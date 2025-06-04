unit uMeraSignal;

interface
uses
  uCommonTypes, ubinfile;

type
  tSignalPrt = record
    i:cardinal;
    t:double;
  end;

  cSignal = class
  protected
    // частота
    ffreqX:single;
  public
    fname:string;
    // обект с данными
    obj:tobject;
    // опции Mera файла
    // множитель ГХ
    k1:single;
    // постоянная составляющая. Y =(code*k1-k0)
    k0:single;
    WriteXY:boolean;
    xUnits, yUnits, zUnits:string;
    b_3d:boolean;
    dZ,
    portionsize:integer;
    DataType:string;
    dsc:string;
    prt:array of tSignalPrt;
  protected
    procedure setfreqX(v:single);virtual;
  public
    function VType:integer;virtual; abstract;
    function GetT0:single;virtual; abstract;
    function SignalType:integer;virtual; abstract;
    function Count:integer;virtual; abstract;
    function GetP2(i:integer):point2;virtual; abstract;

    function GetX0:double;virtual; abstract;
    procedure SetX0(x:double);virtual; abstract;

    function GetY(i:integer):single;overload; virtual; abstract;
    function GetY(t:single):single;overload; virtual; abstract;
    function GetX(i:integer):single;virtual; abstract;

    function GetP2d(i:integer):point2d;virtual;abstract;
    function GetYd(i:integer):double;overload;virtual;abstract;
    function GetYd(t:double):double;overload;virtual;abstract;
    function GetXd(i:integer):double;virtual;abstract;

    function GetTEnd:single;virtual; abstract;

    procedure setcapacity(v:cardinal);virtual; abstract;
    function getCapacity:cardinal;virtual; abstract;


    procedure AddPoints(var p:array of point2);overload;virtual;abstract;
    procedure AddPoints(var p:array of single);overload;virtual;abstract;
    procedure AddPoints(var p:array of double);overload;virtual;abstract;
    procedure AddPoints(var p:array of double; startind:integer; count:integer);overload;virtual;abstract;
    procedure clear;virtual;abstract;
    constructor create;virtual;
    // (мат ожидание, размах)
    function EvalEstimates:point2;virtual;abstract;

    function getname:string;virtual;
    procedure setname(s:string);virtual;
    procedure loadSignal(p_name:string);virtual; abstract;
    procedure SaveData(const f:file);virtual;
  public
    property freqx:single read ffreqx write setfreqX;
    property name:string read getName write setName;
    property x0:double read getx0 write setx0;
    property capacity:cardinal read getcapacity write setcapacity;
  end;

  function SignalFormatToDataSize(format:string):integer;

  const
    c_Float = 1;
    c_Double = 2;

implementation


constructor cSignal.create;
begin
  k1:=1;
  k0:=0;
end;

procedure cSignal.setfreqX(v:single);
begin
  ffreqx:=v;
end;

procedure cSignal.setname(s: string);
begin
  fname:=s;
end;

function cSignal.getname: string;
begin
  result:=fname;
end;

procedure cSignal.SaveData(const f:file);
var
  x,endT,y, dt:double;
begin
  dt:=1/freqX;
  x:=GetP2(0).x;
  endT:=GetTEnd;
  // пишем y сигнала
  while x<endT do
  begin
    y:=GetY(x);
    if VType=c_float then
      WriteSingle(f,y);
    if VType=c_Double then
      WriteDouble(f,y);
    x:=x+dt;
  end;
end;

function SignalFormatToDataSize(format:string):integer;
begin
  result:=-1;
  if format='r8' then
    result:=8;
  if format='r4' then
    result:=4;
  if format='i2' then
    result:=2;
end;

end.
