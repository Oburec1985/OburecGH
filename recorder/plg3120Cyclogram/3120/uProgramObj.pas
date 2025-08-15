unit uProgramObj;

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
  ubaseProgramObj,
  uControlObj, uModeObj,
  blaccess;

type

  cProgramList = class(cbaseobj)
  protected
    // перечитать список всех задач
    procedure DoAddTask(sender: tobject);
    procedure DoDelTask(sender: tobject);
  public
    constructor create; override;
    destructor destroy; override;
  end;

  // лист для программы. Не удаляет объекты, умеет сортировать по имени и по индексу
  cProgControlList = class(cSetList)
  public
    // 0 - по имени; 1 - по индексу
    sorttype: integer;
  public
    constructor create; override;
  end;


  // объекты программ выполняются одновременно
  cProgramObj = class(cBaseProgramObj)
  public
    // Стартовать программу при старте циклограммы режимов
    m_StartOnPlay: boolean;
    m_enableOnStart: boolean;
    // режим который устанавливается при останове программы
    StopMode: cModeObj;
  private
    cs: TRTLCriticalSection;
    m_applyModeStateTag: boolean;
    // число повторений программы
    fCounter: Cardinal;
    // состояние программы c_play, c_stop...
    fstate: integer;
    // состояние на момент останова программы
    flaststate: integer;
    fLastMode: string;

    // число повторений программы (общее)
    fRepeatCount,
    // выполненое число повторений программы (общее)
    fStep: integer;
    fenabled: boolean;
    // список режимов
    // объект пустышка для хранения режимов
    fmodes: cbaseobj;
    // объект пустышка для хранения используемых регуляторов
    fcontrols: tstringlist;
    // время паузы на режиме
    fModePauseT: double;
    fInTolerance: boolean;
    // счетчик времени при выполнении посл шага паузы режима
    fModePauseTi: int64;
    // счетчик времени при выполнении посл шага программы
    fModeT1: int64;
    // значение StateTag на предыдущей итерации
    m_stateTagVal: integer;
  public
    // время работы программы
    fProgT: double;
    // время на режиме
    fModeT: double;
    // время начала проверки выхода на режим
    fCheckStartTime: double;
    fCheckStartTime_i: int64;
    // фактическое время проведенное в допуске при выходе на режим
    fCheckLength: double;
    factivemode: cModeObj;

    m_stateTag,
    // номер текущего режима -1 (нет активного режима)
    m_ModeIndTag,
    // запись тега меняет состояние программы
    m_EnableTag: itag;
  protected
    procedure evalStateTag;
    procedure InitCS;
    procedure DeleteCS;
    procedure entercs;
    procedure exitcs;
    // все режимы были не применены
    procedure DropModesApplyedState;
    // обновляем время паузы на режиме
    procedure UpdateModePauseT;
    procedure ResetModePauseT;
    procedure ResetModeCheckTime;
    procedure ContinueModePauseT;
    // обновляем время испытания
    procedure UpdateModeT;
    // сброс времени программы
    procedure ResetProgT;

    function getactive: boolean;override;
  public
    // сброс времени режима и время паузы на режиме (если время режима ноль то и паузы на нем не было)
    procedure ResetModeT;
    procedure changeStateTag(v: integer);
    procedure AplyStateTag(v: integer);
    // продолжить отсчет времени на испытании
    procedure ContinueModeT;
    // время на режиме
    function getCheckLength: double;
    function getModePauseTime: double;
    function getModeTime: double;
    function getProgTime: double;
  protected
    procedure setname(str: string); override;
    function getimageindex: integer; override;
    // cProgramObj
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    // вызывается при переключении состояниия программы
    procedure switchTrigs;
    // вызывать в том же потоке что и execute, чтобы не напороть с временем на режиме (меняется ив  execute и в setstate)
    procedure setstate(s: integer);
    procedure setEnabled(d: boolean);
    function getstate: integer;
    procedure SetActiveMode(m: cModeObj);
    function GetActiveMode: cModeObj;
    // активирует следующий режим и возвращает его. Также резетит время на режиме
    function NextMode: cModeObj;
    // Если пришел один из триггерных сигналов переключиться на другой режим
    function SelectModeByTrig: cModeObj;
  public
    // вызывается сейчас при загрузке из Эксель или XML , что не очень правильно, правильнее было б при смене имени программы
    function CreateStateTag: itag;
    procedure ShowComponent(node: pointer; component: tcomponent); override;
    procedure DoLincParent; override;
  public
    property stateTag: integer read m_stateTagVal write changeStateTag;
    // не предназначено для пользователя (нельзя ставить c_play или stop, можно tryPlay или tryStop
    // (применяется в execute для синхронизации потоков))
    property state: integer read getstate write setstate;
    procedure Start(p_resetTime: boolean); overload;
    // не только переводит в проигрывание, но и сбрасывает счетчик времени
    // в качестве активного режима ставит 0-й режим
    procedure Start; overload;
    procedure continue;
    procedure pause;
    procedure stop;
    // добавляем контрол который будет управляться программой
    procedure AddControl(c: cControlObj);
    procedure removeOwnControls;
    procedure removeOwnControl(c: cControlObj); overload;
    procedure removeOwnControl(i: integer); overload;
    procedure removeOwnControl(cname: string); overload;
    function ControlCount: integer;
    function getOwnControl(i: integer): cControlObj; overload;
    function getOwnControl(name: string): cControlObj; overload;

    function getMode(i: integer): cModeObj; overload;
    function getMode(name: string): cModeObj; overload;
    function getMode(t: cTask): cModeObj; overload;
    // выполнить шаг программы
    procedure Exec;
    function ModeCount: integer;
    // удаляет дочернгие режимы
    procedure ClearModes;
    procedure addmode(m: cModeObj);
    procedure insertMode(m: cModeObj; modeIndex: integer);
    property InTolerance: boolean read fInTolerance write fInTolerance;
    property CheckLength: double read getCheckLength write fCheckLength;
    property ActiveMode: cModeObj read GetActiveMode write SetActiveMode;
    property enabled: boolean read fenabled write setEnabled;
    property RepeatCount: integer read fRepeatCount write fRepeatCount;
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

  c_feedback_str = 'Обр.св.:';
  c_DAC_str = 'DAC:';

  c_LogControlCyclogram = true;


