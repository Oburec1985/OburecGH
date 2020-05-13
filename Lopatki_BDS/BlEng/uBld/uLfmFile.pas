// В юните описаны структуры и классы для генерации, загрузки, сохранения
// данных Bld файла
unit uLfmFile;

interface
 uses
   Messages, ComCtrls, classes, SysUtils, uBldFile, uBinFile, upair;

 type
 cConfiFile_lfm = class
 private
   // Файл записанный с данной конфигурацией
   recentFile,
   // Читаемый файл
   filename:string;
   f:file;
 public
   stages:cStageList;
   sensors:cSensorList;
 private
   procedure readStages;
   procedure readSensors;
 public
   constructor Create;
   procedure deleteData;
   procedure readFile(name:string);
 end;

implementation

constructor cConfiFile_lfm.Create;
begin
  stages:=cStageList.create;
  sensors:=cSensorList.create;
end;

procedure cConfiFile_lfm.deleteData;
begin
  stages.destroy;
  sensors.destroy;
end;

procedure cConfiFile_lfm.readStages;
var
  i,count:integer;
  lReaded:cardinal;
  function ReadBlRecCfg:cBlRecCfg;
  begin

  end;
  // Считать данные пары
  function ReadPair(bladecount:integer):cPair;
  var i:integer;
  begin
    result:=cpair.create;
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
  function ReadStage:cStage;
  var
    i:byte;
  begin
    result:=cStage.Create;
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
      result.pairlist.AddPair(ReadPair(result.bladenumber));
    end;
    result.tahocomb:=readTypedint(f);
  end;
begin
  count:=readTypedInt(f);
  for I := 0 to count - 1 do
  begin
    stages.AddStage(readStage);
  end;
end;

procedure cConfiFile_lfm.readSensors;
var
  i:integer;
  count:shortint;
  lReaded:cardinal;
  sensor:cSensor;
  function ReadSensor:cSensor;
  var
    nameLen,i:byte;
    Ch:array of char;
  begin
    result:=cSensor.Create;
    result.mChanName:=ReadTypedAnsiString(f);
    result.mChanNumber:=ReadTypedInt(f);
    result.mChanType:=ReadTypedInt(f);
  end;
begin
  count:=ReadTypedInt(f);
  for I := 0 to count - 1 do
  begin
    sensor:=readSensor;
    sensors.AddSensor(sensor);
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
    CloseFile(f); // Закрыть файл
  end;
end;

end.
