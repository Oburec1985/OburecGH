unit uGrapfForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uEventList, //udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath, //uTag,
  uaxis, upage, uBuffTrend1d, uQueue,
  uRecorderEvents, ubaseObj, uCommonTypes, uRCFunc,
  //uBuffTrend1d,
  tags,
  uEditGraphFrm,
  PluginClass, ImgList, Menus, uChart, uSpin, uRcCtrls;

type
  TAxCfg = record
    name:string;
    scale,
    shift:double;
    ax:caxis;
  end;

  cGraphTag = class
    m_owner:tobject;
    m_t:ctag;
    m_line:cBuffTrend1d;
    m_axisName:string;
  protected
    // если прив€зан тег пересчитываем параметры линии (шаг дискретизации)
    procedure UpdateTag;
    function axis:caxis;
  public
    procedure SetAxis(a:caxis);
    function ToStr:string;
    procedure fromstr(s:string);
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
    ShiftSE: TFloatSpinEdit;
    ShiftLabel: TLabel;
    TrigCB: TRcComboBox;
    TrigCbox: TCheckBox;
    TrigFE: TFloatSpinEdit;
    TrigLvlLabel: TLabel;
    procedure XScaleSEChange(Sender: TObject);
    procedure SignalsLVClick(Sender: TObject);
    procedure YScaleSEChange(Sender: TObject);
    procedure ShiftSEChange(Sender: TObject);
    procedure cChart1RBtnClick(Sender: TObject);
    procedure XScaleSEKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure YScaleSEDownClick(Sender: TObject);
    procedure TrigCBChange(Sender: TObject);
    procedure cChart1MouseZoom(Sender: TObject; UpScale: Boolean);
  public
    cs: TRTLCriticalSection;
    // развертка X
    m_xScale:double;
    // список сигналов
    m_slist:tstringlist;

    m_trig:ctag;
    // находимс€ ниже трига
    m_lostate:boolean;
  protected
    // обновилась ось по клику Scale
    f_changeAx:boolean;
    f_ActiveAxisInd:integer;
    // обновилась ось X
    m_updateGraph:boolean;
    // обновл€етс€ на кажд итерации UpdateData
    m_comInterv:point2d;

    // обновл€етс€ в UpdateData
    m_updateDrawInterval:boolean;

    // настройки осей
    fAxCfgCapacity:integer;
    fAxCfgCount:integer;
    m_axCfg:array of TAxCfg;
  protected
    procedure updateYScale;
    // происходит когда все плагины загружены
    procedure OnRecorderInit;
    procedure TestConfig;
    procedure showsignalsinLV;
    function ActiveSignal:cGraphTag;
    // номер оси сигнала
    function axInd(s:cGraphTag):integer;
    procedure doStart;override;
    procedure updatedata;override;
    procedure updateView;
    function SearchTrig(t: cTag; p_threshold: double;
      var p_interval: point2d): boolean;

    procedure InitCS;
    procedure DeleteCS;
    function  TryEnterCS:boolean;
    procedure EnterCS;
    procedure ExitCS;

    function AxCfgToStr(i:integer):string;
    function StrToAxCfg(s:string):TAxCfg;
    procedure setAxCount(c:integer);
  public
    procedure addaxis(a:caxis);
    function getSignal(i:integer):cGraphTag;overload;
    function getSignal(S:string):cGraphTag;overload;
    procedure delSignal(s:cGraphTag);
    // удал€ет только ось. сигналы не трогает
    procedure delaxis(ax:caxis);

    property AxCount:integer read fAxCfgCount write setAxCount;
    // очистить список сигналов в осциле
    procedure clear;
    // добавить сигнал в осцил
    function addSignal(s: string; ax:caxis):cGraphTag;overload;
    function addSignal(s: string; ax:string):cGraphTag;overload;
    function addSignal(s: cGraphTag):cGraphTag;overload;

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

function TGraphFrm.ActiveSignal: cGraphTag;
begin
  if m_slist.Count>0 then
  begin
    if SignalsLV.ItemIndex=-1 then
      result:=getSignal(0)
    else
      result:=cGraphTag(SignalsLV.items[SignalsLV.ItemIndex].Data);
  end
  else
    result:=nil;
end;

function TGraphFrm.addSignal(s: string; ax:caxis):cGraphTag;
var
  t:cGraphTag;
  f:ulong;
  ind:integer;
