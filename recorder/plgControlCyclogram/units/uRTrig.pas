unit uRTrig;

interface

uses
  classes, windows, uEventList, uBaseObj, nativexml, uVTServices, VirtualTrees,
  recorder, tags, uBaseObjService, uRCFunc, uMeasureBase, ucommonmath, sysutils,
  uAlarms;

type
  TBoolOper = (boAnd, boOr);

  TTrigType = (trFront, trFall, trHiLvl, trLoLvl, trEqv, trPause, trAlarms,
               trStart, trStop, trStop_cyclogram);

  cbasetrig = class;

  cTrigsAlarmHandler = class(TInterfacedObject, IAlarmEventHandler)
  public
    procedure Attach;
    procedure Detach;
    function OnAlarmEvent(pTag: ITag; pAlarm:IAlarm; nIndex:integer; dblVal:double; flags:ULONG): HRESULT;stdcall;
  end;

  TTrigAction  = class
  private
    m_targetname:string;
    fmdbPropTag:cTag;
    m_Val:double;
  public
    parent:cbasetrig;
    // писать по фронту триггера/ по спаду
    m_Front:boolean;
    m_target:tobject;
    opertype:integer;
    // свойства базы данных
    mdbPropName:string;
    mdbPropVal:string;
  protected
    procedure relincTargetToName;
    procedure settargetname(tname:string);
    function getmdbtag:itag;
    procedure setmdbtag(t:itag);
    procedure readData;
  public
    function getctag:ctag;
    function opertypetoStr:string;
    function GetString:string;
    procedure apply;
    property targetname:string read m_targetname write settargetname;
    property mdbtag:itag read getmdbtag write setmdbtag;
    constructor create(trig:cbasetrig);
    destructor destroy;
  end;

  cBaseTrig = class(cbaseobj)
  public
    m_DisableOnApply:boolean;
    // включить при старте циклограммы режимов
    m_EnableOnStart:boolean;
    m_actions:tlist;

    m_andTrigs: Tstringlist;
    m_orTrigs: Tstringlist;
    //ChildOperation: TBoolOper;
  private
     // объект который является владельцем триггера
    fowner: tobject;

    fShowInGraph,
    fenabled:boolean;
    // 0 - фронт, 1 - спад, 2 - уровень
    ftrigtype: TTrigType;
    fEList: ceventlist;
    // триггер сработал
    fstate: boolean;
    // триггер применен. Например для триггера уровня триггер может
    // оставаться взведенным (для логических операций), но уже примененным
    fApplyed: boolean;
    fNot: boolean;
    cs_state: TRTLCriticalSection;
    groupSuccess: boolean;

  private
    procedure setState(s: boolean);
    function getState: boolean;
    // перечисляет всех наследников триггерной группы по уровням. т.е. пока первый уровень
    // не выполнится дальше не проверяем триггеры
    function LevelEnumChildrens: boolean;
  protected
    procedure readActionData;
    procedure setowner(o:tobject);
    function getShowInGraphs:boolean;override;
    procedure setShowInGraphs(b:boolean);override;
    procedure doLincParent; override;
    procedure setname(str: string); virtual;
    procedure InitCS;
    procedure DeleteCS;
    function getTrigType: TTrigType;
    procedure ShowComponent(node: pointer; component: tcomponent); override;
    function getimageindex: integer; override;
    procedure setNot(b: boolean);
    function getNot: boolean;
    // вызывается при обработке группы триггеров. ИНогда надо инициализировать
    // обработку триггерногг состояния например для таймера
    procedure beforeCheckInLevelEnum;virtual;
    // добавлено для избежания рекурсии в getState
    // проверяет только локальный триггер без вложений
    // не проверяет данные, только состояние флага fstate! Если надо обновить fstate по новым даным
    // это делает checkStateonNewData
    // ПО СУТИ: СРАБОТАЛ САМ ТРИГГЕР БЕЗ УЧЕТА ИНВЕРСИИ И ПОТОМКОВ
    function check: boolean; virtual;
  public
    procedure doOnStart;
    // сработал сам триггер или нет с учетом инверсии
    function ownState:boolean;
    // проверить логическое состояние триггеров в каталогах m_orTrigs и m_AndTrigs
    function checkBools: boolean; virtual;
    procedure AddEvent(name, dsc: string; e: TNotifyEvent); overload;
    procedure AddEvent(name, dsc: string; etype: cardinal; e: TNotifyEvent);
      overload;
    procedure RemoveEvent(e: TNotifyEvent);
    procedure addAndTrig(t: cBaseTrig);
    function getAndTrig(i:integer):cBaseTrig;
    procedure addOrTrig(t: cBaseTrig);
    function getOrTrig(i:integer):cBaseTrig;
    // поменять состояние (enable/disable) триггера и его потомков
    Procedure SwitchAll(b:boolean);
    procedure setEnabled(b:boolean);virtual;
    function getenabled:boolean;virtual;
    // включить выключить дочерние триггеры на основании уровней.
    // Функция предназначена для вставки в событие обновления триггера
    // дизаблит или наоборот дочерние триги если родители выполнились или наоборот
    procedure SwitchChildState;
    // Сбрасывает при необходимости состояние триггера. Вызывается объектом пользователем триггера.
    // напрмеир если программа стартовала по триггеру типа фронт, то триггер считается сработавшим
    // и сбрасывается в этой процедуре в ноль
    procedure doOnTrigApply;virtual;
  public
    constructor create(p_owner: tobject); virtual;
    destructor destroy; override;

    procedure ApplyActions;
    // для инверсных тригов выполняются действия при срабатывании сброса помеченные флагом выполняться при сбросе
    procedure ApplyFallActions;
    procedure relinkActionTargets;
    function ActionCount:integer;
    function getaction(i:integer):ttrigaction;
    procedure addAction(actType:integer;Target:tobject);overload;
    procedure addAction(a:tTrigAction);overload;

    property Trigtype: TTrigType read getTrigType write ftrigtype;
    // сработал/ не сработал. Для фронт спада надо привести в false в объекте кот использует триггер
    // после срабатывания
    property state: boolean read getState write setState;
    property owner: tobject read fowner write setowner;
    property Inverse: boolean read getNot write setNot;
    property enabled: boolean read getenabled write setEnabled;
  end;

  cTimeTrig = class(cBaseTrig)
  public
    dueTime: cardinal;
  private
    m_TimerHandle, m_Timerqueue: cardinal;
  private
    // стартуем триггер -duetime время через которое таймер должен сработать
    procedure start(p_dueTime: cardinal);
  protected
    procedure beforeCheckInLevelEnum;override;
  public
    procedure doOnTrigApply;override;
    function check: boolean; override;
    constructor create(p_owner: tobject); override;
  end;

  cAlarmTrig = class(cBaseTrig)
  public
    tag:ctag;
  public
    procedure setchannel(str: string); overload;
    procedure setchannel(t: itag); overload;
    // взводится пока в g_conmng (хоть это и неправильно, должно работать в менеджере тригов)
    procedure doOnTrigApply;override;
    constructor create(p_owner: tobject);override;
    destructor destroy;override;
  end;


  cRTrig = class(cBaseTrig)
  public
    ftag: itag;
  private
    fTryTrig:boolean;
    fchannel: string;

    fThreshold: double;
    fdsc: string;
  protected
    function getenabled: boolean;override;
  public
    function LvlTrigType: boolean;
    procedure setchannel(str: string); overload;
    procedure setchannel(t: itag); overload;
    // функция не предназначена для использования пользователем!!!!
    // вставляется в поток обновления данных
    function CheckTrigOnNewData: boolean;
    function channame: string;
    procedure doOnTrigApply;override;
  public

    property Threshold: double read fThreshold write fThreshold;
    property dsc: string read fdsc write fdsc;
  end;

  cTrigChain = class(cBaseTrig)
  public

  end;

  function TrigTypeToInt(trType:TTrigType):integer;
  function IntToTrigType(trType:integer):TTrigType;
  Function MDBAction(a:TTrigAction):boolean;

