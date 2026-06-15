unit uRecorderSettingsDialog;

{
  Модуль uRecorderSettingsDialog

  Назначение:
    Диалог настройки параметров рекордера и конфигурации аппаратных каналов/устройств.
    Позволяет задавать параметры отображения, буферизации, записи, условия
    старта/останова сбора данных, а также импортировать сигналы из файлов формата Mera.

  Библиотеки и зависимости:
    - Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls: стандартные модули LCL.
    - ComCtrls, ImgList, Grids, Buttons: компоненты UI (дерево устройств, списки каналов).
    - uRecorderStateMachine, uRecorderRunControlSettings, uRecorderTags: бизнес-логика рекордера.
    - uMeraFile: парсинг файлов конфигурации сигналов Mera.
    - uRecorderCommandImages: константы индексов иконок UI.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ImgList, Grids, Buttons, Menus, LCLType,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderTags, uMeraFile,
  uRecorderCommandImages, uTagSettingsDialog, uComponentServices,
  uRecorderSpectrumEngine, uRecorderFrequencyBands, uRecorderFrequencyBandsDialog,
  uRecorderMic140DataSource, uRecorderMic140SettingsDialog;

type
  { TRecorderSettingsDialog }

  { Класс диалогового окна настроек рекордера }
  TRecorderSettingsDialog = class(TForm)
  published
    fPageControl: TPageControl;                 // Контейнер вкладок настроек
    fApplyButton: TButton;                     // Кнопка "Применить"
    fHardwareTree: TTreeView;                   // Дерево аппаратной конфигурации/устройств
    btnDeviceAdd: TBitBtn;                      // Кнопка добавления устройства (Mera-файла)
    btnChannelAdd: TBitBtn;                     // Кнопка добавления выбранного канала в список активных
    btnChannelRemove: TBitBtn;                  // Кнопка удаления канала из списка активных
    btnChannelEdit: TBitBtn;                    // Кнопка настройки выбранного тега
    pnChannelMoveButtons: TPanel;               // Панель кнопок перемещения каналов
    spChannels: TSplitter;                      // Разделитель между сетками доступных и выбранных каналов
    fAvailableChannelsGrid: TStringGrid;        // Таблица доступных для выбора каналов
    fSelectedChannelsGrid: TStringGrid;         // Таблица выбранных (активных) каналов
    spChannelAlgorithms: TSplitter;             // Разделитель между каналами и алгоритмами
    fAlgorithmsTree: TTreeView;                 // Дерево алгоритмов каналов
    fAlgorithmKindCombo: TComboBox;             // Тип создаваемого алгоритма
    btnAlgorithmAdd: TBitBtn;                   // Создать алгоритм по выбранным каналам
    btnAlgorithmRemove: TBitBtn;                // Удалить узел алгоритма
    btnAlgorithmConfig: TBitBtn;                // Применить параметры FFT-узла
    btnFrequencyBands: TBitBtn;                 // Настроить частотные полосы
    fAlgorithmFftSizeEdit: TEdit;               // Размер FFT
    fAlgorithmFftSizeUpDown: TUpDown;           // Стрелочки изменения размера FFT
    fAlgorithmSampleRateEdit: TEdit;            // Частота опроса
    fAlgorithmPortionLabel: TLabel;             // Размер порции в секундах
    fAlgorithmAverageBlocksEdit: TEdit;         // Количество блоков усреднения
    fAlgorithmOverlapEdit: TEdit;               // Перекрытие FFT
    fAlgorithmOverlapCombo: TComboBox;          // Режим перекрытия FFT
    fAlgorithmWindowCombo: TComboBox;           // Оконная функция
    fAlgorithmNormalizeCombo: TComboBox;        // Нормировка спектра
    fAlgorithmZeroPadCheck: TCheckBox;          // Дополнять нулями
    fAlgorithmAhCorrectionCheck: TCheckBox;     // Коррекция АЧХ
    fAlgorithmIntegrationGroup: TRadioGroup;    // Режим интегрирования
    Cfg: TEdit;

    // Поля ввода общих настроек
    fScreenUpdateEdit: TEdit;                   // Период обновления экрана (сек)
    fBufferSecondsEdit: TEdit;                  // Длина отображаемого буфера (сек)
    fDataUpdateEdit: TEdit;                     // Период обновления данных (сек)
    fTestNameEdit: TEdit;                       // Имя текущего испытания
    fProductNameEdit: TEdit;                    // Имя исследуемого изделия
    fModifyNameCheck: TCheckBox;                // Флаг автоматической модификации имени испытания
    fPrehistoryCheck: TCheckBox;                // Флаг записи предыстории
    fPrehistoryEdit: TEdit;                     // Длина предыстории (сек)
    fResetTimeCheck: TCheckBox;                 // Флаг сброса времени при старте записи
    fWriteWithPausesCheck: TCheckBox;           // Флаг разрешения записи с паузами
    fSaveConfigWithDataCheck: TCheckBox;        // Флаг сохранения файла конфигурации вместе с данными
    fWorkDirEdit: TEdit;                        // Рабочий каталог сохранения файлов
    fTemplateCheck: TCheckBox;                  // Флаг использования шаблона имени файла
    fTemplateButton: TButton;                   // Кнопка настройки шаблона
    fFrameDirEdit: TEdit;                       // Путь к текущему кадру данных

    // Условия старта записи
    fStartManualRadio: TRadioButton;            // Старт вручную (по кнопке)
    fStartLevelRadio: TRadioButton;             // Старт по достижению уровня сигнала
    fStartTriggerRadio: TRadioButton;           // Старт по внешнему триггеру
    fStartTriggerEdit: TEdit;                   // Номер триггера старта
    fStartChannelCombo: TComboBox;              // Канал-источник для условия старта
    fStartEdgeCombo: TComboBox;                 // Направление перехода (больше/меньше)
    fStartLevelEdit: TEdit;                     // Пороговый уровень для старта

    // Условия останова записи
    fStopManualRadio: TRadioButton;             // Остановы вручную (по кнопке)
    fStopLevelRadio: TRadioButton;              // Останов по уровню сигнала
    fStopDurationRadio: TRadioButton;           // Останов по длительности (таймеру)
    fStopDurationEdit: TEdit;                   // Время записи до останова (сек)
    fStopChannelCombo: TComboBox;               // Канал-источник для условия останова
    fStopEdgeCombo: TComboBox;                  // Направление перехода для останова
    fStopLevelEdit: TEdit;                      // Пороговый уровень для останова
    fStopReturnToPreviewCheck: TCheckBox;       // Флаг возврата в режим просмотра после останова

    // Обработчики событий UI элементов диалога
    procedure ApplyButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure ConditionChanged(Sender: TObject);
    procedure btnDeviceAddClick(Sender: TObject);
    procedure btnChannelAddClick(Sender: TObject);
    procedure btnChannelRemoveClick(Sender: TObject);
    procedure btnChannelEditClick(Sender: TObject);
    procedure fAvailableChannelsGridDblClick(Sender: TObject);
    procedure fAvailableChannelsGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure fSelectedChannelsGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure fSelectedChannelsGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure fSelectedChannelsGridDblClick(Sender: TObject);
    procedure fSelectedChannelsGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure fAlgorithmsTreeChange(Sender: TObject; Node: TTreeNode);
    procedure fAlgorithmsTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure fAlgorithmsTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure btnAlgorithmAddClick(Sender: TObject);
    procedure btnAlgorithmRemoveClick(Sender: TObject);
    procedure btnAlgorithmConfigClick(Sender: TObject);
    procedure btnFrequencyBandsClick(Sender: TObject);
    procedure fAlgorithmAhCorrectionCheckChange(Sender: TObject);
    procedure fAlgorithmFftParamChange(Sender: TObject);
    procedure fAlgorithmOverlapComboChange(Sender: TObject);
    procedure fHardwareTreeDblClick(Sender: TObject);
    procedure fHardwareTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fAlgorithmsTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fCfgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure fAlgorithmFftSizeUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure WorkDirBrowseClick(Sender: TObject);
  private
    fRunSettings: TRecorderRunControlSettings;   // Ссылка на объект настроек запуска/останова
    fTagRegistry: TRecorderTagRegistry;         // Ссылка на реестр тегов приложения
    fDeviceImageList: TCustomImageList;         // Список картинок для дерева устройств
    fTagDialogImageList: TCustomImageList;      // Список иконок диалога настройки тегов
    fMeraFolder: string;                        // Путь к последней папке импортированного Mera-файла
    fMeraFileName: string;                      // Имя импортированного Mera-файла
    fMeraSignals: TList;                        // Список TMeraSignalInfo, загруженных из файла
    fMic140Signals: TList;                      // Список доступных каналов MIC-140
    fSelectedChannelTags: TList;                // Row-map выбранных каналов на TRecorderTag
    fSelectedSortColumn: Integer;               // Колонка текущей сортировки выбранных каналов
    fSelectedSortAscending: Boolean;            // Направление текущей сортировки
    fSpectrumConfigTree: TRecorderSpectrumConfigTree; // Черновая модель алгоритмов вкладки каналов
    fFrequencyBands: TRecorderFrequencyBandList; // Черновая модель частотных полос
    fCanDrag: Boolean;
    fDragStartPt: TPoint;
    fDragSelectActive: Boolean;
    fDragSelectStart: TPoint;
    fDragSelectEnd: TPoint;
    fSelectingGrid: TStringGrid;
    fSavedSelection: TGridRect;
    procedure fSelectedChannelsGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure fSelectedChannelsGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridPaint(Sender: TObject);
    
    // Вспомогательные методы работы с Mera-сигналами
    procedure AddMeraSignal(ASignal: TMeraSignalInfo);
    function CloneMeraSignalForTag(ASignal: TMeraSignalInfo;
      const ATagName: string): TMeraSignalInfo;
    procedure ApplyMeraSignalToTag(ATag: TRecorderTag; ASignal: TMeraSignalInfo);
    function SignalSourceId(ASignal: TMeraSignalInfo): string;
    function SignalSourceGroup(ASignal: TMeraSignalInfo): string;
    function FindTagBySourceAddress(const ASourceId, AAddress: string): TRecorderTag;
    function SignalHasLinkedTag(ASignal: TMeraSignalInfo): Boolean;
    function SelectedTagByGridRow(ARow: Integer): TRecorderTag;
    function CompareTagsForSelectedGrid(ATagA, ATagB: TRecorderTag): Integer;
    procedure SortSelectedTags(ATags: TList);
    procedure SortSelectedChannelsByColumn(AColumn: Integer);
    procedure OpenSelectedChannelTagSettings;
    procedure AddSpectrumAlgorithmsFromSelectedChannels;
    procedure AddSpectrumAlgorithmForTag(ATag: TRecorderTag;
      ATargetNode: TRecorderSpectrumConfigNode);
    function CreateSpectrumConfigNode(ATag: TRecorderTag): TRecorderSpectrumConfigNode;
    function SelectedSpectrumConfigNode: TRecorderSpectrumConfigNode;
    procedure CreateSelectedMeraTags;
    procedure ClearMeraSignals;
    procedure ClearMic140Signals;
    procedure RestoreMeraSignalsFromTags;
    procedure RestoreMic140SignalsFromTags;
    function FindMeraSignalByTagName(const ATagName: string): TMeraSignalInfo;
    function FindMic140SignalBySourceAddress(const ASourceId, AAddress: string): TMeraSignalInfo;
    procedure BuildMic140Signals(const ASourceId: string; AChannelCount: Integer;
      APollFrequencyHz: Double; AEnabledChannels: TStrings);
    function AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    function SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    procedure LoadMeraFile(const AFileName: string);
    procedure MarkSignalsFromRegistry;
    function MeraSourceId(const AFileName: string): string;
    procedure DeleteCurrentMeraSource;
    procedure ReloadCurrentMeraSource;
    procedure HardwareAddSourceClick(Sender: TObject);
    procedure HardwareSearchClick(Sender: TObject);
    procedure AddMic140Source(const APresetHost: string = '');
    function SelectedMic140SourceId: string;
    procedure ConfigureMic140Source(const ASourceId: string);
    procedure DeleteMic140Source(const ASourceId: string);
    procedure HardwareDeleteSourceClick(Sender: TObject);
    procedure HardwareReloadSourceClick(Sender: TObject);
    procedure HardwareEditSourceClick(Sender: TObject);
    
    // Методы инициализации и обновления интерфейса
    procedure PopulateChannelGrids;
    procedure PopulateHardwareTree;
    procedure PopulateAlgorithmsTree;
    procedure InitializeAlgorithmControls;
    procedure LoadSelectedAlgorithmSettings;
    procedure StoreSelectedAlgorithmSettings;
    procedure UpdateAlgorithmDerivedControls;
    procedure DeleteSelectedAlgorithms;
    function GetSettingsFromControls(const ACurrent: TRecorderSpectrumSettings): TRecorderSpectrumSettings;
    procedure UpdateConfigStr;
    procedure SetGridHeaders;
    procedure ToggleHardwareSignal(ANode: TTreeNode);
    procedure SetRunSettings(AValue: TRecorderRunControlSettings);
    procedure SetTagRegistry(AValue: TRecorderTagRegistry);
    procedure SetDeviceImageList(AValue: TCustomImageList);
    procedure SetDialogButtonImages;
    procedure InitializeHardwareTree;
    
    // Динамическое построение UI (используется при отсутствии lfm-файла формы)
    procedure BuildUi;
    procedure BuildRecorderTab(ATab: TTabSheet);
    procedure BuildHardwareTab(ATab: TTabSheet);
    procedure BuildPlaceholderTab(const ACaption: string);
    
    // Чтение и сохранение настроек
    procedure LoadFromSettings;
    procedure StoreToSettings;
    procedure UpdateConditionControls;
    function ReadFloatEdit(AEdit: TEdit; ADefault: Double): Double;
    function ReadSecondsAsMs(AEdit: TEdit; ADefaultMs: Cardinal): Cardinal;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    // Свойства доступа к зависимостям
    property DeviceImageList: TCustomImageList read fDeviceImageList write SetDeviceImageList;
    property TagDialogImageList: TCustomImageList read fTagDialogImageList write fTagDialogImageList;
    property RunSettings: TRecorderRunControlSettings read fRunSettings write SetRunSettings;
    property TagRegistry: TRecorderTagRegistry read fTagRegistry write SetTagRegistry;
  end;

{ Отображает модальный диалог настроек }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry = nil;
  ADeviceImageList: TCustomImageList = nil;
  ATagDialogImageList: TCustomImageList = nil): Boolean;