implementation
  uses
    u3120ControlObj;
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


{ cProgramObj }
procedure cProgramObj.changeStateTag(v: integer);
//var
  //r:double;
begin
  if v <> m_stateTagVal then
  begin
    m_stateTagVal := v;
    m_stateTag.PushValue(v, -1);
    //r := GetMean(m_stateTag);
    //if r>0 then
    //  showmessage('1');
  end;
end;

procedure cProgramObj.AplyStateTag(v: integer);
begin
  case v of
    c_Prog_PlayTag:
      begin
        state := c_TryPlay;
      end;
    c_Prog_PauseTag:
      begin
        state := c_Pause;
      end;
    c_Prog_StopTag:
      begin
        state := c_Stop;
      end;
  end;

end;

procedure cProgramObj.continue;
begin
  Start(false);
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

constructor cProgramObj.create;
begin
  inherited;
  enabled := true;
  m_enableOnStart := true;
  m_applyModeStateTag := false;
  fmodes := cbaseobj.create;
  fmodes.destroydata := true;
  fmodes.autocreate := true;
  fmodes.fHelper := true;
  fmodes.name := name + '_Режимы';
  fmodes.childrens.comparator := ModeCompare;
  fmodes.childrens.Sorted := true;

  fcontrols := tstringlist.create;
  // fcontrols.comparator:=ControlComparator;
  fcontrols.Sorted := true;
  AddChild(fmodes);

  InitCS;
end;

destructor cProgramObj.destroy;
var
  ir: irecorder;
begin
  DeleteCS;
  fmodes.destroy;
  fcontrols.destroy;
  if m_stateTag <> nil then
  begin
    ir := getIR;
    CloseTag(m_stateTag);
    m_stateTag := nil;
  end;
  if m_EnableTag <> nil then
  begin
    CloseTag(m_EnableTag);
    m_EnableTag := nil;
  end;
  if m_ModeIndTag <> nil then
  begin
    CloseTag(m_ModeIndTag);
    m_ModeIndTag := nil;
  end;
  inherited;
end;

procedure cProgramObj.DoLincParent;
begin
  inherited;
end;

procedure cProgramObj.DropModesApplyedState;
var
  i: integer;
  m: cModeObj;
begin
  for i := 0 to ModeCount - 1 do
  begin
    m := getMode(i);
    m.m_applyed := false;
  end;
end;

procedure cProgramObj.AddControl(c: cControlObj);
begin
  fcontrols.AddObject(c.name, c);
end;

procedure cProgramObj.removeOwnControls;
begin
  fcontrols.clear;
end;

