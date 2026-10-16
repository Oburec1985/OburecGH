unit uRecorderPxiMx248ConfiguredEditor;

{
  Composition adapter between the generic configured-source editor registry
  and the MX-248 offline settings dialog. It persists one validated canonical
  property packet; hardware I/O remains owned by the runtime datasource.

  Source ids use pxi-mx248:<chassis>:<slot>, where chassis is the DevAPI
  CrateSlot.CCSN and slot is CrateSlot.SlotNo. The bridge resolves this stable
  route after each discovery; discovery array order is never persisted.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderTags, uRecorderDriverContractsV2;

type
  { Short names are local to the MX-248 API. The underlying Recorder contracts
    stay unchanged, so this unit does not force a repository-wide rename. }
  TRcResult = TRcOperationResult;
  TRcTags = TRecorderTagRegistry;

const
  CRcMx248ModuleType = 'PXI MX-248';

function RcMx248SourceId(AChassis, ASlot: Integer): string;
function TryParseRcMx248SourceId(const ASourceId: string;
  out AChassis, ASlot: Integer): Boolean;
function RcApplyMx248Draft(ARegistry: TRcTags;
  const AOldSourceId, ASourceId: string; AChassis, ASlot: Integer;
  const AProperties: string): TRcResult;

implementation

uses
  Classes, SysUtils, uRecorderDataSources,
  uRecorderConfiguredDataSources, uRecorderConfiguredSourceEditor,
  uRecorderPxiMx248SettingsService,
  uRecorderPxiMx248SettingsDialog, uRecorderPxiMx248Types,
  uRecorderPxiMx248Properties, uRecorderPxiMx248Addressing,
  uRecorderPxiMx248WindowsTransport, uRecorderPxiMx248RuntimeTransport;

type
  TRcSources = TRecorderDataSourceManager;

  TPxiMx248ConfiguredSettingsService = class(TInterfacedObject,
    IPxiMx248SettingsService)
  private
    fAppliedSourceId: string;
    fDataSources: TRcSources;
    fOldSourceId: string;
    fRegistry: TRcTags;
  public
    constructor Create(ARegistry: TRcTags; const AOldSourceId: string;
      ADataSources: TRcSources);
    function ApplyDraft(const ASourceId: string; AChassis, ASlot: Integer;
      const AProperties: string): TRcResult;
    function Discover(out ADevices: TPxiMx248DiscoveredDevices): TRcResult;
    function ReadLiveProperties(AChassis, ASlot: Integer;
      out AProperties: string): TRcResult;
    function ApplyLiveDraft(AChassis, ASlot: Integer;
      const AProperties: string; out AReadback: string): TRcResult;
    function ZeroBalance(AChassis, ASlot: Integer; AChannelMask: Cardinal;
      out AValues: string): TRcResult;
    property AppliedSourceId: string read fAppliedSourceId;
  end;

  TPxiMx248ConfiguredSourceEditor = class(TInterfacedObject,
    IRecorderConfiguredSourceEditor)
  public
    function SupportsSource(const ASourceId, AModuleType: string): Boolean;
    function EditSource(AOwner: TComponent; ARegistry: TRecorderTagRegistry;
      const ASourceId: string; out ANewSourceId: string;
      ADataSources: TRecorderDataSourceManager): Boolean;
  end;

function RcMx248SourceId(AChassis, ASlot: Integer): string;
begin
  Result := Format('pxi-mx248:%d:%d', [AChassis, ASlot]);
end;

function TPxiMx248ConfiguredSettingsService.Discover(
  out ADevices: TPxiMx248DiscoveredDevices): TRcResult;
begin
  Result := RecorderDiscoverPxiMx248(ADevices);
end;

function OpenInitializedTransport(AChassis,ASlot: Integer;
  out ATransport: TRecorderPxiMx248WindowsTransport): TRcResult;
var
  lSerial,lVersion: string;
begin
  ATransport:=TRecorderPxiMx248WindowsTransport.Create(AChassis,ASlot);
  Result:=ATransport.Connect;
  if Result.IsSuccess then Result:=ATransport.Initialize(lSerial,lVersion);
  if Result.IsSuccess then Result:=ATransport.TestLink;
  if not Result.IsSuccess then begin
    ATransport.Disconnect;
    FreeAndNil(ATransport)
  end
end;

function TPxiMx248ConfiguredSettingsService.ReadLiveProperties(AChassis,
  ASlot: Integer; out AProperties: string): TRcResult;
var
  lTransport: TRecorderPxiMx248WindowsTransport;
  lSource: IRecorderDataSource;
  lRuntime: IPxiMx248RuntimeSettings;
begin
  AProperties:='';
  if fDataSources <> nil then
  begin
    lSource := fDataSources.FindSource(RcMx248SourceId(AChassis, ASlot));
    if (lSource <> nil) and Supports(lSource, IPxiMx248RuntimeSettings, lRuntime) then
      Exit(lRuntime.RuntimeReadLiveProperties(AProperties));
  end;
  lTransport:=nil;
  Result:=OpenInitializedTransport(AChassis,ASlot,lTransport);
  if not Result.IsSuccess then Exit;
  try
    Result:=lTransport.ReadLiveProperties(AProperties)
  finally
    lTransport.Disconnect;
    lTransport.Free
  end
end;

function PacketValue(const APacket,AName: string): string;
var
  lValues: TStringList;
begin
  lValues:=TStringList.Create;
  try
    lValues.StrictDelimiter:=True;
    lValues.Delimiter:=';';
    lValues.DelimitedText:=APacket;
    lValues.NameValueSeparator:='=';
    Result:=lValues.Values[AName]
  finally
    lValues.Free
  end
end;

function AcquisitionPacket(const APacket: string): string;
var
  lValues: TStringList;
  I: Integer;
begin
  Result:='';
  lValues:=TStringList.Create;
  try
    lValues.StrictDelimiter:=True;
    lValues.Delimiter:=';';
    lValues.DelimitedText:=APacket;
    lValues.NameValueSeparator:='=';
    for I:=0 to lValues.Count-1 do
      if Pos('pxi.',LowerCase(Trim(lValues.Names[I])))<>1 then begin
        if Result<>'' then Result:=Result+';';
        Result:=Result+lValues[I]
      end
  finally
    lValues.Free
  end
end;

function WithoutTransientAddress(const APacket: string): string;
var
  lValues: TStringList;
  I: Integer;
begin
  Result := '';
  lValues := TStringList.Create;
  try
    lValues.StrictDelimiter := True;
    lValues.Delimiter := ';';
    lValues.DelimitedText := APacket;
    lValues.NameValueSeparator := '=';
    for I := 0 to lValues.Count - 1 do
      if not SameText(Trim(lValues.Names[I]), CPxiMx248SourceAddressKey) then
      begin
        if Result <> '' then Result := Result + ';';
        Result := Result + lValues[I];
      end;
  finally
    lValues.Free;
  end;
end;

function ParseTriggerSource(const AValue: string; out AMode,
  ASource: Integer): Boolean;
var
  lSuffix: string;
begin
  AMode:=2; { off means no external trigger; the software Start still pulses }
  ASource:=0;
  if SameText(Trim(AValue),'off') then Exit(True);
  if Pos('pxi_trig',LowerCase(Trim(AValue)))<>1 then Exit(False);
  lSuffix:=Copy(Trim(AValue),Length('PXI_TRIG')+1,MaxInt);
  Result:=TryStrToInt(lSuffix,ASource) and (ASource>=0) and (ASource<=7);
  if Result then AMode:=2 { TRIG_INTERNAL: trigger received from PXI }
end;

function TPxiMx248ConfiguredSettingsService.ApplyLiveDraft(AChassis,
  ASlot: Integer; const AProperties: string; out AReadback: string):
  TRcResult;
var
  lStore: TPxiMx248PropertyStore;
  lCanonical: string;
  lConfiguration: TPxiMx248Configuration;
  lTransport: TRecorderPxiMx248WindowsTransport;
  lRtsiClock,lRtsiSync,lTriggerMode,lTriggerSource,lTriggerLevel: Integer;
  lSource: IRecorderDataSource;
  lRuntime: IPxiMx248RuntimeSettings;
begin
  AReadback:='';
  lSource := nil;
  if (fRegistry <> nil) and
    (RecorderConfiguredDataSourcesFind(fRegistry,
      RcMx248SourceId(AChassis, ASlot)) <> nil) and
    not SameText(RecorderNormalizeTagSourceId(fOldSourceId),
      RecorderNormalizeTagSourceId(RcMx248SourceId(AChassis,
        ASlot))) then
    Exit(TRcOperationResult.Failure(rocInvalidArgument,
      'mx248.settings.route',
      'Эта физическая плата уже привязана к другому узлу'));
  lStore:=TPxiMx248PropertyStore.Create(nil);
  try
    Result:=lStore.CalcProperties(AcquisitionPacket(AProperties),lCanonical);
    if Result.IsSuccess then Result:=lStore.CurrentConfiguration(lConfiguration)
  finally
    lStore.Free
  end;
  if not Result.IsSuccess then Exit;

  if SameText(PacketValue(AProperties,'pxi.clock-source'),'PXI_CLK10') then
    lRtsiClock:=0 { RTSI_SLAVE }
  else lRtsiClock:=3; { RTSI_OFF: local clock }
  if SameText(PacketValue(AProperties,'pxi.bus-role'),'Slave') then
    lRtsiSync:=0
  else if SameText(PacketValue(AProperties,'pxi.bus-role'),'Hardwired') then
    lRtsiSync:=2
  else
    lRtsiSync:=1; { original single-board default: Master }
  if not ParseTriggerSource(PacketValue(AProperties,'pxi.trigger-line'),
    lTriggerMode,lTriggerSource) then
    Exit(TRcOperationResult.Failure(rocInvalidArgument,
      'mx248.settings.trigger','Expected off or PXI_TRIG0..PXI_TRIG7'));
  if SameText(PacketValue(AProperties,'pxi.trigger-level'),'high') or
     SameText(PacketValue(AProperties,'pxi.trigger-edge'),'rising') then
    lTriggerLevel:=1
  else
    lTriggerLevel:=0;

  if fDataSources <> nil then
  begin
    lSource := fDataSources.FindSource(RcMx248SourceId(AChassis,
      ASlot));
    if (lSource <> nil) and Supports(lSource, IPxiMx248RuntimeSettings,
      lRuntime) then
      Exit(lRuntime.RuntimeApplyLive(AcquisitionPacket(AProperties),
        lRtsiClock, lRtsiSync, lTriggerMode, lTriggerSource, lTriggerLevel,
        AReadback));
  end;

  lTransport:=nil;
  Result:=OpenInitializedTransport(AChassis,ASlot,lTransport);
  if not Result.IsSuccess then Exit;
  try
    Result:=lTransport.ProgramAcquisition(lConfiguration);
    if Result.IsSuccess then
      { SEV is unused by this dialog. Keep it off; CLK/SYNC express the two
        explicit UI choices and trigger mode/source express the selected line. }
      Result:=lTransport.ConfigurePxi(3,lRtsiClock,lRtsiSync,
        lTriggerMode,lTriggerSource,lTriggerLevel);
    if Result.IsSuccess then Result:=lTransport.ReadLiveProperties(AReadback)
  finally
    lTransport.Disconnect;
    lTransport.Free
  end
end;

function TPxiMx248ConfiguredSettingsService.ZeroBalance(AChassis,
  ASlot: Integer; AChannelMask: Cardinal; out AValues: string):
  TRcResult;
var
  lTransport: TRecorderPxiMx248WindowsTransport;
  lSource: IRecorderDataSource;
  lRuntime: IPxiMx248RuntimeSettings;
begin
  AValues:='';
  if fDataSources <> nil then
  begin
    lSource := fDataSources.FindSource(RcMx248SourceId(AChassis,
      ASlot));
    if (lSource <> nil) and Supports(lSource, IPxiMx248RuntimeSettings,
      lRuntime) then
      Exit(lRuntime.RuntimeZeroBalance(AChannelMask, AValues));
  end;
  lTransport:=nil;
  Result:=OpenInitializedTransport(AChassis,ASlot,lTransport);
  if not Result.IsSuccess then Exit;
  try
    Result:=lTransport.ZeroBalance(AChannelMask,AValues)
  finally
    lTransport.Disconnect;
    lTransport.Free
  end
end;

function TryParseRcMx248SourceId(const ASourceId: string;
  out AChassis, ASlot: Integer): Boolean;
var
  lItems: TStringList;
begin
  AChassis := 0;
  ASlot := 0;
  lItems := TStringList.Create;
  try
    lItems.StrictDelimiter := True;
    lItems.Delimiter := ':';
    lItems.DelimitedText := LowerCase(Trim(ASourceId));
    Result := (lItems.Count = 3) and (lItems[0] = 'pxi-mx248') and
      TryStrToInt(lItems[1], AChassis) and (AChassis >= 0) and
      TryStrToInt(lItems[2], ASlot) and (ASlot >= 0);
  finally
    lItems.Free;
  end;
end;

constructor TPxiMx248ConfiguredSettingsService.Create(
  ARegistry: TRcTags; const AOldSourceId: string;
  ADataSources: TRcSources);
begin
  inherited Create;
  fRegistry := ARegistry;
  fOldSourceId := AOldSourceId;
  fDataSources := ADataSources;
end;

function RcApplyMx248Draft(ARegistry: TRcTags;
  const AOldSourceId, ASourceId: string; AChassis, ASlot: Integer;
  const AProperties: string):
  TRcResult;
var
  I, lChannel, lExistingChannel: Integer;
  lEntry, lExistingEntry: TRecorderConfiguredDataSource;
  lSourceId, lSourceAddress, lRule, lPersisted, lAddress: string;
  lTag: TRecorderTag;
  lFound: Boolean;
  lRate: Double;
begin
  if ARegistry = nil then
    Exit(TRcOperationResult.Failure(rocInvalidState,
      'mx248.settings.persist', 'Tag registry is not available'));
  lSourceId := RcMx248SourceId(AChassis, ASlot);
  if not SameText(Trim(ASourceId), lSourceId) then
    Exit(TRcOperationResult.Failure(rocInvalidArgument,
      'mx248.settings.source', 'Source ID must match chassis and slot'));
  { One physical route may have only one configured owner. This check is
    deliberately before Ensure so a rejected Apply is fully non-mutating. }
  lExistingEntry := RecorderConfiguredDataSourcesFind(ARegistry, lSourceId);
  if (lExistingEntry <> nil) and
    not SameText(RecorderNormalizeTagSourceId(AOldSourceId),
      RecorderNormalizeTagSourceId(lSourceId)) then
    Exit(TRcOperationResult.Failure(rocInvalidArgument,
      'mx248.settings.route', 'Эта физическая плата уже привязана к другому узлу'));
  lRule := PxiMx248NormalizeAddressRule(PacketValue(AProperties,
    CPxiMx248AddressRuleKey));
  lSourceAddress := Trim(PacketValue(AProperties,
    CPxiMx248SourceAddressKey));
  if lSourceAddress = '' then
    lSourceAddress := PxiMx248DefaultSourceAddress(1, AChassis, lRule);
  if not PxiMx248ValidSourceAddress(lSourceAddress) then
    Exit(TRcOperationResult.Failure(rocInvalidArgument,
      'mx248.settings.address', 'Некорректный алиас платы'));
  lPersisted := WithoutTransientAddress(AProperties);
  { Prepare and persist the destination before touching the old identity.
    This keeps tag bindings intact if allocation/validation of the target fails. }
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, lSourceId,
    CRcMx248ModuleType);
  if lEntry = nil then
    Exit(TRcOperationResult.Failure(rocInternal,
      'mx248.settings.persist', 'Could not create configured source'));
  lEntry.SpecificConfigText := lPersisted;
  lEntry.SourceAddress := lSourceAddress;
  lEntry.Enabled := True;
  if (AOldSourceId <> '') and not SameText(AOldSourceId, lSourceId) then
  begin
    { Route changes must preserve published tag objects and their user names,
      calibrations and references. Only the source binding is re-keyed. }
    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      if SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
        RecorderNormalizeTagSourceId(AOldSourceId)) then
        lTag.SourceId := lSourceId;
    end;
    RecorderConfiguredDataSourcesRemove(ARegistry, AOldSourceId);
  end;
  lRate := StrToFloatDef(PacketValue(AProperties, 'sample-rate-hz'),
    CPxiMx248DefaultSampleRateHz);
  lEntry.DefaultPollFrequencyHz := lRate;
  { Publish/migrate all eight bindings immediately. A settings Apply therefore
    updates the channel list without waiting for a datasource restart. }
  for lChannel := 1 to CPxiMx248ChannelCount do
  begin
    lAddress := PxiMx248ChannelAddress(lSourceAddress, lChannel);
    lTag := nil;
    lFound := False;
    for I := 0 to ARegistry.TagCount - 1 do
      if SameText(RecorderNormalizeTagSourceId(ARegistry.Tags[I].SourceId),
        RecorderNormalizeTagSourceId(lSourceId)) and
        PxiMx248TryChannelFromAddress(ARegistry.Tags[I].Address,
          lExistingChannel) and (lExistingChannel = lChannel) then
      begin
        lTag := ARegistry.Tags[I];
        lFound := True;
        Break;
      end;
    if not lFound then
      lTag := ARegistry.CreateTag(Format('%s AIn%d', [lSourceAddress,
        lChannel]), 4096);
    lTag.SourceId := lSourceId;
    lTag.Address := lAddress;
    lTag.ModuleType := CRcMx248ModuleType;
    lTag.PollFrequencyHz := lRate;
    lTag.UnitName := 'V';
  end;
  { A successfully linked board is immediately visible to channel/tag views.
    Runtime link checks may later mark it offline, but must not hide the tags
    during the same settings transaction. }
  ARegistry.RegisterActiveSource(lSourceId);
  Result := TRcOperationResult.Success;