implementation

{$R *.lfm}

{ Точка входа для запуска диалога настроек }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry;
  ADeviceImageList: TCustomImageList;
  ATagDialogImageList: TCustomImageList): Boolean;
var
  lDialog: TRecorderSettingsDialog;
begin
  lDialog := TRecorderSettingsDialog.Create(AOwner);
  try
    lDialog.DeviceImageList := ADeviceImageList;
    lDialog.TagDialogImageList := ATagDialogImageList;
    lDialog.TagRegistry := ATagRegistry;
    lDialog.RunSettings := ARunSettings;
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

{ Вспомогательные функции динамического создания UI контролов }

function AddLabel(AOwner: TComponent; AParent: TWinControl; ALeft, ATop: Integer;
  const ACaption: string): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Caption := ACaption;
end;

function AddEdit(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth: Integer; const AText: string): TEdit;
begin
  Result := TEdit.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Text := AText;
end;

function AddGroup(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth, AHeight: Integer; const ACaption: string): TGroupBox;
begin
  Result := TGroupBox.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
end;

function AddRadio(AOwner: TComponent; AParent: TWinControl; ALeft, ATop: Integer;
  const ACaption: string; AOnChange: TNotifyEvent): TRadioButton;
begin
  Result := TRadioButton.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Caption := ACaption;
  Result.OnChange := AOnChange;
end;

function AddCheck(AOwner: TComponent; AParent: TWinControl; ALeft, ATop: Integer;
  const ACaption: string): TCheckBox;
begin
  Result := TCheckBox.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Caption := ACaption;
end;

function AddCombo(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth: Integer): TComboBox;
begin
  Result := TComboBox.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Style := csDropDownList;
end;

{ Назначение картинки кнопкам с глифом }
procedure AssignButtonImage(AButton: TBitBtn; AImages: TCustomImageList;
  AIndex: Integer);
var
  lBitmap: TBitmap;
  lNative: TBitmap;
  lW, lH: Integer;
begin
  if (AButton = nil) or (AImages = nil) or (AIndex < 0) or
    (AIndex >= AImages.Count) then
    Exit;

  lNative := TBitmap.Create;
  lBitmap := TBitmap.Create;
  try
    lNative.SetSize(AImages.Width, AImages.Height);
    AImages.GetBitmap(AIndex, lNative);
    
    lW := AButton.ClientWidth;
    if lW <= 0 then lW := AButton.Width;
    lH := AButton.ClientHeight;
    if lH <= 0 then lH := AButton.Height;
    
    // Add margin so it fits beautifully
    if lW > 6 then Dec(lW, 6);
    if lH > 6 then Dec(lH, 6);
    if lW <= 0 then lW := 16;
    if lH <= 0 then lH := 16;

    lBitmap.SetSize(lW, lH);
    lBitmap.Canvas.Brush.Color := clBtnFace;
    lBitmap.Canvas.FillRect(0, 0, lW, lH);
    lBitmap.Canvas.StretchDraw(Rect(0, 0, lW, lH), lNative);
    
    AButton.Caption := '';
    AButton.Glyph.Assign(lBitmap);
    AButton.Layout := blGlyphTop;
    AButton.Margin := 0;
  finally
    lNative.Free;
    lBitmap.Free;
  end;
end;

{ TRecorderSettingsDialog }

const
  CDeviceRootImageIndex = CIconDeviceRoot;
  CDeviceControllerImageIndex = CIconDeviceController;
  CDeviceModuleImageIndex = CIconDeviceModule;
  CMeraSampleFile = 'D:\works\mera\mera files signals\shocks\signal0005\signal0005.mera';

constructor TRecorderSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fMeraSignals := TList.Create;
  fMic140Signals := TList.Create;
  fSelectedChannelTags := TList.Create;
  fSpectrumConfigTree := TRecorderSpectrumConfigTree.Create;
  fFrequencyBands := TRecorderFrequencyBandList.Create;
  fSelectedSortColumn := 2;
  fSelectedSortAscending := True;

  if (btnChannelEdit = nil) and (pnChannelMoveButtons <> nil) then
  begin
    btnChannelEdit := TBitBtn.Create(Self);
    btnChannelEdit.Parent := pnChannelMoveButtons;
    btnChannelEdit.Left := 6;
    btnChannelEdit.Top := 276;
    btnChannelEdit.Width := 30;
    btnChannelEdit.Height := 30;
    btnChannelEdit.Caption := '...';
    btnChannelEdit.Hint := 'Настроить выбранный канал';
    btnChannelEdit.ShowHint := True;
    btnChannelEdit.OnClick := @btnChannelEditClick;
  end;

  if FindComponent('btnWorkDirBrowse') is TButton then
    TButton(FindComponent('btnWorkDirBrowse')).OnClick := @WorkDirBrowseClick;
  if btnDeviceAdd <> nil then
    btnDeviceAdd.OnClick := @HardwareAddSourceClick;
  if FindComponent('btnDeviceDelete') is TBitBtn then
    TBitBtn(FindComponent('btnDeviceDelete')).OnClick := @HardwareDeleteSourceClick;
  if FindComponent('btnDeviceSetup') is TBitBtn then
    TBitBtn(FindComponent('btnDeviceSetup')).OnClick := @HardwareEditSourceClick;
  if FindComponent('btnDeviceSearch') is TBitBtn then
    TBitBtn(FindComponent('btnDeviceSearch')).OnClick := @HardwareSearchClick;

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelsGrid.OnDblClick := @fSelectedChannelsGridDblClick;
    fSelectedChannelsGrid.OnMouseDown := @fSelectedChannelsGridMouseDown;
    fSelectedChannelsGrid.OnMouseMove := @fSelectedChannelsGridMouseMove;
    fSelectedChannelsGrid.OnMouseUp := @fSelectedChannelsGridMouseUp;
    fSelectedChannelsGrid.OnPaint := @GridPaint;
    fSelectedChannelsGrid.DragMode := dmManual;
  end;

  if fAvailableChannelsGrid <> nil then
  begin
    fAvailableChannelsGrid.OnMouseMove := @fSelectedChannelsGridMouseMove;
    fAvailableChannelsGrid.OnMouseUp := @fSelectedChannelsGridMouseUp;
    fAvailableChannelsGrid.OnPaint := @GridPaint;
    fAvailableChannelsGrid.DragMode := dmManual;
  end;
  if fAlgorithmsTree <> nil then
  begin
    fAlgorithmsTree.Images := fDeviceImageList;
    fAlgorithmsTree.ImagesWidth := 16;
  end;
  if fAlgorithmsTree <> nil then
  begin
    fAlgorithmsTree.Options := fAlgorithmsTree.Options + [tvoAllowMultiselect];
    fAlgorithmsTree.OnKeyDown := @fAlgorithmsTreeKeyDown;
  end;
  if fAlgorithmWindowCombo <> nil then
    fAlgorithmWindowCombo.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmZeroPadCheck <> nil then
    fAlgorithmZeroPadCheck.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmIntegrationGroup <> nil then
    fAlgorithmIntegrationGroup.OnClick := @fAlgorithmFftParamChange;
  if Cfg <> nil then
    Cfg.OnKeyDown := @fCfgKeyDown;
  if fAlgorithmFftSizeEdit <> nil then
    fAlgorithmFftSizeEdit.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmSampleRateEdit <> nil then
    fAlgorithmSampleRateEdit.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmOverlapCombo <> nil then
    fAlgorithmOverlapCombo.OnChange := @fAlgorithmOverlapComboChange;
  if fAlgorithmAhCorrectionCheck <> nil then
    fAlgorithmAhCorrectionCheck.OnChange := @fAlgorithmAhCorrectionCheckChange;

  SetGridHeaders;
  InitializeAlgorithmControls;
  InitializeHardwareTree;
  UpdateConditionControls;
end;

destructor TRecorderSettingsDialog.Destroy;
begin
  ClearMeraSignals;
  ClearMic140Signals;
  fFrequencyBands.Free;
  fSpectrumConfigTree.Free;
  fSelectedChannelTags.Free;
  fMic140Signals.Free;
  fMeraSignals.Free;
  inherited Destroy;
end;

procedure TRecorderSettingsDialog.SetRunSettings(AValue: TRecorderRunControlSettings);
begin
  fRunSettings := AValue;
  LoadFromSettings;
end;

procedure TRecorderSettingsDialog.SetTagRegistry(AValue: TRecorderTagRegistry);
begin
  fTagRegistry := AValue;
  RestoreMeraSignalsFromTags;
  RestoreMic140SignalsFromTags;
  if fTagRegistry <> nil then
  begin
    fSpectrumConfigTree.Assign(fTagRegistry.SpectrumConfigs);
    PopulateAlgorithmsTree;
  end;
end;

procedure TRecorderSettingsDialog.SetDeviceImageList(AValue: TCustomImageList);
begin
  fDeviceImageList := AValue;
  if fHardwareTree <> nil then
  begin
    fHardwareTree.Images := fDeviceImageList;
    fHardwareTree.ImagesWidth := 16;
  end;
  if fAlgorithmsTree <> nil then
  begin
    fAlgorithmsTree.Images := fDeviceImageList;
    fAlgorithmsTree.ImagesWidth := 16;
  end;
  SetDialogButtonImages;
end;

{ Настройка иконок кнопок на панели дерева устройств }
procedure TRecorderSettingsDialog.SetDialogButtonImages;
var
  lButton: TComponent;
begin
  AssignButtonImage(btnDeviceAdd, fDeviceImageList, CIconAdd);
  AssignButtonImage(btnChannelAdd, fDeviceImageList, CIconRight);
  AssignButtonImage(btnChannelRemove, fDeviceImageList, CIconLeft);
  AssignButtonImage(btnChannelEdit, fDeviceImageList, CIconProperty);

  lButton := FindComponent('btnDeviceDelete');
  if lButton is TBitBtn then
    AssignButtonImage(TBitBtn(lButton), fDeviceImageList, CIconRemove);

  lButton := FindComponent('btnDeviceSetup');
  if lButton is TBitBtn then
    AssignButtonImage(TBitBtn(lButton), fDeviceImageList, CIconProperty);

  lButton := FindComponent('btnDeviceSearch');
  if lButton is TBitBtn then
    AssignButtonImage(TBitBtn(lButton), fDeviceImageList, CIconSearch);
end;

procedure TRecorderSettingsDialog.AddMeraSignal(ASignal: TMeraSignalInfo);
begin
  if fMeraSignals = nil then
    fMeraSignals := TList.Create;
  fMeraSignals.Add(ASignal);
end;

function TRecorderSettingsDialog.CloneMeraSignalForTag(ASignal: TMeraSignalInfo;
  const ATagName: string): TMeraSignalInfo;
begin
  Result := TMeraSignalInfo.Create;
  Result.Name := ATagName;
  Result.Address := ASignal.Address;
  Result.ModuleName := ASignal.ModuleName;
  Result.DataTypeName := ASignal.DataTypeName;
  Result.DataType := ASignal.DataType;
  Result.FrequencyHz := ASignal.FrequencyHz;
  Result.StartSec := ASignal.StartSec;
  Result.UnitsName := ASignal.UnitsName;
  Result.Description := ASignal.Description;
  Result.FileName := ASignal.FileName;
  Result.XFileName := ASignal.XFileName;
  Result.HasXData := ASignal.HasXData;
  Result.Enabled := True;
  Result.Selected := True;
end;
function TRecorderSettingsDialog.MeraSourceId(const AFileName: string): string;
begin
  Result := 'Mera file: ' + AFileName;
end;

{ Copies MERA signal properties into a tag and binds it to the active source. }
procedure TRecorderSettingsDialog.ApplyMeraSignalToTag(ATag: TRecorderTag;
  ASignal: TMeraSignalInfo);
var
  lSourceId: string;
begin
  if (ATag = nil) or (ASignal = nil) then
    Exit;

  lSourceId := SignalSourceId(ASignal);
  ATag.Address := ASignal.Address;
  ATag.UnitName := ASignal.UnitsName;
  ATag.SourceId := lSourceId;
  ATag.ModuleType := ASignal.ModuleName;
  ATag.PollFrequencyHz := ASignal.FrequencyHz;
  if SameText(ASignal.ModuleName, 'MIC-140') then
    ATag.Description := Format('%s; freq=%s Hz',
      [ASignal.Description, FormatFloat('0.######', ASignal.FrequencyHz)])
  else
    ATag.Description := Format('%s; type=%s; freq=%s; file=%s',
      [ASignal.Name, ASignal.DataTypeName, FormatFloat('0.######', ASignal.FrequencyHz),
      ExtractFileName(ASignal.FileName)]);
end;

function TRecorderSettingsDialog.SignalSourceId(ASignal: TMeraSignalInfo): string;
begin
  Result := '';
  if ASignal = nil then
    Exit;
  if SameText(ASignal.ModuleName, 'MIC-140') then
    Result := ASignal.FileName
  else
    Result := MeraSourceId(fMeraFileName);
end;

function TRecorderSettingsDialog.SignalSourceGroup(ASignal: TMeraSignalInfo): string;
begin
  Result := '';
  if ASignal = nil then
    Exit;
  if SameText(ASignal.ModuleName, 'MIC-140') then
    Result := 'MIC-140'
  else
    Result := 'Mera File';
