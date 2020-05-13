unit uMoveController;

interface
uses uNodeObject, umatrix, uquat, MathFunction, uvectorlist, uBaseModificator,
     utimecontroller, uCommonTypes;

type
  AxisAngel = record
    ax:point3;
    a:single;
  end;

  ckey = class
    state:axisangel;
    q:tquat;
    m:matrixgl;
    t:cardinal; // в тиках
    keytype:integer;
  public
    constructor create;virtual;
    function keyTypeString:string;
  end;

  cKeyList = class(cIntVectorlist)
  protected
    function GetStateM(t:cardinal):matrixgl;
    function GetStateQ(t:cardinal):tquat;
    function  GetKey(Index: Integer): ckey;
    function  GetLastKey: ckey;
    function  GetFirstKey: ckey;
  public
    function MaxTime:cardinal;
    procedure addkey(k:ckey);overload;
    procedure addkey(m:matrixgl;t:cardinal);overload;
    procedure addkey(quat:tquat;t:cardinal);overload;
    constructor create;
    destructor destroy;
    Property key[Index: Integer] : ckey read GetKey;
  end;

  cMoveController = class(cBaseModificator)
    timecntrl:ctimecontroller;
  public
    framecount:cardinal;
    tpf:cardinal;
    t:cardinal;// время последнего срабатывания
    // Tick per second
    tps:cardinal;
    // ключи анимации
    keys:cKeyList;
  protected
    // получить состояния кости в момент времени t (секунды)
    function GetStateM(t:single):matrixgl;virtual;
    function GetStateQ(t:single):tquat;virtual;
  public
    // расчет нового состояния для объекта
    procedure apply(t_:cardinal);overload;
    procedure apply(t_:single);overload;
  public
    constructor create(obj:tobject; timecntrl_:ctimecontroller);
    destructor destroy;virtual;
    procedure UpdateObj(sender:tobject);
  end;

implementation

constructor ckey.create;
begin
  keytype:=-1;
end;

function ckey.keyTypeString:string;
begin
  case keytype of
    0:;
  else
    result:='Простой';
  end;
end;

constructor cKeyList.create;
begin
  sorted:=true;
  destroydata:=true;
end;

destructor cKeyList.destroy;
begin
  inherited;
end;

function  cKeyList.GetKey(Index: Integer): ckey;
begin
  result:=ckey(getObj(index));
end;

procedure  cKeyList.AddKey(k:ckey);
begin
  AddObject(@k.t,k);
end;

procedure cKeyList.addkey(m:matrixgl;t:cardinal);
var key:ckey;
begin
  key:=ckey.create;
  key.m:=m;
  key.q:=matrixtoquat(m);
  key.t:=t;
  AddKey(key);
end;

procedure cKeyList.addkey(quat:tquat; t:cardinal);
var key:ckey;
begin
  key:=ckey.create;
  key.q:=quat;
  key.t:=t;
  AddKey(key);
end;

function  cKeyList.GetLastKey: ckey;
begin
  if count<>0 then
    result:=ckey(getkey(Count-1))
  else
    result:=nil;
end;

function  cKeyList.GetFirstKey: ckey;
begin
  if count<>0 then
    result:=ckey(getkey(0))
  else
    result:=nil;
end;

function cKeyList.GetStateM(t:cardinal):matrixgl;
var q:tquat;
    k1,k2:cKey;
    index:integer;
    dt:integer;
    t_:single;
begin
  k1:=ckey(getlow(@t,index));
  if k1=nil then
  begin
    result:=getkey(0).m;
    exit;
  end;
  if index=count-1 then
  begin
    result:=getkey(count-1).m;
    exit;
  end;
  k2:=ckey(getkey(index+1));
  dt:=k2.t - k1.t;
  t_:=(t-k1.t)/dt;
  q:=QuaternionSlerp(k1.q,k2.q,t_);
  result:=quattomatrix(q);
end;

function cKeyList.GetStateQ(t:cardinal):tquat;
var q:tquat;
    k1,k2:cKey;
    index:integer;
    dt:integer;
    t_:single;
begin
  k1:=ckey(getlow(@t,index));
  if k1=nil then
  begin
    result:=getkey(0).q;
    exit;
  end;
  if index=count-1 then
  begin
    result:=getkey(count-1).q;
    exit;
  end;
  k2:=ckey(getkey(index+1));
  dt:=k2.t - k1.t;
  t_:=(t-k1.t)/dt;
  q:=QuaternionSlerp(k1.q,k2.q,t_);
  result:=q;
end;

function ckeylist.MaxTime:cardinal;
begin
  result:=key[count-1].t;
end;

function cMoveController.GetStateQ(t:single):tquat;
var t_:cardinal;
begin
  t_:=trunc(t*tps);
  result:=keys.GetStateQ(t_);
end;

function cMoveController.GetStateM(t:single):matrixgl;
var t_:cardinal;
begin
  t_:=trunc(t*tps);
  result:=keys.GetStateM(t_);
end;

procedure cMoveController.apply(t_:cardinal);
begin
  cnodeobject(owner).nodetm:=keys.GetStateM(t_);
  t:=t_;
end;

procedure cMoveController.apply(t_:single);
begin
  cnodeobject(owner).nodetm:=GetStateM(t_);
  t:=trunc(t_*tps);
end;

procedure cMoveController.UpdateObj(sender:tobject);
begin
  apply(timecntrl.ticks);
end;

constructor cMoveController.create(obj:tobject;timecntrl_:cTimeController);
begin
  owner:=obj;
  timecntrl:=timecntrl_;
  timecntrl_.TimeEvents.AddEvent('cMoveController updateObj'+cnodeobject(obj).name,
                                 ChangeTimeEvent,UpdateObj);
  keys:=ckeylist.create;
end;

destructor cMoveController.destroy;
begin
  timecntrl.TimeEvents.removeEvent(UpdateObj,0);
  keys.destroy;
  inherited;
end;

end.
