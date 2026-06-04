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
  uRecorderCommandImages, uTagSettingsDialog;

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
    procedure fHardwareTreeDblClick(Sender: TObject);
    procedure fHardwareTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WorkDirBrowseClick(Sender: TObject);
  private
    fRunSettings: TRecorderRunControlSettings;   // Ссылка на объект настроек запуска/останова
    fTagRegistry: TRecorderTagRegistry;         // Ссылка на реестр тегов приложения
    fDeviceImageList: TCustomImageList;         // Список картинок для дерева устройств
    fTagDialogImageList: TCustomImageList;      // Список иконок диалога настройки тегов
    fMeraFolder: string;                        // Путь к последней папке импортированного Mera-файла
    fMeraFileName: string;                      // Имя импортированного Mera-файла
    fMeraSignals: TList;                        // Список TMeraSignalInfo, загруженных из файла
    fSelectedChannelTags: TList;                // Row-map выбранных каналов на TRecorderTag
    fSelectedSortColumn: Integer;               // Колонка текущей сортировки выбранных каналов
    fSelectedSortAscending: Boolean;            // Направление текущей сортировки
    
    // Вспомогательные методы работы с Mera-сигналами
    procedure AddMeraSignal(ASignal: TMeraSignalInfo);
    function CloneMeraSignalForTag(ASignal: TMeraSignalInfo;
      const ATagName: string): TMeraSignalInfo;
    procedure ApplyMeraSignalToTag(ATag: TRecorderTag; ASignal: TMeraSignalInfo);
    function FindTagBySourceAddress(const ASourceId, AAddress: string): TRecorderTag;
    function SignalHasLinkedTag(ASignal: TMeraSignalInfo): Boolean;
    function SelectedTagByGridRow(ARow: Integer): TRecorderTag;
    function CompareTagsForSelectedGrid(ATagA, ATagB: TRecorderTag): Integer;
    procedure SortSelectedTags(ATags: TList);
    procedure SortSelectedChannelsByColumn(AColumn: Integer);
    procedure OpenSelectedChannelTagSettings;
    procedure CreateSelectedMeraTags;
    procedure ClearMeraSignals;
    procedure RestoreMeraSignalsFromTags;
    function FindMeraSignalByTagName(const ATagName: string): TMeraSignalInfo;
    function AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    function SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    procedure LoadMeraFile(const AFileName: string);
    procedure MarkSignalsFromRegistry;
    function MeraSourceId(const AFileName: string): string;
    procedure DeleteCurrentMeraSource;
    procedure ReloadCurrentMeraSource;
    procedure HardwareDeleteSourceClick(Sender: TObject);
    procedure HardwareReloadSourceClick(Sender: TObject);
    procedure HardwareEditSourceClick(Sender: TObject);
    
    // Методы инициализации и обновления интерфейса
    procedure PopulateChannelGrids;
    procedure PopulateHardwareTree;
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
  fSelectedChannelTags := TList.Create;
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

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelsGrid.OnDblClick := @fSelectedChannelsGridDblClick;
    fSelectedChannelsGrid.OnMouseDown := @fSelectedChannelsGridMouseDown;
  end;

  SetGridHeaders;
  InitializeHardwareTree;
  UpdateConditionControls;
end;

destructor TRecorderSettingsDialog.Destroy;
begin
  ClearMeraSignals;
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
end;

procedure TRecorderSettingsDialog.SetDeviceImageList(AValue: TCustomImageList);
begin
  fDeviceImageList := AValue;
  if fHardwareTree <> nil then
  begin
    fHardwareTree.Images := fDeviceImageList;
    fHardwareTree.ImagesWidth := 16;
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
begin
  if (ATag = nil) or (ASignal = nil) then
    Exit;

  ATag.Address := ASignal.Address;
  ATag.UnitName := ASignal.UnitsName;
  ATag.SourceId := MeraSourceId(fMeraFileName);
  ATag.ModuleType := ASignal.ModuleName;
  ATag.PollFrequencyHz := ASignal.FrequencyHz;
  ATag.Description := Format('%s; type=%s; freq=%s; file=%s',
    [ASignal.Name, ASignal.DataTypeName, FormatFloat('0.######', ASignal.FrequencyHz),
    ExtractFileName(ASignal.FileName)]);
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
    (FindTagBySourceAddress(MeraSourceId(fMeraFileName), ASignal.Address) <> nil);
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
end;

{ Создание или обновление каналов/тегов в реестре на основе выбранных сигналов Mera-файла }
procedure TRecorderSettingsDialog.CreateSelectedMeraTags;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
  lSourceId: string;
  lTagName: string;
