unit uWPproc;

interface

uses
  Windows, sysutils, ActiveX, Classes, ComObj, StdVcl,
  uBaseObjService, variants,
  Winpos_ole_TLB, POSBase, graphics, Forms, uBaseObj, uBaseObjMng, NativeXML,
  uEventList, dialogs, uCommonMath,
  uCommonTypes, uWPProcServices, uLogFile, uSetList, inifiles, mathfunction,
  uWPEvents, uWPOpers, Messages, uWPServices,
  math;

type
  TUnits = (u_Abs, u_percent, u_10Lg, u_20Lg);

  tgraphstruct = record
    hpage, hgraph, haxis, hline: integer;
  end;

  TProcessEvent = function(Sender: TObject;
    process: integer): integer of object;

  TInFoEvent = procedure(Sender: TObject; dsc: string) of object;

  cWPAxis = class;
  cSrc = class;
  cWPObj = class;
  cWPSignal = class;
  cWPGraph = class;
  cOperObj = class;
  cWPObjMng = class;

  cTubeID = class
  public
    hgraph, l, ll, h, hh, p: integer;
  end;

  cTrig = class(cBaseObj)
  public
    // ���������� ��� ������� ��������������� �������
    // ��������� ��������
    x: double;
  private
    // ������� ������
    fsuccess: boolean;
    // ���������� ���������� ��� ���������� ���������� ������ ���������
    fgroupSuccess: boolean;
    fGroupNumber: integer;
    // ��������� ����������� ����� ��� ��������� ������� ��������. ���� ������� ������ ��� ������, �� ���� ��� ��� ������ �������,
    // ����� ��������� ������ �� ����� ������������ ����� �������� ����� � ����������� ������
    fLastX: double;
    // ������������ ����� ������ ������ ���������
    fgroupMaxX: double;
    // ������� ������ ��� ����� ���������. ���� ������� ������� �� ��� ��������� ������ ���������
    // � ������� ����� ������ ��� ����� ���������
    // c_Trig_Search = 0;
    // c_Trig_Start = 1;
    // c_Trig_Stop = 2;
    // c_Trig_User = 3;
    ftrigtype: integer;
    fSearchIntervalT1: cTrig;
  public
    processed: boolean;
    id: string;
    // ��������� ������� ����������� �� X
    Threshold, shift: double;
    // � ����� ������� ������ �����
    Front: boolean;
    // ��� ������ ��������
    TrigName: string;
    // ������� ��� �������� ������ ����������� �����
    m_helpChannel:boolean;
    // ID ��������� ��������
    fsrcID: integer;
    // ����� ������������
    number: integer;
    // ������ ��������� (���������� �������� ����� ���������� ������ ���������)
    list: tstringlist;
    // ��������� ������������
    lastid: integer;
    // ���� ��������� ������� ������ ���������
    m_groupprocessed: boolean;
    // ���� ����� ������������ ��� ������ ���������
    m_FindGroup: boolean;
    // ������������ ��� ������
    units: TUnits;
    // �������� ������ ��������
    // ����� �������� ������ ��������� � ��������. 0 - ������� �� �������, ������� ������������ ��������
    XIntervalType: integer;

    extremumType: integer;
    fSearchIntervalType: integer;

    fSearchInterval: point2d;
    SearchIntervalT2: cTrig;
    SearchIntervalT1name, SearchIntervalT2name: string;

    // ��������� ����������
    m_fltTrend: boolean;
    m_fltTrendPoints: integer;
    m_fltHPF, m_fltLPF: boolean;
    m_fltHPFOrder, m_fltLPFOrder: integer;
    m_fltH2: boolean;
    m_fltH2Npoints: integer;
    // ���� -1 �� ��� �����������������
    m_fltResample: integer;
  private
    procedure SetSrcID(id: integer);
    function getsrcid: integer;
  protected
    procedure DoLincParent; override;
  public
    function GetSignal: cWPSignal;
    // ��������� ���������� (������ ��� c_Trig_User)
    procedure SetX(lx: double);
    // ���������� ��������� �������� ���� ��������
    function GetTypeString: string;
    // ���������� �������� ������ � ���������� ���������
    function GetAbsoluteValue(s: iwpsignal): double;
    function GenID: string;
    // cb - callback ��� ����������� ������� ������ �������� (�� ������ ���� ����� ����)
    function GetTime(var error: boolean; src: cSrc; start, finish: double;
      cb: TProcessEvent): double; overload;
    function GetTime(src:csrc): double; overload;
    function GetTime: double; overload;
    Function Compare(t: cTrig): boolean;
    property srcid: integer read getsrcid write SetSrcID;
    // ����������� ���������� ��������
    function isGroup: boolean;
    // ��� �������� � ������ ������� � ���������
    function GroupSuccess: boolean;
  protected
    function GetSearchIntervalType: integer;
    function GetSearchIntervalT1: cTrig;
    procedure SetSearchIntervalType(t: integer);
    procedure Settrigtype(t: integer);
    function GetSearchInterval: point2d;
  public
    property success: boolean read fsuccess write fsuccess;
    property trigtype: integer read ftrigtype write Settrigtype;
    property SearchIntervalType: integer read GetSearchIntervalType write
      SetSearchIntervalType;
    property SearchIntervalT1
      : cTrig read GetSearchIntervalT1 write fSearchIntervalT1;
    property SearchInterval: point2d read GetSearchInterval;
    constructor create; override;
  end;

  cWPTube = class
  public
    XAxis:integer;
  protected
    // ������ ��������
    //sig: cWPSignal;
    // ��� ���� 'E:\mera\�� ����\1203\280613\signal0436\3- 1.tuf'
    fname: string;
    path: string;
    pr, l, ll, h, hh: array of point2d;
    n_pr, n_l, n_ll, n_h, n_hh: iwpnode;
    // ��������� ������ cTubeID
    tubelist: tstringlist;
    // ���� � ����� � ������ ������
    folder: string;
  protected
    function getname: string;
    procedure setname(s: string);
  public
    constructor create;
    destructor destroy;
    procedure load(f: string);
    // ������� �����
    procedure CreateLines(g: cWPGraph; a: cWPAxis); overload;
    procedure CreateLines(g: integer; a: integer); overload;
    procedure delLines(g: integer);
    // ���������� ����� ����� ��� �����
    procedure delGraph(g: integer);
    procedure addid(g, p, ll, l, h, hh: integer);
    procedure CreateSignals;
    property name: string read getname write setname;
  end;

  TIntervalOpts = record
    intervaltype: integer;
    t1, t2: double;
    // ������� ���������� �� ����� ����
    // start, stop: cWPSignal;
    start, stop: cTrig;
  end;

  // ���������� - ����� �� ���������� ������������
  wpenumProc = function(obj: iwpnode; data: pointer): boolean;

  // �������� ������ ���������. �������� + ��������
  cOperObj = class
  public
    // ������ ������ ��������� winpos
    operStr: string;
    // ��������� ���������
    params: string;
    // ID ����� ����������
    DstID: integer;
    srcid: integer;
    // ������ ��������� (�������� + ����������)
    srcList: tstringlist;
    mng: cWPObjMng;
  protected
  private
    // ���� � ����� � ���������� �������
    fSrcDir: string;
    // ���� � ����� � ������������
    fDstDir: string;
  public
    // ����� ���������
    Interval: TIntervalOpts;
    fstatus: integer;
  protected
    function GetSrcDir: string;
    function GetDstDir: string;
    procedure SetSrcDir(s: string);
    procedure SetDstDir(s: string);
    // ������ �������� ��������� � ������������ � ��������
    // (�������� ���� ������ ������ ��� ���������, �� ������ ����� ���������)
    procedure CheckParams;
  public
    function GetSrc: cSrc;
    // �������� �� ������ ���� �������� ������ ��������
    // procedure PrepareSignals;
    procedure PrepareSignalsID;
    constructor create(p_operstr: string; p_params: string);
    destructor destroy;
    function SrcCount: integer;
    function GetSignalsOpts(i: integer): cSignalsOpt;
    procedure LingWP(p_mng: cWPObjMng);
    // � �������� ������� � ������ - ���� � ������ ������
    procedure AddSrc(s: cSignalsOpt);

    property SrcDir: string read GetSrcDir write SetSrcDir;
    property DstDir: string read GetDstDir write SetDstDir;
  end;

  cWPObjMng = class(cBaseObjMng)
  public
  public
    // ��������� ���������� ����������� ����� ������ �������. �������� doAddLine
    m_hline, m_haxis, m_hGraph: integer;
    m_str: string;
  public
    // ������� ���������������� ����������� ������
    fsTrig: integer;
    // ������ �������� �� ������� ������� ������� �������� ������ �� X
    TrigList: tstringlist;
    trigStart, trigStop: cTrig;
    // ���� ��������� ��� ������� (������ ��������)
    GraphApi: IWPGraphs;
    // ���� � ����������� �� ���������
    Resfolder: string;
    // ������ ������� ����������
    opers: tstringlist;
    // �������� � ��������� 0..100
    Progress: integer;
    // ������ ��������� ���������
    ProgressStr: String;
    // ������ ��������� ���������
    LastCfg: String;
    root: iwpnode;
    graphRoot: iwpnode;

    tubes: tstringlist;

    // ������� ���������� �������
    OnUpdateStatus: tNotifyEvent;
    StatusCallback: TProcessEvent;
    InfoCallBack: TInFoEvent;
    // ��� ��������� ��������������� ������������ �������. ����� ������ ������� ���������
    // ���� ����������� ������� �������� ������
    fcurSrc: cSrc;
  protected
    // �������� ����� ����������
    srcList: tstringlist;
    m_selectedSrc: cSrc;
    // ������ ������������� ����������
    algList: tstringlist;
  public
    procedure delTrig(tr:ctrig);
    // ��������� ��������������� ���������� ����� (x ������� �� ��������� �������)
    function AddHelpTrig: cWPSignal;
    function GetWPSignal(name: string; src: cSrc): cWPSignal; overload;
    function GetWPSignal(s: iwpsignal): cWPSignal; overload;
    function GetWPSignal(name: string): cWPSignal; overload;
    function AddSrc(name: string; id: integer; m: idispatch): cSrc; overload;
    // ���� � ���� � ������ WinPos
    function AddSrc(name: string): cSrc; overload;
    function GetStartTrig: cTrig;
    function GetStopTrig: cTrig;
    function loadsrc(str:string):csrc;
  protected
    function FindTube(n:iwpnode):cwptube;
    // ������� ���������� �� x ����� ����� ���������� ����� ��� ������ ����������
    // ����-�� ������ �� ID
    function GetTrigWithID(id: string): cTrig;
    procedure ClearTrigs;

    procedure renamesrc(s: cSrc; str: string);
    procedure ClearSRC;

    // ������ ��������
    procedure XMLSaveMngAttributes(node: txmlnode); override;
    procedure XMLlOADMngAttributes(node: txmlnode); override;
    procedure regObjClasses; override;
    procedure AddBaseObjInstance(obj: cBaseObj); override;
    function getWPAx(haxis: integer): cWPAxis;
    // ��������� ��������
    // �������� ��� ���� � �������� ���������� ������ (����� ��� ��������
    // ������������� �� � ����� � � ����, �������� ���� ������ � ������� ������)
    function GetIWPNodeByHLine(hline: integer): iwpnode;
    // �������� ��� ���������.
    function GetSrcName(i: integer): string;
    // �������� ���� �� ������ ����������
    function GetIWPUsml(i: integer): iwpusml;
    function GetIWPUsmlByHLine(hline: integer): iwpusml;
    function GetIWPUsmlByIWPSignal(s: iwpsignal): iwpusml;
    function GetSignalByHLine(hline: integer): cWPSignal;
    // �������� ������ �� ���� � ���� � ������ �������� WinPos
    function GetSignalByPath(str: string): cWPSignal;
    function GetSelectedSrc: cSrc;
    // ������� �������� ������
    procedure ApplyOperator(o: cOperObj);

    function GetCurSrc: cSrc;
    procedure SetCurSrc(s: cSrc);
    procedure ClearGraphs;
    procedure AddSystemTrigs;
    // ��������� ��������� ��� ��������� ��������� � �����
    procedure ProcessTrig(tr: cTrig; cb: TProcessEvent);
  public
    // ���������� ����� �������� � ������� ���� WP
    function GetCurSrcInMainWnd: cSrc;
    procedure EvalTrigs(cb: TProcessEvent);
    function getTrig(name: string): cTrig; overload;
    function getTrig(i: integer): cTrig; overload;
    procedure ReadGraphs;
    function getWPObj(i: integer): cWPObj; overload;
    function getWPObj(name: string): cWPObj; overload;
    procedure doAddSignal(s: string);
    // ���������� ��� �������������� ���� (��)
    // procedure doRenamingNode(n: cardinal);
    // ���������� ����� �������������� ���� (��)
    procedure doRenamedNode(n: cardinal);
    // ���������� ��� �������� ����. ��������� ������ ��� ���������
    procedure doDestroyNode(n: cardinal);
    procedure doAddNode(p: string);
    // ��������� ������� �� ��������� ����
    procedure CreateGraphs;
    // ��������� ���������
    procedure execute;
    procedure clear; override;
    // �������� ���������
    procedure ClearOpers;
    // ������������� �������� ��������� � ������� ������� Win���
    function EditOperator(o: cOperObj): integer;
    // �������� ������ � ���������� ��������� (���������� � notifyEvent �������)
    function AddOper(oper: string; params: string): cOperObj;
    function GetOper(i: integer): cOperObj;
    Property SelectedSrc: cSrc read GetSelectedSrc write m_selectedSrc;
    constructor create; override;
    destructor destroy; override;
    procedure save(path: string);
    procedure load(path: string);
    // ��������� �������� ����� ���������� ������
    procedure ReadSrc;
    // ��������� ������ ���������� ��������. ���������� ����� ���� ��� ���������
    // �������, ����� �������� ���������� ������� � ���������
    procedure ReadResults;
    // �������� �� ������. � �������� ������ ���� ��������
    // ������ ���� � ������ ��������
    function GetSrc(name: string): cSrc; overload;
    function GetSrc(i: integer): cSrc; overload;
    function getsrcid(id: integer): cSrc;
    function GetSrcBySignal(s: cWPSignal): cSrc; overload;
    function GetSrcBySignal(s: idispatch): cSrc; overload;
    function SrcCount: integer;
    // ���������� ����� ���������� ���������
    procedure OnExecuteOper(alg: string; src: string);
  public
    property curSrc: cSrc read GetCurSrc write SetCurSrc;
  end;

  cWPObj = class(cBaseObj)
  protected
    fid: integer;
  protected
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: TObject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    procedure ReplaceObjMng(m: TObject); override;
    procedure DoLincParent; override;
    procedure createEvents; virtual;
    procedure destroyEvents; virtual;
    function getEventList: ceventlist;
    function GetGraph: IWPGraphs;
  public
    property events: ceventlist read getEventList;
    property GraphApi: IWPGraphs read GetGraph;
  end;

  cWPSignal = class(cWPObj)
  public
    // ����������� ���
    virt: boolean;
    src: cSrc;
    istube: boolean;
  protected
    ftubename:string;
    fnode: wpnode;
    // true ���� �������� � USML ������
    ConnectToUsml: boolean;
  protected
    // ������� ������ �� ������� �����������!! ������ �� ���� iwpNode, �.�.
    // ������ �������� �������� � �������� ������ WP
    function GetSignal: iwpsignal;
    // �������� ������ �� ��������� � ������ ���������
    function getProcSignal(t1, t2: double): iwpsignal;
    procedure setname(s: string); override;
    procedure createTube;
    procedure setNode(n: wpnode);
    procedure setMng(m: TObject); override;
    function gettube:cwptube;
    procedure settube(t:cwptube);
  public
    procedure setFs(f: double);
    function getFs: double;
    function getUSML: iwpusml;
    function GetP2(i: integer): point2;
    // ������ �� Y
    function getLength: double;
    function getMinMaxX: point2d;
    function getMinMaxY: point2d;
    property fs: double read getFs write setFs;
    function count: cardinal;
    property Signal: iwpsignal read GetSignal;
    property node: wpnode read fnode write setNode;
    property tube:cwptube read gettube write settube;
    constructor create(n: iwpnode); overload;
    constructor create; overload;
    destructor destroy; override;
  end;

  // �����������
  cSrc = class(cWPObj)
  public
    // ���� �� ����� signals � ������ winpos
    name: string;
    // �������� ����� �������� �� �������� node ������ �������, �.�. ������
    // iwpusml ����� ����� �� ��������
    merafile: iwpusml;

    // ������ � ����� ���������
    processed: boolean;
    ft1, ft2: double;
    // ������� ���� ����
    IntervalOpts: integer;
    fTrigStart, fTrigStop: cTrig;
    TrigLevel: double;

    id: integer;
    // �� ������ ���� �������� �� � ������� � � �����
    node: iwpnode;
    // ������ ��������� ����������� ��������� ������ (������� ��� ������ ����� (���� lbl))
    trigList:tstringlist;
  protected
    // ���� true �� �������� � ����� ����� � merafile
    bnode: boolean;
  private
    // d - ��� �������� �������� (node ��� iwpusml)
    procedure initSRC(d: idispatch);
  protected
    procedure setMng(m: TObject); override;
    procedure ReadTrigs;
    // ��������� ����� �� ������������ ������ � ���������
    function CheckSignal(s:iwpsignal):boolean;
    // �������� �� ���� ��������� ��� �������� �� ��������� �� ���������� ����� �������
    // �� �������� ������ � MERA ������!!!!
    procedure UpdateSrc;
  public
    constructor create(p_name: string); overload;
    constructor create(m: idispatch); overload;
    destructor destroy;
    // ���������� ��������� �� ������ �� �������� �������� ������� (��� �����
    // ���� ��� ���� ���� ����)
    function GetNodeInstance: cardinal;
    // �������� ������ � ����� name. � ������� ������ ���� ������������������� ������ ���
    function CreateSignal(s: iwpsignal): cWPSignal; overload;
    function CreateSignal(d: idispatch): cWPSignal; overload;
    function getSignalHinst(sname: string): integer;
    function GetSignal(sname: string): iwpsignal;overload;
    function GetSignal(i: integer): iwpsignal;overload;
    function getSignalObj(sname: string): cWPSignal;overload;
    function getSignalObj(i: integer): cWPSignal;overload;
    // ��������� ������� ��������� �� ����� �������� ��������
    function EvalStartStop(CallBack: TProcessEvent): point2d;
    // ��������� ������� ��������� �� ����� ������� ��������
    function EvalStartStopMax(CallBack: TProcessEvent): point2d;
  protected
    function gett1: double;
    function gett2: double;
    procedure setT1(v: double);
    procedure setT2(v: double);
    procedure settrigstart(t: cTrig);
    procedure settrigstop(t: cTrig);
  public
    property trigStart: cTrig read fTrigStart write settrigstart;
    property trigStop: cTrig read fTrigStop write settrigstop;
    property t1: double read gett1 write setT1;
    property t2: double read gett2 write setT2;
  end;

  cWPPage = class(cWPObj)
  public
    hpage: integer;
    // ���� ��� X
    OneAxisX,
    // ���� ��� Y
    OneAxisY,
    // ���������� ���
    ShowName,
    // ������������� ��������
    SyncCursors: boolean;
    // ��������� ����������� ��������
    graphtable: tpoint;
  public
    procedure ApplyOpts;
    function GetPageStyle: integer;
  protected
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: TObject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
  end;

  cWPGraph = class(cWPObj)
  public
    FindInterval: boolean;
    startTrig, StopTrig: cTrig;
    signalLength: double;
    // ------------------------------------------------------------------------
    tubes: boolean;
    hgraph: integer;
    // �������� �� ��� X
    XAxis: point2d;
    // ���� 1, �� ��� �������� ������� ������� ���������� � �������� �� �������
    autoscale: boolean;
    // ������������ �������� �� ��� X
    ZoomXAxis: point2d;
    // ������� �� ��� X
    XName, szftempl: widestring;
    color: integer;
    // #define GROPT_SHOWLEGEND 0x0200 // ���������� �������
    ShowLegend: boolean;
    // GROPT_SHOWNAME 1h ���� ��������� ��������
    ShowName,
    // GROPT_YINDENT 2h 10% ������ ��� ����� ������ � �����
    YINDENT,
    // GROPT_SUBGRID 4h ���� ��������� ���������� ����� �� �����
    SUBGRID,
    // GROPT_GRIDLABS 8h �������� ����� � ����� �����
    GRIDLABS,
    // GROPT_LINENUMS 10h ���������� ������ �����
    LINENUMS,
    // GROPT_AUTONORM 20h ������������� ��������������� ������ ���
    AUTONORM,
    // GROPT_POLAR 40h �������� ����������
    POLAR,
    // GROPT_AXCOLUMN 80h ���� ���������� ���� Y ���� ��� ������
    AXCOLUMN,
    // ���� ���������� ���� Y ���� �� ������
    AXROW: boolean;
    // �������� �� ��� X
    LogX: boolean;
    node: iwpnode;
  protected
    function GetAxisByLine(hline: integer): cWPAxis;
    function getXMinMax: point2d;
    // ����� ���
    function GetAxis(i: integer): cWPAxis;
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: TObject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    function EvalXBounds: point2d;
  public
    constructor create; override;
    destructor destroy; override;
    procedure ApplyOpts;
  end;

  cWPAxis = class(cWPObj)
  public
    // ����� ��� �� ��������
    // axIndex:integer;
    haxis: integer;
    // �������� �� ��� X
    MinMax: point2d;
    // ������������ �������� �� ��� X
    ZoomAxis: point2d;
    // ������� �� ��� X
    // AXOPT_NAME* 20h ���������� ��� ��� ����������� ���
    szName,
    // AXOPT_FORMAT* 40h ���������� ������ ���������
    szftempl: widestring;
    color: integer;
    // ���� 1, �� ��� �������� ������� ������� ���������� � �������� �� �������
    autoscale: boolean;
    // AXOPT_LOG 1h ��������������� �������
    log,
    // AXOPT_FZERO 2h ��������� ���� � ����� ����� ("1.500" ������ "1.5")
    FZERO,
    // AXOPT_TIME 4h �������� ����� ������� � ������� ���.��.��.���
    TIME: boolean;
    tube: cWPTube;
    // AXOPT_COLOR* 8h ���������� ������� ���� ��������� ���
    // COLOR,
    // AXOPT_RANGE* 10h ���������� ������ �������� ���
    // RANGE,
  protected
    procedure DoLincParent; override;
    // ���������� ��� ���� (������� ��� ������� � ����� �������)
    function getYminmax: point2d;
    // ����������� ��� �� Y
    procedure Normalise;
    function GetGraph: cWPGraph;
    function GetSignal(i: integer): cWPSignal;
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: TObject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
  public
    procedure ApplyOpts;
  end;

  cWPLine = class(cWPObj)
  protected
    fsignalName: string;
  public
    hline: integer;
    srcid: integer;
    // ������ �� ������ �� �������� �������
    Signal: cWPSignal;
    // ��������; �����������
    LineType: integer;
    // LNOPT_COLOR - ����
    color: integer;
    // LNOPT_WIDTH - �������
    width: integer;
    // LNOPT_LINE2BASE - ������������ ����� �� �������� � 0
    LINE2BASE: boolean;
    // LNOPT_ONLYPOINTS - �������� ������ �����
    ONLYPOINTS: boolean;
    // LNOPT_VISIBLE - ������ �����
    VISIBLE: boolean;
    // LNOPT_HIST - �����������
    HIST: boolean;
    // LNOPT_HISTTRANSP - ���������� �����������
    HISTTRANSP: boolean;
    // LNOPT_PARAM -
    PARAM: boolean;
    // LNOPT_INTERP - ������� ������������ 2 ����
    INTERP: boolean;
  protected
    hSignal: integer;
    srcName: string;
  protected
    function getMinMaxY: point2d;
    procedure LoadObjAttributes(xmlNode: txmlnode; mng: TObject); override;
    procedure SaveObjAttributes(xmlNode: txmlnode); override;
    procedure setsignalname(s: string);
  public
    property signalname: string read fsignalName write setsignalname;
    constructor create; override;
    procedure ApplyOpts;
  end;





