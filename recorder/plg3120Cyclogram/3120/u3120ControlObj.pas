unit u3120ControlObj;

interface

uses
  classes, uBaseObj, uBaseObjMng, u3120RTrig, NativeXML, recorder,
  dialogs, activeX,
  sysutils, windows, uRecorderEvents, VirtualTrees, uVTServices,
  tags,
  MathFunction,
  uCommonMath,
  ucommontypes,
  pluginclass, plugin, u2dMath, uRCFunc, PathUtils,
  uPathMng,
  IniFiles,
  uEventTypes,
  uAlarms,
  uSetList,
  uControlObj, uModeObj, uProgramObj, uBaseProgramObj,
  blaccess;

type

  TModeType = (mtN, mtM, mtStop);

  T3120Struct = record
    // коэф. регулирования
    P,I,D:double;
    // вкл защиту по температуре, по уровню, давл. масла, ур. масла, по оборотам/моменту
    TAlarm, LAlarm, Palarm, LPAlarm, MNAlarm:boolean;
    // уровень лдя защиты по M/N
    MNthreshold:double;
    // тип режима: тормозной (M)/ приводной (N)/ останов
    ModeType:TModeType;
    // запрет на рост быстрее
    Nramp:double;
  end;

  cControlMng = class(cBaseObjMng)
  private
    fcs: TRTLCriticalSection;
    // состояние ошибки. -1 если сброшено, дальше номер в зависимости от
    // места процедуры в которой упало
    fErrorState: integer;
    // число ошибок
    fErrorCount: integer;

    m_configChanged: boolean;
    // место хранения предыдущей конфигурации
    m_prevDir: string;
    fUseUpdateTagsEvent: boolean;

    // play/pause
    fstate: integer;
    // нужно ли исполнять контролы
    fExecControls: boolean;
    fStoptrig: cBaseTrig;
    // список программ которые претендуют на управление
    fprograms: cProgramList;
    // вызов на удаление происходит при удалении менеджера т.к. обьект залинкован в него
    fcontrols: cControlList;

    // должен быть менеджер в отдельном файле
    fTrigList: tstringlist;
    m_TrigAlarmHandler: cTrigsAlarmHandler;

    // время на испытании
    // обновляется при каждом шаге exec
    ft: double;
    // время предыдущего измерения счетчика времени
    ft64: int64;
    // замер времени с последнего перехода на Play
    fPlayCounter: int64;

    // сколько блоков данных считали всего
    m_ReadyBlockCount: integer;
    m_ITagBlock: IBlockAccess; // ссылка на интерфейс для получения данных тега
    m_BuffSize: integer;
    // Данные тега
    m_TagData: array of double;
    m_TestWriteVTag: itag;
    m_IWriteBlock: IBlockAccess; // ссылка на интерфейс для получения данных тега
  public
    // если переменная выключена то выбор режимов по клику мышью будет работать только
    // когда циклограмма на паузе
    AllowUserModeSelect: boolean;
    // частота счетчика замера времени
    m_Freq: int64;
  public
    function ErrorCount: integer;
    function ErrorStr: string;
  private
    procedure PushErroCode(ec: integer);
    procedure CheckError;

    procedure InitCS;
    procedure DeleteCS;
    procedure exitcs;
    procedure entercs;
    // происходит при останове работы цыклограммы режимво
    procedure UpdateLastState;
    // сохранение состояния циклограммы режимов и конфигураций
    procedure doSaveCfg(sender: tobject);
    // инициация состояния тегов в момент изменения состояния рекордера (чтобы
    // предотвратить лишние срабатывания doUpdateTags)
    procedure pushControlsTags;
    // происходит по событию Recorder когда обновились данные в тегах
    procedure doUpdateData;
    procedure doOnStop;
    // обновляем время испытания
    procedure UpdateT1;
    // сброс времени испытания
    procedure ResetT;
    // продолжить отсчет времени на испытании
    procedure ContinueT;
    procedure Start(p_resetTime: boolean); overload;

    procedure destroyTrigs;
    // блок процедур в цикле обновления данных рекордера!!!
    // проверка триггеров по уровням
    procedure CheckTriggers;
    procedure InitTriggers;
    procedure UpdateControlState;
    procedure UpdateProgramState;
    procedure UpdateModeState;
    procedure UpdateModeTolerance;

    procedure doStartStopTrig(Start: boolean);
    procedure doStopCyclogramTrigs;
    procedure doUpdateTags(sender: tobject);
    procedure doChangeRState(sender: tobject);
    // Линкуем триггеры с объектами назначения
    procedure RelinkTrigsNames;
    procedure doDestroyObjForTrig(sender: tobject);
    procedure createEvents;
    procedure DestroyEvents;
  protected
    // в качестве узла получает корневой узел к которому добавляется инфа
    procedure XMLSaveMngAttributes(node: txmlnode); override;
    procedure XMLlOADMngAttributes(node: txmlnode); override;
    procedure doAfterLoadXML; override;
    procedure doBeforeLoadXML; override;
    procedure regObjClasses; override;
    procedure AddBaseObjInstance(obj: cbaseobj); override;
    procedure removeObj(obj: cbaseobj); override;
    procedure doRenameObj(sender: tobject); override;
    procedure setConfigChanged(b: boolean);
    procedure setstate(s: integer);
    procedure setStopTrigger(t: cBaseTrig);
    procedure CheckCommonStop;
    // применить действия взведенных триггеров
    procedure ApplyActionTrigs;
    // вызывается при старте работы по программе; включает триги у которых
    // включено свойство EnableOnStart
    procedure EnableTrigs;
  public
    procedure SaveToXML(fname: string; sectionName: string); override;
    // сохраняем момент останова
    procedure SaveState;
    procedure LoadState;
    // сбросить состояние всех триггеров
    procedure DropTrigs;
    function getTrig(i: integer): crtrig; overload;
    function getTrig(name: string): crtrig; overload;
    function TrigCount: integer;
    // зарегистрировать триггер в ftriglist;
    procedure addtrig(t: cBaseTrig);
    procedure StopControls;
    // общее время на испытании
    function getComTime: double;
    // время на режиме
    function getProgTime(p: cProgramObj): double;
    function getModeTime(p: cProgramObj): double;
    function getModePauseTime(p: cProgramObj): double;
    function getModeCheckLength(p: cProgramObj): double;
    procedure renametrig(oldname, newname: string);
    procedure doRenameTrig(sender: tobject);
    procedure doDestroyTrig(sender: tobject);
    procedure destroyTrig(t: crtrig);
    // переводит регуляторы в активный режим. Сбрасывает время в 0
    procedure Start; overload;
    // переводит все регуляторы в останов. Не сбрасывает время (работает как пауза)
    procedure stop;
    // останавливает циклограмму но не регуляторы
    procedure pause;
    // переводит циклогамму в активный режим без сброса времени
    procedure continuePlay;
    // выполнить очередной шаг циклограммы режимов
    function Exec: boolean; // возвращает Стоп только при полном останове
    // выполнить шаг регуляторов
    procedure ExecControls;
    function createControl(name: string; classname: string): cControlObj;
    function createMode(name: string; classname: string): cModeObj;
    function getControlObj(id: integer): cControlObj; overload;
    function getControlObj(id: string): cControlObj; overload;
    function ProgramCount: integer;
    function ModeCount: integer;
    function getProgram(i: integer): cProgramObj; overload;
    function getProgram(progname: string): cProgramObj; overload;
    function ControlsCount: integer;
    constructor create; override;
    destructor destroy; override;
  protected
    function getprograms: cProgramList;
  public
    property StopTrigger: cBaseTrig read fStoptrig write setStopTrigger;
    // вызывать напрямую опасно, т.к. должны использоваться флаги вида c_TryStop и c_TryPlay
    // для управления режимом из потока в котором вызывается exec
    property state: integer read fstate write setstate;
    property programs: cProgramList read getprograms write fprograms;
    property controls: cControlList read fcontrols write fcontrols;
    property ConfigChanged: boolean read m_configChanged write setConfigChanged;
  end;

