unit uTag;

interface

uses
  sysutils, udrawobj, classes, uBaseObj, uBaseObjMng, uPoint, uCommonTypes,
  uMyMath, uVectorList, uEventList, windows, uEventTypes,
  NativeXML, uGlobalStrings, uCommonMath;

type
  cBaseTag = class(cBaseObj)
  protected
    // алгоритм котоорый создал тег
    fsource: tobject;
    // объект в который отрисуетс€ тег
    fdrawobj: cdrawobj;
    // активен
    factive: boolean;
    // описание
    fdsc: string;
    // критическа€ секци€ защиты данных
    cs: TRTLCriticalSection;
    f: file;
  public
    offset: single;
    alarms: cFloatVectorList;
    OnSetDrawObj: tNotifyevent;
    OnSetActive: tNotifyevent;
    // строка идентификатор тега внутри алгоритма. равна
    // имени присваиваемому в первый момент
    id: string;
    // дополнительный параметрю например при загрузке из xml
    // сохран€ет линкуемый отрисовываемый объект
    opts: string;
    // включить/ выключить запись данных
    fLogData: boolean;
  protected
    procedure setname(name: string); override;
    function getLen: integer; virtual;
    procedure SetLen(i: integer); virtual;
    Procedure setDrawObj(obj: cdrawobj); virtual;
    procedure setactive(b: boolean); virtual;
    procedure setDsc(str: string);
    function getDsc: string;
    // проверить текущее значение тега
    function CheckAlarm: boolean; virtual;
    Procedure OnAlarm;
    procedure SaveData; virtual;
    procedure OpenFile(fname: string); virtual;
    procedure CloseTagFile; virtual;
    function getLogData: boolean;
    // процедуры
  public
    property LogData: boolean read getLogData write fLogData;
    procedure UpdateDrawObj;
    // ѕришли новые данные
    procedure UpdateValue;
    function AlarmCount: integer;
    procedure addalarm(a: cBaseObj);
    Function TypeString: String; override;
    Procedure setSource(src: tobject); virtual;
    constructor create; override;
    destructor destroy; override;
    // свойства
  public
    property source: tobject read fsource write setSource;
    property dsc: string read fdsc write setDsc;
    property active: boolean read factive write setactive;
    property DrawObj: cdrawobj read fdrawobj write setDrawObj;
    property length: integer read getLen write SetLen;
  end;

  cBaseScalarTag = class(cBaseTag)

  end;

  cScalarTag = class(cBaseScalarTag)
  protected
    fValue: single;
  protected
    function getValue: single;
    procedure SetValue(v: single);
    // проверить текущее значение тега
    function CheckAlarm: boolean; override;
    procedure SaveData; override;
  public
    Function TypeString: String; override;
  public
    property Value: single read getValue write SetValue;
  end;

  c2ScalarTag = class(cBaseScalarTag)
  protected
    fValue: point2;
    fx: file;
  protected
    function getValue: point2;
    procedure SetValue(v: point2);
    function CheckAlarm: boolean; override;
    procedure SaveData; override;
    procedure OpenFile(fname: string); override;
    procedure CloseTagFile; override;
  public
    Function TypeString: String; override;
  public
    property Value: point2 read getValue write SetValue;
  end;

  cArrayTag = class(cBaseTag)
  public
    // число проинициализированных точек
    used: integer;
    initMinMax: boolean;
  protected
    function getCapacity: cardinal; virtual; abstract;
    procedure setCapacity(i: cardinal); virtual; abstract;
    constructor create; override;
    procedure updateUseditems;
  public
    // очистить буфер
    property capacity: cardinal read getCapacity write setCapacity;
    procedure clear; virtual;
  end;

  cVectorTag = class(cArrayTag)
  public
    dx: single;
    fValue: array of single;
    MinMax: point2;
    fx0: single;
  protected
    function getValue(i: integer): single; overload;
    procedure SetValue(index: integer; v: single);
    function getLen: integer; override;
    procedure SetLen(i: integer); override;
    function CheckAlarm: boolean; override;
    function getCapacity: cardinal; override;
    procedure setCapacity(i: cardinal); override;
    procedure SaveData; override;
  public
    function getValue(t: single): single; overload;
    Function TypeString: String; override;
    procedure Add(v: single); overload;
    procedure Add(var v: array of single); overload;
    Function M: single;
    Function D: single;
  public
    procedure clear; override;
    destructor destroy; override;
    constructor create; override;
    property Value[index: integer]: single read getValue write SetValue;
  end;

  cdVectorTag = class(cArrayTag)
  public
    dx: double;
    fValue: array of double;
    MinMax: point2d;
    fx0: double;
  protected
    procedure SaveData; override;
    function getValue(i: integer): double; overload;
    procedure SetValue(index: integer; v: double);
    function getLen: integer; override;
    function getCapacity: cardinal; override;
    procedure setCapacity(i: cardinal); override;
  public
    function getValue(t: double): double; overload;
    Function TypeString: String; override;
    procedure Add(v: double); overload;
    procedure Add(var v: array of double); overload;
    Function M: double;
    Function D: double;
  public
    procedure clear; override;
    destructor destroy; override;
    constructor create; override;
    property Value[index: integer]: double read getValue write SetValue;
  end;

  c2VectorTag = class(cArrayTag)
  public
    fValue: array of point2;
    XMinMax: point2;
    YMinMax: point2;
  protected
    fx: file;
  protected
    procedure SaveData; override;
    procedure OpenFile(fname: string); override;
    procedure CloseTagFile; override;
    function getValue(i: integer): point2;
    procedure SetValue(index: integer; v: point2);
    function getLen: integer; override;
    procedure SetLen(i: integer); override;
    function CheckAlarm: boolean; override;
    function getCapacity: cardinal; override;
    procedure setCapacity(i: cardinal); override;
  public
    procedure SetX(i: integer; x: single);
    procedure SetY(i: integer; y: single);
  public
    // корректно работает только если массив данных отсортирован по X
    function getY(x: single): single;
    Function TypeString: String; override;
    procedure Add(v: point2);
    function M: single;
    Function D: single;
    function Count: integer;
    procedure addpoints(var ar: array of point2; Count: integer);
  public
    property Value[index: integer]: point2 read getValue write SetValue;
    property length: integer read getLen write SetLen;
  end;

  c2dVectorTag = class(cArrayTag)
  public
    fValue: array of point2d;
    XMinMax: point2d;
    YMinMax: point2d;
  protected
    fx: file;
  protected
    procedure OpenFile(fname: string); override;
    procedure CloseTagFile; override;
    procedure SaveData; override;
    function getValue(i: integer): point2d;
    procedure SetValue(index: integer; v: point2d);
    function getLen: integer; override;
    procedure SetLen(i: integer); override;
    function CheckAlarm: boolean; override;
    function getCapacity: cardinal; override;
    procedure setCapacity(i: cardinal); override;
  public
    procedure SetX(i: integer; x: double);
    procedure SetY(i: integer; y: double);
  public
    // корректно работает только если массив данных отсортирован по X
    function getY(x: double): double;
    Function TypeString: String; override;
    procedure Add(v: point2d);
    function M: double;
    Function D: double;
    function Count: integer;
  public
    property Value[index: integer]: point2d read getValue write SetValue;
    property length: integer read getLen write SetLen;
  end;

  cTagMng = class(cBaseObjMng)
  public
    // путь к хранилищу данных по тегам
    TagsFolder: string;
    // включить/выключить запись
    logtags: boolean;
  protected
    procedure AddBaseObjInstance(obj: cBaseObj); override;
    procedure XMLSaveMngAttributes(node: txmlnode); override;
    procedure XMLlOADMngAttributes(node: txmlnode); override;
  private
  public
    constructor create; override;
    destructor destroy; override;
    // открыть замер
    procedure OpenRecord(path: string);
    function gettag(i: integer): cBaseTag; overload;
    function gettag(name: string): cBaseTag; overload;
    function createTag(id: integer): cBaseTag;
    procedure AddToXML(fname: string; sectionName: string); override;
    function LoadFromXML(fname: string; sectionName: string): boolean; override;
  end;

