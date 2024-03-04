unit TestFFT;

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uMeraFile, uBuffSignal, umerasignal,
  complex,
  uHardwareMath,
  uFFT,
  performancetime,
  fft, fht, Ap, DCL_MYOWN, ComCtrls;

// AVal - ������ ������������� ������, Nvl - ����� �������, ������ ���� ������ ������� 2.
// FTvl - ������ ���������� ��������, Nft - ����� �������, ������ ���� ����� Nvl / 2 ��� ������.

type


  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    AlgLib: TButton;
    SSEBtn: TButton;
    MultArraySSE: TButton;
    procedure AlgLibClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SSEBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MultArraySSEClick(Sender: TObject);
  private
    rezSignals:tstringlist;
    FFTProp:TFFTProp;
    AlignedSampl:TAlignDarray;
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
  //FCount=8192;
  FCount=8;

  TwoPi = 6.283185307179586;

var

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
  meraopts.TestName:='����';
  meraopts.TestDsc:='����';

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
  FreeMemAligned(MagFFTarray);
  FreeMemAligned(CalcSampl);
  FreeMemAligned(FFTProp.TableExp);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  s:tstringlist;
  p:tpair;
  STR:STRING;
begin
  GetMemAlignedArray_d(fcount, AlignedSampl);
  GetMemAlignedArray_d(fcount shr 1, MagFFTarray);
  GetMemAlignedArray_cmpx_d(fcount, CalcSampl);
  GetMemAlignedArray_cmpx_d(fcount, FFTProp.TableExp);

  FFTProp.StartInd:=0;
  FFTProp.PCount:=fcount;
  GetFFTExpTable(FCount, false, tcmxArray_d(FFTProp.TableExp.p));
  FFTProp.TableInd := GetArrayIndex(FCount, 2);
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
  meraopts.TestName:='����';
  meraopts.TestDsc:='����';

  m:=cmerafile.create('c:\USML\�����\cos_221_fs13500\cosinus.MERA',cBuffSignal);
  s:=cbuffsignal(m.GetSignal(0));

  setlength(outarray,round(fcount));
  setlength(cbuffsignal(s).d_points1d,fcount);

  ar:=tarrayvalues(cbuffsignal(s).d_points1d);
  setlength(outarray,round(fcount/2));
  //w:=GetFFTWnd(FFTProp.PCount,wdRect);
  w:=GetFFTWnd(FFTProp.PCount,wdHann);
  fft_al_d_sse(tdoublearray(ar),TCmxArray_d(CalcSampl.p),fftprop, w);
  // ��� ����� ������� �������
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
  resMera:=cMeraFile.create('c:\USML\�����\cos_221_fs13500\hann\res_rect.mera','c:\USML\�����\cos_221_fs13500\hann\',
                             rezSignals,
                             meraopts,nil);
  resMera.Save;
  resMera.Destroy;
  rezSignals.Destroy;
end;

procedure TForm1.MultArraySSEClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    tdoublearray(AlignedSampl.p)[i]:=1;
  end;
  MULT_SSE_al_d(tdoublearray(AlignedSampl.p), 2);
end;


// ����������� ������ 1 ��2 �����������. ���������� �������� d1
// ���������: ������ � eax, ������ � edx, ������ � ecx, ���-�� - ����.
function MulAr_sse(const D1: array of double;const D2: array of double; var dOut: array of double): Extended; overload;
var
  // ������ ����� ��� ���������� ���������
  shift: integer;
asm
 // ��������� � ���� �������� EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI.
  pushad
  // ���������� ������ - ���������� � �������� �� ������ � eax
  mov eax, [eax] // @D1[0]
  mov edx, [edx] // @D2[0]
  mov ecx, [ecx] // @DOut[0]
  mov ebx, [eax-4] // ���������� ����� �������

  MOV ECX, ebx
  // ����� ������� 4-� ������ � ECX. ��� ���� ����� ����� � ��� ������, ���� �������� ������� ����
  shr ECX, 2
  shl ECX, 2
  // ����������� ���-�� ��������� ���������
  //mov ebx, edx // ebx=Length
  sub ebx, ecx // Length-NBlock

  // ecx - � �������� �� ���� �������� (*sof(double) 2^3)
  shl ECX, 3
  mov shift, ecx
  sub ecx, 16
  @@Loop:
    //
    movapd xmm0, [eax+ecx] // ��������� �� 2 �����
    movapd xmm1, [edx+ecx] // ��������� �� 2 �����
    movapd xmm2, [eax+ecx-16] // ��������� �� 2 �����
    movapd xmm3, [edx+ecx-16] // ��������� �� 2 �����
    movapd xmm4, [eax+ecx-32] // ��������� �� 2 �����
    movapd xmm5, [edx+ecx-32] // ��������� �� 2 �����
    movapd xmm6, [eax+ecx-48] // ��������� �� 2 �����
    movapd xmm7, [edx+ecx-48] // ��������� �� 2 �����

    // ����������� 0 � 2 � ��������� � 0
    MULPD xmm0, xmm1
    MULPD xmm2, xmm3
    MULPD xmm4, xmm5
    MULPD xmm6, xmm7
    movapd [ecx],xmm0
    movapd [ecx+16],xmm0
    movapd [ecx+32],xmm2
    movapd [ecx+48],xmm4
    movapd [ecx+64],xmm6
    dOut
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
  popad
  @@1:
    jmp @exit
  @@2: // 1
    jmp @exit
  @@3: // 2
    jmp @exit
  @@4: // 0 �����
  @Exit:
end;

end.
