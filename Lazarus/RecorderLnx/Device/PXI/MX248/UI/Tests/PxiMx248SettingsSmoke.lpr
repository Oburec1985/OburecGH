program PxiMx248SettingsSmoke;

{
  Headless-friendly construction smoke for the MX-248 LCL settings editor.
  It verifies LFM loading, default schema validation and the single apply
  callback boundary. See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, SysUtils,
  uRecorderDriverContractsV2, uRecorderPxiMx248SettingsService,
  uRecorderPxiMx248SettingsDialog, uRecorderPxiMx248Types,
  uRecorderPxiMx248ConfiguredEditor, uRecorderConfiguredDataSources,
  uRecorderPxiMx248Addressing, uRecorderTags;

type
  TApplyProbe = class(TInterfacedObject, IPxiMx248SettingsService)
  public
    CallCount: Integer;
    LastSourceId: string;
    LastChassis: Integer;
    LastSlot: Integer;
    LastProperties: string;
    LastLiveProperties: string;
    function ApplyDraft(const ASourceId: string; AChassis, ASlot: Integer;
      const AProperties: string): TRcOperationResult;
    function Discover(out ADevices: TPxiMx248DiscoveredDevices):
      TRcOperationResult;
    function ReadLiveProperties(AChassis, ASlot: Integer;
      out AProperties: string): TRcOperationResult;
    function ApplyLiveDraft(AChassis, ASlot: Integer;
      const AProperties: string; out AReadback: string): TRcOperationResult;
    function ZeroBalance(AChassis, ASlot: Integer; AChannelMask: Cardinal;
      out AValues: string): TRcOperationResult;
  end;

function TApplyProbe.ApplyDraft(const ASourceId: string; AChassis,
  ASlot: Integer; const AProperties: string): TRcOperationResult;
begin
  Inc(CallCount);
  LastSourceId := ASourceId;
  LastChassis := AChassis;
  LastSlot := ASlot;
  LastProperties := AProperties;
  Result := TRcOperationResult.Success;
end;

function TApplyProbe.ReadLiveProperties(AChassis, ASlot: Integer;
  out AProperties: string): TRcOperationResult;
begin
  AProperties := 'sample-rate-hz=512000';
  Result := TRcOperationResult.Success;
end;

function TApplyProbe.ApplyLiveDraft(AChassis, ASlot: Integer;
  const AProperties: string; out AReadback: string): TRcOperationResult;
begin
  LastLiveProperties := AProperties;
  AReadback := 'sample-rate-hz=512000;trigger-mode=2;trigger-source=3;' +
    'trigger-level=0;rtsi-sync=1';
  Result := TRcOperationResult.Success;
end;

function TApplyProbe.ZeroBalance(AChassis, ASlot: Integer;
  AChannelMask: Cardinal; out AValues: string): TRcOperationResult;
begin
  AValues := 'ch1=0';
  Result := TRcOperationResult.Success;
end;

function TApplyProbe.Discover(out ADevices: TPxiMx248DiscoveredDevices):
  TRcOperationResult;
begin
  SetLength(ADevices, 1);
  ADevices[0].DeviceIndex := 0;
  ADevices[0].DeviceName := 'MX-248 PXI Card';
  ADevices[0].SerialNumber := 3253;
  ADevices[0].Revision := 524;
  ADevices[0].ChassisType := 1;
  ADevices[0].Chassis := 2;
  ADevices[0].Slot := 14;
  Result := TRcOperationResult.Success;
end;

procedure Require(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

var
  lDialog: TPxiMx248SettingsDialog;
  lError, lProperties: string;
  lProbe: TApplyProbe;
  lService: IPxiMx248SettingsService;
  lRegistry: TRecorderTagRegistry;
  lResult: TRcOperationResult;
  lLegacyTag: TRecorderTag;
  lChannel: Integer;
begin
  Application.Initialize;
  lProbe := TApplyProbe.Create;
  lService := lProbe;
  lDialog := TPxiMx248SettingsDialog.Create(nil);
  try
    lDialog.LoadDraft('', '', 2, 5, lService);
    Require(lDialog.gridChannels.ColCount = 8,
      'Redundant enabled-channel column is still visible');
    Require(lDialog.gridChannels.Cells[3, 1] = '±100000 пКл',
      'Default amplifier range is not shown in physical charge units');
    Require(lDialog.gridChannels.Cells[7, 0] = 'Подключение входа',
      'Floating input column has an unclear caption');
    Require(lDialog.gridChannels.Cells[7, 1] = 'С общей точкой',
      'Floating input state is not explained in operator terms');
    lDialog.gridChannels.Row := 1;
    lDialog.gridChannels.Col := 1;
    lDialog.GridDblClick(nil);
    Require(lDialog.gridChannels.Cells[3, 1] = '±10 В',
      'Direct ADC range is not shown in volts when amplifier is disabled');
    Require(lDialog.ValidateDraft(lProperties, lError), lError);
    Require(Pos('sample-rate-hz=512000', lProperties) > 0,
      'Canonical default sample rate is missing');
    Require(Pos('device.type=', lProperties) = 0,
      'Read-only properties must not enter persisted apply packet');
    Require(Pos('channel.1.range-index=0', lProperties) > 0,
      'Physical range caption corrupted the DevAPI range index');
    Require(Pos('pxi.address-rule=slot-channel', lProperties) > 0,
      'Address rule is missing');
    Require(Pos('pxi.source-address=2', lProperties) > 0,
      'Default board alias is missing');
    Require(lDialog.ApplyDraft(lError), lError);
    Require(Pos('pxi.trigger-level=high', lProbe.LastLiveProperties) > 0,
      'Active TTL trigger level is missing from live apply');
    Require(lDialog.cbTriggerEdge.Text = 'low',
      'Live trigger level readback was not reflected in the UI');
    Require(lDialog.cbBusRole.Text = 'Master',
      'PXI bus role readback was not reflected as Master');
    Require(Pos('pxi.bus-role=Master', lProbe.LastLiveProperties) > 0,
      'Default PXI bus role is not Master');
    Require(PxiMx248TryChannelFromAddress('1', lChannel) and (lChannel = 1),
      'Legacy numeric channel address is not accepted');
    Require(PxiMx248TryChannelFromAddress('mx248-1-1', lChannel) and
      (lChannel = 1), 'MX alias channel address is not accepted');
    Require(PxiMx248TryChannelFromAddress('pxi1-1-8', lChannel) and
      (lChannel = 8), 'PXI alias channel address is not accepted');
    Require(PxiMx248TryChannelFromAddress('manual-alias-3', lChannel) and
      (lChannel = 3), 'Manual alias channel address is not accepted');
    Require(lProbe.CallCount = 1, 'Apply callback count mismatch');
    Require(lProbe.LastSourceId = 'pxi-mx248:2:5', 'SourceId mismatch');
    Require((lProbe.LastChassis = 2) and (lProbe.LastSlot = 5),
      'PXI location mismatch');
    Require(Pos('channel.8.enabled=True', lProbe.LastProperties) > 0,
      'Eighth channel is missing');
    lDialog.DiscoverClick(nil);
    Require((lDialog.cbDiscovered.Items.Count = 1) and
      (lDialog.cbDiscovered.ItemIndex = 0),
      'Explicit discovery did not populate binding choices');
    Require(lDialog.ApplyDraft(lError), lError);
    Require(lProbe.LastSourceId = 'pxi-mx248:2:14',
      'Discovered board must be proposed for linking');
    Require((lProbe.LastChassis = 2) and (lProbe.LastSlot = 14),
      'Discovered PXI route mismatch');

    lRegistry := TRecorderTagRegistry.Create;
    try
      RecorderConfiguredDataSourcesEnsure(lRegistry, 'pxi-mx248:0:0',
        'PXI MX-248');
      lLegacyTag := lRegistry.CreateTag('Legacy AIn1', 16);
      lLegacyTag.SourceId := 'pxi-mx248:0:0';
      lLegacyTag.Address := '1';
      lDialog.LoadDraft('pxi-mx248:2:14', '', 2, 14, lService);
      Require((lDialog.cbDiscovered.Items.Count = 1) and
        (lDialog.cbDiscovered.ItemIndex = 0),
        'Known discovery result was not selected when dialog reopened');
      lDialog.edSourceAddress.Text := 'mx248-14';
      Require(lDialog.cbAddressRule.Text = 'Ручное именование',
        'Manual alias did not switch the address rule');
      Require(lDialog.ValidateDraft(lProperties, lError), lError);
      Require(Pos(CPxiMx248AddressRuleKey + '=' +
        CPxiMx248AddressRuleManual, lProperties) > 0,
        'Manual address rule was not persisted');
      lResult := RcApplyMx248Draft(lRegistry,
        'pxi-mx248:0:0', 'pxi-mx248:2:14', 2, 14, lProperties);
      Require(lResult.IsSuccess, lResult.MessageText);
      Require(lRegistry.TagCount = 8,
        'Apply must expose all eight tags immediately');
      Require(lRegistry.IsSourceActive('pxi-mx248:2:14'),
        'Applied MX-248 source was not activated');
      Require(RecorderTagSourceIsVisible(lRegistry, lLegacyTag),
        'Applied MX-248 tag is hidden from the main tag list');
      Require(lLegacyTag.Address = 'mx248-14-1',
        'Legacy numeric address was not migrated in-place');
      Require(lLegacyTag.SourceId = 'pxi-mx248:2:14',
        'Legacy tag source binding was not migrated');
      Require(RecorderConfiguredDataSourcesFind(lRegistry,
        'pxi-mx248:2:14').SourceAddress = 'mx248-14',
        'Board alias was not stored in SourceAddress');
      Require(Pos('pxi.source-address=', RecorderConfiguredDataSourcesFind(
        lRegistry, 'pxi-mx248:2:14').SpecificConfigText) = 0,
        'Transient alias leaked into specific config');
      lResult := RcApplyMx248Draft(lRegistry,
        'pxi-mx248:9:9', 'pxi-mx248:2:14', 2, 14, lProperties);
      Require((not lResult.IsSuccess) and (lResult.Code = rocInvalidArgument),
        'Duplicate physical route must be rejected');
      Require(lRegistry.TagCount = 8,
        'Rejected duplicate route mutated tags');
    finally
      lRegistry.Free;
    end;
    WriteLn('RESULT PxiMx248SettingsSmoke passed');
  finally
    lDialog.Free;
    lService := nil;
  end;
end.