const
  // идетификаторы типов тегов
  c_ScalarTag = 1;
  c_VectorTag = 2;

implementation

uses
  uTagUtils, uAlarms;

constructor cBaseTag.create;
begin
  inherited;
  alarms := calarmslist.create;
  DrawObj := nil;
end;

destructor cBaseTag.destroy;
begin
  alarms.destroy;
  inherited;
end;

procedure cBaseTag.setname(name: string);
begin
  inherited;
  if id = '' then
    id := name;
end;

procedure cBaseTag.addalarm(a: cBaseObj);
begin
  if a <> nil then
  begin
    calarmslist(alarms).addalarm(calarm(a));
    calarm(a).source := self;
  end;
end;

function cBaseTag.CheckAlarm: boolean;
begin
  result := false;
end;

Procedure cBaseTag.OnAlarm;
var
  e: ceventlist;
  a: calarm;
begin
  a := calarmslist(alarms).getAlarm(0);
  e := a.alarmMng.Events;
  e.CallAllEventsWithSender(e_OnTagAlarm, self);
end;

procedure cBaseTag.SaveData;
begin

end;

procedure cBaseTag.OpenFile(fname: string);
begin
  assignfile(f, fname);
  rewrite(f, 1);
end;

procedure cBaseTag.CloseTagFile;
begin
  closefile(f);
