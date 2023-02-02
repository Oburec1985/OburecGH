unit uMeasureBase;

interface
uses
  uDBObject, ubaseobj, pathutils, uCommonMath, sysutils, nativexml, classes, uPathMng, ZipMstr, dialogs,
  inifiles;

type
  TProp = class
  public
    value:string;
  end;

  // структура для описания замера внутри регистрации
  TBaseSignal=class
  public
    // копия строки которая лежит в мерафайле, но сохраняется в сигнале для того чтобы знать дату заархивированных сигналов
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
  protected
    m_dsc:string;
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
    procedure RenameProp(newname:string;index:integer);
    // путь к xml дескриптору
    function XMLDescPath:string;
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
    property dsc:string read getdsc;
  end;

  cBaseMeaFolder = class(cXmlFolder)
  public
    m_TestTypes:tstringlist;
    m_ObjTypes:tstringlist;
  protected
    // вызывается внутри CreateXMLDesc, получает главный узел на вход
    procedure doCreateFiles(node:txmlnode);override;
    procedure doLoadDesc(node:txmlnode);override;
  public
    function LoadObjProperties(objType:string):tstringlist;
    constructor create;override;
    destructor destroy;override;
  end;
  // испытываемый объект
  cObjFolder = class(cXmlFolder)
  public
    m_ObjType:string;
  protected
    // вызывается внутри CreateXMLDesc, получает главный узел на вход
    procedure doCreateFiles(node:txmlnode);override;
    procedure doLoadDesc(node:txmlnode);override;
  end;
  // испытания
  cTestFolder = class(cXmlFolder)
  public
    m_testType:string;
    m_date:tdatetime;
  protected
    // Установка имени
    procedure setname(str:string);override;
    // вызывается внутри CreateXMLDesc, получает главный узел на вход
    procedure doCreateFiles(node:txmlnode);override;
    procedure doLoadDesc(node:txmlnode);override;
  public
    function DateTime:tdatetime;
  end;
  // каталог содержит регистрации
  cRegFolder = class(cXmlFolder)
  public
    m_date:tdatetime;
    // список записей внутри регистратора
    m_signals:tstringlist;
    // наличие аварии
    m_alarm:boolean;
    m_alarmType:string;
    m_alarmDsc:string;
  protected
    procedure doCreateFiles(node:txmlnode);override;
    procedure doLoadDesc(node:txmlnode);override;
    function getimageindex:integer;override;
  public
    // данные регистрации заархивированы
    function rar:boolean;
    // размер записаных файлов 0 или вообще нет данных
    function NoData:boolean;
    function MakeZip:boolean;
    // данные регистрации скопированы
    function Complete:boolean;
    // пустая регистрация или уже содержит записи
    function empty:boolean;
    function AddSignal(Rcname, path, folder:string):TBaseSignal;
    function getMeraPath(i:integer):string;
    function getSignal(i:integer):TBaseSignal;
    function dateTime:tdatetime;
    constructor create;override;
    destructor  destroy;override;
  end;

  cLastCfgFolder = class(cXmlFolder)

  end;

  cMBase = class(cDB)
  public
    m_zip:tzipmaster;
  public
    // имена базовых папок
  protected
    // вызывается в конструкторе cDB класса
    function createBaseFolder:cDBFolder;override;
  public
    procedure InitBaseFolder(str:string);override;
    function getRegByMeraFile(merafile:string):cRegFolder;
    // пересохраняет все xml описатели всех объектов
    procedure UpdateXMLDescriptors;
    constructor create;override;
    destructor destroy;override;
  end;

  var
    g_mbase:cMBase;

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
constructor cMBase.create;
var
  dir, fname:string;
  list:tstringlist;
