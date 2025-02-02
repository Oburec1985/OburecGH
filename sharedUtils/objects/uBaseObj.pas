// ����� �� �������� ����������� ��� ������� ������ ���������. ������������ ���
// ����������� ������ ���������� ������������ ���� ��������. �������� � ����
// ��������� ������
unit uBaseObj;

interface

uses
  sysutils, uEventList, classes, controls, dialogs, ucommonMath,
  uEventTypes, NativeXML, uMetaData,
  uSetList;

type
  cBaseObj = class;
  // ���������� - ����� �� ���������� ������������
  enumProc = function(obj: cBaseObj; data: pointer): boolean;
  cBaseObjList = class;

  cBaseObj = class
  public
    m_NotSaveToXml: boolean;
    fdefCaption: boolean;
    f_caption: string;
    // ���� ������������ �� �� ��������� ��� �������� �������� ��� ������������ �����
    // destroydata
    // � ��������� ��� ������ ������ clear. ������������� ���� ������������ ����� �������� ������ ��� �������� ������
    blocked: boolean;
    // ������ ������
    fimageind: integer;
    // ������������ ������. ����� ��� ����������� ����������� � TreeView
    fparent: cBaseObj;
    // ������ ��������� ������������� � ������ ������� �������. ������������ ��� ��������
    // ��� �������� ��������. ������ �� �� ��� ����� ����������� � �����������
    // ������ ������� True ��� ��������������� �������� ��������,�.�. ������ ����� �������� � �� ������������ ��� ��������
    // ���������� ���������� ����
    autocreate: boolean;
    // ������ ���������������. �� ������������ � ������
    fHelper: boolean;
    metadata: MetaDataList;
    // ������ � ������� ����� ������
    list: cBaseObjList;
    itemindex: integer;
    // �������� �������. ����� ��� ����������� ����������� � TreeView
    childrens: cBaseObjList;
  protected
    fBaseObjMng: tobject;
    // ��� �������
    fname: string;
    // ���������� (-1 ���� �� ����������)
    fsort: integer;
  public
  // �������
    fOnDestroy:tnotifyevent;
  public
    function NotSaveToXml:boolean;virtual;
    procedure DoBeforeLincParent; virtual;
    // ���������� ��� ���������� ������ �������� (� ��� ����� ���� ����� �������� nil)
    procedure DoLincParent; virtual;
    // �������� ������ �� engine, �� �� ��������� ������ � ������ engina
    procedure ReplaceObjMng(mng: tobject); virtual;
    procedure CreateChildrens; virtual;
  protected
    procedure setcaption(str: string); virtual;
    // ���� � ��������� �������� ����������� ������ � ������ parentname �� �� ��������� ��� ��������
    function GetParentName: string;
    procedure SetParentName(parentname: string); virtual;
    // ����������� ���� �������� ������, ������� ��� ���� ���������
    // � ������� ����������
    // ������������� ������ � ��������� �� �������������� ������
    function fEnumGroupMembers(proc: enumProc; data: pointer;
      var continue: boolean): boolean;
    // ������������� �� ����� ��� ����� �������
    procedure unLincMng; virtual;
    // �������� ������ �� ������� ������ (��� ������� - �������, ��� ������� - ������� � �.�.)
    function GetMainParent: cBaseObj; virtual;
    procedure SetMainParent(p: cBaseObj); virtual;
    // �������������� ������ �������� ��������
    function SupportedChildClass(obj: cBaseObj): boolean; overload; virtual;
    function SupportedChildClass(classname: string): boolean; overload; virtual;
    function SupportedChildClass(objtype: integer): boolean; overload; virtual;
  public
    // ����������� ������� ��� ����������� � �����������. ����������� � ����������� �������� ��� ����������� � VirtualTreeView
    procedure ShowComponent(node: pointer; component: tcomponent); virtual;
    procedure setMng(m: tobject); virtual;
    function getMng: tobject;
    // �������� � ������
    function isHeader: boolean;
    function GetRoot: cBaseObj;
    function mainParentClassName: string; virtual;
    // ������ ����������� ��� �������
    function TypeString: String; virtual;
    procedure EnumGroupMembers(proc: enumProc; data: pointer);
    function find(name: string; var index: integer): boolean; virtual;
    // ����� �� �������� ����� KeyComparator � cSetList
    function findObj(key: pointer; var ind: integer): cBaseObj;
    // ���������� ������ �������� � ���������� classname
    // ���� �� ���� ������
    function getChildrensByClassName(p_classname: ansistring): tstringlist;
    function getChildrenByName(name: string): cBaseObj;
    function getChildrenByCaption(name: string): cBaseObj;
    // �������� ������� �� ������
    function getChild(i: integer): cBaseObj; overload;
    // �������� ������� �� �����
    function getChild(name: string): cBaseObj; overload;
    // ����� ��������
    function ChildCount: integer;
    constructor create; virtual;
    destructor destroy; virtual;
    // �������� ������ �������
    procedure AddChild(newChild: cBaseObj);
    // ������������ � �������
    procedure lincTo(p_parent: cBaseObj);
    // ����������� ������ �� ��������
    procedure unlinc; virtual;
    // ����������� �������� �������
    procedure unlincChildrens;
    // ��������� �������� ��������� �� ������ ��� �� ���� �� ������
    function isParentObj(obj: cBaseObj): boolean;
    // �������� �������� ����� �������� = classname. � ����� ����� �� ����������
    function GetParentByClassName(p_classname: string): cBaseObj;
    // ����� ������ �������� - ���������� ������ ��������
    function HaveCommonParent(obj: cBaseObj): cBaseObj;
    // �������� ������� (�������� ���������� ������� � ���������� �� ������)
    procedure deletechild(i: integer); overload; virtual;
    procedure deletechild(name: string); overload; virtual;
    procedure deletechild(node: pointer); overload; virtual;
    procedure destroychildrens;
    procedure clear;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); virtual;
    procedure SaveObjAttributes(xmlNode: txmlNode); virtual;
    // ����������, ����� ������ ��������� �������
    procedure OnEngCreate; virtual;
  protected
    // ��������� �����
    procedure setname(str: string); virtual;
    // ��������� ��������
    procedure setParent(p: cBaseObj); virtual;
    // ��������� ���� ����������
    procedure setsorted(value: integer); virtual; abstract;
    procedure setimageind(ind: integer);
    function getimageindex: integer; virtual;
    // ��������� ��������
    procedure setImageList(p_imagelist: timagelist); virtual;
    function getImageList: timagelist; virtual;
    // ��������� �������� ������� ��������� �������
    function getdestroydata: boolean;
    procedure SetDestroyData(b: boolean);
    function getShowInGraphs: boolean; virtual;
    procedure setShowInGraphs(b: boolean); virtual;
  protected
    property sorted: integer read fsort write setsorted;
  public
    property mainParent: cBaseObj read GetMainParent write SetMainParent;
    property parent: cBaseObj read fparent write setParent;
    property name: string read fname write setname;
    property imageindex: integer read getimageindex write setimageind;
    property images: timagelist read getImageList write setImageList;
    property parentname: string read GetParentName write SetParentName;
    property destroydata: boolean read getdestroydata write SetDestroyData;
    // ���������� � ������ �������� � �������
    property ShowInGraphs: boolean read getShowInGraphs write setShowInGraphs;
    property caption: string read f_caption write setcaption;
  end;

  // ���������� ������ �������
  cBaseObjList = class(cSetList)
  private
    fcomparetype: integer;
  protected
    // ���������� � ������� (���)
    mDataName: string;
    // ��� ����������
    mDataClass: TClass;
    // ��������� ����� �������� ����� ����������� � �� �������� �����,
    // �� ���������� � �������� ������������ ��������� �������� ������ ����� ������
    // ����� ����
  protected
    // ���������� ����� ����������� ���� �� ����� ���� �� ������������� ��������.
    // ����� ����������� ������ ���� �������� ����� prepareMetaDataSort ���� ���������� �����
    // � ��� �������� �� �������� ����� �����������
    // c_StrCompare = 1;
    // c_MetaCompare = 2;
    procedure setcomparetype(t: integer); virtual;
  public
    constructor create; virtual;
    destructor destroy; virtual;
    procedure cleardata;
    procedure removeobj(i: integer); override;
    function getobj(name: string): cBaseObj; overload; virtual;
    function getobj(i: integer): cBaseObj; overload;
    procedure addobj(obj: cBaseObj);
    procedure deleteobj(obj: cBaseObj);
    // �������� ������� (�������� ���������� ������� � ���������� �� ������)
    procedure deletechild(i: integer); override;
    procedure deletechild(name: string); overload;
    procedure deletechild(node: pointer); overload; override;
    procedure PrepareMetaDataSort(sortname: string; cl: TClass);
    function find(name: string; var index: integer): boolean; overload; virtual;
    function find(obj: cBaseObj; var index: integer): boolean; overload;
    property comparetype: integer read fcomparetype write setcomparetype;
  end;

