unit uControlObj;

interface

uses
  classes, uBaseObj, uBaseObjMng,  uRTrig, NativeXML, recorder,
  dialogs, activeX,
  sysutils, windows, uRecorderEvents, VirtualTrees, uVTServices,
  tags,
  uCommonMath,
  ucommontypes,
  pluginclass, plugin, u2dMath, uRCFunc, PathUtils,
  uPathMng,
  uEventTypes,
  uAlarms,
  uSetList,
  blaccess;

type

  TPType = (ptNullPoly, ptlinePoly, ptCubePoly);

  cControlObj = class;
  cModeObj = class;
  cProgramList = class;
  cControlList = class;
  cProgramObj = class;

  cControlMng = class(cBaseObjMng)
  private

    m_configChanged: boolean;
    // место хранения предыдущей конфигурации
    m_prevDir: string;
    fUseUpdateTagsEvent: boolean;
    fstate: integer;
    // нужно ли исполнять контролы
    fExecControls: boolean;
    //m_TagGroup: ITagsGroup;
    fStoptrig: cBaseTrig;
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
    //
  public
    // если переменная выключена то выбор редимов по клику мышью будет работать только
    // когда циклограмма на паузе
    AllowUserModeSelect: boolean;
    // частота счетчика замера времени
    m_Freq: int64;
  private

    // происходит при останове работы цыклограммы режимво
    procedure UpdateLastState;
    // сохранение состояния циклограммы режимов и конфигураций
    procedure doSaveCfg(sender: tobject);
    procedure doStopRec(sender: tobject);
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
    procedure UpdateModeTolerance;

    procedure doStartStopTrig(Start: boolean);
    procedure doUpdateTags(sender: tobject);
    procedure doChangeRState(sender: tobject);
    // Линкуем триггеры с объектами назначения
    procedure RelinkTrigsNames;
    procedure doinitMDBEvents(sender: tobject);
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
    procedure Exec;
    // выполнить шаг регуляторов
    procedure ExecControls;
    function createControl(name: string; classname: string): cControlObj;
    function createProgram(name: string; classname: string): cProgramObj;
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
    // вызывать напрямую опасно, т.к. должны использоваться флагивида c_TryStop и c_TryPlay
    // для управления режимом из потока в котором вызывается exec
    property state: integer read fstate write setstate;
    property programs: cProgramList read getprograms write fprograms;
    property controls: cControlList read fcontrols write fcontrols;
    property ConfigChanged: boolean read m_configChanged write setConfigChanged;
  end;

  cProgramList = class(cbaseobj)
  protected
    // перечитать список всех задач
    procedure DoAddTask(sender: tobject);
    procedure DoDelTask(sender: tobject);
  public
    constructor create; override;
    destructor destroy; override;
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

  pZonePair =^TZonePair;

  TZonePair = record
    tag:pointer; // ссылка на itag
    value:double;
  end;

  cZone = class
  private
    // допуск в зоне
    ftol:double;
  public
    defaultZone:boolean;
    // теги ZonePair
    tags:tlist;
    owner:tlist;
  private
  public
    procedure AddZonePair(z:TZonePair);
    procedure cleartags;
    procedure delPair(i:integer);
    function GetZonePair(i:integer):TZonePair; overload;
    function GetZonePair(str:string):TZonePair; overload;
    function propstr:string;
    constructor create (List:tlist; tol:double);
    destructor destroy;
  protected
    procedure setTol(t:double);
  public
    property tol:double read ftol write settol;
  end;

  cZoneList = class (csetlist)
  protected
    procedure deletechild(node:pointer);override;
  public
    procedure clearZones;
    function NewZone(tol:double):cZone;
    constructor create;override;
    function GetZone(i:integer):cZone;
    procedure DelZone(i:integer);
  end;

  // регулятор
  cControlObj = class(cbaseobj)
  private
    fcurPWMState:boolean; // текущее состояние ШИМ on/off
    fPWMT: double; // время в течении которого работаем на полупериоде ШИМ
    fPWMTi: int64; // счетчик времени на предыдущем цикле для расчета ШИМ
    // сохраняемые параметры
    fPWM_Toff:double; // время выключения при ШИМ
    fPWM_Ton:double; // время включения при ШИМ
    fPWM:boolean; // включение работы по ШИМ
    // программа которая в данный момент дает задание регулятору
    fOwnerProg: cProgramObj;
    // единицы в которых работает контрол
    funits: string;
    // c_NOTReady = 0;
    // c_Ready = 1;
    // c_Play = 2;
    // c_Stop = 7;
    fstate: integer;
    // на текущем шаге циклограммы пользователь вбил свое задание
    f_manualMode:boolean;
    m_feedback: itag;
    m_feedbackBlA: IBlockAccess;
    fbData: array of double;

    m_feedback_name: string;
    m_feedback_id: tagid;
    m_dtask: double;
    // обратная связь
    m_dfeedback: double;
    m_TaskApplyed: boolean;
    // состояние регулятора
    m_stateTag: itag;

    cs_state, cs: TRTLCriticalSection;
    // оценивать допуск по максимальному отклонению или по мат ожиданию
    fScalarTolerance: boolean;
    // проверяемый на допуск режим
    fCurMode: cModeObj;
    // в допуске
    fInTolerance: boolean;
    fCheckOnMode: boolean;
  public
    m_zones_enabled:boolean;
    // зоны регулирования
    m_ZoneList:cZoneList;
  protected
    Procedure StartPWM;
    Procedure StopPWM;
    Procedure UpdatePWM;

    procedure InitCS;
    procedure DeleteCS;
    procedure entercs;
    procedure exitcs;
    procedure createTags;
    // функция обработки регулятора.
    function doUpdateData(): integer; virtual;
    function getstate: integer; virtual;
    procedure setstate(s: integer); virtual;
    function getimageindex: integer; override;
    procedure setproperties(str: string); virtual; abstract;
    function getProperties: string; virtual;
    procedure setfbname(str: string);
    function getfbname: string;
    procedure setunits(str: string); virtual;
    function getunits: string; virtual;
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    // вычитать из тега обратную связь
    function getFB: double; virtual;
    procedure doRename;
    procedure setOwnerProg(p: cProgramObj);
    procedure StarCheckMode(m: cModeObj);
    procedure StopCheckMode;
    function CheckMode: boolean;
    function getInTol: boolean;
    procedure setInTol(b: boolean);
  public
    Function PlayState: boolean;
    // вазвращает состояние готов к работе
    // Feedback - канал обратной связи
    // Task - задание
    // data - специализированные настройки могут отличаться для регуляторов раздичных типов
    function config(Feedback: itag; data: tobject): boolean; virtual;
    procedure Start; virtual;
    procedure stop; virtual;
    procedure pause; virtual;
    function Exec: boolean; virtual;
    function InProgress: boolean;
    function GetCheckOnMode: boolean;
    procedure SetManualTask(t: double); virtual;
    // установить доп. свойства контрола на циклограмме.
    // вызывается в cmode.exec, параметры читаются из задачи cTask
    procedure setparams(params:TStringlist);virtual;
    procedure SetTask(t: double); virtual; abstract;
    function GetTask:double;
  public
    property CheckOnMode: boolean read GetCheckOnMode write fCheckOnMode;
    property InTolerance: boolean read getInTol write setInTol;
    // c_NOTReady = 0;
    // c_Ready = 1;
    // c_Play = 2;
    // c_Stop = 7
    // программа которая в данный момент дает задание регулятору
    property OwnerProg: cProgramObj read fOwnerProg write setOwnerProg;
    property state: integer read getstate write setstate;
    property Properties: string read getProperties write setproperties;
    property feedbackname: string read getfbname write setfbname;
    property task: double read getTask write m_dtask;
    function getTaskstr(digits: integer): string;
    property Feedback: double read getFB;
    function getFBstr: string;
    property units: string read getunits write setunits;
    constructor create; override;
    destructor destroy; override;
  end;

  cDacControl = class(cControlObj)
  private
    m_dac: itag;
  public
    m_dac_id: tagid;
    m_dac_name: string;
  protected
    function getstate: integer; override;
    function getDAC: itag;
    procedure setDAC(dac: itag);
    function getProperties: string; override;
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    function getDACname: string;
    procedure setDACname(dacname: string);
    function getDACID: tagid;
    procedure setDACID(dacname: tagid);
  public
    function TypeString: string; override;
    function Exec: boolean; override;
    procedure SetTask(t: double); override;
  public
    property dac: itag read getDAC write setDAC;
    property dacname: string read getDACname write setDACname;
    property DACID: tagid read getDACID write setDACID;
  end;

  cBaseProgramObj = class(cbaseobj)
  private
    fStartTrig: cBaseTrig;
    fStoptrig: cBaseTrig;

    cs_StartTrig: TRTLCriticalSection;
    fStartState: boolean;

    cs_StopTrig: TRTLCriticalSection;
    fStopState: boolean;

  protected
    procedure InitCS;
    procedure DeleteCS;

    procedure setStartTrig(t: cBaseTrig);
    procedure setStopTrig(t: cBaseTrig);
    // здесь по событию обновления триггера, если триггер сработал, то ставиться stateStart или StateStop в true
    // сброс в false происходит в проверке StateStart/StateTrue в Exec
    procedure doUpdateTrig(sender: tobject);
    procedure createEvents;
    procedure DestroyEvents;

    procedure setactive(b: boolean); virtual;
    function getactive: boolean; virtual;

    procedure setname(n: string); override;
  public
  public
    constructor create; override;
    destructor destroy; override;
    // property StartTrig: cBaseTrig read fStartTrig write setStartTrig;
    // property StopTrig: cBaseTrig read fStoptrig write setStopTrig;
    property active: boolean read getactive write setactive;
  end;

  // объекты программ выполняются одновременно
  cProgramObj = class(cBaseProgramObj)
  public
    // Стартовать программу при старте циклограммы режимов
    m_StartOnPlay: boolean;
    m_enableOnStart: boolean;
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

    factivemode: cModeObj;
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
    // время работы программы
    fProgT: double;
    // время на режиме
    fModeT: double;
    // время паузы на режиме
    fModePauseT: double;
    // время начала проверки выхода на режим
    fCheckStartTime: double;
    fCheckStartTime_i: int64;
    fInTolerance: boolean;
    // фактическое время проведенное в допуске при выходе на режим
    fCheckLength: double;
    // счетчик времени при выполнении посл шага паузы режима
    fModePauseTi: int64;
    // счетчик времени при выполнении посл шага программы
    fModeT1: int64;
    // значение StateTag
    m_stateTagVal: integer;
    m_stateTag,
    // номер текущего режима -1 (нет активного режима)
    m_ModeIndTag,
    // запись тега меняет состояние программы
    m_EnableTag: itag;
  protected
    procedure evalStateTag;
    procedure changeStateTag(v: integer);
    procedure AplyStateTag(v: integer);
    procedure InitCS;
    procedure DeleteCS;
    procedure entercs;
    procedure exitcs;
    function CreateStateTag: itag;
    function getactive: boolean; override;
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
    // сброс времени режима и время паузы на режиме (если время режима ноль то и паузы на нем не было)
    procedure ResetModeT;
    // продолжить отсчет времени на испытании
    procedure ContinueModeT;
    // время на режиме
    function getCheckLength: double;
    function getModePauseTime: double;
    function getModeTime: double;
    function getProgTime: double;
    procedure setname(str: string); override;
    function getimageindex: integer; override;
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
    procedure ShowComponent(node: pointer; component: tcomponent); override;
    procedure DoLincParent; override;
  public
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


  // класс описание задачи регулятору
  cTask = class
  private
    // режим состоит из запрета контролу работать (сохраняем предыдущее значение)
    fStopControlValue: boolean;
    fapplyed:boolean;
    cs: TRTLCriticalSection;
    // дополнительные параметры отправляемые по циклограмме в контрол
    fparams:string;
  public
    m_Params:TStringList;
  public
    TaskType: TPType;
    // компоненты касательных векторов
    leftTang, rightTang, point: point2;
    spline: cubicspline;
    // владелец задачи
    control: cControlObj;
    mode: cModeObj;
    // использовать значение предыдущего режима
    m_UsePrev: boolean;
    // допуск
    m_tolerance: double;
    m_useTolerance: boolean;
    // тип скомпилированного сплайна
    SplineInterp: TPType;
  protected

  protected
    function gettask: double;
    procedure SetTask(d: double);
    procedure SetStopControlValue(b: boolean);
    // задание применено
    function getApplyed: boolean;
    procedure setApplyed(b: boolean);
  public
    procedure InitCS;
    procedure DeleteCS;
    procedure exitcs;
    procedure entercs;

    property applyed:boolean read getApplyed write setApplyed;
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
    property task: double read gettask write SetTask;
    property StopControlValue: boolean read fStopControlValue write  SetStopControlValue;
  protected
    procedure setparams(str:string);
  public
    property params: string read fparams write setparams;
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
  private
    findex: integer;
    m_tryActive: boolean;
    // применен режим или нет хотя бы один раз
    m_applyed: boolean;
    fCounter: Cardinal;
    factive: boolean;
    // Время на режиме, сек
    f_ModeLength: double;
    // Cписок задач (пара: контроллер/ задание)
    TaskList: tstringlist;
    StepValsList: tstringlist;
    // проверять выход на режим. Следующий режим не начнется пока все контролу\ы не окажутся
    // в допуске fThrehold
    fCheckThrehold: boolean;
    // время проверок на допуск
    fCheckLength: double;
    // режим бесконечный - прервется по требованию пользователя или по триггеру
    fInfinity: boolean;
    // в состоянии проверок (основная часть режима окончена)
    fCheckProgres: boolean;
  protected
    procedure setindex(i: integer);
    procedure SwitchModeTrigs(b: boolean);
    function GetModeDsc: string;
    procedure SetMainParent(p: cbaseobj); override;
    function getimageindex: integer; override;
    procedure setstate(s: integer);
    function getstate: integer;
    procedure setactive(b: boolean); override;
    function getactive: boolean; override;
    procedure setModeLen(d: double);
    function getModeLen: double;
    function getmainparent: cbaseobj; override;
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    procedure CreateTasks;
    procedure setMng(m: tobject); override;
    procedure createTags;
    procedure DestroyTags;
    procedure updateTagsNames;
    procedure unLincTags;
    procedure DoLincParent; override;
    procedure StartCheckThreshold;
    // (resetCheck:boolean) - если resetCheck то fCurMode не сбрасывается
    // (сбрасываем только таймер но не останавливаем проверку)
    procedure StopCheckThreshold(resetCheck: boolean);
    function EvalThresholds: boolean;
  public
    function getNextMode: cModeObj;
    function getPrevMode: cModeObj;
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
    function getProgram: cProgramObj;
    function gettimeinterval: point2d;
    function TaskCount: integer;
    procedure clearStepVals;
    function createStepV(t: itag; v: double): cStepVal;
    procedure clearTaskList;
    // обработка списка задач, где каждая задача это регулятор с заданием
    procedure doUpdateData; virtual;
    function createTask(c: cControlObj; task: double): cTask;
      overload;
    function createTask(ControlName: string; task: double): cTask;
      overload;
    procedure editTask(c: cControlObj; task: double); overload;
    procedure editTask(ControlName: string; task: double); overload;
    function gettask(i: integer): cTask; overload;
    function gettask(ControlName: string): cTask; overload;
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