end;
function TRecorderSettingsDialog.FindTagBySourceAddress(const ASourceId,
  AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if fTagRegistry = nil then
    Exit;

  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) and SameText(lTag.Address, AAddress) then
      Exit(lTag);
  end;
end;

function TRecorderSettingsDialog.SignalHasLinkedTag(
  ASignal: TMeraSignalInfo): Boolean;
begin
  Result := (ASignal <> nil) and
    (FindTagBySourceAddress(SignalSourceId(ASignal), ASignal.Address) <> nil);
end;

function TRecorderSettingsDialog.SelectedTagByGridRow(
  ARow: Integer): TRecorderTag;
begin
  Result := nil;
  if (fSelectedChannelTags = nil) or (ARow < 1) or
    (ARow > fSelectedChannelTags.Count) then
    Exit;
  if TObject(fSelectedChannelTags[ARow - 1]) is TRecorderTag then
    Result := TRecorderTag(fSelectedChannelTags[ARow - 1]);
end;

function TRecorderSettingsDialog.CompareTagsForSelectedGrid(ATagA,
  ATagB: TRecorderTag): Integer;
begin
  Result := 0;
  if (ATagA = nil) or (ATagB = nil) then
    Exit;

  case fSelectedSortColumn of
    0:
      Result := CompareText(ATagA.Name, ATagB.Name);
    1:
      begin
        Result := CompareText(ATagA.Address, ATagB.Address);
        if Result = 0 then
          Result := CompareText(ATagA.Name, ATagB.Name);
      end;
    2:
      Result := CompareText(ATagA.ModuleType, ATagB.ModuleType);
    3:
      Result := CompareValue(ATagA.PollFrequencyHz, ATagB.PollFrequencyHz);
    4:
      Result := 0;
    5:
      Result := CompareText(ATagA.SourceId, ATagB.SourceId);
    6:
      Result := CompareText(ATagA.Description, ATagB.Description);
    7:
      Result := CompareValue(ATagA.Id, ATagB.Id);
  else
    Result := CompareText(ATagA.Name, ATagB.Name);
  end;

  if (Result = 0) and (fSelectedSortColumn <> 1) then
  begin
    Result := CompareText(ATagA.Address, ATagB.Address);
    if Result = 0 then
      Result := CompareText(ATagA.Name, ATagB.Name);
  end;

  if not fSelectedSortAscending then
    Result := -Result;
end;

procedure TRecorderSettingsDialog.SortSelectedTags(ATags: TList);
var
  I: Integer;
  J: Integer;
  lTemp: Pointer;
begin
  if ATags = nil then
    Exit;

  for I := 0 to ATags.Count - 2 do
    for J := I + 1 to ATags.Count - 1 do
      if CompareTagsForSelectedGrid(TRecorderTag(ATags[I]),
        TRecorderTag(ATags[J])) > 0 then
      begin
        lTemp := ATags[I];
        ATags[I] := ATags[J];
        ATags[J] := lTemp;
      end;
end;

procedure TRecorderSettingsDialog.SortSelectedChannelsByColumn(AColumn: Integer);
begin
  if AColumn < 0 then
    Exit;

  if fSelectedSortColumn = AColumn then
    fSelectedSortAscending := not fSelectedSortAscending
  else
  begin
    fSelectedSortColumn := AColumn;
    fSelectedSortAscending := True;
  end;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.OpenSelectedChannelTagSettings;
var
  lDialogOk: Boolean;
  lTag: TRecorderTag;
  lTags: TList;
begin
  lTag := SelectedTagByGridRow(fSelectedChannelsGrid.Row);
  if lTag = nil then
    Exit;

  lTags := TList.Create;
  try
    lTags.Add(lTag);
    if fTagDialogImageList <> nil then
      lDialogOk := ShowTagSettingsDialog(Self, fTagRegistry, lTags, fTagDialogImageList)
    else
      lDialogOk := ShowTagSettingsDialog(Self, fTagRegistry, lTags, fDeviceImageList);
    if lDialogOk then
    begin
      MarkSignalsFromRegistry;
      PopulateHardwareTree;
      PopulateChannelGrids;
    end;
  finally
    lTags.Free;
  end;
end;

function TRecorderSettingsDialog.SelectedSpectrumConfigNode: TRecorderSpectrumConfigNode;
var
  lNode: TTreeNode;
begin
  Result := nil;
  if fAlgorithmsTree = nil then
    Exit;
  lNode := fAlgorithmsTree.Selected;
  while lNode <> nil do
  begin
    if TObject(lNode.Data) is TRecorderSpectrumConfigNode then
      Exit(TRecorderSpectrumConfigNode(lNode.Data));
    lNode := lNode.Parent;
  end;
end;

function TRecorderSettingsDialog.CreateSpectrumConfigNode(
  ATag: TRecorderTag): TRecorderSpectrumConfigNode;
var
  lSettings: TRecorderSpectrumSettings;
begin
  Result := fSpectrumConfigTree.AddNode('spectrum.' +
    IntToStr(fSpectrumConfigTree.NodeCount + 1),
    'Спектр ' + IntToStr(fSpectrumConfigTree.NodeCount + 1));
  lSettings := Result.Settings;
  if (ATag <> nil) and (ATag.PollFrequencyHz > 0) then
    lSettings.SampleRateHz := ATag.PollFrequencyHz;
  Result.Settings := lSettings;
end;

procedure TRecorderSettingsDialog.AddSpectrumAlgorithmForTag(ATag: TRecorderTag;
  ATargetNode: TRecorderSpectrumConfigNode);
var
  I: Integer;
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
begin
  if ATag = nil then
    Exit;

  lNode := ATargetNode;
  if lNode = nil then
    lNode := CreateSpectrumConfigNode(ATag);

  for I := 0 to lNode.BindingCount - 1 do
    if SameText(lNode.Bindings[I].SourceTagName, ATag.Name) then
      Exit;

  lBinding := lNode.AddBinding(ATag.Name);
  lBinding.OutputPrefix := ATag.Name + '_spm';
end;

procedure TRecorderSettingsDialog.AddSpectrumAlgorithmsFromSelectedChannels;
var
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
  lTag: TRecorderTag;
  lTargetNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  if (fSelectedChannelsGrid = nil) or (fAlgorithmKindCombo = nil) then
    Exit;
  if fAlgorithmKindCombo.ItemIndex < 0 then
    fAlgorithmKindCombo.ItemIndex := 0;
  if fAlgorithmKindCombo.Text <> 'Спектр' then
    Exit;

  lSelection := fSelectedChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  lTargetNode := SelectedSpectrumConfigNode;
  if lTargetNode = nil then
    lTargetNode := CreateSpectrumConfigNode(nil);

  for lRow := lTop to lBottom do
  begin
    lTag := SelectedTagByGridRow(lRow);
    if lTag <> nil then
    begin
      if (lTargetNode.Settings.SampleRateHz <= 0) and (lTag.PollFrequencyHz > 0) then
      begin
        lSettings := lTargetNode.Settings;
        lSettings.SampleRateHz := lTag.PollFrequencyHz;
        lTargetNode.Settings := lSettings;
      end;
      AddSpectrumAlgorithmForTag(lTag, lTargetNode);
    end;
  end;
  PopulateAlgorithmsTree;
  LoadSelectedAlgorithmSettings;
end;

procedure TRecorderSettingsDialog.InitializeAlgorithmControls;
begin
  if fAlgorithmKindCombo <> nil then
  begin
    fAlgorithmKindCombo.Items.Clear;
    fAlgorithmKindCombo.Items.Add('Спектр');
    fAlgorithmKindCombo.ItemIndex := 0;
  end;
  if fAlgorithmWindowCombo <> nil then
  begin
    fAlgorithmWindowCombo.Items.Clear;
    fAlgorithmWindowCombo.Items.Add('Rect');
    fAlgorithmWindowCombo.Items.Add('Hann');
    fAlgorithmWindowCombo.Items.Add('Hamming');
    fAlgorithmWindowCombo.Items.Add('Blackman');
    fAlgorithmWindowCombo.Items.Add('FlatTop');
    fAlgorithmWindowCombo.ItemIndex := Ord(swkHann);
  end;
  if fAlgorithmOverlapCombo <> nil then
  begin
    fAlgorithmOverlapCombo.Items.Clear;
    fAlgorithmOverlapCombo.Items.Add(RecorderSpectrumOverlapName(somNone));
    fAlgorithmOverlapCombo.Items.Add(RecorderSpectrumOverlapName(somHalf));
    fAlgorithmOverlapCombo.Items.Add(RecorderSpectrumOverlapName(somQuarter));
    fAlgorithmOverlapCombo.ItemIndex := Ord(somNone);
  end;
  if fAlgorithmIntegrationGroup <> nil then
  begin
    fAlgorithmIntegrationGroup.Items.Clear;
    fAlgorithmIntegrationGroup.Items.Add(RecorderSpectrumIntegrationName(simNone));
    fAlgorithmIntegrationGroup.Items.Add(RecorderSpectrumIntegrationName(simSingle));
    fAlgorithmIntegrationGroup.Items.Add(RecorderSpectrumIntegrationName(simDouble));
    fAlgorithmIntegrationGroup.ItemIndex := Ord(simNone);
  end;
  if fAlgorithmNormalizeCombo <> nil then
  begin
    fAlgorithmNormalizeCombo.Visible := False;
    fAlgorithmNormalizeCombo.ItemIndex := Ord(snmNone);
  end;
  PopulateAlgorithmsTree;
end;

procedure TRecorderSettingsDialog.PopulateAlgorithmsTree;
var
  I: Integer;
  J: Integer;
  lRoot: TTreeNode;
  lNode: TRecorderSpectrumConfigNode;
  lConfigTreeNode: TTreeNode;
  lBinding: TRecorderSpectrumTagBinding;
begin
  if fAlgorithmsTree = nil then
    Exit;

  fAlgorithmsTree.Items.BeginUpdate;
  try
    fAlgorithmsTree.Items.Clear;
    lRoot := fAlgorithmsTree.Items.Add(nil, 'Алгоритмы');
    lRoot.Data := nil;
    for I := 0 to fSpectrumConfigTree.NodeCount - 1 do
    begin
      lNode := fSpectrumConfigTree.Nodes[I];
      lConfigTreeNode := fAlgorithmsTree.Items.AddChild(lRoot,
        lNode.DisplayName);
      lConfigTreeNode.Data := lNode;
      lConfigTreeNode.ImageIndex := CIconSpectrum;
      lConfigTreeNode.SelectedIndex := CIconSpectrum;
      for J := 0 to lNode.BindingCount - 1 do
      begin
        lBinding := lNode.Bindings[J];
        with fAlgorithmsTree.Items.AddChild(lConfigTreeNode,
          lBinding.SourceTagName + ' -> ' + lBinding.OutputPrefix) do
          Data := lBinding;
      end;
      lConfigTreeNode.Expand(True);
    end;
    lRoot.Expand(True);
    if fAlgorithmsTree.Selected = nil then
      fAlgorithmsTree.Selected := lRoot;
  finally
    fAlgorithmsTree.Items.EndUpdate;
  end;
end;

procedure TRecorderSettingsDialog.LoadSelectedAlgorithmSettings;
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;
  lSettings := lNode.Settings;
  if fAlgorithmFftSizeEdit <> nil then
    fAlgorithmFftSizeEdit.Text := IntToStr(lSettings.FFTSize);
  if fAlgorithmSampleRateEdit <> nil then
    fAlgorithmSampleRateEdit.Text := FormatFloat('0.###', lSettings.SampleRateHz);
  if fAlgorithmAverageBlocksEdit <> nil then
    fAlgorithmAverageBlocksEdit.Text := IntToStr(lSettings.AverageBlockCount);
  if fAlgorithmOverlapEdit <> nil then
    fAlgorithmOverlapEdit.Text := IntToStr(lSettings.Overlap);
  if fAlgorithmOverlapCombo <> nil then
    fAlgorithmOverlapCombo.ItemIndex := Ord(lSettings.OverlapMode);
  if fAlgorithmWindowCombo <> nil then
    fAlgorithmWindowCombo.ItemIndex := Ord(lSettings.WindowKind);
  if fAlgorithmZeroPadCheck <> nil then
    fAlgorithmZeroPadCheck.Checked := lSettings.ZeroPad;
  if fAlgorithmAhCorrectionCheck <> nil then
    fAlgorithmAhCorrectionCheck.Checked := lSettings.AhCorrectionEnabled;
  if fAlgorithmIntegrationGroup <> nil then
    fAlgorithmIntegrationGroup.ItemIndex := Ord(lSettings.IntegrationMode);
  if Cfg <> nil then
    Cfg.Text := lSettings.AsString;
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.StoreSelectedAlgorithmSettings;
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;

  lSettings := lNode.Settings;
  if (Cfg <> nil) and (Cfg.Text <> '') then
  begin
    try
      lSettings.FromString(Cfg.Text);
      lSettings.Validate;
      lNode.Settings := lSettings;
      LoadSelectedAlgorithmSettings;
      Exit;
    except
      // Ignore parsing error and read from input controls
    end;
  end;

  lSettings := GetSettingsFromControls(lSettings);
  lSettings.Validate;
  lNode.Settings := lSettings;
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.UpdateAlgorithmDerivedControls;
var
  lFftSize: Integer;
  lSampleRate: Double;
  lPortionSec: Double;
begin
  if fAlgorithmPortionLabel = nil then
    Exit;
  lFftSize := 0;
  lSampleRate := 0.0;
  if fAlgorithmFftSizeEdit <> nil then
    TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lFftSize);
  if fAlgorithmSampleRateEdit <> nil then
    lSampleRate := ReadFloatEdit(fAlgorithmSampleRateEdit, 0.0);

  if (lFftSize > 0) and (lSampleRate > 0.0) then
  begin
    lPortionSec := lFftSize / lSampleRate;
    fAlgorithmPortionLabel.Caption := 'порция: ' +
      FormatFloat('0.###', lPortionSec) + ' с';
  end
  else
    fAlgorithmPortionLabel.Caption := 'порция: - с';

  UpdateConfigStr;
