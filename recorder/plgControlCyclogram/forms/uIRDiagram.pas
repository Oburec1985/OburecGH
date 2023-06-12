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

    // отрисовываемый график
    fOut: cqueue<point2d>;
  public
    t1, taho:ctag;
    // частота тегов t1 и taho
    m_freq,
    // размер блока дл€ расчета спектра = freq*Numpoints
    blSize:double;
    // число точек fft дл€ спектров
    m_Numpoints:integer;
    // блок данных по которому идет расчет.
    m_T1data, m_TahoData: TAlignDarray;
    // спектр re_im
    m_T1ClxData, m_TahoClxData:TAlignDCmpx;
    // fftPlan
    FFTProp:TFFTProp;
  protected
  protected
    procedure compile; virtual;
    procedure DrawData; override;
    procedure setmainParent(p: cbaseObj); override;
    procedure setCount(i: integer); override;
    function getCount: integer; override;
  public
    procedure push(p2: point2d);
    // пересчитать данные из fspm, ftahospm в отрисовываемые вершины
    procedure updateData;
    //
    procedure DoStart;
    Procedure ConfigTag(tag, p_taho: itag); overload;
    // пересчет по частотам опроса и дискретности fft
    procedure UpdateBlocks;
    property DrawLines: boolean read fDrawLines write fDrawLines;
    property DrawPoints: boolean read fDrawPoints write fDrawPoints;
    property PointColor: point3 read fPointColor write fPointColor;
    property Capacity:integer read getcount write setcount;
    constructor create; override;
    destructor destroy;
  end;

  cIRPage = class(cBasePage)
  private
    // хоть раз отрисовалась (границы не нулевые. Ќужно дл€ инициации текстовых меток)
    init: boolean;

    fneedrecompile: boolean;
    // матрица вида оси
    stateM: matrixgl;
    // шаг сетки
    m_gridStep: double;
    // отрисовка сетки
    fGridListId: cardinal;
    // отсутупы в пиксел€х
    m_Tab: integer;
    // размер точек
    fDrawPointSize: double;

    m_MaxXedit, m_MaxYedit: cfloatlabel;
    m_PageLabel: cLabel;

    m_graphList: tlist;
  public
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

    function GetYAxis:point2d;

    function GetXAxis:point2d;
  protected
    property YAxis:point2d read GetYAxis write setYAxis;
    property XAxis:point2d read GetXAxis write SetXAxis;
    // об€зательный признак!!! показывает что в страницу встроены другие компоненты
    function isCarrier: boolean; override;
    // прилинковатьс€ к компоненту в котором будет происходить отрисовка
    procedure linc(p_chart: tcomponent); override;
    procedure setCaption(s: string); override;
    procedure BeforeDrawChild; override;
    procedure setBound(rect: trect); override;
    procedure DrawData; override;

    constructor create; override;
    destructor destroy; override;
  public
    function graphCount:integer;
    function mainParentClassName: string; override;
  end;

  TIRDiagramFrm = class(TRecFrm)
  private

  public
    chart: cchart;
    fpage: cIRPage;

    fGraphName: string;
    fGraphMax: double;
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
    function addGraph(p_name: string): IRDiagramTag;overload;
    function addGraph(g: IRDiagramTag): IRDiagramTag;overload;
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
  c_Name = 'ƒиаграмма Ќайквиста';
  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  // ['{DE3939E6-AF72-47FB-B17B-C741AA578B13}']
  IID_DIAGRAM: TGuid = (D1: $DE3939E6; D2: $AF72; D3: $47FB;
    D4: ($B1, $7B, $C7, $41, $AA, $57, $8B, $13));

implementation

