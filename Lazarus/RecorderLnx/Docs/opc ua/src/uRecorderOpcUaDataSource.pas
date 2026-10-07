unit uRecorderOpcUaDataSource;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderDataSources, uRecorderTags,
  uRecorderMessages,
  uRecorderDeviceInterfaces, uRecorderOpcUaDevice, uRecorderOpcUaTypes,
  uRecorderOpcUaApi;

type
  { Tag/worker adapter. The protocol session belongs to the device; this class
    only binds stable Recorder tags to device channels. }
  TRecorderOpcUaDataSource = class(TRecorderDataSourceBase,
    IRecorderMessageSource)
  private
    fDevice: IRecorderDevice;
    fNodeTags: array of TRecorderTag;
    fNodeMessages: array of TRecorderMessage;
    fMessageRegistry: TRecorderMessageRegistry;
    fWriteCursors: array of QWord;
    fLastWrittenValues: array of Double;
    fHasWrittenValues: array of Boolean;
    fNextPrepareAtMs: QWord;
    fPrepared: Boolean;
    fPrepareError: string;
    fBindingError: string;
    fLastSlowCycleLogMs: QWord;
    function OpcDevice: TRecorderOpcUaDevice;
    function BindServerNodes: Boolean;
    function FlushClientWrites: Boolean;
    procedure LogSlowCycle(AWriteMs, AReadMs: QWord);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ADevice: IRecorderDevice; AUpdateTimeMs: Cardinal);
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
    procedure ConfigureMessages(ARegistry: TRecorderMessageRegistry);
    property Device: IRecorderDevice read fDevice;
    property PrepareError: string read fPrepareError;
  end;

implementation

uses
  Math, uRecorderDebugLog;

const
  CRecorderOpcUaReconnectDelayMs = 5000;

constructor TRecorderOpcUaDataSource.Create(const ADevice: IRecorderDevice;
  AUpdateTimeMs: Cardinal);
begin
  if ADevice = nil then
    raise EArgumentNilException.Create('OPC UA device is required');
  fDevice := ADevice;
  inherited Create(ADevice.DeviceId, CRecorderOpcUaModuleType,
    Max(10, AUpdateTimeMs));
end;

function TRecorderOpcUaDataSource.OpcDevice: TRecorderOpcUaDevice;
begin
  Result := TRecorderOpcUaDevice(fDevice.GetNativeObject);
end;

procedure TRecorderOpcUaDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lName: string;
  lNode: TRecorderOpcUaNode;
begin
  fBindingError := '';
  SetLength(fNodeTags, OpcDevice.NodeCount);
  SetLength(fNodeMessages, OpcDevice.NodeCount);
  SetLength(fWriteCursors, OpcDevice.NodeCount);
  SetLength(fLastWrittenValues, OpcDevice.NodeCount);
  SetLength(fHasWrittenValues, OpcDevice.NodeCount);
  for I := 0 to OpcDevice.NodeCount - 1 do
  begin
    lNode := OpcDevice.Node(I);
    if RecorderOpcUaNodeIsMessage(lNode) then Continue;
    lName := lNode.TagName;
    if lName = '' then lName := lNode.NodeId;
    fNodeTags[I] := ARegistry.FindByName(lName);
    if OpcDevice.Config.Mode = oumServer then
    begin
      if fNodeTags[I] = nil then
        fBindingError := Format('OPC UA server tag "%s" was not found',
          [lName]);
      Continue;
    end;
    if fNodeTags[I] = nil then
      fNodeTags[I] := ARegistry.CreateTag(lName, 4096);
    fNodeTags[I].SourceId := SourceId;
    fNodeTags[I].Address := lNode.NodeId;
    fNodeTags[I].ModuleType := CRecorderOpcUaModuleType;
    fNodeTags[I].ExternalWriteAllowed := lNode.Writable;
    fNodeTags[I].PollFrequencyHz := 1000.0 /
      Max(10, OpcDevice.Config.PublishingIntervalMs);
    fWriteCursors[I] := fNodeTags[I].ExternalWriteCursor;
  end;
end;

procedure TRecorderOpcUaDataSource.ConfigureMessages(
  ARegistry: TRecorderMessageRegistry);
var
  I: Integer;
  lName: string;
  lNode: TRecorderOpcUaNode;
