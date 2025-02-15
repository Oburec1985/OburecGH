{ --------------------------------------------------------------------- }
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль класса тестового plug-in`а, описание и реализация }
{ Компилятор: Rad Studio 2010 }
{ НПП "ООО Мера" 2016г. }
{ --------------------------------------------------------------------- }

unit PluginClass;

interface

uses
  Windows,
  recorder,
  tags,
  plugin,
  ActiveX,
  SysUtils,
  Forms,
  uFrmSync,
  journal,
  SyncObjs,
  Classes,
  ExtCtrls,
  blaccess,
  ulogfile,
  uCompMng,
  uEventList,
  uRecorderEvents,
  dialogs,
  variants,
  uRCFunc,
  uRecBasicFactory,
  cfreg;

type

  TRCstateChange = (RSt_Init, RSt_StopToView, RSt_StopToRec, RSt_ViewToStop,
    RSt_ViewToRec, RSt_RecToStop, RSt_RecToView, RSt_initToStop,
    RSt_initToView, RSt_initToRec);

  DynTagsArray = array of ITag;

  cNotifyProcessorList = class;

  cNonifyProcessor = class
  protected
    // ссылка на cNotifyProcessorList
    list: cNotifyProcessorList;
    fname: string;
  protected
    procedure setName(s: string);
    // событие происходит при присвоении cNotifyProcessorList
    procedure doAddParentList; virtual;
    procedure doSave(path: string); virtual;
    procedure doLoad(path: string); virtual;
    procedure doLeaveCfg; virtual;
    // когда все плагины уже загружены и конфиг тоже
    procedure doRCInit; virtual;
  public
    function ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;
      virtual;
    // function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;virtual;
    function ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean; virtual;
    property name: string read fname write setName;
  end;

  cNotifyProcessorList = class(TStringList)
  public
    function GetNP(i: integer): cNonifyProcessor; overload;
    function GetNP(str: string): cNonifyProcessor; overload;
    Procedure AddNP(np: cNonifyProcessor);
    procedure DelNP(i: integer); overload;
    procedure DelNP(str: string); overload;
    procedure CallAllProcessNotify(a_dwCommand: dword; a_dwData: dword);
    destructor destroy;
    constructor Create;
  end;

  // автосоздание методов ctrl+shift+C
  { Класс тестового plug-in`а. Наследует классу TInterfacedObject,
    при этом наследуется реализация IUnknown и механизм подсчета
    ссылок соответсвенно. Класс реализует интерфейс IRecorderPlugin -
    интерфейс plug-in`а. Для отображения данных класс использует
    специальную форму}
  TExtRecorderPack = class(TInterfacedObject, IRecorderPlugin)
  public
    // для прореживания LeaveConfig событий
    m_loadState,
    // взводится при leavecfg
    m_leavecfgNotify:boolean;
    delplg: boolean;
    // Загружен конфиг при стартовой загрузке рекордера
    // сделано для анализа произошло событие SwitchOnUI до загрузки или после
    m_loadDefCfg: boolean;
    FIRecorder: IRecorder;
    // регистратор фабрик компонентов
    m_CompMng: cCompMng;
    // форма для организации очереди сообщений
    m_FrmSync: TFrmSync;
    beforestop:boolean;
  protected
    m_rstate: dword;
    m_UIThreadID: integer;

    m_journal: IJournal;

    // Фабрика классов компонентов
    // m_ExtensionFactory,
    // m_GLFactory:ICustomFormFactory;

    // кнопка управления на странице настройки тегов
    m_BtnTagPropPageID: ULONG;
    // Кнопка на главном тулбаре формуляров
    m_PictBtnMainFramePtr: ipicture; // картинка
    m_btnMainFrameID: ULONG;
    fConfigName: string;
  public
    EList: cEventList;
    m_nplist: cNotifyProcessorList;
  public
    { Конструктор }
    constructor Create;
    destructor destroy; override;
    procedure destroyLog;
  public
    function CreateGUI: integer;
    function DestroyGUI: integer;
  protected
    { Деструктор }
    function _AddRef: integer; stdcall;
    function _release: integer; stdcall;
    procedure GetJournal;
    procedure doStart;
    // destructor Destroy; override;
  public // IRecorderPlugin
    procedure destroyForms;
    // вызвать функцию ShowModal в MainThread
    procedure ShowModalForm(frm: tform);
    function ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;
    // Создание плагина
    function _Create(pOwner: IRecorder): boolean; stdcall;
    // Конфигурирование
    function Config: boolean; stdcall;
    // Вызов окна настройки
    function Edit: boolean; stdcall;
    // Запуск - активизация работы plug-in`а
    function Execute: boolean; stdcall;
    // Приостановка работы
    function Suspend: boolean; stdcall;
    // Возобновление работы
    function Resume: boolean; stdcall;
    // Уведомление о внешних событиях
    function Notify(const dwCommand: dword; const dwData: dword): boolean; stdcall;
    // Получение имени
    function GetName: LPCSTR; stdcall;
    // Получить свойство
    function GetProperty(const dwPropertyID: dword;
      var Value: OleVariant): boolean; stdcall;
    // Задать свойство
    function SetProperty(const dwPropertyID: dword;
      Value: OleVariant): boolean; stdcall;
    // Узнать можно ли завершить работу плагина
    function CanClose: boolean; stdcall;
    // Завершить работу плагина
    function Close: boolean; stdcall;
  // MBaseControl собственные интерфейсы плагина
  //
  private
    function getConfigName: string;
    procedure setConfigName(const Value: string);
    procedure LoadConfName;
    procedure doChangeRCState(Sender: TObject);
  public
    { Метод запуска и останова измерения }
    function StartMeasure: boolean;
    function StopMeasure: boolean;
    property ConfigName: string read getConfigName write setConfigName;
  protected
  end;

