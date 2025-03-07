﻿unit Iterative_FFT_sse;

{$H+}
//{$i 'ComplexDef.inc'}

interface

uses
  Classes, SysUtils,complex;

  function  GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean=False):TCmxArray_d;overload;
  procedure GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean; var res:TCmxArray_d);overload;
  function  GetArrayIndex(CountPoint: Integer;MinIteration: Integer):TIndexArray;
  Procedure NormalizeFFT(var FFTArray:TCmxArray_d); Inline;
  Procedure NormalizeFFTmag(var FFTArray:TCmxArray_d); Inline;overload;
  Procedure NormalizeFFTmag(var FFTArray:TCmxArray_d; Mnogitel:Double);register; assembler;overload;

  Procedure FFT(var D:TCmxArray_d; var TableExp:TCmxArray_d); register; assembler;
  Procedure iFFT(var D:TCmxArray_d; var TableExp:TCmxArray_d);register; assembler;
  // Oburec - попытка считать не одним комплектом регистров sse а двумя
  // получилось чуть медленнее
  procedure EvalFFT_al_d_sse(var Data: TCmxArray_d; var TableExp: TCmxArray_d);register; assembler;

  const
   shl4TComplex  = 3;   // {2^shl4TComplex = SizeOf(TComplex)}
   shl4TComplex_d  = 4;   // {2^shl4TComplex = SizeOf(TComplex)}

implementation


// подразумевается что число точек FFT = Length(Data)
procedure EvalFFT_al_d_sse(var Data: TCmxArray_d; // выходные данные
  var TableExp: TCmxArray_d);
assembler;
var
  J, // определяет уровень итерации
  Len, // длина блока данных (во всей процедуре)
  DPointer, // указатель на данные

  ///eval2, // можно считать второй блок вторым sse составом
  eax1, edx1, // значения регистров для второго блока
  eax2, edx2,
  TableExpPointer
  // ,SSEnum        // Распаралеливание расчета идет за счет использования 2х блоков
  // sse (для double или 4 для single), каждый использует по 3 регистра
    : integer;
