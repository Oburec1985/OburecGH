unit uDBObject;

interface
uses
  ubaseobj, uBaseObjMng, classes, upathmng, sysutils, Windows, uBaseObjService,
  pathutils,  UDirChangeNotifier, messages;

type

  cDBObject = class(cbaseobj)
  protected
    f_path:string;
  protected
    // ���������� ���� ��������� ����
    procedure updatePath;virtual;
    // ��������� ��� ���������� ��������� ����
    procedure setPath(str:string);virtual;
    function getpath:string;virtual;
    // ������� ��� �������������� ����������
    procedure ClearNotActObjects;
    function getimageindex:integer;override;
    function extractObjNamefromPath(str:string):string;
  public
    function Absolutepath:string;
    property path:string read getpath write setPath;
  public
    constructor create;override;
  end;

  cDBFile = class(cDBObject)

  end;

  cDBFolder  = class(cDBObject)
  protected
    // ����������� �������� ��� ���������� ���� ��������
    fscanFolders:boolean;
    fscanfiles:boolean;
    // ������ ��������� ���������� ������ testpath
    ftestresult:integer;
    fdeep:integer;
    m_prefList:tstringlist;
    fTestProc:enumProc;
    // ������������ ����������� ���������� ��������
    fUseNotifier:boolean;
    m_dirNotif:TDirChangeNotifier;
  protected
    // ���������� ��������
    procedure doChange(Sender: TDirChangeNotifier; const FileName,
                      OtherFileName: WideString; Action: TDirChangeNotification);
    procedure NotifThreadTerminated(Sender: TObject);
    // ���������� ���� ��������� ����
    procedure updatePath;override;
    // ���������� ����� ���� ������ ������� ����� ���� � �������� ������������ ��� � ��
    // ��������� �� ������� �������� ��� ��������� �������. -1 = �� ���������
    function testpath(str:string):integer;virtual;
    function getimageindex:integer;override;
  public
    function GetChildByPath(str:string):cDBobject;
    // ��������� ����� ���� � ��� ����������� ������� � ����� str
    procedure doUpdateFolder(str:string);virtual;
    function CreateDBObj(str:string):cDBobject;virtual;
    // ����� �����
    procedure ScanFolders(deep:integer);
    procedure ScanFiles(deep:integer);
    function TypeString:String;override;
    procedure AddPrefix(str:string);
    procedure setNotifier(str:string);
    constructor create;override;
    destructor destroy;override;
    // ������� ��� � ������ ��������
    procedure update;
  public
    property scanFolder:boolean read fscanFolders write fscanFolders;
    property scanFile:boolean read fscanfiles write fscanfiles;
  end;

  cDB = class(cBaseObjMng)
  protected
    // ��������� ������������� ����������
    buf:cdbobject;
  public
    // ����� ���� � ������� ���������� ��������������� ��� ���������� ��������
    m_syncHandle:cardinal;
    // ��������������� ������ �� ������������� �����
    m_FileNotStr:string;

    m_BaseFolder:cDBFolder;
  protected
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    function createBaseFolder:cDBFolder;virtual;
  public
    function getchildbypath(str:string):cdbobject;
    constructor create;override;
    destructor destroy;override;
    procedure InitBaseFolder(str:string);
  end;

  const
    wm_UpdateFolder = WM_User+10;
    E_OnUpdateFolder = $00002000;


    c_DBObjImage = 23;
    c_DBFolderImage = 18;
    c_DBFolderString = '�������';
    c_DBDataFileImage = 1;
    c_DBCfgFileImage = 2;
    c_DBPathError=13;

implementation

constructor cDBObject.create;
begin
  inherited;
  destroydata:=true;
end;

function cDBObject.getimageindex:integer;
begin
  result:=c_DBObjImage;
end;

function cDBObject.extractObjNamefromPath(str:string):string;
begin
  if str[length(str)]='\' then
  begin
    SetLength(str,length(str)-1);
  end;
  result:=ExtractFileName(str);
end;

function cDBObject.Absolutepath:string;
begin
  result:='';
  if isAbsolutePath(path) then
    result:=path
  else
  begin
    if parent<>nil then
    begin
      result:=cDBObject(parent).Absolutepath;
      if isAbsolutePath(result) then
      begin
        result:=RelativePathToAbsolute(result,path);
      end;
    end;
  end;
end;

procedure cDBObject.setPath(str:string);
begin
  f_path:=str;
  updatePath;
  if pos(classname, name)>0 then
  begin
    str:=extractObjNamefromPath(str);
    caption:=str;
    name:=caption;
  end;
end;

procedure cDBObject.ClearNotActObjects;
var
  I: Integer;
  obj:cdbobject;
  lpath1,lpath2:string;
