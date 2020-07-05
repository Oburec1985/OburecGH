unit uComplex;


interface
uses
 SysUtils,Math;

 const
   MinComplex = 5.0e-324;
   MaxComplex = 1.7e+308;
 Type
   PComplex =^TComplex;
   TComplex = record
     Re,
     Im:Double;
   end;// TComplex = record
   TCmxArray = array of TComplex;function GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False):TCmxArray;implementation{------------------------------------------------------------------------------function GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False): TCmxArray;
  Вернет таблицу Exp множителей для FFT анализа. (Комплексных)
  CountFFTPoints - число точек для FFT Анализа.
  InverseFFT - Если True, то множители нужны для обратного БПФ,
  иначе для прямого.
  Пример:
  CountFFTPoints = 32
  CountBlock = 5+1, а именно [0][1][2..3][4..7][8..15][16..31]
  Len = 32
  После чего заполняем каждый блок множителями для БПФ, начиная с блока [1]
  Result (Массив) будет выглядеть так:
  [0][1][2..3][4..7][8..15][16..31]
   | | | | | |
   | | | | | |--- для сшивания блоков длинной = 16
   | | | | |
   | | | | |---------- для сшивания блоков длинной = 8
   | | | |
   | | | |---------------- для сшивания блоков длинной = 4
   | | |
   | | |---------------------- для сшивания блоков длинной = 2
   | |
   | |--------------------------- для сшивания блоков длинной = 1
   |
   |------------------------------ не используется, необходим для выравнивания
   а именно, если знаем, что нужно сшить блоки длинной 16 (блоков всегда два),
   то и exp множители лежат в массиве начиная с номера = 16, и так как блок имеет
   длину 16, множителей тоже 16 !. прям полная идилия :)}function GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False):TCmxArray;
var
  I,StartIndex,N,LenB:Integer;
  w,wn:TComplex;
  Mnogitel:Double;
begin
  Mnogitel := -2*Pi; //Прямое БПФ
  if InverseFFT then
    Mnogitel:= 2*Pi; //Обратное БПФ
  SetLength(Result,CountFFTPoints);
  LenB:=1;
  while LenB <CountFFTPoints do //Пробегаем каждый блок.
  begin
    N := LenB; //поучаем число элементов в блоке
    LenB := LenB shl 1;    //Готовим первый EXP множитель(корень) для БПФ.    wn.Re := 0;
    wn.Im := Mnogitel/LenB;
    wn := exp(wn);
    w := 1;
    StartIndex:=N; //Стартовый индекс в массиве.
    Dec(N); //Т.к индексация с нуля
    For I:=0 to N do //заполняем блок exp множителями для БПФ, в массиве
    begin
      Result[StartIndex+I]:=w;
      w:=w*wn;
    end;
  end;
end;

{------------------------------------------------------------------------------function GetArrayIndex(CountPoint: Integer;MinIteration: Integer): TIndexArray;
Вернет массив длиной CountPoint из чисел(индексов) от 0 до CountPoint-1.
Этот массив будет содержать в себе индексы, в той последовательности, которая
необходима при самой нижней итерации при работе с БПФ. Индексы для того, чтобы
правильно расположить дискретные данные для БПФ.
Проводить перестановку будем согласно значению MinIteration..
Этот массив позволит перемешивать массив дискретных данных один раз,
а не при каждом вызове fft функции..
См более детально в доках по БПФ прореживание по времени}
function GetArrayIndex(CountPoint: Integer; MinIteration: Integer):TIndexArray;
Var I,LenBlock,HalfBlock,HalfBlock_1,
 StartIndex,EndIndex,ChIndex,NChIndex :Integer;
 TempArray:TIndexArray;
begin
 EndIndex:=CountPoint-1;
 SetLength(Result,CountPoint);
 For I:=0 to EndIndex do //Располагаем индексы по порядку
 Result[I]:=I;
 LenBlock :=CountPoint;
 HalfBlock :=LenBlock shr 1;
40
 HalfBlock_1:=HalfBlock -1;
 while LenBlock > MinIteration do //переставляем индексы в блоках длинной
LenBlock
 begin
 StartIndex:=0; //начинаем с крайнего левого блока
 TempArray :=Copy(Result,0,CountPoint);
 repeat //переставляем индексы в конкретном(начало блока =StartIndex)
 блоке длинной LenBlock
 ChIndex :=StartIndex;
 NChIndex:=ChIndex+1;
 EndIndex:=StartIndex+HalfBlock_1;
 //Выделяем четные и нечетные индексы и помещаем обратно в исходный
 //массив
 for I:=StartIndex to EndIndex do
 begin
 Result[I] :=TempArray[ChIndex];
 Result[I+HalfBlock]:=TempArray[NChIndex];
 ChIndex :=ChIndex +2;
 NChIndex:=NChIndex+2;
 end;
 StartIndex:=StartIndex+LenBlock; //переходим к другому блоку
 Until StartIndex >= CountPoint; //если дошли до длины массива,
 //значит блоков больше нет.
 //уменьшаем длину блок, пока не дойдем до минимального размера (MinIteration)
 LenBlock :=LenBlock shr 1;
 HalfBlock :=LenBlock shr 1;
 HalfBlock_1:=HalfBlock - 1;
 end;
 TempArray:=Nil;
end;
end.