begin
  t:=cGraphTag.create;
  t.m_owner:=self;
  t.m_axisName:=ax.name;
  t.m_t.tagname:=s;
  m_slist.AddObject(s, t);
  ind:=axInd(t);
  if ind=-1 then
  begin
    addaxis(ax);
  end;
  result:=t;
  if ax<>nil then
  begin
    t.m_line:=cBuffTrend1d.create;
    t.m_line.color:=ColorArray[m_slist.count];
    ax.AddChild(t.m_line);
    if t.m_t.tag<>nil then
    begin
      // обновл€ем dx дл€ линии
      t.UpdateTag;
    end;
    // «адать маску оценок оценок
    f:=t.m_t.tag.GetEstimatorsMask;
    setflag(f, ESTIMATOR_PEAK+ESTIMATOR_RMSD);
    t.m_t.tag.SetEstimatorsMask(f);
  end;
end;

function TGraphFrm.addSignal(s: string; ax:string):cGraphTag;
var
  l_ax:caxis;
begin
  l_ax:=cpage(cChart1.activePage).getaxis(ax);
  result:=addSignal(s, l_ax);
end;

// scale; shift
procedure TGraphFrm.addaxis(a: caxis);
begin
  m_axCfg[AxCount].ax:=a;
  m_axCfg[AxCount].name:=a.name;
  AxCount:=AxCount+1;
end;

function TGraphFrm.addSignal(s: cGraphTag): cGraphTag;
var
  l_ax:caxis;
  f:ulong;
begin
  s.m_owner:=self;
  result:=getSignal(s.m_t.tagname);
  if result=nil then
  begin
    m_slist.AddObject(s.m_t.tagname, s);
    result:=s;
    l_ax:=cpage(cChart1.activePage).getaxis(s.m_axisName);
    if l_ax<>nil then
    begin
      s.m_line:=cBuffTrend1d.create;
      s.m_line.color:=ColorArray[m_slist.count];
      l_ax.AddChild(s.m_line);
      if s.m_t.tag<>nil then
      begin
        // обновл€ем dx дл€ линии
        s.UpdateTag;
      end;
      // «адать маску оценок оценок
      if s.m_t.tag<>nil then
      begin
        f:=s.m_t.tag.GetEstimatorsMask;
        setflag(f, ESTIMATOR_PEAK+ESTIMATOR_RMSD);
        s.m_t.tag.SetEstimatorsMask(f);
      end;
    end;
  end;
end;

function TGraphFrm.AxCfgToStr(i: integer): string;
var
  a:TAxCfg;
begin
  a:=m_axCfg[i];
  result:=floattostr(a.scale)+';'+floattostr(a.shift)+';'+a.name;
end;

function TGraphFrm.StrToAxCfg(s: string):TAxCfg;
var
  s1:string;
  i:integer;
begin
  s1:=getSubStrByIndex(s,';',1,0);
  result.scale:=strtofloat(s1);
  s1:=getSubStrByIndex(s,';',1,1);
  result.shift:=strtofloat(s1);
  s1:=getSubStrByIndex(s,';',1,2);
  result.name:=s1;
end;

function TGraphFrm.axInd(s: cGraphTag): integer;
var
  I: Integer;
  parAx:caxis;
begin
  result:=-1;
  parAx:=s.axis;
  if parax<>nil then
  begin
    for I := 0 to fAxCfgCount - 1 do
    begin
      if m_axCfg[i].ax=s.axis then
      begin
        result:=i;
        exit;
      end;
    end;
  end;
end;

procedure TGraphFrm.cChart1MouseZoom(Sender: TObject; UpScale: Boolean);
var
  p:TNotifyEvent;
  s:cGraphTag;
  i:integer;
begin
  if UpScale then
  BEGIN
    s:=ActiveSignal;
    if s<>nil then
    begin
      shiftse.OnChange:=nil;
      shiftse.Value:=s.m_t.GetMeanEst;
      shiftse.OnChange:=p;
      i:=axInd(s);
      m_axCfg[i].shift:=shiftse.Value;
      p:=YScaleSE.OnChange;
      YScaleSE.OnChange:=nil;
      YScaleSE.Value:=(s.axis.maxY-s.axis.minY)/cpage(cChart1.activePage).gridlinecount_Y;
      YScaleSE.OnChange:=p;
      f_ActiveAxisInd:=i;
      f_changeAx:=true;

    end;
  END;
