unit uRecorderMic140LegacyChannelDesc;

{
  Legacy scan channel descriptor packing (ME048 / MIC140 reg bits).
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uRecorderMic140LegacyProtocol, uRecorderMic140StreamTypes;

function Mic140LegacyPackMic140RegDesc(AMuxIn1, AMuxIn2, AK1, AK2, AAmp2, AAmp4,
  AAmp16, ABreakTst: Word): Word;
procedure Mic140LegacyPackMe04848(const ACode: array of Word; out AW0, AW1: Word);
procedure Mic140LegacyPackMe04896(const ACode: array of Word;
  ANumMe048: Word; out AW0, AW1: Word);
procedure Mic140LegacyMe048ForPhysicalChannel(APhysicalChannel: Integer;
  out AW0, AW1: Word);
function Mic140LegacyMe048Code48(APhysicalChannel: Integer): Word;
function Mic140LegacyLevel0Code: Word;
function Mic140LegacyTInCode48(ATemperatureIndex: Integer): Word;
function Mic140LegacyTInDesc48(ATemperatureIndex: Integer): Word;
function Mic140LegacyWordAt(const AWords: TRecorderMic140LegacyWordArray;
  AIndex: Integer): Word;

implementation

function Mic140LegacyPackMic140RegDesc(AMuxIn1, AMuxIn2, AK1, AK2, AAmp2, AAmp4,
  AAmp16, ABreakTst: Word): Word;
begin
  // TRegMIC140 bit layout from mic140_96mod.cpp: desc |= reg[j] << j.
  Result := 0;
  if AAmp4 <> 0 then
    Result := Result or (AAmp4 shl 1);
  if AAmp2 <> 0 then
    Result := Result or (AAmp2 shl 2);
  if AAmp16 <> 0 then
    Result := Result or (AAmp16 shl 3);
  if AMuxIn1 <> 0 then
    Result := Result or (AMuxIn1 shl 4);
  if AMuxIn2 <> 0 then
    Result := Result or (AMuxIn2 shl 5);
  if ABreakTst <> 0 then
    Result := Result or (ABreakTst shl 6);
  if AK1 <> 0 then
    Result := Result or (AK1 shl 8);
  if AK2 <> 0 then
    Result := Result or (AK2 shl 10);
end;

procedure Mic140LegacyPackMe04848(const ACode: array of Word; out AW0, AW1: Word);
var
  lReg: packed record
    indicator: Word;
    XA14: Word;
    XA13: Word;
    XA12: Word;
    XA11: Word;
    XA10: Word;
    XA9: Word;
    XA8: Word;
    XA7: Word;
    XA6: Word;
    XA5: Word;
    XA4: Word;
    XA3: Word;
    XA2: Word;
    XA1: Word;
    XA0: Word;
  end;
  J: Integer;
begin
  // ModuleMIC140_48::PrepareModuleDescForScan packs TRegME048 into code_ME048[1]
  // when num_me048=0 (all 48 AIn channels on this module).
  AW0 := 0;
  AW1 := 0;
  if Length(ACode) < 16 then
    Exit;
  FillChar(lReg, SizeOf(lReg), 0);
  lReg.XA0 := ACode[0];
  lReg.XA1 := ACode[1];
  lReg.XA2 := ACode[2];
  lReg.XA3 := ACode[3];
  lReg.XA4 := ACode[4];
  lReg.XA5 := ACode[5];
  lReg.XA6 := ACode[6];
  lReg.XA7 := ACode[7];
  lReg.XA8 := ACode[8];
  lReg.XA9 := ACode[9];
  lReg.XA10 := ACode[10];
  lReg.XA11 := ACode[11];
  lReg.XA12 := ACode[12];
  lReg.XA13 := ACode[13];
  lReg.XA14 := ACode[14];
  lReg.indicator := ACode[15];
  for J := 0 to 15 do
    AW1 := AW1 or (PWord(@lReg)[J] shl J);
end;

procedure Mic140LegacyPackMe04896(const ACode: array of Word;
  ANumMe048: Word; out AW0, AW1: Word);
var
  lReg: array[0..15] of Word;
  J: Integer;
  lWordIdx: Integer;
begin
  // ModuleMIC140_96::PrepareModuleDescForScan packs TRegME048 into two words.
  AW0 := 0;
  AW1 := 0;
  if Length(ACode) < 16 then
    Exit;
  lReg[0] := ACode[15];
  for J := 0 to 14 do
    lReg[J + 1] := ACode[14 - J];
  lWordIdx := 1 - Integer(ANumMe048);
  for J := 0 to 15 do
    if lWordIdx = 0 then
      AW0 := AW0 or (lReg[J] shl J)
    else
      AW1 := AW1 or (lReg[J] shl J);
end;

procedure Mic140LegacyMe048ForPhysicalChannel(APhysicalChannel: Integer;
  out AW0, AW1: Word);
const
  CCodeLevel0: array[0..15] of Word =
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
  CCodeChanAIn: array[0..47, 0..15] of Word = (
    (0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    (1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1),
    (0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1),
    (1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1),
    (1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    (1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1),
    (1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1),
    (1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1),
    (1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1));
var
  lIdx: Integer;
begin
  if (APhysicalChannel < 0) or (APhysicalChannel > 47) then
  begin
    Mic140LegacyPackMe04848(CCodeLevel0, AW0, AW1);
    Exit;
  end;
  lIdx := APhysicalChannel;
  Mic140LegacyPackMe04848(CCodeChanAIn[lIdx], AW0, AW1);
end;

function Mic140LegacyMe048Code48(APhysicalChannel: Integer): Word;
var
  lGroup: Integer;
  lLow: Integer;
  lSelectLine: Integer;
begin
  // Equivalent to packing TRegME048 from MIC140_48mod.cpp. The first 24
  // physical channels use selector lines XA2..XA7; the second half uses
  // XA8..XA13 and sets the indicator bit.
  lLow := APhysicalChannel mod 4;
  if APhysicalChannel < 24 then
  begin
    lGroup := APhysicalChannel div 4;
    lSelectLine := 2 + lGroup;
    Result := 0;
  end
  else
  begin
    lGroup := (APhysicalChannel - 24) div 4;
    lSelectLine := 8 + lGroup;
    Result := 1;
  end;

  if (lLow and 1) <> 0 then
    Result := Result or (Word(1) shl 15);
  if (lLow and 2) <> 0 then
    Result := Result or (Word(1) shl 14);
  Result := Result or (Word(1) shl (15 - lSelectLine));
end;

function Mic140LegacyLevel0Code: Word;
begin
  Result := Word(1) shl 1;
end;

function Mic140LegacyTInCode48(ATemperatureIndex: Integer): Word;
begin
  // ModuleMIC140_48::code_chanTIn_48 and TInNum={1,0}. The third internal
  // slot is programmed as level0mV by the original driver, not as an external
  // user temperature channel.
  case ATemperatureIndex of
    0: Result := $C002;
    1: Result := $4002;
  else
    Result := Mic140LegacyLevel0Code;
  end;
end;

function Mic140LegacyTInDesc48(ATemperatureIndex: Integer): Word;
begin
  // TRegMIC140 packed bits: MUX_IN1 is bit 4, MUX_IN2 is bit 5, K1 is bit 8.
  // ModuleMIC140_48 forces the last TIn slot to board MUX 2 while keeping the
  // same hard-amplifier timing bits as ordinary scan channels.
  if ATemperatureIndex = MIC140TemperatureChannelCount - 1 then
    Result := $0120
  else
    Result := $0110;
end;

function Mic140LegacyWordAt(const AWords: TRecorderMic140LegacyWordArray;
  AIndex: Integer): Word;
begin
  if (AIndex >= 0) and (AIndex < Length(AWords)) then
    Result := AWords[AIndex]
  else
    Result := 0;
end;

end.
