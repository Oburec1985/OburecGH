unit Iterative_FFT_nu;

{$H+}

interface

uses
  Classes, SysUtils, complex;



  function  GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False):TCmxArray_d;
  function  GetArrayIndex(CountPoint: Integer;MinIteration: Integer):TIndexArray;
  Procedure NormalizeFFTSpectr(var FFTArray:TCmxArray_d); Inline;overload;
  Procedure NormalizeFFTSpectr(var FFTArray:TCmxArray_d; Mnogitel:Double);overload;

  Procedure FFT_iter_nu(var D:TCmxArray_d; const TableExp:TCmxArray_d);
  Procedure iFFT(var D:TCmxArray_d; const TableExp:TCmxArray_d);



implementation

{-------------------------------------------------------------------------------
function GetFFTExpTable(CountFFTPoints:Integer;
                        InverseFFT:Boolean=False): TCmxArray;

Вернет таблицу Exp множителей для FFT анализа. (Комплексных)
CountFFTPoints - число точек для FFT Анализа.
InverseFFT     - Если True, то множители нужны для обратного БПФ,
                 иначе для прямого.


Пример:
CountFFTPoints = 32
CountBlock     = 5+1, а именно [0][1][2..3][4..7][8..15][16..31]
Len            = 32

После чего заполняем каждый блок множителями для БПФ, начиная с блока [1]
Result (Массив) будет выглядеть так:
[0][1][2..3][4..7][8..15][16..31]
 |  |    |     |     |      |
 |  |    |     |     |      |--- для сшивания блоков длинной = 16
 |  |    |     |     |
 |  |    |     |     |---------- для сшивания блоков длинной = 8
 |  |    |     |
 |  |    |     |---------------- для сшивания блоков длинной = 4
 |  |    |
 |  |    |---------------------- для сшивания блоков длинной = 2
 |  |
 |  |--------------------------- для сшивания блоков длинной = 1
 |
 |------------------------------ не используется, необходим для выравнивания

 а именно, если знаем, что нужно сшить блоки длинной 16 (блоков всегда два),
 то и exp множители лежат в массиве начиная с номера = 16, и так как блок имеет
 длину 16, множителей тоже 16 !. прям полная идилия :)}
function GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False): TCmxArray_d;
var I,StartIndex,N,LenB:Integer;
    w,wn:TComplex_d;
    Mnogitel:Double;
begin

  Mnogitel := -2*Pi;               //Прямое  БПФ

  if InverseFFT then
     Mnogitel:= 2*Pi;              //Обратное  БПФ


  SetLength(Result,CountFFTPoints);

  LenB:=1;

  while LenB <CountFFTPoints do //Пробегаем каждый блок.
    begin
      N     := LenB;      //поучаем число элементов в блоке
      LenB  := LenB shl 1;

      //Готовим первый EXP множитель(корень) для БПФ.
      wn.Re := 0;
      wn.Im := Mnogitel/LenB;
      wn    := exp(wn);
      w     := 1;

      StartIndex:=N;    //Стартовый индекс в массиве.
      Dec(N);           //Т.к индексация с нуля
      For I:=0 to N do  //заполняем блок exp множителями для БПФ, в массиве
        begin
          Result[StartIndex+I]:=w;
          w:=w*wn;
        end;
    end;
end;

{-------------------------------------------------------------------------------
function GetArrayIndex(CountPoint: Integer;MinIteration: Integer): TIndexArray;
Вернет массив длиной CountPoint из чисел(индексов) от 0 до CountPoint-1.
Этот массив будет содержать в себе индексы, в той последовательности, которая
необходима при самой нижней итерации при работе с БПФ. Индексы для того, чтобы
правильно расположить дискретные данные для БПФ.

Проводить перестановку будем согласно значению MinIteration.. 
Этот массив позволит перемешивать массив дискретных данных один раз,
а не при каждом вызове fft функции.. 
См более детально в доках по БПФ прореживание по времени}
function GetArrayIndex(CountPoint: Integer; MinIteration: Integer): TIndexArray;
Var I,LenBlock,HalfBlock,HalfBlock_1,
    StartIndex,EndIndex,ChIndex,NChIndex :Integer;
    TempArray:TIndexArray;
begin

  EndIndex:=CountPoint-1;

  SetLength(Result,CountPoint);
    For I:=0 to EndIndex do           //Располагаем индексы по порядку
      Result[I]:=I;


  LenBlock   :=CountPoint;
  HalfBlock  :=LenBlock shr 1;
  HalfBlock_1:=HalfBlock -1;


  while LenBlock > MinIteration do    //переставляем индексы в блоках длинной  LenBlock
    begin
      StartIndex:=0;                  //начинаем с крайнего левого блока
      TempArray :=Copy(Result,0,CountPoint);

      repeat //переставляем индексы в конкретном(начало блока =StartIndex) блоке длинной  LenBlock
        ChIndex :=StartIndex;
        NChIndex:=ChIndex+1;
        EndIndex:=StartIndex+HalfBlock_1;

        //Выделяем четные и нечетные индексы и помещаем обратно в исходный массив
        for I:=StartIndex to EndIndex do
          begin
            Result[I]          :=TempArray[ChIndex];
            Result[I+HalfBlock]:=TempArray[NChIndex];

            ChIndex :=ChIndex +2;
            NChIndex:=NChIndex+2;
          end;

        StartIndex:=StartIndex+LenBlock;   //переходим к другому блоку
      Until StartIndex >= CountPoint;      //если дошли до длины массива, значит блоков больше нет.

      //уменьшаем длину блок, пока не дойдем до минимального размера (MinIteration)
      LenBlock   :=LenBlock shr 1;
      HalfBlock  :=LenBlock shr 1;
      HalfBlock_1:=HalfBlock -  1;
    end;


  TempArray:=Nil;
