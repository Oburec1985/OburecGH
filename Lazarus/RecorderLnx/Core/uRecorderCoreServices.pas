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
{$codepage UTF8}

interface

uses
  Classes, SysUtils, SyncObjs, uRecorderStateMachine;

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
        rceSpectrumFrame,        { Получен новый кадр спектра }
    rceUser                  { Пользовательское событие }
    , rceConfigurationPrepared,
    rceRunTransitionBefore,
    rceRunTransitionAfter,
    rceInitialized           { Проект загружен, формы и источники созданы, runtime подготовлен }
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
    Transition: TRecorderStateTransition;
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
      Active: Boolean;
      InFlight: Integer;
      DeferredFree: Boolean;
      Idle: TEvent;
      constructor Create;
      destructor Destroy; override;
    end;
  private
    fNextToken: Integer;              { Счетчик для генерации следующего токена }
    fSubscriptions: TList;            { Список активных подписок (TSubscription) }
    fLock: TRTLCriticalSection;
    fPublishers: Integer;
    fPublishersIdle: TEvent;
    fShuttingDown: Boolean;
    function BeginPublish: Boolean;
    procedure EndPublish;
    function FindSubscription(AToken: Integer): TSubscription;
    function GetSubscription(AIndex: Integer): TSubscription;
    function LeaseSubscription(AToken: Integer): TSubscription;
    procedure ReleaseSubscription(ASubscription: TSubscription);
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
      Снимок токенов фиксирует порядок: новая подписка получит следующее
      событие, а отписанная до своего хода уже не вызывается. Unsubscribe из
      другого потока возвращается после завершения уже идущего callback. }
    procedure Publish(const AEvent: TRecorderEvent);

    { Удобный конструктор события без объектной нагрузки }
    class function MakeEvent(AKind: TRecorderEventKind; ASource: TObject = nil;
      const AName: string = ''; const AText: string = '';
      AIntValue: Int64 = 0; AData: TObject = nil;
      ATransition: TRecorderStateTransition = rstNone): TRecorderEvent; static;
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
uses
  uRecorderDebugLog;

type
  PRecorderEventCallbackFrame = ^TRecorderEventCallbackFrame;
  TRecorderEventCallbackFrame = record
    Subscription: Pointer;
    Previous: PRecorderEventCallbackFrame;
  end;

threadvar
  gRecorderEventCallbackFrame: PRecorderEventCallbackFrame;

function CurrentThreadInvokes(ASubscription: Pointer): Boolean;
var
  lFrame: PRecorderEventCallbackFrame;
begin
  lFrame := gRecorderEventCallbackFrame;
  while lFrame <> nil do
  begin
    if lFrame^.Subscription = ASubscription then
      Exit(True);
    lFrame := lFrame^.Previous;
  end;
  Result := False;
end;

{ TRecorderEventBus }

constructor TRecorderEventBus.TSubscription.Create;
begin
  inherited Create;
  Active := True;
  Idle := TEvent.Create(nil, True, True, '');
end;

destructor TRecorderEventBus.TSubscription.Destroy;
begin
  Idle.Free;
  inherited Destroy;
end;

constructor TRecorderEventBus.Create;
begin
  inherited Create;
  fSubscriptions := TList.Create;
  fPublishersIdle := TEvent.Create(nil, True, True, '');
  fNextToken := 1;
  InitCriticalSection(fLock);
end;

destructor TRecorderEventBus.Destroy;
var
  I: Integer;
  lSubscriptions: TList;
begin
  lSubscriptions := TList.Create;
  EnterCriticalSection(fLock);
  try
    fShuttingDown := True;
    for I := 0 to fSubscriptions.Count - 1 do
    begin
      GetSubscription(I).Active := False;
      lSubscriptions.Add(fSubscriptions[I]);
    end;
    fSubscriptions.Clear;
  finally
    LeaveCriticalSection(fLock);
  end;

  { Publishers release subscription leases before their bus-level lease. This
    lets shutdown reclaim handlers first, then the list and critical section. }
  for I := 0 to lSubscriptions.Count - 1 do
  begin
    TSubscription(lSubscriptions[I]).Idle.WaitFor(INFINITE);
    { Pair with ReleaseSubscription: the event may wake before that method has
      left the bus lock, so cross the same lock before reclaiming its object. }
    EnterCriticalSection(fLock);
    LeaveCriticalSection(fLock);
    TObject(lSubscriptions[I]).Free;
  end;
  lSubscriptions.Free;
  fPublishersIdle.WaitFor(INFINITE);
  fSubscriptions.Free;
  fPublishersIdle.Free;
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderEventBus.BeginPublish: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := not fShuttingDown;
    if Result then
    begin
      if fPublishers = 0 then
        fPublishersIdle.ResetEvent;
      Inc(fPublishers);
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderEventBus.EndPublish;
begin
  EnterCriticalSection(fLock);
  try
    Dec(fPublishers);
    if fPublishers = 0 then
      fPublishersIdle.SetEvent;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderEventBus.GetSubscription(AIndex: Integer): TSubscription;