begin
  inherited;
  g_mbase:=self;
  m_zip:=TZipMaster.Create(nil);

  // папка с dll
  dir:=GetCurrentDir;
  //showmessage(dir);
  fname:=FindFile('DelZip179.dll',dir,3);
  if fileexists(fname) then
  begin
    //showmessage(fname);
    dir:=ExtractFileDir(fname);
    m_zip.DLLDirectory:=dir;
    //showmessage(m_zip.DLLDirectory);

    m_zip.Dll_Load := true;
  end;
  regclass(cTestFolder);
  regclass(cRegFolder);
  regclass(cObjFolder);
  regclass(cLastCfgFolder);
  regclass(cXmlFolder);
end;

function cMBase.createBaseFolder: cDBFolder;
begin
  result:=cBaseMeaFolder.create;
end;

destructor cMBase.destroy;
begin
  m_zip.Destroy;
  inherited;
end;

function cMBase.getRegByMeraFile(merafile: string): cRegFolder;
var
  lpath, fname, fldname, classname:string;
  xml:tnativexml;
  node:txmlNode;
begin
  lpath:=extractfiledir(merafile);
  lpath:=DelSlashFromPath(trimpath(lpath));
  fldname:=ExtractFilename(lpath);

  fname:=lpath+'.xml';
  result:=cRegFolder(getchildbypath(lpath));
end;

procedure cMBase.InitBaseFolder(str: string);
var
  xml:tnativexml;
  lstr, prop, val:string;
  node, child, propnode:txmlnode;
  count:integer;
  I: Integer;
begin
  inherited;
  lstr:=str+'.xml';
  xml:=TNativeXml.Create(nil);
  xml.LoadFromFile(lstr);
  node:=xml.Root;
  cBaseMeaFolder(m_BaseFolder).doloadDesc(node);
  xml.Destroy;
end;

procedure cMBase.UpdateXMLDescriptors;
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
  prop:TProp;
  I: Integer;
begin
  prop:=nil;
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=pname then
    begin
      prop:=Tprop(m_Properties.Objects[i]);
      break;
    end;
  end;
  if prop=nil then
  begin
    prop:=TProp.Create;
    m_Properties.AddObject(pname, prop);
  end;
  if isvalue(val) then
  begin
    if (prop.value='') then
      prop.value:='0';
    if isvalue(prop.value)  then
    begin
      prop.value:=floattostr(strtofloat(val)+strtofloat(prop.value));
    end;
  end;
  if getmng<>nil then
  begin
    cMBase(getmng).Events.CallAllEventsWithSender(E_ChangePropertieEvent,self);
  end;
end;

procedure cXmlFolder.Setpropertie(pname:string; val:string);
var
  prop:TProp;
  I: Integer;
begin
  prop:=nil;
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=pname then
    begin
      prop:=Tprop(m_Properties.Objects[i]);
      break;
    end;
  end;
  if prop=nil then
  begin
    prop:=TProp.Create;
    m_Properties.AddObject(pname, prop);
  end;
  //if isvalue(val) then
  begin
    prop.value:=val;
  end;
  if getmng<>nil then
  begin
    cMBase(getmng).Events.CallAllEventsWithSender(E_ChangePropertieEvent,self);
  end;
end;

procedure cXmlFolder.clearProps;
var
  I: Integer;
  p:tprop;
begin
  for I := 0 to m_Properties.Count - 1 do
  begin
    p:=tprop(m_Properties.Objects[i]);
    p.Destroy;
  end;
  m_Properties.Clear;
end;

constructor cXmlFolder.create;
begin
  inherited;
  m_Properties:=tstringlist.Create;
  fUseNotifier:=false;

end;

procedure cXmlFolder.delpropertie(i: integer);
var
  prop:tprop;
begin
  if i<=m_Properties.count-1 then
  begin
    prop:=tprop(m_Properties.Objects[i]);
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
  prop:TProp;
begin
  prop:=TProp(m_Properties.Objects[i]);
  result:=prop.value;
end;

function cXmlFolder.getProperty(pname: string; var success: boolean): string;
var
  I: Integer;
  prop:TProp;
begin
  result:='';
  prop:=nil;
  success:=false;
  for I := 0 to m_Properties.Count - 1 do
  begin
    if m_Properties.Strings[i]=pname then
    begin
      prop:=TProp(m_Properties.Objects[i]);
      success:=true;
      break;
    end;
  end;
  if success then
    result:=prop.value;
