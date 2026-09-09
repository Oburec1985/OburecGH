#!/usr/bin/env bash
set -euo pipefail

status=0
check_firebird=0
check_rcpanel=0

usage() {
  echo "Usage: check-firebird-recorderlnx.sh [--firebird] [--rcpanel] [--all]"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --firebird) check_firebird=1 ;;
    --rcpanel) check_rcpanel=1 ;;
    --all) check_firebird=1; check_rcpanel=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ "$check_firebird" = 0 ] && [ "$check_rcpanel" = 0 ]; then
  check_firebird=1
  check_rcpanel=1
fi

check_path() {
  local path="$1"
  if [ -e "$path" ]; then
    echo "OK   $path"
  else
    echo "MISS $path"
    status=1
  fi
}

check_executable() {
  local path="$1"
  if [ -x "$path" ]; then
    echo "OK   $path is executable"
  else
    echo "MISS $path is not executable"
    status=1
  fi
}

check_writable() {
  local path="$1"
  if [ -w "$path" ]; then
    echo "OK   $path is writable by $(id -un)"
  else
    echo "MISS $path is not writable by $(id -un)"
    status=1
  fi
}

check_firebird_installation() {
  echo "Checking Firebird..."
  check_path /opt/firebird/bin/isql
  check_path /opt/firebird/bin/firebird
  check_path /opt/firebird/bin/gfix
  check_path /opt/firebird/bin/gbak
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
}

check_rcpanel_installation() {
  echo "Checking rcPanel..."
  check_executable /opt/mera/RecorderCoordinator/RecorderCoordinator
  check_path /opt/mera/RecorderCoordinator/RecorderCoordinator.ini
  check_path /opt/mera/RecorderCoordinator/RecorderCoordinator.log
  check_path /var/opt/mera/RecorderCoordinator/archive
  check_executable /usr/bin/rcpanel
  check_path /usr/share/applications/rcpanel.desktop
  check_path /usr/share/icons/hicolor/256x256/apps/rcpanel.png
  check_path /usr/share/pixmaps/rcpanel.png
  if grep -q '^Icon=rcpanel$' /usr/share/applications/rcpanel.desktop; then
    echo "OK   rcPanel desktop icon name"
  else
    echo "FAIL rcPanel desktop icon name"
    status=1
  fi
  if grep -q '^sql_db_config=/var/opt/mera/RecorderLnx/config/projects/default/sql-db.ini$' \
    /opt/mera/RecorderCoordinator/RecorderCoordinator.ini; then
    echo "OK   rcPanel SQL config path"
  else
    echo "FAIL rcPanel SQL config path"
    status=1
  fi
  [ ! -e /opt/mera/RecorderCoordinator/RecorderCoordinator.ini ] || check_writable /opt/mera/RecorderCoordinator/RecorderCoordinator.ini
  [ ! -e /opt/mera/RecorderCoordinator/RecorderCoordinator.log ] || check_writable /opt/mera/RecorderCoordinator/RecorderCoordinator.log
  [ ! -d /var/opt/mera/RecorderCoordinator/archive ] || check_writable /var/opt/mera/RecorderCoordinator/archive
}

if [ "$check_firebird" = 1 ]; then
  check_firebird_installation
fi
if [ "$check_rcpanel" = 1 ]; then
  [ "$check_firebird" = 0 ] || echo
  check_rcpanel_installation
fi

exit "$status"
