unit uRecorderMic140v2Stream;

{ Чтение кадров скана: num_buff, corrupt, декоммутация AIn. }

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uRecorderDeviceInterfaces, uRecorderMic140v2WireTypes,
  uRecorderMic140v2Protocol, uRecorderMic140v2Consts, uRecorderMic140v2Diag;

type
  TMic140v2StreamState = record
    ReadCnt: Int64;
    FailCnt: Integer;
    ErrLogged: Boolean;
    PktLogged: Boolean;
    ExpectedDataWords: Word;
    ExpectedMessageWords: Word;
    PayloadStride: Integer;
    LastNumBuff: Word;
    LastNumBuffOk: Boolean;
    LastTick: QWord;
    LastTickOk: Boolean;
    GapCnt: Integer;
    DupCnt: Integer;
    CorruptCnt: Integer;
    CorruptStreak: Integer;
    SoftRestartCnt: Integer;
    StallRestartCnt: Integer;
    SeqReset: Boolean;
    SampleIdx: Int64;
    DroppedSampleRows: Int64;
    Carry: array[0..47] of Word;
    CarryCount: Integer;
  end;

procedure Mic140v2StreamClear(var S: TMic140v2StreamState);
procedure Mic140v2StreamSetExpectedPacket(var S: TMic140v2StreamState;
  ADataWords, AMessageWords: Word);
function Mic140v2StreamSincePrevMs(var S: TMic140v2StreamState): QWord;
procedure Mic140v2StreamCheckNumBuff(var S: TMic140v2StreamState;
  const ARaw: TMic140LegacyRawBlock; ASinceMs: QWord;
  const AHost: string; APort: Word; out ADesync: Boolean);
procedure Mic140v2StreamLogBlock(var S: TMic140v2StreamState;
  const ARaw: TMic140LegacyRawBlock; ASinceMs: QWord;
  AUserCh: Integer; const AHost: string; APort: Word;
  out ACorrupt: Boolean); overload;
procedure Mic140v2StreamLogBlock(var S: TMic140v2StreamState;
  const ARaw: TMic140LegacyRawBlock; ASinceMs: QWord;
  AUserCh, AStride: Integer; const AHost: string; APort: Word;
  out ACorrupt: Boolean); overload;
function Mic140v2StreamReadRaw(ACli: TMic140v2Tcp; var S: TMic140v2StreamState;
  AChCnt, AStride: Integer; AFreq: Double; AStop: Boolean; ATimeoutMs: Cardinal;
  const AHost: string; APort: Word; out ARaw: TMic140LegacyRawBlock): Boolean;
