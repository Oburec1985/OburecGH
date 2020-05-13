// класс служит дл€ дополнени€ оконной процедуры вне движка
// cFrameListener - класс имеющий виртуальную функцию котора€ вызываетс€ из оконной
// процедуры движка. ѕереопредел€€ функцию в потомках можно реализовать спе -
// цифический интерфейс пользовател€
unit uFrameListener;

interface
uses
  messages, classes, windows, uCommonTypes, uCommonMath, uSetList;

type
  cFrameList = class;

  cFrameListener = class
  protected
    name:string;
    data:tobject;
    settings:cardinal;
    factive:boolean;
    frList:cFrameList;
    // ключ сортировки
    prioritet:integer;
  protected
    procedure init(p_data:tobject; p_name:string);virtual;
    procedure setactive(b:boolean);virtual;
    procedure SetLockMouse(b:boolean);
    function GetLockMouse:boolean;
    procedure setprioritet(p:integer);
  public
  public
    Constructor create(p_data:tobject;pname:string);overload;
    Constructor create(p_data:tobject);overload;
    procedure WndProc(var msg:tmessage;var mouse:smousestruct);virtual;abstract;
    procedure setflags(flag:cardinal);
    function getflag(flag:cardinal):boolean;
    property active:boolean read factive write setactive;
    property LockMouse:boolean read getLockMouse write setLockMouse;
    property prior:integer read prioritet write setprioritet;
  end;

  cFrameList = class(tStringlist)
  public
    // главный фрейм который блокирует все остальные
    ControlFrame:cFrameListener;
  protected
    sortPriorList:csetlist;
  private
    data:tobject;
    factive:boolean;
  protected
    procedure setactive(b:boolean);
  public
    constructor create(p_data:tobject);
    destructor destroy;
    function GetFrame(i:integer):cframelistener;overload;
    function GetFramePrior(i:integer):cframelistener;overload;
    function GetFrame(name:string):cframelistener;overload;
    procedure add(frame:cFramelistener);
    procedure EnableAll(b:boolean);
    procedure deleteObj(i:integer);overload;
    procedure deleteObj(name:string);overload;
    procedure deleteObj(frame:cFramelistener);overload;
    procedure wndproc(msg:tmessage;var mouse:smousestruct);
  public
    property active:boolean read factive write setactive;
  end;

const
  c_blockAllWM = $00000001;
  c_blockWMLMouseBtnDawn = $00000002;
  c_blockWMLMouseBtnUp = $00000004;
  c_blockWMMouse = $00000008;

implementation

procedure cFrameListener.init(p_data:tobject; p_name:string);
begin
  data:=p_data;
  name:=p_name;
  active:=true;
end;

procedure cFrameListener.setprioritet(p:integer);
begin
  if frList<>nil then
  begin
    frList.sortPriorList.RemoveObj(self);
    prioritet:=p;
    frList.sortPriorList.AddObj(self);
  end;
  prioritet:=p;
end;

Constructor cFrameListener.create(p_data:tobject;pname:string);
begin
  init(p_data, pname);
  prioritet:=-1;
end;

Constructor cFrameListener.create(p_data:tobject);
begin
  init(p_data, classname);
  settings:=0;
  prioritet:=-1;
end;

function KeyComparator(p1,p2:pointer):integer;
begin
  if cFrameListener(p1).prioritet>cFrameListener(p2).prioritet then
  begin
    result:=1;
  end
  else
  begin
    if cFrameListener(p1).prioritet<cFrameListener(p2).prioritet then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;


constructor cFrameList.create(p_data:tobject);
begin
  data:=p_data;
  sorted:=true;
  active:=true;
  sortPriorList:=cSetList.create;
  sortPriorList.destroydata:=false;
  sortPriorList.comparator:=KeyComparator;
end;

destructor cFrameList.destroy;
var i:integer;
begin
  while count<>0 do
  begin
    deleteObj(0);
  end;
  sortPriorList.destroy;
  inherited;
end;

procedure cFrameList.add(frame:cFramelistener);
begin
  addobject(frame.name,frame);
  frame.frList:=self;
  frame.prioritet:=sortPriorList.Count;
  sortPriorList.Add(frame);
end;

procedure cFrameList.deleteObj(i:integer);
var fr:cframelistener;
begin
  fr:=cframelistener(getobject(i));
  delete(i);
  sortPriorList.RemoveObj(fr);
  fr.destroy;
end;

procedure cFrameList.deleteObj(name:string);
var index:integer;
    fr:cframelistener;
begin
  if find(name,index) then
  begin
    fr:=cframelistener(getobject(index));
    delete(index);
    sortPriorList.RemoveObj(fr);
    fr.destroy;
  end;
end;

procedure cFrameList.deleteObj(frame:cFramelistener);
begin
  deleteObj(frame.name);
end;

function cFrameList.GetFrame(i:integer):cframelistener;
begin
  result:=nil;
  if i<count then
    result:=cframelistener(getobject(i));
end;

function cFrameList.GetFramePrior(i:integer):cframelistener;
begin
  result:=nil;
  if i<count then
    result:=cframelistener(sortPriorList.Items[i]);
end;

function cFrameList.GetFrame(name:string):cframelistener;
var i:integer;
begin
  result:=nil;
  if find(name,i) then
    result:=cframelistener(getobject(i));
end;

procedure cFrameList.EnableAll(b:boolean);
var
  I: Integer;
  fr:cframelistener;
begin
  for I := 0 to Count - 1 do
  begin
    fr:=getframe(i);
    fr.active:=b;
  end;
end;


procedure cFrameList.wndproc(msg:tmessage;var mouse:smousestruct);
var i:integer;
    frame:cframelistener;
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

procedure cFrameList.setactive(b:boolean);
begin
  factive:=b;
end;

procedure cFrameListener.setflags(flag:cardinal);
begin
  setflag(settings, flag);
end;

function cFrameListener.getflag(flag:cardinal):boolean;
begin
  result:=checkflag(settings, flag);
end;

procedure cFrameListener.setactive(b:boolean);
begin
  factive:=b;
end;

procedure cFrameListener.SetLockMouse(b:boolean);
begin
  if b then
    frList.ControlFrame:=self
  else
    frList.ControlFrame:=nil;
end;

function cFrameListener.GetLockMouse:boolean;
begin
  result:=frList.ControlFrame=self;
end;


end.
