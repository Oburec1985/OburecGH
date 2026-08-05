unit uRecorderMic140Utils;

{
  РЈС‚РёР»РёС‚С‹ РїР°СЂСЃРёРЅРіР° MIC-140: Р°РґСЂРµСЃР° РєР°РЅР°Р»РѕРІ, SourceId, СЃСЂР°РІРЅРµРЅРёРµ Р°РґСЂРµСЃРѕРІ.

  РњРѕРґСѓР»СЊ RecorderLnx (РЅРµ SharedUtils): СЃРїРµС†РёС„РёС‡РµРЅ РґР»СЏ MIC-140 / Recorder.
  2026-06: РІС‹РЅРµСЃРµРЅРѕ РёР· Device/MIC140/uRecorderMic140DataSource.pas Рё
  UI/uRecorderSettingsDialog.pas (СѓР±СЂР°РЅРѕ РґСѓР±Р»РёСЂРѕРІР°РЅРёРµ ParseMic140ChannelNumber).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils;

const
  CMic140SourcePrefix = 'MIC-140:';
  MIC140DefaultHost = '192.168.14.155';
  MIC140DefaultPort = 4000;
  MIC140DefaultNodeNumber = 2;

function ParseMic140ChannelNumber(const AAddress: string;
  out AChannelNumber: Integer): Boolean;
function ParseMic140NodeNumber(const AAddress: string;
  out ANodeNumber: Integer): Boolean;
function SameMic140Address(const AAddr1, AAddr2: string): Boolean;
function RecorderMic140SourceId(const AHost: string; APort: Word): string;
function RecorderMic140NodeTagPrefix(ANodeNumber: Integer): string;
function RecorderMic140ChannelTagName(ANodeNumber, AChannelNumber: Integer): string;
function RecorderMic140TemperatureAddressText(ADeviceSerial,
  ATemperatureIndex: Integer): string;
function RecorderMic140TemperatureDisplayName(ADeviceSerial,
  ATemperatureIndex: Integer): string;
function ParseMic140TemperatureChannelIndex(const AAddress: string;
  out ATemperatureIndex: Integer): Boolean;
function RecorderMic140DiagnosticTagName(ANodeNumber: Integer;
  const ASuffix: string): string;
function TryParseRecorderMic140SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;

implementation

uses
  StrUtils;

function ParseMic140ChannelNumber(const AAddress: string;
  out AChannelNumber: Integer): Boolean;
var
  lPos: Integer;
  lStr: string;
begin
  Result := False;
  lStr := Trim(AAddress);
  lPos := RPos('-', lStr);
  if lPos > 0 then
    lStr := Trim(Copy(lStr, lPos + 1, MaxInt));
  Result := TryStrToInt(lStr, AChannelNumber);
end;

function ParseMic140NodeNumber(const AAddress: string;
  out ANodeNumber: Integer): Boolean;
var
  lPos: Integer;
  lStr: string;
begin
  Result := False;
  ANodeNumber := MIC140DefaultNodeNumber;
  lStr := Trim(AAddress);
  lPos := Pos('-', lStr);
  if lPos <= 0 then
    Exit;
  Result := TryStrToInt(Trim(Copy(lStr, 1, lPos - 1)), ANodeNumber);
end;

function RecorderMic140NodeTagPrefix(ANodeNumber: Integer): string;
begin
  if ANodeNumber <= 0 then
    ANodeNumber := MIC140DefaultNodeNumber;
  Result := Format('MIC140-%d', [ANodeNumber]);
end;

function RecorderMic140ChannelTagName(ANodeNumber,
  AChannelNumber: Integer): string;
begin
  Result := Format('%s-%2.2d', [RecorderMic140NodeTagPrefix(ANodeNumber),
    AChannelNumber]);
end;

function RecorderMic140TemperatureAddressText(ADeviceSerial,
  ATemperatureIndex: Integer): string;
begin
  if ATemperatureIndex <= 0 then
    ATemperatureIndex := 1;
  if ADeviceSerial < 0 then
    ADeviceSerial := 0;
  Result := Format('%4.4d-t%2d', [ADeviceSerial, ATemperatureIndex]);
end;

function RecorderMic140TemperatureDisplayName(ADeviceSerial,
  ATemperatureIndex: Integer): string;
begin
  Result := Format('MIC140-{%s}',
    [RecorderMic140TemperatureAddressText(ADeviceSerial, ATemperatureIndex)]);
end;

function ParseMic140TemperatureChannelIndex(const AAddress: string;
  out ATemperatureIndex: Integer): Boolean;
var
  lPos: Integer;
  lTail: string;
begin
  Result := False;
  lPos := Pos('-t', LowerCase(Trim(AAddress)));
  if lPos <= 0 then
    Exit;
  lTail := Trim(Copy(AAddress, lPos + 2, MaxInt));
  Result := TryStrToInt(lTail, ATemperatureIndex) and (ATemperatureIndex > 0);
end;

function RecorderMic140DiagnosticTagName(ANodeNumber: Integer;
  const ASuffix: string): string;
begin
  Result := RecorderMic140NodeTagPrefix(ANodeNumber) + '-' + ASuffix;
end;

function SameMic140Address(const AAddr1, AAddr2: string): Boolean;
var
  lNum1, lNum2: Integer;
  lTemp1, lTemp2: Integer;
begin
  if SameText(AAddr1, AAddr2) then
    Exit(True);
  if ParseMic140TemperatureChannelIndex(AAddr1, lTemp1) and
    ParseMic140TemperatureChannelIndex(AAddr2, lTemp2) then
    Exit(lTemp1 = lTemp2);
  Result := ParseMic140ChannelNumber(AAddr1, lNum1) and
            ParseMic140ChannelNumber(AAddr2, lNum2) and
            (lNum1 = lNum2);
end;

function RecorderMic140SourceId(const AHost: string; APort: Word): string;
begin
  Result := CMic140SourcePrefix + ' ' + Trim(AHost) + ':' + IntToStr(APort);
end;

function TryParseRecorderMic140SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
var
  lHostPort: string;
  lPos: Integer;
  lPort: Integer;
begin
  Result := False;
  AHost := '';
  APort := MIC140DefaultPort;
  if Pos(CMic140SourcePrefix, ASourceId) <> 1 then
    Exit;

  lHostPort := Trim(Copy(ASourceId, Length(CMic140SourcePrefix) + 1, MaxInt));
  if lHostPort = '' then
    lHostPort := MIC140DefaultHost + ':' + IntToStr(MIC140DefaultPort);

  lPos := RPos(':', lHostPort);
  if lPos > 0 then
  begin
    AHost := Trim(Copy(lHostPort, 1, lPos - 1));
    if not TryStrToInt(Trim(Copy(lHostPort, lPos + 1, MaxInt)), lPort) then
      Exit;
    if (lPort <= 0) or (lPort > High(Word)) then
      Exit;
    APort := Word(lPort);
  end
  else
    AHost := lHostPort;

  Result := AHost <> '';
end;

end.
