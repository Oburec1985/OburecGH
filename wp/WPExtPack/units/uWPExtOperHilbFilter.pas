unit uWPExtOperHilbFilter;
// ������ ���������. ������� ���������� ������������ ���� ������ ���� ������ �������.

interface
uses
  ComObj, ActiveX, WPExtPack_TLB, Winpos_ole_TLB,
  StdVcl, PosBase, sysutils,
  uWPProc, uCommonTypes, uWPservices, uWPProcservices,
  uSetList, math, uWPEvents, ComServ, uCommonMath,
  uMyMath,
  uwpOpers;

type
  // ctrl+shift+c ������������ ����������� �������
  TExtOperHilbertFlt = class(TAutoObject, IWPExtOper)
  public
    resfolder:string;
    m_opts:string;
    // ������� ���� ������ ��� ���������
    m_allSignal:boolean;
    m_t1,m_t2:double;
  private
    // ���� -1 �� ��� �����������������
    m_Resample:integer;
    m_nBlocks:integer;
    m_NPoints:integer;
    m_Offset:integer;
    m_error:boolean;
  public
  protected
    m_mng: cWPObjmng;
  public
    procedure Setup;
    procedure GetError(out pnerrcode: integer; out perrstr: WideString);safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
    procedure OnSetup(hwndparent: integer; out phwnd: integer); safecall;
    procedure Exec(const psrc1, psrc2: IDispatch; out pdst1, pdst2: IDispatch);safecall;
  public
    procedure DoEndProcess(sender: tobject);
    function Execute(const psrc1: IDispatch): boolean;
    function eval(s: iwpsignal): iwpsignal;
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
    procedure linc(p_mng: cWPObjmng);
    Constructor create;
    destructor destroy;
  end;

  const
    HilbFltRegName = '������ H2Hilb';
    //HilbFltHintName = '������ Oburec';
    HilbExtName = 'H2F';

    c_Resample='Resample';
    c_NPoints = 'nPoints';
    c_Offset = 'nOfsNext';
    c_MO = 'isMO';
    c_NBlocks = 'nBlocks';
    // ���������� ����� ������ �� ���� ���������� ������
    c_blockExt = 0.75;

implementation
uses
  uFrmHibFltFrm;

constructor TExtOperHilbertFlt.create;
begin
  m_opts:='nPoints=2048,nOfsNext=1536,nBlocks=1,ifMO=1,Resample=-1';
  m_NPoints:=2048;
  m_nBlocks:=1;
  m_Resample:=-1;
end;

destructor TExtOperHilbertFlt.destroy;
begin

end;

procedure TExtOperHilbertFlt.DoEndProcess(sender: tobject);
begin

end;

function TExtOperHilbertFlt.eval(s: iwpsignal): iwpsignal;
begin

end;

procedure TExtOperHilbertFlt.Exec(const psrc1, psrc2: IDispatch; out pdst1,  pdst2: IDispatch);
var
  r1, r2, err: olevariant;
  s1, res:iwpsignal;
  str:string;
  Hilb, Arifm:IWPOperator;
  v:cstring;

begin
  s1 := psrc1 as iwpsignal;
  hilb:= WP.GetObject('/Operators/�������������� ���������') as IWPOperator;
  if (Assigned(hilb)) then
  begin
    if m_Resample<>-1 then
    begin
      res:=Resample(s1,m_Resample);
      //wp.Link(resfolder, s1.sname+'_resample', res as IDispatch);
    end
    else
      res:=s1;
    // ������������ ����� ������
    m_nBlocks:=trunc(res.size/(c_blockExt*m_NPoints));
    if m_nBlocks*m_NPoints>=res.size then
      dec(m_nBlocks);
    m_opts:=ChangeParamF(m_opts, c_NBlocks,inttostr(m_nBlocks));
    m_opts:=ChangeParamF(m_opts, c_Offset,inttostr(m_Offset));
    hilb.loadProperties(m_opts);
    hilb.Exec(res,res,refvar(r1),refvar(r2));
    res := iwpsignal(TVarData(r1).VPointer);
    //wp.Link(resfolder, s1.sname+'_1_'+HilbExtName, res as IDispatch);

    hilb.Exec(res,res,refvar(r1),refvar(r2));
    res := iwpsignal(TVarData(r1).VPointer);
    //wp.Link(resfolder, s1.sname+'_2_'+HilbExtName, res as IDispatch);
    str:=res.sname;
    res:=Multiply(res,-1);

    wp.Link(resfolder, s1.sname+'_'+HilbExtName, res as IDispatch);
    //s2 := iwpsignal(TVarData(r2).VPointer);
    //wp.Link('/Signals/results', s2.sname, s2 as IDispatch);
    //res2:='/Signals/results/'+s2.sname;
  end;
  winpos.Refresh;
  //pdst1 := dst;
  //pdst2 := dst;
  winpos.AddTextInLog(HilbFltRegName, m_opts, true);
  winpos.DoEvents;
end;

function TExtOperHilbertFlt.Execute(const psrc1: IDispatch): boolean;
var
  D: IDispatch;
begin
  result := true;
  Exec(psrc1, psrc1, D, D);
  if m_error then
    result := false;
end;

procedure TExtOperHilbertFlt.GetError(out pnerrcode: integer;
  out perrstr: WideString);
begin

end;

procedure TExtOperHilbertFlt.GetPropStr(out pstr: WideString);
begin
  pstr := m_opts;
end;

procedure TExtOperHilbertFlt.SetPropStr(const str: WideString);
begin
  m_opts:=str;
  m_NPoints:=strtoint(GetParam(str, c_NPoints));
  m_Offset:=round(m_NPoints*0.75);
  m_nBlocks:=strtoint(GetParam(str, c_NBlocks));
  m_Resample:=strtoint(GetParam(str, c_Resample));
end;

procedure TExtOperHilbertFlt.linc(p_mng: cWPObjmng);
begin
   m_mng:=p_mng;
   //mng.Events.AddEvent('RptEO_EndProcess', E_OnEndProcess, DoEndProcess);
end;

procedure TExtOperHilbertFlt.OnApply;
begin

end;

procedure TExtOperHilbertFlt.OnClose;
begin

end;

procedure TExtOperHilbertFlt.OnSetup(hwndparent: integer; out phwnd: integer);
begin
  HilbFltFrm.editoper;
  phwnd := HilbFltFrm.handle;
end;

procedure TExtOperHilbertFlt.Setup;
var
  h:integer;
begin
  OnSetup(0,h);
end;

initialization

//TAutoObjectFactory.create(ComServer, TExtOperHilbertFlt, CLASS_ExtOperHilbertFlt,
//  ciSingleInstance, tmApartment);

end.
