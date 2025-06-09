unit uBladeDB;

interface
uses
  uDBObject, ubaseobj, pathutils, uCommonMath, sysutils, nativexml, classes, uPathMng, dialogs,
  inifiles;

type
  // структура для описания замера внутри регистрации
  TBaseSignal=class
  public
    // копия строки которая лежит в мерафайле, но сохраняется в сигнале для того
    // чтобы знать дату заархивированных сигналов
    m_datestr:string;
    // имя регистратора
    m_RCname:string;
    // путь по которому записал регистратор
    m_path:string;
    // подкаталог регистрации в который нуждно положить замер в базе
    m_folder:string;
    // замер скопирован в базу
    m_copy:boolean;
    // замер хаархивирован
    m_rar:boolean;
  public
  end;

  // базовый класс для хранения информации о данных каталога в xml файле
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
    // использовать str не рекомендуется, тк str это путь, который все равно присваивается далее в методе
    // setpath сразу после создания объекта
    function CreateDBObj(str:string):cDBobject;override;
    procedure doLoadDesc(node:txmlnode);virtual;
    function testpath(str:string):integer;override;
    // вызывается внутри CreateXMLDesc, получает главный узел на вход
    procedure doCreateFiles(node:txmlnode);virtual;
    function getdsc:string;
    //procedure DoLincParent;override;
  public
      // установить тип объекта
    procedure setObjType(s:string); overload;
    procedure setObjType(s:string; delProp:boolean; proplist:tstringlist); overload;
    procedure setObjType(s:string; proplist:tstringlist); overload;
    // сохранить объект в БД
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
    // путь к xml дескриптору
    function XMLDescPath:string;virtual;
    // создание файла xml и каталога если отсутствует запись/ перезапись файла описателя
    // вызывается принудительно, не по событию doLincParent т.к. на момент линковки объект может
    // быть не подготовлен
    function CreateFiles:cXmlFolder;
    procedure renameDirAndDsc(newname:string);
    // удаление с диска файла описателя и самого каталога
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
    m_turbTypes:TStringList;
    m_StageTypes:TStringList;
    m_BladeTypes:TStringList;
  protected
    procedure doCreateFiles(node:txmlnode);override;
  public
    // палучить тип из базы типов
    function getType(s:string):cObjType;
    function XMLDescPath:string;override;
    constructor create;override;
    destructor destroy;override;
  end;

  // испытываемый объект
  cTurbFolder = class(cXmlFolder)
  private

  public

  end;

  // испытания
  cStageFolder = class(cXmlFolder)
  public
    m_date:tdatetime;
  protected

  public

  end;

  // испытания
  cBladeFolder = class(cXmlFolder)
  public

  protected

  public

  end;

  cBladeBase = class(cDB)
  public

  protected
    // вызывается в конструкторе cDB класса
    function createBaseFolder:cDBFolder;override;
  public
    function SelectTurb:cTurbFolder;
    function SelectStage:cStageFolder;
    function SelectBlade:cBladeFolder;
    function root:cBladeBaseFolder;
    // каталог базы данных
    procedure InitBaseFolder(str:string);
    // Создать описатели
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
    // события
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
  g_mbase:=self;

  // папка с dll
  dir:=GetCurrentDir;
  //showmessage(dir);
  regclass(cXmlFolder);
  regclass(cBladeBaseFolder);
end;


function cBladeBase.createBaseFolder: cDBFolder;
begin
  result:=cBladeBaseFolder.create;
end;

destructor cBladeBase.destroy;
begin
  inherited;
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
  lstr:=str+'base.xml';
  xml:=TNativeXml.Create(nil);
  if fileexists(lstr) then
    xml.LoadFromFile(lstr)
  else
  begin
    objtype:=cObjType.create;
    objtype.fname:='ГТЭ-170.1';
    objtype.addProp('Ступеней','2');
    objtype.owner:=cBladeBaseFolder(m_BaseFolder).m_turbTypes;
    cBladeBaseFolder(m_BaseFolder).m_turbTypes.AddObject(objtype.fname,objtype);
    // Типы лопаток
    objtype:=cObjType.create;
    objtype.fname:='62.403-0010.001';
    objtype.addProp('Чертеж','62.403-0010.001');
    objtype.owner:=cBladeBaseFolder(m_BaseFolder).m_BladeTypes;
    cBladeBaseFolder(m_BaseFolder).m_BladeTypes.AddObject(objtype.fname,objtype);

    cXmlFolder(m_BaseFolder).CreateXMLDesc;
  end;
  node:=xml.Root;
  xml.Destroy;
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
  end
  else
    result:=nil;
end;

function cBladeBase.SelectTurb: cTurbFolder;
begin
  if root.selected=nil then
  begin
    if root.ChildCount>0 then
    begin
      root.selected:=cxmlfolder(root.getChild(0));
      result:=cTurbFolder(root.getChild(0));
    end;
  end;
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
  // создаем  каталог если отсутствует
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
  // создаем  xml описатель
  // укорачиваем путь с конца на один уровень
  newpath:=XMLDescPath;
  fld:=ExtractFileDir(newpath);
  if not DirectoryExists(fld) then
    exit;
  if newpath='.xml' then
    exit;
  xml:=TNativeXml.Create(nil);
  //xml.LoadFromFile(fname);
  node:=xml.Root;
  node.name:=name;
  node.WriteAttributeString('Class',classname,'');
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
  // сохраняем свойства объектов
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
  result:=Absolutepath;
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
      // сохраняем возможные свойства объекта
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
    // список возможных типов испытаний
    types:=getNode(node,'TurbineType');
    SaveProperties(types,m_turbTypes);
  end;
  if m_BladeTypes.Count>0 then
  begin
    // список возможных типов испытаний
    types:=getNode(node,'BladeType');
    SaveProperties(types,m_BladeTypes);
  end;
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
    // для пустого типа не требуется чистить свойства объекта
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



end.
