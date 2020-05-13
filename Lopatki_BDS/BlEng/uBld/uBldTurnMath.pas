// � ������ ������� ��������� � ������� ��� ��������� ���������� �������
unit uBldTurnMath;

interface
uses
  uBldFile, math, umyTypes_, utickdata, uMyMath, classes;

// �������� ���� sensorind-��� �������, ��������� skip ������� � ��������� � trend
function EvalSkipBlades(pos:single;stage:cstage;blade:integer):integer;
// ��������� ��� ��������� ��� ������ ��������� start, end �� ������ ����
function EvalTickPosInTurn(tick,tick1,tick2:stickdata;start,finish:single):single;
// ��������� ��� ��������� ��� ������ ��������� start..finish, ���� ������ taxo ������������
// � �������� ���������� sortedtaxo, ����� ����������� ��������� ������ �������
// ������� ������� ������������� ���� � ������ ������������ � �������, ��������� ��������
// ������ �������� � ������� ������� ���� ������ �������. ������� ����� ������ ��� ���������
// ��� ��� � ��� ��� ������ �������� ��-�� �������� � �������
function EvalTickPos(tick:sTickData;start,finish:single;const taxo:cticks;
                     sortedtaxo,useAcseleration:boolean):single;
// ��������� ��� ��������� ��� ������ ��������� start..finish, ���� ������ taxo ������������
// � �������� ���������� sortedtaxo, ����� ����������� ��������� ������ �������
function EvalTickPos_(tick:sTickData;start,finish:single;const taxo:cticks;
                      sortedtaxo,useAcseleration:boolean):single;
// ��������� ���� � �������� ������� ������� ������� ������
// ��� �������� ������� �� �������
function EvalBladePath(Bladepos,Sensorpos:single):single;
// ��������� ����� ������� �������
function EvalStageBladeCount(const taho:array of stickdata;
                             const sensorticks:array of stickdata;
                             Tahodivision:integer):integer;
// ��������� ����� ������� �� ������ �������.
// Tick1, Tick2 - ����� ������ � ����� �������.
// shape - ����� ������.
// sensorticks - ������ �����.
// skip - ����� ������� ������� ���� ���������� ����� �� ������� �������� ������� �� 1-� �������
// ���������� false ���� ������ ������� (��� ������ ����� ��� �������)
// ����������� ����� ������������ � ������ shape.points2[i].x
function EvalStageShapeByTurn(const tick1, tick2:sTickData;
                      const sensorticks:array of stickdata;
                      bladenumber:integer;
                      var shape:cpoints2):boolean;
// ��������� ������� ������� ������ ������� � ����� ��:
// ��������� ������� �� ����, ��������� �������� � �������� �������� ����
// (������ ����� ���� �������)
function EvalBladePosTick(BladePos,SensorPos,Amplitude:single;Taho1,Taho2:sTickData):stickdata;


implementation

// ��������� ������� ������� ������ ������� � ����� ��:
// ��������� ������� �� ����, ��������� �������� � �������� �������� ����
// (������ ����� ���� �������)
function EvalBladePosTick(BladePos,SensorPos,Amplitude:single;
                          Taho1, Taho2:stickdata):stickdata;
var
  i,j:integer;
  // dT - ����� ������� 1-� �������; A - ���� ���������� ��������; f - ����
  Tturn,T0,dT:Cardinal;
  T:integer;
  A,phase:single;
  lOverflow:cardinal;
begin
  lOverflow:=1;
  Tturn:=decTicks(Taho2.Data, Taho1.Data, lOverflow);
  // ����� ������� ������ �������
  dT := trunc(Tturn/360);
  // ���� ���������� �������� � ��������
  a:=EvalBladePath(Bladepos,Sensorpos);
  // ��������� ����� ������� �������� + dT(��������)
  lOverflow:=Taho1.OverflowCount;
  // ��������� ����� ������� = ���� � ��������*t(1-� �������)
  T0 :=AddTicks(Taho1.Data,trunc(dT*A),lOverflow);
  // T - �������� �������� ������� �������
  T :=trunc(dT*Amplitude);
  Result.Data:=AddTicks(T0,T,lOverflow);
  Result.OverflowCount:=lOverflow;
