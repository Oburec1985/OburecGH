unit uRecorderMic140StreamHelpers;

{
  MIC-140 stream diagnostics: logging filters, raw-block sanity checks, payload
  classification. Kept out of the data source orchestration unit.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uRecorderDeviceInterfaces, uRecorderMic140StreamTypes,
  uRecorderMic140LegacyProtocol;

const
  CMic140RawBufferDropLogIntervalMs = 1000;
  CMic140LegacyScanDetailLogBlocks = 15;
  CMic140LegacyStreamSummaryInterval = 20;
  CMic140LegacyNumBuffDesyncRestartMissed = 32;
  CMic140MisalignPositiveThreshold = 500.0;

procedure Mic140LogWarning(const AMessage: string);
procedure Mic140LogFlash(const AMessage: string);

function Mic140AdcCodeIsSaturated(AValue: Double): Boolean;
function Mic140LegacyStrainBlockLooksCorrupt(
  const ABlock: TRecorderDeviceSampleBlock): Boolean;
function Mic140LegacyRawBlockLooksCorrupt(const ARaw: TMic140LegacyRawBlock;
  AUserChannelCount: Integer): Boolean;
function Mic140LegacyDetectAdcJump(const ARaw, ALastGood: TMic140LegacyRawBlock;
  ALastGoodValid, AUserChannelCount: Integer; out AJumpSummary: string): Boolean;
function Mic140LegacyClassifyPayload(AHeaderOk, ALayoutSuspect,
  AAdcJump: Boolean; const AJumpSummary: string): string;
procedure Mic140LegacyExtractRawSample(const ARaw: TMic140LegacyRawBlock;
  ASampleIndex, AUserChannelCount: Integer; out ASubRaw: TMic140LegacyRawBlock);

implementation

uses
  uSharedFileLogger, uRecorderDebugLog;

const
  CMic140MisalignSatThreshold = 32760.0;
  CMic140MisalignMinSatChannels = 32;
  CMic140MisalignMinPositiveChannels = 20;
  CMic140StrainCodeMax = 500;
  CMic140StrainCodeMin = -15000;
  CMic140MisalignMinBadStrainChannels = 8;
  CMic140LegacyAdcJumpThreshold = 1500;

procedure Mic140LogWarning(const AMessage: string);
begin
  if CMic140StreamLogOnly and not Mic140StreamLogAllowed(AMessage) then
    Exit;
  SharedLogger.Enabled := True;
  SharedLogger.Warning(AMessage);
end;

procedure Mic140LogFlash(const AMessage: string);
begin
  SharedLogger.Enabled := True;
  SharedLogger.Info(AMessage);
end;

function Mic140AdcCodeIsSaturated(AValue: Double): Boolean;
begin
  Result := (AValue >= 32767) or (AValue <= -32768);
end;

function Mic140LegacyStrainAdcCodePlausible(AValue: Integer): Boolean;
begin
  Result := (AValue <= CMic140StrainCodeMax) and (AValue >= CMic140StrainCodeMin);
end;

function Mic140LegacyStrainBlockLooksCorrupt(
  const ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  lI: Integer;
  lJ: Integer;
  lBadCount: Integer;
  lPosCount: Integer;
  lSatCount: Integer;
begin
  lBadCount := 0;
  lPosCount := 0;
  lSatCount := 0;
  if (ABlock.ChannelCount <= 0) or (ABlock.SampleCount <= 0) then
    Exit(False);
  for lJ := 0 to ABlock.SampleCount - 1 do
    for lI := 0 to ABlock.ChannelCount - 1 do
    begin
      if lI >= Length(ABlock.Values) then
        Continue;
      if lJ >= Length(ABlock.Values[lI]) then
        Continue;
      if Mic140AdcCodeIsSaturated(ABlock.Values[lI][lJ]) then
        Inc(lSatCount)
      else if not Mic140LegacyStrainAdcCodePlausible(Trunc(ABlock.Values[lI][lJ])) then
        Inc(lBadCount)
      else if ABlock.Values[lI][lJ] > CMic140MisalignPositiveThreshold then
        Inc(lPosCount);
    end;
  Result := (lBadCount >= CMic140MisalignMinBadStrainChannels) or
    (lSatCount >= CMic140MisalignMinSatChannels) or
    (lPosCount >= CMic140MisalignMinPositiveChannels);
end;

function Mic140LegacyRawBlockLooksCorrupt(const ARaw: TMic140LegacyRawBlock;
  AUserChannelCount: Integer): Boolean;
var
  lI: Integer;
  lJ: Integer;
  lPosCount: Integer;
  lSampleCount: Integer;
  lSatCount: Integer;
  lCode: Integer;
  lStride: Integer;
begin
  lPosCount := 0;
  lSatCount := 0;
  if (ARaw.DataWordCount = 0) or (AUserChannelCount <= 0) then
    Exit(False);
  lStride := AUserChannelCount;
  lSampleCount := ARaw.DataWordCount div lStride;
  if lSampleCount <= 0 then
    Exit(False);
  for lJ := 0 to lSampleCount - 1 do
    for lI := 0 to Min(AUserChannelCount - 1, 47) do
    begin
      lCode := SmallInt(ARaw.Data[lJ * lStride + lI]);
      if (lCode >= 32767) or (lCode <= -32768) then
        Inc(lSatCount)
      else if lCode > CMic140MisalignPositiveThreshold then
        Inc(lPosCount);
    end;
  Result := (lSatCount >= CMic140MisalignMinSatChannels) or
    (lPosCount >= CMic140MisalignMinPositiveChannels);
end;

function Mic140LegacyDetectAdcJump(const ARaw, ALastGood: TMic140LegacyRawBlock;
  ALastGoodValid, AUserChannelCount: Integer; out AJumpSummary: string): Boolean;
var
  lDelta: Integer;
  lI: Integer;
  lJumpCount: Integer;
  lMaxDelta: Integer;
  lMaxCh: Integer;
  lNewCode: Integer;
  lOldCode: Integer;
begin
  Result := False;
  AJumpSummary := '';
  if (not Boolean(ALastGoodValid)) or (AUserChannelCount <= 0) or
     (ARaw.DataWordCount <> ALastGood.DataWordCount) then
    Exit;
  lJumpCount := 0;
  lMaxDelta := 0;
  lMaxCh := -1;
  for lI := 0 to Min(AUserChannelCount - 1, 47) do
  begin
    lNewCode := SmallInt(ARaw.Data[lI]);
    lOldCode := SmallInt(ALastGood.Data[lI]);
    lDelta := Abs(lNewCode - lOldCode);
    if lDelta < CMic140LegacyAdcJumpThreshold then
      Continue;
    Inc(lJumpCount);
    if lDelta > lMaxDelta then
    begin
      lMaxDelta := lDelta;
      lMaxCh := lI + 1;
    end;
  end;
  if lJumpCount = 0 then
    Exit;
  Result := True;
  AJumpSummary := Format('ch%d delta=%d jumps=%d', [lMaxCh, lMaxDelta, lJumpCount]);
end;

function Mic140LegacyClassifyPayload(AHeaderOk, ALayoutSuspect,
  AAdcJump: Boolean; const AJumpSummary: string): string;
begin
  if not AHeaderOk then
    Exit('payload=untrusted_header');
  if ALayoutSuspect then
    Exit('payload=layout_or_phase');
  if AAdcJump then
    Exit('payload=adc_unstable ' + AJumpSummary);
  Result := 'payload=ok';
end;

procedure Mic140LegacyExtractRawSample(const ARaw: TMic140LegacyRawBlock;
  ASampleIndex, AUserChannelCount: Integer; out ASubRaw: TMic140LegacyRawBlock);
var
  lI: Integer;
  lStride: Integer;
  lSrcIndex: Integer;
  lWords: Integer;
begin
  FillChar(ASubRaw, SizeOf(ASubRaw), 0);
  Move(ARaw.Header[0], ASubRaw.Header[0], SizeOf(ARaw.Header));
  ASubRaw.ReadSerial := ARaw.ReadSerial;
  lStride := AUserChannelCount;
  lWords := 0;
  for lI := 0 to lStride - 1 do
  begin
    lSrcIndex := ASampleIndex * lStride + lI;
    if lSrcIndex >= ARaw.DataWordCount then
      Break;
    ASubRaw.Data[lI] := ARaw.Data[lSrcIndex];
    Inc(lWords);
  end;
  ASubRaw.DataWordCount := Word(lWords);
end;

end.