function RStatePlay: boolean;
  // получить ссылку на транслятор сообщений notifyProcessor
function GetNP(name: string): cNonifyProcessor;
procedure AddPlgEvent(ename: string; etype: cardinal; e: tNotifyEvent);
procedure RemovePlgEvent(e: tNotifyEvent; etype: cardinal);
procedure CallPlgEvents(etype: cardinal); overload;
procedure CallPlgEvents(etype: cardinal; Sender: TObject); overload;
function GetRCStateChange: TRCstateChange;
procedure logMessage(str: string);
procedure LogRecorderMessage(str: string; log:boolean);


var
  { В библиотеке создается всего один глобальный экземпляр plug-in`а,
    и соответсвенно есть переменная ссылка на интерфейс этого plug-in`а.
    Экземпляр plug-in`а создается по загрузке библиотеки, и должен удаляться,
    когда счетчик ссылок станет равен нулю, это должно происходить перед
    выгрузкой библиотеки (если подсчет ссылок организоан правильно). }
  GPluginInstance: IRecorderPlugin = nil;
  // каталог Recorder-а
  g_startdir: string;
  // взводится после создания интерфейса пользователя
  g_createGUI: boolean = false;
  // взводится если произошло событие загрузки при  запуске рекордера.
  // по идее интерфейс можно инициализировать только после завершения загрузки движка
  g_LoadEngine: boolean = false;
  rcStateChange: TRCstateChange;


const
  c_TagProp_nullpoly = 'nullpoly';
  c_Log_PlgClass = false;
  RS_Before_STOP = RS_STOP+RS_VIEW;

implementation

uses
  uCreateComponents;

function RStatePlay: boolean;
begin
  // result:=TExtRecorderPack(GPluginInstance).FIRecorder.CheckState(RS_VIEW or RS_REC);
  result := not g_IR.CheckState(RS_stop);
  if TExtRecorderPack(GPluginInstance).beforestop then
    result := false;
end;



procedure logMessage(str: string);
begin
  if g_logFile <> nil then
    g_logFile.addInfoMes(str);
end;


function GetNP(name: string): cNonifyProcessor;
begin
  result := TExtRecorderPack(GPluginInstance).m_nplist.GetNP(name);
end;

function GetRCStateChange: TRCstateChange;
begin
  result := rcStateChange;
end;

procedure AddPlgEvent(ename: string; etype: cardinal; e: tNotifyEvent);
begin
  TExtRecorderPack(GPluginInstance).EList.AddEvent(ename, etype, e);
end;

procedure CallPlgEvents(etype: cardinal);
begin
  TExtRecorderPack(GPluginInstance).EList.CallAllEvents(etype);
end;

procedure CallPlgEvents(etype: cardinal; Sender: TObject);
begin
  TExtRecorderPack(GPluginInstance).EList.CallAllEventsWithSender(etype,
    Sender);
end;

procedure RemovePlgEvent(e: tNotifyEvent; etype: cardinal);
begin
  TExtRecorderPack(GPluginInstance).EList.removeEvent(e, etype);
end;

procedure cNonifyProcessor.setName(s: string);
var
  i: integer;
begin
  if list <> nil then
  begin
    if list.Find(fname, i) then
    begin
      list.Delete(i);
    end;
    list.AddObject(s, self);
  end;
  fname := s;
end;

procedure cNonifyProcessor.doAddParentList;
begin

end;

procedure cNonifyProcessor.doLeaveCfg;
begin

end;

procedure cNonifyProcessor.doLoad(path: string);
begin

end;

procedure cNonifyProcessor.doRCInit;
begin
  RecorderInit;
end;

procedure cNonifyProcessor.doSave(path: string);
begin

end;

function cNonifyProcessor.ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean;
begin

end;

function cNonifyProcessor.ProcessNotify(a_dwCommand: dword;
  a_dwData: dword): boolean;
var
  pMsgInfo: PCB_MESSAGE;
  path: string;
  b:boolean;
begin
  case a_dwCommand of
    PN_SHOWINFO:
    begin
      pMsgInfo := pointer(a_dwData);
    end;
    PN_LEAVERCCONFIG:
    begin
      if TExtRecorderPack(G_Plg).m_loadState then
      begin

      end
      else
        doLeaveCfg;
    end;
    PN_RCLOADCONFIG:
    begin
      path := getRConfig;
      doLoad(path);
    end;
    PN_RCINITIALIZED:
      begin
        doRCInit;
      end;
    PN_RCSAVECONFIG:
      begin
        path := getRConfig;
        doSave(path);
      end;
    PN_CUSTOM_BUTTON_CLICK:
      begin
        if a_dwData = 0 then
        begin

        end
        else
        begin
          pMsgInfo := pointer(a_dwData);
          ProcessBtnClick(pMsgInfo);
        end;
      end;
  end;
end;

function cNotifyProcessorList.GetNP(i: integer): cNonifyProcessor;
begin
  result := NIL;
  if i < count then
    result := cNonifyProcessor(objects[i]);
end;

function cNotifyProcessorList.GetNP(str: string): cNonifyProcessor;
var
  i: integer;
begin
  result := nil;
  if Find(str, i) then
    result := cNonifyProcessor(objects[i]);
end;

procedure cNotifyProcessorList.CallAllProcessNotify(a_dwCommand: dword;
  a_dwData: dword);
var
  i: integer;
  np: cNonifyProcessor;
  b, b1:boolean;
begin
  b:=false;
  b1:=(a_dwCommand=PN_RCLOADCONFIG);
  if b1 then
  begin
    TExtRecorderPack(G_Plg).m_loadState:=true;
    ecm(b);
  end;
  for i := 0 to count - 1 do
  begin
    np := GetNP(i);
    np.ProcessNotify(a_dwCommand, a_dwData);
  end;
  if b1 then
  begin
    TExtRecorderPack(G_Plg).m_loadState:=false;
    if b then
      lcm;
  end;
end;

Procedure cNotifyProcessorList.AddNP(np: cNonifyProcessor);
begin
  np.list := self;
  if np.name = '' then
  begin
    np.name := np.ClassName;
  end;
  AddObject(np.name, np);
  np.doAddParentList;
end;

procedure cNotifyProcessorList.DelNP(i: integer);
var
  np: cNonifyProcessor;
begin
  np := cNonifyProcessor(objects[i]);
  np.destroy;
  Delete(i);
end;

procedure cNotifyProcessorList.DelNP(str: string);
var
  i: integer;
begin
  if Find(str, i) then
    DelNP(i);
end;

destructor cNotifyProcessorList.destroy;
var
  np: cNonifyProcessor;
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    np := cNonifyProcessor(objects[i]);
    np.destroy;
  end;
  clear;
  inherited;
end;

constructor cNotifyProcessorList.Create;
begin
  sorted := true;
  inherited;
end;

procedure TExtRecorderPack.destroyLog;
begin
  if g_logFile<>nil then
  begin
    g_logFile.destroy;
    g_logFile := nil;
  end;
end;

procedure TExtRecorderPack.doChangeRCState(Sender: TObject);
var
  newstate, statechange: dword;
begin
  if beforestop then
  begin
    newstate:=rs_stop; // костыль на предустановку для распознования что это равно стоп
    //newstate := c_RS_Before_STOP;
  end
  else
    newstate := RState;
  case m_rstate of
    RS_STOP:
      begin
        case newstate of
          RS_VIEW:
          begin
            rcStateChange := RSt_StopToView;
            doStart;
          end;
          RS_REC:
          begin
            g_merafile:=GetMeraFile;
            rcStateChange := RSt_StopToRec;
            doStart;
          end;
        end;
      end;
    RS_VIEW:
      begin
        case newstate of
          RS_VIEW:
            rcStateChange := RSt_ViewToStop;
          RS_REC:
          begin
            rcStateChange := RSt_ViewToRec;
            doStart;
            g_merafile:=GetMeraFile;
          end;
          RS_STOP:
            rcStateChange := RSt_ViewToStop;
        end;
      end;
    RS_REC:
      begin
        case newstate of
          RS_VIEW:
          begin
            rcStateChange := RSt_RecToView;
            doStart;
          end;
          RS_STOP:
            rcStateChange := RSt_RecToStop;
        end;
      end;
    0:
      begin
        case newstate of
          RS_VIEW:
          begin
            rcStateChange := RSt_initToView;
            doStart;
          end;
          RS_STOP:
            rcStateChange := RSt_initToStop;
          RS_REC:
          begin
            g_merafile:=GetMeraFile;
            rcStateChange := RSt_initToRec;
            doStart;
          end;
        end;
      end;
  end;
  if newstate <> m_rstate then
  begin
    m_rstate := newstate;
    EList.CallAllEvents(c_RC_DoChangeRCState);
  end;
end;

procedure TExtRecorderPack.doStart;
var
  i:integer;
  f:cRecBasicFactory;
begin
  for I := 0 to m_CompMng.Count - 1 do
  begin
    f:=cRecBasicFactory(m_CompMng.Objects[i]);
    f.doStart;
  end;
end;

procedure LogRecorderMessage(str: string; log:boolean);
begin
  if not log then exit;
  // m_journal.AddEvent(pwidechar(str[1]), 0, 1, 0);
  if g_logFile <> nil then
    g_logFile.addInfoMes(str);
end;

// system32 путь
function GetSystemDir:string;
begin
 SetLength(Result,256);
 SetLength(Result,GetSystemDirectory(PChar(Result),256));
end;

{ Конструктор } { Создание формы тестового plug-in`а }
constructor TExtRecorderPack.Create;
begin
  m_loadState:=false;
  g_startdir := extractfiledir(Application.ExeName) + '\plugins\';
  g_startdir := ExtractFileDrive(GetSystemDir)+'\Mera files\Recorder\plugins\';
  if not DirectoryExists(g_startdir) then
    ForceDirectories(g_startdir);
  EList := cEventList.Create(nil, true);
  m_nplist := cNotifyProcessorList.Create;
