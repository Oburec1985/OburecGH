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
  uRecorderDataSources, uRecorderTagSettingsProvider,
  uRecorderCalibrationAddDialog, uRecorderCalibrationPropertiesDialog,
  uRecorderCalibrationListDialog, uRecorderSdbStore, uRecorderSdbSelectDialog,
  uRecorderStrainCalibrationDialog,
  uRecorderCommandImages, uRcIconIds,
  uRecorderFrequencyGrids, uRecorderUnitManager,
  uRecorderTagCalibrationDialog;

type
  TTagHardwareSourceSetupEvent = procedure(Sender: TObject; ATag: TRecorderTag) of object;
  TTagCanZeroBalanceEvent = function(Sender: TObject;
    ARegistry: TRecorderTagRegistry; ATags: TList): Boolean of object;
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
    fChannelCalibrateBtn: TButton;
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
    fSetpointAlarmInfoEdit0: TEdit;
    lbSetpointText0_1: TLabel;
    lbSetpointText0_2: TLabel;
    fSetpointColorPanel0: TPanel;
    pnSetpoint1: TPanel;
    lbSetpointName1: TLabel;
    fSetpointEnabledCheck1: TCheckBox;
    pnSetpointUnit1: TPanel;
    fSetpointThresholdEdit1: TEdit;
    fSetpointAlarmInfoEdit1: TEdit;
    lbSetpointText1_1: TLabel;
    lbSetpointText1_2: TLabel;
    fSetpointColorPanel1: TPanel;
    pnSetpoint2: TPanel;
    lbSetpointName2: TLabel;
    fSetpointEnabledCheck2: TCheckBox;
    pnSetpointUnit2: TPanel;
    fSetpointThresholdEdit2: TEdit;
    fSetpointAlarmInfoEdit2: TEdit;
    lbSetpointText2_1: TLabel;
    lbSetpointText2_2: TLabel;
    fSetpointColorPanel2: TPanel;
    pnSetpoint3: TPanel;
    lbSetpointName3: TLabel;
    fSetpointEnabledCheck3: TCheckBox;
    pnSetpointUnit3: TPanel;
    fSetpointThresholdEdit3: TEdit;
    fSetpointAlarmInfoEdit3: TEdit;
    lbSetpointText3_1: TLabel;
    lbSetpointText3_2: TLabel;
    fSetpointColorPanel3: TPanel;
    pnSetpointAdd: TPanel;
    lbSetpointAddName: TLabel;
    fSetpointHysteresisCheck: TCheckBox;
    fSetpointStatusChannelCheck: TCheckBox;
    fSetpointSoundCheck: TCheckBox;
    fSetpointRangeControlCheck: TCheckBox;
    fSetpointRangeAlarmInfoEdit: TEdit;
    pnBottom: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    fApplyButton: TButton;
    /// LFM-обработчик OnClick кнопки OK; при создании заменяется на OkButtonClick.
    procedure btnOkClick(Sender: TObject);
    /// LFM-обработчик OnChange флага Auto; рабочая логика назначается через OnClick.
    procedure fAutoUnitCheckChange(Sender: TObject);
    /// OnClick кнопки балансировки запускает операцию для выбранного канала.
    procedure ZeroBalanceButtonClick(Sender: TObject);
    /// OnClick кнопки настройки устройства открывает редактор аппаратного источника.
    procedure HardwareDeviceSetupButtonClick(Sender: TObject);
    /// OnClick кнопки «Градуировка» открывает секундный мастер градуировки тега.
    procedure TagCalibrationButtonClick(Sender: TObject);
  private
    fImages: TCustomImageList;                           // Единый список иконок главной формы
    fCommandImages: TCustomImageList;                    // Список иконок устройства (ilCommandButtons)
    fTagRegistry: TRecorderTagRegistry;                  // Реестр тегов
    fDataSources: TRecorderDataSourceManager;            // Источники и их capabilities
    fSelectedMeraFileName: string;                       // Путь выбранного Mera-файла
    fTags: TList;                                        // Список редактируемых тегов
    fDataUpdateMs: Cardinal;                             // Интервал обновления данных (TRecorderTag)
    fEstimateChecks: array[TRecorderTagEstimateKind] of TCheckBox; // Флаги вычисления различных оценок
    fSetpointColorPanels: array[TRecorderTagSetpointKind] of TPanel; // Цвета отображения для каждой уставки
    fSetpointColorChanged: array[TRecorderTagSetpointKind] of Boolean;
    fSetpointEnabledChecks: array[TRecorderTagSetpointKind] of TCheckBox; // Флаги активности уставок
    fSetpointThresholdEdits: array[TRecorderTagSetpointKind] of TEdit; // Значения порогов уставок
    fSetpointAlarmInfoEdits: array[TRecorderTagSetpointKind] of TEdit; // Тексты событий уставок
    fOnHardwareSourceSetup: TTagHardwareSourceSetupEvent;
    fOnCanZeroBalance: TTagCanZeroBalanceEvent;
    fOnZeroBalance: TTagZeroBalanceEvent;
    
    // Внутренние методы обработчиков UI
    /// OnClick кнопки «Применить» переносит UI в модель, не закрывая диалог.
    procedure ApplyButtonClick(Sender: TObject);
    /// OnDblClick цветовой панели выбирает цвет и отмечает явное изменение.
    procedure SetpointColorDblClick(Sender: TObject);
    /// OnClick кнопки адреса выбирает сигнал и проверяет уникальность привязки.
    procedure AddressButtonClick(Sender: TObject);
    /// OnClick кнопки OK валидирует UI, сохраняет теги и закрывает диалог.
    procedure OkButtonClick(Sender: TObject);
    /// OnClick кнопки выбора канальной ГХ открывает редактор состава pipeline.
    procedure SelectCalibrationButtonClick(Sender: TObject);
    /// OnDblClick поля канальной ГХ выбирает ступень и открывает её свойства.
    procedure ChannelCurveNotebookClick(Sender: TObject);
    /// OnClick кнопки добавления создаёт ГХ и добавляет новую ступень pipeline.
    procedure AddCalibrationButtonClick(Sender: TObject);
    /// OnClick кнопки удаления очищает канальную цепочку выбранных тегов.
    procedure DeleteCalibrationButtonClick(Sender: TObject);
    /// Обработчик OnClick редактирования открывает последнюю ступень pipeline.
    procedure EditCalibrationButtonClick(Sender: TObject);
    /// Редактирует указанную ступень через черновик и фиксирует выбранный вариант.
    procedure EditCalibrationAt(APipelineIndex: Integer);
    /// OnClick кнопки экспорта сохраняет последнюю канальную ГХ в БДГХ.
    procedure ExportCalibrationButtonClick(Sender: TObject);
    /// OnClick кнопки просмотра открывает назначенную аппаратную ГХ.
    procedure SelectHardwareCalibrationButtonClick(Sender: TObject);
    /// OnClick кнопки свойств редактирует назначенную аппаратную ГХ.
    procedure EditHardwareCalibrationButtonClick(Sender: TObject);
    /// Редактирует связанную ГХ через копию и обновляет БДГХ до commit модели.
    function EditLinkedHardwareCalibration(
      ACalibration: TRecorderCalibration): Boolean;
    /// OnClick кнопки выгрузки считывает ГХ из устройств и привязывает их к тегам.
    procedure DownloadHardwareCalibrationFromDeviceClick(Sender: TObject);
    /// Назначает кнопке изображение, подсказку и при необходимости квадратный размер.
    procedure AssignSpeedButtonImage(AButton: TSpeedButton; AImages: TCustomImageList;
      AImageIndex: Integer; const AHint: string = ''; AIconSize: Integer = 0);
    /// Настраивает кнопку команды, используя изображение или текстовый fallback.
    procedure AssignActionSpeedButton(AButton: TSpeedButton; AImages: TCustomImageList;
      AImageIndex: Integer; const ACaption, AHint: string);
    /// Раскладывает кнопки действий устройства с учётом видимости и размеров панели.
    procedure LayoutTagDeviceActionButtons;
    /// Загружает резервную иконку выгрузки ГХ.
    procedure AssignDownloadFlashIcon(AButton: TSpeedButton);
    /// Обновляет текст и доступность элементов канальной цепочки ГХ.
    procedure UpdateChannelCurveText;
    /// Обновляет подпись аппаратной ГХ, не меняя флаг её применения.
    procedure UpdateHardwareCurveText;
    /// Показывает действия аппаратной ГХ только для поддерживаемых источников.
    procedure UpdateHardwareCurveButtons;
    function ResolveSettingsProvider(ATag: TRecorderTag;
      out AProvider: IRecorderTagSettingsProvider): Boolean;
    /// OnClick галки аппаратной ГХ переносит явный выбор в флаг её применения.
    procedure HardwareCurveCheckClick(Sender: TObject);
    /// OnClick внешней галки канальной ГХ меняет общий флаг применения pipeline.
    procedure ChannelCurveCheckClick(Sender: TObject);
    /// OnClick галки Auto меняет только режим единиц и обновляет их список.
    procedure AutoUnitCheckClick(Sender: TObject);
    /// OnDropDown комбобокса единиц актуализирует список перед его раскрытием.
    procedure UnitComboDropDown(Sender: TObject);
    /// OnSelect единицы в Auto меняет UnitOut выходной ГХ, не снимая AutoUnit.
    procedure UnitComboSelect(Sender: TObject);
    /// Строит список единиц по выходу реально применяемой цепочки ГХ.
    procedure RefreshUnitChoices;
    /// OnClick галки оценки синхронизирует набор расчётов и оценку по умолчанию.
    procedure EstimateCheckClick(Sender: TObject);
    /// OnChange списка оценки по умолчанию включает выбранную оценку в расчёт.
    procedure DefaultEstimateComboChange(Sender: TObject);
    /// OnClick кнопки настройки источника вызывает внешний редактор оборудования.
    procedure HardwareSourceSetupButtonClick(Sender: TObject);
    /// Обновляет кнопки настройки и балансировки по возможностям выбранных тегов.
    procedure UpdateTagDeviceActionButtons;
    /// Показывает сведения о выражении только для одиночного виртуального канала.
    procedure UpdateVirtualChannelInfo;
    /// Возвращает UnitOut последней включённой ступени либо применяемой аппаратной ГХ.
    function TryGetChannelCalibrationOutputUnit(ATag: TRecorderTag;
      out AUnitName: string): Boolean;
    function TryGetStrainDeviceExcitation(ATag: TRecorderTag;
      out AExcitation: string): Boolean;
    /// Возвращает последнюю реально применяемую ГХ, задающую выход AutoUnit.
    function FindOutputCalibration(ATag: TRecorderTag): TRecorderCalibration;
    /// Проверяет наличие применяемой ГХ с определённой выходной единицей.
    function SelectedCalibrationEnabled(ATag: TRecorderTag): Boolean;
    /// Возвращает исходную единицу тега до автоматического преобразования ГХ.
    function BaseUnitName(ATag: TRecorderTag): string;
    /// Выбирает AutoUnit по последней применяемой ГХ, не меняя флаги ГХ.
    procedure ApplyAutoUnitFromChannelCalibration;
    /// Проверяет, можно ли открыть настройку источника для текущего выбора тегов.
    function CanConfigureHardwareSource: Boolean;
    /// Проверяет поддержку балансировки единственным выбранным тегом.
    function CanZeroBalance: Boolean;
    
    // Обмен данными между UI и тегами
    /// Заполняет список оценки по умолчанию теми же видами, что показаны галками.
    procedure FillDefaultEstimateChoices;
    /// Заполняет контролы общими значениями тегов, не изменяя модель.
    procedure LoadFromTags;
    /// Валидирует UI и записывает в теги только явно представленные настройки.
    procedure StoreToTags;
    /// Привязывает выбранный Mera-сигнал к текущему тегу и копирует его метаданные.
    procedure ApplyMeraSignalToCurrentTag(const ASourceId: string;
      ASignal: TMeraSignalInfo);
    /// Даёт пользователю выбрать активный Mera-сигнал, ещё не занятый другим тегом.
    function SelectActiveMeraSignal(out ASourceId: string;
      out ASignal: TMeraSignalInfo): Boolean;
    
    // Функции проверки согласованности значений при множественном выборе
    /// Возвращает общее булево состояние тегов либо -1 для смешанного выбора.
    function AllBool(AGetter: Integer): Integer;
    /// Возвращает общее состояние применения канальной цепочки либо -1.
    function AllChannelCalibrationEnabled: Integer;
    /// Читает единое состояние выбранной оценки у всех редактируемых тегов.
    function AllEstimateBool(AKind: TRecorderTagEstimateKind;
      out AValue: Boolean): Boolean;
    /// Возвращает общую оценку по умолчанию, если она одинакова у всех тегов.
    function AllEstimateDefault(out AValue: TRecorderTagEstimateKind): Boolean;
    /// Читает общий служебный флаг расчёта оценки по номеру свойства.
    function AllEstimateFlag(AGetter: Integer; out AValue: Boolean): Boolean;
    /// Читает общее вещественное значение настройки оценки по номеру свойства.
    function AllEstimateFloat(AKind: Integer; out AValue: Double): Boolean;
    /// Возвращает общий целочисленный параметр оценок для множественного выбора.
    function AllEstimateInt(out AValue: Integer): Boolean;
    /// Читает общее вещественное свойство тега по номеру свойства.
    function AllFloat(AKind: Integer; out AValue: Double): Boolean;
    /// Возвращает общий булев параметр указанной уставки.
    function AllSetpointBool(AKind: TRecorderTagSetpointKind;
      AGetter: Integer; out AValue: Boolean): Boolean;
    /// Возвращает общее вещественное значение указанной уставки.
    function AllSetpointFloat(AKind: TRecorderTagSetpointKind;
      AGetter: Integer; out AValue: Double): Boolean;
    /// Возвращает общий текст события указанной уставки.
    function AllSetpointInfoText(AKind: TRecorderTagSetpointKind;
      out AValue: string): Boolean;
    /// Возвращает общий текст тревоги выхода за допустимый диапазон.
    function AllRangeAlarmInfoText(out AValue: string): Boolean;
    /// Читает общий глобальный флаг уставок по номеру свойства.
    function AllSetpointGlobalBool(AGetter: Integer; out AValue: Boolean): Boolean;
    /// Возвращает общее строковое свойство тегов по номеру свойства.
    function AllString(AKind: Integer; out AValue: string): Boolean;
    /// Возвращает общий идентификатор источника выбранных тегов.
    function AllSourceId(out AValue: string): Boolean;
    
    // Дополнительные проверки и чтение чисел
    /// Разрешает ручную частоту только когда источник не диктует её сам.
    function FrequencyCanBeEdited: Boolean;
    /// Проверяет наличие тега с отсутствующим или неподключённым источником.
    function HasDetachedSource: Boolean;
    /// Проверяет, не привязан ли Mera-сигнал к другому тегу реестра.
    function IsSignalAlreadyLinked(const ASourceId: string;
      ASignal: TMeraSignalInfo; AExceptTag: TRecorderTag): Boolean;
    /// Определяет, требуется ли подтверждать активность выбранного источника.
    function SourceNeedsActiveCheck(const ASourceId: string): Boolean;
    /// Разбирает число из UI с поддержкой локального десятичного разделителя.
    function ReadFloat(const AText: string; out AValue: Double): Boolean;
    
    { Быстрое приведение к типу TRecorderTag по индексу }
    /// Возвращает тег из внутреннего нетипизированного списка по индексу.
    function TagAt(AIndex: Integer): TRecorderTag;
  public
    /// После загрузки визуальной LFM-формы связывает runtime-обработчики,
    /// реестр и выбранные теги, затем загружает их общее состояние в контролы.
    constructor CreateDialog(AOwner: TComponent; ATagRegistry: TRecorderTagRegistry;
      ATags: TList; ADataSources: TRecorderDataSourceManager = nil;
      AImages: TCustomImageList = nil; ADataUpdateMs: Cardinal = 200;
      AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent = nil;
      AOnCanZeroBalance: TTagCanZeroBalanceEvent = nil;
      AOnZeroBalance: TTagZeroBalanceEvent = nil;
      ACommandImages: TCustomImageList = nil); reintroduce;
    /// Освобождает принадлежащую диалогу копию списка выбранных тегов.
    destructor Destroy; override;
  end;

