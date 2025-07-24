unit uBladeDB;

interface
uses
  windows,
  uDBObject, ubaseobj, pathutils, uCommonMath, sysutils, nativexml, classes, uPathMng, dialogs,
  inifiles, upoint, ucommontypes, uspmband,
  variants, uExcel, u2dmath;

type
  // ��������� ��� �������� ������ ������ �����������
  TBaseSignal=class
  public
    // ����� ������ ������� ����� � ���������, �� ����������� � ������� ��� ����
    // ����� ����� ���� ���������������� ��������
    m_datestr:string;
    // ��� ������������
    m_RCname:string;
    // ���� �� �������� ������� �����������
    m_path:string;
    // ���������� ����������� � ������� ������ �������� ����� � ����
    m_folder:string;
    // ����� ���������� � ����
    m_copy:boolean;
    // ����� �������������
    m_rar:boolean;
  public
  end;

  cObjType  = class;

  // ������� ����� ��� �������� ���������� � ������ �������� � xml �����
  cXmlFolder = class(cDbFolder)
  public
    selected:cXmlFolder;
  protected
    m_dsc:string;
    m_ObjType:string;
    m_Properties:tstringlist;
  private
    procedure clearProps;
  protected
    procedure setname(str:string);override;
    // ������������ str �� �������������, �� str ��� ����, ������� ��� ����� ������������� ����� � ������
    // setpath ����� ����� �������� �������
    function CreateDBObj(str:string):cDBobject;override;
    procedure doLoadDesc(node:txmlnode);virtual;
    function testpath(str:string):integer;override;
    // ���������� ������ CreateXMLDesc, �������� ������� ���� �� ����
    procedure doCreateFiles(node:txmlnode);virtual;
    function getdsc:string;
    //procedure DoLincParent;override;
  public
    function getObjType:cobjtype;
    // �������� ���� � ���� ����� � ������������
    function getFolder:string;
    // ���������� ��� �������
    procedure setObjType(s:string); overload;
    procedure setObjType(s:string; delProp:boolean; proplist:tstringlist); overload;
    procedure setObjType(s:string; proplist:tstringlist); overload;
    // ��������� ������ � ��
    procedure CreateXMLDesc;
    function PropCount:integer;
    function FindPropertie(pname:string):integer;
    function getPropertyName(i:integer):string;
    function getProperty(pname:string; var success:boolean):string;overload;
    function getProperty(i:integer):string;overload;
    procedure addpropertie(pname:string; val:string);
    procedure Setpropertie(pname:string; val:string);
    procedure delpropertie(i:integer);overload;
    procedure delpropertie(pname:string);overload;
    procedure clearPropertie;
    procedure RenameProp(newname:string;index:integer);overload;
    procedure RenameProp(oldname, newname:string);overload;
    // ���� � xml �����������
    function XMLDescPath:string;virtual;
    // �������� ����� xml � �������� ���� ����������� ������/ ���������� ����� ���������
    // ���������� �������������, �� �� ������� doLincParent �.�. �� ������ �������� ������ �����
    // ���� �� �����������
    function CreateFiles:cXmlFolder;
    procedure renameDirAndDsc(newname:string);
    // �������� � ����� ����� ��������� � ������ ��������
    procedure delFolder;
    constructor create;override;
    destructor destroy;override;
  public
    property ObjType: string read m_ObjType write setobjtype;
    property dsc:string read getdsc;
  end;

  cObjType = class
  private
    fname:string;
  public
    proplist:tstringlist;
    owner:tstringlist;
  public
    constructor create(o:cXmlFolder);overload;
    constructor create;overload;
    destructor destroy;
    procedure clear;
    procedure addProp(t:string; defv:string);
    procedure setPropVal(t:string; defv:string);
    function getval(t:string):string;
    function getProp(t:string):cstring;
  protected
    procedure setname(s:string);
  public
    property name:string read fname write setname;
  end;

  cBladeBaseFolder = class(cXmlFolder)
  public
    // ������ �������� cObjType
    m_turbTypes:TStringList;
    m_StageTypes:TStringList;
    m_BladeTypes:TStringList;
  protected
    procedure doCreateFiles(node:txmlnode);override;
    procedure doLoadDesc(node: txmlnode);override;
  public
    // �������� ��� �� ���� �����
    function getType(s:string):cObjType;
    function XMLDescPath:string;override;
    constructor create;override;
    destructor destroy;override;
  end;

  cStageFolder  = class;

  // ������������ ������
  cTurbFolder = class(cXmlFolder)
  private
    function GetStageCount:integer;
    procedure  SetStageCount(c:integer);
  public
    function GetBladeCount(stageNum:integer):integer;
    procedure Buildreport; overload;
    // ���� � �������
    procedure Buildreport(tmpl:string);overload;
    function GetStage(i:integer):cstageFolder;
    property StageCount:integer read getstagecount write setstagecount;
  end;

  // ���������
  cStageFolder = class(cXmlFolder)
  public
    m_date:tdatetime;
    m_sn:integer;
  protected
    procedure setBlCount(c:integer);
    function getBlCount:integer;
  public
    // �������� ���� ��� �������� �������
    function GetNext(b:cXmlFolder):cXmlFolder;
    function GetPrev(b:cXmlFolder):cXmlFolder;
    function StageNum:integer;
    property BlCount:integer read getBlCount write setBlCount;
  end;

  // ���������
  cBladeFolder = class(cXmlFolder)
  public
    // �������� ���������� ������ ������
    // d - ���� �������������
    // ������: f1...f2_a1_f1_d;f1...f2_an_fn_dn
    m_resStr:string;
    m_res:integer;
    m_sn:integer;
    // false - �����, true - ������
    m_sideCB:boolean;
  protected
    procedure getTones(list:blist);
    procedure doCreateFiles(node:txmlnode);override;
    procedure doLoadDesc(node:txmlnode);override;
  public
    procedure DoLincParent; override;

    function ObjType:string;
    function BladeType:string;
    function BladeReport:string;overload;
    // �������� - ���� � �������
    function ToneCount:integer;
    // f1,f2,threshold
    function Tone(i:integer):point3d;
  end;

  cBladeBase = class(cDB)
  public
    m_sn:integer;
  protected
    // ���������� � ������������ cDB ������
    function createBaseFolder:cDBFolder;override;
    function getObjType(t:string):cObjtype;
    procedure regObjClasses;override;
    // ���������� ������ ��������
    procedure doAfterLoadXML;override;
  public
    function SelectTurb:cTurbFolder;
    function SelectStage:cStageFolder;
    function SelectBlade:cBladeFolder;
    function root:cBladeBaseFolder;
    // ������� ���� ������
    procedure InitBaseFolder(str:string);
    // ������� ���������
    procedure UpdateXMLDescriptors;
    constructor create;override;
    destructor destroy;override;
  end;

  var
    g_mbase:cBladeBase;

  const
    c_img_emptyReg=c_DBFolderImage;
    c_img_CompleteReg=35;
    c_img_NoData=36;
    c_img_RarReg=34;
    // �������
    E_AddNotifyPropertieEvent=$00004000;
    E_ChangePropertieEvent=$00008000;

    function FindMBaseWithObjPath(dbObjPath:string):string;

