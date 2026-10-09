unit uRecorderPxiMx248SettingsDialog;

{
  Назначение: LCL-редактор offline-черновика PXI MX-248 для восьми каналов.
  Его вызывает configured-source editor после выбора модуля. Форма строит один
  строковый пакет, проверяет его штатным TPxiMx248PropertyStore и только затем
  передаёт сервису применения.

  Контракт: форма не подключается к оборудованию, не управляет lifecycle и не
  публикует теги. Основная компоновка хранится в LFM. До успешного ApplyDraft
  исходная конфигурация не меняется. Все channel keys one-based, строки grid
  соответствуют каналам 1..8. Архитектура: Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids,
  uRecorderDriverContractsV2, uRecorderPxiMx248Properties,
  uRecorderPxiMx248Types, uRecorderPxiMx248SettingsService;

type
  TPxiMx248SettingsDialog = class(TForm)
    btnApply: TButton;
    btnCancel: TButton;
    btnSearch: TButton;
    btnOk: TButton;
    cbCalibrationMode: TComboBox;
    cbDiscovered: TComboBox;
    edBlockSamples: TEdit;
    edChassis: TEdit;
    edSampleRate: TEdit;
    edSlot: TEdit;
    edSourceId: TEdit;
    gridChannels: TStringGrid;
    lblBlockSamples: TLabel;
    lblCalibrationMode: TLabel;
    lblChassis: TLabel;
    lblDiscovered: TLabel;
    lblSampleRate: TLabel;
    lblSlot: TLabel;
    lblSourceId: TLabel;
    lblStatus: TLabel;
    pnButtons: TPanel;
    pnDevice: TPanel;
    procedure ApplyClick(Sender: TObject);
    procedure DiscoveredChange(Sender: TObject);
    procedure DiscoverClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure LocationChange(Sender: TObject);
    procedure OkClick(Sender: TObject);
  private
    fDraft: TPxiMx248PropertyStore;
    fDiscovered: TPxiMx248DiscoveredDevices;
    fService: IPxiMx248SettingsService;
    procedure ConfigureChoices;
    procedure ConfigureGrid;
    procedure FillControls(const AProperties: string);
    function BuildPropertyPacket: string;
    function ChannelKey(AChannel: Integer; const AName: string): string;
    function ReadLocation(out AChassis, ASlot: Integer): Boolean;
    procedure SetStatus(const AText: string; AIsError: Boolean);
    procedure UpdateSourceId;
    procedure LinkDiscoveredDevice(AIndex: Integer);
    function ValueFromPacket(const APacket, AName: string): string;
    function WritablePacketFromCanonical(const AProperties: string): string;
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
  Graphics, uRecorderPxiMx248DiscoveryWorker;

const
  CColChannel = 0;
  CColEnabled = 1;
  CColAmplifier = 2;
  CColInputMode = 3;
  CColRange = 4;
  CColLpf = 5;
  CColIcp = 6;
  CColCalibration = 7;
  CColFloating = 8;

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
  SetStatus(Format('Предложена привязка: %s, SN=%d, шасси=%d, слот=%d. ' +
    'Нажмите Применить или OK для сохранения.', [lDevice.DeviceName,
    lDevice.SerialNumber, lDevice.Chassis, lDevice.Slot]), False);
end;

procedure TPxiMx248SettingsDialog.DiscoveredChange(Sender: TObject);
begin
  LinkDiscoveredDevice(cbDiscovered.ItemIndex);
end;

procedure TPxiMx248SettingsDialog.DiscoverClick(Sender: TObject);
var
  I: Integer;
  lResult: TRecorderOperationResult;
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

destructor TPxiMx248SettingsDialog.Destroy;
begin
  fService := nil;
  fDraft.Free;
  inherited Destroy;
end;

procedure TPxiMx248SettingsDialog.ConfigureChoices;
begin
  cbCalibrationMode.Items.Clear;
  cbCalibrationMode.Items.Add('reference');
  cbCalibrationMode.Items.Add('pxi');
  cbCalibrationMode.ItemIndex := 0;
end;

procedure TPxiMx248SettingsDialog.ConfigureGrid;
var
  I: Integer;
begin
  gridChannels.ColCount := 9;
  gridChannels.RowCount := CPxiMx248ChannelCount + 1;
  gridChannels.FixedRows := 1;
  gridChannels.Cells[CColChannel, 0] := 'Канал';
  gridChannels.Cells[CColEnabled, 0] := 'Вкл.';
  gridChannels.Cells[CColAmplifier, 0] := 'Усил.';
  gridChannels.Cells[CColInputMode, 0] := 'Вход';
  gridChannels.Cells[CColRange, 0] := 'Диапазон';
  gridChannels.Cells[CColLpf, 0] := 'LPF';
  gridChannels.Cells[CColIcp, 0] := 'ICP, mA';
  gridChannels.Cells[CColCalibration, 0] := 'Калибр.';
  gridChannels.Cells[CColFloating, 0] := 'Floating';
  for I := 1 to CPxiMx248ChannelCount do
    gridChannels.Cells[CColChannel, I] := IntToStr(I);
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
  edSampleRate.Text := ValueFromPacket(AProperties, 'sample-rate-hz');
  edBlockSamples.Text := ValueFromPacket(AProperties, 'block-samples');
  cbCalibrationMode.Text := ValueFromPacket(AProperties, 'calibration-mode');
  for I := 1 to CPxiMx248ChannelCount do
  begin
    gridChannels.Cells[CColEnabled, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'enabled'));
    gridChannels.Cells[CColAmplifier, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'amplifier-enabled'));
    gridChannels.Cells[CColInputMode, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'input-mode'));
    gridChannels.Cells[CColRange, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'range-index'));
    gridChannels.Cells[CColLpf, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'lpf-index'));
    gridChannels.Cells[CColIcp, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'icp-current'));
    gridChannels.Cells[CColCalibration, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'calibration-enabled'));
    gridChannels.Cells[CColFloating, I] :=
      ValueFromPacket(AProperties, ChannelKey(I, 'input-floating'));
  end;