end;

procedure TRecorderSettingsDialog.DeleteSelectedAlgorithms;
var
  lNodeList: TList;
  lSelectedNode: TTreeNode;
  lObj: TObject;
  lBinding: TRecorderSpectrumTagBinding;
  lParentNode: TRecorderSpectrumConfigNode;
  I, J: Integer;
begin
  if (fAlgorithmsTree = nil) or (fAlgorithmsTree.SelectionCount = 0) then
    Exit;

  lNodeList := TList.Create;
  try
    for I := 0 to fAlgorithmsTree.SelectionCount - 1 do
      lNodeList.Add(fAlgorithmsTree.Selections[I]);

    fAlgorithmsTree.Items.BeginUpdate;
    try
      // First delete channel bindings (TRecorderSpectrumTagBinding)
      for I := 0 to lNodeList.Count - 1 do
      begin
        lSelectedNode := TTreeNode(lNodeList[I]);
        if lSelectedNode.Data = nil then
          Continue;
        lObj := TObject(lSelectedNode.Data);
        if lObj is TRecorderSpectrumTagBinding then
        begin
          lBinding := TRecorderSpectrumTagBinding(lObj);
          lParentNode := nil;
          if (lSelectedNode.Parent <> nil) and (TObject(lSelectedNode.Parent.Data) is TRecorderSpectrumConfigNode) then
            lParentNode := TRecorderSpectrumConfigNode(lSelectedNode.Parent.Data);

          if lParentNode <> nil then
          begin
            for J := lParentNode.BindingCount - 1 downto 0 do
              if lParentNode.Bindings[J] = lBinding then
              begin
                lParentNode.DeleteBinding(J);
                Break;
              end;
          end;
        end;
      end;

      // Then delete algorithms themselves (TRecorderSpectrumConfigNode)
      for I := 0 to lNodeList.Count - 1 do
      begin
        lSelectedNode := TTreeNode(lNodeList[I]);
        if lSelectedNode.Data = nil then
          Continue;
        lObj := TObject(lSelectedNode.Data);
        if lObj is TRecorderSpectrumConfigNode then
        begin
          for J := fSpectrumConfigTree.NodeCount - 1 downto 0 do
            if fSpectrumConfigTree.Nodes[J] = lObj then
            begin
              fSpectrumConfigTree.DeleteNode(J);
              Break;
            end;
        end;
      end;
    finally
      fAlgorithmsTree.Items.EndUpdate;
    end;
  finally
    lNodeList.Free;
  end;

  PopulateAlgorithmsTree;
end;

function TRecorderSettingsDialog.GetSettingsFromControls(
  const ACurrent: TRecorderSpectrumSettings): TRecorderSpectrumSettings;
var
  lInt: Integer;
begin
  Result := ACurrent;
  if (fAlgorithmFftSizeEdit <> nil) and
    TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lInt) then
    Result.FFTSize := lInt;
  if (fAlgorithmOverlapEdit <> nil) and
    TryStrToInt(Trim(fAlgorithmOverlapEdit.Text), lInt) then
    Result.Overlap := lInt;
  if fAlgorithmSampleRateEdit <> nil then
    Result.SampleRateHz := ReadFloatEdit(fAlgorithmSampleRateEdit, Result.SampleRateHz);
  if (fAlgorithmAverageBlocksEdit <> nil) and
    TryStrToInt(Trim(fAlgorithmAverageBlocksEdit.Text), lInt) then
    Result.AverageBlockCount := lInt;
  if (fAlgorithmOverlapCombo <> nil) and (fAlgorithmOverlapCombo.ItemIndex >= 0) then
    Result.OverlapMode := TRecorderSpectrumOverlapMode(fAlgorithmOverlapCombo.ItemIndex);
  if (fAlgorithmWindowCombo <> nil) and (fAlgorithmWindowCombo.ItemIndex >= 0) then
    Result.WindowKind := TRecorderSpectrumWindowKind(fAlgorithmWindowCombo.ItemIndex);
  if fAlgorithmZeroPadCheck <> nil then
    Result.ZeroPad := fAlgorithmZeroPadCheck.Checked;
  if fAlgorithmAhCorrectionCheck <> nil then
    Result.AhCorrectionEnabled := fAlgorithmAhCorrectionCheck.Checked;
  if (fAlgorithmIntegrationGroup <> nil) and
    (fAlgorithmIntegrationGroup.ItemIndex >= 0) then
    Result.IntegrationMode := TRecorderSpectrumIntegrationMode(fAlgorithmIntegrationGroup.ItemIndex);
  Result.NormalizeMode := snmNone;
end;

procedure TRecorderSettingsDialog.UpdateConfigStr;
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;
  lSettings := GetSettingsFromControls(lNode.Settings);
  if Cfg <> nil then
    Cfg.Text := lSettings.AsString;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    DeleteSelectedAlgorithms;
    Key := 0;
  end;
end;

procedure TRecorderSettingsDialog.fCfgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    btnAlgorithmConfigClick(Sender);
    Key := 0;
  end;
end;

procedure TRecorderSettingsDialog.fAlgorithmFftSizeUpDownClick(Sender: TObject; Button: TUDBtnType);
  function NextPowerOfTwo(AValue: Integer): Integer;
  begin
    Result := 1;
    while Result <= AValue do
      Result := Result * 2;
  end;
  function PreviousPowerOfTwo(AValue: Integer): Integer;
  begin
    if AValue <= 2 then
    begin
      Result := 2;
      Exit;
    end;
    Result := 1;
    while Result < AValue do
      Result := Result * 2;
    Result := Result div 2;
  end;
  function IsPowerOfTwoVal(AValue: Integer): Boolean;
  begin
    Result := (AValue > 0) and ((AValue and (AValue - 1)) = 0);
  end;
var
  lVal: Integer;
begin
  if fAlgorithmFftSizeEdit = nil then
    Exit;

  if not TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lVal) then
    lVal := 8192;

  if lVal < 2 then
    lVal := 2;

  if Button = btNext then
  begin
    if lVal < 1048576 then
    begin
      if not IsPowerOfTwoVal(lVal) then
        lVal := NextPowerOfTwo(lVal)
      else
        lVal := lVal * 2;
    end;
  end
  else
  begin
    if lVal > 2 then
    begin
      if not IsPowerOfTwoVal(lVal) then
        lVal := PreviousPowerOfTwo(lVal)
      else
        lVal := lVal div 2;
    end;
  end;

  fAlgorithmFftSizeEdit.Text := IntToStr(lVal);
  fAlgorithmFftParamChange(fAlgorithmFftSizeEdit);
end;

{ Marks signals already represented in registry. Name matches relink existing tags
  to the freshly reloaded source without creating duplicates. }
procedure TRecorderSettingsDialog.MarkSignalsFromRegistry;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lSourceId: string;
begin
  if (fTagRegistry = nil) or (fMeraSignals = nil) then
    Exit;

  lSourceId := MeraSourceId(fMeraFileName);
  if fMeraFileName <> '' then
    fTagRegistry.RegisterActiveSource(lSourceId);

  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    lSignal.Enabled := FindTagBySourceAddress(lSourceId, lSignal.Address) <> nil;
    lSignal.Selected := lSignal.Enabled;
  end;

  if fMic140Signals <> nil then
    for I := 0 to fMic140Signals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(fMic140Signals[I]);
      lSignal.Selected := SignalHasLinkedTag(lSignal);
    end;
end;

{ Создание или обновление каналов/тегов в реестре на основе выбранных сигналов Mera-файла }
procedure TRecorderSettingsDialog.CreateSelectedMeraTags;
var
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
  lSourceId: string;
  lTagName: string;

  procedure CreateTagsFromSignals(ASignals: TList);
  var
    J: Integer;
  begin
    if ASignals = nil then
      Exit;
    for J := 0 to ASignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(ASignals[J]);
      if (lSignal = nil) or (not lSignal.Selected) then
        Continue;

      lSourceId := SignalSourceId(lSignal);
      if lSourceId <> '' then
        fTagRegistry.RegisterActiveSource(lSourceId);

      lTag := FindTagBySourceAddress(lSourceId, lSignal.Address);
      if lTag = nil then
      begin
        lTagName := MeraSignalToRecorderTagName(lSignal);
        lTag := fTagRegistry.FindByName(lTagName);
        if lTag = nil then
          lTag := fTagRegistry.CreateTag(lTagName, Ceil(Max(4096, lSignal.FrequencyHz)));
      end;

      ApplyMeraSignalToTag(lTag, lSignal);
      lTag.EnsureBufferCapacity(Ceil(Max(4096, lSignal.FrequencyHz)));
    end;
  end;
begin
  if fTagRegistry = nil then
    Exit;

  if (fMeraFileName <> '') and (fMeraSignals <> nil) then
    fTagRegistry.RegisterActiveSource(MeraSourceId(fMeraFileName));

  CreateTagsFromSignals(fMeraSignals);
  CreateTagsFromSignals(fMic140Signals);
end;

procedure TRecorderSettingsDialog.ClearMeraSignals;
begin
  uMeraFile.ClearMeraSignals(fMeraSignals);
end;

procedure TRecorderSettingsDialog.ClearMic140Signals;
begin
  uMeraFile.ClearMeraSignals(fMic140Signals);
end;

procedure TRecorderSettingsDialog.BuildMic140Signals(const ASourceId: string;
  AChannelCount: Integer; APollFrequencyHz: Double; AEnabledChannels: TStrings);
var
  I: Integer;
  lAddress: string;
  lSignal: TMeraSignalInfo;
begin
  if fMic140Signals = nil then
    fMic140Signals := TList.Create;
  for I := fMic140Signals.Count - 1 downto 0 do
  begin
    lSignal := TMeraSignalInfo(fMic140Signals[I]);
    if SameText(lSignal.FileName, ASourceId) then
    begin
      lSignal.Free;
      fMic140Signals.Delete(I);
    end;
  end;

  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  if AChannelCount > MIC140DefaultChannelCount then
    AChannelCount := MIC140MaxChannelCount
  else
    AChannelCount := MIC140DefaultChannelCount;
  if APollFrequencyHz <= 0 then
    APollFrequencyHz := MIC140DefaultPollFrequencyHz;
  APollFrequencyHz := RecorderMic140NormalizeFrequency(APollFrequencyHz);

  for I := 1 to AChannelCount do
  begin
    lAddress := IntToStr(I);
    if (AEnabledChannels <> nil) and (AEnabledChannels.Count > 0) and
      (AEnabledChannels.IndexOf(lAddress) < 0) then
      Continue;

    lSignal := TMeraSignalInfo.Create;
    lSignal.Name := Format('MIC140_%2.2d', [I]);
    lSignal.Address := lAddress;
    lSignal.ModuleName := 'MIC-140';
    lSignal.DataTypeName := 'R8';
    lSignal.DataType := mvtFloat64;
    lSignal.FrequencyHz := APollFrequencyHz;
    lSignal.UnitsName := '';
    lSignal.Description := Format('MIC-140 channel %s', [lAddress]);
    lSignal.FileName := ASourceId;
    lSignal.Enabled := True;
    lSignal.Selected := SignalHasLinkedTag(lSignal);
    fMic140Signals.Add(lSignal);
  end;

  for I := 1 to MIC140TemperatureChannelCount do
  begin
    lAddress := 'T' + IntToStr(I);
    if (AEnabledChannels <> nil) and (AEnabledChannels.Count > 0) and
      (AEnabledChannels.IndexOf(lAddress) < 0) then
      Continue;

    lSignal := TMeraSignalInfo.Create;
    lSignal.Name := Format('MIC140_T%1.1d', [I]);
    lSignal.Address := lAddress;
    lSignal.ModuleName := 'MIC-140';
    lSignal.DataTypeName := 'R4';
    lSignal.DataType := mvtFloat64;
    lSignal.FrequencyHz := APollFrequencyHz;
    lSignal.UnitsName := 'degC';
    lSignal.Description := Format('MIC-140 temperature channel %s', [lAddress]);
    lSignal.FileName := ASourceId;
    lSignal.Enabled := True;
    lSignal.Selected := SignalHasLinkedTag(lSignal);
    fMic140Signals.Add(lSignal);
  end;
end;
procedure TRecorderSettingsDialog.RestoreMeraSignalsFromTags;
const
  CMeraSourcePrefix = 'Mera file: ';
var
  I: Integer;
  lFileName: string;
  lTag: TRecorderTag;
begin
  if (fTagRegistry = nil) or (fMeraSignals = nil) then
    Exit;

  lFileName := '';
  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if Pos(CMeraSourcePrefix, lTag.SourceId) = 1 then
    begin
      lFileName := Trim(Copy(lTag.SourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
      Break;
    end;
  end;

  if lFileName = '' then
  begin
    PopulateHardwareTree;
    PopulateChannelGrids;
    Exit;
  end;

  fMeraFolder := ExtractFilePath(lFileName);
  fMeraFileName := lFileName;
  if FileExists(lFileName) then
  begin
    LoadMeraSignalsFromFile(lFileName, fMeraSignals);
    MarkSignalsFromRegistry;
  end
  else
    ClearMeraSignals;

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

function TRecorderSettingsDialog.FindMeraSignalByTagName(
  const ATagName: string): TMeraSignalInfo;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if fMeraSignals = nil then
    Exit;

  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if SameText(MeraSignalToRecorderTagName(lSignal), ATagName) then
      Exit(lSignal);
  end;
end;

function TRecorderSettingsDialog.FindMic140SignalBySourceAddress(
  const ASourceId, AAddress: string): TMeraSignalInfo;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if fMic140Signals = nil then
    Exit;
  for I := 0 to fMic140Signals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMic140Signals[I]);
    if SameText(lSignal.FileName, ASourceId) and SameText(lSignal.Address, AAddress) then
      Exit(lSignal);
  end;
end;

{ Возвращает Mera-сигнал по строке таблицы доступных каналов }
function TRecorderSettingsDialog.AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
var
  I: Integer;
  lRow: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if ARow < 1 then
    Exit;

  lRow := 0;
  if fMeraSignals <> nil then
  begin
    for I := 0 to fMeraSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(fMeraSignals[I]);
      if SignalHasLinkedTag(lSignal) then
        Continue;
      Inc(lRow);
      if lRow = ARow then
        Exit(lSignal);
    end;
  end;

  if fMic140Signals = nil then
    Exit;
  for I := 0 to fMic140Signals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMic140Signals[I]);
    if SignalHasLinkedTag(lSignal) then
      Continue;
    Inc(lRow);
    if lRow = ARow then
      Exit(lSignal);
  end;