end;

function cBaseTag.getLogData: boolean;
begin
  result := fLogData;
end;

procedure cBaseTag.UpdateValue;
begin
  CheckAlarm;
  if LogData then
  begin
    SaveData;
  end;
end;

function cBaseTag.AlarmCount: integer;
begin
  result := alarms.Count;
end;

procedure cBaseTag.setDsc(str: string);
begin
  fdsc := str;
end;

function cBaseTag.getDsc: string;
begin
  result := fdsc;
end;

procedure cBaseTag.UpdateDrawObj;
begin
  if fdrawobj <> nil then
    TagToDrawObj(fdrawobj, self, nil);
end;

Procedure cBaseTag.setSource(src: tobject);
begin
  fsource := src;
end;

Procedure cBaseTag.setDrawObj(obj: cdrawobj);
begin
  fdrawobj := obj;
  if assigned(OnSetDrawObj) then
    OnSetDrawObj(obj);
end;

function cBaseTag.getLen: integer;
begin
  result := 1;
end;

procedure cBaseTag.SetLen(i: integer);
begin
end;

procedure cBaseTag.setactive(b: boolean);
begin
  if factive <> b then
  begin
    factive := b;
    if assigned(OnSetActive) then
      OnSetActive(self);
  end;
end;

Function cBaseTag.TypeString: String;
begin
  result := v_BaseTagDsc;
end;

function cScalarTag.getValue: single;
begin
  result := fValue;
end;

procedure cScalarTag.SaveData;
var
  i: integer;
begin
  BlockWrite(f, fValue, sizeof(fValue), i);
end;

procedure cScalarTag.SetValue(v: single);
begin
  fValue := v;
end;

function cScalarTag.CheckAlarm: boolean;
var
  a: calarm;
  i: integer;
  b: boolean;
begin
  result := false;
  if alarms.Count = 0 then
    exit;
  // проходим по всем алармам и взводим их
  for i := 0 to alarms.Count - 1 do
  begin
    a := calarm(alarms.getObj(i));
    b := a.checkValue(Value);
    if b then
      result := b;
  end;
  if b then
    OnAlarm;
end;

Function c2ScalarTag.TypeString: String;
begin
  result := v_2ScalarTAgDSCf;
end;

procedure c2ScalarTag.SaveData;
var
  i: integer;
begin
  BlockWrite(f, fValue.y, sizeof(fValue), i);
  BlockWrite(fx, fValue.x, sizeof(fValue), i);
end;

procedure c2ScalarTag.OpenFile(fname: string);
var
  str: string;
begin
  inherited;
  str := TrimExt(fname);
  assignfile(fx, str + '.x');
  rewrite(fx, 1);
