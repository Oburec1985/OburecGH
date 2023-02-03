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
    t: cTag;
    m_dt:double;
    // отображать предысторию
    m_bHist: boolean;
    //
    m_histX0: double;
    // данные для отображения предистории
    m_histdata: array of double;
    m_outdata: array of double;
    m_histLen, // длина предыстории
    m_histUsed, // используется
    // длина осциллографирования в int
    m_Resetsize: integer;

    // ось на которой лежит сигнал
    ax: caxis;
    axname: string;
    // линия
    line: cBuffTrend1d;
    // размер отображаемых данных
    m_portion: integer;
  protected
    procedure saveData(fname: string; num:integer);
    procedure resetData(lastind: integer);
    // получить данные с учетом истории (склейка буферов)
    function GetOscTrigData(var data: array of double; time: point2d;
      var lastind: integer): integer;
    procedure doStart(oscLen: double; Phase0: double; oscType: TOscType);
    function GetInterval: point2d;
    // длительность предистории
    function HistLength: double;
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
    m_TahoStart:boolean; // старт поиска периода
    m_iTahoStart:integer; // индекс начала триггера
    m_iTahoStop:integer; // индекс завершения триггера
    m_iTahoN:integer; // Число отсчитанных оборотов

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
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    // NUM - номер осциллограммы
    procedure SaveMera(f: string;num:integer);
    Function GetAxCfg(name: string): TAxis;
    Function GetPAxCfg(name: string): PAxis;
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

procedure TSyncOscFrm.SaveMera(f: string; num:integer);
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
    WriteFloatToIniMera(ifile, s.t.tagname+'_'+inttostr(num), 'Freq', s.t.freq);
    ifile.WriteString(s.t.tagname+'_'+inttostr(num), 'XFormat', 'R8');
    ifile.WriteString(s.t.tagname+'_'+inttostr(num), 'YFormat', 'R8');
    // Подпись оси x
    ifile.WriteString(s.t.tagname+'_'+inttostr(num), 'XUnits', 'Гц');
    // Подпись оси Y
    // ifile.WriteString(s.tagname, 'YUnits', TagUnits(wp.m_YParam.tag));
    WriteFloatToIniMera(ifile, s.t.tagname+'_'+inttostr(num),'Start', s.m_histX0);
    // k0
    ifile.WriteFloat(s.t.tagname+'_'+inttostr(num), 'k0', 0);
    // k1
    ifile.WriteFloat(s.t.tagname+'_'+inttostr(num), 'k1', 1);
    s.saveData(f, num);
  end;
  ifile.destroy;
end;

procedure TOscSignal.saveData(fname: string;num:integer);
var
  lname: string;
  f: file;
  i: integer;
begin
  lname := extractfiledir(fname) + '\' + t.tagname +'_'+inttostr(num)+ '.dat';
  AssignFile(f, lname);
  Rewrite(f, 1);
  BlockWrite(f, line.data_r[0], sizeof(double) * line.count);
  closefile(f);
  // lname := extractfiledir(fname) + '\' + tagname + '.x';
  // AssignFile(f, lname);
  // Rewrite(f, 1);
  // for i := 0 to fready - 1 do
  // begin
  // BlockWrite(f, fdrawarray[i].x, sizeof(double));
  // end;
  // closefile(f);
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
      Result.m_dt:=1/Result.t.freq;
      break;
    end;
  end;
  if Result = nil then
  begin
    Result := TOscSignal.create;
    Result.t.tag := t;
    Result.m_dt:=1/Result.t.freq;
    Result.ax := a;
    Result.line := cBuffTrend1d.create;
    Result.ax.AddChild(Result.line);
    m_signals.Add(Result);
    Result.line.color := ColorArray[m_signals.count - 1];
  end;
end;

function TSyncOscFrm.CreateSignal(a: caxis; tname: string): TOscSignal;
begin
  Result := TOscSignal.create;
  Result.t.tagname := tname;
  Result.m_dt:=1/Result.t.freq;
  Result.ax := a;
  Result.line := cBuffTrend1d.create;
  Result.ax.AddChild(Result.line);
  m_signals.Add(Result);
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
    r.TopRight := p2(p.MaxX, axCfg.ymax);
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
  m_ax := cQueue<TAxis>.create;
