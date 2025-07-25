unit uHardwareMath;

interface

// {$Include ..\..\..\..\sharedUtils\utils\FastMM\FastMM4Options.inc}
// {$define fastmm}
// обьявлена в FastMM4Options.inc. Если выравнивание по 16 байт делает FastMM то надо включить

uses
  types, math, ucommontypes, complex, Iterative_FFT_sse,
  recursive_sse2_sse3_d_al_fft
  //,uEditCurveFrm
  ;

type
  TDoubleArray = array of double;
  PDoubleArray = ^TDoubleArray;

  TFFTStats_d = record
    imax: cardinal; // максимум в спектре
    max: double; // амплитуда макс. гарм.
  end;

  TAlignDarray = record
    // d:TDoubleArray;
    p: pointer;
    nAlignedSampl: pointer;
    nAlignedSize: integer; // в байтах
  end;

  PAlignDarray = ^TAlignDarray;

  TAlignDCmpx = record
    // d:TCmxArray_d;
    p: pointer;
    // вся память для выделенного массива
    nAlignedSampl: pointer;
    nAlignedSize: integer; // в байтах
  end;

 // Прямоугольное окно
  // Окно Ханна (Хеннинга)  Hann k=2/3 или 1/1.5 или 0.67   Hanning
  // Окно Хэмминга Hamming 1/0.54 ~1.85
  // Окно Блэкмана Blackman  1/0.375 (или примерно 2.67).
  // Окно Кайзера
  // Flattop 1/0.215 (или примерно 4.65)
  TWndType = (wdRect, wdHann, wdHamming, wdBlackman, wdFlattop);
  PWndType = ^TWndType;


  TWndFunc = record
    size: integer;
   ecf:double; // зависит от типа окна. норм-ия СКО
    acf:double; // зависит от типа окна. норм-ия А
    ar: TAlignDarray;
    wndtype: TWndType;
    // вкл коррекцию АЧХ
    useCorrAFH:boolean;
    // коррекция АЧХ
    //CorrAFHar: cCurve;
  end;

  PWndFunc = ^TWndFunc;

  TFFTProp = record
   scale:double;
    TableExp: TAlignDCmpx; // множители Wn
    TableInd: TIndexArray; // Индексы нижней итерации FFT
    // Номер блока (задает первый индекс обрабатываемой временной последовательности)
    // Например у нас 2048 точек, размер блока 1024 можно посчитать 2 блока FFT
    StartInd: integer;
    PCount: integer; // Число точек FFT
    inverse: boolean;
    m_Zoom:boolean;
    m_ZoomOrd:integer;
    m_useScaleCurve:boolean;
    m_scaleCurve:pDoubleArray;
  end;

  pFFTProp = ^TFFTProp;

function OSEnabledXmmYmm: boolean;
function IsAVX2supported: boolean;

procedure ReindexArray(AInput: TDoubleArray; var p_out:TDoubleArray; StartIndex, Count, Iterations: Integer);
function ConcatArrays(const A, B: TDoubleArray):TDoubleArray;

function tempSUM(const Data: array of double; first, stop: integer): Extended;
function fSUM(const Data: array of double; first, stop: integer): Extended;
function SUM_SSE_d(const Data: array of double): Extended; overload;
function SUM_SSE_d(const Data: array of double;
  first, stop: integer): Extended; overload;
// перемножить все числа массива на Scale
procedure MULT_SSE_al_d(var ar: TDoubleArray; scale: double);
procedure MULT_SSE_al_cmpx_d(var ar: TCmxArray_d; scale: double);
// входной массив не промасштабированный на 1/FFTCount результат FFT
procedure ifft_al_d_sse(inData: TCmxArray_d; var outData: TCmxArray_d;
  FFTPlan: TFFTProp);
// вызов FFT. На входе выровненные данные по 16 байтам даблы и комплексы. Результат в OutData
// OutData в обязательном порядке должен иметь размер FFTSize!!! FFTPlan влияет лишь на
// подготовку данных из inData в OutData inDataNull - блок с дополнением нулями
// первый элемент - двойное среднее!!!
procedure fft_al_d_sse(inData: TDoubleArray; inDataNull: TDoubleArray;var outData: TCmxArray_d; FFTPlan: TFFTProp); overload;
procedure fft_al_d_sse(inData: TDoubleArray; var outData: TCmxArray_d; FFTPlan: TFFTProp); overload;
procedure fft_al_d_sse(inData: TDoubleArray; var outData: TCmxArray_d;
  FFTPlan: TFFTProp; wnd: PWndFunc); overload;
// нормализация вида Abs(inData[i])*(1/FFTSize). размер OutData FFTSize/2
// outData в 2 раза меньше чем inData, на множитель нормализации влияет только яисло точек FFT
// т.е. Length(inData)
procedure NormalizeAndScaleSpmMag(var inData: TCmxArray_d;
  var outData: TDoubleArray);
// то же что и строка выше но без нормализации
procedure EvalSpmMag(var inData: TCmxArray_d; var outData: TDoubleArray);

// Выделение памяти
// возвращает массив выровненный по 16 байтам
procedure GetMemAlignedArray_d(const SrcSize: integer;
  out alData: TAlignDarray); overload;
// ---------------------------------------------------------------------------
procedure GetMemAlignedArray_d(const bits: integer; const src: pointer;
  const SrcSize: integer; out DstAligned: pointer;
  out DstUnaligned: pointer; out DstSize: integer); overload;

// возвращает массив выровненный по 16 байтам
procedure GetMemAlignedArray_cmpx_d(const SrcSize: integer;
  out alData: TAlignDCmpx); overload;
// ----------------------------------------------------------------------------
procedure GetMemAlignedArray_cmpx_d(const bits: integer; const src: pointer;
  const SrcSize: integer; out DstAligned: pointer; out DstUnaligned: pointer;
  out DstSize: integer); overload;

procedure FreeMemAligned(var alData: TAlignDarray); overload;
procedure FreeMemAligned(var alData: TAlignDCmpx); overload;

procedure FreeMemAligned(const src: pointer; var DstUnaligned: pointer;
  var DstSize: integer); overload;

procedure GetMemAligned(const bits: integer; const src: pointer;
  const SrcSize: integer; out DstAligned, DstUnaligned: pointer;
  out DstSize: integer);

// служебные функции
// служебная функция для сортировки массива данных в порядке нижней итерации FFT
procedure SortFFTArray(const inData: TDoubleArray; var outData: TCmxArray_d;
  const TableInd: TIndexArray; StartInd, // Номер блока (задает первый индекс обрабатываемой временной последовательности)
  // Например у нас 2048 точек, размер блока 1024 можно посчитать 2 блока FFT
  PCount: integer); // Число точек FFT
// таблица индексов для сортировки по нижней итерации FFT
// FFTProp.TableInd := GetArrayIndex(FCount, 2);
function GetArrayIndex(CountPoint: integer; MinIteration: integer): TIndexArray;
procedure GetFFTExpTable(CountFFTPoints: integer; InverseFFT: boolean;
  var res: TCmxArray_d);
function AlignBlockLength(b: TAlignDarray): integer; overload;
function AlignBlockLength(b: TAlignDCmpx): integer; overload;

procedure FillWndHann(var a: TDoubleArray);
procedure FillWndHammin(var a: TDoubleArray);
procedure FillWndBlackman(var a: TDoubleArray);
procedure FillWndFlattop(var a: TDoubleArray);
function GetFFTWnd(fftCount: integer; wnd:TWndType): PWndFunc;


function MulAr_sse_al(const D1: array of double;const D2: array of double; var dOut: array of double): Extended;overload;
function MulAr_sse_al(const D1: array of double;const D2: array of double; var dOut: array of double; count:integer): Extended;overload;

procedure MulAr_sse_al_Cmpx(const D1: array of TComplex_d;const D2: array of double; var dOut: array of TComplex_d);
// Процедура для выполнения рекурсивной переиндексации массива
// Data: Динамический массив типа Double, который будет переиндексирован.
//       Изменяется по месту (in-place).
// N: Текущий размер обрабатываемого подмассива. Изначально это длина всего массива.
// IterationsLeft: Количество оставшихся итераций рекурсии.
// StartIndex: Начальный индекс текущего подмассива в исходном массиве.
// OriginalLength: Исходная полная длина массива (для корректной работы с индексами).
procedure ReindexArrayRecursive(var Data: TDoubleArray; N, IterationsLeft, StartIndex, OriginalLength: Integer);
function PerformArrayReindexing(var Data: TDoubleArray; TotalIterations: Integer): Boolean;
// смещает массив (центрирует)
procedure SubtractFromArray_SSE_Double(var A: TDoubleArray; const Value: Double);

var
  // настройки FFT прямого и обратного преобразования
  g_FFTWndList: array of TWndFunc;

