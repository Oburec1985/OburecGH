unit uTagSettingsDialog;

{
  Модуль uTagSettingsDialog

  Назначение:
    Диалог редактирования одного или нескольких тегов/каналов RecorderLnx.

  Правила множественного выбора (multi-select):
    - Поле ввода показывает значение только тогда, когда это значение одинаково для всех выбранных тегов.
    - Пустые поля со смешанными (различающимися) значениями оставляются без изменений при сохранении (нажатии ОК).
    - Имя канала редактируется только тогда, когда выбран один единственный тег.

  Библиотеки и зависимости:
    - Classes, SysUtils, Forms, Controls, Graphics: базовые модули LCL.
    - StdCtrls, ExtCtrls, ComCtrls, Buttons, Dialogs: компоненты интерфейса (кнопки, вкладки, поля ввода).
    - uRecorderTags: классы тегов/каналов и их уставки.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls,
  Buttons, Dialogs, ImgList, uRecorderTags, uMeraFile, uComponentServices,
  uRecorderCalibrationAddDialog, uRecorderCalibrationPropertiesDialog,
  uRecorderCalibrationListDialog;

type
  { TTagSettingsDialog }

  { Диалоговое окно настройки свойств тега (канала) }
  TTagSettingsDialog = class(TForm)
  published
    fPageControl: TPageControl;
    tsParams: TTabSheet;
    gbGeneral: TGroupBox;
    lbName: TLabel;
    fNameEdit: TEdit;
    lbUnit: TLabel;
    fUnitCombo: TComboBox;
    fAutoUnitCheck: TCheckBox;
    lbModule: TLabel;
    fModuleEdit: TEdit;
    fAddressButton: TSpeedButton;
    lbDescription: TLabel;
    fDescriptionEdit: TEdit;
    fDescriptionEditBtn: TSpeedButton;
    lbFrequency: TLabel;
    fFrequencyCombo: TComboBox;
    lbHz: TLabel;
    fDetachedSourceLabel: TLabel;
    gbRange: TGroupBox;
    lbMin: TLabel;
    fMinEdit: TEdit;
    lbMax: TLabel;
    fMaxEdit: TEdit;
    fAutoRangeCheck: TCheckBox;
    gbHardwareCurve: TGroupBox;
    fHardwareCurveCheck: TCheckBox;
    fHardwareCurveEdit: TEdit;
    fHardwareCurveSelectBtn: TSpeedButton;
    fHardwareCurveSetupBtn: TSpeedButton;
    gbChannelCurve: TGroupBox;
    fChannelCurveCheck: TCheckBox;
    fChannelCurveEdit: TEdit;
    fChannelCurveSelectBtn: TSpeedButton;
    fChannelCurveAddBtn: TSpeedButton;
    fChannelCurveDeleteBtn: TSpeedButton;
    fChannelCurveEditBtn: TSpeedButton;
    lbVirtualChannelInfo: TLabel;
    tsAdditional: TTabSheet;
    gbEstimates: TGroupBox;
    fEstimateCheckMO: TCheckBox;
    fEstimateCheckSKZ: TCheckBox;
    fEstimateCheckSKO: TCheckBox;
    fEstimateCheckPeak: TCheckBox;
    fEstimateCheckPeakPeak: TCheckBox;
    fEstimateCheckMin: TCheckBox;
    fEstimateCheckMax: TCheckBox;
    fEstimateCheckPeakPeakByRms: TCheckBox;
    lbDefaultEstimate: TLabel;
    fDefaultEstimateCombo: TComboBox;
    gbPortion: TGroupBox;
    fPortionLengthEdit: TEdit;
    lbPortionUnit: TLabel;
    gbSmoothing: TGroupBox;
    fSmoothingCheck: TCheckBox;
    fSmoothingKEdit: TEdit;
    gbChannelProps: TGroupBox;
    fScadaCheck: TCheckBox;
    tsSetpoints: TTabSheet;
    pnSetpoint0: TPanel;
    lbSetpointName0: TLabel;
    fSetpointEnabledCheck0: TCheckBox;
    pnSetpointUnit0: TPanel;
    fSetpointThresholdEdit0: TEdit;
    lbSetpointText0_1: TLabel;
    lbSetpointText0_2: TLabel;
    fSetpointColorPanel0: TPanel;
    pnSetpoint1: TPanel;
    lbSetpointName1: TLabel;
    fSetpointEnabledCheck1: TCheckBox;
    pnSetpointUnit1: TPanel;
    fSetpointThresholdEdit1: TEdit;
    lbSetpointText1_1: TLabel;
    lbSetpointText1_2: TLabel;
    fSetpointColorPanel1: TPanel;
    pnSetpoint2: TPanel;
    lbSetpointName2: TLabel;
    fSetpointEnabledCheck2: TCheckBox;
    pnSetpointUnit2: TPanel;
    fSetpointThresholdEdit2: TEdit;
    lbSetpointText2_1: TLabel;
    lbSetpointText2_2: TLabel;
    fSetpointColorPanel2: TPanel;
    pnSetpoint3: TPanel;
    lbSetpointName3: TLabel;
    fSetpointEnabledCheck3: TCheckBox;
    pnSetpointUnit3: TPanel;
    fSetpointThresholdEdit3: TEdit;
    lbSetpointText3_1: TLabel;
    lbSetpointText3_2: TLabel;
    fSetpointColorPanel3: TPanel;
    pnSetpointAdd: TPanel;
    lbSetpointAddName: TLabel;
    fSetpointHysteresisCheck: TCheckBox;
    fSetpointStatusChannelCheck: TCheckBox;
    fSetpointSoundCheck: TCheckBox;
    pnBottom: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    fApplyButton: TButton;
  private
    fImages: TCustomImageList;                           // Список иконок для диалога
    fTagRegistry: TRecorderTagRegistry;                  // Реестр тегов
    fSelectedMeraFileName: string;                       // Путь выбранного Mera-файла
    fTags: TList;                                        // Список редактируемых тегов (TRecorderTag)
    fEstimateChecks: array[TRecorderTagEstimateKind] of TCheckBox; // Флаги вычисления различных оценок
    fSetpointColorPanels: array[TRecorderTagSetpointKind] of TPanel; // Цвета отображения для каждой уставки
    fSetpointEnabledChecks: array[TRecorderTagSetpointKind] of TCheckBox; // Флаги активности уставок
    fSetpointThresholdEdits: array[TRecorderTagSetpointKind] of TEdit; // Значения порогов уставок
    
    // Внутренние методы обработчиков UI
    procedure ApplyButtonClick(Sender: TObject);
    procedure AddressButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure SelectCalibrationButtonClick(Sender: TObject);
    procedure AddCalibrationButtonClick(Sender: TObject);
    procedure DeleteCalibrationButtonClick(Sender: TObject);
    procedure EditCalibrationButtonClick(Sender: TObject);
    procedure AssignSpeedButtonImage(AButton: TSpeedButton; AImageIndex: Integer);
    procedure UpdateChannelCurveText;
    
    // Обмен данными между UI и тегами
    procedure LoadFromTags;
    procedure StoreToTags;
    procedure ApplyMeraSignalToCurrentTag(const ASourceId: string;
      ASignal: TMeraSignalInfo);
    function SelectActiveMeraSignal(out ASourceId: string;
      out ASignal: TMeraSignalInfo): Boolean;
    
    // Функции проверки согласованности значений при множественном выборе
    function AllBool(AGetter: Integer): Integer;
    function AllEstimateBool(AKind: TRecorderTagEstimateKind;
      out AValue: Boolean): Boolean;
    function AllEstimateDefault(out AValue: TRecorderTagEstimateKind): Boolean;
    function AllEstimateFlag(AGetter: Integer; out AValue: Boolean): Boolean;
    function AllEstimateFloat(AKind: Integer; out AValue: Double): Boolean;
    function AllEstimateInt(out AValue: Integer): Boolean;
    function AllFloat(AKind: Integer; out AValue: Double): Boolean;
    function AllSetpointBool(AKind: TRecorderTagSetpointKind;
      AGetter: Integer; out AValue: Boolean): Boolean;
    function AllSetpointFloat(AKind: TRecorderTagSetpointKind;
      AGetter: Integer; out AValue: Double): Boolean;
    function AllSetpointGlobalBool(AGetter: Integer; out AValue: Boolean): Boolean;
    function AllString(AKind: Integer; out AValue: string): Boolean;
    
    // Дополнительные проверки и чтение чисел
    function FrequencyCanBeEdited: Boolean;
    function HasDetachedSource: Boolean;
    function IsSignalAlreadyLinked(const ASourceId: string;
      ASignal: TMeraSignalInfo; AExceptTag: TRecorderTag): Boolean;
    function SourceNeedsActiveCheck(const ASourceId: string): Boolean;
    function ReadFloat(const AText: string; out AValue: Double): Boolean;
    
    { Быстрое приведение к типу TRecorderTag по индексу }
    function TagAt(AIndex: Integer): TRecorderTag;
  public
    constructor CreateDialog(AOwner: TComponent; ATagRegistry: TRecorderTagRegistry;
      ATags: TList; AImages: TCustomImageList = nil); reintroduce;
    destructor Destroy; override;
  end;

function ShowTagSettingsDialog(AOwner: TComponent; ATagRegistry: TRecorderTagRegistry; ATags: TList; AImages: TCustomImageList = nil): Boolean;

implementation

{$R *.lfm}

const
  CTagDialogIconAddress = 0;
  CTagDialogIconEdit = 1;
  CTagDialogIconProperty = 2;
  CTagDialogIconHardwareCurve = 3;
  CTagDialogIconAdd = 4;
  CTagDialogIconRemove = 5;
  CTagDialogIconChannelCurve = 6;

function ShowSelectSignalDialog(AOwner: TComponent; AList: TStrings; var ASelectedIndex: Integer): Boolean;
var
  lForm: TForm;
  lListBox: TListBox;
  lOkBtn, lCancelBtn: TButton;
begin
  lForm := TForm.CreateNew(AOwner, 1);
  try
    lForm.Caption := 'Выбор сигнала источника';
    lForm.SetBounds(0, 0, 350, 450);
    lForm.Position := poOwnerFormCenter;
    lForm.BorderStyle := bsDialog;
    
    lListBox := TListBox.Create(lForm);
    lListBox.Parent := lForm;
    lListBox.SetBounds(10, 10, 314, 340);
    lListBox.Items.Assign(AList);
    
    lOkBtn := TButton.Create(lForm);
    lOkBtn.Parent := lForm;
    lOkBtn.SetBounds(140, 370, 80, 25);
    lOkBtn.Caption := 'OK';
    lOkBtn.ModalResult := mrOk;
    lOkBtn.Default := True;
    
    lCancelBtn := TButton.Create(lForm);
    lCancelBtn.Parent := lForm;
    lCancelBtn.SetBounds(230, 370, 80, 25);
    lCancelBtn.Caption := 'Отмена';
    lCancelBtn.ModalResult := mrCancel;
    
    if lListBox.Items.Count > 0 then
      lListBox.ItemIndex := 0;
      
    Result := lForm.ShowModal = mrOk;
    if Result then
      ASelectedIndex := lListBox.ItemIndex;
  finally
    lForm.Free;
  end;
end;

function ShowTagSettingsDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; ATags: TList;
  AImages: TCustomImageList): Boolean;