end;

procedure TGraphFrm.cChart1RBtnClick(Sender: TObject);
begin
  EditGraphFrm.editFrm(self);
  if EditGraphFrm.ShowModal=mrok then
  begin
    showsignalsinLV;
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
  m_trig:=cTag.create;

  m_slist:=TStringList.Create;
  // установка оси поумолчанию
  fAxCfgCapacity:=10;
  setlength(m_axCfg, fAxCfgCapacity);
  fAxCfgCount:=1;

  InitCS;
end;

procedure TGraphFrm.delaxis(ax: caxis);
var
  I, j: Integer;
  s:cGraphTag;
begin
  for I := 0 to axCount - 1 do
  begin
    if m_axCfg[i].ax=ax then
    begin
      dec(fAxCfgCount);
      if fAxCfgCount>0 then
      move(m_axCfg[i+1],m_axCfg[i],fAxCfgCount*sizeof(TAxCfg));
      for j := 0 to m_slist.Count - 1 do
      begin
        s:=getSignal(j);
        if s.axis=ax then
        begin
          s.destroy;
        end;
      end;
      ax.destroy;
      break;
    end;
  end;
end;

procedure TGraphFrm.delSignal(s: cGraphTag);
begin
  s.destroy;
end;

destructor TGraphFrm.destroy;
begin
  m_trig.destroy;

  clear;
  m_slist.Destroy;

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
  m_lostate:=true;
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

function TGraphFrm.getSignal(S: string): cGraphTag;
var
  I: Integer;
  t:cGraphTag;
begin
  result:=nil;
  for I := 0 to m_slist.Count - 1 do
  begin
    t:=getSignal(i);
    if t.m_t.tagname=s then
    begin
      result:=t;
      exit;
    end;
  end;
end;

function TGraphFrm.getSignal(i: integer): cGraphTag;
begin
  result:=cGraphTag(m_slist.Objects[i]);
end;

function fgetcolor(li: tlistitem): integer;
begin
  result := rgbtoint(cGraphTag(li.Data).m_line.color);
end;

procedure TGraphFrm.OnRecorderInit;
var
  r:frect;
  I: Integer;
  s:cGraphTag;
begin
  SignalsLV.DrawColorBox:=true;
  SignalsLV.getcolor:=fgetcolor;
  m_xScale:=0.3;
  XScaleSE.Value:=0.3;
  m_axCfg[0].ax:=cpage(cChart1.activePage).activeAxis;

  r.BottomLeft.x:=0;
  r.BottomLeft.y:=0;
  r.TopRight.x:=0.3;
  r.TopRight.y:=10;
  cpage(cChart1.activePage).ZoomfRect(r);
  // заполнить комбо бокс тегами
  trigcb.updateTagsList(true);
  // инициаци€ тегов
  for I := 0 to m_slist.Count - 1 do
  begin
    s:=getSignal(i);
    s.m_t.doOnStart
  end;
end;

procedure TGraphFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  s: cGraphTag;
  s1:string;
begin
  inherited;
  a_pIni.WriteInteger(str, 'AxCount', AxCount);
  for I := 0 to AxCount - 1 do
  begin
    s1:=AxCfgToStr(i);
    a_pIni.WriteString(str, 'Ax_'+inttostr(i), s1);
  end;
  a_pIni.WriteInteger(str, 'SCount', m_slist.count);
  for I := 0 to m_slist.count - 1 do
  begin
    s:=getSignal(i);
    s1:=s.ToStr;
    a_pIni.WriteString(str, 'Tag_'+inttostr(i), s1);
  end;
  a_pIni.WriteString(str, 'TrigTag', TrigCB.Text);
  a_pIni.WriteBool(str, 'TrigEnabled', TrigCBox.Checked);
  a_pIni.WriteFloat(str, 'TrigLvl', TrigFE.Value);
end;

procedure TGraphFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i,c: integer;
  s: cGraphTag;
  s1:string;
  a:caxis;
