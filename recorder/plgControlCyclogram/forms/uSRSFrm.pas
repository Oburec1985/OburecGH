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
  math, uAxis,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons;

type
  cSpmCfg = class;

  // структура для хранения удара
  TDataBlock = class
  public
    m_timeStamp:double;
    m_timeInd:integer; // для синхронизации.блок srs хранит индекс блока тахо
    m_timecapacity:integer;
    // размер для m_TimeBlock
    m_TimeArrSize:integer;
    m_size:integer;
    m_spm:TCmxArray_d;
    m_frf,
    m_mod2,
    m_mod:TDoubleArray;
    m_TimeBlock:TDoubleArray;
  protected
    find:integer; // индекс в tlist;
  protected
    // вычислить амплитуду^2
    procedure evalmod2;
    procedure setsize(s:integer);
    function getsize:integer;
  public
    property size:integer read getsize write setsize;
  end;

  TDataBlockList = class(tlist)
  public
    // когеренция по списку ударов
    m_coh:TDoubleArray;
    // кроссспектр ударов
    m_Cxy: TCmxArray_d; // Sxy
    m_Sxx, m_Syy: TDoubleArray;
    m_LastBlock:integer;
    m_shockCount:integer;// общее число ударов за все время
    m_cfg:cspmcfg;
  public
    procedure evalCoh(TahoShockList:TDataBlockList);
    procedure clearData;
    function getBlock(i:integer):TDataBlock;
    function getLastBlock:TDataBlock;overload;
    function getLastBlock(d:TDataBlock):TDataBlock;overload;
    function getPrevBlock(d:TDataBlock):TDataBlock;
    // добавить спектр удара data - TCmxArray_d
    function addBlock(data:pointer; dsize:integer):TDataBlock;overload;
    function addBlock(data:pointer; spmMag:tdoublearray; dsize:integer; time:double; tb:TDoubleArray; psize:integer):TDataBlock;overload;
    constructor create;
    destructor destroy;
  end;

  cSRSres = class;
 // конфигуратор расчета спектра
  cSpmCfg = class
  public
    // ограничение по количеству ударов
    m_capacity:integer;
    // FFTplan
    FFTProp:TFFTProp;
    // число точек fft, число блоков по которым идет расчет спектров,
    m_fftCount,fHalfFft,
    m_blockcount:integer;
    // добавлять нули
    m_addNulls: boolean;
  private
    ftypeRes:integer;
    // разрешение спектра
    fspmdx: double;
    // размер порции по которой идет расчет (length*fs*blockCount) в сек.
    fportionsize: double;
    // размер порции по которой идет расчет в отсчетах
    fportionsizei:integer;
    // размер блока по которому идет расчет fft. Если не дополнять нулями то равен m_fftCount*m_blockcount
    // иначе полезных данных в блоке будет m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // количество отсчетов дополняемых нулями
    fNullsPoints:integer;
  public
    taho:tobject;
    // список сигналов к обработке
    m_SRSList:Tlist;
  protected
    procedure settyperes(t:integer);
  public
    procedure addSRS(s:pointer);
    function GetSrs(i:integer):cSRSres;
    function SRSCount:integer;
    function name:string;
    property typeres:integer read ftyperes write settyperes;
    constructor create;
    destructor destroy;
  end;

  cSRSres = class
  public
    m_tag:ctag;
  public
    m_SpmDx:double;
    m_freq:double;
    // размер блока для расчета спектра = freq*Numpoints
    blSize:double;
    // блок данных по которому идет расчет.
    m_T1data: TAlignDarray;
    fDataCount:integer; // количество данных в m_T1data
    // спектр re_im
    m_T1ClxData:TAlignDCmpx;
    // спектр амплитуд
    m_rms:TAlignDarray;
    // синтезированная передаточная характеристика
    m_frf,
    m_phase: TDoubleArray;
    line, lineSpm, lineCoh, lineFrf,
    // усредненная Frf
    lineAvFRF:cBuffTrend1d;
    // список ударов (TDataBlock)
    m_shockList:TDataBlockList;
    // обработан последний удар
    m_shockProcessed:boolean;
  private
    fcfg:cSpmCfg;
    fComInt:point2d;
    // найден общий интервал с взведенным тригом
    //fComInterval:boolean;
    fComIntervalLen:double;
  protected
    procedure setcfg(c:cSpmCfg);
  public
    property cfg:cSpmCfg read fcfg write setcfg;
    function name:string;
    constructor create;
    destructor destroy;
  end;
  // выключен/ найден/ завершен TrEnd - накоплены данные для удара на тахо канале
  TtrigStates = (TrOff, TrRise, TrFall,  TrEnd);

  cSRSTaho = class
  public
    m_CohTreshold,
    // Амплдитуда для обнаружения события
    m_treshold:double;
    // отступ слева и длительность
    m_ShiftLeft, m_Length:double;
    m_tag:ctag;
    // блок данных по которому идет расчет. Размер fportionsizei = length*ShockCount
    m_T1data: TAlignDarray;
    fDataCount:integer; // количество данных в m_T1data
    // спектр re_im
    m_T1ClxData:TAlignDCmpx;
    // тот же спектр, но амплитуда
    m_rms: TAlignDarray;
    line, lineSpm:cBuffTrend1d;

    // список ударов (TDataBlock)
    m_shockList:TDataBlockList;
  private // переменные для обсчета в алгоритме обработки
    v_min, v_max:double;
    f_imin, f_imax, // индексы отсчетов содержащих максимум и минимум в текущем ударе
    f_iEnd:integer; // индекс последнего отсчета в текущем ударе
    fTrigState:TtrigStates;
    // номер удара в серии
    fShockInd:integer;
    // начало и конец найденного для обработки удара
    TrigInterval:point2d;
  private
    fSpmCfgList:TList;
  protected
    procedure setCfg(c:cSpmCfg);
    function getCfg(i:integer):cSpmCfg;overload;
    function GetCfg:cSpmCfg;overload;
    // когда найден новый триггер, старый пора сбросить:
    // например обнулить общий интевал
    procedure resetTrig;
  public
    property Cfg:cSpmCfg read getcfg write setcfg;
    function CfgCount:integer;
    procedure evalCoh;
    procedure evalFRF;
    function name:string;
    constructor create;
    destructor destroy;
  end;

  TSRSFrm = class(TRecFrm)
    SpmChart: cChart;
    RightGB: TGroupBox;
    ShockCountLabel: TLabel;
    ShockCountE: TEdit;
    EvalFRF: TButton;
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
    procedure FormCreate(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure WinPosBtnClick(Sender: TObject);
    procedure ShockSBDownClick(Sender: TObject);
    procedure ShockSBUpClick(Sender: TObject);
    procedure SpmChartDblClick(Sender: TObject);
    procedure SaveMdbBtnClick(Sender: TObject);
    procedure CompareBtnClick(Sender: TObject);
  public
    ready:boolean;
    pageT, pageSpm:cpage;
    axSpm, axCoh:cAxis;
    // список настроек Тахо
    m_TahoList:TList;
    // spm
    m_lgX, m_lgY:boolean;
    m_minX, m_maxX:double;
    m_minY, m_maxY:double;
  public
    PROCEDURE ShowShock(shock: integer);
    procedure BuildSpm(s:tobject);
    procedure UpdateView;
    procedure updatedata;
    // выделение памяти. происходит при загрузке или смене конфига
    procedure UpdateBlocks;
    procedure UpdateChart;
    procedure doStart;
    procedure addTaho(t:csrstaho);
    function getTaho:csrstaho;
    procedure RBtnClick(sender: tobject);
    procedure TestCoh;
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent);override;
    destructor destroy;override;
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
    m_meraFile:string;
    m_ShockFile:string;
  private
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
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
  function copyData(t:ctag; var time:point2d; buf:TAlignDarray):integer;


