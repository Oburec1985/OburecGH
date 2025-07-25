unit uWPOpers;

interface

uses
  Windows, ActiveX, Classes, ComObj, uNiiPMlib_TLB, StdVcl,
  uBaseObjService, variants, sysutils,
  Winpos_ole_TLB, uCommonMath,  uCommonTypes, uWPProcServices, mathfunction,
  uWPEvents, posbase, u2dMath, uWPServices, dialogs,
  math;

Function GetMO(s: iwpsignal): double;
// ���
Function GetRMS(s: iwpsignal): double;
function GetIntervalSignal (t1t2:point2d; s:iwpsignal):iwpsignal;
function AddConstant (c:double; s:iwpsignal):iwpsignal;
// �������� � ��������� 0..1 dt
function Normalise0_1(const sig: olevariant; MinMax:point2d): iwpsignal;
// ��������� �� ���������
function Multiply(const sig: olevariant; const d:double): iwpsignal;
// �����������������
function Resample(const sig: olevariant; const freq:double): iwpsignal;
// ����������
function TrendMO(const sig: olevariant; const points:integer): iwpsignal;
function TrendAmp(const sig: olevariant; const points:integer): iwpsignal;
function LPF(const sig: olevariant; const order:integer; freq:double): iwpsignal;
// ������ Oburec
function H2Flt(const sig: olevariant; const points:integer; resample:integer): iwpsignal;
// �������� �� ��������� (���������� ������ xy)
// sx, sy - iwpsignal
function BuildWPDependence(sx, sy: olevariant): iwpSignal;
// ��������� ����� ������������� �����������. �� ���� ���� ������ ��������� ������������� �����������
function BuildProbabilityDistribution(s: iwpsignal; palfa:double):iwpSignal;

//function TypeCastToIWPUSML(d: idispatch): iwpusml;
//function TypeCastToIWNode(d: idispatch): iwpnode;
//function TypeCastToIWSignal(d: idispatch): iwpsignal; overload;
//function TypeCastToIWSignal(n: iwpnode): iwpsignal; overload;

function getISignalByPath(str:string):iwpsignal;

implementation

uses
  uWPExtPack, uWPExtOperHilbFilter;

function getISignalByPath(str:string):iwpsignal;
var
  d:idispatch;
begin
  d:=wp.GetNodeStr(str);
  result:=TypeCastToIWSignal(d);
end;

Function GetRMS(s: iwpsignal): double;
var
  oper:iwpoperator;
  opts:string;
  r1,r2:olevariant;
begin
  oper:=WP.GetObject('/Operators/�������. ��������������') as IWPOperator;
  // 0- ��������� ���������
  oper.Exec(s,s,refvar(r1),refvar(r2));
  //result.M := r1.GetY(0);
  //result.D := r1.GetY(1);
  //result.E := r1.GetY(2);
  //result.A3 := r1.GetY(3);
  //result.A4 := r1.GetY(4);
  //result.R := r1.GetY(5) * 2;
  //result.RMS := r1.GetY(6);
  result:=r1.GetY(2);
end;

{GetObjectType
long GetObjectType(IDispatch* Object)
�������� ��� �������.

��� ������� ���
������� ����.
�������� OBJTYPE_EMPTY
0 ������ ������ OBJTYPE_UNKNOWN
1 ������ ������������ ���� OBJTYPE_NODE
2 ���� ������ (IWPNode) OBJTYPE_SIGNAL
3 ������ (IWPSignal) OBJTYPE_OPER
4 �������� (IWPOperator)
Object ������.}

function GetMO(s: iwpsignal): double;
var
  n:iwpnode;
  res:integer;
  oper:iwpoperator;
  d:idispatch;
  opts:string;
  r1,r2:olevariant;
