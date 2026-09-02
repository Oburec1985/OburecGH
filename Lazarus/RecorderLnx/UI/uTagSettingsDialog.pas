unit uTagSettingsDialog;

{
  Модуль uTagSettingsDialog

  Назначение:
    Диалог редактирования свойств одного или нескольких тегов/каналов RecorderLnx.

  Режим multi-select:
    - Если выбрано несколько каналов, общие поля показывают «смешанное» состояние.
    - Часть действий (градуировки, адрес входа) доступна только для одного тега.
    - При сохранении изменения применяются ко всем выбранным тегам.

  Кодировка (2026-06):
    Файл в UTF-8, {$codepage UTF8}. Строки для LCL — обычные string-литералы.
    См. Docs/source-encoding.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls,
  Buttons, Dialogs, ImgList, uRecorderTags, uMeraFile, uComponentServices,
  uRecorderMic140DataSource, uRecorderMic140DeviceConfig, uRecorderMic140Calibration, uRecorderMic140LegacyTiming, uRecorderMic140Utils, uRecorderMic140StreamTypes, uRecorderCalibrationAddDialog, uRecorderCalibrationPropertiesDialog,
  uRecorderCalibrationListDialog, uRecorderSdbStore, uRecorderSdbSelectDialog,
  uRecorderStrainCalibrationDialog,
  uRecorderMic140SettingsDialog, uRecorderMic185DataSource,
  uMic185MebiusTypes,
  uRecorderMic185Calibration,
  uRecorderMc201Calibration, uRecorderConfiguredDataSources,
  uRecorderCommandImages, uRecorderMc032SettingsDialog,
  uRecorderDeviceInterfaces, uRecorderHardwareLiveDevices,
  uRecorderFrequencyGrids;

type
  TTagHardwareSourceSetupEvent = procedure(Sender: TObject; ATag: TRecorderTag) of object;
  TTagZeroBalanceEvent = procedure(Sender: TObject; ARegistry: TRecorderTagRegistry;
    ATags: TList) of object;
  { TTagSettingsDialog }
  { Диалоговое окно настройки свойств тега (канала)   }
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
    fHardwareSourceSetupBtn: TSpeedButton;
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
    fHardwareCurveDownloadBtn: TSpeedButton;
    gbChannelCurve: TGroupBox;
    fChannelCurveCheck: TCheckBox;
    fChannelCurveEdit: TEdit;
    fChannelCurveSelectBtn: TSpeedButton;
    fChannelCurveAddBtn: TSpeedButton;
    fChannelCurveDeleteBtn: TSpeedButton;
    fChannelCurveEditBtn: TSpeedButton;
    pnTagDeviceActions: TPanel;
    fZeroBalanceBtn: TSpeedButton;
    fHardwareDeviceSetupBtn: TSpeedButton;
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
    fSetpointRangeControlCheck: TCheckBox;
    pnBottom: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    fApplyButton: TButton;
    ilTagDialogButtons: TImageList;
    procedure ZeroBalanceButtonClick(Sender: TObject);
    procedure HardwareDeviceSetupButtonClick(Sender: TObject);
  private
    fImages: TCustomImageList;                           // Список иконок для диалога (ilTagDialogButtons)
    fCommandImages: TCustomImageList;                    // Список иконок устройства (ilCommandButtons)
    fTagRegistry: TRecorderTagRegistry;                  // Реестр тегов
    fSelectedMeraFileName: string;                       // Путь выбранного Mera-файла
    fTags: TList;                                        // Список редактируемых тегов
    fDataUpdateMs: Cardinal;                             // Интервал обновления данных (TRecorderTag)
    fEstimateChecks: array[TRecorderTagEstimateKind] of TCheckBox; // Флаги вычисления различных оценок
    fSetpointColorPanels: array[TRecorderTagSetpointKind] of TPanel; // Цвета отображения для каждой уставки
    fSetpointEnabledChecks: array[TRecorderTagSetpointKind] of TCheckBox; // Флаги активности уставок
    fSetpointThresholdEdits: array[TRecorderTagSetpointKind] of TEdit; // Значения порогов уставок
    fOnHardwareSourceSetup: TTagHardwareSourceSetupEvent;
    fOnZeroBalance: TTagZeroBalanceEvent;
    
    // Внутренние методы обработчиков UI
    procedure ApplyButtonClick(Sender: TObject);
    procedure AddressButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure SelectCalibrationButtonClick(Sender: TObject);
    procedure ChannelCurveNotebookClick(Sender: TObject);
    procedure AddCalibrationButtonClick(Sender: TObject);
    procedure DeleteCalibrationButtonClick(Sender: TObject);
    procedure EditCalibrationButtonClick(Sender: TObject);
    procedure EditCalibrationAt(APipelineIndex: Integer);
    procedure ExportCalibrationButtonClick(Sender: TObject);
    procedure SelectHardwareCalibrationButtonClick(Sender: TObject);
    procedure EditHardwareCalibrationButtonClick(Sender: TObject);
    procedure DownloadHardwareCalibrationFromDeviceClick(Sender: TObject);
    procedure AssignSpeedButtonImage(AButton: TSpeedButton; AImages: TCustomImageList;
      AImageIndex: Integer; const AHint: string = ''; ABtnSize: Integer = 0);
    procedure AssignActionSpeedButton(AButton: TSpeedButton; AImages: TCustomImageList;
      AImageIndex: Integer; const ACaption, AHint: string);
    procedure LayoutTagDeviceActionButtons;
    procedure AssignDownloadFlashIcon(AButton: TSpeedButton);
    procedure UpdateChannelCurveText;
    procedure UpdateHardwareCurveText;
    procedure UpdateHardwareCurveButtons;
    function EnsureMic185HardwareCalibrationAssigned(ATag: TRecorderTag;
      AEnableOnTag: Boolean): Boolean;
    function Mic185SourceUnitName(ATag: TRecorderTag;
      const ASettings: TMic185ChannelProgramSettings): string;
    function TryGetStrainDeviceExcitation(ATag: TRecorderTag;
      out AExcitation: string): Boolean;
    procedure HardwareCurveCheckClick(Sender: TObject);
    procedure AutoUnitCheckClick(Sender: TObject);
    procedure EstimateCheckClick(Sender: TObject);
    procedure DefaultEstimateComboChange(Sender: TObject);
    procedure DisableEmptyChannelCalibrations;
    procedure HardwareSourceSetupButtonClick(Sender: TObject);
    procedure UpdateHardwareSourceSetupButton;
    procedure UpdateTagDeviceActionButtons;
    procedure UpdateVirtualChannelInfo;
    function TryGetChannelCalibrationOutputUnit(ATag: TRecorderTag;
      out AUnitName: string): Boolean;
    procedure ApplyAutoUnitFromChannelCalibration;
    function CanConfigureHardwareSource: Boolean;
    function CanZeroBalance: Boolean;
    
    // Обмен данными между UI и тегами
    procedure LoadFromTags;
    procedure StoreToTags;
    procedure ApplyMeraSignalToCurrentTag(const ASourceId: string;
      ASignal: TMeraSignalInfo);
    function SelectActiveMeraSignal(out ASourceId: string;
      out ASignal: TMeraSignalInfo): Boolean;
    
    // Функции проверки согласованности значений при множественном выборе
    function AllBool(AGetter: Integer): Integer;
    function AllChannelCalibrationEnabled: Integer;
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
    function AllSourceId(out AValue: string): Boolean;
    
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
      ATags: TList; AImages: TCustomImageList = nil; ADataUpdateMs: Cardinal = 200;
      AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent = nil;
      AOnZeroBalance: TTagZeroBalanceEvent = nil;
      ACommandImages: TCustomImageList = nil); reintroduce;
    destructor Destroy; override;
  end;

function ShowTagSettingsDialog(AOwner: TComponent; ATagRegistry: TRecorderTagRegistry; ATags: TList; AImages: TCustomImageList = nil; ADataUpdateMs: Cardinal = 200; AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent = nil; AOnZeroBalance: TTagZeroBalanceEvent = nil; ACommandImages: TCustomImageList = nil): Boolean;

implementation