const
  E_Trig = $00000001;
  E_RenameTrig = $00000002;
  E_DestroyTrig = $00000004;

  c_Trig_front = 0;
  c_Trig_Fall  = 1;
  c_Trig_hiLvl = 2;
  c_Trig_loLvl = 3;
  c_Trig_Eqv   = 4;
  c_Trig_Pause = 5;
  c_Trig_Alarms = 6;
  c_Trig_Start = 7;
  c_Trig_Stop  = 8;
  c_Trig_Stop_Cyclogram  = 9;



  c_Trig_img_fall = 0;
  c_Trig_img_front = 1;
  c_Trig_img_and = 2;
  c_Trig_img_or = 3;
  c_Trig_img_StartRecorder = 4;
  c_Trig_img_StopRecorder = 5;
  c_Trig_img_Pause = 6;
  c_Trig_img_Eqv = 7;
  c_Trig_img_Alarms = 8;


  // стартовать программу
  // Выбрать режим
  c_action_Start= 0;
  // остановить программу cProgramObj
  // завершить режим cModeObj
  // Остановить циклограмму cControlMng
  c_action_Stop=1;
  // след. режим cProgramObj
  c_action_next=2;
  // предыдущий режим cProgramObj
  c_action_Prev=3;
  // пауза программы
  c_action_Pause=4;
  // Отключить триггер
  c_action_Enable=5;
  // Включить триггер
  c_action_Disable=6;

  c_action_MDBaddProp=7;
  c_action_MDBsetProp=8;
  c_action_MDBdecProp=9;
  c_MDB_objid = 'Объект';
  c_MDB_testid = 'Испытание';
  c_MDB_regid = 'Регистрация';



implementation

uses
  PLUGinClass, uControlObj, uMBaseControl;
{ cRTrig }

