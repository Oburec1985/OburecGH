# rcPanel: Linux desktop shortcut was untrusted and did not launch

## Symptom

The rcPanel shortcut showed a red forbidden emblem in Astra/FLY and did not
launch, while the RecorderLnx shortcut installed by DEB worked.

## Confirmed difference

The RecorderLnx DEB post-install script copies its system desktop entry to each
user's XDG desktop, assigns the user as owner and sets mode 0755. The rcPanel
shell installer only created `/usr/share/applications/rcpanel.desktop` with mode
0644. A manually copied desktop file therefore remained untrusted.

Both application images are valid 256x256 RGBA PNG files. The image format was
not the cause.

## Fix

The rcPanel installer now mirrors the DEB behavior: it resolves
`XDG_DESKTOP_DIR`, copies `rcPanel.desktop`, applies mode 0755 and user ownership.
The user copy uses the absolute `/usr/share/pixmaps/rcpanel.png` fallback for old
FLY shells; the system entry continues to use the theme name `rcpanel`.

## Verification

The component was installed in the Atra VM. The resulting shortcut was
`user:user`, mode 0755, and passed desktop validation. Launching that exact file
with `gio launch` created the expected RecorderCoordinator process as the
desktop user.

