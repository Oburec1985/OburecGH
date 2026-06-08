unit recursive_sse2_sse3_d_al_fft;

{$H+}

interface

uses
  Classes, SysUtils,complex;

  const
     shl4TComplex_s  = 3;  // {2^shl4TComplex = SizeOf(TComplex)}
     shl4TComplex_d  = 4;  // {2^shl4TComplex = SizeOf(TComplex)}

  function  GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False):TCmxArray_d;
  function  GetArrayIndex(CountPoint: Integer;MinIteration: Integer):TIndexArray;
  Procedure NormalizeFFTSpectr(var FFTArray:TCmxArray_d); Inline;overload;
  Procedure NormalizeFFTSpectr(var FFTArray:TCmxArray_d; Mnogitel:Double);register; assembler;overload;

  Procedure _fft(var D:TCmxArray_d; StartIndex,ALen:Integer; const TableExp:TCmxArray_d); register; assembler;

  Procedure FFT(var D:TCmxArray_d; const TableExp:TCmxArray_d); Inline;
  Procedure iFFT(var D:TCmxArray_d; const TableExp:TCmxArray_d); register; assembler;

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
procedure _fft(var D: TCmxArray; StartIndex, ALen: Integer;
               const TableExp:TCmxArray);

Рекурсивный метод БПФ (прореживание по времени), над данными D,
которые должны быть расположены согласно нижней итерации БПФ,
для этого есть проц GetArrayIndex, которая вернет массив, в котором расположены
индексы 0..Length(D), в той последовательности которая нужна.
В нашем случае в процедуру  GetArrayIndex нужно передать MinIteration = 2

StartIndex - должен при первом входе равняться 0 (нулю)
ALen       - Должна быть равна Length(D)
TableExp   - массив Exp множителей для БПФ, созданный GetFFTExpTable