implementation

{ cMeaBase }
constructor cBladeBase.create;
var
  dir, fname:string;
  list:tstringlist;
begin
  inherited;
  m_sn:=0;
  g_mbase:=self;

  // ����� � dll
  dir:=GetCurrentDir;
  //showmessage(dir);
end;


function cBladeBase.createBaseFolder: cDBFolder;
begin
  result:=cBladeBaseFolder.create;
end;

destructor cBladeBase.destroy;
begin
  inherited;
end;


procedure cBladeBase.doAfterLoadXML;
var
  t:cTurbFolder;
  s:cStageFolder;
  o:cObjType;
  I, j, c: Integer;
begin
  inherited;
  // ������������ ���� �������. ���� ��������� �������� ������ ���
  // �������� � ���� �� ������������ ���
  for I := 0 to root.ChildCount - 1 do
  begin
    t:=cTurbFolder(root.getChild(i));
    o:=t.getObjType;
    for j := 0 to t.ChildCount - 1 do
    begin
      s:=t.GetStage(j);
      if t.GetBladeCount(j)=0 then
      begin
        if s.BlCount>0 then
        begin
          o.addProp('StageBCount_'+IntToStr(i+1), inttostr(s.BlCount));
        end;
      end;
    end;
  end;
end;

function cBladeBase.getObjType(t:string): cObjtype;
begin
  result:=root.getType(t);
end;

procedure cBladeBase.InitBaseFolder(str: string);
var
  xml:tnativexml;
  lstr, prop, val:string;
  node, child, propnode:txmlnode;
  count:integer;
  I: Integer;
  objtype:cObjType;

begin
  inherited;
  lstr:=str+'bladeMdb.xml';
  xml:=TNativeXml.Create(nil);
  if fileexists(lstr) then
  begin
    xml.LoadFromFile(lstr);
    node:=xml.Root;
    root.doloadDesc(node);
    doAfterLoadXML;
    xml.Destroy;
  end
  else
  begin
    objtype:=cObjType.create;
    objtype.fname:='���-170.1';
    objtype.addProp('StageCount','2');
    objtype.owner:=cBladeBaseFolder(m_BaseFolder).m_turbTypes;
    cBladeBaseFolder(m_BaseFolder).m_turbTypes.AddObject(objtype.fname,objtype);
    // ���� �������
    objtype:=cObjType.create;
    objtype.fname:='62.403-0010.001';
    objtype.addProp('������','62.403-0010.001');
    objtype.owner:=cBladeBaseFolder(m_BaseFolder).m_BladeTypes;
    cBladeBaseFolder(m_BaseFolder).m_BladeTypes.AddObject(objtype.fname,objtype);

    cXmlFolder(m_BaseFolder).CreateXMLDesc;
  end;

end;

procedure cBladeBase.regObjClasses;
begin
  inherited;
  regclass(cXmlFolder);
  regclass(cBladeBaseFolder);
  regclass(cTurbFolder);
  regclass(cStageFolder);
  regclass(cBladeFolder);
end;

function cBladeBase.root: cBladeBaseFolder;
begin
  result:=cBladeBaseFolder(m_BaseFolder);
end;

function cBladeBase.SelectStage:cStageFolder;
var
  t:cTurbFolder;