var
  g_conmng: cControlMng;

implementation

uses
  uMeasureBase, uMBaseControl;

{ cControlMng }
procedure cControlMng.regObjClasses;
begin
  regclass(cDacControl);
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
      fprograms.DoDelTask(obj);
    end;
    if fcontrols <> nil then
    begin
      fcontrols.DoDelcontrol(obj);
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
        t := m.gettask(ti);
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
  case GetRCStateChange of
    RSt_Init:
      begin
        pushControlsTags;
      end;
    RSt_StopToView:
      begin
        InitTriggers;
        doStartStopTrig(true);
        pushControlsTags;
      end;
    RSt_StopToRec:
      begin
        InitTriggers;
        doStartStopTrig(true);
        pushControlsTags;
      end;
    RSt_ViewToStop:
      begin
        doStartStopTrig(false);
      end;
    RSt_ViewToRec:
      begin
        doStartStopTrig(true);
        pushControlsTags;
      end;
    RSt_initToRec:
      begin
        doStartStopTrig(true);
        pushControlsTags;
      end;
    RSt_initToView:
      begin
        doStartStopTrig(true);
        pushControlsTags;
      end;
    RSt_RecToStop:
      begin
        doStartStopTrig(false);
      end;
    RSt_RecToView:
      begin
        doStartStopTrig(true);
        pushControlsTags;
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
    c.doRename;
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
    programs.DoAddTask(obj);
    controls.DoAddControl(obj);
    cControlObj(obj).createTags;
  end;
  if obj is cModeObj then
  begin
    cModeObj(obj).CreateTasks;
    cModeObj(obj).createTags;
  end;