var
  g_conmng: cControlMng;

implementation

//uses
  //uMeasureBase,   uMBaseControl  ;

{ cControlMng }
procedure cControlMng.regObjClasses;
begin
  regclass(cControlObj);
  regclass(cModeObj);
  regclass(cProgramObj);
  regclass(cProgramList);
end;

procedure cControlMng.RelinkTrigsNames;
var
  i: integer;
  t: cBaseTrig;
begin
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    if t is crtrig then
    begin
      if crtrig(t).channame <> '' then
      begin
        if crtrig(t).ftag = nil then
        begin
          crtrig(t).setchannel(crtrig(t).channame);
        end;
      end;
    end;
    t.relinkActionTargets;
  end;
end;

procedure cControlMng.removeObj(obj: cbaseobj);
begin
  inherited;
  if obj is cControlObj then
  begin
    if fprograms <> nil then
    begin
      //fprograms.DoDelTask(obj);
    end;
    if fcontrols <> nil then
    begin
      //fcontrols.DoDelcontrol(obj);
    end;
  end;
end;

procedure cControlMng.doAfterLoadXML;
var
  pi, mi, ti: integer;
  p: cProgramObj;
  m: cModeObj;
  t: cTask;
  i: integer;
begin
  for pi := 0 to ProgramCount - 1 do
  begin
    p := getProgram(pi);
    p.CreateStateTag;
    for mi := 0 to p.ModeCount - 1 do
    begin
      m := p.getMode(mi);
      for ti := 0 to m.TaskCount - 1 do
      begin
        t := m.GetTask(ti);
        t.point := p2(m.gettimeinterval.x, t.task);
        t.compilespline;
      end;
    end;
  end;
  // линкуем триги с объектами движка
  RelinkTrigsNames;

  m_prevDir := getRConfig;

end;

procedure cControlMng.doBeforeLoadXML;
begin
  if fprograms = nil then
  begin
    fprograms := cProgramList.create;
    add(fprograms);
    m_configChanged := true;
  end;
end;

procedure cControlMng.doChangeRState(sender: tobject);
begin
  // прогрузка тегов всех контролов
  pushControlsTags;
  case GetRCStateChange of
    RSt_Init:
      begin
      end;
    RSt_StopToView:
      begin
        InitTriggers;
        doStartStopTrig(true);
      end;
    Rst_StopToRec:
      begin
        InitTriggers;
        doStartStopTrig(true);
      end;
    RSt_ViewToStop:
      begin
        doStartStopTrig(false);
      end;
    RSt_ViewToRec:
      begin
        doStartStopTrig(true);
      end;
    RSt_initToRec:
      begin
        doStartStopTrig(true);
      end;
    RSt_initToView:
      begin
        doStartStopTrig(true);
      end;
    RSt_RecToStop:
      begin
        doStartStopTrig(false);
      end;
    RSt_RecToView:
      begin
        doStartStopTrig(true);
      end;
  end;
end;

procedure cControlMng.doOnStop;
begin
  Events.CallAllEvents(E_OnStopControlMng);
end;

procedure cControlMng.doRenameObj(sender: tobject);
var
  p: cProgramObj;
  m: cModeObj;
  t: cTask;
  i, J: integer;
  c: cControlObj;
begin
  inherited;
  if sender is cModeObj then
  begin
    m := cModeObj(sender);
    m.doRename;
  end;
  if sender is cControlObj then
  begin
    c := cControlObj(sender);
    //c.doRename;
  end;
end;

procedure cControlMng.AddBaseObjInstance(obj: cbaseobj);
begin
  inherited;
  if obj is cBaseProgramObj then
  begin
    // addtrig(cBaseProgramObj(obj).StartTrig);
    // addtrig(cBaseProgramObj(obj).StopTrig);
  end;
  if obj is cProgramObj then
  begin
    obj.parent := programs;
  end;
  if obj is cControlObj then
  begin
    obj.parent := controls;
    //programs.DoAddTask(obj);
    //controls.DoAddControl(obj);
    cControlObj(obj).createStateTags;
  end;
  if obj is cModeObj then
  begin
    cModeObj(obj).CreateTasks;
    cModeObj(obj).createTags;
  end;
end;

procedure cControlMng.doUpdateTags(sender: tobject);
begin
  // потенциально опасно в многопоточности (state)
  if fUseUpdateTagsEvent then
  begin
    CheckError;
    PushErroCode(1);
    CheckTriggers;
    PushErroCode(2);
    // если поменялось значение тега отвечающее за состояние контрола то необходимо поменять состояние контрола
    UpdateControlState;
    PushErroCode(3);
    // если поменялось значение тега отвечающее за состояние программы
    UpdateProgramState;
    PushErroCode(4);
    UpdateModeState;
    PushErroCode(5);
    UpdateModeTolerance;
    PushErroCode(0);
  end;
