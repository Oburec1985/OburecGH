#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LOG_FILE="${RECORDERLNX_FIREBIRD_LOG:-/tmp/recorderlnx-firebird-install.log}"
FIREBIRD_PREFIX="/opt/firebird"
PROFILE_FILE="/etc/profile.d/recorderlnx-sqldb.sh"
RECORDERLNX_SQLDB_CONFIG="/var/opt/mera/RecorderLnx/config/projects/default/sql-db.ini"
RECORDERLNX_SQLDB_DIR="/var/opt/mera/SQLdb"
RECORDERLNX_LEGACY_SQLDB_DIR="/var/opt/mera/RecorderLnx/sqldb"
ALLOW_ONLINE_DEPS="${RECORDERLNX_FIREBIRD_ONLINE_DEPS:-0}"
INSTALL_FIREBIRD=0
INSTALL_RCPANEL=0
NO_GUI=0

usage() {
  cat <<'EOF'
Usage: install-firebird-recorderlnx.sh [--firebird] [--rcpanel] [--all] [--no-gui]
With no component flags, a Zenity checklist is shown.
EOF
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --firebird) INSTALL_FIREBIRD=1 ;;
      --rcpanel) INSTALL_RCPANEL=1 ;;
      --all) INSTALL_FIREBIRD=1; INSTALL_RCPANEL=1 ;;
      --no-gui) NO_GUI=1 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
  done
}

choose_components() {
  local selected
  if [ "$INSTALL_FIREBIRD" = 1 ] || [ "$INSTALL_RCPANEL" = 1 ]; then
    return
  fi
  if [ "$NO_GUI" = 1 ]; then
    echo "No component selected. Use --firebird, --rcpanel, or --all." >&2
    exit 2
  fi
  if ! command -v zenity >/dev/null 2>&1; then
    echo "Zenity was not found. Run with --firebird, --rcpanel, or --all." >&2
    exit 2
  fi
  selected="$(zenity --list --checklist \
    --title='RecorderLnx: дополнительные компоненты' \
    --text='Выберите компоненты для установки:' \
    --column='Установить' --column='Компонент' --column='Назначение' \
    TRUE Firebird 'Локальная SQL база данных' \
    TRUE rcPanel 'Панель управления RecorderLnx' \
    --separator='|' --width=650 --height=300)" || exit 0
  case "|$selected|" in *'|Firebird|'*) INSTALL_FIREBIRD=1 ;; esac
  case "|$selected|" in *'|rcPanel|'*) INSTALL_RCPANEL=1 ;; esac
  if [ "$INSTALL_FIREBIRD" = 0 ] && [ "$INSTALL_RCPANEL" = 0 ]; then
    echo "No component selected."
    exit 0
  fi
}

parse_args "$@"
choose_components

exec > >(tee -a "$LOG_FILE") 2>&1

echo "RecorderLnx Firebird installer"
echo "Log: $LOG_FILE"
echo

if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    echo "Requesting administrator permissions..."
    reexec_args=(--no-gui)
    [ "$INSTALL_FIREBIRD" = 1 ] && reexec_args+=(--firebird)
    [ "$INSTALL_RCPANEL" = 1 ] && reexec_args+=(--rcpanel)
    exec sudo -E bash "$0" "${reexec_args[@]}"
  fi
  echo "Run this script as root or install sudo first."
  exit 1
fi

find_archive() {
  local archive
  archive="$(find "$SCRIPT_DIR" -maxdepth 1 -type f \
    -name 'Firebird-*-linux-x64.tar.gz' | sort | tail -n 1)"
  if [ -z "$archive" ]; then
    echo "Firebird linux x64 archive was not found in: $SCRIPT_DIR"
    exit 1
  fi
  printf '%s\n' "$archive"
}

install_local_dependencies() {
  local dep_dir="$SCRIPT_DIR/deps"
  local packages=()
  local package

  if ! command -v dpkg >/dev/null 2>&1; then
    echo "dpkg was not found; skipping local .deb dependency install."
    return
  fi

  if [ -d "$dep_dir" ]; then
    while IFS= read -r -d '' package; do
      packages+=("$package")
    done < <(find "$dep_dir" -maxdepth 1 -type f -name '*.deb' -print0 | sort -z)
  fi

  if [ "${#packages[@]}" -eq 0 ]; then
    echo "No local dependency packages found in: $dep_dir"
    echo "Offline mode: apt repositories will not be used."
    return
  fi

  echo "Installing local dependency packages from: $dep_dir"
  dpkg -i "${packages[@]}" || true
  if dpkg --audit | grep -q .; then
    echo "WARN dpkg reports unresolved dependencies after local package install."
    echo "     Add missing .deb packages to '$dep_dir' and run this script again."
    dpkg --audit || true
  fi
}

