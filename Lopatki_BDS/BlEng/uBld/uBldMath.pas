// ������ �������� ��������� �������  ��������� �������������:
// ���������� ����, ���������� ���������� �������
// � �.�. ��� ������� �������� �� ��������� ��������� ������ �������

unit uBldMath;

interface
uses
  uBldFile, math, utickdata, uMyMath, classes, dialogs, usensor, uchan, ubaseobj, sysutils,
  utrend, ucommontypes, uchart, upage, uaxis, ugistogram, udrawobj,
  uErrorProc, uSimpleSetList, ubasictrend;

  // �������������� ���� � �������
  function TickToSec(tick:stickdata):single;overload;
  function TickToSec(tick:cardinal):single;overload;
  function GetFreq(t1,t2:stickdata):single;
  // ����������� ������� � ����
  function SecToTick(time:single):stickdata;
  // ���������� ������ ���������� ���� � �������
  function GetLastTick(t1,t2:stickdata;sensor:cBaseTicks):integer;
  // ������ ����� ������� ������ �������
  function TickCountInTurn(t1,t2:stickdata;sensor:cBaseTicks):integer;
  // ��������� ����� ������� �� ���������� �����
  function EvalBladesCount(taho:cBaseTicks; sensor:cBaseTicks):integer;
  // ��������� ����� ������� �������� �� ������ ����������� � ������� Pos
  function EvSensorTickInTurn(start:stickdata;degT:single;pos:single):stickdata;overload;
  function EvSensorTickInTurn(start:stickdata;dt:cardinal;pos:single):stickdata;overload;
  function EvSensorTickInTurn(start,finish:stickdata; pos:single):stickdata;overload;
  // ��������� ���� ������� ������ ������ �������, ���� ��������� ��� ��������
  function EvalBladePath(sensorpos, bladepos:single):single;
  // ��������� ������ ������������ � ������� turnIndex �� �����������/
  // �������� ��� � ������ ������� sensor ������� bladecount �������. ���� ������ ���������,
  // �� ���������� ������ ������ ������� � �������
  // �� ��, ��� � ����������, �� sensorind ���������� ������ ������� � ������� �������
  function TestTurn(SensorTicks:cBaseTicks; sensorind:integer;t1,t2:stickdata;
                    bladeCount:integer;endPos:single; var last:integer):integer;
  // ������ ������ ��� ����. ���������� ���� � �������, ������ ���� ������� � ��������
  // ����� ������������ ���������
  // sensor - ������ �� �������� ��������� ����.
  // ����� - ������ � ������� ������� ��������� �������
  // ������� ������������ ��� fi=1/ (ti - t(i-1)). ����� fi ����������� ������ ti+1/(2*dt)
  procedure EvalTaxo(sensor:csensor; trend:cbasictrend; uts:cbaseobj);
  // ��������� ��� ������ tick ��������� ������ �������
  function InTurn(t1,t2,tick:stickdata):boolean;
  // ����� ��������� ���� � �������� ������ �������
  function EvalTickPos(t1,t2,tick:stickdata):single;overload;
  function EvalTickPos(t1,tick:stickdata;freq:single):single;overload;
  // ����� ���� ������� �������� ������� � ������� �� dt
  function EvalTickDPos(t1,t2:stickdata;dtick:integer):single;overload;
  function EvalTickDPos(freq:single;dtick:integer):single;overload;
  // ��������, ��� ������ �������� ������� ������������������
  // �������� ���������� �� ���������� �������� (���������� ������ ���� �� 0)
  function GetOffsetsInit(data:array of single):boolean;
  procedure prepareBlades(var blades:array of single; const offsets:array of single);
  // �������� ����� �������
  // skipblade - ���������� �������
  function getBladeNumber(skipblade, SensorIndex, bladecount:integer):integer;
  // �������� ������� ��������� ���������� ������� �� ������ � �����, ��������� ��������� ����������
  // � ������� from �� ������ to, ar - �������� ������ ��� �������
  // ����� ������ ���� �� ������ �������� ����� (from - to)
  function getBladeDistWithMeedle(ticks:cBaseTicks; from, toind:integer;
                                  var ar:array of integer;
                                  meedlepath:integer; thereshold:single):integer;
  // t1, t2 - ������ � ����� ������� dpos- ���������� ������� ����� �������������
  // � ����
  function DegToTick(t1,t2:stickdata; dpos:single):integer;

  const
  // ����� ��������� ���������� ������� �� ���������� ���������
    c_step = 2;

implementation
uses
  udensityalg, uUtssensor;

function getBladeNumber(skipblade, SensorIndex, bladecount:integer):integer;
begin
  if (skipblade>=sensorindex) then
    result:=skipblade - sensorindex
  else
    result:=skipBlade + bladecount - sensorindex;
end;

