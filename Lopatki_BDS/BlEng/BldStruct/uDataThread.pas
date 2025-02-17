unit uDataThread;

interface

uses
  windows, uBaseObj, classes, SysUtils, uBldTimeProc, uChan, uBladeTicksFile,
  uCommonMath, uEventtypes, ExtCtrls, uBaseObjMng, uTickData,
  NativeXML, uEventList, dialogs, uSetList,
  ubldEngEventTypes;

type
  cDataThreadMng = class;

  // ����� ��� ����������� ����� ������� ���������� � ����������� �������
  // � ��������� BaseObj-��
  cDataThread = class(TThread)
  protected
    // ��� ���� ����� ����������� (������ ����� ����������)
    b_waitNewDataEvent:boolean;
    // ������� ����� (����� ������ ��� ������ � �������)
    channels: cBaseObj;
    fperiod: cardinal;
    fMng: cDataThreadMng;
    // ������ �������� ������ � ������� ������
    StartStopCs: TRTLCriticalSection;
    // ���������� ������� - ��������, �����, ������� � ���������, �����������
    fStatus: integer;
    // ������� ��� ������ ����� ������ (������ ����������� � ����������)
    m_NewDataEvent:thandle;
  public
    name:string;
    Data: pointer;
    // ���� ������������ ��� ������. ����� ��������� ������, ��� ����� ������ ������,
    // �������� � �.�.
    typeThread:cardinal;
  protected
    // ���������/ ���������� ������
    procedure setEnabled(b: boolean);
    function getEnabled: boolean;
    procedure InitCS;
    procedure DeleteCS;
    // ������� ����������� � execute. �������� ����������� ������� ��������� �������
    // ����� ���������� ������ ��������� �������� ��������� ������
    // ������ ���������� ������, �.�. ����� ���������� ����� ������� dataprocevent
    procedure PlayFunc; virtual;
    // ���������� ������� � �������
    procedure ExchangeData;

    procedure SetNewDataEvent;
    // �������� ������� - �� ����� ������
    procedure DropNewDataEvent;
    // �������� ������� - �������� ��������� ������
    function waitNewDataEvent: boolean;
    // ������� ������� ����� ������. ������ ����������� � ����������
    procedure OnNewData;virtual;
    // ���������� ��������������� ����� �������� ������ ����� ������ � ��������� setEnabled
    // ���������� ���� data
    procedure BeforeStartThread(sender:tobject);virtual;
    // ������� ���������� �� ��������� ������� ������
    procedure OnDataProc(sender:tobject);virtual;
    // ���������� � SetEnabled=false
    procedure OnBeforeStop(sender:tobject);virtual;
    procedure CreateEvents;virtual;
    procedure destroyEvents;virtual;
  public
    constructor create(mng: cDataThreadMng); virtual;
    destructor destroy; override;
    procedure Execute; override;
    property Enabled: boolean read getEnabled write setEnabled;
    property period: cardinal read fperiod write fperiod;
  end;

  cDataThreadMng = class(cSetList)
  private
    // �������� ��� ��� ������
    fEnabled: boolean;
    // ���������� ������� - ��������, �����, ������� � ���������, �����������
    fStatus: integer;
    // ���������������� ������ �� ������ ����������.
    // ���� �������� ��������� �������, �� ��� ���������� Execute �� ����� ��� ������� � �������� ��������� �������.
    // ��� ������� ������ ��������� SyncEvent
    fCallSync: boolean;
    // ������ �������� �������
    cs: TRTLCriticalSection;
  protected
    // ������� ������������� ������. ���� ����� 0, �� enabled:=false;
    fStopThreadCounter: integer;
  public
    m_tProc: cBldTimeProc;
    // ����������� �������
    AsyncEvent: TNotifyEvent;
    // ���������� �������
    SyncEvent: TNotifyEvent;
    // ��� ��������������� �������. ��� ������, �����
    m_threadtype:cardinal;
  protected
    procedure ASyncDataEvent(DataThread: cDataThread); virtual;
    procedure SyncDataEvent(DataThread: cDataThread); virtual;
    // ���������/ ���������� �������
    procedure setEnabled(b: boolean);
    function getEnabled: boolean;
  public
    constructor create;OVERRIDE;
    destructor destroy; override;
    procedure Linc(tProc: cBldTimeProc);
    function AddObj(key:pointer):integer;override;
    // ��������� ��������� ����� ���������� �������
    procedure addStartedThread;
    procedure decStartedThread;
    function GetThread(i: integer): cDataThread;overload;
    function GetThread(p_name: string): cDataThread;overload;
    // �������� ������� (�������� ���������� ������� � ���������� �� ������)
    procedure deletechild(node: pointer); override;
    // ���������/ ���������� �������
    property Enabled: boolean read getEnabled write setEnabled;
    // ���������������� ������ �� ������ ����������.
    property CallSync: boolean read getEnabled write setEnabled;
  end;

