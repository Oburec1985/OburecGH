unit uModeObj;

interface

uses
  classes, uBaseObj, uBaseObjMng, NativeXML, recorder,
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
  u3120RTrig,
  uControlObj,
  ubaseProgramObj,
  blaccess;

type


  cModeObj = class;

  cProgramList = class(cbaseobj)
  protected
    // перечитать список всех задач
    procedure DoAddTask(sender: tobject);
    procedure DoDelTask(sender: tobject);
  public
    constructor create; override;
    destructor destroy; override;
  end;



  // класс описание задачи регулятору
  cTask = class
  private
    // режим состоит из запрета контролу работать (сохраняем предыдущее значение)
    fStopControlValue: boolean;
    fapplyed: boolean;
    cs: TRTLCriticalSection;
  public
    m_data:T3120Struct;
  public
    TaskType: TPType;
    // компоненты касательных векторов
    leftTang, rightTang,
    // point.y задублирован с m_data.
    point: point2;
    spline: cubicspline;
    // владелец задачи
    control: cControlObj;
    mode: cModeObj;
    // использовать значение предыдущего режима
    m_UsePrev: boolean;

    // допуск. Используется для определения вышли на режим или нет
    m_tolerance: double;
    m_useTolerance: boolean;
    // 0 - проценты, 1 абсолютное значение
    m_tolType:integer;

    // тип скомпилированного сплайна
    SplineInterp: TPType;
    // настройка зоны
  protected
    function GetTask: double;
    procedure SetTask(d: double);
    procedure SetStopControlValue(b: boolean);
    // задание применено
    function getApplyed: boolean;
    procedure setApplyed(b: boolean);
  public
    procedure copytaskto(t: cTask);
    // доп задания контролу
    function TagsToString: string;
    function DataToStr: string;
    procedure strtodata(s:string);
    procedure InitCS;
    procedure DeleteCS;
    procedure exitcs;
    procedure entercs;

    property applyed: boolean read getApplyed write setApplyed;
    function getNextTask: cTask;
    function getPrevTask: cTask;
    function NullSpline: boolean;
    // подразумевается сплайн от точки режима mode до следующего режима
    procedure compilespline;
    function getPrevValue: double;
    // получить юниты из тега
    function getunits: string;
    function strValue: string;
    function strUseTol: string;
    property task: double read GetTask write SetTask;
    property StopControlValue: boolean read fStopControlValue write SetStopControlValue;
  public
    constructor create;
    destructor destroy;
  end;


  cStepVal = class
  public
    name: string;
    m_t: itag;
    m_val: double;
  public
    function tagname: string;
  end;

  // Режим
  cModeObj = class(cBaseProgramObj)
  public
    // тег индикатор что режим включен
    m_stateTag: itag;
    findex: integer;
    // в состоянии проверок (основная часть режима окончена)
    fCheckProgres: boolean;
    // время проверок на допуск
    fCheckLength: double;
    m_tryActive: boolean;
  private
    // применен режим или нет хотя бы один раз
    m_applyed: boolean;
    fCreateStateTag: boolean;
    fCounter: Cardinal;
    factive: boolean;
    // Время на режиме, сек
    f_ModeLength: double;
    // Cписок задач (пара: контроллер/ задание)
    TaskList: tstringlist;
    StepValsList: tstringlist;
    // проверять выход на режим. Следующий режим не начнется пока выбранные контролы не окажутся
    // в допуске fThrehold
    fCheckThrehold: boolean;
    // режим бесконечный - прервется по требованию пользователя или по триггеру
    fInfinity: boolean;
  protected
    procedure setindex(i: integer);
    function GetModeDsc: string;
    procedure SetMainParent(p: cbaseobj); override;
    function getimageindex: integer; override;
    procedure setstate(s: integer);
    function getstate: integer;
    procedure setactive(b: boolean);
    function getactive: boolean;
    procedure setModeLen(d: double);
    function getModeLen: double;
    function getmainparent: cbaseobj; override;
    // cModeObj
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    procedure setMng(m: tobject); override;
    procedure DestroyTags;
    procedure updateTagsNames;
    procedure unLincTags;
    procedure DoLincParent; override;
    procedure setApplyed(b: boolean);
  public
    procedure CreateTasks;
    procedure createTags;

    procedure SwitchModeTrigs(b: boolean);
    // (resetCheck:boolean) - если resetCheck то fCurMode не сбрасывается
    // (сбрасываем только таймер но не останавливаем проверку)
    procedure StopCheckThreshold(resetCheck: boolean);
    function EvalThresholds: boolean;
    procedure StartCheckThreshold;
    function getNextMode: cModeObj;
    function getPrevMode: cModeObj;
    function CopyMode(before: boolean): cModeObj;
    // параметр u значение 0..1 задает точку получаемую при интерполяции между задачами
    function GetTaskValue(t: cTask; x: double): double; overload;
    function GetTaskValue(c: cControlObj; x: double): double; overload;
    // для мультитредового включения. Реально переходит в active в методе exec
    procedure TryActive;
    function stepValCount: integer;
    procedure addstepTag(t: itag; v: double); overload;
    procedure addstepTag(tname: string; v: double); overload;
    procedure delstepTag(t: itag; v: double);
    procedure clearsteptags;
    function getstepval(i: integer): cStepVal; overload;
    function getstepval(tname: string): cStepVal; overload;
    function modeIndex: integer;
    procedure Exec;
    // изменили имя режима
    procedure doRename;
    procedure DoRenameControl(c: cControlObj);
    //function getProgram: cProgramObj;
    function gettimeinterval: point2d;
    function TaskCount: integer;
    procedure clearStepVals;
    function createStepV(t: itag; v: double): cStepVal;
    procedure clearTaskList;
    // обработка списка задач, где каждая задача это регулятор с заданием
    procedure doUpdateData; virtual;
    function createTask(c: cControlObj): cTask; overload;
    function createTask(c: cControlObj; task: double): cTask; overload;
    function createTask(ControlName: string; task: double): cTask; overload;
    procedure editTask(c: cControlObj; task: double); overload;
    procedure editTask(ControlName: string; task: double); overload;
    function GetTask(i: integer): cTask; overload;
    function GetTask(ControlName: string): cTask; overload;
    procedure clearTask;
    procedure DelTask(i: integer); overload;
    procedure DelTask(ControlName: string); overload;
    property state: integer read getstate write setstate;
    property active: boolean read getactive write setactive;
    property ModeLength: double read getModeLen write setModeLen;
    property CheckLength: double read fCheckLength write fCheckLength;
    // необходим контроль режима на выход на допуск
    property CheckThreshold: boolean read fCheckThrehold write fCheckThrehold;
    property Infinity: boolean read fInfinity write fInfinity;
    property MIndex: integer read findex write setindex;
    property applyed:boolean read m_applyed write setApplyed;
    constructor create; override;
    destructor destroy; override;
  end;

