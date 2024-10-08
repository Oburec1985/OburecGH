unit uFrmHibFltFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, uCommonMath,
  Dialogs, StdCtrls, DCL_MYOWN, uWPservices, uWPProcServices, posbase, uWpProc, uWPExtOperHilbFilter;

type
  THilbFltFrm = class(TForm)
    NumPointsCB: TComboBox;
    NumPointsLabel: TLabel;
    nBlocksIE: TIntEdit;
    Label1: TLabel;
    TimeFE: TFloatEdit;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    SignalLB: TListBox;
    AutoCB: TCheckBox;
    ResampleCB: TCheckBox;
    ResampleIE: TIntEdit;
    T1fe: TFloatEdit;
    Label3: TLabel;
    T2fe: TFloatEdit;
    Label4: TLabel;
    LengthCB: TCheckBox;
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalLBClick(Sender: TObject);
    procedure NumPointsCBChange(Sender: TObject);
    procedure ResampleIEChange(Sender: TObject);
  private
    m_oper:TExtOperHilbertFlt;
    m_pars:tstringlist;
    // ������
    m_slist:tstringlist;
    m_mng:cwpObjMng;
  private
    // ������� �������� �������� � LB
    procedure UpdateSelected;
    function GetNotifyStr(p_opts:string):string;
  public
    function GetPropStr:string;
    Procedure SetPropStr(str:string);
    Procedure Linc(p_mng:cWpObjMng; eo:TExtOperHilbertFlt);
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
    function Showmodal:integer;override;
    function EditOper(str:string):string;overload;
    function EditOper:string;overload;
  end;

var
  HilbFltFrm: THilbFltFrm;

implementation
uses
  Winpos_ole_TLB, uWpExtPack;

{$R *.dfm}

{ THilbFltFrm }

function GetSelItemFromLB(LB:tlistbox):cwpSignal;
var
  item:pointer;
  I: Integer;
begin
  result:=nil;
  for I := 0 to lb.Count - 1 do
  begin
    if lb.Selected[i] then
    begin
      result:=cwpsignal(lb.Items.Objects[i]);
      exit;
    end;
  end;
end;

procedure THilbFltFrm.UpdateSelected;
var
  d:idispatch;
  i,count:integer;
  s:iwpsignal;
  signal:cwpsignal;
begin
  SignalLB.Clear;
  d := posbase.WINPOS.getselectedObject;
  count := getChildCount(d);
  if count <> 0 then
  begin
    // ���� � ���� ��������� �������
    for I := 0 to count - 1 do
    begin
      s := GetChildSignal(d, I);
      signal:=m_mng.GetWPSignal(s);
      SignalLB.AddItem(signal.name,signal);
    end;
  end
  else
  begin
    if IsSignal(d) then
    begin
      signal:=m_mng.GetWPSignal(d as iwpsignal);
      SignalLB.AddItem(signal.name,signal);
    end
    else
    begin
      // �������� �� ������ ���� ������ ��������
      // (�������� ����� ������� �����������)
      d:=posbase.winpos.GetSelectedNode;
      count := getChildCount(d);
      if count <> 0 then
      begin
        // ���� � ���� ��������� �������
        for I := 0 to count - 1 do
        begin
          s := GetChildSignal(d, I);
          signal:=m_mng.GetWPSignal(s);
          SignalLB.AddItem(signal.name,signal);
        end;
      end
    end;
  end;
end;

procedure THilbFltFrm.ApplyBtnClick(Sender: TObject);
var
  i, start, stop:integer;
  s:cwpsignal;
  param:olevariant;
  str:widestring;
  sig:iwpsignal;
begin
  m_Oper.resfolder:='/Signals/'+HilbExtName+'/';
  for I := 0 to SignalLB.count - 1 do
  begin
    s := cwpsignal(SignalLB.Items.Objects[I]);
    sig:=s.Signal;
    if not LengthCB.Checked then
    begin
      start:=sig.indexof(T1fe.FloatNum);
      stop:=sig.indexof(T2fe.FloatNum);
      sig:=wp.GetInterval(sig,start , stop - start) as iwpsignal;
    end;
    // ��������� �������
    m_oper.Execute(sig);
    //TExtOperHilbertFlt(s).res := TExtOperAmpFind(eo).res.Copy;
  end;
  BringToFront;
  str:=GetNotifyStr(m_oper.m_opts);
  param:=str;
  // ����� �����������
  TExtPack(extPack).NotifyPlugin($000F0001, param);
end;

constructor THilbFltFrm.create(aowner: tcomponent);
begin
  inherited;
  M_slist:=TStringList.Create;
  Caption:='��������� '+HilbFltRegName;
end;

destructor THilbFltFrm.destroy;
begin
  inherited;
  M_slist.Destroy;
end;

Procedure THilbFltFrm.Linc(p_mng:cWpObjMng; eo:TExtOperHilbertFlt);
begin
  m_mng:=p_mng;
  m_Oper:=eo;
end;

procedure THilbFltFrm.NumPointsCBChange(Sender: TObject);
begin
  timefe.FloatNum:=strtoint(NumPointsCB.Text)/ResampleIE.IntNum;
end;

procedure THilbFltFrm.ResampleIEChange(Sender: TObject);
begin
  timefe.FloatNum:=strtoint(NumPointsCB.Text)/ResampleIE.IntNum;
end;

function THilbFltFrm.GetNotifyStr(p_opts:string): string;
var
  i:integer;
  signal:cwpsignal;
  str, numstr:string;