begin
  t:=SelectTurb;
  if t<>nil then
  begin
    if t.selected=nil then
    begin
      if t.ChildCount>0 then
      begin
        t.selected:=cxmlfolder(t.getChild(0));
        result:=cStageFolder(t.selected);
      end;
    end
    else
      result:=cStageFolder(t.selected);
  end
  else
    result:=nil;
end;

function cBladeBase.SelectBlade: cBladeFolder;
var
  s:cStageFolder;
begin
  result:=nil;
  s:=SelectStage;
  if s<>nil then
  begin
    if s.selected=nil then
    begin
      if s.ChildCount>0 then
      begin
        s.selected:=cxmlfolder(s.getChild(0));
        result:=cBladeFolder(s.selected);
      end;
    end
    else
      result:=cBladeFolder(s.selected);
  end;
end;

function cBladeBase.SelectTurb: cTurbFolder;
begin
  result:=nil;
  if root.selected=nil then
  begin
    if root.ChildCount>0 then
    begin
      root.selected:=cxmlfolder(root.getChild(0));
      result:=cTurbFolder(root.getChild(0));
    end;
  end
  else
    result:=cTurbFolder(root.selected);
end;

procedure cBladeBase.UpdateXMLDescriptors;
var
  I: Integer;
  obj:cbaseobj;
begin
  for I := 0 to objects.Count - 1 do
  begin
    obj:=getobj(i);
    if obj is cXMLFolder then
    begin
      cXmlFolder(obj).CreateXMLDesc;
    end;
  end;
end;
{ cXmlFolder }

procedure cXmlFolder.addpropertie(pname, val: string);
var
  prop:cstring;
  I: Integer;
begin
  prop:=nil;
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=pname then
    begin
      prop:=cstring(m_Properties.Objects[i]);
      break;
    end;
  end;
  if prop=nil then
  begin
    prop:=cstring.Create;
    m_Properties.AddObject(pname, prop);
  end;
  if isvalue(val) then
  begin
    if (prop.str='') then
      prop.str:='0';
    if isvalue(prop.str)  then
    begin
      prop.str:=floattostr(strtoFloatExt(val)+strtoFloatExt(prop.str));
    end;
  end
  else
  begin
    prop.str:=val;
  end;
end;

procedure cXmlFolder.Setpropertie(pname:string; val:string);
var
  prop:cString;
  I: Integer;
begin
  prop:=nil;
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=pname then
    begin
      prop:=cString(m_Properties.Objects[i]);
      break;
    end;
  end;
  if prop=nil then
  begin
    prop:=cString.Create;
    m_Properties.AddObject(pname, prop);
  end;
  //if isvalue(val) then
  begin
    prop.str:=val;
  end;
end;

procedure cXmlFolder.clearProps;
var
  I: Integer;
  p:cString;
begin
  for I := 0 to m_Properties.Count - 1 do
  begin
    p:=cString(m_Properties.Objects[i]);
    p.Destroy;
  end;
  m_Properties.Clear;
end;

constructor cXmlFolder.create;
begin
  inherited;
  m_Properties:=tstringlist.Create;
  fUseNotifier:=false;
  selected:=nil;
end;

procedure cXmlFolder.delpropertie(i: integer);
var
  prop:cString;
begin
  if i<=m_Properties.count-1 then
  begin
    prop:=cString(m_Properties.Objects[i]);
    prop.destroy;
    m_Properties.Delete(i);
  end;
end;

procedure cXmlFolder.delFolder;
var
  xmlpath, path:string;
begin
  path:=Absolutepath;
  xmlpath:=XMLDescPath;
  if fileexists(xmlpath) then
  begin
    DeleteFile(xmlpath);
  end;
  if DirectoryExists(path) then
    RemoveDirAll(path);
end;

procedure cXmlFolder.delpropertie(pname: string);
var
  I: Integer;
begin
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=pname then
    begin
      delpropertie(i);
      exit;
    end;
  end;
end;

procedure cXmlFolder.clearPropertie;
var
  I: Integer;
begin
  for I := m_Properties.Count - 1 downto 0 do
  begin
    delpropertie(i);
  end;
end;

destructor cXmlFolder.destroy;
begin
  if parent<>nil then
  begin
    if cXmlFolder(parent).selected=self then
      cXmlFolder(parent).selected:=nil
  end;
  clearProps;
  m_Properties.Destroy;
  inherited;
end;

function cXmlFolder.getPropertyName(i: integer): string;
begin
  result:=m_Properties.Strings[i];
end;

function cXmlFolder.PropCount: integer;
begin
  result:=m_Properties.Count;
end;

procedure cXmlFolder.renameDirAndDsc(newname: string);
var
  dir, newdir, dscfile, newdscfile:string;
begin
  dir:=Absolutepath;
  newdir:=TrimPath(dir)+newname;
  dscfile:=XMLDescPath;
  newdscfile:=TrimPath(dscfile)+newname+'.xml';
  path:=newname;
  if dir<>newdir then
  begin
    if DirectoryExists(dir) then
      renameDir(dir, newdir);
    if FileExists(dscfile) then
      RenameFile(dscfile,newdscfile);
  end;
end;

procedure cXmlFolder.RenameProp(oldname, newname:string);
var
  I: Integer;
