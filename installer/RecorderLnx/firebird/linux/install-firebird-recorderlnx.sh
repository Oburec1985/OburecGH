#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LOG_FILE="${RECORDERLNX_FIREBIRD_LOG:-/tmp/recorderlnx-firebird-install.log}"
FIREBIRD_PREFIX="/opt/firebird"
PROFILE_FILE="/etc/profile.d/recorderlnx-sqldb.sh"

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

install_dependencies() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "Installing Firebird dependencies through apt..."
    apt-get update || echo "WARN apt-get update failed; continuing with local library check."
    apt-get install -y libicu-dev libncurses6 libtommath1 libtomcrypt1 || \
      apt-get install -y libicu-dev libncurses6 libtommath-dev libtomcrypt-dev || \
      echo "WARN dependency install failed; Firebird installer will check required libraries."
    return
  fi
  echo "apt-get was not found; assuming required libraries are already installed."
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

  escaped_password="${password//\'/\'\\\'\'}"
  cat > "$PROFILE_FILE" <<EOF
# RecorderLnx SQL DB password for Firebird SYSDBA.
# Created by install-firebird-recorderlnx.sh.
export RECORDERLNX_SQLDB_PASSWORD='$escaped_password'
EOF
  chmod 0644 "$PROFILE_FILE"
  echo "RecorderLnx SQL password environment file created: $PROFILE_FILE"
  echo "For current terminal only, run: source $PROFILE_FILE"
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

  if [ -f "$PROFILE_FILE" ]; then
    echo "OK   $PROFILE_FILE"
  else
    echo "MISS $PROFILE_FILE"
  fi

  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet firebird.service; then
      echo "OK   firebird.service is active"
    else
      echo "WARN firebird.service is not active"
    fi
  fi
}

main() {
  local archive
  archive="$(find_archive)"
  install_dependencies
  install_firebird "$archive"
  enable_firebird_service
  write_recorderlnx_password_env
  check_firebird
  echo
  echo "Done. Re-login or restart RecorderLnx so it can see RECORDERLNX_SQLDB_PASSWORD."
}

main "$@"
