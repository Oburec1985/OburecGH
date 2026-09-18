#!/usr/bin/env python3
import argparse
import gzip
import hashlib
import io
import os
import re
import shutil
import tarfile
import time
from pathlib import Path


APP_NAME = "RecorderLnx"
AGENT_NAME = "RecorderHostAgent"
PACKAGE_NAME = "recorderlnx"


def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest().upper()


def newest_source(repo_root):
    roots = [
        repo_root / "Lazarus" / "RecorderLnx",
        repo_root / "Lazarus" / "SharedUtils",
    ]
    suffixes = {".pas", ".pp", ".inc", ".lfm", ".lpr"}
    excluded = {"lib", "tools", "_buildverify", "backup", "cach", "errors", "tmp", ".git"}
    newest = None
    for source_root in roots:
        for path in source_root.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in suffixes:
                continue
            if any(part.lower() in excluded for part in path.parts):
                continue
            if newest is None or path.stat().st_mtime > newest.stat().st_mtime:
                newest = path
    return newest


def newest_tree_source(source_root):
    suffixes = {".pas", ".pp", ".inc", ".lfm", ".lpr"}
    excluded = {"lib", "_buildverify", "backup", "tmp", ".git"}
    newest = None
    for path in source_root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in suffixes:
            continue
        if any(part.lower() in excluded for part in path.parts):
            continue
        if newest is None or path.stat().st_mtime > newest.stat().st_mtime:
            newest = path
    return newest


def expected_schema_version(repo_root):
    source = (repo_root / "Lazarus" / "RecorderLnx" / "SQLdb" /
              "uRecorderSqlDbTypes.pas")
    match = re.search(
        rb"CRecorderSqlDbSchemaVersion\s*=\s*(\d+)", source.read_bytes())
    if not match:
        raise SystemExit(f"Cannot read SQLdb schema version from {source}")
    return int(match.group(1))


def validate_linux_binary(repo_root, linux_exe):
    binary = linux_exe.read_bytes()
    if not binary.startswith(b"\x7fELF"):
        raise SystemExit(f"Not a Linux ELF executable: {linux_exe}")

    latest = newest_source(repo_root)
    if latest is not None and linux_exe.stat().st_mtime < latest.stat().st_mtime:
        raise SystemExit(
            "Linux binary is older than production sources. "
            f"Binary: {linux_exe} ({time.ctime(linux_exe.stat().st_mtime)}); "
            f"newest source: {latest} ({time.ctime(latest.stat().st_mtime)}). "
            "Run lazbuild -B RecorderLnx.lpi on Linux before packaging."
        )

    schema_version = expected_schema_version(repo_root)
    required_markers = [b"Database schema %d is newer than supported %d"]
    if schema_version >= 3:
        required_markers.extend([
            b"RecorderLnx SQLdb maintenance indexes",
            b"idx_signal_values_signal_time",
        ])
    missing = [marker.decode("ascii") for marker in required_markers
               if marker not in binary]
    if missing:
        raise SystemExit(
            f"Linux binary does not match SQLdb schema {schema_version}; "
            f"missing markers: {', '.join(missing)}. Rebuild it on Linux."
        )
    return binary, schema_version


def verify_packaged_binary(data_tar, member_name, expected_binary):
    with gzip.GzipFile(fileobj=io.BytesIO(data_tar), mode="rb") as gz:
        with tarfile.open(fileobj=gz, mode="r") as tar:
            member = tar.extractfile(member_name)
            if member is None:
                raise SystemExit(f"Packaged binary is missing: {member_name}")
            packaged_binary = member.read()
    if packaged_binary != expected_binary:
        raise SystemExit(
            "Packaged RecorderLnx differs from staging binary: "
            f"staging SHA256={sha256_bytes(expected_binary)}, "
            f"package SHA256={sha256_bytes(packaged_binary)}"
        )


def unix_path(*parts):
    return "/".join(part.strip("/") for part in parts if part)


def add_dir(tar, name, mode=0o755):
    info = tarfile.TarInfo(name.rstrip("/") + "/")
    info.type = tarfile.DIRTYPE
    info.mode = mode
    info.uid = 0
    info.gid = 0
    info.uname = "root"
    info.gname = "root"
    info.mtime = 0
    tar.addfile(info)


def add_bytes(tar, name, data, mode=0o644):
    if isinstance(data, str):
        data = data.encode("utf-8")
    info = tarfile.TarInfo(name)
    info.size = len(data)
    info.mode = mode
    info.uid = 0
    info.gid = 0
    info.uname = "root"
    info.gname = "root"
    info.mtime = 0
    tar.addfile(info, io.BytesIO(data))


