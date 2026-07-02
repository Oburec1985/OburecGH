unit uSharedFileLogger;

{ Заглушка логгера для автономного примера MIC-140. }

{$mode objfpc}{$H+}

interface

type
  TSharedFileLogger = class
  private
    fEnabled: Boolean;
  public
    constructor Create;
    procedure Debug(const AMessage: string);
    procedure Warning(const AMessage: string);
    property Enabled: Boolean read fEnabled write fEnabled;
  end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);

var
  SharedLogger: TSharedFileLogger;

implementation

uses
  SysUtils;

constructor TSharedFileLogger.Create;
begin
  inherited Create;
  fEnabled := True;
end;

procedure TSharedFileLogger.Debug(const AMessage: string);
begin
  if fEnabled then
    WriteLn(AMessage);
end;

procedure TSharedFileLogger.Warning(const AMessage: string);
begin
  if fEnabled then
    WriteLn('WARN: ' + AMessage);
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
end;

initialization
  SharedLogger := TSharedFileLogger.Create;

finalization
  SharedLogger.Free;

end.