end;

function cXmlFolder.CreateDBObj(str: string): cDBobject;
var
  xml:tnativexml;
  lstr, prop, val:string;
  node, child, propnode:txmlnode;
  count:integer;
  I: Integer;
begin
  lstr:=str+'.xml';
  xml:=TNativeXml.Create(nil);
  xml.LoadFromFile(lstr);
  node:=xml.Root;
  lstr:=node.ReadAttributeString('Class');
  result:=cDBobject(cMBase(getmng).CreateObjByType(lstr));
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
  doCreateFiles(node);
  xml.XmlFormat:=xfReadable;
  xml.SaveToFile(newpath);
  xml.destroy;
end;

procedure cXmlFolder.doCreateFiles(node: txmlnode);
begin
end;

//procedure cXmlFolder.DoLincParent;
//begin
//  inherited;
//  if parent<>nil then
//  begin
//    CreateFiles;
//  end;
//end;

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
  result:=DelSlashFromPath(absolutepath);
  result:=result+'.xml';
end;

{ TBaseSignal }


{ cRegFolder }

function cRegFolder.AddSignal(Rcname, path, folder: string): TBaseSignal;
begin
  result:=TBaseSignal.create;
  result.m_path:=path;
  result.m_folder:=folder;
  result.m_Rcname:=Rcname;
  if result.m_folder='' then
    result.m_folder:=Rcname;
  m_signals.AddObject(rcname, result);
end;

function cRegFolder.Complete: boolean;
var
  I: Integer;
  s:TBaseSignal;
begin
  if empty then
  begin
    result:=false;
  end
  else
  begin
    result:=true;
  end;
  for I := 0 to m_signals.Count - 1 do
  begin
    s:=getSignal(i);
    if not s.m_copy then
    begin
      result:=false;
      exit;
    end;
  end;
end;

constructor cRegFolder.create;
begin
  inherited;
  m_signals:=TStringList.Create;
end;

function cRegFolder.dateTime: tdatetime;
var
  I: Integer;
  s:TBaseSignal;
  f:tinifile;
  str:string;
  d:tdatetime;
begin
  if m_date=0 then
  begin
    for I := 0 to m_signals.Count - 1 do
    begin
      s:=getSignal(i);
      if s.m_rar then
      begin
        str:=s.m_datestr;
      end
      else
      begin
        f:=TIniFile.Create(s.m_path);
        str:=f.ReadString('MERA','Date','');
        f.Destroy;
      end;
      if str='' then
        d:=0
      else
        d:=StrToDate(str);
      if d>m_date then
        m_date:=d;
    end;
  end;
  if m_date=0 then
  begin
    m_date:=GetDirTime(Absolutepath);
  end;
  result:=m_date;
end;

destructor cRegFolder.destroy;
var
  I: Integer;
  s:TBaseSignal;
begin
  for I := 0 to m_signals.Count - 1 do
  begin
    s:=getSignal(i);
    s.destroy;
  end;
  m_signals.Destroy;
  inherited;
end;

procedure cRegFolder.doCreateFiles(node: txmlnode);
var
  I: Integer;
  s:TBaseSignal;
  signals,child, regprops:txmlnode;

begin
  if m_signals.Count>0 then
  begin
    signals:=getNode(node,'Signals');
    //node.WriteAttributeInteger('SignalsCount',m_signals.Count,0);
    for I := 0 to m_signals.Count - 1 do
    begin
      s:=getSignal(i);
      child:=getNode(signals,s.m_RCname);
      child.WriteAttributeString('Class','TBaseSignal','');
      child.WriteAttributeString('RCname',s.m_RCname,'');
      child.WriteAttributeString('RCPath',s.m_path,'');
      child.WriteAttributeString('SubFolder',s.m_folder,'');
      child.WriteAttributeBool  ('Copydata',s.m_copy,false);
      child.WriteAttributeBool  ('Rar',s.m_rar,false);
      if s.m_datestr<>'' then
      begin
        child.WriteAttributeString('DateStr',s.m_datestr,'');
      end;
    end;
  end;
  regprops:=getNode(node,'RegProps');
  regprops.WriteAttributeBool('Alarm',m_alarm,false);
  regprops.WriteAttributeString('AlarmType',m_alarmType,'');
  regprops.WriteAttributeString('AlarmDsc',m_alarmDsc,'');
