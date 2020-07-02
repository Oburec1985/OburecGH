unit uFFTFlt;
// порядок создания оператор
// 1) Открыть файл .ridl в IDE. В дереве объектов добавить CoClass
// 2) На вкладке implements вставить интерфейс IWPExtOper
// 3) создать вручную юнит с исходником плагина и скопировать туда набор методов из примера (методы помеченные как safecall)
// 4) Добавить секцию initialization как в этом файле
// 5) добавить в событие Connect плагина:
// eoRpt := TExtOperRpt.create(); // RptRegName - имя для отображение в среде WP
// WINPOS.RegisterExtOper(eoRpt, 1, 1, RptRegName, 'Rpt', True);

interface
uses
  windows, ComObj, types, Forms, ActiveX, WPExtPack_TLB, Winpos_ole_TLB,
  StdVcl, PosBase,
  uFindMaxForm, uWPProc, classes, uCommonTypes, uWPservices, sysutils, utrend,
  uSetList, math, uWPEvents, ComServ, uCommonMath,
  MathFunction,
  uMyMath,
  uWPOpers,
  uBaseObjMng,
  uWPProcServices,
  Pathutils,
  Variants,
  fft,
  uHardwareMath,
  complex,
  ap
  ;

type

// алгоритм не знает списка сигналов обработки (он получает по одному
  // сигналу перед вызовом). Работу с группой сигналов реализует форма
  TExtFFTflt = class(TAutoObject, IWPExtOper)
  private
    m_FFTPlanList:array of TFFTProp;
    m_iFFTPlanList:array of TFFTProp;
    m_mng: cBaseObjmng;

    data:TDoubleArray;
    cmplx_al, MagFFTarray: TAlignDCmpx;
    ifftPlan,fftPlan:TFFTProp;
    // набор коэффициентов для fft спектра
    m_curveScales:array of double;
    resfolder:string;
    // опции оператора
    m_fftCount, m_Offset:integer;
    m_curve:string;
  public
    procedure GetError(out pnerrcode: integer; out perrstr: WideString);safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);safecall;
    procedure OnSetup(hwndparent: integer; out phwnd: integer); safecall;
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
    procedure FreeFFTPlanList;
    function GetFFTPlan(fftCount:integer): TFFTProp;
    function GetInverseFFTPlan(fftCount:integer): TFFTProp;
  public
    function GetPropStrF(out pstr: WideString):string;
    function Execute(const psrc1: IDispatch): boolean;
    procedure link(m:cbaseObjMng);
    procedure Setup;
    Constructor create;
    destructor destroy;
  end;

implementation
uses
  uFFTFltFrm;

const
  c_OperName = 'FFTflt';
  c_opts = '';

{TExtFFTInverse}
constructor TExtFFTflt.create;
begin
  m_fftCount:=1024;
  setlength(m_FFTPlanList,100);
  setlength(m_iFFTPlanList,100);
end;

destructor TExtFFTflt.destroy;
begin
  FreeFFTPlanList;
end;



function TExtFFTflt.Execute(const psrc1: IDispatch): boolean;
var
  D: IDispatch;
begin
  result := true;
  Exec(psrc1, psrc1, D, D);
  //if m_error then
  //  result := false;
end;

procedure TExtFFTflt.Exec(const psrc1, psrc2: IDispatch; out pdst1,
  pdst2: IDispatch);
var
  r1, r2, err: olevariant;
  s1, interval, res:iwpsignal;
  I, size, startind:integer;
  k:double;
  str:string;
  wstr:widestring;
  //a1,a2,x:olevariant;
  EndSignal:boolean;