function RecorderMc201SlotFromAddress(const AAddress: string;
  out ASlot: Integer): Boolean;
var
  lParts: TStringList;
begin
  Result := False;
  ASlot := 0;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := '-';
    lParts.DelimitedText := Trim(AAddress);
    if lParts.Count < 2 then Exit;
    Result := TryStrToInt(lParts[lParts.Count - 2], ASlot) and (ASlot > 0);
  finally
    lParts.Free;
  end;
end;

procedure RecorderMc201ApplySlotFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double);
var
  I, lSlot, lTagSlot: Integer;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or
    not RecorderMc201SlotFromAddress(AAddress, lSlot) then Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) and
      RecorderMc201SlotFromAddress(lTag.Address, lTagSlot) and
      (lTagSlot = lSlot) then
      lTag.PollFrequencyHz := AFrequencyHz;
  end;
end;

{$R *.lfm}

const
  CTagDialogIconAddress = 0;
  CTagDialogIconEdit = 1;
  CTagDialogIconProperty = 2;
  CTagDialogIconHardwareCurve = 3;
  CTagDialogIconAdd = 4;
  CTagDialogIconRemove = 5;
  CTagDialogIconChannelCurve = 6;
  CTagDeviceActionBtnSize = 32;
  CTagDeviceActionBtnGap = 4;
  CMeraSourcePrefix = 'Mera file: ';
  CRamOutIconPaths: array[0..2] of string = (
    'D:\works\windev-v3.9\rc_guisrv\res\v3\ico\ram_out.ico',
    'D:\works\windev-v3.9\rc_guisrv\res\ram_out.ico',
    'D:\works\windev-v3.9\images\from_rcguisrv\res\harf_t.ico'
  );

function ShowSelectSignalDialog(AOwner: TComponent; AList: TStrings; var ASelectedIndex: Integer): Boolean;
var
  lForm: TForm;
  lListBox: TListBox;
  lOkBtn, lCancelBtn: TButton;
begin
  lForm := TForm.CreateNew(AOwner, 1);
  try
    lForm.Caption := 'Выбор сигнала из списка';
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
  AImages: TCustomImageList; ADataUpdateMs: Cardinal;
  AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent;
  AOnZeroBalance: TTagZeroBalanceEvent;
  ACommandImages: TCustomImageList): Boolean;
var
  lDialog: TTagSettingsDialog;
begin
  lDialog := TTagSettingsDialog.CreateDialog(AOwner, ATagRegistry, ATags, AImages,
    ADataUpdateMs, AOnHardwareSourceSetup, AOnZeroBalance, ACommandImages);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TTagSettingsDialog.CreateDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; ATags: TList; AImages: TCustomImageList;
  ADataUpdateMs: Cardinal; AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent;
  AOnZeroBalance: TTagZeroBalanceEvent; ACommandImages: TCustomImageList);
var
  lEstimateKind: TRecorderTagEstimateKind;
begin
  inherited Create(AOwner);
  if ATagRegistry = nil then
    raise ERecorderTagError.Create('Tag registry cannot be nil');
  if (ATags = nil) or (ATags.Count = 0) then
    raise ERecorderTagError.Create('No tags selected');

  fTagRegistry := ATagRegistry;
  if AImages <> nil then
  begin
    ilTagDialogButtons.Assign(AImages);
    fImages := ilTagDialogButtons;
  end
  else
    fImages := ilTagDialogButtons;
  fCommandImages := ACommandImages;
  fOnHardwareSourceSetup := AOnHardwareSourceSetup;
  fOnZeroBalance := AOnZeroBalance;
  fTags := TList.Create;
  fTags.Assign(ATags);
  fDataUpdateMs := ADataUpdateMs;

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
  for lEstimateKind := Low(TRecorderTagEstimateKind) to
    tekPeakToPeakByRmsDeviation do
    if fEstimateChecks[lEstimateKind] <> nil then
      fEstimateChecks[lEstimateKind].OnClick := @EstimateCheckClick;

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
  fHardwareSourceSetupBtn.OnClick := @HardwareSourceSetupButtonClick;
  fHardwareSourceSetupBtn.Visible := False;
  fChannelCurveSelectBtn.OnClick := @ChannelCurveNotebookClick;
  fChannelCurveAddBtn.OnClick := @AddCalibrationButtonClick;
  fChannelCurveDeleteBtn.OnClick := @DeleteCalibrationButtonClick;
  fChannelCurveEditBtn.OnClick := @ExportCalibrationButtonClick;
  fHardwareCurveSelectBtn.OnClick := @SelectHardwareCalibrationButtonClick;
  fHardwareCurveSetupBtn.OnClick := @EditHardwareCalibrationButtonClick;
  fHardwareCurveDownloadBtn.OnClick := @DownloadHardwareCalibrationFromDeviceClick;
  fHardwareCurveCheck.OnClick := @HardwareCurveCheckClick;
  fAutoUnitCheck.OnClick := @AutoUnitCheckClick;
  btnOk.OnClick := @OkButtonClick;
  fApplyButton.OnClick := @ApplyButtonClick;

  AssignSpeedButtonImage(fAddressButton, fImages, CTagDialogIconAddress);
  AssignSpeedButtonImage(fDescriptionEditBtn, fImages, CTagDialogIconEdit);
  AssignSpeedButtonImage(fHardwareCurveSelectBtn, fImages, CTagDialogIconProperty);
  AssignSpeedButtonImage(fHardwareCurveSetupBtn, fImages, CTagDialogIconHardwareCurve);
  AssignSpeedButtonImage(fHardwareCurveDownloadBtn, fCommandImages,
    CTagDialogIconHardwareCurveRead, 'Выгрузка из памяти ГХ');
  if (fHardwareCurveDownloadBtn <> nil) and (fHardwareCurveDownloadBtn.Images = nil) then
    AssignDownloadFlashIcon(fHardwareCurveDownloadBtn);
  AssignSpeedButtonImage(fChannelCurveSelectBtn, fImages, CTagDialogIconProperty,
    'Редактировать канальную ГХ');
  AssignSpeedButtonImage(fChannelCurveAddBtn, fImages, CTagDialogIconAdd);
  AssignSpeedButtonImage(fChannelCurveDeleteBtn, fImages, CTagDialogIconRemove);
  AssignSpeedButtonImage(fChannelCurveEditBtn, fImages, CTagDialogIconChannelCurve,
    'Экспорт текущей ГХ в БДГХ');
  AssignSpeedButtonImage(fZeroBalanceBtn, fCommandImages, CTagDialogIconZeroBalance,
    'Балансировка нуля', CTagDeviceActionBtnSize);
  AssignSpeedButtonImage(fHardwareDeviceSetupBtn, fCommandImages,
    CTagDialogIconHardwareSource, 'Настройка аппаратной части', CTagDeviceActionBtnSize);
  LayoutTagDeviceActionButtons;
  LoadFromTags;
  fDefaultEstimateCombo.OnChange := @DefaultEstimateComboChange;
end;

destructor TTagSettingsDialog.Destroy;
begin
  fTags.Free;
  inherited Destroy;
end;


procedure TTagSettingsDialog.AssignSpeedButtonImage(AButton: TSpeedButton;
  AImages: TCustomImageList; AImageIndex: Integer; const AHint: string;
  ABtnSize: Integer);
var
  lBtnSize: Integer;
begin
  if (AButton = nil) or (AImages = nil) or (AImageIndex < 0) or
    (AImageIndex >= AImages.Count) then
    Exit;
  if ABtnSize > 0 then
    lBtnSize := ABtnSize
  else if AImages.Width > 0 then
    lBtnSize := AImages.Width
  else
    lBtnSize := 32;
  AButton.Images := AImages;
  AButton.ImageIndex := AImageIndex;
  AButton.ImageWidth := lBtnSize;
  AButton.Caption := '';
  AButton.Layout := blGlyphTop;
  AButton.Spacing := 0;
  AButton.Margin := 0;
  AButton.Flat := False;
  if AHint <> '' then
  begin
    AButton.Hint := AHint;
    AButton.ShowHint := True;
    AButton.ParentShowHint := False;
  end;
  AButton.SetBounds(AButton.Left, AButton.Top, lBtnSize, lBtnSize);