const
  // событие обновления состояния рекордера
  E_OnStopControlMng = $00000040;
  E_OnUpdateTrig = $00000080;
  E_OnChangeCfg = $00000100;

  c_NOTReady = 0;
  c_Ready = 1;
  c_TryPlay = 2;
  c_Play = 3;
  c_TryPause = 4;
  c_Pause = 5;
  c_TryStop = 6;
  c_Stop = 7;
  // программа закончилась
  c_TryEnd = 8;
  c_End = 9;
  c_Stop_AndDropTask = 10;
  c_Cardmax = 4294967295;

  // значение для StateTag
  // программа закончилась
  c_Prog_EndTag = 5;
  // программа проверяет режим
  c_Prog_CheckModeTag = 4;
  // программа на бесконечном режиме
  c_Prog_InfinitiModeTag = 3;
  // программа продолжается
  c_Prog_PlayTag = 2;
  // программа в паузе
  c_Prog_PauseTag = 1;
  // программа в стопе
  c_Prog_StopTag = 0;
  // картинки в имеджлисте
  c_img_Program = 0;
  c_img_Program_stop = 1;
  c_img_Program_pause = 2;
  c_img_Program_play = 3;
  c_img_Mode = 4;
  c_img_Mode_stop = 5;
  c_img_Mode_pause = 6;
  c_img_Mode_play = 7;
  c_img_Control = 8;
  c_img_Control_stop = 9;
  c_img_Control_pause = 10;
  c_img_Control_play = 11;
  c_LastConfigFolderName = 'LastCfg';
  // тип режима
  c_TaskType_0 = 0;
  c_TaskType_1 = 1;
  c_TaskType_poly = 2;

  c_DAC_CLASSID = 'CDacControl';
  c_DAC_Typestring = 'Прямое управление ЦАП';

  c_feedback_str = 'Обр.св.:';
  c_DAC_str = 'DAC:';

  c_LogControlCyclogram = true;


implementation

uses
  u3120ControlObj,
  uProgramObj;

  //uMeasureBase,   uMBaseControl  ;

function getmin(i1, i2: integer): integer;
begin
  if i1 >= i2 then
    result := i2
  else
    result := i1;
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

{ cModeObj }

function cModeObj.createTask(c: cControlObj): cTask;
var
  i: integer;
begin
  if not TaskList.Find(c.name, i) then
  begin
    result := cTask.create;
    result.control := c;
    result.task := 0;
    result.mode := self;
    TaskList.AddObject(result.control.name, result);
  end
  else
  begin
    result := GetTask(i);
  end;
end;

function cModeObj.createTask(c: cControlObj; task: double): cTask;
var
  i: integer;
begin
  if not TaskList.Find(c.name, i) then
  begin
    result := cTask.create;
    result.control := c;
    result.task := task;
    result.mode := self;
    TaskList.AddObject(result.control.name, result);
  end
  else
  begin
    result := GetTask(i);
    result.task := task;
  end;
end;

function cModeObj.GetModeDsc: string;
var
  p: cProgramObj;
begin
  result := '';
  if false then
  begin
    p := cProgramObj(getmainparent);
    if p <> nil then
    begin
      result := result + p.name;
    end;
  end
  else
    result := name;
end;

