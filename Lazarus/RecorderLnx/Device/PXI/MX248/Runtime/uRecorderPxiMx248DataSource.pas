unit uRecorderPxiMx248DataSource;

{
  RecorderLnx datasource for one production MX-248 adapter. ConfigureTags
  creates or reuses exactly eight stable tags. PrepareHardware owns the
  Connect -> Initialize -> Configure path; Start/Stop only control acquisition.

  DoTick reads and publishes complete blocks. Tag references and the time array
  are prepared before Start; the hot path performs no string lookup or resize.
  The device and transport remain connected across ordinary Start/Stop cycles.
  See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, uRecorderDataSources, uRecorderTags,
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uRecorderDriverContractsV2, uRecorderPxiMx248RuntimeTransport;

type
  TRecorderPxiMx248DataSource = class(TRecorderDataSourceBase,
    IRecorderZeroBalanceSupport, IPxiMx248RuntimeSettings)
  private
    fDevice: IRecorderDevice;
    fEnabled: array[0..7] of Boolean;
    fTags: array[0..7] of TRecorderTag;
    fTimes: array of Double;
    fSamplesPerTick: Double;
    fSampleDebt: Double;
    fPublishedBlocks: Int64;
    fLastReadError: string;
    function FindChannelTag(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure PublishBlock(const ABlock: TRcAcquisitionBlock);
    function TagName(AChannel: Integer): string;
    procedure PrepareRuntimeBuffers;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId: string; const ADevice: IRecorderDevice;
      AUpdateTimeMs: Cardinal);
    destructor Destroy; override;
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
    function ZeroBalanceTags(AOwner: TComponent; ATags: TList;
      AMessages: TStrings): Boolean;
    function RuntimeReadLiveProperties(out AProperties: string):
      TRcOperationResult;
    function RuntimeApplyLive(const AProperties: string; ARtsiClock,
      ARtsiSync, ATriggerMode, ATriggerSource, ATriggerLevel: Integer;
      out AReadback: string): TRcOperationResult;
    function RuntimeZeroBalance(AChannelMask: Cardinal; out AValues: string):
      TRcOperationResult;
  end;

implementation

uses
  Variants, uRecorderDebugLog, uRecorderPxiMx248Addressing,
  uRecorderHardwareLiveDevices;

function TRecorderPxiMx248DataSource.RuntimeReadLiveProperties(
  out AProperties: string): TRcOperationResult;
var
  lControl: IPxiMx248LiveControlDevice;
begin
  AProperties := '';
  if State = dssRunning then
    Exit(TRcOperationResult.Failure(rocInvalidState,
      'mx248.runtime.read', 'Stop acquisition before reading settings'));
  if fDevice.State = rdsDisconnected then PrepareHardware;
  if not Supports(fDevice, IPxiMx248LiveControlDevice, lControl) then
    Exit(TRcOperationResult.Failure(rocUnsupported,
      'mx248.runtime.read', 'Runtime device does not support live settings'));
  Result := lControl.ReadLiveProperties(AProperties);
end;

function TRecorderPxiMx248DataSource.RuntimeApplyLive(
  const AProperties: string; ARtsiClock, ARtsiSync, ATriggerMode,
  ATriggerSource, ATriggerLevel: Integer; out AReadback: string):
  TRcOperationResult;
var
  lControl: IPxiMx248LiveControlDevice;
begin
  AReadback := '';
  if State = dssRunning then
    Exit(TRcOperationResult.Failure(rocInvalidState,
      'mx248.runtime.apply', 'Stop acquisition before applying settings'));
  if fDevice.State = rdsDisconnected then PrepareHardware;
  if not Supports(fDevice, IPxiMx248LiveControlDevice, lControl) then
    Exit(TRcOperationResult.Failure(rocUnsupported,
      'mx248.runtime.apply', 'Runtime device does not support live settings'));
  Result := lControl.ApplyLive(AProperties, ARtsiClock, ARtsiSync,
    ATriggerMode, ATriggerSource, ATriggerLevel, AReadback);
  if Result.IsSuccess then PrepareRuntimeBuffers;
end;

function TRecorderPxiMx248DataSource.RuntimeZeroBalance(
  AChannelMask: Cardinal; out AValues: string): TRcOperationResult;
var
  lMaintenance: IPxiMx248MaintenanceDevice;
begin
  AValues := '';
  if State = dssRunning then
    Exit(TRcOperationResult.Failure(rocInvalidState,
      'mx248.runtime.zero', 'Stop acquisition before zero balance'));
  if fDevice.State = rdsDisconnected then PrepareHardware;
  if not Supports(fDevice, IPxiMx248MaintenanceDevice, lMaintenance) then
    Exit(TRcOperationResult.Failure(rocUnsupported,
      'mx248.runtime.zero', 'Runtime device does not support maintenance'));
  Result := lMaintenance.ZeroBalance(AChannelMask, AValues);
end;

function TRecorderPxiMx248DataSource.ZeroBalanceTags(AOwner: TComponent;
  ATags: TList; AMessages: TStrings): Boolean;
var
  I, lChannel: Integer;
  lMaintenance: IPxiMx248MaintenanceDevice;
  lMask: Cardinal;
  lResult: TRcOperationResult;
  lTag: TRecorderTag;
  lValues: string;
begin
  Result := False;
  lMask := 0;
  if (ATags = nil) or (ATags.Count = 0) then Exit;
  for I := 0 to ATags.Count - 1 do
  begin
    lTag := TRecorderTag(ATags[I]);
    if (lTag = nil) or not SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      RecorderNormalizeTagSourceId(SourceId)) or
      not PxiMx248TryChannelFromAddress(lTag.Address, lChannel) or
      (lChannel < 1) or (lChannel > 8) then Exit;
    lMask := lMask or (Cardinal(1) shl (lChannel - 1));
  end;
  if not Supports(fDevice, IPxiMx248MaintenanceDevice, lMaintenance) then Exit;
  lResult := lMaintenance.ZeroBalance(lMask, lValues);
  if AMessages <> nil then
  begin
    if lResult.IsSuccess then
      AMessages.Add('MX-248: балансировка выполнена: ' + lValues)
    else
      AMessages.Add('MX-248: ' + lResult.Stage + ': ' + lResult.MessageText);
  end;
  Result := lResult.IsSuccess;