end;

destructor TSyncOscFrm.destroy;
begin
  m_ax.destroy;
  m_TrigTag.destroy;
  FreeAndNil(m_signals);
  FreeAndNil(m_Chart);
  inherited;
end;

procedure TSyncOscFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, c: integer;
  s: TOscSignal;
  tname, axname: string;
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
  m_Threshold := a_pIni.ReadFloat(str, 'Threshold', 0.5);
  m_Phase0 := a_pIni.ReadFloat(str, 'Shift', 0);
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
    axCfg.ymin := a_pIni.ReadFloat(str, 'axCfg_y1_' + inttostr(i), 0);
    axCfg.ymax := a_pIni.ReadFloat(str, 'axCfg_y2_' + inttostr(i), 10);
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
    pAxCfg:=GetPAxCfg(axname);
    if pAxCfg=nil then
    begin
      axCfg.name:=axname;
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
  a_pIni.WriteFloat(str, 'Threshold', m_Threshold);
  a_pIni.WriteFloat(str, 'Shift', m_Phase0);
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
    a_pIni.WriteFloat(str, 'axCfg_y1_' + inttostr(i), axCfg.ymin);
    a_pIni.WriteFloat(str, 'axCfg_y2_' + inttostr(i), axCfg.ymax);
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

procedure TSyncOscFrm.UpdateData;
var
  s: TOscSignal;
  i, ind, j, imin, imax, lreset: integer;
  b, lb: boolean;
  // отображаемый интервал
  t: point2d;
  interval: point2d;
  interval_i: tpoint;
  v_min, v_max, v, prev: double;
begin
  b := false;
  if m_type = tHarmOscil then
  begin
    if m_TrigTag.UpdateTagData(true) then
    begin
      v_min := m_TrigTag.m_ReadData[0];
      v_max := m_TrigTag.m_ReadData[0];
      for i := 1 to m_TrigTag.lastindex - 1 do
      begin
        v := m_TrigTag.m_ReadData[i];
        if v > m_Threshold then
        begin
          v_max:=max(v_max, v, lb);
          if lb then
          begin
            if m_TahoStart then
            begin
              m_iTahoStart:=i;
            end
            else
            begin
              m_iTahoStop:=i;
              inc(m_iTahoN);
            end;
          end
        end;
        prev:=v;
      end;
      m_TrigTag.ResetTagData();
    end;
  end;
  // триггерный старт
  if m_type = TtrigOscil then
  begin
    if m_TrigTag.UpdateTagData(true) then
    begin
      v_min := m_TrigTag.m_ReadData[0];
      v_max := m_TrigTag.m_ReadData[0];
      for i := 1 to m_TrigTag.lastindex - 1 do
      begin
        v := m_TrigTag.m_ReadData[i];
        if v > v_max then
        begin
          v_max := v;
          imin := i;
          // rise
          if (v_max - v_min) > m_Threshold then
          begin
            m_TrigTime := m_TrigTag.getReadTime(i);
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
              m_TrigTime := m_TrigTag.getReadTime(i);
              m_TrigInterval.x := m_TrigTime + m_Phase0;
              m_TrigInterval.y := m_TrigInterval.x + m_Length;
              m_TrigRes := true;
              break;
            end;
          end;
        end;
      end;
      m_TrigTag.ResetTagData();
    end;
    b := false;
    for i := 0 to m_signals.count - 1 do
    begin
      s := GetSignal(i);
      if s.t.UpdateTagData(true, s.m_Resetsize) or b then
      begin
        t := s.GetInterval;
        if (t.y > m_TrigInterval.y) and m_TrigRes then
        begin
          if i = 0 then
            interval := getCommonInterval(m_TrigInterval, t)
          else
            interval := getCommonInterval(interval, t);
          if b or (i=0) then
            b := true;
        end
        else
        begin
          // данные триггера накопились не по всем каналам
          b:=false;
        end;
      end;
    end;
    // отображение триггерных данных
    if b then
    begin
      m_TrigRes := false;
      m_TimeLabel.Text := 'Time: ' + formatstr(interval.x, 3);
      for i := 0 to m_signals.count - 1 do
      begin
        s := GetSignal(i);
        if interval.x > 0 then
        begin
          v := interval.x;
          s.m_histX0:= v;
        end
        else
        begin

        end;
        // возвращает количество элементов в m_outData, ind - посл элемент в m_readData
        j := s.GetOscTrigData(s.m_outdata, interval, ind);
        if j > 0 then
        begin
          s.line.AddPoints(s.m_outdata, j);
          s.resetData(ind);
        end;
      end;
    end;
    exit;
  end;
  // сбор данных
  for i := 0 to m_signals.count - 1 do
  begin
    s := GetSignal(i);
    if s.t.UpdateTagData(true) or b then
    begin
      if not m_init then
      begin
        m_init := true;
      end;
      t := s.t.getPortionTime;

      if (t.y - t.x) > m_Length then
        b := true
      else
        b := false;
      if not b then
        break;
      if i = 0 then
        interval := t
      else
        interval := getCommonInterval(interval, t);
      if (interval.y - interval.x < m_Length) then
      begin
        b := false;
        break;
      end
    end
    else
    begin

    end;
  end;
  if b then
  begin
    // рисуем только последние синхронные данные, а не весь объем
    interval.x := interval.y - m_Length;
    m_TimeLabel.Text := 'Time: ' + formatstr(interval.x, 3);
    for i := 0 to m_signals.count - 1 do
    begin
      s := GetSignal(i);
      interval_i := s.t.getIntervalInd(interval);
      s.line.AddPoints(s.t.m_ReadData, interval_i.x,
        (interval_i.y - interval_i.x));
      if s.t.lastindex >= interval_i.y then
      begin
        s.t.ResetTagDataTimeInd(interval_i.y);
      end;
    end;
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
      // addplgevent('OscFact_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
      // g_algMng.Events.AddEvent('OscFact_SpmSetProps',e_OnSetAlgProperties,doChangeAlgProps);
      // g_algMng.Events.AddEvent('OscFact_OnLeaveCfg', E_OnChangeAlgCfg, doChangeCfg);
    end;
  end;