После отработки, массив D, будет содержать БПФ входного массива D
Т.е преобразование проходит на месте, без создания копий}
procedure _fft(var D:TCmxArray_d; StartIndex,ALen:Integer;
               const TableExp:TCmxArray_d); register; assembler;

  asm
    push  EAX
    push  EBX

    cmp   ALen,2
    jnz   @ALenIsNot2           //Если Alen<>2 то продолжаем расчет
                                //Иначе дошли до минимальной итерации в рекурсии
    mov   EBX,EDX               //EBX = StartIndex

    //####################    Предел Рекурсии        ----------- Begin ---------
    //          D[StartIndex]   :=D[StartIndex]+D[StartIndex+1];
    //          D[StartIndex+1] :=D[StartIndex]-D[StartIndex+1];
    //----------------------------------------------------------------- 
    mov   EAX,[EAX]             //EAX   :=  @D[0]
    shl   EBX,shl4TComplex_d      //Смещение D[StartIndex] от-но D[0];
    add   EAX,EBX               //EAX   :=  @D[StartIndex]
    mov   EBX,EAX               //EBX   :=  @D[StartIndex]
    //add   EBX,SizeOf(TComplex)//EBX   :=  @D[StartIndex+1]
    add   EBX,16                //EBX   :=  @D[StartIndex+1]

    MOVaPD  xmm0,  [EAX]        //xmm0 :=  D[StartIndex]
    MOVaPD  xmm1,  xmm0         //xmm1 :=  D[StartIndex]
    MOVaPD  xmm2,  [EBX]        //xmm2 :=  D[StartIndex+1]
    ADDPD   xmm0,  xmm2         //xmm0 :=  D[StartIndex] + D[StartIndex+1]
    SUBPD   xmm1,  xmm2         //xmm1 :=  D[StartIndex] - D[StartIndex+1]
    MOVaPD  [EAX], xmm0
    MOVaPD  [EBX], xmm1

    jmp   @Exit                 //расчитали предельный случай выходим (exit)
    //####################       Предел Рекурсии        --------- END   --------



  @ALenIsNot2:
    push  ECX                   //Сохраняем ALen на стеке
    push  EDX                   //Сохраняем StartIndex на стеке
    mov   EBX,EDX               //EBX = StartIndex (StartIndex - на момент
                                //входа в процедуру)

    //-------вызов функции FFT2(D,StartIndex,ALen,TableExp) ----- begin --------
    shr   ECX,1                 //ALen:=ALen shr 1;
    push  DWord ptr TableExp
    call  _fft                  //Вызываем _fft = Рекурсия БПФ,
                                //для первой половины данных
    //-------вызов функции FFT2(D,StartIndex,ALen,TableExp) ----- End ----------


    //-------вызов функции FFT2(D,StartIndex,ALen,TableExp) ----- begin --------
    //На данный момент в ECX уже хранится  ALen shr 1; см чуть выше
    add   EDX,ECX               //EDX := StartIndex:=StartIndex+ALen
    push  DWord ptr TableExp
    call  _fft                  //Вызываем _fft = Рекурсия БПФ,
                                //для второй половины данных
    //-------вызов функции FFT2(D,StartIndex,ALen,TableExp) ----- End  ---------


    shl   EBX,shl4TComplex_d      //Смещение для D[StartIndex]; EBX = StartIndex
    mov   EAX,[EAX]             //EAX      := @D[0]
    shl   EDX,shl4TComplex_d      //Смещение для D[NChIndex] (EDX=StartIndex+ALen)
    add   EDX,EAX               //EDX      := @D[NChIndex]
    add   EAX,EBX               //EAX      := @D[StartIndex]

    mov   EBX,ECX               //EBX  := TableExpIndex = ALen
    shl   EBX,shl4TComplex_d      //Смещение для TableExp[TableExpIndex];
    add   EBX,TableExp          //EBX :=  @TableExp[TableExpIndex];


    //####################  цикл расчета бабочки БПФ  --------- Begin ----------
  @ButterflyFFT:            //ECX содержит число повторений цикла

    //--------------------  Начали расчет  TempBn -----------------------
    //           TempBn  := D[NChIndex]*TableExp[TableExpIndex]
    // Обозначим: L = D[NChIndex];   R = TableExp[TableExpIndex]
    //-------------------------------------------------------------------
    MOVaPD    xmm0, [EDX]       //xmm0 = [L.Re, L.Im]
    MOVDDUP   xmm1, [EBX]       //xmm1 = [R.Re, R.Re]
    MOVDDUP   xmm2, [EBX+8]     //xmm2 = [R.Im, R.Im]
    MULPD     xmm2, xmm0        //xmm2 = [L.Re*R.Im, L.Im*R.Im]
    MULPD     xmm1, xmm0        //xmm1 = [L.Re*R.Re, L.Im*R.Re]
    SHUFPD    xmm2, xmm2, 1     //xmm2 = [L.Im*R.Im, L.Re*R.Im]
    ADDSUBPD  xmm1, xmm2        //xmm1 = [L.Re*R.Re-L.Im*R.Im; L.Im*R.Re+L.Re*R.Im]
    //--------------------- Закончили  Расчет TempBn --------------------


    //--------------------  Бабочка БПФ    ---------- Begin -----------
    //           D[StartIndex] :=D0+TempBn;
    //           D[NChIndex]   :=D0-TempBn;
    //-----------------------------------------------------------------
    MOVaPD    xmm0,  [EAX]      //xmm0 := D[StartIndex] = (D0)
    MOVaPD    xmm2,  xmm0       //xmm2 := xmm0
    ADDPD     xmm0,  xmm1       //xmm0 := D0+TempBn; т.к xmm1=TempBn см выше
    SUBPD     xmm2,  xmm1       //xmm2 := D0-TempBn;
    MOVaPD    [EAX], xmm0       //D[StartIndex] :=D0+TempBn;
    MOVaPD    [EDX], xmm2       //D[NChIndex]   :=D0-TempBn;
    //--------------------  Бабочка БПФ   --------------  END  --------

    //Приращение индексов
    add   EAX,16
    add   EBX,16
    add   EDX,16
    //add   EDX,SizeOf(TComplex)

    loop  @ButterflyFFT    //Давай еще разок :)   dec(ECX)
    //####################  цикл расчета бабочки БПФ  --------- END   ----------

    pop   EDX
    pop   ECX

  @Exit:
    pop   EBX
    pop   EAX