function TrigTypeToInt(trType:TTrigType):integer;
begin
  case trtype of
    trFront: result :=c_Trig_front;
    trFall:  result :=c_Trig_Fall;
    trHiLvl: result :=c_Trig_hiLvl;
    trLoLvl: result :=c_Trig_loLvl;
    trEqv:   result :=c_Trig_Eqv;
    trPause: result :=c_Trig_Pause;
    trAlarms:result :=c_Trig_Alarms;
    trStart: result :=c_Trig_Start;
    trStop:  result :=c_Trig_Stop;
    trStop_cyclogram:
             result :=c_Trig_Stop_Cyclogram;
  end;
end;

function IntToTrigType(trType:integer):TTrigType;
begin
  case trType of
    c_Trig_front: result:=trFront;
    c_Trig_Fall: result:=trFall;
    c_Trig_hiLvl: result:=trHiLvl;
    c_Trig_loLvl: result:=trLoLvl;
    c_Trig_Eqv:  result:=trEqv;
    c_Trig_Pause: result:=trPause;
    c_Trig_Alarms: result:=trAlarms;
    c_Trig_Start: result:=trStart;
    c_Trig_Stop: result:=trStop;
    c_Trig_Stop_cyclogram: result:=trStop_cyclogram;
  end;
end;

function cRTrig.channame: string;
begin
  if fchannel<>'' then
    result := fchannel
  else
    result := name;
  if ftag <> nil then
  begin
    result := ftag.getname;
  end;
end;

function cRTrig.LvlTrigType: boolean;
begin
  result := (ftrigtype = TrhiLvl) or (ftrigtype = TrloLvl);
end;

procedure cRTrig.setchannel(str: string);
begin
  fchannel := str;
  ftag := getTagByName(str);
  setchannel(ftag);
end;

procedure cRTrig.setchannel(t: itag);
begin
  ftag := t;
  if t <> nil then
  begin
    fchannel := t.getname;
  end;
end;

function cRTrig.CheckTrigOnNewData: boolean;
var
  d: double;
begin
  readActionData;
  if ftag = nil then
  begin
    result := false;
    exit;
  end;
  ftag.GetScalarEstimate(d, ESTIMATOR_MEAN);
  // фронт
  if ftrigtype = trFront then
  begin
    if d > fThreshold then
    begin
      if ftrytrig then
      begin
        result := true;
        ftrytrig:=false;
        state := true;
        fEList.CallAllEvents(E_Trig);
      end
    end
    else
    begin
      state := false;
      ftrytrig := true;
    end;
  end;
  // спад
  if ftrigtype = trFall then
  begin
    if d < fThreshold then
    begin
      if ftrytrig then
      begin
        result := true;
        ftrytrig := false;
        state := true;
        fEList.CallAllEvents(E_Trig);
      end;
    end
    else
    begin
      state := false;
      ftrytrig := true;
    end;
  end;
  if ftrigtype = TrhiLvl then
  begin
    result := d > fThreshold;
    if state <> result then
    begin
      state := result;
      fEList.CallAllEvents(E_Trig);
    end;
  end;
  if ftrigtype = TrloLvl then
  begin
    result := d < fThreshold;
    if state <> result then
    begin
      state := result;
      fEList.CallAllEvents(E_Trig);
    end;
  end;
  if ftrigtype = trEqv then
  begin
    result := d = fThreshold;
    if state <> result then
    begin
      state := result;
      fEList.CallAllEvents(E_Trig);
    end;
  end;
end;

procedure cRTrig.doOnTrigApply;
begin
  case trigtype of
    trFront: state:=false;
    trFall:  state:=false;
    trHiLvl: ;
    trLoLvl: ;
    trPause: state:=false;
    trStart: state:=false;
    trStop: state:=false;
  end;
  inherited;
end;

function cRTrig.getenabled: boolean;
begin
  result:=fenabled;
  if trigtype=trStop then
    result:=true;
end;

{ cBaseTrig }
function cBaseTrig.check: boolean;
begin
  EnterCriticalSection(cs_state);
  result := fstate;
  LeaveCriticalSection(cs_state);
end;


function enumProc(obj: cbaseobj; data: pointer): boolean;
begin
  result := cBaseTrig(obj).check;
  if not result then
    cBaseTrig(data).groupSuccess := false;
end;

function cBaseTrig.getimageindex: integer;
begin
  case Trigtype of
    Trfront:
      result := c_Trig_img_front;
    TrFall:
      result := c_Trig_img_fall;
    TrhiLvl:
      result := c_Trig_img_front;
    TrloLvl:
      result := c_Trig_img_fall;
    TrPause:
      result := c_Trig_img_Pause;
    trEqv:
      result := c_Trig_img_Eqv;
    trAlarms:
      result := c_Trig_img_Alarms;
    TrStart:
      result := c_Trig_img_StartRecorder;
    TrStop:
      result := c_Trig_img_StopRecorder;
  end;
end;


function cBaseTrig.getState: boolean;
begin
  if enabled then
  begin
    result := LevelEnumChildrens;
    if fNot then
      result := not result;
  end
  else
    result:=false;
end;

function cBaseTrig.getTrigType: TTrigType;
begin
  result := ftrigtype;