begin
  if (fTagRegistry = nil) or (fMeraSignals = nil) then
    Exit;

  lSourceId := MeraSourceId(fMeraFileName);
  if fMeraFileName <> '' then
    fTagRegistry.RegisterActiveSource(lSourceId);

  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if not SignalHasLinkedTag(lSignal) then
      Continue;

    lTag := FindTagBySourceAddress(lSourceId, lSignal.Address);
    if lTag = nil then
    begin
      lTagName := MeraSignalToRecorderTagName(lSignal);
      lTag := fTagRegistry.FindByName(lTagName);
      if lTag = nil then
        lTag := fTagRegistry.CreateTag(lTagName, 4096);
    end;

    ApplyMeraSignalToTag(lTag, lSignal);
  end;
end;

procedure TRecorderSettingsDialog.ClearMeraSignals;
begin
  uMeraFile.ClearMeraSignals(fMeraSignals);
end;
procedure TRecorderSettingsDialog.RestoreMeraSignalsFromTags;
const
  CMeraSourcePrefix = 'Mera file: ';
var
  I: Integer;
  lFileName: string;
  lSignal: TMeraSignalInfo;
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

{ Возвращает Mera-сигнал по строке таблицы доступных каналов }
function TRecorderSettingsDialog.AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
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

procedure TRecorderSettingsDialog.HardwareDeleteSourceClick(Sender: TObject);
begin
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
  lSignal: TMeraSignalInfo;
begin
  if fHardwareTree = nil then
    Exit;

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
  lSelectedTags: TList;
  lSignal: TMeraSignalInfo;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  SetGridHeaders;
  lSourceId := MeraSourceId(fMeraFileName);

  if fAvailableChannelsGrid <> nil then
  begin
    lEnabledCount := 0;
    for I := 0 to fMeraSignals.Count - 1 do
      if not SignalHasLinkedTag(TMeraSignalInfo(fMeraSignals[I])) then
        Inc(lEnabledCount);

    if lEnabledCount = 0 then
      fAvailableChannelsGrid.RowCount := 2
    else
      fAvailableChannelsGrid.RowCount := lEnabledCount + 1;
    lRow := 1;
    for I := 0 to fMeraSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(fMeraSignals[I]);
      if SignalHasLinkedTag(lSignal) then
        Continue;
      fAvailableChannelsGrid.Cells[0, lRow] := lSignal.Address;
      fAvailableChannelsGrid.Cells[1, lRow] := lSignal.ModuleName;
      fAvailableChannelsGrid.Cells[2, lRow] := lSignal.Name;
      Inc(lRow);
    end;
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
        fSelectedChannelsGrid.Cells[5, lRow] := 'Mera File';
        fSelectedChannelsGrid.Cells[6, lRow] := lTag.Description;
        fSelectedChannelsGrid.Cells[7, lRow] := IntToStr(lTag.Id);
        Inc(lRow);
      end;
    finally
      lSelectedTags.Free;
    end;
  end;
end;

{ Переключение активности сигнала по двойному клику в дереве аппаратных модулей }
procedure TRecorderSettingsDialog.ToggleHardwareSignal(ANode: TTreeNode);
var
  lSignal: TMeraSignalInfo;
begin
  if (ANode = nil) or (ANode.Data = nil) then
    Exit;

  lSignal := TMeraSignalInfo(ANode.Data);
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
  if (fAvailableChannelsGrid = nil) or (fMeraSignals = nil) then
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
  lCol: LongInt;
  lRow: LongInt;
begin
  if (Button <> mbLeft) or (fSelectedChannelsGrid = nil) then
    Exit;

  fSelectedChannelsGrid.MouseToCell(X, Y, lCol, lRow);
  if lRow = 0 then
    SortSelectedChannelsByColumn(lCol);
end;
procedure TRecorderSettingsDialog.fAvailableChannelsGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // Не начинать drag-and-drop здесь: TStringGrid использует MouseDown для выделения.
end;

{ Drag and Drop доступного канала в активную сетку }
procedure TRecorderSettingsDialog.fSelectedChannelsGridDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  lSignal: TMeraSignalInfo;
begin
  if Source <> fAvailableChannelsGrid then
    Exit;

  lSignal := AvailableSignalByGridRow(fAvailableChannelsGrid.Row);
  if lSignal = nil then
    Exit;

  lSignal.Selected := True;
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
    TRadioButton, TComboBox, TButton, TTreeView, TStringGrid, TSplitter
  ]);

end.