end;

procedure TPxiMx248SettingsDialog.LoadDraft(const ASourceId,
  AProperties: string; AChassis, ASlot: Integer;
  const AService: IPxiMx248SettingsService);
var
  lCanonical: string;
  lResult: TRecorderOperationResult;
begin
  fService := AService;
  edChassis.Text := IntToStr(AChassis);
  edSlot.Text := IntToStr(ASlot);
  edSourceId.Text := ASourceId;
  if Trim(ASourceId) = '' then UpdateSourceId;
  if Trim(AProperties) = '' then Exit;
  lResult := fDraft.CalcProperties(AProperties, lCanonical);
  if not lResult.IsSuccess then
  begin
    SetStatus(lResult.MessageText, True);
    Exit;
  end;
  FillControls(lCanonical);
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
  Add('sample-rate-hz', edSampleRate.Text);
  Add('block-samples', edBlockSamples.Text);
  Add('calibration-mode', cbCalibrationMode.Text);
  for I := 1 to CPxiMx248ChannelCount do
  begin
    Add(ChannelKey(I, 'enabled'), gridChannels.Cells[CColEnabled, I]);
    Add(ChannelKey(I, 'amplifier-enabled'),
      gridChannels.Cells[CColAmplifier, I]);
    Add(ChannelKey(I, 'input-mode'), gridChannels.Cells[CColInputMode, I]);
    Add(ChannelKey(I, 'range-index'), gridChannels.Cells[CColRange, I]);
    Add(ChannelKey(I, 'lpf-index'), gridChannels.Cells[CColLpf, I]);
    Add(ChannelKey(I, 'icp-current'), gridChannels.Cells[CColIcp, I]);
    Add(ChannelKey(I, 'calibration-enabled'),
      gridChannels.Cells[CColCalibration, I]);
    Add(ChannelKey(I, 'input-floating'),
      gridChannels.Cells[CColFloating, I]);
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
  lResult: TRecorderOperationResult;
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
  lResult := fDraft.CalcProperties(BuildPropertyPacket, lFullSnapshot);
  Result := lResult.IsSuccess;
  if Result then
    ACanonicalProperties := WritablePacketFromCanonical(lFullSnapshot)
  else
    AErrorText := lResult.Stage + ': ' + lResult.MessageText;
end;

function TPxiMx248SettingsDialog.ApplyDraft(out AErrorText: string): Boolean;
var
  lCanonical: string;
  lChassis, lSlot: Integer;
  lResult: TRecorderOperationResult;
begin
  Result := ValidateDraft(lCanonical, AErrorText);
  if not Result then Exit;
  if fService = nil then
  begin
    AErrorText := 'Сервис применения настроек PXI MX-248 не подключён.';
    Exit(False);
  end;
  ReadLocation(lChassis, lSlot);
  lResult := fService.ApplyDraft(Trim(edSourceId.Text), lChassis, lSlot,
    lCanonical);
  Result := lResult.IsSuccess;
  if Result then
    AErrorText := ''
  else
    AErrorText := lResult.Stage + ': ' + lResult.MessageText;
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
end;

procedure TPxiMx248SettingsDialog.GridDblClick(Sender: TObject);
var
  lCell: string;
begin
  if (gridChannels.Row < 1) or not (gridChannels.Col in
    [CColEnabled, CColAmplifier, CColCalibration, CColFloating]) then Exit;
  lCell := gridChannels.Cells[gridChannels.Col, gridChannels.Row];
  gridChannels.Cells[gridChannels.Col, gridChannels.Row] :=
    BoolToStr(not SameText(lCell, 'True'), True);
end;

procedure TPxiMx248SettingsDialog.ApplyClick(Sender: TObject);
var
  lError: string;
begin
  if ApplyDraft(lError) then SetStatus('Настройки применены.', False)
  else SetStatus(lError, True);
end;

procedure TPxiMx248SettingsDialog.OkClick(Sender: TObject);
var
  lError: string;
begin
  if ApplyDraft(lError) then ModalResult := mrOk
  else SetStatus(lError, True);
end;

end.