const
  c_fftPlan_blockLength =10;
  reg = $FA10;
  PF_FLOATING_POINT_PRECISION_ERRATA = 0; // On a Pentium, a floating-point precision error can occur in rare circumstances.
  PF_FLOATING_POINT_EMULATED = 1; // Floating-point operations are emulated using a software emulator.
  // This function returns a nonzero value if floating-point operations are emulated; otherwise, it returns zero.
  PF_COMPARE_EXCHANGE_DOUBLE = 2; // The atomic compare and exchange operation (cmpxchg) is available.
  PF_MMX_INSTRUCTIONS_AVAILABLE = 3; // The MMX instruction set is available.
  PF_PPC_MOVEMEM_64BIT_OK = 4;
  PF_ALPHA_BYTE_INSTRUCTIONS = 5;
  PF_XMMI_INSTRUCTIONS_AVAILABLE = 6; // The SSE instruction set is available.
  PF_3DNOW_INSTRUCTIONS_AVAILABLE = 7; // The 3D-Now instruction set is available.
  PF_RDTSC_INSTRUCTION_AVAILABLE = 8; // The RDTSC instruction is available.
  PF_PAE_ENABLED = 9; // The processor is PAE-enabled. For more information, see Physical Address Extension.
  // All x64 processors always return a nonzero value for this feature.
  PF_XMMI64_INSTRUCTIONS_AVAILABLE = 10; // The SSE2 instruction set is available.
  // Windows 2000:  This feature is not supported.
  PF_SSE_DAZ_MODE_AVAILABLE = 11;
  PF_NX_ENABLED = 12; // Data execution prevention is enabled.
  // Windows XP/2000:  This feature is not supported until Windows XP with SP2 and Windows Server 2003 with SP1.
  PF_SSE3_INSTRUCTIONS_AVAILABLE = 13; // The SSE3 instruction set is available.
  // Windows Server 2003 and Windows XP/2000:  This feature is not supported.
  PF_COMPARE_EXCHANGE128 = 14; // The atomic compare and exchange 128-bit operation (cmpxchg16b) is available.
  // Windows Server 2003 and Windows XP/2000:  This feature is not supported.
  PF_COMPARE64_EXCHANGE128 = 15; // The atomic compare 64 and exchange 128-bit operation (cmp8xchg16) is available.
  // Windows Server 2003 and Windows XP/2000:  This feature is not supported.
  PF_CHANNELS_ENABLED = 16; // The processor channels are enabled.
  PF_XSAVE_ENABLED = 17; // The processor implements the XSAVE and XRSTOR instructions.
  // Windows Server 2008, Windows Vista, Windows Server 2003 and Windows XP/2000:  This feature is not supported until Windows 7 and Windows Server 2008 R2.
  PF_ARM_VFP_32_REGISTERS_AVAILABLE = 18; // The VFP/Neon: 32 x 64bit register bank is present. This flag has the same meaning as PF_ARM_VFP_EXTENDED_REGISTERS.

  PF_SECOND_LEVEL_ADDRESS_TRANSLATION = 20; // Second Level Address Translation is supported by the hardware.
  PF_VIRT_FIRMWARE_ENABLED = 21; // Virtualization is enabled in the firmware.
  PF_RDWRFSGSBASE_AVAILABLE = 22; // RDFSBASE, RDGSBASE, WRFSBASE, and WRGSBASE instructions are available.
  PF_FASTFAIL_AVAILABLE = 23; // _fastfail() is available.
  PF_ARM_DIVIDE_INSTRUCTION_AVAILABLE = 24; // The divide instructions are available.
  PF_ARM_64BIT_LOADSTORE_ATOMIC = 25; // The 64-bit load/store atomic instructions are available.
  PF_ARM_EXTERNAL_CACHE_AVAILABLE = 26; // The external cache is available.
  PF_ARM_FMAC_INSTRUCTIONS_AVAILABLE = 27; // The floating-point multiply-accumulate instruction is available.

const
  c_pi = 3.1415926535897932384626433;
  c_2pi = c_pi * 2;
  c_4pi = c_pi * 4;
  c_6pi = c_pi * 6;
  c_8pi = c_pi * 8;
  shl4TComplex = 3; // {2^shl4TComplex = SizeOf(TComplex)}
  shl4TComplex_d = 4; // {2^shl4TComplex = SizeOf(TComplex)}

implementation


// Вспомогательная функция для обмена местами двух элементов
procedure Swap(var A, B: Double);
var
  Temp: Double;
begin
  Temp := A;
  A := B;
  B := Temp;
end;

procedure SubtractFromArray_SSE_Double(var A: TDoubleArray; const Value: Double);
var
  Count: Integer;
  P: PDouble;
begin
  Count := Length(A);
  if Count = 0 then Exit;

  P := @A[0];

  asm
    // Указатель на начало массива
    MOV ESI, P
    // Количество элементов в массиве
    MOV ECX, Count
    // Делим на 2, так как обрабатываем по 2 элемента double за раз
    SHR ECX, 1
    // Если в массиве меньше 2 элементов, переходим к обработке остатка
    JZ @@HandleRemainder

    // Загружаем вычитаемое значение в регистр XMM1
    MOVSD XMM1, Value
    // Дублируем значение из нижней части регистра в верхнюю
    // Теперь в XMM1 находится [Value, Value]
    UNPCKLPD XMM1, XMM1

  @@Loop:
    // Загружаем 2 элемента double из массива в XMM0 -> [A[i+1], A[i]]
    MOVUPD XMM0, [ESI]
    // Вычитаем упакованные double: XMM0 := XMM0 - XMM1
    SUBPD XMM0, XMM1
    // Сохраняем результат обратно в массив
    MOVUPD [ESI], XMM0
    // Сдвигаем указатель на 16 байт (2 * sizeof(double))
    ADD ESI, 16
    // Уменьшаем счетчик циклов
    DEC ECX
    JNZ @@Loop

  @@HandleRemainder:
    // Проверяем, остался ли один необработанный элемент (если длина нечетная)
    MOV ECX, Count
    AND ECX, 1
    JZ @@Done // Если нет, завершаем

    // Обрабатываем последний элемент с помощью FPU
    FLD QWORD PTR [ESI]   // Загружаем значение из массива в стек FPU
    FSUB QWORD PTR Value  // Вычитаем наше значение
    FSTP QWORD PTR [ESI]  // Сохраняем результат обратно

  @@Done:
  end;
end;


procedure ReindexArrayRecursive(var Data: TDoubleArray; N, IterationsLeft, StartIndex, OriginalLength: Integer);
var
  EvenBlock: TDoubleArray; // Временный массив для четных элементов
  OddBlock: TDoubleArray;  // Временный массив для нечетных элементов
  i, j: Integer;
begin
  // Условие выхода из рекурсии:
  // Если не осталось итераций, или размер текущего блока равен 1,
  // значит, этот блок уже не требует дальнейшей переиндексации.
  if (IterationsLeft <= 0) or (N <= 1) then
    Exit;
  // Определяем размеры подблоков
  SetLength(EvenBlock, N div 2);
  SetLength(OddBlock, N - (N div 2)); // На случай нечетного N, хотя по заданию N = 2^Iterations
  j := 0; // Индекс для EvenBlock
  // Разделение на четные и нечетные элементы относительно текущего подмассива
  // Перебираем элементы в текущем подмассиве (от StartIndex до StartIndex + N - 1)
  for i := 0 to N - 1 do
  begin
    if (i mod 2) = 0 then // Если индекс внутри подмассива четный
    begin
      EvenBlock[j] := Data[StartIndex + i];
      Inc(j);
    end;
  end;
  j := 0; // Индекс для OddBlock
  for i := 0 to N - 1 do
  begin
    if (i mod 2) <> 0 then // Если индекс внутри подмассива нечетный
    begin
      OddBlock[j] := Data[StartIndex + i];
      Inc(j);
    end;
  end;

  // Соединяем блоки обратно в Data по месту
  // Сначала четные, потом нечетные
  for i := 0 to High(EvenBlock) do
  begin
    Data[StartIndex + i] := EvenBlock[i];
  end;
  for i := 0 to High(OddBlock) do
  begin
    Data[StartIndex + Length(EvenBlock) + i] := OddBlock[i];
  end;

  // Рекурсивный вызов для четного блока
  ReindexArrayRecursive(Data, Length(EvenBlock), IterationsLeft - 1, StartIndex, OriginalLength);

  // Рекурсивный вызов для нечетного блока
  // Начальный индекс нечетного блока смещается на размер четного блока
  ReindexArrayRecursive(Data, Length(OddBlock), IterationsLeft - 1, StartIndex + Length(EvenBlock), OriginalLength);
end;


// Вспомогательная функция для удобного вызова
// Она рассчитывает общее количество итераций и запускает рекурсию.
// Параметры:
//   Data: Входной и выходной массив Double, который будет переиндексирован.
//   TotalIterations: Общее количество итераций (например, 2 или 3).
// Возвращает True, если операция успешна, False при ошибке (например, неподходящая длина массива).
function PerformArrayReindexing(var Data: TDoubleArray; TotalIterations: Integer): Boolean;
var
  ExpectedLength: Integer;
