unit uRzdFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, DCL_MYOWN, Buttons, Spin,
  inifiles, posbase, Winpos_ole_TLB,
  uWPProc, uRZDTareFrame, ucommonmath, uCommontypes, uwpopers, mathfunction,
  pathutils, uPathMng, uEventList, UWPEvents, uMNK, u2DMath, uBtnListView,
  uComponentServises,
  Types,
  udbobject,
  uRZDBase,
  ImgList,
  VirtualTrees,
  ActiveX,
  uBaseObjService,
  uVTServices,
  Shellapi,
  uEventTypes,
  uLogFile,
  uPointsList,
  uAddRZDDataFrm,
  //RpRender, RpRenderRTF, RpDefine,
  pngimage, gifimg, jpeg,
  FileCtrl, ShlObj,
  ClipBrd,
  //RpBase, RpFiler, RpRenderPDF, RpSystem,
  frxClass, frxRich,
  frxEditMemo,
  uWPServices,
  frxExportRTF, frxExportPDF, frxExportHTML, frxExportODF;

type
  cGist = class
  public
    start: integer;
    shift: integer;
    proc: boolean;
    lvl: double;
    noise: double;
  end;

  TVec4 = record
    i1, i2, i3, i4: double;
  end;

  // структура описания создания вектора Ei
  TEi = record
    sname, // имя датчика по которому построен
    fname, // имя силы по которому построен
    // ссылка на узлы в дереве WP
    nCloud, nPoly: iwpnode;
    cloud, poly: iwpSignal;
    str_sname, str_fName: string;
    fmax: double;
    // значение компонента вектора f
    ei: double;
    polyC: array of double;
    result: boolean;
  end;

  smatrix = record
    mf: string;
    vt, gt, s1, s2, s3, s4: string;
    // интервал времени
    t1t2: point2d;
  end;

  TRZDMatrix = class
  public
    date: string;
    m_active: boolean;
    vtmax: array [0 .. 3] of double;
    gtmax: array [0 .. 3] of double;
    // 3 последних восстановленных сигнала используется при построении ф-ции сравнения
    lastn1, lastn2, lastn3: string;
    n1, n2, n3: iwpnode;
    // сигналы по которым посчитана матрица
    sensors: array [0 .. 3] of smatrix;
    // если True то используются абсолютные имена датчиков иначе ищем датчики в замере по префиксам
    useSNames: boolean;
    // найденые имена по префиксам
    fs1, fs2, fs3, fs4: string;
    // имена датчиков для которых строится матрица предустановленные
    ls1, ls2, ls3, ls4: string;
    // участок для которого строится матрица
    region: string;
    // сечение для которго строится матрица
    cut: integer;
    // матрица коэфициентов
    m: d2array;
    // степень полинома
    poly: integer;
    // последние посчитанные сигналы
    resVt, resGt: iwpSignal;
  public
    // возвращает имя в ини файле
    function GetIniName: string;
    procedure UpdateSNames(mf: string); overload;
    procedure UpdateSNames(src: csrc); overload;
    function ApplyMatrix(src: csrc): boolean;
    function getRow(i: integer): string;
    function Infostr: string;
    function regionNum: integer;
    // возвращает приставку к имени сигнала вида _1_reg_01
    function GetResPostfix: string;
    constructor create;
  protected
    function gets1: string;
    function gets2: string;
    function gets3: string;
    function gets4: string;
    function gets(index: integer): string;

    // меняет ды1ююды4 (только для редактирования пользователем!!!)
    procedure sets(index: integer; str: string);
  public
    // установка обновляет только имена по поиску
    property s1: string read gets1 write fs1;
    property s2: string read gets2 write fs2;
    property s3: string read gets3 write fs3;
    property s4: string read gets4 write fs4;
    property s[index: integer]: string read gets write sets;
  end;

  TRZDFrm = class(TForm)
    PathPanel: TPanel;
    Splitter1: TSplitter;
    BaseFolderPanel: TPanel;
    BaseFolderLabel: TLabel;
    BaseFolderEdit: TEdit;
    BaseFolderBtn: TButton;
    VertPanel: TPanel;
    sectionCB: TComboBox;
    RegionCB: TComboBox;
    RegionLabel: TLabel;
    sectionLabel: TLabel;
    Splitter2: TSplitter;
    TareNamePanel: TPanel;
    LabelsPanel: TPanel;
    VFLabel: TLabel;
    HFLabel: TLabel;
    S1Label: TLabel;
    VCPathLabel: TLabel;
    S2Label: TLabel;
    S3Label: TLabel;
    S4Label: TLabel;
    MatrixPanel: TPanel;
    MatrixGB: TGroupBox;
    G11: TFloatEdit;
    G21: TFloatEdit;
    G31: TFloatEdit;
    G41: TFloatEdit;
    G42: TFloatEdit;
    G32: TFloatEdit;
    G22: TFloatEdit;
    G12: TFloatEdit;
    G43: TFloatEdit;
    G33: TFloatEdit;
    G23: TFloatEdit;
    G13: TFloatEdit;
    ExpMatrixBtn: TButton;
    ImpMatrixBtn: TButton;
    ApplyGB: TGroupBox;
    Hout_D: TFloatEdit;
    Hout_DLabel: TLabel;
    ExportMatrixPath: TEdit;
    ImportMatrixPath: TComboBox;
    SaveDialog1: TSaveDialog;
    ExportMatrixBtn: TButton;
    ImportMatrixBtn: TButton;
    UseMFmatrix: TCheckBox;
    useSignalPrefix: TCheckBox;
    TareFramePageControl: TPageControl;
    VC_Page: TTabSheet;
    H_Page: TTabSheet;
    Hout_Page: TTabSheet;
    Hin_Page: TTabSheet;
    LinkEvalWP: TCheckBox;
    DrawGraphBtn: TSpeedButton;
    StayOnTopBtn: TSpeedButton;
    CutSE: TSpinEdit;
    RegionSE: TSpinEdit;
    ChangeTestByCutCB: TCheckBox;
    LoadBtnPanel: TPanel;
    CreateMatrixBtn: TButton;
    SelectIntervalCursorBtn: TButton;
    SelectIntervalGraphBtn: TButton;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    VTree1: TVTree;
    Splitter5: TSplitter;
    UpdatePathBtn: TSpeedButton;
    Timer1: TTimer;
    FmaxEdit: TFloatEdit;
    FmaxLabel: TLabel;
    VC_Frame: TRZDTareFrame;
    H_Frame: TRZDTareFrame;
    Hin_Frame: TRZDTareFrame;
    Hout_Frame: TRZDTareFrame;
    NullBtn: TButton;
    NullCb: TCheckBox;
    GtmaxLabel: TLabel;
    GtmaxEdit: TFloatEdit;
    DelMatrixOnExpCB: TCheckBox;
    PAlfaLabel: TLabel;
    PAlfaEdit: TFloatEdit;
    FmaxAbsLabel: TLabel;
    GtmaxAbsLabel: TLabel;
    FmaxAbsFE: TFloatEdit;
    GtmaxAbsFE: TFloatEdit;
    OpenDialog1vista: TFileOpenDialog;
    OpenDialog1: TOpenDialog;
    ScrollBox1: TScrollBox;
    EvalGB: TGroupBox;
    Splitter3: TSplitter;
    JournalPageControl: TPageControl;
    JournalTS: TTabSheet;
    JournalLB: TListBox;
    MatrixTS: TTabSheet;
    Splitter4: TSplitter;
    Panel1: TPanel;
    RegLabel: TLabel;
    CutLabel: TLabel;
    Mat_S1label: TLabel;
    mat_S2label: TLabel;
    mat_s4label: TLabel;
    mat_s3Label: TLabel;
    DelMatrixBtn: TSpeedButton;
    Matrix_CutSE: TSpinEdit;
    mat_UseNamesCB: TCheckBox;
    MatrixRegSE: TEdit;
    Mat_S1CB: TComboBox;
    Mat_S2CB: TComboBox;
    Mat_S3CB: TComboBox;
    Mat_S4CB: TComboBox;
    MatrixLV: TBtnListView;
    TabSheet1: TTabSheet;
    Splitter6: TSplitter;
    GistLV: TBtnListView;
    Panel2: TPanel;
    GistStartLabel: TLabel;
    GistShiftLabel: TLabel;
    AddGist: TSpeedButton;
    DelGist: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    GistStart: TSpinEdit;
    GistShiftSE: TSpinEdit;
    GistDxFE: TFloatEdit;
    GistTrigFE: TFloatEdit;
    GistNoiseFE: TFloatEdit;
    GistProcCB: TCheckBox;
    Panel3: TPanel;
    TestLabel: TLabel;
    PolyLabel: TLabel;
    Hin_EvalBtn: TSpeedButton;
    Label1: TLabel;
    TestsFolderLabel: TLabel;
    TestPath: TComboBox;
    PolySE: TSpinEdit;
    TestPathBtn: TButton;
    PolyCount: TIntEdit;
    TestsFolderE: TEdit;
    ReportCB: TCheckBox;
    OpenReportCB: TCheckBox;
    Reptype: TRadioGroup;
    ExtImagesCB: TCheckBox;
    FltPanel: TPanel;
    TrendPortionILabel: TLabel;
    TrendPortionFLabel: TLabel;
    LPFOrderLabel: TLabel;
    LPFfreqLabel: TLabel;
    LPFCB: TCheckBox;
    TrendPortionIE: TIntEdit;
    TrendPortionFE: TFloatEdit;
    TrendCB: TCheckBox;
    LPFOrder: TIntEdit;
    LPFfreq: TFloatEdit;
    ApplyBtn: TButton;
    dXCB: TCheckBox;
    GistNIE: TIntEdit;
    frxPDFExport1: TfrxPDFExport;
    frxRTFExport1: TfrxRTFExport;
    frxHTMLExport1: TfrxHTMLExport;
    frxReport1: TfrxReport;
    procedure BaseFolderBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BaseFolderEditChange(Sender: TObject);
    procedure RegionCBChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sectionCBChange(Sender: TObject);
    procedure useSignalPrefixClick(Sender: TObject);
    procedure CreateMatrixBtnClick(Sender: TObject);
    procedure TestPathBtnClick(Sender: TObject);
    procedure Hin_EvalBtnClick(Sender: TObject);
    procedure DrawGraphBtnClick(Sender: TObject);
    procedure StayOnTopBtnClick(Sender: TObject);
    procedure CutSEChange(Sender: TObject);
    procedure TrendPortionFEChange(Sender: TObject);
    procedure TrendPortionIEChange(Sender: TObject);
    procedure Hin_FramePathChange(Sender: TObject);
    procedure H_FramePathChange(Sender: TObject);
    procedure Hout_FramePathChange(Sender: TObject);
    procedure VC_FramePathChange(Sender: TObject);
    procedure ExpMatrixBtnClick(Sender: TObject);
    procedure ImpMatrixBtnClick(Sender: TObject);
    procedure ImportMatrixPathChange(Sender: TObject);
    procedure ExportMatrixPathChange(Sender: TObject);
    procedure MatrixLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure UseMFmatrixClick(Sender: TObject);
    procedure TestPathChange(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure Hin_FrameSelectIntervalCursorBtnClick(Sender: TObject);
    procedure SelectIntervalCursorBtnClick(Sender: TObject);
    procedure SelectIntervalGraphBtnClick(Sender: TObject);
    procedure ExportMatrixBtnClick(Sender: TObject);
    procedure RegionSEChange(Sender: TObject);
    procedure TestsFolderEChange(Sender: TObject);
    procedure VTree1DragOver(Sender: TBaseVirtualTree; Source: TObject;
      shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: integer; var Accept: boolean);
    procedure VTree1DragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; shift: TShiftState;
      Pt: TPoint; var Effect: integer; Mode: TDropMode);
    procedure UpdatePathBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure NullBtnClick(Sender: TObject);
    procedure AddGistClick(Sender: TObject);
    procedure DelGistClick(Sender: TObject);
    procedure DelMatrixBtnClick(Sender: TObject);
    procedure ReportCBClick(Sender: TObject);
    procedure dXCBClick(Sender: TObject);
  public
    m_gistVtViewRange, m_gistGtViewRange: point2d;
    m_pageIndex: integer;
    m_log: cLogFile;
    f_updFolder: string;
    ThreadCount: integer;
    m_logindex: integer;
    // префикс для D1, D2,D3,D4,Fh,Fv
    m_D1Pref, m_D2Pref, m_D3Pref, m_D4Pref, m_FhPref, m_FvPref,
    // префикс для участка
    m_regionPref,
    // префикс для заезда
    m_TestPref,
    // префикс для сечения
    m_sectionPref: string;
    // текущий источник сигнала для обработки
    m_src,
    // источники соответствующие нагружениям
    vc_src, h_src, hout_src, hin_src: csrc;
    // секция ини файла в которую сохраняются настройки и путь к ини файлу
    m_section, m_cfg, m_VCPref, m_H_Pref, m_Hin_Pref, m_Hout_Pref: string;

    m_wpMng: cwpobjmng;
    // Графика для выбора участков времен по курсорам
    graph: array [0 .. 3] of tgraphstruct;
    // вектора для расчета матрицы силы
    e1, e2, e3, e4: array [0 .. 3] of TEi;
    // зависимость верт от гор тяги в втором эксперименте
    m_F2zFy, m_F2zFy_poly: iwpSignal;
    m_F2zFyValue, m_F2zFyMaxX: double; // значение полинома Fz(Fy)
    e1norm, e2norm, e3norm, e4norm: TVec4;
    // матрица по векторам ei и результирующая матрица
    E, G: d2array;
    m_matrix: TRZDMatrix;
    MatrixList: tlist;
    // база данных
    m_DB: cRZDbase;

    f_updDBCS: TRTLCriticalSection;
    f_needUpdateDB: boolean;
    // m_s1, m_s2, m_s3, m_s4, m_Vt, m_Gt:iwpsignal;
    m_JourmalAlarm:boolean;
  protected
    procedure setJournalAlarm(b:boolean);
    procedure cleargist;
    procedure addgistproc(start, shift: integer; lvl, noise: double;
      proc: boolean);
    procedure CheckMatrix(m: TRZDMatrix; src: csrc);
    function checkSignalInterval(s: iwpSignal; interval: point2d): boolean;
    procedure UpdateTestsFolder;
    procedure ShowG(p_g: d2array);
    procedure ImpMatrix(str: string);
    procedure ExportMatrix(m: TRZDMatrix; ifile: string);
    procedure FillMatrixSensorsCB;
    procedure ClearMList;
    procedure addMatrix(m: TRZDMatrix);
    // Обновить имена датчиков матрицы на основании имен датчиков фрейма
    procedure UpdateMatrixNames(m: TRZDMatrix; fr: TRZDTareFrame);
    procedure ShowMatrixList;
    // получить из ShowMatrixList статусы активности матриц
    // procedure getActStatusForM;
    // обновить размер порции для филдьтра "тренд"
    procedure UpdateIPortion;
    procedure UpdateFPortion;
    // считывает максимальную частоту опроса среди всех датчиков из ини файла
    function maxFS(s1, s2, s3, s4, vt, gt, mera: string): double;
    function GetregionPath: string;
    Procedure GetNumFromSectionCB;
    // загрузка источника данных по выбранному пути
    function LoadSrc(str: string): csrc;
    procedure LoadVCSrc;
    procedure LoadHSrc;
    procedure LoadHinCSrc;
    procedure LoadHoutSrc;
    procedure SaveToIniTareFrame(ifile: tinifile; fr: TRZDTareFrame);
    procedure LoadfromIniTareFrame(ifile: tinifile; fr: TRZDTareFrame);
    // Заполняем комбобоксы доступными сигналами
    procedure FillCB(V_cb, H_cb, D1_cb, D2_cb, D3_cb, D4_cb: TComboBox;
      merafile: string);
    procedure FillVCCB;
    procedure FillHCB;
    procedure FillHoutCB;
    procedure FillHinCB;
    // проверки каталогов
    procedure CheckBaseFolder;
    function checkImportFolder: boolean;
    // считываем список участков
    procedure ReadRegionFolders;
    procedure ReadSegments(RegionPath: string);
    // заполняем пути к сигналам калибровки
    procedure ReadTests(segmentpath: string);

    procedure createEvents;
    procedure destroyEvents;

    procedure OnAddLine(Sender: TObject);
    procedure OnDestroySignal(Sender: TObject);
    procedure OnDestroySrc(Sender: TObject);

    function EvalEi(interval: point2d; s, V: iwpSignal; name: string): TEi;
    procedure EvalFzFy(interval: point2d; Fz, Fy: iwpSignal; name: string);

    procedure LinkEiSignals(E: array of TEi);
    function GetAbsRelFmax(fmax, rel, p_abs: double): double;
    // построить сравннеие двух сигналов по формуле
    // s1-s2/f(base,f);
    function BuildCompare(s1, base: iwpSignal; fmax, rel: double;
      resfolder: string; var res1, res2: iwpSignal): iwpSignal;
    // p2list - полный перечень всех экстремумов gtForce - если true, то ищется не максимум горизонтальный силы, а зеначение силы когда был максимум на вертикальной силе
    function BuildGistogram(s: iwpSignal; dx: double; dxN: integer;
      lvl, noise: double; start, shift: integer; folder, gistname: string;
      usep2List: boolean; var p2list: cP2dList; gtForce: boolean): iwpSignal;
      overload;
    procedure BuildReport(vt, gt: iwpSignal; m: TRZDMatrix);
    procedure addRepPageFR(G: tgraphstruct; date: string; cut: string;
      testcaption: string; findcalibr: boolean; filepath: string;
      var pageIndex: integer);

    procedure addEiJournal(p_name: string; E: array of TEi; enorm: TVec4);
    // построение рез матрицы
    function buildG: d2array;
    function getformmatrix: d2array;
    procedure ApplyMatrix(s1, s2, s3, s4: iwpSignal; p_g: d2array;
      srcpath: string; sname: string; m: TRZDMatrix);
    // возвращает СОЗДАННЫЙ ВНОВЬ стринг лист содержащий имена датчиков соотносящиеся с сечением
    function GetSensorsNameWithPref(src: csrc; sect: integer): tstringlist;
      overload;
    function GetSensorsNameWithPref(mf: string; sect: integer): tstringlist;
      overload;
    // Загрузка данных для построения матрицы
    function PrepareDataforMatrix: boolean;
    // получить по индексу комбобокс для редактирования свойтсв матрицы
    function GetSensCB(i: integer): TComboBox;
    // отобразить исходные сигналы для выборки сигналов по курсору
    // возвращает hpage на котором отображены графики
    function ShowTimeGraphs(p: integer; fr: TRZDTareFrame; src: csrc;
      graphname: string): tgraphstruct;
    function CheckSrc: boolean;
    // получить сигнал с учетом фильтров
    function GetSignal(src: csrc; sname: string; calibr: boolean;
      var findSignal: boolean): iwpSignal;
    // получить путь с учетом базового каталога
    function gettestpath: string;
    procedure createDB;
    procedure UpdateDB; overload;
    procedure UpdateDB(str: string); overload;
    // перечитать каталоги базы данных
    // procedure UpdateDB;
    procedure copyFile(str: string; p: crzdpars);
    // обновляем базу
    procedure doUpdateBase(Sender: TObject);
    procedure doUpdateBaseMessage(Sender: TObject);
    procedure UpdateHandler(var Message: TMessage); message wm_UpdateFolder;
  public
    function GetCalibrFolder: string;
    function GetTestsFolder: string;
    // filename - путь к КАТАЛОГУ с мера файлом
    function testDir(filename: string): boolean;
  public
    procedure Init(p_section, p_cfg: string; p_wpMng: cwpobjmng);
    procedure Save;
    procedure Load;
  end;

var
  RZDFrm: TRZDFrm;
  def_h: double;
  def_init: boolean;
  c_CommentDx: double = 9;
  c_CommentDy: double = 7;
  v_Log: boolean = true;
  v_GistUniformAxis: boolean = false;
  v_GistAbsValueForGt: boolean = true;
  v_GistAbsRangeView: boolean = false;
  v_GistAxXScale: boolean = true;
  v_GistAxXRate: double = 0.2;
  v_MaxF: double = 10;
  v_bitScale: double = 0.8;

const
  c_TestVersion = false;
  // число значащих цифр
  c_digits = 3;

implementation

const
  c_Percent = 1;
  c_abs = 0;
{$R *.dfm}

  { TRZDFrm }
  // масштаб либо мин мах с заданным отступом или от мин до макс*2
procedure setGistXScale(hline: integer; rangeview: point2d);
var
  G: tgraphstruct;
  min, max, range: double;
  gist: iwpSignal;

  p2: point2d;
  s1, s2: widestring;
  color: integer;
  opt: integer;
begin
  G := GetGraphStructByHLine(hline);

  gist := IWPGraphs(WP.GraphAPI).GetSignal(hline) as iwpSignal;

  if v_GistAbsRangeView then
  begin
    p2 := rangeview;
    IWPGraphs(WP.GraphAPI).SetXMinMax(G.hgraph, p2.x, p2.y);
    IWPGraphs(WP.GraphAPI).GetAxisOpt(G.hgraph, 0, opt, min, max, s1, s2,
      color);
    IWPGraphs(WP.GraphAPI).SetAxisOpt(G.hgraph, 0, AXOPT_RANGE, $FFFFFFFF,
      p2.x, p2.y, '1', '1', 0);
    IWPGraphs(WP.GraphAPI).GetAxisOpt(G.hgraph, 0, opt, min, max, s1, s2,
      color);
  end
  else
  begin
    min := strtofloat(gist.GetProperty('GistMin'));
    max := strtofloat(gist.GetProperty('GistMax'));
    range := max - min;
    p2.x := min - range * v_GistAxXRate;
    p2.y := max + range * v_GistAxXRate;
    if p2.x > (min - (2 * gist.DeltaX)) then
      p2.x := (min - (2 * gist.DeltaX));
    if p2.y < (max + (2 * gist.DeltaX)) then
      p2.y := (max + (2 * gist.DeltaX));

    if v_GistAxXScale then
    begin
      IWPGraphs(WP.GraphAPI).SetXMinMax(G.hgraph, p2.x, p2.y);
      IWPGraphs(WP.GraphAPI).GetAxisOpt(G.hgraph, 0, opt, min, max, s1, s2,
        color);
      IWPGraphs(WP.GraphAPI).SetAxisOpt(G.hgraph, 0, AXOPT_RANGE, $FFFFFFFF,
        p2.x, p2.y, '1', '1', 0);
      IWPGraphs(WP.GraphAPI).GetAxisOpt(G.hgraph, 0, opt, min, max, s1, s2,
        color);
    end
    else
      IWPGraphs(WP.GraphAPI).SetYAxisMinMax(G.haxis, 0, max * 1.2);
  end;
end;

