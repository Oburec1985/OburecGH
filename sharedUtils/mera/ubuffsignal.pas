unit uBuffSignal;

interface
uses
  uMeraSignal,
  uCommonTypes,
  //uBasicTrend, uTrend,
  uMyMath, sysutils;

type
  cBuffSignal = class(cSignal)
  protected
    fname:string;
    fx0:double;
  public
    m_1d:boolean;
    points1d:array of single;
    points2d:array of point2;
    d_points1d:array of double;
    d_points2d:array of point2d;
    i2_points1d:array of Int16;
    i2_points2d:array of point2i2;
  protected
    procedure setfreqX(v:single);override;
    procedure SetX0(x:double);override;
    function GetX0:double;override;
  public
    constructor create;override;
    function getname:string;override;
    procedure setname(s:string);override;
    function VType:integer;override;
    function Count:integer;override;

    function GetY(i:integer):single;overload; override;
    function GetY(t:single):single;overload; override;
    function GetX(i:integer):single;override;
    function SignalType:integer;override;
    function GetT0:single;override;
    function GetTEnd:single;override;
    function GetP2(i:integer):point2;override;
    procedure clear;override;
    procedure setcapacity(v:cardinal);override;
    function getCapacity:cardinal;override;
    function EvalEstimates:point2;override;
    procedure loadSignal(p_name:string);override;
    procedure AddPoints(var p:array of point2);overload;override;
    procedure AddPoints(var p:array of single);overload;override;
    procedure AddPoints(var p:array of double);overload;override;
    procedure AddPoints(var p: array of double; startind:integer;p_count: integer);overload;override;
    procedure SaveData(const f:file);override;
  end;


implementation


procedure cBuffSignal.clear;
begin
  capacity:=0;
end;

procedure cBuffSignal.SaveData(const f:file);
begin
  if m_1d then
  begin
    if datatype='r4' then
    begin
      BlockWrite(f, points1d[0], count*sizeof(single));
    end;
    if datatype='r8' then
    begin
      BlockWrite(f, d_points1d[0], count*sizeof(double));
    end;
  end;
end;

procedure cBuffSignal.AddPoints(var p:array of point2);
var
  I: Integer;
begin
  capacity:=length(p);
  // копируем данные
  move(p[0], points2d[0], sizeof(point2)*count);
end;

procedure cBuffSignal.AddPoints(var p:array of single);
var
  I: Integer;
begin
  capacity:=length(p);
  // копируем данные
  move(p[0], points1d[0], sizeof(single)*count);
end;

procedure cBuffSignal.AddPoints(var p: array of double);
var
  I: Integer;
begin
  capacity:=length(p);
  // копируем данные
  move(p[0], d_points1d[0], sizeof(double)*count);
end;

procedure cBuffSignal.AddPoints(var p: array of double; startind:integer;p_count: integer);
var
  I: Integer;
begin
  if p_count>length(p) then
    p_count:=length(p);
  capacity:=p_count;
  // копируем данные
  move(p[0], d_points1d[startind], sizeof(double)*p_count);
end;



function cBuffSignal.EvalEstimates:point2;
var
  I: Integer;
  min, max:single;
begin
  if m_1d then
  begin
    Min:=points1d[0];
    Max:=points1d[0];
    for I := 1 to count - 1 do
    begin
      if min>points1d[i] then
      begin
        min:=points1d[i];
      end
      else
      begin
        if max<points1d[i] then
        begin
          max:=points1d[i];
        end;
      end;
    end;
    result.x:=GetM(points1d);
    result.y:=Max-Min;
  end
  else
  begin
    Min:=points2d[0].y;
    Max:=points2d[0].y;
    for I := 1 to count - 1 do
    begin
      if min>points2d[i].y then
      begin
        min:=points2d[i].y;
      end
      else
      begin
        if max<points2d[i].y then
        begin
          max:=points2d[i].y;
        end;
      end;
    end;
    result.x:=GetM(points2d);
    result.y:=Max-Min;
  end;
end;


function cBuffSignal.Count:integer;
begin
  result:=capacity;
end;

function cBuffSignal.getname:string;
begin
  result:=fname;
end;

function cBuffSignal.SignalType:integer;
begin
end;

function cBuffSignal.GetT0:single;
begin
  if m_1d then
    result:=0
  else
    result:=points2d[0].x;
end;

function cBuffSignal.GetP2(i:integer):point2;
begin
  if m_1d then
    result:=p2(i/ffreqX+x0,points1d[i])
  else
    result:=points2d[i];
end;

function cBuffSignal.GetY(i:integer):single;
begin
  if m_1d then
  begin
    if datatype='r8' then
    begin
      result:=d_points1d[i]
    end;
    if datatype='r4' then
    begin
      result:=points1d[i]
    end;
    if datatype='i2' then
    begin
      result:=i2_points1d[i]*k1;
    end;
  end
  else
  begin
    if datatype='r8' then
    begin
      result:=d_points2d[i].y
    end;
    if datatype='r4' then
    begin
      result:=points2d[i].y
    end;
    if datatype='i2' then
    begin
      result:=i2_points2d[i].y*k1;
    end;
    result:=points2d[i].y;
  end;