begin
  Result := False;
  // Проверяем, что TotalIterations > 0
  if TotalIterations <= 0 then
  begin
    Exit;
  end;
  // Вычисляем ожидаемую длину массива (должна быть степенью 2 для простоты алгоритма)
  // Это N в формуле N = 2^k, где k - количество итераций
  ///ExpectedLength := 1 shl TotalIterations; // 2 в степени TotalIterations
  // Проверяем, соответствует ли длина массива ожидаемой
  ///if Length(Data) <> ExpectedLength then
  ///begin
    //ShowMessage(Format('Ошибка: Длина массива (%d) должна быть 2 в степени %d (%d) для данного алгоритма.', [Length(Data), TotalIterations, ExpectedLength]));
   /// Exit;
  ///end;
  // Запускаем рекурсивную переиндексацию
  ReindexArrayRecursive(Data, Length(Data), TotalIterations, 0, Length(Data));
  Result := True;
end;


{ TArrayUtils }
procedure ReindexArray(AInput: TDoubleArray; var p_out:TDoubleArray; StartIndex, Count, Iterations: Integer);
var
  WorkArray: TDoubleArray;
  CurrentIteration, i, Len: Integer;
  EvenPart, OddPart: TDoubleArray;
  idx: Integer;
begin
  // Проверка и коррекция входных параметров
  if (StartIndex < 0) or (StartIndex >= Length(AInput)) or (Count <= 0) then
  begin
    SetLength(p_out, 0);
    Exit;
  end;
  // Корректируем Count, если выходим за пределы массива
  Count := Min(Count, Length(AInput) - StartIndex);
  SetLength(WorkArray, Count);
  Move(AInput[StartIndex], WorkArray[0], Count * SizeOf(Double));

  // Обработка итераций
  for CurrentIteration := 1 to Iterations do
  begin
    Len := Length(WorkArray);
    if Len < 2 then Break;

    // Разделение на четные и нечетные элементы
    SetLength(EvenPart, (Len + 1) div 2);
    SetLength(OddPart, Len div 2);

    // Заполнение четных элементов
    for idx := 0 to High(EvenPart) do
      EvenPart[idx] := WorkArray[idx * 2];

    // Заполнение нечетных элементов
    for idx := 0 to High(OddPart) do
      OddPart[idx] := WorkArray[idx * 2 + 1];

    // Объединение частей
    WorkArray := ConcatArrays(EvenPart, OddPart);
  end;

  p_out := WorkArray;
end;

function ConcatArrays(const A, B: TDoubleArray): TDoubleArray;
var
  i, LenA, LenB: Integer;
begin
  LenA := Length(A);
  LenB := Length(B);
  SetLength(Result, LenA + LenB);
  for i := 0 to LenA - 1 do
    Result[i] := A[i];
  for i := 0 to LenB - 1 do
    Result[LenA + i] := B[i];
end;


function MulAr_sse_al(const D1: array of double;const D2: array of double; var dOut: array of double; count:integer): Extended;
var
  // размер блока при вычислении умножения
  shift: integer;
asm
// сохранить в стек регистры EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI.
  pushad
  // квадратные скобки - обратиться к значению по адресу в eax
  //mov eax, d1 // @D1[0]
  mov edx, count // запоминаем длину массива
  mov ebx, edx // запоминаем длину массива
  mov edi, dOut
  // число кратных 3-м блоков в ECX. Два раза сдвиг влево и два вправо, чтоб похерить младшие биты
  shr edx, 3
  push edx
  shl edx, 3
  // высчитываем кол-во некратных элементов
  sub ebx, edx // например если всего 10 а кратно 8 то ebx = 2
  pop edx

  // ecx - в смещение до посл элемента (*sof(double) 2^3)
  shl edx, 3// длина кратных блолков в байтах
  mov esi, 0

  cmp edx, 1 // установка флага сравнения
  jl @@EndMul // jl - jump if less
  @@Loop:
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi] // загружаем по 2 числа

    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16] // загружаем по 2 числа
    movapd xmm4, [eax+esi+32] // загружаем по 2 числа
    movapd xmm5, [ecx+esi+32] // загружаем по 2 числа
    movapd xmm6, [eax+esi+48] // загружаем по 2 числа
    movapd xmm7, [ecx+esi+48] // загружаем по 2 числа

    // перемножить 0 и 2 и сохранить в 0
    MULPD xmm0, xmm1
    MULPD xmm2, xmm3
    MULPD xmm4, xmm5
    MULPD xmm6, xmm7
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movapd [edi+esi+32], xmm4
    movapd [edi+esi+48], xmm6
    add esi, 64
    sub edx, 8 // вычитаем из edx 64 и устанавливаем sign flag
  JNZ @@loop // переход если edi не ноль
  //jns @@loop // переход если SF=1
  @@EndMul:
    // домножаем остатки
    JMP   @V.Pointer[ebx*4]
  @V:
       DD @@1
       DD @@2
       DD @@3
       DD @@4
       DD @@5
       DD @@6
       DD @@7
       DD @@8
  @@1: // 0
    jmp @exit
  @@2: // 1
    movlpd xmm0, [eax+esi] // загружаем по 1 числу
    movlpd xmm1, [ecx+esi] // загружаем по 1 числу
    MULPD  xmm0, xmm1
    movlpd [edi+esi], xmm0
    jmp @exit
  @@3: // остаток 2 числа
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd  xmm1, [ecx+esi]
    MULPD  xmm0, xmm1
    movapd [edi+esi], xmm0
    jmp @exit
  @@4: // 3 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movlpd xmm2, [eax+esi+16] // загружаем по 1 числа
    movlpd xmm3, [ecx+esi+16]
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    movapd [edi+esi], xmm0
    movlpd [edi+esi+16], xmm2
    jmp @exit
  @@5: // 4 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    jmp @exit
  @@6: // 5 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    movlpd xmm4, [eax+esi+32] // загружаем по 1 числа
    movlpd xmm5, [ecx+esi+32] // загружаем по 1 числа
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    MULPD  xmm4, xmm5
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movlpd [edi+esi+32], xmm4
    jmp @exit
  @@7: // 6 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    movapd xmm4, [eax+esi+32] // загружаем по 1 числа
    movapd xmm5, [ecx+esi+32] // загружаем по 1 числа
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    MULPD  xmm4, xmm5
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movapd [edi+esi+32], xmm4
    jmp @exit
  @@8: // 7 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    movapd xmm4, [eax+esi+32] // загружаем по 1 числа
    movapd xmm5, [ecx+esi+32] // загружаем по 1 числа
    movapd xmm6, [eax+esi+48] // загружаем по 1 числа
    movapd xmm7, [ecx+esi+48] // загружаем по 1 числа
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    MULPD  xmm4, xmm5
    MULPD  xmm6, xmm7
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movapd [edi+esi+32], xmm4
    movlpd [edi+esi+48], xmm6
    jmp @exit
  @Exit:
  popad
end;

// перемножаем массив 1 на2 поэлементно. количество согласно d1
// Параметры: первый в eax, второй в ecx!!! (по описанию ebx по факту ecx), третий в ecx???, ост-ые - стек.
function MulAr_sse_al(const D1: array of double;const D2: array of double; var dOut: array of double): Extended;
var
  // размер блока при вычислении умножения
  shift: integer;
