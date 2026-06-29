unit uRecorderMic140v2Scan;

{
  Программирование BIOS-скана MIC-140 (эталон: ModuleMIC140_48 + ScanMIC140 + Modscn).

  Порядок как в Recorder:
    StopScan → RESETSCANMAIN → CONFIGSCANMAIN → APPENDSCANMAIN → SETSTATESCAN
    → FIFO (CreateBiosCCScanBuf) → дескрипторы каналов → ADDCHANNELMODULE → SCAN_SET_CHANS

  Сверка windev-v3.9:
    MIC140_96_rce/MIC140_48mod.cpp   — ME048, AInNum, ground, TIn
    MIC140_96_rce/mic140_96scn.cpp   — ChannelsToBios, GetScanDivider
    mtc/Modscn.cpp                   — CreateInternalScan, CreateBiosCCScanBuf
    mtc/Mc114mod.cpp                 — scale_period_16000 (freq/divider/period)
    mtcEthernet81/Mc031ethernetifc.cpp — DM buffer с 0x522
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
    fBufCur: Word;
    fHeapCur: Word;
    fLastFifoReady: Word;
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
      AUpdMs: Cardinal; ADevRev, ADevSubRev: Word);
    { Полный цикл: stop → RESET → timer → FIFO → каналы → SCAN_SET_CHANS. }
    function ProgramScan(out AErr: string): Boolean;
    function LastTiming: TRecorderMic140Timing;
    property LastFifoReadyWords: Word read fLastFifoReady;
    function LastExpectedMessageWords: Word;
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
  AFreq: Double; AUpdMs: Cardinal; ADevRev, ADevSubRev: Word);
begin
  inherited Create;
  fCli := ACli;
  fChCnt := AChCnt;
  fFreq := Mic140v2NormalizeFrequency(AFreq);
  fUpdMs := AUpdMs;
  fDevRev := ADevRev;
  fDevSubRev := ADevSubRev;
  fLastFifoReady := 0;
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
  Result := fChCnt;
end;

function TMic140v2ScanProgrammer.PayloadStride: Integer;
begin
  Result := fChCnt;
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
  Result := Mic140v2TimingForFrequency(fFreq, fChCnt);
end;

function TMic140v2ScanProgrammer.ProgramScan(out AErr: string): Boolean;
var
  i, intCnt, descCnt, ptrCnt, tIdx: Integer;
  args, desc, chanDump, reply: TMic140v2WordBuf;
  pg, fifoAddr, fifoDesc, scanDesc, scanChan, valAddr, descAddr: Word;
  fifoPg, fifoReady, fifoCapacity, me0, me1: Word;
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
  tim := Mic140v2TimingForFrequency(fFreq, fChCnt);
  intCnt := BiosScanSlotCount;
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
  descCnt := intCnt + 1;
  if not AllocHeap(descCnt * CMic140LegacyDescChanWords, pg, descAddr) then
  begin
    AErr := 'channel desc alloc failed';
    Exit;
  end;

  SetLength(desc, descCnt * CMic140LegacyDescChanWords);
  me0 := Mic140v2Level0Code;
  me1 := Mic140v2Level0Code;
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
        Mic140v2Me048ForPhysicalChannel(CAInNum48[i], me0, me1)
      else
      begin
        me0 := 0;
        me1 := 0;
      end;
      desc[(i + 1) * CMic140LegacyDescChanWords + 0] := me0;
      desc[(i + 1) * CMic140LegacyDescChanWords + 1] := me1;
      desc[(i + 1) * CMic140LegacyDescChanWords + 4] := Word(valAddr + i);
    end
    else
    begin
      tIdx := i - fChCnt;
      Mic140v2PackTInMe04848v2(tIdx, lRev2, me0, me1);
      desc[(i + 1) * CMic140LegacyDescChanWords + 0] := me0;
      desc[(i + 1) * CMic140LegacyDescChanWords + 1] := me1;
      desc[(i + 1) * CMic140LegacyDescChanWords + 2] := Mic140v2TInDesc48v2(tIdx);
      desc[(i + 1) * CMic140LegacyDescChanWords + 4] :=
        Word(CMaskChanLeft or (valAddr + fChCnt + tIdx));
    end;
    if i < fChCnt then
    begin
      if i >= 24 then
        desc[(i + 1) * CMic140LegacyDescChanWords + 2] := CNormalDesc or $0010
      else
        desc[(i + 1) * CMic140LegacyDescChanWords + 2] := CNormalDesc;
    end;
    desc[(i + 1) * CMic140LegacyDescChanWords + 3] := lChannelDelaySport - 1;
  end;

  if not fCli.WriteDmWords(descAddr, desc, AErr) then
  begin
    AErr := 'desc DM write: ' + AErr;
    Exit;
  end;

  { The live rev14 stand is stable only with AIn descriptors in the scan pointer
    list. Alternating ground pointers reproduce Recorder's flag_chan_ground=1
    shape but corrupt the second bank after the first rows. }
  ptrCnt := intCnt;
  SetLength(chanDump, CMic140LegacyStartDescChanWords + ptrCnt);
  chanDump[0] := tim.LegacyAverageDelaySport - 1;
  chanDump[1] := tim.AverageSampleCount;
  chanDump[2] := Word(fChCnt);
  { [ORIG] m_ChanDump[2]=channels.Size() — число пользовательских AIn }
  for i := 0 to intCnt - 1 do
    chanDump[CMic140LegacyStartDescChanWords + i] :=
      Word(descAddr + (i + 1) * CMic140LegacyDescChanWords);

  RecorderDebugLog(Format(
    '[MIC140v2 scan] rev=%d.%d rev2=%s slots=%d ptrs=%d val=0x%.4x desc=0x%.4x fifo=0x%.4x ready=%d capacity=%d stride=%d chanDelay=%d timer(scale=%d period=%d div=%d) desc0=[%s] desc1=[%s] desc48=[%s] ptrHead=[%s]',
    [fDevRev, fDevSubRev, BoolToStr(lRev2, True), intCnt, ptrCnt, valAddr, descAddr, fifoAddr, fifoReady, fifoCapacity, PayloadStride,
     lChannelDelaySport, TimerScale, TimerPeriod, ScanDivider,
     Mic140v2WordsPreview(desc, 0, 5),
     Mic140v2WordsPreview(desc, CMic140LegacyDescChanWords, 5),
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
    '[MIC140v2] scan OK slots=%d ptrs=%d payloadStride=%d fifoReady=%d msgWords=%d',
    [intCnt, ptrCnt, PayloadStride, fifoReady, LastExpectedMessageWords]));
  Result := True;
end;

end.