procedure cProgramObj.removeOwnControl(c: cControlObj);
begin
  removeOwnControl(c.name);
end;

procedure cProgramObj.removeOwnControl(i: integer);
begin
  fcontrols.Delete(i);
end;

procedure cProgramObj.removeOwnControl(cname: string);
var
  i: integer;
  c: cControlObj;
begin
  for i := 0 to fcontrols.Count - 1 do
  begin
    c := cControlObj(fcontrols.Objects[i]);
    if c.name = cname then
    begin
      fcontrols.Delete(i);
      break;
    end;
  end;
end;

function cProgramObj.ControlCount: integer;
begin
  result := fcontrols.Count;
end;

function cProgramObj.getOwnControl(i: integer): cControlObj;
begin
  result := cControlObj(fcontrols.Objects[i]);
end;

function cProgramObj.getOwnControl(name: string): cControlObj;
var
  i: integer;
  c: cControlObj;
  b: boolean;
begin
  b := false;
  if fcontrols.Sorted then
  begin
    if fcontrols.Find(name, i) then
    begin
      result := cControlObj(fcontrols.Objects[i]);
    end
    else
    begin
      result := nil;
    end;
  end
  else
  begin
    for i := 0 to fcontrols.Count - 1 do
    begin
      c := cControlObj(fcontrols.Objects[i]);
      if c.name = name then
      begin
        b := true;
        break;
      end;
    end;
  end;
end;

procedure cProgramObj.ClearModes;
begin
  fmodes.destroychildrens;
end;

procedure cProgramObj.addmode(m: cModeObj);
begin
  m.MIndex := fmodes.ChildCount;
  fmodes.AddChild(m);
end;

procedure cProgramObj.insertMode(m: cModeObj; modeIndex: integer);
var
  i: integer;
  mode: cModeObj;
begin
  m.MIndex := modeIndex;
  for i := m.MIndex to ModeCount - 1 do
  begin
    mode := getMode(i);
    inc(mode.findex);
  end;
  fmodes.AddChild(m);
end;

procedure cProgramObj.ResetModeCheckTime;
begin
  QueryPerformanceCounter(fCheckStartTime_i);
  fCheckLength := 0;
end;

procedure cProgramObj.Exec;
var
  i: integer;
  mode: cModeObj;
  continueMode: boolean;
begin
  case state of
    c_TryPlay:
      state := c_Play;
    c_TryStop:
      state := c_Stop;
    c_TryPause:
      state := c_Pause;
  end;
  if state = c_Pause then
  begin
    // продолжаем считать таймер
    // возможно следует перенести в execute где выполняется непосредственный учет времени
    UpdateModePauseT;
  end;
  if state = c_Play then
  begin
    // попытка выбрать новый режим по триггеру
    // или по запросу пользователя m_tryMode
    // в том числе переход на предыдущий режим
    SelectModeByTrig;
    UpdateModeT;
    mode := ActiveMode;
    if mode <> nil then
    begin
      // mode.ModeLength - бесконечный режим, который может кончиться только по триггеру
      continueMode := (fModeT < mode.ModeLength) or (mode.Infinity);
      if not continueMode then
      begin
        if mode.CheckThreshold then // нужна проверка перед переходом на новый режим
        begin
          if not mode.fCheckProgres then
          begin
            // сбрасываем время проверки
            mode.StartCheckThreshold;
          end;
          continueMode := true;
          if (mode.EvalThresholds) and (state = c_Play) then
          begin
            if fCheckLength >= mode.fCheckLength then
            begin
              continueMode := false;
              mode.StopCheckThreshold(false);
            end;
          end
          else
          begin
            // сбрасываем время проверки
            ResetModeCheckTime;
          end;
        end;
      end;
      if continueMode then
      begin

      end
      else
      begin
        // получаем следующий режим, резетим время, даем новое задание
        mode := NextMode;
      end;
    end;
    if mode <> nil then
    begin
      mode.Exec;
      incCounter(fCounter);
    end
    else
    begin
      if ModeCount > 0 then
      begin
        inc(fStep);
        // программы повторилась еще раз
        if fStep < fRepeatCount then
        begin
          mode := getMode(0);
          mode.active := true;
        end
        else
        begin
          state := c_End;
        end;
      end
      else // в программе нет режимов, значит ставим, что сразу закончилась
      begin
        state := c_End;
      end;
    end;
  end;
  evalStateTag;
end;

procedure cProgramObj.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure cProgramObj.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;

procedure cProgramObj.exitcs;
begin
  LeaveCriticalSection(cs);
