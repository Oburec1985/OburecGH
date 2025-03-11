unit uBaseObjMng;

interface
uses
  controls, stdctrls, classes, sysutils, uEventList, uEventTypes, uBaseObj,
  uCommonMath,
  //uVectorList,
  forms,
  uSetList,
  uLogFile,
  dialogs,
  NativeXML,
  uRegClassesList;

type
  cEnumData = class
  public
    p:enumproc;
    data:pointer;
  end;

  cBaseObjMng = class
  private
  protected
    GetMngObjForm:tForm;
  public
    m_EnableAddObjInstanceEvent:boolean;
    // ������ ���� �������� �������. ������ ��� ������� cBaseObjStr (�.� � ���� ������� �� ���������)
    // � ��� �������� ������ ��� � ����������� ���� � ������� ������ AddBaseObjInstance
    objects:cBaseObjList;
    regclasses:tstringlist;
    // �������� ��� ����������� �������� ������
    images_16:tImageList;
    images_32:tImageList;
    // ������ ������� �������
    Events:cEventList;
  protected
    // ������� ������
    Procedure DeleteObj(obj:cBaseObj);
    // �������� ������ ������� � �����
    function getobjind(obj:cBaseObj):integer;
    // � ������� �� Add �� ��������� � ��������� �������� �������
    procedure AddBaseObjInstance(obj:cbaseobj);virtual;
    function regclass(cl:tclass):cObjCreator;
    procedure regObjClasses;virtual;
    // � �������� ���� �������� �������� ���� � �������� ����������� ����
    procedure XMLSaveMngAttributes(node:txmlnode);virtual;
    procedure XMLlOADMngAttributes(node:txmlnode);virtual;
    procedure XMLlOADMngAttributesAfterObjects(node:txmlnode);virtual;
    // ���������� ����� ��������� �� xml ����� clear; ������ ������ ��������� �
    // ���������������� ��������� � ����� ������
    procedure doBeforeLoadXML;virtual;
    procedure doAfterLoadXML;virtual;
    procedure createEvents;
    procedure doRenameObj(sender:tobject);virtual;
  public
    constructor create;virtual;
    destructor destroy;virtual;
    // ���������� ����� ��������
    function count:integer;
    // �������� ������ ��������
    // ����� ���� ���������� � ����������. ���� � ���������� ������������ ������� �������� � ��������
    // ������������ ������ �������� � ������ autocreate=true, �� ��� �������� �� xml ����� ���� ������:
    // ������ ����� ������� � ������ clear � �� ����� ������ �����. (���������� ��� ������������� ����� ����� clear
    procedure clear;virtual;
    function getobj(name:string):cBaseObj;overload;
    function getobj(i:integer):cBaseObj;overload;
    // ������� ������ �� ������
    // ������� �����. ����������� ���!!!
    procedure removeObj(obj:cBaseObj);overload;virtual;
    // ������� ������ �� ������ �� �������
    procedure removeObj(i:integer);overload;
    // ����������� ��� ���� � ������, ������� �� �������� ��������
    function EnumTreeNodes(proc:enumproc; data:pointer):boolean;
    // �������� ������
    Procedure Add(obj:cBaseObj; root:cBaseObj);overload;
    Procedure Add(obj:cBaseObj);overload;
    // ������� ������ �� ����� ������
    Function CreateObjByType(Classname:string):cbaseobj;virtual;
    procedure SaveToXML(fname:string; sectionName:string);overload;virtual;
    procedure SaveToXML(fname:string; sectionName:string; rewrite:boolean);overload;virtual;
    procedure AddToXML(fname:string; sectionName:string);virtual;
    // �� ������� engine ����� ���������
    function AddFromXML(fname:string; sectionName:string):boolean;overload;virtual;
    function AddFromXML(node:tXmlNode):boolean;overload;virtual;
    function LoadFromXML(fname:string; sectionName:string):boolean;overload;virtual;
    function LoadFromXML(node:tXmlNode):boolean;overload;virtual;
    function GetObjDlg:cBaseObj;
  end;

implementation
uses
  uObjXML, uGetMngObjForm
  //,uRcFunc
  ;

procedure cBaseObjMng.regObjClasses;
begin
  regclass(cbaseobj);
end;

constructor cBaseObjMng.create;
begin
  m_EnableAddObjInstanceEvent:=false;
  events:=cEventList.create(self,true);
  events.destroydata:=true;
  createEvents;
  // ������ ��������
  objects:=cBaseObjList.Create;
  objects.destroydata:=true;
  regclasses:=cRegClassesList.create;
  regObjClasses;
  GetMngObjForm:=tGetMngObjForm.Create(nil);