var
  SRSFrm: TSRSFrm;
  g_SRSFactory: cSRSFactory;

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

function copyData(t:ctag;var time:point2d; buf:TAlignDarray):integer;
var
  int:tpoint;
begin
  int:=t.getIntervalInd(time);
  if int.x<0 then // если предыстория не успела накопиться
  begin
    time.x:=time.x-int.x/t.freq;
    int.x:=0;
  end;
  result:=int.Y-int.x;
  move(t.m_ReadData[int.x], buf.p^, result*sizeof(double));
end;

{ TSRSFrm }
procedure TSRSFrm.addTaho(t: csrstaho);
begin
  m_tahoList.Add(t);
end;

procedure TSRSFrm.BuildSpm(s: tobject);
var
  k,v:double;
  c:cSpmCfg;
  t:cSRSTaho;
  maxT, maxS:double;
  i, halfNP:integer;
begin
  if s is cSRSTaho then
  begin
    c:=cSRSTaho(s).Cfg;
    fft_al_d_sse(TDoubleArray(cSRSTaho(s).m_T1data.p),
                tCmxArray_d(cSRSTaho(s).m_T1ClxData.p),
                cSpmCfg(c).FFTProp);
    // расчет первого спектра
    k := 2 / c.m_fftCount;
    halfNP:=c.m_fftCount shr 1;
    MULT_SSE_al_cmpx_d(tCmxArray_d(cSRSTaho(s).m_T1ClxData.p), k);
    EvalSpmMag(tCmxArray_d(cSRSTaho(s).m_T1ClxData.p),
               TDoubleArray(cSRSTaho(s).m_rms.p));
  end;
  if s is cSRSres then
  begin
    c:=cSRSres(s).cfg;
    fft_al_d_sse(TDoubleArray(cSRSres(s).m_T1data.p),
                tCmxArray_d(cSRSres(s).m_T1ClxData.p),
                cSpmCfg(c).FFTProp);
    // расчет первого спектра
    k := 2 / c.m_fftCount;
    halfNP:=c.m_fftCount shr 1;
    MULT_SSE_al_cmpx_d(tCmxArray_d(cSRSres(s).m_T1ClxData.p), k);
    EvalSpmMag(tCmxArray_d(cSRSres(s).m_T1ClxData.p),
               TDoubleArray(cSRSres(s).m_rms.p));
    //if c.m_typeRes=c_FRF then
    if false then // блок отключен т.к. считаем только усредненную FRF
    begin
      t:=getTaho;
      //maxT:=MaxValue(TDoubleArray(t.m_rms.p));
      for I := 0 to c.fHalfFft - 1 do
      begin
        v:=TDoubleArray(cSRSres(s).m_rms.p)[i];
        k:=TDoubleArray(t.m_rms.p)[i];
        //if (k/maxT)<0.1 then
        //begin
        //  TDoubleArray(cSRSres(s).m_rms.p)[i]:=0.00001;
        //end
        //else
        //begin
        TDoubleArray(cSRSres(s).m_rms.p)[i]:=v/k;
        //end;
      end;
    end;
  end;
end;

procedure TSRSFrm.CompareBtnClick(Sender: TObject);
var
  o:cObjFolder;
  t:cTestFolder;
  path:string;
  ifile: TIniFile;
  f, sname: string;
begin
  if g_MBaseControl<>nil then
  begin
    o:=g_MBaseControl.GetSelectObj;
    t:=g_MBaseControl.GetSelectTest;
    if o<>nil then
    begin
      path:=g_mbase.m_BaseFolder.Absolutepath;
      if o.ObjType<>'' then
      begin
        path:= path+'\FrfTypes'+'\'+o.ObjType;
        f:=path+'\frf.mera';
        if fileexists(f) then
          ShellExecute(0,nil,pwidechar(f),nil,nil, SW_HIDE);
      end;
    end;
  end;
end;

constructor TSRSFrm.create(Aowner: tcomponent);
begin
  m_TahoList:=TList.Create;
  inherited;
end;

destructor TSRSFrm.destroy;
begin
  m_TahoList.Destroy;
end;

procedure TSRSFrm.doStart;
var
  t:cSRSTaho;
  I: Integer;
  s:cSRSres;
begin
  ready:=false;
  t:=getTaho;
  t.fTrigState:=TrOff;
  if t.m_tag <> nil then
  begin
    t.m_tag.doOnStart;
    t.m_shockList.clearData;
    t.f_iEnd:=0;
    ZeroMemory(t.m_T1data.p,  t.cfg.fportionsizei* sizeof(double));
    if t.cfg<>nil then
    begin
      for I := 0 to t.Cfg.SRSCount - 1 do
      begin
        s:=t.Cfg.GetSrs(i);
        s.m_tag.doOnStart;
        s.m_shockList.clearData;
        ZeroMemory(s.m_T1data.p,  t.cfg.fportionsizei* sizeof(double));
        ZeroMemory(s.m_frf, t.Cfg.fHalfFft* sizeof(double));
      end;
    end
    else
      exit;
  end
  else
  begin
    exit;
  end;
  ready:=true;