end;

constructor TRecorderPxiMx248DataSource.Create(const ASourceId: string;
  const ADevice: IRecorderDevice; AUpdateTimeMs: Cardinal);
begin
  if ADevice = nil then
    raise EArgumentNilException.Create('MX-248 device is required');
  inherited Create(ASourceId, 'PXI MX-248', AUpdateTimeMs);
  fDevice := ADevice;
end;

destructor TRecorderPxiMx248DataSource.Destroy;
begin
  RecorderHardwareUnregisterLiveDevice(Self);
  if fDevice <> nil then fDevice.Disconnect;
  fDevice := nil;
  inherited Destroy;
end;

function TRecorderPxiMx248DataSource.TagName(AChannel: Integer): string;
begin
  Result := Format('%s AIn%d', [SourceId, AChannel + 1]);
end;

function TRecorderPxiMx248DataSource.FindChannelTag(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I, lChannel, lCandidateChannel: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      RecorderNormalizeTagSourceId(SourceId)) and
      SameText(Trim(lTag.Address), Trim(AAddress)) then
      Exit(lTag);
  end;
  if not PxiMx248TryChannelFromAddress(AAddress, lChannel) then Exit;
  { Migrate old numeric and old-alias addresses in-place. This preserves tag
    identity, user name, calibration pipeline and component references. }
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      RecorderNormalizeTagSourceId(SourceId)) and
      PxiMx248TryChannelFromAddress(lTag.Address, lCandidateChannel) and
      (lCandidateChannel = lChannel) then
      Exit(lTag);
  end;
