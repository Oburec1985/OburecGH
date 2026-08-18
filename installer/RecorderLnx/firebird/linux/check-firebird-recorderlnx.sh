#!/usr/bin/env bash
set -euo pipefail

status=0

check_path() {
  local path="$1"
  if [ -e "$path" ]; then
    echo "OK   $path"
  else
    echo "MISS $path"
    status=1
  fi
}

check_path /opt/firebird/bin/isql
check_path /opt/firebird/SYSDBA.password
check_path /etc/profile.d/recorderlnx-sqldb.sh

if command -v systemctl >/dev/null 2>&1; then
  if systemctl is-active --quiet firebird.service; then
    echo "OK   firebird.service is active"
  else
    echo "MISS firebird.service is not active"
    status=1
  fi
fi

exit "$status"
