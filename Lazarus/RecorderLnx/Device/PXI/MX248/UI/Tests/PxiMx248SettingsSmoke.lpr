program PxiMx248SettingsSmoke;

{
  LCL smoke for the MX-248 settings editor. It verifies LFM loading, grid
  selection/context behavior, queued group-edit modal flows, draft-only edits,
  and the apply callback boundary. See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, Controls, StdCtrls, Classes, Types, SysUtils, Grids,
  uRecorderDriverContractsV2, uRecorderPxiMx248SettingsService,
  uRecorderPxiMx248ChannelDialog,
  uRecorderPxiMx248SettingsDialog, uRecorderPxiMx248Types,
  uRecorderPxiMx248ConfiguredEditor, uRecorderConfiguredDataSources,
  uRecorderPxiMx248Addressing, uRecorderTags;

type
  TGridAccess = class(TStringGrid)
  public
    procedure ClickCell(ARow, ACol: Integer; AModifiers: TShiftState);
  end;

  TModalAutomation = class
    procedure OnIdle(Sender: TObject; var Done: Boolean);
  end;

  TApplyProbe = class(TInterfacedObject, IPxiMx248SettingsService)
  public
    CallCount: Integer;
    LastSourceId: string;
    LastChassis: Integer;
    LastSlot: Integer;
    LastProperties: string;
    LastLiveProperties: string;
    LiveApplyCount: Integer;
    LiveReadCount: Integer;
    ZeroBalanceCount: Integer;
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

procedure TGridAccess.ClickCell(ARow, ACol: Integer;
  AModifiers: TShiftState);
var
  lRect: TRect;
  lX, lY: Integer;
begin
  lRect := CellRect(ACol, ARow);
  lX := (lRect.Left + lRect.Right) div 2;
  lY := (lRect.Top + lRect.Bottom) div 2;
  inherited MouseDown(mbLeft, AModifiers, lX, lY);
  inherited MouseUp(mbLeft, AModifiers, lX, lY);
end;

function TApplyProbe.ReadLiveProperties(AChassis, ASlot: Integer;
  out AProperties: string): TRcOperationResult;
begin
  Inc(LiveReadCount);
  AProperties := 'sample-rate-hz=512000';
  Result := TRcOperationResult.Success;
end;

function TApplyProbe.ApplyLiveDraft(AChassis, ASlot: Integer;
  const AProperties: string; out AReadback: string): TRcOperationResult;
begin
  Inc(LiveApplyCount);
  LastLiveProperties := AProperties;
  AReadback := 'sample-rate-hz=512000;trigger-mode=2;trigger-source=3;' +
    'trigger-level=0;rtsi-sync=1';
  Result := TRcOperationResult.Success;
end;

function TApplyProbe.ZeroBalance(AChassis, ASlot: Integer;
  AChannelMask: Cardinal; out AValues: string): TRcOperationResult;
begin
  Inc(ZeroBalanceCount);
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
  gModalAutomationError: string;
  gCancelNextChannelDialog: Boolean;
  gChannelDialogAutomated: Boolean;
  gExpectMixedInputMode: Boolean;

procedure TModalAutomation.OnIdle(Sender: TObject; var Done: Boolean);
var
  lForm: TCustomForm;
  lDialog: TPxiMx248ChannelDialog;
begin
  lForm := Screen.ActiveCustomForm;
  if not (lForm is TPxiMx248ChannelDialog) or gChannelDialogAutomated then
    Exit;
  gChannelDialogAutomated := True;
  lDialog := TPxiMx248ChannelDialog(lForm);
  try
    Require(lDialog.chkAmplifier.State = cbGrayed,
      'Mixed amplifier values were not shown as keep-per-channel');
    if gExpectMixedInputMode then
      Require(lDialog.cbInputMode.Text = 'Разные значения',
        'Mixed input mode values were not shown');
    if gCancelNextChannelDialog then
    begin
      lDialog.cbIeee.ItemIndex := 2;
      lDialog.btnCancel.Click;
    end
    else
    begin
      lDialog.cbInputMode.ItemIndex := 1;
      lDialog.btnOk.Click;
    end;
  except
    on E: Exception do
    begin
      gModalAutomationError := E.Message;
      lDialog.ModalResult := mrCancel;
    end;
  end;
end;

function HasPacketValue(const APacket, AKey, AValue: string): Boolean;
begin
  Result := Pos(AKey + '=' + AValue, APacket) > 0;
end;

function PacketValue(const APacket, AKey: string): string;
var
  lParts: TStringList;
  I: Integer;
begin
  Result := '';
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ';';
    lParts.DelimitedText := APacket;
    for I := 0 to lParts.Count - 1 do
      if Copy(lParts[I], 1, Length(AKey) + 1) = AKey + '=' then
        Exit(Copy(lParts[I], Length(AKey) + 2, MaxInt));
  finally
    lParts.Free;
  end;
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
  lAutomation: TModalAutomation;
  lSavedProperties: string;
  lRowRect: TRect;
  lMousePoint: TPoint;
  lAfterCancel: string;
  lAmpRow1, lAmpRow3, lAmpRow5, lUnselectedInput: string;
begin
  Application.Initialize;
  lAutomation := TModalAutomation.Create;
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

    { Exercise ordinary Ctrl/Shift selection and the actual child editor.
      The service probe must remain untouched until the explicit Apply below. }
    Require((lProbe.CallCount = 0) and (lProbe.LiveApplyCount = 0) and
      (lProbe.LiveReadCount = 0) and (lProbe.ZeroBalanceCount = 0),
      'Settings were sent to the service before Apply');
    lDialog.pages.ActivePage := lDialog.pageChannels;
    lDialog.Show;
    Application.ProcessMessages;
    Require(lDialog.gridChannels.RangeSelectMode = rsmMulti,
      'Grid does not support multiple discontiguous selections');
    lDialog.gridChannels.ClearSelections;
    TGridAccess(lDialog.gridChannels).ClickCell(2, 1, []);
    TGridAccess(lDialog.gridChannels).ClickCell(4, 1, [ssShift]);
    Require(lDialog.IsChannelSelected(2) and lDialog.IsChannelSelected(3) and
      lDialog.IsChannelSelected(4), 'Shift range selection failed');

    lDialog.gridChannels.ClearSelections;
    TGridAccess(lDialog.gridChannels).ClickCell(1, 1, []);
    TGridAccess(lDialog.gridChannels).ClickCell(3, 1, [ssCtrl]);
    TGridAccess(lDialog.gridChannels).ClickCell(5, 1, [ssCtrl]);
    Require(lDialog.IsChannelSelected(1) and lDialog.IsChannelSelected(3) and
      lDialog.IsChannelSelected(5) and not lDialog.IsChannelSelected(2) and
      not lDialog.IsChannelSelected(4), 'Ctrl discontiguous selection failed');
    lRowRect := lDialog.gridChannels.CellRect(1, 3);
    lMousePoint := Point((lRowRect.Left + lRowRect.Right) div 2,
      (lRowRect.Top + lRowRect.Bottom) div 2);
    lDialog.GridMouseDown(lDialog.gridChannels, mbRight, [], lMousePoint.X,
      lMousePoint.Y);
    Require(lDialog.IsChannelSelected(1) and lDialog.IsChannelSelected(3) and
      lDialog.IsChannelSelected(5) and not lDialog.IsChannelSelected(2),
      'Right-click on selected row discarded the selected group');
    lRowRect := lDialog.gridChannels.CellRect(1, 7);
    lMousePoint := Point((lRowRect.Left + lRowRect.Right) div 2,
      (lRowRect.Top + lRowRect.Bottom) div 2);
    lDialog.GridMouseDown(lDialog.gridChannels, mbRight, [], lMousePoint.X,
      lMousePoint.Y);
    Require(lDialog.IsChannelSelected(7) and
      not lDialog.IsChannelSelected(1) and not lDialog.IsChannelSelected(3),
      'Right-click outside selection did not select the clicked row');
    lDialog.GridMouseDown(lDialog.gridChannels, mbRight, [], 4, 4);
    Require(not lDialog.miEditChannels.Enabled,
      'Context edit is enabled on the grid header');

    { Make the three selected channels observably mixed in amplifier and mode. }
    lDialog.gridChannels.Cells[2, 3] := 'single-ended';
    if lDialog.gridChannels.Cells[1, 1] = lDialog.gridChannels.Cells[1, 3] then
    begin
      lDialog.gridChannels.Row := 3;
      lDialog.gridChannels.Col := 1;
      lDialog.GridDblClick(nil);
    end;
    lDialog.gridChannels.Row := 2;
    lDialog.gridChannels.Col := 5;
    lDialog.GridDblClick(nil);
    Require(lDialog.gridChannels.Cells[5, 2] <> 'off',
      'Existing IEPE double-click behavior did not change the value');
    lDialog.gridChannels.ClearSelections;
    TGridAccess(lDialog.gridChannels).ClickCell(1, 1, []);
    TGridAccess(lDialog.gridChannels).ClickCell(3, 1, [ssCtrl]);
    TGridAccess(lDialog.gridChannels).ClickCell(5, 1, [ssCtrl]);
    lRowRect := lDialog.gridChannels.CellRect(1, 3);
    lMousePoint := Point((lRowRect.Left + lRowRect.Right) div 2,
      (lRowRect.Top + lRowRect.Bottom) div 2);
    lDialog.GridMouseDown(lDialog.gridChannels, mbRight, [], lMousePoint.X,
      lMousePoint.Y);
    Require(lDialog.ValidateDraft(lSavedProperties, lError), lError);
    lAmpRow1 := PacketValue(lSavedProperties, 'channel.1.amplifier-enabled');
    lAmpRow3 := PacketValue(lSavedProperties, 'channel.3.amplifier-enabled');
    lAmpRow5 := PacketValue(lSavedProperties, 'channel.5.amplifier-enabled');
    lUnselectedInput := PacketValue(lSavedProperties, 'channel.2.input-mode');
    Require((lAmpRow1 <> lAmpRow3) and
      (PacketValue(lSavedProperties, 'channel.1.input-mode') <>
       PacketValue(lSavedProperties, 'channel.3.input-mode')),
      'Group edit fixture does not contain mixed values');

    gCancelNextChannelDialog := False;
    gExpectMixedInputMode := True;
    gChannelDialogAutomated := False;
    gModalAutomationError := '';
    Application.OnIdle := @lAutomation.OnIdle;
    lDialog.miEditChannels.Click;
    Application.OnIdle := nil;
    Require(gChannelDialogAutomated,
      'Queued automation did not reach the channel editor');
    Require(gModalAutomationError = '', gModalAutomationError);
    Require(lDialog.ValidateDraft(lProperties, lError), lError);
    Require(HasPacketValue(lProperties, 'channel.1.input-mode', 'single-ended') and
      HasPacketValue(lProperties, 'channel.3.input-mode', 'single-ended') and
      HasPacketValue(lProperties, 'channel.5.input-mode', 'single-ended'),
      'Common group value was not applied to all selected channels');
    Require((PacketValue(lProperties, 'channel.1.amplifier-enabled') = lAmpRow1) and
      (PacketValue(lProperties, 'channel.3.amplifier-enabled') = lAmpRow3) and
      (PacketValue(lProperties, 'channel.5.amplifier-enabled') = lAmpRow5),
      'Mixed amplifier state did not preserve each selected channel value');
    Require(PacketValue(lProperties, 'channel.2.input-mode') = lUnselectedInput,
      'Group edit changed an unselected channel');

    lSavedProperties := lProperties;
    gCancelNextChannelDialog := True;
    gExpectMixedInputMode := False;
    gChannelDialogAutomated := False;
    gModalAutomationError := '';
    Application.OnIdle := @lAutomation.OnIdle;
    lDialog.miEditChannels.Click;
    Application.OnIdle := nil;
    Require(gChannelDialogAutomated,
      'Queued automation did not reach the cancel editor');
    Require(gModalAutomationError = '', gModalAutomationError);
    Require(lDialog.ValidateDraft(lAfterCancel, lError), lError);
    Require(lAfterCancel = lSavedProperties,
      'Cancel changed the channel draft');
    Require((lProbe.CallCount = 0) and (lProbe.LiveApplyCount = 0) and
      (lProbe.LiveReadCount = 0) and (lProbe.ZeroBalanceCount = 0),
      'An edit, cancel, or discovery action reached the device service');
    lDialog.Hide;

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
    lAutomation.Free;
    lService := nil;
  end;
end.
