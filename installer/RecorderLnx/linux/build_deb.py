#!/usr/bin/env python3
import argparse
import gzip
import io
import os
import shutil
import tarfile
import time
from pathlib import Path


APP_NAME = "RecorderLnx"
PACKAGE_NAME = "recorderlnx"


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
chmod -R a+rwX /var/opt/mera
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
Exec=/opt/mera/RecorderLnx/RecorderLnx
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
        add_symlink(tar, "usr/bin/recorderlnx", "/opt/mera/RecorderLnx/RecorderLnx")
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

    data_tar = make_data_tar(repo_root)
    installed_size_kb = max(1, len(data_tar) // 1024)
    control_tar = make_control_tar(args.version, args.architecture, installed_size_kb)
    output_file = output_dir / f"{PACKAGE_NAME}_{args.version}_{args.architecture}.deb"
    write_deb(output_file, control_tar, data_tar)
    print(output_file)


if __name__ == "__main__":
    main()