end;

procedure TOscilFact.DestroyEvents;
begin
  // removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
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
end;

destructor TOscSignal.destroy;
begin
  t.destroy;
  t := nil;
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
        if Phase0 < 0 then
        begin
          setlength(m_histdata, round(abs(Phase0) * t.freq));
          m_histLen := round(abs(Phase0) * t.freq);
          m_Resetsize := round(oscLen * t.freq);
        end;
      end;
  end;
end;

function TOscSignal.GetInterval: point2d;
begin
  Result := t.getPortionTime;
  Result.x := Result.x - HistLength;
end;

function TOscSignal.HistLength: double;
begin
  Result := m_dt * m_histLen;
end;

function TOscSignal.GetOscTrigData(var data: array of double; time: point2d;
  var lastind: integer): integer;
var
  t1: point2d;
  l: double;
  intervali: tpoint;
  i1, i2: integer;
begin
  t1 := t.getPortionTime;
  if t1.x > time.x then
  begin
    l := (t1.x - time.x);
    i1 := round(l * t.freq);
    move(m_histdata[m_histLen - i1], data[0], i1 * sizeof(double));
    i2 := round((time.y - l) * t.freq);
    move(t.m_ReadData[0], data[i1], i2 * sizeof(double));
    Result := i1 + i2;
    lastind := i2;
  end
  else
  begin
    intervali := t.getIntervalInd(time);
    lastind := intervali.y;
    move(t.m_ReadData[intervali.x], data[0],
      (intervali.y - intervali.x) * sizeof(double));
    Result := intervali.y - intervali.x;
  end;
end;

// сдвигаем данные до lastind+histlen
procedure TOscSignal.resetData(lastind: integer);
var
  i: integer;
begin
  i := t.m_ReadSize - lastind;
  if i >= m_histLen then
  begin
    i := m_histLen;
  end;
  m_histUsed := i;
  move(t.m_ReadData[lastind], m_histdata[0], i * sizeof(double));
  t.ResetTagDataTimeInd(lastind + i);
end;

end.