var
  lDialog: TTagSettingsDialog;
begin
  lDialog := TTagSettingsDialog.CreateDialog(AOwner, ATagRegistry, ATags, AImages);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TTagSettingsDialog.CreateDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; ATags: TList; AImages: TCustomImageList);
begin
  inherited Create(AOwner);
  if ATagRegistry = nil then
    raise ERecorderTagError.Create('Tag registry cannot be nil');
  if (ATags = nil) or (ATags.Count = 0) then
    raise ERecorderTagError.Create('No tags selected');

  fTagRegistry := ATagRegistry;
  fImages := AImages;
  fTags := TList.Create;
  fTags.Assign(ATags);

  // Инициализируем массивы ссылками на компоненты формы LFM
  fEstimateChecks[tekMean] := fEstimateCheckMO;
  fEstimateChecks[tekRmsValue] := fEstimateCheckSKZ;
  fEstimateChecks[tekRmsDeviation] := fEstimateCheckSKO;
  fEstimateChecks[tekPeak] := fEstimateCheckPeak;
  fEstimateChecks[tekPeakToPeak] := fEstimateCheckPeakPeak;
  fEstimateChecks[tekMinimum] := fEstimateCheckMin;
  fEstimateChecks[tekMaximum] := fEstimateCheckMax;
  fEstimateChecks[tekPeakToPeakByRmsDeviation] := fEstimateCheckPeakPeakByRms;
  fEstimateChecks[tekLastValue] := nil;

  fSetpointEnabledChecks[tskHighAlarm] := fSetpointEnabledCheck0;
  fSetpointEnabledChecks[tskHighWarning] := fSetpointEnabledCheck1;
  fSetpointEnabledChecks[tskLowWarning] := fSetpointEnabledCheck2;
  fSetpointEnabledChecks[tskLowAlarm] := fSetpointEnabledCheck3;

  fSetpointThresholdEdits[tskHighAlarm] := fSetpointThresholdEdit0;
  fSetpointThresholdEdits[tskHighWarning] := fSetpointThresholdEdit1;
  fSetpointThresholdEdits[tskLowWarning] := fSetpointThresholdEdit2;
  fSetpointThresholdEdits[tskLowAlarm] := fSetpointThresholdEdit3;

  fSetpointColorPanels[tskHighAlarm] := fSetpointColorPanel0;
  fSetpointColorPanels[tskHighWarning] := fSetpointColorPanel1;
  fSetpointColorPanels[tskLowWarning] := fSetpointColorPanel2;
  fSetpointColorPanels[tskLowAlarm] := fSetpointColorPanel3;
  fAddressButton.OnClick := @AddressButtonClick;
  fChannelCurveSelectBtn.OnClick := @SelectCalibrationButtonClick;
  fChannelCurveAddBtn.OnClick := @AddCalibrationButtonClick;
  fChannelCurveDeleteBtn.OnClick := @DeleteCalibrationButtonClick;
  fChannelCurveEditBtn.OnClick := @EditCalibrationButtonClick;
  fHardwareCurveSelectBtn.OnClick := @SelectCalibrationButtonClick;
  fHardwareCurveSetupBtn.OnClick := @EditCalibrationButtonClick;
  btnOk.OnClick := @OkButtonClick;
  fApplyButton.OnClick := @ApplyButtonClick;

  AssignSpeedButtonImage(fAddressButton, CTagDialogIconAddress);
  AssignSpeedButtonImage(fDescriptionEditBtn, CTagDialogIconEdit);
  AssignSpeedButtonImage(fHardwareCurveSelectBtn, CTagDialogIconProperty);
  AssignSpeedButtonImage(fHardwareCurveSetupBtn, CTagDialogIconHardwareCurve);
  AssignSpeedButtonImage(fChannelCurveSelectBtn, CTagDialogIconProperty);
  AssignSpeedButtonImage(fChannelCurveAddBtn, CTagDialogIconAdd);
  AssignSpeedButtonImage(fChannelCurveDeleteBtn, CTagDialogIconRemove);
  AssignSpeedButtonImage(fChannelCurveEditBtn, CTagDialogIconChannelCurve);
  LoadFromTags;