end;

procedure cProgramObj.entercs;
begin
  EnterCriticalSection(cs);
end;

procedure cProgramObj.evalStateTag;
begin
  case state of
    c_Play:
      begin
        if ActiveMode <> nil then
        begin
          if ActiveMode.Infinity then
            changeStateTag(c_Prog_InfinitiModeTag)
          else
          begin
            if ActiveMode.fCheckProgres then
            begin
              changeStateTag(c_Prog_CheckModeTag);
            end
            else
            begin
              changeStateTag(c_Prog_PlayTag);
            end;
          end;
        end
      end;
    c_Stop:
      begin
        changeStateTag(c_Prog_StopTag);
      end;
    c_TryStop:
      begin
        changeStateTag(c_Prog_StopTag);
      end;
    c_End:
      begin
        changeStateTag(c_Prog_EndTag);
      end;
    c_Pause:
      begin
        changeStateTag(c_Prog_PauseTag);
      end;
  end;

end;

function cProgramObj.CreateStateTag: itag;
var
  b:boolean;
begin
  ecm(b);
  if m_stateTag=nil  then
  begin
    m_stateTag := uRCFunc.CreateStateTag(name + '_State', self);
    m_EnableTag := uRCFunc.CreateStateTag(name + '_Enable', self);
    m_ModeIndTag := uRCFunc.CreateStateTag(name + '_ModeIndTag', self);
  end;
  result := m_stateTag;
  if b then
    lcm;
end;

function cProgramObj.getactive: boolean;
begin
  result := state = (c_Play);
end;

function cProgramObj.ModeCount: integer;
begin
  result := fmodes.ChildCount;
end;

function cProgramObj.getMode(i: integer): cModeObj;
begin
  if i < 0 then
    result := nil
  else
    result := cModeObj(fmodes.getChild(i));
end;

function cProgramObj.getMode(name: string): cModeObj;
begin
  result := cModeObj(fmodes.getChildrenByCaption(name));
end;

function cProgramObj.getMode(t: cTask): cModeObj;
var
  i: integer;
  m: cModeObj;
  J: integer;
  lt: cTask;
begin
  result := nil;
  for i := 0 to ModeCount - 1 do
  begin
    m := getMode(i);
    for J := 0 to m.TaskCount - 1 do
    BEGIN
      lt := m.GetTask(J);
      if lt = t then
      begin
        result := m;
        exit;
      end;
    END;
  end;
end;

function cProgramObj.getModeTime: double;
begin
  result := fModeT;
end;

function cProgramObj.getCheckLength: double;
begin
  entercs;
  result := fCheckLength;
  exitcs;
end;

function cProgramObj.getModePauseTime: double;
begin
  result := fModePauseT;
end;

function cProgramObj.getProgTime: double;
begin
  result := fProgT;
end;

function cProgramObj.GetActiveMode: cModeObj;
var
  i: integer;
  obj: cModeObj;
begin
  result := factivemode;
end;

function cProgramObj.NextMode: cModeObj;
var
  actMode, m: cModeObj;
  i: integer;
begin
  fInTolerance := false;
  actMode := GetActiveMode;
  result := nil;
  for i := 0 to ModeCount - 1 do
  begin
    m := getMode(i);
    if m = actMode then
    begin
      if i <> (ModeCount - 1) then
      begin
        result := getMode(i + 1);
        actMode.m_applyed := false;
        result.active := true;
      end;
    end;
  end;
end;

function cProgramObj.SelectModeByTrig: cModeObj;
var
  actMode, m: cModeObj;
  i, startind: integer;
begin
  result := nil;
  // выбор режима по запросу пользователя
  for i := 0 to ModeCount - 1 do
  begin
    m := getMode(i);
    if m.m_tryActive then
    begin
      m.active := true;
      // на случай если находились в режиме проверки
      // case state of
      // c_Pause: changeStateTag(c_Prog_PauseTag);
      // c_Play: changeStateTag(c_Prog_PlayTag);
      // end;
      m.m_tryActive := false;
      result := m;
      exit;
    end;
  end;
  actMode := GetActiveMode;
  if actMode = nil then
    exit;
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

procedure cProgramObj.SaveObjAttributes(xmlNode: txmlnode);
var
  i: integer;
  str: string;
  c: cControlObj;
