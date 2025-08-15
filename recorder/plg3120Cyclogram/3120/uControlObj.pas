unit uControlObj;

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
  // u3120RTrig,
  blaccess;

type

  cControlObj = class;
  cControlList = class;

  TModeType = (mtN, mtM, mtStop);

  T3120Struct = record
    // коэф. регулирования
    P, I, D: double;
    // вкл защиту по температуре, по уровню, давл. масла, ур. масла, по оборотам/моменту
    TAlarm, LAlarm, Palarm, LPAlarm, MNAlarm: boolean;
    // уровень лдя защиты по M/N
    Tthreshold, Lthreshold, Pthreshold, MNthreshold: double;
    // тип режима: тормозной (M)/ приводной (N)/ останов
    ModeType: TModeType;
    // запрет на рост быстрее
    Nramp,
    // текущее задание
    Task: double;
  end;

  cControlList = class(cbaseobj)
  protected
    // перечитать список всех задач
    procedure DoAddControl(sender: tobject);
    procedure DoDelcontrol(sender: tobject);
  public
    constructor create; override;
    destructor destroy; override;
  end;

  cControlObj = class(cbaseobj)
  private
    // c_NOTReady = 0;
    // c_Ready = 1;
    // c_Play = 2;
    // c_Stop = 7;
    fstate: integer;
    // на текущем шаге циклограммы пользователь вбил свое задание
    // f_manualMode: boolean;
    cs_state, cs: TRTLCriticalSection;
    // оценивать допуск по максимальному отклонению или по мат ожиданию
    fScalarTolerance: boolean;
    // проверяемый на допуск режим
    // fCurMode: cModeObj;
    // fCurTask: cTask;
    // в допуске
    fInTolerance: boolean;
    fCheckOnMode: boolean;
    // задание
    fTask, fFB: double;
  public
    m_TaskTag, m_FBtag: ctag;
    // m_data:T3120Struct;
    Index: integer;
    // состояние регулятора
    m_stateTag: itag;
  protected
    // применить новое значение к контролу (напрмиер при ручном упроравлдении)
    procedure ApplyTaskVal(v: double); virtual;
    procedure InitCS;
    procedure DeleteCS;
    procedure entercs;
    procedure exitcs;
    // функция обработки регулятора.
    function doUpdateData(): integer; virtual;
    function getstate: integer; virtual;
    procedure setstate(s: integer); virtual;
    function getimageindex: integer; override;
    procedure setproperties(str: string); virtual; abstract;
    function getProperties: string; virtual;
    // вычитать из тега обратную связь
    procedure doRename;
    // procedure setOwnerProg(p: cProgramObj);
    // procedure StarCheckMode(m: cModeObj);
    // procedure StopCheckMode;
    function CheckMode: boolean;
    function getInTol: boolean;
    procedure setInTol(b: boolean);

    // установить доп. свойства контрола на циклограмме.
    // вызывается в cmode.exec, параметры читаются из задачи cTask
    procedure SetTask(t: double); virtual;
    function GetTask: double; virtual;
  public
    procedure createStateTags;
    // применить теги их задачи cTask
    // procedure ApplyTags(t: cTask);
    // применить новую задачу
    procedure ApplyTask(t: tobject);virtual;
    function TagsToString: string;
    function TagsCount: integer;
    procedure ValsFromString(s: string);

    Function PlayState: boolean;
    // вазвращает состояние готов к работе
    // Feedback - канал обратной связи
    // Task - задание
    // data - специализированные настройки могут отличаться для регуляторов раздичных типов
    // function config(Feedback: itag; data: tobject): boolean; virtual;
    procedure Start; virtual;
    procedure stop; virtual;
    procedure pause; virtual;
    function Exec: boolean; virtual;
    function InProgress: boolean;
    function GetCheckOnMode: boolean;
    procedure SetManualTask(t: double); virtual;
    function feedBack: double; virtual;
  public
    property CheckOnMode: boolean read GetCheckOnMode write fCheckOnMode;
    property InTolerance: boolean read getInTol write setInTol;
    // c_NOTReady = 0;
    // c_Ready = 1;
    // c_Play = 2;
    // c_Stop = 7
    // программа которая в данный момент дает задание регулятору
    // property OwnerProg: cProgramObj read fOwnerProg write setOwnerProg;
    property state: integer read getstate write setstate;
    property Properties: string read getProperties write setproperties;
    property Task: double read GetTask write SetTask;
    function getTaskstr(digits: integer): string;
    constructor create; override;
    destructor destroy; override;
  end;

  // регулятор
  cMNControl = class(cControlObj)
  private

  public
    // тег управления
    m_Mtag, m_Ntag: ctag;
    // тег измерения
    m_MtagFB, m_NtagFB: ctag;
    m_data: T3120Struct;
  protected
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
  protected
    procedure ApplyTask(t: tobject);override;
    procedure SetTask(t: double); override;
    function GetTask: double; override;
    constructor create; override;
    destructor destroy; override;
  end;

  cStepVal = class
  public
    name: string;
    m_t: itag;
    m_val: double;
  public
    function tagname: string;
  end;

  function TModeTypeToStr(mt:TModeType):string;
  function strToModeType(s:string):TModeType;

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
  uModeObj;