function SelectDirectoryLoc(const Title: string; var Path: string): boolean;
var
  lpItemID, start: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array [0 .. MAX_PATH] of char;
  TempPath: array [0 .. MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.pszDisplayName := @Path[1];
  BrowseInfo.hwndOwner := 0;
  BrowseInfo.lpszTitle := PChar(Title);

  // BrowseInfo.pidlRoot:=start;
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  result := lpItemID <> nil;
  if result then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Path := TempPath;
    GlobalFreePtr(lpItemID);
  end;
end;

function GetOsVersion: integer;
var
  str: string;
  VersionInformation: OSVERSIONINFO;
begin
  VersionInformation.dwOSVersionInfoSize := sizeof(VersionInformation);
  GetVersionEx(VersionInformation);
  // str:='OS Version '+
  // intToStr(VersionInformation.dwMajorVersion)+'.'+
  // intToStr(VersionInformation.dwMinorVersion)+' '+VersionInformation.szCSDVersion;
  // Result:=str;
  result := VersionInformation.dwMajorVersion;
end;

procedure TRZDFrm.BaseFolderBtnClick(Sender: TObject);
var
  str: string;
begin
  if GetOsVersion >= 6 then
  begin
    OpenDialog1vista.filename := BaseFolderEdit.Text;
    OpenDialog1vista.Options := [fdoPickFolders, fdoForceFileSystem];
    if OpenDialog1vista.Execute() then
    begin
      BaseFolderEdit.Text := OpenDialog1vista.filename;
    end;
  end
  else
  begin
    // OpenDialog1.Options := [ofOldStyleDialog, fdoForceFileSystem];
    str := BaseFolderEdit.Text;
    // if SelectDirectory('Выбор базового каталога', '',str) then
    if SelectDirectoryLoc('Выбор базового каталога', str) then
    begin
      BaseFolderEdit.Text := str;
    end;
  end;
end;

procedure TRZDFrm.Init(p_section, p_cfg: string; p_wpMng: cwpobjmng);
var
  i, j: integer;
  m: d2array;
  d: double;
  str: string;
begin
  str := extractfiledir(p_cfg) + '\log.txt';
  m_log := cLogFile.create(str, ';');
  if AddRZDDataFrm = nil then
  begin
    AddRZDDataFrm := tAddRZDDataFrm.create(nil);
  end;

  m_section := p_section;
  m_cfg := p_cfg;
  m_wpMng := p_wpMng;

  MatrixList := tlist.create;

  createEvents;
  setlength(E, 3, 4);
end;

procedure TRZDFrm.LoadfromIniTareFrame(ifile: tinifile; fr: TRZDTareFrame);
var
  subStr: string;
  i: integer;
begin
  // Путь к замеру для тарировки вертикально центрального нагружения
  for i := 1 to length(fr.name) - 1 do
  begin
    if fr.name[i] = '_' then
    begin
      subStr := copy(fr.Name, 1, i - 1);
      break;
    end;
  end;

  fr.NullFE1.FloatNum := IniReadFloatEx(ifile, m_section,
    subStr + '_' + 'Null1', 0);
  fr.NullFE2.FloatNum := IniReadFloatEx(ifile, m_section,
    subStr + '_' + 'Null2', 0);

  fr.T1FE.FloatNum := IniReadFloatEx(ifile, m_section, subStr + '_' + 'T1', 0);
  fr.T2FE.FloatNum := IniReadFloatEx(ifile, m_section, subStr + '_' + 'T2', 0);
  fr.Path.Text := ifile.readString(m_section, subStr + '_' + 'Path', '');
  fr.VFCbox.Text := ifile.readString(m_section, subStr + '_' + 'VF', '');
  fr.HFCbox.Text := ifile.readString(m_section, subStr + '_' + 'HF', '');
  fr.S1Cbox.Text := ifile.readString(m_section, subStr + '_' + 'S1', '');
  fr.S2Cbox.Text := ifile.readString(m_section, subStr + '_' + 'S2', '');
  fr.S3Cbox.Text := ifile.readString(m_section, subStr + '_' + 'S3', '');
  fr.S4Cbox.Text := ifile.readString(m_section, subStr + '_' + 'S4', '');
end;

procedure TRZDFrm.Load;
var
  ifile: tinifile;
  str: string;
  i, ind, count: integer;
  start, shift: integer;
  noise, lvl: double;
  b: boolean;
begin
  ifile := tinifile.create(m_cfg);
  v_Log := ifile.ReadBool(m_section, 'LogEvals', true);
  v_GistUniformAxis := ifile.ReadBool(m_section, 'GistUniformAxis', true);
  v_GistAbsValueForGt := ifile.ReadBool(m_section, 'GistAbsValueForG', true);
  v_GistAbsRangeView := ifile.ReadBool(m_section, 'gistAbsRangeView', false);
  m_gistVtViewRange.x := IniReadFloatEx(ifile, m_section, 'gistVtViewRange_X',
    0);
  m_gistVtViewRange.y := IniReadFloatEx(ifile, m_section, 'gistVtViewRange_X',
    50);
  m_gistGtViewRange.x := IniReadFloatEx(ifile, m_section, 'gistGtViewRange_X',
    0);
  m_gistGtViewRange.y := IniReadFloatEx(ifile, m_section, 'gistGtViewRange_X',
    50);
  GistProcCB.Checked := ifile.ReadBool(m_section, 'GistAbsRateCheckBox', true);

  m_logindex := ifile.ReadInteger(m_section, 'LogIndex', 0);
  GistTrigFE.FloatNum := IniReadFloatEx(ifile, m_section, 'GistTrig', 0.3);
  GistNoiseFE.FloatNum := IniReadFloatEx(ifile, m_section, 'GistNoise', 0.1);

  dXCB.Checked := ifile.ReadBool(m_section, 'GistDxType', true);
  GistDxFE.FloatNum := IniReadFloatEx(ifile, m_section, 'GistDx', 0.2);
  GistNIE.intnum := ifile.ReadInteger(m_section, 'GistDxN', 40);

  GistDxFE.Visible := dXCB.Checked;
  GistNIE.Visible := not dXCB.Checked;

  ifile.writeFloat(m_section, '', GistTrigFE.FloatNum);
  ifile.writeFloat(m_section, '', GistNoiseFE.FloatNum);

  // параметр по которому вычисляется приведенная погрешность
  v_MaxF := IniReadFloatEx(ifile, m_section, 'MaxF', 10);
  FmaxEdit.FloatNum := IniReadFloatEx(ifile, m_section, 'VtMaxRel', 0.1);
  FmaxAbsFE.FloatNum := IniReadFloatEx(ifile, m_section, 'VtMaxAbs', 1);

  GtmaxEdit.FloatNum := IniReadFloatEx(ifile, m_section, 'GtMaxRel', 0.1);
  GtmaxAbsFE.FloatNum := IniReadFloatEx(ifile, m_section, 'GtMaxAbs', 1);

  ExtImagesCB.Checked := ifile.ReadBool(m_section, 'ExtImages', false);

  LinkEvalWP.Visible := ifile.ReadBool(m_section, 'MatrixBtn', false);
  ApplyBtn.Visible := ifile.ReadBool(m_section, 'MatrixBtn', false);

  FltPanel.Visible := ifile.ReadBool(m_section, 'FltPanel', false);
  ReportCB.Checked := ifile.ReadBool(m_section, 'GenReport', false);
  OpenReportCB.Checked := ifile.ReadBool(m_section, 'OpenReport', false);
  NullCb.Checked := ifile.ReadBool(m_section, 'NullCB', false);
  Reptype.ItemIndex := ifile.ReadInteger(m_section, 'RepType', 0);

  c_CommentDx := IniReadFloatEx(ifile, m_section, 'CommentDx', 9);
  c_CommentDy := IniReadFloatEx(ifile, m_section, 'CommentDy', 7);

  v_GistAxXRate := IniReadFloatEx(ifile, m_section, 'GistAxXRate', 0.2);
  v_GistAxXScale := ifile.ReadBool(m_section, 'GistAxXScale', true);
  v_bitScale := IniReadFloatEx(ifile, m_section, 'BitScale', 0.8);

  // загружаем префиксы
  m_D1Pref := ifile.readString(m_section, 'D1Prefix', 'NV');
  if m_D1Pref = '' then
    m_D1Pref := 'VN';
  m_D2Pref := ifile.readString(m_section, 'D2Prefix', 'VV');
  if m_D2Pref = '' then
    m_D2Pref := 'NN';
  m_D3Pref := ifile.readString(m_section, 'D3Prefix', 'NN');
  if m_D3Pref = '' then
    m_D3Pref := 'VV';
  m_D4Pref := ifile.readString(m_section, 'D4Prefix', 'VN');
  if m_D4Pref = '' then
    m_D4Pref := 'NV';

  m_FhPref := ifile.readString(m_section, 'FhPrefix', 'Gt');
  if m_FhPref = '' then
    m_FhPref := 'GT';
  m_FvPref := ifile.readString(m_section, 'FvPrefix', 'Vt');
  if m_FvPref = '' then
    m_FvPref := 'Vt';

  m_regionPref := ifile.readString(m_section, 'RegionPrefix', 'Reg');
  if m_regionPref = '' then
    m_regionPref := 'Reg';
  m_TestPref := ifile.readString(m_section, 'TestPrefix', 'Test');
  if m_TestPref = '' then
    m_TestPref := 'Test';

  m_sectionPref := ifile.readString(m_section, 'SectionPrefix', 'Seg');
  if m_sectionPref = '' then
    m_sectionPref := 'Seg';

  m_VCPref := ifile.readString(m_section, 'VCPrefix', 'VC_');
  if m_VCPref = '' then
    m_VCPref := 'VC_';
  m_H_Pref := ifile.readString(m_section, 'HPrefix', 'H_');
  if m_H_Pref = '' then
    m_H_Pref := 'H_';
  m_Hin_Pref := ifile.readString(m_section, 'HinPrefix', 'Hin_');
  if m_Hin_Pref = '' then
    m_Hin_Pref := 'Hin_';
  m_Hout_Pref := ifile.readString(m_section, 'HoutPrefix', 'Hout_');
  if m_Hout_Pref = '' then
    m_Hout_Pref := 'Hout_';

  // Путь к замеру для тарировки вертикально центрального нагружения
  LoadfromIniTareFrame(ifile, VC_Frame);
  LoadfromIniTareFrame(ifile, H_Frame);
  LoadfromIniTareFrame(ifile, Hin_Frame);
  LoadfromIniTareFrame(ifile, Hout_Frame);

  BaseFolderEdit.Text := ifile.readString(m_section, 'BaseFolder', '');

  TestsFolderE.Text := ifile.readString(m_section, 'TestsFolder', '.\Tests');
  // путь к заезду
  TestPath.Text := ifile.readString(m_section, 'TestPath', '');
  TestPathChange(nil);

  // участок
  str := ifile.readString(m_section, 'Region', '');
  if str <> '' then
  begin
    RegionCB.Text := str;
    RegionSE.Value := strtoint(getendnum(RegionCB.Text));
  end;
  // сечение
  str := ifile.readString(m_section, 'Section', '');
  if str <> '' then
  begin
    sectionCB.Text := str;
    GetNumFromSectionCB;
  end;
  Hout_D.FloatNum := ifile.readFloat(m_section, 'Dout', 20);

  ExportMatrixPath.Text := ifile.readString(m_section, 'ExportMatrixPath', '');
  ImportMatrixPath.Text := ifile.readString(m_section, 'ImportMatrixPath', '');
  ExportMatrixPathChange(nil);
  if checkImportFolder then
  begin
    ImpMatrixBtnClick(nil);
  end;

  PolySE.Value := ifile.ReadInteger(m_section, 'Poly', 3);
  PolyCount.intnum := ifile.ReadInteger(m_section, 'PolyCount', 100);
  // использовать усреднение
  TrendCB.Checked := ifile.ReadBool(m_section, 'UseTrend', false);
  TrendPortionIE.intnum := ifile.ReadInteger(m_section, 'TrendNumPoints', 0);
  TrendPortionFE.FloatNum := IniReadFloatEx(ifile, m_section, 'TrendPortion',
    0);
  // использовать lopassfilter
  LPFCB.Checked := ifile.ReadBool(m_section, 'UseLPF', false);
  LPFOrder.intnum := ifile.ReadInteger(m_section, 'LPFOrder', 1);
  LPFfreq.FloatNum := IniReadFloatEx(ifile, m_section, 'LPFfreq', 0);

  useSignalPrefix.Checked := ifile.ReadBool(m_section, 'UsePrefix', true);
  ChangeTestByCutCB.Checked := ifile.ReadBool(m_section, 'ChangeTestByCut',
    true);

  cleargist;
  count := ifile.ReadInteger(m_section, 'GistCount', 0);
  for i := 0 to count - 1 do
  begin
    str := ifile.readString(m_section, 'gist_' + inttostr(i), '');
    start := strtoint(GetSubString(str, ';', 1, ind));
    shift := strtoint(GetSubString(str, ';', ind + 1, ind));
    b := strtobool(GetSubString(str, ';', ind + 1, ind));
    lvl := strtofloat(GetSubString(str, ';', ind + 1, ind));
    noise := strtofloat(GetSubString(str, ';', ind + 1, ind));
    addgistproc(start, shift, lvl, noise, true);
  end;
  ifile.Destroy;
  createDB;

  ReportCBClick(nil);
end;

procedure TRZDFrm.SaveToIniTareFrame(ifile: tinifile; fr: TRZDTareFrame);
var
  subStr: string;
  i: integer;
begin
  // Путь к замеру для тарировки вертикально центрального нагружения
  for i := 1 to length(fr.name) - 1 do
  begin
    if fr.name[i] = '_' then
    begin
      subStr := copy(fr.Name, 1, i - 1);
      break;
    end;
  end;
  ifile.writeFloat(m_section, subStr + '_' + 'Null1', fr.NullFE1.FloatNum);
  ifile.writeFloat(m_section, subStr + '_' + 'Null2', fr.NullFE2.FloatNum);
  ifile.writeFloat(m_section, subStr + '_' + 'T1', fr.T1FE.FloatNum);
  ifile.writeFloat(m_section, subStr + '_' + 'T2', fr.T2FE.FloatNum);
  ifile.writeString(m_section, subStr + '_' + 'Path', fr.Path.Text);
  // верт. сила
  ifile.writeString(m_section, subStr + '_' + 'VF', fr.VFCbox.Text);
  // верт. сила
  ifile.writeString(m_section, subStr + '_' + 'HF', fr.HFCbox.Text);
  ifile.writeString(m_section, subStr + '_' + 'S1', fr.S1Cbox.Text);
  ifile.writeString(m_section, subStr + '_' + 'S2', fr.S2Cbox.Text);
  ifile.writeString(m_section, subStr + '_' + 'S3', fr.S3Cbox.Text);
  ifile.writeString(m_section, subStr + '_' + 'S4', fr.S4Cbox.Text);
end;

procedure TRZDFrm.Save;
var
  ifile: tinifile;
  i: integer;
  G: cGist;
  str: string;
begin
  ifile := tinifile.create(m_cfg);

  ifile.WriteBool(m_section, 'LogEvals', v_Log);
  ifile.WriteBool(m_section, 'GistUniformAxis', v_GistUniformAxis);
  ifile.WriteBool(m_section, 'GistAbsValueForG', v_GistAbsValueForGt);
  ifile.WriteBool(m_section, 'gistAbsRangeView', v_GistAbsRangeView);
  ifile.writeFloat(m_section, 'gistVtViewRange_X', m_gistVtViewRange.x);
  ifile.writeFloat(m_section, 'gistVtViewRange_Y', m_gistVtViewRange.y);
  ifile.writeFloat(m_section, 'gistGtViewRange_X', m_gistGtViewRange.x);
  ifile.writeFloat(m_section, 'gistGtViewRange_Y', m_gistGtViewRange.y);
  ifile.WriteBool(m_section, 'GistAbsRateCheckBox', GistProcCB.Checked);

  ifile.writeFloat(m_section, 'GistTrig', GistTrigFE.FloatNum);
  ifile.writeFloat(m_section, 'GistNoise', GistNoiseFE.FloatNum);

  ifile.WriteBool(m_section, 'GistDxType', dXCB.Checked);
  ifile.writeFloat(m_section, 'GistDxFE', GistNoiseFE.FloatNum);
  ifile.writeInteger(m_section, 'GistDxN', GistNIE.intnum);

  ifile.writeFloat(m_section, 'VtMaxRel', FmaxEdit.FloatNum);
  ifile.writeFloat(m_section, 'VtMaxAbs', FmaxAbsFE.FloatNum);
  ifile.writeFloat(m_section, 'GtMaxRel', GtmaxEdit.FloatNum);
  ifile.writeFloat(m_section, 'GtMaxAbs', GtmaxAbsFE.FloatNum);
  ifile.writeFloat(m_section, 'MaxF', v_MaxF);

  ifile.WriteBool(m_section, 'FltPanel', FltPanel.Visible);
  ifile.writeInteger(m_section, 'RepType', Reptype.ItemIndex);
  ifile.WriteBool(m_section, 'MatrixBtn', ApplyBtn.Visible);
  ifile.WriteBool(m_section, 'NullCB', NullCb.Checked);
  ifile.WriteBool(m_section, 'ExtImages', ExtImagesCB.Checked);
  ifile.WriteBool(m_section, 'GenReport', ReportCB.Checked);
  ifile.WriteBool(m_section, 'OpenReport', OpenReportCB.Checked);
  ifile.writeFloat(m_section, 'CommentDx', c_CommentDx);
  ifile.writeFloat(m_section, 'CommentDy', c_CommentDy);
  ifile.WriteBool(m_section, 'GistAxXScale', v_GistAxXScale);
  ifile.writeFloat(m_section, 'GistAxXRate', v_GistAxXRate);
  ifile.writeFloat(m_section, 'BitScale', v_bitScale);

  ifile.writeString(m_section, 'BaseFolder', BaseFolderEdit.Text);
  // каталог для списка заездов
  ifile.writeString(m_section, 'TestsFolder', TestsFolderE.Text);
  // участок
  ifile.writeString(m_section, 'Region', RegionCB.Text);
  // сечение
  ifile.writeString(m_section, 'Section', sectionCB.Text);
  ifile.writeFloat(m_section, 'Dout', Hout_D.FloatNum);

  SaveToIniTareFrame(ifile, VC_Frame);
  SaveToIniTareFrame(ifile, H_Frame);
  SaveToIniTareFrame(ifile, Hin_Frame);
  SaveToIniTareFrame(ifile, Hout_Frame);

  ifile.writeString(m_section, 'ExportMatrixPath', ExportMatrixPath.Text);
  ifile.writeString(m_section, 'ImportMatrixPath', ImportMatrixPath.Text);
  // путь к заезду
  ifile.writeString(m_section, 'TestPath', TestPath.Text);
  ifile.writeString(m_section, 'T1', '');
  ifile.writeString(m_section, 'T2', '');
  ifile.writeInteger(m_section, 'Poly', PolySE.Value);
  ifile.writeInteger(m_section, 'PolyCount', PolyCount.intnum);

  // использовать усреднение
  ifile.WriteBool(m_section, 'UseTrend', TrendCB.Checked);
  ifile.writeInteger(m_section, 'TrendNumPoints', TrendPortionIE.intnum);
  ifile.writeFloat(m_section, 'TrendPortion', TrendPortionFE.FloatNum);
  // использовать lopassfilter
  ifile.WriteBool(m_section, 'UseLPF', LPFCB.Checked);
  ifile.writeInteger(m_section, 'LPFOrder', LPFOrder.intnum);
  ifile.writeFloat(m_section, 'LPFfreq', LPFfreq.FloatNum);
  // сохраняем префиксы
  ifile.writeString(m_section, 'D1prefix', m_D1Pref);
  ifile.writeString(m_section, 'D2prefix', m_D2Pref);
  ifile.writeString(m_section, 'D3prefix', m_D3Pref);
  ifile.writeString(m_section, 'D4prefix', m_D4Pref);
  ifile.writeString(m_section, 'Fhprefix', m_FhPref);
  ifile.writeString(m_section, 'Fvprefix', m_FvPref);
  ifile.writeString(m_section, 'RegionPrefix', m_regionPref);
  ifile.writeString(m_section, 'TestPrefix', m_TestPref);
  ifile.writeString(m_section, 'SectionPrefix', m_sectionPref);

  ifile.writeString(m_section, 'VCPrefix', m_VCPref);
  ifile.writeString(m_section, 'HPrefix', m_H_Pref);
  ifile.writeString(m_section, 'HinPrefix', m_Hin_Pref);
  ifile.writeString(m_section, 'HoutPrefix', m_Hout_Pref);

  ifile.WriteBool(m_section, 'UsePrefix', useSignalPrefix.Checked);
  ifile.WriteBool(m_section, 'ChangeTestByCut', ChangeTestByCutCB.Checked);

  ifile.writeInteger(m_section, 'GistCount', GistLV.Items.count);
  for i := 0 to GistLV.Items.count - 1 do
  begin
    G := cGist(GistLV.Items[i].data);
    str := inttostr(G.start) + ';' + inttostr(G.shift) + ';' + booltostr
      (G.proc, true) + ';' + floattostr(G.lvl) + ';' + floattostr(G.noise);
    ifile.writeString(m_section, 'gist_' + inttostr(i), str);
  end;
  ifile.Destroy;
end;

function TRZDFrm.LoadSrc(str: string): csrc;
begin
  result := m_wpMng.LoadSrc(str);
end;

procedure TRZDFrm.LoadVCSrc;
begin
  vc_src := LoadSrc(VC_Frame.Path.Text);
end;

procedure TRZDFrm.MatrixLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  li: TListItem;
  i, cut, usenames: integer;
  reg: string;
  m: TRZDMatrix;
  j: integer;
  cb: TComboBox;
begin
  if MatrixLV.Selected = nil then
    exit;
  // обработка свойства сечение
  cut := -1;
  for i := 0 to MatrixLV.Items.count - 1 do
  begin
    if not MatrixLV.Items[i].Selected then
      continue;
    m := TRZDMatrix(MatrixLV.Items[i].data);
    if cut = -1 then
    begin
      cut := m.cut;
    end
    else
    begin
      if cut <> m.cut then
      begin
        cut := -1;
        break;
      end;
    end;
  end;
  if cut = -1 then
    Matrix_CutSE.Text := ''
  else
    Matrix_CutSE.Value := cut;
  // обработка свойства регион
  reg := '-1';
  for i := 0 to MatrixLV.Items.count - 1 do
  begin
    if not MatrixLV.Items[i].Selected then
      continue;
    m := TRZDMatrix(MatrixLV.Items[i].data);
    if reg = '-1' then
    begin
      reg := m.region;
    end
    else
    begin
      if reg <> m.region then
      begin
        reg := '-1';
        break;
      end;
    end;
  end;
  if reg = '-1' then
    MatrixRegSE.Text := ''
  else
    MatrixRegSE.Text := reg;
  // обработка свойства искать имена
  usenames := 1;
  for i := 0 to MatrixLV.Items.count - 1 do
  begin
    if not MatrixLV.Items[i].Selected then
      continue;
    m := TRZDMatrix(MatrixLV.Items[i].data);
    SetMultiSelectComponentBool(mat_UseNamesCB, m.useSNames);
  end;
  endMultiSelect(mat_UseNamesCB);
  // обработка свойства имен датчиков
  for i := 0 to MatrixLV.Items.count - 1 do
  begin
    if MatrixLV.Items[i].Selected then
    begin
      m := TRZDMatrix(MatrixLV.Items[i].data);
      for j := 0 to 3 do
      begin
        cb := GetSensCB(j);
        if MatrixLV.Items[i] = MatrixLV.Selected then
          cb.Text := m.s[j]
        else
        begin
          if cb.Text <> '_' then
          begin
            if cb.Text <> m.s[j] then
            begin
              cb.Text := '_';
            end;
          end;
        end;
      end;
    end;
  end;
  // обработка матрицы
  if MatrixLV.SelCount = 1 then
  begin
    ShowG(m.m);
  end;

  if Change = ctState then
  begin
    if Item <> nil then
    begin
      if Item.data <> nil then
      begin
        TRZDMatrix(Item.data).m_active := Item.Checked;
      end;
    end;
  end;
end;

function TRZDFrm.GetSensCB(i: integer): TComboBox;
begin
  case i of
    0:
      begin
        result := Mat_S1CB;
      end;
    1:
      begin
        result := Mat_S2CB;
      end;
    2:
      begin
        result := Mat_S3CB;
      end;
    3:
      begin
        result := Mat_S4CB;
      end;
  end;
end;

procedure TRZDFrm.LoadHSrc;
begin
  h_src := LoadSrc(H_Frame.Path.Text);
end;

procedure TRZDFrm.LoadHinCSrc;
begin
  hin_src := LoadSrc(Hin_Frame.Path.Text);
end;

procedure TRZDFrm.LoadHoutSrc;
begin
  hout_src := LoadSrc(Hout_Frame.Path.Text);
end;

procedure SetCBIndex(cb: TComboBox; str: string);
var
  i: integer;
begin
  for i := 0 to cb.Items.count - 1 do
  begin
    if cb.Items[i] = str then
    begin
      cb.ItemIndex := i;
      exit;
    end;
  end;
end;

procedure TRZDFrm.FillCB(V_cb, H_cb, D1_cb, D2_cb, D3_cb, D4_cb: TComboBox;
  merafile: string);
var
  i: integer;
  str, str1, sname, V_cb_str, H_cb_str, D1_cb_str, D2_cb_str, D3_cb_str,
    D4_cb_str: string;
  ifile: tinifile;
  list: tstringlist;
begin
  // загрузка имен датчиков
  ifile := tinifile.create(merafile);
  list := tstringlist.create;
  ifile.ReadSections(list);
  for i := 0 to list.count - 1 do
  begin
    if lowercase(list.Strings[i]) = 'mera' then
    begin
      list.Delete(i);
      break;
    end;
  end;
  ifile.Destroy;

  V_cb_str := V_cb.Text;
  H_cb_str := H_cb.Text;
  D1_cb_str := D1_cb.Text;
  D2_cb_str := D2_cb.Text;
  D3_cb_str := D3_cb.Text;
  D4_cb_str := D4_cb.Text;

  V_cb.clear;
  H_cb.clear;
  D1_cb.clear;
  D2_cb.clear;
  D3_cb.clear;
  D4_cb.clear;
  for i := 0 to list.count - 1 do
  begin
    sname := list.Strings[i];
    if useSignalPrefix.Checked then
    begin
      str := getendnum(sectionCB.Text);
      str1 := DelNullCharsInNumStr(str);
      if CheckPosSubstr(m_FvPref, sname) then
      begin
        V_cb.AddItem(sname, nil);
      end;
      if CheckPosSubstr(m_FhPref, sname) then
      begin
        H_cb.AddItem(sname, nil);
      end;
      if CheckPosSubstr(m_D1Pref + str, sname) or CheckPosSubstr
        (m_D1Pref + str1, sname) then
      begin
        D1_cb.AddItem(sname, nil);
      end;
      if CheckPosSubstr(m_D2Pref + str, sname) or CheckPosSubstr
        (m_D2Pref + str1, sname) then
      begin
        D2_cb.AddItem(sname, nil);
      end;
      if CheckPosSubstr(m_D3Pref + str, sname) or CheckPosSubstr
        (m_D3Pref + str1, sname) then
      begin
        D3_cb.AddItem(sname, nil);
      end;
      if CheckPosSubstr(m_D4Pref + str, sname) or CheckPosSubstr
        (m_D4Pref + str1, sname) then
      begin
        D4_cb.AddItem(sname, nil);
      end;
    end
    else
    begin
      V_cb.AddItem(sname, nil);
      H_cb.AddItem(sname, nil);
      D1_cb.AddItem(sname, nil);
      D2_cb.AddItem(sname, nil);
      D3_cb.AddItem(sname, nil);
      D4_cb.AddItem(sname, nil);
    end;
  end;
  SetCBIndex(V_cb, V_cb_str);
  SetCBIndex(H_cb, H_cb_str);
  SetCBIndex(D1_cb, D1_cb_str);
  SetCBIndex(D2_cb, D2_cb_str);
  SetCBIndex(D3_cb, D3_cb_str);
  SetCBIndex(D4_cb, D4_cb_str);

  if (V_cb.Items.count > 0) and (V_cb.ItemIndex < 0) then
    V_cb.ItemIndex := 0;
  if (H_cb.Items.count > 0) and (H_cb.ItemIndex < 0) then
    H_cb.ItemIndex := 0;
  if (D1_cb.Items.count > 0) and (D1_cb.ItemIndex < 0) then
    D1_cb.ItemIndex := 0;
  if (D2_cb.Items.count > 0) and (D2_cb.ItemIndex < 0) then
    D2_cb.ItemIndex := 0;
  if (D3_cb.Items.count > 0) and (D3_cb.ItemIndex < 0) then
    D3_cb.ItemIndex := 0;
  if (D4_cb.Items.count > 0) and (D4_cb.ItemIndex < 0) then
    D4_cb.ItemIndex := 0;
end;

procedure TRZDFrm.FillVCCB;
begin
  FillCB(VC_Frame.VFCbox, VC_Frame.HFCbox, VC_Frame.S1Cbox, VC_Frame.S2Cbox,
    VC_Frame.S3Cbox, VC_Frame.S4Cbox, VC_Frame.Path.Text);
end;

procedure TRZDFrm.FillHCB;
begin
  FillCB(H_Frame.VFCbox, H_Frame.HFCbox, H_Frame.S1Cbox, H_Frame.S2Cbox,
    H_Frame.S3Cbox, H_Frame.S4Cbox, H_Frame.Path.Text);
end;

procedure TRZDFrm.FillHoutCB;
begin
  FillCB(Hout_Frame.VFCbox, Hout_Frame.HFCbox, Hout_Frame.S1Cbox,
    Hout_Frame.S2Cbox, Hout_Frame.S3Cbox, Hout_Frame.S4Cbox,
    Hout_Frame.Path.Text);
end;

procedure TRZDFrm.FillHinCB;
begin
  FillCB(Hin_Frame.VFCbox, Hin_Frame.HFCbox, Hin_Frame.S1Cbox,
    Hin_Frame.S2Cbox, Hin_Frame.S3Cbox, Hin_Frame.S4Cbox, Hin_Frame.Path.Text);
end;

procedure TRZDFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Save;
end;

procedure TRZDFrm.FormShow(Sender: TObject);
begin
  Load;
end;

Function GetVtSignal(src: csrc; cut: integer): cwpsignal;
begin

end;

procedure TRZDFrm.BuildReport(vt, gt: iwpSignal; m: TRZDMatrix);
var
  vt_gist, gt_gist, gt1, gt2, probabl1, probabl2, probabl3, s1, s2: iwpSignal;
  trig, noise, mo, max, trigval: double;
  n, color: integer;
  folder, cutstr, str: string;
  ifile: tinifile;
  graph: tgraphstruct;

  dbfld: cSegmentFolder;
  l_date: tdatetime;

  l_s, l_sr, vc, h, hin, hout: csrc;
  sig: cwpsignal;
  calibr: boolean;
  p2list: cP2dList;
  lcolor, i: integer;
  rview: point2d;
  trigsignal: iwpSignal;
begin
  // BuildGistogram(s:iwpsignal; dx, lvl, noise:double;start, shift:integer;folder:string):iwpsignal;overload;
  folder := GetSignalFolder(vt);

  trig := GistTrigFE.FloatNum;
  if GistProcCB.Checked then
    trig := trig * (vt.MaxY - vt.MinY);
  noise := GistNoiseFE.FloatNum;
  if GistProcCB.Checked then
    noise := noise * (vt.MaxY - vt.MinY);
  cutstr := '_Сеч.' + inttostr(m.cut);
  trigval := trig;
  if Abs(vt.MinY) > Abs(vt.MaxY) then
    trigval := -trigval;
  // создаем страницу с триггерным уровнем
  graph := createline(vt);
  trigsignal := iwpSignal(WP.CreateSignalXY(5, 5));
  trigsignal.size := 2;
  trigsignal.SetX(0, vt.MinX);
  trigsignal.SetY(0, trigval);
  trigsignal.SetX(1, vt.MaxX);
  trigsignal.SetY(1, trigval);
  WP.Link(folder, vt.sname + '_Lvl', trigsignal);
  graph := createline(trigsignal, graph.hgraph, graph.haxis);
  lcolor := clred;
  IWPGraphs(WP.GraphAPI).SetLineOpt(graph.hline, LNOPT_color + LNOPT_WIDTH,
    LNOPT_color + LNOPT_WIDTH, 3, lcolor);

  str := 'Lvl=' + formatstrNoE(trigval, c_digits)
    + #10 + 'noise=' + formatstrNoE(noise, c_digits) + #10;
  IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 3, 3, 10, 5);
  // создаем гистограммы
  vt_gist := BuildGistogram(vt, GistDxFE.FloatNum, GistNIE.intnum, trig, noise,
    0, 0, folder, 'Верт. сила' + cutstr, false, p2list, false);

  // dx - не корректно обновляется на основании числа точек для горизонтальной силы т.к.
  // диапазон определяется на основании gt.MaxY - gt.MinY. В действительности в гистограмму попадают силы не Max и Min а
  // силы действующие на момент максимума в верт. и гор-х осях
  gt_gist := BuildGistogram(gt, GistDxFE.FloatNum, GistNIE.intnum, trig, noise,
    0, 0, folder, 'Гор. сила' + cutstr, false, p2list, true);

  gt1 := BuildGistogram(gt, GistDxFE.FloatNum, GistNIE.intnum, trig, noise, 0,
    1, folder, 'Набегающая. ось' + cutstr, false, p2list, true);
  gt2 := BuildGistogram(gt, GistDxFE.FloatNum, GistNIE.intnum, trig, noise, 1,
    1, folder, 'Ведомая ось' + cutstr, false, p2list, true);
  p2list.Destroy;

  probabl1 := BuildProbabilityDistribution(vt_gist, PAlfaEdit.FloatNum);
  probabl1.sname := 'Распред.верт.силы' + cutstr;
  WP.Link(folder, probabl1.sname, probabl1);

  probabl2 := BuildProbabilityDistribution(gt1, PAlfaEdit.FloatNum);
  probabl2.sname := 'Распред.Gt_ведущ.' + cutstr;
  WP.Link(folder, probabl2.sname, probabl2);

  probabl3 := BuildProbabilityDistribution(gt2, PAlfaEdit.FloatNum);
  probabl3.sname := 'Распред.Gt_ведом.' + cutstr;
  WP.Link(folder, probabl3.sname, probabl3);

  // создаем графики калибровочной матрицы
  dbfld := m_DB.getCalibr(m.region, m.cut);
  calibr := false;
  if dbfld <> nil then
  begin
    l_date := dbfld.GetDate;
    vc := dbfld.getvcres;
    h := dbfld.gethres;
    hin := dbfld.gethinres;
    hout := dbfld.gethoutres;
    if (vc <> nil) and (h <> nil) and (hin <> nil) and (hout <> nil) then
    begin
      calibr := true;
      // вертикальная сила
      l_s := dbfld.getvc;
      l_sr := dbfld.getvcres;
      s1 := l_s.getSignalObj(m.sensors[0].vt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'VT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Vt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);

      if sig <> nil then
        s2 := sig.Signal
      else
      begin
        JournalLB.AddItem('Не найден результат тарировки Vt' + ' Сечение:' +
            inttostr(m.cut) + ' Регион:' + m.region + ' в сигнале ' +
            extractfilename(l_sr.merafile.filename), nil);
        exit;
      end;
      graph := createline(s1);
      IWPGraphs(WP.GraphAPI).SetPageDim(graph.hpage, PAGE_DM_TABLE, 4, 2);

      graph := createline(s2, graph.hgraph, graph.haxis);

      s1 := l_s.getSignalObj(m.sensors[0].gt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'GT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Gt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);
      s2 := sig.Signal;

      graph := createline(s1, graph.hgraph, graph.haxis);
      graph := createline(s2, graph.hgraph, graph.haxis);

      str := 'Вертикально';
      IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 45, 3,
        c_CommentDx * 4, c_CommentDy);

      IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
        GROPT_SHOWNAME + GROPT_SHOWLEGEND);
      // горизонтальная сила
      l_s := dbfld.geth;
      l_sr := dbfld.gethres;
      s1 := l_s.getSignalObj(m.sensors[1].vt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'VT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Vt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);
      s2 := sig.Signal;

      graph := createline(s1, graph.hpage);
      graph := createline(s2, graph.hgraph, graph.haxis);

      s1 := l_s.getSignalObj(m.sensors[1].gt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'GT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Gt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);
      s2 := sig.Signal;

      graph := createline(s1, graph.hgraph, graph.haxis);
      graph := createline(s2, graph.hgraph, graph.haxis);

      str := 'Горизонтально';
      IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 45, 3,
        c_CommentDx * 4, c_CommentDy);
      IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
        GROPT_SHOWNAME + GROPT_SHOWLEGEND);
      // горизонтальная наружу
      l_s := dbfld.gethout;
      l_sr := dbfld.gethoutres;
      s1 := l_s.getSignalObj(m.sensors[2].vt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'VT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Vt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);
      s2 := sig.Signal;

      graph := createline(s1, graph.hpage);
      graph := createline(s2, graph.hgraph, graph.haxis);

      s1 := l_s.getSignalObj(m.sensors[2].gt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'GT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Gt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);
      s2 := sig.Signal;

      graph := createline(s1, graph.hgraph, graph.haxis);
      graph := createline(s2, graph.hgraph, graph.haxis);

      str := 'Вертикально наружу';
      IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 45, 3,
        c_CommentDx * 5, c_CommentDy);
      IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
        GROPT_SHOWNAME + GROPT_SHOWLEGEND);
      // горизонтальная внутрь
      l_s := dbfld.gethin;
      l_sr := dbfld.gethinres;
      s1 := l_s.getSignalObj(m.sensors[3].vt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'VT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Vt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);
      s2 := sig.Signal;

      graph := createline(s1, graph.hpage);
      graph := createline(s2, graph.hgraph, graph.haxis);

      s1 := l_s.getSignalObj(m.sensors[3].gt).Signal;

      ifile := tinifile.create(l_sr.merafile.filename);
      str := ifile.readString('RZDHexa', 'GT', '');
      ifile.Destroy;
      if str = '' then
        str := 'Gt' + m.GetResPostfix;
      sig := l_sr.getSignalObj(str);
      s2 := sig.Signal;

      graph := createline(s1, graph.hgraph, graph.haxis);
      graph := createline(s2, graph.hgraph, graph.haxis);

      str := 'Вертикально внутрь';
      IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 45, 3,
        c_CommentDx * 5, c_CommentDy);
      IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
        GROPT_SHOWNAME + GROPT_SHOWLEGEND);
    end;
  end;

  // создаем гистограммы
  if calibr then
  begin
    graph := createline(vt_gist, graph.hpage);
    rview := m_gistVtViewRange;
  end
  else
  begin
    graph := createline(vt_gist);
    IWPGraphs(WP.GraphAPI).SetPageDim(graph.hpage, PAGE_DM_TABLE, 4, 1);
    rview := m_gistGtViewRange;
  end;

  setGistXScale(graph.hline, rview);
  IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
    GROPT_SHOWNAME + GROPT_SHOWLEGEND);

  // две гистограммы
  // Гистограмма ведущей оси
  graph := createline(gt1, graph.hpage);
  setGistXScale(graph.hline, m_gistGtViewRange);
  IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
    GROPT_SHOWNAME + GROPT_SHOWLEGEND);
  color := clGreen;
  IWPGraphs(WP.GraphAPI).SetLineOpt(graph.hline, 0, LNOPT_color, 0, color);
  // Гистограмма ведомой оси
  // graph := createline(gt2, graph.hgraph, graph.haxis);
  graph := createline(gt2, graph.hpage);
  setGistXScale(graph.hline, m_gistGtViewRange);
  IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
    GROPT_SHOWNAME + GROPT_SHOWLEGEND);
  color := clred;
  IWPGraphs(WP.GraphAPI).SetLineOpt(graph.hline, 0, LNOPT_color, 0, color);

  // График с 3-я комментами
  graph.hgraph := IWPGraphs(WP.GraphAPI).CreateGraph(graph.hpage);
  graph.haxis := 0;
  graph.hline := 0;
  str := vt_gist.GetProperty('Palfa');
  if str <> '' then
  begin
    trig := strtofloat(str);
    mo := strtofloat(vt_gist.GetProperty('MO'));
    max := strtofloat(vt_gist.GetProperty('GistMax'));
    n := strtoint(vt_gist.GetProperty('GistN'));
    // formatstr truncto
    str := 'Vt_max(P)=' + formatstrNoE(trig, c_digits)
      + #10 + 'Vt_max=' + formatstrNoE(max, c_digits)
      + #10 + 'Vt_mean=' + formatstrNoE(mo, c_digits) + #10 + 'N=' + inttostr
      (n) + #10 + 'dX=' + formatstrNoE(vt_gist.DeltaX, c_digits);

    IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 20, 3,
      c_CommentDx * 3.5, c_CommentDy * 3.5);
  end;

  str := gt1.GetProperty('Palfa');
  if str <> '' then
  begin
    trig := strtofloat(str);
    mo := strtofloat(gt1.GetProperty('MO'));
    max := strtofloat(gt1.GetProperty('GistMax'));
    n := strtoint(gt1.GetProperty('GistN'));
    str := 'Набег. ось' + #10 + 'Gt_max(P)=' + formatstrNoE(trig, c_digits)
      + #10 + 'Gt_max=' + formatstrNoE(max, c_digits)
      + #10 + 'Gt_mean=' + formatstrNoE(mo, c_digits) + #10 + 'N=' + inttostr
      (n) + #10 + 'dX=' + formatstrNoE(gt1.DeltaX, c_digits);

    IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 20, 30,
      c_CommentDx * 3.5, c_CommentDy * 3.5);

    str := 'P=' + formatstrNoE(PAlfaEdit.FloatNum, c_digits);
    IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 55, 23,
      c_CommentDx * 3.5, c_CommentDy * 2.3);
  end;
  str := gt2.GetProperty('Palfa');
  if str <> '' then
  begin
    trig := strtofloat(str);
    mo := strtofloat(gt2.GetProperty('MO'));
    max := strtofloat(gt2.GetProperty('GistMax'));
    n := strtoint(gt1.GetProperty('GistN'));
    str := 'Ведом. ось' + #10 + 'Gt_max(P)=' + formatstrNoE(trig, c_digits)
      + #10 + 'Gt_max=' + formatstrNoE(max, c_digits)
      + #10 + 'Gt_mean=' + formatstrNoE(mo, c_digits) + #10 + 'N=' + inttostr
      (n) + #10 + 'dX=' + formatstrNoE(gt2.DeltaX, c_digits);

    IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 20, 55,
      c_CommentDx * 3.5, c_CommentDy * 3.5);
  end;

  IWPGraphs(WP.GraphAPI).SetGraphOpt(graph.hgraph, 0,
    GROPT_SHOWNAME + GROPT_SHOWLEGEND + GROPT_SUBGRID);

  // Сохранение отчета
  for i := length(folder) downto 1 do
  begin
    if folder[i] = '/' then
    begin
      folder := copy(folder, 1, i - 1);
      break;
    end;
  end;
  l_s := m_wpMng.GetSrc(folder);
  folder := trimname(folder);
  folder := folder + ' Дата:' + l_s.merafile.date;
  addRepPageFR(graph, datetostr(l_date), inttostr(m.cut), folder, calibr,
    l_s.merafile.filename, m_pageIndex);
