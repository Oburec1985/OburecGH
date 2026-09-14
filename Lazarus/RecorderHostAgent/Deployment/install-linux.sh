#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_BIN="$SCRIPT_DIR/../../RecorderLnx/lib/x86_64-linux/RecorderHostAgent"
INSTALL_DIR=/opt/mera/RecorderLnx
CONFIG="$INSTALL_DIR/RecorderHostAgent.ini"

[ -x "$SOURCE_BIN" ] || {
  echo "Build Linux RecorderHostAgent first: $SOURCE_BIN" >&2
  exit 1
}
install -d -m 0755 "$INSTALL_DIR" /usr/lib/systemd/user /usr/local/sbin
install -m 0755 "$SOURCE_BIN" "$INSTALL_DIR/RecorderHostAgent"
install -m 0755 "$SCRIPT_DIR/recorder-host-agent-shutdown" \
  /usr/local/sbin/recorder-host-agent-shutdown
install -m 0644 "$SCRIPT_DIR/recorder-host-agent.service" \
  /usr/lib/systemd/user/recorder-host-agent.service
if [ ! -f "$CONFIG" ]; then
  cat >"$CONFIG" <<'EOF'
[agent]
listen=0.0.0.0
port=8766
recorder_path=/usr/bin/recorderlnx
allow_shutdown=0
api_token=
EOF
  chmod 0644 "$CONFIG"
fi
systemctl --global enable recorder-host-agent.service
RUNTIME_USER=${SUDO_USER:-}
if [ -n "$RUNTIME_USER" ] && [ "$RUNTIME_USER" != root ]; then
  printf '%s ALL=(root) NOPASSWD: /usr/local/sbin/recorder-host-agent-shutdown\n' \
    "$RUNTIME_USER" > /etc/sudoers.d/recorder-host-agent
  chmod 0440 /etc/sudoers.d/recorder-host-agent
  if command -v visudo >/dev/null 2>&1; then
    visudo -cf /etc/sudoers.d/recorder-host-agent
  fi
  sed -i 's/^allow_shutdown=.*/allow_shutdown=1/' "$CONFIG"
fi
echo "RecorderHostAgent is enabled for desktop user sessions."
echo "For the current user run: systemctl --user enable --now recorder-host-agent.service"
echo "Diagnostics: journalctl --user -u recorder-host-agent.service"