end;

procedure cControlMng.doUpdateTags(sender: tobject);
begin
  //LogRecorderMessage('cControlMng.doUpdateTags_enter');
  // потенциально опасно в многопоточности (state)
  if fUseUpdateTagsEvent then
  begin
    CheckTriggers;
    // если поменялось значение тега отвечающее за состояние контрола то необходимо поменять состояние контрола
    UpdateControlState;
    // если поменялось значение тега отвечающее за состояние программы
    UpdateProgramState;
    UpdateModeTolerance;
  end;
  //LogRecorderMessage('cControlMng.doUpdateTags_exit');
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
  AddPlgEvent('cControlMng_doMDBCreate', E_MDBCreate, doinitMDBEvents);

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
  //m_TagGroup := ITagsGroup(ir.GetGroupByName(gname));
  //if m_TagGroup = nil then
  //begin
  //  m_TagGroup := ITagsGroup(ir.CreateTagsGroup(gname));
  //end;

  m_TrigAlarmHandler := cTrigsAlarmHandler.create;
  m_TrigAlarmHandler.Attach;

  createEvents;
end;

destructor cControlMng.destroy;
begin
  //m_TagGroup := nil;

  m_TrigAlarmHandler.Detach;
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

function cControlMng.createProgram(name: string;
  classname: string): cProgramObj;
begin

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
      error := obj.doUpdateData;
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

procedure cControlMng.Exec;
var
  i: integer;
  p: cProgramObj;
  bstop: boolean;
begin
  bstop := true;
  // проверяем триггеры
  ApplyActionTrigs;
  case state of
    c_TryPlay:
      state := c_Play;
    c_TryStop:
      begin
        state := c_Stop;
      end;
    c_TryPause:
      state := c_Pause;
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
            // if p.StartTrig <> nil then
            // begin

            // end;
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

procedure cControlMng.doinitMDBEvents(sender: tobject);
var
  base: TMBaseControl;
begin
  base := MBaseControl;
  if base <> nil then
  begin
    base.fOnStopRec := doStopRec;
    base.fSaveCfg := doSaveCfg;
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
  c: cControlObj;
  p: cProgramObj;
  v: double;
begin
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
    if (p.state = c_Play) or (c.state = c_TryPlay) then
    begin
      p.changeStateTag(c_Prog_PlayTag);
    end
    else
    begin
      p.changeStateTag(c_Prog_StopTag);
    end;
    if (p.state = c_Play) or (c.state = c_TryPlay) then
    begin
      p.m_ModeIndTag.PushValue(-1, -1);
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

procedure cControlMng.doStartStopTrig(Start: boolean);
var
  t: cBaseTrig;
  i: integer;
begin
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
      if t.Trigtype = trStop then
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

procedure cControlMng.doStopRec(sender: tobject);
var
  o, t, r, lastcfg: cxmlfolder;
  prop: TProp;
  b: boolean;
  cfgpath, mname: string;
  p: cProgramObj;
  i: integer;
begin
  if sender is TMBaseControl then
  begin
    o := TMBaseControl(sender).GetSelectObj;
    if o <> nil then
    begin
      t := TMBaseControl(sender).GetSelectTest;
      if t <> nil then
      begin
        lastcfg := cxmlfolder(t.getChildrenByCaption('Lastcfg'));
        if lastcfg <> nil then
        begin
          // сохранение состояния циклограммы
          for i := 0 to ProgramCount - 1 do
          begin
            p := getProgram(i);
            lastcfg.addpropertie('Pstate_' + inttostr(i),
              booltostr(p.state = c_Play));
            mname := '';
            if p.ActiveMode <> nil then
              mname := p.ActiveMode.name;
            lastcfg.addpropertie('Pmode_' + inttostr(i), mname);
            lastcfg.addpropertie('Pcounter_' + inttostr(i), inttostr(p.fStep));
          end;
        end;
      end;
    end;
  end;
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
    v := GetScalar(c.m_stateTag);
    if c.state = c_Play then
    begin
      if v < 0.5 then
      begin
        c.state := c_Stop;
      end;
    end
    else
    begin
      if v > 0.5 then
      begin
        c.state := c_Play;
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
    p.flaststate := p.state;
    p.fLastMode := '';
    if p.ActiveMode <> nil then
    begin
      p.fLastMode := p.ActiveMode.name;
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
  Tol: point2d;

  v, devtime: double;
  blCount: integer;
  inTol: boolean;
begin
  if state <> c_Play then
    exit;
  for i := 0 to ControlsCount - 1 do
  begin
    c := getControlObj(i);
    p := c.OwnerProg;
    if p <> nil then // 1
    begin
      if c.CheckOnMode then // 2
      begin
        m := c.fCurMode;
        if m <> nil then // 3
        begin
          t := m.gettask(c.name);
          v := c.fCurMode.GetTaskValue(t, 1);
          Tol.x := v - t.m_tolerance;
          Tol.y := v + t.m_tolerance;
          if c.fScalarTolerance then
          begin
            v := GetMean(c.m_feedback);
            inTol := false;
            if v > Tol.x then
            begin
              if v < Tol.y then
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
              if (v > Tol.y) or (v < Tol.x) then
              begin
                inTol := false;
                break;
              end;
            end;
          end;
          c.InTolerance := inTol;
        end; // 3
      end; // 2
    end; // 1
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
    if v=p.m_stateTagVal then
      continue;
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
        p.fenabled := false;
      end;
    end
    else
    begin
      if v > 0.5 then
      begin
        p.fenabled := true;
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
  for i := 0 to ProgramCount - 1 do
  begin
    p := getProgram(i);
    p.stop;
  end;
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
  di64,i64: int64;
