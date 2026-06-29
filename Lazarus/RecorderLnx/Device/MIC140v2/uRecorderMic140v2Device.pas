unit uRecorderMic140v2Device;

{
  MIC-140 v2: IMic140Device, UsesRawRing=True.
  Ядро: Protocol / Scan / Stream / RawRing. Utils — MIC140v2/utils/.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants,
  uRecorderDeviceInterfaces, uRecorderMic140DeviceApi, uRecorderTags,
  uRecorderMic140v2WireTypes,
  uRecorderMic140v2Protocol, uRecorderMic140v2Consts, uRecorderMic140v2Timing,
  uRecorderMic140v2Scan, uRecorderMic140v2Stream, uRecorderMic140v2Helper,
  uRecorderMic140v2Diag;

type
  TRecorderMic140v2Device = class(TInterfacedObject, IMic140Device)
  private
    fId, fHost: string;
    fPort: Word;
    fChCnt: Integer;
    fFreq: Double;
    fUpdMs: Cardinal;
    fNode: Integer;
    fState: TRecorderDeviceState;
    fStop: Boolean;
    fScanOn: Boolean;
    fCli: TMic140v2Tcp;
    fFw: TMic140v2Firmware;
    fHwSer: Integer;
    fExpDataWords: Word;
    fExpMsgWords: Word;
    fCh: TRecorderDeviceChannelArray;
    fStr: TMic140v2StreamState;
    fAux: TMic140AuxTemperatureBlock;
    procedure BuildChannels;
    function ScanStride: Integer;
    function ProbeScan: Boolean;
    procedure RecoverTcp;
    function SoftRestartScan: Boolean;
    function StallRestartScan: Boolean;
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer): Variant;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer): Boolean;
  public
    constructor Create(const ADeviceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal);
    destructor Destroy; override;

    function GetDeviceSerial: Integer;
    function GetLegacyFirmware(out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
    function GetNodeNumber: Integer;
    procedure Connect;
    procedure Disconnect;
    procedure ProgramDevice;
    procedure Start;
    procedure RequestStopAcquisition;
    procedure Stop;
    procedure ClearLegacyScanBuffer;
    function ReadLegacyRawBlock(ATimeoutMs: Cardinal;
      out ARaw: TMic140LegacyRawBlock): Boolean;
    function LegacyDecommutateRawBlock(const ARaw: TMic140LegacyRawBlock;
      out ABlock: TRecorderDeviceSampleBlock): Boolean;
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderDeviceSampleBlock): Boolean;
    function RunServiceZeroBalance(const AChannelNumbers: array of Integer;
      APollFrequencyHz: Double; out AMeans: TRecorderDoubleArray;
      out AErrorMessage: string): Boolean;
    function LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;
    function LegacyStreamReadCount: Int64;
    function LegacyNumBuffGapCount: Integer;
    function LegacyDuplicateNumBuffCount: Integer;
    function LegacyCorruptReadCount: Integer;
    function LegacyMdpResyncByteCount: Int64;
    function LegacyTryRestartStreamAfterReadStall: Boolean;
    function LegacyConsumeStreamSequenceReset: Boolean;
    function UsesRawRing: Boolean;
    function ChannelCount: Integer;
  end;

implementation

uses
  Math;

const
  CMaxFreq = 1000.0;
  CBalMin = 30;
  CBalSkip = 10;
  CBalFrac = 0.3;

constructor TRecorderMic140v2Device.Create(const ADeviceId, AHost: string;
  APort: Word; AChannelCount: Integer; APollFrequencyHz: Double;
  AUpdateTimeMs: Cardinal);
begin
  inherited Create;
  if ADeviceId = '' then
    raise ERecorderDeviceError.Create('device id empty');
  if AHost = '' then
    raise ERecorderDeviceError.Create('host empty');
  if not (AChannelCount in [1..MIC140MaxChannelCount]) then
    raise ERecorderDeviceError.CreateFmt('bad channel count %d', [AChannelCount]);
  fFreq := Mic140v2NormalizeFrequency(APollFrequencyHz);
  if fFreq > CMaxFreq then
    fFreq := MIC140DefaultPollFrequencyHz;
  fId := ADeviceId;
  fHost := AHost;
  fPort := APort;
  fChCnt := AChannelCount;
  fUpdMs := AUpdateTimeMs;
  fNode := MIC140v2DefaultNode;
  fState := rdsDisconnected;
  Mic140v2StreamClear(fStr);
  BuildChannels;