end;

destructor TTagSettingsDialog.Destroy;
begin
  fTags.Free;
  inherited Destroy;
end;


procedure TTagSettingsDialog.AssignSpeedButtonImage(AButton: TSpeedButton; AImageIndex: Integer);
begin
  if (AButton = nil) or (fImages = nil) or (AImageIndex < 0) or
    (AImageIndex >= fImages.Count) then
    Exit;
  AButton.Images := fImages;
  AButton.ImageIndex := AImageIndex;
  AButton.ImageWidth := 32;
  AButton.Caption := '';
end;

procedure TTagSettingsDialog.UpdateChannelCurveText;
begin
  if fTags.Count = 0 then
    Exit;
  if TagAt(0).CalibrationNames.Count > 0 then
    fChannelCurveEdit.Text :=
      TagAt(0).CalibrationNames[TagAt(0).CalibrationNames.Count - 1]
  else
    fChannelCurveEdit.Text := '';
  fChannelCurveCheck.Checked := fChannelCurveEdit.Text <> '';
end;
function TTagSettingsDialog.TagAt(AIndex: Integer): TRecorderTag;
begin
  Result := TRecorderTag(fTags[AIndex]);
end;

{ Динамическое создание UI для поддержки автономного существования без DFM }
function TTagSettingsDialog.AllString(AKind: Integer; out AValue: string): Boolean;
var
  I: Integer;
  lValue: string;
begin
  AValue := '';
  if fTags.Count = 0 then
    Exit(False);

  case AKind of
    0: AValue := TagAt(0).Name;
    1: AValue := TagAt(0).UnitName;
    2: AValue := TagAt(0).Address;
    3: AValue := TagAt(0).Description;
    4: AValue := TagAt(0).ModuleType;
  end;

  for I := 1 to fTags.Count - 1 do
  begin
    case AKind of
      0: lValue := TagAt(I).Name;
      1: lValue := TagAt(I).UnitName;
      2: lValue := TagAt(I).Address;
      3: lValue := TagAt(I).Description;
      4: lValue := TagAt(I).ModuleType;
    else
      lValue := '';
    end;
    if not SameText(AValue, lValue) then
      Exit(False);
  end;
  Result := True;
