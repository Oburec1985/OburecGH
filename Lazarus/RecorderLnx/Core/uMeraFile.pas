unit uMeraFile;

{
  РџР°СЂСЃРёРЅРі MERA-РґРµСЃРєСЂРёРїС‚РѕСЂРѕРІ Рё СЃРёРіРЅР°Р»РѕРІ РґР»СЏ RecorderLnx (РЅРµ SharedUtils).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes;

type
  TMeraValueType = (
    mvtFloat64,
    mvtFloat32,
    mvtInt32,
    mvtUInt32,
    mvtInt16,
    mvtUInt16
  );

  TMeraSignalInfo = class
  public
    Name: string;
    Address: string;
    ModuleName: string;
    DataTypeName: string;
    DataType: TMeraValueType;
    FrequencyHz: Double;
    StartSec: Double;
    UnitsName: string;
    Description: string;
    SourceValueMode: string;
    SensorCalibrationName: string;
    AmplifierCalibrationName: string;
    FileName: string;
    XFileName: string;
    HasXData: Boolean;
    Enabled: Boolean;
    Selected: Boolean;
  end;

procedure ClearMeraSignals(ASignals: TList);
procedure LoadMeraSignalsFromFile(const AFileName: string; ASignals: TList);
function MeraSignalToRecorderTagName(ASignal: TMeraSignalInfo): string;
function MeraValueTypeSize(AValueType: TMeraValueType): Integer;
function MeraValueTypeFromName(const AName: string; out AValueType: TMeraValueType): Boolean;

implementation

uses
  SysUtils, IniFiles, LazFileUtils, LazUTF8, LConvEncoding;

procedure ClearMeraSignals(ASignals: TList);
var
  I: Integer;
begin
  if ASignals = nil then
    Exit;

  for I := 0 to ASignals.Count - 1 do
    TObject(ASignals[I]).Free;
  ASignals.Clear;
end;

function MeraTextToUtf8(const AValue: string): string;
begin
  Result := CP1251ToUTF8(AValue);
end;

function MeraSignalToRecorderTagName(ASignal: TMeraSignalInfo): string;
begin
  Result := '';
  if ASignal = nil then
    Exit;

  Result := Trim(ASignal.Name);
  Result := StringReplace(Result, ' ', '_', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '_', [rfReplaceAll]);
  if Result = '' then
    Result := 'Signal';
end;

function MeraValueTypeSize(AValueType: TMeraValueType): Integer;
begin
  case AValueType of
    mvtFloat64:
      Result := SizeOf(Double);
    mvtFloat32:
      Result := SizeOf(Single);
    mvtInt32,
    mvtUInt32:
      Result := SizeOf(LongInt);
    mvtInt16,
    mvtUInt16:
      Result := SizeOf(SmallInt);
  else
    Result := SizeOf(Double);
  end;
end;

function MeraValueTypeFromName(const AName: string; out AValueType: TMeraValueType): Boolean;
var
  lName: string;
begin
  lName := UpperCase(Trim(AName));
  Result := True;
  if lName = 'R8' then
    AValueType := mvtFloat64
  else if lName = 'R4' then
    AValueType := mvtFloat32
  else if lName = 'I4' then
    AValueType := mvtInt32
  else if lName = 'UI4' then
    AValueType := mvtUInt32
  else if lName = 'I2' then
    AValueType := mvtInt16
  else if lName = 'UI2' then
    AValueType := mvtUInt16
  else
  begin
    AValueType := mvtFloat64;
    Result := False;
  end;
end;

procedure LoadMeraSignalsFromFile(const AFileName: string; ASignals: TList);
var
  lIni: TIniFile;
  lSections: TStringList;
  lSignal: TMeraSignalInfo;
  lFolder: string;
  lIniSection: string;
  lSectionName: string;
  lDataFileName: string;
  lXFileName: string;
  lFreqText: string;
  lStartText: string;
  lDataType: TMeraValueType;
  I: Integer;
begin
  if ASignals = nil then
    raise Exception.Create('MERA signal list is not assigned');
  if not FileExistsUTF8(AFileName) then
    raise Exception.CreateFmt('MERA descriptor not found: %s', [AFileName]);

  ClearMeraSignals(ASignals);
  lFolder := IncludeTrailingPathDelimiter(ExtractFilePath(AFileName));
  lSections := TStringList.Create;
  lIni := TIniFile.Create(UTF8ToSys(AFileName));
  try
    lIni.ReadSections(lSections);
    for I := 0 to lSections.Count - 1 do
    begin
      lIniSection := lSections[I];
      lSectionName := MeraTextToUtf8(lIniSection);
      if SameText(lSectionName, 'MERA') then
        Continue;

      lDataFileName := lFolder + lSectionName + '.dat';
      if not FileExistsUTF8(lDataFileName) then
        Continue;
      lXFileName := lFolder + lSectionName + '.x';

      lSignal := TMeraSignalInfo.Create;
      try
        lSignal.Name := lSectionName;
        lSignal.Address := Trim(MeraTextToUtf8(lIni.ReadString(lIniSection, 'Address', '')));
        lSignal.ModuleName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'ModName', ''));
        lSignal.DataTypeName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'YFormat', 'R8'));
        if not MeraValueTypeFromName(lSignal.DataTypeName, lDataType) then
          Continue;
        lSignal.DataType := lDataType;
        if lSignal.ModuleName = '' then
          lSignal.ModuleName := lSignal.DataTypeName;
        lSignal.UnitsName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'YUnits', ''));
        lSignal.Description := MeraTextToUtf8(lIni.ReadString(lIniSection, 'Comment', ''));
        lSignal.SensorCalibrationName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'tare0', ''));
        lSignal.AmplifierCalibrationName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'tare1', ''));
        lFreqText := lIni.ReadString(lIniSection, 'Freq', '0');
        lFreqText := StringReplace(lFreqText, '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
        if not TryStrToFloat(lFreqText, lSignal.FrequencyHz) then
          lSignal.FrequencyHz := 0;
        lStartText := lIni.ReadString(lIniSection, 'Start', '0');
        lStartText := StringReplace(lStartText, '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
        if not TryStrToFloat(lStartText, lSignal.StartSec) then
          lSignal.StartSec := 0;
        lSignal.FileName := lDataFileName;
        lSignal.XFileName := lXFileName;
        lSignal.HasXData := FileExistsUTF8(lXFileName) and
          (Trim(lIni.ReadString(lIniSection, 'XFormat', '')) <> '');
        lSignal.Enabled := False;
        lSignal.Selected := False;
        ASignals.Add(lSignal);
        lSignal := nil;
      finally
        lSignal.Free;
      end;
    end;
  finally
    lIni.Free;
    lSections.Free;
  end;
end;

end.