end;

{ Возвращает Mera-сигнал по строке таблицы выбранных каналов }
function TRecorderSettingsDialog.SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
var
  I: Integer;
  lRow: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if (fMeraSignals = nil) or (ARow < 1) then
    Exit;

  lRow := 0;
  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if not SignalHasLinkedTag(lSignal) then
      Continue;
    Inc(lRow);
    if lRow = ARow then
      Exit(lSignal);
  end;
end;

{ Загрузка информации о сигналах из выбранного файла Mera }
procedure TRecorderSettingsDialog.LoadMeraFile(const AFileName: string);
begin
  fMeraFolder := ExtractFilePath(AFileName);
  fMeraFileName := AFileName;
  LoadMeraSignalsFromFile(AFileName, fMeraSignals);
  if fTagRegistry <> nil then
    fTagRegistry.RegisterActiveSource(MeraSourceId(fMeraFileName));
  MarkSignalsFromRegistry;

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

{ Обновление дерева аппаратной части при загрузке файлов Mera }
procedure TRecorderSettingsDialog.DeleteCurrentMeraSource;
var
  I: Integer;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  if fMeraFileName = '' then
    Exit;

  if MessageDlg('Удаление источника данных',
    'Удалить источник данных "' + ExtractFileName(fMeraFileName) + '"?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  lSourceId := MeraSourceId(fMeraFileName);
  if fTagRegistry <> nil then
  begin
    fTagRegistry.UnregisterActiveSource(lSourceId);
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if SameText(lTag.SourceId, lSourceId) then
        lTag.SourceId := 'Detached: ' + lSourceId;
    end;
  end;

  fMeraFileName := '';
  fMeraFolder := '';
  ClearMeraSignals;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.ReloadCurrentMeraSource;
begin
  if fMeraFileName = '' then
    Exit;
  if not FileExists(fMeraFileName) then
  begin
    MessageDlg('Перечитывание источника',
      'Файл источника данных не найден: ' + fMeraFileName,
      mtWarning, [mbOK], 0);
    Exit;
  end;

  LoadMeraSignalsFromFile(fMeraFileName, fMeraSignals);
  MarkSignalsFromRegistry;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.RestoreMic140SignalsFromTags;
var
  I: Integer;
  lChannelCount: Integer;
  lChannelNumber: Integer;
  lAddressNumber: Integer;
  lHost: string;
  lPort: Word;
  lSourceId: string;
  lSources: TStringList;
  lTag: TRecorderTag;
  lFrequencyHz: Double;
begin
  ClearMic140Signals;
  if fTagRegistry = nil then
    Exit;

  lSources := TStringList.Create;
  try
    lSources.CaseSensitive := False;
    lSources.Sorted := False;
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) and
        (lSources.IndexOf(lTag.SourceId) < 0) then
        lSources.Add(lTag.SourceId);
    end;

    for I := 0 to fTagRegistry.ActiveSourceCount - 1 do
    begin
      lSourceId := fTagRegistry.ActiveSourceIds[I];
      if TryParseRecorderMic140SourceId(lSourceId, lHost, lPort) and
        (lSources.IndexOf(lSourceId) < 0) then
        lSources.Add(lSourceId);
    end;

    for I := 0 to lSources.Count - 1 do
    begin
      lSourceId := lSources[I];
      lChannelCount := MIC140DefaultChannelCount;
      lFrequencyHz := MIC140DefaultPollFrequencyHz;
      for lChannelNumber := 0 to fTagRegistry.TagCount - 1 do
      begin
        lTag := fTagRegistry.Tags[lChannelNumber];
        if not SameText(lTag.SourceId, lSourceId) then
          Continue;
        if TryStrToInt(lTag.Address, lAddressNumber) and
          (lAddressNumber > lChannelCount) then
          lChannelCount := MIC140MaxChannelCount;
        if lTag.PollFrequencyHz > 0 then
          lFrequencyHz := lTag.PollFrequencyHz;
      end;
      BuildMic140Signals(lSourceId, lChannelCount, lFrequencyHz, nil);
    end;
  finally
    lSources.Free;
  end;

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.HardwareAddSourceClick(Sender: TObject);
var
  lButton: TButton;
  lCombo: TComboBox;
  lForm: TForm;
begin
  lForm := TForm.Create(Self);
  try
    lForm.Caption := 'Data source';
    lForm.Position := poOwnerFormCenter;
    lForm.BorderStyle := bsDialog;
    lForm.Width := 320;
    lForm.Height := 132;

    lCombo := TComboBox.Create(lForm);
    lCombo.Parent := lForm;
    lCombo.Left := 16;
    lCombo.Top := 16;
    lCombo.Width := 280;
    lCombo.Style := csDropDownList;
    lCombo.Items.Add('MIC-140');
    lCombo.Items.Add('Mera file');
    lCombo.ItemIndex := 0;

    lButton := TButton.Create(lForm);
    lButton.Parent := lForm;
    lButton.Left := 124;
    lButton.Top := 58;
    lButton.Width := 82;
    lButton.Height := 28;
    lButton.Caption := 'OK';
    lButton.Default := True;
    lButton.ModalResult := mrOk;

    lButton := TButton.Create(lForm);
    lButton.Parent := lForm;
    lButton.Left := 214;
    lButton.Top := 58;
    lButton.Width := 82;
    lButton.Height := 28;
    lButton.Caption := 'Cancel';
    lButton.Cancel := True;
    lButton.ModalResult := mrCancel;

    if lForm.ShowModal <> mrOk then
      Exit;
    if SameText(lCombo.Text, 'MIC-140') then
      AddMic140Source
    else
      btnDeviceAddClick(Sender);
  finally
    lForm.Free;
  end;
end;

procedure TRecorderSettingsDialog.HardwareSearchClick(Sender: TObject);
var
  lFound: TStringList;
begin
  lFound := TStringList.Create;
  try
    Screen.Cursor := crHourGlass;
    try
      RecorderMic140Discover(lFound, MIC140DefaultDiscoverySubnet,
        MIC140DefaultPort, 180);
    finally
      Screen.Cursor := crDefault;
    end;
    if lFound.Count = 0 then
    begin
      MessageDlg('MIC-140', 'Device not found in 192.168.14.0/24',
        mtWarning, [mbOK], 0);
      Exit;
    end;
    AddMic140Source(lFound[0]);
  finally
    lFound.Free;
  end;
end;

procedure TRecorderSettingsDialog.AddMic140Source(const APresetHost: string);
var
  lSourceId: string;
begin
  if APresetHost <> '' then
    lSourceId := RecorderMic140SourceId(APresetHost, MIC140DefaultPort)
  else
    lSourceId := '';
  ConfigureMic140Source(lSourceId);
end;

function TRecorderSettingsDialog.SelectedMic140SourceId: string;
var
  lHost: string;
  lNode: TTreeNode;
  lPort: Word;
  lTag: TRecorderTag;
begin
  Result := '';
  if fHardwareTree <> nil then
  begin
    lNode := fHardwareTree.Selected;
    while lNode <> nil do
    begin
      if TObject(lNode.Data) is TRecorderTag then
      begin
        lTag := TRecorderTag(lNode.Data);
        if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
          Exit(lTag.SourceId);
      end;
      if TryParseRecorderMic140SourceId(lNode.Text, lHost, lPort) then
        Exit(RecorderMic140SourceId(lHost, lPort));
      lNode := lNode.Parent;
    end;
  end;

  if fSelectedChannelsGrid <> nil then
  begin
    lTag := SelectedTagByGridRow(fSelectedChannelsGrid.Row);
    if (lTag <> nil) and TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
      Result := lTag.SourceId;
  end;
end;

procedure TRecorderSettingsDialog.ConfigureMic140Source(const ASourceId: string);
var
  I: Integer;
  lCapacity: Integer;
  lChannelNumber: Integer;
  lHost: string;
  lNewSourceId: string;
  lPort: Word;
  lResult: TRecorderMic140DialogResult;
  lTag: TRecorderTag;
begin
  if fTagRegistry = nil then
    Exit;

  InitRecorderMic140DialogResult(lResult);
  try
    if TryParseRecorderMic140SourceId(ASourceId, lHost, lPort) then
    begin
      lResult.Host := lHost;
      lResult.Port := lPort;
      lResult.SelectedChannels.Clear;
      for I := 0 to fTagRegistry.TagCount - 1 do
      begin
        lTag := fTagRegistry.Tags[I];
        if SameText(lTag.SourceId, ASourceId) then
        begin
          lResult.SelectedChannels.Add(lTag.Address);
          if TryStrToInt(lTag.Address, lChannelNumber) and
            (lChannelNumber > lResult.ChannelCount) then
            lResult.ChannelCount := MIC140MaxChannelCount;
          if lTag.PollFrequencyHz > 0 then
            lResult.PollFrequencyHz := lTag.PollFrequencyHz;
        end;
      end;
    end;

    if not ShowRecorderMic140SettingsDialog(Self, lResult) then
      Exit;

    lNewSourceId := RecorderMic140SourceId(lResult.Host, lResult.Port);
    if (ASourceId <> '') and (not SameText(ASourceId, lNewSourceId)) then
      fTagRegistry.UnregisterActiveSource(ASourceId);
    fTagRegistry.RegisterActiveSource(lNewSourceId);
    lResult.PollFrequencyHz := RecorderMic140NormalizeFrequency(lResult.PollFrequencyHz);
    BuildMic140Signals(lNewSourceId, lResult.ChannelCount,
      lResult.PollFrequencyHz, lResult.SelectedChannels);

    lCapacity := Ceil(Max(4096, lResult.PollFrequencyHz));
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if (not SameText(lTag.SourceId, lNewSourceId)) and
        ((ASourceId = '') or (not SameText(lTag.SourceId, ASourceId))) then
        Continue;
      if (lResult.SelectedChannels.Count > 0) and
        (lResult.SelectedChannels.IndexOf(lTag.Address) < 0) then
        Continue;
      lTag.SourceId := lNewSourceId;
      lTag.ModuleType := 'MIC-140';
      lTag.PollFrequencyHz := lResult.PollFrequencyHz;
      lTag.UnitName := '';
      lTag.Description := Format('MIC-140 channel %s; freq=%s Hz',
        [lTag.Address, FormatFloat('0.######', lResult.PollFrequencyHz)]);
      lTag.EnsureBufferCapacity(lCapacity);
    end;

    PopulateHardwareTree;
    PopulateChannelGrids;
  finally
    DoneRecorderMic140DialogResult(lResult);
  end;
end;

procedure TRecorderSettingsDialog.DeleteMic140Source(const ASourceId: string);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  if (ASourceId = '') or (fTagRegistry = nil) then
    Exit;
  if MessageDlg('MIC-140', 'Remove source "' + ASourceId + '"?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  fTagRegistry.UnregisterActiveSource(ASourceId);
  for I := fMic140Signals.Count - 1 downto 0 do
    if SameText(TMeraSignalInfo(fMic140Signals[I]).FileName, ASourceId) then
    begin
      TObject(fMic140Signals[I]).Free;
      fMic140Signals.Delete(I);
    end;
  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) then
      lTag.SourceId := 'Detached: ' + ASourceId;
  end;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.HardwareDeleteSourceClick(Sender: TObject);
begin
  if SelectedMic140SourceId <> '' then
    DeleteMic140Source(SelectedMic140SourceId)
  else
    DeleteCurrentMeraSource;
end;

procedure TRecorderSettingsDialog.HardwareReloadSourceClick(Sender: TObject);
begin
  ReloadCurrentMeraSource;
end;

procedure TRecorderSettingsDialog.HardwareEditSourceClick(Sender: TObject);
var
  lDialog: TOpenDialog;
  lOldSourceId, lNewSourceId: string;
  I: Integer;
  lTag: TRecorderTag;
begin
  if SelectedMic140SourceId <> '' then
  begin
    ConfigureMic140Source(SelectedMic140SourceId);
    Exit;
  end;

  if fMeraFileName = '' then
    Exit;

  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Выберите файл Mera';
    lDialog.Filter := 'Mera file (*.mera)|*.mera|All files (*.*)|*.*';
    lDialog.InitialDir := ExtractFilePath(fMeraFileName);
    lDialog.FileName := ExtractFileName(fMeraFileName);
    if lDialog.Execute then
    begin
      lOldSourceId := MeraSourceId(fMeraFileName);
      fMeraFileName := lDialog.FileName;
      fMeraFolder := ExtractFilePath(lDialog.FileName);
      lNewSourceId := MeraSourceId(fMeraFileName);

      if fTagRegistry <> nil then
      begin
        fTagRegistry.RegisterActiveSource(lNewSourceId);
        for I := 0 to fTagRegistry.TagCount - 1 do
        begin
          lTag := fTagRegistry.Tags[I];
          if SameText(lTag.SourceId, lOldSourceId) then
            lTag.SourceId := lNewSourceId;
        end;
      end;

      if FileExists(fMeraFileName) then
      begin
        LoadMeraSignalsFromFile(fMeraFileName, fMeraSignals);
        MarkSignalsFromRegistry;
      end
      else
        ClearMeraSignals;

      PopulateHardwareTree;
      PopulateChannelGrids;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderSettingsDialog.PopulateHardwareTree;