end;

procedure TRecorderPxiMx248DataSource.DoCreateTags(
  ARegistry: TRecorderTagRegistry);
var
  I, lCapacity: Integer;
  lChannels: TRecorderDeviceChannelArray;
begin
  lChannels := fDevice.GetChannels;
  if Length(lChannels) <> Length(fTags) then
    raise ERecorderDataSourceError.Create('MX-248 must expose eight channels');
  lCapacity := Max(4096, Ceil(lChannels[0].PollFrequencyHz * 4));
  for I := 0 to High(fTags) do
  begin
    fTags[I] := FindChannelTag(ARegistry, lChannels[I].Address);
    if fTags[I] = nil then fTags[I] := ARegistry.CreateTag(TagName(I), lCapacity);
    fTags[I].EnsureBufferCapacity(lCapacity);
    fTags[I].SourceId := SourceId;
    fTags[I].Address := lChannels[I].Address;
    fTags[I].SourceUnitName := lChannels[I].UnitName;
    if fTags[I].AutoUnit then ARegistry.SyncTagAutoUnit(fTags[I], True);
    fTags[I].PollFrequencyHz := lChannels[I].PollFrequencyHz;
    fEnabled[I] := lChannels[I].Enabled;
  end;
end;

procedure TRecorderPxiMx248DataSource.PrepareHardware;
begin
  inherited PrepareHardware;
  if fDevice.State <> rdsProgrammed then
  begin
    fDevice.Connect;
    RecorderHardwareRegisterLiveDevice(Self, SourceId, fDevice);
    RecorderHardwareClearSourceOffline(SourceId);
    fDevice.InitializeDevice;
    fDevice.ConfigureDevice;
  end;
  PrepareRuntimeBuffers;
end;

procedure TRecorderPxiMx248DataSource.PrepareRuntimeBuffers;
var
  lBlockSamples, I: Integer;
  lText: string;
  lChannels: TRecorderDeviceChannelArray;
begin
  lText := fDevice.GetProp('block-samples');
  if not TryStrToInt(Copy(lText, Pos('=', lText) + 1, MaxInt), lBlockSamples) then
    lBlockSamples := Max(1, Round(UpdateTimeMs *
      Double(fDevice.GetDeviceProperty(rdpPollFrequencyHz)) / 1000.0));
  SetLength(fTimes, lBlockSamples);
  fSamplesPerTick := UpdateTimeMs *
    Double(fDevice.GetDeviceProperty(rdpPollFrequencyHz)) / 1000.0;
  fSampleDebt := 0;
  lChannels := fDevice.GetChannels;
  for I := 0 to High(fTags) do
    if (fTags[I] <> nil) and (I < Length(lChannels)) then
    begin
      fEnabled[I] := lChannels[I].Enabled;
      fTags[I].PollFrequencyHz := lChannels[I].PollFrequencyHz;
      fTags[I].EnsureBufferCapacity(Max(4096,
        Ceil(lChannels[I].PollFrequencyHz * 4)));
      fTags[I].SourceUnitName := lChannels[I].UnitName;
      if (Registry <> nil) and fTags[I].AutoUnit then
        Registry.SyncTagAutoUnit(fTags[I], True);
      if Registry <> nil then Registry.RebuildScales(fTags[I]);
    end;
end;

procedure TRecorderPxiMx248DataSource.Start;
begin
  inherited Start;
  if fDevice.State <> rdsProgrammed then
    raise ERecorderDataSourceError.Create('MX-248 hardware is not prepared');
  fSampleDebt := 0;
  fPublishedBlocks := 0;
  fLastReadError := '';
  fDevice.Start;
  RecorderDebugLog(Format('[MX248] source=%s stage=start rate=%g block=%d',
    [SourceId, Double(fDevice.GetDeviceProperty(rdpPollFrequencyHz)),
      Length(fTimes)]));
end;

