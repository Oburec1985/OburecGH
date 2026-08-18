# 2026-08-18 - Linux deb install launches from tmp and config dir is missing

## Symptom

On Debian-based Orel 1.8, after installing/opening the package the file manager
shows `tmp/qapt-deb-installer/opt/mera/RecorderLnx`, and RecorderLnx reports:

`Unable to create file "/var/opt/mera/RecorderLnx/config/app.ini": No such file or directory.`

The user also needs a desktop shortcut and wants required directories created
programmatically like `ForceDirectories` on Windows.

## Confirmed Facts

- The path in the screenshot is a Qapt package preview/extraction directory,
  not the final install path `/opt/mera/RecorderLnx`.
- The package asks for a password, so the installer can run root-owned package
  stages, including `postinst`.
- The `.deb` contains `/opt/mera/RecorderLnx/RecorderLnx`,
  `/usr/share/applications/recorderlnx.desktop`, `/usr/bin/recorderlnx`, and
  the `/var/opt/mera/...` data directories.

## Actions

- Added `RecorderEnsureMeraDirectories` to the application and call it before
  app config/run-control writes. It creates:
  `/var/opt/mera/RecorderLnx/config/projects/default`,
  `/var/opt/mera/Calibr`, `/var/opt/mera/Resources`, `/var/opt/mera/SDB`
  for the configured Mera Files root.
- `TRecorderRunControlSettings.SaveToFile` now creates the parent directory
  before opening `TIniFile`.
- Updated the `.deb` `postinst` to create the same `/var/opt/mera` tree,
  copy `app.ini` and default project on first install, make `/var/opt/mera`
  user-writable, and copy a desktop shortcut for existing users when
  `~/Desktop` or `~/Рабочий стол` exists.
- Updated Linux installer README: do not run the temporary
  `/tmp/qapt-deb-installer/...` binary; run `/opt/mera/RecorderLnx/RecorderLnx`
  or the shortcut after installation.

## 2026-08-18 Follow-up

User reported that the graphical installer still says an installation error
occurred, the desktop shortcut is not created, and RecorderLnx must also appear
in the "Other/Прочее" application menu so it can be found with the star/search
button.

Actions:

- Added `/var/opt/mera/RecorderLnx/install.log` logging from `postinst`.
- Made shortcut creation non-fatal and based on `~/.config/user-dirs.dirs`
  (`XDG_DESKTOP_DIR`) plus `~/Desktop` fallback, instead of relying on one
  hard-coded localized directory.
- Added `/usr/bin/recorderlnx-install-check` to diagnose missing files and
  writable directories after installation.
- Changed the desktop entry to `Categories=Utility;` and added search keywords
  so the app should appear in the utility/other menu group and launcher search.

## Verification

- Windows `RecorderLnx.lpi` rebuild completed with `WIN_BUILD_EXIT=0`.
- `python -m py_compile installer/RecorderLnx/linux/build_deb.py` completed.
- `installer/RecorderLnx/linux/build-installer.ps1` rebuilt
  `Output/recorderlnx_0.1.0_amd64.deb`.
- The rebuilt `.deb` was inspected: `postinst` contains the directory creation,
  permission fix and shortcut creation; data archive contains the expected
  application, desktop entry and data directories.
- Follow-up verification: `.deb` contains `usr/bin/recorderlnx-install-check`;
  `postinst` contains logging, `desktop_dir_from_user_dirs`, and a non-fatal
  call to `recorderlnx-install-check`; `.desktop` contains `Categories=Utility;`
  and search keywords.

## Remaining Risk

The Windows `.deb` packer does not rebuild the Linux executable. Pascal
`ForceDirectories` changes are compiled into the Windows binary and will enter
the Linux package after the next Linux build of
`lib/x86_64-linux/RecorderLnx`. The package-level `postinst` fix is already in
the rebuilt `.deb` and should address the reported install-time config
directory issue.

## 2026-08-18 Follow-up: dpkg unpack failed before postinst

User tested the package on the project VM. The graphical installer reported a
generic `dpkg` installation error after "Unpacking recorderlnx"; no
`/var/opt/mera/RecorderLnx/install.log` existed.

Confirmed facts:

- `dpkg -s recorderlnx` reported `Status: install ok not-installed`.
- `/var/log/dpkg.log` showed `half-installed` immediately followed by
  `not-installed`, before package configuration.
- Re-running `sudo dpkg -i /home/user/recorderlnx_0.1.0_amd64.deb` on the VM
  first failed with:
  `ошибка создания каталога «opt/mera/RecorderLnx/res/sdb»: Нет такого файла или каталога`.
- After adding `opt/mera/RecorderLnx/res/`, the next unpack reached the next
  missing parent:
  `usr/share/recorderlnx/config/projects/default/default.config.json.dpkg-new:
  Нет такого файла или каталога`.

Root cause:

- `build_deb.py` created nested directories with `add_tree`, but the data
  archive did not include every parent directory before nested files/dirs. The
  Orel/Astra `dpkg` unpacker did not synthesize those parents.

Actions:

- Added explicit data archive directories:
  `opt/mera/RecorderLnx/res`,
  `usr/share/recorderlnx/config/projects`, and
  `usr/share/recorderlnx/config/projects/default`.
- Removed duplicate desktop shortcut copy when `XDG_DESKTOP_DIR` equals
  `$home/Desktop`.

Verification:

- `python -m py_compile installer/RecorderLnx/linux/build_deb.py` completed.
- `installer/RecorderLnx/linux/build-installer.bat` rebuilt
  `Output/recorderlnx_0.1.0_amd64.deb`.
- `tar -tzf data.tar.gz` now lists all required parent dirs before files.
- Copied the rebuilt package to `user@192.168.112.128` and ran
  `sudo dpkg -i /home/user/recorderlnx_0.1.0_amd64.deb`; result:
  `DPKG_EXIT=0`.
- `recorderlnx-install-check` on the VM returned `CHECK_EXIT=0` and confirmed
  executable, paths file, BIOS, SDB icons, desktop entry, `/usr/bin` launcher,
  app config/default project, and writable `/var/opt/mera` directories.
