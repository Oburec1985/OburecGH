unit uAlarms;

interface
uses
  controls, stdctrls, classes, sysutils, uEventList, uEventTypes, uBaseObj,
  uCommonMath, uVectorList, forms,
  uLogFile, dialogs, uBaseObjMng;

type
  cAlarm = class;

  cAlarmMng = class(cBaseObjMng)
  protected
    // Созхранять в SQL БД
    SaveSql:boolean;
  protected
  public
    constructor create;override;
    destructor destroy;override;
    procedure linc(tp:tobject);
    function createalarm:cAlarm;
    function getAlarm(i:integer):calarm;overload;
    function getAlarm(name:string):calarm;overload;
  end;

  cAlarmsList = class(cfloatvectorlist)
  public
  public
    constructor create;override;
    procedure AddAlarm(a:calarm);
    function GetAlarm(i:integer):calarm;overload;
    // получаем аларм слева от v
    function GetAlarm(v:single):calarm;overload;
    function inAlarm:boolean;
  end;

  cAlarm = class(cBaseObj)
  protected
    fEnabled:boolean;
    // уставка
    fthreshold:single;
    fgisterezis:single;
    fPercentGisterezis:integer;
  public
    // значение которое изменило аларм
    tagvalue:single;
    OnTime, OffTime:tDateTime;
    // источник данных который проверяется на alarm
    source:cbaseobj;  
    // процедура вызываемая при проверке аларма
    onCheckValue:tNotifyEvent;
    dsc:string;
    // Если true то аларм ограничивает тег справа, иначе слева
    LoAlarm:boolean;
  protected
    procedure LincSource(p_source:cbaseobj);
    // вызывается при взводе аларма
    procedure OnTrigAlarm;
    // вызывается при сбросе аларма
    procedure OffTrigAlarm;
    procedure setEnabled(b:boolean);
    // установка гистерезиса взвода аларма в процентах
    procedure setGisterezis(percent:integer);
    procedure setThreshold(v:single);
    procedure setMng(m:cAlarmMng);
    function getMng:cAlarmMng;
  public
    procedure SetTime(t:tdatetime);
    procedure SetOnTime(t:tdatetime);
    procedure SetOffTime(t:tdatetime);
    function CheckValue(v:single):boolean;
    function typestring:string;override;
  public
    property alarmMng:cAlarmMng read getMng write setMng;
    property enabled:boolean read fEnabled write setEnabled;
    property threshold:single read fthreshold write setThreshold;
    property Gisterezis:integer read fPercentGisterezis write setGisterezis;
    constructor create;override;
    destructor destroy;override;
  end;

implementation

procedure cAlarmMng.linc(tp:tobject);
begin
  //tproc:=tp;
end;

constructor cAlarmMng.create;
begin
  inherited;
  savesql:=true;
end;

destructor cAlarmMng.destroy;
begin
  inherited;
end;


function cAlarmMng.createalarm:cAlarm;
var
  al:calarm;
begin
  al:=calarm.create;
  Add(al);
  result:=al;
end;

function cAlarmMng.getAlarm(i:integer):calarm;
begin
  result:=calarm(getobj(i));
end;

function cAlarmMng.getAlarm(name:string):calarm;
begin
  result:=calarm(getobj(name));
end;

procedure cAlarm.SetTime(t:tdatetime);
begin
  if enabled then
    setOntime(t)
  else
    setOffTime(t);
end;

procedure cAlarm.SetOnTime(t:tdatetime);
begin
  OnTime:=t;
  OffTime:=0;
end;

procedure cAlarm.SetOffTime(t:tdatetime);
begin
  OffTime:=t;
end;

procedure cAlarm.setMng(m:cAlarmMng);
begin
  setMng(m);
end;

function cAlarm.getMng:cAlarmMng;
begin
  result:=cAlarmMng(inherited getmng);
end;

procedure cAlarm.LincSource(p_source:cbaseobj);
begin
  source:=p_source;
end;

constructor cAlarm.create;
begin
  Inherited;
  fgisterezis:=0;
  fPercentGisterezis:=0;
end;

destructor cAlarm.destroy;
begin
  inherited;
end;

function cAlarm.typestring:string;
begin
  if LoAlarm then
    result:='Lo Аларм'
  else
    result:='Hi Аларм';
end;

procedure cAlarm.setGisterezis(percent:integer);
begin
  fPercentGisterezis:=percent;
  fgisterezis:=fthreshold*percent/100;
end;

procedure cAlarm.setThreshold(v:single);
begin
  fthreshold:=v;
  setGisterezis(fPercentGisterezis);
end;

function cAlarm.CheckValue(v:single):boolean;
begin
  if not LoAlarm then
  begin
    if threshold<=v then
    begin
      if not enabled then
        tagvalue:=v;
      enabled:=true;
    end
    else
    begin
      // выключаем аларм с учетом гистерезиса
      if (threshold-fgisterezis>=v) then
      begin
        tagvalue:=v;
        enabled:=false;
      end;
    end;
  end
  else
  begin
    if threshold>=v then
    begin
      if not enabled then
        tagvalue:=v;
      enabled:=true;
    end
    else
    begin
      // выключаем аларм с учетом гистерезиса
      if (threshold+fgisterezis<=v) then
      begin
        if enabled then
          tagvalue:=v;
        enabled:=false;
      end;
    end;
  end;
  result:=enabled;
end;

procedure cAlarm.OnTrigAlarm;
begin

end;

procedure cAlarm.OffTrigAlarm;
begin

end;

procedure cAlarm.setEnabled(b:boolean);
begin
  if b<>fEnabled then
  begin
    if b then
    begin
      OnTrigAlarm;
    end
    else
    begin
      OffTrigAlarm;
    end;
    fEnabled:=b;
    //alarmMng.events.CallAllEventsWithSender(e_OnChangeAlarm,self);
  end;
end;


procedure cAlarmsList.AddAlarm(a:calarm);
begin
  addObject(@a.threshold,a);
end;

function cAlarmsList.GetAlarm(i:integer):calarm;
begin
  result:=calarm(getobj(i));
end;

function cAlarmsList.GetAlarm(v:single):calarm;
var
  index:integer;
begin
  result:=calarm(GetLow(@v, index));
end;

constructor cAlarmsList.create;
begin
  inherited;
  destroydata:=false;
end;

function cAlarmsList.inAlarm:boolean;
var
  I: Integer;
  a:calarm;
begin
  result:=false;
  for I := 0 to Count - 1 do
  begin
    a:=GetAlarm(i);
    if a.enabled then
    begin
      result:=true;
      exit;
    end;
  end;
end;



end.
