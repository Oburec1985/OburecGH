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

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ImgList, Grids, Buttons,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderTags, uMeraFile,
  uRecorderCommandImages;

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
    procedure fAvailableChannelsGridDblClick(Sender: TObject);
    procedure fAvailableChannelsGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure fSelectedChannelsGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure fSelectedChannelsGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure fHardwareTreeDblClick(Sender: TObject);
  private
    fRunSettings: TRecorderRunControlSettings;   // Ссылка на объект настроек запуска/останова
    fTagRegistry: TRecorderTagRegistry;         // Ссылка на реестр тегов приложения
    fDeviceImageList: TCustomImageList;         // Список картинок для дерева устройств
    fMeraFolder: string;                        // Путь к последней папке импортированного Mera-файла
    fMeraFileName: string;                      // Имя импортированного Mera-файла
    fMeraSignals: TList;                        // Список TMeraSignalInfo, загруженных из файла
    
    // Вспомогательные методы работы с Mera-сигналами
    procedure AddMeraSignal(ASignal: TMeraSignalInfo);
    procedure CreateSelectedMeraTags;
    procedure ClearMeraSignals;
    procedure RestoreMeraSignalsFromTags;
    function FindMeraSignalByTagName(const ATagName: string): TMeraSignalInfo;
    function AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    function SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    procedure LoadMeraFile(const AFileName: string);
    
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
    property RunSettings: TRecorderRunControlSettings read fRunSettings write SetRunSettings;
    property TagRegistry: TRecorderTagRegistry read fTagRegistry write SetTagRegistry;
  end;

{ Отображает модальный диалог настроек }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry = nil;
  ADeviceImageList: TCustomImageList = nil): Boolean;

implementation

{$R *.lfm}

{ Точка входа для запуска диалога настроек }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry;
  ADeviceImageList: TCustomImageList): Boolean;
var
  lDialog: TRecorderSettingsDialog;
begin
  lDialog := TRecorderSettingsDialog.Create(AOwner);
  try
    lDialog.DeviceImageList := ADeviceImageList;
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
begin
  if (AButton = nil) or (AImages = nil) or (AIndex < 0) or
    (AIndex >= AImages.Count) then
    Exit;

  lBitmap := TBitmap.Create;
  try
    AImages.GetBitmap(AIndex, lBitmap);
    AButton.Caption := '';
    AButton.Glyph.Assign(lBitmap);
    AButton.Layout := blGlyphTop;
    AButton.Margin := 0;
  finally
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
  AssignButtonImage(btnChannelAdd, fDeviceImageList, CIconAdd);
  AssignButtonImage(btnChannelRemove, fDeviceImageList, CIconRemove);

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

{ Создание или обновление каналов/тегов в реестре на основе выбранных сигналов Mera-файла }
procedure TRecorderSettingsDialog.CreateSelectedMeraTags;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
  lTagName: string;
begin
  if (fTagRegistry = nil) or (fMeraSignals = nil) then
    Exit;

  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if not lSignal.Selected then
      Continue;

    lTagName := MeraSignalToRecorderTagName(lSignal);
    lTag := fTagRegistry.FindByName(lTagName);
    if lTag = nil then
      lTag := fTagRegistry.CreateTag(lTagName, 4096);

    lTag.Address := lSignal.Address;
    lTag.UnitName := lSignal.UnitsName;
    lTag.SourceId := 'Mera file: ' + fMeraFileName;
    lTag.ModuleType := lSignal.ModuleName;
    lTag.PollFrequencyHz := lSignal.FrequencyHz;
    lTag.Description := Format('%s; type=%s; freq=%s; file=%s',
      [lSignal.Name, lSignal.DataTypeName, FormatFloat('0.######', lSignal.FrequencyHz),
      ExtractFileName(lSignal.FileName)]);
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
    LoadMeraSignalsFromFile(lFileName, fMeraSignals)
  else
    ClearMeraSignals;

  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if not SameText(lTag.SourceId, CMeraSourcePrefix + lFileName) then
      Continue;

    lSignal := FindMeraSignalByTagName(lTag.Name);
    if lSignal <> nil then
    begin
      lSignal.Enabled := True;
      lSignal.Selected := True;
    end;
  end;

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
    if lSignal.Selected then
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
    if not lSignal.Selected then
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

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

