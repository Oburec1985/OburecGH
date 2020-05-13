unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Memo2: TMemo;
    Memo3: TMemo;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
type
  TArr = packed array [0..3] of Double;
const
  iTimes = 100000000;
  iSize = 3;
var
  i, k: Integer;
  Fr, t: Int64;
  Dt: Extended;
  arr1, arr2, arr3: array [0 .. iSize] of Single;
  s1, s2, s3 : Single;
  arr1_avx, arr2_avx: TArr;

  procedure vec4_dot_avx(var arr1_avx, arr2_avx: TArr);
    begin
      {$IFDEF CPUX64}
      asm
        vmovupd ymm0, [rcx] //; ymm0 = *a
        vmovupd ymm1, [rdx] //; ymm1 = *b

        vmulpd ymm0, ymm0, ymm1 //; ymm0 = ( a3 * b3, a2 * b2, a1 * b1, a0 * b0 )

        vmovupd [arr1_avx], ymm0
      end;
      {$ELSE}
      asm
        //mov eax, [esp + 8 + 0] //; eax = a
        //mov edx, [esp + 8 + 8] //; edx = b
        //vmovupd ymm0, [eax] //; ymm0 = *a
        //vmovupd ymm1, [edx] //; ymm1 = *b
      end;
      {$ENDIF}

    end;