/// Показывает модальный редактор тегов; True означает подтверждённое сохранение.
function ShowTagSettingsDialog(AOwner: TComponent; ATagRegistry: TRecorderTagRegistry; ATags: TList; ADataSources: TRecorderDataSourceManager = nil; AImages: TCustomImageList = nil; ADataUpdateMs: Cardinal = 200; AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent = nil; AOnCanZeroBalance: TTagCanZeroBalanceEvent = nil; AOnZeroBalance: TTagZeroBalanceEvent = nil; ACommandImages: TCustomImageList = nil): Boolean;

implementation

const
  CMixedAlarmInfoText = '<разные значения>';

{$R *.lfm}

const
  CTagDialogIconSize = 32;
  CTagDeviceActionBtnSize = 32;
  CTagDeviceActionBtnGap = 4;
  CMeraSourcePrefix = 'Mera file: ';
  CRamOutIconPaths: array[0..2] of string = (
    'D:\works\windev-v3.9\rc_guisrv\res\v3\ico\ram_out.ico',
    'D:\works\windev-v3.9\rc_guisrv\res\ram_out.ico',
    'D:\works\windev-v3.9\images\from_rcguisrv\res\harf_t.ico'
  );

/// Показывает простой модальный список и возвращает подтверждённый индекс строки.
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
  ADataSources: TRecorderDataSourceManager; AImages: TCustomImageList;
  ADataUpdateMs: Cardinal;
  AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent;
  AOnCanZeroBalance: TTagCanZeroBalanceEvent;
  AOnZeroBalance: TTagZeroBalanceEvent;
  ACommandImages: TCustomImageList): Boolean;