begin
  fMessageRegistry := ARegistry;
  SetLength(fNodeMessages, OpcDevice.NodeCount);
  if fMessageRegistry <> nil then
    fMessageRegistry.RemoveBySource(SourceId);
  for I := 0 to OpcDevice.NodeCount - 1 do
  begin
    lNode := OpcDevice.Node(I);
    if not RecorderOpcUaNodeIsMessage(lNode) then Continue;
    if fMessageRegistry = nil then
    begin
      fBindingError := 'OPC UA message registry is not configured';
      Exit;
    end;
    lName := lNode.TagName;
    if lName = '' then lName := lNode.NodeId;
    fNodeMessages[I] := fMessageRegistry.Add(lName, SourceId, lNode.NodeId,
      lNode.MessageKind, lNode.MessageColor);
  end;
end;

function TRecorderOpcUaDataSource.FlushClientWrites: Boolean;
var
  I, J, lCount, lChunkCount, lChunkStart, lMaxPerRequest: Integer;
  lCandidateCursor: QWord;
  lValue: Double;
  lHasValue: Boolean;
  lIndexes, lChunkIndexes: TRecorderOpcUaIntegerArray;
  lValues, lChunkValues: TRecorderOpcUaDoubleArray;
  lCursors: array of QWord;
begin
  Result := True;
  if OpcDevice.Config.Mode <> oumClient then Exit;
  Registry.BeginExternalWriteBatch;
  try
    SetLength(lIndexes, Length(fNodeTags));
    SetLength(lValues, Length(fNodeTags));
    SetLength(lCursors, Length(fNodeTags));
    lCount := 0;
    for I := 0 to High(fNodeTags) do
    begin
      if (fNodeTags[I] = nil) or not OpcDevice.Node(I).Writable then Continue;
      lCandidateCursor := fWriteCursors[I];
      lHasValue := False;
      while fNodeTags[I].ReadExternalWrite(lCandidateCursor, lValue) do
      begin
        if (not fHasWrittenValues[I]) or
          (not SameValue(fLastWrittenValues[I], lValue)) then
        begin
          lHasValue := True;
          Break;
        end;
        { Confirmed duplicates can be discarded immediately. A distinct
          press/release edge is retained until its WriteResponse succeeds. }
        fWriteCursors[I] := lCandidateCursor;
      end;
      if not lHasValue then Continue;
      lIndexes[lCount] := I;
      lValues[lCount] := lValue;
      lCursors[lCount] := lCandidateCursor;
      Inc(lCount);
    end;
    SetLength(lIndexes, lCount);
    SetLength(lValues, lCount);
    SetLength(lCursors, lCount);
  finally
    Registry.EndExternalWriteBatch;
  end;
  if lCount = 0 then Exit;
  lMaxPerRequest := Max(1, Integer(OpcDevice.Config.MaxNodesPerWrite));
  lChunkStart := 0;
  while lChunkStart < lCount do
  begin
    lChunkCount := Min(lMaxPerRequest, lCount - lChunkStart);
    SetLength(lChunkIndexes, lChunkCount);
    SetLength(lChunkValues, lChunkCount);
    for J := 0 to lChunkCount - 1 do
    begin
      lChunkIndexes[J] := lIndexes[lChunkStart + J];
      lChunkValues[J] := lValues[lChunkStart + J];
    end;
    if not OpcDevice.WriteClientValues(lChunkIndexes, lChunkValues) then
      Exit(False);
    for J := 0 to lChunkCount - 1 do
    begin
      I := lIndexes[lChunkStart + J];
      fWriteCursors[I] := lCursors[lChunkStart + J];
      fLastWrittenValues[I] := lValues[lChunkStart + J];
      fHasWrittenValues[I] := True;
    end;
    Inc(lChunkStart, lChunkCount);
  end;
end;

function TRecorderOpcUaDataSource.BindServerNodes: Boolean;
var
  I: Integer;
  lValue: Double;
begin
  Result := True;
  if OpcDevice.Config.Mode <> oumServer then Exit;
  for I := 0 to High(fNodeTags) do
  begin
    if fNodeTags[I] = nil then
    begin
      if RecorderOpcUaNodeIsMessage(OpcDevice.Node(I)) then
      begin
        fBindingError := 'OPC UA server mode does not support string messages';
        Exit(False);
      end;
      Exit(False);
    end;
    lValue := 0;
    if fNodeTags[I].SignalBuffer.Count > 0 then
      lValue := fNodeTags[I].SignalBuffer.LatestValue;
    if not OpcDevice.ConfigureServerNode(I, fNodeTags[I].Name, lValue) then
      Exit(False);
  end;
end;

procedure TRecorderOpcUaDataSource.LogSlowCycle(AWriteMs, AReadMs: QWord);
var
  lNow, lTotalMs: QWord;