// �������� ������ ' '
function GetSName(name: string): string;
// ����� � ����� ������ , � = ������ �������
function ConvertPropertieStr(s: string): string;
// ������� �� ����� '/'
Function TrimName(str: string): string;
Function TrimDir(str: string): string;
// ��������� ������ �����/����

function EvalTrig(s: cWPSignal; from: double; finish: double; lvl: double;
  hi: boolean; num: integer; dsc: string; CallBack: TProcessEvent;
  var p_success: boolean): double;

function isHelpChannel(s:string):boolean;overload;
function isHelpChannel(s:iwpsignal):boolean;overload;
function isHelpChannel(s:cwpsignal):boolean;overload;


const
  c_Src_name = '_Src_';

  c_AlgStatusOk = 0; // ��� ����
  c_AlgStatusSrc = 1; // �� ������ ��������
  // IntervalOpts
  // ������� ���� ����
  c_IntervalAllTest = 1;
  // ������� �� �������
  c_IntervalTime = 2;
  // ������� �� ���������� �������� ����� ����
  c_IntervalTrigs = 3;
  // ������� �� �������
  c_IntervalCursor = 4;
  GROPT_SHOWLEGEND = $0200;

  c_Trig_Search = 0;
  c_Trig_Start = 1;
  c_Trig_Stop = 2;
  c_Trig_User = 3;

  c_Trig_Lvl = 0;
  c_Trig_Dif1 = 1;
  c_Trig_Dif2 = 2;

  c_TrigSearchInterval_No = 0;
  c_TrigSearchInterval_from = 1;
  c_TrigSearchInterval_to = 2;
  c_TrigSearchInterval_Interval = 3;
  // ������� ������������ �������������
  c_Trig_NoFiltert = 0;
  c_Trig_TrendFilter = 1;
  c_Trig_ExpFilter = 2;



  c_pageStyle_Row = 0;
  c_pageStyle_col = 1;
  c_pageStyle_table = 2;

  wmCreateInterface = WM_USER+1;
  wm_WPEnd =wmCreateInterface;

implementation

uses
  uwpExtpack;

procedure saveString(path: string; Key: string; value: string);
var
  ifile: tinifile;
begin
  ifile := tinifile.create(path);
  ifile.WriteString('Main', Key, value);
  ifile.destroy;
end;

function LoadString(path: string; Key: string): string;
var
  ifile: tinifile;
begin
  ifile := tinifile.create(path);
  result := ifile.readString('Main', Key, '');
  ifile.destroy;
end;

function cTrig.GetAbsoluteValue(s: iwpsignal): double;
var
  r, mo, max, min: double;
begin
  max := s.MaxY;
  min := s.MinY;
  r := max - min;
  if units = u_Abs then
  begin
    result := Threshold;
  end;
  if units = u_percent then
  begin
    result := r * (Threshold / 100) + min;
  end;
  if units = u_10Lg then
  begin
    result := r * (Power(10, Threshold / 10));
  end;
  if units = u_20Lg then
  begin
    result := r * (Power(10, Threshold / 20));
  end;
end;

function cTrig.GetTime(src:csrc): double;
var
  er: boolean;
  f: tNotifyEvent;
  sig: cWPSignal;
  p: point2d;
begin
  case trigtype of
    c_Trig_Start:
      begin
        if src=nil then
        begin
          x:=-1;
          result:=x;
          fsuccess:=false;
          exit;
        end;
        x := src.t1;
        fsuccess:=true;
        result := x;
        exit;
      end;
    c_Trig_Stop:
      begin
        if src=nil then
        begin
          x:=-1;
          result:=x;
          fsuccess:=false;
          exit;
        end;
        x := src.t2;
        result := x;
        exit;
      end;
    c_Trig_User:
      begin
        result := x;
        exit;
      end;
    c_Trig_Search:
      begin
        if not processed then
        begin
          er := true;
          x := 0;
          result := 0;
          sig := src.getSignalObj(TrigName);
          if sig <> nil then
          begin
            // cb - callback �� ������� ��� ����������� �������� ������� ��������
            p := sig.getMinMaxX;
            result := EvalTrig(sig, p.x, p.y, GetAbsoluteValue(sig.Signal),
              Front, number, '���������� ������ �����������', nil, fsuccess)
              + shift;
            x := result;
            lastid := srcid;
            processed := true;
            er := false;
          end;
        end
        else
        begin
          result := x;
        end;
      end;
  end;
end;

function cTrig.GetTime: double;
var
  src: cSrc;
begin
  src := mng.getsrcid(srcid);
  result:=GetTime(src);
end;


function EvalGropTrigStatus(obj: cBaseObj; data: pointer): boolean;
var
  tr: cTrig;
  s: cWPSignal;
  Interval: point2d;
  number: integer;
begin
  result := true;
  tr := cTrig(obj);
  s := tr.GetSignal;
  Interval := tr.SearchInterval;
  // cb - callback �� ������� ��� ����������� �������� ������� ��������
  if tr.isHeader then
  begin
    if tr.m_FindGroup then
    begin
      // number:=tr.fGroupNumber;
      number := 0;
    end
    else
    begin
      number := tr.number;
    end;
    if tr.fsuccess then
    begin
      Interval.x := tr.fLastX;
    end;
  end
  else
    number := tr.number;

  tr.x := EvalTrig(s, Interval.x, Interval.y, tr.GetAbsoluteValue(s.Signal),
    tr.Front, number, '���������� ������ �����������', nil, tr.fsuccess)
    + tr.shift;
  if tr.fsuccess then
    tr.fLastX := tr.x;
  if tr.fsuccess = false then
  begin
    // ctrig(data).fgroupSuccess:=false;
    result := tr.fsuccess;
  end;
end;

function cTrig.GetTime(var error: boolean; src: cSrc; start, finish: double;
  cb: TProcessEvent): double;
var
  s: cWPSignal;
  // ���� ������� ��������� ���� ��������� ������� ��� ���� ������� ��� ������
  groupNum: integer;
begin
  src := mng.getsrcid(srcid);
  case trigtype of
    c_Trig_Start:
      begin
        x := src.t1;
        result := x;
        exit;
      end;
    c_Trig_Stop:
      begin
        x := src.t2;
        result := x;
        exit;
      end;
    c_Trig_User:
      begin
        result := x;
        exit;
      end;
    c_Trig_Search:
      begin
        if not processed then
        begin
          error := true;
          x := 0;
          result := 0;
          s := src.getSignalObj(TrigName);
          if s <> nil then
          begin
            if m_FindGroup then
            begin
              if isGroup then
              begin
                if isHeader then
                begin
                  // ����� ������������ �������� ��� ������� ������ ���������
                  // ����������� ������� ���� ��� ������ �������
                  fGroupNumber := 0;
                  while fGroupNumber <= number do
                  begin
                    EnumGroupMembers(EvalGropTrigStatus, self);
                    if GroupSuccess then
                    begin
                      inc(fGroupNumber);
                      // �������� ����� ���������� �������� � fgroupMaxX
                      fLastX := fgroupMaxX;
                    end;
                    // ���� �� ������ �������� ������� �� ������� �� �����
                    if fsuccess = false then
                      break;
                  end;
                end;
              end
            end
            else
            begin
              // cb - callback �� ������� ��� ����������� �������� ������� ��������
              result := EvalTrig(s, start, finish, GetAbsoluteValue(s.Signal),
                Front, number, '���������� ������ �����������', cb, fsuccess)
                + shift;
              x := result;
            end;
            result := x;
            lastid := srcid;
            processed := true;
            error := false;
          end;
        end
        else
        begin
          result := x;
        end;
      end;
  end;
end;

procedure cTrig.SetSrcID(id: integer);
begin
  fsrcID := id;
  if fsrcID <> id then
  begin
    processed := false;
  end;
end;

function cTrig.isGroup: boolean;
begin
  result := false;
  if (parent <> nil) or (childcount <> 0) then
  begin
    result := true;
  end;
end;

constructor cTrig.create;
begin
  inherited;
  m_FindGroup:=false;
  x := -1;
end;

function cTrig.GetSearchIntervalT1: cTrig;
begin
  result := fSearchIntervalT1;
  if fSearchIntervalT1 = nil then
  begin
    if parent <> nil then
      result := cTrig(parent);
  end
end;

function cTrig.GetSearchIntervalType: integer;
begin
  result := fSearchIntervalType;
  if fSearchIntervalType = c_TrigSearchInterval_No then
  begin
    if parent <> nil then
    begin
      SearchIntervalT1 := cTrig(parent);
      result := c_TrigSearchInterval_from;
    end;
  end;
end;

function cTrig.GetSearchInterval: point2d;
var
  s: cWPSignal;
begin
  s := GetSignal;
  case SearchIntervalType of
    c_TrigSearchInterval_No:
      begin
        if s <> nil then
        begin
          result := s.getMinMaxX;
        end
        else
        begin
          result := p2d(0, 0);
        end;
      end;
    c_TrigSearchInterval_from:
      begin
        result.y := fSearchInterval.y;
        if SearchIntervalT1 <> nil then
        begin
          result.x := SearchIntervalT1.x;
        end
        else
        begin
          result.x := fSearchInterval.x;
        end;
        result.y := s.getMinMaxX.y;
      end;
    c_TrigSearchInterval_to:
      begin
        result.x := s.getMinMaxX.x;
        if SearchIntervalT2 <> nil then
        begin
          result.y := SearchIntervalT2.x;
        end
        else
        begin
          result.y := fSearchInterval.y;
        end;
      end;
    c_TrigSearchInterval_Interval:
      begin
        if SearchIntervalT2 <> nil then
        begin
          result.y := SearchIntervalT2.x;
        end
        else
          result.y := fSearchInterval.y;

        if SearchIntervalT1 <> nil then
        begin
          result.x := SearchIntervalT1.x;
        end
        else
        begin
          result.x := fSearchInterval.x;
        end;
      end;
  end;

end;

procedure cTrig.Settrigtype(t: integer);
begin
  processed := false;
  fsuccess := false;
  ftrigtype := t;
  if t <> c_Trig_Search then
  begin
    fsuccess := true;
  end;
end;

procedure cTrig.SetSearchIntervalType(t: integer);
begin
  processed := false;
  fsuccess := false;

  fSearchIntervalType := t;
end;

function enumtrigs(obj: cBaseObj; data: pointer): boolean;
begin
  result := cTrig(obj).fsuccess;
  if cTrig(data).fgroupMaxX < cTrig(obj).x then
  begin
    cTrig(data).fgroupMaxX := cTrig(obj).x;
  end;
  cTrig(data).fgroupSuccess := result;
end;

function cTrig.GroupSuccess: boolean;
var
  obj, child: cBaseObj;
  i: integer;
begin
  obj := GetRoot;
  fgroupMaxX := x;
  EnumGroupMembers(enumtrigs, obj);
  result := fgroupSuccess;
end;

function cTrig.getsrcid: integer;
begin
  result := fsrcID;
end;

procedure cTrig.DoLincParent;
begin
  inherited;
  processed := false;
end;

function cTrig.GetSignal: cWPSignal;
var
  src: cSrc;
begin
  result := nil;
  src := mng.getsrcid(srcid);
  if src <> nil then
  begin
    result := src.getSignalObj(TrigName);
  end;
end;

procedure cTrig.SetX(lx: double);
begin
  if trigtype = c_Trig_User then
  begin
    x := lx;
  end;
end;

function cTrig.GetTypeString: string;
begin
  case trigtype of
    c_Trig_Start:
      result := '�����';
    c_Trig_Stop:
      result := '����';
    c_Trig_Search:
      result := '����� ��������';
    c_Trig_User:
      result := '��������������';
  end;
end;

function cTrig.GenID: string;
var
  ind: integer;
  str: string;
begin
  if list <> nil then
  begin
    if list.Find(id, ind) then
    begin
      if self = list.Objects[ind] then
        list.Delete(ind);
    end;
  end;
  case trigtype of
    c_Trig_Search:
      begin
        id := TrigName + '/lvl=' + formatstr(Threshold, 3)
          + '/Shift=' + formatstr(shift, 3) + '/�=' + inttostr(number);
        if Front then
          id := id + '/Front'
        else
          id := id + '/Fall';
        case units of
          u_Abs:
            str := '/���.';
          u_percent:
            str := '/%';
          u_10Lg:
            str := '/10Lg';
          u_20Lg:
            str := '/20Lg';
        end;
        id := id + str;
      end;
    c_Trig_Start:
      begin
        id := '����� ������';
      end;
    c_Trig_Stop:
      begin
        id := '���� ������';
      end;
    c_Trig_User:
      begin
        id := 'Trig_abs_' + formatstr(GetTime, 2);
      end;
  end;
  if list <> nil then
  begin
    list.AddObject(id, self);
  end;
  result := id;
  if name = 'cTrig' then
    name := id;
end;

Function cTrig.Compare(t: cTrig): boolean;
begin
  result := false;
  if t.TrigName = TrigName then
  begin
    if t.Threshold = Threshold then
    begin
      if t.Front = Front then
      begin
        if t.number = number then
        begin
          if t.trigtype = trigtype then
          begin
            if t.shift = shift then
            begin
              result := true;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function ExtractSignalName(s: string): string;
var
  folder: string;
  i: integer;
