unit uSignalsUtils;

interface
uses
  uMeraSignal, uBasicTrend, uBuffTrend1d, upoint, ucommontypes, ubuffsignal, utrend;

Procedure CopyToTrend(trend:cbasictrend; s:csignal);
function GetTrend(s:csignal):cbasicTrend;
function CreateSignal(t:ctrend):cBuffSignal;

implementation

function CreateSignal(t:ctrend):cBuffSignal;
begin
  result:=cBuffSignal.create;
  Result.WriteXY:=true;
  result.DataType:='r4';
  result.m_1d:=false;
  result.name:=t.name;
  result.AddPoints(t.drawarray);
end;

function GetTrend(s:csignal):cbasicTrend;
var
  I: Integer;
begin
  result:=nil;
  if s=nil then exit;
  if s is cbuffsignal then
  begin
    result:=cbufftrend1d.create;
    cbufftrend1d(result).x0:=cbuffsignal(s).x0;
    cbufftrend1d(result).dx:=1/cbuffsignal(s).freqx;
    cbufftrend1d(result).Count:=cbuffsignal(s).Count;
    for I := 0 to cbuffsignal(s).Count - 1 do
    begin
      cbufftrend1d(result).AddPoint(cbuffsignal(s).gety(i),i);
    end;
  end;
end;

Procedure CopyToTrend(trend:cbasictrend; s:csignal);
var
  i:integer;
  dx:single;
begin
  if s is cbuffsignal then
  begin
    for i := 0 to s.count - 1 do
    begin
      trend.addpoint(s.Getp2(i));
      //trend.prt:=@s.prt;
    end;
  end;
end;


end.
