unit uEventList;

interface
uses
  Windows, Messages, SysUtils, Classes, StdCtrls, Controls, ExtCtrls, uCommonMath,
  dialogs, usetlist;

const
  E_AllEvents = $0000;


type
  tsorttype = (st_namesort,st_TypeSort,st_None);
  EventProcedure = procedure(sender:tobject) of object;

  cEvent = class
  public
    active:boolean;
    name:string;
    dsc:string;
    EventType:cardinal; // ������������� �������
    action:EventProcedure;
  public
    constructor create;
  end;

  cEventList = class(cSetList)
  public
    active:boolean;
    fEventListChange:tNotifyEvent;
  private
    owner:tobject;
    // ���� ��������, �� ����� ���������� ���� � �����, ���� ���, �� ����� ������ ������
    // ������������ ��� ������ ������� (�.�. flag = opt)
    UseMask:boolean;
    fsorttype:tsorttype;
  protected
    procedure setSortType(sorttype:tsorttype);
    procedure setcomparator;
    procedure deletechild(node:pointer);override;
    procedure DoOnChange;
  public
    // ������������� ������. Owner - ������ ������� ���������� � �������
    constructor create(aOwner:tobject;pusemask:boolean);
    // ����� ���������� ����������� ���� ��������� �������
    destructor destroy;
    function GetEvent(i:integer):cEvent;overload;
    function GetEvent(name:string):cEvent;overload;
    // �������� ������� �� �����
    function GetProcByEventName(name:string):EventProcedure;
    // �������� � ������ ����� �������. Name - ��������������� ������;
    // p_action - ��������� �� ��������� ������� ����� ���������� �� �������
    // eventType - ��� �������
    function AddEvent(name:string;eventType:cardinal;p_action:eventprocedure):cevent;
    // ������� ������� �� ������ �� �����, �������� ���� ����� � �������
    // ��������� �������. ����� ���������� �������� ������ ������� (cUInterface)
    procedure callEvent(index:integer);
    // ����� ���� ������� ���� eventtype
    procedure CallAllEvents(eventtype:cardinal);
    procedure CallAllEventsWithSender(eventtype:cardinal;sender:tobject);
    // ������� �������� ������ �������
    procedure removeEvent(p_action:eventprocedure;etype:cardinal);overload;
    procedure RemoveEvent(p_action:eventprocedure;etype:cardinal;owner:tobject);overload;    
  public
    property sorttype:tsorttype read fsorttype write setsorttype;
  end;

implementation

function TypeComparator(p1,p2:pointer):integer;
begin
  if cevent(p1).EventType>cevent(p2).EventType then
    result:=1
  else
  begin
    if cevent(p1).EventType<cevent(p2).EventType then
      result:=-1
    else
      result:=0;
  end;
end;

function StringComparator(p1,p2:pointer):integer;
begin
  result:=AnsiCompareStr(cevent(p1).name,cevent(p1).name);
end;

constructor cEventList.create(aOwner:tobject;pusemask:boolean);
begin
  inherited create;
  active:=true;
  owner:=aOwner;
  //sorttype:=st_namesort;
  //sorttype:=st_none;
  sorttype:=st_TypeSort;
  usemask:=pusemask;
end;

destructor cEventList.destroy;
begin
  inherited destroy;
end;

procedure cEventList.RemoveEvent(p_action:eventprocedure;etype:cardinal;owner:tobject);
var i:integer;
    e:cevent;
    obj:tobject;
begin
  for I := 0 to Count - 1 do
  begin
    e:=getevent(i);
    // ���� ��� � ����� �������
    if (e.EventType=etype) and (@e.action=@p_action) then
    begin
      // ���� ��������
      //Caption := TObject(ppointer(integer(@@OnCreate) + 4)^).ClassName;
      obj:=tMethod(e.action).data;
      if owner<>nil then
      begin
        if owner<>obj then
          continue;
      end;
      e.Destroy;
      Delete(i);
      DoOnChange;
      exit;
    end;
  end;