begin
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=oldname then
    begin
      m_Properties.Strings[i]:=newname;
    end;
  end;
end;

procedure cXmlFolder.RenameProp(newname: string; index: integer);
begin
  m_Properties.Strings[index]:=newname;
end;

procedure cXmlFolder.setname(str: string);
begin
  inherited;
  if path='' then
  begin
    path:=str;
  end;
end;

function cXmlFolder.getdsc: string;
begin
  result:=m_dsc;
end;

function cXmlFolder.getFolder: string;
begin
  result:=Absolutepath+'\'+extractfilename(Absolutepath);
end;

function cXmlFolder.getObjType: cobjtype;
begin
  result:=g_mbase.getObjType(m_ObjType);
end;

function cXmlFolder.getProperty(i: integer): string;
var
  prop:cString;
begin
  prop:=cString(m_Properties.Objects[i]);
  result:=prop.str;
end;

function cXmlFolder.getProperty(pname: string; var success: boolean): string;
var
  I: Integer;
  prop:cString;
begin
  result:='';
  prop:=nil;
  success:=false;
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=pname then
    begin
      prop:=cString(m_Properties.Objects[i]);
      success:=true;
      break;
    end;
  end;
  if success then
    result:=prop.str;
end;

function cXmlFolder.CreateDBObj(str: string): cDBobject;
var
  xml:tnativexml;
  lstr, prop, val:string;
  node, child, propnode:txmlnode;
  count:integer;
  I: Integer;
begin
  result:=nil;
  lstr:=str+'.xml';
  xml:=TNativeXml.Create(nil);
  xml.LoadFromFile(lstr);
  node:=xml.Root;
  if node<>nil then
  begin
    lstr:=node.ReadAttributeString('Class');
    result:=cDBobject(cBladeBase(getmng).CreateObjByType(lstr));
    if result<>nil then
    begin
      cxmlfolder(result).m_ObjType:=node.ReadAttributeString('ObjType');
      child:=node.FindNode('Properies');
      if child<>nil then
      begin
        count:=child.NodeCount;
        for I := 0 to Count - 1 do
        begin
          propnode:=child.Nodes[i];
          prop:=propnode.name;
          val:=propnode.ReadAttributeString('Value', '');
          cXmlFolder(result).addpropertie(prop, val);
        end;
      end;
      cXmlFolder(result).doLoadDesc(node);
      xml.Destroy;
    end;
  end
  else
    xml.Destroy;
end;

function cXmlFolder.CreateFiles: cXmlFolder;
var
  newpath:string;
  I: Integer;
begin
  // �������  ������� ���� �����������
  newpath:=absolutepath;
  if not DirectoryExists(newpath) then
  begin
    ForceDirectories(newpath);
  end;
  CreateXMLDesc;
end;

procedure cXmlFolder.CreateXMLDesc;
var
  xml:TNativeXml;
  node, props,child :TXmlNode;
  newpath, value, propname, fld:string;
  i:integer;
begin
  // �������  xml ���������
  // ����������� ���� � ����� �� ���� �������
  newpath:=XMLDescPath;
  fld:=ExtractFileDir(newpath);
  if not DirectoryExists(fld) then
  begin
    ForceDirectories(fld);
  end;
  if newpath='.xml' then
    exit;
  xml:=TNativeXml.Create(nil);
  //xml.LoadFromFile(fname);
  node:=xml.Root;
  node.name:=name;
  node.WriteAttributeString('Class',classname,'');
  node.WriteAttributeString('ObjType',m_ObjType,'');
  if m_Properties.Count>0 then
  begin
    props:=getNode(node,'Properies');
    for I := 0 to m_Properties.Count - 1 do
    begin
      propname:=m_Properties.Strings[i];
      child:=getNode(props,propname);
      child.WriteAttributeString('Value',getProperty(i),'');
    end;
  end;
  // ��������� �������� ��������
  doCreateFiles(node);
  xml.XmlFormat:=xfReadable;
  xml.SaveToFile(newpath);
  xml.destroy;
end;

procedure cXmlFolder.doCreateFiles(node: txmlnode);
begin
end;


procedure cXmlFolder.doLoadDesc(node: txmlnode);
begin

end;

function cXmlFolder.FindPropertie(pname: string): integer;
var
  I: Integer;
begin
  result:=-1;
  for I := 0 to m_Properties.Count - 1 do
  begin
    if pname=m_Properties.Strings[i] then
    begin
      result:=i;
      exit;
    end;
  end;
end;

function cXmlFolder.testpath(str: string): integer;
var
  substr:string;
begin
  result:=-1;
  if (str[length(str)]='.') then
  begin
    exit;
  end;
  if isDirectory(str) then
  begin
    substr:=str+'.xml';
    if fileexists(substr) then
    begin
      result:=1;
    end;
  end;
end;

function cXmlFolder.XMLDescPath: string;
begin
  result:=Absolutepath+'.xml';
end;

procedure SaveProperties(node:txmlnode; sList:tstringlist);
var
  I: Integer;
  o:cbaseobj;
  objType:cObjType;
  types,child:txmlnode;
  j,k: Integer;
  propname:string;
  prop:cString;
