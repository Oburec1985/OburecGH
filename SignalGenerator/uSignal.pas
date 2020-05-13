unit uSignal;

interface
uses
  uBaseObj, uBaseObjStr, uBaseObjMng, uTrend, uCommonTypes, inifiles, classes,
  sysutils, uMyMath;

type
  cScale = class(cBaseObjStr)

  end;

  cSignal = class(cBaseObjStr)
  private
    // частота дискретизации
    m_fs, m_dx:single;
  public
    dsc, xUnits, yUnits:string;
    x0,
    m, r, Min, Max:single;
    points:array of single;
  protected
    function getSignallength:integer;
    procedure setSignalLength(l:integer);
    procedure setFs(v:single);
    procedure setdX(v:single);
  public
    procedure EvalEstimates;
    function getTimelength:single;
    function GetY(t:single):single;
    Procedure CopyToTrend(trend:ctrend);
    constructor create;override;
  public
    property fs:single read m_fs write setFs;
    property dx:single read m_dx write setdX;
    property SignalLength:integer read getSignallength write setSignalLength;
  end;

  cSignalsMng = class(cBaseObjMng)
  protected
    procedure regObjClasses;override;
    procedure AddBaseObjInstance(obj:cbaseobj);override;
  public
    constructor create;override;
    Function CreateObjByType(Classname:string):cbaseobj;override;
    function getsignal(i:integer):csignal;overload;
    function getsignal(name:string):csignal;overload;
  end;


implementation

constructor cSignal.create;
begin
  inherited;
  x0:=0;
end;

function cSignal.getSignallength:integer;
begin
  result:=length(points);
end;

procedure cSignal.setSignalLength(l:integer);
begin
  setlength(points,l);
end;

function cSignal.getTimelength:single;
begin
  result:=length(points)*(1/fs);
end;

Procedure cSignal.CopyToTrend(trend:ctrend);
var
  i:integer;
begin
  for i := 0 to Signallength - 1 do
  begin
    trend.addpoint(p2(i*dx+x0,points[i]));
  end;
end;

constructor cSignalsMng.create;
begin
  inherited;
end;

procedure cSignalsMng.regObjClasses;
begin
  inherited;
end;

Function cSignalsMng.CreateObjByType(Classname:string):cbaseobj;
begin
  result:=inherited CreateObjByType(Classname);
end;

procedure cSignalsMng.AddBaseObjInstance(obj:cbaseobj);
begin
  if obj is cSignal then
    inherited;
end;

function cSignalsMng.getsignal(i:integer):csignal;
begin
  result:=csignal(getobj(i));
end;

function cSignalsMng.getsignal(name:string):csignal;
begin
  result:=csignal(getobj(name));
end;

procedure cSignal.EvalEstimates;
var
  I: Integer;
begin
  Min:=points[0];
  Max:=points[0];
  for I := 1 to SignalLength - 1 do
  begin
    if min>points[i] then
    begin
      min:=points[i];
    end
    else
    begin
      if max<points[i] then
      begin
        max:=points[i];
      end;
    end;
  end;
  m:=GetM(points);
  r:=Max-Min;
end;

function cSignal.GetY(t:single):single;
var
  i:integer;
  t1,y1,y2, dt:single;
begin
  i:=trunc(t/dt);
  y1:=points[i];
  t1:=t*dt;
  if i<SignalLength then
  begin
    y2:=points[i+1];
    result:=(y2-y1)/dt;
    result:=result*(t-t1);
  end
  else
    result:=y1;
end;

procedure cSignal.setFs(v:single);
begin
  m_fs:=v;
  m_dx:=1/v;
end;

procedure cSignal.setdX(v:single);
begin
  m_dx:=v;
  m_fs:=1/v;
end;

end.