procedure cModeObj.createTags;
var
  ir: irecorder;
  str: string;
  tagname, tname: lpcstr;
  var_type: Variant;
begin
  if fCreateStateTag = false then
    exit;
  ir := getIR;
  str := GetModeDsc + '_State';
  if RStateConfig then
  begin
    if m_stateTag = nil then
    begin
      tname := lpcstr(StrToAnsi(str));
      // tname:=StrToPAnsi(str);
      m_stateTag := CreateStateTag(tname, self);
    end;
  end;
end;

procedure cModeObj.DestroyTags;
var
  changestate: boolean;
  refCount: integer;
begin
  if m_stateTag <> nil then
  begin
    ecm(changestate);
    CloseTag(m_stateTag);
    m_stateTag := nil;
    if changestate then
      lcm;
  end;
end;

procedure cModeObj.updateTagsNames;
var
  ir: irecorder;
  str: ansistring;
begin
  ir := getIR;
  str := GetModeDsc + '_State';
  if m_stateTag <> nil then
    m_stateTag.setname(lpcstr(StrToAnsi(str)))
  else
  begin

  end;
end;

procedure cModeObj.unLincTags;
begin
  DestroyTags;
end;

function cModeObj.createTask(ControlName: string; task: double): cTask;
var
  i: integer;
  con: cControlObj;
begin
  result := nil;
  con := cControlObj(cControlMng(getmng).getobj(ControlName));
  if con <> nil then
  begin
    result := createTask(con, task);
  end;
end;

procedure cModeObj.CreateTasks;
var
  i: integer;
  mng: cControlMng;
  con: cControlObj;
begin
  mng := cControlMng(getmng);
  for i := 0 to mng.ControlsCount - 1 do
  begin
    con := mng.getControlObj(i);
    createTask(con, 0);
  end;
end;

constructor cModeObj.create;
begin
  inherited;

  TaskList := tstringlist.create;
  TaskList.Sorted := true;

  StepValsList := tstringlist.create;
  StepValsList.Sorted := true;
end;

destructor cModeObj.destroy;
var
  i: integer;
  t: cTask;
  s: cStepVal;
begin
  unLincTags;
  for i := 0 to TaskList.Count - 1 do
  begin
    t := GetTask(i);
    t.destroy
  end;
  TaskList.destroy;
  clearsteptags;
  StepValsList.destroy;
  inherited;
end;

procedure cModeObj.DoLincParent;
begin
  inherited;
  if parent <> nil then
  begin
    updateTagsNames;
  end;
end;

procedure cModeObj.StopCheckThreshold(resetCheck: boolean);
var
  i: integer;
  c: cControlObj;
  p: cProgramObj;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    c := GetTask(i).control;
    if not resetCheck then
    begin
      //if c.fCurMode = self then
      //begin
      //  c.StopCheckMode;
      //end;
    end;
  end;
  p := cProgramObj(getmainparent);
  //p.ResetModeCheckTime;
  fCheckProgres := false;
end;

procedure cModeObj.StartCheckThreshold;
var
  i: integer;
  c: cControlObj;
  p: cProgramObj;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    c := GetTask(i).control;
    //c.StarCheckMode(self);
  end;
  p := cProgramObj(getmainparent);
  //p.ResetModeCheckTime;
  fCheckProgres := true;
end;

function cModeObj.EvalThresholds: boolean;
var
  i: integer;
  c: cControlObj;
  p: cProgramObj;
  res: boolean;
  di64, t64, freq: int64;
begin
  res := true;
  for i := 0 to TaskList.Count - 1 do
  begin
    c := GetTask(i).control;
    //res := c.CheckMode;
    if not res then
    begin
      break;
    end;
  end;
  result := res;
  p := cProgramObj(getmainparent);
  QueryPerformanceCounter(t64);
  if res then
  begin
    QueryPerformanceFrequency(freq);
    di64 := decI64(p.fCheckStartTime_i, t64);
    p.fCheckLength := di64 / freq;
  end
  else
  begin
    p.fCheckLength := 0;
  end;
end;

procedure cModeObj.doRename;
begin
  updateTagsNames;
end;

procedure cModeObj.DoRenameControl(c: cControlObj);
var
  i: integer;
  t: cTask;
begin
  for i := 0 to TaskCount - 1 do
  begin
    t := GetTask(i);
    if t.control = c then
    begin
      TaskList.Delete(i);
      TaskList.AddObject(c.name, t);
      exit;
    end;
  end;
end;

procedure cModeObj.editTask(c: cControlObj; task: double);
var
  i: integer;
  t: cTask;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    t.task := task;
  end;
end;

procedure cModeObj.editTask(ControlName: string; task: double);
var
  t: cTask;
begin
  t := GetTask(ControlName);
  if t <> nil then
  begin
    t.task := task;
  end;
end;

procedure cModeObj.Exec;
var
  t, nextT: cTask;
  s: cStepVal;
  c: cControlObj;
  i: integer;
  v, x: double;
  p: cProgramObj;
