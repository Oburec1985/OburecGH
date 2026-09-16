# RecorderLnx Linux installer

This directory builds a Debian package from Windows. Before packaging, the
builder connects to the first available Linux computer from
`..\deploy-linux-hosts.local.txt`, compiles both Linux programs in the shared
repository, and then packages:

`Lazarus/RecorderLnx/lib/x86_64-linux/RecorderLnx`

and the host-control agent built on Linux:

`Lazarus/RecorderLnx/lib/x86_64-linux/RecorderHostAgent`

The build fails if that executable is older than production Pascal/LFM sources,
is not an ELF binary, does not contain the SQL schema markers expected by the
current sources, or differs from the executable embedded into the generated
package. The successful build prints SHA-256 for both input and `.deb`.

## Build From Windows

```powershell
.\build-installer.ps1
```

The host list format is `user@host|password`. By default the shared repository
must be mounted on Linux as `/mnt/win_share/OburecGH`. Override it when needed:

```powershell
.\build-installer.ps1 -LinuxRepoRoot /another/mount/OburecGH
```

For an intentional package-only run with already verified ELF files:

```powershell
.\build-installer.ps1 -SkipLinuxBuild
```

or from `cmd.exe`, Explorer, Total Commander:

```bat
build-installer.bat
```

Output:

`Output/recorderlnx_0.1.9_amd64.deb`

## Install On Linux

```bash
sudo dpkg -i recorderlnx_0.1.9_amd64.deb
```

Do not run `RecorderLnx` from the package preview/extraction directory such as
`/tmp/qapt-deb-installer/...`. That is only the installer viewer's temporary
copy and it can disappear after reboot. After installation run:

```bash
/usr/bin/recorderlnx
```

or use the created desktop/menu shortcut.

If the graphical installer reports an installation error, check:

```bash
cat /var/opt/mera/RecorderLnx/install.log
recorderlnx-install-check
```

The package installs the Firebird **client** runtime (`libfbclient2`) as a
dependency. A local Firebird server is not required when `sql-db.ini` points to
a database on another computer. The client runtime is still required by SQL
trend components. `recorderlnx-install-check` reports it separately as
`Firebird client library`. The launcher exposes the modern
`libfbclient.so.2` under the unversioned name expected by FPC 3.2.2; therefore
start the installed application through `/usr/bin/recorderlnx` or its desktop
shortcut.

Installed application files:

- `/opt/mera/RecorderLnx`
- `/opt/mera/RecorderLnx/RecorderHostAgent`
- `/opt/mera/RecorderLnx/RecorderHostAgent.ini`
- `/usr/lib/systemd/user/recorder-host-agent.service`
- `/etc/xdg/autostart/recorder-host-agent.desktop`
- `/usr/bin/recorderlnx`
- `/usr/share/applications/recorderlnx.desktop`
- `/usr/bin/recorderlnx-install-check`
- `~/Desktop/RecorderLnx.desktop` or `~/Рабочий стол/RecorderLnx.desktop`
  for existing users when such desktop directories exist

`RecorderHostAgent` is registered in system-wide XDG Autostart and starts at
graphical login for every desktop user. This method is used on Astra so the
agent inherits the DISPLAY/Wayland environment needed to launch RecorderLnx.
It intentionally does not run as a root system service. After installation
into an already active session, log out and back in, or start it once as that
user:

```bash
/opt/mera/RecorderLnx/RecorderHostAgent
```

For remote control the installer allows inbound TCP `8766` when an active
`ufw` or `firewalld` is detected. Verify access from the rcPanel computer with:

```bash
curl http://RECORDER_PC_IP:8766/api/v1/status
```

Writable data/configuration directories:

- `/var/opt/mera/RecorderLnx/config`
- `/var/opt/mera/Calibr`
- `/var/opt/mera/Resources`
- `/var/opt/mera/SDB`

This is the Linux equivalent of the Windows `Mera Files` directory. The package
also installs the default configuration template under
`/usr/share/recorderlnx/config`; `postinst` copies it to `/var/opt/mera` only
when the user configuration does not already exist.

Packaged resources match the Windows installer:

- executable: `/opt/mera/RecorderLnx/RecorderLnx`
- SDB image resources: `/opt/mera/RecorderLnx/res`
- MC-201 BIOS: `/opt/mera/RecorderLnx/bios/devices/mc201/mc_201a.bio`
- runtime paths file: `/opt/mera/RecorderLnx/RecorderLnx.paths.ini`
- writable `Mera Files` data tree: `/var/opt/mera`

The installer creates the writable data tree with user-writeable permissions so
RecorderLnx can save `app.ini`, project files, logs, SDB data and calibrations
without running as root.

The menu entry uses `Categories=Utility;`, which should place it into the
desktop environment's utility/other application group and make it visible in
application search/favorites.

## Notes

If one build computer is unavailable, the builder tries the next active entry
from the host list. Packaging starts only after both forced Linux builds finish
successfully.

## Linux setup manager

The package installs the expandable `/opt/mera/RecorderLnx/LinuxSetupManager`
and a desktop/menu shortcut named `Настройка Linux`. Its sections configure the
computer name, Wake-on-LAN, publication of a local directory and connection of
SMB resources. Each section includes an explanation and equivalent console
commands. Narrow root-owned helpers live under `/usr/local/sbin`; dependencies
include Samba, `cifs-utils`, PolicyKit and `ethtool`.

The settings button beside `Каталог замеров` uses
`/usr/local/sbin/recorderlnx-share-folder` and publishes the selected directory
as the read-only `MeraFiles` Samba share. The package installs this helper and
the Samba server dependency.
# Обязательная сборка перед упаковкой

`build-installer.ps1` упаковывает уже собранные Linux ELF и намеренно не
запускает Lazarus. Перед выпуском критического исправления выполните в Atra VM
`Lazarus/Tools/build_recorderlnx_linux.sh`: скрипт принудительно собирает
RecorderLnx, RecorderHostAgent, LinuxSetupManager и LinuxSetupManagerCli и
пишет результат в `Lazarus/RecorderLnx/linux_build_report.txt`.