end;

procedure c2ScalarTag.closeTagfile;
begin
  inherited;
  closefile(fx);
end;

function c2ScalarTag.CheckAlarm: boolean;
var
  a: calarm;
  i: integer;
  b: boolean;
begin
  result := false;
  if alarms.Count = 0 then
    exit;
  // проходим по всем алармам и взводим их
  for i := 0 to alarms.Count - 1 do
  begin
    a := calarm(alarms.getObj(i));
    b := a.checkValue(Value.y);
    if b then
      result := b;
  end;
  if b then
    OnAlarm;
end;

function c2ScalarTag.getValue: point2;
begin
  result := fValue;
end;

procedure c2ScalarTag.SetValue(v: point2);
begin
  fValue := v;
end;

Function cScalarTag.TypeString: String;
begin
  result := v_ScalarTAgDSCf;
end;

constructor cArrayTag.create;
begin
  inherited;
  clear;
end;

procedure cArrayTag.clear;
begin
  used := 0;
  initMinMax := false;
end;

procedure cArrayTag.updateUseditems;
begin
  inc(used);
end;

procedure cVectorTag.clear;
begin
  inherited;
end;

constructor cVectorTag.create;
begin
  inherited;
end;

destructor cVectorTag.destroy;
begin
  inherited;
end;

function cVectorTag.getValue(i: integer): single;
begin
  result := fValue[i];
end;

function cVectorTag.getValue(t: single): single;
var
  i: integer;
  k: single;
  p1x: single;
begin
  i := trunc(t / dx);
  p1x := i * dx;
  k := (fValue[i + 1] - fValue[i]) / dx;
  result := fValue[i] + k * (t - p1x);
end;

procedure cVectorTag.SaveData;
var
  i: integer;
begin
  BlockWrite(f, fValue, system.length(fValue) * sizeof(single), i);
end;

procedure cVectorTag.SetValue(index: integer; v: single);
begin
  if index > used then
    used := index;
  fValue[index] := v;
  if initMinMax then
  begin
    if v < MinMax.x then
    begin
      MinMax.x := v
    end
    else
    begin
      if v > MinMax.y then
        MinMax.y := v;
    end;
  end
  else
  begin
    initMinMax := true;
    MinMax := p2(v, v);
  end;
end;

function cVectorTag.CheckAlarm: boolean;
var
  a: calarm;
  i: integer;
  b: boolean;
begin
  result := false;
  if alarms.Count = 0 then
    exit;
  // проходим по всем алармам и взводим их
  for i := 0 to alarms.Count - 1 do
  begin
    a := calarm(alarms.getObj(i));
    if a.loAlarm then
      b := a.checkValue(MinMax.x)
    else
      b := a.checkValue(MinMax.y);
    if b then
      result := b;
  end;
  if b then
    OnAlarm;
end;

function cVectorTag.getCapacity: cardinal;
begin
  result := system.length(fValue);
end;

procedure cVectorTag.setCapacity(i: cardinal);
begin
  setlength(fValue, i);
end;

function cVectorTag.getLen: integer;
begin
  result := system.length(fValue);
end;

Function cVectorTag.M: single;
begin
  result := GetM(fValue);
end;

Function cVectorTag.D: single;
begin
  result := getdisp(fValue);
end;

procedure cVectorTag.SetLen(i: integer);
begin
  if i >= 0 then
    setlength(fValue, i);
end;

Function cVectorTag.TypeString: String;
begin
  result := v_VectorTagDscf;
end;

procedure cVectorTag.Add(v: single);
begin
  Value[used] := v;
  updateUseditems;
end;

procedure cVectorTag.Add(var v: array of single);
var
  l: integer;
begin

end;

constructor cdVectorTag.create;
begin
  inherited;
end;

destructor cdVectorTag.destroy;
begin
  inherited;
end;

function cdVectorTag.getValue(i: integer): double;
begin
  result := fValue[i];
end;

procedure cdVectorTag.SaveData;
var
  i: integer;
begin
  BlockWrite(f, fValue, system.length(fValue) * sizeof(double), i);