end;

Procedure ScaleBitmap(Const BMP: TBitmap; Const NewWidth: integer;
  Const NewHeight: integer);
Var
  TMP: TBitmap;
Begin
  If (BMP.Width = NewWidth) And (BMP.Height = NewHeight) Then
    exit;
  TMP := TBitmap.create();
  Try

    TMP.Width := NewWidth;
    TMP.Height := NewHeight;
    // TransparentColor:=clBlack;
    // cliprect - результрующие габариты, bmp - исходная картинка

    // StretchDraw(ClipRect, BMP);
    SetStretchBltMode(TMP.canvas.handle, ColorOnColor);
    SetStretchBltMode(TMP.canvas.handle, HalfTone);
    StretchBlt(TMP.canvas.handle, 0, 0, NewWidth, NewHeight, BMP.canvas.handle,
      0, 0, BMP.Width, BMP.Height, SRCCOPY);

    BMP.Assign(TMP);
  Finally
    TMP.Free();
  End;
End;

procedure TRZDFrm.addRepPageFR(G: tgraphstruct; date: string; cut: string;
                               testcaption: string; findcalibr: boolean; filepath: string;
                               var pageIndex: integer);
var
  obj: TObject;
  txt: TfrxMemoView;
  t: TfrxRichView;
  BMP: TfrxPictureView;
  page: TfrxPage;
  png: TPNGImage;

  Bit: TBitmap;
  gif: TGIFImage;

  res: boolean;
  fpath: string;
