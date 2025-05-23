unit uPageSRS;

interface
uses
  uMeraSignal, uBaseObj,  uCommonTypes, math, classes, uSrs, uBuffSignal;
type

  cDiscreetSRSAlg = class(cSRSAlg)
  public
    function Eval(signal:csignal; shockindex:integer):csignal;override;
    function EvalTimeRealisation(signal:csignal; shockindex:integer;
                                     f:single; var maxV:single):csignal;override;
  end;

implementation
uses
  uSRSForm;

function cDiscreetSRSAlg.EvalTimeRealisation(signal:csignal; shockindex:integer;
                                     f:single; var maxV:single):csignal;
var
  shock:cShock;
  i, j, i1,i2:integer;
  x:array of single;
  dt, dt2, wn, wn2, N:single;
begin
  Shock:=GetShock(ShockIndex);
  i1:=Shock.i1;
  i2:=Shock.i2;
  dt:=1/signal.freqX;

  result:=csignal.create;
  result.capacity:=i2-i1-1;
  result.x0:=0;

  wn:=f*2*pi;
  wn2:=wn*wn;
  cbuffsignal(result).points1d[0]:=0;
  dt2:=dt*dt;

  setlength(x,cbuffsignal(result).count+1);
  x[0]:=0;
  x[1]:=dt2*cbuffsignal(signal).points1d[i1+1]/2;
  N:=wn*e*dt;
  // ������ ��������� ���������� �����������
  for i:= i1+2 to i2 - 1 do
  begin
    j:=i-i1;
    x[j]:=(dt2*cbuffsignal(signal).points1d[i]-x[j-1]*(wn2*dt2-2)-
                         x[j-2]*(1-N))/(1+N);
  end;
  cbuffsignal(result).points1d[0]:=0;
  maxV:=0;
  // ������ ���������
  for i:= 1 to cbuffsignal(result).count-2 do
  begin
    cbuffsignal(result).points1d[i]:=(x[i+1]-2*x[i]+x[i-1])/dt2;
    if abs(cbuffsignal(result).points1d[i])>abs(maxV) then
    //if result.points[i]>maxV then
      maxV:=cbuffsignal(result).points1d[i];
  end;
end;

// signal - ��������� ������ ��� ������� ������� �����. �� ��� ���� �������� ��������
function cDiscreetSRSAlg.Eval(signal:csignal; shockindex:integer):csignal;
var
  i, SpectrumLength:integer;
  f, maxV:single;
  s:csignal;
begin
  SpectrumLength:=trunc((f2-f1)/df);
  result:=csignal.create;
  cbuffsignal(result).capacity:=SpectrumLength;
  //cbuffsignal1d(result).dx:=trunc(df);
  result.x0:=f1;

  f:=f1;
  // ������ �� ����������� ��������
  for i := 0 to SpectrumLength - 1 do
  begin
    s:=EvalTimeRealisation(signal,ShockIndex,f,maxV);
    s.destroy;
    cbuffsignal(result).points1d[i]:=maxV;
    f:=f+df;
  end;
end;

end.
