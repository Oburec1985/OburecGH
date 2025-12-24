unit uGenBldForm;

interface

uses
  Windows, SysUtils, Classes, graphics,
  Forms, StdCtrls, ComCtrls, uBaseObj, usensor, uTickData,
  uBtnListView, ExtCtrls, uChart, DCL_MYOWN, uBldEng, Controls, uBldObj, ustage,
  ubldMath, utrend, uaxis, uturbina, uBldCompProc, dialogs, uCompaundFrame,
  uBlInterfaceFrame, uMyMath, uCommonTypes, inifiles, uPoint, uCommonMath, Spin,
  uerrorproc, mathfunction, uPage;

type

  SensorStruct = class
    skipblade:boolean;
    // закон пропуска лопаток
    SkipType:integer;
    // Индекс лопатки
    Blade:integer;
    // период пропуска
    i:integer;
    // пропустить первых n импульсов
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
    SName: TEdit;
    SLabel: TLabel;
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
    // отображаемая ступень
    stage:cstage;
    cursensor:csensor;
    // точность преобразования кривой на графике в последовательность отрезков
    prec:integer;
    // хранит настройки генерации импульсов по каждому датчику
    sensorStructs:tstringlist;
    OnLvChange:boolean;
    m_tahoTrend, m_STrend:ctrend;
  private
    procedure showstage(s:cstage);
    procedure showCfg;
    // генерит массив импульсов таходатчика
    procedure generateConstTaho(s:csensor);
    // процедура генерит тахо
    procedure generateTaho(s:csensor);
    // сгенерить импульсы на датчиках
    procedure generateSensorsImpuls(stage:cstage);
    // сгенерить импульсы на датчик за оборот
    procedure generateTurnImpuls(t1,t2:stickdata;s:csensor);
    // получить значение вибрации в градусах
    function getVibrationLevel(time:single):single;
    // перечислить тахо датчики и сгенерить для них импульсы по данным формы
    procedure enumTaho(stage:cstage);
    // процедура генерит данные в зависимости от настройки формы
    procedure generateData;
    // сохраняет сигнал чарта в текстовый файл
    procedure SaveChart;
    // загрузить сигнал чарта из файла
    procedure LoadChart;
    procedure showsensor(s:csensor);
    procedure SetSensor(s:csensor);
    // проверка нужно ли отбросить импульс с индексом ind по датчику
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
  //Это скорее всего не нужно, просто перестраховка.
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
  // точность сохранения флотов чарта
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
  // точность преобразования кривых на графике в последовательность отрезков
  // (число разбиений между двумя соседними точками если безье)
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
  // время оборота
  dt:=decticks(t1,t2);
  // число тиков в градусе
  degT:=dt.Data/360;
  stage:=cstage(s.stage);
  for I := 0 to stage.BladeCount - 1 do
  begin
    // путь который должна пройти лопатка до датчика
    pos:=EvalBladePath(s.pos,stage.shape.Blades[i]);
    // ожидаемое время прихода импульса
    tick:=EvSensorTickInTurn(t1,degt,pos);
    t:=TickToSec(tick);
    // если датчик периферийный
    // или корневой и стоит галочка генерить вибрацию по корневым датчикам
    // и лопатка помечена как вибрируемая
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
  // проход по датчикам ступени
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
      // проход по всем оборотам и генерация на каждом обороте импульсов от лопаток на датчик
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
  // проход по ступеням
  for i := 0 to t.StageCount - 1 do
  begin
    stage:=t.GetStage(i);
    // сгенерить импульсы от тахо датчиков
    enumTaho(stage);
    // генерим импульсы по всем датчикам
    generateSensorsImpuls(stage);
  end;
end;

constructor TGeneratorForm.create(aowner:tcomponent);
begin
  inherited;
  initChart:=false;
  initBladesLV(bladesLV);
  m_tahoTrend:=TahoChart.activetrend;
  if m_tahoTrend=nil then
  begin
    m_tahoTrend:=cpage(TahoChart.activePage).activeAxis.AddTrend;
    m_tahoTrend.name:='Taho';
  end;
  m_STrend:=VibrationChart.activetrend;
  if m_STrend=nil then
  begin
    m_STrend:=cpage(VibrationChart.activePage).activeAxis.AddTrend;
    m_STrend.name:='Sensor';
  end;
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
  // разница в секундах между двумя соседними точками на графике
  // при вычислении наклона (касательной)
  dtime:single;
  // две соседние точки при конвертации кривой в безье
  line:frect;
  lp,rp:cBeziePoint;
  // текущая частота в цикле генерации тахо сигнала
  curfreq,
  // текущее время в цикле генерации тахо сигнала
  curt,
  // время до следующего тика
  curdt,
  // максимальная частота
  fmax,
  // максимальное время
  tmax,
  // ускорение
  a,
  // часть оборота, которая была пройдена, до того как частота опять изменилась
  part:single;
  // время оборота
  root:point2;
  // число корней в уравнении V0*t+(a*t^2)/2
  rootcount:integer;
