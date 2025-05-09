// ����� ������������ ��� ��������� ������ � realtime
unit uBldTimeProc;

interface

uses
  uBldEng, usensor, ustage, utickdata, ubldmath, classes, ubldEngEventTypes,
  uBaseBldAlg, uCommonMath, uEventtypes, uTag, uBaseObjMng, windows, SysUtils,
  uSetList;

type
  cBldTimeProc = class
  public
    feng: cbldeng;
    // ������ �����
    fTagMng: cTagMng;
    alarms: cBaseObjMng;
    HistMng: tobject;
    // ������ ���������� ������� ����� ����������� ��� ������� ������
    algList: cBaseObjMng;
    // ������ �������
    TaskList: cBaseObjMng;
    // ������� ���������� ������
    fViewTime: single;
    // ������ ����������.
    m_DataProcEvent,
    m_DataExchangeEvent: thandle;
    // �������� ������� ������
    dataThreads: cSetList;
  protected
    ft1, ft2: single;
    // ��������� ����� (Run/Pause)
    fstate: boolean;
  protected
    procedure OnTagSetActive(sender: tobject);
  private
    // ����� ������ ������ �� t
    procedure setEng(p_eng: cbldeng);
    // ���������� ����� ������ � �������������� ����� ��������� ���������
    // (���� ��������� ���������)
    procedure OnFinishPlayData(sender: tobject);
    // ���������� � ������ ��������� ������ ����� ��������� ����� �������
    // ����� ������� ��������� ������ � ������� ���������
    procedure OnASyncGetData(sender:tobject);
  protected
    // ��������� ���� �� ���� ���� ������ ��������� ������ � ��������� ���������
    function getplaymode: boolean;
    function checkT(t: single): boolean;
    function getdt: single;
    procedure setdt(p_dt: single);
    // ������� ���������� ���������� � �������
    function getPeriod: single;
    procedure setPeriod(p_dt: single);
  public
    constructor create(p_eng: tobject);
    destructor destroy;
    procedure addalgtags(alg: cbaseBldAlg);
    // �������� ��������
    procedure addAlg(a: cbaseBldAlg);
    // �������� ������ �� �������� �� ����� � �� �������
    function Getalg(i: integer): cbaseBldAlg; overload;
    function Getalg(name: string): cbaseBldAlg; overload;
    function AlgCount: integer;
    procedure clear;
    // ������� ������ ��������������� ������
    procedure stop;
    procedure deleteAlg(alg: cbaseBldAlg);
    function getprec: integer;
    // ���������� � ������� (task) ����� ���� ��� ����� �������� ��� ������
    procedure OnTaskFinishEval(sender: tobject);

    // �������� ������� - �������� ��������� ������
    function waitDataProcEvent: boolean;
    // �������� �������� ������� ������� ����� ������
    // ���������� �������� � ������ ��������� ������ �����
    // ������ ���������� � ��������� �����. ����������� � ���������� �����
    //  � ������ ������� ��������� (restarthreads)
    // ����� ������� ��������� � �������� � ������ ����� ���������� ������ play
    // - ����� ������
    procedure SetDataProcEvent;
    // �������� ������� - �� ����� ������
    procedure DropDataProcEvent;
    // �������� �������� ������� ������� ����� ������
    // ���������� �������� � ������ ��������� ������ �����
    // ������ ���������� � ��������� �����. ����������� � ���������� �����
    //  � ������ ������� ��������� (restarthreads)
    // ����� ������� ��������� � �������� � ������ ����� ���������� ������ play
    // - ����� ������
    procedure SetDataExchangeEvent;
    // �������� ������� - �� ����� ������
    procedure DropDataExchangeEvent;
    // �������� ������� - �������� ��������� ������
    // ������ �������� � ������������ ������, ����� �� ��������� ������
    function waitDataExchangeEvent: boolean;
    // ��������� ������ �� ��������� ���������� ����� � ����. �����������
    // ������ ���� ������ ������� ��� ������ ����������
    procedure RestartTasks;
    procedure delTasks;
    function GetState: integer;
    // mode ��� ������� ������
    procedure play(p_mode: integer);
    // ������� ���������� ����� ���������� ������
    // ������ ���������� ���� � ������� � ������� ���������� ������
    procedure OnNewData(sender: tobject);
  public
    // ��������� ������� ����� (false ���� ��� � �����)
    property PlayMode: boolean read getplaymode;
    property eng: cbldeng read feng write setEng;
    property prec: integer read getprec;
    property ViewTime: single read fViewTime write fViewTime;
    property dt: single read getdt write setdt;
    property period: single read getPeriod write setPeriod;
  end;

const
  c_Device = 2;

implementation

uses
  uAlarms, uAlgMng, uHistoryMng, uTaskMng, uProcessAlgtask, uPlat,
  uDataThread, uFileThread;

constructor cBldTimeProc.create(p_eng: tobject);
var
  DataThread: cFileThread;
