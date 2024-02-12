unit uHardwareMath;

interface

// {$Include ..\..\..\..\sharedUtils\utils\FastMM\FastMM4Options.inc}
// {$define fastmm}



// ��������� � FastMM4Options.inc. ���� ������������ �� 16 ���� ������ FastMM �� ���� ��������

uses
  types, math, ucommontypes, complex, Iterative_FFT_sse,
  recursive_sse2_sse3_d_al_fft;

type
  TDoubleArray = array of double;

  TFFTStats_d = record
    imax: cardinal; // �������� � �������
    max: double; // ��������� ����. ����.
  end;

  TAlignDarray = record
    // d:TDoubleArray;
    p: pointer;
    nAlignedSampl: pointer;
    nAlignedSize: integer; // � ������
  end;

  TAlignDCmpx = record
    // d:TCmxArray_d;
    p: pointer;
    // ��� ������ ��� ����������� �������
    nAlignedSampl: pointer;
    nAlignedSize: integer; // � ������
  end;

  // ������������� ����
  // ���� ����� (��������)  Hann k=2/3 ��� 1/1.5 ��� 0.67   Hanning
  // ���� �������� Hamming 1/0.54 ~1.85
  // ���� �������� Blackman  1/0.375 (��� �������� 2.67).
  // ���� �������
  // Flattop 1/0.215 (��� �������� 4.65)
  TWndType = (wdRect, wdHann, wdHamming, wdBlackman, wdFlattop);
  PWndType = ^TWndType;

  TWndFunc = record
    size: integer;
    acf:double; // ������� �� ���� ����
    ar: TDoubleArray;
    wndtype: TWndType;
  end;

  PWndFunc = ^TWndFunc;

  TFFTProp = record
    scale:double;
    TableExp: TAlignDCmpx; // ��������� Wn
    TableInd: TIndexArray; // ������� ������ �������� FFT
    // ����� ����� (������ ������ ������ �������������� ��������� ������������������)
    // �������� � ��� 2048 �����, ������ ����� 1024 ����� ��������� 2 ����� FFT
    StartInd: integer;
    PCount: integer; // ����� ����� FFT
    inverse: boolean;
  end;

  pFFTProp = ^TFFTProp;

function OSEnabledXmmYmm: boolean;
function IsAVX2supported: boolean;

function tempSUM(const Data: array of double; first, stop: integer): Extended;
function fSUM(const Data: array of double; first, stop: integer): Extended;
function SUM_SSE_d(const Data: array of double): Extended; overload;
function SUM_SSE_d(const Data: array of double;
  first, stop: integer): Extended; overload;
// ����������� ��� ����� ������� �� Scale
procedure MULT_SSE_al_d(var ar: TDoubleArray; scale: double);
procedure MULT_SSE_al_cmpx_d(var ar: TCmxArray_d; scale: double);
// ������� ������ �� ������������������� �� 1/FFTCount ��������� FFT
procedure ifft_al_d_sse(inData: TCmxArray_d; var outData: TCmxArray_d;
  FFTPlan: TFFTProp);
// ����� FFT. �� ����� ����������� ������ �� 16 ������ ����� � ���������. ��������� � OutData
// OutData � ������������ ������� ������ ����� ������ FFTSize!!! FFTPlan ������ ���� ��
// ���������� ������ �� inData � OutData
// ������ ������� - ������� �������!!!
procedure fft_al_d_sse(inData: TDoubleArray; var outData: TCmxArray_d;
  FFTPlan: TFFTProp); overload;
procedure fft_al_d_sse(inData: TDoubleArray; var outData: TCmxArray_d;
  FFTPlan: TFFTProp; wnd: PWndFunc); overload;
// ������������ ���� Abs(inData[i])*(1/FFTSize). ������ OutData FFTSize/2
// outData � 2 ���� ������ ��� inData, �� ��������� ������������ ������ ������ ����� ����� FFT
// �.�. Length(inData)
procedure NormalizeAndScaleSpmMag(var inData: TCmxArray_d;
  var outData: TDoubleArray);