asm
 // сохранить в стек регистры EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI.
  pushad
  // квадратные скобки - обратиться к значению по адресу в eax
  //mov eax, d1 // @D1[0]
  mov edx, [eax-4] // запоминаем длину массива
  mov ebx, edx // запоминаем длину массива
  mov edi, dOut
  // число кратных 3-м блоков в ECX. Два раза сдвиг влево и два вправо, чтоб похерить младшие биты
  shr edx, 3
  push edx
  shl edx, 3
  // высчитываем кол-во некратных элементов
  sub ebx, edx // например если всего 10 а кратно 8 то ebx = 2
  pop edx

  // ecx - в смещение до посл элемента (*sof(double) 2^3)
  shl edx, 3// длина кратных блолков в байтах
  mov esi, 0

  cmp edx, 1 // установка флага сравнения
  jl @@EndMul // jl - jump if less
  @@Loop:
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi] // загружаем по 2 числа
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16] // загружаем по 2 числа
    movapd xmm4, [eax+esi+32] // загружаем по 2 числа
    movapd xmm5, [ecx+esi+32] // загружаем по 2 числа
    movapd xmm6, [eax+esi+48] // загружаем по 2 числа
    movapd xmm7, [ecx+esi+48] // загружаем по 2 числа

    // перемножить 0 и 2 и сохранить в 0
    MULPD xmm0, xmm1
    MULPD xmm2, xmm3
    MULPD xmm4, xmm5
    MULPD xmm6, xmm7
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movapd [edi+esi+32], xmm4
    movapd [edi+esi+48], xmm6
    add esi, 64
    sub edx, 8 // вычитаем из edx 64 и устанавливаем sign flag
  JNZ @@loop // переход если edi не ноль
  //jns @@loop // переход если SF=1
  @@EndMul:
    // домножаем остатки
    JMP   @V.Pointer[ebx*4]
  @V:
       DD @@1
       DD @@2
       DD @@3
       DD @@4
       DD @@5
       DD @@6
       DD @@7
       DD @@8
  @@1: // 0
    jmp @exit
  @@2: // 1
    movlpd xmm0, [eax+esi] // загружаем по 1 числу
    movlpd xmm1, [ecx+esi] // загружаем по 1 числу
    MULPD  xmm0, xmm1
    movlpd [edi+esi], xmm0
    jmp @exit
  @@3: // остаток 2 числа
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd  xmm1, [ecx+esi]
    MULPD  xmm0, xmm1
    movapd [edi+esi], xmm0
    jmp @exit
  @@4: // 3 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movlpd xmm2, [eax+esi+16] // загружаем по 1 числа
    movlpd xmm3, [ecx+esi+16]
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    movapd [edi+esi], xmm0
    movlpd [edi+esi+16], xmm2
    jmp @exit
  @@5: // 4 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    jmp @exit
  @@6: // 5 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    movlpd xmm4, [eax+esi+32] // загружаем по 1 числа
    movlpd xmm5, [ecx+esi+32] // загружаем по 1 числа
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    MULPD  xmm4, xmm5
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movlpd [edi+esi+32], xmm4
    jmp @exit
  @@7: // 6 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    movapd xmm4, [eax+esi+32] // загружаем по 1 числа
    movapd xmm5, [ecx+esi+32] // загружаем по 1 числа
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    MULPD  xmm4, xmm5
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movapd [edi+esi+32], xmm4
    jmp @exit
  @@8: // 7 чисел
    movapd xmm0, [eax+esi] // загружаем по 2 числа
    movapd xmm1, [ecx+esi]
    movapd xmm2, [eax+esi+16] // загружаем по 2 числа
    movapd xmm3, [ecx+esi+16]
    movapd xmm4, [eax+esi+32] // загружаем по 1 числа
    movapd xmm5, [ecx+esi+32] // загружаем по 1 числа
    movapd xmm6, [eax+esi+48] // загружаем по 1 числа
    movapd xmm7, [ecx+esi+48] // загружаем по 1 числа
    MULPD  xmm0, xmm1
    MULPD  xmm2, xmm3
    MULPD  xmm4, xmm5
    MULPD  xmm6, xmm7
    movapd [edi+esi], xmm0
    movapd [edi+esi+16], xmm2
    movapd [edi+esi+32], xmm4
    movlpd [edi+esi+48], xmm6
    jmp @exit
  @Exit:
  popad
end;


function GetFFTWnd(fftCount: integer; wnd:TWndType): PWndFunc;
var
  i, l: integer;
  pr: PWndFunc;
  r: TWndFunc;
begin
  r.size := 0;
  r.acf:=1;
  r.ecf:=1;
  r.ar.p:=nil;
  r.ar.nAlignedSampl:=nil;
  r.ar.nAlignedSize:=0;
  for i := 0 to length(g_FFTWndList) - 1 do
  begin
    pr := @g_FFTWndList[i];
    if pr.size=0 then
      break;
    if (pr.size = fftCount) and (pr.wndtype=wnd) then
    begin
      result := @g_FFTWndList[i];
      exit;
    end;
  end;
  l:=i+1;
  // длина массива
  l := length(g_FFTWndList);
  SetLength(g_FFTWndList, l + c_fftPlan_blockLength);
  r.size := fftCount;
  r.wndtype:=wnd;
  GetMemAlignedArray_d(fftCount,r.ar);
  //setlength(r.ar, fftCount);
  case wnd of
    wdHann:    // 0.22/0.14
    begin
      // acf 2 ecf 1.63
      r.acf:=2;
      r.ecf:=1.63;
      FillWndHann(TDoubleArray(r.ar.p));
    end;
    wdHamming:
    begin
      // acf 1.85 ecf 1.59
      r.acf:=1.8534;
      r.ecf:=1.59;
      FillWndHammin(TDoubleArray(r.ar.p));
    end;
    wdBlackman:
    begin
      // acf 2.8 ecf 1.97
      r.acf:=2.8;
      r.ecf:=1.97;
      FillWndBlackman(TDoubleArray(r.ar.p));
    end;
    wdFlattop:
    begin
      // acf 4.18 ecf 2.26
      r.acf:=4.18;
      r.ecf:=2.26;
      FillWndFlattop(TDoubleArray(r.ar.p));
    end;
  end;
  g_FFTWndList[l] := r;
  result := @g_FFTWndList[l];
end;

function fSUM(const Data: array of double; first, stop: integer): Extended;
asm  // IN: EAX = ptr to Data, EDX = High(Data) = Count - 1
     // Uses 4 accumulators to minimize read-after-write delays and loop overhead
     // 5 clocks per loop, 4 items per loop = 1.2 clocks per item
       FLDZ
       MOV      ECX, EDX
       FLD      ST(0)
       AND      EDX, not 3
       FLD      ST(0)
       AND      ECX, 3
       FLD      ST(0)
       SHL      EDX, 3      // count * sizeof(Double) = count * 8
       JMP      @Vector.Pointer[ECX*4]
@Vector:
       DD @@1
       DD @@2
       DD @@3
       DD @@4
@@4:   FADD     qword ptr [EAX+EDX+24]    // 1
       FXCH     ST(3)                     // 0
@@3:   FADD     qword ptr [EAX+EDX+16]    // 1
       FXCH     ST(2)                     // 0
@@2:   FADD     qword ptr [EAX+EDX+8]     // 1
       FXCH     ST(1)                     // 0
@@1:   FADD     qword ptr [EAX+EDX]       // 1
       FXCH     ST(2)                     // 0
       SUB      EDX, 32
       JNS      @@4
       FADDP    ST(3),ST                  // ST(3) := ST + ST(3); Pop ST
       FADD                               // ST(1) := ST + ST(1); Pop ST
       FADD                               // ST(1) := ST + ST(1); Pop ST
       FWAIT
end;

function tempSUM(const Data: array of double; first, stop: integer): Extended;
var
  I: integer;
  p0, p: pinteger;

begin
  p := @Data[first];
  p0 := pinteger(integer(p) - 4);
  I := p0^; // запоминаем старое значение
  // p0^:=(stop-first+1)*sizeof(double);
  p0^ := (stop - first + 1);
  // p[0]:=integer(@p[2]);
  result := sum(TDoubleArray(p));
  p0^ := I; // восстанавливаем старое значение
end;

procedure GetFFTExpTable(CountFFTPoints: integer; InverseFFT: boolean;
  var res: TCmxArray_d);
var
  I, StartIndex, N, LenB: integer;
  w, wn: TComplex_d;
  Mnogitel: double;
begin
  Mnogitel := -2 * Pi; // Прямое  БПФ
  if InverseFFT then
    Mnogitel := 2 * Pi; // Обратное  БПФ
  LenB := 1;

  while LenB < CountFFTPoints do // Пробегаем каждый блок.
  begin
    N := LenB; // поучаем число элементов в блоке
    LenB := LenB shl 1;
    // Готовим первый EXP множитель(корень) для БПФ.
    wn.Re := 0;
    wn.Im := Mnogitel / LenB;
    wn := exp(wn);
    w := 1;

    StartIndex := N; // Стартовый индекс в массиве.
    Dec(N); // Т.к индексация с нуля
    For I := 0 to N do // заполняем блок exp множителями для БПФ, в массиве
    begin
      res[StartIndex + I] := w;
      w := w * wn;
    end;
  end;
end;

function GetArrayIndex(CountPoint: integer;
  MinIteration: integer): TIndexArray;
Var
  I, LenBlock, HalfBlock, HalfBlock_1, StartIndex, EndIndex, ChIndex,
    NChIndex: integer;
  TempArray: TIndexArray;
begin

  EndIndex := CountPoint - 1;

  SetLength(result, CountPoint);
  For I := 0 to EndIndex do // Располагаем индексы по порядку
    result[I] := I;

  LenBlock := CountPoint;
  HalfBlock := LenBlock shr 1;
  HalfBlock_1 := HalfBlock - 1;

  while LenBlock > MinIteration do // переставляем индексы в блоках длинной  LenBlock
  begin
    StartIndex := 0; // начинаем с крайнего левого блока
    TempArray := Copy(result, 0, CountPoint);

    repeat // переставляем индексы в конкретном(начало блока =StartIndex) блоке длинной  LenBlock
      ChIndex := StartIndex;
      NChIndex := ChIndex + 1;
      EndIndex := StartIndex + HalfBlock_1;

      // Выделяем четные и нечетные индексы и помещаем обратно в исходный массив
      for I := StartIndex to EndIndex do
      begin
        result[I] := TempArray[ChIndex];
        result[I + HalfBlock] := TempArray[NChIndex];

        ChIndex := ChIndex + 2;
        NChIndex := NChIndex + 2;
      end;

      StartIndex := StartIndex + LenBlock; // переходим к другому блоку
    Until StartIndex >= CountPoint; // если дошли до длины массива, значит блоков больше нет.

    // уменьшаем длину блок, пока не дойдем до минимального размера (MinIteration)
    LenBlock := LenBlock shr 1;
    HalfBlock := LenBlock shr 1;
    HalfBlock_1 := HalfBlock - 1;
  end;
  TempArray := Nil;