begin
  inc(pageIndex);

  txt := frxReport1.FindObject('From') as TfrxMemoView;
  txt.Text := 'Тарировка от ' + date;
  txt := frxReport1.FindObject('Cut') as TfrxMemoView;
  txt.Text := 'Сечение:' + cut;
  txt := frxReport1.FindObject('TestMemo') as TfrxMemoView;
  txt.Text := 'Испытание ' + testcaption;
  // заполняем картинку
  BMP := frxReport1.FindObject('Bmp1') as TfrxPictureView;
  if not def_init then
  begin
    def_h := BMP.Height;
    def_init := true;
  end;
  if not findcalibr then
  begin
    BMP.Height := def_h / 1.6;
  end
  else
    BMP.Height := def_h;

  if m_log <> nil then
    m_log.addInfoMes('before_WP.SaveImage');
  WP.SaveImage('', '');
  if m_log <> nil then
    m_log.addInfoMes('after_WP.SaveImage');
  if ExtImagesCB.Checked then
  begin
    // fastreport работает только с png
    fpath := extractfiledir(filepath) + '\graph' + inttostr(pageIndex) + '.png';
    png := TPNGImage.create;
    png.CompressionLevel := 7;
    if m_log <> nil then
      m_log.addInfoMes('png.LoadFromClipboardFormat_1');
    png.LoadFromClipboardFormat(CF_BITMAP, Clipboard.GetAsHandle(CF_BITMAP),
      CF_BITMAP);
    if m_log <> nil then
      m_log.addInfoMes('png.LoadFromClipboardFormat_2');
    png.SaveToFile(fpath);
    png.Free;

    // WP.SaveImage(fpath, '');
    // fpath:='G:\oburec\project2010\2011\wp\RZD\signals\Tests\sig02\1.png';
  end;

  if Clipboard.HasFormat(CF_BITMAP) or Clipboard.HasFormat(CF_PICTURE) then
  begin
    // if ExtImagesCB.Checked then
    // begin
    // bmp.FileLink:=fpath;
    // bmp.Stretched:=true;
    // bmp.AutoSize:=true;
    // bmp.Width:=800;
    // bmp.Height:=600;
    // end
    // else
    begin
      if c_TestVersion then
      begin
        if Reptype.ItemIndex=1 then
          Reptype.ItemIndex:=2;
      end;
      // если не rtf с высоким качеством
      if Reptype.ItemIndex = 1 then
      begin
        if m_log <> nil then
          m_log.addInfoMes('bmp.Picture.Assign_1');
        BMP.Picture.Assign(Clipboard);
        if m_log <> nil then
          m_log.addInfoMes('bmp.Picture.Assign_2');
      end
      else
      begin
        Bit := TBitmap.create;
        if m_log <> nil then
          m_log.addInfoMes('Bit.Assign_1');
        Bit.Assign(Clipboard);
        if m_log <> nil then
          m_log.addInfoMes('Bit.Assign_2');
        Bit.PixelFormat := pf8bit;
        ScaleBitmap(Bit, ROUND(Bit.Width * v_bitScale),
          ROUND(Bit.Height * v_bitScale));
        if c_TestVersion then
        begin
          Bit.Canvas.Font.Size:=70;
          Bit.Canvas.TextOut(400,150,'TestVersion');
        end;
        BMP.Picture.Assign(Bit);
      end;
    end;
  end;
  // создаем страницу отчета в памяти
  frxReport1.PrepareReport(false);
  frxReport1.PrintOptions.ShowDialog := false;
end;

procedure TRZDFrm.Hin_EvalBtnClick(Sender: TObject);
var
  m: TRZDMatrix;
  i, matrix_region: integer;
  n: iwpnode;
  dir, filename, folder, cutstr, str, str1: string;
  // при обработке матрица должна быть применена с тем регионом? который указан в постфиксе испытания
  // если постфикс отсутствует или матриц с нужным регионом не найдено используются выбранные матрицы в ListView
  findmatrixregion: boolean;
  resSrc: csrc;
  s, vt, gt: cwpsignal;
  G: cGist;
  trig, noise, dx: double;
  p2list: cP2dList;
begin
  // G*S
  str := gettestpath;
  m_src := LoadSrc(str);
  if m_src = nil then
  begin
    CheckFolderComponent(TestPath, TestPath.Hint, false);
    exit;
  end;
  m_log.addInfoMes('Загрузка файла успешна');
  // укорачиваем путть с конца на 1 уровень
  str := TrimPath(str);
  if str[length(str)] = '\' then
  begin
    setlength(str, length(str) - 1);
  end;
  str := lowercase(str);
  // m_regionPref
  str:=LowerCase(str);
  if pos(lowercase('_'+m_regionPref), str) > 0 then
  begin
    matrix_region := strtointext(getendnum(str));
  end
  else
  begin
    matrix_region := -1;
  end;
  findmatrixregion := false;
  for i := 0 to MatrixList.count - 1 do
  begin
    m := TRZDMatrix(MatrixList.Items[i]);
    if m.m_active then
    begin
      if m.regionNum = matrix_region then
      begin
        findmatrixregion := true;
        break;
      end;
    end;
  end;

  for i := 0 to MatrixList.count - 1 do
  begin
    if TRZDMatrix(MatrixList.Items[i]).m_active then
    begin
      m := TRZDMatrix(MatrixList.Items[i]);
      if findmatrixregion then
      begin
        if m.regionNum = matrix_region then
        begin
          m.ApplyMatrix(m_src)
        end;
      end
      else
      begin
        m.ApplyMatrix(m_src)
      end;
    end;
  end;
  m_log.addInfoMes('обработка матриц - успешно');
  n := WP.Get(m_src.name + '/RZDForce') as iwpnode;
  dir := extractfiledir(m_src.merafile.filename);
  WP.SaveUSML(n.absolutepath, dir + '\RZDforce.mera');
  // сохраняем матрицу рядом с замером
  for i := 0 to MatrixList.count - 1 do
  begin
    m := MatrixList.Items[i];
    ExportMatrix(m, dir + '\matrix.rzd');
  end;
  resSrc := m_wpMng.GetSrc(n.absolutepath);
  m_log.addInfoMes('получение каталога результирующего сигнала');
  if m=nil then
  begin
    m_log.addErrorMes('Не найдены матрицы для обработки');
    exit;
  end;
  //if not Supports(m.resVt, DIID_IWPSignal) then
  //begin
  //  m_log.addErrorMes('Не посчитан сигнал VT');
  //  exit;
  //end;
  //folder := GetSignalFolder(m.resVt);
  folder := n.absolutepath;
  m_log.addInfoMes('построение гистограм');
  i := 0;
  // корректно работает только с одной матрицей
  for i := 0 to GistLV.Items.count - 1 do
  begin
    G := cGist(GistLV.Items[i].data);
    trig := GistTrigFE.FloatNum;
    if GistProcCB.Checked then
      trig := trig * (m.resVt.MaxY - m.resVt.MinY);
    noise := GistNoiseFE.FloatNum;
    if GistProcCB.Checked then
      noise := noise * (m.resVt.MaxY - m.resVt.MinY);
    if dXCB.Checked then
      dx := GistDxFE.FloatNum
    else
      dx := (m.resVt.MaxY - m.resVt.MinY)/GistNIE.intnum;

    BuildGistogram(m.resVt, GistDxFE.FloatNum, GistNIE.intnum, trig, noise,
      G.start, G.shift, folder,
      'Верт. сила:' + cutstr + ' Старт:' + inttostr(G.start)
        + ' Пропуск:' + inttostr(G.shift), false, p2list, false);
    BuildGistogram(m.resGt, GistDxFE.FloatNum, GistNIE.intnum, trig, noise,
      G.start, G.shift, folder,
      'Гор. сила:' + cutstr + ' Старт:' + inttostr(G.start)
        + ' Пропуск:' + inttostr(G.shift), false, p2list, true);
    p2list.Destroy;
  end;

  cutstr := '_Сеч.' + inttostr(m.cut);

  // создание отчета
  frxReport1.PreviewPages.clear();
  frxRTFExport1.OpenAfterExport := OpenReportCB.Checked;
  frxPDFExport1.OpenAfterExport := OpenReportCB.Checked;
  frxHTMLExport1.OpenAfterExport := OpenReportCB.Checked;
  m_pageIndex := 0;
  m_log.addInfoMes('до построения отчета');
  for i := 0 to MatrixList.count - 1 do
  begin
    m := MatrixList.Items[i];
    if not m.m_active then
      continue;
    vt := resSrc.getSignalObj('Vt_' + inttostr(m.cut) + '_' + m.region);
    gt := resSrc.getSignalObj('Gt_' + inttostr(m.cut) + '_' + m.region);
    if ReportCB.Checked then
    begin
      if (vt <> nil) and (gt <> nil) then
        BuildReport(vt.Signal, gt.Signal, m);
    end;
  end;
  m_log.addInfoMes('после построения отчета');
  case Reptype.ItemIndex of
    0:
      filename := dir + '\RZDreport.rtf';
    1:
      filename := dir + '\RZDreport.rtf';
    2:
      filename := dir + '\RZDreport.pdf';
    3:
      filename := dir + '\RZDreport.html';
  end;
  if fileuse(filename) then
    exit;
  case Reptype.ItemIndex of
    0: // экспорт в Rtf
      begin
        frxRTFExport1.filename := filename;
        frxRTFExport1.OverwritePrompt := false;
        frxRTFExport1.ShowDialog := false;
        frxRTFExport1.ExportEMF := false;
        frxReport1.Export(frxRTFExport1);
      end;
    1: // экспорт в Rtf с выс. качеством
      begin
        frxRTFExport1.filename := filename;
        frxRTFExport1.ExportEMF := true;
        frxRTFExport1.OverwritePrompt := false;
        frxRTFExport1.ShowDialog := false;
        frxReport1.Export(frxRTFExport1);
      end;
    2: // экспорт в ПДФ
      begin
        frxPDFExport1.filename := filename;
        frxPDFExport1.OverwritePrompt := false;
        frxPDFExport1.ShowDialog := false;
        frxReport1.Export(frxPDFExport1);
      end;
    3: // экспорт в HTML
      begin
        frxHTMLExport1.filename := filename;
        frxHTMLExport1.OverwritePrompt := false;
        frxHTMLExport1.ShowDialog := false;
        frxReport1.Export(frxHTMLExport1);
      end;
  end;
  WP.Refresh;
end;

procedure TRZDFrm.VC_FramePathChange(Sender: TObject);
begin
  vc_src := m_wpMng.GetSrc(VC_Frame.Path.Text);
  CheckSrc;
end;

procedure TRZDFrm.VTree1DragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; shift: TShiftState;
  Pt: TPoint; var Effect: integer; Mode: TDropMode);
var
  FmtEtc: TFormatEtc;
  Medium: TStgMedium;
  FileCount: integer;
  i: integer;
  FileNameLength: integer;
  filename: string;
  FileList: tstringlist;
begin
  FileList := tstringlist.create;

  FmtEtc.cfFormat := CF_HDROP;
  FmtEtc.ptd := nil;
  FmtEtc.dwAspect := DVASPECT_CONTENT;
  FmtEtc.lindex := -1;
  FmtEtc.tymed := TYMED_HGLOBAL;
  if DataObject.GetData(FmtEtc, Medium) = S_OK then
    try
      try
        // второй параметр iFile - при ffffff - число файлов, иначе индекс файла
        FileCount := DragQueryFile(Medium.hGlobal, $FFFFFFFF, nil, 0);
        for i := 0 to FileCount - 1 do
        begin
          FileNameLength := DragQueryFile(Medium.hGlobal, i, nil, 0);
          setlength(filename, FileNameLength);
          DragQueryFile(Medium.hGlobal, i, PChar(filename), FileNameLength + 1);
          if testDir(filename) then
            FileList.Add(filename);
        end;
      finally
        DragFinish(Medium.hGlobal);
      end;
    finally
      ReleaseStgMedium(Medium);
    end;
  FormStyle := fsNormal;

  AddRZDDataFrm.showsignals(FileList);

  FileList.Destroy;
end;

// modes to determine drop position further
// TDropMode = (    dmNowhere,    dmAbove,    dmOnNode,    dmBelow  );
// TDragState = (dsDragEnter, dsDragLeave, dsDragMove);
procedure TRZDFrm.VTree1DragOver(Sender: TBaseVirtualTree; Source: TObject;
  shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: integer; var Accept: boolean);
begin
  Accept := false;
  if Source = nil then
    Accept := true;
end;

procedure TRZDFrm.Hin_FramePathChange(Sender: TObject);
begin
  hin_src := m_wpMng.GetSrc(Hin_Frame.Path.Text);
  CheckSrc;
end;

procedure TRZDFrm.Hin_FrameSelectIntervalCursorBtnClick(Sender: TObject);
begin
  Hin_Frame.SelectIntervalCursorBtnClick(Sender);
end;

procedure TRZDFrm.Hout_FramePathChange(Sender: TObject);
begin
  hout_src := m_wpMng.GetSrc(Hout_Frame.Path.Text);
  CheckSrc;
end;

procedure TRZDFrm.H_FramePathChange(Sender: TObject);
begin
  h_src := m_wpMng.GetSrc(H_Frame.Path.Text);
  CheckSrc;
end;

procedure testmnk;
var
  x, y, p: array of double;
  poly: integer;

  m1, m2, m3: d2array;
  i, j, c: integer;
begin
  setlength(m1, 3, 3);
  setlength(m2, 4, 3);
  c := 1;
  for i := 0 to 3 - 1 do
  begin
    for j := 0 to 3 - 1 do
    begin
      m1[i, j] := c;
      inc(c);
    end;
  end;
  c := 1;
  for i := 0 to 4 - 1 do
  begin
    for j := 0 to 3 - 1 do
    begin
      m2[i, j] := c;
      inc(c);
    end;
  end;
  MultMatrix(m1, m2, m3);

  poly := 2;
  setlength(x, 8);
  setlength(y, 8);
  setlength(p, poly + 1);

  x[0] := 0.72;
  y[0] := 0.53;
  x[1] := 0.99;
  y[1] := 1.10;
  x[2] := 1.11;
  y[2] := 1.22;
  x[3] := 1.76;
  y[3] := 3.22;
  x[4] := 1.86;
  y[4] := 3.91;
  x[5] := 2.55;
  y[5] := 6.23;
  x[6] := 3.24;
  y[6] := 9.06;
  x[7] := 4.53;
  y[7] := 2.32;

  buildMNK(poly, x, y, p);

end;

procedure TRZDFrm.ExportMatrixPathChange(Sender: TObject);
var
  str, dir: string;
begin
  str := RelativePathToAbsolute(BaseFolderEdit.Text, ExportMatrixPath.Text);
  // dir:=extractfiledir(str)+'\RZDmatrix\';
  // str:=dir+ExtractFileName(STR);
  ExportMatrixPath.Hint := 'Путь: ' + str;
end;

procedure TRZDFrm.ImportMatrixPathChange(Sender: TObject);
begin
  checkImportFolder;
end;

procedure TRZDFrm.BaseFolderEditChange(Sender: TObject);
begin
  // ищем папку
  if CheckFolderComponent(BaseFolderEdit, true) then
  BEGIN
    ReadRegionFolders;
    UpdateTestsFolder;
  END;
end;

procedure TRZDFrm.UpdateTestsFolder;
var
  str, fld, testfolder: string;
  list: tstringlist;
  i: integer;
begin
  str := GetTestsFolder;
  TestsFolderE.Hint := str;
  testfolder := str;
  if CheckFolderComponent(TestsFolderE, testfolder, true) then
  begin
    str := TestPath.Text;
  end;
  TestPath.clear;
  TestPath.Hint := '';
  list := tstringlist.create;
  FindFileext('*.mera', testfolder, 1, list);
  FindFileext('*.usm', testfolder, 1, list);
  TestPath.clear;
  for i := 0 to list.count - 1 do
  begin
    fld := list.Strings[i];
    if fld[length(fld)] <> gettestpath then
      TestPath.AddItem(fld, nil);
  end;
  TestPath.ItemIndex := -1;
  for i := 0 to list.count - 1 do
  begin
    if TestPath.Items[i] = str then
    begin
      TestPath.ItemIndex := i;
      break;
    end;
  end;
  if TestPath.ItemIndex = -1 then
  begin
    TestPath.AddItem(str, nil);
  end;
  list.Destroy;
end;

function TRZDFrm.GetTestsFolder: string;
begin
  result := RelativePathToAbsolute(BaseFolderEdit.Text, TestsFolderE.Text);
end;

function TRZDFrm.testDir(filename: string): boolean;
var
  list: tstringlist;
begin
  list := tstringlist.create;
  ScanDir(filename, '*.mera', list, 1);
  if list.count > 0 then
    result := true
  else
  begin
    result := false;
  end;
  list.Destroy;
end;

function TRZDFrm.checkImportFolder: boolean;
var
  str, dir: string;
begin
  str := RelativePathToAbsolute(BaseFolderEdit.Text, ImportMatrixPath.Text);
  dir := extractfiledir(str);
  str := dir + '\' + extractfilename(str);
  ImportMatrixPath.Hint := 'Путь: ' + str;
  // ищем файл
  result := CheckFolderComponent(ImportMatrixPath, str, false);
  if result then
  begin
    if m_DB <> nil then
      crzdbasefolder(m_DB.m_BaseFolder).m_MatrixFolder.Path :=
        ImportMatrixPath.Text;
  end;
end;

procedure TRZDFrm.CheckBaseFolder;
begin
  if DirectoryExists(BaseFolderEdit.Text) then
  begin
    BaseFolderEdit.color := clWindow;
    ReadRegionFolders;
  end
  else
  begin
    BaseFolderEdit.color := $008080FF;
  end;
end;

procedure TRZDFrm.UseMFmatrixClick(Sender: TObject);
var
  dir, rzdname, fname: string;
begin
  if UseMFmatrix.Checked then
  begin
    dir := extractfiledir(gettestpath) + '\';
    fname := FindFile('*.rzd', dir, 1);
    if fileexists(dir + fname) then
    begin
      ImpMatrix(dir + fname);
    end;
  end
  else
  begin
    ImpMatrixBtnClick(nil);
  end;
end;

procedure TRZDFrm.EvalFzFy(interval: point2d; Fz, Fy: iwpSignal; name: string);
var
  // коэффициенты полинома
  ci: array of double;
  x, y: olevariant;
  p, p2: point2d;
  size: integer;
  i: integer;
  graph: tgraphstruct;
  str: string;
begin
  if interval.y > interval.x then
  begin
    Fz := GetIntervalSignal(interval, Fz);
    Fy := GetIntervalSignal(interval, Fy);
  end;
  m_F2zFy := BuildWPDependence(Fy, Fz);
  m_F2zFy.sname := name + '_cloud';
  m_F2zFy.comment := 'Y:' + Fz.sname + '_X:' + Fy.sname;

  size := m_F2zFy.size;
  x := VarArrayCreate([0, size], varDouble);
  y := VarArrayCreate([0, size], varDouble);

  m_F2zFy.GetArray(0, size, y, x, true);
  setlength(ci, 1);
  buildMNK(0, x, y, size, ci);

  // добавляем запись в журнал
  str := name + ' Poly:';
  for i := 0 to length(ci) - 1 do
  begin
    str := str + ' ' + formatstrNoE(ci[i], c_digits);
  end;
  JournalLB.AddItem(str, nil);

  // создаем апроксимирующий полином в дереве сигналов
  m_F2zFy_poly := iwpSignal(WP.CreateSignalXY(VT_R8, VT_R8)) as iwpSignal;
  m_F2zFy_poly.size := 2;
  m_F2zFy_poly.sname := name + '_poly';
  m_F2zFy_poly.comment := 'Y:' + Fz.sname + '_X:' + Fy.sname;

  p.y := fi(PolySE.Value, ci, m_F2zFy.MinX);
  p.x := m_F2zFy.MinX;
  m_F2zFy_poly.SetX(0, p.x);
  m_F2zFy_poly.SetY(0, p.y);
  p2.y := fi(PolySE.Value, ci, m_F2zFy.MaxX);
  p2.x := m_F2zFy.MaxX;
  m_F2zFy_poly.SetX(1, p2.x);
  m_F2zFy_poly.SetY(1, p2.y);
  // уровень прямой на полиноме
  m_F2zFyValue := p2.y;
  if Abs(m_F2zFy.MaxX) > Abs(m_F2zFy.MinX) then
    m_F2zFyMaxX := m_F2zFy.MaxX
  else
    m_F2zFyMaxX := m_F2zFy.MinX;
  JournalLB.AddItem('Fz(Fy)=' + formatstrNoE(p2.y, c_digits), nil);

  // графика
  if LinkEvalWP.Checked then
  begin
    WP.Link('Signals/MNK/', m_F2zFy.sname, m_F2zFy);
    WP.Link('Signals/MNK/', m_F2zFy_poly.sname, m_F2zFy_poly);
    // строим графику
    graph := createline(m_F2zFy);
    IWPGraphs(WP.GraphAPI).SetLineOpt(graph.hline, LNOPT_ONLYPOINTS,
      LNOPT_ONLYPOINTS, 0, $00D2D5);
    graph := createline(m_F2zFy_poly, graph.hgraph, graph.haxis);
    WP.Refresh;
  end;
end;

function TRZDFrm.EvalEi(interval: point2d; s, V: iwpSignal; name: string): TEi;
var
  // коэффициенты полинома
  ci: array of double;
  x, y: olevariant;
  p, p2: point2d;
  size: integer;
  str: string;
  i: integer;
begin
  result.result := true;
  result.str_sname := s.sname;
  result.str_fName := V.sname;
  if interval.y > interval.x then
  begin
    s := GetIntervalSignal(interval, s);
    V := GetIntervalSignal(interval, V);
  end;

  // строим облако точек
  result.cloud := BuildWPDependence(V, s);
  result.cloud.sname := name + '_cloud';
  result.cloud.comment := 'Y:' + s.sname + '_X:' + V.sname;

  size := result.cloud.size;
  x := VarArrayCreate([0, size - 1], varDouble);
  y := VarArrayCreate([0, size - 1], varDouble);

  result.cloud.GetArray(0, size, y, x, true);
  setlength(ci, PolySE.Value + 1);

  buildMNK(PolySE.Value, x, y, size, ci);
  setlength(result.polyC, PolySE.Value + 1);
  // сохраняем коэфициенты
  for i := 0 to PolySE.Value do
  begin
    result.polyC[i] := ci[i];
  end;

  // добавляем запись в журнал
  str := name + ' Poly:';
  for i := 0 to length(ci) - 1 do
  begin
    str := str + ' ' + formatstrNoE(ci[i], c_digits);
  end;
  JournalLB.AddItem(str, nil);

  // создаем апроксимирующий полином в дереве сигналов
  if PolySE.Value < 2 then
  begin
    result.poly := iwpSignal(WP.CreateSignalXY(VT_R8, VT_R8)) as iwpSignal;
    result.poly.size := 2;
  end
  else
  begin
    result.poly := iwpSignal(WP.CreateSignal(VT_R8)) as iwpSignal;
    result.poly.size := PolyCount.intnum;
  end;
  result.poly.sname := name + '_poly';
  result.poly.comment := 'Y:' + s.sname + '_X:' + V.sname;

  if PolySE.Value < 2 then
  begin
    p.y := fi(PolySE.Value, ci, result.cloud.MinX);
    p.x := result.cloud.MinX;
    result.poly.SetX(0, p.x);
    result.poly.SetY(0, p.y);
    p2.y := fi(PolySE.Value, ci, result.cloud.MaxX);
    p2.x := result.cloud.MaxX;
    result.poly.SetX(1, p2.x);
    result.poly.SetY(1, p2.y);
  end
  else
  begin
    result.poly.StartX := result.cloud.MinX;
    result.poly.DeltaX := (result.cloud.MaxX - result.cloud.MinX)
      / result.poly.size;
    for i := 0 to result.poly.size - 1 do
    begin
      result.poly.SetY(i, fi(PolySE.Value, ci,
          i * result.poly.DeltaX + result.poly.StartX));
    end;
  end;

  if Abs(result.cloud.MaxX) > Abs(result.cloud.MinX) then
  begin
    result.fmax := result.cloud.MaxX;
    // result.ei := abs(p.y);
    result.ei := fi(PolySE.Value, ci, result.cloud.MaxX);
  end
  else
  begin
    result.fmax := result.cloud.MinX;
    // result.ei := abs(p2.y);
    result.ei := fi(PolySE.Value, ci, result.cloud.MinX);
  end;
