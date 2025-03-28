unit uProcessAlgTask;

interface

uses
  windows, uBldEng, uBaseObj, uTickData, classes, ubldEngEventTypes, SysUtils,
  uBaseBldAlg, uCommonMath, uEventtypes, ExtCtrls, usensor, uBaseObjMng, uBldTimeProc,
  uBldMath, NativeXML, uEventList, dialogs, uchan;

type
  cProcessAlgThread = class;

  cTask = class(cBaseObj)
    Thread:cProcessAlgThread;
  protected
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    constructor create;override;
    destructor destroy;override;
  end;

  cProcessAlgThread = class(TThread)
  public
    tproc:cbldtimeproc;
    eng:cbldeng;
  private
    task:ctask;
    fTimeLength:single;
    // ������, ����� � ������ �������� ���������� �����
    ft1, ft2, fdt:single;
    // ������ ������� � ���������� �������� �� ���������� �����������
    fiT1,fiT2:integer;
    // ����� �������� � ������� ��������� �����
    turnCount:integer;
    // ���� ������ �� �������� ��������� ����� �������� ���������� � ����
    // � ������ ����������
    ftaho:csensor;
    // ������ ���������� ������� ����� ����������� ��� ������� ������
    algList:tStringlist;
    // ������ ���������� ������ � �������������
    fPeriod:cardinal;
    // ��������� ������
    // c_Run, c_Stop, c_TryStop
    fstate:cardinal;
    cs, StartStopcs: TRTLCriticalSection;
  protected
    // ���������� bop ������� synchronise - � �������� ������
    procedure SyncCallEvents;
    function events:ceventlist;
    procedure SetState(s:cardinal);
    function getperiod:single;
    procedure setperiod(v:single);
    procedure Execute; override;
    procedure PlayFunc(sender:tobject);
    // �������� ����� �� ������ dt
    procedure IncFrame;
    // ������ ����� �������� �������� � ������� �����.
    function updateFrame:integer;
    procedure settimelength(t:single);
    function getTimeLength:single;
    // ����� ����������
    procedure CallAlgs;
    // ����� ������ ����� �� t
    function GetT1(s:csensor;t:single):integer;
    // ����� ������ ������ �� t
    function GetT2(s:csensor;t:single):integer;
    function fgett1:single;
    function fgett2:single;
    procedure sett1(t:single);
    procedure sett2(t:single);
    procedure setdt(t:single);
    function getdt:single;
    procedure settaho(t:csensor);
    // �������� ���� ����� > ����� ������� �� ��������� �����
    function checkT(t:single):boolean;
    // ���������� ����� ������ ���������
    procedure OnFinishPlayData(sender:tobject);
    // ������ ������ ��������������� ������
    procedure play;
    // ������� ������ ��������������� ������
    procedure stop;
    procedure InitCS;
    procedure DeleteCS;
  public
    function t0:single;
    procedure EnterCS;
    procedure ExitCS;
    // ���������������
    procedure linc(p_eng:cbldeng);
    procedure addAlg(a:cBaseBldAlg);
    procedure removeAlg(a:cbaseBldAlg);
    // �������� ������ �� �������� �� ����� � �� �������
    function Getalg(i:integer):cBaseBldAlg;overload;
    function Getalg(name:string):cBaseBldAlg;overload;
    function AlgCount:integer;
    procedure clear;
  public
    constructor create;
    destructor destroy;override;
    // ���������� ����� ������� (����� �� ����)
    property TimeLength:single read getTimeLength write settimelength;
    property t1:single read fGetT1 write setT1;
    property t2:single read fGetT2 write setT2;
    property dT:single read getdt write setDT;
    property taho:csensor read ftaho write settaho;
    property period:single read getPeriod write setPeriod;
    property state:cardinal read fstate write setState;
  end;

const
  c_Run = $000001;
  c_Stop = $000002;
  c_TryStop = $000004;
  c_tRYdESTROY = $000008;
  c_destroy = $000010;

implementation
uses
  uAlgMng, uTaskMng;

