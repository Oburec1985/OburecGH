unit uSRSFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  Forms, ComCtrls,
  uRecBasicFactory,
  uRecorderEvents,
  uChart,
  inifiles,
  upage,
  tags,
  complex,
  uBuffTrend1d,
  uCommonMath,
  uCommonTypes,
  pluginClass,
  uMeasureBase,
  uMBaseControl,
  shellapi,
  uPathMng,
  opengl, uSimpleObjects,
  math, uAxis, uDrawObj, uDoubleCursor, uBasicTrend,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons;

type
  TSpmWndFunc = (wnd_no, wnd_rect, wnd_exp, // окно с формулой *e^(-x), где x 0...1 (1 при времени)
    wnd_han);

  TSpmWnd = record
    wndfunc: TSpmWndFunc;
    x1, x2, y: double;
    // exp res = exp (ln(y)(x-x0)/(x1-x0))
  end;

  cSpmCfg = class;

  cExpFuncObj = class(cMoveObj)
  public
    // 0 - точка в которой экс. ф-я=1,
    // x1 - точка в которой нормируется значение экспоненты
    // y1 - значение экспоненты для x1
    m_x0, m_x1, m_y1: double;
    // событие при обновлении координат
    fUpdateParams: TNotifyEvent;
  protected
    // координаты для отрисовки
    fy0, fy1, fdy, fdy005, faxmin: double;
    // константа для градуировки точки x1 y1
    // exp(-fA*x1)=y1
    fA: double;
    // 0 - не прошел тест 1- точка 0, 2 - точка 1
    fTestObj: integer;
  public
    m_DisplayListName: Cardinal;
    m_needRecompile: boolean;
    m_weight: single;
    m_count: integer;
  protected
    function TestObj(p_p2: point2; dist: single): boolean; override;
    // пересчитать границы
    procedure EvalBound; override;
    procedure EvalA;
    procedure compile;
    procedure drawdata; override;
    // происходит когда обновился масштаб оси объекта
    procedure doUpdateWorldSize(sender: tobject); override;
    procedure SetPos(p: point2); override;
    procedure doOnUpdateParams;
  public
    procedure SetParams(x0, x1, y1: double);
    function getScale(x: double): double;
    constructor create; override;
    destructor destroy; override;
  end;

  // структура для хранения удара
  TDataBlock = class
  public
    m_owner: tlist;
    // используется для тахо. Найден блок данных хотя бы по одному датчику
    m_connectedInd: integer;

    m_timeStamp: point2d;
    m_timeInd: integer; // для синхронизации.блок srs хранит индекс блока тахо
    m_timecapacity: integer; // вместимость для осцилограммы
    // размер для m_TimeBlock
    m_TimeArrSize: integer;
    m_spmsize: integer;
    // усредненнй спектр
    m_WechSpm: TCmxArray_d;
    m_Cxy: TCmxArray_d;
    m_frf, m_mod2 // спектр амплитуд квадрат
      : TDoubleArray; // спектр амплитуд
    // исходный массив данных для расчета удара
    m_TimeBlock: TDoubleArray;
    // спектр амплитуд.
    m_mod,
    // блок данных по которому идет расчет спектра.
    m_TimeBlockFlt: TAlignDarray;
    // спектр re_im
    m_ClxData: TAlignDCmpx;
  protected
  protected
    procedure prepareData;
    // вычислить амплитуду^2
    procedure evalmod2;
    procedure setsize(s: integer);
    function getsize: integer;
    function TahoFreq: double;
  public
    // построить спектр
    procedure BuildSpm;
    function index: integer;
    property spmsize: integer read getsize write setsize;
  end;

  TDataBlockList = class(tlist)
  public
    m_wnd: TSpmWnd;
    // когеренция по списку ударов
    m_coh: TDoubleArray;
    // кроссспектр ударов
    m_Cxy: TCmxArray_d; // Sxy
    // спектр S
    m_Sxx,
    // спектр Taho
    m_Syy: TDoubleArray;
    m_LastBlock: integer;
    m_shockCount: integer; // общее число ударов за все время
    m_cfg: cSpmCfg;
  public
    // hideind - номер удара который не учитывается
    procedure evalCoh(TahoShockList: TDataBlockList; hideind: integer);
    procedure clearData;
    procedure delBlock(db: TDataBlock);
    function getBlock(i: integer): TDataBlock;
    function getLastBlock: TDataBlock; overload;
    function getLastBlock(d: TDataBlock): TDataBlock; overload;
    function getPrevBlock(d: TDataBlock): TDataBlock;
    // добавить спектр удара data - TCmxArray_d
    function addBlock(p_spmsize: integer): TDataBlock; overload;
    function addBlock(p_spmsize: integer; time: point2d; tb: TDoubleArray;
      p_timesize: integer): TDataBlock; overload;
    constructor create;
    destructor destroy;
  end;

  cSRSres = class;

  // конфигуратор расчета спектра
  cSpmCfg = class
  public
    // ограничение по количеству ударов
    m_capacity: integer;
    // FFTplan
    FFTProp: TFFTProp;
    // число точек fft, число блоков по которым идет расчет спектров,
    m_fftCount, fHalfFft, m_blockcount: integer;
    // добавлять нули
    m_addNulls: boolean;
  private
    ftypeRes: integer;
    // разрешение спектра
    fspmdx: double;
    // размер порции по которой идет расчет (length*fs*blockCount) в сек.
    fportionsize: double;
    // размер порции по которой идет расчет в отсчетах
    fportionsizei: integer;
    // размер блока по которому идет расчет fft. Если не дополнять нулями то равен m_fftCount*m_blockcount
    // иначе полезных данных в блоке будет m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // количество отсчетов дополняемых нулями
    fNullsPoints: integer;
  public
    taho: tobject;
    // список сигналов к обработке
    m_SRSList: tlist;
  protected
    procedure settyperes(t: integer);
  public
    procedure setWnd(wf: TSpmWndFunc; x1, x2, y: double); overload;
    procedure setWnd(wf: TSpmWndFunc); overload;
    procedure addSRS(s: pointer);
    function GetSrs(i: integer): cSRSres;
    function SRSCount: integer;
    // частота дискретизации сигнала
    function Freq: double;
    function name: string;
    property typeres: integer read ftypeRes write settyperes;
    constructor create;
    destructor destroy;
  end;

  cSRSres = class
  public
    m_tag: ctag;
  public
    m_SpmDx: double;
    m_freq: double;
    // размер блока для расчета спектра = freq*Numpoints
    blSize: double;
    // блок данных по которому идет расчет.
    m_T1data: TAlignDarray;
    fDataCount: integer; // количество данных в m_T1data
    // спектр re_im
    m_T1ClxData: TAlignDCmpx;
    // спектр амплитуд
    m_rms: TAlignDarray;
    // синтезированная передаточная характеристика
    m_frf, m_phase: TDoubleArray;
    m_fltFrf: array of integer; // счетчик отбракованных точек
    line, lineSpm, lineCoh, lineFrf,
    // усредненная Frf
    lineAvFRF: cBuffTrend1d;
    // список ударов (TDataBlock)
    m_shockList: TDataBlockList;
    // обработан последний удар
    m_shockProcessed: boolean;
  private
    fcfg: cSpmCfg;
    fComInt: point2d;
    // найден общий интервал с взведенным тригом
    // fComInterval:boolean;
    fComIntervalLen: double;
  protected
    procedure setcfg(c: cSpmCfg);
  public
    property cfg: cSpmCfg read fcfg write setcfg;
    function name: string;
    constructor create;
    destructor destroy;
  end;

  // выключен/ найден/ завершен TrEnd - накоплены данные для удара на тахо канале
  TtrigStates = (TrOff, TrRise, TrFall, TrEnd);

  cSRSTaho = class
  public
    m_frm: tform;
    m_CohTreshold,
    // Амплдитуда для обнаружения события
    m_treshold: double;
    // отступ слева и длительность
    m_ShiftLeft, m_Length: double;
    m_tag: ctag;
    // блок данных по которому идет расчет. Размер fportionsizei = length*ShockCount
    m_T1data: TAlignDarray;
    fDataCount: integer; // количество данных в m_T1data
    // спектр re_im
    // m_T1ClxData:TAlignDCmpx;
    // тот же спектр, но амплитуда
    // m_rms: TAlignDarray;
    line, lineSpm: cBuffTrend1d;

    // список ударов (TDataBlock)
    m_shockList: TDataBlockList;
    // окно на удар
    m_corrTaho: boolean;
  private // переменные для обсчета в алгоритме обработки
    v_min, v_max: double;
    f_imin, f_imax, // индексы отсчетов содержащих максимум и минимум в текущем ударе
    f_iEnd: integer; // индекс последнего отсчета в текущем ударе
    fTrigState: TtrigStates;
    // номер удара в серии
    fShockInd: integer;
    // начало и конец найденного для обработки удара
    TrigInterval: point2d;
  private
    fSpmCfgList: tlist;
  protected
    procedure setcfg(c: cSpmCfg);
    function getCfg(i: integer): cSpmCfg; overload;
    function getCfg: cSpmCfg; overload;
    // когда найден новый триггер, старый пора сбросить:
    // например обнулить общий интевал
    procedure resetTrig;
  public
    property cfg: cSpmCfg read getCfg write setcfg;
    function CfgCount: integer;
    // длина корректируемых окном данных
    function corrLen: double;
    procedure evalCoh(hideind: integer);
    procedure evalFRF(hideind: integer; estimator: integer;
      rebuildspm: boolean);
    // расчет сохраняется в m_Cxy блоков
    procedure evalWelchSpm(tb, sb: TDataBlock);
    procedure evalWelchFrf(estimator: integer);
    function name: string;
    constructor create;
    destructor destroy;
  end;

  TSRSFrm = class(TRecFrm)
    SpmChart: cChart;
    RightGB: TGroupBox;
    ShockCountLabel: TLabel;
    ShockCountE: TEdit;
    SaveBtn: TButton;
    ShockSB: TSpinButton;
    ShockIE: TIntEdit;
    ShockLabel: TLabel;
    WinPosBtn: TSpeedButton;
    Point_No: TLabel;
    PointIE: TIntEdit;
    PointSE: TSpinButton;
    SaveMdbPan: TPanel;
    SaveMdbBtn: TButton;
    Button1: TButton;
    CompareBtn: TSpeedButton;
    DelBtn: TButton;
    hideCB: TCheckBox;
    EstimatorRG: TRadioGroup;
    UseWndFcb: TCheckBox;
    WelchCB: TCheckBox;
    DisableCB: TCheckBox;
    SPMcb: TCheckBox;
    procedure FormCreate(sender: tobject);
    procedure SaveBtnClick(sender: tobject);
    procedure WinPosBtnClick(sender: tobject);
    procedure ShockSBDownClick(sender: tobject);
    procedure ShockSBUpClick(sender: tobject);
    procedure SpmChartDblClick(sender: tobject);
    procedure SaveMdbBtnClick(sender: tobject);
    procedure CompareBtnClick(sender: tobject);
    procedure DelBtnClick(sender: tobject);
    procedure hideCBClick(sender: tobject);
    procedure EstimatorRGClick(sender: tobject);
    procedure UseWndFcbClick(sender: tobject);
    procedure SpmChartCursorMove(sender: tobject);
    procedure WelchCBClick(sender: tobject);
    procedure DisableCBClick(sender: tobject);
    procedure SPMcbClick(sender: tobject);
  public
    ready: boolean;
    // axRef - воздействие; ax - отклик
    axRef, ax: caxis;
    // h0, h1, h2
    m_estimator: integer;
    pageT, pageSpm: cpage;
    axSpm, axCoh: caxis;
    m_expWndline: cExpFuncObj;
    // список настроек Тахо
    m_TahoList: tlist;
    // spm
    m_lgX, m_lgY, m_newAx: boolean;
    m_minX, m_maxX: double;
    m_minY, m_maxY: double;
    m_saveT0: boolean;

    m_UseWelch: boolean;
    m_WelchShift, m_WelchCount: integer;
    // последний полученный блок тахо
    m_lastTahoBlock: TDataBlock;
    m_lastMDBfile: string;
    // редактировать отклик
    m_corrS: boolean;
  protected
    fdelBtn: boolean; // нажали кнопку удалить удар
    fUpdateFrf: boolean; // обновился frf
    fShowLast: boolean; // обновился frf  в потоке
  protected
    procedure doUpdateParams(sender: tobject);
    // расчет числа боков для усреднения
    procedure EvalWelchBCount;
    procedure setNewAx(b: boolean);
  public
    function hideind: integer;
    procedure delCurrentShock;
    PROCEDURE ShowShock(shock: integer);
    // отобразить последнюю передаточную характеристику блока в S и усредн. передаточную
    procedure ShowFrf(s: cSRSres; c: cSpmCfg; shInd: integer);
    procedure ShowSpm;
    procedure UpdateView;
    procedure updatedata;
    // выделение памяти. происходит при загрузке или смене конфига
    procedure UpdateBlocks;
    procedure UpdateChart;
    procedure doStart;
    procedure addTaho(t: cSRSTaho);
    function getTaho: cSRSTaho;
    procedure RBtnClick(sender: tobject);
    procedure TestCoh;
    procedure updateFrf(rebuildspm: boolean);
    procedure updateWelchFrf;
  public
    property NewAxis: boolean read m_newAx write setNewAx;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  ISRSFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cSRSFactory = class(cRecBasicFactory)
  public
    // merafile
    m_meraFile: string;
    m_ShockFile: string;
  private
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
    // когда Recorder загрузил конфиги;
    procedure doRecorderInit; override;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure doStart;
    procedure doStop;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

  // копируем данные из тега по интервалу времени time в buf. Возвращает число элементов