end;


{-------------------------------------------------------------------------------
procedure FFT(var D: TCmxArray; const TableExp: TCmxArray);

Процедура служит роль некого интерфейса, для вызова более 
низкоуровневой процедуры _fft, которая и будет производить 
расчет БПФ, над данным D.

Входные параметры: Смотри процедуру _fft.}
procedure FFT(var D: TCmxArray_d; const TableExp: TCmxArray_d);
begin

  _fft(D,0,Length(D),TableExp);

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
После отработки, массив D будет содержать первоначальные (восстановленные)
данные (сигнал)
Т.е преобразование проходит на месте, без создания копий}
procedure iFFT(var D: TCmxArray_d; const TableExp: TCmxArray_d); register; assembler;
var N:Integer;
  asm

    push  DWord ptr TableExp
    mov   EDX,0
    mov   ECX,[EAX]
    mov   ECX,[ECX-4]     //ECX := High(D)
    ///inc   ECX             //Теперь ECX = Length(D)
    call  _fft

    mov   N,ECX           //N:=Length(D)
    mov   EAX,[EAX]       //Записали адрес первого элемента массива D

    fild  N               //Поместили в  стек FPU, N

    //####################  цикл нормализации       --------- begin ------------
  @Normalize:
    //fld   TComplex.Re [EAX]    //Поместили в стек FPU, D[Index].Re
    fld   double [EAX]    //Поместили в стек FPU, D[Index].Re
    fld   ST(1)                //ST := ST(1) = N
    fdiv                       //St(0) =  D[Index].Re/N
    //fstp  TComplex.Re [EAX]    //Записали St(0) в D[Index].Re
    fstp  double [EAX]    //Записали St(0) в D[Index].Re
    //add   EAX,SizeOf(TComplex) //Приращение индексa, для массивa D.
    add   EAX,16 //Приращение индексa, для массивa D.
    loop  @Normalize           //Повторить пока ECX<>0
    //####################  цикл нормализации       ----------- END ------------
    // добавлено 20.10.20 для очистки стека Скрипник А.А.
    finit
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
procedure NormalizeFFTSpectr(var FFTArray: TCmxArray_d; Mnogitel: Double);register; assembler;
  asm

    mov   EAX,[EAX]     //EAX := @D[0]
    mov   ECX,[EAX-4]   //ECX := High(D)
    //inc   ECX           //ECX = Length(FFTArray); inc т.к в FPC по смещению
                        //хранится Не  Length, а значение High
    shr   ECX,1         //ECX = Length/2

    MOVsD xmm2,Mnogitel //xmm2 := [Mnogitel,Temp]

    //####################  цикл нормализации       --------- begin ------------
  @Normalize:
    MOVaPD    xmm0,  [EAX]      //xmm0 := D[Index]
    MOVaPD    xmm1,  xmm0       //xmm1 := xmm0
    MULPD     xmm0,  xmm1       //xmm0 := [Re^2,  Im^2]
    MOVhlPS   xmm1,  xmm0       //xmm1 := [Im^2,  Temp]
    ADDSD     xmm0,  xmm1       //xmm0 := [Re^2+Im^2, Temp]
    SQRTSD    xmm1,  xmm0       //xmm1 := [(Re^2+Im^2)^0.5, Temp]
    MULSD     xmm1,  xmm2       //xmm1 := [((Re^2+Im^2)^0.5)*Mnogitel, Temp]
    MOVaPD    [EAX], xmm1       //D[Index] :=Abs(D[I])*Mnogitel

    //add   EAX,SizeOf(TComplex)//Приращение индексa, для массивa D
    add   EAX,16                //Приращение индексa, для массивa D
    loop  @Normalize            //Повторить пока ECX<>0
    //####################  цикл нормализации       ----------- END ------------

end;


end.