end;

procedure SortFFTArray(const inData: TDoubleArray; // входные данные
  var outData: TCmxArray_d; // выходные данные
  const TableInd: TIndexArray; // Индексы нижней итерации FFT
  StartInd, // Номер блока (задает первый индекс обрабатываемой временной последовательности)
  // Например у нас 2048 точек, размер блока 1024 можно посчитать 2 блока FFT
  PCount: integer); // Число точек FFT
var
  I: integer;
begin
  // размещение согласно нижней итерации FFT
  for I := StartInd to PCount - StartInd - 1 do
  begin
    outData[I] := inData[TableInd[I] + StartInd];
  end;
end;

procedure EvalSpmMag(var inData: TCmxArray_d; var outData: TDoubleArray);
var
  N: integer;
asm
  pushad
    mov   EAX,[EAX]     // EAX := @D[0]
    mov   EDX,[EDX]     // EAX := @D[0]
    mov   ECX,[EAX-4]   // ECX := Length

    shr   ECX,1         // ECX = Length/2
    dec   ECX           // Length-1
    // ####################  цикл нормализации       --------- begin ------------
    mov  ebx, EDX     // EbX := @outD[0]
    // lea  eax, p2
  @Normalize:
    MOVaPD    xmm0,  [EAX]      // xmm0 := D[Index]
    MOVaPD    xmm1,  xmm0       // xmm1 := xmm0
    MULPD     xmm0,  xmm1       // xmm0 := [Re^2,  Im^2]
    MOVhlPS   xmm1,  xmm0       // xmm1 := [Im^2,  Temp]
    ADDSD     xmm0,  xmm1       // xmm0 := [Re^2+Im^2, Temp]
    SQRTSD    xmm1,  xmm0       // xmm1 := [(Re^2+Im^2)^0.5, Temp]

    MOVLPS    [ebx], xmm1       // D[Index] :=Abs(D[I])*Mnogitel
    add       ebx,   8
    add       eax,   16
    // add   EAX,SizeOf(TComplex)//Приращение индексa, для массивa D
    dec   ecx                  // Приращение индексa, для массивa D
  jns @Normalize // переход если SF=1
    // ####################  цикл нормализации       ----------- END ------------
  popad
end;

//  на вход принимает не нормированный комплексный спектр из fft_al_d_sse
procedure NormalizeAndScaleSpmMag(var inData: TCmxArray_d;
  var outData: TDoubleArray);
var
  // p2:point2d;
  scale: double;
  one, N: integer;
asm
  pushad
    mov   EAX,[EAX]     // EAX := @D[0]
    mov   EDX,[EDX]     // EAX := @D[0]
    mov   ECX,[EAX-4]   // ECX := Length
    // масштаб
    mov   n, ecx
    shr   n, 1
    mov   one, 1
    fild  one    // N
    fild  n  // Поместили в стек FPU 1
    fdiv                // St(0) =  1/N
    fstp  double [scale]
    lea   ebx, [scale]

    MOVDDUP xmm2, [ebx] // xmm2= scale
    shr   ECX,1         // ECX = Length/2
    dec   ECX           // Length-1
    // ####################  цикл нормализации       --------- begin ------------
    mov  ebx, EDX     // EbX := @outD[0]
    // lea  eax, p2
  @Normalize:
    MOVaPD    xmm0,  [EAX]      // xmm0 := D[Index]
    MOVaPD    xmm1,  xmm0       // xmm1 := xmm0
    MULPD     xmm0,  xmm1       // xmm0 := [Re^2,  Im^2]
    MOVhlPS   xmm1,  xmm0       // xmm1 := [Im^2,  Temp]
    ADDSD     xmm0,  xmm1       // xmm0 := [Re^2+Im^2, Temp]
    SQRTSD    xmm1,  xmm0       // xmm1 := [(Re^2+Im^2)^0.5, Temp]
    MULSD     xmm1,  xmm2       // xmm1 := [((Re^2+Im^2)^0.5)*Mnogitel, Temp]

    MOVLPS    [ebx], xmm1       // D[Index] :=Abs(D[I])*Mnogitel
    // MOVuPD    [ebx], xmm1       //D[Index] :=Abs(D[I])*Mnogitel

    add       ebx,   8
    add       eax,   16
    // add   EAX,SizeOf(TComplex)//Приращение индексa, для массивa D
    dec   ecx                  // Приращение индексa, для массивa D
  jns @Normalize // переход если SF=1
    // ####################  цикл нормализации       ----------- END ------------
  popad
end;

procedure ifft_al_d_sse(inData: TCmxArray_d; var outData: TCmxArray_d;
  FFTPlan: TFFTProp);
var
  I, ind, adr: integer;
  J, Len, sof, DPointer, TableExpPointer: integer;
begin
  // размещение согласно нижней итерации FFT
  for I := 0 to FFTPlan.PCount - 1 do
  begin
    ind := FFTPlan.TableInd[I] + FFTPlan.StartInd;
    outData[I] := inData[ind];
  end;
  iFFT(TCmxArray_d(outData), FFTPlan.TableExp.p);
end;

procedure fft_al_d_sse(inData: TDoubleArray; var outData: TCmxArray_d;
  FFTPlan: TFFTProp; wnd: PWndFunc);
var
  I: Integer;
begin
  if (wnd <> nil) and (wnd.wndtype <> wdRect) then
  begin
    //for I := 0 to wnd.size - 1 do
    //begin
    //  inData[i]:=inData[i]*TDoubleArray(wnd.ar.p)[i];
    //end;
    MulAr_sse_al(inData, TDoubleArray(wnd.ar.p), inData, wnd.size);
  end;
  fft_al_d_sse(inData, outData, FFTPlan);
end;

procedure MulAr_sse_al_Cmpx(const D1: array of TComplex_d;const D2: array of double; var dOut: array of TComplex_d);
var
  I: Integer;
begin
  // D2 �������� ��������� ��� ����� ����������� �������
  for I := 0 to length(d2) - 1 do
  begin
    dout[i]:=d1[i]*d2[i];
  end;
end;

function ReindexArray_(const AInput: TDoubleArray;StartIndex, Count: Integer): TDoubleArray;
var
  i, idx, evenCount, oddCount, startEven, startOdd: Integer;
begin
  // Проверка валидности параметров
  if (StartIndex < 0) or
     (StartIndex >= Length(AInput)) or
     (Count <= 0) or
     (StartIndex + Count > Length(AInput)) then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  // Определяем количество четных и нечетных элементов
  if (StartIndex mod 2) = 0 then
    evenCount := (Count + 1) div 2  // Если стартовый индекс четный
  else
    evenCount := Count div 2;        // Если стартовый индекс нечетный
  oddCount := Count - evenCount;
  SetLength(Result, Count);
  // Заполняем элементы с четными индексами
  startEven := StartIndex;
  if (startEven mod 2) <> 0 then Inc(startEven);
  for i := 0 to evenCount - 1 do
  begin
    idx := startEven + i * 2;
    Result[i] := AInput[idx];
  end;
  // Заполняем элементы с нечетными индексами
  startOdd := StartIndex;
  if (startOdd mod 2) = 0 then Inc(startOdd);
  for i := 0 to oddCount - 1 do
  begin
    idx := startOdd + i * 2;
    Result[evenCount + i] := AInput[idx];
  end;
end;

procedure fft_al_d_sse(inData: TDoubleArray; inDataNull: TDoubleArray;var outData: TCmxArray_d; FFTPlan: TFFTProp); overload;
begin
  move(indata[0], inDataNull[0], length(indata)*sizeof(double));
  fft_al_d_sse(inDataNull, outData, FFTPlan);
end;

procedure fft_al_d_sse(inData: TDoubleArray; var outData: TCmxArray_d;
  FFTPlan: TFFTProp);
var
  I, adr, ind: integer;
  J, Len, sof, DPointer, TableExpPointer: integer;
