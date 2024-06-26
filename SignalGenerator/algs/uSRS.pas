unit uSRS;

interface
uses
  uMeraSignal, uBaseObj, uCommonTypes, math, classes, ubuffsignal;
type

  // ��������� ��������� ����
  cShock = class
  public
    // ����� �����
    ind,
    // ������� �����
    i1,i2,
    // ������������ ��������� (�� ������) - ������
    iAmax:integer;
    // ����� ����
    tmax,
    // ������ � ����� �����
    t1,t2,
    // ������������ ��������� (�� ������)
    Amax:single;
  end;

  cSRSAlg = class(cBaseObj)
  public
    // ��������� � �������� ������ ������������ ����� �� �������
    offset1,offset2,
    // ��������� � �������� �������
    f1,f2,
    // ���������� �� ������� ��� ������� �������
    dF,
    // �������������
    e
    :single;
    // ��������� �������� � ��������� (�� �����) ��� �������
    Threshold, GistThrehold:integer;
    ShockList:tList;
  protected
    cursignal:csignal;
  protected
    procedure clearShockList;
  public
    // ��������� ������ � ����� ������ � ��������
    procedure EvalShockEdges(s:csignal);
    function Eval(signal:csignal; shockindex:integer):csignal;virtual;
    function EvalTimeRealisation(signal:csignal; shockindex:integer;
                                  f:single; var maxV:single):csignal;virtual;
    function GetShock(i:integer):cShock;
    constructor create;
    destructor destroy;
  end;

  function EvalSRS(s:csignal):csignal;

implementation
uses
  uSRSForm;

constructor cSRSAlg.create;
begin
  ShockList:=TList.Create;
end;

destructor cSRSAlg.destroy;
begin
  ClearShockList;
  ShockList.Destroy;
end;

procedure cSRSAlg.EvalShockEdges(s:csignal);
var
  aMax, r, thresholdMax, thresholdMin, gist_max, gist_min:single;
  iMax,I: Integer;
  p2:point2;
  shock:cShock;
  // ������ ����
  Detected,
  // ���������� ����� ���������� ��� ����� ����� ������� �� ����� �������
  // ������������� ����� ����� ����� ������ ����� ��� ������
  needBreak:boolean;
  Y,dx:single;
begin
  cursignal:=s;
  // ������� ����� ������
  ClearShockList;
  p2:=cbuffsignal(cursignal).evalestimates;
  r:=p2.y*Threshold/200;
  thresholdMax:=p2.x+r;
  thresholdMin:=p2.x-r;
  r:=p2.y*GistThrehold/100;
  gist_max:=thresholdMax-r;
  gist_min:=thresholdMin+r;
  Detected:=false;
  needbreak:=false;
  i:=0;
  while i<(cursignal.Count-1) do
  begin
    if cbuffsignal(cursignal).m_1d then
      y:=cbuffsignal(cursignal).points1d[i]
    else
      y:=cbuffsignal(cursignal).points2d[i].y;
    // �������� ��������� �������������� �����
    if y>thresholdMax then
    begin
      detected:=true;
      // ��������� ��������� � �����
      aMax:=y;
      // ������ ��������� � �����
      iMax:=i;
      while y>gist_max do
      begin
        if i>cbuffsignal(s).count then
        begin
          break;
        end;
        if aMax<y then
        begin
          aMax:=y;
          iMax:=i;
        end;
        inc(i);
      end;
    end
    else
    begin
      // �������� ��������� �������������� �����
      if y<thresholdMin then
      begin
        detected:=true;
        // ��������� ��������� � �����
        aMax:=y;
        // ������ ��������� � �����
        iMax:=i;
        while y<gist_min do
        begin
          if i>cbuffsignal(cursignal).count then
          begin
            break;
          end;
          if aMax<y then
          begin
            aMax:=y;
            iMax:=i;
          end;
          inc(i);
        end;
      end;
    end;
    if detected then
    begin
      shock:=cshock.create;
      shock.ind:=shocklist.Count;
      shock.iAmax:=iMax;
      shock.Amax:=aMax;
      dx:=1/cbuffsignal(cursignal).freqX;
      if cbuffsignal(s).m_1d then
      begin
        shock.tmax:=shock.iAmax*dx;
      end
      else
      begin
        shock.tmax:=cbuffsignal(s).points2d[shock.iAmax].x;
      end;
      // ������ � ����� �����
      shock.t1:=shock.Tmax-offset1;
      if shock.t1<0 then
      begin
        shock.t1:=0;
        shock.i1:=0;
      end
      else
      begin
        shock.i1:=round(shock.t1/dx);
      end;
      shock.t2:=shock.Tmax+offset2;
      if shock.t2>s.GetTEnd then
      begin
        shock.t2:=s.GetTEnd;
        shock.i2:=s.count-1;
        needbreak:=true;
      end
      else
      begin
        shock.i2:=round(shock.t2/dx);
        i:=shock.i2;
      end;
      ShockList.Add(shock);
      detected:=false;
    end;
    if needbreak then
      break;
    inc(i);
  end;