asm
  // параметры идут в регистрах eax, edx, ecx
  pushAD
  // EAX - DPointer = @D[0]
  // EDI - LenBlock во всей процедуре, меняется в цикле
  // ESI - HalfBlock во всей процедуре, меняется в цикле
  // ECX - общая длина блока (изначальная)
  // EDX - @TableExp[0]
  // EBX - индекс, а затем при вычислении адресс Wn в массиве TableExp
  mov   EAX,[EAX]             // EAX       := @D[0]
  mov   ECX,[EAX-4]           // ECX       := Length(D)
  mov   Len, ECX              // Len       := Length(D);
  mov   EDI, 2                // LenBlock  := 2; EDI играет роль LenBlock во всей процедуре
  mov   ESI,1                 // HalfBlock := 1; ESI играет роль HalfBlock во всей процедуре
  mov   DPointer, EAX         // DPointer  := @D[0]
  mov   EDX, [EDX]            // EDX  := @TableExp[0]
  mov   TableExpPointer, EDX   // TableExpPointer  := @TableExp[0]

  cmp   EDI, ECX
  ja    @Exit                 // Выход, так как: LenBlock > Len

    // #################### while LenBlock <= Len do ------  begin -------------
  @Loop_LenBlock: // перебор уровней итерации. J уровень итерации, здесь перебор Fk, где k номер гармоники
  // роль k играет EBX
    mov   EBX,ESI               // EBX = (TableExpIndex := HalfBlock)
    shl   EBX,shl4TComplex_d    // Смещение для TableExp[TableExpIndex]
    add   EBX, TableExpPointer   // EBX := @TableExp[TableExpIndex]
    mov   J,0                   // J   := 0

     // #################### while J < HalfBlock do   ------- begin -------------
  @Loop_J: // перебор итераций одного уровня
    xor   ECX,ECX               // ECX - играет роль I;  I:=0;

     // ####################    while I<Len do        ------- begin -------------
  @Loop_I: // перебор итераций одного уровня
    mov   EAX,J                 // EAX := J (EAX играет роль StartIndex, J - номер уровня)
    add   EAX,ECX               // StartIndex := I+J; // i шагает через длину блока lenblock
    mov   EDX,EAX               // NChIndex   := StartIndex
    add   EDX,ESI               // NChIndex   := StartIndex+HalfBlock;
    shl   EAX,shl4TComplex_d    // Смещение для D[StartIndex] от-но D[0]
    shl   EDX,shl4TComplex_d    // Смещение для D[NChIndex]   от-но D[0]
    add   EAX,DPointer          // EAX := @D[StartIndex] // D0
    add   EDX,DPointer          // EDX := @D[NChIndex] // D1
    // запрет расчета на втором блоке
    add   ECX,EDI               // I := I+LenBlock;
    cmp   ESI, EDI
    jnb   @NotEval2             //Если I>Len повторить цикл

    mov   eax1, EAX
    mov   edx1, EDX
    // готовим адреса для второго блока
    mov   EAX,J                 // EAX := J (EAX играет роль StartIndex)
    add   EAX,ECX               // StartIndex := I+J;
    mov   EDX,EAX               // NChIndex   := StartIndex
    add   EDX,ESI               // NChIndex   := StartIndex+HalfBlock;
    shl   EAX,shl4TComplex_d    // Смещение для D[StartIndex] от-но D[0]
    shl   EDX,shl4TComplex_d    // Смещение для D[NChIndex]   от-но D[0]
    add   EAX,DPointer          // EAX := @D[StartIndex] // D0
    add   EDX,DPointer          // EDX := @D[NChIndex] // D1
    mov   eax2, EAX
    mov   edx2, EDX
    // смешанный расчет сразу по двум блокам
    // --------------------  Начали расчет FFT Fk=D0+WD1; F(k+N/2)=D0-W*D1
    // TempBn  := W*D1=D[NChIndex]*TableExp[TableExpIndex]
    // Wn=(Er;Ei) D1=(Dr;Di) W*D1= (Er*Dr-Ei*Di; Er*Di+Ei*Dr)
    MOVaPD    xmm3, [EDX]       // xmm3 = [D.Re, D.Im]
  // коррекция expInd для второго блока регистров SSE
    cmp       ECX,Len
    jnb        @ExpInd1
    MOVDDUP   xmm4, [EBX]      // xmm4 = [W.Re, W.Re]
    MOVDDUP   xmm5, [EBX+8]    // xmm5 = [W.Im, W.Im]
    Jmp       @EndExpInd
  @ExpInd1:
    MOVDDUP   xmm4, [EBX+16]    // xmm4 = [W.Re, W.Re]
    MOVDDUP   xmm5, [EBX+24]    // xmm5 = [W.Im, W.Im]
  @EndExpInd:
    MULPD     xmm5, xmm3        // xmm5 = [D.Re*W.Im, D.Im*W.Im]
    MULPD     xmm4, xmm3        // xmm4 = [D.Re*W.Re, D.Im*W.Re]
    SHUFPD    xmm5, xmm5, 1     // xmm5 = [D.Im*W.Im, D.Re*W.Im]  // поменяли местами xmm2[0] и xmm2[1]

    mov       edx, edx1         // вернули первый адрес
    MOVaPD    xmm0, [EDX]       // xmm0 = [D.Re, D.Im] // MOVaPD - два числа в оба регистра с адреса EDX
    MOVDDUP   xmm1, [EBX]       // xmm1 = [W.Re, W.Re] // MOVDDUP - одно число в оба регистра
    MOVDDUP   xmm2, [EBX+8]     // xmm2 = [W.Im, W.Im]
    MULPD     xmm2, xmm0        // xmm2 = [W.Im*D.Re, W.Im*D.Im]
    MULPD     xmm1, xmm0        // xmm1 = [W.Re*D.Re, W.Re*D.Im]
    SHUFPD    xmm2, xmm2, 1     // xmm2 = [W.Im*D.Im, W.Im*D.Re]  // поменяли местами xmm2[0] и xmm2[1]
    ADDSUBPD  xmm4, xmm5        // xmm4 = [D.Re*W.Re-D.Im*W.Im; D.Im*W.Re+D.Re*W.Im]
    ADDSUBPD  xmm1, xmm2        // xmm1 = [W.Re*D.Re-W.Im*D.Im; W.Im*D.Re+W.Re*D.Im] // ADDSUBPD первые элементы вычитаются вторые складываются
    // бабочка БПФ вперемешку двумя блоками
    MOVaPD    xmm3,  [EAX]      // xmm3 := D[StartIndex] = (D0)
    mov       EAX,   EAX1
    MOVaPD    xmm0,  [EAX]      // xmm0 := D[StartIndex] = (D0)
    MOVaPD    xmm5,  xmm3       // xmm5 := xmm3
    MOVaPD    xmm2,  xmm0       // xmm2 := xmm0
    ADDPD     xmm3,  xmm4       // xmm3 := D0+TempBn; т.к xmm4=TempBn см выше
    ADDPD     xmm0,  xmm1       // xmm0 := D0+TempBn; т.к xmm1=TempBn см выше
    SUBPD     xmm5,  xmm4       // xmm5 := D0-TempBn;
    SUBPD     xmm2,  xmm1       // xmm2 := D0-TempBn;

    MOVaPD    [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    mov       EAX, eax2
    MOVaPD    [EDX], xmm2       // D[NChIndex]   :=D0-TempBn;
    MOVaPD    [EAX], xmm3       // D[StartIndex] :=D0+TempBn;
    mov       EDX, edx2
    MOVaPD    [EDX], xmm5       // D[NChIndex]   :=D0-TempBn;


    add   ECX,EDI               // I := I+LenBlock;
    cmp   ECX,Len
    jb    @Loop_I               // Если I<Len повторить цикл}
    jmp   @NextBlock
  @NotEval2:
    ///mov   Eval2, 0
    // вертаем назад как было
    mov   Eax, Eax2
    mov   Edx, Edx2
    // --------------------  Начали расчет FFT Fk=D0+WD1; F(k+N/2)=D0-W*D1
    // TempBn  := W*D1=D[NChIndex]*TableExp[TableExpIndex]
    // Wn=(Er;Ei) D1=(Dr;Di) W*D1= (Er*Dr-Ei*Di; Er*Di+Ei*Dr)
    // -------------------------------------------------------------------
    MOVaPD    xmm0, [EDX]       // xmm0 = [D.Re, D.Im] // MOVaPD - два числа в оба регистра с адреса EDX
    MOVDDUP   xmm1, [EBX]       // xmm1 = [W.Re, W.Re] // MOVDDUP - одно число в оба регистра
    MOVDDUP   xmm2, [EBX+8]     // xmm2 = [W.Im, W.Im]
    MULPD     xmm2, xmm0        // xmm2 = [W.Im*D.Re, W.Im*D.Im]
    MULPD     xmm1, xmm0        // xmm1 = [W.Re*D.Re, W.Re*D.Im]
    SHUFPD    xmm2, xmm2, 1     // xmm2 = [W.Im*D.Im, W.Im*D.Re]  // поменяли местами xmm2[0] и xmm2[1]
    ADDSUBPD  xmm1, xmm2        // xmm1 = [W.Re*D.Re-W.Im*D.Im; W.Im*D.Re+W.Re*D.Im] // ADDSUBPD первые элементы вычитаются вторые складываются
    // --------------------  Бабочка БПФ    ---------- Begin -----------
    // D0=D[StartIndex] :=D0+TempBn;
    // D1=D[NChIndex]   :=D0-TempBn;
    // -----------------------------------------------------------------
    MOVaPD    xmm0,  [EAX]      // xmm0 := D[StartIndex] = (D0)
    MOVaPD    xmm2,  xmm0       // xmm2 := xmm0
    ADDPD     xmm0,  xmm1       // xmm0 := D0+TempBn; т.к xmm1=TempBn см выше
    SUBPD     xmm2,  xmm1       // xmm2 := D0-TempBn;
    MOVaPD    [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    MOVaPD    [EDX], xmm2       // D[NChIndex]   :=D0-TempBn;

    // если пришли сюда то уже делали приращение
    //add   ECX,EDI               // I := I+LenBlock;
    cmp   ECX,Len
    jb    @Loop_I               // Если I<Len повторить цикл}
  @NextBlock:
    // ####################    while I<Len do        ------- END  -------------
    // add   EBX, SizeOf(TComplex_d)  //Приращение адреса для TableExp[TableExpIndex]
    add   EBX, 16  // Приращение адреса для TableExp[TableExpIndex]
    inc   J
    cmp   J,ESI
    jb    @Loop_J               // Если  J < HalfBlock то повторить цикл
    // #################### while J < HalfBlock do   ------- END  -------------
    // переход на след. уровень итераций
    mov   ESI,EDI               // HalfBlock(ESI) := LenBlock;
    shl   EDI,1                 // LenBlock  := LenBlock shl 1;
    cmp   EDI,Len
    jbe   @Loop_LenBlock        // Если LenBlock <= Len то повторить цикл
    // #################### while LenBlock <= Len do ------- END  -------------
  @Exit:
     popAD
end;
// backup предыдущей функции
// подразумевается что число точек FFT = Length(Data)
procedure EvalFFT_al_d_sse__(var Data: TCmxArray_d; // выходные данные
  var TableExp: TCmxArray_d);
assembler;
var
  J, // определяет уровень итерации
  Len, // длина блока данных (во всей процедуре)
  DPointer, // указатель на данные

  ///eval2, // можно считать второй блок вторым sse составом
  eax1, edx1, // значения регистров для второго блока
  eax2, edx2,
  TableExpPointer
  // ,SSEnum        // Распаралеливание расчета идет за счет использования 2х блоков
  // sse (для double или 4 для single), каждый использует по 3 регистра
    : integer;
asm
  // параметры идут в регистрах eax, edx, ecx
  pushAD
  // EAX - DPointer = @D[0]
  // EDI - LenBlock во всей процедуре, меняется в цикле
  // ESI - HalfBlock во всей процедуре, меняется в цикле
  // ECX - общая длина блока (изначальная)
  // EDX - @TableExp[0]
  // EBX - индекс, а затем при вычислении адресс Wn в массиве TableExp
  mov   EAX,[EAX]             // EAX       := @D[0]
  mov   ECX,[EAX-4]           // ECX       := Length(D)
  mov   Len, ECX              // Len       := Length(D);
  mov   EDI, 2                // LenBlock  := 2; EDI играет роль LenBlock во всей процедуре
  mov   ESI,1                 // HalfBlock := 1; ESI играет роль HalfBlock во всей процедуре
  mov   DPointer, EAX         // DPointer  := @D[0]
  mov   EDX, [EDX]            // EDX  := @TableExp[0]
  mov   TableExpPointer, EDX   // TableExpPointer  := @TableExp[0]

  cmp   EDI, ECX
  ja    @Exit                 // Выход, так как: LenBlock > Len

    // #################### while LenBlock <= Len do ------  begin -------------
  @Loop_LenBlock: // перебор уровней итерации. J уровень итерации, здесь перебор Fk, где k номер гармоники
  // роль k играет EBX
    mov   EBX,ESI               // EBX = (TableExpIndex := HalfBlock)
    shl   EBX,shl4TComplex_d    // Смещение для TableExp[TableExpIndex]
    add   EBX, TableExpPointer   // EBX := @TableExp[TableExpIndex]
    mov   J,0                   // J   := 0

     // #################### while J < HalfBlock do   ------- begin -------------
  @Loop_J: // перебор итераций одного уровня
    xor   ECX,ECX               // ECX - играет роль I;  I:=0;

     // ####################    while I<Len do        ------- begin -------------
  @Loop_I: // перебор итераций одного уровня
    mov   EAX,J                 // EAX := J (EAX играет роль StartIndex, J - номер уровня)
    add   EAX,ECX               // StartIndex := I+J; // i шагает через длину блока lenblock
    mov   EDX,EAX               // NChIndex   := StartIndex
    add   EDX,ESI               // NChIndex   := StartIndex+HalfBlock;
    shl   EAX,shl4TComplex_d    // Смещение для D[StartIndex] от-но D[0]
    shl   EDX,shl4TComplex_d    // Смещение для D[NChIndex]   от-но D[0]
    add   EAX,DPointer          // EAX := @D[StartIndex] // D0
    add   EDX,DPointer          // EDX := @D[NChIndex] // D1
    // запрет расчета на втором блоке
    add   ECX,EDI               // I := I+LenBlock;
    ///cmp   ECX,Len
    cmp   ESI, EDI
    jnb   @NotEval2             //Если I>Len повторить цикл
    //jb   @NotEval2             //Если I>Len повторить цикл

    mov   eax1, EAX
    mov   edx1, EDX
    // готовим адреса для второго блока
    mov   EAX,J                 // EAX := J (EAX играет роль StartIndex)
    add   EAX,ECX               // StartIndex := I+J;
    mov   EDX,EAX               // NChIndex   := StartIndex
    add   EDX,ESI               // NChIndex   := StartIndex+HalfBlock;
    shl   EAX,shl4TComplex_d    // Смещение для D[StartIndex] от-но D[0]
    shl   EDX,shl4TComplex_d    // Смещение для D[NChIndex]   от-но D[0]
    add   EAX,DPointer          // EAX := @D[StartIndex] // D0
    add   EDX,DPointer          // EDX := @D[NChIndex] // D1
    mov   eax2, EAX
    mov   edx2, EDX
    // смешанный расчет сразу по двум блокам
    // --------------------  Начали расчет FFT Fk=D0+WD1; F(k+N/2)=D0-W*D1
    // TempBn  := W*D1=D[NChIndex]*TableExp[TableExpIndex]
    // Wn=(Er;Ei) D1=(Dr;Di) W*D1= (Er*Dr-Ei*Di; Er*Di+Ei*Dr)
    MOVaPD    xmm3, [EDX]       // xmm3 = [D.Re, D.Im]
  // коррекция expInd для второго блока регистров SSE
    cmp       ECX,Len
    jnb        @ExpInd1
    MOVDDUP   xmm4, [EBX]      // xmm4 = [W.Re, W.Re]
    MOVDDUP   xmm5, [EBX+8]    // xmm5 = [W.Im, W.Im]
    Jmp       @EndExpInd
  @ExpInd1:
    MOVDDUP   xmm4, [EBX+16]    // xmm4 = [W.Re, W.Re]
    MOVDDUP   xmm5, [EBX+24]    // xmm5 = [W.Im, W.Im]
  @EndExpInd:
    MULPD     xmm5, xmm3        // xmm5 = [D.Re*W.Im, D.Im*W.Im]
    MULPD     xmm4, xmm3        // xmm4 = [D.Re*W.Re, D.Im*W.Re]
    SHUFPD    xmm5, xmm5, 1     // xmm5 = [D.Im*W.Im, D.Re*W.Im]  // поменяли местами xmm2[0] и xmm2[1]

    mov       edx, edx1         // вернули первый адрес
    MOVaPD    xmm0, [EDX]       // xmm0 = [D.Re, D.Im] // MOVaPD - два числа в оба регистра с адреса EDX
    MOVDDUP   xmm1, [EBX]       // xmm1 = [W.Re, W.Re] // MOVDDUP - одно число в оба регистра
    MOVDDUP   xmm2, [EBX+8]     // xmm2 = [W.Im, W.Im]
    MULPD     xmm2, xmm0        // xmm2 = [W.Im*D.Re, W.Im*D.Im]
    MULPD     xmm1, xmm0        // xmm1 = [W.Re*D.Re, W.Re*D.Im]
    SHUFPD    xmm2, xmm2, 1     // xmm2 = [W.Im*D.Im, W.Im*D.Re]  // поменяли местами xmm2[0] и xmm2[1]
    ADDSUBPD  xmm4, xmm5        // xmm4 = [D.Re*W.Re-D.Im*W.Im; D.Im*W.Re+D.Re*W.Im]
    ADDSUBPD  xmm1, xmm2        // xmm1 = [W.Re*D.Re-W.Im*D.Im; W.Im*D.Re+W.Re*D.Im] // ADDSUBPD первые элементы вычитаются вторые складываются
    // бабочка БПФ вперемешку двумя блоками
    MOVaPD    xmm3,  [EAX]      // xmm3 := D[StartIndex] = (D0)
    mov       EAX,   EAX1
    MOVaPD    xmm0,  [EAX]      // xmm0 := D[StartIndex] = (D0)
    MOVaPD    xmm5,  xmm3       // xmm5 := xmm3
    MOVaPD    xmm2,  xmm0       // xmm2 := xmm0
    ADDPD     xmm3,  xmm4       // xmm3 := D0+TempBn; т.к xmm4=TempBn см выше
    ADDPD     xmm0,  xmm1       // xmm0 := D0+TempBn; т.к xmm1=TempBn см выше
    SUBPD     xmm5,  xmm4       // xmm5 := D0-TempBn;
    SUBPD     xmm2,  xmm1       // xmm2 := D0-TempBn;

    MOVaPD    [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    mov       EAX, eax2
    MOVaPD    [EDX], xmm2       // D[NChIndex]   :=D0-TempBn;
    MOVaPD    [EAX], xmm3       // D[StartIndex] :=D0+TempBn;
    mov       EDX, edx2
    MOVaPD    [EDX], xmm5       // D[NChIndex]   :=D0-TempBn;


    add   ECX,EDI               // I := I+LenBlock;
    cmp   ECX,Len
    jb    @Loop_I               // Если I<Len повторить цикл}
    jmp   @NextBlock
  @NotEval2:
    ///mov   Eval2, 0
    // вертаем назад как было
    mov   Eax, Eax2
    mov   Edx, Edx2
    // --------------------  Начали расчет FFT Fk=D0+WD1; F(k+N/2)=D0-W*D1
    // TempBn  := W*D1=D[NChIndex]*TableExp[TableExpIndex]
    // Wn=(Er;Ei) D1=(Dr;Di) W*D1= (Er*Dr-Ei*Di; Er*Di+Ei*Dr)
    // -------------------------------------------------------------------
    MOVaPD    xmm0, [EDX]       // xmm0 = [D.Re, D.Im] // MOVaPD - два числа в оба регистра с адреса EDX
    MOVDDUP   xmm1, [EBX]       // xmm1 = [W.Re, W.Re] // MOVDDUP - одно число в оба регистра
    MOVDDUP   xmm2, [EBX+8]     // xmm2 = [W.Im, W.Im]
    MULPD     xmm2, xmm0        // xmm2 = [W.Im*D.Re, W.Im*D.Im]
    MULPD     xmm1, xmm0        // xmm1 = [W.Re*D.Re, W.Re*D.Im]
    SHUFPD    xmm2, xmm2, 1     // xmm2 = [W.Im*D.Im, W.Im*D.Re]  // поменяли местами xmm2[0] и xmm2[1]
    ADDSUBPD  xmm1, xmm2        // xmm1 = [W.Re*D.Re-W.Im*D.Im; W.Im*D.Re+W.Re*D.Im] // ADDSUBPD первые элементы вычитаются вторые складываются
    // --------------------  Бабочка БПФ    ---------- Begin -----------
    // D0=D[StartIndex] :=D0+TempBn;
    // D1=D[NChIndex]   :=D0-TempBn;
    // -----------------------------------------------------------------
    MOVaPD    xmm0,  [EAX]      // xmm0 := D[StartIndex] = (D0)
    MOVaPD    xmm2,  xmm0       // xmm2 := xmm0
    ADDPD     xmm0,  xmm1       // xmm0 := D0+TempBn; т.к xmm1=TempBn см выше
    SUBPD     xmm2,  xmm1       // xmm2 := D0-TempBn;
    MOVaPD    [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    MOVaPD    [EDX], xmm2       // D[NChIndex]   :=D0-TempBn;

    // если пришли сюда то уже делали приращение
    //add   ECX,EDI               // I := I+LenBlock;
    cmp   ECX,Len
    jb    @Loop_I               // Если I<Len повторить цикл}
  @NextBlock:
    // ####################    while I<Len do        ------- END  -------------
    // add   EBX, SizeOf(TComplex_d)  //Приращение адреса для TableExp[TableExpIndex]
    add   EBX, 16  // Приращение адреса для TableExp[TableExpIndex]
    inc   J
    cmp   J,ESI
    jb    @Loop_J               // Если  J < HalfBlock то повторить цикл
    // #################### while J < HalfBlock do   ------- END  -------------
    // переход на след. уровень итераций
    mov   ESI,EDI               // HalfBlock(ESI) := LenBlock;
    shl   EDI,1                 // LenBlock  := LenBlock shl 1;
    cmp   EDI,Len
    jbe   @Loop_LenBlock        // Если LenBlock <= Len то повторить цикл
    // #################### while LenBlock <= Len do ------- END  -------------
  @Exit:
     popAD
end;

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
var
  I,StartIndex,N,LenB:Integer;
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

procedure GetFFTExpTable(CountFFTPoints:Integer; InverseFFT:Boolean; var res:TCmxArray_d);
var
  I,StartIndex,N,LenB:Integer;
  w,wn:TComplex_d;
  Mnogitel:Double;
begin

  Mnogitel := -2*Pi;               //Прямое  БПФ

  if InverseFFT then
     Mnogitel:= 2*Pi;              //Обратное  БПФ

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
        res[StartIndex+I]:=w;
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
procedure FFT(var D: TCmxArray; var TableExp: TCmxArray);

Итеративынй метод БПФ (прореживание по времени), над данными D,
которые должны быть расположены согласно нижней итерации БПФ,
для этого есть проц GetArrayIndex, которая вернет массив, в котором расположены
индексы 0..Length(D), в той последовательности которая нужна.
В нашем случае в процедуру  GetArrayIndex нужно передать MinIteration = 2

TableExp - массив Exp множителей для БПФ, созданный GetFFTExpTable
После отработки, массив D, будет содержать БПФ входного массива D
Т.е преобразование проходит на месте, без создания копий}
procedure FFT(var D: TCmxArray_d; var TableExp: TCmxArray_d);register; assembler;
var
    J,Len, sof,DPointer,TableExpPointer:Integer;
asm
    // параметры идут в регистрах eax, edx, ecx
    pushAD
    // EAX - DPointer = @D[0]
    // EDI - LenBlock во всей процедуре, меняется в цикле
    // ESI - HalfBlock во всей процедуре, меняется в цикле
    // ECX - общая длина блока (изначальная)
    // EDX - @TableExp[0]
    // EBX - индекс, а затем при вычислении адресс Wn в массиве TableExp
    mov   EAX,[EAX]             //EAX       := @D[0]
    mov   ECX,[EAX-4]           //ECX       := Length(D)
    // закомент от 30.07.19 Oburec - иначе портится длина динамического массива [d(0-4)]
    ///inc   ECX                //ECX       := Length(D)
    mov   Len, ECX              //Len       := Length(D);
    mov   EDI, 2                //LenBlock  := 2; EDI играет роль LenBlock во
                                //всей процедуре
    mov   ESI,1                 //HalfBlock := 1; ESI играет роль HalfBlock во
                                //всей процедуре
    mov   DPointer, EAX         //DPointer  := @D[0]
    mov   EDX, [EDX]            // EDX  := @TableExp[0]
    mov   TableExpPointer,EDX   //TableExpPointer  := @TableExp[0]

    cmp   EDI, ECX
    ja    @Exit                 //Выход, так как: LenBlock > Len

    //#################### while LenBlock <= Len do ------  begin -------------
  @Loop_LenBlock: // перебор итераций J - уровень итерации
    mov   EBX,ESI               // EBX = (TableExpIndex := HalfBlock)
    shl   EBX,shl4TComplex_d    // Смещение для TableExp[TableExpIndex]
    add   EBX, TableExpPointer   // EBX := @TableExp[TableExpIndex]
    mov   J,0                   // J   := 0

     //#################### while J < HalfBlock do   ------- begin -------------
  @Loop_J: // перебор итераций одного уровня
    xor   ECX,ECX               //ECX - играет роль I;  I:=0;

     //####################    while I<Len do        ------- begin -------------
  @Loop_I: // перебор итераций одного уровня
    mov   EAX,J                 //EAX := J (EAX играет роль StartIndex)
    add   EAX,ECX               //StartIndex := I+J;
    mov   EDX,EAX               //NChIndex   := StartIndex
    add   EDX,ESI               //NChIndex   := StartIndex+HalfBlock;
    shl   EAX,shl4TComplex_d    //Смещение для D[StartIndex] от-но D[0]
    shl   EDX,shl4TComplex_d    //Смещение для D[NChIndex]   от-но D[0]
    add   EAX,DPointer          //EAX := @D[StartIndex] // D0
    add   EDX,DPointer          //EDX := @D[NChIndex] // D1


    //--------------------  Начали расчет  TempBn -----------------------
    //           TempBn  := D[NChIndex]*TableExp[TableExpIndex]
    // Обозначим: L = D[NChIndex];   R = TableExp[TableExpIndex]
    //-------------------------------------------------------------------
    MOVaPD    xmm0, [EDX]       //xmm0 = [L.Re, L.Im]
    MOVDDUP   xmm1, [EBX]       //xmm1 = [R.Re, R.Re]
    MOVDDUP   xmm2, [EBX+8]     //xmm2 = [R.Im, R.Im]
    MULPD     xmm2, xmm0        //xmm2 = [L.Re*R.Im, L.Im*R.Im]
    MULPD     xmm1, xmm0        //xmm1 = [L.Re*R.Re, L.Im*R.Re]
    SHUFPD    xmm2, xmm2, 1     //xmm2 = [L.Im*R.Im, L.Re*R.Im]  // поменяли местами xmm2[0] и xmm2[1]
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

    add   ECX,EDI               //I := I+LenBlock;
    cmp   ECX,Len
    jb    @Loop_I               //Если I<Len повторить цикл
    //####################    while I<Len do        ------- END  -------------
    //add   EBX, SizeOf(TComplex_d)  //Приращение адреса для TableExp[TableExpIndex]
    add   EBX, 16  //Приращение адреса для TableExp[TableExpIndex] // INC(TableExpIndex)
    inc   J
    cmp   J,ESI
    jb    @Loop_J               //Если  J < HalfBlock то повторить цикл
    //#################### while J < HalfBlock do   ------- END  -------------

    mov   ESI,EDI               //HalfBlock(ESI) := LenBlock;
    shl   EDI,1                 //LenBlock  := LenBlock shl 1;
    cmp   EDI,Len
    jbe   @Loop_LenBlock        //Если LenBlock <= Len то повторить цикл
    //#################### while LenBlock <= Len do ------- END  -------------
  @Exit:
     popAD
end;

{-------------------------------------------------------------------------------
procedure iFFT(var D: TCmxArray; var TableExp: TCmxArray);

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
procedure iFFT(var D: TCmxArray_d; var TableExp: TCmxArray_d);register; assembler;
var N:Integer;
asm
  pushad
  call  FFT

  mov   EAX,[EAX]           //EAX := @D[0]
  mov   ECX,[EAX-4]         //ECX := High(D)
  inc   ECX                 //ECX := Length(D)
  mov   N,ECX               //N   := Length(D)

  fild  N                   //Поместили в  стек FPU, N

  //####################  цикл нормализации       --------- begin ------------
@Normalize:
  /// fld   TComplex.Re [EAX]    //Поместили в стек FPU, D[Index].Re
  fld   [EAX]    //Поместили в стек FPU, D[Index].Re
  fld   ST(1)                //ST := ST(1) = N
  fdiv                       //St(0) =  D[Index].Re/N
  ///fstp  TComplex.Re [EAX]    //Записали St(0) в D[Index].Re
  fstp  [EAX]    //Записали St(0) в D[Index].Re
  ///add   EAX,SizeOf(TComplex) //Приращение индексa, для массивa D.
  add   EAX, 16 //Приращение индексa, для массивa D.
  loop  @Normalize           //Повторить пока ECX<>0
  //####################  цикл нормализации       ----------- END ------------
  popad
end;

{-------------------------------------------------------------------------------
procedure  NormalizeFFTmag(var FFTArray: TCmxArray);
Процедура стандартной нормализации (выделение амплитуды)
яв-ся интерфейсом для вызова функции
NormalizeFFTmag(var FFTArray: TCmxArray; Mnogitel: Double);

Нормализация имеет вид:  FFTArray[I].Re:=abs(FFTArray[I])/(N/2);
что соответствует, выделению амплитуды сигнала...

Например в MathCad идет нормализация на 1/sqrt(N),
что не яв-ся амплитудой сигнала.
Где N = Length(FFTArray)}
procedure NormalizeFFTmag(var FFTArray: TCmxArray_d);
begin
   NormalizeFFTmag(FFTArray, 2/Length(FFTArray));
end;


{-------------------------------------------------------------------------------
procedure NormalizeFFTmag(var FFTArray: TCmxArray; Mnogitel: Double);

Процедура Нормализации вектора данных, полученных при помощи БПФ,
после обработки массив будет иметь только реальные значения в первой половине
, вторая половина массива не обрабатывается она яв-ся зеркальным
отражением первой половины массива FFTArray.

Нормализация имеет вид:  FFTArray[I].Re:=abs(FFTArray[I])*Mnogitel;
что дает возможность менять множитель и проводить нужную нормализацию}
procedure NormalizeFFTmag(var FFTArray: TCmxArray_d; Mnogitel: Double);register; assembler;
asm
   mov   EAX,[EAX]     //EAX := @D[0]
   mov   ECX,[EAX-4]   //ECX := High(D)
   ///inc   ECX           //ECX = Length(FFTArray); inc т.к в FPC по смещению
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

   ///add   EAX,SizeOf(TComplex)  //Приращение индексa, для массивa D
   add   EAX, 16  //Приращение индексa, для массивa D
   loop  @Normalize            //Повторить пока ECX<>0
    //####################  цикл нормализации       ----------- END ------------
end;

Procedure NormalizeFFT(var FFTArray:TCmxArray_d); Inline;
begin

end;

end.
