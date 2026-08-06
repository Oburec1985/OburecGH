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
  uRecorderHardwareTree, uRecorderMeraSdbThermocouples, uRecorderMeraPaths,
  uRecorderTagBalance, uRecorder, uRecorderSettingsSourceProbe,
  uRecorderHardwareLiveDevices, uRecorderVirtualTagDialog,
  uRecorderNetworkBinding;

type
  { TRecorderSettingsDialog }

  { Класс диалогового окна настроек рекордера }
  TRecorderSettingsDialog = class(TForm)
  published
    fPageControl: TPageControl;                 // Контейнер вкладок настроек
    fApplyButton: TButton;                     // Кнопка "Применить"
    fHardwareTree: TTreeView;                   // Дерево аппаратной конфигурации/устройств
    cbNetworkInterface: TComboBox;
    edNetworkTestHost: TEdit;
    edNetworkTestPort: TEdit;
    btnNetworkTest: TButton;
    lblNetworkTestResult: TLabel;
    btnDeviceAdd: TBitBtn;                      // Кнопка добавления устройства (Mera-файла)
    btnChannelAdd: TBitBtn;                     // Кнопка добавления выбранного канала в список активных
    btnChannelRemove: TBitBtn;                  // Кнопка удаления канала из списка активных
    btnChannelEdit: TBitBtn;                    // Кнопка настройки выбранного тега
    pnChannelMoveButtons: TPanel;               // Панель кнопок перемещения каналов
    spChannels: TSplitter;                      // Разделитель между сетками доступных и выбранных каналов
    fAvailableChannelsGrid: TStringGrid;        // Таблица доступных для выбора каналов
    fSelectedChannelsGrid: TStringGrid;         // Таблица выбранных (активных) каналов
    edSelectedChannelsFilter: TEdit;
    btnSelectedChannelsClear: TButton;
    cbHideInactiveSelectedChannels: TCheckBox;
    cbOnlyVirtualSelectedChannels: TCheckBox;
    pnCreateVirtualTag: TPanel;
    btnCreateVirtualTag: TBitBtn;
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
    fAlgorithmBandRmsCheck: TCheckBox;
    fAlgorithmBandMaxCheck: TCheckBox;
    fAlgorithmBandMaxFrequencyCheck: TCheckBox;
    fAlgorithmWriteEstimatesCheck: TCheckBox;
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
    fMeraFilesPathEdit: TEdit;                  // Каталог Mera Files (SDB, калибровки)
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
    fStopManualRadio: TRadioButton;             // Останов вручную (по кнопке)
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
    procedure btnCreateVirtualTagClick(Sender: TObject);
    procedure fAvailableChannelsGridDblClick(Sender: TObject);
    procedure fAvailableChannelsGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure fSelectedChannelsGridDrawCell(Sender: TObject; aCol,
      aRow: Integer; aRect: TRect; aState: TGridDrawState);
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
    procedure fHardwareTreeMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure fHardwareTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure fHardwareTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fAlgorithmsTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fCfgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure fAlgorithmFftSizeUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure WorkDirBrowseClick(Sender: TObject);
    procedure MeraFilesPathBrowseClick(Sender: TObject);
    procedure NetworkTestClick(Sender: TObject);
  private
    fRecorder: TRecorder;
    fSourceProbe: TRecorderSettingsSourceProbe;
    fDeviceImageList: TCustomImageList;
    fTagDialogImageList: TCustomImageList;      // Список иконок диалога настройки тегов
    fSelectedChannelTags: TList;                // Row-map выбранных каналов на TRecorderTag
    fAvailableChannelSignals: TList;            // Row-map доступных каналов
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
    fDataSourcesChanged: Boolean;
    procedure fSelectedChannelsGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure fSelectedChannelsGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SelectedChannelsFilterChanged(Sender: TObject);
    procedure SelectedChannelsFilterClearClick(Sender: TObject);
    procedure GridPaint(Sender: TObject);
    
    // Вспомогательные методы работы с Mera-сигналами
    procedure ApplyMeraSignalToTag(ATag: TRecorderTag; ASignal: TMeraSignalInfo);
    function CloneMeraSignalForTag(ASignal: TMeraSignalInfo;
      const ATagName: string): TMeraSignalInfo;
    function SignalSourceId(ASignal: TMeraSignalInfo): string;
    function MeraSourceId(const AFileName: string): string;
    function SignalSourceGroup(ASignal: TMeraSignalInfo): string;
    function FindTagBySourceAddress(const ASourceId, AAddress: string): TRecorderTag;
    function SignalHasLinkedTag(ASignal: TMeraSignalInfo): Boolean;
    function TagIsVirtual(ATag: TRecorderTag): Boolean;
    function TagLinkedToInactiveHardware(ATag: TRecorderTag): Boolean;
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
    function SelectedSpectrumBinding: TRecorderSpectrumTagBinding;
    procedure CreateSelectedMeraTags;
    function FindMeraSignalByTagName(const ATagName: string): TMeraSignalInfo;
    function FindMic140SignalBySourceAddress(const ASourceId, AAddress: string): TMeraSignalInfo;
    function AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    function SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    procedure LoadMeraFile(const AFileName: string);
    procedure MarkSignalsFromRegistry;
    procedure DeleteCurrentMeraSource;
    procedure ReloadCurrentMeraSource;
    procedure HardwareAddSourceClick(Sender: TObject);
    procedure HardwareSearchClick(Sender: TObject);
    procedure AddMic140Source(const APresetHost: string = '');
    procedure EditMc032Source(const ASourceId: string = '');
    function SelectedHardwareSourceId: string;
    procedure EditHardwareSource(const ASourceId: string;
      const AModuleTypeHint: string = '');
    procedure EditMeraFileSource(const ASourceId: string);
    procedure ApplyConfiguredSourceChange(const AOldSourceId, ANewSourceId: string;
      ARefreshUi: Boolean = True);
    procedure DeleteMic185Source(const ASourceId: string);
    procedure TagHardwareSourceSetup(Sender: TObject; ATag: TRecorderTag);
    procedure TagZeroBalance(Sender: TObject; ARegistry: TRecorderTagRegistry;
      ATags: TList);

    procedure DeleteMic140Source(const ASourceId: string);
    procedure HardwareDeleteSourceClick(Sender: TObject);
    procedure HardwareReloadSourceClick(Sender: TObject);
    procedure HardwareResetSourceClick(Sender: TObject);
    procedure HardwareResetAllSourcesClick(Sender: TObject);
    procedure HardwareToggleSourceClick(Sender: TObject);
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
    procedure SetRecorder(AValue: TRecorder);
    procedure SetDeviceImageList(AValue: TCustomImageList);
    procedure SetTagDialogImageList(AValue: TCustomImageList);
    procedure SetDialogButtonImages;
    procedure InitializeHardwareTree;
    
    // Динамическое построение UI (используется при отсутствии lfm-файла формы)
    procedure BuildUi;
    procedure BuildRecorderTab(ATab: TTabSheet);
    procedure BuildHardwareTab(ATab: TTabSheet);
    procedure BuildPlaceholderTab(const ACaption: string);
    
    // Чтение и сохранение настроек
    procedure SyncMeraFilesPathFromUi;
    procedure LoadFromSettings;
    procedure StoreToSettings;
    procedure ApplySpectrumConfiguration;
    procedure RemoveOrphanSpectrumEstimateTags;
    procedure UpdateConditionControls;
    function ReadFloatEdit(AEdit: TEdit; ADefault: Double): Double;
    function ReadSecondsAsMs(AEdit: TEdit; ADefaultMs: Cardinal): Cardinal;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    // Свойства доступа к зависимостям
    property Recorder: TRecorder read fRecorder write SetRecorder;
    property DeviceImageList: TCustomImageList read fDeviceImageList write SetDeviceImageList;
    property TagDialogImageList: TCustomImageList read fTagDialogImageList
      write SetTagDialogImageList;
    property DataSourcesChanged: Boolean read fDataSourcesChanged;

    { Self-test / debug: same path as dblClick on MIC185 in hardware tree. }
    procedure DebugEditMic185Source(const ASourceId: string);
  end;

{ Отображает модальный диалог настроек }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARecorder: TRecorder;
  ADeviceImageList: TCustomImageList = nil;
  ATagDialogImageList: TCustomImageList = nil): Boolean;
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARecorder: TRecorder;
  ADeviceImageList: TCustomImageList;
  ATagDialogImageList: TCustomImageList;
  out ADataSourcesChanged: Boolean): Boolean;

{ Opens settings dialog internals and invokes MIC185 edit (no full settings modal). }
function RecorderSettingsDialogDebugEditMic185(AOwner: TComponent;
  ARecorder: TRecorder;
  ADeviceImageList, ATagDialogImageList: TCustomImageList;
  const ASourceId: string): Boolean;

implementation

uses
  StrUtils, ssockets,
  uRecorderConfiguredDataSources, uRecorderConfiguredSourceEditor,
  uRecorderMic140DataSource, uRecorderMic140DeviceConfig,
  uRecorderMic140StreamTypes,
  uRecorderMic140LegacyTiming, uRecorderMic140Utils,
  uRecorderMic185DataSource, uMic185Constants,
  uRecorderDeviceConfigSignature,
  uRecorderMc032SettingsDialog, uRecorderMc201SlotSettingsDialog,
  uRecorderDeviceSearchDialog, uMc032Device, uRecorderDebugLog;

{$R *.lfm}

const
  CMeraSourcePrefix = 'Mera file: ';

type
  TRecorderTcpProbeThread = class(TThread)
  private
    fHost: string;
    fPort: Word;
    fTimeoutMs: Cardinal;
    fOpen: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const AHost: string; APort: Word;
      ATimeoutMs: Cardinal);
    property Host: string read fHost;
    property IsOpen: Boolean read fOpen;
  end;

constructor TRecorderTcpProbeThread.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  Start;
end;

procedure TRecorderTcpProbeThread.Execute;
begin
  fOpen := RecorderMic140TcpProbe(fHost, fPort, fTimeoutMs);
end;

procedure RecorderFindOpenTcpHosts(ACandidates, AFound: TStrings;
  APort: Word; ATimeoutMs: Cardinal);
const
  CBatchSize = 48;
var
  lThreads: TList;
  lThread: TRecorderTcpProbeThread;
  lFirst, lLast, I: Integer;
begin
  if (ACandidates = nil) or (AFound = nil) then Exit;
  AFound.Clear;
  lThreads := TList.Create;
  try
    lFirst := 0;
    while lFirst < ACandidates.Count do
    begin
      lLast := lFirst + CBatchSize - 1;
      if lLast >= ACandidates.Count then lLast := ACandidates.Count - 1;
      for I := lFirst to lLast do
        lThreads.Add(TRecorderTcpProbeThread.Create(ACandidates[I], APort,
          ATimeoutMs));
      for I := 0 to lThreads.Count - 1 do
      begin
        lThread := TRecorderTcpProbeThread(lThreads[I]);
        lThread.WaitFor;
        if lThread.IsOpen and (AFound.IndexOf(lThread.Host) < 0) then
          AFound.Add(lThread.Host);
        lThread.Free;
      end;
      lThreads.Clear;
      lFirst := lLast + 1;
      Application.ProcessMessages;
    end;
  finally
    for I := 0 to lThreads.Count - 1 do
      TObject(lThreads[I]).Free;
    lThreads.Free;
  end;
end;

function IsChannelEnabled(AEnabledChannels: TStrings; const AAddress: string): Boolean;
var
  I: Integer;
  lChanNumSrc, lChanNumDest: Integer;
begin
  Result := False;
  if (AEnabledChannels = nil) or (AEnabledChannels.Count = 0) then
    Exit(True);

  if AEnabledChannels.IndexOf(AAddress) >= 0 then
    Exit(True);

  if ParseMic140ChannelNumber(AAddress, lChanNumDest) then
  begin
    for I := 0 to AEnabledChannels.Count - 1 do
    begin
      if ParseMic140ChannelNumber(AEnabledChannels[I], lChanNumSrc) and (lChanNumSrc = lChanNumDest) then
        Exit(True);
    end;
  end;
end;