begin
  QueryPerformanceCounter(i64);
  QueryPerformanceFrequency(m_Freq);
  // предусмотреть защиту от переполнения таймера
  di64:=decI64(ft64, i64);
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
        // останов регуляторов
        StopControls;
        ResetT;
        for i := 0 to ProgramCount - 1 do
        begin
          p := getProgram(i);
          p.state := c_Stop;
        end;
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

procedure cControlObj.setfbname(str: string);
var
  t: itag;
begin
  t := getTagByName(str);
  if t <> nil then
  begin
    config(t, nil);
  end
  else
    m_feedback_name := str;
end;

procedure cControlObj.setOwnerProg(p: cProgramObj);
begin
  fOwnerProg := p;
end;

function cControlObj.getFB: double;
begin
  result := 0;
  if m_feedback <> nil then
  begin
    result := m_feedback.GetEstimate(ESTIMATOR_MEAN);
  end;
end;

function cControlObj.getFBstr: string;
begin
  if m_feedback <> nil then
  begin
    result := floattostr(GetMean(m_feedback));
  end
  else
  begin
    result := 'н.г.';
  end;
end;

function cControlObj.getfbname: string;
begin
  result := m_feedback_name;
  if m_feedback <> nil then
  begin
    result := m_feedback.getname;
  end;
end;

function cControlObj.config(Feedback: itag; data: tobject): boolean;
var
  fbsize: integer;
begin
  m_feedback := Feedback;
  if Feedback = nil then
  begin
    state := c_NOTReady;
    Feedback := nil;
    m_feedback_name := '';
  end
  else
  begin
    m_feedback_name := Feedback.getname;
    Feedback.GetTagId(m_feedback_id);
    if not FAILED(Feedback.QueryInterface(IBlockAccess, m_feedbackBlA)) then
    begin
      fbsize := m_feedbackBlA.GetBlocksSize;
      SetLength(fbData, fbsize);
    end;
  end;
end;

constructor cControlObj.create;
begin
  inherited;
  InitCS;
  funits := 'б.р.';
  fScalarTolerance := true;
  m_ZoneList:=cZoneList.create;
  // дефолтная зона
  m_ZoneList.NewZone(0);
end;

destructor cControlObj.destroy;
var
  ir: irecorder;
  i: integer;
  p: cProgramObj;
begin
  if m_stateTag <> nil then
  begin
    CloseTag(m_stateTag);
    m_stateTag := nil;
  end;
  DeleteCS;
  for i := 0 to g_conmng.ProgramCount - 1 do
  begin
    p := g_conmng.getProgram(i);
    p.removeOwnControl(self);
  end;

  m_ZoneList.destroy;
  m_ZoneList:=nil;
  inherited;
end;

procedure cControlObj.createTags;
begin
  m_stateTag := CreateStateTag(name + '_state', self);
end;

procedure cControlObj.doRename;
var
  str: string;
  i, J: integer;
  p: cProgramObj;
  m: cModeObj;
begin
  str := name + '_State';
  if m_stateTag <> nil then
    m_stateTag.setname(lpcstr(StrToAnsi(str)));
  for i := 0 to g_conmng.ProgramCount - 1 do
  begin
    p := g_conmng.getProgram(i);
    for J := 0 to p.ModeCount - 1 do
    begin
      m := p.getMode(J);
      m.DoRenameControl(self);
    end;
  end;
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
  v: double;
begin
  result := (state = c_Play);
  if m_stateTag <> nil then
  begin
    v := GetScalar(m_stateTag);
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
end;

Procedure cControlObj.StartPWM;
begin
  QueryPerformanceCounter(fPWMTi);
  fPWMT:=0;
  fcurPWMState:=true;
  fPWM:=true; // выключен ШИМ
end;

Procedure cControlObj.StopPWM;
begin
  fPWM:=false; // выключен ШИМ
  fcurPWMState:=true;
end;

Procedure cControlObj.UpdatePWM;
var
  di64,i64, fr: int64;
  threshold, dt:double;
begin
  // предусмотреть защиту от переполнения таймера
  di64:=decI64(fPWMTi, i64);
  QueryPerformanceFrequency(fr);
  dt:=di64/fr;
  fPWMT:=fPWMT+dt;
  if fcurPWMState then
    threshold:=fPWM_Ton
  else
    threshold:=fPWM_Toff;
  if fPWMT>threshold then
  begin
    fcurPWMState:=not fcurPWMState;
    fPWMt:=0;
  end;
  QueryPerformanceFrequency(fPWMTi);
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

procedure cControlObj.entercs;
begin
  EnterCriticalSection(cs_state);
end;

function cControlObj.GetCheckOnMode: boolean;
var
  // p:cProgramObj;
  m: cModeObj;
  t: cTask;
begin
  result := false;
  // p:=OwnerProg;
  // if p=nil then
  // exit;
  m := fCurMode;
  if m = nil then
    exit;
  t := m.gettask(name);
  if t = nil then
    exit;
  result := t.m_useTolerance;
end;

procedure cControlObj.SetManualTask(t: double);
begin
  f_manualMode:=true;
  SetTask(t);
end;

procedure cControlObj.setparams(params:TStringlist);
var
  l_str, str:string;
  b, b1:boolean;
  i, j:integer;
  z:cZone;
  d:double;
  pair:TZonePair;
begin
  l_str:=GetParsValue(params, 'PWM_Thi');
  if l_str<>'' then
  begin
    fPWM_Ton:=strtofloat(l_str);
  end;
  l_str:=GetParsValue(params, 'PWM_Tlo');
  if l_str<>'' then
  begin
    fPWM_Toff:=strtofloat(l_str);
  end;
  l_str:=GetParsValue(params, 'PWM_state');
  if l_str<>'' then
  begin
    fPWM:=StrToBool(l_str);
  end;
  // включение работы по зонам
  l_str:=GetParsValue(params, 'Zone_state');
  if l_str<>'' then
  begin
    m_zones_enabled:=StrToBool(l_str);
    if m_zones_enabled then
    begin
      b:=true;
      i:=0;
      while b do
      begin
        l_str:=GetParsValue(params, 'Tol_'+inttostr(i));
        if l_str='' then break;
        z:=m_ZoneList.GetZone(i);
        d:=strtofloat(l_str);
        if z=nil then
          z:=m_ZoneList.NewZone(d)
        else
          z.tol:=d;
        // теги в зонах управления
        b1:=true;
        while b1 do
        begin
          l_str:='z'+inttostr(i)+'_t'+inttostr(j);
          str:=GetParsValue(params, l_str);
          if str<>'' then
          begin
            pair:=z.GetZonePair(str);
            l_str:='z'+inttostr(i)+'_tval'+inttostr(j);
            str:=GetParsValue(params, l_str);
            pair.value:=strtofloat(str);
          end
          else
            break;
        end;
      end;
    end;
  end;
end;

function cControlObj.GetTask:double;
begin
  if fPWM then
  begin
    if fcurPWMState then
      result:=m_dtask
    else
      result:=0;
  end
  else
    result:=m_dtask;
end;


procedure cControlObj.SaveObjAttributes(xmlNode: txmlnode);
var
  str: utf8string;
  z:czone;
  I, j: Integer;
  pars:tstringlist;
  pair:tzonepair;