install_online_dependencies_if_requested() {
  if [ "$ALLOW_ONLINE_DEPS" != "1" ]; then
    return
  fi
  if command -v apt-get >/dev/null 2>&1; then
    echo "Online dependency install is explicitly enabled."
    apt-get update
    apt-get install -y libicu-dev libncurses6 libtommath1 libtomcrypt1 || \
      apt-get install -y libicu-dev libncurses6 libtommath-dev libtomcrypt-dev
  else
    echo "apt-get was not found; online dependency install skipped."
  fi
}

install_firebird() {
  local archive="$1"
  local work_dir
  local extracted_dir

  if [ -x "$FIREBIRD_PREFIX/bin/isql" ]; then
    echo "Firebird already installed in $FIREBIRD_PREFIX"
    return
  fi

  work_dir="$(mktemp -d /tmp/recorderlnx-firebird.XXXXXX)"
  trap 'rm -rf "$work_dir"' EXIT

  echo "Extracting: $archive"
  tar -xzf "$archive" -C "$work_dir"
  extracted_dir="$(find "$work_dir" -maxdepth 1 -type d -name 'Firebird-*' | head -n 1)"
  if [ -z "$extracted_dir" ] || [ ! -x "$extracted_dir/install.sh" ]; then
    echo "Firebird install.sh was not found after extraction."
    exit 1
  fi

  echo "Running Firebird silent installer..."
  (cd "$extracted_dir" && ./install.sh -silent)
}

enable_firebird_service() {
  if command -v systemctl >/dev/null 2>&1; then
    echo "Enabling Firebird service..."
    systemctl daemon-reload || true
    systemctl enable firebird.service || true
    systemctl restart firebird.service || systemctl start firebird.service || true
    systemctl --no-pager --full status firebird.service || true
  else
    echo "systemctl was not found; please start Firebird manually if needed."
  fi
}

firebird_account() {
  if getent passwd firebird >/dev/null 2>&1; then
    printf '%s\n' 'firebird'
  elif getent passwd firebirdsql >/dev/null 2>&1; then
    printf '%s\n' 'firebirdsql'
  else
    printf '%s\n' 'root'
  fi
}

prepare_recorderlnx_sqldb_dirs() {
  local fb_user
  local fb_group

  fb_user="$(firebird_account)"
  fb_group="$fb_user"
  if ! getent group "$fb_group" >/dev/null 2>&1; then
    fb_group="root"
  fi

  echo "Preparing RecorderLnx SQL DB directories..."
  install -d -m 2775 "$RECORDERLNX_SQLDB_DIR"
  install -d -m 2775 "$RECORDERLNX_LEGACY_SQLDB_DIR"
  chown "$fb_user:$fb_group" "$RECORDERLNX_SQLDB_DIR" || true
  chown "$fb_user:$fb_group" "$RECORDERLNX_LEGACY_SQLDB_DIR" || true
  chmod 2775 "$RECORDERLNX_SQLDB_DIR" "$RECORDERLNX_LEGACY_SQLDB_DIR" || true
  echo "OK   $RECORDERLNX_SQLDB_DIR owner target: $fb_user:$fb_group"
  echo "OK   $RECORDERLNX_LEGACY_SQLDB_DIR owner target: $fb_user:$fb_group"
}

desktop_user() {
  local candidate
  candidate="${SUDO_USER:-}"
  if [ -n "$candidate" ] && [ "$candidate" != root ] &&
     id "$candidate" >/dev/null 2>&1; then
    printf '%s\n' "$candidate"
    return
  fi
  candidate="$(awk -F: '$3 >= 1000 && $3 < 65534 && $6 ~ "^/home/" && $7 !~ /(nologin|false)$/ {print $1}' /etc/passwd)"
  if [ "$(printf '%s\n' "$candidate" | sed '/^$/d' | wc -l)" -eq 1 ]; then
    printf '%s\n' "$candidate" | sed '/^$/d'
  fi
}

