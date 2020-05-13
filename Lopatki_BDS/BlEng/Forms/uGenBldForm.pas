unit uGenBldForm;

interface

uses
  Windows, SysUtils, Classes, Forms, StdCtrls, ComCtrls, uBaseObj, usensor, uTickData,
  uBtnListView, ExtCtrls, uChart, DCL_MYOWN, uBldEng, Controls, uBldObj, ustage,
  ubldMath, utrend, uaxis, uturbina, uBldCompProc, dialogs, uCompaundFrame,
  uBlInterfaceFrame, uMyMath, uCommonTypes, inifiles, uPoint, uCommonMath, Spin,
  uerrorproc, mathfunction, uPage;

type

  SensorStruct = class
    skipblade:boolean;
    // ����� �������� �������
    SkipType:integer;
    // ������ �������
    Blade:integer;
    // ������ ��������
    i:integer;
    // ���������� ������ n ���������
    skipFirst:integer;
  end;

  cBoolArray = class
    a:array of boolean;
  public
    procedure getstage(stage:cstage);
  end;

  TGeneratorForm = class(TForm)
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    CfgGB: TGroupBox;
    CfgTV: TTreeView;
    BladesGB: TGroupBox;
    BladesLV: TBtnListView;
    Splitter1: TSplitter;
    SignalGB: TGroupBox;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    PropertyGB: TGroupBox;
    ValueEdit: TFloatEdit;
    ValueLabel: TLabel;
    VibrationFloatEdit: TFloatEdit;
    FreqVibrLabel: TLabel;
    VibrationTypeCB: TComboBox;
    VibrationTypeLabel: TLabel;
    Label1: TLabel;
    TahoCB: TComboBox;
    FreqFE: TFloatEdit;
    FreqLabel: TLabel;
    SignalLengthFE: TFloatEdit;
    SignalLengthLabel: TLabel;
    VibrRootCB: TCheckBox;
    SignalSetupPageControl: TPageControl;
    TahoTabSheet: TTabSheet;
    VibrationTabSheet: TTabSheet;
    TahoChart: cChart;
    VibrationChart: cChart;
    SensorGB: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    SkipBladeCB: TComboBox;
    SkipCB: TCheckBox;
    SkipPeriodSE: TSpinEdit;
    SkipBladeSE: TSpinEdit;
    Button1: TButton;
    SkipFirstLabel: TLabel;
    SkipFirstSE: TSpinEdit;
    procedure CfgTVChange(Sender: TObject; Node: TTreeNode);
    procedure BladesLVChanging(Sender: TObject; Item: TListItem;
      Change: TItemChange; var AllowChange: Boolean);
    procedure BladesLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure EvalBtnClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure TahoChartInit(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    initChart:boolean;
    eng:cBldEng;
    // ������������ �������
    stage:cstage;
    cursensor:csensor;
    // �������� �������������� ������ �� ������� � ������������������ ��������
    prec:integer;
    sensorStructs:tstringlist;
    OnLvChange:boolean;
  private
    procedure showstage(s:cstage);
    procedure showCfg;
    // ������� ������ ��������� �����������
    procedure generateConstTaho(s:csensor);
    // ��������� ������� ����
    procedure generateTaho(s:csensor);
    // ��������� �������� �� ��������
    procedure generateSensorsImpuls(stage:cstage);
    // ��������� �������� �� ������ �� ������
    procedure generateTurnImpuls(t1,t2:stickdata;s:csensor);
    // �������� �������� �������� � ��������
    function getVibrationLevel(time:single):single;
    // ����������� ���� ������� � ��������� ��� ��� �������� �� ������ �����
    procedure enumTaho(stage:cstage);
    // ��������� ������� ������ � ����������� �� ��������� �����
    procedure generateData;
    // ��������� ������ ����� � ��������� ����
    procedure SaveChart;
    // ��������� ������ ����� �� �����
    procedure LoadChart;
    procedure showsensor(s:csensor);
    procedure SetSensor(s:csensor);
    // �������� ����� �� ��������� ������� � �������� ind �� �������
    function TestSkip(s:csensor; ind:integer):boolean;
    procedure filterTicks;
    procedure filterSensorTicks(s:csensor);
  public
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
    procedure getEngine(e:cBldEng);
    function ShowModal:integer;
    procedure loadCfg;
    procedure SaveCfg;
  end;

var
  GeneratorForm: TGeneratorForm;

implementation

var
  LastState:Boolean;
  //��� ������ ����� �� �����, ������ �������������.
  LastItem:TListItem;

const
  c_ConstSkip = 1;
  c_TurnSkip = 0;
  c_NoiseSkip = 2;

  c_sin = 0;
  c_cos = 1;
  c_const = 0;
  c_line = 1;
  c_user = 2;
  // �������� ���������� ������ �����
  floatPrec = 3;
  ChartCfgName = 'GenChartCfg.cfg';
  CfgName = 'GenFormCfg.ini';
  SaveSection = 'Main';
  LengthKey = 'SignalLength';
  FreqKey = 'Frequency';
  GenRootKey = 'GenerateRoot';
  TahoType = 'TahoType';
  VibrationType = 'VibrationType';
  VibrationFreq = 'VibrationFrequency';
  VibrationValue = 'VibrationValue';
  // �������� �������������� ������ �� ������� � ������������������ ��������
  // (����� ��������� ����� ����� ��������� ������� ���� �����)
  Precision = 'Precision';

{$R *.dfm}

function strTofloat_(str:string; separator:char):single;
var
  I: Integer;
begin
  for I := 1 to length(str) do
  begin
    if (str[i]='.') or (str[i]=',') then
    begin
      str[i]:=separator;
    end;
  end;
  result:=strtofloat(str);
end;

procedure cBoolArray.getstage(stage:cstage);
var
  I: Integer;
begin
  setlength(a,stage.BladeCount);
  stage.data:=self;
  for I := 0 to stage.bladecount - 1 do
  begin
    a[i]:=true;
  end;
end;

function enumTahoProc(obj:cbaseobj; data:pointer):boolean;
var
  s:csensor;
begin
  result:=true;
  s:=csensor(obj);
  if s.sensortype=c_rot then
  begin
    case TGeneratorForm(data).TahoCB.ItemIndex of
      c_const: TGeneratorForm(data).generateConstTaho(s);
      c_user: TGeneratorForm(data).generateTaho(s);
    end;
  end;
end;

function TGeneratorForm.getVibrationLevel(time:single):single;
var
  min,max,x:single;
  trend:ctrend;
  phase:single;
  function getPhase(t:single):single;
  var
    period,phase:single;
  begin
    period:=1/VibrationFloatEdit.FloatNum;
    phase:=frac(t/period)*2*pi;
    result:=phase;
  end;
begin
  case VibrationTypeCB.ItemIndex of
    c_sin:
    begin
      result:=ValueEdit.FloatNum*sin(getPhase(time));
    end;
    c_cos:
    begin
      result:=ValueEdit.FloatNum*cos(getPhase(time));
    end;
    c_user:
    begin
      min:=cpage(VibrationChart.activepage).activeAxis.min.x;
      max:=cpage(VibrationChart.activepage).activeAxis.max.x;;
      x:=frac(time)*(max-min);
      trend:=VibrationChart.activetrend;
      result:=ValueEdit.FloatNum*trend.gety(x);
    end;
  end;
end;
//
procedure TGeneratorForm.generateTurnImpuls(t1,t2:stickdata;s:csensor);
var
  i:integer;
  ticks:cbaseticks;
  stage:cstage;
  pos,phase:single;
  dt,tick:stickdata;
  degT:single;
  t, period:single;
begin
  ticks:=s.chan.ticks;
  // ����� �������
  dt:=decticks(t1,t2);
  // ����� ����� � �������
  degT:=dt.Data/360;
  stage:=cstage(s.stage);
  for I := 0 to stage.BladeCount - 1 do
  begin
    // ���� ������� ������ ������ ������� �� �������
    pos:=EvalBladePath(s.pos,stage.shape.Blades[i]);
    // ��������� ����� ������� ��������
    tick:=EvSensorTickInTurn(t1,degt,pos);
    t:=TickToSec(tick);
    // ���� ������ ������������
    // ��� �������� � ����� ������� �������� �������� �� �������� ��������
    // � ������� �������� ��� �����������
    if cboolarray(stage.data).a[i] then
    begin
      if (s.sensortype=c_edge) or
         ((s.sensortype=c_root) and (VibrRootCB.Checked))
      then
      begin
        pos:=pos+getVibrationLevel(t);
        tick:=EvSensorTickInTurn(t1, degt, pos);
      end;
    end;
    ticks.add(tick);
   end;
end;

procedure TGeneratorForm.generateSensorsImpuls(stage:cstage);
var
  i, j:integer;
  s, taho:csensor;
  tahoticks:cbaseticks;
  t1,t2:stickdata;
begin
  // ������ �� �������� �������
  for i := 0 to stage.sensorscount - 1 do
  begin
    s:=stage.GetSensor(i);
    if s.sensortype<>c_rot then
    begin
      s.chan.ticks.clear;
      taho:=stage.GetTaho;
      if taho=nil then
      begin
        errorStage_noTaho(stage,eng.flags);
        exit;
      end;
      tahoticks:=taho.chan.ticks;
      // ������ �� ���� �������� � ��������� �� ������ ������� ��������� �� ������� �� ������
      for j := 1 to tahoticks.Count - 1 do
      begin
        t1:=tahoticks.gettick(j-1);
        t2:=tahoticks.gettick(j);
        generateTurnImpuls(t1, t2, s);
      end;
    end;
  end;
end;

procedure TGeneratorForm.enumTaho(stage:cstage);
begin
  stage.EnumSensors(enumTahoProc, self);
end;

procedure TGeneratorForm.generateData;
var
  i,j: Integer;
  obj:cbldobj;
  t:cTurbine;
  stage:cstage;
begin
  t:=cTurbine(eng.getTurbine);
  if t=nil then
  begin
    exit;
  end;
  // ������ �� ��������
  for i := 0 to t.StageCount - 1 do
  begin
    stage:=t.GetStage(i);
    // ��������� �������� �� ���� ��������
    enumTaho(stage);
    // ������� �������� �� ���� ��������
    generateSensorsImpuls(stage);
  end;
end;

constructor TGeneratorForm.create(aowner:tcomponent);
begin
  inherited;
  initChart:=false;
  initBladesLV(bladesLV);
end;

destructor TGeneratorForm.destroy;
begin
  inherited;
end;


procedure TGeneratorForm.TahoChartInit(Sender: TObject);
begin
  if not initchart then
  begin
    LoadChart;
    initchart:=true;
  end;
end;

procedure TGeneratorForm.generateTaho(s:csensor);
var
  TurnCount:cardinal;
  i:integer;
  dt:cardinal;
  ticks:cbaseticks;
  tick,t1,t2:stickdata;
  trend:ctrend;
  index:tpoint;
  // ������� � �������� ����� ����� ��������� ������� �� �������
  // ��� ���������� ������� (�����������)
  dtime:single;
  // ��� �������� ����� ��� ����������� ������ � �����
  line:frect;
  lp,rp:cBeziePoint;
  // ������� ������� � ����� ��������� ���� �������
  curfreq,
  // ������� ����� � ����� ��������� ���� �������
  curt,
  // ����� �� ���������� ����
  curdt,
  // ������������ �������
  fmax,
  // ������������ �����
  tmax,
  // ���������
  a,
  // ����� �������, ������� ���� ��������, �� ���� ��� ������� ����� ����������
  part:single;
  // ����� �������
  root:point2;
  // ����� ������ � ��������� V0*t+(a*t^2)/2
  rootcount:integer;
begin
  // ������ �� ���� ����������� ����� ����
  trend:=ctrend(tahoChart.activetrend);
  // �������� ������������ ������� � �����
  fmax:=cpage(tahochart.activepage).activeAxis.max.y;
  // �������� ������������ ����� � �����
  tmax:=cpage(tahochart.activepage).activeAxis.max.x;
  // �������� ������ �� ������ ����� � ������� ���
  ticks:=s.chan.ticks;
  ticks.clear;
  // ����� �������, ������� ���� ��������, �� ���� ��� ������� ����� ����������
  part:=0;
  // ��������� �������� � ������ ���� �������, ���� �� ����� �� �������
  // ��������� ������������� �������
  while (curt<tmax) do
  begin
    if curt<trend.GetBound.TopRight.x then
    begin
      line:=trend.GetLoHi_(curt,lp,rp,index);
      // ��� ��������� ������� �� �������
      dtime:=(line.TopRight.x - line.BottomLeft.x)/(prec*2);
      curFreq:=trend.GetY(curt);
      a:=trend.GetTangent(curt, dtime);
    end
    else
    begin
      curFreq:=trend.GetBound.TopRight.y;
      a:=0;
    end;
    // ���������� ������� ������� ������� �� ������ v0*t+at^2/2 = S(���� ������, = 1)
    // �� ��������� ������� ����� �������
    // part - ����� ������� ������� ���� �������� �� ���������� �������.
    // a - ��������� (��������� �������), ��� �� ����������� � �������
    // ����������� � �������.
    // ������� ����� ����������� ���������� �������
    root:=SqRoot(a/2, curFreq,(-1 + part), rootcount);
    // ����� � �������� �� ���������� ����
    curDT:=root.x;
    // ���� ��������� ��� �� ���������� �� ������� ������� ��� ������� �� ������
    // �������� ��������� ��� �������� �������� ��������� �������
    if ((curt + curdt)<=curt+dtime) and (rootcount<>0) then
    begin
      part:=0;
      curt:=curt + curdt;
      // ����� ������� ������ �������� �� ���� ������
      tick:=SecToTick(curt);
      // ��������� ������� � ������ �����������
      ticks.add(tick);
    end
    else
    // ��� ��� �� ����� ���� ��������� �� ���������� �� ������� ��������� ������
    // ��������� ����� ������� ������� ������� �������
    begin
      // S = V0*t+a*t^2/2+S0
      part:=curFreq*dtime + (a*dtime*dtime)/2 + part;
      curt:=curt+dtime;
    end;
  end;
end;

procedure TGeneratorForm.generateConstTaho(s:csensor);
var
  TurnCount:cardinal;
  i:integer;
  dt:cardinal;
  ticks:cbaseticks;
  tick,t1,t2:stickdata;
begin
  // ����� ��������
  TurnCount:=round(freqFE.FloatNum*SignalLengthFE.FloatNum);
  // �������� ������ �� ������ �����
  ticks:=s.chan.ticks;
  ticks.clear;
  // ���������� ������� �������� - ��� ������� � ������� �������� �����
  t2.Data:=0;
  t2.OverflowCount:=0;
  // ����� ������ �������
  dT:=trunc(CardFreq/(freqFE.FloatNum));
  for I := 0 to turncount - 1 do
  begin
    t1:=t2;
    t2:=addtick(t1,dt);
    // t1, t2 ������ � ����� �������
    tick:=EvSensorTickInTurn(t1,t2,s.pos);
    ticks.add(tick);
    // ���������� ������� �� ������ ������� (��������� ����� ���������� �������)
  end;
end;

procedure TGeneratorForm.EvalBtnClick(Sender: TObject);
begin
  generateData;
end;

procedure TGeneratorForm.getEngine(e:cBldEng);
begin
  eng:=e;
  loadcfg;
end;


procedure TGeneratorForm.ShowStage(s:cstage);
var
  I: Integer;
  li:tlistitem;
begin
  bladeslv.clear;
  OnLvChange:=false;
  showBladesInLV(bladeslv,s);
  for I := 0 to s.BladeCount - 1 do
  begin
    li:=bladeslv.Items[i];
    li.Checked:=cboolarray(s.data).a[i];
  end;
 OnLvChange:=true;
end;

// ��������� � �������� ������� ����� ������������ ����� �� ������� �������� ��� �������
procedure PrepareStages(e:cbldeng);
var
  t:cTurbine;
  stage:cstage;
  a:cBoolArray;
  i:integer;
begin
  t:=cTurbine(e.getTurbine);
  if t<>nil then
  begin
    for i := 0 to t.stageCount - 1 do
    begin
      stage:=t.GetStage(i);
      if stage.data=nil then
      begin
        a:=cBoolArray.Create;
        a.getstage(stage);
      end;
    end;
  end;
end;

procedure ReleaseStages(e:cbldeng);
var
  t:cTurbine;
  stage:cstage;
  a:cBoolArray;
  i:integer;
begin
  t:=cTurbine(e.getTurbine);
  if t=nil then exit;
  for i := 0 to t.stageCount - 1 do
  begin
    stage:=t.GetStage(i);
    if stage.data<>nil then
    begin
      a:=stage.data;
      a.destroy;
      stage.data:=nil;
    end;
  end;
end;


procedure TGeneratorForm.showCfg;
var
  i:integer;
  obj:cbldobj;
  s:sensorstruct;
begin
  ShowEngInTreeView(cfgtv,eng);
  sensorStructs.Clear;
  for I := 0 to eng.count - 1 do
  begin
    obj:=cbldobj(eng.getobj(i));
    if obj is csensor then
    begin
      s:=sensorstruct.Create;
      sensorStructs.AddObject(obj.name,s);
    end;
  end;
end;

function TGeneratorForm.ShowModal:integer;
var
  s:SensorStruct;
begin
  sensorStructs:=tstringlist.Create;
  sensorStructs.Sorted:=true;
  PrepareStages(eng);
  showCfg;
  result:=inherited showmodal;
  if result=mrok then
  begin
    // ��������� �������� �� ������������
    generateData;
    // ������������� ��������
    filterTicks;
  end;
  ReleaseStages(eng);
  while sensorstructs.count<>0 do
  begin
    s:=SensorStruct(sensorstructs.Objects[0]);
    s.Destroy;
    sensorstructs.Delete(0);
  end;
  sensorStructs.Destroy;
end;

procedure TGeneratorForm.ApplyBtnClick(Sender: TObject);
begin
  savecfg;
  SaveChart;
end;

procedure TGeneratorForm.BladesLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if OnLvChange then
  begin
    if (LastItem=Item)and(Item.Checked<>LastState) then
    begin
      // ��� ���� �������� ������ ��� ��������� ��������,
      // ������ ����� ��������, ���� ������ ���� ����������.
      if stage<>nil then
      begin
        cboolarray(stage.data).a[item.Index]:=Item.Checked;
      end;
    end;
  end;
end;

procedure TGeneratorForm.BladesLVChanging(Sender: TObject; Item: TListItem;
  Change: TItemChange; var AllowChange: Boolean);
begin
  LastItem:=Item;
  LastState:=Item.Checked;
end;

procedure TGeneratorForm.Button1Click(Sender: TObject);
begin
  SetSensor(cursensor);
end;

procedure TGeneratorForm.CfgTVChange(Sender: TObject; Node: TTreeNode);
begin
  if tobject(node.Data) is cstage then
  begin
    showstage(cstage(node.data));
    stage:=cstage(node.data);
  end;
  if tobject(node.Data) is csensor then
  begin
    cursensor:=csensor(node.Data);
    showsensor(cursensor);
  end;
end;

procedure TGeneratorForm.showsensor(s:csensor);
var
  obj:SensorStruct;
  i:integer;
begin
  if sensorStructs.Find(s.name,i) then
  begin
    obj:=SensorStruct(sensorStructs.Objects[i]);
    skipbladecb.ItemIndex:=obj.SkipType;
    SkipBladeSE.Value:=obj.Blade;
    SkipBladeSE.Enabled:=s.sensortype<>c_rot;
    SkipPeriodSE.Value:=obj.i;
    SkipCB.Checked:=obj.skipblade;
  end;
end;

procedure TGeneratorForm.SetSensor(s:csensor);
var
  obj:SensorStruct;
  i:integer;
begin
  if sensorStructs.Find(s.name,i) then
  begin
    obj:=SensorStruct(sensorStructs.Objects[i]);
    obj.SkipType:=skipbladecb.ItemIndex;
    obj.i:=SkipPeriodSE.Value;
    obj.Blade:=SkipBladeSe.Value;
    obj.skipblade:=SkipCB.Checked;
    obj.skipFirst:=SkipFirstSE.Value;
  end;
end;

procedure TGeneratorForm.SaveCfg;
var
  cfgfolder,name:string;
  f:TiniFile;
begin
  cfgFolder:=eng.PathMng.getCfgList.Strings[0];
  name:=cfgfolder+cfgName;
  f:=tinifile.Create(name);
  // ����� ����� ������
  f.WriteFloat(saveSection, LengthKey, SignalLengthFE.FloatNum);
  // ����� ������� ���� � ������ ����������� ������
  f.WriteFloat(saveSection, FreqKey, freqFE.FloatNum);
  // ����� ���� ��������� �������� �� �������� ��������
  f.Writebool(saveSection, GenRootKey, vibrrootcb.checked);
  // ����� ����� ��������� ����
  f.WriteInteger(saveSection, TahoType, tahocb.ItemIndex);
  // ����� ����� ��������� ��������
  f.WriteInteger(saveSection, VibrationType, VibrationTypecb.ItemIndex);
  // ����� ������� �������� � ������ ��������� ������
  f.WriteFloat(saveSection, VibrationFreq, VibrationFloatEdit.FloatNum);
  // ����� ��������� �������� ��� �������������� ������
  f.WriteFloat(saveSection, VibrationValue, ValueEdit.FloatNum);
  // �������� �������������� ������ �� ������� � ������������������ ��������
  // (����� ��������� ����� ����� ��������� ������� ���� �����)
  f.WriteInteger(saveSection, Precision, prec);
  f.Destroy;
end;

procedure TGeneratorForm.loadCfg;
var
  cfgfolder,name:string;
  f:TiniFile;
begin
  cfgFolder:=eng.PathMng.getCfgList.Strings[0];
  name:=cfgfolder+cfgName;
  f:=tinifile.Create(name);
  // ����� ����� ������
  SignalLengthFE.FloatNum:=f.ReadFloat(saveSection, LengthKey, 10);
  // ����� ������� ���� � ������ ����������� ������
  freqFE.FloatNum:=f.readFloat(saveSection, FreqKey, 50);
  // ����� ���� ��������� �������� �� �������� ��������
  vibrrootcb.checked:=f.ReadBool(saveSection, GenRootKey, false);
  // ����� ����� ��������� ����
  tahocb.ItemIndex:=f.ReadInteger(saveSection, TahoType, c_const);
  // ����� ����� ��������� ��������
  VibrationTypecb.ItemIndex:=f.ReadInteger(saveSection, VibrationType, c_sin);
  // ����� ������� �������� � ������ ��������� ������
  VibrationFloatEdit.FloatNum:=f.ReadFloat(saveSection, VibrationFreq, 1);
  // ����� ��������� �������� ��� �������������� ������
  ValueEdit.FloatNum:=f.ReadFloat(saveSection, VibrationValue, 1);
  // �������� �������������� ������ �� ������� � ������������������ ��������
  // (����� ��������� ����� ����� ��������� ������� ���� �����)
  prec:=f.Readinteger(saveSection, Precision, 15);
  f.Destroy;
end;

function readPointsCountFromHeader(h:string):integer;
var
  str:string;
  i,len:integer;
begin
  i:=pos(':',h);
  len:=length(h)-i;
  setlength(str,len);
  move(h[i+1],str[1],len);
  result:=strtoint(str);
end;

function readPoint(str:string):cBeziePoint;
var
  buf:string;
  i,t,index:integer;
  bp:cBeziepoint;
begin
  bp:=cBeziepoint.create;
  buf:=GetSubString(str,' ',9,index);
  // ��������� ��� �������
  if buf='corner' then
    bp.smooth:=false
  else
    bp.smooth:=true;
  // ��������� ���������� �������
  buf:=GetSubString(str,';',24,index);
  bp.point.x:=strtofloat_(buf,'.');
  // ��������� ���������� �������
  buf:=GetSubString(str,'/',index+3,index);
  bp.point.y:=strtofloat_(buf,'.');;
  if bp.smooth then
  begin
    // ��������� ���������� �������
    buf:=GetSubString(str, ';', index+15, index);
    bp.left.x:=strtofloat_(buf,'.');;
    // ��������� ���������� �������
    buf:=GetSubString(str, '/', index+3, index);
    bp.left.y:=strtofloat_(buf,'.');
    // ��������� ���������� �������
    buf:=GetSubString(str, ';',index+16, index);
    bp.right.x:=strtofloat_(buf,'.');
    // ��������� ���������� �������
    buf:=GetSubString(str, '/', index+3, index);
    bp.right.y:=strtofloat_(buf,'.');
  end;
  result:=bp;
end;

procedure TGeneratorForm.LoadChart;
var
  f:tstringlist;
  trend:ctrend;
  I, strCount,res: Integer;
  p:cbeziePoint;
  str, str2, filename, cfgfolder:string;
begin
  f:=tstringlist.Create;
  filename:=eng.PathMng.findCfgPathFile(ChartCfgName);
  f.LoadFromFile(filename);
  // ��������� ������ ��������� ����� ��� ������� ���� � ��������� �����
  str:=f.Strings[0];
  res:=Pos('TahoChart',str);
  if (res<>0) then
  begin
    trend:=tahochart.activetrend;
    trend.Clear;
    // �������� ����� ����� � �����
    strCount:=readPointsCountFromHeader(str);
    i:=1;
    while i<=strcount do
    begin
      str:=f.Strings[i];
      p:=readpoint(str);
      trend.AddPoint(p);
      inc(i);
    end;
  end;
  if i<f.Count-1 then
  begin
    trend:=VibrationChart.activetrend;
    trend.Clear;    
    // ��������� ������ ��������� ����� ��� ������� ���� � ��������� �����
    str:=f.Strings[i];
    res:=Pos('VibrationChart',str);
    if (res<>0) then
    begin
      // �������� ����� ����� � �����
      strCount:=readPointsCountFromHeader(str);
      inc(i);
      res:=i;
      while i<strcount+res do
      begin
        str:=f.Strings[i];
        p:=readpoint(str);
        trend.AddPoint(p);
        inc(i);
      end;
    end;
  end;
  f.Destroy;
end;

procedure TGeneratorForm.SaveChart;
var
  f:tstringlist;
  trend:ctrend;
  I: Integer;
  p:cbeziePoint;
  str,t,coord, filename, cfgfolder:string;
begin
  f:=tstringlist.Create;
  trend:=tahochart.activetrend;
  if trend<>nil then
  begin
    // ��������� ������ ��������� ����� ��� ������� ���� � ��������� �����
    str:='TahoChart'+' ����� �����:'+inttostr(trend.count);
    f.Add(str);
    for I := 0 to trend.count - 1 do
    begin
      p:=trend.getPoint(i);
      coord:='point x:'+formatstr(p.point.x,floatPrec)+';y:'+formatstr(p.point.y,floatPrec);
      if p.smooth then
      begin
        coord:=coord+'/LeftTangent x:'+formatstr(p.left.x,floatPrec)+';y:'+formatstr(p.left.y,floatPrec);
        coord:=coord+'/RightTangent x:'+formatstr(p.right.x,floatPrec)+';y:'+formatstr(p.right.y,floatPrec);
        t:='smooth ';
      end
      else
        t:='corner ';
      str:=inttostr(i)+') Type:'+t+coord;
      f.Add(str);
    end;
  end;
  // ��������� ������ ��������� ����� ��� ������� ������ �������� � ��������� �����
  trend:=VibrationChart.activetrend;
  if trend<>nil then
  begin
    str:='VibrationChart'+' ����� �����:'+inttostr(trend.count);
    f.Add(str);
    for I := 0 to trend.count - 1 do
    begin
      p:=trend.getPoint(i);
      coord:='point x:'+formatstr(p.point.x,floatPrec)+';y:'+formatstr(p.point.y,floatPrec);
      if p.smooth then
      begin
        coord:=coord+'/LeftTangent x:'+formatstr(p.left.x,floatPrec)+';y:'+formatstr(p.left.y,floatPrec);
        coord:=coord+'/RightTangent x:'+formatstr(p.right.x,floatPrec)+';y:'+formatstr(p.right.y,floatPrec);
        t:='smooth ';
      end
      else
        t:='corner ';
      str:=inttostr(i)+') Type:'+t+coord;
      f.Add(str);
    end;
  end;
  cfgFolder:=eng.PathMng.getCfgList.Strings[0];
  filename:=cfgfolder+ChartCfgName;
  f.SaveToFile(filename);
  f.Destroy;
end;

function TGeneratorForm.TestSkip(s:csensor; ind:integer):boolean;
var
  obj:SensorStruct;
  I, turn, blade: Integer;
begin
  result:=false;
  if sensorStructs.Find(s.name,i) then
    obj:=SensorStruct(sensorStructs.Objects[i]);
  if not obj.skipblade then
  begin
    exit;
  end;
  // ������� ������ n �����
  if ind<obj.skipFirst then
  begin
    result:=true;
    exit;
  end;
  case obj.SkipType of
    c_ConstSkip:
    begin
      if frac((ind+1)/obj.i)=0 then
      begin
        result:=true;
      end;
    end;
    c_TurnSkip:
    begin
      turn:=trunc((ind+1)/stage.BladeCount);
      // ���� �� ������ ������� ���� ��������� �������
      if frac((turn+1)/obj.i)=0 then
      begin
        // �������� ������ �������� ������ �������
        blade:=ind - turn*stage.BladeCount;
        // ��������� ����� �������
        blade:=getBladeNumber(s.skipblade,blade,stage.bladecount);
        // ���� �� ������ ������� ���������� ��������
        if (blade=obj.Blade) then
        begin
          result:=true;
        end;
      end;
    end;
    c_NoiseSkip:
    begin
      result:=false;
    end;
  end;
end;

procedure TGeneratorForm.filterSensorTicks(s:csensor);
var
  i:integer;
  ticks:cbaseticks;
  struct:SensorStruct;
begin
  if sensorStructs.Find(s.name,i) then
  begin
    struct:=sensorstruct(sensorStructs.Objects[i]);
    if struct.skipblade then
    begin
      ticks:=cbaseticks.create;
      for I := 0 to s.tickscount - 1 do
      begin
        if not TestSkip(s,i) then
          ticks.add(s.chan.ticks.gettick(i));
      end;
      s.chan.ticks.destroy;
      s.chan.ticks:=ticks;
    end;
  end;
end;

procedure TGeneratorForm.filterTicks;
var
  i:integer;
  s:csensor;
begin
  for I := 0 to eng.count - 1 do
  begin
    if eng.getobj(i) is csensor then
    begin
      s:=csensor(eng.getobj(i));
      filterSensorTicks(s);
    end;
  end;
end;

end.
