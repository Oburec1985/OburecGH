# Linux Recorder runtime directory was not writable

## Symptom and evidence

ARM192.168.9.200 reported inability to create
`/srv/recorderlnx/MeraFiles/RecorderLnx/coordinator-client.ini`.
`namei`, `stat` and `getfacl` showed the RecorderLnx directory root:root0755;
its app.ini and config subtree were user-owned. The requested INI was absent.
The former `/var/opt/mera/RecorderLnx/coordinator-client.ini` existed user0600.

## Root cause

DEB postinst migrated/chowned app.ini and config but omitted the containing
runtime directory. Newly introduced sibling INIs and atomic replacements
therefore failed. Deployment also continued configuring the obsolete /var root
after the package switched its default paths file to /srv.

## Fix

- On ARM, assigned only the exact RecorderLnx runtime parent to user:user0700.
- Migrated coordinator-client.ini from the old root only when destination absent;
  preserved its contents and user0600 permissions.
- postinst now migrates this INI and assigns the runtime parent and INI to the
  selected runtime user. install-check now checks runtime parent writability.
- deploy-linux-all.bat now configures/verifies the current packaged default
  `/srv/recorderlnx/MeraFiles/RecorderLnx`, not the obsolete /var data directory.

## Verification

Actual user open-r+b/write of unchanged INI bytes succeeded. namei/stat confirm
user0700 parent/user0600 INI. Python compile and three freshness regressions pass;
generated postinst passes sh-n after removing only Windows pipeline CRLF.
An isolated root-owned0755 fixture executed the exact generated ownership
block: user access failed before, then directory/INI write checks passed after
(`ISOLATED_RUNTIME_PERMISSION_REGRESSION_OK`). Fixture was cleaned.
Recorder startup passed the permission stage and logged completed deferred
hardware preparation; installed application reports0.1.148. The diagnostic
instance was asked to close using WM_DELETE_WINDOW, not force-killed.
It exited normally; log confirms MIC185 detach/unregister and pgrep is empty.

## Prevention

When adding a runtime file beside app.ini or moving the data root, validate
directory create/replace access as the desktop user, not only file ownership.
Deployment and installer must address the same active root. Do not recursively
change ownership of home or unrelated directories.