begin
  d:=WP.GetObject('/Operators/�������. ��������������');
  winpos:=wp.DefaultInterface;
  res:=winpos.GetObjectType(d);
  if res=0 then // ���������� ������
  begin
    d:=WP.GetObject('/Operators/Probabilistic analisys');
  end;
  oper:=d as IWPOperator;
  // 0- ��������� ���������
  oper.Exec(s,s,refvar(r1),refvar(r2));
  //result.M := r1.GetY(0);
  result:=r1.GetY(0);
end;

function GetIntervalSignal (t1t2:point2d; s:iwpsignal):iwpsignal;
begin
  result:=wp.GetInterval(s,s.IndexOf(t1t2.x), s.IndexOf(t1t2.y)-s.IndexOf(t1t2.x)) as iwpsignal;
end;

function BuildProbabilityDistribution(s: iwpsignal;palfa:double):iwpSignal;
var
  I: Integer;
  v,d, sigma, x:double;
  p1,p2:point2d;
  sum:double;
  b:boolean;
begin
  // ���������� �����, ����������� 2 �����
  sigma:=palfa;
  b:=true;
  result:=s.Clone(0, s.size) as iwpsignal;
  d:=s.DeltaX;
  sum:=0;
  for I := 0 to s.size - 1 do
  begin
    v:=s.getY(i);
    sum:=v+sum;
    result.setY(i, sum*d);
    result.StartX:=-d;
    // ���������� ������� 2sigma
    if b then
    begin
      if (sum*d)>sigma then
      begin
        p1.x:=result.GetX(i-1);
        p1.y:=result.Gety(i-1);
        p2.x:=result.GetX(i);
        p2.y:=result.Gety(i);
        x:=EvalLineX(sigma, p1,p2);
        result.SetProperty('Sigma', floattostr(x));
        b:=false;
      end;
    end;
  end;
end;

function BuildWPDependence(sx, sy: olevariant): iwpSignal;
var
  oper: iwpoperator;
  pars: tstringlist;
  opts, str, flP: string;
  r1, r2: olevariant;
  s1, s2: iwpSignal;
begin
  oper := WP.GetObject('/Operators/��������������� ������') as iwpoperator;
  opts :=
    'type=0,p2xy=0,crop=0,left=0,right=0,top=0,bottom=0,angle0=0,clcw=0,degr=0';
  oper.loadProperties(opts);
  oper.Exec(sy, sx, refvar(r1), refvar(r2));
  result := iwpSignal(TVarData(r1).VPointer);
end;

function AddConstant (c:double; s:iwpsignal):iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str, flP:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
begin
  oper:=WP.GetObject('/Operators/�����. ��������') as IWPOperator;
  flP:=replaceChar(floattostr(c),',','.');
  // 0- ��������� ���������
  opts:='kind=0,const='+flP;
  oper.loadProperties(opts);
  oper.Exec(s,s,refvar(r1),refvar(r2));
  result:=iwpsignal(TVarData(r1).VPointer);
end;

function Resample(const sig: olevariant; const freq:double):iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str, flP:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
begin
  oper:=WP.GetObject('/Operators/�����������������') as IWPOperator;
  flP:=replaceChar(floattostr(freq),',','.');

  // 2- ��������� �� ���������
  opts:='kind=1,type=0,freq='+flP;
  oper.loadProperties(opts);
  oper.Exec(sig,sig,refvar(r1),refvar(r2));
  result:=iwpsignal(TVarData(r1).VPointer);
end;

function H2Flt(const sig: olevariant; const points:integer; resample:integer): iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str, flP:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
begin
  oper:=WP.GetObject('/����������/'+HilbFltRegName) as IWPOperator;
  opts:=TExtOperHilbertFlt(oper).m_opts;
  ChangeParamF(opts,c_NPoints,inttostr(points));
  //ChangeParamF(opts,c_Resample,resample);
  //oper.SetPropStr
  // 2- ��������� �� ���������
  opts:='typeRes=3,bEquivMag=0,nPoints='+flP;
  oper.loadProperties(opts);
  oper.Exec(sig,sig,refvar(r1),refvar(r2));
  result:=iwpsignal(TVarData(r1).VPointer);
end;