begin
  Result := TSubscription(fSubscriptions[AIndex]);
end;

function TRecorderEventBus.FindSubscription(AToken: Integer): TSubscription;
var
  I: Integer;
begin
  for I := 0 to fSubscriptions.Count - 1 do
    if GetSubscription(I).Token = AToken then
      Exit(GetSubscription(I));
  Result := nil;
end;

function TRecorderEventBus.LeaseSubscription(
  AToken: Integer): TSubscription;
begin
  Result := nil;
  EnterCriticalSection(fLock);
  try
    Result := FindSubscription(AToken);
    if (Result = nil) or not Result.Active then
      Exit(nil);
    if Result.InFlight = 0 then
      Result.Idle.ResetEvent;
    Inc(Result.InFlight);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderEventBus.ReleaseSubscription(
  ASubscription: TSubscription);
var
  lFree: Boolean;
begin
  lFree := False;
  EnterCriticalSection(fLock);
  try
    Dec(ASubscription.InFlight);
    if ASubscription.InFlight = 0 then
    begin
      ASubscription.Idle.SetEvent;
      lFree := ASubscription.DeferredFree;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
  if lFree then
    ASubscription.Free;
end;

function TRecorderEventBus.Subscribe(AHandler: TRecorderEventHandler): Integer;
var
  lSubscription: TSubscription;
begin
  if not Assigned(AHandler) then
    raise ERecorderCoreServiceError.Create('Event handler cannot be empty');

  lSubscription := TSubscription.Create;
  lSubscription.Handler := AHandler;
  EnterCriticalSection(fLock);
  try
    lSubscription.Token := fNextToken;
    Inc(fNextToken);
    fSubscriptions.Add(lSubscription);
  finally
    LeaveCriticalSection(fLock);
  end;
  Result := lSubscription.Token;
end;

function TRecorderEventBus.Unsubscribe(AToken: Integer): Boolean;
var
  lSubscription: TSubscription;
  lWait: Boolean;
begin
  Result := False;
  lSubscription := nil;
  lWait := False;
  EnterCriticalSection(fLock);
  try
    lSubscription := FindSubscription(AToken);
    if lSubscription <> nil then
    begin
      lSubscription.Active := False;
      fSubscriptions.Remove(lSubscription);
      Result := True;
      if lSubscription.InFlight = 0 then
        lWait := False
      else if CurrentThreadInvokes(lSubscription) then
      begin
        { Waiting for a callback already on this thread would deadlock. Its
          final ReleaseSubscription owns deferred reclamation instead. }
        lSubscription.DeferredFree := True;
        lSubscription := nil;
      end
      else
        lWait := True;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
  if lSubscription <> nil then
  begin
    if lWait then
    begin
      lSubscription.Idle.WaitFor(INFINITE);
      EnterCriticalSection(fLock);
      LeaveCriticalSection(fLock);
    end;
    lSubscription.Free;
  end;
end;

procedure TRecorderEventBus.Publish(const AEvent: TRecorderEvent);
var
  I: Integer;
  lSnapshot: TList;
  lSubscription: TSubscription;
  lFrame: TRecorderEventCallbackFrame;
  lStart: QWord;
begin
  if not BeginPublish then
    Exit;
  lStart := GetTickCount64;
  lSnapshot := TList.Create;
  try
    EnterCriticalSection(fLock);
    try
      for I := 0 to fSubscriptions.Count - 1 do
        lSnapshot.Add(Pointer(PtrInt(GetSubscription(I).Token)));
    finally
      LeaveCriticalSection(fLock);
    end;

    for I := 0 to lSnapshot.Count - 1 do
    begin
      lSubscription := LeaseSubscription(PtrInt(lSnapshot[I]));
      if lSubscription = nil then
        Continue;
      lFrame.Subscription := lSubscription;
      lFrame.Previous := gRecorderEventCallbackFrame;
      gRecorderEventCallbackFrame := @lFrame;
      try
        lSubscription.Handler(Self, AEvent);
      finally
        gRecorderEventCallbackFrame := lFrame.Previous;
        ReleaseSubscription(lSubscription);
      end;
    end;
  finally
    lSnapshot.Free;
    EndPublish;
  end;
  if GetTickCount64 - lStart > 5 then
    { Streaming debug: EventBus timing suppressed.
    RecorderDebugLog(Format('[EventBus] Publish: Kind=%d, Time=%d ms, ThreadID=%d',
      [Ord(AEvent.Kind), GetTickCount64 - lStart, PtrUInt(GetThreadID)])); }
end;

class function TRecorderEventBus.MakeEvent(AKind: TRecorderEventKind;
  ASource: TObject; const AName: string; const AText: string;
  AIntValue: Int64; AData: TObject;
  ATransition: TRecorderStateTransition): TRecorderEvent;
begin
  Result.Kind := AKind;
  Result.Source := ASource;
  Result.Name := AName;
  Result.Text := AText;
  Result.IntValue := AIntValue;
  Result.Data := AData;
  Result.Transition := ATransition;
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

procedure TRecorderExtensionManager.HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
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