// �� �� ��� � ������ ���� �� ��� ������������
procedure EvalSpmMag(var inData: TCmxArray_d; var outData: TDoubleArray);

// ��������� ������
// ���������� ������ ����������� �� 16 ������
procedure GetMemAlignedArray_d(const SrcSize: integer;
  out alData: TAlignDarray); overload;
// ---------------------------------------------------------------------------
procedure GetMemAlignedArray_d(const bits: integer; const src: pointer;
  const SrcSize: integer; out DstAligned: pointer;
  out DstUnaligned: pointer; out DstSize: integer); overload;

// ���������� ������ ����������� �� 16 ������
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

// ��������� �������
// ��������� ������� ��� ���������� ������� ������ � ������� ������ �������� FFT
procedure SortFFTArray(const inData: TDoubleArray; var outData: TCmxArray_d;
  const TableInd: TIndexArray; StartInd, // ����� ����� (������ ������ ������ �������������� ��������� ������������������)
  // �������� � ��� 2048 �����, ������ ����� 1024 ����� ��������� 2 ����� FFT
  PCount: integer); // ����� ����� FFT
// ������� �������� ��� ���������� �� ������ �������� FFT
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

var
  // ��������� FFT ������� � ��������� ��������������
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


function GetFFTWnd(fftCount: integer; wnd:TWndType): PWndFunc;
var
  i, l: integer;
  pr: PWndFunc;
  r: TWndFunc;
begin
  r.size := 0;
  r.acf:=1;
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
  // ����� �������
  l := length(g_FFTWndList);
  SetLength(g_FFTWndList, l + c_fftPlan_blockLength);
  r.size := fftCount;
  r.wndtype:=wnd;
  setlength(r.ar, fftCount);
  case wnd of
    wdHann:    // 0.22/0.14
    begin
      // acf 2 ecf 1.63
      r.acf:=2;
      FillWndHann(r.ar);
    end;
    wdHamming:
    begin
      // acf 1.85 ecf 1.59
      r.acf:=1.8534;
      FillWndHammin(r.ar);
    end;
    wdBlackman:
    begin
      // acf 2.8 ecf 1.97
      r.acf:=2.8;
      FillWndBlackman(r.ar);
    end;
    wdFlattop:
    begin
      // acf 4.18 ecf 2.26
      r.acf:=4.18;
      FillWndFlattop(r.ar);
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
  I := p0^; // ���������� ������ ��������
  // p0^:=(stop-first+1)*sizeof(double);
  p0^ := (stop - first + 1);
  // p[0]:=integer(@p[2]);
  result := sum(TDoubleArray(p));
  p0^ := I; // ��������������� ������ ��������
end;

procedure GetFFTExpTable(CountFFTPoints: integer; InverseFFT: boolean;
  var res: TCmxArray_d);
var
  I, StartIndex, N, LenB: integer;
  w, wn: TComplex_d;
  Mnogitel: double;
