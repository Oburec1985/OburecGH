// класс служит дл€ дополнени€ оконной процедуры вне движка
// cFrameListener - класс имеющий виртуальную функцию котора€ вызываетс€ из оконной
// процедуры движка. ѕереопредел€€ функцию в потомках можно реализовать спе -
// цифический интерфейс пользовател€
unit uglFrameListener;

interface
uses
  messages, classes, windows, u3dTypes, usetlist
  //,uObjectTypes
   ;

type
  cglFrameList = class;

  cglFrameListener = class
  protected
    prevControlFrame:cglFrameListener;
    name:string;
    ui:tobject;
    flockmouse:boolean;
  public
    frList:cglFrameList;
    // хранит список залоченых интерфейсных фреймов
    locklist:array of integer;
    active:boolean;
    // ключ сортировки 0 - наивысший приоритет
    prioritet:integer;
  protected
    procedure setprioritet(p:integer);
    procedure SetLockMouse(b:boolean);
    function GetLockMouse:boolean;
    procedure notify(etype:cardinal);virtual;
  public
    Constructor create(p_ui:tobject;pname:string);virtual;
    procedure WndProc(msg:tmessage; mouse:mousestruct);virtual;abstract;
  public
    property prior:integer read prioritet write setprioritet;
    property LockMouse:boolean read getLockMouse write setLockMouse;
  end;

  cglFrameList = class(tStringlist)
  private
    ui:tobject;
    ControlFrame:cglFrameListener;
    factive:boolean;
  protected
    sortPriorList:csetlist;
  public
    procedure setactive(b:boolean);
    constructor create(p_ui:tobject);
    destructor destroy;
    function GetFrame(i:integer):cglframelistener;overload;
    function GetFrame(name:string):cglframelistener;overload;
    procedure add(frame:cglFramelistener);
    procedure deleteObj(i:integer);overload;
    procedure deleteObj(name:string);overload;
    procedure deleteObj(frame:cglFramelistener);overload;
    // нотификаци€ дл€ событий наподобие инициализации
    procedure Notify(eType:integer);
    procedure wndproc(msg:tmessage; mouse:mousestruct);
    function GetFramePrior(i:integer):cglframelistener;
  public
    property active:boolean read factive write setactive;
  end;

const
  // происходит при инициализации фреймов
  c_initFrames = $0000001;
  // происходит при выборе объекта
  c_SelObject = $0000002;

implementation

Constructor cglFrameListener.create(p_ui:tobject;pname:string);
begin
  ui:=p_ui;
  name:=pname;
  active:=true;
end;


procedure cglFrameListener.setprioritet(p:integer);
begin
  if frList<>nil then
  begin
    frList.sortPriorList.RemoveObj(self);
    prioritet:=p;
    frList.sortPriorList.AddObj(self);
  end;
  prioritet:=p;
end;

function KeyComparator(p1,p2:pointer):integer;
begin
  if cglFrameListener(p1).prioritet>cglFrameListener(p2).prioritet then
  begin
    result:=1;
  end
  else
  begin
    if cglFrameListener(p1).prioritet<cglFrameListener(p2).prioritet then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

constructor cglFrameList.create(p_ui:tobject);
begin
  ui:=p_ui;
  sorted:=true;
  active:=true;

  sortPriorList:=cSetList.create;
  sortPriorList.destroydata:=false;
  sortPriorList.comparator:=KeyComparator;
end;

destructor cglFrameList.destroy;
var i:integer;
begin
  while count<>0 do
  begin
    deleteObj(0);
  end;
  sortPriorList.destroy;
  inherited;
end;


procedure cglFrameList.add(frame:cglFramelistener);
begin
  addobject(frame.name,frame);
  frame.frList:=self;
  frame.prioritet:=sortPriorList.Count;
  sortPriorList.Add(frame);
end;

procedure cglFrameList.deleteObj(i:integer);
var
  fr:cglframelistener;
begin
  fr:=cglframelistener(getobject(i));
  delete(i);
  sortPriorList.RemoveObj(fr);
  fr.destroy;
end;

procedure cglFrameList.deleteObj(name:string);
var index:integer;
    fr:cglframelistener;
begin
  if find(name,index) then
  begin
    fr:=cglframelistener(getobject(index));
    delete(index);
    sortPriorList.RemoveObj(fr);
    fr.destroy;
  end;
end;

procedure cglFrameList.deleteObj(frame:cglFramelistener);
begin
  deleteObj(frame.name);
end;

function cglFrameList.GetFrame(i:integer):cglframelistener;
begin
  result:=nil;
  if i<count then
    result:=cglframelistener(getobject(i));
end;

procedure cglFrameList.setactive(b:boolean);
begin
  factive:=b;
end;


function cglFrameList.GetFrame(name:string):cglframelistener;
var i:integer;
begin
  result:=nil;
  if find(name,i) then
    result:=cglframelistener(getobject(i));
end;

function cglFrameList.GetFramePrior(i:integer):cglframelistener;
begin
  result:=nil;
  if i<count then
    result:=cglframelistener(sortPriorList.Items[i]);
end;


procedure cglFrameList.wndproc(msg:tmessage; mouse:mousestruct);
var i:integer;
    frame:cglframelistener;
begin
  if active then
  begin
    for I := 0 to count - 1 do
    begin
      if ControlFrame<>nil then
      begin
        ControlFrame.WndProc(msg,mouse);
        break;
      end
      else
      begin
        frame:=GetFramePrior(i);
        if frame.Active then
          frame.WndProc(msg,mouse);
      end;
    end;
  end;
end;


procedure cglFrameList.Notify(eType:integer);
var i:integer;
    frame:cglframelistener;
begin
  for I := 0 to count - 1 do
  begin
    frame:=GetFramePrior(i);
    frame.notify(eType);
  end;
End;


procedure cglframelistener.SetLockMouse(b:boolean);
var
  i:integer;
  f:cglFrameListener;
begin
  setlength(locklist,frList.Count);
  if b then
  begin
    prevControlFrame:=frList.ControlFrame;
    frList.ControlFrame:=self;
  end
  else
  begin
    if prevControlFrame<>self then
    begin
      frList.ControlFrame:=prevControlFrame;
    end
    else
    begin
      frList.ControlFrame:=nil;
      prevControlFrame:=nil;
    end;
    prevControlFrame:=nil;
  end;
  flockmouse:=b;
  {if b then
  begin
    for i:=0 to frList.Count-1 do
    begin
      f:=frList.GetFrame(i);
      if f<>self then
      begin
        if f.active then
        begin

        end;
      end;
    end;
  end;}
end;

function cglframelistener.GetLockMouse:boolean;
begin
  result:=flockmouse;
end;

procedure cglFrameListener.notify(etype: cardinal);
begin

end;

end.