begin
  result := s;
  for i := length(s) downto 1 do
  begin
    if (s[i] = '\') or (s[i] = '/') then
    begin
      folder := s;
      // -1 �.�. �������� ����
      setlength(folder, i - 1);
      // i+1 �.�. �������� ����
      result := Copy(s, i + 1, length(s) - i);
      break;
    end;
  end;
end;

function ExtractSignalFolder(s: string): string;
var
  i: integer;
begin
  result := 'Signals/';
  for i := length(s) downto 1 do
  begin
    if (s[i] = '\') or (s[i] = '/') then
    begin
      result := s;
      // -1 �.�. �������� ����
      setlength(result, i);
      exit;
    end;
  end;
end;



function EnumGroupMembers(proc: wpenumProc; node: iwpnode; data: pointer;
  var continue: boolean): boolean;
var
  i: integer;
  obj: iwpnode;
  childNode: iwpnode;
begin
  result := true;
  if continue then
  begin
    continue := proc(node, data);
    if continue then
    begin
      for i := 0 to node.childcount - 1 do
      begin
        childNode := iwpnode(node.at(i));
        EnumGroupMembers(proc, childNode, data, continue);
        if not continue then
          exit;
      end;
    end;
  end;
end;

function TubeComparator(p1, p2: pointer): integer;
begin
  if cTubeID(p1).hgraph > cTubeID(p2).hgraph then
  begin
    result := 1;
  end
  else
  begin
    if cTubeID(p1).hgraph < cTubeID(p2).hgraph then
    begin
      result := -1;
    end
    else
    begin
      result := 0;
    end;
  end;
end;

function cWPTube.getname: string;
begin
  result := fname;
end;

procedure cWPTube.setname(s: string);
begin
  fname := s;
end;

constructor cWPTube.create;
begin
  tubelist := tstringlist.create;
  tubelist.Sorted := true;
end;

destructor cWPTube.destroy;
var
  ind: integer;
  i: integer;
begin
  setlength(pr, 0);
  setlength(l, 0);
  setlength(ll, 0);
  setlength(h, 0);
  setlength(hh, 0);
  n_pr := nil;
  n_l := nil;
  n_ll := nil;
  n_h := nil;
  n_hh := nil;

  tubelist.destroy;
  if cWPObjMng(uwpExtpack.mng).tubes.Find(name, ind) then
  begin
    if cWPObjMng(mng).tubes.Objects[ind] = self then
      cWPObjMng(mng).tubes.Delete(ind)
    else
    begin
      for i := ind to cWPObjMng(mng).tubes.count - 1 do
      begin
        if cWPObjMng(mng).tubes.Objects[i] = self then
        begin
          cWPObjMng(mng).tubes.Delete(i);
          break;
        end;
      end;
    end;
  end;
  inherited;
end;

procedure cWPTube.CreateSignals;
var
  l_p, l_l, l_ll, l_h, l_hh: iwpsignal;
  // line_p, line_l, line_ll, line_h, line_hh:iwp;
  i: integer;
begin
  l_p := iwpsignal(wp.CreateSignalXY(5, 5));
  l_l := iwpsignal(wp.CreateSignalXY(5, 5));
  l_ll := iwpsignal(wp.CreateSignalXY(5, 5));
  l_h := iwpsignal(wp.CreateSignalXY(5, 5));
  l_hh := iwpsignal(wp.CreateSignalXY(5, 5));

  l_p.size := length(pr);
  l_l.size := length(pr);
  l_ll.size := length(pr);
  l_h.size := length(pr);
  l_hh.size := length(pr);

  for i := 0 to length(pr) - 1 do
  begin
    l_p.SetX(i, pr[i].x);
    l_p.SetY(i, pr[i].y);

    l_l.SetX(i, l[i].x);
    l_l.SetY(i, l[i].y);

    l_ll.SetX(i, ll[i].x);
    l_ll.SetY(i, ll[i].y);

    l_h.SetX(i, h[i].x);
    l_h.SetY(i, h[i].y);

    l_hh.SetX(i, hh[i].x);
    l_hh.SetY(i, hh[i].y);
  end;

  l_p.sname := 'Prof_' + name;
  l_p.NameX := '��';
  l_p.NameY := 'Y';

  l_l.sname := 'Lo_' + name;
  l_p.NameX := '��';
  l_p.NameY := 'Y';

  l_ll.sname := 'LoLo_' + name;
  l_p.NameX := '��';
  l_p.NameY := 'Y';

  l_h.sname := 'Hi_' + name;
  l_p.NameX := '��';
  l_p.NameY := 'Y';

  l_hh.sname := 'HiHi_' + name;
  l_p.NameX := '��';
  l_p.NameY := 'Y';

  //folder := ExtractSignalFolder(sig.node.AbsolutePath) + 'Tubes/';
  // folder:=DeleteChars(folder,'"');
  if folder[length(folder)] <> '/' then
    folder := folder + '/';
  // winpos.Link( 'Signals/', s.sname, s );
  // � ���� folder=Signals/����������/ � s.sname=3- 1

  n_pr := iwpnode(winpos.Link(folder, l_p.sname, l_p));
  n_l := iwpnode(winpos.Link(folder, l_l.sname, l_l));
  n_ll := iwpnode(winpos.Link(folder, l_ll.sname, l_ll));
  n_h := iwpnode(winpos.Link(folder, l_h.sname, l_h));
  n_hh := iwpnode(winpos.Link(folder, l_hh.sname, l_hh));

end;

procedure cWPTube.CreateLines(g: cWPGraph; a: cWPAxis);
var
  l_p, l_l, l_ll, l_h, l_hh: iwpsignal;
begin
  CreateLines(g.hgraph, a.haxis);
  winpos.Refresh;
end;

procedure cWPTube.addid(g, p, ll, l, h, hh: integer);
var
  t: cTubeID;
  ind: integer;
begin
  if not tubelist.Find(inttostr(g), ind) then
  begin
    t := cTubeID.create;
    t.l := l;
    t.ll := ll;
    t.h := h;
    t.hh := hh;
    t.p := p;
    tubelist.AddObject(inttostr(g), t);
  end;
end;

procedure cWPTube.delGraph(g: integer);
var
  t, obj: cTubeID;
  ind: integer;
begin
  t := cTubeID.create;
  t.hgraph := g;
  if tubelist.Find(inttostr(g), ind) then
  begin
    obj := cTubeID(tubelist.Objects[ind]);
    tubelist.Delete(ind);
    obj.destroy;
  end;
  t.destroy;
end;

procedure cWPTube.delLines(g: integer);
var
  t, obj: cTubeID;
  ind: integer;
begin
  t := cTubeID.create;
  t.hgraph := g;
  if tubelist.Find(inttostr(g), ind) then
  begin
    obj := cTubeID(tubelist.Objects[ind]);
    IWPGraphs(winpos.GraphApi).DestroyLine(obj.l);
    IWPGraphs(winpos.GraphApi).DestroyLine(obj.ll);
    IWPGraphs(winpos.GraphApi).DestroyLine(obj.h);
    IWPGraphs(winpos.GraphApi).DestroyLine(obj.hh);
    IWPGraphs(winpos.GraphApi).DestroyLine(obj.p);
    tubelist.Delete(ind);
    obj.destroy;
  end;
  t.destroy;
end;

procedure cWPTube.CreateLines(g: integer; a: integer);
var
  l_p, l_l, l_ll, l_h, l_hh: iwpsignal;
  i, count: integer;
  line: integer;
  h_P, h_l, h_ll, h_h, h_hh: integer;
begin
  if tubelist.Find(inttostr(g), h_P) then
    exit;

  l_p := iwpsignal(n_pr.Reference);
  l_l := iwpsignal(n_l.Reference);
  l_ll := iwpsignal(n_ll.Reference);
  l_h := iwpsignal(n_h.Reference);
  l_hh := iwpsignal(n_hh.Reference);

  h_P := IWPGraphs(winpos.GraphApi).createline(g, a, l_p.Instance);
  h_l := IWPGraphs(winpos.GraphApi).createline(g, a, l_l.Instance);
  h_ll := IWPGraphs(winpos.GraphApi).createline(g, a, l_ll.Instance);
  h_h := IWPGraphs(winpos.GraphApi).createline(g, a, l_h.Instance);
  h_hh := IWPGraphs(winpos.GraphApi).createline(g, a, l_hh.Instance);

  addid(g, h_P, h_ll, h_l, h_h, h_hh);

  IWPGraphs(winpos.GraphApi).SetLineOpt(h_h, $1410, $1410, 2, $00D2D5);
  // 0-��������, 1,2,3...
  IWPGraphs(winpos.GraphApi).SetLineOpt(h_hh, $1410, $1410, 1, $0000FF);
  IWPGraphs(winpos.GraphApi).SetLineOpt(h_l, $1410, $1410, 2, $00D2D5);
  IWPGraphs(winpos.GraphApi).SetLineOpt(h_ll, $1410, $1410, 1, $0000FF);
  IWPGraphs(winpos.GraphApi).SetLineOpt(h_P, $1410, $1410, 0, $66DA6E);

  winpos.Refresh;
end;

procedure cWPTube.load(f: string);
var
  tfile: tstringlist;
  i, ind: integer;
  s, s1: string;
  j: integer;
begin
  tfile := tstringlist.create;
  name := extractfilename(f);
  path := f;
  tfile.LoadFromFile(f);
  if tfile.count > 2 then
  begin
    setlength(pr, tfile.count - 1);
    setlength(l, tfile.count - 1);
    setlength(ll, tfile.count - 1);
    setlength(h, tfile.count - 1);
    setlength(hh, tfile.count - 1);
  end
  else
    exit;
  for i := 1 to tfile.count - 1 do
  begin
    s := tfile.Strings[i];
    s1 := GetSubString(s, ';', 1, ind);
    pr[i - 1].x := StrToFloatExt(s1);
    l[i - 1].x := pr[i - 1].x;
    h[i - 1].x := pr[i - 1].x;
    ll[i - 1].x := pr[i - 1].x;
    hh[i - 1].x := pr[i - 1].x;
    for j := 0 to 4 do
    begin
      s1 := GetSubString(s, ';', ind + 1, ind);
      if s1 = '' then
        exit;
      case j of
        0:
          pr[i - 1].y := StrToFloatExt(s1);
        1:
          l[i - 1].y := StrToFloatExt(s1);
        2:
          h[i - 1].y := StrToFloatExt(s1);
        3:
          ll[i - 1].y := StrToFloatExt(s1);
        4:
          hh[i - 1].y := StrToFloatExt(s1);
      end;
    end;
  end;
  CreateSignals;
  tfile.destroy;
end;

procedure cWPObj.LoadObjAttributes(xmlNode: txmlnode; mng: TObject);
begin
  inherited;
  // ����� ����
  // fcolor.x := xmlNode.ReadAttributeFloat('Color_R');
end;

function cWPObj.GetGraph: IWPGraphs;
begin
  result := cWPObjMng(getmng).GraphApi;
end;

procedure cWPObj.SaveObjAttributes(xmlNode: txmlnode);
begin
  inherited;
  // ����� ����
  // xmlNode.WriteAttributeFloat('Color_R', fcolor.x);
end;

procedure cWPObj.DoLincParent;
begin
  inherited;
  { if parent <> nil then
    begin
    node.LincTo(cDrawObj(parent).node);
    if cDrawObj(parent).getDrawObjMng <> nil then
    begin
    setMng(cDrawObj(parent).getDrawObjMng);
    end;
    if events <> nil then
    // ���������� ��� ���������� ��������� ����������
    events.CallAllEventsWithSender(e_onLincParent, self);
    end
    else
    begin
    if node<>nil then
    node.unLinc;
    if events <> nil then
    begin
    events.CallAllEventsWithSender(e_onLincParent, self);
    DeleteEvents;
    end;
    end; }
end;

procedure cWPObj.createEvents;
begin
  // events.AddEvent(name+'_OnUpadeteTextLabelBound', e_onResize+E_OnZoom, doUpdateWorldSize);
end;

procedure cWPObj.destroyEvents;
begin
  // events.removeEvent(doUpdateWorldSize, e_onResize+E_OnZoom);
end;

function cWPObj.getEventList: ceventlist;
var
  mng: TObject;
begin
  result := nil;
  mng := getmng;
  if mng <> nil then
  begin
    result := cBaseObjMng(mng).events;
  end;
end;

procedure cWPObj.ReplaceObjMng(m: TObject);
begin
  inherited;
  if m <> nil then
  begin
    createEvents;
  end;
end;

function cWPObjMng.getWPObj(i: integer): cWPObj;
begin
  result := cWPObj(getObj(i));
end;

procedure cWPObjMng.ClearOpers;
var
  i: integer;
  o: cOperObj;
begin
  while opers.count <> 0 do
  begin
    o := GetOper(0);
    o.destroy;
  end;
  // opers.clear;
end;

function cWPObjMng.EditOperator(o: cOperObj): integer;
var
  oper: iwpOperator;
  { ole_src1,ole_src2, ole_dst1, ole_dst2, ole_OptFFT, ole_Err : OleVariant;
    s:iwpsignal;
    str, folder:string;
    sOpts:cSignalsOpt;
    node:IWPNode;
    src:csrc; }
begin
  // -- �������� ������ � ���������� ���������
  // -- (������ ������� ���������� ����� ����� � ���� "���������")
  // �������� "����������"
  oper := winpos.GetObject(o.operStr) as iwpOperator;
  oper.LoadProperties(ConvertPropertieStr(o.params));
  result := oper.SetupDlg;
  if result = 3 then
    o.params := oper.getPropertyValues;
end;

function cWPObjMng.AddOper(oper: string; params: string): cOperObj;
var
  o: cOperObj;
begin
  o := cOperObj.create(oper, params);
  o.operStr := oper;
  o.LingWP(self);
  opers.AddObject(oper, o);
  result := o;
end;

function cWPObjMng.GetOper(i: integer): cOperObj;
begin
  result := cOperObj(opers.Objects[i]);
end;

function cWPObjMng.getWPObj(name: string): cWPObj;
begin
  result := cWPObj(getObj(name));
end;

procedure cWPObjMng.AddBaseObjInstance(obj: cBaseObj);
begin
  if (obj is cWPObj) or (obj is cWPPage) or (obj is cWPGraph) or
    (obj is cWPAxis) or (obj is cWPLine) then
  begin
    // �� ��������� ������� � ����� ������ ��������
    if (obj is cSrc) or (obj is cWPSignal) then
    begin
      obj.ReplaceObjMng(self);
      exit;
    end;
    inherited AddBaseObjInstance(obj);
  end;
end;

procedure cWPObjMng.regObjClasses;
begin
  inherited;
  regclass(cWPPage);
  regclass(cWPGraph);
  regclass(cWPAxis);
  regclass(cWPLine);
end;

procedure Savetrig(srcnode: txmlnode; tr: cTrig; nodeNum: integer);
var
  i: integer;
  chTrig: cTrig;
  child, childNode: txmlnode;
  p2: point2d;
begin
  child := srcnode.NodeNew('Trig_' + tr.name);
  child.WriteAttributeString('NodeName', tr.Name, '');
  child.WriteAttributeString('NodeType', 'Trig', 'Trig');
  child.WriteAttributeinteger('TrigType', tr.trigtype, c_Trig_Search);
  child.WriteAttributeFloat('Shift', tr.shift, 0);
  if tr.trigtype = c_Trig_User then
  begin
    child.WriteAttributeFloat('ResX', tr.GetTime, 0);
  end
  else
  begin
    child.WriteAttributeinteger('SearchType', tr.fSearchIntervalType,
      c_TrigSearchInterval_No);
    if tr.SearchIntervalT1 <> nil then
    begin
      child.WriteAttributeString('SearchIntervalT1', tr.SearchIntervalT1.name,
        '');
    end;
    if tr.SearchIntervalT2 <> nil then
    begin
      child.WriteAttributeString('SearchIntervalT2', tr.SearchIntervalT2.name,
        '');
    end;
    p2 := tr.SearchInterval;
    child.WriteAttributeFloat('SearchIntervalX1', p2.x, 0);
    child.WriteAttributeFloat('SearchIntervalX2', p2.y, 0);

    child.WriteAttributeString('Signal', tr.TrigName, '');
    child.WriteAttributeinteger('Number', tr.number, -1);
    child.WriteAttributeFloat('Threshold', tr.Threshold, 0.5);
    // ��������� ����������
    child.WriteAttributeinteger('FltResample', tr.m_fltResample, -1);
    child.WriteAttributeBool('FltTrend', tr.m_fltTrend, false);
    child.WriteAttributeinteger('FltTrendNPoints', tr.m_fltTrendPoints, 100);
    child.WriteAttributeBool('FltHPF', tr.m_fltHPF, false);
    child.WriteAttributeinteger('FltHPFOrder', tr.m_fltHPFOrder, 300);
    child.WriteAttributeBool('FltLPF', tr.m_fltLPF, false);
    child.WriteAttributeinteger('FltLPFOrder', tr.m_fltLPFOrder, 300);
    child.WriteAttributeBool('FltH2', tr.m_fltH2, false);
    child.WriteAttributeinteger('FltH2NPoints', tr.m_fltH2Npoints, 1024);

    if tr.Front then
      child.WriteAttributeString('Front', 'true', 'true')
    else
      child.WriteAttributeString('Front', 'false', 'true');
    child.WriteAttributeinteger('SRCID', tr.srcid, 0);
    case tr.units of
      u_Abs:
        child.WriteAttributeString('Units', 'Abs', '');
      u_percent:
        child.WriteAttributeString('Units', '%', '');
      u_10Lg:
        child.WriteAttributeString('Units', '10Lg', '');
      u_20Lg:
        child.WriteAttributeString('Units', '20Lg', '');
    end;
  end;
  for i := 0 to tr.childcount - 1 do
  begin
    chTrig := cTrig(tr.getChild(i));
    Savetrig(child, chTrig, i);
  end;
end;

procedure cWPObjMng.XMLSaveMngAttributes(node: txmlnode);
var
  i, j, k, num: integer;
  src: cSrc;
  srcnode, child, signalNode: txmlnode;
  o: cOperObj;
  srcOpt: cSignalDesc;
  sOpts: cSignalsOpt;

  tr: cTrig;
begin
  inherited;

  srcnode := node.NodeNew('Triggers');
  num := 0;
  for i := 0 to TrigList.count - 1 do
  begin
    tr := cTrig(TrigList.Objects[i]);
    if tr.isHeader then
    begin
      Savetrig(srcnode, tr, num);
      inc(num);
    end;
  end;

  srcnode := node.NodeNew('SRC');
  for i := 0 to srcList.count - 1 do
  begin
    src := GetSrc(i);
    srcnode.WriteAttributeString('SRC_' + inttostr(i), src.name, '');
    srcnode.WriteAttributeinteger('SRCid_' + inttostr(i), src.id, -1);
    srcnode.WriteAttributeinteger('SRCopts_' + inttostr(i), src.IntervalOpts,
      c_IntervalAllTest);
    srcnode.WriteAttributeFloat('SRClevel_' + inttostr(i), src.TrigLevel, 0.5);
    if src.trigStart <> nil then
      srcnode.WriteAttributeString('SRCstart', src.trigStart.id, '');
    if src.trigStop <> nil then
      srcnode.WriteAttributeString('SRCstop', src.trigStop.id, '');
  end;
  // ����� ������
  node.WriteAttributeString('ResFolder', Resfolder);
  // ����� ���������
  node := node.NodeNew('Operators');
  for i := 0 to opers.count - 1 do
  begin
    o := GetOper(i);
    srcnode := node.NodeNew('Operator_' + inttostr(i));
    srcnode.WriteAttributeString('OperName', o.operStr, '');
    srcnode.WriteAttributeString('OperParams', o.params, '');
    srcnode.WriteAttributeinteger('OperIntervalType', o.Interval.intervaltype,
      c_IntervalAllTest);
    srcnode.WriteAttributeFloat('OperIntervalT1', o.Interval.t1, 0);
    srcnode.WriteAttributeFloat('OperIntervalT2', o.Interval.t2, 0);
    if o.Interval.start<>nil then
      srcnode.WriteAttributeString('OperIntervalTrig1', o.Interval.start.name,'');
    if o.Interval.stop<>nil then
      srcnode.WriteAttributeString('OperIntervalTrig2', o.Interval.stop.name, '');
    src := GetSrc(o.DstDir);
    if src <> nil then
    begin
      srcnode.WriteAttributeinteger('DstID', src.id, -1);
    end
    else
    begin
      srcnode.WriteAttributeinteger('DstID', o.DstID, -1);
    end;
    src := GetSrc(o.SrcDir);
    if src <> nil then
    begin
      srcnode.WriteAttributeinteger('SrcID', src.id, -1);
    end
    else
    begin
      srcnode.WriteAttributeinteger('SrcID', o.srcid, -1);
    end;
    for j := 0 to o.srcList.count - 1 do
    begin
      // ������� sOpts - ���� �������� ���������� ���������
      // ���� ��� ��������� ���������� �������������� ����� 5 c������� �� ����� 5 sOpts
      sOpts := o.GetSignalsOpts(j);
      signalNode := srcnode.NodeNew('s_' + inttostr(j));
      signalNode.WriteAttributeinteger('DSC_Count', sOpts.pathDstList.count, 0);
      // ����� ���������� ���������
      for k := 0 to sOpts.pathDstList.count - 1 do
      begin
        // ���� ���������� �������
        if o.fDstDir <> '' then
        begin
          signalNode.WriteAttributeString('DSC_' + inttostr(k),
            o.fDstDir + ExtractSignalName((sOpts.GetDst(k))), '');
        end
        else
          signalNode.WriteAttributeString('DSC_' + inttostr(k),
            sOpts.GetDst(k), '');
      end;
      signalNode.WriteAttributeinteger('SRC_Count', sOpts.pathSrcList.count, 0);
      // ����� ��������� ���������
      for k := 0 to sOpts.pathSrcList.count - 1 do
      begin
        if o.fSrcDir <> '' then
        begin
          signalNode.WriteAttributeString('SRC_Name_' + inttostr(k),
            o.fSrcDir + ExtractSignalName(sOpts.GetSrcName(k)), '');
        end
        else
        begin
          signalNode.WriteAttributeString('SRC_Name_' + inttostr(k),
            sOpts.GetSrcName(k), '');
        end;
        signalNode.WriteAttributeinteger('SRC_Start_' + inttostr(k),
          sOpts.GetSrcStart(k), 0);
        signalNode.WriteAttributeinteger('SRC_Count_' + inttostr(k),
          sOpts.GetSrcCount(k), 0);
      end;
    end;
  end;
end;

function LoadTrig(childNode: txmlnode; TrigList: tstringlist): cTrig;
var
  tr, childtr: cTrig;
  i, trtype: integer;
  str: string;
begin
  tr := nil;
  result := nil;
  if childNode <> nil then
  begin
    str := childNode.Name;
    if pos('Trig_', str) < 1 then
      exit;

    str := childNode.ReadAttributeString('NodeType', 'Trig');
    if str = 'Trig' then
    begin
      trtype := childNode.ReadAttributeInteger('TrigType', c_Trig_Search);
      if (trtype = c_Trig_Start) or (trtype = c_Trig_Stop) then
      begin
        if trtype = c_Trig_Start then
        begin
          tr := mng.GetStartTrig;
        end
        else
        begin
          tr := mng.GetStopTrig;
        end;
        tr.shift := childNode.ReadAttributeFloat('Shift', 0);
        exit;
      end;
      tr := cTrig.create;
      tr.processed := false;
      tr.trigtype := trtype;
      tr.list := TrigList;
      str := childNode.ReadAttributeString('NodeName', '');
      // str:=childNode.Name;
      tr.name := str;
      if tr.trigtype = c_Trig_User then
      begin
        tr.SetX(childNode.ReadAttributeFloat('ResX', 0));
      end
      else
      begin
        tr.SearchIntervalType := childNode.ReadAttributeInteger('SearchType',
          c_TrigSearchInterval_No);
        tr.SearchIntervalT1name := childNode.ReadAttributeString
          ('SearchIntervalT1', '');
        tr.SearchIntervalT2name := childNode.ReadAttributeString
          ('SearchIntervalT2', '');
        tr.fSearchInterval.x := childNode.ReadAttributeFloat
          ('SearchIntervalX1', 0);
        tr.fSearchInterval.y := childNode.ReadAttributeFloat
          ('SearchIntervalX2', 0);

        tr.TrigName := childNode.ReadAttributeString('Signal', '');

        tr.m_fltResample := childNode.ReadAttributeInteger('FltResample', -1);
        tr.m_fltTrend := childNode.ReadAttributeBool('FltTrend', false);
        tr.m_fltTrendPoints := childNode.ReadAttributeInteger
          ('FltTrendNPoints', 100);
        tr.m_fltHPF := childNode.ReadAttributeBool('FltHPF', false);
        tr.m_fltHPFOrder := childNode.ReadAttributeInteger('FltHPFOrder', 300);
        tr.m_fltLPF := childNode.ReadAttributeBool('FltLPF', false);
        tr.m_fltLPFOrder := childNode.ReadAttributeInteger('FltLPFOrder', 300);
        tr.m_fltLPF := childNode.ReadAttributeBool('FltH2', false);
        tr.m_fltLPFOrder := childNode.ReadAttributeInteger('FltH2NPoints',
          1024);

        tr.number := childNode.ReadAttributeInteger('Number', -1);
        tr.Threshold := childNode.ReadAttributeFloat('Threshold', 0.5);
        tr.shift := childNode.ReadAttributeFloat('Shift', 0);
        str := childNode.ReadAttributeString('Front', 'true');
        tr.Front := str = 'true';
        tr.srcid := childNode.ReadAttributeInteger('SRCID', 0);
        str := childNode.ReadAttributeString('Front', 'Abs');
        if str = 'Abs' then
        begin
          tr.units := u_Abs;
        end
        else
        begin
          if str = '%' then
          begin
            tr.units := u_percent;
          end
          else
          begin
            if str = '10Lg' then
            begin
              tr.units := u_10Lg;
            end
            else
            begin
              if str = '20Lg' then
              begin
                tr.units := u_20Lg;
              end
            end;
          end;
        end;
      end;
      tr.GenID;
      for i := 0 to childNode.NodeCount - 1 do
      begin
        childtr := LoadTrig(childNode.nodes[i], TrigList);
        if childtr <> nil then
          childtr.parent := tr;
      end;
      result := tr;
    end;
  end;
end;

procedure cWPObjMng.XMLlOADMngAttributes(node: txmlnode);
var
  n, srcnode, childNode: txmlnode;
  i, j, k, scount: integer;
  o: cOperObj;
  srcOpt: cSignalDesc;
  sOpts: cSignalsOpt;
  str, str1: string;
  b: boolean;
  src: cSrc;
  tr: cTrig;
begin
  inherited;
  ClearTrigs;
  AddSystemTrigs;

  Resfolder := node.ReadAttributeString('ResFolder', '');
  // ������ ��������
  srcnode := node.FindNode('Triggers');
  if srcnode <> nil then
  begin
    for i := 0 to srcnode.NodeCount - 1 do
    begin
      childNode := srcnode.nodes[i];
      str := childNode.name;
      LoadTrig(childNode, TrigList);
    end;
    for i := 0 to TrigList.count - 1 do
    begin
      tr := getTrig(i);
      if tr.SearchIntervalT1name <> '' then
      begin
        tr.SearchIntervalT1 := getTrig(tr.SearchIntervalT1name);
      end;
      if tr.SearchIntervalT2name <> '' then
      begin
        tr.SearchIntervalT2 := getTrig(tr.SearchIntervalT2name);
      end;
    end;
  end;
  mng.events.CallAllEvents(E_OnUpdateTrigs);
  // ������ ���������
  childNode := node.FindNode('SRC');
  if childNode <> nil then
  begin
    b := true;
    j := 0;
    while b do
    begin
      str := childNode.ReadAttributeString('SRC_' + inttostr(j));
      if str = '' then
      begin
        break;
      end;
      i := childNode.ReadAttributeInteger('SRCid_' + inttostr(j));
      src := getsrcid(i);
      if src <> nil then
      begin
        src.IntervalOpts := childNode.ReadAttributeInteger
          ('SRCopts_' + inttostr(j));
        src.TrigLevel := childNode.ReadAttributeFloat
          ('SRClevel_' + inttostr(j));
        str := childNode.ReadAttributeString('SRCstart', '');
        src.trigStart := mng.GetTrigWithID(str);
        str := childNode.ReadAttributeString('SRCstop', '');
        src.trigStop := mng.GetTrigWithID(str);
        src.EvalStartStop(nil);
      end;
      inc(j);
    end;
  end;
  // ������ ���������
  childNode := node.FindNode('Operators');
  if childNode = nil then
  begin
    g_logFile.addInfoMes('�� ������ ���� � ���������� Operators');
  end;
  if childNode <> nil then
  begin
    for i := 0 to childNode.NodeCount - 1 do
    begin
      n := childNode.nodes[i];
      str := n.ReadAttributeString('OperParams', '');
      str1 := n.ReadAttributeString('OperName', '');
      if str1 <> '' then
      begin
        // str1:=DeleteChars(str1,'"');
        o := AddOper(str1, str);
        o.DstID := n.ReadAttributeInteger('DstID', -1);
        o.srcid := n.ReadAttributeInteger('SrcID', -1);
      end
      else
        continue;
      o.Interval.intervaltype := srcnode.ReadAttributeInteger
        ('OperIntervalType', c_IntervalAllTest);
      o.Interval.t1 := srcnode.ReadAttributeFloat('OperIntervalT1', 0);
      o.Interval.t2 := srcnode.ReadAttributeFloat('OperIntervalT2', 0);

      str := srcnode.ReadAttributeString('OperIntervalTrig1', '');
      o.Interval.start := getTrig(str);
      str := srcnode.ReadAttributeString('OperIntervalTrig2', '');
      o.Interval.stop := getTrig(str);

      // ������ ���������
      for j := 0 to n.NodeCount - 1 do
      begin
        srcnode := n.nodes[j];
        scount := srcnode.ReadAttributeInteger('DSC_Count', 0);
        if scount = 0 then
          continue;
        // ������ ����������
        b := true;
        sOpts := cSignalsOpt.create(o);
        k := 0;
        while b do
        begin
          str := srcnode.ReadAttributeString('DSC_' + inttostr(k), '');
          inc(k);
          if str <> '' then
            sOpts.addDst(str)
          else
            b := false;
        end;
        // ����� ��������� ���������
        b := true;
        k := 0;
        while b do
        begin
          str := srcnode.ReadAttributeString('SRC_Name_' + inttostr(k), '');
          if str <> '' then
          begin
            srcOpt := cSignalDesc.create;
            srcOpt.path := str;
            srcOpt.i0 := srcnode.ReadAttributeInteger
              ('SRC_Start_' + inttostr(k), 0);
            srcOpt.count := srcnode.ReadAttributeInteger
              ('SRC_Count_' + inttostr(k), 0);
            sOpts.AddSrc(srcOpt);
          end
          else
          begin
            b := false;
          end;
          inc(k);
        end;
        o.AddSrc(sOpts);
      end;
    end;
  end;
end;

procedure cWPObjMng.save(path: string);
begin
  LastCfg := path;
  saveString(startDir + '\Services.ini', 'LastCfg', LastCfg);
  SaveToXML(path, 'Win���', true);
end;

procedure cWPObjMng.load(path: string);
begin
  if srcList.count = 0 then
    exit;
  ClearOpers;
  LastCfg := path;
  saveString(startDir + '\Services.ini', 'LastCfg', LastCfg);
  // ��� Load ��������� � ��������� ������ (����! )) )
  // LoadFromXML(path, 'Win���');
  ClearGraphs;
  AddFromXML(path, 'Win���');
end;

procedure cWPObjMng.ClearSRC;
var
  i: integer;
  src: cSrc;
begin
  for i := 0 to srcList.count - 1 do
  begin
    src := GetSrc(i);
    src.destroy;
  end;
  srcList.clear;
end;

function GetGraphX(g: integer): point2d;
begin
  IWPGraphs(wp.GraphApi).getXMinMax(g, result.x, result.y);
end;

function GetGraphCursorX(p, g: integer): point2d;
var
  ntrack: integer;
  v:double;
begin
  ntrack := IWPGraphs(wp.GraphApi).GetTrackMode(p);
  // 2-������� ������
  if (ntrack <> 8) then
  begin
    result := GetActiveGraphX;
    exit;
  end;
  IWPGraphs(wp.GraphApi).GetXCursorPos(g, &result.x, false);
  IWPGraphs(wp.GraphApi).GetXCursorPos(g, &result.y, true);
  if result.x>result.y then
  begin
    v:=result.x;
    result.x:=result.y;
    result.y:=v;
  end;
end;

function GetActiveGraphX: point2d;
var
  hpage, hgraph: integer;
begin
  result.x := 0;
  result.y := 0;
  if IWPGraphs(wp.GraphApi).GetPageCount = 0 then
  begin
    exit;
  end;
  hpage := IWPGraphs(wp.GraphApi).ActiveGraphPage;
  if (IWPGraphs(wp.GraphApi).GetGraphCount(hpage) <= 0) then
  begin
    exit;
  end;
  hgraph := IWPGraphs(wp.GraphApi).ActiveGraph(hpage);
  IWPGraphs(wp.GraphApi).getXMinMax(hgraph, result.x, result.y);
end;

function GetActiveCursorX: point2d;
var
  hpage, hgraph, hline, ntrack: integer;
begin
  result.x := 0;
  result.y := 0;
  if (IWPGraphs(wp.GraphApi).GetPageCount = 0) then
  begin
    exit;
  end;
  hpage := IWPGraphs(wp.GraphApi).ActiveGraphPage;
  if (IWPGraphs(wp.GraphApi).GetGraphCount(hpage) <= 0) then
  begin
    exit;
  end;
  hgraph := IWPGraphs(wp.GraphApi).ActiveGraph(hpage);
  // if (GraphApi.GetLineCount(hgraph)<= 0) then
  // exit;
  // hline:=GraphApi.GetLine(hgraph, 0);

  ntrack := IWPGraphs(wp.GraphApi).GetTrackMode(hpage);
  // 8-������� ������
  if (ntrack <> 8) then
  begin
    result := GetActiveGraphX;
    exit;
  end;
  IWPGraphs(wp.GraphApi).GetXCursorPos(hgraph, &result.x, false);
  IWPGraphs(wp.GraphApi).GetXCursorPos(hgraph, &result.y, true);
end;

function cWPObjMng.getTrig(i: integer): cTrig;
begin
  if i < TrigList.count then
    result := cTrig(TrigList.Objects[i])
  else
    result := nil;
end;

function cWPObjMng.getTrig(name: string): cTrig;
var
  i: integer;
begin
  if TrigList.create.Find(name, i) then
  begin
    result := cTrig(TrigList.Objects[i]);
  end
  else
    result := nil;
end;

procedure cWPObjMng.ProcessTrig(tr: cTrig; cb: TProcessEvent);
var
  ch: cTrig;
  error: boolean;
  src: cSrc;
  Signal: iwpsignal;
  i: integer;
  start, finish: double;
begin
  src := getsrcid(tr.srcid);
  if assigned(InfoCallBack) then
  begin
    InfoCallBack(nil, '���������� ������ �����������');
  end;
  Signal := src.GetSignal(tr.TrigName);
  if tr.trigtype = c_Trig_User then
  begin
    tr.processed := true;
  end
  else
  begin
    case tr.ftrigtype of
      c_Trig_Start:
        begin
          tr.x := src.t1;
          tr.processed := true;
          exit;
        end;
      c_Trig_Stop:
        begin
          tr.x := src.t2;
          tr.processed := true;
          exit;
        end;
    end;
    if Signal <> nil then
    begin
      start := Signal.MinX;
      finish := Signal.MaxX;
      case tr.SearchIntervalType of
        c_TrigSearchInterval_from:
          begin
            if tr.SearchIntervalT1 <> nil then
            begin
              start := tr.SearchIntervalT1.GetTime;
            end
            else
            begin
              start := tr.SearchInterval.x;
            end;
          end;
        c_TrigSearchInterval_to:
          begin
            if tr.SearchIntervalT2 <> nil then
            begin
              finish := tr.SearchIntervalT2.GetTime;
            end
            else
            begin
              finish := tr.SearchInterval.y;
            end;
          end;
        c_TrigSearchInterval_Interval:
          begin
            if tr.SearchIntervalT1 <> nil then
            begin
              start := tr.SearchIntervalT1.GetTime;
            end
            else
            begin
              start := tr.SearchInterval.x;
            end;
            if tr.SearchIntervalT2 <> nil then
            begin
              finish := tr.SearchIntervalT2.GetTime;
            end
            else
            begin
              finish := tr.SearchInterval.y;
            end;
          end;
      end;
      tr.GetTime(error, src, start, finish, cb);
    end
    else
    begin
      g_logFile.addInfoMes('�� ������ ������ ������� ��������: ' + tr.TrigName);
    end;
  end;
end;

procedure cWPObjMng.EvalTrigs(cb: TProcessEvent);
var
  i: integer;
  tr: cTrig;
begin
  for i := 0 to TrigList.count - 1 do
  begin
    tr := cTrig(TrigList.Objects[i]);
    if tr.isHeader then
    begin
      ProcessTrig(tr, cb);
    end;
  end;
end;

procedure cWPObjMng.ReadGraphs;
var
  i, j, k, n, lPageCount: integer;
  hpage, hgraph, haxis, hline: integer;

  page: cWPPage;
  graph: cWPGraph;

  axis: cWPAxis;
  line: cWPLine;

  sobj: cWPSignal;

  opt: integer;
  IWPs: iwpsignal;

  graphNode, l_node: iwpnode;
begin
  clear;
  graphNode := GetGraphRoot;
  // ���� �� ���������
  for i := 0 to GraphApi.GetPageCount - 1 do
  begin
    hpage := GraphApi.GetPage(i);
    // ����� ������ ��� 3� �������
    if hpage=0 then
      continue;
    page := cWPPage.create;
    page.setMng(self);
    page.hpage := hpage;
    page.graphtable.x := round(sqrt(GraphApi.GetGraphCount(hpage)));
    page.graphtable.y := round(sqrt(GraphApi.GetGraphCount(hpage)));

    // ���� �� ��������
    for j := 0 to GraphApi.GetGraphCount(hpage) - 1 do
    begin
      hgraph := GraphApi.GetGraph(hpage, j);
      graph := cWPGraph.create;
      graph.parent := page;
      graph.hgraph := hgraph;

      for k := 0 to graphNode.childcount - 1 do
      begin
        l_node := iwpnode(graphNode.at(i));
        if Supports(l_node.Reference, DIID_IWPGraphs) then
        begin
          if (graph.name = l_node.name) then
          begin
            graph.node := l_node;
          end;
        end;
      end;
      GraphApi.getXMinMax(hgraph, graph.ZoomXAxis.x, graph.ZoomXAxis.y);
      // 0 - �������� ����1���� ��� X
      GraphApi.GetAxisOpt(hgraph, 0, opt, graph.XAxis.x, graph.XAxis.y,
        graph.XName, graph.szftempl, graph.color);
      graph.LogX := CheckFlag(opt, AXOPT_Log);
      // ���� �� ����
      for k := 0 to GraphApi.GetYAxisCount(hgraph) - 1 do
      begin
        haxis := GraphApi.GetYAxis(hgraph, k);
        axis := cWPAxis.create;
        axis.parent := graph;
        axis.haxis := haxis;
        GraphApi.GetYAxisMinMax(haxis, axis.ZoomAxis.x, axis.ZoomAxis.y);
        GraphApi.GetAxisOpt(hgraph, haxis, opt, axis.MinMax.x, axis.MinMax.y,
          axis.szName, axis.szftempl, axis.color);
        axis.log := CheckFlag(opt, AXOPT_Log);
      end;
      // ���� �� ������
      for k := 0 to GraphApi.GetLineCount(hgraph) - 1 do
      begin
        hline := GraphApi.GetLine(hgraph, k);
        sobj := GetSignalByHLine(hline);
        if sobj <> nil then
        begin
          if pos('.tuf', sobj.name) < 1 then
          begin
            line := cWPLine.create;
            line.hline := hline;
            GraphApi.getlineopt(line.hline, opt, $FFFF, line.width, line.color);
            // �� ����������� � ����� ��� ����� �����
            axis := graph.GetAxisByLine(hline);
            line.parent := axis;
            GetIWPSignalByHLine(hline);
            line.Signal := sobj;
            IWPs := GetIWPSignalByHLine(hline);
            line.signalname := IWPs.sname;
            // line.color:=clBlue;
            // line.width:=1;
            line.VISIBLE := true;
            line.HISTTRANSP := true;
            line.LINE2BASE := CheckFlag(opt, LNOPT_LINE2BASE);
            // GraphApi.get(haxis, axis.ZoomAxis.x, axis.ZoomAxis.y);
            if line.Signal <> nil then
            begin
              line.hSignal := line.Signal.Signal.Instance;
              if line.Signal.ConnectToUsml then
                line.srcName := GetIWPUsmlByHLine(hline).FileName
              else
                line.srcName := GetIWPNodeByHLine(hline).AbsolutePath;
              line.srcid := GetSrcBySignal(line.Signal).id;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure cWPObjMng.AddSystemTrigs;
var
  t: cTrig;
begin
  t := cTrig.create;
  t.trigtype := c_Trig_Start;
  t.TrigName := '����� ������';
  t.GenID;
  TrigList.AddObject(t.id, t);

  t := cTrig.create;
  t.TrigName := '���� ������';
  t.trigtype := c_Trig_Stop;
  t.GenID;
  TrigList.AddObject(t.id, t);

end;

procedure cWPObjMng.ClearGraphs;
var
  i: integer;
  obj: cWPObj;
  cycl: boolean;
begin
  i := 0;
  cycl := true;
  while cycl do
  begin
    obj := cWPObj(Objects.getObj(i));
    if obj = nil then
      exit;
    if (obj is cSrc) or (obj is cWPSignal) then
    begin
      inc(i);
      if i > Objects.count - 1 then
      begin
        cycl := false;
      end;
      continue;
    end
    else
    begin
      Objects.deletechild(i);
      if i > Objects.count - 1 then
      begin
        cycl := false;
      end;
    end;
  end;
end;

procedure cWPObjMng.CreateGraphs;
var
  i, j, k, n: integer;

  obj: cWPObj;
  page: cWPPage;
  graph: cWPGraph;
  axis: cWPAxis;
  line: cWPLine;
  src: cSrc;

  hinst: integer;
begin
  for i := 0 to count - 1 do
  begin
    obj := getWPObj(i);
    if obj is cWPPage then
    begin
      // ������� ��������
      page := cWPPage(obj);
      page.hpage := GraphApi.CreatePage;
      // ��������� ����� �������� ��������
      page.ApplyOpts;
      for j := 0 to page.childcount - 1 do
      begin
        obj := cWPObj(page.getChild(j));
        if obj is cWPGraph then
        begin
          graph := cWPGraph(page.getChild(j));
          // ������� �������
          if j = 0 then
            graph.hgraph := GraphApi.GetGraph(page.hpage, j)
          else
            graph.hgraph := GraphApi.CreateGraph(page.hpage);
          graph.ApplyOpts;
          for k := 0 to graph.childcount - 1 do
          begin
            obj := cWPAxis(graph.getChild(k));
            if obj is cWPAxis then
            begin
              // ������� ���
              axis := cWPAxis(obj);
              if k > 0 then
                axis.haxis := GraphApi.CreateYAxis(cWPGraph(axis.parent).hgraph)
              else
                axis.haxis := GraphApi.GetYAxis(cWPGraph(axis.parent).hgraph,
                  k);
              // ������� �����
              for n := 0 to axis.childcount - 1 do
              begin
                obj := cWPObj(axis.getChild(n));
                if obj is cWPLine then
                begin
                  src := getsrcid(cWPLine(obj).srcid);
                  if src <> nil then
                  begin
                    cWPLine(obj).Signal := src.getSignalObj
                      (cWPLine(obj).signalname);
                    if cWPLine(obj).Signal <> nil then
                    begin
                      if cWPLine(obj).Signal.tube <> nil then
                        if graph.tubes then
                        begin
                          axis.tube := cWPLine(obj).Signal.tube;
                          axis.tube.CreateLines(graph, axis);
                        end;
                      // ��������� � cWPLine Load.ObjAttributes
                      if cWPLine(obj).Signal <> nil then
                      begin
                        cWPLine(obj).hline := GraphApi.createline
                          (cWPGraph(cWPAxis(axis).parent).hgraph, axis.haxis,
                          cWPLine(obj).Signal.Signal.Instance);
                        cWPLine(obj).ApplyOpts;
                      end;
                    end;
                  end;
                end;
              end;
              // ����� ��������� ����� ��� ����� �������� ��������, �����
              // ����� �������
              axis.ApplyOpts;
            end;
          end;
        end;
      end;
      winpos.Refresh;
    end;
  end;
end;

function cWPObjMng.getWPAx(haxis: integer): cWPAxis;
var
  i: integer;
  obj: cBaseObj;
begin
  result := nil;
  for i := 0 to count - 1 do
  begin
    obj := getObj(i);
    if obj is cWPAxis then
    begin
      if cWPAxis(obj).haxis = haxis then
      begin
        result := cWPAxis(obj);
      end;
    end;
  end;
end;

constructor cWPObjMng.create;
begin
  inherited;

  // ������� ���������������� ����������� ������
  fsTrig := 1000;

  ProgressStr := '��������';

  TrigList := tstringlist.create;
  TrigList.Sorted := true;
  AddSystemTrigs;

  srcList := tstringlist.create;
  srcList.Sorted := true;
  GraphApi := winpos.GraphApi as IWPGraphs;

  algList := tstringlist.create;
  algList.Sorted := true;

  tubes := tstringlist.create;
  tubes.Sorted := true;

  opers := tstringlist.create;
  // opers.Sorted:=true;
  root := GetWPRoot;

  LastCfg := LoadString(startDir + 'Services.ini', 'LastCfg');
end;


procedure cWPObjMng.delTrig(tr: ctrig);
var
  I: Integer;
begin
  for I := 0 to TrigList.Count - 1 do
  begin
    if triglist.Objects[i]=tr then
    begin
      triglist.Delete(i);
      tr.destroy;
      exit;
    end;
  end;
end;

destructor cWPObjMng.destroy;
var
  i: integer;
  tube: cWPTube;
  trig: cTrig;
begin
  inherited;
  // ������� ������ �� ����������
  ClearOpers;
  opers.destroy;
  srcList.destroy;
  algList.destroy;
  g_logFile.destroy;
  for i := 0 to tubes.count - 1 do
  begin
    tube := cWPTube(tubes.Objects[i]);
    tube.destroy;
  end;
  tubes.destroy;

  for i := 0 to TrigList.count - 1 do
  begin
    trig := cTrig(TrigList.Objects[i]);
    trig.destroy;
  end;
  TrigList.destroy;
end;

function cWPObjMng.AddSrc(name: string; id: integer; m: idispatch): cSrc;
var
  obj: cSrc;
  i: integer;
  t: cWPTube;
begin
  for i := 0 to tubes.count - 1 do
  begin
    t := cWPTube(tubes.Objects[i]);
    if name[length(name)] <> '/' then
    begin
      if t.folder = name + '/' then
        exit;
    end
    else
    begin
      if t.folder = name then
        exit;
    end;
  end;
  obj := cSrc.create(m);
  obj.id := id;
  // obj.name := GetSName(name);
  obj.name := name;
  obj.setMng(self);

  srcList.AddObject(obj.name, obj);
  result := obj;
end;

function cWPObjMng.GetStartTrig: cTrig;
var
  i: integer;
  tr: cTrig;
begin
  for i := 0 to TrigList.count - 1 do
  begin
    tr := getTrig(i);
    if tr.trigtype = c_Trig_Start then
    begin
      result := tr;
      exit;
    end;
  end;
end;

function cWPObjMng.FindTube(n:iwpnode):cwptube;
var
  I: Integer;
  t:cwptube;
begin
  result:=nil;
  for I := 0 to tubes.Count - 1 do
  begin
    t:=cwptube(tubes.Objects[i]);
    if (t.n_pr.Instance=n.Instance) or (t.n_l.Instance=n.Instance)
    or (t.n_ll.Instance=n.Instance) or (t.n_h.Instance=n.Instance)
    or (t.n_hh.Instance=n.Instance) then
    begin
      result:=t;
      exit;
    end;
  end;
end;

function cWPObjMng.loadsrc(str:string):csrc;
begin
  result:=nil;
  if fileexists(str) then
    WP.LoadUSML(str)
  else
    exit;
  result := GetSrc(str);
end;

function cWPObjMng.GetStopTrig: cTrig;
var
  i: integer;
  tr: cTrig;
begin
  for i := 0 to TrigList.count - 1 do
  begin
    tr := getTrig(i);
    if tr.trigtype = c_Trig_Stop then
    begin
      result := tr;
      exit;
    end;
  end;
end;

function cWPObjMng.AddSrc(name: string): cSrc;
var
  obj: cSrc;
  i: integer;
  t: cWPTube;
begin
  for i := 0 to tubes.count - 1 do
  begin
    t := cWPTube(tubes.Objects[i]);
    if name[length(name)] <> '/' then
    begin
      if t.folder = name + '/' then
        exit;
    end
    else
    begin
      if t.folder = name then
        exit;
    end;
  end;
  obj := cSrc.create(name);
  obj.setMng(self);
  obj.id := srcList.count;

  srcList.AddObject(obj.name, obj);
  result := obj;
end;

procedure cWPObjMng.doAddNode(p: string);
var
  d: idispatch;
  usml: iwpusml;
  n, parent: iwpnode;
  i: integer;
  src: cSrc;
  path, dir: string;
  rename: boolean;
  s: iwpsignal;
  sobj: cWPSignal;
  // root:iwpnode;
begin
  // ���� ����������� ������
  if pos('Signals', p) > 0 then
  begin
    if p[9] <> '/' then
    begin
      path := Copy(p, 9, length(p) - 8);
      path := '/Signals/' + path;
      p := path;
    end;
    // �������� ������ ���� �� �����
    for i := length(p) downto 1 do
    begin
      if p[i] = '/' then
      begin
        if i > 1 then
        begin
          if p[i - 1] = '/' then
          begin
            path := p;
            setlength(path, i - 1);
            path := path + Copy(p, i + 1, length(p) - i);
            p := path;
            break;
          end;
        end;
      end;
    end;
    d := wp.GetNodeStr(p);

    // ���� ������������ �����
    rename := false;
    if IsSrc(d) or isUSML(d) then
    begin
      for i := 0 to srcList.count - 1 do
      begin
        src := GetSrc(i);
        // ���� �������� � �����
        if isNode(d) then
        begin
          n := d as iwpnode;
          if n.Instance = src.node.Instance then
          begin
            rename := true;
            renamesrc(src, p);
            // ��������� �� ��������� �� � ��������� ����� �������
            src.UpdateSrc;
          end
          else
          begin
            if Supports(n.Reference, DIID_IWPUSML) then
            begin
              usml := n.Reference as iwpusml;
              if usml = src.merafile then
              begin
                rename := true;
                renamesrc(src, p);
              end;
            end;
          end;
        end;
      end;
      // ���� ��� ����� ���� � ���������
      if not rename then
      begin
        AddSrc(p);
      end;
    end;
    // ���� �������� ������
    if IsSignal(d) then
    begin
      n := d as iwpnode;
      parent := getparentnode(n);
      dir := parent.AbsolutePath;
      src := GetSrc(dir);
      if src = nil then
      begin
        if dir[length(dir)] = '/' then
        begin
          setlength(dir, length(dir) - 1);
        end;
        AddSrc(dir);
      end
      else
      begin
        if Supports(d, DIID_IWPSignal) then
        begin
          s := d as iwpsignal;
          sobj := src.CreateSignal(s);
        end;
        if Supports(d, DIID_IWPNode) then
        begin
          if Supports((d as iwpnode).Reference, DIID_IWPSignal) then
          begin
            s := (d as iwpnode).Reference as iwpsignal;
            sobj := src.CreateSignal(s);
          end;
        end;
      end;
    end;
  end;
end;

procedure cWPObjMng.ClearTrigs;
var
  t: cTrig;
  i: integer;
begin
  for i := 0 to TrigList.count - 1 do
  begin
    t := cTrig(TrigList.Objects[i]);
    t.destroy;
  end;
  TrigList.clear;
end;

function cWPObjMng.GetTrigWithID(id: string): cTrig;
var
  i: integer;
begin
  result := nil;
  for i := 0 to TrigList.count - 1 do
  begin
    if cTrig(TrigList.Objects[i]).id = id then
    begin
      result := cTrig(TrigList.Objects[i]);
    end;
  end;
end;

procedure cWPObjMng.renamesrc(s: cSrc; str: string);
var
  i, j, len: integer;
  s2: cSrc;
  o: cOperObj;
  path: string;
begin
  for i := 0 to srcList.count - 1 do
  begin
    s2 := GetSrc(i);
    if s2 = s then
    begin
      for j := 0 to opers.count - 1 do
      begin
        o := GetOper(j);
        // ��������������� ��������� � ����������
        path := o.SrcDir;
        len := length(path);
        if path[len] = '/' then
          setlength(path, len - 1);
        if path = s.name then
        begin
          o.SrcDir := str + '/';
        end;
        // ��������������� ���������� � ����������
        path := o.DstDir;
        len := length(path);
        if path[len] = '/' then
          setlength(path, len - 1);
        if path = s.name then
        begin
          o.DstDir := str + '/';
        end;
      end;
      srcList.Delete(i);
      s.name := str;
      srcList.AddObject(str, s);
      exit;
    end;
  end;
end;

procedure cWPObjMng.doAddSignal(s: string);
var
  d: idispatch;
  wp_s: iwpsignal;
  signalNode: iwpnode;
  wpsignal: cWPSignal;
  srcPath: string;
  src: cSrc;
  i: integer;
begin
  d := wp.Get(s);
  if IsSignal(d) then
  begin
    wp_s := d as iwpsignal;
    d := wp.GetNode(wp_s);
    signalNode := d as iwpnode;
    wpsignal := cWPSignal.create(signalNode);
    // ���� ����� ���������
    srcPath := signalNode.AbsolutePath;
    srcPath := ExtractSignalFolder(srcPath);
    d := wp.Get(srcPath);
    if srcList.Find(srcPath, i) then
    begin
      src := GetSrc(i);
    end
    else
    begin
      src := AddSrc(srcPath);
    end;
    if src <> nil then
    begin
      wpsignal.src := src;
    end;
  end;
end;

procedure cWPObjMng.doRenamedNode(n: cardinal);
var
  i, index: integer;
  Instance: cardinal;
  s: cSrc;
  newname, endPath: string;
  node: iwpnode;
begin
  endPath := '';
  for i := 0 to SrcCount - 1 do
  begin
    s := GetSrc(i);
    node := s.node;
    while (node <> nil) do
    begin
      Instance := node.Instance;
      if n = Instance then
      begin
        newname := s.node.AbsolutePath + '/' + endPath;
        // ���� ��������� ������ ����
        renamesrc(s, newname);
        exit;
      end;
      endPath := node.name + '/' + endPath;
      node := getparentnode(node);
      if node.Instance = root.Instance then
      begin
        node := nil;
      end;
    end;
  end;
end;

procedure cWPObjMng.doDestroyNode(n: cardinal);
var
  i, j: integer;
  Instance: cardinal;
  s: cSrc;
  obj: cWPObj;
  Signal: cWPSignal;
  node, ch:wpnode;
  t:cwptube;
begin
  // ��������� �� ����������
  i := 0;
  while i <= SrcCount - 1 do
  begin
    s := GetSrc(i);
    for j := 0 to s.childcount - 1 do
    begin
      Signal := s.getSignalObj(j);
      if Signal.node.Instance = n then
      begin
        Signal.destroy;
        // �� ��������� �������� (���������� � ����������� �������)
        exit;
      end;
    end;
    Instance := s.GetNodeInstance;
    if n = Instance then
    begin
      // ���������� ���� 04.01.2017
      events.CallAllEventsWithSender(E_OnDestroySrc, s);
      s.destroy;
      srcList.Delete(i);
      // events.CallAllEventsWithSender(E_OnDestroySrc);
      exit;
    end
    else
      inc(i);
  end;
  // ���� ��������� ���� �� �������� ���������� ������. �������� ����� � �������� �������
  node:=findnode(n);
  if node<>nil then
  begin
    for I := 0 to node.ChildCount - 1 do
    begin
      ch:=node.At(i) as iwpnode;
      t:=FindTube(ch);
      if t<>nil then
      begin
        t.destroy;
      end;
    end;
  end;
end;

function cWPObjMng.GetCurSrcInMainWnd: cSrc;
var
  d: idispatch;
  n: iwpnode;
  m: iwpusml;
  src: cSrc;
  isig: iwpsignal;
  s: cWPSignal;
  str: string;
  i, hpage, hline, hgraph: integer;
begin
  src := nil;
  d := winpos.GetSelectedObject;
  // ���� iwpNode
  if IsSrc(d) then
  begin
    n := TypeCastToIWNode(d);
    src := GetSrc(n.AbsolutePath);
    result := src;
    exit;
  end
  else
  begin
    if Supports(d, DIID_IWPUSML) then
    begin
      m := TypeCastToIWPUSML(d);
      src := mng.GetSrc(m.FileName);
      result := src;
      exit;
    end;
    if IsSignal(d) then
    begin
      src := GetSrcBySignal(d);
      result := src;
      exit;
    end;
    // �������� �� ������ ���� ������ ��������
    // (�������� ����� ������� �����������)
    d := winpos.GetSelectedNode;
    n := TypeCastToIWNode(d);
    // �������� ���� ���� ������� �������
    if n = nil then
    begin
      result := nil;
      if (GraphApi.GetPageCount = 0) then
      begin
        exit;
      end;
      hpage := GraphApi.ActiveGraphPage;
      if GraphApi.GetGraphCount(hpage) = 0 then
      begin
      end
      else
      begin
        hgraph := GraphApi.ActiveGraph(hpage);
        if GraphApi.GetLineCount(hgraph) = 0 then
        begin
        end
        else
        begin
          hline := GraphApi.GetLine(hgraph, 0);
          s := GetSignalByHLine(hline);
          result := s.src;
          exit;
        end;
      end;
    end
    else
    begin
      src := GetSrc(n.AbsolutePath);
      result := src;
      exit;
    end;
  end;
  // �������� �� ����� ���������� getSelectObject
  if src = nil then
  begin
    if SrcCount > 0 then
    begin
      src := cSrc(srcList.Objects[i]);
      result := src;
    end;
  end;
end;

function cWPObjMng.GetCurSrc: cSrc;
var
  d: idispatch;
  n: iwpnode;
  m: iwpusml;
  isig: iwpsignal;
  s: cWPSignal;
  str: string;
  i: integer;
begin
  if fcurSrc <> nil then
  begin
    result := fcurSrc;
    exit;
  end
  else
  begin
    d := winpos.GetSelectedObject;
    // ���� iwpNode
    if IsSrc(d) then
    begin
      n := TypeCastToIWNode(d);
      fcurSrc := GetSrc(n.AbsolutePath);
      result := fcurSrc;
      exit;
    end
    else
    begin
      if Supports(d, DIID_IWPUSML) then
      begin
        m := TypeCastToIWPUSML(d);
        fcurSrc := mng.GetSrc(m.FileName);
        result := fcurSrc;

        exit;
      end;
      if IsSignal(d) then
      begin
        fcurSrc := GetSrcBySignal(d);
        result := fcurSrc;
        exit;
      end;
      // �������� �� ������ ���� ������ ��������
      // (�������� ����� ������� �����������)
      d := winpos.GetSelectedNode;
      n := TypeCastToIWNode(d);
      if n <> nil then
      begin
        fcurSrc := GetSrc(n.AbsolutePath);
        result := fcurSrc;
        exit;
      end
      else
        result := nil;
    end;
  end;
end;

procedure cWPObjMng.SetCurSrc(s: cSrc);
begin
  fcurSrc := s;
end;

procedure cWPObjMng.ApplyOperator(o: cOperObj);
var
  oper: iwpOperator;
  extOper: IWPExtOper;
  ole_src1, ole_src2, ole_dst1, ole_dst2, ole_OptFFT, ole_Err: OleVariant;
  s: iwpsignal;
  str, folder: string;
  sOpts: cSignalsOpt;
  node: iwpnode;
  s1, s2: iwpsignal;
  sig, resSignal: cWPSignal;
  src: cSrc;
  i: integer;
begin
  // -- �������� ������ � ���������� ���������
  // -- (������ ������� ���������� ����� ����� � ���� "���������")
  // �������� "����������"
  oper := winpos.GetObject(o.operStr) as iwpOperator;
  // -- ������ ��������� ���������
  // -- �����! �����, ��������, ������� � ����� "=" �.�. �������� ���������
  // -- ����������. 1) ����� oper.Exec ��� oper.LoadProperties �������� �
  // -- ������������� ���������� �������� �� ���������.
  // -- 2) ������ LoadProperties ����� ��������������� ���������� LoadProperty,
  // -- ������� ��������� ��������� �������� ��� ��������� ��������� ���������
  // oper.LoadProperties(' kindFunc = 3 , numPoints = 1024 , nBlocks = 1 , typeWindow = 1 , '+
  // ' ofsNextBlock = 1024, typeMagnitude = 2 , type = 0 , isMO = 1 , '+
  // ' isCorrectFunc = 0 , fLog = 0, useOpZn = 1, OpZn = 0');
  str := ConvertPropertieStr(o.params);
  //str:=ChangeParamF(str, 'nBlocks', '1');
  oper.LoadProperties(str);
  for i := 0 to o.srcList.count - 1 do
  begin
    sOpts := o.GetSignalsOpts(i);
    // ������������ ������ ���� ������! ���� ��� ������� ������� ��� ��������� � ��� ������� ����,
    // �� �������� ������� ������������ ����� ������� ���� ���������� � �� ��������� ���������
    if sOpts.srcSignals.count = 0 then
      continue;
    sig := cWPSignal(sOpts.srcSignals[0]);

    curSrc := mng.GetSrcBySignal(sig);
    s1 := sig.getProcSignal(o.Interval.t1, o.Interval.t2);
    ole_src1 := s1;
    // ��� ���������� � ����� ��������� �� ����� �������� ����
    if sOpts.srcSignals.count > 1 then
    begin
      s2 := cWPSignal(sOpts.srcSignals[1]).getProcSignal(o.Interval.t1,
        o.Interval.t2);
      ole_src2 := s2;
    end
    else
    begin
      ole_src2 := s1;
    end;
    // s:=iwpsignal(TVarData(ole_src1).VPointer);
    oper.Exec(ole_src1, ole_src2, refvar(ole_dst1), refvar(ole_dst2));
    // -- ������� ��������� � ������ Win���
    s := iwpsignal(TVarData(ole_dst1).VPointer);
    // ���� �������� �������� �������
    if s <> nil then
    begin
      str := sOpts.GetDst(0);
      s.sname := ExtractSignalName(str);
      // folder := ExtractSignalFolder(str);
      folder := o.DstDir;
      // folder:=DeleteChars(folder,'"');
      if folder[length(folder)] <> '/' then
        folder := folder + '/';
      // winpos.Link( 'Signals/', s.sname, s );
      // � ���� folder=Signals/����������/ � s.sname=3- 1
      winpos.Link(folder, s.sname, s);
      // � ������ ��������� ������ ���� ��� �����
      if folder[length(folder)] = '/' then
        setlength(folder, length(folder) - 1);
      src := GetSrc(folder);
      if src = nil then
      begin
        src := AddSrc(folder);
        src.id := o.DstID;
        resSignal := src.getSignalObj(s.sname);
        resSignal.tube := cWPSignal(sOpts.srcSignals[0]).tube;
      end
      else
      begin
        resSignal := src.CreateSignal(s);
        resSignal.tube := cWPSignal(sOpts.srcSignals[0]).tube;
      end;
    end;
  end;
  winpos.Refresh;
end;

function ConvertPropertieStr(s: string): string;
var
  i: integer;
begin
  result := ' ';
  for i := 1 to length(s) do
  begin
    if (s[i] = ',') or (s[i] = '=') then
    begin
      result := result + ' ';
      result := result + s[i];
      result := result + ' ';
    end
    else
      result := result + s[i];
  end;
end;

function cWPObjMng.GetSelectedSrc: cSrc;
begin
  result := nil;
  if m_selectedSrc = nil then
  begin
    result := GetSrc(0);
    if result <> nil then
      m_selectedSrc := result;
  end
  else
    result := m_selectedSrc;
end;

function IsDir(name: string): boolean;
begin
  if fileexists(name) then
    result := true
  else
    result := false;
end;

function cWPObjMng.GetSrc(name: string): cSrc;
var
  i: integer;
begin
  result := nil;
  if name = '' then
    exit;
  // ������� 07.01.2017 - WinPos ��������������� �������� ���� ���� ������ ����������
  // ��������� �� ����� �� ������ �����
  if IsDir(name) then
  begin
    for i := 0 to SrcCount - 1 do
    begin
      result := GetSrc(i);
      if not result.bnode then
      begin
        if lowercase(name) = lowercase(result.merafile.FileName) then
          exit;
      end;
    end;
    result := nil;
    /// ���� �� ������ 2017
    /// name := '/Signals/' + (ExtractSignalName(name));
  end;
  i := length(name);
  if name[i] = '/' then
    setlength(name, i - 1);
  if srcList.Find(name, i) then
  begin
    result := cSrc(srcList.Objects[i]);
  end;
end;

function cWPObjMng.SrcCount: integer;
begin
  result := srcList.count;
end;

function cWPObjMng.GetSrc(i: integer): cSrc;
begin
  if srcList.count > 0 then
    result := cSrc(srcList.Objects[i])
  else
    result := nil;
end;

function cWPObjMng.GetSrcBySignal(s: cWPSignal): cSrc;
var
  path: string;
begin
  if s <> nil then
  begin
    path := trimPath(s.node.AbsolutePath);
    result := GetSrc(path);
  end;
end;

function cWPObjMng.GetSrcBySignal(s: idispatch): cSrc;
var
  path, str: string;
  n: iwpnode;
  i: integer;
begin
  result := nil;
  if IsSignal(s) then
  begin
    n := wp.GetNode(s) as iwpnode;
    str := n.AbsolutePath;
    for i := length(str) downto 1 do
    begin
      if str[i] = '/' then
      begin
        setlength(str, i);
        fcurSrc := mng.GetSrc(str);
        result := fcurSrc;
        exit;
      end;
    end;
  end;
end;

procedure cWPObjMng.execute;
var
  i: integer;
  o: cOperObj;
begin
  Progress := 0;
  ProgressStr := '��������� ������';
  if assigned(OnUpdateStatus) then
    OnUpdateStatus(self);
  for i := 0 to opers.count - 1 do
  begin
    o := GetOper(i);
    // �������� ������ ��������
    o.PrepareSignalsID;
    if o.fstatus = c_AlgStatusOk then
    begin
      ApplyOperator(o);
      Progress := trunc(100 * (i + 1) / opers.count);
      if assigned(OnUpdateStatus) then
        OnUpdateStatus(self);
    end
    else
      continue;
  end;
  events.CallAllEvents(E_OnEndProcess);
  ProgressStr := '��������';
  Progress := 0;
  if assigned(OnUpdateStatus) then
    OnUpdateStatus(self);
  ReadResults;
end;

procedure cWPObjMng.OnExecuteOper(alg: string; src: string);
begin

end;

function cWPObjMng.getsrcid(id: integer): cSrc;
var
  i: integer;
  src: cSrc;
begin
  result := nil;
  for i := 0 to srcList.count - 1 do
  begin
    src := cSrc(srcList.Objects[i]);
    if src.id = id then
    begin
      result := src;
      exit;
    end;
  end;
end;

// wpenumProc = function(obj:iwpnode; data:pointer):boolean;
function enumReadSRC(obj: iwpnode; data: pointer): boolean;
var
  d: idispatch;
  m: iwpusml;
  src: cSrc;
  p2: point2d;
begin
  result := true;
  // ���� ���� �������� ���� �������
  if IsSrc(obj) then
  begin
    cWPObjMng(data).AddSrc(obj.AbsolutePath, cWPObjMng(data).srcList.count,
      obj);
  end
  else
  begin
    d := obj.Reference;
    if Supports(d, DIID_IWPUSML) then
    begin
      m := d as iwpusml;
      src := cWPObjMng(data).AddSrc(obj.AbsolutePath,
        cWPObjMng(data).srcList.count, m);
      src.node := obj;
      p2 := src.EvalStartStop(nil);
      src.t1 := p2.x;
      src.t2 := p2.y;
    end;
  end;
end;

procedure cWPObjMng.clear;
begin
  inherited;
end;

procedure cWPObjMng.ReadSrc;
var
  node: iwpnode;
  b: boolean;
begin
  // if not extPack.init then
  begin
    extPack.init := true;
    ClearSRC;
    node := iwpnode((winpos.Get('/signals')));
    b := true;
    EnumGroupMembers(enumReadSRC, node, self, b);
  end;
end;

function enumReadSRCResults(obj: iwpnode; data: pointer): boolean;
var
  d: idispatch;
  m: iwpusml;
  src, oldSrc: cSrc;
begin
  result := true;
  oldSrc := cWPObjMng(data).GetSrc(obj.AbsolutePath);
  if (oldSrc <> nil) then
    exit;
  // ���� ���� �������� ���� �������
  if IsSrc(obj) then
  begin
    cWPObjMng(data).AddSrc(obj.AbsolutePath, cWPObjMng(data).srcList.count,
      obj);
  end
  else
  begin
    d := obj.Reference;
    if Supports(d, DIID_IWPUSML) then
    begin
      m := d as iwpusml;
      src := cWPObjMng(data).AddSrc(obj.AbsolutePath,
        cWPObjMng(data).srcList.count, m);
    end;
  end;
end;

procedure cWPObjMng.ReadResults;
var
  node: iwpnode;
  b: boolean;
begin
  node := iwpnode((winpos.Get('/signals')));
  b := true;
  EnumGroupMembers(enumReadSRCResults, node, self, b);
end;

function cWPObjMng.GetIWPUsmlByHLine(hline: integer): iwpusml;
var
  s: iwpsignal;
begin
  s := GetIWPSignalByHLine(hline);
  result := GetIWPUsmlByIWPSignal(s);
end;

function cWPObjMng.GetIWPUsmlByIWPSignal(s: iwpsignal): iwpusml;
var
  node: iwpnode;
  str: string;
begin
  result := nil;
  node := TypeCastToIWNode(winpos.GetNode(s));
  if node <> nil then
  begin
    str := node.AbsolutePath;
    str := trimPath(str);
    result := TypeCastToIWPUSML(winpos.GetObjectStr(str));
  end;
end;

function cWPObjMng.GetIWPNodeByHLine(hline: integer): iwpnode;
var
  s: iwpsignal;
  node: iwpnode;
  str: string;
begin
  result := nil;
  s := GetIWPSignalByHLine(hline);
  node := TypeCastToIWNode(winpos.GetNode(s));
  if node <> nil then
  begin
    str := node.AbsolutePath;
    str := trimPath(str);
    setlength(str, length(str) - 1);
    result := TypeCastToIWNode(winpos.GetNodeStr(str));
  end;
end;

function cWPObjMng.GetIWPUsml(i: integer): iwpusml;
var
  src: cSrc;
begin
  src := GetSrc(i);
  result := src.merafile;
end;

function cWPObjMng.GetSrcName(i: integer): string;
var
  src: cSrc;
begin
  src := GetSrc(i);
  if src.bnode then
  begin
    result := src.node.AbsolutePath;
  end
  else
  begin
    result := src.merafile.FileName;
  end;
end;

function cWPObjMng.AddHelpTrig: cWPSignal;
var
  src: cSrc;
  hpage, hgraph, hline, ntrack: integer;
  x, dx: double;
  s: iwpsignal;
  i: integer;
  tr: cTrig;
  n, child: iwpnode;
  str: string;
begin
  if (GraphApi.GetPageCount = 0) then
  begin
    exit;
  end;
  src := GetCurSrcInMainWnd;
  if src = nil then
    exit;
  hpage := GraphApi.ActiveGraphPage;
  if (GraphApi.GetGraphCount(hpage) <= 0) then
  begin
    exit;
  end;
  hgraph := GraphApi.ActiveGraph(hpage);
  // 8-������� ������
  // nTrack:=GraphApi.GetTrackMode(hpage);
  ntrack := GraphApi.GetCursorType(hpage);
  // 1 - ��������� �� X; 2 - ������� �� X 3- ��������� �� Y, 4 - ������� �� Y
  if (ntrack = 1) or (ntrack = 2) then
  begin
    dx := 1 / fsTrig;
    GraphApi.GetXCursorPos(hgraph, x, false);
    // ������� ���������� ������
    s := wp.CreateSignal(VT_I1) as iwpsignal;
    s.size := 3;
    s.DeltaX := dx;
    s.StartX := x - dx;
    for i := 0 to 2 do
    begin
      s.SetY(i, 0);
    end;
    s.SetY(1, 1);
    n := src.node;
    str := 'Trig_001';
    while src.GetSignal(str) <> nil do
    begin
      str := modname(str, false);
    end;
    s.sname := str;
    wp.Link(src.name, str, s);
    wp.Refresh;
    src.CreateSignal(s);
    // ������� �������
    tr := cTrig.create;
    tr.m_helpChannel:=true;
    tr.Settrigtype(c_Trig_User);
    tr.TrigName := s.sname;
    tr.list := TrigList;
    tr.number := 0;
    tr.Threshold := 0.5;
    tr.x := s.GetX(1);
    tr.shift := 0;
    tr.Front := true;
    tr.srcid := src.id;
    tr.GenID;
  end
  else
  begin
    exit;
  end;
end;

function cWPObjMng.GetWPSignal(name: string; src: cSrc): cWPSignal;
begin
  result := nil;
  if src <> nil then
  begin
    result := src.getSignalObj(name);
  end;
end;

function cWPObjMng.GetWPSignal(s: iwpsignal): cWPSignal;
var
  n: iwpnode;
begin
  n := iwpnode(winpos.GetNode(s));
  result := GetSignalByPath(n.AbsolutePath);
end;

function cWPObjMng.GetWPSignal(name: string): cWPSignal;
var
  i: integer;
  folder: string;
  s: cSrc;
begin
  result := nil;
  folder := ExtractSignalFolder(name);
  s := GetSrc(folder);
  if s = nil then
    exit;
  result := s.getSignalObj(ExtractSignalName(name));
end;

function cWPObjMng.GetSignalByPath(str: string): cWPSignal;
var
  folder, name: string;
  i: integer;
  src: cSrc;
begin
  for i := length(str) downto 1 do
  begin
    if (str[i] = '\') or (str[i] = '/') then
    begin
      folder := str;
      // -1 �.�. �������� ����
      setlength(folder, i - 1);
      // i+1 �.�. �������� ����
      name := Copy(str, i + 1, length(str) - i);
      break;
    end;
  end;
  src := GetSrc(folder);
  result := GetWPSignal(name, src);
end;

function cWPObjMng.GetSignalByHLine(hline: integer): cWPSignal;
var
  hSignal: integer;
  i: integer;
  src: cSrc;
  s: iwpsignal;
  f1: iwpusml;
  f2: iwpusml;
  f2node: iwpnode;
  str: string;
begin
  result := nil;
  s := GetIWPSignalByHLine(hline);
  hSignal := s.Instance;

  f2 := GetIWPUsmlByHLine(hline);
  if f2 <> nil then
  begin
    for i := 0 to srcList.count - 1 do
    begin
      f1 := GetIWPUsml(i);
      if f1 <> nil then
      begin
        if f1.FileName = f2.FileName then
        // if f1.filename=f2.filename then
        begin
          src := GetSrc(i);
          result := GetWPSignal(s.sname, src);
          exit;
        end;
      end;
    end;
  end;

  f2node := GetIWPNodeByHLine(hline);
  if f2node <> nil then
  begin
    for i := 0 to srcList.count - 1 do
    begin
      str := GetSrcName(i);
      if str = f2node.AbsolutePath then
      begin
        src := GetSrc(i);
        result := GetWPSignal(s.sname, src);
        exit;
      end;
    end;
  end;

end;

function GetSName(name: string): string;
begin
  result := replaceSpace(name, '_');
end;



function cWPGraph.GetAxisByLine(hline: integer): cWPAxis;
var
  haxis, num: integer;
  i: integer;
  ax: cWPAxis;
begin
  result := nil;
  num := GraphApi.GetYAxisNum(hline);
  haxis := GraphApi.GetYAxis(hgraph, num);
  for i := 0 to childcount - 1 do
  begin
    ax := GetAxis(i);
    if ax.haxis = haxis then
    begin
      result := ax;
      exit;
    end;
  end;
end;

function cWPGraph.GetAxis(i: integer): cWPAxis;
var
  obj: cBaseObj;
begin
  result := nil;
  obj := getChild(i);
  if obj <> nil then
  begin
    result := cWPAxis(obj);
  end;
end;

function cWPGraph.EvalXBounds: point2d;
var
  src: cSrc;
  MinMax: point2d;
  er: boolean;
begin
  src := mng.SelectedSrc;
  MinMax := getXMinMax;
  if src <> nil then
  begin
    if FindInterval then
    begin
      if startTrig <> nil then
      begin
        result.x := startTrig.GetTime(er, src, MinMax.x, MinMax.y,
          mng.StatusCallback);
        if er then
        begin
          result.x := MinMax.x;
        end;
      end
      else
      begin
        result.x := MinMax.x;
        if not autoscale then
        begin
          if (ZoomXAxis.x > MinMax.x) and ((ZoomXAxis.x < MinMax.y)) then
            result.x := ZoomXAxis.x;
        end;
      end;
      if StopTrig <> nil then
      begin
        result.y := StopTrig.GetTime(er, src, MinMax.x, MinMax.y,
          mng.StatusCallback);
        if er then
        begin
          result.y := MinMax.y;
        end;
      end
      else
      begin
        if (autoscale) or (result.x > ZoomXAxis.y) then
          result.y := MinMax.y
        else
          result.y := ZoomXAxis.y;
      end;
    end
    else
    begin
      if autoscale then
        result := MinMax
      else
        result := ZoomXAxis;
    end;
  end;
end;

function cWPGraph.getXMinMax: point2d;
var
  i, j: integer;
  ax: cWPAxis;
  s: cWPSignal;
  p2, lp2: point2d;
  b: boolean;
begin
  p2 := p2d(0, 0);
  b := true;
  for i := 0 to childcount - 1 do
  begin
    ax := GetAxis(i);
    for j := 0 to ax.childcount - 1 do
    begin
      s := ax.GetSignal(j);
      if s <> nil then
      begin
        // ���� ������ ���������
        if b then
        begin
          p2 := s.getMinMaxX;
          b := false;
        end
        else
        begin
          lp2 := s.getMinMaxX;
          if p2.x > lp2.x then
            p2.x := lp2.x;
          if p2.y < lp2.y then
            p2.y := lp2.y
        end;
      end;
    end;
  end;
  result := p2;
end;

constructor cWPGraph.create;
begin
  inherited;
  AXROW := true;
  tubes := true;
  ShowName := true;
  ShowLegend := true;
end;

destructor cWPGraph.destroy;
var
  i: integer;
  t: cWPTube;
begin
  inherited;
  if node <> nil then
    node := nil;
  for i := 0 to cWPObjMng(mng).tubes.count - 1 do
  begin
    t := cWPTube(cWPObjMng(mng).tubes.Objects[i]);
    t.delGraph(hgraph);
  end;
end;

procedure cWPGraph.ApplyOpts;
var
  opt, axopt: cardinal;

  p2: point2d;
begin
  opt := 0;
  axopt := 0;
  // GraphApi.

  if ShowName then
  begin
    setFlag(opt, GROPT_SHOWNAME);
  end;
  if YINDENT then
  begin
    setFlag(opt, GROPT_YINDENT);
  end;
  if SUBGRID then
  begin
    setFlag(opt, GROPT_SUBGRID);
  end;
  if GRIDLABS then
  begin
    setFlag(opt, GROPT_GRIDLABS);
  end;
  if POLAR then
  begin
    setFlag(opt, GROPT_POLAR);
  end;
  if LINENUMS then
  begin
    setFlag(opt, GROPT_LINENUMS);
  end;
  if AUTONORM then
  begin
    setFlag(opt, GROPT_AUTONORM);
  end;
  if AXROW then
  begin
    setFlag(opt, GROPT_AXROW);
  end;
  if AXCOLUMN then
  begin
    setFlag(opt, GROPT_AXCOLUMN);
  end;
  if LogX then
  begin
    setFlag(axopt, AXOPT_Log);
  end;

  if LogX and (ZoomXAxis.x <= 0) then
  begin
    ZoomXAxis.x := 0.000001;
  end;

  if ShowLegend then
  begin
    setFlag(opt, GROPT_SHOWLEGEND);
  end;
  // gexminmax ��� ����� �� ���������
  p2 := EvalXBounds;
  GraphApi.SetXMinMax(hgraph, p2.x, p2.y);
  if p2.x < 0.0000001 then
    p2.x := 0.0000001;
  GraphApi.SetXMinMax(hgraph, p2.x, p2.y);

  GraphApi.SetAxisOpt(hgraph, 0, axopt, AXOPT_RANGE or AXOPT_Log or axopt,
    p2.x, p2.y, XName[1],
    // szftempl
    ' ', color);
  GraphApi.SetGraphOpt(hgraph, opt, $FFFFFFFF);
end;

procedure cWPGraph.LoadObjAttributes(xmlNode: txmlnode; mng: TObject);
var
  str: string;
  id: string;
begin
  inherited;
  szftempl := ' ';
  XAxis.x := xmlNode.ReadAttributeFloat('Min.X');
  XAxis.y := xmlNode.ReadAttributeFloat('Max.X');

  ZoomXAxis.x := xmlNode.ReadAttributeFloat('ZoomMin.X');
  ZoomXAxis.y := xmlNode.ReadAttributeFloat('ZoomMax.X');

  XName := xmlNode.ReadAttributeString('XAxisName');
  szftempl := xmlNode.ReadAttributeString('szftempl');

  color := xmlNode.ReadAttributeInteger('Color');

  str := xmlNode.ReadAttributeString('XLog', ' ');
  if lowercase(str) = 'true' then
    LogX := true
  else
    LogX := false;

  str := xmlNode.ReadAttributeString('Tubes', 'true');
  if lowercase(str) = 'true' then
    tubes := true
  else
    tubes := false;

  str := xmlNode.ReadAttributeString('Legend', 'true');
  if lowercase(str) = 'true' then
    ShowLegend := true
  else
    ShowLegend := false;

  str := xmlNode.ReadAttributeString('XAutoScale', 'true');
  if lowercase(str) = 'true' then
    autoscale := true
  else
    autoscale := false;

  str := xmlNode.ReadAttributeString('AxisRow', 'true');
  if lowercase(str) = 'true' then
    AXROW := true
  else
    AXROW := false;

  str := xmlNode.ReadAttributeString('AxisCol', 'false');
  if lowercase(str) = 'true' then
    AXCOLUMN := true
  else
    AXCOLUMN := false;

  str := xmlNode.ReadAttributeString('FindInterval', 'false');
  if lowercase(str) = 'true' then
    FindInterval := true
  else
    FindInterval := false;
  id := xmlNode.ReadAttributeString('StartTrig', '');
  startTrig := cWPObjMng(mng).GetTrigWithID(id);

  id := xmlNode.ReadAttributeString('StopTrig', '');
  StopTrig := cWPObjMng(mng).GetTrigWithID(id);

  signalLength := xmlNode.ReadAttributeFloat('Length', 0);
end;

procedure cWPGraph.SaveObjAttributes(xmlNode: txmlnode);
begin
  inherited;
  xmlNode.WriteAttributeFloat('Min.X', XAxis.x);
  xmlNode.WriteAttributeFloat('Max.X', XAxis.y);

  xmlNode.WriteAttributeFloat('ZoomMin.X', ZoomXAxis.x);
  xmlNode.WriteAttributeFloat('ZoomMax.X', ZoomXAxis.y);

  xmlNode.WriteAttributeString('XAxisName', XName);
  xmlNode.WriteAttributeString('szftempl', szftempl);

  xmlNode.WriteAttributeBool('AxisRow', AXROW);
  xmlNode.WriteAttributeBool('AxisCol', AXCOLUMN);
  xmlNode.WriteAttributeBool('XLog', LogX);
  xmlNode.WriteAttributeBool('XAutoScale', autoscale);
  xmlNode.WriteAttributeBool('Tubes', tubes);
  xmlNode.WriteAttributeBool('ShowLegend', ShowLegend);

  xmlNode.WriteAttributeBool('FindInterval', FindInterval);
  if startTrig <> nil then
    xmlNode.WriteAttributeString('StartTrig', startTrig.id)
  else
    xmlNode.WriteAttributeString('StartTrig', '');
  if StopTrig <> nil then
    xmlNode.WriteAttributeString('StopTrig', StopTrig.id)
  else
  begin
    xmlNode.WriteAttributeString('StopTrig', '');
  end;

  xmlNode.WriteAttributeFloat('Length', signalLength);
end;

procedure cWPAxis.DoLincParent;
begin
  // if parent<>nil then
  // begin
  // if cwppage(parent).ChildCount=1 then
  // begin

  // end;
  // end;
end;

function cWPAxis.getYminmax: point2d;
var
  i: integer;
  s: cWPSignal;
  p2, lp2: point2d;
begin
  for i := 0 to childcount - 1 do
  begin
    s := GetSignal(i);
    if s = nil then
    begin
      result := p2d(0, 0);
      exit;
    end;
    lp2 := s.getMinMaxY;
    if i = 0 then
    begin
      p2 := lp2;
    end
    else
    begin
      if lp2.x < p2.x then
      begin
        p2.x := lp2.x
      end;
      if lp2.y > p2.y then
      begin
        p2.x := lp2.y;
      end;
    end;
  end;
  result := p2;
end;

procedure cWPAxis.Normalise;
var
  p2: point2d;
begin
  p2 := getYminmax;
  GraphApi.SetYAxisMinMax(haxis, p2.x, p2.y);
end;

function cWPAxis.GetSignal(i: integer): cWPSignal;
var
  l: cWPLine;
  src: cSrc;
begin
  l := cWPLine(getChild(i));
  result := l.Signal;
  if result = nil then
  begin
    src := mng.getsrcid(l.srcid);
    if src <> nil then
    begin
      l.Signal := src.getSignalObj(l.signalname);
      result := l.Signal;
    end;
  end;
end;

function cWPAxis.GetGraph: cWPGraph;
begin
  if parent <> nil then
    result := cWPGraph(parent)
  else
    result := nil;
end;

procedure cWPAxis.ApplyOpts;
var
  opt: cardinal;
  iopt: integer;
  laxis: integer;
  lax: point2d;
  s1, s2: widestring;
  gr: cWPGraph;
  line: cWPLine;
begin
  opt := 0;
  if log then
  begin
    setFlag(opt, AXOPT_Log);
  end;
  if FZERO then
  begin
    setFlag(opt, AXOPT_FZERO);
  end;
  if TIME then
  begin
    setFlag(opt, AXOPT_TIME);
  end;
  // ��������
  setFlag(opt, AXOPT_RANGE);

  szftempl := ' ';
  // ������������� ��������
  if log then
  begin
    if ZoomAxis.x <= 0 then
    begin
      ZoomAxis.x := 0.000000001;
    end;
  end;
  GraphApi.SetYAxisMinMax(haxis, ZoomAxis.x, ZoomAxis.y);
  if autoscale then
  begin
    Normalise;
  end;
  GraphApi.SetAxisOpt(cWPGraph(parent).hgraph, haxis, opt, $FFFF, 0, 0, szName,
    szftempl, color);
end;

procedure cWPAxis.LoadObjAttributes(xmlNode: txmlnode; mng: TObject);
var
  str: string;
begin
  inherited;
  str := xmlNode.ReadAttributeString('MinY');
  MinMax.x := StrToFloatExt(str);

  str := xmlNode.ReadAttributeString('MaxY');
  MinMax.y := StrToFloatExt(str);

  str := xmlNode.ReadAttributeString('ZoomMinY');
  ZoomAxis.x := StrToFloatExt(str);

  str := xmlNode.ReadAttributeString('ZoomMaxY');
  ZoomAxis.y := StrToFloatExt(str);

  szName := xmlNode.ReadAttributeString('AxisName');
  szftempl := xmlNode.ReadAttributeString('szftempl');

  // axIndex:= xmlNode.ReadAttributeInteger('AxIndex', 0);
  color := xmlNode.ReadAttributeInteger('Color');
  // ����������� �� Y
  str := xmlNode.ReadAttributeString('AutoScale', 'true');
  if lowercase(str) = 'true' then
    autoscale := true
  else
    autoscale := false;

  str := xmlNode.ReadAttributeString('LogScale', 'false');
  if lowercase(str) = 'true' then
    log := true
  else
    log := false;
end;

procedure cWPAxis.SaveObjAttributes(xmlNode: txmlnode);
begin
  inherited;
  xmlNode.WriteAttributeFloat('MinY', MinMax.x);
  xmlNode.WriteAttributeFloat('MaxY', MinMax.y);

  xmlNode.WriteAttributeFloat('ZoomMinY', ZoomAxis.x);
  xmlNode.WriteAttributeFloat('ZoomMaxY', ZoomAxis.y);

  xmlNode.WriteAttributeString('AxisName', szName);
  xmlNode.WriteAttributeString('szftempl', szftempl);

  xmlNode.WriteAttributeinteger('Color', color);

  xmlNode.WriteAttributeBool('LogScale', log);
  xmlNode.WriteAttributeBool('AutoScale', autoscale);
  // xmlNode.WriteAttributeInteger('AxIndex', axIndex);
end;

function cWPPage.GetPageStyle: integer;
begin
  if graphtable.x = 1 then
  begin
    result := c_pageStyle_col;
  end
  else
  begin
    if graphtable.y = 1 then
    begin
      result := c_pageStyle_Row;
    end
    else
    begin
      result := c_pageStyle_table;
    end;
  end;
end;

procedure cWPPage.LoadObjAttributes(xmlNode: txmlnode; mng: TObject);
begin
  inherited;
  SyncCursors := xmlNode.ReadAttributeBool('SyncCurs', false);
  graphtable.x := xmlNode.ReadAttributeInteger('Rows', 1);
  graphtable.y := xmlNode.ReadAttributeInteger('Col', 1);
end;

procedure cWPPage.SaveObjAttributes(xmlNode: txmlnode);
begin
  xmlNode.WriteAttributeBool('SyncCurs', SyncCursors);
  xmlNode.WriteAttributeinteger('Rows', graphtable.x);
  xmlNode.WriteAttributeinteger('Col', graphtable.y);
  inherited;
end;

procedure cWPPage.ApplyOpts;
var
  opt: cardinal;
begin
  // ��������� �����
  opt := 0;
  if ShowName then
  begin
    setFlag(opt, PGOPT_SHOWNAME);
  end;
  if OneAxisX then
  begin
    setFlag(opt, PGOPT_SINGLEX);
  end;
  if OneAxisY then
  begin
    setFlag(opt, PGOPT_SINGLEY);
  end;
  if SyncCursors then
  begin
    setFlag(opt, PGOPT_SYNCCURS);
  end;
  case GetPageStyle of
    c_pageStyle_Row:
      GraphApi.SetPageDim(hpage, PAGE_DM_Vert, graphtable.y, graphtable.x);
    c_pageStyle_col:
      GraphApi.SetPageDim(hpage, PAGE_DM_HORZ, graphtable.y, graphtable.x);
    c_pageStyle_table:
      GraphApi.SetPageDim(hpage, PAGE_DM_TABLE, graphtable.y, graphtable.x);
  end;
  GraphApi.SetPageOpt(hpage, opt, $FFFFFFFF);
end;

constructor cWPLine.create;
begin
  // ��������
  LineType := 0;
  inherited;
end;

procedure cWPLine.ApplyOpts;
var
  opt, setopt: integer;
begin
  // ��������� �����
  opt := 0;
  setopt := 0;
  setflag_int(opt, LNOPT_LINE2BASE);
  setflag_int(opt, LNOPT_ONLYPOINTS);
  setflag_int(opt, LNOPT_VISIBLE);
  setflag_int(opt, LNOPT_HIST);
  setflag_int(opt, LNOPT_HISTTRANSP);
  setflag_int(opt, LNOPT_PARAM);
  // setflag_int(opt,LNOPT_INTERP);
  setflag_int(opt, LNOPT_WIDTH);
  setflag_int(opt, LNOPT_color);
  // GraphApi.SetLineOpt(hline, $410, $410, 0, $FF0000);

  // ������������ ����� 1 shl 0
  if LINE2BASE then
  begin
    setflag_int(setopt, LNOPT_LINE2BASE);
  end
  else
  // �������� ������ ����� 1 shl 1
    if ONLYPOINTS then
  begin
    setflag_int(setopt, LNOPT_ONLYPOINTS);
  end;
  if VISIBLE then
  begin
    setflag_int(setopt, LNOPT_VISIBLE);
  end;
  // 1 shl 3
  if HIST then
  begin
    setflag_int(setopt, LNOPT_HIST);
  end;
  if HISTTRANSP then
  begin
    setflag_int(setopt, LNOPT_HISTTRANSP);
  end;
  if PARAM then
  begin
    setflag_int(setopt, LNOPT_PARAM);
  end;

  // if true then
  // begin
  // dropFlag_int(setopt, LNOPT_INTERP);
  // setFlag_int(setopt, LNOPT_INTERP);
  // end;

  GraphApi.SetLineOpt(hline, setopt, opt, width, color); // 0-��������, 1,2,3...
  // ��� ����� 0- ��������; 1, 2 - �������
  // GraphApi.SetLineOpt(hLine, $1410, $1410, linetype, color); //0-��������, 1,2,3...

end;

function cWPLine.getMinMaxY: point2d;
begin
  result := Signal.getMinMaxY;
end;

procedure cWPLine.LoadObjAttributes(xmlNode: txmlnode; mng: TObject);
var
  src: cSrc;
  SrcCount: integer;
  resSignal: cWPSignal;
  str: string;
begin
  inherited;
  srcName := xmlNode.ReadAttributeString('SrcName', '');
  fsignalName := xmlNode.ReadAttributeString('SrcSignal', '');
  srcid := xmlNode.ReadAttributeInteger('srcID', 0);
  color := xmlNode.ReadAttributeInteger('Color', clblue);
  width := xmlNode.ReadAttributeInteger('Width', 1);

  str := xmlNode.ReadAttributeString('LINE2BASE', 'false');
  if lowercase(str) = 'true' then
    LINE2BASE := true
  else
    LINE2BASE := false;

  ONLYPOINTS := xmlNode.ReadAttributeBool('ONLYPOINTS', ONLYPOINTS);
  VISIBLE := xmlNode.ReadAttributeBool('VISIBLE', VISIBLE);
  HIST := xmlNode.ReadAttributeBool('HIST', HIST);
  HISTTRANSP := xmlNode.ReadAttributeBool('HISTTRANSP', HISTTRANSP);
  PARAM := xmlNode.ReadAttributeBool('PARAM', PARAM);

end;

procedure cWPLine.setsignalname(s: string);
begin
  fsignalName := s;
  name := s;
end;

procedure cWPLine.SaveObjAttributes(xmlNode: txmlnode);
begin
  // ����� ���� ������ ���� ������ � ��������������� ������ (��������)
  xmlNode.WriteAttributeinteger('srcID', srcid);
  xmlNode.WriteAttributeString('SrcName', srcName);
  // xmlNode.WriteAttributeString('SrcSignal', getSName(signal.name));
  // xmlNode.WriteAttributeString('SrcSignal', deletechars(signal.name,'"'));
  if signalname = '' then
  begin
    if Signal <> nil then
    begin
      fsignalName := Signal.Name;
    end;
  end;
  xmlNode.WriteAttributeString('SrcSignal', signalname);

  xmlNode.WriteAttributeinteger('Color', color);
  xmlNode.WriteAttributeinteger('Width', width);
  xmlNode.WriteAttributeBool('LINE2BASE', LINE2BASE);
  xmlNode.WriteAttributeBool('ONLYPOINTS', ONLYPOINTS);
  xmlNode.WriteAttributeBool('VISIBLE', VISIBLE);
  xmlNode.WriteAttributeBool('HIST', HIST);
  xmlNode.WriteAttributeBool('HISTTRANSP', HISTTRANSP);
  xmlNode.WriteAttributeBool('PARAM', PARAM);
  inherited;
end;

destructor cSrc.destroy;
var
  i: integer;
begin
  merafile := nil;
  node := nil;
  // showmessage(name);
  inherited;
end;

procedure cSrc.setMng(m: TObject);
var
  o: cWPObj;
  i: integer;
begin
  ReplaceObjMng(m);
  for i := 0 to childcount - 1 do
  begin
    o := cWPObj(getChild(i));
    o.ReplaceObjMng(m);
  end;
end;

function cSrc.CheckSignal(s:iwpsignal):boolean;
var
  I: Integer;
  isig:iwpsignal;
  b:boolean;
begin
  b:=true;
  for I := 0 to childrens.Count - 1 do
  begin
    isig:=GetSignal(i);
    if isig.Instance=s.Instance then
    begin
      b:=false;
      result:=b;
      exit;
    end;
  end;
  // ���� ������ ��� �� �����������
  if b then
  begin
    CreateSignal(s);
  end;
  result:=b;
end;

procedure cSrc.UpdateSrc;
var
  i:integer;
  disp:idispatch;
  s:iwpsignal;
  str:string;
begin
  // ���� �������� ���� ����
  if merafile<>nil then
  begin

  end
  else
  begin
    for i := 0 to node.childcount - 1 do
    begin
      disp := node.at(i);
      disp := (disp as iwpnode).Reference;
      if Supports(disp, DIID_IWPSignal) then
      begin
        s := disp as iwpsignal;
        str:=s.sname;
        CheckSignal(s);
      end;
    end;
  end;
end;

procedure cSrc.initSRC(d: idispatch);
var
  i: integer;
  fname: string;
  disp: idispatch;
  s: iwpsignal;
  wpsignal: cWPSignal;
  wproot, n: iwpnode;
  m: iwpusml;
begin
  bnode := false;
  if d = nil then
    exit;
  if isUSML(d) then
  begin
    if Supports(d, DIID_IWPNode) then
    begin
      if Supports((d as iwpnode).Reference, DIID_IWPUSML) then
      begin
        merafile := (d as iwpnode).Reference as iwpusml;
        node := d as iwpnode;
      end;
    end
    else
    begin
      if Supports(d, DIID_IWPUSML) then
      begin
        merafile := d as iwpusml;
        wproot := GetWPRoot;
        for i := 0 to wproot.childcount - 1 do
        begin
          n := iwpnode(wproot.at(i));
          m := TypeCastToIWPUSML(n);
          if m = merafile then
            node := n;
        end;
      end;
    end;
    // ��������� ��������� � ��������
    fname := merafile.FileName;
    fname := extractfilename(fname);
    for i := 0 to merafile.ParamCount - 1 do
    begin
      d := merafile.Parameter(i);
      if Supports(d, DIID_IWPSignal) then
      begin
        s := d as iwpsignal;
        wpsignal := cWPSignal.create;
        wpsignal.ConnectToUsml := true;
        wpsignal.node := iwpnode(winpos.GetNode(s));
        wpsignal.createTube;
        wpsignal.src := self;
        AddChild(wpsignal);
        // AddObject(getsname(s.sname), wpsignal);
      end;
    end;
  end
  else
  begin
    if isNode(d) then
    begin
      bnode := true;
      node := d as iwpnode;
      for i := 0 to node.childcount - 1 do
      begin
        disp := node.at(i);
        disp := (disp as iwpnode).Reference;
        if Supports(disp, DIID_IWPSignal) then
        begin
          s := disp as iwpsignal;
          wpsignal := cWPSignal.create;
          wpsignal.src := self;
          wpsignal.ConnectToUsml := false;
          wpsignal.node := iwpnode(winpos.GetNode(s));
          // AddObject(getsname(s.sname), wpsignal);
          AddChild(wpsignal);
        end;
      end;
    end;
  end;
end;

procedure cSrc.ReadTrigs;
var
  lbl:tstringlist;
  fname, str, sval, trigname, mode:string;
  i, ind:integer;

  time:double;
  tr:ctrig;
begin
  fname:=merafile.FileName;
  // ������ ��� ����
  fname:=ChangeFileExt(fname,'lbl');
  if fileexists(fname) then
  begin
    lbl:=TStringList.Create;
    lbl.LoadFromFile(fname);
    for I := 0 to List.Count - 1 do
    begin
      str:=lbl.Strings[i];
      ind:=0;
      mode:='';
      trigname:='';
      sval:=GetSubString(str,' ',ind+1,ind);
      time:=strtoFloatExt(sval);
      sval:=GetSubString(str,' ',ind+1,ind);
      trigname:=sval;
      if (ind+1)<length(str) then
      begin
        mode:=trigname;
        sval:=GetSubString(str,' ',ind+1,ind);
      end;
      tr:=cTrig.create;
      tr.trigtype:=c_Trig_User;
      tr.SetX(time);
      if mode<>'' then
      begin
        tr.name:=mode;
      end
      else
      begin
        tr.name:=trigname;
      end;
    end;
    lbl.Destroy;
  end;
end;

constructor cSrc.create(p_name: string);
var
  d: idispatch;
  i: integer;
  s: iwpsignal;
  wpsignal: cWPSignal;

  n: iwpnode;
begin
  inherited create;
  processed := false;

  destroydata := true;

  IntervalOpts := c_IntervalAllTest;
  trigStart := nil;
  trigStop := nil;
  TrigLevel := 0.5;

  name := p_name;
  bnode := false;

  d := winpos.Get(name);
  if winpos.IsNodeExist(name) then
    initSRC(d)
  else
  // ���� ����� ��� �������� ������� �� ����������
  begin
    s := iwpsignal(winpos.CreateSignalXY(5, 5));
    s.sname := 'Node';
    n := iwpnode(winpos.Link('Signals/' + p_name, s.sname, s));
    winpos.DeleteNode(n.AbsolutePath);
    initSRC(n);
  end;
  { if d <> nil then
    begin
    if isNode(d) then
    begin
    bnode := true;
    node := d as iwpnode;
    for i := 0 to node.ChildCount - 1 do
    begin
    d := node.at(i);
    d := (d as iwpnode).Reference;
    if Supports(d, DIID_IWPSignal) then
    begin
    s := d as iwpsignal;
    wpsignal := cWPSignal.create;
    wpsignal.ConnectToUsml := false;
    wpsignal.node := iwpnode(winpos.GetNode(s));
    // AddObject(getsname(s.sname), wpsignal);
    AddObject(s.sname, wpsignal);
    end;
    end;
    end;
    end; }
end;

constructor cSrc.create(m: idispatch);
begin
  inherited create;
  destroydata := true;
  initSRC(m);
end;

function cSrc.CreateSignal(d: idispatch): cWPSignal;
var
  s: iwpsignal;
  i: integer;
  sig: cWPSignal;
  b: boolean;
begin
  s := TypeCastToIWSignal(d);
  b := Find(s.sname, i);
  if not b then
  begin
    result := cWPSignal.create;
    if bnode then
    begin
      result.node := iwpnode(winpos.GetNode(s));
      result.src := self;
      AddChild(result);
    end
    else
    begin
      // �� �������� ��� ���� �����
      // result.node := winpos.GetNode(s) as iwpnode;
      result.node := winpos.GetNodeStr(name + '/' + s.sname) as iwpnode;
      result.src := self;
      AddChild(result);
      // WP.SaveUSML(name,merafile.FileName);
    end;
  end
  else
  begin
    sig := cWPSignal.create;
    result:=sig;
    sig.src := self;
    sig.ConnectToUsml := not bnode;
    sig.node := iwpnode(winpos.GetNode(s));
    // AddObject(getsname(s.sname), wpsignal);
    AddChild(result);
  end;
end;

function cSrc.CreateSignal(s: iwpsignal): cWPSignal;
var
  i: integer;
  d: idispatch;
begin
  result := cWPSignal.create;
  if bnode then
  begin
    d := winpos.GetNode(s);
    result.node := TypeCastToIWNode(d);
    // ���� ������ �� ���������� � ������
    if result.node = nil then
    begin
      d := winpos.Link('Signals/' + name + '/', s.sname, s) as iwpnode;
      result.node := TypeCastToIWNode(d);
    end;
    result.src := self;
    AddChild(result);
  end
  else
  begin
    // �� �������� ��� ���� �����
    // result.node := winpos.GetNode(s) as iwpnode;
    result.node := winpos.GetNodeStr(name + '/' + s.sname) as iwpnode;
    result.src := self;
    AddChild(result);
    // WP.SaveUSML(name,merafile.FileName);
  end;
end;

function cSrc.getSignalHinst(sname: string): integer;
var
  i: integer;
  s: cWPSignal;
begin
  s := cWPSignal(getChild(sname));
  if s <> nil then
  begin
    result := s.Signal.Instance;
  end;
end;

function cSrc.GetSignal(sname: string): iwpsignal;
var
  s: cWPSignal;
begin
  result := nil;
  s := getSignalObj(sname);
  if s <> nil then
    result := s.Signal;
end;


function cSrc.GetSignal(i: integer): iwpsignal;
var
  s: cWPSignal;
begin
  s:=getSignalObj(i);
  if s<>nil then
    result:=s.Signal;
end;

function cSrc.getSignalObj(sname: string): cWPSignal;
var
  s: cBaseObj;
  i: integer;
begin
  result := nil;
  s := getChild(sname);
  if s <> nil then
  begin
    result := cWPSignal(s);
  end;
end;

function cSrc.getSignalObj(i: integer): cWPSignal;
begin
  result := cWPSignal(getChild(i));
end;

function cSrc.gett1: double;
begin
  if not processed then
  begin
    EvalStartStop(nil);
  end;
  result:=ft1;
  case IntervalOpts of
    c_IntervalTrigs:
    begin
      if fTrigStart<>nil then
      begin
        result:=fTrigStart.GetTime;
      end;
    end;
  end;
end;

function cSrc.gett2: double;
begin
  if not processed then
  begin
    EvalStartStop(nil);
  end;
  result := ft2;
  case IntervalOpts of
    c_IntervalTrigs:
    begin
      if fTrigStop<>fTrigStop then
      begin
        if fTrigStop<>nil then
        begin
          result:=fTrigStop.GetTime(self);
        end;
      end;
    end;
  end;
end;

procedure cSrc.setT1(v: double);
begin
  ft1 := v;
end;

procedure cSrc.setT2(v: double);
begin
  ft2 := v;
end;

procedure cSrc.settrigstart(t: cTrig);
begin
  processed := false;
  if t <> nil then
  begin
    t.srcid := id;
  end;
  fTrigStart := t;
end;

procedure cSrc.settrigstop(t: cTrig);
begin
  processed := false;
  if t <> nil then
  begin
    t.srcid := id;
  end;
  fTrigStop := t;
end;

function cSrc.EvalStartStop(CallBack: TProcessEvent): point2d;
var
  s: cWPSignal;
  i: integer;
  min, max: double;
  // ����� ����
  trig: boolean;
  linitMin, linitMax:boolean;
begin
  min := 0;
  max := 0;
  linitMin:=false; linitMax:=false;
  // ������ ����� �����
  if (IntervalOpts = c_IntervalAllTest) or (max = 0) then
  begin
    for i := 0 to childcount - 1 do
    begin
      s := getSignalObj(i);
      if not isHelpChannel(s) then
      begin
        if i = 0 then
        begin
          if s.Signal <> nil then
          begin
            if s.Signal.size>1 then
            begin
              min := s.Signal.MinX;
              max := s.Signal.MaxX;
              if min=max then
                continue;
            end;
          end;
        end
        else
        begin
          if s.Signal <> nil then
          begin
            if s.signal.size<2 then continue;
            // �������� ����� �������� �������
            if not linitMin then
            begin
              min:=s.Signal.MinX;
              linitMin:=true;
            end
            else
            begin
              if s.Signal.MinX > min then
                min := s.Signal.MinX;
            end;
            if not linitMax then
            begin
              max:=s.Signal.MaxX;
              linitMax:=true;
            end
            else
            begin
              if s.Signal.MaxX < max then
                max := s.Signal.MaxX;
            end;
          end;
        end;
      end;
    end;
    ft1 := min;
    ft2 := max;
  end;
  // ���������� �� ���������� ��������
  if IntervalOpts = c_IntervalTrigs then
  begin
    trig := TrigLevel > 0;
    if trigStart <> nil then
    begin
      // EvalTrig(TrigStart, t1, TrigLevel, trig, '���������� ������ ���������', callback);
      if trigStart.trigtype = c_Trig_Start then
      begin
        ft1 := min;
      end
      else
      begin
        if trigStart.trigtype = c_Trig_Stop then
        begin
          ft1 := max;
        end;
      end;
    end;
    if trigStop <> nil then
    begin
      if trigStop.trigtype = c_Trig_Start then
      begin
        ft2 := min;
      end
      else
      begin
        if trigStop.trigtype = c_Trig_Stop then
        begin
          ft2 := max;
        end;
      end;
    end;
  end;
  processed := true;
  result := p2d(min, max);
end;

function cSrc.EvalStartStopMax(CallBack: TProcessEvent): point2d;
var
  s: cWPSignal;
  i: integer;
  min, max: double;
  // ����� ����
  trig: boolean;
begin
  min := 0;
  max := 0;
  // ������ ����� �����
  if (IntervalOpts = c_IntervalAllTest) or (max = 0) then
  begin
    for i := 0 to childcount - 1 do
    begin
      s := getSignalObj(i);
      if not isHelpChannel(s) then
      begin
        if i = 0 then
        begin
          if s.Signal <> nil then
          begin
            min := s.Signal.MinX;
            max := s.Signal.MaxX;
          end;
        end
        else
        begin
          if s.Signal <> nil then
          begin
            if s.Signal.MinX < min then
              min := s.Signal.MinX;
            if s.Signal.MaxX > max then
              max := s.Signal.MaxX;
          end;
        end;
      end;
    end;
    ft1 := min;
    ft2 := max;
  end;
  // ���������� �� ���������� ��������
  if IntervalOpts = c_IntervalTrigs then
  begin
    trig := TrigLevel > 0;
    if trigStart <> nil then
    begin
      // EvalTrig(TrigStart, t1, TrigLevel, trig, '���������� ������ ���������', callback);
      if trigStart.trigtype = c_Trig_Start then
      begin
        ft1 := min;
      end
      else
      begin
        if trigStart.trigtype = c_Trig_Stop then
        begin
          ft1 := max;
        end;
      end;
    end;
    if trigStop <> nil then
    begin
      if trigStop.trigtype = c_Trig_Start then
      begin
        ft2 := min;
      end
      else
      begin
        if trigStop.trigtype = c_Trig_Stop then
        begin
          ft2 := max;
        end;
      end;
    end;
  end;
  processed := true;
  result := p2d(min, max);
end;


function cWPSignal.getMinMaxY: point2d;
var
  s: iwpsignal;
begin
  s := GetSignal;
  result := p2d(s.MinY, s.MaxY);
end;

function cWPSignal.getMinMaxX: point2d;
var
  s: iwpsignal;
begin
  s := GetSignal;
  result := p2d(s.MinX, s.MaxX);
end;

function cWPSignal.GetP2(i: integer): point2;
var
  s: iwpsignal;
begin
  s := GetSignal;
  result := p2(s.GetX(i), s.GetY(i));
end;

function cWPSignal.GetSignal: iwpsignal;
begin
  if node = nil then
    result := nil
  else
    result := iwpsignal(node.Reference);
end;

function cWPSignal.getProcSignal(t1, t2: double): iwpsignal;
var
  s: iwpsignal;
  start, stop: integer;
  d: idispatch;
begin
  s := GetSignal;
  start := s.IndexOf(t1);
  stop := s.IndexOf(t2);
  d := wp.GetInterval(s, start, stop - start);
  result := d as iwpsignal;
end;

procedure cWPSignal.setname(s: string);
var
  str: widestring;

begin
  str := s;
  if node <> nil then
    Signal.sname := str;
  inherited;
end;

procedure cWPSignal.setNode(n: wpnode);
begin
  fnode := n;
  if signal<>nil then
    name := Signal.sname;
end;

procedure cWPSignal.setMng(m: TObject);
begin
  ReplaceObjMng(m);
end;

procedure cWPSignal.createTube;
var
  ifile: tinifile;
  t: cWPTube;
  u: iwpusml;
  fname, tubename: string;
  ind:integer;
begin
  u := getUSML;
  ifile := tinifile.create(u.FileName);
  tubename := ifile.readString(name, 'Tube', '');
  fname := extractfilepath(u.FileName) + tubename + '.tuf';
  if tubename <> '' then
  begin
    if fileexists(fname) then
    begin
      if cWPObjMng(mng).tubes.Find(tubename,ind) then
      begin
        t:=cWPTube(cWPObjMng(mng).tubes.Objects[ind]);
      end
      else
      begin
        t := cWPTube.create;
        //t.sig := self;
        t.folder := ExtractSignalFolder(self.node.AbsolutePath) + 'Tubes/';
        t.load(fname);
        t.name := tubename;
        t.XAxis:=c_AxX_Hz;
        cWPObjMng(mng).tubes.AddObject(tubename, t);
      end;
      tube := t;
    end;
  end;
  ifile.destroy;
end;

function cWPSignal.gettube:cwptube;
var
  ind:integer;
begin
  result:=nil;
  if cWPObjMng(mng).tubes.Find(ftubename,ind) then
  begin
    result:=cwptube(cWPObjMng(mng).tubes.Objects[ind]);
  end;
end;

procedure cWPSignal.settube(t:cwptube);
begin
  if t<>nil then
    ftubename:=t.fname;
end;

constructor cWPSignal.create;
begin
  inherited;
  istube := false;
  tube := nil;
end;

destructor cWPSignal.destroy;
var
  ind: integer;
begin
  if mng <> nil then
    mng.events.CallAllEventsWithSender(E_OnDestroySignal, self);
  inherited;
end;

constructor cWPSignal.create(n: iwpnode);
var
  parent: iwpnode;
  path: string;
begin
  if n = nil then
    exit;
  node := n;
  istube := false;
  tube := nil;
  parent := getparentnode(n);
  if isUSML(parent) then
  begin
    ConnectToUsml := true;
    createTube;
  end;
end;

function cWPSignal.getUSML: iwpusml;
var
  n: iwpnode;
begin
  n := getparentnode(node);
  if isUSML(n) then
  begin
    result := TypeCastToIWPUSML(n);
  end
  else
  begin
    result := nil;
  end;
end;

function cWPSignal.count: cardinal;
begin
  if node <> nil then
    result := iwpsignal(node.Reference).size
  else
    result := 0;
end;

function cWPSignal.getFs: double;
begin
  result := 1 / Signal.DeltaX;
end;

function cWPSignal.getLength: double;
begin
  result:=Signal.MaxX-Signal.MinX;
end;

procedure cWPSignal.setFs(f: double);
begin
  Signal.DeltaX := 1 / f;
end;

constructor cOperObj.create(p_operstr: string; p_params: string);
begin
  srcList := tstringlist.create;
  srcList.Sorted := true;
  DstID := -1;
  operStr := p_operstr;
  params := p_params;
  // ��������� ������ ��������� ���������
  Interval.intervaltype := c_IntervalAllTest;
  Interval.t1 := 0;
  Interval.t2 := 0;
  Interval.start := nil;
  Interval.stop := nil;
end;

destructor cOperObj.destroy;
var
  i: integer;
  opts: cSignalsOpt;
begin
  if mng <> nil then
  begin
    for i := 0 to mng.opers.count - 1 do
    begin
      if mng.opers.Objects[i] = self then
      begin
        mng.opers.Delete(i);
        break;
      end;
    end;
  end;
  while srcList.count <> 0 do
  begin
    opts := cSignalsOpt(srcList.Objects[0]);
    opts.destroy;
  end;
  srcList.destroy;
end;

procedure cOperObj.CheckParams;
var
  i: integer;
  o: cSignalsOpt;
  sOpt: cSignalDesc;
  s: cWPSignal;
  // ����� ��������� � ��������
  slength, sStart: integer;
begin
  for i := 0 to srcList.count - 1 do
  begin
    o := GetSignalsOpts(i);
    // SRC_Start_0="0" SRC_Count_0="8715600"
    s := cWPSignal(o.GetSignal(i));
    sStart := o.GetSrcStart(i);
    slength := o.GetSrcCount(i)
    // ������ ����� ��������� ��� ����������� ���������
    // sList:=ParsStrParam(params);
    // ������� ��������� ��������
    // DeleteParsResult(slist);
  end;
end;

function cOperObj.GetSrc: cSrc;
begin
  result := mng.getsrcid(srcid);
end;

procedure cOperObj.PrepareSignalsID;
var
  i, j: integer;
  o: cSignalsOpt;
  s: cWPSignal;
  str: string;
  int: point2d;
  src: cSrc;
begin
  fstatus := c_AlgStatusSrc;
  for i := 0 to srcList.count - 1 do
  begin
    o := GetSignalsOpts(i);
    src := mng.getsrcid(srcid);
    if src <> nil then
    begin
      for j := 0 to o.pathSrcList.count - 1 do
      begin
        str := ExtractSignalName(o.GetSrcName(j));
        s := src.getSignalObj(str);
        if s = nil then
          continue;
        // ������ ������
        if i = 0 then
        BEGIN
          if Interval.intervaltype = c_IntervalAllTest then
          begin
            Interval.t1 := src.t1;
            Interval.t2 := src.t2;
          end;
        END;
        if s <> nil then
        begin
          fstatus := c_AlgStatusOk;
          o.srcSignals.Add(s);
        end
        else
        begin
          // �� ������ ��������
          fstatus := c_AlgStatusSrc;
          break;
        end;
      end;
    end;
  end;
end;

procedure cOperObj.LingWP(p_mng: cWPObjMng);
begin
  mng := p_mng;
end;

function cOperObj.SrcCount: integer;
begin
  result := srcList.count;
end;

function cOperObj.GetSignalsOpts(i: integer): cSignalsOpt;
begin
  result := cSignalsOpt(srcList.Objects[i]);
end;

procedure cOperObj.AddSrc(s: cSignalsOpt);
var
  Signal: cWPSignal;
begin
  // �������� 27.12.14
  // srcList.AddObject(s.pathDstList.Strings[0], s);
  srcList.AddObject(s.pathSrcList.Strings[0], s);
end;

function cSrc.GetNodeInstance: cardinal;
begin
  result := 0;
  if bnode then
  begin
    result := node.Instance;
  end
  else
  begin
    if node <> nil then
      result := node.Instance;
    // if merafile<>nil then
    // result:=merafile.Instance;
  end;
end;

procedure cOperObj.SetSrcDir(s: string);
begin
  fSrcDir := s;
  if length(fSrcDir) > 0 then
  begin
    if fSrcDir[length(fSrcDir)] <> '/' then
    begin
      fSrcDir := fSrcDir + '/';
    end;
  end;
end;

procedure cOperObj.SetDstDir(s: string);
begin
  fDstDir := s;
end;

Function TrimName(str: string): string;
var
  i: integer;
begin
  result := str;
  for i := length(str) downto 1 do
  begin
    if str[i] = '/' then
    begin
      result := Copy(str, i + 1, length(str) - i);
      exit;
    end;
  end;
end;

Function TrimDir(str: string): string;
var
  i: integer;
begin
  result := str;
  for i := length(str) downto 1 do
  begin
    if str[i] = '/' then
    begin
      setlength(str, i);
      result := str;
      exit;
    end;
  end;
end;

function GetSrcName(srcPath: string): string;
var
  i, l: integer;
  b: boolean;
begin
  b := false;
  srcPath := TrimDir(srcPath);
  l := length(srcPath);
  for i := l downto 1 do
  begin
    if i = l then
    begin
      if srcPath[i] = '/' then
      begin
        b := true;
        continue;
      end;
    end;
    if srcPath[i] = '/' then
    begin
      if b then
        result := Copy(srcPath, i + 1, l - i - 1)
      else
        result := Copy(srcPath, i + 1, l - i);
      break;
    end;
  end;
  i := pos('.', result);
  if i > 0 then
  begin
    l := length(result);
    result := Copy(result, 1, i - 1);
  end;
end;

function ConvertDst(dst, srcName: string): string;
begin
  result := ReplaceSubstr(dst, c_Src_name, srcName, 1);
end;

function cOperObj.GetSrcDir: string;
var
  str: string;
  src: cSrc;
begin
  if fSrcDir = '' then
  begin
    result := '';
    if SrcCount > 0 then
    begin
      str := cSignalsOpt(GetSignalsOpts(0)).GetSrcName(0);
      if str = '' then
        fSrcDir := '/Signals/Results/'
      else
      begin
        if pos('/', str) = 0 then
        begin
          // fSrcDir := 'Results/'+str;
          fSrcDir := '/Signals/Results/';
        end
        else
        begin
          // src:=GetSrc;
          // fSrcDir:=GetSrc.name;
          // GetSrcName
          fSrcDir := TrimDir(str);
        end;
      end;
      result := fSrcDir;
    end;
  end
  else
    result := fSrcDir;
end;

function cOperObj.GetDstDir: string;
var
  l_SrcDir, str: string;
  src: cSrc;
begin
  result := '';
  if fDstDir = '' then
  begin
    if SrcCount > 0 then
    begin
      str := cSignalsOpt(GetSignalsOpts(0)).GetDst(0);
      if str = '' then
        fDstDir := '/Signals/Results/'
      else
      begin
        if pos('/', str) = 0 then
        begin
          fDstDir := '/Signals/Results/';
        end
        else
        begin
          // ������� ����������
          fDstDir := TrimDir(str);
          // ������� ���������
          l_SrcDir := GetSrcName(cSignalsOpt(GetSignalsOpts(0)).GetSrcName(0));
          if pos(l_SrcDir, fDstDir) <> 0 then
          begin
            fDstDir := ReplaceSubstr(fDstDir, l_SrcDir, c_Src_name, 1);
          end;
        end;
      end;
      src := GetSrc;
      l_SrcDir := src.name + '/';
      l_SrcDir := GetSrcName(l_SrcDir);
      result := ConvertDst(fDstDir, l_SrcDir);
    end;
  end
  else
  begin
    // l_SrcDir:=GetSrcName(cSignalsOpt(GetSignalsOpts(0)).GetSRCName(0));
    src := GetSrc;
    if src <> nil then
    begin
      l_SrcDir := src.name + '/';
      l_SrcDir := GetSrcName(l_SrcDir);
      result := ConvertDst(fDstDir, l_SrcDir);
    end
    else
      result := fDstDir;
  end;
end;


function EvalTrig(s: cWPSignal; from: double; finish: double; lvl: double;
  hi: boolean; num: integer; dsc: string; CallBack: TProcessEvent;
  var p_success: boolean): double;
var
  i, fromind, finishind, trignum: integer;
  x, y, v: double;
  trig: boolean;
  sX, sY: OleVariant;
  size: integer;
begin
  p_success := false;
  x := -1;
  size := s.Signal.size;
  fromind := s.Signal.IndexOf(from);
  finishind := s.Signal.IndexOf(finish);
  sX := VarArrayCreate([0, size - 1], varDouble);
  sY := VarArrayCreate([0, size - 1], varDouble);
  s.Signal.GetArray(0, size, sY, sX, true);
  // ���������� �� ����������� ��������
  trig := true;
  trignum := 0;
  for i := fromind to finishind do
  begin
    if i = fromind then
    begin
      v := sY[fromind];
      // �����
      if hi then
      begin
        if v > lvl then
        begin
          trig := false;
        end;
      end
      else
      // ����
      begin
        if v < lvl then
        begin
          trig := false;
        end;
      end;
    end;
    y := sY[i];
    // �����
    if hi then
    begin
      if y > lvl then
      begin
        if trig then
        begin
          x := sX[i];
          if trignum = num then
          begin
            p_success := true;
            break;
          end
          else
          begin
            inc(trignum);
            trig := false;
          end;
        end;
      end
      else
      begin
        if not trig then
          trig := true;
      end;
    end
    else
    begin
      // ���� ����
      if y < lvl then
      begin
        if trig then
        begin
          x := sX[i];
          if trignum = num then
          begin
            p_success := true;
            break;
          end
          else
          begin
            inc(trignum);
            trig := false;
          end;
        end;
      end
      else
      begin
        if not trig then
          trig := true;
      end;
    end;
    if assigned(CallBack) then
    begin
      CallBack(nil, trunc((i - fromind) * 100 / (finishind - fromind)));
    end;
  end;
  VarClear(sX);
  VarClear(sY);
  result := x;
end;


// ����� � ���� �����
//XType=5 ��� ���
//YType=0 ��� ���
//XUnitsId=0x0 ������� ���������
//YUnitsId=0x0 ������� ���������
procedure setSignalUnits(s: iwpsignal; unitsY: integer; unitsX: integer);
begin
  case unitsY of
    c_Vibr_g:
    begin
      // 1 - ������  ��� ���; 1 - ������ ��� Y; 80 - ����� ���
      s.SetSType(1, 1, 80);
      // 2 - ������  ��� �������� ������; 0 - ������ ����� �� Y; 4294972687 - g
      s.SetSType(2, 1, 4294972687);
    end;
    c_Vibr_ms:
    begin
      // 1 - ������  ��� ���; 0 - ������ ��� X; 5 - ��������� ���
      s.SetSType(1, 1, 80);
      // 2 - ������  ��� �������� ������; 0 - ������ ����� �� X; 4294972673 - ms
      s.SetSType(2, 1, 4294972673);
    end
    else
    begin
      if unitsY=0 then
      begin
        s.SetSType(1, 1, 0);
        // 2 - ������  ��� �������� ������;
        // 0 - ������ ����� �� X;
        // 0 - ������������
        s.SetSType(2, 1, 0);
      end;
    end;
  end;
  case unitsX of
    c_AxX_sec:
      begin
        // nTypeAx; nTypeVal
        // 0 - ������  ��� �������; 0 - ������ �������� ���������; 1 - ��������� �������, 2 - ����������
        s.SetSType(0, 0, 1);
        // 1 - ������  ��� ���; 0 - ������ ��� X; 5 - ��������� ���, 10 - ���������
        s.SetSType(1, 0, 5);
        // 2 - ������  ��� �������� ������; 0 - ������ ����� �� X; 4294968577 - �������
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_msec:
      begin
        s.SetSType(0, 0, 1);
        s.SetSType(1, 0, 5);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_min:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 5);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_Hour:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 5);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_Hz:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 10);
        s.SetSType(2, 0, 4294968833);
      end;
    c_AxX_kHz:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 10);
        s.SetSType(2, 0, 4294968577);
      end;
    c_AxX_rpm:
      begin
        s.SetSType(0, 0, 2);
        s.SetSType(1, 0, 10);
        s.SetSType(2, 0, 4294968577);
      end;
  end;
