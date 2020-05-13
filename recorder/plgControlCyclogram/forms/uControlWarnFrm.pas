unit uControlWarnFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor, uEditProfileFrm, u2dmath,
  uRecorderEvents, ubaseObj, uCommonTypes, uPathMng, NativeXML, tags,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  PluginClass, ImgList, uChart, uGrmsSrcAlg, uPhaseAlg, usetlist;

type
  Taxis = record
    name:string;
    min, max:double;
    lg:boolean;
    acitive:boolean;
  end;

  TCntrlWrnChart = class;


  TWrkPoint = class
  private
    m_name: string;
  private
    cs: TRTLCriticalSection;
    // создан при загрузке конфига
    fload: boolean;
    fchart: TCntrlWrnChart;
    // кольцевой буфер данных
    fdata: array of point2d;
    fAxisName:string;
    fdrawarray: array of point2d;
    // количество повторений значений в интервале m_dx
    fdxPCount: array of integer;
    flast: integer;
    // время последней отрисованной точки
    fLastTimeX, fLastTimeY: double;
    // размер буфера для графика
    fPCount: integer;
    fPointsColor: point3;
    fDrawPoints: boolean;
    fDrawLine: boolean;
    // количество прочитанных точек по x и по для отслеждивания обновления данных
    freadyX, freadyY: cardinal;
  public
    faxis:caxis;
    // готовых к отрисовке точек
    // растет от нуля до PCount по мере заполнения буфера
    fready: integer;
    // настройки регулярной оси X
    m_regularX: boolean;
    m_dx: double;

    m_StateTag: itag;
    m_estimateX: boolean;
    m_estimateY: boolean;

    m_XTypeEstimate: integer;
    m_YTypeEstimate: integer;
    m_XParam: ctag;
    m_YParam: ctag;
    m_owner: tstringlist;
    m_tr: ctrend;
  protected
    procedure EnterTrendCS;
    procedure ExitTrendCS;
    procedure EnterCS;
    procedure ExitCS;
    procedure InitCS;
    procedure DeleteCS;
    // сброс счетчиков. Нужно делать при старте просмотра
    procedure init;
    // получить текущее положение рабочей точки
    function getValue: point2d;
    procedure setPCount(c: integer);
    // сравнить с профилем
    function checkValue(p2d: point2d; prof: tprofile): integer;
    procedure createTag(tagname: string);

    function GetDrawPoints: boolean;
    procedure SetDrawPoints(b: boolean);

    function GetDrawLine: boolean;
    procedure SetDrawLine(b: boolean);

    function GetPColor: point3;
    procedure SetPColor(p: point3);
    procedure saveData(fname: string);
    procedure setname(p_name: string);
    procedure setaxis(a: caxis);
    procedure setaxisname(s: string);
    function getaxisname: string;
  public
    procedure initgraph;
    function ready: boolean;
    // событие обновления данных. Здесь получаем последнее положение
    // и добавляем в буфер данных для отрисовки
    procedure UpdateData(prof: tprofile);
    procedure UpdateView;
    // использовать оценку по обгоим тегам
    procedure UpdateDataScalar(prof: tprofile);
    // Как минимум один тег векторный. Данные могут идти асинхронно при  построениии параметра по параметру анализируется время
    // каждой точки
    procedure UpdateDataWithTime(prof: tprofile);
    constructor create(chart: cchart);
    destructor destroy;
  public
    property name: string read m_name write setname;
    property PCount: integer read fPCount write setPCount;
    property PColor: point3 read GetPColor write SetPColor;
    property DrawPoints: boolean read GetDrawPoints write SetDrawPoints;
    property DrawLine: boolean read GetDrawLine write SetDrawLine;
    property axis: caxis read faxis write SetAxis;
    property axisname: string read faxisname write SetAxisName;
  end;

  TCntrlWrnChart = class(TRecFrm)
  public
    m_XminDefault,m_XmaxDefault:double;
    m_lgX:boolean;
    m_axises:array of taxis;
    chart: cchart;
    m_profile, m_hihi, m_lolo, m_lo, m_hi: ctrend;
  protected
    m_name: string;
    fPSize: Single;
    fShowProfile, fShowWarnings, fShowAlarms, fShowRms, fShowPhase: boolean;
    m_GraphList: tstringlist;
    fprofile: tprofile;
  public
    procedure SpmChartInit(Sender: TObject);
  public
  protected
    procedure initProfile;
    procedure WndProc(var Message: TMessage); override;
    // отрисовка компонента
    procedure UpdateData;
    procedure UpdateView;
    procedure doStart;
    procedure setProfile(p: tprofile);
  public
    function ProfileAxis:caxis;
    procedure delProfile;
    function getDefAxisSettings(a:caxis; var error:boolean; var ind:integer):taxis;overload;
    function getDefAxisSettings(axName:string; var error:boolean; var ind:integer):taxis;overload;
    procedure clearWP;
    property profile: tprofile read fprofile write setProfile;
    procedure addGraph(wp: TWrkPoint; a:caxis);
    // применить все настройки
    procedure UpdateOpts;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LinkAxisSettings;
    // заполнить тестовыми данными
    procedure TestInit;
    function GraphCount: integer;
    function getWP(name: string): TWrkPoint; overload;
    function getWP(i: integer): TWrkPoint; overload;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  protected
    procedure doCursorMove(Sender: TObject);
    procedure doKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RBtnClick(Sender: TObject);
    procedure DblClick(Sender: TObject);
    procedure setShowProfile(b: boolean);
    function getShowProfile: boolean;
    procedure setShowWarnings(b: boolean);
    function getShowWarnings: boolean;
    procedure setShowAlarms(b: boolean);
    function getShowAlarms: boolean;
    function GetPSize: Single;
    procedure SetPSize(s: Single);
    function getname: string;
    procedure setname(s: string);
    function getLgX: boolean;
    procedure setLgX(b: boolean);
  public
    property name: string read m_name write setname;
    property PSize: Single read GetPSize write SetPSize;
    property LgX: boolean read getLgX write setLgX;
    property ShowProfile: boolean read getShowProfile write setShowProfile;
    property ShowWarnings: boolean read getShowWarnings write setShowWarnings;
    property ShowAlarms: boolean read getShowAlarms write setShowAlarms;
    property ShowAh: boolean read fShowRms write fShowRms;
    property ShowPh: boolean read fShowPhase write fShowPhase;
  end;

  ICtrlWrnFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cCtrlWrnFactory = class(cRecBasicFactory)
  public
    // профили
    m_pList: tprofilelist;
  private
    m_counter: integer;
  private
    procedure AddEvents;
  protected
    procedure doDestroyForms; override;
    procedure CreateEvents;
    procedure DestroyEvents;
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
    procedure doLoad(Sender: TObject);
    procedure doSave(Sender: TObject);
    procedure doUpdateData(Sender: TObject);
    procedure SaveMera;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
    procedure savetoxml(f: string);
    procedure loadxml(f: string);
    procedure savetoini(f: TIniFile);
    procedure loadini(f: TIniFile);
  end;

