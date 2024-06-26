unit uStage;

interface
uses uBaseObj, controls, uBldObj, uPair, uSensor, dialogs, classes, uBaseObjTypes,
      uerrorproc, uBldTypes, nativexml, sysutils, uCommonMath, mathfunction;

type
  cStage = class(cBldObj)
  public
    // ������ ������� (�������� �������� � ��������)
    Shape:cShape;
    // ������� ����� �������. True - �� �������
    orderblade:boolean;
  protected
    fdiametr:single;
    // ������ �������� � �������� ��������� �������
    sensors:cBldObj;
    // ������ �������� � �������� ��������� ���� ��������
    pairs:cBldObj;
  public
    constructor create;override;
    destructor destroy;override;
     // �������� ������
    function GetSensor(name:string):cSensor;overload;
    function GetSensor(i:integer):cSensor;overload;
    // �������� ���� ������ �������
    function GetTaho:cSensor;
    // ����� ��������
    function SensorsCount:integer;
    // �������� ����
    function GetPair(name:string):cPair;overload;
    function GetPair(i:integer):cPair;overload;
    // �������� ��� ������ ��� ������� ����� �������� � �������� �������
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
    // ����� ��������
    function PairCount:integer;
    // �������� ������
    Procedure AddSensor(sensor:csensor);
    // �������� ����
    Procedure AddPair(pair:cpair);
  protected
    function getRad:single;
    procedure setRad(r:single);
    function getTurbineName:string;
    procedure setTurbineName(str:string);
    function getTurbine:cbldobj;
    procedure setTurbine(t:cbldobj);
    // ���������� ����� ������� (��� ���� ��� ���������� ���������� �� ����������)
    procedure setBladeCount(count:integer);
    // ������� ����� �������
    function getBladeCount:integer;
    function GetMainParent:cbaseobj;override;
    procedure SetMainParent(p:cbaseobj);override;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    function mainparentClassname:string;override;
    function FindSensorByChunNumber(chan:integer):csensor;
    // ����������� �������
    procedure EnumSensors(proc:enumProc;data:pointer);
    // ��������, ��� ������� �������� ���������� � ������������ �������
    function bladePos:boolean;
    // ������������� ��� ���� �������� ����� ������������ �������
    procedure UpdateSensorsSkipBlade;
    // ����������� ������� �������
    procedure evalBladesPos;
    procedure evalOffsets;
    // �������� ���������� ��������� ��� �������� �������� � ��
    function GetScale:single;
  public
    property BladeCount:integer read getBladeCount write setBladeCount;
    property TurbineName:string read getTurbineName write SetTurbineName;
    property turbine:cbldobj read getTurbine write SetTurbine;
    // ������� � ����������
    property diametr:single read fdiametr write fdiametr;
    // ������� � ����������
    property Radius:single read getRad write setRad;
  end;

implementation

uses
  ubldmath;

constructor cStage.create;
begin
  inherited;
  shape:=cshape.create;
  helper:=false;
  objtype:=c_stage;
  imageindex:=c_stage_img;
  //--------------------------
  sensors:=cSensorList.create;
  sensors.autocreate:=true;
  sensors.parent:=self;
  sensors.name:='�������';
  //--------------------------
  pairs:=cPairList.create;
  pairs.autocreate:=true;
  pairs.parent:=self;
  pairs.name:='����';
end;

destructor cStage.destroy;
begin
  shape.destroy;
  sensors.destroy;
  pairs.destroy;
  inherited;
end;

function cStage.getTurbineName:string;
begin
  result:=parentname;
end;

procedure cStage.setTurbineName(str:string);
begin
  parentname:=str;
end;

function cStage.getRad:single;
begin
  result:=fdiametr/2;
end;

procedure cStage.setRad(r:single);
begin
  fdiametr:=2*r;
end;

function cStage.GetSensor(name:string):cSensor;
begin
  result := cSensor(sensors.getchild(name));
end;

function cStage.GetSensor(i:integer):cSensor;
begin
  result := cSensor(sensors.getchild(i));
end;

function cStage.SensorsCount:integer;
begin
  result:=sensors.ChildCount;
end;

function cStage.GetPair(name:string):cPair;
begin
  result := cPair(pairs.getchild(name));
end;

function cStage.GetPair(i:integer):cPair;
begin
  result := cPair(pairs.getchild(i));
end;

function cStage.PairCount:integer;
begin
  result:=pairs.ChildCount;
end;

Procedure cStage.AddSensor(sensor:csensor);
begin
  if sensor is cSensor then
    sensors.addchild(sensor)
  else
    showmessage('������� �������� '+sensor.ClassName+' ������ cSensor');
end;

