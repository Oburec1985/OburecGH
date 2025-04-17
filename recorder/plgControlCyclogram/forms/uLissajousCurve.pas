unit uLissajousCurve;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor, uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uCommonTypes, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  PluginClass,
  ImgList,
  uChart,
  usetlist,
  tags,
  uBuffTrend2d,
  MathFunction,
  ulissajousCurveEdit,
  uHardwareMath,
  uQueue;


type
  TAxis = record
    name: string;
    xmin, xmax ,ymin, ymax: double;
  end;

  PAxis = ^TAxis;


  TLisSig = class
  public
    owner:TRecFrm;
    m_tx, m_ty:cTag;
    // лини€ фигуры
    m_trend:cBuffTrend2d;
    // центр масс
    m_centerData:cQueue<point2d>;
    m_center:cBuffTrend2d;
    // главный диаметр
    m_Diam:cBuffTrend2d;

    // накопленный интервал по всем блокам
    m_intervalX, m_intervalY, m_comInterval:point2d;
    // обновл€етс€ в UpdateData
    m_updateDrawInterval:boolean;
  Protected
    // найти теги если они не были проинициализированы
    procedure updateTags;
    // вызываетс€ в updatedata IFrm. ќбновл€ет блоки данных и интервал
    function updateData:boolean;
    // перенести данные в линию
    procedure updateLine;
  public
    procedure updatetrend;
    function name:string;
    procedure doStart();
    constructor create(p_owner:TRecFrm);
    // удал€етс€ сигнал из списка владельца автоматически
    destructor destroy;
  end;

  TLissajousFrm = class(TRecFrm)
  private
    // интервал времени
    m_Interval: point2d;
  public
    // настройка оси
    m_axis:taxis;
    // длина отображаемого участка
    m_timeLen:double;
  public
    m_p:cpage;
    m_ax:cAxis;
    m_Chart: cchart;
    // список сигналов в осциллограмме
    m_signals: tlist;
  protected
    procedure UpdateView;
    procedure ChartRBtnClick(Sender: tobject);
    procedure DblClick(Sender: tobject);
    procedure ChartInit(Sender: tobject);
    // вызываетс€ фабрикой в updatedata;
    procedure UpdateData;override;
    procedure doStart;override;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    function sCount: integer;
    function createsignal:TLisSig;
    function GetSignal(i: integer): TLisSig; overload;
    function GetSignal(name: string): TLisSig; overload;
    function GetPAxCfg: PAxis;
    // удалить сигнал из списка
    procedure Removesig(s:TLisSig);
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  ILissajousFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  TLissajousFact = class(cRecBasicFactory)
  public
    eList: ceventlist;
    initevents: boolean;
  private
    factivechart: TLissajousFrm;
    m_counter: integer;
  private
  protected
    procedure doUpdateData;override;
    procedure doDestroyForms; override;
    procedure CreateEvents;
    procedure DestroyEvents;
    procedure doChangeCfg(Sender: tobject);
    procedure doChangeAlgProps(Sender: tobject);
    procedure doRecorderInit;override;
  public
    procedure doAfterLoad; override;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

const
  E_CURSMOVE = $00000001;

  c_Pic = 'Lissajous';
  c_Name = '‘игуры Ћиссажу';
  c_defXSize = 400;
  c_defYSize = 400;

  // ['{BBE60C79-CE1A-45BA-8556-7AC11FEF16AA}']
  IID_OSCIL: TGuid = (D1: $BBE60C79; D2: $CE1A; D3: $45BA;
    D4: ($85, $56, $7A, $C1, $1F, $EF, $16, $AA));

var
  g_LissajousFactory: TLissajousFact;

implementation

{$R *.dfm}
procedure TLissajousFrm.ChartRBtnClick(Sender: tobject);
begin
  if g_LisEditFrm <> nil then
  begin
    g_LisEditFrm.updateTagsList;
    g_LisEditFrm.SetEditObj(self);
  end;
end;

procedure TLissajousFrm.DblClick(Sender: tobject);
var
  r: frect;
  p: cpage;
begin
  p := cpage(m_Chart.activePage);
  r.BottomLeft.x:=m_axis.xmin;
  r.BottomLeft.y:=m_axis.ymin;
  r.TopRight.x:=m_axis.xmax;
  r.TopRight.y:=m_axis.ymax;
  p.ZoomfRect(r);
