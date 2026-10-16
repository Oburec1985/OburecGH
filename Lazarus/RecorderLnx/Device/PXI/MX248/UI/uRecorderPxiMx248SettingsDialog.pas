unit uRecorderPxiMx248SettingsDialog;

{
  Назначение: LCL-редактор offline-черновика PXI MX-248 для восьми каналов.
  Его вызывает configured-source editor после выбора модуля. Форма строит один
  строковый пакет, проверяет его штатным TPxiMx248PropertyStore и только затем
  передаёт сервису применения.

  Контракт: форма не подключается к оборудованию, не управляет lifecycle и не
  публикует теги. Apply/Read/Zero передают сервису только неизменяемые снимки в
  worker-потоке; worker не обращается к LCL. Основная компоновка хранится в
  LFM. До успешного ApplyDraft исходная конфигурация не меняется. Все channel
  keys one-based, строки grid соответствуют каналам 1..8. Архитектура:
  Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids, ComCtrls,
  uRecorderDriverContractsV2, uRecorderPxiMx248Properties,
  uRecorderPxiMx248Types, uRecorderPxiMx248SettingsService;

type
  TPxiMx248SettingsDialog = class(TForm)
    btnApply: TButton;
    btnCancel: TButton;
    btnSearch: TButton;
    btnReadLive: TButton;
    btnZeroBalance: TButton;
    btnOk: TButton;
    cbCalibrationMode: TComboBox;
    cbClockSource: TComboBox;
    cbBusRole: TComboBox;
    cbDiscovered: TComboBox;
    cbTriggerEdge: TComboBox;
    cbTriggerLine: TComboBox;
    cbAddressRule: TComboBox;
    chkExternalSync: TCheckBox;
    edChassis: TEdit;
    cbSampleRate: TComboBox;
    edSlot: TEdit;
    edSourceId: TEdit;
    edSourceAddress: TEdit;
    gridChannels: TStringGrid;
    lblCalibrationMode: TLabel;
    lblChassis: TLabel;
    lblDiscovered: TLabel;
    lblSampleRate: TLabel;
    lblSlot: TLabel;
    lblSourceId: TLabel;
    lblSourceAddress: TLabel;
    lblAddressRule: TLabel;
    lblAddressPreview: TLabel;
    lblStatus: TLabel;
    lblAdvancedNotice: TLabel;
    lblClockSource: TLabel;
    lblBusRole: TLabel;
    lblTriggerEdge: TLabel;
    lblTriggerLine: TLabel;
    pageAdditional: TTabSheet;
    pageChannels: TTabSheet;
    pageGeneral: TTabSheet;
    pages: TPageControl;
    pnButtons: TPanel;
    pnAcquisition: TPanel;
    pnDiscovery: TPanel;
    pnLocation: TPanel;
    pnChannelHint: TPanel;
    progressIo: TProgressBar;
    procedure ApplyClick(Sender: TObject);
    procedure DiscoveredChange(Sender: TObject);
    procedure DiscoverClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure GridDblClick(Sender: TObject);
    procedure LocationChange(Sender: TObject);
    procedure AddressRuleChange(Sender: TObject);
    procedure SourceAddressChange(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure ReadLiveClick(Sender: TObject);
    procedure ZeroBalanceClick(Sender: TObject);
  private
    fDraft: TPxiMx248PropertyStore;
    fDiscovered: TPxiMx248DiscoveredDevices;
    fService: IPxiMx248SettingsService;
    { Internal transport batching; deliberately not exposed in the operator
      dialog because the original MX-248 UI does not make it a board setting. }
    fBlockSamples: string;
    fIoBusy: Boolean;
    fCloseAfterApply: Boolean;
    fUpdatingAddressControls: Boolean;
    fPendingSourceId: string;
    fPendingChassis: Integer;
    fPendingSlot: Integer;
    fPendingProperties: string;
    fRangeIndices: array[1..CPxiMx248ChannelCount] of Integer;
    procedure ConfigureChoices;
    procedure ConfigureGrid;
    function ChannelRangeText(AChannel: Integer): string;
    procedure UpdateChannelRangeText(AChannel: Integer);
    function FloatingText(const ARawValue: string): string;
    function FloatingRawValue(const ADisplayValue: string): string;
    procedure FillControls(const AProperties: string);
    function BuildPropertyPacket: string;
    function ChannelKey(AChannel: Integer; const AName: string): string;
    function ReadLocation(out AChassis, ASlot: Integer): Boolean;
    procedure SetStatus(const AText: string; AIsError: Boolean);
    procedure UpdateSourceId;
    procedure UpdateAddressPreview;
    function SelectedAddressRule: string;
    procedure LinkDiscoveredDevice(AIndex: Integer);
    procedure FillDiscoveredChoices(AChassis, ASlot: Integer);
    function ValueFromPacket(const APacket, AName: string): string;
    function BasePacketForValidation(const APacket: string): string;
    function AdvancedPropertyPacket: string;
    procedure FillAdvancedControls(const AProperties: string);
    procedure ApplyLiveReadback(const AProperties: string);
    function WritablePacketFromCanonical(const AProperties: string): string;
    procedure BeginServiceOperation(AKind: Integer; const ASourceId: string;
      AChassis, ASlot: Integer; const AProperties, AStatus: string);
    procedure CompleteServiceOperation(AKind: Integer;
      const AResult: TRcOperationResult; const AData: string);
    procedure SetIoBusy(ABusy: Boolean; const AStatus: string = '');
  public
    destructor Destroy; override;
    procedure LoadDraft(const ASourceId, AProperties: string;
      AChassis, ASlot: Integer; const AService: IPxiMx248SettingsService);
    function ValidateDraft(out ACanonicalProperties: string;
      out AErrorText: string): Boolean;
    function ApplyDraft(out AErrorText: string): Boolean;
  end;

function ShowPxiMx248SettingsDialog(AOwner: TComponent;
  const ASourceId, AProperties: string; AChassis, ASlot: Integer;
  const AService: IPxiMx248SettingsService): Boolean;

implementation

{$R *.lfm}

uses
  Graphics, uRecorderPxiMx248DiscoveryWorker,
  uRecorderPxiMx248ChannelDialog, uRecorderPxiMx248Addressing;

const
  CColChannel = 0;
  CColAmplifier = 1;
  CColInputMode = 2;
  CColRange = 3;
  CColLpf = 4;
  CColIcp = 5;
  CColCalibration = 6;
  CColFloating = 7;
  CKeyClockSource = 'pxi.clock-source';
  CKeySyncReceive = 'pxi.sync-receive';
  CKeyBusRole = 'pxi.bus-role';
  CKeyTriggerLine = 'pxi.trigger-line';
  CKeyTriggerLevel = 'pxi.trigger-level';
  CKeyLegacyTriggerEdge = 'pxi.trigger-edge';

type
  TPxiMx248DialogOperation = (pdoApply, pdoRead, pdoZero);
  TPxiMx248DialogOperationComplete = procedure(AKind: Integer;
    const AResult: TRcOperationResult; const AData: string) of object;

  { The worker owns immutable inputs and calls only the settings service.
    Its synchronized completion is the sole boundary back to LCL controls. }
  TPxiMx248DialogWorker = class(TThread)
  private
    fKind: TPxiMx248DialogOperation;
    fService: IPxiMx248SettingsService;
    fSourceId: string;
    fChassis: Integer;
    fSlot: Integer;
    fProperties: string;
    fResult: TRcOperationResult;
    fData: string;
    fOnComplete: TPxiMx248DialogOperationComplete;
    procedure DeliverResult;
  protected
    procedure Execute; override;
  public
    constructor Create(AKind: TPxiMx248DialogOperation;
      const AService: IPxiMx248SettingsService; const ASourceId: string;
      AChassis, ASlot: Integer; const AProperties: string;
      AOnComplete: TPxiMx248DialogOperationComplete);
  end;

constructor TPxiMx248DialogWorker.Create(AKind: TPxiMx248DialogOperation;
  const AService: IPxiMx248SettingsService; const ASourceId: string;
  AChassis, ASlot: Integer; const AProperties: string;
  AOnComplete: TPxiMx248DialogOperationComplete);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  fKind := AKind;
  fService := AService;
  fSourceId := ASourceId;
  fChassis := AChassis;
  fSlot := ASlot;
  fProperties := AProperties;
  fOnComplete := AOnComplete;
end;

procedure TPxiMx248DialogWorker.Execute;
begin
  try
    case fKind of
      pdoApply:
        { The worker owns hardware I/O only. Registry persistence is completed
          later by the form in the GUI thread. }
        fResult := fService.ApplyLiveDraft(fChassis, fSlot, fProperties,
          fData);
      pdoRead:
        fResult := fService.ReadLiveProperties(fChassis, fSlot, fData);
      pdoZero:
        fResult := fService.ZeroBalance(fChassis, fSlot, $FF, fData);
    end;
  except
    on E: Exception do
      fResult := TRcOperationResult.Failure(rocInternal,
        'mx248.settings.worker', E.Message);
  end;
  Synchronize(@DeliverResult);
end;

procedure TPxiMx248DialogWorker.DeliverResult;
begin
  if Assigned(fOnComplete) then
    fOnComplete(Ord(fKind), fResult, fData);
end;

function ShowPxiMx248SettingsDialog(AOwner: TComponent;
  const ASourceId, AProperties: string; AChassis, ASlot: Integer;
  const AService: IPxiMx248SettingsService): Boolean;
var
  lDialog: TPxiMx248SettingsDialog;
begin
  lDialog := TPxiMx248SettingsDialog.Create(AOwner);
  try
    lDialog.LoadDraft(ASourceId, AProperties, AChassis, ASlot, AService);
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

procedure TPxiMx248SettingsDialog.LinkDiscoveredDevice(AIndex: Integer);
var
  lDevice: TPxiMx248DiscoveredDevice;
begin
  if (AIndex < 0) or (AIndex >= Length(fDiscovered)) then Exit;
  lDevice := fDiscovered[AIndex];
  edChassis.Text := IntToStr(lDevice.Chassis);
  edSlot.Text := IntToStr(lDevice.Slot);
  UpdateSourceId;
  SetStatus(Format('Предложена привязка: %s, SN=%d, слот PXI/шина PCI=%d, устройство PCI=%d. ' +
    'Нажмите Применить или OK для сохранения.', [lDevice.DeviceName,
    lDevice.SerialNumber, lDevice.Chassis, lDevice.Slot]), False);
end;

procedure TPxiMx248SettingsDialog.FillDiscoveredChoices(AChassis,
  ASlot: Integer);
var
  I, lSelected: Integer;
begin
  RecorderKnownPxiMx248Devices(fDiscovered);
  cbDiscovered.Items.Clear;
  lSelected := -1;
  for I := 0 to High(fDiscovered) do
  begin
    cbDiscovered.Items.Add(Format('%s — SN=%d, шасси=%d, слот=%d',
      [fDiscovered[I].DeviceName, fDiscovered[I].SerialNumber,
       fDiscovered[I].Chassis, fDiscovered[I].Slot]));
    if (fDiscovered[I].Chassis = AChassis) and
      (fDiscovered[I].Slot = ASlot) then
      lSelected := I;
  end;
  if lSelected >= 0 then
    cbDiscovered.ItemIndex := lSelected
  else if (AChassis <> 0) or (ASlot <> 0) then
  begin
    cbDiscovered.Items.Add(Format(
      'Текущая привязка — шасси=%d, слот=%d', [AChassis, ASlot]));
    cbDiscovered.ItemIndex := cbDiscovered.Items.Count - 1;
  end
  else
    cbDiscovered.ItemIndex := -1;
end;

procedure TPxiMx248SettingsDialog.DiscoveredChange(Sender: TObject);
begin
  LinkDiscoveredDevice(cbDiscovered.ItemIndex);
end;

procedure TPxiMx248SettingsDialog.DiscoverClick(Sender: TObject);
var
  I: Integer;
  lResult: TRcOperationResult;
begin
  cbDiscovered.Items.Clear;
  SetLength(fDiscovered, 0);
  if fService = nil then
  begin
    SetStatus('Сервис поиска PXI MX-248 не подключён.', True);
    Exit;
  end;
  Screen.Cursor := crHourGlass;
  btnSearch.Enabled := False;
  try
    lResult := RecorderDiscoverPxiMx248Responsive(fDiscovered, fService);
  finally
    btnSearch.Enabled := True;
    Screen.Cursor := crDefault;
  end;
  if not lResult.IsSuccess then
  begin
    SetStatus(lResult.Stage + ': ' + lResult.MessageText, True);
    Exit;
  end;
  for I := 0 to High(fDiscovered) do
    cbDiscovered.Items.Add(Format('%s — SN=%d, шасси=%d, слот=%d',
      [fDiscovered[I].DeviceName, fDiscovered[I].SerialNumber,
       fDiscovered[I].Chassis, fDiscovered[I].Slot]));
  if Length(fDiscovered) = 0 then
  begin
    SetStatus('DevAPI не нашёл плат MX-248 в системе.', True);
    Exit;
  end;
  cbDiscovered.ItemIndex := 0;
  LinkDiscoveredDevice(0);
end;

procedure TPxiMx248SettingsDialog.FormCreate(Sender: TObject);
var
  lProperties: string;
begin
  fDraft := TPxiMx248PropertyStore.Create(nil);
  ConfigureChoices;
  ConfigureGrid;
  if fDraft.GetProperties('*', lProperties).IsSuccess then
    FillControls(lProperties);
end;

procedure TPxiMx248SettingsDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not fIoBusy;
  if not CanClose then
    SetStatus('Дождитесь завершения операции с MX-248.', False);
end;

destructor TPxiMx248SettingsDialog.Destroy;
begin
  fService := nil;
  fDraft.Free;
  inherited Destroy;
end;

procedure TPxiMx248SettingsDialog.ConfigureChoices;
var
  I: Integer;
begin
  cbAddressRule.Items.Add('Слот-канал');
  cbAddressRule.Items.Add('Тип-слот-канал');
  cbAddressRule.Items.Add('Шасси-слот-канал');
  cbAddressRule.Items.Add('Ручное именование');
  cbAddressRule.ItemIndex := 0;
  cbSampleRate.Items.Clear;
  for I := Low(CPxiMx248SampleRates) to High(CPxiMx248SampleRates) do
    cbSampleRate.Items.Add(IntToStr(CPxiMx248SampleRates[I]));
  cbSampleRate.ItemIndex := cbSampleRate.Items.IndexOf('512000');
  cbCalibrationMode.Items.Clear;
  cbCalibrationMode.Items.Add('reference');
  cbCalibrationMode.Items.Add('pxi');
  cbCalibrationMode.ItemIndex := 0;
  cbClockSource.Items.Add('internal');
  cbClockSource.Items.Add('PXI_CLK10');
  cbClockSource.ItemIndex := 1;
  cbBusRole.Items.Add('Slave');
  cbBusRole.Items.Add('Master');
  cbBusRole.Items.Add('Hardwired');
  cbBusRole.ItemIndex := 1;
  cbTriggerLine.Items.Add('off');
  for I := 0 to 7 do
    cbTriggerLine.Items.Add('PXI_TRIG' + IntToStr(I));
  cbTriggerLine.ItemIndex := 0;
  cbTriggerEdge.Items.Add('low');
  cbTriggerEdge.Items.Add('high');
  cbTriggerEdge.ItemIndex := 1;
end;

function TPxiMx248SettingsDialog.SelectedAddressRule: string;
begin
  case cbAddressRule.ItemIndex of
    1: Result := CPxiMx248AddressRuleTypeSlot;
    2: Result := CPxiMx248AddressRuleChassisSlot;
    3: Result := CPxiMx248AddressRuleManual;
  else
    Result := CPxiMx248AddressRuleSlot;
  end;
end;

procedure TPxiMx248SettingsDialog.UpdateAddressPreview;
begin
  lblAddressPreview.Caption := 'Адреса каналов: ' +
    PxiMx248ChannelAddress(Trim(edSourceAddress.Text), 1) + ' … ' +
    PxiMx248ChannelAddress(Trim(edSourceAddress.Text), CPxiMx248ChannelCount);
end;

procedure TPxiMx248SettingsDialog.AddressRuleChange(Sender: TObject);
var
  lChassis, lSlot: Integer;
begin
  if fUpdatingAddressControls or
    (SelectedAddressRule = CPxiMx248AddressRuleManual) then
  begin
    UpdateAddressPreview;
    Exit;
  end;
  if ReadLocation(lChassis, lSlot) then
  begin
    fUpdatingAddressControls := True;
    try
      edSourceAddress.Text := PxiMx248DefaultSourceAddress(1, lChassis,
        SelectedAddressRule);
    finally
      fUpdatingAddressControls := False;
    end;
  end;
  UpdateAddressPreview;
end;

procedure TPxiMx248SettingsDialog.SourceAddressChange(Sender: TObject);
var
  lChassis, lSlot: Integer;
begin
  if not fUpdatingAddressControls and
    (SelectedAddressRule <> CPxiMx248AddressRuleManual) and
    ReadLocation(lChassis, lSlot) and
    not SameText(Trim(edSourceAddress.Text),
      PxiMx248DefaultSourceAddress(1, lChassis, SelectedAddressRule)) then
  begin
    fUpdatingAddressControls := True;
    try
      cbAddressRule.ItemIndex := 3;
    finally
      fUpdatingAddressControls := False;
    end;
  end;
  UpdateAddressPreview;
end;

procedure TPxiMx248SettingsDialog.ConfigureGrid;
var
  I: Integer;
begin
  gridChannels.ColCount := 8;
  gridChannels.RowCount := CPxiMx248ChannelCount + 1;
  gridChannels.FixedRows := 1;
  gridChannels.Cells[CColChannel, 0] := 'Канал';
  gridChannels.Cells[CColAmplifier, 0] := 'Усил.';
  gridChannels.Cells[CColInputMode, 0] := 'Вход';
  gridChannels.Cells[CColRange, 0] := 'Диапазон';
  gridChannels.Cells[CColLpf, 0] := 'LPF';
  gridChannels.Cells[CColIcp, 0] := 'ICP, mA';
  gridChannels.Cells[CColCalibration, 0] := 'Калибр.';
  gridChannels.Cells[CColFloating, 0] := 'Подключение входа';
  gridChannels.ColWidths[CColChannel] := 50;
  gridChannels.ColWidths[CColAmplifier] := 70;
  gridChannels.ColWidths[CColInputMode] := 120;
  gridChannels.ColWidths[CColRange] := 120;
  gridChannels.ColWidths[CColLpf] := 58;
  gridChannels.ColWidths[CColIcp] := 65;
  gridChannels.ColWidths[CColCalibration] := 78;
  gridChannels.ColWidths[CColFloating] := 140;
  for I := 1 to CPxiMx248ChannelCount do
    gridChannels.Cells[CColChannel, I] := IntToStr(I);
end;

function TPxiMx248SettingsDialog.ChannelRangeText(AChannel: Integer): string;
begin
  if not SameText(gridChannels.Cells[CColAmplifier, AChannel], 'True') then
    Exit('±10 В');
  case fRangeIndices[AChannel] of
    1: Result := '±10000 пКл';
    2: Result := '±1000 пКл';
  else
    Result := '±100000 пКл';
  end;
end;

procedure TPxiMx248SettingsDialog.UpdateChannelRangeText(AChannel: Integer);
begin
  gridChannels.Cells[CColRange, AChannel] := ChannelRangeText(AChannel);
end;

function TPxiMx248SettingsDialog.FloatingText(const ARawValue: string): string;
begin
  if SameText(ARawValue, 'True') or (ARawValue = '1') then
    Result := 'Плавающий'
  else
    Result := 'С общей точкой';
end;

function TPxiMx248SettingsDialog.FloatingRawValue(
  const ADisplayValue: string): string;
begin
  Result := BoolToStr(SameText(ADisplayValue, 'Плавающий') or
    SameText(ADisplayValue, 'True') or (ADisplayValue = '1'), True);
end;

function TPxiMx248SettingsDialog.ChannelKey(AChannel: Integer;
  const AName: string): string;
begin
  Result := Format('channel.%d.%s', [AChannel, AName]);
end;

function TPxiMx248SettingsDialog.ValueFromPacket(const APacket,
  AName: string): string;
var
  lItems: TStringList;
begin
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

procedure TPxiMx248SettingsDialog.FillControls(const AProperties: string);
var
  I: Integer;
begin
  cbSampleRate.ItemIndex := cbSampleRate.Items.IndexOf(
    ValueFromPacket(AProperties, 'sample-rate-hz'));
  if cbSampleRate.ItemIndex < 0 then cbSampleRate.ItemIndex := 0;
  fBlockSamples := ValueFromPacket(AProperties, 'block-samples');
  if Trim(fBlockSamples) = '' then
    fBlockSamples := IntToStr(CPxiMx248DefaultBlockSamples);
  cbCalibrationMode.Text := ValueFromPacket(AProperties, 'calibration-mode');
  FillAdvancedControls(AProperties);
  for I := 1 to CPxiMx248ChannelCount do
  begin
    gridChannels.Cells[CColAmplifier, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'amplifier-enabled'));
    gridChannels.Cells[CColInputMode, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'input-mode'));
    fRangeIndices[I] := StrToIntDef(ValueFromPacket(AProperties,
      ChannelKey(I, 'range-index')), 0);
    UpdateChannelRangeText(I);
    gridChannels.Cells[CColLpf, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'lpf-index'));
    gridChannels.Cells[CColIcp, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'icp-current'));
    gridChannels.Cells[CColCalibration, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'calibration-enabled'));
    gridChannels.Cells[CColFloating, I] := FloatingText(
      ValueFromPacket(AProperties, ChannelKey(I, 'input-floating')));
  end;