end;

function FindPageByGraph(graph: integer): integer;
var
  i, j, p: integer;
begin
  result := 0;
  for i := 0 to IWPGraphs(wp.GraphApi).GetPageCount - 1 do
  begin
    p := IWPGraphs(wp.GraphApi).GetPage(i);
    for j := 0 to IWPGraphs(wp.GraphApi).GetGraphCount(p) - 1 do
    begin
      if IWPGraphs(wp.GraphApi).GetGraph(p, j) = graph then
      begin
        result := p;
        exit;
      end;
    end;
  end;
end;

procedure normaliseGraph(g: integer);
var
  x1, x2, y1, y2: double;
  axCount, lCount, ax, line, axNum, opt, color: integer;
  i, j: integer;
  str1, str2: widestring;
  s: iwpsignal;
begin
  axCount := IWPGraphs(wp.GraphApi).GetYAxisCount(g);
  lCount := IWPGraphs(wp.GraphApi).GetLineCount(g);
  IWPGraphs(wp.GraphApi).GetAxisOpt(g, 0, opt, x1, x2, str1, str2, color);
  for j := 0 to lCount - 1 do
  begin
    line := IWPGraphs(wp.GraphApi).GetLine(g, j);
    s := IWPGraphs(wp.GraphApi).GetSignal(line) as iwpsignal;
    if s.MinX < x1 then
      x1 := s.MinX;
    if s.MaxX > x2 then
      x2 := s.MaxX;
  end;

  IWPGraphs(wp.GraphApi).SetXMinMax(g, x1, x2);
  IWPGraphs(wp.GraphApi).SetGraphOpt(g, GROPT_AUTONORM, GROPT_AUTONORM);
  IWPGraphs(wp.GraphApi).SetAxisOpt(g, 0, AXOPT_RANGE, AXOPT_RANGE, x1, x2, '',
    ' ', 0);
  for i := 0 to axCount - 1 do
  begin
    ax := IWPGraphs(wp.GraphApi).GetYAxis(g, i);
    IWPGraphs(wp.GraphApi).GetAxisOpt(g, ax, opt, y1, y2, str1, str2, color);
    for j := 0 to lCount - 1 do
    begin
      line := IWPGraphs(wp.GraphApi).GetLine(g, j);
      axNum := IWPGraphs(wp.GraphApi).GetYAxisNum(line);
      if axNum = i then
      begin
        s := IWPGraphs(wp.GraphApi).GetSignal(line) as iwpsignal;
        if s.MinY < y1 then
          y1 := s.MinY;
        if s.MaxY > y2 then
          y2 := s.MaxY;
      end;
      IWPGraphs(wp.GraphApi).SetYAxisMinMax(ax, y1, y2);
      IWPGraphs(wp.GraphApi).SetAxisOpt(g, ax, AXOPT_RANGE, AXOPT_RANGE, y1,
        y2, '', '', 0);
    end;
  end;

end;


function findSignal(path:string):iwpsignal;
var
  d:idispatch;
begin
  d:=WP.GetObject(path);
  result:=TypeCastToIWSignal(d);
end;


function isHelpChannel(s:string):boolean;
var
  t:ctrig;
  I: Integer;
begin
  result:=false;
  for I := 0 to mng.TrigList.Count - 1 do
  begin
    t:=mng.getTrig(i);
    if t.TrigName=s then
    begin
      if t.m_helpChannel then
      begin
        result:=true;
        exit;
      end;
    end;
  end;
end;

function isHelpChannel(s:iwpsignal):boolean;
var
  t:ctrig;
  I: Integer;
begin
  result:=isHelpChannel(s.sname);
end;

function isHelpChannel(s:cwpsignal):boolean;
var
  t:ctrig;
  I: Integer;
begin
  result:=isHelpChannel(s.name);
end;


end.