end;

procedure cBaseObjMng.createEvents;
begin
  events.AddEvent(classname+'_doRenameObj',E_OnRenameObj,doRenameObj);
end;

procedure cBaseObjMng.doRenameObj(sender:tobject);
begin

end;

function cBaseObjMng.regclass(cl:tclass):cObjCreator;
begin
  result:=cRegClassesList(regclasses).RegClass(cBaseObjClass(cl));
end;

destructor cBaseObjMng.destroy;
var
  I: Integer;
  o:cbaseobj;
begin
  events.destroy;
  events:=nil;
  for I := 0 to Count - 1 do
  begin
    o:=getobj(i);
    o.blocked:=false;
  end;
  // ������� ������� ������
  clear;
  objects.Destroy;
  cRegClassesList(regclasses).Destroy;
  //GetMngObjForm.destroy;
end;

procedure cBaseObjMng.doAfterLoadXML;
begin

end;

procedure cBaseObjMng.doBeforeLoadXML;
begin

end;

procedure cBaseObjMng.clear;
var
  i:integer;
  obj:cbaseobj;
  //b:boolean;
begin
  i:=0;
  //b:=false;
  while i<objects.count do
  begin
    obj:=objects.getobj(i);
    if obj.blocked then
    begin
      inc(i);
    end
    else
    begin
      objects.deletechild(i);
      i:=0;
    end;
  end;
end;

// callBack ������� ������������ ��� ���������� �������� � ������.
function AddProc(obj:cBaseObj; data:pointer):boolean;
var
  index:integer;
  objects:cBaseObjList;
  oldobj:cbaseobj;
  str:string;
begin
  result:=true;
  objects:=cBaseObjlist(cBaseObjMng(data).objects);
  oldobj:=objects.getobj(obj.name);
  if oldobj<>obj then
  begin
    str:=obj.name;
    while objects.Find(str,index) do
    begin
      if objects.getobj(index)=obj then
        exit;
      str:=modname(str, true);
    end;
    obj.name:=str;
  end
  // ���� ���� ������� �������� ��� ������������ ������
  else
    exit;
  cBaseObjMng(data).AddBaseObjInstance(obj);
end;

procedure cBaseObjMng.AddBaseObjInstance(obj:cbaseobj);
begin
  objects.AddObj(obj);
  obj.ReplaceObjMng(self);
  if m_EnableAddObjInstanceEvent then
    events.CallAllEventsWithSender(E_OnAddObjInstance, obj);
end;

Procedure cBaseObjMng.Add(obj:cBaseObj; root:cBaseObj);
begin
  if obj<>nil then
  begin
    obj.parent:=root;
    // ����������� ��� ����� ����� �������� ��� �������
    obj.EnumGroupMembers(AddProc,self);
  end;
  events.CallAllEventsWithSender(E_OnAddObj, obj);
end;

Procedure cBaseObjMng.Add(obj:cBaseObj);
begin
  if obj<>nil then
  begin
    if getobj(obj.name)<>obj then
    begin
      // ������ nil ������� � �������� ��������
      add(obj,obj.parent);
    end;
  end;
end;


// ������� ������ �� ������
procedure cBaseObjMng.removeObj(obj:cBaseObj);
begin
  objects.removeobj(obj);
end;

// ������� ������ �� ������ �� �������
procedure cBaseObjMng.removeObj(i:integer);
var
  obj:cbaseobj;
begin
  obj:=getobj(i);
  removeobj(obj);
end;

function cBaseObjMng.GetObjInd(obj:cBaseObj):integer;
var ind:integer;
begin
  if objects.find(obj.name, ind) then
    result:=ind
  else
    result:=-1;
end;

Procedure cBaseObjMng.DeleteObj(obj:cBaseObj);
var i:integer;
begin
  i:=getobjind(obj);
  // ����� ������� ��� ��������� ������� �� �������� �������
  Events.CallAllEventsWithSender(E_OnDestroyObject, obj);
  // ������� ������
  obj.destroy;
  // ������� ������ �� ������
  objects.removeobj(i);
end;


// ���������� ����� ��������
function cBaseObjMng.count:integer;
begin
  result:=objects.count;
end;

function cBaseObjMng.getobj(name:string):cBaseObj;
var i:integer;
begin
  if objects.Find(name,i) then
  begin
    result:=getobj(i);
  end
  else
    result:=nil;