end;

function TPxiMx248ConfiguredSettingsService.ApplyDraft(const ASourceId: string;
  AChassis, ASlot: Integer; const AProperties: string):
  TRcOperationResult;
begin
  Result := RcApplyMx248Draft(fRegistry, fOldSourceId,
    ASourceId, AChassis, ASlot, AProperties);
  if Result.IsSuccess then
    fAppliedSourceId := RcMx248SourceId(AChassis, ASlot);
end;

function TPxiMx248ConfiguredSourceEditor.SupportsSource(const ASourceId,
  AModuleType: string): Boolean;
var
  lChassis, lSlot: Integer;
begin
  Result := SameText(AModuleType, CRcMx248ModuleType) or
    TryParseRcMx248SourceId(ASourceId, lChassis, lSlot);
end;

function TPxiMx248ConfiguredSourceEditor.EditSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string; ADataSources: TRecorderDataSourceManager): Boolean;
var
  lChassis, lSlot: Integer;
  lEntry: TRecorderConfiguredDataSource;
  lProperties: string;
  lServiceObject: TPxiMx248ConfiguredSettingsService;
  lService: IPxiMx248SettingsService;
begin
  ANewSourceId := ASourceId;
  lChassis := 0;
  lSlot := 0;
  TryParseRcMx248SourceId(ASourceId, lChassis, lSlot);
  lProperties := '';
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  if lEntry <> nil then
  begin
    lProperties := lEntry.SpecificConfigText;
    if lProperties <> '' then lProperties := lProperties + ';';
    lProperties := lProperties + CPxiMx248SourceAddressKey + '=' +
      Trim(lEntry.SourceAddress);
  end;
  lServiceObject := TPxiMx248ConfiguredSettingsService.Create(ARegistry,
    ASourceId, ADataSources);
  lService := lServiceObject;
  Result := ShowPxiMx248SettingsDialog(AOwner, ASourceId, lProperties,
    lChassis, lSlot, lService);
  if Result then ANewSourceId := lServiceObject.AppliedSourceId;
  lService := nil;
end;

initialization
  RecorderRegisterConfiguredSourceEditor(TPxiMx248ConfiguredSourceEditor.Create);

end.