end;


function cBaseTrig.checkBools: boolean;
var
  i:integer;
  child:cBaseTrig;
begin
  result:=false;
  for I := 0 to m_andTrigs.Count - 1 do
  begin
    child:=getAndTrig(i);
    groupSuccess:=child.LevelEnumChildrens;
    if not groupSuccess then
      exit;
  end;
  for I := 0 to m_OrTrigs.Count - 1 do
  begin
    child:=getOrTrig(i);
    groupSuccess:=child.LevelEnumChildrens;
    if groupSuccess then
      break;
  end;
  result:=groupSuccess;
end;

function cBaseTrig.LevelEnumChildrens: boolean;
var
  I: integer;
  child: cBaseTrig;
begin
  result:=false;
  groupSuccess:=false;
  beforeCheckInLevelEnum;
  if check then
  begin
    groupSuccess:=true;
    if not groupSuccess then
      exit;
    // проверка тригов в каталогах m_orTrigs и m_andTrigs
    groupSuccess:=checkBools;
    // проверка следующего уровня если текущий уровень исполнен
    if groupSuccess then
    begin
      for I := 0 to childCount - 1 do
      begin
        child:=cBaseTrig(getchild(i));
        groupSuccess := child.LevelEnumChildrens;
        if not groupSuccess then
        begin
          break;
        end;
      end;
    end;
  end;
  result := groupSuccess;
end;

function cBaseTrig.ownState: boolean;
begin
  if enabled then
  begin
    if fNot then
      result:=not check
    else
      result:=check;
  end
  else
    result:=false;
end;

procedure cBaseTrig.readActionData;
var
  I: Integer;
  a:TTrigAction;
begin
  for I := 0 to ActionCount - 1 do
  begin
    a:=getaction(i);
    a.readData;
  end;
end;

procedure cBaseTrig.relinkActionTargets;
var
  I: Integer;
  a:TTrigAction;
begin
  if m_actions<>nil then
  begin
    for I := 0 to m_actions.Count - 1 do
    begin
      a:=getaction(i);
      a.relincTargetToName;
    end;
  end;
end;

procedure cBaseTrig.setShowInGraphs(b: boolean);
begin
  fShowInGraph:=b;
end;

function cBaseTrig.getShowInGraphs: boolean;
begin
  result:=fShowInGraph;
end;


procedure cBaseTrig.setState(s: boolean);
begin
  EnterCriticalSection(cs_state);
  fstate := s;
  if not fstate then
    fApplyed:=false;
  LeaveCriticalSection(cs_state);
end;

procedure cBaseTrig.setNot(b: boolean);
begin
  fnot:=b;
end;

procedure cBaseTrig.setowner(o: tobject);
begin
  fowner:=o;
  if o=nil then
    ShowInGraphs:=true
  else
    ShowInGraphs:=false;
end;

function cBaseTrig.getNot: boolean;
begin
  result:=fnot;
end;

procedure cBaseTrig.ShowComponent(node: pointer; component: tcomponent);
var
  vtv: TVTree;
  n, child: pVirtualNode;
  I: integer;
  d: pnodedata;
  t: cBaseTrig;
begin
  vtv := TVTree(component);
  //child := vtv.AddChild(n, c);
  // fastMM выдает порчу памяти если параметр не nil. видать так нельзя данные инициализировать!!!
  // 01/10/18
  n := vtv.AddChild(pVirtualNode(node), nil);
  d := vtv.GetNodeData(n);
  vtv.initChildNode(n);
  d.caption := 'Or';
  d.color := vtv.normalcolor;
  d.ImageIndex := c_Trig_img_or;
  d.data := m_orTrigs;
  for I := 0 to m_orTrigs.Count - 1 do
  begin
    t := cBaseTrig(m_orTrigs.objects[I]);
    t.ShowInGraphs:=true;
    ShowBaseObjectInVTreeView(vtv, t, n);
    t.ShowInGraphs:=false;
  end;

  n := vtv.AddChild(pVirtualNode(node), nil);
  vtv.initChildNode(n);
  d := vtv.GetNodeData(n);
  d.caption := 'And';
  d.color := vtv.normalcolor;
  d.ImageIndex := c_Trig_img_and;
  d.data := m_andTrigs;

  for I := 0 to m_AndTrigs.Count - 1 do
  begin
    t := cBaseTrig(m_AndTrigs.objects[I]);
    t.ShowInGraphs:=true;
    ShowBaseObjectInVTreeView(vtv, t, n);
    t.ShowInGraphs:=false;
  end;

end;

procedure cBaseTrig.setname(str: string);
begin
  inherited;
  fEList.CallAllEventsWithSender(E_RenameTrig, self);
end;

procedure cBaseTrig.InitCS;
begin
  InitializeCriticalSection(cs_state);
end;

procedure cBaseTrig.DeleteCS;
begin
  DeleteCriticalSection(cs_state);
end;