begin
  if not m_applyed then
  begin
    if m_stateTag <> nil then
      m_stateTag.PushValue(1, -1);
    for i := 0 to stepValCount - 1 do
    begin
      s := getstepval(i);
      if s.m_t <> nil then
      begin
        s.m_t.PushValue(s.m_val, -1);
      end;
    end;
  end;
  p := cProgramObj(getmainparent);
  for i := 0 to TaskCount - 1 do
  begin
    t := GetTask(i);
    if not t.fapplyed then
    begin
      c := t.control;
      c.Task:=t.task;
      c.ApplyTask(t);
      //t.applyed := true; // см ниже 19.10.22
    end
    else
    begin
    end;
    // программа может влиять только на те контролы которые заняты программой
    //if t.control.OwnerProg <> p then
    //  continue;
    // если дано задание не управлять в автомате
    if t.StopControlValue then
    begin
      t.control.state := c_Stop;
    end
    else
    begin
      if t.SplineInterp = ptNullPoly then
      begin
        if (not m_applyed) or (not t.applyed) then
        begin
          //if not t.control.f_manualMode then
          begin
            t.entercs;
            t.control.Task:=t.task;
            t.applyed := true;
            t.exitcs;
          end;
        end;
      end
      else
      begin
        c := t.control;
        x := p.getModeTime / ModeLength;
        v := GetTaskValue(t, x);
        c.Task:=v;
      end;
    end;
  end;
  m_applyed := true;
end;

function cModeObj.modeIndex: integer;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
begin
  result := -1;
  p := cProgramObj(getmainparent);
  for i := 0 to p.ModeCount - 1 do
  begin
    m := p.getMode(i);
    if m = self then
    begin
      result := i;
      exit;
    end;
  end;
end;

function cModeObj.CopyMode(before: boolean): cModeObj;
var
  i: integer;
  t: cTask;
begin
  result := cModeObj.create;
  if before then
    result.MIndex := MIndex
  else
    result.MIndex := MIndex + 1;
  cProgramObj(getmainparent).insertMode(result, result.MIndex);
  result.ModeLength := ModeLength;
  result.CreateTasks;
  for i := 0 to TaskCount - 1 do
  begin
    t := GetTask(i);
    t.copytaskto(result.GetTask(i));
  end;
end;

function cModeObj.getNextMode: cModeObj;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
begin
  result := nil;
  p := cProgramObj(getmainparent);
  i := modeIndex;
  if i > -1 then
  begin
    if i < p.ModeCount then
    begin
      result := p.getMode(i + 1);
    end;
  end;
end;

function cModeObj.getPrevMode: cModeObj;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
begin
  result := nil;
  p := cProgramObj(getmainparent);
  i := modeIndex;
  if i > 0 then
  begin
    result := p.getMode(i - 1);
  end;
end;

function cModeObj.GetTask(i: integer): cTask;
begin
  result := cTask(TaskList.Objects[i]);
end;

procedure cModeObj.clearTask;
var
  t: cTask;
begin
  while TaskList.Count <> 0 do
  begin
    DelTask(0);
  end;
end;

procedure cModeObj.clearTaskList;
var
  i: integer;
  v: cTask;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    v := cTask(TaskList.Objects[i]);
    v.destroy;
  end;
  TaskList.clear;
end;

function cModeObj.createStepV(t: itag; v: double): cStepVal;
var
  str: string;
begin
  result := cStepVal.create;
  str := t.getname;
  result.name := str;
  result.m_t := t;
  result.m_val := v;
  StepValsList.AddObject(str, result);
end;

procedure cModeObj.delstepTag(t: itag; v: double);
var
  tname: string;
  ind: integer;
  s: cStepVal;
begin
  tname := t.getname;
  if StepValsList.Find(tname, ind) then
  begin
    s := cStepVal(StepValsList.Objects[ind]);
    s.destroy;
    StepValsList.Delete(ind);
  end;
end;

function cModeObj.getstepval(i: integer): cStepVal;
begin
  result := cStepVal(StepValsList.Objects[i]);
end;

function cModeObj.getstepval(tname: string): cStepVal;
var
  ind: integer;
begin
  result := nil;
  if StepValsList.Find(tname, ind) then
  begin
    result := getstepval(ind);
  end;
end;

function cModeObj.stepValCount: integer;
begin
  result := StepValsList.Count;
end;

procedure cModeObj.SwitchModeTrigs(b: boolean);
begin
  // if StartTrig <> nil then
  // StartTrig.enabled := b;
  // if StopTrig <> nil then
  // StopTrig.enabled := b;
end;

procedure cModeObj.addstepTag(t: itag; v: double);
var
  tname: string;
  ind: integer;
  s: cStepVal;
begin
  tname := t.getname;
  if not StepValsList.Find(tname, ind) then
  begin
    s := cStepVal.create;
    s.m_t := t;
    s.name := tname;
    s.m_val := v;
    StepValsList.AddObject(tname, s);
  end;
end;

procedure cModeObj.addstepTag(tname: string; v: double);
var
  t: itag;
begin
  t := getTagByName(tname);
  if t <> nil then
  begin
    addstepTag(t, v);
  end;
end;