begin
  // ссылка на чарт описывающий форму тахо
  trend:=ctrend(tahoChart.activetrend);
  if trend=nil then exit;
  
  // получаем максимальную частоту в чарте
  fmax:=cpage(tahochart.activepage).activeAxis.max.y;
  // получаем максимальное время в чарте
  tmax:=cpage(tahochart.activepage).activeAxis.max.x;
  // получаем ссылку на массив тиков и очищаем его
  ticks:=s.chan.ticks;
  ticks.clear;
  // часть оборота, которая была пройдена, до того как частота опять изменилась
  part:=0;
  // добавляем импульсы в массив тахо датчика, пока не вышли за пределы
  // диапазона генерируемого сигнала
  while (curt<tmax) do
  begin
    if curt<trend.GetBound.TopRight.x then
    begin
      line:=trend.GetLoHi_(curt,lp,rp,index);
      // шаг разбиения сплайна на отрезки
      dtime:=(line.TopRight.x - line.BottomLeft.x)/(prec*2);
      curFreq:=trend.GetY(curt);
      a:=trend.GetTangent(curt, dtime);
    end
    else
    begin
      curFreq:=trend.GetBound.TopRight.y;
      a:=0;
    end;
    // промежуток времени который пройдет за оборот v0*t+at^2/2 = S(один оборот, = 1)
    // из уравнения находим время оборота
    // part - часть оборота которая была пройдена на предыдущем участке.
    // a - ускорение (изменение частоты), оно же касательная к графику
    // касательная к крафику.
    // находим время прохождения следующего оборота
    root:=SqRoot(a/2, curFreq,(-1 + part), rootcount);
    // время в секундах до очередного тика
    curDT:=root.x;
    // если следующий тик не выбивается за границы участка где частота не успела
    // изменить ускорение при заданной точности разбиения сплайна
    if ((curt + curdt)<=curt+dtime) and (rootcount<>0) then
    begin
      part:=0;
      curt:=curt + curdt;
      // время прихода нового импульса на тахо датчик
      tick:=SecToTick(curt);
      // добавляем импульс в массив таходатчика
      ticks.add(tick);
    end
    else
    // так как за время пока ускорение не измениться не спевает произойти оборот
    // вычисляем часть оборота которую пройдет турбина
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
  // Число оборотов
  TurnCount:=round(freqFE.FloatNum*SignalLengthFE.FloatNum);
  // получаем ссылку на массив тиков
  ticks:=s.chan.ticks;
  ticks.clear;
  // Постоянная частота вращения - все времена в массиве оборотов равны
  t2.Data:=0;
  t2.OverflowCount:=0;
  // Время одного оборота
  dT:=trunc(CardFreq/(freqFE.FloatNum));
  for I := 0 to turncount - 1 do
  begin
    t1:=t2;
    t2:=addtick(t1,dt);
    // t1, t2 начало и конец оборота
    tick:=EvSensorTickInTurn(t1,t2,s.pos);
    ticks.add(tick);
    // Увеличение частоты на каждом обороте (уменьшаем время следующего оборота)
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
  TahoChart.imagelist:=e.images_16;
  VibrationChart.imagelist:=e.images_16;
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