end;

procedure TTagSettingsDialog.AssignActionSpeedButton(AButton: TSpeedButton;
  AImages: TCustomImageList; AImageIndex: Integer; const ACaption, AHint: string);
begin
  if AButton = nil then
    Exit;
  if (AImages <> nil) and (AImageIndex >= 0) and (AImageIndex < AImages.Count) then
  begin
    AButton.Images := AImages;
    AButton.ImageIndex := AImageIndex;
    if AImages.Width > 0 then
      AButton.ImageWidth := AImages.Width
    else
      AButton.ImageWidth := 32;
  end;
  AButton.Caption := ACaption;
  AButton.Layout := blGlyphLeft;
  AButton.Spacing := 4;
  AButton.Margin := 6;
  AButton.Flat := False;
  AButton.Hint := AHint;
  AButton.ShowHint := True;
  AButton.ParentShowHint := False;
end;

procedure TTagSettingsDialog.UpdateChannelCurveText;
var
  lBool: Integer;
begin
  if fTags.Count = 0 then
    Exit;
  DisableEmptyChannelCalibrations;
  if TagAt(0).CalibrationNames.Count > 0 then
    fChannelCurveEdit.Text :=
      TagAt(0).CalibrationNames[TagAt(0).CalibrationNames.Count - 1]
  else
    fChannelCurveEdit.Text := '';
  lBool := AllChannelCalibrationEnabled;
  fChannelCurveCheck.AllowGrayed := fTags.Count > 1;
  if lBool < 0 then
    fChannelCurveCheck.State := cbGrayed
  else
    fChannelCurveCheck.Checked := lBool > 0;
end;

function TTagSettingsDialog.EnsureMic185HardwareCalibrationAssigned(
  ATag: TRecorderTag; AEnableOnTag: Boolean): Boolean;
begin
  Result := False;
  if (ATag = nil) or (fTagRegistry = nil) or
    (Pos('MIC-185:', ATag.SourceId) <> 1) then
    Exit;
  Result := RecorderMic185LoadHardwareCalibrationForTag(fTagRegistry, ATag,
    AEnableOnTag);
end;

function TTagSettingsDialog.TryGetStrainDeviceExcitation(ATag: TRecorderTag;
  out AExcitation: string): Boolean;
var
  lEffectivePowerMa: Double;
  lNominalPowerMa: Double;
  lSettings: TMic185ChannelProgramSettings;
begin
  Result := False;
  AExcitation := '';
  if (ATag = nil) or (fTagRegistry = nil) then
    Exit;

  if RecorderIsHardwareMic185TagSource(ATag.SourceId) then
  begin
    RecorderMic185GetSourceChannelMode(fTagRegistry, ATag.SourceId,
      ATag.Address, ATag.PollFrequencyHz, lSettings);
    lNominalPowerMa := Abs(Mic185PowerCodeToMa(lSettings.PowerMaCode));
    if SameValue(lNominalPowerMa, 0.0, 1E-9) then
      lNominalPowerMa := Abs(Mic185PowerCodeToMa(
        RecorderMic185GetSourcePowerMaCode(fTagRegistry, ATag.SourceId)));
    lEffectivePowerMa := RecorderMic185ApplyCurrentCalibration(fTagRegistry,
      ATag, lNominalPowerMa);
    AExcitation := FormatFloat('0.###', lEffectivePowerMa) + 'mA';
    Result := True;
  end;
end;

procedure TTagSettingsDialog.UpdateHardwareCurveText;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lConfigured: TRecorderConfiguredDataSource;
  lFirstEnabled: Boolean;
  lFirstName: string;
  lMic185Settings: TMic185ChannelProgramSettings;
  lSameEnabled: Boolean;
  lSameName: Boolean;
begin
  if fTags.Count = 0 then
    Exit;

  if Pos('MIC-185:', TagAt(0).SourceId) = 1 then
    for I := 0 to fTags.Count - 1 do
      EnsureMic185HardwareCalibrationAssigned(TagAt(I), False);
  lFirstName := Trim(TagAt(0).HardwareCalibrationName);
  lFirstEnabled := TagAt(0).HardwareCalibrationEnabled;
  lSameName := True;
  lSameEnabled := True;
  for I := 1 to fTags.Count - 1 do
  begin
    if not SameText(lFirstName, Trim(TagAt(I).HardwareCalibrationName)) then
      lSameName := False;
    if lFirstEnabled <> TagAt(I).HardwareCalibrationEnabled then
      lSameEnabled := False;
  end;

  fHardwareCurveCheck.AllowGrayed := fTags.Count > 1;
  if lSameEnabled then
    fHardwareCurveCheck.Checked := lFirstEnabled
  else
    fHardwareCurveCheck.State := cbGrayed;

  if not lSameName then
  begin
    fHardwareCurveEdit.Text := '<разные аппаратные ГХ>';
    Exit;
  end;

  lCalibration := fTagRegistry.FindCalibrationByName(
    lFirstName);
  if (lCalibration = nil) and (Pos('MIC-185:', TagAt(0).SourceId) = 1) then
  begin
    RecorderMic185LoadHardwareCalibrationForTag(fTagRegistry, TagAt(0), False);
    lFirstName := Trim(TagAt(0).HardwareCalibrationName);
    lFirstEnabled := TagAt(0).HardwareCalibrationEnabled;
    fHardwareCurveCheck.Checked := lFirstEnabled;
    lCalibration := fTagRegistry.FindCalibrationByName(lFirstName);
  end;
  // MC-201: если на диске уже есть ГХ для SN+диапазона — подтянуть сразу.
  if (Pos('MC-032:', TagAt(0).SourceId) = 1) and
    ((lCalibration = nil) or (lFirstName = '')) then
  begin
    lConfigured := RecorderConfiguredDataSourcesFind(fTagRegistry,
      TagAt(0).SourceId);
    if lConfigured <> nil then
    begin
      if RecorderMc201LoadHardwareCalibrationForTag(fTagRegistry, TagAt(0),
        lConfigured.SpecificConfigText) then
      begin
        lFirstName := Trim(TagAt(0).HardwareCalibrationName);
        lFirstEnabled := TagAt(0).HardwareCalibrationEnabled;
        fHardwareCurveCheck.Checked := lFirstEnabled;
        lCalibration := fTagRegistry.FindCalibrationByName(lFirstName);
      end;
    end;
  end;
  if (Pos('MIC-185:', TagAt(0).SourceId) = 1) and (lCalibration <> nil) then
  begin
    RecorderMic185GetSourceChannelMode(fTagRegistry, TagAt(0).SourceId,
      TagAt(0).Address, TagAt(0).PollFrequencyHz, lMic185Settings);
    fHardwareCurveEdit.Text := RecorderMic185EffectiveTransformText(
      fTagRegistry, TagAt(0), lMic185Settings, TagAt(0).UnitName);
  end
  else
    fHardwareCurveEdit.Text := lFirstName;
end;

function TTagSettingsDialog.Mic185SourceUnitName(ATag: TRecorderTag;
  const ASettings: TMic185ChannelProgramSettings): string;
begin
  Result := RecorderMic185GetSourceChannelUnitName(fTagRegistry,
    ATag.SourceId, ATag.Address);
  if Result = '' then
    Result := RecorderMic185RangeUnitText(ASettings.MeasRangeIndex);
end;

procedure TTagSettingsDialog.HardwareCurveCheckClick(Sender: TObject);
var
  lChannelNumber: Integer;
  lMic185Settings: TMic185ChannelProgramSettings;
  lSettings: TRecorderMic140ChannelSettings;
