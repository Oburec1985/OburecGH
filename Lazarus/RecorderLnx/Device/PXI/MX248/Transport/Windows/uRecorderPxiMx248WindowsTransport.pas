unit uRecorderPxiMx248WindowsTransport;

{
  Win64 client transport for MX-248 Bridge IPC v1. The first operation starts
  the x86 bridge with inherited stdin/stdout pipes; the bridge alone loads the
  vendor DevAPI selected by RECORDER_MX248_VENDOR_DIR.

  One owner thread must serialize all calls. This object owns the child process
  and its pipes, retains one configured chassis/slot route, validates every response
  request id and bounds every wait/payload. ReadBlock decodes into caller-owned
  preallocated arrays. Non-Windows builds expose the same class but every
  operation returns rocUnsupported without starting a process.

  SetModuleProperties only caches the typed snapshot; ProgramAcquisition is the
  single IPC CONFIGURE boundary. Do not use this unit from a GUI thread and do
  not add vendor ABI declarations or direct DLL loading here. See
  Device/PXI/MX248/Docs/README.md and Bridge/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Process, uRecorderAcquisitionTypes,
  uRecorderDriverContractsV2, uRecorderPxiMx248Types,
  uRecorderPxiMx248RuntimeTransport, uRecorderPxiMx248BridgeCodec;

type
  TRecorderPxiMx248WindowsTransport = class(TInterfacedObject,
    IPxiMx248BlockTransport)
  private
    fBridgeExecutable: string;
    fConfiguration: TPxiMx248Configuration;
    fChassis: LongInt;
    fSlot: LongInt;
    fIoTimeoutMs: Cardinal;
    fPayloadBuffer: array of Byte;
    fProcess: TProcess;
    fRequestId: Cardinal;
    fSampleCursor: QWord;
    fSessionPoisoned: Boolean;
    function Unsupported(const AStage: string): TRecorderOperationResult;
    function StartChild: TRecorderOperationResult;
    function ReadExact(var ABuffer; ACount, ATimeoutMs: Cardinal):
      TRecorderOperationResult;
    function ExchangeStarted(ACommand: Word; const APayload;
      APayloadSize, ATimeoutMs: Cardinal; out ADataOffset,
      ADataSize: Cardinal): TRecorderOperationResult;
    function Exchange(ACommand: Word; const APayload; APayloadSize,
      ATimeoutMs: Cardinal; out ADataOffset, ADataSize: Cardinal):
      TRecorderOperationResult;
    procedure PoisonChild;
    procedure StopChild;
  public
    constructor Create(AChassis, ASlot: Integer;
      const ABridgeExecutable: string = ''; AIoTimeoutMs: Cardinal = 5000);
    destructor Destroy; override;
    { Installer/startup smoke entry: starts the child and validates HELLO plus
      STATUS without opening hardware. }
    function CheckBridge: TRecorderOperationResult;
    function Discover(out ADevices: TPxiMx248DiscoveredDevices):
      TRecorderOperationResult;
    function Connect: TRecorderOperationResult;
    function Initialize(out ASerialNumber, AVersion: string):
      TRecorderOperationResult;
    function TestLink: TRecorderOperationResult;
    function SetModuleProperties(const AConfiguration: TPxiMx248Configuration):
      TRecorderOperationResult;
    function ProgramAcquisition(const AConfiguration: TPxiMx248Configuration):
      TRecorderOperationResult;
    function Start: TRecorderOperationResult;
    function Stop: TRecorderOperationResult;
    procedure Disconnect;
    function ReadBlock(ATimeoutMs: Cardinal;
      var ABlock: TRecorderAcquisitionBlock): TRecorderOperationResult;
  end;

function RecorderDiscoverPxiMx248(out ADevices: TPxiMx248DiscoveredDevices;
  const ABridgeExecutable: string = ''): TRecorderOperationResult;

implementation

function ResultCode(ACode: Cardinal): TRecorderOperationCode;
begin
  case ACode of
    1, 2: Result := rocProtocol;
    3: Result := rocUnsupported;
    4: Result := rocTransport;
    5: Result := rocInternal;
  else
    Result := rocProtocol;
  end;
end;

constructor TRecorderPxiMx248WindowsTransport.Create(AChassis, ASlot: Integer;
  const ABridgeExecutable: string; AIoTimeoutMs: Cardinal);
begin
  inherited Create;
  fChassis := AChassis;
  fSlot := ASlot;
  fIoTimeoutMs := AIoTimeoutMs;
  if fIoTimeoutMs = 0 then fIoTimeoutMs := 5000;
  if ABridgeExecutable <> '' then fBridgeExecutable := ABridgeExecutable
  else fBridgeExecutable := IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0))) + 'mx248' + PathDelim + 'vendor' +
    PathDelim + 'PxiMx248Bridge.exe';
  PxiMx248DefaultConfiguration(fConfiguration);
  SetLength(fPayloadBuffer, CPxiMx248BridgeMaxPayload);