end;

destructor TRecorderMic140v2Device.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

function TRecorderMic140v2Device.GetDeviceId: string;
begin
  Result := fId;
end;

function TRecorderMic140v2Device.GetName: string;
begin
  Result := Format('MIC-140 %s:%d', [fHost, fPort]);
end;

function TRecorderMic140v2Device.GetState: TRecorderDeviceState;
begin
  Result := fState;
end;

function TRecorderMic140v2Device.GetChannels: TRecorderDeviceChannelArray;
begin
  Result := Copy(fCh, 0, Length(fCh));
end;

function TRecorderMic140v2Device.GetDeviceProperty(AProperty: TRecorderDeviceProperty;
  AIndex: Integer): Variant;
begin
  case AProperty of
    rdpName: Result := GetName;
    rdpHost: Result := fHost;
    rdpPort: Result := Integer(fPort);
    rdpPollFrequencyHz: Result := fFreq;
    rdpUpdateTimeMs: Result := Integer(fUpdMs);
    rdpChannelCount: Result := fChCnt;
    rdpDeviceSerial: Result := GetDeviceSerial;
    rdpStateWord: Result := Ord(fState);
    rdpErrorCode: Result := 0;
    rdpErrorText: Result := '';
  else
    Result := Null;
  end;
end;

function TRecorderMic140v2Device.TrySetDeviceProperty(
  AProperty: TRecorderDeviceProperty; const AValue: Variant;
  AIndex: Integer): Boolean;
var
  n: Double;
begin
  Result := False;
  case AProperty of
    rdpHost:
      if VarIsStr(AValue) or VarIsType(AValue, varUString) then
      begin
        fHost := string(AValue);
        Exit(True);
      end;
    rdpPort:
      if VarIsNumeric(AValue) then
      begin
        n := AValue;
        fPort := Word(Trunc(n));
        Exit(True);
      end;
    rdpPollFrequencyHz:
      if VarIsNumeric(AValue) then
      begin
        fFreq := Double(AValue);
        Exit(True);
      end;
    rdpUpdateTimeMs:
      if VarIsNumeric(AValue) then
      begin
        n := AValue;
        fUpdMs := Cardinal(Trunc(n));
        Exit(True);
      end;
    rdpChannelCount:
      if VarIsNumeric(AValue) then
      begin
        n := AValue;
        if Trunc(n) > 0 then
        begin
          fChCnt := Trunc(n);
          BuildChannels;
          Exit(True);
        end;
      end;
  end;
end;

procedure TRecorderMic140v2Device.BuildChannels;
var
  i: Integer;
begin
  SetLength(fCh, fChCnt);
  for i := 0 to fChCnt - 1 do
  begin
    fCh[i].Name := Mic140v2ChannelTag(fNode, i + 1);
    fCh[i].Address := Format('%d-%2.2d', [fNode, i + 1]);
    fCh[i].ModuleType := 'MIC-140';
    fCh[i].PollFrequencyHz := fFreq;
    fCh[i].Enabled := True;
  end;
end;

function TRecorderMic140v2Device.ScanStride: Integer;
begin
  { Current scan program is AIn-only: one payload row has fChCnt ADC words. }
  Result := fChCnt;
end;

function TRecorderMic140v2Device.GetDeviceSerial: Integer;
begin
  if fHwSer > 0 then
    Exit(fHwSer);
  if fFw.DevType > 0 then
    Result := Mic140v2HardwareCalibrSerial(fFw)
  else
    Result := 0;
end;