{ Точка входа для запуска диалога настроек }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARecorder: TRecorder;
  ADeviceImageList: TCustomImageList;
  ATagDialogImageList: TCustomImageList): Boolean;
var
  lDataSourcesChanged: Boolean;
begin
  Result := ShowRecorderSettingsDialog(AOwner, ARecorder, ADeviceImageList,
    ATagDialogImageList, lDataSourcesChanged);
end;

function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARecorder: TRecorder;
  ADeviceImageList: TCustomImageList;
  ATagDialogImageList: TCustomImageList;
  out ADataSourcesChanged: Boolean): Boolean;
var
  lDialog: TRecorderSettingsDialog;
begin
  ADataSourcesChanged := False;
  lDialog := TRecorderSettingsDialog.Create(AOwner);
  try
    lDialog.DeviceImageList := ADeviceImageList;
    lDialog.TagDialogImageList := ATagDialogImageList;
    lDialog.Recorder := ARecorder;
    { Вход в конфигурацию проверяет существующие сессии, но не программирует приборы. }
    RecorderHardwareTestAllLiveSources;
    Result := lDialog.ShowModal = mrOk;
    { Выход из конфигурации повторно фиксирует доступность каналов. }
    RecorderHardwareTestAllLiveSources;
    ADataSourcesChanged := lDialog.DataSourcesChanged;
  finally
    lDialog.Free;
  end;
end;

function RecorderSettingsDialogDebugEditMic185(AOwner: TComponent;
  ARecorder: TRecorder;
  ADeviceImageList, ATagDialogImageList: TCustomImageList;
  const ASourceId: string): Boolean;
var
  lDialog: TRecorderSettingsDialog;
begin
  lDialog := TRecorderSettingsDialog.Create(AOwner);
  try
    lDialog.DeviceImageList := ADeviceImageList;
    lDialog.TagDialogImageList := ATagDialogImageList;
    lDialog.Recorder := ARecorder;
    lDialog.DebugEditMic185Source(ASourceId);
    Result := True;
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
  CDeviceControllerImageIndex = 42;
  CDeviceDisabledImageIndex = 41;
  CDeviceInactiveTagImageIndex = 54;
  CDeviceVirtualTagImageIndex = 20;
  CDeviceInactiveTagIconSize = 16;
  CDeviceModuleImageIndex = CIconDeviceModule;
  CDeviceTreeProbeTimeoutMs = 1000;
  CMeraSampleFile = 'D:\works\mera\mera files signals\shocks\signal0005\signal0005.mera';

constructor TRecorderSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fDataSourcesChanged := False;
  fSelectedChannelTags := TList.Create;
  fAvailableChannelSignals := TList.Create;
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
  if FindComponent('btnMeraFilesPathBrowse') is TButton then
    TButton(FindComponent('btnMeraFilesPathBrowse')).OnClick := @MeraFilesPathBrowseClick;
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
    fSelectedChannelsGrid.OnDrawCell := @fSelectedChannelsGridDrawCell;
    fSelectedChannelsGrid.OnMouseDown := @fSelectedChannelsGridMouseDown;
    fSelectedChannelsGrid.OnMouseMove := @fSelectedChannelsGridMouseMove;
    fSelectedChannelsGrid.OnMouseUp := @fSelectedChannelsGridMouseUp;
    fSelectedChannelsGrid.OnPaint := @GridPaint;
    fSelectedChannelsGrid.DragMode := dmManual;
  end;

  if edSelectedChannelsFilter <> nil then
    edSelectedChannelsFilter.OnChange := @SelectedChannelsFilterChanged;
  if btnSelectedChannelsClear <> nil then
    btnSelectedChannelsClear.OnClick := @SelectedChannelsFilterClearClick;
  if cbHideInactiveSelectedChannels <> nil then
    cbHideInactiveSelectedChannels.OnChange := @SelectedChannelsFilterChanged;
  if cbOnlyVirtualSelectedChannels <> nil then
    cbOnlyVirtualSelectedChannels.OnChange := @SelectedChannelsFilterChanged;

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
  if fAlgorithmBandRmsCheck <> nil then
    fAlgorithmBandRmsCheck.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmBandMaxCheck <> nil then
    fAlgorithmBandMaxCheck.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmBandMaxFrequencyCheck <> nil then
    fAlgorithmBandMaxFrequencyCheck.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmWriteEstimatesCheck <> nil then
    fAlgorithmWriteEstimatesCheck.OnChange := @fAlgorithmFftParamChange;
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
  if fHardwareTree <> nil then
    RecorderHardwareTreeClearNodes(fHardwareTree);
  fFrequencyBands.Free;
  fSpectrumConfigTree.Free;
  fSelectedChannelTags.Free;
  fAvailableChannelSignals.Free;
  FreeAndNil(fSourceProbe);
  inherited Destroy;
end;

procedure TRecorderSettingsDialog.SetRecorder(AValue: TRecorder);
begin
  FreeAndNil(fSourceProbe);
  fRecorder := AValue;
  if fRecorder <> nil then
  begin
    fSourceProbe := TRecorderSettingsSourceProbe.Create(fRecorder.TagRegistry);
    fSourceProbe.RestoreFromRegistry;
    fSpectrumConfigTree.Assign(fRecorder.TagRegistry.SpectrumConfigs);
    PopulateAlgorithmsTree;
    LoadFromSettings;
  end;
  PopulateHardwareTree;
  PopulateChannelGrids;
  if fSelectedChannelsGrid <> nil then
    fSelectedChannelsGrid.Invalidate;
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

procedure TRecorderSettingsDialog.SetTagDialogImageList(AValue: TCustomImageList);
begin
  fTagDialogImageList := AValue;
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
  AssignButtonImage(btnCreateVirtualTag, fDeviceImageList,
    CDeviceVirtualTagImageIndex);

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
  Result.SourceValueMode := ASignal.SourceValueMode;
  Result.FileName := ASignal.FileName;
  Result.XFileName := ASignal.XFileName;
  Result.HasXData := ASignal.HasXData;
  Result.Enabled := True;
  Result.Selected := True;
end;
function TRecorderSettingsDialog.MeraSourceId(const AFileName: string): string;
begin
  Result := RecorderMeraFileTagSourceId(AFileName);
end;

{ Copies MERA signal properties into a tag and binds it to the active source. }
procedure TRecorderSettingsDialog.ApplyMeraSignalToTag(ATag: TRecorderTag;
  ASignal: TMeraSignalInfo);
var
  lSourceId: string;
  lFirstMc201Bind: Boolean;
begin
  if (ATag = nil) or (ASignal = nil) then
    Exit;

  lSourceId := SignalSourceId(ASignal);
  { Первый bind MC-201: галочка аппаратной ГХ по умолчанию включена. }
  lFirstMc201Bind := SameText(ASignal.ModuleName, 'MC-201') and
    (not SameText(ATag.ModuleType, 'MC-201'));
  ATag.Address := ASignal.Address;
  ATag.UnitName := ASignal.UnitsName;
  ATag.SourceId := lSourceId;
  ATag.IsVirtual := RecorderIsVirtualTagSource(lSourceId);
  ATag.ModuleType := ASignal.ModuleName;
  ATag.PollFrequencyHz := ASignal.FrequencyHz;
  ATag.SourceValueMode := ASignal.SourceValueMode;
  if lFirstMc201Bind then
    ATag.HardwareCalibrationEnabled := True;
  if SameText(ASignal.ModuleName, 'MIC-140') then
    ATag.Description := Format('%s; freq=%s Hz',
      [ASignal.Description, FormatFloat('0.######', ASignal.FrequencyHz)])
  else
    ATag.Description := Format('%s; type=%s; freq=%s; file=%s',
      [ASignal.Name, ASignal.DataTypeName, FormatFloat('0.######', ASignal.FrequencyHz),
      ExtractFileName(ASignal.FileName)]);
  if not RecorderTagUsesMic140Settings(ATag) then
    RecorderTagClearMic140Settings(ATag);
end;

function TRecorderSettingsDialog.SignalSourceId(ASignal: TMeraSignalInfo): string;
begin
  if fSourceProbe = nil then
    Exit('');
  Result := fSourceProbe.SignalSourceId(ASignal);
end;

function TRecorderSettingsDialog.SignalSourceGroup(ASignal: TMeraSignalInfo): string;
begin
  Result := '';
  if ASignal = nil then
    Exit;
  if SameText(ASignal.ModuleName, 'MIC-140') then
    Result := 'MIC-140'
  else if SameText(ASignal.ModuleName, 'MIC183/185') then
    Result := 'MIC183/185'
  else if SameText(ASignal.ModuleName, 'MC-201') then
    Result := 'MC-032 / MC-201'
  else
    Result := 'Mera File';
end;
function TRecorderSettingsDialog.FindTagBySourceAddress(const ASourceId,
  AAddress: string): TRecorderTag;
begin
  if fSourceProbe = nil then
    Exit(nil);
  Result := fSourceProbe.FindTagBySourceAddress(ASourceId, AAddress);
end;

function TRecorderSettingsDialog.SignalHasLinkedTag(
  ASignal: TMeraSignalInfo): Boolean;
begin
  if fSourceProbe = nil then
    Exit(False);
  Result := fSourceProbe.SignalHasLinkedTag(ASignal);
end;

