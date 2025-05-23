unit uObjDb;

interface
uses
  NativeXml, SysUtils, uBaseObj, UBaseObjMng;

type
  cDBBaseObj = class(cBaseObj)
  public
    // ������ �������� �������;
    dsc:string;
  public
    function TypeString:String;override;
  end;

  // ����� ������� ������ ���������� ��������� �������
  cDBTest = class(cDBBaseObj)
  public
    // ��� ���������
    TestType:integer;
    // ���� ���������
    Date:TDateTime;
  end;

  cDBObj = class(cDBBaseObj)
    // ���� ���������
  end;

  cObjDataBase = class (cBaseObjMng)
  public
    fname:string;
  protected
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    procedure XMLSaveMngAttributes(node:txmlnode);override;
    procedure XMLlOADMngAttributes(node:txmlnode);override;
    procedure regObjClasses;override;
  protected
    function GetName:string;
    procedure setName(s:string);
  public
    property name:string read getname write setname;
  public
    constructor create;override;
    destructor destroy;override;
    function getDBObj(i:integer):cDBBaseObj;overload;
    function getDBObj(name:string):cDBBaseObj;overload;
    procedure AddToXML(fname:string; sectionName:string);override;
    function LoadFromXML(fname:string; sectionName:string):boolean;override;
  end;

implementation

constructor cObjDataBase.create;
begin
  inherited;
end;

destructor cObjDataBase.destroy;
begin
  inherited;
end;

procedure cObjDataBase.regObjClasses;
begin
  inherited;
  regclass(cDBTest);
  regclass(cDBObj);
end;

function cObjDataBase.GetName:string;
begin
  result:=fname;
end;

procedure cObjDataBase.setName(s:string);
begin
  s:=fName;
end;

procedure cObjDataBase.AddBaseObjInstance(obj:cbaseobj);
begin
  if obj is cDBBaseObj then
    inherited;
end;

function cObjDataBase.getDBObj(i:integer):cDBBaseObj;
begin
  result:=cDBBaseObj(getobj(i));
end;

function cObjDataBase.getDBObj(name:string):cDBBaseObj;
begin
  result:=cDBBaseObj(getobj(name));
end;

procedure cObjDataBase.XMLSaveMngAttributes(node:txmlnode);
begin
  // ��� ���� �������
  //node.WriteAttributeString('TagsFolder',TagsFolder);
end;

procedure cObjDataBase.XMLlOADMngAttributes(node:txmlnode);
begin
  inherited;
  if node<>nil then
  begin

  end;
end;

procedure cObjDataBase.AddToXML(fname:string; sectionName:string);
var
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  obj:cbaseobj;
begin
  inherited;
  doc:=TNativeXml.Create(nil);
  doc.LoadFromFile(fname);
  node:=doc.Root;
  node:=node.NodeNew(sectionName);
  XMLSaveMngAttributes(node);
  Doc.XmlFormat := xfReadable;
  doc.SaveToFile(fname);
  doc.destroy;
end;

function cObjDataBase.LoadFromXML(fname:string; sectionName:string):boolean;
var
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  obj:cbaseobj;
begin
  inherited;
  doc:=TNativeXml.Create(nil);
  doc.LoadFromFile(fname);
  node:=doc.Root.FindNode(sectionname);
  XMLlOADMngAttributes(node);
  doc.destroy;
end;

function cDBBaseObj.TypeString:String;
begin
  result:='������� ������ ���� ������';
end;

end.