end;

procedure TSRSFrm.FormCreate(Sender: TObject);
var
  p:cpage;
  r:frect;
begin
  spmchart.OnRBtnClick := RBtnClick;
  spmchart.tabs.activeTab.addPage(true);

  p:=SpmChart.tabs.activeTab.GetPage(0);
  r.BottomLeft.x:=0;
  r.BottomLeft.y:=0;
  r.TopRight.x:=10;
  r.TopRight.y:=10;
  p.ZoomfRect(r);
  p.Caption:='Oscillogram';
  pageT:=p;
  p:=SpmChart.tabs.activeTab.GetPage(1);
  r.BottomLeft.x:=0;
  r.BottomLeft.y:=0;
  r.TopRight.x:=10;
  r.TopRight.y:=10;
  p.ZoomfRect(r);
  p.Caption:='Freq Dom.';
  pageSpm:=p;
  axSpm:=p.activeAxis;

  axCoh:=cAxis.create;
  axCoh.name:='CoherenceAx';
  p.addaxis(axCoh);
  axCoh.min:=p2d(0,0);
  axCoh.max:=p2d(10, 2);
end;

procedure TSRSFrm.UpdateBlocks;
var
  refresh:double;
  lt:csrstaho;
  c:cSpmCfg;
  s:cSRSres;
  I: Integer;
begin
  refresh:=GetREFRESHPERIOD;
  lt:=getTaho;
  c:=lt.cfg;
  c.fHalfFft:= c.m_fftCount shr 1;
  // размер блока для расчета в секундах
  c.fportionsize:= lt.m_Length*c.m_blockcount;
  c.fportionsizei:=round(c.fportionsize*lt.m_tag.freq);
  c.fOutSize := c.m_fftCount * c.m_blockcount;
  c.fspmdx:=lt.m_tag.freq/c.m_fftCount;
  c.FFTProp:=GetFFTPlan(c.m_fftCount);
  c.FFTProp.StartInd:=0;

  GetMemAlignedArray_d(c.fportionsizei, lt.m_T1data);
  GetMemAlignedArray_cmpx_d(c.m_fftCount, lt.m_T1ClxData);
  GetMemAlignedArray_d(c.m_fftCount, lt.m_rms);
  lt.lineSpm.dx:=c.fspmdx;
  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    GetMemAlignedArray_d(c.fportionsizei, s.m_T1data);
    // tCmxArray_d(cSRSres(s).m_T1ClxData.p)
    GetMemAlignedArray_cmpx_d(c.m_fftCount, s.m_T1ClxData);
    GetMemAlignedArray_d(c.fHalfFft, s.m_rms);
    SetLength(s.m_frf, c.fHalfFft);
    SetLength(s.m_phase, c.fHalfFft);
    // блок расчета когеренции
    setlength(s.m_shockList.m_Cxy, c.fHalfFft);
    setlength(s.m_shockList.m_sxx, c.fHalfFft);
    setlength(s.m_shockList.m_syy, c.fHalfFft);
    setlength(s.m_shockList.m_coh, c.fHalfFft);

    s.lineSpm.dx:=c.fspmdx;
    s.lineCoh.dx:=c.fspmdx;
    s.lineFrf.dx:=c.fspmdx;
    s.lineAvFrf.dx:=c.fspmdx;
  end;
end;


procedure TSRSFrm.UpdateChart;
var
  l:cBuffTrend1d;
  t:csrstaho;
  c:cSpmCfg;
  s:cSRSres;
  I: Integer;
  fr:frect;
begin
  pageT.activeAxis.clear;
  pageSpm.activeAxis.clear;
  t:=getTaho;
  if t<>nil then
  begin
    l:= cBuffTrend1d.create;
    pageT.activeAxis.AddChild(l);
    l.color := ColorArray[0];
    t.line:=l;
    t.line.name:=t.name;
    l.dx:=1/t.m_tag.freq;

    l:= cBuffTrend1d.create;
    l.color := ColorArray[0];
    pageSpm.activeAxis.AddChild(l);
    t.lineSpm:=l;
    t.lineSpm.name:=t.name+'_spm';

    c:=t.Cfg;
    for I := 0 to c.SRSCount - 1 do
    begin
      s:=c.GetSrs(i);
      l:= cBuffTrend1d.create;
      pageT.activeAxis.AddChild(l);
      l.color := ColorArray[i+1];
      s.line:=l;
      s.line.name:=s.name;
      l.dx:=1/t.m_tag.freq;

      l:= cBuffTrend1d.create;
      l.color := ColorArray[i+1];
      pageSpm.activeAxis.AddChild(l);
      s.lineSpm:=l;
      s.lineSpm.name:=s.name+'_spm';

      l:= cBuffTrend1d.create;
      l.color := ColorArray[i+1];
      pageSpm.activeAxis.AddChild(l);
      s.linefrf:=l;
      s.linefrf.name:=s.name+'_frf';

      l:= cBuffTrend1d.create;
      l.color := ColorArray[i+2];
      pageSpm.activeAxis.AddChild(l);
      s.lineavfrf:=l;
      s.lineavfrf.name:=s.name+'_AvFrf';
      s.lineAvFRF.weight:=5;
      s.lineAvFRF.visible:=false;

      l:= cBuffTrend1d.create;
      //l.color := ColorArray[i+10];
      l.color := yellow;
      l.dx:=1/t.m_tag.freq;
      axCoh.AddChild(l);
      s.lineCoh:=l;
      s.lineCoh.name:=s.name+'_coh';
    end;
    c.typeres:=c.typeres;

    fr.BottomLeft:=p2(0,-2*t.m_treshold);
    fr.TopRight:=p2(t.m_Length,t.m_treshold*2);
    pageT.ZoomfRect(fr);

    fr.BottomLeft:=p2(m_minX,m_minY);
    fr.TopRight:=p2(m_maxX,m_maxY);
    pageSpm.LgX:=m_lgX;
    pageSpm.activeAxis.Lg:=m_lgY;
    pageSpm.ZoomfRect(fr);
  end;
end;

procedure TSRSFrm.updatedata;
var
  t:csrstaho;
  c:cSpmCfg;
  s:cSRSres;
  i, pcount ,dropCount:integer;
  sig_interval, common_interval:point2d;
  b:boolean;
  v, comIntervalLen, blocklen, refresh, dropLen:double;