var
  lDialog: TTagSettingsDialog;
begin
  lDialog := TTagSettingsDialog.CreateDialog(AOwner, ATagRegistry, ATags,
    ADataSources, AImages,
    ADataUpdateMs, AOnHardwareSourceSetup, AOnCanZeroBalance, AOnZeroBalance,
    ACommandImages);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TTagSettingsDialog.CreateDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager; AImages: TCustomImageList;
  ADataUpdateMs: Cardinal; AOnHardwareSourceSetup: TTagHardwareSourceSetupEvent;
  AOnCanZeroBalance: TTagCanZeroBalanceEvent;
  AOnZeroBalance: TTagZeroBalanceEvent; ACommandImages: TCustomImageList);
var
  lEstimateKind: TRecorderTagEstimateKind;
  lSetpointKind: TRecorderTagSetpointKind;
begin
  inherited Create(AOwner);
  if ATagRegistry = nil then
    raise ERecorderTagError.Create('Tag registry cannot be nil');
  if (ATags = nil) or (ATags.Count = 0) then
    raise ERecorderTagError.Create('No tags selected');

  fTagRegistry := ATagRegistry;
  fDataSources := ADataSources;
  if ACommandImages <> nil then
    fImages := ACommandImages
  else
    fImages := AImages;
  fCommandImages := fImages;
  fOnHardwareSourceSetup := AOnHardwareSourceSetup;
  fOnCanZeroBalance := AOnCanZeroBalance;
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
  FillDefaultEstimateChoices;

  fSetpointEnabledChecks[tskHighAlarm] := fSetpointEnabledCheck0;
  fSetpointEnabledChecks[tskHighWarning] := fSetpointEnabledCheck1;
  fSetpointEnabledChecks[tskLowWarning] := fSetpointEnabledCheck2;
  fSetpointEnabledChecks[tskLowAlarm] := fSetpointEnabledCheck3;

  fSetpointThresholdEdits[tskHighAlarm] := fSetpointThresholdEdit0;
  fSetpointThresholdEdits[tskHighWarning] := fSetpointThresholdEdit1;
  fSetpointThresholdEdits[tskLowWarning] := fSetpointThresholdEdit2;
  fSetpointThresholdEdits[tskLowAlarm] := fSetpointThresholdEdit3;

  fSetpointAlarmInfoEdits[tskHighAlarm] := fSetpointAlarmInfoEdit0;
  fSetpointAlarmInfoEdits[tskHighWarning] := fSetpointAlarmInfoEdit1;
  fSetpointAlarmInfoEdits[tskLowWarning] := fSetpointAlarmInfoEdit2;
  fSetpointAlarmInfoEdits[tskLowAlarm] := fSetpointAlarmInfoEdit3;

  fSetpointColorPanels[tskHighAlarm] := fSetpointColorPanel0;
  fSetpointColorPanels[tskHighWarning] := fSetpointColorPanel1;
  fSetpointColorPanels[tskLowWarning] := fSetpointColorPanel2;
  fSetpointColorPanels[tskLowAlarm] := fSetpointColorPanel3;
  for lSetpointKind := Low(TRecorderTagSetpointKind) to
    High(TRecorderTagSetpointKind) do
  begin
    fSetpointColorPanels[lSetpointKind].Cursor := crHandPoint;
    fSetpointColorPanels[lSetpointKind].Hint :=
      'Двойной щелчок — выбрать цвет';
    fSetpointColorPanels[lSetpointKind].ShowHint := True;
    fSetpointColorPanels[lSetpointKind].Tag := Ord(lSetpointKind);
    fSetpointColorPanels[lSetpointKind].OnDblClick := @SetpointColorDblClick;
    fSetpointColorChanged[lSetpointKind] := False;
  end;
  fAddressButton.OnClick := @AddressButtonClick;
  fChannelCurveSelectBtn.OnClick := @SelectCalibrationButtonClick;
  fChannelCurveEdit.OnDblClick := @ChannelCurveNotebookClick;
  fChannelCurveAddBtn.OnClick := @AddCalibrationButtonClick;
  fChannelCurveDeleteBtn.OnClick := @DeleteCalibrationButtonClick;
  fChannelCurveEditBtn.OnClick := @ExportCalibrationButtonClick;
  fHardwareCurveSelectBtn.OnClick := @SelectHardwareCalibrationButtonClick;
  fHardwareCurveSetupBtn.OnClick := @EditHardwareCalibrationButtonClick;
  fHardwareCurveDownloadBtn.OnClick := @DownloadHardwareCalibrationFromDeviceClick;
  fHardwareCurveCheck.OnClick := @HardwareCurveCheckClick;
  fChannelCurveCheck.OnClick := @ChannelCurveCheckClick;
  fAutoUnitCheck.OnClick := @AutoUnitCheckClick;
  fUnitCombo.OnDropDown := @UnitComboDropDown;
  fUnitCombo.OnSelect := @UnitComboSelect;
  btnOk.OnClick := @OkButtonClick;
  fApplyButton.OnClick := @ApplyButtonClick;
  { Назначаем runtime-обработчики явно: кнопки панели устройства могли быть
    перенесены в LFM, но первый щелчок не должен зависеть от LFM-привязки. }
  fZeroBalanceBtn.OnClick := @ZeroBalanceButtonClick;
  fHardwareDeviceSetupBtn.OnClick := @HardwareDeviceSetupButtonClick;

  AssignSpeedButtonImage(fAddressButton, fImages, CIconAddress);
  AssignSpeedButtonImage(fDescriptionEditBtn, fImages, CIconEdit);
  AssignSpeedButtonImage(fHardwareCurveSelectBtn, fImages, CIconProperty);
  AssignSpeedButtonImage(fHardwareCurveSetupBtn, fImages, CIconHardwareCurve);
  AssignSpeedButtonImage(fHardwareCurveDownloadBtn, fCommandImages,
    CIconHardwareCurveRead, 'Выгрузка из памяти ГХ');
  if (fHardwareCurveDownloadBtn <> nil) and (fHardwareCurveDownloadBtn.Images = nil) then
    AssignDownloadFlashIcon(fHardwareCurveDownloadBtn);
  AssignSpeedButtonImage(fChannelCurveSelectBtn, fImages, CIconProperty,
    'Настроить цепочку ГХ');
  fChannelCurveEdit.Hint := 'Двойной щелчок — редактировать выбранную ГХ';
  fChannelCurveEdit.ShowHint := True;
  AssignSpeedButtonImage(fChannelCurveAddBtn, fImages, CIconAdd);
  AssignSpeedButtonImage(fChannelCurveDeleteBtn, fImages, CIconRemove);
  AssignSpeedButtonImage(fChannelCurveEditBtn, fImages, CIconChannelCurve,
    'Экспорт текущей ГХ в БДГХ');
  AssignSpeedButtonImage(fZeroBalanceBtn, fCommandImages, CIconZeroBalance,
    'Балансировка нуля');
  AssignSpeedButtonImage(fHardwareDeviceSetupBtn, fCommandImages,
    CIconHardwareSource, 'Настройка аппаратной части');
  LayoutTagDeviceActionButtons;
  LoadFromTags;
  fDefaultEstimateCombo.OnChange := @DefaultEstimateComboChange;