{ Обновление дерева аппаратной части при загрузке файлов Mera }
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
      lSourceNode.ImageIndex := CDeviceControllerImageIndex;
      lSourceNode.SelectedIndex := CDeviceControllerImageIndex;

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
    fSelectedChannelsGrid.ColCount := 7;
    fSelectedChannelsGrid.FixedRows := 1;
    fSelectedChannelsGrid.RowCount := 2;
    fSelectedChannelsGrid.Cells[0, 0] := 'Имя';
    fSelectedChannelsGrid.Cells[1, 0] := 'Адрес';
    fSelectedChannelsGrid.Cells[2, 0] := 'Тип';
    fSelectedChannelsGrid.Cells[3, 0] := 'Частота';
    fSelectedChannelsGrid.Cells[4, 0] := 'ГХ';
    fSelectedChannelsGrid.Cells[5, 0] := 'Группа';
    fSelectedChannelsGrid.Cells[6, 0] := 'Информация';
    fSelectedChannelsGrid.Cells[0, 1] := 'MemTag';
    fSelectedChannelsGrid.Cells[1, 1] := 'virtual';
    fSelectedChannelsGrid.Cells[2, 1] := '';
    fSelectedChannelsGrid.Cells[3, 1] := '0.0';
    fSelectedChannelsGrid.Cells[4, 1] := '-';
    fSelectedChannelsGrid.Cells[5, 1] := 'Основные каналы';
    fSelectedChannelsGrid.Cells[6, 1] := '';
  end;
end;

{ Заполнение сеток доступных и выбранных каналов на основе fMeraSignals }
procedure TRecorderSettingsDialog.PopulateChannelGrids;
var
  I: Integer;
  lRow: Integer;
  lEnabledCount: Integer;
  lSignal: TMeraSignalInfo;
begin
  SetGridHeaders;

  if fAvailableChannelsGrid <> nil then
  begin
    lEnabledCount := 0;
    for I := 0 to fMeraSignals.Count - 1 do
      if not TMeraSignalInfo(fMeraSignals[I]).Selected then
        Inc(lEnabledCount);

    if lEnabledCount = 0 then
      fAvailableChannelsGrid.RowCount := 2
    else
      fAvailableChannelsGrid.RowCount := lEnabledCount + 1;
    lRow := 1;
    for I := 0 to fMeraSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(fMeraSignals[I]);
      if lSignal.Selected then
        Continue;
      fAvailableChannelsGrid.Cells[0, lRow] := lSignal.Address;
      fAvailableChannelsGrid.Cells[1, lRow] := lSignal.ModuleName;
      fAvailableChannelsGrid.Cells[2, lRow] := lSignal.Name;
      Inc(lRow);
    end;
  end;

  if fSelectedChannelsGrid <> nil then
  begin
    lEnabledCount := 0;
    for I := 0 to fMeraSignals.Count - 1 do
      if TMeraSignalInfo(fMeraSignals[I]).Selected then
        Inc(lEnabledCount);
    if lEnabledCount = 0 then
      fSelectedChannelsGrid.RowCount := 2
    else
      fSelectedChannelsGrid.RowCount := lEnabledCount + 1;
    lRow := 1;
    for I := 0 to fMeraSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(fMeraSignals[I]);
      if not lSignal.Selected then
        Continue;
      fSelectedChannelsGrid.Cells[0, lRow] := MeraSignalToRecorderTagName(lSignal);
      fSelectedChannelsGrid.Cells[1, lRow] := lSignal.Address;
      fSelectedChannelsGrid.Cells[2, lRow] := lSignal.ModuleName;
      fSelectedChannelsGrid.Cells[3, lRow] := FormatFloat('0.######', lSignal.FrequencyHz);
      fSelectedChannelsGrid.Cells[4, lRow] := '-';
      fSelectedChannelsGrid.Cells[5, lRow] := 'Mera File';
      fSelectedChannelsGrid.Cells[6, lRow] := lSignal.Name + ', ' + ExtractFileName(lSignal.FileName);
      Inc(lRow);
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
begin
  if fHardwareTree = nil then
    Exit;

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
  PopulateChannelGrids;
end;

{ Исключение каналов из активного списка }
procedure TRecorderSettingsDialog.btnChannelRemoveClick(Sender: TObject);
var
  lSignal: TMeraSignalInfo;
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
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

  for lRow := lTop to lBottom do
  begin
    lSignal := SelectedSignalByGridRow(lRow);
    if lSignal <> nil then
      lSignal.Selected := False;
  end;
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
  PopulateChannelGrids;
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

initialization
  RegisterClasses([
    TPageControl, TTabSheet, TPanel, TGroupBox, TLabel, TEdit, TCheckBox,
    TRadioButton, TComboBox, TButton, TTreeView, TStringGrid, TSplitter
  ]);

end.
