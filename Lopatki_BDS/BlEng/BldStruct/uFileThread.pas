unit uFileThread;

interface
uses
  windows, uBaseObj, classes, SysUtils, uTickData, uChan, uBladeTicksFile,
  uCommonMath, uEventtypes, ExtCtrls, uBaseObjMng, uBldTimeProc,
  NativeXML, uEventList, dialogs, uSetList, uDataThread, UDirChangeNotifier,
  uBldEng, ubldEngEventTypes;


type
  cID = class
    time:tDateTime;
    // ��� �����
    filetype:integer;
    // ������������� ������������ ������
    intID:integer;
    // ���� ���������
    m_processed:boolean;
    fName:string;
  end;

  cIDSet = class(cSetList)
  public
    Function GetID(i:integer):cID;overload;
    Function GetID(fname:string):cID;overload;
    constructor create;override;
    destructor destroy;override;
    procedure deletechild(node:pointer);override;
  end;

  // ����� ��� ����������� ����� ������� ���������� � ����������� �������
  // � ��������� BaseObj-��
  cFileThread = class(cDataThread)
  public
    // ������ ��������������� ������� ���� ���������
    m_IDList:cIDSet;
    // ������� �������������� ����
    curID:integer;
  protected
    buffstr:string;
    // ���������� ����������� ������
    m_NamePart, m_ext,
    // ����� � ������������ �������
    m_folder:string;
    // ����� ��� �������� �� ��������� (������ ������� ��������� ��������)
    m_FolderThread:TDirChangeNotifier;
  protected
    // ���������� ���������� ����� ���� �� � �������
    // fType = c_notDataType ���� ��� ������
    function GetFileType(path:string;var fType:integer):string;
    // callback �� �������� ������� �������� �� ���������
    procedure ThreadTerminated(Sender: TObject);
    // ���� �������� ���� � ������� �� ���������� true
    function AddID(fName:string):boolean;
    // ��������� ���������� ����� ��������� �������
    procedure SthChange(Sender: TDirChangeNotifier; const FileName,
              OtherFileName: WideString; Action: TDirChangeNotification);
    procedure OnNewData;override;
    // ��������� ������� ����� ������ � ��������� � ������ ���������������
    // ���� ������ ��������������� ������ ��� ������� ����� ���������
    // ������������ ������ �� ����������� ����� ����. ���� ��������� �������
    // � cBldTimeProc ��������� ������ (��������� ���������), �� ���������� ����� �������.
    procedure PlayFunc;override;
    // ����������� � OnFinishPlayData (� �������)
    procedure OnDataProc(sender:tobject);override;
    function LoadFile(index:integer):boolean;
    // ���������� ��������������� ����� �������� ������ ����� ������ �
    // setEnabled. ����� ���������� ������������ ������� ��� ���������� �������
    // � ������������ � �������� ����� ��� ����������� ��������� ��������
    // � �������. ���������� ���� data
    procedure OnBeforeStop(sender:tobject);override;
    // ��������� TDirChangeNotifier �� �������� �� ��������� ���������
    // ����� ���������� ����� ���� ���������� �������
    procedure BeforeStartThread(sender:tobject);override;
    procedure cleardata;
    // ��������� ����� � �������(��� �����) � �������� ��������������
    // ��������� ��� ���� ��� �����, �� ������� � �������������� ������ �� � ����� ������� ������������
    // PartName
    procedure ReadFolder;
    procedure setNamePart(v:string);
    procedure setFolder(v:string);
    // �������� ������������ ������ (����������� ������ �������)
    // ��� ���������� �������
    procedure UpdateChans;
  public
    constructor create(mng:cDataThreadMng);override;
    destructor destroy;override;
    // ���������� ���� � ������� ������
    procedure Init(p_folder:string;name:string);
  public
    property namePart:string read m_NamePart write setNamePart;
    property Folder:string read m_folder write setFolder;
  end;

const
  c_NotDataFile = 0;
  c_sdtFile = 1;
  c_bldFile = 2;

  c_Files = $00000001;
  c_Device = $00000002;
  c_Demo = $00000004;


implementation

// ������� ������ / �� �����
function TrimPath(str:string):string;
var
  l:integer;