end;

procedure cRegFolder.doLoadDesc(node: txmlnode);
var
  s:TBaseSignal;
  i,SignalsCount:integer;
  signals,regprops,child:txmlnode;
  lClass,lrcname, lsubfolder, lrcpath:string;
begin
  inherited;
  signals:=node.FindNode('Signals');
  if signals<>nil then
  begin
    for I := 0 to signals.NodeCount - 1 do
    begin
      child:=signals.Nodes[i];
      lClass:=child.ReadAttributeString('Class','');
      if lClass='TBaseSignal' then
      begin
        lrcname:=child.ReadAttributeString('RCname','');
        lrcpath:=child.ReadAttributeString('RCPath','');
        lsubfolder:=child.ReadAttributeString('SubFolder','');
        s:=AddSignal(lrcname,lrcpath,lsubfolder);
        s.m_copy:=child.ReadAttributeBool('Copydata',false);
        s.m_rar:=child.ReadAttributeBool('Rar',false);
        s.m_datestr:=child.ReadAttributeString('DateStr','');
      end;
    end;
  end;
  regprops:=node.FindNode('RegProps');
  if regprops<>nil then
  begin
    m_alarm:=regprops.ReadAttributeBool('Alarm',false);
    m_alarmType:=regprops.ReadAttributeString('AlarmType','');
    m_alarmDsc:=regprops.ReadAttributeString('AlarmDsc','');
  end;
end;

function cRegFolder.empty: boolean;
begin
  empty:=(m_signals.count=0);
end;

function cRegFolder.getimageindex: integer;
begin
  Result:=inherited;
  if rar then
  begin
    result:=c_img_RarReg;
    exit;
  end;
  if NoData then
  begin
    result:=c_img_Nodata;
    exit;
  end;
  if empty then
  begin
    result:=c_img_emptyReg;
    exit;
  end;
  if Complete then
  begin
    result:=c_img_CompleteReg;
    exit;
  end;
end;

function cRegFolder.getSignal(i:integer): TBaseSignal;
begin
  result:=TBaseSignal(m_signals.Objects[i]);
end;

function cRegFolder.getMeraPath(i:integer):string;
var
  s:TBaseSignal;
  fld:string;
begin
  s:=getSignal(i);
  result:='';
  if s.m_copy then
  begin
    fld:=AddSlashToPath(Absolutepath)+s.m_RCname;
    result:=FindFile('*.mera',fld,1);
  end
  else
  begin
    result:=s.m_path;
  end;
end;

function cRegFolder.MakeZip:boolean;
var
  db:cMBase;
  path, str,zippath:string;
  list:tstringlist;
  I: Integer;
  s:tbasesignal;
  j: Integer;
  f:tinifile;
begin
  if rar then
    exit;
  if Complete then
  begin
    db:=cMBase(getmng);
    list:=tstringlist.Create;
    for I := 0 to m_signals.count - 1 do
    begin
      s:=getSignal(i);

      f:=TIniFile.Create(s.m_path);
      str:=f.ReadString('MERA','Date','');
      s.m_datestr:=str;
      f.Destroy;

      path:=AddSlashToPath(Absolutepath)+s.m_folder;
      zippath:=path+'.zip';
      db.m_zip.ZipFileName:=zippath;
      db.m_zip.AddOptions:=db.m_zip.AddOptions
                           //+[AddDirNames]
                           //+[AddSeparateDirs]
                           //+[AddRecurseDirs]
                           ;
      db.m_zip.FSpecArgs.Clear;
      list.clear;
      ScanDir(path, '*.*', list);
      for j := 0 to List.Count - 1 do
      begin
        str:=list.Strings[j];
        if extractfileext(str)<>'zip' then
        begin
          db.m_zip.FSpecArgs.Add(list.Strings[j]);
        end;
      end;
      if db.m_zip.FSpecArgs.Count>0 then
      begin
        db.m_zip.add;
        //db.m_zip.Clear;
        RemoveDirAll(path);
        //db.m_zip.SuccessCnt
        s.m_rar:=true;
      end;
    end;
  end;
  CreateFiles;
