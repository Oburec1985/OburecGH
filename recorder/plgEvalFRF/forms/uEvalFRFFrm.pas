unit uEvalFRFFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  uComponentServises,
  Forms, ComCtrls,
  uRecBasicFactory,
  uCommonMath, MathFunction, u2DMath,
  uRecorderEvents,
  uChart,
  inifiles,
  upage,
  tags,
  complex,
  uTextLabel,
  uBuffTrend1d, utrend, uaxis, uYCursor,
  uCommonTypes,
  pluginClass,
  shellapi,
  uPathMng,
  opengl, uSimpleObjects,
  math, uDrawObj, uDoubleCursor, uBasicTrend, uProfile, uExcel,
  uBladeDB, uSpmBand, uChartEvents,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons, uBtnListView, uSpin;

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
    // y1 - значение экспоненты для x1 (например 0,1 шкалы)
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
    // true - sres/taho
  protected
    function TestObj(p_p2: point2; dist: single): boolean; override;
    // пересчитать границы
    procedure EvalBound; override;
    procedure EvalA;
    procedure compile;
    procedure drawdata; override;
    procedure SetPos(p: point2); override;
    function GetPos: point2; override;
    procedure doOnUpdateParams;
  public
    // происходит когда обновился масштаб оси объекта
    procedure doUpdateWorldSize(sender: tobject); override;
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
    // используется для Датчика. Хранит номер блока данных Тахо
    m_connectedInd: integer;

    m_timeMax: double; // время отметки в ударе
    m_timeStamp: point2d;
    m_timecapacity: integer; // вместимость для осцилограммы
    // размер для m_TimeBlock
    m_TimeArrSize: integer;
    m_spmsize: integer;
    addnull: boolean;
    // усредненнй спектр
    m_WechSpm: TCmxArray_d;
    m_Cxy: TCmxArray_d;
    m_frf, m_mod2 // спектр амплитуд квадрат
      : TDoubleArray; // спектр амплитуд
    // исходный массив данных для расчета удара
    m_TimeBlock: TDoubleArray;
    // спектр амплитуд.
    m_mod,
    // блок данных по которому идет расчет спектра. (с учетом окна)
    m_TimeBlockFlt, m_TimeBlockFltNull: TAlignDarray;
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
    constructor create;
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
    // получить блок по максимуму в ударе
    function getBlock(tstamp: double): TDataBlock; overload;
    function getBlock(i: integer): TDataBlock; overload;
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
    // разрешение спектра
    fspmdx: double;
  private
    ftypeRes: integer;
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
    function addSRS(s: pointer): cSRSres;
    procedure delSRS(s: tobject);
    function GetSrs(i: integer): cSRSres; overload;
    function GetSrs(s: string): cSRSres; overload;
    function SRSCount: integer;
    // частота дискретизации сигнала
    function Freq: double;
    function name: string;
    property typeres: integer read ftypeRes write settyperes;
    constructor create;
    destructor destroy;
  end;

  cSRSTaho = class;

  cSRSres = class
  public
    m_tag: ctag;
  public
    m_color: point3;
    m_colorAlt: point3;
    // m_freq: double;
    // размер блока для расчета спектра = freq*Numpoints
    blSize: double;
    fDataCount: integer; // количество данных в m_T1data
    // спектр re_im
    m_T1ClxData: TAlignDCmpx;
    // блок данных по которому идет расчет.
    m_T1data: TAlignDarray;
    // спектр амплитуд
    m_rms: TAlignDarray;
    // синтезированная передаточная характеристика (усредненная)
    m_frf, m_phase: TDoubleArray;
    m_fltFrf: array of integer; // счетчик отбракованных точек
    line, lineSpm, lineCoh, lineFrf, linePhase,
    // усредненная Frf
    lineAvFRF: cBuffTrend1d;
    // список ударов (TDataBlock) (хранит спектры)
    m_shockList: TDataBlockList;
    // обработан последний удар
    m_shockProcessed: boolean;
    // 1 - x, 2- y, 3 - z, 0 - noAx
    m_axis,
    // прибавлять номер точки
    m_incPNum: byte;
    // список найденных флагов (сравнивается с флагами в полосах)
    m_flags: array of point2d;
    // список найденных экстремумов на линии для сравненияс
    // полосами TExtremum1d
    m_extremums: tlist;
    m_decrement: array of double;
    // экстремумы совпали с диапазоном полос tspmband
    m_checkres: boolean;
  private
    fcfg: cSpmCfg;
    fComInt: point2d;
    // найден общий интервал с взведенным тригом
    fComIntervalLen: double;
  protected
    procedure setcfg(c: cSpmCfg);
  public
    procedure updateBlock(p_spmsize: integer; p_timeBlock: integer);
    property cfg: cSpmCfg read fcfg write setcfg;
    function name: string;
    function getTaho: cSRSTaho;
    constructor create;
    destructor destroy;
  end;

  // выключен/ найден/ завершен TrEnd - накоплены данные для удара на тахо канале
  TtrigStates = (TrOff, TrRise,
    // найден но не финализирован
    TrFall, TrEnd);

  cSRSTaho = class
  public
    // профиль испытания
    m_profile: cprofile;

    m_color: point3;
    m_frm: tform;
    m_CohTreshold,
    // Амплдитуда для обнаружения события
    m_treshold: double;
    m_tag: ctag;
    // блок данных по которому идет расчет. Размер fportionsizei = length*ShockCount
    m_T1data: TAlignDarray;
    fDataCount: integer; // количество данных в m_T1data
    // спектр re_im
    // m_T1ClxData:TAlignDCmpx;
    // тот же спектр, но амплитуда
    // m_rms: TAlignDarray;

    line: cBuffTrend1d;

    // список ударов (TDataBlock)
    m_shockList: TDataBlockList;
    // окно на удар
    m_corrTaho: boolean;
  private // переменные для обсчета в алгоритме обработки
    v_min, v_max: double;
    f_imin, f_imax, // индексы отсчетов содержащих максимум и минимум в текущем ударе
    // индекс последнего отсчета который уже проанализирован f_iEnd+1 не проанализирован
    // все что  в диапазоне 0...f_iEnd можно дропать
    f_iEnd: integer;
    fTrigState: TtrigStates;
    // номер удара в серии
    fShockInd: integer;
    // начало и конец найденного для обработки удара
    m_MaxTime: double;
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

  TFRFFrm = class(TRecFrm)
    SpmChart: cChart;
    RightGB: TGroupBox;
    ShockCountLabel: TLabel;
    ShockCountE: TEdit;
    SaveBtn: TButton;
    ShockSB: TSpinButton;
    ShockIE: TIntEdit;
    ShockLabel: TLabel;
    WinPosBtn: TSpeedButton;
    DelBtn: TButton;
    hideCB: TCheckBox;
    EstimatorRG: TRadioGroup;
    UseWndFcb: TCheckBox;
    WelchCB: TCheckBox;
    DisableCB: TCheckBox;
    SignalsGroupBox: TGroupBox;
    SignalsLV: TBtnListView;
    Splitter1: TSplitter;
    ResTypeRG: TRadioGroup;
    BladeGB: TGroupBox;
    BladeLabel: TLabel;
    StatusEdit: TEdit;
    StatusLabel: TLabel;
    BladeNumEdit: TEdit;
    BladeSE: TSpinButton;
    TrigLvlLabel: TLabel;
    TrigFE: TFloatSpinEdit;
    DempfE: TEdit;
    DempfLabel: TLabel;
    HideExcelCB: TCheckBox;
    procedure FormCreate(sender: tobject);
    procedure SaveBtnClick(sender: tobject);
    procedure WinPosBtnClick(sender: tobject);
    procedure ShockSBDownClick(sender: tobject);
    procedure ShockSBUpClick(sender: tobject);
    procedure SpmChartDblClick(sender: tobject);
    procedure DelBtnClick(sender: tobject);
    procedure hideCBClick(sender: tobject);
    procedure EstimatorRGClick(sender: tobject);
    procedure UseWndFcbClick(sender: tobject);
    procedure SpmChartCursorMove(sender: tobject);
    procedure WelchCBClick(sender: tobject);
    procedure DisableCBClick(sender: tobject);
    procedure SPMcbClick(sender: tobject);
    procedure doShowLines(sender: tobject);
    procedure SignalsLVClick(sender: tobject);
    procedure ResTypeRGClick(sender: tobject);
    procedure SignalsLVColumnBtnClick(item: TListItem; lv: TListView);
    procedure BladeSEUpClick(sender: tobject);
    procedure SpmChartMouseZoom(sender: tobject; UpScale: boolean);
    procedure BladeSEDownClick(sender: tobject);
    procedure HideExcelCBClick(Sender: TObject);
    procedure TrigFEChange(Sender: TObject);
  public
    m_Frf_YX: boolean;
    // отступ слева и длительность
    m_ShiftLeft, m_Length,
    // уровень для флагов на спектре
    m_spmTrig: double;

    ready: boolean;
    // показывать флажки на максимумы
    m_showflags, m_showBandLab: boolean;
    // axRef - воздействие; ax - отклик
    axRef, TimeAx: caxis;
    // h0, h1, h2                         -
    m_estimator: integer;
    pageT, pageSpm: cpage;
    axSpm: caxis;

    m_expWndline: cExpFuncObj;
    // профиль текущего выбраного тахо
    m_profileline: ctrend;
    // список настроек Тахо
    m_TahoList: tlist;
    // spm
    m_lgX, m_lgY, m_newAx: boolean;
    m_minX, m_maxX: double;
    m_minY, m_maxY: double;
    // текущая частота
    m_curFreq: double;
    m_saveT0: boolean;

    m_UseWelch: boolean;
    m_WelchShift, m_WelchCount: integer;
    // последний полученный блок тахо
    m_lastTahoBlock: TDataBlock;
    m_lastMDBfile,
    // Путь к последнему Mera файлу в который сохранили FRF
    // при формировании отчета
    m_MeraFile: string;
    // редактировать отклик
    m_corrS: boolean;

    m_bands: bList;
    // текстовые метки на полосах
    m_labList: tlist;
  protected
    // курсор для триггера
    Ycurs: cYCursor;

    fdelBtn: boolean; // нажали кнопку удалить удар
    fUpdateFrf: boolean; // обновился frf
    fShowLast: boolean; // обновился frf  в потоке
  protected
    procedure doUpdateParams(sender: tobject);
    // расчет числа боков для усреднения
    procedure EvalWelchBCount;
    procedure setNewAx(b: boolean);
    procedure ShowSignalsLV;
    procedure Showbladestatus(s: integer);
    // получить значение датчика в заданном X с учетом типа выбраной линии
    function GetSelectValue(s: csrsres; x:double; shockIndex:integer):double;
  public
    // просчитать по линиям флаги и сравнить их с band
    // если не попадают в bands то лопатка бракованная
    // сразу сохраняет в БД отчет по лопатке в excel
    function CheckFlags: boolean;
    procedure SaveReport(repname: string; bl: cBladeFolder);
    // построить отчет по турбине
    procedure buildReport();
    procedure doOnZoom(sender: tobject);
    function hideind: integer;
    procedure delCurrentShock;
    PROCEDURE ShowShock(shock: integer);
    // спрятать лишние frf
    procedure ShowLines;
    // отобразить последнюю передаточную характеристику блока в S и усредн. передаточную
    procedure ShowFrf(s: cSRSres; c: cSpmCfg; shInd: integer);
    procedure ShowSpm;
    procedure ShowPhase;
    // сколько выбранных сигналов
    function CheckedCount: integer;
    procedure UpdateView;
    // возвращает найден ли удар или нет. Вызов внутри updatedata
    function SearchTrig(t: cSRSTaho): boolean;
    procedure updatedata; override;
    // выделение памяти. происходит при загрузке или смене конфига
    procedure UpdateBlocks;
    procedure UpdateChart;
    procedure doStart;
    procedure addTaho(t: cSRSTaho);
    function getTaho: cSRSTaho;
    function getRes(s: string): cSRSres;
    procedure RBtnClick(sender: tobject);
    procedure TestCoh;
    procedure updateFrf(rebuildspm: boolean);
    procedure updateWelchFrf;
    function ActiveSignal: cSRSres;
    function MaxSpmY: double;
    function MinSpmY: double;
    // обновить надписи в метках полос
    procedure UpdateBands(s: cSRSres);
    procedure UpdateBandNames;
    procedure UpdateLabels;
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

  cFRFFactory = class(cRecBasicFactory)
  public
    // merafile
    m_MeraFile: string;
    m_ShockFile: string;
    m_hideExcel:boolean;
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
    procedure doUpdateData; override;
    procedure doChangeRState(sender: tobject);
    procedure doStart;
    procedure doStop;
  public
    constructor create;
    destructor destroy; override;
    // создаем метки
    procedure CreateBands(f: TFRFFrm; base: cBladeBase);
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

  // копируем данные из тега по интервалу времени time в buf. Возвращает число элементов
