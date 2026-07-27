unit uRecorderMic140Device;

{
  MIC-140 v2: IMic140Device, UsesRawRing=True.
  ?˜???˜??: Protocol / Scan / Stream / RawRing. Utils ˜˜˜ MIC140/utils/.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants,
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uRecorderDeviceDataThread, uRecorderMic140DeviceApi, uRecorderTags,
  uRecorderMic140WireTypes,
  uRecorderMic140Protocol, uRecorderMic140Consts, uRecorderMic140Timing,
  uRecorderMic140Scan, uRecorderMic140Stream, uRecorderMic140Helper,
  uRecorderMic140Diag, uRecorderMic140DataThread;

type
  TRecorderMic140Device = class(TInterfacedObject, IMic140Device,
    IMic140ServiceMemory)
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
    fInitialized: Boolean;
    fCli: TMic140v2Tcp;
    fFw: TMic140v2Firmware;
    fProgrammingProfile: TMic140ProgrammingProfile;
    fGroundEnabled: Boolean;
    fHwSer: Integer;
    fExpDataWords: Word;
    fExpMsgWords: Word;
    fCh: TRecorderDeviceChannelArray;
    fRangeIndexes: array of Integer;
    fCommutIndexes: array of Integer;
    fBoardCommutIndexes: array of Integer;
    fStr: TMic140v2StreamState;
    fAux: TMic140AuxTemperatureBlock;
    fValAddr: Word;
    fTinSlots: Integer;
    fScanPayloadStride: Integer;
    fLastTinDmWords: TMic140v2WordBuf;
    fLastTinDmReadTick: QWord;
    { Play: consume DataThread ring. }
    fDataThread: TRecorderMic140DataThread;
    procedure BuildChannels;
    procedure RefreshAuxFromDm(ASampleCount: Integer);
    function ScanStride: Integer;
    function ProbeScan: Boolean;
    procedure RecoverTcp;
    function SoftRestartScan: Boolean;
    function StallRestartScan: Boolean;
    function PumpOneBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderDeviceSampleBlock): Boolean;
    procedure EnsureDataThread;
    procedure StopDataThread;
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    function GetNativeObject: TObject;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer): Variant;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer): Boolean;
  public
    constructor Create(const ADeviceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      AProgrammingProfile: TMic140ProgrammingProfile = mppAutoCompatibility;
      AGroundEnabled: Boolean = False);
    destructor Destroy; override;

    function GetDeviceSerial: Integer;
    function GetLegacyFirmware(out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
    function GetNodeNumber: Integer;
    procedure Connect;
    procedure Disconnect;
    procedure InitializeDevice;
    procedure ConfigureDevice;
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
    function TestLink(out AErrorText: string): Boolean;
    function SupportsDeviceAction(AAction: TRecorderDeviceAction): Boolean;
    function ExecuteDeviceAction(AAction: TRecorderDeviceAction;
      const AChannelIndices: array of Integer; out AValues: TRecorderDeviceActionValues;
      out AErrorText: string): Boolean;
    function ReadServiceFirmware(
      out AFirmware: TRecorderMic140LegacyFirmware;
      out AErrorMessage: string): Boolean;
    function StopServiceScan(out AErrorMessage: string): Boolean;
    function ReadServiceFlash(AAddress: LongWord; var ABuffer;
      AByteCount: Integer; out AErrorMessage: string): Boolean;
  end;

implementation

uses
  Math, LCLIntf;

const
  CMaxFreq = 1000.0;
  CBalMin = 30;
  CBalSkip = 10;
  CBalFrac = 0.3;

function TRecorderMic140Device.SupportsDeviceAction(
  AAction: TRecorderDeviceAction): Boolean;
begin
  Result := AAction = rdaZeroBalance;
end;

function TRecorderMic140Device.ExecuteDeviceAction(
  AAction: TRecorderDeviceAction; const AChannelIndices: array of Integer;
  out AValues: TRecorderDeviceActionValues; out AErrorText: string): Boolean;
begin
  SetLength(AValues, 0);
  AErrorText := '?˜?????˜?˜?????? ???˜?????????˜???˜?˜?˜ ?˜?????˜?????????????˜???????????˜?? API MIC-140';
  Result := False;
end;


function TRecorderMic140Device.ReadServiceFirmware(
  out AFirmware: TRecorderMic140LegacyFirmware;
  out AErrorMessage: string): Boolean;
begin
  FillChar(AFirmware, SizeOf(AFirmware), 0);
  if fState = rdsStarted then
  begin
    AErrorMessage := 'MIC-140: stop acquisition before reading calibration';
    Exit(False);
  end;
  if fCli = nil then
  begin
    AErrorMessage := 'MIC-140: device connection is not open';
    Exit(False);
  end;
  Result := fCli.ReadFirmware(AFirmware, AErrorMessage);
end;

function TRecorderMic140Device.StopServiceScan(
  out AErrorMessage: string): Boolean;
begin
  if fState = rdsStarted then
  begin
    AErrorMessage := 'MIC-140: stop acquisition before reading calibration';
    Exit(False);
  end;
  if fCli = nil then
  begin
    AErrorMessage := 'MIC-140: device connection is not open';
    Exit(False);
  end;
  Result := fCli.StopScan(AErrorMessage);
  fCli.ClearBufferedPackets;
end;

function TRecorderMic140Device.ReadServiceFlash(AAddress: LongWord;
  var ABuffer; AByteCount: Integer; out AErrorMessage: string): Boolean;
begin
  if fState = rdsStarted then
  begin
    AErrorMessage := 'MIC-140: stop acquisition before reading calibration';
    Exit(False);
  end;
  if fCli = nil then
  begin
    AErrorMessage := 'MIC-140: device connection is not open';
    Exit(False);
  end;
  Result := fCli.ReadFlashStorage(AAddress, ABuffer, AByteCount, AErrorMessage);
end;

constructor TRecorderMic140Device.Create(const ADeviceId, AHost: string;
  APort: Word; AChannelCount: Integer; APollFrequencyHz: Double;
  AUpdateTimeMs: Cardinal; AProgrammingProfile: TMic140ProgrammingProfile;
  AGroundEnabled: Boolean);
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
  fProgrammingProfile := AProgrammingProfile;
  fGroundEnabled := AGroundEnabled;
  fNode := MIC140v2DefaultNode;
  fState := rdsDisconnected;
  fInitialized := False;
  fDataThread := nil;
  Mic140v2StreamClear(fStr);
  BuildChannels;
  EnsureDataThread;
end;

destructor TRecorderMic140Device.Destroy;
begin
  Disconnect;
  StopDataThread;
  FreeAndNil(fDataThread);
  inherited Destroy;
end;

procedure TRecorderMic140Device.EnsureDataThread;
var
  lSamples: Integer;
  lMaxPerCh: Integer;
  lStride: Integer;
begin
  if fDataThread = nil then
    fDataThread := TRecorderMic140DataThread.Create(@PumpOneBlock, 500);
  { ˜˜˜˜ BIOS-˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜˜ half-FIFO (~7 ˜˜˜˜˜˜˜˜/˜˜˜˜˜ ˜˜˜ 48ch).
    ˜˜ 100 ˜˜ ˜ DataUpdateMs=300 ˜˜˜˜ = 30, ˜˜ FIFO ˜˜˜ ?6-7 ˜ Config
    ˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜˜ ˜ ˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜; ˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜˜˜ DoTick. }
  lStride := ScanStride;
  if lStride <= 0 then
    lStride := Max(1, fChCnt);
  lMaxPerCh := ((CMic140LegacyDmBufferEnd - CMic140LegacyDmBufferBegin + 1) div 2)
    div lStride;
  if lMaxPerCh < 1 then
    lMaxPerCh := 1;
  lSamples := Max(1, Round(fFreq * Max(1, Integer(fUpdMs)) / 1000.0));
  if lSamples > lMaxPerCh then
    lSamples := lMaxPerCh;
  if (fExpDataWords > 0) and (lStride > 0) then
    lSamples := Max(1, Integer(fExpDataWords) div lStride);
  fDataThread.Config(fChCnt, lSamples, fFreq);
end;

procedure TRecorderMic140Device.StopDataThread;
var
  lDeadline: QWord;
begin
  if fDataThread = nil then
    Exit;
  fDataThread.StopPlay;
  lDeadline := GetTickCount64 + 2000;
  while (fDataThread.State <> dtsIdle) and (GetTickCount64 < lDeadline) do
    Sleep(5);
end;

function TRecorderMic140Device.PumpOneBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  raw: TMic140LegacyRawBlock;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  if not ReadLegacyRawBlock(ATimeoutMs, raw) then
    Exit(False);
  Result := LegacyDecommutateRawBlock(raw, ABlock);
end;

function TRecorderMic140Device.GetDeviceId: string;
begin
  Result := fId;
end;

function TRecorderMic140Device.GetName: string;
begin
  Result := Format('MIC-140 %s:%d', [fHost, fPort]);
end;

function TRecorderMic140Device.GetState: TRecorderDeviceState;
begin
  Result := fState;
end;

function TRecorderMic140Device.GetChannels: TRecorderDeviceChannelArray;
begin
  Result := Copy(fCh, 0, Length(fCh));
end;

function TRecorderMic140Device.GetNativeObject: TObject;
begin
  Result := Self;
end;

function TRecorderMic140Device.GetDeviceProperty(AProperty: TRecorderDeviceProperty;
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
    rdpMic140RangeIndex:
      if (AIndex >= 0) and (AIndex < Length(fRangeIndexes)) then
        Result := fRangeIndexes[AIndex]
      else
        Result := Null;
    rdpMic140CommutIndex:
      if (AIndex >= 0) and (AIndex < Length(fCommutIndexes)) then
        Result := fCommutIndexes[AIndex]
      else
        Result := Null;
    rdpMic140BoardCommutIndex:
      if (AIndex >= 0) and (AIndex < Length(fBoardCommutIndexes)) then
        Result := fBoardCommutIndexes[AIndex]
      else
        Result := Null;
    rdpStateWord: Result := Ord(fState);
    rdpErrorCode: Result := 0;
    rdpErrorText: Result := '';
  else
    Result := Null;
  end;
end;

function TRecorderMic140Device.TrySetDeviceProperty(
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
    rdpMic140RangeIndex:
      if VarIsNumeric(AValue) and (AIndex >= 0) and
        (AIndex < Length(fRangeIndexes)) then
      begin
        n := AValue;
        fRangeIndexes[AIndex] := Trunc(n);
        Exit(True);
      end;
    rdpMic140CommutIndex:
      if VarIsNumeric(AValue) and (AIndex >= 0) and
        (AIndex < Length(fCommutIndexes)) then
      begin
        n := AValue;
        fCommutIndexes[AIndex] := Trunc(n);
        Exit(True);
      end;
    rdpMic140BoardCommutIndex:
      if VarIsNumeric(AValue) and (AIndex >= 0) and
        (AIndex < Length(fBoardCommutIndexes)) then
      begin
        n := AValue;
        fBoardCommutIndexes[AIndex] := Trunc(n);
        Exit(True);
      end;
  end;
end;

procedure TRecorderMic140Device.BuildChannels;
var
  i: Integer;
  lOldRangeCount: Integer;
  lOldCommutCount: Integer;
  lOldBoardCommutCount: Integer;
begin
  lOldRangeCount := Length(fRangeIndexes);
  lOldCommutCount := Length(fCommutIndexes);
  lOldBoardCommutCount := Length(fBoardCommutIndexes);
  SetLength(fCh, fChCnt);
  SetLength(fRangeIndexes, fChCnt);
  SetLength(fCommutIndexes, fChCnt);
  SetLength(fBoardCommutIndexes, fChCnt);
  for i := 0 to fChCnt - 1 do
  begin
    fCh[i].Name := Mic140v2ChannelTag(fNode, i + 1);
    fCh[i].Address := Format('%d-%2.2d', [fNode, i + 1]);
    fCh[i].ModuleType := 'MIC-140';
    fCh[i].PollFrequencyHz := fFreq;
    fCh[i].Enabled := True;
    if (i >= lOldRangeCount) or (fRangeIndexes[i] < 0) then
      fRangeIndexes[i] := CMic140Range100mV;
    if (i >= lOldCommutCount) or (fCommutIndexes[i] < 0) then
      fCommutIndexes[i] := CMic140ChannelCommutIn;
    if (i >= lOldBoardCommutCount) or (fBoardCommutIndexes[i] < 0) then
      fBoardCommutIndexes[i] := CMic140ChannelCommutIn;
  end;
end;

function TRecorderMic140Device.ScanStride: Integer;
begin
  if fScanPayloadStride > 0 then
    Result := fScanPayloadStride
  else
    Result := fChCnt;
end;

procedure TRecorderMic140Device.RefreshAuxFromDm(ASampleCount: Integer);
var
  lWords, lChunk: TMic140v2WordBuf;
  lErr: string;
  i, j: Integer;
  lNow: QWord;
  lUseCache: Boolean;
  lSubRev: Word;
begin
  if (fCli = nil) or (fValAddr = 0) or (fTinSlots <= 0) or (ASampleCount <= 0) then
    Exit;
  lNow := GetTickCount64;
  lSubRev := Mic140v2DevSubRevFromFirmware(fFw);
  lUseCache := (fLastTinDmReadTick <> 0) and (lNow - fLastTinDmReadTick < fUpdMs) and
    (Length(fLastTinDmWords) >= fTinSlots);
  { ?˜ MIC-140-48v3/SubRev1 ???????????˜?? t6..t12 ?????????˜ ???????˜?˜?? ?? DM 5..11.
    ?˜???˜?????? ???˜ ?????????? ???????˜???˜???? ???? ???????????? ??????????: ?˜?˜?? ???˜?˜?˜?˜???? ?˜?????? ???????????? ?? ????
    ???˜?˜???????˜???˜ ?? ?????˜???˜?˜?????˜?? ???˜?????˜???˜?˜???? ?˜?????????? ????-???? ???????˜???????˜???????? 200-ms ???˜?˜??. }
  if lSubRev = 1 then
  begin
    lUseCache := False;
    if fCli.ReadDmWords(
      Word(fValAddr + fChCnt + Mic140v2TInDmWordOffset(0, lSubRev)),
      fTinSlots, lWords, lErr) and (Length(lWords) >= fTinSlots) then
    begin
      SetLength(fLastTinDmWords, fTinSlots);
      for i := 0 to fTinSlots - 1 do
        fLastTinDmWords[i] := lWords[i];
      fLastTinDmReadTick := lNow;
      lUseCache := True;
    end
    else if Length(fLastTinDmWords) < fTinSlots then
      Exit;
  end;
  if (lSubRev <> 1) and not lUseCache then
  begin
    SetLength(lWords, fTinSlots);
    for i := 0 to fTinSlots - 1 do
    begin
      if not fCli.ReadDmWords(
        Word(fValAddr + fChCnt +
          Mic140v2TInDmWordOffset(i, lSubRev)),
        1, lChunk, lErr) then
      begin
        Mic140v2Log(Format('[MIC140v2:%s:%d] TIn DM read[%d]: %s',
          [fHost, fPort, i + 1, lErr]));
        if Length(fLastTinDmWords) < fTinSlots then
          Exit;
        lUseCache := True;
        Break;
      end;
      if Length(lChunk) > 0 then
        lWords[i] := lChunk[0]
      else
        lWords[i] := 0;
    end;
    if not lUseCache then
    begin
      SetLength(fLastTinDmWords, fTinSlots);
      for i := 0 to fTinSlots - 1 do
        fLastTinDmWords[i] := lWords[i];
      fLastTinDmReadTick := lNow;
    end;
  end;
  fAux.ChannelCount := fTinSlots;
  { TIn ?˜???˜?????˜?˜?˜ ???˜???????˜???˜?? ?˜???????????? ???? DM, ?? ???? ???˜???????˜ ?? ?????˜?˜???????˜?????˜?? FIFO AIn. }
  fAux.SampleCount := 1;
  SetLength(fAux.Values, fTinSlots);
  SetLength(fAux.Valid, fTinSlots);
  for i := 0 to fTinSlots - 1 do
  begin
    SetLength(fAux.Values[i], 1);
    SetLength(fAux.Valid[i], 1);
    for j := 0 to 0 do
    begin
      fAux.Valid[i][j] := i < Length(fLastTinDmWords);
      if fAux.Valid[i][j] then
        fAux.Values[i][j] := SmallInt(fLastTinDmWords[i]);
    end;
  end;
end;

function TRecorderMic140Device.GetDeviceSerial: Integer;
begin
  if fHwSer > 0 then
    Exit(fHwSer);
  if fFw.DevType > 0 then
    Result := Mic140v2HardwareCalibrSerial(fFw)
  else
    Result := 0;
end;

function TRecorderMic140Device.GetLegacyFirmware(
  out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
begin
  Result := fFw.DevType > 0;
  if Result then
    AFirmware := fFw;
end;

function TRecorderMic140Device.GetNodeNumber: Integer;
begin
  Result := fNode;
end;

function TRecorderMic140Device.UsesRawRing: Boolean;
begin
  Result := True;
end;

function TRecorderMic140Device.ChannelCount: Integer;
begin
  Result := fChCnt;
end;

procedure TRecorderMic140Device.Connect;
begin
  if fState <> rdsDisconnected then
    Exit;
  FreeAndNil(fCli);
  fHwSer := 0;
  FillChar(fFw, SizeOf(fFw), 0);
  Mic140v2StreamClear(fStr);
  fScanOn := False;
  fInitialized := False;

  if not Mic140v2TcpProbe(fHost, fPort, 800) then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] TCP probe failed', [fHost, fPort]));
    Exit;
  end;

  fCli := TMic140v2Tcp.Create(fHost, fPort, 5000);
  try
    fCli.Connect;
    fState := rdsConnected;
    Mic140v2Log(Format('[MIC140v2:%s:%d] transport connected',
      [fHost, fPort]));
  except
    on E: Exception do
    begin
      Mic140v2Log(Format('[MIC140v2:%s:%d] connect: %s', [fHost, fPort, E.Message]));
      FreeAndNil(fCli);
    end;
  end;
end;

procedure TRecorderMic140Device.Disconnect;
begin
  if fState = rdsStarted then
    Stop;
  StopDataThread;
  FreeAndNil(fCli);
  FillChar(fFw, SizeOf(fFw), 0);
  fHwSer := 0;
  fScanOn := False;
  fInitialized := False;
  fStop := False;
  fState := rdsDisconnected;
end;

procedure TRecorderMic140Device.InitializeDevice;
var
  err: string;
  lReply: TMic140v2WordBuf;
begin
  if fState = rdsDisconnected then
    Connect;
  if (fState = rdsDisconnected) or (fCli = nil) or fInitialized then
    Exit;
  if not fCli.ReadFirmware(fFw, err) then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] init firmware: %s',
      [fHost, fPort, err]));
    Exit;
  end;
  fHwSer := Mic140v2HardwareCalibrSerial(fFw);
  { [ORIG: CCMC031EthernetInterface::LoadBios] ?????˜???˜?˜?????˜ MIC-140-48v3
    ???????? ?˜???? ???? ?˜???˜?˜???˜ ?????˜?˜???????˜ CMD_RESET. ?˜?? ???˜?˜???˜?˜ ?˜ ???˜?˜?˜?˜??
    ModuleMIC140_96::LoadBios: ?˜?˜?? ?˜???????˜?? ?˜?˜???????? ???˜?˜?????????? ???˜?˜???˜?????˜?˜?˜?˜. }
  if not fCli.CallCommand(CMic140LegacyCmdReset, nil, 0, lReply, err) then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] init CMD_RESET: %s',
      [fHost, fPort, err]));
    Exit;
  end;
  fCli.ClearBufferedPackets;
  { Reset ?????˜???˜?˜?????˜?? ?????????˜?˜?????˜?˜?˜ ???˜?????˜?˜????????. ?˜ ???˜?????????????? ?????˜???? ???????˜???????˜??????
    ?????????????????? ?˜?˜?? ?????˜?˜?? ???????˜?˜???????˜ CheckState(BIOS_LOADED_STATE). ?˜?? ?????˜?˜????????
    Stop/ResetScanMain, ???????? BIOS ?˜???????? ???? ???˜?????˜?????˜ ???? ???????˜???˜ ???????˜?????˜?˜???˜????. }
  Sleep(500);
  if not fCli.ReadFirmware(fFw, err) then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] firmware after CMD_RESET: %s',
      [fHost, fPort, err]));
    Exit;
  end;
  fHwSer := Mic140v2HardwareCalibrSerial(fFw);
  if not Mic140v2StopScan(fCli, err) then
    Mic140v2Log(Format('[MIC140v2:%s:%d] init orphan stop: %s',
      [fHost, fPort, err]));
  fCli.ClearBufferedPackets;
  fStop := False;
  fInitialized := True;
  Mic140v2Log(Format(
    '[MIC140v2:%s:%d] initialized devType=%d ser=%d rev=%d.%d BIOS=%d.%d hwCal=%d',
    [fHost, fPort, fFw.DevType, fFw.DevSerNo,
     Mic140v2DevRevFromFirmware(fFw), Mic140v2DevSubRevFromFirmware(fFw),
     fFw.BiosVersion, fFw.BiosFunction, fHwSer]));