begin
  feng := cbldeng(p_eng);

  alarms := cAlarmMng.create;
  cAlarmMng(alarms).linc(self);
  fTagMng := cTagMng.create;
  algList := cAlgMng.create;
  cAlgMng(algList).linc(self);
  HistMng := cHistoryMng.create;
  // ������� ������ �����
  TaskList := cTaskMng.create;
  TaskList.events.AddEvent('cBldTimeProc_OnTaskFinishEval', e_OnFinishPlayData,
    OnTaskFinishEval);

  m_DataProcEvent := CreateEvent(nil, True, False, nil);
  m_DataExchangeEvent := CreateEvent(nil, True, False, nil);

  dataThreads := cDataThreadMng.create;
  cDataThreadMng(dataThreads).linc(self);
  cDataThreadMng(dataThreads).AsyncEvent:=OnASyncGetData;
  // ����� ��� ������ � ����������� �������
  DataThread := cFileThread.create(cDataThreadMng(dataThreads));
end;

destructor cBldTimeProc.destroy;
var
  i: integer;
  a: cbaseBldAlg;
begin
  delTasks;
  // ����� ��������� �������� ������� ����� �������������� � ������ �����.
  // ���������� ��������� ���� ��� ������ ������������
  while not ctaskmng(TaskList).Stoped do
  begin
    sleep(300);
  end;

  CloseHandle(m_DataProcEvent);
  m_DataProcEvent := 0;
  CloseHandle(m_DataExchangeEvent);
  m_DataExchangeEvent := 0;


  TaskList.destroy;
  algList.destroy;
  fTagMng.destroy;
  cHistoryMng(HistMng).destroy;
  alarms.destroy;
  dataThreads.destroy;
end;


procedure cBldTimeProc.OnTagSetActive(sender: tobject);
begin
  if cBaseTag(sender).active then
  begin
    fTagMng.Add(cBaseTag(sender));
  end
  else
  begin
    fTagMng.removeObj(cBaseTag(sender));
  end;
  eng.events.CallAllEventsWithSender(e_OnAddRemoveTag, cBaseTag(sender));
end;

procedure cBldTimeProc.addalgtags(alg: cbaseBldAlg);
var
  i: integer;
  tag: cBaseTag;
begin
  for i := 0 to alg.tags.Count - 1 do
  begin
    tag := cBaseTag(alg.tags.getobj(i));
    tag.onsetactive := OnTagSetActive;
    if tag.active then
      fTagMng.Add(tag);
  end;
end;

procedure cBldTimeProc.addAlg(a: cbaseBldAlg);
begin
  if a <> nil then
  begin
    algList.Add(a, nil);
  end;
end;

function cBldTimeProc.Getalg(i: integer): cbaseBldAlg;
begin
  Result := cbaseBldAlg(algList.getobj(i));
end;

function cBldTimeProc.Getalg(name: string): cbaseBldAlg;
var
  i: integer;
  obj: cbaseBldAlg;
begin
  obj := cbaseBldAlg(algList.getobj(name));
  if obj <> nil then
  begin
    Result := obj;
  end
  else
    Result := nil;
end;

function cBldTimeProc.AlgCount: integer;
begin
  Result := algList.Count;
end;


procedure cBldTimeProc.OnFinishPlayData(sender: tobject);
begin
  // �������� ������� ��� ������ ���������� � ���� �� ���������� ����� ����
  SetDataProcEvent;
  // PostThreadMessage( cFileLoaderMng(FileLoaderMng).ThreadID, wm_OnStopTasksMessage, 0, 0);
  // cFileLoaderMng(FileLoaderMng).OnStopPlay(sender);
  if feng <> nil then
  begin
    feng.events.CallAllEvents(e_OnFinishPlayData);
  end;
end;

procedure cBldTimeProc.RestartTasks;
var
  i: integer;
  t, activetask: ctask;
begin
  // ������ �������� � ������������ ������
  //waitDataExchangeEvent;
  for i := 0 to TaskList.Count - 1 do
  begin
    if i = 0 then
      fstate := True;
    activetask := cTaskMng(TaskList).activetask;
    t := ctask(TaskList.getobj(i));
    t.Thread.t1 := activetask.Thread.t0;
    t.Thread.t2 := activetask.Thread.t1 + activetask.Thread.dt;
    t.Thread.state := c_Run;
  end;
  eng.events.CallAllEvents(E_OnTimeStartStop);
end;

procedure cBldTimeProc.delTasks;
var
  i: integer;
  t: ctask;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    t := ctask(TaskList.getobj(i));
    t.Thread.state := uprocessalgtask.c_destroy;
  end;
end;

procedure cBldTimeProc.play(p_mode: integer);
begin
  // �� ���� ��������� ������� ������ �.�. ������ ��� �� �����������
  SetDataProcEvent;
  cDataThreadMng(dataThreads).m_threadtype := p_mode;
  cDataThreadMng(dataThreads).enabled := True;
  // ���� ��� ������� (���� �����, ������ �������, ��� ������ ��������)
  if p_mode=c_demo then
    SetDataExchangeEvent;
  // ��������� ������ �� ���������
  RestartTasks;
