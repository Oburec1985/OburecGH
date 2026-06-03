unit uRecorderCoreServices;

{
  Модуль uRecorderCoreServices

  Назначение:
    Базовые core-сервисы RecorderLnx для событий, команд UI/action и статических
    расширений первой версии. Это минимальный перенос полезной механики Recorder:
    Notify, custom toolbar buttons и PluginManager, но без COM, HWND и LCL.

  Место в архитектуре:
    Core/domain. Модуль не зависит от UI и не знает о тегах, устройствах или
    записи. Эти подсистемы будут публиковать события и регистрировать действия
    через описанные здесь сервисы.

  Ограничения первой версии:
    Расширения пока статические Object Pascal-классы внутри процесса. Внешняя
    граница .dll/.so будет отдельным адаптером C ABI поверх этого lifecycle.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { Тип события RecorderLnx.
    Имена намеренно близки к PN_* из Recorder, но события типизированы и не
    требуют передачи указателей через DWORD. }
  TRecorderEventKind = (
    rceBeforeStart,          { Перед запуском процесса записи }
    rceStarted,              { Запись успешно запущена }
    rceRecordModeEntered,    { Вход в режим записи }
    rceStopped,              { Запись остановлена }
    rceAfterStop,            { После останова записи }
    rceDataUpdated,          { Обновление данных/семплов }
    rceAlarmChanged,         { Изменение состояния тревоги/уставки тега }
    rceSaveConfig,           { Событие сохранения конфигурации }
    rceLoadConfig,           { Событие загрузки конфигурации }
    rceImportSettings,       { Импорт настроек }
    rceExportSettings,       { Экспорт настроек }
    rceDataPlacementChanged, { Изменение расположения данных }
    rceActionExecute,        { Выполнение действия }
    rceFormsChanged,         { Изменение форм или экранов отображения }
    rceUser                  { Пользовательское событие }
  );

  { Данные одного события core-шины.
    
    Kind      - тип события.
    Source    - объект-источник, если он есть.
    Name      - уточняющее имя события или user-event id.
    Text      - короткие текстовые данные для логов/простых команд.
    IntValue  - числовой параметр для счетчиков и кодов.
    Data      - объектная полезная нагрузка. Владение не передается. }
  TRecorderEvent = record
    Kind: TRecorderEventKind;
    Source: TObject;
    Name: string;
    Text: string;
    IntValue: Int64;
    Data: TObject;
  end;

  { Обработчик события.
    
    ASender - экземпляр TRecorderEventBus.
    AEvent  - данные события. Обработчик не должен освобождать AEvent.Data. }
  TRecorderEventHandler = procedure(ASender: TObject;
    const AEvent: TRecorderEvent) of object;

  { Класс исключения для сервисов ядра }
  ERecorderCoreServiceError = class(Exception);

  { TRecorderEventBus
    Простая синхронная событийная шина. Подписчики вызываются в том же потоке,
    который публикует событие. Для событий из worker-thread позже будет отдельный
    UI dispatcher/queue, чтобы не трогать LCL напрямую. }
  TRecorderEventBus = class
  private type
    { Внутренний класс подписки }
    TSubscription = class
    public
      Token: Integer;                 { Уникальный токен подписки }
      Handler: TRecorderEventHandler; { Обработчик события }
    end;
  private
    fNextToken: Integer;              { Счетчик для генерации следующего токена }
    fSubscriptions: TList;            { Список активных подписок (TSubscription) }
    function GetSubscription(AIndex: Integer): TSubscription;
  public
    { Создает пустую шину событий }
    constructor Create;
    { Уничтожает шину и очищает все подписки }
    destructor Destroy; override;

    { Подписывает обработчик и возвращает token для будущей отписки }
    function Subscribe(AHandler: TRecorderEventHandler): Integer;

    { Удаляет подписку по token. Возвращает True, если подписка была найдена }
    function Unsubscribe(AToken: Integer): Boolean;

    { Синхронно рассылает событие всем текущим подписчикам.
      Если обработчик отписывает себя или других подписчиков во время обработки,
      текущая рассылка продолжает идти по снимку списка, чтобы не пропускать
      соседние обработчики из-за сдвига индексов. }
    procedure Publish(const AEvent: TRecorderEvent);

    { Удобный конструктор события без объектной нагрузки }
    class function MakeEvent(AKind: TRecorderEventKind; ASource: TObject = nil;
      const AName: string = ''; const AText: string = '';
      AIntValue: Int64 = 0; AData: TObject = nil): TRecorderEvent; static;
  end;

  { Контекст выполнения action.
    
    Sender   - UI/control/plugin, который вызвал команду.
    Text     - строковый параметр команды.
    IntValue - числовой параметр команды.
    Data     - объектная нагрузка без передачи владения. }
  TRecorderActionContext = record
    Sender: TObject;
    Text: string;
    IntValue: Int64;
    Data: TObject;
  end;

  { Событийный обработчик выполнения действия }
  TRecorderActionExecuteEvent = procedure(ASender: TObject;
    const AContext: TRecorderActionContext) of object;

  { TRecorderAction
    Описание команды, которую может показать toolbar/menu/hotkey слой. }
  TRecorderAction = class
  private
    fCaption: string;                          { Заголовок действия для интерфейса }
    fEnabled: Boolean;                         { Флаг доступности действия }
    fHint: string;                             { Подсказка / всплывающее описание }
    fId: string;                               { Уникальный текстовый идентификатор }
    fOnExecute: TRecorderActionExecuteEvent;   { Обработчик выполнения }
    fOwner: TObject;                           { Владелец команды (например, плагин) }
  public
    { Создает action.
      AId        - стабильный id команды.
      ACaption   - человекочитаемая подпись для UI.
      AHint      - подсказка/описание.
      AOwner     - владелец команды, например extension. Владение не передается.
      AOnExecute - обработчик выполнения. }
    constructor Create(const AId, ACaption, AHint: string; AOwner: TObject;
      AOnExecute: TRecorderActionExecuteEvent);

    { Выполняет action или выбрасывает исключение, если action отключен или
      обработчик не назначен. }
    procedure Execute(const AContext: TRecorderActionContext);

    property Id: string read fId;
    property Caption: string read fCaption write fCaption;
    property Hint: string read fHint write fHint;
    property Owner: TObject read fOwner;
    property Enabled: Boolean read fEnabled write fEnabled;
    property OnExecute: TRecorderActionExecuteEvent read fOnExecute write fOnExecute;
  end;

  { TRecorderActionRegistry
    Реестр команд core-уровня. UI позже сможет построить toolbar на основании
    записей этого реестра, а плагины смогут регистрировать свои команды. }
  TRecorderActionRegistry = class
  private
    fActions: TStringList;                    { Список зарегистрированных действий, сортированный по Id }
    function GetAction(AIndex: Integer): TRecorderAction;
    function GetActionCount: Integer;
  public
    { Инициализирует реестр }
    constructor Create;
    { Очищает реестр, уничтожая все зарегистрированные действия }
    destructor Destroy; override;

    { Регистрирует action и принимает владение объектом }
    procedure RegisterAction(AAction: TRecorderAction);

    { Создает и регистрирует action одной командой }
    function AddAction(const AId, ACaption, AHint: string; AOwner: TObject;
      AOnExecute: TRecorderActionExecuteEvent): TRecorderAction;

    { Удаляет action по id. Возвращает True, если команда была найдена }
    function UnregisterAction(const AId: string): Boolean;

    { Ищет action по id. Возвращает nil, если команда не зарегистрирована }
    function FindAction(const AId: string): TRecorderAction;

    { Выполняет зарегистрированную команду }
    procedure ExecuteAction(const AId: string; const AContext: TRecorderActionContext);

    property ActionCount: Integer read GetActionCount;
    property Actions[AIndex: Integer]: TRecorderAction read GetAction;
  end;

  { Состояние расширения в менеджере }
  TRecorderExtensionState = (
    resCreated,       { Расширение создано }
    resInitialized,   { Пройдена инициализация }
    resRegistered,    { Сервисы и команды зарегистрированы }
    resStarted,       { Расширение запущено }
    resStopped,       { Расширение остановлено }
    resClosed         { Расширение закрыто и освобождено }
  );

  { Интерфейс статического расширения RecorderLnx.
    Это Object Pascal-аналог полезной части IRecorderPlugin: init/register/start/
    stop/notify/close. Внешние .dll/.so позже будут адаптироваться к этому
    интерфейсу через C ABI слой. }
  IRecorderExtension = interface
    ['{D1594B1B-E8BD-4F97-A15B-B53C63A1986B}']
    { Возвращает уникальный идентификатор расширения }
    function GetId: string;
    { Возвращает отображаемое имя расширения }
    function GetName: string;
    { Инициализация расширения с передачей главного хоста приложения }
    procedure Initialize(AHost: TObject);
    { Регистрация собственных событий и команд в реестрах ядра }
    procedure RegisterServices(AEventBus: TRecorderEventBus;
      AActionRegistry: TRecorderActionRegistry);
    { Запуск работы расширения }
    procedure Start;
    { Остановка работы расширения }
    procedure Stop;
    { Проверка возможности закрытия расширения }
    function CanClose: Boolean;
    { Освобождение ресурсов и закрытие расширения }
    procedure Close;
    { Метод обратного вызова при возникновении событий в шине ядра }
    procedure Notify(const AEvent: TRecorderEvent);
  end;

  { TRecorderExtensionManager
    Менеджер статических расширений. Хранит интерфейсы, вызывает общий lifecycle
    и подписывает расширения на события шины через метод Notify. }
  TRecorderExtensionManager = class
  private type
    { Контекст расширения для отслеживания его состояния }
    TExtensionContext = class
    public
      Extension: IRecorderExtension;   { Ссылка на интерфейс расширения }
      State: TRecorderExtensionState;   { Текущее состояние в жизненном цикле }
      EventToken: Integer;              { Токен подписки на события }
    end;
  private
    fActionRegistry: TRecorderActionRegistry; { Ссылка на реестр команд }
    fEventBus: TRecorderEventBus;            { Ссылка на шину событий }
    fExtensions: TList;                      { Список контекстов расширений TExtensionContext }
    fHost: TObject;                          { Ссылка на объект хоста }
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    function GetContext(AIndex: Integer): TExtensionContext;
    function GetExtension(AIndex: Integer): IRecorderExtension;
    function GetExtensionCount: Integer;
  public
    { AEventBus/AActionRegistry - общие сервисы core. Владение не передается. }
    constructor Create(AEventBus: TRecorderEventBus;
      AActionRegistry: TRecorderActionRegistry);
    { Деструктор закрывает и освобождает все расширения }
    destructor Destroy; override;

    { Добавляет extension в менеджер. Менеджер хранит interface reference. }
    procedure AddExtension(const AExtension: IRecorderExtension);

    { Вызывает Initialize для всех расширений. }
    procedure InitializeAll(AHost: TObject);

    { Вызывает RegisterServices для всех расширений и подписывает их на события. }
    procedure RegisterServicesAll;

    { Запускает все зарегистрированные расширения. }
    procedure StartAll;

    { Останавливает все запущенные расширения в обратном порядке. }
    procedure StopAll;

    { Проверяет, можно ли закрыть все расширения. }
    function CanCloseAll: Boolean;

    { Закрывает все расширения, предварительно отписывая их от событий. }
    procedure CloseAll;

    property ExtensionCount: Integer read GetExtensionCount;
    property Extensions[AIndex: Integer]: IRecorderExtension read GetExtension;
  end;

implementation

{ TRecorderEventBus }

constructor TRecorderEventBus.Create;
begin
  inherited Create;
  fSubscriptions := TList.Create;
  fNextToken := 1;
end;

destructor TRecorderEventBus.Destroy;
var
  I: Integer;
begin
  for I := 0 to fSubscriptions.Count - 1 do
    TObject(fSubscriptions[I]).Free;
  fSubscriptions.Free;
  inherited Destroy;
end;

function TRecorderEventBus.GetSubscription(AIndex: Integer): TSubscription;
begin
  Result := TSubscription(fSubscriptions[AIndex]);
end;

function TRecorderEventBus.Subscribe(AHandler: TRecorderEventHandler): Integer;
var
  lSubscription: TSubscription;
begin
  if not Assigned(AHandler) then
    raise ERecorderCoreServiceError.Create('Event handler cannot be empty');

  lSubscription := TSubscription.Create;
  lSubscription.Token := fNextToken;
  lSubscription.Handler := AHandler;
  Inc(fNextToken);
  fSubscriptions.Add(lSubscription);
  Result := lSubscription.Token;
end;

function TRecorderEventBus.Unsubscribe(AToken: Integer): Boolean;
var
  I: Integer;
  lSubscription: TSubscription;
begin
  Result := False;
  for I := 0 to fSubscriptions.Count - 1 do
  begin
    lSubscription := GetSubscription(I);
    if lSubscription.Token = AToken then
    begin
      fSubscriptions.Delete(I);
      lSubscription.Free;
      Exit(True);
    end;
  end;
end;

procedure TRecorderEventBus.Publish(const AEvent: TRecorderEvent);
var
  I: Integer;
  lSnapshot: TList;
  lSubscription: TSubscription;
begin
  lSnapshot := TList.Create;
  try
    for I := 0 to fSubscriptions.Count - 1 do
      lSnapshot.Add(fSubscriptions[I]);

    for I := 0 to lSnapshot.Count - 1 do
    begin
      lSubscription := TSubscription(lSnapshot[I]);
      if fSubscriptions.IndexOf(lSubscription) >= 0 then
        lSubscription.Handler(Self, AEvent);
    end;
  finally
    lSnapshot.Free;
  end;
end;

class function TRecorderEventBus.MakeEvent(AKind: TRecorderEventKind;
  ASource: TObject; const AName: string; const AText: string;
  AIntValue: Int64; AData: TObject): TRecorderEvent;
begin
  Result.Kind := AKind;
  Result.Source := ASource;
  Result.Name := AName;
  Result.Text := AText;
  Result.IntValue := AIntValue;
  Result.Data := AData;
end;

{ TRecorderAction }

constructor TRecorderAction.Create(const AId, ACaption, AHint: string;
  AOwner: TObject; AOnExecute: TRecorderActionExecuteEvent);
begin
  inherited Create;
  if AId = '' then
    raise ERecorderCoreServiceError.Create('Action id cannot be empty');

  fId := AId;
  fCaption := ACaption;
  fHint := AHint;
  fOwner := AOwner;
  fOnExecute := AOnExecute;
  fEnabled := True;
end;

procedure TRecorderAction.Execute(const AContext: TRecorderActionContext);
begin
  if not fEnabled then
    raise ERecorderCoreServiceError.CreateFmt('Action is disabled: %s', [fId]);
  if not Assigned(fOnExecute) then
    raise ERecorderCoreServiceError.CreateFmt('Action has no handler: %s', [fId]);

  fOnExecute(Self, AContext);
end;

{ TRecorderActionRegistry }

constructor TRecorderActionRegistry.Create;
begin
  inherited Create;
  fActions := TStringList.Create;
  fActions.CaseSensitive := False;
  fActions.Sorted := True;
  fActions.Duplicates := dupError;
end;

destructor TRecorderActionRegistry.Destroy;
var
  I: Integer;
begin
  for I := 0 to fActions.Count - 1 do
    fActions.Objects[I].Free;
  fActions.Free;
  inherited Destroy;
end;

function TRecorderActionRegistry.GetAction(AIndex: Integer): TRecorderAction;
begin
  Result := TRecorderAction(fActions.Objects[AIndex]);
end;

function TRecorderActionRegistry.GetActionCount: Integer;
begin
  Result := fActions.Count;
end;

procedure TRecorderActionRegistry.RegisterAction(AAction: TRecorderAction);
begin
  if AAction = nil then
    raise ERecorderCoreServiceError.Create('Action cannot be nil');
  if fActions.IndexOf(AAction.Id) >= 0 then
    raise ERecorderCoreServiceError.CreateFmt('Action already registered: %s',
      [AAction.Id]);

  fActions.AddObject(AAction.Id, AAction);
end;

function TRecorderActionRegistry.AddAction(const AId, ACaption, AHint: string;
  AOwner: TObject; AOnExecute: TRecorderActionExecuteEvent): TRecorderAction;
begin
  Result := TRecorderAction.Create(AId, ACaption, AHint, AOwner, AOnExecute);
  try
    RegisterAction(Result);
  except
    Result.Free;
    raise;
  end;
end;

function TRecorderActionRegistry.UnregisterAction(const AId: string): Boolean;
var
  lIndex: Integer;
  lAction: TRecorderAction;
begin
  lIndex := fActions.IndexOf(AId);
  Result := lIndex >= 0;
  if Result then
  begin
    lAction := TRecorderAction(fActions.Objects[lIndex]);
    fActions.Delete(lIndex);
    lAction.Free;
  end;
end;

function TRecorderActionRegistry.FindAction(const AId: string): TRecorderAction;
var
  lIndex: Integer;
begin
  lIndex := fActions.IndexOf(AId);
  if lIndex >= 0 then
    Result := TRecorderAction(fActions.Objects[lIndex])
  else
    Result := nil;
end;

procedure TRecorderActionRegistry.ExecuteAction(const AId: string;
  const AContext: TRecorderActionContext);
var
  lAction: TRecorderAction;
begin
  lAction := FindAction(AId);
  if lAction = nil then
    raise ERecorderCoreServiceError.CreateFmt('Action not found: %s', [AId]);

  lAction.Execute(AContext);
end;

{ TRecorderExtensionManager }

constructor TRecorderExtensionManager.Create(AEventBus: TRecorderEventBus;
  AActionRegistry: TRecorderActionRegistry);
begin
  inherited Create;
  if AEventBus = nil then
    raise ERecorderCoreServiceError.Create('Event bus cannot be nil');
  if AActionRegistry = nil then
    raise ERecorderCoreServiceError.Create('Action registry cannot be nil');

  fEventBus := AEventBus;
  fActionRegistry := AActionRegistry;
  fExtensions := TList.Create;
end;

destructor TRecorderExtensionManager.Destroy;
begin
  CloseAll;
  fExtensions.Free;
  inherited Destroy;
end;

procedure TRecorderExtensionManager.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
var
  I: Integer;
  lContext: TExtensionContext;
begin
  for I := 0 to fExtensions.Count - 1 do
  begin
    lContext := GetContext(I);
    if lContext.State <> resClosed then
      lContext.Extension.Notify(AEvent);
  end;
end;

function TRecorderExtensionManager.GetContext(AIndex: Integer): TExtensionContext;
begin
  Result := TExtensionContext(fExtensions[AIndex]);
end;

function TRecorderExtensionManager.GetExtension(AIndex: Integer): IRecorderExtension;
begin
  Result := GetContext(AIndex).Extension;
end;

function TRecorderExtensionManager.GetExtensionCount: Integer;
begin
  Result := fExtensions.Count;
end;

procedure TRecorderExtensionManager.AddExtension(
  const AExtension: IRecorderExtension);
var
  I: Integer;
  lContext: TExtensionContext;
begin
  if AExtension = nil then
    raise ERecorderCoreServiceError.Create('Extension cannot be nil');

  for I := 0 to fExtensions.Count - 1 do
    if SameText(GetContext(I).Extension.GetId, AExtension.GetId) then
      raise ERecorderCoreServiceError.CreateFmt('Extension already registered: %s',
        [AExtension.GetId]);

  lContext := TExtensionContext.Create;
  lContext.Extension := AExtension;
  lContext.State := resCreated;
  lContext.EventToken := 0;
  fExtensions.Add(lContext);
end;

procedure TRecorderExtensionManager.InitializeAll(AHost: TObject);
var
  I: Integer;
  lContext: TExtensionContext;
begin
  fHost := AHost;
  for I := 0 to fExtensions.Count - 1 do
  begin
    lContext := GetContext(I);
    if lContext.State = resCreated then
    begin
      lContext.Extension.Initialize(fHost);
      lContext.State := resInitialized;
    end;
  end;
end;

procedure TRecorderExtensionManager.RegisterServicesAll;
var
  I: Integer;
  lContext: TExtensionContext;
begin
  for I := 0 to fExtensions.Count - 1 do
  begin
    lContext := GetContext(I);
    if lContext.State = resCreated then
      lContext.Extension.Initialize(fHost);
    if lContext.State in [resCreated, resInitialized] then
    begin
      lContext.Extension.RegisterServices(fEventBus, fActionRegistry);
      lContext.State := resRegistered;
    end;
  end;

  if (fExtensions.Count > 0) and (GetContext(0).EventToken = 0) then
  begin
    for I := 0 to fExtensions.Count - 1 do
      GetContext(I).EventToken := -1;
    GetContext(0).EventToken := fEventBus.Subscribe(@HandleEvent);
  end;
end;

procedure TRecorderExtensionManager.StartAll;
var
  I: Integer;
  lContext: TExtensionContext;
begin
  for I := 0 to fExtensions.Count - 1 do
  begin
    lContext := GetContext(I);
    if lContext.State in [resRegistered, resStopped] then
    begin
      lContext.Extension.Start;
      lContext.State := resStarted;
    end;
  end;
end;

procedure TRecorderExtensionManager.StopAll;
var
  I: Integer;
  lContext: TExtensionContext;
begin
  for I := fExtensions.Count - 1 downto 0 do
  begin
    lContext := GetContext(I);
    if lContext.State = resStarted then
    begin
      lContext.Extension.Stop;
      lContext.State := resStopped;
    end;
  end;
end;

function TRecorderExtensionManager.CanCloseAll: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to fExtensions.Count - 1 do
    Result := Result and GetContext(I).Extension.CanClose;
end;

procedure TRecorderExtensionManager.CloseAll;
var
  I: Integer;
  lContext: TExtensionContext;
begin
  if fExtensions = nil then
    Exit;

  StopAll;

  if (fExtensions.Count > 0) and (GetContext(0).EventToken > 0) then
    fEventBus.Unsubscribe(GetContext(0).EventToken);

  for I := fExtensions.Count - 1 downto 0 do
  begin
    lContext := GetContext(I);
    if lContext.State <> resClosed then
    begin
      lContext.Extension.Close;
      lContext.State := resClosed;
    end;
    fExtensions.Delete(I);
    lContext.Free;
  end;
end;

end.