constructor cProcessAlgThread.create;
begin
  inherited create(true);
  fstate:=c_stop;
  InitCS;
  // ��������� ������
  FreeOnTerminate:=false;
  Priority:=tpLower;
  alglist:=tstringlist.Create;
end;

destructor cProcessAlgThread.destroy;
begin
  if suspended then
  begin
    resume;
    state:=c_DESTROY;
  end;
  alglist.Destroy;
  alglist:=nil;
  deletecs;
  inherited;
end;

procedure cProcessAlgThread.linc(p_eng:cbldeng);
begin
  eng:=p_eng;
  tproc:=cbldtimeproc(eng.timeProc);
end;

procedure cProcessAlgThread.addAlg(a:cBaseBldAlg);
var
  i:integer;
  obj:cBaseBldAlg;
begin
  if a<>nil then
  begin
    while algList.find(a.name,i) do
    begin
      obj:=cbasebldalg(algList.Objects[i]);
      if obj<>a then
        a.name:=modname(a.name, false);
    end;
    alglist.addobject(a.name,a);
    if a.Task<>nil then
      ctask(a.task).Thread.removeAlg(a);
    a.Task:=task;
  end;
end;

procedure cProcessAlgThread.removeAlg(a:cbaseBldAlg);
var
  i:integer;
  alg:cbasebldalg;
begin
  if alglist.Find(a.name,i) then
  begin
    alg:=cbasebldalg(algList.Objects[i]);
    if a=alg then
      alglist.Delete(i);
  end;
end;

function cProcessAlgThread.Getalg(i:integer):cBaseBldAlg;
begin
  Result:=cBaseBldAlg(alglist.objects[i]);
end;

function cProcessAlgThread.Getalg(name:string):cBaseBldAlg;
var
  i:integer;
begin
  if algList.find(name,i) then
  begin
    result:=Getalg(i);
  end
  else
    result:=nil;
end;

function cProcessAlgThread.AlgCount:integer;
begin
  result:=alglist.count;
end;

procedure cProcessAlgThread.clear;
var
  I: Integer;
  a:cBaseBldAlg;
begin
  for I := 0 to algList.Count - 1 do
  begin
    a:=Getalg(i);
    a.Destroy;
  end;
  alglist.Clear;
end;

procedure cProcessAlgThread.play;
begin
  if suspended then
    resume;
end;

procedure cProcessAlgThread.stop;
begin
  if not suspended then
    suspend;
end;

procedure cProcessAlgThread.PlayFunc(sender:tobject);
begin
  // �������� ����� �� dt (��� ��������� t1, t2 ���������� ��������,
  // ��� ������ �� ����� �� ������������). ���� ����� �� ��������� �� ����������
  if checkflag(state,c_Run) then
  begin
    IncFrame;
  end;
  if checkflag(state,c_Run) then
  begin
    if TimeLength>0 then
    begin
      CallAlgs;
      // ������������ ��������� � �������!!! (���� �������
      // ��������� ����� ������� �������)
      eng.Events.CallAllEventsWithSender(E_OnTimeProc,self);
    end
    else
      fstate:=c_TryStop;
  end;
end;


procedure cProcessAlgThread.Execute;
begin
  while (not terminated) and (fstate<>c_destroy) do
  begin
    EnterCriticalSection(StartStopCs);
    if checkflag(state,c_Run) then
    begin
      // ���� �� ����� �� ���� ������ �� � ������� onFinishPlayData � ����������
      // ����� ������������ ��� ������, �.�. ����� �� ������� �������� ���������
      // SatrtStopCs � �������� ������
      LeaveCriticalSection(StartStopCs);
      playFunc(nil);
    end
    else
      LeaveCriticalSection(StartStopCs);
    sleep(fPeriod);
    if checkflag(state,c_trystop) then
    begin
      fstate:=c_stop;
      stop;
    end;
    if checkflag(state,c_trydestroy) then
      fstate:=c_destroy;
  end;
end;

procedure cProcessAlgThread.IncFrame;
begin
  t1:=ft1+dt;
  t2:=ft2+dt;
  updateFrame;