function Mic140v2StreamDecommutate(const ARaw: TMic140LegacyRawBlock;
  AChCnt, AStride: Integer; AFreq: Double;
  var SAux: TMic140AuxTemperatureBlock;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;

implementation

uses
  uRecorderDebugLog, Math;

function Mic140v2SignedPreview(const ARaw: TMic140LegacyRawBlock;
  AFirst, ACount: Integer): string;
var
  I: Integer;
  lLast: Integer;
begin
  Result := '';
  if (AFirst < 0) or (ACount <= 0) or (AFirst >= ARaw.DataWordCount) then
    Exit;
  lLast := Min(Integer(ARaw.DataWordCount), AFirst + ACount);
  for I := AFirst to lLast - 1 do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + IntToStr(SmallInt(ARaw.Data[I]));
  end;
end;

function Mic140v2CodeInRecorderBand(ACode, AIndex: Integer): Boolean;
begin
  if (ACode >= 32760) or (ACode <= -32760) or (ACode = 0) or
     (ACode > 0) then
    Exit(False);
  if AIndex < 24 then
    Result := (ACode >= -8200) and (ACode <= -6300)
  else
    Result := (ACode >= -24000) and (ACode <= -13000);
end;

procedure Mic140v2BestBandWindow(const ARaw: TMic140LegacyRawBlock;
  AStartIndex, ACount: Integer; out ABestOfs, ABestGood: Integer);
var
  lOfs, lI, lGood, lCode: Integer;
begin
  ABestOfs := -1;
  ABestGood := -1;
  if (ACount <= 0) or (ARaw.DataWordCount < ACount) then
    Exit;
  for lOfs := 0 to ARaw.DataWordCount - ACount do
  begin
    lGood := 0;
    for lI := 0 to ACount - 1 do
    begin
      lCode := SmallInt(ARaw.Data[lOfs + lI]);
      if Mic140v2CodeInRecorderBand(lCode, AStartIndex + lI) then
        Inc(lGood);
    end;
    if lGood > ABestGood then
    begin
      ABestGood := lGood;
      ABestOfs := lOfs;
    end;
  end;
end;

function Mic140v2RejectedPacketQualityText(const ARaw: TMic140LegacyRawBlock): string;
var
  lFullOfs, lFullGood, lHeadOfs, lHeadGood, lTailOfs, lTailGood,
  lPairOfs, lPairGood, lOfs, lI, lGood, lCode: Integer;
begin
  Mic140v2BestBandWindow(ARaw, 0, 48, lFullOfs, lFullGood);
  Mic140v2BestBandWindow(ARaw, 0, 24, lHeadOfs, lHeadGood);
  Mic140v2BestBandWindow(ARaw, 24, 24, lTailOfs, lTailGood);
  lPairOfs := -1;
  lPairGood := -1;
  if ARaw.DataWordCount >= 48 then
  begin
    for lOfs := 0 to ARaw.DataWordCount - 48 do
    begin
      lGood := 0;
      for lI := 0 to 47 do
      begin
        lCode := SmallInt(ARaw.Data[lOfs + lI]);
        if Mic140v2CodeInRecorderBand(lCode, lI) then
          Inc(lGood);
      end;
      if lGood > lPairGood then
      begin
        lPairGood := lGood;
        lPairOfs := lOfs;
      end;
    end;
  end;
  Result := Format('profile full48=%d/48@%d head24=%d/24@%d tail24=%d/24@%d pair=%d/48@%d',
    [lFullGood, lFullOfs, lHeadGood, lHeadOfs, lTailGood, lTailOfs,
     lPairGood, lPairOfs]);
end;

procedure Mic140v2StreamClear(var S: TMic140v2StreamState);
begin
  FillChar(S, SizeOf(S), 0);
end;

procedure Mic140v2StreamSetExpectedPacket(var S: TMic140v2StreamState;
  ADataWords, AMessageWords: Word);
begin
  S.ExpectedDataWords := ADataWords;
  S.ExpectedMessageWords := AMessageWords;
end;

function Mic140v2StreamSincePrevMs(var S: TMic140v2StreamState): QWord;
var
  now: QWord;
begin
  now := GetTickCount64;
  if S.LastTickOk then
    Result := now - S.LastTick
  else
    Result := 0;
  S.LastTick := now;
  S.LastTickOk := True;
end;

function Mic140v2DetectPayloadStride(ADataWords, ADefaultStride: Integer): Integer;
begin
  if (ADefaultStride > 0) and ((ADataWords mod ADefaultStride) = 0) then
    Exit(ADefaultStride);
  if (ADataWords mod 48) = 0 then
    Exit(48);
  if (ADataWords mod 60) = 0 then
    Exit(60);
  if (ADataWords mod 51) = 0 then
    Exit(51);
  Result := 0;
end;

{ Drops invalid rows inside a BIOS payload without hiding packet/order errors.
  MIC-140 can deliver a valid stream packet where only one ADC row contains
  transition garbage. Keeping good rows prevents spikes while num_buff/read
  counters continue to describe the original packet stream. }
function Mic140v2KeepGoodSampleRows(var ARaw: TMic140LegacyRawBlock;
  AUserCh, AStride: Integer; out AFirstKeptRow, ADroppedRows,
  AShiftedRows, APartialRows: Integer): Boolean;
var
  lSample, lSamples, lDst, lOfs, lShift, lShiftedOfs, lCandOfs,
  lLastSourceEnd: Integer;
begin
  AFirstKeptRow := 0;
  ADroppedRows := 0;
  AShiftedRows := 0;
  APartialRows := 0;
  Result := False;
  if (AStride <= 0) or (ARaw.DataWordCount <= 0) or
     ((ARaw.DataWordCount mod AStride) <> 0) then
    Exit;

  lSamples := ARaw.DataWordCount div AStride;
  lDst := 0;
  lLastSourceEnd := 0;
  for lSample := 0 to lSamples - 1 do
  begin
    lOfs := lSample * AStride;
    if lOfs < lLastSourceEnd then
    begin
      Inc(ADroppedRows);
      Continue;
    end;
    if not Mic140v2RawRowRecorderProfile(ARaw, lOfs, AUserCh) then
    begin
      lShiftedOfs := -1;
      for lShift := 1 to AStride - 1 do
      begin
        lCandOfs := lOfs + lShift;
        if lCandOfs + AStride > ARaw.DataWordCount then
          Continue;
        if lCandOfs < lLastSourceEnd then
          Continue;
        if Mic140v2RawRowRecorderProfile(ARaw, lCandOfs, AUserCh) then
        begin
          lShiftedOfs := lCandOfs;
          Break;
        end;
      end;
      if lShiftedOfs < 0 then
      begin
        Inc(ADroppedRows);
        Continue;
      end;
      lOfs := lShiftedOfs;
      Inc(AShiftedRows);
    end;

    if lDst = 0 then
      AFirstKeptRow := lSample;
    if (lDst <> lSample) or (lOfs <> lSample * AStride) then
      Move(ARaw.Data[lOfs], ARaw.Data[lDst * AStride],
        AStride * SizeOf(Word));
    lLastSourceEnd := lOfs + AStride;
    Inc(lDst);
  end;

  if lDst <= 0 then
    Exit;
  ARaw.DataWordCount := Word(lDst * AStride);
  Result := True;
end;

procedure Mic140v2SaveCarry(var S: TMic140v2StreamState;
  const AData: array of Word; ACount: Integer);
var
  lI, lKeepFrom: Integer;
begin
  S.CarryCount := Min(ACount, Length(S.Carry));
  if S.CarryCount <= 0 then
    Exit;
  lKeepFrom := ACount - S.CarryCount;
  for lI := 0 to S.CarryCount - 1 do
    S.Carry[lI] := AData[lKeepFrom + lI];
end;

function Mic140v2ExtractCarryRows(var S: TMic140v2StreamState;
  var ARaw: TMic140LegacyRawBlock; AUserCh, AStride: Integer;
  out AFirstKeptRow, ADroppedRows, AShiftedRows, APartialRows: Integer): Boolean;
var
  lBuf: array[0..CMic140LegacyMaxScanDataWords + 47] of Word;
  lProbe: TMic140LegacyRawBlock;
  lI, lTotal, lPos, lOut: Integer;
begin
  AFirstKeptRow := 0;
  ADroppedRows := 0;
  AShiftedRows := 0;
  APartialRows := 0;
  Result := False;
  if (AStride <> 48) or (AUserCh < 48) or (ARaw.DataWordCount <= 0) then
    Exit;

  lTotal := Min(S.CarryCount + ARaw.DataWordCount, Length(lBuf));
  for lI := 0 to Min(S.CarryCount, lTotal) - 1 do
    lBuf[lI] := S.Carry[lI];
  for lI := 0 to Min(Integer(ARaw.DataWordCount), lTotal - S.CarryCount) - 1 do
    lBuf[S.CarryCount + lI] := ARaw.Data[lI];

  FillChar(lProbe, SizeOf(lProbe), 0);
  lProbe.DataWordCount := Word(Min(lTotal, CMic140LegacyMaxScanDataWords));
  for lI := 0 to lProbe.DataWordCount - 1 do
    lProbe.Data[lI] := lBuf[lI];

  lOut := 0;
  lPos := 0;
  while (lPos + AStride <= lProbe.DataWordCount) and
        ((lOut + 1) * AStride <= CMic140LegacyMaxScanDataWords) do
  begin
    if Mic140v2RawRowRecorderProfile(lProbe, lPos, AUserCh) then
    begin
      if lOut = 0 then
        AFirstKeptRow := Max(0, (lPos - S.CarryCount) div AStride);
      if (lPos mod AStride) <> 0 then
        Inc(AShiftedRows);
      Move(lBuf[lPos], ARaw.Data[lOut * AStride], AStride * SizeOf(Word));
      Inc(lOut);
      Inc(lPos, AStride);
    end
    else
    begin
      Inc(lPos);
      Inc(APartialRows);
    end;
  end;

  ADroppedRows := Max(0, ARaw.DataWordCount div AStride - lOut);
  if lOut <= 0 then
    Exit;
  ARaw.DataWordCount := Word(lOut * AStride);
  ARaw.PayloadStrideWords := Word(AStride);
  Result := True;
end;

procedure Mic140v2StreamCheckNumBuff(var S: TMic140v2StreamState;
  const ARaw: TMic140LegacyRawBlock; ASinceMs: QWord;
  const AHost: string; APort: Word; out ADesync: Boolean);
var
  cur, exp: Word;
  missed: Integer;
begin
  ADesync := False;
  cur := ARaw.Header[CMic140LegacyBiosNumBuffIdx];
  if S.LastNumBuffOk then
  begin
    if cur = S.LastNumBuff then
    begin
      Inc(S.DupCnt);
      Mic140v2Log(Format('[MIC140v2:%s:%d] num_buff dup rs=%d nb=%d ms=%d prev=%d',
        [AHost, APort, ARaw.ReadSerial, cur, ASinceMs, S.LastNumBuff]));
    end
    else
    begin
      exp := Word((Integer(S.LastNumBuff) + 1) and $FFFF);
      if cur <> exp then
      begin
        missed := Integer(cur) - Integer(exp);
        if missed < 0 then
          Inc(missed, 65536);
        if missed >= CMic140v2NumBuffDesyncMissed then
        begin
          Mic140v2Log(Format(
            '[MIC140v2:%s:%d] num_buff desync rs=%d prev=%d exp=%d cur=%d missed=%d',
            [AHost, APort, ARaw.ReadSerial, S.LastNumBuff, exp, cur, missed]));
          S.LastNumBuffOk := False;
          ADesync := True;
          Exit;
        end;
        Inc(S.GapCnt);
        Mic140v2Log(Format(
          '[MIC140v2:%s:%d] num_buff gap rs=%d ms=%d prev=%d exp=%d cur=%d missed=%d',
          [AHost, APort, ARaw.ReadSerial, ASinceMs, S.LastNumBuff, exp, cur, missed]));
      end;
    end;
  end;
  S.LastNumBuff := cur;
  S.LastNumBuffOk := True;
end;

procedure Mic140v2StreamLogBlock(var S: TMic140v2StreamState;
  const ARaw: TMic140LegacyRawBlock; ASinceMs: QWord;
  AUserCh: Integer; const AHost: string; APort: Word;
  out ACorrupt: Boolean);
begin
  Mic140v2StreamLogBlock(S, ARaw, ASinceMs, AUserCh, 0, AHost, APort, ACorrupt);
end;

procedure Mic140v2StreamLogBlock(var S: TMic140v2StreamState;
  const ARaw: TMic140LegacyRawBlock; ASinceMs: QWord;
  AUserCh, AStride: Integer; const AHost: string; APort: Word;
  out ACorrupt: Boolean);
var
  lStride: Integer;
begin
  lStride := AStride;
  if lStride <= 0 then
    lStride := Mic140v2DetectPayloadStride(ARaw.DataWordCount, 0);
  ACorrupt := Mic140v2RawCorrupt(ARaw, AUserCh, lStride);
  if ACorrupt then
  begin
    Inc(S.CorruptCnt);
    Inc(S.CorruptStreak);
  end
  else
    S.CorruptStreak := 0;
  if (not S.PktLogged) or ACorrupt or
     (ARaw.ReadSerial <= CMic140v2ScanDetailLogBlocks) then
  begin
    Mic140v2Log(Format(
      '[MIC140v2:%s:%d] scan rs=%d nb=%d ms=%d corrupt=%s',
      [AHost, APort, ARaw.ReadSerial, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       ASinceMs, BoolToStr(ACorrupt, True)]));
    S.PktLogged := True;
  end;
end;

function Mic140v2StreamReadRaw(ACli: TMic140v2Tcp; var S: TMic140v2StreamState;
  AChCnt, AStride: Integer; AFreq: Double; AStop: Boolean; ATimeoutMs: Cardinal;
  const AHost: string; APort: Word; out ARaw: TMic140LegacyRawBlock): Boolean;
var
  pkt: TMic140v2ScanPacket;
  err: string;
  words, samples, since, effStride: Integer;
  originalData: array[0..CMic140LegacyMaxScanDataWords - 1] of Word;
  originalWordCount: Integer;
  keptFirst, droppedRows, shiftedRows, partialRows, originalSamples: Integer;
  desync: Boolean;
  corrupt: Boolean;
  verdict: TMic140LegacyBiosHeaderVerdict;
begin
  FillChar(ARaw, SizeOf(ARaw), 0);
  Result := False;
  if ACli = nil then
    Exit;
  if AStop then
  begin
    if ATimeoutMs = 0 then
      ACli.TimeoutMs := 1
    else if ATimeoutMs > CMic140StopReadTimeoutMs then
      ACli.TimeoutMs := CMic140StopReadTimeoutMs
    else
      ACli.TimeoutMs := ATimeoutMs;
  end
  else
    ACli.TimeoutMs := ATimeoutMs;

  if not ACli.ReadScanBlock(pkt, err) then
  begin
    if ATimeoutMs > 0 then
    begin
      Inc(S.FailCnt);
      if S.FailCnt = 1 then
        RecorderDebugLog(Format('[MIC140v2:%s:%d] read timeout after %d blocks: %s',
          [AHost, APort, S.ReadCnt, err]))
      else if (S.FailCnt >= CMic140v2ReadTimeoutWarnAfter) and (not S.ErrLogged) then
      begin
        Mic140v2Log(Format(
          '[MIC140v2:%s:%d] read fail blocks=%d timeouts=%d resync=%d: %s',
          [AHost, APort, S.ReadCnt, S.FailCnt, ACli.MdpResyncByteCount, err]));
        S.ErrLogged := True;
      end;
    end;
    Exit;
  end;

  S.ErrLogged := False;
  S.FailCnt := 0;
  if Length(pkt.HeaderWords) < CMic140LegacyBiosHeaderWords then
    Exit;
  Move(pkt.HeaderWords[0], ARaw.Header[0], CMic140LegacyBiosHeaderWords * SizeOf(Word));
  words := Length(pkt.DataWords);
  effStride := Mic140v2DetectPayloadStride(words, AStride);
  if effStride <= 0 then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] reject unaligned payload words=%d stride=%d nb=%d',
      [AHost, APort, words, AStride, ARaw.Header[CMic140LegacyBiosNumBuffIdx]]));
    Exit;
  end;
  if (S.PayloadStride > 0) and (S.PayloadStride <> effStride) then
    Mic140v2Log(Format('[MIC140v2:%s:%d] payload stride change %d -> %d words=%d',
      [AHost, APort, S.PayloadStride, effStride, words]));
  S.PayloadStride := effStride;

  Mic140LegacyEvaluateBiosScanHeader(ARaw.Header, 0, words,
    S.LastNumBuff, S.LastNumBuffOk, verdict);
  if not (verdict.TypeOk and verdict.ScanIdOk and verdict.StateOk and
      verdict.SlotOk and verdict.ChanOk) then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] reject packet %s mdpResync=%d q=%d',
      [AHost, APort, Mic140LegacyBiosHeaderVerdictText(verdict),
       ACli.MdpResyncByteCount, ACli.ScanQueueDepth]));
    Exit;
  end;
  if (S.ExpectedDataWords > 0) and (words <> S.ExpectedDataWords) then
  begin
    Mic140v2Log(Format(
      '[MIC140v2:%s:%d] warn dataWords=%d expected=%d (accepting, stride=%d)',
      [AHost, APort, words, S.ExpectedDataWords, effStride]));
  end;
  if words > CMic140LegacyMaxScanDataWords then
    words := CMic140LegacyMaxScanDataWords;
  if words > 0 then
  begin
    Move(pkt.DataWords[0], ARaw.Data[0], words * SizeOf(Word));
    Move(pkt.DataWords[0], originalData[0], words * SizeOf(Word));
  end;
  originalWordCount := words;
  ARaw.DataWordCount := Word(words);
  ARaw.PayloadStrideWords := Word(effStride);
  samples := words div effStride;
  if samples <= 0 then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] no samples words=%d stride=%d ch=%d',
      [AHost, APort, words, effStride, AChCnt]));
    Exit;
  end;
  originalSamples := samples;
  if not Mic140v2KeepGoodSampleRows(ARaw, AChCnt, effStride,
    keptFirst, droppedRows, shiftedRows, partialRows) then
  begin
    Move(originalData[0], ARaw.Data[0], originalWordCount * SizeOf(Word));
    ARaw.DataWordCount := Word(originalWordCount);
    if Mic140v2ExtractCarryRows(S, ARaw, AChCnt, effStride,
      keptFirst, droppedRows, shiftedRows, partialRows) then
    begin
      Mic140v2Log(Format(
        '[MIC140v2:%s:%d] carry sample rows nb=%d dropped=%d kept=%d shifted=%d partial=%d',
        [AHost, APort, ARaw.Header[CMic140LegacyBiosNumBuffIdx], droppedRows,
         ARaw.DataWordCount div effStride, shiftedRows, partialRows]));
    end
    else
    begin
      Mic140v2Log(Format(
        '[MIC140v2:%s:%d] reject all sample rows nb=%d words=%d samples=%d stride=%d %s',
        [AHost, APort, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
         words, samples, effStride, Mic140v2RejectedPacketQualityText(ARaw)]));
      if S.ReadCnt < CMic140v2ScanDetailLogBlocks then
        RecorderDebugLog(Format(
          '[MIC140v2:%s:%d] reject raw nb=%d first96=[%s]',
          [AHost, APort, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
           Mic140v2SignedPreview(ARaw, 0, 96)]));
      Mic140v2SaveCarry(S, originalData, originalWordCount);
      Exit;
    end;
  end;
  Mic140v2SaveCarry(S, originalData, originalWordCount);
  if droppedRows > 0 then
  begin
    Inc(S.DroppedSampleRows, droppedRows);
    samples := ARaw.DataWordCount div effStride;
    Mic140v2Log(Format(
      '[MIC140v2:%s:%d] dropped sample rows nb=%d dropped=%d kept=%d firstKept=%d totalDropped=%d',
      [AHost, APort, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       droppedRows, samples, keptFirst, S.DroppedSampleRows]));
  end;
  if shiftedRows > 0 then
    Mic140v2Log(Format(
      '[MIC140v2:%s:%d] shifted sample rows nb=%d shifted=%d partial=%d kept=%d',
      [AHost, APort, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       shiftedRows, partialRows, ARaw.DataWordCount div effStride]));

  Inc(S.ReadCnt);
  ARaw.ReadSerial := S.ReadCnt;
  S.StallRestartCnt := 0;
  since := Mic140v2StreamSincePrevMs(S);
  if (not S.PktLogged) or (ARaw.ReadSerial <= CMic140v2ScanDetailLogBlocks) then
  begin
    Mic140v2Log(Format(
      '[MIC140v2:%s:%d] %s rs=%d nb=%d ms=%d words=%d samples=%d stride=%d q=%d resync=%d',
      [AHost, APort, Mic140LegacyBiosHeaderVerdictText(verdict), ARaw.ReadSerial,
       ARaw.Header[CMic140LegacyBiosNumBuffIdx], since, words, samples, effStride,
       ACli.ScanQueueDepth, ACli.MdpResyncByteCount]));
    if ARaw.ReadSerial <= 4 then
      RecorderDebugLog(Format(
        '[MIC140v2:%s:%d] raw%d first60=[%s] second60=[%s]',
        [AHost, APort, ARaw.ReadSerial,
         Mic140v2SignedPreview(ARaw, 0, 60),
         Mic140v2SignedPreview(ARaw, 60, 60)]));
    S.PktLogged := True;
  end;
  Mic140v2StreamCheckNumBuff(S, ARaw, since, AHost, APort, desync);
  if desync then
    S.SeqReset := True;

  Mic140v2StreamLogBlock(S, ARaw, since, AChCnt, effStride, AHost, APort, corrupt);
  ARaw.FirstSampleIndex := S.SampleIdx + keptFirst;
  Inc(S.SampleIdx, originalSamples);
  Result := True;