constructor cBaseTrig.create(p_owner: tobject);
begin
  inherited create;
  fApplyed:=False;
  ShowInGraphs:=true;
  m_EnableOnStart:=false;
  fenabled:=false;
  owner := p_owner;
  InitCS;
  fEList := ceventlist.create(self, true);
  fstate := false;
  m_andTrigs := Tstringlist.create;
  m_orTrigs := Tstringlist.create;
end;

destructor cBaseTrig.destroy;
var
  i:integer;
  a:TTrigAction;
begin
  while m_andTrigs.Count>0 do
  begin
    m_andTrigs.Delete(0);
  end;
  m_andTrigs.destroy;
  while m_orTrigs.Count>0 do
  begin
    m_orTrigs.Delete(0);
  end;
  m_orTrigs.destroy;
  if m_actions<>nil then
  begin
    i:=0;
    while m_actions.Count>0 do
    begin
      a:=TTrigAction(m_actions.Items[i]);
      a.Destroy
    end;
    m_actions.Destroy;
    m_actions:=nil;
  end;
  fEList.CallAllEventsWithSender(E_DestroyTrig, self);
  DeleteCS;
  fEList.destroy;
  fEList:=nil;
  inherited;
end;

procedure cBaseTrig.doLincParent;
begin
  inherited;
  if parent<>nil then
  begin
    g_conmng.addtrig(self);
  end;
end;

procedure cBaseTrig.doOnStart;
begin
  state:=false;

end;

procedure cBaseTrig.doOnTrigApply;
var
  I: Integer;
  child:cbasetrig;
begin
  fApplyed:=true;
  for I := 0 to m_OrTrigs.Count - 1 do
  begin
    child:=getOrTrig(i);
    child.doOnTrigApply;
  end;
  for I := 0 to m_AndTrigs.Count - 1 do
  begin
    child:=getAndTrig(i);
    child.doOnTrigApply;
  end;
  for I := 0 to ChildCount - 1 do
  begin
    child:=cbasetrig(getchild(i));
    child.doOnTrigApply;
  end;
  if m_DisableOnApply then
  begin
    enabled:=False;
  end;
end;

procedure cBaseTrig.AddEvent(name, dsc: string; e: TNotifyEvent);
var
  event: cEvent;
begin
  event := fEList.AddEvent(name, E_Trig, e);
  event.dsc := dsc;
end;

procedure cBaseTrig.AddEvent(name, dsc: string; etype: cardinal;
  e: TNotifyEvent);
var
  event: cEvent;
begin
  event := fEList.AddEvent(name, etype, e);
  event.dsc := dsc;
end;

procedure cBaseTrig.ApplyActions;
var
  i:integer;
  a:tTrigAction;
begin
  if not fApplyed then
  begin
    if m_actions<>nil then
    begin
      for I := 0 to ActionCount - 1 do
      begin
        a:=getaction(i);
        a.apply;
        if Trigtype=trStop_cyclogram then
        begin
          if a.opertype=c_action_Start then
          begin
            if a.m_target is cmodeobj then
            begin
              cmodeobj(a.m_target).getProgram.stopmode:=cmodeobj(a.m_target);
            end;
          end;
        end;
      end;
      doOnTrigApply;
    end;
  end;
end;

procedure cBaseTrig.ApplyFallActions;
var
  i:integer;
  a:tTrigAction;
begin
  if m_actions<>nil then
  begin
    for I := 0 to ActionCount - 1 do
    begin
      a:=getaction(i);
      if not a.m_Front then
        a.apply;
    end;
    doOnTrigApply;
  end;
end;

procedure cBaseTrig.beforeCheckInLevelEnum;
begin

end;

function cBaseTrig.getOrTrig(i:integer):cBaseTrig;
begin
  result:=cBaseTrig(m_orTrigs.objects[i]);
end;

procedure cBaseTrig.addAction(actType: integer; Target: tobject);
var
  a:TTrigAction;
begin
  a:=TTrigAction.Create(self);
  a.m_target:=target;
  a.opertype:=actType;
  m_actions.Add(a);
end;

function cBaseTrig.ActionCount: integer;
begin
  if m_actions<>nil then
  begin
    result:=m_actions.Count;
  end
  else
    result:=0;
end;

procedure cBaseTrig.addAction(a:tTrigAction);
begin
  m_actions.Add(a);
end;

procedure cBaseTrig.addOrTrig(t: cBaseTrig);
begin
  t.owner:=m_orTrigs;
  m_orTrigs.AddObject(t.name, t);
  g_conmng.addtrig(t);
end;

procedure cBaseTrig.addAndTrig(t: cBaseTrig);
begin
  t.owner:=m_andTrigs;
  m_andTrigs.AddObject(t.name, t);
  g_conmng.addtrig(t);
end;

function cBaseTrig.getaction(i: integer): ttrigaction;
begin
  result:=ttrigaction(m_actions.items[i]);
end;

function cBaseTrig.getAndTrig(i:integer):cBaseTrig;
begin
  result:=cBaseTrig(m_andTrigs.objects[i]);
end;

function cBaseTrig.getenabled: boolean;
begin
  result:=fenabled;
end;