begin
  // загрузка осей
  //exit;
  AxCount:= a_pIni.ReadInteger(str, 'AxCount', 0);
  if AxCount=0 then exit;
  for I := 0 to AxCount - 1 do
  begin
    s1:= a_pIni.ReadString(str, 'Ax_'+inttostr(i), '');
    m_axCfg[i]:=StrToAxCfg(s1);
    if i=cpage(cChart1.activePage).axises.ChildCount then
    begin
      a:=cAxis.create;
      a.name:=m_axCfg[i].name;
      cpage(cChart1.activePage).addaxis(a);
      m_axCfg[i].ax:=a;
    end
    else
    begin
      m_axCfg[i].ax:=cpage(cChart1.activePage).getaxis(m_axCfg[i].name);
    end;
  end;
  // загрузка сигналов
  c:= a_pIni.ReadInteger(str, 'SCount', 0);
  for I := 0 to c - 1 do
  begin
    s1:= a_pIni.ReadString(str, 'Tag_'+inttostr(i), s1);
    s:=cGraphTag.create;
    s.m_owner:=self;
    s.fromstr(s1);
    addSignal(s);
  end;
  showsignalsinLV;
  TrigCB.Text:=a_pIni.ReadString(str, 'TrigTag', '');
  TrigCBox.Checked:=a_pIni.ReadBool(str, 'TrigEnabled', false);
  TrigFE.Value:=a_pIni.ReadFloat(str, 'TrigLvl', 1);
end;


procedure TGraphFrm.setAxCount(c:integer);
begin
  fAxCfgCount:=c;
  if c>length(m_axCfg) then
  begin
    fAxCfgCapacity:=fAxCfgCapacity+10;
    setlength(m_axCfg,fAxCfgCapacity);
  end;
end;

procedure TGraphFrm.ShiftSEChange(Sender: TObject);
var
  s:cGraphTag;
  lcount:integer;
  I ,y: Integer;
  p:TNotifyEvent;
  r:fRect;
  a:caxis;
begin
  s := ActiveSignal;
  i:=axInd(s);
  if YScaleSE.Value>0 then
  begin
    if i>-1 then
    begin
      m_axCfg[i].shift:=ShiftSE.Value;
      a:=m_axcfg[i].ax;
      y:=cpage(cChart1.activePage).gridlinecount_Y;
      r.TopRight.y:=0.5*y*m_axCfg[i].scale+m_axCfg[i].shift;
      r.BottomLeft.y:=-0.5*y*m_axCfg[i].scale+m_axCfg[i].shift;
      r.BottomLeft.x:=0;
      r.BottomLeft.x:=m_xScale;
      a.ZoomfRect(r);
      cChart1.redraw;
    end;
  end;
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
    li.Checked:=true;
    li.data:=s;
    SignalsLV.SetSubItemByColumnName('є',inttostr(i),li);
    SignalsLV.SetSubItemByColumnName('»м€',s.m_t.tagname,li);
    //SignalsLV.addColorItem(i,rgbtoint(s.m_line.color));
  end;
  LVchange(SignalsLV);
end;

procedure TGraphFrm.SignalsLVClick(Sender: TObject);
var
  s:cGraphTag;
  lcount:integer;
  I: Integer;
  p:TNotifyEvent;
  li:tlistitem;
  page:cpage;
begin
  s := ActiveSignal;
  page:=cpage(cChart1.activePage);
  page.activeAxis:=s.axis;
  i:=axInd(s);
  if i>-1 then
  begin
    p:=YScaleSE.OnChange;
    YScaleSE.OnChange:=nil;
    YScaleSE.Value:=m_axcfg[i].scale;
    YScaleSE.OnChange:=p;

    p:=YScaleSE.OnChange;
    ShiftSE.OnChange:=nil;
    ShiftSE.Value:=m_axcfg[i].shift;
    ShiftSE.OnChange:=p;
  end;
  for I := 0 to SignalsLV.Items.Count - 1 do
  begin
    li:=SignalsLV.Items[i];
    s:=getSignal(i);
    s.m_line.visible:=li.Checked;
  end;
end;



procedure TGraphFrm.YScaleSEChange(Sender: TObject);
var
  s:cGraphTag;
  i:integer;
begin
  s := ActiveSignal;
  i:=axInd(s);
  if YScaleSE.Value>0 then
  begin
    if i>-1 then
    begin
      m_axCfg[i].scale:=YScaleSE.Value;
      f_changeAx:=true;
      f_ActiveAxisInd:=i;
    end;
  end;
  if not RStatePlay then
    updateView;
end;

procedure TGraphFrm.updateYScale;
var
  lcount:integer;
  I ,y: Integer;
  p:TNotifyEvent;
  r:fRect;
  a:caxis;