const
  c_Stop = 0;
  c_TryStop = 1;
  c_Play = 3;
  c_destroy = 4;
  // ���� �������
  c_FileThread = $00000001;
  c_PlatThread = $00000002;

implementation

procedure cDataThread.BeforeStartThread(sender:tobject);
begin
end;

procedure cDataThread.PlayFunc;
begin
  fMng.ASyncDataEvent(self);
end;

procedure cDataThread.ExchangeData;
var
  i: integer;
  chan, lchan: cchan;
  lticks: cBaseTicks;
begin
  for I := 0 to channels.childCount - 1 do
  begin
    lchan := cchan(channels.getChild(i));
    chan := cchan(fMng.m_tProc.eng.findchan(lchan.chan));
    if chan<>nil then
    begin
      lticks := lchan.ticks;
      lchan.ticks := chan.ticks;
      chan.ticks := lticks;
    end;
  end;
  // ������� ������� �������� ������? ����� ����� ��� �� ����
  // ���������� ������� � restarttasks
  fMng.m_tProc.SetDataExchangeEvent;
end;

procedure cDataThread.Execute;
begin
  while (not terminated) and (fstatus<>c_destroy) do
  begin
    // ���� ����  ����� ��������� ���������� ������
    // ������������ ������� ���� ������� �������� setEvent, ���� ���� resetEvent
    // ���� ������ �� ���������� ����� ����� �������� !!!
    fMng.m_tProc.waitDataProcEvent;
    //EnterCriticalSection(StartStopCs);
    // ������� waitNewDataEvent ������ ��������� � play ����� �� �����������
    // ��� ��������� (����� ������������ �� ���� ������)
    if b_waitNewDataEvent then
      waitNewDataEvent;
    if fStatus = c_Play then
    begin
      // ��������� ������
      PlayFunc;
      ExchangeData;
      // ������ ����������!
      fMng.m_tProc.SetDataExchangeEvent;
      // ����� ������������ �������
      if assigned(fMng.AsyncEvent) then
        fMng.AsyncEvent(self);
    end;
    if fStatus = c_TryStop then
    begin
      EnterCriticalSection(StartStopCs);
      fStatus := c_Stop;

      LeaveCriticalSection(StartStopCs);
      fMng.decStartedThread;
      suspend;
    end;
    sleep(fperiod);
  end;
end;

constructor cDataThread.create(mng: cDataThreadMng);
begin
  inherited create(true);
  b_waitNewDataEvent:=true;
  fmng:=mng;

  channels := cChanobj.create;
  channels.destroydata := true;
  InitCS;

  // ��������� ������
  FreeOnTerminate := false;
  Priority := tpLower;

  name:=classname;

  m_NewDataEvent:=CreateEvent(nil, True, False, nil);

  CreateEvents;
  mng.AddObj(self);
end;

destructor cDataThread.destroy;
begin
  fStatus := c_destroy;
  if suspended then
  begin
    resume;
  end;

  CloseHandle(m_newDataEvent);
  m_newDataEvent := 0;

  DeleteCS;
  channels.destroy;
  destroyEvents;
  inherited;
end;

procedure cDataThread.CreateEvents;
begin
  fmng.m_tProc.feng.Events.AddEvent('cDataThread_OnFinishPlayData',e_OnFinishPlayData, OnDataProc);
end;

procedure cDataThread.destroyEvents;
begin
  fmng.m_tProc.feng.Events.removeEvent(OnDataProc,e_OnFinishPlayData);
end;

procedure cDataThread.InitCS;
begin
  InitializeCriticalSection(StartStopCs);
end;

procedure cDataThread.DeleteCS;
begin
  DeleteCriticalSection(StartStopCs);
end;

procedure cDataThread.OnNewData;
begin