const
  c_Pic = 'CTRLWRNCHART';
  c_Name = 'График "Рабочая точка';

  c_SpmChart_defXSize = 400;
  c_SpmChart_defYSize = 400;

  c_defEst = 0;
  c_MeanEst = 1;
  c_RMSEst = 2;
  c_PeakEst = 3;

  // ctrl+shift+G
  // ['{CE899B2C-15A2-404E-9DC0-B006C81C755B}']
  IID_CHARTSPM: TGuid = (D1: $CE899B2C; D2: $15A2; D3: $404E;
    D4: ($9D, $C0, $B0, $6C, $81, $C7, $6F, $5B));

var
  g_CtrlWrnFactory: cCtrlWrnFactory;

implementation

uses uEditControlWrnFrm, uSpmChart, signal;
{$R *.dfm}

procedure TCntrlWrnChart.RBtnClick(Sender: TObject);
begin
  if EditCntlWrnFrm <> nil then
  begin
    EditCntlWrnFrm.EditChart(self);
  end;
end;

Function TCntrlWrnChart.GetPSize: Single;
var
  p: cpage;
begin
  if chart.activePage <> nil then
  begin
    p := cpage(chart.activePage);
    if p <> nil then
      fPSize := p.getPointSize;
  end;
  result := fPSize;
end;

procedure TCntrlWrnChart.SetPSize(s: Single);
var
  p: cpage;
begin
  fPSize := s;
  if chart.activePage <> nil then
  begin
    p := cpage(chart.activePage);
    if p <> nil then
      fPSize := p.setPointSize(s);
  end;
end;

procedure TCntrlWrnChart.doCursorMove(Sender: TObject);
begin
  g_SpmFactory.doCursorMove(self);
end;

procedure TCntrlWrnChart.doKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  p: cpage;
begin
  if GetKeyState(VK_CONTROL) < 0 then
  begin
    if GetKeyState(Ord('3')) < 0 then
    begin
      p := cpage(chart.activePage);
      p.cursor.visible := not p.cursor.visible;
    end;
  end;
end;

procedure TCntrlWrnChart.addGraph(wp: TWrkPoint; a:caxis);
begin
  wp.m_owner := m_GraphList;
  wp.fchart := self;
  m_GraphList.AddObject(wp.m_name, wp);
  wp.axis:=a;
  wp.initgraph;
end;

procedure TCntrlWrnChart.clearWP;
begin
  m_GraphList.Clear;
end;

constructor TCntrlWrnChart.create(Aowner: tcomponent);
begin
  inherited;
  m_GraphList := tstringlist.create;
  m_GraphList.Sorted := true;

  chart := cchart.create(self);
  chart.Align := alClient;
  chart.showTV := false;
  chart.showLegend := false;
  chart.OnRBtnClick := RBtnClick;
  chart.OnDblClick := DblClick;
  chart.OnInit := SpmChartInit;
  chart.OnKeyDown := doKeyDown;
  chart.OnCursorMove := doCursorMove;

  fShowWarnings := true;
  fShowProfile := true;
  fShowAlarms := true;

  fShowRms := true;
  fShowPhase := true;

  PSize := 5;
end;

procedure TCntrlWrnChart.DblClick(Sender: TObject);
var
  r: frect;
  a: caxis;
  act:caxis;
  p: cpage;
  defAxis:taxis;
  err:boolean;
  i,j:integer;
begin
  p := cpage(chart.activePage);
  act:=p.activeAxis;
  for I := 0 to length(m_axises) - 1 do
  begin
    a := p.getaxis(i);
    defAxis:=getDefAxisSettings(a,err, j);
    if not err then
    begin
      r.BottomLeft := p2(m_XminDefault, defAxis.min);
      r.TopRight := p2(m_XmaxDefault, defAxis.max);
      p.activeAxis:=a;
      p.ZoomfRect(r);
    end;
  end;
  p.activeAxis:=act;
end;


destructor TCntrlWrnChart.destroy;
var
  i: integer;
  w: TWrkPoint;
begin
  for i := 0 to GraphCount - 1 do
  begin
    w := getWP(i);
    w.destroy;
  end;
  m_GraphList.Clear;
  m_GraphList.destroy;
  m_GraphList := nil;
  inherited;
end;

procedure TCntrlWrnChart.LinkAxisSettings;
var
  I: Integer;
  a:caxis;
  p:cpage;
begin
  p:=cpage(chart.activePage);
  for I := 0 to length(m_axises) - 1 do
  begin
    if i=0 then
    begin
      a:=p.activeAxis;
      if m_axises[i].name<>'' then
      begin
        a.name:=m_axises[i].name;
        a.caption:=m_axises[i].name;
      end
      else
      begin
        m_axises[i].name:=a.caption;
      end;
    end
    else
    begin
      a:=p.getaxis(m_axises[i].name);
      if a=nil then
      begin
        a:=p.Newaxis;
        a.name:=m_axises[i].name;
        a.caption:=m_axises[i].name;
      end;
    end;
    a.maxY:=m_axises[i].max;
    a.minY:=m_axises[i].min;
    a.lg:=m_axises[i].lg;
  end;
end;


procedure TCntrlWrnChart.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  w: TWrkPoint;
  ax:taxis;
