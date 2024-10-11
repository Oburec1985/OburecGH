unit uTimeController;

interface
uses
  uNodeObject, umatrix, uquat, MathFunction, uvectorlist, uBaseModificator,
  ueventlist
  ,uTickMath
  , classes;

type
// класс дл€ управлени€ временем. ќн вызывает все движение объектов движка,
// но не имеет собственного таймера (потока)
ctimeController = class
  TimeEvents:ceventlist;
protected
  ftime:cardinal;
  ftps, // число тиков в секунду (tpf/fps)
  ffps, // число кадров в секунду
  framecount, // число кадров
  tpf:cardinal; // число тиков в кадре
  maxseconds:cardinal; // максимальное число секунд в счетчике с учетом tps
  fmaxTime:cardinal;
protected
  procedure getmaxsec;
protected
  // в милисекундах
  procedure settime(t:cardinal);overload;
  procedure settime(t:single);overload;
  procedure setticks(t:cardinal);
  procedure settps(t:cardinal);
  procedure setfps(t:cardinal);
  // в милисекундах
  function gettime:cardinal;
  procedure setmaxtime(t:cardinal);
public
  procedure init(l_tpf,l_fps:cardinal);
  constructor create;
  destructor destroy;
  // вызов всех событий времени контролов движени€
  procedure apply;
public
  // при изменении мен€етс€ tpf (tickperframe)
  property tps:cardinal read ftps write settps;
  // при изменении мен€етс€ tpf (tickperframe)
  property fps:cardinal read ffps write setfps;
  property time:cardinal read gettime write settime;
  property ticks:cardinal read ftime write setticks;
  property maxtime:cardinal read fmaxtime write setmaxtime;
end;

const
  ChangeTimeEvent = $000001;
  ChangeOptsEvent = $000002;

implementation

constructor cTimeController.create;
begin
  ffps:=30;
  ftps:=1;
  TimeEvents:=ceventlist.create(self,true);
end;

procedure cTimeController.setmaxtime(t:cardinal);
begin
  fmaxtime:=t;
  timeevents.CallAllEvents(ChangeOptsEvent);
end;

procedure cTimeController.init(l_tpf,l_fps:cardinal);
begin
  tpf:=l_tpf;
  ffps:=l_fps;
  ftps:=tpf*ffps;
end;

destructor cTimeController.destroy;
begin
  TimeEvents.destroy;
end;

procedure cTimeController.settime(t:single);
begin
  if t>maxseconds then
    t:=t-maxseconds;
  ftime:=trunc(t*ftps);
end;

procedure cTimeController.settime(t:cardinal);
begin
  setticks(trunc(tps*t/1000));
  apply;
end;

procedure cTimeController.setticks(t:cardinal);
begin
  if t>maxtime then
  begin
    ftime:=t-maxtime;
  end
  else
    ftime:=t;
  apply;
end;

function cTimeController.gettime:cardinal;
begin
  result:=trunc(ftime*1000/tps);
end;

procedure cTimeController.settps(t:cardinal);
begin
  ftps:=t;
  tpf:=trunc(ftps/ffps);
  getMaxSec;
end;

procedure cTimeController.setfps(t:cardinal);
begin
  ffps:=trunc(tpf/tps);
  getMaxSec;
end;

procedure cTimeController.getmaxsec;
begin
  maxseconds:=trunc(MaxCardinalValue/tps);
end;

procedure cTimeController.apply;
begin
  TimeEvents.CallAllEvents(ChangeTimeEvent);
end;

end.