function GetNode(node: txmlNode; key: string): txmlNode;

const
  c_BaseObj_Img = 5;
  c_StrCompare = 1;
  c_MetaCompare = 2;
  c_BlueLeft = 30;
  c_BlueRight = 28;
  c_BlueDown = 31;
  c_BlueUpdate = 29;

implementation

uses
  uBaseObjMng;

type
  sList = class(tstringlist)
  protected
    slisttext: string;
  end;

function GetNode(node: txmlNode; key: string): txmlNode;
begin
  result := node.FindNode(key);
  if result = nil then
    result := node.NodeNew(key);
end;

function IsClass(obj: tobject; name: string): boolean;
var
  cl: TClass;
begin
  result := false;
  cl := obj.ClassType;
  if cl.classname = name then
  begin
    result := true;
  end
  else
    while cl.ClassParent <> nil do
    begin
      cl := cl.ClassParent;
      if cl.classname = name then
      begin
        result := true;
        exit;
      end;
    end;
end;

function NameComparator(p1, p2: pointer): integer;
var
  s1, s2: ansistring;
begin
  s1 := cBaseObj(p1).name;
  s2 := cBaseObj(p2).name;
  result := NameComparatorStrBaseNum(s1, s2);
end;

function NameKeyComparator(p1, p2: pointer): integer;
var
  s1, s2: ansistring;