procedure cModeObj.clearsteptags;
var
  i: integer;
  s: cStepVal;
begin
  for i := 0 to StepValsList.Count - 1 do
  begin
    s := cStepVal(StepValsList.Objects[i]);
    s.destroy;
  end;
  StepValsList.clear;
end;

procedure cModeObj.clearStepVals;
var
  i: integer;
  v: cStepVal;
begin
  for i := 0 to StepValsList.Count - 1 do
  begin
    v := cStepVal(StepValsList.Objects[i]);
    v.destroy;
  end;
  StepValsList.clear;
end;

procedure cModeObj.DelTask(i: integer);
var
  t: cTask;
begin
  t := GetTask(i);
  t.destroy;
  TaskList.Delete(i);
end;

procedure cModeObj.DelTask(ControlName: string);
var
  i: integer;
begin
  if TaskList.Find(ControlName, i) then
  begin
    DelTask(i);
  end;
end;

function cModeObj.getactive: boolean;
begin
  result := factive;
end;

procedure cModeObj.setactive(b: boolean);
var
  p: cProgramObj;
  m: cModeObj;
  i: integer;
begin
  if b = active then
    exit;
  if not b then
  begin
    if m_stateTag <> nil then
      m_stateTag.PushValue(0, -1);
  end;
  p := cProgramObj(getmainparent);
  applyed := false;
  if not active then
  begin
    for i := 0 to p.ModeCount - 1 do
    begin
      m := p.getMode(i);
      if m.active then
      begin
        m.factive := false;
        if m_stateTag <> nil then
          m.m_stateTag.PushValue(0, -1);
        break;
      end;
    end;
  end;
  if b then
  begin
    p.factivemode := self;
    p.ResetModeT;
  end;
  // пишем индекс активного режима в тег
  i := modeIndex;
  p.m_ModeIndTag.PushValue(i, -1);
  StopCheckThreshold(false);
  // p.ResetModeCheckTime;
  factive := b;
  if assigned(p.fOnNextMode) then
  begin
    p.fOnNextMode(self);
  end;
end;

procedure cModeObj.setApplyed(b: boolean);
var
  I: Integer;
  t:cTask;
begin
  m_applyed:=b;
  for I := 0 to TaskCount - 1 do
  begin
    t:=GetTask(i);
    t.applyed:=false;
  end;
end;

procedure cModeObj.setindex(i: integer);
begin
  findex := i;
end;

procedure cModeObj.SetMainParent(p: cbaseobj);
begin
  if p is cProgramObj then
  begin
    cProgramObj(p).addmode(self);
  end
  else
    inherited;
end;

function cModeObj.getimageindex: integer;
begin
  case state of
    c_Play:
      result := c_img_Mode_play;
    c_NOTReady:
      result := c_img_Mode_stop;
    c_Ready:
      result := c_img_Mode;
    c_Pause:
      result := c_img_Mode_pause;
  end;
end;

function cModeObj.getstate: integer;
var
  p: cProgramObj;
begin
  p := cprogramobj(getmainparent);
  if p <> nil then
  begin
    result := p.state;
  end
  else
  begin
    result := c_NOTReady;
  end;
end;

procedure cModeObj.setstate(s: integer);
var
  p: cProgramObj;
begin
  p := cProgramObj(parent);
  p.state := s;
end;

function cModeObj.GetTask(ControlName: string): cTask;
var
  i: integer;
  t: cTask;
begin
  result := nil;
  if TaskList.Find(ControlName, i) then
    result := GetTask(i);
end;

function cModeObj.GetTaskValue(t: cTask; x: double): double;
var
  u: double;
begin
  if t.SplineInterp = ptCubePoly then
  begin
    x := t.spline.p0.x + x * (t.spline.p3.x - t.spline.p0.x);
    u := FindPointOnSpline(t.spline, x);
    result := EvalSplinePoint(u, t.spline).y;
  end
  else
  begin
    if t.SplineInterp = ptNullPoly then
    begin
      result := t.GetTask;
      exit;
    end;
    u := (t.spline.p3.x - t.spline.p0.x) * x + t.spline.p0.x;
    if u > t.spline.p3.x then
    begin
      u := t.spline.p3.x;
    end
    else
    begin
      if (u < t.spline.p0.x) then
      begin
        u := t.spline.p0.x;
      end;
    end;
    result := EvalLineY(u, t.spline.p0, t.spline.p3);
  end;
end;

function cModeObj.GetTaskValue(c: cControlObj; x: double): double;
var
  t: cTask;
begin
  t := GetTask(c.name);
  result := GetTaskValue(t, x);
end;

function cModeObj.gettimeinterval: point2d;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
  t: double;
begin
  p := cProgramObj(getmainparent);
  t := 0;
  for i := 0 to p.ModeCount - 1 do
  begin
    m := p.getMode(i);
    if m <> self then
    begin
      t := t + m.ModeLength;
    end
    else
    begin
      result := p2d(t, t + ModeLength);
      exit;
    end;
  end;
end;

function cModeObj.TaskCount: integer;
begin
  result := TaskList.Count;
end;

