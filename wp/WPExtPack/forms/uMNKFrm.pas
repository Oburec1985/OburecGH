unit uMNKFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, uCommonMath,
  Dialogs, StdCtrls, DCL_MYOWN, Spin, uWPServices, uWPProcservices,uWPExtOperMNK;

type
  TMNKFrm = class(TForm)
    PolyLabel: TLabel;
    PolySE: TSpinEdit;
    PolyCount: TIntEdit;
    Label1: TLabel;
    ApplyBtn: TButton;
  private
    m_pars:tstringlist;
    m_oper:TExtOperOLS;
  public
    //constructor create(aowner:tcomponent);override;
    //destructor destroy;override;
    procedure setpropstr(str:string);
    function GetPropStr: string;
    function EditOper(str:string):string;
  end;

var
  MNKFrm: TMNKFrm;

implementation

{$R *.dfm}

{ TMNKFrm }


function TMNKFrm.GetPropStr: string;
var
  v:cString;
  ind:integer;
  str:widestring;
begin
  m_oper.GetPropStr(str);
  m_pars:=ParsStrParamNoSort( str,',');
  if FindInPars(m_pars, c_MNKNPoints, ind) then
  begin
    v:=cstring(m_pars.Objects[ind]);
    v.str:=PolyCount.text;
  end;
  if FindInPars(m_pars,c_MNKPoly,ind) then
  begin
    v:=cstring(m_pars.Objects[ind]);
    v.str:=polyse.text;
  end;
  result:=ParsToStr(m_pars);
  m_pars.Destroy;
end;

procedure TMNKFrm.setpropstr(str:string);
begin
  m_pars:=ParsStrParamNoSort(str, ',');
  PolyCount.IntNum:=strtoint(GetParsValue(m_pars,c_MNKNPoints));
  PolySE.Value:=strtoint(GetParsValue(m_pars,c_MNKPoly));
  m_pars.Destroy;
end;

function TMNKFrm.EditOper(str: string): string;
var
  res:integer;
  lstr:string;
begin
  // ��������� �������� � �����
  SetPropStr(str);
  res:=showmodal;
  if res=mrok then
  begin
    lstr:=GetPropStr;
    // ��������� �������� � ��������
    m_oper.SetPropStr(lstr);
    Result:=str;
  end;
end;

end.