begin
  // размещение согласно нижней итерации FFT
  for I := 0 to FFTPlan.PCount - 1 do
  begin
    ind := FFTPlan.TableInd[I] + FFTPlan.StartInd;
    outData[I] := inData[ind];
  end;
  adr := integer(@inData[0]) - 4;
  // EvalFFT_al_d_sse(outData, FFTPlan.TableExp);
  recursive_sse2_sse3_d_al_fft.fft(outData, FFTPlan.TableExp.p);
  if FFTPlan.m_useScaleCurve then
  begin
    if FFTPlan.m_scaleCurve<>nil then
    begin
      MulAr_sse_al_Cmpx(outData, tdoublearray(FFTPlan.m_scaleCurve), outData);
    end;
  end;
end;

procedure MULT_SSE_al_cmpx_d(var ar: TCmxArray_d; scale: double);
var
  shift: integer;
  r: point2d;
asm
  pushad
    mov eax, [eax] // @D[0]
    mov edx, [eax-4]
    // xmm0..3 - загрузка данных для умножения
    // xmm4 - множитель
    // ecx - длина массива
    MOVDDUP Xmm4, scale
    // ECX - длина массива потом преобразование в смещение
    MOV     ECX, edx
    // число кратных 2-м блокам в ECX
    shr     ECX, 2
    shl     ECX, 2
    // высчитываем кол-во некратных элементов
    mov     ebx, edx // ebx=Length
    sub     ebx, ecx // Length-NBlock
    // ecx - в смещение до посл элемента (*sof(double)*2)
    shl     ECX, 4
    mov     shift, ecx
    sub     ecx, 16
  @@Loop: // обработка кратных даннх
    movapd xmm0, [eax+ecx] // загружаем по 2 числа
    movapd xmm1, [eax+ecx-16] // загружаем по 2 числа
    movapd xmm2, [eax+ecx-32] // загружаем по 2 числа
    movapd xmm3, [eax+ecx-48] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    MULPD  xmm2, xmm4
    MULPD  xmm3, xmm4
    movapd [eax+ecx],xmm0
    movapd [eax+ecx-16],xmm1
    movapd [eax+ecx-32],xmm2
    movapd [eax+ecx-48],xmm3
    sub ecx, 64
  jns @@loop // переход если SF=1
    shl edx, 3 // смещение к последнему элементу
    // домножаем остатки
    JMP   @Vector.Pointer[ebx*4]
  @Vector:
       DD @@1
       DD @@2
       DD @@3
       DD @@4

  @@1:
    jmp @exit
  @@2:
  // 1
    add eax, shift
    movapd xmm0, [eax] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    movapd [eax], xmm0
    jmp @exit
  @@3:
  // 2
    add eax, shift
    movapd xmm0, [eax] // загружаем по 2 числа
    movapd xmm1, [eax+16] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    movapd [eax], xmm0
    movapd [eax+16], xmm1
    jmp @exit
  // 0 чисел
  @@4:
  // 3 чисел
    add eax, shift
    movapd xmm0, [eax] // загружаем по 2 числа
    movapd xmm1, [eax+16] // загружаем по 2 числа
    movapd xmm2, [eax+32] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    MULPD  xmm2, xmm4
    movapd [eax], xmm0
    movapd [eax+16], xmm1
    movapd [eax+32], xmm2
  @Exit:
  popad
end;

procedure MULT_SSE_al_d(var ar: TDoubleArray; scale: double);
var
  shift: integer;
  r: point2d;
asm
  pushad
    mov eax, [eax] // @D[0]
    // в edx кладем длину массива. Она лежит по смещению 4 от нулевого элемента
    mov edx, [eax-4]
    // xmm0..3 - загрузка данных для умножения
    // xmm4 - множитель
    // ecx - длина массива
    MOVDDUP Xmm4, scale

    MOV     ECX, edx
    // число кратных 4-м блоков в ECX
    shr     ECX, 2
    shl     ECX, 2
    // высчитываем кол-во некратных элементов
    mov     ebx, edx // ebx=Length
    sub     ebx, ecx // Length-NBlock
    // ecx - в смещение до посл элемента (*sof(double))
    shl     ECX, 3
    mov     shift, ecx
    sub     ecx, 16
  @@Loop:
    movapd xmm0, [eax+ecx] // загружаем по 2 числа
    movapd xmm1, [eax+ecx-16] // загружаем по 2 числа
    movapd xmm2, [eax+ecx-32] // загружаем по 2 числа
    movapd xmm3, [eax+ecx-48] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    MULPD  xmm2, xmm4
    MULPD  xmm3, xmm4
    movapd [eax+ecx],xmm0
    movapd [eax+ecx-16],xmm1
    movapd [eax+ecx-32],xmm2
    movapd [eax+ecx-48],xmm3
    sub ecx, 64
  jns @@loop // переход если SF=1
    shl edx, 3 // смещение к последнему элементу
    // домножаем остатки
    JMP   @Vector.Pointer[ebx*4]
  @Vector:
       DD @@1
       DD @@2
       DD @@3
       DD @@4

  @@1:
    jmp @exit
  @@2:
  // 1
    add eax, shift
    movddup xmm0, [eax] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    movupd [r],  xmm0
    // дабл копируем через стек FPU
    lea ebx, r   // lea копирует в первый операнд значение по адресу втрого
    fld qword ptr [ebx]
    FSTP qword ptr [eax]
    jmp @exit
  @@3:
  // 2
    add eax, shift
    movapd xmm0, [eax] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    movapd [eax], xmm0
    jmp @exit
  // 0 чисел
  @@4:
  // 3 чисел
    add eax, shift
    movapd xmm0, [eax] // загружаем по 2 числа
    movddup xmm1, [eax+16] // загружаем по 2 числа
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    movapd [eax], xmm0
    // дабл копируем через стек FPU
    movupd [r],  xmm1
    lea ebx, r   // lea копирует в первый операнд значение по адресу втрого
    fld qword ptr [ebx]
    add eax, 16
    FSTP qword ptr [eax]
  @Exit:
  popad
end;

function SUM_SSE_d(const Data: array of double): Extended;
// const
// zero_d: array [0..1] of Double = (0,0);
var
  r2, r1: double;
asm
  pushad
  // edx - длина массива (точнее номер hight элемента)
  // ecx - целое без остатка количество итераций по сложению буферов sse (16 даблов на итерацию)
  // ebx - остаток деления (элементы не уместившиеся в целое число итераций)
  // esi - цказатель по массиву суммируемых данных (начинается с начала адреса data и ползет до посл. элемента)
  MOV ECX, EDX // в ecx кладем LENGTH длина массива

  dec ecx      // уменьшаем еще на 1 элемент т.к. в xmm0 2 числа
  push edx
  // делим на 14 чтобы понять число блков кратное 14 значениям в 7-и регистрах
  MOV eax, ecx
  MOV ecx, 14
  cdq
  IDIV ECX // результат автоматом попадает в eax
  MOV ecx, eax // в ecx кладем hight длина массива
  // сохраняем остаток от деления на 14 (неявно попадает в edx при выполнении div)
  MOV Ebx, EDX
  pop edx
  cmp ecx, 0
  jnz @@StartProg
  MOV Ebx, edx // корректируем остаток если число блоков 0

  @@StartProg:
  movups xmm0, [esi] // здесь результат сложения всех регистров
  sub ecx, 1         // прочитали блок
  js @@endSum         // переход если SF=1

  // Зануляем r2
  fldz
  fstp r2
  add esi, 16
  @@loop:            // есть полные итерации
    movups xmm1, [esi]
    movups xmm2, [esi+16]
    movups xmm3, [esi+32]
    movups xmm4, [esi+48]
    movups xmm5, [esi+64]
    movups xmm6, [esi+80]
    movups xmm7, [esi+96]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5
    addpd xmm6, xmm7

    addpd xmm0, xmm2
    addpd xmm4, xmm6
    addpd xmm0, xmm4

    add esi, 112 // указатель на следующий блок массива
    sub ecx, 1   // прочитали блок
  jns @@loop // переход если SF=1
  haddpd xmm0, xmm0
  movsd r2, xmm0

  @@endSum:
  xorps  xmm0, xmm0
  xorps  xmm1, xmm1
  xorps  xmm2, xmm2
  xorps  xmm3, xmm3
  xorps  xmm4, xmm4
  xorps  xmm5, xmm5
  xorps  xmm6, xmm6
  xorps  xmm7, xmm7

  // суммируем некратный кусок
  // inc ebx // увеличим на 1, т.к. если регистр не полный то все равно нужно класть в регистр
  shr ebx, 1 // определяем сколько даблов можно положить в регистры
             // (делим на 2 оставшиеся элеенты тк регистр sse вмещает по 2 элемента)
  JMP @Vec.Pointer[Ebx*4]
  @Vec:
       DD @@1
       DD @@2
       DD @@3
       DD @@4
       DD @@5
       DD @@6
       DD @@7
       DD @@8
  @@1: // 1, 2 чисел
    movups xmm0, [esi]
    jmp @@endProg
  @@2: // 3, 4 чисел
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    addpd xmm0, xmm1

    jmp @@endProg
  @@3: // 5, 6 чисел
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    addpd xmm0, xmm1
    addpd xmm0, xmm2
    jmp @@endProg
  @@4: // 7, 8 чисел
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm0, xmm2
    jmp @@endProg
  @@5: // 10
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5
    addpd xmm0, xmm2
    addpd xmm0, xmm4
    jmp @@endProg
  @@6: // 12
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]
    movups xmm5, [esi+80]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5

    addpd xmm0, xmm2
    addpd xmm0, xmm4
    jmp @@endProg
  @@7: // 2
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]
    movups xmm5, [esi+80]
    movups xmm6, [esi+96]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5

    addpd xmm0, xmm2
    addpd xmm4, xmm6
    addpd xmm0, xmm4
    jmp @@endProg
  @@8: // 14, 15 чисел в некратном остатке
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]
    movups xmm5, [esi+80]
    movups xmm6, [esi+96]
    movups xmm7, [esi+112]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5
    addpd xmm6, xmm7
    addpd xmm0, xmm2
    addpd xmm4, xmm6
    addpd xmm0, xmm4
  @@endProg:
  // функция возвращает значение через eax???
  haddpd xmm0, xmm0
  movsd r1, xmm0
  fld r1
  fld r2
  faddp st(1), st
  // fstp st(0)
  FSTP result      // SumOfSquares := Sum1; Pop Sum1
  // fwait
  popad
