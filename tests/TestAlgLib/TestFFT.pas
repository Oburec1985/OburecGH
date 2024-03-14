unit TestFFT;

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uMeraFile, uBuffSignal, umerasignal,
  complex,
  uHardwareMath,
  uFFT,
  performancetime,
  fft, fht, Ap, DCL_MYOWN, ComCtrls, ExtCtrls, uChart, utrend, upage, uaxis, uBuffTrend1d;

// AVal - массив анализируемых данных, Nvl - длина массива, должна быть кратна степени 2.
// FTvl - массив полученных значений, Nft - длина массива, должна быть равна Nvl / 2 или меньше.

type


  TForm1 = class(TForm)
    Memo1: TMemo;
    AlgLib: TButton;
    SSEBtn: TButton;
    MultArraySSE: TButton;
    cChart1: cChart;
    IterCountIE: TIntEdit;
    LgyCb: TCheckBox;
    UseShaders: TCheckBox;
    procedure AlgLibClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SSEBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MultArraySSEClick(Sender: TObject);
    procedure LgyCbClick(Sender: TObject);
    procedure UseShadersClick(Sender: TObject);
  private
    rezSignals:tstringlist;
    FFTProp:TFFTProp;
    AlignedSampl,AlignedSampl2:TAlignDarray;
    CalcSampl: TAlignDCmpx;
    MagFFTarray:TAlignDarray;
  public

  end;

  pPair = ^tpair;

  tPair = record
    a:double;
    b:double;
  end;

const
  TwoPi = 6.283185307179586;

var
  //FCount=8192;
  FCount:integer = 16384;

  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.AlgLibClick(Sender: TObject);
var
  m:cmerafile;
  s:cbuffsignal;
  spmcount:integer;
  rezS:cbuffsignal;
  resMera:cMeraFile;
  meraopts:tmeraopts;
  cmplx_resArray:TComplex1DArray;
  outArray:array of double;
  k:double;
  I: Integer;
begin
  meraopts.TestName:='Фаза';
  meraopts.TestDsc:='Фаза';

  m:=cmerafile.create('g:\oburec\project2010\2011\tests\signals\Cos_100_500_1000_2000\Cos_100_500_1000_2000.MERA',
                      cBuffSignal);
  s:=cbuffsignal(m.GetSignal(0));

  setlength(outarray,round(fcount/2));
  setlength(cbuffsignal(s).d_points1d,fcount);
  for I := 0 to fcount - 1 do
  begin
    cbuffsignal(s).d_points1d[i]:=i;
  end;

  FFTR1D(treal1darray(cbuffsignal(s).d_points1d), FCount, cmplx_resArray);
  spmcount:=fcount div 2;
  setlength(outArray, spmcount);
  k:=1/spmcount;
  for I := 0 to spmcount - 1 do
  begin
    outArray[i]:=k*sqrt(cmplx_resArray[i].x*cmplx_resArray[i].x+cmplx_resArray[i].y*cmplx_resArray[i].y);
  end;

  rezS:=cBuffSignal.create;
  rezS.datatype:='r8';

  rezs.AddPoints(outArray);

  rezS.name:='SpmTest';
  rezS.freqX:=(2*FCount)/(cbuffsignal(s).freqx*2);
  //rezs.x0:=1/rezs.freqx;
  rezs.x0:=0;

  rezSignals:=TStringList.Create;
  rezSignals.AddObject(rezS.name,rezS);
  resMera:=cMeraFile.create('g:\oburec\project2010\2011\tests\signals\alglib\res_alglib.mera','g:\oburec\project2010\2011\tests\signals\',
                             rezSignals, meraopts,nil);
  resMera.Save;
  resMera.Destroy;
  rezSignals.Destroy;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeMemAligned(AlignedSampl);
  FreeMemAligned(AlignedSampl2);
  FreeMemAligned(MagFFTarray);
  FreeMemAligned(CalcSampl);
  FreeMemAligned(FFTProp.TableExp);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  s:tstringlist;
  p:tpair;
  STR:STRING;
  i:integer;
begin
  GetMemAlignedArray_d(fcount, AlignedSampl);
  GetMemAlignedArray_d(fcount, AlignedSampl2);
  GetMemAlignedArray_d(fcount shr 1, MagFFTarray);
  GetMemAlignedArray_cmpx_d(fcount, CalcSampl);
  GetMemAlignedArray_cmpx_d(fcount, FFTProp.TableExp);

  FFTProp.StartInd:=0;
  FFTProp.PCount:=fcount;
  i:=2;
  while fcount>=i do
  begin
    i:=i shl 1;
  end;
  if fcount<i then
    i:=i shr 1;
  GetFFTExpTable(i, false, tcmxArray_d(FFTProp.TableExp.p));
  FFTProp.TableInd := GetArrayIndex(i, 2);
end;


procedure TForm1.LgyCbClick(Sender: TObject);
begin
  cpage(cchart1.activePage).activeAxis.Lg:=not cpage(cchart1.activePage).activeAxis.Lg;
