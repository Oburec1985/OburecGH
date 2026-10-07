unit uRecorderDacSession;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uRecorderDacTypes, uRecorderDacContracts;

type
  { Stable DAC lifecycle orchestrator. Pump is called by a backend worker or test. }
  TRecorderDacSession = class
  private
    fBackend: IRecorderDacBackend;
    fProvider: IRecorderDacSampleProvider;
    fMirror: IRecorderDacMirror;
    fConfig: TRecorderDacConfig;
    fBuffer: array of Double;
    fLastFrame: array of Double;
    fCounters: TRecorderDacCounters;
    fConfigured: Boolean;
    fMirrorQueue: array of Double;
    fMirrorFlushBuffer: array of Double;
    fMirrorCounts: array[0..3] of Integer;
    fMirrorRead: Integer;
    fMirrorWrite: Integer;
    fMirrorCount: Integer;
    fMirrorLock: TRTLCriticalSection;
    procedure ClampBlock(AFrameCount: Integer);
    procedure FillUnderrunBlock(out AFrameCount: Integer);
    procedure RememberLastFrame(AFrameCount: Integer);
    function EnqueueMirror(AFrameCount: Integer): Boolean;
  public
    constructor Create(const ABackend: IRecorderDacBackend;
      const AProvider: IRecorderDacSampleProvider;
      const AMirror: IRecorderDacMirror = nil);
    destructor Destroy; override;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function Start(out AResult: TRecorderDacResult): Boolean;
    function Pump(out AResult: TRecorderDacResult): Boolean;
    function FlushMirror(out AResult: TRecorderDacResult): Boolean;
    function Stop(out AResult: TRecorderDacResult): Boolean;
    procedure Abort;
    function Disconnect(out AResult: TRecorderDacResult): Boolean;
    function State: TRecorderDacState;
    property Counters: TRecorderDacCounters read fCounters;
  end;

implementation

constructor TRecorderDacSession.Create(const ABackend: IRecorderDacBackend;
  const AProvider: IRecorderDacSampleProvider; const AMirror: IRecorderDacMirror);
begin
  inherited Create;
  InitCriticalSection(fMirrorLock);
  fBackend := ABackend;
  fProvider := AProvider;
  fMirror := AMirror;
end;

destructor TRecorderDacSession.Destroy;
begin
  DoneCriticalSection(fMirrorLock);
  inherited Destroy;
end;

function TRecorderDacSession.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
var
  lMirrorIdentity: IRecorderDacMirrorIdentity;
  lSourceIdentity: IRecorderDacSourceIdentity;
begin
  Result := False;
  if (fBackend = nil) or (fProvider = nil) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC backend and provider are required');
    Exit;
  end;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  if Supports(fProvider, IRecorderDacSourceIdentity, lSourceIdentity) and
    Supports(fMirror, IRecorderDacMirrorIdentity, lMirrorIdentity) and
    (lSourceIdentity.SourceIdentity <> 0) and
    (lSourceIdentity.SourceIdentity = lMirrorIdentity.MirrorIdentity) then
  begin
    AResult := RecorderDacFailed(rdeFeedbackLoop, rdsgConfigure,
      'DAC input tag cannot also be its mirror tag');
    Exit;
  end;
  if fBackend.State = rdsConfigured then
    if not fBackend.Disconnect(AResult) then Exit;
  if not fProvider.Configure(AConfig, AResult) then Exit;
  if (fMirror <> nil) and not fMirror.Configure(AConfig, AResult) then Exit;
  if (fBackend.State = rdsClosed) and not fBackend.Connect(AResult) then Exit;
  if (fBackend.State = rdsConnected) and not fBackend.Initialize(AResult) then Exit;
  if (fBackend.State = rdsInitialized) and
    not fBackend.ReadProperties(AResult) then Exit;
  if not fBackend.Configure(AConfig, AResult) then Exit;
  fConfig := AConfig;
  SetLength(fBuffer, AConfig.FramesPerBlock * AConfig.ChannelCount);
  SetLength(fLastFrame, AConfig.ChannelCount);
  if fMirror <> nil then
  begin
    SetLength(fMirrorQueue, 4 * AConfig.FramesPerBlock * AConfig.ChannelCount);
    SetLength(fMirrorFlushBuffer, AConfig.FramesPerBlock * AConfig.ChannelCount);
  end
  else
  begin
    SetLength(fMirrorQueue, 0);
    SetLength(fMirrorFlushBuffer, 0);
  end;
  fMirrorRead := 0;
  fMirrorWrite := 0;
  fMirrorCount := 0;
  FillChar(fCounters, SizeOf(fCounters), 0);
  fConfigured := True;
  Result := True;
end;

function TRecorderDacSession.EnqueueMirror(AFrameCount: Integer): Boolean;
var
  lOffset: Integer;
  lSampleCount: Integer;
begin
  if fMirror = nil then Exit(False);
  EnterCriticalSection(fMirrorLock);
  try
    if fMirrorCount = Length(fMirrorCounts) then Exit(False);
    lSampleCount := AFrameCount * fConfig.ChannelCount;
    lOffset := fMirrorWrite * fConfig.FramesPerBlock * fConfig.ChannelCount;
    Move(fBuffer[0], fMirrorQueue[lOffset], lSampleCount * SizeOf(Double));
    fMirrorCounts[fMirrorWrite] := AFrameCount;
    fMirrorWrite := (fMirrorWrite + 1) mod Length(fMirrorCounts);
    Inc(fMirrorCount);
    Result := True;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
