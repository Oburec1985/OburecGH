unit uMyMath;

interface
  uses ucommontypes, sysutils, math, uSetList, uSimpleSetList
  //,generics.collections, Generics.Defaults
  ;
type
  tmathstats=record
    m:double;
    a:double;
    sum:double;
    min:double;
    max:double;
  end;

  dArray = array of double;

// a,b,c - коэффициенты уравнения
//  x1,x2 - корни уравнения
//  ok = True  - решение есть
//  ok = False - решения нет
// Решает квадратное уравнение
Function SqRoot(a, b, c: real;var rootcount: integer):point2;
// находит в массиве элемент слева от элемента с заданным x
function FindInFloatArrayLowBound(const a:array of single;x:single;from,toind:integer):integer;
// находит в массиве элемент справа от элемента с заданным x
function FindInFloatArrayHiBound(const a:array of single;x:single;from,toind:integer):integer;
// находит в массиве элемент слева от элемента с заданным x
function FindInDoubleArrayLowBound(const a:array of real;x:real):integer;
// находит в массиве элемент справа от элемента с заданным x
function FindInDoubleArrayHiBound(const a:array of real;x:real):integer;
function FindInDPointsArrayLowBound(const a:array of point2d;x:double;from,toind:integer):integer;
function FindInDPointsArrayHiBound(const a:array of point2d;x:double;from,toind:integer):integer;

function FindInPointsArrayLowBound(const a:array of point2;x:single;from,toind:integer):integer;
function FindInPointsArrayHiBound(const a:array of point2;x:single;from,toind:integer):integer;
// Математически верное округление числа
Function MathRound(val:single):integer;
// Оставить sign знаков после запятой
function TruncFloatNumString(val:string;sign:integer):string;
// Округление
function RounTo(v:single;sign:integer):single;
// Вернуть строку от округленного числа
function GetRoundNumString(val:single;sign:integer):string;
// Медианная фильтрация одномерного сигнала
// thereshold: порог; i1,i2 диапазон на котором производится фильтрация
function MeedleFilter(var F:array of single;i1,i2,order:integer; thereshold:single):boolean;
// true если четное
function mod2(v:integer):boolean;
// расчет мат ожидания
function GetM(var a1:array of single):single;overload;
// дисперсия ищется по y-ам
function GetM(var a2:array of point2):single;overload;
function GetMd(var a1:array of double):double;overload;
function GetMd(var a2:array of point2d):double;overload;
// расчет дисперсии
function GetDisp(var a1:array of single):single;overload;
function GetDisp(var a1:array of point2):single;overload;
function GetDispd(var a1:array of double):double;overload;

function GetSKOd(var a1:array of double):double;overload;
function GetSKOd(var a1:array of double; startind:integer):double;overload;

function GetDispd(var a1:array of point2d):double;overload;
function GetSqrtDisp(var a1:array of single):single;
// расчет ковариации sum( (Xi-mx)(Yi-my) )/length
function GetCov(var a1:array of single;var a2:array of single):single;
// коеффициент корреляции пирсона
// Cov(a1,a2)/(sqrt(D(a1))*sqrt(D(a2)))
function getCorr(var a1:array of single;var a2:array of single):single;
function GetStats(var a1:array of double; startind,endind:integer):tmathstats;

implementation

Function MathRound(val:single):integer;
var val1,val2:integer;
begin
  val1:=round(val);
  val2:=val1 - 1;
  if abs(val-val1)<abs(val-val-1) then
    result:=val1
  else
    result:=val2;
end;

Function SqRoot(a, b, c: real;var rootcount: integer):point2;
var
  d,sqrtd: real; // дискриминант
  p2:point2;
begin
  if a=0 then
  begin
    result.x:=-c/b;
    rootcount:=1;
    exit;
  end;
  d := Sqr(b) - 4 * a * c;
  if d < 0 then
    rootcount := 0 // уравнение не имеет решения
  else
  begin
    sqrtd:=Sqrt(d);
    if sqrt(d)=0 then
      rootcount:=1
    else
      rootcount := 2;
    p2.x := (-b + sqrtd) / (2 * a);
    p2.y := (-b - sqrtd) / (2 * a);
  end;
  Result:=p2;
end;

// находит в массиве элемент слева от элемента с заданным x
function FindInFloatArrayLowBound(const a:array of single;x:single;from,toind:integer):integer;
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
  if toind>=Length(a) then
    len:=Length(a)
  else
    len:=toind;
  // Определяем границы поиска в массиве
  left:=from;
  right:=len-1;
  // Проверка граничных результатов
  if a[len-1]<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0]>x then
  begin
    result:=0;
    exit;
  end;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a[curind]>x then
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
  if a[curind]>x then
    result:=curind-1
  else
    result:=curind;
end;
// находит в массиве элемент справа от элемента с заданным x
function FindInFloatArrayHiBound(const a:array of single;x:single;from,toind:integer):integer;
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
  if toind>=Length(a) then
    len:=Length(a)
  else
    len:=toind;
  // Определяем границы поиска в массиве
  left:=from;
  right:=len-1;
  // Проверка граничных результатов
  if a[len-1]<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0]>x then
  begin
    result:=0;
    exit;
  end;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a[curind]>x then
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
  if a[curind]>x then
    result:=curind
  else
    result:=curind+1;