end;

procedure TForm1.SSEBtnClick(Sender: TObject);
var
  m:cmerafile;
  s:cbuffsignal;
  rezS:cbuffsignal;
  resMera:cMeraFile;
  meraopts:tmeraopts;
  cmplx_resArray:TComplex1DArray;
  ar,outArray:TArrayValues;
  I: Integer;
  w:pwndFunc;
begin
  meraopts.TestName:='Фаза';
  meraopts.TestDsc:='Фаза';

  m:=cmerafile.create('c:\USML\Файлы\cos_221_fs13500\cosinus.MERA',cBuffSignal);
  s:=cbuffsignal(m.GetSignal(0));

  setlength(outarray,round(fcount));
  setlength(cbuffsignal(s).d_points1d,fcount);

  ar:=tarrayvalues(cbuffsignal(s).d_points1d);
  setlength(outarray,round(fcount/2));
  //w:=GetFFTWnd(FFTProp.PCount,wdRect);
  w:=GetFFTWnd(FFTProp.PCount,wdHann);
  fft_al_d_sse(tdoublearray(ar),TCmxArray_d(CalcSampl.p),fftprop, w);
  // без учета оконной функции
  NormalizeAndScaleSpmMag(TCmxArray_d(CalcSampl.p), TDoubleArray(MagFFTarray.p));

  rezS:=cBuffSignal.create;
  rezS.datatype:='r8';

  rezs.AddPoints(TDoubleArray(MagFFTarray.p));

  rezS.name:='res_rect';
  rezS.freqX:=(2*FCount)/(cbuffsignal(s).freqx*2);
  //rezs.x0:=1/rezs.freqx;
  rezs.x0:=0;

  rezSignals:=TStringList.Create;
  rezSignals.AddObject(rezS.name,rezS);
  resMera:=cMeraFile.create('c:\USML\Файлы\cos_221_fs13500\hann\res_rect.mera','c:\USML\Файлы\cos_221_fs13500\hann\',
                             rezSignals,
                             meraopts,nil);
  resMera.Save;
  resMera.Destroy;
  rezSignals.Destroy;
end;

procedure TForm1.UseShadersClick(Sender: TObject);
var
  p:cpage;
  a:caxis;
  t:cBuffTrend1d;
begin
  cChart1.m_UseShaders:=UseShaders.Checked;
  p:=cpage(cchart1.activePage);
  a:=p.activeAxis;
  t:=cBuffTrend1d(a.getChild(0));
  cChart1.Invalidate;
end;

function MulAr_sse_al_test(const D1: array of double;const D2: array of double; var dOut: array of double; count:integer): Extended;
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

procedure TForm1.MultArraySSEClick(Sender: TObject);
var
  I: Integer;
  pf:TPerformanceTime;
  t1,t2, v:double;
  ar:array of double;
  j, c: Integer;

  p:cpage;
  t:cBuffTrend1d;
  a:cAxis;
  k: Integer;
begin
  c:=5000;
  for I := 0 to fcount-1 do
  begin
    tdoublearray(AlignedSampl.p)[i]:=i;
    tdoublearray(AlignedSampl2.p)[i]:=i+1;
    tdoublearray(CalcSampl.p)[i]:=i+2;
  end;

  p:=cpage(cchart1.activePage);
  a:=p.activeAxis;
  t:=cBuffTrend1d(a.getChild(0));
  setlength(ar, fcount);
  if t=nil then
  begin
    t:=cBuffTrend1d.create;
    t.flength:=c;
    t.dx:=1;
    a.AddChild(t);
  end
  else
  begin

  end;
  pf:=TPerformanceTime.Create;
  //for I := 1 to c-1 do
  for I := 1 to fcount-1 do
  begin
    pf.Start;
    for k := 0 to IterCountIE.IntNum do
    begin
      //MulAr_sse_al(tdoublearray(AlignedSampl.p), tdoublearray(AlignedSampl2.p), tdoublearray(CalcSampl.p));
      MulAr_sse_al(tdoublearray(AlignedSampl.p), tdoublearray(AlignedSampl2.p), tdoublearray(CalcSampl.p), i);
    end;

    t1:=pf.Stop;
    pf.Start;
    for k := 0 to IterCountIE.IntNum do
    begin
      for j := 0 to i-1 do
      begin
        tdoublearray(CalcSampl.p)[j]:=tdoublearray(AlignedSampl.p)[j]*tdoublearray(AlignedSampl2.p)[j];
      end;
      //MulAr_sse_al_test(tdoublearray(AlignedSampl.p), tdoublearray(AlignedSampl2.p), tdoublearray(CalcSampl.p), i);
    end;
    t2:=pf.Stop;
    v:=t2/t1;
    ar[i]:=v;
    //ar[i]:=10;
  end;
  t.AddPoints(ar);
  cChart1.Invalidate;
  pf.Destroy;
end;


end.