begin
  types:=node;
  if sList.Count>0 then
  begin
    for I := 0 to sList.Count - 1 do
    begin
      objType:=cObjType(sList.Objects[i]);
      child:=getNode(types,objtype.name);
      child.WriteAttributeInteger('PropCount', objtype.proplist.Count,0);
      // ��������� ��������� �������� �������
      for j := 0 to objtype.proplist.Count - 1 do
      begin
        child.WriteAttributeString('Prop_'+inttostr(j), objtype.proplist.Strings[j],'');
        child.WriteAttributeString('Prop_v_'+inttostr(j), cString(objtype.proplist.Objects[j]).str,'0');
      end;
    end;
  end;
end;


constructor cBladeBaseFolder.create;
begin
  inherited;
  m_turbTypes:=TStringList.Create;
  m_turbTypes.Sorted:=true;
  m_turbTypes.Duplicates:=dupIgnore;

  m_stageTypes:=TStringList.Create;
  m_stageTypes.Sorted:=true;
  m_stageTypes.Duplicates:=dupIgnore;


  m_BladeTypes:=TStringList.Create;
  m_BladeTypes.Sorted:=true;
  m_BladeTypes.Duplicates:=dupIgnore;

end;

destructor cBladeBaseFolder.destroy;
var
  I: Integer;
  prop:cObjType;
begin
  for I := 0 to m_turbTypes.Count - 1 do
  begin
    prop:=cObjType(m_turbTypes.Objects[i]);
    prop.destroy;
  end;
  m_turbTypes.Destroy;

  for I := 0 to m_stageTypes.Count - 1 do
  begin
    prop:=cObjType(m_stageTypes.Objects[i]);
    prop.destroy;
  end;
  m_stageTypes.Destroy;

  for I := 0 to m_BladeTypes.Count - 1 do
  begin
    prop:=cObjType(m_BladeTypes.Objects[i]);
    prop.destroy;
  end;
  m_BladeTypes.Destroy;
  inherited;
end;

procedure cBladeBaseFolder.doCreateFiles(node:txmlnode);
var
  I: Integer;
  o:cbaseobj;
  objType:cObjType;
  types,child:txmlnode;
  j,k: Integer;
  propname:string;
  prop:cString;
begin
  if m_turbTypes.Count>0 then
  begin
    // ������ ��������� ����� ���������
    types:=getNode(node,'TurbineType');
    SaveProperties(types,m_turbTypes);
  end;
  if m_BladeTypes.Count>0 then
  begin
    // ������ ��������� ����� ���������
    types:=getNode(node,'BladeType');
    SaveProperties(types,m_BladeTypes);
  end;
end;

procedure LoadProp(node: txmlnode; sList:tstringlist);
var
  s, s1:string;
  objType:cObjType;
  i, j, k:integer;
  child:txmlnode;
begin
  for I := 0 to node.NodeCount - 1 do
  begin
    child:=node.Nodes[i];
    s:=child.name;
    if slist.Find(s, j) then
    begin
      objtype:=cObjType(slist.Objects[j]);
    end
    else
    begin
      objtype:=cObjType.create;
      objType.name:=child.name;
      objType.owner:=slist;
      slist.AddObject(child.name, objType);
    end;
    objType.owner:=sList;
    j:=child.ReadAttributeInteger('PropCount',0);
    for k := 0 to j - 1 do
    begin
      s:=child.ReadAttributeString('Prop_'+inttostr(k), '');
      s1:=child.ReadAttributeString('Prop_v_'+inttostr(k),'');
      objType.addProp(s, s1);
    end;
  end;
end;

procedure cBladeBaseFolder.doLoadDesc(node: txmlnode);
var
  s, lclass:string;
  objType:cObjType;
  i, j:integer;
  tests,child:txmlnode;
begin
  inherited;
  tests:=node.FindNode('TurbineType');
  LoadProp(tests, m_turbTypes);

  //tests:=node.FindNode('StageType');
  //LoadProp(tests, m_StageTypes);

  tests:=node.FindNode('BladeType');
  LoadProp(tests, m_BladeTypes);
end;

function cBladeBaseFolder.getType(s:string): cObjType;
var
  i:integer;
begin
  result:=nil;
  if m_turbTypes.Find(s, i) then
    result:=cObjType(m_turbTypes.Objects[i]);

  if m_StageTypes.Find(s, i) then
    result:=cObjType(m_StageTypes.Objects[i]);

  if m_BladeTypes.Find(s, i) then
    result:=cObjType(m_BladeTypes.Objects[i]);
end;

function cBladeBaseFolder.XMLDescPath:string;
var
  fldName:string;
begin
  fldName:=extractDirName(DelSlashFromPath(absolutepath));
  result:=absolutepath+fldName+'.xml';
end;

function FindMBaseWithObjPath(dbObjPath:string):string;
var
  lpath, fname, fldname, classname:string;
  xml:tnativexml;
  node:txmlNode;
begin
  lpath:=extractfiledir(dbObjPath);
  fldname:=ExtractFileName(lpath);
  while lpath<>'' do
  begin
    lpath:=DelSlashFromPath(lpath);
    fname:=lpath+'.xml';
    if fileexists(fname) then
    begin
      xml:=TNativeXml.Create(nil);
      xml.LoadFromFile(fname);
      node:=xml.Root;
      classname:=node.ReadAttributeString('Class');
      if (classname='cObjFolder') then
      begin
        result:= TrimPath(lpath);
        result:= DelSlashFromPath(result);
        break;
      end;
    end;
    lpath:=TrimPath(lpath);
    fldname:=ExtractFileDir(lpath);
  end;