end;

function TRecorderDacSession.Start(out AResult: TRecorderDacResult): Boolean;
begin
  if not fConfigured then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgStart,
      'Configure DAC session before Start');
    Exit(False);
  end;
  fProvider.Reset;
  if fMirror <> nil then fMirror.Reset;
  Result := fBackend.Start(AResult);
end;

procedure TRecorderDacSession.ClampBlock(AFrameCount: Integer);
var
  I: Integer;
  lSampleCount: Integer;
begin
  lSampleCount := AFrameCount * fConfig.ChannelCount;
  for I := 0 to lSampleCount - 1 do
    if fBuffer[I] < fConfig.MinimumValue then
      fBuffer[I] := fConfig.MinimumValue
    else if fBuffer[I] > fConfig.MaximumValue then
      fBuffer[I] := fConfig.MaximumValue;
end;

procedure TRecorderDacSession.FillUnderrunBlock(out AFrameCount: Integer);
var
  I, lChannel: Integer;
begin
  AFrameCount := fConfig.FramesPerBlock;
  for I := 0 to AFrameCount - 1 do
    for lChannel := 0 to fConfig.ChannelCount - 1 do
      if fConfig.UnderrunPolicy = rdupHoldLast then
        fBuffer[I * fConfig.ChannelCount + lChannel] := fLastFrame[lChannel]
      else
        fBuffer[I * fConfig.ChannelCount + lChannel] := fConfig.SafeValue;
end;

procedure TRecorderDacSession.RememberLastFrame(AFrameCount: Integer);
var
  I, lOffset: Integer;
begin
  if AFrameCount <= 0 then Exit;
  lOffset := (AFrameCount - 1) * fConfig.ChannelCount;
  for I := 0 to fConfig.ChannelCount - 1 do
    fLastFrame[I] := fBuffer[lOffset + I];
end;

function TRecorderDacSession.Pump(out AResult: TRecorderDacResult): Boolean;
var
  lFrameCount: Integer;
  lProviderResult: TRecorderDacResult;
begin
  if fBackend.State <> rdsRunning then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgWrite,
      'DAC session is not running');
    Exit(False);
  end;
  Inc(fCounters.RequestedFrames, fConfig.FramesPerBlock);
  if not fProvider.FillBlock(@fBuffer[0], fConfig.FramesPerBlock,
    lFrameCount, lProviderResult) then
  begin
    Inc(fCounters.Underruns);
    if fConfig.UnderrunPolicy = rdupStop then
    begin
      AResult := lProviderResult;
      Exit(False);
    end;
    FillUnderrunBlock(lFrameCount);
  end;
  if (lFrameCount <= 0) or (lFrameCount > fConfig.FramesPerBlock) then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'DAC provider returned an invalid frame count');
    Exit(False);
  end;
  ClampBlock(lFrameCount);
  RememberLastFrame(lFrameCount);
  if not fBackend.SubmitBlock(@fBuffer[0], lFrameCount, AResult) then Exit(False);
  Inc(fCounters.SubmittedFrames, lFrameCount);
  if (fMirror <> nil) and not EnqueueMirror(lFrameCount) then
    Inc(fCounters.DroppedMirrorBlocks);
  Result := True;
end;

function TRecorderDacSession.FlushMirror(
  out AResult: TRecorderDacResult): Boolean;
var
  lFrameCount: Integer;
  lOffset: Integer;
begin
  if fMirror = nil then
  begin
    AResult := RecorderDacOk;
    Exit(False);
  end;
  EnterCriticalSection(fMirrorLock);
  try
    if fMirrorCount = 0 then
    begin
      AResult := RecorderDacOk;
      Exit(False);
    end;
    lFrameCount := fMirrorCounts[fMirrorRead];
    lOffset := fMirrorRead * fConfig.FramesPerBlock * fConfig.ChannelCount;
    Move(fMirrorQueue[lOffset], fMirrorFlushBuffer[0],
      lFrameCount * fConfig.ChannelCount * SizeOf(Double));
    fMirrorRead := (fMirrorRead + 1) mod Length(fMirrorCounts);
    Dec(fMirrorCount);
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
  Result := fMirror.WriteBlock(@fMirrorFlushBuffer[0], lFrameCount, AResult);
  if Result then Inc(fCounters.MirroredFrames, lFrameCount);
end;

function TRecorderDacSession.Stop(out AResult: TRecorderDacResult): Boolean;
begin
  Result := fBackend.Stop(AResult);
end;

procedure TRecorderDacSession.Abort;
begin
  fBackend.Abort;
end;

function TRecorderDacSession.State: TRecorderDacState;
begin
  Result := fBackend.State;
end;

function TRecorderDacSession.Disconnect(out AResult: TRecorderDacResult): Boolean;
begin
  if fBackend.State = rdsRunning then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgDisconnect,
      'Stop DAC session before disconnect');
    Exit(False);
  end;
  fConfigured := False;
  Result := fBackend.Disconnect(AResult);
end;

end.
