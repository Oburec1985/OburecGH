unit uIRDiagram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath, uDoubleCursor, uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, utextlabel, tags,
  PluginClass,
  blaccess,
  ImgList, uChart, uGrmsSrcAlg, uPhaseAlg, usetlist, upage,
  uCommonTypes,
  uGraphObj,
  uBasePage,
  OpenGL,
  math,
  complex,
  uHardwareMath,
  ufloatlabel,
  utext,
  uqueue,
  uSpm;

type
  spmPoint = record
    spm: array of point2d;
    t: double;
    ind: integer;
    len: integer;
  end;

  // алгоритм который собирает данные спектров канала и тахо в единий канал
  cIRAlg = class(cbasealg)
  public
    ftaho, fspm: cspm;
  private
    fowner: tobject;
    fnewData: boolean;
    // размер буфера в секундах (буфер нужен для соединения данных тахо и основного тега в
    // единый массив без ошибок по времени)
    fBuffLength: double;
    fTaxodx: double; // шаг между посчитанными спектрами по времени
    // значение комплексного спектра на главной гармонике
    // x y= re im; z = t; u = Fmax
    fTahoBuff: cqueue<point4d>;
    fSpmdx: double; // шаг между посчитанными спектрами по времени
    // значение комплексного спектра на главной гармонике
    // queue
    fSpmBuff: cqueue<spmPoint>;
    // полоса анализа вокруг главной частоты тахо в долях
    fband: point2d;
    fband_i: point2d;
    fTahoValue: double;

    fOut: cqueue<point2d>;
    // число расчитанных точек/ счет внутри fOut
    pCount: integer;
  protected
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    procedure doEndEvalBlock(sender: tobject); override;
    procedure doUpdateSrcData(sender: tobject); override;
    procedure doOnStart; override;
    function ready: boolean; override;
    // пересчитать по входным тегам размеры буферов данных, dx по времени для каналов
    procedure UpdateChannels(spm, taho: string); overload;
    procedure UpdateChannels(spm, taho: cspm); overload;
  public
    procedure resetdata;
    function newData: boolean;
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

  IRDiagramTag = class(cGraphObj)
  private
    // отрисовка линии
    fListId: cardinal;
    fneedrecompile: boolean;
    // рисовать линии
    fDrawLines: boolean;
    // рисовать точки
    fDrawPoints: boolean;
    // цвет вершин
    fPointColor: point3;

    xTime, yTime: double;
  public
    m_irAlg: cIRAlg;
    // fxpoints, fypoints:array of double;
  protected
  protected
    procedure doLincParent; override;
    procedure compile; virtual;
    procedure DrawData; override;
    procedure setmainParent(p: cbaseObj); override;
    // число точек
    function getCount: integer; override;
    procedure setCount(i: integer); override;
  public
    procedure push(p2: point2d);
    // пересчитать данные из fspm, ftahospm в отрисовываемые вершины
    procedure updateData;
    //
    Procedure ConfigTag(spm, taho: cspm); overload;
    Procedure ConfigTag(spm, taho: string); overload;
    property DrawLines: boolean read fDrawLines write fDrawLines;
    property DrawPoints: boolean read fDrawPoints write fDrawPoints;
    property PointColor: point3 read fPointColor write fPointColor;
    constructor create; override;
  end;

  cIRPage = class(cBasePage)
  private
    // хоть раз отрисовалась (границы не нулевые. Нужно для инициации текстовых меток)
    init: boolean;

    fneedrecompile: boolean;
    // матрица вида оси
    stateM: matrixgl;
    // шаг сетки
    m_gridStep: double;
    // отрисовка сетки
    fGridListId: cardinal;
    // отсутупы в пикселях
    m_Tab: integer;
    // размер точек
    fDrawPointSize: double;

    m_MaxXedit, m_MaxYedit: cfloatlabel;
    m_PageLabel: cLabel;

    m_graphList: tlist;
  protected
    fXAxis, fYAxis: point2d;
  protected
    procedure setXAxis(p2: point2d);
    procedure setYAxis(p2: point2d);
    procedure compile;
    procedure drawPage;
    procedure DrawCross;
    procedure DrawGrid;
    procedure DrawGraphBorder;

    procedure initTEdit(edit: cdrawobj);
    procedure UpdateAxisbyText(sender: tobject; var Key: Word;
      Shift: TShiftState);
    procedure setmax(e: cfloatlabel; v: double);
    function ModComponentName(p_name: string): string;
    Procedure OutText(str: PCHAR; p2: point2; align: integer; index: integer);
    // раставить эдиты
    procedure setEditPos(sender: tobject);
    procedure SetLabelPos;

    procedure PrepareZoom;
    procedure setzoom;

    procedure setYAx(p:point2d);
    function GetYAxis:point2d;

    procedure SetXAx(p:point2d);
    function GetXAxis:point2d;
  protected
    property YAxis:point2d read GetYAxis write setYAx;
    property XAxis:point2d read GetXAxis write SetXAx;
    // обязательный признак!!! показывает что в страницу встроены другие компоненты
    function isCarrier: boolean; override;
    // прилинковаться к компоненту в котором будет происходить отрисовка
    procedure linc(p_chart: tcomponent); override;
    procedure setCaption(s: string); override;
    procedure BeforeDrawChild; override;
    procedure setBound(rect: trect); override;
    procedure DrawData; override;

    constructor create; override;
    destructor destroy; override;
  public
    function mainParentClassName: string; override;
  end;

  TIRDiagramFrm = class(TRecFrm)
  private
    // m_graphlist: tlist;
  public
    chart: cchart;
    fpage: cIRPage;

    fGraphName: string;
    fGraphMax: double;
    fpsize: double;
  protected
    procedure ChartInit(sender: tobject);
    procedure RBtnClick(sender: tobject);
    function getGraphMax: double;
    procedure setGraphMax(v: double);
    function getPSize: double;
    procedure setPSize(v: double);
    function getGraphName: string;
    procedure setGraphName(v: string);
    procedure createevents;
    procedure destroyevents;
    procedure doOnZoom(sender: tobject);
    procedure UpdateView;
    procedure updateData;
    procedure doStart;
  public
    procedure clearGraphList;
    function GraphCount: integer;
    function getGraph(i: integer): IRDiagramTag; overload;
    function getGraph(gname: string): IRDiagramTag; overload;
    function addGraph(p_name: string): IRDiagramTag;
    property GraphMax: double read getGraphMax write setGraphMax;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    property GraphName: string read getGraphName write setGraphName;
    property PSize: double read getPSize write setPSize;
  end;

  IRDiagramFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cIRDiagramFactory = class(cRecBasicFactory)
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
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;



