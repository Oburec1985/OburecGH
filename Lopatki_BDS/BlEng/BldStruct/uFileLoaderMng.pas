// ������������ suspend ������ �������� ��������� ��� ��������
unit uFileLoaderMng;

interface
uses
  windows, uBldEng, uTickData, classes, ubldEngEventTypes, SysUtils,
  uCommonMath, uEventtypes, ExtCtrls, uBaseObjMng, uBldTimeProc,
  uEventList, dialogs, uchan, uVectorList, uBladeTicksFile, uBaseObj,
  uSetList, uDirChangeNotifier, messages;

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

  // �������� ����������� ������
  cFileLoaderMng = class(TThread)
  public
    // ������ ��������������� ������� ���� ���������
    m_IDList:cIDSet;
    curID:integer;
  protected
    m_tProc:cBldTimeProc;
    m_eng:cbldEng;
    // ����� ��� �������� �� ��������� (������ ������� ��������� ��������)
    m_FolderThread:TDirChangeNotifier;
    msg:TagMsg;
  protected
    // ����� ���������� ������������� � �������� �����
    m_LastFileTime:tDateTime;
    // ���������� ����������� ������
    m_NamePart, m_ext,
    // ����� � ������������ �������
    m_folder:string;
    // �����/ ����
    m_mode:boolean;
    // ������� �����
    channels:cBaseObj;
    // ������ � ������������� ����� �������� ����� ������
    m_Period:integer;
    // ���� ������������ ��� ���� ��������
    m_FileLoaded:boolean;
    // ������� ��� ������ ����������
    ExchangeDataEvent:thandle;
  protected
    procedure cleardata;
    // ���������� ����� � �������
    procedure Reset;
    function GetFileType(path:string;var fType:integer):string;
    function LoadFile(index:integer):boolean;
    procedure Execute; override;
    // ��������� ������� ����� ������ � ��������� � ������ ���������������
    // ���� ������ ��������������� ������ ��� ������� ����� ���������
    // ������������ ������ �� ����������� ����� ����. ���� ��������� �������
    // � cBldTimeProc ��������� ������ (��������� ���������), �� ���������� ����� �������.
    function CheckNewData:boolean;
    // �������� ��������� ������������� ������� �� m_eng
    procedure UpdateChans;
    // ���������� ������� � �������
    procedure ExchangeData;
    procedure Linc(tProc:cBldTimeProc);
    // ��������� ����� � �������(��� �����) � �������� ��������������
    // ��������� ��� ���� ��� �����, �� ������� � �������������� ������ �� � ����� ������� ������������
    // PartName
    procedure ReadFolder;
    procedure SthChange(Sender: TDirChangeNotifier; const FileName,
              OtherFileName: WideString; Action: TDirChangeNotification);
    // ������� ��� �������� ������ ��������� �� ���������
    procedure ThreadTerminated(Sender: TObject);
    procedure createEvents;
    procedure DestroyEvents;
    procedure OnLoad(sender:tobject);
    procedure setNamePart(v:string);
    procedure setFolder(v:string);
  protected
    procedure setMode(b:boolean);
    // ���������� ����� ��� ������ ��������� ��������� ����. ����������� � ������� ������
    // (���������� ���������������� �� ������ ��������� ������(���������� ������� �������� ���������))
    procedure doStopPlay(var message: TMessage);message wm_OnStopTasksMessage;
  public
    // ��������� ���� � ������ ��������������� ��� ����������
    // ����� ����������� ������ � ��� ������ ���� �� ����� ������� ����������� �����. �.�.
    // ���� ����� ������ ���_�����, ��������: ������_01
    function AddID(fName:string):boolean;
    procedure Init(p_folder:string;name:string);
    constructor create(tProc:cBldTimeProc);
    destructor destroy;override;
    procedure SetExchangeEvent;
    procedure DropExchangeEvent;
    function waitExchangeEvent:boolean;
    function GetCurId:cid;
    // ���������� ����� ��������� ��������������� ���� ������ � ������ ���� �� �����
    // ����� ����� message � ������ ���������� ������
    procedure OnStopPlay(sender:tobject);
    // ������� ����� ������� �������� ����������� ��������� ����� ������ � �������
    procedure StartWaitData;
    // ���������� ��� � ������ ������ ��������� ��� �����
    function FinishPlayData:boolean;
  protected
  public
    property Folder:string read m_folder write setFolder;
    property namePart:string read m_NamePart write setNamePart;
    // ����� ��� ����
    property mode:boolean read m_mode write SetMode;
  end;