begin
  inherited;
  str := feedbackname;
  xmlNode.WriteAttributeString('FeedBackName', str);
  xmlNode.WriteAttributeBool('PWMMode', fPWM);
  xmlNode.WriteAttributeFloat('PWM_T_ON', fPWM_Ton);
  xmlNode.WriteAttributeFloat('PWM_T_OFF', fPWM_Toff);
  xmlNode.WriteAttributeInteger('ZoneCount', m_ZoneList.Count);
  xmlNode.WriteAttributeBool('Zones_Enabled', m_zones_enabled);
  begin
    pars:=tstringlist.Create;
    for I := 0 to m_ZoneList.Count - 1 do
    begin
      z:=m_ZoneList.GetZone(i);
      addParam(pars, 'Tol', floattostr(z.tol));
      addParam(pars, 'tCount', inttostr(z.tags.Count));
      for j := 0 to z.tags.Count - 1 do
      begin
        pair:=z.GetZonePair(j);
        addParam(pars, 't'+inttostr(j), itag(pair.tag).GetName);
        addParam(pars, 'tVal'+inttostr(j), floattostr(pair.value));
      end;
      xmlNode.WriteAttributeString('Z'+inttostr(i), ParsToStr(pars));
    end;
    delpars(pars);
  end;
  // xmlNode.WriteAttributeBool('CheckOnMode', CheckOnMode);
end;

procedure cControlObj.LoadObjAttributes(xmlNode: txmlnode; mng: tobject);
var
  zCount:integer;
  pars:tstringlist;
  z:czone;
  pair:TZonePair;
  i, j, c:integer;
  str:string;
  d:double;
begin
  inherited;
  feedbackname := xmlNode.ReadAttributeString('FeedBackName', '');
  // CheckOnMode := xmlNode.ReadAttributeBool('CheckOnMode', false);
  fPWM:=xmlNode.ReadAttributeBool('PWMMode', false);
  fPWM_Ton:=xmlNode.ReadAttributeFloat('PWM_T_ON', 0);
  fPWM_Toff:=xmlNode.ReadAttributeFloat('PWM_T_OFF', 0);
  zCount:=xmlNode.ReadAttributeInteger('ZoneCount', 1);
  m_zones_enabled:=xmlNode.ReadAttributeBool('Zones_Enabled', false);
  i:=0;
  m_ZoneList.clearZones;
  while zCount>0 do
  begin
    str:=xmlNode.ReadAttributeString('z'+inttostr(i), '');
    pars:=ParsStrParam(str,',');
    d:=strtofloat(GetParsValue(pars, 'Tol'));
    if d=0 then
    begin
      z:=m_ZoneList.GetZone(0);
    end
    else
    begin
      z:=m_ZoneList.NewZone(d);
    end;
    c:=strtoint(GetParsValue(pars, 'tCount'));
    for j := 0 to c - 1 do
    begin
      str:=GetParsValue(pars, 't'+inttostr(j));
      pair.tag:=pointer(getTagByName(str));
      str:=GetParsValue(pars, 'tVal'+inttostr(j));
      pair.value:=strtofloat(str);
      z.AddZonePair(pair);
    end;
    dec(zCount);
    inc(i);
    delpars(pars);
  end;
end;

function cControlObj.getProperties: string;
begin
  result := c_feedback_str + feedbackname + ';';
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
    if fCurMode <> nil then
      result := true;
  end;
end;

function cControlObj.getTaskstr(digits: integer): string;
begin
  result := format('%.*g', [digits, task]);
end;

function cControlObj.getunits: string;
begin
  if m_feedback <> nil then
  begin
    result := GetTagUnits(m_feedback);
  end
  else
  begin
    result := funits;
  end;
end;

procedure cControlObj.setunits(str: string);
begin
  funits := str;
  if m_feedback <> nil then
  begin
    SetTagUnits(m_feedback, str);
  end;
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
    m_stateTag.PushValue(1, -1)
  else
    m_stateTag.PushValue(0, -1);
end;

procedure cControlObj.StarCheckMode(m: cModeObj);
begin
  fCurMode := m;
end;

procedure cControlObj.StopCheckMode;
begin

  fCurMode := nil;
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
  StartPWM;
end;

procedure cControlObj.stop;
begin
  state := c_Stop;
  StopPWM;
end;

Function cControlObj.PlayState: boolean;
begin
  if fstate = c_Play then
    result := true
  else
    result := false;
end;

{ cProgramObj }
procedure cProgramObj.changeStateTag(v: integer);
begin
  if v <> m_stateTagVal then
  begin
    m_stateTagVal := v;
    m_stateTag.PushValue(v, -1);
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

constructor cProgramObj.create;
begin
  inherited;
  enabled := true;
  m_enableOnStart := true;
  m_applyModeStateTag := false;
  fmodes := cbaseobj.create;
  fmodes.destroydata:=true;
  fmodes.autocreate := true;
  fmodes.fHelper := true;
  fmodes.name := name + '_Режимы';
  fmodes.childrens.comparator := ModeCompare;
  fmodes.childrens.Sorted := true;

  fcontrols := tstringlist.create;
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
  fcontrols.Clear;
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
begin
  if fcontrols.Find(cname, i) then
  begin
    fcontrols.Delete(i);
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
begin
  result:= nil;
  if fcontrols.Find(name, i) then
    result := getOwnControl(i);
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
begin
  m_stateTag := uRCFunc.CreateStateTag(name + '_State', self);
  m_EnableTag := uRCFunc.CreateStateTag(name + '_Enable', self);
  m_ModeIndTag := uRCFunc.CreateStateTag(name + '_ModeIndTag', self);
  result := m_stateTag;
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
  ct: ctag;
begin
  child := node.NodeNew(key);
  if t.m_actions <> nil then
  begin
    actions := child.NodeNew('Actions');
    for i := 0 to t.m_actions.Count - 1 do
    begin
      ActNode := actions.NodeNew('Act_' + inttostr(i));
      act := TTrigAction(t.m_actions.Items[i]);
      if act.m_target <> nil then
        ActNode.WriteAttributeString('TargetName', cbaseobj(act.m_target).name)
      else
        ActNode.WriteAttributeString('TargetName', act.targetname);
      ActNode.WriteAttributeinteger('ActionType', act.opertype);
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
  child.WriteAttributeinteger('Type', TrigTypeToInt(t.Trigtype));
  child.WriteAttributeBool('Inverse', t.Inverse);
  child.WriteAttributeBool('EnableOnStart', t.m_enableOnStart);
  child.WriteAttributeBool('DisableOnApply', t.m_DisableOnApply);
  if t is crtrig then
  begin
    child.WriteAttributeString('Trigname', crtrig(t).channame, '');
    child.WriteAttributeFloat('Threshold', crtrig(t).Threshold);
  end
  else
  begin
    if t is cTimeTrig then
    begin
      child.WriteAttributeinteger('dueTime', cTimeTrig(t).dueTime);
    end
    else
    begin
      if t is cAlarmTrig then
      begin
        saveTag(cAlarmTrig(t).tag, child);
      end;
    end;
  end;

  child.WriteAttributeinteger('OrCount', t.m_orTrigs.Count);
  for i := 0 to t.m_orTrigs.Count - 1 do
  begin
    childTrig := cBaseTrig(t.m_orTrigs.Objects[i]);
    writeTrig(child, key + '_or_' + inttostr(i), childTrig);
  end;
  child.WriteAttributeinteger('AndCount', t.m_AndTrigs.Count);
  for i := 0 to t.m_AndTrigs.Count - 1 do
  begin
    childTrig := cBaseTrig(t.m_AndTrigs.Objects[i]);
    writeTrig(child, key + '_and_' + inttostr(i), childTrig);
  end;

  child.WriteAttributeinteger('ChildCount', t.ChildCount);
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
  xmlNode.WriteAttributeinteger('ControlCount', ControlCount);
  // пишем используемые контролы
  for i := 0 to ControlCount - 1 do
  begin
    str := 'Control' + inttostr(i);
    c := getOwnControl(i);
    xmlNode.WriteAttributeString(str, c.name);
  end;
  xmlNode.WriteAttributeinteger('ProgRepeat', fRepeatCount);
  xmlNode.WriteAttributeBool('ProgStartOnPlay', m_StartOnPlay);

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
  ct: ctag;
  b:boolean;