end;

procedure cControlMng.DropTrigs;
var
  i: integer;
  t: cBaseTrig;
begin
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    t.state := false;
  end;
end;

procedure cControlMng.createEvents;
begin
  AddPlgEvent('cControlMng_doUpdateTags', c_RUpdateData, doUpdateTags);
  AddPlgEvent('cControlMng_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);

  Events.AddEvent('cControlMng_doDestroyObjForTrig', E_OnDestroyObject,
    doDestroyObjForTrig);
end;

procedure cControlMng.DestroyEvents;
begin
  RemovePlgEvent(doUpdateTags, c_RUpdateData);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
  Events.removeEvent(doDestroyObjForTrig, E_OnDestroyObject);
end;

constructor cControlMng.create;
var
  ir: irecorder;
  group: ansistring;
  gname: PAnsiChar;
begin
  inherited;
  // состояние для поиска ошибок
  fErrorState := 0;
  fErrorCount := 0;
  InitCS;

  AllowUserModeSelect := true;

  fUseUpdateTagsEvent := true;

  fExecControls := true;
  m_configChanged := true;

  ft := 0;
  fstate := c_Stop;

  fprograms := cProgramList.create;
  add(fprograms);

  fcontrols := cControlList.create;
  add(fcontrols);

  fTrigList := tstringlist.create;
  fTrigList.Sorted := true;

  ir := getIR;
  group := 'ControlsGroup';
  gname := PAnsiChar(group);
  // m_TagGroup := ITagsGroup(ir.GetGroupByName(gname));
  // if m_TagGroup = nil then
  // begin
  // m_TagGroup := ITagsGroup(ir.CreateTagsGroup(gname));
  // end;

  m_TrigAlarmHandler := cTrigsAlarmHandler.create;
  m_TrigAlarmHandler.Attach;

  createEvents;
end;

destructor cControlMng.destroy;
begin
  DeleteCS;
  // m_TagGroup := nil;

  //m_TrigAlarmHandler.Detach;
  // m_TrigAlarmHandler.Destroy;
  m_TrigAlarmHandler := nil;

  destroyTrigs;
  fTrigList.destroy;
  fTrigList := nil;

  DestroyEvents;
  inherited;
end;

procedure cControlMng.destroyTrigs;
var
  i: integer;
  t: crtrig;
begin
  while fTrigList.Count > 0 do
  begin
    t := getTrig(0);
    t.destroy;
    // fTrigList.Delete(0);
  end;
end;

function cControlMng.createControl(name: string;
  classname: string): cControlObj;
begin
  result := cControlObj(CreateObjByType(classname));
  result.name := name;
  AddBaseObjInstance(result);
end;


function cControlMng.createMode(name: string; classname: string): cModeObj;
begin
  result := cModeObj(CreateObjByType(classname));
  result.name := name;
  AddBaseObjInstance(result);
end;

procedure cControlMng.doUpdateData;
var
  obj: cControlObj;
  i: integer;
  error: integer;
begin
  for i := 0 to Count - 1 do
  begin
    obj := getControlObj(i);
    if obj.state = c_Play then
    begin
      //error := obj.doUpdateData;
    end;
  end;
end;

procedure cControlMng.EnableTrigs;
var
  i: integer;
  t: cBaseTrig;
begin
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    t.enabled := t.m_enableOnStart;
  end;
end;

procedure cControlMng.doStartStopTrig(Start: boolean);
var
  t: cBaseTrig;
  i: integer;
begin
  if state <> c_Play then
    exit;
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    if t is crtrig then
    begin
      if t.Trigtype = trStart then
      begin
        if Start then
        begin
          t.state := true;
          t.ApplyActions;
        end;
      end;
      if t.Trigtype = trStop_cyclogram then
      begin
        if not Start then
        begin
          t.state := true;
          t.ApplyActions;
        end;
      end;
    end;
  end;
end;

procedure cControlMng.doStopCyclogramTrigs;
var
  t: cBaseTrig;
  i: integer;
begin
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    if t is crtrig then
    begin
      if (t.Trigtype = trStop_cyclogram) or (t.Trigtype = trStop) then
      begin
        // if not Start then
        t.state := true; // триггер сработал
        t.ApplyActions;
      end;
    end;
  end;
end;

function cControlMng.Exec: boolean;
var
  i: integer;
  p: cProgramObj;
  bstop: boolean;
begin
  result := true;
  bstop := true;
  // проверяем триггеры
  ApplyActionTrigs;
  case state of
    c_TryPlay:
      state := c_Play;
    c_TryStop:
      begin
        // стоп триг здесь проверяется
        state := c_Stop;
      end;
    c_TryPause:
      state := c_Pause;
  end;
  if state = c_Stop then
  begin
    result := false;
    exit;
  end;
  if (state = c_Play) or (state = c_Pause) then
  begin
    CheckCommonStop;
    // делаем замер времени работы
    UpdateT1;
    for i := 0 to ProgramCount - 1 do
    begin
      p := getProgram(i);
      // проверка нужно ли программу запустить или остановить
      case p.state of
        c_TryPlay:
          begin
            bstop := false;
            p.Exec;
          end;
        c_Play:
          begin
            bstop := false;
            p.Exec;
          end;
        c_Pause:
          begin
            p.Exec;
            bstop := false;
          end;
        c_Stop:
          begin

          end;
        c_End:
          begin

          end
        else
        begin
          // bstop := true;
        end;
      end;
    end;
    // СОХРАНИТЬ АКТИВНЫЕ ПРОГРАММЫ ИХ режимы и времена на режимах
    SaveState;
  end;
  if state = c_Pause then
  begin
    bstop := false;
  end;
  if bstop then
  begin
    if state <> c_Stop then
      state := c_TryStop;
  end;
  // пересчитываем реакцию регуляторов
  // if fExecControls then
  // ExecControls;
end;

procedure cControlMng.ExecControls;
var
  i: integer;
  con: cControlObj;
begin
  for i := 0 to ControlsCount - 1 do
  begin
    con := getControlObj(i);
    con.Exec;
  end;
end;

function cControlMng.ControlsCount: integer;
var
  i: integer;
begin
  result := controls.ChildCount;
end;

function cControlMng.getprograms: cProgramList;
begin
  // приходится пересоздавать после загрузки объекта
  if fprograms = nil then
  begin
    fprograms := cProgramList.create;
    add(fprograms);
  end;
  result := fprograms;
end;

function cControlMng.getControlObj(id: integer): cControlObj;
begin
  result := cControlObj(controls.getChild(id));
end;

function cControlMng.getComTime: double;
begin
  result := ft;
end;

function cControlMng.getControlObj(id: string): cControlObj;
begin
  result := cControlObj(controls.getChild(id));
end;

function cControlMng.getProgTime(p: cProgramObj): double;
begin
  result := p.getProgTime;
end;

function cControlMng.getModePauseTime(p: cProgramObj): double;
begin
  result := p.getModePauseTime;
end;

function cControlMng.getModeCheckLength(p: cProgramObj): double;
begin
  result := p.CheckLength;
end;

function cControlMng.getModeTime(p: cProgramObj): double;
begin
  result := p.getModeTime;
end;

function cControlMng.getProgram(i: integer): cProgramObj;
begin
  result := cProgramObj(programs.getChild(i));
end;

function cControlMng.getProgram(progname: string): cProgramObj;
begin
  result := cProgramObj(programs.getChild(progname));
end;

function cControlMng.getTrig(i: integer): crtrig;
begin
  result := crtrig(fTrigList.Objects[i]);
end;

function cControlMng.getTrig(name: string): crtrig;
var
  i: integer;
begin
  result := nil;
  if fTrigList.Find(name, i) then
  begin
    result := crtrig(fTrigList.Objects[i]);
  end;
end;

procedure cControlMng.InitTriggers;
var
  i: integer;
  t: cBaseTrig;
begin
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    t.doOnStart;
  end;
end;


function cControlMng.ModeCount: integer;
var
  i: integer;
  p: cProgramObj;
begin
  result := 0;
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    result := result + p.ModeCount;
  end;
end;

function cControlMng.ProgramCount: integer;
begin
  result := programs.ChildCount;
end;

procedure cControlMng.pushControlsTags;
var
  i: integer;
  b: boolean;
  c: cControlObj;
  p: cProgramObj;
  v: double;
begin
  c := nil;
  for i := 0 to ControlsCount - 1 do
  begin
    c := getControlObj(i);
    if (c.state = c_Play) or (c.state = c_TryPlay) then
    begin
      c.m_stateTag.PushValue(1, -1);
    end
    else
    begin
      c.m_stateTag.PushValue(0, -1);
    end;
  end;
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    if c = nil then
      b := (p.state = c_Play)
    else
      b := (p.state = c_Play) or (c.state = c_TryPlay);
    if b then
    begin
      p.changeStateTag(c_Prog_PlayTag);
      p.m_ModeIndTag.PushValue(-1, -1);
    end
    else
    begin
      p.changeStateTag(c_Prog_StopTag);
    end;
    if (p.enabled) then
    begin
      p.m_EnableTag.PushValue(1, -1);
    end
    else
    begin
      p.m_EnableTag.PushValue(0, -1);
    end;
  end;
end;

procedure cControlMng.PushErroCode(ec: integer);
begin
  fErrorState := ec;
end;

procedure cControlMng.renametrig(oldname, newname: string);
var
  i: integer;
  t: crtrig;
begin
  if fTrigList.Find(oldname, i) then
  begin
    t := getTrig(i);
    t.name := newname;
    fTrigList.Delete(i);
    fTrigList.AddObject(newname, t);
  end;
end;

procedure cControlMng.doRenameTrig(sender: tobject);
var
  i: integer;
  t: crtrig;
  sl: tstringlist;
begin
  for i := 0 to fTrigList.Count - 1 do
  begin
    t := getTrig(i);
    if t = sender then
    begin
      fTrigList.Delete(i);
      fTrigList.AddObject(t.name, t);
      break;
    end;
  end;
  if cBaseTrig(sender).owner is tstringlist then
  begin
    sl := tstringlist(cBaseTrig(sender).owner);
    for i := 0 to sl.Count - 1 do
    begin
      if sl.Objects[i] = sender then
      begin
        sl.Delete(i);
        sl.AddObject(t.name, t);
        break;
      end;
    end;
  end;
end;

procedure cControlMng.doSaveCfg(sender: tobject);
begin
  m_prevDir := getRConfig;
end;

procedure cControlMng.doDestroyObjForTrig(sender: tobject);
var
  i: integer;
  t: cBaseTrig;
  a: TTrigAction;
  J: integer;
begin
  for i := 0 to fTrigList.Count - 1 do
  begin
    t := getTrig(i);
    if t.ActionCount > 0 then
    begin
      for J := 0 to t.ActionCount - 1 do
      begin
        a := t.getaction(J);
        if a.m_target = sender then
          a.m_target := nil;
      end;
    end;
  end;
end;

procedure cControlMng.doDestroyTrig(sender: tobject);
var
  i: integer;
  sl: tstringlist;
begin
  if fTrigList.Find(cBaseTrig(sender).name, i) then
  begin
    fTrigList.Delete(i);
  end;
  if cBaseTrig(sender).owner <> nil then
  begin
    if cBaseTrig(sender).owner is tstringlist then
    begin
      sl := tstringlist(cBaseTrig(sender).owner);
      for i := 0 to sl.Count - 1 do
      begin
        if sl.Objects[i] = sender then
        begin
          sl.Delete(i);
          break;
        end;
      end;
    end;
  end;
end;

procedure cControlMng.destroyTrig(t: crtrig);
var
  i: integer;
begin
  if fTrigList.Find(t.name, i) then
  begin
    fTrigList.Delete(i);
    t.destroy;
  end;
end;

procedure cControlMng.Start(p_resetTime: boolean);
var
  i: integer;
  obj: cControlObj;
  p: cProgramObj;
begin
  state := c_TryPlay;
  EnableTrigs;
  InitTriggers;
  if p_resetTime then
    ResetT
  else
    ContinueT;
  for i := 0 to ControlsCount - 1 do
  begin
    obj := getControlObj(i);
    obj.Start;
  end;
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    if p.m_enableOnStart then
    begin
      p.enabled := true;
    end;
    // if (p.StartTrig = nil) and (p.m_StartOnPlay) then
    if p.m_StartOnPlay then
      p.Start(p_resetTime)
    else
      p.state := c_Pause;
  end;
end;

procedure cControlMng.Start;
begin
  Start(true);
end;

// переводит циклогамму в активный режим без сброса времени
procedure cControlMng.addtrig(t: cBaseTrig);
var
  i: integer;
  trig: crtrig;
begin
  if t = nil then
    exit;
  for i := 0 to fTrigList.Count - 1 do
  begin
    trig := getTrig(i);
    if trig = t then
      exit;
  end;
  fTrigList.AddObject(t.name, t);
  t.AddEvent('ControlMng_doRenametrig', '', E_RenameTrig, doRenameTrig);
  t.AddEvent('ControlMng_doDestroyTrig', '', E_DestroyTrig, doDestroyTrig);
end;

procedure cControlMng.ApplyActionTrigs;
var
  i: integer;
  t: cBaseTrig;
  res: boolean;
begin
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    if t.m_actions <> nil then
    begin
      res := t.state;
      if res then
      begin
        t.ApplyActions;
      end
      else
      begin
        if t.Inverse then
        begin
          t.ApplyFallActions;
        end;
      end;
    end;
  end;
end;

// doUpdateTag
procedure cControlMng.CheckCommonStop;
begin
  if StopTrigger <> nil then
  begin
    if StopTrigger.state then
    begin
      stop;
      StopTrigger.doOnTrigApply;
    end;
  end;
end;

procedure cControlMng.CheckError;
begin
  if fErrorState <> 0 then
  begin
    entercs;
    inc(fErrorCount);
    exitcs;
    logMessage('Er:' + inttostr(fErrorState) + ' Count:' + inttostr(fErrorCount)
      );
  end;
end;

function cControlMng.ErrorCount: integer;
begin
  entercs;
  result := fErrorCount;
  exitcs;
end;

function cControlMng.ErrorStr: string;
begin
  entercs;
  result := 'Er:' + inttostr(fErrorState) + ' Count:' + inttostr(fErrorCount);
  exitcs;
end;

procedure cControlMng.InitCS;
begin
  InitializeCriticalSection(fcs);
end;

procedure cControlMng.DeleteCS;
begin
  DeleteCriticalSection(fcs);
end;

procedure cControlMng.exitcs;
begin
  LeaveCriticalSection(fcs);
end;

procedure cControlMng.entercs;
begin
  EnterCriticalSection(fcs);
end;

procedure cControlMng.CheckTriggers;
var
  i: integer;
  t: cBaseTrig;
  b1: boolean;
begin
  for i := 0 to fTrigList.Count - 1 do
  begin
    t := getTrig(i);
    if t.enabled then
    begin
      if t is crtrig then
      begin
        b1 := t.ownState;
        crtrig(t).CheckTrigOnNewData;
        if b1 <> t.ownState then
        begin
          // обновление состояния триггера режима или программы
          g_conmng.Events.CallAllEventsWithSender(E_OnUpdateTrig, t);
        end;
      end;
    end;
  end;
  for i := 0 to fTrigList.Count - 1 do
  begin
    t := getTrig(i);
    if (t.parent = nil) and (not(t.owner is tstringlist)) then
    begin
      t.SwitchChildState;
    end;
  end;
end;

procedure cControlMng.UpdateControlState;
var
  i: integer;
  c: cControlObj;
  v: double;
begin
  for i := 0 to ControlsCount - 1 do
  begin
    c := getControlObj(i);
    v := GetMean(c.m_stateTag);
    if c.state = c_Play then
    begin
      // если 0 то Стоп
      if v < 0.5 then
      begin
        c.state := c_Stop;
      end
      else
      begin
        if v > 1.5 then
        begin
          c.state := c_Stop_AndDropTask;
        end;
      end;
    end
    else
    begin
      if v > 0.5 then
      begin
        // Если 1 то Play
        if v < 1.5 then
          c.state := c_Play
        else
        begin
          // Если 2 то Stop и сброс задания
          c.state := c_Stop_AndDropTask;
        end;
      end;
    end;
  end;
end;

procedure cControlMng.UpdateLastState;
var
  i: integer;
  p: cProgramObj;
begin
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    //p.flaststate := p.state;
    //p.fLastMode := '';
    if p.ActiveMode <> nil then
    begin
      //p.fLastMode := p.ActiveMode.name;
    end;
  end;
end;

procedure cControlMng.UpdateModeTolerance;
var
  i, J, len: integer;
  c: cControlObj;
  p: cProgramObj;
  m: cModeObj;
  t: cTask;
  tol: point2d;

  v, devtime: double;
  blCount: integer;
  inTol: boolean;
begin
  if state <> c_Play then
    exit;
  for i := 0 to ControlsCount - 1 do
  begin
    c := getControlObj(i);
    //p := c.OwnerProg;
    if p <> nil then // 1
    begin
      if c.CheckOnMode then // 2
      begin
        //m := p.fCurMode;
        m := p.ActiveMode;
        if m <> nil then // 3
        begin
          t := m.GetTask(c.name);
          v := p.ActiveMode.GetTaskValue(t, 1);
          tol.x := v - t.m_tolerance;
          tol.y := v + t.m_tolerance;
          {if c.fScalarTolerance then
          begin
            v := GetMean(c.m_feedback);
            inTol := false;
            if v > tol.x then
            begin
              if v < tol.y then
              begin
                inTol := true;
              end;
            end;
          end
          else
          // для вектора
          begin
            // сколько всего
            blCount := c.m_feedbackBlA.GetReadyBlocksCount;
            // for I := 0 to blCount - 1 do
            J := blCount - 1;
            len := Length(c.fbData);
            begin
              if SUCCEEDED(c.m_feedbackBlA.GetVectorR8(pointer(c.fbData)^, J,
                  len, true)) then
              begin
                devtime := c.m_feedbackBlA.GetBlockDeviceTime(J);
              end;
            end;
            inTol := true;
            for J := 0 to len - 1 do
            begin
              v := c.fbData[J];
              if (v > tol.y) or (v < tol.x) then
              begin
                inTol := false;
                break;
              end;
            end;
          end;}
          c.InTolerance := inTol;
        end; // 3
      end; // 2
    end; // 1
  end;
end;

procedure cControlMng.UpdateModeState;
var
  i: integer;
  p: cProgramObj;
  v: double;
  newmode: cModeObj;
begin
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    if p.active then
    begin
      v := GetMean(p.m_ModeIndTag);
      if v <> p.ActiveMode.modeIndex then
      begin
        if (g_conmng.state = c_Pause) or g_conmng.AllowUserModeSelect then
        begin
          newmode := p.getMode(trunc(v));
          if newmode <> nil then
          begin
            if g_conmng.state <> c_Stop then
            begin
              if newmode = nil then
                exit;
              if g_conmng.state = c_Play then
                cModeObj(newmode).TryActive
              else
              begin
                if g_conmng.state = c_Pause then
                begin
                  cModeObj(newmode).active := true;
                  cModeObj(newmode).Exec;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure cControlMng.UpdateProgramState;
var
  i: integer;
  p: cProgramObj;
  v: double;
  b: boolean;
begin
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    v := GetScalar(p.m_stateTag);
    //if v = p.m_stateTagVal then
    //  continue;
    b := false;
    case p.state of
      c_Play:
        begin
          if v <> c_Prog_PlayTag then
          begin
            b := true;
          end;
        end;
      c_Pause:
        begin
          if v <> c_Prog_PauseTag then
          begin
            b := true;
          end;
        end;
      c_Stop:
        begin
          if v <> c_Prog_StopTag then
          begin
            b := true;
          end;
        end;
    end;
    if b then
      p.AplyStateTag(round(v));

    v := GetScalar(p.m_EnableTag);
    if p.enabled then
    begin
      if v < 0.5 then
      begin
        //p.fenabled := false;
      end;
    end
    else
    begin
      if v > 0.5 then
      begin
        //p.fenabled := true;
      end;
    end;
  end;
end;

procedure cControlMng.continuePlay;
begin
  Start(false);
end;

procedure cControlMng.stop;
var
  i: integer;
  obj: cControlObj;
  p: cProgramObj;
begin
  if state = c_Stop then
    exit;
  // в setstate сбрасывается время
  state := c_TryStop;
  // останов циклограммы
  // for i := 0 to ProgramCount - 1 do
  // begin
  // p := getProgram(i);
  // p.stop;
  // end;
end;

procedure cControlMng.pause;
var
  i: integer;
  p: cProgramObj;
begin
  state := c_TryPause;
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    p.state := c_Pause;
  end;
end;

procedure cControlMng.UpdateT1;
var
  di64, i64: int64;
begin
  QueryPerformanceCounter(i64);
  QueryPerformanceFrequency(m_Freq);
  // предусмотреть защиту от переполнения таймера
  di64 := decI64(ft64, i64);
  ft := ft + di64 / m_Freq;
  ft64 := i64;
end;

procedure cControlMng.ResetT;
begin
  QueryPerformanceCounter(ft64);
  QueryPerformanceFrequency(m_Freq);
  // предусмотреть защиту от переполнения таймера
  ft := 0;
end;

procedure cControlMng.LoadState;
var
  ifile: tinifile;
  p: cProgramObj;
  m: cModeObj;
  str: string;
  i, c, J: integer;
  l: tlist;
begin
  ifile := tinifile.create(extractfiledir(m_prevDir)
      + '\' + 'CyclogramState.ini');
  // ifile.WriteInteger('Main','State', g_conmng.state);
  str := '';
  c := ifile.ReadInteger('Main', 'ActiveProgCount', 0);
  for i := 0 to c - 1 do
  begin
    str := ifile.ReadString('Prog_' + inttostr(i), 'PName', '');
    if str = '' then
    begin
      break;
    end;
    p := g_conmng.getProgram(str);
    if p <> nil then
    begin
      p.active := true;
    end
    else
    begin
      p := g_conmng.getProgram(0);
      if p = nil then
        exit;
    end;
    str := ifile.ReadString('Prog_' + inttostr(i), 'MName', '');
    if str = '' then
    begin
      continue;
    end;
    m := p.getMode(str);
    if m <> nil then
    begin
      m.active := true;
      //p.fModeT := ifile.ReadFloat('Prog_' + inttostr(i), 'MTime', 0);
      for J := 0 to p.ModeCount - 1 do
      begin
        m := p.getMode(J);
        if m = p.ActiveMode then
        begin
          //p.fProgT := p.fProgT + p.fModeT;
        end
        else
        begin
          //p.fProgT := p.fProgT + m.ModeLength;
        end;
      end;
    end;
  end;
  ifile.destroy;
end;

procedure cControlMng.SaveState;
var
  ifile: tinifile;
  p: cProgramObj;
  m: cModeObj;
  str: string;
  i: integer;
  l: tlist;
begin
  ifile := tinifile.create(extractfiledir(m_prevDir)
      + '\' + 'CyclogramState.ini');
  // ifile.WriteInteger('Main','State', g_conmng.state);
  str := '';
  l := tlist.create;
  for i := 0 to g_conmng.ProgramCount - 1 do
  begin
    p := g_conmng.getProgram(i);
    if p.active then
    begin
      l.add(p);
    end;
  end;
  ifile.WriteInteger('Main', 'ActiveProgCount', l.Count);
  for i := 0 to l.Count - 1 do
  begin
    p := cProgramObj(l.Items[i]);
    ifile.WriteString('Prog_' + inttostr(i), 'PName', p.name);
    m := p.ActiveMode;
    if m <> nil then
    begin
      ifile.WriteString('Prog_' + inttostr(i), 'MName', m.name);
      // время которое программа простояла на режиме
      //ifile.WriteFloat('Prog_' + inttostr(i), 'MTime', p.fModeT);
    end;
  end;
  l.destroy;
  ifile.destroy;
end;

procedure cControlMng.SaveToXML(fname, sectionName: string);
var
  doc: TNativeXml;
  node, cn: txmlnode;
  i: integer;
  obj: cbaseobj;
  dir: string;
begin
  doc := TNativeXml.create(nil);
  if fileexists(fname) then
  begin
    //doc.LoadFromFile(fname);
    node := doc.Root;
    doc.XmlFormat := xfReadable;
    node.name := 'Root';
    if node <> nil then
    begin
      node := node.FindNode('ControlCyclogram');
      if node <> nil then
      begin
        cn := node.FindNode('cProgramList');
        cn.clear;
      end;
      if node<>nil then
        node.Clear;
    end;
    doc.SaveToFile(fname);
    doc.destroy;
  end;
  inherited;
end;

procedure cControlMng.StopControls;
var
  i: integer;
  obj: cControlObj;
begin
  for i := 0 to ControlsCount - 1 do
  begin
    obj := getControlObj(i);
    obj.stop;
  end;
end;

function getmin(i1, i2: integer): integer;
begin
  if i1 >= i2 then
    result := i2
  else
    result := i1;
end;

function cControlMng.TrigCount: integer;
begin
  result := fTrigList.Count;
end;

procedure cControlMng.setConfigChanged(b: boolean);
begin
  m_configChanged := b;
  if b then
  begin
    Events.CallAllEvents(E_OnChangeCfg);
  end;
end;

procedure cControlMng.setstate(s: integer);
var
  i: integer;
  p: cProgramObj;
begin
  fstate := s;
  case s of
    c_Stop:
      begin
        // выполнить триггер перехода циклограммы в стоп
        doStopCyclogramTrigs;
        ResetT;
        for i := 0 to ProgramCount - 1 do
        begin
          p := getProgram(i);
          if p.active then
          begin
            // залипушка на случай если режим поменялся по тригу
            if p.ActiveMode <> nil then
            begin
              /// переписать бы на сокращенный exec с применением только заданий контролов
              /// (все равно стоп, никакие интерполяции не подразумеваются)
              p.ActiveMode.Exec;
              ExecControls;
            end;
          end;
          p.stop;
          p.state := c_Stop;
        end;
        // останов регуляторов
        StopControls;
        if StopTrigger <> nil then
          StopTrigger.enabled := false;
        Events.CallAllEvents(E_OnStopControlMng);
      end;
  else
    begin
      if StopTrigger <> nil then
        StopTrigger.enabled := true;
    end;
  end;

end;

procedure cControlMng.setStopTrigger(t: cBaseTrig);
begin
  if t = nil then
  begin
    if fStoptrig <> nil then
    begin
      fStoptrig.destroy;
      fStoptrig := t;
      addtrig(t);
    end
    else
    begin

    end;
  end
  else
  begin
    if fStoptrig <> nil then
    begin
      fStoptrig.destroy;
      fStoptrig := t;
    end
    else
    begin
      fStoptrig := t;
    end;
    addtrig(t);
  end;
end;

procedure cControlMng.ContinueT;
begin
  QueryPerformanceCounter(ft64);
  QueryPerformanceFrequency(m_Freq);
end;

{ cControlObj }
procedure incCounter(var c: Cardinal);
begin
  inc(c);
  if c = c_Cardmax then
  begin
    c := 0;
  end;
end;



function ModeCompare(p1, p2: pointer): integer;
var
  m1, m2: cModeObj;
begin
  m1 := cModeObj(m1);
  m2 := cModeObj(m2);
  if m1.MIndex > m2.MIndex then
  begin
    result := 1;
  end
  else
  begin
    if m1.MIndex < m2.MIndex then
    begin
      result := -1;
    end
    else
    begin
      result := 0;
    end;
  end;
end;

function ControlComparator(p1, p2: pointer): integer;
var
  c1, c2: cControlObj;
begin
  c1 := cControlObj(p1);
  c2 := cControlObj(p2);
  // if c1.OwnerProg.fcontrols.sorttype=1 then

  if c1.Index > c2.Index then
  begin
    result := 1;
  end
  else
  begin
    if c1.Index < c2.Index then
    begin
      result := -1;
    end
    else
    begin
      result := 0;
    end;
  end;
end;

procedure writeTrig(node: txmlnode; key: string; t: cBaseTrig);
var
  child, actions, ActNode: txmlnode;
  childTrig: cBaseTrig;
  i: integer;
  act: TTrigAction;
  ct: cTag;
begin
  child := GetNode(node, key);
  if t.m_actions <> nil then
  begin
    actions := GetNode(child, 'Actions');
    for i := 0 to t.m_actions.Count - 1 do
    begin
      ActNode := GetNode(actions, 'Act_' + inttostr(i));
      act := TTrigAction(t.m_actions.Items[i]);
      if act.m_target <> nil then
        ActNode.WriteAttributeString('TargetName', cbaseobj(act.m_target).name)
      else
        ActNode.WriteAttributeString('TargetName', act.targetname);
      ActNode.WriteAttributeInteger('ActionType', act.opertype);
      ActNode.WriteAttributeBool('ActionFront', act.m_Front);
      if (act.opertype = c_action_MDBaddProp) or
        (act.opertype = c_action_MDBsetProp) or
        (act.opertype = c_action_MDBdecProp) then
      begin
        ActNode.WriteAttributeString('MDBPropName', act.mdbPropName);
        if act.mdbTag <> nil then
        begin
          ct := act.getctag;
          saveTag(ct, ActNode);
        end
        else
        begin
          ActNode.WriteAttributeString('MDBPropVal', act.mdbPropVal);
        end;
      end;
    end;
  end;
  child.WriteAttributeString('Name', t.name);
  child.WriteAttributeInteger('Type', TrigTypeToInt(t.Trigtype));
  child.WriteAttributeBool('Inverse', t.Inverse);
  child.WriteAttributeBool('EnableOnStart', t.m_enableOnStart);
  child.WriteAttributeBool('DisableOnApply', t.m_DisableOnApply);
  if t is crtrig then
  begin
    child.WriteAttributeString('Trigname', crtrig(t).channame, '');
    child.WriteAttributeFloat('Threshold', crtrig(t).threshold);
  end
  else
  begin
    if t is cTimeTrig then
    begin
      child.WriteAttributeInteger('dueTime', cTimeTrig(t).dueTime);
    end
    else
    begin
      if t is cAlarmTrig then
      begin
        saveTag(cAlarmTrig(t).tag, child);
      end;
    end;
  end;

  child.WriteAttributeInteger('OrCount', t.m_orTrigs.Count);
  for i := 0 to t.m_orTrigs.Count - 1 do
  begin
    childTrig := cBaseTrig(t.m_orTrigs.Objects[i]);
    writeTrig(child, key + '_or_' + inttostr(i), childTrig);
  end;
  child.WriteAttributeInteger('AndCount', t.m_AndTrigs.Count);
  for i := 0 to t.m_AndTrigs.Count - 1 do
  begin
    childTrig := cBaseTrig(t.m_AndTrigs.Objects[i]);
    writeTrig(child, key + '_and_' + inttostr(i), childTrig);
  end;

  child.WriteAttributeInteger('ChildCount', t.ChildCount);
  for i := 0 to t.ChildCount - 1 do
  begin
    childTrig := cBaseTrig(t.getChild(i));
    writeTrig(child, key + '_' + inttostr(i), childTrig);
  end;
end;

function ReadTrig(node: txmlnode; key: string; p: tobject): cBaseTrig;
var
  child, actions, ActNode: txmlnode;
  act: TTrigAction;
  i: TTrigType;
  ChildCount, J: integer;
  t, childTrig: cBaseTrig;
  str: string;
  trigtarget: cbaseobj;
  ct: cTag;
  b: boolean;
begin
  b := false;
  for J := 0 to node.NodeCount - 1 do
  begin
    child := node.Nodes[J];
    if child.name = key then
    begin
      b := true;
      break;
    end;
  end;
  if not b then
    child := nil;
  // child := node.FindNode(key);
  result := nil;
  if child <> nil then
  begin
    i := InttoTrigtype(child.ReadAttributeInteger('Type', 0));
    case i of
      TrPause:
        begin
          t := cTimeTrig.create(p);
          t.Trigtype := i;
        end;
      trAlarms:
        begin
          t := cAlarmTrig.create(p);
          t.Trigtype := i;
        end
      else
      begin
        t := crtrig.create(p);
        t.Trigtype := i;
      end;
    end;
    if t is crtrig then
    begin
      str := child.ReadAttributeString('Trigname', '');
      crtrig(t).setchannel(str);
      crtrig(t).threshold := child.ReadAttributeFloat('Threshold', 0.5);
    end
    else
    begin
      if t is crtrig then
      begin
        cTimeTrig(t).dueTime := child.ReadAttributeInteger('dueTime', 0);
      end
      else
      begin
        ct := LoadTag(child, nil);
        if ct.tag <> nil then
        begin
          cAlarmTrig(t).tag.tag := ct.tag;
        end;
        ct.destroy;
      end;
    end;
    t.name := child.ReadAttributeString('Name', crtrig(t).name);
    t.Inverse := child.ReadAttributeBool('Inverse', false);
    t.m_enableOnStart := child.ReadAttributeBool('EnableOnStart', false);
    t.m_DisableOnApply := child.ReadAttributeBool('DisableOnApply', false);

    actions := child.FindNode('Actions');
    if actions <> nil then
    begin
      t.m_actions := tlist.create;
      for J := 0 to actions.NodeCount - 1 do
      begin
        ActNode := actions.FindNode('Act_' + inttostr(J));
        act := TTrigAction.create(t);
        str := ActNode.ReadAttributeString('TargetName', '');
        act.targetname := str;
        act.opertype := ActNode.ReadAttributeInteger('ActionType', -1);
        act.m_Front := ActNode.ReadAttributeBool('ActionFront', true);
        if (act.opertype = c_action_MDBaddProp) or
          (act.opertype = c_action_MDBsetProp) or
          (act.opertype = c_action_MDBdecProp) then
        begin
          act.mdbPropName := ActNode.ReadAttributeString('MDBPropName', '');
          ct := LoadTag(ActNode, nil);
          if ct.tag = nil then
          begin
            act.mdbPropVal := ActNode.ReadAttributeString('MDBPropVal', '');
          end;
          act.mdbTag := ct.tag;
          ct.destroy;
          ct := nil;
        end;
        t.addAction(act);
      end;
    end;

    ChildCount := child.ReadAttributeInteger('OrCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_or_' + inttostr(J), p);
      t.addOrTrig(childTrig);
    end;
    ChildCount := child.ReadAttributeInteger('AndCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_and_' + inttostr(J), p);
      // if childTrig.name<>'Trig_m02' then
      t.addAndTrig(childTrig)
      // else
      // childTrig.destroy;
    end;

    ChildCount := child.ReadAttributeInteger('ChildCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_' + inttostr(J), p);
      t.AddChild(childTrig);
    end;
    result := t;
  end;
end;

procedure cControlMng.XMLlOADMngAttributes(node: txmlnode);
var
  trignode: txmlnode;
  i: integer;
  t: cBaseTrig;
begin
  inherited;
  AllowUserModeSelect := node.ReadAttributeBool('AlowUserModeSelect', true);
  StopTrigger := ReadTrig(node, 'CommonStopTrig', self);
  trignode := node.FindNode('TrigsNode');
  // пишем триггеры с списком действий
  if trignode <> nil then
  begin
    for i := 0 to trignode.NodeCount - 1 do
    begin
      // if i<1 then
      begin
        t := ReadTrig(trignode, 'ActionTrig_' + inttostr(i), nil);
        addtrig(t);
      end;
    end;
  end;
end;

procedure cControlMng.XMLSaveMngAttributes(node: txmlnode);
var
  TrigsNode: txmlnode;
  i, actTrigCount: integer;
  t: cBaseTrig;
begin
  inherited;
  node.WriteAttributeBool('AlowUserModeSelect', AllowUserModeSelect, true);
  if StopTrigger <> nil then
    writeTrig(node, 'CommonStopTrig', StopTrigger);

  TrigsNode := GetNode(node, 'TrigsNode');
  // пишем триггеры с списком действий
  actTrigCount := 0;
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    if t.m_actions <> nil then
    begin
      if t.owner = nil then
      begin
        writeTrig(TrigsNode, 'ActionTrig_' + inttostr(actTrigCount), t);
        inc(actTrigCount);
      end;
    end;
  end;
end;

Function IntToTPType(i: integer): TPType;
begin
  case i of
    0:
      result := ptNullPoly;
    1:
      result := ptlinePoly;
    2:
      result := ptCubePoly;
  end;
end;

Function TPTypeToInt(pt: TPType): integer;
begin
  case pt of
    ptNullPoly:
      result := 0;
    ptlinePoly:
      result := 1;
    ptCubePoly:
      result := 2;
  end;
end;

end.