end;

function cRegFolder.NoData: boolean;
var
  I, j: Integer;
  s:TBaseSignal;

  merapath, datpath, fld:string;

  f:tinifile;
  sections:tstringlist;
begin
  result:=true;
  sections:=tstringlist.create;
  for I := 0 to m_signals.Count - 1 do
  begin
    s:=getSignal(i);
    merapath:=getMeraPath(i);
    if fileexists(merapath) then
    begin
      fld:=AddSlashToPath(ExtractFileDir(merapath));
      f:=TIniFile.Create(merapath);
      sections.clear;
      f.ReadSections(sections);
      for j := 0 to sections.Count - 1 do
      begin
        if lowercase(sections.Strings[j])<>'mera' then
        begin
          datpath:=fld+sections.Strings[j]+'.dat';
          if fileexists(datpath) then
          begin
            if not IsOpen(datpath) then
            begin
              if GetFileSize(datpath)>0 then
              begin
                result:=false;
                sections.destroy;
                exit;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  sections.destroy;
end;

function cRegFolder.rar: boolean;
var
  i:integer;
  s:TBaseSignal;
begin
  if empty then
  begin
    result:=false;
  end
  else
  begin
    result:=true;
  end;
  for I := 0 to m_signals.Count - 1 do
  begin
    s:=getSignal(i);
    if not s.m_rar then
    begin
      result:=false;
      exit;
    end;
  end;
end;


{ cTestFolder }
function cTestFolder.DateTime: tdatetime;
var
  I: Integer;
  o:cbaseobj;
  r:cregFolder;
  d:tdatetime;
begin
  r:=nil;
  for I := 0 to ChildCount - 1 do
  begin
    o:=getChild(i);
    if o is cRegFolder then
    begin
      r:=cRegFolder(o);
    end
    else
      continue;
    if d<>0 then
    begin
      if m_date=0 then
        m_date:=d
      else
      begin
        if d<m_date then
          m_date:=d;
      end;
    end;
  end;
  if m_date=0 then
  begin

  end;
  result:=m_date;
end;

procedure cTestFolder.doCreateFiles(node: txmlnode);
begin
  inherited;
  node.WriteAttributeString('TestType',m_testType,'');
end;

procedure cTestFolder.doLoadDesc(node: txmlnode);
begin
  inherited;
  m_testType:=node.ReadAttributeString('TestType','');
end;

procedure cTestFolder.setname(str: string);
var
  s:string;
begin
  s:=f_caption;
  inherited;
  if f_caption<>extractfilename(path) then
  begin
    f_caption:=path;
  end
end;

{ сBaseMeaFolder }

constructor cBaseMeaFolder.create;
begin
  inherited;
  m_TestTypes:=TStringList.Create;
  m_TestTypes.Sorted:=true;
  m_TestTypes.Duplicates:=dupIgnore;

  m_ObjTypes:=TStringList.Create;
  m_ObjTypes.Sorted:=true;
  m_ObjTypes.Duplicates:=dupIgnore;
end;

destructor cBaseMeaFolder.destroy;
begin
  m_testTypes.destroy;
  m_ObjTypes.Destroy;
  inherited;
end;

procedure cBaseMeaFolder.doCreateFiles(node: txmlnode);
var
  I: Integer;
  s:string;
  o:cbaseobj;
  types,child:txmlnode;
  propList:tstringlist;
  j,k: Integer;
  propname:string;
  prop:TProp;
