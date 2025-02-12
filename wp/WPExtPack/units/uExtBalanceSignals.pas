unit uExtBalanceSignals;

interface
uses
  windows, ComObj, types, Forms, ActiveX, WPExtPack_TLB, Winpos_ole_TLB,
  StdVcl, PosBase,
  uWPProc, classes, uCommonTypes, uWPservices, sysutils, utrend,
  uSetList, math, uWPEvents, ComServ, uCommonMath,
  MathFunction,
  uMyMath,
  uWPOpers,
  uBaseObjMng,
  uWPProcServices,
  Pathutils,
  Variants
  ;

type
  // �������� �� ����� ������ �������� ��������� (�� �������� �� ������
  // ������� ����� �������). ������ � ������� �������� ��������� �����
  TExtBalanceSignals = class(TAutoObject, IWPExtOper)
  private
    m_mng: cBaseObjmng;
    resfolder:string;
    m_blockcount,
    m_fftCount:integer;
    m_dx:double;
    x1,x2:double;
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
  uExtBalanceSignalsFrm;

const
  c_OperName = 'BalanceZero';

constructor TExtBalanceSignals.create;
begin

end;

destructor TExtBalanceSignals.destroy;
begin

end;

function TExtBalanceSignals.Execute(const psrc1: IDispatch): boolean;
var
  D: IDispatch;
begin
  result := true;
  Exec(psrc1, psrc1, D, D);
  //if m_error then
  //  result := false;
end;

procedure TExtBalanceSignals.Exec(const psrc1, psrc2: IDispatch; out pdst1,
  pdst2: IDispatch);
var
  r1, r2, err: olevariant;
  s1, s2, res:iwpsignal;
  str:string;
  k:double;
  wstr:widestring;
  I, size: Integer;
begin
  s1 := psrc1 as iwpsignal;
  size:=s1.size;
  begin
    s2:=getinterval(s1, p2d(x1,x2));
    k:=GetMO(s2);
    res:=AddConstant(-k,s1);
    wp.Link('/Signals/results', s1.sname+'_'+'balZero', res as IDispatch);
  end;
  winpos.Refresh;
  GetPropStr(wstr);
  winpos.AddTextInLog(c_OperName, wstr, true);
  winpos.DoEvents;
end;


procedure TExtBalanceSignals.GetError(out pnerrcode: integer; out perrstr: WideString);
begin

end;

procedure TExtBalanceSignals.GetPropStr(out pstr: WideString);
var
  pars: tstringlist;
  b: boolean;
  str: string;
begin
  pars := tstringlist.create;
  addParam(pars, 'X1', floattostr(x1));
  addParam(pars, 'X2', floattostr(x2));
  pstr := ParsToStr(pars);
  delpars(pars);
  pars.destroy;
end;

procedure TExtBalanceSignals.SetPropStr(const str: WideString);
begin
  x1:=strtoFloatExt(GetParam(str, 'X1'));
  x2:=strtoFloatExt(GetParam(str, 'X2'));
end;

function TExtBalanceSignals.GetPropStrF(out pstr: WideString): string;
var
  wstr:WideString;
begin
  GetPropStr(wstr);
  result:=wstr;
end;

procedure TExtBalanceSignals.link(m: cbaseObjMng);
begin
  m_mng:=m;
end;

procedure TExtBalanceSignals.Setup;
var
  h:integer;
begin
  OnSetup(0,h);
end;

procedure TExtBalanceSignals.OnApply;
begin

end;

procedure TExtBalanceSignals.OnClose;
begin

end;

procedure TExtBalanceSignals.OnSetup(hwndparent: integer; out phwnd: integer);
begin
  BalanceZeroFrm.editoper;
  phwnd := BalanceZeroFrm.handle;
end;

end.