end;

{ Возвращает True, если вещественное свойство совпадает для всех тегов }
function TTagSettingsDialog.AllFloat(AKind: Integer; out AValue: Double): Boolean;
var
  I: Integer;
  lValue: Double;
begin
  AValue := 0;
  if fTags.Count = 0 then
    Exit(False);

  case AKind of
    0: AValue := TagAt(0).PollFrequencyHz;
    1: AValue := TagAt(0).RangeMin;
    2: AValue := TagAt(0).RangeMax;
  end;

  for I := 1 to fTags.Count - 1 do
  begin
    case AKind of
      0: lValue := TagAt(I).PollFrequencyHz;
      1: lValue := TagAt(I).RangeMin;
      2: lValue := TagAt(I).RangeMax;
    else
      lValue := 0;
    end;
    if Abs(AValue - lValue) > 1E-9 then
      Exit(False);
  end;
  Result := True;
end;

{ Возвращает 1 (True), 0 (False) или -1 (различаются) }
function TTagSettingsDialog.AllBool(AGetter: Integer): Integer;
var
  I: Integer;
  lValue: Boolean;
  lFirst: Boolean;
begin
  Result := -1;
  if fTags.Count = 0 then
    Exit;

  if AGetter = 0 then
    lFirst := TagAt(0).AutoUnit
  else
    lFirst := TagAt(0).AutoRange;

  for I := 1 to fTags.Count - 1 do
  begin
    if AGetter = 0 then
      lValue := TagAt(I).AutoUnit
    else
      lValue := TagAt(I).AutoRange;
    if lFirst <> lValue then
      Exit;
  end;

  if lFirst then
    Result := 1
  else
    Result := 0;
end;

{ Совпадение настроек флага вычисляемых оценок }
function TTagSettingsDialog.AllEstimateBool(AKind: TRecorderTagEstimateKind;
  out AValue: Boolean): Boolean;
var
  I: Integer;
  lValue: Boolean;
begin
  AValue := TagAt(0).EstimateSettings.EnabledKinds[AKind];
  for I := 1 to fTags.Count - 1 do
  begin
    lValue := TagAt(I).EstimateSettings.EnabledKinds[AKind];
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

{ Совпадение вида математической оценки по умолчанию }
function TTagSettingsDialog.AllEstimateDefault(
  out AValue: TRecorderTagEstimateKind): Boolean;
var
  I: Integer;
begin
  AValue := TagAt(0).EstimateSettings.DefaultKind;
  for I := 1 to fTags.Count - 1 do
    if AValue <> TagAt(I).EstimateSettings.DefaultKind then
      Exit(False);
  Result := True;
end;

{ Проверка совпадения глобального флага оценок (сглаживание или экспорт в SCADA) }
function TTagSettingsDialog.AllEstimateFlag(AGetter: Integer;
  out AValue: Boolean): Boolean;
var
  I: Integer;
  lValue: Boolean;
begin
  if AGetter = 0 then
    AValue := TagAt(0).EstimateSettings.SmoothingEnabled
  else
    AValue := TagAt(0).EstimateSettings.ScadaEnabled;

  for I := 1 to fTags.Count - 1 do
  begin
    if AGetter = 0 then
      lValue := TagAt(I).EstimateSettings.SmoothingEnabled
    else
      lValue := TagAt(I).EstimateSettings.ScadaEnabled;
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

{ Совпадение коэффициента фильтра сглаживания }
function TTagSettingsDialog.AllEstimateFloat(AKind: Integer;
  out AValue: Double): Boolean;
var
  I: Integer;
  lValue: Double;
begin
  if AKind = 0 then
    AValue := TagAt(0).EstimateSettings.SmoothingK
  else
    Exit(False);

  for I := 1 to fTags.Count - 1 do
  begin
    lValue := TagAt(I).EstimateSettings.SmoothingK;
    if Abs(AValue - lValue) > 1E-9 then
      Exit(False);
  end;
  Result := True;
end;

{ Совпадение порции данных вычисления оценок }
function TTagSettingsDialog.AllEstimateInt(out AValue: Integer): Boolean;
var
  I: Integer;
begin
  AValue := TagAt(0).EstimateSettings.PortionLength;
  for I := 1 to fTags.Count - 1 do
    if AValue <> TagAt(I).EstimateSettings.PortionLength then
      Exit(False);
  Result := True;
end;

{ Совпадение настроек флагов конкретной уставки (активна или передается в выходной канал) }
function TTagSettingsDialog.AllSetpointBool(AKind: TRecorderTagSetpointKind;
  AGetter: Integer; out AValue: Boolean): Boolean;
var
  I: Integer;
  lSetpoint: TRecorderTagSetpoint;
  lValue: Boolean;
begin
  lSetpoint := TagAt(0).Setpoints[AKind];
  if AGetter = 0 then
    AValue := lSetpoint.Enabled
  else
    AValue := lSetpoint.OutputEnabled;

  for I := 1 to fTags.Count - 1 do
  begin
    lSetpoint := TagAt(I).Setpoints[AKind];
    if AGetter = 0 then
      lValue := lSetpoint.Enabled
    else
      lValue := lSetpoint.OutputEnabled;
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

{ Совпадение числовых значений порогов и гистерезиса }
function TTagSettingsDialog.AllSetpointFloat(AKind: TRecorderTagSetpointKind;
  AGetter: Integer; out AValue: Double): Boolean;
var
  I: Integer;
  lSetpoint: TRecorderTagSetpoint;
  lValue: Double;