end;

procedure TTagSettingsDialog.FillDefaultEstimateChoices;
var
  lKind: TRecorderTagEstimateKind;
  lCaption: string;
begin
  fDefaultEstimateCombo.Items.BeginUpdate;
  try
    fDefaultEstimateCombo.Items.Clear;
    for lKind := Low(TRecorderTagEstimateKind) to
      tekPeakToPeakByRmsDeviation do
    begin
      lCaption := StringReplace(fEstimateChecks[lKind].Caption,
        ' precision: default', '', []);
      fDefaultEstimateCombo.Items.AddObject(lCaption, TObject(PtrInt(lKind)));
    end;
  finally
    fDefaultEstimateCombo.Items.EndUpdate;
  end;
end;

destructor TTagSettingsDialog.Destroy;
begin
  fTags.Free;
  inherited Destroy;
end;


procedure TTagSettingsDialog.AssignSpeedButtonImage(AButton: TSpeedButton;
  AImages: TCustomImageList; AImageIndex: Integer; const AHint: string;
  AIconSize: Integer);
var
  lIconSize: Integer;
begin
  if (AButton = nil) or (AImages = nil) or (AImageIndex < 0) or
    (AImageIndex >= AImages.Count) then
    Exit;
  if AIconSize > 0 then
    lIconSize := AIconSize
  else
    lIconSize := CTagDialogIconSize;
  AButton.Images := AImages;
  AButton.ImageIndex := AImageIndex;
  AButton.ImageWidth := lIconSize;
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
  I: Integer;
  lBool: Integer;
begin
  if fTags.Count = 0 then
    Exit;
  fChannelCurveEdit.Text := '';
  for I := TagAt(0).CalibrationNames.Count - 1 downto 0 do
    if RecorderCalibrationStepEnabled(TagAt(0).CalibrationNames, I) then
    begin
      fChannelCurveEdit.Text := TagAt(0).CalibrationNames[I];
      Break;
    end;
  lBool := AllChannelCalibrationEnabled;
  fChannelCurveCheck.AllowGrayed := fTags.Count > 1;
  if lBool < 0 then
    fChannelCurveCheck.State := cbGrayed
  else
    fChannelCurveCheck.Checked := lBool > 0;
  fChannelCalibrateBtn.Enabled := fTags.Count = 1;
end;

procedure TTagSettingsDialog.TagCalibrationButtonClick(Sender: TObject);
var
  lDraft: TRecorderCalibration;
  lError: string;
  lOriginal: TRecorderCalibration;
  lTag: TRecorderTag;
  lTarget: TRecorderTagCalibrationTarget;
  lEstimateKind: TRecorderTagEstimateKind;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Градуировка',
      'Градуировка доступна только для одного выбранного тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  lTag := TagAt(0);
  lDraft := nil;
  if not ShowRecorderTagCalibrationDialog(Self, fTagRegistry, lTag,
    lDraft, lOriginal, lTarget, lEstimateKind) then
    Exit;
  try
    if lTarget = rtctLastNode then
    begin
      if not RecorderSdbUpdateLinkedCalibration(lOriginal, lDraft, lError) then
      begin
        MessageDlg('Градуировка',
          'Не удалось обновить связанную ГХ в БДГХ:' + LineEnding + lError,
          mtError, [mbOK], 0);
        Exit;
      end;
      if not fTagRegistry.CommitCalibrationEdit(lOriginal, lDraft) then
      begin
        MessageDlg('Градуировка', 'Не удалось сохранить скорректированную ГХ.',
          mtError, [mbOK], 0);
        Exit;
      end;
    end
    else
    begin
      fTagRegistry.Calibrations.Add(lDraft);
      lTag.CalibrationNames.Clear;
      lTag.CalibrationNames.Add(lDraft.Name);
      { Нажатие пользователем «OK» в мастере является явным включением только
        что созданной сквозной ГХ; фоновые загрузчики флаг не меняют. }
      lTag.ChannelCalibrationEnabled := True;
      lDraft := nil;
    end;
    lTag.InvalidateCalibrationScale;
    fTagRegistry.SyncTagAutoUnit(lTag);
    fTagRegistry.RebuildScales(lTag);
    lTag.ClearSignalHistory;
    UpdateChannelCurveText;
    RefreshUnitChoices;
  finally
    lDraft.Free;
  end;
end;

function TTagSettingsDialog.TryGetStrainDeviceExcitation(ATag: TRecorderTag;
  out AExcitation: string): Boolean;
begin
  Result := False;
  AExcitation := '';
end;

procedure TTagSettingsDialog.UpdateHardwareCurveText;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lFirstEnabled: Boolean;
  lFirstName: string;
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
  lSameEnabled: Boolean;
  lSameName: Boolean;
begin
  if fTags.Count = 0 then
    Exit;

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
  fHardwareCurveEdit.Text := lFirstName;
  if (fTags.Count = 1) and ResolveSettingsProvider(TagAt(0), lProvider) then
  begin
    RecorderInitTagSettingsState(lState);
    if lProvider.ReadState(fTagRegistry, TagAt(0), lState) and
      (Trim(lState.HardwareCalibrationText) <> '') then
      fHardwareCurveEdit.Text := lState.HardwareCalibrationText;
  end;
end;

procedure TTagSettingsDialog.HardwareCurveCheckClick(Sender: TObject);
begin
  { При множественном выборе cbGrayed означает разные исходные значения.
    Первый явный щелчок должен стать общей командой «включить», иначе LCL
    оставляет промежуточное состояние и StoreToTags пропускает все теги. }
  if fHardwareCurveCheck.State = cbGrayed then
    fHardwareCurveCheck.State := cbChecked;
  fHardwareCurveCheck.AllowGrayed := False;
  ApplyAutoUnitFromChannelCalibration;
  RefreshUnitChoices;
end;

