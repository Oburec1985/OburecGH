unit uBldEng;

interface
uses
  controls, stdctrls, classes, sysutils, uEventList, uEventTypes, uBaseObj,
  uCommonMath, uVectorList, forms, uBldPathMng,
  uLogFile, dialogs, uBaseObjMng, ubldEngEventTypes , uSetList
  ;

type

  cBldEng = class(cBaseObjMng)
  private
    ftimeproc:tobject;
  public
    // �������� ����� (���� ������ ���������� ��������� �� �������)
    flags:cardinal;
    // ����
    PathMng:cBldPathMng;
    // ���� � ������� ������������
    curCfg,
    // ��������� ����������� ���� � �������
    lastfile,
    // ������� ��� ���������� �������� �� ���������
    SaveFolder:string;
    logFile:cLogFile;
    prec:integer;
    HardWare:cBaseObjMng;
    ThreadList:cIDList;
  public
    // ������ �������
    channels:cBaseObj;
  protected
    GetEngObjForm:TForm;
  protected
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    procedure regObjClasses;override;
    procedure setTimeProc(tp:tobject);
  private
  public
    constructor create;override;
    destructor destroy;override;
    procedure clear;override;
    // ������� ������ �� �������
    procedure clearTicks;
    procedure setEngFlag(flag:cardinal; b:boolean);
    // ����� ������ �� ������ ������
    function FindSensor(chan:integer):cbaseobj;
    // �������� ����� �� ������
    function findchan(i:integer):cbaseobj;
    // �������� ����� �� �������
    function getchan(i:integer):cbaseobj;
    // �������� ������ ���������� � ������������ �������
    function getTurbine:cbaseobj;
    // �������� ����� �����
    function Addchan(i:integer):cbaseobj;overload;
    // �������� ����� �����
    function Addchan(chan:cbaseobj):cbaseobj;overload;
    // ����� �������
    function ChanCount:integer;
    // �������� ����� �� ������ UTS
    function UTS:cbaseobj;
    // ������� ������ �� ������
    procedure removeObj(obj:cBaseObj);override;
    // ��������� �������� �� ���� �������� � ������, �������� ��������� ������������ � ��������
    // � �������� ���� ������.
    procedure EnumSensors(proc:enumproc; data:pointer);
    // �������� ���� ������. ���� ������ obj �� ������� � ������� ���� ���� ������,
    // �� �� ������������, ����� ������������ ����� ��� ������ ������� �������.
    // ���� ���� ������� ��� �� ���������� nil
    // ���� showSelectDlg true �� ������ ���������� � ����� ������
    // obj - ������ ������� ������ ��������. ���� ��� ������� �� ���� ������
    // ���������� ������ �� ���� �������.
    function GetTaho(obj:cbaseobj; showSelectDlg:boolean):cbaseobj;
    // obj - ������ ������� ������ ��������. �������� ���� ��� �������
    // � ������ ���� ������, �� ���������� ������ �� ���� �������.
    function GetObjDlg(obj:cbaseobj; objtype:integer):cbaseobj;
    // ���������� ���� � ��� ����� ���
    procedure SetFolderPath(Folder,fname:string);
    function GetFolder:string;
    function GetFName:string;
    function GetDataThread(name:string):tobject;
    // ���������� ������� ���������
    procedure getmessage(str:string; messType:integer);
    property timeproc:tobject read ftimeproc write setTimeproc;
  end;

  const
    c_errorMessage = 1;
    c_infoMessage = 2;
    // ������� ����� 40 ����
    CardFreq = 40000000;
    // ���� � ������� ������������
    c_curCfg = '\files\BldEngCfgPath.cfg';
    // ����� ������
    c_ignore = $00000001;
    c_ShowMessage = $00000002;
    c_LogMessage = $00000004;
    c_EngLoading = $00000008;


implementation
uses usensor, ustage, upair, uBldObj, uChan, uTurbina, uUTSSensor,
     uerrorproc, uGetEngObjForm, uLfmFile, uBldFile, u2070, u2081, uPlat,
     uFileThread, ubldtimeproc, uDatathread;

procedure cBldEng.regObjClasses;
begin
  inherited;
  regclass(cUTSSensor);
  regclass(cSensor);
  regclass(cPair);
  regclass(cTurbine);
  regclass(cStage);
  regclass(cChan);
  regclass(cM2070);
  regclass(cM2081);
end;


constructor cBldEng.create;
var
  res:cardinal;
  path,section:ansistring;
