# Lua calculation plugin

`Plugins/LuaCalcPlugin/LuaCalcPlugin.lpi` builds a DLL or SO using the same flat
plugin ABI as `SampleInfoPlugin`. The project group contains RecorderLnx, the
oscillogram plugin and LuaCalcPlugin.

Double-click the **LuaCalcPlugin** row on the settings plugin page. Each subprogram is
stored as `<project>/LuaCalc/<name>.lua`. The editor lists scripts on the left
and project tags on the right. Double click inserts `{Tag name}.Value` at the
caret. The engine translates this form to `getValue("Tag name")` before Lua
compilation. Ordinary Lua table literals remain untouched. Existing LuaCP scripts with
`function lua_main()` and `getValue` / `setValue` can be loaded as text.
`{Output} = expression` and `{Output}.Value = expression` write to a virtual
tag. When switching scripts or closing the editor, missing referenced tags
are offered for creation as scalar virtual tags.

Double-click the LuaCalcPlugin row on the plugin settings page to open the
editor. The oscillogram plugin is displayed as **Осциллограмма** while its
binary filename remains stable for existing configurations.

The plugin runs `lua_main()` once when a project is loaded or the editor closes,
then on each `PN_UPDATEDATA`. `getValue(name)` reads the latest value of an
existing tag. `setValue(name, value)` writes to an existing **virtual** tag;
create it in RecorderLnx first. Errors disable the affected script and are
written to `<project>/LuaCalc/errors.log`. Other scripts continue running.

Lua 5.3 or 5.4 of the application's CPU architecture must be installed as a
shared library (`lua53.dll` / `lua54.dll` on Windows; `liblua5.3.so.0` /
`liblua5.4.so.0` on Linux). The local Windows build now has LuaBinaries 5.4.8
x64 `lua54.dll` beside RecorderLnx.exe. The official archive is
`lua-5.4.8_Win64_dllw6_lib.zip`, SHA-256
`45506b8fcb83fa3aec17e343a56d415ea22d02319dc38350a4743cd5be3573a1`.
Its runtime PE machine is `8664`. A separate engine smoke run loaded it and
confirmed that changing E1 changes the calculated output (5 to 8). The
already-running RecorderLnx process must be restarted to load the new plugin
code. Windows and Linux installer packaging is a planned next stage.
The old LuaCP binary is Win32 MFC/COM code and cannot be used through the
RecorderLnx flat ABI. Text `.lua` scripts are the supported migration path.

The host API appends size-checked callbacks for enumerating tags, reading their
latest values, writing virtual tags and obtaining the active project directory.
Only POD records and UTF-8 C strings cross the DLL boundary.