begin
  lpath1:=Absolutepath;
  i:=0;
  obj:=cDBObject(getchild(i));
  while obj<>nil do
  begin
    lpath2:=obj.Absolutepath;
    if pos(lpath1, lpath2)<1 then
    begin
      obj.destroy;
    end
    else
    begin
      inc(i);
    end;
    obj:=cDBObject(getchild(i));
  end;
end;

procedure cDBObject.updatePath;
begin

end;

function cDBObject.getpath:string;
begin
  result:=f_path;
end;

function UpdatePathProc(obj:cBaseObj; data:pointer):boolean;
begin
  cdbobject(obj).updatePath;
end;

procedure cDBFolder.update;
begin
  clear;
  ScanFolders(fdeep);
  ScanFiles(fdeep);
end;

procedure cDBFolder.updatePath;
var
  I: Integer;
  ch:cdbobject;
begin
  ClearNotActObjects;
  for I := 0 to childrens.Count - 1 do
  begin
    ch:=cdbobject(getchild(i));
    ch.updatePath;
  end;
  ScanFolders(fdeep);
  ScanFiles(fdeep);

  if fUseNotifier then
    setNotifier(Absolutepath);
end;

procedure cDBFolder.doUpdateFolder(str:string);
var
  path:string;
  obj:cdbObject;
  I: Integer;
  add:boolean;
begin
  path:=Absolutepath;
  if testpath(str)>-1 then
  begin
    str:=GetPathLevel(path, str, 1);
    obj:=GetChildByPath(str);
    // ��������� �������� ������� ���� �� ���������
    if obj<>nil then
    begin
      add:=false;
      if obj is cdbfolder then
      begin
        if cdbfolder(obj).scanFile then
          cdbfolder(obj).ScanFiles(1);
        if cdbfolder(obj).scanFolder then
          cdbfolder(obj).ScanFolders(1);
      end;
    end;
    // �� ��������� �������� ��� �� ���� � ����
    if add then
    begin
      obj:=cdbObject(CreateDBObj(str));
      if obj<>nil then
      begin
        obj.path:=str;
        AddChild(obj);
      end;
    end;
  end;
end;

function ComparePath(obj:cBaseObj; data:pointer):boolean;
begin
  result:=true;
  if cdbobject(obj).Absolutepath=string(data) then
  begin
    cdb(obj.getmng).buf:=cdbobject(obj);
    result:=false;
  end;
end;

function cDBFolder.GetChildByPath(str:string):cDBobject;
var
  i:integer;
  o:cDBobject;
begin
  result:=nil;
  cDB(getmng).buf:=nil;
  EnumGroupMembers(ComparePath,@str[1]);
  result:=cDB(getmng).buf;
  {for I := 0 to childcount - 1 do
  begin
    o:=cdbObject(getchild(i));
    if o.Absolutepath=str then
    begin
      result:=o;
      break;
    end;
  end;}
end;

procedure cDBFolder.doChange(Sender: TDirChangeNotifier; const FileName,
                      OtherFileName: WideString; Action: TDirChangeNotification);
var
  Fmt: WideString;
  obj:cdbobject;
  foldername:string;
begin
  case Action of
    dcnFileAdd:
    begin
      Fmt := 'Creation file %s';
      obj:=nil;
      // ���������� ��������� �������� (�� ���� ������ ������ �.�. �� ����� ���������� ��������
      // ����� ��������� ����� ����������� ���������� �������� ������� ����� ���������)
      {if isfile(filename) then
      begin
        foldername:=ExtractFileDir(filename);
        obj:=GetChildByPath(foldername);
      end;
      if obj<>nil then
      begin
        if obj is cdbfolder then
          cdbfolder(obj).doUpdateFolder(FileName);
      end
      else
        doUpdateFolder(FileName);}
      // ����������� ����
      cdb(getmng).m_FileNotStr:=FileName;
      PostMessage(cdb(getmng).m_syncHandle,wm_UpdateFolder,integer(@FileName[1]),integer(self));
      //cdb(getmng).events.CallAllEvents(E_OnUpdateFolder);
    end;
    dcnFileRemove:
    begin
      Fmt := 'Remove file %s';
    end;
    dcnRenameFile, dcnRenameDir:
    begin
      Fmt := '%s renamed to %s';
    end;
    dcnModified:
    begin
      Fmt := 'Modification file %s';
    end;
    dcnLastAccess:
    begin
      Fmt := 'Date last access file %s  modified';
    end;
    dcnLastWrite:
    begin
      Fmt := 'Date last write file %s modified';
    end;
    dcnCreationTime:
    begin
      Fmt := 'Creation time file %s modified';
    end;
  end;
  Fmt:=Format(Fmt, [FileName, OtherFileName]);
end;

procedure cDBFolder.NotifThreadTerminated(Sender: TObject);
begin
  m_dirNotif:=nil;
end;