begin
  lSetpoint := TagAt(0).Setpoints[AKind];
  if AGetter = 0 then
    AValue := lSetpoint.Threshold
  else
    AValue := lSetpoint.HysteresisPercent;

  for I := 1 to fTags.Count - 1 do
  begin
    lSetpoint := TagAt(I).Setpoints[AKind];
    if AGetter = 0 then
      lValue := lSetpoint.Threshold
    else
      lValue := lSetpoint.HysteresisPercent;
    if Abs(AValue - lValue) > 1E-9 then
      Exit(False);
  end;
  Result := True;
end;

{ Совпадение общих настроек модуля уставок (гистерезис, звук, канал состояния) }
function TTagSettingsDialog.AllSetpointGlobalBool(AGetter: Integer;
  out AValue: Boolean): Boolean;
var
  I: Integer;
  lValue: Boolean;
begin
  case AGetter of
    0: AValue := TagAt(0).SetpointHysteresisEnabled;
    1: AValue := TagAt(0).SetpointSoundUntilEnd;
    2: AValue := TagAt(0).SetpointStatusChannelEnabled;
  else
    Exit(False);
  end;

  for I := 1 to fTags.Count - 1 do
  begin
    case AGetter of
      0: lValue := TagAt(I).SetpointHysteresisEnabled;
      1: lValue := TagAt(I).SetpointSoundUntilEnd;
      2: lValue := TagAt(I).SetpointStatusChannelEnabled;
    else
      lValue := False;
    end;
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

{ Редактирование частоты опроса доступно только для аппаратных тегов }
function TTagSettingsDialog.FrequencyCanBeEdited: Boolean;
var
  lValue: string;
begin
  Result := AllString(4, lValue);
end;

function TTagSettingsDialog.HasDetachedSource: Boolean;
var
  I: Integer;
  lSourceId: string;
begin
  Result := False;
  for I := 0 to fTags.Count - 1 do
  begin
    lSourceId := Trim(TagAt(I).SourceId);
    if SourceNeedsActiveCheck(lSourceId) and
      not fTagRegistry.IsSourceActive(lSourceId) then
      Exit(True);
  end;
end;

function TTagSettingsDialog.SourceNeedsActiveCheck(const ASourceId: string): Boolean;
var
  lSourceId: string;
begin
  lSourceId := Trim(ASourceId);
  Result := (lSourceId <> '') and (not SameText(lSourceId, 'manual')) and
    (not SameText(lSourceId, 'debug.diagnostics'));
end;

function TTagSettingsDialog.IsSignalAlreadyLinked(const ASourceId: string;
  ASignal: TMeraSignalInfo; AExceptTag: TRecorderTag): Boolean;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := False;
  if ASignal = nil then
    Exit;

  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if lTag = AExceptTag then
      Continue;
    if SameText(lTag.SourceId, ASourceId) and SameText(lTag.Address, ASignal.Address) then
      Exit(True);
  end;
end;

function TTagSettingsDialog.SelectActiveMeraSignal(out ASourceId: string;
  out ASignal: TMeraSignalInfo): Boolean;
const
  CMeraSourcePrefix = 'Mera file: ';
var
  I: Integer;
  lDialog: TForm;
  lList: TListBox;
  lPanel: TPanel;
  lButton: TButton;
  lSignals: TList;
  lSourceIds: TStringList;
  lSourceId: string;
  lFileName: string;
  lSignal: TMeraSignalInfo;
