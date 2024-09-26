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
  usetlist,
  ufreqband,
  uHardwareMath,
  tags,
  uSyncOscillogramEditFrm,
  ufloatlabel,
  MathFunction,
  uQueue,
  uSpm;

type
  TOscType = (tOscil, tHarmOscil, TtrigOscil);

  TAxis = record
    name: string;
    ymin, ymax: double;
  end;

  PAxis = ^TAxis;

  TOscSignal = class
  private
  public
    m_owner: tlist;
    t: cTag;
    m_dt: double;
    // обновляется в updatedata
    m_interval,
    // поправка интервала с учетом триггера
    m_drawInterval: point2d;
    m_outdata: array of double;
    // ось на которой лежит сигнал
    ax: caxis;
    axname: string;
    // линия
    line: cBuffTrend1d;
    // размер отображаемых данных
    m_portion:double;
  protected
    procedure saveData(fname: string; num: integer);
    procedure doStart(oscLen: double; Phase0: double; oscType: TOscType);
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
    // сдвиг фазы/ сдвиг относительно триггерного события
    m_Phase0: double;
    // длительность сигнала осциллограммы
    m_Length: double;
    // интервал времени
    m_TrigInterval: point2d;
  public
    m_Chart: cchart;
    // триггер/ тахо
    m_TrigTag: cTag;
    // список сигналов в осциллограмме
    m_signals: tlist;
    // настройки осей
    m_ax: cQueue<TAxis>;
  protected
    m_TahoStart: boolean; // старт поиска периода
    m_iTahoStart: integer; // индекс начала триггера
    m_iTahoStop: integer; // индекс завершения триггера
    m_iTahoN: integer; // Число отсчитанных оборотов

    // момент срабатывания триггера
    m_TrigTime: double;
    m_TrigTimeInd: integer;
    m_TrigRes: boolean;
    m_init: boolean;
    m_TimeLabel: cfloatlabel;
  protected
    procedure setTimeLabelPos(Sender: tobject);
    procedure UpdateView;
    procedure FormClick(Sender: tobject);
    procedure FormKeyDown(Sender: tobject; var Key: Word; Shift: TShiftState);
    procedure ChartRBtnClick(Sender: tobject);
    procedure DblClick(Sender: tobject);
    procedure doCursorMove(Sender: tobject);
    procedure ChartInit(Sender: tobject);
    procedure UpdateData;
    function SearchTrig(t: cTag; p_threshold: double;
      var p_interval: point2d): boolean;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    // NUM - номер осциллограммы
    procedure SaveMera(f: string; num: integer);
    Function GetAxCfg(name: string): TAxis;
    Function GetPAxCfg(name: string): PAxis;
    Function GetAxCfgInd(name: string): integer;
    procedure UpdateProps;
    function sCount: integer;
    function CreateSignal(a: caxis; t: itag): TOscSignal; overload;
    function CreateSignal(a: caxis; tname: string): TOscSignal; overload;
    function GetSignal(i: integer): TOscSignal; overload;
    function GetSignal(name: string): TOscSignal; overload;
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
    procedure doChangeCfg(Sender: tobject);
    // procedure doChangeRState(Sender: TObject);
    procedure doChangeAlgProps(Sender: tobject);
    procedure doStart; override;
    procedure SetActiveChart(c: TSyncOscFrm);
    function GetActiveChart: TSyncOscFrm;
    procedure doRCInit(Sender: tobject);
  public
    procedure doUpdateData; override;
    procedure doAfterLoad; override;
    procedure doCursorMove(Sender: tobject);
  public
    procedure SaveMera(f: string);
    property actchart: TSyncOscFrm read GetActiveChart write SetActiveChart;
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

function TOscTypeToInt(t: TOscType): integer;
function IntToTOscType(i: integer): TOscType;

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