begin
  b:=false;
  for j := 0 to node.NodeCount - 1 do
  begin
    child:=node.Nodes[j];
    if child.name=key then
    begin
      b:=true;
      break;
    end;
  end;
  if not b then
    child:=nil;
  //child := node.FindNode(key);
  result := nil;
  if child <> nil then
  begin
    i := InttoTrigtype(child.ReadAttributeinteger('Type', 0));
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
      crtrig(t).Threshold := child.ReadAttributeFloat('Threshold', 0.5);
    end
    else
    begin
      if t is crtrig then
      begin
        cTimeTrig(t).dueTime := child.ReadAttributeinteger('dueTime', 0);
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
        act.opertype := ActNode.ReadAttributeinteger('ActionType', -1);
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
          act.mdbtag:=ct.tag;
          ct.destroy;
          ct := nil;
        end;
        t.addAction(act);
      end;
    end;

    ChildCount := child.ReadAttributeinteger('OrCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_or_' + inttostr(J), p);
      t.addOrTrig(childTrig);
    end;
    ChildCount := child.ReadAttributeinteger('AndCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_and_' + inttostr(J), p);
      //if childTrig.name<>'Trig_m02' then
        t.addAndTrig(childTrig)
      //else
      //  childTrig.destroy;
    end;

    ChildCount := child.ReadAttributeinteger('ChildCount', 0);
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
      //if i<1 then
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
  TrigsNode := node.NodeNew('TrigsNode');
  // пишем триггеры с списком действий
  actTrigCount := 0;
  for i := 0 to TrigCount - 1 do
  begin
    t := getTrig(i);
    if t.m_actions <> nil then
    begin
      if t.owner=nil then
      begin
        writeTrig(TrigsNode, 'ActionTrig_' + inttostr(actTrigCount), t);
        inc(actTrigCount);
      end;
    end;
  end;
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
  fRepeatCount := xmlNode.ReadAttributeinteger('ProgRepeat', 1);
  m_StartOnPlay := xmlNode.ReadAttributeBool('ProgStartOnPlay', true);
  lConCount := xmlNode.ReadAttributeinteger('ControlCount', 0);
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

  fRepeatCount := xmlNode.ReadAttributeinteger('ProgRepeat');
  // StartTrig := ReadTrig(xmlNode, 'StartTrig', self);
  // StopTrig := ReadTrig(xmlNode, 'StopTrig', self);

  TrigsNode := xmlNode.FindNode('TrigsNode');
  if TrigsNode <> nil then
  begin
    for i := 0 to TrigsNode.NodeCount - 1 do
    begin
      t := ReadTrig(TrigsNode, 'ActionTrig_' + inttostr(i), nil);
    end;
  end;
end;

procedure cProgramObj.SetActiveMode(m: cModeObj);
var
  i:integer;
  t:ctask;
begin
  if factivemode <> nil then
  begin
    factivemode.active := false;
    for I := 0 to factivemode.TaskCount - 1 do
    begin
      t:=factivemode.gettask(i);
      t.control.f_manualMode:=false;
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
  if s=c_pause then
  begin
    if (fstate=c_stop) or (fstate=c_end) then
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
          if c.fOwnerProg = nil then
            c.fOwnerProg := self;
        end;
      end;
    c_Stop:
      begin
        ActiveMode := nil;
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
        if c.fOwnerProg = self then
          c.fOwnerProg := nil;
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
  di64:=decI64(fModeT1,i64);
  dx := di64 / g_conmng.m_Freq;
  fProgT := fProgT + dx;
  // предусмотреть защиту от переполнения таймера
  fModeT := fModeT + dx;
  fModeT1 := i64;
end;

procedure cProgramObj.UpdateModePauseT;
var
  di64,i64: int64;
  dx: double;
begin
  QueryPerformanceCounter(i64);
  di64:=decI64(fModePauseTi, i64);
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
    result := gettask(i);
    result.control := c;
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
    p := getProgram;
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
  refCount:integer;
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
    t := gettask(i);
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
    c := gettask(i).control;
    if not resetCheck then
    begin
      if c.fCurMode = self then
      begin
        c.StopCheckMode;
      end;
    end;
  end;
  p := getProgram;
  p.ResetModeCheckTime;
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
    c := gettask(i).control;
    c.StarCheckMode(self);
  end;
  p := getProgram;
  p.ResetModeCheckTime;
  fCheckProgres := true;
end;

function cModeObj.EvalThresholds: boolean;
var
  i: integer;
  c: cControlObj;
  p: cProgramObj;
  res: boolean;
  di64,t64, freq: int64;
begin
  res := true;
  for i := 0 to TaskList.Count - 1 do
  begin
    c := gettask(i).control;
    res := c.CheckMode;
    if not res then
    begin
      break;
    end;
  end;
  result := res;
  p := getProgram;
  QueryPerformanceCounter(t64);
  if res then
  begin
    QueryPerformanceFrequency(freq);
    di64:=decI64(p.fCheckStartTime_i,t64);
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
    t := gettask(i);
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
  t := gettask(ControlName);
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
  p := getProgram;
  for i := 0 to TaskCount - 1 do
  begin
    t := gettask(i);
    // программа может влиять только на те контролы которые заняты программой
    if t.control.OwnerProg <> p then
      continue;
    if t.StopControlValue then
    begin
      t.control.state := c_Stop;
    end
    else
    begin
      nextT := t.getNextTask;
      if t.SplineInterp = ptNullPoly then
      begin
        if (not m_applyed) or (not t.applyed) then
        begin
          c := t.control;
          if not c.f_manualMode then
          begin
            t.entercs;
            c.SetTask(t.gettask);
            t.applyed:=true;
            t.exitcs;
          end;
        end;
      end
      else
      begin
        c := t.control;
        x := p.getModeTime / ModeLength;
        v := GetTaskValue(t, x);
        c.SetTask(v);
      end;
    end;
    c.setparams(t.m_params);
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

function cModeObj.gettask(i: integer): cTask;
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
  TaskList.Clear;
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
  StepValsList.Clear;
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
  StepValsList.Clear;
end;

procedure cModeObj.DelTask(i: integer);
var
  t: cTask;
begin
  t := gettask(i);
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
    m_stateTag.PushValue(0, -1);
  end;
  p := cProgramObj(getmainparent);
  m_applyed := false;
  if not active then
  begin
    for i := 0 to p.ModeCount - 1 do
    begin
      m := p.getMode(i);
      if m.active then
      begin
        m.factive := false;
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
  p := getProgram;
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

function cModeObj.gettask(ControlName: string): cTask;
var
  i: integer;
  t: cTask;