var
  lRootNode: TTreeNode;
  lSourceNode: TTreeNode;
  I: Integer;
  lRow: Integer;
  lSignal: TMeraSignalInfo;
  lSourceIds: TStringList;
  lSourceId: string;
begin
  if fHardwareTree = nil then
    Exit;

  lSourceIds := TStringList.Create;
  fHardwareTree.Items.BeginUpdate;
  try
    fHardwareTree.Items.Clear;
    lRootNode := fHardwareTree.Items.Add(nil, 'Устройства');
    lRootNode.ImageIndex := CDeviceRootImageIndex;
    lRootNode.SelectedIndex := CDeviceRootImageIndex;

    if fMeraFileName <> '' then
    begin
      lSourceNode := fHardwareTree.Items.AddChild(lRootNode,
        'Mera File - ' + ExtractFileName(fMeraFileName));
      if FileExists(fMeraFileName) then
      begin
        lSourceNode.ImageIndex := CDeviceControllerImageIndex;
        lSourceNode.SelectedIndex := CDeviceControllerImageIndex;
      end
      else
      begin
        lSourceNode.ImageIndex := 31;
        lSourceNode.SelectedIndex := 31;
      end;

      for I := 0 to fMeraSignals.Count - 1 do
      begin
        lSignal := TMeraSignalInfo(fMeraSignals[I]);
        if lSignal.Enabled then
          with fHardwareTree.Items.AddChild(lSourceNode, '[x] ' + lSignal.Name) do
          begin
            ImageIndex := CDeviceModuleImageIndex;
            SelectedIndex := CDeviceModuleImageIndex;
            Data := lSignal;
          end
        else
          with fHardwareTree.Items.AddChild(lSourceNode, '[ ] ' + lSignal.Name) do
        begin
          ImageIndex := CDeviceModuleImageIndex;
          SelectedIndex := CDeviceModuleImageIndex;
          Data := lSignal;
        end;
      end;
      lSourceNode.Expand(True);
    end;

    if fMic140Signals <> nil then
    begin
      lSourceIds.CaseSensitive := False;
      lSourceIds.Sorted := False;
      for I := 0 to fMic140Signals.Count - 1 do
      begin
        lSignal := TMeraSignalInfo(fMic140Signals[I]);
        if (lSignal.FileName <> '') and (lSourceIds.IndexOf(lSignal.FileName) < 0) then
          lSourceIds.Add(lSignal.FileName);
      end;

      for I := 0 to lSourceIds.Count - 1 do
      begin
        lSourceId := lSourceIds[I];
        lSourceNode := fHardwareTree.Items.AddChild(lRootNode, lSourceId);
        lSourceNode.ImageIndex := CDeviceControllerImageIndex;
        lSourceNode.SelectedIndex := CDeviceControllerImageIndex;
        for lRow := 0 to fMic140Signals.Count - 1 do
        begin
          lSignal := TMeraSignalInfo(fMic140Signals[lRow]);
          if not SameText(lSignal.FileName, lSourceId) then
            Continue;
          if SignalHasLinkedTag(lSignal) then
            with fHardwareTree.Items.AddChild(lSourceNode, '[x] ' + lSignal.Name) do
            begin
              ImageIndex := CDeviceModuleImageIndex;
              SelectedIndex := CDeviceModuleImageIndex;
              Data := lSignal;
            end
          else
            with fHardwareTree.Items.AddChild(lSourceNode, '[ ] ' + lSignal.Name) do
            begin
              ImageIndex := CDeviceModuleImageIndex;
              SelectedIndex := CDeviceModuleImageIndex;
              Data := lSignal;
            end;
        end;
        lSourceNode.Expand(True);
      end;
    end;

    lRootNode.Expand(True);
  finally
    fHardwareTree.Items.EndUpdate;
    lSourceIds.Free;
  end;
end;

{ Установка заголовков сеток каналов }
procedure TRecorderSettingsDialog.SetGridHeaders;
begin
  if fAvailableChannelsGrid <> nil then
  begin
    fAvailableChannelsGrid.ColCount := 3;
    fAvailableChannelsGrid.FixedRows := 1;
    fAvailableChannelsGrid.RowCount := 2;
    fAvailableChannelsGrid.Cells[0, 0] := 'Адрес';
    fAvailableChannelsGrid.Cells[1, 0] := 'Тип';
    fAvailableChannelsGrid.Cells[2, 0] := 'Имя';
    fAvailableChannelsGrid.Cells[0, 1] := '';
    fAvailableChannelsGrid.Cells[1, 1] := '';
    fAvailableChannelsGrid.Cells[2, 1] := '';
  end;

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelsGrid.ColCount := 8;
    fSelectedChannelsGrid.FixedRows := 1;
    fSelectedChannelsGrid.RowCount := 2;
    fSelectedChannelsGrid.Cells[0, 0] := 'Имя';
    fSelectedChannelsGrid.Cells[1, 0] := 'Адрес';
    fSelectedChannelsGrid.Cells[2, 0] := 'Тип';
    fSelectedChannelsGrid.Cells[3, 0] := 'Частота';
    fSelectedChannelsGrid.Cells[4, 0] := 'ГХ';
    fSelectedChannelsGrid.Cells[5, 0] := 'Группа';
    fSelectedChannelsGrid.Cells[6, 0] := 'Информация';
    fSelectedChannelsGrid.Cells[7, 0] := 'ID';
    fSelectedChannelsGrid.Cells[0, 1] := '';
    fSelectedChannelsGrid.Cells[1, 1] := '';
    fSelectedChannelsGrid.Cells[2, 1] := '';
    fSelectedChannelsGrid.Cells[3, 1] := '';
    fSelectedChannelsGrid.Cells[4, 1] := '';
    fSelectedChannelsGrid.Cells[5, 1] := '';
    fSelectedChannelsGrid.Cells[6, 1] := '';
    fSelectedChannelsGrid.Cells[7, 1] := '';
  end;
end;

{ Заполнение сеток доступных и выбранных каналов на основе fMeraSignals }
procedure TRecorderSettingsDialog.PopulateChannelGrids;
var
  I: Integer;
  lRow: Integer;
  lEnabledCount: Integer;
  lHost: string;
  lPort: Word;
  lSelectedTags: TList;
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;

  procedure CountAvailableSignals(ASignals: TList);
  var
    J: Integer;
  begin
    if ASignals = nil then
      Exit;
    for J := 0 to ASignals.Count - 1 do
      if not SignalHasLinkedTag(TMeraSignalInfo(ASignals[J])) then
        Inc(lEnabledCount);
  end;

  procedure FillAvailableSignals(ASignals: TList);
  var
    J: Integer;
  begin
    if ASignals = nil then
      Exit;
    for J := 0 to ASignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(ASignals[J]);
      if SignalHasLinkedTag(lSignal) then
        Continue;
      fAvailableChannelsGrid.Cells[0, lRow] := lSignal.Address;
      fAvailableChannelsGrid.Cells[1, lRow] := lSignal.ModuleName;
      fAvailableChannelsGrid.Cells[2, lRow] := lSignal.Name;
      Inc(lRow);
    end;
  end;
begin
  SetGridHeaders;

  if fAvailableChannelsGrid <> nil then
  begin
    lEnabledCount := 0;
    CountAvailableSignals(fMeraSignals);
    CountAvailableSignals(fMic140Signals);

    if lEnabledCount = 0 then
      fAvailableChannelsGrid.RowCount := 2
    else
      fAvailableChannelsGrid.RowCount := lEnabledCount + 1;
    lRow := 1;
    FillAvailableSignals(fMeraSignals);
    FillAvailableSignals(fMic140Signals);
  end;

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelTags.Clear;
    lSelectedTags := TList.Create;
    try
      if fTagRegistry <> nil then
        for I := 0 to fTagRegistry.TagCount - 1 do
        begin
          lTag := fTagRegistry.Tags[I];
          lSelectedTags.Add(lTag);
        end;

      SortSelectedTags(lSelectedTags);

      if lSelectedTags.Count = 0 then
        fSelectedChannelsGrid.RowCount := 2
      else
        fSelectedChannelsGrid.RowCount := lSelectedTags.Count + 1;

      lRow := 1;
      for I := 0 to lSelectedTags.Count - 1 do
      begin
        lTag := TRecorderTag(lSelectedTags[I]);
        fSelectedChannelTags.Add(lTag);
        fSelectedChannelsGrid.Cells[0, lRow] := lTag.Name;
        fSelectedChannelsGrid.Cells[1, lRow] := lTag.Address;
        fSelectedChannelsGrid.Cells[2, lRow] := lTag.ModuleType;
        fSelectedChannelsGrid.Cells[3, lRow] := FormatFloat('0.######', lTag.PollFrequencyHz);
        fSelectedChannelsGrid.Cells[4, lRow] := '-';
        if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
          fSelectedChannelsGrid.Cells[5, lRow] := 'MIC-140'
        else if Pos('Mera file:', lTag.SourceId) = 1 then
          fSelectedChannelsGrid.Cells[5, lRow] := 'Mera File'
        else
          fSelectedChannelsGrid.Cells[5, lRow] := lTag.SourceId;
        fSelectedChannelsGrid.Cells[6, lRow] := lTag.Description;
        fSelectedChannelsGrid.Cells[7, lRow] := IntToStr(lTag.Id);
        Inc(lRow);
      end;
    finally
      lSelectedTags.Free;
    end;
  end;

  SGChange(fAvailableChannelsGrid);
  SGChange(fSelectedChannelsGrid);
end;

{ Переключение активности сигнала по двойному клику в дереве аппаратных модулей }
procedure TRecorderSettingsDialog.ToggleHardwareSignal(ANode: TTreeNode);
var
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
begin
  if (ANode = nil) or (ANode.Data = nil) then
    Exit;

  lSignal := TMeraSignalInfo(ANode.Data);
  if SameText(lSignal.ModuleName, 'MIC-140') then
  begin
    lTag := FindTagBySourceAddress(SignalSourceId(lSignal), lSignal.Address);
    if lTag <> nil then
      fTagRegistry.RemoveTag(lTag)
    else
    begin
      lSignal.Selected := True;
      CreateSelectedMeraTags;
      lSignal.Selected := False;
    end;
    PopulateHardwareTree;
    PopulateChannelGrids;
    Exit;
  end;

  lSignal.Enabled := not lSignal.Enabled;
  if not lSignal.Enabled then
    lSignal.Selected := False;

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.InitializeHardwareTree;
var
  lPopup: TPopupMenu;
  lItem: TMenuItem;
begin
  if fHardwareTree = nil then
    Exit;

  fHardwareTree.OnKeyDown := @fHardwareTreeKeyDown;
  if fHardwareTree.PopupMenu = nil then
  begin
    lPopup := TPopupMenu.Create(Self);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Перечитать теги источника';
    lItem.OnClick := @HardwareReloadSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Настройка источника...';
    lItem.OnClick := @HardwareEditSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Удалить источник данных';
    lItem.OnClick := @HardwareDeleteSourceClick;
    lPopup.Items.Add(lItem);

    fHardwareTree.PopupMenu := lPopup;
  end;

  fHardwareTree.Items.BeginUpdate;
  try
    fHardwareTree.ReadOnly := True;
    fHardwareTree.Options := fHardwareTree.Options + [tvoShowButtons, tvoShowLines, tvoShowRoot];
    fHardwareTree.ImagesWidth := 16;
    PopulateHardwareTree;
  finally
    fHardwareTree.Items.EndUpdate;
  end;
end;

{ Динамическое создание пользовательского интерфейса }
procedure TRecorderSettingsDialog.BuildUi;
var
  lButtonPanel: TPanel;
  lButton: TButton;
  lTab: TTabSheet;
begin
  Caption := 'Настройка';
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  Width := 890;
  Height := 660;
  Constraints.MinWidth := 760;
  Constraints.MinHeight := 520;

  fPageControl := TPageControl.Create(Self);
  fPageControl.Parent := Self;
  fPageControl.Align := alClient;

  lTab := TTabSheet.Create(Self);
  lTab.PageControl := fPageControl;
  lTab.Caption := 'Рекордер';
  BuildRecorderTab(lTab);

  lTab := TTabSheet.Create(Self);
  lTab.PageControl := fPageControl;
  lTab.Caption := 'Аппаратные свойства';
  BuildHardwareTab(lTab);

  BuildPlaceholderTab('Каналы');
  BuildPlaceholderTab('Плагины');

  lButtonPanel := TPanel.Create(Self);
  lButtonPanel.Parent := Self;
  lButtonPanel.Align := alBottom;
  lButtonPanel.Height := 42;
  lButtonPanel.BevelOuter := bvNone;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := Width - 270;
  lButton.Top := 7;
  lButton.AnchorSideRight.Control := lButtonPanel;
  lButton.AnchorSideRight.Side := asrRight;
  lButton.Anchors := [akTop, akRight];
  lButton.Caption := 'OK';
  lButton.Default := True;
  lButton.OnClick := @OkButtonClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := Width - 182;
  lButton.Top := 7;
  lButton.AnchorSideRight.Control := lButtonPanel;
  lButton.AnchorSideRight.Side := asrRight;
  lButton.Anchors := [akTop, akRight];
  lButton.Caption := 'Закрыть';
  lButton.Cancel := True;
  lButton.ModalResult := mrCancel;

  fApplyButton := TButton.Create(Self);
  fApplyButton.Parent := lButtonPanel;
  fApplyButton.Width := 82;
  fApplyButton.Height := 28;
  fApplyButton.Left := Width - 94;
  fApplyButton.Top := 7;
  fApplyButton.AnchorSideRight.Control := lButtonPanel;
  fApplyButton.AnchorSideRight.Side := asrRight;
  fApplyButton.Anchors := [akTop, akRight];
  fApplyButton.Caption := 'Применить';
  fApplyButton.OnClick := @ApplyButtonClick;
end;

