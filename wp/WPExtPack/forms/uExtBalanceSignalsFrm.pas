unit uExtBalanceSignalsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, ComCtrls, uBtnListView, ExtCtrls,
  uExtBalanceSignals,uWPservices, uCommonTypes, posbase, Winpos_ole_TLB,
  inifiles,
  uComponentServises,
  uCommonMath;

type
  TBalanceZeroFrm = class(TForm)
    Panel1: TPanel;
    ChannelsLV: TBtnListView;
    Panel2: TPanel;
    BeginFE: TFloatEdit;
    Label1: TLabel;
    Label2: TLabel;
    EndFE: TFloatEdit;
    Label4: TLabel;
    Label5: TLabel;
    PathEdit: TEdit;
    Label3: TLabel;
    SaveBtn: TButton;
    LoadBtn: TButton;
    ApplyBtn: TButton;
    procedure LoadBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PathEditChange(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
  private
    m_oper:TExtBalanceSignals;
  private
    procedure showSignals;
    function getsignal(i:integer):iwpsignal;
    function GetPropStr: string;
    Procedure SetPropStr(str: string);
    function GetNotifyStr(p_opts: string): string;
  public
    procedure link(eo: TExtBalanceSignals);
    function EditOper: string;
  end;

var
  BalanceZeroFrm: TBalanceZeroFrm;

implementation

uses
  uWpExtPack;

{$R *.dfm}

{ TBalanceZeroFrm }
procedure TBalanceZeroFrm.SaveBtnClick(Sender: TObject);
var
  ifile:tinifile;
  c:integer;
  I: Integer;
  sname,str, str1:string;
  j: Integer;
  li:tlistitem;
begin
  ifile:=TIniFile.Create(PathEdit.Text);
  c:=0;
  for j := 0 to channelslv.items.count - 1 do
  begin
    li:=channelslv.Items[j];
    if li.Checked then
    begin
      channelslv.GetSubItemByColumnName('���',li,str1);
      sname:=ExtractFileName(str1);
      ifile.writeString('main', 's_'+inttostr(c), sname);
      inc(c);
    end;
  end;
  ifile.WriteInteger('main', 'count', c);
  ifile.Destroy;
end;

procedure TBalanceZeroFrm.LoadBtnClick(Sender: TObject);
var
  ifile:tinifile;
  c:integer;
  I: Integer;
  sname,str, str1:string;
  j: Integer;
  li:tlistitem;
begin
  ifile:=TIniFile.Create(PathEdit.Text);
  c:=ifile.ReadInteger('main', 'count', 0);
  for I := 0 to c - 1 do
  begin
    str:=ifile.ReadString('main', 's_'+inttostr(i), '');
    for j := 0 to channelslv.items.count - 1 do
    begin
      li:=channelslv.Items[j];
      channelslv.GetSubItemByColumnName('���',li,str1);
      sname:=ExtractFileName(str1);
      if sname=str then
      begin
        li.Checked:=true;
        break;
      end;
    end;
  end;
  ifile.Destroy;
end;

procedure TBalanceZeroFrm.PathEditChange(Sender: TObject);
begin
  CheckFolderComponent(PathEdit, true);
end;

function TBalanceZeroFrm.EditOper: string;
var
  res: integer;
  i: integer;
  p2:point2d;
begin
  // ��������� �������� � �����
  p2:=GetActiveCursorX;
  BeginFE.FloatNum:=p2.x;
  EndFE.FloatNum:=p2.y;
  showSignals;
  res := showmodal;
  if res = mrok then
  begin
    // ��������� �������� � ��������
    m_oper.SetPropStr(GetPropStr);
    ApplyBtnClick(nil);
  end;
end;

function TBalanceZeroFrm.getsignal(i:integer):iwpsignal;
var
  li:tlistitem;
  str:string;
begin
  li:=ChannelsLV.items[i];
  ChannelsLV.GetSubItemByColumnName('���', li, str);
  result:=findSignal(str);
end;

procedure TBalanceZeroFrm.ApplyBtnClick(Sender: TObject);
var
  i, start, stop: integer;
  param: olevariant;
  wstr: widestring;
  s: iwpsignal;
  iD: idispatch;
  str:string;
  li:tlistitem;
begin
  str := GetNotifyStr(m_oper.GetPropStrF(wstr));
  param := str;
  // ����� ���������
  for i := 0 to ChannelsLV.items.count - 1 do
  begin
    li:=ChannelsLV.items[i];
    if li.Checked then
    begin
      s := GetSignal(i);
      m_oper.Exec(s, s, iD, iD);
    end;
  end;
  BringToFront;
  // ��������� � ������ ��� ��������
  // 'o="/Operators/����������";p="kindFunc=5, numPoints=16384, nBlocks=1, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=1, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";s1_000="/Signals/6363.mera/NI6363-{PXI1Slot18-18- 1}";i1_000=0;c1_000=1000;d1_000="/Signals/����������/NI6363-{PXI1Slot18-18- 1}_Real#2";d2_000="/Signals/����������/NI6363-{PXI1Slot18-18- 1}_Image#2";dp1_000=3f8f260d;dp2_000=3f8fa48d;'
  // ����� �����������
  TExtPack(extPack).NotifyPlugin($000F0001, param);
end;

function TBalanceZeroFrm.GetNotifyStr(p_opts: string): string;
var
  i: integer;
  str, numstr: string;
  s1:iwpsignal;
  n:iwpnode;
begin
  // 'o="/Operators/����������";p="kindFunc=4, numPoints=16384, nBlocks=530, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=0, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";
  // s1_000="/Signals/signal0436.mera/3- 1";i1_000=0;c1_000=8694000;d1_000="/Signals/����������/signal0436.mera_�A/3- 1_�A";dp1_000=1e9a008d;
  // s1_001="/Signals/signal0436.mera/18- 1_Taho";i1_001=0;c1_001=8715600;d1_001="/Signals/����������/signal0436.mera_�A/18- 1_Taho_�A";
  // dp1_001=1e95690d;
  // s1_002="/Signals/signal0436.mera/18- 3_Stop";i1_002=0;c1_002=8715600;d1_002="/Signals/����������/signal0436.mera_�A/18- 3_Stop_�A";dp1_002=1e96a90d;s1_003="/Signals/signal0436.mera/18- 4_Start";i1_003=0;c1_003=8715600;d1_003="/Signals/����������/signal0436.mera_�A/18- 4_Start_�A";dp1_003=1e98248d;'

  // 'o="/Operators/����������������";
  // p="BandCount=1,bx_0=5,by_0=2000,L_pos_0=90,L_neg_0=10,N_pos_0=5,N_neg_0=5,N_Max_0=+,N_Neg_0=+,Units_0=%";
  // s1_001="3- 1_�A"i1_001=0;c1_001=2048;d1_001="3- 1_�A_AFlg" s2_002="18- 1_Taho_�A"i2_002=0;c2_002=2048;d2_002="3- 1_�A_AFlg"s3_003="18- 3_Stop_�A"i3_003=0;c3_003=2048;d3_003="18- 3_Stop_�A_AFlg"s4_004="18- 4_Start_�A"i4_004=0;c4_004=2048;d4_004="18- 4_Start_�A_AFlg"'
  result := 'o="/����������/' + 'FFTInverse' + '";p="' + p_opts + '";';
  for I := 0 to ChannelsLV.items.Count - 1 do
  begin
    s1:=GetSignal(i);
    numstr:=inttostr(i);
    str:=numstr;
    if length(str)<3 then
    begin
      while length(str)<>3 do
      begin
       str:='0'+str;
      end;
    end;
    // ����� ������ ������ ����, �.�. �� ���� ����� ������������ ��������
    // � ��������������� ID
    n:=findNode(s1);
    result:=result+'s1'+'_'+str+'="'+n.AbsolutePath+'";';
    result:=result+
    'i1'+'_'+str+'='+'0'+';'
    +'c1'+'_'+str+'='+inttostr(s1.size)+';'
    +'d1'+'_'+str+'="'+'/Signals/results/'+ s1.sname+'_BalZero';
  end;
end;

function TBalanceZeroFrm.GetPropStr: string;
var
  pars: tstringlist;
  b: boolean;
  str: string;
begin
  pars := tstringlist.Create;
  addParam(pars, 'X1', BeginFE.text);
  addParam(pars, 'X2', Endfe.text);
  result := ParsToStr(pars);
  delpars(pars);
  pars.Destroy;
end;

procedure TBalanceZeroFrm.link(eo: TExtBalanceSignals);
begin
  m_oper := eo;
end;

procedure TBalanceZeroFrm.SetPropStr(str: string);
var
  P: tstringlist;
begin
  P := ParsStrParamNoSort(str, ',');
  BeginFE.FloatNum :=strtoFloatExt(GetParsValue(P, 'X1'));
  EndFE.FloatNum :=strtoFloatExt(GetParsValue(P, 'X2'));
  P.Destroy;
end;

procedure TBalanceZeroFrm.showSignals;
var
  n, ch:iwpnode;
  li:tlistitem;
  I: Integer;
begin
  n:=getCurSrcInMainWnd;
  ChannelsLV.clear;
  for I := 0 to n.ChildCount - 1 do
  begin
    ch:=n.At(i) as iwpnode;
    if issignal(ch) then
    begin
      li:=ChannelsLV.Items.add;
      ChannelsLV.SetSubItemByColumnName('���',ch.absolutepath,li)
    end;
  end;
  LVChange(ChannelsLV);
end;

end.