function TRecorderMic140v2Device.GetLegacyFirmware(
  out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
begin
  Result := fFw.DevType > 0;
  if Result then
    AFirmware := fFw;
end;

function TRecorderMic140v2Device.GetNodeNumber: Integer;
begin
  Result := fNode;
end;

function TRecorderMic140v2Device.UsesRawRing: Boolean;
begin
  Result := True;
end;

function TRecorderMic140v2Device.ChannelCount: Integer;
begin
  Result := fChCnt;
end;

procedure TRecorderMic140v2Device.Connect;
var
  err: string;
begin
  if fState <> rdsDisconnected then
    Exit;
  FreeAndNil(fCli);
  fHwSer := 0;
  FillChar(fFw, SizeOf(fFw), 0);
  Mic140v2StreamClear(fStr);
  fScanOn := False;

  if not Mic140v2TcpProbe(fHost, fPort, 800) then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] TCP probe failed', [fHost, fPort]));
    Exit;
  end;

  fCli := TMic140v2Tcp.Create(fHost, fPort, 5000);
  try
    fCli.Connect;
    if not fCli.ReadFirmware(fFw, err) then
    begin
      Mic140v2Log(Format('[MIC140v2:%s:%d] firmware: %s', [fHost, fPort, err]));
      FreeAndNil(fCli);
      Exit;
    end;
    fHwSer := Mic140v2HardwareCalibrSerial(fFw);
    if not Mic140v2StopScan(fCli, err) then
      Mic140v2Log(Format('[MIC140v2:%s:%d] orphan stop: %s', [fHost, fPort, err]));
    fCli.ClearBufferedPackets;
    fStop := False;
    fState := rdsConnected;
    Mic140v2Log(Format(
      '[MIC140v2:%s:%d] connected devType=%d ser=%d rev=%d.%d BIOS=%d.%d hwCal=%d',
      [fHost, fPort, fFw.DevType, fFw.DevSerNo,
       Mic140v2DevRevFromFirmware(fFw), Mic140v2DevSubRevFromFirmware(fFw),
       fFw.BiosFunction, fFw.BiosVersion, fHwSer]));
  except
    on E: Exception do
    begin
      Mic140v2Log(Format('[MIC140v2:%s:%d] connect: %s', [fHost, fPort, E.Message]));
      FreeAndNil(fCli);
    end;
  end;
end;

procedure TRecorderMic140v2Device.Disconnect;
begin
  if fState = rdsStarted then
    Stop;
  FreeAndNil(fCli);
  FillChar(fFw, SizeOf(fFw), 0);
  fHwSer := 0;
  fScanOn := False;
  fStop := False;
  fState := rdsDisconnected;
end;

procedure TRecorderMic140v2Device.ProgramDevice;
var
  prog: TMic140v2ScanProgrammer;
  err: string;
  tim: TRecorderMic140Timing;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsDisconnected then
    Exit;
  if fCli = nil then
    Exit;

  prog := TMic140v2ScanProgrammer.Create(fCli, fChCnt, fFreq, fUpdMs,
    Mic140v2DevRevFromFirmware(fFw), Mic140v2DevSubRevFromFirmware(fFw));
  try
    if prog.ProgramScan(err) then
    begin
      fState := rdsProgrammed;
      tim := prog.LastTiming;
      fExpDataWords := prog.LastFifoReadyWords;
      fExpMsgWords := prog.LastExpectedMessageWords;
      Mic140v2StreamSetExpectedPacket(fStr, fExpDataWords, fExpMsgWords);
      Mic140v2Log(Format(
        '[MIC140v2:%s:%d] scan programmed ch=%d stride=%d freq=%.3f Hz fifoReady=%d msgWords=%d',
        [fHost, fPort, fChCnt, ScanStride, fFreq, fExpDataWords, fExpMsgWords]));
    end
    else
      Mic140v2Log(Format('[MIC140v2:%s:%d] program failed: %s', [fHost, fPort, err]));
  finally
    prog.Free;
  end;
end;

function TRecorderMic140v2Device.ProbeScan: Boolean;
var
  pkt: TMic140v2ScanPacket;
  err: string;
  saved: Cardinal;