end;

function cdVectorTag.getValue(t: double): double;
var
  i: integer;
  k: single;
  p1x: double;
begin
  i := trunc(t / dx);
  p1x := i * dx;
  k := (fValue[i + 1] - fValue[i]) / dx;
  result := fValue[i] + k * (t - p1x);
end;

procedure cdVectorTag.SetValue(index: integer; v: double);
begin
  if index > used then
    used := index;
  fValue[index] := v;
  if initMinMax then
  begin
    if v < MinMax.x then
    begin
      MinMax.x := v
    end
    else
    begin
      if v > MinMax.y then
        MinMax.y := v;
    end;
  end
  else
  begin
    initMinMax := true;
    MinMax := p2d(v, v);
  end;
end;

function cdVectorTag.getLen: integer;
begin
  result := used;
end;

function cdVectorTag.getCapacity: cardinal;
begin
  result := system.length(fValue);
end;

procedure cdVectorTag.setCapacity(i: cardinal);
begin
  setlength(fValue, i);
end;

Function cdVectorTag.M: double;
begin
  result := GetMd(fValue);
end;

Function cdVectorTag.D: double;
begin
  result := GetDispd(fValue);
end;

Function cdVectorTag.TypeString: String;
begin
  result := 'VectorTagDscf';
end;

procedure cdVectorTag.Add(v: double);
begin
  Value[used] := v;
  updateUseditems;
end;

procedure cdVectorTag.Add(var v: array of double);
var
  Count: integer;
begin
  Count := system.length(v);
  if Count > capacity then
  begin
    capacity := Count;
  end;
  move(v[0], fValue[0], Count * sizeof(double));
  used := Count;
end;

procedure cdVectorTag.clear;
begin
  inherited;
  capacity := 0;
end;

procedure c2VectorTag.addpoints(var ar: array of point2; Count: integer);
var
  p1, p2: pointer;
begin
  p1 := @ar[0];
  p2 := @fValue[0];
  move(p1, p2, Count);
end;

function c2VectorTag.CheckAlarm: boolean;
var
  a: calarm;
  i: integer;
  b: boolean;
begin
  result := false;
  if alarms.Count = 0 then
    exit;
  // проходим по всем алармам и взводим их
  for i := 0 to alarms.Count - 1 do
  begin
    a := calarm(alarms.getObj(i));
    if a.loAlarm then
      b := a.checkValue(YMinMax.x)
    else
      b := a.checkValue(YMinMax.y);
    if b then
      result := b;
  end;
  if b then
    OnAlarm;
end;

procedure c2VectorTag.OpenFile(fname: string);
var
  str: string;
begin
  inherited;
  str := TrimExt(fname);
  assignfile(fx, str + '.x');
  rewrite(fx, 1);
end;

procedure c2VectorTag.closeTagfile;
begin
  inherited;
  closefile(fx);
end;

procedure c2VectorTag.SaveData;
var
  i: integer;
begin
  BlockWrite(f, fValue, system.length(fValue) * sizeof(single), i);
  BlockWrite(fx, fValue, system.length(fValue) * sizeof(single), i);
end;

function c2VectorTag.getValue(i: integer): point2;
begin
  result := fValue[i];
end;

procedure c2VectorTag.SetValue(index: integer; v: point2);
begin
  if index > used then
    used := index;
  fValue[index] := v;
  if initMinMax then
  begin
    if v.x < XMinMax.x then
    begin
      XMinMax.x := v.x
    end
    else
    begin
      if v.x > XMinMax.y then
        XMinMax.y := v.x;
    end;
    if v.y < YMinMax.x then
    begin
      YMinMax.x := v.y
    end
    else
    begin
      if v.y > YMinMax.y then
        YMinMax.y := v.y;
    end;
  end
  else
  begin
    initMinMax := true;
    XMinMax := p2(v.x, v.x);
    YMinMax := p2(v.y, v.y);
  end;
end;

procedure c2VectorTag.SetX(i: integer; x: single);
begin
  fValue[i].x := x;
end;