end;

// находит в массиве элемент слева от элемента с заданным x
function FindInDoubleArrayLowBound(const a:array of real;x:real):integer;
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
  if a[len-1]<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0]>x then
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
    if a[curind]>x then
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
  if a[curind]>x then
    result:=curind-1
  else
    result:=curind;
end;
// находит в массиве элемент справа от элемента с заданным x
function FindInDoubleArrayHiBound(const a:array of real;x:real):integer;
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
  if a[len-1]<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0]>x then
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
    if a[curind]>x then
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
  if a[curind]>x then
    result:=curind
  else
    result:=curind+1;
end;

function FindInDPointsArrayLowBound(const a:array of point2d;x:double;from,toind:integer):integer;
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
  if toind>=Length(a) then
    len:=Length(a)
  else
    len:=toind;
  // Определяем границы поиска в массиве
  left:=from;
  right:=len-1;
  // Проверка граничных результатов
  if a[len-1].x<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0].x>x then
  begin
    result:=0;
    exit;
  end;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a[curind].x>x then
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
  if a[curind].x>x then
    result:=curind-1
  else
    result:=curind;
end;

function FindInDPointsArrayHiBound(const a:array of point2d;x:double;from,toind:integer):integer;
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
  if toind>=Length(a) then
    len:=Length(a)
  else
    len:=toind;
  // Проверка граничных результатов
  if a[len-1].x<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0].x>x then
  begin
    result:=0;
    exit;
  end;
  // Определяем границы поиска в массиве
  left:=from;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a[curind].x>x then
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
  if a[curind].x>x then
    result:=curind
  else
    result:=curind+1;
end;

// находит в массиве элемент слева от элемента с заданным x
function FindInPointsArrayLowBound(const a:array of point2;x:single;from,toind:integer):integer;
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
  if toind>=Length(a) then
    len:=Length(a)
  else
    len:=toind;
  // Определяем границы поиска в массиве
  left:=from;
  right:=len-1;
  // Проверка граничных результатов
  if a[len-1].x<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0].x>x then
  begin
    result:=0;
    exit;
  end;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a[curind].x>x then
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
  if a[curind].x>x then
    result:=curind-1
  else
    result:=curind;
end;
// находит в массиве элемент справа от элемента с заданным x
function FindInPointsArrayHiBound(const a:array of point2;x:single;from,toind:integer):integer;
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
  if toind>=Length(a) then
    len:=Length(a)
  else
    len:=toind;
  // Проверка граничных результатов
  if a[len-1].x<x then
  begin
    result:=len-1;
    exit;
  end;
  if a[0].x>x then
  begin
    result:=0;
    exit;
  end;
  // Определяем границы поиска в массиве
  left:=from;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a[curind].x>x then
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
  if a[curind].x>x then
    result:=curind
  else
    result:=curind+1;
end;

function GetRoundNumString(val:single;sign:integer):string;
begin
  val:=RounTo(val,sign);
  result:=TruncFloatNumString(floattostr(val),sign);
end;

function TruncFloatNumString(val:string;sign:integer):string;
var pos, // позичия разделителя
    fraclen,i,len:integer;
    fv:single;
begin
  len:=length(val);
  pos:=-1;
  for i:=(len-1) downto 1 do
  begin
    if (val[i]='.') or (val[i]=',') then
    begin
      pos:=i;
      break;
    end;
  end;
  fraclen:=len-pos;
  if pos=-1 then
  begin
    result:=val;
  end
  else
  begin
    if fraclen>sign then
    begin
      len:=pos + sign;
      setlength(val, len);
      result:=val;
    end
    else
      result:=val;
  end;
end;

function RounTo(v:single;sign:integer):single;
var i:integer;
begin
  // Округление
    for i := 0 to sign - 1 do
    begin
      v:=v*10;
    end;
    v:=round(v);
    for i := 0 to sign - 1 do
    begin
      v:=v/10;
    end;
    result:=v;
end;

function MeedleFilter(var F:array of single;i1,i2,order:integer; thereshold:single):boolean;
var
  I, curind: Integer;
  a:cFloatSetList;
  mid:single;
begin
  a:=cFloatSetList.create;
  curind:=i1;
  for I := curind to order do
  begin
    a.Add(f[i-curind]);
  end;
//  mid:=a.getsingle(order/2-1);
  if mod2(order) then
//    mid:=(mid+a.getsingle(order/2))/2;
end;

function mod2(v:integer):boolean;
begin
  result:=not ((v mod 2) > 0);
end;

function GetM(var a2:array of point2):single;
var
  I,len:integer;
begin
  result:=0;
  len:=length(a2);
  for I := 0 to len - 1 do
  begin
    result:=a2[i].y+result;
  end;
  result:=result/len;
end;

function GetM(var a1:array of single):single;
var
  I,len:integer;
begin
  result:=0;
  len:=length(a1);
  for I := 0 to len - 1 do
  begin
    result:=a1[i]+result;
  end;
  result:=result/len;
