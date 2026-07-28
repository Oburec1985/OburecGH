unit uRecorderMic140v2Scan;

{
  Программирование BIOS-скана MIC-140 (эталон: ModuleMIC140_48 + ScanMIC140 + Modscn).

  Отладочные оверрайды (tin-slots, bank2-delay, chan-dump-count, ME048 v2) — только
  в Tests/Mic140ProtocolDebug/Driver/uRecorderMic140v2Scan.pas (shadow unit).
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
    fV3Profile: Boolean;
    fGroundEnabled: Boolean;
    fTemperatureChannelCount: Integer;
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
    function FifoReadyWords: Word;
    function TimerScale: Word;
    function TimerPeriod: Word;
    function ScanDivider: Word;
  public
    constructor Create(ACli: TMic140v2Tcp; AChCnt: Integer; AFreq: Double;
      AUpdMs: Cardinal; ADevRev, ADevSubRev: Word;
      const ARangeIndexes: array of Integer;
      const AUserCommutIndexes: array of Integer;
      const ABoardCommutIndexes: array of Integer;
      AV3Profile, AGroundEnabled: Boolean);
    { Полный цикл: stop → RESET → timer → FIFO → каналы → SCAN_SET_CHANS. }
    function ProgramScan(out AErr: string): Boolean;
    function LastTiming: TRecorderMic140Timing;
    property LastFifoReadyWords: Word read fLastFifoReady;
    function LastExpectedMessageWords: Word;
    property LastValAddr: Word read fLastValAddr;
    property LastPayloadStride: Integer read fLastPayloadStride;
    property TemperatureChannelCount: Integer read fTemperatureChannelCount;
  end;

implementation

uses
  uRecorderMic140v2Diag, uRecorderDebugLog;

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
  const ABoardCommutIndexes: array of Integer;
  AV3Profile, AGroundEnabled: Boolean);
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
  fV3Profile := AV3Profile;
  fGroundEnabled := AGroundEnabled;
  if fV3Profile then
    fTemperatureChannelCount := MIC140v3VisibleTemperatureChannelCount
  else
    fTemperatureChannelCount := MIC140TemperatureChannelCount;
  fLastFifoReady := 0;
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
  { [ORIG] flag_allch_sampl: GetMaxCountChanAIn + GetMaxCountChanTIn (MIC140_48mod) }
  Result := fChCnt + fTemperatureChannelCount;
end;

function TMic140v2ScanProgrammer.PayloadStride: Integer;
begin
  { Стабильный FIFO: 48 AIn; TIn — READMEMDM 114 (см. protocol/05_data_stream.md) }
  Result := fChCnt + fTemperatureChannelCount;
end;

function TMic140v2ScanProgrammer.FifoReadyWords: Word;
var
  ch, maxW, readyPerCh, tgt: Integer;
  upd: Cardinal;