procedure TRecorderPxiMx248DataSource.Stop;
begin
  if (fDevice <> nil) and (fDevice.State = rdsStarted) then fDevice.Stop;
  RecorderDebugLog(Format('[MX248] source=%s stage=stop published_blocks=%d',
    [SourceId,fPublishedBlocks]));
  inherited Stop;
end;

procedure TRecorderPxiMx248DataSource.PublishBlock(
  const ABlock: TRcAcquisitionBlock);
var
  I, J, lCount: Integer;
  lFirstTime, lRate: Double;
  lPreparedCount: Integer;
  lPreparedFirstTime, lPreparedRate: Double;
begin
  lPreparedCount := -1;
  lPreparedFirstTime := 0;
  lPreparedRate := 0;
  for I := 0 to High(fTags) do
    if (fTags[I] <> nil) and fEnabled[I] and (I <= High(ABlock.Values)) then
    begin
      lCount := RecorderBlockChannelSampleCount(ABlock, I);
      lRate := RecorderBlockChannelSampleRate(ABlock, I);
      lFirstTime := RecorderBlockChannelFirstTime(ABlock, I);
      if (lCount <= 0) or (lRate <= 0) or
        (lCount > Length(fTimes)) or (lCount > Length(ABlock.Values[I])) then
        raise ERecorderDataSourceError.Create('MX-248 block exceeds prepared buffers');
      { All MX-248 channels normally share one timebase. Rebuild only when
        explicit per-channel metadata actually differs. }
      if (lCount <> lPreparedCount) or (lFirstTime <> lPreparedFirstTime) or
        (lRate <> lPreparedRate) then
      begin
        for J := 0 to lCount - 1 do fTimes[J] := lFirstTime + J / lRate;
        lPreparedCount := lCount;
        lPreparedFirstTime := lFirstTime;
        lPreparedRate := lRate;
      end;
      Registry.PublishBlock(fTags[I], fTimes, ABlock.Values[I], lCount, False);
    end;
end;

procedure TRecorderPxiMx248DataSource.DoTick;
var
  lBlock: TRcAcquisitionBlock;
  lAttempts, lMaxAttempts: Integer;
  lError: string;
begin
  if fDevice.State <> rdsStarted then Exit;
  { One scheduler tick may represent many hardware blocks. Accumulate sample
    debt and drain enough complete blocks to keep the acquisition rate, rather
    than silently publishing only one small block per UI/data update period. }
  fSampleDebt := fSampleDebt + fSamplesPerTick;
  lAttempts := 0;
  lMaxAttempts := Max(1, Ceil(fSampleDebt / Max(1, Length(fTimes))) + 1);
  while (fSampleDebt >= 1.0) and (lAttempts < lMaxAttempts) do
  begin
    Inc(lAttempts);
    if not fDevice.ReadBlock(Max(Cardinal(1000), UpdateTimeMs * 4), lBlock) then
    begin
      lError := VarToStr(fDevice.GetDeviceProperty(rdpErrorText));
      if (lError <> '') and (lError <> fLastReadError) then
        RecorderDebugLog(Format('[MX248] source=%s stage=read error=%s',
          [SourceId,lError]));
      fLastReadError := lError;
      Break;
    end;
    fLastReadError := '';
    PublishBlock(lBlock);
    Inc(fPublishedBlocks);
    if (fPublishedBlocks <= 3) or (fPublishedBlocks mod 100 = 0) then
      RecorderDebugLog(Format('[MX248] source=%s stage=publish block=%d '+
        'samples=%d rate=%g ch1_first=%g ch1_last=%g',
        [SourceId,fPublishedBlocks,lBlock.SampleCount,lBlock.SampleRateHz,
          lBlock.Values[0][0],lBlock.Values[0][lBlock.SampleCount-1]]));
    { Keep a negative remainder when a full block exceeds this tick's target;
      it is credit for the following tick, not samples to read again. }
    fSampleDebt := fSampleDebt - lBlock.SampleCount;
  end;
end;

end.