begin
  if f_changeAx then
  begin
    //i:=axInd(s);
    i:=f_ActiveAxisInd;
    if YScaleSE.Value>0 then
    begin
      if i>-1 then
      begin
        m_axCfg[i].scale:=YScaleSE.Value;
        f_changeAx:=true;

        y:=cpage(cChart1.activePage).gridlinecount_Y;
        r.TopRight.y:=0.5*y*m_axCfg[i].scale+m_axCfg[i].shift;
        r.BottomLeft.y:=-0.5*y*m_axCfg[i].scale+m_axCfg[i].shift;
        r.BottomLeft.x:=0;
        r.BottomLeft.x:=m_xScale;
        a:=m_axcfg[i].ax;
        a.ZoomfRect(r);
        cChart1.redraw;
        f_changeAx:=false;
      end;
    end;
  end;
end;


procedure TGraphFrm.YScaleSEDownClick(Sender: TObject);
var
  lInc:double;
  p:TNotifyEvent;
begin
  p:=tfloatspinedit(sender).OnChange;
  tfloatspinedit(sender).OnChange:=nil;
  if tfloatspinedit(sender).Value<=0 then
  begin
    tfloatspinedit(sender).Value:=tfloatspinedit(sender).Value+tfloatspinedit(sender).Increment;
    linc:=tfloatspinedit(sender).Increment/10;
    while tfloatspinedit(sender).Value-linc<=0 do
    begin
      linc:=linc/10;
    end;
    tfloatspinedit(sender).OnChange:=p;
    tfloatspinedit(sender).Value:=tfloatspinedit(sender).Value-lInc;
    exit;
  end;
  tfloatspinedit(sender).OnChange:=p;
end;

procedure TGraphFrm.TestConfig;
var
  a0, a:caxis;
  s:cGraphTag;
  I, y: Integer;
  r:frect;
begin
  a:=cAxis.create;
  cpage(cChart1.activePage).addaxis(a);
  a0:=cpage(cChart1.activePage).activeAxis;

  s:=addSignal('GenSignal_001', a0.name);
  s:=addSignal('GenSignal_0002', a.name);

  m_xScale:=0.3;
  showsignalsinLV;

  cpage(cChart1.activePage).gridlinecount_Y:=8;
  XScaleSE.Value:=1;
  fAxCfgCount:=2;
  // ось 1
  m_axCfg[0].ax:=a0;
  m_axCfg[0].name:=a0.name;
  m_axCfg[0].scale:=1;
  m_axCfg[0].shift:=0;
  y:=cpage(cChart1.activePage).gridlinecount_Y;
  r.TopRight.y:=0.5*y*m_axCfg[0].scale+m_axCfg[0].shift;
  r.BottomLeft.y:=-0.5*y*m_axCfg[0].scale+m_axCfg[0].shift;
  r.BottomLeft.x:=0;
  r.BottomLeft.x:=m_xScale;
  a0.ZoomfRect(r);
  // ось 2
  m_axCfg[1].ax:=a;
  m_axCfg[1].name:=a.name;
  m_axCfg[1].scale:=1;
  m_axCfg[1].shift:=0;
  y:=cpage(cChart1.activePage).gridlinecount_Y;
  r.TopRight.y:=0.5*y*m_axCfg[1].scale+m_axCfg[1].shift;
  r.BottomLeft.y:=-0.5*y*m_axCfg[1].scale+m_axCfg[1].shift;
  r.BottomLeft.x:=0;
  r.BottomLeft.x:=m_xScale;
  a.ZoomfRect(r);
end;

procedure TGraphFrm.TrigCBChange(Sender: TObject);
var
  t:itag;
begin
  setComboBoxItem(TrigCB.Text, tcombobox(Sender));
  t:=TrigCB.gettag();
  if t<>nil then
  begin
    m_trig.tag:=t;
  end;
end;

function TGraphFrm.TryEnterCS: boolean;
begin

end;

procedure TGraphFrm.updatedata;
var
  s: cGraphTag;
  trigTag, t:ctag;
  it:itag;
  i, j: integer;
  // интервал графика который будет нарисован
  interval: point2d;
  v, prev: double;
  b:boolean;
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
    //entercs;
    if TrigCbox.Checked and (TrigCB.ItemIndex<>-1) then
    begin
      b:=false;
      if m_trig.UpdateTagData(false) then
      begin
        // данные триггера обновились
        b:=true;
      end;
      SearchTrig(t, TrigFE.Value, interval);
      m_comInterv:=interval;
    end
    else
    begin
      // подрезаем интервал по длине кадра
      if (m_comInterv.y-m_xScale)>m_comInterv.x then
        m_comInterv.x:=m_comInterv.y-m_xScale;
    end;
    //exitcs;
  end;