function copyData(t: ctag; var time: point2d; buf: TAlignDarray): integer;

var
  FRFFrm: TFRFFrm;
  g_FrfFactory: cFRFFactory;
  g_disableFRF: boolean;

const
  c_Pic = 'FRF';
  c_Name = 'Поиск частот';
  c_defXSize = 400;
  c_defYSize = 400;
  c_FRF = 1;

  // ctrl+shift+G
  // ['{54C462CD-E137-4BA6-9FB5-EFD92D159DE7}']
  IID_SRS: TGuid = (D1: $54C462CD; D2: $E137; D3: $4BA6;
    D4: ($9F, $B5, $EF, $D9, $2D, $15, $9D, $E7));

implementation

uses
  uEditEvalFRFFrm, uCreateComponents;
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

function TextLabelsComparator(p1, p2: pointer): integer;
begin
  if cTextLabel(p1).Position.x > cTextLabel(p2).Position.x then
    result := 1
  else
  begin
    if cTextLabel(p1).Position.x < cTextLabel(p2).Position.x then
      result := -1
    else
      result := 0;
  end;
end;

function correctPos(aX: caxis; page: cpage; p: point2d): point2d;
var
  x, y: double;
begin
  if page.lgX then
  begin
    if (aX.min.x < p.x) and (p.x < aX.max.x) then
    begin
      x := LogValToLinearScale(p.x, p2d(aX.min.x, aX.max.x));
    end;
  end
  else
  begin
    x := p.x;
  end;
  if aX.lg then
  begin
    if (aX.min.y < p.y) and (p.y < aX.max.y) then
    begin
      y := LogValToLinearScale(p.y, p2d(aX.min.y, aX.max.y));
    end;
  end
  else
  begin
    y := p.y;
  end;
  result := p2d(x, y);
end;

function corrcetBound(r: frect): frect;
var
  b: boolean;
begin
  result.BottomLeft.x := min(r.BottomLeft.x, r.TopRight.x, b);
  result.BottomLeft.y := min(r.BottomLeft.y, r.TopRight.y, b);
  result.TopRight.x := max(r.BottomLeft.x, r.TopRight.x, b);
  result.TopRight.y := max(r.BottomLeft.y, r.TopRight.y, b);
end;

function intersectlabel(i: integer; a: caxis; flags: tlist; l: cTextLabel;
  shift: point2d): boolean;
var
  j: integer;
  l2: cTextLabel;
  r2, r: frect;
begin
  result := false;
  r := l.boundrect;
  r.BottomLeft := SummP2(r.BottomLeft, p2(shift.x, shift.y));
  r.TopRight := SummP2(r.TopRight, p2(shift.x, shift.y));
  r := corrcetBound(r);
  for j := i - 1 downto 0 do
  begin
    l2 := cTextLabel(flags.Items[j]);
    if not l2.visible then
      continue;
    r2 := l2.boundrect;
    r2 := corrcetBound(r2);
    // не ушли за правую границу
    if r.BottomLeft.x <= r2.TopRight.x then
    begin
      // не ушли за нижнюю границу
      if r.TopRight.y >= r2.BottomLeft.y then
      begin
        // не ушли за левую границу
        if r.TopRight.x >= r2.BottomLeft.x then
        begin
          // не ушли за верхнюю границу
          if r.BottomLeft.y <= r2.TopRight.y then
            result := true;
        end;
      end;
    end;
    // если есть пересечение
    if result then
      exit;
  end;
end;

{ TSRSFrm }

procedure TFRFFrm.addTaho(t: cSRSTaho);
begin
  t.m_frm := self;
  m_TahoList.Add(t);
end;

procedure TFRFFrm.BladeSEDownClick(sender: tobject);
var
  s: cStageFolder;
  bl, sb: cBladeFolder;
begin
  s := g_mbase.SelectStage;
  if s <> nil then
  begin
    sb := g_mbase.SelectBlade;
    if sb <> nil then
    begin
      bl := cBladeFolder(s.GetPrev(sb));
      if bl <> nil then
      begin
        s.selected := bl;
        BladeNumEdit.Text := bl.caption;
        Showbladestatus(bl.m_res);
      end;
    end;
  end;
end;

procedure TFRFFrm.BladeSEUpClick(sender: tobject);
var
  s: cStageFolder;
  bl, sb: cBladeFolder;
begin
  s := g_mbase.SelectStage;
  if s <> nil then
  begin
    sb := g_mbase.SelectBlade;
    if sb <> nil then
    begin
      bl := cBladeFolder(s.GetNext(sb));
      if bl <> nil then
      begin
        s.selected := bl;
        BladeNumEdit.Text := (bl.caption);
        Showbladestatus(bl.m_res);
      end;
    end;
  end;
end;

function TFRFFrm.CheckedCount: integer;
var
  i, c: integer;
  li: TListItem;
begin
  result := 0;
  for i := 0 to SignalsLV.Items.Count - 1 do
  begin
    li := SignalsLV.Items[i];
    if li.Checked then
      inc(result);
  end;
end;

function TFRFFrm.CheckFlags: boolean;
var
  t: cSRSTaho;
  s: cSRSres;
  cfg: cSpmCfg;
  i, j, k: integer;
  bl: cBladeFolder;
  b: tspmband;
  extr: PExtremum1d;
  res: boolean;
  repPath, resStr: string;
  v, vf, f1, f2, decrement: double;
  minmax, p1,p2: point2d;
begin
  t := getTaho;
  cfg := t.getCfg;
  bl := g_mbase.SelectBlade;
  result := true;
  for i := 0 to cfg.SRSCount - 1 do
  begin
    s := cfg.GetSrs(i);
    s.m_checkres := false;
    b := m_bands.getband(bl.ToneCount - 1);
    // поиск в экстремумов ограниченном джиапазоне (ограничение по концу посл тона)
    FindMinMaxDouble(s.lineFrf.data_r, minmax.x, minmax.y);
    // minmax.y:=0.01*(minmax.y-minmax.x)+minmax.x;
    // minmax.x:=0.005*(minmax.y-minmax.x)+minmax.x;
    if TrigFE.Value<=0 then
    begin
      showmessage('Установить уровень Trig >0');
      exit;
    end;
    minmax.y := TrigFE.Value;
    minmax.x := 0.95 * TrigFE.Value;
    FindExtremumsInY(s.lineFrf.data_r, 1, b.m_f2i, minmax.y, minmax.x, s.m_extremums);
    if s.m_extremums.Count = 0 then
    begin
      result := false;
      s.m_checkres := false;
      break;
    end;
    for j := 0 to s.m_extremums.Count - 1 do
    begin
      extr := PExtremum1d(s.m_extremums[j]);
      if m_bands.Count > j then
        b := m_bands.getband(j)
      else
        b := nil;
      if b = nil then
        break;
      // экстремумы полос и найденные должны соответствовать др. другу
      if b.m_fmaxi = extr.Index then
      begin
        // расчет демпфирования
        v:=extr.Value*0.5;
        k:=extr.Index;
        while s.lineFrf.data_r[k]>v do
        begin
          dec(k);
        end;
        p1.x:=s.lineFrf.GetXByInd(k);
        p1.y:=s.lineFrf.GetYByInd(k);
        p2.x:=s.lineFrf.GetXByInd(extr.Index);
        p2.y:=s.lineFrf.GetYByInd(extr.Index);
        f1:=EvalLineX(v, p1, p2);

        k:=extr.Index;
        while s.lineFrf.data_r[k]>v do
        begin
          inc(k);
        end;
        p1.x:=s.lineFrf.GetXByInd(k);
        p1.y:=s.lineFrf.GetYByInd(k);
        p2.x:=s.lineFrf.GetXByInd(extr.Index);
        p2.y:=s.lineFrf.GetYByInd(extr.Index);
        f2:=EvalLineX(v, p1, p2);
        vf:=2*p2.x;
        s.m_decrement[j]:=(f2-f1)/vf;
      end
      else
      begin
        result := false;
        break;
      end;
    end;
    s.m_checkres := result;
  end;
  result := true;
  for i := 0 to cfg.SRSCount - 1 do
  begin
    s := cfg.GetSrs(i);
    if not s.m_checkres then
    begin
      result := false;
      break;
    end;
  end;
  resStr := '';
  for i := 0 to m_bands.Count - 1 do
  begin
    b := m_bands[i];
    extr := nil;
    if i<s.m_extremums.count then
    begin
      extr := PExtremum1d(s.m_extremums[i]);
    end;
    if extr <> nil then
    begin
      v := extr.Value;
      vf := s.lineFrf.GetXByInd(extr.Index);
      decrement:=s.m_decrement[i];
    end
    else
    begin
      v := 0;
      vf := 0;
    end;
    resStr := resStr + floattostr(b.m_f1) + '..' + floattostr(b.m_f2)
      + '_' + floattostr(v) + '_' + floattostr(vf) +'_'+floattostr(decrement)+ ';';
  end;
  if result then
    bl.m_res := 2
  else
    bl.m_res := 1;
  bl.m_resStr := resStr;
  Showbladestatus(bl.m_res);
  if not CheckExcelInstall then
  begin
    showmessage('Необходима установка Excel');
    exit;
  end;
  repPath := bl.BladeReport;
  // сохраняем статус лопатки
  bl.CreateXMLDesc;
  SaveReport(repPath, bl);
end;

procedure TFRFFrm.buildReport;
var
  turb: cTurbFolder;
begin
  turb := g_mbase.SelectTurb;
  turb.Buildreport('', g_FrfFactory.m_hideExcel);
end;

procedure TFRFFrm.SaveReport(repname: string; bl: cBladeFolder);
var
  r0, i, j, r, c: integer;
  t: cSRSTaho;
  s: cSRSres;
  cfg: cSpmCfg;
  b: tspmband;
  extr: PExtremum1d;
  date: TDateTime;
  res: boolean;
  rng: olevariant;
  str, repPath: string;
  minmax: point2d;
  v, v1, d: double;
begin
  KillAllExcelProcesses;
  if not CheckVarObj(E) then
  begin
    if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;

  if fileexists(repname) then
  begin
    if not IsExcelFileOpen(repname) then
    begin
      OpenWorkBook(repname);
    end
    else
    begin
      VisibleExcel(true);
    end;
  end
  else
  begin
    AddWorkBook;
    AddSheet('Page_01');
  end;
  // в пятом столбце строки идут заполненные подряд
  r0 := GetEmptyRow(1, 1, 5);
  SetCell(1, r0, 2, 'Blade:');
  SetCell(1, r0, 3, bl.m_sn);
  SetCell(1, r0, 4, 'Чертеж:');
  SetCell(1, r0, 5, bl.ObjType);
  SetCell(1, r0, 6, 'MeraFile:');
  SetCell(1, r0, 7, m_MeraFile);

  inc(r0);
  SetCell(1, r0, 4, 'Time:');
  date := now;
  SetCell(1, r0, 5, DateToStr(date));
  SetCell(1, r0+1, 5, TimeToStr(date));
  r := r0 + 2;
  c := 2;

  t := getTaho;
  cfg := t.getCfg;
  for i := 0 to cfg.SRSCount - 1 do
  begin
    s := cfg.GetSrs(i);
    str := s.m_tag.tagname;
    SetCell(1, r - 1, c, str);
    SetCell(1, r, c, 'Band');
    SetCell(1, r, c + 1, 'A1');
    SetCell(1, r, c + 2, 'F1');
    SetCell(1, r, c + 3, 'Dekr');
    SetCell(1, r, c + 4, 'Res');
    // проход по формам (полосам)
    if m_bands.Count = 0 then
    begin
      SetCell(1, r + 1 + j, c, floattostr(b.m_f1) + '...' + floattostr(b.m_f2));
      SetCell(1, r + 1 + j, c + 1, 0);
      SetCell(1, r + 1 + j, c + 2, 0);
      rng := GetRangeObj(1, point(r + 1 + j, 2), point(r + 1 + j, 5));
      SetCell(1, r + 1 + j, c + 3, 0);
      SetCell(1, r + 1 + j, c + 4, 'Не испытан');
    end
    else
    begin
      for j := 0 to m_bands.Count - 1 do
      begin
        b := m_bands.getband(j);
        SetCell(1, r + 1 + j, c,
          floattostr(b.m_f1) + '..' + floattostr(b.m_f2));
        if s.m_extremums.Count > 0 then
        begin
          if j < s.m_extremums.Count then
          begin
            extr := s.m_extremums[j];
            v1 := s.lineFrf.GetXByInd(extr.Index);
            v := extr.Value;
            d:=s.m_decrement[j];
          end
          else
          begin
            v1 := 0;
            v1 := 0;
            d:=0;
            extr := nil;
          end;
          SetCell(1, r + 1 + j, c + 1, v);
        end
        else
        begin
          v := 0;
          SetCell(1, r + 1 + j, c + 1, 0);
        end;
        SetCell(1, r + 1 + j, c + 2, v1);
        SetCell(1, r + 1 + j, c + 3, d);
        if (v1 > b.m_f1) and (v1 < b.m_f2) then
        begin
          SetCell(1, r + 1 + j, c + 4, 'Годен');
        end
        else
        begin
          rng := GetRangeObj(1, point(r + 1 + j, c), point(r + 1 + j, c + 3));
          rng.Interior.Color := RGB(255, 165, 0); // Оранжевый цвет;
          SetCell(1, r + 1 + j, c + 4, 'Не годен');
        end;
      end;
    end;
    c := c + 4;
  end;
  // разметка заголовка
  rng := GetRangeObj(1, point(r, 2), point(r, c - 1));
  // c_Excel_GrayInd = 15;
  rng.Interior.ColorIndex := 15;
  rng.Font.Bold := true;
  // ставим сетку всего блока
  rng := GetRangeObj(1, point(r, 2), point(r + j, c - 1));
  SetRangeBorder(rng);
  SaveWorkBookAs(repname);
  if g_FrfFactory.m_hideExcel then
  begin
    CloseWorkBook;
    CloseExcel;
  end;