begin
  Result := False;
  if fCli = nil then
    Exit;
  saved := fCli.TimeoutMs;
  try
    fCli.TimeoutMs := CMic140LegacyStartProbeTimeoutMs;
    Result := fCli.ReadScanBlock(pkt, err) and (Length(pkt.DataWords) > 0);
  finally
    fCli.TimeoutMs := saved;
  end;
end;

procedure TRecorderMic140v2Device.RecoverTcp;
var
  err: string;
begin
  if fCli = nil then
    Exit;
  try
    fCli.Disconnect;
  except
  end;
  try
    fCli.Connect;
    if fCli.ReadFirmware(fFw, err) then
    begin
      if not Mic140v2StopScan(fCli, err) then
        Mic140v2Log(Format('[MIC140v2:%s:%d] recover stop: %s', [fHost, fPort, err]));
      fCli.ClearBufferedPackets;
      fScanOn := False;
    end;
  except
    on E: Exception do
      Mic140v2Log(Format('[MIC140v2:%s:%d] recover: %s', [fHost, fPort, E.Message]));
  end;
end;

function TRecorderMic140v2Device.SoftRestartScan: Boolean;
var
  err: string;
begin
  Result := False;
  if (fState <> rdsStarted) or (fCli = nil) then
    Exit;
  if fStr.CorruptStreak < CMic140LegacySoftRestartCorruptThreshold then
    Exit;
  if fStr.SoftRestartCnt >= CMic140LegacySoftRestartMaxAttempts then
    Exit;
  Inc(fStr.SoftRestartCnt);
  Mic140v2Log(Format('[MIC140v2:%s:%d] soft restart %d after %d corrupt',
    [fHost, fPort, fStr.SoftRestartCnt, fStr.CorruptStreak]));
  if not Mic140v2StopScan(fCli, err) then
    Mic140v2Log(Format('[MIC140v2:%s:%d] soft stop: %s', [fHost, fPort, err]));
  fCli.ClearBufferedPackets;
  fStr.SeqReset := True;
  fStr.CorruptStreak := 0;
  fStr.PktLogged := False;
  if fCli.StartScan(err) then
  begin
    fScanOn := True;
    fState := rdsStarted;
    Result := True;
  end
  else
    fState := rdsConnected;
end;

function TRecorderMic140v2Device.StallRestartScan: Boolean;
var
  err: string;
begin
  Result := False;
  if (fState <> rdsStarted) or (fCli = nil) or fStop then
    Exit;
  if fStr.StallRestartCnt >= CMic140LegacyReadStallRestartMaxAttempts then
    Exit;
  Inc(fStr.StallRestartCnt);
  Mic140v2Log(Format('[MIC140v2:%s:%d] stall restart %d after %d blocks',
    [fHost, fPort, fStr.StallRestartCnt, fStr.ReadCnt]));
  if not Mic140v2StopScan(fCli, err) then
    Mic140v2Log(Format('[MIC140v2:%s:%d] stall stop: %s', [fHost, fPort, err]));
  fCli.ClearBufferedPackets;
  fStr.SeqReset := True;
  fStr.PktLogged := False;
  fStr.LastNumBuffOk := False;
  fStr.LastTickOk := False;
  if fStr.StallRestartCnt >= CMic140LegacyReadStallRestartMaxAttempts then
  begin
    fState := rdsConnected;
    ProgramDevice;
    if fState <> rdsProgrammed then
      Exit;
  end;
  if fCli.StartScan(err) then
  begin
    fScanOn := True;
    fState := rdsStarted;
    Result := True;
  end
  else
    fState := rdsConnected;
end;