begin
  if not ready then exit;
  t:=getTaho;
  c:=t.cfg;
  blocklen:=t.m_Length;
  refresh:=t.m_tag.BlockSize/t.m_tag.freq;
  if blocklen<refresh then
    blocklen:=refresh;
  if t.m_tag.UpdateTagData(true) then
  begin
    // не отбрасываем данные если находимся в состоянии когда триг найден но
    // еще не накопился целиком
    if t.fTrigState<>TrFall then
    begin
      dropLen:=t.m_tag.getPortionLen-2*blocklen;
      if dropLen>0 then // при этом условии гарантированно остается 2*blocklen
      begin
        dropCount:=trunc(dropLen*t.m_tag.freq);
        // возможно следует ограничить размер отбрасываемых данных
        // по f_iEnd
        if t.f_iEnd>0 then
        begin
          if dropCount>t.f_iEnd then
            dropCount:=t.f_iEnd;
        end;
        t.m_tag.ResetTagDataTimeInd(dropCount);
        t.f_iEnd:=t.f_iEnd-dropCount;
        if t.f_iEnd<0 then
        begin
          t.f_iEnd:=0;
          // если просохатили удар (отбросили данные в посл. ударе, забываем про него)
          t.ResetTrig;
        end;
      end;
    end;
    t.v_min := t.m_tag.m_ReadData[0];
    t.v_max := t.m_tag.m_ReadData[0];
    // поиск триггера
    if t.fTrigState=TrOff then
    begin
      for i := t.f_iEnd to t.m_tag.lastindex - 1 do
      begin
        v := t.m_tag.m_ReadData[i];
        if v > t.m_treshold then
        begin
          if v>t.v_max then
          begin
            t.fTrigState:=TrRise;
            t.v_max := v;
            t.f_imax := i;
          end;
        end
        else
        begin
          if t.fTrigState=TrRise then
            t.fTrigState:=TrFall;
        end;
      end;
      // сдвигаем индекс проанализированных данных т.к. отбрасываемые данные ограничены iEnd
      // в противном случае можно отбросить не проанализированные данные
      if t.fTrigState=TrOff then
        t.f_iEnd:=t.m_tag.lastindex;
    end;
    // если триггер найден
    if t.fTrigState=TrFall then
    begin
      inc(t.fShockInd);
      t.TrigInterval.x:=t.m_tag.getReadTime(t.f_imax)-t.m_ShiftLeft;
      t.TrigInterval.y:=t.TrigInterval.x+t.m_Length;
      t.f_iEnd:=t.m_tag.getIndex(t.TrigInterval.y);
      // если данных накопилось на целиковый удар
      if t.f_iEnd<=t.m_tag.lastindex then
      begin
        t.fTrigState:=TrEnd;
        pcount:=copyData(t.m_tag, t.TrigInterval, t.m_T1data);
        t.fDataCount:=pcount;
        t.line.AddPoints(TDoubleArray(t.m_T1data.p), pcount);
        t.line.flength:=pcount;
        if pcount>c.m_fftCount then
        begin
          BuildSpm(t);
          t.m_shockList.addBlock(t.m_T1ClxData.p,
                                 tdoublearray(t.m_rms.p),
                                 c.fHalfFft,
                                 t.TrigInterval.x,
                                 TDoubleArray(t.m_T1data.p), pcount);
          t.lineSpm.AddPoints(TDoubleArray(t.m_rms.p), c.fHalfFft);
        end
        else
        begin

        end;
      end;
    end;
    if t.fTrigState=TrEnd then
    begin
      b:=true;
      for i := 0 to c.SRSCount - 1 do
      begin
        s := c.GetSrs(i);
        if s.m_shockProcessed=false then
        begin
          b:=false;
          break;
        end;
      end;
      if b then // стоит еще добавить проверку на отвалившийся датчик. В случае если
      // какой то канал не накопил удар, игнорируем его по таймауту
      begin
        t.evalFRF;
        // внутри вызывается t.fTrigState:=TrOff;
        t.ResetTrig;
      end;
    end;
    for i := 0 to c.SRSCount - 1 do
    begin
      s := c.GetSrs(i);
      if s.m_tag.UpdateTagData(true) then
      begin
        sig_interval := s.m_tag.getPortionTime;
        if s.m_tag.getPortionLen>2*blocklen then
        begin
          dropCount:=s.m_tag.getIndex(t.TrigInterval.x);
          // отбрасываем все что слева по времени от найденного удара
          if dropCount>0 then
          begin
            s.m_tag.ResetTagDataTimeInd(dropCount-1);
          end;
        end;
      end;
      common_interval:=p2d(0,0);
      ComIntervalLen:=0;
      if sig_interval.y>t.TrigInterval.x then
      begin
        if t.TrigInterval.y>sig_interval.x then
        begin
          common_interval:=getCommonInterval(sig_interval, t.TrigInterval);
          ComIntervalLen:=common_interval.y-common_interval.x;
        end;
      end;
      if ComIntervalLen>0 then
      begin
        //s.fComInterval:=true;
        // если данные накопились и тахо тоже накопился
        if (ComIntervalLen>s.fComIntervalLen) and (t.fTrigState=TrEnd)  then
        begin
          s.fComIntervalLen:=ComIntervalLen;
          s.fComInt:=common_interval;
          pcount:=copyData(s.m_tag, common_interval, s.m_T1data);
          if pCount>c.m_fftCount then
          begin
            s.fDataCount:=pcount;
            s.line.AddPoints(TDoubleArray(s.m_T1data.p), pcount);
            s.line.flength:=pcount;

            BuildSpm(s);
            s.m_shockList.addBlock(cSRSres(s).m_T1ClxData.p, // Spm Cmplx
                                   tdoublearray(s.m_rms.p), // SpmMag
                                   c.fHalfFft, // SpmSize
                                   common_interval.x, // timeStamp
                                   TDoubleArray(s.m_T1data.p), // timeData
                                   pcount); // timeData size
            s.lineSpm.AddPoints(TDoubleArray(s.m_rms.p), c.fHalfFft);

            s.m_shockProcessed:=true;
          end;
          t.evalCoh;
        end;
      end;
    end;
  end;
end;

procedure TSRSFrm.UpdateView;
var
  i: integer;
  c:cSpmCfg;
  t:cSRSTaho;
  s:cSRSres;
begin
  if RStatePlay then
  begin
    t:=getTaho;
    if t<>nil then
    begin
      ShockCountE.Text:=inttostr(t.m_shockList.Count);
    end;
  end;
  SpmChart.redraw;
