# Startup: unbound plugin component

User observed ACCESS VIOLATION reading address $30 in
uFormEditorController.pas:1421 while constructing the mnemonic page.

Confirmed cause: a plugin placeholder legitimately has Factory=nil, while its
generic visual host is registered. The visual-control branch dereferenced
Factory.TypeName unconditionally. No evidence implicates oscillator rendering.

Reproduction: PluginEditorStateSmoke adds TRecorderPluginVisualComponent with
PluginTypeId=missing.oscillogram and no factory, then switches runtime/edit mode.
Before fix: exit 1, Access violation. After fix: exit 0, existing opaque
delete/undo/copy/paste tests and placeholder scenario pass.

Fix: use factory display name only when available, otherwise retain plugin type
identity in the hint. No opaque state or binding is discarded. Version 0.1.178.

Residual: this does not establish why the user's plugin was unavailable; actual
startup with the user's configuration has not been verified.