end;

procedure cEventList.removeEvent(p_action:eventprocedure;etype:cardinal);
begin
  RemoveEvent(p_action,etype,nil);
end;

function cEventList.GetProcByEventName(name:string):EventProcedure;
var
    e:cevent;
begin
  result:=nil;
  e:=getevent(name);
  if e<>nil then
    result:=e.action;
end;

function cEventList.AddEvent(name:string;eventType:cardinal;p_action:eventprocedure):cEvent;
var e:cevent;
begin
  e:=cevent.Create;
  e.name:=name;
  e.action:=p_action;
  e.EventType:=eventtype;
  if getevent(name)<>nil then
    e.name:=name+'_';
  AddObj(e);
  DoOnChange;
  result:=e;
end;

procedure cEventList.DoOnChange;
begin
  if active then
  begin
    if assigned(fEventListChange) then
      fEventListChange(self);
  end;
end;

procedure cEventList.callEvent(index: Integer);
var
  e:cevent;
begin
  e:=getevent(index);
  if e.active then
    e.action(owner);
end;

procedure cEventList.CallAllEvents(eventtype:cardinal);
var i,starti,c:integer;
    e:cevent;
    call:boolean;
begin
  if not active then exit;
  c:=count;
  if fsorttype=st_TypeSort then
  begin
    e:=cEvent.Create;
    e.EventType:=eventtype;
    // ���� ������ ������ � ����� ������
    starti:=FindFirstNode(e);
    e.Destroy;
  end
  else
  begin
    starti:=0;
  end;
  if starti<>-1 then
  begin
    for I := starti to c - 1 do
    begin
      e:=getevent(i);
      if eventtype<>E_AllEvents then
      begin
        if usemask then
          call:=checkflag(e.EventType,eventtype)
        else
          call:=e.EventType=eventtype;
      end
      else
        call:=true;
      if call then
      begin
        if e.active then
        begin
          e.action(owner);
        end;
      end;
    end;
  end;
end;

procedure cEventList.CallAllEventsWithSender(eventtype:cardinal;sender:tobject);
var i:integer;
    e:cevent;
    call:boolean;
begin
  if not active then exit;
  if fsorttype=st_TypeSort then
  begin
    e:=cEvent.Create;
    e.EventType:=eventtype;
    FindFirstNode(e);
    e.Destroy;
  end
  else
  begin
  end;
  for I := 0 to count - 1 do
  begin
    e:=GetEvent(i);
    if e=nil then
      continue;
    if usemask then
      call:=checkflag(e.EventType,eventtype)
    else
      call:=e.EventType=eventtype;
    if call then
    begin
      if e.active then
        e.action(sender);
    end;
  end;
end;

function cEventList.GetEvent(i:integer):cEvent;
begin
  result:=nil;
  if i<count then
  begin
    result:=cevent(getnode(i));
  end;
end;

function cEventList.GetEvent(name:string):cEvent;
var
  I: Integer;
  e:cevent;
begin
  result:=nil;
  for I := 0 to Count - 1 do
  begin
    e:=getevent(i);
    if e.name=name then
    begin
      result:=e;
      exit;
    end;
  end;
end;

procedure cEventList.setSortType(sorttype:tsorttype);
begin
  fsorttype:=sorttype;
  if sorttype=st_none then
  begin
    fsorted:=false;
  end
  else
  begin
    fsorted:=true;
  end;
  setcomparator;
  SortChildrens;
end;

procedure cEventList.setcomparator;
begin
  if sorttype=st_namesort then
  begin
    comparator:=StringComparator
  end
  else
  begin
    if sorttype=st_TypeSort then
      comparator:=TypeComparator;
  end;
end;

procedure cEventList.deletechild(node:pointer);
begin
  cevent(node).Destroy;
  DoOnChange;
end;

{ cEvent }


{ cEvent }

constructor cEvent.create;
begin
  active:=true;
end;

end.