end;

procedure TSRSFrm.WinPosBtnClick(Sender: TObject);
begin
  if fileexists(g_SRSFactory.m_meraFile) then
    ShellExecute(0,nil,pwidechar(g_SRSFactory.m_ShockFile),nil,nil, SW_HIDE);
end;

function TSRSFrm.getTaho: csrstaho;
begin
  if m_taholist.count>0 then
    result:=csrstaho(m_tahoList.Items[0])
  else
    result:=nil;
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
  i, count: integer;
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
  tag:itag;
  ltag:ctag;
begin
  inherited;
  ltag:=LoadTagIni(a_pIni,str,'Taho_Tag');
  if ltag<>nil then
  begin
    t:=cSRSTaho.create;
    t.m_tag.tag:=ltag.tag;
    ltag.destroy;
    c:=cSpmCfg.Create;
    t.Cfg:=c;
    addTaho(t);
  end
  else
    exit;
  t.m_ShiftLeft:=strtoFloatExt(a_pIni.ReadString(str, 'ShiftLeft', '0.05'));
  t.m_treshold:=strtoFloatExt(a_pIni.ReadString(str, 'Threshold', '0.05'));
  t.m_Length:=strtoFloatExt(a_pIni.ReadString(str, 'Length', '0.05'));

  m_minX:=strtoFloatExt(a_pIni.ReadString(str, 'Spm_minX', '0'));
  m_maxX:=strtoFloatExt(a_pIni.ReadString(str, 'Spm_maxX', '1000'));
  m_minY:=strtoFloatExt(a_pIni.ReadString(str, 'Spm_minY', '0.0001'));
  m_maxY:=strtoFloatExt(a_pIni.ReadString(str, 'Spm_maxY', '10'));
  m_lgX:=a_pIni.ReadBool(str, 'Spm_Lg_x', false);
  m_lgY:=a_pIni.ReadBool(str, 'Spm_Lg_y', false);

  if c<>nil then
  begin
    c.m_fftCount:=a_pIni.ReadInteger(str, 'FFtnum', 32);
    c.m_blockcount:=a_pIni.ReadInteger(str, 'BlockCount', 1);
    c.m_addNulls:=a_pIni.ReadBool(str, 'AddNulls', false);
    count:=a_pIni.ReadInteger(str, 'SigCount', 0);
    for I := 0 to count - 1 do
    begin
      tag:=LoadITagIni(a_pIni,str,'Tag_'+inttostr(i));
      if tag<>nil then
      begin
        c.addSRS(pointer(tag));
      end;
    end;
    c.typeRes:=a_pIni.ReadInteger(str, 'ResType', 0);
  end;
  // TestCoh;
  UpdateChart;
  UpdateBlocks;
end;


procedure savedata(dir: string;sname:string;db:tDoubleArray); overload;
var
  lname: string;
  f: file;
begin
  // временной блок
  lname := dir + '\' + sname+'.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, db[0], sizeof(double) * length(db));
  closefile(f);
end;

procedure savedata(fname: string;sname:string;db:tdatablock; taho:boolean); overload;
var
  lname: string;
  f: file;
  i: integer;
begin
  if not taho then
  begin
    lname := extractfiledir(fname) + '\'+'spm_'+sname+'.dat';
    AssignFile(f, lname);
    Rewrite(f, 1);
    BlockWrite(f, db.m_mod[0], sizeof(double) * db.m_size);
    closefile(f);

    lname := extractfiledir(fname) + '\'+'frf_'+sname+'.dat';
    AssignFile(f, lname);
    Rewrite(f, 1);
    BlockWrite(f, db.m_frf[0], sizeof(double) * db.m_size);
    closefile(f);
  end;
  // временной блок
  lname := extractfiledir(fname) + '\' + sname+'.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, db.m_TimeBlock[0], sizeof(double) * db.m_TimeArrSize);
  closefile(f);
end;

procedure saveHeader( ifile:tinifile; freq:double; start:double; ident:string);
begin
  WriteFloatToIniMera(ifile, ident, 'Freq', freq);
  ifile.WriteString(ident, 'XFormat', 'R8');
  ifile.WriteString(ident, 'YFormat', 'R8');
  // Подпись оси x
  ifile.WriteString(ident, 'XUnits', 'Гц');
  // Подпись оси Y
  // ifile.WriteString(s.tagname, 'YUnits', TagUnits(wp.m_YParam.tag));
  WriteFloatToIniMera(ifile, ident,'Start', start);
  // k0
  ifile.WriteFloat(ident, 'k0', 0);
  // k1
  ifile.WriteFloat(ident, 'k1', 1);
end;

procedure TSRSFrm.SaveBtnClick(Sender: TObject);
var
  i, j, num: integer;
  ifile: TIniFile;
  f,ident,dir: string;
  c:cSpmCfg;
  t:cSRSTaho;
  s: cSRSres;
  db, tb:tdatablock;
begin
  dir := extractfiledir(g_SRSFactory.m_merafile) + '\Shock\';
  f := dir + trimext(extractfilename(g_SRSFactory.m_merafile)) + '_Shocks.mera';
  g_SRSFactory.m_ShockFile:=f;
  ForceDirectories(dir);
  ifile := TIniFile.create(f);
  c:=getTaho.Cfg;
  t:=getTaho;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    for j := 0 to s.m_shockList.Count - 1 do
    begin
      if j=0 then
      begin
        db:=s.m_shockList.getLastBlock;
        tb:=t.m_shockList.getLastBlock;
      end
      else
      begin
        db:=s.m_shockList.getPrevBlock(db);
        tb:=t.m_shockList.getPrevBlock(tb);
      end;
      num:=s.m_shockList.Count-j;
      // spm
      ident:='spm_'+ s.m_tag.tagname+'_'+inttostr(num);
      saveHeader(ifile,1/c.fspmdx, 0, ident);
      // frf
      ident:='frf_'+ s.m_tag.tagname+'_'+inttostr(num);
      saveHeader(ifile,1/c.fspmdx, 0,ident);
      // временной блок
      ident:=s.m_tag.tagname+'_'+inttostr(num);
      saveHeader(ifile, s.m_tag.freq, db.m_timeStamp, ident);
      saveData(f, s.m_tag.tagname+'_'+inttostr(num),db, false);

      if i=0 then
      begin
        ident:=t.m_tag.tagname+'_'+inttostr(num);
        saveHeader(ifile,t.m_tag.freq, tb.m_timeStamp, ident);
        saveData(f, ident,tb, true);
      end;
    end;
  end;
  ifile.destroy;