end;

function SUM_SSE_d(const Data: array of double;
  first, stop: integer): Extended; overload;
// const
// zero_d: array [0..1] of Double = (0,0);
var
  r2, r1: double;
  shift: integer;
asm
  pushad
  // edx - длина массива (точнее номер hight элемента)
  // ecx - целое без остатка количество итераций по сложению буферов sse (16 даблов на итерацию)
  // ebx - остаток деления (элементы не уместившиеся в целое число итераций)
  // esi - цказатель по массиву суммируемых данных (начинается с начала адреса data и ползет до посл. элемента)
  mov esi, data // сохраняем в esi адрес массива data. В дальнейшем eax будет испорчен при делении (а указатель на data как раз лежит в eax)

  // вычисляем сдвижку начала данныхы
  mov eax, 8
  mul first;
  add esi, eax // сдвигаем начало данных

  MOV ECX, [stop] // в ecx кладем hight длина массива
  dec ecx      // уменьшаем еще на 1 элемент т.к. в xmm0 2 числа

  push edx // сохраняем т.к. edx служебный и заполняется при операции div
  // делим на 14 чтобы понять число блков кратное 14 значениям в 7-и регистрах
  sub stop, first
  MOV eax, stop
  MOV ecx, 14
  cdq
  IDIV ECX // результат автоматом попадает в eax

  MOV ECX, [stop] // в ecx кладем hight длина массива

  // сохраняем остаток от деления на 14 (неявно попадает в edx при выполнении div)
  MOV Ebx, EDX
  pop edx
  cmp ecx, 0
  jnz @@StartProg
  MOV Ebx, edx // корректируем остаток если число блоков 0

  @@StartProg:
  movups xmm0, [esi] // здесь результат сложения всех регистров
  sub ecx, 1         // прочитали блок
  js @@endSum         // переход если SF=1

  // Зануляем r2
  fldz
  fstp r2
  add esi, 16
  @@loop:            // есть полные итерации
    movups xmm1, [esi]
    movups xmm2, [esi+16]
    movups xmm3, [esi+32]
    movups xmm4, [esi+48]
    movups xmm5, [esi+64]
    movups xmm6, [esi+80]
    movups xmm7, [esi+96]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5
    addpd xmm6, xmm7

    addpd xmm0, xmm2
    addpd xmm4, xmm6
    addpd xmm0, xmm4

    add esi, 112 // указатель на следующий блок массива
    sub ecx, 1   // прочитали блок
  jns @@loop // переход если SF=1
  haddpd xmm0, xmm0
  movsd r2, xmm0

  @@endSum:
  xorps  xmm0, xmm0
  xorps  xmm1, xmm1
  xorps  xmm2, xmm2
  xorps  xmm3, xmm3
  xorps  xmm4, xmm4
  xorps  xmm5, xmm5
  xorps  xmm6, xmm6
  xorps  xmm7, xmm7

  // суммируем некратный кусок
  // inc ebx // увеличим на 1, т.к. если регистр не полный то все равно нужно класть в регистр
  shr ebx, 1 // определяем сколько даблов  можно положить в регистры
             // (делим на 2 оставшиеся элеенты тк регистр sse вмещает по 2 элемента)
  JMP @Vec.Pointer[Ebx*4]
  @Vec:
       DD @@1
       DD @@2
       DD @@3
       DD @@4
       DD @@5
       DD @@6
       DD @@7
       DD @@8
  @@1: // 1, 2 чисел
    movups xmm0, [esi]
    jmp @@endProg
  @@2: // 3, 4 чисел
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    addpd xmm0, xmm1

    jmp @@endProg
  @@3: // 5, 6 чисел
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    addpd xmm0, xmm1
    addpd xmm0, xmm2
    jmp @@endProg
  @@4: // 7, 8 чисел
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm0, xmm2
    jmp @@endProg
  @@5: // 10
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5
    addpd xmm0, xmm2
    addpd xmm0, xmm4
    jmp @@endProg
  @@6: // 12
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]
    movups xmm5, [esi+80]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5

    addpd xmm0, xmm2
    addpd xmm0, xmm4
    jmp @@endProg
  @@7: // 2
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]
    movups xmm5, [esi+80]
    movups xmm6, [esi+96]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5

    addpd xmm0, xmm2
    addpd xmm4, xmm6
    addpd xmm0, xmm4
    jmp @@endProg
  @@8: // 14, 15 чисел в некратном остатке
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    movups xmm3, [esi+48]
    movups xmm4, [esi+64]
    movups xmm5, [esi+80]
    movups xmm6, [esi+96]
    movups xmm7, [esi+112]

    addpd xmm0, xmm1
    addpd xmm2, xmm3
    addpd xmm4, xmm5
    addpd xmm6, xmm7
    addpd xmm0, xmm2
    addpd xmm4, xmm6
    addpd xmm0, xmm4
  @@endProg:
  // функция возвращает значение через eax???
  haddpd xmm0, xmm0
  movsd r1, xmm0
  fld r1
  fld r2
  faddp st(1), st
  // fstp st(0)
  FSTP result      // SumOfSquares := Sum1; Pop Sum1
  // fwait
  popad
end;

procedure FreeMemAligned(var alData: TAlignDCmpx);
var
  pint: pinteger;
begin
// если включен FastMM с опцией
{$IFDEF fastmm}
  SetLength(alData.d, 0);
{$ELSE}
  // pint := pinteger(integer(aldata.p)-4);
  // pint^:=0;
  // pint := pinteger(integer(aldata.p) - 8);
  // pint^:=0;
  FreeMemAligned(alData.p, alData.nAlignedSampl,
    alData.nAlignedSize);
  alData.p := nil;
{$ENDIF}
end;

procedure FreeMemAligned(var alData: TAlignDarray);
var
  pint: pinteger;
begin
  // если включен FastMM с опцией
{$IFDEF fastmm}
  SetLength(alData.d, 0);
{$ELSE}
  { pint := pinteger(integer(@aldata.d[0]) - 4);
    pint^:=0;
    pint := pinteger(integer(@aldata.d[0]) - 8);
    pint^:=0; }
  FreeMemAligned(alData.p, alData.nAlignedSampl,
    alData.nAlignedSize);
  alData.p := nil;
{$ENDIF}
end;

procedure FreeMemAligned(const src: pointer;
  var DstUnaligned: pointer; var DstSize: integer);
begin
  // if src <> DstUnaligned then
  // begin
  if DstUnaligned <> nil then
  begin
    FreeMem(DstUnaligned, DstSize);
  end;
  // end;
  DstUnaligned := nil;
  DstSize := 0;
end;

procedure GetMemAligned(const bits: integer; const src: pointer;
  const SrcSize: integer; out DstAligned, DstUnaligned: pointer;
  out DstSize: integer);
var
  Bytes: NativeInt;
  I: NativeInt;
begin
  if src <> nil then
  begin
    I := NativeInt(src);
    I := I shr bits;
    I := I shl bits;
    if I = NativeInt(src) then
    begin
      // the source is already aligned, nothing to do
      DstAligned := src;
      DstUnaligned := src;
      DstSize := SrcSize;
      exit;
    end;
  end;
  Bytes := 1 shl bits;
  DstSize := SrcSize + Bytes;
  GetMem(DstUnaligned, DstSize);
  FillChar(DstUnaligned^, DstSize, 0);
  I := NativeInt(DstUnaligned) + Bytes;
  I := I shr bits;
  I := I shl bits;
  DstAligned := pointer(I);
  if src <> nil then
    Move(src^, DstAligned^, SrcSize);
end;