end;

function TRZDFrm.ShowTimeGraphs(p: integer; fr: TRZDTareFrame; src: csrc;
  graphname: string): tgraphstruct;
var
  s1, s2, s3, s4, vt, gt: iwpSignal;
  graph: tgraphstruct;
begin
  s1 := src.GetSignal(fr.S1Cbox.Text);
  s2 := src.GetSignal(fr.S2Cbox.Text);
  s3 := src.GetSignal(fr.S3Cbox.Text);
  s4 := src.GetSignal(fr.S4Cbox.Text);
  vt := src.GetSignal(fr.VFCbox.Text);
  gt := src.GetSignal(fr.HFCbox.Text);

  // графика
  graph.hpage := p;
  // строим графику
  if p = 0 then
    graph := createline(s1)
  else
    graph := createline(s1, p);
  graph := createline(s2, graph.hgraph, graph.haxis);
  graph := createline(s3, graph.hgraph, graph.haxis);
  graph := createline(s4, graph.hgraph, graph.haxis);
  // в новую ось
  // graph := createline(vt, graph.hgraph, graph.haxis);
  // graph := createline(gt, graph.hgraph, graph.haxis);
  graph := createlineNewAx(vt, graph.hgraph);
  graph := createline(gt, graph.hgraph, graph.haxis);
  normaliseGraph(graph.hgraph);
  result := graph;
end;

procedure TRZDFrm.StayOnTopBtnClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
  begin
    FormStyle := fsStayOnTop;
    StayOnTopBtn.Hint := 'Поверх окон';
    StayOnTopBtn.Down := true;
  end
  else
  begin
    FormStyle := fsNormal;
    StayOnTopBtn.Down := false;
    StayOnTopBtn.Hint := 'Скрывать окно';
  end;
end;

// Загрузка данных для построения матрицы
function TRZDFrm.PrepareDataforMatrix: boolean;
begin
  // загружаем источники
  LoadVCSrc;
  LoadHSrc;
  LoadHinCSrc;
  LoadHoutSrc;
  result := CheckSrc;
end;

function TRZDFrm.GetSignal(src: csrc; sname: string; calibr: boolean;
  var findSignal: boolean): iwpSignal;
var
  str: string;
  s, smo: iwpSignal;
  mo: double;
  flt: boolean;
  isig: iwpSignal;
  nullInterval: point2d;
begin
  result := nil;
  str := src.name + '/Filter/' + sname + '_Flt';
  // '/Signals/Sig75.mera/Filter/_141Vt_Flt'
  isig := getISignalByPath(str);
  if isig <> nil then
  begin
    findSignal := true;
    result := isig;
    exit;
  end;
  s := src.GetSignal(sname);
  if s <> nil then
    findSignal := true
  else
  begin
    findSignal := false;
    exit;
  end;

  flt := false;
  if TrendCB.Checked then
  begin
    s := TrendMO(s, TrendPortionIE.intnum);
    flt := true;
  end;
  if LPFCB.Checked then
  begin
    s := lpf(s, LPFOrder.intnum, LPFfreq.FloatNum);
    flt := true;
  end;
  if flt then
    s.sname := sname + '_Flt';

  if src = vc_src then
  begin
    nullInterval := VC_Frame.GetNullInterval;
  end;
  if src = h_src then
  begin
    nullInterval := H_Frame.GetNullInterval;
  end;
  if src = hin_src then
  begin
    nullInterval := Hin_Frame.GetNullInterval;
  end;
  if src = hout_src then
  begin
    nullInterval := Hout_Frame.GetNullInterval;
  end;
  // балансировка нуля
  if calibr then
  begin
    if nullInterval.x <> nullInterval.y then
    begin
      if flt = false then
      begin
        flt := true;
      end;
      smo := GetIntervalSignal(nullInterval, s);
      mo := GetMO(smo);
      s := addconstant(-1 * mo, s);
      s.sname := sname + '_Flt';
    end;
  end;

  result := s;
  if flt then
  begin
    str := src.name + '/Filter/' + s.sname;
    isig := getISignalByPath(str);
    if isig = nil then
    begin
      WP.Link(src.name + '/Filter/', s.sname, s);
      WP.Refresh;
    end;
  end;
end;

function TRZDFrm.CheckSrc: boolean;
begin
  result := true;
  if (vc_src = nil) or (h_src = nil) or (hout_src = nil) or (hin_src = nil) then
  begin
    result := false;
    CreateMatrixBtn.Caption := 'Загрузить';
    LoadBtnPanel.color := clBtnFace;
    DrawGraphBtn.Hint := 'Не загружены сигналы';
  end
  else
  begin
    CreateMatrixBtn.Caption := 'Создать';
    LoadBtnPanel.color := clGreen;
    DrawGraphBtn.Hint := 'Отрисовать графики';
  end;
end;

function TRZDFrm.checkSignalInterval(s: iwpSignal; interval: point2d): boolean;
var
  min, max: double;
begin
  result := true;
  if (s.MaxX < interval.x) or (s.MinX > interval.y) then
  begin
    JournalLB.AddItem('Интервал сигнала не совпадает с выбраным интервалом!' +
        formatstrNoE(s.MinX, c_digits) + '..' + formatstrNoE(s.MaxX, c_digits),
      nil);
    result := false;
  end;
end;

function getAbsMax(v1, v2: double): double;
begin
  result := v1;
  if Abs(v1) < Abs(v2) then
    result := v2;
end;

procedure TRZDFrm.CreateMatrixBtnClick(Sender: TObject);
var
  s, f, res, smo: iwpSignal;
  p: tgraphstruct;
  interval, interval1, interval2, interval3, interval4, p1, p2: point2d;
  c: double;
  src: csrc;
  frame: TRZDTareFrame;
  e1fore2, mo: double;
  i, j: integer;
  b: boolean;
  n: iwpnode;
  str: string;
  vt, gt: array [0 .. 3] of double;
  ifile: tinifile;
begin
  if not CheckSrc then
  begin
    PrepareDataforMatrix;
    exit;
  end;
  JournalLB.clear;

  // Считаем E1
  src := vc_src;
  frame := VC_Frame;
  s := GetSignal(src, frame.S1Cbox.Text, NullCb.Checked, b);
  f := GetSignal(src, frame.VFCbox.Text, NullCb.Checked, b);
  interval := frame.GetInterval;

  interval1 := interval;
  JournalLB.AddItem('Интервал: ' + formatstrNoE(interval.x,
      c_digits) + '..' + formatstrNoE(interval.y, c_digits), nil);
  if not checkSignalInterval(s, interval) then
  begin
    setJournalAlarm(true);
    exit;
  end;
  if not checkSignalInterval(f, interval) then
  begin
    setJournalAlarm(true);
    exit;
  end;

  e1[0] := EvalEi(interval, s, f, 'E1_1');
  s := GetSignal(src, frame.S2Cbox.Text, NullCb.Checked, b);
  e1[1] := EvalEi(interval, s, f, 'E1_2');
  s := GetSignal(src, frame.S3Cbox.Text, NullCb.Checked, b);
  e1[2] := EvalEi(interval, s, f, 'E1_3');
  s := GetSignal(src, frame.S4Cbox.Text, NullCb.Checked, b);
  e1[3] := EvalEi(interval, s, f, 'E1_4');
  for i := 0 to 3 do
  begin
    if e1[i].result = false then
    begin
      JournalLB.AddItem('Не удалось расчитать e1', nil);
      setJournalAlarm(true);
      exit;
    end;
  end;

  // нужно ли учитывать знак fmax?
  e1norm.i1 := e1[0].ei / e1[0].fmax;
  e1norm.i2 := e1[1].ei / e1[1].fmax;
  e1norm.i3 := e1[2].ei / e1[2].fmax;
  e1norm.i4 := e1[3].ei / e1[3].fmax;
  LinkEiSignals(e1);
  addEiJournal('e1', e1, e1norm);
  f := GetIntervalSignal(interval, f);
  vt[0] := getAbsMax(f.MaxY, f.MinY);
  f := GetSignal(src, frame.HFCbox.Text, NullCb.Checked, b);
  f := GetIntervalSignal(interval, f);
  gt[0] := getAbsMax(f.MaxY, f.MinY);
  JournalLB.AddItem('', nil);

  // Считаем E2
  src := h_src;
  frame := H_Frame;
  s := GetSignal(src, frame.S1Cbox.Text, NullCb.Checked, b);
  f := GetSignal(src, frame.HFCbox.Text, NullCb.Checked, b);
  interval := frame.GetInterval;
  interval2 := interval;

  JournalLB.AddItem('Интервал: ' + formatstrNoE(interval.x,
      c_digits) + '..' + formatstrNoE(interval.y, c_digits), nil);
  if not checkSignalInterval(s, interval) then
  begin
    setJournalAlarm(true);
    exit;
  end;
  if not checkSignalInterval(f, interval) then
  begin
    setJournalAlarm(true);
    exit;
  end;

  e2[0] := EvalEi(interval, s, f, 'E2_1');
  s := GetSignal(src, frame.S2Cbox.Text, NullCb.Checked, b);
  e2[1] := EvalEi(interval, s, f, 'E2_2');
  s := GetSignal(src, frame.S3Cbox.Text, NullCb.Checked, b);
  e2[2] := EvalEi(interval, s, f, 'E2_3');
  s := GetSignal(src, frame.S4Cbox.Text, NullCb.Checked, b);
  e2[3] := EvalEi(interval, s, f, 'E2_4');
  for i := 0 to 3 do
  begin
    if e2[i].result = false then
    begin
      JournalLB.AddItem('Не удалось расчитать e2', nil);
      setJournalAlarm(true);
      exit;
    end;
  end;

  s := GetSignal(src, frame.VFCbox.Text, NullCb.Checked, b);
  f := GetSignal(src, frame.HFCbox.Text, NullCb.Checked, b);
  EvalFzFy(interval, s, f, 'Fz(Fy)');

  c := 1 / e2[0].fmax;
  for i := 0 to 3 do
  begin
    e1fore2 := fi(e1[i].polyC, m_F2zFyValue);
    case i of
      0:
      begin
        e2norm.i1 := c * (e2[i].ei - e1fore2);
        e2norm.i1 := c * (e2[i].ei - e1norm.i1*m_F2zFyValue);
      end;
      1:
      begin
        e2norm.i2 := c * (e2[i].ei - e1fore2);
        e2norm.i2 := c * (e2[i].ei - e1norm.i2*m_F2zFyValue);
      end;
      2:
      begin
        e2norm.i3 := c * (e2[i].ei - e1fore2);
        e2norm.i3 := c * (e2[i].ei - e1norm.i3*m_F2zFyValue);
      end;
      3:
      begin
        e2norm.i4 := c * (e2[i].ei - e1fore2);
        e2norm.i4 := c * (e2[i].ei - e1norm.i4*m_F2zFyValue);
      end;
    end;
  end;

  LinkEiSignals(e2);
  addEiJournal('e2', e2, e2norm);

  f := GetSignal(src, frame.VFCbox.Text, NullCb.Checked, b);
  f := GetIntervalSignal(interval, f);
  vt[1] := getAbsMax(f.MaxY, f.MinY); ;
  f := GetSignal(src, frame.HFCbox.Text, NullCb.Checked, b);
  f := GetIntervalSignal(interval, f);
  gt[1] := getAbsMax(f.MaxY, f.MinY); ;
  JournalLB.AddItem('', nil);

  // Считаем E3
  src := hout_src;
  frame := Hout_Frame;
  s := GetSignal(src, frame.S1Cbox.Text, NullCb.Checked, b);
  f := GetSignal(src, frame.VFCbox.Text, NullCb.Checked, b);
  interval := frame.GetInterval;
  interval3 := interval;

  JournalLB.AddItem('Интервал: ' + formatstrNoE(interval.x,
      c_digits) + '..' + formatstrNoE(interval.y, c_digits), nil);
  if not checkSignalInterval(s, interval) then
  begin
    setJournalAlarm(true);
    exit;
  end;
  if not checkSignalInterval(f, interval) then
  begin
    setJournalAlarm(true);
    exit;
  end;


  e3[0] := EvalEi(interval, s, f, 'E3_1');
  s := GetSignal(src, frame.S2Cbox.Text, NullCb.Checked, b);
  e3[1] := EvalEi(interval, s, f, 'E3_2');
  s := GetSignal(src, frame.S3Cbox.Text, NullCb.Checked, b);
  e3[2] := EvalEi(interval, s, f, 'E3_3');
  s := GetSignal(src, frame.S4Cbox.Text, NullCb.Checked, b);
  e3[3] := EvalEi(interval, s, f, 'E3_4');
  for i := 0 to 3 do
  begin
    if e3[i].result = false then
    begin
      JournalLB.AddItem('Не удалось расчитать e3', nil);
      setJournalAlarm(true);
      exit;
    end;
  end;
  c := 1 / e3[0].fmax;
  e3norm.i1 := c * (e3[0].ei);
  e3norm.i2 := c * (e3[1].ei);
  e3norm.i3 := c * (e3[2].ei);
  e3norm.i4 := c * (e3[3].ei);
  LinkEiSignals(e3);
  addEiJournal('доп. e3', e3, e3norm);

  f := GetSignal(src, frame.VFCbox.Text, NullCb.Checked, b);
  f := GetIntervalSignal(interval, f);
  vt[2] := getAbsMax(f.MaxY, f.MinY); ;
  f := GetSignal(src, frame.HFCbox.Text, NullCb.Checked, b);
  f := GetIntervalSignal(interval, f);
  gt[2] := getAbsMax(f.MaxY, f.MinY); ;
  JournalLB.AddItem('', nil);
  // Считаем E4
  src := hin_src;
  frame := Hin_Frame;
  s := GetSignal(src, frame.S1Cbox.Text, NullCb.Checked, b);
  f := GetSignal(src, frame.VFCbox.Text, NullCb.Checked, b);
  interval := frame.GetInterval;
  interval4 := interval;

  JournalLB.AddItem('Интервал: ' + formatstrNoE(interval.x,
      c_digits) + '..' + formatstrNoE(interval.y, c_digits), nil);
  if not checkSignalInterval(s, interval) then
    exit;
  if not checkSignalInterval(f, interval) then
    exit;

  e4[0] := EvalEi(interval, s, f, 'E4_1');
  s := GetSignal(src, frame.S2Cbox.Text, NullCb.Checked, b);
  e4[1] := EvalEi(interval, s, f, 'E4_2');
  s := GetSignal(src, frame.S3Cbox.Text, NullCb.Checked, b);
  e4[2] := EvalEi(interval, s, f, 'E4_3');
  s := GetSignal(src, frame.S4Cbox.Text, NullCb.Checked, b);
  e4[3] := EvalEi(interval, s, f, 'E4_4');
  for i := 0 to 3 do
  begin
    if e4[i].result = false then
    begin
      JournalLB.AddItem('Не удалось расчитать e4', nil);
      setJournalAlarm(true);
      exit;
    end;
  end;
  c := 1 / e4[0].fmax;
  e4norm.i1 := c * (e4[0].ei);
  e4norm.i2 := c * (e4[1].ei);
  e4norm.i3 := c * (e4[2].ei);
  e4norm.i4 := c * (e4[3].ei);
  LinkEiSignals(e4);
  addEiJournal('доп. e4 ', e4, e4norm);

  f := GetSignal(src, frame.VFCbox.Text, NullCb.Checked, b);
  f := GetIntervalSignal(interval, f);
  vt[3] := getAbsMax(f.MaxY, f.MinY); ;
  f := GetSignal(src, frame.HFCbox.Text, NullCb.Checked, b);
  f := GetIntervalSignal(interval, f);
  gt[3] := getAbsMax(f.MaxY, f.MinY); ;
  JournalLB.AddItem('', nil);
  // Вычисляем окончательно e3
  c := 1 / (2 * Hout_D.FloatNum);
  e3norm.i1 := c * (e3norm.i1 - e4norm.i1);
  e3norm.i2 := c * (e3norm.i2 - e4norm.i2);
  e3norm.i3 := c * (e3norm.i3 - e4norm.i3);
  e3norm.i4 := c * (e3norm.i4 - e4norm.i4);
  JournalLB.AddItem('e3norm: ' + formatstrNoE(e3norm.i1,
      c_digits) + '; ' + formatstrNoE(e3norm.i2,
      c_digits) + '; ' + formatstrNoE(e3norm.i3,
      c_digits) + '; ' + formatstrNoE(e3norm.i4, c_digits), nil);

  E[0, 0] := e1norm.i1;
  E[0, 1] := e1norm.i2;
  E[0, 2] := e1norm.i3;
  E[0, 3] := e1norm.i4;
  E[1, 0] := e2norm.i1;
  E[1, 1] := e2norm.i2;
  E[1, 2] := e2norm.i3;
  E[1, 3] := e2norm.i4;
  E[2, 0] := e3norm.i1;
  E[2, 1] := e3norm.i2;
  E[2, 2] := e3norm.i3;
  E[2, 3] := e3norm.i4;
  buildG;

  frame := VC_Frame;
  m_matrix := TRZDMatrix.create;
  m_matrix.date := datetostr(now);
  for i := 0 to 3 do
  begin
    case i of
      0:
        begin
          src := vc_src;
          m_matrix.sensors[i].t1t2 := interval1;
          frame := VC_Frame;
        end;
      1:
        begin
          src := h_src;
          m_matrix.sensors[i].t1t2 := interval2;
          frame := H_Frame;
        end;
      2:
        begin
          src := hout_src;
          m_matrix.sensors[i].t1t2 := interval3;
          frame := Hout_Frame;
        end;
      3:
        begin
          src := hin_src;
          m_matrix.sensors[i].t1t2 := interval4;
          frame := Hin_Frame;
        end;
    end;
    m_matrix.vtmax[i] := vt[i];
    m_matrix.gtmax[i] := gt[i];
    m_matrix.sensors[i].mf := extractfilename(frame.Path.Text);
    m_matrix.sensors[i].vt := frame.VFCbox.Text;
    m_matrix.sensors[i].gt := frame.HFCbox.Text;
    m_matrix.sensors[i].s1 := frame.S1Cbox.Text;
    m_matrix.sensors[i].s2 := frame.S2Cbox.Text;
    m_matrix.sensors[i].s3 := frame.S3Cbox.Text;
    m_matrix.sensors[i].s4 := frame.S4Cbox.Text;
  end;
  m_matrix.poly := PolySE.Value;
  m_matrix.cut := CutSE.Value;
  m_matrix.region := RegionCB.Text;
  // m_matrix.useSNames := not useSignalPrefix.Checked;
  for i := 0 to 3 do
  begin
    for j := 0 to 2 do
    begin
      m_matrix.m[i, j] := G[i, j];
    end;
  end;
  addMatrix(m_matrix);
  ShowMatrixList;
  // проверка качества работы матрицы
  m_matrix.useSNames := true;
  UpdateMatrixNames(m_matrix, VC_Frame);
  if m_matrix.ApplyMatrix(vc_src) then
  begin
    n := WP.Get(vc_src.name + '/RZDForce') as iwpnode;
    str := extractfiledir(vc_src.merafile.filename);
    WP.SaveUSML(n.absolutepath, str + '\RZDforce.mera');

    ifile := tinifile.create(str + '\RZDForce\RZDforce.mera');
    ifile.writeString('RZDHexa', 'VT', m_matrix.lastn1);
    ifile.writeString('RZDHexa', 'GT', m_matrix.lastn2);
    ifile.writeString('RZDHexa', 'M', m_matrix.lastn3);
    ifile.Destroy;

    CheckMatrix(m_matrix, vc_src);
  end
  else
    exit;
  UpdateMatrixNames(m_matrix, H_Frame);
  if m_matrix.ApplyMatrix(h_src) then
  begin
    n := WP.Get(h_src.name + '/RZDForce') as iwpnode;
    str := extractfiledir(h_src.merafile.filename);
    WP.SaveUSML(n.absolutepath, str + '\RZDforce.mera');

    ifile := tinifile.create(str + '\RZDForce\RZDforce.mera');
    ifile.writeString('RZDHexa', 'VT', m_matrix.lastn1);
    ifile.writeString('RZDHexa', 'GT', m_matrix.lastn2);
    ifile.writeString('RZDHexa', 'M', m_matrix.lastn3);
    ifile.Destroy;

    CheckMatrix(m_matrix, h_src);
  end
  else
    exit;
  UpdateMatrixNames(m_matrix, Hout_Frame);
  if m_matrix.ApplyMatrix(hout_src) then
  begin
    n := WP.Get(hout_src.name + '/RZDForce') as iwpnode;
    str := extractfiledir(hout_src.merafile.filename);
    WP.SaveUSML(n.absolutepath, str + '\RZDforce.mera');

    ifile := tinifile.create(str + '\RZDForce\RZDforce.mera');
    ifile.writeString('RZDHexa', 'VT', m_matrix.lastn1);
    ifile.writeString('RZDHexa', 'GT', m_matrix.lastn2);
    ifile.writeString('RZDHexa', 'M', m_matrix.lastn3);
    ifile.Destroy;

    CheckMatrix(m_matrix, hout_src);
  end
  else
    exit;
  UpdateMatrixNames(m_matrix, Hin_Frame);
  if m_matrix.ApplyMatrix(hin_src) then
  begin
    n := WP.Get(hin_src.name + '/RZDForce') as iwpnode;
    str := extractfiledir(hin_src.merafile.filename);
    WP.SaveUSML(n.absolutepath, str + '\RZDforce.mera');

    ifile := tinifile.create(str + '\RZDForce\RZDforce.mera');
    ifile.writeString('RZDHexa', 'VT', m_matrix.lastn1);
    ifile.writeString('RZDHexa', 'GT', m_matrix.lastn2);
    ifile.writeString('RZDHexa', 'M', m_matrix.lastn3);
    ifile.Destroy;

    CheckMatrix(m_matrix, hin_src);
  end
  else
    exit;
  m_matrix.useSNames := false;
  WP.Refresh;
end;

procedure TRZDFrm.CheckMatrix(m: TRZDMatrix; src: csrc);
var
  p: tgraphstruct;
  sig, f, res, res1, res2: iwpSignal;
  lcaption: string;
  b: boolean;
  frame: TRZDTareFrame;
  i: integer;
  lsrc: csrc;
  vtmax, gtmax, V: double;
  n: iwpnode;
  lcolor: integer;