end;

function cProcessAlgThread.updateFrame:integer;
begin
  turnCount:=fiT2-fiT1;
  result:=turnCount;
end;

procedure cProcessAlgThread.settimelength(t:single);
begin
  ftimelength:=t;
end;

function cProcessAlgThread.getTimeLength:single;
var
  tick:stickdata;
  lt:single;
begin
  result:=0;
  if taho<>nil then
  begin
    if taho.tickscount<>0 then
    begin
      tick:=taho.chan.ticks.gettick(taho.chan.ticks.Count-1);
      lt:=TickToSec(tick);
      ftimelength:=lt-t0;
      result:=ftimelength;
    end;
  end;
end;

procedure cProcessAlgThread.CallAlgs;
var
  I: Integer;
  a:cBaseBldAlg;
  it1,it2:integer;
begin
  for I := 0 to algList.Count - 1 do
  begin
    a:=Getalg(i);
    if a.curtaho=taho then
    begin
      it1:=fit1;
      it2:=fit2;
    end
    else
    begin
      it1:=GetT1(a.curtaho,ft1);
      it2:=GetT2(a.curtaho,ft2);
    end;
    if not a.prepared then
      a.prepare;
    if a.prepared then
    begin
      if not a.blocked then
      begin
        a.apply(it1,it2);
      end;
    end;
  end;
end;

// ����� ������ ������ �� t
function cProcessAlgThread.GetT2(s:csensor;t:single):integer;
var
  tick:stickdata;
begin
  if s.tickscount<>0 then
  begin
    tick:=SecToTick(t);
    s.chan.ticks.GetHiTick(tick,result);
  end
  else
    result:=-1;
end;

// ����� ������ ����� �� t
function cProcessAlgThread.GetT1(s:csensor;t:single):integer;
var
  tick:stickdata;
  p:pointer;
  chan:cchan;
begin
  if s.tickscount<>0 then
  begin
    tick:=SecToTick(t);
    chan:=s.chan;
    p:=chan.ticks.GetLow(@tick,result);
    if p=nil then
    begin
      ft1:=ticktosec(chan.ticks.gettick(0));
      result:=0;
    end;
  end
  else
    result:=-1;
end;

function cProcessAlgThread.fgett1:single;
begin
  entercs;
  result:=ft1;
  exitcs;
end;

function cProcessAlgThread.fgett2:single;
begin
  entercs;
  result:=ft2;
  exitcs;
end;

procedure cProcessAlgThread.sett1(t:single);
begin
  entercs;
  ft1:=t;
  exitcs;  
  if checkT(t) then
  begin
    if taho<>nil then
    begin
      fit1:=GetT1(taho,t);
    end;
  end;
end;

procedure cProcessAlgThread.sett2(t:single);
begin
  entercs;
  ft2:=t;
  exitcs;  
  if checkT(t) then
  begin
    if taho<>nil then
    begin
      fit2:=GetT2(taho,t);
    end;
  end;
end;

procedure cProcessAlgThread.setdt(t:single);
begin
  if t>0.1 then
    fdt:=t
  else
    fdt:=0.1;
  t2:=t1+fdt;
end;

procedure cProcessAlgThread.settaho(t:csensor);
var
  tick:stickdata;
  lt:single;
  ldt:single;
begin
  ftaho:=t;
  ldt:=dt;
  t1:=ft1;
  t2:=ft1+ldt;
  ftimelength:=0;
  if taho<>nil then
  begin
    if taho.tickscount<>0 then
    begin
      tick:=taho.chan.ticks.gettick(taho.chan.ticks.Count-1);
      lt:=TickToSec(tick);
      ftimelength:=lt-t0;
    end;
  end;
  updateFrame;
end;

function cProcessAlgThread.checkT(t:single):boolean;
begin
  result:=true;
  if t>=t0+TimeLength then
  begin
    result:=false;
    OnFinishPlayData(nil);
  end
end;


function cProcessAlgThread.t0:single;
var
  tick:stickdata;