end;

function cBaseObjMng.getobj(i:integer):cBaseObj;
begin
  if i<objects.Count then
  begin
    result:=cBaseObj(objects.getobj(i));
  end
  else
    result:=nil;
end;


function l_enumTreeNodes(obj:cBaseObj; data:pointer):boolean;
begin
  result:=true;
  cenumdata(data).p(obj, cenumdata(data).data);
end;

function cBaseObjMng.EnumTreeNodes(proc:enumproc; data:pointer):boolean;
var
  I: Integer;
  obj:cbaseobj;
  enumData:cenumdata;
begin
  result:=true;
  enumData:=cenumdata.Create;
  enumdata.p:=proc;
  enumdata.data:=data;
  for I := 0 to count - 1 do
  begin
    obj:=getobj(i);
    if obj.parent=nil then
    begin
      obj.EnumGroupMembers(l_enumTreeNodes, enumdata);
    end;
  end;
  enumData.Destroy;
end;

Function cBaseObjMng.CreateObjByType(Classname:string):cbaseobj;
begin
  result:=cRegClassesList(regclasses).callFunc(classname);
  if result<>nil then
    result.OnEngCreate;
end;

procedure cBaseObjMng.AddToXML(fname:string; sectionName:string);
var
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  obj:cbaseobj;
begin
  doc:=TNativeXml.Create(nil);
  //doc:=TNativeXml.Create;
  doc.LoadFromFile(fname);
  node:=doc.Root;
  XMLSaveObjects(doc, self, sectionName);
  node:=node.FindNode(sectionname);
  XMLSaveMngAttributes(node);
  Doc.XmlFormat := xfReadable;
  doc.SaveToFile(fname);
  doc.destroy;
end;

procedure cBaseObjMng.SaveToXML(fname:string; sectionName:string; rewrite:boolean);
var
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  obj:cbaseobj;
  dir:string;
begin
  doc:=TNativeXml.Create(nil);
  if not rewrite then
  begin
    if fileexists(fname) then
    begin
      doc.LoadFromFile(fname);
    end;
  end;
  node:=doc.Root;
  node.name:='Root';
  XMLSaveObjects(doc, self, sectionName);
  node:=node.FindNode(sectionname);
  XMLSaveMngAttributes(node);
  Doc.XmlFormat := xfReadable;
  dir:=extractfiledir(fname);
  if not DirectoryExists(dir) then
  begin
    ForceDirectories(dir);
  end;
  doc.SaveToFile(fname);
  doc.destroy;
end;

procedure cBaseObjMng.SaveToXML(fname:string; sectionName:string);
begin
  SaveToXML(fname, sectionName, false);
end;

function cBaseObjMng.AddFromXML(node:tXmlNode):boolean;
var
  rootnode:txmlnode;
  I: Integer;
  obj:cbaseobj;
begin
  XMLlOADMngAttributes(node);
  XMLLoadObjects(node.Document, self, node);
  XMLlOADMngAttributesAfterObjects(node);
  node.Document.destroy;
  result:=true;
  events.CallAllEvents(E_OnLoadObjMng);
end;

function cBaseObjMng.AddFromXML(fname:string; sectionName:string):boolean;
var
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  obj:cbaseobj;
begin
  doc:=TNativeXml.Create(nil);
  doc.XmlFormat:=xfReadable;
  doc.LoadFromFile(fname);
  node:=doc.Root.FindNode(sectionname);
  if node<>nil then
  begin
    result:=AddFromXML(node);
  end
  else
    doc.Destroy;
end;

function cBaseObjMng.LoadFromXML(node:tXmlNode):boolean;
begin
  clear;
  doBeforeLoadXML;
  AddFromXML(node);
  doAfterLoadXML;
end;

function cBaseObjMng.LoadFromXML(fname:string; sectionName:string):boolean;
begin
  clear;
  doBeforeLoadXML;
  //Events.active:=false;
  AddFromXML(fname,sectionName);
  //Events.active:=true;
  doAfterLoadXML;
end;

procedure cBaseObjMng.XMLSaveMngAttributes(NODE:TXMLNODE);
begin

end;

procedure cBaseObjMng.XMLLoadMngAttributes(NODE:TXMLNODE);
begin

end;

procedure cBaseObjMng.XMLlOADMngAttributesAfterObjects(node:txmlnode);
begin

end;

function cBaseObjMng.GetObjDlg:cBaseObj;
begin
  result:=tGetMngObjForm(GetMngObjForm).GetObj(self);
end;

end.