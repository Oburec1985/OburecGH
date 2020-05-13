unit uViewDataForm;

interface

uses
  Windows, SysUtils, Forms, StdCtrls,Classes, Controls,ComCtrls,Menus, dialogs,
  uOglChart, DCL_MYOWN, uBtnListView, uoglprocess,  // компоненты
  ubldfile,
  uBldService,
  ubldmath,
  uMytypes_,
  uTickData,
  uDensityForm,
  uXYTrendPos,
  ufilterturnsform, Spin,
  upair;

type
  TViewDataForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cGlChart1: cGlChart;
    SensorsListView: TBtnListView;
    Label1: TLabel;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    EvalDensityMenu: TMenuItem;
    N3: TMenuItem;
    SortTicksMenu: TMenuItem;
    EvalXYTrend: TMenuItem;
    BladeNumberSpinEdit: TSpinEdit;
    Label3: TLabel;
    BladePosLabel: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    PeakFloatEdit: TFloatEdit;
    FilterTurnsMenu: TMenuItem;
    procedure FilterTurnsMenuClick(Sender: TObject);
    procedure cGlChart1AfterGetData(ymin, ymax: Single; sender: cTrend);
    procedure BladeNumberSpinEditChange(Sender: TObject);
    procedure EvalXYTrendClick(Sender: TObject);
    // Сортирует массив данных
    procedure SortTicksMenuClick(Sender: TObject);
    // Отрисовка плотности распределения пиков bldFile-а
    procedure EvalDensityMenuClick(Sender: TObject);
  private
    { Private declarations }
    // Получить ссылку на выбранный в таблице датчик
    function GetSelectedSensor:cSensor;
    // Получить номер выделенной лопатки по определленной ступени
    function GetSelectedBladePos:single;
    // Процедура сохраняет массивы с выделенными тиками по каждому из датчиков в
    // поле trends:array of cpoints; где каждый элемент массива соответствует
    // индексу датчика в паспорте BldFile-а
    procedure formGetTicks(const p_bldfile:cbldFileGen);
    // Отрисовать плотность распределения пиков bldFile-а. Отрисовываемые данные
    // передаются через ar
    procedure DrawDensity(var ar:cpoints2);
    // передаются через ar
    procedure DrawArray(var ar:cpoints2);
    // Отрисовать временной тренд по определленной лопатке
    procedure drawXYTrend(showform:boolean);
    // Обновить амплитуду сигнала
    procedure updatePeak(ymin,ymax:single);
  public
    function showmodal(const bldFile:cbldFileGen):integer;
    { Public declarations }
  private
    lastalg:string;
    bldfile:cbldfilegen;
  end;
var
  ViewDataForm: TViewDataForm;

const AlgXYTrend = 'Просмотр вибрации по лопатке';
const AlgDens = 'Просмотр статистики';

implementation

{$R *.dfm}
// Процедура сохраняет массивы с выделенными тиками по каждому из датчиков в
// поле trends:array of cpoints; где каждый элемент массива соответствует
// индексу датчика в паспорте BldFile-а
procedure TViewDataForm.formGetTicks(const p_bldfile:cbldFileGen);
var impulscount,i:integer;
    li:tlistitem;
    str:string;
begin
  bldFile:=p_bldFile;
  showSensorsInLV(SensorsListView,bldfile);
end;
// передаются через ar
procedure TViewDataForm.cGlChart1AfterGetData(ymin, ymax: Single;
  sender: cTrend);
begin
  updatePeak(ymin,ymax);
end;

procedure TViewDataForm.DrawArray(var ar:cpoints2);
var
  ltrend:ctrend;
  i,j,len:integer;
  step:single;
begin
  cGlChart1.Chart.gettrend(0,ltrend);
  ltrend.clear;
  len:=length(ar.ar);
  ltrend.GetData(ar.ar);
  cGlChart1.Chart.FullZoom(true,true);
