unit uTaskMng;

interface

uses
  ubldmath, classes, ubldEngEventTypes, uAlgMng,
  uCommonMath, ExtCtrls, ubaseobj, uEventTypes, usensor,
  NativeXML, uProcessAlgTask, uBaseObjMng, uBldEng;

type
  cTaskMng = class(cBaseObjMng)
  public
    eng:cbldeng;
    alglist:cBaseObjMng;
    factivetask:cTask;
  protected
  protected
    procedure regObjClasses;override;
    procedure XMLSaveMngAttributes(node:txmlnode);override;
    procedure XMLlOADMngAttributes(node:txmlnode);override;
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    procedure CreateEvents;
    procedure destroyEvents;
    procedure ChangeCfg(sender:tobject);
    procedure ChangeAlgsCfg(sender:tobject);
  protected
    function getactivetask:ctask;
    function getTask(i:integer):ctask;
  public
    // true ���� ��� ������ � ��������� c_destroy
    function Stoped:boolean;
    constructor create;override;
    // ����� ������ ��� �������� ���� �� ������ �������� ����� ���� �� ������������� ������
    destructor destroy;override;
    Function CreateObjByType(Classname:string):cbaseobj;override;
    procedure linc(p_eng:cbldeng);
  public
    property activetask:ctask read getactivetask write factivetask;
  end;


implementation
uses
  uBldTimeProc, uBaseBldAlg;

constructor cTaskMng.create;

begin
  inherited;
  objects.destroydata:=true;
end;

destructor cTaskMng.destroy;
begin
  destroyEvents;
  inherited;
end;

procedure cTaskMng.AddBaseObjInstance(obj:cbaseobj);
begin
  inherited;
  eng.ThreadList.AddID(ctask(obj).name,ctask(obj).Thread.ThreadID);
end;

procedure cTaskMng.regObjClasses;
begin
  inherited;
  regclass(ctask);
end;

Function cTaskMng.CreateObjByType(Classname:string):cbaseobj;
begin
  result:=inherited CreateObjByType(Classname);
end;

procedure cTaskMng.XMLSaveMngAttributes(node:txmlnode);
begin
  inherited;
end;

procedure cTaskMng.XMLlOADMngAttributes(node:txmlnode);
begin
  inherited;
end;

procedure cTaskMng.linc(p_eng:cbldeng);
begin
  eng:=p_eng;
  alglist:=cbldtimeproc(eng.timeProc).algList;
  CreateEvents;
end;

function cTaskMng.getactivetask:ctask;
begin
  result:=nil;
  if factivetask=nil then
  begin
    if count<>0 then
    begin
      factivetask:=ctask(getobj(0));
    end;
  end;
  result:=factivetask;
end;

function cTaskMng.getTask(i:integer):ctask;
begin
  result:=ctask(getobj(i));
end;

procedure cTaskMng.CreateEvents;
begin
  if eng<>nil then
  begin
    eng.Events.AddEvent('cTaskMng_OnChangeCfg',E_OnDestroyObject,ChangeCfg);
    alglist.Events.AddEvent('cTaskMng_OnChangeAlgsList',E_OnDestroyObject,ChangeAlgsCfg);
  end;
end;

procedure cTaskMng.destroyEvents;
begin
  if eng<>nil then
  begin
    eng.Events.removeEvent(ChangeCfg,E_OnDestroyObject);
  end;
  if alglist<>nil then
  begin
    alglist.Events.removeEvent(ChangeAlgsCfg,E_OnDestroyObject);
  end;
end;

procedure cTaskMng.ChangeAlgsCfg(sender:tobject);
var
  I: Integer;
  alg:cBaseBldAlg;
  t:ctask;
begin
  for I := 0 to Count - 1 do
  begin
    if sender is cBaseBldAlg then
    begin
      t:=gettask(i);
      alg:=t.Thread.Getalg(cBaseBldAlg(sender).name);
      if alg=sender then
        t.Thread.removeAlg(alg);
    end;
  end;
end;

procedure cTaskMng.ChangeCfg(sender:tobject);
var
  I: Integer;
  t:ctask;
begin
  for I := 0 to Count - 1 do
  begin
    if sender is csensor then
    begin
      t:=gettask(i);
      if t.Thread.taho=sender then
        t.Thread.taho:=nil;
    end;
  end;
end;

function cTaskMng.Stoped:boolean;
var
  I: Integer;
  t:ctask;
begin
  result:=true;
  for I := 0 to Count - 1 do
  begin
    t:=gettask(i);
    if t.Thread.state<>uprocessalgtask.c_destroy then
    begin
      result:=false;
      exit;
    end;
  end;
end;

end.