end;

procedure TRecorderMic140Device.ConfigureDevice;
begin
  ProgramDevice;
end;

procedure TRecorderMic140Device.ProgramDevice;
var
  prog: TMic140v2ScanProgrammer;
  err: string;
  tim: TRecorderMic140Timing;
begin
  if fState = rdsDisconnected then
    Connect;
  if not fInitialized then
    InitializeDevice;
  if (fState = rdsDisconnected) or not fInitialized then
    Exit;
  if fCli = nil then
    Exit;

  prog := TMic140v2ScanProgrammer.Create(fCli, fChCnt, fFreq, fUpdMs,
    Mic140v2DevRevFromFirmware(fFw), Mic140v2DevSubRevFromFirmware(fFw),
    fRangeIndexes, fCommutIndexes, fBoardCommutIndexes, fProgrammingProfile,
    fGroundEnabled);
  try
    if prog.ProgramScan(err) then
    begin
      fState := rdsProgrammed;
      tim := prog.LastTiming;
      fExpDataWords := prog.LastFifoReadyWords;
      fExpMsgWords := prog.LastExpectedMessageWords;
      fScanPayloadStride := prog.LastPayloadStride;
      fValAddr := prog.LastValAddr;
      fTinSlots := prog.TemperatureChannelCount;
      Mic140v2StreamSetExpectedPacket(fStr, fExpDataWords, fExpMsgWords);
      EnsureDataThread;
      Mic140v2Log(Format(
        '[MIC140v2:%s:%d] scan programmed ch=%d fifoStride=%d tin=%d val=0x%.4x freq=%.3f Hz fifoReady=%d msgWords=%d countAver=%d decayUs=%.3f',
        [fHost, fPort, fChCnt, fScanPayloadStride, fTinSlots, fValAddr, fFreq,
         fExpDataWords, fExpMsgWords, tim.AverageSampleCount,
         tim.ChannelCommutationUs]));
    end
    else
      Mic140v2Log(Format('[MIC140v2:%s:%d] program failed: %s', [fHost, fPort, err]));
  finally
    prog.Free;
  end;