def add_file(tar, source, name, mode=0o644):
    source = Path(source)
    info = tar.gettarinfo(str(source), name)
    info.mode = mode
    info.uid = 0
    info.gid = 0
    info.uname = "root"
    info.gname = "root"
    info.mtime = 0
    with source.open("rb") as handle:
        tar.addfile(info, handle)


def add_tree(tar, source_dir, target_dir):
    source_dir = Path(source_dir)
    if not source_dir.exists():
        return
    for root, dirs, files in os.walk(source_dir):
        root_path = Path(root)
        rel_root = root_path.relative_to(source_dir)
        if rel_root.as_posix() == ".":
            target_root = target_dir.strip("/")
        else:
            target_root = unix_path(target_dir, rel_root.as_posix())
            add_dir(tar, target_root)
        for file_name in sorted(files):
            source_file = root_path / file_name
            target_file = unix_path(target_root, file_name)
            add_file(tar, source_file, target_file)


def add_symlink(tar, name, target):
    info = tarfile.TarInfo(name)
    info.type = tarfile.SYMTYPE
    info.linkname = target
    info.mode = 0o777
    info.uid = 0
    info.gid = 0
    info.uname = "root"
    info.gname = "root"
    info.mtime = 0
    tar.addfile(info)


def gzip_tar(build_func):
    buffer = io.BytesIO()
    with gzip.GzipFile(fileobj=buffer, mode="wb", mtime=0) as gz:
        with tarfile.open(fileobj=gz, mode="w") as tar:
            build_func(tar)
    return buffer.getvalue()


def ar_member(name, data, mode=0o100644):
    timestamp = int(time.time())
    header = (
        f"{name}/".ljust(16)[:16]
        + f"{timestamp:<12}"
        + f"{0:<6}"
        + f"{0:<6}"
        + f"{mode:o}".ljust(8)[:8]
        + f"{len(data):<10}"
        + "`\n"
    ).encode("ascii")
    padding = b"\n" if len(data) % 2 else b""
    return header + data + padding


def install_check_script():
    return """#!/bin/sh
status=0

check_path() {
  path="$1"
  if [ -e "$path" ]; then
    echo "OK   $path"
  else
    echo "MISS $path"
    status=1
  fi
}

check_writable_dir() {
  path="$1"
  if [ -d "$path" ] && [ -w "$path" ]; then
    echo "OK   writable $path"
  else
    echo "MISS writable $path"
    status=1
  fi
}

check_path /opt/mera/RecorderLnx/RecorderLnx
check_path /opt/mera/RecorderLnx/RecorderHostAgent
check_path /opt/mera/RecorderLnx/LinuxSetupManager
check_path /opt/mera/RecorderLnx/LinuxSetupManagerCli
check_path /opt/mera/RecorderLnx/RecorderHostAgent.ini
check_path /usr/local/sbin/recorder-host-agent-shutdown
check_path /usr/local/sbin/recorderlnx-connect-share
check_path /usr/local/sbin/recorderlnx-share-folder
check_path /usr/local/sbin/recorderlnx-set-hostname
check_path /usr/local/sbin/recorderlnx-configure-wol
check_path /usr/local/sbin/recorderlnx-mount-kip-obmen
check_path /usr/local/sbin/recorderlnx-associate-mera-winpos
check_path /usr/local/sbin/recorderlnx-associate-file
check_path /usr/lib/systemd/user/recorder-host-agent.service
check_path /usr/lib/systemd/system/recorderlnx-network-shares.service
check_path /usr/lib/systemd/system/recorderlnx-network-shares.timer
check_path /etc/xdg/autostart/recorder-host-agent.desktop
check_path /opt/mera/RecorderLnx/lib/libfbclient.so
check_path /opt/mera/RecorderLnx/RecorderLnx.paths.ini
check_path /opt/mera/RecorderLnx/bios/devices/mc201/mc_201a.bio
check_path /opt/mera/RecorderLnx/res/sdb/Scales.ico
check_path /usr/share/applications/recorderlnx.desktop
check_path /usr/share/applications/recorderlnx-linux-setup-manager.desktop
check_path /usr/share/icons/hicolor/256x256/apps/recorderlnx.png
check_path /usr/bin/recorderlnx
check_path /usr/bin/recorderlnx-linux-setup
check_path /var/opt/mera/RecorderLnx/config/app.ini
check_path /var/opt/mera/RecorderLnx/config/projects/default/default.config.json
if { command -v ldconfig >/dev/null 2>&1 && ldconfig -p 2>/dev/null ||
     [ -x /sbin/ldconfig ] && /sbin/ldconfig -p 2>/dev/null; } |
   grep -q 'libfbclient[.]so'; then
  echo "OK   Firebird client library"
else
  echo "MISS Firebird client library (install libfbclient2)"
  status=1
fi
check_writable_dir /var/opt/mera
check_path /var/opt/mera/SQLdb
check_writable_dir /var/opt/mera/RecorderLnx/config
check_writable_dir /var/opt/mera/Calibr
check_writable_dir /var/opt/mera/Resources
check_writable_dir /var/opt/mera/SDB

exit "$status"
"""