end;


// signal - ��������� ������ ��� ������� ������� �����. �� ��� ���� �������� ��������
function cSRSAlg.Eval(signal:csignal; shockindex:integer):csignal;
var
  wn,
  // 2*exp(-e*wn*dt)
  l_exp,
  // cos(wd*dt)
  l_cos,
  // e*dt*wn
  e_dT_wn,
  // e*e
  e2,
  // ������������� ����������� �������
  f,
  // Wn*Sqrt(1-e*e);
  Wd,
  // Wd*dT
  Wd_dT,
  wn_dt,
  // ���������� �������
  dT,
  // ��������� �� ���� i-2, i-1, i
  Ai_2, Ai_1, Ai,
  // �������� ����� �� ���� i-1 � i
  Yi_1, Yi,
  // ������������ ����� ����������� ���������� �� ������� (���� ������� �� ����)
  B1,B2,B3,B4
  :single;
  // ������������ �������� ��� ������� �����
  Amax:single;
  // ������� ��������, ��������� � �������� ������ ����������� �������
  SpectrumLength,spectrumcounter,i,i1,i2:integer;

  shock:cShock;

  ldx:single;
begin
  Shock:=GetShock(ShockIndex);
  SpectrumLength:=trunc((f2-f1)/df);
  result:=cbuffsignal.create;
  result.freqX:=df;
  result.x0:=f1;
  result.capacity:=SpectrumLength;

  // m_dx:=v;
  // m_fs:=1/v;
  // result.dx:=trunc(df);
  ldx:=trunc(df);
  result.x0:=f1;
  // ???
  dt:=1/signal.freqX;

  i1:=Shock.i1;
  i2:=Shock.i2;
  e2:=e*e;
  Ai_2:=0;
  Ai_1:=0;
  f:=f1;
  spectrumcounter:=0;
  while f<f2 do
  begin
    wn:=f*2*pi;
    wn_dt:=dt*wn;
    e_dT_wn:=e*wn_dt;
    wd:=wn*sqrt(1-e2);
    wd_dt:=wd*dt;
    l_exp:=exp(-e_dt_wn);
    l_cos:=cos(wd_dt);
    //B1:=2*exp(-e*wn*dt)*cos(wd*dt);
    B1:=2*l_exp*l_cos;
    //B2:=exp(-2*e*wn*dt);
    B2:=l_exp*l_exp;
    //B3:=2*e*wn*dt;
    B3:=2*e_dT_wn;
    //B4:=wn*dt*exp(-e*wn*dt)*( (wn/wd)*(1-2*e*e)*sin(wd*dt)-2*e*cos(wd*dt) );
    B4:=wn_dt*l_EXP*( sin(wd_dt)*wn/wd*(1-2*e2) - 2*e*l_cos );
    Amax:=0;
    for I := i1+1 to i2 do
    begin

      Ai:=B1*Ai_1-
          B2*Ai_2+
          B3*cbuffsignal(signal).GetY(i)+
          B4*cbuffsignal(signal).GetY(i-1);
      if abs(Amax)<abs(Ai) then
      begin
        Amax:=Ai;
      end;
      Ai_2:=Ai_1;
      Ai_1:=Ai;
    end;
    cbuffsignal(result).points1d[spectrumcounter]:=Amax;
    inc(spectrumcounter);
    f:=f+df;
  end;