function copyData(t: ctag; var time: point2d; buf: TAlignDarray): integer;

var
  SRSFrm: TSRSFrm;
  g_SRSFactory: cSRSFactory;
  g_disableFRF: boolean;

const
  c_Pic = 'SRSFRM';
  c_Name = 'Анализ ударов';
  c_defXSize = 400;
  c_defYSize = 400;
  c_FRF = 1;

  // ctrl+shift+G
  // ['{54C462CD-E137-4BA6-9FB5-EFD92D159DE5}']
  IID_SRS: TGuid = (D1: $54C462CD; D2: $E137; D3: $4BA6;
    D4: ($9F, $B5, $EF, $D9, $2D, $15, $9D, $E5));

implementation

uses
  uEditSrsFrm, uCreateComponents;
{$R *.dfm}

function copyData(t: ctag; var time: point2d; buf: TAlignDarray): integer;
var
  int: tpoint;
begin
  int := t.getIntervalInd(time);
  if int.x < 0 then // если предыстория не успела накопиться
  begin
    time.x := time.x - int.x / t.Freq;
    int.x := 0;
  end;
  result := int.y - int.x;
  move(t.m_ReadData[int.x], buf.p^, result * sizeof(double));
end;

{ TSRSFrm }
procedure TSRSFrm.addTaho(t: cSRSTaho);
begin
  t.m_frm := self;
  m_TahoList.Add(t);
end;

procedure TSRSFrm.CompareBtnClick(sender: tobject);
var
  o: cObjFolder;
  t: cTestFolder;
  path: string;
  ifile: TIniFile;
  f, sname: string;
begin
  if g_MBaseControl <> nil then
  begin
    o := g_MBaseControl.GetSelectObj;
    t := g_MBaseControl.GetSelectTest;
    if o <> nil then
    begin
      path := g_mbase.m_BaseFolder.Absolutepath;
      if o.ObjType <> '' then
      begin
        path := path + '\FrfTypes' + '\' + o.ObjType;
        f := path + '\frf.mera';
        if m_lastMDBfile <> '' then
        begin
          f := m_lastMDBfile;
        end;
        if fileexists(f) then
          ShellExecute(0, nil, pwidechar(f), nil, nil, SW_HIDE);
      end;
    end;
  end;
end;

constructor TSRSFrm.create(Aowner: tcomponent);
begin
  m_TahoList := tlist.create;
  inherited;
end;

procedure TSRSFrm.DelBtnClick(sender: tobject);
begin
  fdelBtn := true;
  if RStateStop then
    UpdateView;
end;

procedure TSRSFrm.ShowFrf(s: cSRSres; c: cSpmCfg; shInd: integer);
var
  sd: TDataBlock;
begin
  // рисуем
  if shInd > -1 then
    sd := s.m_shockList.getBlock(shInd)
  else
    sd := s.m_shockList.getLastBlock;
  s.lineAvFRF.AddPoints(s.m_frf, c.fHalfFft);
  if sd <> nil then
  begin
    s.lineFrf.AddPoints(sd.m_frf, c.fHalfFft);
  end;
  fUpdateFrf := false;
end;

procedure TSRSFrm.delCurrentShock;
var
  td, sd: TDataBlock;
  s: cSRSres;
  t: cSRSTaho;
  c: cSpmCfg;
  i: integer;
begin
  t := getTaho;
  for i := 0 to t.cfg.SRSCount - 1 do
  begin
    hideCB.Checked := false;
    s := t.cfg.GetSrs(i);
    sd := s.m_shockList.getBlock(ShockIE.intnum);
    if sd = nil then
      exit;
    td := t.m_shockList.getBlock(ShockIE.intnum);
    s.m_shockList.delBlock(sd);
    t.m_shockList.delBlock(td);
    updateFrf(false);
  end;
  ShockCountE.Text := inttostr(t.m_shockList.Count);
  fdelBtn := false;
end;

destructor TSRSFrm.destroy;
begin
  m_TahoList.destroy;
end;

procedure TSRSFrm.DisableCBClick(sender: tobject);
begin
  g_disableFRF := DisableCB.Checked;
end;

procedure TSRSFrm.doStart;
var
  t: cSRSTaho;
  i: integer;
  s: cSRSres;
begin
  m_lastMDBfile := '';
  m_lastTahoBlock := nil;
  ready := false;
  t := getTaho;
  if t = nil then
    exit;
  t.fTrigState := TrOff;
  if t.m_tag <> nil then
  begin
    t.m_tag.doOnStart;
    t.m_shockList.clearData;
    t.f_iEnd := 0;
    ZeroMemory(t.m_T1data.p, t.cfg.fportionsizei * sizeof(double));
    if t.cfg <> nil then
    begin
      for i := 0 to t.cfg.SRSCount - 1 do
      begin
        s := t.cfg.GetSrs(i);
        s.m_tag.doOnStart;
        s.m_shockList.clearData;
        ZeroMemory(s.m_T1data.p, t.cfg.fportionsizei * sizeof(double));
        ZeroMemory(s.m_frf, t.cfg.fHalfFft * sizeof(double));
      end;
    end
    else
    begin
      exit;
    end;
  end
  else
  begin
    exit;
  end;
  ready := true;
end;