end;

procedure TPxiMx248SettingsDialog.LoadDraft(const ASourceId,
  AProperties: string; AChassis, ASlot: Integer;
  const AService: IPxiMx248SettingsService);
var
  lCanonical: string;
  lResult: TRcOperationResult;
begin
  fService := AService;
  fUpdatingAddressControls := True;
  try
  edChassis.Text := IntToStr(AChassis);
  edSlot.Text := IntToStr(ASlot);
  edSourceId.Text := ASourceId;
  if Trim(ASourceId) = '' then UpdateSourceId;
  lCanonical := PxiMx248NormalizeAddressRule(ValueFromPacket(AProperties,
    CPxiMx248AddressRuleKey));
  if lCanonical = CPxiMx248AddressRuleTypeSlot then
    cbAddressRule.ItemIndex := 1
  else if lCanonical = CPxiMx248AddressRuleChassisSlot then
    cbAddressRule.ItemIndex := 2
  else if lCanonical = CPxiMx248AddressRuleManual then
    cbAddressRule.ItemIndex := 3
  else
    cbAddressRule.ItemIndex := 0;
  edSourceAddress.Text := Trim(ValueFromPacket(AProperties,
    CPxiMx248SourceAddressKey));
  if edSourceAddress.Text = '' then
    edSourceAddress.Text := PxiMx248DefaultSourceAddress(1, AChassis,
      SelectedAddressRule);
  if (SelectedAddressRule <> CPxiMx248AddressRuleManual) and
    not SameText(edSourceAddress.Text, PxiMx248DefaultSourceAddress(
      1, AChassis, SelectedAddressRule)) then
    cbAddressRule.ItemIndex := 3;
  finally
    fUpdatingAddressControls := False;
  end;
  FillDiscoveredChoices(AChassis, ASlot);
  UpdateAddressPreview;
  if Trim(AProperties) = '' then Exit;
  lResult := fDraft.CalcProperties(BasePacketForValidation(AProperties),
    lCanonical);
  if not lResult.IsSuccess then
  begin
    SetStatus(lResult.MessageText, True);
    Exit;
  end;
  FillControls(lCanonical);
  FillAdvancedControls(AProperties);