function LPF(const sig: olevariant; const order:integer; freq:double): iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
begin
  oper:=WP.GetObject('/Operators/������������� ����������') as IWPOperator;
  opts:='flag=0,nOrder=51,iType=1,iKind=1,iTypeWin=3,fsr=30,fn=1,fv=30,fs=602.353';
  str:='nOrder='+inttostr(order)+',';
  //s1:=sig.vt;
  str:=str+'fs='+replaceChar(floattostr(1/sig.DeltaX),',','.')+',';
  str:=str+'fsr='+replaceChar(floattostr(freq),',','.');
  opts:=updateParams(opts, str);
  oper.loadProperties(opts);
  oper.Exec(sig,sig,refvar(r1),refvar(r2));
  result:=iwpsignal(TVarData(r1).VPointer);
end;

function TrendMO(const sig: olevariant; const points:integer): iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str, flP:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
  d:idispatch;
  res:integer;
begin
  d:=WP.GetObject('/VibroOpers/���������������� ��������� (������)');
  winpos:=wp.DefaultInterface;
  res:=winpos.GetObjectType(d);
  if res=0 then // ���������� ������
  begin
    d:=WP.GetObject('/VibroOpers/Sequence processing (trends)');
  end;
  oper:=d as IWPOperator;

  flP:=inttostr(points);
  // 3- ������� 0 -RMS
  opts:='typeRez=3,bEquivMag=0,nPoints='+flP;
  oper.loadProperties(opts);
  oper.Exec(sig,sig,refvar(r1),refvar(r2));
  result:=iwpsignal(TVarData(r1).VPointer);
end;

function TrendAmp(const sig: olevariant; const points:integer): iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str, flP:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
  d:idispatch;
  res:integer;
begin
  d:=WP.GetObject('/VibroOpers/���������������� ��������� (������)');
  winpos:=wp.DefaultInterface;
  res:=winpos.GetObjectType(d);
  if res=0 then // ���������� ������
  begin
    d:=WP.GetObject('/VibroOpers/Sequence processing (trends)');
  end;
  oper:=d as IWPOperator;

  flP:=inttostr(points);
  // 3- ������� 0 - RMS; 1 - ampl
  opts:='typeRez=1,bEquivMag=0,nPoints='+flP;
  oper.loadProperties(opts);
  oper.Exec(sig,sig,refvar(r1),refvar(r2));
  result:=iwpsignal(TVarData(r1).VPointer);
end;

function Multiply(const sig: olevariant; const d:double): iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str, flP:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
begin
  oper:=WP.GetObject('/Operators/�����. ��������') as IWPOperator;
  flP:=replaceChar(floattostr(d),',','.');
  // 2- ��������� �� ���������
  opts:='kind=2,const='+flP;
  oper.loadProperties(opts);
  oper.Exec(sig,sig,refvar(r1),refvar(r2));
  result:=iwpsignal(TVarData(r1).VPointer);
end;

function Normalise0_1(const sig: olevariant; MinMax:point2d): iwpsignal;
var
  oper:iwpoperator;
  pars:tstringlist;
  opts, str, flP:string;
  r1,r2:olevariant;
  s1, s2:iwpsignal;
begin
  oper:=WP.GetObject('/Operators/�����. ��������') as IWPOperator;
  // ���������
  flP:=replaceChar(floattostr(minMax.x),',','.');
  opts:='kind=1,const='+flP;
  oper.loadProperties(opts);
  oper.Exec(sig,sig,refvar(r1),refvar(r2));
  // �������
  s1 := iwpsignal(TVarData(r1).VPointer);
  flP:=replaceChar(floattostr(minMax.y-minMax.x),',','.');
  opts:='kind=3,const='+flp;
  oper.loadProperties(opts);
  oper.Exec(s1,s1,refvar(r1),refvar(r2));

  s2 := iwpsignal(TVarData(r1).VPointer);
  wp.Link('/Signals/results', s2.sname, s2 as IDispatch);
  result:=s2;
end;

end.
