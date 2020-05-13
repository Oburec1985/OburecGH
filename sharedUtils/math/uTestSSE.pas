unit uTestSSE;

interface
uses
  stdctrls,
  sysutils,
  performancetime,
  uHardwareMath,
  complex;

procedure TestFunc(memo:tmemo);
procedure MULPD_Xmm100(var a1:pointer); assembler;
procedure MOVaPD_Xmm100(var a1:pointer); assembler;
procedure MOVDDUP_Xmm100(var a1:pointer); assembler;
procedure SHUFPD_Xmm100(var a1:pointer); assembler;
procedure ADDSUBPD_Xmm100(var a1:pointer); assembler;
procedure ADDPD_Xmm100(var a1:pointer); assembler;
procedure SUBPD_Xmm100(var a1:pointer); assembler;


implementation

procedure TestFunc(memo:tmemo);
var
  ar: tdoublearray;
  nal_ar:pointer;
  nal_size:integer;
  time:TPerformanceTime;
begin
  //GetMemAlignedArray_d(4, nil,1024 * sizeof(double),ar,nal_ar,nal_size);

  time:=TPerformanceTime.Create;
  Time.Start;
  MOVaPD_Xmm100(pointer(ar));
  Time.Stop;
  Memo.Lines.add('MOVaPD = ' + FloatToStr(Time.Delay) + ' сек.');

  Time.Start;
  MULPD_Xmm100(pointer(ar));
  Time.Stop;
  Memo.Lines.add('MULPD = ' + FloatToStr(Time.Delay) + ' сек.');

  Time.Start;
  MOVDDUP_Xmm100(pointer(ar));
  Time.Stop;
  Memo.Lines.add('MOVDDUP = ' + FloatToStr(Time.Delay) + ' сек.');

  Time.Start;
  SHUFPD_Xmm100(pointer(ar));
  Time.Stop;
  Memo.Lines.add('SHUFPD = ' + FloatToStr(Time.Delay) + ' сек.');

  Time.Start;
  ADDSUBPD_Xmm100(pointer(ar));
  Time.Stop;
  Memo.Lines.add('ADDSUBPD = ' + FloatToStr(Time.Delay) + ' сек.');

  Time.Start;
  ADDPD_Xmm100(pointer(ar));
  Time.Stop;
  Memo.Lines.add('ADDPD = ' + FloatToStr(Time.Delay) + ' сек.');

  Time.Start;
  SUBPD_Xmm100(pointer(ar));
  Time.Stop;
  Memo.Lines.add('SUBPD = ' + FloatToStr(Time.Delay) + ' сек.');
  time.free;
end;

procedure MULPD_Xmm100(var a1:pointer); assembler;
var
  i:integer;
asm
  pushAD
  mov       EAX,[EAX]         // EAX       := @D[0]
  MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
  MOVaPD    xmm1, [Eax]       // xmm3 = [D.Re, D.Im]
  mov i, 0
  @Loop_i:
    MULPD    xmm0, xmm1
    INC i
    cmp i, 100000000
    jb @Loop_i
  PopAD
end;

procedure MOVaPD_Xmm100(var a1:pointer); assembler;
var
  i:integer;
asm
  pushAD
  mov       EAX,[EAX]
  MOVaPD    xmm1, [Eax]       // xmm3 = [D.Re, D.Im]
  MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
  mov i, 0
  @Loop_i:
    MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
    INC i
    cmp i, 100000000
    jb @Loop_i
  PopAD
end;

procedure MOVDDUP_Xmm100(var a1:pointer); assembler;
var
  i:integer;
asm
  pushAD
  mov       EAX,[EAX]
  MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
  MOVaPD    xmm1, [Eax]       // xmm3 = [D.Re, D.Im]
  mov i, 0
  @Loop_i:
    MOVDDUP   xmm0, [Eax]
    MOVaPD   [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    INC i
    cmp i, 100000000
    jb @Loop_i
  PopAD
end;

procedure SHUFPD_Xmm100(var a1:pointer); assembler;
var
  i:integer;
asm
  pushAD
  mov       EAX,[EAX]
  MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
  MOVaPD    xmm1, [Eax]       // xmm3 = [D.Re, D.Im]
  mov i, 0
  @Loop_i:
    SHUFPD    xmm0, xmm0,1       // xmm3 = [D.Re, D.Im]
    MOVaPD   [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    INC i
    cmp i, 100000000
    jb @Loop_i
  PopAD
end;


procedure ADDSUBPD_Xmm100(var a1:pointer); assembler;
var
  i:integer;
asm
  pushAD
  mov       EAX,[EAX]
  MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
  MOVaPD    xmm1, [Eax]       // xmm3 = [D.Re, D.Im]
  mov i, 0
  @Loop_i:
    ADDSUBPD    xmm0, xmm1       // xmm3 = [D.Re, D.Im]
    MOVaPD   [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    INC i
    cmp i, 100000000
    jb @Loop_i
  PopAD
end;

procedure ADDPD_Xmm100(var a1:pointer); assembler;
var
  i:integer;
asm
  pushAD
  mov       EAX,[EAX]
  MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
  MOVaPD    xmm1, [Eax]       // xmm3 = [D.Re, D.Im]
  mov i, 0
  @Loop_i:
    ADDPD    xmm0, xmm1       // xmm3 = [D.Re, D.Im]
    MOVaPD   [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    INC i
    cmp i, 100000000
    jb @Loop_i
  PopAD
end;


procedure SUBPD_Xmm100(var a1:pointer); assembler;
var
  i:integer;
asm
  pushAD
  mov       EAX,[EAX]
  MOVaPD    xmm0, [Eax]       // xmm3 = [D.Re, D.Im]
  MOVaPD    xmm1, [Eax]       // xmm3 = [D.Re, D.Im]
  mov i, 0
  @Loop_i:
    SUBPD    xmm0, xmm1       // xmm3 = [D.Re, D.Im]
    MOVaPD   [EAX], xmm0       // D[StartIndex] :=D0+TempBn;
    INC i
    cmp i, 100000000
    jb @Loop_i
  PopAD
end;

end.