function TOscTypeToInt(t: TOscType): integer;
begin
  case t of
    tOscil:
      Result := 0;
    TtrigOscil:
      Result := 1;
    tHarmOscil:
      Result := 2;
  end;
end;

function IntToTOscType(i: integer): TOscType;
begin
  case i of
    0:
      Result := tOscil;
    1:
      Result := TtrigOscil;
    2:
      Result := tHarmOscil;
  end;
end;

procedure TSyncOscFrm.SaveMera(f: string; num: integer);
var
  i, j: integer;
  s: TOscSignal;
  ifile: TIniFile;
  dir: string;
begin
  dir := extractfiledir(f) + '\Oscillogramm\';
  f := dir + trimext(extractfileName(f)) + '_Osc.mera';
  g_Path := f;
  ForceDirectories(dir);
  ifile := TIniFile.create(f);
  for j := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(j);
    WriteFloatToIniMera(ifile, s.t.tagname + '_' + inttostr(num), 'Freq',
      s.t.freq);
    ifile.WriteString(s.t.tagname + '_' + inttostr(num), 'XFormat', 'R8');
    ifile.WriteString(s.t.tagname + '_' + inttostr(num), 'YFormat', 'R8');
    // Подпись оси x
    ifile.WriteString(s.t.tagname + '_' + inttostr(num), 'XUnits', 'Гц');
    // Подпись оси Y
    // ifile.WriteString(s.tagname, 'YUnits', TagUnits(wp.m_YParam.tag));
    // WriteFloatToIniMera(ifile, s.t.tagname + '_' + inttostr(num), 'Start',
    // s.m_histX0);
    // k0
    ifile.WriteFloat(s.t.tagname + '_' + inttostr(num), 'k0', 0);
    // k1
    ifile.WriteFloat(s.t.tagname + '_' + inttostr(num), 'k1', 1);
    s.saveData(f, num);
  end;
  ifile.destroy;
end;

procedure TOscSignal.saveData(fname: string; num: integer);
var
  lname: string;
  f: file;
  i: integer;
begin
  lname := extractfiledir(fname) + '\' + t.tagname + '_' + inttostr(num)
    + '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, line.data_r[0], sizeof(double) * line.count);
  closefile(f);
end;

procedure TSyncOscFrm.FormClick(Sender: tobject);
begin
  g_OscFactory.actchart := self;
end;