begin
  s1 := string(cBaseObj(p1).name);
  s2 := string(p2^);
  result := NameComparatorStrBaseNum(s1, s2);
end;

function MetaDataCompare(p1, p2: pointer): integer;
var
  o1, o2: cBaseObj;
  prop1, prop2: metadata;
begin
  o1 := cBaseObj(p1);
  o2 := cBaseObj(p2);
  prop1 := o1.metadata.getobj(o1.list.mDataName);
  prop2 := o2.metadata.getobj(o2.list.mDataName);
  if prop1 <> nil then
  begin
    if prop1.ClassType = o1.list.mDataClass then
    begin
      if prop2 = nil then
      begin
        result := 1;
      end
      else
      begin
        if prop2.ClassType <> o1.list.mDataClass then
        begin
          result := 1;
        end
        else
        begin
          result := prop1.compare(prop2);
        end;
      end;
    end
    else
    begin
      if prop2 <> nil then
      begin
        if prop2.ClassType = o1.list.mDataClass then
        begin
          result := -1;
        end
        else
        begin
          result := StrComp(pansichar(p1), pansichar(p2));
        end;
      end
      else
      begin
        result := StrComp(pansichar(p1), pansichar(p2));
      end;
    end;
  end
  else
  begin
    if prop2 = nil then
    begin
      result := StrComp(pansichar(p1), pansichar(p2));
    end
    else
    begin
      result := -1;
    end;
  end;
end;

constructor cBaseObj.create;
begin
  fdefCaption := true;
  fHelper := false;
  fparent := nil;
  blocked := false;
  fname := classname;
  f_caption := classname;
  imageindex := c_BaseObj_Img;
  metadata := MetaDataList.create;
  fBaseObjMng := nil;
  CreateChildrens;
end;

destructor cBaseObj.destroy;
var
  events: ceventlist;
begin
  if assigned(fOnDestroy) then
    fOnDestroy(self);
  metadata.destroy;
  metadata := nil;
  unlinc;
  if not childrens.destroydata then
    unlincChildrens;
  if (fBaseObjMng <> nil) then
  begin
    events := cBaseObjMng(fBaseObjMng).events;
    // ������������� ����
    setMng(nil);
    // ����� ������� ��� ��������� ������� �� �������� �������
    if events <> nil then
      events.CallAllEventsWithSender(E_OnDestroyObject, self);
  end;
  childrens.destroy;
  childrens := nil;
  // ������� ������
  inherited;