procedure prepareBlades(var blades:array of single; const offsets:array of single);
var
  I,count: Integer;
begin
  count:=length(offsets);
  blades[0]:=0;
  for I := 1 to count - 1 do
  begin
    blades[i]:=offsets[i-1] + blades[i-1];
  end;
end;

// ��������, ��� ������ �������� ������� ������������������
// �������� ���������� �� ���������� �������� (���������� ������ ���� �� 0)
function GetOffsetsInit(data:array of single):boolean;
var
  l:integer;
begin
  l:=length(data);
  if l<>0 then
    result:=data[l-1]<>0
  else
    result:=false;
end;

function GetLastTick(t1,t2:stickdata;sensor:cbaseticks):integer;
var
  ind,i,count:integer;
  tick:stickdata;
begin
  tick:=sensor.GetLoTick(t2,ind);
  if ind>0 then
  begin
    result:=ind;
  end
  else
    result:=-1;
end;

function TickCountInTurn(t1,t2:stickdata;sensor:cbaseticks):integer;
var
  ind,i,count:integer;
  tick:stickdata;
begin
  tick:=sensor.GetHiTick(t1,ind);
  if ind>0 then
  begin
    if compareticks(sensor.gettick(ind-1),t1)=0 then
    begin
      dec(ind);
      tick:=sensor.gettick(ind);
    end;
  end;
  count:=0;
  while compareticks(t2,tick)>0 do
  begin
    inc(count);
    inc(ind);
    if ind<sensor.Count then
      tick:=sensor.gettick(ind)
    else
      break;
  end;
  result:=count;
end;

function EvalBladesCount(taho:cbaseticks; sensor:cbaseticks):integer;
var
  count,I: Integer;
  t1,t2:stickdata;
begin
  count:=0;
  for I := 0 to taho.Count - 2 do
  begin
    t1:=taho.gettick(i);
    t2:=taho.gettick(i+1);
    count:=count+TickCountInTurn(t1, t2, sensor);
  end;
  result:=round(count/(taho.Count - 1));
end;

function TickToSec(tick:stickdata):single;
var
  t1:single;
begin
  t1:=MaxCardinalValue/cardfreq;
  result:=tick.OverflowCount*t1 + tick.Data/cardfreq;;
end;

function TickToSec(tick:cardinal):single;
var
  t:stickdata;
begin
  t.OverflowCount:=0;
  t.Data:=tick;
  result:=TickToSec(t);
end;

function SecToTick(time:single):stickdata;
var
  // ����� � �������� MaxCardinalValue �����
  overflowLength:single;
begin
  overflowLength:=(MaxCardinalValue/cardfreq);
  result.OverflowCount:=Trunc(time/overflowLength);
  result.Data:=trunc((time - result.OverflowCount*overflowLength)*cardfreq);
end;

function EvalSensorTickInTurn(start:stickdata;dt:cardinal;pos:single):stickdata;
var
  degT:single; // ����� ������� 1-� �������
  o:cardinal;
begin
  degT:=dt/360;
  result:=EvSensorTickInTurn(start,degt,pos);
end;

function EvSensorTickInTurn(start:stickdata;dt:cardinal;pos:single):stickdata;
var
  degT:single; // ����� ������� 1-� �������
  o:cardinal;
begin
  degT:=dt/360;
  result:=EvSensorTickInTurn(start,degt,pos);
end;

function EvSensorTickInTurn(start,finish:stickdata; pos:single):stickdata;
var
  dt:stickdata;// ����� �������
begin
  dt.Data:=evDecTicks(start,finish);
  result:=EvalSensorTickInTurn(start,dt.Data,pos);
end;
// degT ����� ����� ����������� ����� ������ 1 ������
function EvSensorTickInTurn(start:stickdata;degT:single;pos:single):stickdata;
begin
  result:=addtick(start,trunc(degT*pos));
end;

function EvalBladePath(sensorpos, bladepos:single):single;
begin
  if sensorpos>=bladepos then
    result:=sensorpos-bladepos
  else
    result:=360+sensorpos-bladepos;
end;

function InTurn(t1,t2,tick:stickdata):boolean;
begin
  result:=false;
  if (compareticks(t1,tick)<=0) then
  begin
    result:=compareticks(t2,tick)>=0;
  end;
end;

function TestTurn(SensorTicks:cbaseticks; sensorind:integer;t1,t2:stickdata;
                  bladeCount:integer;endPos:single; var last:integer):integer;
var
  j,i:integer;
  prevtick,tick:stickdata;
  dpos:single;
  // ���� ��� ��������� ������� ����������� � ������ ������
  addLast:boolean;
  freq: array of single;