end;
// Отрисовать плотность распределения пиков bldFile-а.
procedure TViewDataForm.DrawDensity(var ar:cpoints2);
var ltrend:ctrend;
    drawar:array of point2;
    i,j,len:integer;
    step:single;
begin
  cGlChart1.Chart.gettrend(0,ltrend);
  ltrend.clear;
  len:=length(ar.ar);
  setlength(drawar,len*2);
  step:=ar.ar[1].x - ar.ar[0].x;
  for I := 0 to len - 1 do
  begin
    for j := 0 to 1 do
    begin
      drawar[2*i+j].x:=ar.ar[i].x+(step-(step/1000))*j;
      drawar[2*i+j].y:=ar.ar[i].y;
    end;
  end;
  ltrend.GetData(DrawAr);
  cGlChart1.Chart.FullZoom(true,true);
end;
// Получить ссылку на выбранный в таблице датчик
function TViewDataForm.GetSelectedBladePos:single;
var
  blade:integer;
  str:string;
  bladepos:single;
  sensor:cSensor;
  stage:cstage;
begin
  // Получить выделенный в таблице датчик
  sensor:=GetSelectedSensor;
  if sensor.mChanNumber>255 then exit;
  // Находим ступень на которой находится выделенный датчик
  stage:=bldfile.GetStageByName(sensor.stagename);
  blade:=BladeNumberSpinEdit.Value-1;
  if (blade<0) or (blade>(stage.bladenumber-1)) then
  begin
    result:=-1;
    showmessage('Такой лопатки не существует');
    exit;
  end;
  // Находим позицию выделенной в форме лопатки
  result := stage.blades[blade].offset;
end;
// Процедура по вызову расчета и отрисовки статистики выделенного в
// SensorsListView канала. В случае неудачи, имя датчика равно ''
function TViewDataForm.GetSelectedSensor:cSensor;
var li:tlistitem;
    str:string;
begin
  li:=SensorsListView.Selected;
  if li=nil then
  begin
    result.mChanName:='';
    result.mChanNumber:=65000;
    showmessage('Необходимо выбрать канал, по которому будет строиться статистика!');
    exit;
  end;
  SensorsListView.GetSubItemByColumnName(ColSensorName,li,str);
  result:=bldfile.GetSensor(str);
end;
// Процедура по вызову расчета и отрисовки статистики выделенного в
// SensorsListView канала.
procedure TViewDataForm.EvalDensityMenuClick(Sender: TObject);
var
    i,len,tahoind,sensorind,
    order:integer; // Число разрядов (столбиков гистограммы) при расчете статистики
    ar:cpoints2;
    sensor:cSensor;
begin
  lastalg:=AlgDens;
  sensor:=getselectedSensor;
  if (sensor.mChanName='') then exit;
  sensorind:=bldfile.getsensorind(sensor.mChanName);
  tahoind:=bldFile.GetSensorInd(bldFile.GetStageTaho(sensor.stagename).mChanName);
  // Вычисляем массив статистику канала с номером sensorind и сохраняем в
  // массив ar
  ar:=cpoints2.create;
  if DensityForm.ShowModal = mrok then
  begin
    order:=DensityForm.OrderSpinEdit.Value;
    EvalDensity(bldfile.trends[tahoind].ticks, sensorind, bldfile, order, ar);
    DrawDensity(ar);
    ar.destroy;
  end;
end;
// Отсортировать пики по времени
procedure TViewDataForm.SortTicksMenuClick(Sender: TObject);
var i:integer;
    sensor:cSensor;
begin
  sensor:=getselectedSensor;
  if sensor.mChanName='' then exit;
  i:=bldfile.getsensorind(sensor.mChanName);
  i:=SortTickArray(bldfile.trends[i].ticks.ticks);
  showmessage('Число перестановок(инверсий) = '+inttostr(i));
end;

function TViewDataForm.showmodal(const bldFile:cbldFileGen):integer;
var i,len:integer;
    black,blue:point3;
    ltrend:ctrend;
    ar:array of point2;