begin
  if taho<>nil then
  begin
    tick:=taho.chan.ticks.gettick(0);
    result:=TickToSec(tick);
  end
  else
    result:=0;
end;

function cProcessAlgThread.getdt:single;
begin
  result:=fdt;
end;

procedure cProcessAlgThread.SyncCallEvents;
begin
  Events.CallAllEventsWithSender(e_OnFinishPlayData, self);
end;

procedure cProcessAlgThread.OnFinishPlayData(sender:tobject);
begin
  fstate:=c_TryStop;
  if eng<>nil then
  begin
    synchronize(SyncCallEvents);
    //Events.CallAllEventsWithSender(e_OnFinishPlayData, self);
  end;
end;

function cProcessAlgThread.getperiod:single;
begin
  result:=fperiod/1000;
end;

procedure cProcessAlgThread.setperiod(v:single);
begin
  fperiod:=trunc(v*1000);
end;

function cProcessAlgThread.events:ceventlist;
begin
  result:=cBaseObjMng(task.getMng).Events;
end;

procedure cProcessAlgThread.SetState(s:cardinal);
var
  lthreadID:cardinal;
begin
  if fstate=s then exit;
  if checkflag(s,c_Run) then
  begin
    EnterCriticalSection(StartStopCs);
    fstate:=s;
    LeaveCriticalSection(StartStopCs);
    play;
  end
  else
  begin
    lthreadID:=GetCurrentThreadID;
    if s<>c_destroy then
    begin
      if lthreadID=ThreadID then
      begin
        fstate:=s;
        stop;
      end
      else
      begin
        fstate:=c_TryStop;
      end;
    end
    else
    begin
      // ���� ����� ���������� �� ��� ����� ���������� �����
      if fstate=c_stop then
      begin
        fstate:=c_destroy;
        resume;
        exit;
      end
      else
      begin
        if fstate=c_trystop then
        begin
          fstate:=c_trydestroy;
          exit;
        end;
      end;
      fstate:=c_TRYDESTROY;
    end;
  end;
end;

procedure cProcessAlgThread.InitCS;
begin
  InitializeCriticalSection(cs);
  InitializeCriticalSection(StartStopcs);
end;

procedure cProcessAlgThread.DeleteCS;
begin
  DeleteCriticalSection(cs);
  DeleteCriticalSection(StartStopcs);
end;

procedure cProcessAlgThread.EnterCS;
begin
   EnterCriticalSection(cs);
end;

procedure cProcessAlgThread.ExitCS;
begin
   LeaveCriticalSection(cs);
end;


constructor cTask.create;
begin
  inherited;
  thread:=cProcessAlgThread.create;
  thread.task:=self;
end;

destructor cTask.destroy;
begin
  //thread.Resume;
  //thread.terminate;
  Thread.eng.ThreadList.destroyobj(Thread.threadid);
  thread.Destroy;
  inherited;
end;

procedure cTask.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
var
  str:string;
  sensor:csensor;
begin
  inherited;
  if thread<>nil then
  begin
    str:=xmlNode.ReadAttributeString('TahoName');
    sensor:=csensor(cbldeng(cTaskMng(mng).eng).getobj(str));
    if sensor<>nil then
    begin
      thread.taho:=sensor;
    end;
    // �������������� ����� ������� (dT)
    thread.dT:=xmlNode.ReadAttributeFloat('dT');
    // ������� ����������
    thread.period:=xmlNode.ReadAttributeFloat('Period');
    thread.linc(ctaskmng(mng).eng);
  end;
end;

procedure cTask.SaveObjAttributes(xmlNode:txmlNode);
var
  str:string;
begin
  inherited;
  if thread.taho<>nil then
    str:=thread.taho.name
  else
    str:='';
  // ��� ���� �������
  xmlNode.WriteAttributeString('TahoName',str);
  // �������������� ����� ������� (dT)
  xmlNode.WriteAttributeFloat('dT',thread.dT);
  // ������� ����������
  xmlNode.WriteAttributeFloat('Period',thread.period);
end;




end.
