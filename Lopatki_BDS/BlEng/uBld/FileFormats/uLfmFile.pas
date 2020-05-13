// В юните описаны структуры и классы для генерации, загрузки, сохранения
// данных Bld файла
unit uLfmFile;

interface
  uses
    Messages, ComCtrls, classes, SysUtils, uBinFile, upair, ubldobj, uturbina,
    usensor, ustage, dialogs, ubldeng;

  type

  cLFMSensor = class
    name:string;
    chun:byte;
    objtype:byte;
  end;

  cLFMPair = class
    name:string;
    root:smallint;
    Peak:smallint;
    skipblades:smallint;
    base:single;
    Tahoshift:single;
    BladesPointers:array of integer;
    Impuls:array of integer;
    Checked:boolean;
    Fi:single;
  end;

  cLFMStage = class
    name:string;
    stagetype:byte;
    diametr:single;
    resonanse:single;
    bladenumber:byte;
    pairscount:byte;
    orderblade:boolean;
    kfSigma:single;
    countHarm:shortint;
    orderHarm:array of integer;
    f1:single;
    LimStressResonance:single;
    LimStressStill:single;
    bin:single;
    bout:single;
    pairlist:tstringlist;
    tahocomb:shortint;
  public
    constructor create;
    destructor destroy;
  end;

  cConfiFile_lfm = class
  private
    eng:cbldeng;
    // Файл записанный с данной конфигурацией
    recentFile,
    // Читаемый файл
    filename:string;
    f:file;
  public
    stages:tstringlist;
    sensors:tstringlist;
  private
    procedure readStages;
    procedure readSensors;
    procedure deleteData;
    // считать lfm файл в специиальную структуру
    procedure readFile(name:string);
    // преобразовать к человеческому формату
    function ConvertToEngine:cbldobj;
    function readData(name:string; peng:cbldeng):cbldobj;
  public
    constructor Create;
    destructor destroy;
  end;

  function readLFMData(eng:cbldeng; name:string):cbldobj;
  // записать конфигурацию
  procedure WriteLFMData(eng:cbldeng; filename:string);

implementation

constructor cConfiFile_lfm.Create;
begin
  stages:=tstringlist.create;
  sensors:=tstringlist.create;
end;

destructor cConfiFile_lfm.destroy;
begin
  deletedata;
end;

procedure cConfiFile_lfm.deleteData;
var
  i:integer;
  stage:cLFMStage;
  sensor:cLFMSensor;
begin
  for i:= 0 to stages.Count - 1 do
  begin
    stage:=clfmstage(stages.Objects[i]);
    stage.Destroy;
  end;
  stages.Destroy;
  for i:= 0 to sensors.Count - 1 do
  begin
    sensor:=clfmsensor(sensors.Objects[i]);
    sensor.Destroy;
  end;
  sensors.Destroy;
end;

procedure cConfiFile_lfm.readStages;
var
  i,count:integer;
  lReaded:cardinal;
  stage:clfmstage;
  {function ReadBlRecCfg:cBlRecCfg;
  begin

  end;}
  // Считать данные пары
  function ReadPair(bladecount:integer):cLFMPair;
  var i:integer;
  begin
    result:=cLFMPair.create;
    result.name:=ReadTypedAnsiString(f);
    result.root:=ReadTypedInt(f);
    result.Peak:=ReadTypedInt(f);
    result.skipblades:=ReadTypedInt(f);
    result.base:=ReadTypedSingle(f);
    result.Tahoshift:=ReadTypedSingle(f);
    setlength(result.BladesPointers,bladecount);
    setlength(result.Impuls,bladecount);
    for I := 0 to bladecount - 1 do
    begin
      result.BladesPointers[i]:=readTypedint(f);
      result.Impuls[result.BladesPointers[i]]:=i;
    end;
    result.Checked:=readTypedbool(f);
    result.Fi:=readTypedsingle(f);
  end;
  // Считать данные ступени
  function ReadStage:cLFMStage;
  var
    i:integer;
    pair:clfmpair;
  begin
    result:=cLFMStage.Create;
    result.name:=ReadTypedAnsiString(f);
    result.stagetype:=ReadTypedInt(f);
    result.diametr:=ReadTypedSingle(f);
    result.resonanse:=ReadTypedSingle(f);
    result.bladenumber:=ReadTypedInt(f);
    result.pairscount:=ReadTypedInt(f);
    result.orderblade:=ReadTypedBool(f);
    result.kfSigma:=ReadTypedSingle(f);
    result.countHarm:=ReadTypedInt(f);
    if result.countHarm>0 then
    begin
      setlength(result.OrderHarm,result.countHarm);
      for I := 0 to result.countHarm - 1 do
      begin
        result.OrderHarm[i]:=ReadTypedInt(f);
      end;
    end;
    result.f1:=ReadTypedSingle(f);
    result.LimStressResonance:=ReadTypedSingle(f);
    result.LimStressStill:=ReadTypedSingle(f);
    result.bin:=ReadTypedSingle(f);
    result.bout:=ReadTypedSingle(f);
    for i := 0 to result.pairscount - 1 do
    begin
      pair:=ReadPair(result.bladenumber);
      result.pairlist.AddObject(pair.name,pair);
    end;
    result.tahocomb:=readTypedint(f);
  end;