procedure c2VectorTag.SetY(i: integer; y: single);
begin
  fValue[i].y := y;
end;

Function c2VectorTag.M: single;
begin
  result := GetM(fValue);
end;

Function c2VectorTag.D: single;
begin
  result := getdisp(fValue);
end;

function c2VectorTag.getLen: integer;
begin
  result := system.length(fValue);
end;

procedure c2VectorTag.SetLen(i: integer);
begin
  if i >= 0 then
    setlength(fValue, i);
end;

Function c2VectorTag.TypeString: String;
begin
  result := v_2VectorTagDsc;
end;

procedure c2VectorTag.Add(v: point2);
begin
  if used >= length then
    exit;
  Value[used] := v;
  updateUseditems;
end;

function c2VectorTag.getY(x: single): single;
var
  right, left: integer;
  k: single;
  p1, p2: point2;
begin
  right := FindInPointsArrayHiBound(fValue, x, 0, used);
  if right = 0 then
  begin
    result := fValue[0].y;
    exit;
  end;
  left := FindInPointsArrayLowbound(fValue, x, 0, used);
  if left = length - 1 then
  begin
    result := fValue[length - 1].y;
    exit;
  end;
  p2 := fValue[right];
  p1 := fValue[left];
  k := (p2.y - p1.y) / (p2.x - p1.x);
  result := p1.y + k * (x - p1.x);
end;

function c2VectorTag.getCapacity: cardinal;
begin
  result := system.length(fValue);
end;

procedure c2VectorTag.setCapacity(i: cardinal);
begin
  setlength(fValue, i);
end;

function c2VectorTag.Count: integer;
begin
  result := used;
end;

function c2dVectorTag.CheckAlarm: boolean;
var
  a: calarm;
  i: integer;
  b: boolean;
begin
  result := false;
  if alarms.Count = 0 then
    exit;
  // проходим по всем алармам и взводим их
  for i := 0 to alarms.Count - 1 do
  begin
    a := calarm(alarms.getObj(i));
    if a.loAlarm then
      b := a.checkValue(YMinMax.x)
    else
      b := a.checkValue(YMinMax.y);
    if b then
      result := b;
  end;
  if b then
    OnAlarm;
end;

procedure c2dVectorTag.OpenFile(fname: string);
var
  str: string;
begin
  inherited;
  str := TrimExt(fname);
  assignfile(fx, str + '.x');
  rewrite(fx, 1);
end;

procedure c2dVectorTag.closeTagfile;
begin
  inherited;
  closefile(fx);
end;

procedure c2dVectorTag.SaveData;
var
  i: integer;
begin
  BlockWrite(f, fValue, system.length(fValue) * sizeof(double), i);
  BlockWrite(fx, fValue, system.length(fValue) * sizeof(double), i);
end;

function c2dVectorTag.getValue(i: integer): point2d;
begin
  result := fValue[i];
end;

procedure c2dVectorTag.SetValue(index: integer; v: point2d);
begin
  if index > used then
    used := index;
  fValue[index] := v;
  if initMinMax then
  begin
    if v.x < XMinMax.x then
    begin
      XMinMax.x := v.x
    end
    else
    begin
      if v.x > XMinMax.y then
        XMinMax.y := v.x;
    end;
    if v.y < YMinMax.x then
    begin
      YMinMax.x := v.y
    end
    else
    begin
      if v.y > YMinMax.y then
        YMinMax.y := v.y;
    end;
  end
  else
  begin
    initMinMax := true;
    XMinMax := p2d(v.x, v.x);
    YMinMax := p2d(v.y, v.y);
  end;
end;

procedure c2dVectorTag.SetX(i: integer; x: double);
begin
  fValue[i].x := x;
end;

procedure c2dVectorTag.SetY(i: integer; y: double);
begin
  fValue[i].y := y;
end;

Function c2dVectorTag.M: double;
begin
  result := GetMd(fValue);
end;

Function c2dVectorTag.D: double;
begin
  result := GetDispd(fValue);
end;

function c2dVectorTag.getLen: integer;
begin
  result := system.length(fValue);