begin
  inherited;
  xmlNode.WriteAttributeInteger('ControlCount', ControlCount);
  // пишем используемые контролы
  for i := 0 to ControlCount - 1 do
  begin
    str := 'Control' + inttostr(i);
    c := getOwnControl(i);
    xmlNode.WriteAttributeString(str, c.name);
  end;
  xmlNode.WriteAttributeInteger('ProgRepeat', fRepeatCount);
  xmlNode.WriteAttributeBool('ProgStartOnPlay', m_StartOnPlay);
end;



procedure cProgramObj.LoadObjAttributes(xmlNode: txmlnode; mng: tobject);
var
  lConCount, i: integer;
  TrigsNode, trignode: txmlnode;
  str, conName: string;
  c: cControlObj;
  t: cBaseTrig;
begin
  inherited;
  fRepeatCount := xmlNode.ReadAttributeInteger('ProgRepeat', 1);
  m_StartOnPlay := xmlNode.ReadAttributeBool('ProgStartOnPlay', true);
  lConCount := xmlNode.ReadAttributeInteger('ControlCount', 0);
  // пишем используемые контролы
  for i := 0 to lConCount - 1 do
  begin
    str := 'Control' + inttostr(i);
    conName := xmlNode.ReadAttributeString(str, '');
    if conName <> '' then
    begin
      c := g_conmng.getControlObj(conName);
      if c <> nil then
      begin
        AddControl(c);
      end;
    end;
  end;
  fRepeatCount := xmlNode.ReadAttributeInteger('ProgRepeat');
  TrigsNode := xmlNode.FindNode('TrigsNode');
  if TrigsNode <> nil then
  begin
    for i := 0 to TrigsNode.NodeCount - 1 do
    begin
      //t := ReadTrig(TrigsNode, 'ActionTrig_' + inttostr(i), nil);
    end;
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


procedure cProgramObj.SetActiveMode(m: cModeObj);
var
  i: integer;
  t: cTask;
begin
  if factivemode <> nil then
  begin
    factivemode.active := false;
    for i := 0 to factivemode.TaskCount - 1 do
    begin
      t := factivemode.GetTask(i);
      //t.control.f_manualMode := false;
    end;
  end;
  if m <> nil then
    m.active := true;
  factivemode := m;
end;

procedure cProgramObj.setEnabled(d: boolean);
begin
  if d = fenabled then
    exit;
  fenabled := d;
  if m_EnableTag <> nil then
  begin
    if d then
      m_EnableTag.PushValue(1, -1)
    else
      m_EnableTag.PushValue(0, -1);
  end;
  if d = false then
  begin
    stop;
  end;
end;

procedure cProgramObj.setname(str: string);
begin
  inherited;
  fmodes.name := name + '_Режимы';
end;

procedure cProgramObj.setstate(s: integer);
var
  c: cControlObj;
  i: integer;
begin
  if not((s = c_TryStop) or (s = c_Stop)) then
  begin
    if not enabled then
      exit;
  end;
  if s = c_Pause then
  begin
    if (fstate = c_Stop) or (fstate = c_End) then
    begin
      // пауза не должна выводить из стопа
      exit;
    end;
  end;

  fstate := s;
  switchTrigs;
  case s of
    c_Play:
      begin
        StopMode := nil;
        // если первый раз стартуем программу
        if ActiveMode = nil then
        begin
          Start(true);
        end
        else
        begin
          ContinueModeT;
        end;
        for i := 0 to ControlCount - 1 do
        begin
          c := getOwnControl(i);
          //if c.fOwnerProg = nil then
          //  c.setOwnerProg(self);
        end;
      end;
    c_Stop:
      begin
        ActiveMode := StopMode;
        // сброс всех таймеров
        ResetProgT;
      end;
    c_Pause:
      begin
        ContinueModePauseT;
        if ActiveMode <> nil then
          ActiveMode.StopCheckThreshold(false);
      end;
    c_End:
      begin
        ActiveMode := nil;
      end;
  end;
  if not((s = c_Play) or (s = c_TryPlay)) then
  begin
    if s <> c_Pause then
    begin
      for i := 0 to ControlCount - 1 do
      begin
        c := getOwnControl(i);
        //if c.fOwnerProg = self then
        //  c.setOwnerProg(nil);
      end;
    end;
  end;
end;

procedure cProgramObj.Start(p_resetTime: boolean);
begin
  // c_tryplay отличается тем что сперва проверяем нужно ли сделать старт программе по триггеру
  state := c_TryPlay;
  if p_resetTime then
  begin
    fStep := 0;
    ResetModeT;
    DropModesApplyedState;
  end
  else
    ContinueModeT;
  if p_resetTime then
  begin
    if ModeCount > 0 then
    begin
      factivemode := getMode(0);
      factivemode.active := true;
    end;
    fCounter := 0;
  end;