end;

destructor TExtRecorderPack.destroy;
begin
  exit;
  g_startdir := '';
  EList.destroy;
  EList := nil;
  m_nplist.destroy;
  m_nplist := nil;
  FIRecorder := nil;
  inherited;
end;

function TExtRecorderPack.CreateGUI: integer;
var
  // UISrv: tagVARIANT;
  val: OleVariant;
  // f:icustomformFactory;
begin
  m_UIThreadID:=GetCurrentThreadId;

  FIRecorder.GetProperty(RCPROP_CONFIGNAME, val);
  fConfigName := ExtractFileName(val);

  SendMessage(m_FrmSync.Handle, WM_CreateFrms, 0, 0);
  result := 0;
end;

function TExtRecorderPack.ProcessNotify(a_dwCommand: dword;
  a_dwData: dword): boolean;
var
  pMsgInfo: PCB_MESSAGE;
  I: Integer;
  b:boolean;
begin
  result := false;
  b:=a_dwCommand=PN_LEAVERCCONFIG;
  if b then
  begin
    m_leavecfgNotify:=true;
  end;
  m_nplist.CallAllProcessNotify(a_dwCommand, a_dwData);
  LogRecorderMessage('Enter_'+TranslateNotifyToStr(a_dwCommand), c_Log_PlgClass);
  case a_dwCommand of
    PN_RCLOADCONFIG:
    begin
      m_loadState:=true;
      for I := 0 to m_CompMng.Count - 1 do
      begin
        m_CompMng.doafterload;
      end;
      CallPlgEvents(c_RC_LoadCfg);
      m_loadState:=false;
    end;
    PN_RCSAVECONFIG:
    begin
      CallPlgEvents(c_RC_SaveCfg);
    end;
    PN_SHOWINFO:
    begin
      pMsgInfo := pointer(a_dwData);
    end;
    PN_CUSTOM_BUTTON_CLICK:
    begin
      if a_dwData = 0 then
      begin

      end
      else
      begin
        pMsgInfo := pointer(a_dwData);
        if pMsgInfo.uID = m_btnMainFrameID then
        begin

        end
        else
        begin

        end;
      end;
    end;
  end;
  if b then
  begin
    m_leavecfgNotify:=false;
  end;
  LogRecorderMessage('Exit_'+TranslateNotifyToStr(a_dwCommand), c_Log_PlgClass);