end;

function TPxiMx248SettingsDialog.BasePacketForValidation(
  const APacket: string): string;
var
  I: Integer;
  lItems: TStringList;
  lName: string;
begin
  Result := '';
  lItems := TStringList.Create;
  try
    lItems.StrictDelimiter := True;
    lItems.Delimiter := ';';
    lItems.DelimitedText := APacket;
    lItems.NameValueSeparator := '=';
    for I := 0 to lItems.Count - 1 do
    begin
      lName := Trim(lItems.Names[I]);
      if SameText(lName, 'sample-rate-hz') or
        SameText(lName, 'block-samples') or
        SameText(lName, 'calibration-mode') or
        (Pos('channel.', LowerCase(lName)) = 1) then
      begin
        if Result <> '' then Result := Result + ';';
        Result := Result + lName + '=' + lItems.ValueFromIndex[I];
      end;
    end;
  finally
    lItems.Free;
  end;
end;

procedure TPxiMx248SettingsDialog.FillAdvancedControls(
  const AProperties: string);
var
  lValue: string;
begin
  lValue := ValueFromPacket(AProperties, CKeyBusRole);
  if lValue <> '' then cbBusRole.ItemIndex := cbBusRole.Items.IndexOf(lValue);
  if cbBusRole.ItemIndex < 0 then cbBusRole.ItemIndex := 1;
  lValue := ValueFromPacket(AProperties, CKeyClockSource);
  if lValue <> '' then cbClockSource.ItemIndex := cbClockSource.Items.IndexOf(lValue);
  if cbClockSource.ItemIndex < 0 then cbClockSource.ItemIndex := 1;
  lValue := ValueFromPacket(AProperties, CKeyTriggerLine);
  if lValue <> '' then cbTriggerLine.ItemIndex := cbTriggerLine.Items.IndexOf(lValue);
  if cbTriggerLine.ItemIndex < 0 then cbTriggerLine.ItemIndex := 0;
  lValue := ValueFromPacket(AProperties, CKeyTriggerLevel);
  if lValue = '' then
  begin
    { Compatibility with drafts created before PROP_TRIG_LEVEL was wired. }
    lValue := ValueFromPacket(AProperties, CKeyLegacyTriggerEdge);
    if SameText(lValue, 'rising') then lValue := 'high'
    else if SameText(lValue, 'falling') then lValue := 'low';
  end;
  if lValue <> '' then cbTriggerEdge.ItemIndex := cbTriggerEdge.Items.IndexOf(lValue);
  if cbTriggerEdge.ItemIndex < 0 then cbTriggerEdge.ItemIndex := 0;
  lValue := ValueFromPacket(AProperties, CKeySyncReceive);
  chkExternalSync.Checked := SameText(lValue, 'True');
