unit uRecorderMic140v2Scan;

{
  Shadow unit: программирование BIOS-скана MIC-140 (только для Mic140ProtocolDebug).

  Копия Device/MIC140v2/uRecorderMic140v2Scan.pas + экспериментальные хуки.
  Подключается из-за порядка search path: Driver/ перед Device/MIC140v2.

  Дополнительно к production-версии:
    Mic140v2SetDebugTinSlotCount     — 0..3 TIn в BIOS-списке (MASK_CHAN_LEFT на ptr TIn)
    Mic140v2SetDebugFifoStride       — 48 или 51 слов/строка FIFO (0 = авто: 51 при tin=3)
    Mic140v2SetDebugBank2DelayMul    — увеличить SPORT-delay для CH25..48
    Mic140v2SetDebugChanDumpCount    — переписать m_ChanDump[2] (48 vs 51)
    Mic140v2SetDebugFifoSamples      — строк sample в MDP (0=авто; 3 → msgWords=163)
    MIC140_DEBUG_RECORDER_PROFILE=1  — stride=51, chanDump=51, fifoSamples=3
    MIC140_DEBUG_GROUND_POINTERS=1   — flag_chan_ground (ground+chan ptr pairs)
    MIC140_DEBUG_ME048_V2=1          — 24-bit ME048 packing (MIC140_48v2), нестабильно

  Эталон оригинала: MIC140_48mod.cpp, mic140_96scn.cpp, Modscn.cpp.
}
{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, StrUtils,
  uRecorderMic140v2WireTypes,
  uRecorderMic140v2Protocol, uRecorderMic140v2Consts,
  uRecorderMic140v2Timing, uRecorderMic140v2ChanDesc, uRecorderMic140v2Helper;

type
  TMic140v2ScanProgrammer = class
  private
    fCli: TMic140v2Tcp;
    fChCnt: Integer;
    fFreq: Double;
    fUpdMs: Cardinal;
    fDevRev: Word;
    fDevSubRev: Word;
    fRangeIndexes: array of Integer;
    fCommutIndexes: array of Integer;
    fBoardCommutIndexes: array of Integer;
    fBufCur: Word;
    fHeapCur: Word;
    fLastFifoReady: Word;
    fLastValAddr: Word;
    fLastPayloadStride: Integer;
    function AllocBuf(AWords: Word; out APg, AAddr: Word): Boolean;
    function AllocHeap(AWords: Word; out APg, AAddr: Word): Boolean;
    function BiosScanSlotCount: Integer;
    function PayloadStride: Integer;
    function VisibleChanDumpCount: Integer;
    function FifoReadyWords: Word;
    function TimerScale: Word;
    function TimerPeriod: Word;
    function ScanDivider: Word;
  public
    constructor Create(ACli: TMic140v2Tcp; AChCnt: Integer; AFreq: Double;
      AUpdMs: Cardinal; ADevRev, ADevSubRev: Word;
      const ARangeIndexes: array of Integer;
      const AUserCommutIndexes: array of Integer;
      const ABoardCommutIndexes: array of Integer);
    { Полный цикл: stop → RESET → timer → FIFO → каналы → SCAN_SET_CHANS. }
    function ProgramScan(out AErr: string): Boolean;
    function LastTiming: TRecorderMic140Timing;
    property LastFifoReadyWords: Word read fLastFifoReady;
    property LastValAddr: Word read fLastValAddr;
    property LastPayloadStride: Integer read fLastPayloadStride;
    function LastExpectedMessageWords: Word;
  end;

function Mic140v2DebugTinSlotCount: Integer;
procedure Mic140v2SetDebugTinSlotCount(ACount: Integer);
function Mic140v2DebugFifoStride: Integer;
procedure Mic140v2SetDebugFifoStride(AStride: Integer);
function Mic140v2DebugBank2DelayMul: Integer;
procedure Mic140v2SetDebugBank2DelayMul(AMul: Integer);
function Mic140v2DebugChanDumpCount: Integer;
procedure Mic140v2SetDebugChanDumpCount(ACount: Integer);
function Mic140v2DebugFifoSamples: Integer;
procedure Mic140v2SetDebugFifoSamples(ACount: Integer);
function Mic140v2DebugRecorderProfile: Boolean;
procedure Mic140v2ApplyRecorderWireProfile;
function Mic140v2DebugGroundPointers: Boolean;
procedure Mic140v2SetDebugGroundPointers(AEnabled: Boolean);

implementation

uses
  uRecorderMic140v2Diag, uRecorderDebugLog;

var
  GMic140v2DebugTinSlotCount: Integer = -1;
  GMic140v2DebugFifoStride: Integer = -1;
  GMic140v2DebugBank2DelayMul: Integer = -1;
  GMic140v2DebugChanDumpCount: Integer = -1;
  GMic140v2DebugFifoSamples: Integer = -1;
  GMic140v2DebugGroundPointers: Integer = -1;

function Mic140v2DebugTinSlotCount: Integer;
begin
  if GMic140v2DebugTinSlotCount >= 0 then
    Result := GMic140v2DebugTinSlotCount
  else
    Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_TIN_SLOTS'), 0);
  if Result < 0 then
    Result := 0;
  if Result > MIC140TemperatureChannelCount then
    Result := MIC140TemperatureChannelCount;
end;

procedure Mic140v2SetDebugTinSlotCount(ACount: Integer);
begin
  GMic140v2DebugTinSlotCount := ACount;
  if GMic140v2DebugTinSlotCount < 0 then
    GMic140v2DebugTinSlotCount := 0;
  if GMic140v2DebugTinSlotCount > MIC140TemperatureChannelCount then
    GMic140v2DebugTinSlotCount := MIC140TemperatureChannelCount;
end;

function Mic140v2DebugFifoStride: Integer;
begin
  if GMic140v2DebugFifoStride >= 0 then
    Result := GMic140v2DebugFifoStride
  else
    Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_FIFO_STRIDE'), -1);
end;

procedure Mic140v2SetDebugFifoStride(AStride: Integer);
begin
  GMic140v2DebugFifoStride := AStride;
end;

function Mic140v2DebugBank2DelayMul: Integer;
begin
  if GMic140v2DebugBank2DelayMul >= 0 then
    Result := GMic140v2DebugBank2DelayMul
  else
    Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_BANK2_DELAY_MUL'), 1);
  if Result < 1 then
    Result := 1;
  if Result > 16 then
    Result := 16;
end;

procedure Mic140v2SetDebugBank2DelayMul(AMul: Integer);
begin
  GMic140v2DebugBank2DelayMul := AMul;
  if GMic140v2DebugBank2DelayMul < 1 then
    GMic140v2DebugBank2DelayMul := 1;
  if GMic140v2DebugBank2DelayMul > 16 then
    GMic140v2DebugBank2DelayMul := 16;
end;

function Mic140v2DebugChanDumpCount: Integer;
begin
  if GMic140v2DebugChanDumpCount >= 0 then
    Result := GMic140v2DebugChanDumpCount
  else
    Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_CHAN_DUMP_COUNT'), -1);
end;

procedure Mic140v2SetDebugChanDumpCount(ACount: Integer);
begin
  GMic140v2DebugChanDumpCount := ACount;
end;

function Mic140v2DebugFifoSamples: Integer;
begin
  if GMic140v2DebugFifoSamples >= 0 then
    Result := GMic140v2DebugFifoSamples
  else
    Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_FIFO_SAMPLES'), -1);
end;

procedure Mic140v2SetDebugFifoSamples(ACount: Integer);
begin
  GMic140v2DebugFifoSamples := ACount;
end;

function Mic140v2DebugRecorderProfile: Boolean;
begin
  Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_RECORDER_PROFILE'), 0) <> 0;
end;

procedure Mic140v2ApplyRecorderWireProfile;
begin
  Mic140v2SetDebugFifoStride(51);
  Mic140v2SetDebugChanDumpCount(48);
  Mic140v2SetDebugFifoSamples(3);
end;

function Mic140v2DebugUseMe048V2: Boolean;
begin
  Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_ME048_V2'), 0) <> 0;
end;

function Mic140v2DebugGroundPointers: Boolean;
begin
  { [ORIG] MIC140_48mod flag_chan_ground=1: ground desc ptr before each channel ptr. }
  if GMic140v2DebugGroundPointers >= 0 then
    Result := GMic140v2DebugGroundPointers <> 0
  else
    Result := StrToIntDef(GetEnvironmentVariable('MIC140_DEBUG_GROUND_POINTERS'), 0) <> 0;
end;

procedure Mic140v2SetDebugGroundPointers(AEnabled: Boolean);
begin
  if AEnabled then
    GMic140v2DebugGroundPointers := 1
  else
    GMic140v2DebugGroundPointers := 0;
end;

const
  { [ORIG] MIC140_48mod.cpp AInNum[] — физический номер AIn для code_chanAIn_48[] }
  CAInNum48: array[0..47] of Word =
    (24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
     36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
     23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12,
     11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);
  { [ORIG] MIC140_48mod reg_MC114 для AIn: AMP2+AMP4+AMP16+K1 → типично $0100 }
  CNormalDesc = Word($0100);
  { [ORIG] ground descriptor: MUX_IN1=1 → $0110 }
  CGroundDesc = Word($0110);
  { [ORIG] MIC140_48mod MASK_CHAN_LEFT — TIn ptr с битом 15 }
  CMaskChanLeft = Word($8000);
  CMic140v2DevRev12 = 12;
  CMic140TInNum: array[0..11] of Integer =
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
  CMic140TInNumSubRev1: array[0..11] of Integer =
    (4, 3, 2, 1, 0, 5, 6, 7, 8, 9, 10, 11);

function Mic140v2WordsPreview(const AWords: TMic140v2WordBuf;
  AFirst, ACount: Integer): string;
var
  I: Integer;
  LEnd: Integer;
begin
  Result := '';
  if (AFirst < 0) or (ACount <= 0) or (AFirst >= Length(AWords)) then
    Exit;
  LEnd := Min(Length(AWords), AFirst + ACount);
  for I := AFirst to LEnd - 1 do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + IntToStr(AWords[I]);
  end;
end;

constructor TMic140v2ScanProgrammer.Create(ACli: TMic140v2Tcp; AChCnt: Integer;
  AFreq: Double; AUpdMs: Cardinal; ADevRev, ADevSubRev: Word;
  const ARangeIndexes: array of Integer;
  const AUserCommutIndexes: array of Integer;
  const ABoardCommutIndexes: array of Integer);
var
  I: Integer;
begin
  inherited Create;
  fCli := ACli;
  fChCnt := AChCnt;
  fFreq := Mic140v2NormalizeFrequency(AFreq);
  fUpdMs := AUpdMs;
  fDevRev := ADevRev;
  fDevSubRev := ADevSubRev;
  fLastFifoReady := 0;
  fLastValAddr := 0;
  fLastPayloadStride := 0;
  SetLength(fRangeIndexes, fChCnt);
  SetLength(fCommutIndexes, fChCnt);
  SetLength(fBoardCommutIndexes, fChCnt);
  for I := 0 to fChCnt - 1 do
  begin
    if I <= High(ARangeIndexes) then
      fRangeIndexes[I] := ARangeIndexes[I]
    else
      fRangeIndexes[I] := CMic140Range100mV;
    if I <= High(AUserCommutIndexes) then
      fCommutIndexes[I] := AUserCommutIndexes[I]
    else
      fCommutIndexes[I] := CMic140ChannelCommutIn;
    if I <= High(ABoardCommutIndexes) then
      fBoardCommutIndexes[I] := ABoardCommutIndexes[I]
    else
      fBoardCommutIndexes[I] := CMic140ChannelCommutIn;
  end;
end;

function TMic140v2ScanProgrammer.LastExpectedMessageWords: Word;
begin
  Result := CMic140LegacyBiosHeaderWords + fLastFifoReady;
end;

function TMic140v2ScanProgrammer.AllocBuf(AWords: Word; out APg, AAddr: Word): Boolean;
begin
  APg := 0;
  AAddr := fBufCur;
  Result := (AWords > 0) and
    (LongWord(fBufCur) + AWords - 1 <= CMic140LegacyDmBufferEnd);
  if Result then
    Inc(fBufCur, AWords);
end;

function TMic140v2ScanProgrammer.AllocHeap(AWords: Word; out APg, AAddr: Word): Boolean;
begin
  APg := 0;
  AAddr := fHeapCur;
  Result := (AWords > 0) and
    (LongWord(fHeapCur) + AWords - 1 <= CMic140LegacyDmHeapEnd);
  if Result then
    Inc(fHeapCur, AWords);
end;

function TMic140v2ScanProgrammer.BiosScanSlotCount: Integer;
begin
  { [ORIG] MIC140_48mod flag_allch_sampl: GetMaxCountChanAIn + GetMaxCountChanTIn }
  Result := fChCnt + Mic140v2DebugTinSlotCount;
end;

function TMic140v2ScanProgrammer.PayloadStride: Integer;
var
  lStride: Integer;
begin
  {
    [ORIG] FIFO stride (слов/строка) ≠ число BIOS-слотов:
      AIn ptr без MASK → в FIFO;
      TIn ptr с MASK_CHAN_LEFT → в DM, если stride=48;
      stride=51 → AIn+TIn в одной строке (как Recorder / DeviceCore).
  }
  lStride := Mic140v2DebugFifoStride;
  if lStride <= 0 then
  begin
    { Стабильный стенд: fifo=48; Recorder wire: stride=51 (см. --recorder-wire) }
    if Mic140v2DebugRecorderProfile then
      Result := fChCnt + Mic140v2DebugTinSlotCount
    else
      Result := fChCnt;
  end
  else if lStride = 48 then
    Result := fChCnt
  else if lStride = 51 then
    Result := fChCnt + MIC140TemperatureChannelCount
  else
    Result := lStride;
end;

function TMic140v2ScanProgrammer.VisibleChanDumpCount: Integer;
begin
  {
    [ORIG] m_ChanDump[2] — видимая ширина строки для BIOS.
    Recorder: 51 при flag_allch_sampl (48 AIn + 3 TIn в одной FIFO-строке).
  }
  if Mic140v2DebugChanDumpCount >= 0 then
    Result := Mic140v2DebugChanDumpCount
  else if Mic140v2DebugRecorderProfile then
    Result := PayloadStride
  else
    Result := fChCnt;
end;

function TMic140v2ScanProgrammer.FifoReadyWords: Word;
var
  ch, maxW, readyPerCh, tgt, lSamples: Integer;
  upd: Cardinal;
begin
  {
    [ORIG] Modscn::CreateBiosCCScanBuf — sizeready = half FIFO in words;
           ScanMIC140::GetChanMaxFifoSizeCC() / GetCountChanBios() (= channels.size()).
    Recorder wire (2026-07-01): msgWords=163 → 3 строки × stride 51 @ 10 Гц / 200 мс.
  }
  ch := PayloadStride;
  if ch <= 0 then
    ch := MIC140DefaultChannelCount;
  maxW := CMic140LegacyDmBufferEnd - CMic140LegacyDmBufferBegin + 1;
  upd := fUpdMs;
  if upd = 0 then
    upd := 200;
  tgt := Round(fFreq * upd / 1000.0);
  if tgt < 1 then
    tgt := 1;
  readyPerCh := (maxW div 2) div ch;
  if readyPerCh <= 0 then
    readyPerCh := 1;
  lSamples := readyPerCh;
  if tgt < lSamples then
    lSamples := tgt;
  if Mic140v2DebugFifoSamples > 0 then
    lSamples := Mic140v2DebugFifoSamples;
  if lSamples > 1024 then
    lSamples := 1024;
  Result := Word(lSamples * PayloadStride);
end;

function TMic140v2ScanProgrammer.TimerScale: Word;
begin
  { [ORIG] Mc114mod::GetScale — для 1 Гц scale=2, иначе 1 (scale_period_16000) }
  if SameValue(fFreq, 1.0, 0.001) then
    Result := 2
  else
    Result := 1;
end;

function TMic140v2ScanProgrammer.TimerPeriod: Word;
begin
  { [ORIG] Mc114mod TIMER_PERIOD=640, GetPeriod() }
  Result := CMic140LegacyTimerPeriod;
end;

function TMic140v2ScanProgrammer.ScanDivider: Word;
begin
  { [ORIG] Mc114mod::GetTimerCount / ModuleMIC140_96::GetMainScanDivider → scale_period_16000[].count }
  if SameValue(fFreq, 1.0, 0.001) then
    Result := 25000
  else if SameValue(fFreq, 2.0, 0.001) then
    Result := 25000
  else if SameValue(fFreq, 5.0, 0.001) then
    Result := 10000
  else if SameValue(fFreq, 10.0, 0.001) then
    Result := 5000
  else if SameValue(fFreq, 20.0, 0.001) then
    Result := 2500
  else if SameValue(fFreq, 25.0, 0.001) then
    Result := 2000
  else if SameValue(fFreq, 50.0, 0.001) then
    Result := 1000
  else
    Result := 500;
end;

function TMic140v2ScanProgrammer.LastTiming: TRecorderMic140Timing;
begin
  Result := Mic140v2TimingForFrequency(fFreq, fChCnt,
    Mic140v2DebugGroundPointers);
end;

function TMic140v2ScanProgrammer.ProgramScan(out AErr: string): Boolean;
var
  i, intCnt, descCnt, ptrCnt, tIdx, lInternalTempIdx: Integer;
  args, desc, chanDump, reply: TMic140v2WordBuf;
  pg, fifoAddr, fifoDesc, scanDesc, scanChan, valAddr, descAddr: Word;
  fifoPg, fifoReady, fifoCapacity, me0, me1, lRegDesc: Word;
  stopErr: string;
  tim: TRecorderMic140Timing;
  lRev2: Boolean;
  lChannelDelaySport: Word;
begin
  Result := False;
  AErr := '';
  if fCli = nil then
  begin
    AErr := 'TCP client missing';
    Exit;
  end;

  fBufCur := CMic140LegacyDmBufferBegin;
  fHeapCur := CMic140LegacyDmHeapBegin;
  tim := Mic140v2TimingForFrequency(fFreq, fChCnt, Mic140v2DebugGroundPointers);
  intCnt := BiosScanSlotCount;
  fLastPayloadStride := PayloadStride;
  fifoReady := FifoReadyWords;
  fifoCapacity := 2 * fifoReady;
  fLastFifoReady := fifoReady;
  lRev2 := (fDevRev > 0) and (fDevRev < CMic140v2DevRev12);
  lChannelDelaySport := tim.LegacyChannelDelaySport;

  fCli.TimeoutMs := CMic140LegacyCommandTimeoutMs;
  { [LNX] явный StopScan перед программированием — сиротский scan после обрыва TCP }
  if not Mic140v2StopScan(fCli, stopErr) then
    Mic140v2Log(Format('[MIC140v2] pre-program stop: %s', [stopErr]));
  fCli.ClearBufferedPackets;

  if not fCli.CallCommand(CMic140LegacyCmdResetScanMain, nil, 0, reply, AErr) then
  begin
    { [ORIG] Ccdevice::OnResetScanMain / CMD_RESETSCANMAIN }
    AErr := 'RESETSCANMAIN: ' + AErr;
    Exit;
  end;

  SetLength(args, 2);
  args[0] := TimerScale - 1;
  args[1] := TimerPeriod - 1;
  if not fCli.CallCommand(CMic140LegacyCmdConfigScanMain, args, 0, reply, AErr) then
  begin
    { [ORIG] ModuleMIC140_96::WriteConfig → ConfigScanMain(scale-1, period-1) }
    AErr := 'CONFIGSCANMAIN: ' + AErr;
    Exit;
  end;

  if not AllocHeap(CMic140LegacyBiosScanContextWords, pg, scanDesc) then
  begin
    AErr := 'scan context alloc failed';
    Exit;
  end;
  SetLength(args, 5);
  args[0] := CMic140LegacyTypeMic140;
  args[1] := CMic140LegacyScanId;
  args[2] := ScanDivider;
  args[3] := scanDesc;
  args[4] := pg;
  if not fCli.CallCommand(CMic140LegacyCmdAppendScanMain, args, 0, reply, AErr) then
  begin
    { [ORIG] Modscn::CreateInternalScan(type, scan_id, divider, ctx_addr) }
    AErr := 'APPENDSCANMAIN: ' + AErr;
    Exit;
  end;

  SetLength(args, 2);
  args[0] := CMic140LegacyScanId;
  args[1] := 0;
  if not fCli.CallCommand(CMic140LegacyCmdSetStateScan, args, 0, reply, AErr) then
  begin
    AErr := 'SETSTATESCAN: ' + AErr;
    Exit;
  end;

  if not AllocBuf(fifoCapacity, fifoPg, fifoAddr) then
  begin
    AErr := 'FIFO buffer alloc failed';
    Exit;
  end;
  if not AllocHeap(CMic140LegacyBiosScanBufferDescWords, pg, fifoDesc) then
  begin
    AErr := 'FIFO desc alloc failed';
    Exit;
  end;
  SetLength(args, CMic140LegacyBiosScanBufferDescWords);
  args[0] := 0;
  args[1] := CMic140LegacyScanId;
  args[2] := fifoAddr;
  args[3] := fifoAddr;
  args[4] := fifoAddr;
  args[5] := fifoPg;
  args[6] := fifoCapacity;
  args[7] := fifoReady;
  args[8] := 0;
  args[9] := 0;
  if not fCli.WriteDmWords(fifoDesc, args, AErr) then
  begin
    { [ORIG] Modscn::CreateBiosCCScanBuf — tmp[6]=2*size, tmp[7]=size (sizeready) }
    AErr := 'FIFO desc write: ' + AErr;
    Exit;
  end;
  SetLength(args, 3);
  args[0] := CMic140LegacyScanId;
  args[1] := fifoDesc;
  args[2] := 0;
  if not fCli.CallCommand(CMic140LegacyCmdScanSetBuff, args, 0, reply, AErr) then
  begin
    AErr := 'SCAN_SET_BUFF: ' + AErr;
    Exit;
  end;

  if not AllocHeap(fChCnt + MIC140v2InternalTemperatureChannelCount, pg, valAddr) then
  begin
    AErr := 'value area alloc failed';
    Exit;
  end;
  fLastValAddr := valAddr;
  descCnt := intCnt + 1;
  if not AllocHeap(descCnt * CMic140LegacyDescChanWords, pg, descAddr) then
  begin
    AErr := 'channel desc alloc failed';
    Exit;
  end;

  SetLength(desc, descCnt * CMic140LegacyDescChanWords);
  if Mic140v2DebugUseMe048V2 and ((fDevRev >= CMic140v2DevRev12) or lRev2) then
    Mic140v2PackLevel0Me04848v2(lRev2, me0, me1)
  else
  begin
    me0 := Mic140v2Level0Code;
    me1 := Mic140v2Level0Code;
  end;
  { [ORIG] ground: code_level0mV → code_ME048[1], [0]=0 }
  desc[0] := me0;
  desc[1] := me1;
  desc[2] := CGroundDesc;
  desc[3] := tim.LegacyGroundDelaySport - 1;
  desc[4] := CMic140LegacyMaskGroundChannel;

  for i := 0 to intCnt - 1 do
  begin
    if i < fChCnt then
    begin
      if i <= High(CAInNum48) then
      begin
        { [ORIG] MIC140_48v2mod: code_chanAIn[AInGetChanN(ui)%48] via AInNum[].
          CAInNum48[ui] = AInNum[ui]. Табличная PackMe04848, не BuildAInCode48v2. }
        if Mic140v2DebugUseMe048V2 and ((fDevRev >= CMic140v2DevRev12) or lRev2) then
          Mic140v2PackMe04848v2(CAInNum48[i], lRev2, me0, me1)
        else
          Mic140v2Me048ForPhysicalChannelWithUserCommut(CAInNum48[i],
            fCommutIndexes[i], me0, me1);
      end
      else
      begin
        me0 := 0;
        me1 := 0;
      end;
      desc[(i + 1) * CMic140LegacyDescChanWords + 0] := me0;
      desc[(i + 1) * CMic140LegacyDescChanWords + 1] := me1;
      desc[(i + 1) * CMic140LegacyDescChanWords + 2] :=
        Mic140v2AInRegDesc(fRangeIndexes[i], fBoardCommutIndexes[i]);
      if (i >= 24) and (Mic140v2DebugBank2DelayMul > 1) then
        desc[(i + 1) * CMic140LegacyDescChanWords + 3] :=
          Word(lChannelDelaySport * Mic140v2DebugBank2DelayMul - 1)
      else
        desc[(i + 1) * CMic140LegacyDescChanWords + 3] := lChannelDelaySport - 1;
      { [ORIG] MIC140_48mod: user AIn — mask_chan_left=0, ptr=var_addr+num_chan }
      desc[(i + 1) * CMic140LegacyDescChanWords + 4] := Word(valAddr + i);
    end
    else
    begin
      tIdx := i - fChCnt;
      lInternalTempIdx := Mic140v2TInDmWordOffset(tIdx, fDevSubRev);

      if (fDevRev >= CMic140v2DevRev12) or lRev2 then
      begin
        if fDevSubRev = 1 then
        begin
          Mic140v2PackTInMe04848v2(lInternalTempIdx, lRev2, me0, me1);
          lRegDesc := Mic140v2TInDesc48v2(lInternalTempIdx);
        end
        else if tIdx = 0 then
          Mic140v2PackTInMe04848(1, me0, me1)
        else if tIdx = 1 then
          Mic140v2PackTInMe04848(0, me0, me1)
        else
          Mic140v2PackTInMe04848(tIdx, me0, me1);

        if (fDevSubRev <> 1) and (tIdx = 2) then
          lRegDesc := $0120
        else if fDevSubRev <> 1 then
          lRegDesc := $0100;
      end
      else
      begin
        Mic140v2PackTInMe04848(tIdx, me0, me1);
        lRegDesc := Mic140v2TInDesc48(tIdx);
      end;

      desc[(i + 1) * CMic140LegacyDescChanWords + 0] := me0;
      desc[(i + 1) * CMic140LegacyDescChanWords + 1] := me1;
      desc[(i + 1) * CMic140LegacyDescChanWords + 2] := lRegDesc;
      desc[(i + 1) * CMic140LegacyDescChanWords + 3] := lChannelDelaySport - 1;
      desc[(i + 1) * CMic140LegacyDescChanWords + 4] :=
        Word(CMaskChanLeft or (valAddr + fChCnt + lInternalTempIdx));
    end;
  end;

  if not fCli.WriteDmWords(descAddr, desc, AErr) then
  begin
    AErr := 'desc DM write: ' + AErr;
    Exit;
  end;

  { [ORIG] m_ChanDump[2]=channels.Size(); internal TIn в BIOS, но видимых AIn = 48 }
  if Mic140v2DebugGroundPointers then
  begin
    { [ORIG] flag_chan_ground=1: ground desc ptr, затем channel desc ptr }
    ptrCnt := intCnt * 2;
    SetLength(chanDump, CMic140LegacyStartDescChanWords + ptrCnt);
    chanDump[0] := tim.LegacyAverageDelaySport - 1;
    chanDump[1] := tim.AverageSampleCount;
    chanDump[2] := Word(VisibleChanDumpCount);
    for i := 0 to intCnt - 1 do
    begin
      chanDump[CMic140LegacyStartDescChanWords + i * 2] := descAddr;
      chanDump[CMic140LegacyStartDescChanWords + i * 2 + 1] :=
        Word(descAddr + (i + 1) * CMic140LegacyDescChanWords);
    end;
  end
  else
  begin
    ptrCnt := intCnt;
    SetLength(chanDump, CMic140LegacyStartDescChanWords + ptrCnt);
    chanDump[0] := tim.LegacyAverageDelaySport - 1;
    chanDump[1] := tim.AverageSampleCount;
    chanDump[2] := Word(VisibleChanDumpCount);
    for i := 0 to intCnt - 1 do
      chanDump[CMic140LegacyStartDescChanWords + i] :=
        Word(descAddr + (i + 1) * CMic140LegacyDescChanWords);
  end;

  RecorderDebugLog(Format(
    '[MIC140v2 scan] rev=%d.%d rev2=%s slots=%d ptrs=%d val=0x%.4x desc=0x%.4x fifo=0x%.4x ready=%d capacity=%d fifoStride=%d chanDelay=%d ground=%s timer(scale=%d period=%d div=%d) desc0=[%s] desc1=[%s] desc25=[%s] desc48=[%s] ptrHead=[%s]',
    [fDevRev, fDevSubRev, BoolToStr(lRev2, True), intCnt, ptrCnt, valAddr, descAddr, fifoAddr, fifoReady, fifoCapacity, fLastPayloadStride,
     lChannelDelaySport, BoolToStr(Mic140v2DebugGroundPointers, True), TimerScale, TimerPeriod, ScanDivider,
     Mic140v2WordsPreview(desc, 0, 5),
     Mic140v2WordsPreview(desc, CMic140LegacyDescChanWords, 5),
     Mic140v2WordsPreview(desc, 25 * CMic140LegacyDescChanWords, 5),
     Mic140v2WordsPreview(desc, 48 * CMic140LegacyDescChanWords, 10),
     Mic140v2WordsPreview(chanDump, 0, 12)]));

  if not AllocHeap(CMic140LegacyDescChanWords, pg, scanChan) then
  begin
    AErr := 'scan chan desc alloc failed';
    Exit;
  end;
  if not AllocHeap(Length(chanDump), pg, scanDesc) then
  begin
    AErr := 'chan ptr alloc failed';
    Exit;
  end;
  if not fCli.WriteDmWords(scanDesc, chanDump, AErr) then
  begin
    AErr := 'chan ptr write: ' + AErr;
    Exit;
  end;

  SetLength(args, 6);
  args[0] := CMic140LegacyScanId;
  args[1] := 0;
  args[2] := scanDesc;
  args[3] := ptrCnt;
  args[4] := scanChan;
  args[5] := pg;
  if not fCli.CallCommand(CMic140LegacyCmdAddChannelModule, args, 0, reply, AErr) then
  begin
    { [ORIG] mic140_96scn::ChannelsToBios CMD_ADDCHANNELMODULE, tmp[3]=ptrCount }
    AErr := 'ADDCHANNELMODULE: ' + AErr;
    Exit;
  end;

  SetLength(args, 4);
  args[0] := CMic140LegacyScanId;
  args[1] := 1;
  args[2] := scanChan;
  args[3] := pg;
  if not fCli.CallCommand(CMic140LegacyCmdScanSetChans, args, 0, reply, AErr) then
  begin
    AErr := 'SCAN_SET_CHANS: ' + AErr;
    Exit;
  end;

  Mic140v2Log(Format(
    '[MIC140v2] scan OK slots=%d ptrs=%d fifoStride=%d fifoReady=%d msgWords=%d',
    [intCnt, ptrCnt, fLastPayloadStride, fifoReady, LastExpectedMessageWords]));
  Result := True;
end;

end.