begin
  count:=readTypedInt(f);
  for I := 0 to count - 1 do
  begin
    stage:=readStage;
    stages.AddObject(stage.name,stage);
  end;
end;

procedure cConfiFile_lfm.readSensors;
var
  i:integer;
  count:shortint;
  lReaded:cardinal;
  sensor:cLFMSensor;
  function ReadSensor:cLFMSensor;
  var
    nameLen,i:byte;
    Ch:array of char;
  begin
    result:=cLFMSensor.Create;
    result.Name:=ReadTypedAnsiString(f);
    result.Chun:=ReadTypedInt(f);
    result.objType:=ReadTypedInt(f);
  end;
begin
  count:=ReadTypedInt(f);
  for I := 0 to count - 1 do
  begin
    sensor:=readSensor;
    sensors.AddObject(sensor.name,sensor);
  end;
end;

procedure cConfiFile_lfm.readFile(name:string);
var str:string;
    val:byte;
begin
  filename:=name;
  // Начинаем читать файл
  AssignFile(f,name);
  // Проверка, что файл существует
  if Assigned(@f) then
  begin
    reset(f,1); // Длина одной записываемой единицы.
    str:=ReadString(f,4);
    str:=LowerCase(Str);
    if str<>'@dfm' then
      exit;
    recentFile:=ReadTypedAnsiString(f);
    readSensors;
    readStages;
    CloseFile(f);
  end;
end;


function cConfiFile_lfm.readData(name:string; peng:cbldeng):cbldobj;
begin
  eng:=peng;
  readFile(name);
  result:=ConvertToEngine;
end;

function cConfiFile_lfm.ConvertToEngine:cbldobj;
var
  i, pairscounter, sensorscounter:integer;
  turbina:cturbine;
  stage:cstage;
  sensor:csensor;
  pair:cpair;
  lfmPair:clfmPair;
  lfmsensor:clfmsensor;
  lfmstage:clfmstage;
begin
  eng.Events.active:=false;
  turbina:=cturbine.create;
  turbina.name:=extractfilename(filename);
  eng.lastfile:=recentFile;
  // читаем ступени
  // читаем датчики
  for sensorscounter := 0 to sensors.Count - 1 do
  begin
    lfmSensor:=clfmsensor(sensors.Objects[sensorscounter]);
    sensor:=csensor.create;
    sensor.name:=lfmSensor.name;
    sensor.chanNumber:=lfmSensor.chun;
    sensor.sensortype:=lfmSensor.objtype;
    eng.Add(sensor);
    lfmSensor.name:=sensor.name;
  end;
  for I := 0 to stages.Count - 1 do
  begin
    stage:=cstage.create;
    lfmstage:=clfmstage(stages.Objects[i]);
    stage.name:=lfmstage.name;
    stage.diametr:=lfmstage.diametr;
    stage.bladecount:=lfmstage.bladenumber;
    for pairscounter := 0 to lfmstage.pairlist.Count - 1 do
    begin
      lfmPair:=clfmpair(lfmstage.pairlist.Objects[pairscounter]);
      pair:=cpair.create;
      pair.name:=lfmpair.name;
      lfmSensor:=clfmSensor(sensors.Objects[lfmpair.root]);
      sensor:=csensor(eng.getobj(lfmSensor.name));
      pair.AddSensor(sensor);
      stage.AddSensor(sensor);
      stage.AddPair(pair);
      lfmSensor:=clfmSensor(sensors.Objects[lfmpair.Peak]);
      sensor:=csensor(eng.getobj(lfmSensor.name));
      pair.AddSensor(sensor);
      stage.AddSensor(sensor);
      stage.AddPair(pair);
    end;
    turbina.AddStage(stage);
  end;
  eng.Events.active:=true;  
  eng.Add(turbina,nil);
  result:=turbina;
end;

constructor cLFMStage.create;
begin
  pairlist:=tstringlist.create;
end;

destructor cLFMStage.destroy;
var
  i:integer;
  pair:clfmpair;
begin
  for I := 0 to pairlist.count - 1 do
  begin
    pair:=clfmpair(pairlist.objects[i]);
    pair.Destroy;
  end;
  pairlist.Destroy;
end;

function readLFMData(eng:cbldeng;name:string):cbldobj;
var loader:cConfiFile_lfm;
begin
  if fileexists(name) then
  begin
    loader:=cConfiFile_lfm.Create;
    result:=loader.readData(name, eng);
    loader.destroy;
  end
  else
  begin
    result:=nil;
    showmessage('файл '+name+' не найден');
  end;
end;