end;
// ��������� ����� ������� �������
function EvalStageBladeCount(const taho:array of stickdata;
                             const sensorticks:array of stickdata;
                             Tahodivision:integer):integer;
var taholen,sensorlen:integer;
  function ROUND_(v:single):integer;
  begin
    result:=round(v);
  end;
begin
  result:=ROUND_(length(sensorticks)/length(taho));
end;
// ��������� ����� ������� �� ������ �������.
// Tick1, Tick2 - ����� ������ � ����� �������.
// shape - ����� ������.
// sensorticks - ������ �����.
function EvalStageShapeByTurn(const tick1, tick2:sTickData;
                        const sensorticks:array of stickdata;
                        bladenumber:integer;
                        var shape:cpoints2):boolean;
var tickCountInTurn,i,impulsind,tturn, tdeg, Startind, bladeind:cardinal;
    pos:single;
begin
  tturn:=DecTicks_(tick2,tick1);
  tdeg:=round(tturn/360);
  Startind:=FindInTickArrayHiBound(sensorticks,tick1);
  tickCountInTurn:=0;
  for i:=startind to startind + bladenumber-1 do
  begin
    // �������� ��� ��� ��������� ������ �������
    if not inTurn(sensorticks[i],tick1,tick2) then
      break;
    // ����� �������� ������ �������
    impulsind:=i-startind;
    // ������ ������ ������� (��������� ���� � 0-�)
    if (impulsind)<bladenumber then
      bladeind:=impulsind
    else
      bladeind:=bladenumber-(impulsind);
    // ��������� ���� ������ �������
    pos:=EvalTickPosInTurn(sensorticks[i],tick1,tick2,0,360);
    shape.ar[bladeind].x:=pos;
    inc(tickCountInTurn);
  end;
  if TickCountInTurn<bladenumber then
    result:=false
  else
    result:=true;
end;

function EvalBladePath(Bladepos,Sensorpos:single):single;
begin
  // ���� ���������� �������� � ��������
  if sensorpos<Bladepos then
     result:=360 - (Bladepos - sensorpos)
  else
     result:=sensorpos - Bladepos;
end;

// ������� � ������� ������� ������ �� �������� � �������� x
function FindInDoubleArrayHiBound(const a:array of sblade;x:real):integer;
var b:boolean;
    len,range,curind,
    left,right:integer;
    frac_:boolean;
    function _div(a,b:integer;var frac_:boolean):integer;
    var res:integer;
    begin
       if a=1 then
       begin
        result:=0;
        exit;
       end;
       res:= trunc(a/b);
       frac_:=((a mod b)<>0);
       result:=res;
    end;
begin
  len:=Length(a);
  // �������� ��������� �����������
  if a[len-1].offset<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0].offset>x then
  begin
    result:=0;
    exit;
  end;
  // ���������� ������� ������ � �������
  left:=0;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a[curind].offset>x then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if a[curind].offset>x then
    result:=curind
  else
    result:=curind+1;
end;

// ��������� ����� �������? ������� ���� ����������, ����� �������������
// ������ ������� �������� ����������� � ������� pos
// blade - ����� ������� �������� ������� ������ ���������
function EvalSkipBlades(pos:single;stage:cStage;blade:integer):integer;
var intpos:integer;
    count:integer; // ����� ������������ �������
begin
  // ������� ����� ����� ������� ����� ������
  intpos:=FindInDoubleArrayHiBound(stage.blades,pos);
  // ��������� ����� ������� ������� ���� ����������
  if intpos>blade then
    result:=intpos - blade -1
  else
    result:=stage.bladenumber - blade + intpos -1;
end;
// ��������� �������� ������ �������
function EvalVelocity(start,finish:stickdata):single;
var t1,t2,dt:single;
begin
  // ����� � �������� �� ������ ������� ����
  t1:=CalcTime_(start);
  // ����� � �������� �� ������ ���������� ����
  t2:=CalcTime_(finish);
  dt:=t2-t1;
  result:=1/dt;