desktop_dir_from_user_dirs() {
  local user_home="$1"
  local user_dirs="$user_home/.config/user-dirs.dirs"
  local desktop_line
  local desktop_value

  [ -f "$user_dirs" ] || return 1
  desktop_line="$(grep '^XDG_DESKTOP_DIR=' "$user_dirs" 2>/dev/null | tail -n 1 || true)"
  [ -n "$desktop_line" ] || return 1
  desktop_value="$(printf '%s\n' "$desktop_line" | sed 's/^XDG_DESKTOP_DIR=//; s/^"//; s/"$//')"
  desktop_value="$(printf '%s\n' "$desktop_value" | sed "s|\$HOME|$user_home|g")"
  [ -n "$desktop_value" ] || return 1
  printf '%s\n' "$desktop_value"
}

install_rcpanel_desktop_shortcuts() {
  local src=/usr/share/applications/rcpanel.desktop
  local home
  local user
  local desktop
  local xdg_desktop
  local candidates

  [ -f "$src" ] || return 0
  for home in /home/*; do
    [ -d "$home" ] || continue
    user="$(basename "$home")"
    candidates="$home/Desktop"
    xdg_desktop="$(desktop_dir_from_user_dirs "$home" || true)"
    if [ -n "$xdg_desktop" ] && [ "$xdg_desktop" != "$home/Desktop" ]; then
      candidates="$xdg_desktop
$candidates"
    fi
    while IFS= read -r desktop; do
      [ -n "$desktop" ] || continue
      [ -d "$desktop" ] || continue
      cp "$src" "$desktop/rcPanel.desktop" || continue
      sed -i 's|^Icon=.*$|Icon=/usr/share/pixmaps/rcpanel.png|' \
        "$desktop/rcPanel.desktop"
      chmod 0755 "$desktop/rcPanel.desktop" || true
      chown "$user:$user" "$desktop/rcPanel.desktop" 2>/dev/null || true
      echo "OK   rcPanel desktop shortcut: $desktop/rcPanel.desktop"
    done <<EOF
$candidates
EOF
  done
}

find_rcpanel_binary() {
  local bundled="$SCRIPT_DIR/payload/RecorderCoordinator"
  local repo_binary="$SCRIPT_DIR/../../../../Lazarus/RecorderCoordinator/lib/x86_64-linux/RecorderCoordinator"
  if [ -f "$bundled" ]; then
    printf '%s\n' "$bundled"
  elif [ -f "$repo_binary" ]; then
    printf '%s\n' "$repo_binary"
  else
    echo "rcPanel payload was not found. Run prepare-installer.ps1 first." >&2
    return 1
  fi
}

normalize_rcpanel_config() {
  local config_file="$1"

  if grep -q '^[[:space:]]*sql_db_config[[:space:]]*=' "$config_file"; then
    sed -i \
      "s|^[[:space:]]*sql_db_config[[:space:]]*=.*$|sql_db_config=$RECORDERLNX_SQLDB_CONFIG|" \
      "$config_file"
  elif grep -q '^\[events\][[:space:]]*$' "$config_file"; then
    sed -i "/^\[events\][[:space:]]*$/a sql_db_config=$RECORDERLNX_SQLDB_CONFIG" \
      "$config_file"
  else
    printf '\n[events]\nsql_db_config=%s\n' "$RECORDERLNX_SQLDB_CONFIG" >> "$config_file"
  fi
  echo "OK   rcPanel SQL config path: $RECORDERLNX_SQLDB_CONFIG"
}

install_rcpanel() {
  local source_binary
  local runtime_user
  local runtime_group
  local config_file=/opt/mera/RecorderCoordinator/RecorderCoordinator.ini
  local log_file=/opt/mera/RecorderCoordinator/RecorderCoordinator.log
  local archive_dir=/var/opt/mera/RecorderCoordinator/archive

  source_binary="$(find_rcpanel_binary)"
  if [ "$source_binary" = "$SCRIPT_DIR/payload/RecorderCoordinator" ] &&
     [ -f "$SCRIPT_DIR/payload/RecorderCoordinator.sha256" ] &&
     command -v sha256sum >/dev/null 2>&1; then
    (cd "$SCRIPT_DIR/payload" && sha256sum -c RecorderCoordinator.sha256)
  fi
  if [ "$(dd if="$source_binary" bs=1 count=4 2>/dev/null)" != "$(printf '\177ELF')" ]; then
    echo "rcPanel payload is not a Linux ELF executable: $source_binary" >&2
    exit 1
  fi

  install -d -m 0755 /opt/mera/RecorderCoordinator
  install -m 0755 "$source_binary" /opt/mera/RecorderCoordinator/RecorderCoordinator
  install -d -m 0755 /usr/share/icons/hicolor/256x256/apps
  install -m 0644 "$SCRIPT_DIR/payload/rcpanel.png" /usr/share/icons/hicolor/256x256/apps/rcpanel.png
  install -d -m 0755 /usr/share/pixmaps
  install -m 0644 "$SCRIPT_DIR/payload/rcpanel.png" /usr/share/pixmaps/rcpanel.png
  install -d -m 0755 /var/opt/mera/RecorderCoordinator
  install -d -m 0755 "$archive_dir"
  touch "$config_file" "$log_file"
  if [ ! -s "$config_file" ]; then
    cat > "$config_file" <<'EOF'
[service]
listen=0.0.0.0
port=8765
event_window_sec=30

[events]
create_recording_events=1
sql_db_config=/var/opt/mera/RecorderLnx/config/projects/default/sql-db.ini

[commands]
start_all_on_any_recording=0

[storages]
count=1

[storage.0]
name=Локальный архив
kind=local
root=/var/opt/mera/RecorderCoordinator/archive
host=
user=
EOF
  fi
  normalize_rcpanel_config "$config_file"

  runtime_user="$(desktop_user)"
  if [ -n "$runtime_user" ]; then
    runtime_group="$(id -gn "$runtime_user")"
    chown "$runtime_user:$runtime_group" "$config_file" "$log_file"
    chown -R "$runtime_user:$runtime_group" /var/opt/mera/RecorderCoordinator
    chmod 0600 "$config_file" "$log_file"
    chmod 0700 /var/opt/mera/RecorderCoordinator "$archive_dir"
  else
    echo "WARN Desktop user is unknown; rcPanel writable files remain root-owned."
  fi

  cat > /usr/bin/rcpanel <<'EOF'
#!/bin/sh
if [ -r /etc/profile.d/recorderlnx-sqldb.sh ]; then
  . /etc/profile.d/recorderlnx-sqldb.sh
fi
exec /opt/mera/RecorderCoordinator/RecorderCoordinator "$@"
EOF
  chmod 0755 /usr/bin/rcpanel
  cat > /usr/share/applications/rcpanel.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=rcPanel
GenericName=RecorderLnx Control Panel
Comment=Панель управления RecorderLnx
Exec=/usr/bin/rcpanel
Path=/opt/mera/RecorderCoordinator
Terminal=false
Icon=rcpanel
Categories=Utility;
Keywords=RecorderLnx;Mera;Coordinator;rcPanel;
StartupNotify=false
EOF
  chmod 0644 /usr/share/applications/rcpanel.desktop
  install_rcpanel_desktop_shortcuts
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
  fi
  echo "OK   rcPanel installed (internal binary name: RecorderCoordinator)"
}

write_recorderlnx_password_env() {
  local password
  local escaped_password

  if [ ! -f "$FIREBIRD_PREFIX/SYSDBA.password" ]; then
    echo "SYSDBA password file was not found: $FIREBIRD_PREFIX/SYSDBA.password"
    return
  fi

  password="$(awk -F= '/^ISC_PASSWORD=/{print $2; exit}' \
    "$FIREBIRD_PREFIX/SYSDBA.password")"
  if [ -z "$password" ]; then
    echo "Could not read ISC_PASSWORD from $FIREBIRD_PREFIX/SYSDBA.password"
    return
  fi

  cat > "$PROFILE_FILE" <<EOF
# Created by install-firebird-recorderlnx.sh.
export RECORDERLNX_SQLDB_ROOT='$RECORDERLNX_SQLDB_DIR'
EOF
  chmod 0644 "$PROFILE_FILE"
  echo "RecorderLnx SQL root environment file created: $PROFILE_FILE"

  if [ -f "$RECORDERLNX_SQLDB_CONFIG" ]; then
    config_owner="${SUDO_USER:-}"
    if [ -z "$config_owner" ] || [ "$config_owner" = "root" ]; then
      config_owner="$(stat -c '%U' "$RECORDERLNX_SQLDB_CONFIG" 2>/dev/null || true)"
    fi
    if [ -z "$config_owner" ] || [ "$config_owner" = "root" ]; then
      echo "Cannot determine RecorderLnx desktop user. Run this installer via sudo from that user."
      exit 1
    fi
    escaped_password="$(printf '%s' "$password" | sed 's/[\\&|]/\\&/g')"
    if grep -q '^Password=' "$RECORDERLNX_SQLDB_CONFIG"; then
      sed -i "s|^Password=.*$|Password=$escaped_password|" \
        "$RECORDERLNX_SQLDB_CONFIG"
    else
      printf '\nPassword=%s\n' "$password" >> "$RECORDERLNX_SQLDB_CONFIG"
    fi
    chmod 0600 "$RECORDERLNX_SQLDB_CONFIG"
    config_group="$(id -gn "$config_owner")"
    config_root="$(dirname "$(dirname "$(dirname "$RECORDERLNX_SQLDB_CONFIG")")")"
    chown -R "$config_owner:$config_group" "$config_root"
    find "$config_root" -type d -exec chmod 0700 {} +
    find "$config_root" -type f -exec chmod 0600 {} +
    install -d -m 0700 -o "$config_owner" -g "$config_group" \
      "$RECORDERLNX_SQLDB_DIR/data"
    echo "RecorderLnx SQL password stored in: $RECORDERLNX_SQLDB_CONFIG"
  else
    echo "RecorderLnx SQL config not found. Install RecorderLnx and repeat this installer."
  fi
}

check_firebird() {
  echo
  echo "Checking Firebird installation..."
  if [ -x "$FIREBIRD_PREFIX/bin/isql" ]; then
    echo "OK   $FIREBIRD_PREFIX/bin/isql"
  else
    echo "MISS $FIREBIRD_PREFIX/bin/isql"
    exit 1
  fi
  if [ -x "$FIREBIRD_PREFIX/bin/gfix" ]; then
    echo "OK   $FIREBIRD_PREFIX/bin/gfix"
  else
    echo "MISS $FIREBIRD_PREFIX/bin/gfix"
  fi
  if [ -x "$FIREBIRD_PREFIX/bin/gbak" ]; then
    echo "OK   $FIREBIRD_PREFIX/bin/gbak"
  else
    echo "MISS $FIREBIRD_PREFIX/bin/gbak"
  fi

  if [ -f "$PROFILE_FILE" ]; then
    echo "OK   $PROFILE_FILE"
  else
    echo "MISS $PROFILE_FILE"
  fi

  if [ -d "$RECORDERLNX_SQLDB_DIR" ]; then
    echo "OK   $RECORDERLNX_SQLDB_DIR"
    ls -ld "$RECORDERLNX_SQLDB_DIR" || true
  else
    echo "MISS $RECORDERLNX_SQLDB_DIR"
  fi

  if [ -d "$RECORDERLNX_LEGACY_SQLDB_DIR" ]; then
    echo "OK   $RECORDERLNX_LEGACY_SQLDB_DIR"
    ls -ld "$RECORDERLNX_LEGACY_SQLDB_DIR" || true
  else
    echo "MISS $RECORDERLNX_LEGACY_SQLDB_DIR"
  fi

  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet firebird.service; then
      echo "OK   firebird.service is active"
    else
      echo "WARN firebird.service is not active"
    fi
  fi

  if command -v ldd >/dev/null 2>&1; then
    echo
    echo "Checking Firebird shared libraries..."
    if ldd "$FIREBIRD_PREFIX/bin/firebird" | grep -q 'not found'; then
      ldd "$FIREBIRD_PREFIX/bin/firebird" | grep 'not found' || true
      echo "WARN Missing shared libraries. Put required Debian .deb packages into:"
      echo "     $SCRIPT_DIR/deps"
    else
      echo "OK   Firebird shared libraries are resolved"
    fi
  fi
}

main() {
  local archive
  if [ "$INSTALL_RCPANEL" = 1 ]; then
    install_rcpanel
  fi
  if [ "$INSTALL_FIREBIRD" = 1 ]; then
    archive="$(find_archive)"
    install_local_dependencies
    install_online_dependencies_if_requested
    install_firebird "$archive"
    enable_firebird_service
    prepare_recorderlnx_sqldb_dirs
    write_recorderlnx_password_env
    check_firebird
  fi
  echo
  echo "Done. Selected components were installed."
}

main "$@"