end;

function cBaseObj.GetMainParent: cBaseObj;
var
  lparent: cBaseObj;
begin
  lparent := parent;
  if lparent <> nil then
  begin
    if lparent.autocreate then
    begin
      while lparent <> nil do
      begin
        if lparent.autocreate then
        begin
          lparent := lparent.parent;
          if lparent <> nil then
          begin
            if not lparent.autocreate then
              break;
          end
          else
            break;
        end;
      end;
    end;
  end;
  if lparent = nil then
  begin
    if parent <> nil then
    begin
      result := parent;
      exit;
    end;
  end;
  result := lparent;
end;

procedure cBaseObj.SetMainParent(p: cBaseObj);
begin
  parent := p;
end;

function cBaseObj.mainParentClassName: string;
begin
  result := 'cBaseObj';
end;

function cBaseObj.NotSaveToXml: boolean;
begin
  result:=false;
end;

function cBaseObj.isHeader: boolean;
begin
  result := true;
  if parent <> nil then
    result := false;
end;

function cBaseObj.GetRoot: cBaseObj;
var
  obj: cBaseObj;
begin
  obj := parent;
  if obj <> nil then
  begin
    while obj.parent <> nil do
    begin
      obj := obj.parent;
    end;
    result := obj;
  end
  else
  begin
    result := self;
  end;
end;

function cBaseObj.TypeString: String;
begin
  result := '������� ������';
end;

procedure cBaseObj.setMng(m: tobject);
begin
  if (fBaseObjMng <> m) then
  begin
    if ((fBaseObjMng <> nil)) or (m = nil) then
    begin
      unLincMng;
    end;
    // �������� ������ �� eng
    // ReplaceObjMng(m);
    if m <> nil then
    begin
      cBaseObjMng(m).Add(self);
    end;
  end;
end;

function cBaseObj.getMng: tobject;
begin
  result := fBaseObjMng;
end;

procedure cBaseObj.ReplaceObjMng(mng: tobject);
begin
  fBaseObjMng := mng;
end;

procedure cBaseObj.unLincMng;
begin
  if fBaseObjMng <> nil then
  begin
    cBaseObjMng(fBaseObjMng).removeobj(self);
  end;
  // ����������� ��������
  // unlincChildrens;
  // ����������� ��������
  parent := nil;
end;

procedure cBaseObj.SetParentName(parentname: string);
var
  parentObj: cBaseObj;
begin
  parentObj := cBaseObjMng(fBaseObjMng).getobj(parentname);
  if parent <> nil then
    parent := parentObj;
end;

procedure cBaseObj.setShowInGraphs(b: boolean);
begin

end;

procedure cBaseObj.ShowComponent(node: pointer; component: tcomponent);
begin

end;

// ��������� ������� ��������
procedure cBaseObj.setimageind(ind: integer);
begin
  fimageind := ind;
end;

function cBaseObj.getimageindex: integer;
begin
  result := fimageind;
end;

procedure cBaseObj.setImageList(p_imagelist: timagelist);
begin
  cBaseObjMng(fBaseObjMng).images_16 := p_imagelist;
end;

function cBaseObj.getImageList: timagelist;
begin
  if cBaseObjMng(fBaseObjMng) <> nil then
    result := cBaseObjMng(fBaseObjMng).images_16
  else
    result := nil;
end;

// ����� ��������
function cBaseObj.ChildCount: integer;
begin
  if childrens <> nil then
    result := childrens.count;
end;

procedure cBaseObj.setcaption(str: string);
begin
  f_caption := str;
  fdefCaption := false;
end;

function cBaseObj.GetParentName: string;
begin
  if fparent <> nil then
    result := parent.name
  else
    result := '';
end;

procedure cBaseObj.DoBeforeLincParent;
begin

end;

procedure cBaseObj.DoLincParent;
begin

end;

procedure cBaseObj.unlinc;
var
  i, c: integer;