end;

constructor TFRFFrm.create(Aowner: tcomponent);
begin
  // отступ слева и длительность
  m_ShiftLeft := 0.05;
  m_Length := 1;
  m_TahoList := tlist.create;

  m_bands := bList.create;
  m_labList := tlist.create;
  m_showBandLab := false;
  m_showflags := false;
  inherited;
end;

procedure TFRFFrm.DelBtnClick(sender: tobject);
begin
  fdelBtn := true;
  if RStateStop then
    UpdateView;
end;

function TFRFFrm.ActiveSignal: cSRSres;
var
  td, sd: TDataBlock;
  s: cSRSres;
  t: cSRSTaho;
  c: cSpmCfg;
  i: integer;
begin
  t := getTaho;
  if SignalsLV.ItemIndex = -1 then
    s := t.cfg.GetSrs(0)
  else
    s := t.cfg.GetSrs(SignalsLV.ItemIndex);
  result := s;
end;

function TFRFFrm.MaxSpmY: double;
begin
  if ResTypeRG.ItemIndex = 1 then
    result := 1.1
  else
  begin
    if ResTypeRG.ItemIndex = 3 then
      result := 180
    else
      result := m_maxY;
  end;
end;

function TFRFFrm.MinSpmY: double;
begin
  if ResTypeRG.ItemIndex = 1 then
    result := 0.1
  else
  begin
    if ResTypeRG.ItemIndex = 3 then
      result := -180
    else
      result := m_minY;
  end;
end;

procedure TFRFFrm.doOnZoom(sender: tobject);
begin
  m_bands.UpdateBands;
  // UpdateBands;
  UpdateLabels;
end;

procedure TFRFFrm.doShowLines(sender: tobject);
var
  s: cSRSres;
  t: cSRSTaho;
  r: frect;
  li: TListItem;
  i, lcount: integer;
begin
  for i := 0 to SignalsLV.Items.Count - 1 do
  begin
    li := SignalsLV.Items[i];
    if not li.Checked then
      continue;
    s := cSRSres(li.Data);
    s.lineCoh.visible := ResTypeRG.ItemIndex = 1;
    if ResTypeRG.ItemIndex = 0 then
    begin
      lcount := CheckedCount;
      s.lineFrf.visible := lcount = 1;
      s.lineAvFRF.visible := true;
    end;
    if ResTypeRG.ItemIndex = 2 then
    begin
      s.lineSpm.visible := true;
      ShowSpm;
    end
    else
      s.lineSpm.visible := false;
    if ResTypeRG.ItemIndex = 3 then
    begin
      s.linePhase.visible := true;
      ShowPhase;
    end
    else
      s.linePhase.visible := false;
  end;

  // перекочевало сюда из showspm
  UpdateView;
  if (ResTypeRG.ItemIndex = 1) or (ResTypeRG.ItemIndex = 3) then
  begin
    r.BottomLeft.x := m_minX;
    r.TopRight.x := m_maxX;
    axSpm.lg := false;
  end
  else
  begin
    r.BottomLeft.x := m_minX;
    r.TopRight.x := m_maxX;
    axSpm.lg := m_lgY;
  end;
  r.BottomLeft.y := MinSpmY;
  r.TopRight.y := MaxSpmY;
  axSpm.ZoomfRect(r);
end;

procedure TFRFFrm.Showbladestatus(s: integer);
begin
  case s of
    0:
      begin
        StatusEdit.Text := 'Не испытан';
        StatusEdit.Color := clWindow;
      end;
    1:
      begin
        StatusEdit.Text := 'Не годен';
        StatusEdit.Color := $008080FF;
      end;
    2:
      begin
        StatusEdit.Text := 'Годен';
        StatusEdit.Color := clWindow;
      end;
  end;
end;

procedure TFRFFrm.ShowFrf(s: cSRSres; c: cSpmCfg; shInd: integer);
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
    if s.lineFrf.visible then
    begin
      s.lineFrf.AddPoints(sd.m_frf, c.fHalfFft);
      UpdateBands(s);
      UpdateLabels;
    end;
  end;
  fUpdateFrf := false;
end;

procedure TFRFFrm.delCurrentShock;
var
  td, sd: TDataBlock;
  s: cSRSres;
  t: cSRSTaho;
  c: cSpmCfg;
  i: integer;
begin
  t := getTaho;
  td := t.m_shockList.getBlock(ShockIE.intnum);
  t.m_shockList.delBlock(td);
  for i := 0 to t.cfg.SRSCount - 1 do
  begin
    hideCB.Checked := false;
    s := t.cfg.GetSrs(i);
    sd := s.m_shockList.getBlock(ShockIE.intnum);
    if sd = nil then
      exit;
    s.m_shockList.delBlock(sd);
  end;
  updateFrf(false);
  ShockCountE.Text := inttostr(t.m_shockList.Count);
  fdelBtn := false;
end;

destructor TFRFFrm.destroy;
var
  i: integer;
  t: cSRSTaho;
begin
  for i := 0 to m_TahoList.Count - 1 do
  begin
    t := m_TahoList.Items[i];
    t.destroy;
  end;
  m_TahoList.destroy;
  m_bands.destroy;
  m_labList.destroy;
  inherited;
end;

procedure TFRFFrm.DisableCBClick(sender: tobject);
begin
  g_disableFRF := DisableCB.Checked;
end;

procedure TFRFFrm.doStart;
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
    t.m_MaxTime := 0;
    t.TrigInterval.x := 0;
    t.TrigInterval.y := 0;
    ZeroMemory(t.m_T1data.p, t.cfg.fportionsizei * sizeof(double));
    if t.cfg <> nil then
    begin
      for i := 0 to t.cfg.SRSCount - 1 do
      begin
        s := t.cfg.GetSrs(i);
        s.m_tag.doOnStart;
        s.fComIntervalLen := 0;
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

procedure TFRFFrm.doUpdateParams(sender: tobject);
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

procedure TFRFFrm.updateWelchFrf;
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

procedure TFRFFrm.updateFrf(rebuildspm: boolean);
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

procedure TFRFFrm.EstimatorRGClick(sender: tobject);
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

procedure TFRFFrm.FormCreate(sender: tobject);
var
  p: cpage;
  r: frect;
begin
  SpmChart.OnRBtnClick := RBtnClick;
  SpmChart.tabs.activeTab.addPage(true);
  SpmChart.OBJmNG.Events.AddEvent('SpmChart_OnZoom', e_OnChangeAxisScale,
    doOnZoom);

  p := SpmChart.tabs.activeTab.GetPage(0);
  r.BottomLeft.x := 0;
  r.BottomLeft.y := 0;
  r.TopRight.x := 10;
  r.TopRight.y := 10;
  p.ZoomfRect(r);
  p.Caption := 'Oscillogram';
  pageT := p;
  TimeAx := pageT.getaxis(0);

  p := SpmChart.tabs.activeTab.GetPage(1);
  r.BottomLeft.x := 0;
  r.BottomLeft.y := 0;
  r.TopRight.x := 10;
  r.TopRight.y := 10;
  p.ZoomfRect(r);
  p.Caption := 'Freq Dom.';
  pageSpm := p;
  m_profileline := ctrend.create;
  m_profileline.name := 'Profile';
  pageSpm.activeAxis.AddChild(m_profileline);
  m_profileline.visible := true;

  axSpm := p.activeAxis;
end;

procedure TFRFFrm.UpdateBandNames;
var
  i, j: integer;
  b: tspmband;
  s: cSRSres;
  t: cSRSTaho;
begin
  t := getTaho;
  if t <> nil then
  begin
    for i := 0 to m_bands.Count - 1 do
    begin
      b := m_bands.getband(i);
      b.m_trends.clear;
      for j := 0 to t.cfg.SRSCount - 1 do
      begin
        s := t.cfg.GetSrs(j);
        b.m_trends.AddObject(s.name, s);
        if b.flag = nil then
          b.createlabel;
        s.lineFrf.AddChild(b.flag);
      end;
    end;
  end;
end;

// обновить значения меток.
procedure TFRFFrm.UpdateLabels;
var
  i, j, k, ind: integer;
  b: tspmband;
  tr: cBuffTrend1d;
  l: cTextLabel;
  p: cpage;
  a: caxis;
  x, y, max, maxX: double;
  spmMax, pos: point2d;
  // смещение положения метки для непересечения
  percentSize: point2;
  r: frect;
  // пересекаем другую метку
  intersect: boolean;
begin
  m_labList.clear;
  if not m_showflags then
    exit;

  for i := 0 to m_bands.Count - 1 do
  begin
    b := m_bands.getband(i);
    l := b.flag;
    l.visible := m_showflags;
    if not m_showflags then
      continue;

    a := caxis(l.GetParentByClassName('cAxis'));
    p := cpage(a.GetParentByClassName('cPage'));
    l.visible := true;
    // xMax
    x := b.m_freqband.m_realX;
    // tr:=cBuffTrend1d(l.parent);
    // UpdateBandNames создает привязки
    tr := ActiveSignal.lineFrf;
    l.parent := tr;
    if b.m_fmaxi > tr.Count then
      exit;
    if b.m_fmaxi > 0 then
    begin
      max := tr.GetYByInd(b.m_fmaxi);
      maxX := tr.GetXByInd(b.m_fmaxi);
      // флаг показываем только если он выше граничного значения
      if (b.m_fmaxi = b.m_f1i) or (b.m_fmaxi = b.m_f2i) then
      begin
        l.visible := false;
      end
      else
      begin
        l.visible := true;
      end;
    end;
    pos := correctPos(a, p, p2d(maxX, max));
    l.Position := p2(pos.x, pos.y);
    l.line := l.Position;
    l.Text := format('F:%.3g', [maxX]) + format(' V:%.3g', [max]);
    m_labList.Add(l);
  end;
  m_labList.Sort(TextLabelsComparator);
  // пересчитываем положения меток
  for i := 0 to m_labList.Count - 1 do
  begin
    l := cTextLabel(m_labList.Items[i]);
    // смещаем метку
    r := l.boundrect;
    percentSize.x := r.TopRight.x - r.BottomLeft.x;
    percentSize.x := percentSize.x / a.getdx;
    percentSize.y := r.TopRight.y - r.BottomLeft.y;
    percentSize.y := percentSize.y / a.getdy;
    // пытаемся сместиться вверх
    intersect := true;
    pos := p2d(l.Position.x, l.Position.y);
    j := 1; // число смещений
    while intersect do
    begin
      // pos.x:=pos.x+percentSize.x*a.getdx;
      pos.y := pos.y + percentSize.y * a.getdy;
      // intersectlabel(i:integer;a:caxis;flags:tlist;l:ctextlabel;pos:point2d)
      intersect := intersectlabel(i, a, m_labList, l,
        p2d(0, percentSize.y * a.getdy * j));
      inc(j);
    end;
    l.Position := p2(pos.x, pos.y);
  end;