procedure TSyncOscFrm.FormKeyDown(Sender: tobject; var Key: Word;
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
  i: integer;
  s: TOscSignal;
begin
  Result := nil;
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    if s.t.tagname = name then
    begin
      Result := s;
      exit;
    end;
  end;
end;

function TSyncOscFrm.CreateSignal(a: caxis; t: itag): TOscSignal;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to m_signals.count - 1 do
  begin
    if TOscSignal(m_signals.Items[i]).t.tag = t then
    begin
      Result := TOscSignal(m_signals.Items[i]);
      if Result.t.freq <> 0 then
      begin
        Result.m_dt := 1 / Result.t.freq;
      end
      else
        showmessage
          ('1) TSyncOscFrm.CreateSignal t.freq=0: ' + Result.t.tagname);
      Result.line.dx := Result.m_dt;
      break;
    end;
  end;
  if Result = nil then
  begin
    Result := TOscSignal.create;
    Result.t.tag := t;
    if Result.t <> nil then
    begin
      if Result.t.freq <> 0 then
        Result.m_dt := 1 / Result.t.freq
      else
      begin
        showmessage
          ('2) TSyncOscFrm.CreateSignal t.freq=0: ' + Result.t.tagname);
      end;
    end
    else
    begin
      showmessage('3) TSyncOscFrm.CreateSignal t=nil: ' + Result.t.tagname);
      Result.m_dt := 0;
    end;
    Result.ax := a;
    Result.line := cBuffTrend1d.create;
    Result.line.name := t.GetName;
    Result.line.dx := Result.m_dt;
    Result.ax.AddChild(Result.line);
    m_signals.Add(Result);
    Result.m_owner := m_signals;
    Result.line.color := ColorArray[m_signals.count - 1];
  end;
end;

function TSyncOscFrm.CreateSignal(a: caxis; tname: string): TOscSignal;
begin
  Result := TOscSignal.create;
  Result.t.tagname := tname;
  if Result.t.freq <> 0 then
  begin
    Result.m_dt := 1 / Result.t.freq;
  end
  else
  begin
    // showmessage('4) TSyncOscFrm.CreateSignal t.freq=0: '+Result.t.tagname);
  end;
  Result.ax := a;
  Result.line := cBuffTrend1d.create;
  Result.ax.AddChild(Result.line);
  m_signals.Add(Result);
  Result.m_owner := m_signals;
end;

function TSyncOscFrm.GetSignal(i: integer): TOscSignal;
begin
  Result := TOscSignal(m_signals.Items[i]);
end;

procedure TSyncOscFrm.ChartRBtnClick(Sender: tobject);
begin
  if g_EditSyncOscFrm <> nil then
  begin
    g_EditSyncOscFrm.updateTagsList;
    g_EditSyncOscFrm.SetEditObj(self);
  end;
end;

procedure TSyncOscFrm.setTimeLabelPos(Sender: tobject);
var
  pos: point2;
  h: single;
  w: integer;
  p: cpage;
begin
  if m_TimeLabel <> nil then
  begin
    p := cpage(m_Chart.activePage);
    w := p.getwidth;
    if w <> 0 then
    begin
      if p.getheight <> 0 then
      begin
        h := m_TimeLabel.GetTextHeigth;
        pos.y := 1 - 2 * h;
        pos.x := 0.8;
        m_TimeLabel.position := pos;
        m_TimeLabel.Text := 'Time:';
      end;
    end;
  end;
end;

procedure TSyncOscFrm.DblClick(Sender: tobject);
var
  r: frect;
  a: caxis;
  p: cpage;
  axCfg: TAxis;
  i: integer;
begin
  p := cpage(m_Chart.activePage);
  for i := 0 to m_ax.SIZE - 1 do
  begin
    axCfg := m_ax.GetByInd(i);
    a := p.getaxis(axCfg.name);
    p.activeAxis := a;

    r.BottomLeft := p2(p.MinX, axCfg.ymin);
    r.TopRight := p2(m_Length, axCfg.ymax);
    p.ZoomfRect(r);
  end;
end;

procedure TSyncOscFrm.doCursorMove(Sender: tobject);
begin
  // g_SpmFactory.doCursorMove(self);
end;

Function TSyncOscFrm.GetPAxCfg(name: string): PAxis;
var
  i: integer;
  a: PAxis;
begin
  Result := nil;
  for i := 0 to m_ax.SIZE - 1 do
  begin
    a := PAxis(m_ax.GetPByInd(i));
    if a.name = name then
    begin
      Result := a;
      exit;
    end;
  end;
end;

Function TSyncOscFrm.GetAxCfgInd(name: string): integer;
var
  i: integer;
  a: PAxis;
begin
  Result := -1;
  for i := 0 to m_ax.SIZE - 1 do
  begin
    a := PAxis(m_ax.GetPByInd(i));
    if a.name = name then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TSyncOscFrm.GetAxCfg(name: string): TAxis;
var
  i: integer;
  a: TAxis;
begin
  Result.name := '';
  for i := 0 to m_ax.SIZE - 1 do
  begin
    a := m_ax.GetByInd(i);
    if a.name = name then
    begin
      Result := a;
      exit;
    end;
  end;
end;

procedure TSyncOscFrm.ChartInit(Sender: tobject);
var
  i: integer;
  p: cpage;
  d: cDoubleCursor;
  ax: cdrawobj;
begin
  p := cpage(m_Chart.activePage);
  if p = nil then
    exit;

  p.Caption := 'Синхронная осциллограмма';
  // для рисования после текстовых меток полос
  ax := cdrawobj(p.getChild('Axises'));
  ax.layer := 1;
  // p.SetView(p2(0,1),p2(0,1));
  d := p.cursor;
  d.visible := false;
end;

constructor TSyncOscFrm.create(Aowner: tcomponent);
var
  p: cpage;
begin
  inherited;
  m_signals := tlist.create;
  m_Chart := cchart.create(self);

  m_Chart.Name := 'TSyncOscChart';
  m_Chart.Align := alClient;
  m_Chart.showTV := false;
  m_Chart.showLegend := false;
  m_Chart.OnClick := FormClick;
  m_Chart.OnRBtnClick := ChartRBtnClick;
  m_Chart.OnDblClick := DblClick;
  m_Chart.OnInit := ChartInit;

  m_TimeLabel := cfloatlabel.create;
  m_TimeLabel.autocreate := true;
  m_TimeLabel.textcolor := blue;
  m_TimeLabel.Align := c_right;
  m_TimeLabel.Name := modname('Time:', false);
  m_TimeLabel.Transparent := true;
  p := cpage(m_Chart.activePage);
  p.AddChild(m_TimeLabel);
  p.Events.AddEvent('ChartOnCursorMove', e_onResize, setTimeLabelPos);
  setTimeLabelPos(nil);

  // m_Chart.OnKeyDown := doKeyDown;
  m_Chart.OnCursorMove := doCursorMove;
  m_Length := 1;
  m_type := tOscil;
  m_TrigTag := cTag.create;
  m_TrigTag.m_useReadBuffer:=false;
  m_ax := cQueue<TAxis>.create;
end;

destructor TSyncOscFrm.destroy;
var
  i: integer;
  s: TOscSignal;
begin
  m_ax.destroy;
  m_TrigTag.destroy;
  while sCount <> 0 do
  begin
    s := GetSignal(0);
    s.line := nil;
    s.destroy;
  end;
  FreeAndNil(m_signals);
  FreeAndNil(m_Chart);
  inherited;
end;

procedure TSyncOscFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, c: integer;
  s: TOscSignal;
  tname, axname, ls: string;
  t: itag;
  a: caxis;
  axCfg: TAxis;
  pAxCfg: PAxis;
  p: cpage;
  j: integer;
begin
  if m_ax.SIZE > 0 then
    m_ax.clear;
  m_Length := a_pIni.ReadFloat(str, 'Length', 1);
  ls := a_pIni.ReadString(str, 'Threshold', '0.5');
  m_Threshold := strtoFloatExt(ls);
  ls := a_pIni.ReadString(str, 'Shift', '0');
  m_Phase0 := strtoFloatExt(ls);
  m_type := IntToTOscType(a_pIni.ReadInteger(str, 'OscType', 0));
  c := a_pIni.ReadInteger(str, 'AxCount', 1);
  tname := a_pIni.ReadString(str, 'Trig', '');
  if tname <> '' then
    m_TrigTag.tagname := tname;

  p := cpage(m_Chart.activePage);
  for i := 0 to c - 1 do
  begin
    axCfg := m_ax.GetByInd(i);
    axCfg.name := a_pIni.ReadString(str, 'axCfg_name_' + inttostr(i), '');
    ls := a_pIni.ReadString(str, 'axCfg_y1_' + inttostr(i), '0');
    axCfg.ymin := strtoFloatExt(ls);
    ls := a_pIni.ReadString(str, 'axCfg_y2_' + inttostr(i), '10');
    axCfg.ymax := strtoFloatExt(ls);
    a := p.activeAxis;
    if i > 0 then
    begin
      a := caxis.create;
      a.name := axCfg.name;
      p.addaxis(a);
    end
    else
    begin
      if axCfg.name <> '' then
        a.name := axCfg.name
      else
        axCfg.name := a.name;
    end;
    m_ax.push_back(axCfg);
  end;
  c := a_pIni.ReadInteger(str, 'SCount', 0);
  for i := 0 to c - 1 do
  begin
    tname := a_pIni.ReadString(str, 'sig_' + inttostr(i), '');
    t := getTagByName(tname);
    axname := a_pIni.ReadString(str, 'axis_' + inttostr(i), '');
    if m_Chart.activePage = nil then
    begin
      m_Chart.tabs.activeTab.addPage(true);
    end;
    // если у чарта оси нет то создаем
    a := caxis(cpage(m_Chart.activePage).getaxis(axname));
    if a = nil then
    begin
      a := cpage(m_Chart.activePage).Newaxis;
      a.name := axname;
    end;
    pAxCfg := GetPAxCfg(axname);
    if pAxCfg = nil then
    begin
      axCfg.name := axname;
      m_ax.push_back(axCfg);
    end;

    for j := 0 to m_ax.SIZE - 1 do
    begin
      pAxCfg := PAxis(m_ax.GetPByInd(j));
      if pAxCfg.name = axname then
      begin
        a.minY := pAxCfg.ymin;
        a.maxY := pAxCfg.ymax;
      end;
    end;
    if t <> nil then
    begin
      s := CreateSignal(a, t);
    end
    else
    begin
      s := CreateSignal(a, tname);
    end;
    if s.line <> nil then
    begin
      s.line.dx := 1 / s.t.freq;
    end;
  end;
end;

procedure TSyncOscFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  s: TOscSignal;
  axCfg: TAxis;
begin
  inherited;
  a_pIni.WriteFloat(str, 'Length', m_Length);
  WriteFloatToIniMera(a_pIni, str, 'Threshold', m_Threshold);
  // a_pIni.WriteFloat(str, 'Threshold', m_Threshold);
  WriteFloatToIniMera(a_pIni, str, 'Shift', m_Phase0);
  a_pIni.WriteInteger(str, 'OscType', TOscTypeToInt(m_type));
  a_pIni.WriteInteger(str, 'AxCount', m_ax.SIZE);
  if m_TrigTag.tagname <> '' then
  begin
    a_pIni.WriteString(str, 'Trig', m_TrigTag.tagname);
  end;
  for i := 0 to m_ax.SIZE - 1 do
  begin
    axCfg := m_ax.GetByInd(i);
    a_pIni.WriteString(str, 'axCfg_name_' + inttostr(i), axCfg.name);
    WriteFloatToIniMera(a_pIni, str, 'axCfg_y1_' + inttostr(i), axCfg.ymin);
    WriteFloatToIniMera(a_pIni, str, 'axCfg_y2_' + inttostr(i), axCfg.ymax);
  end;
  a_pIni.WriteInteger(str, 'SCount', m_signals.count);
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    a_pIni.WriteString(str, 'sig_' + inttostr(i), s.t.tagname);
    a_pIni.WriteString(str, 'axis_' + inttostr(i), s.ax.name);
  end;
end;

function TSyncOscFrm.sCount: integer;
begin
  Result := m_signals.count;
end;

function TSyncOscFrm.SearchTrig(t: cTag; p_threshold: double;
  var p_interval: point2d): boolean;
var
  v_min, v_max, v, prev: double;
  i, imin: integer;
begin
  v_min := t.m_ReadData[0];
  v_max := t.m_ReadData[0];
  for i := 1 to t.lastindex - 1 do
  begin
    v := t.m_ReadData[i];
    if v > v_max then
    begin
      v_max := v;
      imin := i;
      // rise
      if (v_max - v_min) > p_threshold then
      begin
        m_TrigTime := t.getReadTime(i);
        m_TrigInterval.x := m_TrigTime + m_Phase0;
        m_TrigInterval.y := m_TrigInterval.x + m_Length;
        m_TrigRes := true;
        break;
      end;
    end
    else
    begin
      if v < v_min then
      begin
        v_min := v;
        imin := i;
        // fall
        if (v_max - v_min) > m_Threshold then
        begin
          m_TrigTime := t.getReadTime(i);
          m_TrigInterval.x := m_TrigTime + m_Phase0;
          m_TrigInterval.y := m_TrigInterval.x + m_Length;
          m_TrigRes := true;
          break;
        end;
      end;
    end;
  end;
end;

procedure TSyncOscFrm.UpdateData

;
var
  s: TOscSignal;
  i, ind, j: integer;
  // отображаемый интервал
  t: point2d;
  // интервал графика который будет нарисован
  interval: point2d;
  interval_i: tpoint;
  v, prev: double;
begin
  // триггерный старт
  if m_type = TtrigOscil then
  begin
    if m_TrigTag.UpdateTagData(true) then
    begin
      m_TrigRes := SearchTrig(m_TrigTag, m_Threshold, m_TrigInterval);
      m_TrigTag.ResetTagData();
    end;
  end;

  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    j := s.t.block.GetReadyBlocksCount;
    ind:=0;
    if s.t.UpdateTagData(false) then
    begin
      inc(ind);
      s.m_interval := s.t.EvalTimeInterval;
      // вычисляем рисуемый интервал
      if m_type = TtrigOscil then
      begin
        interval := getCommonInterval(s.m_interval, m_TrigInterval);
        if not CompareInterval(s.m_drawInterval, interval) then
        begin
          s.m_drawInterval := interval;
        end;
      end
      else
      begin
        s.m_drawInterval := s.m_interval;
        if ind=0 then
          interval:=s.m_interval;
      end;
    end;
  end;
  // рисуем синхронные данные
  m_TimeLabel.Text := 'Time: ' + formatstr(interval.x, 3);
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    interval_i:=s.t.getIntervalInd(interval);
    s.line.AddPoints(s.t.m_ReadData, interval_i.x,(interval_i.y - interval_i.x));
  end;
end;

procedure TSyncOscFrm.UpdateProps;
var
  p: cpage;
  a: caxis;
  axCfg: TAxis;
  r: frect;
begin
  p := cpage(m_Chart.activePage);
  a := p.activeAxis;
  axCfg := GetAxCfg(a.name);
  r.BottomLeft := p2(0, m_Length);
  r.TopRight := p2(axCfg.ymin, axCfg.ymax);
  p.ZoomfRect(r);
end;

procedure TSyncOscFrm.UpdateView;
var
  i: integer;
begin
  if RStatePlay then
  begin
    // m_time:=
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
  g_OscFactory := nil;
  inherited;
end;

procedure TOscilFact.CreateEvents;
begin
  if not initevents then
  begin
    if g_algMng <> nil then
    begin
      initevents := true;
      addplgevent('OscFact_doRcInit', E_RC_Init, doRCInit);
      // addplgevent('OscFact_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
      // g_algMng.Events.AddEvent('OscFact_SpmSetProps',e_OnSetAlgProperties,doChangeAlgProps);
      // g_algMng.Events.AddEvent('OscFact_OnLeaveCfg', E_OnChangeAlgCfg, doChangeCfg);
    end;
  end;
end;

procedure TOscilFact.DestroyEvents;
begin
  removeplgEvent(doRCInit, E_RC_Init);
  if g_algMng <> nil then
  begin

  end;
end;

procedure TOscilFact.doAfterLoad;
begin
  CreateEvents;
end;

procedure TOscilFact.doChangeAlgProps(Sender: tobject);
var
  i: integer;
  sChart: TSyncOscFrm;
  j: integer;
begin
  for i := 0 to count - 1 do
  begin
    sChart := TSyncOscFrm(getfrm(i));
  end;
end;

procedure TOscilFact.doChangeCfg(Sender: tobject);
var
  i, k: integer;
  p: cpage;
  d: cDoubleCursor;
  ax: cdrawobj;
  a: cbaseobj;
  sChart: TSyncOscFrm;
begin
  for i := 0 to count - 1 do
  begin
    sChart := TSyncOscFrm(getfrm(i));
  end;
end;

function TOscilFact.doCreateForm: cRecBasicIFrm;
begin
  Result := nil;
  if m_counter < 1 then
  begin
    Result := IOscilFrm.create();
  end;
end;

procedure TOscilFact.doCursorMove(Sender: tobject);
begin

end;

procedure TOscilFact.doDestroyForms;
begin
  inherited;
end;

procedure TOscilFact.doRCInit(Sender: tobject);
var
  i: integer;
  frm: TSyncOscFrm;
  j: integer;
  s: TOscSignal;
begin
  for i := 0 to count - 1 do
  begin
    frm := TSyncOscFrm(getfrm(i));
    for j := 0 to frm.m_signals.count - 1 do
    begin
      s := frm.GetSignal(j);
      if s.t.tag = nil then
      begin
        s.t.tagname := s.t.tagname;
        if s.t.tag <> nil then
        begin
          s.m_dt := 1 / s.t.freq;
          s.line.dx := s.m_dt;
          s.line.color := ColorArray[j];
        end;
      end;
    end;
  end;
end;

procedure TOscilFact.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure TOscilFact.doStart;
var
  i: integer;
  frm: TSyncOscFrm;
  j: integer;
  s: TOscSignal;
begin
  for i := 0 to count - 1 do
  begin
    frm := TSyncOscFrm(getfrm(i));
    if frm.m_TrigTag.tag <> nil then
    begin
      frm.m_TrigTag.doOnStart;
    end;
    for j := 0 to frm.m_signals.count - 1 do
    begin
      s := frm.GetSignal(j);
      s.doStart(frm.m_Length, frm.m_Phase0, frm.m_type);
    end;
    frm.m_init := false;
  end;
end;

procedure TOscilFact.doUpdateData;
var
  s: TOscSignal;
  j: integer;
  frm: TSyncOscFrm;
begin
  for j := 0 to count - 1 do
  begin
    frm := TSyncOscFrm(getfrm(j));
    frm.UpdateData;
  end;
end;

function TOscilFact.GetActiveChart: TSyncOscFrm;
begin

end;

procedure TOscilFact.SaveMera(f: string);
var
  i: integer;
  frm: TSyncOscFrm;
begin
  for i := 0 to count - 1 do
  begin
    frm := TSyncOscFrm(getfrm(i));
    frm.SaveMera(f, i);
  end;
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
  Result := TSyncOscFrm.create(nil);
end;

function IOscilFrm.doGetName: LPCSTR;
begin
  Result := 'OscilFrm';
end;

function IOscilFrm.doRepaint: boolean;
begin
  TSyncOscFrm(m_pMasterWnd).UpdateView;
end;

{ TOscSignal }
constructor TOscSignal.create;
begin
  t := cTag.create;
  t.m_useReadBuffer:=false;
end;

destructor TOscSignal.destroy;
var
  i: integer;
begin
  t.destroy;
  t := nil;
  if line <> nil then
  begin
    line.destroy;
  end;
  if m_owner <> nil then
  begin
    for i := 0 to m_owner.count - 1 do
    begin
      if m_owner.Items[i] = self then
      begin
        m_owner.Delete(i);
        exit;
      end;
    end;
  end;
end;

procedure TOscSignal.doStart(oscLen, Phase0: double; oscType: TOscType);
begin
  t.doOnStart;
  m_portion := trunc(oscLen * t.freq);
  case oscType of
    tOscil:
      ;
    tHarmOscil:
      ;
    TtrigOscil:
      begin
        setlength(m_outdata, trunc(oscLen * t.freq));
      end;
  end;
end;


end.