end;

// ���������/ ���������� ������
procedure cDataThread.setEnabled(b: boolean);
begin
  if b then
  begin
    if fStatus=c_Play then
      exit;
  end;
  // �������� �� ��������
  if b then
  begin
    EnterCriticalSection(StartStopCs);
    fStatus := c_Play;
    LeaveCriticalSection(StartStopCs);
    fMng.addStartedThread;
    BeforeStartThread(data);
    if suspended then
      resume;
  end
  else
  begin
    OnBeforeStop(nil);
    EnterCriticalSection(StartStopCs);
    // ��������� ���������. ��������� �������� � execute
    fStatus := c_TryStop;
    // �� ���� ����� ������
    SetNewDataEvent;
    LeaveCriticalSection(StartStopCs);
  end;
end;

procedure cDataThread.OnDataProc(sender:tobject);
begin

end;

procedure cDataThread.SetNewDataEvent;
begin
  SetEvent(m_NewDataEvent);
end;
// �������� ������� - �� ����� ������
procedure cDataThread.DropNewDataEvent;
begin
  ResetEvent(m_NewDataEvent);
end;

// �������� ������� - �������� ��������� ������
function cDataThread.waitNewDataEvent: boolean;
begin
  Result := waitforsingleobject(m_NewDataEvent, infinite) = WAIT_OBJECT_0;
  DropNewDataEvent;
end;


procedure cDataThread.OnBeforeStop(sender:tobject);
begin
end;

function cDataThread.getEnabled: boolean;
begin
  result := (fStatus=c_play);
end;

procedure cDataThreadMng.deletechild(node: pointer);
begin
  cDatathread(node).Destroy;
end;

procedure cDataThreadMng.ASyncDataEvent(DataThread: cDataThread);
begin

end;

procedure cDataThreadMng.SyncDataEvent(DataThread: cDataThread);
begin

end;

function cDataThreadMng.GetThread(i: integer): cDataThread;
begin
  result := cDataThread(getNode(i));
end;

function cDataThreadMng.GetThread(p_name: string): cDataThread;
var
  i: Integer;
  t:cDataThread;
begin
  result:=nil;
  for i := 0 to Count - 1 do
  begin
    t:=GetThread(i);
    if t.name=p_name then
    begin
      result:=t;
      exit;
    end;
  end;
end;

procedure cDataThreadMng.setEnabled(b: boolean);
var
  t: cDataThread;
  i: integer;
begin
  // �������� �������� ������
  //m_tProc.DropDataProcEvent;
  if b then
  begin
    fEnabled := true;
    for i := 0 to Count - 1 do
    begin
      t := GetThread(i);
      if checkflag(t.typeThread,m_threadtype) then
        t.Enabled := true;
    end;
  end
  else
  begin
    for i := 0 to Count - 1 do
    begin
      t := GetThread(i);
      t.Enabled := false;
    end;
  end;
end;

function cDataThreadMng.getEnabled: boolean;
begin
  if (fStopThreadCounter = Count) then
    result := false
  else
    result := true;
end;

function ThreadComparator(p1,p2:pointer):integer;
var
  b:boolean;
begin
  Result:=AnsiCompareStr(cdatathread(p1).name,cdatathread(p2).name);
end;

constructor cDataThreadMng.create;
begin
  inherited;
  comparator:=ThreadComparator;
  destroydata := true;
  InitializeCriticalSection(cs);
end;


destructor cDataThreadMng.destroy;
begin
  DeleteCriticalSection(cs);
  enabled:=false;
  while enabled do
  begin
    sleep(1000);
  end;
  inherited;
end;

procedure cDataThreadMng.Linc(tProc: cBldTimeProc);
begin
  m_tProc := tProc;
end;

procedure cDataThreadMng.addStartedThread;
begin
  EnterCriticalSection(cs);
  dec(fStopThreadCounter);
  LeaveCriticalSection(cs);
end;

procedure cDataThreadMng.decStartedThread;
begin
  EnterCriticalSection(cs);
  inc(fStopThreadCounter);
  LeaveCriticalSection(cs);
end;

function cDataThreadMng.AddObj(key:pointer):integer;
begin
  inherited;
  m_tProc.feng.ThreadList.AddID(cdatathread(key).ClassName, cdatathread(key).ThreadID);
  decStartedThread;
end;

end.