function TRecorderSettingsDialog.TagIsVirtual(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and ATag.IsVirtual;
end;

function TRecorderSettingsDialog.TagLinkedToInactiveHardware(
  ATag: TRecorderTag): Boolean;
var
  lSourceId: string;
begin
  Result := False;
  if (fRecorder.TagRegistry = nil) or (ATag = nil) then
    Exit;
  if RecorderIsDetachedTagSource(ATag.SourceId) then
    Exit(True);

  lSourceId := RecorderNormalizeTagSourceId(ATag.SourceId);
  if lSourceId = '' then
    Exit;
  if RecorderIsVirtualTagSource(lSourceId) then
    Exit(not RecorderTagSourceIsVisible(fRecorder.TagRegistry, ATag));
  if not RecorderIsHardwareTagSource(lSourceId) then
    Exit;

  Result := not fRecorder.TagRegistry.IsSourceActive(lSourceId);
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
      Result := 0;
    1:
      Result := CompareText(ATagA.Name, ATagB.Name);
    2:
      begin
        Result := CompareText(ATagA.Address, ATagB.Address);
        if Result = 0 then
          Result := CompareText(ATagA.Name, ATagB.Name);
      end;
    3:
      Result := CompareText(ATagA.ModuleType, ATagB.ModuleType);
    4:
      Result := CompareValue(ATagA.PollFrequencyHz, ATagB.PollFrequencyHz);
    5:
      Result := 0;
    6:
      Result := CompareText(ATagA.SourceId, ATagB.SourceId);
    7:
      Result := CompareText(ATagA.Description, ATagB.Description);
    8:
      Result := CompareValue(ATagA.Id, ATagB.Id);
  else
    Result := CompareText(ATagA.Name, ATagB.Name);
  end;

  if (Result = 0) and (fSelectedSortColumn <> 2) then
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
  if AColumn <= 0 then
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
  lBeforeProgramming: string;
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
    lBeforeProgramming := RecorderSourceProgrammingSignature(
      fRecorder.TagRegistry, lTag);
    lDialogOk := ShowTagSettingsDialog(Self, fRecorder.TagRegistry, lTags, fTagDialogImageList,
      ReadSecondsAsMs(fDataUpdateEdit, 200), @TagHardwareSourceSetup, @TagZeroBalance,
      fDeviceImageList);
    if lDialogOk then
    begin
      { Имя, единицы, ГХ и оценки не требуют пересоздания источника.
        Dirty выставляется только по изменению программируемой конфигурации. }
      if lBeforeProgramming <> RecorderSourceProgrammingSignature(
        fRecorder.TagRegistry, lTag) then
        fDataSourcesChanged := True;
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
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;
  lBinding := SelectedSpectrumBinding;
  if lBinding <> nil then
    lSettings := lBinding.ResolveSettings(lNode.Settings)
  else
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
  fAlgorithmBandRmsCheck.Checked := lSettings.CalculateBandRms;
  fAlgorithmBandMaxCheck.Checked := lSettings.CalculateBandMaximum;
  fAlgorithmBandMaxFrequencyCheck.Checked := lSettings.CalculateBandMaximumFrequency;
  fAlgorithmWriteEstimatesCheck.Checked := lSettings.WriteEstimatesToTags;
  if Cfg <> nil then
    Cfg.Text := lSettings.AsString;
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.StoreSelectedAlgorithmSettings;
var
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;

  lBinding := SelectedSpectrumBinding;
  if lBinding <> nil then
    lSettings := lBinding.ResolveSettings(lNode.Settings)
  else
    lSettings := lNode.Settings;
  if (Cfg <> nil) and (Cfg.Text <> '') then
  begin
    try
      lSettings.FromString(Cfg.Text);
      lSettings.Validate;
      if lBinding <> nil then
      begin
        lBinding.Settings := lSettings;
        lBinding.UseOwnSettings := True;
      end
      else
        lNode.Settings := lSettings;
      LoadSelectedAlgorithmSettings;
      Exit;
    except
      // Ignore parsing error and read from input controls
    end;
  end;

  lSettings := GetSettingsFromControls(lSettings);
  lSettings.Validate;
  if lBinding <> nil then
  begin
    lBinding.Settings := lSettings;
    lBinding.UseOwnSettings := True;
  end
  else
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
  lBindings: TList;
  lConfigNodes: TList;
  lSelectedNode: TTreeNode;
  lObj: TObject;
  lBinding: TRecorderSpectrumTagBinding;
  lParentNode: TRecorderSpectrumConfigNode;
  I, J: Integer;
begin
  if (fAlgorithmsTree = nil) or (fAlgorithmsTree.SelectionCount = 0) then
    Exit;

  { Snapshot model objects before changing the model. DeleteBinding/DeleteNode
    free those objects, therefore TTreeNode.Data must not be read afterwards. }
  lBindings := TList.Create;
  lConfigNodes := TList.Create;
  try
    for I := 0 to fAlgorithmsTree.SelectionCount - 1 do
    begin
      lSelectedNode := fAlgorithmsTree.Selections[I];
      if lSelectedNode.Data = nil then
        Continue;
      lObj := TObject(lSelectedNode.Data);
      if lObj is TRecorderSpectrumConfigNode then
        lConfigNodes.Add(lObj)
      else if lObj is TRecorderSpectrumTagBinding then
        lBindings.Add(lObj);
    end;

    fAlgorithmsTree.Items.BeginUpdate;
    try
      { Delete explicitly selected bindings only from algorithms which are not
        selected themselves. Deleting a parent already deletes all children. }
      for I := fSpectrumConfigTree.NodeCount - 1 downto 0 do
      begin
        lParentNode := fSpectrumConfigTree.Nodes[I];
        if lConfigNodes.IndexOf(lParentNode) >= 0 then
          Continue;
        for J := lParentNode.BindingCount - 1 downto 0 do
        begin
          lBinding := lParentNode.Bindings[J];
          if lBindings.IndexOf(lBinding) >= 0 then
            lParentNode.DeleteBinding(J);
        end;
      end;

      for I := fSpectrumConfigTree.NodeCount - 1 downto 0 do
        if lConfigNodes.IndexOf(fSpectrumConfigTree.Nodes[I]) >= 0 then
          fSpectrumConfigTree.DeleteNode(I);
    finally
      fAlgorithmsTree.Items.EndUpdate;
    end;
  finally
    lConfigNodes.Free;
    lBindings.Free;
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
  Result.CalculateBandRms := fAlgorithmBandRmsCheck.Checked;
  Result.CalculateBandMaximum := fAlgorithmBandMaxCheck.Checked;
  Result.CalculateBandMaximumFrequency := fAlgorithmBandMaxFrequencyCheck.Checked;
  Result.WriteEstimatesToTags := fAlgorithmWriteEstimatesCheck.Checked;
  Result.NormalizeMode := snmNone;
end;

procedure TRecorderSettingsDialog.UpdateConfigStr;
var
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;
  lBinding := SelectedSpectrumBinding;
  if lBinding <> nil then
    lSettings := GetSettingsFromControls(lBinding.ResolveSettings(lNode.Settings))
  else
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
begin
  if fSourceProbe <> nil then
    fSourceProbe.MarkSignalsFromRegistry;
end;


{ Создание или обновление каналов/тегов в реестре на основе выбранных сигналов Mera-файла }
procedure TRecorderSettingsDialog.CreateSelectedMeraTags;
var
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
  lSourceId: string;
  lTagName: string;
  I, J, lCount: Integer;

  function IsTagSelected(ATag: TRecorderTag): Boolean;
  var
    K: Integer;
    lSig: TMeraSignalInfo;
  begin
    Result := False;
    if ATag = nil then
      Exit;

    if (fRecorder <> nil) and SameText(ATag.SourceId, MeraSourceId(fSourceProbe.MeraFilePath)) then
    begin
      for K := 0 to fSourceProbe.GroupSignalCount(rsgMeraFile) - 1 do
      begin
        lSig := fSourceProbe.GroupSignal(rsgMeraFile, K);
        if (lSig <> nil) and SameText(lSig.Address, ATag.Address) then
        begin
          Result := lSig.Selected;
          Exit;
        end;
      end;
    end;

    if (fRecorder <> nil) and (Pos('MIC-140:', ATag.SourceId) = 1) then
    begin
      for K := 0 to fSourceProbe.GroupSignalCount(rsgMic140) - 1 do
      begin
        lSig := fSourceProbe.GroupSignal(rsgMic140, K);
        if (lSig <> nil) and SameText(lSig.FileName, ATag.SourceId) and SameMic140Address(lSig.Address, ATag.Address) then
        begin
          Result := lSig.Selected;
          Exit;
        end;
      end;
    end;

    if (fRecorder <> nil) and (Pos('MIC-185:', ATag.SourceId) = 1) then
    begin
      for K := 0 to fSourceProbe.GroupSignalCount(rsgMic185) - 1 do
      begin
        lSig := fSourceProbe.GroupSignal(rsgMic185, K);
        if (lSig <> nil) and SameText(lSig.FileName, ATag.SourceId) and
          SameText(lSig.Address, ATag.Address) then
        begin
          Result := lSig.Selected;
          Exit;
        end;
      end;
    end;

    if (fRecorder <> nil) and (Pos('MC-032:', ATag.SourceId) = 1) then
    begin
      for K := 0 to fSourceProbe.GroupSignalCount(rsgMcbus) - 1 do
      begin
        lSig := fSourceProbe.GroupSignal(rsgMcbus, K);
        if (lSig <> nil) and SameText(lSig.FileName, ATag.SourceId) and
          SameText(lSig.Address, ATag.Address) then
        begin
          Result := lSig.Selected;
          Exit;
        end;
      end;
    end;
  end;
  procedure CreateTagsFromGroup(AGroup: TRecorderSettingsSourceGroup);
  var
    J: Integer;
  begin
    if fRecorder = nil then
      Exit;
    for J := 0 to fSourceProbe.GroupSignalCount(AGroup) - 1 do
    begin
      lSignal := fSourceProbe.GroupSignal(AGroup, J);
      if (lSignal = nil) or (not lSignal.Selected) then
        Continue;

      lSourceId := SignalSourceId(lSignal);
      if lSourceId <> '' then
        fRecorder.TagRegistry.RegisterActiveSource(lSourceId);

      lTag := FindTagBySourceAddress(lSourceId, lSignal.Address);
      if lTag = nil then
      begin
        lTagName := MeraSignalToRecorderTagName(lSignal);
        lTag := fRecorder.TagRegistry.FindByName(lTagName);
        if (lTag <> nil) and (not SameText(lTag.SourceId, lSourceId)) then
          lTag := nil;
        if lTag = nil then
          lTag := fRecorder.TagRegistry.CreateTag(lTagName,
            Ceil(Max(4096, lSignal.FrequencyHz)), AGroup = rsgMeraFile);
      end;

      ApplyMeraSignalToTag(lTag, lSignal);
      lTag.EnsureBufferCapacity(Ceil(Max(4096, lSignal.FrequencyHz)));
    end;
  end;
begin
  if fRecorder.TagRegistry = nil then
    Exit;

  // Remove deselected tags
  for I := fRecorder.TagRegistry.TagCount - 1 downto 0 do
  begin
    lTag := fRecorder.TagRegistry.Tags[I];
    if SameText(lTag.SourceId, MeraSourceId(fSourceProbe.MeraFilePath)) or
      (Pos('MIC-140:', lTag.SourceId) = 1) or
      (Pos('MIC-185:', lTag.SourceId) = 1) or
      (Pos('MC-032:', lTag.SourceId) = 1) then
    begin
      if not IsTagSelected(lTag) then
        fRecorder.TagRegistry.RemoveTag(lTag);
    end;
  end;

  // Unregister active sources that have no tags left
  for I := fRecorder.TagRegistry.ActiveSourceCount - 1 downto 0 do
  begin
    lSourceId := fRecorder.TagRegistry.ActiveSourceIds[I];
    lCount := 0;
    for J := 0 to fRecorder.TagRegistry.TagCount - 1 do
      if SameText(fRecorder.TagRegistry.Tags[J].SourceId, lSourceId) then
        Inc(lCount);
    if lCount = 0 then
      fRecorder.TagRegistry.UnregisterActiveSource(lSourceId);
  end;

  if (fSourceProbe.MeraFilePath <> '') and (fRecorder <> nil) then
    fRecorder.TagRegistry.RegisterActiveSource(MeraSourceId(fSourceProbe.MeraFilePath));

  CreateTagsFromGroup(rsgMeraFile);
  CreateTagsFromGroup(rsgMic140);
  CreateTagsFromGroup(rsgMic185);
  CreateTagsFromGroup(rsgMcbus);
end;

function TRecorderSettingsDialog.FindMeraSignalByTagName(
  const ATagName: string): TMeraSignalInfo;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if fRecorder = nil then
    Exit;

  for I := 0 to fSourceProbe.GroupSignalCount(rsgMeraFile) - 1 do
  begin
    lSignal := fSourceProbe.GroupSignal(rsgMeraFile, I);
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
  if fRecorder = nil then
    Exit;
  for I := 0 to fSourceProbe.GroupSignalCount(rsgMic140) - 1 do
  begin
    lSignal := fSourceProbe.GroupSignal(rsgMic140, I);
    if SameText(lSignal.FileName, ASourceId) and SameText(lSignal.Address, AAddress) then
      Exit(lSignal);
  end;
end;

{ Возвращает Mera-сигнал по строке таблицы доступных каналов }
function TRecorderSettingsDialog.AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
begin
  Result := nil;
  if (fAvailableChannelSignals = nil) or (ARow < 1) or
    (ARow > fAvailableChannelSignals.Count) then
    Exit;
  Result := TMeraSignalInfo(fAvailableChannelSignals[ARow - 1]);
end;

{ Возвращает Mera-сигнал по строке таблицы доступных каналов }
function TRecorderSettingsDialog.SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
var
  I: Integer;
  lRow: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if (fRecorder = nil) or (ARow < 1) then
    Exit;

  lRow := 0;
  for I := 0 to fSourceProbe.GroupSignalCount(rsgMeraFile) - 1 do
  begin
    lSignal := fSourceProbe.GroupSignal(rsgMeraFile, I);
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
  if fRecorder = nil then
    Exit;
  fSourceProbe.LoadMeraFile(AFileName);
  fDataSourcesChanged := True;
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
  if fSourceProbe.MeraFilePath = '' then
    Exit;

  if MessageDlg('Удаление источника данных',
    'Удалить источник данных "' + ExtractFileName(fSourceProbe.MeraFilePath) + '"?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  lSourceId := MeraSourceId(fSourceProbe.MeraFilePath);
  if fRecorder.TagRegistry <> nil then
  begin
    RecorderConfiguredDataSourcesRemove(fRecorder.TagRegistry, lSourceId);
    for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
    begin
      lTag := fRecorder.TagRegistry.Tags[I];
      if SameText(lTag.SourceId, lSourceId) then
        lTag.SourceId := 'Detached: ' + lSourceId;
    end;
  end;

  fSourceProbe.MeraFilePath := '';
  fSourceProbe.MeraFolder := '';
  fSourceProbe.ClearGroup(rsgMeraFile);
  fDataSourcesChanged := True;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.ReloadCurrentMeraSource;
begin
  if fRecorder = nil then
    Exit;
  if fSourceProbe.MeraFilePath = '' then
    Exit;
  if not FileExists(fSourceProbe.MeraFilePath) then
  begin
    MessageDlg('Перечитывание источника',
      'Файл источника данных не найден: ' + fSourceProbe.MeraFilePath,
      mtWarning, [mbOK], 0);
    Exit;
  end;

  fSourceProbe.ReloadMeraFile;
  fDataSourcesChanged := True;
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
    lCombo.Items.Add('MIC183/185');
    lCombo.Items.Add('MC-032');
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
    else if SameText(lCombo.Text, 'MIC183/185') then
      EditHardwareSource('', 'MIC183/185')
    else if SameText(lCombo.Text, 'MC-032') then
      EditMc032Source
    else
      btnDeviceAddClick(Sender);
  finally
    lForm.Free;
  end;
end;

procedure TRecorderSettingsDialog.NetworkTestClick(Sender: TObject);
var
  lElapsedMs: QWord;
  lErrorText: string;
  lPortValue: Integer;
  lStartedAt: QWord;
  lStream: TSocketStream;
begin
  if (cbNetworkInterface <> nil) and (cbNetworkInterface.ItemIndex >= 0) then
    SetRecorderNetworkBindAddress(RecorderNetworkAddressFromDisplay(
      cbNetworkInterface.Text));
  if not TryStrToInt(Trim(edNetworkTestPort.Text), lPortValue) or
     (lPortValue < 1) or (lPortValue > 65535) then
  begin
    lblNetworkTestResult.Caption := 'Некорректный порт';
    lblNetworkTestResult.Font.Color := clRed;
    Exit;
  end;
  Screen.Cursor := crHourGlass;
  lStartedAt := GetTickCount64;
  lStream := nil;
  try
    if RecorderOpenBoundTcpStream(Trim(edNetworkTestHost.Text),
      Word(lPortValue), 1500, lStream, lErrorText) then
    begin
      lElapsedMs := GetTickCount64 - lStartedAt;
      lblNetworkTestResult.Caption := Format('Связь есть, %d мс', [lElapsedMs]);
      lblNetworkTestResult.Font.Color := clGreen;
    end
    else
    begin
      lblNetworkTestResult.Caption := 'Нет связи: ' + lErrorText;
      lblNetworkTestResult.Font.Color := clRed;
    end;
  finally
    lStream.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TRecorderSettingsDialog.HardwareSearchClick(Sender: TObject);
var
  lFoundHosts: TStringList;
  lBroadcastHosts: TStringList;
  lBroadcastIps: TStringList;
  lCandidateHosts: TStringList;
  lOpenHosts: TStringList;
  lConfiguredIds: TStringList;
  lSeenIds: TStringList;
  lDialog: TRecorderDeviceSearchDialog;
  lDevice: TRecorderDiscoveredDevice;
  lMc032: TMc032Device;
  lSourceId: string;
  lHost: string;
  lVersion: string;
  lError: string;
  lDisplay: string;
  lBroadcastValue: string;
  lBroadcastKind: string;
  lBroadcastSerial: string;
  lSerial: LongWord;
  lPort: Word;
  I, lIndex: Integer;
  lSearchStartedAt, lStageStartedAt: QWord;

  function IsConfigured(const ASourceId: string): Boolean;
  begin
    Result := (fRecorder <> nil) and
      (RecorderConfiguredDataSourcesFind(fRecorder.TagRegistry, ASourceId) <> nil);
  end;

  procedure AddFound(const ADeviceType, ASourceId, ADisplayText: string);
  var
    lConfigured: Boolean;
  begin
    if (Trim(ASourceId) = '') or (lSeenIds.IndexOf(ASourceId) >= 0) then
      Exit;
    lSeenIds.Add(ASourceId);
    lConfigured := IsConfigured(ASourceId);
    lDisplay := ADisplayText;
    if lConfigured then
      lDisplay := lDisplay + '  (уже добавлено)';
    lDialog.AddDevice(ADeviceType, ASourceId, lDisplay, lConfigured);
  end;

  function ProbeMic140(const AHost: string; APort: Word): Boolean;
  var
    lMic140Serial, lDevSubRev: Integer;
    lMic140Version, lMic140Display: string;
  begin
    Result := RecorderMic140QueryDeviceInfo(AHost, APort, lMic140Serial,
      lMic140Version, lDevSubRev);
    if not Result then Exit;
    lMic140Display := Format('MIC-140 - %s:%d', [AHost, APort]);
    if lMic140Serial <> 0 then
      lMic140Display := lMic140Display + Format(', SN=%d', [lMic140Serial]);
    if lMic140Version <> '' then
      lMic140Display := lMic140Display + ', ' + lMic140Version;
    AddFound('MIC-140', RecorderMic140SourceId(AHost, APort),
      lMic140Display);
  end;

  function ProbeMic185(const AHost: string; APort: Word): Boolean;
  begin
    Result := RecorderMic185ReadDeviceInfo(AHost, APort, lSerial, lVersion,
      lError, 1000);
    if not Result then Exit;
    lSourceId := RecorderMic185SourceId(AHost, APort);
    lDisplay := Format('MIC183/185 — %s:%d', [AHost, APort]);
    if lSerial <> 0 then
      lDisplay := lDisplay + Format(', SN=%d', [lSerial]);
    if lVersion <> '' then
      lDisplay := lDisplay + ', ' + lVersion;
    AddFound('MIC183/185', lSourceId, lDisplay);
  end;

  function ProbeMc032(const AHost: string; APort: Word;
    ATimeoutMs: Cardinal): Boolean;
  begin
    lMc032.Host := AHost;
    lMc032.Port := APort;
    lMc032.TimeoutMs := ATimeoutMs;
    Result := lMc032.TestConnection(lError);
    if Result then
      AddFound('MC-032', RecorderMc032SourceId(AHost, APort),
        Format('MC-032 — %s:%d', [AHost, APort]));
  end;
begin
  lSearchStartedAt := GetTickCount64;
  { Автопоиск должен использовать текущее значение списка, даже если
    пользователь ещё не нажал «Применить». }
  if (cbNetworkInterface <> nil) and (cbNetworkInterface.ItemIndex >= 0) then
    SetRecorderNetworkBindAddress(RecorderNetworkAddressFromDisplay(
      cbNetworkInterface.Text));
  lFoundHosts := TStringList.Create;
  lBroadcastHosts := TStringList.Create;
  lBroadcastIps := TStringList.Create;
  lCandidateHosts := TStringList.Create;
  lOpenHosts := TStringList.Create;
  lConfiguredIds := TStringList.Create;
  lSeenIds := TStringList.Create;
  lDialog := TRecorderDeviceSearchDialog.Create(Self);
  lMc032 := TMc032Device.Create;
  try
    lSeenIds.CaseSensitive := False;
    lSeenIds.Sorted := True;
    lSeenIds.Duplicates := dupIgnore;
    lCandidateHosts.CaseSensitive := False;
    lCandidateHosts.Sorted := True;
    lCandidateHosts.Duplicates := dupIgnore;
    if (fRecorder <> nil) and (fRecorder.TagRegistry <> nil) then
      RecorderEnumerateConfiguredSourceIds(fRecorder.TagRegistry,
        lConfiguredIds, True);

    Screen.Cursor := crHourGlass;
    try
      { Штатные broadcast-ответы уже содержат тип прибора. Такие устройства
        добавляем сразу и повторный TestLink для них не выполняем. }
      { Оригинальный MebiusDAQ EthernetBus ждёт ответы 5000 мс. MIC185 на
        стенде не успевает ответить за прежние 1400 мс. }
      lStageStartedAt := GetTickCount64;
      RecorderDiscoverMeraBroadcast(lBroadcastHosts, 5200);
      RecorderDebugLog(Format('[HardwareSearch] broadcast: %d device(s), %d ms',
        [lBroadcastHosts.Count, GetTickCount64 - lStageStartedAt]));
      for I := 0 to lBroadcastHosts.Count - 1 do
      begin
        lHost := lBroadcastHosts.Names[I];
        lBroadcastValue := lBroadcastHosts.ValueFromIndex[I];
        lBroadcastKind := Copy2SymbDel(lBroadcastValue, '|');
        lBroadcastSerial := lBroadcastValue;
        lBroadcastIps.Add(lHost);
        lDisplay := Format('%s - %s:%d', [lBroadcastKind, lHost, 4000]);
        if lBroadcastSerial <> '' then
          lDisplay := lDisplay + ', SN=' + lBroadcastSerial;
        if SameText(lBroadcastKind, 'MIC-140') then
          AddFound('MIC-140', RecorderMic140SourceId(lHost, 4000), lDisplay)
        else if SameText(lBroadcastKind, 'MIC183/185') then
          AddFound('MIC183/185', RecorderMic185SourceId(lHost, 4000), lDisplay);
      end;

      for I := 0 to lConfiguredIds.Count - 1 do
        if TryParseRecorderMic185SourceId(lConfiguredIds[I], lHost, lPort) then
          lCandidateHosts.Add(lHost);
      for I := 0 to lConfiguredIds.Count - 1 do
        if TryParseRecorderMic140SourceId(lConfiguredIds[I], lHost, lPort) then
          lCandidateHosts.Add(lHost);
      for I := 0 to lConfiguredIds.Count - 1 do
        if TryParseRecorderMc032SourceId(lConfiguredIds[I], lHost, lPort) then
          lCandidateHosts.Add(lHost);

      { Резервный поиск использует настоящую маску выбранного адаптера.
        TCP-порт проверяется пакетами потоков; тяжелый протокольный TestLink
        выполняется только для узлов, у которых порт 4000 действительно открыт. }
      RecorderEnumerateDiscoveryIPv4(lFoundHosts, 65534);
      lCandidateHosts.AddStrings(lFoundHosts);
      for I := 0 to lBroadcastIps.Count - 1 do
      begin
        lIndex := lCandidateHosts.IndexOf(lBroadcastIps[I]);
        if lIndex >= 0 then lCandidateHosts.Delete(lIndex);
      end;
      lStageStartedAt := GetTickCount64;
      RecorderFindOpenTcpHosts(lCandidateHosts, lOpenHosts,
        MIC140DefaultPort, 90);
      RecorderDebugLog(Format('[HardwareSearch] TCP scan: %d candidate(s), '+
        '%d open, %d ms', [lCandidateHosts.Count, lOpenHosts.Count,
        GetTickCount64 - lStageStartedAt]));

      lStageStartedAt := GetTickCount64;
      for I := 0 to lOpenHosts.Count - 1 do
      begin
        lHost := lOpenHosts[I];
        if ProbeMic185(lHost, MIC185DefaultPort) then Continue;
        if ProbeMic140(lHost, MIC140DefaultPort) then Continue;
        ProbeMc032(lHost, 4000, 700);
        Application.ProcessMessages;
      end;
      RecorderDebugLog(Format('[HardwareSearch] fallback identification: '+
        '%d host(s), %d ms', [lOpenHosts.Count,
        GetTickCount64 - lStageStartedAt]));
    finally
      Screen.Cursor := crDefault;
    end;

    if lDialog.DeviceCount = 0 then
    begin
      MessageDlg('Автопоиск', 'Поддерживаемые устройства не найдены.',
        mtWarning, [mbOK], 0);
      Exit;
    end;

    if lDialog.ShowModal <> mrOk then
      Exit;
    lStageStartedAt := GetTickCount64;
    for I := 0 to lDialog.DeviceCount - 1 do
    begin
      if not lDialog.DeviceChecked(I) then
        Continue;
      lDevice := lDialog.DeviceAt(I);
      { Подтверждение общего списка означает добавление выбранных источников.
        Настроечные диалоги здесь не открываем: их пользователь вызывает позже
        кнопкой свойств или двойным щелчком по конкретному устройству. }
      if SameText(lDevice.DeviceType, 'MIC-140') then
        RecorderConfiguredDataSourcesEnsure(fRecorder.TagRegistry,
          lDevice.SourceId, 'MIC-140', MIC140DefaultPollFrequencyHz)
      else if SameText(lDevice.DeviceType, 'MIC183/185') then
        RecorderConfiguredDataSourcesEnsure(fRecorder.TagRegistry,
          lDevice.SourceId, 'MIC183/185', MIC185DefaultPollFrequencyHz)
      else if SameText(lDevice.DeviceType, 'MC-032') then
        RecorderConfiguredDataSourcesEnsure(fRecorder.TagRegistry,
          lDevice.SourceId, 'MC-032', 0)
      else
        Continue;
      { Broadcast/protocol discovery already proved that this endpoint is alive.
        Do not immediately repeat TestLink while merely adding its config. }
      RecorderHardwareClearSourceOffline(lDevice.SourceId);
      ApplyConfiguredSourceChange('', lDevice.SourceId, False);
    end;
    PopulateHardwareTree;
    PopulateChannelGrids;
    if fSelectedChannelsGrid <> nil then
      fSelectedChannelsGrid.Invalidate;
    RecorderDebugLog(Format('[HardwareSearch] batch add/UI refresh: %d ms; '+
      'total search dialog cycle: %d ms', [GetTickCount64 - lStageStartedAt,
      GetTickCount64 - lSearchStartedAt]));
  finally
    lMc032.Free;
    lDialog.Free;
    lSeenIds.Free;
    lConfiguredIds.Free;
    lOpenHosts.Free;
    lCandidateHosts.Free;
    lBroadcastIps.Free;
    lBroadcastHosts.Free;
    lFoundHosts.Free;
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
  EditHardwareSource(lSourceId, 'MIC-140');
end;

function TRecorderSettingsDialog.SelectedHardwareSourceId: string;
var
  lNode: TTreeNode;
begin
  Result := '';
  if fHardwareTree = nil then
    Exit;
  lNode := fHardwareTree.Selected;
  while lNode <> nil do
  begin
    Result := RecorderHardwareTreeSourceId(lNode);
    if Result <> '' then
      Exit;
    lNode := lNode.Parent;
  end;
end;

procedure TRecorderSettingsDialog.EditHardwareSource(const ASourceId: string;
  const AModuleTypeHint: string);
var
  lNewSourceId: string;
begin
  if fRecorder = nil then
    Exit;
  if SameText(AModuleTypeHint, 'MC-032') or
    (Pos('MC-032: ', ASourceId) = 1) then
  begin
    EditMc032Source(ASourceId);
    Exit;
  end;
  if RecorderIsVirtualTagSource(ASourceId) then
  begin
    EditMeraFileSource(ASourceId);
    Exit;
  end;
  SyncMeraFilesPathFromUi;
  if not RecorderEditConfiguredDataSource(Self, fRecorder.TagRegistry, ASourceId,
    lNewSourceId, AModuleTypeHint) then
    Exit;
  ApplyConfiguredSourceChange(ASourceId, lNewSourceId);
end;

function TRecorderSettingsDialog.SelectedSpectrumBinding:
  TRecorderSpectrumTagBinding;
begin
  Result := nil;
  if (fAlgorithmsTree <> nil) and (fAlgorithmsTree.Selected <> nil) and
    (TObject(fAlgorithmsTree.Selected.Data) is TRecorderSpectrumTagBinding) then
    Result := TRecorderSpectrumTagBinding(fAlgorithmsTree.Selected.Data);
end;

procedure TRecorderSettingsDialog.EditMc032Source(const ASourceId: string);
var
  lConfig: TRecorderConfiguredDataSource;
  lInitialConfigText: string;
  lModulesText: string;
  lNewSourceId: string;
begin
  if (fRecorder = nil) or (fRecorder.TagRegistry = nil) then
    Exit;
  lInitialConfigText := '';
  lConfig := RecorderConfiguredDataSourcesFind(fRecorder.TagRegistry, ASourceId);
  if lConfig <> nil then
    lInitialConfigText := lConfig.SpecificConfigText;
  if not ShowRecorderMc032SettingsDialog(Self, ASourceId, lInitialConfigText, lNewSourceId,
    lModulesText) then
    Exit;
  if (ASourceId <> '') and not SameText(ASourceId, lNewSourceId) then
    RecorderConfiguredDataSourcesRemove(fRecorder.TagRegistry, ASourceId);
  lConfig := RecorderConfiguredDataSourcesEnsure(fRecorder.TagRegistry,
    lNewSourceId, 'MC-032', 0);
  if lConfig <> nil then
    lConfig.SpecificConfigText := lModulesText;
  fRecorder.TagRegistry.RegisterActiveSource(lNewSourceId);
  ApplyConfiguredSourceChange(ASourceId, lNewSourceId);
end;

procedure TRecorderSettingsDialog.EditMeraFileSource(const ASourceId: string);
var
  lDialog: TOpenDialog;
  lOldSourceId, lNewSourceId: string;
  I: Integer;
  lPath: string;
  lTag: TRecorderTag;
begin
  lPath := RecorderMeraFileTagSourcePath(ASourceId);
  if lPath <> '' then
    fSourceProbe.MeraFilePath := lPath
  else if fSourceProbe.MeraFilePath = '' then
    Exit;

  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Выберите файл Mera';
    lDialog.Filter := 'Mera file (*.mera)|*.mera|All files (*.*)|*.*';
    lDialog.InitialDir := ExtractFilePath(fSourceProbe.MeraFilePath);
    lDialog.FileName := ExtractFileName(fSourceProbe.MeraFilePath);
    if not lDialog.Execute then
      Exit;

    lOldSourceId := MeraSourceId(fSourceProbe.MeraFilePath);
    fSourceProbe.MeraFilePath := lDialog.FileName;
    fSourceProbe.MeraFolder := ExtractFilePath(lDialog.FileName);
    lNewSourceId := MeraSourceId(fSourceProbe.MeraFilePath);

    if fRecorder.TagRegistry <> nil then
    begin
      RecorderConfiguredDataSourcesRemove(fRecorder.TagRegistry, lOldSourceId);
      RecorderConfiguredDataSourcesEnsure(fRecorder.TagRegistry, lNewSourceId,
        'MC-201', 0);
      fRecorder.TagRegistry.RegisterActiveSource(lNewSourceId);
      for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := fRecorder.TagRegistry.Tags[I];
        if SameText(lTag.SourceId, lOldSourceId) then
          lTag.SourceId := lNewSourceId;
      end;
    end;

    if FileExists(fSourceProbe.MeraFilePath) then
      fSourceProbe.LoadMeraFile(fSourceProbe.MeraFilePath)
    else
      fSourceProbe.ClearGroup(rsgMeraFile);
    fDataSourcesChanged := True;

    PopulateHardwareTree;
    PopulateChannelGrids;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderSettingsDialog.ApplyConfiguredSourceChange(
  const AOldSourceId, ANewSourceId: string; ARefreshUi: Boolean);
var
  I: Integer;
  lConfig: TRecorderMic140SourceConfig;
  lHost: string;
  lPort: Word;
  lSourceConfig: TRecorderConfiguredDataSource;
  lTag: TRecorderTag;
begin
  if fRecorder.TagRegistry = nil then
    Exit;
  fDataSourcesChanged := True;

  if TryParseRecorderMic140SourceId(ANewSourceId, lHost, lPort) then
  begin
    if (AOldSourceId <> '') and (not SameText(AOldSourceId, ANewSourceId)) then
      RecorderMic140RekeySourceId(fRecorder.TagRegistry, AOldSourceId, ANewSourceId);
    lConfig := FindRecorderMic140DeviceConfig(fRecorder.TagRegistry, ANewSourceId);
    if lConfig <> nil then
      fSourceProbe.BuildMic140(ANewSourceId, lConfig.ChannelCount,
        lConfig.SelectedChannels, lConfig.ChannelSettings, lConfig.DeviceSerial);
    RecorderConfiguredDataSourcesEnsure(fRecorder.TagRegistry, ANewSourceId,
      'MIC-140', 0);
  end
  else if TryParseRecorderMic185SourceId(ANewSourceId, lHost, lPort) then
  begin
    if (AOldSourceId <> '') and (not SameText(AOldSourceId, ANewSourceId)) then
    begin
      fRecorder.TagRegistry.UnregisterActiveSource(AOldSourceId);
      for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := fRecorder.TagRegistry.Tags[I];
        if SameText(lTag.SourceId, AOldSourceId) then
          lTag.SourceId := ANewSourceId;
      end;
    end;
    fRecorder.TagRegistry.RegisterActiveSource(ANewSourceId);
    fSourceProbe.BuildMic185(ANewSourceId);
    RecorderConfiguredDataSourcesEnsure(fRecorder.TagRegistry, ANewSourceId,
      'MIC183/185', 0);
  end
  else if TryParseRecorderMc032SourceId(ANewSourceId, lHost, lPort) then
  begin
    { MC-032 хранится в общем RecorderConfiguredDataSources, а не в частном
      списке конкретного прибора. Это сохраняет контроллер, найденные слоты
      MC-201 и их настройки после Применить/OK и повторного открытия диалога. }
    if (AOldSourceId <> '') and not SameText(AOldSourceId, ANewSourceId) then
    begin
      fRecorder.TagRegistry.UnregisterActiveSource(AOldSourceId);
      for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := fRecorder.TagRegistry.Tags[I];
        if SameText(lTag.SourceId, AOldSourceId) then
          lTag.SourceId := ANewSourceId;
      end;
    end;
    fRecorder.TagRegistry.RegisterActiveSource(ANewSourceId);
    lSourceConfig := RecorderConfiguredDataSourcesFind(fRecorder.TagRegistry,
      ANewSourceId);
    if lSourceConfig <> nil then
      fSourceProbe.BuildMcbus(ANewSourceId,
        lSourceConfig.SpecificConfigText,
        lSourceConfig.DefaultPollFrequencyHz);
  end;

  if ARefreshUi then
  begin
    PopulateHardwareTree;
    PopulateChannelGrids;
    if fSelectedChannelsGrid <> nil then
      fSelectedChannelsGrid.Invalidate;
  end;
end;

procedure TRecorderSettingsDialog.TagHardwareSourceSetup(Sender: TObject;
  ATag: TRecorderTag);
var
  I, lSlot: Integer;
  lCaption: string;
  lConfig: TRecorderConfiguredDataSource;
  lConfigText: string;
  lLines: TStringList;
  lPath: string;
begin
  if ATag = nil then
    Exit;
  if Pos('MC-032: ', ATag.SourceId) = 1 then
  begin
    lConfig := RecorderConfiguredDataSourcesFind(fRecorder.TagRegistry,
      ATag.SourceId);
    if lConfig = nil then
      Exit;
    lLines := TStringList.Create;
    try
      lLines.StrictDelimiter := True;
      lLines.Delimiter := '-';
      lLines.DelimitedText := ATag.Address;
      if (lLines.Count < 2) or
        not TryStrToInt(lLines[lLines.Count - 2], lSlot) then
        Exit;
      lLines.Text := lConfig.SpecificConfigText;
      lCaption := '';
      for I := 0 to lLines.Count - 1 do
        if Pos('Слот ' + IntToStr(lSlot) + ':', Trim(lLines[I])) = 1 then
        begin
          lCaption := Trim(lLines[I]);
          Break;
        end;
      if lCaption <> '' then
      begin
        lConfigText := lConfig.SpecificConfigText;
        if ShowRecorderMc201SlotSettingsDialog(Self,
          lCaption, lConfigText, ATag.SourceId,
          fRecorder.DataSources, fRecorder.TagRegistry) then
        begin
          lConfig.SpecificConfigText := lConfigText;
          fDataSourcesChanged := True;
          PopulateHardwareTree;
          PopulateChannelGrids;
        end;
      end;
    finally
      lLines.Free;
    end;
    Exit;
  end;
  if Pos(CMeraSourcePrefix, ATag.SourceId) = 1 then
  begin
    lPath := Trim(Copy(ATag.SourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
    if lPath <> '' then
      fSourceProbe.MeraFilePath := lPath;
  end;
  EditHardwareSource(RecorderNormalizeTagSourceId(ATag.SourceId));
end;

procedure TRecorderSettingsDialog.TagZeroBalance(Sender: TObject;
  ARegistry: TRecorderTagRegistry; ATags: TList);
begin
  RecorderTryZeroBalanceTags(Self, ARegistry, ATags, fRecorder.DataSources);
end;

procedure TRecorderSettingsDialog.DebugEditMic185Source(const ASourceId: string);
begin
  EditHardwareSource(ASourceId);
end;

procedure TRecorderSettingsDialog.DeleteMic185Source(const ASourceId: string);
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
begin
  if (ASourceId = '') or (fRecorder.TagRegistry = nil) then
    Exit;
  if MessageDlg('MIC183/185', 'Remove source "' + ASourceId + '"?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  RecorderConfiguredDataSourcesRemove(fRecorder.TagRegistry, ASourceId);
  fDataSourcesChanged := True;
  fRecorder.TagRegistry.UnregisterActiveSource(ASourceId);
  for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
  begin
    lTag := fRecorder.TagRegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) then
      lTag.SourceId := 'Detached: ' + ASourceId;
  end;
  fSourceProbe.RemoveSourceSignals(ASourceId);
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.DeleteMic140Source(const ASourceId: string);
var
  I: Integer;
  lIdx: Integer;
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
begin
  if (ASourceId = '') or (fRecorder.TagRegistry = nil) then
    Exit;
  if MessageDlg('MIC-140', 'Remove source "' + ASourceId + '"?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  RecorderConfiguredDataSourcesRemove(fRecorder.TagRegistry, ASourceId);
  fDataSourcesChanged := True;
  lIdx := fRecorder.TagRegistry.SourceSpecificConfigs.IndexOf(ASourceId);
  if lIdx >= 0 then
    fRecorder.TagRegistry.SourceSpecificConfigs.Delete(lIdx);
  fRecorder.TagRegistry.UnregisterActiveSource(ASourceId);
  for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
  begin
    lTag := fRecorder.TagRegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) then
      lTag.SourceId := 'Detached: ' + ASourceId;
  end;
  fSourceProbe.RemoveSourceSignals(ASourceId);
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.HardwareDeleteSourceClick(Sender: TObject);
var
  lHost: string;
  lPort: Word;
  lSourceId: string;
begin
  lSourceId := SelectedHardwareSourceId;
  if lSourceId = '' then
    Exit;
  if TryParseRecorderMic140SourceId(lSourceId, lHost, lPort) then
    DeleteMic140Source(lSourceId)
  else if TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
    DeleteMic185Source(lSourceId)
  else if TryParseRecorderMc032SourceId(lSourceId, lHost, lPort) then
    DeleteMic185Source(lSourceId)
  else if RecorderIsVirtualTagSource(lSourceId) then
    DeleteCurrentMeraSource;
end;

procedure TRecorderSettingsDialog.HardwareReloadSourceClick(Sender: TObject);
begin
  ReloadCurrentMeraSource;
end;

procedure TRecorderSettingsDialog.HardwareResetSourceClick(Sender: TObject);
var
  lErrorText: string;
  lSourceId: string;
begin
  lSourceId := SelectedHardwareSourceId;
  if lSourceId = '' then
    Exit;
  lErrorText := '';
  { Явный сброс инвалидирует текущую аппаратную конфигурацию. При следующем
    запуске источник заново выполнит Init/Configure; обычный Stop этого не делает. }
  RecorderHardwareRequestSourceReset(lSourceId);
  RecorderHardwareClearSourceOffline(lSourceId);
  if RecorderHardwareSourceLinkOk(fRecorder.TagRegistry, lSourceId) then
    RecorderHardwareClearSourceOffline(lSourceId)
  else
  begin
    if Trim(lErrorText) = '' then
      lErrorText := 'TEST устройства не выполнен';
    RecorderHardwareMarkSourceOffline(lSourceId, lErrorText);
  end;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.HardwareResetAllSourcesClick(Sender: TObject);
begin
  RecorderHardwareClearAllOfflineSources;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.HardwareToggleSourceClick(Sender: TObject);
var
  lConfig: TRecorderConfiguredDataSource;
  lSourceId: string;
begin
  lSourceId := SelectedHardwareSourceId;
  if lSourceId = '' then
    Exit;
  lConfig := RecorderConfiguredDataSourcesFind(fRecorder.TagRegistry, lSourceId);
  if lConfig = nil then
    Exit;
  lConfig.Enabled := not lConfig.Enabled;
  { Это изменение состава сбора, а не аппаратной конфигурации. }
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.HardwareEditSourceClick(Sender: TObject);
var
  lSourceId: string;
begin
  lSourceId := SelectedHardwareSourceId;
  if lSourceId = '' then
    Exit;
  EditHardwareSource(lSourceId);
end;

procedure TRecorderSettingsDialog.fHardwareTreeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  lNode: TTreeNode;
  lReason: string;
  lSourceId: string;
begin
  if fHardwareTree = nil then
    Exit;
  lNode := fHardwareTree.GetNodeAt(X, Y);
  lSourceId := '';
  while lNode <> nil do
  begin
    lSourceId := RecorderHardwareTreeSourceId(lNode);
    if lSourceId <> '' then
      Break;
    lNode := lNode.Parent;
  end;
  if lSourceId = '' then
  begin
    fHardwareTree.Hint := '';
    Exit;
  end;
  lReason := RecorderHardwareSourceOfflineReason(lSourceId);
  if not RecorderConfiguredDataSourceEnabled(fRecorder.TagRegistry,
    lSourceId) then
    fHardwareTree.Hint := 'Источник отключён пользователем'
  else if lReason <> '' then
    fHardwareTree.Hint := 'Ошибка устройства: ' + lReason
  else if (lNode <> nil) and (lNode.ImageIndex = CDeviceControllerImageIndex) then
    fHardwareTree.Hint := 'Устройство доступно'
  else
    fHardwareTree.Hint := 'Ошибка устройства: TEST не выполнен';
end;

procedure TRecorderSettingsDialog.PopulateHardwareTree;
var
  lRootNode: TTreeNode;
  lSourceNode: TTreeNode;
  lModuleNode: TTreeNode;
  I, J: Integer;
  lConfig: TRecorderConfiguredDataSource;
  lModuleCaptions: TStringList;
  lEntries: TRecorderHardwareTreeEntries;
  lEntry: TRecorderHardwareTreeEntry;
  lAcquiring: Boolean;
  lHost: string;
  lNodeCaption: string;
  lSerialNumber: LongWord;
  lVersionText: string;
  lPort: Word;
begin
  if fHardwareTree = nil then
    Exit;
  if fRecorder = nil then
    Exit;

  fHardwareTree.Items.BeginUpdate;
  try
    if fRecorder.TagRegistry <> nil then
      fRecorder.TagRegistry.RefreshActiveSourcesFromTags;

    RecorderHardwareTreeClearNodes(fHardwareTree);
    fHardwareTree.Items.Clear;
    lRootNode := fHardwareTree.Items.Add(nil, 'Устройства');
    lRootNode.ImageIndex := CDeviceRootImageIndex;
    lRootNode.SelectedIndex := CDeviceRootImageIndex;

    RecorderCollectHardwareTreeEntries(fRecorder.TagRegistry, lEntries);

    lModuleCaptions := TStringList.Create;
    try
      for I := 0 to High(lEntries) do
      begin
        lEntry := lEntries[I];
        lNodeCaption := lEntry.NodeCaption;
        if TryParseRecorderMic185SourceId(lEntry.SourceId, lHost, lPort) and
          RecorderMic185TryGetLiveDeviceInfo(lHost, lPort, lSerialNumber,
            lVersionText, lAcquiring) and (lSerialNumber <> 0) then
          lNodeCaption := Format('%s, SN=%d', [lNodeCaption, lSerialNumber]);
        if lEntry.Enabled then
          lSourceNode := fHardwareTree.Items.AddChild(lRootNode,
            lNodeCaption)
        else
          lSourceNode := fHardwareTree.Items.AddChild(lRootNode,
            '[ВЫКЛ] ' + lNodeCaption);
        RecorderHardwareTreeBindSourceId(lSourceNode, lEntry.SourceId);
      if fRecorder.TagRegistry <> nil then
        if lEntry.Enabled and lEntry.HasLinkedTags and lEntry.LinkOk then
          fRecorder.TagRegistry.RegisterActiveSource(lEntry.SourceId)
        else
          fRecorder.TagRegistry.UnregisterActiveSource(lEntry.SourceId);
      if lEntry.Enabled and lEntry.LinkOk then
      begin
        lSourceNode.ImageIndex := CDeviceControllerImageIndex;
        lSourceNode.SelectedIndex := CDeviceControllerImageIndex;
      end
      else
      begin
        lSourceNode.ImageIndex := CDeviceDisabledImageIndex;
        lSourceNode.SelectedIndex := CDeviceDisabledImageIndex;
        end;

        lConfig := RecorderConfiguredDataSourcesFind(fRecorder.TagRegistry,
          lEntry.SourceId);
        if (lConfig <> nil) and SameText(lConfig.ModuleType, 'MC-032') then
        begin
          RecorderMc032ModuleCaptions(lConfig.SpecificConfigText,
            lModuleCaptions);
          for J := 0 to lModuleCaptions.Count - 1 do
          begin
            lModuleNode := fHardwareTree.Items.AddChild(lSourceNode,
              lModuleCaptions[J]);
            lModuleNode.ImageIndex := CDeviceControllerImageIndex;
            lModuleNode.SelectedIndex := CDeviceControllerImageIndex;
          end;
          lSourceNode.Expand(False);
        end;
      end;
    finally
      lModuleCaptions.Free;
    end;

    lRootNode.Expand(True);
  finally
    fHardwareTree.Items.EndUpdate;
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
    fSelectedChannelsGrid.ColCount := 9;
    fSelectedChannelsGrid.FixedRows := 1;
    fSelectedChannelsGrid.RowCount := 2;
    fSelectedChannelsGrid.ColWidths[0] := 20;
    fSelectedChannelsGrid.Cells[0, 0] := '';
    fSelectedChannelsGrid.Cells[1, 0] := 'Имя';
    fSelectedChannelsGrid.Cells[2, 0] := 'Адрес';
    fSelectedChannelsGrid.Cells[3, 0] := 'Тип';
    fSelectedChannelsGrid.Cells[4, 0] := 'Частота';
    fSelectedChannelsGrid.Cells[5, 0] := 'ГХ';
    fSelectedChannelsGrid.Cells[6, 0] := 'Группа';
    fSelectedChannelsGrid.Cells[7, 0] := 'Информация';
    fSelectedChannelsGrid.Cells[8, 0] := 'ID';
    fSelectedChannelsGrid.Cells[0, 1] := '';
    fSelectedChannelsGrid.Cells[1, 1] := '';
    fSelectedChannelsGrid.Cells[2, 1] := '';
    fSelectedChannelsGrid.Cells[3, 1] := '';
    fSelectedChannelsGrid.Cells[4, 1] := '';
    fSelectedChannelsGrid.Cells[5, 1] := '';
    fSelectedChannelsGrid.Cells[6, 1] := '';
    fSelectedChannelsGrid.Cells[7, 1] := '';
    fSelectedChannelsGrid.Cells[8, 1] := '';
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
  lFilterText: string;

  function SelectedTagPassesFilter(ATag: TRecorderTag): Boolean;
  var
    lSearchText: string;
  begin
    Result := ATag <> nil;
    if not Result then
      Exit;
    if (cbHideInactiveSelectedChannels <> nil) and
      cbHideInactiveSelectedChannels.Checked and TagLinkedToInactiveHardware(ATag) then
      Exit(False);
    if (cbOnlyVirtualSelectedChannels <> nil) and
      cbOnlyVirtualSelectedChannels.Checked and
      (not TagIsVirtual(ATag)) then
      Exit(False);
    if lFilterText = '' then
      Exit(True);
    lSearchText := LowerCase(ATag.Name + ' ' + ATag.Address + ' ' +
      ATag.ModuleType + ' ' + ATag.SourceId + ' ' + ATag.Description);
    Result := Pos(lFilterText, lSearchText) > 0;
  end;

  procedure CountAvailableSignals(AGroup: TRecorderSettingsSourceGroup);
  var
    J: Integer;
  begin
    if fRecorder = nil then
      Exit;
    for J := 0 to fSourceProbe.GroupSignalCount(AGroup) - 1 do
      if not SignalHasLinkedTag(fSourceProbe.GroupSignal(AGroup, J)) then
        Inc(lEnabledCount);
  end;

  procedure FillAvailableSignals(AGroup: TRecorderSettingsSourceGroup);
  var
    J: Integer;
  begin
    if fRecorder = nil then
      Exit;
    for J := 0 to fSourceProbe.GroupSignalCount(AGroup) - 1 do
    begin
      lSignal := fSourceProbe.GroupSignal(AGroup, J);
      if SignalHasLinkedTag(lSignal) then
        Continue;
      fAvailableChannelsGrid.Cells[0, lRow] := lSignal.Address;
      fAvailableChannelsGrid.Cells[1, lRow] := lSignal.ModuleName;
      fAvailableChannelsGrid.Cells[2, lRow] := lSignal.Name;
      fAvailableChannelSignals.Add(lSignal);
      Inc(lRow);
    end;
  end;
begin
  SetGridHeaders;

  lFilterText := '';
  if edSelectedChannelsFilter <> nil then
  begin
    lFilterText := Trim(LowerCase(edSelectedChannelsFilter.Text));
    if SameText(lFilterText, 'filter') then
      lFilterText := '';
  end;

  if fRecorder = nil then
    Exit;

  if fAvailableChannelsGrid <> nil then
  begin
    fAvailableChannelSignals.Clear;
    lEnabledCount := 0;
    CountAvailableSignals(rsgMeraFile);
    CountAvailableSignals(rsgMic140);
    CountAvailableSignals(rsgMic185);
    CountAvailableSignals(rsgMcbus);

    if lEnabledCount = 0 then
      fAvailableChannelsGrid.RowCount := 2
    else
      fAvailableChannelsGrid.RowCount := lEnabledCount + 1;
    lRow := 1;
    FillAvailableSignals(rsgMeraFile);
    FillAvailableSignals(rsgMic140);
    FillAvailableSignals(rsgMic185);
    FillAvailableSignals(rsgMcbus);
  end;

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelTags.Clear;
    lSelectedTags := TList.Create;
    try
      if fRecorder.TagRegistry <> nil then
        for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
        begin
          lTag := fRecorder.TagRegistry.Tags[I];
          if SelectedTagPassesFilter(lTag) then
            lSelectedTags.Add(lTag);
        end;

      SortSelectedTags(lSelectedTags);

      if FindComponent('gbSelectedChannels') is TGroupBox then
        TGroupBox(FindComponent('gbSelectedChannels')).Caption :=
          Format('Выбранные каналы (%d)', [fRecorder.TagRegistry.TagCount]);

      if lSelectedTags.Count = 0 then
        fSelectedChannelsGrid.RowCount := 2
      else
        fSelectedChannelsGrid.RowCount := lSelectedTags.Count + 1;

      lRow := 1;
      for I := 0 to lSelectedTags.Count - 1 do
      begin
        lTag := TRecorderTag(lSelectedTags[I]);
        fSelectedChannelTags.Add(lTag);
        fSelectedChannelsGrid.Cells[0, lRow] := '';
        fSelectedChannelsGrid.Cells[1, lRow] := lTag.Name;
        fSelectedChannelsGrid.Cells[2, lRow] := lTag.Address;
        fSelectedChannelsGrid.Cells[3, lRow] := lTag.ModuleType;
        fSelectedChannelsGrid.Cells[4, lRow] := FormatFloat('0.######', lTag.PollFrequencyHz);
        fSelectedChannelsGrid.Cells[5, lRow] := '-';
        if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
          fSelectedChannelsGrid.Cells[6, lRow] := 'MIC-140'
        else if TryParseRecorderMic185SourceId(lTag.SourceId, lHost, lPort) then
          fSelectedChannelsGrid.Cells[6, lRow] := 'MIC183/185'
        else if TryParseRecorderMc032SourceId(lTag.SourceId, lHost, lPort) then
          fSelectedChannelsGrid.Cells[6, lRow] := 'MC-032 / MC-201'
        else if Pos('Mera file:', lTag.SourceId) = 1 then
          fSelectedChannelsGrid.Cells[6, lRow] := 'Mera File'
        else
          fSelectedChannelsGrid.Cells[6, lRow] := lTag.SourceId;
        fSelectedChannelsGrid.Cells[7, lRow] := lTag.Description;
        fSelectedChannelsGrid.Cells[8, lRow] := IntToStr(lTag.Id);
        Inc(lRow);
      end;
    finally
      lSelectedTags.Free;
    end;
  end;

  SGChange(fAvailableChannelsGrid);
  SGChange(fSelectedChannelsGrid);
end;

procedure TRecorderSettingsDialog.InitializeHardwareTree;
var
  lPopup: TPopupMenu;
  lItem: TMenuItem;
begin
  if fHardwareTree = nil then
    Exit;

  fHardwareTree.OnDblClick := @fHardwareTreeDblClick;
  fHardwareTree.OnKeyDown := @fHardwareTreeKeyDown;
  fHardwareTree.OnMouseMove := @fHardwareTreeMouseMove;
  fHardwareTree.OnMouseDown := @fHardwareTreeMouseDown;
  fHardwareTree.ShowHint := True;
  fHardwareTree.ParentShowHint := False;
  if fHardwareTree.PopupMenu = nil then
  begin
    lPopup := TPopupMenu.Create(Self);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Включить / выключить источник';
    lItem.OnClick := @HardwareToggleSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Перечитать теги источника';
    lItem.OnClick := @HardwareReloadSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Настройка источника...';
    lItem.OnClick := @HardwareEditSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Сбросить состояние устройства';
    lItem.OnClick := @HardwareResetSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'Сбросить состояние всех устройств';
    lItem.OnClick := @HardwareResetAllSourcesClick;
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
  finally
    fHardwareTree.Items.EndUpdate;
  end;
end;

procedure TRecorderSettingsDialog.fHardwareTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lNode: TTreeNode;
begin
  if (Button <> mbRight) or (fHardwareTree = nil) then
    Exit;
  lNode := fHardwareTree.GetNodeAt(X, Y);
  if lNode <> nil then
    fHardwareTree.Selected := lNode;
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

  lGroup := AddGroup(Self, lLeftPanel, 8, 482, 620, 66, 'База градуировочных характеристик');
  AddLabel(Self, lGroup, 10, 18, 'Каталог Mera Files');
  fMeraFilesPathEdit := AddEdit(Self, lGroup, 10, 36, 526, '');
  lButton := TButton.Create(Self);
  lButton.Parent := lGroup;
  lButton.Left := 548;
  lButton.Top := 34;
  lButton.Width := 54;
  lButton.Height := 26;
  lButton.Caption := '...';
  lButton.OnClick := @MeraFilesPathBrowseClick;

  lGroup := AddGroup(Self, lRightPanel, 8, 8, 210, 142, 'Условия старта записи');
  fStartManualRadio := AddRadio(Self, lGroup, 10, 20, 'По клавише', @ConditionChanged);
  fStartLevelRadio := AddRadio(Self, lGroup, 104, 20, 'По уровню', @ConditionChanged);
  fStartTriggerRadio := AddRadio(Self, lGroup, 10, 46, 'Триггерный старт', @ConditionChanged);
  fStartTriggerEdit := AddEdit(Self, lGroup, 140, 42, 48, '1');
  AddLabel(Self, lGroup, 10, 76, 'Канал');
  fStartChannelCombo := AddCombo(Self, lGroup, 52, 72, 136);
  fStartEdgeCombo := AddCombo(Self, lGroup, 10, 100, 74);
  fStartEdgeCombo.Items.Add('меньше');
  fStartEdgeCombo.Items.Add('меньше');
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
  fStopEdgeCombo.Items.Add('меньше');
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
procedure TRecorderSettingsDialog.SyncMeraFilesPathFromUi;
var
  lPath: string;
begin
  lPath := '';
  if fMeraFilesPathEdit <> nil then
    lPath := Trim(fMeraFilesPathEdit.Text);
  if (lPath = '') and (fRecorder.RunSettings <> nil) then
    lPath := Trim(fRecorder.RunSettings.MeraFilesPath);
  if lPath <> '' then
    SetRecorderMeraFilesPath(lPath);
end;

procedure TRecorderSettingsDialog.LoadFromSettings;
var
  I: Integer;
  lBindAddress: string;
begin
  if fRecorder.RunSettings = nil then
    Exit;

  fStartManualRadio.Checked := fRecorder.RunSettings.StartCondition = rscManual;
  fStartLevelRadio.Checked := fRecorder.RunSettings.StartCondition = rscSignalLevel;
  fStartTriggerRadio.Checked := fRecorder.RunSettings.StartCondition = rscExternalTrigger;
  fStartChannelCombo.Text := fRecorder.RunSettings.StartChannelName;
  fStartEdgeCombo.ItemIndex := Ord(fRecorder.RunSettings.StartEdge);
  fStartLevelEdit.Text := FloatToStr(fRecorder.RunSettings.StartLevel);

  fStopManualRadio.Checked := fRecorder.RunSettings.StopCondition = rstopManual;
  fStopLevelRadio.Checked := fRecorder.RunSettings.StopCondition = rstopSignalLevel;
  fStopDurationRadio.Checked := fRecorder.RunSettings.StopCondition = rstopDuration;
  fStopDurationEdit.Text := FormatFloat('0.000000', fRecorder.RunSettings.StopDelayMs / 1000);
  fStopChannelCombo.Text := fRecorder.RunSettings.StopChannelName;
  fStopEdgeCombo.ItemIndex := Ord(fRecorder.RunSettings.StopEdge);
  fStopLevelEdit.Text := FloatToStr(fRecorder.RunSettings.StopLevel);

  if fStartChannelCombo.Text = '' then
    fStartChannelCombo.Text := 'MemTag';
  if fStopChannelCombo.Text = '' then
    fStopChannelCombo.Text := 'MemTag';

  fScreenUpdateEdit.Text := FormatFloat('0.###', fRecorder.RunSettings.ScreenUpdateMs / 1000);
  fBufferSecondsEdit.Text := FormatFloat('0.###', fRecorder.RunSettings.DisplayBufferMs / 1000);
  fDataUpdateEdit.Text := FormatFloat('0.###', fRecorder.RunSettings.DataUpdateMs / 1000);
  fWorkDirEdit.Text := IncludeTrailingPathDelimiter(fRecorder.RunSettings.RecordRootDir);
  if fMeraFilesPathEdit <> nil then
  begin
    if Trim(fRecorder.RunSettings.MeraFilesPath) <> '' then
      fMeraFilesPathEdit.Text := fRecorder.RunSettings.MeraFilesPath
    else
      fMeraFilesPathEdit.Text := RecorderMeraFilesPath;
  end;
  SyncMeraFilesPathFromUi;
  fFrameDirEdit.Text := IncludeTrailingPathDelimiter(fRecorder.RunSettings.RecordRootDir) + '0001';
  fResetTimeCheck.Checked := True;
  if cbNetworkInterface <> nil then
  begin
    RecorderEnumerateLocalIPv4(cbNetworkInterface.Items);
    lBindAddress := RecorderNetworkBindAddress;
    if lBindAddress = '' then
      cbNetworkInterface.ItemIndex := 0
    else
    begin
      cbNetworkInterface.ItemIndex := -1;
      for I := 1 to cbNetworkInterface.Items.Count - 1 do
        if SameText(RecorderNetworkAddressFromDisplay(
          cbNetworkInterface.Items[I]), lBindAddress) then
        begin
          cbNetworkInterface.ItemIndex := I;
          Break;
        end;
      if cbNetworkInterface.ItemIndex < 0 then
      begin
        cbNetworkInterface.Items.Add(lBindAddress);
        cbNetworkInterface.ItemIndex := cbNetworkInterface.Items.Count - 1;
      end;
    end;
  end;

  UpdateConditionControls;
  if fRecorder.TagRegistry <> nil then
    fFrequencyBands.Assign(fRecorder.TagRegistry.FrequencyBands);
end;

{ Перенос настроек из UI в объект fRecorder.RunSettings }
procedure TRecorderSettingsDialog.StoreToSettings;
begin
  if fRecorder.RunSettings = nil then
    Exit;

  { Внешние кнопки «Применить» и OK также должны сохранить текущую строку
    алгоритма, даже если внутренняя кнопка спектра не была нажата. }
  if SelectedSpectrumConfigNode <> nil then
    StoreSelectedAlgorithmSettings;

  if cbNetworkInterface <> nil then
    if cbNetworkInterface.ItemIndex <= 0 then
      SetRecorderNetworkBindAddress('')
    else
      SetRecorderNetworkBindAddress(
        RecorderNetworkAddressFromDisplay(cbNetworkInterface.Text));

  if fStartLevelRadio.Checked then
    fRecorder.RunSettings.StartCondition := rscSignalLevel
  else if fStartTriggerRadio.Checked then
    fRecorder.RunSettings.StartCondition := rscExternalTrigger
  else
    fRecorder.RunSettings.StartCondition := rscManual;

  fRecorder.RunSettings.StartChannelName := fStartChannelCombo.Text;
  fRecorder.RunSettings.StartEdge := TRecorderSignalEdge(fStartEdgeCombo.ItemIndex);
  fRecorder.RunSettings.StartLevel := ReadFloatEdit(fStartLevelEdit, fRecorder.RunSettings.StartLevel);

  if fStopLevelRadio.Checked then
    fRecorder.RunSettings.StopCondition := rstopSignalLevel
  else if fStopDurationRadio.Checked then
    fRecorder.RunSettings.StopCondition := rstopDuration
  else
    fRecorder.RunSettings.StopCondition := rstopManual;

  fRecorder.RunSettings.StopChannelName := fStopChannelCombo.Text;
  fRecorder.RunSettings.StopEdge := TRecorderSignalEdge(fStopEdgeCombo.ItemIndex);
  fRecorder.RunSettings.StopLevel := ReadFloatEdit(fStopLevelEdit, fRecorder.RunSettings.StopLevel);
  fRecorder.RunSettings.StopDelayMs := ReadSecondsAsMs(fStopDurationEdit, fRecorder.RunSettings.StopDelayMs);
  fRecorder.RunSettings.ScreenUpdateMs := ReadSecondsAsMs(fScreenUpdateEdit,
    fRecorder.RunSettings.ScreenUpdateMs);
  fRecorder.RunSettings.DisplayBufferMs := ReadSecondsAsMs(fBufferSecondsEdit,
    fRecorder.RunSettings.DisplayBufferMs);
  fRecorder.RunSettings.DataUpdateMs := ReadSecondsAsMs(fDataUpdateEdit,
    fRecorder.RunSettings.DataUpdateMs);
  fRecorder.RunSettings.RecordRootDir := IncludeTrailingPathDelimiter(Trim(fWorkDirEdit.Text));
  if fMeraFilesPathEdit <> nil then
    fRecorder.RunSettings.MeraFilesPath := ExcludeTrailingPathDelimiter(Trim(fMeraFilesPathEdit.Text));
  SetRecorderMeraFilesPath(fRecorder.RunSettings.MeraFilesPath);
  fRecorder.RunSettings.RequireValid;
  if fRecorder.TagRegistry <> nil then
  begin
    fRecorder.TagRegistry.SpectrumConfigs.Assign(fSpectrumConfigTree);
    fRecorder.TagRegistry.FrequencyBands.Assign(fFrequencyBands);
  end;
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

procedure TRecorderSettingsDialog.MeraFilesPathBrowseClick(Sender: TObject);
var
  lDir: string;
begin
  if fMeraFilesPathEdit = nil then
    Exit;
  lDir := Trim(fMeraFilesPathEdit.Text);
  if lDir = '' then
    lDir := RecorderMeraFilesPath;
  if SelectDirectory('Каталог Mera Files', '', lDir) then
    fMeraFilesPathEdit.Text := ExcludeTrailingPathDelimiter(lDir);
end;
procedure TRecorderSettingsDialog.ApplyButtonClick(Sender: TObject);
begin
  StoreToSettings;
  ApplySpectrumConfiguration;
end;



procedure TRecorderSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToSettings;
  RemoveOrphanSpectrumEstimateTags;
  if fSourceProbe <> nil then
    fSourceProbe.SyncToRegistry;
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

{ Назначение картинки кнопкам с глифом }
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
  fDataSourcesChanged := True;
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
    if (lTag <> nil) and (fRecorder.TagRegistry <> nil) then
      fRecorder.TagRegistry.RemoveTag(lTag);
  end;
  MarkSignalsFromRegistry;
  fDataSourcesChanged := True;
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
  fDataSourcesChanged := True;
  MarkSignalsFromRegistry;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.btnChannelEditClick(Sender: TObject);
begin
  OpenSelectedChannelTagSettings;
end;

procedure TRecorderSettingsDialog.btnCreateVirtualTagClick(Sender: TObject);
var
  lName: string;
  lTag: TRecorderTag;
  lIsVector: Boolean;
  lFrequencyHz: Double;
begin
  if (fRecorder = nil) or (fRecorder.TagRegistry = nil) then
    Exit;
  if not ShowRecorderVirtualTagDialog(Self, lName, lIsVector,
    lFrequencyHz) then
    Exit;
  lName := Trim(lName);
  if lName = '' then
  begin
    MessageDlg('Создание виртуального тега', 'Имя тега не может быть пустым.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if fRecorder.TagRegistry.FindByName(lName) <> nil then
  begin
    MessageDlg('Создание виртуального тега',
      'Тег с именем "' + lName + '" уже существует.', mtWarning, [mbOK], 0);
    Exit;
  end;
  lTag := fRecorder.TagRegistry.CreateTag(lName, 4096, True);
  lTag.IsVector := lIsVector;
  lTag.PollFrequencyHz := lFrequencyHz;
  lTag.SourceId := 'manual';
  if lIsVector then
    lTag.SourceValueMode := 'vector'
  else
    lTag.SourceValueMode := 'scalar';
  lTag.Address := 'virtual.' + lName;
  lTag.ModuleType := 'Virtual';
  if lIsVector then
    lTag.Description := 'Пользовательский виртуальный векторный тег'
  else
    lTag.Description := 'Пользовательский виртуальный скалярный тег';
  lTag.UnitName := '-';
  lTag.AutoUnit := False;
  fDataSourcesChanged := True;
  PopulateChannelGrids;
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

procedure TRecorderSettingsDialog.fSelectedChannelsGridDrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  lBitmap: TBitmap;
  lIconLeft: Integer;
  lIconTop: Integer;
  lIconRect: TRect;
  lImageIndex: Integer;
  lTag: TRecorderTag;
begin
  if (Sender <> fSelectedChannelsGrid) or (aCol <> 0) or (aRow < 1) or
    (fDeviceImageList = nil) then
    Exit;

  lTag := SelectedTagByGridRow(aRow);
  if TagIsVirtual(lTag) then
    lImageIndex := CDeviceVirtualTagImageIndex
  else if TagLinkedToInactiveHardware(lTag) then
    lImageIndex := CDeviceInactiveTagImageIndex
  else
    Exit;

  if (lImageIndex < 0) or (lImageIndex >= fDeviceImageList.Count) then
    Exit;

  if gdSelected in aState then
  begin
    fSelectedChannelsGrid.Canvas.Brush.Color := clHighlight;
    fSelectedChannelsGrid.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    fSelectedChannelsGrid.Canvas.Brush.Color := fSelectedChannelsGrid.Color;
    fSelectedChannelsGrid.Canvas.Font.Color := fSelectedChannelsGrid.Font.Color;
  end;
  fSelectedChannelsGrid.Canvas.FillRect(aRect);

  lIconLeft := aRect.Left + ((aRect.Right - aRect.Left) - CDeviceInactiveTagIconSize) div 2;
  lIconTop := aRect.Top + ((aRect.Bottom - aRect.Top) - CDeviceInactiveTagIconSize) div 2;
  if lIconLeft < aRect.Left then
    lIconLeft := aRect.Left;
  if lIconTop < aRect.Top then
    lIconTop := aRect.Top;
  lIconRect := Rect(lIconLeft, lIconTop, lIconLeft + CDeviceInactiveTagIconSize,
    lIconTop + CDeviceInactiveTagIconSize);

  lBitmap := TBitmap.Create;
  try
    fDeviceImageList.GetBitmap(lImageIndex, lBitmap);
    fSelectedChannelsGrid.Canvas.StretchDraw(lIconRect, lBitmap);
  finally
    lBitmap.Free;
  end;

  if gdFocused in aState then
    fSelectedChannelsGrid.Canvas.DrawFocusRect(aRect);
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
    StoreToSettings;
    ApplySpectrumConfiguration;
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

{ Двойной клик по дочернему узлу MC-201 открывает свойства именно модуля.
  Проверка Parent + разбор номера слота обязательны: fallback ниже предназначен
  для родительского MC-032 и иначе снова откроет диалог контроллера. }
procedure TRecorderSettingsDialog.fHardwareTreeDblClick(Sender: TObject);
var
  lConfig: TRecorderConfiguredDataSource;
  lConfigText: string;
  lSerial: string;
  lSlot: Integer;
  lSourceId: string;
  lVersion: string;
begin
  lSourceId := SelectedHardwareSourceId;
  if lSourceId = '' then
    Exit;
  if (fHardwareTree.Selected <> nil) and
    (fHardwareTree.Selected.Parent <> nil) and
    TryParseRecorderMc201ModuleCaption(fHardwareTree.Selected.Text, lSlot,
      lSerial, lVersion) then
  begin
    lConfig := RecorderConfiguredDataSourcesFind(fRecorder.TagRegistry, lSourceId);
    if (lConfig <> nil) and SameText(lConfig.ModuleType, 'MC-032') then
    begin
      lConfigText := lConfig.SpecificConfigText;
      if ShowRecorderMc201SlotSettingsDialog(Self, fHardwareTree.Selected.Text,
        lConfigText, lSourceId, fRecorder.DataSources,
        fRecorder.TagRegistry) then
      begin
        lConfig.SpecificConfigText := lConfigText;
        fHardwareTree.Invalidate;
      end;
    end;
    Exit;
  end;
  EditHardwareSource(lSourceId);
end;

procedure TRecorderSettingsDialog.ApplySpectrumConfiguration;
begin
  if (fRecorder = nil) or (fRecorder.AlgorithmManager = nil) then
    Exit;
  RemoveOrphanSpectrumEstimateTags;
  { Производные теги являются частью применённой конфигурации. Создаём их
    сразу, чтобы результат «Создать теги» был виден в этом же диалоге. }
  fRecorder.AlgorithmManager.PrepareConfiguration;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.RemoveOrphanSpectrumEstimateTags;
var
  I, J, K: Integer;
  lTag: TRecorderTag;
  lSourceTagName: string;
  lReferenced: Boolean;
begin
  if (fRecorder = nil) or (fRecorder.TagRegistry = nil) then
    Exit;

  { Estimate tag names are user-editable. SourceId is the stable ownership key
    used by the spectrum runtime: "spectrum:<source tag>". }
  for I := fRecorder.TagRegistry.TagCount - 1 downto 0 do
  begin
    lTag := fRecorder.TagRegistry.Tags[I];
    if not SameText(lTag.ModuleType, 'Spectrum estimate') then
      Continue;
    if Pos('spectrum:', LowerCase(lTag.SourceId)) <> 1 then
      Continue;
    lSourceTagName := Copy(lTag.SourceId, Length('spectrum:') + 1, MaxInt);
    lReferenced := False;
    for J := 0 to fRecorder.TagRegistry.SpectrumConfigs.NodeCount - 1 do
    begin
      for K := 0 to fRecorder.TagRegistry.SpectrumConfigs.Nodes[J].BindingCount - 1 do
        if SameText(fRecorder.TagRegistry.SpectrumConfigs.Nodes[J].Bindings[K].SourceTagName,
          lSourceTagName) then
        begin
          lReferenced := True;
          Break;
        end;
      if lReferenced then
        Break;
    end;
    if not lReferenced then
      fRecorder.TagRegistry.RemoveTag(lTag);
  end;
end;

procedure TRecorderSettingsDialog.SelectedChannelsFilterChanged(Sender: TObject);
begin
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.SelectedChannelsFilterClearClick(Sender: TObject);
begin
  if edSelectedChannelsFilter <> nil then
    edSelectedChannelsFilter.Clear;
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