{ cControlObj }

function TModeTypeToStr(mt:TModeType):string;
begin
  case mt of
    mtN: result:='0';
    mtM: result:='1';
    mtStop: result:='2';
  end;
end;

function strToModeType(s:string):TModeType;
var
  i:integer;
begin
  i:=strtoint(s);
  case i of
    0: result:=mtN;
    1: result:=mtM;
    2: result:=mtStop;
  end;
end;

function cControlObj.TagsCount: integer;
begin
  // result := fTags.Count;
end;

procedure cControlObj.ValsFromString(s: string);
var
  pars: tstringlist;
  I: integer;
  tname: string;
  cstr: cstring;
  // t: cTagPair;
begin
  pars := ParsStrParam(s, ';');
  for I := 0 to pars.Count - 1 do
  begin
    tname := pars.Strings[I];
    cstr := cstring(pars.Objects[I]);
  end;
end;

constructor cControlObj.create;
begin
  inherited;
  InitCS;
  fScalarTolerance := true;
  m_FBtag := ctag.create;
  m_TaskTag := ctag.create;
end;

destructor cControlObj.destroy;
var
  ir: irecorder;
  I: integer;
  // p: cProgramObj;
  b: boolean;
begin
  if m_stateTag <> nil then
  begin
    CloseTag(m_stateTag);
    m_stateTag := nil;
  end;

  m_FBtag.destroy;
  m_TaskTag.destroy;
  DeleteCS;

  // for i := 0 to g_conmng.ProgramCount - 1 do
  // begin
  // p := g_conmng.getProgram(i);
  // p.removeOwnControl(self);
  // end;
  inherited;
end;

procedure cControlObj.createStateTags;
begin
  m_stateTag := CreateStateTag(name + '_state', self);
end;

procedure cControlObj.doRename;
var
  str: string;
  I, J: integer;
  // p: cProgramObj;
  // m: cModeObj;
begin
  str := name + '_State';
  if m_stateTag <> nil then
    m_stateTag.setname(lpcstr(StrToAnsi(str)));
  // for i := 0 to g_conmng.ProgramCount - 1 do
  // begin
  // p := g_conmng.getProgram(i);
  // for J := 0 to p.ModeCount - 1 do
  // begin
  // m := p.getMode(J);
  // m.DoRenameControl(self);
  // end;
  // end;
end;

function cControlObj.doUpdateData(): integer;
begin

end;

procedure cControlObj.pause;
begin
  state := c_Pause;
end;

function cControlObj.Exec: boolean;
var
  v, err: double;