end;

procedure TFRFFrm.UpdateBands(s: cSRSres);
var
  i, j: integer;
  b: tspmband;
  act_s: cSRSres;
  p, max: double;
begin

  act_s := ActiveSignal;
  for i := 0 to m_bands.Count - 1 do
  begin
    b := m_bands.getband(i);
    if not m_showBandLab then
    begin
      b.m_freqband.m_LineLabel.visible := false;
    end;

    b.m_f1i := s.lineFrf.GetLowInd(b.m_f1) + 1;
    b.m_f2i := s.lineFrf.GetLowInd(b.m_f2);
    max := 0;
    b.m_fmaxi := 0;
    for j := b.m_f1i to b.m_f2i do
    begin
      p := s.lineFrf.GetYByInd(j);
      if max < p then
      begin
        max := p;
        b.m_fmaxi := j;
      end;
    end;
    if s = act_s then
      b.m_freqband.m_realX := s.lineFrf.GetXByInd(b.m_fmaxi);
    for j := 0 to b.m_trends.Count - 1 do
    begin
      if s = b.m_trends.Objects[j] then
      begin
        b.m_freqband.setY(max, j);
        break;
      end;
    end;
    b.m_freqband.name := b.m_freqband.name;
  end;
end;

procedure TFRFFrm.UpdateBlocks;
var
  refresh: double;
  lt: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i: integer;
begin
  refresh := GetREFRESHPERIOD;
  lt := getTaho;
  if lt.m_tag.Freq <> 0 then
    lt.line.dx := 1 / lt.m_tag.Freq;

  c := lt.cfg;
  c.fHalfFft := c.m_fftCount shr 1;
  // размер блока для расчета в секундах
  c.fportionsize := m_Length * c.m_blockcount;
  c.fportionsizei := round(c.fportionsize * lt.m_tag.Freq);
  c.fOutSize := c.m_fftCount * c.m_blockcount;
  c.fspmdx := lt.m_tag.Freq / c.m_fftCount;
  c.FFTProp := GetFFTPlan(c.m_fftCount);
  c.FFTProp.StartInd := 0;

  GetMemAlignedArray_d(c.fportionsizei, lt.m_T1data);
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    if s.m_tag.Freq <> 0 then
      s.line.dx := 1 / s.m_tag.Freq;
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
    s.linePhase.dx := c.fspmdx;
    s.lineCoh.dx := c.fspmdx;
    s.lineFrf.dx := c.fspmdx;
    s.lineAvFRF.dx := c.fspmdx;
  end;
end;

procedure TFRFFrm.UpdateChart;
var
  l: cBuffTrend1d;
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i: integer;
  fr: frect;
  a: caxis;
  bfrf: boolean;

  prLine: cProfileLine;
begin
  t := getTaho;
  if t <> nil then
  begin
    prLine := cProfileLine(t.m_profile.getline('Profile'));
    prLine.exclude(m_profileline);
  end;

  for i := 0 to pageT.axises.ChildCount - 1 do
  begin
    a := pageT.getaxis(i);
    a.clear;
  end;
  axSpm.clear;
  if t = nil then
    exit;
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
    begin
      axRef.AddChild(l)
    end
    else
    begin
      axRef := TimeAx;
      pageT.getaxis(0).AddChild(l);
    end;
    l.Color := t.m_color;
    t.line := l;
    t.line.name := t.name;
    if t.m_tag.Freq = 0 then
      l.dx := 1 / t.m_tag.Freq
    else
      l.dx := 0;

    m_expWndline := cExpFuncObj.create;
    m_expWndline.name := 'ExpWndLine';
    m_expWndline.visible := UseWndFcb.Checked;
    m_expWndline.enabled := UseWndFcb.Checked;
    m_expWndline.selectable := UseWndFcb.Checked;
    m_expWndline.fHelper := true;
    m_expWndline.fUpdateParams := doUpdateParams;
    TimeAx.AddChild(m_expWndline);

    c := t.cfg;
    if m_corrS then
    begin
      c.setWnd(wnd_exp, m_ShiftLeft, m_Length, 0.0001);
    end
    else
    begin
      c.setWnd(wnd_no);
    end;
    for i := 0 to c.SRSCount - 1 do
    begin
      s := c.GetSrs(i);
      l := cBuffTrend1d.create;
      TimeAx.AddChild(l);
      l.Color := s.m_color;
      s.line := l;
      s.line.name := s.name;
      if t.m_tag.Freq = 0 then
        l.dx := 1 / t.m_tag.Freq
      else
        l.dx := 0;

      l := cBuffTrend1d.create;
      l.Color := s.m_color;
      axSpm.AddChild(l);
      s.lineSpm := l;
      s.lineSpm.dx := c.fspmdx;
      s.lineSpm.name := s.name + '_spm';
      l.visible := not bfrf;

      l := cBuffTrend1d.create;
      l.Color := s.m_color;
      axSpm.AddChild(l);
      s.linePhase := l;
      s.linePhase.dx := c.fspmdx;
      s.linePhase.name := s.name + '_Phase';
      l.visible := ResTypeRG.ItemIndex = 3;

      l := cBuffTrend1d.create;
      l.Color := s.m_colorAlt;
      l.dx := c.fspmdx;
      axSpm.AddChild(l);
      s.lineFrf := l;
      s.lineFrf.name := s.name + '_frf';
      l.visible := bfrf;

      l := cBuffTrend1d.create;
      l.Color := s.m_color;
      l.dx := c.fspmdx;
      axSpm.AddChild(l);

      s.lineAvFRF := l;
      s.lineAvFRF.name := s.name + '_AvFrf';
      s.lineAvFRF.weight := 5;
      s.lineAvFRF.visible := true;

      l := cBuffTrend1d.create;
      l.Color := s.m_color;
      l.visible := false;
      l.dx := c.fspmdx;
      axSpm.AddChild(l);
      s.lineCoh := l;
      s.lineCoh.name := s.name + '_coh';
    end;
    UpdateBandNames;
    c.typeres := c.typeres;

    m_profileline := ctrend.create;
    m_profileline.name := 'Profile';
    m_profileline.Color := green;
    pageSpm.activeAxis.AddChild(m_profileline);
    m_profileline.visible := true;

    prLine := cProfileLine(t.m_profile.getline('Profile'));
    prLine.addline(m_profileline);
    prLine.updatepoints;

    fr.BottomLeft := p2(0, -2 * t.m_treshold);
    fr.TopRight := p2(m_Length, t.m_treshold * 2);
    pageT.ZoomfRect(fr);
    m_expWndline.SetParams(m_ShiftLeft, m_Length, 0.001);

    fr.BottomLeft := p2(m_minX, m_minY);
    fr.TopRight := p2(m_maxX, m_maxY);
    pageSpm.lgX := m_lgX;
    axSpm.lg := m_lgY;
    pageSpm.ZoomfRect(fr);
  end;
  UpdateBlocks;
end;

function TFRFFrm.SearchTrig(t: cSRSTaho): boolean;
var
  i, pcount, dropCount: integer;
  sig_interval, common_interval: point2d;
  v, siglen, dropLen: double;
  b: boolean;
  s: cSRSres;
begin
  result := false;
  if t.m_tag.UpdateTagData(true) then
  begin
    // не отбрасываем данные если находимся в состоянии когда триг найден но
    // еще не накопился целиком
    if t.fTrigState <> TrFall then
    begin
      // logMessage('RBlock: ' + inttostr(t.m_tag.m_readyBlock));
      sig_interval := t.m_tag.getPortionTime;
      siglen := sig_interval.y;
      // logMessage('SLen: ' + floattostr(siglen));
      dropLen := t.m_tag.getPortionLen - m_Length;
      if dropLen > 0 then // при этом условии гарантированно остается 2*blocklen
      begin
        dropCount := trunc(dropLen * t.m_tag.Freq);
        if t.f_iEnd > 0 then
        begin
          if dropCount > t.f_iEnd then
            dropCount := t.f_iEnd;
        end;
        t.m_tag.ResetTagDataTimeInd(dropCount); // 1,000027805
        // logMessage('ReadDataTime: ' +floattostr(t.m_tag.m_ReadDataTime));
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
      // for i := 0 to t.m_tag.lastindex - 1 do
      begin
        v := t.m_tag.m_ReadData[i];
        if v > t.m_treshold then
        begin
          if v > t.v_max then
          begin
            // logMessage('SLen2: ' + floattostr(siglen));
            t.fTrigState := TrRise;
            t.v_max := v;
            t.f_imax := i;
          end;
        end
        else
        begin
          if t.fTrigState = TrRise then
          begin
            t.fTrigState := TrFall;
            // считаем границы порции
            t.m_MaxTime := t.m_tag.getReadTime(t.f_imax);
            // logMessage('MaxTime: ' +floattostr(t.m_MaxTime));
            t.TrigInterval.x := t.m_MaxTime - m_ShiftLeft;
            t.TrigInterval.y := t.TrigInterval.x + m_Length;
            // logMessage('TrigInterval: ' +floattostr(t.TrigInterval.x)+'...'+floattostr(t.TrigInterval.y));
            t.f_iEnd := t.m_tag.getIndex(t.TrigInterval.y);
            result := true;
            break;
          end;
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
      // если данных накопилось на целиковый удар
      if t.f_iEnd <= t.m_tag.lastindex then
      begin
        t.fTrigState := TrEnd;
        pcount := copyData(t.m_tag, t.TrigInterval, t.m_T1data);
        t.fDataCount := pcount;
        /// дополнять нулями
        if pcount < t.cfg.m_fftCount then
        begin

        end;
        begin
          // AddBlock делать без перевыделения памяти!!!
          m_lastTahoBlock := t.m_shockList.addBlock(t.cfg.m_fftCount,
            p2d(t.TrigInterval.x, t.TrigInterval.x + pcount / t.m_tag.Freq),
            TDoubleArray(t.m_T1data.p), pcount);
          m_lastTahoBlock.m_timeMax := t.m_MaxTime;
          // накладываем окно
          m_lastTahoBlock.prepareData;
          // рисуем с учетом окна
          t.line.AddPoints(TDoubleArray(m_lastTahoBlock.m_TimeBlockFlt.p),
            pcount);
          t.line.flength := pcount;
          m_lastTahoBlock.BuildSpm;
        end;
      end;
    end;
    if t.fTrigState = TrEnd then
    begin
      b := true;
      // проверяем все ли блоки данных от датчиков засчитаны в удар
      for i := 0 to t.cfg.SRSCount - 1 do
      begin
        s := t.cfg.GetSrs(i);
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
  end;
end;

procedure TFRFFrm.updatedata;
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i, pcount, dropCount: integer;
  sig_interval, common_interval: point2d;
  find: boolean;
  block: TDataBlock;
  siglen, comIntervalLen, refresh, dropLen: double;