begin
  s1 := psrc1 as iwpsignal;
  startind:=0;
  EndSignal:=false;
  while not EndSignal do
  begin
    interval:=wp.GetInterval(s1, startind, m_fftCount) as iwpsignal;
    for I := 0 to m_fftCount - 1 do
    begin
      data[i]:=interval.GetY(i);
    end;
    fft_al_d_sse(data, TCmxArray_d(cmplx_al.p), fftPlan);
    k:=1/(fftPlan.PCount shr 1);
    MULT_SSE_al_cmpx_d(tCmxArray_d(cmplx_al.p), k);
    EvalSpmMag(TCmxArray_d(cmplx_al.p), TDoubleArray(MagFFTarray.p));
    //NormalizeAndScaleSpmMag(TCmxArray_d(cmplx_al.p), TDoubleArray(MagFFTarray.p));
    // сохраняем амплитудный спектр
    res:=iwpsignal(wp.CreateSignal(vt_r8));
    res.DeltaX:=(1/(s1.deltaX))/m_fftCount;
    res.size:=AlignBlockLength(MagFFTarray);
    for I := 0 to res.size-1 do
    begin
      res.SetY(i, TDoubleArray(MagFFTarray.p)[i]);
    end;
    wp.Link('/Signals/results', s1.sname+'_'+'MagSpm', res as IDispatch);
    startind:=startind+m_offset;
    EndSignal:=true;
  end;
  size:=s1.size;
  begin
    {a1 := VarArrayCreate([0, size-1], varDouble);
    x := VarArrayCreate([0, size-1], varDouble);
    setlength(cmpx, size*2);
    s1.GetArray(0,size,a1,x,true);
    s2.GetArray(0,size,a2,x,true);
    for I := 0 to size - 1 do
    begin
      cmpx[i].X:=a1[i];
      cmpx[i].y:=a2[i];
    end;
    // зеркалирование спектра
    for I := size to 2*size - 1 do
    begin
      cmpx[i].X:=a1[size-i+size-1];
      cmpx[i].y:=a2[size-i+size-1];
    end;
    FFTR1DInv(cmpx, 2*size, resArray);
    res:=iwpsignal(wp.CreateSignal(vt_r8));
    res.DeltaX:=1/(s1.MaxX*2);
    res.size:=size;
    k:=size;
    for I := 0 to size-1 do
    begin
      res.SetY(i, resArray[i]*k);
    end;
    str:=res.sname;
    wp.Link('/Signals/results', s1.sname+'_'+s2.sname+'fftInv', res as IDispatch);}
  end;
  winpos.Refresh;
  GetPropStr(wstr);
  winpos.AddTextInLog(c_OperName, wstr, true);
  winpos.DoEvents;
end;


procedure TExtFFTflt.GetError(out pnerrcode: integer; out perrstr: WideString);
begin

end;

procedure TExtFFTflt.GetPropStr(out pstr: WideString);
var
  pars: tstringlist;
  b: boolean;
  str: string;
begin
  pars := tstringlist.create;
  addParam(pars, 'FFTCount', inttostr(m_fftCount));
  addParam(pars, 'OffsetBlock', inttostr(m_offset));
  addParam(pars, 'Curve', m_curve);
  pstr := ParsToStr(pars);
  delpars(pars);
  pars.destroy;
end;

procedure TExtFFTflt.SetPropStr(const str: WideString);
begin
  m_fftCount:=strtoint(GetParam(str, 'FFTCount'));
  m_offset:=strtoint(GetParam(str, 'OffsetBlock'));
  m_curve:=GetParam(str, 'Curve');
  fftPlan:=GetFFTPlan(m_fftCount);
  ifftPlan:=GetFFTPlan(m_fftCount);
  setlength(data, m_fftcount);
  GetMemAlignedArray_cmpx_d(m_fftCount, cmplx_al);
  GetMemAlignedArray_cmpx_d(m_fftCount shr 1, MagFFTarray);
  fftPlan.StartInd:=0;
  fftPlan.PCount:=m_fftCount;
  ifftPlan.StartInd:=0;
  ifftPlan.PCount:=m_fftCount;
end;

function TExtFFTflt.GetPropStrF(out pstr: WideString): string;
var
  wstr:WideString;
begin
  GetPropStr(wstr);
  result:=wstr;
end;

