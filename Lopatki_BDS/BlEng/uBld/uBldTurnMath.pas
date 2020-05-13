// В модуле собраны процедуры и функции для обработки одиночного оборота
unit uBldTurnMath;

interface
uses
  uBldFile, math, umyTypes_, utickdata, uMyMath, classes;

// выбирает тики sensorind-ого датчика, пропуская skip лопаток и запоминая в trend
function EvalSkipBlades(pos:single;stage:cstage;blade:integer):integer;
// Посчитать где находится тик внутри диапазона start, end по одному обоб
function EvalTickPosInTurn(tick,tick1,tick2:stickdata;start,finish:single):single;
// посчитать где находится пик внутри диапазона start..finish, если сигнал taxo отсортирован
// и включена переменная sortedtaxo, будет происходить ускорение работы фенкции
// Функция вначале пересчитывает тики с учетом переполнений в секунды, вычисляет скорость
// внутри поворота и считает позицию тика внутри оборота. Функция менее точная чем следующая
// так как в ней нет потери точности из-за перевода в секунды
function EvalTickPos(tick:sTickData;start,finish:single;const taxo:cticks;
                     sortedtaxo,useAcseleration:boolean):single;
// посчитать где находится пик внутри диапазона start..finish, если сигнал taxo отсортирован
// и включена переменная sortedtaxo, будет происходить ускорение работы фенкции
function EvalTickPos_(tick:sTickData;start,finish:single;const taxo:cticks;
                      sortedtaxo,useAcseleration:boolean):single;
// Вычисляет путь в градусах который пройдет лопатка прежде
// чем появится импульс на датчике
function EvalBladePath(Bladepos,Sensorpos:single):single;
// Вычисляет число лопаток ступени
function EvalStageBladeCount(const taho:array of stickdata;
                             const sensorticks:array of stickdata;
                             Tahodivision:integer):integer;
// Вычислить форму ступени по одному обороту.
// Tick1, Tick2 - время начало и конца оборота.
// shape - форма колеса.
// sensorticks - массив тиков.
// skip - число лопаток которое надо пропустить чтобы на датчике появился импульс от 1-й лопатки
// Возвращает false если оборот сбойный (тик меньше тиков чем лопаток)
// Посчитанная форма складывается в масиив shape.points2[i].x
function EvalStageShapeByTurn(const tick1, tick2:sTickData;
                      const sensorticks:array of stickdata;
                      bladenumber:integer;
                      var shape:cpoints2):boolean;
// Вычисляет позицию лопатки внутри оборота в тиках по:
// положению лопатки на валу, амплитуде вибрации и скорости вращения вала
// (массив тиков тахо датчика)
function EvalBladePosTick(BladePos,SensorPos,Amplitude:single;Taho1,Taho2:sTickData):stickdata;


implementation

// Вычисляет позицию лопатки внутри оборота в тиках по:
// положению лопатки на валу, амплитуде вибрации и скорости вращения вала
// (массив тиков тахо датчика)
function EvalBladePosTick(BladePos,SensorPos,Amplitude:single;
                          Taho1, Taho2:stickdata):stickdata;
var
  i,j:integer;
  // dT - Время прохода 1-о градуса; A - путь проходимый датчиком; f - фаза
  Tturn,T0,dT:Cardinal;
  T:integer;
  A,phase:single;
  lOverflow:cardinal;
begin
  lOverflow:=1;
  Tturn:=decTicks(Taho2.Data, Taho1.Data, lOverflow);
  // время прохода одного градуса
  dT := trunc(Tturn/360);
  // путь проходимый датчиком в градусах
  a:=EvalBladePath(Bladepos,Sensorpos);
  // расчетное время прихода импульса + dT(вибрация)
  lOverflow:=Taho1.OverflowCount;
  // Расчетное время прихода = путь в градусах*t(1-о градуса)
  T0 :=AddTicks(Taho1.Data,trunc(dT*A),lOverflow);
  // T - значение разброса прихода лопатки
  T :=trunc(dT*Amplitude);
  Result.Data:=AddTicks(T0,T,lOverflow);
  Result.OverflowCount:=lOverflow;
