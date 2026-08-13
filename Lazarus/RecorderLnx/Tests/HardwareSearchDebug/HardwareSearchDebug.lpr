program HardwareSearchDebug;

{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

uses
  Interfaces, Classes, SysUtils, uRecorderNetworkBinding,
  uRecorderMic140DataSource, uRecorderMic140Utils;

function SwitchValue(const AName, ADefault: string): string;
var
  I: Integer;
  lPrefix: string;
begin
  Result := ADefault;
  lPrefix := AName + '=';
  for I := 1 to ParamCount do
    if SameText(Copy(ParamStr(I), 1, Length(lPrefix)), lPrefix) then
      Exit(Copy(ParamStr(I), Length(lPrefix) + 1, MaxInt));
end;

function HasSwitch(const AName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), AName) then Exit(True);
end;

procedure Run;
var
  lFound: TStringList;
  lArp: TStringList;
  lOpen: TStringList;
  lBind: string;
  lHost: string;
  lVersion: string;
  lTimeout: Cardinal;
  lSerial: Integer;
  lDevSubRev: Integer;
  I: Integer;
begin
  RecorderSetNetworkDebugLogFile(ExtractFilePath(ParamStr(0)) +
    'hardware-search-debug.log');
  lBind := SwitchValue('--bind', '');
  lTimeout := StrToIntDef(SwitchValue('--timeout-ms', '5200'), 5200);
  SetRecorderNetworkBindAddress(lBind);
  lHost := SwitchValue('--tcp-host', '');
  if lHost <> '' then
  begin
    Writeln(Format('tcp_probe host=%s port=4000 open=%s',
      [lHost, BoolToStr(RecorderTcpPortOpen(lHost, 4000, lTimeout), True)]));
    Exit;
  end;
  lFound := TStringList.Create;
  lArp := TStringList.Create;
  lOpen := TStringList.Create;
  try
    Writeln(Format('hardware-search-debug bind="%s" effective="%s" timeout=%d',
      [lBind, RecorderNetworkBindAddress, lTimeout]));
    RecorderDiscoverMeraBroadcast(lFound, lTimeout);
    Writeln(Format('broadcast_found=%d', [lFound.Count]));
    for I := 0 to lFound.Count - 1 do
      Writeln(lFound[I]);
    RecorderEnumerateArpIPv4(lArp);
    Writeln(Format('arp_candidates=%d', [lArp.Count]));
    for I := 0 to lArp.Count - 1 do
      Writeln('arp=' + lArp[I]);
    if HasSwitch('--tcp-scan') then
    begin
      RecorderFindOpenTcpHosts(lArp, lOpen, 4000, 90);
      Writeln(Format('tcp4000_open=%d', [lOpen.Count]));
      for I := 0 to lOpen.Count - 1 do
        Writeln('tcp4000=' + lOpen[I]);
      if HasSwitch('--mic140-info') then
      begin
        Writeln('mic140_info_begin');
        for I := 0 to lOpen.Count - 1 do
        begin
          lHost := lOpen[I];
          if RecorderMic140QueryDeviceInfoWithTimeout(lHost, MIC140DefaultPort,
            lSerial, lVersion, lDevSubRev, 1000) then
            Writeln(Format('mic140=%s sn=%d version=%s subrev=%d',
              [lHost, lSerial, lVersion, lDevSubRev]))
          else
            Writeln('not_mic140=' + lHost);
        end;
        Writeln('mic140_info_end');
      end;
    end;
  finally
    lOpen.Free;
    lArp.Free;
    lFound.Free;
  end;
end;

begin
  Run;
end.