begin
  // Определяем тактовую частоту процессора (количество тактов в секунду).
  QueryPerformanceFrequency(Fr);
  if Fr = 0 then
  begin
    ShowMessage('Не удалось получить сведения о тактовой частоте.');
    Exit;
  end;
  // ShowMessage('Тактовая частота процессора (количество тактов в секунду): ' + IntToStr(Fr));
  Memo1.Text := Memo1.Text + 'Частота: '#9#9 + FloatToStrF(Fr, ffnumber, 20, 0) + #13#10;

  for k := 0 to iSize do
  begin
    arr1[k] := Fr + k;
    arr2[k] := (Fr + k) * 2;
  end;

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo1.Text := Memo1.Text + 'Pascal' + #13#10;
  Memo1.Text := Memo1.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  // Запуск исследуемого процесса.
  // for i := 1 to iTimes do Sleep(10);
  for i := 1 to iTimes do
  begin
    {for k := 0 to iSize do
    begin
      arr3[k] := arr1[k] * arr2[k];
    end;}
    arr3[0] := arr1[0] * arr2[0];
    arr3[1] := arr1[1] * arr2[1];
    arr3[2] := arr1[2] * arr2[2];
    arr3[3] := arr1[3] * arr2[3];
  end;

  // Показание счётчика тактов.
  QueryPerformanceCounter(t);
  Memo1.Text := Memo1.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  // Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF((t-Dt)/iTimes, ffnumber, 20, 0) + #13#10;
  Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  // ShowMessage('Усреднённая длительность выполнения в секундах: ' + FloatToStr(Dt));
  Memo1.Text := Memo1.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + #13#10;

  // ------ ASM ----------------------------

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo1.Text := Memo1.Text + 'ASM' + #13#10;
  Memo1.Text := Memo1.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  for i := 1 to iTimes do
  begin
      //for k  := 0 to iSize do
      begin
        //s1 := arr1[k];
        //s2 := arr2[k];
        //s3 := 0;
        asm
          {//mov [arr1[0]], s
          //mov eax, arr1[0]
          fld dword ptr [arr1[1]]
          //fld [s2]
          //movss EDX, arr1[0]
          //MOV ESX, [arr2[0]]
          //MOV EBX, [arr3[0]]
          //fld dword ptr [EDX]
          //fld dword ptr [ESX]
          FMUL [s2]
          //fstp dword ptr [EBX]
          fstp [s3]}

          fld dword ptr [arr1[0]]
          FMUL dword ptr [arr2[0]]
          fstp dword ptr [arr3[0]]

          fld dword ptr [arr1[1]]
          FMUL dword ptr [arr2[1]]
          fstp dword ptr [arr3[1]]

          fld dword ptr [arr1[2]]
          FMUL dword ptr [arr2[2]]
          fstp dword ptr [arr3[2]]

          fld dword ptr [arr1[3]]
          FMUL dword ptr [arr2[3]]
          fstp dword ptr [arr3[3]]
        end;
        //arr3[k] := s3;
      end;

  end;

  QueryPerformanceCounter(t);
  Memo1.Text := Memo1.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  Memo1.Text := Memo1.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + #13#10;

  // ------ ASM AVX ----------------------------

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo1.Text := Memo1.Text + 'ASM AVX' + #13#10;
  Memo1.Text := Memo1.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  for i := 1 to iTimes do
  begin
      //for k  := 0 to iSize do
      begin
        vec4_dot_avx(arr1_avx, arr2_avx);
      end;

  end;

  QueryPerformanceCounter(t);
  Memo1.Text := Memo1.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  Memo1.Text := Memo1.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + #13#10;

  // ------ SSE ----------------------------

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo1.Text := Memo1.Text + 'SSE' + #13#10;
  Memo1.Text := Memo1.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  for i := 1 to iTimes do
  begin
      asm
        movups xmm0, [arr1]
        movups xmm1, [arr2]
        mulps xmm0, xmm1
        movups [arr3], xmm0
      end;

  end;

  QueryPerformanceCounter(t);
  Memo1.Text := Memo1.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  Memo1.Text := Memo1.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + #13#10;

  // ------ SSE параллельно ----------------------------

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo1.Text := Memo1.Text + 'SSE параллельно' + #13#10;
  Memo1.Text := Memo1.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  for i := 1 to Round(iTimes/4) do
  begin
      asm
        movups xmm0, [arr1]
        movups xmm1, [arr2]
        mulps xmm0, xmm1
        movups [arr3], xmm0

        movups xmm2, [arr1]
        movups xmm3, [arr2]
        mulps xmm2, xmm3
        movups [arr3], xmm2

        movups xmm4, [arr1]
        movups xmm5, [arr2]
        mulps xmm4, xmm5
        movups [arr3], xmm4

        movups xmm6, [arr1]
        movups xmm7, [arr2]
        mulps xmm6, xmm7
        movups [arr3], xmm6


      end;

  end;

  QueryPerformanceCounter(t);
  Memo1.Text := Memo1.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  Memo1.Text := Memo1.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + '----------------------------------' + #13#10;

  SendMessage(Memo1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TForm1.Button2Click(Sender: TObject);
const
  PF_FLOATING_POINT_PRECISION_ERRATA  = 0; // On a Pentium, a floating-point precision error can occur in rare circumstances.
  PF_FLOATING_POINT_EMULATED          = 1; // Floating-point operations are emulated using a software emulator.
                                           // This function returns a nonzero value if floating-point operations are emulated; otherwise, it returns zero.
  PF_COMPARE_EXCHANGE_DOUBLE          = 2; // The atomic compare and exchange operation (cmpxchg) is available.
  PF_MMX_INSTRUCTIONS_AVAILABLE       = 3; // The MMX instruction set is available.
  PF_PPC_MOVEMEM_64BIT_OK             = 4;
  PF_ALPHA_BYTE_INSTRUCTIONS          = 5;
  PF_XMMI_INSTRUCTIONS_AVAILABLE      = 6; // The SSE instruction set is available.
  PF_3DNOW_INSTRUCTIONS_AVAILABLE     = 7; // The 3D-Now instruction set is available.
  PF_RDTSC_INSTRUCTION_AVAILABLE      = 8; // The RDTSC instruction is available.
  PF_PAE_ENABLED                      = 9; // The processor is PAE-enabled. For more information, see Physical Address Extension.
                                           // All x64 processors always return a nonzero value for this feature.
  PF_XMMI64_INSTRUCTIONS_AVAILABLE    = 10; // The SSE2 instruction set is available.
                                            // Windows 2000:  This feature is not supported.
  PF_SSE_DAZ_MODE_AVAILABLE           = 11;
  PF_NX_ENABLED                       = 12; // Data execution prevention is enabled.
                                            // Windows XP/2000:  This feature is not supported until Windows XP with SP2 and Windows Server 2003 with SP1.
  PF_SSE3_INSTRUCTIONS_AVAILABLE      = 13; // The SSE3 instruction set is available.
                                            // Windows Server 2003 and Windows XP/2000:  This feature is not supported.
  PF_COMPARE_EXCHANGE128              = 14; // The atomic compare and exchange 128-bit operation (cmpxchg16b) is available.
                                            // Windows Server 2003 and Windows XP/2000:  This feature is not supported.
  PF_COMPARE64_EXCHANGE128            = 15; // The atomic compare 64 and exchange 128-bit operation (cmp8xchg16) is available.
                                            // Windows Server 2003 and Windows XP/2000:  This feature is not supported.
  PF_CHANNELS_ENABLED                 = 16; // The processor channels are enabled.
  PF_XSAVE_ENABLED                    = 17; // The processor implements the XSAVE and XRSTOR instructions.
                                            // Windows Server 2008, Windows Vista, Windows Server 2003 and Windows XP/2000:  This feature is not supported until Windows 7 and Windows Server 2008 R2.
  PF_ARM_VFP_32_REGISTERS_AVAILABLE   = 18; // The VFP/Neon: 32 x 64bit register bank is present. This flag has the same meaning as PF_ARM_VFP_EXTENDED_REGISTERS.

  PF_SECOND_LEVEL_ADDRESS_TRANSLATION = 20; // Second Level Address Translation is supported by the hardware.
  PF_VIRT_FIRMWARE_ENABLED            = 21; // Virtualization is enabled in the firmware.
  PF_RDWRFSGSBASE_AVAILABLE           = 22; // RDFSBASE, RDGSBASE, WRFSBASE, and WRGSBASE instructions are available.
  PF_FASTFAIL_AVAILABLE               = 23; // _fastfail() is available.
  PF_ARM_DIVIDE_INSTRUCTION_AVAILABLE = 24; // The divide instructions are available.
  PF_ARM_64BIT_LOADSTORE_ATOMIC       = 25; // The 64-bit load/store atomic instructions are available.
  PF_ARM_EXTERNAL_CACHE_AVAILABLE     = 26; // The external cache is available.
  PF_ARM_FMAC_INSTRUCTIONS_AVAILABLE  = 27; // The floating-point multiply-accumulate instruction is available.
var
  i : integer;
begin
  Memo2.Text := '';
  for i := 0 to 27 do
    Memo2.Text := Memo2.Text + IntToStr(i) + ' = ' + BoolToStr( IsProcessorFeaturePresent(i), true ) + #13#10;
end;

    procedure GetMemAligned(const bits: Integer; const src: Pointer;
      const SrcSize: Integer; out DstAligned, DstUnaligned: Pointer;
      out DstSize: Integer);
    var
      Bytes: NativeInt;
      i: NativeInt;
    begin
      if src <> nil then
      begin
        i := NativeInt(src);
        i := i shr bits;
        i := i shl bits;
        if i = NativeInt(src) then
        begin
          // the source is already aligned, nothing to do
          DstAligned := src;
          DstUnaligned := src;
          DstSize := SrcSize;
          Exit;
        end;
      end;
      Bytes := 1 shl bits;
      DstSize := SrcSize + Bytes;
      GetMem(DstUnaligned, DstSize);
      FillChar(DstUnaligned^, DstSize, 0);
      i := NativeInt(DstUnaligned) + Bytes;
      i := i shr bits;
      i := i shl bits;
      DstAligned := Pointer(i);
      if src <> nil then
        Move(src^, DstAligned^, SrcSize);
    end;

    procedure FreeMemAligned(const src: Pointer; var DstUnaligned: Pointer;
      var DstSize: Integer);
    begin
      if src <> DstUnaligned then
      begin
        if DstUnaligned <> nil then
          FreeMem(DstUnaligned, DstSize);
      end;
      DstUnaligned := nil;
      DstSize := 0;
    end;

procedure TForm1.Button3Click(Sender: TObject);
type
  TVector = packed array [0..3] of Single;
  PVector = ^TVector;
const
  iTimes = 10000;
  iSize = 100003;
  //SizeAligned = SizeOf(TVector);
var
  i, k, m, n: Integer;
  Fr, t: Int64;
  Dt: Extended;
  arr1: array [0 .. iSize] of Double;
  arr2, arr3: array [0 .. 1] of Double;
  s1, s2, s3, res : Double; //Single;
  DataUnaligned1, DataAligned1, DataUnaligned2, DataAligned2: Pointer;
  SizeUnaligned1, SizeUnaligned2: Integer;
  V1, V2: PVector;
  TV1, TV2 : TVector;

procedure add4(const a, b: TVector; out Result: TVector); register; assembler;
asm
  movaps xmm0, [eax]
  movaps xmm1, [edx]
  addps xmm0, xmm1
  movaps [ecx], xmm0
end;

procedure add4_avx(const a, b: TVector; out Result: TVector); register; assembler;
asm
  // {$IFDEF CPUX64}
  ///vmovupd ymm0, [rcx]
  ///vmovupd ymm1, [rdx]
 /// vaddps ymm0, ymm1, ymm0
 /// vmovupd [Result], ymm0
  //{$ENDIF}
end;

function IsAVX2supported: boolean;
asm
    // Save EBX
    {$IFDEF CPUx86}
      push ebx
    {$ELSE CPUx64}
      //mov r10, rbx
    {$ENDIF}
    //Check CPUID.0
    xor eax, eax
    cpuid //modifies EAX,EBX,ECX,EDX
    cmp al, 7 // do we have a CPUID leaf 7 ?
    jge @Leaf7
      xor eax, eax
      jmp @Exit
    @Leaf7:
      //Check CPUID.7
      mov eax, 7h
      xor ecx, ecx
      cpuid
      bt ebx, 5 //AVX2: CPUID.(EAX=07H, ECX=0H):EBX.AVX2[bit 5]=1
      setc al
   @Exit:
   // Restore EBX
   {$IFDEF CPUx86}
     pop ebx
   {$ELSE CPUx64}
     //mov rbx, r10
   {$ENDIF}
end;

function OSEnabledXmmYmm: boolean;
// necessary to check before using AVX, FMA or AES instructions!
asm
  {$IFDEF CPUx86}
  push ebx
  {$ELSE CPUx64}
  //mov r10, rbx
  {$ENDIF}
  mov eax,1
  cpuid
  bt ecx, 27  // CPUID.1:ECX.OSXSAVE[bit 27] = 1 (XGETBV enabled for application use; implies XGETBV is an available instruction also)
  jnc @not_supported
    xor ecx,ecx //Specify control register XCR0 = XFEATURE_ENABLED_MASK register
    db 0Fh, 01h, 0D0h // xgetbv //Reads XCR (extended control register) -> EDX:EAX
    {lgdt eax = db 0Fh, 01h = privileged instruction, so don't go here unless xgetbv is allowed}
      //CHECK XFEATURE_ENABLED_MASK[2:1] = ‘11b’
      and eax, 06h //06h= 00000000000000000000000000000110b
      cmp eax, 06h//; check OS has enabled both XMM (bit 1) and YMM (bit 2) state management support
    jne @not_supported
      mov eax,1
      jmp @out
  @not_supported:
    xor eax,eax
  @out:
 {$IFDEF CPUx86}
  pop ebx
  {$ELSE CPUx64}
  //mov rbx, r10
  {$ENDIF}
end;

function SUM_SSE(const Data: array of Double): Extended;
const
  MaxDouble = (High(Integer) - $F) div sizeof(Double);
  reg = 2;
  reg_by_block = 14;
type
  bigArray = array of Double;
  pMyArray = ^bigArray;

  TDoubleArray = packed array [0..MaxDouble] of Double;
  PDoubleArray = ^TDoubleArray;

const
  SizeAligned = SizeOf(TDoubleArray);

var
  work_array : array of Double;
  Pwork_array: PDoubleArray;
  pTemp: ^bigArray;
  iSize, iSize_block, i : Integer;
  res : array [0..1] of Double;
begin
  iSize := Length(Data);

  if iSize = 0 then
    begin
      Result := 0;
      Exit;
    end;

  if iSize = 1 then
    begin
      Result := Data[0];
      Exit;
    end;

  iSize_block := (iSize - reg) div reg_by_block; // сколько блоков без 1
  if ((iSize - reg) mod reg_by_block) > 0 then
    begin
      iSize_block := iSize_block + 1;
    end;

  iSize := iSize_block*reg_by_block + reg;
  //getMem (Pwork_array, iSize * sizeof(Double));
  //getMem (Pwork_array, iSize);
  //getMem (Pointer(work_array), iSize);

  //GetMemAligned(4 {align by 4 bits, i.e. by 16 bytes}, Pwork_array, iSize {SizeAligned}, DataAligned1, DataUnaligned1, SizeUnaligned1);
  //Pwork_array := @Data;
  GetMemAligned(4 {align by 4 bits, i.e. by 16 bytes}, @Data, iSize * sizeof(Double) {SizeAligned}, Pointer(Pwork_array) {DataAligned1}, DataUnaligned1, SizeUnaligned1);
  //Pwork_array := DataAligned1;

  //https://stackoverflow.com/questions/15801313/how-to-use-align-data-move-sse-in-delphi-xe3

  //getMem (pTemp, sizeof(Double) * (iSize_block*reg_by_block + reg));
  //CopyArray(Pointer(work_array), @Data, TypeInfo(Double), 5);
  //CopyMemory ( pTemp, @Data, sizeof(Double) * (iSize_block*reg_by_block + reg));
  //SetLength(work_array, iSize_block*reg_by_block + reg);
  //for i := 0 to iSize - 1 do
  //  Pwork_array^[i] := Data[i];

  asm
        push ecx
        mov ecx, iSize_block // edx    // счетчик цикла
        sub ecx, 1
        //lea esi, work_array // адрес массива данных
        //mov esi, work_array
        mov esi, Pwork_array
        //mov esi, [Data]

        movups xmm0, [esi] // здесь результат сложения всех регистров

  @@loop:
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

        add esi, 112 // указатель на следующий блок массива
        sub ecx, 1   // прочитали блок
        jns @@loop

        haddpd xmm0, xmm0
        movups [res], xmm0

        pop ecx
  end;

  //FreeMem(Pwork_array);
  (*{$IFDEF VER80}
    FreeMem(Pwork_array, iSize * sizeof(Double));
  {$ELSE}
    FreeMem(Pwork_array);
  {$ENDIF}  *)

  FreeMemAligned(nil, DataUnaligned1, SizeUnaligned1);

  Result := res[0];
end;

begin
  // Определяем тактовую частоту процессора (количество тактов в секунду).
  QueryPerformanceFrequency(Fr);
  if Fr = 0 then
  begin
    ShowMessage('Не удалось получить сведения о тактовой частоте.');
    Exit;
  end;
  // ShowMessage('Тактовая частота процессора (количество тактов в секунду): ' + IntToStr(Fr));
  Memo3.Text := Memo3.Text + 'Частота: '#9#9 + FloatToStrF(Fr, ffnumber, 20, 0) + #13#10;

  for k := 0 to iSize do
  begin
    arr1[k] := k;
  end;

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo3.Text := Memo3.Text + 'Pascal' + #13#10;
  Memo3.Text := Memo3.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  // Запуск исследуемого процесса.
  // for i := 1 to iTimes do Sleep(10);
  for i := 1 to iTimes do
  begin
    res := 0;
    for k := 0 to iSize do
      res := res + arr1[k];
  end;
  Memo3.Text := Memo3.Text + 'Результат: '#9#9 + FloatToStrF(res, ffnumber, 20, 0) + #13#10;

  // Показание счётчика тактов.
  QueryPerformanceCounter(t);
  Memo3.Text := Memo3.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  // Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF((t-Dt)/iTimes, ffnumber, 20, 0) + #13#10;
  Memo3.Text := Memo3.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  // ShowMessage('Усреднённая длительность выполнения в секундах: ' + FloatToStr(Dt));
  Memo3.Text := Memo3.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + #13#10;

  // ------ Math ----------------------------

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo3.Text := Memo3.Text + 'Math' + #13#10;
  Memo3.Text := Memo3.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  res := 0;
  for i := 1 to iTimes do
    begin
        res := SUM(arr1);
    end;
  Memo3.Text := Memo3.Text + 'Результат: '#9#9 + FloatToStrF(res, ffnumber, 20, 0) + #13#10;

  // Показание счётчика тактов.
  QueryPerformanceCounter(t);
  Memo3.Text := Memo3.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  // Memo1.Text := Memo1.Text + 'Длительность в тиках: '#9 + FloatToStrF((t-Dt)/iTimes, ffnumber, 20, 0) + #13#10;
  Memo3.Text := Memo3.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  // ShowMessage('Усреднённая длительность выполнения в секундах: ' + FloatToStr(Dt));
  Memo3.Text := Memo3.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + #13#10;

  // ------ SSE  выровнено ----------------------------

 (*GetMemAligned(4 {align by 4 bits, i.e. by 16 bytes}, nil, SizeAligned, DataAligned1, DataUnaligned1, SizeUnaligned1);
  V1 := DataAligned1;
  // now you can work with your vector via V1^ - it is aligned by 16 bytes and stays in the heap
 GetMemAligned(4 {align by 4 bits, i.e. by 16 bytes}, nil, SizeAligned, DataAligned2, DataUnaligned2, SizeUnaligned2);
  V2 := DataAligned2;
   Memo3.Lines.Add(IntToHex(DWord(V1), 8));
 Memo3.Lines.Add(IntToHex(DWord(V2), 8)); *)

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo3.Text := Memo3.Text + 'SSE выровнено' + #13#10;
  Memo3.Text := Memo3.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  for i := 1 to iTimes do
    begin
        res := SUM_SSE(arr1);
    end;

  (*FreeMemAligned(nil, DataUnaligned1, SizeUnaligned1);
  FreeMemAligned(nil, DataUnaligned2, SizeUnaligned2); *)

  Memo3.Text := Memo3.Text + 'Результат: '#9#9 + FloatToStrF(res, ffnumber, 20, 0) + #13#10;

  QueryPerformanceCounter(t);
  Memo3.Text := Memo3.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  Memo3.Text := Memo3.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  Memo3.Text := Memo3.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + #13#10;

// ------ SSE  не выровнено ----------------------------

  // Чтение показания счётчика тактов.
  QueryPerformanceCounter(t);
  Dt := t;
  Memo3.Text := Memo3.Text + 'SSE не выровнено' + #13#10;
  Memo3.Text := Memo3.Text + 'Счетчик до: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;

  Memo3.Lines.Add(IntToHex(DWord(@arr2), 8));
 Memo3.Lines.Add(IntToHex(DWord(@arr3), 8));
  {arr1[0] := 1;
  arr1[1] := 2;
  arr1[2] := 3;
  arr1[3] := 4;

  arr1[4] := 5;
  arr1[5] := 6;
  arr1[6] := 7;
  arr1[7] := 8;}

  for i := 1 to iTimes do
  begin
    res := 0;
    k := 0;
    arr3[0] := 0;
    arr3[1] := 0;

     for n := 0 to Ceil(iSize / 2) do
     begin
     for m := 0 to 1 do
      begin
        if k <= iSize then
          begin
            arr2[m] := arr1[k];
            Inc(k);
          end
        else
          begin
            arr2[m] := 0;
          end;
      end;

      //for k := 0 to 25000 do//iSize div 4 do
      begin
      asm
        movups xmm0, [arr3]
        movups xmm1, [arr2]
        addps xmm0, xmm1
        movups [arr3], xmm0
      end;
      end;
     end;

    res := arr3[0] + arr3[1];
  end;

  Memo3.Text := Memo3.Text + 'Результат: '#9#9 + FloatToStrF(res, ffnumber, 20, 0) + #13#10;

  QueryPerformanceCounter(t);
  Memo3.Text := Memo3.Text + 'Счетчик после: '#9#9 + FloatToStrF(t, ffnumber, 20, 0) + #13#10;
  Memo3.Text := Memo3.Text + 'Длительность в тиках: '#9 + FloatToStrF(t - Dt, ffnumber, 20, 0) + #13#10;
  // Рассчёт времени.
  Dt := (t - Dt) / (iTimes * Fr);

  Memo3.Text := Memo3.Text + 'Длительность в секундах: '#9 + FloatToStrF(Dt, ffnumber, 20, 10) + #13#10 + '----------------------------------' + #13#10;

  SendMessage(Memo3.Handle, WM_VSCROLL, SB_BOTTOM, 0);

end;


end.