end;

// вызов из
// function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
procedure TExtRecorderPack.destroyForms;
begin
{$ifdef DEBUG}
  if m_FrmSync <> nil then
  begin
    ///if m_FrmSync.createThreadId = GetCurrentThreadId then
    begin
      try
        //m_FrmSync.Free;
        //m_FrmSync := nil;
      except
        g_logFile.addErrorMes('FrmSync - не удалось удалить');
      end;
    end;
    ///else
    begin
    ///  g_logFile.addErrorMes('FrmSync пытается удалиться в другом потоке нежели был создан');
    end;
  end;
{$endif}
end;

procedure TExtRecorderPack.ShowModalForm(frm: tform);
begin
  PostMessage(m_FrmSync.Handle, WM_ShowModalSettingsFrm, integer(frm), 0);
end;

function TExtRecorderPack.DestroyGUI: integer;
begin
  delplg := true;


  // m_pProcessFormPtr.reset(nil);
  // Удаляем кнопки со страниц
  if m_CompMng.m_BtnMainFrame <> nil then
  begin
    if m_btnMainFrameID <> 0 then
    begin
      m_CompMng.m_BtnMainFrame.RemoveButton(m_btnMainFrameID);
      m_btnMainFrameID := 0;
    end;
  end;
  if m_CompMng.m_BtnTagPropPage <> nil then
  begin
    if m_BtnTagPropPageID <> 0 then
    begin
      m_CompMng.m_BtnTagPropPage.RemoveButton(m_BtnTagPropPageID);
      m_BtnTagPropPageID := 0;
    end;
  end;
  m_CompMng.destroy;
  m_CompMng := nil;

  result := 0;