end;

function Mic140v2StreamDecommutate(const ARaw: TMic140LegacyRawBlock;
  AChCnt, AStride: Integer; AFreq: Double;
  var SAux: TMic140AuxTemperatureBlock;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  i, j, idx: Integer;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  ClearMic140AuxTemperatureBlock(SAux);
  Result := False;
  if (AStride <= 0) and (ARaw.PayloadStrideWords > 0) then
    AStride := ARaw.PayloadStrideWords;
  ABlock.ChannelCount := AChCnt;
  if AChCnt <= 0 then
    Exit;
  ABlock.SampleCount := ARaw.DataWordCount div AStride;
  if ABlock.SampleCount <= 0 then
    Exit;
  ABlock.SampleRateHz := AFreq;
  ABlock.FirstTimeSec := ARaw.FirstSampleIndex / AFreq;
  SetLength(ABlock.Values, AChCnt);
  for i := 0 to AChCnt - 1 do
    SetLength(ABlock.Values[i], ABlock.SampleCount);
  for j := 0 to ABlock.SampleCount - 1 do
    for i := 0 to AChCnt - 1 do
    begin
      idx := j * AStride + i;
      ABlock.Values[i][j] := SmallInt(ARaw.Data[idx]);
    end;
  SAux.ChannelCount := MIC140TemperatureChannelCount;
  SAux.SampleCount := ABlock.SampleCount;
  SetLength(SAux.Values, SAux.ChannelCount);
  SetLength(SAux.Valid, SAux.ChannelCount);
  for i := 0 to SAux.ChannelCount - 1 do
  begin
    SetLength(SAux.Values[i], ABlock.SampleCount);
    SetLength(SAux.Valid[i], ABlock.SampleCount);
    for j := 0 to ABlock.SampleCount - 1 do
    begin
      idx := j * AStride + AChCnt + i;
      SAux.Valid[i][j] := idx < ARaw.DataWordCount;
      if SAux.Valid[i][j] then
        SAux.Values[i][j] := SmallInt(ARaw.Data[idx]);
    end;
  end;
  Result := True;
end;

end.