end;

procedure cBldTimeProc.stop;
var
  i: integer;
  t: ctask;
begin
  // ������������� ������ ����� ������ (�� ��������� �����)
  cDataThreadMng(dataThreads).enabled := False;
  // �������� ���� ��������� ��������� �������� ������
  // (����� �������� ��������� ������)
  SetDataProcEvent;
  for i := 0 to TaskList.Count - 1 do
  begin
    t := ctask(TaskList.getobj(i));
    t.Thread.state := uProcessAlgTask.c_Stop;
  end;
  fstate := False;
  eng.events.CallAllEvents(E_OnTimeStartStop);
end;

function cBldTimeProc.getplaymode: boolean;
var
  i: integer;
  t: ctask;
begin
  Result := False;
  for i := 0 to TaskList.Count - 1 do
  begin
    t := ctask(TaskList.getobj(i));
    if checkFlag(t.Thread.state, c_Run) then
    begin
      Result := True;
      exit;
    end;
  end;
end;

procedure cBldTimeProc.clear;
var
  i: integer;
  a: cbaseBldAlg;
begin
  for i := 0 to algList.Count - 1 do
  begin
    a := Getalg(i);
    a.destroy;
  end;
  algList.clear;
end;

procedure cBldTimeProc.setEng(p_eng: cbldeng);
begin
  feng := p_eng;
  cTaskMng(TaskList).linc(p_eng);
  cHistoryMng(HistMng).linc(feng);
end;

procedure cBldTimeProc.deleteAlg(alg: cbaseBldAlg);
begin
  alg.destroy;
end;

function cBldTimeProc.getprec: integer;
begin
  Result := eng.prec;
end;

// �������� ���� ����� > ����� ������� �� ��������� �����
function cBldTimeProc.checkT(t: single): boolean;
begin

end;

procedure cBldTimeProc.OnTaskFinishEval(sender: tobject);
var
  res: boolean;
begin
  res := PlayMode;
  if not res then
  begin
    if fstate then
    begin
      fstate := False;
      OnFinishPlayData(nil);
    end;
  end;
end;

procedure cBldTimeProc.SetDataProcEvent;
begin
  SetEvent(m_DataProcEvent);
end;

// �������� ������� - ��������� ��������� ������
procedure cBldTimeProc.DropDataProcEvent;
begin
  ResetEvent(m_DataProcEvent);
end;
// �������� ������� - �������� ��������� ������
function cBldTimeProc.waitDataProcEvent: boolean;
begin
  Result := waitforsingleobject(m_DataProcEvent, infinite) = WAIT_OBJECT_0;
end;

procedure cBldTimeProc.SetDataExchangeEvent;
begin
  SetEvent(m_DataExchangeEvent);
  // �������� �������� ��������� ������
  DropDataProcEvent;
end;
// �������� ������� - ��������� ��������� ������
procedure cBldTimeProc.DropDataExchangeEvent;
begin
  ResetEvent(m_DataExchangeEvent);
end;

// �������� ������� - �������� ��������� ������
function cBldTimeProc.waitDataExchangeEvent: boolean;
begin
  Result := waitforsingleobject(m_DataExchangeEvent, infinite) = WAIT_OBJECT_0;
  DropDataExchangeEvent;
end;


function cBldTimeProc.GetState: integer;
begin
  Result := 0;
  if PlayMode then
    Result := 2
  else
  begin
    // if cFileLoaderMng(FileLoaderMng).mode then
    // begin
    // result:=1;
    // end;
  end;
end;

function cBldTimeProc.getdt: single;
var
  t: ctask;
begin
  t := ctask(TaskList.getobj(0));
  if t <> nil then
  begin
    Result := t.Thread.dt;
  end
  else
    Result := 0;
end;

procedure cBldTimeProc.setdt(p_dt: single);
var
  t: ctask;
  i: integer;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    t := ctask(TaskList.getobj(i));
    t.Thread.dt := p_dt;
  end;
end;

function cBldTimeProc.getPeriod: single;
var
  t: ctask;
begin
  t := ctask(TaskList.getobj(0));
  if t <> nil then
  begin
    Result := t.Thread.period;
  end
  else
    Result := 0;
end;

procedure cBldTimeProc.setPeriod(p_dt: single);
var
  t: ctask;
  i: integer;
begin
  for i := 0 to TaskList.Count - 1 do
  begin
    t := ctask(TaskList.getobj(i));
    t.Thread.period := p_dt;
  end;
end;

procedure cBldTimeProc.OnASyncGetData(sender:tobject);
begin
  restarttasks;
end;

procedure cBldTimeProc.OnNewData(sender: tobject);
begin

end;

end.