end;

procedure TExtRecorderPack.GetJournal;
var
  val: OleVariant;
  tV: tagVariant;
  rep: integer;
  str: widestring;
begin
  str := '';
  val := str;
  rep := FIRecorder.GetProperty(RCPROP_USER_LOG, val);
  if not failed(rep) then
  begin
    tV := tagVariant(val);
    rep := iunknown(tV.pUnkVal).QueryInterface(CLSID_Journal, m_journal);
  end;
end;

procedure TExtRecorderPack.LoadConfName;
var
  val: OleVariant;
  Ext: string;
  p: integer;
begin
  fConfigName := ExtractFileName(getConfigName);
  Ext := ExtractFileExt(fConfigName);
  p := Pos(Ext, fConfigName);
  Delete(fConfigName, p, length(fConfigName) - p + 1);
end;

function getConfigName: string;
var
  val: OleVariant;
begin
  TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_CONFIGNAME,
    val);
  result := val;
end;

// IRecorderPlugin
// Создание (инициализации внутренних полей) плагина
// происходит автоматично самим рекордером
function TExtRecorderPack._AddRef: integer;
begin
  inherited;
end;

function TExtRecorderPack._release: integer;
begin
  inherited;
end;


function TExtRecorderPack._Create(pOwner: IRecorder): boolean; stdcall;
var
  cfg: string;