end;



procedure TLissajousFrm.ChartInit(Sender: tobject);
var
  i: integer;
  s:TLisSig;
begin
  m_p := cpage(m_Chart.activePage);
  m_p.Caption := '‘игуры Ћиссажу';
  m_ax := m_p.activeAxis;
  // обновление сигналов по загрузке
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    s.updateTags;
    s.updatetrend;
    s.m_trend.color:=ColorArray[i];
    s.m_center.pointcolor:=Orange;
  end;
end;

constructor TLissajousFrm.create(Aowner: tcomponent);
var
  p: cpage;
begin
  inherited;
  m_signals := tlist.create;
  m_Chart := cchart.create(self);

  m_Chart.Name := 'TLissajousChart';
  m_Chart.Align := alClient;
  m_Chart.showTV := false;
  m_Chart.showLegend := false;
  m_Chart.OnRBtnClick := ChartRBtnClick;
  m_Chart.OnDblClick := DblClick;
  m_Chart.OnInit := ChartInit;

  p := cpage(m_Chart.activePage);
  //p.Events.AddEvent('ChartOnCursorMove', e_onResize, setTimeLabelPos);
end;

function TLissajousFrm.createsignal: TLisSig;
begin
  Result:=TLisSig.create(self);
  m_signals.Add(result);
end;

destructor TLissajousFrm.destroy;
var
  i: integer;
begin
  FreeAndNil(m_signals);
  FreeAndNil(m_Chart);
  inherited;
end;

procedure TLissajousFrm.doStart;
var
  s:TLisSig;
  I: Integer;
begin
  for I := 0 to sCount - 1 do
  begin
    s:=GetSignal(i);
    s.doStart;
  end;
end;

function TLissajousFrm.GetSignal(i: integer): TLisSig;
begin
  result:=TLisSig(m_signals.Items[i]);
end;

function TLissajousFrm.GetPAxCfg: PAxis;
var
  i: integer;
  a: PAxis;
begin
  Result := @m_axis;
end;

function TLissajousFrm.GetSignal(name: string): TLisSig;
var
  i: integer;
  s: TLisSig;
begin
  Result := nil;
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    if s.name = name then
    begin
      Result := s;
      exit;
    end;
  end;
end;

function TLissajousFrm.sCount: integer;
begin
  Result:=m_signals.Count;
end;

procedure TLissajousFrm.Removesig(s: TLisSig);
var
  I: Integer;
begin
  for I := 0 to m_signals.Count - 1 do
  begin
    if GetSignal(i)=s then
    begin
      m_signals.Delete(i);
      exit;
    end;
  end;
end;

procedure TLissajousFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  s: TLisSig;
  axCfg: TAxis;
begin
  inherited;
  a_pIni.WriteFloat(str, 'Length', m_timeLen);
  a_pIni.WriteFloat(str, 'XAxMin', m_axis.xmin);
  a_pIni.WriteFloat(str, 'XAxMax', m_axis.xmax);
  a_pIni.WriteFloat(str, 'YAxMin', m_axis.ymin);
  a_pIni.WriteFloat(str, 'YAxMax', m_axis.ymax);
  a_pIni.WriteInteger(str, 'SCount', m_signals.count);
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    saveTagToIni(a_pIni, s.m_tx,str, 'sigX_' + inttostr(i));
    saveTagToIni(a_pIni, s.m_ty,str, 'sigY_' + inttostr(i));
  end;
end;

procedure TLissajousFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i,n: integer;
  s: TLisSig;
  axCfg: TAxis;
begin
  inherited;
  m_timeLen := a_pIni.ReadFloat(str, 'Length', 0.3);
  m_axis.xmin := a_pIni.ReadFloat(str, 'XAxMin', -3);
  m_axis.xmax := a_pIni.ReadFloat(str, 'XAxMax', 3);
  m_axis.ymin := a_pIni.ReadFloat(str, 'YAxMin', -3);
  m_axis.ymax := a_pIni.ReadFloat(str, 'YAxMax', 3);
  n:=a_pIni.ReadInteger(str, 'SCount', 0);
  for i := 0 to n - 1 do
  begin
    s:=createsignal;
    LoadExTagIni(a_pIni, s.m_tx, str, 'sigX_' + inttostr(i));
    LoadExTagIni(a_pIni, s.m_ty, str, 'sigY_' + inttostr(i));
  end;