begin
  if m_TestTypes.Count>0 then
  begin
    // список возможных типов испытаний
    types:=getNode(node,'TestTypes');
    for I := 0 to m_TestTypes.Count - 1 do
    begin
      s:=m_TestTypes.Strings[i];
      child:=getNode(types,s);
      child.WriteAttributeString('Class','TestTypeStr','');
    end;
  end;
  if m_ObjTypes.Count>0 then
  begin
    // список возможных типов испытаний
    types:=getNode(node,'ObjTypes');
    for I := 0 to m_ObjTypes.Count - 1 do
    begin
      s:=m_ObjTypes.Strings[i];
      proplist:=LoadObjProperties(s);
      if proplist=nil then
      begin
        proplist:=TStringList.Create;
        proplist.Duplicates:=dupIgnore;
      end;
      child:=getNode(types,s);
      child.WriteAttributeString('Properties','ObjTypeStr','');
      for j := 0 to g_mbase.objects.Count - 1 do
      begin
        o:=g_mbase.getobj(j);
        if o is cObjFolder then
        begin
          if cObjFolder(o).m_ObjType=s then
          begin
            for k := 0 to cObjFolder(o).PropCount - 1 do
            begin
              propname:=cObjFolder(o).m_Properties.Strings[k];
              prop:=tprop(cObjFolder(o).m_Properties.Objects[k]);
              proplist.AddObject(propname,prop);
            end;
          end;
        end;
      end;
      for j := 0 to proplist.Count - 1 do
      begin
        child.WriteAttributeString('Prop_'+inttostr(j),proplist.Strings[j],'');
        child.WriteAttributeString('Prop_v_'+inttostr(j),'0','0');
      end;
      propList.Destroy;
    end;
  end;
end;

procedure cBaseMeaFolder.doLoadDesc(node: txmlnode);
var
  s, lclass:string;
  i, j:integer;
  tests,child:txmlnode;
begin
  inherited;
  tests:=node.FindNode('TestTypes');
  if tests<>nil then
  begin
    for I := 0 to tests.NodeCount - 1 do
    begin
      child:=tests.Nodes[i];
      lClass:=child.ReadAttributeString('Class','');
      if lClass='TestTypeStr' then
      begin
        s:=child.name;
        m_TestTypes.Add(s);
      end;
    end;
  end;
  tests:=node.FindNode('ObjTypes');
  if tests<>nil then
  begin
    for I := 0 to tests.NodeCount - 1 do
    begin
      child:=tests.Nodes[i];
      lClass:=child.ReadAttributeString('Properties','');
      if lClass='ObjTypeStr' then
      begin
        s:=child.name;
        m_ObjTypes.Add(s);
      end;
    end;
  end;
end;

function cBaseMeaFolder.LoadObjProperties(objType: string): tstringlist;
var
  xml:tnativexml;
  node, n, child:txmlNode;
  i, j:integer;
  s, lpath:string;
begin
  result:=nil;
  lpath:=getpath+'.xml';
  if fileexists(lpath) then
  begin
    xml:=TNativeXml.Create(nil);
    xml.LoadFromFile(lpath);
    node:=xml.Root;
    n:=node.FindNode('objTypes');
    if n<>nil then
    begin
      for I := 0 to n.NodeCount - 1 do
      begin
        child:=n.Nodes[i];
        s:=child.ReadAttributeString('Properties','');
        if s='ObjTypeStr' then
        begin
          if objType=child.name then
          begin
            result:=TStringList.Create;
            result.Duplicates:=dupIgnore;
            j:=0;
            s:=child.ReadAttributeString('Prop_'+inttostr(j),'');
            while s <> '' do
            begin
              result.add(s);
              inc(j);
              s:=child.ReadAttributeString('Prop_'+inttostr(j),'');
            end;
            Exit;
          end;
        end;
      end;
    end;
  end;
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

{ cObjFolder }
procedure cObjFolder.doCreateFiles(node: txmlnode);
begin
  inherited;
  node.WriteAttributeString('ObjType',m_ObjType,'');
end;

procedure cObjFolder.doLoadDesc(node: txmlnode);
begin
  inherited;
  m_ObjType:=node.ReadAttributeString('ObjType','');
end;


end.
