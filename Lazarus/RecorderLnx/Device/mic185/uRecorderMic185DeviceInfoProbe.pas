unit uRecorderMic185DeviceInfoProbe;

{
  Standalone MIC183/185 serial/version probe for settings UI.

  Does not use TRecorderMic185Device — only a short-lived TRecorderMebiusTcpClient
  with IOCTL GetSoftVersion. Existing acquisition/protocol path is untouched.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils;

function RecorderMic185ProbeDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AAcquiring: Boolean; out AErrorText: string;
  ATimeoutMs: Cardinal = 3000): Boolean;

implementation

uses
  uMic185Constants, uMic185MebiusTcpProtocol, uMic185MebiusTypes,
  uRecorderMic185DataSource, uRecorderMic185Runtime;

function RecorderMic185ProbeDeviceInfoViaTcp(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal; out ASerialNumber: LongWord; out AVersionText: string;
  out AErrorText: string): Boolean;
var
  lClient: TRecorderMebiusTcpClient;
  lError: string;
  lInfo: TMic185HardDeviceInfo;
  lOut: TRecorderByteArray;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  AErrorText := '';

  lClient := TRecorderMebiusTcpClient.Create(AHost, APort, ATimeoutMs);
  try
    RecorderMic185RuntimeNoteProbeTcpOpen;
    if not lClient.TryConnect(lError) then
    begin
      AErrorText := lError;
      RecorderMic185Log(Format('ProbeDeviceInfo %s:%d connect failed: %s',
        [AHost, APort, lError]));
      Exit;
    end;

    if not lClient.TryCallCommand(CMic185IoCtlCmdGetSoftVersion, nil,
      CMic185HardDeviceInfoSize, lOut, lError) then
    begin
      AErrorText := lError;
      RecorderMic185Log(Format('ProbeDeviceInfo %s:%d GetSoftVersion failed: %s',
        [AHost, APort, lError]));
      Exit;
    end;

    if Length(lOut) < CMic185HardDeviceInfoSize then
    begin
      AErrorText := 'GetSoftVersion reply is too short';
      RecorderMic185Log(Format('ProbeDeviceInfo %s:%d short reply (%d bytes)',
        [AHost, APort, Length(lOut)]));
      Exit;
    end;

    FillChar(lInfo, SizeOf(lInfo), 0);
    Move(lOut[0], lInfo, SizeOf(lInfo));
    ASerialNumber := lInfo.SerialNumber;
    if lInfo.SoftVersion <> 0 then
      AVersionText := Mic185FormatSoftVersion(lInfo.SoftVersion);
    RecorderMic185RuntimeUpdateInfo(AHost, APort, ASerialNumber, lInfo.SoftVersion);
    Result := ASerialNumber <> 0;
    if Result then
      RecorderMic185Log(Format('ProbeDeviceInfo %s:%d sn=%d ver=%s',
        [AHost, APort, ASerialNumber, AVersionText]))
    else
      AErrorText := 'Device returned zero serial number';
  finally
    lClient.Free;
  end;
end;

function RecorderMic185ProbeDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AAcquiring: Boolean; out AErrorText: string;
  ATimeoutMs: Cardinal): Boolean;
var
  lHost: string;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  AAcquiring := False;
  AErrorText := '';
  lHost := Trim(AHost);
  if lHost = '' then
  begin
    AErrorText := 'Адрес устройства не задан';
    Exit;
  end;

  if RecorderMic185TryGetLiveDeviceInfo(lHost, APort, ASerialNumber,
    AVersionText, AAcquiring) then
    Exit(True);

  if RecorderMic185RuntimeIsBusy(lHost, APort) then
  begin
    AAcquiring := True;
    if RecorderMic185RuntimeTryGetInfo(lHost, APort, ASerialNumber, AVersionText) and
      (ASerialNumber <> 0) then
      Exit(True);
    AErrorText := 'Порт занят активным опросом, идентификация недоступна';
    RecorderMic185Log(Format('ProbeDeviceInfo %s:%d busy without cached info',
      [lHost, APort]));
    Exit;
  end;

  Result := RecorderMic185ProbeDeviceInfoViaTcp(lHost, APort, ATimeoutMs,
    ASerialNumber, AVersionText, AErrorText);
  if Result then
    AAcquiring := False;
end;

end.