begin
  if not ready then
    exit;
  t := getTaho;
  c := t.cfg;
  refresh := t.m_tag.BlockSize / t.m_tag.Freq;
  if m_Length < refresh then
    m_Length := refresh;
  // поиск удара. внутри обновляются данные по тахо, ущется удар, обновляется автомат trigstate
  find := SearchTrig(t);

  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    if s.m_tag.UpdateTagData(true) then
    begin
      sig_interval := s.m_tag.getPortionTime;
      // logMessage('sig_interval: ' +floattostr(sig_interval.x)+'...'+floattostr(sig_interval.y));
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
      // logMessage('com_interval: ' +floattostr(common_interval.x)+'...'+floattostr(common_interval.y));
      if comIntervalLen > 0 then
      begin
        // если данные накопились и тахо тоже накопился
        if (comIntervalLen >= s.fComIntervalLen) then
        begin
          // сброс в resettrig
          s.fComIntervalLen := comIntervalLen;
          s.fComInt := common_interval;
          pcount := copyData(s.m_tag, common_interval, s.m_T1data);
          if pcount >= c.m_fftCount then
          begin

          end;
          // logMessage('ShockIndex: ' +inttostr(m_lastTahoBlock.index));
          s.fDataCount := pcount; // скопровано отсчетов в блок
          block := s.m_shockList.getBlock(t.m_MaxTime);
          if block = nil then
          begin
            block := s.m_shockList.addBlock(c.m_fftCount, // SpmSize
              p2d(common_interval.x,
                common_interval.x + pcount / s.m_tag.Freq), // timeStamp
              TDoubleArray(s.m_T1data.p), // timeData
              pcount); // timeData size
            block.m_timeMax := t.m_MaxTime;
            block.prepareData;

            block.BuildSpm;
            s.line.AddPoints(TDoubleArray(block.m_TimeBlockFlt.p), pcount);
            s.line.flength := pcount;
            if m_lastTahoBlock<>nil then
            begin
              block.m_connectedInd := m_lastTahoBlock.index;
            end
            else
            begin
              block.m_connectedInd:=0;
            end;
            s.m_shockProcessed := true;
            dropCount := s.m_tag.getIndex(t.TrigInterval.x);
            if dropCount > 0 then
            begin
              if dropCount < s.m_tag.lastindex then
                s.m_tag.ResetTagDataTimeInd(dropCount);
            end;
            t.evalCoh(hideind);
          end;
        end;
      end;
      // херим старые данные
      if s.m_tag.getPortionLen > 2 * m_Length then
      begin
        dropLen := s.m_tag.getPortionLen - 2 * m_Length;
        if dropLen > 0 then // при этом условии гарантированно остается 2*blocklen
        begin
          dropCount := trunc(dropLen * s.m_tag.Freq);
        end;
        // отбрасываем все что слева по времени от найденного удара
        if dropCount > 0 then
        begin
          s.m_tag.ResetTagDataTimeInd(dropCount - 1);
        end;
      end;
    end;
  end;
end;

procedure TFRFFrm.hideCBClick(sender: tobject);
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

procedure TFRFFrm.HideExcelCBClick(Sender: TObject);
begin
  g_FrfFactory.m_hideExcel:=HideExcelCB.Checked;
end;

procedure TFRFFrm.ShowLines;
var
  t: cSRSTaho;
  c: cSpmCfg;
  i: integer;
  ls, asig: cSRSres;
  li: TListItem;
  lcount: integer;
  r: frect;
  b: boolean;
begin
  t := getTaho;
  c := t.cfg;
  lcount := CheckedCount;
  asig := ActiveSignal;
  for i := 0 to c.SRSCount - 1 do
  begin
    ls := c.GetSrs(i);
    li := SignalsLV.Items[i];
    b := (lcount = 0) and (ls = asig);
    if (not li.Checked) and (not b) then
    begin
      ls.lineFrf.visible := false;
      ls.lineAvFRF.visible := false;
      ls.lineSpm.visible := false;
      ls.linePhase.visible := false;
      ls.lineCoh.visible := false;
    end
    else
    begin
      case ResTypeRG.ItemIndex of
        0:
          begin
            if lcount < 2 then
            begin
              ls.lineFrf.visible := true;
              ls.lineAvFRF.weight := 5;
            end
            else
            begin
              ls.lineFrf.visible := false;
              ls.lineAvFRF.weight := 1;
            end;
            ls.lineAvFRF.visible := true;
            ls.lineSpm.visible := false;
            ls.lineCoh.visible := false;
            ls.linePhase.visible := false;
          end;
        1:
          begin
            ls.lineCoh.visible := true;
            ls.lineAvFRF.visible := false;
            ls.lineSpm.visible := false;
            ls.linePhase.visible := false;
            ls.lineFrf.visible := false;
            ls.lineAvFRF.visible := false;
          end;
        2:
          begin
            ls.lineCoh.visible := false;
            ls.lineAvFRF.visible := false;
            ls.lineSpm.visible := true;
            ls.linePhase.visible := false;
            ls.lineFrf.visible := false;
            ls.lineAvFRF.visible := false;
            ShowSpm;
          end;
        3:
          begin
            ls.lineCoh.visible := false;
            ls.lineAvFRF.visible := false;
            ls.lineSpm.visible := false;
            ls.linePhase.visible := true;
            ls.lineFrf.visible := false;
            ls.lineAvFRF.visible := false;
            ShowPhase;
          end;
      end;
    end;
  end;
  if (ResTypeRG.ItemIndex = 1) or (ResTypeRG.ItemIndex = 3) then
  begin
    axSpm.lg := false;
  end
  else
  begin
    axSpm.lg := m_lgY;
  end;
  r.BottomLeft.x := m_minX;
  r.TopRight.x := m_maxX;
  r.BottomLeft.y := MinSpmY;
  r.TopRight.y := MaxSpmY;
  axSpm.ZoomfRect(r);
end;

function TFRFFrm.hideind: integer;
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

procedure TFRFFrm.UpdateView;
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
      s := c.GetSrs(0);
      if s <> nil then
        ShockCountE.Text := inttostr(s.m_shockList.Count)
      else
        ShockCountE.Text := '0';
    end;
  end;
  if ResTypeRG.ItemIndex = 0 then
  begin
    if fUpdateFrf then
    begin
      for i := 0 to c.SRSCount - 1 do
      begin
        s := c.GetSrs(i);
        if fShowLast then
          ShowFrf(s, c, -1)
        else
          ShowFrf(s, c, ShockIE.intnum);
      end;
      if CheckedCount = 0 then
      begin
        ShowLines;
        s := ActiveSignal;
        s.lineFrf.visible := true;
        s.lineAvFRF.visible := true;
      end;
      fShowLast := false;
    end;
  end;
  if ResTypeRG.ItemIndex = 2 then
    ShowSpm;
  if ResTypeRG.ItemIndex = 3 then
  begin
    ShowPhase;
  end;
  SpmChart.redraw;
end;

procedure TFRFFrm.UseWndFcbClick(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i, j: integer;
  db: TDataBlock;
begin
  t := getTaho;
  if t = nil then
    exit;
  c := t.cfg;
  t.m_corrTaho := UseWndFcb.Checked;
  if t.m_corrTaho then
  begin
    pageT.cursor.visible := true;
    pageT.cursor.cursortype := c_DoubleCursor;
    pageT.cursor.setx1(0);
    if t.corrLen <= 0 then
    begin
      t.m_shockList.m_wnd.x2 := m_Length * 0.7;
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
    m_expWndline.doUpdateWorldSize(nil);
    m_expWndline.SetParams(m_ShiftLeft * 0.5, 0.7 * m_Length, 0.001);
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
  // пересчет с учетом окон

  for i := 0 to t.cfg.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    for j := 0 to s.m_shockList.Count - 1 do
    begin
      db := s.m_shockList.getBlock(j);
      db.prepareData;
      db.BuildSpm;
    end;
    for j := 0 to t.m_shockList.Count - 1 do
    begin
      db := t.m_shockList.getBlock(j);
      db.prepareData;
      db.BuildSpm;
    end;
    if t.m_shockList.Count <> 0 then
    begin
      db := t.m_shockList.getBlock(ShockIE.intnum);
      t.line.AddPoints(TDoubleArray(db.m_TimeBlockFlt.p), db.m_TimeArrSize);
      db := s.m_shockList.getBlock(ShockIE.intnum);
      s.line.AddPoints(TDoubleArray(db.m_TimeBlockFlt.p), db.m_TimeArrSize);
      updateFrf(false);
      UpdateView;
    end;
  end;
end;

procedure TFRFFrm.WelchCBClick(sender: tobject);
var
  t: cSRSTaho;
begin
  m_UseWelch := WelchCB.Checked;
  t := getTaho;
  updateFrf(not m_UseWelch);
  UpdateView;
end;

procedure TFRFFrm.WinPosBtnClick(sender: tobject);
begin
  buildReport;
  if fileexists(g_FrfFactory.m_MeraFile) then
  begin
    ShellExecute(0, nil, pwidechar(g_FrfFactory.m_ShockFile), nil, nil,
      SW_HIDE);
  end;
end;

function TFRFFrm.getRes(s: string): cSRSres;
var
  t: cSRSTaho;
  c: cSpmCfg;
begin
  t := getTaho;
  c := t.cfg;
  result := c.GetSrs(s);
end;


function TFRFFrm.getTaho: cSRSTaho;
begin
  if m_TahoList.Count > 0 then
    result := cSRSTaho(m_TahoList.Items[0])
  else
    result := nil;
end;

procedure TFRFFrm.ResTypeRGClick(sender: tobject);
begin
  // ShowLines(nil);
  SignalsLVClick(nil);
end;

procedure TFRFFrm.RBtnClick(sender: tobject);
begin
  if EditFrfFrm <> nil then
  begin
    EditFrfFrm.Edit(self);
  end;
end;

procedure TFRFFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, Count: integer;
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  tag: itag;
  ltag: ctag;
  prof: cProfileLine;

begin
  inherited;
  ltag := LoadTagIni(a_pIni, str, 'Taho_Tag');
  if ltag <> nil then
  begin
    t := cSRSTaho.create;
    prof := t.m_profile.getline('Profile');
    prof.addline(m_profileline);
    prof.updatepoints;
    if pageSpm.activeAxis.getChild('Profile') = nil then
    begin
      showmessage('nil');
    end;

    t.m_color := ColorArray[0];
    t.m_tag.tag := ltag.tag;
    t.m_tag.tagname := ltag.tagname;
    ltag.destroy;
    c := cSpmCfg.create;
    t.cfg := c;
    addTaho(t);
  end
  else
    exit;
  m_ShiftLeft := strtofloatext(a_pIni.ReadString(str, 'ShiftLeft', '0.05'));
  m_Length := strtofloatext(a_pIni.ReadString(str, 'Length', '0.05'));
  // амплитуда для поиска события
  t.m_treshold := strtofloatext(a_pIni.ReadString(str, 'Threshold', '0.05'));
  m_spmTrig:= strtofloatext(a_pIni.ReadString(str, 'TrigLvl', '0.05'));

  m_minX := strtofloatext(a_pIni.ReadString(str, 'Spm_minX', '0'));
  m_maxX := strtofloatext(a_pIni.ReadString(str, 'Spm_maxX', '1000'));
  m_minY := strtofloatext(a_pIni.ReadString(str, 'Spm_minY', '0.0001'));
  m_maxY := strtofloatext(a_pIni.ReadString(str, 'Spm_maxY', '10'));
  m_lgX := a_pIni.ReadBool(str, 'Spm_Lg_x', false);
  m_lgY := a_pIni.ReadBool(str, 'Spm_Lg_y', false);
  NewAxis := a_pIni.ReadBool(str, 'TahoNewAxis', false);
  m_saveT0 := a_pIni.ReadBool(str, 'SaveT0', false);
  m_showflags := a_pIni.ReadBool(str, 'ShowFlags', false);
  m_showBandLab := a_pIni.ReadBool(str, 'ShowBandLabels', false);
  m_estimator := a_pIni.ReadInteger(str, 'Estimator', 1);
  ResTypeRG.ItemIndex:= a_pIni.readInteger(str, 'EvalType', 0);
  HideExcelCB.Checked:=a_pIni.ReadBool(str, 'HideExcel', false);
  g_FrfFactory.m_hideExcel:=HideExcelCB.Checked;
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
        s := c.addSRS(pointer(ltag));
        s.m_axis := a_pIni.ReadInteger(str, 'Axis_' + inttostr(i), 0);
        s.m_incPNum := a_pIni.ReadInteger(str, 'Pinc_' + inttostr(i), 0);
      end;
    end;
    c.typeres := a_pIni.ReadInteger(str, 'ResType', 0);
  end;
  m_WelchShift := a_pIni.ReadInteger(str, 'WelchShift', 32);
  m_WelchCount := a_pIni.ReadInteger(str, 'WelchBlockCount', 4);
  m_UseWelch := a_pIni.ReadBool(str, 'useWelch', true);
  WelchCB.Checked := m_UseWelch;
  UpdateChart;
  ShowSignalsLV;
  ShowLines;
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
    BlockWrite(f, tdoublearray(db.m_mod.p)[0], sizeof(double) * db.m_spmsize);
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
  ident: string; xUnits: string);
begin
  WriteFloatToIniMera(ifile, ident, 'Freq', Freq);
  ifile.WriteString(ident, 'XFormat', 'R8');
  ifile.WriteString(ident, 'YFormat', 'R8');
  // Подпись оси x
  ifile.WriteString(ident, 'XUnits', xUnits);
  // Подпись оси Y
  // ifile.WriteString(s.tagname, 'YUnits', TagUnits(wp.m_YParam.tag));
  WriteFloatToIniMera(ifile, ident, 'Start', start);
  // k0
  ifile.WriteFloat(ident, 'k0', 0);
  // k1
  ifile.WriteFloat(ident, 'k1', 1);
  if xUnits = 'с' then
  begin
    ifile.WriteString(ident, 'Function', '1');
    ifile.WriteString(ident, 'XType', '5');
    // напряжение
    ifile.WriteString(ident, 'YType', '160');
    ifile.WriteString(ident, 'XUnitsId', '0x100000501');
    ifile.WriteString(ident, 'YUnitsId', '0x100003201');
  end;