begin
  if fparent <> nil then
  begin
    DoBeforeLincParent;
    for i := 0 to parent.ChildCount - 1 do
    begin
      if fparent.getChild(i) = self then
      begin
        fparent.childrens.removeobj(i);
        c := fparent.ChildCount;
        break;
      end;
    end;
    fparent := nil;
    DoLincParent;
  end;
end;

// ��������� �����
procedure cBaseObj.setname(str: string);
var
  index, lcount: integer;
  b: boolean;
  obj: cBaseObj;
  lname: string;
begin
  lname := fname;
  // ������������� �� ��������
  if parent <> nil then
  begin
    parent.childrens.removeobj(self);
  end;
  if cBaseObjMng(fBaseObjMng) <> nil then
  begin
    b := true;
    while b do
    begin
      obj := cBaseObjMng(fBaseObjMng).getobj(str);
      if obj <> nil then
      begin
        if obj <> self then
        begin
          str := modname(str, false)
        end
        else
          break;
      end
      else
        break;
    end;
    lcount := cBaseObjMng(fBaseObjMng).count;
    // �.�. � ���� ������ ��������������� ������ �������� �� ������ � �� ��������� ��� ��������������
    // cBaseObjMng(fBaseObjMng).removeobj(self);
    cBaseObjMng(fBaseObjMng).objects.removeobj(self);
    fname := str;
    if lcount <> cBaseObjMng(fBaseObjMng).count then
    begin
      cBaseObjMng(fBaseObjMng).objects.addobj(self);
    end;
    cBaseObjMng(fBaseObjMng).events.CallAllEventsWithSender(E_OnRenameObj,
      self);
  end
  else
    fname := str;
  // �������������� � ��������
  if parent <> nil then
  begin
    parent.childrens.addobj(self);
  end;
  if fdefCaption then
    f_caption := fname;
end;

procedure cBaseObj.setParent(p: cBaseObj);
begin
  if (p = nil) then
  begin
    unlinc;
  end;
  if (p <> nil) and (p <> fparent) then
  begin
    p.AddChild(self);
  end;
end;

procedure cBaseObj.AddChild(newChild: cBaseObj);
var
  index: integer;
  str: string;
  m: cBaseObjMng;
begin
  if SupportedChildClass(newChild) then
  begin
    newChild.DoBeforeLincParent;
    if newChild.getMng = nil then
    begin
      m := cBaseObjMng(getMng);
      if m <> nil then
      begin
        newChild.setMng(m);
      end;
    end;
    if newChild.fparent <> nil then
    begin
      if newChild.fparent = self then
        exit;
      newChild.unlinc;
    end;
    str := newChild.name;
    while childrens.find(str, index) do
    begin
      str := modname(str, true);
    end;
    if str <> newChild.name then
      newChild.name := str;
    childrens.addobj(newChild);
    newChild.fparent := self;
    newChild.DoLincParent;
  end;
end;

procedure cBaseObj.lincTo(p_parent: cBaseObj);
begin
  p_parent.AddChild(self);
end;

// �������� ������� �� �����
function cBaseObj.getChild(name: string): cBaseObj;
begin
  result := childrens.getobj(name);
end;

function cBaseObj.getChild(i: integer): cBaseObj;
begin
  result := childrens.getobj(i);
end;

function cBaseObj.fEnumGroupMembers(proc: enumProc; data: pointer;
  var continue: boolean): boolean;
var
  i: integer;
  obj: cBaseObj;
begin
  result := true;
  if continue then
  begin
    continue := proc(self, data);
    if continue then
    begin
      for i := 0 to ChildCount - 1 do
      begin
        obj := getChild(i);
        obj.fEnumGroupMembers(proc, data, continue);
        if not continue then
          exit;
      end;
    end;
  end;
end;

procedure cBaseObj.EnumGroupMembers(proc: enumProc; data: pointer);
var
  continue: boolean;
begin
  continue := true;
  fEnumGroupMembers(proc, data, continue);
end;

procedure cBaseObj.unlincChildrens;
var
  obj: cBaseObj;
begin
  while ChildCount <> 0 do
  begin
    obj := getChild(0);
    obj.parent := nil;
  end;
end;

function cBaseObj.find(name: string; var index: integer): boolean;
begin
  result := childrens.find(name, index);
