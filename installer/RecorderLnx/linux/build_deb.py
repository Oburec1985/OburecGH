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
PACKAGE_NAME = "recorderlnx"


def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest().upper()


def newest_source(repo_root):
    roots = [
        repo_root / "Lazarus" / "RecorderLnx",
        repo_root / "Lazarus" / "SharedUtils",
    ]
    suffixes = {".pas", ".pp", ".inc", ".lfm", ".lpr"}
    excluded = {"lib", "_buildverify", "backup", "cach", "errors", "tmp", ".git"}
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


def verify_packaged_binary(data_tar, expected_binary):
    with gzip.GzipFile(fileobj=io.BytesIO(data_tar), mode="rb") as gz:
        with tarfile.open(fileobj=gz, mode="r") as tar:
            member = tar.extractfile("opt/mera/RecorderLnx/RecorderLnx")
            if member is None:
                raise SystemExit("Packaged RecorderLnx binary is missing")
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
check_path /opt/mera/RecorderLnx/RecorderLnx.paths.ini
check_path /opt/mera/RecorderLnx/bios/devices/mc201/mc_201a.bio
check_path /opt/mera/RecorderLnx/res/sdb/Scales.ico
check_path /usr/share/applications/recorderlnx.desktop
check_path /usr/bin/recorderlnx
check_path /var/opt/mera/RecorderLnx/config/app.ini
check_path /var/opt/mera/RecorderLnx/config/projects/default/default.config.json
check_writable_dir /var/opt/mera
check_writable_dir /var/opt/mera/SQLdb
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
Depends: libc6, libgtk2.0-0
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
    printf '%s\\n' "$candidates" | while IFS= read -r desktop; do
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
touch "$LOG" 2>/dev/null || true
log "RecorderLnx postinst started"
if [ ! -f /var/opt/mera/RecorderLnx/config/app.ini ]; then
  cp /usr/share/recorderlnx/config/app.ini /var/opt/mera/RecorderLnx/config/app.ini
  log "app.ini copied"
fi
if [ ! -f /var/opt/mera/RecorderLnx/config/projects/default/default.config.json ]; then
  cp -a /usr/share/recorderlnx/config/projects/default/. /var/opt/mera/RecorderLnx/config/projects/default/
  log "default project copied"
fi
chmod 755 /opt/mera/RecorderLnx/RecorderLnx
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
"""
    postrm = """#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi
exit 0
"""

    def build(tar):
        add_bytes(tar, "control", control)
        add_bytes(tar, "postinst", postinst, 0o755)
        add_bytes(tar, "postrm", postrm, 0o755)

    return gzip_tar(build)


def make_data_tar(repo_root):
    project_root = repo_root / "Lazarus" / "RecorderLnx"
    linux_lib = project_root / "lib" / "x86_64-linux"
    app_ini = project_root / "config" / "app.ini"
    default_project = project_root / "config" / "projects" / "default"
    bios_file = project_root / "Device" / "MCbus" / "resources" / "devices" / "mc201" / "mc_201a.bio"
    paths_ini = """[Paths]
MeraFiles=/var/opt/mera
Config=/var/opt/mera/RecorderLnx/config
Plugins=plugins
Bios=bios
SysCom=syscom
"""
    desktop = """[Desktop Entry]
Type=Application
Name=RecorderLnx
GenericName=RecorderLnx
Comment=RecorderLnx measurement recorder
Exec=/usr/bin/recorderlnx
Path=/opt/mera/RecorderLnx
Terminal=false
Categories=Utility;
Keywords=RecorderLnx;Mera;Recorder;Measurements;
StartupNotify=false
NoDisplay=false
"""

    def build(tar):
        for directory in [
            "opt",
            "opt/mera",
            "opt/mera/RecorderLnx",
            "opt/mera/RecorderLnx/plugins",
            "opt/mera/RecorderLnx/res",
            "opt/mera/RecorderLnx/bios",
            "opt/mera/RecorderLnx/bios/devices",
            "opt/mera/RecorderLnx/bios/devices/mc201",
            "opt/mera/RecorderLnx/syscom",
            "usr",
            "usr/bin",
            "usr/share",
            "usr/share/applications",
            "usr/share/recorderlnx",
            "usr/share/recorderlnx/config",
            "usr/share/recorderlnx/config/projects",
            "usr/share/recorderlnx/config/projects/default",
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
        add_tree(tar, linux_lib / "res", "opt/mera/RecorderLnx/res")
        if bios_file.exists():
            add_file(tar, bios_file, "opt/mera/RecorderLnx/bios/devices/mc201/mc_201a.bio")
        add_bytes(tar, "opt/mera/RecorderLnx/RecorderLnx.paths.ini", paths_ini)
        add_bytes(tar, "usr/share/applications/recorderlnx.desktop", desktop)
        launcher = """#!/bin/sh
if [ -r /etc/profile.d/recorderlnx-sqldb.sh ]; then
  . /etc/profile.d/recorderlnx-sqldb.sh
fi
exec /opt/mera/RecorderLnx/RecorderLnx "$@"
"""
        add_bytes(tar, "usr/bin/recorderlnx", launcher, 0o755)
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
    if not linux_exe.exists():
        raise SystemExit(f"Linux binary not found: {linux_exe}")

    binary, schema_version = validate_linux_binary(repo_root, linux_exe)

    data_tar = make_data_tar(repo_root)
    verify_packaged_binary(data_tar, binary)
    installed_size_kb = max(1, len(data_tar) // 1024)
    control_tar = make_control_tar(args.version, args.architecture, installed_size_kb)
    output_file = output_dir / f"{PACKAGE_NAME}_{args.version}_{args.architecture}.deb"
    write_deb(output_file, control_tar, data_tar)
    print(
        f"Linux input: {linux_exe} size={len(binary)} "
        f"mtime={time.ctime(linux_exe.stat().st_mtime)} "
        f"schema={schema_version} SHA256={sha256_bytes(binary)}"
    )
    print(f"DEB SHA256={sha256_bytes(output_file.read_bytes())}")
    print(output_file)


if __name__ == "__main__":
    main()