begin
  result := nil;
  if TaskList.Find(ControlName, i) then
    result := gettask(i);
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
      result := t.gettask;
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
  t := gettask(c.name);
  result := GetTaskValue(t, x);
end;

function cModeObj.gettimeinterval: point2d;
var
  p: cProgramObj;
  i: integer;
  m: cModeObj;
  t: double;
begin
  p := getProgram;
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
  tname: string;
  val: double;
  s: cStepVal;
begin
  inherited;
  ModeLength := xmlNode.ReadAttributeFloat('Length', 0);
  CheckLength := xmlNode.ReadAttributeFloat('CheckLength', 0);
  CheckThreshold := xmlNode.ReadAttributeBool('CheckThreshold', false);
  Infinity := xmlNode.ReadAttributeBool('Infinity', false);

  // StopTrig := ReadTrig(xmlNode, 'NextModeTrig', self);
  // StartTrig := ReadTrig(xmlNode, 'StartModeTrig', self);

  TaskNode := xmlNode.NodeByName('TaskList');
  if TaskNode <> nil then
  begin
    lTaskCount := TaskNode.ReadAttributeinteger('NCount', 0);
    for i := 0 to lTaskCount - 1 do
    begin
      n := TaskNode.NodeByName('T' + inttostr(i));
      if n <> nil then
      begin
        tname := n.ReadAttributeString('TaskName', '');
        val := n.ReadAttributeFloat('TaskVal', 0);
        editTask(tname, val);
        t := gettask(tname);
        t.m_tolerance := n.ReadAttributeFloat('Tolerance', 0);
        t.m_useTolerance := n.ReadAttributeBool('UseTolerance', false);
        if t <> nil then
        begin
          t.task := val;
          t.TaskType := IntToTPType(n.ReadAttributeinteger('TaskType', 0));
          t.leftTang.x := n.ReadAttributeFloat('LeftTangX', 0);
          t.leftTang.y := n.ReadAttributeFloat('LeftTangY', 0);
          t.rightTang.x := n.ReadAttributeFloat('RightTangX', 0);
          t.rightTang.y := n.ReadAttributeFloat('RightTangY', 0);
          // t.point.x:=n.ReadAttributeFloat('PointX', 0);
          // t.point.y:=n.ReadAttributeFloat('PointY', 0);
        end;
      end;
    end;
  end;
  stepsNode := xmlNode.NodeByName('StepList');
  if stepsNode <> nil then
  begin
    lTaskCount := stepsNode.ReadAttributeinteger('NCount', stepValCount);
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
begin
  inherited;
  xmlNode.WriteAttributeFloat('Length', ModeLength);
  xmlNode.WriteAttributeFloat('CheckLength', CheckLength);
  xmlNode.WriteAttributeBool('CheckThreshold', CheckThreshold);
  xmlNode.WriteAttributeBool('Infinity', Infinity);
  TaskNode := xmlNode.NodeNew('TaskList');
  TaskNode.WriteAttributeFloat('NCount', TaskCount);
  for i := 0 to TaskCount - 1 do
  begin
    t := gettask(i);
    n := TaskNode.NodeNew('T' + inttostr(i));
    n.WriteAttributeString('TaskName', t.control.name);
    n.WriteAttributeFloat('TaskVal', t.gettask);
    n.WriteAttributeFloat('Tolerance', t.m_tolerance);
    n.WriteAttributeBool('UseTolerance', t.m_useTolerance);

    n.WriteAttributeinteger('TaskType', TPTypeToInt(t.TaskType));
    n.WriteAttributeFloat('LeftTangX', t.leftTang.x);
    n.WriteAttributeFloat('LeftTangY', t.leftTang.y);
    n.WriteAttributeFloat('RightTangX', t.rightTang.x);
    n.WriteAttributeFloat('RightTangY', t.rightTang.y);
  end;
  stepsNode := xmlNode.NodeNew('StepList');
  stepsNode.WriteAttributeFloat('NCount', stepValCount);
  for i := 0 to stepValCount - 1 do
  begin
    s := getstepval(i);
    n := TaskNode.NodeNew('Step' + inttostr(i));
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

function cModeObj.getProgram: cProgramObj;
begin
  result := cProgramObj(getmainparent);
end;

function cModeObj.getmainparent: cbaseobj;
begin
  if parent <> nil then
  begin
    result := parent.parent;
  end;
end;

procedure cModeObj.doUpdateData;
var
  i: integer;
  t: cTask;
  c: cControlObj;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    t := gettask(i);
    c := t.control;
    c.m_TaskApplyed := false;
    c.SetTask(t.task);
  end;
  incCounter(fCounter);
end;

{ cDacControl }
function cDacControl.Exec: boolean;
begin
  result := inherited;
  if result then // в состоянии Play
  begin
    if not m_TaskApplyed then
    begin
      m_TaskApplyed := true;
      m_dac.PushValue(task, -1);
    end;
    if m_feedback <> nil then
      m_dfeedback := GetMean(m_feedback);
  end;
end;

function cDacControl.getDAC: itag;
begin
  result := m_dac;
end;

function cDacControl.getDACID: tagid;
begin
  result := m_dac_id;
end;

procedure cDacControl.setDACID(dacname: tagid);
var
  t: itag;
begin
  t := GetTagById(dacname);
  if t <> nil then
  begin
    dac := t;
  end
  else
    m_dac_id := dacname;
end;

function cDacControl.getProperties: string;
begin
  result := inherited;
  result := result + c_DAC_str + getDACname + ';';
end;

procedure cDacControl.LoadObjAttributes(xmlNode: txmlnode; mng: tobject);
var
  int: tagid;
begin
  inherited;
  dacname := xmlNode.ReadAttributeString('DACName', '');
  int := xmlNode.ReadAttributeint64('DACID', 0);
  DACID := int;
end;

procedure cDacControl.SaveObjAttributes(xmlNode: txmlnode);
var
  str: utf8string;
begin
  inherited;
  str := dacname;
  xmlNode.WriteAttributeString('DACName', str);
  xmlNode.WriteAttributeInt64('DACID', DACID);
end;

procedure cDacControl.setDAC(dac: itag);
var
  str: string;
begin
  if m_dac <> nil then
  begin
    AddTagProp(m_dac, c_TagProp_nullpoly, '0');
  end;
  m_dac := dac;
  if m_dac <> nil then
  begin
    AddTagProp(m_dac, c_TagProp_nullpoly, '1');
  end;

  if m_dac <> nil then
  begin
    str := m_dac.getname;
    m_dac_name := str;
    m_dac.GetTagId(m_dac_id);
  end
  else
  begin
    str := '';
    m_dac_name := '';
    m_dac_id := -1; ;
  end;
end;

function cDacControl.getDACname: string;
begin
  result := m_dac_name;
end;

procedure cDacControl.setDACname(dacname: string);
var
  t: itag;
begin
  t := getTagByName(dacname);
  if t <> nil then
  begin
    dac := t;
  end
  else
    m_dac_name := dacname;
end;

function cDacControl.getstate: integer;
begin
  result := inherited;
  if result <> c_NOTReady then
  begin
    if dac = nil then
    begin
      result := c_NOTReady;
    end;
  end;
end;

procedure cDacControl.SetTask(t: double);
begin
  m_TaskApplyed := false;
  m_dtask := t;
end;


function cDacControl.TypeString: string;
begin
  result := c_DAC_Typestring;
end;

{ cBaseProgramObj }

procedure cBaseProgramObj.InitCS;
begin
  InitializeCriticalSection(cs_StartTrig);
  InitializeCriticalSection(cs_StopTrig);