end;

procedure c2dVectorTag.SetLen(i: integer);
begin
  if i >= 0 then
    setlength(fValue, i);
end;

Function c2dVectorTag.TypeString: String;
begin
  result := v_2VectorTagDsc;
end;

procedure c2dVectorTag.Add(v: point2d);
begin
  if used >= length then
    exit;
  Value[used] := v;
  updateUseditems;
end;

function c2dVectorTag.getY(x: double): double;
var
  right, left: integer;
  k: double;
  p1, p2: point2d;
begin
  right := FindInDPointsArrayHiBound(fValue, x, 0, used);
  if right = 0 then
  begin
    result := fValue[0].y;
    exit;
  end;
  left := FindInDPointsArrayLowbound(fValue, x, 0, used);
  if left = length - 1 then
  begin
    result := fValue[length - 1].y;
    exit;
  end;
  p2 := fValue[right];
  p1 := fValue[left];
  k := (p2.y - p1.y) / (p2.x - p1.x);
  result := p1.y + k * (x - p1.x);
end;

function c2dVectorTag.getCapacity: cardinal;
begin
  result := system.length(fValue);
end;

procedure c2dVectorTag.setCapacity(i: cardinal);
begin
  setlength(fValue, i);
end;

function c2dVectorTag.Count: integer;
begin
  result := used;
end;

constructor cTagMng.create;
begin
  inherited;
end;

destructor cTagMng.destroy;
begin
  inherited;
end;

procedure cTagMng.AddBaseObjInstance(obj: cBaseObj);
begin
  if obj is cBaseTag then
    inherited;
end;

function cTagMng.createTag(id: integer): cBaseTag;
var
  tag: cBaseTag;
begin
  case id of
    c_ScalarTag:
      tag := cScalarTag.create;
    c_VectorTag:
      tag := cVectorTag.create;
  end;
  Add(tag, nil);
  result := tag;
end;

function cTagMng.gettag(i: integer): cBaseTag;
begin
  result := cBaseTag(getObj(i));
end;

function cTagMng.gettag(name: string): cBaseTag;
begin
  result := cBaseTag(getObj(name));
end;

procedure cTagMng.XMLSaveMngAttributes(node: txmlnode);
begin
  // им€ тахо датчика
  node.WriteAttributeString('TagsFolder', TagsFolder);
  node.WriteAttributeBool('LogTags', logtags);
end;

procedure cTagMng.XMLlOADMngAttributes(node: txmlnode);
begin
  if node <> nil then
  begin
    TagsFolder := node.ReadAttributeString('TagsFolder');
    logtags := node.ReadAttributeBool('LogTags');
  end;
end;

procedure cTagMng.AddToXML(fname: string; sectionName: string);
var
  doc: TNativeXml;
  node: txmlnode;
  i: integer;
  obj: cBaseObj;
begin
  doc := TNativeXml.create(nil);
  doc.LoadFromFile(fname);
  node := doc.Root;
  node := node.NodeNew(sectionName);
  XMLSaveMngAttributes(node);
  doc.XmlFormat := xfReadable;
  doc.SaveToFile(fname);
  doc.destroy;
end;

function cTagMng.LoadFromXML(fname: string; sectionName: string): boolean;
var
  doc: TNativeXml;
  node: txmlnode;
  i: integer;
  obj: cBaseObj;
begin
  doc := TNativeXml.create(nil);
  doc.LoadFromFile(fname);
  node := doc.Root.FindNode(sectionName);
  XMLlOADMngAttributes(node);
  doc.destroy;
end;

procedure cTagMng.OpenRecord(path: string);
var
  I: Integer;
  tag:cbasetag;
  tagname:string;
begin
  for I := 0 to Count - 1 do
  begin
    tag:=gettag(i);
    if tag.LogData then
    begin
      if path[length(path)]<>'\' then
      begin
        path:=path+'\';
        tagname:=replaseChars(tag.name,'\/;@%:#+-*,"','_');
        tag.OpenFile(path+tagname+'.dat');
      end;
    end;
  end;
end;

end.
