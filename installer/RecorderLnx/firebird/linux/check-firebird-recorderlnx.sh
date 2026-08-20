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
check_path /opt/firebird/bin/firebird
check_path /opt/firebird/SYSDBA.password
check_path /etc/profile.d/recorderlnx-sqldb.sh
check_path /var/opt/mera/SQLdb
check_path /var/opt/mera/RecorderLnx/sqldb

if [ -d /var/opt/mera/SQLdb ]; then
  echo "INFO $(ls -ld /var/opt/mera/SQLdb)"
fi

if command -v systemctl >/dev/null 2>&1; then
  if systemctl is-active --quiet firebird.service; then
    echo "OK   firebird.service is active"
  else
    echo "MISS firebird.service is not active"
    status=1
  fi
fi

if command -v ldd >/dev/null 2>&1 && [ -x /opt/firebird/bin/firebird ]; then
  if ldd /opt/firebird/bin/firebird | grep -q 'not found'; then
    echo "MISS Firebird shared libraries:"
    ldd /opt/firebird/bin/firebird | grep 'not found' || true
    status=1
  else
    echo "OK   Firebird shared libraries are resolved"
  fi
fi

exit "$status"