end;

function TPxiMx248SettingsDialog.AdvancedPropertyPacket: string;
begin
  Result := CKeyClockSource + '=' + cbClockSource.Text + ';' +
    CKeyBusRole + '=' + cbBusRole.Text + ';' +
    CKeySyncReceive + '=' + BoolToStr(chkExternalSync.Checked, True) + ';' +
    CKeyTriggerLine + '=' + cbTriggerLine.Text + ';' +
    CKeyTriggerLevel + '=' + cbTriggerEdge.Text + ';' +
    CPxiMx248AddressRuleKey + '=' + SelectedAddressRule + ';' +
    CPxiMx248SourceAddressKey + '=' + Trim(edSourceAddress.Text);
end;

function TPxiMx248SettingsDialog.BuildPropertyPacket: string;
var
  I: Integer;

  procedure Add(const AName, AValue: string);
  begin
    if Result <> '' then Result := Result + ';';
    Result := Result + AName + '=' + Trim(AValue);
  end;

begin
  Result := '';
  Add('sample-rate-hz', cbSampleRate.Text);
  Add('block-samples', fBlockSamples);
  Add('calibration-mode', cbCalibrationMode.Text);
  for I := 1 to CPxiMx248ChannelCount do
  begin
    { There is deliberately no independent channel enable switch here.
      Runtime participation is defined by the used-tag list; a configured
      channel is otherwise available to the board. }
    Add(ChannelKey(I, 'enabled'), 'True');
    Add(ChannelKey(I, 'amplifier-enabled'),
      gridChannels.Cells[CColAmplifier, I]);
    Add(ChannelKey(I, 'input-mode'), gridChannels.Cells[CColInputMode, I]);
    Add(ChannelKey(I, 'range-index'), IntToStr(fRangeIndices[I]));
    Add(ChannelKey(I, 'lpf-index'), gridChannels.Cells[CColLpf, I]);
    Add(ChannelKey(I, 'icp-current'), gridChannels.Cells[CColIcp, I]);
    Add(ChannelKey(I, 'calibration-enabled'),
      gridChannels.Cells[CColCalibration, I]);
    Add(ChannelKey(I, 'input-floating'),
      FloatingRawValue(gridChannels.Cells[CColFloating, I]));
  end;
