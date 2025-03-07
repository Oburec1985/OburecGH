unit uTurbina;

interface
uses
  uBldObj, uStage, dialogs, uBaseObj, usensor, upair, classes, uBaseObjTypes,
  uChan, nativexml, sysutils;

type
  cTurbine = class(cBldObj)
  public
  protected
    function GetMainParent:cbaseobj;override;
    procedure SetMainParent(p:cbaseobj);override;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    constructor create;override;
    destructor destroy;override;
    function GetStage(name:string):cStage;overload;
    function GetStage(i:integer):cStage;overload;
    function StageCount:integer;
    function SensorsCount:integer;
    function PairsCount:integer;
    // �������� ��� ������ ��� ������� ����� �������� � �������� �������
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
    // �������� �������
    procedure AddStage(stage:cStage);
  end;

implementation
uses
  uBldEng;

constructor cTurbine.create;
begin
  inherited;
  helper:=false;  
  objtype:=c_turbine;
  imageindex:=c_Turbine_img;
end;

destructor cTurbine.destroy;
begin
  inherited;
end;

function cTurbine.GetStage(name:string):cStage;
begin
   result:=cstage(GetChild(name));
end;

function cTurbine.GetStage(i:integer):cStage;
begin
   result:=cstage(GetChild(i));
end;

function cTurbine.StageCount:integer;
begin
  result:=childcount;
end;

function cTurbine.SensorsCount:integer;
var
  i,count:integer;
  stage:cstage;
begin
  count:=0;
  for I := 0 to stageCount - 1 do
  begin
    stage:=getstage(i);
    count:=count+stage.SensorsCount;
  end;
  result:=count;
end;

function cTurbine.PairsCount:integer;
var
  i,count:integer;
  stage:cstage;
begin
  count:=0;
  for I := 0 to stageCount - 1 do
  begin
    stage:=getstage(i);
    count:=count+stage.pairCount;
  end;
  result:=count;
end;

procedure cTurbine.AddStage(stage:cStage);
begin
  if stage is cstage then
    addchild(stage)
  else
    showmessage('������� �������� '+stage.ClassName+' ������ cSensor');
end;

function cTurbine.SupportedChildClass(obj:cbaseobj):boolean;
begin
  result:=false;
  if obj is cstage then
    result:=true;
  {
  if obj is cSensor then
    result:=true;
  if obj is cpair then
    result:=true;
  if obj is cChan then
    result:=true;
  }
end;

function cTurbine.SupportedChildClass(classname:string):boolean;
var strlist:tstringlist;
    i:integer;
begin
  strlist:=tStringList.Create;
  strlist.Sorted:=true;
  strlist.Add('cSensor');
  strlist.Add('cStage');
  strlist.Add('cPair');
  strlist.Add('cChan');
  result:=strlist.find(classname,i);
end;

function cTurbine.SupportedChildClass(objtype:integer):boolean;
begin
  result:=true;
  case objtype of
    c_sensor:;
    c_Stage:;
    c_Pair:;
  else
    result:=false;
  end;
end;

function cTurbine.GetMainParent:cbaseobj;
begin
  result:=cbldobj(parent);
end;

procedure cTurbine.SetMainParent(p:cbaseobj);
begin
  parent:=p;
end;

procedure cTurbine.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
begin
  inherited;
  cbldeng(mng).lastfile:=xmlNode.ReadAttributeString('Filename');
end;

procedure cTurbine.SaveObjAttributes(xmlNode:txmlNode);
var
  str:UTF8String;
begin
  inherited;
  str:=eng.lastfile;
  xmlNode.WriteAttributeString('Filename',str);
end;

end.