end;


procedure TSRSFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
begin
  inherited;
  t:=getTaho;
  if t<>nil then
  begin
    saveTagToIni(a_pIni,t.m_tag,str,'Taho_Tag');
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

    c:=t.Cfg;
    if c<>nil then
    begin
      a_pIni.WriteInteger(str, 'FFtnum', c.m_fftCount);
      a_pIni.WriteInteger(str, 'BlockCount', c.m_blockcount);
      a_pIni.WriteBool(str, 'AddNulls', c.m_addNulls);
      a_pIni.WriteInteger(str, 'SigCount', c.SRSCount);
      a_pIni.WriteInteger(str, 'ResType', C.typeRes);
      for I := 0 to c.SRSCount - 1 do
      begin
        s:=c.GetSrs(i);
        saveTagToIni(a_pIni,s.m_tag,str,'Tag_'+inttostr(i));
      end;
    end;
  end;
end;

procedure TSRSFrm.ShowShock(shock: integer);
var
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
  I, j: Integer;
  block, tahobl:TDataBlock;
begin
  t:=getTaho;
  if t=nil then exit;
  c:=t.Cfg;
  for I := 0 to c.m_SRSList.Count - 1 do
  begin
    s:=c.GetSrs(i);
    s.lineAvFRF.visible:=true;
    //for j := 0 to s.m_shockList.Count - 1 do
    if (shock<s.m_shockList.Count) and (shock>-1) then
    begin
      block:=s.m_shockList.getBlock(shock);
      tahobl:=t.m_shockList.getBlock(shock);
      s.lineFrf.AddPoints(block.m_frf, c.fHalfFft);
      s.line.flength:=block.m_TimeArrSize;
      s.line.AddPoints(block.m_TimeBlock, block.m_TimeArrSize);
      t.line.flength:=tahobl.m_TimeArrSize;
      t.line.AddPoints(tahobl.m_TimeBlock, tahobl.m_TimeArrSize);
      SpmChartDblClick(nil);
      SpmChart.redraw;
    end;
  end;
end;


procedure TSRSFrm.SpmChartDblClick(Sender: TObject);
var
  r:frect;
begin
  r.BottomLeft.x:=m_minX;
  r.BottomLeft.y:=m_minY;
  r.TopRight.x:=m_maxX;
  r.TopRight.y:=m_maxY;
  pageSpm.activeAxis:=axSpm;
  pageSpm.ZoomfRect(r);
end;

procedure TSRSFrm.ShockSBDownClick(Sender: TObject);
var
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
  I, j: Integer;
  block, tahobl:TDataBlock;
begin
  t:=getTaho;
  if t=nil then exit;
  c:=t.Cfg;
  if ShockIE.IntNum>0 then
  begin
    ShockIE.IntNum:=ShockIE.IntNum-1;
    ShowShock(ShockIE.IntNum);
  end;
end;


procedure TSRSFrm.ShockSBUpClick(Sender: TObject);
var
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
  I, j: Integer;
  block, tahobl:TDataBlock;
begin
  t:=getTaho;
  if t=nil then exit;
  c:=t.Cfg;
  if ShockIE.IntNum<t.m_shockList.Count-1 then
  begin
    ShockIE.IntNum:=ShockIE.IntNum+1;
    ShowShock(ShockIE.IntNum);
  end;
end;

procedure TSRSFrm.TestCoh;
var
  c:cSpmCfg;
  t:cSRSTaho;
  s:cSRSres;
  d1:TCmxArray_d;
  cmx:TComplex_d;
begin
  t:=getTaho;
  c:=t.Cfg;
  s:=c.GetSrs(0);

  setlength(d1, 1);
  cmx.Re:=-30.25475291;cmx.im:=-82.46784439;
  d1[0]:=cmx;
  t.m_shockList.addBlock(@d1[0],1);
  cmx.Re:=14.69077253;cmx.im:=-86.75400644;
  d1[0]:=cmx;
  t.m_shockList.addBlock(@d1[0],1);

  cmx.Re:=-30.25475291;cmx.im:=-82.46784439;
  d1[0]:=cmx;
  s.m_shockList.addBlock(d1,1);
  cmx.Re:=-74.66651386;cmx.im:=45.57920805;
  d1[0]:=cmx;
  s.m_shockList.addBlock(d1,1);

  setlength(s.m_shockList.m_Cxy, 1);
  setlength(s.m_shockList.m_sxx, 1);
  setlength(s.m_shockList.m_syy, 1);
  setlength(s.m_shockList.m_coh, 1);
  s.m_shockList.evalCoh(t.m_shockList);
end;

{ cSRSTaho }
procedure cSRSTaho.setCfg(c: cSpmCfg);
var
  lc:cSpmCfg;
begin
 if fSpmCfgList.Count>0 then
 begin
   lc:=cSpmCfg(fSpmCfgList.Items[0]);
   lc.Destroy;
   fSpmCfgList.Clear;
 end;
 c.taho:=self;
 m_shockList.m_cfg:=c;
 fSpmCfgList.Add(c);
end;

function cSRSTaho.GetCfg: cSpmCfg;
begin
  result:=cSpmCfg(fSpmCfgList.items[0]);
end;

function cSRSTaho.GetCfg(i: integer): cSpmCfg;
begin
  result:=cSpmCfg(fSpmCfgList.items[i]);
end;

function cSRSTaho.CfgCount: integer;
begin
  result:=fSpmCfgList.Count;
end;

constructor cSRSTaho.create;
begin
  inherited;
  m_treshold:=1;
  m_CohTreshold:=0.5;
  // отступ слева и длительность
  m_ShiftLeft:=0.05;
  m_Length:=1;
  m_tag:=cTag.create;
  fSpmCfgList:=TList.Create;

  m_shockList:=TDataBlockList.Create;
end;

destructor cSRSTaho.destroy;
begin
  m_tag.destroy;
  fSpmCfgList.Destroy;
  m_shockList.Destroy;
  inherited;
end;

procedure cSRSTaho.evalCoh;
var
  I, shockCount: Integer;
  c:cSpmCfg;
  s:cSRSres;
begin
  c:=cfg;
  shockCount:=m_shockList.Count;
  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    if (shockCount=s.m_shockList.Count) and (m_shockList.m_LastBlock=s.m_shockList.m_LastBlock) then
    begin
      s.m_shockList.evalCoh(m_shockList);
      s.lineCoh.AddPoints(s.m_shockList.m_coh, c.fHalfFft);
    end;
  end;