begin
//'o="/Operators/����������";p="kindFunc=4, numPoints=16384, nBlocks=530, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=0, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";
//s1_000="/Signals/signal0436.mera/3- 1";i1_000=0;c1_000=8694000;d1_000="/Signals/����������/signal0436.mera_�A/3- 1_�A";dp1_000=1e9a008d;
//s1_001="/Signals/signal0436.mera/18- 1_Taho";i1_001=0;c1_001=8715600;d1_001="/Signals/����������/signal0436.mera_�A/18- 1_Taho_�A";
//dp1_001=1e95690d;
//s1_002="/Signals/signal0436.mera/18- 3_Stop";i1_002=0;c1_002=8715600;d1_002="/Signals/����������/signal0436.mera_�A/18- 3_Stop_�A";dp1_002=1e96a90d;s1_003="/Signals/signal0436.mera/18- 4_Start";i1_003=0;c1_003=8715600;d1_003="/Signals/����������/signal0436.mera_�A/18- 4_Start_�A";dp1_003=1e98248d;'

//'o="/Operators/����������������";
// p="BandCount=1,bx_0=5,by_0=2000,L_pos_0=90,L_neg_0=10,N_pos_0=5,N_neg_0=5,N_Max_0=+,N_Neg_0=+,Units_0=%";
// s1_001="3- 1_�A"i1_001=0;c1_001=2048;d1_001="3- 1_�A_AFlg" s2_002="18- 1_Taho_�A"i2_002=0;c2_002=2048;d2_002="3- 1_�A_AFlg"s3_003="18- 3_Stop_�A"i3_003=0;c3_003=2048;d3_003="18- 3_Stop_�A_AFlg"s4_004="18- 4_Start_�A"i4_004=0;c4_004=2048;d4_004="18- 4_Start_�A_AFlg"'
  result:='o="/����������/'+HilbFltRegName+'";p="'+p_opts+'";';
  for I := 0 to SignalLB.Count - 1 do
  begin
    signal:=cwpsignal(SignalLB.Items.Objects[i]);
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
    result:=result+'s1'+'_'+str+'="'+signal.node.AbsolutePath+'";'
          +'i1'+'_'+str+'='+'0'+';'
          +'c1'+'_'+str+'='+inttostr(signal.Signal.size)+';'
          +'d1'+'_'+str+'="'+m_oper.resfolder+'/'+
          signal.name+HilbExtName+'";';
  end;
end;

function THilbFltFrm.GetPropStr: string;
var
  v:cString;
  ind:integer;
begin
  m_pars:=ParsStrParamNoSort( m_oper.m_opts,',');
  if FindInPars(m_pars,c_NPoints,ind) then
  begin
    v:=cstring(m_pars.Objects[ind]);
    v.str:=numpointscb.text;
  end;
  if FindInPars(m_pars,c_Resample,ind) then
  begin
    v:=cstring(m_pars.Objects[ind]);
    if ResampleCB.Checked then
    begin
      v.str:=ResampleIE.text;
    end
    else
    begin
      v.str:='-1';
    end;
  end;
  result:=ParsToStr(m_pars);
  m_pars.Destroy;
end;

procedure THilbFltFrm.SetPropStr(str: string);
var
  s:iwpsignal;
begin
  m_pars:=ParsStrParamNoSort(str, ',');
  NumPointsCB.text:=GetParsValue(m_pars,c_NPoints);
  ResampleIE.text:=GetParsValue(m_pars,c_Resample);
  m_pars.Destroy;
end;

function THilbFltFrm.Showmodal:integer;
begin
  UpdateSelected;
  Result:=inherited showmodal;
end;

procedure THilbFltFrm.SignalLBClick(Sender: TObject);
var
  s:cwpsignal;
  npoints:integer;
begin
  s:=GetSelItemFromLB(SignalLB);
  npoints:=strtoint(NumPointsCB.Text);
  nBlocksIE.IntNum:=trunc(s.Signal.size/(c_blockExt*npoints));
  if nBlocksIE.IntNum*NPoints>=s.Signal.size then
    nBlocksIE.IntNum:=nBlocksIE.IntNum-1;

  ResampleIE.IntNum:=round(s.getFs);

  T1fe.FloatNum:=s.Signal.MinX;
  T2fe.FloatNum:=s.Signal.MaxX;
end;

function THilbFltFrm.EditOper:string;
var
  res:integer;
begin
  // ��������� �������� � �����
  res:=showmodal;
  if res=mrok then
  begin
    // ��������� �������� � ��������
    m_oper.SetPropStr(GetPropStr);
    m_oper.m_allSignal:=LengthCB.Checked;
    m_oper.m_t1:=T1fe.FloatNum;
    m_oper.m_t2:=T2fe.FloatNum;
    Result:=m_oper.m_opts;
    ApplyBtnClick(nil);
  end;
end;

function THilbFltFrm.EditOper(str:string):string;
var
  res:integer;
begin
  // ��������� �������� � �����
  SetPropStr(str);
  res:=showmodal;
  if res=mrok then
  begin
    // ��������� �������� � ��������
    m_oper.SetPropStr(GetPropStr);
    m_oper.m_allSignal:=LengthCB.Checked;
    m_oper.m_t1:=T1fe.FloatNum;
    m_oper.m_t2:=T2fe.FloatNum;
    Result:=m_oper.m_opts;
    ApplyBtnClick(nil);
  end;
end;

end.