begin
  result := (state = c_Play);
  if m_stateTag <> nil then
  begin
    v := GetMean(m_stateTag);
    if result then
    begin
      // if v < 1 then
      // begin
      // m_stateTag.PushValue(1, -1);
      // end;
    end
    else
    begin

    end;
  end;
  if result then // в состоянии Play
  begin
    // работа без ШИМ
    // if not m_TaskApplyed then
    begin
      // m_TaskApplyed := true;
      ApplyTaskVal(Task);
    end;
    // if m_feedback <> nil then
    // m_dfeedback := GetMean(m_feedback);
  end;
end;

procedure cControlObj.InitCS;
begin
  InitializeCriticalSection(cs_state);
  InitializeCriticalSection(cs);
end;

procedure cControlObj.DeleteCS;
begin
  DeleteCriticalSection(cs_state);
  DeleteCriticalSection(cs);
end;

procedure cControlObj.exitcs;
begin
  LeaveCriticalSection(cs_state);
end;

function cControlObj.feedBack: double;
begin
  result := m_FBtag.GetMeanEst;
end;

procedure cControlObj.entercs;
begin
  EnterCriticalSection(cs_state);
end;

function cControlObj.GetCheckOnMode: boolean;
// var
// p:cProgramObj;
// m: cModeObj;
// t: cTask;
begin
  result := false;
  // m := fCurMode;
  // if m = nil then
  // exit;
  // t := m.GetTask(name);
  // if t = nil then
  // exit;
  // result := t.m_useTolerance;
end;

procedure cControlObj.SetManualTask(t: double);
begin
  // f_manualMode := true;
  SetTask(t);
end;

function cControlObj.GetTask: double;
begin
  result := fTask;
end;

procedure cControlObj.SetTask(t: double);
begin
  fTask := t;
end;

procedure cMNControl.SaveObjAttributes(xmlNode: txmlnode);
var
  str: utf8string;
  I, J, c: integer;
  pars: tstringlist;
begin
  inherited;
  //saveTag(m_Mtag, xmlNode);
  //saveTag(m_Ntag, xmlNode);
  //saveTag(m_MtagFB, xmlNode);
  //saveTag(m_NtagFB, xmlNode);
end;

procedure cMNControl.LoadObjAttributes(xmlNode: txmlnode; mng: tobject);
var
  str: string;
begin
  inherited;
  m_Mtag.tagname:=name+'_Mtsk';
  m_Ntag.tagname:=name+'_Ntsk';
  m_MtagFB.tagname:=name+'_Mfb';
  m_NtagFB.tagname:=name+'_Nfb';
  //LoadTag(xmlNode, m_Mtag);
  //LoadTag(xmlNode, m_Ntag);
  //LoadTag(xmlNode, m_MtagFB);
  //LoadTag(xmlNode, m_NtagFB);
  // str := xmlNode.ReadAttributeString('Tags', '');
  // ValsFromString(str);
end;

procedure cMNControl.SetTask(t: double);
begin
  m_data.Task := t;
end;

procedure cMNControl.ApplyTask(t: tobject);
begin
  m_data:=ctask(t).m_data;
  case m_data.ModeType of
    mtN: m_Ntag.PushValue(m_data.Task);
    mtM: m_Mtag.PushValue(m_data.Task);
    mtStop:;
  end;
end;

constructor cMNControl.create;
begin
  inherited;
  m_Mtag := ctag.create;
  m_Ntag := ctag.create;
  m_MtagFB := ctag.create;
  m_NtagFB := ctag.create;
end;

destructor cMNControl.destroy;
begin
  inherited;
  m_Mtag.destroy;
  m_Ntag.destroy;
  m_MtagFB.destroy;
  m_NtagFB.destroy;
end;

function cMNControl.GetTask: double;
begin
  result := m_data.Task;
end;

function cControlObj.getProperties: string;
begin
  // result := c_feedback_str + feedbackname + ';';
end;

