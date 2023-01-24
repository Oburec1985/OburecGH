unit uSyncOscillogram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor, uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uCommonTypes, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  PluginClass,
  ImgList,
  uChart,
  uGrmsSrcAlg,
  uPhaseAlg,
  usetlist,
  ufreqband,
  uHardwareMath,
  tags,
  uBaseAlgBands,
  uSyncOscillogramEditFrm,
  uQueue,
  uSpm;

type
  TOscType = (tOscil, tHarmOscil, TtrigOscil);


  TAxis = record
    name:string;
    ymin, ymax:double;
  end;

  PAxis = ^TAxis;

  TOscSignal = class
    t: cTag;
    // ось на которой лежит сигнал
    ax: caxis;
    axname:string;
    // линия
    line:cBuffTrend1d;
  public
    constructor create;
    destructor destroy;
  end;

  TSyncOscFrm = class(TRecFrm)
  public
    // тип осциллографирования
    m_type: TOscType;
    // порог для поиска триггера
    m_Threshold: double;
    // сдвиг фазы
    m_Phase0: double;
    // длительность сигнала осциллограммы
    m_Length: double;
  public
    m_Chart: cchart;
    // триггер/ тахо
    m_TrigTag: cTag;
    // список сигналов в осциллограмме
    m_signals: tlist;
    // настройки осей
    m_ax:cQueue<TAxis>;
  PRIVATE
    m_time:double;
  protected
    procedure UpdateView;
    procedure FormClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ChartRBtnClick(Sender: TObject);
    procedure DblClick(Sender: TObject);
    procedure doCursorMove(sender:tobject);
    procedure ChartInit(Sender: TObject);
    procedure UpdateData;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    Function GetAxCfg(name:string):TAxis;
    procedure UpdateProps;
    function sCount:integer;
    function CreateSignal(a:cAxis; t:itag):TOscSignal;overload;
    function CreateSignal(a:cAxis; tname:string):TOscSignal;overload;
    function GetSignal(i:integer):TOscSignal;overload;
    function GetSignal(name:string):TOscSignal;overload;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IOscilFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  TOscilFact = class(cRecBasicFactory)
  public
    eList: ceventlist;
    initevents: boolean;
  private
    factivechart: TSyncOscFrm;
    m_counter: integer;
  private
  protected
    procedure doDestroyForms; override;
    procedure CreateEvents;
    procedure DestroyEvents;
    procedure doChangeCfg(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doChangeAlgProps(Sender: TObject);
    procedure doStart;
    procedure SetActiveChart(c: TSyncOscFrm);
    function GetActiveChart: TSyncOscFrm;
  public
    procedure doUpdateData;override;
    procedure doAfterLoad; override;
    procedure doCursorMove(Sender: TObject);
  public
    property actchart: TSyncOscFrm read GetActiveChart write SetActiveChart;
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

  function TOscTypeToInt(t:TOscType):integer;
  function IntToTOscType(i:integer):TOscType;

const
  E_CURSMOVE = $00000001;
  E_SETACTSPMCHART = $00000002;


  c_Pic = 'OSC_FRM';
  c_Name = 'Синхронная осциллограмма';
  c_defXSize = 400;
  c_defYSize = 400;

  IID_OSCIL: TGuid = (D1: $62F38BB6; D2: $F088; D3: $4A0B;
                      D4: ($93, $3A, $C1, $4F, $8F, $A5, $90, $BC));
var
  g_OscFactory: TOscilFact;
  SyncOscFrm: TSyncOscFrm;

implementation

{$R *.dfm}
{ TSyncOscFrm }

function TOscTypeToInt(t:TOscType):integer;
begin
  case t of
    tOscil:Result:=0;
    TtrigOscil:Result:=1;
    tHarmOscil:Result:=2;
  end;
end;

function IntToTOscType(i:integer):TOscType;
begin
  case i of
    0:result:=tOscil;
    1:result:=TtrigOscil;
    2:result:=tHarmOscil;
  end;
end;

procedure TSyncOscFrm.FormClick(Sender: TObject);
begin
  g_OscFactory.actchart := self;
end;

procedure TSyncOscFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  p: cpage;
begin
  if GetKeyState(VK_CONTROL) < 0 then
  begin

  end;
end;

function TSyncOscFrm.GetSignal(name: string): TOscSignal;
var
  I: Integer;
  s:TOscSignal;
begin
  result:=nil;
  for I := 0 to m_signals.Count - 1 do
  begin
    s:=GetSignal(i);
    if s.t.tagname=name then
    begin
      result:=s;
      exit;
    end;
  end;
end;

function TSyncOscFrm.CreateSignal(a:cAxis; t:itag):TOscSignal;
var
  i:integer;
begin
  result:=nil;
  for I := 0 to m_signals.Count - 1 do
  begin
    if TOscSignal(m_signals.Items[i]).t.tag=t then
    begin
      result:=toscsignal(m_signals.Items[i]);
      break;
    end;
  end;
  if result=nil then
  begin
    result:=TOscSignal.create;
    Result.t.tag:=t;
    Result.ax:=a;
    Result.line:=cBuffTrend1d.create;
    Result.ax.AddChild(Result.line);
    m_signals.Add(result);
    Result.line.color := ColorArray[a.ChildCount-1];
  end;
end;

function TSyncOscFrm.CreateSignal(a:cAxis; tname:string):TOscSignal;
begin
  result:=TOscSignal.create;
  Result.t.tagname:=tname;
  Result.ax:=a;
  Result.line:=cBuffTrend1d.create;
  Result.ax.AddChild(Result.line);
  m_signals.Add(result);
end;


function TSyncOscFrm.GetSignal(i: integer): TOscSignal;
begin
  result:=TOscSignal(m_signals.Items[i]);
end;

procedure TSyncOscFrm.ChartRBtnClick(Sender: TObject);
begin
  if g_EditSyncOscFrm <> nil then
  begin
    g_EditSyncOscFrm.updateTagsList;
    g_EditSyncOscFrm.SetEditObj(self);
  end;
end;

procedure TSyncOscFrm.DblClick(Sender: TObject);
var
  r: frect;
  a: caxis;
  p: cpage;
  axCfg:TAxis;
begin
  p := cpage(m_chart.activePage);
  a := p.activeAxis;
  axCfg:=GetAxCfg(a.name);
  r.BottomLeft := p2(0, axCfg.ymin);
  r.TopRight := p2(m_Length, axCfg.ymax);
  p.ZoomfRect(r);
end;

procedure TSyncOscFrm.doCursorMove(sender:tobject);
begin
  //g_SpmFactory.doCursorMove(self);
end;

function TSyncOscFrm.GetAxCfg(name: string): TAxis;
var
  I: Integer;
  a:TAxis;
begin
  result.name:='';
  for I := 0 to m_ax.size - 1 do
  begin
    a:=m_ax.GetByInd(i);
    if a.name=name then
    begin
      result:=a;
      exit;
    end;
  end;
end;

procedure TSyncOscFrm.ChartInit(Sender: TObject);
var
  i: integer;
  p: cpage;
  d: cDoubleCursor;
  ax:cdrawobj;
begin
  p := cpage(m_Chart.activePage);
  if p=nil then exit;

  p.Caption:='Синхронная осциллограмма';
  // для рисования после текстовых меток полос
  ax:=cdrawobj(p.getChild('Axises'));
  ax.layer:=1;
  //p.SetView(p2(0,1),p2(0,1));
  d := p.cursor;
  d.visible := false;
end;

constructor TSyncOscFrm.create(Aowner: tcomponent);
begin
  inherited;
  m_signals := tlist.create;
  m_Chart := cchart.create(self);

  m_Chart.Name:='TSyncOscChart';
  m_Chart.Align := alClient;
  m_Chart.showTV := false;
  m_Chart.showLegend := false;
  m_Chart.OnClick := FormClick;
  m_Chart.OnRBtnClick := ChartRBtnClick;
  m_Chart.OnDblClick := DblClick;
  m_Chart.OnInit := ChartInit;
  //m_Chart.OnKeyDown := doKeyDown;
  m_Chart.OnCursorMove := doCursorMove;
  m_Length:=1;
  m_type:=tOscil;
  m_TrigTag:=cTag.create;
  m_ax := cqueue<TAxis>.create;
end;

destructor TSyncOscFrm.destroy;
begin
  m_ax.Destroy;
  m_TrigTag.destroy;
  FreeAndNil(m_signals);
  FreeAndNil(m_Chart);
  inherited;
end;

procedure TSyncOscFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i,c: integer;
  s: TOscSignal;
  tname,axname:string;
  t:itag;
  a:caxis;
  axCfg:taxis;
  pAxCfg:PAxis;
  p:cpage;
  j: Integer;
begin
  if m_ax.size>0 then
    m_ax.clear;

  m_Length:=a_pIni.ReadFloat(str, 'Length', 1);
  m_type:=IntToTOscType(a_pIni.ReadInteger(str, 'type_' + inttostr(i), 0));
  c:=a_pIni.ReadInteger(str, 'AxCount', 1);
  for i := 0 to c - 1 do
  begin
    axCfg := m_ax.GetByInd(i);
    axCfg.name:=a_pIni.ReadString(str, 'axCfg_name_' + inttostr(i), '');
    axCfg.ymin:=a_pIni.ReadFloat(str, 'axCfg_y1_' + inttostr(i), 0);
    axCfg.ymax:=a_pIni.ReadFloat(str, 'axCfg_y2_' + inttostr(i), 10);
    m_ax.push_back(axCfg);
  end;
  c:=a_pIni.ReadInteger(str, 'SCount', 0);
  for i := 0 to c - 1 do
  begin
    tname:=a_pIni.ReadString(str, 'sig_' + inttostr(i), '');
    t:=getTagByName(tname);
    axname:=a_pIni.ReadString(str, 'axis_' + inttostr(i), '');
    if m_chart.activePage=nil then
    begin
      m_chart.tabs.activeTab.addPage(true);
    end;
    a:=caxis(cpage(m_chart.activePage).getaxis(axname));
    if a=nil then
    begin
      a:=cpage(m_chart.activePage).Newaxis;
      a.name:=axname;
    end;
    for j := 0 to m_ax.size - 1 do
    begin
      pAxCfg:=PAxis(m_ax.GetPByInd(j));
      if pAxCfg.name=axname then
      begin
        a.minY:=pAxCfg.ymin;
        a.maxY:=pAxCfg.ymax;
      end;
    end;
    if t<>nil then
    begin
      s:=CreateSignal(a, t);
    end
    else
    begin
      s:=CreateSignal(a, tname);
    end;
    if s.line<>nil then
    begin
      s.line.dx:=1/s.t.freq;
    end;
  end;
end;

procedure TSyncOscFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  s: TOscSignal;
  axCfg:TAxis;
begin
  inherited;
  a_pIni.WriteFloat(str, 'Length', m_Length);
  a_pIni.WriteInteger(str, 'type_' + inttostr(i), TOscTypeToInt(m_type));
  a_pIni.WriteInteger(str, 'AxCount', m_ax.size);
  for i := 0 to m_ax.size - 1 do
  begin
    axCfg := m_ax.GetByInd(i);
    a_pIni.WriteString(str, 'axCfg_name_' + inttostr(i), axCfg.name);
    a_pIni.WriteFloat(str, 'axCfg_y1_' + inttostr(i), axCfg.ymin);
    a_pIni.WriteFloat(str, 'axCfg_y2_' + inttostr(i), axCfg.ymax);
  end;
  a_pIni.WriteInteger(str, 'SCount', m_signals.Count);
  for i := 0 to m_signals.Count - 1 do
  begin
    s := GetSignal(i);
    a_pIni.WriteString(str, 'sig_' + inttostr(i), s.t.tagname);
    a_pIni.WriteString(str, 'axis_' + inttostr(i), s.ax.name);
  end;
  if m_TrigTag.tagname<>'' then
  begin
    a_pIni.WriteString(str, 'Trig_' + inttostr(i), m_TrigTag.tagname);
  end;
end;

function TSyncOscFrm.sCount: integer;
begin
  result:=m_signals.count;
end;

procedure TSyncOscFrm.UpdateData;
var
  s:TOscSignal;
  I: Integer;
  t:point2d;
  b:boolean;
begin
  b:=false;
  for I := 0 to m_signals.Count - 1 do
  begin
    s:=GetSignal(i);
    if s.t.UpdateTagData(true) then
    begin
      t:=s.t.getPortionTime;
      if (t.y-t.x)>m_length then
      begin
        if t.x>=m_time then
        begin
          b:=true;
        end
        else
          b:=false;
      end
      else
      begin
        b:=false;
      end;
      if not b then
        break;
    end;
  end;
  if b then
  begin
    m_time:=m_time+m_length;
    for I := 0 to m_signals.Count - 1 do
    begin
      s:=GetSignal(i);
      s.line.AddPoints(s.t.m_ReadData);
      s.t.ResetTagDataTimeInd(s.t.getIndex(m_time));
    end;
  end;
end;

procedure TSyncOscFrm.UpdateProps;
var
  p:cpage;
  a:caxis;
  axCfg:TAxis;
  r: frect;
begin
  p:=cpage(m_chart.activePage);
  a:=p.activeAxis;
  axCfg:=GetAxCfg(a.name);
  r.BottomLeft := p2(0, m_Length);
  r.TopRight := p2(aXCfg.ymin, aXCfg.ymax);
  p.ZoomfRect(r);
end;

procedure TSyncOscFrm.UpdateView;
var
  i: integer;
begin
  if RStatePlay then
  begin
    //m_time:=
  end;
  m_Chart.redraw;
end;

procedure TSyncOscFrm.WndProc(var Message: TMessage);
begin
  inherited;
end;

{ TOscilFact }

constructor TOscilFact.create;
begin
  initevents := false;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_OSCIL;
  eList := ceventlist.create(self, true);
  CreateEvents;
end;

destructor TOscilFact.destroy;
begin
  DestroyEvents;
  eList.destroy;
  g_OscFactory:=nil;
  inherited;
end;

procedure TOscilFact.CreateEvents;
begin
  if not initevents then
  begin
    if g_algMng<>nil then
    begin
      initevents:=true;
      addplgevent('OscFact_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
      //g_algMng.Events.AddEvent('OscFact_SpmSetProps',e_OnSetAlgProperties,doChangeAlgProps);
      //g_algMng.Events.AddEvent('OscFact_OnLeaveCfg', E_OnChangeAlgCfg, doChangeCfg);
    end;
  end;
end;

procedure TOscilFact.DestroyEvents;
begin
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
  if g_algMng<>nil then
  begin

  end;
end;

procedure TOscilFact.doAfterLoad;
begin
  CreateEvents;
end;

procedure TOscilFact.doChangeAlgProps(Sender: TObject);
var
  I: Integer;
  sChart:TSyncOscFrm;
  j: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    sChart:=TSyncOscFrm(getfrm(i));
  end;
end;

procedure TOscilFact.doChangeCfg(Sender: TObject);
var
  i, k: integer;
  p: cpage;
  d: cDoubleCursor;
  ax:cdrawobj;
  a:cbaseobj;
  sChart:TSyncOscFrm;
begin
  for I := 0 to Count - 1 do
  begin
    sChart:=TSyncOscFrm(getfrm(i));
  end;
end;

procedure TOscilFact.doChangeRState(Sender: TObject);
begin
  exit;
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

function TOscilFact.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := IOscilFrm.create();
  end;
end;

procedure TOscilFact.doCursorMove(Sender: TObject);
begin

end;

procedure TOscilFact.doDestroyForms;
begin
  inherited;
end;

procedure TOscilFact.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure TOscilFact.doStart;
var
  I: Integer;
  frm:TSyncOscFrm;
  j: Integer;
  s:TOscSignal;
begin
  for I := 0 to count - 1 do
  begin
    frm:=TSyncOscFrm(GetFrm(i));
    for j := 0 to frm.m_signals.Count - 1 do
    begin
      s:=frm.GetSignal(j);
      s.t.doOnStart;
    end;
    if frm.m_TrigTag.tag<>nil then
      frm.m_TrigTag.doOnStart;
  end;
end;

procedure TOscilFact.doUpdateData;
var
  s:TOscSignal;
  j:integer;
  frm:TSyncOscFrm;
begin
  for j := 0 to count - 1 do
  begin
    frm:=TSyncOscFrm(GetFrm(j));
    frm.UpdateData;
  end;
end;

function TOscilFact.GetActiveChart: TSyncOscFrm;
begin

end;

procedure TOscilFact.SetActiveChart(c: TSyncOscFrm);
begin

end;

{ ISpmFrm }
procedure IOscilFrm.doClose;
begin
  inherited;
  m_lRefCount := 1;
end;

function IOscilFrm.doCreateFrm: TRecFrm;
begin
  result := TSyncOscFrm.create(nil);
end;

function IOscilFrm.doGetName: LPCSTR;
begin
  result := 'OscilFrm';
end;

function IOscilFrm.doRepaint: boolean;
begin
  TSyncOscFrm(m_pMasterWnd).UpdateView;
end;

{ TOscSignal }
constructor TOscSignal.create;
begin
  t:=cTag.create;
end;

destructor TOscSignal.destroy;
begin
  t.destroy;
  t:=nil;
end;

end.