procedure cModeObj.TryActive;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
begin
  // все предыдущие попытки сделать другие режимы активными сбрасываем
  p := cProgramObj(getmainparent);
  for i := 0 to p.ModeCount - 1 do
  begin
    m := p.getMode(i);
    if m <> self then
    begin
      m.m_tryActive := false;
    end;
  end;
  m_tryActive := true;
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


procedure cModeObj.LoadObjAttributes(xmlNode: txmlnode; mng: tobject);
var
  TaskNode, stepsNode, n: txmlnode;
  i, lTaskCount: integer;
  t: cTask;
  str, tname: string;
  val: double;
  s: cStepVal;
  c: cControlObj;
  p: cProgramObj;
begin
  inherited;
  ModeLength := xmlNode.ReadAttributeFloat('Length', 0);
  CheckLength := xmlNode.ReadAttributeFloat('CheckLength', 0);
  CheckThreshold := xmlNode.ReadAttributeBool('CheckThreshold', false);
  Infinity := xmlNode.ReadAttributeBool('Infinity', false);

  TaskNode := xmlNode.NodeByName('TaskList');
  if TaskNode <> nil then
  begin
    lTaskCount := TaskNode.ReadAttributeInteger('NCount', 0);
    for i := 0 to lTaskCount - 1 do
    begin
      n := TaskNode.NodeByName('T' + inttostr(i));
      if n <> nil then
      begin
        tname := n.ReadAttributeString('TaskName', '');
        val := n.ReadAttributeFloat('TaskVal', 0);
        editTask(tname, val);
        t := GetTask(tname);
        if t <> nil then
        begin
          t.m_tolerance := n.ReadAttributeFloat('Tolerance', 0);
          t.m_useTolerance := n.ReadAttributeBool('UseTolerance', false);
          t.task := val;
          t.TaskType := IntToTPType(n.ReadAttributeInteger('TaskType', 0));
          t.leftTang.x := n.ReadAttributeFloat('LeftTangX', 0);
          t.leftTang.y := n.ReadAttributeFloat('LeftTangY', 0);
          t.rightTang.x := n.ReadAttributeFloat('RightTangX', 0);
          t.rightTang.y := n.ReadAttributeFloat('RightTangY', 0);
          str := n.ReadAttributeString('Data', '');
          if str<>'' then
            t.StrToData(str);
        end;
      end;
    end;
  end;
  stepsNode := xmlNode.NodeByName('StepList');
  if stepsNode <> nil then
  begin
    lTaskCount := stepsNode.ReadAttributeInteger('NCount', stepValCount);
    for i := 0 to lTaskCount - 1 do
    begin
      n := TaskNode.NodeByName('Step' + inttostr(i));
      if n <> nil then
      begin
        tname := n.ReadAttributeString('StepChannel', '');
        val := n.ReadAttributeFloat('StepVal', 1);
        addstepTag(tname, val);
      end;
    end;
  end;
end;

procedure cModeObj.SaveObjAttributes(xmlNode: txmlnode);
var
  TaskNode, stepsNode, n: txmlnode;
  i: integer;
  t: cTask;
  s: cStepVal;
  str: string;
begin
  inherited;
  xmlNode.WriteAttributeFloat('Length', ModeLength);
  xmlNode.WriteAttributeFloat('CheckLength', CheckLength);
  xmlNode.WriteAttributeBool('CheckThreshold', CheckThreshold);
  xmlNode.WriteAttributeBool('Infinity', Infinity);
  TaskNode := GetNode(xmlNode, 'TaskList');
  TaskNode.WriteAttributeFloat('NCount', TaskCount);
  for i := 0 to TaskCount - 1 do
  begin
    t := GetTask(i);
    n := GetNode(TaskNode, 'T' + inttostr(i));
    n.WriteAttributeString('TaskName', t.control.name);
    n.WriteAttributeFloat('TaskVal', t.GetTask);
    n.WriteAttributeFloat('Tolerance', t.m_tolerance);
    n.WriteAttributeBool('UseTolerance', t.m_useTolerance);
    n.WriteAttributeInteger('TaskType', TPTypeToInt(t.TaskType));
    n.WriteAttributeFloat('LeftTangX', t.leftTang.x);
    n.WriteAttributeFloat('LeftTangY', t.leftTang.y);
    n.WriteAttributeFloat('RightTangX', t.rightTang.x);
    n.WriteAttributeFloat('RightTangY', t.rightTang.y);
    n.WriteAttributeString('Data', t.DataToStr);
  end;
  stepsNode := GetNode(xmlNode, 'StepList');
  stepsNode.WriteAttributeFloat('NCount', stepValCount);
  for i := 0 to stepValCount - 1 do
  begin
    s := getstepval(i);
    n := GetNode(TaskNode, 'Step' + inttostr(i));
    n.WriteAttributeString('StepChannel', s.name);
    n.WriteAttributeFloat('StepVal', s.m_val);
  end;
end;

procedure cModeObj.setMng(m: tobject);
begin
  inherited;
end;

procedure cModeObj.setModeLen(d: double);
begin
  f_ModeLength := d;
end;