procedure TTagSettingsDialog.ChannelCurveCheckClick(Sender: TObject);
begin
  if fChannelCurveCheck.State = cbGrayed then
    fChannelCurveCheck.State := cbChecked;
  fChannelCurveCheck.AllowGrayed := False;
  { Внешняя галка — единственное управление всей канальной цепочкой.
    Сразу перестраиваем категорию и текущее значение combo по её состоянию. }
  AutoUnitCheckClick(fAutoUnitCheck);
end;

function TTagSettingsDialog.TagAt(AIndex: Integer): TRecorderTag;
begin
  Result := TRecorderTag(fTags[AIndex]);
end;

function TTagSettingsDialog.ResolveSettingsProvider(ATag: TRecorderTag;
  out AProvider: IRecorderTagSettingsProvider): Boolean;
begin
  Result := RecorderResolveTagSettingsProvider(ATag, fDataSources, AProvider);
end;

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

function TTagSettingsDialog.AllSetpointInfoText(
  AKind: TRecorderTagSetpointKind; out AValue: string): Boolean;
var
  I: Integer;
begin
  AValue := TagAt(0).Setpoints[AKind].AlarmInfoText;
  for I := 1 to fTags.Count - 1 do
    if AValue <> TagAt(I).Setpoints[AKind].AlarmInfoText then
      Exit(False);
  Result := True;
end;

function TTagSettingsDialog.AllRangeAlarmInfoText(out AValue: string): Boolean;
var
  I: Integer;
begin
  AValue := TagAt(0).SetpointRangeAlarmInfoText;
  for I := 1 to fTags.Count - 1 do
    if AValue <> TagAt(I).SetpointRangeAlarmInfoText then
      Exit(False);
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
  { Сигнал задаёт исходную единицу. Результирующую единицу после ГХ
    вычисляет registry, не меняя пользовательские галки применения. }
  lTag.SourceUnitName := ASignal.UnitsName;
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
  lTag: TRecorderTag;
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
begin
  Result := False;
  if fTags.Count <> 1 then
    Exit;
  lTag := TagAt(0);
  if ResolveSettingsProvider(lTag, lProvider) then
  begin
    RecorderInitTagSettingsState(lState);
    if lProvider.ReadState(fTagRegistry, lTag, lState) and
      lState.HardwareSourceConfigurable then
      Exit(True);
  end;
  Result := Pos(CMeraSourcePrefix, lTag.SourceId) = 1;
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
begin
  Result := Assigned(fOnCanZeroBalance) and
    fOnCanZeroBalance(Self, fTagRegistry, fTags);
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
var
  lTag: TRecorderTag;
  lUnitName: string;
begin
  if not CanZeroBalance then
    Exit;
  { Балансировка может быть запущена до OK/Apply. Диалог фиксирует
    только общую модель единицы; её аппаратную интерпретацию выполняет
    конкретный datasource в ZeroBalanceTags. }
  if fTags.Count = 1 then
  begin
    lTag := TagAt(0);
    lUnitName := Trim(fUnitCombo.Text);
    if lUnitName <> '' then
    begin
      lTag.SourceUnitName := lUnitName;
      if not lTag.AutoUnit then
        lTag.UnitName := lUnitName;
    end;
  end;
  if fOnZeroBalance <> nil then
    fOnZeroBalance(Self, fTagRegistry, fTags);
end;

procedure TTagSettingsDialog.fAutoUnitCheckChange(Sender: TObject);
begin

end;

procedure TTagSettingsDialog.btnOkClick(Sender: TObject);
begin

end;

procedure TTagSettingsDialog.HardwareDeviceSetupButtonClick(Sender: TObject);
begin
  HardwareSourceSetupButtonClick(Sender);
end;

procedure TTagSettingsDialog.HardwareSourceSetupButtonClick(Sender: TObject);
var
  lDialog: TOpenDialog;
  lNewSourceId: string;
  lOldSourceId: string;
  lPath: string;
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
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
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
  if (fTags.Count = 1) and ResolveSettingsProvider(TagAt(0), lProvider) then
  begin
    RecorderInitTagSettingsState(lState);
    if lProvider.ReadState(fTagRegistry, TagAt(0), lState) and
      (Trim(lState.OutputUnitName) <> '') then
      fUnitCombo.Text := lState.OutputUnitName;
  end;
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
  ApplyAutoUnitFromChannelCalibration;
  RefreshUnitChoices;
  UpdateHardwareCurveButtons;
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

    if AllSetpointInfoText(lSetpointKind, lText) then
      fSetpointAlarmInfoEdits[lSetpointKind].Text := lText
    else
      fSetpointAlarmInfoEdits[lSetpointKind].Text := CMixedAlarmInfoText;

    fSetpointColorPanels[lSetpointKind].Color :=
      TColor(TagAt(0).Setpoints[lSetpointKind].Color);
    fSetpointColorChanged[lSetpointKind] := False;
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
  if AllRangeAlarmInfoText(lText) then
    fSetpointRangeAlarmInfoEdit.Text := lText
  else
    fSetpointRangeAlarmInfoEdit.Text := CMixedAlarmInfoText;
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
  lProvider: IRecorderTagSettingsProvider;
  lDraft: TRecorderTagSettingsDraft;
  lApplyResult: TRecorderTagSettingsApplyResult;
  lErrorText: string;
  lPreviousFrequency: Double;
  lPreviousUnitName: string;
  lPreviousSourceUnitName: string;
  lPreviousAutoUnit: Boolean;
  lPreviousHardwareEnabled: Boolean;
  lPreviousChannelEnabled: Boolean;
  lHardwareChanged: Boolean;
  lChannelChanged: Boolean;
  lRuntimeTransformChanged: Boolean;