end;

function cBaseObj.SupportedChildClass(obj: cBaseObj): boolean;
begin
  if obj is cBaseObj then
    result := true
  else
    result := false;
end;

function cBaseObj.SupportedChildClass(classname: string): boolean;
var
  i: integer;
begin
  result := true;
end;

function cBaseObj.SupportedChildClass(objtype: integer): boolean;
begin
  result := true;
end;

procedure cBaseObj.destroychildrens;
begin
  while ChildCount <> 0 do
  begin
    deletechild(0);
  end;
end;

procedure cBaseObj.clear;
begin
  destroychildrens;
end;

procedure cBaseObj.deletechild(i: integer);
begin
  childrens.deletechild(i);
end;

procedure cBaseObj.deletechild(name: string);
begin
  childrens.deletechild(name);
end;

procedure cBaseObj.deletechild(node: pointer);
begin
  childrens.deleteobj(cBaseObj(node));
end;

function cBaseObj.GetParentByClassName(p_classname: string): cBaseObj;
var
  node: cBaseObj;
begin
  result := nil;
  node := self;
  while (node.parent <> nil) do
  begin
    if IsClass(node.parent, p_classname) then
    begin
      result := node.parent;
      break;
    end;
    node := node.parent;
  end;
end;

function cBaseObj.isParentObj(obj: cBaseObj): boolean;
var
  node: cBaseObj;
begin
  result := false;
  node := self;
  while node.parent <> nil do
  begin
    if node = obj then
    begin
      result := true;
      break;
    end;
    node := node.parent;
  end;
end;

function cBaseObj.HaveCommonParent(obj: cBaseObj): cBaseObj;
var
  node: cBaseObj;
begin
  result := nil;
  node := obj;
  while node.parent <> nil do
  begin
    if isParentObj(node) then
    begin
      result := node;
      break;
    end;
    node := node.parent;
  end;
end;

function CheckChild(obj: cBaseObj; data: pointer): boolean;
var
  cl: TClass;
begin
  result := true;
  cl := obj.ClassType;
  if cl.classname = sList(data).slisttext then
  begin
    sList(data).AddObject(obj.name, obj);
  end
  else
  begin
    while cl.ClassParent <> nil do
    begin
      cl := cl.ClassParent;
      if obj.ClassParent.classname = sList(data).slisttext then
      begin
        sList(data).AddObject(obj.name, obj);
        exit;
      end;
    end;
  end;
end;

function cBaseObj.getChildrensByClassName(p_classname: ansistring): tstringlist;
var
  list: sList;
begin
  list := sList.create;
  list.slisttext := p_classname;
  EnumGroupMembers(CheckChild, list);
  result := list;
end;

function CheckChildCaption(obj: cBaseObj; data: pointer): boolean;
begin
  result := true;
  if obj.caption = sList(data).slisttext then
  begin
    sList(data).AddObject(obj.name, obj);
    // �������� �����
    result := false;
  end;
end;

function cBaseObj.getChildrenByCaption(name: string): cBaseObj;
var
  list: sList;
begin
  list := sList.create;
  list.slisttext := name;
  EnumGroupMembers(CheckChildCaption, list);
  if list.count > 0 then
  begin
    result := cBaseObj(list.objects[0]);
  end
  else
    result := nil;
  list.destroy;
end;

function CheckChildName(obj: cBaseObj; data: pointer): boolean;
begin
  result := true;
  if obj.Name = sList(data).slisttext then
  begin
    sList(data).AddObject(obj.name, obj);
    // �������� �����
    result := false;
  end;
end;

function cBaseObj.getChildrenByName(name: string): cBaseObj;
var
  list: sList;
begin
  list := sList.create;
  list.slisttext := name;
  EnumGroupMembers(CheckChildName, list);
  if list.count > 0 then
  begin
    result := cBaseObj(list.objects[0]);
  end
  else
    result := nil;
  list.destroy;
end;

function cBaseObj.findObj(key: pointer; var ind: integer): cBaseObj;
begin
  ind := childrens.FindobjWithKey(key);
  if ind >= 0 then
    result := cBaseObj(childrens.Get(ind))
  else
    result := nil;
end;