begin
  Result := False;
  ASourceId := '';
  ASignal := nil;

  lSignals := TList.Create;
  lSourceIds := TStringList.Create;
  lDialog := TForm.CreateNew(Self, 1);
  try
    lDialog.Caption := 'Выбор канала источника данных';
    lDialog.Position := poOwnerFormCenter;
    lDialog.BorderStyle := bsDialog;
    lDialog.ClientWidth := 560;
    lDialog.ClientHeight := 400;

    lList := TListBox.Create(lDialog);
    lList.Parent := lDialog;
    lList.Align := alClient;

    lPanel := TPanel.Create(lDialog);
    lPanel.Parent := lDialog;
    lPanel.Align := alBottom;
    lPanel.Height := 42;
    lPanel.BevelOuter := bvNone;

    lButton := TButton.Create(lDialog);
    lButton.Parent := lPanel;
    lButton.SetBounds(390, 8, 74, 26);
    lButton.Caption := 'OK';
    lButton.Default := True;
    lButton.ModalResult := mrOk;

    lButton := TButton.Create(lDialog);
    lButton.Parent := lPanel;
    lButton.SetBounds(470, 8, 74, 26);
    lButton.Caption := 'Отмена';
    lButton.Cancel := True;
    lButton.ModalResult := mrCancel;

    for I := 0 to fTagRegistry.ActiveSourceCount - 1 do
    begin
      lSourceId := fTagRegistry.ActiveSourceIds[I];
      if Pos(CMeraSourcePrefix, lSourceId) <> 1 then
        Continue;

      lFileName := Trim(Copy(lSourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
      if not FileExists(lFileName) then
        Continue;

      LoadMeraSignalsFromFile(lFileName, lSignals);
      while lSignals.Count > 0 do
      begin
        lSignal := TMeraSignalInfo(lSignals[0]);
        lSignals.Delete(0);
        if IsSignalAlreadyLinked(lSourceId, lSignal, TagAt(0)) then
        begin
          lSignal.Free;
          Continue;
        end;
        lSourceIds.Add(lSourceId);
        lList.Items.AddObject(Format('%s  [%s]  %s',
          [LclText(lSignal.Name), LclText(lSignal.Address),
          ExtractFileName(lFileName)]), lSignal);
      end;
    end;

    if lList.Items.Count = 0 then
    begin
      MessageDlg('Выбор канала', 'Нет доступных каналов активного источника данных.',
        mtInformation, [mbOK], 0);
      Exit;
    end;

    lList.ItemIndex := 0;
    if lDialog.ShowModal = mrOk then
      Result := lList.ItemIndex >= 0;

    if Result then
    begin
      ASourceId := lSourceIds[lList.ItemIndex];
      ASignal := TMeraSignalInfo(lList.Items.Objects[lList.ItemIndex]);
      lList.Items.Objects[lList.ItemIndex] := nil;
    end;
  finally
    for I := 0 to lDialog.ComponentCount - 1 do
      if lDialog.Components[I] is TListBox then
      begin
        lList := TListBox(lDialog.Components[I]);
        while lList.Items.Count > 0 do
        begin
          TObject(lList.Items.Objects[0]).Free;
          lList.Items.Delete(0);
        end;
        Break;
      end;
    lDialog.Free;
    ClearMeraSignals(lSignals);
    lSignals.Free;
    lSourceIds.Free;
  end;
end;

procedure TTagSettingsDialog.ApplyMeraSignalToCurrentTag(const ASourceId: string;
  ASignal: TMeraSignalInfo);
var
  lExisting: TRecorderTag;
  lTag: TRecorderTag;
  lTagName: string;
begin
  if (fTags.Count <> 1) or (ASignal = nil) then
    Exit;

  lTag := TagAt(0);
  lTagName := MeraSignalToRecorderTagName(ASignal);
  lExisting := fTagRegistry.FindByName(lTagName);
  if (lExisting <> nil) and (lExisting <> lTag) then
    raise ERecorderTagError.Create('Tag name already exists: ' + lTagName);

  lTag.Name := lTagName;
  lTag.Address := ASignal.Address;
  lTag.UnitName := ASignal.UnitsName;
  lTag.SourceId := ASourceId;
  lTag.ModuleType := ASignal.ModuleName;
  lTag.PollFrequencyHz := ASignal.FrequencyHz;
  lTag.SensorCalibrationName := ASignal.SensorCalibrationName;
  lTag.AmplifierCalibrationName := ASignal.AmplifierCalibrationName;
  lTag.Description := Format('%s; type=%s; freq=%s; file=%s',
    [ASignal.Name, ASignal.DataTypeName, FormatFloat('0.######',
    ASignal.FrequencyHz), ExtractFileName(ASignal.FileName)]);
end;

procedure TTagSettingsDialog.AddressButtonClick(Sender: TObject);
var
  lSignal: TMeraSignalInfo;
  lSourceId: string;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Выбор канала',
      'Адрес можно связывать с источником только для одного выбранного тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if not SelectActiveMeraSignal(lSourceId, lSignal) then
    Exit;
  try
    ApplyMeraSignalToCurrentTag(lSourceId, lSignal);
    LoadFromTags;
  finally
    lSignal.Free;
  end;
end;

{ Загрузка текущих параметров тегов в элементы интерфейса }
procedure TTagSettingsDialog.LoadFromTags;
var
  lText: string;
  lFloat: Double;
  lBool: Integer;
  lChecked: Boolean;
  lEstimateKind: TRecorderTagEstimateKind;
  lIndex: Integer;
  lInt: Integer;
  lSetpointKind: TRecorderTagSetpointKind;
  lJ: Integer;
  lSourceActive: Boolean;
  lTagTemp: TRecorderTag;
begin
  if fTags.Count = 1 then
  begin
    Caption := 'Настройка канала ' + TagAt(0).Name;
    fNameEdit.Text := TagAt(0).Name;
    fNameEdit.Enabled := True;
    fAddressButton.Enabled := fTagRegistry.ActiveSourceCount > 0;
  end
  else
  begin
    Caption := Format('Настройка каналов (%d)', [fTags.Count]);
    fNameEdit.Text := '';
    fNameEdit.Enabled := False;
    fAddressButton.Enabled := False;
  end;

  fDetachedSourceLabel.Visible := HasDetachedSource;

  if AllString(1, lText) then
    fUnitCombo.Text := lText
  else
    fUnitCombo.Text := '';
  if AllString(2, lText) then
    fModuleEdit.Text := lText
  else
    fModuleEdit.Text := '';

  lSourceActive := True;
  for lJ := 0 to fTags.Count - 1 do
  begin
    lTagTemp := TagAt(lJ);
    if SourceNeedsActiveCheck(lTagTemp.SourceId) then
    begin
      if not fTagRegistry.IsSourceActive(lTagTemp.SourceId) then
      begin
        lSourceActive := False;
        Break;
      end;
    end;
  end;
  fDetachedSourceLabel.Visible := not lSourceActive;

  if AllString(3, lText) then
    fDescriptionEdit.Text := lText
  else
    fDescriptionEdit.Text := '';

  if AllFloat(0, lFloat) and (lFloat > 0) then
    fFrequencyCombo.Text := FormatFloat('0.######', lFloat)
  else
    fFrequencyCombo.Text := '';
  fFrequencyCombo.Enabled := FrequencyCanBeEdited;

  if AllFloat(1, lFloat) then
    fMinEdit.Text := FormatFloat('0.######', lFloat)
  else
    fMinEdit.Text := '';
  if AllFloat(2, lFloat) then
    fMaxEdit.Text := FormatFloat('0.######', lFloat)
  else
    fMaxEdit.Text := '';

  lBool := AllBool(0);
  fAutoUnitCheck.AllowGrayed := fTags.Count > 1;
  if lBool < 0 then
    fAutoUnitCheck.State := cbGrayed
  else
    fAutoUnitCheck.Checked := lBool > 0;

  lBool := AllBool(1);
  fAutoRangeCheck.AllowGrayed := fTags.Count > 1;
  if lBool < 0 then
    fAutoRangeCheck.State := cbGrayed
  else
    fAutoRangeCheck.Checked := lBool > 0;

  UpdateChannelCurveText;

  for lEstimateKind := Low(TRecorderTagEstimateKind) to tekPeakToPeakByRmsDeviation do
  begin
    fEstimateChecks[lEstimateKind].AllowGrayed := fTags.Count > 1;
    if AllEstimateBool(lEstimateKind, lChecked) then
      fEstimateChecks[lEstimateKind].Checked := lChecked
    else
      fEstimateChecks[lEstimateKind].State := cbGrayed;
  end;

  if AllEstimateDefault(lEstimateKind) then
  begin
    lIndex := Ord(lEstimateKind);
    if (lIndex >= 0) and (lIndex < fDefaultEstimateCombo.Items.Count) then
      fDefaultEstimateCombo.ItemIndex := lIndex
    else
      fDefaultEstimateCombo.ItemIndex := -1;
  end
  else
    fDefaultEstimateCombo.ItemIndex := -1;

  if AllEstimateInt(lInt) then
    fPortionLengthEdit.Text := IntToStr(lInt)
  else
    fPortionLengthEdit.Text := '';

  fSmoothingCheck.AllowGrayed := fTags.Count > 1;
  if AllEstimateFlag(0, lChecked) then
    fSmoothingCheck.Checked := lChecked
  else
    fSmoothingCheck.State := cbGrayed;
  if AllEstimateFloat(0, lFloat) then
    fSmoothingKEdit.Text := FormatFloat('0.######', lFloat)
  else
    fSmoothingKEdit.Text := '';

  fScadaCheck.AllowGrayed := fTags.Count > 1;
  if AllEstimateFlag(1, lChecked) then
    fScadaCheck.Checked := lChecked
  else
    fScadaCheck.State := cbGrayed;

  for lSetpointKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
  begin
    fSetpointEnabledChecks[lSetpointKind].AllowGrayed := fTags.Count > 1;
    if AllSetpointBool(lSetpointKind, 0, lChecked) then
      fSetpointEnabledChecks[lSetpointKind].Checked := lChecked
    else
      fSetpointEnabledChecks[lSetpointKind].State := cbGrayed;

    if AllSetpointFloat(lSetpointKind, 0, lFloat) then
      fSetpointThresholdEdits[lSetpointKind].Text := FormatFloat('0.######', lFloat)
    else
      fSetpointThresholdEdits[lSetpointKind].Text := '';

    fSetpointColorPanels[lSetpointKind].Color :=
      TColor(TagAt(0).Setpoints[lSetpointKind].Color);
  end;

  fSetpointHysteresisCheck.AllowGrayed := fTags.Count > 1;
  if AllSetpointGlobalBool(0, lChecked) then
    fSetpointHysteresisCheck.Checked := lChecked
  else
    fSetpointHysteresisCheck.State := cbGrayed;

  fSetpointSoundCheck.AllowGrayed := fTags.Count > 1;
  if AllSetpointGlobalBool(1, lChecked) then
    fSetpointSoundCheck.Checked := lChecked
  else
    fSetpointSoundCheck.State := cbGrayed;

  fSetpointStatusChannelCheck.AllowGrayed := fTags.Count > 1;
  if AllSetpointGlobalBool(2, lChecked) then
    fSetpointStatusChannelCheck.Checked := lChecked
  else
    fSetpointStatusChannelCheck.State := cbGrayed;
end;

{ Безопасное чтение вещественных чисел с заменой точек/запятых }
function TTagSettingsDialog.ReadFloat(const AText: string;
  out AValue: Double): Boolean;
var
  lText: string;
begin
  lText := StringReplace(Trim(AText), '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  Result := TryStrToFloat(lText, AValue);
end;

{ Сохранение изменений из элементов UI обратно в отредактированные теги }
procedure TTagSettingsDialog.StoreToTags;
var
  I: Integer;
  lTag: TRecorderTag;
  lExisting: TRecorderTag;
  lEstimateKind: TRecorderTagEstimateKind;
  lEstimateSettings: TRecorderTagEstimateSettings;
  lFloat: Double;
  lInt: Integer;
  lSetpoint: TRecorderTagSetpoint;
  lSetpointKind: TRecorderTagSetpointKind;
begin
  if fNameEdit.Enabled and (Trim(fNameEdit.Text) <> '') then
  begin
    lExisting := fTagRegistry.FindByName(Trim(fNameEdit.Text));
    if (lExisting <> nil) and (lExisting <> TagAt(0)) then
      raise ERecorderTagError.Create('Tag name already exists: ' + Trim(fNameEdit.Text));
    TagAt(0).Name := Trim(fNameEdit.Text);
  end;

  for I := 0 to fTags.Count - 1 do
  begin
    lTag := TagAt(I);
    if fSelectedMeraFileName <> '' then
    begin
      lTag.Address := Trim(fModuleEdit.Text);
      lTag.SourceId := 'Mera file: ' + fSelectedMeraFileName;
    end;
    if Trim(fUnitCombo.Text) <> '' then
      lTag.UnitName := Trim(fUnitCombo.Text);
    if Trim(fDescriptionEdit.Text) <> '' then
      lTag.Description := Trim(fDescriptionEdit.Text);
    if fFrequencyCombo.Enabled and (Trim(fFrequencyCombo.Text) <> '') then
    begin
      if not ReadFloat(fFrequencyCombo.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid poll frequency');
      lTag.PollFrequencyHz := lFloat;
    end;
    if Trim(fMinEdit.Text) <> '' then
    begin
      if not ReadFloat(fMinEdit.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid lower range value');
      lTag.RangeMin := lFloat;
    end;
    if Trim(fMaxEdit.Text) <> '' then
    begin
      if not ReadFloat(fMaxEdit.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid upper range value');
      lTag.RangeMax := lFloat;
    end;
    if fAutoUnitCheck.State <> cbGrayed then
      lTag.AutoUnit := fAutoUnitCheck.Checked;
    if fAutoRangeCheck.State <> cbGrayed then
      lTag.AutoRange := fAutoRangeCheck.Checked;

    lEstimateSettings := lTag.EstimateSettings;
    for lEstimateKind := Low(TRecorderTagEstimateKind) to tekPeakToPeakByRmsDeviation do
      if fEstimateChecks[lEstimateKind].State <> cbGrayed then
        lEstimateSettings.EnabledKinds[lEstimateKind] :=
          fEstimateChecks[lEstimateKind].Checked;
    if fDefaultEstimateCombo.ItemIndex >= 0 then
      lEstimateSettings.DefaultKind := TRecorderTagEstimateKind(PtrInt(
        fDefaultEstimateCombo.Items.Objects[fDefaultEstimateCombo.ItemIndex]));
    if Trim(fPortionLengthEdit.Text) <> '' then
    begin
      if not TryStrToInt(Trim(fPortionLengthEdit.Text), lInt) or (lInt <= 0) then
        raise ERecorderTagError.Create('Invalid estimate portion length');
      lEstimateSettings.PortionLength := lInt;
    end;
    if fSmoothingCheck.State <> cbGrayed then
      lEstimateSettings.SmoothingEnabled := fSmoothingCheck.Checked;
    if Trim(fSmoothingKEdit.Text) <> '' then
    begin
      if not ReadFloat(fSmoothingKEdit.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid smoothing coefficient');
      lEstimateSettings.SmoothingK := lFloat;
    end;
    if fScadaCheck.State <> cbGrayed then
      lEstimateSettings.ScadaEnabled := fScadaCheck.Checked;
    lTag.EstimateSettings := lEstimateSettings;

    for lSetpointKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
    begin
      lSetpoint := lTag.Setpoints[lSetpointKind];
      if fSetpointEnabledChecks[lSetpointKind].State <> cbGrayed then
        lSetpoint.Enabled := fSetpointEnabledChecks[lSetpointKind].Checked;
      if Trim(fSetpointThresholdEdits[lSetpointKind].Text) <> '' then
      begin
        if not ReadFloat(fSetpointThresholdEdits[lSetpointKind].Text, lFloat) then
          raise ERecorderTagError.Create('Invalid setpoint threshold');
        lSetpoint.Threshold := lFloat;
      end;
      lTag.Setpoints[lSetpointKind] := lSetpoint;
    end;
    if fSetpointHysteresisCheck.State <> cbGrayed then
      lTag.SetpointHysteresisEnabled := fSetpointHysteresisCheck.Checked;
    if fSetpointSoundCheck.State <> cbGrayed then
      lTag.SetpointSoundUntilEnd := fSetpointSoundCheck.Checked;
    if fSetpointStatusChannelCheck.State <> cbGrayed then
      lTag.SetpointStatusChannelEnabled := fSetpointStatusChannelCheck.Checked;
  end;
end;

procedure TTagSettingsDialog.ApplyButtonClick(Sender: TObject);
begin
  StoreToTags;
  LoadFromTags;
end;

procedure TTagSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToTags;
  ModalResult := mrOk;
end;


procedure TTagSettingsDialog.SelectCalibrationButtonClick(Sender: TObject);
var
  lSelected: TRecorderCalibration;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Канальная ГХ',
      'Выбор ГХ из списка доступен только для одного выбранного тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  lSelected := nil;
  if ShowRecorderCalibrationListDialog(Self, fTagRegistry.Calibrations, lSelected) and
    (lSelected <> nil) then
  begin
    if TagAt(0).CalibrationNames.Count = 0 then
      TagAt(0).CalibrationNames.Add(lSelected.Name)
    else
      TagAt(0).CalibrationNames[TagAt(0).CalibrationNames.Count - 1] :=
        lSelected.Name;
    UpdateChannelCurveText;
  end;
end;

procedure TTagSettingsDialog.AddCalibrationButtonClick(Sender: TObject);
var
  I: Integer;
  lKind: TRecorderCalibrationKind;
  lCalibration: TRecorderCalibration;
begin
  if not ShowRecorderCalibrationAddDialog(Self, lKind) then
    Exit;

  lCalibration := TRecorderCalibration.Create(lKind);
  try
    lCalibration.Name := 'ГХ ' + IntToStr(fTagRegistry.Calibrations.Count + 1);
    if lKind = rckPiecewiseLinear then
    begin
      lCalibration.AddPoint(0, 0);
      lCalibration.AddPoint(1, 1);
    end;

    if not ShowRecorderCalibrationPropertiesDialog(Self, lCalibration) then
      Exit;

  fTagRegistry.Calibrations.Add(lCalibration);
  for I := 0 to fTags.Count - 1 do
    if TagAt(I).CalibrationNames.Count = 0 then
      TagAt(I).CalibrationNames.Add(lCalibration.Name)
    else
      TagAt(I).CalibrationNames[TagAt(I).CalibrationNames.Count - 1] :=
        lCalibration.Name;
    lCalibration := nil;
    UpdateChannelCurveText;
  finally
    lCalibration.Free;
  end;
end;

procedure TTagSettingsDialog.DeleteCalibrationButtonClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to fTags.Count - 1 do
    TagAt(I).CalibrationNames.Clear;
  UpdateChannelCurveText;
end;

procedure TTagSettingsDialog.EditCalibrationButtonClick(Sender: TObject);
var
  lCalibration: TRecorderCalibration;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Канальная ГХ',
      'ГХ можно редактировать только для одного выбранного тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if TagAt(0).CalibrationNames.Count = 0 then
  begin
    MessageDlg('Канальная ГХ',
      'У выбранного тега нет назначенной ГХ.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  lCalibration := fTagRegistry.FindCalibrationByName(
    TagAt(0).CalibrationNames[TagAt(0).CalibrationNames.Count - 1]);
  if lCalibration = nil then
  begin
    MessageDlg('Канальная ГХ',
      'Назначенная ГХ не найдена в списке характеристик.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if ShowRecorderCalibrationPropertiesDialog(Self, lCalibration) then
    UpdateChannelCurveText;
end;

end.