{ Конструирование вкладки общих настроек }
procedure TRecorderSettingsDialog.BuildRecorderTab(ATab: TTabSheet);
var
  lLeftPanel: TPanel;
  lRightPanel: TPanel;
  lGroup: TGroupBox;
  lButton: TButton;
begin
  lLeftPanel := TPanel.Create(Self);
  lLeftPanel.Parent := ATab;
  lLeftPanel.Align := alClient;
  lLeftPanel.BevelOuter := bvNone;

  lRightPanel := TPanel.Create(Self);
  lRightPanel.Parent := ATab;
  lRightPanel.Align := alRight;
  lRightPanel.Width := 230;
  lRightPanel.BevelOuter := bvNone;

  lGroup := AddGroup(Self, lLeftPanel, 8, 8, 210, 82, 'Отображение');
  AddLabel(Self, lGroup, 10, 22, 'Период обновления');
  fScreenUpdateEdit := AddEdit(Self, lGroup, 126, 18, 56, '0.5');
  AddLabel(Self, lGroup, 186, 22, 'с');

  lGroup := AddGroup(Self, lLeftPanel, 238, 8, 390, 82, 'Сигналы');
  AddLabel(Self, lGroup, 10, 18, 'Длина отображаемых данных');
  fBufferSecondsEdit := AddEdit(Self, lGroup, 190, 14, 64, '1');
  AddLabel(Self, lGroup, 260, 18, 'с');
  AddLabel(Self, lGroup, 10, 40, 'Период обновления данных');
  fDataUpdateEdit := AddEdit(Self, lGroup, 190, 36, 64, '0.3');
  AddLabel(Self, lGroup, 260, 40, 'с');

  lGroup := AddGroup(Self, lLeftPanel, 8, 102, 620, 78, '');
  AddLabel(Self, lGroup, 10, 18, 'Испытание');
  fTestNameEdit := AddEdit(Self, lGroup, 130, 14, 470, 'Испытание');
  AddLabel(Self, lGroup, 10, 42, 'Изделие');
  fProductNameEdit := AddEdit(Self, lGroup, 130, 42, 470, 'Изделие');

  lGroup := AddGroup(Self, lLeftPanel, 8, 190, 620, 284, 'Запись');
  fModifyNameCheck := AddCheck(Self, lGroup, 12, 22,
    'Модифицировать имя по каждому испытанию');
  fModifyNameCheck.Enabled := False;
  fPrehistoryCheck := AddCheck(Self, lGroup, 12, 48, 'Предыстория');
  fPrehistoryEdit := AddEdit(Self, lGroup, 130, 44, 68, '10');
  AddLabel(Self, lGroup, 206, 48, 'сек');
  fResetTimeCheck := AddCheck(Self, lGroup, 12, 74,
    'Сброс времени при начале записи');
  fWriteWithPausesCheck := AddCheck(Self, lGroup, 12, 100, 'Запись с паузами');
  fSaveConfigWithDataCheck := AddCheck(Self, lGroup, 12, 126,
    'Сохранять файл конфигурации вместе с записью данных');
  AddLabel(Self, lGroup, 10, 154, 'Рабочий каталог');
  fWorkDirEdit := AddEdit(Self, lGroup, 10, 172, 526, 'C:\USML\');
  lButton := TButton.Create(Self);
  lButton.Parent := lGroup;
  lButton.Left := 548;
  lButton.Top := 170;
  lButton.Width := 54;
  lButton.Height := 26;
  lButton.Caption := '...';
  lButton.OnClick := @WorkDirBrowseClick;
  fTemplateCheck := AddCheck(Self, lGroup, 12, 204, 'Шаблон');
  fTemplateButton := TButton.Create(Self);
  fTemplateButton.Parent := lGroup;
  fTemplateButton.Left := 84;
  fTemplateButton.Top := 200;
  fTemplateButton.Width := 86;
  fTemplateButton.Height := 26;
  fTemplateButton.Caption := 'Настроить';
  fTemplateButton.Enabled := False;
  fFrameDirEdit := AddEdit(Self, lGroup, 10, 232, 470, 'C:\USML\signal0000');

  lGroup := AddGroup(Self, lRightPanel, 8, 8, 210, 142, 'Условия старта записи');
  fStartManualRadio := AddRadio(Self, lGroup, 10, 20, 'По клавише', @ConditionChanged);
  fStartLevelRadio := AddRadio(Self, lGroup, 104, 20, 'По уровню', @ConditionChanged);
  fStartTriggerRadio := AddRadio(Self, lGroup, 10, 46, 'Триггерный старт', @ConditionChanged);
  fStartTriggerEdit := AddEdit(Self, lGroup, 140, 42, 48, '1');
  AddLabel(Self, lGroup, 10, 76, 'Канал');
  fStartChannelCombo := AddCombo(Self, lGroup, 52, 72, 136);
  fStartEdgeCombo := AddCombo(Self, lGroup, 10, 100, 74);
  fStartEdgeCombo.Items.Add('меньше');
  fStartEdgeCombo.Items.Add('больше');
  fStartLevelEdit := AddEdit(Self, lGroup, 92, 100, 72, '0.0');

  lGroup := AddGroup(Self, lRightPanel, 8, 160, 210, 170, 'Условия останова записи');
  fStopManualRadio := AddRadio(Self, lGroup, 10, 20, 'По клавише', @ConditionChanged);
  fStopLevelRadio := AddRadio(Self, lGroup, 104, 20, 'По уровню', @ConditionChanged);
  fStopDurationRadio := AddRadio(Self, lGroup, 10, 46, 'Через', @ConditionChanged);
  fStopDurationEdit := AddEdit(Self, lGroup, 70, 42, 74, '1.000000');
  AddLabel(Self, lGroup, 152, 46, 'сек');
  AddLabel(Self, lGroup, 10, 76, 'Канал');
  fStopChannelCombo := AddCombo(Self, lGroup, 52, 72, 136);
  fStopEdgeCombo := AddCombo(Self, lGroup, 10, 100, 74);
  fStopEdgeCombo.Items.Add('меньше');
  fStopEdgeCombo.Items.Add('больше');
  fStopLevelEdit := AddEdit(Self, lGroup, 92, 100, 72, '0.0');
  fStopReturnToPreviewCheck := AddCheck(Self, lGroup, 10, 126, 'Переход в просмотр');
  fStopReturnToPreviewCheck.Enabled := False;

  lButton := TButton.Create(Self);
  lButton.Parent := lRightPanel;
  lButton.Left := 8;
  lButton.Top := 342;
  lButton.Width := 122;
  lButton.Height := 28;
  lButton.Caption := 'Системное время';

  fStartChannelCombo.Items.Add('MemTag');
  fStartChannelCombo.Items.Add('SineTag');
  fStopChannelCombo.Items.Add('MemTag');
  fStopChannelCombo.Items.Add('SineTag');
end;

{ Конструирование вкладки дерева оборудования и устройств }
procedure TRecorderSettingsDialog.BuildHardwareTab(ATab: TTabSheet);
var
  lGroup: TGroupBox;
  lRootNode: TTreeNode;
  lControllerNode: TTreeNode;
  lButtonPanel: TPanel;
  lButton: TButton;
begin
  lGroup := AddGroup(Self, ATab, 8, 8, 858, 560, 'Устройства');
  lGroup.AnchorSideRight.Control := ATab;
  lGroup.AnchorSideRight.Side := asrRight;
  lGroup.AnchorSideBottom.Control := ATab;
  lGroup.AnchorSideBottom.Side := asrBottom;
  lGroup.Anchors := [akLeft, akTop, akRight, akBottom];

  lButtonPanel := TPanel.Create(Self);
  lButtonPanel.Parent := lGroup;
  lButtonPanel.Align := alBottom;
  lButtonPanel.Height := 52;
  lButtonPanel.BevelOuter := bvNone;

  fHardwareTree := TTreeView.Create(Self);
  fHardwareTree.Parent := lGroup;
  fHardwareTree.Align := alClient;
  fHardwareTree.ReadOnly := True;
  fHardwareTree.Images := fDeviceImageList;
  fHardwareTree.OnKeyDown := @fHardwareTreeKeyDown;
  fHardwareTree.Options := fHardwareTree.Options + [tvoShowButtons, tvoShowLines, tvoShowRoot];

  lRootNode := fHardwareTree.Items.Add(nil, 'Устройства');
  lRootNode.ImageIndex := CDeviceRootImageIndex;
  lRootNode.SelectedIndex := CDeviceRootImageIndex;
  lControllerNode := fHardwareTree.Items.AddChild(lRootNode,
    '[1] МС-Крейт - ISA Крейт-контроллер s/n: 0000');
  lControllerNode.ImageIndex := CDeviceControllerImageIndex;
  lControllerNode.SelectedIndex := CDeviceControllerImageIndex;
  with fHardwareTree.Items.AddChild(lControllerNode,
    'Слот 1 - MC-212 с/н:00000 - Тензомодуль 4 канала v4.0-v5.0') do
  begin
    ImageIndex := CDeviceModuleImageIndex;
    SelectedIndex := CDeviceModuleImageIndex;
  end;
  lRootNode.Expand(True);
  lControllerNode.Expand(True);

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 8;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '+';
  lButton.Hint := 'Добавить устройство вручную';
  lButton.ShowHint := True;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 62;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '-';
  lButton.Hint := 'Удалить устройство вручную';
  lButton.ShowHint := True;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 116;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '...';
  lButton.Hint := 'Настроить выбранное устройство';
  lButton.ShowHint := True;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 170;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '?';
  lButton.Hint := 'Автопоиск подключенных устройств';
  lButton.ShowHint := True;
end;

{ Вспомогательная заглушка вкладки для ещё не разработанных компонентов }
procedure TRecorderSettingsDialog.BuildPlaceholderTab(const ACaption: string);
var
  lTab: TTabSheet;
  lLabel: TLabel;
begin
  lTab := TTabSheet.Create(Self);
  lTab.PageControl := fPageControl;
  lTab.Caption := ACaption;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := lTab;
  lLabel.Left := 16;
  lLabel.Top := 16;
  lLabel.Caption := 'Раздел будет заполнен после появления соответствующей модели.';
end;

{ Чтение конфигурации из объекта TRecorderRunControlSettings в UI элементы диалога }
procedure TRecorderSettingsDialog.LoadFromSettings;
begin
  if fRunSettings = nil then
    Exit;

  fStartManualRadio.Checked := fRunSettings.StartCondition = rscManual;
  fStartLevelRadio.Checked := fRunSettings.StartCondition = rscSignalLevel;
  fStartTriggerRadio.Checked := fRunSettings.StartCondition = rscExternalTrigger;
  fStartChannelCombo.Text := fRunSettings.StartChannelName;
  fStartEdgeCombo.ItemIndex := Ord(fRunSettings.StartEdge);
  fStartLevelEdit.Text := FloatToStr(fRunSettings.StartLevel);

  fStopManualRadio.Checked := fRunSettings.StopCondition = rstopManual;
  fStopLevelRadio.Checked := fRunSettings.StopCondition = rstopSignalLevel;
  fStopDurationRadio.Checked := fRunSettings.StopCondition = rstopDuration;
  fStopDurationEdit.Text := FormatFloat('0.000000', fRunSettings.StopDelayMs / 1000);
  fStopChannelCombo.Text := fRunSettings.StopChannelName;
  fStopEdgeCombo.ItemIndex := Ord(fRunSettings.StopEdge);
  fStopLevelEdit.Text := FloatToStr(fRunSettings.StopLevel);

  if fStartChannelCombo.Text = '' then
    fStartChannelCombo.Text := 'MemTag';
  if fStopChannelCombo.Text = '' then
    fStopChannelCombo.Text := 'MemTag';

  fScreenUpdateEdit.Text := FormatFloat('0.###', fRunSettings.ScreenUpdateMs / 1000);
  fBufferSecondsEdit.Text := FormatFloat('0.###', fRunSettings.DisplayBufferMs / 1000);
  fDataUpdateEdit.Text := FormatFloat('0.###', fRunSettings.DataUpdateMs / 1000);
  fWorkDirEdit.Text := IncludeTrailingPathDelimiter(fRunSettings.RecordRootDir);
  fFrameDirEdit.Text := IncludeTrailingPathDelimiter(fRunSettings.RecordRootDir) + '0001';
  fResetTimeCheck.Checked := True;

  UpdateConditionControls;
end;

{ Перенос настроек из UI в объект fRunSettings }
procedure TRecorderSettingsDialog.StoreToSettings;
begin
  if fRunSettings = nil then
    Exit;

  if fStartLevelRadio.Checked then
    fRunSettings.StartCondition := rscSignalLevel
  else if fStartTriggerRadio.Checked then
    fRunSettings.StartCondition := rscExternalTrigger
  else
    fRunSettings.StartCondition := rscManual;

  fRunSettings.StartChannelName := fStartChannelCombo.Text;
  fRunSettings.StartEdge := TRecorderSignalEdge(fStartEdgeCombo.ItemIndex);
  fRunSettings.StartLevel := ReadFloatEdit(fStartLevelEdit, fRunSettings.StartLevel);

  if fStopLevelRadio.Checked then
    fRunSettings.StopCondition := rstopSignalLevel
  else if fStopDurationRadio.Checked then
    fRunSettings.StopCondition := rstopDuration
  else
    fRunSettings.StopCondition := rstopManual;

  fRunSettings.StopChannelName := fStopChannelCombo.Text;
  fRunSettings.StopEdge := TRecorderSignalEdge(fStopEdgeCombo.ItemIndex);
  fRunSettings.StopLevel := ReadFloatEdit(fStopLevelEdit, fRunSettings.StopLevel);
  fRunSettings.StopDelayMs := ReadSecondsAsMs(fStopDurationEdit, fRunSettings.StopDelayMs);
  fRunSettings.ScreenUpdateMs := ReadSecondsAsMs(fScreenUpdateEdit,
    fRunSettings.ScreenUpdateMs);
  fRunSettings.DisplayBufferMs := ReadSecondsAsMs(fBufferSecondsEdit,
    fRunSettings.DisplayBufferMs);
  fRunSettings.DataUpdateMs := ReadSecondsAsMs(fDataUpdateEdit,
    fRunSettings.DataUpdateMs);
  fRunSettings.RecordRootDir := IncludeTrailingPathDelimiter(Trim(fWorkDirEdit.Text));
  fRunSettings.RequireValid;
  if fTagRegistry <> nil then
    fTagRegistry.SpectrumConfigs.Assign(fSpectrumConfigTree);
end;

{ Включение/выключение контроллеров в зависимости от выбранных триггеров старта/останова }
procedure TRecorderSettingsDialog.UpdateConditionControls;
var
  lStartLevel: Boolean;
  lStopLevel: Boolean;
  lStopDuration: Boolean;
begin
  lStartLevel := fStartLevelRadio.Checked;
  fStartChannelCombo.Enabled := lStartLevel;
  fStartEdgeCombo.Enabled := lStartLevel;
  fStartLevelEdit.Enabled := lStartLevel;
  fStartTriggerEdit.Enabled := fStartTriggerRadio.Checked;

  lStopLevel := fStopLevelRadio.Checked;
  lStopDuration := fStopDurationRadio.Checked;
  fStopChannelCombo.Enabled := lStopLevel;
  fStopEdgeCombo.Enabled := lStopLevel;
  fStopLevelEdit.Enabled := lStopLevel;
  fStopDurationEdit.Enabled := lStopDuration;
end;

{ Безопасное чтение вещественного числа из TEdit с учётом локали }
function TRecorderSettingsDialog.ReadFloatEdit(AEdit: TEdit; ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AEdit.Text);
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  if not TryStrToFloat(lText, Result) then
    Result := ADefault;
end;

{ Чтение секунд из UI и перевод в миллисекунды }
function TRecorderSettingsDialog.ReadSecondsAsMs(AEdit: TEdit;
  ADefaultMs: Cardinal): Cardinal;
var
  lSeconds: Double;
begin
  lSeconds := ReadFloatEdit(AEdit, ADefaultMs / 1000);
  if lSeconds < 0 then
    lSeconds := 0;
  Result := Round(lSeconds * 1000);
end;


procedure TRecorderSettingsDialog.WorkDirBrowseClick(Sender: TObject);
var
  lDir: string;
begin
  lDir := Trim(fWorkDirEdit.Text);
  if lDir = '' then
    lDir := 'C:\USML\';
  if not SelectDirectory('Выберите рабочий каталог для записи MERA-файлов', '', lDir) then
    Exit;
  fWorkDirEdit.Text := IncludeTrailingPathDelimiter(lDir);
  fFrameDirEdit.Text := IncludeTrailingPathDelimiter(lDir) + '0001';
end;
procedure TRecorderSettingsDialog.ApplyButtonClick(Sender: TObject);
begin
  StoreToSettings;
end;



procedure TRecorderSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToSettings;
  CreateSelectedMeraTags;
  ModalResult := mrOk;
end;

procedure TRecorderSettingsDialog.ConditionChanged(Sender: TObject);
begin
  UpdateConditionControls;
end;

{ Добавление нового устройства путём импорта сигналов из файла Mera }
procedure TRecorderSettingsDialog.btnDeviceAddClick(Sender: TObject);
var
  lDialog: TOpenDialog;
begin
  if MessageDlg('Добавление устройства', 'Mera file', mtConfirmation,
    [mbOK, mbCancel], 0) <> mrOk then
    Exit;

  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Mera file';
    lDialog.Filter := 'Mera file (*.mera)|*.mera|All files (*.*)|*.*';
    lDialog.InitialDir := ExtractFilePath(CMeraSampleFile);
    lDialog.FileName := ExtractFileName(CMeraSampleFile);
    if lDialog.Execute then
    begin
      LoadMeraFile(lDialog.FileName);
      if fPageControl <> nil then
        fPageControl.ActivePageIndex := 1;
    end;
  finally
    lDialog.Free;
  end;
end;

{ Добавление каналов в активный список }
procedure TRecorderSettingsDialog.btnChannelAddClick(Sender: TObject);
var
  lSignal: TMeraSignalInfo;
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
begin
  if fAvailableChannelsGrid = nil then
    Exit;

  lSelection := fAvailableChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  for lRow := lBottom downto lTop do
  begin
    lSignal := AvailableSignalByGridRow(lRow);
    if lSignal <> nil then
      lSignal.Selected := True;
  end;
  CreateSelectedMeraTags;
  MarkSignalsFromRegistry;
  PopulateChannelGrids;
end;

{ Исключение каналов из активного списка }
procedure TRecorderSettingsDialog.btnChannelRemoveClick(Sender: TObject);
var
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
  lTag: TRecorderTag;
begin
  if fSelectedChannelsGrid = nil then
    Exit;

  lSelection := fSelectedChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  for lRow := lBottom downto lTop do
  begin
    lTag := SelectedTagByGridRow(lRow);
    if (lTag <> nil) and (fTagRegistry <> nil) then
      fTagRegistry.RemoveTag(lTag);
  end;
  MarkSignalsFromRegistry;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.fAvailableChannelsGridDblClick(Sender: TObject);
var
  lSignal: TMeraSignalInfo;
begin
  if fAvailableChannelsGrid = nil then
    Exit;

  lSignal := AvailableSignalByGridRow(fAvailableChannelsGrid.Row);
  if lSignal = nil then
    Exit;

  lSignal.Selected := True;
  CreateSelectedMeraTags;
  MarkSignalsFromRegistry;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.btnChannelEditClick(Sender: TObject);
begin
  OpenSelectedChannelTagSettings;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridDblClick(Sender: TObject);
begin
  OpenSelectedChannelTagSettings;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lGrid: TStringGrid;
  lCol: LongInt;
  lRow: LongInt;
begin
  lGrid := TStringGrid(Sender);
  if (Button <> mbLeft) or (lGrid = nil) then
    Exit;

  lGrid.MouseToCell(X, Y, lCol, lRow);
  if lRow = 0 then
  begin
    if lGrid = fSelectedChannelsGrid then
      SortSelectedChannelsByColumn(lCol);
    Exit;
  end;

  if (lRow >= lGrid.Selection.Top) and (lRow <= lGrid.Selection.Bottom) then
  begin
    fCanDrag := True;
    fDragStartPt := Point(X, Y);
    fDragSelectActive := False;
    fSavedSelection := lGrid.Selection;
  end
  else
  begin
    fDragSelectActive := True;
    fDragSelectStart := Point(X, Y);
    fDragSelectEnd := Point(X, Y);
    fSelectingGrid := lGrid;
    fCanDrag := False;
    lGrid.Selection := TGridRect(Rect(0, lRow, lGrid.ColCount - 1, lRow));
  end;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lGrid: TStringGrid;
  lColStart, lRowStart, lColEnd, lRowEnd: LongInt;
  lTemp: LongInt;
begin
  lGrid := TStringGrid(Sender);
  if fCanDrag and (ssLeft in Shift) then
  begin
    if (Abs(X - fDragStartPt.X) > 5) or (Abs(Y - fDragStartPt.Y) > 5) then
    begin
      fCanDrag := False;
      lGrid.Selection := fSavedSelection;
      lGrid.BeginDrag(False);
    end;
    Exit;
  end;

  if fDragSelectActive and (fSelectingGrid = lGrid) and (ssLeft in Shift) then
  begin
    fDragSelectEnd := Point(X, Y);
    lGrid.Invalidate;

    lGrid.MouseToCell(fDragSelectStart.X, fDragSelectStart.Y, lColStart, lRowStart);
    lGrid.MouseToCell(fDragSelectEnd.X, fDragSelectEnd.Y, lColEnd, lRowEnd);

    if (lRowStart > 0) and (lRowEnd > 0) then
    begin
      if lRowStart > lRowEnd then
      begin
        lTemp := lRowStart;
        lRowStart := lRowEnd;
        lRowEnd := lTemp;
      end;
      if lRowStart < 1 then
        lRowStart := 1;

      lGrid.Selection := TGridRect(Rect(0, lRowStart, lGrid.ColCount - 1, lRowEnd));
    end;
  end;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lGrid: TStringGrid;
begin
  lGrid := TStringGrid(Sender);
  fCanDrag := False;
  if fDragSelectActive and (fSelectingGrid = lGrid) then
  begin
    fDragSelectActive := False;
    lGrid.Invalidate;
  end;
end;

procedure TRecorderSettingsDialog.GridPaint(Sender: TObject);
var
  lGrid: TStringGrid;
  lRect: TRect;
begin
  lGrid := TStringGrid(Sender);
  if fDragSelectActive and (fSelectingGrid = lGrid) then
  begin
    lRect.Left := Min(fDragSelectStart.X, fDragSelectEnd.X);
    lRect.Top := Min(fDragSelectStart.Y, fDragSelectEnd.Y);
    lRect.Right := Max(fDragSelectStart.X, fDragSelectEnd.X);
    lRect.Bottom := Max(fDragSelectStart.Y, fDragSelectEnd.Y);

    lGrid.Canvas.Brush.Style := bsClear;
    lGrid.Canvas.Pen.Color := clHighlight;
    lGrid.Canvas.Pen.Style := psDash;
    lGrid.Canvas.Pen.Width := 1;
    lGrid.Canvas.Rectangle(lRect);
  end;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeChange(Sender: TObject;
  Node: TTreeNode);
begin
  LoadSelectedAlgorithmSettings;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  lDropNode: TTreeNode;
begin
  if Source = fSelectedChannelsGrid then
  begin
    lDropNode := fAlgorithmsTree.GetNodeAt(X, Y);
    if lDropNode <> nil then
      fAlgorithmsTree.Selected := lDropNode;
    AddSpectrumAlgorithmsFromSelectedChannels;
  end;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source = fSelectedChannelsGrid;
end;

procedure TRecorderSettingsDialog.btnAlgorithmAddClick(Sender: TObject);
begin
  AddSpectrumAlgorithmsFromSelectedChannels;
end;

procedure TRecorderSettingsDialog.btnAlgorithmRemoveClick(Sender: TObject);
begin
  DeleteSelectedAlgorithms;
end;

procedure TRecorderSettingsDialog.btnAlgorithmConfigClick(Sender: TObject);
begin
  try
    StoreSelectedAlgorithmSettings;
  except
    on E: Exception do
      MessageDlg('Настройка спектра', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderSettingsDialog.btnFrequencyBandsClick(Sender: TObject);
begin
  ShowRecorderFrequencyBandsDialog(Self, fFrequencyBands);
end;

procedure TRecorderSettingsDialog.fAlgorithmAhCorrectionCheckChange(
  Sender: TObject);
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
  lProfile: string;
begin
  if (fAlgorithmAhCorrectionCheck = nil) or
    (not fAlgorithmAhCorrectionCheck.Checked) then
    Exit;

  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;

  lSettings := lNode.Settings;
  lProfile := lSettings.AhCorrectionProfileName;
  if lProfile = '' then
    lProfile := 'default';
  if InputQuery('Коррекция АЧХ', 'Профиль коэффициентов спектра', lProfile) then
  begin
    lSettings.AhCorrectionEnabled := True;
    lSettings.AhCorrectionProfileName := lProfile;
    lNode.Settings := lSettings;
  end
  else
    fAlgorithmAhCorrectionCheck.Checked := lSettings.AhCorrectionEnabled;
end;

procedure TRecorderSettingsDialog.fAlgorithmFftParamChange(Sender: TObject);
begin
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.fAlgorithmOverlapComboChange(Sender: TObject);
var
  lFftSize: Integer;
  lOverlap: Integer;
begin
  if (fAlgorithmOverlapCombo = nil) or (fAlgorithmFftSizeEdit = nil) or
    (fAlgorithmOverlapEdit = nil) then
    Exit;
  if fAlgorithmOverlapCombo.ItemIndex < 0 then
    Exit;
  if not TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lFftSize) then
    Exit;

  case TRecorderSpectrumOverlapMode(fAlgorithmOverlapCombo.ItemIndex) of
    somHalf:
      lOverlap := lFftSize div 2;
    somQuarter:
      lOverlap := lFftSize div 4;
  else
    lOverlap := 0;
  end;
  fAlgorithmOverlapEdit.Text := IntToStr(lOverlap);
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.fAvailableChannelsGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fSelectedChannelsGridMouseDown(Sender, Button, Shift, X, Y);
end;

{ Drag and Drop доступного канала в активную сетку }
procedure TRecorderSettingsDialog.fSelectedChannelsGridDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  lSignal: TMeraSignalInfo;
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
begin
  if Source <> fAvailableChannelsGrid then
    Exit;

  lSelection := fAvailableChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  for lRow := lBottom downto lTop do
  begin
    lSignal := AvailableSignalByGridRow(lRow);
    if lSignal <> nil then
      lSignal.Selected := True;
  end;
  CreateSelectedMeraTags;
  MarkSignalsFromRegistry;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source = fAvailableChannelsGrid;
end;

{ Двойной клик на устройстве/модуле в дереве для изменения его активности }
procedure TRecorderSettingsDialog.fHardwareTreeDblClick(Sender: TObject);
begin
  if (fHardwareTree = nil) or (fHardwareTree.Selected = nil) then
    Exit;

  ToggleHardwareSignal(fHardwareTree.Selected);
  if fPageControl <> nil then
    fPageControl.ActivePageIndex := 2;
end;

procedure TRecorderSettingsDialog.fHardwareTreeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_DELETE then
    Exit;

  DeleteCurrentMeraSource;
  Key := 0;
end;

initialization
  RegisterClasses([
    TPageControl, TTabSheet, TPanel, TGroupBox, TLabel, TEdit, TCheckBox,
    TRadioButton, TRadioGroup, TComboBox, TButton, TTreeView, TStringGrid,
    TSplitter
  ]);

end.
