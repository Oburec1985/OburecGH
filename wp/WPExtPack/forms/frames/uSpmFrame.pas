unit uSpmFrame;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, sysutils,
  Dialogs, StdCtrls, uWPProcServices, uCommonMath;

type
  TSpmFrame = class(TFrame)
    WndLabel: TLabel;
    WndCB: TComboBox;
    SpmTypeLabel: TLabel;
    SpmTypeCB: TComboBox;
    SpmResLabel: TLabel;
    SpmResCB: TComboBox;
    NumPointsLabel: TLabel;
    NumPointsCB: TComboBox;
    NulCB: TCheckBox;
  private
    m_eo:tobject;
    m_opts:string;
  public
    procedure SetOpts(str:string);
    function GetOpts:string;
  end;

  const
  // ��� ����
  SINGLEWIN       = 1;
  TRIANGLEWIN     = 2;
  HANNINGWIN      = 3;
  HANNINGWIN_RMS  = 4;
  BLACKMANWIN     = 5;
  BLACKMANWIN_RMS = 6;
  FLATTOP         = 7;
  FLATTOP_RMS     = 8;

  AMPLITUDE_SPM = 4; // ����������� ������
  SPM_SPM = 5; // ������ ��������� ��������
  ImRe_SPM = 6;
  ModPhase_SPM = 7;

  MAG_RMS = 1; // ���
  MAG_A = 2; // ���������
  MAG_R = 3; // ������

  c_numPoints = 'numPoints';
  C_SPMOPTS= 'kindFunc=4,numPoints=16384,nLines=0,typeWindow=1,typeMagnitude=1,type=0,method=0,isMO=1,isCorrectFunc=0,isMonFase=0,isFill0=1,fMaxVal=0,fLog=0,fPrSpec=0,f3D=0,iStandart=1,fFlt=0';


implementation

{$R *.dfm}

function strtobool(str:string):boolean;
begin
  result:=false;
  if str='1' then
    RESULT:=TRUE;
end;

procedure TSpmFrame.SetOpts(str:string);
var
  pars:tstringlist;
  i:integer;
begin
  if str<>'' then
    m_opts:=str
  else
    m_opts:=C_SPMOPTS;

  pars:=ParsStrParamNoSort(m_opts, ',');
  numpointscb.text:=GetParsValue(pars, c_numPoints);
  NulCB.checked:=strtobool(GetParsValue(pars,'isFill0'));
  i:=strtoint(GetParsValue(pars,'typeWindow'));
  case i of
    SINGLEWIN: wndCB.ItemIndex:=0;
    TRIANGLEWIN: wndCB.ItemIndex:=1;
    HANNINGWIN: wndCB.ItemIndex:=2;
    HANNINGWIN_RMS: wndCB.ItemIndex:=3;
    BLACKMANWIN: wndCB.ItemIndex:=4;
    BLACKMANWIN_RMS: wndCB.ItemIndex:=5;
    FLATTOP: wndCB.ItemIndex:=6;
    FLATTOP_RMS: wndCB.ItemIndex:=7;
  end;
  i:=strtoint(GetParsValue(pars,'kindFunc'));
  case i of
    AMPLITUDE_SPM:       SpmTypeCB.ItemIndex:=0;
    SPM_SPM:     SpmTypeCB.ItemIndex:=1;
    ImRe_SPM:      SpmTypeCB.ItemIndex:=2;
    ModPhase_SPM:  SpmTypeCB.ItemIndex:=3;
  end;
  i:=strtoint(GetParsValue(pars,'typeMagnitude'));
  case i of
    MAG_RMS:  SpmResCB.ItemIndex:=0;
    MAG_A:  SpmResCB.ItemIndex:=1;
    MAG_R:  SpmResCB.ItemIndex:=2;
  end;
  pars.destroy;
end;

function TSpmFrame.GetOpts:string;
var
  pars:tstringlist;
  ind:integer;
  v:cString;
  str:string;
begin
  pars:=ParsStrParamNoSort(m_opts, ',');
  if FindInPars(pars, c_numPoints, ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    v.str:=numpointscb.text;
  end;
  if FindInPars(pars,'isFill0',ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    if NulCB.checked then
      v.str:='1'
    else
      v.str:='0';
  end;
  if FindInPars(pars,'typeWindow',ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    case wndCB.itemindex of
      0: v.str:=inttostr(SINGLEWIN);
      1: v.str:=inttostr(TRIANGLEWIN);
      2: v.str:=inttostr(HANNINGWIN);
      3: v.str:=inttostr(HANNINGWIN_RMS);
      4: v.str:=inttostr(BLACKMANWIN);
      5: v.str:=inttostr(BLACKMANWIN_RMS);
      6: v.str:=inttostr(FLATTOP);
      7: v.str:=inttostr(FLATTOP_RMS);
    end;
  end;
  if FindInPars(pars,'kindFunc',ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    case SpmTypeCB.itemindex of
      0: v.str:=inttostr(AMPLITUDE_SPM);
      1: v.str:=inttostr(SPM_SPM);
      2: v.str:=inttostr(ImRe_SPM);
      3: v.str:=inttostr(ModPhase_SPM);
    end;
  end;
  if FindInPars(pars,'typeMagnitude',ind) then
  begin
    v:=cstring(pars.Objects[ind]);
    case SpmResCB.itemindex of
      0: v.str:=inttostr(MAG_A);
      1: v.str:=inttostr(MAG_R);
      2: v.str:=inttostr(MAG_RMS);
    end;
  end;
  str:=ParsToStr(pars);
  result:=str;
  pars.Destroy;
end;

end.