procedure GetMemAlignedArray_cmpx_d(const SrcSize: integer;
  out alData: TAlignDCmpx);
begin
  // если включен FastMM с опцией
{$IFDEF fastmm}
  SetLength(alData.d, SrcSize);
{$ELSE}
  if alData.p <> nil then
  begin
    if SrcSize > AlignBlockLength(alData) then
    begin
      FreeMemAligned(alData);
    end
    else
      exit;
  end;
  GetMemAlignedArray_cmpx_d(4, alData.p,
    SrcSize * sizeof(TComplex_d), alData.p,
    alData.nAlignedSampl, alData.nAlignedSize);
{$ENDIF}
end;

procedure GetMemAlignedArray_cmpx_d(const bits: integer;
  const src: pointer; const SrcSize: integer;
  out DstAligned: pointer; out DstUnaligned: pointer;
  out DstSize: integer);
var
  Bytes: NativeInt;
  I: NativeInt;
  pint: pinteger;
  p: pointer;
begin
{$IFDEF fastmm}
  SetLength(DstAligned, SrcSize);
{$ELSE}
  if src <> nil then
  begin
    if SrcSize > DstSize then
    begin
      I := NativeInt(src);
      I := I shr bits;
      I := I shl bits;
      if I = NativeInt(src) then
      begin
        // the source is already aligned, nothing to do
        DstAligned := src;
        if DstUnaligned = nil then
          DstUnaligned := DstAligned;
        DstSize := SrcSize;
        // по смещению 4 лежит длина массива
        // добавлено 20.06.2021
        pint := pinteger(integer(DstAligned) - 4);
        pint^ := round(SrcSize / sizeof(TComplex_d));
        exit;
      end;
    end;
  end;
  Bytes := 1 shl bits;
  DstSize := SrcSize + Bytes;
  GetMem(DstUnaligned, DstSize);
  FillChar(DstUnaligned^, DstSize, 0);
  I := NativeInt(DstUnaligned) + Bytes;
  I := I shr bits;
  I := I shl bits;
  DstAligned := pointer(I);
  // по смещению 4 лежит длина массива
  pint := pinteger(integer(DstAligned) - 4);
  pint^ := round(SrcSize / sizeof(TComplex_d));
  // по смещению 8 лежит кол-во ссылок на интерфейс DynArray
  pint := pinteger(integer(DstAligned) - 8);
  pint^ := 1;
  if src <> nil then
    Move(src^, DstAligned, SrcSize);
{$ENDIF}
end;

procedure GetMemAlignedArray_d(const SrcSize: integer;
  out alData: TAlignDarray); overload;
begin
  // если включен FastMM с опцией
{$IFDEF fastmm}
  SetLength(alData.d, SrcSize);
{$ELSE}
  if alData.p <> nil then
  begin
    if SrcSize > AlignBlockLength(alData) then
    begin
      FreeMemAligned(alData);
    end
    else
      exit;
  end;
  GetMemAlignedArray_d(4, alData.p, // src
    SrcSize * sizeof(double), // srcSize
    alData.p, // DstAligned
    alData.nAlignedSampl, // DstUnAligned
    alData.nAlignedSize); // DstUnSize
{$ENDIF}
end;

procedure GetMemAlignedArray_d(const bits: integer;
  const src: pointer; const SrcSize: integer;
  // количество отсчетов для которого выделяем память
  out DstAligned: pointer; // TDoubleArray
  out DstUnaligned: pointer; out DstSize: integer);
var
  Bytes: NativeInt;
  I, l: NativeInt;
  pint: pinteger;
  p: pointer;
begin
{$IFDEF fastmm}
  l := SrcSize shr 3;
  SetLength(DstAligned, l);
{$ELSE}
    if src <> nil then
    begin
      // if srcsize>length(tdoublearray(DstAligned)) then
      begin
        I := NativeInt(src);
        I := I shr bits;
        I := I shl bits;
        if I = NativeInt(src) then
        begin
          // the source is already aligned, nothing to do
          DstAligned := src;
          DstUnaligned := src;
          DstSize := SrcSize;
          exit;
        end;
      end;
    end;
    Bytes := 1 shl bits;
    DstSize := SrcSize + Bytes;
    GetMem(DstUnaligned, DstSize);
    FillChar(DstUnaligned^, DstSize, 0);
    I := NativeInt(DstUnaligned) + Bytes;
    I := I shr bits;
    I := I shl bits;
    DstAligned := pointer(I);
    I := integer(DstAligned) - 4;
    pint := pinteger(I);
    pint^ := round(SrcSize / sizeof(double));
    pint := pinteger(integer(DstAligned) - 8);
    pint^ := 1;
    if src <> nil then
      Move(src^, TDoubleArray(DstAligned)[0], SrcSize);
{$ENDIF}
end;

function IsAVX2supported: boolean;
asm
    // Save EBX
    {$IFDEF CPUx86}
      push ebx
    {$ELSE CPUx64}
      // mov r10, rbx
    {$ENDIF}
    // Check CPUID.0
    xor eax, eax
    cpuid // modifies EAX,EBX,ECX,EDX
    cmp al, 7 // do we have a CPUID leaf 7 ?
    jge @Leaf7
      xor eax, eax
      jmp @Exit
    @Leaf7:
      // Check CPUID.7
      mov eax, 7h
      xor ecx, ecx
      cpuid
      bt ebx, 5 // AVX2: CPUID.(EAX=07H, ECX=0H):EBX.AVX2[bit 5]=1
      setc al
   @Exit:
   // Restore EBX
   {$IFDEF CPUx86}
     pop ebx
   {$ELSE CPUx64}
     // mov rbx, r10
   {$ENDIF}
end;

function OSEnabledXmmYmm: boolean;
// necessary to check before using AVX, FMA or AES instructions!
asm
  {$IFDEF CPUx86}
  push ebx
  {$ELSE CPUx64}
  // mov r10, rbx
  {$ENDIF}
  mov eax,1
  cpuid
  bt ecx, 27  // CPUID.1:ECX.OSXSAVE[bit 27] = 1 (XGETBV enabled for application use; implies XGETBV is an available instruction also)
  jnc @not_supported
    xor ecx,ecx // Specify control register XCR0 = XFEATURE_ENABLED_MASK register
    db 0Fh, 01h, 0D0h // xgetbv //Reads XCR (extended control register) -> EDX:EAX
    { lgdt eax = db 0Fh, 01h = privileged instruction, so don't go here unless xgetbv is allowed }
      // CHECK XFEATURE_ENABLED_MASK[2:1] = ‘11b’
      and eax, 06h // 06h= 00000000000000000000000000000110b
      cmp eax, 06h// ; check OS has enabled both XMM (bit 1) and YMM (bit 2) state management support
    jne @not_supported
      mov eax,1
      jmp @out
  @not_supported:
    xor eax,eax
  @out:
 {$IFDEF CPUx86}
  pop ebx
  {$ELSE CPUx64}
  // mov rbx, r10
  {$ENDIF}
end;

function AlignBlockLength(b: TAlignDarray): integer;
var
  pint: pinteger;
begin
  pint := pinteger(integer(b.p) - 4);
  result := pint^;
end;

function AlignBlockLength(b: TAlignDCmpx): integer;
var
  pint: pinteger;
begin
  pint := pinteger(integer(b.p) - 4);
  result := pint^;
end;

procedure FillWndHann(var a: TDoubleArray);
var
  I, N, N2: integer;
  d:double;
begin
  N := length(a) - 1;
  d:= c_2pi/N;
  for I := 0 to N do
  begin
    a[I] := 0.5 * (1 - cos(d * I));
  end;
end;

procedure FillWndHammin(var a: TDoubleArray);
var
  I, N, N2: integer;
begin
  N := length(a) - 1;
  for I := 0 to N do
  begin
    a[I] := 0.53836 - 0.46164 * cos((c_2pi * I) / (N));
  end;
END;

procedure FillWndBlackman(var a: TDoubleArray);
const
  alfa = 0.16;
  a0 = (1 - alfa) / 2;
  a1 = 0.5;
  a2 = alfa / 2;
var
  I, N, N2: integer;
begin
  N := length(a) - 1;

  for I := 0 to N do
  begin
    a[I] := a0 - a1 * cos((c_2pi * I) / (N)) + a2 * cos
      ((c_4pi * I) / (N));
  end;
end;

procedure FillWndFlattop(var a: TDoubleArray);
const
  a0 = 0.21557895;
  a1 = 0.41663158;
  a2 = 0.277263158;
  a3 = 0.083578947;
  a4 = 0.006947368;
var
  I, N, N2: integer;
begin
  N := length(a) - 1;
  for I := 0 to N do
  begin
    a[I] := a0 - a1 * cos((c_2pi * I) / (N)) + a2 * cos
      ((c_4pi * I) / (N)) - a3 * cos((c_6pi * I) / (N))
      + a4 * cos((c_8pi * I) / (N))
  end;
end;

end.
