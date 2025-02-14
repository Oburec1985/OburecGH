unit uGrapfForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uEventList, //udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath, uTag,
  uaxis, upage, uBuffTrend1d,
  uRecorderEvents, ubaseObj, uCommonTypes, uRCFunc,
  //uBuffTrend1d,
  tags,
  PluginClass, ImgList, Menus, uChart, uSpin;

type
  cGraphTag = class
    m_t:ctag;
    m_line:cBuffTrend1d;
    m_axisName:string;
  protected
    // если прив€зан тег пересчитываем параметры линии (шаг дискретизации)
    procedure UpdateTag;
  public
    constructor create;
    destructor destroy;

  end;

  TGraphFrm = class(TRecFrm)
    RightGB: TGroupBox;
    cChart1: cChart;
    RightSplitter: TSplitter;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    SignalsLV: TBtnListView;
    XScaleSE: TFloatSpinEdit;
    XScaleLabel: TLabel;
    YScaleSE: TFloatSpinEdit;
    Label1: TLabel;
    Splitter1: TSplitter;
    procedure XScaleSEChange(Sender: TObject);
  public
    cs: TRTLCriticalSection;
    // развертка X
    m_xScale:double;
    // список сигналов
    m_slist:tstringlist;
  protected
    m_updateGraph:boolean;
    // обновл€етс€ на кажд итерации UpdateData
    m_comInterv:point2d;
    // обновл€етс€ в UpdateData
    m_updateDrawInterval:boolean;
  protected
    procedure TestConfig;
    procedure showsignalsinLV;
    function getSignal(i:integer):cGraphTag;
    procedure doStart;override;
    procedure updatedata;override;
    procedure updateView;

    procedure InitCS;
    procedure DeleteCS;
    function  TryEnterCS:boolean;
    procedure EnterCS;
    procedure ExitCS;
  public
    // очистить список сигналов в осциле
    procedure clear;
    // добавить сигнал в осцил
    function addSignal(s: string; ax:string):cGraphTag;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

 IGraphFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cGraphFrmFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
  protected
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doStart;override;
    procedure CreateEvents;
    procedure DestroyEvents;
    // когда Recorder загрузил конфиги;
    procedure doRecorderInit;override;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

const
  // ctrl+shift+G
  //['{E7EA803D-BE61-4A10-A3FB-36CAE2571FD3}']
  IID_GRAPH: TGuid = (D1: $E7EA803D; D2: $BE61; D3: $4A10;
    D4: ($A3, $FB, $36, $CA, $E2, $57, $1F, $D3));

  c_Pic = 'GRAPHPIC';
  c_Name = '“ест графики';
  c_defXSize = 370;
  c_defYSize = 90;


var
  g_GraphFrmFactory: cGraphFrmFactory;
  GraphFrm: TGraphFrm;

implementation

{$R *.dfm}

{ TGraphFrm }

function TGraphFrm.addSignal(s: string; ax:string):cGraphTag;
var
  t:cGraphTag;
  l_ax:caxis;
begin
  t:=cGraphTag.create;
  t.m_axisName:=ax;
  t.m_t.tagname:=s;
  m_slist.AddObject(s, t);
  result:=t;
  l_ax:=cpage(cChart1.activePage).getaxis(ax);
  if l_ax<>nil then
  begin
    t.m_line:=cBuffTrend1d.create;
    t.m_line.color:=ColorArray[m_slist.count];
    l_ax.AddChild(t.m_line);
    if t.m_t.tag<>nil then
    begin
      // обновл€ем dx дл€ линии
      t.UpdateTag;
    end;
  end;
end;

procedure TGraphFrm.clear;
var
  I: Integer;
  t:cGraphTag;
begin
  for I := 0 to m_sList.Count - 1 do
  begin
    t:=cGraphTag(m_sList.Objects[i]);
    t.destroy;
  end;
  m_slist.Clear;
end;

constructor TGraphFrm.create(Aowner: tcomponent);
begin
  inherited;
  m_slist:=TStringList.Create;
  InitCS;
end;

destructor TGraphFrm.destroy;
begin
  DeleteCS;
  inherited;
end;

procedure TGraphFrm.doStart;
var
  i:integer;
  t:cGraphTag;
begin
  m_comInterv.x:=0;
  m_comInterv.y:=0;
  for I := 0 to m_slist.Count - 1 do
  begin
    t:=getSignal(i);
    t.m_t.doOnStart;
  end;
end;

procedure TGraphFrm.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure TGraphFrm.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;

procedure TGraphFrm.EnterCS;
begin
  EnterCriticalSection(cs);
end;

procedure TGraphFrm.ExitCS;
begin
  LeaveCriticalSection(cs);
end;



function TGraphFrm.getSignal(i: integer): cGraphTag;
begin
  result:=cGraphTag(m_slist.Objects[i]);
end;


procedure TGraphFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TGraphFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

function fgetcolor(li: tlistitem): integer;
begin
  result := rgbtoint(cGraphTag(li.Data).m_line.color);
end;

procedure TGraphFrm.showsignalsinLV;
var
  I: Integer;
  s:cGraphTag;
  li:tlistitem;
begin
  SignalsLV.Clear;
  //SignalsLV.clearcolors;
  for I := 0 to m_slist.Count - 1 do
  begin
    s:=getSignal(i);
    li:=SignalsLV.Items.Add;
    li.data:=s;
    SignalsLV.SetSubItemByColumnName('є',inttostr(i),li);
    SignalsLV.SetSubItemByColumnName('»м€',s.m_t.tagname,li);
    //SignalsLV.addColorItem(i,rgbtoint(s.m_line.color));
  end;
  LVchange(SignalsLV);