begin
  if fTags.Count <> 1 then
    Exit;
  if Pos('MIC-185:', TagAt(0).SourceId) = 1 then
  begin
    if not fHardwareCurveCheck.Checked then
    begin
      fUnitCombo.Text := 'код';
      Exit;
    end;
    RecorderMic185GetSourceChannelMode(fTagRegistry, TagAt(0).SourceId,
      TagAt(0).Address, TagAt(0).PollFrequencyHz, lMic185Settings);
    if SameText(Trim(fUnitCombo.Text), 'код') or
      SameText(Trim(fUnitCombo.Text), 'code') then
      fUnitCombo.Text := Mic185SourceUnitName(TagAt(0), lMic185Settings);
    fHardwareCurveEdit.Text := RecorderMic185EffectiveTransformText(
      fTagRegistry, TagAt(0), lMic185Settings, fUnitCombo.Text);
    Exit;
  end;
  if Pos(CMic140SourcePrefix, TagAt(0).SourceId) <> 1 then
    Exit;
  lSettings.ChannelAddress := '';
  if not RecorderMic140TryGetChannelSettings(fTagRegistry, TagAt(0),
    lChannelNumber, lSettings) then
    Exit;

  if not fHardwareCurveCheck.Checked then
    fUnitCombo.Text := 'code'
  else if lSettings.ChannelCalibrationEnabled and
    RecorderMic140ChannelUsesTemperature(lSettings) then
    fUnitCombo.Text := RecorderMic140OutputModeUnitName(momTemperatureC)
  else
    fUnitCombo.Text := RecorderMic140OutputModeUnitName(momMillivolts);
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

function TTagSettingsDialog.AllSourceId(out AValue: string): Boolean;
var
  I: Integer;
begin
  AValue := '';
  if fTags.Count = 0 then
    Exit(False);
  AValue := TagAt(0).SourceId;
  for I := 1 to fTags.Count - 1 do
    if not SameText(AValue, TagAt(I).SourceId) then
      Exit(False);
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

  case AGetter of
    0: lFirst := TagAt(0).AutoUnit;
    1: lFirst := TagAt(0).AutoRange;
  else
    lFirst := TagAt(0).SetpointRangeControlEnabled;
  end;

  for I := 1 to fTags.Count - 1 do
  begin
    case AGetter of
      0: lValue := TagAt(I).AutoUnit;
      1: lValue := TagAt(I).AutoRange;
    else
      lValue := TagAt(I).SetpointRangeControlEnabled;
    end;
    if lFirst <> lValue then
      Exit;
  end;

  if lFirst then
    Result := 1
  else
    Result := 0;
end;

function TTagSettingsDialog.AllChannelCalibrationEnabled: Integer;
var
  I: Integer;
  lFirst: Boolean;
begin
  Result := -1;
  if fTags.Count = 0 then
    Exit;
  lFirst := TagAt(0).ChannelCalibrationEnabled;
  for I := 1 to fTags.Count - 1 do
    if TagAt(I).ChannelCalibrationEnabled <> lFirst then
      Exit;
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

{ Совпадение настроек флага вычисляемых оценок }
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

