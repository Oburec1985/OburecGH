unit uMic185CodeVerify;

{
  Сверка кодов АЦП со стендом Lazarus и эталоном Recorder (defaults.md).
  Канал N в таблице = индекс N-1 (MemTag MIC183_185-{3-N}).
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRecorderAcquisitionTypes;

function Mic185RecorderRefCode(AChannelIndex: Integer): Integer;
function Mic185HasRecorderRefCode(AChannelIndex: Integer): Boolean;
function Mic185CodeTolerance: Integer;
function Mic185ChannelCodeMatch(AChannelIndex: Integer; ACode: Double;
  out ARef, ADelta: Integer): Boolean;
function Mic185VerifyBlockCodes(var ABlock: TRecorderAcquisitionBlock;
  ASampleIndex: Integer; out AReport: string): Boolean;

implementation

const
  CMic185RefChannelCount = 50;
  CMic185CodeTolerance = 3;

function Mic185RecorderRefCode(AChannelIndex: Integer): Integer;
begin
  { Эталон Recorder: defaults.md, каналы 3-1 … 3-50 }
  case AChannelIndex of
    0:  Result := 32767;
    1:  Result := -32768;
    2:  Result := 32767;
    3:  Result := -32768;
    4:  Result := -32768;
    5:  Result := -10679;
    6:  Result := -32768;
    7:  Result := -21301;
    8:  Result := -32768;
    9:  Result := -32768;
    10: Result := -32768;
    11: Result := -32768;
    12: Result := -32768;
    13: Result := -9193;
    14: Result := -32768;
    15: Result := -23655;
    16: Result := -32768;
    17: Result := -32768;
    18: Result := -32768;
    19: Result := -32768;
    20: Result := -32768;
    21: Result := -8134;
    22: Result := -32768;
    23: Result := -6471;
    24: Result := -32768;
    25: Result := -32768;
    26: Result := -32768;
    27: Result := -32768;
    28: Result := -32768;
    29: Result := -6311;
    30: Result := -32768;
    31: Result := 3166;
    32: Result := -32768;
    33: Result := -32768;
    34: Result := -32768;
    35: Result := -32768;
    36: Result := -32768;
    37: Result := -5592;
    38: Result := -32768;
    39: Result := -6083;
    40: Result := -32768;
    41: Result := -32768;
    42: Result := -32768;
    43: Result := -32768;
    44: Result := -17967;
    45: Result := -124;   { не int16 — пропускаем при сверке }
    46: Result := -32768;
    47: Result := 1753;
    48: Result := -32768;
    49: Result := -32768;
  else
    Result := 0;
  end;
end;

function Mic185HasRecorderRefCode(AChannelIndex: Integer): Boolean;
begin
  Result := (AChannelIndex >= 0) and (AChannelIndex < CMic185RefChannelCount) and
    (AChannelIndex <> 45);
end;

function Mic185CodeTolerance: Integer;
begin
  Result := CMic185CodeTolerance;
end;

function Mic185ChannelCodeMatch(AChannelIndex: Integer; ACode: Double;
  out ARef, ADelta: Integer): Boolean;
var
  lGot: Integer;
begin
  ARef := 0;
  ADelta := 0;
  if not Mic185HasRecorderRefCode(AChannelIndex) then
    Exit(True);
  lGot := Round(ACode);
  ARef := Mic185RecorderRefCode(AChannelIndex);
  ADelta := lGot - ARef;
  Result := Abs(ADelta) <= CMic185CodeTolerance;
end;

function Mic185VerifyBlockCodes(var ABlock: TRecorderAcquisitionBlock;
  ASampleIndex: Integer; out AReport: string): Boolean;
var
  I: Integer;
  lGot, lRef: Integer;
  lMismatch: Integer;
  lLines: TStringList;
begin
  lMismatch := 0;
  lLines := TStringList.Create;
  try
    if (ABlock.SampleCount <= 0) or (ASampleIndex < 0) or
      (ASampleIndex >= ABlock.SampleCount) then
    begin
      AReport := 'no samples';
      Exit(False);
    end;

    for I := 0 to CMic185RefChannelCount - 1 do
    begin
      if not Mic185HasRecorderRefCode(I) then
        Continue;
      if I >= ABlock.ChannelCount then
      begin
        Inc(lMismatch);
        lLines.Add(Format('ch%d: missing', [I + 1]));
        Continue;
      end;
      lGot := Round(ABlock.Values[I][ASampleIndex]);
      lRef := Mic185RecorderRefCode(I);
      if Abs(lGot - lRef) > CMic185CodeTolerance then
      begin
        Inc(lMismatch);
        lLines.Add(Format('ch%d (3-%d): got=%d ref=%d delta=%d',
          [I + 1, I + 1, lGot, lRef, lGot - lRef]));
      end;
    end;

    if lMismatch = 0 then
      AReport := Format('OK: %d channels match (tol=%d, sample=%d)',
        [CMic185RefChannelCount - 1, CMic185CodeTolerance, ASampleIndex])
    else
      AReport := Format('MISMATCH %d:'#13#10'%s', [lMismatch, lLines.Text]);
    Result := lMismatch = 0;
  finally
    lLines.Free;
  end;
end;

end.
