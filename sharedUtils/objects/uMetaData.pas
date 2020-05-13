unit uMetaData;

interface

uses sysutils, uEventList, classes, controls, dialogs,
     ucommonMath, uEventTypes, NativeXML;

type

  MetaData = class
  protected
    fname, fdsc:string;
  protected
    procedure setDSC(s:string);
    function getDSC:string;
    procedure setName(s:string);
    function getName:string;
    procedure setsize(v:integer);VIRTUAL;abstract;
    function getsize:integer;VIRTUAL;abstract;

    function GetIV(i:integer):integer;overload;virtual;abstract;
    procedure setiv(i:integer; v:integer);overload;virtual;abstract;
    function GetDV(i:integer):double;overload;virtual;abstract;
    procedure setdv(i:integer; d:double);overload;virtual;abstract;
    function GetSV(i:integer):string;overload;virtual;abstract;
    procedure setSV(i:integer; s:string);overload;virtual;abstract;

    function GetIV:integer;overload;
    procedure setiv(v:integer);overload;
    function GetDV:double;overload;
    procedure setdv(d:double);overload;
    function GetSV:string;overload;virtual;
    procedure setSV(s:string);overload;
  public
    property Name:string read getname write setname;
    property DSC:string read getDSC write setDSC;
    property size:integer read getSize write setSize;
    property IValue:integer read getIV write setIV;
    property DValue:double read getDV write setDV;
    property SValue:string read getSV write setSV;
    // сравниваем с аналогом
    function Compare(mdata:metadata):integer;virtual;abstract;
    constructor create;virtual;
    destructor destroy;virtual;
  end;

  IntMetaData = class(MetaData)
  protected
    fname, fdsc:string;
    fval:array of integer;
  protected
    procedure setsize(v:integer);override;
    function getsize:integer;override;
    function GetIV(i:integer):integer;override;
    procedure setiv(i:integer; v:integer);override;
    function GetSV:string;override;
  public
    function Compare(mdata:metadata):integer;override;
    constructor create;override;
  end;

  DoubleMetaData = class(MetaData)
  protected
    fname, fdsc:string;
    fval:array of double;
  protected
    procedure setsize(v:integer);override;
    function getsize:integer;override;
    function GetdV(i:integer):double;override;
    procedure setdv(i:integer; v:double);override;
    function GetSV:string;override;
  public
    function Compare(mdata:metadata):integer;override;
    constructor create;override;
  end;

  StringMetaData = class(MetaData)
  protected
    fname, fdsc:string;
    fval:string;
  protected
    procedure setsize(v:integer);override;
    function getsize:integer;override;
    function GetSV(i:integer):string;override;
    procedure setSV(i:integer; v:string);override;
  public
    function Compare(mdata:metadata):integer;override;
  end;

  MetaDataClass = class of MetaData;

  cObjCreator = class
  public
    createfunc:MetaDataClass;
  end;

  MetaDataList = class(TStringList)
  protected
    regclasses:tstringlist;
  protected
    procedure regclass(cl:MetaDataClass);
    function callFunc(index:integer):MetaData;overload;
  public
    procedure clearData;
    procedure SaveToXml(Node:tXmlNode);
    procedure LoadXml(Node:tXmlNode);
    function callFunc(classname:string):MetaData;overload;
    function GetObj(i:integer):MetaData;overload;
    function GetObj(s:string):MetaData;overload;
    procedure DeleteObj(i:integer);overload;
    procedure DeleteObj(name:string);overload;
    procedure AddObj(obj:metadata);
    constructor create;
    destructor destroy;
  end;

implementation

function StringMetaData.GetSV(i:integer):string;
begin
  result:=fval;
end;

function StringMetaData.Compare(mdata:metadata):integer;
var
  s1,s2:ansistring;
begin
  s1:=SValue;
  s2:=StringMetaData(mdata).SValue;
  result:=AnsiStrComp(PAnsiChar(@s1[1]),PAnsiChar(@s1[1]));
end;

procedure StringMetaData.setSV(i:integer; v:string);
begin
  fval:=v;
end;

procedure StringMetaData.setsize(v:integer);
begin
  setlength(fval,v);
end;

function StringMetaData.getsize:integer;
begin
  result:=length(fval);
end;

constructor DoubleMetaData.create;
begin
  inherited;
  setlength(fval,1);
end;

function DoubleMetaData.GetdV(i:integer):double;
begin
  result:=fval[i];
end;

procedure DoubleMetaData.setdv(i:integer; v:double);
begin
  fval[i]:=v;
end;

procedure DoubleMetaData.setsize(v:integer);
begin
  setlength(fval,v);
end;

function DoubleMetaData.getsize:integer;
begin
  result:=length(fval);
end;

function DoubleMetaData.Compare(mdata:metadata):integer;
begin
  if DValue>DoubleMetaData(mdata).DValue then
    result:=1
  else
  begin
    if DValue<DoubleMetaData(mdata).DValue then
    begin
      result:=-1;
    end
    else
      result:=0;
  end;
end;

function DoubleMetaData.GetSV:string;
begin
  result:=floattostr(fval[0]);
end;

procedure IntMetaData.setsize(v:integer);
begin
  setlength(fval,v);
end;

function IntMetaData.getsize:integer;
begin
  result:=length(fval);