begin
  black.x:=0;black.y:=0;black.z:=0;
  blue.x:=0.3;blue.y:=0.3;blue.z:=0.7;
  SensorsListView.Clear;
  // процедура выделяет массивы тиков по каждому из каналов
  formGetTicks(bldfile);
  len:=length(bldfile.trends);
  for I := 0 to len - 1 do
  begin
    if bldfile.Sensors.sensors[i].mChanType=c_rot then
    begin
      EvalTaxo(bldfile,i,0,bldfile.trends[i]);
      cGlChart1.Chart.clear;
      cGlChart1.Chart.AddTrend(black,blue);
      cGlChart1.Chart.gettrend(0,ltrend);
      ar:=@bldfile.trends[i].ar.ar[0];
      len:=length(ar);
      ltrend.GetData(ar);
      ltrend.m_trend.visible:=true;
      // Запрещаем рисовать точки тренда и запрещаем двигать точки
      ltrend.m_trend.m_drawpoints:=false;
      cGlChart1.Chart.m_SelectOpts.m_SelectMode:=false;
      cGlChart1.Chart.FullZoom(true,true);
      break;
    end;
  end;
  inherited ShowModal;
end;

// Отрисовать временной тренд по определленной лопатке
procedure TViewDataForm.drawXYTrend(showform:boolean);
var sensor:cSensor;
    stage:cstage;
    blade,tahoind:integer;
    ar:cpoints2;
begin
  if getselectedbladepos<>-1 then
  begin
    sensor:=getselectedsensor;
    stage:=bldFile.GetStageByName(sensor.stagename);
    tahoind:=bldFile.GetSensorInd(bldFile.GetStageTaho(sensor.stagename).mChanName);
    blade:=BladeNumberSpinEdit.Value-1;
    ar:=cpoints2.Create;
    if showform then
      XYTrendForm.showmodal(blade,bldfile,sensor,bldfile.trends[tahoind].ticks.ticks,ar)
    else
      XYTrendForm.EvalTrend(blade,bldfile,sensor,bldfile.trends[tahoind].ticks.ticks,ar);
    DrawArray(ar);
    ar.destroy;
  end;
end;
// При изменении номера лопатки должен быть выведен тренд вибрации
// по лопатке
procedure TViewDataForm.BladeNumberSpinEditChange(Sender: TObject);
var bladepos:single;
begin
  bladepos:=GetSelectedBladePos;
  if bladepos<>-1 then
  begin
    BladePosLabel.caption:='Положение лопатки = '+floattostr(bladepos);
  end
  else
  begin
    BladePosLabel.caption:='Лопатки с таким номером на выбранной ступени нет';
    exit;
  end;  
  if (lastAlg=AlgXYTrend) then
    drawXYTrend(false);
end;
//
procedure TViewDataForm.EvalXYTrendClick(Sender: TObject);
begin
  lastAlg:=AlgXYTrend;
  drawXYTrend(true);
end;

procedure TViewDataForm.FilterTurnsMenuClick(Sender: TObject);
var sensor:cSensor;
    stage:cstage;
    sensorind, tahoind:integer;
    filteredticks,filteredtaho:cticks;
    break:array of integer;
begin
  sensor:=getselectedsensor;
  stage:=bldFile.GetStageByName(sensor.stagename);
  tahoind:=bldFile.GetSensorInd(bldFile.GetStageTaho(sensor.stagename).mChanName);
  sensorind:=bldfile.getsensorind(sensor.mChanName);
  filteredticks:=cticks.create;
  filteredtaho:=cticks.create;
  // Применяем алгоритм фильтрации
  FilterTurnsForm.showmodal(length(stage.blades),
                            bldfile.trends[tahoind].ticks.ticks,
                            bldfile.trends[sensorind].ticks.ticks,
                            filteredticks,
                            filteredtaho,
                            @break);
end;

procedure TViewDataForm.updatePeak(ymin,ymax:single);
var ltrend:ctrend;
begin
  PeakFloatEdit.FloatNum:=ymax-ymin;
end;

end.