begin
  lTotalMs := AWriteMs + AReadMs;
  if lTotalMs < UpdateTimeMs then Exit;
  lNow := GetTickCount64;
  if (fLastSlowCycleLogMs <> 0) and
    (lNow - fLastSlowCycleLogMs < 5000) then Exit;
  fLastSlowCycleLogMs := lNow;
  RecorderDebugLog(Format(
    '[OPC UA PERF] source=%s write=%d ms read=%d ms total=%d ms period=%d ms nodes=%d',
    [SourceId, AWriteMs, AReadMs, lTotalMs, UpdateTimeMs,
    OpcDevice.NodeCount]));
end;

procedure TRecorderOpcUaDataSource.PrepareHardware;
begin
  fPrepared := False;
  if (OpcDevice.Config.Mode = oumClient) and (OpcDevice.NodeCount = 0) then
  begin
    fPrepareError := 'Не выбраны OPC UA-каналы';
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  if fBindingError <> '' then
  begin
    fPrepareError := fBindingError;
    Exit;
  end;
  fPrepareError := '';
  fDevice.Disconnect;
  fDevice.Connect;
  if fDevice.State = rdsDisconnected then
  begin
    fPrepareError := OpcDevice.LastError;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  fDevice.InitializeDevice;
  fDevice.ConfigureDevice;
  if fDevice.State <> rdsProgrammed then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  if not BindServerNodes then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  fDevice.Start;
  fPrepared := fDevice.State = rdsStarted;
  if not fPrepared then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
  end;
  if fPrepared then fNextPrepareAtMs := 0;
  if (not fPrepared) and (fPrepareError <> '') then
    RecorderDebugLog(Format('[OPC UA] source=%s error=%s',
      [SourceId, fPrepareError]));
end;

procedure TRecorderOpcUaDataSource.Start;
begin
  if not fPrepared then PrepareHardware;
  { Expected network failures are retried by the worker and do not escape into
    the UI. This matches the MIC-140 source lifecycle. }
  inherited Start;
end;

procedure TRecorderOpcUaDataSource.DoTick;
var
  I: Integer;
  lQuality: Cardinal;
  lTime, lValue: Double;
  lText: string;
  lReadStartedMs, lWriteMs: QWord;
begin
  if not fPrepared then
  begin
    if GetTickCount64 < fNextPrepareAtMs then Exit;
    PrepareHardware;
    if not fPrepared then Exit;
  end;
  { A write is queued by Recorder code, but reaches the network only on this
    OPC source tick. Flush it before a potentially long multi-chunk read so a
    control command is not delayed by the complete acquisition scan. }
  lReadStartedMs := GetTickCount64;
  if (OpcDevice.Config.Mode = oumClient) and not FlushClientWrites then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fPrepared := False;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    RecorderDebugLog(Format(
      '[OPC UA] source=%s write failed; reconnect in %d ms: %s',
      [SourceId, CRecorderOpcUaReconnectDelayMs, fPrepareError]));
    Exit;
  end;
  lWriteMs := GetTickCount64 - lReadStartedMs;
  lReadStartedMs := GetTickCount64;
  if not OpcDevice.Iterate then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fPrepared := False;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    RecorderDebugLog(Format(
      '[OPC UA] source=%s connection lost; reconnect in %d ms: %s',
      [SourceId, CRecorderOpcUaReconnectDelayMs, fPrepareError]));
    Exit;
  end;
  LogSlowCycle(lWriteMs, GetTickCount64 - lReadStartedMs);
  if OpcDevice.Config.Mode = oumServer then
  begin
    for I := 0 to High(fNodeTags) do
      if (fNodeTags[I] <> nil) and (fNodeTags[I].SignalBuffer.Count > 0) then
        OpcDevice.WriteServerValue(I,
          fNodeTags[I].SignalBuffer.LatestValue);
    Exit;
  end;
  for I := 0 to High(fNodeTags) do
    if fNodeMessages[I] <> nil then
    begin
      if OpcDevice.ReadMessageChanged(I, lText, lTime, lQuality) then
        fMessageRegistry.Publish(fNodeMessages[I], lText, lTime, lQuality);
    end
    else if (fNodeTags[I] <> nil) and
      OpcDevice.ReadChanged(I, lValue, lTime, lQuality) then
      { OPC UA SourceTimestamp is absolute Unix time. Recorder tags use the
        project elapsed-time scale, which the registry supplies here. }
      Registry.PublishValue(fNodeTags[I], lValue);
end;

procedure TRecorderOpcUaDataSource.Stop;
begin
  fDevice.Stop;
  fPrepared := False;
  inherited Stop;
end;

end.