end;

function TRecorderMic140Device.ProbeScan: Boolean;
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

procedure TRecorderMic140Device.RecoverTcp;
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

function TRecorderMic140Device.SoftRestartScan: Boolean;
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

function TRecorderMic140Device.StallRestartScan: Boolean;
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

procedure TRecorderMic140Device.Start;
var
  att: Integer;
  err: string;
  cmdOk, probe: Boolean;
  lArgs, lReply: TMic140v2WordBuf;
begin
  { Start ???? ???˜?????????˜???˜ Connect/Init/Config ?????˜??????: ???˜???˜?????˜?˜???? ?????? ?????˜??????
    ?????????˜?˜???˜?˜ ???????????˜???????˜ ?˜?˜?˜?˜?????˜?˜???? ???? ?????˜???˜?????? ?? ???˜???˜?????˜?˜ ?????? ?????????˜?˜. }
  if fState <> rdsProgrammed then
    Exit;
  if fCli = nil then
    Exit;

  { [ORIG] ?˜???˜???? Stop ???????˜?˜ Device ?˜???????????˜ PROGRAMMED, ?????˜?˜?????˜ ?˜???????˜?˜?˜???? Start
    ?˜???????? ???˜?????????˜???˜ Programming ?? SETSTATESCAN(scan_id, 0). ?˜ RecorderLnx
    ?˜?˜???˜???˜?? Config ???˜???????˜?? ???˜ Play, ???? ?˜?????˜ ?????˜???????? ?˜???????????˜???????˜ ???˜?˜ ?˜???????? ????????
    ?????˜?????˜?????˜?˜: ???????˜?? MIC-140 ???˜???????????????˜ ?????????˜?˜???˜???˜ ?˜ ?????˜???????????? ?????????˜???? ?? ???????˜
    ?????????????? ???????˜?˜?˜?˜?˜ ?????????˜ Start. }
  SetLength(lArgs, 2);
  lArgs[0] := CMic140LegacyScanId;
  lArgs[1] := 0;
  if not fCli.CallCommand(CMic140LegacyCmdSetStateScan, lArgs, 0, lReply, err) then
  begin
    Mic140v2Log(Format('[MIC140v2:%s:%d] start rearm failed: %s',
      [fHost, fPort, err]));
    Exit;
  end;

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
      EnsureDataThread;
      fDataThread.StartPlay;
      Mic140v2Log(Format('[MIC140:%s:%d] scan started att=%d probe=%s',
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

procedure TRecorderMic140Device.RequestStopAcquisition;
begin
  fStop := True;
end;

procedure TRecorderMic140Device.ClearLegacyScanBuffer;
begin
  if fCli <> nil then
    fCli.ClearBufferedPackets;
  fStr.LastNumBuffOk := False;
  fStr.LastTickOk := False;
  fStr.PayloadStride := 0;
end;

procedure TRecorderMic140Device.Stop;
var
  err: string;
begin
  fStop := True;
  StopDataThread;
  if (fCli <> nil) and ((fState = rdsStarted) or fScanOn) then
  begin
    if not Mic140v2StopScan(fCli, err) then
      Mic140v2Log(Format('[MIC140:%s:%d] stop failed: %s', [fHost, fPort, err]))
    else
      Mic140v2Log(Format(
        '[MIC140:%s:%d] stopped blocks=%d gaps=%d dup=%d corrupt=%d resync=%d',
        [fHost, fPort, fStr.ReadCnt, fStr.GapCnt, fStr.DupCnt, fStr.CorruptCnt,
         LegacyMdpResyncByteCount]));
    fCli.ClearBufferedPackets;
    fScanOn := False;
  end;
  if fState <> rdsDisconnected then
  begin
    if fInitialized and (fExpDataWords > 0) then
      fState := rdsProgrammed
    else
      fState := rdsConnected;
  end;
end;

function TRecorderMic140Device.ReadLegacyRawBlock(ATimeoutMs: Cardinal;
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

function TRecorderMic140Device.LegacyDecommutateRawBlock(
  const ARaw: TMic140LegacyRawBlock;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  lStride: Integer;
begin
  lStride := fStr.PayloadStride;
  if lStride <= 0 then
    lStride := ScanStride;
  Result := Mic140v2StreamDecommutate(ARaw, fChCnt, lStride, fFreq, fAux, ABlock);
  if Result and (fTinSlots > 0) and (lStride <= fChCnt) then
    RefreshAuxFromDm(ABlock.SampleCount);
end;

function TRecorderMic140Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  lDeadline: QWord;
  lRing: TRecorderAcquisitionBlock;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  { Play: äàííûå èç DataThread; consumer (DataSource) òîëüêî ÷èòàåò êîëüöî. }
  if (fState = rdsStarted) and (fDataThread <> nil) and
    (fDataThread.State = dtsPlaying) then
  begin
    Result := False;
    { timeout=0: non-blocking ring poll (DoTick drain). }
    if ATimeoutMs = 0 then
    begin
      if fDataThread.ReadBlock(lRing) then
      begin
        CopyRecorderAcquisitionBlock(lRing, ABlock);
        Exit(True);
      end;
      Exit(False);
    end;
    lDeadline := GetTickCount64 + ATimeoutMs;
    repeat
      if fDataThread.ReadBlock(lRing) then
      begin
        CopyRecorderAcquisitionBlock(lRing, ABlock);
        Exit(True);
      end;
      Sleep(1);
    until GetTickCount64 >= lDeadline;
    Exit;
  end;
  Result := PumpOneBlock(ATimeoutMs, ABlock);
end;

function TRecorderMic140Device.LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;
begin
  Result := fAux;
end;

function TRecorderMic140Device.LegacyStreamReadCount: Int64;
begin
  Result := fStr.ReadCnt;
end;

function TRecorderMic140Device.LegacyNumBuffGapCount: Integer;
begin
  Result := fStr.GapCnt;
end;

function TRecorderMic140Device.LegacyDuplicateNumBuffCount: Integer;
begin
  Result := fStr.DupCnt;
end;

function TRecorderMic140Device.LegacyCorruptReadCount: Integer;
begin
  Result := fStr.CorruptCnt;
end;

function TRecorderMic140Device.LegacyMdpResyncByteCount: Int64;
begin
  if fCli <> nil then
    Result := fCli.MdpResyncByteCount
  else
    Result := 0;
end;

function TRecorderMic140Device.LegacyTryRestartStreamAfterReadStall: Boolean;
begin
  Result := StallRestartScan;
end;

function TRecorderMic140Device.LegacyConsumeStreamSequenceReset: Boolean;
begin
  Result := fStr.SeqReset;
  fStr.SeqReset := False;
end;

function TRecorderMic140Device.RunServiceZeroBalance(
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

function TRecorderMic140Device.TestLink(out AErrorText: string): Boolean;
begin
  { ˜˜˜ MIC-185: ˜˜ ˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜ ˜˜˜˜˜ scan-˜˜˜˜˜˜ ˜ DataThread. }
  Result := False;
  AErrorText := '';
  if (fState = rdsDisconnected) or (fCli = nil) then
  begin
    AErrorText := 'MIC-140 is not connected';
    Exit;
  end;
  if fState = rdsStarted then
    Exit(True);
  if fState >= rdsConnected then
    Exit(True);
  Result := fCli.ReadFirmware(fFw, AErrorText);
end;

end.