end;

function TPxiMx248SettingsDialog.WritablePacketFromCanonical(
  const AProperties: string): string;
var
  I: Integer;

  procedure Add(const AName: string);
  begin
    if Result <> '' then Result := Result + ';';
    Result := Result + AName + '=' + ValueFromPacket(AProperties, AName);
  end;

begin
  Result := '';
  Add('sample-rate-hz');
  Add('block-samples');
  Add('calibration-mode');
  for I := 1 to CPxiMx248ChannelCount do
  begin
    Add(ChannelKey(I, 'enabled'));
    Add(ChannelKey(I, 'amplifier-enabled'));
    Add(ChannelKey(I, 'input-mode'));
    Add(ChannelKey(I, 'range-index'));
    Add(ChannelKey(I, 'lpf-index'));
    Add(ChannelKey(I, 'icp-current'));
    Add(ChannelKey(I, 'calibration-enabled'));
    Add(ChannelKey(I, 'input-floating'));
  end;
end;

function TPxiMx248SettingsDialog.ReadLocation(out AChassis,
  ASlot: Integer): Boolean;
begin
  Result := TryStrToInt(Trim(edChassis.Text), AChassis) and
    (AChassis >= 0) and TryStrToInt(Trim(edSlot.Text), ASlot) and
    (ASlot >= 0);