begin
  inherited;
  a_pIni.WriteString(str, 'ComponentName', name);

  a_pIni.WriteFloat(str, 'X_min', m_XminDefault);
  a_pIni.WriteFloat(str, 'X_max', m_XmaxDefault);
  a_pIni.WriteBool(str, 'X_Lg', m_lgX);
  a_pIni.WriteInteger(str, 'AxisCount', Length(m_axises));
  for I := 0 to Length(m_axises) - 1 do
  begin
    ax:=m_axises[i];
    a_pIni.WriteString(str, 'Ax_Y_name_'+inttostr(i), ax.name);
    a_pIni.WriteFloat(str, 'Ax_Y_min_'+inttostr(i), ax.min);
    a_pIni.WriteFloat(str, 'Ax_Y_max_'+inttostr(i), ax.max);
    a_pIni.WriteBool(str,  'Y_Lg_'+inttostr(i), ax.lg);
  end;
  a_pIni.WriteFloat(str, 'PSize', PSize);

  a_pIni.WriteBool(str, 'ShowProfile', ShowProfile);
  a_pIni.WriteBool(str, 'ShowWarnings', ShowWarnings);
  a_pIni.WriteBool(str, 'ShowAlarms', ShowAlarms);
  a_pIni.WriteInteger(str, 'GraphCount', GraphCount);
  if profile <> nil then
    a_pIni.WriteString(str, 'Profile', profile.name);
  for i := 0 to GraphCount - 1 do
  begin
    w := getWP(i);
    a_pIni.WriteString(str, 'Axis_' + inttostr(i), w.axisname);
    a_pIni.WriteString(str, 'GraphName_' + inttostr(i), w.name);
    saveTagToIni(a_pIni, w.m_XParam, str, 'GraphX_' + inttostr(i));
    saveTagToIni(a_pIni, w.m_YParam, str, 'GraphY_' + inttostr(i));
    a_pIni.WriteBool(str, 'EstimateX_' + inttostr(i), w.m_estimateX);
    a_pIni.WriteBool(str, 'EstimateY_' + inttostr(i), w.m_estimateY);
    a_pIni.WriteBool(str, 'DrawPoints_' + inttostr(i), w.DrawPoints);
    a_pIni.WriteBool(str, 'DrawLine_' + inttostr(i), w.DrawLine);
    a_pIni.WriteBool(str, 'regularX_' + inttostr(i), w.m_regularX);
    a_pIni.WriteFloat(str, 'dX_' + inttostr(i), w.m_dx);

    a_pIni.WriteInteger(str, 'PColor_' + inttostr(i), rgbtoint(w.PColor));
    a_pIni.WriteInteger(str, 'GraphPCount_' + inttostr(i), w.PCount);
    a_pIni.WriteInteger(str, 'XEst_' + inttostr(i), w.m_XTypeEstimate);
    a_pIni.WriteInteger(str, 'YEst_' + inttostr(i), w.m_YTypeEstimate);
  end;
end;

procedure TCntrlWrnChart.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  alg: cbasealgcontainer;
  i, Count: integer;
  lstr: string;
  w: TWrkPoint;
  p: tprofile;
  ax:Taxis;
begin
  inherited;
  name := a_pIni.ReadString(str, 'ComponentName', 'Параметрический график');

  m_XmaxDefault:=readFloatFromIni(a_pIni,str, 'X_max');
  m_XminDefault:=readFloatFromIni(a_pIni,str, 'X_min');
  m_lgX:=a_pIni.ReadBool(str, 'X_Lg', false);

  Count:=a_pIni.ReadInteger(str, 'AxisCount', 1);
  SetLength(m_axises, count);
  for I := 0 to count - 1 do
  begin
    m_axises[i].name:=a_pIni.ReadString(str, 'Ax_Y_name_'+inttostr(i), '');
    m_axises[i].min:=a_pIni.ReadFloat(str, 'Ax_Y_min_'+inttostr(i), 0);
    m_axises[i].max:=a_pIni.ReadFloat(str, 'Ax_Y_max_'+inttostr(i), 10);
    m_axises[i].lg:=a_pIni.ReadBool(str,  'Y_Lg_'+inttostr(i), false);
  end;

  PSize := IniReadFloatEx(a_pIni, str, 'PSize', 5);

  ShowProfile := a_pIni.ReadBool(str, 'ShowProfile', false);
  ShowWarnings := a_pIni.ReadBool(str, 'ShowWarnings', false);
  ShowAlarms := a_pIni.ReadBool(str, 'ShowAlarms', false);

  lstr := a_pIni.ReadString(str, 'Profile', '');
  p := cCtrlWrnFactory(m_f).m_pList.getprof(lstr, i);
  profile := p;

  Count := a_pIni.ReadInteger(str, 'GraphCount', 0);
  for i := 0 to Count - 1 do
  begin
    w := TWrkPoint.create(chart);
    w.name := a_pIni.ReadString(str, 'GraphName_' + inttostr(i), '');
    LoadExTagIni(a_pIni, w.m_XParam, str, 'GraphX_' + inttostr(i));
    LoadExTagIni(a_pIni, w.m_YParam, str, 'GraphY_' + inttostr(i));
    w.m_estimateX := a_pIni.ReadBool(str, 'EstimateX_' + inttostr(i), true);
    w.m_estimateY := a_pIni.ReadBool(str, 'EstimateY_' + inttostr(i), true);
    w.PCount := a_pIni.ReadInteger(str, 'GraphPCount_' + inttostr(i), 1);
    w.DrawPoints := a_pIni.ReadBool(str, 'DrawPoints_' + inttostr(i), true);
    w.DrawLine := a_pIni.ReadBool(str, 'DrawLine_' + inttostr(i), true);
    w.m_regularX := a_pIni.ReadBool(str, 'regularX_' + inttostr(i), false);
    w.m_dx := IniReadFloatEx(a_pIni, str, 'dX_' + inttostr(i), 0.5);

    w.PColor := inttorgb(a_pIni.ReadInteger(str, 'PColor_' + inttostr(i),
        rgbtoint(w.PColor)));
    w.m_XTypeEstimate := a_pIni.ReadInteger(str, 'XEst_' + inttostr(i), 0);
    w.m_YTypeEstimate := a_pIni.ReadInteger(str, 'YEst_' + inttostr(i), 0);
    w.fload := true;
    addGraph(w, nil);
    w.axisname := a_pIni.ReadString(str, 'Axis_' + inttostr(i), '');
  end;