begin
  delplg := false;
  FIRecorder := pOwner; // сохранение полученной ссылки на интерфейс Recorder`а
  GlobInit(GPluginInstance, FIRecorder);

  // GetJournal;
  m_CompMng := cCompMng.Create(FIRecorder);

  m_FrmSync := TFrmSync.Create(nil);
  m_FrmSync.createThreadId := GetCurrentThreadId;
  m_FrmSync.Show;
  m_FrmSync.Close;
  m_FrmSync.HandleNeeded;

  createComponents(m_CompMng);
  // LoadConfName;
  result := true; // завершено успешно

end;


// Конфигурирование
function TExtRecorderPack.Config: boolean; stdcall;
begin
  { тестовому plug-in`у нечего настраивать }
  result := true; // завершено успешно
end;

// Вызов окна настройки
function TExtRecorderPack.Edit: boolean; stdcall;
begin
  // frmTestSettings.Show; {Тестовый plug-in имеет всего одно окно}
  result := true; // завершено успешно
  EList.CallAllEvents(c_RC_PlgEdit);
end;

// Запуск - активизация работы plug-in`а
function TExtRecorderPack.Execute: boolean; stdcall;
begin
  // frmTestSettings.Show;    // отображение формы
  result := true; // завершено успешно
end;

function TExtRecorderPack.getConfigName: string;
begin
  result := fConfigName;
end;

// Приостановка работы
function TExtRecorderPack.Suspend: boolean; stdcall;
begin
  result := true; // завершено успешно
end;

// Возобновление работы
function TExtRecorderPack.Resume: boolean; stdcall;
begin
  result := true; // завершено успешно
end;

procedure TExtRecorderPack.setConfigName(const Value: string);
begin
  fConfigName := Value;
end;

// Уведомление о внешних событиях
function TExtRecorderPack.Notify(const dwCommand: dword;
  const dwData: dword): boolean; stdcall;
var
  fact: cRecBasicFactory;
  tags: DynTagsArray;
  I: Integer;
begin
  result := ProcessNotify(dwCommand, dwData);
  case dwCommand of
    PN_RCLOADCONFIG:
      begin
        m_loadDefCfg := true;
      end;
    PN_ON_SWITCH_TO_UI_THREAD:
      begin
        result := (CreateGUI = 0);

        createFormsRecorderUIThread(m_CompMng);
        g_createGUI := true;
      end;
    PN_ON_DESTROY_UI_SRV:
      begin
        result := (DestroyGUI = 0);
        destroyForms;
        destroyFormsRecorderUIThread(m_CompMng);
      end;
    PN_ENTERRCCONFIG:
      begin
        // Рекордер перешел в режим настройки
        // В то время пока производится изменение настройки,
        // теги недоступны (потому, что они могут удаляться)
        // сообщить фрме о начале изменения настройки
        // frmTestSettings.BeginConfigure;
        result := true;
      end;
    PN_LEAVERCCONFIG:
      begin
        // Оповестить форму о завершении изменения конфигурации и
        // передать ей новый список ссылок на интерфейсы тегов
        // frmTestSettings.EndConfigure(Tags);
        result := true;
        if m_loadState then
        BEGIN

        END
        ELSE
          CallPlgEvents(c_RC_LeaveCfg);
      end;
    PN_RCSTOP:
      begin
        beforestop:=false;
        // frmTestSettings.Started := false;
        //EList.CallAllEvents(c_RC_ChangeState);
        doChangeRCState(self);
        result := true;
      end;
    PN_BEFORE_RCSTOP:
      begin
        // frmTestSettings.Started := false;
        //EList.CallAllEvents(c_RC_ChangeState);
        beforestop:=true;
        doChangeRCState(self);
        result := true;
      end;
    PN_RCSTART:
      begin
        beforestop:=false;
        // frmTestSettings.Started := true;
        doChangeRCState(self);
        result := true;
      end;
    PN_SYNCHRO_READ_DATA_BLOCK:
      begin
        EList.CallAllEvents(c_RC_SynchroRead);
      end;
    PN_RCINITIALIZED:
    begin
      for I := 0 to m_CompMng.Count - 1 do
      begin
        fact:=cRecBasicFactory(m_CompMng.Objects[i]);
        fact.doRecorderInit;
      end;
      EList.CallAllEvents(E_RC_Init);
    end;
    PN_UPDATEDATA:
      begin
        for I := 0 to m_CompMng.Count - 1 do
        begin
          fact:=cRecBasicFactory(m_CompMng.Objects[i]);
          fact.doUpdateData;
        end;
        // frmTestSettings.RecorderGotData;
        EList.CallAllEvents(c_RUpdateData);
        result := true;
      end
    else
    begin
      if (m_FrmSync <> nil) then
      begin
        if dwCommand <> PN_RCSAVECONFIG then
        begin
          result := SendMessage(m_FrmSync.Handle, WM_PROCNOTIFY, dwCommand,
            dwData) = 0;
        end;
      end;
    end;
  end;
  result := false; // прочие сообщения не обрабатываем
end;

// Получение имени
function TExtRecorderPack.GetName: LPCSTR; stdcall;
begin
  result := LPCSTR(GPluginInfo.Name);
  { Из глобальной структуры описания plug-in`а }
end;

// Получить свойство
function TExtRecorderPack.GetProperty(const dwPropertyID: dword;
  var Value: OleVariant): boolean; stdcall;
begin
  case dwPropertyID of
    PLGPROP_INFOSTRING:
      begin { Получить строку описания plug-in`а }
        Value := GPluginInfo.Dsc; { Из глобальной структуры описания plug-in`а }
        result := true;
      end;
  else
    result := false;
  end;
end;

// Задать свойство
function TExtRecorderPack.SetProperty(const dwPropertyID: dword;
  { const } Value: OleVariant): boolean; stdcall;
begin
  result := false; { Свойств нет и устанавливать нечего }
end;

// Узнать можно ли завершить работу плагина
function TExtRecorderPack.CanClose: boolean; stdcall;
begin
  // всегда можно закрыть plug-in
  result := true;
end;

// Завершить работу плагина
function TExtRecorderPack.Close: boolean; stdcall;
begin
  // FreeAndNil(frmTestSettings);
  destroyEngine;
  result := true;
end;

{ Методы запуска и останова измерения }
function TExtRecorderPack.StartMeasure: boolean;
begin
  { Для запуска необходимо передать сообщение Recorder`у }
  result := FIRecorder.Notify(RCN_VIEW, 0);
end;

function TExtRecorderPack.StopMeasure: boolean;
begin
  { Для останова необходимо передать сообщение Recorder`у }
  result := FIRecorder.Notify(RCN_STOP, 0);
end;


end.