begin
  tick:=SensorTicks.GetTick(sensorind);
  result:=sensorind;
  last:=GetLastTick(t1,t2,SensorTicks);
  if last<=sensorind+bladecount then
  // ��������� � ������� ������ ��� �������
  begin
    last:=sensorind+bladecount - 1;
    for j:=sensorind+1 to (last) do
    begin
      tick:=SensorTicks.gettick(j);
      if not InTurn(t1,t2,tick) then
      begin
        // ���� �� ����������� ������ �������� � ������� ����� ���������,
        // � �� ���� �� �� � ������ ������
        if j=last-1 then
        begin
          addLast:=false;
          // �������� �������� � ������� ���
          tick:=SensorTicks.gettick(last);
          // ������� ��������� ������� � �������. �.�. ��� �� �������� �����������
          // � ������ ������ ����� ����� > 360 ��������
          dpos:=EvalTickPos(t1,t2,tick);
          // ������� ���������� �������� �� ���������� ��������� ���������
          if endPos>=0 then
          begin
            dpos:=endpos-dpos;
            // ���������, ��� ������� ����������� �� ����� ��� �� �������� ����������
            if dpos<c_step then
            begin
              addLast:=true;
            end;
          end
          // ���� ��������� ��������� ������� �� ��������, �� �������, ��� �������
          // ������ ������ ������� ������ �� ������ "����" ����� ���������
          else
          begin
            if (dpos-360)<c_step then
              addLast:=true;
          end;
          if addLast then
            exit;
        end;
        last:=j-1;
        result:=-1;
      end;
    end;
  end
  // ��������� � ������� ������ ��� �������
  else
  begin
    result:=-1;
  end;
end;

function EvalTickPos(t1,t2,tick:stickdata):single;
var
  dt, dt2:int64;
begin
  // ����� �������
  dt:=evDecTicks(t1,t2);
  // ����� �� ������ ������� �� �������� tick
  dt2:=evDecTicks(t1,tick);
  result:=(dt2/dt)*360;
end;

function EvalTickPos(t1,tick:stickdata;freq:single):single;
var
  t2:stickdata;
begin
  t2:=Addtick(t1,trunc((1/freq)*CardFreq));
  result:=EvalTickPos(t1,t2,tick);
end;

function EvalTickDPos(t1,t2:stickdata;dtick:integer):single;
var
 dt:cardinal;
begin
  // ����� �������
  dt:=evDecTicks(t1,t2);
  result:=(dtick/dt)*360;
end;

function EvalTickDPos(freq:single;dtick:integer):single;
begin
  result:=freq*360*dtick/cardfreq;
end;

// ��c��� ����� ������ ;��������� ������� �� ������� � ������ ��������
procedure EvalTaxo(sensor:csensor; trend:cbasictrend; uts:cbaseobj);
var
  ticks:cbaseticks;
  len:integer;
  dT:stickdata;
  i: Integer;
  time,freq,TurnTime:double;
begin
  trend.clear;
  ticks:=sensor.chan.ticks;
  len:=ticks.Count;
  // ��������� �����
  for i := 1 to len-1 do
  begin
    //sensor.eng.getmessage(inttostr(i)+' '+ticktostr(ticks.gettick(i)), 2);
    dt:=DecTicks(ticks.gettick(i-1),ticks.gettick(i));
    TurnTime:=TickToSec(dt);
    // ������ ������� ��������
    freq:=1/turntime;
    time:=TickToSec(ticks.gettick(i))-(turntime/2);
    trend.AddPoint(p2(time,freq));
  end;
end;

function GetFreq(t1,t2:stickdata):single;
var
  dt:integer;
begin
  dt:=evDecTicks(t1,t2);
  result:=CardFreq/dt;
end;

function getBladeDistWithMeedle(ticks:cbaseticks; from, toind:integer; var ar:array of integer; meedlepath:integer; thereshold:single):integer;
var
  sum, ithereshold, i, meedle:integer;
  list:  cIntSetList;
  t1,t2:stickdata;
begin
  list:=cIntSetList.create;
  list.destroydata:=true;
  for I := from to  toind-1 do
  begin
    t1:=ticks.gettick(i);
    t2:=ticks.gettick(i+1);
    ar[i-from]:=evDecTicks(t1,t2);
  end;
  for I := 0 to  meedlepath do
  begin
    list.Add(ar[i]);
  end;
  // ������ �������� �������
  meedle:=trunc(list.Count/2);
  // �������� �������
  meedle:=list.getInt(meedle);
  ithereshold:=round(meedle*thereshold);
  sum:=0;
  for I := 0 to toind-from-1 do
  begin
    if abs(meedle-ar[i])>ithereshold then
    begin
      ar[i]:=meedle;
    end;
    sum:=ar[i]+sum;
  end;
  list.destroy;
  result:=round(sum/(toind-from));
end;

function DegToTick(t1,t2:stickdata; dpos:single):integer;
var
  dt:integer;
begin
  dt:=evDecTicks(t1,t2);
  result:=trunc(dt*dpos/360);
end;



end.
