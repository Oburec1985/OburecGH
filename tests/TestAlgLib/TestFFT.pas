unit TestFFT;

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uMeraFile, uBuffSignal, umerasignal,
  complex,
  uHardwareMath, math,
  uYCursor,
  performancetime, nativexml, ucommonmath, uCommonTypes,
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
    CheckBox1: TCheckBox;
    SpmDxFe: TFloatEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MultArraySSEClick(Sender: TObject);
    procedure LgyCbClick(Sender: TObject);
    procedure UseShadersClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure SSEBtnClick(Sender: TObject);
  private
    rezSignals:tstringlist;
    FFTProp,
    FFTProp2
    :TFFTProp;
    m_spmpage:cpage;
    AlignedSampl,AlignedSampl2:TAlignDarray;
    CmxArray, CmxArrayZoom:TAlignDCmpx;
    // тест перемножения массива
    CalcSampl: TAlignDCmpx;
    MagFFTarray,MagFFTarrayZoom:TAlignDarray;
  public

  end;

  pPair = ^tpair;

  tPair = record
    a:double;
    b:double;
  end;

function GetFFTPlan(fftCount: integer): TFFTProp;
function GetInverseFFTPlan(fftCount: integer): TFFTProp;

const
  TwoPi = 6.283185307179586;

var
  FCount:integer = 16384;
  Form1: TForm1;
  // настройки FFT прямого и обратного преобразования
  g_FFTPlanList: array of TFFTProp;
  g_inverseFFTPlanList: array of TFFTProp;

implementation
{$R *.DFM}
function GetFFTPlan(fftCount: integer): TFFTProp;
var
  i, j, l: integer;
  r: TFFTProp;
begin
  j := -1;
  r.PCount := 0;
  for i := 0 to length(g_FFTPlanList) - 1 do
  begin
    r := g_FFTPlanList[i];
    if r.PCount = fftCount then
    begin
      result := g_FFTPlanList[i];
      exit;
    end
    else
    begin
      if j = -1 then
      begin
        if r.PCount = 0 then
        begin
          j := i;
        end;
      end;
    end;
  end;
  if (j = -1) then
  begin
    // длина массива
    j := length(g_FFTPlanList);
    SetLength(g_FFTPlanList, j + c_fftPlan_blockLength);
  end;
  r := g_FFTPlanList[j];
  r.StartInd := 0;
  r.PCount := fftCount;
  r.m_scaleCurve:=nil;
  GetMemAlignedArray_cmpx_d(fftCount, r.TableExp);
  r.TableInd := GetArrayIndex(fftCount, 2);
  GetFFTExpTable(fftCount, false, tcmxArray_d(r.TableExp.p));
  g_FFTPlanList[j] := r;
  result := g_FFTPlanList[j];
end;

function GetInverseFFTPlan(fftCount: integer): TFFTProp;
var
  i, j, l: integer;
  r: TFFTProp;
begin
  j := -1;
  r.PCount := 0;
  for i := 0 to length(g_inverseFFTPlanList) - 1 do
  begin
    r := g_inverseFFTPlanList[i];
    if r.PCount = fftCount then
    begin
      result := g_inverseFFTPlanList[i];
      exit;
    end
    else
    begin
      if j = -1 then
      begin
        if r.PCount = 0 then
        begin
          j := i;
        end;
      end;
    end;
  end;
  if (j = -1) then
  begin
    // длина массива
    j := length(g_inverseFFTPlanList);
    SetLength(g_inverseFFTPlanList, j + c_fftPlan_blockLength);
  end;
  r := g_inverseFFTPlanList[j];
  r.inverse := true;
  r.StartInd := 0;
  r.PCount := fftCount;
  GetMemAlignedArray_cmpx_d(fftCount, r.TableExp);
  r.TableInd := GetArrayIndex(fftCount, 2);
  GetFFTExpTable(fftCount, true, tcmxArray_d(r.TableExp.p));
  g_inverseFFTPlanList[j] := r;
  result := g_inverseFFTPlanList[j];
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeMemAligned(AlignedSampl);
  FreeMemAligned(AlignedSampl2);
  FreeMemAligned(MagFFTarray);
  FreeMemAligned(MagFFTarrayZoom);
  FreeMemAligned(CalcSampl);
  FreeMemAligned(FFTProp.TableExp);
  FreeMemAligned(CmxArray);
  FreeMemAligned(CmxArrayZoom);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  s:tstringlist;
  p:tpair;
  STR:STRING;
  i, j:integer;
  t, spmTrend, spmTrendZoom:cBuffTrend1d;

  a:caxis;
  curs:cYCursor;
  F1, F2, Fs, dFspm,
  dPhase1, Phase1,
  dPhase2, Phase2:double;
  rect:frect;