end;

function TPxiMx248SettingsDialog.ValidateDraft(
  out ACanonicalProperties: string; out AErrorText: string): Boolean;
var
  lChassis, lSlot: Integer;
  lFullSnapshot: string;
  lResult: TRcOperationResult;
begin
  ACanonicalProperties := '';
  AErrorText := '';
  if not ReadLocation(lChassis, lSlot) then
  begin
    AErrorText := 'Шасси и слот должны быть неотрицательными целыми числами.';
    Exit(False);
  end;
  if Trim(edSourceId.Text) = '' then
  begin
    AErrorText := 'Source ID не задан.';
    Exit(False);
  end;
  if not PxiMx248ValidSourceAddress(edSourceAddress.Text) then
  begin
    AErrorText := 'Алиас платы не задан или содержит недопустимые символы.';
    Exit(False);
  end;
  lResult := fDraft.CalcProperties(BuildPropertyPacket, lFullSnapshot);
  Result := lResult.IsSuccess;
  if Result then
  begin
    ACanonicalProperties := WritablePacketFromCanonical(lFullSnapshot);
    if ACanonicalProperties <> '' then ACanonicalProperties :=
      ACanonicalProperties + ';';
    ACanonicalProperties := ACanonicalProperties + AdvancedPropertyPacket;
  end
  else
    AErrorText := lResult.Stage + ': ' + lResult.MessageText;
end;

function TPxiMx248SettingsDialog.ApplyDraft(out AErrorText: string): Boolean;
var
  lCanonical: string;
  lReadback: string;
  lChassis, lSlot: Integer;
  lResult: TRcOperationResult;
begin
  Result := ValidateDraft(lCanonical, AErrorText);
  if not Result then Exit;
  if fService = nil then
  begin
    AErrorText := 'Сервис применения настроек PXI MX-248 не подключён.';
    Exit(False);
  end;
  ReadLocation(lChassis, lSlot);
  SetStatus('Применение к MX-248 и контрольное чтение...', False);
  lResult := fService.ApplyLiveDraft(lChassis, lSlot, lCanonical, lReadback);
  if lResult.IsSuccess then
  begin
    ApplyLiveReadback(lReadback);
    lResult := fService.ApplyDraft(Trim(edSourceId.Text), lChassis, lSlot,
      lCanonical);
  end;
  Result := lResult.IsSuccess;
  if Result then
    AErrorText := ''
  else
    AErrorText := lResult.Stage + ': ' + lResult.MessageText;
end;

procedure TPxiMx248SettingsDialog.SetIoBusy(ABusy: Boolean;
  const AStatus: string);
begin
  fIoBusy := ABusy;
  pages.Enabled := not ABusy;
  btnApply.Enabled := not ABusy;
  btnOk.Enabled := not ABusy;
  btnCancel.Enabled := not ABusy;
  progressIo.Visible := ABusy;
  if AStatus <> '' then SetStatus(AStatus, False);
end;

procedure TPxiMx248SettingsDialog.BeginServiceOperation(AKind: Integer;
  const ASourceId: string; AChassis, ASlot: Integer;
  const AProperties, AStatus: string);
var
  lWorker: TPxiMx248DialogWorker;