end;

function IntMetaData.GetIV(i:integer):integer;
begin
  result:=fval[i];
end;

procedure IntMetaData.setiv(i:integer; v:integer);
begin
  fval[i]:=v;
end;

function IntMetaData.GetSV:string;
begin
  result:=inttostr(fval[0]);
end;

function IntMetaData.Compare(mdata:metadata):integer;
begin
  if IValue>IntMetaData(mdata).IValue then
    result:=1
  else
  begin
    if IValue<IntMetaData(mdata).IValue then
    begin
      result:=-1;
    end
    else
      result:=0;
  end;
end;

constructor IntMetaData.create;
begin
  inherited;
  setlength(fval,1);
end;

procedure MetaData.setDSC(s:string);
begin
  fdsc:=s;
end;

function MetaData.getDSC:string;
begin
  result:=fdsc;
end;

procedure MetaData.setName(s:string);
begin
  fname:=s;
end;

function MetaData.getName:string;
begin
  result:=fname;
end;

function MetaData.GetIV:integer;
begin
  result:=getIV(0);
end;

procedure MetaData.setiv(v:integer);
begin
  SetIV(0,v);
end;

function MetaData.GetDV:double;
begin
  result:=getDV(0);
end;

procedure MetaData.setdv(d:double);
begin
  SetDV(0,d);
end;

function MetaData.GetSV:string;
begin
  result:=getSV(0);
end;

procedure MetaData.setSV(s:string);
begin
  setSV(0,s);
end;

constructor MetaData.create;
begin

end;

destructor MetaData.destroy;
begin

end;


constructor MetaDataList.create;
begin
  sorted:=true;
  regclasses:=tstringlist.Create;
  regclasses.Sorted:=true;
  regclass(DoubleMetaData);
  regclass(IntMetaData);
  regclass(StringMetaData);
end;

destructor MetaDataList.destroy;
var
  i:integer;
  creator:cObjCreator;
begin
  clearData;
  for I := 0 to regclasses.Count - 1 do
  begin
    creator:=cObjCreator(regclasses.Objects[i]);
    creator.Destroy;
  end;
  regclasses.Destroy;
end;

procedure MetaDataList.regclass(cl:MetaDataClass);
var
  i:integer;
  creator:cObjCreator;
begin
  if not find(classname,i) then
  begin
    creator:=cObjCreator.Create;
    creator.createfunc:=cl;
    regclasses.AddObject(cl.ClassName, creator)
  end;
end;

function MetaDataList.callFunc(index:integer):MetaData;
var
  creator:cObjCreator;
begin
  creator:=cObjCreator(regclasses.objects[index]);
  result:=creator.createfunc.create;
end;

function MetaDataList.callFunc(classname:string):MetaData;
var
  i:integer;
begin
  result:=nil;
  if regclasses.find(classname,i) then
  begin
    result:=callFunc(i);
  end;
end;

procedure MetaDataList.SaveToXml(Node:tXmlNode);
var
  childNode:tXmlNode;
  I: Integer;
  obj:Metadata;
begin
  for I := 0 to Count - 1 do
  begin
    obj:=MetaData(objects[i]);
    childNode:=node.NodeNew(obj.name);
    ChildNode.WriteAttributeString('Type', obj.classname);
    ChildNode.WriteAttributeString('Value', obj.GetSV);
    ChildNode.WriteAttributeString('DSC', obj.DSC);
  end;
end;

procedure MetaDataList.LoadXml(Node:tXmlNode);
var
  childNode:tXmlNode;
  I: Integer;
  obj:Metadata;
  str:string;
begin
  for I := 0 to node.NodeCount - 1 do
  begin
    childNode:=node.nodes[i];
    str:=ChildNode.ReadAttributeString('Type','');
    obj:=callFunc(str);
    if obj<>nil then
    begin
      obj.Name:=ChildNode.name;
      obj.dsc:=ChildNode.ReadAttributeString('DSC','');
      if obj is IntMetaData then
      begin
        obj.IValue:=ChildNode.ReadAttributeInteger('Value',0);
      end
      else
      begin
        if obj is DoubleMetaData then
        begin
          obj.DValue:=ChildNode.ReadAttributeFloat('Value',0);
        end
        else
        begin
          obj.SValue:=ChildNode.ReadAttributeString('Value','');
        end;
      end;
      addobj(obj);
    end;
  end;
end;

function MetaDataList.GetObj(i:integer):MetaData;
begin
  result:=MetaData(objects[i]);
end;

function MetaDataList.GetObj(s:string):MetaData;
var
  i:integer;
begin
  result:=nil;
  if find(s,i) then
    result:=getobj(i);
end;

procedure MetaDataList.clearData;
var
  i:integer;
  data:MetaData;
begin
  for I := 0 to Count - 1 do
  begin
    data:=GetObj(i);
    data.destroy;
  end;
  clear;
end;

procedure MetaDataList.DeleteObj(i:integer);
var
  obj:metadata;
begin
  obj.destroy;
  Delete(i);
end;

procedure MetaDataList.DeleteObj(name:string);
var
  i:integer;
begin
  if find(name, i) then
  begin
    deleteobj(i);
  end;
end;

procedure MetaDataList.AddObj(obj:metadata);
begin
  addobject(obj.name,obj);
end;

end.