procedure TSRSFrm.doUpdateParams(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i: integer;
  db, lb: TDataBlock;
  j: integer;
begin
  t := getTaho;
  if t = nil then
    exit;

  c := t.getCfg;
  for i := 0 to c.m_SRSList.Count - 1 do
  begin
    s := c.GetSrs(i);
    s.m_shockList.m_wnd.x1 := m_expWndline.m_x0;
    s.m_shockList.m_wnd.x2 := m_expWndline.m_x1;
    s.m_shockList.m_wnd.y := m_expWndline.m_y1;
    lb := s.m_shockList.getLastBlock;
    if lb = nil then
      exit;

    lb.prepareData;
    lb.BuildSpm;
    if db = nil then
      exit;
    for j := 0 to s.m_shockList.Count - 1 do
    begin
      db := s.m_shockList.getBlock(j);
      if lb = db then
        continue;
      db.prepareData;
      db.BuildSpm;
    end;
    s.line.AddPoints(TDoubleArray(lb.m_TimeBlockFlt.p), lb.m_TimeArrSize);
  end;
  updateFrf(false);
  UpdateView;
end;

procedure TSRSFrm.updateWelchFrf;
var
  t: cSRSTaho;
begin
  t := getTaho;
  if t = nil then
    exit;

  if t.m_shockList.Count > 0 then
  begin
    t.evalCoh(hideind);
    t.evalWelchFrf(m_estimator);
    fUpdateFrf := true;
  end;
end;

procedure TSRSFrm.updateFrf(rebuildspm: boolean);
var
  t: cSRSTaho;
  c: cSpmCfg;
begin
  if m_UseWelch then
  begin
    updateWelchFrf;
    exit;
  end;
  t := getTaho;
  if t = nil then
    exit;
  c := t.getCfg;

  if t.m_shockList.Count > 0 then
  begin
    t.evalCoh(hideind);
    t.evalFRF(hideind, m_estimator, rebuildspm);
    fUpdateFrf := true;
  end;
end;

procedure TSRSFrm.EstimatorRGClick(sender: tobject);
var
  i: integer;
  c: cSpmCfg;
  t: cSRSTaho;
  s: cSRSres;
begin
  m_estimator := EstimatorRG.ItemIndex;
  t := getTaho;
  updateFrf(false);
  UpdateView;
end;

procedure TSRSFrm.FormCreate(sender: tobject);
var
  p: cpage;
  r: frect;
begin
  SpmChart.OnRBtnClick := RBtnClick;
  SpmChart.tabs.activeTab.addPage(true);

  p := SpmChart.tabs.activeTab.GetPage(0);
  r.BottomLeft.x := 0;
  r.BottomLeft.y := 0;
  r.TopRight.x := 10;
  r.TopRight.y := 10;
  p.ZoomfRect(r);
  p.Caption := 'Oscillogram';
  pageT := p;

  p := SpmChart.tabs.activeTab.GetPage(1);
  r.BottomLeft.x := 0;
  r.BottomLeft.y := 0;
  r.TopRight.x := 10;
  r.TopRight.y := 10;
  p.ZoomfRect(r);
  p.Caption := 'Freq Dom.';
  pageSpm := p;
  axSpm := p.activeAxis;

  axCoh := caxis.create;
  axCoh.name := 'CoherenceAx';
  p.addaxis(axCoh);
  axCoh.min := p2d(0, 0);
  axCoh.max := p2d(10, 2);
end;

procedure TSRSFrm.UpdateBlocks;
var
  refresh: double;
  lt: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i: integer;
begin
  refresh := GetREFRESHPERIOD;
  lt := getTaho;
  c := lt.cfg;
  c.fHalfFft := c.m_fftCount shr 1;
  // размер блока для расчета в секундах
  c.fportionsize := lt.m_Length * c.m_blockcount;
  c.fportionsizei := round(c.fportionsize * lt.m_tag.Freq);
  c.fOutSize := c.m_fftCount * c.m_blockcount;
  c.fspmdx := lt.m_tag.Freq / c.m_fftCount;
  c.FFTProp := GetFFTPlan(c.m_fftCount);
  c.FFTProp.StartInd := 0;

  GetMemAlignedArray_d(c.fportionsizei, lt.m_T1data);
  // GetMemAlignedArray_cmpx_d(c.m_fftCount, lt.m_T1ClxData);
  // GetMemAlignedArray_d(c.m_fftCount, lt.m_rms);
  lt.lineSpm.dx := c.fspmdx;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    GetMemAlignedArray_d(c.fportionsizei, s.m_T1data);
    // tCmxArray_d(cSRSres(s).m_T1ClxData.p)
    GetMemAlignedArray_cmpx_d(c.m_fftCount, s.m_T1ClxData);
    GetMemAlignedArray_d(c.fHalfFft, s.m_rms);
    SetLength(s.m_frf, c.fHalfFft);
    SetLength(s.m_fltFrf, c.fHalfFft);
    SetLength(s.m_phase, c.fHalfFft);
    // блок расчета когеренции
    SetLength(s.m_shockList.m_Cxy, c.fHalfFft);
    SetLength(s.m_shockList.m_Sxx, c.fHalfFft);
    SetLength(s.m_shockList.m_Syy, c.fHalfFft);
    SetLength(s.m_shockList.m_coh, c.fHalfFft);

    s.lineSpm.dx := c.fspmdx;
    s.lineCoh.dx := c.fspmdx;
    s.lineFrf.dx := c.fspmdx;
    s.lineAvFRF.dx := c.fspmdx;
  end;
end;

procedure TSRSFrm.UpdateChart;
var
  l: cBuffTrend1d;
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i: integer;
  fr: frect;
  a: caxis;
  bfrf: boolean;
begin
  for i := 0 to pageT.axises.ChildCount - 1 do
  begin
    a := pageT.getaxis(i);
    a.clear;
  end;
  pageSpm.activeAxis.clear;
  t := getTaho;
  c := t.getCfg;

  UseWndFcb.Checked := t.m_shockList.m_wnd.wndfunc <> wnd_no;

  if t <> nil then
  begin
    if t.m_corrTaho then
    begin
      pageT.cursor.visible := true;
      pageT.cursor.cursortype := c_DoubleCursor;
      pageT.cursor.setx1(0);
      pageT.cursor.setx2(t.corrLen);
      t.m_shockList.m_wnd.x1 := 0;
      t.m_shockList.m_wnd.x2 := t.corrLen;
    end
    else
    begin
      pageT.cursor.visible := false;
      pageT.cursor.cursortype := c_DoubleCursor;
      pageT.cursor.setx1(0);
      pageT.cursor.setx2(t.corrLen);
    end;

    l := cBuffTrend1d.create;
    if m_newAx then
      axRef.AddChild(l)
    else
      pageT.getaxis(0).AddChild(l);
    l.color := ColorArray[0];
    t.line := l;
    t.line.name := t.name;
    l.dx := 1 / t.m_tag.Freq;

    l := cBuffTrend1d.create;
    l.color := ColorArray[0];
    t.lineSpm := l;
    t.lineSpm.dx := c.fspmdx;
    t.lineSpm.name := t.name + '_spm';
    bfrf := c.typeres = c_FRF;
    pageSpm.activeAxis.AddChild(l);
    l.visible := not bfrf;

    m_expWndline := cExpFuncObj.create;
    m_expWndline.name := 'ExpWndLine';
    m_expWndline.visible := UseWndFcb.Checked;
    m_expWndline.enabled := UseWndFcb.Checked;
    m_expWndline.selectable := UseWndFcb.Checked;
    m_expWndline.fUpdateParams := doUpdateParams;
    pageT.activeAxis.AddChild(m_expWndline);

    c := t.cfg;
    if m_corrS then
    begin
      c.setWnd(wnd_exp, t.m_ShiftLeft, t.m_Length, 0.0001);
    end
    else
    begin
      c.setWnd(wnd_no);
    end;
    for i := 0 to c.SRSCount - 1 do
    begin
      s := c.GetSrs(i);
      l := cBuffTrend1d.create;
      pageT.activeAxis.AddChild(l);
      l.color := ColorArray[i + 1];
      s.line := l;
      s.line.name := s.name;
      l.dx := 1 / t.m_tag.Freq;

      l := cBuffTrend1d.create;
      l.color := ColorArray[i + 1];
      pageSpm.activeAxis.AddChild(l);
      s.lineSpm := l;
      s.lineSpm.dx := c.fspmdx;
      s.lineSpm.name := s.name + '_spm';
      l.visible := not bfrf;

      l := cBuffTrend1d.create;
      l.color := ColorArray[i + 1];
      l.dx := c.fspmdx;
      pageSpm.activeAxis.AddChild(l);
      s.lineFrf := l;
      s.lineFrf.name := s.name + '_frf';
      l.visible := bfrf;

      l := cBuffTrend1d.create;
      l.color := ColorArray[i + 2];
      l.dx := c.fspmdx;
      pageSpm.activeAxis.AddChild(l);

      s.lineAvFRF := l;
      s.lineAvFRF.name := s.name + '_AvFrf';
      s.lineAvFRF.weight := 5;
      s.lineAvFRF.visible := true;

      l := cBuffTrend1d.create;
      // l.color := ColorArray[i+10];
      l.color := violet;
      l.dx := c.fspmdx;
      axCoh.AddChild(l);
      s.lineCoh := l;
      s.lineCoh.name := s.name + '_coh';
    end;
    c.typeres := c.typeres;

    fr.BottomLeft := p2(0, -2 * t.m_treshold);
    fr.TopRight := p2(t.m_Length, t.m_treshold * 2);
    pageT.ZoomfRect(fr);
    m_expWndline.SetParams(t.m_ShiftLeft, t.m_Length, 0.001);

    fr.BottomLeft := p2(m_minX, m_minY);
    fr.TopRight := p2(m_maxX, m_maxY);
    pageSpm.LgX := m_lgX;
    pageSpm.activeAxis.Lg := m_lgY;
    pageSpm.ZoomfRect(fr);
  end;
  UpdateBlocks;
end;

procedure TSRSFrm.updatedata;
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i, pcount, dropCount: integer;
  sig_interval, common_interval: point2d;
  b: boolean;
  block: TDataBlock;
  v, comIntervalLen, blocklen, refresh, dropLen: double;
begin
  if not ready then
    exit;
  t := getTaho;
  c := t.cfg;
  blocklen := t.m_Length;
  refresh := t.m_tag.BlockSize / t.m_tag.Freq;
  if blocklen < refresh then
    blocklen := refresh;
  if t.m_tag.UpdateTagData(true) then
  begin
    // не отбрасываем данные если находимся в состоянии когда триг найден но
    // еще не накопился целиком
    if t.fTrigState <> TrFall then
    begin
      dropLen := t.m_tag.getPortionLen - 2 * blocklen;
      if dropLen > 0 then // при этом условии гарантированно остается 2*blocklen
      begin
        dropCount := trunc(dropLen * t.m_tag.Freq);
        // возможно следует ограничить размер отбрасываемых данных
        // по f_iEnd
        if t.f_iEnd > 0 then
        begin
          if dropCount > t.f_iEnd then
            dropCount := t.f_iEnd;
        end;
        t.m_tag.ResetTagDataTimeInd(dropCount);
        t.f_iEnd := t.f_iEnd - dropCount;
        if t.f_iEnd < 0 then
        begin
          t.f_iEnd := 0;
          // если просохатили удар (отбросили данные в посл. ударе, забываем про него)
          t.resetTrig;
        end;
      end;
    end;
    t.v_min := t.m_tag.m_ReadData[0];
    t.v_max := t.m_tag.m_ReadData[0];
    // поиск триггера
    if t.fTrigState = TrOff then
    begin
      for i := t.f_iEnd to t.m_tag.lastindex - 1 do
      begin
        v := t.m_tag.m_ReadData[i];
        if v > t.m_treshold then
        begin
          if v > t.v_max then
          begin
            t.fTrigState := TrRise;
            t.v_max := v;
            t.f_imax := i;
          end;
        end
        else
        begin
          if t.fTrigState = TrRise then
            t.fTrigState := TrFall;
        end;
      end;
      // сдвигаем индекс проанализированных данных т.к. отбрасываемые данные ограничены iEnd
      // в противном случае можно отбросить не проанализированные данные
      if t.fTrigState = TrOff then
        t.f_iEnd := t.m_tag.lastindex;
    end;
    // если триггер найден
    if t.fTrigState = TrFall then
    begin
      inc(t.fShockInd);
      t.TrigInterval.x := t.m_tag.getReadTime(t.f_imax) - t.m_ShiftLeft;
      t.TrigInterval.y := t.TrigInterval.x + t.m_Length;
      t.f_iEnd := t.m_tag.getIndex(t.TrigInterval.y);
      // если данных накопилось на целиковый удар
      if t.f_iEnd <= t.m_tag.lastindex then
      begin
        t.fTrigState := TrEnd;
        pcount := copyData(t.m_tag, t.TrigInterval, t.m_T1data);
        t.fDataCount := pcount;
        /// дополнять нулями
        if pcount < c.m_fftCount then
        begin

        end;
        begin
          if m_lastTahoBlock <> nil then
          begin
            if m_lastTahoBlock.m_connectedInd = -1 then
            begin
              t.m_shockList.delBlock(m_lastTahoBlock);
            end;
          end;

          // AddBlock делать без перевыделения памяти!!!

          m_lastTahoBlock := t.m_shockList.addBlock(c.m_fftCount,
            p2d(t.TrigInterval.x, t.TrigInterval.x + pcount / t.m_tag.Freq),
            TDoubleArray(t.m_T1data.p), pcount);
          m_lastTahoBlock.prepareData;
          t.line.AddPoints(TDoubleArray(m_lastTahoBlock.m_TimeBlockFlt.p),
            pcount);
          t.line.flength := pcount;
          m_lastTahoBlock.BuildSpm;
          // t.lineSpm.AddPoints(TDoubleArray(m_lastTahoBlock.m_mod.p),
          // c.fHalfFft);
        end;
      end;
    end;
    if t.fTrigState = TrEnd then
    begin
      b := true;
      for i := 0 to c.SRSCount - 1 do
      begin
        s := c.GetSrs(i);
        if s.m_shockProcessed = false then
        begin
          b := false;
          break;
        end;
      end;
      if b then // стоит еще добавить проверку на отвалившийся датчик. В случае если
      // какой то канал не накопил удар, игнорируем его по таймауту
      begin
        t.evalFRF(hideind, m_estimator, false);
        fUpdateFrf := true;
        // показывать последний удар при обновлении
        fShowLast := true;
        // внутри вызывается t.fTrigState:=TrOff;
        t.resetTrig;
      end;
    end;
    for i := 0 to c.SRSCount - 1 do
    begin
      s := c.GetSrs(i);
      if s.m_tag.UpdateTagData(true) then
      begin
        sig_interval := s.m_tag.getPortionTime;
        if s.m_tag.getPortionLen > 2 * blocklen then
        begin
          dropCount := s.m_tag.getIndex(t.TrigInterval.x);
          // отбрасываем все что слева по времени от найденного удара
          if dropCount > 0 then
          begin
            s.m_tag.ResetTagDataTimeInd(dropCount - 1);
          end;
        end;
      end;
      common_interval := p2d(0, 0);
      comIntervalLen := 0;
      if sig_interval.y > t.TrigInterval.x then
      begin
        if t.TrigInterval.y > sig_interval.x then
        begin
          common_interval := getCommonInterval(sig_interval, t.TrigInterval);
          comIntervalLen := common_interval.y - common_interval.x;
        end;
      end;
      if comIntervalLen > 0 then
      begin
        // s.fComInterval:=true;
        // если данные накопились и тахо тоже накопился
        if (comIntervalLen > s.fComIntervalLen) and (t.fTrigState = TrEnd) then
        begin
          s.fComIntervalLen := comIntervalLen;
          s.fComInt := common_interval;
          pcount := copyData(s.m_tag, common_interval, s.m_T1data);
          if pcount >= c.m_fftCount then
          begin

          end;
          begin
            s.fDataCount := pcount;

            block := s.m_shockList.addBlock(c.m_fftCount, // SpmSize
              p2d(common_interval.x,
                common_interval.x + pcount / s.m_tag.Freq), // timeStamp
              TDoubleArray(s.m_T1data.p), // timeData
              pcount); // timeData size
            block.prepareData;
            block.BuildSpm;
            s.line.AddPoints(TDoubleArray(block.m_TimeBlockFlt.p), pcount);
            s.line.flength := pcount;

            m_lastTahoBlock.m_connectedInd := s.m_shockList.m_LastBlock;
            s.m_shockProcessed := true;
          end;
          t.evalCoh(hideind);
        end;
      end;
    end;
  end;
end;

procedure TSRSFrm.hideCBClick(sender: tobject);
var
  i: integer;
  c: cSpmCfg;
  t: cSRSTaho;
  s: cSRSres;
begin
  t := getTaho;
  updateFrf(false);
  UpdateView;
end;

function TSRSFrm.hideind: integer;
begin
  if hideCB.Checked then
  begin
    result := ShockIE.intnum;
  end
  else
  begin
    result := -1;
  end;
end;

procedure TSRSFrm.UpdateView;
var
  i: integer;
  c: cSpmCfg;
  t: cSRSTaho;
  s: cSRSres;
begin
  t := getTaho;
  if t = nil then
    exit;
  c := t.getCfg;
  if fdelBtn then
  begin
    delCurrentShock;
    s := c.GetSrs(0);
  end;
  if RStatePlay then
  begin
    if t <> nil then
    begin
      ShockCountE.Text := inttostr(t.m_shockList.Count);
    end;
  end;
  if not SPMcb.Checked then
  begin
    if fUpdateFrf then
    begin
      s := c.GetSrs(0);
      if fShowLast then
        ShowFrf(s, c, -1)
      else
        ShowFrf(s, c, ShockIE.intnum);
      fShowLast := false;
    end;
  end
  else
  begin
    ShowSpm;
  end;
  SpmChart.redraw;
end;

procedure TSRSFrm.UseWndFcbClick(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i: integer;
begin
  t := getTaho;
  c := t.cfg;
  t.m_corrTaho := UseWndFcb.Checked;
  if t.m_corrTaho then
  begin
    pageT.cursor.visible := true;
    pageT.cursor.cursortype := c_DoubleCursor;
    pageT.cursor.setx1(0);
    if t.corrLen <= 0 then
    begin
      t.m_shockList.m_wnd.x2 := t.m_Length * 0.7;
    end;
    pageT.cursor.setx2(t.m_shockList.m_wnd.x2);
    t.m_shockList.m_wnd.x1 := 0;
    t.m_shockList.m_wnd.x2 := t.m_shockList.m_wnd.x2;
  end
  else
  begin
    pageT.cursor.visible := false;
    pageT.cursor.cursortype := c_DoubleCursor;
    pageT.cursor.setx1(0);
    pageT.cursor.setx2(t.m_shockList.m_wnd.x2);
  end;

  if UseWndFcb.Checked then
  begin
    t.m_shockList.m_wnd.wndfunc := wnd_rect;
    c.setWnd(wnd_exp);
  end
  else
  begin
    t.m_shockList.m_wnd.wndfunc := wnd_no;
    c.setWnd(wnd_no);
  end;
  m_expWndline.locked := not UseWndFcb.Checked;
  m_expWndline.visible := UseWndFcb.Checked;
  m_expWndline.enabled := UseWndFcb.Checked;
  m_expWndline.selectable := UseWndFcb.Checked;
end;

procedure TSRSFrm.WelchCBClick(sender: tobject);
var
  t: cSRSTaho;
begin
  m_UseWelch := WelchCB.Checked;
  t := getTaho;
  updateFrf(not m_UseWelch);
  UpdateView;
end;

procedure TSRSFrm.WinPosBtnClick(sender: tobject);
begin
  if fileexists(g_SRSFactory.m_meraFile) then
    ShellExecute(0, nil, pwidechar(g_SRSFactory.m_ShockFile), nil, nil,
      SW_HIDE);
end;

function TSRSFrm.getTaho: cSRSTaho;
begin
  if m_TahoList.Count > 0 then
    result := cSRSTaho(m_TahoList.Items[0])
  else
    result := nil;
end;

procedure TSRSFrm.RBtnClick(sender: tobject);
begin
  if EditSrsFrm <> nil then
  begin
    EditSrsFrm.Edit(self);
  end;
end;

procedure TSRSFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, Count: integer;
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  tag: itag;
  ltag: ctag;
begin
  inherited;
  ltag := LoadTagIni(a_pIni, str, 'Taho_Tag');
  if ltag <> nil then
  begin
    t := cSRSTaho.create;
    t.m_tag.tag := ltag.tag;
    t.m_tag.tagname := ltag.tagname;
    ltag.destroy;
    c := cSpmCfg.create;
    t.cfg := c;
    addTaho(t);
  end
  else
    exit;
  t.m_ShiftLeft := strtoFloatExt(a_pIni.ReadString(str, 'ShiftLeft', '0.05'));
  t.m_treshold := strtoFloatExt(a_pIni.ReadString(str, 'Threshold', '0.05'));
  t.m_Length := strtoFloatExt(a_pIni.ReadString(str, 'Length', '0.05'));

  m_minX := strtoFloatExt(a_pIni.ReadString(str, 'Spm_minX', '0'));
  m_maxX := strtoFloatExt(a_pIni.ReadString(str, 'Spm_maxX', '1000'));
  m_minY := strtoFloatExt(a_pIni.ReadString(str, 'Spm_minY', '0.0001'));
  m_maxY := strtoFloatExt(a_pIni.ReadString(str, 'Spm_maxY', '10'));
  m_lgX := a_pIni.ReadBool(str, 'Spm_Lg_x', false);
  m_lgY := a_pIni.ReadBool(str, 'Spm_Lg_y', false);
  NewAxis := a_pIni.ReadBool(str, 'TahoNewAxis', false);
  m_saveT0 := a_pIni.ReadBool(str, 'SaveT0', false);
  m_estimator := a_pIni.ReadInteger(str, 'Estimator', 1);

  if c <> nil then
  begin
    c.m_capacity := a_pIni.ReadInteger(str, 'ShockCount', 5);
    c.m_fftCount := a_pIni.ReadInteger(str, 'FFtnum', 32);
    c.m_blockcount := a_pIni.ReadInteger(str, 'BlockCount', 1);
    c.m_addNulls := a_pIni.ReadBool(str, 'AddNulls', false);
    Count := a_pIni.ReadInteger(str, 'SigCount', 0);
    for i := 0 to Count - 1 do
    begin
      ltag := LoadTagIni(a_pIni, str, 'Tag_' + inttostr(i));
      if ltag <> nil then
      begin
        c.addSRS(pointer(ltag));
      end;
    end;
    c.typeres := a_pIni.ReadInteger(str, 'ResType', 0);
  end;
  m_WelchShift := a_pIni.ReadInteger(str, 'WelchShift', 32);
  m_WelchCount := a_pIni.ReadInteger(str, 'WelchBlockCount', 4);
  m_UseWelch := a_pIni.ReadBool(str, 'useWelch', true);
  WelchCB.Checked := m_UseWelch;
  UpdateChart;
end;

procedure savedata(dir: string; sname: string; db: TDoubleArray); overload;
var
  lname: string;
  f: file;
begin
  // временной блок
  lname := dir + '\' + sname + '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, db[0], sizeof(double) * length(db));
  closefile(f);
end;

procedure savedata(fname: string; sname: string; db: TDataBlock;
  taho: boolean); overload;
var
  lname: string;
  f: file;
  i: integer;
begin
  if not taho then
  begin
    lname := extractfiledir(fname) + '\' + 'spm_' + sname + '.dat';
    AssignFile(f, lname);
    Rewrite(f, 1);
    BlockWrite(f, db.m_mod.p, sizeof(double) * db.m_spmsize);
    closefile(f);

    lname := extractfiledir(fname) + '\' + 'frf_' + sname + '.dat';
    AssignFile(f, lname);
    Rewrite(f, 1);
    BlockWrite(f, db.m_frf[0], sizeof(double) * db.m_spmsize);
    closefile(f);
  end;
  // временной блок
  lname := extractfiledir(fname) + '\' + sname + '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, db.m_TimeBlock[0], sizeof(double) * db.m_TimeArrSize);
  closefile(f);
