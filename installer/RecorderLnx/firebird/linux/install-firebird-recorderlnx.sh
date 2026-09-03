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

exec > >(tee -a "$LOG_FILE") 2>&1

echo "RecorderLnx Firebird installer"
echo "Log: $LOG_FILE"
echo

if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    echo "Requesting administrator permissions..."
    exec sudo -E bash "$0"
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
  archive="$(find_archive)"
  install_local_dependencies
  install_online_dependencies_if_requested
  install_firebird "$archive"
  enable_firebird_service
  prepare_recorderlnx_sqldb_dirs
  write_recorderlnx_password_env
  check_firebird
  echo
  echo "Done. Restart RecorderLnx; the password is stored in its protected config."
}

main "$@"