// добавляет к ступеням массивы битов показывающих нужно ли генерит вибрации для лопаток
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
  cursensor:=nil;
  sensorStructs:=tstringlist.Create;
  sensorStructs.Sorted:=true;
  PrepareStages(eng);
  showCfg;
  result:=inherited showmodal;
  if result=mrok then
  begin
    // сгенерить импульсы на таходатчиках
    generateData;
    // отфильтровать импульсы
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
      // Вот сюда попадаем только при изменении чекбокса,
      // причём любым способом, хоть мышкой хоть программно.
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
  sname.text:=s.name;
  sname.Color:=clwindow;
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
  if s=nil then
  begin
    sname.Text:='Не выбран датчик';
    sname.Color:=clPink;
    exit;
  end;

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
  // пишем время записи
  f.WriteFloat(saveSection, LengthKey, SignalLengthFE.FloatNum);
  // пишем частоту тахо в случае постоянного закона
  f.WriteFloat(saveSection, FreqKey, freqFE.FloatNum);
  // пишем флаг генерации вибрации по корневым датчикам
  f.Writebool(saveSection, GenRootKey, vibrrootcb.checked);
  // пишем закон изменения тахо
  f.WriteInteger(saveSection, TahoType, tahocb.ItemIndex);
  // пишем закон изменения вибрации
  f.WriteInteger(saveSection, VibrationType, VibrationTypecb.ItemIndex);
  // пишем частоту вибрации в случае синусного закона
  f.WriteFloat(saveSection, VibrationFreq, VibrationFloatEdit.FloatNum);
  // пишем амплитуды вибрации при синусаидальном законе
  f.WriteFloat(saveSection, VibrationValue, ValueEdit.FloatNum);
  // точность преобразования кривых на графике в последовательность отрезков
  // (число разбиений между двумя соседними точками если безье)
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
  // пишем время записи
  SignalLengthFE.FloatNum:=f.ReadFloat(saveSection, LengthKey, 10);
  // пишем частоту тахо в случае постоянного закона
  freqFE.FloatNum:=f.readFloat(saveSection, FreqKey, 50);
  // пишем флаг генерации вибрации по корневым датчикам
  vibrrootcb.checked:=f.ReadBool(saveSection, GenRootKey, false);
  // пишем закон изменения тахо
  tahocb.ItemIndex:=f.ReadInteger(saveSection, TahoType, c_const);
  // пишем закон изменения вибрации
  VibrationTypecb.ItemIndex:=f.ReadInteger(saveSection, VibrationType, c_sin);
  // пишем частоту вибрации в случае синусного закона
  VibrationFloatEdit.FloatNum:=f.ReadFloat(saveSection, VibrationFreq, 1);
  // пишем амплитуды вибрации при синусаидальном законе
  ValueEdit.FloatNum:=f.ReadFloat(saveSection, VibrationValue, 1);
  // точность преобразования кривых на графике в последовательность отрезков
  // (число разбиений между двумя соседними точками если безье)
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
  // считываем тип вершины
  if buf='corner' then
    bp.smooth:=false
  else
    bp.smooth:=true;
  // считываем координаты вершины
  buf:=GetSubString(str,';',24,index);
  bp.point.x:=strtofloat_(buf,'.');
  // считываем координаты вершины
  buf:=GetSubString(str,'/',index+3,index);
  bp.point.y:=strtofloat_(buf,'.');;
  if bp.smooth then
  begin
    // считываем координаты вершины
    buf:=GetSubString(str, ';', index+15, index);
    bp.left.x:=strtofloat_(buf,'.');;
    // считываем координаты вершины
    buf:=GetSubString(str, '/', index+3, index);
    bp.left.y:=strtofloat_(buf,'.');
    // считываем координаты вершины
    buf:=GetSubString(str, ';',index+16, index);
    bp.right.x:=strtofloat_(buf,'.');
    // считываем координаты вершины
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
  if eng=nil then
    exit;

  filename:=eng.PathMng.findCfgPathFile(ChartCfgName);
  f.LoadFromFile(filename);
  // сохраняем данные настройки чарта для задания тахо в текстовой форме
  str:=f.Strings[0];
  res:=Pos('TahoChart',str);
  if (res<>0) then
  begin
    trend:=tahochart.activetrend;
    trend.Clear;
    // получаем число точек в чарте
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
    // сохраняем данные настройки чарта для задания тахо в текстовой форме
    str:=f.Strings[i];
    res:=Pos('VibrationChart',str);
    if (res<>0) then
    begin
      // получаем число точек в чарте
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
    // сохраняем данные настройки чарта для задания тахо в текстовой форме
    str:='TahoChart'+' Число точек:'+inttostr(trend.count);
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
  // сохраняем данные настройки чарта для задания закона вибрации в текстовой форме
  trend:=VibrationChart.activetrend;
  if trend<>nil then
  begin
    str:='VibrationChart'+' Число точек:'+inttostr(trend.count);
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
  // пропуск первых n тиков
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
      // если на данном обороте надо сгенерить пропуск
      if frac((turn+1)/obj.i)=0 then
      begin
        // получаем индекс импульса внутри оборота
        blade:=ind - turn*stage.BladeCount;
        // вычисляем номер лопатки
        blade:=getBladeNumber(s.skipblade,blade,stage.bladecount);
        // если по данной лопатке генеряться пропуски
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