begin
  Mnogitel := -2 * Pi; // ������  ���
  if InverseFFT then
    Mnogitel := 2 * Pi; // ��������  ���
  LenB := 1;

  while LenB < CountFFTPoints do // ��������� ������ ����.
  begin
    N := LenB; // ������� ����� ��������� � �����
    LenB := LenB shl 1;
    // ������� ������ EXP ���������(������) ��� ���.
    wn.Re := 0;
    wn.Im := Mnogitel / LenB;
    wn := exp(wn);
    w := 1;

    StartIndex := N; // ��������� ������ � �������.
    Dec(N); // �.� ���������� � ����
    For I := 0 to N do // ��������� ���� exp ����������� ��� ���, � �������
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
  For I := 0 to EndIndex do // ����������� ������� �� �������
    result[I] := I;

  LenBlock := CountPoint;
  HalfBlock := LenBlock shr 1;
  HalfBlock_1 := HalfBlock - 1;

  while LenBlock > MinIteration do // ������������ ������� � ������ �������  LenBlock
  begin
    StartIndex := 0; // �������� � �������� ������ �����
    TempArray := Copy(result, 0, CountPoint);

    repeat // ������������ ������� � ����������(������ ����� =StartIndex) ����� �������  LenBlock
      ChIndex := StartIndex;
      NChIndex := ChIndex + 1;
      EndIndex := StartIndex + HalfBlock_1;

      // �������� ������ � �������� ������� � �������� ������� � �������� ������
      for I := StartIndex to EndIndex do
      begin
        result[I] := TempArray[ChIndex];
        result[I + HalfBlock] := TempArray[NChIndex];

        ChIndex := ChIndex + 2;
        NChIndex := NChIndex + 2;
      end;

      StartIndex := StartIndex + LenBlock; // ��������� � ������� �����
    Until StartIndex >= CountPoint; // ���� ����� �� ����� �������, ������ ������ ������ ���.

    // ��������� ����� ����, ���� �� ������ �� ������������ ������� (MinIteration)
    LenBlock := LenBlock shr 1;
    HalfBlock := LenBlock shr 1;
    HalfBlock_1 := HalfBlock - 1;
  end;
  TempArray := Nil;
end;

procedure SortFFTArray(const inData: TDoubleArray; // ������� ������
  var outData: TCmxArray_d; // �������� ������
  const TableInd: TIndexArray; // ������� ������ �������� FFT
  StartInd, // ����� ����� (������ ������ ������ �������������� ��������� ������������������)
  // �������� � ��� 2048 �����, ������ ����� 1024 ����� ��������� 2 ����� FFT
  PCount: integer); // ����� ����� FFT
var
  I: integer;
begin
  // ���������� �������� ������ �������� FFT
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
    // ####################  ���� ������������       --------- begin ------------
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
    // add   EAX,SizeOf(TComplex)//���������� ������a, ��� ������a D
    dec   ecx                  // ���������� ������a, ��� ������a D
  jns @Normalize // ������� ���� SF=1
    // ####################  ���� ������������       ----------- END ------------
  popad
end;

// �� ���� ��������� �� ������������� ����������� ������ �� fft_al_d_sse
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
    // �������
    mov   n, ecx
    shr   n, 1
    mov   one, 1
    fild  one    // N
    fild  n  // ��������� � ���� FPU 1
    fdiv                // St(0) =  1/N
    fstp  double [scale]
    lea   ebx, [scale]

    MOVDDUP xmm2, [ebx] // xmm2= scale
    shr   ECX,1         // ECX = Length/2
    dec   ECX           // Length-1
    // ####################  ���� ������������       --------- begin ------------
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
    // add   EAX,SizeOf(TComplex)//���������� ������a, ��� ������a D
    dec   ecx                  // ���������� ������a, ��� ������a D
  jns @Normalize // ������� ���� SF=1
    // ####################  ���� ������������       ----------- END ------------
  popad
end;

procedure ifft_al_d_sse(inData: TCmxArray_d; var outData: TCmxArray_d;
  FFTPlan: TFFTProp);
var
  I, ind, adr: integer;
  J, Len, sof, DPointer, TableExpPointer: integer;
begin
  // ���������� �������� ������ �������� FFT
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
    for I := 0 to wnd.size - 1 do
    begin
      inData[i]:=inData[i]*wnd.ar[i];
    end;
  end;
  fft_al_d_sse(inData, outData, FFTPlan);
end;

procedure fft_al_d_sse(inData: TDoubleArray; var outData: TCmxArray_d;
  FFTPlan: TFFTProp);
var
  I, adr, ind: integer;
  J, Len, sof, DPointer, TableExpPointer: integer;