end;

destructor TRecorderPxiMx248WindowsTransport.Destroy;
begin
  StopChild;
  inherited Destroy;
end;

function TRecorderPxiMx248WindowsTransport.CheckBridge:
  TRecorderOperationResult;
begin
  Result := StartChild;
end;

function ParseDiscoveryText(const AText: string;
  out ADevices: TPxiMx248DiscoveredDevices; out AError: string): Boolean;
var
  lRows, lFields: TStringList;
  I, lValue: Integer;
  lDevice: TPxiMx248DiscoveredDevice;
begin
  Result := False;
  AError := '';
  SetLength(ADevices, 0);
  if Trim(AText) = '' then Exit(True);
  lRows := TStringList.Create;
  lFields := TStringList.Create;
  try
    lRows.StrictDelimiter := True;
    lRows.Delimiter := ';';
    lRows.DelimitedText := AText;
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ',';
    for I := 0 to lRows.Count - 1 do
    begin
      lFields.DelimitedText := lRows[I];
      if lFields.Count <> 7 then
      begin
        AError := 'Invalid MX-248 discovery row: ' + lRows[I];
        Exit;
      end;
      lDevice.DeviceName := '';
      lDevice.DeviceIndex := 0;
      lDevice.SerialNumber := 0;
      lDevice.Revision := 0;
      lDevice.ChassisType := 0;
      lDevice.Chassis := 0;
      lDevice.Slot := 0;
      if not TryStrToInt(lFields[0], lDevice.DeviceIndex) or
        not TryStrToInt(lFields[1], lValue) or (lValue < 0) then
      begin
        AError := 'Invalid MX-248 discovery identity: ' + lRows[I];
        Exit;
      end;
      lDevice.SerialNumber := LongWord(lValue);
      if not TryStrToInt(lFields[2], lValue) or (lValue < 0) then
      begin
        AError := 'Invalid MX-248 revision: ' + lRows[I];
        Exit;
      end;
      lDevice.Revision := LongWord(lValue);
      lDevice.DeviceName := lFields[3];
      if not TryStrToInt(lFields[4], lDevice.ChassisType) or
        not TryStrToInt(lFields[5], lDevice.Chassis) or
        not TryStrToInt(lFields[6], lDevice.Slot) then
      begin
        AError := 'Invalid MX-248 route: ' + lRows[I];
        Exit;
      end;
      SetLength(ADevices, Length(ADevices) + 1);
      ADevices[High(ADevices)] := lDevice;
    end;
    Result := True;
  finally
    lFields.Free;
    lRows.Free;
  end;
end;

function TRecorderPxiMx248WindowsTransport.Discover(
  out ADevices: TPxiMx248DiscoveredDevices): TRecorderOperationResult;
const
  { DevAPI performs a synchronous PCI scan. On the reference MIC-315 this
    normally takes about five seconds, so the regular command timeout is not
    a valid discovery deadline. Keep runtime command latency independent. }
  CDiscoveryTimeoutMs = 30000;