{ Совпадение вида математической оценки по умолчанию }
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
    if RecorderIsDetachedTagSource(lSourceId) then
      Exit(True);
    if RecorderIsHardwareMic140TagSource(lSourceId) then
      Continue;
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
    lDialog.Caption := 'Выбор активного сигнала канала';
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
      MessageDlg('Связь входа',
        'Нет доступных сигналов активных источников для связи входа.',
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

  if not fTagRegistry.RenameTag(lTag, lTagName) then
    raise ERecorderTagError.Create('Invalid tag name');
  lTag.Address := ASignal.Address;
  lTag.UnitName := ASignal.UnitsName;
  lTag.SourceId := ASourceId;
  lTag.ModuleType := ASignal.ModuleName;
  lTag.PollFrequencyHz := ASignal.FrequencyHz;
  lTag.SensorCalibrationName := ASignal.SensorCalibrationName;
  lTag.AmplifierCalibrationName := ASignal.AmplifierCalibrationName;
  if Trim(lTag.Description) = '' then
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
    MessageDlg('Адрес канала',
      'Смена адреса входа доступна только для одного значения тега.',
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

function TTagSettingsDialog.CanConfigureHardwareSource: Boolean;
var
  lHost: string;
  lPort: Word;
  lTag: TRecorderTag;
begin
  Result := False;
  if fTags.Count <> 1 then
    Exit;
  lTag := TagAt(0);
  if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
    Exit(True);
  if TryParseRecorderMic185SourceId(lTag.SourceId, lHost, lPort) then
    Exit(True);
  if TryParseRecorderMc032SourceId(lTag.SourceId, lHost, lPort) then
    Exit(True);
  Result := Pos(CMeraSourcePrefix, lTag.SourceId) = 1;
end;

procedure TTagSettingsDialog.UpdateHardwareSourceSetupButton;
begin
  if fHardwareSourceSetupBtn = nil then
    Exit;
  fHardwareSourceSetupBtn.Enabled := CanConfigureHardwareSource;
  fHardwareSourceSetupBtn.Visible := CanConfigureHardwareSource;
end;

procedure TTagSettingsDialog.LayoutTagDeviceActionButtons;
var
  lLeft: Integer;
  lTop: Integer;
  lVisibleCount: Integer;
begin
  if pnTagDeviceActions = nil then
    Exit;
  lTop := 4;
  lLeft := 0;
  lVisibleCount := 0;
  if (fZeroBalanceBtn <> nil) and fZeroBalanceBtn.Visible then
  begin
    fZeroBalanceBtn.SetBounds(lLeft, lTop, CTagDeviceActionBtnSize, CTagDeviceActionBtnSize);
    Inc(lLeft, CTagDeviceActionBtnSize + CTagDeviceActionBtnGap);
    Inc(lVisibleCount);
  end;
  if (fHardwareDeviceSetupBtn <> nil) and fHardwareDeviceSetupBtn.Visible then
  begin
    fHardwareDeviceSetupBtn.SetBounds(lLeft, lTop, CTagDeviceActionBtnSize,
      CTagDeviceActionBtnSize);
    Inc(lLeft, CTagDeviceActionBtnSize + CTagDeviceActionBtnGap);
    Inc(lVisibleCount);
  end;
  if lVisibleCount > 0 then
  begin
    pnTagDeviceActions.Height := CTagDeviceActionBtnSize + 8;
    pnTagDeviceActions.Width := lLeft;
  end;
end;

function TTagSettingsDialog.CanZeroBalance: Boolean;
var
  I: Integer;
  lHost: string;
  lPort: Word;
  lTag: TRecorderTag;
begin
  Result := False;
  if fTags.Count = 0 then
    Exit;
  for I := 0 to fTags.Count - 1 do
  begin
    lTag := TagAt(I);
    if Pos('Detached:', lTag.SourceId) = 1 then
      Continue;
    if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
      Exit(True);
    if TryParseRecorderMic185SourceId(lTag.SourceId, lHost, lPort) then
      Exit(True);
    if TryParseRecorderMc032SourceId(lTag.SourceId, lHost, lPort) then
      Exit(True);
  end;
end;

procedure TTagSettingsDialog.UpdateTagDeviceActionButtons;
begin
  if fZeroBalanceBtn <> nil then
  begin
    fZeroBalanceBtn.Enabled := CanZeroBalance;
    fZeroBalanceBtn.Visible := CanZeroBalance;
  end;
  if fHardwareDeviceSetupBtn <> nil then
  begin
    fHardwareDeviceSetupBtn.Enabled := CanConfigureHardwareSource;
    fHardwareDeviceSetupBtn.Visible := CanConfigureHardwareSource;
  end;
  if pnTagDeviceActions <> nil then
    pnTagDeviceActions.Visible := (fZeroBalanceBtn <> nil) and fZeroBalanceBtn.Visible or
      ((fHardwareDeviceSetupBtn <> nil) and fHardwareDeviceSetupBtn.Visible);
  LayoutTagDeviceActionButtons;
end;

procedure TTagSettingsDialog.UpdateVirtualChannelInfo;
begin
  if lbVirtualChannelInfo = nil then
    Exit;
  lbVirtualChannelInfo.Visible := (fTags.Count = 1) and
    RecorderIsVirtualTagSource(TagAt(0).SourceId);
end;

procedure TTagSettingsDialog.ZeroBalanceButtonClick(Sender: TObject);
begin
  if not CanZeroBalance then
    Exit;
  if fOnZeroBalance <> nil then
    fOnZeroBalance(Self, fTagRegistry, fTags);
end;

procedure TTagSettingsDialog.HardwareDeviceSetupButtonClick(Sender: TObject);
begin
  HardwareSourceSetupButtonClick(Sender);
end;

procedure TTagSettingsDialog.HardwareSourceSetupButtonClick(Sender: TObject);
var
  lConfigs: TStringList;
  lDialog: TOpenDialog;
  lHost: string;
  lNewSourceId: string;
  lOldSourceId: string;
  lPath: string;
  lPort: Word;
  lTag: TRecorderTag;
  I: Integer;
begin
  if not CanConfigureHardwareSource then
    Exit;
  lTag := TagAt(0);
  if fOnHardwareSourceSetup <> nil then
  begin
    fOnHardwareSourceSetup(Self, lTag);
    LoadFromTags;
    Exit;
  end;

  if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
  begin
    lConfigs := TStringList.Create;
    try
      lConfigs.OwnsObjects := True;
      if ApplyRecorderMic140SourceDialog(Self, fTagRegistry, lConfigs, lTag.SourceId,
        lNewSourceId) then
        LoadFromTags;
    finally
      lConfigs.Free;
    end;
    Exit;
  end;

  if Pos(CMeraSourcePrefix, lTag.SourceId) <> 1 then
    Exit;
  lPath := Trim(Copy(lTag.SourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Выберите файл Mera';
    lDialog.Filter := 'Mera file (*.mera)|*.mera|All files (*.*)|*.*';
    if lPath <> '' then
    begin
      lDialog.InitialDir := ExtractFilePath(lPath);
      lDialog.FileName := ExtractFileName(lPath);
    end;
    if not lDialog.Execute then
      Exit;
    lOldSourceId := lTag.SourceId;
    lNewSourceId := CMeraSourcePrefix + lDialog.FileName;
    fTagRegistry.RegisterActiveSource(lNewSourceId);
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      if SameText(fTagRegistry.Tags[I].SourceId, lOldSourceId) then
        fTagRegistry.Tags[I].SourceId := lNewSourceId;
    end;
    LoadFromTags;
  finally
    lDialog.Free;
  end;
end;

{ Загрузка текущих параметров тегов в элементы интерфейса }
procedure TTagSettingsDialog.LoadFromTags;
var
  I: Integer;
  lText: string;
  lFloat: Double;
  lBool: Integer;
  lChecked: Boolean;
  lEstimateKind: TRecorderTagEstimateKind;
  lIndex: Integer;
  lInt: Integer;
  lSetpointKind: TRecorderTagSetpointKind;
  lJ: Integer;
  lSourceId: string;
  lSourceActive: Boolean;
  lTagTemp: TRecorderTag;
  lFrequencyGrid: TRecorderFrequencyGrid;
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
    lSourceId := Trim(lTagTemp.SourceId);
    if RecorderIsDetachedTagSource(lSourceId) then
    begin
      lSourceActive := False;
      Break;
    end;
    if RecorderIsHardwareMic140TagSource(lSourceId) then
      Continue;
    if SourceNeedsActiveCheck(lSourceId) and
      not fTagRegistry.IsSourceActive(lSourceId) then
    begin
      lSourceActive := False;
      Break;
    end;
  end;
  fDetachedSourceLabel.Visible := not lSourceActive;

  if AllString(3, lText) then
    fDescriptionEdit.Text := lText
  else
    fDescriptionEdit.Text := '';

  fFrequencyCombo.Items.Clear;
  if AllSourceId(lSourceId) and
    RecorderFrequencyGridForSource(lSourceId, lFrequencyGrid) then
    for I := 0 to High(lFrequencyGrid) do
      fFrequencyCombo.Items.Add(FormatFloat('0.######', lFrequencyGrid[I]));

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
  UpdateHardwareCurveText;
  UpdateHardwareCurveButtons;
  UpdateHardwareSourceSetupButton;
  UpdateTagDeviceActionButtons;
  UpdateVirtualChannelInfo;

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
  begin
    if (fTags.Count > 0) and RecorderTagEstimatePortionLengthIsAuto(lInt, TagAt(0).PollFrequencyHz, fDataUpdateMs) then
      lInt := RecorderTagDefaultEstimatePortionLength(TagAt(0).PollFrequencyHz, fDataUpdateMs);
    fPortionLengthEdit.Text := IntToStr(lInt);
  end
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

  lBool := AllBool(2);
  fSetpointRangeControlCheck.AllowGrayed := fTags.Count > 1;
  if lBool < 0 then
    fSetpointRangeControlCheck.State := cbGrayed
  else
    fSetpointRangeControlCheck.Checked := lBool > 0;
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
  lMic185Settings: TMic185ChannelProgramSettings;
  lSetpoint: TRecorderTagSetpoint;
  lSetpointKind: TRecorderTagSetpointKind;
  lChannelNumber: Integer;
  lSettings: TRecorderMic140ChannelSettings;
  lAppliedMic185Sources: TStringList;
  lAutoUnitName: string;
  lPreviousUnitName: string;
  lSourceId: string;
begin
  if fNameEdit.Enabled and (Trim(fNameEdit.Text) <> '') then
  begin
    lExisting := fTagRegistry.FindByName(Trim(fNameEdit.Text));
    if (lExisting <> nil) and (lExisting <> TagAt(0)) then
      raise ERecorderTagError.Create('Tag name already exists: ' + Trim(fNameEdit.Text));
    if not fTagRegistry.RenameTag(TagAt(0), Trim(fNameEdit.Text)) then
      raise ERecorderTagError.Create('Invalid tag name');
  end;

  lAppliedMic185Sources := TStringList.Create;
  try
    lAppliedMic185Sources.CaseSensitive := False;
    for I := 0 to fTags.Count - 1 do
    begin
      lTag := TagAt(I);
      lPreviousUnitName := lTag.UnitName;
    if fSelectedMeraFileName <> '' then
    begin
      lTag.Address := Trim(fModuleEdit.Text);
      lTag.SourceId := 'Mera file: ' + fSelectedMeraFileName;
      lTag.IsVirtual := True;
      RecorderTagClearMic140Settings(lTag);
    end;
    if Trim(fUnitCombo.Text) <> '' then
      lTag.UnitName := Trim(fUnitCombo.Text);
    if (fTags.Count = 1) or (Trim(fDescriptionEdit.Text) <> '') then
      lTag.Description := Trim(fDescriptionEdit.Text);
    if fFrequencyCombo.Enabled and (Trim(fFrequencyCombo.Text) <> '') then
    begin
      if not ReadFloat(fFrequencyCombo.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid poll frequency');
      if Pos('MIC-140:', lTag.SourceId) = 1 then
      begin
        { Частота у MIC-140 общая для прибора. Не запускаем обход всех тегов
          и изменение их буферов, если пользователь просто нажал OK. }
        if not SameValue(lTag.PollFrequencyHz,
          RecorderMic140NormalizeFrequency(lFloat), 1E-9) then
          RecorderMic140ApplySourceFrequency(fTagRegistry, lTag.SourceId, lFloat);
      end
      else if Pos('MC-032:', lTag.SourceId) = 1 then
        RecorderMc201ApplySlotFrequency(fTagRegistry, lTag.SourceId,
          lTag.Address, lFloat)
      else if Pos('MIC-185:', lTag.SourceId) = 1 then
      begin
        lSourceId := RecorderNormalizeTagSourceId(lTag.SourceId);
        if lAppliedMic185Sources.IndexOf(lSourceId) < 0 then
        begin
          lAppliedMic185Sources.Add(lSourceId);
          RecorderMic185ApplySourceFrequency(fTagRegistry, lSourceId, lFloat,
            fDataUpdateMs);
        end;
      end
      else
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
    if fHardwareCurveCheck.State <> cbGrayed then
    begin
      if lTag.HardwareCalibrationEnabled <> fHardwareCurveCheck.Checked then
        lTag.ClearSignalHistory;
      lTag.HardwareCalibrationEnabled := fHardwareCurveCheck.Checked;
      if lTag.HardwareCalibrationEnabled and
        (Pos('MIC-185:', lTag.SourceId) = 1) then
      begin
        EnsureMic185HardwareCalibrationAssigned(lTag, True);
        RecorderMic185GetSourceChannelMode(fTagRegistry, lTag.SourceId,
          lTag.Address, lTag.PollFrequencyHz, lMic185Settings);
        if SameText(Trim(lTag.UnitName), 'код') or
          SameText(Trim(lTag.UnitName), 'code') then
          lTag.UnitName := Mic185SourceUnitName(lTag, lMic185Settings);
        lTag.RangeMax := RecorderMic185EffectiveRangeMaxForTag(fTagRegistry,
          lTag, lMic185Settings, lTag.UnitName);
        lTag.RangeMin := -lTag.RangeMax;
      end;
      if (not lTag.HardwareCalibrationEnabled) and
        (Pos('MIC-185:', lTag.SourceId) = 1) then
      begin
        RecorderMic185SetSourceChannelUnitName(fTagRegistry, lTag.SourceId,
          lTag.Address, lTag.PollFrequencyHz, lPreviousUnitName);
        lTag.UnitName := 'код';
      end;
      if Pos(CMic140SourcePrefix, lTag.SourceId) = 1 then
      begin
        lSettings.ChannelAddress := '';
        if RecorderMic140TryGetChannelSettings(fTagRegistry, lTag,
          lChannelNumber, lSettings) then
        begin
          lSettings.HardwareCalibrationEnabled :=
            lTag.HardwareCalibrationEnabled;
          lSettings.HardwareCalibrationName :=
            lTag.HardwareCalibrationName;
          RecorderMic140UpdateChannelSettings(fTagRegistry, lTag, lSettings);
        end;
      end;
    end;
    { Hardware curve edit may show MIC-185 k,b details; calibration assignment
      itself is changed only by explicit read/select actions. }
    if fChannelCurveCheck.State <> cbGrayed then
    begin
      if lTag.ChannelCalibrationEnabled <> fChannelCurveCheck.Checked then
        lTag.ClearSignalHistory;
      lTag.ChannelCalibrationEnabled := fChannelCurveCheck.Checked;
      if lTag.ChannelCalibrationEnabled and
        ((lTag.CalibrationNames = nil) or (lTag.CalibrationNames.Count = 0)) then
        lTag.ChannelCalibrationEnabled := False;
      if Pos(CMic140SourcePrefix, lTag.SourceId) = 1 then
      begin
        if fChannelCurveCheck.Checked then
        begin
          lSettings.ChannelAddress := '';
          if RecorderMic140TryGetChannelSettings(fTagRegistry, lTag, lChannelNumber,
            lSettings) and ((Trim(lSettings.ThermocoupleScalePath) <> '') or
            (Trim(lSettings.ThermocoupleScaleName) <> '')) then
          begin
            if lTag.SourceValueMode <>
              RecorderMic140OutputModeToConfigName(momTemperatureC) then
              lTag.ClearSignalHistory;
            lTag.SourceValueMode :=
              RecorderMic140OutputModeToConfigName(momTemperatureC);
            lTag.UnitName := RecorderMic140OutputModeUnitName(momTemperatureC);
          end;
        end
        else
        begin
          if lTag.SourceValueMode <>
            RecorderMic140OutputModeToConfigName(momMillivolts) then
            lTag.ClearSignalHistory;
          lTag.SourceValueMode :=
            RecorderMic140OutputModeToConfigName(momMillivolts);
          lTag.UnitName := RecorderMic140OutputModeUnitName(momMillivolts);
        end;
      end;
    end;
    if Pos(CMic140SourcePrefix, lTag.SourceId) = 1 then
    begin
      lSettings.ChannelAddress := '';
      if RecorderMic140TryGetChannelSettings(fTagRegistry, lTag,
        lChannelNumber, lSettings) then
      begin
        lSettings.ChannelCalibrationEnabled :=
          lTag.ChannelCalibrationEnabled;
        if lSettings.ChannelCalibrationEnabled and
          RecorderMic140ChannelUsesTemperature(lSettings) then
          lSettings.OutputMode :=
            RecorderMic140OutputModeToConfigName(momTemperatureC)
        else
          lSettings.OutputMode :=
            RecorderMic140OutputModeToConfigName(momMillivolts);
        lSettings.HardwareCalibrationEnabled :=
          lTag.HardwareCalibrationEnabled;
        lSettings.HardwareCalibrationName :=
          lTag.HardwareCalibrationName;
        RecorderMic140UpdateChannelSettings(fTagRegistry, lTag, lSettings);
        RecorderMic140ApplyTagOutputPresentation(lTag, lSettings);
      end;
    end;

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
      if (fTags.Count > 0) and (lInt = RecorderTagDefaultEstimatePortionLength(TagAt(0).PollFrequencyHz, fDataUpdateMs)) then
        lInt := 17280;
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
    if fSetpointRangeControlCheck.State <> cbGrayed then
      lTag.SetpointRangeControlEnabled := fSetpointRangeControlCheck.Checked;
    if (not RecorderTagUsesMic140Settings(lTag)) and
      (not RecorderIsHardwareMic185TagSource(lTag.SourceId)) then
      RecorderTagClearMic140Settings(lTag);
    if lTag.AutoUnit and
      TryGetChannelCalibrationOutputUnit(lTag, lAutoUnitName) then
      lTag.UnitName := lAutoUnitName;
  end;
  finally
    lAppliedMic185Sources.Free;
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
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Канальная ГХ',
      'Выбор ГХ из списка поддерживается только для одного значения тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if Pos(CMic140SourcePrefix, TagAt(0).SourceId) = 1 then
  begin
    MessageDlg('Канальная ГХ',
      'Для MIC-140 термопарная ГХ настраивается в диалоге канала MIC-140 ' +
      'и выгружается из памяти прибора. Общий список ГХ для этого канала не используется.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if ShowRecorderCalibrationPipelineDialog(Self, fTagRegistry.Calibrations,
    TagAt(0).CalibrationNames) then
  begin
    TagAt(0).ChannelCalibrationEnabled :=
      TagAt(0).CalibrationNames.Count > 0;
    ApplyAutoUnitFromChannelCalibration;
    UpdateChannelCurveText;
  end;
end;

function TTagSettingsDialog.TryGetChannelCalibrationOutputUnit(
  ATag: TRecorderTag; out AUnitName: string): Boolean;
var
  lCalibration: TRecorderCalibration;
  lLastIndex: Integer;
begin
  AUnitName := '';
  Result := False;
  if (ATag = nil) or (ATag.CalibrationNames = nil) or
    (ATag.CalibrationNames.Count = 0) then
    Exit;
  lLastIndex := ATag.CalibrationNames.Count - 1;
  lCalibration := fTagRegistry.FindCalibrationByName(
    ATag.CalibrationNames[lLastIndex]);
  if lCalibration = nil then
    Exit;
  AUnitName := Trim(lCalibration.UnitOut);
  Result := AUnitName <> '';
end;

procedure TTagSettingsDialog.ApplyAutoUnitFromChannelCalibration;
var
  I: Integer;
  lUnitName: string;
begin
  if fAutoUnitCheck.State <> cbChecked then
    Exit;
  for I := 0 to fTags.Count - 1 do
    if TryGetChannelCalibrationOutputUnit(TagAt(I), lUnitName) then
      TagAt(I).UnitName := lUnitName;
  if (fTags.Count = 1) and
    TryGetChannelCalibrationOutputUnit(TagAt(0), lUnitName) then
    fUnitCombo.Text := lUnitName;
end;

procedure TTagSettingsDialog.AutoUnitCheckClick(Sender: TObject);
begin
  ApplyAutoUnitFromChannelCalibration;
end;

procedure TTagSettingsDialog.EstimateCheckClick(Sender: TObject);
var
  lCheck: TCheckBox;
begin
  if not (Sender is TCheckBox) then
    Exit;
  lCheck := TCheckBox(Sender);
  if lCheck.State = cbGrayed then
    lCheck.State := cbChecked;
  lCheck.AllowGrayed := False;
end;

procedure TTagSettingsDialog.DefaultEstimateComboChange(Sender: TObject);
var
  lCheck: TCheckBox;
  lKind: TRecorderTagEstimateKind;
begin
  if fDefaultEstimateCombo.ItemIndex < 0 then
    Exit;
  lKind := TRecorderTagEstimateKind(PtrInt(
    fDefaultEstimateCombo.Items.Objects[fDefaultEstimateCombo.ItemIndex]));
  if lKind > tekPeakToPeakByRmsDeviation then
    Exit;
  lCheck := fEstimateChecks[lKind];
  if lCheck = nil then
    Exit;
  lCheck.AllowGrayed := False;
  lCheck.Checked := True;
end;

procedure TTagSettingsDialog.DisableEmptyChannelCalibrations;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  for I := 0 to fTags.Count - 1 do
  begin
    lTag := TagAt(I);
    if (lTag <> nil) and lTag.ChannelCalibrationEnabled and
      ((lTag.CalibrationNames = nil) or (lTag.CalibrationNames.Count = 0)) then
      lTag.ChannelCalibrationEnabled := False;
  end;
end;

procedure TTagSettingsDialog.AddCalibrationButtonClick(Sender: TObject);
var
  lAction: TRecorderCalibrationAddAction;
  lCalibrationName: string;
  lExcitation: string;
  lKey: string;
  I: Integer;
  lKind: TRecorderCalibrationKind;
  lCalibration: TRecorderCalibration;
begin
  if not ShowRecorderCalibrationAddDialog(Self, lKind, lAction) then
    Exit;

  if lAction = rcaaLoadFromSdb then
  begin
    if not ShowRecorderSdbSelectDialog(Self, '', lKey) or
      not RecorderSdbImportCalibration(fTagRegistry.Calibrations, lKey,
        lCalibrationName) then
      Exit;
    for I := 0 to fTags.Count - 1 do
    begin
      if TagAt(I).CalibrationNames.Count = 0 then
        TagAt(I).CalibrationNames.Add(lCalibrationName)
      else
        TagAt(I).CalibrationNames[TagAt(I).CalibrationNames.Count - 1] :=
          lCalibrationName;
      TagAt(I).ChannelCalibrationEnabled := True;
    end;
    ApplyAutoUnitFromChannelCalibration;
    UpdateChannelCurveText;
    Exit;
  end;

  lCalibration := TRecorderCalibration.Create(lKind);
  try
    lCalibration.Name := 'ГХ ' + IntToStr(fTagRegistry.Calibrations.Count + 1);
    if lKind = rckPiecewiseLinear then
    begin
      lCalibration.AddPoint(0, 0);
      lCalibration.AddPoint(1, 1);
    end;

    if lKind = rckStrain then
    begin
      if fTags.Count > 0 then
        TryGetStrainDeviceExcitation(TagAt(0), lExcitation);
      if not ShowRecorderStrainCalibrationDialog(Self, lCalibration,
        lExcitation, TagAt(0).UnitName) then Exit;
    end
    else if not ShowRecorderCalibrationPropertiesDialog(Self, lCalibration) then
      Exit;

  fTagRegistry.Calibrations.Add(lCalibration);
  for I := 0 to fTags.Count - 1 do
  begin
    if TagAt(I).CalibrationNames.Count = 0 then
      TagAt(I).CalibrationNames.Add(lCalibration.Name)
    else
      TagAt(I).CalibrationNames[TagAt(I).CalibrationNames.Count - 1] :=
        lCalibration.Name;
    TagAt(I).ChannelCalibrationEnabled := True;
  end;
    lCalibration := nil;
    ApplyAutoUnitFromChannelCalibration;
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
  begin
    TagAt(I).CalibrationNames.Clear;
    TagAt(I).ChannelCalibrationEnabled := False;
    if Pos(CMic140SourcePrefix, TagAt(I).SourceId) = 1 then
    begin
      TagAt(I).SourceValueMode :=
        RecorderMic140OutputModeToConfigName(momMillivolts);
      TagAt(I).UnitName := RecorderMic140OutputModeUnitName(momMillivolts);
    end;
  end;
  UpdateChannelCurveText;
end;

procedure TTagSettingsDialog.EditCalibrationButtonClick(Sender: TObject);
begin
  if (fTags.Count = 1) and (TagAt(0).CalibrationNames.Count > 0) then
    EditCalibrationAt(TagAt(0).CalibrationNames.Count - 1)
  else
    EditCalibrationAt(-1);
end;

procedure TTagSettingsDialog.EditCalibrationAt(APipelineIndex: Integer);
var
  lCalibration: TRecorderCalibration;
  lDraft: TRecorderCalibration;
  lExcitation: string;
  lName: string;
  lChoice: TModalResult;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Канальная ГХ','Редактирование доступно только для одного значения тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if (APipelineIndex < 0) or
    (APipelineIndex >= TagAt(0).CalibrationNames.Count) then
  begin
    MessageDlg('Канальная ГХ',
      'У выбранного тега нет назначенной ГХ.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  lName := TagAt(0).CalibrationNames[APipelineIndex];
  lCalibration := fTagRegistry.FindCalibrationByName(lName);
  if lCalibration = nil then
  begin
    MessageDlg('Канальная ГХ', 'ГХ «' + lName +
      '» не найдена в реестре калибровок.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  lDraft := lCalibration.Clone;
  try
    TryGetStrainDeviceExcitation(TagAt(0), lExcitation);
    if not (((lDraft.Kind = rckStrain) and
      ShowRecorderStrainCalibrationDialog(Self, lDraft, lExcitation,
      TagAt(0).UnitName)) or
      ((lDraft.Kind <> rckStrain) and
      ShowRecorderCalibrationPropertiesDialog(Self, lDraft))) then
      Exit;

    lChoice := MessageDlg('Сохранение канальной ГХ',
      'Да — изменить общую ГХ для всех тегов, которые её используют.' + LineEnding +
      'Нет — создать отдельную локальную копию только для текущего тега.' + LineEnding +
      'Отмена — не применять изменения.', mtConfirmation,
      [mbYes, mbNo, mbCancel], 0);
    try
      case lChoice of
        mrYes:
          fTagRegistry.CommitCalibrationEdit(lCalibration, lDraft);
        mrNo:
          fTagRegistry.AddCalibrationCopyForTag(TagAt(0), APipelineIndex, lDraft);
      else
        Exit;
      end;
    except
      on E: ERecorderTagError do
      begin
        MessageDlg('Канальная ГХ', E.Message, mtError, [mbOK], 0);
        Exit;
      end;
    end;
    ApplyAutoUnitFromChannelCalibration;
    UpdateChannelCurveText;
  finally
    lDraft.Free;
  end;
end;

procedure TTagSettingsDialog.ChannelCurveNotebookClick(Sender: TObject);
var
  lIndex: Integer;
begin
  if (fTags.Count <> 1) or (TagAt(0).CalibrationNames.Count = 0) then
  begin
    EditCalibrationAt(-1);
    Exit;
  end;
  if TagAt(0).CalibrationNames.Count = 1 then
  begin
    EditCalibrationAt(0);
    Exit;
  end;
  if ShowRecorderCalibrationPipelineItemDialog(Self,
    fTagRegistry.Calibrations, TagAt(0).CalibrationNames, lIndex) then
    EditCalibrationAt(lIndex);
end;

procedure TTagSettingsDialog.ExportCalibrationButtonClick(Sender: TObject);
var
  lCalibration: TRecorderCalibration;
  lCreatedKey: string;
  lError: string;
  lFolderKey: string;
  lName: string;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Экспорт ГХ',
      'Экспорт доступен только для одного значения тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  if TagAt(0).CalibrationNames.Count = 0 then
  begin
    MessageDlg('Экспорт ГХ', 'У выбранного тега нет назначенной ГХ.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  lName := TagAt(0).CalibrationNames[TagAt(0).CalibrationNames.Count - 1];
  lCalibration := fTagRegistry.FindCalibrationByName(lName);
  if lCalibration = nil then
  begin
    MessageDlg('Экспорт ГХ', 'Назначенная ГХ не найдена в реестре.', mtError, [mbOK], 0);
    Exit;
  end;
  if not ShowRecorderSdbFolderSelectDialog(Self, '', lFolderKey) then
    Exit;
  if RecorderSdbExportCalibration(lFolderKey, lCalibration, False,
    lCreatedKey, lError) then
  begin
    MessageDlg('Экспорт ГХ', 'ГХ экспортирована в БДГХ:' + LineEnding + lCreatedKey, mtInformation, [mbOK], 0);
    Exit;
  end;
  if lError = 'EXISTS' then
  begin
    if MessageDlg('Экспорт ГХ', 'В выбранной папке уже есть ГХ с таким именем.' +LineEnding + 'Заменить её?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;
    if RecorderSdbExportCalibration(lFolderKey, lCalibration, True,
      lCreatedKey, lError) then
    begin
      MessageDlg('Экспорт ГХ', 'ГХ заменена в БДГХ:' + LineEnding +
        lCreatedKey, mtInformation, [mbOK], 0);
      Exit;
    end;
  end;
  MessageDlg('Экспорт ГХ', 'Не удалось экспортировать ГХ:' + LineEnding +
    lError, mtError, [mbOK], 0);
end;

procedure TTagSettingsDialog.SelectHardwareCalibrationButtonClick(Sender: TObject);
var
  lCalibration: TRecorderCalibration;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Аппаратная ГХ',
      'Просмотр аппаратной ГХ поддерживается только для одного значения тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if Trim(TagAt(0).HardwareCalibrationName) = '' then
    EnsureMic185HardwareCalibrationAssigned(TagAt(0), False);

  if Trim(TagAt(0).HardwareCalibrationName) = '' then
  begin
    MessageDlg('Аппаратная ГХ',
      'У выбранного тега нет назначенной аппаратной ГХ. Сначала выполните вычитку ГХ из модуля.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  lCalibration := fTagRegistry.FindCalibrationByName(
    Trim(TagAt(0).HardwareCalibrationName));
  if lCalibration <> nil then
  begin
    if ShowRecorderCalibrationPropertiesDialog(Self, lCalibration) then
      UpdateHardwareCurveText;
  end
  else
  begin
    MessageDlg('Аппаратная ГХ',
      'Градуировка аппаратной ГХ не найдена в реестре калибровок.',
      mtInformation, [mbOK], 0);
  end;
end;

procedure TTagSettingsDialog.EditHardwareCalibrationButtonClick(Sender: TObject);
var
  lCalibration: TRecorderCalibration;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Аппаратная ГХ',
      'Редактирование доступно только для одного значения тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if Trim(TagAt(0).HardwareCalibrationName) = '' then
    EnsureMic185HardwareCalibrationAssigned(TagAt(0), False);

  if Trim(TagAt(0).HardwareCalibrationName) = '' then
  begin
    MessageDlg('Аппаратная ГХ',
      'У выбранного тега нет назначенной аппаратной ГХ.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  lCalibration := fTagRegistry.FindCalibrationByName(TagAt(0).HardwareCalibrationName);
  if lCalibration = nil then
  begin
    MessageDlg('Аппаратная ГХ',
      'Градуировка аппаратной ГХ не найдена в списке калибровок.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if ShowRecorderCalibrationPropertiesDialog(Self, lCalibration) then
    UpdateHardwareCurveText;
end;

procedure TTagSettingsDialog.AssignDownloadFlashIcon(AButton: TSpeedButton);
var
  lI: Integer;
  lIcon: TIcon;
begin
  if AButton = nil then
    Exit;
  lIcon := TIcon.Create;
  try
    for lI := Low(CRamOutIconPaths) to High(CRamOutIconPaths) do
    begin
      if FileExists(CRamOutIconPaths[lI]) then
      begin
        lIcon.LoadFromFile(CRamOutIconPaths[lI]);
        AButton.Glyph.Assign(lIcon);
        Break;
      end;
    end;
  finally
    lIcon.Free;
  end;
end;

procedure TTagSettingsDialog.UpdateHardwareCurveButtons;
var
  lI: Integer;
  lHasHardwareDevice: Boolean;
begin
  lHasHardwareDevice := False;
  for lI := 0 to fTags.Count - 1 do
  begin
    if (Pos('MIC-140:', TagAt(lI).SourceId) = 1) or
      (Pos('MIC-185:', TagAt(lI).SourceId) = 1) or
      (Pos('MC-032: ', TagAt(lI).SourceId) = 1) then
    begin
      lHasHardwareDevice := True;
      Break;
    end;
  end;
  if fHardwareCurveDownloadBtn <> nil then
    fHardwareCurveDownloadBtn.Visible := lHasHardwareDevice;
end;

procedure TTagSettingsDialog.DownloadHardwareCalibrationFromDeviceClick(Sender: TObject);
const
  sGhDownloadTitle = 'Выгрузка ГХ';
  sGhDownloadOk = 'Градуировки успешно выгружены из памяти устройства.';
  sGhDownloadNoSupportedMic =
    'Среди выбранных тегов нет каналов MIC-140 или MIC-185.';
var
  lB: Double;
  lCalibrationName: string;
  lErrorMessage: string;
  lErrors: TStringList;
  lI: Integer;
  lK: Double;
  lMessageText: string;
  lMessages: TStringList;
  lOkCount: Integer;
  lDevice: IRecorderDevice;
  lValues: TRecorderDeviceActionValues;
begin
  if fTags.Count = 0 then
    Exit;

  lErrors := TStringList.Create;
  lMessages := TStringList.Create;
  try
    lOkCount := 0;
    for lI := 0 to fTags.Count - 1 do
    begin
      if Pos('MC-032: ', TagAt(lI).SourceId) = 1 then
      begin
        lDevice := RecorderHardwareFindLiveDevice(TagAt(lI).SourceId);
        if lDevice = nil then
          lErrors.Add(Format('%s (%s): нет активной сессии MC-032',
            [TagAt(lI).Name, TagAt(lI).Address]))
        else if not lDevice.ExecuteDeviceAction(rdaReadHardwareCalibration,
          [], lValues, lErrorMessage) then
          lErrors.Add(Format('%s (%s): %s', [TagAt(lI).Name,
            TagAt(lI).Address, lErrorMessage]));
        Continue;
      end;
      if Pos('MIC-185:', TagAt(lI).SourceId) = 1 then
      begin
        if RecorderMic185DownloadHardwareCalibrationFromDeviceEx(fTagRegistry,
          TagAt(lI), lK, lB, lCalibrationName, lErrorMessage) then
        begin
          Inc(lOkCount);
          lMessages.Add(Format('%s (%s): %s', [TagAt(lI).Name,
            TagAt(lI).Address, RecorderMic185FormatHardwareKx(lK, lB)]));
        end
        else
          lErrors.Add(Format('%s (%s): %s', [TagAt(lI).Name, TagAt(lI).Address,
            lErrorMessage]));
        Continue;
      end;
      if Pos('MIC-140:', TagAt(lI).SourceId) <> 1 then
        Continue;
      if RecorderMic140DownloadHardwareCalibrationFromDevice(fTagRegistry,
        TagAt(lI), lErrorMessage) then
        Inc(lOkCount)
      else
        lErrors.Add(Format('%s (%s): %s', [TagAt(lI).Name, TagAt(lI).Address,
          lErrorMessage]));
    end;

    UpdateHardwareCurveText;
    if (lErrors.Count = 0) and (lOkCount > 0) then
    begin
      if lMessages.Count > 0 then
      begin
        lMessageText := lMessages[0];
        if lMessages.Count > 1 then
          lMessageText := lMessageText + LineEnding + '...';
        MessageDlg(sGhDownloadTitle, sGhDownloadOk + LineEnding +
          lMessageText, mtInformation, [mbOK], 0);
      end
      else
        MessageDlg(sGhDownloadTitle, sGhDownloadOk, mtInformation, [mbOK], 0);
    end
    else if lErrors.Count > 0 then
      MessageDlg(sGhDownloadTitle, lErrors.Text, mtError, [mbOK], 0)
    else
      MessageDlg(sGhDownloadTitle, sGhDownloadNoSupportedMic,
        mtInformation, [mbOK], 0);
  finally
    lMessages.Free;
    lErrors.Free;
  end;
end;

end.