begin
  if fIoBusy then Exit;
  if fService = nil then
  begin
    SetStatus('Сервис настроек PXI MX-248 не подключён.', True);
    Exit;
  end;
  SetIoBusy(True, AStatus);
  fPendingSourceId := ASourceId;
  fPendingChassis := AChassis;
  fPendingSlot := ASlot;
  fPendingProperties := AProperties;
  try
    lWorker := TPxiMx248DialogWorker.Create(TPxiMx248DialogOperation(AKind),
      fService, ASourceId, AChassis, ASlot, AProperties,
      @CompleteServiceOperation);
    lWorker.Start;
  except
    on E: Exception do
    begin
      SetIoBusy(False);
      SetStatus('mx248.settings.worker: ' + E.Message, True);
    end;
  end;
end;

procedure TPxiMx248SettingsDialog.CompleteServiceOperation(AKind: Integer;
  const AResult: TRcOperationResult; const AData: string);
var
  lResult: TRcOperationResult;
begin
  SetIoBusy(False);
  { ApplyLiveDraft may have changed hardware even when persistence fails.
    Reflect its readback before reporting the later failure. }
  if (TPxiMx248DialogOperation(AKind) = pdoApply) and (AData <> '') then
    ApplyLiveReadback(AData);
  lResult := AResult;
  if lResult.IsSuccess and
    (TPxiMx248DialogOperation(AKind) = pdoApply) then
    lResult := fService.ApplyDraft(fPendingSourceId, fPendingChassis,
      fPendingSlot, fPendingProperties);
  if not lResult.IsSuccess then
  begin
    fCloseAfterApply := False;
    SetStatus(lResult.Stage + ': ' + lResult.MessageText, True);
    Exit;
  end;
  case TPxiMx248DialogOperation(AKind) of
    pdoApply:
      begin
        SetStatus('Настройки применены.', False);
        if fCloseAfterApply then ModalResult := mrOk;
        fCloseAfterApply := False;
      end;
    pdoRead:
      begin
        ApplyLiveReadback(AData);
        SetStatus('Свойства прочитаны с платы.', False);
      end;
    pdoZero:
      SetStatus('Балансировка выполнена: ' + AData, False);
  end;
end;

procedure TPxiMx248SettingsDialog.ApplyLiveReadback(const AProperties: string);
var
  I, lValue: Integer;
  lText: string;
begin
  lText := ValueFromPacket(AProperties, 'sample-rate-hz');
  if lText <> '' then cbSampleRate.ItemIndex := cbSampleRate.Items.IndexOf(lText);
  for I := 1 to CPxiMx248ChannelCount do
  begin
    lText := ValueFromPacket(AProperties, Format('ch%d.enabled', [I]));
    lText := ValueFromPacket(AProperties, Format('ch%d.amplifier-enabled', [I]));
    if lText <> '' then gridChannels.Cells[CColAmplifier, I] :=
      BoolToStr(lText <> '0', True);
    lText := ValueFromPacket(AProperties, Format('ch%d.input-mode', [I]));
    if TryStrToInt(lText, lValue) then
      if lValue = 1 then gridChannels.Cells[CColInputMode, I] := 'single-ended'
      else gridChannels.Cells[CColInputMode, I] := 'differential';
    lText := ValueFromPacket(AProperties, Format('ch%d.range-index', [I]));
    if lText <> '' then
    begin
      fRangeIndices[I] := StrToIntDef(lText, 0);
      UpdateChannelRangeText(I);
    end;
    lText := ValueFromPacket(AProperties, Format('ch%d.lpf-index', [I]));
    if lText <> '' then gridChannels.Cells[CColLpf, I] := lText;
    lText := ValueFromPacket(AProperties, Format('ch%d.icp-current', [I]));
    if TryStrToInt(lText, lValue) then
      case lValue of 1: gridChannels.Cells[CColIcp, I] := '4';
        2: gridChannels.Cells[CColIcp, I] := '10';
      else gridChannels.Cells[CColIcp, I] := 'off' end;
    lText := ValueFromPacket(AProperties, Format('ch%d.calibration-mode', [I]));
    if lText <> '' then gridChannels.Cells[CColCalibration, I] :=
      BoolToStr(lText <> '0', True);
    lText := ValueFromPacket(AProperties, Format('ch%d.input-floating', [I]));
    if lText <> '' then gridChannels.Cells[CColFloating, I] :=
      FloatingText(BoolToStr(lText <> '0', True));
  end;
  lText := ValueFromPacket(AProperties, 'rtsi-clock');
  if TryStrToInt(lText, lValue) then
    if lValue = 0 then cbClockSource.ItemIndex := cbClockSource.Items.IndexOf('PXI_CLK10')
    else cbClockSource.ItemIndex := cbClockSource.Items.IndexOf('internal');
  lText := ValueFromPacket(AProperties, 'rtsi-sync');
  if TryStrToInt(lText, lValue) then
  begin
    case lValue of
      0: cbBusRole.ItemIndex := cbBusRole.Items.IndexOf('Slave');
      1: cbBusRole.ItemIndex := cbBusRole.Items.IndexOf('Master');
      2: cbBusRole.ItemIndex := cbBusRole.Items.IndexOf('Hardwired');
    end;
  end;
  lText := ValueFromPacket(AProperties, 'trigger-mode');
  if TryStrToInt(lText, lValue) and (lValue <> 0) then
    cbTriggerLine.ItemIndex := cbTriggerLine.Items.IndexOf('PXI_TRIG' +
      ValueFromPacket(AProperties, 'trigger-source'))
  else cbTriggerLine.ItemIndex := 0;
  lText := ValueFromPacket(AProperties, 'trigger-level');
  if TryStrToInt(lText, lValue) then
    if lValue <> 0 then
      cbTriggerEdge.ItemIndex := cbTriggerEdge.Items.IndexOf('high')
    else
      cbTriggerEdge.ItemIndex := cbTriggerEdge.Items.IndexOf('low');
