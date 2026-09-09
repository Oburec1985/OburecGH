# RecorderLnx Linux installer

This directory builds a Debian package directly from Windows.

The builder does not compile the Linux executable. It packages the already
built binary:

`Lazarus/RecorderLnx/lib/x86_64-linux/RecorderLnx`

The build fails if that executable is older than production Pascal/LFM sources,
is not an ELF binary, does not contain the SQL schema markers expected by the
current sources, or differs from the executable embedded into the generated
package. The successful build prints SHA-256 for both input and `.deb`.

## Build From Windows

```powershell
.\build-installer.ps1
```

or from `cmd.exe`, Explorer, Total Commander:

```bat
build-installer.bat
```

Output:

`Output/recorderlnx_0.1.0_amd64.deb`

## Install On Linux

```bash
sudo dpkg -i recorderlnx_0.1.0_amd64.deb
```

Do not run `RecorderLnx` from the package preview/extraction directory such as
`/tmp/qapt-deb-installer/...`. That is only the installer viewer's temporary
copy and it can disappear after reboot. After installation run:

```bash
/opt/mera/RecorderLnx/RecorderLnx
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
`Firebird client library`.

Installed application files:

- `/opt/mera/RecorderLnx`
- `/usr/bin/recorderlnx`
- `/usr/share/applications/recorderlnx.desktop`
- `/usr/bin/recorderlnx-install-check`
- `~/Desktop/RecorderLnx.desktop` or `~/Рабочий стол/RecorderLnx.desktop`
  for existing users when such desktop directories exist

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

If the Linux executable is stale, rebuild it on Linux first. This Windows
builder only creates the installer package.