var
  lEmpty: Byte;
  lOffset, lSize: Cardinal;
  lTimeoutMs: Cardinal;
  lText, lError: string;
begin
  SetLength(ADevices, 0);
  lEmpty := 0;
  lTimeoutMs := fIoTimeoutMs;
  if lTimeoutMs < CDiscoveryTimeoutMs then lTimeoutMs := CDiscoveryTimeoutMs;
  Result := Exchange(CPxiMx248CommandDiscover, lEmpty, 0, lTimeoutMs,
    lOffset, lSize);
  if not Result.IsSuccess then Exit;
  lText := '';
  if lSize > 0 then
    SetString(lText, PChar(@fPayloadBuffer[lOffset]), lSize);
  if not ParseDiscoveryText(lText, ADevices, lError) then
    Result := TRecorderOperationResult.Failure(rocProtocol,
      'mx248.discover.decode', lError);
end;

function RecorderDiscoverPxiMx248(out ADevices: TPxiMx248DiscoveredDevices;
  const ABridgeExecutable: string): TRecorderOperationResult;
var
  lTransport: TRecorderPxiMx248WindowsTransport;
begin
  lTransport := TRecorderPxiMx248WindowsTransport.Create(0, 0,
    ABridgeExecutable);
  try
    Result := lTransport.Discover(ADevices);
    lTransport.Disconnect;
  finally
    lTransport.Free;
  end;
end;

function TRecorderPxiMx248WindowsTransport.Unsupported(
  const AStage: string): TRecorderOperationResult;
begin
  Result := TRecorderOperationResult.Failure(rocUnsupported, AStage,
    'PXI MX-248 DevAPI bridge transport is available only on Windows');
end;

function TRecorderPxiMx248WindowsTransport.StartChild:
  TRecorderOperationResult;
var
  lOffset, lSize: Cardinal;
  lEmpty: Byte;
begin
  {$ifndef windows}
  Exit(Unsupported('mx248.bridge.start'));
  {$else}
  if fSessionPoisoned then
    Exit(TRecorderOperationResult.Failure(rocTransport, 'mx248.bridge.start',
      'IPC session is lost; disconnect and reconnect'));
  if Assigned(fProcess) and fProcess.Running then
    Exit(TRecorderOperationResult.Success);
  FreeAndNil(fProcess);
  if not FileExists(fBridgeExecutable) then
    Exit(TRecorderOperationResult.Failure(rocTransport, 'mx248.bridge.start',
      'Bridge executable not found: ' + fBridgeExecutable));
  fProcess := TProcess.Create(nil);
  fProcess.Executable := fBridgeExecutable;
  fProcess.Options := [poUsePipes, poNoConsole];
  try
    fProcess.Execute;
  except
    on E: Exception do
    begin
      FreeAndNil(fProcess);
      Exit(TRecorderOperationResult.Failure(rocTransport,
        'mx248.bridge.start', E.Message));
    end;
  end;
  lEmpty := 0;
  Result := ExchangeStarted(CPxiMx248CommandHello, lEmpty, 0,
    fIoTimeoutMs, lOffset, lSize);
  if Result.IsSuccess then
    Result := ExchangeStarted(CPxiMx248CommandStatus, lEmpty, 0,
      fIoTimeoutMs, lOffset, lSize);
  if not Result.IsSuccess then StopChild;
  {$endif}
end;

function TRecorderPxiMx248WindowsTransport.ReadExact(var ABuffer;
  ACount, ATimeoutMs: Cardinal): TRecorderOperationResult;
var
  lAvailable, lRead: LongInt;
  lBuffer: PByte;
  lDeadline: QWord;
  lDiscard: array[0..255] of Byte;