begin
  // ���������� �������� ������ �������� FFT
  for I := 0 to FFTPlan.PCount - 1 do
  begin
    ind := FFTPlan.TableInd[I] + FFTPlan.StartInd;
    outData[I] := inData[ind];
  end;
  adr := integer(@inData[0]) - 4;
  // EvalFFT_al_d_sse(outData, FFTPlan.TableExp);
  recursive_sse2_sse3_d_al_fft.fft(outData, FFTPlan.TableExp.p);
end;

procedure MULT_SSE_al_cmpx_d(var ar: TCmxArray_d; scale: double);
var
  shift: integer;
  r: point2d;
asm
  pushad
    mov eax, [eax] // @D[0]
    mov edx, [eax-4]
    // xmm0..3 - �������� ������ ��� ���������
    // xmm4 - ���������
    // ecx - ����� �������
    MOVDDUP Xmm4, scale
    // ECX - ����� ������� ����� �������������� � ��������
    MOV     ECX, edx
    // ����� ������� 2-� ������ � ECX
    shr     ECX, 2
    shl     ECX, 2
    // ����������� ���-�� ��������� ���������
    mov     ebx, edx // ebx=Length
    sub     ebx, ecx // Length-NBlock
    // ecx - � �������� �� ���� �������� (*sof(double)*2)
    shl     ECX, 4
    mov     shift, ecx
    sub     ecx, 16
  @@Loop: // ��������� ������� �����
    movapd xmm0, [eax+ecx] // ��������� �� 2 �����
    movapd xmm1, [eax+ecx-16] // ��������� �� 2 �����
    movapd xmm2, [eax+ecx-32] // ��������� �� 2 �����
    movapd xmm3, [eax+ecx-48] // ��������� �� 2 �����
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    MULPD  xmm2, xmm4
    MULPD  xmm3, xmm4
    movapd [eax+ecx],xmm0
    movapd [eax+ecx-16],xmm1
    movapd [eax+ecx-32],xmm2
    movapd [eax+ecx-48],xmm3
    sub ecx, 64
  jns @@loop // ������� ���� SF=1
    shl edx, 3 // �������� � ���������� ��������
    // ��������� �������
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
    movapd xmm0, [eax] // ��������� �� 2 �����
    MULPD  xmm0, xmm4
    movapd [eax], xmm0
    jmp @exit
  @@3:
  // 2
    add eax, shift
    movapd xmm0, [eax] // ��������� �� 2 �����
    movapd xmm1, [eax+16] // ��������� �� 2 �����
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    movapd [eax], xmm0
    movapd [eax+16], xmm1
    jmp @exit
  // 0 �����
  @@4:
  // 3 �����
    add eax, shift
    movapd xmm0, [eax] // ��������� �� 2 �����
    movapd xmm1, [eax+16] // ��������� �� 2 �����
    movapd xmm2, [eax+32] // ��������� �� 2 �����
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
    mov edx, [eax-4]
    // xmm0..3 - �������� ������ ��� ���������
    // xmm4 - ���������
    // ecx - ����� �������
    MOVDDUP Xmm4, scale

    MOV     ECX, edx
    // ����� ������� 4-� ������ � ECX
    shr     ECX, 2
    shl     ECX, 2
    // ����������� ���-�� ��������� ���������
    mov     ebx, edx // ebx=Length
    sub     ebx, ecx // Length-NBlock
    // ecx - � �������� �� ���� �������� (*sof(double))
    shl     ECX, 3
    mov     shift, ecx
    sub     ecx, 16
  @@Loop:
    movapd xmm0, [eax+ecx] // ��������� �� 2 �����
    movapd xmm1, [eax+ecx-16] // ��������� �� 2 �����
    movapd xmm2, [eax+ecx-32] // ��������� �� 2 �����
    movapd xmm3, [eax+ecx-48] // ��������� �� 2 �����
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    MULPD  xmm2, xmm4
    MULPD  xmm3, xmm4
    movapd [eax+ecx],xmm0
    movapd [eax+ecx-16],xmm1
    movapd [eax+ecx-32],xmm2
    movapd [eax+ecx-48],xmm3
    sub ecx, 64
  jns @@loop // ������� ���� SF=1
    shl edx, 3 // �������� � ���������� ��������
    // ��������� �������
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
    movddup xmm0, [eax] // ��������� �� 2 �����
    MULPD  xmm0, xmm4
    movupd [r],  xmm0
    // ���� �������� ����� ���� FPU
    lea ebx, r   // lea �������� � ������ ������� �������� �� ������ ������
    fld qword ptr [ebx]
    FSTP qword ptr [eax]
    jmp @exit
  @@3:
  // 2
    add eax, shift
    movapd xmm0, [eax] // ��������� �� 2 �����
    MULPD  xmm0, xmm4
    movapd [eax], xmm0
    jmp @exit
  // 0 �����
  @@4:
  // 3 �����
    add eax, shift
    movapd xmm0, [eax] // ��������� �� 2 �����
    movddup xmm1, [eax+16] // ��������� �� 2 �����
    MULPD  xmm0, xmm4
    MULPD  xmm1, xmm4
    movapd [eax], xmm0
    // ���� �������� ����� ���� FPU
    movupd [r],  xmm1
    lea ebx, r   // lea �������� � ������ ������� �������� �� ������ ������
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
  // edx - ����� ������� (������ ����� hight ��������)
  // ecx - ����� ��� ������� ���������� �������� �� �������� ������� sse (16 ������ �� ��������)
  // ebx - ������� ������� (�������� �� ������������ � ����� ����� ��������)
  // esi - ��������� �� ������� ����������� ������ (���������� � ������ ������ data � ������ �� ����. ��������)
  MOV ECX, EDX // � ecx ������ LENGTH ����� �������

  dec ecx      // ��������� ��� �� 1 ������� �.�. � xmm0 2 �����
  push edx
  // ����� �� 14 ����� ������ ����� ����� ������� 14 ��������� � 7-� ���������
  MOV eax, ecx
  MOV ecx, 14
  cdq
  IDIV ECX // ��������� ��������� �������� � eax
  MOV ecx, eax // � ecx ������ hight ����� �������
  // ��������� ������� �� ������� �� 14 (������ �������� � edx ��� ���������� div)
  MOV Ebx, EDX
  pop edx
  cmp ecx, 0
  jnz @@StartProg
  MOV Ebx, edx // ������������ ������� ���� ����� ������ 0

  @@StartProg:
  movups xmm0, [esi] // ����� ��������� �������� ���� ���������
  sub ecx, 1         // ��������� ����
  js @@endSum         // ������� ���� SF=1

  // �������� r2
  fldz
  fstp r2
  add esi, 16
  @@loop:            // ���� ������ ��������
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

    add esi, 112 // ��������� �� ��������� ���� �������
    sub ecx, 1   // ��������� ����
  jns @@loop // ������� ���� SF=1
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

  // ��������� ��������� �����
  // inc ebx // �������� �� 1, �.�. ���� ������� �� ������ �� ��� ����� ����� ������ � �������
  shr ebx, 1 // ���������� ������� ������ ����� �������� � ��������
             // (����� �� 2 ���������� ������� �� ������� sse ������� �� 2 ��������)
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
  @@1: // 1, 2 �����
    movups xmm0, [esi]
    jmp @@endProg
  @@2: // 3, 4 �����
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    addpd xmm0, xmm1

    jmp @@endProg
  @@3: // 5, 6 �����
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    addpd xmm0, xmm1
    addpd xmm0, xmm2
    jmp @@endProg
  @@4: // 7, 8 �����
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
  @@8: // 14, 15 ����� � ��������� �������
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
  // ������� ���������� �������� ����� eax???
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
  // edx - ����� ������� (������ ����� hight ��������)
  // ecx - ����� ��� ������� ���������� �������� �� �������� ������� sse (16 ������ �� ��������)
  // ebx - ������� ������� (�������� �� ������������ � ����� ����� ��������)
  // esi - ��������� �� ������� ����������� ������ (���������� � ������ ������ data � ������ �� ����. ��������)
  mov esi, data // ��������� � esi ����� ������� data. � ���������� eax ����� �������� ��� ������� (� ��������� �� data ��� ��� ����� � eax)

  // ��������� ������� ������ �������
  mov eax, 8
  mul first;
  add esi, eax // �������� ������ ������

  MOV ECX, [stop] // � ecx ������ hight ����� �������
  dec ecx      // ��������� ��� �� 1 ������� �.�. � xmm0 2 �����

  push edx // ��������� �.�. edx ��������� � ����������� ��� �������� div
  // ����� �� 14 ����� ������ ����� ����� ������� 14 ��������� � 7-� ���������
  sub stop, first
  MOV eax, stop
  MOV ecx, 14
  cdq
  IDIV ECX // ��������� ��������� �������� � eax

  MOV ECX, [stop] // � ecx ������ hight ����� �������

  // ��������� ������� �� ������� �� 14 (������ �������� � edx ��� ���������� div)
  MOV Ebx, EDX
  pop edx
  cmp ecx, 0
  jnz @@StartProg
  MOV Ebx, edx // ������������ ������� ���� ����� ������ 0

  @@StartProg:
  movups xmm0, [esi] // ����� ��������� �������� ���� ���������
  sub ecx, 1         // ��������� ����
  js @@endSum         // ������� ���� SF=1

  // �������� r2
  fldz
  fstp r2
  add esi, 16
  @@loop:            // ���� ������ ��������
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

    add esi, 112 // ��������� �� ��������� ���� �������
    sub ecx, 1   // ��������� ����
  jns @@loop // ������� ���� SF=1
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

  // ��������� ��������� �����
  // inc ebx // �������� �� 1, �.�. ���� ������� �� ������ �� ��� ����� ����� ������ � �������
  shr ebx, 1 // ���������� ������� ������ ����� �������� � ��������
             // (����� �� 2 ���������� ������� �� ������� sse ������� �� 2 ��������)
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
  @@1: // 1, 2 �����
    movups xmm0, [esi]
    jmp @@endProg
  @@2: // 3, 4 �����
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    addpd xmm0, xmm1

    jmp @@endProg
  @@3: // 5, 6 �����
    movups xmm0, [esi]
    movups xmm1, [esi+16]
    movups xmm2, [esi+32]
    addpd xmm0, xmm1
    addpd xmm0, xmm2
    jmp @@endProg
  @@4: // 7, 8 �����
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
  @@8: // 14, 15 ����� � ��������� �������
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
  // ������� ���������� �������� ����� eax???
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
// ���� ������� FastMM � ������
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
  // ���� ������� FastMM � ������
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
  // ���� ������� FastMM � ������
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
        // �� �������� 4 ����� ����� �������
        // ��������� 20.06.2021
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
  // �� �������� 4 ����� ����� �������
  pint := pinteger(integer(DstAligned) - 4);
  pint^ := round(SrcSize / sizeof(TComplex_d));
  // �� �������� 8 ����� ���-�� ������ �� ��������� DynArray
  pint := pinteger(integer(DstAligned) - 8);
  pint^ := 1;
  if src <> nil then
    Move(src^, DstAligned, SrcSize);
{$ENDIF}
end;

procedure GetMemAlignedArray_d(const SrcSize: integer;
  out alData: TAlignDarray); overload;
begin
  // ���� ������� FastMM � ������
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
  // ���������� �������� ��� �������� �������� ������
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
      // CHECK XFEATURE_ENABLED_MASK[2:1] = �11b�
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