begin
  GetMemAlignedArray_d(fcount, AlignedSampl);
  GetMemAlignedArray_d(fcount*2, AlignedSampl2);
  GetMemAlignedArray_d(fcount shr 1, MagFFTarray);
  GetMemAlignedArray_d(fcount, MagFFTarrayZoom);
  GetMemAlignedArray_cmpx_d(fcount, CalcSampl);
  GetMemAlignedArray_cmpx_d(fcount, FFTProp.TableExp);
  GetMemAlignedArray_cmpx_d(fcount, CmxArray);
  GetMemAlignedArray_cmpx_d(fcount*2, CmxArrayZoom);

  FFTProp.StartInd:=0;
  FFTProp.PCount:=fcount;
  i:=2;
  while fcount>=i do
  begin
    i:=i shl 1;
  end;
  if fcount<i then
    i:=i shr 1;
  fftprop:=GetFFTPlan(fcount);
  fftprop2:=GetFFTPlan(fcount*2);
  //for I := 0 to 4 do
  begin
    Fs:=10000;
    dFspm:=Fs/FCount;
    F1:=1000; F2:=10;
    //f1:=dFspm*2000; f2:=dFspm*20;
    dPhase1:=2*pi*F1/Fs;
    dPhase2:=2*pi*F2/Fs;

    Phase1:=0;
    Phase2:=0;
    a:=cpage(cChart1.activePage).activeAxis;
    t:=cBuffTrend1d.create;
    t.flength:=FCount;
    for j :=0 to t.flength - 1 do
    begin
      tdoublearray(AlignedSampl.p)[j]:=1*Sin(Phase1)+1*Sin(Phase2);
      Phase1:=Phase1+dPhase1;
      Phase2:=Phase2+dPhase2;
    end;
    // fs=10 kHz
    t.dx:=1/Fs;
    t.color:=colorarray[0];
    a.AddChild(t);
    t.AddPoints(tdoublearray(AlignedSampl.p));
  end;
  cpage(cChart1.activePage).Normalise;
  cpage(cChart1.activePage).cursor.visible:=true;
  cpage(cChart1.activePage).cursor.setx1(100);
  curs:=cYCursor.create;
  cChart1.activePage.AddChild(curs);
  rect.BottomLeft.x:=0;
  rect.BottomLeft.y:=0;
  rect.TopRight.x:=5000;
  rect.TopRight.y:=2;
  cpage(cChart1.activePage).ZoomfRect(rect);

  m_spmpage:=cChart1.activeTab.addPage(true);
  m_spmpage.name:='Freq.dom';


  spmTrend:=cBuffTrend1d.create;
  spmTrend.flength:=FCount;
  spmTrend.dx:=dFspm;
  FFTProp.StartInd:=0;
  fft_al_d_sse(tdoublearray(AlignedSampl.p),
               tcmxArray_d(CmxArray.p), FFTProp);
  EvalSpmMag(tcmxArray_d(CmxArray.p), TDoubleArray(MagFFTarray.p));
  MULT_SSE_al_d(TDoubleArray(MagFFTarray.p), 1/fcount);

  FFTProp.m_Zoom:=false;
  FFTProp.m_ZoomOrd:=0;
  // с добавкой нулей
  move(tdoublearray(AlignedSampl.p)[0],tdoublearray(AlignedSampl2.p)[0],fcount*sizeof(double));
  fft_al_d_sse(tdoublearray(AlignedSampl2.p),
               tcmxArray_d(CmxArrayZoom.p), FFTProp2);
  EvalSpmMag(tcmxArray_d(CmxArrayZoom.p), TDoubleArray(MagFFTarrayZoom.p));
  MULT_SSE_al_d(TDoubleArray(MagFFTarrayZoom.p), 1/fcount);

  a:=m_spmpage.activeAxis;
  spmTrendZoom:=cBuffTrend1d.create;
  spmTrendZoom.flength:=FFTProp2.PCount;
  spmTrendZoom.dx:=Fs/FFTProp2.PCount;
  spmTrendZoom.color:=red;
  a.AddChild(spmTrendZoom);
  spmTrendZoom.AddPoints(tdoublearray(MagFFTarrayZoom.p));

  a.AddChild(spmTrend);
  SpmDxFe.FloatNum:=spmTrend.dx;
  spmTrend.AddPoints(tdoublearray(MagFFTarray.p));

  rect.BottomLeft.x:=0.1;
  rect.BottomLeft.y:=0.0001;
  rect.TopRight.x:=10;
  rect.TopRight.y:=20;
  m_spmpage.ZoomfRect(rect);
end;

procedure TForm1.LgYCbClick(Sender: TObject);
begin
  cpage(cchart1.activePage).activeAxis.Lg:=not cpage(cchart1.activePage).activeAxis.Lg;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  cpage(cchart1.activePage).LgX:=not cpage(cchart1.activePage).LgX;
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


procedure TForm1.SSEBtnClick(Sender: TObject);
var
  a1,a2:TDoubleArray;
  I: Integer;
begin
  setlength(a1,16);
  setlength(a2,16);
  for I := 0 to length(a2) - 1 do
  begin
    a1[i]:=i;
    a2[i]:=i;
  end;
  //ReindexArray(a1,a2,0,8,2);
  PerformArrayReindexing(a1,2);
end;

end.
