unit uKoltSRS;

interface
uses
  uMeraSignal, uBaseObj, uCommonTypes, math, classes, uSrs, ubuffsignal;
type

  ckSRSAlg = class(cSRSAlg)
  public
    function Eval(signal:csignal; shockindex:integer):csignal;override;
  end;

implementation
uses
  uSRSForm;

// signal - ��������� ������ ��� ������� ������� �����. �� ��� ���� �������� ��������
function ckSRSAlg.Eval(signal:csignal; shockindex:integer):csignal;
var
  shock:cShock;
  dt, rab, w, f_t, w_s, A_1, A_2, B_b, Ud, Y1, Y2, y3, yy:single;
  f,i1,i2,SpectrumLength:integer;
  I,j: Integer;
  �: Integer;
begin
  Shock:=GetShock(ShockIndex);

  SpectrumLength:=trunc((f2-f1)/df);
  result:=csignal.create;
  result.capacity:=SpectrumLength;
  //result.dx:=trunc(df);
  result.x0:=f1;

  dt:=1/signal.freqX;
  i1:=Shock.i1;
  i2:=Shock.i2;

  rab:=sqrt(1-e*e);
  f:=trunc(f1);
  for I := 0 to SpectrumLength - 1 do
  begin
    w:=2*pi*f;
    f_t:=w*dt;
    w_s:=w*rab;
    a_1:=exp(-e*f_t);
    a_2:=-a_1*a_1;
    b_b:=f_t*a_1*sin(w_s*dt)/rab;
    a_1:=a_1*2*cos(w_s*dt);
    ud:=0;
    y1:=0;
    y2:=0;
    for j := i1 to i2-i1 - 1 do
    begin
      y3:=B_b*cbuffsignal(signal).points1d[j]+a_1*y2+a_2*y1;
      y1:=y2;
      y2:=y3;
      yy:=abs(y3);
      if yy>ud then
        ud:=yy;
    end;
    cbuffsignal(result).points1d[i]:=ud;
    f:=f+trunc(df);
  end;
end;

end.