end;

procedure cSRSTaho.evalFRF;
var
  I, k, shockCount: Integer;
  c:cSpmCfg;
  s:cSRSres;
  td, sd:TDataBlock;
  j: Integer;
  v1,v2:double;
begin
  c:=cfg;
  shockCount:=m_shockList.Count;
  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    ZeroMemory(s.m_frf,length(s.m_frf)*sizeof(double));
    td:=nil;
    sd:=nil;
    for k := 0 to s.m_shockList.Count - 1 do
    begin
      td:=m_shockList.getLastBlock(td);
      sd:=s.m_shockList.getLastBlock(sd);
      for j := 0 to Cfg.fHalfFft - 1 do
      begin
        v1:=sd.m_mod[j];
        v2:=td.m_mod[j];
        sd.m_frf[j]:=v1/v2;
        s.m_frf[j]:=sd.m_frf[j]+s.m_frf[j];
      end;
    end;
    for j := 0 to Cfg.fHalfFft - 1 do
    begin
      s.m_phase[j]:=(180/pi)*s.m_shockList.m_Cxy[j].Im/s.m_shockList.m_Cxy[j].re;
      if s.m_shockList.m_coh[j]<m_CohTreshold then
      begin
        s.m_frf[j]:=0;
      end
      else
      begin
        s.m_frf[j]:=s.m_frf[j]/s.m_shockList.Count;
      end;
    end;
    s.lineavfrf.AddPoints(s.m_frf, c.fHalfFft);
    s.linefrf.AddPoints(s.m_frf, c.fHalfFft);
  end;
end;

procedure cSRSTaho.ResetTrig;
var
  c:cSpmCfg;
  I: Integer;
  s:cSRSres;
begin
  c:=Cfg;
  //ZeroMemory(m_T1data.p,  c.m_fftCount* sizeof(double));
  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    s.fComIntervalLen:=0;
    //ZeroMemory(s.m_T1data.p,  c.m_fftCount* sizeof(double));
  end;
  for i := 0 to c.SRSCount - 1 do
  begin
    s := c.GetSrs(i);
    s.m_shockProcessed:=false;
  end;
  fTrigState:=TrOff;
end;

function cSRSTaho.name: string;
begin
  result:=m_tag.tagname;
end;

{ сSpmCfg }
procedure cSpmCfg.addSRS(s: pointer);
var
  I: Integer;
  ls:cSRSres;
  t:itag;
begin
  if GetObjectClass(s) = nil then
  begin
    if Supports(itag(pointer(s)),IID_ITAG) then
    begin
      t:=itag(pointer(s));
      for I := 0 to m_SRSList.Count - 1 do
      begin
        ls:=cSRSres(m_SRSList.Items[i]);
        if t=ls.m_tag.tag then
          exit;
      end;
      ls:=cSRSres.create;
      ls.m_tag.tag:=t;
      ls.cfg:=self;
      m_SRSList.Add(ls);
    end
  end
  else
  begin
    if tobject(s) is cSRSres then
    begin
      for I := 0 to m_SRSList.Count - 1 do
      begin
        ls:=cSRSres(m_SRSList.Items[i]);
        if s=ls then
          exit;
      end;
    end;
    m_SRSList.Add(s);
  end;
end;

constructor cSpmCfg.create;
begin
  m_SRSList:=TList.Create;
  m_fftCount:=32;
  m_blockcount:=1;
  m_addNulls:=false;
  m_capacity:=5;
end;

destructor cSpmCfg.destroy;
begin
  m_SRSList.Destroy;
end;

function cSpmCfg.GetSrs(i: integer): cSRSres;
begin
  result:=cSRSres(m_SRSList.Items[i]);
end;

function cSpmCfg.name: string;
begin
  result:= cSRSTaho(taho).name+'_FFTp='+inttostr(FFTProp.PCount);
end;

procedure cSpmCfg.settyperes(t: integer);
var
  I: Integer;
  s:cSRSres;
  b:boolean;
begin
  ftypeRes:=t;
  for I := 0 to srsCount - 1 do
  begin
    s:=GetSrs(i);
    b:=t=c_FRF;
    if s.lineSpm<>nil then
      s.lineSpm.visible:=not b;
    if s.linefrf<>nil then
      s.linefrf.visible:=b;
  end;
end;

function cSpmCfg.SRSCount: integer;
begin
  result:=m_SRSList.Count;
end;

{ cSRSres }
constructor cSRSres.create;
begin
  m_tag:=cTag.create;
  m_shockList:=TDataBlockList.Create;
end;

destructor cSRSres.destroy;
begin
  m_tag.destroy;
  m_shockList.Destroy;
end;

function cSRSres.name: string;
begin
  result:=m_tag.tagname;
end;

procedure cSRSres.setcfg(c: cSpmCfg);
begin
  fcfg:=c;
  m_shockList.m_cfg:=c;
end;

{ cSRSFactory }
procedure cSRSFactory.createevents;
begin
  addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cSRSFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
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
      g_SRSFactory.m_meraFile:=GetMeraFile;
      doStart;
    end;
    RSt_StopToRec:
    begin
      g_SRSFactory.m_meraFile:=GetMeraFile;
      doStart;
    end;
    RSt_ViewToStop:
    begin
      doStop;
    end;
    RSt_ViewToRec:
    begin
      g_SRSFactory.m_meraFile:=GetMeraFile;
    end;
    RSt_initToRec:
    begin
      g_SRSFactory.m_meraFile:=GetMeraFile;
      doStart;
    end;
    RSt_initToView:
    begin
      g_SRSFactory.m_meraFile:=GetMeraFile;
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

procedure TSRSFrm.SaveMdbBtnClick(Sender: TObject);
var
  o:cObjFolder;
  t:cTestFolder;
  path:string;

  i, j, num: integer;
  ifile: TIniFile;
  f,ident,dir, sname: string;
  c:cSpmCfg;
  taho:cSRSTaho;
  s: cSRSres;