end;

procedure cBaseProgramObj.DeleteCS;
begin
  DeleteCriticalSection(cs_StartTrig);
  DeleteCriticalSection(cs_StopTrig);
end;

destructor cBaseProgramObj.destroy;
begin
  DestroyEvents;
  DeleteCS;
  inherited;
end;

constructor cBaseProgramObj.create;
begin
  inherited;
  createEvents;
  InitCS;
end;

procedure cBaseProgramObj.DestroyEvents;
begin
  if g_conmng.Events <> nil then
  begin
    g_conmng.Events.removeEvent(doUpdateTrig, E_OnUpdateTrig);
  end;
end;

procedure cBaseProgramObj.createEvents;
begin
  g_conmng.Events.AddEvent('cBaseProgramObj_doUpdateTrig', E_OnUpdateTrig,
    doUpdateTrig);
end;

// здесь по событию обновления триггера, если триггер сработал, то ставиться stateStart или StateStop в true
// сброс в false происходит в проверке StateStart/StateTrue в Exec
procedure cBaseProgramObj.doUpdateTrig(sender: tobject);
begin
  if sender is crtrig then
  begin
    if sender = fStartTrig then
    begin

    end;
    if sender = fStoptrig then
    begin

    end;
  end;
end;

function cBaseProgramObj.getactive: boolean;
begin

end;

procedure cBaseProgramObj.setactive(b: boolean);
begin

end;

procedure cBaseProgramObj.setname(n: string);
begin
  inherited;
  if isValue(n) then
  begin
    caption := n;
    if self is cProgramObj then
    begin
      fname := 'p' + n;
    end;
    if self is cModeObj then
    begin
      fname := 'm' + n;
    end;
  end;
end;

procedure cBaseProgramObj.setStartTrig(t: cBaseTrig);
begin
  if fStartTrig <> nil then
  begin
    if fStartTrig.owner = self then
    begin
      fStartTrig.destroy;
    end;
  end;
  fStartTrig := t;
  g_conmng.addtrig(t);
end;

procedure cBaseProgramObj.setStopTrig(t: cBaseTrig);
begin
  if fStoptrig <> nil then
  begin
    if fStartTrig.owner = self then
    begin
      fStoptrig.destroy;
    end;
  end;
  fStoptrig := t;
  g_conmng.addtrig(t);
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

{ cTask }
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

constructor cTask.create;
begin
  TaskType := ptNullPoly;
  initcs;
  m_Params:=TStringList.Create;
end;

destructor cTask.destroy;
begin
  DeleteCS;
  m_Params.Destroy;
  m_Params:=nil;
end;


function cTask.getApplyed: boolean;
begin
  result:=fapplyed;
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
    result := m.gettask(control.name);
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
    result := m.gettask(control.name);
  end
end;

function cTask.getPrevValue: double;
var
  p: cProgramObj;
  i: integer;
  m, prev: cModeObj;
begin
  p := cProgramObj(mode.getmainparent);
  for i := 0 to p.ModeCount - 1 do
  begin
    m := p.getMode(i);
    if m = mode then
    begin
      if i > 0 then
      begin
        prev := p.getMode(i - 1);
      end
      else
        prev := nil;
      break;
    end;
  end;
  if prev <> nil then
  begin
    result := prev.gettask(control.name).task;
  end
  else
  begin
    result := point.y;
  end;
end;

function cTask.gettask: double;
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

procedure cTask.setparams(str:string);
begin
  if m_Params.Count>0 then
  begin
    // очистка парсера
    ClearParsResult(m_Params);
  end;
  if str<>'' then
    updateParams(m_params, str, ',');
end;

procedure cTask.SetTask(d: double);
begin
  point.y := d;
end;

function cTask.getunits: string;
var
  units: string;
begin
  units := '';
  if control <> nil then
  begin
    if control.m_feedback <> nil then
    begin
      units := GetTagUnits(control.m_feedback);
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
  fapplyed:=b;
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

{ cControlList }
constructor cControlList.create;
begin
  inherited;
  destroydata:=true;
  fHelper := true;
  // опасно ставить True кт.к. будет разрушен и не восстановлен при загрузке
  autocreate := true;
  blocked := true;
end;

destructor cControlList.destroy;
var
  mng: cControlMng;
begin
  mng := cControlMng(getmng());
  mng.controls := nil;
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

{ cZone }

procedure cZone.cleartags;
begin
  while tags.Count<>0 do
  begin
    delpair(0);
  end;
end;

procedure cZone.setTol(t:double);
begin
  if defaultZone then
    exit
  else
    ftol:=t;
end;

function cZone.propstr:string;
var
  t:double;
begin
  t:=tol;
  if t>0 then
    result:='+'+FloatToStr(tol)
  else
  begin
    if t<0 then
      result:=FloatToStr(tol)
    else
      result:='0';
  end;
end;

constructor cZone.create(list:tlist; tol:double);
begin
  ftol:=tol;
  tags:=tlist.create;
  owner:=list;
  csetlist(owner).AddObj(self);
  if owner.count=1 then
  begin
    defaultzone:=true;
  end
  else
  begin
    defaultzone:=false;
  end;
end;

destructor cZone.destroy;
begin
  owner.Remove(self);
  cleartags;
  tags.destroy;
  tags:=nil;
end;

procedure cZone.AddZonePair(z: TZonePair);
var
  p:pZonePair;
begin
  getmem(p,sizeof(TZonePair));
  p.tag:=z.tag;
  p.value:=z.value;
  tags.Add(p);
end;


function cZone.GetZonePair(i:integer): TZonePair;
begin
  result:=TZonePair(tags.items[i]^);
end;

function cZone.GetZonePair(str:string):TZonePair;
var
  i:integer;
  zp:tZonePair;
begin
  result.tag:=nil;
  result.value:=-1;
  for I := 0 to tags.Count - 1 do
  begin
    zp:=GetZonePair(i);
    if itag(zp.tag).GetName=str then
    begin
      result:=zp;
      exit;
    end;
  end;
end;

procedure cZone.delPair(i: integer);
var
  p:pointer;
begin
  p:=tags.items[i];
  FreeMem(p, sizeof(TZonePair));
  tags.Delete(i);
end;


{ cZoneList }
function ZoneComparator(p1,p2:pointer):integer;
begin
  if cZone(p1^).tol>cZone(p2^).tol then
  begin
    result:=1;
  end
  else
  begin
    if cZone(p1^).tol<cZone(p2^).tol then
    begin
      result:=-1;
    end
    else

    begin
      result:=0;
    end;
  end;
end;


constructor cZoneList.create;
begin
  inherited;
  comparator:=ZoneComparator;
  destroydata:=true;
end;

procedure cZoneList.deletechild(node: pointer);
begin
  inherited;
  czone(node).destroy;
end;

procedure cZoneList.clearZones;
var
  z:czone;
begin
  while count>1 do
  begin
    z:=GetZone(0);
    if not z.defaultZone then
      z.destroy
    else
    begin
      z:=getzone(count-1);
      z.destroy;
    end;
  end;
end;

function cZoneList.NewZone(tol:double):cZone;
begin
  // добавление в список происходит внутри конструктора
  result:=cZone.create(self, tol);
end;

procedure cZoneList.DelZone(i: integer);
var
  z:czone;
begin
  z:=getzone(i);
  z.destroy;
end;

function cZoneList.GetZone(i: integer): cZone;
begin
  Result:=cZone(items[i]);
end;

end.