end;
// вычислить число лопаток ступени
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
// Вычислить форму ступени по одному обороту.
// Tick1, Tick2 - время начало и конца оборота.
// shape - форма колеса.
// sensorticks - массив тиков.
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
    // Проверка что тик находится внутри оборота
    if not inTurn(sensorticks[i],tick1,tick2) then
      break;
    // номер импульса внутри оборота
    impulsind:=i-startind;
    // Расчет номера лопатки (нумерация идет с 0-я)
    if (impulsind)<bladenumber then
      bladeind:=impulsind
    else
      bladeind:=bladenumber-(impulsind);
    // Положение тика внутри оборота
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
  // путь проходимый датчиком в градусах
  if sensorpos<Bladepos then
     result:=360 - (Bladepos - sensorpos)
  else
     result:=sensorpos - Bladepos;
end;

// находит в массиве элемент справа от элемента с заданным x
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
  // Проверка граничных результатов
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
  // Определяем границы поиска в массиве
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

// вычисляет число лопаток? которое надо пропустить, чтобы зафиксировать
// первую лопатку датчиком находящимся в позиции pos
// blade - номер лопатки импульсы которой должны считаться
function EvalSkipBlades(pos:single;stage:cStage;blade:integer):integer;
var intpos:integer;
    count:integer; // число пропускаемых лопаток
begin
  // находим после какой лопатки стоит датчик
  intpos:=FindInDoubleArrayHiBound(stage.blades,pos);
  // вычисляем число лопаток которое надо пропускать
  if intpos>blade then
    result:=intpos - blade -1
  else
    result:=stage.bladenumber - blade + intpos -1;
end;
// Вычислить скорость внутри оборота
function EvalVelocity(start,finish:stickdata):single;
var t1,t2,dt:single;
begin
  // Время в секундах на момент первого тика
  t1:=CalcTime_(start);
  // Время в секундах на момент последнего тика
  t2:=CalcTime_(finish);
  dt:=t2-t1;
  result:=1/dt;
end;
// Вычислить ускорение внутри оборота. V1,V2 значения скоростей, t1,t2
// значения времени первого и второго оборота
//     v1:=1/(t2-t1)     v2:=1/(t3-t2)
//                     a:=(v2-v1)/(t3-t1)
// t1----------------t2------------------t3
function EvalAceleration(v1,v2:single;t1_,t2_:sTickData):single;
var t1,t2:single;
begin
  // Время в секундах на момент первого тика
  t1:=CalcTime_(t1_);
  // Время в секундах на момент последнего тика
  t2:=CalcTime_(t2_);
  result:=(v2-v1)/(t2-t1);
end;
// Вычислить позицию тика внетри оборота
function EvalTickPosinTurn(tick,tick1,tick2:stickdata;start,finish:single):single;
var tturn,dt:cardinal;
    d:single;
begin
  tturn:=DecTicks_(tick2,tick1);
  d:=finish - start;
  dt:=DecTicks_(tick,tick1);
  result:=(dt/tturn)*d + start;
end;
// посчитать где находится пик внутри диапазона start..finish, если сигнал taxo отсортирован
// и включена переменная sortedtaxo, будет происходить ускорение работы фенкции
// useAcseleration - использовать ускорение при расчетах (либо пренебречь)
function EvalTickPos(tick:sTickData;start,finish:single;const taxo:cticks;
                     sortedtaxo,useAcseleration:boolean):single;
var i,len:integer;
    round:single;
    a,v:single;//ускорение
    t1,t2,t:single;
begin
  len:=length(taxo.ticks);
  if sortedtaxo then
  begin
    i:=FindInTickArrayLowBound(taxo.ticks,tick);
  end
  else // вычисление i перебором
  begin

  end;
  round:=finish-start;
  if i<>0 then
  begin
    // Время в секундах на момент первого тика
    t1:=CalcTime_(taxo.ticks[i]);
    // Время в секундах на момент последнего тика
    t2:=CalcTime_(taxo.ticks[i-1]);
    t:=CalcTime_(tick);
    v:=1/(t1-t2); // в герцах
  end
  else
  begin
    t2:=CalcTime_(taxo.ticks[1]);
    t1:=CalcTime_(taxo.ticks[0]);
    t:=CalcTime_(tick);
    v:=1/(t2-t1); // в герцах
  end;
  // Вычисление скорости внутри оборота в градусах
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
  v:=round*v; // в единицах в которых round
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
  else // вычисление i перебором
  begin
  end;
  round:=finish-start;
  if i<>0 then
  begin
    // Время в секундах на момент первого тика
    t2:=taxo.ticks[i].Data;
    // Время в секундах на момент последнего тика
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