end;

procedure cProgramObj.ShowComponent(node: pointer; component: tcomponent);
var
  vtv: TVTree;
  n, child: pVirtualNode;
  i: integer;
  c: cControlObj;
  d: pnodedata;
  str: string;
begin
  vtv := TVTree(component);
  n := pVirtualNode(node);
  d := vtv.GetNodeData(n);
  str := d.caption;
  n := vtv.AddChild(n, nil);
  d := vtv.GetNodeData(n);
  vtv.initChildNode(n);
  d.caption := 'Регуляторы';
  d.color := vtv.normalcolor;
  d.ImageIndex := c_img_Control;
  for i := 0 to ControlCount - 1 do
  begin
    c := getOwnControl(i);
    // child := vtv.AddChild(n, c);
    // fastMM выдает порчу памяти если параметр не nil. видать так нельзя данные инициализировать!!!
    // 01/10/18
    child := vtv.AddChild(n, nil);
    d := vtv.GetNodeData(child);
    d.color := vtv.normalcolor;
    d.caption := c.name;
    d.data := c;
    d.ImageIndex := c.ImageIndex;
  end;
end;

procedure cProgramObj.Start;
begin
  Start(true);
end;

procedure cProgramObj.stop;
begin
  state := c_TryStop;
  fCounter := 0;
  evalStateTag;
end;

procedure cProgramObj.switchTrigs;
var
  i: integer;
  m: cModeObj;
  play: boolean;
begin
  if (state = c_Play) then
  begin
    // if StartTrig <> nil then
    // StartTrig.enabled := false;
    // if StopTrig <> nil then
    // StopTrig.enabled := true;
    play := true;
  end
  else
  begin
    if (state = c_Stop) or (state = c_Pause) or (state = c_End) then
    begin
      // if StartTrig <> nil then
      // StartTrig.enabled := true;
      // if StopTrig <> nil then
      // StopTrig.enabled := false;
    end;
    play := false;
  end;
  for i := 0 to ModeCount - 1 do
  begin
    m := getMode(i);
    m.SwitchModeTrigs(play);
  end;
end;

procedure cProgramObj.pause;
begin
  state := c_TryPause;
end;

procedure cProgramObj.UpdateModeT;
var
  di64, i64: int64;
  dx: double;
begin
  QueryPerformanceCounter(i64);
  di64 := decI64(fModeT1, i64);
  dx := di64 / g_conmng.m_Freq;
  fProgT := fProgT + dx;
  // предусмотреть защиту от переполнения таймера
  fModeT := fModeT + dx;
  fModeT1 := i64;
end;

procedure cProgramObj.UpdateModePauseT;
var
  di64, i64: int64;
  dx: double;
begin
  QueryPerformanceCounter(i64);
  di64 := decI64(fModePauseTi, i64);
  dx := di64 / g_conmng.m_Freq;
  // предусмотреть защиту от переполнения таймера
  fModePauseT := fModePauseT + dx;
  fModePauseTi := i64;
end;

procedure cProgramObj.ResetModePauseT;
begin
  QueryPerformanceCounter(fModePauseTi);
  // предусмотреть защиту от переполнения таймера
  fModePauseT := 0;
end;

procedure cProgramObj.ContinueModePauseT;
begin
  QueryPerformanceCounter(fModePauseTi);
end;

procedure cProgramObj.ResetProgT;
begin
  fProgT := 0;
  ResetModeT;
end;

procedure cProgramObj.ResetModeT;
begin
  QueryPerformanceCounter(fModeT1);
  // предусмотреть защиту от переполнения таймера
  fModeT := 0;
  ResetModePauseT;
end;

procedure cProgramObj.ContinueModeT;
begin
  QueryPerformanceCounter(fModeT1);
end;

function cProgramObj.getstate: integer;
begin
  result := fstate;
end;

function cProgramObj.getimageindex: integer;
begin
  case state of
    c_Play:
      result := c_img_Program_play;
    c_NOTReady:
      result := c_img_Program_stop;
    c_Ready:
      result := c_img_Program;
    c_Pause:
      result := c_img_Program_pause;
  end;
end;

{ cModeObj }



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

{ cProgControlList }
constructor cProgControlList.create;
begin
  inherited;
  comparator := ControlComparator;
  destroydata := false;
end;

end.
