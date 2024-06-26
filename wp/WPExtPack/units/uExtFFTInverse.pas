// ������� �������� ��������
// 1) ������� ���� .ridl � IDE. � ������ �������� �������� CoClass
// 2) �� ������� implements �������� ��������� IWPExtOper
// 3) ������� ������� ���� � ���������� ������� � ����������� ���� ����� ������� �� ������� (������ ���������� ��� safecall)
// 4) �������� ������ initialization ��� � ���� �����
// 5) �������� � ������� Connect �������:
// eoRpt := TExtOperRpt.create(); // RptRegName - ��� ��� ����������� � ����� WP
// WINPOS.RegisterExtOper(eoRpt, 1, 1, RptRegName, 'Rpt', True);

unit uExtFFTInverse;

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
  ap
  ;

type

// �������� �� ����� ������ �������� ��������� (�� �������� �� ������
  // ������� ����� �������). ������ � ������� �������� ��������� �����
  TExtFFTInverse = class(TAutoObject, IWPExtOper)
  private
    m_mng: cBaseObjmng;
    resfolder:string;
    m_blockcount,
    m_fftCount:integer;
    m_dx:double;
  public
    procedure GetError(out pnerrcode: integer; out perrstr: WideString);safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);safecall;
    procedure OnSetup(hwndparent: integer; out phwnd: integer); safecall;
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
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
  uFFTInverseFrm;

const
  c_OperName = 'FFTInverse';

{TExtFFTInverse}
constructor TExtFFTInverse.create;
begin

end;

destructor TExtFFTInverse.destroy;
begin

end;

function TExtFFTInverse.Execute(const psrc1: IDispatch): boolean;
var
  D: IDispatch;
begin
  result := true;
  Exec(psrc1, psrc1, D, D);
  //if m_error then
  //  result := false;
end;

procedure TExtFFTInverse.Exec(const psrc1, psrc2: IDispatch; out pdst1,
  pdst2: IDispatch);
var
  r1, r2, err: olevariant;
  s1, s2, res:iwpsignal;
  str:string;
  k:double;
  wstr:widestring;
  v:cstring;
  I, size: Integer;
  a1,a2,x:olevariant;
  cmpx:TComplex1DArray;
  resArray:treal1darray;
begin
  s1 := psrc1 as iwpsignal;
  s2 := psrc2 as iwpsignal;
  size:=s1.size;
  begin
    a1 := VarArrayCreate([0, size-1], varDouble);
    a2 := VarArrayCreate([0, size-1], varDouble);
    x := VarArrayCreate([0, size-1], varDouble);
    setlength(cmpx, size*2);
    s1.GetArray(0,size,a1,x,true);
    s2.GetArray(0,size,a2,x,true);
    for I := 0 to size - 1 do
    begin
      cmpx[i].X:=a1[i];
      cmpx[i].y:=a2[i];
    end;
    // �������������� �������
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
    wp.Link('/Signals/results', s1.sname+'_'+s2.sname+'fftInv', res as IDispatch);
  end;
  winpos.Refresh;
  GetPropStr(wstr);
  winpos.AddTextInLog(c_OperName, wstr, true);
  winpos.DoEvents;
end;


procedure TExtFFTInverse.GetError(out pnerrcode: integer; out perrstr: WideString);
begin

end;

procedure TExtFFTInverse.GetPropStr(out pstr: WideString);
var
  pars: tstringlist;
  b: boolean;
  str: string;
begin
  pars := tstringlist.create;
  addParam(pars, 'FFTCount', inttostr(m_fftCount));
  addParam(pars, 'dX', floattostr(m_dx));
  addParam(pars, 'BCount', floattostr(m_blockcount));
  pstr := ParsToStr(pars);
  delpars(pars);
  pars.destroy;
end;

procedure TExtFFTInverse.SetPropStr(const str: WideString);
begin
  m_fftCount:=strtoint(GetParam(str, 'FFTCount'));
  m_blockcount:=strtoint(GetParam(str, 'BCount'));
  m_dx:=strtoFloatExt(GetParam(str, 'dX'));
end;

function TExtFFTInverse.GetPropStrF(out pstr: WideString): string;
var
  wstr:WideString;
begin
  GetPropStr(wstr);
  result:=wstr;
end;

procedure TExtFFTInverse.link(m: cbaseObjMng);
begin
  m_mng:=m;
end;

procedure TExtFFTInverse.Setup;
var
  h:integer;
begin
  OnSetup(0,h);
end;

procedure TExtFFTInverse.OnApply;
begin

end;

procedure TExtFFTInverse.OnClose;
begin

end;

procedure TExtFFTInverse.OnSetup(hwndparent: integer; out phwnd: integer);
begin
  FFTInverseFrm.editoper;
  phwnd := FFTInverseFrm.handle;
end;


end.