Procedure cStage.AddPair(pair:cpair);
begin
  if pair is cPair then
    pairs.addchild(pair)
  else
    showmessage('������� �������� '+pair.ClassName+' ������ cSensor');
end;

function cStage.SupportedChildClass(obj:cbaseobj):boolean;
begin
  if obj is cBldObj then
    result:=true
  else
    result:=false;
end;

function cStage.SupportedChildClass(classname:string):boolean;
var strlist:tstringlist;
    i:integer;
begin
  strlist:=tStringList.Create;
  strlist.Sorted:=true;
  strlist.Add('cSensor');
  strlist.Add('cPair');
  result:=strlist.find(classname,i);
end;

function cStage.SupportedChildClass(objtype:integer):boolean;
begin
  result:=true;
  case objtype of
    c_sensor:;
    c_Pair:;
  else
    result:=false;
  end;
end;


procedure cStage.setBladeCount(count:integer);
var
  da:single;
  i:integer;
begin
  if count<0 then exit;
  shape.bladeCount:=count;
  da:=360/count;
  for i := 0 to count - 1 do
  begin
    shape.blades[i]:=i*da;
  end;
end;

function cStage.getBladeCount:integer;
begin
  result:=length(shape.Blades);
  if result=0 then
    result:=-1;
end;

function cStage.FindSensorByChunNumber(chan:integer):csensor;
begin
  // �������� ����� � ������������� ��������
  result:=usensor.findSensorByChunNumber(sensors,chan);
  if result<>nil then
    exit;
  // �������� ����� � �����
  result:=usensor.findSensorByChunNumber(pairs,chan);
end;

function cStage.getTurbine:cbldobj;
begin
  result:=cbldobj(parent)
end;

procedure cStage.setTurbine(t:cbldobj);
begin
  parent:=t;
end;

procedure cStage.EnumSensors(proc:enumProc;data:pointer);
var
  i:integer;
  s:csensor;
begin
  for I := 0 to sensors.childcount - 1 do
  begin
    s:=getsensor(i);
    // ����������� ������� �������� � ������ �������
    proc(s,data);
  end;
end;

function cStage.GetTaho:cSensor;
var
  I: Integer;
  s:csensor;
begin
  for I := 0 to sensorscount - 1 do
  begin
    s:=getsensor(i);
    if s.sensortype=c_rot then
    begin
      result:=s;
      exit;
    end;
  end;
  errorStage_noTaho(self,eng.flags);
  result:=nil;
end;

function cStage.GetMainParent:cbaseobj;
begin
  result:=getTurbine;
end;

procedure cStage.SetMainParent(p:cbaseobj);
begin
  turbine:=cbldobj(p);
end;

function cStage.bladePos:boolean;
begin
  result:=true;
  if shape=nil then
  begin
    result:=false;
    exit;
  end;
  if (shape.offset[length(shape.offset)-1]=0) and (shape.blades[length(shape.blades)-1]=0) then
  begin
    result:=false;
    exit;
  end;
end;

procedure cstage.UpdateSensorsSkipBlade;
var
  I: Integer;
  s:csensor;
begin
  for I := 0 to SensorsCount - 1 do
  begin
    s:=GetSensor(i);
    s.skipBlade:=s.EvalSkipBlades;
  end;
end;

procedure cstage.evalBladesPos;
var
  I: Integer;
begin
  setlength(shape.blades, bladecount);
  prepareBlades(shape.blades,Shape.offset);
end;

procedure cstage.evalOffsets;
begin
  shape.PrepareOffsetsFromBladePos(shape.blades);
end;

function cstage.mainparentClassname:string;
begin
  result:='cTurbine';
end;

procedure cstage.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
var
  I: Integer;
  str:string;
begin
  inherited;
  diametr:=xmlNode.ReadAttributeFloat('Diametr');
  bladecount:=xmlNode.ReadAttributeInteger('BladeCount');
  for I := 0 to bladecount - 1 do
  begin
    str:='blade_'+inttostr(i);
    str:=xmlNode.ReadAttributeString(str);
    Shape.blades[i]:=strtofloat(str);
  end;
  if bladecount>0 then
    evalOffsets;
end;

procedure cstage.SaveObjAttributes(xmlNode:txmlNode);
var
  I: Integer;
  str:utf8string;
begin
  inherited;
  xmlNode.WriteAttributeFloat('Diametr',diametr);
  xmlNode.WriteAttributeInteger('BladeCount',bladecount);
  for I := 0 to bladecount - 1 do
  begin
    str:=FormatStr(Shape.blades[i],eng.prec);
    xmlNode.AttributeAdd('blade_'+inttostr(i), str);
  end;
end;

function cstage.GetScale:single;
begin
  result:=diametr*pi/360;
end;



end.