procedure TRecorderMic140v2Device.Start;
var
  att: Integer;
  err: string;
  cmdOk, probe: Boolean;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsDisconnected then
    Exit;
  if fState = rdsConnected then
    ProgramDevice;
  if fState <> rdsProgrammed then
    Exit;
  if fCli = nil then
    Exit;

  for att := 1 to CMic140LegacyStartAttempts do
  begin
    fCli.ClearBufferedPackets;
    fCli.TimeoutMs := CMic140LegacyStartCommandTimeoutMs;
    cmdOk := fCli.StartScan(err);
    probe := False;
    if not cmdOk then
      probe := ProbeScan;
    if cmdOk or probe then
    begin
      fCli.TimeoutMs := CMic140LegacyCommandTimeoutMs;
      // StartScan is a command on stream 1; stream-0 packets may already be
      // arriving by the time the reply is read. Do not drain TCP here: cutting
      // a live packet in the middle desynchronizes MDP. The read thread will
      // consume queued boundary packets and keep sequence/corrupt counters.
      Mic140v2StreamClear(fStr);
      Mic140v2StreamSetExpectedPacket(fStr, fExpDataWords, fExpMsgWords);
      fScanOn := True;
      fStop := False;
      fState := rdsStarted;
      Mic140v2Log(Format('[MIC140v2:%s:%d] scan started att=%d probe=%s',
        [fHost, fPort, att, BoolToStr(probe, True)]));
      Exit;
    end;
    fCli.TimeoutMs := CMic140LegacyCommandTimeoutMs;
    Mic140v2Log(Format('[MIC140v2:%s:%d] start fail att=%d: %s', [fHost, fPort, att, err]));
    if not Mic140v2StopScan(fCli, err) then
      Mic140v2Log(Format('[MIC140v2:%s:%d] start recovery stop: %s', [fHost, fPort, err]));
    fCli.ClearBufferedPackets;
    fScanOn := False;
    if att < CMic140LegacyStartAttempts then
    begin
      RecoverTcp;
      fState := rdsConnected;
      ProgramDevice;
      if fState <> rdsProgrammed then
        Break;
    end;
  end;
  fState := rdsConnected;
end;

procedure TRecorderMic140v2Device.RequestStopAcquisition;
begin
  fStop := True;
end;

procedure TRecorderMic140v2Device.ClearLegacyScanBuffer;
begin
  if fCli <> nil then
    fCli.ClearBufferedPackets;
  fStr.LastNumBuffOk := False;
  fStr.LastTickOk := False;
  fStr.PayloadStride := 0;
end;

procedure TRecorderMic140v2Device.Stop;
var
  err: string;
begin
  fStop := True;
  if (fCli <> nil) and ((fState = rdsStarted) or fScanOn) then
  begin
    if not Mic140v2StopScan(fCli, err) then
      Mic140v2Log(Format('[MIC140v2:%s:%d] stop failed: %s', [fHost, fPort, err]))
    else
      Mic140v2Log(Format(
        '[MIC140v2:%s:%d] stopped blocks=%d gaps=%d dup=%d corrupt=%d resync=%d',
        [fHost, fPort, fStr.ReadCnt, fStr.GapCnt, fStr.DupCnt, fStr.CorruptCnt,
         LegacyMdpResyncByteCount]));
    fCli.ClearBufferedPackets;
    fScanOn := False;
  end;
  if fState <> rdsDisconnected then
    fState := rdsConnected;
end;

function TRecorderMic140v2Device.ReadLegacyRawBlock(ATimeoutMs: Cardinal;
  out ARaw: TMic140LegacyRawBlock): Boolean;
begin
  Result := False;
  if (fState <> rdsStarted) or (fCli = nil) then
    Exit;
  Result := Mic140v2StreamReadRaw(fCli, fStr, fChCnt, ScanStride, fFreq, fStop,
    ATimeoutMs, fHost, fPort, ARaw);
  if Result and Mic140v2RawCorrupt(ARaw, fChCnt, fStr.PayloadStride) then
    SoftRestartScan;
end;