begin
  {$ifndef windows}
  Exit(Unsupported('mx248.bridge.read'));
  {$else}
  lBuffer := @ABuffer;
  lDeadline := GetTickCount64 + ATimeoutMs;
  while ACount > 0 do
  begin
    if not Assigned(fProcess) then
      Exit(TRecorderOperationResult.Failure(rocTransport,
        'mx248.bridge.read', 'Bridge process is not running'));
    while fProcess.Stderr.NumBytesAvailable > 0 do
    begin
      lAvailable := fProcess.Stderr.NumBytesAvailable;
      if lAvailable > SizeOf(lDiscard) then lAvailable := SizeOf(lDiscard);
      fProcess.Stderr.Read(lDiscard[0], lAvailable);
    end;
    lAvailable := fProcess.Output.NumBytesAvailable;
    if lAvailable > 0 then
    begin
      if Cardinal(lAvailable) > ACount then lAvailable := ACount;
      lRead := fProcess.Output.Read(lBuffer^, lAvailable);
      if lRead <= 0 then
        Exit(TRecorderOperationResult.Failure(rocTransport,
          'mx248.bridge.read', 'Bridge pipe closed'));
      Inc(lBuffer, lRead);
      Dec(ACount, lRead);
      Continue;
    end;
    if not fProcess.Running then
      Exit(TRecorderOperationResult.Failure(rocTransport,
        'mx248.bridge.read', 'Bridge process exited'));
    if GetTickCount64 >= lDeadline then
      Exit(TRecorderOperationResult.Failure(rocTimeout,
        'mx248.bridge.read', 'Bridge response timeout'));
    Sleep(1);
  end;
  Result := TRecorderOperationResult.Success;
  {$endif}
end;

function TRecorderPxiMx248WindowsTransport.ExchangeStarted(ACommand: Word;
  const APayload; APayloadSize, ATimeoutMs: Cardinal; out ADataOffset,
  ADataSize: Cardinal): TRecorderOperationResult;
var
  lHeader, lReply: TPxiMx248BridgeHeader;
  lHeaderBytes: array[0..CPxiMx248BridgeHeaderSize - 1] of Byte;
  lCode: Cardinal;
  lStage, lText, lError: string;
begin
  ADataOffset := 0;
  ADataSize := 0;
  if APayloadSize > CPxiMx248BridgeMaxPayload then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'mx248.bridge.write', 'Request payload exceeds 1 MiB'));
  Inc(fRequestId);
  if fRequestId = 0 then Inc(fRequestId);
  lHeader.Magic := CPxiMx248BridgeMagic;
  lHeader.Version := CPxiMx248BridgeVersion;
  lHeader.Command := ACommand;
  lHeader.RequestId := fRequestId;
  lHeader.PayloadSize := APayloadSize;
  PxiMx248EncodeHeader(lHeader, lHeaderBytes);
  try
    fProcess.Input.WriteBuffer(lHeaderBytes[0], SizeOf(lHeaderBytes));
    if APayloadSize > 0 then fProcess.Input.WriteBuffer(APayload, APayloadSize);
  except
    on E: Exception do
    begin
      Result := TRecorderOperationResult.Failure(rocTransport,
        'mx248.bridge.write', E.Message);
      PoisonChild;
      Exit;
    end;
  end;
  Result := ReadExact(lHeaderBytes[0], SizeOf(lHeaderBytes), ATimeoutMs);
  if not Result.IsSuccess then
  begin
    PoisonChild;
    Exit;
  end;
  if not PxiMx248DecodeHeader(lHeaderBytes, lReply, lError) then
  begin
    Result := TRecorderOperationResult.Failure(rocProtocol,
      'mx248.bridge.header', lError);
    PoisonChild;
    Exit;
  end;
  if (lReply.RequestId <> lHeader.RequestId) or
    (lReply.Command <> lHeader.Command) then
  begin
    Result := TRecorderOperationResult.Failure(rocProtocol,
      'mx248.bridge.header', 'Response request id or command mismatch');
    PoisonChild;
    Exit;
  end;
  if lReply.PayloadSize > 0 then
  begin
    Result := ReadExact(fPayloadBuffer[0], lReply.PayloadSize, ATimeoutMs);
    if not Result.IsSuccess then
    begin
      PoisonChild;
      Exit;
    end;
  end;
  if not PxiMx248DecodeResult(fPayloadBuffer, lReply.PayloadSize, lCode,
    lStage, lText, ADataOffset, ADataSize, lError) then
  begin
    Result := TRecorderOperationResult.Failure(rocProtocol,
      'mx248.bridge.result', lError);
    PoisonChild;
    Exit;
  end;
  if lCode <> 0 then
  begin
    Result := TRecorderOperationResult.Failure(ResultCode(lCode), lStage, lText);
    Exit;
  end;
  Result := TRecorderOperationResult.Success;