function cModeObj.getModeLen: double;
begin
  result := f_ModeLength;
end;


function cModeObj.getmainparent: cbaseobj;
begin
  if parent <> nil then
  begin
    result := parent.parent;
  end
  ELSE
    result := nil;
end;

procedure cModeObj.doUpdateData;
var
  i: integer;
  t: cTask;
  c: cControlObj;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    t := GetTask(i);
    c := t.control;
    c.Task:=t.task;
  end;
  incCounter(fCounter);
end;



{ cProgramList }
constructor cProgramList.create;
begin
  inherited;
  fHelper := true;
  // нельзя ставить True кт.к. будет разрушен и не восстановлен при загрузке
  autocreate := true;
  blocked := true;
end;

destructor cProgramList.destroy;
var
  mng: cControlMng;
begin
  mng := cControlMng(getmng());
  mng.programs := nil;
  inherited;
end;

procedure cProgramList.DoAddTask(sender: tobject);
var
  c: cControlObj;
  i, J: integer;
  p: cProgramObj;
  m: cModeObj;
begin
  if sender is cControlObj then
  begin
    c := cControlObj(sender);
  end;
  for i := 0 to ChildCount - 1 do
  begin
    p := cProgramObj(getChild(i));
    for J := 0 to p.ModeCount - 1 do
    begin
      m := p.getMode(J);
      m.createTask(c, 0);
    end;
  end;
end;

procedure cProgramList.DoDelTask(sender: tobject);
var
  c: cControlObj;
  i, J: integer;
  p: cProgramObj;
  m: cModeObj;
begin
  if sender is cControlObj then
  begin
    c := cControlObj(sender);
  end;
  for i := 0 to ChildCount - 1 do
  begin
    p := cProgramObj(getChild(i));
    for J := 0 to p.ModeCount - 1 do
    begin
      m := p.getMode(J);
      m.DelTask(c.name);
    end;
  end;
end;

procedure cTask.compilespline;
var
  t0, t1, t2: cTask;
  nextM: cModeObj;
begin
  t1 := self;
  t2 := getNextTask;
  // сплайн справа
  if t2 <> nil then
  begin
    if not t2.NullSpline then
    begin
      if (t2.TaskType = ptCubePoly) or (t1.TaskType = ptCubePoly) then
      begin
        t1.SplineInterp := ptCubePoly;
      end
      else
      begin
        if t2.TaskType = ptlinePoly then
        begin
          t1.SplineInterp := ptlinePoly;
        end;
      end;
      t1.spline.p0 := t1.point;
      t1.spline.p1 := t1.rightTang;

      if t2.TaskType = ptCubePoly then
      begin
        t1.spline.p2 := t2.leftTang;
      end
      else
      begin
        t1.spline.p2 := t2.point;
      end;
      t1.spline.p3 := t2.point;
    end
    else
    begin
      t1.SplineInterp := ptNullPoly;
    end;
  end;
  // сплайн слева
  t0 := getPrevTask;
  t1 := t0;
  t2 := self;
  // сплайн слева
  if t1 = nil then
    exit;
  if not t2.NullSpline then
  begin
    if (t2.TaskType = ptCubePoly) or (t1.TaskType = ptCubePoly) then
    begin
      t1.SplineInterp := ptCubePoly;
    end
    else
    begin
      if t2.TaskType = ptlinePoly then
      begin
        t1.SplineInterp := ptlinePoly;
      end;
    end;
    t1.spline.p0 := t1.point;
    t1.spline.p1 := t1.rightTang;
    if t2.TaskType = ptCubePoly then
    begin
      t1.spline.p2 := t2.leftTang;
    end
    else
    begin
      t1.spline.p2 := t2.point;
    end;
    t1.spline.p3 := t2.point;
  end
  else
  begin
    t1.SplineInterp := ptNullPoly;
  end;
end;



procedure cTask.copytaskto(t: cTask);
var
  i: integer;
begin
  t.fStopControlValue := fStopControlValue;
  t.leftTang := leftTang;
  t.rightTang := rightTang;
  t.TaskType := TaskType;
  t.control := control;
  t.point := point;
  t.spline := spline;
  t.m_UsePrev := m_UsePrev;
  t.m_tolerance := m_tolerance;
  t.m_useTolerance := m_useTolerance;
  t.SplineInterp := SplineInterp;
  t.m_data:=m_data;
end;

constructor cTask.create;
begin
  TaskType := ptNullPoly;
  InitCS;
  //m_Params := tstringlist.create;
end;

destructor cTask.destroy;
var
  i: integer;
begin
  DeleteCS;
  //m_Params.destroy;
  //m_Params := nil;
end;

function cTask.getApplyed: boolean;
begin
  result := fapplyed;
end;

function cTask.getNextTask: cTask;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
begin
  result := NIL;
  m := mode.getNextMode;
  if m <> nil then
  begin
    result := m.GetTask(control.name);
  end
end;

function cTask.getPrevTask: cTask;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
begin
  result := NIL;
  p := cProgramObj(mode.getmainparent);
  m := mode.getPrevMode;
  if m <> nil then
  begin
    result := m.GetTask(control.name);
  end