end;

procedure TFRFFrm.SaveBtnClick(sender: tobject);
var
  i, j, num: integer;
  ifile: TIniFile;
  f, ident, dir: string;
  c: cSpmCfg;
  t: cSRSTaho;
  s: cSRSres;
  db, tb: TDataBlock;
begin
  // dir := extractfiledir(g_FrfFactory.m_meraFile) + '\Shock';
  if g_mbase.SelectBlade=nil then
  begin
    StatusEdit.Text:='Не выбрана лопатка';
    StatusEdit.color:=clPink;
    exit;
  end;

  dir := extractfiledir(g_mbase.SelectBlade.getFolder) + '\Shock';
  f := dir + '\' + trimext(extractfilename(g_FrfFactory.m_MeraFile))
    + '_Shocks.mera';
  while fileexists(f) do
  begin
    dir := ModName(dir, false);
    f := dir + '\' + trimext(extractfilename(g_FrfFactory.m_MeraFile))
      + '_Shocks.mera';
  end;
  m_MeraFile := f;
  g_FrfFactory.m_ShockFile := f;
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
      if (tb=nil) or (db = nil) then
      begin
        continue;
      end;
      num := s.m_shockList.Count - j;
      // spm
      ident := 'spm_' + s.m_tag.tagname + '_' + inttostr(num);
      saveHeader(ifile, 1 / c.fspmdx, 0, ident, 'Гц');
      // frf
      ident := 'frf_' + s.m_tag.tagname + '_' + inttostr(num);
      saveHeader(ifile, 1 / c.fspmdx, 0, ident, 'Гц');
      // временной блок
      ident := s.m_tag.tagname + '_' + inttostr(num);
      if m_saveT0 then
        saveHeader(ifile, s.m_tag.Freq, db.m_timeStamp.x, ident, 'с')
      else
        saveHeader(ifile, s.m_tag.Freq, 0, ident, 'с');
      savedata(f, s.m_tag.tagname + '_' + inttostr(num), db, false);

      if i = 0 then
      begin
        ident := t.m_tag.tagname + '_' + inttostr(num);
        if m_saveT0 then
          saveHeader(ifile, t.m_tag.Freq, tb.m_timeStamp.x, ident, 'с')
        else
          saveHeader(ifile, t.m_tag.Freq, 0, ident, 'с');
        savedata(f, ident, tb, true);
      end;
    end;

    ident := 'AvFRF_' + s.m_tag.tagname;
    // ident := extractfiledir(ident) + '\'+'AvFRF_'+s.m_tag.tagname+'.dat';
    saveHeader(ifile, 1 / c.fspmdx, 0, ident, 'Гц');
    savedata(f, s.m_tag.tagname, s);
  end;
  ifile.destroy;
  CheckFlags;
end;

procedure TFRFFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
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
    WriteFloatToIniMera(a_pIni, str, 'ShiftLeft', m_ShiftLeft);
    WriteFloatToIniMera(a_pIni, str, 'Threshold', t.m_treshold);
    WriteFloatToIniMera(a_pIni, str, 'Length', m_Length);
    WriteFloatToIniMera(a_pIni, str, 'CohThreshold', t.m_CohTreshold);
    WriteFloatToIniMera(a_pIni, str, 'TrigLvl', TrigFE.Value);

    WriteFloatToIniMera(a_pIni, str, 'Spm_minX', m_minX);
    WriteFloatToIniMera(a_pIni, str, 'Spm_maxX', m_maxX);
    WriteFloatToIniMera(a_pIni, str, 'Spm_minY', m_minY);
    WriteFloatToIniMera(a_pIni, str, 'Spm_maxY', m_maxY);
    a_pIni.WriteBool(str, 'Spm_Lg_x', m_lgX);
    a_pIni.WriteBool(str, 'Spm_Lg_y', m_lgY);
    a_pIni.WriteBool(str, 'SaveT0', m_saveT0);
    a_pIni.WriteBool(str, 'TahoNewAxis', m_newAx);
    a_pIni.WriteInteger(str, 'Estimator', m_estimator);
    a_pIni.WriteInteger(str, 'EvalType', ResTypeRG.ItemIndex);
    a_pIni.WriteBool(str, 'ShowFlags', m_showflags);
    a_pIni.WriteBool(str, 'ShowBandLabels', m_showBandLab);
    a_pIni.WriteBool(str, 'HideExcel', HideExcelCB.Checked);
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
        a_pIni.WriteInteger(str, 'Axis_' + inttostr(i), s.m_axis);
        a_pIni.WriteInteger(str, 'Pinc_' + inttostr(i), s.m_incPNum);
      end;
    end;
    a_pIni.WriteInteger(str, 'WelchBlockCount', m_WelchCount);
    a_pIni.WriteInteger(str, 'WelchShift', m_WelchShift);
    a_pIni.WriteBool(str, 'useWelch', m_UseWelch);
  end;
end;

procedure TFRFFrm.setNewAx(b: boolean);
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
      if t <> nil then
      begin
        a := caxis(t.line.parent);
        axRef.AddChild(t.line);
      end;
      // showmessage(inttostr(a.childcount));
    end;
  end;
  m_newAx := b;
end;

procedure TFRFFrm.ShowShock(shock: integer);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  i, j: integer;
  block, tahobl: TDataBlock;
  lax_X:point2d;
  a:caxis;
  r:frect;
  o:cdrawobj;
begin
  t := getTaho;
  if t = nil then
    exit;
  c := t.cfg;
  tahobl := t.m_shockList.getBlock(shock);
  t.line.AddPoints(TDoubleArray(tahobl.m_TimeBlockFlt.p), tahobl.m_TimeArrSize);
  for i := 0 to c.m_SRSList.Count - 1 do
  begin
    s := c.GetSrs(i);
    s.lineAvFRF.visible := true;
    // for j := 0 to s.m_shockList.Count - 1 do
    if (shock < s.m_shockList.Count) and (shock > -1) then
    begin
      block := s.m_shockList.getBlock(shock);
      s.line.AddPoints(TDoubleArray(block.m_TimeBlockFlt.p),
        block.m_TimeArrSize);
    end;
  end;
  lax_X:=p2d(TimeAx.min.x,TimeAx.max.x);
  SpmChartDblClick(nil);

  // нормализация времени
  for i := 0 to pageT.axises.ChildCount - 1 do
  begin
    a := pageT.getaxis(i);
    r.BottomLeft.x := lax_X.x;
    r.TopRight.x := lax_X.y;
    r.BottomLeft.y := a.min.y;
    r.TopRight.y := a.max.y;
    a.ZoomfRect(r);
    for j := 0 to a.ChildCount - 1 do
    begin
      o := cdrawobj(a.getChild(j));
      o.doUpdateWorldSize(a);
    end;
  end;
  fUpdateFrf := true;
  UpdateView;
end;

procedure TFRFFrm.ShowSignalsLV;
var
  t: cSRSTaho;
  s: cSRSres;
  i: integer;
  c: cSpmCfg;
  li: TListItem;
begin
  t := getTaho;
  c := t.cfg;
  SignalsLV.clear;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    li := SignalsLV.Items.Add;
    li.Data := s;
    SignalsLV.SetSubItemByColumnName('№', inttostr(i + 1), li);
    SignalsLV.SetSubItemByColumnName('Имя', s.m_tag.tagname, li);
  end;
end;

procedure TFRFFrm.ShowPhase;
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  b: TDataBlock;
begin
  t := getTaho;
  c := t.getCfg;
  if c <> nil then
  begin
    s := ActiveSignal;
    if s <> nil then
    begin
      s.linePhase.AddPoints(TDoubleArray(s.m_phase), c.fHalfFft);
    end;
  end;
end;

procedure TFRFFrm.ShowSpm;
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  b: TDataBlock;
begin
  t := getTaho;
  c := t.getCfg;
  if c <> nil then
  begin
    s := ActiveSignal;
    if s <> nil then
    begin
      b := s.m_shockList.getBlock(ShockIE.intnum);
      if b <> nil then
      begin
        if s.lineSpm <> nil then
          s.lineSpm.AddPoints(TDoubleArray(b.m_mod.p), c.fHalfFft);
      end;
    end;
  end;
end;