end;


{-------------------------------------------------------------------------------
procedure FFT(var D: TCmxArray; const TableExp: TCmxArray);

Итеративный метод БПФ (прореживание по времени), над данными D,
которые должны быть расположены согласно нижней итерации БПФ,
для этого есть проц GetArrayIndex, которая вернет массив, в котором расположены
индексы 0..Length(D), в той последовательности которая нужна.
В нашем случае в процедуру  GetArrayIndex нужно передать MinIteration = 2

TableExp - массив Exp множителей для БПФ, созданный GetFFTExpTable
После отработки, массив D, будет содержать БПФ входного массива D
Т.е преобразование проходит на месте, без создания копий}
procedure FFT_iter_nu(var D: TCmxArray_d; const TableExp: TCmxArray_d);
var
    I,J,NChIndex,TableExpIndex,Len,StartIndex,LenBlock,HalfBlock:Integer;
    TempBn,D0:TComplex_d;
begin

  Len          := Length(D);
  LenBlock     := 2;
  HalfBlock    := 1;

  While LenBlock <= Len do //Пробегаем блоки от 2 до  Len
    begin
      I:=0;
      NChIndex  := HalfBlock;
      StartIndex:= 0;

      TableExpIndex := HalfBlock;
      Dec(HalfBlock);

      while I<Len do  //Пробегаем блоки
        begin

          for J:=0 to HalfBlock do //Работаем в конкретном блоке
            begin
              //(Бабочка БПФ)
              TempBn        :=D[NChIndex]*TableExp[TableExpIndex+J];
              D0            :=D[StartIndex];
              D[StartIndex] :=D0+TempBn;
              D[NChIndex]   :=D0-TempBn;

              Inc(NChIndex);
              Inc(StartIndex);
            end;

          I         := I + LenBlock;
          NChIndex  := I + HalfBlock+1;
          StartIndex:= I;
        end;

      HalfBlock := LenBlock;
      LenBlock  := LenBlock shl 1;
    end;
end;

{-------------------------------------------------------------------------------
procedure iFFT(var D: TCmxArray; const TableExp: TCmxArray);

Обратное преобразование БПФ (прореживание по времени), над данными D,
которые должны быть расположены согласно нижней итерации БПФ,
для этого есть проц GetArrayIndex, которая вернет массив, в котором расположены
индексы 0..Length(D), в той последовательности которая нужна.
В нашем случае в процедуру  GetArrayIndex нужно передать MinIteration = 2

Нормализация имеет вид:  D[Index].Re:=D[Index].Re/Length(D);

TableExp - массив Exp множителей для обратного БПФ, созданный GetFFTExpTable,
с указанием  InverseFFT=True
После отработки, массив D, будет содержать первоначальные (восстановленные)
данные (сигнал)
Т.е преобразование проходит на месте, без создания копий}
procedure iFFT(var D: TCmxArray_d; const TableExp: TCmxArray_d);
var I,Len,N:Integer;
begin
  Len:=Length(D);

  FFT_iter_nu(D,TableExp);

  N:=Len;
  Dec(Len);
  For I:=0 to Len do
    D[I].Re:=D[I].Re/N;
end;

{-------------------------------------------------------------------------------
procedure  NormalizeFFTSpectr(var FFTArray: TCmxArray);
Процедура стандартной нормализации (выделение амплитуды)
яв-ся интерфейсом для вызова функции 
NormalizeFFTSpectr(var FFTArray: TCmxArray; Mnogitel: Double);

Нормализация имеет вид:  FFTArray[I].Re:=abs(FFTArray[I])/(N/2);
что соответствует, выделению амплитуды сигнала...

Например в MathCad идет нормализация на 1/sqrt(N),
что не яв-ся амплитудой сигнала.
Где N = Length(FFTArray)}
procedure NormalizeFFTSpectr(var FFTArray: TCmxArray_d);
begin
   NormalizeFFTSpectr(FFTArray, 2/Length(FFTArray));
end;


{-------------------------------------------------------------------------------
procedure NormalizeFFTSpectr(var FFTArray: TCmxArray; Mnogitel: Double);

Процедура Нормализации вектора данных, полученных при помощи БПФ,
после обработки массив будет иметь только реальные значения в первой половине
, вторая половина массива не обрабатывается она яв-ся зеркальным
отражением первой половины массива FFTArray.

Нормализация имеет вид:  FFTArray[I].Re:=abs(FFTArray[I])*Mnogitel;
что дает возможность менять множитель и проводить нужную нормализацию}
procedure NormalizeFFTSpectr(var FFTArray: TCmxArray_d; Mnogitel: Double);
var I,Len:Integer;
begin
    Len:= Length(FFTArray);
    Len:= Len shr 1;       //Len := Len/2;
    Dec(Len);              //т.к индексация с нуля

    For I:=0 to Len do
      FFTArray[I].Re:=abs(FFTArray[I])*Mnogitel;

end;

end.