function TRecorderMic140v2Device.LegacyDecommutateRawBlock(
  const ARaw: TMic140LegacyRawBlock;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  lStride: Integer;
begin
  lStride := fStr.PayloadStride;
  if lStride <= 0 then
    lStride := ScanStride;
  Result := Mic140v2StreamDecommutate(ARaw, fChCnt, lStride, fFreq, fAux, ABlock);
end;

function TRecorderMic140v2Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  raw: TMic140LegacyRawBlock;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  if not ReadLegacyRawBlock(ATimeoutMs, raw) then
    Exit(False);
  Result := LegacyDecommutateRawBlock(raw, ABlock);
end;

function TRecorderMic140v2Device.LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;
begin
  Result := fAux;
end;

function TRecorderMic140v2Device.LegacyStreamReadCount: Int64;
begin
  Result := fStr.ReadCnt;
end;

function TRecorderMic140v2Device.LegacyNumBuffGapCount: Integer;
begin
  Result := fStr.GapCnt;
end;

function TRecorderMic140v2Device.LegacyDuplicateNumBuffCount: Integer;
begin
  Result := fStr.DupCnt;
end;

function TRecorderMic140v2Device.LegacyCorruptReadCount: Integer;
begin
  Result := fStr.CorruptCnt;
end;

function TRecorderMic140v2Device.LegacyMdpResyncByteCount: Int64;
begin
  if fCli <> nil then
    Result := fCli.MdpResyncByteCount
  else
    Result := 0;
end;

function TRecorderMic140v2Device.LegacyTryRestartStreamAfterReadStall: Boolean;
begin
  Result := StallRestartScan;
end;

function TRecorderMic140v2Device.LegacyConsumeStreamSequenceReset: Boolean;
begin
  Result := fStr.SeqReset;
  fStr.SeqReset := False;
end;

function TRecorderMic140v2Device.RunServiceZeroBalance(
  const AChannelNumbers: array of Integer; APollFrequencyHz: Double;
  out AMeans: TRecorderDoubleArray; out AErrorMessage: string): Boolean;
var
  blk: TRecorderDeviceSampleBlock;
  chIdx, i, j, k, tgt: Integer;
  sums: array of Double;
  cnt, eff: array of Integer;
  need: Boolean;
  savedHz: Double;
  tEnd: QWord;
begin
  Result := False;
  AErrorMessage := '';
  SetLength(AMeans, Length(AChannelNumbers));
  if Length(AChannelNumbers) = 0 then
  begin
    AErrorMessage := 'no channels';
    Exit;
  end;
  SetLength(sums, Length(AChannelNumbers));
  SetLength(cnt, Length(AChannelNumbers));
  SetLength(eff, Length(AChannelNumbers));
  tgt := Max(CBalMin, Round(CBalFrac * APollFrequencyHz));
  savedHz := fFreq;
  fFreq := Mic140v2NormalizeFrequency(APollFrequencyHz);
  try
    if fState = rdsStarted then
      Stop;
    if fState = rdsDisconnected then
      Connect;
    if fState = rdsDisconnected then
    begin
      AErrorMessage := 'connect failed';
      Exit;
    end;
    ProgramDevice;
    if fState <> rdsProgrammed then
    begin
      AErrorMessage := 'program failed';
      Exit;
    end;
    Start;
    if fState <> rdsStarted then
    begin
      AErrorMessage := 'start failed';
      Exit;
    end;
    tEnd := GetTickCount64 + 20000;
    while GetTickCount64 < tEnd do
    begin
      need := False;
      for j := 0 to High(eff) do
        if eff[j] < tgt then
        begin
          need := True;
          Break;
        end;
      if not need then
        Break;
      if not ReadBlock(500, blk) then
        Continue;
      for i := 0 to blk.SampleCount - 1 do
        for j := 0 to High(AChannelNumbers) do
        begin
          chIdx := AChannelNumbers[j] - 1;
          if (chIdx < 0) or (chIdx >= blk.ChannelCount) then
            Continue;
          Inc(cnt[j]);
          if cnt[j] <= CBalSkip then
            Continue;
          if eff[j] >= tgt then
            Continue;
          sums[j] := sums[j] + blk.Values[chIdx][i];
          Inc(eff[j]);
        end;
    end;
    Stop;
    for j := 0 to High(AChannelNumbers) do
    begin
      if eff[j] < tgt then
      begin
        AErrorMessage := Format('ch %d: %d/%d samples', [AChannelNumbers[j], eff[j], tgt]);
        Exit;
      end;
      AMeans[j] := sums[j] / eff[j];
    end;
    Result := True;
  finally
    fFreq := savedHz;
    if fState <> rdsDisconnected then
      Disconnect;
  end;
end;

end.
