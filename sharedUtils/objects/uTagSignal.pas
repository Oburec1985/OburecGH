unit uTagSignal;

interface
uses
  uMeraSignal, uTag, uCommonTypes;

type
  cTagSignal = class(cSignal)
  protected
    procedure setfreqX(v:single);override;
    function GetX0:double;override;
    procedure SetX0(x:double);override;
  public
    function VType:integer;override;
    function Count:integer;override;
    function GetY(i:integer):single;overload; override;
    function GetY(t:single):single;overload; override;
    function GetX(i:integer):single;override;
    function GetP2d(i:integer):point2d;override;
    function GetYd(i:integer):double;overload; override;
    function GetYd(t:double):double;overload; override;
    function GetXd(i:integer):double;override;
    function getname:string;override;
    procedure setname(s:string);override;
    function SignalType:integer;override;
    function GetT0:single;override;
    function GetTEnd:single;override;
    function GetP2(i:integer):point2;override;
    procedure AddPoints(var p:array of point2);override;
    procedure AddPoints(var p:array of single);override;
    procedure AddPoints(var p:array of double);override;
    procedure loadSignal(p_name:string);override;
    procedure clear;override;
  end;

implementation

function cTagSignal.Count:integer;
begin
  result:=cBaseTag(obj).length;
end;

function cTagSignal.getname:string;
begin
  if obj<>nil then
    result:=cBaseTag(obj).name;
end;

procedure cTagSignal.loadSignal(p_name:string);
begin

end;

procedure cTagSignal.setname(s:string);
begin
  if obj=nil then
  begin
    if (dataType='R8') or (dataType='r8') then
    begin
      obj:=cdVectorTag.create;
    end;
    if (dataType='R4') or (dataType='r4') then
    begin
      obj:=cVectorTag.create;
    end;
  end;
  if obj<>nil then
    cBaseTag(obj).name:=s;
end;

function cTagSignal.SignalType:integer;
begin
end;

function cTagSignal.GetT0:single;
begin
  if obj is c2VectorTag then
    result:=c2VectorTag(obj).XMinMax.x;
  if obj is cVectorTag then
  begin
    result:=0;
  end;
  if obj is cdVectorTag then
  begin
    result:=0;
  end;
end;

function cTagSignal.GetP2(i:integer):point2;
begin
  if obj is c2VectorTag then
    result:=c2VectorTag(obj).Value[i];
end;

function cTagSignal.GetY(i:integer):single;
begin
  if obj is c2VectorTag then
    result:=c2VectorTag(obj).Value[i].y;
  if obj is cVectorTag then
    result:=cVectorTag(obj).Value[i];
  if obj is cdVectorTag then
    result:=cdVectorTag(obj).Value[i];
end;

function cTagSignal.GetP2d(i:integer):point2d;
begin
  if obj is c2dVectorTag then
    result:=c2dVectorTag(obj).Value[i];
end;

function cTagSignal.GetYd(i:integer):double;
begin
  if obj is c2dVectorTag then
    result:=c2dVectorTag(obj).Value[i].y;
end;

function cTagSignal.GetY(t:single):single;
begin
  if obj is c2VectorTag then
    result:=c2VectorTag(obj).getY(t);
  if obj is cVectorTag then
    result:=cVectorTag(obj).getValue(t);
  if obj is cdVectorTag then
    result:=cdVectorTag(obj).getValue(t);
end;

function cTagSignal.GetYd(t:double):double;
begin
  if obj is c2dVectorTag then
    result:=c2dVectorTag(obj).getY(t);
end;

function cTagSignal.GetX(i:integer):single;
begin
  if obj is c2VectorTag then
    result:=c2VectorTag(obj).Value[i].x;
end;

function cTagSignal.GetXd(i:integer):double;
begin
  if obj is c2dVectorTag then
    result:=c2dVectorTag(obj).Value[i].x;
end;

function cTagSignal.GetTEnd:single;
begin
  if obj is c2VectorTag then
    result:=c2VectorTag(obj).XMinMax.y;
  if obj is cVectorTag then
    result:=(1/freqX)*Count;
  if obj is cdVectorTag then
    result:=(1/freqX)*Count;
end;

function cTagSignal.VType:integer;
begin
  result:=c_float;
  if obj is c2dVectorTag then
    result:=c_double;
  if obj is cdVectorTag then
    result:=c_double;
end;

procedure cTagSignal.AddPoints(var p:array of point2);
begin
  if obj is c2VectorTag then
  begin
    c2VectorTag(obj).addpoints(p, length(p));
  end;
end;

procedure cTagSignal.AddPoints(var p:array of single);
begin
  if obj is cVectorTag then
  begin
    cVectorTag(obj).add(p);
  end;
end;

procedure cTagSignal.AddPoints(var p:array of double);
begin
  if obj is cdVectorTag then
  begin
    cdVectorTag(obj).add(p);
  end;
end;

procedure cTagSignal.clear;
begin
  if obj is cArrayTag then
  begin
    cArrayTag(obj).clear;
  end;
end;

procedure cTagSignal.setfreqX(v:single);
begin
  inherited;
  if obj is cVectorTag then
    cVectorTag(obj).dx:=1/v;
  if obj is cdVectorTag then
    cdVectorTag(obj).dx:=1/v;
end;

function cTagSignal.GetX0:double;
begin
  if obj is cdvectortag then
  begin
    result:=cdvectortag(obj).fx0;
  end;
  if obj is cvectortag then
  begin
    result:=cvectortag(obj).fx0;
  end;
end;

procedure cTagSignal.SetX0(x:double);
begin
  if obj is cdvectortag then
  begin
    cdvectortag(obj).fx0:=x;
  end;
  if obj is cvectortag then
  begin
    cvectortag(obj).fx0:=x;
  end;
end;

end.
