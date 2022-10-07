
unit uPolarGraph;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath, uDoubleCursor, uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uCommonTypes, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, utextlabel, tags,
  PluginClass, ImgList, uChart, uGrmsSrcAlg, uPhaseAlg, usetlist,
  uPolarGraphPage;

type
  TPolarGraph = class;

  tturn = record
    t:double;
    xind, yind, tahoind:integer;
  end;


  cTagGraph = class
  protected
    m_tr: cPolarGraph;
    fPolarGraph:TPolarGraph;
  private
    m_updateX, m_updateY:boolean;
    // буфер для расчета отрисовки первой точки в обороте
    fTurns:array of tturn;
    // количество отображаемых оборотов
    m_TurnCount,
    // количество посчитанных оборотов в fTurns
    readyturn:integer;

    // кольцевой буфер данных
    fTahoData, fXdata, fYdata, fFirstPointData: array of double;
    // используется точек
    fused,
    // размер буфера для графика
    fPCount,
    // индекс последнего используемого элемента в массиве fXdata, fYdata
    fLastIndex:integer;

    fPointsColor, fcolor: tcolor;

    fDrawPoints,
    fDrawLine,
    fDrawFPLine,
    m_UseTaho:boolean;
    // создан при загрузке конфига
    fload: boolean;
    m_TahoColor:integer;


    cs: TRTLCriticalSection;
    m_owner: tlist;
    m_name: string;
    m_StateTag: itag;
  private
    procedure SetDrawLine(const Value: boolean);
    function GetDrawLine: boolean;
    procedure SetDrawFPLine(const Value: boolean);
    function GetDrawFPLine: boolean;
    function GetDrawPoints: boolean;
    procedure SetDrawPoints(const Value: boolean);
    procedure SetPColor(const Value: tcolor);
    function GetPColor: tcolor;
    procedure SetColor(const Value: tcolor);
    function GetColor: tcolor;
    procedure SetTahoColor(c: TColor);
    function GetTahoColor: TColor;
    procedure SetUseTaho(b: boolean);
    function GetUseTaho: boolean;
    procedure setTurnCount(const Value: integer);
  public
    m_TahoThreshold:double;
    // 0 - число точек, 1 - число оборотов
    m_BuffType
    :integer;
    // входные теги синхронизированы (блоки данных приходят одновременно
    // (например каналы одного модуля)), упрощает расчет гистограммы
    m_SyncTags:boolean;
    m_xTag, m_yTag, m_taho: ctag;
  protected
    procedure EnterTrendCS;
    procedure ExitTrendCS;
    procedure EnterCS;
    procedure ExitCS;
    procedure InitCS;
    procedure DeleteCS;
    // событие обновления данных. Здесь получаем последнее положение
    // и добавляем в буфер данных для отрисовки
    procedure UpdateData;
    procedure UpdateView;
    // вспомогательная процедура
    procedure evalTurnTimes;
    // создание графических объектов по событию создания контекста OGl
    procedure initgraph;
    procedure createTag(tagname: string);

    procedure setPCount(c: integer);
    procedure setname(p_name: string);
  public
    // сброс счетчиков. Нужно делать при старте просмотра или редактировании
    procedure init;
    // размер буфера для графика
    property PCount: integer read fPCount write setPCount;
    property TurnCount: integer read m_TurnCount write setTurnCount;
    property PColor: TColor read GetPColor write SetPColor;
    property Color: TColor read GetColor write SetColor;
    property TahoColor: TColor read GetTahoColor write SetTahoColor;
    property UseTaho: boolean read GetUseTaho write setUseTaho;

    property DrawPoints: boolean read GetDrawPoints write SetDrawPoints;
    property DrawLine: boolean read GetDrawLine write SetDrawLine;
    property DrawFPLine: boolean read GetDrawFPLine write SetDrawFPLine;

    property name: string read m_name write setname;
    constructor create(chart: cchart);
    destructor destroy;override;
  end;

  cPolarGraphTag = class(cPolarGraph)
  protected
    Data:cTagGraph;
  protected
    // получить установить число вершин
    function getCount: integer; override;
    // преобразование индекса с учетом кольцевого буфера
    function convertindex(i:integer):integer;
    function FPcount:integer;override;
    function FPindex(i:integer):integer;override;
    function GetDrawFPLine: boolean;override;
  public
    procedure init(tagGraph:cTagGraph);
    function getP2(i: integer): point2; override;
    function gety(i: integer): double; override;
    function getx(i: integer): double; override;
    constructor create;override;
  end;

  TPolarGraph = class(TRecFrm)
  private
    fGraphName: string;
    fGraphMax: double;
    fpsize: double;
    page: cPolarGraphPage;
    m_graphlist: tlist;
  public
    chart: cchart;
  protected
    procedure ChartInit(Sender: TObject);
    procedure RBtnClick(Sender: TObject);
    function getGraphMax: double;
    procedure setGraphMax(v: double);
    function getPSize: double;
    procedure setPSize(v: double);
    function getGraphName: string;
    procedure setGraphName(v: string);
    procedure createevents;
    procedure destroyevents;
    procedure doOnZoom(Sender: TObject);
    procedure UpdateView;
    procedure UpdateData;
    procedure doStart;
    procedure clearGraphList;
  public
    function GraphCount: integer;
    function getGraph(i: integer): cTagGraph;overload;
    function getGraph(gname: string): cTagGraph;overload;
    function addGraph(p_name: string): cTagGraph;
    property GraphMax: double read getGraphMax write setGraphMax;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    property GraphName: string read getGraphName write setGraphName;
    property PSize: double read getPSize write setPSize;
  end;

  IPolarFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cPolarFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
    procedure CreateEvents;
    procedure DestroyEvents;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
  public
    constructor create;
    destructor destroy;override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

