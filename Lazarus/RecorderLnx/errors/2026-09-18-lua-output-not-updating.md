# Lua output tag did not update

## Symptom

The script `function lua_main() {LuaTest} = {E1}.Value+{E2}.Value end`
did not update `LuaTest` when E1/E2 were changed in input fields.

## Confirmed facts

- The original tag reference expander only converted `{name}.Value` to
  `getValue("name")`; it left `{LuaTest} =` unchanged, so Lua compilation failed.
- Input fields publish tag values. RecorderLnx sends `PN_UPDATEDATA` after tag
  revision changes. The plugin executes `lua_main()` on that notification.
- The old Recorder LuaCP DLL uses an incompatible MFC/COM object ABI; the new
  plugin runs compatible `.lua` text via Lua 5.3/5.4 shared library.

## Fix and verification

- Convert line-start `{output} = expression` and `{output}.Value = expression`
  to `setValue("output", expression)`. Input references remain `getValue`.
- On leaving a script, offer to create unresolved references as scalar virtual
  tags; `setValue` writes only to virtual tags.
- Forced build of RecorderLnx in `_buildverify` succeeded. LuaCalcPlugin built
  as a separate verification DLL because the running RecorderLnx holds its DLL.
- The running Win64 process had LuaCalcPlugin.dll but no Lua module loaded;
  no matching Win64 Lua library existed in its search path. Original LuaCP
  libraries are Win32 (`PE 014C`). Downloaded LuaBinaries 5.4.8 Win64 and
  verified the official archive SHA-256 before placing `lua54.dll` beside
  RecorderLnx.exe (`PE 8664`).
- A separate Win64 `LuaCalcSmoke` program loaded this DLL and ran the user's
  expression. Initial E1=2, E2=3 produced LuaTest=5; changing E1 to 5 and
  calling the next tick produced LuaTest=8 (`RESULT LuaCalcSmoke passed`).
- Updated EXE and both plugin DLLs were staged to their canonical paths while
  preserving previous files. The restarted RecorderLnx process (PID 28796)
  has loaded `LuaCalcPlugin.dll`, `SampleInfoPlugin.dll` and `lua54.dll`.
  End-to-end value changes remain to be checked in the GUI.