end;


procedure TCntrlWrnChart.SpmChartInit(Sender: TObject);
var
  i: integer;
  p: cpage;
  d: cDoubleCursor;
  w: TWrkPoint;
begin
  p := cpage(chart.activePage);
  if name='' then
    p.Caption := 'Параметрический график'
  else
    p.Caption := name;
  d := p.cursor;
  d.visible := false;

  LinkAxisSettings;

  PSize := fPSize;

  UpdateOpts;
  initProfile;

  for i := 0 to GraphCount - 1 do
  begin
    w := getWP(i);
    w.initgraph;
  end;
  if length(m_axises)=0 then
    setlength(m_axises,1);
  m_axises[0].name:=p.activeAxis.name;
  m_axises[0].name:=p.activeAxis.caption;
  m_axises[0].min:=p.activeAxis.minY;
  m_axises[0].max:=p.activeAxis.maxY;
  m_axises[0].lg:=p.activeAxis.lg;
end;

procedure TCntrlWrnChart.TestInit;
var
  spm: cBaseObj;
  i: integer;
begin

end;

procedure TCntrlWrnChart.doStart;
var
  i: integer;
  w: TWrkPoint;
begin
  for i := 0 to GraphCount - 1 do
  begin
    w := getWP(i);
    w.init;
  end;
end;

procedure TCntrlWrnChart.setname(s: string);
begin
  m_name := s;
  if chart.activePage <> nil then
  begin
    chart.activePage.Caption := m_name;
  end;
end;

procedure TCntrlWrnChart.setProfile(p: tprofile);
var
  i: integer;
  tr: ctrend;
begin
  fprofile := p;
  if p = nil then
    exit;
  p.evalData;
  if m_profile <> nil then
  begin
    for i := 0 to p.Count - 1 do
    begin
      tr := m_profile;
      addPointsToProfile(p.x, p.m_data, 0, tr);
      tr := m_hihi;
      addPointsToProfile(p.x, p.m_data, 1, tr);
      tr := m_hi;
      addPointsToProfile(p.x, p.m_data, 2, tr);
      tr := m_lo;
      addPointsToProfile(p.x, p.m_data, 3, tr);
      tr := m_lolo;
      addPointsToProfile(p.x, p.m_data, 4, tr);
    end;
  end;
end;

procedure TCntrlWrnChart.delProfile;
begin
  m_profile:=nil;
  m_lolo:=nil;
  m_lo:=nil;
  m_hi:=nil;
  m_hihi:=nil;
  fprofile:=nil;
end;

function TCntrlWrnChart.ProfileAxis: caxis;
begin
  result:=nil;
  if m_profile<>nil then
    result:=caxis(m_profile.GetParentByClassName('cAxis'));
end;


procedure TCntrlWrnChart.initProfile;
var
  p: cpage;
  aX: caxis;
begin
  p := cpage(chart.activePage);
  aX := p.activeAxis;

  if m_profile = nil then
  begin
    m_profile := ctrend.create;
    aX.AddChild(m_profile);
    m_profile.enabled := false;
    m_profile.name := 'Profile';
    m_profile.color := p3(0, 1, 0);
  end;
  if m_lolo = nil then
  begin
    m_lolo := ctrend.create;
    m_lolo.selectable := false;
    m_lolo.name := 'LoLo';
    m_lolo.color := p3(1, 0, 0);
    aX.AddChild(m_lolo);
  end;
  if m_lo = nil then
  begin
    m_lo := ctrend.create;
    m_lo.selectable := false;
    m_lo.name := 'Lo';
    m_lo.color := Orange; // p3(1,1,0);
    aX.AddChild(m_lo);
  end;
  if m_hi = nil then
  begin
    m_hi := ctrend.create;
    m_hi.selectable := false;
    m_hi.name := 'Hi';
    m_hi.color := Orange;
    aX.AddChild(m_hi);
  end;
  if m_hihi = nil then
  begin
    m_hihi := ctrend.create;
    aX.AddChild(m_hihi);
    m_hihi.selectable := false;
    m_hihi.name := 'HiHi';
    m_hihi.color := p3(1, 0, 0);
  end;
  if fprofile <> nil then
    profile := fprofile;
end;

procedure TCntrlWrnChart.setShowAlarms(b: boolean);
begin
  fShowAlarms := b;
  if m_hihi <> nil then
  begin
    m_hihi.visible := b;
    m_lolo.visible := b;
  end;
end;

procedure TCntrlWrnChart.setShowProfile(b: boolean);
begin
  fShowProfile := b;
  if m_profile <> nil then
    m_profile.visible := b;
end;

procedure TCntrlWrnChart.setShowWarnings(b: boolean);
begin
  fShowWarnings := b;
  if m_hi <> nil then
  begin
    m_hi.visible := b;
    m_lo.visible := b;
  end;
end;

function TCntrlWrnChart.getShowAlarms: boolean;
begin
  result := fShowAlarms;
end;

function TCntrlWrnChart.getShowProfile: boolean;
begin
  result := fShowProfile;
end;

function TCntrlWrnChart.getShowWarnings: boolean;
begin
  result := fShowWarnings;
end;

function TCntrlWrnChart.getWP(name: string): TWrkPoint;
var
  i: integer;
begin
  result := nil;
  if m_GraphList.find(name, i) then
  begin
    result := TWrkPoint(m_GraphList.Objects[i]);
  end;
end;

function TCntrlWrnChart.getWP(i: integer): TWrkPoint;
begin
  result := TWrkPoint(m_GraphList.Objects[i]);
end;

function TCntrlWrnChart.GraphCount: integer;
begin
  result := m_GraphList.Count;
end;

procedure TCntrlWrnChart.UpdateOpts;
var
  r: frect;
  a: caxis;
  p: cpage;
  I: Integer;
