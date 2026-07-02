unit uMic140DebugReference;

{
  Эталон сырых кодов АЦП со стенда Windows Recorder.

  Источники (в порядке приоритета при старте):
    1. Встроенные CDefaultStandAin / CDefaultStandTin (fallback)
    2. Data/mic140_adc_reference.txt рядом с exe (перекрывает встроенные)

  Формат файла: «AIN 29 6074» или «TIN 3 18328» (номер канала с 1).
  Допуск приёмки: ±50 кодов (CMic140StandTol*).

  Индексация в API: 0-based (CH29 → AChannelIndex=28, T3 → ATinIndex=2).
  TIn берутся из TMic140AuxTemperatureBlock, не из основного блока AIn.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  CMic140StandAinCount = 48;
  CMic140StandTinCount = 3;
  CMic140StandTolAinLo = 50;
  CMic140StandTolAinHi = 50;
  CMic140StandTolTin = 50;

function Mic140StandAinReference(AChannelIndex: Integer; out ACode: Integer): Boolean;
function Mic140StandTinReference(ATinIndex: Integer; out ACode: Integer): Boolean;
function Mic140StandAinTolerance(AChannelIndex: Integer): Integer;
function Mic140StandAinCodeOk(ACode, AChannelIndex: Integer): Boolean;
function Mic140StandTinCodeOk(ACode, ATinIndex: Integer): Boolean;

implementation

const
  CDefaultStandAin: array[0..CMic140StandAinCount - 1] of Integer = (
    -7169, -7120, -6600, -7230, -7169, -7120, -6600, -7230,
    -7169, -7120, -6600, -7230, -7169, -7120, -6600, -7230,
    -7169, -7120, -6600, -7230, -7169, -7120, -6600, -7230,
    -16343, -15155, -19671, -22939, -18200, -17138, -18610, -17564,
    -17917, -14702, -19368, -22788, -25616, -20981, -24690, -25538,
    -25250, -19538, -23826, -25438, -25790, -19143, -23506, -26066
  );
  CDefaultStandTin: array[0..CMic140StandTinCount - 1] of Integer = (8306, 8496, 18624);

var
  GStandAin: array[0..CMic140StandAinCount - 1] of Integer;
  GStandTin: array[0..CMic140StandTinCount - 1] of Integer;

procedure Mic140LoadReferenceFile;
var
  lLines: TStringList;
  lPath, lKind: string;
  lI, lChan, lCode: Integer;
  lParts: TStringArray;
begin
  for lI := 0 to CMic140StandAinCount - 1 do
    GStandAin[lI] := CDefaultStandAin[lI];
  for lI := 0 to CMic140StandTinCount - 1 do
    GStandTin[lI] := CDefaultStandTin[lI];

  lPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'Data' + DirectorySeparator + 'mic140_adc_reference.txt';
  if not FileExists(lPath) then
    Exit;

  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(lPath);
    for lI := 0 to lLines.Count - 1 do
    begin
      if (Trim(lLines[lI]) = '') or (Trim(lLines[lI])[1] = '#') then
        Continue;
      lParts := Trim(lLines[lI]).Split([' '], TStringSplitOptions.ExcludeEmpty);
      if Length(lParts) < 3 then
        Continue;
      lKind := UpperCase(lParts[0]);
      lChan := StrToIntDef(lParts[1], 0);
      lCode := StrToIntDef(lParts[2], 0);
      if (lKind = 'AIN') and (lChan >= 1) and (lChan <= CMic140StandAinCount) then
        GStandAin[lChan - 1] := lCode
      else if (lKind = 'TIN') and (lChan >= 1) and (lChan <= CMic140StandTinCount) then
        GStandTin[lChan - 1] := lCode;
    end;
  finally
    lLines.Free;
  end;
end;

function Mic140StandAinReference(AChannelIndex: Integer; out ACode: Integer): Boolean;
begin
  Result := (AChannelIndex >= 0) and (AChannelIndex < CMic140StandAinCount);
  if Result then
    ACode := GStandAin[AChannelIndex];
end;

function Mic140StandTinReference(ATinIndex: Integer; out ACode: Integer): Boolean;
begin
  Result := (ATinIndex >= 0) and (ATinIndex < CMic140StandTinCount);
  if Result then
    ACode := GStandTin[ATinIndex];
end;

function Mic140StandAinTolerance(AChannelIndex: Integer): Integer;
begin
  if (AChannelIndex >= 0) and (AChannelIndex < 24) then
    Result := CMic140StandTolAinLo
  else
    Result := CMic140StandTolAinHi;
end;

function Mic140StandAinCodeOk(ACode, AChannelIndex: Integer): Boolean;
var
  lRef: Integer;
begin
  Result := Mic140StandAinReference(AChannelIndex, lRef) and
    (Abs(ACode - lRef) <= Mic140StandAinTolerance(AChannelIndex));
end;

function Mic140StandTinCodeOk(ACode, ATinIndex: Integer): Boolean;
var
  lRef: Integer;
begin
  Result := Mic140StandTinReference(ATinIndex, lRef) and
    (Abs(ACode - lRef) <= CMic140StandTolTin);
end;

initialization
  Mic140LoadReferenceFile;

end.
