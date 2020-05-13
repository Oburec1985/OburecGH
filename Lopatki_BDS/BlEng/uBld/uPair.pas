unit uPair;

interface
uses
  ComCtrls, classes, math, sysutils,  uTickData;

type

  // структура хранит информацию об измерительном канале
  cSensor = class
    mChanNumber: word;      // Номер канала
    mAmplifier: byte;       // Усиление МФПИ
    mChanName: string;      // Номер канала
    mChanType: word;        // Тип датчика
    stagename:string;       // имя ступени на которой находится датчик
    pos:single;             // позиция датчика на турбине
  end;

  // лист который содержит список датчиков
  cSensorList = class(tstringlist)
  public
    m_cleardata:boolean;
  private
    function readSensor(index:integer):cSensor;
  public
    constructor create;
    destructor destroy;
    procedure cleardata;
    procedure AddSensor(sensor:cSensor);
    property sensors[index:integer]: cSensor read readSensor;
  end;

  cPair = class
    // имя пары
    name:string;
    // корневой датчик
    root:integer;
    // периферийный датчик
    peak:integer;
    // пропустить лопаток
    skipblades:integer;
    // растояние между датчиками
    base:single;
    // Смещение тахо
    Tahoshift:single;
    // массив указателей на лопатки (сопоставление какой импульс соответствует какой лопатке)
    // длина равна BladeCount
    BladesPointers:array of integer;
    Impuls:array of integer;
    // включен расчет по лопатке
    Checked:boolean;
    // Расстояния между импульсами
    Fi:single;
  end;

  // лист который содержит список датчиков
  cPairList = class(tstringlist)
  private
    function readPair(index:integer):cPair;
  public
    constructor create;
    destructor destroy;
    procedure cleardata;
    procedure AddPair(pair:cPair);
    property pairs[index:integer]: cPair read readPair;
  end;

implementation

constructor cSensorList.create;
begin
  sorted:=true;
  m_cleardata:=true;
  Duplicates:=dupIgnore;
end;

destructor cSensorList.destroy;
begin
  if m_cleardata then
    self.cleardata;
end;

procedure cSensorList.AddSensor(sensor:cSensor);
begin
  addObject(inttostr(sensor.mChanNumber),sensor);
end;

function cSensorList.readSensor(index:integer):cSensor;
begin
  result:=cSensor(objects[index]);
end;

procedure cSensorList.cleardata;
var sensor:cSensor;
    i:integer;
begin
  for I := 0 to Count - 1 do
  begin
    sensor:=sensors[i];
    sensor.Destroy;
  end;
  clear;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------

constructor cPairList.create;
begin
  sorted:=true;
  Duplicates:=dupIgnore;
end;

destructor cPairList.destroy;
begin
  self.cleardata;
end;

procedure cPairList.AddPair(pair:cpair);
begin
  addObject(pair.name,pair);
end;

function cPairList.readPair(index:integer):cPair;
begin
  result:=cPair(objects[index]);
end;

procedure cPairList.cleardata;
var pair:cPair;
    i:integer;
begin
  for I := 0 to Count - 1 do
  begin
    pair:=pairs[i];
    pair.Destroy;
  end;
  clear;
end;

end.
