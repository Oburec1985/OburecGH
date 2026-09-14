#!/usr/bin/env bash
set -euo pipefail

SHARE_NAME="MeraFiles"
REQUESTED_PATH="${1:-}"

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -- "$0" "$@"
fi

detect_desktop_user() {
  if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    printf '%s\n' "$SUDO_USER"
    return
  fi
  awk -F: '$3 >= 1000 && $3 < 65534 && $6 ~ /^\/home\// {print $1; exit}' /etc/passwd
}

DESKTOP_USER="$(detect_desktop_user)"
if [ -z "$DESKTOP_USER" ]; then
  echo "ERROR: не удалось определить пользователя рабочего стола." >&2
  exit 1
fi
DESKTOP_GROUP="$(id -gn "$DESKTOP_USER")"
USER_HOME="$(getent passwd "$DESKTOP_USER" | cut -d: -f6)"

if [ -n "$REQUESTED_PATH" ]; then
  MERA_PATH="$REQUESTED_PATH"
elif [ -d "$USER_HOME/Mera Files" ]; then
  MERA_PATH="$USER_HOME/Mera Files"
elif [ -d /var/opt/mera ]; then
  MERA_PATH=/var/opt/mera
else
  MERA_PATH="$USER_HOME/Mera Files"
fi

if ! command -v smbd >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y samba smbclient
fi

install -d -m 0775 -o "$DESKTOP_USER" -g "$DESKTOP_GROUP" "$MERA_PATH"
install -d -m 0775 -o "$DESKTOP_USER" -g "$DESKTOP_GROUP" "$MERA_PATH/SDB"

SMB_CONF=/etc/samba/smb.conf
BEGIN_MARKER="# BEGIN RECORDERLNX MERA FILES"
END_MARKER="# END RECORDERLNX MERA FILES"
TEMP_CONF="$(mktemp)"
trap 'rm -f "$TEMP_CONF"' EXIT

awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
  $0 == begin {skip=1; next}
  $0 == end {skip=0; next}
  !skip {print}
' "$SMB_CONF" > "$TEMP_CONF"

cat >> "$TEMP_CONF" <<EOF

$BEGIN_MARKER
[$SHARE_NAME]
   path = $MERA_PATH
   browseable = yes
   read only = no
   guest ok = yes
   guest only = yes
   force user = $DESKTOP_USER
   force group = $DESKTOP_GROUP
   create mask = 0664
   directory mask = 0775
$END_MARKER
EOF

testparm -s "$TEMP_CONF" >/dev/null
install -m 0644 "$TEMP_CONF" "$SMB_CONF"

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now smbd
  systemctl restart smbd
else
  service smbd restart
fi

if command -v ufw >/dev/null 2>&1 && ufw status | grep -q '^Status: active'; then
  ufw allow Samba
fi

echo "OK: $MERA_PATH опубликован как //$HOSTNAME/$SHARE_NAME"
echo "SDB: //$HOSTNAME/$SHARE_NAME/SDB"