uses uIRDiagramEditFrm;
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
  addplgevent('cIRDiagramFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
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

function TIRDiagramFrm.addGraph(g: IRDiagramTag): IRDiagramTag;
begin
  fpage.m_graphList.Add(g);
  result:=g;
end;

procedure TIRDiagramFrm.ChartInit(sender: tobject);
var
  i: integer;
  g: IRDiagramTag;
  p2: point2d;
begin
  chart.name := 'IRDiagram';
  chart.activeTab.AddChild(fpage);
  chart.activePage.destroy;
  chart.activeTab.Alignpages(1);
  chart.activePage := fpage;
  GraphName := 'ƒиаграмма Ќайквиста';
  createevents;
  if GraphMax <> 0 then
  begin
    // page.Max := GraphMax;
  end;
  PSize := PSize;
  if GraphCount=0 then
    g := addGraph('test_001')
  else
    g:=getGraph(0);
  g.Count:= 10;
  for i := 0 to 9 do
  begin
    p2.x := i;
    p2.y := i * i;
    g.push(p2);
  end;
  //g.ConfigTag('3- 1', '18- 1_taho');
  g.fneedrecompile := true;
end;

procedure TIRDiagramFrm.RBtnClick(sender: tobject);
begin
  if IRDiagrEditFrm <> nil then
  begin
    IRDiagrEditFrm.EditChart(self);
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
  for I := 0 to GraphCount - 1 do
  begin
    gr:=getGraph(i);
    gr.Destroy;
  end;
  fpage.m_graphList.Clear;
end;

constructor TIRDiagramFrm.create(Aowner: tcomponent);
begin
  inherited;
  chart := cchart.create(self);
  chart.align := alClient;
  chart.showTV := false;
  chart.showLegend := false;
  chart.OnInit := ChartInit;
  chart.OnRBtnClick := RBtnClick;
  fpage := cIRPage.create;
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
    g.DoStart;
  end;
end;

procedure TIRDiagramFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, Count: integer;
  lstr, sect: string;
  gr: IRDiagramTag;
begin
  inherited;
  GraphMax := readFloatFromIni(a_pIni, str, 'GridMax');
  PSize := readFloatFromIni(a_pIni, str, 'PSize');
  GraphName := a_pIni.ReadString(str, 'ComponentName', '√истограмма биений');
  Count := a_pIni.ReadInteger(str, 'GraphCount', 1);
  clearGraphList;
  for i := 0 to Count - 1 do
  begin
    sect:='GraphName_' + inttostr(i);
    gr := addGraph( a_pIni.readString(str, sect+'_Name', ''));
    LoadexTagIni(a_pIni,gr.t1, str, sect+'_Tag');
    LoadexTagIni(a_pIni,gr.taho,str, sect+'_Taho');
    gr.DrawPoints:=a_pIni.readBool(str, sect+'_DrawP', true);
  end;
end;

procedure TIRDiagramFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  gr: IRDiagramTag;
  ax: taxis;
  sect,ident:string;
begin
  inherited;
  a_pIni.WriteFloat(str, 'GridMax', GraphMax);
  a_pIni.WriteFloat(str, 'PSize', PSize);
  a_pIni.WriteInteger(str, 'GraphCount', fpage.graphCount);
  a_pIni.WriteString(str, 'ComponentName', GraphName);
  for i := 0 to fpage.graphCount - 1 do
  begin
    gr := getGraph(i);
    sect:='GraphName_' + inttostr(i);
    saveTagToIni(a_pIni,gr.t1,str,sect+'_Tag');
    saveTagToIni(a_pIni,gr.t1,str,sect+'_Taho');
    a_pIni.WriteString(str, sect+'_Name', gr.name);
    a_pIni.WriteBool(str, sect+'_DrawP', gr.DrawPoints);
  end;
end;

procedure TIRDiagramFrm.updateData;
var
  i: integer;
  g: IRDiagramTag;
begin
 for i := 0 to GraphCount - 1 do
  begin
    g := getGraph(i);
    g.updateData;
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
  result:=cIRPage(fpage).fDrawPointSize;;
end;

procedure TIRDiagramFrm.setPSize(v: double);
begin
  // if page<>nil then
  // begin
  // page.psize:=v;
  // end;
end;

function TIRDiagramFrm.GraphCount: integer;
begin
  if fpage=nil then
    result:=0
  else
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
        p2 := fOut.peak(i);
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
        p2 := fOut.peak(i);
        lp.x := p2.x;
        lp.y := p2.y;
        glVertex2fv(@lp);
      end;
      glEnd;
    end;
    glEndList;
  end;
end;


procedure IRDiagramTag.ConfigTag(tag, p_taho: itag);
begin
  t1.tag:=tag;
  taho.tag:=p_taho;
  m_freq:=t1.freq;
  UpdateBlocks;
end;

constructor IRDiagramTag.create;
begin
  inherited;
  t1:=cTag.create;
  taho:=cTag.create;
  fOut := cqueue<point2d>.create;

  DrawPoints := true;
  fPointColor := red;
  DrawLines := true;
  fcolor := blue;
end;

destructor IRDiagramTag.destroy;
begin
  t1.destroy;
  taho.destroy;
  fOut.Destroy;
end;

procedure IRDiagramTag.DoStart;
begin
  taho.initTag;
  t1.initTag;

  taho.doOnStart;
  t1.doOnStart;
  fOut.clear;
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

procedure IRDiagramTag.push(p2: point2d);
begin
  fOut.push_back(p2);
end;

procedure IRDiagramTag.setCount(i: integer);
begin
  inherited;
  fOut.capacity:=i;
end;

function IRDiagramTag.getCount: integer;
begin
 result := fOut.size;
end;

procedure IRDiagramTag.setmainParent(p: cbaseObj);
begin
  inherited;

end;

procedure IRDiagramTag.UpdateBlocks;
var
  refresh:double;
begin
  refresh:=GetREFRESHPERIOD;
  m_Numpoints:=NearestOrd2(m_freq*refresh);
  blSize:= m_Numpoints / m_freq;
  // fOutSize := m_fftCount * m_blockcount;
  GetMemAlignedArray_d(m_Numpoints, m_T1data);
  GetMemAlignedArray_d(m_Numpoints, m_Tahodata);
  GetMemAlignedArray_cmpx_d(m_Numpoints, m_T1ClxData);
  GetMemAlignedArray_cmpx_d(m_Numpoints, m_TahoClxData);
  FFTProp:=GetFFTPlan(m_Numpoints);
  FFTProp.StartInd:=0;
end;

procedure IRDiagramTag.updateData;
var
  i, lastInd, maxind: integer;
  interval1,interval2, common:point2d;
  common_i1, common_i2:tpoint;
  resMag, mag,k:double;
  newdata:boolean;
  cmplx, c1,c2, res:TComplex_d;
  p2:point2d;
begin
  newdata:=false;
  if t1.UpdateTagData(true, lastInd) then
  begin
    interval1:=t1.getPortionTime;
  end;
  if taho.UpdateTagData(true, lastind) then
  begin
    interval2:=taho.getPortionTime;
  end;
  common:=getCommonInterval(interval1,interval2);
  resMag:=0;
  if (common.y-common.x)>blSize then
  begin
    newdata:=true;
    common_i1:=t1.getIntervalInd(common);
    common_i2:=taho.getIntervalInd(common);
    while (common_i1.x>common_i1.x) and (common_i2.y>common_i2.y) do
    begin
      move(t1.m_ReadData[common_i1.X], m_T1data.p^, m_Numpoints*sizeof(double));
      move(taho.m_ReadData[common_i2.X], m_Tahodata.p^, m_Numpoints*sizeof(double));
      fft_al_d_sse(TDoubleArray(m_T1data.p), tCmxArray_d(m_T1ClxData.p), FFTProp);
      fft_al_d_sse(TDoubleArray(m_Tahodata.p), tCmxArray_d(m_TahoClxData.p), FFTProp);
      // расчет первого спектра
      k := 2 / m_Numpoints;
      maxind := 0;
      resMag := 0;
      k := k * k; // т.к. перемножаем 2 числа которые нужно нормировать с одинаковым "K"
      // timer:=TPerformanceTime.create;
      for i := 1 to m_Numpoints - 1 do
      begin
        // дл€ совпадени€ с WinPos k*s1[i].x, где k=(2/fftcount) (ниже блок совпадает с WinPos)
        // res[i].x := k*s1[i].x * k*s2[i].x + k*s1[i].y * k*s2[i].y;
        // res[i].y := k*s1[i].y * k*s2[i].x - k*s1[i].x * k*s2[i].y;
        // комплексно сопр€жонное умножение!!!!
        c1:=tCmxArray_d(m_T1ClxData.p)[i];
        c2:=tCmxArray_d(m_TahoClxData.p)[i];
        cmplx.re := k *(c1.Re * c2.re + c1.im * c2.im);
        cmplx.im := k *(c1.im * c2.re - c1.re * c2.im);

        mag := abs(cmplx);
        if mag > resMag then
        begin
          resMag := mag;
          maxind := i;
          res:=cmplx;
        end;
      end;
      p2.x:=res.Re;
      p2.y:=res.im;
      fOut.push_back(p2);
      common_i1.x:=common_i1.x+m_Numpoints;
      common_i2.x:=common_i2.x+m_Numpoints;
    end;
    if newData then
    begin
      fneedrecompile := true;
    end;
  end;
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

// ќбновить оси при вводе текста в TEdit
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
  // отрисовка рамки пол€ вывода самого графика
  DrawGraphBorder;
  // установка матрицы вида дл€ отрисовки внутри пол€в ывода
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

function cIRPage.GetXAxis: point2d;
begin
  Result:=fXAxis;
end;

function cIRPage.GetYAxis: point2d;
begin
  Result:=fYAxis;
end;

function cIRPage.graphCount: integer;
begin
  result:=m_graphList.Count;
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

  // расстановка меток по ос€м
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

    m_PageLabel.Text := 'ƒиаграмма Ќайквиста';
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
  // заменена стандартна€ функци€ т.к. в случае изменени€ зума
  // из другого потока glOrtho не работает
  MathFunction.CreateOrthoMatrix(fXAxis.x, fXAxis.y, fYAxis.x, fYAxis.y, -1, 1,
    stateM);
  fneedrecompile := true;
end;

procedure cIRPage.setzoom;
begin
  // ======================ѕодготовка к рисованию=========================
  glMatrixMode(gl_projection);
  glloadmatrixf(@stateM);
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



end.