procedure cBaseTrig.RemoveEvent(e: TNotifyEvent);
begin
  fEList.RemoveEvent(e, E_Trig);
end;

{ cTimeTrig }
// TWaitOrTimerCallback = procedure (Context: Pointer; Success: Boolean) stdcall;
procedure cTimeTrig.beforeCheckInLevelEnum;
begin
  if not check then
  begin
    start(dueTime);
  end;
end;

function cTimeTrig.check: boolean;
begin
  result := inherited check;
end;

constructor cTimeTrig.create(p_owner: tobject);
begin
  inherited;
  Trigtype:=trPause;
  m_TimerHandle := 0;
end;

procedure cTimeTrig.doOnTrigApply;
begin
  state:=False;
  inherited;
end;

procedure timerCallBack(param: pointer; TimerOrWaitFired: boolean); stdcall;
begin
  cTimeTrig(param).state := true;
  DeleteTimerQueueTimer(0,
                        cTimeTrig(param).m_TimerHandle,
                        0);
  cTimeTrig(param).m_TimerHandle:=0;
end;

procedure cTimeTrig.start(p_dueTime: cardinal);
begin
  if m_TimerHandle=0 then
  begin
    m_Timerqueue := 0;
    state:=false;
    CreateTimerQueueTimer(m_TimerHandle,
                          0, // CreateTimerQueue //DeleteTimerQueue(hTimerQueue)
                          timerCallBack,
                          self, // параметр в callback
                          p_dueTime, // задержка перед первым срабатыванием
                          0, // период срабатывания после первого раза. Для одноразового должно быть 0
                          WT_EXECUTEONLYONCE);
  end;
end;

Procedure cBaseTrig.SwitchAll(b:boolean);
var
  I: Integer;
  child:cbasetrig;
begin
  enabled:=b;
  for I := 0 to ChildCount - 1 do
  begin
    child:=cbasetrig(getChild(i));
    child.SwitchAll(b);
  end;
end;

procedure cBaseTrig.SwitchChildState;
var
  I: Integer;
  child:cbasetrig;
  b:boolean;
begin
  b:=false;
  // если триг сам по себе включен
  if enabled then
  begin
    // если триг сработал
    if check then
    begin
      // если логические операции по тригам выполнились
      if checkBools then
      begin
        b:=true;
      end;
    end;
  end;
  for I := 0 to ChildCount - 1 do
  begin
    child:=cbasetrig(getChild(i));
    child.enabled:=b;
    child.SwitchAll(b);
  end;
end;

procedure cBaseTrig.setEnabled(b:boolean);
var
  i:integer;
  child:cbasetrig;
begin
  fenabled:=b;
  if not fenabled then
    fApplyed:=false;

  for I := 0 to m_andTrigs.Count - 1 do
  begin
    child:=cbasetrig(m_andTrigs.Objects[i]);
    child.enabled:=b;
  end;
  for I := 0 to m_orTrigs.Count - 1 do
  begin
    child:=cbasetrig(m_orTrigs.Objects[i]);
    child.enabled:=b;
  end;
end;

{ TrigAction }
procedure StartObj(o:tobject);
begin
  if o is cProgramObj then
  begin
    if cProgramObj(o).state=c_Pause then
    begin
      cProgramObj(o).state:=c_tryplay;
    end
    else
    begin
      if cProgramObj(o).state=c_Stop then
      begin
        cProgramObj(o).state:=c_tryplay;
      end;
    end;
  end;
  if o is cBaseTrig then
  begin

  end;
  if o is cControlObj then
  begin
    cControlObj(o).Start;
  end;
  if o is cModeObj then
  begin
    cModeObj(o).active:=true;
  end;
end;

procedure PauseObj(o:tobject);
begin
  if o is cProgramObj then
  begin
    cProgramObj(o).state:=c_TryPause;
  end;
  if o is cBaseTrig then
  begin

  end;
  if o is cControlObj then
  begin
    cControlObj(o).stop;
  end;
  if o is cModeObj then
  begin
    //cModeObj(o).active:=fa;
  end;
end;

procedure StopObj(o:tobject);
var
  m:cmodeobj;
begin
  if o is cProgramObj then
  begin
    cProgramObj(o).state:=c_TryStop;
  end;
  if o is cBaseTrig then
  begin

  end;
  if o is cControlObj then
  begin
    cControlObj(o).stop;
  end;
  if o is cModeObj then
  begin
    m:=cModeObj(o).getNextMode;
    m.active:=true;
  end;
end;

procedure SetEnable(o:tobject; state:boolean);
var
  m:cmodeobj;
begin
  if o is cProgramObj then
  begin

  end;
  if o is cBaseTrig then
  begin
    cBaseTrig(o).enabled:=state;
  end;
  if o is cControlObj then
  begin
    cControlObj(o).stop;
  end;
  if o is cModeObj then
  begin

  end;
end;

Function MDBAction(a:TTrigAction):boolean;
begin
  if (a.opertype=c_action_MDBaddProp) or
     (a.opertype=c_action_MDBsetProp) or
     (a.opertype=c_action_MDBdecProp)
  then
  begin
    result:=true;
  end
  else
    result:=false;