end;

procedure TGraphFrm.TestConfig;
var
  a0, a:caxis;
  s:cGraphTag;
begin
  a:=cAxis.create;
  cpage(cChart1.activePage).addaxis(a);
  a0:=cpage(cChart1.activePage).activeAxis;

  s:=addSignal('GenSignal_001', a0.name);
  s:=addSignal('GenSignal_0002', a.name);

  m_xScale:=0.3;
  showsignalsinLV;
end;

function TGraphFrm.TryEnterCS: boolean;
begin

end;

procedure TGraphFrm.updatedata;
var
  s: cGraphTag;
  i, j: integer;
  // интервал графика который будет нарисован
  interval: point2d;
  v, prev: double;
begin
  if m_slist.count=0 then exit;

  v:=GetRCTime;
  for i := 0 to m_slist.count - 1 do
  begin
    // обновл€ем данные и накопленные интервалы в тегах.  орректируем интервал отображени€
    s:=GetSignal(i);
    if s.m_t.UpdateTagData(false) then
    begin
      // накопленный интервал по всем блокам
      interval := s.m_t.EvalTimeInterval;
      if interval.y>m_comInterv.y then
      begin
        m_comInterv:=interval;
      end;
      m_updateDrawInterval:=true;
    end;
    // защита m_xScale
    entercs;
    // подрезаем интервал по длине кадра
    if (m_comInterv.y-m_xScale)>m_comInterv.x then
      m_comInterv.x:=m_comInterv.y-m_xScale;
    exitcs;
  end;
end;

procedure TGraphFrm.updateView;
var
  i: integer;
  s: cGraphTag;
  interval_i: tpoint;
  j, len: Integer;
  r:frect;
begin
  if RStatePlay then
  begin

  end;
  if m_updateGraph then
  begin
    r.TopRight.y:=cpage(cChart1.activePage).activeAxis.maxY;
    r.BottomLeft.y:=cpage(cChart1.activePage).activeAxis.minY;
    r.TopRight.x:=m_xScale;
    r.BottomLeft.x:=0;
    cpage(cChart1.activePage).ZoomfRect(r);
    m_updateGraph:=false;
    cChart1.redraw;
  end;

  if m_updateDrawInterval then
  begin
    // перенос данных в линии
    for i := 0 to m_slist.count - 1 do
    begin
      s := GetSignal(i);
      s.m_t.RebuildReadBuff(true,m_comInterv);
      // предполагаетс€ что частоты одинаковы!!! по X и по Y
      interval_i:=s.m_t.getIntervalInd(m_comInterv);
      if interval_i.y>=length(s.m_t.m_ReadData) then
      begin
        interval_i.y:=length(s.m_t.m_ReadData)-1;
      end;
      if interval_i.y - interval_i.x>0 then
      begin
        s.m_line.AddPoints(s.m_t.m_ReadData, interval_i.x,(interval_i.y - interval_i.x));
      end;
    end;
    m_updateDrawInterval:=false;
  end;
  cChart1.redraw;
end;

procedure TGraphFrm.XScaleSEChange(Sender: TObject);
var
  r:frect;
begin
  EnterCS;
  m_updateGraph:=true;
  m_xScale:=XScaleSE.Value;
  if m_comInterv.y-m_xScale>m_comInterv.x then
    m_comInterv.x:=m_comInterv.y-m_xScale;
  exitcs;
  if not RStatePlay then
    updateView;
end;

{ IGraphFrm }

procedure IGraphFrm.doClose;
begin
  inherited;
end;

function IGraphFrm.doCreateFrm: TRecFrm;
begin
  result := TGraphFrm.create(nil);
end;

function IGraphFrm.doGetName: LPCSTR;
begin

end;

function IGraphFrm.doRepaint: boolean;
begin
  TGraphFrm(m_pMasterWnd).updateView;
end;

{ cGraphFrmFactory }

constructor cGraphFrmFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_GRAPH;
end;

procedure cGraphFrmFactory.CreateEvents;
begin

end;

destructor cGraphFrmFactory.destroy;
begin

  inherited;
end;

procedure cGraphFrmFactory.DestroyEvents;
begin

end;

procedure cGraphFrmFactory.doChangeRState(Sender: TObject);
begin

end;

function cGraphFrmFactory.doCreateForm: cRecBasicIFrm;
begin
  result := IGraphFrm.create();
end;

procedure cGraphFrmFactory.doRecorderInit;
var
  i, j: integer;
  Frm: TRecFrm;
  r:frect;
begin
  //exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TGraphFrm(frm).SignalsLV.DrawColorBox:=true;
    TGraphFrm(frm).SignalsLV.getcolor:=fgetcolor;
    TGraphFrm(frm).m_xScale:=0.3;
    r.BottomLeft.x:=0;
    r.BottomLeft.y:=0;
    r.TopRight.x:=0.3;
    r.TopRight.y:=10;
    cpage(TGraphFrm(frm).cChart1.activePage).ZoomfRect(r);
    TGraphFrm(frm).TestConfig;
  end;
end;

procedure cGraphFrmFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure cGraphFrmFactory.doStart;
begin
  inherited;
end;

procedure cGraphFrmFactory.doUpdateData(Sender: TObject);
begin

end;

{ cGraphTag }
constructor cGraphTag.create;
begin
  m_t:=cTag.create;
end;

destructor cGraphTag.destroy;
begin
  m_t.destroy;
end;

procedure cGraphTag.UpdateTag;
begin
  m_line.dx:=1/m_t.tag.GetFreq;
end;

end.
