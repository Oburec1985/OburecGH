unit uTrendSignal;

interface
uses
  uMeraSignal, uTrend, uCommonTypes, uBasicTrend;

type
  cTrendSignal = class(cSignal)
  public
    function VType:integer;override;
    function Count:integer;override;
    function GetY(i:integer):single;overload; override;
    function GetY(t:single):single;overload; override;
    function GetX(i:integer):single;override;
    function getname:string;override;
    function SignalType:integer;override;
    function GetT0:single;override;
    function GetX0:double;override;
    function GetTEnd:single;override;
    function GetP2(i:integer):point2;override;
  end;


implementation

function cTrendSignal.Count:integer;
begin
  result:=cBasicTrend(obj).count;
end;

function cTrendSignal.getname:string;
begin
  result:=cBasicTrend(obj).name;
end;

function cTrendSignal.SignalType:integer;
begin
end;

function cTrendSignal.GetX0:double;
begin
  result:=0;
end;

function cTrendSignal.GetT0:single;
begin
  result:=cBasicTrend(obj).GetT0;
end;

function cTrendSignal.GetP2(i:integer):point2;
begin
  result:=cBasicTrend(obj).getP2(i);
end;

function cTrendSignal.GetY(i:integer):single;
begin
  result:=cBasicTrend(obj).getP2(I).y;
end;

function cTrendSignal.GetY(t:single):single;
begin
  result:=cBasicTrend(obj).gety(t);
end;

function cTrendSignal.GetX(i:integer):single;
begin
  result:=cBasicTrend(obj).getP2(i).x;
end;

function cTrendSignal.GetTEnd:single;
begin
  result:=cBasicTrend(obj).getP2(cBASICTrend(obj).count-1).x;
end;

function cTrendSignal.VType:integer;
begin
  result:=c_float;
end;

end.