begin
  if fNameEdit.Enabled and (Trim(fNameEdit.Text) <> '') then
  begin
    lExisting := fTagRegistry.FindByName(Trim(fNameEdit.Text));
    if (lExisting <> nil) and (lExisting <> TagAt(0)) then
      raise ERecorderTagError.Create('Tag name already exists: ' + Trim(fNameEdit.Text));
    if not fTagRegistry.RenameTag(TagAt(0), Trim(fNameEdit.Text)) then
      raise ERecorderTagError.Create('Invalid tag name');
  end;

  for I := 0 to fTags.Count - 1 do
    begin
      lTag := TagAt(I);
      lPreviousFrequency := lTag.PollFrequencyHz;
      lPreviousUnitName := lTag.UnitName;
      lPreviousSourceUnitName := lTag.SourceUnitName;
      lPreviousAutoUnit := lTag.AutoUnit;
      lPreviousHardwareEnabled := lTag.HardwareCalibrationEnabled;
      lPreviousChannelEnabled := lTag.ChannelCalibrationEnabled;
      lTag.InvalidateCalibrationScale;
      lHardwareChanged := False;
      lChannelChanged := False;
      lRuntimeTransformChanged := False;
    if fSelectedMeraFileName <> '' then
    begin
      lTag.Address := Trim(fModuleEdit.Text);
      lTag.SourceId := 'Mera file: ' + fSelectedMeraFileName;
      lTag.IsVirtual := True;
    end;
    { При Auto единица в combo уже является выходом последней ГХ. Не записываем
      её обратно как исходную единицу канала: SourceUnitName нужен сборщику
      коэффициента для перехода, например V -> mV. }
    if (Trim(fUnitCombo.Text) <> '') and
      not ((fAutoUnitCheck.State = cbChecked) and
      SelectedCalibrationEnabled(lTag)) then
      lTag.UnitName := Trim(fUnitCombo.Text);
    if (fTags.Count = 1) or (Trim(fDescriptionEdit.Text) <> '') then
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
    if fHardwareCurveCheck.State <> cbGrayed then
    begin
      lHardwareChanged := lTag.HardwareCalibrationEnabled <>
        fHardwareCurveCheck.Checked;
      lTag.HardwareCalibrationEnabled := fHardwareCurveCheck.Checked;
    end;
    { Calibration assignment itself is changed only by explicit actions. }
    if fChannelCurveCheck.State <> cbGrayed then
    begin
      lChannelChanged := lTag.ChannelCalibrationEnabled <>
        fChannelCurveCheck.Checked;
      lTag.ChannelCalibrationEnabled := fChannelCurveCheck.Checked;
    end;
    if ResolveSettingsProvider(lTag, lProvider) then
    begin
      RecorderInitTagSettingsDraft(lTag, fDataUpdateMs, lDraft);
      lDraft.PollFrequencyHz := lTag.PollFrequencyHz;
      if Trim(fUnitCombo.Text) <> '' then
        lDraft.UnitName := Trim(fUnitCombo.Text)
      else
        lDraft.UnitName := lTag.UnitName;
      lDraft.AutoUnit := lTag.AutoUnit;
      lDraft.HardwareCalibrationEnabled := lTag.HardwareCalibrationEnabled;
      lDraft.ChannelCalibrationEnabled := lTag.ChannelCalibrationEnabled;
      { Provider сравнивает draft с прежним значением и сам применяет
        source-wide/slot-wide семантику частоты. }
      lTag.PollFrequencyHz := lPreviousFrequency;
      lTag.UnitName := lPreviousUnitName;
      lTag.SourceUnitName := lPreviousSourceUnitName;
      lTag.AutoUnit := lPreviousAutoUnit;
      lTag.HardwareCalibrationEnabled := lPreviousHardwareEnabled;
      lTag.ChannelCalibrationEnabled := lPreviousChannelEnabled;
      if not lProvider.NormalizeDraft(fTagRegistry, lTag, lDraft, lErrorText) then
        raise ERecorderTagError.Create(lErrorText);
      RecorderInitTagSettingsApplyResult(lApplyResult);
      if not lProvider.ApplyDraft(fTagRegistry, lTag, lDraft, lApplyResult,
        lErrorText) then
        raise ERecorderTagError.Create(lErrorText);
      if lApplyResult.UnitChanged then lTag.UnitName := lApplyResult.UnitName;
      if lApplyResult.SourceUnitChanged then
        lTag.SourceUnitName := lApplyResult.SourceUnitName;
      if lApplyResult.FrequencyChanged then
        lTag.PollFrequencyHz := lApplyResult.PollFrequencyHz;
      if not lApplyResult.FrequencyChanged then
        lTag.PollFrequencyHz := lDraft.PollFrequencyHz;
      if lApplyResult.RangeChanged then
      begin
        lTag.RangeMin := lApplyResult.RangeMin;
        lTag.RangeMax := lApplyResult.RangeMax;
      end;
      lRuntimeTransformChanged := lRuntimeTransformChanged or
        lApplyResult.SignalHistoryMustBeCleared;
      lTag.AutoUnit := lDraft.AutoUnit;
      lTag.HardwareCalibrationEnabled := lDraft.HardwareCalibrationEnabled;
      lTag.ChannelCalibrationEnabled := lDraft.ChannelCalibrationEnabled;
      lRuntimeTransformChanged := lRuntimeTransformChanged or
        lApplyResult.SourceUnitChanged or lApplyResult.UnitChanged or
        lHardwareChanged or lChannelChanged;
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
      if fSetpointAlarmInfoEdits[lSetpointKind].Text <> CMixedAlarmInfoText then
        lSetpoint.AlarmInfoText := Trim(
          fSetpointAlarmInfoEdits[lSetpointKind].Text);
      if fSetpointColorChanged[lSetpointKind] then
        lSetpoint.Color := LongInt(fSetpointColorPanels[lSetpointKind].Color);
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
    if fSetpointRangeAlarmInfoEdit.Text <> CMixedAlarmInfoText then
      lTag.SetpointRangeAlarmInfoText := Trim(fSetpointRangeAlarmInfoEdit.Text);
    if lTag.AutoUnit then
      fTagRegistry.SyncTagAutoUnit(lTag);
    fTagRegistry.RebuildScales(lTag);
    lRuntimeTransformChanged := lRuntimeTransformChanged or
      not SameText(lPreviousUnitName, lTag.UnitName) or
      not SameText(lPreviousSourceUnitName, lTag.SourceUnitName) or
      (lPreviousAutoUnit <> lTag.AutoUnit) or
      (lPreviousHardwareEnabled <> lTag.HardwareCalibrationEnabled) or
      (lPreviousChannelEnabled <> lTag.ChannelCalibrationEnabled);
    if lRuntimeTransformChanged then
      lTag.ClearSignalHistory;
    if lRuntimeTransformChanged and (fDataSources <> nil) then
      fDataSources.RefreshSourceRuntimeTransforms(lTag.SourceId);
  end;
end;

procedure TTagSettingsDialog.ApplyButtonClick(Sender: TObject);
begin
  StoreToTags;
  LoadFromTags;
end;

procedure TTagSettingsDialog.SetpointColorDblClick(Sender: TObject);
var
  lColorDialog: TColorDialog;
  lKind: TRecorderTagSetpointKind;
  lPanel: TPanel;
begin
  if not (Sender is TPanel) then
    Exit;
  lPanel := TPanel(Sender);
  if (lPanel.Tag < Ord(Low(TRecorderTagSetpointKind))) or
    (lPanel.Tag > Ord(High(TRecorderTagSetpointKind))) then
    Exit;
  lKind := TRecorderTagSetpointKind(lPanel.Tag);
  lColorDialog := TColorDialog.Create(Self);
  try
    lColorDialog.Color := lPanel.Color;
    if lColorDialog.Execute then
    begin
      lPanel.Color := lColorDialog.Color;
      fSetpointColorChanged[lKind] := True;
    end;
  finally
    lColorDialog.Free;
  end;
end;

procedure TTagSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToTags;
  ModalResult := mrOk;
end;


