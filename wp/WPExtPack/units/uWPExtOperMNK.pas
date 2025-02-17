unit uWPExtOperMNK;

interface

uses
  ComObj, ActiveX, WPExtPack_TLB, Winpos_ole_TLB,
  StdVcl, PosBase, uMNK, variants,
  uWPProc, uCommonTypes, uWPservices, uWPProcservices,
  ComServ, uCommonMath, sysutils,
  uwpOpers;

type
  // ctrl+shift+c ������������ ����������� �������
  // Ordinary Least Squares, OLS
  TExtOperOLS = class(TAutoObject, IWPExtOper)
  protected
    // �������
    m_nPoints,m_Poly:integer;
    // ������� ������������� ��������
    m_Fs:double;
    // �������� ���������
    m_opts:string;
  public
    procedure GetError(out pnerrcode: integer; out perrstr: WideString);safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure OnSetup(hwndparent: integer; out phwnd: integer); safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);safecall;
  public
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
  end;

  const
    c_MNKPoly = 'Poly';
    c_MNKNPoints = 'nPoints';

implementation


{ TExtOperOLS }



procedure TExtOperOLS.Exec(const psrc1, psrc2: IDispatch; out pdst1,  pdst2: IDispatch);
var
  err: olevariant;
  s1, r1, r2:iwpsignal;
  str:string;
  x,y:olevariant;
  size:integer;
  c:array of double;
  val:double;
  I, polysize: Integer;
begin
  s1 := psrc1 as iwpsignal;
  size:=s1.size;
  x := VarArrayCreate([0, size - 1], varDouble);
  y := VarArrayCreate([0, size - 1], varDouble);
  s1.GetArray(0,size,y,x,true);
  setlength(c, m_Poly+1);
  //buildMNK(m_poly, y, s1.StartX, s1.DeltaX, size, c);
  buildMNK(m_poly, x,y, size, c);
  m_fs:=m_npoints/(s1.MaxX-s1.MinX);
  r1:=Winpos.CreateSignal(5) as iwpsignal;
  r1.SName:=s1.sname+'_OLS';
  r1.startx:=s1.StartX;
  r1.DeltaX:=1/m_fs;
  polysize:=round((s1.MaxX-s1.MinX)*m_fs);
  r1.size:=polysize;
  for I := 0 to polysize - 1 do
  begin
    val:=fi(c,r1.GetX(i));
    r1.SetY(i,val);
  end;
  r2:=Winpos.CreateSignal(5) as iwpsignal;
  r2.size:=m_poly+1;
  r2.SName:=s1.sname+'_OLSPoly';
  for I := 0 to m_poly do
  begin
    r1.SetY(i,c[i]);
  end;
  str:=GetSignalFolder(s1);
  wp.Link(str, r1.sname, r1 as IDispatch);
  wp.Link(str, r2.sname, r2 as IDispatch);
  winpos.Refresh;
  pdst1 := r1;
  pdst2 := r2;
  winpos.DoEvents;
end;

procedure TExtOperOLS.GetError(out pnerrcode: integer; out perrstr: WideString);
begin

end;

procedure TExtOperOLS.OnApply;
begin

end;

procedure TExtOperOLS.OnClose;
begin

end;

procedure TExtOperOLS.GetPropStr(out pstr: WideString);
begin
  pstr:=m_opts;
end;

procedure TExtOperOLS.OnSetup(hwndparent: integer; out phwnd: integer);
begin

end;


procedure TExtOperOLS.SetPropStr(const str: WideString);
begin
  m_opts:=str;
  m_Poly:=strtoint(GetParam(str, c_MNKPoly));
  m_nPoints:=strtoint(GetParam(str, c_MNKNPoints));
end;




end.