end;

function TLisSig.updateData:boolean;
var
  interv:point2d;
  l:double;
  b:boolean;
begin
  b:=false;
  result:=false;
  if m_tx.UpdateTagData(false) then
  begin
    // накопленный интервал по всем блокам
    m_intervalX := m_tx.EvalTimeInterval;
    b:=true;
  end;
  if m_ty.UpdateTagData(false) then
  begin
    // накопленный интервал по всем блокам
    m_intervalY := m_ty.EvalTimeInterval;
    b:=true;
  end;
  if b then
  begin
    interv:=getCommonInterval(m_intervalX, m_intervalY);
    // коррекци€ интервала по отображаемой длине
    if TLissajousFrm(owner).m_timeLen>0 then
    begin
      l:=interv.y-interv.x;
      if l>TLissajousFrm(owner).m_timeLen then
        interv.X:=interv.y-TLissajousFrm(owner).m_timeLen;
    end;
    if (m_comInterval.x<>interv.x) or (m_comInterval.y<>interv.y) then
    begin
      m_comInterval:= interv;
      m_updateDrawInterval:=true;
      result:=true;
    end;
  end;
end;

procedure TLissajousFrm.UpdateData;
var
  s: TLisSig;
  i, j: integer;
  // интервал графика который будет нарисован
  interval: point2d;
  v, prev: double;
begin
  if m_signals.count=0 then exit;

  v:=GetRCTime;
  for i := 0 to m_signals.count - 1 do
  begin
    // обновл€ем данные и накопленные интервалы в тегах.  орректируем интервал отображени€
    s:=GetSignal(i);
    s.updateData;
  end;
end;

procedure TLisSig.updateLine;
begin

end;

procedure TLissajousFrm.UpdateView;
var
  i: integer;
  s: TLisSig;
  p:point2d;
  lp:point2;
  intervalx_i, intervaly_i: tpoint;
  j, len: Integer;
  scale:double;
begin
  if RStatePlay then
  begin

  end;
  // перенос данных в линии
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    if s.m_updateDrawInterval then
    begin
      //logMessage('LisFrm_01');
      s.m_tx.RebuildReadBuff(true, s.m_comInterval);
      s.m_ty.RebuildReadBuff(true, s.m_comInterval);
      // предполагаетс€ что частоты одинаковы!!! по X и по Y
      intervalx_i:=s.m_tx.getIntervalInd(s.m_comInterval);
      intervaly_i:=s.m_ty.getIntervalInd(s.m_comInterval);
      if intervalx_i.y>=length(s.m_tx.m_ReadData) then
      begin
        intervalx_i.y:=length(s.m_tx.m_ReadData)-1;
      end;
      len:=intervalx_i.y-intervalx_i.x;
      if len>0 then
      begin
        s.m_trend.Count:=len;
        p.x:=0;
        p.y:=0;
        for j := 0 to len - 1 do
        begin
          s.m_trend.data[j].x:=s.m_tx.m_ReadData[intervalx_i.x+j];
          s.m_trend.data[j].y:=s.m_ty.m_ReadData[intervaly_i.x+j];
        end;
        scale:=1/len;
        p.x:=tempSUM(s.m_tx.m_ReadData,intervalx_i.x,len-1)*scale;
        p.y:=tempSUM(s.m_ty.m_ReadData,intervaly_i.x,len-1)*scale;
        //s.m_trend.AddPoints();
        s.m_centerData.push_back(p);
        if s.m_centerData.size>4 then
        begin
          s.m_centerData.pop_front;
        end;
        s.m_center.Count:=0;
        for j := 0 to s.m_centerData.size - 1 do
        begin
          p:=s.m_centerData.Peak(j);
          lp.x:=p.x;
          lp.y:=p.y;
          s.m_center.addpoint(lp);
        end;
        s.m_trend.NeedRecompile:=true;
        s.m_updateDrawInterval:=false;
      end;
    end;
  end;
  m_Chart.redraw;
  logMessage('LisFrm_03');
