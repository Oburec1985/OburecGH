#!/bin/sh
set -e

LOG=/var/opt/mera/RecorderLnx/install.log

log() {
  echo "$@"
  if [ -n "$LOG" ]; then
    echo "$@" >> "$LOG" 2>/dev/null || true
  fi
}

desktop_dir_from_user_dirs() {
  user_home="$1"
  user_dirs="$user_home/.config/user-dirs.dirs"
  [ -f "$user_dirs" ] || return 1
  desktop_line=$(grep '^XDG_DESKTOP_DIR=' "$user_dirs" 2>/dev/null | tail -n 1 || true)
  [ -n "$desktop_line" ] || return 1
  desktop_value=$(printf '%s\n' "$desktop_line" | sed 's/^XDG_DESKTOP_DIR=//; s/^"//; s/"$//')
  desktop_value=$(printf '%s\n' "$desktop_value" | sed "s|\$HOME|$user_home|g")
  [ -n "$desktop_value" ] || return 1
  printf '%s\n' "$desktop_value"
  return 0
}

install_desktop_shortcuts() {
  src=/usr/share/applications/recorderlnx.desktop
  [ -f "$src" ] || { log "desktop source not found: $src"; return 0; }
  for home in /home/*; do
    [ -d "$home" ] || continue
    user=$(basename "$home")
    candidates="$home/Desktop"
    xdg_desktop=$(desktop_dir_from_user_dirs "$home" || true)
    if [ -n "$xdg_desktop" ] && [ "$xdg_desktop" != "$home/Desktop" ]; then
      candidates="$xdg_desktop
$candidates"
    fi
    printf '%s\n' "$candidates" | while IFS= read -r desktop; do
      [ -n "$desktop" ] || continue
      [ -d "$desktop" ] || continue
      cp "$src" "$desktop/RecorderLnx.desktop" || {
        log "failed to copy desktop shortcut to $desktop"
        continue
      }
      chmod 755 "$desktop/RecorderLnx.desktop" || true
      chown "$user:$user" "$desktop/RecorderLnx.desktop" 2>/dev/null || true
      log "desktop shortcut created: $desktop/RecorderLnx.desktop"
    done
  done
}

mkdir -p /var/opt/mera/RecorderLnx/config/projects/default
mkdir -p /var/opt/mera/SQLdb
mkdir -p /var/opt/mera/Calibr /var/opt/mera/Resources /var/opt/mera/SDB
mkdir -p /opt/mera/RecorderLnx/lib
touch "$LOG" 2>/dev/null || true
log "RecorderLnx postinst started"
fbclient_path=$(ldconfig -p 2>/dev/null | awk '/libfbclient[.]so[.]2([[:space:]]|$)/ {print $NF; exit}')
if [ -z "$fbclient_path" ]; then
  fbclient_path=$(find /usr/lib /lib \( -type f -o -type l \) \
    -name 'libfbclient.so.2' -print 2>/dev/null | head -n 1 || true)
fi
if [ -n "$fbclient_path" ] && [ -e "$fbclient_path" ]; then
  ln -sfn "$fbclient_path" /opt/mera/RecorderLnx/lib/libfbclient.so
  log "Firebird client compatibility link: /opt/mera/RecorderLnx/lib/libfbclient.so -> $fbclient_path"
else
  log "ERROR libfbclient.so.2 was not found after package dependency installation"
fi
if [ ! -f /var/opt/mera/RecorderLnx/config/app.ini ]; then
  cp /usr/share/recorderlnx/config/app.ini /var/opt/mera/RecorderLnx/config/app.ini
  log "app.ini copied"
fi
if [ ! -f /var/opt/mera/RecorderLnx/config/projects/default/default.config.json ]; then
  cp -a /usr/share/recorderlnx/config/projects/default/. /var/opt/mera/RecorderLnx/config/projects/default/
  log "default project copied"
fi
chmod 755 /opt/mera/RecorderLnx/RecorderLnx
chmod 755 /opt/mera/RecorderLnx/RecorderHostAgent
if command -v systemctl >/dev/null 2>&1; then
  # This is deliberately a user service.  RecorderHostAgent must inherit the
  # logged-in user's DISPLAY/Wayland session so the GUI RecorderLnx it starts
  # is visible.  A root system service would launch it outside that session.
  systemctl --global enable recorder-host-agent.service >/dev/null 2>&1 ||     log "failed to enable RecorderHostAgent user service globally"
  log "RecorderHostAgent enabled for user sessions"
else
  log "systemctl not found; RecorderHostAgent autostart was not enabled"
fi
config_root=/var/opt/mera/RecorderLnx/config
runtime_user="${SUDO_USER:-}"
if [ -z "$runtime_user" ] || [ "$runtime_user" = root ]; then
  runtime_user=$(stat -c '%U' "$config_root" 2>/dev/null || true)
fi
if [ -z "$runtime_user" ] || [ "$runtime_user" = root ]; then
  # A GUI package installer/dpkg normally has no SUDO_USER.  Select a user
  # only when the machine has exactly one regular interactive /home account;
  # on multi-user systems keep the fail-closed behaviour below.
  runtime_candidates=$(awk -F: '$3 >= 1000 && $3 < 65534 && $6 ~ "^/home/" && $7 !~ /(nologin|false)$/ {print $1}' /etc/passwd)
  if [ "$(printf '%s
' "$runtime_candidates" | sed '/^$/d' | wc -l)" -eq 1 ]; then
    runtime_user=$(printf '%s
' "$runtime_candidates" | sed '/^$/d')
  fi
fi
if [ -n "$runtime_user" ] && [ "$runtime_user" != root ] && id "$runtime_user" >/dev/null 2>&1; then
  runtime_group=$(id -gn "$runtime_user")
  chown -R "$runtime_user:$runtime_group" "$config_root"     /var/opt/mera/Calibr /var/opt/mera/Resources /var/opt/mera/SDB
  find "$config_root" /var/opt/mera/Calibr /var/opt/mera/Resources     /var/opt/mera/SDB -type d -exec chmod 0700 {} +
  find "$config_root" /var/opt/mera/Calibr /var/opt/mera/Resources     /var/opt/mera/SDB -type f -exec chmod 0600 {} +
else
  log "runtime user is unknown; writable config permissions were not broadened"
fi
install_desktop_shortcuts
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi
/usr/bin/recorderlnx-install-check >> "$LOG" 2>&1 || true
log "RecorderLnx postinst finished"
exit 0