begin
  for i := 0 to 3 do
  begin
    case i of
      0:
        begin
          lsrc := vc_src;
          frame := VC_Frame;
          lcaption := 'Сравнение для нагр-ия верт. силой'
        end;
      1:
        begin
          lsrc := h_src;
          frame := H_Frame;
          lcaption := 'Сравнение для нагр-ия горизонтальной силой';
        end;
      2:
        begin
          lsrc := hout_src;
          frame := Hout_Frame;
          lcaption := 'Сравнение для нагр-ия верт. силой с смещением наружу';
        end;
      3:
        begin
          lsrc := hin_src;
          frame := Hin_Frame;
          lcaption := 'Сравнение для нагр-ия верт. силой с смещением внутрь';
        end;
    end;
    if src = lsrc then
      break;
  end;
  vtmax := m.vtmax[i];
  gtmax := m.gtmax[i];

  // n := WP.Get(src.name + '/RZDForce/' + 'Vt_' + inttostr(m_matrix.cut)
  // + '_' + m.region) as iwpnode;
  n := m.n1;
  if n = nil then
    exit;
  sig := n.Reference as iwpSignal;

  f := GetSignal(src, frame.VFCbox.Text, false, b);
  JournalLB.AddItem(lcaption, nil);
  JournalLB.AddItem('Vtmax=' + formatstrNoE(vtmax, c_digits), nil);

  // res := BuildCompare(sig, f, GetAbsRelFmax(vtmax, FmaxEdit.FloatNum, FmaxAbsFe.FloatNum), src.name + '/RZDForce/', res1, res2);
  res := BuildCompare(sig, f, FmaxAbsFE.FloatNum, FmaxEdit.FloatNum,
    src.name + '/RZDForce/', res1, res2);

  p := createline(sig);
  IWPGraphs(WP.GraphAPI).SetPageDim(p.hpage, PAGE_DM_TABLE, 2, 2);
  p := createline(f, p.hgraph, p.haxis);

  // p := createline(res, p.hpage);
  // res1 - сигнал разница между исходным и расчитанным
  p := createline(res1, p.hpage);
  // res - сигнал сравнение
  // p := createline(res, p.hgraph, p.haxis);
  // res2 - знаменатель
  p := createline(res2, p.hgraph, p.haxis);
  lcolor := clred;
  IWPGraphs(WP.GraphAPI).SetLineOpt(p.hline, LNOPT_color + LNOPT_WIDTH,
    LNOPT_color + LNOPT_WIDTH, 3, lcolor);

  V := GetRMS(res);
  // IWPGraphs(WP.GraphAPI).AddComment(p.hgraph, lcaption + ' F=Vt ' + 'D= ' + formatstr(V, c_digits), 15, 5, c_CommentDx*9, c_CommentDy*1);
  IWPGraphs(WP.GraphAPI).AddComment(p.hgraph, lcaption + ' F=Vt', 15, 5,
    c_CommentDx * 9, c_CommentDy * 1);

  n := m.n2;
  sig := n.Reference as iwpSignal;
  // sig := (WP.Get(src.name + '/RZDForce/' + 'Gt_' + inttostr(m_matrix.cut)
  // + '_' + m.region) as iwpnode).Reference as iwpSignal;
  f := GetSignal(src, frame.HFCbox.Text, false, b);
  // f:=GetIntervalSignal(m.sensors[i].t1t2,f);
  JournalLB.AddItem('Gtmax=' + formatstrNoE(gtmax, c_digits), nil);
  res := BuildCompare(sig, f, GtmaxAbsFE.FloatNum, GtmaxEdit.FloatNum,
    src.name + '/RZDForce/', res1, res2);
  p := createline(sig, p.hpage);
  p := createline(f, p.hgraph, p.haxis);

  // p := createline(res, p.hpage);
  p := createline(res1, p.hpage);
  p := createline(res2, p.hgraph, p.haxis);
  lcolor := clred;
  IWPGraphs(WP.GraphAPI).SetLineOpt(p.hline, LNOPT_color + LNOPT_WIDTH,
    LNOPT_color + LNOPT_WIDTH, 3, lcolor);

  V := GetRMS(res);
  // IWPGraphs(WP.GraphAPI).AddComment(p.hgraph, lcaption + ' F=Gt ' + 'D= ' + formatstr(V, c_digits), 15, 5, c_CommentDx*9, c_CommentDy*1);
  IWPGraphs(WP.GraphAPI).AddComment(p.hgraph, lcaption + ' F=Gt', 15, 5,
    c_CommentDx * 9, c_CommentDy * 1);
end;

procedure TRZDFrm.addgistproc(start, shift: integer; lvl, noise: double;
  proc: boolean);
var
  gist: cGist;
  li: TListItem;
begin
  gist := cGist.create;
  gist.start := start;
  gist.shift := shift;
  gist.proc := proc;
  gist.lvl := lvl;
  gist.noise := noise;

  li := GistLV.Items.Add;
  li.data := gist;
  GistLV.SetSubItemByColumnName('Первый импульс', inttostr(gist.start), li);
  GistLV.SetSubItemByColumnName('Пропуск', inttostr(gist.shift), li);
end;

procedure TRZDFrm.setJournalAlarm(b:boolean);
begin
  if b then
  begin
    m_JourmalAlarm:=b;
    JournalPageControl.ActivePageIndex:=0;
    //JournalPageControl.Pages[0].Highlighted:=true;
  end
  else
  begin
    //JournalPageControl.Pages[0].Highlighted:=false;
    m_JourmalAlarm:=b;
  end;
end;

procedure TRZDFrm.cleargist;
var
  i: integer;
  li: TListItem;
begin
  for i := 0 to GistLV.Items.count - 1 do
  begin
    li := GistLV.Items[i];
    cGist(li.data).Destroy;
  end;
  GistLV.clear;
end;

procedure TRZDFrm.AddGistClick(Sender: TObject);
begin
  addgistproc(GistStart.Value, GistShiftSE.Value, GistTrigFE.FloatNum,
    GistNoiseFE.FloatNum, GistProcCB.Checked);
end;

procedure TRZDFrm.UpdateMatrixNames(m: TRZDMatrix; fr: TRZDTareFrame);
begin
  m.ls1 := fr.S1Cbox.Text;
  m.ls2 := fr.S2Cbox.Text;
  m.ls3 := fr.S3Cbox.Text;
  m.ls4 := fr.S4Cbox.Text;
end;

procedure TRZDFrm.addMatrix(m: TRZDMatrix);
var
  i: integer;
  lm: TRZDMatrix;
begin
  for i := 0 to MatrixList.count - 1 do
  begin
    lm := TRZDMatrix(MatrixList.Items[i]);
    if lm.GetIniName = m.GetIniName then
    begin
      lm.Destroy;
      MatrixList.Items[i] := m;
      exit;
    end;
  end;
  MatrixList.Add(m);
end;

procedure TRZDFrm.ApplyBtnClick(Sender: TObject);
var
  i: integer;
  m: TRZDMatrix;
  j: integer;
  cb: TComboBox;
begin
  for i := 0 to MatrixLV.Items.count - 1 do
  begin
    if MatrixLV.Items[i].Selected then
    begin
      m := TRZDMatrix(MatrixLV.Items[i].data);
      m.m := getformmatrix;
      if Matrix_CutSE.Text <> '' then
        m.cut := Matrix_CutSE.Value;
      if MatrixRegSE.Text <> '' then
        m.region := MatrixRegSE.Text;
      if mat_UseNamesCB.State <> cbGrayed then
        m.useSNames := mat_UseNamesCB.Checked;
      if m.useSNames then
      begin
        for j := 0 to 3 do
        begin
          cb := GetSensCB(j);
          if (cb.Text <> '_') and (cb.Text <> '') then
          begin
            m.sets(j, cb.Text);
          end;
        end;
      end;
    end;
  end;
  ShowMatrixList;
end;

procedure TRZDFrm.CutSEChange(Sender: TObject);
var
  str, str1: string;
  b, find: boolean;
  i, endnum: integer;
begin
  str := m_sectionPref + '_' + inttostr(CutSE.Value);
  str := lowercase(str);
  find := false;
  for i := 0 to sectionCB.Items.count - 1 do
  begin
    str1 := lowercase(sectionCB.Items[i]);
    if CheckPosSubstr(m_sectionPref, str1) then
    begin
      str1 := getendnum(str1);
      if strtoint(str1) = CutSE.Value then
      begin
        sectionCB.ItemIndex := i;
        break;
        find := true;
        b := true;
      end;
    end;
  end;
  if not find then
  begin
    if sectionCB.ItemIndex <> -1 then
    begin
      str1 := lowercase(sectionCB.Items[sectionCB.ItemIndex]);
    end
    else
      str1 := sectionCB.Text;
    endnum := strtoint(getendnum(str1));
    if endnum < CutSE.Value then
    begin
      // пробуем уйти к ближайшему наверх
      if (sectionCB.ItemIndex + 1) < (sectionCB.Items.count) then
      begin
        sectionCB.ItemIndex := sectionCB.ItemIndex + 1;
      end;
    end;
    if endnum > CutSE.Value then
    begin
      // пробуем уйти к ближайшему вниз
      if (sectionCB.ItemIndex - 1) > -1 then
      begin
        sectionCB.ItemIndex := sectionCB.ItemIndex - 1;
      end;
    end;
  end;
  sectionCBChange(nil);
end;

procedure TRZDFrm.DelGistClick(Sender: TObject);
var
  li: TListItem;
begin
  li := GistLV.Selected;
  if li <> nil then
    cGist(li.data).Destroy;
  li.Delete;
end;

procedure TRZDFrm.DelMatrixBtnClick(Sender: TObject);
var
  li: TListItem;
  m: TRZDMatrix;
begin
  if MatrixLV.Selected <> nil then
  begin
    li := MatrixLV.Selected;
    m := MatrixList.Items[li.Index];
    m.Destroy;
    MatrixList.Delete(li.Index);
    MatrixLV.DeleteSelected;
    ShowMatrixList;
  end;
end;

function TRZDFrm.GetSensorsNameWithPref(mf: string; sect: integer): tstringlist;
var
  i: integer;
  str, str1, str2, str3, str4, endnum: string;
  s1, s2, s3, s4: boolean;
  sections: tstringlist;
  ifile: tinifile;
begin
  result := tstringlist.create;
  s1 := false;
  s2 := false;
  s3 := false;
  s4 := false;
  ifile := tinifile.create(mf);
  sections := tstringlist.create;
  ifile.ReadSections(sections);
  for i := 0 to sections.count - 1 do
  begin
    str := sections.Strings[i];
    if CheckPosSubstr(m_D1Pref + inttostr(sect), str) then
    begin
      endnum := getendnum(str);
      if strtoint(endnum) = sect then
      begin
        if not s1 then
        begin
          str1 := str;
          s1 := true;
        end;
      end;
    end;
    if CheckPosSubstr(m_D2Pref + inttostr(sect), str) then
    begin
      endnum := getendnum(str);
      if strtoint(endnum) = sect then
      begin
        if not s2 then
        begin
          str2 := str;
          s2 := true;
        end;
      end;
    end;
    if CheckPosSubstr(m_D3Pref + inttostr(sect), str) then
    begin
      endnum := getendnum(str);
      if strtoint(endnum) = sect then
      begin
        if not s3 then
        begin
          str3 := str;
          s3 := true;
        end;
      end;
    end;
    if CheckPosSubstr(m_D4Pref + inttostr(sect), str) then
    begin
      endnum := getendnum(str);
      if strtoint(endnum) = sect then
      begin
        if not s4 then
        begin
          str4 := str;
          s4 := true;
        end;
      end;
    end;
  end;
  result.Add(str1);
  result.Add(str2);
  result.Add(str3);
  result.Add(str4);
  ifile.Destroy;
  sections.Destroy;
end;

function TRZDFrm.GetSensorsNameWithPref(src: csrc; sect: integer): tstringlist;
var
  i: integer;
  str, ls1, ls2, ls3, ls4: string;
  s1, s2, s3, s4: boolean;
begin
  result := tstringlist.create;
  s1 := false;
  s2 := false;
  s3 := false;
  s4 := false;
  for i := 0 to src.childCount - 1 do
  begin
    str := src.getSignalObj(i).name;
    if CheckPosSubstr(m_D1Pref + inttostr(sect), str) then
    begin
      if not s1 then
      begin
        result.Add(str);
        s1 := true;
      end;
    end;
    if CheckPosSubstr(m_D2Pref + inttostr(sect), str) then
    begin
      if not s2 then
      begin
        result.Add(str);
        s2 := true;
      end;
    end;
    if CheckPosSubstr(m_D3Pref + inttostr(sect), str) then
    begin
      if not s3 then
      begin
        result.Add(str);
        s3 := true;
      end;
    end;
    if CheckPosSubstr(m_D4Pref + inttostr(sect), str) then
    begin
      if not s4 then
      begin
        result.Add(str);
        s4 := true;
      end;
    end;
  end;
  for i := 0 to result.count - 1 do
  begin
    str := result.Strings[i];
    if CheckPosSubstr(m_D1Pref + inttostr(sect), str) then
    begin
      ls1 := str;
    end;
    if CheckPosSubstr(m_D2Pref + inttostr(sect), str) then
    begin
      ls2 := str;
    end;
    if CheckPosSubstr(m_D3Pref + inttostr(sect), str) then
    begin
      ls3 := str;
    end;
    if CheckPosSubstr(m_D4Pref + inttostr(sect), str) then
    begin
      ls4 := str;
    end;
  end;
  result.clear;
  if s1 then
    result.Add(ls1);
  if s2 then
    result.Add(ls2);
  if s3 then
    result.Add(ls3);
  if s4 then
    result.Add(ls4);
end;

procedure TRZDFrm.ApplyMatrix(s1, s2, s3, s4: iwpSignal; p_g: d2array;
  srcpath: string; sname: string; m: TRZDMatrix);
var
  // максимальная частота опроса среди сигналов
  V, v1, v2, v3, v4, DeltaX, maxFS, min, max: double;
  interval: point2d;
  // датчик с максимальной частотой дискретизации
  i, start, stop: integer;
  s, r1, r2, r3: iwpSignal;
  folder, str: string;
begin
  maxFS := s1.DeltaX;
  s := s1;
  if s2.DeltaX < maxFS then
  begin
    s := s2;
    maxFS := s2.DeltaX;
  end;
  if s3.DeltaX < maxFS then
  begin
    s := s3;
    maxFS := s3.DeltaX;
  end;
  if s4.DeltaX < maxFS then
  begin
    s := s4;
    maxFS := s4.DeltaX;
  end;
  DeltaX := maxFS;
  maxFS := 1 / maxFS;
  // находим интервал обработки
  interval.x := s1.MinX;
  if s2.MinX > interval.x then
    interval.x := s2.MinX;
  if s3.MinX > interval.x then
    interval.x := s3.MinX;
  if s4.MinX > interval.x then
    interval.x := s4.MinX;
  // находим интервал обработки
  interval.y := s1.MaxX;
  if s2.MaxX < interval.y then
    interval.y := s2.MaxX;
  if s3.MaxX > interval.y then
    interval.y := s3.MaxX;
  if s4.MaxX > interval.y then
    interval.y := s4.MaxX;

  s1 := GetIntervalSignal(interval, s1);
  s2 := GetIntervalSignal(interval, s2);
  s3 := GetIntervalSignal(interval, s3);
  s4 := GetIntervalSignal(interval, s4);
  if s1.DeltaX < DeltaX then
  begin
    s1 := Resample(s1, maxFS);
  end;
  if s2.DeltaX < DeltaX then
  begin
    s2 := Resample(s2, maxFS);
  end;
  if s3.DeltaX < DeltaX then
  begin
    s3 := Resample(s3, maxFS);
  end;
  if s4.DeltaX < DeltaX then
  begin
    s4 := Resample(s4, maxFS);
  end;

  start := s.IndexOf(interval.x);
  stop := s.IndexOf(interval.y);
  r1 := s.Clone(start, stop - start) as iwpSignal;
  r1.sname := 'Vt_' + sname;
  m.resVt := r1;
  r2 := s.Clone(start, stop - start) as iwpSignal;
  r2.sname := 'Gt_' + sname;
  m.resGt := r2;
  r3 := s.Clone(start, stop - start) as iwpSignal;
  r3.sname := 'M_' + sname;

  JournalLB.AddItem('Расчет матрицы', nil);
  str := 's1: ' + s1.sname + ';' + 's2: ' + s2.sname + ';' + 's3: ' +
    s3.sname + ';' + 's4: ' + s4.sname;
  JournalLB.AddItem(str, nil);
  for i := 0 to r1.size - 1 do
  begin
    if i = 0 then
    begin
      v1 := s1.GetX(i);
      v2 := s2.GetX(i);
      v3 := s3.GetX(i);
      v4 := s4.GetX(i);
      min := v1;
      max := v1;
      if v2 > max then
        max := v2;
      if v3 > max then
        max := v3;
      if v4 > max then
        max := v4;
      if v2 < min then
        min := v2;
      if v3 < min then
        min := v3;
      if v4 < min then
        min := v4;
      JournalLB.AddItem('Максимальная несинхронность: ' + formatstrNoE
          (max - min, c_digits), nil);
    end;
    v1 := s1.GetY(i);
    v2 := s2.GetY(i);
    v3 := s3.GetY(i);
    v4 := s4.GetY(i);
    /// Логирование значения
    if v_Log then
    begin
      // if i = m_logindex then
      if i = 2593 then
      begin
        JournalLB.AddItem('Индекс отсчета: ' + inttostr(m_logindex), nil);
        str := formatstrNoE(v1, 4) + '; ' + formatstrNoE(v2, 4)
          + '; ' + formatstrNoE(v3, 4) + '; ' + formatstrNoE(v4, 4);
        JournalLB.AddItem(str, nil);
        str := 'Z=' + formatstrNoE(p_g[0, 0], 4) + '; ' + formatstrNoE
          (p_g[1, 0], 4) + '; ' + formatstrNoE(p_g[2, 0], 4)
          + '; ' + formatstrNoE(p_g[3, 0], 4);
        JournalLB.AddItem(str, nil);
        str := 'G=' + formatstrNoE(p_g[0, 1], 4) + '; ' + formatstrNoE
          (p_g[1, 1], 4) + '; ' + formatstrNoE(p_g[2, 1], 4)
          + '; ' + formatstrNoE(p_g[3, 1], 4);
        JournalLB.AddItem(str, nil);
      end;
    end;
    V := p_g[0, 0] * v1 + p_g[1, 0] * v2 + p_g[2, 0] * v3 + p_g[3, 0] * v4;
    r1.SetY(i, V);
    V := p_g[0, 1] * v1 + p_g[1, 1] * v2 + p_g[2, 1] * v3 + p_g[3, 1] * v4;
    r2.SetY(i, V);
    V := p_g[0, 2] * v1 + p_g[1, 2] * v2 + p_g[2, 2] * v3 + p_g[3, 2] * v4;
    r3.SetY(i, V);
  end;
  folder := srcpath + '/RZDForce/';
  m.n1 := WP.Link(folder, r1.sname, r1) as iwpnode;
  m.lastn1 := (m.n1.Name);
  m.n2 := WP.Link(folder, r2.sname, r2) as iwpnode;
  m.lastn2 := (m.n2.Name);
  m.n3 := WP.Link(folder, r3.sname, r3) as iwpnode;
  m.lastn3 := (m.n3.Name);
end;

function TRZDFrm.buildG: d2array;
var
  Et_e, ident, Et: d2array;
begin
  Et := transpondmatrix(E);
  MultMatrix(Et, E, Et_e);
  Et_e := Invers(Et_e);
  MultMatrix(Et_e, Et, G);
  result := G;
  ShowG(G);
end;

procedure TRZDFrm.SelectIntervalCursorBtnClick(Sender: TObject);
var
  i: integer;
  G: tgraphstruct;
  p: point2d;
  fr: TRZDTareFrame;
begin
  for i := 0 to 3 do
  begin
    G := graph[i];
    p := GetGraphCursorX(G.hpage, G.hgraph);
    case i of
      0:
        fr := VC_Frame;
      1:
        fr := H_Frame;
      2:
        fr := Hout_Frame;
      3:
        fr := Hin_Frame;
    end;
    fr.T1FE.FloatNum := p.x;
    fr.T2FE.FloatNum := p.y;
  end;
end;

procedure TRZDFrm.SelectIntervalGraphBtnClick(Sender: TObject);
var
  i: integer;
  G: tgraphstruct;
  p: point2d;
  fr: TRZDTareFrame;
begin
  for i := 0 to 3 do
  begin
    G := graph[i];
    if G.hgraph = 0 then
    begin
      p.x := 0;
      p.y := 10;
    end
    else
    begin
      p := GetGraphX(G.hgraph);
      case i of
        0:
          fr := VC_Frame;
        1:
          fr := H_Frame;
        2:
          fr := Hout_Frame;
        3:
          fr := Hin_Frame;
      end;
    end;
    fr.T1FE.FloatNum := p.x;
    fr.T2FE.FloatNum := p.y;
  end;
end;

procedure TRZDFrm.ShowG(p_g: d2array);
begin
  G11.FloatNum := p_g[0, 0];
  G12.FloatNum := p_g[0, 1];
  G13.FloatNum := p_g[0, 2];
  G21.FloatNum := p_g[1, 0];
  G22.FloatNum := p_g[1, 1];
  G23.FloatNum := p_g[1, 2];
  G31.FloatNum := p_g[2, 0];
  G32.FloatNum := p_g[2, 1];
  G33.FloatNum := p_g[2, 2];
  G41.FloatNum := p_g[3, 0];
  G42.FloatNum := p_g[3, 1];
  G43.FloatNum := p_g[3, 2];
end;

function TRZDFrm.getformmatrix: d2array;
begin
  setlength(result, 4, 3);
  result[0, 0] := G11.FloatNum;
  result[0, 1] := G12.FloatNum;
  result[0, 2] := G13.FloatNum;
  result[1, 0] := G21.FloatNum;
  result[1, 1] := G22.FloatNum;
  result[1, 2] := G23.FloatNum;
  result[2, 0] := G31.FloatNum;
  result[2, 1] := G32.FloatNum;
  result[2, 2] := G33.FloatNum;
  result[3, 0] := G41.FloatNum;
  result[3, 1] := G42.FloatNum;
  result[3, 2] := G43.FloatNum;
end;

procedure TRZDFrm.addEiJournal(p_name: string; E: array of TEi; enorm: TVec4);
begin
  JournalLB.AddItem(p_name + ': ' + formatstrNoE(E[0].ei,
      c_digits) + '; ' + formatstrNoE(E[1].ei, c_digits) + '; ' + formatstrNoE
      (E[2].ei, c_digits) + '; ' + formatstrNoE(E[3].ei, c_digits), nil);
  JournalLB.AddItem('Fmax: ' + formatstrNoE(E[0].fmax, c_digits), nil);
  JournalLB.AddItem(p_name + 'norm: ' + formatstrNoE(enorm.i1,
      c_digits) + '; ' + formatstrNoE(enorm.i2,
      c_digits) + '; ' + formatstrNoE(enorm.i3, c_digits) + '; ' + formatstrNoE
      (enorm.i4, c_digits), nil);
