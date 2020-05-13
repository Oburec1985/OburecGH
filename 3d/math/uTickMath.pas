unit uTickMath;
interface
uses math;

  // сложить времена в тиках с учетом преполнений (cardinal)
  Function AddTicks(Tick:cardinal;dTick:Int64;var overflow:cardinal):cardinal;
  // вычесть времена в тиках с учетом преполнений (cardinal)
  Function DecTicks(Tick:cardinal;dTick:Int64; var overflow:cardinal):cardinal;
  // Получить разницу в тиках без учета переполнений счетчика
  Function GetDeltaTick(Tick:Int64;dTick:Int64):int64;

  const MaxCardinalValue = 4294967295;

implementation

// Получить разницу в тиках без учета переполнений счетчика
Function GetDeltaTick(Tick:Int64;dTick:Int64):int64;
var overflow:cardinal;
begin
  overflow:=1;
  result:=decTicks(Tick, dTick ,overflow);
  if overflow=0 then
  begin
    result:=-decTicks(dTick,Tick,overflow);
  end;
end;

Function AddTicks(Tick:cardinal;dTick:Int64;var overflow:cardinal):cardinal;
var delt:cardinal;
begin
  if dTick<0 then
  begin
    Result:=DecTicks(Tick,-dTick,overflow);
    exit;
  end;
  delt:=MaxCardinalValue-dTick;
  if Tick>delt then
  begin
    Result:=Tick-delt;
    overflow:=overflow+1;
  end
  else
    Result:=Tick+dTick;
end;

Function DecTicks(Tick:cardinal;dTick:Int64; var overflow:cardinal):cardinal;
var delt:cardinal;
begin
  if dTick<0 then
  begin
    Result:=AddTicks(Tick,-dTick,overflow);
    exit;
  end;
  if dTick>Tick then
  begin
    delt:=dTick-Tick;
    Result:=MaxCardinalValue - delt;
    overflow:=overflow-1;
  end
  else
  begin
    Result:=Tick-dTick;
  end;
end;

end.
