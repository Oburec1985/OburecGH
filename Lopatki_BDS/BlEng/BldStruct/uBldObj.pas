unit uBldObj;

interface
uses uBaseObj, controls, classes, uBldEng, ueventtypes, ueventlist,
     uBldGlobalStrings;

type
  cBldObj = class(cBaseObj)
  public
    // ��� �������
    objtype:integer;
    // ���������� ������ ������ (�� ������ ������������ � �����������)
    helper:boolean;
    // �������������� ������
    data:pointer;
  protected
  protected
    procedure setengine(e:cbldeng);virtual;
    function getengine:cbldeng;virtual;
  public
    constructor create;override;
    destructor destroy; override;
    function TypeString:String;override;
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
    function GetImages32:TImageList;
    // ���������� true ���� ������ �������� (�� ����������� � �������� ������)
    function root:boolean;virtual;
    property eng:cBldEng read getengine write setengine;
  end;

  function gettypestring(objtype:integer):string;
  function TypeStringToInt(typestr:string):integer;
  function CreateObjByType(typestr:string):cbldobj;

  const
    c_BldObj = 0;
    c_Turbine = 1;
    c_Stage = 2;
    c_Sensor = 3;
    c_pair = 4;
    c_Chan = 5;
    c_TahoSensor = 6;
    c_EdgeSensor = 7;
    c_RootSensor = 8;
    c_UTS = 9;
    // �������� ����
    c_2070 = 10;
    c_2081 = 11;

  // ��������� ������������ ��� �������
  const c_Root = 0;
  const c_Edge = 1;
  const c_Rot  = 4;

implementation
uses
  uturbina, usensor,upair,ustage;

constructor cBldObj.create;
begin
  inherited;
  helper:=true;
  objtype:=c_bldObj;
end;

destructor cBldObj.destroy;
begin
  inherited;
end;

// ������ �������� ���� �������
function cBldObj.TypeString:String;
begin
  case objtype of
    c_turbine: result:=gettypestring(objtype);
    c_pair: result:=gettypestring(objtype);
    c_sensor: result:=gettypestring(objtype);
    c_stage: result:=gettypestring(objtype);
  else
    result:=self.ClassName;
  end;
end;

function cBldObj.SupportedChildClass(obj:cbaseobj):boolean;
begin
  if obj is cBldObj then
    result:=true
  else
    result:=false;
end;

function cBldObj.SupportedChildClass(classname:string):boolean;
var strlist:tstringlist;
    i:integer;
begin
  strlist:=tStringList.Create;
  strlist.Sorted:=true;
  strlist.Add('cTurbina');
  strlist.Add('cSensor');
  strlist.Add('cStage');
  strlist.Add('cPair');
  strlist.Add('cBldObj');
  result:=strlist.find(classname,i);
end;

function cBldObj.SupportedChildClass(objtype:integer):boolean;
begin
  result:=true;
  case objtype of
    c_sensor:;
    c_Stage:;
    c_Pair:;
    c_Turbine:;
    c_BldObj:;
    c_Chan:;
  else
    result:=false;
  end;
end;

function gettypestring(objtype:integer):string;
begin
  case objtype of
    c_turbine: result:= v_turbine;
    c_pair: result:= v_pair;
    c_sensor: result:= v_sensor;
    c_stage: result:= v_stage;
    c_bldobj: result:= v_bldobj;
    c_chan: result:= v_chan;
  else
    result:='Unckown type';
  end;
end;

function TypeStringToInt(typestr:string):integer;
var strlist:tstringlist;
    i:integer;
begin
  strlist:=tStringList.Create;
  strlist.Add(v_sensor);
  strlist.Add(v_bldObj);
  strlist.Add(v_pair);
  strlist.Add(v_stage);
  strlist.Add(v_turbine);
  strlist.Add(v_Chan);
  strlist.Add(v_UTS);
  strlist.Add('M2070');
  strlist.Add('M2081');
  for I := 0 to strlist.Count - 1 do
  begin
    if strlist.Strings[i]=typestr then
    begin
      break;
    end;
  end;
  if i=0 then
    result:=c_sensor;
  if i=1 then
    result:=c_bldObj;
  if i=2 then
    result:=c_pair;
  if i=3 then
    result:=c_stage;
  if i=4 then
    result:=c_turbine;
  if i=5 then
    result:=c_chan;
  if i=6 then
    result:=c_UTS;
  if i=7 then
    result:=c_2070;
  if i=8 then
    result:=c_2081;
  strlist.Destroy;
end;

function cBldObj.GetImages32:TImageList;
begin
  if eng<>nil then
    result:=eng.images_32
  else
    result:=nil;
end;

function cBldObj.root:boolean;
begin
  result:=(parent=nil);
end;

function cBldObj.getengine:cbldeng;
begin
  result:=cbldeng(fBaseObjMng);
end;

procedure cBldObj.setengine(e:cbldeng);
begin
  SetMng(e);
end;

function CreateObjByType(typestr:string):cbldobj;
var
  obj:cbldobj;
begin
  obj:=nil;
  if typestr = v_Turbine then
  begin
    obj:=cturbine.create;
  end;
  if typestr = v_Stage then
  begin
    obj:=cStage.create;
  end;
  if typestr = v_Sensor then
  begin
    obj:=cSensor.create;
  end;
  if typestr = v_pair then
  begin
    obj:=cPair.create;
  end;
  result:=obj;
end;

end.