end;

function TGraphFrm.SearchTrig(t: cTag; p_threshold: double;
  var p_interval: point2d): boolean;
var
  TrigTime, v, prev: double;
  i, imin: integer;
  TrigRes:boolean;
begin
  for i := 1 to t.lastindex - 1 do
  begin
    v := t.m_ReadData[i];
    if m_lostate then
    begin
      // rise
      if v>p_threshold then
      begin
        TrigTime:= t.getReadTime(i);
        TrigRes:= true;
        m_lostate:=false;
        p_interval.x:=TrigTime;
        p_interval.y:=TrigTime+m_xScale;
        break;
      end;
    end
    else
    begin
      if v<p_threshold then
      begin
        m_lostate:=false;
      end;
    end
  end;
  result:=TrigRes;
end;

procedure TGraphFrm.updateView;
var
  i: integer;
  s: cGraphTag;
  interval_i: tpoint;
  j, len: Integer;
  r:frect;
  li:tlistitem;
  v:double;
begin
  if RStatePlay then
  begin
    updateYScale;
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
  // отобразить амплитуды
  for I := 0 to SignalsLV.Items.Count - 1 do
  begin
    li:=SignalsLV.Items[i];
    s:=getSignal(i);
    v:=s.m_t.GetPeakEst;
    SignalsLV.SetSubItemByColumnName('A',formatStrnoe(v,4),li);
    v:=s.m_t.GetRMSEst;
    SignalsLV.SetSubItemByColumnName('Rms',formatStrnoe(v,4),li);
  end;
end;


procedure TGraphFrm.XScaleSEChange(Sender: TObject);
var
  r:frect;
begin
  //EnterCS;
  m_updateGraph:=true;
  m_xScale:=XScaleSE.Value;
  if m_comInterv.y-m_xScale>m_comInterv.x then
    m_comInterv.x:=m_comInterv.y-m_xScale;
  //exitcs;
  if not RStatePlay then
    updateView;
end;



procedure TGraphFrm.XScaleSEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  
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
begin
  //exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TGraphFrm(Frm).OnRecorderInit;
    //TGraphFrm(frm).TestConfig;
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
function cGraphTag.axis: caxis;
begin
  result:=nil;
  if m_line<>nil then
  begin
    result:=caxis(m_line.parent);
  end;
end;

constructor cGraphTag.create;
begin
  m_t:=cTag.create;
end;

destructor cGraphTag.destroy;
var
  I: Integer;
begin
  m_t.destroy;
  if m_line<>nil then
  begin
    m_line.destroy;
  end;
  if m_owner<>nil then
  begin
    for I := 0 to TGraphFrm(m_owner).m_slist.Count - 1 do
    begin
      if TGraphFrm(m_owner).m_slist.Objects[i]=self then
      begin
        TGraphFrm(m_owner).m_slist.Delete(i);
        TGraphFrm(m_owner).SignalsLV.Items.Delete(i);
        break;
      end;
    end;
  end;
end;

procedure cGraphTag.fromstr(s: string);
var
  s1:string;
  i:integer;
begin
  m_t.FromStr(s);
  s1:=getSubStrByIndex(s,';',1,2);
  if isValue(s1) then
  begin
    i:=strtoint(s1);
    m_axisName:=TGraphFrm(m_owner).m_axCfg[i].name;
  end
  else
  begin
    m_axisName:=s1;
  end;
end;

procedure cGraphTag.SetAxis(a: caxis);
var
  ax:caxis;
begin
  if m_line<>nil then
  begin
    //ax:=caxis(m_line.parent);
    m_line.parent:=a;
    m_axisName:=a.name;
  end;
end;

function cGraphTag.ToStr: string;
var
  i:integer;
begin
  //result:=m_t.ToStr+';'+m_axisName;
  i:=TGraphFrm(m_owner).axInd(self);
  result:=m_t.ToStr+';'+inttostr(i);
end;

procedure cGraphTag.UpdateTag;
begin
  m_line.dx:=1/m_t.tag.GetFreq;
end;

end.