begin
  l:=length(str);
  if (str[l]='/') or (str[l]='\') then
  begin
    setlength(str, l-1);
  end;
  result:=str;
end;

// �������� �� ������ �����. ��������� ������ ������ �� ��� ��� ���� �� ��������
// ������ ������� �� ����� � ���������� ���������� ����� � �����. ����� ���� �����
// ������ � ������ ������
function ExtractNumFromName(str:string):integer;
var
  len:integer;
  I: Integer;
begin
  len:=length(str);
  // ��������� ������ ������
  for I := 1 to len do
  begin
    if not isDigit(Str[i]) then
    begin
      if i<>1 then
      begin
        setlength(str,i-1);
        result:=strtoint(str);
        exit;
      end;
      break;
    end;
  end;
  // ��������� ���e� ������
  for I := len downto 1 do
  begin
    if not isDigit(Str[i]) then
    begin
      if i<>len then
      begin
        str:=Copy(str,i+1,len-i);
        result:=strtoint(str);
        exit;
      end;
      break;
    end;
  end;
  result:=-1;
end;

procedure cFileThread.Init(p_folder:string;name:string);
begin
  folder:=p_folder;
  NamePart:=lowercase(name);
  // ��������� ������ ������ � ��������
  ReadFolder;
end;

procedure cFileThread.ReadFolder;
var
  // ��������� ��� ����� � �����
  sr:tSearchRec;
  strList:tstringlist;
  searchPath:string;
  I: Integer;
begin
  curid:=0;
  m_IDList.listclear;
  // ��������� ������ ������ � ��������
  if DirectoryExists(m_folder) then
  begin
    searchPath:=m_folder+'*';
    strlist:=tstringlist.create;
    //faDirectory
    if FindFirst(searchPath, faAnyFile, SR) = 0 then
    begin
      if (sr.name<>'.') and (sr.name<>'..') then
        strlist.Add(sr.Name);
    end;
    while FindNext(SR)=0 do
    begin
      if (sr.name<>'.') and (sr.name<>'..') then
        strlist.Add(sr.Name);
    end;
    // �������� ������ ���������������
    for I := 0 to strList.Count - 1 do
    begin
      searchPath:=strList.Strings[i];
      AddID(searchPath);
    end;
    strlist.destroy;
  end;
end;

procedure cFileThread.setFolder(v:string);
var
  ch:char;
  a,b:boolean;
begin
  if length(v)<>0 then
  begin
    ch:=v[length(v)];
    b:=ch<>'\';
    a:=ch<>'/';
    if b and a then
    begin
      m_folder:=v+'\';
    end
    else
      m_folder:=v;
  end;
end;

procedure cFileThread.setNamePart(v:string);
var
  i,len:integer;
begin
  m_namePart:=extractfilename(v);
  len:=length(m_namePart);
  for i:=len downto 1 do
  begin
    if m_namePart[i]='.' then
    begin
      setlength(m_namePart,i-1);
      exit;
    end;
  end;
end;

procedure cFileThread.BeforeStartThread(sender:tobject);
begin
  curid:=0;
  UpdateChans;
  if not checkflag(typeThread, c_demo) then
  begin
    m_FolderThread:=TDirChangeNotifier.Create(m_folder, CAllNotifications);
    m_FolderThread.OnChange := SthChange;
    m_FolderThread.OnTerminate := ThreadTerminated;
  end;
end;

procedure cFileThread.OnBeforeStop(sender:tobject);
begin
  if m_FolderThread<>nil then
  begin
    m_FolderThread.Terminate;
    m_FolderThread:=nil;
  end;
end;

procedure cFileThread.ThreadTerminated(Sender: TObject);
begin
  m_FolderThread := nil;
end;

function cFileThread.AddID(fName:string):boolean;
var
  id:cid;
  FileType,p:integer;
  dir, l_mfolder:string;
  sr:tSearchRec;
begin
  result:=false;
  if m_folder='' then
    exit;
  dir:=extractfiledir(fname);
  if dir<>'' then
  begin
    dir:=LowerCase(TrimPath(dir));
    l_mfolder:=LowerCase(TrimPath(m_folder));
    if dir<>m_folder then
    // ���� �������� � ����������, � �� � ������� (�������� sdt ����)
    begin
      fname:=extractfileName(dir);
      dir:=TrimPath(extractfiledir(dir));
      // ���� ���� �������� ������ ��� �� ������� �����������
      // �� �������
      if dir<>l_mfolder then
        exit;
    end
  end;
  fName:=ExtractFileName(fName);
  fName:=LowerCase(fName);
  if pos(namePart,fName)<>0 then
  begin
    p:=ExtractNumFromName(fname);
    if p<>-1 then
    begin
      fName:=getFileType(m_folder+fName, filetype);
      if filetype<>c_NotDataFile then
      begin
        id:=m_idList.GetID(fName);
        if id=nil then
        begin
          result:=true;
          id:=cid.Create;
          id.filetype:=filetype;
          id.fName:=fName;
          id.intID:=p;
          m_idList.AddObj(id);
          setNewDataEvent;
        end;
      end;
    end;
  end;
end;

function cFileThread.GetFileType(path:string;var fType:integer):string;
var
  // ��������� ��� ����� � �����
  sr:tSearchRec;
begin
  fType:=c_NotDataFile;
  if DirectoryExists(path) then
  begin
    if findFirst(path+'\*.sdt',faAnyFile,sr)=0 then
    begin
      if CheckSDTFile(path+'\'+sr.Name) then
      begin
        fType:=c_sdtFile;
        result:=path+'\'+sr.Name;
      end;
    end;
  end
  else
  begin
    if pos(path,'.bld')<>0 then
    begin
      fType:=c_bldFile;
      result:=path;
    end;
  end;
end;

procedure cFileThread.SthChange(Sender: TDirChangeNotifier; const FileName,
                      OtherFileName: WideString; Action: TDirChangeNotification);
var
  Fmt: WideString;
  log:boolean;
begin
  log:=checkflag(cbldtimeproc(fMng.m_tProc).feng.flags,c_LogMessage);
  case Action of
    dcnFileAdd:
    begin
      Fmt := 'Creation file %s';
      buffstr:=FileName;
      OnNewData;
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
  if log then
    cbldtimeproc(fMng.m_tProc).feng.getmessage(fmt, c_LogMessage);
end;


function cFileThread.LoadFile(index:integer):boolean;
var
  fname, ext:string;
  l_id:cID;
begin
  result:=false;
  l_id:=m_IDList.GetID(index);
  fname:=l_id.fName;
  // ������� ������ ������
  cleardata;
  if fileexists(fname) then
  begin
    ReadData(fname, channels);
    result:=true;
  end;
end;

procedure cFileThread.cleardata;
var
  I: Integer;
  ticks:cBaseTicks;
  chan:cchan;
begin
  for I := 0 to channels.childCount - 1 do
  begin
    chan:=cchan(channels.getChild(i));
    ticks:=chan.ticks;
    ticks.clear;
  end;
end;

constructor cFileThread.create(mng:cDataThreadMng);
begin
  inherited;
  typeThread:=c_FileThread;

  m_IDList:=cIDSet.create;
  m_IDList.destroydata:=true;
  fPeriod:=1000;
  m_ext:='.sdt';
  m_NamePart:='';
  curID:=0;
  // ��������� ������
  FreeOnTerminate:=false;
  Priority:=tpLower;
end;

destructor cFileThread.destroy;
begin
  //if suspended then
  //begin
  //  Enabled:=false;
  //  resume;
  //end;
  m_IDList.Destroy;
  inherited;
end;

procedure cFileThread.OnDataProc(sender:tobject);
var
  id:cId;
begin
  if enabled then
  begin
    id:=m_IDList.GetID(curid-1);
    if id<>nil then
    begin
      id.time:=now;
    end;
    inherited;
  end;
end;

procedure cFileThread.OnNewData;
begin
  // ���� ���������� �����
  // � buffstr ����������� ������ � ������ ������������ �����
  // ������ ���������� ����� ������� NewDataEvent
  if AddID(buffstr) then
  begin
    cbldtimeproc(fMng.m_tProc).feng.Events.CallAllEvents(E_OnEngAddFile);
  end;
end;

procedure cFileThread.PlayFunc;
begin
  if m_idList.count>curID then
  begin
    LoadFile(curID);
    inc(curid);
  end;
  // ����� ������� dataprocevent (����� ���������� ����� ������ ���������� ��������)
  inherited;
end;

procedure cFileThread.UpdateChans;
var
  I: Integer;
  chan,lchan:cchan;
begin
  if fMng.m_tProc.feng<>nil then
  begin
    channels.destroychildrens;
    for I := 0 to fMng.m_tProc.feng.channels.childCount - 1 do
    begin
      chan:=cchan(fMng.m_tProc.feng.getchan(i));
      lchan:=cchan.create;
      lchan.chan:=chan.chan;
      channels.addchild(lchan);
    end;
  end;
end;

function IDcomparator(p1,p2:pointer):integer;
begin
  result:=0;
  if cID(p1).intID>cID(p2).intID then
  begin
    result:=1
  end
  else
  begin
    if cID(p1).intID<cID(p2).intID then
    begin
      result:=-1
    end
  end;
end;


constructor cIDSet.create;
begin
  inherited;
  comparator:=idComparator;
end;

destructor cIDSet.destroy;
begin
  inherited;
end;

procedure cIDSet.deletechild(node:pointer);
begin
  cID(node).destroy;
end;

Function cIDSet.GetID(i:integer):cID;
begin
  if i>=0 then
    result:=cID(getNode(i))
  else
    result:=nil;
end;

Function cIDSet.GetID(fname:string):cID;
var
  I: Integer;
  id:cid;
begin
  result:=nil;
  for I := 0 to Count - 1 do
  begin
    id:=GetID(i);
    if id.fName=fname then
    begin
      result:=id;
      exit;
    end;
  end;
end;

end.