end;

procedure TTrigAction.apply;
var
  p:cProgramObj;
  t:cBaseTrig;
  m:cModeObj;
  c:cControlObj;
  mdbobj:cxmlfolder;
  str:string;
  success, mdbvalue:boolean;
  tag:itag;
begin
  if MDBAction(self) then
  begin
    mdbobj:=nil;
    if targetname=c_MDB_objid then
    begin
      if MBaseControl<>nil then
        mdbobj:=MBaseControl.GetSelectObj;
    end;
    if targetname=c_MDB_testid then
    begin
      if MBaseControl<>nil then
        mdbobj:=MBaseControl.GetSelecttest;
    end;
    if targetname=c_MDB_regid then
    begin
      if MBaseControl<>nil then
        mdbobj:=MBaseControl.GetSelectreg;
    end;
    if mdbobj<>nil then
    begin
      str:=mdbobj.getProperty(mdbPropName,success);
      mdbvalue:=false;
      if isvalue(str) then
      begin
        if isvalue(mdbPropVal) then
        begin
          mdbvalue:=true;
        end;
      end
      else
      begin
        mdbvalue:=false;
      end;
      case opertype of
        c_action_MDBaddProp:
        begin
          if mdbtag<>nil then
          begin
            str:=floattostr(m_val);
          end
          else
            str:='';
          if mdbvalue then
          begin
            str:=floattostr(strtofloatext(mdbPropVal)+strtofloatext(str));
          end
          else
          begin
            if str<>'' then
            begin

            end
            else
            begin
              str:=str+';'+mdbPropVal
            end;
          end;
        end;
        c_action_MDBsetProp:str:=mdbPropVal;
        c_action_MDBdecProp:
        begin
          if mdbvalue then
          begin
            str:=floattostr(strtofloatext(str)-strtofloatext(mdbPropVal));
          end
          else
          begin

          end;
        end;
      end;
      mdbobj.addpropertie(mdbPropName,str);
      mdbobj.CreateXMLDesc;
      if g_MBaseControl<>nil then
      begin
        g_MBaseControl.ShowObjProps(mdbobj);
      end;
    end;
    exit;
  end;
  if m_target<>nil then
  begin
    case opertype of
      c_action_Start:
      begin
        StartObj(m_target);
      end;
      c_action_Stop:
      begin
        StopObj(m_target);
      end;
      c_action_Prev:
      begin
        if m_target is cProgramObj then
        begin
          m:=cProgramObj(m_target).ActiveMode;
          m:=m.getPrevMode;
          if m<>nil then
            m.TryActive;
        end;
      end;
      c_action_next:
      begin
        if m_target is cProgramObj then
        begin
          m:=cProgramObj(m_target).ActiveMode;
          m:=m.getNextMode;
          if m<>nil then
            m.TryActive;
        end;
      end;
      c_action_Pause:
      begin
        PauseObj(m_target);
      end;
      c_action_Enable:
      begin
        SetEnable(m_target, true);
      end;
      c_action_Disable:
      begin
        SetEnable(m_target, false);
      end;
    end;
  end
  else
  begin
    if opertype=c_action_Stop then
    begin
      g_conmng.stop;
    end;
  end;
end;


function TTrigAction.opertypetoStr:string;
var
  str:string;
begin
  case opertype of
    c_action_Start:result:='Программа/ режим/ регулятор: стартовать';
    c_action_Stop:result:='Программа/ режим/ регулятор/ циклограмма: остановить';
    c_action_next:result:='Программа: след. реж.';
    c_action_Prev:result:='Программа: пред. реж.';
    c_action_Pause:result:='Программа: пaуза';
    c_action_Disable: result:='Триггер: отключить';
    c_action_Enable:result:='Триггер:включить';
    else
    begin
      if (opertype=c_action_MDBaddProp) or
         (opertype=c_action_MDBsetProp) or
         (opertype=c_action_MDBdecProp) then
      begin
        case opertype of
          c_action_MDBaddProp:str:='прибавить св-во';
          c_action_MDBsetProp:str:='установить св-во';
          c_action_MDBdecProp:str:='вычесть св-во';
        end;

        result:=targetname+': '+str;
      end;
    end;
  end;
end;

procedure TTrigAction.setmdbtag(t: itag);
begin
  if fmdbPropTag=nil then
  begin
    fmdbPropTag:=cTag.create;
  end;
  fmdbPropTag.tag:=t;
end;

function TTrigAction.getctag: ctag;
begin
  result:=fmdbPropTag;
end;

function TTrigAction.getmdbtag: itag;
begin
  result:=nil;
  if fmdbPropTag<>nil then
  begin
    result:=fmdbPropTag.tag;
  end;
end;

procedure TTrigAction.settargetname(tname: string);
begin
  m_targetname:=tname;
  relincTargetToName;
end;

procedure TTrigAction.readData;
begin
  if mdbtag<>nil then
  begin
    m_Val:=fmdbPropTag.GetDefaultEst;
  end;