begin
  inherited;
  SaveFolder:='';
  prec:=5;
  logFile:=clogFile.create(extractfiledir(Application.ExeName)+'\journal.log',';');
  setflag(flags,c_ShowMessage+c_LogMessage);
  // �������� ����� � ��������
  PathMng:=cBldPathMng.create(extractfiledir(Application.ExeName)+c_curCfg);

  // ������ ��������� �������
  channels:=cChanobj.create;
  channels.name:='������';
  channels.destroydata:=True;
  GetEngObjForm:=tGetEngObjForm.create(nil);
  HardWare:=cPlatsList.create;
  cPlatsList(HardWare).eng:=self;
  tGetEngObjForm(GetEngObjForm).linc(self);

  ThreadList:=cIDList.create;
end;

destructor cBldEng.destroy;
begin
  GetEngObjForm.destroy;
  channels.destroy;
  channels:=nil;
  logfile.destroy;
  PathMng.destroy;
  HardWare.destroy;
  ThreadList.destroy;
  inherited;
end;

procedure cBldEng.clear;
begin
  inherited;
  if channels<>nil then
  begin
    channels.childrens.cleardata;
  end;
end;

procedure cBldEng.clearTicks;
var
  I: Integer;
  chan:cchan;
begin
  if channels<>nil then
  begin
    for I := 0 to channels.ChildCount - 1 do
    begin
      chan:=cchan(channels.getChild(i));
      chan.ticks.clear;
    end;
  end;
end;

procedure cBldEng.setTimeProc(tp:tobject);
begin
  ftimeproc:=tp;
end;

// ������� ������ �� ������
procedure cBldEng.removeObj(obj:cBaseObj);
begin
  if obj is cchan then
  begin
    obj.unlinc;
  end
  else
  begin
    inherited removeobj(obj);
  end;
end;

procedure cBldEng.AddBaseObjInstance(obj:cbaseobj);
var
  ch:cchan;
begin
  if not cbldobj(obj).helper then
  begin
    if obj is cPlat then
    begin
      HardWare.Add(obj);
      obj.ReplaceObjMng(HardWare);
      exit;
    end;
    if obj is csensor then
    begin
      ch:=cchan(Addchan(csensor(obj).channumber));
    end;
    if not (obj is cchan) then
    begin
      inherited AddBaseObjInstance(obj);
      exit;
    end
    // ���� ������� ������ � ������
    else
    begin
      channels.addchild(obj);
      obj.ReplaceObjMng(self);
    end;
  end;
end;


function cBldEng.FindSensor(chan:integer):cbaseobj;
var
  I: Integer;
  obj:cbaseobj;
begin
  for I := 0 to objects.Count - 1 do
  begin
    obj:=getobj(i);
    if obj is csensor then
    begin
      if csensor(obj).chan.chan=chan then
      begin
        result:=obj;
      end;
    end;
  end;
end;

// �������� ����� �� ������
function cBldEng.findchan(i:integer):cbaseobj;
var
  chan:cchan;
  ind:integer;
begin
  chan:=cchan(channels.findObj(@i, ind));
  result:=chan;
end;
// �������� ����� �� �������
function cBldEng.getchan(i:integer):cbaseobj;
begin
  result:=cbaseobj(channels.getChild(i));
end;

function cBldEng.Addchan(i:integer):cbaseobj;
var
  chan:cchan;
  ind:integer;
begin
  if i<>-1 then
  begin
    chan:=cchan(channels.findObj(@i, ind));
    if chan=nil then
    begin
      chan:=cchan.create;
      chan.chan:=i;
      Addchan(chan);
    end;
    result:=chan;
  end
  else
    result:=nil;
end;

function cBldEng.Addchan(chan:cbaseobj):cbaseobj;
var
  lchan:cchan;
  ind:integer;
begin
  lchan:=cchan(channels.findObj(@cchan(chan).chan,ind));
  if (lchan=nil) then
  begin
    cbldobj(chan).eng:=self;
    lchan:=cchan(chan);
  end
  else
  // ���� ����� � ����� �������� ���������� �� �������� ���������� �����
  begin
    if lchan<>chan then
    begin
      channels.deletechild(ind);
      lchan.destroy;
    end;
  end;
  events.CallAllEventsWithSender(E_OnAddObj, chan);
  result:=lchan;
end;

function cBldEng.ChanCount:integer;
begin
  result:=channels.ChildCount;
end;

function cBldEng.getTurbine:cbaseobj;
var
  obj:cbaseobj;
  i:integer;