end;

procedure cxmlFolder.setObjType(s: string; delProp: boolean; proplist:tstringlist);
var
  I,j,k: Integer;
  pr, objpr:string;
  vPr, vObj:cString;
  find, del:boolean;
begin
  m_ObjType:=s;
  if proplist=nil then
  begin
    // ��� ������� ���� �� ��������� ������� �������� �������
    if s<>'' then
      clearProps;
    exit;
  end;
  for I := 0 to m_Properties.Count-1 do
  begin
    objpr:=m_Properties.Strings[i];
    vObj:=cString(m_Properties.Objects[i]);
    for j:=0 to proplist.Count-1 do
    begin
      pr:=(proplist.Strings[j]);
      if pr=objpr then
      begin
        vPr:=cString(proplist.Objects[j]);
        if vPr=nil then
        begin
          vPr:=cString.Create;
        end;
        vPr.str:=vObj.str;
        break;
      end;
    end;
  end;
  clearProps;
  for I := 0 to proplist.Count - 1 do
  begin
    objpr:=proplist.Strings[i];
    pr:=cString(proplist.Objects[i]).str;
    addpropertie(objpr, pr);
  end;
end;

procedure cxmlFolder.setObjType(s: string; proplist:tstringlist);
begin
  setObjType(s, true, proplist);
end;

procedure cxmlFolder.setObjType(s:string);
var
  otype:cObjType;
begin
  m_ObjType:=s;
end;

{ cObjType }

procedure cObjType.addProp(t, defv: string);
var
  v:cstring;
  ind:integer;
begin
  if proplist.Find(t, ind) then
  begin
    v:=cstring(proplist.Objects[ind]);
    v.str:=defv;
  end
  else
  begin
    v:=cString.Create;
    v.str:=defv;
    proplist.AddObject(t, v);
  end;
end;

function cObjType.getProp(t: string): cString;
var
  ind:integer;
begin
  if proplist.Find(t, ind) then
  begin
    result:=cString(proplist.Objects[ind]);
  end
  else
  begin
    result:=nil;
  end;
end;

function cObjType.getval(t: string): string;
var
  v:cstring;
  ind:integer;
begin
  if proplist.Find(t, ind) then
  begin
    v:=cstring(proplist.Objects[ind]);
    result:=v.str;
  end
  else
  begin
    result:='';
  end;
end;

procedure cObjType.setPropVal(t, defv: string);
var
  v:cstring;
  ind:integer;
begin
  if proplist.Find(t, ind) then
  begin
    v:=cstring(proplist.Objects[ind]);
    v.str:=defv;
  end;
end;

procedure cObjType.clear;
var
  I: Integer;
  v:cString;
begin
  for I := 0 to proplist.Count - 1 do
  begin
    v:=cString(proplist.Objects[i]);
    v.Destroy;
  end;
  proplist.Clear;
end;

constructor cObjType.create(o: cXmlFolder);
var
  I: Integer;
  p:cString;
begin
  proplist:=TStringList.Create;
  proplist.Duplicates:=dupIgnore;
  proplist.Sorted:=true;
  for I := 0 to o.m_Properties.Count - 1 do
  begin
    addProp(o.m_Properties.Strings[i],'0');
  end;
end;

constructor cObjType.create;
begin
  proplist:=TStringList.Create;
  proplist.Duplicates:=dupIgnore;
  proplist.Sorted:=true;
end;

destructor cObjType.destroy;
begin
  proplist.Destroy;
end;

procedure cObjType.setname(s: string);
var
  I: Integer;
begin
  if owner<>nil then
  begin
    for I := 0 to owner.Count - 1 do
    begin
      if owner.Objects[I]=self then
      begin
        owner.Delete(i);
        break;
      end;
    end;
    owner.AddObject(s,self);
  end;
  fname:=s;
end;

{ cBladeFolder }
function cBladeFolder.BladeReport: string;
begin
  result:=Absolutepath+'\'+extractfilename(Absolutepath)+'.xlsx';
end;

function cBladeFolder.BladeType: string;
begin

end;

procedure cBladeFolder.doCreateFiles(node:txmlnode);
var
  lpath:string;
begin
  inherited;
  lpath:=Absolutepath;
  ForceDirectories(lpath);
  node.WriteAttributeInteger('Result',m_res);
  node.WriteAttributeString('ResStr',m_resStr);
  node.WriteAttributeBool('Side',m_sideCB);
end;

procedure cBladeFolder.DoLincParent;
var
  bl:cBladeFolder;
begin
  inherited;
  if m_ObjType='' then
  begin
    if parent<>nil then
    begin
      bl:=cbladefolder(parent.getChild(0));
      m_ObjType:=bl.m_ObjType;
    end;
  end;
end;

procedure cBladeFolder.doLoadDesc(node: txmlnode);
var
  bl:cBladeFolder;
begin
  inherited;
  M_res:=node.ReadAttributeInteger('Result',-1);
  m_resStr:=node.ReadAttributeString('ResStr','');
  m_sideCB:=node.ReadAttributeBool('Side',false);