end;

procedure savedata(fname: string; sname: string; s: cSRSres); overload;
var
  lname: string;
  f: file;
  i: integer;
begin
  lname := extractfiledir(fname) + '\' + 'AvFRF_' + sname + '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, s.m_frf[0], sizeof(double) * length(s.m_frf));
  closefile(f);
end;

procedure savedataCoh(fld: string; sname: string; s: cSRSres); overload;
var
  lname: string;
  f: file;
  i: integer;
begin
  lname := fld + sname + '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, s.m_shockList.m_coh[0],
    sizeof(double) * length(s.m_shockList.m_coh));
  closefile(f);
end;

procedure saveHeader(ifile: TIniFile; Freq: double; start: double;
  ident: string);
begin
  WriteFloatToIniMera(ifile, ident, 'Freq', Freq);
  ifile.WriteString(ident, 'XFormat', 'R8');
  ifile.WriteString(ident, 'YFormat', 'R8');
  // Подпись оси x
  ifile.WriteString(ident, 'XUnits', 'Гц');
  // Подпись оси Y
  // ifile.WriteString(s.tagname, 'YUnits', TagUnits(wp.m_YParam.tag));
  WriteFloatToIniMera(ifile, ident, 'Start', start);
  // k0
  ifile.WriteFloat(ident, 'k0', 0);
  // k1
  ifile.WriteFloat(ident, 'k1', 1);
end;

procedure TSRSFrm.SaveBtnClick(sender: tobject);
var
  i, j, num: integer;
  ifile: TIniFile;
  f, ident, dir: string;
  c: cSpmCfg;
  t: cSRSTaho;
  s: cSRSres;
  db, tb: TDataBlock;
