unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

const
  CMic140StreamLogOnly = False;

function Mic140StreamLogAllowed(const AMessage: string): Boolean;
procedure RecorderDebugLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);

implementation

uses
  SysUtils, uSharedFileLogger;

function Mic140StreamLogAllowed(const AMessage: string): Boolean;
begin
  Result := True;
end;

procedure RecorderDebugLog(const AMessage: string);
begin
  SharedLogger.Debug(AMessage);
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  uSharedFileLogger.RegisterThreadName(AThreadID, AName);
end;

end.