begin
  {
    [ORIG] Modscn::CreateBiosCCScanBuf — sizeready = half FIFO in words;
           ScanMIC140::GetChanMaxFifoSizeCC() / GetCountChanBios() (= channels.size()).
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
  if tgt < readyPerCh then
    readyPerCh := tgt;
  if readyPerCh > 1024 then
    readyPerCh := 1024;
  Result := Word(readyPerCh * PayloadStride);
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
  Result := Mic140v2TimingForFrequency(fFreq, fChCnt, fGroundEnabled,
    fTemperatureChannelCount);
end;

function TMic140v2ScanProgrammer.ProgramScan(out AErr: string): Boolean;
var
  i, intCnt, descCnt, ptrCnt, tIdx, lInternalTempIdx, lTempValueIdx,
    lDescBase: Integer;
  args, desc, chanDump, reply: TMic140v2WordBuf;
  pg, fifoAddr, fifoDesc, scanDesc, scanChan, valAddr, descAddr: Word;
  fifoPg, fifoReady, fifoCapacity, me0, me1, lRegDesc, scanChanPg: Word;
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
  tim := Mic140v2TimingForFrequency(fFreq, fChCnt, fGroundEnabled,
    fTemperatureChannelCount);
  intCnt := BiosScanSlotCount;
  fifoReady := FifoReadyWords;
  fifoCapacity := 2 * fifoReady;
  fLastFifoReady := fifoReady;
  lRev2 := (fDevRev > 0) and (fDevRev < CMic140v2DevRev12);
  lChannelDelaySport := tim.LegacyChannelDelaySport;

  fCli.TimeoutMs := CMic140LegacyCommandTimeoutMs;
  { [LNX] явный StopScan перед программированием — сиротский scan после обрыва TCP }
  SetLength(args, 2);
  args[0] := TimerScale - 1;
  args[1] := TimerPeriod - 1;
  if not fCli.CallCommand(CMic140LegacyCmdConfigScanMain, args, 0, reply, AErr) then
  begin
    { [ORIG] ModuleMIC140_96::WriteConfig → ConfigScanMain(scale-1, period-1) }
    AErr := 'CONFIGSCANMAIN: ' + AErr;
    Exit;
  end;
  { В дампе Recorder один таймер задаётся дважды: контроллером и модулем. }
  if not fCli.CallCommand(CMic140LegacyCmdConfigScanMain, args, 0, reply,
    AErr) then
  begin
    AErr := 'CONFIGSCANMAIN module pass: ' + AErr;
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
  if fGroundEnabled then
    lDescBase := 1
  else
    lDescBase := 0;
  descCnt := intCnt + lDescBase;
  if not AllocHeap(descCnt * CMic140LegacyDescChanWords, pg, descAddr) then
  begin
    AErr := 'channel desc alloc failed';
    Exit;
  end;

  SetLength(desc, descCnt * CMic140LegacyDescChanWords);
  if fGroundEnabled then
  begin
    Mic140v2PackLevel0Me04848v2(lRev2, me0, me1);
    desc[0] := me0;
    desc[1] := me1;
    desc[2] := CGroundDesc;
    desc[3] := tim.LegacyGroundDelaySport - 1;
    desc[4] := CMic140LegacyMaskGroundChannel;
  end;

  for i := 0 to intCnt - 1 do
  begin
    if i < fChCnt then
    begin
      if (i <= High(CAInNum48)) and (fDevRev >= CMic140v2DevRev12) and
         (fCommutIndexes[i] = CMic140ChannelCommutIn) then
        Mic140v2PackMe04848v2(CAInNum48[i], lRev2, me0, me1)
      else if i <= High(CAInNum48) then
        Mic140v2Me048ForPhysicalChannelWithUserCommut(CAInNum48[i],
          fCommutIndexes[i], me0, me1)
      else
      begin
        me0 := 0;
        me1 := 0;
      end;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 0] := me0;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 1] := me1;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 2] :=
        Mic140v2AInRegDesc(fRangeIndexes[i], fBoardCommutIndexes[i]);
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 3] := lChannelDelaySport - 1;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 4] := Word(valAddr + i);
    end
    else
    begin
      tIdx := i - fChCnt;
      if fV3Profile and (fDevSubRev = 1) then
        lInternalTempIdx := tIdx + 5
      else
        lInternalTempIdx := Mic140v2TInDmWordOffset(tIdx, fDevSubRev);
      lTempValueIdx := lInternalTempIdx;

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

      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 0] := me0;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 1] := me1;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 2] := lRegDesc;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 3] := lChannelDelaySport - 1;
      desc[(i + lDescBase) * CMic140LegacyDescChanWords + 4] :=
        Word(valAddr + fChCnt + lTempValueIdx);
    end;
  end;

  Mic140v2Log(Format('[MIC140v2] write channel descriptors address=0x%.4x words=%d',
    [descAddr, Length(desc)]));
  if not fCli.WriteDmWords(descAddr, desc, AErr) then
  begin
    AErr := 'desc DM write: ' + AErr;
    Exit;
  end;

  { H45: без ground в ptr list. TIn ptr остаются (MASK → DM), chanDump[2]=48 AIn. }
  if fGroundEnabled then
    ptrCnt := intCnt * 2
  else
    ptrCnt := intCnt;
  SetLength(chanDump, CMic140LegacyStartDescChanWords + ptrCnt);
  chanDump[0] := tim.LegacyAverageDelaySport - 1;
  chanDump[1] := tim.AverageSampleCount;
  { [ORIG] m_ChanDump[2]=channels.Size() — visible user AIn count, not internal slot count. }
  chanDump[2] := Word(PayloadStride);
  { [ORIG] m_ChanDump[2]=channels.Size() — число пользовательских AIn }
  for i := 0 to intCnt - 1 do
    if fGroundEnabled then
    begin
      chanDump[CMic140LegacyStartDescChanWords + i * 2] := descAddr;
      chanDump[CMic140LegacyStartDescChanWords + i * 2 + 1] :=
        Word(descAddr + (i + lDescBase) * CMic140LegacyDescChanWords);
    end
    else
      chanDump[CMic140LegacyStartDescChanWords + i] :=
        Word(descAddr + (i + lDescBase) * CMic140LegacyDescChanWords);

  RecorderDebugLog(Format(
    '[MIC140v2 scan] rev=%d.%d rev2=%s slots=%d ptrs=%d val=0x%.4x desc=0x%.4x fifo=0x%.4x ready=%d capacity=%d stride=%d chanDelay=%d timer(scale=%d period=%d div=%d) desc0=[%s] desc1=[%s] desc48=[%s] ptrHead=[%s]',
    [fDevRev, fDevSubRev, BoolToStr(lRev2, True), intCnt, ptrCnt, valAddr, descAddr, fifoAddr, fifoReady, fifoCapacity, PayloadStride,
     lChannelDelaySport, TimerScale, TimerPeriod, ScanDivider,
     Mic140v2WordsPreview(desc, 0, 5),
     Mic140v2WordsPreview(desc, CMic140LegacyDescChanWords, 5),
     Mic140v2WordsPreview(desc, 48 * CMic140LegacyDescChanWords, 10),
     Mic140v2WordsPreview(chanDump, 0, 12)]));

  scanChanPg := 0;
  if not AllocHeap(CMic140LegacyModuleScanDescWords, scanChanPg, scanChan) then
  begin
    AErr := 'module scan desc alloc failed';
    Exit;
  end;
  pg := 0;
  if not AllocHeap(Length(chanDump), pg, scanDesc) then
  begin
    AErr := 'chan ptr alloc failed';
    Exit;
  end;
  Mic140v2Log(Format('[MIC140v2] write channel pointers address=0x%.4x words=%d',
    [scanDesc, Length(chanDump)]));
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
  args[5] := scanChanPg;
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
  args[3] := scanChanPg;
  if not fCli.CallCommand(CMic140LegacyCmdScanSetChans, args, 0, reply, AErr) then
  begin
    AErr := 'SCAN_SET_CHANS: ' + AErr;
    Exit;
  end;

  { Холодный прибор не начинает устойчивое преобразование от одного
    STARTSCANMAIN. Оригинальный Recorder после таблиц настраивает BIOS-сообщение
    и явно запускает АЦП. Адрес сообщения — первый свободный адрес heap. }
  SetLength(args, 3);
  args[0] := fHeapCur;
  args[1] := 0;
  args[2] := CMic140LegacyMessageBufferWords;
  if not fCli.CallCommand(CMic140LegacyCmdConfigMessage, args, 4, reply,
    AErr) then
  begin
    AErr := 'CONFIG_MESSAGE: ' + AErr;
    Exit;
  end;

  SetLength(args, 3);
  args[0] := 0;
  args[1] := 0;
  args[2] := 1;
  if not fCli.CallCommand(CMic140LegacyCmdConfigSyncStart, args, 0, reply,
    AErr) then
  begin
    AErr := 'CONFIG_SYNC_START: ' + AErr;
    Exit;
  end;

  SetLength(args, 1);
  args[0] := CMic140LegacyInitialStartTimer;
  if not fCli.CallCommand(CMic140LegacyCmdSetTimeoutStartTimer, args, 0,
    reply, AErr) then
  begin
    AErr := 'SET_TIMEOUTSTARTTIMER initial: ' + AErr;
    Exit;
  end;

  SetLength(args, 0);
  if not fCli.CallCommand(CMic140LegacyCmdStartTriggerAdc, args, 0, reply,
    AErr) then
  begin
    AErr := 'START_TRIGGERSTARTADC: ' + AErr;
    Exit;
  end;

  SetLength(args, 1);
  args[0] := CMic140LegacyRunStartTimer;
  if not fCli.CallCommand(CMic140LegacyCmdSetTimeoutStartTimer, args, 0,
    reply, AErr) then
  begin
    AErr := 'SET_TIMEOUTSTARTTIMER run: ' + AErr;
    Exit;
  end;
  { Это не таймаут транспорта: после START_TRIGGERSTARTADC прибору требуется
    около 4,2 с для запуска/успокоения АЦП. В Recorder программирование разных
    устройств надо выполнять параллельно в служебных задачах, чтобы ожидание
    одного прибора не блокировало UI и инициализацию остальных устройств. }
  Sleep(CMic140LegacyAdcStartSettleMs);

  Mic140v2Log(Format(
    '[MIC140v2] scan OK slots=%d ptrs=%d payloadStride=%d fifoReady=%d msgWords=%d val=0x%.4x message=0x%.4x',
    [intCnt, ptrCnt, PayloadStride, fifoReady, LastExpectedMessageWords,
     valAddr, fHeapCur]));
  fLastValAddr := valAddr;
  fLastPayloadStride := PayloadStride;
  Result := True;
end;

end.