begin
  result:=nil;
  for I := 0 to count - 1 do
  begin
    obj:=getobj(i);
    if obj is cTurbine then
    begin
      result:=obj;
      exit;
    end;
  end;
end;

procedure cBldEng.EnumSensors(proc:enumproc; data:pointer);
var
  I: Integer;
  obj:cbldobj;
begin
  for I := 0 to count - 1 do
  begin
    obj:=cbldobj(getobj(i));
    if obj is csensor then
      proc(obj,data);
  end;
end;

function cBldEng.GetObjDlg(obj:cbaseobj; objtype:integer):cbaseobj;
var
  header:string;
begin
  case objtype of
    c_edgeSensor: header:= '����� ������������� �������';
    c_RootSensor: header:= '����� ��������� �������';
    c_tahoSensor: header:= '����� ���� �������';
    c_Turbine: header:= '����� �������';
    c_Sensor: header:= '����� �������';
    c_Stage: header:= '����� �������';
    c_Chan: header:= '����� ������';
    c_pair: header:= '����� ����';
  end;
  result := csensor(tGetEngObjForm(GetEngObjForm).GetObj(objtype, obj, header));
end;

function cBldEng.GetTaho(obj:cbaseobj; showselectdlg:boolean):cbaseobj;
var
  parent:cbaseobj;
  taho:csensor;
begin
  taho:=nil;
  if not showselectdlg then
  begin
    // ���� ���������� ������ - ������
    if obj is csensor then
    begin
      parent:=csensor(obj).stage;
      if parent<>nil then
      begin
        taho:=cstage(parent).GetTaho;
      end;
    end;
    // ���� ���������� ������ - ����
    if obj is cpair then
    begin
      parent:=cpair(obj).stage;
      if parent<>nil then
      begin
        taho:=cstage(parent).GetTaho;
      end;
    end;
    // ���� ���������� �������
    if obj is cstage then
    begin
      taho:=cstage(obj).GetTaho;
    end;
  end;
  if showselectdlg and (taho=nil) then
  begin
    taho:=csensor(tGetEngObjForm(GetEngObjForm).GetObj(c_tahoSensor, nil, '����� ���� �������'));
  end;
  result:=taho;
end;

procedure cBldEng.getmessage(str:string; messType:integer);
begin
  if CheckFlag(flags, c_ShowMessage) then
  begin
    showmessage(str);
  end;
  if CheckFlag(flags, c_LogMessage) then
  begin
    if messType=c_errorMessage then
    begin
      logFile.addErrorMes(str);
    end;
    if messType=c_infoMessage then
    begin
      logFile.addInfoMes(str);
    end;
  end;
end;

procedure cBldEng.setEngFlag(flag:cardinal; b:boolean);
begin
  if b then
    setFlag(flags,flag)
  else
    dropFlag(flags,flag);
end;

function cBldEng.UTS:cbaseobj;
var
  i:integer;
  obj:cbaseobj;
begin
  result:=nil;
  for I := 0 to objects.Count - 1 do
  begin
    obj:=getObj(i);
    if obj is cUTSSensor then
    begin
      if cUTSSensor(obj).chan<>nil then
      begin
        result:=obj;
        exit;
      end;
    end;
  end;
end;

procedure cBldEng.SetFolderPath(Folder,fname:string);
var
  t:cFileThread;
begin
  t:=cFileThread(cDataThreadMng(cbldtimeproc(ftimeproc).dataThreads).GetThread('cFileThread'));
  if t<>nil then
  begin
    t.Init(folder,fname);
  end
  else
  begin
    getmessage('������� ���������� ���� � �������� ��������������� �� �������� ������ cFileThread',c_errorMessage);
  end;
end;

function cBldEng.GetFolder:string;
var
  t:cFileThread;
begin
  result:='';
  t:=cFileThread(cDataThreadMng(cbldtimeproc(ftimeproc).dataThreads).GetThread('cFileThread'));
  if t<>nil then
  begin
    result:=cFileThread(t).folder;
  end
end;

function cBldEng.GetFName:string;
var
  t:cFileThread;
begin
  result:='';
  t:=cFileThread(GetDataThread('cFileThread'));
  if t<>nil then
  begin
    result:=cFileThread(t).namePart;
  end
end;

function cBldEng.GetDataThread(name:string):tobject;
begin
  result:=cDataThreadMng(cbldtimeproc(ftimeproc).dataThreads).GetThread('cFileThread');
end;

end.