def make_control_tar(version, architecture, installed_size_kb):
    control = f"""Package: {PACKAGE_NAME}
Version: {version}
Section: science
Priority: optional
Architecture: {architecture}
Maintainer: Mera
Depends: libc6, libgtk2.0-0, libfbclient2, sudo, cifs-utils, policykit-1, samba, ethtool, util-linux, xdg-utils, shared-mime-info, libcap2, libgnutls30, libnettle8, libseccomp2
Installed-Size: {installed_size_kb}
Description: RecorderLnx measurement recorder
 Cross-platform RecorderLnx measurement recorder.
"""
    postinst = """#!/bin/sh
set -e

LOG=/var/opt/mera/RecorderLnx/install.log

log() {
  echo "$@"
  if [ -n "$LOG" ]; then
    echo "$@" >> "$LOG" 2>/dev/null || true
  fi
}

configure_host_agent_firewall() {
  if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q '^Status: active'; then
    ufw allow 8766/tcp comment 'Mera RecorderHostAgent API' >/dev/null 2>&1 || \
      log "failed to allow TCP 8766 in ufw"
    log "HostAgent firewall rule checked: ufw TCP 8766"
    return
  fi

  if command -v firewall-cmd >/dev/null 2>&1 && \
     firewall-cmd --state >/dev/null 2>&1; then
    firewall-cmd --permanent --add-port=8766/tcp >/dev/null 2>&1 || \
      log "failed to allow TCP 8766 in firewalld"
    firewall-cmd --reload >/dev/null 2>&1 || \
      log "failed to reload firewalld"
    log "HostAgent firewall rule checked: firewalld TCP 8766"
  fi
}

configure_host_agent_shutdown() {
  runtime_user="$1"
  sudoers_file=/etc/sudoers.d/recorder-host-agent
  if [ -z "$runtime_user" ] || [ "$runtime_user" = root ]; then
    log "shutdown helper installed; no desktop user selected for sudoers"
    return 1
  fi
  printf '%s ALL=(root) NOPASSWD: /usr/local/sbin/recorder-host-agent-shutdown\n' \
    "$runtime_user" > "$sudoers_file"
  chmod 0440 "$sudoers_file"
  if command -v visudo >/dev/null 2>&1 && ! visudo -cf "$sudoers_file" >/dev/null 2>&1; then
    rm -f "$sudoers_file"
    log "shutdown sudoers validation failed; shutdown remains disabled"
    return 1
  fi
  sed -i 's/^allow_shutdown=.*/allow_shutdown=1/' \
    /opt/mera/RecorderLnx/RecorderHostAgent.ini
  log "shutdown helper enabled for user: $runtime_user"
  return 0
}

start_host_agent_for_logged_in_users() {
  command -v loginctl >/dev/null 2>&1 || return 0
  command -v runuser >/dev/null 2>&1 || return 0

  loginctl list-users --no-legend 2>/dev/null | while read -r uid user rest; do
    [ -n "$uid" ] || continue
    [ -n "$user" ] || continue
    [ "$uid" -ge 1000 ] 2>/dev/null || continue
    runtime_dir="/run/user/$uid"
    [ -S "$runtime_dir/bus" ] || continue
    if runuser -u "$user" -- env \
      XDG_RUNTIME_DIR="$runtime_dir" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus" \
      systemctl --user restart recorder-host-agent.service >/dev/null 2>&1; then
      log "RecorderHostAgent restarted for logged-in user: $user"
    else
      log "RecorderHostAgent restart deferred until next graphical login: $user"
    fi
  done
}

desktop_dir_from_user_dirs() {
  user_home="$1"
  user_dirs="$user_home/.config/user-dirs.dirs"
  [ -f "$user_dirs" ] || return 1
  desktop_line=$(grep '^XDG_DESKTOP_DIR=' "$user_dirs" 2>/dev/null | tail -n 1 || true)
  [ -n "$desktop_line" ] || return 1
  desktop_value=$(printf '%s\\n' "$desktop_line" | sed 's/^XDG_DESKTOP_DIR=//; s/^"//; s/"$//')
  desktop_value=$(printf '%s\\n' "$desktop_value" | sed "s|\\$HOME|$user_home|g")
  [ -n "$desktop_value" ] || return 1
  printf '%s\\n' "$desktop_value"
  return 0
}

install_desktop_shortcuts() {
  for home in /home/*; do
    [ -d "$home" ] || continue
    user=$(basename "$home")
    candidates="$home/Desktop"
    xdg_desktop=$(desktop_dir_from_user_dirs "$home" || true)
    if [ -n "$xdg_desktop" ] && [ "$xdg_desktop" != "$home/Desktop" ]; then
      candidates="$xdg_desktop
$candidates"
    fi
    for shortcut in RecorderLnx.desktop LinuxSetupManager.desktop; do
      case "$shortcut" in
        RecorderLnx.desktop) src=/usr/share/applications/recorderlnx.desktop ;;
        LinuxSetupManager.desktop) src=/usr/share/applications/recorderlnx-linux-setup-manager.desktop ;;
      esac
      [ -f "$src" ] || continue
      printf '%s\\n' "$candidates" | while IFS= read -r desktop; do
        [ -n "$desktop" ] || continue
        [ -d "$desktop" ] || continue
        cp "$src" "$desktop/$shortcut" || continue
        chmod 755 "$desktop/$shortcut" || true
        chown "$user:$user" "$desktop/$shortcut" 2>/dev/null || true
        log "desktop shortcut created: $desktop/$shortcut"
      done
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
  fbclient_path=$(find /usr/lib /lib \\( -type f -o -type l \\) \\
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
if ! grep -q '^\\[SQLdbConnection\\]$' /var/opt/mera/RecorderLnx/config/app.ini; then
  printf '\n' >> /var/opt/mera/RecorderLnx/config/app.ini
  sed -n '/^\\[SQLdbConnection\\]$/,$p' /usr/share/recorderlnx/config/app.ini \
    >> /var/opt/mera/RecorderLnx/config/app.ini
  log "SQLdbConnection added to app.ini"
fi
if [ ! -f /var/opt/mera/RecorderLnx/config/projects/default/default.config.json ]; then
  cp -a /usr/share/recorderlnx/config/projects/default/. /var/opt/mera/RecorderLnx/config/projects/default/
  log "default project copied"
fi
chmod 755 /opt/mera/RecorderLnx/RecorderLnx
chmod 755 /opt/mera/RecorderLnx/RecorderHostAgent
if command -v systemctl >/dev/null 2>&1; then
  # An older package enabled this as a systemd user unit.  Disable that link
  # to avoid two agents competing for TCP 8766.  XDG Autostart below is the
  # authoritative launcher because it inherits DISPLAY/Wayland on Astra.
  systemctl --global disable recorder-host-agent.service >/dev/null 2>&1 || true
  systemctl daemon-reload
  systemctl enable recorderlnx-network-shares.timer >/dev/null 2>&1
  systemctl restart recorderlnx-network-shares.timer >/dev/null 2>&1
  systemctl start recorderlnx-network-shares.service >/dev/null 2>&1 || \
    log "SMB resources will be retried by systemd after network startup"
  if [ -f /etc/samba/kip-obmen.credentials ]; then
    /usr/local/sbin/recorderlnx-mount-kip-obmen || \
      log "KIP Obmen automount configuration failed"
  else
    log "KIP Obmen automount skipped: credentials file is absent"
  fi
fi
log "RecorderHostAgent registered in XDG Autostart; it starts at graphical login"
configure_host_agent_firewall
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
  if [ "$(printf '%s\n' "$runtime_candidates" | sed '/^$/d' | wc -l)" -eq 1 ]; then
    runtime_user=$(printf '%s\n' "$runtime_candidates" | sed '/^$/d')
  fi
fi
if [ -n "$runtime_user" ] && [ "$runtime_user" != root ] && id "$runtime_user" >/dev/null 2>&1; then
  runtime_group=$(id -gn "$runtime_user")
  chown -R "$runtime_user:$runtime_group" "$config_root" \
    /var/opt/mera/Calibr /var/opt/mera/Resources /var/opt/mera/SDB
  find "$config_root" /var/opt/mera/Calibr /var/opt/mera/Resources \
    /var/opt/mera/SDB -type d -exec chmod 0700 {} +
  find "$config_root" /var/opt/mera/Calibr /var/opt/mera/Resources \
    /var/opt/mera/SDB -type f -exec chmod 0600 {} +
  configure_host_agent_shutdown "$runtime_user" || true
else
  log "runtime user is unknown; writable config permissions were not broadened"
fi
# HostAgent reads allow_shutdown and api_token only at startup. Restart it
# after the final config/sudoers update, never before configure_host_agent_shutdown.
start_host_agent_for_logged_in_users
install_desktop_shortcuts
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi
/usr/bin/recorderlnx-install-check >> "$LOG" 2>&1 || true
log "RecorderLnx postinst finished"
exit 0
"""
    prerm = """#!/bin/sh
set -e

# dpkg replaces executable files without terminating processes that still map
# the old inode.  Stop only instances launched from this package, before files
# are unpacked, so an upgrade cannot leave an old RecorderLnx or HostAgent alive.
if [ "${1:-}" = upgrade ] || [ "${1:-}" = remove ] || [ "${1:-}" = deconfigure ]; then
  if command -v pkill >/dev/null 2>&1; then
    pkill -TERM -f '^/opt/mera/RecorderLnx/RecorderLnx([[:space:]]|$)' 2>/dev/null || true
    pkill -TERM -f '^/opt/mera/RecorderLnx/RecorderHostAgent([[:space:]]|$)' 2>/dev/null || true
    sleep 1
    pkill -KILL -f '^/opt/mera/RecorderLnx/RecorderLnx([[:space:]]|$)' 2>/dev/null || true
    pkill -KILL -f '^/opt/mera/RecorderLnx/RecorderHostAgent([[:space:]]|$)' 2>/dev/null || true
  fi
fi
exit 0
"""
    postrm = """#!/bin/sh
set -e
if [ "${1:-}" = remove ] || [ "${1:-}" = purge ]; then
  rm -f /etc/sudoers.d/recorder-host-agent
  if command -v systemctl >/dev/null 2>&1; then
    systemctl disable --now recorderlnx-ntp-server.service >/dev/null 2>&1 || true
    systemctl --global disable recorder-host-agent.service >/dev/null 2>&1 || true
  fi
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi
exit 0
"""

    def build(tar):
        add_bytes(tar, "control", control)
        add_bytes(tar, "postinst", postinst, 0o755)
        add_bytes(tar, "prerm", prerm, 0o755)
        add_bytes(tar, "postrm", postrm, 0o755)

    return gzip_tar(build)


