program LuaCalcSmoke;

{$mode objfpc}{$H+}

uses SysUtils, uLuaCalcEngine;

var
  lEngine: TLuaCalcEngine;
  lCallbacks: TLuaCalcCallbacks;
  lE1, lE2, lOutput: Double;
  lLogText: UTF8String;

procedure WriteLog(AContext: Pointer; const AMessage: UTF8String); cdecl;
begin
  lLogText := AMessage;
end;

function ReadTag(AContext: Pointer; const AName: UTF8String;
  out AValue: Double): Boolean; cdecl;
begin
  Result := True;
  if AName = 'E1' then AValue := lE1
  else if AName = 'E2' then AValue := lE2
  else Result := False;
end;

function WriteTag(AContext: Pointer; const AName: UTF8String;
  AValue, ATime: Double; AStatus: LongInt): Boolean; cdecl;
begin
  Result := AName = 'LuaTest';
  if Result then lOutput := AValue;
end;

begin
  lE1 := 2;
  lE2 := 3;
  lEngine := TLuaCalcEngine.Create;
  try
    lCallbacks := Default(TLuaCalcCallbacks);
    lCallbacks.OnGetValue := @ReadTag;
    lCallbacks.OnSetValue := @WriteTag;
    lCallbacks.OnLogMessage := @WriteLog;
    lEngine.SetCallbacks(lCallbacks);
    if not lEngine.Execute('function lua_main()' + #10 +
      '  {LuaTest} = {E1}.Value+{E2}.Value' + #10 +
      '  logMessage("calculated")' + #10 + 'end') then
      raise Exception.Create(lEngine.LastError);
    if lOutput <> 5 then raise Exception.Create('initial output mismatch');
    if lLogText <> 'calculated' then
      raise Exception.Create('log message mismatch');
    lE1 := 5;
    if not lEngine.RunMain then raise Exception.Create(lEngine.LastError);
    if lOutput <> 8 then raise Exception.Create('updated output mismatch');
    WriteLn('RESULT LuaCalcSmoke passed');
  finally
    lEngine.Free;
  end;
end.