end;

procedure cBladeFolder.getTones(list: blist);
var
  c, i:integer;
  p3:point3d;
begin
  list.cleardata;
  c := ToneCount;
  for i := 0 to c - 1 do
  begin
    p3 := Tone(i);
    list.addband(p3.x, p3.y, p3.z, nil);
  end;
end;

function cBladeFolder.ObjType: string;
begin
  result:=m_ObjType;
end;

function cBladeFolder.Tone(i: integer): point3d;
var
  o:cObjType;
  s1,s2,s3:string;
begin
  o:=getObjType;
  s1:=o.getval('F1_'+inttostr(i+1));
  s2:=o.getval('F2_'+inttostr(i+1));
  s3:=o.getval('Threshold_'+inttostr(i+1));
  result.x:=strtoFloatExt(s1);
  result.y:=strtofloatExt(s2);
  result.z:=strtofloatExt(s3);
end;

function cBladeFolder.ToneCount: integer;
var
  o:cObjType;
  s:string;
begin
  result:=0;
  o:=getObjType;
  if o<>nil then
  begin
    s:=o.getval('ToneCount');
    result:=strtoint(s);
  end;
end;

{ cStageFolder }

function cStageFolder.GetNext(b: cXmlFolder): cXmlFolder;
var
  bl:cBladeFolder;
  I: Integer;
begin
  result:=nil;
  if b=nil then
  begin
    result:=cBladeFolder(getchild(0));
    exit;
  end;
  for I := 0 to ChildCount - 2 do
  begin
    bl:=cBladeFolder(getchild(i));
    if bl=b then
    begin
      result:=cBladeFolder(getchild(i+1));
      exit;
    end;
  end;
end;

function cStageFolder.GetPrev(b: cXmlFolder): cXmlFolder;
var
  bl:cBladeFolder;
  I: Integer;
begin
  result:=nil;
  for I := ChildCount - 1 downto 1 do
  begin
    bl:=cBladeFolder(getchild(i));
    if bl=b then
    begin
      result:=cBladeFolder(getchild(i-1));
      exit;
    end;
  end;
end;

procedure cStageFolder.setBlCount(c: integer);
var
  bl:cBladeFolder;
  f:string;
begin
  while c<>ChildCount do
  begin
    if c>ChildCount then
    begin
      bl:=cBladeFolder.create;
      if cBladeFolder(selected)<>nil then
      begin
        bl.setObjType(cBladeFolder(selected).ObjType);
      end;
      bl.name:='Bl_'+inttostr(ChildCount+1);
      AddChild(bl);
    end
    else
    begin
      bl:=cBladeFolder(getchild(ChildCount-1));
      f:=bl.Absolutepath;
      DeleteFile(f);
      bl.destroy;
    end;
  end;
end;

function cStageFolder.StageNum: integer;
var
  I: Integer;
begin
  result:=0;
  for I := 0 to parent.childCount - 1 do
  begin
    if parent.getChild(i)=self then
    begin
      result:=i;
      exit;
    end;
  end;
end;

function cStageFolder.getBlCount: integer;
begin
  result:=ChildCount;
end;

{ cTurbFolder }

procedure cTurbFolder.Buildreport;
var
  r0, i, j, r, c: integer;
  b: tspmband;
  extr: PExtremum1d;
  date: TDateTime;
  res: boolean;
  rng: olevariant;
  str, str1, str2, repPath: string;
  minmax: point2d;
  v: double;
  turb: cTurbFolder;
  stage: cStageFolder;
  blade: cBladeFolder;
begin
  if VarIsEmpty(E) then
  begin
    // if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;
  turb := g_mbase.SelectTurb;
  stage := g_mbase.SelectStage;
  blade := g_mbase.SelectBlade;
  repPath := turb.getFolder + 'Report.xlsx';
  if fileexists(repPath) then
  begin
    if not IsExcelFileOpen(repPath) then
    begin
      OpenWorkBook(repPath);
      ClearExcelSheet(E,1,false);
    end
  end
  else
  begin
    AddWorkBook;
    AddSheet('Page_01');
  end;
  r0 := GetEmptyRow(1, 1, 2);
  SetCell(1, r0, 2, '�������:');
  SetCell(1, r0, 3, turb.ObjType);
  SetCell(1, r0, 4, '�������:');
  SetCell(1, r0, 5, stage.m_sn);
  inc(r0);
  SetCell(1, r0, 2, '����� �������:');
  SetCell(1, r0, 3, stage.BlCount);
  inc(r0);
  SetCell(1, r0, 2, '�������');
  SetCell(1, r0, 3, 'Band');
  SetCell(1, r0, 4, 'A1');
  SetCell(1, r0, 5, 'F1');
  // ������ �� ������ (�������)
  blade := nil;
  for i := 0 to stage.BlCount - 1 do
  begin
    inc(r0);
    blade := cBladeFolder(stage.GetNext(blade));
    if i=0 then
      c:=blade.ToneCount;
    SetCell(1, r0, 2, blade.name);
    // c - ����� �����
    for j := 0 to c - 1 do
    begin
      str := getSubStrByIndex(blade.m_resStr, ';', 1, j);
      // f1..f2
      str1 := getSubStrByIndex(str, '_', 1, 0);
      SetCell(1, r0, 3, str1);
      // A
      str1 := getSubStrByIndex(str, '_', 1, 1);
      // F
      str2 := getSubStrByIndex(str, '_', 1, 2);
      SetCell(1, r0, 4, strtofloatext(str1));
      SetCell(1, r0, 5, strtofloatext(str2));
      if blade.m_res = 1 then
      begin
        rng := GetRangeObj(1, point(r0, 2), point(r0, 5));
        rng.Interior.Color := RGB(255, 165, 0); // ��������� ����;
      end;
    end;
  end;
  SaveWorkBookAs(repPath);
  CloseWorkBook;
  CloseExcel;