begin
  p := cpage(chart.activePage);

  p.lgX := m_lgX;
  for I := 0 to length(m_axises) - 1 do
  begin
    if m_axises[i].name<>'' then
    begin
      a:=caxis(p.getChildrenByCaption(m_axises[i].name));
      if a<>nil then
        a.caption:=m_axises[i].name
      else
        a:=p.Newaxis;
    end
    else
    begin
      m_axises[i].name:=a.caption;
    end;
    a.maxY:=m_axises[i].max;
    a.minY:=m_axises[i].min;
    a.lg:=m_axises[i].lg;

    r.BottomLeft := p2(m_XminDefault, m_axises[i].min);
    r.TopRight := p2(m_XmaxDefault, m_axises[i].max);
    a.ZoomfRect(r);
  end;
end;

function TCntrlWrnChart.getDefAxisSettings(axName:string; var error:boolean; var ind:integer):taxis;
var
  I: Integer;
begin
  error:=true;
  for I := 0 to length(m_axises) - 1 do
  begin
    if m_axises[i].name=axName then
    begin
      ind:=i;
      result:=m_axises[i];
      error:=false;
      exit;
    end;
  end;
end;

function TCntrlWrnChart.getLgX: boolean;
begin
  result:=m_lgX;
end;

procedure TCntrlWrnChart.setLgX(b: boolean);
begin
  m_lgX:=b;
  if chart.activePage <> nil then
  begin
    cpage(chart.activePage).LgX:=m_lgx;
  end;
end;


function TCntrlWrnChart.getDefAxisSettings(a: caxis; var error:boolean; var ind:integer): taxis;
var
  I: Integer;
begin
  result:=getDefAxisSettings(a.caption, error, ind);
end;

function TCntrlWrnChart.getname: string;
begin

end;

procedure TCntrlWrnChart.UpdateData;
var
  i: integer;
  w: TWrkPoint;
begin
  //logMessage('TCntrlWrnChart.UpdateData tid: '+inttostr(GetCurrentThreadId));
  // spmChart.activePage.caption := modname(spmChart.activePage.caption, false);
  for i := 0 to GraphCount - 1 do
  begin
    w := getWP(i);
    w.UpdateData(fprofile);
  end;
end;

procedure TCntrlWrnChart.UpdateView;
var
  i: integer;
  w: TWrkPoint;
begin
  //logMessage('TCntrlWrnChart.UpdateView tid: '+inttostr(GetCurrentThreadId));
  for i := 0 to GraphCount - 1 do
  begin
    w := getWP(i);
    w.UpdateView;
  end;
  chart.redraw;
end;

procedure TCntrlWrnChart.WndProc(var Message: TMessage);
begin
  inherited;
end;

{ cControlFactory }

procedure cCtrlWrnFactory.AddEvents;
begin

end;

constructor cCtrlWrnFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_CHARTSPM;
  m_pList := tprofilelist.create;
  CreateEvents;
end;