end;

procedure TRZDFrm.LinkEiSignals(E: array of TEi);
var
  graph: tgraphstruct;
  i, color: integer;
  s: iwpSignal;
  str: string;
begin
  // графика
  graph.hpage := 0;
  if LinkEvalWP.Checked then
  begin
    for i := 0 to 3 do
    begin
      E[i].nCloud := iwpnode(WP.Link('Signals/MNK/', E[i].cloud.sname,
          E[i].cloud));
      E[i].nPoly := iwpnode(WP.Link('Signals/MNK/', E[i].poly.sname,
          E[i].poly));
      // строим графику
      if graph.hpage = 0 then
      begin
        graph := createline(iwpSignal(E[i].nCloud.Reference));
        IWPGraphs(WP.GraphAPI).SetPageDim(graph.hpage, PAGE_DM_TABLE, 2, 2);
      end
      else
      begin
        graph := createline(iwpSignal(E[i].nCloud.Reference), graph.hpage);
      end;
      IWPGraphs(WP.GraphAPI).SetLineOpt(graph.hline, LNOPT_ONLYPOINTS,
        LNOPT_ONLYPOINTS, 0, $00D2D5);
      graph := createline(E[i].poly, graph.hgraph, graph.haxis);
      // цвет тренда
      color := clred;
      IWPGraphs(WP.GraphAPI).SetLineOpt(graph.hline, LNOPT_color + LNOPT_WIDTH,
        LNOPT_color + LNOPT_WIDTH, 3, color);
      s := iwpSignal(E[i].nCloud.Reference);
      // str:=s.comment;
      str := E[i].str_sname;
      IWPGraphs(WP.GraphAPI).AddComment(graph.hgraph, str, 45, 5, 15, 5);
    end;
    WP.Refresh;
  end;
end;

function TRZDFrm.BuildGistogram(s: iwpSignal; dx: double; dxN: integer;
  lvl, noise: double; start, shift: integer; folder, gistname: string;
  usep2List: boolean; var p2list: cP2dList; gtForce: boolean): iwpSignal;
var
  // полный список экстремумов
  res,
  // прореженные импульсы с учетом пропуска осей
  res1: cP2dList;
  p2, p: point2d;
  p2dptr: Ppoint2d;
  findtrg: boolean;
  i, lshift, j, ind, count: integer;
  // экстремум на участке
  localmax, localmax_x, V, sum, min, max, SIGshift: double;
begin
  res1 := cP2dList.create;
  res1.sortByY;

  if not gtForce then
  begin
    if not usep2List then
    begin
      if v_Log then
      begin
        JournalLB.AddItem('Точки на гистограмму Vt', nil);
        JournalLB.AddItem('lvl=' + formatstrNoE(lvl,
            c_digits) + ' noise=' + formatstrNoE(noise, c_digits), nil);
      end;
      res := cP2dList.create;
      if Abs(s.MaxY) < Abs(s.MinY) then
        s := Multiply(s, -1);

      findtrg := false;
      localmax := s.MinY;
      for i := 0 to s.size - 1 do
      begin
        V := s.GetY(i);
        if V > lvl then
        begin
          findtrg := true;
          if V > localmax then
          begin
            localmax := V;
            localmax_x := s.GetX(i);
          end;
        end
        else
        begin
          // проверяем вышли мы за уровень гистерезиса или нет
          if findtrg then
          begin
            if V + noise > lvl then
            begin

            end
            else
            begin
              p2.x := localmax_x;
              p2.y := localmax;
              localmax := s.MinY;
              if v_Log then
              begin
                JournalLB.AddItem(floattostr(p2.x) + ' ' + floattostr(p2.y),
                  nil);
              end;
              res.Add(p2);
              findtrg := false;
            end;
          end;
        end;
      end;
    end
    else
    begin
      res := p2list;
    end;
  end
  else
  // горизонтальная сила
  begin
    res := p2list;
    for i := 0 to res.count - 1 do
    begin
      p2dptr := res.getPtr(i);
      ind := s.IndexOf(p2dptr.x);
      if v_GistAbsValueForGt then
      begin
        p2dptr.y := Abs(s.GetY(ind))
      end
      else
      begin
        p2dptr.y := s.GetY(ind);
      end;
    end;
  end;
  // вычисляем минимальное значение импульса сигнала
  min := Abs(s.MaxY);
  max := -1;
  if v_Log and gtForce then
  begin
    JournalLB.AddItem('Точки на гистограмму Gt', nil);
  end;
  for j := start to res.count - 1 do
  begin
    if (lshift = shift) or (j = start) then
    begin
      p2 := res.getP(j);
      if p2.y > max then
        max := p2.y;
      if p2.y < min then
        min := p2.y;
      lshift := 0;
      if v_Log then
      begin
        JournalLB.AddItem(floattostr(p2.x) + ' ' + floattostr(p2.y), nil);
      end;
    end
    else
    begin
      inc(lshift);
    end;
  end;
  if not dXCB.Checked then
  begin
    dx := (max - min) / dxN;
  end;

  result := WP.CreateSignal(VT_R4) as iwpSignal;
  result.sname := gistname;
  V := (s.MaxY - s.MinY) / dx;
  if ROUND(V) < V then
    V := ROUND(V) + 1
  else
    V := ROUND(V);
  result.size := ROUND(V) * 2;
  result.DeltaX := dx;
  result.SetProperty('Gist', '1');
  SIGshift := ROUND(min / dx) * dx;
  result.StartX := SIGshift;

  lshift := 0;
  sum := 0;
  count := 0;
  // сдвижка оси x для выравнивания минимума в кратную гистограмму
  V := dx * ROUND(min / dx);
  result.StartX := result.StartX - V;
  for j := start to res.count - 1 do
  begin
    if (lshift = shift) or (j = start) then
    begin
      p2 := res.getP(j);
      res1.Add(p2);
      sum := p2.y + sum;
      ind := ROUND((p2.y - result.StartX) / dx);
      V := result.GetY(ind);
      result.SetY(ind, V + 1);
      lshift := 0;
      inc(count);
    end
    else
    begin
      inc(lshift);
    end;
  end;
  if not v_GistUniformAxis then
  begin
    SIGshift := max - dx * ROUND(max / dx) - dx / 2;
    result.StartX := result.StartX + SIGshift;
  end;
  result.SetProperty('GistN', inttostr(count));
  result.SetProperty('MO', floattostr(sum / res.count));
  result.SetProperty('GistMax', floattostr(max));
  result.SetProperty('GistMin', floattostr(min));
  // нормировка сигнала
  for i := 0 to result.size - 1 do
  begin
    V := result.GetY(i);
    if V <> 0 then
    begin
      // result.SetY(i, V / (res.count * dx));
      result.SetY(i, V / (count * dx));
    end;
  end;
  // вычисляем доверительный интервал
  // цена деления одного импульса
  // v:=1/res.Count;
  // импульс на котором мы еще меньше доверительного интервала
  V := 1 / res1.count;
  j := trunc(PAlfaEdit.FloatNum * res1.count) - 1;
  if j > -1 then
  begin
    p := res1.getP(j);
    p.x := p.y;
    p.y := V * (j + 1);
    if j + 1 <= res1.count - 1 then
    begin
      p2 := res1.getP(j + 1);
      p2.x := p2.y;
      p2.y := V * (j + 2);
      V := EvalLineX(PAlfaEdit.FloatNum, p, p2);
    end
    else
    begin
      p2 := res1.getP(j);
      V := p2.y;
    end;
    result.SetProperty('Palfa', floattostr(V));
  end;
  WP.Link(folder, result.sname, result);
  // res.Destroy;
  p2list := res;
  res1.Destroy;
end;

function TRZDFrm.GetAbsRelFmax(fmax, rel, p_abs: double): double;
var
  V: double;
begin
  V := Abs(fmax * rel);
  if V < p_abs then
  begin
    result := p_abs;
  end
  else
  begin
    result := V;
  end;
end;

function getmax(v1, v2: double): double;
begin
  result := v1;
  if v2 > v1 then
    result := v2;
end;

// base - тарировочная сила, s1 - расчитанная
function TRZDFrm.BuildCompare(s1, base: iwpSignal; fmax, rel: double;
  resfolder: string; var res1, res2: iwpSignal): iwpSignal;
var
  // максимальная частота опроса среди сигналов
  DeltaX, maxFS, min, max, lmax, V: double;
  interval: point2d;
  // датчик с максимальной частотой дискретизации
  i, start, stop: integer;
  res: iwpSignal;
begin
  maxFS := s1.DeltaX;
  if base.DeltaX < maxFS then
  begin
    maxFS := base.DeltaX;
  end;

  DeltaX := maxFS;
  maxFS := 1 / maxFS;

  if s1.DeltaX > DeltaX then
  begin
    s1 := Resample(s1, maxFS);
  end;
  if base.DeltaX > DeltaX then
  begin
    base := Resample(base, maxFS);
  end;

  // находим интервал обработки
  interval.x := s1.MinX;
  if base.MinX > interval.x then
    interval.x := base.MinX;
  // находим интервал обработки
  interval.y := s1.MaxX;
  if base.MaxX < interval.y then
    interval.y := base.MaxX;
  s1 := GetIntervalSignal(interval, s1);
  base := GetIntervalSignal(interval, base);

  start := s1.IndexOf(interval.x);
  stop := s1.IndexOf(interval.y);
  V := base.MaxY - base.MinY;
  max := Abs(fmax);

  res := s1.Clone(start, stop - start) as iwpSignal;
  res.sname := s1.sname + '_' + base.sname + '_compare';

  res1 := s1.Clone(start, stop - start) as iwpSignal;
  res1.sname := s1.sname + '_Delta';

  res2 := s1.Clone(start, stop - start) as iwpSignal;
  res2.sname := s1.sname + '_AbsTol';

  for i := 0 to stop - 1 do
  begin
    V := Abs(s1.GetY(i) - base.GetY(i));
    if max < Abs(base.GetY(i)) * rel then
      lmax := Abs(base.GetY(i)) * rel
    else
      lmax := max;
    // V := V / lmax;
    V := V / getmax(Abs(base.GetY(i)), v_MaxF);
    res.SetY(i, V);
    res1.SetY(i, Abs(s1.GetY(i) - base.GetY(i)));
    res2.SetY(i, lmax);
  end;
  WP.Link(resfolder, res.sname, res);
  WP.Link(resfolder, res1.sname, res1);
  WP.Link(resfolder, res2.sname, res2);
  result := res;
end;

function TRZDFrm.GetCalibrFolder: string;
var
  L: integer;
  str: string;
begin
  L := length(BaseFolderEdit.Text);
  str := BaseFolderEdit.Text;
  if BaseFolderEdit.Text[L] = '\' then
    setlength(str, L - 1);
  result := str + '\Calibr';
end;

procedure TRZDFrm.ReadRegionFolders;
var
  list: tstringlist;
  i: integer;
  laststr: string;
begin
  list := tstringlist.create;
  // сканируемый каталог, маска, список результатов
  FindFolders(GetCalibrFolder, '*' + m_regionPref + '*', list, 1);

  laststr := RegionCB.Text;
  RegionCB.clear;
  for i := 0 to list.count - 1 do
  begin
    RegionCB.AddItem(extractfilename(list.Strings[i]), nil);
  end;
  if RegionCB.Items.count > 0 then
  begin
    RegionCB.ItemIndex := 0;
  end;
  for i := 0 to RegionCB.Items.count - 1 do
  begin
    if RegionCB.Items[i] = laststr then
    begin
      RegionCB.ItemIndex := i;
      break;
    end;
  end;
  RegionCBChange(nil);
  list.Destroy;
end;

procedure TRZDFrm.ReadSegments(RegionPath: string);
var
  list: tstringlist;
  i: integer;
  sectiontext: string;
begin
  list := tstringlist.create;
  // сканируемый каталог, маска, список результатов
  FindFolders(RegionPath, '*' + m_sectionPref + '*', list, 1);
  sectiontext := sectionCB.Text;
  sectionCB.clear;
  for i := 0 to list.count - 1 do
  begin
    sectionCB.AddItem(extractfilename(list.Strings[i]), nil);
  end;
  for i := 0 to sectionCB.Items.count - 1 do
  begin
    if i = 0 then
      sectionCB.ItemIndex := 0;
    if sectionCB.Items[i] = sectiontext then
    begin
      sectionCB.ItemIndex := i;
      break;
    end;
  end;
  GetNumFromSectionCB;
  sectionCBChange(nil);
  list.Destroy;
end;

Procedure TRZDFrm.GetNumFromSectionCB;
var
  str: string;
begin
  str := getendnum(sectionCB.Text);
  if isDigit(str) then
  begin
    CutSE.Value := strtoint(str);
  end;
end;

procedure SetCb(cb: TComboBox; str: string);
var
  i: integer;
begin
  for i := 0 to cb.Items.count - 1 do
  begin
    if cb.Items.Strings[i] = str then
    begin
      cb.ItemIndex := i;
      break;
    end;
  end;
end;

// заполняем пути к сигналам калибровки
procedure TRZDFrm.ReadTests(segmentpath: string);
var
  list: tstringlist;
  i: integer;
  vc_str, h_str, hin_str, hout_str: string;
begin
  list := tstringlist.create;
  // сканируемый каталог, маска, список результатов
  FindFileext('*.mera', segmentpath, 2, list);
  vc_str := VC_Frame.Path.Text;
  VC_Frame.Path.clear;
  h_str := H_Frame.Path.Text;
  H_Frame.Path.clear;
  hin_str := Hin_Frame.Path.Text;
  Hin_Frame.Path.clear;
  hout_str := Hout_Frame.Path.Text;
  Hout_Frame.Path.clear;
  for i := 0 to list.count - 1 do
  begin
    if useSignalPrefix.Checked then
    begin
      if CheckPosSubstr(m_VCPref, list.Strings[i]) then
        VC_Frame.Path.AddItem(list.Strings[i], nil);
      if CheckPosSubstr(m_H_Pref, list.Strings[i]) then
        H_Frame.Path.AddItem(list.Strings[i], nil);
      if CheckPosSubstr(m_Hin_Pref, list.Strings[i]) then
        Hin_Frame.Path.AddItem(list.Strings[i], nil);
      if CheckPosSubstr(m_Hout_Pref, list.Strings[i]) then
        Hout_Frame.Path.AddItem(list.Strings[i], nil);
    end
    else
    begin
      VC_Frame.Path.AddItem(list.Strings[i], nil);
      H_Frame.Path.AddItem(list.Strings[i], nil);
      Hin_Frame.Path.AddItem(list.Strings[i], nil);
      Hout_Frame.Path.AddItem(list.Strings[i], nil);
    end;
  end;
  if VC_Frame.Path.Items.count > 0 then
    VC_Frame.Path.ItemIndex := 0;
  if H_Frame.Path.Items.count > 0 then
    H_Frame.Path.ItemIndex := 0;
  if Hin_Frame.Path.Items.count > 0 then
    Hin_Frame.Path.ItemIndex := 0;
  if Hout_Frame.Path.Items.count > 0 then
    Hout_Frame.Path.ItemIndex := 0;

  SetCb(VC_Frame.Path, vc_str);
  SetCb(H_Frame.Path, h_str);
  SetCb(Hin_Frame.Path, hin_str);
  SetCb(Hout_Frame.Path, hout_str);

  list.Destroy;
  FillVCCB;
  FillHCB;
  FillHoutCB;
  FillHinCB;

  UpdateIPortion;
  // обновляем статус кнопки Загрузить/Создать. Если прописан новый замер то src сбрасывается
  VC_FramePathChange(nil);
  H_FramePathChange(nil);
  Hin_FramePathChange(nil);
  Hout_FramePathChange(nil);
  CheckSrc;
end;

