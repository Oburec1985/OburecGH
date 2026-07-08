unit uRecorderMic140Flash;

{
  MIC-140 flash/PZU: mi118tar layout, tare records, read from device.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderMic140LegacyProtocol,
  uRecorderMic140FlashConstants, uRecorderMic140MebiusConstants,
  uRecorderMic140StreamHelpers;

type
  TMic140FltPoint = packed record
    X: Single;
    Y: Single;
  end;

  TMic140TareType1 = packed record
    Date: Word;
    Time: Word;
    OperName: array[0..15] of Byte;
    TareType: Byte;
    Range: Byte;
    TableNodes: Byte;
    TablePoints: array[0..CMic140TareTableMaxPoints - 1] of TMic140FltPoint;
  end;

  TMic140TareType2 = packed record
    Date: Word;
    Time: Word;
    OperName: array[0..15] of Byte;
    TareType: Byte;
    Range: Byte;
    TableNodes: Byte;
    TablePoints: array[0..152] of TMic140FltPoint;
  end;

  TMic140FlashDirEntry = packed record
    Name: array[0..CMic140FlashNameLength - 1] of AnsiChar;
    Size: LongWord;
    FileTime: LongWord;
    Addr: LongWord;
  end;

function Mic140FlashLogFilePath: string;
function Mic140BytesToHex(const AData; ASize, AMaxBytes: Integer): string;
function Mic140FlashDirEntryName(const AEntry: TMic140FlashDirEntry): string;
function Mic140FlashDirEntryIsEmpty(const AEntry: TMic140FlashDirEntry): Boolean;
function Mic140ParseFlashDirEntries(const AData: array of Byte;
  out AEntries: array of TMic140FlashDirEntry): Integer;
function Mic140Mic118TarFileSize(AMaxAinChannels, AMaxTinChannels: Integer): LongWord;
function Mic140ResolveMaxAinChannels(AChannelCountHint: Integer): Integer;
function Mic140FindMi118TarBaseAddress(AClient: TRecorderMic140LegacyClient;
  AMaxAinChannels, AMaxTinChannels: Integer; out ABaseAddress: LongWord;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;
function Mic140CalcBaseCalibrAddress(AMi118TarBase, AChanIndex, ARangeIndex,
  AMaxAinChannels, AMaxTinChannels: Integer): LongWord;
function Mic140TareTypeRangeIsEmpty(const ATare: TMic140TareType1): Boolean;
function Mic140TareToCalibration(const ATare: TMic140TareType1;
  ACalibration: TRecorderCalibration): Boolean;
function Mic140HardwareTareIsUsable(const ATare: TMic140TareType1): Boolean;
function Mic140DescribeTareRecord(const ATare: TMic140TareType1): string;
function Mic140DescribeTareRejectReason(const ATare: TMic140TareType1): string;
function Mic140Tare2TypeRangeIsEmpty(const ATare: TMic140TareType2): Boolean;
function Mic140Tare2ToCalibration(const ATare: TMic140TareType2;
  ACalibration: TRecorderCalibration): Boolean;
function Mic140HardwareTare2IsUsable(const ATare: TMic140TareType2): Boolean;
function Mic140DescribeTare2Record(const ATare: TMic140TareType2): string;
function Mic140DescribeTare2RejectReason(const ATare: TMic140TareType2): string;
function Mic140ResolveMaxAinChannelsFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Integer;
function Mic140TryReadHardwareTareFromFlash(AClient: TRecorderMic140LegacyClient;
  AMi118Base, AChanIndex, AMaxAinChannels, AMaxTinChannels,
  APreferredRangeIndex: Integer; out ATare: TMic140TareType1; out ARangeIndex: Integer;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;
function Mic140TryReadHardwareTare2FromFlash(AClient: TRecorderMic140LegacyClient;
  AMi118Base, AChanIndex, AMaxAinChannels, AMaxTinChannels,
  APreferredRangeIndex: Integer; out ATare: TMic140TareType2; out ARangeIndex: Integer;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;

implementation

uses
  Math, StrUtils,
  uSharedFileLogger;

function Mic140FlashLogFilePath: string;
begin
  Result := SharedLogger.FileName;
  if Result = '' then
    Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..\LogWindows.log');
end;

function Mic140BytesToHex(const AData; ASize, AMaxBytes: Integer): string;
var
  lCount: Integer;
  lI: Integer;
  lBytes: PByte;
begin
  Result := '';
  lBytes := @AData;
  lCount := ASize;
  if lCount > AMaxBytes then
    lCount := AMaxBytes;
  for lI := 0 to lCount - 1 do
    Result := Result + IntToHex(lBytes[lI], 2);
  if ASize > AMaxBytes then
    Result := Result + '...';
end;
function Mic140FlashDirEntryName(const AEntry: TMic140FlashDirEntry): string;
var
  I: Integer;
begin
  SetLength(Result, 0);
  for I := 0 to CMic140FlashNameLength - 1 do
  begin
    if (AEntry.Name[I] = #0) or (AEntry.Name[I] = AnsiChar(#$FF)) then
      Break;
    Result := Result + AEntry.Name[I];
  end;
  Result := Trim(Result);
end;

function Mic140FlashDirEntryIsEmpty(const AEntry: TMic140FlashDirEntry): Boolean;
var
  I: Integer;
  lEmpty: Boolean;
begin
  lEmpty := True;
  for I := 0 to CMic140FlashNameLength - 1 do
  begin
    if (AEntry.Name[I] <> #0) and (AEntry.Name[I] <> AnsiChar(#$FF)) then
      Exit(False);
  end;
  Result := lEmpty;
end;

function Mic140ParseFlashDirEntries(const AData: array of Byte;
  out AEntries: array of TMic140FlashDirEntry): Integer;
var
  I, lOffset: Integer;
begin
  Result := 0;
  for I := 0 to CMic140FlashMaxDirEntries - 1 do
  begin
    lOffset := I * SizeOf(TMic140FlashDirEntry);
    if lOffset + SizeOf(TMic140FlashDirEntry) > Length(AData) then
      Break;
    Move(AData[lOffset], AEntries[Result], SizeOf(TMic140FlashDirEntry));
    if Mic140FlashDirEntryIsEmpty(AEntries[Result]) then
      Break;
    Inc(Result);
  end;
end;

function Mic140Mic118TarFileSize(AMaxAinChannels, AMaxTinChannels: Integer): LongWord;
begin
  Result := LongWord(AMaxAinChannels) * SizeOf(TMic140TareType1) * CMic140RangeCountMic140 +
    LongWord(AMaxTinChannels) * SizeOf(TMic140TareType2) * CMic140RangeCountMic140;
end;

function Mic140ResolveMaxAinChannels(AChannelCountHint: Integer): Integer;
begin
  if (AChannelCountHint > 0) and (AChannelCountHint <= CMic140MaxAinChannels48) then
    Result := CMic140MaxAinChannels48
  else
    Result := CMic140MaxAinChannels96;
end;

function Mic140FindMi118TarBaseAddress(AClient: TRecorderMic140LegacyClient;
  AMaxAinChannels, AMaxTinChannels: Integer; out ABaseAddress: LongWord;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;
var
  lAddress: LongWord;
  lDirBytes: array of Byte;
  lEntries: array of TMic140FlashDirEntry;
  lFileCount: Integer;
  lFoundIndex: Integer;
  lI: Integer;
  lName: string;
  lPrefix: string;
  lSize: LongWord;
  lTareSize: LongWord;
begin
  Result := False;
  ABaseAddress := 0;
  AErrorMessage := '';
  lPrefix := ALogPrefix;
  if lPrefix <> '' then
    lPrefix := lPrefix + ' ';
  SetLength(lDirBytes, CMic140FlashDirSize);
  if not AClient.ReadFlashStorage(CMic140FlashDirOffset, lDirBytes[0],
    CMic140FlashDirSize, AErrorMessage) then
  begin
    Mic140LogFlash(lPrefix + 'flash dir read failed at offset ' +
      IntToStr(CMic140FlashDirOffset) + ': ' + AErrorMessage);
    Exit;
  end;

  SetLength(lEntries, CMic140FlashMaxDirEntries);
  lFileCount := Mic140ParseFlashDirEntries(lDirBytes, lEntries);
  Mic140LogFlash(lPrefix + Format('flash dir entries=%d tareRecSize=%d expectedTareFileSize=%d',
    [lFileCount, SizeOf(TMic140TareType1),
    Mic140Mic118TarFileSize(AMaxAinChannels, AMaxTinChannels)]));
  for lI := 0 to lFileCount - 1 do
  begin
    lName := Mic140FlashDirEntryName(lEntries[lI]);
    Mic140LogFlash(lPrefix + Format('flash dir[%d] name=%s addr=0x%.8x size=%u',
      [lI, lName, lEntries[lI].Addr, lEntries[lI].Size]));
  end;

  if lFileCount = 0 then
  begin
    AErrorMessage := 'Flash disk directory is empty';
    Mic140LogFlash(lPrefix + AErrorMessage);
    Exit;
  end;

  lTareSize := Mic140Mic118TarFileSize(AMaxAinChannels, AMaxTinChannels);
  lFoundIndex := -1;
  for lI := 0 to lFileCount - 1 do
  begin
    if SameText(Mic140FlashDirEntryName(lEntries[lI]), CMic140Mi118TarFileName) then
    begin
      lFoundIndex := lI;
      lAddress := lEntries[lI].Addr;
      lSize := lEntries[lI].Size;
      Break;
    end;
  end;

  if lFoundIndex >= 0 then
    Mic140LogFlash(lPrefix + Format('mi118tar found at index %d addr=0x%.8x size=%u expected=%u',
      [lFoundIndex, lAddress, lSize, lTareSize]))
  else
    Mic140LogFlash(lPrefix + 'mi118tar not found in flash dir, using fallback placement');

  if (lFoundIndex < 0) or (lSize <> lTareSize) then
  begin
    if lFoundIndex < 0 then
    begin
      lAddress := lEntries[lFileCount - 1].Addr;
      lSize := lEntries[lFileCount - 1].Size;
      Inc(lAddress, lSize);
    end;
    Inc(lAddress, lTareSize);
    Mic140LogFlash(lPrefix + Format('mi118tar fallback base=0x%.8x', [lAddress]));
  end;

  if lAddress > CMic140FlashStorageBytes then
  begin
    AErrorMessage := 'Calibration storage is outside flash memory';
    Mic140LogFlash(lPrefix + Format('%s (base=0x%.8x diskSize=%d)',
      [AErrorMessage, lAddress, CMic140FlashStorageBytes]));
    Exit;
  end;

  ABaseAddress := lAddress;
  Mic140LogFlash(lPrefix + Format('mi118tar base=0x%.8x', [ABaseAddress]));
  Result := True;
end;

function Mic140CalcBaseCalibrAddress(AMi118TarBase, AChanIndex, ARangeIndex,
  AMaxAinChannels, AMaxTinChannels: Integer): LongWord;
begin
  if AChanIndex < AMaxAinChannels then
    Result := AMi118TarBase +
      LongWord(AChanIndex) * SizeOf(TMic140TareType1) * CMic140RangeCountMic140 +
      LongWord(ARangeIndex) * SizeOf(TMic140TareType1)
  else
    Result := AMi118TarBase +
      LongWord(AMaxAinChannels) * SizeOf(TMic140TareType1) * CMic140RangeCountMic140 +
      LongWord(AChanIndex - AMaxAinChannels) * SizeOf(TMic140TareType2) *
      CMic140RangeCountMic140 +
      LongWord(ARangeIndex) * SizeOf(TMic140TareType2);
end;

function Mic140TareTypeRangeIsEmpty(const ATare: TMic140TareType1): Boolean;
var
  lValue: Word;
begin
  lValue := Word(ATare.TareType) or (Word(ATare.Range) shl 8);
  Result := (lValue = 0) or (lValue = $FFFF);
end;

function Mic140TareToCalibration(const ATare: TMic140TareType1;
  ACalibration: TRecorderCalibration): Boolean;
var
  lI: Integer;
begin
  Result := False;
  if ACalibration = nil then
    Exit;
  if ATare.TareType <> CMic140TareTypeTable then
    Exit;
  if (ATare.TableNodes = 0) or (ATare.TableNodes > CMic140TareTableMaxPoints) then
    Exit;

  ACalibration.ClearPoints;
  ACalibration.Kind := rckPiecewiseLinear;
  ACalibration.Extrapolation := True;
  for lI := 0 to ATare.TableNodes - 1 do
    ACalibration.AddPoint(ATare.TablePoints[lI].X, ATare.TablePoints[lI].Y);
  Result := ACalibration.PointCount > 0;
end;


function Mic140HardwareTareIsUsable(const ATare: TMic140TareType1): Boolean;
begin
  Result := not Mic140TareTypeRangeIsEmpty(ATare) and
    (ATare.TareType = CMic140TareTypeTable) and
    (ATare.TableNodes > 0) and
    (ATare.TableNodes <= CMic140TareTableMaxPoints);
end;

function Mic140DescribeTareRecord(const ATare: TMic140TareType1): string;
begin
  Result := Format('date=%u time=%u type=%u range=%u nodes=%u recSize=%d hex=%s',
    [ATare.Date, ATare.Time, ATare.TareType, ATare.Range, ATare.TableNodes,
    SizeOf(ATare), Mic140BytesToHex(ATare, SizeOf(ATare), 24)]);
end;

function Mic140DescribeTareRejectReason(const ATare: TMic140TareType1): string;
begin
  if Mic140TareTypeRangeIsEmpty(ATare) then
    Exit('empty type/range word');
  if ATare.TareType <> CMic140TareTypeTable then
    Exit(Format('unsupported tare type %u (expected table=%u)',
      [ATare.TareType, CMic140TareTypeTable]));
  if ATare.TableNodes = 0 then
    Exit('table node count is zero');
  if ATare.TableNodes > CMic140TareTableMaxPoints then
    Exit(Format('table node count %u exceeds max %u',
      [ATare.TableNodes, CMic140TareTableMaxPoints]));
  Result := 'unknown reject reason';
end;

function Mic140Tare2TypeRangeIsEmpty(const ATare: TMic140TareType2): Boolean;
var
  lValue: Word;
begin
  lValue := Word(ATare.TareType) or (Word(ATare.Range) shl 8);
  Result := (lValue = 0) or (lValue = $FFFF);
end;

function Mic140Tare2ToCalibration(const ATare: TMic140TareType2;
  ACalibration: TRecorderCalibration): Boolean;
var
  lI: Integer;
begin
  Result := False;
  if ACalibration = nil then
    Exit;
  if ATare.TareType <> CMic140TareTypeTable then
    Exit;
  if (ATare.TableNodes = 0) or (ATare.TableNodes > CMic140TareTable2MaxPoints) then
    Exit;

  ACalibration.ClearPoints;
  ACalibration.Kind := rckPiecewiseLinear;
  ACalibration.Extrapolation := True;
  for lI := 0 to ATare.TableNodes - 1 do
    ACalibration.AddPoint(ATare.TablePoints[lI].X, ATare.TablePoints[lI].Y);
  Result := ACalibration.PointCount > 0;
end;

function Mic140HardwareTare2IsUsable(const ATare: TMic140TareType2): Boolean;
begin
  Result := not Mic140Tare2TypeRangeIsEmpty(ATare) and
    (ATare.TareType = CMic140TareTypeTable) and
    (ATare.TableNodes > 0) and
    (ATare.TableNodes <= CMic140TareTable2MaxPoints);
end;

function Mic140DescribeTare2Record(const ATare: TMic140TareType2): string;
begin
  Result := Format('date=%u time=%u type=%u range=%u nodes=%u recSize=%d hex=%s',
    [ATare.Date, ATare.Time, ATare.TareType, ATare.Range, ATare.TableNodes,
    SizeOf(ATare), Mic140BytesToHex(ATare, SizeOf(ATare), 24)]);
end;

function Mic140DescribeTare2RejectReason(const ATare: TMic140TareType2): string;
begin
  if Mic140Tare2TypeRangeIsEmpty(ATare) then
    Exit('empty type/range word');
  if ATare.TareType <> CMic140TareTypeTable then
    Exit(Format('unsupported tare type %u (expected table=%u)',
      [ATare.TareType, CMic140TareTypeTable]));
  if ATare.TableNodes = 0 then
    Exit('table node count is zero');
  if ATare.TableNodes > CMic140TareTable2MaxPoints then
    Exit(Format('table node count %u exceeds max %u',
      [ATare.TableNodes, CMic140TareTable2MaxPoints]));
  Result := 'unknown reject reason';
end;

function Mic140ResolveMaxAinChannelsFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Integer;
begin
  if (AFirmware.DevType > 0) and (AFirmware.DevType <= CMic140MaxAinChannels48) then
    Result := CMic140MaxAinChannels48
  else
    Result := CMic140MaxAinChannels96;
end;

function Mic140TryReadHardwareTareFromFlash(AClient: TRecorderMic140LegacyClient;
  AMi118Base, AChanIndex, AMaxAinChannels, AMaxTinChannels,
  APreferredRangeIndex: Integer; out ATare: TMic140TareType1; out ARangeIndex: Integer;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;
var
  lAddress: LongWord;
  lCandidate: TMic140TareType1;
  lFoundAny: Boolean;
  lPrefix: string;
  lTryRange: Integer;
begin
  Result := False;
  ARangeIndex := -1;
  AErrorMessage := '';
  FillChar(ATare, SizeOf(ATare), 0);
  lFoundAny := False;
  lPrefix := ALogPrefix;
  if lPrefix <> '' then
    lPrefix := lPrefix + ' ';

  Mic140LogFlash(lPrefix + Format('scan tare slots: chanIndex=%d preferredRange=%d ain=%d tin=%d base=0x%.8x',
    [AChanIndex, APreferredRangeIndex, AMaxAinChannels, AMaxTinChannels, AMi118Base]));

  for lTryRange := 0 to CMic140RangeCountMic140 - 1 do
  begin
    lAddress := Mic140CalcBaseCalibrAddress(AMi118Base, AChanIndex, lTryRange,
      AMaxAinChannels, AMaxTinChannels);
    FillChar(lCandidate, SizeOf(lCandidate), 0);
    if not AClient.ReadFlashStorage(lAddress, lCandidate, SizeOf(lCandidate),
      AErrorMessage) then
    begin
      Mic140LogFlash(lPrefix + Format('range slot %d read failed at 0x%.8x: %s',
        [lTryRange, lAddress, AErrorMessage]));
      Exit;
    end;

    Mic140LogFlash(lPrefix + Format('range slot %d addr=0x%.8x %s',
      [lTryRange, lAddress, Mic140DescribeTareRecord(lCandidate)]));

    if not Mic140HardwareTareIsUsable(lCandidate) then
    begin
      Mic140LogFlash(lPrefix + Format('range slot %d rejected: %s',
        [lTryRange, Mic140DescribeTareRejectReason(lCandidate)]));
      Continue;
    end;

    ATare := lCandidate;
    if lCandidate.Range < CMic140RangeCountMic140 then
      ARangeIndex := lCandidate.Range
    else
      ARangeIndex := lTryRange;
    lFoundAny := True;

    if (APreferredRangeIndex >= 0) and (APreferredRangeIndex < CMic140RangeCountMic140) and
      ((lTryRange = APreferredRangeIndex) or (lCandidate.Range = Byte(APreferredRangeIndex))) then
    begin
      Mic140LogFlash(lPrefix + Format('selected range slot %d (preferred match)', [lTryRange]));
      Exit(True);
    end;
    if lCandidate.Range = Byte(lTryRange) then
    begin
      Mic140LogFlash(lPrefix + Format('selected range slot %d (range field match)', [lTryRange]));
      Exit(True);
    end;
  end;

  if lFoundAny then
  begin
    Mic140LogFlash(lPrefix + Format('selected first usable tare with rangeIndex=%d', [ARangeIndex]));
    Exit(True);
  end;

  AErrorMessage := 'Calibration was not found in device flash memory';
  Mic140LogFlash(lPrefix + AErrorMessage);
end;

function Mic140TryReadHardwareTare2FromFlash(AClient: TRecorderMic140LegacyClient;
  AMi118Base, AChanIndex, AMaxAinChannels, AMaxTinChannels,
  APreferredRangeIndex: Integer; out ATare: TMic140TareType2; out ARangeIndex: Integer;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;
var
  lAddress: LongWord;
  lCandidate: TMic140TareType2;
  lFoundAny: Boolean;
  lPrefix: string;
  lTryRange: Integer;
begin
  Result := False;
  ARangeIndex := -1;
  AErrorMessage := '';
  FillChar(ATare, SizeOf(ATare), 0);
  lFoundAny := False;
  lPrefix := ALogPrefix;
  if lPrefix <> '' then
    lPrefix := lPrefix + ' ';

  Mic140LogFlash(lPrefix + Format('scan TIn tare slots: chanIndex=%d preferredRange=%d ain=%d tin=%d base=0x%.8x',
    [AChanIndex, APreferredRangeIndex, AMaxAinChannels, AMaxTinChannels, AMi118Base]));

  for lTryRange := 0 to CMic140RangeCountMic140 - 1 do
  begin
    lAddress := Mic140CalcBaseCalibrAddress(AMi118Base, AChanIndex, lTryRange,
      AMaxAinChannels, AMaxTinChannels);
    FillChar(lCandidate, SizeOf(lCandidate), 0);
    if not AClient.ReadFlashStorage(lAddress, lCandidate, SizeOf(lCandidate),
      AErrorMessage) then
    begin
      Mic140LogFlash(lPrefix + Format('TIn range slot %d read failed at 0x%.8x: %s',
        [lTryRange, lAddress, AErrorMessage]));
      Exit;
    end;

    Mic140LogFlash(lPrefix + Format('TIn range slot %d addr=0x%.8x %s',
      [lTryRange, lAddress, Mic140DescribeTare2Record(lCandidate)]));

    if not Mic140HardwareTare2IsUsable(lCandidate) then
    begin
      Mic140LogFlash(lPrefix + Format('TIn range slot %d rejected: %s',
        [lTryRange, Mic140DescribeTare2RejectReason(lCandidate)]));
      Continue;
    end;

    ATare := lCandidate;
    if lCandidate.Range < CMic140RangeCountMic140 then
      ARangeIndex := lCandidate.Range
    else
      ARangeIndex := lTryRange;
    lFoundAny := True;

    if (APreferredRangeIndex >= 0) and (APreferredRangeIndex < CMic140RangeCountMic140) and
      ((lTryRange = APreferredRangeIndex) or (lCandidate.Range = Byte(APreferredRangeIndex))) then
    begin
      Mic140LogFlash(lPrefix + Format('selected TIn range slot %d (preferred match)', [lTryRange]));
      Exit(True);
    end;
    if lCandidate.Range = Byte(lTryRange) then
    begin
      Mic140LogFlash(lPrefix + Format('selected TIn range slot %d (range field match)', [lTryRange]));
      Exit(True);
    end;
  end;

  if lFoundAny then
  begin
    Mic140LogFlash(lPrefix + Format('selected first usable TIn tare with rangeIndex=%d', [ARangeIndex]));
    Exit(True);
  end;

  AErrorMessage := 'Calibration was not found in device flash memory';
  Mic140LogFlash(lPrefix + AErrorMessage);
end;

end.