end;
// ��������� ��������� ������ �������. V1,V2 �������� ���������, t1,t2
// �������� ������� ������� � ������� �������
//     v1:=1/(t2-t1)     v2:=1/(t3-t2)
//                     a:=(v2-v1)/(t3-t1)
// t1----------------t2------------------t3
function EvalAceleration(v1,v2:single;t1_,t2_:sTickData):single;
var t1,t2:single;
begin
  // ����� � �������� �� ������ ������� ����
  t1:=CalcTime_(t1_);
  // ����� � �������� �� ������ ���������� ����
  t2:=CalcTime_(t2_);
  result:=(v2-v1)/(t2-t1);
end;
// ��������� ������� ���� ������ �������
function EvalTickPosinTurn(tick,tick1,tick2:stickdata;start,finish:single):single;
var tturn,dt:cardinal;
    d:single;
begin
  tturn:=DecTicks_(tick2,tick1);
  d:=finish - start;
  dt:=DecTicks_(tick,tick1);
  result:=(dt/tturn)*d + start;
end;
// ��������� ��� ��������� ��� ������ ��������� start..finish, ���� ������ taxo ������������
// � �������� ���������� sortedtaxo, ����� ����������� ��������� ������ �������
// useAcseleration - ������������ ��������� ��� �������� (���� ����������)
function EvalTickPos(tick:sTickData;start,finish:single;const taxo:cticks;
                     sortedtaxo,useAcseleration:boolean):single;
var i,len:integer;
    round:single;
    a,v:single;//���������
    t1,t2,t:single;
begin
  len:=length(taxo.ticks);
  if sortedtaxo then
  begin
    i:=FindInTickArrayLowBound(taxo.ticks,tick);
  end
  else // ���������� i ���������
  begin

  end;
  round:=finish-start;
  if i<>0 then
  begin
    // ����� � �������� �� ������ ������� ����
    t1:=CalcTime_(taxo.ticks[i]);
    // ����� � �������� �� ������ ���������� ����
    t2:=CalcTime_(taxo.ticks[i-1]);
    t:=CalcTime_(tick);
    v:=1/(t1-t2); // � ������
  end
  else
  begin
    t2:=CalcTime_(taxo.ticks[1]);
    t1:=CalcTime_(taxo.ticks[0]);
    t:=CalcTime_(tick);
    v:=1/(t2-t1); // � ������
  end;
  // ���������� �������� ������ ������� � ��������
  if ((i>2) and (useAcseleration)) then
  begin
    a:=EvalAceleration(EvalVelocity(taxo.ticks[i-1],taxo.ticks[i]),v,
                       taxo.ticks[i-1],taxo.ticks[i+1]);
  end
  else
  begin
    a:=0;
  end;
  a:=a*round;
  v:=round*v; // � �������� � ������� round
  t:=t-t1;
  result:=v*t+a*t*t/2;
end;
function EvalTickPos_(tick:sTickData;start,finish:single;const taxo:cticks;
                      sortedtaxo,useAcseleration:boolean):single;
var i,len:integer;
    round:single;
    overflow,t,t1,t2,dt:cardinal;
begin
  len:=length(taxo.ticks);
  if sortedtaxo then
  begin
    i:=FindInTickArrayLowBound(taxo.ticks,tick);
  end
  else // ���������� i ���������
  begin
  end;
  round:=finish-start;
  if i<>0 then
  begin
    // ����� � �������� �� ������ ������� ����
    t2:=taxo.ticks[i].Data;
    // ����� � �������� �� ������ ���������� ����
    t1:=taxo.ticks[i-1].data;
    overflow:=1;
    dt:=decTicks(t2,t1,overflow);
    overflow:=1;
    t:=decTicks(tick.Data,t2,overflow);
  end
  else
  begin
    t2:=taxo.ticks[1].Data;
    t1:=taxo.ticks[0].Data;
    overflow:=1;
    dt:=decTicks(t2,t1,overflow);
    overflow:=1;
    t:=decTicks(tick.Data,t1,overflow);
  end;
  result:=(t/dt)*round;
end;



end.