const

  c_NotDataFile = 0;
  c_sdtFile = 1;
  c_bldFile = 2;

implementation


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
  result:=cID(getNode(i));
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

constructor cFileLoaderMng.create(tProc:cBldTimeProc);
begin
  inherited create(true);
  m_IDList:=cIDSet.create;
  m_IDList.destroydata:=true;
  m_Period:=1000;
  m_ext:='.sdt';
  m_NamePart:='';
  curID:=0;
  channels:=cBaseObj.create;
  channels.destroydata:=true;
  Linc(tProc);
  // ������� ������� �������� ����� ������/
  // ���������� ���������� �������/ ��������� ���������/ ��� �������
  ExchangeDataEvent:=CreateEvent(nil, True, False, nil);

  // ��������� ������
  FreeOnTerminate:=false;
  Priority:=tpLower;

  createEvents;
end;

destructor cFileLoaderMng.destroy;
begin
  destroyevents;
  if suspended then
  begin
    resume;
    m_mode:=false;
  end;
  m_IDList.Destroy;
  channels.destroy;
  inherited;
end;

procedure cFileLoaderMng.Linc(tProc:cBldTimeProc);
begin
  m_tProc:=tProc;
  m_eng:=cbldeng(tProc.eng);
end;

procedure cFileLoaderMng.Execute;
var
  id:cId;
begin
  while not terminated do
  begin
    if m_mode then
    begin
      CheckNewData;
      // ��������� ��������� ������
      // OnStopPlay
      if PeekMessage(Msg, 0, 0, 0, pm_NoRemove) and m_mode then
      begin
        dispatch(Msg.message);
      end;
    end;
    // ���� �������� ������������
    if (not suspended) and (not m_mode) then
      suspend;
    if m_period>0 then
      sleep(m_period);
  end;
  inherited;
end;

function cFileLoaderMng.LoadFile(index:integer):boolean;
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

procedure cFileLoaderMng.UpdateChans;
var
  I: Integer;
  chan,lchan:cchan;
begin
  if m_eng<>nil then
  begin
    channels.destroychildrens;
    for I := 0 to m_eng.channels.childCount - 1 do
    begin
      chan:=cchan(m_eng.getchan(i));
      lchan:=cchan.create;
      lchan.chan:=chan.chan;
      channels.addchild(lchan);
    end;
  end;
end;

procedure cFileLoaderMng.ExchangeData;
var
  I: Integer;
  chan,lchan:cchan;
  lticks:cBaseTicks;
begin
  for I := 0 to m_eng.channels.childCount - 1 do
  begin
    chan:=cchan(m_eng.getchan(i));
    lchan:=cchan(channels.getChild(i));
    lticks:=lchan.ticks;

    lchan.ticks:=chan.ticks;
    chan.ticks:=lticks;
  end;
  // ����� ���� �� ��������
  m_FileLoaded:=false;
  SetExchangeEvent;
  m_tProc.RestartTasks;
end;

procedure cFileLoaderMng.Reset;
begin
  curid:=0;
  m_IDList.clear;
  // ��������� ������ ������ � ��������
  readfolder;
end;

procedure cFileLoaderMng.Init(p_folder:string;name:string);
begin
  folder:=p_folder;
  NamePart:=lowercase(name);
  // ��������� ������ ������ � ��������
  Reset;
end;

procedure cFileLoaderMng.StartWaitData;
begin
  m_FolderThread:=TDirChangeNotifier.Create(m_folder, CAllNotifications);
  m_FolderThread.OnChange := SthChange;
  m_FolderThread.OnTerminate := ThreadTerminated;
end;

