#!/bin/sh
set -e
if [ "${1:-}" = remove ] || [ "${1:-}" = purge ]; then
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --global disable recorder-host-agent.service >/dev/null 2>&1 || true
  fi
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi
exit 0