procedure TExtFFTflt.link(m: cbaseObjMng);
begin
  m_mng:=m;
end;

procedure TExtFFTflt.Setup;
var
  h:integer;
begin
  OnSetup(0,h);
end;

procedure TExtFFTflt.OnApply;
begin

end;

procedure TExtFFTflt.OnClose;
begin

end;

procedure TExtFFTflt.OnSetup(hwndparent: integer; out phwnd: integer);
begin
  FFTFltFrm.editoper;
  phwnd := FFTfltFrm.handle;
end;


procedure TExtFFTflt.FreeFFTPlanList;
var
  i:integer;
begin
  for I := 0 to length(m_FFTPlanList) - 1 do
  begin
    if m_FFTPlanList[i].PCount<>0 then
    begin
      FreeMemAligned(m_FFTPlanList[i].TableExp);
      m_FFTPlanList[i].TableExp.p:=nil;
      setlength(m_FFTPlanList[i].TableInd,0);
      m_FFTPlanList[i].TableInd:=nil;
    end;
  end;
  setlength(m_FFTPlanList,0);
  for I := 0 to length(m_iFFTPlanList) - 1 do
  begin
    if m_iFFTPlanList[i].PCount<>0 then
    begin
      FreeMemAligned(m_iFFTPlanList[i].TableExp);
      m_iFFTPlanList[i].TableExp.p:=nil;
      setlength(m_iFFTPlanList[i].TableInd,0);
      m_iFFTPlanList[i].TableInd:=nil;
    end;
  end;
  setlength(m_iFFTPlanList,0);
end;

function TExtFFTflt.GetFFTPlan(fftCount: integer): TFFTProp;
var
  I, j, l: Integer;
  r:TFFTProp;
begin
  j:=-1;
  r.PCount:=0;
  for I := 0 to length(m_FFTPlanList) - 1 do
  begin
    r:=m_FFTPlanList[i];
    if r.PCount=fftCount then
    begin
      result:=m_FFTPlanList[i];
      exit;
    end
    else
    begin
      if j=-1 then
      begin
        if r.PCount=0 then
        begin
          j:=i;
        end;
      end;
    end;
  end;
  if (j=-1) then
  begin
    // длина массива
    j:=Length(m_FFTPlanList);
    setlength(m_FFTPlanList, j+10);
  end;
  r:=m_FFTPlanList[j];
  r.StartInd:=0;
  r.PCount:=fftCount;
  GetMemAlignedArray_cmpx_d(fftCount, r.TableExp);
  r.TableInd := GetArrayIndex(fftCount, 2);
  GetFFTExpTable(fftCount, false, tcmxArray_d(r.TableExp.p));
  m_FFTPlanList[j]:=r;
  result:=m_FFTPlanList[j];
end;

function TExtFFTflt.GetInverseFFTPlan(fftCount: integer): TFFTProp;
var
  I, j, l: Integer;
  r:TFFTProp;
begin
  j:=-1;
  r.PCount:=0;
  for I := 0 to length(m_iFFTPlanList) - 1 do
  begin
    r:=m_iFFTPlanList[i];
    if r.PCount=fftCount then
    begin
      result:=m_iFFTPlanList[i];
      exit;
    end
    else
    begin
      if j=-1 then
      begin
        if r.PCount=0 then
        begin
          j:=i;
        end;
      end;
    end;
  end;
  if (j=-1) then
  begin
    // длина массива
    j:=Length(m_iFFTPlanList);
    setlength(m_iFFTPlanList, j+10);
  end;
  r:=m_iFFTPlanList[j];
  r.inverse:=true;
  r.StartInd:=0;
  r.PCount:=fftCount;
  GetMemAlignedArray_cmpx_d(fftCount, r.TableExp);
  r.TableInd := GetArrayIndex(fftCount, 2);
  GetFFTExpTable(fftCount, true, tcmxArray_d(r.TableExp.p));
  m_iFFTPlanList[j]:=r;
  result:=m_iFFTPlanList[j];
end;

end.