procedure cDBFolder.setNotifier(str:string);
begin
  if m_dirNotif<>nil then
  begin
    m_dirNotif.Terminate;
    m_dirNotif:=nil;
  end;
  //m_dirNotif:=TDirChangeNotifier.Create(getpath,[dcnFileAdd , dcnFileRemove]);
  //str:=Absolutepath;
  if DirectoryExists(str) then
  begin
    if str[length(str)]<>'\' then
      str:=str+'\';
    // false �������� synchronise ��� �������
    m_dirNotif:=TDirChangeNotifier.Create(str,CAllNotifications, false);
    m_dirNotif.OnChange := doChange;
    m_dirNotif.OnTerminate := NotifThreadTerminated;
  end;
end;

constructor cDBFolder.create;
begin
  inherited;
  fdeep:=1;
  fUseNotifier:=false;
  m_prefList:=tStringlist.Create;
  fimageind:=c_DBFolderImage;
  fscanFolders:=true;
  fscanFiles:=true;
end;

destructor cDBFolder.destroy;
begin
  m_prefList.Destroy;
  if m_dirNotif<>nil then
  begin
    m_dirNotif.Terminate;
    m_dirNotif:=nil;
  end;
  inherited;
end;

function cDBFolder.TypeString:String;
begin
  // �������
  result:=c_DBFolderString;
end;

function cDBFolder.getimageindex:integer;
begin
  result:=fimageind;
end;

function cDBFolder.testpath(str:string):integer;
var
  I: Integer;
  pref:string;
begin
  result:=-1;
  ftestresult:=result;
  str:=ExtractFileName(str);
  for I := 0 to m_prefList.Count - 1 do
  begin
    pref:=m_prefList.Strings[i];
    pref:=LowerCase(pref);
    str:=LowerCase(str);
    if pos(pref, str)>0 then
    begin
      result:=i;
      ftestresult:=i;
      exit;
    end;
  end;
end;

function cDBFolder.CreateDBObj(str:string):cDBobject;
begin
  result:=cDBFolder.create;
end;

procedure cDBFolder.ScanFiles(deep:integer);
var
  I: Integer;
  lpath,str:string;
  list:tstringlist;
  obj:cdbFile;
begin
  if fscanfiles then
  begin
    list := tstringlist.Create;
    lpath:=Absolutepath;
    if lpath='' then exit;
    ScanDir(lpath,'*.*',list, deep);
    // ����������� �������, �����, ������ �����������
    for I := 0 to List.Count - 1 do
    begin
      str:=list.Strings[i];
      if testpath(str)>-1 then
      begin
        if GetChildByPath(str)<>nil then continue;
        if isFile(str) then
        begin
          obj:=cdbFile(CreateDBObj(str));
          if obj<>nil then
          begin
            obj.path:=str;
            AddChild(obj);
          end;
        end;
      end;
    end;
    list.destroy;
  end;
end;

procedure cDBFolder.ScanFolders(deep:integer);
var
  I: Integer;
  lpath,str:string;
  list:tstringlist;
  obj,o:cdbobject;
begin
  if fscanFolders then
  begin
    list := tstringlist.Create;
    lpath:=Absolutepath;
    if lpath='' then exit;
    // ����������� �������, �����, ������ �����������
    FindFolders(lpath, '*', list, deep);
    for I := 0 to List.Count - 1 do
    begin
      str:=list.Strings[i];
      if testpath(str)>-1 then
      begin
        if isdirectory(str) then
        begin
          obj:=cdbfolder(CreateDBObj(str));
          o:=GetChildByPath(str);
          if o=nil then
          begin
            AddChild(obj);
            obj.path:=str;
          end;
        end;
      end;
    end;
    list.destroy;
  end;
end;

procedure cDBFolder.AddPrefix(str:string);
begin
  m_prefList.Add(str);
end;

constructor cDB.create;
begin
  inherited;
  m_BaseFolder:=createBaseFolder;
  m_BaseFolder.autocreate:=true;
  m_BaseFolder.fHelper:=true;
  Add(m_BaseFolder, nil);
end;

function cDB.getchildbypath(str:string):cdbobject;
var
  I: Integer;
  o:cdbobject;
begin
  result:=nil;
  for I := 0 to Count - 1 do
  begin
    o:=cdbobject(getobj(i));
    if o.Absolutepath=str then
    begin
      result:=cdbobject(o);
      exit;
    end;
  end;
end;

destructor cDB.destroy;
begin
  inherited;
end;

procedure cDB.InitBaseFolder(str:string);
begin
  m_BaseFolder.path:=str;
end;

procedure cDB.AddBaseObjInstance(obj:cbaseobj);
begin
  if obj is cDBObject then
  begin
    inherited AddBaseObjInstance(obj);
  end;
end;

function cDB.createBaseFolder:cDBFolder;
begin
  result:=cDBFolder.create;
end;

end.