procedure cCtrlWrnFactory.CreateEvents;
begin
  addplgevent('cCtrlWrnFactory_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
  addplgevent('cCtrlWrnFactory_doLoad', c_RC_LoadCfg, doLoad);
  addplgevent('cCtrlWrnFactory_doSave', c_RC_SaveCfg, doSave);
  addplgevent('cCtrlWrnFactory_doUpdateData', c_RUpdateData, doUpdateData);
end;

procedure cCtrlWrnFactory.DestroyEvents;
begin
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
  removeplgEvent(doLoad, c_RC_LoadCfg);
  removeplgEvent(doSave, c_RC_SaveCfg);
  removeplgEvent(doUpdateData, c_RUpdateData);
end;

destructor cCtrlWrnFactory.destroy;
begin
  m_pList.destroy;
  DestroyEvents;
  inherited;
end;

procedure cCtrlWrnFactory.doChangeRState(Sender: TObject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
      end;
    RSt_StopToView:
      begin
        doStart;
      end;
    RSt_StopToRec:
      begin
        doStart;
      end;
    RSt_ViewToStop:
      begin

      end;
    RSt_ViewToRec:
      begin

      end;
    RSt_initToRec:
      begin
        doStart;
      end;
    RSt_initToView:
      begin
        doStart;
      end;
    RSt_RecToStop:
      begin
        SaveMera;
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

procedure cCtrlWrnFactory.SaveMera;
var
  i, j: integer;
  Frm: TCntrlWrnChart;
  wp: TWrkPoint;
  ifile: TIniFile;
begin
  if not fileexists(g_merafile) then
    exit;
  ifile := TIniFile.create(g_merafile);
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := TCntrlWrnChart(GetFrm(i));
    for j := 0 to Frm.m_GraphList.Count - 1 do
    begin
      wp := Frm.getWP(j);
      if wp.ready then
      begin
        if wp.fready > 0 then
        begin
          if wp.m_regularX then
          begin
            ifile.WriteFloat(wp.name, 'Freq', (1 / wp.m_dx))
          end
          else
          begin
            ifile.WriteString(wp.name, 'XFile', wp.name + '.x');
            ifile.WriteString(wp.name, 'XFormat', 'R8');
          end;
          ifile.WriteString(wp.name, 'YFormat', 'R8');
          // Подпись оси x
          ifile.WriteString(wp.name, 'XUnits', 'Гц');
          // Подпись оси Y
          ifile.WriteString(wp.name, 'YUnits', TagUnits(wp.m_YParam.tag));
          ifile.WriteFloat(wp.name, 'Start', 0);
          // k0
          ifile.WriteFloat(wp.name, 'k0', 0);
          // k1
          ifile.WriteFloat(wp.name, 'k1', 1);
          // СЕВ
          // if (fUTS<>nil) and (signal<>fUTS) then
          // begin
          // f.WriteString(wp.name, 'UTS_Channel', fUTS.getname);
          // end;
          wp.saveData(g_merafile);
        end;
      end;
    end;
  end;
  ifile.destroy;
end;

function cCtrlWrnFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := ICtrlWrnFrm.create();
  end;
end;

procedure cCtrlWrnFactory.doDestroyForms;
begin
  inherited;

end;

procedure cCtrlWrnFactory.doLoad(Sender: TObject);
var
  str: string;
begin
  str := getRConfig;
  str := ChangeFileExt(str, '.xml');
  if fileexists(str) then
  begin
    loadxml(str);
    if EditProfileFrm <> nil then
      EditProfileFrm.loadini(extractfiledir(str));
  end;
end;

procedure cCtrlWrnFactory.doSave(Sender: TObject);
var
  str: string;
begin
  str := getRConfig;
  str := ChangeFileExt(str, '.xml');
  savetoxml(str);
  if EditProfileFrm <> nil then
    EditProfileFrm.savetoini(extractfiledir(str));
end;

procedure cCtrlWrnFactory.doSetDefSize(var PSize: SIZE);
begin
  PSize.cx := c_SpmChart_defXSize;
  PSize.cy := c_SpmChart_defYSize;
end;

procedure cCtrlWrnFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TCntrlWrnChart(Frm).doStart;
  end;
end;

procedure cCtrlWrnFactory.doUpdateData(Sender: TObject);
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TCntrlWrnChart(Frm).UpdateData;
  end;
end;

procedure cCtrlWrnFactory.savetoini(f: TIniFile);
var
  i: integer;
  p: tprofile;
  str: string;
begin
  f.WriteInteger('CtrlWrnFactory', 'ProfCount', m_pList.Count);
  for i := 0 to m_pList.Count - 1 do
  begin
    p := m_pList.getprof(i);
    str := p.settings;
    f.WriteString('CtrlWrnFactory', 'Profile_' + inttostr(i), str);
  end;
end;

procedure cCtrlWrnFactory.savetoxml(f: string);
var
  doc: TNativeXml;
  node, ch: txmlnode;
  i: integer;
  p: tprofile;
  str: string;
begin
  doc := TNativeXml.create(nil);
  // doc:=TNativeXml.Create;
  doc.LoadFromFile(f);
  node := doc.Root;
  node := node.NodeNew('GraphProfiles');
  node.WriteAttributeInteger('PCount', m_pList.Count, 0);
  for i := 0 to m_pList.Count - 1 do
  begin
    p := m_pList.getprof(i);
    ch := node.NodeNew('Profile_' + inttostr(i));
    str := p.settings;
    ch.WriteAttributeString('Opts', str, '');
  end;
  doc.XmlFormat := xfReadable;
  doc.SaveToFile(f);
  doc.destroy;
end;

procedure cCtrlWrnFactory.loadxml(f: string);
var
  doc: TNativeXml;
  node, ch: txmlnode;
  i, PCount: integer;
  p: tprofile;
  str: string;
begin
  doc := TNativeXml.create(nil);
  doc.LoadFromFile(f);
  node := doc.Root;
  node := node.FindNode('GraphProfiles');
  if node = nil then
  begin
    doc.destroy;
    exit;
  end;
  m_pList.Cleardata;
  PCount := node.ReadAttributeInteger('PCount', 0);
  for i := 0 to PCount - 1 do
  begin
    ch := node.FindNode('Profile_' + inttostr(i));
    if ch <> nil then
    begin
      str := ch.ReadAttributeString('Opts', '');
      if str <> '' then
      begin
        p := tprofile.create;
        p.settings := str;
        p.m_owner := m_pList;
        m_pList.AddObject(p.name, p);
      end;
    end;
  end;
  doc.destroy;
end;

procedure cCtrlWrnFactory.loadini(f: TIniFile);
var
  i, c: integer;
  p: tprofile;
  str: string;
begin
  c := f.ReadInteger('CtrlWrnFactory', 'ProfCount', 0);
  for i := 0 to c - 1 do
  begin
    str := f.ReadString('CtrlWrnFactory', 'Profile_' + inttostr(i), '');
    if str <> '' then
    begin
      p := tprofile.create;
      p.settings := str;
    end;
  end;
end;

{ ICtrlWrnFrm }

procedure ICtrlWrnFrm.doClose;
begin
  m_lRefCount := 1;
end;

function ICtrlWrnFrm.doCreateFrm: TRecFrm;
begin
  result := TCntrlWrnChart.create(nil);
  TCntrlWrnChart(result).name:='Параметрический график';
end;

function ICtrlWrnFrm.doGetName: LPCSTR;
begin
  result := 'SpmFrm';
end;

function ICtrlWrnFrm.doRepaint: boolean;
begin
  inherited;
  TCntrlWrnChart(m_pMasterWnd).UpdateView;
end;

{ TWrkPoint }

function TWrkPoint.checkValue(p2d: point2d; prof: tprofile): integer;
var
  p1, p2: point2d;
  i: integer;
  val: double;
begin
  result := 0;
  if prof = nil then
    exit;
  for i := 0 to prof.Count - 1 do
  begin
    if p2d.x < prof.x[i] then
    begin
      if i = 0 then // мы слева от трубки допуска
      begin

      end
      else
      begin
        p1.x := prof.x[i - 1];
        p1.y := prof.m_data[i - 1].hh;
        p2.x := prof.x[i];
        p2.y := prof.m_data[i].hh;
        val := EvalLineYd(p2d.x, p1, p2);
        if p2d.y > val then
        begin
          result := 2;
          break;
        end;
        p1.y := prof.m_data[i - 1].h;
        p2.y := prof.m_data[i].h;
        val := EvalLineYd(p2d.x, p1, p2);
        if p2d.y > val then
        begin
          result := 1;
          break;
        end;
        p1.y := prof.m_data[i - 1].ll;
        p2.y := prof.m_data[i].ll;
        val := EvalLineYd(p2d.x, p1, p2);
        if p2d.y < val then
        begin
          result := -2;
          break;
        end;
        p1.y := prof.m_data[i - 1].l;
        p2.y := prof.m_data[i].l;
        val := EvalLineYd(p2d.x, p1, p2);
        if p2d.y < val then
        begin
          result := -1;
          break;
        end;
      end;
    end;
  end;
  if m_StateTag <> nil then
  begin
    m_StateTag.PushValue(result, -1);
  end;
end;

constructor TWrkPoint.create;
begin
  InitCS;
  fload := false;
  fPointsColor := black;
  m_estimateX := true;
  m_estimateY := true;
  PCount := 1;
  m_XParam := ctag.create;
  m_YParam := ctag.create;
end;

procedure TWrkPoint.createTag(tagname: string);
begin
  if not RStateConfig then
  begin
    ecm;
    if tagname <> '' then
      m_StateTag := CreateStateTag(tagname + '_State', nil);
    lcm;
  end
  else
  begin
    if tagname <> '' then
      m_StateTag := CreateStateTag(tagname + '_State', nil);
  end;
end;



destructor TWrkPoint.destroy;
begin
  DeleteCS;

  m_XParam.destroy;
  m_YParam.destroy;
  if m_tr<>nil then
  begin
    m_tr.destroy;
  end;

  CloseTag(m_StateTag);

  m_StateTag := nil;
end;

procedure TWrkPoint.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure TWrkPoint.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;

procedure TWrkPoint.EnterCS;
begin
  //EnterCriticalSection(cs);
  EnterTrendCS;
end;

procedure TWrkPoint.ExitCS;
begin
  ExitTrendCS;
end;

procedure TWrkPoint.ExitTrendCS;
begin
  m_tr.ExitCS;
end;

procedure TWrkPoint.EnterTrendCS;
begin
  m_tr.EnterCS;
end;


function TWrkPoint.getaxisname: string;
begin
  if faxis<>nil then
  begin
    result:=faxis.caption;
  end
  else
  begin
    result:=fAxisName;
  end;
end;

function getEstType(etype: integer): cardinal;
begin
  case etype of
    c_defEst:
      result := ESTIMATOR_DEFAULT;
    c_MeanEst:
      result := ESTIMATOR_MEAN;
    c_RMSEst:
      result := ESTIMATOR_RMSD;
    c_PeakEst:
      result := ESTIMATOR_PEAK;
  end;
end;

function TWrkPoint.getValue: point2d;
var
  v: double;
  t: ctag;
  i: integer;
  tX, tY: double;
  // dt, ut:double;
begin
  if not ready then
    exit;
  begin
    t := m_XParam;

    case m_XTypeEstimate of
      c_defEst:
        v := t.GetDefaultEst;
      c_MeanEst:
        v := t.GetMeanEst;
      c_RMSEst:
        v := t.GetRMSEst;
      c_PeakEst:
        v := t.GetPeakEst;
    end;
    result.x := v;
    // t.tag.GetScalarEstimateEx(v, ESTIMATOR_MEAN, @dt, @ut);

    t := m_YParam;
    case m_XTypeEstimate of
      c_defEst:
        v := t.GetDefaultEst;
      c_MeanEst:
        v := t.GetMeanEst;
      c_RMSEst:
        v := t.GetRMSEst;
      c_PeakEst:
        v := t.GetPeakEst;
    end;
    result.y := v;
    exit;
  end;
end;

procedure TWrkPoint.init;
begin
  fready := 0;
  flast := 0;
  freadyX := 0;
  freadyY := 0;
  m_XParam.doOnStart;
  m_YParam.doOnStart;
end;

procedure TWrkPoint.initgraph;
var
  index:integer;
  I: Integer;
  a:caxis;
begin
  if m_tr = nil then
    m_tr := ctrend.create;
  if fchart.chart.activePage <> nil then
  begin
    index:=0;
    for I := 0 to fchart.m_GraphList.Count - 1 do
    begin
      if self = fchart.m_GraphList.Objects[i] then
      begin
          index:=i;
          break;
      end;
    end;
    a:=axis;
    if a=nil then
      axisname:=fAxisName;
    if axis=nil then
    begin
      axis:=a;
    end;
    if axis=nil then
    begin
      if length(fchart.m_axises)=1 then
      begin
        axis:=cpage(fchart.chart.activePage).activeAxis;
        fchart.m_axises[0].name:=axis.caption;
        fchart.m_axises[0].min:=axis.minY;
        fchart.m_axises[0].max:=axis.maxY;
        fchart.m_axises[0].lg:=axis.lg;
      end;
    end;
    //a.AddChild(m_tr);
    m_tr.color := ColorArray[index];
    m_tr.pointcolor := ColorArray[index];
    if fload then
      m_tr.pointcolor := fPointsColor;
    m_tr.name := name;
  end;
end;

function TWrkPoint.ready: boolean;
begin
  result := false;
  if PCount > 0 then
  begin
    if m_XParam.tag <> nil then
    begin
      if m_YParam.tag <> nil then
      begin
        result := true;
      end;
    end;
  end;
end;

procedure TWrkPoint.saveData(fname: string);
var
  lname: string;
  f: file;
  i: integer;
begin
  lname := extractfiledir(fname) + '\' + name + '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  for i := 0 to fready - 1 do
  begin
    BlockWrite(f, fdrawarray[i].y, sizeof(double));
  end;
  closefile(f);
  lname := extractfiledir(fname) + '\' + name + '.x';
  AssignFile(f, lname);
  Rewrite(f, 1);
  for i := 0 to fready - 1 do
  begin
    BlockWrite(f, fdrawarray[i].x, sizeof(double));
  end;
  closefile(f);
end;

procedure TWrkPoint.setaxis(a: caxis);
begin
  if a<>faxis then
  begin
    if m_tr<>nil then
    begin
      m_tr.parent:=a;
    end;
    faxis:=a;
    fAxisName:=a.caption;
  end;
end;

procedure TWrkPoint.setaxisname(s: string);
var
  p:cpage;
  I: Integer;
  a:caxis;
begin
  fAxisName:=s;
  p:=cpage(fchart.chart.activePage);
  if p=nil then
    exit;
  for I := 0 to p.getAxisCount - 1 do
  begin
    a:=p.getaxis(i);
    if a.caption=s then
    begin
      faxis:=a;
      m_tr.parent:=a;
      exit;
    end;
  end;
end;

procedure TWrkPoint.setname(p_name: string);
var
  index: integer;
  obj: TWrkPoint;
begin
  if p_name = name then
    exit;
  if m_owner <> nil then
  begin
    if m_owner.find(m_name, index) then
    begin
      obj := TWrkPoint(m_owner.Objects[index]);
      if obj = self then
      begin
        m_owner.Delete(index);
      end
    end;
    while m_owner.find(p_name, index) do
    begin
      p_name := modname(p_name, false);
    end;
    m_owner.AddObject(p_name, self);
  end;
  if m_StateTag <> nil then
  begin
    if not RStateConfig then
      ecm;
    m_StateTag.setname(LPCSTR(StrToAnsi(p_name)));
    lcm;
  end
  else // если тег еще не создан
  begin
    createTag(p_name);
  end;
  m_name := p_name;
end;

procedure TWrkPoint.setPCount(c: integer);
begin
  fPCount := c;
  SetLength(fdata, c);
  SetLength(fdrawarray, c);
  SetLength(fdxPCount, c);
end;

function TWrkPoint.GetDrawPoints: boolean;
var
  p: cpage;
begin
  if m_tr <> nil then
  begin
    fDrawPoints := m_tr.drawpoint;
  end;
  result := fDrawPoints;
end;

procedure TWrkPoint.SetDrawPoints(b: boolean);
begin
  fDrawPoints := b;
  if m_tr <> nil then
  begin
    m_tr.drawpoint := fDrawPoints;
  end;
end;

function TWrkPoint.GetDrawLine: boolean;
var
  p: cpage;
begin
  if m_tr <> nil then
  begin
    fDrawLine := m_tr.drawLines;
  end;
  result := fDrawLine;
end;

procedure TWrkPoint.SetDrawLine(b: boolean);
begin
  fDrawLine := b;
  if m_tr <> nil then
  begin
    m_tr.drawLines := fDrawLine;
  end;
end;

function TWrkPoint.GetPColor: point3;
begin
  result := fPointsColor;
  if m_tr <> nil then
  begin
    result := m_tr.pointcolor;
  end;
end;

procedure TWrkPoint.SetPColor(p: point3);
begin
  fPointsColor := p;
  if m_tr <> nil then
  begin
    m_tr.pointcolor := p;
  end;
end;

procedure TWrkPoint.UpdateDataScalar(prof: tprofile);
var
  p2d: point2d;
  curind, copydata: integer;
  alarmLvl, i, lcount: integer;
begin
  alarmLvl := 0;
  p2d := getValue;
  // коррекция значения точки если равномерная шкала x
  if m_regularX then
  begin
    i := trunc(p2d.x / m_dx);
    lcount := fdxPCount[i];
    p2d.y := (fdrawarray[i].y * lcount + p2d.y) / (lcount + 1);
    fdxPCount[i] := (lcount + 1);
  end;
  if alarmLvl = 0 then
  begin
    alarmLvl := checkValue(p2d, prof);
  end;

  curind := flast;
  fdata[curind] := p2d;
  if fready < PCount then
  begin
    inc(fready);
  end;
  // готовим буфер данных
  copydata := 0;
  if fready < PCount then
  begin
    move(fdata[0], fdrawarray[0], fready * sizeof(point2d))
  end
  else
  begin
    if flast < PCount - 1 then
    begin
      copydata := (PCount - flast - 1);
      move(fdata[flast + 1], fdrawarray[0], copydata * sizeof(point2d));
    end;
    move(fdata[0], fdrawarray[copydata], (flast + 1) * sizeof(point2d));
  end;
  if flast < PCount - 1 then
  begin
    inc(flast);
  end
  else
  begin
    flast := 0;
  end
end;

procedure TWrkPoint.UpdateDataWithTime(prof: tprofile);
var
  p2d: point2d;
  curind, copydata: integer;
  TimeX, TimeY: point2d;
  alarmLvl,
  // счетчик внутри данных очередной порции
  i: integer;
  newXdata, newYData, b: boolean;
  time: double;
  error: boolean;
begin
  newXdata := false;
  m_XParam.UpdateTagData(true);
  if freadyX < m_XParam.readyBlockCount then
    newXdata := true;

  newYData := false;
  m_YParam.UpdateTagData(true);
  if freadyY < m_YParam.readyBlockCount then
    newYData := true;

  if not(newYData and newXdata) then
    exit
  else
  begin
    freadyY := m_YParam.readyBlockCount;
    freadyX := m_XParam.readyBlockCount;
  end;

  i := 0;
  b := true;
  alarmLvl := 0;

  EnterCS;
  while b do
  begin
    time := m_XParam.getReadTime(i);
    p2d.x := m_XParam.m_ReadData[i];
    p2d.y := m_YParam.GetValByTime(time, false, error).y;
    if error then
    begin
      inc(i);
      if i > (m_XParam.lastindex - 1) then
      begin
        b := false;
        break;
      end;
      continue;
    end;
    // p2d.y:=m_YParam.GetValByTime(time, false, error).y;
    if alarmLvl = 0 then
    begin
      alarmLvl := checkValue(p2d, prof);
    end;
    curind := flast;

    fdata[curind] := p2d;
    if fready < PCount then
    begin
      inc(fready);
    end;
    // готовим буфер данных
    copydata := 0;
    if fready < PCount then
    begin
      move(fdata[0], fdrawarray[0], fready * sizeof(point2d))
    end
    else
    begin
      if flast < PCount - 1 then
      begin
        copydata := (PCount - flast - 1);
        move(fdata[flast + 1], fdrawarray[0], copydata * sizeof(point2d));
      end;
      // ???
      move(fdata[0], fdrawarray[copydata], (flast + 1) * sizeof(point2d));
    end;
    if flast < PCount - 1 then
    begin
      inc(flast);
    end
    else
    begin
      flast := 0;
    end;
    inc(i);
    if i > (m_XParam.lastindex - 1) then
    begin
      b := false;
      break;
    end;
  end;
  ExitCS;
  m_XParam.ResetTagData();
  m_YParam.ResetTagData();
end;

procedure TWrkPoint.UpdateView;
begin
  // отрисовка
  EnterCS;
  m_tr.Clear;
  m_tr.addpoints(fdrawarray, fready);
  exitcs;
end;

procedure TWrkPoint.UpdateData(prof: tprofile);
begin
  if m_estimateX and m_estimateY then
  begin
    UpdateDataScalar(prof);
    exit;
  end;
  UpdateDataWithTime(prof);
end;

end.