begin
  dir := extractfiledir(g_SRSFactory.m_meraFile) + '\Shock';
  f := dir + '\' + trimext(extractfilename(g_SRSFactory.m_meraFile))
    + '_Shocks.mera';
  while fileexists(f) do
  begin
    dir := ModName(dir, false);
    f := dir + '\' + trimext(extractfilename(g_SRSFactory.m_meraFile))
      + '_Shocks.mera';
  end;
  g_SRSFactory.m_ShockFile := f;
  ForceDirectories(dir);
  ifile := TIniFile.create(f);
  c := getTaho.cfg;
  t := getTaho;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    for j := 0 to s.m_shockList.Count - 1 do
    begin
      if j = 0 then
      begin
        db := s.m_shockList.getLastBlock;
        tb := t.m_shockList.getLastBlock;
      end
      else
      begin
        db := s.m_shockList.getPrevBlock(db);
        tb := t.m_shockList.getPrevBlock(tb);
      end;
      num := s.m_shockList.Count - j;
      // spm
      ident := 'spm_' + s.m_tag.tagname + '_' + inttostr(num);
      saveHeader(ifile, 1 / c.fspmdx, 0, ident);
      // frf
      ident := 'frf_' + s.m_tag.tagname + '_' + inttostr(num);
      saveHeader(ifile, 1 / c.fspmdx, 0, ident);
      // временной блок
      ident := s.m_tag.tagname + '_' + inttostr(num);
      if m_saveT0 then
        saveHeader(ifile, s.m_tag.Freq, db.m_timeStamp.x, ident)
      else
        saveHeader(ifile, s.m_tag.Freq, 0, ident);
      savedata(f, s.m_tag.tagname + '_' + inttostr(num), db, false);

      if i = 0 then
      begin
        ident := t.m_tag.tagname + '_' + inttostr(num);
        if m_saveT0 then
          saveHeader(ifile, t.m_tag.Freq, tb.m_timeStamp.x, ident)
        else
          saveHeader(ifile, t.m_tag.Freq, 0, ident);
        savedata(f, ident, tb, true);
      end;
    end;

    ident := 'AvFRF_' + s.m_tag.tagname;
    // ident := extractfiledir(ident) + '\'+'AvFRF_'+s.m_tag.tagname+'.dat';
    saveHeader(ifile, 1 / c.fspmdx, 0, ident);
    savedata(f, s.m_tag.tagname, s);

    ident := 'Coh_' + s.m_tag.tagname;
    saveHeader(ifile, 1 / c.fspmdx, 0, ident);
    dir := extractfiledir(g_SRSFactory.m_meraFile) + '\Shock\';
    savedataCoh(dir, ident, s);
  end;
  ifile.destroy;
end;

procedure TSRSFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
begin
  inherited;
  t := getTaho;
  if t <> nil then
  begin
    saveTagToIni(a_pIni, t.m_tag, str, 'Taho_Tag');
    WriteFloatToIniMera(a_pIni, str, 'ShiftLeft', t.m_ShiftLeft);
    WriteFloatToIniMera(a_pIni, str, 'Threshold', t.m_treshold);
    WriteFloatToIniMera(a_pIni, str, 'Length', t.m_Length);
    WriteFloatToIniMera(a_pIni, str, 'CohThreshold', t.m_CohTreshold);

    WriteFloatToIniMera(a_pIni, str, 'Spm_minX', m_minX);
    WriteFloatToIniMera(a_pIni, str, 'Spm_maxX', m_maxX);
    WriteFloatToIniMera(a_pIni, str, 'Spm_minY', m_minY);
    WriteFloatToIniMera(a_pIni, str, 'Spm_maxY', m_maxY);
    a_pIni.WriteBool(str, 'Spm_Lg_x', m_lgX);
    a_pIni.WriteBool(str, 'Spm_Lg_y', m_lgY);
    a_pIni.WriteBool(str, 'SaveT0', m_saveT0);
    a_pIni.WriteBool(str, 'TahoNewAxis', m_newAx);
    a_pIni.WriteInteger(str, 'Estimator', m_estimator);
    c := t.cfg;
    if c <> nil then
    begin
      a_pIni.WriteInteger(str, 'FFtnum', c.m_fftCount);
      a_pIni.WriteInteger(str, 'BlockCount', c.m_blockcount);
      a_pIni.WriteBool(str, 'AddNulls', c.m_addNulls);
      a_pIni.WriteInteger(str, 'SigCount', c.SRSCount);
      a_pIni.WriteInteger(str, 'ResType', c.typeres);
      a_pIni.WriteInteger(str, 'ShockCount', c.m_capacity);
      for i := 0 to c.SRSCount - 1 do
      begin
        s := c.GetSrs(i);
        saveTagToIni(a_pIni, s.m_tag, str, 'Tag_' + inttostr(i));
      end;
    end;
    a_pIni.WriteInteger(str, 'WelchBlockCount', m_WelchCount);
    a_pIni.WriteInteger(str, 'WelchShift', m_WelchShift);
    a_pIni.WriteBool(str, 'useWelch', m_UseWelch);
  end;
end;

procedure TSRSFrm.setNewAx(b: boolean);
var
  t: cSRSTaho;
  i: integer;
  a: caxis;
begin
  if b then
  begin
    if not m_newAx then
    begin
      axRef := caxis.create;
      axRef.name := 'RefAxis';
      pageT.addaxis(axRef);
      t := getTaho;
      a := caxis(t.line.parent);
      axRef.AddChild(t.line);
      // showmessage(inttostr(a.childcount));
    end;
  end;
  m_newAx := b;
end;

procedure TSRSFrm.ShowShock(shock: integer);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i, j: integer;
  block, tahobl: TDataBlock;
begin
  t := getTaho;
  if t = nil then
    exit;
  c := t.cfg;
  for i := 0 to c.m_SRSList.Count - 1 do
  begin
    s := c.GetSrs(i);
    s.lineAvFRF.visible := true;
    // for j := 0 to s.m_shockList.Count - 1 do
    if (shock < s.m_shockList.Count) and (shock > -1) then
    begin
      block := s.m_shockList.getBlock(shock);
      tahobl := t.m_shockList.getBlock(shock);

      s.line.flength := block.m_TimeArrSize;
      s.line.AddPoints(TDoubleArray(block.m_TimeBlockFlt.p),
        block.m_TimeArrSize);

      t.line.flength := tahobl.m_TimeArrSize;
      t.line.AddPoints(TDoubleArray(tahobl.m_TimeBlockFlt.p),
        tahobl.m_TimeArrSize);
      SpmChartDblClick(nil);
      fUpdateFrf := true;
      UpdateView;
    end;
  end;
end;

procedure TSRSFrm.ShowSpm;
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  b: TDataBlock;
begin
  t := getTaho;
  c := t.getCfg;
  s := c.GetSrs(PointIE.intnum);
  b := s.m_shockList.getBlock(ShockIE.intnum);
  s.lineSpm.AddPoints(TDoubleArray(b.m_mod.p), c.fHalfFft);
end;

