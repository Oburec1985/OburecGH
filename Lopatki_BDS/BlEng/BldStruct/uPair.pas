unit uPair;

interface
uses uBaseObj, controls, uBldObj, uSensor, dialogs, classes, uBaseObjTypes,
     uErrorProc, nativexml, uSensorList, sysutils, uBldGlobalStrings;

type
  cPair = class(cBldObj)
  protected
    fBladesLeft:integer;
  public
    // ������ ��������
    sensors:cbaseobjlist;
  public
    constructor create;override;
    destructor destroy;override;
     // �������� ������
    function GetSensor(name:string):cSensor;overload;
    function GetSensor(i:integer):cSensor;overload;
    // �������� ��� ������ ��� ������� ����� �������� � �������� �������
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
    // ����� ��������
    function SensorsCount:integer;
    // �������� ������
    Procedure AddSensor(sensor:csensor);overload;
    // ��� ���������� ������� �� ������ ������ ���� � engine ������ � ����� ������� � �������
    Procedure AddSensor(chan:integer);overload;
    procedure removesensor(sensor:csensor);
    procedure removesensors;
  protected
    procedure unlincMng;override;  
  protected
    function GetStageName:string;
    procedure SetStageName(str:string);
    function GetStage:cbldobj;
    procedure SetStage(s:cbldobj);
    procedure SetName(str:string);override;
    function GetMainParent:cbaseobj;override;
    procedure SetMainParent(p:cbaseobj);override;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    // �������� ���������� ����� ���������
    function getBase:single;
    function mainParentClassName:string;override;
    // ��� ������ ����� � �������� �������� ����� � engine �������
    // � ������ ������ � �������������� � ���
    property stagename:string read getStageName write SetStageName;
    property BladesLeft:integer read fBladesLeft write fBladesLeft;
    property stage:cbldobj read getstage write setstage;
  end;

  cPairList = class(cBldObj)
  public
    constructor Create;override;
    // �������� ��� ������ ��� ������� ����� �������� � �������� �������
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
  end;  

implementation
uses ustage;

constructor cPairList.create;
begin
  inherited;
  imageindex:=c_pair_img;  
end;

function cPairList.SupportedChildClass(objtype:integer):boolean;
begin
  result:=true;
  case objtype of
    c_pair:result:=true;
  else
    result:=false;
  end;
end;

function cPairList.SupportedChildClass(obj:cbaseobj):boolean;
begin
  if obj is cpair then
    result:=true
  else
    result:=false;
end;

function cPairList.SupportedChildClass(classname:string):boolean;
var strlist:tstringlist;
    i:integer;
begin
  strlist:=tStringList.Create;
  strlist.Sorted:=true;
  strlist.Add(v_Pair);
  result:=strlist.find(classname,i);
end;

constructor cPair.create;
begin
  inherited;
  helper:=false;
  imageindex:=c_pair_img;
  objtype:=c_pair;

  sensors:=cbaseobjlist.create;
  sensors.destroydata:=false;
end;

destructor cPair.destroy;
begin
  inherited;
  sensors.destroy
end;

function cPair.GetStage:cbldobj;
begin
  if parent<>nil then
    result:=cbldobj(parent.parent)
  else
    result:=nil;
end;

procedure cPair.SetStage(s:cbldobj);
var
  i:integer;
  sensor:csensor;
begin
  if s<>stage then
  begin
    for I := 0 to sensorscount - 1 do
    begin
      sensor:=getsensor(i);
      if sensor.stage<>s then
      begin
        errorSensorPair_notSameStageProc(sensor, self, eng.flags);
      end;
    end;
    cstage(s).AddPair(self);
  end;
end;

function cPair.GetStageName:string;
begin
  if parent<>nil then
    result:=parent.parentname
  else
    result:='';
end;

procedure cPair.SetStageName(str:string);
begin
  parentname:=str;
end;

function cPair.GetSensor(name:string):cSensor;
begin
  result:=csensor(sensors.getobj(name));
end;

function cPair.GetSensor(i:integer):cSensor;
begin
  result:=csensor(sensors.getobj(i));;
end;

function cPair.SensorsCount:integer;
begin
  result:=sensors.Count;
end;

Procedure cPair.AddSensor(chan:integer);
var sensor:csensor;
begin
   sensor:=csensor(eng.FindSensor(chan));
   if sensor<>nil then
   begin
     AddSensor(sensor);
   end;
end;

procedure cPair.removesensor(sensor:csensor);
begin
  sensor.DelPairRef(self);
end;


Procedure cPair.AddSensor(sensor:csensor);
begin
  if SensorsCount<2 then
  begin
    sensors.AddObj(sensor);
    sensor.AddPairRef(self);
  end
  else
    showmessage('� ���� ����� ���� ������ 2 �������!');
end;

function cPair.SupportedChildClass(objtype:integer):boolean;
begin
  result:=false;
end;

function cPair.SupportedChildClass(obj:cbaseobj):boolean;
begin
  result:=false;
end;

function cPair.SupportedChildClass(classname:string):boolean;
begin
  result:=false;
end;

procedure cPair.SetName(str:string);
var
  i:integer;
  pair:cpair;
  s:csensor;
begin
  for I := 0 to sensorsCount - 1 do
  begin
    s:=getsensor(i);
    s.pairs.RemoveObj(self);
  end;
  inherited;
  for I := 0 to sensorsCount - 1 do
  begin
    s:=getsensor(i);
    s.pairs.AddObj(self);
  end;
end;

procedure cPair.unlincMng;
var
  i:integer;
  s:csensor;
begin
  inherited;
  while SensorsCount<>0 do
  begin
    s:=GetSensor(0);
    s.delpairref(self);
  end;
end;

function cPair.GetMainParent:cbaseobj;
begin
  result:=GetStage;
end;

procedure cPair.SetMainParent(p:cbaseobj);
begin
  stage:=cbldobj(p);
end;

function cPair.mainParentClassName:string;
begin
  result:='cStage';
end;

procedure cPair.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
var
  sCount:integer;
  I: Integer;
  str:string;
  s:csensor;
begin
  inherited;
  // ������� ������� �� �������
  BladesLeft:=xmlNode.ReadAttributeInteger('SkipBlades');
  sCount:=xmlNode.ReadAttributeInteger('SensorsCount',SensorsCount);
  for I := 0 to sCount - 1 do
  begin
    str:='Sensor_'+inttostr(i);
    str:=xmlNode.ReadAttributeString(str);
    s:=csensor(eng.getobj(str));
    if s<>nil then
      AddSensor(s);
  end;

end;

procedure cPair.SaveObjAttributes(xmlNode:txmlNode);
var
  I: Integer;
  s:csensor;
begin
  inherited;
  xmlNode.WriteAttributeBool('AutoCreate',autocreate);
  xmlNode.WriteAttributeInteger('SensorsCount',SensorsCount);
  for I := 0 to SensorsCount - 1 do
  begin
    s:=GetSensor(i);
    xmlNode.AttributeAdd('Sensor_'+inttostr(i), s.name);
  end;
end;

function cPair.getBase:single;
var
  s1,s2:csensor;
begin
  s1:=GetSensor(0);
  s2:=GetSensor(1);
  Result:=Abs(s2.pos-s1.pos);
end;

procedure cPair.removesensors;
var
  I: Integer;
  s:csensor;
begin
  while SensorsCount>0 do
  begin
    s:=GetSensor(0);
    removesensor(s);
  end;
end;




end.