end;

procedure TPxiMx248SettingsDialog.ReadLiveClick(Sender: TObject);
var
  lChassis, lSlot: Integer;
begin
  if not ReadLocation(lChassis, lSlot) then
  begin
    SetStatus('Шасси и слот должны быть неотрицательными целыми числами.', True);
    Exit;
  end;
  BeginServiceOperation(Ord(pdoRead), '', lChassis, lSlot, '',
    'Чтение свойств MX-248...');
end;

procedure TPxiMx248SettingsDialog.ZeroBalanceClick(Sender: TObject);
var
  lChassis, lSlot: Integer;
begin
  if not ReadLocation(lChassis, lSlot) then
  begin
    SetStatus('Шасси и слот должны быть неотрицательными целыми числами.', True);
    Exit;
  end;
  BeginServiceOperation(Ord(pdoZero), '', lChassis, lSlot, '',
    'Балансировка каналов MX-248...');
end;

procedure TPxiMx248SettingsDialog.SetStatus(const AText: string;
  AIsError: Boolean);
begin
  lblStatus.Caption := AText;
  if AIsError then lblStatus.Font.Color := clRed
  else lblStatus.Font.Color := clGreen;
end;

procedure TPxiMx248SettingsDialog.UpdateSourceId;
var
  lChassis, lSlot: Integer;
begin
  if ReadLocation(lChassis, lSlot) then
    edSourceId.Text := Format('pxi-mx248:%d:%d', [lChassis, lSlot]);
end;

procedure TPxiMx248SettingsDialog.LocationChange(Sender: TObject);
begin
  UpdateSourceId;
  if SelectedAddressRule <> CPxiMx248AddressRuleManual then
    AddressRuleChange(nil)
  else UpdateAddressPreview;
end;

procedure TPxiMx248SettingsDialog.GridDblClick(Sender: TObject);
var
  lCell: string;
  lRow: Integer;
  lAmplifier, lInputMode, lRange, lLpf, lIcp,
    lCalibration, lFloating: string;
begin
  lRow := gridChannels.Row;
  if lRow < 1 then Exit;
  if gridChannels.Col = CColIcp then
  begin
    lCell := gridChannels.Cells[CColIcp, lRow];
    if SameText(lCell, 'off') then lCell := '4'
    else if lCell = '4' then lCell := '10'
    else lCell := 'off';
    gridChannels.Cells[CColIcp, lRow] := lCell;
    SetStatus(Format('Канал %d: IEPE %s.', [lRow, lCell]), False);
    Exit;
  end;
  if gridChannels.Col in
    [CColAmplifier, CColCalibration, CColFloating] then
  begin
    lCell := gridChannels.Cells[gridChannels.Col, lRow];
    if gridChannels.Col = CColFloating then
      gridChannels.Cells[CColFloating, lRow] := FloatingText(
        BoolToStr(not SameText(FloatingRawValue(lCell), 'True'), True))
    else
      gridChannels.Cells[gridChannels.Col, lRow] :=
        BoolToStr(not SameText(lCell, 'True'), True);
    if gridChannels.Col = CColAmplifier then UpdateChannelRangeText(lRow);
    Exit;
  end;
  lAmplifier := gridChannels.Cells[CColAmplifier, lRow];
  lInputMode := gridChannels.Cells[CColInputMode, lRow];
  lRange := IntToStr(fRangeIndices[lRow]);
  lLpf := gridChannels.Cells[CColLpf, lRow];
  lIcp := gridChannels.Cells[CColIcp, lRow];
  lCalibration := gridChannels.Cells[CColCalibration, lRow];
  lFloating := FloatingRawValue(gridChannels.Cells[CColFloating, lRow]);
  if EditPxiMx248Channel(Self, lRow, lAmplifier, lInputMode,
    lRange, lLpf, lIcp, lCalibration, lFloating) then
  begin
    gridChannels.Cells[CColAmplifier, lRow] := lAmplifier;
    gridChannels.Cells[CColInputMode, lRow] := lInputMode;
    fRangeIndices[lRow] := StrToIntDef(lRange, 0);
    UpdateChannelRangeText(lRow);
    gridChannels.Cells[CColLpf, lRow] := lLpf;
    gridChannels.Cells[CColIcp, lRow] := lIcp;
    gridChannels.Cells[CColCalibration, lRow] := lCalibration;
    gridChannels.Cells[CColFloating, lRow] := FloatingText(lFloating);
  end;
end;

procedure TPxiMx248SettingsDialog.ApplyClick(Sender: TObject);
var
  lError, lProperties: string;
  lChassis, lSlot: Integer;
begin
  if not ValidateDraft(lProperties, lError) then
  begin
    SetStatus(lError, True);
    Exit;
  end;
  ReadLocation(lChassis, lSlot);
  fCloseAfterApply := False;
  BeginServiceOperation(Ord(pdoApply), Trim(edSourceId.Text), lChassis, lSlot,
    lProperties, 'Применение к MX-248 и контрольное чтение...');
end;

procedure TPxiMx248SettingsDialog.OkClick(Sender: TObject);
var
  lError, lProperties: string;
  lChassis, lSlot: Integer;
begin
  if not ValidateDraft(lProperties, lError) then
  begin
    SetStatus(lError, True);
    Exit;
  end;
  ReadLocation(lChassis, lSlot);
  fCloseAfterApply := True;
  BeginServiceOperation(Ord(pdoApply), Trim(edSourceId.Text), lChassis, lSlot,
    lProperties, 'Применение к MX-248 и контрольное чтение...');
end;

end.