procedure writesensors(var f:file;t:cturbine);
var
  i,j:integer;
  count:shortint;
  lReaded:cardinal;
  sensor:csensor;
  stage:cstage;
  procedure WriteSensor(s:csensor);
  var
    nameLen,i:byte;
    Ch:array of char;
  begin
    writeTypedString(f, s.name,byte(vastring));
    writetypedint(f,sensor.channumber,byte(vaint8));
    writetypedint(f,sensor.sensortype,byte(vaint8));
  end;
begin
  writetypedint(f,t.SensorsCount,byte(vaint8));
  for I := 0 to t.stageCount - 1 do
  begin
    stage:=t.getstage(i);
    for j := 0 to stage.SensorsCount - 1 do
    begin
      sensor:=csensor(stage.GetSensor(j));
      writeSensor(sensor);
    end;
  end;
end;


procedure WriteStages(var f:file; t:cturbine);
var
  i,count:integer;
  stage:cstage;
  // Считать данные пары
  procedure WritePair(var f:file; p:cpair);
  var i, bladecount:integer;
      s:csensor;
      st:cstage;
      Tahoshift, base, Fi:single;
      Impuls,BladesPointers:array of integer;
      checked:boolean;
  begin
    if p.SensorsCount<2 then exit;
    writeTypedString(f, p.name,byte(vastring));
    // индекс канала корневого датчика
    s:=p.GetSensor(0);
    writetypedint(f,s.channumber,byte(vaint8));
    s:=p.GetSensor(1);
    writetypedint(f,s.channumber,byte(vaint8));
    writetypedint(f,p.BladesLeft,byte(vaint8));
    base:=0;
    writetypedsingle(f,base,byte(vasingle));
    Tahoshift:=0;
    writetypedsingle(f,Tahoshift,byte(vasingle));
    st:=cstage(p.stage);
    bladecount:=st.BladeCount;
    setlength(BladesPointers,bladecount);
    setlength(Impuls,bladecount);
    for I := 0 to bladecount - 1 do
    begin
      writetypedint(f,BladesPointers[i],byte(vaint8));
    end;
    Checked:=true;
    writeTypedbool(f, checked);
    Fi:=0;
    writetypedsingle(f,fi,byte(vasingle));
  end;
  procedure writeStage(var f:file; s:cstage);
  var
    pair:cpair;
    i:byte;
    tahocomb, stagetype, countHarm:integer;
    f1, LimStressResonance, LimStressStill, bin, bout, resonanse,kfSigma:single;
    OrderHarm:array of integer;
  begin
    writeTypedString(f, s.name,byte(vastring));
    stagetype:=0;
    writetypedint(f, stagetype, byte(vaint8));
    WriteTypedSingle(f,s.diametr,byte(vasingle));
    resonanse:=0;
    WriteTypedSingle(f,resonanse,byte(vasingle));
    writetypedint(f, s.BladeCount, byte(vaint8));
    writetypedint(f, s.paircount, byte(vaint8));
    writeTypedBool(f,s.orderblade);
    kfSigma:=0;
    WriteTypedSingle(f,kfSigma,byte(vasingle));
    countHarm:=0;
    writetypedint(f, countHarm, byte(vaint8));
    if countHarm>0 then
    begin
      for I := 0 to countHarm - 1 do
      begin
        writetypedint(f, OrderHarm[i], byte(vaint8));
      end;
    end;
    f1:=0;
    WriteTypedSingle(f,f1,byte(vasingle));
    LimStressResonance:=0;
    WriteTypedSingle(f,LimStressResonance,byte(vasingle));
    LimStressStill:=0;
    WriteTypedSingle(f,LimStressStill,byte(vasingle));
    bin:=0;
    WriteTypedSingle(f,bin,byte(vasingle));
    bout:=0;
    WriteTypedSingle(f,bout,byte(vasingle));
    for i := 0 to s.paircount - 1 do
    begin
      pair:=s.GetPair(i);
      writePair(f, pair);
    end;
    tahocomb:=0;
    WriteTypedint(f,tahocomb,byte(vaint8));
  end;
begin
  count:=t.stagecount;
  writetypedint(f,count,byte(vaint8));
  for I := 0 to count - 1 do
  begin
    stage:=t.getstage(i);
    WriteStage(f,stage);
  end;
end;

procedure WriteLFMData(eng:cbldeng; filename:string);
var
  f:file;
  str:string;
  t:cturbine;
  stage:cstage;
begin
  // получить ссылку на турбину
  t:=cturbine(eng.getTurbine);
  if t=nil then exit;
  stage:=t.GetStage(0);
  if stage=nil then exit;
  // Начинаем читать файл
  AssignFile(f,filename);
  // Проверка, что файл существует
  if Assigned(@f) then
  begin
    Rewrite(f,1); // Длина одной записываемой единицы.
    //reset(f,1); // Длина одной записываемой единицы.
    str:='@dfm';
    writestring(f,str);
    // получить  имя последнего считанного файла
    str:=eng.lastfile;
    WriteTypedString(f,str, byte(vastring));
    writesensors(f, t);
    WriteStages(f, t);
    CloseFile(f);
  end;
end;

end.