def make_data_tar(repo_root):
    project_root = repo_root / "Lazarus" / "RecorderLnx"
    linux_lib = project_root / "lib" / "x86_64-linux"
    agent_exe = linux_lib / AGENT_NAME
    linux_setup_exe = project_root / "Tools" / "LinuxSetupManager" / "lib" / "x86_64-linux" / "LinuxSetupManager"
    linux_setup_cli_exe = project_root / "Tools" / "LinuxSetupManager" / "lib" / "x86_64-linux" / "LinuxSetupManagerCli"
    private_chronyd = Path(__file__).resolve().parent / "chronyd-private"
    share_helper = project_root / "Scripts" / "linux" / "recorderlnx-connect-share"
    publish_helper = project_root / "Scripts" / "linux" / "recorderlnx-share-folder"
    hostname_helper = project_root / "Scripts" / "linux" / "recorderlnx-set-hostname"
    wol_helper = project_root / "Scripts" / "linux" / "recorderlnx-configure-wol"
    kip_obmen_helper = project_root / "Scripts" / "linux" / "recorderlnx-mount-kip-obmen"
    mera_winpos_helper = project_root / "Scripts" / "linux" / "recorderlnx-associate-mera-winpos"
    file_association_helper = project_root / "Scripts" / "linux" / "recorderlnx-associate-file"
    app_ini = project_root / "config" / "app.ini"
    default_project = project_root / "config" / "projects" / "default"
    bios_file = project_root / "Device" / "MCbus" / "resources" / "devices" / "mc201" / "mc_201a.bio"
    app_icon = project_root / "resources" / "app" / "RecorderLnx.png"
    paths_ini = """[Paths]
MeraFiles=/var/opt/mera
Config=/var/opt/mera/RecorderLnx/config
Plugins=plugins
Bios=bios
SysCom=syscom
"""
    ntp_server_service = """[Unit]
Description=RecorderLnx private NTP server
After=network-online.target systemd-timesyncd.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/mera/RecorderLnx/chronyd-private -n -x -u root -f /opt/mera/RecorderLnx/chrony-server.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
"""
    desktop = """[Desktop Entry]
Type=Application
Name=RecorderLnx
GenericName=RecorderLnx
Comment=RecorderLnx measurement recorder
Exec=/usr/bin/recorderlnx
Path=/opt/mera/RecorderLnx
Terminal=false
Icon=recorderlnx
Categories=Utility;
Keywords=RecorderLnx;Mera;Recorder;Measurements;
StartupNotify=false
NoDisplay=false
"""
    linux_setup_desktop = """[Desktop Entry]
Type=Application
Name=Настройка Linux
Comment=Настройка имени компьютера, Wake-on-LAN и сетевых каталогов
Exec=/opt/mera/RecorderLnx/LinuxSetupManager
Path=/opt/mera/RecorderLnx
Terminal=false
Icon=preferences-system
Categories=Settings;System;
Keywords=RecorderLnx;Mera;Linux;Hostname;Wake-on-LAN;Samba;
StartupNotify=true
NoDisplay=false
"""
    agent_config = """[agent]
listen=0.0.0.0
port=8766
recorder_path=/usr/bin/recorderlnx
allow_shutdown=0
api_token=
"""
    shutdown_helper = """#!/bin/sh
set -eu

# This root-owned, argument-free helper is the only command granted through
# sudoers. The network-facing agent cannot choose another privileged command.
if command -v systemd-run >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1; then
  exec systemd-run --unit=recorder-host-agent-poweroff --on-active=3s \\
    systemctl poweroff --no-wall
fi
exec /sbin/shutdown -h +1
"""
    agent_service = """[Unit]
Description=Mera RecorderLnx remote start agent
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/mera/RecorderLnx
ExecStart=/opt/mera/RecorderLnx/RecorderHostAgent
SyslogIdentifier=RecorderHostAgent
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
"""
    network_shares_service = """[Unit]
Description=Restore RecorderLnx SMB network shares
Wants=network-online.target
After=network-online.target remote-fs-pre.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/recorderlnx-connect-share restore

[Install]
WantedBy=multi-user.target
"""
    network_shares_timer = """[Unit]
Description=Retry RecorderLnx SMB network shares

[Timer]
OnBootSec=15s
OnUnitActiveSec=60s
AccuracySec=5s
Persistent=true

[Install]
WantedBy=timers.target
"""

    def build(tar):
        for directory in [
            "etc",
            "etc/xdg",
            "etc/xdg/autostart",
            "opt",
            "opt/mera",
            "opt/mera/RecorderLnx",
            "opt/mera/RecorderLnx/lib",
            "opt/mera/RecorderLnx/plugins",
            "opt/mera/RecorderLnx/res",
            "opt/mera/RecorderLnx/bios",
            "opt/mera/RecorderLnx/bios/devices",
            "opt/mera/RecorderLnx/bios/devices/mc201",
            "opt/mera/RecorderLnx/syscom",
            "usr",
            "usr/bin",
            "usr/local",
            "usr/local/sbin",
            "usr/share",
            "usr/share/applications",
            "usr/share/icons",
            "usr/share/icons/hicolor",
            "usr/share/icons/hicolor/256x256",
            "usr/share/icons/hicolor/256x256/apps",
            "usr/share/recorderlnx",
            "usr/share/recorderlnx/config",
            "usr/share/recorderlnx/config/projects",
            "usr/share/recorderlnx/config/projects/default",
            "usr/lib",
            "usr/lib/systemd",
            "usr/lib/systemd/system",
            "usr/lib/systemd/user",
            "var",
            "var/opt",
            "var/opt/mera",
            "var/opt/mera/SQLdb",
            "var/opt/mera/RecorderLnx",
            "var/opt/mera/RecorderLnx/config",
            "var/opt/mera/RecorderLnx/config/projects",
            "var/opt/mera/RecorderLnx/config/projects/default",
            "var/opt/mera/Calibr",
            "var/opt/mera/Resources",
            "var/opt/mera/SDB",
        ]:
            add_dir(tar, directory)
        add_file(tar, linux_lib / APP_NAME, "opt/mera/RecorderLnx/RecorderLnx", 0o755)
        add_file(tar, agent_exe, "opt/mera/RecorderLnx/RecorderHostAgent", 0o755)
        add_file(tar, linux_setup_exe, "opt/mera/RecorderLnx/LinuxSetupManager", 0o755)
        add_file(tar, linux_setup_cli_exe, "opt/mera/RecorderLnx/LinuxSetupManagerCli", 0o755)
        add_file(tar, private_chronyd, "opt/mera/RecorderLnx/chronyd-private", 0o755)
        add_bytes(tar, "lib/systemd/system/recorderlnx-ntp-server.service",
                  ntp_server_service)
        add_bytes(tar, "opt/mera/RecorderLnx/RecorderHostAgent.ini", agent_config)
        add_bytes(tar, "usr/local/sbin/recorder-host-agent-shutdown",
                  shutdown_helper, 0o755)
        add_file(tar, share_helper, "usr/local/sbin/recorderlnx-connect-share", 0o755)
        add_file(tar, publish_helper, "usr/local/sbin/recorderlnx-share-folder", 0o755)
        add_file(tar, hostname_helper, "usr/local/sbin/recorderlnx-set-hostname", 0o755)
        add_file(tar, wol_helper, "usr/local/sbin/recorderlnx-configure-wol", 0o755)
        add_file(tar, kip_obmen_helper, "usr/local/sbin/recorderlnx-mount-kip-obmen", 0o755)
        add_file(tar, mera_winpos_helper, "usr/local/sbin/recorderlnx-associate-mera-winpos", 0o755)
        add_file(tar, file_association_helper, "usr/local/sbin/recorderlnx-associate-file", 0o755)
        add_bytes(tar, "usr/lib/systemd/user/recorder-host-agent.service",
                  agent_service)
        add_bytes(tar, "usr/lib/systemd/system/recorderlnx-network-shares.service",
                  network_shares_service)
        add_bytes(tar, "usr/lib/systemd/system/recorderlnx-network-shares.timer",
                  network_shares_timer)
        agent_autostart = """[Desktop Entry]
Type=Application
Name=RecorderLnx Host Agent
Comment=Remote launcher for RecorderLnx
Exec=/opt/mera/RecorderLnx/RecorderHostAgent
TryExec=/opt/mera/RecorderLnx/RecorderHostAgent
Path=/opt/mera/RecorderLnx
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
"""
        add_bytes(tar, "etc/xdg/autostart/recorder-host-agent.desktop",
                  agent_autostart)
        add_tree(tar, linux_lib / "res", "opt/mera/RecorderLnx/res")
        if bios_file.exists():
            add_file(tar, bios_file, "opt/mera/RecorderLnx/bios/devices/mc201/mc_201a.bio")
        add_bytes(tar, "opt/mera/RecorderLnx/RecorderLnx.paths.ini", paths_ini)
        add_bytes(tar, "usr/share/applications/recorderlnx.desktop", desktop)
        add_bytes(tar, "usr/share/applications/recorderlnx-linux-setup-manager.desktop",
                  linux_setup_desktop)
        add_file(tar, app_icon, "usr/share/icons/hicolor/256x256/apps/recorderlnx.png")
        launcher = """#!/bin/sh
if [ -r /etc/profile.d/recorderlnx-sqldb.sh ]; then
  . /etc/profile.d/recorderlnx-sqldb.sh
fi
export LD_LIBRARY_PATH="/opt/mera/RecorderLnx/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec /opt/mera/RecorderLnx/RecorderLnx "$@"
"""
        add_bytes(tar, "usr/bin/recorderlnx", launcher, 0o755)
        linux_setup_cli_launcher = """#!/bin/sh
exec /opt/mera/RecorderLnx/LinuxSetupManagerCli "$@"
"""
        add_bytes(tar, "usr/bin/recorderlnx-linux-setup", linux_setup_cli_launcher, 0o755)
        add_bytes(tar, "usr/bin/recorderlnx-install-check",
          install_check_script(), 0o755)
        add_file(tar, app_ini, "usr/share/recorderlnx/config/app.ini")
        add_tree(tar, default_project, "usr/share/recorderlnx/config/projects/default")

    return gzip_tar(build)


