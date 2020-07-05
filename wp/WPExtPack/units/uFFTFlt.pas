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

    m_data:TDoubleArray;
    cmplx_al8, fltcmplx_al8, MagFFTarray8,
    cmplx_al,  fltcmplx_al,  MagFFTarray: TAlignDCmpx;
    ifftPlan,fftPlan, fftPlan8, ifftPlan8:TFFTProp;
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

  procedure MultArrays(scales:array of double; cmplx:array of TComplex_d;
                       var outarray:array of TComplex_d);

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

procedure SaveSignal(folder:string; name:string; data:TDoubleArray; deltaX:double; x0:double);
var
  res:iwpsignal;
  i:integer;
begin
  res:=iwpsignal(wp.CreateSignal(vt_r8));
  res.StartX:=x0;
  res.DeltaX:=deltaX;
  res.size:=length(data);
  for I := 0 to res.size-1 do
  begin
    res.SetY(i, data[i]);
  end;
  wp.Link(folder, name, res as IDispatch);
end;

procedure SaveSignalXY(folder:string; nameX, nameY:string; data:TCmxArray_d; deltaX:double; x0:double);
var
  res:iwpsignal;
  i:integer;
begin
  res:=iwpsignal(wp.CreateSignal(vt_r8));
  res.StartX:=x0;
  res.DeltaX:=deltaX;
  res.size:=length(data);
  for I := 0 to res.size-1 do
  begin
    res.SetY(i, data[i].Re);
  end;
  wp.Link(folder, nameX, res as IDispatch);

  res:=iwpsignal(wp.CreateSignal(vt_r8));
  res.StartX:=x0;
  res.DeltaX:=deltaX;
  res.size:=length(data);
  for I := 0 to res.size-1 do
  begin
    res.SetY(i, data[i].Im);
  end;
  wp.Link(folder, nameY, res as IDispatch);
end;


procedure SaveSignalX(folder:string; nameX:string; data:TCmxArray_d; deltaX:double; x0:double);
var
  res:iwpsignal;
  i:integer;
begin
  res:=iwpsignal(wp.CreateSignal(vt_r8));
  res.StartX:=x0;
  res.DeltaX:=deltaX;
  res.size:=length(data);
  for I := 0 to res.size-1 do
  begin
    res.SetY(i, data[i].Re);
  end;
  wp.Link(folder, nameX, res as IDispatch);
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
      m_data[i]:=interval.GetY(i);
    end;
    // test
    {setlength(data, 8);
    for I := 0 to 7 do
    begin
      data[i]:=i;
    end;
    fft_al_d_sse(data, TCmxArray_d(cmplx_al8.p), fftPlan8);
    NormalizeAndScaleSpmMag(TCmxArray_d(cmplx_al8.p), TDoubleArray(MagFFTarray8.p));
    ifft_al_d_sse(TCmxArray_d(cmplx_al8.p), TCmxArray_d(fltcmplx_al8.p), ifftPlan8);}

    fft_al_d_sse(m_data, TCmxArray_d(cmplx_al.p), fftPlan);
    // расчет зафильтрованого спектра
    MultArrays(m_curveScales,TCmxArray_d(cmplx_al.p),TCmxArray_d(fltcmplx_al.p));
    // расчет нормированного исходного спектра (до фильтрации)
    k:=1/(fftPlan.PCount shr 1);
    MULT_SSE_al_cmpx_d(tCmxArray_d(cmplx_al.p), k);
    EvalSpmMag(TCmxArray_d(cmplx_al.p), TDoubleArray(MagFFTarray.p));
    // сохраняем комплексный спектр
    SaveSignalXY('/Signals/results',s1.sname+'_'+'SpmR',s1.sname+'_'+'SpmIm', tCmxArray_d(cmplx_al.p),(1/(s1.deltaX))/m_fftCount, 0);
    // сохраняем амплитудный спектр
    SaveSignal('/Signals/results',s1.sname+'_'+'MagSpm',TDoubleArray(MagFFTarray.p),(1/(s1.deltaX))/m_fftCount, 0);
    ifft_al_d_sse(TCmxArray_d(fltcmplx_al.p), TCmxArray_d(cmplx_al.p), ifftPlan);
    SaveSignalX('/Signals/results',s1.sname+'_'+'SpmFlt',TCmxArray_d(cmplx_al.p),s1.deltaX,s1.StartX);


    startind:=startind+m_offset;
    EndSignal:=true;
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
var
  I: Integer;
begin
  m_fftCount:=strtoint(GetParam(str, 'FFTCount'));
  m_offset:=strtoint(GetParam(str, 'OffsetBlock'));
  m_curve:=GetParam(str, 'Curve');

  fftPlan8:=GetFFTPlan(8);
  ifftPlan8:=GetInverseFFTPlan(8);
  fftPlan:=GetFFTPlan(m_fftCount);
  ifftPlan:=GetInverseFFTPlan(m_fftCount);
  // буфер для данных из сигнала
  setlength(m_data, m_fftcount);
  setlength(m_curveScales, m_fftcount);
  for I := 0 to m_fftcount-1 do
  begin
    m_curveScales[i]:=1;
  end;

  GetMemAlignedArray_cmpx_d(m_fftCount, cmplx_al);
  GetMemAlignedArray_cmpx_d(m_fftCount, fltcmplx_al);
  GetMemAlignedArray_cmpx_d(m_fftCount shr 1, MagFFTarray);

  GetMemAlignedArray_cmpx_d(8, cmplx_al8);
  GetMemAlignedArray_cmpx_d(8, fltcmplx_al8);
  GetMemAlignedArray_cmpx_d(4, MagFFTarray8);

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

procedure MultArrays(scales:array of double;cmplx:array of TComplex_d; var outarray:array of TComplex_d);
var
  i,l:integer;
begin
  l := length(scales);
  for I := 0 to l - 1 do
  begin
    outarray[I].re := cmplx[I].re * scales[I];
    outarray[I].im := cmplx[I].im * scales[I];
  end;
end;

end.