end;

procedure cTurbFolder.Buildreport(tmpl: string);
var
  r0, i, j, r,col, c, c2: integer;
  b: tspmband;
  extr: PExtremum1d;
  date: TDateTime;
  res: boolean;
  rng, rng2: olevariant;
  str, str1, str2, repPath: string;
  tp:tpoint;
  p3:point3d;
  minmax: point2d;
  v: double;
  turb: cTurbFolder;
  stage: cStageFolder;
  blade: cBladeFolder;
begin
  if tmpl='' then
  begin
    tmpl:=g_mbase.root.Absolutepath+'Template\Report_tmpl.xlsx';
  end;
  if VarIsEmpty(E) then
  begin
    // if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;
  if fileexists(tmpl) then
  begin
    if not IsExcelFileOpen(tmpl) then
    begin
      OpenWorkBook(tmpl);
    end;

    turb := g_mbase.SelectTurb;
    stage := g_mbase.SelectStage;
    blade := g_mbase.SelectBlade;

    rng:=GetRange(1,'c_Sketch');
    rng:=blade.m_ObjType;
    rng:=GetRange(1,'c_BlCount');
    rng.value:=stage.BlCount;
    rng:=GetRange(1,'c_ToneCount');
    c:=rng.value;
    rng:=GetRange(1,'c_ToneCount2');
    c2:=rng.value;

    rng.value:=blade.ToneCount;
    rng:=GetRange(1,'c_Tone');
    rng2:=GetRange(1,'c_Start');
    for I := 0 to blade.ToneCount - 1 do
    begin
      SetCell(1, rng.Row-1, rng.Column+i, i+1);
      p3:=blade.Tone(i);
      SetCell(1, rng.Row, rng.Column+i, p3.x);
      SetCell(1, rng.Row+1,rng.Column+i, p3.y);

      SetCell(1, rng2.Row-1,rng2.Column+2+i*3, p3.x);
      SetCell(1, rng2.Row-1,rng2.Column+4+i*3, p3.y);
    end;
    rng:=GetRange(1,'c_Type');
    rng.value:=turb.m_ObjType;
    rng:=GetRange(1,'c_Stage');
    rng.value:=stage.StageNum;
    for I := 0 to stage.BlCount - 1 do
    begin
      SetCell(1, rng2.Row+i,rng2.Column+1, blade.m_sn);
      for j := 0 to blade.ToneCount - 1 do
      begin
        str := getSubStrByIndex(blade.m_resStr, ';', 1, j);
        // F
        str2 := getSubStrByIndex(str, '_', 1, 2);
        r:=rng2.Row+i;
        col:=rng2.Column+2+j*3;
        SetCell(1, r,col, strtofloatext(str2));
      end;
      str2 := getSubStrByIndex(str, '_', 1, 3);
      rng:=GetRange(1,'c_Start');
      //tp:=point(r,rng2.column+c*3+2+c2);
      //rng:=GetRangeObj(1,tpoint(tp),tp);
      rng:=GetRange(1,'c_decr');
      rng.value:=strtofloatext(Str2);
      if blade.m_res=2 then
      begin
        SetCell(1, rng.Row+i,rng.Column+1, '�����');
      end;
      if blade.m_res=1 then
      begin
        rng := GetRangeObj(1, point(rng2.row, rng.column),
                              point(rng2.row, rng2.column+1));
        rng.Interior.Color := RGB(255, 165, 0); // ��������� ����;
        SetCell(1, rng2.Row+i,rng2.Column+1, '�� �����');
      end;
    end;
  end;
  repPath := ExtractFileDir(turb.getFolder) + '\Report.xlsx';
  SaveWorkBookAs(repPath);
  CloseWorkBook;
  CloseExcel;
end;

function cTurbFolder.GetBladeCount(stageNum: integer): integer;
var
  o:cObjType;
  s:cString;
begin
  o:=getObjType;
  s:=o.getProp('StageBCount_'+inttostr(stageNum+1));
  if s<>nil then
    result:=strtoint(s.str)
  else
    result:=0;
end;

function cTurbFolder.GetStage(i: integer): cstageFolder;
begin
  result:=cstageFolder(getchild(i));
end;

function cTurbFolder.GetStageCount: integer;
var
  o:cObjType;
  s:cString;
begin
  o:=getObjType;
  s:=o.getProp('StageCount');
  if s<>nil then
    result:=strtoint(s.str)
  else
    result:=0;
end;

procedure cTurbFolder.SetStageCount(c: integer);
var
  o:cObjType;
  s:cString;
begin
  o:=getObjType;
  o.addProp('StageCount', inttostr(c));
end;

end.