function cControlObj.getimageindex: integer;
begin
  case state of
    c_Play:
      result := c_img_Control_play;
    c_NOTReady:
      result := c_img_Control_stop;
    c_Ready:
      result := c_img_Control;
    c_Pause:
      result := c_img_Control_pause;
  end;
end;

function cControlObj.getInTol: boolean;
begin
  entercs;
  result := fInTolerance;
  exitcs;
end;

procedure cControlObj.setInTol(b: boolean);
begin
  entercs;
  fInTolerance := b;
  exitcs;
end;

function cControlObj.InProgress: boolean;
begin
  result := false;
  if CheckOnMode then
  begin
    // if fCurMode <> nil then
    // result := true;
  end;
end;

function cControlObj.getTaskstr(digits: integer): string;
begin
  result := format('%.*g', [digits, Task]);
end;

function cControlObj.getstate: integer;
begin
  EnterCriticalSection(cs_state);
  result := fstate;
  LeaveCriticalSection(cs_state);
end;

procedure cControlObj.setstate(s: integer);
begin
  EnterCriticalSection(cs_state);
  fstate := s;
  LeaveCriticalSection(cs_state);
  if s = c_Play then
  begin
    m_stateTag.PushValue(1, -1)
  end
  else
  begin
    if s = c_Stop_AndDropTask then
    begin
      m_stateTag.PushValue(3, -1);
      SetTask(0);
    end
    else
      m_stateTag.PushValue(0, -1);
  end;
end;

{
  procedure cControlObj.StarCheckMode(m: cModeObj);
  begin
  fCurMode := m;
  end;

  procedure cControlObj.StopCheckMode;
  begin

  fCurMode := nil;
  end; }

{ procedure cControlObj.ApplyTags(t: cTask);
  var
  i: integer;
  //tag: cTagPair;
  begin
  for i := 0 to t.m_tags.Count - 1 do
  begin
  //tag := cTagPair(t.m_tags.Objects[i]);
  //if isAlive(tag.tag.tag) then
  //  tag.tag.tag.PushValue(tag.value, -1);
  end;
  end; }

{ procedure cControlObj.ApplyTask(t: cTask);
  var
  i: integer;
  begin
  fCurTask := t;
  if t <> nil then
  ApplyTags(t);
  end; }

procedure cControlObj.ApplyTask(t: tobject);
begin
  m_TaskTag.PushValue(ctask(t).m_data.Task);
end;

procedure cControlObj.ApplyTaskVal(v: double);
begin
  fTask:=v;
  m_TaskTag.PushValue(v);
end;

function cControlObj.CheckMode: boolean;
begin
  if not CheckOnMode then
    result := true
  else
    result := InTolerance;
end;

procedure cControlObj.Start;
begin
  state := c_Play;
end;

procedure cControlObj.stop;
begin
  state := c_Stop;
end;

Function cControlObj.PlayState: boolean;
begin
  if fstate = c_Play then
    result := true
  else
    result := false;
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

Function IntToTPType(I: integer): TPType;
begin
  case I of
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

function cControlObj.TagsToString: string;
var
  I: integer;
begin
  result := '';
  for I := 0 to TagsCount - 1 do
  begin

  end;
end;

{ cControlList }
constructor cControlList.create;
begin
  inherited;
  destroydata := true;
  fHelper := true;
  // опасно ставить True кт.к. будет разрушен и не восстановлен при загрузке
  autocreate := true;
  blocked := true;
end;

destructor cControlList.destroy;
var
  mng: cBaseObjMng;
begin
  // mng := getmng();
  // mng.controls := nil;
  inherited;
end;

procedure cControlList.DoAddControl(sender: tobject);
begin

end;

procedure cControlList.DoDelcontrol(sender: tobject);
begin

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

function inrange(r: point2d; x: double): boolean;
begin
  result := false;
  if x <= r.y then
  begin
    if x >= r.x then
      result := true;
  end;
end;

end.