procedure cFileLoaderMng.setMode(b:boolean);
begin
  m_mode:=b;
  if m_mode then
  begin
    Reset;
    if suspended then
      resume;
  end
  else
  begin
    // ������� ������� �������� ������? ����� ����� ��� �� ����
    m_tProc.SetDataProcEvent;
    // ������� ������� ���� ������ ��������� � stopEvent �� ����� ��� � ����� ���� �������
    SetExchangeEvent;
    if m_FolderThread<>nil then
    begin
      m_FolderThread.Terminate;
      m_FolderThread:=nil;
    end;
  end;
end;

function cFileLoaderMng.CheckNewData:boolean;
begin
  result:=false;
  if m_idList.count>curID then
  begin
    LoadFile(curID);
    // ���� ����  ����� ��������� ���������� ������
    if m_tProc.waitDataProcEvent then
    begin
      if mode then
      begin
        ExchangeData;
      end;
    end;
    inc(curid);
  end;
end;

procedure cFileLoaderMng.ReadFolder;
var
  // ��������� ��� ����� � �����
  sr:tSearchRec;
  strList:tstringlist;
  searchPath:string;
  I: Integer;
begin
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

function cFileLoaderMng.AddID(fName:string):boolean;
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
        end;
      end;
    end;
  end;
end;

procedure cFileLoaderMng.SthChange(Sender: TDirChangeNotifier; const FileName,
          OtherFileName: WideString; Action: TDirChangeNotification);
var
  Fmt: WideString;
  log:boolean;
begin
  log:=checkflag(m_eng.flags,c_LogMessage);
  case Action of
    dcnFileAdd:
    begin
      Fmt := 'Creation file %s';
      // ���� ���������� �����
      if AddID(filename) then
        m_eng.Events.CallAllEvents(E_OnEngAddFile);
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
    m_eng.getmessage(fmt, c_LogMessage);
end;

procedure cFileLoaderMng.ThreadTerminated(Sender: TObject);
begin
  m_FolderThread := nil;
end;

function cFileLoaderMng.GetFileType(path:string;var fType:integer):string;
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

procedure cFileLoaderMng.OnStopPlay(sender:tobject);
var
  i:integer;
  id:cid;
begin
  // ���� ����� �����������
  if m_mode then
  begin
    m_eng.Events.CallAllEvents(e_OnUserFinishPlayData);
  end;
end;

procedure cFileLoaderMng.SetExchangeEvent;
VAR
  ID:CID;
begin
  SetEvent(exchangeDataEvent);
  id:=GetCurId;
  if id<>nil then
  begin
    m_eng.lastfile:=ID.fName;
    // �������� ����� ������ � Synchronise
    m_eng.Events.CallAllEvents(E_OnEngLoadData);
  end;
end;

procedure cFileLoaderMng.DropExchangeEvent;
begin
  ResetEvent(exchangeDataEvent);
end;

function cFileLoaderMng.waitExchangeEvent:boolean;
begin
  result:=waitforsingleobject(exchangeDataEvent,infinite)=WAIT_OBJECT_0;
  DropExchangeEvent;
end;

procedure cFileLoaderMng.createEvents;
begin
  m_eng.Events.AddEvent('cFileLoaderMng_OnLoad',E_OnEngLoadCfg,OnLoad);
end;

procedure cFileLoaderMng.DestroyEvents;
begin
  m_eng.Events.removeEvent(OnLoad,E_OnEngLoadCfg);
end;

procedure cFileLoaderMng.OnLoad(sender:tobject);
begin
  UpdateChans;
end;

procedure cFileLoaderMng.cleardata;
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

function cFileLoaderMng.GetCurId:cid;
begin
  if curid<m_idList.Count then
    result:=m_idList.getid(CURID)
  else
    result:=nil;
end;

procedure cFileLoaderMng.doStopPlay(var message: TMessage);
begin
  OnStopPlay(nil);
end;

procedure cFileLoaderMng.setNamePart(v:string);
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

procedure cFileLoaderMng.setFolder(v:string);
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

function cFileLoaderMng.FinishPlayData:boolean;
begin
  result:=curID=m_IDList.Count;
end;

end.