end;

procedure TRecorderPxiMx248WindowsTransport.PoisonChild;
begin
  fSessionPoisoned := True;
  {$ifdef windows}
  if not Assigned(fProcess) then Exit;
  if fProcess.Running then fProcess.Terminate(1);
  FreeAndNil(fProcess);
  {$endif}
end;

function TRecorderPxiMx248WindowsTransport.Exchange(ACommand: Word;
  const APayload; APayloadSize, ATimeoutMs: Cardinal; out ADataOffset,
  ADataSize: Cardinal): TRecorderOperationResult;
begin
  {$ifndef windows}
  Result := Unsupported('mx248.bridge');
  {$else}
  Result := StartChild;
  if Result.IsSuccess then
    Result := ExchangeStarted(ACommand, APayload, APayloadSize, ATimeoutMs,
      ADataOffset, ADataSize);
  {$endif}
end;

procedure TRecorderPxiMx248WindowsTransport.StopChild;
var
  lEmpty: Byte;
  lOffset, lSize: Cardinal;
  lDeadline: QWord;
begin
  {$ifdef windows}
  if not Assigned(fProcess) then Exit;
  if fProcess.Running then
  begin
    lEmpty := 0;
    ExchangeStarted(CPxiMx248CommandShutdown, lEmpty, 0, fIoTimeoutMs,
      lOffset, lSize);
    if not Assigned(fProcess) then Exit;
    lDeadline := GetTickCount64 + 250;
    while fProcess.Running and (GetTickCount64 < lDeadline) do Sleep(1);
    if fProcess.Running then fProcess.Terminate(1);
  end;
  FreeAndNil(fProcess);
  {$endif}
end;

function TRecorderPxiMx248WindowsTransport.Connect: TRecorderOperationResult;
var
  lPayload: array[0..7] of Byte;
  lSlotPayload: array[0..3] of Byte;
  lOffset, lSize: Cardinal;
begin
  PxiMx248EncodeInt32(fChassis, lPayload);
  PxiMx248EncodeInt32(fSlot, lSlotPayload);
  Move(lSlotPayload[0], lPayload[4], SizeOf(lSlotPayload));
  Result := Exchange(CPxiMx248CommandConnect, lPayload[0], SizeOf(lPayload),
    fIoTimeoutMs, lOffset, lSize);
end;

function DataText(const ABuffer: array of Byte; AOffset, ASize: Cardinal): string;
begin
  Result := '';
  if ASize > 0 then SetString(Result, PChar(@ABuffer[AOffset]), ASize);
end;

function PacketValue(const APacket, AName: string): string;
var
  lItems: TStringList;
begin
  Result := '';
  lItems := TStringList.Create;
  try
    lItems.StrictDelimiter := True;
    lItems.Delimiter := ';';
    lItems.DelimitedText := APacket;
    lItems.NameValueSeparator := '=';
    Result := lItems.Values[AName];
  finally
    lItems.Free;
  end;
end;

function TRecorderPxiMx248WindowsTransport.Initialize(out ASerialNumber,
  AVersion: string): TRecorderOperationResult;
var
  lEmpty: Byte;
  lOffset, lSize: Cardinal;
  lPacket: string;
