unit uTagSignal;

interface
uses
  uMeraSignal, uTag, uCommonTypes;

type
  cTagSignal = class(cSignal)
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
    function SignalType:integer;override;
    function GetT0:single;override;
    function GetTEnd:single;override;
    function GetP2(i:integer):point2;override;
  end;

implementation

function cTagSignal.Count:integer;
begin
  result:=cBaseTag(obj).length;
end;

function cTagSignal.getname:string;
begin
  result:=cBaseTag(obj).name;
end;

function cTagSignal.SignalType:integer;
begin
end;

function cTagSignal.GetT0:single;
begin
  if obj is c2VectorTag then
    result:=c2VectorTag(obj).XMinMax.x;
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
  result:=c2VectorTag(obj).getY(t);
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
  result:=c2VectorTag(obj).XMinMax.y;
end;

function cTagSignal.VType:integer;
begin
  if obj is c2dVectorTag then
    result:=c_double
  else
  begin
    result:=c_float;
  end;
end;

end.