var
  g_IRDiagramFactory: cIRDiagramFactory;

const
  c_Pic = 'IRDIAGRAM';
  c_Name = 'Диаграмма Найквиста';
  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  // ['{DE3939E6-AF72-47FB-B17B-C741AA578B13}']
  IID_DIAGRAM: TGuid = (D1: $DE3939E6; D2: $AF72; D3: $47FB;
    D4: ($B1, $7B, $C7, $41, $AA, $57, $8B, $13));

implementation

uses uEditPolarFrm;
{$R *.dfm}
{ cIRDiagramFactory }

constructor cIRDiagramFactory.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_DIAGRAM;
  createevents;
end;

destructor cIRDiagramFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cIRDiagramFactory.createevents;
begin
  // addplgevent('cCtrlWrnFactory_doChangeRState', c_RC_DoChangeRCState,   doChangeRState);
  // addplgevent('cCtrlWrnFactory_doLoad', c_RC_LoadCfg, doLoad);
  // addplgevent('cCtrlWrnFactory_doSave', c_RC_SaveCfg, doSave);
  addplgevent('cIRDiagramFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cIRDiagramFactory_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
end;

procedure cIRDiagramFactory.destroyevents;
begin
  // removeplgEvent(doChangeRState, c_RC_ChangeState);
  // removeplgEvent(doLoad, c_RC_LoadCfg);
  // removeplgEvent(doSave, c_RC_SaveCfg);
  removeplgEvent(doUpdateData, c_RUpdateData);
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cIRDiagramFactory.doUpdateData(sender: tobject);
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TIRDiagramFrm(Frm).updateData;
  end;
end;

procedure cIRDiagramFactory.doAfterLoad;
begin
  inherited;
end;

procedure cIRDiagramFactory.doChangeRState(sender: tobject);
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

function cIRDiagramFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := IRDiagramFrm.create();
  end;
end;

procedure cIRDiagramFactory.doDestroyForms;
begin
  inherited;

end;

procedure cIRDiagramFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
  PSize.cx := c_defXSize;
  PSize.cy := c_defYSize;
end;

procedure cIRDiagramFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TIRDiagramFrm(Frm).doStart;
  end;
end;

{ TPolarGraph }
function TIRDiagramFrm.addGraph(p_name: string): IRDiagramTag;
begin
  result := IRDiagramTag.create;
  result.name := p_name;
  fpage.AddChild(result);
  fpage.m_graphList.Add(result);
end;

procedure TIRDiagramFrm.ChartInit(sender: tobject);
var
  i: integer;
  g: IRDiagramTag;
  p2: point2d;
begin
  fpage := cIRPage.create;
  chart.name := 'IRDiagram';
  chart.activeTab.AddChild(fpage);
  chart.activePage.destroy;
  chart.activeTab.Alignpages(1);
  chart.activePage := fpage;
  GraphName := 'Диаграмма Найквиста';
  createevents;
  if GraphMax <> 0 then
  begin
    // page.Max := GraphMax;
  end;
  PSize := PSize;

  g := addGraph('test_001');
  // g.Count:= 10;
  for i := 0 to 9 do
  begin
    p2.x := i;
    p2.y := i * i;
    g.push(p2);
  end;
  g.ConfigTag('3- 1', '18- 1_taho');
  g.fneedrecompile := true;
end;

procedure TIRDiagramFrm.RBtnClick(sender: tobject);
begin
  if TIRDiagramFrm <> nil then
  begin

  end;
end;

procedure TIRDiagramFrm.setGraphMax(v: double);
begin

end;

procedure TIRDiagramFrm.clearGraphList;
var
  i: integer;
  gr: IRDiagramTag;
begin
  // for I := 0 to m_graphlist.Count - 1 do
  // begin
  // gr:=getGraph(i);
  // gr.Destroy;
  // end;
  // m_graphlist.Clear;
end;

constructor TIRDiagramFrm.create(Aowner: tcomponent);
begin
  inherited;
  // fGraphName:='Гистограмма биений';
  // m_graphlist := tlist.create;
  chart := cchart.create(self);
  chart.align := alClient;
  chart.showTV := false;
  chart.showLegend := false;
  chart.OnInit := ChartInit;
  chart.OnRBtnClick := RBtnClick;
end;

destructor TIRDiagramFrm.destroy;
begin
  clearGraphList;
  destroyevents;
  chart.destroy;
  chart := nil;
  inherited;
end;

procedure TIRDiagramFrm.createevents;
begin
  chart.Objmng.Events.AddEvent('IRDiagram_onZoom', E_OnZoom, doOnZoom);
end;

procedure TIRDiagramFrm.destroyevents;
begin
  chart.Objmng.Events.removeEvent(doOnZoom, E_OnZoom);
end;

procedure TIRDiagramFrm.doOnZoom(sender: tobject);
begin
  // fGraphMax := page.Max;
end;

procedure TIRDiagramFrm.doStart;
var
  i: integer;
  g: IRDiagramTag;
begin
  for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    g.m_irAlg.doOnStart;
    // g.init;
  end;
end;

procedure TIRDiagramFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, Count: integer;
  lstr: string;
  gr: IRDiagramTag;
begin
  inherited;
  GraphMax := readFloatFromIni(a_pIni, str, 'GridMax');
  PSize := readFloatFromIni(a_pIni, str, 'PSize');
  GraphName := a_pIni.ReadString(str, 'ComponentName', 'Гистограмма биений');
  Count := a_pIni.ReadInteger(str, 'GraphCount', 1);
  for i := 0 to Count - 1 do
  begin
    lstr := a_pIni.ReadString(str, 'GraphName_' + inttostr(i), '');
    if lstr <> '' then
    begin
      gr := addGraph(lstr);
      // gr.fload :=true;
      // gr.DrawPoints:=a_pIni.Readbool(str, 'GraphDrawPoints_' + inttostr(i), true);
      // gr.DrawLine:=a_pIni.Readbool(str, 'GraphDrawLine_' + inttostr(i), true);
    end;
  end;
end;

procedure TIRDiagramFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  gr: IRDiagramTag;
  ax: taxis;
begin
  inherited;
  a_pIni.WriteFloat(str, 'GridMax', GraphMax);
  a_pIni.WriteFloat(str, 'PSize', PSize);
  // a_pIni.WriteInteger(str, 'GraphCount', m_graphlist.Count);
  a_pIni.WriteString(str, 'ComponentName', GraphName);
  // for i := 0 to m_graphlist.Count - 1 do
  // begin
  // gr := getGraph(i);
  // a_pIni.WriteString(str, 'GraphName_' + inttostr(i), gr.name);
  // a_pIni.WriteBool(str, 'GraphDrawPoints_' + inttostr(i), gr.DrawPoints);
  // end;
end;

procedure TIRDiagramFrm.updateData;
var
  i: integer;
  g: IRDiagramTag;
begin
  // logMessage('TCntrlWrnChart.UpdateData tid: '+inttostr(GetCurrentThreadId));
  // spmChart.activePage.caption := modname(spmChart.activePage.caption, false);
  for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    g.updateData;
    g.m_irAlg.resetdata;
  end;
end;

procedure TIRDiagramFrm.UpdateView;
var
  i: integer;
  g: IRDiagramTag;
begin
  for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    if g.m_irAlg.newData then
    begin
      g.fneedrecompile := true;
    end;
  end;
  chart.redraw;
end;

procedure TIRDiagramFrm.setGraphName(v: string);
begin
  fGraphName := v;
  // if page <> nil then
  // begin
  // page.caption := v;
  // end;
end;

function TIRDiagramFrm.getGraphName: string;
begin
  if fGraphName = '' then
  begin
    result := classname;
  end
  else
    result := fGraphName;
end;

function TIRDiagramFrm.getGraph(i: integer): IRDiagramTag;
begin
  result := IRDiagramTag(fpage.m_graphList.items[i]);
end;

function TIRDiagramFrm.getGraph(gname: string): IRDiagramTag;
var
  i: integer;
  g: IRDiagramTag;
begin
  result := nil;
  for i := 0 to fpage.m_graphList.Count - 1 do
  begin
    g := IRDiagramTag(fpage.m_graphList.items[i]);
    if g.name = gname then
    begin
      result := g;
      exit;
    end;
  end;
end;

function TIRDiagramFrm.getGraphMax: double;
begin
  result := fGraphMax;
end;

function TIRDiagramFrm.getPSize: double;
begin
  // result:=fpsize;
end;

procedure TIRDiagramFrm.setPSize(v: double);
begin
  // fpsize:=v;
  // if page<>nil then
  // begin
  // page.psize:=v;
  // end;
end;

function TIRDiagramFrm.GraphCount: integer;
begin
  result := fpage.m_graphList.Count;
end;

{ IPolarFrm }
procedure IRDiagramFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IRDiagramFrm.doCreateFrm: TRecFrm;
begin
  result := TIRDiagramFrm.create(nil);
end;

function IRDiagramFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IRDiagramFrm.doRepaint: boolean;
begin
  inherited;
  TIRDiagramFrm(m_pMasterWnd).UpdateView;
end;

{ IRDiagramTag }
procedure IRDiagramTag.compile;
var
  i, ind: integer;
  lp: point2;
  p2: point2d;
begin
  if fneedrecompile then
  begin
    fneedrecompile := false;
    if fListId <> 0 then
      glDeleteLists(fListId, 1);
    fListId := glGenLists(1);
    glNewList(fListId, GL_COMPILE);
    // отрисовка линий
    if DrawLines then
    begin
      glColor3fv(@color);
      glBegin(GL_LINE_STRIP);
      for i := 0 to Count - 1 do
      begin
        p2 := m_irAlg.fOut.peak(i);
        lp.x := p2.x;
        lp.y := p2.y;
        glVertex2fv(@lp);
      end;
      glEnd;
    end;
    // отрисовка точек
    if DrawPoints then
    begin
      glColor3fv(@fPointColor);
      glBegin(GL_Points);
      for i := 0 to Count - 1 do
      begin
        p2 := m_irAlg.fOut.peak(i);
        lp.x := p2.x;
        lp.y := p2.y;
        glVertex2fv(@lp);
      end;
      glEnd;
    end;
    glEndList;
  end;
end;

procedure IRDiagramTag.ConfigTag(spm, taho: cspm);
begin
  m_irAlg.UpdateChannels(spm, taho);
end;

procedure IRDiagramTag.ConfigTag(spm, taho: string);
begin
  m_irAlg.UpdateChannels(spm, taho);
end;

constructor IRDiagramTag.create;
begin
  inherited;
  m_irAlg := cIRAlg.create;
  m_irAlg.fowner := self;
  if g_algmng <> nil then
  begin
    g_algmng.Add(m_irAlg);
  end;
  DrawPoints := true;
  fPointColor := red;
  DrawLines := true;
  fcolor := blue;
end;

procedure IRDiagramTag.doLincParent;
begin
  inherited;
end;

procedure IRDiagramTag.DrawData;
begin
  inherited;
  compile;
  glMatrixMode(gl_projection);
  glpushmatrix;
  cIRPage(parent).setzoom;
  glCallList(fListId);
  glPopMatrix;
end;

function IRDiagramTag.getCount: integer;
begin
  result := m_irAlg.fOut.SIZE;
end;

procedure IRDiagramTag.push(p2: point2d);
begin
  m_irAlg.fOut.push_back(p2);
end;

procedure IRDiagramTag.setCount(i: integer);
begin
  inherited;
  m_irAlg.fOut.capacity := i;
end;

procedure IRDiagramTag.setmainParent(p: cbaseObj);
begin
  inherited;

end;

procedure IRDiagramTag.updateData;
var
  i: integer;
begin
  // if m_irAlg.newData then
  // begin
  // m_irAlg.newData := false;
  // fneedrecompile := true;
  // end;
end;

{ cIRPage }
procedure cIRPage.BeforeDrawChild;
begin
  inherited;
  glMatrixMode(GL_PROJECTION_MATRIX);
  glloadidentity;
end;

procedure cIRPage.compile;
begin
  if fneedrecompile then
  begin
    fneedrecompile := false;
    if fGridListId <> 0 then
      glDeleteLists(fGridListId, 1);
    fGridListId := glGenLists(1);
    glNewList(fGridListId, GL_COMPILE);
    glEndList;
  end;
end;

procedure cIRPage.initTEdit(edit: cdrawobj);
begin
  edit.fhelper := true;
  cfloatlabel(edit).fEnabled := true;
  cfloatlabel(edit).OnKeyEnter := UpdateAxisbyText;
  cfloatlabel(edit).Transparent := false;
  AddChild(edit);
end;

function cIRPage.isCarrier: boolean;
begin
  result := true;
end;

// Обновить оси при вводе текста в TEdit
procedure cIRPage.UpdateAxisbyText(sender: tobject; var Key: Word;
  Shift: TShiftState);
var
  rect: fRect;
  v: double;
begin
  if Key = 13 then
  begin
    v := strtofloatext(cfloatlabel(sender).Text);
    setmax(cfloatlabel(sender), v);
  end;
  cchart(chart).redraw;
end;

constructor cIRPage.create;
begin
  inherited;
  m_graphList := tlist.create;

  m_MaxXedit := cfloatlabel.create;
  m_MaxXedit.autocreate := true;
  m_MaxXedit.textcolor := blue;
  m_MaxXedit.align := utext.c_right;
  m_MaxXedit.Name := modname('IRMaxXEdit', false);
  m_MaxXedit.Transparent := true;
  initTEdit(m_MaxXedit);

  m_MaxYedit := cfloatlabel.create;
  m_MaxYedit.autocreate := true;
  m_MaxYedit.textcolor := blue;
  m_MaxYedit.align := utext.c_right;
  m_MaxYedit.Name := modname('IRMaxYEdit', false);
  m_MaxYedit.Transparent := true;
  initTEdit(m_MaxYedit);

  fDrawPointSize := 5;

  fXAxis.x := -10;
  fXAxis.y := 10;
  fYAxis.x := -10;
  fYAxis.y := 10;

  PrepareZoom;
  color := white;
end;

destructor cIRPage.destroy;
begin
  m_graphList.destroy;
  inherited;
end;

procedure cIRPage.DrawCross;
var
  width, w: double;
begin
  glColor3fv(@gray);
  glGetDoubleV(GL_LINE_WIDTH, @w);
  width := 1;
  glLineWidth(width);
  glBegin(GL_LINES);
  glvertex2f(-1, 0);
  glvertex2f(1, 0);
  glvertex2f(0, -1);
  glvertex2f(0, 1);
  glEnd;
  glLineWidth(w);
end;

procedure cIRPage.DrawData;
begin
  glPointSize(fDrawPointSize);
  compile;
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  setCommonVP;
  // отрисовка фона страницы
  drawPage;
  // отрисовка рамки страницы
  drawBound;
  setDrawObjVP;

  // отрисовка крестика
  DrawCross;
  // отрисовка рамки поля вывода самого графика
  DrawGraphBorder;
  // установка матрицы вида для отрисовки внутри поляв ывода
  setzoom;
  DrawGrid;

  glPopMatrix;
  inherited;
end;

procedure cIRPage.DrawGraphBorder;
var
  width, w: double;
begin
  glColor3fv(@red);
  glGetDoubleV(GL_LINE_WIDTH, @w);
  width := 2;
  glLineWidth(width);
  glBegin(GL_LINE_STRIP);
  glvertex2f(-1, -1);
  glvertex2f(-1, 1);
  glvertex2f(1, 1);
  glvertex2f(1, -1);
  glvertex2f(-1, -1);
  glEnd;
  glLineWidth(w);
end;

Procedure cIRPage.OutText(str: PCHAR; p2: point2; align: integer;
  index: integer);
begin
  getfont(index).OutText(str, p2, align);
end;

procedure cIRPage.DrawGrid;
var
  gridstepx, gridstepy, range, mingridx, maxgridx, mingridy, maxgridy,
    pos: double;
  order, n: integer;
  str: string;
begin
  // расчет сетки по X
  range := fXAxis.y - fXAxis.x;
  order := trunc(log10(range));
  dec(order);
  gridstepx := power(10, order);
  n := round((fXAxis.y - fXAxis.x) / gridstepx);
  if n > 20 then
  begin
    gridstepx := gridstepx * 5;
  end;
  mingridx := gridstepx * trunc(fXAxis.x / gridstepx);
  maxgridx := gridstepx * trunc(fXAxis.y / gridstepx);
  // расчет сетки по Y
  range := fYAxis.y - fYAxis.x;
  order := trunc(log10(range));
  dec(order);
  gridstepy := power(10, order);
  n := round((fYAxis.y - fYAxis.x) / gridstepy);
  if n > 20 then
  begin
    gridstepy := gridstepy * 5;
  end;
  mingridy := gridstepy * trunc(fYAxis.x / gridstepy);
  maxgridy := gridstepy * trunc(fYAxis.y / gridstepy);

  glLineStipple(1, $F0F0);
  glEnable(GL_LINE_STIPPLE);
  glColor3fv(@gray);
  // рисуем сетку по X
  glBegin(GL_LINES);
  pos := mingridx;
  while pos < maxgridx do
  begin
    glvertex2d(pos, fYAxis.x);
    glvertex2d(pos, fYAxis.y);
    pos := pos + gridstepx;
  end;
  // рисуем сетку по Y
  pos := mingridy;
  while pos < maxgridx do
  begin
    glvertex2d(fXAxis.x, pos);
    glvertex2d(fXAxis.y, pos);
    pos := pos + gridstepy;
  end;
  glEnd;
  glDisable(GL_LINE_STIPPLE);
  // подписываем оси X
  pos := mingridx;
  while pos < maxgridx do
  begin
    str := formatstr(pos, 4);
    OutText(PCHAR(str), p2(pos, 0), c_left, c_AxisFontInd);
    pos := pos + gridstepx;
  end;
  // подписываем оси Y
  pos := mingridy;
  while pos < maxgridy do
  begin
    str := formatstr(pos, 4);
    OutText(PCHAR(str), p2(0, pos), c_left, c_AxisFontInd);
    pos := pos + gridstepy;
  end;
end;

procedure cIRPage.drawPage;
begin
  glColor3fv(@color);
  // отрисовка полигона ащте
  glBegin(GL_QUADs);
  glvertex2f(-1, -1);
  glvertex2f(-1, 1);
  glvertex2f(1, 1);
  glvertex2f(1, -1);
  glEnd;
end;

function cIRPage.ModComponentName(p_name: string): string;
var
  obj: tcomponent;
  i: integer;
begin
  if self.chart <> nil then
  begin
    for i := 0 to cchart(self.chart).ComponentCount - 1 do
    begin
      obj := cchart(self.chart).Components[i];
    end;
    obj := cchart(self.chart).FindComponent(p_name);
    while obj <> nil do
    begin
      p_name := modname(p_name, false);
      obj := cchart(self.chart).FindComponent(p_name);
    end;
  end;
  result := p_name;
end;

procedure cIRPage.setBound(rect: trect);
var
  clientrect: trect;
  w, h: integer;
begin
  clientrect := getClientBound;
  if rect.Left < clientrect.Left then
    rect.Left := clientrect.Left;
  if rect.Top > clientrect.Top then
    rect.Top := clientrect.Top;
  if rect.Right > clientrect.Right then
    rect.Right := clientrect.Right;
  if rect.Bottom < clientrect.Bottom then
    rect.Bottom := clientrect.Bottom;
  if rect.Left > rect.Right then
    rect.Right := rect.Left;
  if rect.Bottom > rect.Top then
    rect.Top := rect.Bottom;
  w := clientrect.Right - clientrect.Left;
  h := clientrect.Top - clientrect.Bottom;
  if (w <= 0) or (h <= 0) then
  begin
    exit;
  end;

  ibound := rect;
  GetNormalViewport(m_NormalViewport);
  EvalRelativeBound(ibound);

  // UpdatePixTabs;
  SetTabSpace(m_pixelTabSpace);

  // расстановка меток по осям
  setEditPos(nil);

  if not init then
  begin
    m_MaxYedit.Text := m_MaxYedit.Text;
    m_MaxXedit.Text := m_MaxXedit.Text;
    m_PageLabel.Text := m_PageLabel.Text;
  end;

  CallEventsWithSender(e_onresize, self);
  fneedrecompile := true;
end;

procedure cIRPage.linc(p_chart: tcomponent);
begin
  inherited;
  if m_PageLabel = nil then
  begin
    m_PageLabel := cLabel.create;
    m_PageLabel.Name := ModComponentName('PageLabel');

    m_PageLabel.autocreate := true;
    m_PageLabel.fhelper := true;
    m_PageLabel.Transparent := false;
    m_PageLabel.locked := true;
    AddChild(m_PageLabel);

    m_PageLabel.Text := 'Диаграмма Найквиста';
  end;
end;

function cIRPage.mainParentClassName: string;
begin

end;

procedure cIRPage.setCaption(s: string);
begin
  inherited;

end;

procedure cIRPage.setEditPos(sender: tobject);
var
  bounds, tabs: trect;
  tabtext: TPoint;
  topoffset: integer;
  ipos: TPoint;
  p: point2;
  w, h: integer;
begin
  if m_MaxYedit <> nil then
  begin
    bounds := bound;
    tabs := m_pixelTabSpace;
    topoffset := twincontrol(chart).Height - bounds.Top;
    w := getwidth;
    ipos.x := bounds.Left + (w shr 1);
    ipos.y := bounds.Top - tabs.Top;
    h := getheight;
    if (w <> 0) and (h <> 0) then
    begin
      p := p2iTop2(ipos);
      // по хорошему нужно выравнивать текст по краницам page.tabspace
      p.y := p.y - m_MaxYedit.GetTextHeigth;
      m_MaxYedit.position := p;

      ipos.x := bounds.Right - tabs.Right;
      ipos.y := bounds.Top - (getheight shr 1);
      p := p2iTop2(ipos);
      m_MaxXedit.position := p;
    end;
    // положение метки страницы
    SetLabelPos;
  end;
end;

procedure cIRPage.SetLabelPos;
var
  pos: point2;
  h: single;
  w: integer;
begin
  w := getwidth;
  if w <> 0 then
  begin
    if getheight <> 0 then
    begin
      h := m_PageLabel.GetTextHeigth;
      pos.y := 1 - 2 * h;
      // pos.x := 0 - m_PageLabel.GetTextWidth / 2+0.5;
      pos.x := 0.3;
      m_PageLabel.position := pos;
    end;
  end;
end;

procedure cIRPage.setmax(e: cfloatlabel; v: double);
begin
  if e = m_MaxXedit then
  begin
    m_MaxXedit.Text := floattostr(v);
    fXAxis.x := -v;
    fXAxis.y := v;
  end
  else
  begin
    m_MaxYedit.Text := floattostr(v);
    fYAxis.x := -v;
    fYAxis.y := v;
  end;
  PrepareZoom;
  fneedrecompile := true;
  CallEventsWithSender(E_OnZoom, self);
  compile;
end;

procedure cIRPage.setXAxis(p2: point2d);
begin
  fXAxis := p2;
end;

procedure cIRPage.setYAxis(p2: point2d);
begin
  fYAxis := p2;
end;

procedure cIRPage.PrepareZoom;
var
  ord: integer;
  r: glfloat;
  i: integer;
begin
  // заменена стандартная функция т.к. в случае изменения зума
  // из другого потока glOrtho не работает
  MathFunction.CreateOrthoMatrix(fXAxis.x, fXAxis.y, fYAxis.x, fYAxis.y, -1, 1,
    stateM);
  fneedrecompile := true;
end;

procedure cIRPage.setzoom;
begin
  // ======================Подготовка к рисованию=========================
  glMatrixMode(gl_projection);
  glloadmatrixf(@stateM);
end;

{ cIRAlg }

constructor cIRAlg.create;
begin
  inherited;
  fOut := cqueue<point2d>.create;
  fOut.capacity := 10;
  fOut.m_resizeMode := false;

  fSpmBuff := cqueue<spmPoint>.create;
  fTahoBuff := cqueue<point4d>.create;

  fband.x := 0.8;
  fband.y := 1.2;

  fBuffLength := 3;
  autocreate := true;
  Properties := '';
end;

destructor cIRAlg.destroy;
begin
  inherited;
  fSpmBuff.destroy;
  fTahoBuff.destroy;
end;

procedure cIRAlg.doOnStart;
begin
  inherited;
  fSpmBuff.clear;
  fTahoBuff.clear;

  pCount := 0;
end;

procedure cIRAlg.doUpdateSrcData(sender: tobject);
var
  // индекс в тестируемом спектре главной частоты по тахо
  i, ind: integer;
  res: double;
  // updatetaho
  t1, t2, x: double;
  c: TComplex_d;
  p2: point2d;
  sp: spmPoint;
  p4: point4d;
  bandwidthint, startind, endind, startind1, endind1, spmInd: integer;
begin
  x := ftaho.max.x;
  fTahoValue := x;

  if sender = ftaho then
  begin
    // количество отсчетов в спектре по которым усредняем
    startind := round(x * fband.x / ftaho.spmdX);
    endind := round(x * fband.y / ftaho.spmdX);
    if startind < 0 then
      startind := 0;
    if endind = startind then
      endind := startind + 1;
    if endind >= (AlignBlockLength(fspm.m_rms)) then
      endind := AlignBlockLength(fspm.m_rms) - 1;
    fband_i.x := startind;
    fband_i.y := endind;
    p2 := point2d(tCmxArray_d(ftaho.cmplx_resArray.p)[ftaho.minmax_i.y]);
    p4.x := p2.x;
    p4.y := p2.y;
    p4.z := ftaho.LastBlockTime;
    p4.u := x;

    fTahoBuff.push_back(p4);
  end;
  if sender = fspm then
  begin
    // пересчитываем полосу по текущему значению тахо
    res := TDoubleArray(fspm.m_rms.p)[0];
    // количество отсчетов в спектре по которым усредняем
    startind := round(x * fband.x / fspm.spmdX);
    endind := round(x * fband.y / fspm.spmdX);
    if endind >= AlignBlockLength(fspm.m_rms) then
      endind := AlignBlockLength(fspm.m_rms) - 1;
    ind := 0;
    for i := startind to endind do
    begin
      if TDoubleArray(fspm.m_rms.p)[i] > res then
      begin
        c := tCmxArray_d(fspm.cmplx_resArray.p)[i];
        res := TDoubleArray(fspm.m_rms.p)[i];
        ind := i;
      end;
    end;
    sp.len := 1;
    sp.ind := ind;
    sp.t := fspm.LastBlockTime;
    startind1 := ind - sp.len;
    endind1 := ind + sp.len;
    if startind1 < startind then
      startind1 := startind;
    if endind1 > endind then
      endind1 := endind;
    if endind1>startind1 + 1 then
    begin
      setlength(sp.spm, endind1 - startind1 + 1);
      for i := startind1 to endind1 do
      begin
        c := tCmxArray_d(fspm.cmplx_resArray.p)[i];
        sp.spm[i - startind1].x := c.re;
        sp.spm[i - startind1].y := c.im;
      end;
      fSpmBuff.push_back(sp);
    end
    else
    begin
      //showmessage('error');
    end;
  end;
end;

function Cmplx_mult_sopr_p2d(c1,c2:point2d):point2d;
begin
  result.x := c1.x * c2.x + c1.y * c2.y;
  result.y := c1.y * c2.x - c1.x*c2.y;
  //mag := sqrt(TComplex1Darray(res.p)[i].y * TComplex1Darray(res.p)[i].y + TComplex1Darray(res.p)[i].x * TComplex1Darray(res.p)[i].x);
  //timer.Free;
  //phase := arctan(TComplex1Darray(res.p)[maxind].y / TComplex1Darray(res.p)[maxind].x) * c_radtodeg;
end;

function Cmplx_mult_sopr_cmx(c1,c2:TComplex_d):point2d;
begin
  result.x := c1.re * c2.re + c1.im * c2.im;
  result.y := c1.im * c2.re - c1.re*c2.im;
  //mag := sqrt(TComplex1Darray(res.p)[i].y * TComplex1Darray(res.p)[i].y + TComplex1Darray(res.p)[i].x * TComplex1Darray(res.p)[i].x);
  //timer.Free;
  //phase := arctan(TComplex1Darray(res.p)[maxind].y / TComplex1Darray(res.p)[maxind].x) * c_radtodeg;
end;


procedure cIRAlg.doEndEvalBlock(sender: tobject);
var
  i, j, k,maxind, dropspm, droptaho: integer;

  temp, a1a2, a1, a2, alfa1, halfstepspm, halfstepTaho: double;

  c1, c2: TComplex_d;
  res,p2, maxp2: point2d;
  spm3: spmPoint;
  taho4: point4d;
  str: string;
begin
  if fTahoBuff.SIZE = 0 then
    exit;
  if fSpmBuff.SIZE = 0 then
    exit;

  halfstepspm := fSpmdx / 2;
  halfstepTaho := fTaxodx / 2;
  temp := 0;
  str := '';
  for i := 0 to fSpmBuff.SIZE - 1 do
  begin
    spm3 := fSpmBuff.peak(i);
    for j := 0 to fTahoBuff.SIZE - 1 do
    begin
      taho4 := point4d(fTahoBuff.peak(i));
      if (spm3.t - taho4.z) < halfstepspm then
      begin
        str := str + 'spm_t=' + formatstrNoE(spm3.t, 4)
          + ' Taho_t=' + formatstrNoE(taho4.z, 4) + '; ';
        maxp2:=p2d(0,0);
        temp:=0;
        for k := 0 to length(spm3.spm)-1 do
        begin
          dropspm := i;
          droptaho := j;
          p2 := spm3.spm[k];
          c1.re := p2.x;
          c1.im := p2.y;
          c2.re := taho4.x;
          c2.im := taho4.y;
          res:=Cmplx_mult_sopr_cmx(c1,c2);
          a1a2:=sqrt(sqr(res.x)+sqr(res.y));
          alfa1:=arctan(res.y / res.x) * c_radtodeg;
          str := str + 'A=' + formatstrNoE(a1a2, 4)+ ' Phase=' + formatstrNoE(alfa1, 4) + '; ';
          a1 := abs(c1);
          a2 := abs(c2);
          str := str + 'spm_ri=' + formatstrNoE(c1.re, 4) + ';' + formatstrNoE
            (c1.im, 4);
          str := str + 'taho_ri=' + formatstrNoE(c2.re, 4) + ';' + formatstrNoE
            (c2.im, 4);

          alfa1 := phase_rad(c1.re, c1.im, c2.re, c2.im);
          str := str + 'alfa=' + formatstrNoE(alfa1, 4)
            + '; spm_A=' + formatstrNoE(a1, 4) + '; taho_A=' + formatstrNoE
            (a2, 4);
          a1a2 := a1 * a2;
          str := str + 'A1A2=' + formatstrNoE(a1a2, 4);
          if a1a2 > temp then
          begin
            temp:=a1a2;
            p2.x := a1 * cos(alfa1);
            p2.y := a1 * sin(alfa1);
            maxp2:=p2;
            str := str + 'k=' + inttostr(k) + 'p2=' + formatstrNoE(p2.x, 4)
              + ';' + formatstrNoE(p2.y, 4);
            maxind:=k;
            fOut.push_back(p2);
          end;
          logMessage(str);
        end;
        fnewData := true;
        fOut.push_back(maxp2);
        break;
      end;
    end;
  end;
  fSpmBuff.drop_front(dropspm);
  fTahoBuff.drop_front(droptaho);
end;

procedure cIRAlg.resetdata;
begin
  fSpmBuff.clear;
  fTahoBuff.clear;
  // счет внутри fOut
  pCount := 0;
end;

class function cIRAlg.getdsc: string;
begin
  result := 'Комплексный спектр';
end;

function cIRAlg.GetProperties: string;
begin
  result := 'cIRAlgProps';
end;

function cIRAlg.newData: boolean;
begin
  result := fnewData;
  fnewData := false;
end;

function cIRAlg.ready: boolean;
begin
  // алгоритм вспомогательный, поэтому не требует вызовов
  result := false;
end;

procedure cIRAlg.SetProperties(str: string);
begin
  inherited;
end;

procedure cIRAlg.UpdateChannels(spm, taho: string);
begin
  fspm := cspm(g_algmng.getSpmByTagName(spm));
  ftaho := cspm(g_algmng.getSpmByTagName(taho));
  UpdateChannels(fspm, ftaho);
end;

procedure cIRAlg.UpdateChannels(spm, taho: cspm);
var
  i, j: integer;
begin
  if (fspm <> nil) and (fspm <> spm) then
    unsubscribe(fspm);
  fspm := spm;
  if (ftaho <> nil) and (ftaho <> taho) then
    unsubscribe(ftaho);
  ftaho := taho;

  if ftaho <> nil then
  begin
    ftaho.subscribe(self);
    fTaxodx := ftaho.dX;
  end;
  if fspm <> nil then
  begin
    fspm.subscribe(self);
    fSpmdx := fspm.dX;
  end;
  i := round(fBuffLength / fSpmdx);
  j := round(fBuffLength / fTaxodx);
  if i < j then
    i := j;
end;

end.