end;

function cTask.getPrevValue: double;
var
  p: cProgramObj;
  i: integer;
  m, Prev: cModeObj;
begin
  p := cProgramObj(mode.getmainparent);
  for i := 0 to p.ModeCount - 1 do
  begin
    m := p.getMode(i);
    if m = mode then
    begin
      if i > 0 then
      begin
        Prev := p.getMode(i - 1);
      end
      else
        Prev := nil;
      break;
    end;
  end;
  if Prev <> nil then
  begin
    result := Prev.GetTask(control.name).task;
  end
  else
  begin
    result := point.y;
  end;
end;

function cTask.GetTask: double;
begin
  if m_UsePrev then
    result := getPrevValue
  else
    result := point.y;
end;

procedure cTask.SetStopControlValue(b: boolean);
begin
  fStopControlValue := b;
end;


//'PWM_Thi=0,PWM_Tlo=0,Zone_state=Вкл,Vals=27,5…28;5;0;5; 0'
procedure TaskupdateParams(pars:tstringlist; src:string; separator:string);
var
  newpars:tstringlist;
  I, p, j, ind: Integer;
  cstr
  //, cstr1
  :cstring;
  str, key:string;
  lstr, param:string;
  Value:cString;
begin
  i:=0;
  while i<=length(src) do
  begin
    str:=GetSubString(src,separator,i, ind);
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubString(str,'=',1,j));
        if param='Vals' then
        begin
          value:=cString.Create;
          p:=i+5;
          lstr:=Copy(src,i+5,length(src)-p+1);
          value.str:=deletechars(lstr,'"');
          pars.addobject(param, value);
          exit;
        end
        else
        begin
          value:=cString.Create;
          lstr:=GetSubString(str,separator,j+1,j);
          value.str:=deletechars(lstr,'"');
          pars.addobject(param, value);
        end;
      end;
    end;
    if i=-1 then
      break;
    i:=ind+1;
  end;
end;


procedure cTask.SetTask(d: double);
begin
  point.y := d;
  m_data.Task:=d;
end;

function cTask.getunits: string;
var
  units: string;
begin
  units := '';
  if control <> nil then
  begin
    //if control.m_feedback <> nil then
    begin
      //units := GetTagUnits(control.m_feedback);
    end;
  end;
  result := units;
end;

function cTask.NullSpline: boolean;
begin
  result := TaskType = ptNullPoly;
end;

procedure cTask.InitCS;
begin
  InitializeCriticalSection(cs);
end;


function cTask.DataToStr: string;
begin
  // p;i;d
  result:=floattostr(m_data.P)+';'+
          floattostr(m_data.I)+';'+
          floattostr(m_data.D)+';'+
          booltostr(m_data.TAlarm)+';'+
          booltostr(m_data.LAlarm)+';'+
          booltostr(m_data.PAlarm)+';'+
          booltostr(m_data.MNAlarm)+';'+
          floattostr(m_data.Tthreshold)+';'+
          floattostr(m_data.Lthreshold)+';'+
          floattostr(m_data.Pthreshold)+';'+
          floattostr(m_data.Mthreshold)+';'+
          floattostr(m_data.Nthreshold)+';'+
          TModeTypeToStr(m_data.ModeType)+';'+
          floattostr(m_data.Nramp)+';'+
          floattostr(m_data.Mramp)+';'+
          booltostr(m_data.cmd_start)+';'+
          booltostr(m_data.cmd_stop)+';'+
          booltostr(m_data.forw);
end;

procedure cTask.strtodata(s:string);
var
  i:integer;
begin
  i:=0;
  m_data.P:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.I:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.D:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.TAlarm:=StrtoBoolExt(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.LAlarm:=StrtoBoolExt(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Palarm:=StrtoBoolExt(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.MNAlarm:=StrtoBoolExt(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Tthreshold:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Lthreshold:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Pthreshold:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Mthreshold:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Nthreshold:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.ModeType:=strToModeType(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Nramp:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.Mramp:=strtofloatext(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.cmd_start:=StrtoBoolExt(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.cmd_stop:=StrtoBoolExt(getSubStrByIndex(s,';',1,i));
  inc(i);
  m_data.forw:=strtoboolext(getSubStrByIndex(s,';',1,i));
end;


procedure cTask.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;

procedure cTask.exitcs;
begin
  LeaveCriticalSection(cs);
end;

procedure cTask.entercs;
begin
  EnterCriticalSection(cs);
end;

procedure cTask.setApplyed(b: boolean);
begin
  fapplyed := b;
end;

function cTask.strUseTol: string;
begin
  if m_useTolerance then
    result := floattostr(m_tolerance)
  else
    result := '-';
end;

function cTask.strValue: string;
begin
  result := floattostr(task) + ' ' + getunits;
end;

function cTask.TagsToString: string;
var
  i: integer;
begin
  result := '';

end;


{ cStepVal }

function cStepVal.tagname: string;
begin
  result := '';
  if m_t <> nil then
  begin
    result := m_t.getname;
  end;
end;




end.
