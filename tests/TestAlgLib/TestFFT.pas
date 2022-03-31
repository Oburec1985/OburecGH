unit TestFFT;

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uMeraFile, uBuffSignal, umerasignal, performancetime,
  complex,
  uHardwareMath,
  uFFT,
  usetlist,
  fft, fht, Ap;

// AVal - массив анализируемых данных, Nvl - длина массива, должна быть кратна степени 2.
// FTvl - массив полученных значений, Nft - длина массива, должна быть равна Nvl / 2 или меньше.

type


  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    Label1: TLabel;
    AlgLib: TButton;
    SSEBtn: TButton;
    procedure Button1Click(Sender: TObject);
    procedure AlgLibClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SSEBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
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

  setList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
    procedure addPair(p:tPair);
    function GetPair(i:integer):tPair;
    procedure DelPair(i:integer);
  end;

const
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

procedure TForm1.Button1Click(Sender: TObject);
var
  m:cmerafile;
  s:cbuffsignal;
  rezS:cbuffsignal;
  resMera:cMeraFile;
  meraopts:tmeraopts;
  cmplx_resArray:TComplex1DArray;
  ar,outArray:TArrayValues;
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

  ar:=tarrayvalues(cbuffsignal(s).d_points1d);
  FFTAnalysis(ar,
              outarray,
              FCount,
              round(fcount/2));

  rezS:=cBuffSignal.create;
  rezS.datatype:='r8';

  rezs.AddPoints(outarray);

  rezS.name:='SpmTest';
  rezS.freqX:=(2*FCount)/(cbuffsignal(s).freqx*2);
  rezs.x0:=1/rezs.freqx;

  rezSignals:=TStringList.Create;
  rezSignals.AddObject(rezS.name,rezS);
  resMera:=cMeraFile.create('g:\oburec\project2010\2011\tests\signals\res.mera','g:\oburec\project2010\2011\tests\signals\',
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
  l:setList;
begin
  l:=setList.create;
  l.addPair(p);
  l.addPair(p);
  l.addPair(p);
  l.destroy;

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
begin
  meraopts.TestName:='Фаза';
  meraopts.TestDsc:='Фаза';

  m:=cmerafile.create('g:\oburec\project2010\2011\tests\signals\Cos_100_500_1000_2000\Cos_100_500_1000_2000.MERA',
                      cBuffSignal);
  s:=cbuffsignal(m.GetSignal(0));

  setlength(outarray,round(fcount/2));
  setlength(cbuffsignal(s).d_points1d,fcount);

  ar:=tarrayvalues(cbuffsignal(s).d_points1d);
  setlength(outarray,round(fcount/2));
  for I := 0 to fcount - 1 do
  begin
    ar[i]:=i;
  end;
  fft_al_d_sse(tdoublearray(ar),TCmxArray_d(CalcSampl.p),fftprop);
  NormalizeAndScaleSpmMag(TCmxArray_d(CalcSampl.p), TDoubleArray(MagFFTarray.p));

  rezS:=cBuffSignal.create;
  rezS.datatype:='r8';

  rezs.AddPoints(TDoubleArray(MagFFTarray.p));

  rezS.name:='SSETest';
  rezS.freqX:=(2*FCount)/(cbuffsignal(s).freqx*2);
  rezs.x0:=1/rezs.freqx;

  rezSignals:=TStringList.Create;
  rezSignals.AddObject(rezS.name,rezS);
  resMera:=cMeraFile.create('g:\oburec\project2010\2011\tests\signals\sse\res_sse.mera','g:\oburec\project2010\2011\tests\signals\',
                             rezSignals, meraopts,nil);
  resMera.Save;
  resMera.Destroy;
  rezSignals.Destroy;
end;

{ setList }

function PairComparator(p1,p2:pointer):integer;
begin
  if tpair(p1^).a>tpair(p2^).a then
  begin
    result:=1;
  end
  else
  begin
    if tpair(p1^).a<tpair(p2^).a then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

procedure setList.addPair(p: tPair);
var
  lp:pPair;
begin
  if Findobj(@p)=-1 then
  begin
    getmem(lp,sizeof(tpair));
    lp^:=p;
    Add(lp);
  end;
end;

constructor setList.create;
begin
  inherited;
  comparator:=PairComparator;
  destroydata:=true;
end;

procedure setList.deletechild(node: pointer);
begin
  FreeMem(node,sizeof(tpair));
end;

procedure setList.DelPair(i: integer);
begin
  RemoveObj(i);
end;

function setList.GetPair(i: integer): tpair;
begin
  result:=tpair(items[i]^);
end;

end.