begin
  ASerialNumber := '';
  AVersion := '';
  lEmpty := 0;
  Result := Exchange(CPxiMx248CommandInitialize, lEmpty, 0, fIoTimeoutMs,
    lOffset, lSize);
  if not Result.IsSuccess then Exit;
  lPacket := DataText(fPayloadBuffer, lOffset, lSize);
  ASerialNumber := PacketValue(lPacket, 'serial');
  AVersion := PacketValue(lPacket, 'version');
end;

function TRecorderPxiMx248WindowsTransport.TestLink:
  TRecorderOperationResult;
var
  lEmpty: Byte;
  lOffset, lSize: Cardinal;
begin
  lEmpty := 0;
  Result := Exchange(CPxiMx248CommandTest, lEmpty, 0, fIoTimeoutMs,
    lOffset, lSize);
end;

function TRecorderPxiMx248WindowsTransport.SetModuleProperties(
  const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
begin
  {$ifndef windows}
  Exit(Unsupported('mx248.configure.cache'));
  {$endif}
  fConfiguration := AConfiguration;
  Result := TRecorderOperationResult.Success;
end;

function TRecorderPxiMx248WindowsTransport.ProgramAcquisition(
  const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
var
  lPayload: array[0..79] of Byte;
  lOffset, lSize: Cardinal;
begin
  fConfiguration := AConfiguration;
  PxiMx248EncodeConfigure(fConfiguration, lPayload);
  Result := Exchange(CPxiMx248CommandConfigure, lPayload[0], SizeOf(lPayload),
    fIoTimeoutMs, lOffset, lSize);
end;

function TRecorderPxiMx248WindowsTransport.Start: TRecorderOperationResult;
var
  lEmpty: Byte;
  lOffset, lSize: Cardinal;
begin
  lEmpty := 0;
  Result := Exchange(CPxiMx248CommandStart, lEmpty, 0, fIoTimeoutMs,
    lOffset, lSize);
  if Result.IsSuccess then fSampleCursor := 0;
end;

function TRecorderPxiMx248WindowsTransport.Stop: TRecorderOperationResult;
var
  lEmpty: Byte;
  lOffset, lSize: Cardinal;
begin
  lEmpty := 0;
  Result := Exchange(CPxiMx248CommandStop, lEmpty, 0, fIoTimeoutMs,
    lOffset, lSize);
end;

procedure TRecorderPxiMx248WindowsTransport.Disconnect;
var
  lEmpty: Byte;
  lOffset, lSize: Cardinal;
begin
  if Assigned(fProcess) and fProcess.Running then
  begin
    lEmpty := 0;
    Exchange(CPxiMx248CommandDisconnect, lEmpty, 0, fIoTimeoutMs,
      lOffset, lSize);
  end;
  StopChild;
  fSessionPoisoned := False;
end;

function TRecorderPxiMx248WindowsTransport.ReadBlock(ATimeoutMs: Cardinal;
  var ABlock: TRecorderAcquisitionBlock): TRecorderOperationResult;
var
  lPayload: array[0..3] of Byte;
  lOffset, lSize: Cardinal;
  lError: string;
begin
  PxiMx248EncodeInt32(fConfiguration.BlockSamples, lPayload);
  Result := Exchange(CPxiMx248CommandReadBlock, lPayload[0], SizeOf(lPayload),
    ATimeoutMs, lOffset, lSize);
  if not Result.IsSuccess then Exit;
  if not PxiMx248DecodeBlock(fPayloadBuffer, lOffset, lSize,
    fConfiguration.SampleRateHz, ABlock, lError) then
  begin
    Result := TRecorderOperationResult.Failure(rocProtocol,
      'mx248.read.decode', lError);
    PoisonChild;
  end
  else
  begin
    if fConfiguration.SampleRateHz > 0 then
      ABlock.FirstTimeSec := fSampleCursor / fConfiguration.SampleRateHz
    else
      ABlock.FirstTimeSec := 0;
    Inc(fSampleCursor, ABlock.SampleCount);
  end;
end;

end.