end;

function cBuffSignal.GetY(t:single):single;
var
  right,left:integer;
  k:single;
  p1,p2,dt:single;
begin
  if m_1d then
  begin
    dt:=1/ffreqx;
    left:= trunc(t*ffreqx);
    right:=left+1;
    if right=count then
    begin
      result:=gety(left);
      exit;
    end;
    p2:=gety(right);
    p1:=gety(left);
    k:=(p2-p1)*freqx;
    result:=p1+k*(t-left*dt);
  end
  else
  begin
    dt:=1/ffreqx;
    left:= trunc(t*ffreqx);
    right:=left+1;
    if right=count then
    begin
      result:=gety(left);
      exit;
    end;
    p2:=gety(right);
    p1:=gety(left);
    k:=(p2-p1)*freqx;
    result:=p1+k*(t-left*dt);
  end;
end;

function cBuffSignal.GetX(i:integer):single;
begin
  if m_1d then
    result:=i/ffreqX+x0
  else
    result:=points2d[i].x+x0;
end;

function cBuffSignal.GetTEnd:single;
begin
  if m_1d then
    result:=count/freqx
  else
    result:=points2d[count-1].x;
end;

function cBuffSignal.VType:integer;
begin
  if datatype='r8' then
  begin
    result:=c_Double;
  end;
  if datatype='r4' then
  begin
    result:=c_float;
  end;
end;

function cBuffSignal.getcapacity:cardinal;
begin
  if m_1d then
  begin
    if datatype='r8' then
    begin
      result:=length(d_points1d)
    end;
    if datatype='r4' then
    begin
      result:=length(points1d);
    end;
    if datatype='i2' then
    begin
      result:=length(i2_points1d);
    end;
  end
  else
  begin
    if datatype='r8' then
    begin
      result:=length(d_points2d)
    end;
    if datatype='r4' then
    begin
      result:=length(points2d);
    end;
    if datatype='i2' then
    begin
      result:=length(i2_points2d);
    end;
  end;
end;

procedure cBuffSignal.setCapacity(v:cardinal);
begin
  if m_1d then
  begin
    if datatype='r8' then
    begin
      setlength(d_points1d,v);
    end;
    if datatype='r4' then
    begin
      setlength(points1d,v);
    end;
    if datatype='i2' then
    begin
      setlength(i2_points1d,v);
    end;
  end
  else
  begin
    if datatype='r8' then
    begin
      setlength(d_points2d,v);
    end;
    if datatype='r4' then
    begin
      setlength(points2d,v);
    end;
    if datatype='i2' then
    begin
      setlength(i2_points2d,v);
    end;
  end;
end;


procedure cBuffSignal.setname(s:string);
begin
  fname:=s;
end;

constructor cBuffSignal.create;
begin
  inherited;
  m_1d:=true;
  fname:='cBuffSignal';
end;

procedure cBuffSignal.loadSignal(p_name:string);
var
  fname:string;
  f:file;
  read:integer;
  fsize, datasize, len, j:cardinal;
  d:double;
begin
  fname:=p_name+'.dat';
  if fileexists(fname) then
  begin
    AssignFile(f,fname);
    Reset(f,1);
    fsize:=FileSize(f);
    if DataType='r8' then
      datasize:=8;
    if DataType='r4' then
      datasize:=4;
    if DataType='i2' then
      datasize:=2;
    len:=trunc(fsize/datasize);
    // если сигнал xy
    if fileexists(p_name+'.x') then
    begin
      m_1d:=false;
      WriteXY:=true;
      capacity:=len;
      AssignFile(f,fname);
      reset(f,1);
      for j := 0 to len - 1 do
      begin
        blockread(f, d, datasize, read);
        if datatype='r8' then
          d_points2d[j].y:=d;
        if datatype='r4' then
          points2d[j].y:=d;
      end;
      closefile(f);
      AssignFile(f,p_name+'.x');
      reset(f,1);
      for j := 0 to len - 1 do
      begin
        blockread(f, d, datasize, read);
        if datatype='r8' then
          d_points2d[j].x:=d;
        if datatype='r4' then
          points2d[j].x:=d;
      end;
      closefile(f);
    end
    else
    begin
      WriteXY:=false;
      m_1d:=true;
      capacity:=len;
      AssignFile(f,fname);
      reset(f,1);
      if datatype='r8' then
      begin
        blockread(f,d_points1d[0],datasize*len,read);
      end;
      if datatype='r4' then
      begin
        blockread(f,points1d[0],datasize*len,read);
      end;
      if datatype='i2' then
      begin
        blockread(f,i2_points1d[0],datasize*len,read);
      end;
      closefile(f);
    end;
  end;
end;

procedure cBuffSignal.setfreqX(v:single);
begin
  inherited;
end;

procedure cBuffSignal.SetX0(x:double);
begin
  fx0:=x;
end;

function cBuffSignal.GetX0:double;
begin
  result:=fx0;
end;


end.