end;

function cSRSAlg.EvalTimeRealisation(signal:csignal; shockindex:integer;
                                     f:single; var maxV:single):csignal;
var
  wn,
  // 2*exp(-e*wn*dt)
  l_exp,
  // cos(wd*dt)
  l_cos,
  // e*dt*wn
  e_dT_wn,
  // e*e
  e2,
  // Wn*Sqrt(1-e*e);
  Wd,
  // Wd*dT
  Wd_dT,
  wn_dt,
  // ���������� �������
  dT,
  // ��������� �� ���� i-2, i-1, i
  Ai_2, Ai_1, Ai,
  // �������� ����� �� ���� i-1 � i
  Yi_1, Yi,
  // ������������ ����� ����������� ���������� �� ������� (���� ������� �� ����)
  B1,B2,B3,B4
  :single;
  // ������� ��������, ��������� � �������� ������ ����������� �������
  SpectrumLength,spectrumcounter,i,i1,i2:integer;

  shock:cShock;
begin
  Shock:=GetShock(ShockIndex);
  wn:=f*2*pi;

  dt:=1/cbuffsignal(signal).freqx;
  i1:=Shock.i1;
  i2:=Shock.i2;

  result:=cbuffsignal.create;
  cbuffsignal(result).capacity:=i2-i1;
  cbuffsignal(result).freqX:=dt;

  e2:=e*e;
  Ai_2:=0;
  Ai_1:=0;

  spectrumcounter:=0;

  wn_dt:=dt*wn;
  e_dT_wn:=e*wn_dt;
  wd:=wn*sqrt(1-e2);
  wd_dt:=wd*dt;
  l_exp:=exp(-e_dt_wn);
  l_cos:=cos(wd_dt);
  // B1=2*exp(-e*wn*dt)*cos(wd*dt)
  B1:=2*l_exp*l_cos;
  // B2=exp(-2*e*wn*dt)
  B2:=l_exp*l_exp;
  // B3=2*e*wn*dt
  B3:=2*e_dT_wn;
  // B4=wn*dt*exp(-e*wn*dt)*( (wn/wd)*(1-2*e*e)*sin(wd*dt)-2*e*cos(wd*dt) )
  B4:=wn_dt*l_EXP*( sin(wd_dt)*wn/wd*(1-2*e2) - 2*e*l_cos );
  maxV:=0;
  for I := i1+1 to i2 do
  begin
    Ai:=B1*Ai_1-
        B2*Ai_2+
        B3*cbuffsignal(signal).gety(i)+
        B4*cbuffsignal(signal).gety(i-1);
    Ai_2:=Ai_1;
    Ai_1:=Ai;
    if abs(maxV)<abs(Ai) then
    begin
      maxV:=Ai;
    end;
    cbuffsignal(result).points1d[i-i1-1]:=Ai;
  end;
end;

procedure cSRSAlg.clearShockList;
var
  I: Integer;
  shock:cShock;
begin
  for I := 0 to ShockList.Count - 1 do
  begin
    Shock:=cShock(ShockList.Items[i]);
    Shock.Destroy;
  end;
  ShockList.Clear;
end;

function EvalSRS(s:csignal):csignal;
begin
  result:=SRSForm.EvalSRS(s);
end;

function cSRSAlg.GetShock(i:integer):cShock;
begin
  if i<=ShockList.count-1 then
  begin
    result:=cshock(ShockList.Items[i]);
  end;
end;

end.