function cBaseObj.getdestroydata: boolean;
begin
  result := childrens.destroydata;
end;

procedure cBaseObj.SetDestroyData(b: boolean);
begin
  childrens.destroydata := b;
end;

procedure cBaseObj.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin

end;

procedure cBaseObj.SaveObjAttributes(xmlNode: txmlNode);
begin
  xmlNode.WriteAttributeBool('AutoCreate', autocreate);
end;

procedure cBaseObj.OnEngCreate;
begin

end;

procedure cBaseObj.CreateChildrens;
begin
  childrens := cBaseObjList.create;
end;

function cBaseObj.getShowInGraphs: boolean;
begin
  result := not fHelper;
end;

constructor cBaseObjList.create;
begin
  inherited;
  destroydata := false;
  comparetype := c_StrCompare;
end;

destructor cBaseObjList.destroy;
begin
  if destroydata then
    cleardata;
  inherited;
end;

// �������� ������� (�������� ���������� ������� � ���������� �� ������)
procedure cBaseObjList.deletechild(i: integer);
var
  obj: cBaseObj;
  b: boolean;
begin
  // b:=false;
  obj := cBaseObj(getobj(i));
  removeobj(i);
  // if obj.name='C_01' then
  // begin
  // b:=true;
  // end;
  if not obj.blocked then
  begin
    if destroydata then
    begin
      // if b then
      // begin
      // logRCInfo('c:\RCInfo5_.txt');
      // end;
      obj.destroy;
      // if b then
      // begin
      // logRCInfo('c:\RCInfo5.txt');
      // b:=false;
      // end;
    end;
  end
  else
    obj.fBaseObjMng := nil;
end;

procedure cBaseObjList.removeobj(i: integer);
var
  obj: cBaseObj;
begin
  obj := getobj(i);
  obj.list := nil;
  inherited;
end;

procedure cBaseObjList.deletechild(name: string);
var
  i: integer;
begin
  if find(name, i) then
    deletechild(i);
end;

procedure cBaseObjList.deletechild(node: pointer);
begin
  cBaseObj(node).destroy;
end;

procedure cBaseObjList.deleteobj(obj: cBaseObj);
var
  i: integer;
  lobj: cBaseObj;
begin
  for i := 0 to count - 1 do
  begin
    lobj := getobj(i);
    if lobj = obj then
    begin
      deletechild(i);
    end;
  end;
end;

procedure cBaseObjList.cleardata;
begin
  while count <> 0 do
  begin
    deletechild(0);
  end;
end;

function cBaseObjList.getobj(name: string): cBaseObj;
var
  index: integer;
begin
  if not find(name, index) then
  begin
    result := nil;
  end
  else
  begin
    result := getobj(index);
  end;
end;

function cBaseObjList.find(obj: cBaseObj; var index: integer): boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to count - 1 do
  begin
    if obj = getobj(i) then
    begin
      result := true;
      index := i;
      exit;
    end;
  end;
end;

function cBaseObjList.find(name: string; var index: integer): boolean;
var
  i: integer;
begin
  result := false;
  if comparetype = c_StrCompare then
  begin
    index := FindobjWithKey(@name);
    if index <> -1 then
      result := true;
  end
  else
  begin
    for i := 0 to count - 1 do
    begin
      if name = getobj(i).name then
      begin
        result := true;
        index := i;
        exit;
      end;
    end;
  end;
end;

procedure cBaseObjList.setcomparetype(t: integer);
begin
  fcomparetype := t;
  if t = c_StrCompare then
  begin
    comparator := NameComparator;
    keyComparator := NameKeyComparator;
  end;
  if t = c_MetaCompare then
  begin
    // ���������� �� ��������
    comparator := MetaDataCompare;
  end;
  sorted := true;
end;

procedure cBaseObjList.addobj(obj: cBaseObj);
begin
  obj.list := self;
  inherited addobj(obj);
end;

procedure cBaseObjList.PrepareMetaDataSort(sortname: string; cl: TClass);
begin
  mDataName := sortname;
  mDataClass := cl;
end;

function cBaseObjList.getobj(i: integer): cBaseObj;
begin
  if i < count then
    result := cBaseObj(GetNode(i))
  else
    result := nil;
end;

end.