def write_deb(output_file, control_tar, data_tar):
    debian_binary = b"2.0\n"
    with output_file.open("wb") as handle:
        handle.write(b"!<arch>\n")
        handle.write(ar_member("debian-binary", debian_binary))
        handle.write(ar_member("control.tar.gz", control_tar))
        handle.write(ar_member("data.tar.gz", data_tar))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", default="amd64")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    installer_dir = Path(__file__).resolve().parent
    output_dir = installer_dir / "Output"
    output_dir.mkdir(parents=True, exist_ok=True)

    linux_exe = repo_root / "Lazarus" / "RecorderLnx" / "lib" / "x86_64-linux" / APP_NAME
    agent_exe = repo_root / "Lazarus" / "RecorderLnx" / "lib" / "x86_64-linux" / AGENT_NAME
    linux_setup_exe = (repo_root / "Lazarus" / "RecorderLnx" / "Tools" /
                       "LinuxSetupManager" / "lib" / "x86_64-linux" /
                       "LinuxSetupManager")
    linux_setup_cli_exe = (repo_root / "Lazarus" / "RecorderLnx" / "Tools" /
                           "LinuxSetupManager" / "lib" / "x86_64-linux" /
                           "LinuxSetupManagerCli")
    if not linux_exe.exists():
        raise SystemExit(f"Linux binary not found: {linux_exe}")
    if not agent_exe.exists():
        raise SystemExit(
            f"Linux host agent binary not found: {agent_exe}. "
            "Build RecorderHostAgent.lpi on Linux before packaging."
        )
    if not linux_setup_exe.exists():
        raise SystemExit(
            f"Linux LinuxSetupManager binary not found: {linux_setup_exe}. "
            "Build LinuxSetupManager.lpi on Linux before packaging."
        )
    if not linux_setup_cli_exe.exists():
        raise SystemExit(
            f"Linux LinuxSetupManager CLI binary not found: {linux_setup_cli_exe}. "
            "Build LinuxSetupManagerCli.lpi on Linux before packaging."
        )

    binary, schema_version = validate_linux_binary(repo_root, linux_exe)
    agent_binary = agent_exe.read_bytes()
    if not agent_binary.startswith(b"\x7fELF"):
        raise SystemExit(f"Not a Linux ELF executable: {agent_exe}")
    linux_setup_binary = linux_setup_exe.read_bytes()
    if not linux_setup_binary.startswith(b"\x7fELF"):
        raise SystemExit(f"Not a Linux ELF executable: {linux_setup_exe}")
    linux_setup_cli_binary = linux_setup_cli_exe.read_bytes()
    if not linux_setup_cli_binary.startswith(b"\x7fELF"):
        raise SystemExit(f"Not a Linux ELF executable: {linux_setup_cli_exe}")
    latest_linux_setup_source = newest_tree_source(linux_setup_exe.parents[2])
    if (latest_linux_setup_source is not None and
            linux_setup_exe.stat().st_mtime < latest_linux_setup_source.stat().st_mtime):
        raise SystemExit(
            "LinuxSetupManager is older than its sources. "
            f"Binary: {linux_setup_exe}; newest source: {latest_linux_setup_source}."
        )

    data_tar = make_data_tar(repo_root)
    verify_packaged_binary(
        data_tar, "opt/mera/RecorderLnx/RecorderLnx", binary)
    verify_packaged_binary(
        data_tar, "opt/mera/RecorderLnx/RecorderHostAgent", agent_binary)
    verify_packaged_binary(
        data_tar, "opt/mera/RecorderLnx/LinuxSetupManager", linux_setup_binary)
    verify_packaged_binary(
        data_tar, "opt/mera/RecorderLnx/LinuxSetupManagerCli", linux_setup_cli_binary)
    installed_size_kb = max(1, len(data_tar) // 1024)
    control_tar = make_control_tar(args.version, args.architecture, installed_size_kb)
    output_file = output_dir / f"{PACKAGE_NAME}_{args.version}_{args.architecture}.deb"
    write_deb(output_file, control_tar, data_tar)
    print(
        f"Linux input: {linux_exe} size={len(binary)} "
        f"mtime={time.ctime(linux_exe.stat().st_mtime)} "
        f"schema={schema_version} SHA256={sha256_bytes(binary)}"
    )
    print(
        f"Linux agent input: {agent_exe} size={len(agent_binary)} "
        f"mtime={time.ctime(agent_exe.stat().st_mtime)} "
        f"SHA256={sha256_bytes(agent_binary)}"
    )
    print(
        f"Linux setup manager input: {linux_setup_exe} "
        f"size={len(linux_setup_binary)} "
        f"SHA256={sha256_bytes(linux_setup_binary)}"
    )
    print(f"DEB SHA256={sha256_bytes(output_file.read_bytes())}")
    print(output_file)


if __name__ == "__main__":
    main()