end;

procedure TTrigAction.relincTargetToName;
var
  o:cbaseobj;
begin
  o:=g_conmng.getObj(m_targetname);
  if o=nil then
  begin
    o:=g_conmng.getTrig(m_targetname);
  end;
  if o<>nil then
  begin
    m_target:=o;
  end;
end;

constructor TTrigAction.create(trig: cbasetrig);
begin
  parent:=trig;
  m_Front:=true;
end;

destructor TTrigAction.destroy;
var
  I: Integer;
begin
  for I := 0 to parent.ActionCount - 1 do
  begin
    if parent.getaction(i)=self then
    begin
      parent.m_actions.Delete(i);
      break;
    end;
  end;
  inherited;
end;


function TTrigAction.GetString: string;
begin
  if m_target = nil then
  begin
    result := '';
  end
  else
  begin
    if m_target is cbaseobj then
    begin
      result := cbaseobj(m_target).caption;
    end;
  end;
  if m_target = nil then
  begin
    result:=opertypetoStr;
  end;
  if m_target is cProgramObj then
  begin
    if opertype = c_action_Start then
    begin
      result := 'Стартовать программу: ' + cbaseobj(m_target).caption;
    end;
    if opertype = c_action_Stop then
    begin
      result := 'Остановить программу: ' + cbaseobj(m_target).caption;
    end;
    if opertype = c_action_Next then
    begin
      result := 'след. режим программы: ' + cbaseobj(m_target).caption;
    end;
    if opertype = c_action_Prev then
    begin
      result := 'пред. режим программы: ' + cbaseobj(m_target).caption;
    end;
    if opertype = c_action_Pause then
    begin
      result := 'пауза программы: ' + cbaseobj(m_target).caption;
    end;
  end;
 if m_target is cModeObj then
  begin
    if opertype = c_action_Start then
    begin
      result := 'Стартовать режим: ' + cbaseobj(m_target).caption;
    end;
    if opertype = c_action_Stop then
    begin
      result := 'Остановить режим: ' + cbaseobj(m_target)
        .caption;
    end;
    if opertype = c_action_Next then
    begin
      result := 'Действие не возможно';
    end;
    if opertype = c_action_Prev then
    begin
      result := 'Действие не возможно';
    end;
    if opertype = c_action_Pause then
    begin
      result := 'пауза на режиме:' + cbaseobj(m_target).caption;
    end;
  end;
  if m_target is cBaseTrig then
  begin
    if opertype = c_action_Enable then
    begin
      result := 'Разрешить триггер : ' + cbaseobj(m_target).caption;
    end;
    if opertype = c_action_Disable then
    begin
      result := 'Запретить триггер : ' + cbaseobj(m_target).caption;
    end;
  end;
end;

{ cAlarmTrig }

constructor cAlarmTrig.create(p_owner: tobject);
begin
  inherited;
  tag:=cTag.create;
end;

destructor cAlarmTrig.destroy;
begin
  tag.destroy;
  inherited;
end;

procedure cAlarmTrig.doOnTrigApply;
begin
  state:=false;
  inherited;
end;

procedure cAlarmTrig.setchannel(str: string);
begin
  tag.tagname:=str;
end;

procedure cAlarmTrig.setchannel(t: itag);
begin
  tag.tag:=t;
end;

{ cTrigsAlarmHandler }

procedure cTrigsAlarmHandler.Attach;
var
  ir:irecorder;
  iaeh:IAlarmEventHandler;
  changed:boolean;
begin
  ir:=getIR;
  //iaeh:=self;
  if not FAILED(QueryInterface(IID_IAlarmEventHandler,iaeh)) then
  begin
    ecm(changed);
    ir.Notify(RCN_SUBSCRALARMSEVENT, cardinal(iaeh));
    if changed then
      lcm;
  end;
end;

procedure cTrigsAlarmHandler.Detach;
var
  ir:irecorder;
  iaeh:IAlarmEventHandler;
  changed:boolean;
begin
  ir:=getIR;
  //iaeh:=self;
  if not FAILED(QueryInterface(IID_IAlarmEventHandler,iaeh)) then
  begin
    ecm(changed);
    ir.Notify(RCN_UNSUBSCRALARMSEVENT, cardinal(iaeh));
    if changed then
      lcm;
  end;
end;

function cTrigsAlarmHandler.OnAlarmEvent(pTag: ITag; pAlarm: IAlarm;
  nIndex: integer; dblVal: double; flags: ULONG): HRESULT;
var
  I: Integer;
  tr:cbasetrig;
begin
  for I := 0 to g_conmng.TrigCount - 1 do
  begin
    tr:=g_conmng.getTrig(i);
    if tr is cAlarmTrig then
    begin
      if cAlarmTrig(tr).tag.tagname=ptag.GetName then
      begin
        if nindex<>0 then
        begin
          if tr.enabled then
          begin
            tr.state:=true;
          end;
        end
        else
        begin

        end;
      end;
    end;
  end;
end;

end.