function GetRegPath(base: string; reg: string): string;
begin
  result := reg;
  if pos('\', result) < 1 then
  begin
    if base[length(base)] = '\' then
      result := base + result
    else
      result := base + '\' + result;
  end;
end;

function TRZDFrm.GetregionPath: string;
begin
  result := GetRegPath(BaseFolderEdit.Text, RegionCB.Text);
end;

procedure TRZDFrm.RegionCBChange(Sender: TObject);
var
  num, Path: string;
begin
  Path := GetRegPath(GetCalibrFolder, RegionCB.Text);
  ReadSegments(Path);
  num := getendnum(RegionCB.Text);
  if isDigit(num) then
  begin
    RegionSE.Value := strtoint(num);
  end;
end;

procedure TRZDFrm.RegionSEChange(Sender: TObject);
var
  str, str1, path: string;
  b: boolean;
  i, operation, num: integer;
  e:TNotifyEvent;
begin
  str := m_regionPref + '_' + inttostr(RegionSE.Value);
  str := lowercase(str);
  str1:=getendnum(RegionCB.text);
  operation:=0;
  if isValue(str1) then
  begin
    if strtoIntExt(str1)>RegionSE.Value then
    begin
      // уменьшаем счетчик
      operation:=1;
    end
    else
    begin
      // увеличиваем счетчик
      operation:=2;
    end;
  end;
  for i := 0 to RegionCB.Items.count - 1 do
  begin
    str1 := lowercase(RegionCB.Items[i]);
    if CheckPosSubstr(m_regionPref, str1) then
    begin
      str1 := getendnum(str1);
      if strtoint(str1) = RegionSE.Value then
      begin
        RegionCB.ItemIndex := i;
        break;
        b := true;
      end;
    end;
  end;
  if b=false then
  begin
    e:=RegionSE.OnChange;
    RegionSE.OnChange:=nil;
    if operation=1 then
    begin
      if regionCB.ItemIndex>0 then
      begin
        regionCB.ItemIndex:=regionCB.ItemIndex-1;
      end;
      str1:=getendnum(regionCB.text);
      if isvalue(str1) then
      begin
        num:=strtoint(str1);
        RegionSE.Value:=num;
      end;
    end;
    if operation=2 then
    begin
      if regionCB.ItemIndex<(regionCB.Items.Count-1) then
      begin
        regionCB.ItemIndex:=regionCB.ItemIndex+1;
      end;
      str1:=getendnum(regionCB.text);
      if isvalue(str1) then
      begin
        num:=strtoint(str1);
        RegionSE.Value:=num;
      end;
    end;
    Path := GetRegPath(GetCalibrFolder, RegionCB.Text);
    ReadSegments(Path);
    RegionSE.OnChange:=e;
    // предотвращаем   RegionCBChange(nil);
    exit;
  end;
  // синхронизация спинбатона с текстом regionCB (главный регионCB)
  RegionCBChange(nil);
end;

procedure TRZDFrm.ReportCBClick(Sender: TObject);
begin
  if ReportCB.Checked then
  begin
    OpenReportCB.enabled := true;
  end
  else
  begin
    OpenReportCB.enabled := false;
    OpenReportCB.Checked := false;
  end;
end;

procedure TRZDFrm.sectionCBChange(Sender: TObject);
var
  num, Path, region: string;
begin
  Path := sectionCB.Text;
  if pos('\', Path) < 1 then
  begin
    region := GetRegPath(GetCalibrFolder, RegionCB.Text) + '\';
  end;
  if ChangeTestByCutCB.Checked then
  begin
    region := region + Path;
    ReadTests(region);
  end
  else
  begin
    ReadTests(region);
  end;
  num := getendnum(sectionCB.Text);
  if isDigit(num) then
  begin
    CutSE.Value := strtoint(num);
  end;
end;

procedure TRZDFrm.TestPathBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute(0) then
  begin
    TestPath.Text := OpenDialog1.filename;
  end;
end;

procedure TRZDFrm.TestPathChange(Sender: TObject);
begin
  FillMatrixSensorsCB;
  ShowMatrixList;
  // str:=RelativePathToAbsolute(BaseFolderEdit.Text,ExportMatrixPath.Text);
  TestPath.Hint := gettestpath;
  CheckFolderComponent(TestPath, TestPath.Hint, false);
end;

procedure TRZDFrm.TestsFolderEChange(Sender: TObject);
begin
  UpdateTestsFolder;
end;

procedure TRZDFrm.Timer1Timer(Sender: TObject);
begin
  Timer1.enabled := false;
  UpdateDB(f_updFolder);
end;

function TRZDFrm.gettestpath: string;
begin
  result := RelativePathToAbsolute(GetTestsFolder, TestPath.Text);
end;

procedure TRZDFrm.TrendPortionFEChange(Sender: TObject);
begin
  UpdateIPortion;
end;

procedure TRZDFrm.TrendPortionIEChange(Sender: TObject);
begin
  UpdateFPortion;
end;

procedure TRZDFrm.useSignalPrefixClick(Sender: TObject);
begin
  CheckBaseFolder;
end;

procedure TRZDFrm.createEvents;
begin
  m_wpMng.Events.AddEvent('RZD_Addline', E_OnAddLine, OnAddLine);
  m_wpMng.Events.AddEvent('RZD_Addline', E_OnDestroySignal, OnDestroySignal);
  m_wpMng.Events.AddEvent('RZD_DestroySrc', E_OnDestroySrc, OnDestroySrc);

end;

procedure TRZDFrm.destroyEvents;
begin
  m_wpMng.Events.removeEvent(OnAddLine, E_OnAddLine);
  m_wpMng.Events.removeEvent(OnDestroySignal, E_OnDestroySignal);
end;

procedure TRZDFrm.DrawGraphBtnClick(Sender: TObject);
var
  i: integer;
  fr: TRZDTareFrame;
  p: point2d;
  page: integer;
  src: csrc;
  str: array [0 .. 3] of string;
begin
  page := 0;
  if not CheckSrc then
    exit;
  for i := 0 to 3 do
  begin
    case i of
      0:
        begin
          fr := VC_Frame;
          src := vc_src;
          str[i] := 'Верт. центр. нагружение';
        end;
      1:
        begin
          fr := H_Frame;
          src := h_src;
          str[i] := 'Верт. с смещением по гор-ли';
        end;
      2:
        begin
          fr := Hout_Frame;
          src := hout_src;
          str[i] := 'Гор. с смещением наружу';
        end;
      3:
        begin
          fr := Hin_Frame;
          src := hin_src;
          str[i] := 'Гор. с смещением внутрь';
        end;
    end;
    graph[i] := ShowTimeGraphs(page, VC_Frame, src, str[i]);

    page := graph[i].hpage;
    p := fr.GetInterval;
    if i = 0 then
      IWPGraphs(WP.GraphAPI).ShowCursor(graph[0].hpage, 2);
    IWPGraphs(WP.GraphAPI).SetXCursorPos(graph[i].hgraph, p.x, false);
    IWPGraphs(WP.GraphAPI).SetXCursorPos(graph[i].hgraph, p.y, true);
  end;
  IWPGraphs(WP.GraphAPI).SetPageDim(graph[0].hpage, PAGE_DM_TABLE, 2, 2);
  for i := 0 to 3 do
  begin
    IWPGraphs(WP.GraphAPI).AddComment(graph[i].hgraph, str[i], 15, 10, 25, 5);
  end;
  WP.Refresh;
end;

procedure TRZDFrm.dXCBClick(Sender: TObject);
begin
  if dXCB.Checked then
  begin
    dXCB.Caption := 'dX';
    GistNIE.Visible := false;
    GistDxFE.Visible := true;
  end
  else
  begin
    dXCB.Caption := 'N (число точек)';
    GistNIE.Visible := true;
    GistDxFE.Visible := false;
  end;
end;

procedure formatgist(hline: integer);
begin
  IWPGraphs(WP.GraphAPI).SetLineOpt(hline, LNOPT_HIST, LNOPT_HIST, 0, 0);
  IWPGraphs(WP.GraphAPI).SetLineOpt(hline, LNOPT_LINE2BASE, LNOPT_LINE2BASE, 0,
    0);
  // setGistXScale(hline);
end;

procedure TRZDFrm.OnAddLine(Sender: TObject);
var
  s: iwpSignal;
  str: string;
  V: double;
begin
  if pos('cloud', m_wpMng.m_str) > 0 then
  begin
    IWPGraphs(WP.GraphAPI).SetLineOpt(m_wpMng.m_hline, LNOPT_ONLYPOINTS,
      LNOPT_ONLYPOINTS, 0, $00D2D5);
    exit;
  end;
  if m_wpMng.m_hline <> -1 then
  begin
    s := IWPGraphs(WP.GraphAPI).GetSignal(m_wpMng.m_hline) as iwpSignal;
    if s = nil then
      exit;

    V := 0;
    str := s.GetProperty('Gist');
    if str <> '' then
      V := strtofloatext(str);
    if V = 1 then
    begin
      formatgist(m_wpMng.m_hline);
    end;
  end;
end;

procedure TRZDFrm.OnDestroySignal(Sender: TObject);
begin

end;

procedure TRZDFrm.OnDestroySrc(Sender: TObject);
begin
  if Sender = vc_src then
  begin
    vc_src := nil;
  end;
  if Sender = h_src then
  begin
    h_src := nil;
  end;
  if Sender = hout_src then
  begin
    hout_src := nil;
  end;
  if Sender = hin_src then
  begin
    hin_src := nil;
  end;
  if Sender = m_src then
  begin
    m_src := nil;
  end;
  CheckSrc;
end;

function TRZDFrm.maxFS(s1, s2, s3, s4, vt, gt, mera: string): double;
var
  ifile: tinifile;
  f, fmax: double;
begin
  ifile := tinifile.create(mera);
  f := readFloatFromIni(ifile, s1, 'Freq');
  fmax := f;
  f := readFloatFromIni(ifile, s2, 'Freq');
  if f > fmax then
    fmax := f;
  f := readFloatFromIni(ifile, s3, 'Freq');
  if f > fmax then
    fmax := f;
  f := readFloatFromIni(ifile, s4, 'Freq');
  if f > fmax then
    fmax := f;
  f := readFloatFromIni(ifile, vt, 'Freq');
  if f > fmax then
    fmax := f;
  f := readFloatFromIni(ifile, gt, 'Freq');
  if f > fmax then
    fmax := f;
  ifile.Destroy;
  result := fmax;
end;

procedure TRZDFrm.NullBtnClick(Sender: TObject);
var
  i: integer;
  G: tgraphstruct;
  p: point2d;
  fr: TRZDTareFrame;
begin
  for i := 0 to 3 do
  begin
    G := graph[i];
    p := GetGraphCursorX(G.hpage, G.hgraph);
    case i of
      0:
        fr := VC_Frame;
      1:
        fr := H_Frame;
      2:
        fr := Hout_Frame;
      3:
        fr := Hin_Frame;
    end;
    fr.NullFE1.FloatNum := p.x;
    fr.NullFE2.FloatNum := p.y;
  end;
end;

procedure TRZDFrm.UpdateIPortion;
var
  fs: double;
  frame: TRZDTareFrame;
begin
  case TareFramePageControl.ActivePageIndex of
    0:
      frame := VC_Frame;
    1:
      frame := H_Frame;
    2:
      frame := Hout_Frame;
    3:
      frame := Hin_Frame;
  end;
  fs := maxFS(frame.S1Cbox.Text, frame.S2Cbox.Text, frame.S3Cbox.Text,
    frame.S4Cbox.Text, frame.VFCbox.Text, frame.HFCbox.Text, frame.Path.Text);
  if fs <> 0 then
    TrendPortionIE.intnum := ROUND(TrendPortionFE.FloatNum * fs);
end;

procedure TRZDFrm.UpdatePathBtnClick(Sender: TObject);
var
  str, fld: string;
  i: integer;
begin
  if DirectoryExists(BaseFolderEdit.Text) then
  begin
    str := BaseFolderEdit.Text;
    i := length(BaseFolderEdit.Text);
    if BaseFolderEdit.Text[i] <> '\' then
      str := BaseFolderEdit.Text + '\'
    else
      str := BaseFolderEdit.Text;
    fld := str + 'Calibr';
    if not DirectoryExists(fld) then
    begin
      ForceDirectories(fld);
    end;
    fld := str + 'Tests';
    if not DirectoryExists(fld) then
    begin
      ForceDirectories(fld);
    end;
    fld := str + 'RZDmatrix';
    if not DirectoryExists(fld) then
    begin
      ForceDirectories(fld);
    end;
  end;

  BaseFolderEditChange(nil);
  f_needUpdateDB := true;
  // UpdateDB(f_updFolder);
  UpdateDB;
end;

procedure TRZDFrm.UpdateFPortion;
var
  fs: double;
  frame: TRZDTareFrame;
begin
  case TareFramePageControl.ActivePageIndex of
    0:
      frame := VC_Frame;
    1:
      frame := H_Frame;
    2:
      frame := Hout_Frame;
    3:
      frame := Hin_Frame;
  end;
  fs := maxFS(frame.S1Cbox.Text, frame.S2Cbox.Text, frame.S3Cbox.Text,
    frame.S4Cbox.Text, frame.VFCbox.Text, frame.HFCbox.Text, frame.Path.Text);
  if fs <> 0 then
    TrendPortionFE.FloatNum := TrendPortionIE.intnum / fs;
end;

procedure TRZDFrm.ExpMatrixBtnClick(Sender: TObject);
var
  str, dir: string;
  i: integer;
  m: TRZDMatrix;
begin
  str := RelativePathToAbsolute(BaseFolderEdit.Text, ExportMatrixPath.Text);
  dir := extractfiledir(str);
  str := dir + '\' + extractfilename(str);
  if not DirectoryExists(dir) then
    ForceDirectories(dir);
  if DelMatrixOnExpCB.Checked then
  begin
    if fileexists(str) then
    begin
      DeleteFile(str);
    end;
  end;
  for i := 0 to MatrixList.count - 1 do
  BEGIN
    m := MatrixList.Items[i];
    ExportMatrix(m, str);
  END;
end;

procedure TRZDFrm.ImpMatrixBtnClick(Sender: TObject);
var
  str, dir, pref, V: string;

begin
  str := RelativePathToAbsolute(BaseFolderEdit.Text, ExportMatrixPath.Text);
  dir := extractfiledir(str);
  str := dir + '\' + extractfilename(str);
  ImpMatrix(str);
end;

procedure TRZDFrm.ImpMatrix(str: string);
var
  dir, pref, V: string;
  ini: tinifile;
  sections: tstringlist;
  i, j, n, k: integer;
  m: TRZDMatrix;
begin
  if not fileexists(str) then
    exit;
  // удаляем прошлые матрицы
  ClearMList;
  sections := tstringlist.create;
  ini := tinifile.create(str);
  ini.ReadSections(sections);
  for i := 0 to sections.count - 1 do
  begin
    m := TRZDMatrix.create;
    dir := sections.Strings[i];
    for j := 0 to 3 do
    begin
      case j of
        0:
          pref := 'vc';
        1:
          pref := 'h';
        2:
          pref := 'hout';
        3:
          pref := 'hin';
      end;
      m.sensors[j].mf := ini.readString(dir, 'File_' + pref, '');
      m.sensors[j].vt := ini.readString(dir, 'Vt_' + pref, '');
      m.sensors[j].gt := ini.readString(dir, 'Gt_' + pref, '');
      m.sensors[j].s1 := ini.readString(dir, 'S1_' + pref, '');
      m.sensors[j].s2 := ini.readString(dir, 'S2_' + pref, '');
      m.sensors[j].s3 := ini.readString(dir, 'S3_' + pref, '');
      m.sensors[j].s4 := ini.readString(dir, 'S4_' + pref, '');
      m.sensors[j].t1t2.x := IniReadFloatEx(ini, dir, 't1_' + pref, 0);
      m.sensors[j].t1t2.y := IniReadFloatEx(ini, dir, 't2_' + pref, 0);
    end;
    m.date := ini.readString(dir, 'Date', '01.01.0001');
    m.ls1 := ini.readString(dir, 'S1', '');
    m.ls2 := ini.readString(dir, 'S2', '');
    m.ls3 := ini.readString(dir, 'S3', '');
    m.ls4 := ini.readString(dir, 'S4', '');
    m.region := ini.readString(dir, 'Reg', m.region);
    m.cut := ini.ReadInteger(dir, 'Segment', m.cut);
    m.poly := ini.ReadInteger(dir, 'Poly', 1);
    m.useSNames := ini.ReadBool(dir, 'UseSNames', m.useSNames);
    m.m_active := ini.ReadBool(dir, 'Active', true);
    for j := 0 to 2 do
    begin
      str := ini.readString(dir, 'Row' + inttostr(j + 1), '');
      V := GetSubString(str, ';', 1, k);
      m.m[0, j] := strtofloatext(V);
      V := GetSubString(str, ';', k + 1, k);
      m.m[1, j] := strtofloatext(V);
      V := GetSubString(str, ';', k + 1, k);
      m.m[2, j] := strtofloatext(V);
      V := GetSubString(str, ';', k + 1, k);
      m.m[3, j] := strtofloatext(V);
    end;
    MatrixList.Add(m);
  end;
  sections.Destroy;
  ShowMatrixList;
end;

procedure TRZDFrm.ExportMatrix(m: TRZDMatrix; ifile: string);
var
  ini: tinifile;
  fname, str, pref: string;
  i: integer;
begin
  ini := tinifile.create(ifile);
  fname := m.GetIniName;
  for i := 0 to 3 do
  begin
    case i of
      0:
        pref := 'vc';
      1:
        pref := 'h';
      2:
        pref := 'hout';
      3:
        pref := 'hin';
    end;
    ini.writeString(fname, 'File_' + pref, m.sensors[i].mf);
    ini.writeString(fname, 'Vt_' + pref, m.sensors[i].vt);
    ini.writeString(fname, 'Gt_' + pref, m.sensors[i].gt);
    ini.writeString(fname, 'S1_' + pref, m.sensors[i].s1);
    ini.writeString(fname, 'S2_' + pref, m.sensors[i].s2);
    ini.writeString(fname, 'S3_' + pref, m.sensors[i].s3);
    ini.writeString(fname, 'S4_' + pref, m.sensors[i].s4);
    ini.writeFloat(fname, 't1_' + pref, m.sensors[i].t1t2.x);
    ini.writeFloat(fname, 't2_' + pref, m.sensors[i].t1t2.y);
  end;
  // Сохраняем только предустановленные имена
  ini.writeString(fname, 'Date', m.date);
  ini.writeString(fname, 'S1', m.ls1);
  ini.writeString(fname, 'S2', m.ls2);
  ini.writeString(fname, 'S3', m.ls3);
  ini.writeString(fname, 'S4', m.ls4);
  ini.writeString(fname, 'Reg', m.region);
  ini.writeInteger(fname, 'Segment', m.cut);
  ini.writeInteger(fname, 'Poly', m.poly);
  ini.WriteBool(fname, 'UseSNames', m.useSNames);
  ini.WriteBool(fname, 'Active', m.m_active);
  for i := 0 to 2 do
  begin
    str := m.getRow(i);
    ini.writeString(fname, 'Row' + inttostr(i + 1), str);
  end;
  ini.Destroy;
end;

procedure TRZDFrm.ExportMatrixBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute(0) then
  begin

  end;
end;

procedure TRZDFrm.ClearMList;
var
  i: integer;
  m: TRZDMatrix;
begin
  for i := 0 to MatrixList.count - 1 do
  begin
    m := TRZDMatrix(MatrixList.Items[i]);
    m.Destroy;
  end;
  MatrixList.clear;
end;

procedure TRZDFrm.FillMatrixSensorsCB;
var
  i: integer;
  str: string;
  sections: tstringlist;
  ifile: tinifile;
begin
  ifile := tinifile.create(TestPath.Text);
  sections := tstringlist.create;
  ifile.ReadSections(sections);

  Mat_S1CB.clear;
  Mat_S2CB.clear;
  Mat_S3CB.clear;
  Mat_S4CB.clear;
  for i := 0 to sections.count - 1 do
  begin
    str := sections.Strings[i];
    if lowercase(str) <> 'mera' then
    begin
      Mat_S1CB.AddItem(str, nil);
      Mat_S2CB.AddItem(str, nil);
      Mat_S3CB.AddItem(str, nil);
      Mat_S4CB.AddItem(str, nil);
    end;
  end;
  ifile.Destroy;
  sections.Destroy;
end;

procedure TRZDFrm.ShowMatrixList;
var
  i: integer;
  m: TRZDMatrix;
  li: TListItem;
begin
  MatrixLV.clear;
  for i := 0 to MatrixList.count - 1 do
  begin
    m := TRZDMatrix(MatrixList.Items[i]);
    m.UpdateSNames(gettestpath);
    li := MatrixLV.Items.Add;
    li.data := m;
    li.Checked := m.m_active;
    MatrixLV.SetSubItemByColumnName('Матрица', m.Infostr, li);
    MatrixLV.SetSubItemByColumnName('Рег.', m.region, li);
    MatrixLV.SetSubItemByColumnName('Сеч.', inttostr(m.cut), li);
    MatrixLV.SetSubItemByColumnName('Poly', inttostr(m.poly), li);
    if m.cut = CutSE.Value then
    begin
      // отображает на форме матрицу
      if m.region = RegionCB.Text then
        ShowG(m.m);
    end;
    MatrixLV.SetSubItemByColumnName('S1', m.s1, li);
    MatrixLV.SetSubItemByColumnName('S2', m.s2, li);
    MatrixLV.SetSubItemByColumnName('S3', m.s3, li);
    MatrixLV.SetSubItemByColumnName('S4', m.s4, li);
  end;

  LVChange(MatrixLV);
end;

function TRZDMatrix.ApplyMatrix(src: csrc): boolean;
var
  l_s1, l_s2, l_s3, l_s4: iwpSignal;
  b1, b2, b3, b4: boolean;
begin
  result := false;
  if useSNames then
  begin
    if (s1 = '') or (s2 = '') or (s1 = '') or (s2 = '') then
    begin
      RZDFrm.JournalLB.AddItem(
        'Не определен один из сигналов, попытка поиска по префиксам...', nil);
      exit;
    end;
  end
  else
  begin
    UpdateSNames(src);
  end;
  l_s1 := RZDFrm.GetSignal(src, s1, false, b1);
  l_s2 := RZDFrm.GetSignal(src, s2, false, b2);
  l_s3 := RZDFrm.GetSignal(src, s3, false, b3);
  l_s4 := RZDFrm.GetSignal(src, s4, false, b4);
  if b1 and b2 and b3 and b4 then
  begin
    result := true;
    RZDFrm.ApplyMatrix(l_s1, l_s2, l_s3, l_s4, m, src.name,
      inttostr(cut) + '_' + region, self);
  end
  else
  begin
    RZDFrm.JournalLB.AddItem('Не найдены сигналы', nil);
  end;
end;

procedure TRZDMatrix.UpdateSNames(mf: string);
var
  list: tstringlist;
begin
  list := RZDFrm.GetSensorsNameWithPref(mf, cut);
  if not useSNames then
    s1 := list.Strings[0];
  if not useSNames then
    s2 := list.Strings[1];
  if not useSNames then
    s3 := list.Strings[2];
  if not useSNames then
    s4 := list.Strings[3];
  list.Destroy;
end;

procedure TRZDMatrix.UpdateSNames(src: csrc);
var
  list: tstringlist;
begin
  list := RZDFrm.GetSensorsNameWithPref(src, cut);
  if s1 = '' then
  begin
    if list.count <> 0 then
      s1 := list.Strings[0];
  end;
  if s2 = '' then
  begin
    if list.count > 0 then
      s2 := list.Strings[1];
  end;
  if s3 = '' then
  begin
    if list.count > 1 then
      s3 := list.Strings[2];
  end;
  if s4 = '' then
  begin
    if list.count > 2 then
      s4 := list.Strings[3];
  end;
  list.Destroy;
end;

function TRZDMatrix.getRow(i: integer): string;
begin
  result := floattostr(m[0, i]) + ';' + floattostr(m[1, i]) + ';' + floattostr
    (m[2, i]) + ';' + floattostr(m[3, i]);
end;

function TRZDMatrix.GetResPostfix: string;
begin
  result := '_' + inttostr(cut) + '_' + region;
end;

function TRZDMatrix.regionNum: integer;
begin
  result := strtointext(getendnum(region));
end;

function TRZDMatrix.Infostr: string;
begin
  result := formatstrNoE(m[0, 0], c_digits) + ';' + formatstrNoE(m[1, 0],
    c_digits) + ';' + formatstrNoE(m[2, 0], c_digits) + ';' + formatstrNoE
    (m[3, 0], c_digits);
end;

function TRZDMatrix.GetIniName: string;
begin
  result := 'REG=' + region + ';' + 'Segment=' + inttostr(cut);
end;

constructor TRZDMatrix.create;
begin
  useSNames := false;
  m_active := true;
  setlength(m, 4, 3);
end;

function TRZDMatrix.gets1: string;
begin
  if useSNames then
    result := ls1
  else
    result := fs1;
end;

function TRZDMatrix.gets2: string;
begin
  if useSNames then
    result := ls2
  else
    result := fs2;
end;

function TRZDMatrix.gets3: string;
begin
  if useSNames then
    result := ls3
  else
    result := fs3;
end;

function TRZDMatrix.gets4: string;
begin
  if useSNames then
    result := ls4
  else
    result := fs4;
end;

function TRZDMatrix.gets(index: integer): string;
begin
  case index of
    0:
      result := s1;
    1:
      result := s2;
    2:
      result := s3;
    3:
      result := s4;
  end;
end;

procedure TRZDMatrix.sets(index: integer; str: string);
begin
  case index of
    0:
      ls1 := str;
    1:
      ls2 := str;
    2:
      ls3 := str;
    3:
      ls4 := str;
  end;
end;

procedure TRZDFrm.UpdateDB;
var
  capt: string;
begin
  EnterCriticalSection(f_updDBCS);
  if f_needUpdateDB then
  begin
    f_needUpdateDB := false;
    capt := RZDFrm.Caption;
    RZDFrm.Caption := 'Обновление базы данных';
    m_DB.m_BaseFolder.Path := BaseFolderEdit.Text;
    // отображение в дереве
    doUpdateBase(nil);
    RZDFrm.Caption := capt;
  end;
  LeaveCriticalSection(f_updDBCS);
end;

procedure TRZDFrm.UpdateDB(str: string);
var
  fld, capt: string;
begin
  EnterCriticalSection(f_updDBCS);
  if f_needUpdateDB then
  begin
    f_needUpdateDB := false;
    // inc(ThreadCount);
    capt := RZDFrm.Caption;
    RZDFrm.Caption := 'Обновление базы данных';
    fld := GetPathLevel(m_DB.m_BaseFolder.absolutepath, str, 1);
    // log.addInfoMes('UpdateDB_1');
    m_DB.UpdateDB(fld);
    // отображение в дереве
    doUpdateBase(nil);
    RZDFrm.Caption := capt;
  end;
  LeaveCriticalSection(f_updDBCS);
end;

procedure TRZDFrm.createDB;
begin
  InitializeCriticalSection(f_updDBCS);
  // DeleteCriticalSection(f_updDBCS);
  if m_DB = nil then
  begin
    m_DB := cRZDbase.create;
    m_DB.m_wpMng := m_wpMng;
    m_DB.m_syncHandle := handle;
    m_DB.m_BaseFolder.name := 'BaseFolder';

    m_DB.images_16 := ImageList_16;
    m_DB.images_32 := ImageList_32;

    m_DB.m_MeraPref := '.mera';
    m_DB.m_VCPref := m_VCPref;
    m_DB.m_Hpref := m_H_Pref;
    m_DB.m_Hinpref := m_Hin_Pref;
    m_DB.m_HOutpref := m_Hout_Pref;
    m_DB.regionPref := m_regionPref;
    m_DB.m_SegPref := m_sectionPref;

    crzdbasefolder(m_DB.m_BaseFolder).SetMatrixPref('.rzd');
    crzdbasefolder(m_DB.m_BaseFolder).SetTestsPref;
    crzdbasefolder(m_DB.m_BaseFolder).SetMainPath
      (extractfiledir(ImportMatrixPath.Text), 'calibr', 'tests');
    crzdbasefolder(m_DB.m_BaseFolder).m_MatrixFolder.Caption := 'Matrix';

    m_DB.InitBaseFolder(BaseFolderEdit.Text);
    // m_db.Events.AddEvent('RZD_UpdateBase', E_OnUpdateFolder, doUpdateBaseMessage);
    doUpdateBase(nil);
  end;
  f_needUpdateDB := true;
end;

procedure TRZDFrm.UpdateHandler(var Message: TMessage);
var
  str: widestring;
  foldername: string;
  L: integer;
  obj: cDBObject;
  baseobj: cDBFolder;
begin
  case message.Msg of
    wm_UpdateFolder:
      begin
        f_updFolder := m_DB.m_FileNotStr;

        Timer1.enabled := false;
        Timer1.enabled := true;
      end;
  end;
end;

procedure TRZDFrm.doUpdateBaseMessage(Sender: TObject);
begin
  PostMessage(handle, wm_UpdateFolder, 0, 0);
end;

procedure TRZDFrm.doUpdateBase(Sender: TObject);
begin
  // if GetCurrentThreadId=MainThreadID then
  // begin
  showInVTreeView(VTree1, m_DB.m_BaseFolder, ImageList_16);
  // end;
end;

procedure TRZDFrm.copyFile(str: string; p: crzdpars);
var
  base, fname: string;
begin
  if p.pars.sType > 0 then
  begin
    base := GetregionPath + '\' + m_regionPref + inttostr(p.pars.reg)
      + '\' + m_sectionPref + inttostr(p.pars.seg) + '\';
    fname := extractfilename(str);
  end;
  p.Destroy;
end;

end.