begin
  if g_MBaseControl<>nil then
  begin
    o:=g_MBaseControl.GetSelectObj;
    t:=g_MBaseControl.GetSelectTest;
    if o<>nil then
    begin
      path:=g_mbase.m_BaseFolder.Absolutepath;;
      ForceDirectories(path+'\FrfTypes');
      if o.ObjType<>'' then
      begin
        path:= path+'\FrfTypes'+'\'+o.ObjType;
        ForceDirectories(path);
        ifile := TIniFile.create(path+'\frf.mera');
        taho:=getTaho;
        c:=taho.Cfg;
        for i := 0 to c.SRSCount - 1 do
        begin
          s := c.GetSrs(i);
          sname:=s.m_tag.tagname+'_p№'+inttostr(PointIE.IntNum)+'_frf';
          ident:=sname;
          saveHeader(ifile,1/c.fspmdx, 0, ident);
          saveData(path, sname, s.m_frf);

          sname:=s.m_tag.tagname+'_p№'+inttostr(PointIE.IntNum)+'_phase';
          ident:=sname;
          saveHeader(ifile,1/c.fspmdx, 0, ident);
          saveData(path, sname, s.m_phase);

          ifile.destroy;
        end;
      end;
    end;
  end;
end;


procedure cSRSFactory.doStop;
var
  mdb:boolean;
  path:string;
  I: Integer;
  f:TSRSFrm;
begin
  mdb:=false;
  if g_MBaseControl<>nil then
  begin
    path:=getMDBTestPath;
    if directoryexists(path) then
    begin
      mdb:=true;
    end;
  end;
  for I := 0 to count - 1 do
  begin
    f:=TSRSFrm(GetFrm(i));
    if mdb then
    begin
     f.SaveMdbPan.Color:=clGreen;
    end
    else
    begin
     f.SaveMdbPan.Color:=clBtnFace;
    end
  end;
end;

procedure cSRSFactory.doUpdateData(sender: tobject);
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TSRSFrm(Frm).updateData;
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

procedure TDataBlock.evalmod2;
var
  I: Integer;
  c:TComplex_d;
begin
  for I := 0 to m_size - 1 do
  begin
    c:=sopr(m_spm[i]);
    c:=m_spm[i]*c;
    m_mod2[i]:=c.re;
  end;
end;

function TDataBlock.getsize: integer;
begin
  result:=m_size;
end;

procedure TDataBlock.setsize(s: integer);
begin
  m_size:=s;
  SetLength(m_spm, s);
end;

{ TDataBlockList }
function TDataBlockList.addBlock(data: pointer; dsize: integer):TDataBlock;
var
  db:TDataBlock;
begin
  inc(m_shockCount);
  if (Count=m_cfg.m_capacity) and (m_cfg.m_capacity>0) then
  begin
    m_LastBlock:=m_LastBlock+1;
    if m_LastBlock=m_cfg.m_capacity then
      m_LastBlock:=0;
    db:=getBlock(m_LastBlock);
  end
  else
  begin
    db:=TDataBlock.Create;
    SetLength(db.m_spm, dsize);
    SetLength(db.m_mod2, dsize);
    db.m_size:=dsize;
    db.find:=Add(db);
    m_LastBlock:=db.find;
  end;
  system.move(TCmxArray_d(data)[0], db.m_spm[0], dsize*sizeof(TComplex_d));
  db.evalmod2;
  result:=db;
end;

function TDataBlockList.addBlock(data: pointer; spmMag:tdoublearray; dsize: integer; time: double;
                                 // timeblock
                                 tb:TDoubleArray; psize:integer):TDataBlock;
begin
  result:=addBlock(data, dsize);
  SetLength(result.m_frf, dsize);
  SetLength(result.m_mod, dsize);
  system.move(spmMag[0], result.m_mod[0], dsize*sizeof(double));

  result.m_timeStamp:=time;
  if psize>result.m_timecapacity then
  begin
    setlength(result.m_TimeBlock,psize);
    result.m_timecapacity:=psize;
  end;
  system.move(tb[0], result.m_TimeBlock[0], psize*sizeof(double));
  result.m_TimeArrSize:=psize;
end;

procedure TDataBlockList.clearData;
var
  d:TDataBlock;
  I, l: Integer;
begin
  m_shockCount:=0;
  l:=length(m_Cxy);
  if l>0 then
  begin
    ZeroMemory(m_Cxy, l*(sizeof(TComplex_d)));
    ZeroMemory(m_sxx, l*(sizeof(double)));
    ZeroMemory(m_syy, l*(sizeof(double)));
  end;
  for I := 0 to Count - 1 do
  begin
    d:=TDataBlock(items[i]);
    d.Destroy;
  end;
  Clear;
end;

constructor TDataBlockList.create;
begin
  inherited;
end;

destructor TDataBlockList.destroy;
begin
  ClearData;
  inherited;
end;

procedure TDataBlockList.evalCoh(TahoShockList:TDataBlockList);
var
  i, j,n:integer;
  s, t:TDataBlock;
  p1, p2:TComplex_d;
  k:double;
begin
  n:=Count;
  if n=0 then exit;

  for I := 0 to Count-1 do
  begin
    s:=getBlock(i);
    t:=TahoShockList.getBlock(i);
    for j := 0 to s.m_size - 1 do // проход по спектру
    begin
      p1:=s.m_spm[j];
      p2:=Sopr(t.m_spm[j]);
      m_Cxy[j]:=p1*p2+m_Cxy[j];
      //m_sxx[j]:=mod2(p1)+m_sxx[j];
      //m_syy[j]:=mod2(p2)+m_syy[j];
      m_sxx[j]:=s.m_mod2[j]+m_sxx[j];
      m_syy[j]:=t.m_mod2[j]+m_syy[j];
    end;
  end;
  k:=1/(n*n);
  for j := 0 to s.m_size - 1 do
  begin
    m_coh[j]:=mod2(m_Cxy[j])/(m_sxx[j]*m_syy[j]);
    // делаемсреднюю комплексную передаточную характеристику
    m_cXY[j]:=m_Cxy[j]*k/m_syy[j];
  end;
end;

function TDataBlockList.getBlock(i: integer): TDataBlock;
begin
  result:=TDataBlock(items[i]);
end;

function TDataBlockList.getLastBlock: TDataBlock;
begin
  result:=getBlock(m_LastBlock);
end;

function TDataBlockList.getLastBlock(d:TDataBlock):TDataBlock;
begin
  if d=nil then
    result:=getLastBlock
  else
    result:=getPrevBlock(d);
end;

function TDataBlockList.getPrevBlock(d:TDataBlock): TDataBlock;
var
  i:integer;
begin
  i:=d.find-1;
  if i<0 then
  begin
    i:=Count-1;
  end;
  result:=getBlock(i);
end;

end.