end;



function GetMd(var a2:array of point2d):double;
var
  I,len:integer;
begin
  result:=0;
  len:=length(a2);
  for I := 0 to len - 1 do
  begin
    result:=a2[i].y+result;
  end;
  result:=result/len;
end;

function GetMd(var a1:array of double):double;
var
  I,len:integer;
begin
  result:=0;
  len:=length(a1);
  result:=Sum(a1);
  //for I := 0 to len - 1 do
  //begin
  //  result:=a1[i]+result;
  //end;
  result:=result/len;
end;

procedure MeanAndStdDev(const Data: array of Double; i1,i2:integer; var Mean, StdDev: Extended);
var
  S: Extended;
  N,I: Integer;
begin
  N := High(Data)- Low(Data) + 1;
  if N = 1 then
  begin
    Mean := Data[0];
    StdDev := Data[0];
    Exit;
  end;
  Mean := Sum(Data) / N;
  S := 0;               // sum differences from the mean, for greater accuracy
  for I := Low(Data) to High(Data) do
    S := S + Sqr(Mean - Data[I]);
  StdDev := Sqrt(S / (N - 1));
end;

function GetStats(var a1:array of double; startind,endind:integer):tmathstats;
var
  I,len:integer;
begin
  result.m:=0;
  result.a:=0;
  result.min:=0;
  result.max:=0;
  result.sum:=0;
  len:=length(a1);
  for I := startind to endind do
  begin
    if result.min>a1[i] then
      result.min:=a1[i];
    if result.max<a1[i] then
      result.max:=a1[i];
    result.sum:=a1[i]+result.sum;
  end;
  result.m:=result.sum/len;
  result.a:=(result.max-result.min)/2;
end;

function GetDisp(var a1:array of single):single;
var
  I,len:integer;
  d,m:single;
begin
  m:=getm(a1);
  len:=length(a1);
  result:=0;
  for I := 0 to len - 1 do
  begin
    d:=(a1[i]-m);
    result:=d*d+result;
  end;
  result:=result/len;
end;

function GetDisp(var a1:array of point2):single;
var
  I,len:integer;
  d,m:single;
begin
  m:=getm(a1);
  len:=length(a1);
  result:=0;
  for I := 0 to len - 1 do
  begin
    d:=(a1[i].y-m);
    result:=d*d+result;
  end;
  result:=result/len;
end;

function GetSKOd(var a1:array of double):double;overload;
begin
  result:=sqrt(GetDispd(a1));
end;

function GetSKOd(var a1:array of double; startind:integer):double;overload;
var
  I,len, l:integer;
  d,m:single;
  darr:dArray;
begin
  l:=length(a1);
  len:=l-startind;
  darr:=dArray(@a1[startind]);
  m:=Sum(darr)/len;
  for I:= startind to l - 1 do
  begin
    d:=(a1[i]-m);
    result:=d*d+result;
  end;
  result:=result/len;
end;


function GetDispd(var a1:array of double):double;
var
  I,len:integer;
  d,m:double;
begin
  m:=getmd(a1);
  len:=length(a1);
  result:=0;
  for I := 0 to len - 1 do
  begin
    d:=(a1[i]-m);
    result:=d*d+result;
  end;
  result:=result/len;
end;

function GetDispd(var a1:array of point2d):double;
var
  I,len:integer;
  d,m:double;
begin
  m:=getmd(a1);
  len:=length(a1);
  result:=0;
  for I := 0 to len - 1 do
  begin
    d:=(a1[i].y-m);
    result:=d*d+result;
  end;
  result:=result/len;
end;

function GetSqrtDisp(var a1:array of single):single;
var
  I,len:integer;
  d,m:single;
begin
  m:=getm(a1);
  len:=length(a1);
  result:=0;
  for I := 0 to len - 1 do
  begin
    d:=(a1[i]-m);
    result:=d+result;
  end;
  result:=result/sqrt(len);
end;

function GetCov(var a1:array of single;var a2:array of single):single;
var
  len,i:integer;
  m1,m2:single;
begin
  len:=length(a1);
  m1:=getM(a1);
  m2:=getM(a2);
  result:=0;
  for I := 0 to len - 1 do
  begin
    result:=(a1[i]-m1)*(a2[i]-m2)+result;
  end;
  result:=result/len;
end;

function getCorr(var a1:array of single;var a2:array of single):single;
var
  cov, d1, d2:single;
  //ar1,ar2:array[0..9] of single;
  //i: Integer;
begin
  {for i := 0 to 9 do
  begin
    ar1[i]:=1;
    ar2[i]:=2;
  end;
  ar1[3]:=ar1[3]+1;
  ar2[3]:=ar2[3]+1;
  cov:=GetCov(ar1,ar2);
  d1:=getdisp(ar1);
  d2:=getdisp(ar2);
  result:=cov/(sqrt(d1)*sqrt(d2));}

  cov:=GetCov(a1,a2);
  d1:=getdisp(a1);
  d2:=getdisp(a2);
  result:=cov/(sqrt(d1)*sqrt(d2));
  //result:=cov/sqrt(d1)*sqrt(d2);
end;

end.