procedure TTagSettingsDialog.SelectCalibrationButtonClick(Sender: TObject);
var
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
begin
  if fTags.Count <> 1 then
  begin
    MessageDlg('Канальная ГХ',
      'Выбор ГХ из списка поддерживается только для одного значения тега.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if ResolveSettingsProvider(TagAt(0), lProvider) and
    lProvider.ReadState(fTagRegistry, TagAt(0), lState) and
    not lState.ChannelCalibrationSelectable then
  begin
    MessageDlg('Канальная ГХ',
      'Канальная ГХ настраивается средствами выбранного источника.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if ShowRecorderCalibrationPipelineDialog(Self, fTagRegistry.Calibrations,
    TagAt(0).CalibrationNames) then
  begin
    TagAt(0).InvalidateCalibrationScale;
    AutoUnitCheckClick(fAutoUnitCheck);
    UpdateChannelCurveText;
  end;
end;

function TTagSettingsDialog.TryGetChannelCalibrationOutputUnit(
  ATag: TRecorderTag; out AUnitName: string): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
begin
  AUnitName := '';
  Result := False;
  if (ATag = nil) or (fTagRegistry = nil) then
    Exit;

  if (fChannelCurveCheck.State = cbChecked) and
    (ATag.CalibrationNames <> nil) then
    for I := ATag.CalibrationNames.Count - 1 downto 0 do
    begin
      if not RecorderCalibrationStepEnabled(ATag.CalibrationNames, I) then
        Continue;
      lCalibration := fTagRegistry.FindCalibrationByName(
        ATag.CalibrationNames[I]);
      if (lCalibration <> nil) and (Trim(lCalibration.UnitOut) <> '') then
      begin
        AUnitName := Trim(lCalibration.UnitOut);
        Exit(True);
      end;
    end;

  if ResolveSettingsProvider(ATag, lProvider) and
    lProvider.ReadState(fTagRegistry, ATag, lState) then
  begin
    AUnitName := Trim(lState.OutputUnitName);
    if Trim(AUnitName) = '' then
      AUnitName := Trim(lState.SourceUnitName);
    if Trim(AUnitName) <> '' then
      Exit(True);
  end;

  if fHardwareCurveCheck.State <> cbChecked then
    Exit;
  lCalibration := fTagRegistry.FindCalibrationByName(
    ATag.HardwareCalibrationName);
  if (lCalibration <> nil) and (Trim(lCalibration.UnitOut) <> '') then
  begin
    AUnitName := Trim(lCalibration.UnitOut);
    Result := True;
  end;
end;

function TTagSettingsDialog.FindOutputCalibration(
  ATag: TRecorderTag): TRecorderCalibration;
var
  I: Integer;
begin
  Result := nil;
  if (ATag = nil) or (fTagRegistry = nil) then
    Exit;

  if (fChannelCurveCheck.State = cbChecked) and
    (ATag.CalibrationNames <> nil) then
    for I := ATag.CalibrationNames.Count - 1 downto 0 do
    begin
      if not RecorderCalibrationStepEnabled(ATag.CalibrationNames, I) then
        Continue;
      Result := fTagRegistry.FindCalibrationByName(ATag.CalibrationNames[I]);
      if Result <> nil then
        Exit;
    end;

  if fHardwareCurveCheck.State = cbChecked then
    Result := fTagRegistry.FindCalibrationByName(
      ATag.HardwareCalibrationName);
end;

function TTagSettingsDialog.SelectedCalibrationEnabled(
  ATag: TRecorderTag): Boolean;
var
  lUnitName: string;
begin
  Result := TryGetChannelCalibrationOutputUnit(ATag, lUnitName);
end;

function TTagSettingsDialog.BaseUnitName(ATag: TRecorderTag): string;
begin
  Result := '';
  if ATag = nil then
    Exit;
  Result := Trim(ATag.SourceUnitName);
  if Result = '' then
    Result := Trim(ATag.UnitName);
end;

procedure TTagSettingsDialog.ApplyAutoUnitFromChannelCalibration;
var
  lUnitName: string;
begin
  if (fAutoUnitCheck.State <> cbChecked) or (fTags.Count <> 1) then
    Exit;
  { Предпросмотр берёт состояние checkbox диалога, ещё не
    сохранённое в тег. Базовую SourceUnitName не изменяем. }
  if TryGetChannelCalibrationOutputUnit(TagAt(0), lUnitName) then
    fUnitCombo.Text := lUnitName;
end;

procedure TTagSettingsDialog.RefreshUnitChoices;
var
  lAllUnits: TStringList;
  lOutputUnit: string;
  lOutputInfo: TRecorderUnitInfo;
  lCandidateInfo: TRecorderUnitInfo;
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
  I: Integer;
begin
  if fUnitCombo = nil then
    Exit;

  lAllUnits := TStringList.Create;
  try
    RecorderUnitManager.FillUnitNames(lAllUnits);
    fUnitCombo.Items.BeginUpdate;
    try
      fUnitCombo.Items.Clear;
      { При включённой ГХ ручная единица описывает уже физический выход
        цепочки. Категорию задаёт UnitOut последней канальной ГХ; если
        канальной цепочки нет — UnitOut аппаратной ГХ. }
      if (fTags.Count = 1) and (fAutoUnitCheck.State = cbChecked) and
        TryGetChannelCalibrationOutputUnit(TagAt(0), lOutputUnit) and
        RecorderUnitManager.TryGetUnitInfo(lOutputUnit, lOutputInfo) then
      begin
        for I := 0 to lAllUnits.Count - 1 do
          if RecorderUnitManager.TryGetUnitInfo(lAllUnits[I], lCandidateInfo) and
            SameText(lCandidateInfo.QuantityId, lOutputInfo.QuantityId) then
            fUnitCombo.Items.Add(lAllUnits[I]);
      end
      else if (fTags.Count = 1) and ResolveSettingsProvider(TagAt(0), lProvider) and
        lProvider.ReadState(fTagRegistry, TagAt(0), lState) and
        (Length(lState.UnitNames) > 0) then
      begin
        for I := 0 to High(lState.UnitNames) do
          fUnitCombo.Items.Add(lState.UnitNames[I]);
      end
      else
      begin
        { Без активной ГХ сохраняем общий выбор, включая служебные единицы. }
        fUnitCombo.Items.Add('-');
        fUnitCombo.Items.Add('a.u.');
        fUnitCombo.Items.Add('code');
        fUnitCombo.Items.AddStrings(lAllUnits);
      end;
    finally
      fUnitCombo.Items.EndUpdate;
    end;
  finally
    lAllUnits.Free;
  end;
end;

procedure TTagSettingsDialog.UnitComboDropDown(Sender: TObject);
begin
  RefreshUnitChoices;
end;

procedure TTagSettingsDialog.UnitComboSelect(Sender: TObject);
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lOutputUnit: string;
  lSelectedInfo: TRecorderUnitInfo;
  lOutputInfo: TRecorderUnitInfo;
begin
  if (fTags.Count <> 1) or (Trim(fUnitCombo.Text) = '') then
    Exit;

  { При активной ГХ список уже отфильтрован по физической величине;
    дополнительная проверка не даёт editable-combobox случайно сменить
    категорию единиц. }
  if TryGetChannelCalibrationOutputUnit(TagAt(0), lOutputUnit) and
    RecorderUnitManager.TryGetUnitInfo(lOutputUnit, lOutputInfo) then
  begin
    if not RecorderUnitManager.TryGetUnitInfo(fUnitCombo.Text,
      lSelectedInfo) or not SameText(lSelectedInfo.QuantityId,
      lOutputInfo.QuantityId) then
    begin
      fUnitCombo.Text := lOutputUnit;
      Exit;
    end;
  end;

  if fAutoUnitCheck.State = cbChecked then
  begin
    { В Auto выбранная пользователем совместимая единица становится UnitOut
      выходной ГХ. ConvertOutputUnit одновременно пересчитывает коэффициенты,
      поэтому физическое преобразование остаётся тем же. }
    lCalibration := FindOutputCalibration(TagAt(0));
    if (lCalibration <> nil) and
      lCalibration.ConvertOutputUnit(Trim(fUnitCombo.Text)) then
    begin
      for I := 0 to fTagRegistry.TagCount - 1 do
        fTagRegistry.RebuildScales(fTagRegistry.Tags[I]);
      UpdateChannelCurveText;
      UpdateHardwareCurveText;
      Exit;
    end;
  end;

  fAutoUnitCheck.AllowGrayed := False;
  fAutoUnitCheck.Checked := False;
end;

procedure TTagSettingsDialog.AutoUnitCheckClick(Sender: TObject);
var
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
  lOutputUnit: string;
  lCurrentInfo: TRecorderUnitInfo;
  lOutputInfo: TRecorderUnitInfo;
begin
  if fAutoUnitCheck.State = cbUnchecked then
  begin
    if fTags.Count = 1 then
    begin
      { Auto управляет только выбором единицы отображения и не переключает ГХ.
        При активной цепочке оставляем ручной выбор в категории её выхода. }
      if TryGetChannelCalibrationOutputUnit(TagAt(0), lOutputUnit) and
        RecorderUnitManager.TryGetUnitInfo(lOutputUnit, lOutputInfo) then
      begin
        if not (RecorderUnitManager.TryGetUnitInfo(fUnitCombo.Text,
          lCurrentInfo) and SameText(lCurrentInfo.QuantityId,
          lOutputInfo.QuantityId)) then
          fUnitCombo.Text := lOutputInfo.BaseUnitName;
      end
      else
        fUnitCombo.Text := BaseUnitName(TagAt(0));
      RefreshUnitChoices;
    end;
    Exit;
  end;
  if (fAutoUnitCheck.State = cbChecked) and (fTags.Count = 1) and
    ResolveSettingsProvider(TagAt(0), lProvider) and
    lProvider.ReadState(fTagRegistry, TagAt(0), lState) and
    (Trim(lState.OutputUnitName) <> '') then
  begin
    fUnitCombo.Text := lState.OutputUnitName;
    RefreshUnitChoices;
    Exit;
  end;
  ApplyAutoUnitFromChannelCalibration;
  RefreshUnitChoices;
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
      TagAt(I).CalibrationNames.Add(lCalibrationName);
    end;
    ApplyAutoUnitFromChannelCalibration;
    UpdateChannelCurveText;
    Exit;
  end;

  lCalibration := TRecorderCalibration.Create(lKind);
  try
    lCalibration.Name := 'ГХ ' + IntToStr(fTagRegistry.Calibrations.Count + 1);
    if lKind in [rckPiecewiseLinear, rckPolynomial] then
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
    TagAt(I).CalibrationNames.Add(lCalibration.Name);
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
    TagAt(I).CalibrationNames.Clear;
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
  lError: string;
  lExisting: TRecorderCalibration;
  lExcitation: string;
  lName: string;
  lChoice: TModalResult;
  lSavePrompt: string;
  lSdbKey: string;
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

    if Trim(lCalibration.SdbKey) <> '' then
      lSavePrompt := 'Да — обновить исходную ГХ в БДГХ и во всех тегах.'
    else
      lSavePrompt := 'Да — изменить общую ГХ для всех тегов, которые её используют.';
    lChoice := MessageDlg('Сохранение канальной ГХ',
      lSavePrompt + LineEnding +
      'Нет — создать отдельную локальную копию только для текущего тега.' + LineEnding +
      'Отмена — не применять изменения.', mtConfirmation,
      [mbYes, mbNo, mbCancel], 0);
    try
      case lChoice of
        mrYes:
          begin
            if Trim(lDraft.Name) = '' then
            begin
              MessageDlg('Сохранение канальной ГХ',
                'Имя ГХ не может быть пустым.', mtError, [mbOK], 0);
              Exit;
            end;
            lExisting := fTagRegistry.FindCalibrationByName(Trim(lDraft.Name));
            if (lExisting <> nil) and (lExisting <> lCalibration) then
            begin
              MessageDlg('Сохранение канальной ГХ',
                'ГХ с именем «' + Trim(lDraft.Name) +
                '» уже существует.', mtError, [mbOK], 0);
              Exit;
            end;
            lSdbKey := Trim(lCalibration.SdbKey);
            if not RecorderSdbUpdateLinkedCalibration(lCalibration,
              lDraft, lError) then
            begin
              MessageDlg('Сохранение канальной ГХ',
                'Не удалось обновить ГХ в БДГХ:' + LineEnding + lError,
                mtError, [mbOK], 0);
              Exit;
            end;
            fTagRegistry.CommitCalibrationEdit(lCalibration, lDraft);
            { CommitCalibrationEdit normally turns an edited calibration into
              a local one.  A successful in-place SDB update keeps the link. }
            if lSdbKey <> '' then
              lCalibration.SdbKey := lSdbKey;
          end;
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
    if EditLinkedHardwareCalibration(lCalibration) then
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

  if EditLinkedHardwareCalibration(lCalibration) then
    UpdateHardwareCurveText;
end;

function TTagSettingsDialog.EditLinkedHardwareCalibration(
  ACalibration: TRecorderCalibration): Boolean;
var
  lDraft: TRecorderCalibration;
  lError: string;
  lExisting: TRecorderCalibration;
begin
  Result := False;
  if ACalibration = nil then
    Exit;
  lDraft := ACalibration.Clone;
  try
    if not (((lDraft.Kind = rckStrain) and
      ShowRecorderStrainCalibrationDialog(Self, lDraft)) or
      ((lDraft.Kind <> rckStrain) and
      ShowRecorderCalibrationPropertiesDialog(Self, lDraft))) then
      Exit;
    if Trim(lDraft.Name) = '' then
    begin
      MessageDlg('Сохранение аппаратной ГХ',
        'Имя ГХ не может быть пустым.', mtError, [mbOK], 0);
      Exit;
    end;
    lExisting := fTagRegistry.FindCalibrationByName(Trim(lDraft.Name));
    if (lExisting <> nil) and (lExisting <> ACalibration) then
    begin
      MessageDlg('Сохранение аппаратной ГХ',
        'ГХ с именем «' + Trim(lDraft.Name) + '» уже существует.',
        mtError, [mbOK], 0);
      Exit;
    end;
    if not RecorderSdbUpdateLinkedCalibration(ACalibration, lDraft,
      lError) then
    begin
      MessageDlg('Сохранение аппаратной ГХ',
        'Не удалось обновить связанную ГХ в БДГХ:' + LineEnding +
        lError, mtError, [mbOK], 0);
      Exit;
    end;
    try
      Result := fTagRegistry.CommitCalibrationEdit(ACalibration, lDraft);
    except
      on E: ERecorderTagError do
        MessageDlg('Сохранение аппаратной ГХ', E.Message,
          mtError, [mbOK], 0);
    end;
  finally
    lDraft.Free;
  end;
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
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
begin
  lHasHardwareDevice := False;
  for lI := 0 to fTags.Count - 1 do
    if ResolveSettingsProvider(TagAt(lI), lProvider) and
      lProvider.ReadState(fTagRegistry, TagAt(lI), lState) and
      lState.HardwareCalibrationDownloadable then
    begin
      lHasHardwareDevice := True;
      Break;
    end;
  if fHardwareCurveDownloadBtn <> nil then
    fHardwareCurveDownloadBtn.Visible := lHasHardwareDevice;
end;

procedure TTagSettingsDialog.DownloadHardwareCalibrationFromDeviceClick(Sender: TObject);
const
  sGhDownloadTitle = 'Выгрузка ГХ';
  sGhDownloadOk = 'Градуировки успешно выгружены из памяти устройства.';
  sGhDownloadNoSupported =
    'Среди выбранных тегов нет источников с поддержкой выгрузки аппаратной ГХ.';
var
  lErrorMessage: string;
  lErrors: TStringList;
  lI: Integer;
  lMessageText: string;
  lMessages: TStringList;
  lOkCount: Integer;
  lProvider: IRecorderTagSettingsProvider;
  lResult: TRecorderHardwareCalibrationResult;
  lState: TRecorderTagSettingsState;
begin
  if fTags.Count = 0 then
    Exit;

  lErrors := TStringList.Create;
  lMessages := TStringList.Create;
  try
    lOkCount := 0;
    for lI := 0 to fTags.Count - 1 do
    begin
      if not ResolveSettingsProvider(TagAt(lI), lProvider) then
        Continue;
      if not lProvider.ReadState(fTagRegistry, TagAt(lI), lState) or
        not lState.HardwareCalibrationDownloadable then
        Continue;
      if lProvider.DownloadHardwareCalibration(fTagRegistry, TagAt(lI),
        lResult, lErrorMessage) then
      begin
        Inc(lOkCount);
        if Trim(lResult.MessageText) <> '' then
          lMessages.Add(Format('%s (%s): %s', [TagAt(lI).Name,
            TagAt(lI).Address, lResult.MessageText]))
        else if Trim(lResult.PresentationText) <> '' then
          lMessages.Add(Format('%s (%s): %s', [TagAt(lI).Name,
            TagAt(lI).Address, lResult.PresentationText]));
      end
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
      MessageDlg(sGhDownloadTitle, sGhDownloadNoSupported,
        mtInformation, [mbOK], 0);
  finally
    lMessages.Free;
    lErrors.Free;
  end;
end;

end.