var
  g_PolarFactory: cPolarFactory;

const
  c_Pic = 'POLAR_GIST';
  c_Name = 'Круговая гистограмма';
  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  // ['{76272474-3CD7-4F00-82B7-F8D363A8855A}']|
  IID_POLAR: TGuid = (D1: $76272474; D2: $3CD7; D3: $4F00;
    D4: ($82, $B7, $F8, $D3, $63, $A8, $85, $5A));

implementation

uses
  uEditPolarFrm;
{$R *.dfm}

{ cPolarFactory }
constructor cPolarFactory.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_POLAR;
  CreateEvents;
end;

destructor cPolarFactory.destroy;
begin
  DestroyEvents;
  inherited;
end;

procedure cPolarFactory.CreateEvents;
begin
  //addplgevent('cCtrlWrnFactory_doChangeRState', c_RC_DoChangeRCState,   doChangeRState);
  //addplgevent('cCtrlWrnFactory_doLoad', c_RC_LoadCfg, doLoad);
  //addplgevent('cCtrlWrnFactory_doSave', c_RC_SaveCfg, doSave);
  addplgevent('cPolarFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cPolarFactory_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
end;

procedure cPolarFactory.DestroyEvents;
begin
  //removeplgEvent(doChangeRState, c_RC_ChangeState);
  //removeplgEvent(doLoad, c_RC_LoadCfg);
  //removeplgEvent(doSave, c_RC_SaveCfg);
  removeplgEvent(doUpdateData, c_RUpdateData);
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cPolarFactory.doUpdateData(Sender: TObject);
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TPolarGraph(Frm).UpdateData;
  end;
end;

procedure cPolarFactory.doAfterLoad;
begin
  inherited;
end;

procedure cPolarFactory.doChangeRState(Sender: TObject);
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
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cPolarFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := IPolarFrm.create();
  end;
end;

procedure cPolarFactory.doDestroyForms;
begin
  inherited;

end;

procedure cPolarFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure cPolarFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TPolarGraph(Frm).doStart;
  end;
end;

{ TPolarGraph }
function TPolarGraph.addGraph(p_name: string): cTagGraph;
begin
  result := cTagGraph.create(chart);
  result.m_owner := m_graphlist;
  result.name := p_name;
  result.fPolarGraph:=self;
  m_graphlist.Add(result);
  if page<>nil then
    page.AddChild(result.m_tr)
  else
  begin
    //showmessage('TPolarGraph.addGraph_Попытка добавить график при несозданной странице!')
  end;
end;

procedure TPolarGraph.ChartInit(Sender: TObject);
var
  polar: cPolarGraphPage;
  i:integer;
  g:cTagGraph;
begin
  polar := cPolarGraphPage.create;
  chart.activeTab.AddChild(polar);
  chart.activePage.destroy;
  chart.activeTab.Alignpages(1);
  page := polar;
  GraphName := 'Гистограмма биений';
  createevents;
  if GraphMax <> 0 then
  begin
    page.Max := GraphMax;
  end;
  PSize:=PSize;
  for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    g.initgraph;
  end;
end;

procedure TPolarGraph.RBtnClick(Sender: TObject);
begin
  if EditPolarFrm <> nil then
  begin
    EditPolarFrm.EditChart(self);
  end;
end;

procedure TPolarGraph.clearGraphList;
var
  I: Integer;
  gr:cTagGraph;
begin
  for I := 0 to m_graphlist.Count - 1 do
  begin
    gr:=getGraph(i);
    gr.Destroy;
  end;
  m_graphlist.Clear;
end;

constructor TPolarGraph.create(Aowner: tcomponent);
begin
  inherited;
  fGraphName:='Гистограмма биений';
  m_graphlist := tlist.create;
  chart := cchart.create(self);
  chart.Align := alClient;
  chart.showTV := false;
  chart.showLegend := false;
  chart.OnInit := ChartInit;
  chart.OnRBtnClick := RBtnClick;
end;

destructor TPolarGraph.destroy;
begin
  clearGraphList;
  m_graphlist.Destroy;
  m_graphlist:=nil;
  destroyevents;
  chart.Destroy;
  chart:=nil;
  inherited;
end;

procedure TPolarGraph.createevents;
begin
  chart.Objmng.Events.AddEvent('PolarGraph_onZoom', E_OnZoom, doOnZoom);
end;

procedure TPolarGraph.destroyevents;
begin
  chart.Objmng.Events.removeEvent(doOnZoom, E_OnZoom);
end;

procedure TPolarGraph.doOnZoom(Sender: TObject);
begin
  fGraphMax := page.Max;
end;

procedure TPolarGraph.doStart;
var
  i: integer;
  g: cTagGraph;
begin
  for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    g.init;
  end;
end;


procedure TPolarGraph.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, Count: integer;
  lstr: string;
  gr: cTagGraph;
begin
  inherited;
  GraphMax :=readFloatFromIni(a_pIni,str, 'GridMax');
  PSize:=readFloatFromIni(a_pIni,str, 'PSize');
  GraphName := a_pIni.ReadString(str, 'ComponentName', 'Гистограмма биений');
  Count := a_pIni.ReadInteger(str, 'GraphCount', 1);
  for i := 0 to Count - 1 do
  begin
    lstr := a_pIni.ReadString(str, 'GraphName_' + inttostr(i), '');
    if lstr <> '' then
    begin
      gr := addGraph(lstr);
      gr.fload :=true;
      gr.DrawPoints:=a_pIni.Readbool(str, 'GraphDrawPoints_' + inttostr(i), true);
      gr.DrawLine:=a_pIni.Readbool(str, 'GraphDrawLine_' + inttostr(i), true);
      gr.PCount:=a_pIni.ReadInteger(str, 'GraphPCount_' + inttostr(i), 1000);
      gr.color:=a_pIni.ReadInteger(str, 'GraphColor_' + inttostr(i), clGreen);
      gr.PColor:=a_pIni.ReadInteger(str, 'GraphPColor_' + inttostr(i), clBlue);
      // clOrange 1412570
      gr.m_TahoColor:=a_pIni.ReadInteger(str, 'GraphTahoColor_' + inttostr(i), rgbtoint(Orange));
      gr.m_BuffType:=a_pIni.ReadInteger(str, 'GraphBuffType_' + inttostr(i), 0);
      gr.TurnCount:=a_pIni.ReadInteger(str, 'GraphTurnCount_' + inttostr(i), 10);
      gr.DrawFPLine:=a_pIni.Readbool(str, 'GraphDrawFPLine_' + inttostr(i), true);
      gr.UseTaho:=a_pIni.Readbool(str, 'GraphUseTaho_' + inttostr(i), true);
      gr.m_TahoThreshold:=readFloatFromIni(a_pIni,str, 'GraphTahoThreshold_' + inttostr(i));
      LoadExTagIni(a_pIni, gr.m_taho, str, 'GraphTagTaho_' + inttostr(i));

      LoadExTagIni(a_pIni, gr.m_xTag, str, 'GraphTagX_' + inttostr(i));
      LoadExTagIni(a_pIni, gr.m_yTag, str, 'GraphTagY_' + inttostr(i));
    end;
  end;
end;

procedure TPolarGraph.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  gr: cTagGraph;
  ax: taxis;
begin
  inherited;
  a_pIni.WriteFloat(str, 'GridMax', GraphMax);
  a_pIni.WriteFloat(str, 'PSize', PSize);
  a_pIni.WriteInteger(str, 'GraphCount', m_graphlist.Count);
  a_pIni.WriteString(str, 'ComponentName', GraphName);
  for i := 0 to m_graphlist.Count - 1 do
  begin
    gr := getGraph(i);
    a_pIni.WriteString(str, 'GraphName_' + inttostr(i), gr.name);
    a_pIni.WriteBool(str, 'GraphDrawPoints_' + inttostr(i), gr.DrawPoints);
    a_pIni.WriteBool(str, 'GraphDrawLine_' + inttostr(i), gr.DrawLine);
    a_pIni.WriteInteger(str, 'GraphPCount_' + inttostr(i), gr.PCount);
    a_pIni.WriteInteger(str, 'GraphColor_' + inttostr(i), gr.fcolor);
    a_pIni.WriteInteger(str, 'GraphPColor_' + inttostr(i), gr.fPointsColor);

    a_pIni.WriteInteger(str, 'GraphBuffType_' + inttostr(i), gr.m_BuffType);
    a_pIni.WriteBool(str, 'GraphUseTaho_' + inttostr(i), gr.m_UseTaho);
    a_pIni.WriteBool(str, 'GraphDrawFPLine_' + inttostr(i), gr.DrawFPLine);
    a_pIni.WriteInteger(str, 'GraphTahoColor_' + inttostr(i), gr.m_TahoColor);
    a_pIni.WriteFloat(str, 'GraphTahoThreshold_' + inttostr(i), gr.m_TahoThreshold);
    saveTagToIni(a_pIni, gr.m_taho, str, 'GraphTagTaho_' + inttostr(i));

    saveTagToIni(a_pIni, gr.m_xTag, str, 'GraphTagX_' + inttostr(i));
    saveTagToIni(a_pIni, gr.m_yTag, str, 'GraphTagY_' + inttostr(i));

  end;
end;

procedure TPolarGraph.setGraphMax(v: double);
begin
  fGraphMax := v;
  if page <> nil then
    page.Max := v;
end;

procedure TPolarGraph.UpdateData;
var
  i: integer;
  g: cTagGraph;
begin
  //logMessage('TCntrlWrnChart.UpdateData tid: '+inttostr(GetCurrentThreadId));
  // spmChart.activePage.caption := modname(spmChart.activePage.caption, false);
  for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    g.UpdateData;
  end;
end;

procedure TPolarGraph.UpdateView;
var
  i: integer;
  g: cTagGraph;
begin
  for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    g.UpdateView;
  end;
  chart.redraw;
end;

procedure TPolarGraph.setGraphName(v: string);
begin
  fGraphName := v;
  if page <> nil then
  begin
    page.caption := v;
  end;
end;



function TPolarGraph.getGraph(i: integer): cTagGraph;
begin
  result := cTagGraph(m_graphlist.items[i]);
end;

function TPolarGraph.getGraph(gname: string): cTagGraph;
var
  I: Integer;
  g:cTagGraph;
begin
  result:=nil;
  for I := 0 to m_graphlist.Count - 1 do
  begin
    g := cTagGraph(m_graphlist.items[i]);
    if g.name=gname then
    begin
      result:=g;
      exit;
    end;
  end;
end;

function TPolarGraph.getGraphMax: double;
begin
  result := fGraphMax;
end;

function TPolarGraph.getGraphName: string;
begin
  result:=fGraphName;
end;

function TPolarGraph.getPSize: double;
begin
  result:=fpsize;
end;

procedure TPolarGraph.setPSize(v: double);
begin
  fpsize:=v;
  if page<>nil then
  begin
    page.psize:=v;
  end;
end;

function TPolarGraph.GraphCount: integer;
begin
  result := m_graphlist.Count;
end;

{ IPolarFrm }
procedure IPolarFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IPolarFrm.doCreateFrm: TRecFrm;
begin
  result := TPolarGraph.create(nil);
end;

function IPolarFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IPolarFrm.doRepaint: boolean;
begin
  inherited;
  TPolarGraph(m_pMasterWnd).UpdateView;
end;

{ cTagGraph }
constructor cTagGraph.create(chart: cchart);
begin
  InitCS;
  fload := false;
  PColor := clblack;
  m_TahoColor:=clYellow;
  m_TurnCount:=10;
  m_SyncTags:=true;
  PCount := 1;
  m_xTag := ctag.create;
  m_yTag := ctag.create;
  m_taho := ctag.create;

  m_tr:=cPolarGraphTag.create;
end;

destructor cTagGraph.destroy;
begin
  m_xTag.destroy;
  m_yTag.destroy;
  m_taho.destroy;
  m_tr.destroy;
  inherited;
end;


procedure cTagGraph.createTag(tagname: string);
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

procedure cTagGraph.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;


procedure cTagGraph.EnterCS;
begin
  // EnterCriticalSection(cs);
  EnterTrendCS;
end;

procedure cTagGraph.EnterTrendCS;
begin
  m_tr.EnterCS;
end;

procedure cTagGraph.ExitCS;
begin
  ExitTrendCS;
end;

procedure cTagGraph.ExitTrendCS;
begin
  m_tr.ExitCS;
end;

function cTagGraph.GetColor: tcolor;
begin
  result:=fcolor;
end;

procedure cTagGraph.SetColor(const Value: tcolor);
begin
  fcolor:=value;
  if m_tr<>nil then
  begin
    m_tr.color:=inttorgb(fcolor);
  end;
end;

procedure cTagGraph.SetPColor(const Value: TColor);
begin
  fPointsColor:=Value;
  if m_tr<>nil then
  begin
    m_tr.PointColor:=inttorgb(value);
  end;
end;

function cTagGraph.GetPColor: TColor;
begin
  result:=fPointsColor;
end;

procedure cTagGraph.init;
begin
  m_xTag.doOnStart;
  m_yTag.doOnStart;
  m_taho.doOnStart;
  fused:=0;
  readyturn:=0;
  m_tr.fneedrecompile:=true;
end;

procedure cTagGraph.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure cTagGraph.initgraph;
var
  index:integer;
  I: Integer;
begin
  if m_tr = nil then
    m_tr := cPolarGraphTag.create;
  if fPolarGraph.chart.activePage <> nil then
  begin
    index:=0;
    for I := 0 to fPolarGraph.m_GraphList.Count - 1 do
    begin
      if self = fPolarGraph.getGraph(i) then
      begin
        index:=i;
        break;
      end;
    end;
    cPolarGraphTag(m_tr).data:=self;
    m_tr.color := ColorArray[index];
    m_tr.pointcolor := ColorArray[index];
    if fload then
    begin
      m_tr.pointcolor := inttorgb(PColor);
      m_tr.color := inttorgb(Color);
      m_tr.FirstPointColor:= inttorgb(TahoColor);
      UseTaho:=UseTaho;
    end;
    m_tr.name := name;
    fPolarGraph.page.AddChild(m_tr);
  end;
end;


function cTagGraph.GetDrawFPLine: boolean;
begin
  result:=fDrawFPLine;
end;

procedure cTagGraph.SetDrawFPLine(const Value: boolean);
begin
  fDrawFPLine:=Value;
end;

procedure cTagGraph.SetDrawLine(const Value: boolean);
begin
  fDrawLine:=value;
  if m_tr<>nil then
  begin
    m_tr.DrawLines:=value;
  end;
end;

function cTagGraph.GetDrawLine: boolean;
begin
  result:=fDrawLine;
end;

procedure cTagGraph.SetDrawPoints(const Value: boolean);
begin
  fDrawPoints:=value;
  if m_tr<>nil then
  begin
    m_tr.DrawPoints:=value;
  end;
end;

function cTagGraph.GetDrawPoints: boolean;
begin
  result:=fDrawPoints;
end;

procedure cTagGraph.setname(p_name: string);
var
  index: integer;
  obj: TWrkPoint;
begin
  if p_name = name then
    exit;
  if m_owner <> nil then
  begin

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

procedure cTagGraph.setPCount(c: integer);
begin
  fPCount := c;
  SetLength(fXdata, c);
  SetLength(fYdata, c);
  SetLength(fTurns,c shr 1);
  // SetLength(fdrawarray, c);
  // SetLength(fdxPCount, c);
end;

procedure cTagGraph.SetTahoColor(c: TColor);
begin
  m_TahoColor:=c;
  if m_tr<>nil then
  begin
    m_tr.FirstPointColor:=inttoRGB(m_TahoColor);
  end;
end;

procedure cTagGraph.setTurnCount(const Value: integer);
begin
  m_TurnCount:=value;
  SetLength(fFirstPointData, m_TurnCount);
end;

function cTagGraph.GetTahoColor: TColor;
begin
  result:=m_TahoColor;
end;

function cTagGraph.GetUseTaho: boolean;
begin
  result:=m_UseTaho;
end;

procedure cTagGraph.SetUseTaho(b: boolean);
begin
  m_UseTaho:=b;
  if m_tr<>nil then
  begin
    m_tr.UseFirstPoint:=b;
  end;
end;

procedure cTagGraph.evalTurnTimes;
var
  i, startind, endind :integer;
  trig:boolean;
  v, t, threshold:double;
  minmax:point2d;
  mathstats:TMathStats;
begin
  if m_taho.tag=nil then exit;
  trig:=true;  // работаем начиная с второго оборота
  m_tr.EnterCS;
  readyturn:=0;
  startind:=0;
  endind:=m_taho.lastindex-1;
  if m_SyncTags then
  begin
    // просматриваем не весь массив а только ту часть которая по времени синхронизирована с буферами x,y данных
    startind:=endind-fPCount;
  end;
  mathstats:=GetStats(m_taho.m_ReadData,startind,endind);
  threshold:=m_TahoThreshold*mathstats.a;
  if startind<0 then
    exit;
  for I :=startind to endind do
  begin
    //// ERROR
    v:=m_taho.m_ReadData[i]-mathstats.m;
    if not trig then
    begin
      if v>threshold then
      begin
        t:=m_taho.getReadTime(i);
        fTurns[readyturn].t:=t;
        fTurns[readyturn].tahoind:=i;
        // корректно только для синхронных тегов
        fTurns[readyturn].xind:=m_xTag.getIndex(t)-startind;
        fTurns[readyturn].yind:=m_yTag.getIndex(t)-startind;
        inc(readyturn);
        trig:=true;
      end;
    end
    else
    begin
      if v<threshold then
      begin
        trig:=false;
      end;
    end;
  end;
  m_taho.ResetTagData();
  m_tr.exitcs;
end;

function cPolarGraphTag.FPcount: integer;
begin
  result:=data.readyturn;
  if Data.m_BuffType=1 then
  begin
    if data.readyturn>Data.m_TurnCount then
      result:=Data.m_TurnCount;
  end;
end;

function cPolarGraphTag.FPindex(i: integer): integer;
begin
  result:=data.fTurns[i].xind;
  begin
    if data.readyturn>Data.m_TurnCount then
      result:=data.fTurns[data.readyturn-Data.m_TurnCount+i].xind;
  end;
end;

procedure cTagGraph.UpdateData;
var
  startX, startY, startTaho :double;
  // сколько забираем новых данных
  lcount,
  // сколько копируем данных
  copyCount,
  // с какого элемента начинаем копировать данные
  fromInd:integer;
  I: Integer;
begin
  EnterCS;
  if m_updateX then
    m_XTag.UpdateTagData(true)
  else
    m_updateX:=m_XTag.UpdateTagData(true);
  if m_updateY then
    m_YTag.UpdateTagData(true)
  else
    m_updateY:=m_YTag.UpdateTagData(true);
  if not(m_updateX and m_updateY) then
  begin
    ExitCS;
    exit;
  end;
  startX:=m_XTag.getReadTime(0);
  startY:=m_YTag.getReadTime(0);
  if UseTaho then
  begin
    m_taho.UpdateTagData(true);
    evalTurnTimes;
  end;

  if m_SyncTags then
  begin
    fromInd:=0;
    lcount:=m_XTag.lastindex;
    copycount:=lcount;
    if lcount>fPCount then
    begin
      lcount:=fPCount;
      fromInd:=m_XTag.lastindex-fPCount;
      copycount:=fPCount;
    end;
    if lcount>(fPCount-fLastIndex) then
    begin
      copycount:=(fPCount-fLastIndex);
    end;
    fused:=fused+copycount;
    if fused>fPCount then
      fused:=fPCount;

    move(m_XTag.m_ReadData[fromind], fXdata[fLastIndex], copycount*sizeof(double));
    move(m_YTag.m_ReadData[fromind], fYdata[fLastIndex], copycount*sizeof(double));
    // докопируем кусок данных который не вместился до конца буфера
    if copycount<lcount then
    begin
      move(m_XTag.m_ReadData[fromind+copycount], fXdata[0], lcount-copycount);
      move(m_YTag.m_ReadData[fromind+copycount], fYdata[0], lcount-copycount);
      fLastIndex:=lcount-copycount;
    end;
  end
  else
  begin

  end;
  m_XTag.ResetTagData();
  m_YTag.ResetTagData();
  ExitCS;
  m_tr.fneedrecompile:=true;
  m_updateX:=false;
  m_updateY:=false;
end;

procedure cTagGraph.UpdateView;
begin
  // отрисовка
  EnterCS;
  //m_tr.Clear;
  //m_tr.addpoints(fdrawarray, fready);
  exitcs;
end;

{ cPolarGraphTag }


constructor cPolarGraphTag.create;
begin
  inherited;
end;

function cPolarGraphTag.getCount: integer;
begin
  if data<>nil then
    result:=data.fused
  else
    result:=0;
end;

function cPolarGraphTag.GetDrawFPLine: boolean;
begin
  result:=Data.fDrawFPLine;
end;

function cPolarGraphTag.getP2(i: integer): point2;
var
  ind:integer;
begin
  ind:=convertindex(i);
  result.x:=Data.m_xTag.m_ReadData[ind];
  result.y:=Data.m_yTag.m_ReadData[ind];
end;

function cPolarGraphTag.getx(i: integer): double;
begin
  result:=Data.m_xTag.m_ReadData[convertindex(i)];
end;

function cPolarGraphTag.gety(i: integer): double;
var
  ind:integer;
begin
  result:=Data.m_yTag.m_ReadData[convertindex(i)];
end;

function cPolarGraphTag.convertindex(i: integer): integer;
begin
  if Data.fused<Data.fPCount then
    result:=i
  else
  begin
    result:=Data.fLastIndex+i+1;
    if result=Data.fPCount then
      result:=0;
  end;
end;

procedure cPolarGraphTag.init(tagGraph: cTagGraph);
begin
  data:=tagGraph;
end;



end.