procedure TSRSFrm.SPMcbClick(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
begin
  t := getTaho;
  c := t.getCfg;
  s := c.GetSrs(PointIE.intnum);
  s.lineFrf.visible := not SPMcb.Checked;
  s.lineAvFRF.visible := not SPMcb.Checked;
  s.lineSpm.visible := SPMcb.Checked;
  UpdateView;
end;

procedure TSRSFrm.SpmChartCursorMove(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  tb: TDataBlock;
  j: integer;
begin
  if UseWndFcb.Checked then
  begin
    if SpmChart.activePage = pageT then
    begin
      t := getTaho;
      c := t.cfg;
      t.m_shockList.m_wnd.x2 := pageT.cursor.getx2;
      if tb = nil then
        exit;
      for j := 0 to t.m_shockList.Count - 1 do
      begin
        tb := t.m_shockList.getBlock(j);
        tb.prepareData;
        tb.BuildSpm;
      end;
      tb := t.m_shockList.getBlock(ShockIE.intnum);
      t.line.AddPoints(TDoubleArray(tb.m_TimeBlockFlt.p), tb.m_TimeArrSize);
    end;
  end;
  updateFrf(false);
  UpdateView;
end;

procedure TSRSFrm.SpmChartDblClick(sender: tobject);
var
  r: frect;
  i: integer;
  a: caxis;
begin
  r.BottomLeft.x := m_minX;
  r.BottomLeft.y := m_minY;
  r.TopRight.x := m_maxX;
  r.TopRight.y := m_maxY;
  for i := 0 to pageSpm.axises.ChildCount - 1 do
  begin
    a := pageSpm.getaxis(i);
    a.ZoomfRect(r);
  end;

  for i := 0 to pageT.axises.ChildCount - 1 do
  begin
    a := pageT.getaxis(i);
    pageT.Normalise(a);
  end;
end;

procedure TSRSFrm.ShockSBDownClick(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i, j: integer;
  block, tahobl: TDataBlock;
begin
  t := getTaho;
  if t = nil then
    exit;
  c := t.cfg;
  if ShockIE.intnum > 0 then
  begin
    ShockIE.intnum := ShockIE.intnum - 1;
    ShowShock(ShockIE.intnum);
  end;
end;

procedure TSRSFrm.EvalWelchBCount;
var
  t: cSRSTaho;
  c: cSpmCfg;
  lastpos: integer;
begin
  t := getTaho;
  c := t.cfg;
  if t = nil then
    exit;
  lastpos := trunc(t.m_Length * t.m_tag.Freq) - c.m_fftCount;
  if lastpos > 0 then
    m_WelchCount := trunc(lastpos / m_WelchShift) + 1
  else
    m_WelchCount := 1;
end;

procedure TSRSFrm.ShockSBUpClick(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i, j: integer;
  block, tahobl: TDataBlock;
begin
  t := getTaho;
  if t = nil then
    exit;
  c := t.cfg;
  if ShockIE.intnum < t.m_shockList.Count - 1 then
  begin
    ShockIE.intnum := ShockIE.intnum + 1;
    ShowShock(ShockIE.intnum);
  end;
end;

procedure TSRSFrm.TestCoh;
var
  c: cSpmCfg;
  t: cSRSTaho;
  s: cSRSres;
  D1: TCmxArray_d;
  cmx: TComplex_d;
begin
  t := getTaho;
  c := t.cfg;
  s := c.GetSrs(0);

  SetLength(D1, 1);
  cmx.Re := -30.25475291;
  cmx.im := -82.46784439;
  D1[0] := cmx;
  // t.m_shockList.addBlock(@d1[0],1);
  cmx.Re := 14.69077253;
  cmx.im := -86.75400644;
  D1[0] := cmx;
  // t.m_shockList.addBlock(@d1[0],1);

  cmx.Re := -30.25475291;
  cmx.im := -82.46784439;
  D1[0] := cmx;
  // s.m_shockList.addBlock(d1,1);
  cmx.Re := -74.66651386;
  cmx.im := 45.57920805;
  D1[0] := cmx;
  // s.m_shockList.addBlock(d1,1);

  SetLength(s.m_shockList.m_Cxy, 1);
  SetLength(s.m_shockList.m_Sxx, 1);
  SetLength(s.m_shockList.m_Syy, 1);
  SetLength(s.m_shockList.m_coh, 1);
  s.m_shockList.evalCoh(t.m_shockList, hideind);
end;

{ cSRSTaho }
procedure cSRSTaho.setcfg(c: cSpmCfg);
var
  lc: cSpmCfg;
begin
  if fSpmCfgList.Count > 0 then
  begin
    lc := cSpmCfg(fSpmCfgList.Items[0]);
    lc.destroy;
    fSpmCfgList.clear;
  end;
  c.taho := self;
  m_shockList.m_cfg := c;
  fSpmCfgList.Add(c);
end;

function cSRSTaho.getCfg: cSpmCfg;
begin
  result := cSpmCfg(fSpmCfgList.Items[0]);
end;

function cSRSTaho.getCfg(i: integer): cSpmCfg;
begin
  result := cSpmCfg(fSpmCfgList.Items[i]);
end;

function cSRSTaho.CfgCount: integer;
begin
  result := fSpmCfgList.Count;
end;

function cSRSTaho.corrLen: double;
var
  c: cSpmCfg;
begin
  c := getCfg;
  result := m_shockList.m_wnd.x2;
end;

constructor cSRSTaho.create;
begin
  inherited;
  m_treshold := 1;
  m_CohTreshold := 0.5;
  // отступ слева и длительность
  m_ShiftLeft := 0.05;
  m_Length := 1;
  m_tag := ctag.create;
  fSpmCfgList := tlist.create;

  m_shockList := TDataBlockList.create;
end;

destructor cSRSTaho.destroy;
begin
  m_tag.destroy;
  fSpmCfgList.destroy;
  m_shockList.destroy;
  inherited;
end;

procedure cSRSTaho.evalCoh(hideind: integer);
var
  i, shockCount: integer;
  c: cSpmCfg;
  s: cSRSres;
  len: double;
begin
  c := cfg;
  shockCount := m_shockList.Count;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    // getCommonInterval(s., t.TrigInterval);
    // ComIntervalLen:=common_interval.y-common_interval.x;
    if (shockCount = s.m_shockList.Count) and
      (m_shockList.m_LastBlock = s.m_shockList.m_LastBlock) then
    begin
      s.m_shockList.evalCoh(m_shockList, hideind);
      s.lineCoh.AddPoints(s.m_shockList.m_coh, c.fHalfFft);
    end
    else // число блоков в T и S разбежалось
    begin
      // showmessage('taho:'+ inttostr(shockCount)+' s:'+inttostr(s.m_shockList.Count));
    end;
  end;
end;

// результат
procedure cSRSTaho.evalWelchSpm(tb, sb: TDataBlock);
var
  i, halfNP: integer;
  k: double;
  plan: TFFTProp;
  c: cSpmCfg;
  j: integer;
begin
  c := getCfg;
  plan := cSpmCfg(c).FFTProp;
  plan.StartInd := 0;
  // расчет первого спектра
  // k := 2 / (c.m_fftCount);
  halfNP := c.m_fftCount shr 1;
  ZeroMemory(@sb.m_WechSpm[0], length(sb.m_WechSpm) * sizeof(TComplex_d));
  ZeroMemory(@tb.m_WechSpm[0], length(tb.m_WechSpm) * sizeof(TComplex_d));
  for i := 0 to TSRSFrm(m_frm).m_WelchCount - 1 do
  begin
    fft_al_d_sse(TDoubleArray(tb.m_TimeBlockFlt.p),
      TCmxArray_d(tb.m_ClxData.p), plan);
    // MULT_SSE_al_cmpx_d(TCmxArray_d(tb.m_ClxData.p), k);
    fft_al_d_sse(TDoubleArray(sb.m_TimeBlockFlt.p),
      TCmxArray_d(sb.m_ClxData.p), plan);
    // MULT_SSE_al_cmpx_d(TCmxArray_d(sb.m_ClxData.p), k);
    plan.StartInd := TSRSFrm(m_frm).m_WelchShift + plan.StartInd;
    for j := 0 to halfNP - 1 do
    begin
      sb.m_WechSpm[j] := sb.m_WechSpm[j] + TCmxArray_d(sb.m_ClxData.p)[j];
      tb.m_WechSpm[j] := tb.m_WechSpm[j] + TCmxArray_d(tb.m_ClxData.p)[j];
    end;
  end;
  k := 2 / (c.m_fftCount * TSRSFrm(m_frm).m_WelchCount);
  // нормировка
  for i := 0 to halfNP - 1 do
  begin
    sb.m_WechSpm[i] := sb.m_WechSpm[i] * k;
    TDoubleArray(sb.m_mod.p)[i] := abs(sb.m_WechSpm[i]);
    tb.m_WechSpm[i] := tb.m_WechSpm[i] * k;
    TDoubleArray(tb.m_mod.p)[i] := abs(tb.m_WechSpm[i]);
  end;
end;

procedure cSRSTaho.evalWelchFrf(estimator: integer);
var
  i, j, k, shockCount: integer;
  c: cSpmCfg;
  s: cSRSres;
  td, sd: TDataBlock;
  v1, v2: double;
  cross, px, py: TComplex_d;
begin
  c := cfg;
  shockCount := m_shockList.Count;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    td := nil;
    sd := nil;
    ZeroMemory(s.m_shockList.m_Cxy,
      length(s.m_shockList.m_Cxy) * sizeof(TComplex_d));
    ZeroMemory(s.m_shockList.m_Sxx,
      length(s.m_shockList.m_Cxy) * sizeof(double));
    ZeroMemory(s.m_shockList.m_Syy,
      length(s.m_shockList.m_Cxy) * sizeof(double));
    for k := 0 to s.m_shockList.Count - 1 do
    begin
      td := m_shockList.getBlock(k);
      sd := s.m_shockList.getBlock(k);
      evalWelchSpm(td, sd);
      for j := 0 to c.fHalfFft - 1 do
      begin
        s.m_shockList.m_Cxy[j] := s.m_shockList.m_Cxy[j] + sd.m_WechSpm[j]
          * sopr(td.m_WechSpm[j]);
        cross := td.m_WechSpm[j] * sopr(td.m_WechSpm[j]);
        s.m_shockList.m_Sxx[j] := s.m_shockList.m_Sxx[j] + cross;

        cross := sd.m_WechSpm[j] * sopr(sd.m_WechSpm[j]);
        s.m_shockList.m_Syy[j] := s.m_shockList.m_Syy[j] + cross;

        sd.m_frf[j] := TDoubleArray(sd.m_mod.p)[j] / TDoubleArray(td.m_mod.p)
          [j];
      end;
    end;
    // усредняем
    case estimator of
      0: // без использования фазы
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            s.m_phase[j] := (180 / pi) * s.m_shockList.m_Cxy[j]
              .im / s.m_shockList.m_Cxy[j].Re;
            // Sensor/Taho
            s.m_frf[j] := sqrt(s.m_shockList.m_Syy[j] / s.m_shockList.m_Sxx[j]);
          end;
        end;
      1: // H1 Syx/Sxx  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            s.m_frf[j] := abs(s.m_shockList.m_Cxy[j]) / s.m_shockList.m_Sxx[j];
          end;
        end;
      2: // H1 Syy/Sxy  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            s.m_frf[j] := s.m_shockList.m_Syy[j] / abs(s.m_shockList.m_Cxy[j]);
          end;
        end;
    end;
  end;
end;

// taho - знаменатель
procedure cSRSTaho.evalFRF(hideind: integer; estimator: integer;
  rebuildspm: boolean);
var
  i, k, shockCount: integer;
  c: cSpmCfg;
  s: cSRSres;
  td, sd: TDataBlock;
  j: integer;
  v1, v2: double;
  cross, px, py: TComplex_d;
begin
  c := cfg;
  shockCount := m_shockList.Count;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    ZeroMemory(s.m_frf, length(s.m_frf) * sizeof(double));
    ZeroMemory(s.m_shockList.m_Cxy,
      length(s.m_shockList.m_Cxy) * sizeof(TComplex_d));
    td := nil;
    sd := nil;
    for k := 0 to s.m_shockList.Count - 1 do
    begin
      if k = hideind then
      begin
        dec(shockCount);
        continue;
      end;
      td := m_shockList.getBlock(k);
      sd := s.m_shockList.getBlock(k);
      if rebuildspm then
      begin
        td.BuildSpm;
        sd.BuildSpm;
      end;
      // без использования фазы   y/x. x - тахо
      for j := 0 to c.fHalfFft - 1 do
      begin
        v1 := TDoubleArray(sd.m_mod.p)[j];
        v2 := TDoubleArray(td.m_mod.p)[j];
        if v2 <> 0 then
          sd.m_frf[j] := v1 / v2
        else
          sd.m_frf[j] := 1000000;
        if estimator = 0 then
          s.m_frf[j] := sd.m_frf[j] + s.m_frf[j];
      end;
    end;
    // усредняем
    case estimator of
      0: // без использования фазы
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            s.m_phase[j] := (180 / pi) * s.m_shockList.m_Cxy[j]
              .im / s.m_shockList.m_Cxy[j].Re;
            // if s.m_shockList.m_coh[j] < m_CohTreshold then
            if false then
            begin
              s.m_frf[j] := 0;
            end
            else
            begin
              s.m_frf[j] := s.m_frf[j] / shockCount;
            end;
          end;
        end;
      1: // H1 Syx/Sxx  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            cross := 0;
            v2 := 0;
            for k := 0 to s.m_shockList.Count - 1 do
            begin
              if k = hideind then
              begin
                continue;
              end;
              td := m_shockList.getBlock(k);
              sd := s.m_shockList.getBlock(k);
              px := TCmxArray_d(td.m_ClxData.p)[j];
              py := TCmxArray_d(sd.m_ClxData.p)[j];
              cross := py * sopr(px) + cross;
              v2 := td.m_mod2[j] + v2;
            end;
            s.m_frf[j] := abs(cross) / v2;
          end;
        end;
      2: // H1 Syy/Sxy  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            cross := 0;
            v1 := 0;
            for k := 0 to s.m_shockList.Count - 1 do
            begin
              if k = hideind then
              begin
                continue;
              end;
              td := m_shockList.getBlock(k);
              sd := s.m_shockList.getBlock(k);

              px := TCmxArray_d(td.m_ClxData.p)[j];
              py := TCmxArray_d(sd.m_ClxData.p)[j];
              cross := px * sopr(py) + cross;
              v1 := sd.m_mod2[j] + v1;
            end;
            s.m_frf[j] := v1 / abs(cross);
          end;
        end;
    end;
  end;
end;

procedure cSRSTaho.resetTrig;
var
  c: cSpmCfg;
  i: integer;
  s: cSRSres;
begin
  c := cfg;
  // ZeroMemory(m_T1data.p,  c.m_fftCount* sizeof(double));
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    s.fComIntervalLen := 0;
    // ZeroMemory(s.m_T1data.p,  c.m_fftCount* sizeof(double));
  end;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    s.m_shockProcessed := false;
  end;
  fTrigState := TrOff;
end;

function cSRSTaho.name: string;
begin
  result := m_tag.tagname;
end;

{ сSpmCfg }
procedure cSpmCfg.setWnd(wf: TSpmWndFunc; x1, x2, y: double);
var
  ls: cSRSres;
  t: cSRSTaho;
  i: integer;
begin
  t := cSRSTaho(taho);
  for i := 0 to m_SRSList.Count - 1 do
  begin
    ls := cSRSres(m_SRSList.Items[i]);
    ls.m_shockList.m_wnd.wndfunc := wf;
    ls.m_shockList.m_wnd.x1 := x1;
    ls.m_shockList.m_wnd.x2 := x2;
    ls.m_shockList.m_wnd.y := y;
  end;
end;

procedure cSpmCfg.setWnd(wf: TSpmWndFunc);
var
  ls: cSRSres;
  t: cSRSTaho;
  i: integer;
begin
  t := cSRSTaho(taho);
  for i := 0 to m_SRSList.Count - 1 do
  begin
    ls := cSRSres(m_SRSList.Items[i]);
    ls.m_shockList.m_wnd.wndfunc := wf;
  end;
end;

procedure cSpmCfg.addSRS(s: pointer);
var
  i: integer;
  ls: cSRSres;
  t: itag;
begin
  if GetObjectClass(s) = nil then
  begin
    if Supports(itag(pointer(s)), IID_ITAG) then
    begin
      t := itag(pointer(s));
      for i := 0 to m_SRSList.Count - 1 do
      begin
        ls := cSRSres(m_SRSList.Items[i]);
        if t = ls.m_tag.tag then
          exit;
      end;
      ls := cSRSres.create;
      ls.m_tag.tag := t;
      ls.cfg := self;
      m_SRSList.Add(ls);
    end
  end
  else
  begin
    if tobject(s) is cSRSres then
    begin
      for i := 0 to m_SRSList.Count - 1 do
      begin
        ls := cSRSres(m_SRSList.Items[i]);
        if s = ls then
          exit;
      end;
      m_SRSList.Add(s);
    end;
    if tobject(s) is ctag then
    begin
      for i := 0 to m_SRSList.Count - 1 do
      begin
        ls := cSRSres(m_SRSList.Items[i]);
        if ctag(s).tagname = ls.m_tag.tagname then
        begin
          ctag(s).destroy;
          exit;
        end;
      end;
      ls := cSRSres.create;
      ls.m_tag := ctag(s);
      ls.cfg := self;
      m_SRSList.Add(ls);
    end;
  end;
end;

constructor cSpmCfg.create;
begin
  m_SRSList := tlist.create;
  m_fftCount := 32;
  m_blockcount := 1;
  m_addNulls := false;
  m_capacity := 5;
  if taho <> nil then
    cSRSTaho(taho).m_shockList.m_wnd.wndfunc := wnd_no;
end;

destructor cSpmCfg.destroy;
begin
  m_SRSList.destroy;
end;

function cSpmCfg.Freq: double;
begin
  result := cSRSTaho(taho).m_tag.Freq;
end;

function cSpmCfg.GetSrs(i: integer): cSRSres;
begin
  result := cSRSres(m_SRSList.Items[i]);
end;

function cSpmCfg.name: string;
begin
  result := cSRSTaho(taho).name + '_FFTp=' + inttostr(FFTProp.pcount);
end;

procedure cSpmCfg.settyperes(t: integer);
var
  i: integer;
  s: cSRSres;
  b: boolean;
  ltaho: cSRSTaho;
begin
  ftypeRes := t;
  for i := 0 to SRSCount - 1 do
  begin
    s := GetSrs(i);
    b := t = c_FRF;
    if s.lineSpm <> nil then
      s.lineSpm.visible := not b;
    if s.lineFrf <> nil then
      s.lineFrf.visible := b;
  end;
  if taho <> nil then
  begin
    ltaho := cSRSTaho(taho);
    if ltaho.lineSpm <> nil then
    begin
      ltaho.lineSpm.visible := not b;
    end;
  end;
end;

function cSpmCfg.SRSCount: integer;
begin
  result := m_SRSList.Count;
end;

{ cSRSres }
constructor cSRSres.create;
begin
  m_tag := ctag.create;
  m_shockList := TDataBlockList.create;
  m_shockList.m_wnd.wndfunc := wnd_no;
  m_shockList.m_wnd.x1 := 0;
  m_shockList.m_wnd.x2 := 1;
end;

destructor cSRSres.destroy;
begin
  m_tag.destroy;
  m_shockList.destroy;
end;

function cSRSres.name: string;
begin
  result := m_tag.tagname;
end;

procedure cSRSres.setcfg(c: cSpmCfg);
begin
  fcfg := c;
  m_shockList.m_cfg := c;
end;

{ cSRSFactory }
procedure cSRSFactory.createevents;
begin
  addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cSRSFactory_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
end;

constructor cSRSFactory.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_SRS;
  createevents;
end;

destructor cSRSFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cSRSFactory.destroyevents;
begin

end;

procedure cSRSFactory.doAfterLoad;
begin
  inherited;
end;

procedure cSRSFactory.doChangeRState(sender: tobject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
      end;
    RSt_StopToView:
      begin
        g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_StopToRec:
      begin
        g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_ViewToStop:
      begin
        doStop;
      end;
    RSt_ViewToRec:
      begin
        g_SRSFactory.m_meraFile := GetMeraFile;
      end;
    RSt_initToRec:
      begin
        g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_initToView:
      begin
        g_SRSFactory.m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_RecToStop:
      begin
        doStop;
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cSRSFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := ISRSFrm.create();
  end;
end;

procedure cSRSFactory.doDestroyForms;
begin
  inherited;

end;

procedure cSRSFactory.doRecorderInit;
var
  i, j: integer;
  Frm: TRecFrm;
  s: cSRSres;
  t: cSRSTaho;
  c: cSpmCfg;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    t := TSRSFrm(Frm).getTaho;
    if t.m_tag.tag = nil then
      t.m_tag.tag := getTagByName(t.m_tag.tagname);
    for j := 0 to t.cfg.SRSCount - 1 do
    begin
      s := t.cfg.GetSrs(j);
      if s.m_tag.tag = nil then
        t.m_tag.tag := getTagByName(t.m_tag.tagname);
    end;
    TSRSFrm(Frm).UpdateBlocks;
  end;

end;

procedure cSRSFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
end;

procedure cSRSFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TSRSFrm(Frm).doStart;
  end;
end;

function getSubNameFromFolder(fld: string): string;
var
  i, l: integer;
  str: string;
begin
  result := '';
  l := length(fld);
  for i := length(fld) downto 1 do
  begin
    if fld[i] = '\' then
    begin
      str := Copy(fld, i + 1, l - i - 1);
      if isValue(str) then
      begin
        l := i;
      end
      else
      begin
        result := str;
        exit;
      end;
    end;
  end;
end;

procedure TSRSFrm.SaveMdbBtnClick(sender: tobject);
var
  o: cObjFolder;
  t: cTestFolder;
  path: string;

  i, j, num: integer;
  ifile: TIniFile;
  f, ident, dir, sname, last, subname: string;
  c: cSpmCfg;
  taho: cSRSTaho;
  s: cSRSres;
  b: boolean;
begin
  if g_MBaseControl <> nil then
  begin
    o := g_MBaseControl.GetSelectObj;
    t := g_MBaseControl.GetSelectTest;
    if o <> nil then
    begin
      path := g_mbase.m_BaseFolder.Absolutepath; ;
      ForceDirectories(path + '\FrfTypes');
      if o.ObjType <> '' then
      begin
        path := path + '\FrfTypes' + '\' + o.ObjType;
        ForceDirectories(path);

        taho := getTaho;
        c := taho.cfg;
        s := c.GetSrs(0);
        if s = nil then
          exit;
        sname := s.m_tag.tagname + '_p№' + '0' + '_frf.dat';
        f := path + '\' + sname;
        b := false;
        while isOpen(f) do
        begin
          subname := getSubNameFromFolder(path);
          if not b then
          begin
            if subname <> 'Sub' then
            begin
              path := path + '\Sub';
              b := true;
            end;
          end
          else
          begin
            path := ModName(path, false, last);
          end;
          f := path + '\' + sname;
        end;
        if b then
        begin
          ForceDirectories(path);
        end;
        sname := 'frf.mera';
        f := path + '\' + sname;
        m_lastMDBfile := f;

        ifile := TIniFile.create(f);
        for i := 0 to c.SRSCount - 1 do
        begin
          s := c.GetSrs(i);
          sname := s.m_tag.tagname + '_p№' + inttostr(PointIE.intnum) + '_frf';
          ident := sname;
          saveHeader(ifile, 1 / c.fspmdx, 0, ident);
          savedata(path, sname, s.m_frf);

          sname := s.m_tag.tagname + '_p№' + inttostr(PointIE.intnum)
            + '_phase';
          ident := sname;
          saveHeader(ifile, 1 / c.fspmdx, 0, ident);
          savedata(path, sname, s.m_phase);

          ifile.destroy;
        end;
      end;
    end;
  end;
end;

procedure cSRSFactory.doStop;
var
  mdb: boolean;
  path: string;
  i: integer;
  f: TSRSFrm;
begin
  mdb := false;
  if g_MBaseControl <> nil then
  begin
    path := getMDBTestPath;
    if directoryexists(path) then
    begin
      mdb := true;
    end;
  end;
  for i := 0 to Count - 1 do
  begin
    f := TSRSFrm(GetFrm(i));
    if mdb then
    begin
      f.SaveMdbPan.color := clGreen;
    end
    else
    begin
      f.SaveMdbPan.color := clBtnFace;
    end
  end;
end;

procedure cSRSFactory.doUpdateData(sender: tobject);
var
  i: integer;
  Frm: TRecFrm;
begin
  if g_disableFRF then
    exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TSRSFrm(Frm).updatedata;
  end;
end;

{ ISRSFrm }

procedure ISRSFrm.doClose;
begin
  m_lRefCount := 1;
end;

function ISRSFrm.doCreateFrm: TRecFrm;
begin
  result := TSRSFrm.create(nil);
end;

function ISRSFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function ISRSFrm.doRepaint: boolean;
begin
  inherited;
  TSRSFrm(m_pMasterWnd).UpdateView;
end;

{ TDataBlock }

procedure TDataBlock.BuildSpm;
var
  k, v: double;
  c: cSpmCfg;
  t: cSRSTaho;
  maxT, maxS: double;
  i, halfNP: integer;
begin
  c := TDataBlockList(m_owner).m_cfg;
  fft_al_d_sse(TDoubleArray(m_TimeBlockFlt.p), TCmxArray_d(m_ClxData.p),
    cSpmCfg(c).FFTProp);
  // расчет первого спектра
  k := 2 / c.m_fftCount;
  halfNP := c.m_fftCount shr 1;
  MULT_SSE_al_cmpx_d(TCmxArray_d(m_ClxData.p), k);
  evalmod2;
  EvalSpmMag(TCmxArray_d(m_ClxData.p), TDoubleArray(m_mod.p));
end;

procedure TDataBlock.evalmod2;
var
  i: integer;
  c: TComplex_d;
begin
  for i := 0 to m_spmsize - 1 do
  begin
    c := sopr(TCmxArray_d(m_ClxData.p)[i]);
    c := TCmxArray_d(m_ClxData.p)[i] * c;
    m_mod2[i] := c.Re;
  end;
end;

function TDataBlock.getsize: integer;
begin
  result := m_spmsize;
end;

function TDataBlock.index: integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to m_owner.Count - 1 do
  begin
    if TDataBlockList(m_owner).getBlock(i) = self then
    begin
      result := i;
      exit;
    end;
  end;
end;

procedure TDataBlock.setsize(s: integer);
begin
  m_spmsize := s shr 1;
  SetLength(m_frf, m_spmsize);
  SetLength(m_Cxy, m_spmsize);
  SetLength(m_WechSpm, m_spmsize);
  SetLength(m_mod2, m_spmsize);
end;

function TDataBlock.TahoFreq: double;
begin
  result := TDataBlockList(m_owner).m_cfg.Freq;
end;

{ TDataBlockList }
function TDataBlockList.addBlock(p_spmsize: integer): TDataBlock;
var
  db: TDataBlock;
begin
  inc(m_shockCount);
  if (Count = m_cfg.m_capacity) and (m_cfg.m_capacity > 0) then
  begin
    m_LastBlock := m_LastBlock + 1;
    if m_LastBlock = m_cfg.m_capacity then
      m_LastBlock := 0;
    db := getBlock(m_LastBlock);
    // как будто добавили блок, соотв. сбрасываем показатель готовности
    db.m_connectedInd := -1;
  end
  else
  begin
    db := TDataBlock.create;
    db.spmsize := p_spmsize;
    m_LastBlock := Add(db);
  end;
  // system.move(TCmxArray_d(cpx_spm_data)[0], db.m_spm[0], dsize*sizeof(TComplex_d));
  // db.evalmod2;
  db.m_owner := self;
  result := db;
end;

function TDataBlockList.addBlock(p_spmsize: integer; time: point2d; // timestamp
  // timeblock
  tb: TDoubleArray;
  // размер очередного блока
  p_timesize: integer): TDataBlock;
begin
  result := addBlock(p_spmsize);
  result.m_timeStamp := time;
  // дополняем нулями
  if p_timesize < p_spmsize then
  begin
    // zeromem???
    p_timesize := p_spmsize;
  end;
  if p_timesize > result.m_timecapacity then
  begin
    SetLength(result.m_TimeBlock, p_timesize);
    result.m_timecapacity := p_timesize;
    GetMemAlignedArray_d(p_timesize, result.m_TimeBlockFlt);
  end;
  GetMemAlignedArray_cmpx_d(p_spmsize, result.m_ClxData);
  GetMemAlignedArray_d(p_spmsize, result.m_mod);
  // src/ dst/ count
  system.move(tb[0], result.m_TimeBlock[0], p_timesize * sizeof(double));
  result.m_TimeArrSize := p_timesize;
end;

procedure TDataBlock.prepareData;
var
  i, j, n: integer;
  x, dx, m: double;
  wnd: TSpmWnd;
begin
  system.move(m_TimeBlock[0], TDoubleArray(m_TimeBlockFlt.p)[0],
    m_TimeArrSize * sizeof(double));
  wnd := TDataBlockList(m_owner).m_wnd;
  case wnd.wndfunc of
    wnd_rect:
      begin
        i := round(wnd.x2 * TahoFreq);
        n := m_TimeArrSize - i;
        if n > 0 then
          ZeroMemory(@TDoubleArray(m_TimeBlockFlt.p)[i], n * sizeof(double));
      end;
    wnd_exp:
      begin
        j := round(wnd.x1 * TahoFreq);
        if j < 0 then
          j := 0;
        n := m_TimeArrSize - j;
        dx := 1 / TDataBlockList(m_owner).m_cfg.Freq;
        x := wnd.x1;
        m := mean(m_TimeBlock);
        for i := 1 to n - 1 do
        begin
          x := x + dx;
          if wnd.y = 0 then
            wnd.y := 0.000001;
          TDoubleArray(m_TimeBlockFlt.p)[i + j] := m + (m_TimeBlock[i + j] - m)
            * exp(ln(wnd.y) * (x - wnd.x1) / (wnd.x2 - wnd.x1));
        end;
      end;
  end;
end;

procedure TDataBlockList.clearData;
var
  d: TDataBlock;
  i, l: integer;
begin
  m_shockCount := 0;
  l := length(m_Cxy);
  if l > 0 then
  begin
    ZeroMemory(m_Cxy, l * (sizeof(TComplex_d)));
    ZeroMemory(m_Sxx, l * (sizeof(double)));
    ZeroMemory(m_Syy, l * (sizeof(double)));
  end;
  for i := 0 to Count - 1 do
  begin
    d := TDataBlock(Items[i]);
    d.destroy;
  end;
  clear;
end;

constructor TDataBlockList.create;
begin
  inherited;
end;

procedure TDataBlockList.delBlock(db: TDataBlock);
var
  i: integer;
  bl: TDataBlock;
begin
  for i := 0 to Count - 1 do
  begin
    bl := getBlock(i);
    if bl = db then
    begin
      Delete(i);
      db.destroy;
      if m_LastBlock > i then
      begin
        dec(m_LastBlock);
        exit;
      end
      else
      begin

      end;
    end;
  end;
end;

destructor TDataBlockList.destroy;
begin
  clearData;
  inherited;
end;

procedure TDataBlockList.evalCoh(TahoShockList: TDataBlockList;
  hideind: integer);
var
  i, j, n, len: integer;
  s, t: TDataBlock;
  p1, p2: TComplex_d;
  k: double;
begin
  n := Count;
  if n = 0 then
    exit;

  len := length(m_coh);
  if len > 0 then
  begin
    ZeroMemory(m_Cxy, len * (sizeof(TComplex_d)));
    ZeroMemory(m_Sxx, len * (sizeof(double)));
    ZeroMemory(m_Syy, len * (sizeof(double)));
  end;
  for i := 0 to Count - 1 do
  begin
    if i = hideind then
    begin
      continue;
      dec(n);
    end;
    s := getBlock(i);
    t := TahoShockList.getBlock(i);
    for j := 0 to s.m_spmsize - 1 do // проход по спектру
    begin
      p1 := TCmxArray_d(s.m_ClxData.p)[j];
      p2 := sopr(TCmxArray_d(t.m_ClxData.p)[j]);
      // для H1 Cxy
      s.m_Cxy[j] := p1 * p2;
      m_Cxy[j] := s.m_Cxy[j] + m_Cxy[j];
      m_Sxx[j] := s.m_mod2[j] + m_Sxx[j];
      m_Syy[j] := t.m_mod2[j] + m_Syy[j];
    end;
  end;
  k := 1 / (n);
  for j := 0 to s.m_spmsize - 1 do
  begin
    m_coh[j] := mod2(m_Cxy[j]) / (m_Sxx[j] * m_Syy[j]);
    // делаем средний кросс спектр
    m_Cxy[j] := m_Cxy[j] * k;
  end;
end;

function TDataBlockList.getBlock(i: integer): TDataBlock;
begin
  result := nil;
  if i < Count then
    result := TDataBlock(Items[i]);
end;

function TDataBlockList.getLastBlock: TDataBlock;
begin
  result := getBlock(m_LastBlock);
end;

function TDataBlockList.getLastBlock(d: TDataBlock): TDataBlock;
begin
  if d = nil then
    result := getLastBlock
  else
    result := getPrevBlock(d);
end;

function TDataBlockList.getPrevBlock(d: TDataBlock): TDataBlock;
var
  i: integer;
begin
  if d = nil then
  begin
    result := getLastBlock;
  end
  else
  begin
    i := d.index - 1;
    if i < 0 then
    begin
      i := Count - 1;
    end;
    result := getBlock(i);
  end;
end;

{ cExpFuncObj }
procedure cExpFuncObj.compile;
var
  a: caxis;
  p: cpage;
  i: integer;
  isize: tpoint;
  bsize: point2;
  x, dx, xmax, y: single;
begin
  if m_needRecompile then
  begin
    a := caxis(parent);
    p := cpage(GetPage);
    if a.Lg or p.LgX then
    begin
      // CompileLineLg;
    end
    else
    begin
      a := caxis(parent);
      p := cpage(GetPage);
      if a.Lg or p.LgX then
      begin
        inherited;
      end
      else
      begin
        EvalBound;
        EvalA;
        // подготовка к компиляции списка
        m_DisplayListName := glGenLists(1);
        glNewList(m_DisplayListName, GL_COMPILE);
        glLineWidth(m_weight);
        xmax := a.max.x;
        // марке на x0y0
        dx := (xmax - m_x0) / m_count;
        i := 0;
        // x := i * dx - m_x0;
        x := i * dx;
        glBegin(GL_LINE_STRIP);
        glVertex2f((x + m_x0), fdy * system.exp(-x * fA) + faxmin);
        for i := 1 to m_count - 1 do
        begin
          x := x + dx;
          glVertex2f((x + m_x0), fdy * system.exp(-x * fA) + faxmin);
        end;
        glEnd;
        // отрисовка ползунка
        isize.x := 15;
        isize.y := 15;
        bsize := p.PixelSizeToTrend(isize, a);
        bsize.x := bsize.x * 0.5;
        bsize.y := bsize.y * 0.5;
        y := fy0; // - fdy005;
        glBegin(GL_LINE_STRIP);
        glVertex2f(m_x0 - bsize.x, y - bsize.y);
        glVertex2f(m_x0 - bsize.x, y + bsize.y);
        glVertex2f(m_x0 + bsize.x, y + bsize.y);
        glVertex2f(m_x0 + bsize.x, y - bsize.y);
        glVertex2f(m_x0 - bsize.x, y - bsize.y);
        glEnd;
        // марке на x1y1
        y := fy1; // + fdy005;
        glBegin(GL_LINE_STRIP);
        glVertex2f(m_x1 - bsize.x, y - bsize.y);
        glVertex2f(m_x1 - bsize.x, y + bsize.y);
        glVertex2f(m_x1 + bsize.x, y + bsize.y);
        glVertex2f(m_x1 + bsize.x, y - bsize.y);
        glVertex2f(m_x1 - bsize.x, y - bsize.y);
        glEnd;
        glEndList;
        // p.Caption:=floattostr(fy1);
      end;
    end;
    m_needRecompile := false;
  end;
end;

constructor cExpFuncObj.create;
begin
  inherited;
  color := orange;
  m_count := 200;
  fA := 1;
  m_x0 := 0;
  m_x1 := 1;
  m_weight := 1;
  m_needRecompile := true;
  m_DisplayListName := 0;
  EvalA;
  EvalBound;
  locked := false;
end;

destructor cExpFuncObj.destroy;
begin
  inherited;
end;

procedure cExpFuncObj.doOnUpdateParams;
begin
  if assigned(fUpdateParams) then
    fUpdateParams(self);
end;

procedure cExpFuncObj.doUpdateWorldSize(sender: tobject);
var
  p: cpage;
  a: caxis;
begin
  inherited;
  p := cpage(GetPage);
  a := caxis(parent);
  if a = sender then
  begin
    faxmin := a.minY;
    fdy := a.maxY - a.minY;
    fdy005 := 0.05 * fdy;
    fy0 := a.maxY;
    fy1 := fdy * m_y1 + faxmin;

    m_needRecompile := true;
  end;
end;

procedure cExpFuncObj.drawdata;
var
  oldweight: single;
begin
  inherited;
  if m_needRecompile then
    compile;
  // GL_LINE_WIDTH_RANGE GL_LINE_WIDTH_GRANULARITY
  // glGetDoubleV(GL_LINE_WIDTH,@oldweight);
  glLineWidth(m_weight);
  glCallList(m_DisplayListName);
  // glLineWidth(oldweight);
end;

procedure cExpFuncObj.EvalA;
var
  lnx: double;
begin
  if m_y1 < 0.000001 then
    lnx := -10
  else
    lnx := ln(m_y1);
  fA := -lnx / (m_x1 - m_x0);
end;

procedure cExpFuncObj.EvalBound;
var
  a: caxis;
  p: cpage;
begin
  a := caxis(parent);
  p := cpage(GetPage);

  boundrect.BottomLeft.x := m_x0;
  boundrect.TopRight.x := m_x1;
  boundrect.BottomLeft.y := fy1;
  boundrect.TopRight.y := fy0;
end;

function cExpFuncObj.getScale(x: double): double;
begin
  // (x+m_x0), ymax*system.Exp(-x * fA)
  result := system.exp(-(x - m_x0) * fA);
end;

procedure cExpFuncObj.SetParams(x0, x1, y1: double);
begin
  m_x0 := x0;
  m_x1 := x1;
  m_y1 := m_y1;
  EvalA;
  EvalBound;
  m_needRecompile := true;
end;

procedure cExpFuncObj.SetPos(p: point2);
begin
  case fTestObj of
    0:
      ;
    1:
      begin
        m_x0 := p.x;
      end;
    2:
      begin
        m_x1 := p.x;
        m_y1 := (p.y - faxmin) / fdy;
        fy1 := fdy * m_y1 + faxmin;
      end;
  end;
  doOnUpdateParams;
  m_needRecompile := true;
end;

function cExpFuncObj.TestObj(p_p2: point2; dist: single): boolean;
var
  i: integer;
  lDist: single;
  lp2: point2;
begin
  fTestObj := 0;

  lp2.x := p_p2.x - m_x1;
  lp2.y := p_p2.y - fy1;
  lDist := sqrt(lp2.x * lp2.x + lp2.y * lp2.y);
  dist := dist * 2;
  if lDist < dist then
  begin
    fTestObj := 2;
    result := true;
    exit;
  end;

  lp2.x := p_p2.x - m_x0;
  lp2.y := p_p2.y - fy0;
  lDist := sqrt(lp2.x * lp2.x + lp2.y * lp2.y);
  if lDist < dist then
  begin
    fTestObj := 1;
    result := true;
  end;
end;

end.