procedure TFRFFrm.SignalsLVClick(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  lcount: integer;
  i: integer;
begin
  t := getTaho;
  if t = nil then
    exit;
  if t.m_shockList.Count = 0 then
    exit;
  c := t.cfg;
  s := ActiveSignal;
  ShowLines;
  lcount := CheckedCount;
  if lcount = 0 then
  begin
    if ResTypeRG.ItemIndex = 0 then
    begin
      if fShowLast then
        ShowFrf(s, c, -1)
      else
        ShowFrf(s, c, ShockIE.intnum);
    end;
  end
  else
  begin
    // ShowLines(nil);
  end;
  fShowLast := false;
  SpmChart.redraw;
end;

procedure TFRFFrm.SignalsLVColumnBtnClick(item: TListItem; lv: TListView);
begin
  SignalsLVClick(nil);
end;

procedure TFRFFrm.SPMcbClick(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
begin
  t := getTaho;
  c := t.getCfg;
  s := c.GetSrs(ShockIE.intnum);
  s.lineFrf.visible := ResTypeRG.ItemIndex = 0;
  s.lineAvFRF.visible := ResTypeRG.ItemIndex = 0;
  s.lineSpm.visible := ResTypeRG.ItemIndex = 2;
  UpdateView;
end;

function TFRFFrm.GetSelectValue(s: csrsres; x: double;
                                shockIndex:integer): double;
var
  c:cSpmCfg;
  ind:integer;
  y, y1,y2, x1:double;
  db:TDataBlock;
begin
  result:=0;
  c:=s.cfg;
  ind := trunc(x / c.fspmdx);
  db:=s.m_shockList.getBlock(shockIndex);
  if db=nil then exit;

  case ResTypeRG.ItemIndex of
    0: // frf
    begin
      y1:=db.m_frf[ind];
      y2:=db.m_frf[ind+1];
    end;
    1: // coh
    begin
      y1:=s.m_shockList.m_coh[ind];
      y2:=s.m_shockList.m_coh[ind+1];
    end;
    2: // spm
    begin
      y1:=tdoublearray(db.m_mod.p)[ind];
      y2:=tdoublearray(db.m_mod.p)[ind+1];
    end;
    3: // phase
    begin
      y1:=(180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[ind].im / s.m_shockList.m_Cxy[ind].Re);
      y2:=(180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[ind+1].im /
              s.m_shockList.m_Cxy[ind+1].Re);
    end;
  end;
  x1:=ind * c.fspmdx;
  y := EvalLineYd(x, p2d(x1, y1), p2d(x1+c.fspmdx, y2));
  result:=y;
end;

function InBand(x:double; x1,x2:double):boolean;
begin
  result:=false;
  if x>x1 then
  BEGIN
    if x<x2 then
      result:=true;
  END;
end;

function getDecrement(line:cBuffTrend1d; extr:point2d):double;
var
  i, extrI:integer;
  v1,v2, f1, f2:Double;
  p1,p2:point2d;
begin
  extrI:=line.GetLowInd(extr.x);
  v1:=line.GetXByInd(extrI);
  v2:=line.GetXByInd(extrI+1);
  if abs(v1-extr.x)>abs(v2-extr.x) then
    extrI:=extrI+1;
  v1:=extr.y*0.5;
  i:=extri;
  while line.data_r[i]>v1 do
  begin
    dec(i);
    if i=0 then
    begin
      result:=-1;
      exit;
    end;
  end;
  p1.x:=line.GetXByInd(i);
  p1.y:=line.GetYByInd(i);
  p2.x:=line.GetXByInd(extri);
  p2.y:=line.GetYByInd(extri);
  f1:=EvalLineX(v1, p1, p2);
  i:=extri;
  while line.data_r[i]>v1 do
  begin
    inc(i);
    if (i=length(line.data_r)-1) then
    begin
      result:=-1;
      exit;
    end;
  end;
  p1.x:=line.GetXByInd(i);
  p1.y:=line.GetYByInd(i);
  p2.x:=line.GetXByInd(extri);
  p2.y:=line.GetYByInd(extri);
  f2:=EvalLineX(v1, p1, p2);;
  result:=(f2-f1)/(2*extr.x);
end;

procedure TFRFFrm.SpmChartCursorMove(sender: tobject);
var
  t: cSRSTaho;
  c: cSpmCfg;
  s: cSRSres;
  a: caxis;
  b:tSpmBand;
  tb: TDataBlock;
  j, ind: integer;
  x1, y: double;
  li: TListItem;
  p: TNotifyEvent;
  p2: point2;
  lp2:point2d;
  d:double;
begin
  if sender is cYCursor then
  begin
    a := pageSpm.activeAxis;
    // p2:=cYCursor(Sender).Position; возвращает координаты в FullView
    p2 := cYCursor(sender).Position;
    p2 := pageSpm.p2FullViewToBorderP2(p2);
    p2 := pageSpm.Point2ToTrend(p2, false, a);
    if m_lgY then
    begin
      p2.y := ValToLogScale(p2.y, p2d(a.minY, a.maxY));
    end;
    p := TrigFE.OnChange;
    TrigFE.OnChange := nil;
    TrigFE.Value := p2.y;
    TrigFE.OnChange := p;
  end;
  // если курсор на спектрах
  if SpmChart.activePage = pageSpm then
  begin
    t := getTaho;
    if t = nil then
      exit;
    c := t.cfg;
    x1 := pageSpm.cursor.getx1;
    if pageSpm.lgX then
      x1 := pageSpm.cursor.LinearToLgPos(x1);
    m_curFreq := x1;
    for j := 0 to c.SRSCount - 1 do
    begin
      s := c.GetSrs(j);
      li := SignalsLV.Items[j];
      ind:=trunc(x1/s.cfg.fspmdx);
      SignalsLV.SetSubItemByColumnName('Ind', inttostr(ind), li);
      SignalsLV.SetSubItemByColumnName('X', formatstr(x1, 4), li);
      y := GetSelectValue(s, x1, shockie.IntNum);
      SignalsLV.SetSubItemByColumnName('Y', formatstrnoe(y, 4), li);
    end;
    LVChange(SignalsLV);
    // поиск демпфирования
    s:=ActiveSignal;
    for j := 0 to m_bands.Count - 1 do
    begin
      b:=m_bands.getband(j);
      if InBand(m_curFreq, b.m_f1,b.m_f2 ) then
      begin
        lp2.x:=b.m_freqband.m_realX;
        if b.m_freqband.m_realX>0 then
        begin
          lp2.y:=s.lineFrf.GetY(lp2.x);
          d:=getDecrement(s.lineFrf, lp2);
          DempfE.Text:='F: '+formatstrnoe(lp2.x,3)+' D: '+formatstrnoe(d,4);
        end;
      end;
    end;
  end;
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
      if t.m_shockList.Count <> 0 then
      begin
        tb := t.m_shockList.getBlock(ShockIE.intnum);
        t.line.AddPoints(TDoubleArray(tb.m_TimeBlockFlt.p), tb.m_TimeArrSize);
      end;
    end;
  end;
  //updateFrf(false);
  //UpdateView;
end;

procedure TFRFFrm.SpmChartDblClick(sender: tobject);
var
  r: frect;
  i, j: integer;
  a: caxis;
  o: cdrawobj;
  rect: frect;
  v:double;
  dy: single;
begin
  r.BottomLeft.x := m_minX;
  r.TopRight.x := m_maxX;
  r.BottomLeft.y := MinSpmY;
  r.TopRight.y := MaxSpmY;
  // нормализация спектров
  for i := 0 to pageSpm.axises.ChildCount - 1 do
  begin
    a := pageSpm.getaxis(i);
    a.ZoomfRect(r);
    if a.Lg then
      v:=evalLogPos( a.minY, a.maxY, TrigFE.Value)
    else
      v:=TrigFE.Value;
    Ycurs.setCursor(a, v);
  end;
  // нормализация времени
  for i := 0 to pageT.axises.ChildCount - 1 do
  begin
    a := pageT.getaxis(i);
    rect := pageT.getbound(a);
    dy := rect.TopRight.y - rect.BottomLeft.y;
    dy := dy * 0.1;
    rect.TopRight.y := rect.TopRight.y + dy;
    rect.BottomLeft.y := rect.BottomLeft.y - dy;
    a.ZoomfRect(rect);
    for j := 0 to a.ChildCount - 1 do
    begin
      o := cdrawobj(a.getChild(j));
      o.doUpdateWorldSize(a);
    end;
  end;
end;

procedure TFRFFrm.SpmChartMouseZoom(sender: tobject; UpScale: boolean);
var
  p: cpage;
  a: caxis;
  v:double;
begin
  if Ycurs <> nil then
  begin
    p := pageSpm;
    a := p.activeAxis;
    //Ycurs.setCursor(a, (a.maxY + a.minY) * 0.5);
    if a.Lg then
      v:=evalLogPos( a.minY, a.maxY, TrigFE.Value)
    else
      v:=TrigFE.Value;

    Ycurs.setCursor(a, v);
  end;
end;

procedure TFRFFrm.TrigFEChange(Sender: TObject);
var
  p: cpage;
  a: caxis;
  v:double;
begin
  p := pageSpm;
  a := p.activeAxis;
  if a.Lg then
    v:=evalLogPos( a.minY, a.maxY, TrigFE.Value)
  else
    v:=TrigFE.Value;
  Ycurs.setCursor(a, v);
  SpmChart.Repaint;
end;


procedure TFRFFrm.ShockSBDownClick(sender: tobject);
var
  t: cSRSTaho;
  block, tahobl: TDataBlock;
begin
  t := getTaho;
  if t = nil then
    exit;
  if ShockIE.intnum > 0 then
  begin
    ShockIE.intnum := ShockIE.intnum - 1;
    ShowShock(ShockIE.intnum);
  end;
end;

procedure TFRFFrm.EvalWelchBCount;
var
  t: cSRSTaho;
  c: cSpmCfg;
  lastpos: integer;
begin
  t := getTaho;
  c := t.cfg;
  if t = nil then
    exit;
  lastpos := trunc(m_Length * t.m_tag.Freq) - c.m_fftCount;
  if lastpos > 0 then
    m_WelchCount := trunc(lastpos / m_WelchShift) + 1
  else
    m_WelchCount := 1;
end;

procedure TFRFFrm.ShockSBUpClick(sender: tobject);
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

procedure TFRFFrm.TestCoh;
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
  result := nil;
  if fSpmCfgList.Count > 0 then
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
var
  pline: cProfileLine;
begin
  inherited;
  m_profile := cprofile.create;
  m_profile.newline('Profile', 1);
  m_profile.AddP(1, 1, ptlinePoly, false);
  m_profile.AddP(1000, 1, ptlinePoly, false);

  m_treshold := 1;
  m_CohTreshold := 0.5;
  m_tag := ctag.create;
  fSpmCfgList := tlist.create;

  m_shockList := TDataBlockList.create;
end;

destructor cSRSTaho.destroy;
begin
  m_profile.destroy;
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
  for i := 0 to TFRFFrm(m_frm).m_WelchCount - 1 do
  begin
    fft_al_d_sse(TDoubleArray(tb.m_TimeBlockFlt.p),
      TCmxArray_d(tb.m_ClxData.p), plan);
    // MULT_SSE_al_cmpx_d(TCmxArray_d(tb.m_ClxData.p), k);
    fft_al_d_sse(TDoubleArray(sb.m_TimeBlockFlt.p),
      TCmxArray_d(sb.m_ClxData.p), plan);
    // MULT_SSE_al_cmpx_d(TCmxArray_d(sb.m_ClxData.p), k);
    plan.StartInd := TFRFFrm(m_frm).m_WelchShift + plan.StartInd;
    for j := 0 to halfNP - 1 do
    begin
      sb.m_WechSpm[j] := sb.m_WechSpm[j] + TCmxArray_d(sb.m_ClxData.p)[j];
      tb.m_WechSpm[j] := tb.m_WechSpm[j] + TCmxArray_d(tb.m_ClxData.p)[j];
    end;
  end;
  k := 2 / (c.m_fftCount * TFRFFrm(m_frm).m_WelchCount);
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
            s.m_phase[j] := (180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[j].im / s.m_shockList.m_Cxy[j].Re);
            // Sensor/Taho
            s.m_frf[j] := sqrt(s.m_shockList.m_Syy[j] / s.m_shockList.m_Sxx[j]);
          end;
        end;
      1: // H1 Syx/Sxx  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            s.m_phase[j] := (180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[j].im / s.m_shockList.m_Cxy[j].Re);
            s.m_frf[j] := abs(s.m_shockList.m_Cxy[j]) / s.m_shockList.m_Sxx[j];
          end;
        end;
      2: // H1 Syy/Sxy  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            s.m_phase[j] := (180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[j].im / s.m_shockList.m_Cxy[j].Re);
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
    // ZeroMemory(s.m_shockList.m_Cxy, length(s.m_shockList.m_Cxy) * sizeof(TComplex_d));
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
        if TFRFFrm(m_frm).m_Frf_Yx then // sres/taho
        begin
          v1 := TDoubleArray(sd.m_mod.p)[j];
          v2 := TDoubleArray(td.m_mod.p)[j];
        end
        else
        begin
          v2 := TDoubleArray(sd.m_mod.p)[j];
          v1 := TDoubleArray(td.m_mod.p)[j];
        end;
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
            s.m_phase[j] := (180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[j].im / s.m_shockList.m_Cxy[j].Re);
            // if s.m_shockList.m_coh[j] < m_CohTreshold then
            s.m_frf[j] := s.m_frf[j] / shockCount;
          end;
        end;
      1: // H1 Syx/Sxx  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            cross := 0;
            v2 := 0;
            s.m_phase[j] := (180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[j].im / s.m_shockList.m_Cxy[j].Re);
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
            if TFRFFrm(m_frm).m_Frf_Yx then // sres/taho
            begin
              s.m_frf[j] := abs(cross) / v2;
            end
            else
            begin
              s.m_frf[j] := v2/abs(cross);
            end;
          end;
        end;
      2: // H1 Syy/Sxy  x - тахо
        begin
          for j := 0 to cfg.fHalfFft - 1 do
          begin
            cross := 0;
            v1 := 0;
            s.m_phase[j] := (180 / pi) * ArcTan
              (s.m_shockList.m_Cxy[j].im / s.m_shockList.m_Cxy[j].Re);
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
            if TFRFFrm(m_frm).m_Frf_Yx then // sres/taho
            begin
              s.m_frf[j] := v1/abs(cross);
            end
            else
            begin
              s.m_frf[j] := abs(cross) / v1;
            end;
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

function cSpmCfg.addSRS(s: pointer): cSRSres;
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
        result := ls;
        if t = ls.m_tag.tag then
          exit;
      end;
      ls := cSRSres.create;
      ls.m_tag.tag := t;
      ls.cfg := self;
      result := ls;
      m_SRSList.Add(ls);
      ls.m_color := ColorArray[m_SRSList.Count];
      ls.m_colorAlt := ColorArray[length(ColorArray) - m_SRSList.Count];
    end
  end
  else
  begin
    if tobject(s) is cSRSres then
    begin
      for i := 0 to m_SRSList.Count - 1 do
      begin
        ls := cSRSres(m_SRSList.Items[i]);
        result := ls;
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
        result := ls;
        if ctag(s).tagname = ls.m_tag.tagname then
        begin
          ctag(s).destroy;
          exit;
        end;
      end;
      ls := cSRSres.create;
      result := ls;
      ls.m_tag := ctag(s);
      ls.cfg := self;
      m_SRSList.Add(ls);
      ls.m_color := ColorArray[m_SRSList.Count];
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

procedure cSpmCfg.delSRS(s: tobject);
var
  i: integer;
  res: cSRSres;
begin
  for i := 0 to SRSCount - 1 do
  begin
    res := GetSrs(i);
    if res = s then
    begin
      m_SRSList.delete(i);
      break;
    end;
  end;
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

function cSpmCfg.GetSrs(s: string): cSRSres;
var
  res: cSRSres;
  i: integer;
begin
  result := nil;
  for i := 0 to m_SRSList.Count - 1 do
  begin
    res := GetSrs(i);
    if res.m_tag.tagname = s then
    begin
      result := res;
      exit;
    end;
  end;
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
  m_extremums := tlist.create;
  // с запасиком
  setlength(m_decrement,100);
end;

destructor cSRSres.destroy;
begin
  m_tag.destroy;
  m_tag := nil;
  m_shockList.destroy;
  cfg.delSRS(self);
  cfg := nil;
  m_extremums.destroy;
  if line <> nil then
    line.destroy;
  if lineSpm <> nil then
    lineSpm.destroy;
  if lineCoh <> nil then
    lineCoh.destroy;
  if lineFrf <> nil then
    lineFrf.destroy;
  if lineAvFRF <> nil then
    lineAvFRF.destroy;
end;

function cSRSres.getTaho: cSRSTaho;
begin
  result := nil;
  if cfg <> nil then
  begin
    result := cSRSTaho(cfg.taho);
  end;
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

procedure cSRSres.updateBlock(p_spmsize, p_timeBlock: integer);
var
  j: integer;
  bl: TDataBlock;
begin
  for j := 0 to m_shockList.Count - 1 do
  begin
    bl := m_shockList.getBlock(j);
    if bl.m_spmsize <> p_spmsize then
    begin
      bl.m_spmsize := p_spmsize;
      bl.m_TimeArrSize := p_timeBlock;
      FreeMemAligned(bl.m_TimeBlockFltNull);
      GetMemAlignedArray_d(p_spmsize, bl.m_TimeBlockFltNull);
    end;
  end;
end;

{ cSRSFactory }

constructor cFRFFactory.create;
begin
  inherited;
  g_mbase := cBladeBase.create;
  g_mbase.InitBaseFolder('c:\Mera Files\bladeMdb\');

  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_SRS;
  createevents;
end;

destructor cFRFFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cFRFFactory.CreateBands(f: TFRFFrm; base: cBladeBase);
var
  i, j, c: integer;
  blade: cBladeFolder;
  b: tspmband;
  p3: point3d;
  li: TListItem;
  t: cSRSTaho;
  s: cSRSres;
begin
  f.m_bands.clearData;
  blade := base.SelectBlade;
  if blade <> nil then
  begin
    c := blade.ToneCount;
    for i := 0 to c - 1 do
    begin
      p3 := blade.Tone(i);
      b := f.m_bands.addband(p3.x, p3.y, p3.z, f.SpmChart);
      b.m_freqband.m_LineLabel.visible := f.m_showBandLab;
    end;
    t := f.getTaho;
    if t <> nil then
    begin
      for i := 0 to t.cfg.SRSCount - 1 do
      begin
        s := t.cfg.GetSrs(i);
        SetLength(s.m_flags, c);
      end;
    end;
    f.UpdateBandNames;
  end;
end;

procedure cFRFFactory.createevents;
begin
  // addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cSRSFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;

procedure cFRFFactory.destroyevents;
begin
  // RemovePlgEvent(doUpdateData, c_RUpdateData);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cFRFFactory.doAfterLoad;
begin
  inherited;
end;

procedure cFRFFactory.doChangeRState(sender: tobject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
      end;
    RSt_StopToView:
      begin
        g_FrfFactory.m_MeraFile := GetMeraFile;
        doStart;
      end;
    RSt_StopToRec:
      begin
        g_FrfFactory.m_MeraFile := GetMeraFile;
        doStart;
      end;
    RSt_ViewToStop:
      begin
        doStop;
      end;
    RSt_ViewToRec:
      begin
        g_FrfFactory.m_MeraFile := GetMeraFile;
      end;
    RSt_initToRec:
      begin
        g_FrfFactory.m_MeraFile := GetMeraFile;
        doStart;
      end;
    RSt_initToView:
      begin
        g_FrfFactory.m_MeraFile := GetMeraFile;
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

function cFRFFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := ISRSFrm.create();
  end;
end;

procedure cFRFFactory.doDestroyForms;
begin
  inherited;
end;

function fgetcolor(li: TListItem): integer;
begin
  result := rgbtoint(cSRSres(li.Data).m_color);
end;

procedure cFRFFactory.doRecorderInit;
var
  i, j: integer;
  Frm: TRecFrm;
  s: cSRSres;
  t: cSRSTaho;
  c: cSpmCfg;
  blade: cBladeFolder;
begin
  // exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TFRFFrm(Frm).Ycurs := cYCursor.create;
    TFRFFrm(Frm).pageSpm.AddChild(TFRFFrm(Frm).Ycurs);

    TFRFFrm(Frm).SignalsLV.drawcolorbox := true;
    TFRFFrm(Frm).SignalsLV.getcolor := fgetcolor;
    TFRFFrm(Frm).TrigFE.Value:=TFRFFrm(Frm).m_spmTrig;
    t := TFRFFrm(Frm).getTaho;
    if t <> nil then
    begin
      if t.m_tag.tag = nil then
      begin
        t.m_tag.tag := getTagByName(t.m_tag.tagname);
      end;
      for j := 0 to t.cfg.SRSCount - 1 do
      begin
        s := t.cfg.GetSrs(j);
        if s.m_tag.tag = nil then
        begin
          s.m_tag.tag := getTagByName(s.m_tag.tagname);
        end;
      end;
      TFRFFrm(Frm).UpdateBlocks;
    end;
    CreateBands(TFRFFrm(Frm), g_mbase);

    blade := g_mbase.SelectBlade;
    if blade <> nil then
    begin
      TFRFFrm(Frm).BladeNumEdit.Text := inttostr(blade.m_sn);
    end;
  end;
end;

procedure cFRFFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
end;

procedure cFRFFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TFRFFrm(Frm).doStart;
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

procedure cFRFFactory.doStop;
var
  path: string;
  i: integer;
  f: TFRFFrm;
begin
  for i := 0 to Count - 1 do
  begin
    f := TFRFFrm(GetFrm(i));
  end;
end;

procedure cFRFFactory.doUpdateData;
var
  i: integer;
  Frm: TRecFrm;
begin
  if g_disableFRF then
    exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TFRFFrm(Frm).updatedata;
  end;
end;

{ ISRSFrm }

procedure ISRSFrm.doClose;
begin
  m_lRefCount := 1;
end;

function ISRSFrm.doCreateFrm: TRecFrm;
begin
  result := TFRFFrm.create(nil);
end;

function ISRSFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function ISRSFrm.doRepaint: boolean;
begin
  inherited;
  TFRFFrm(m_pMasterWnd).UpdateView;
end;

{ TDataBlock }

procedure TDataBlock.BuildSpm;
var
  k, v: double;
  c: cSpmCfg;
  t: cSRSTaho;
  maxT, maxS: double;
  i, ind: integer;
begin
  c := TDataBlockList(m_owner).m_cfg;
  if addnull then
  begin
    fft_al_d_sse(TDoubleArray(m_TimeBlockFlt.p),
      TDoubleArray(m_TimeBlockFltNull.p),
      TCmxArray_d(m_ClxData.p), cSpmCfg(c).FFTProp);
    k := 2 / m_TimeArrSize;
  end
  else
  begin
    fft_al_d_sse(TDoubleArray(m_TimeBlockFlt.p), TCmxArray_d(m_ClxData.p),
      cSpmCfg(c).FFTProp);
    // расчет первого спектра
    k := 2 / c.m_fftCount;
  end;

  MULT_SSE_al_cmpx_d(TCmxArray_d(m_ClxData.p), k);
  // расчет по m_ClxData квадрат амплитудн спектра
  evalmod2;
  EvalSpmMag(TCmxArray_d(m_ClxData.p), TDoubleArray(m_mod.p));
  // FindMaxAndIndex(TDoubleArray(m_mod.p), v, ind);
end;

constructor TDataBlock.create;
begin
  m_connectedInd := -1;
end;

procedure TDataBlock.evalmod2;
var
  i: integer;
  c: TComplex_d;
begin
  for i := 0 to length(m_mod2) - 1 do
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
  tb: TDoubleArray; // timeblock
  p_timesize: integer): TDataBlock; // размер очередного блока
begin
  result := addBlock(p_spmsize);
  result.m_timeStamp := time;


  // дополняем нулями
  if p_timesize < p_spmsize then
  begin
    // p_timesize := p_spmsize;
  end;
  if p_timesize > result.m_timecapacity then
  begin
    SetLength(result.m_TimeBlock, p_timesize);
    result.m_timecapacity := p_timesize;
    GetMemAlignedArray_d(p_timesize, result.m_TimeBlockFlt);
    result.addnull := false;
    if p_spmsize > p_timesize then
    begin
      result.addnull := true;
      // выделяем память под блок с дополнением нулями
      GetMemAlignedArray_d(p_timesize + p_spmsize - p_timesize,
        result.m_TimeBlockFltNull);
    end;
  end;
  if p_timesize>0 then
  begin
    GetMemAlignedArray_cmpx_d(p_spmsize, result.m_ClxData);
    GetMemAlignedArray_d(p_spmsize, result.m_mod);
    // src/ dst/ count
    system.move(tb[0], result.m_TimeBlock[0], p_timesize * sizeof(double));
    result.m_TimeArrSize := p_timesize;
  end
  else
  begin
    result.m_TimeArrSize := 0;
  end;
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
        // обрабатываем только часть порции начиная с x0
        for i := 1 to n - 1 do
        begin
          x := x + dx;
          if wnd.y = 0 then
            wnd.y := 0.000001;
          // wnd.x2 - wnd.x1 - нормировка на длину окна
          // в точке x2 экспонента равна заданному значению в точке y2
          TDoubleArray(m_TimeBlockFlt.p)[i + j] := m + (m_TimeBlock[i + j] - m)
            * exp(ln(wnd.y) * (x - wnd.x1) / (wnd.x2 - wnd.x1));
        end;
      end;
  end;
  // сдвиг нуля (центрирование)
  m:=mean(m_TimeBlock);
  SubtractFromArray_SSE_Double(TDoubleArray(m_TimeBlockFlt.p),m);
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
      delete(i);
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
    for j := 0 to  length(s.m_Cxy) - 1 do // проход по спектру
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
  // усреднение по серии ударов
  k := 1 / (n);
  for j := 0 to length(s.m_Cxy) - 1 do
  begin
    m_coh[j] := mod2(m_Cxy[j]) / (m_Sxx[j] * m_Syy[j]);
    // делаем средний кросс спектр
    m_Cxy[j] := m_Cxy[j] * k;
  end;
end;

function TDataBlockList.getBlock(tstamp: double): TDataBlock;
var
  i: integer;
  bl: TDataBlock;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    bl := getBlock(i);
    if bl.m_timeMax = tstamp then
    begin
      result := bl;
      exit;
    end;
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
    if a.lg or p.lgX then
    begin
      // CompileLineLg;
    end
    else
    begin
      a := caxis(parent);
      p := cpage(GetPage);
      if a.lg or p.lgX then
      begin
        inherited;
      end
      else
      begin
        EvalBound;
        EvalA;
        // подготовка к компиляции списка
        if m_DisplayListName <> 0 then
        begin
          glDeleteLists(m_DisplayListName, 1);
          m_DisplayListName := 0;
        end;
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
  Color := orange;
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
  // константа для градуировки точки x1 y1
  // exp(-fA*x1)=y1
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

function cExpFuncObj.GetPos: point2;
begin
  case fTestObj of
    0:
      ;
    1:
      begin
        result.x := m_x0;
        result.y := fy0;
      end;
    2:
      begin
        result.x := m_x1;
        result.y := m_y1 * fdy + faxmin;
      end;
  end;
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
        if fdy = 0 then
          m_y1 := 0
        else
        begin
          if p.y < faxmin then
            p.y := faxmin;
          m_y1 := (p.y - faxmin) / fdy;
        end;
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
  page: cpage;
begin
  result := false;
  page := cpage(GetPage);
  fTestObj := 0;

  lp2.x := p_p2.x - m_x1;
  lp2.y := p_p2.y - fy1;
  lDist := sqrt(lp2.x * lp2.x + lp2.y * lp2.y);
  dist := dist * 2;
  // page.Caption:=floattostr(p_p2.x)+' '+floattostr(p_p2.y);
  if lDist < dist then
  begin
    // page.Caption:='test 2';
    fTestObj := 2;
    result := true;
    exit;
  end;

  lp2.x := p_p2.x - m_x0;
  lp2.y := p_p2.y - fy0;
  lDist := sqrt(lp2.x * lp2.x + lp2.y * lp2.y);
  if lDist < dist then
  begin
    // page.Caption:='test 1';
    fTestObj := 1;
    result := true;
  end;
end;

end.