end;

procedure TLissajousFrm.WndProc(var Message: TMessage);
begin
  inherited;
end;

{ TOscilFact }

constructor TLissajousFact.create;
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

destructor TLissajousFact.destroy;
begin
  DestroyEvents;
  eList.destroy;
  g_LissajousFactory := nil;
  inherited;
end;

procedure TLissajousFact.CreateEvents;
begin
  if not initevents then
  begin
    initevents := true;
  end;
end;

procedure TLissajousFact.DestroyEvents;
begin
  //if g_algMng <> nil then
  begin

  end;
end;

procedure TLissajousFact.doAfterLoad;
begin
  CreateEvents;
end;

procedure TLissajousFact.doChangeAlgProps(Sender: tobject);
var
  i: integer;
  sChart: TLissajousFrm;
  j: integer;
begin
  for i := 0 to count - 1 do
  begin
    sChart := TLissajousFrm(getfrm(i));
  end;
end;

procedure TLissajousFact.doChangeCfg(Sender: tobject);
var
  i, k: integer;
  p: cpage;
  d: cDoubleCursor;
  ax: cdrawobj;
  a: cbaseobj;
  sChart: TLissajousFrm;
begin
  for i := 0 to count - 1 do
  begin
    sChart := TLissajousFrm(getfrm(i));
  end;
end;

function TLissajousFact.doCreateForm: cRecBasicIFrm;
begin
  Result := nil;
  if m_counter < 1 then
  begin
    Result := ILissajousFrm.create();
  end;
end;

procedure TLissajousFact.doDestroyForms;
begin
  inherited;
end;

procedure TLissajousFact.doRecorderInit;
var
  i: integer;
  frm: TLissajousFrm;
  j: integer;
  s: TLisSig;
  r:fRect;
begin
  for i := 0 to count - 1 do
  begin
    frm := TLissajousFrm(getfrm(i));

    // обновление сигналов по загрузке
    for j := 0 to frm.m_signals.count - 1 do
    begin
      s := frm.GetSignal(j);
      s.updateTags;
      s.updatetrend;
    end;
  end;
end;


procedure TLissajousFact.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure TLissajousFact.doUpdateData;
begin
  inherited;
end;

{ ISpmFrm }
procedure ILissajousFrm.doClose;
begin
  inherited;
  m_lRefCount := 1;
end;

function ILissajousFrm.doCreateFrm: TRecFrm;
begin
  Result := TLissajousFrm.create(nil);
end;

function ILissajousFrm.doGetName: LPCSTR;
begin
  Result := 'OscilFrm';
end;

function ILissajousFrm.doRepaint: boolean;
begin
  TLissajousFrm(m_pMasterWnd).UpdateView;
end;

{ TLisSig }
constructor TLisSig.create(p_owner:TRecFrm);
begin
  owner:=p_owner;
  m_tx:=cTag.create;
  m_ty:=cTag.create;

end;

destructor TLisSig.destroy;
begin
  m_tx.destroy;
  m_ty.destroy;
  if m_centerData<>nil then
    m_centerData.Destroy;
end;

procedure TLisSig.doStart;
begin
  m_updateDrawInterval:=false;
  m_tx.doOnStart;
  m_ty.doOnStart;
end;

function TLisSig.name: string;
begin
  result:=m_ty.tagname;
end;



procedure TLisSig.updateTags;
begin
  m_tx.tagname:=m_tx.tagname;
  m_ty.tagname:=m_ty.tagname;
end;

procedure TLisSig.updatetrend;
begin
  if m_trend=nil then
  begin
    if TLissajousFrm(owner).m_p<>nil then
    begin
      m_trend:=cBuffTrend2d.create;
      m_trend.name:=name;
      TLissajousFrm(owner).m_ax.AddChild(m_trend);
      m_trend.color:=ColorArray[TLissajousFrm(owner).m_ax.ChildCount - 1];
      m_centerData:=cQueue<point2d>.create;
      m_center:=cBuffTrend2d.create;
      m_center.drawpoint:=true;
      m_center.drawLines:=true;
      m_center.pointcolor:=Orange;
      TLissajousFrm(owner).m_ax.AddChild(m_center);
    end;
  end;
end;

end.
