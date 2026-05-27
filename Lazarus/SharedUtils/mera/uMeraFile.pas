unit uMeraFile;

{$mode objfpc}{$H+}

interface

uses
  Classes;

type
  TMeraSignalInfo = class
  public
    Name: string;
    Address: string;
    ModuleName: string;
    FrequencyHz: Double;
    UnitsName: string;
    FileName: string;
    Enabled: Boolean;
    Selected: Boolean;
  end;

procedure ClearMeraSignals(ASignals: TList);
procedure LoadMeraSignalsFromFile(const AFileName: string; ASignals: TList);

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

procedure LoadMeraSignalsFromFile(const AFileName: string; ASignals: TList);
var
  lIni: TIniFile;
  lSections: TStringList;
  lSignal: TMeraSignalInfo;
  lFolder: string;
  lIniSection: string;
  lSectionName: string;
  lDataFileName: string;
  lFreqText: string;
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

      lSignal := TMeraSignalInfo.Create;
      try
        lSignal.Name := lSectionName;
        lSignal.Address := Trim(MeraTextToUtf8(lIni.ReadString(lIniSection, 'Address', '')));
        lSignal.ModuleName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'ModName', ''));
        if lSignal.ModuleName = '' then
          lSignal.ModuleName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'YFormat', ''));
        lSignal.UnitsName := MeraTextToUtf8(lIni.ReadString(lIniSection, 'YUnits', ''));
        lFreqText := lIni.ReadString(lIniSection, 'Freq', '0');
        lFreqText := StringReplace(lFreqText, '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
        if not TryStrToFloat(lFreqText, lSignal.FrequencyHz) then
          lSignal.FrequencyHz := 0;
        lSignal.FileName := lDataFileName;
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
