unit uFFTfltFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, Spin, ExtCtrls, uChart, uFFTflt,
  uWPservices, uCommonTypes, posbase, Winpos_ole_TLB,
  inifiles,
  utrend,
  MathFunction,
  uComponentServises,
  uCommonMath, DCL_MYOWN;

type
  LBRecord = class
    s:iwpsignal;
  end;

  TFFTFltFrm = class(TForm)
    ActionPanel: TPanel;
    RightPanel: TPanel;
    ApplyBtn: TButton;
    BtnListView1: TBtnListView;
    SignalsLB: TListBox;
    EditCurvePanel: TPanel;
    F1se: TSpinEdit;
    F2se: TSpinEdit;
    F1Label: TLabel;
    F2Label: TLabel;
    Indexse_01: TSpinEdit;
    Indexse_02: TSpinEdit;
    F1indLabel: TLabel;
    F2indLabel: TLabel;
    ScaleSE: TSpinEdit;
    Label5: TLabel;
    ����������: TButton;
    ScaleCurveChart: cChart;
    FFTCountLabel: TLabel;
    OffsetLabel: TLabel;
    OffsetSE: TSpinEdit;
    dFLabel: TLabel;
    pCountIE: TIntEdit;
    pCountBtn: TSpinButton;
    procedure pCountBtnUpClick(Sender: TObject);
    procedure pCountBtnDownClick(Sender: TObject);
    procedure SignalsLBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    m_oper:TExtFFTflt;
    curv:ctrend;
  private
    procedure UpdateFs;
    procedure ShowCurv;
    function Selected:iwpSignal;
    procedure showSignals;
    function getsignal(i:integer):iwpsignal;
    function GetPropStr: string;
    Procedure SetPropStr(str: string);
    function GetNotifyStr(p_opts: string): string;
  public
    procedure link(eo: TExtFFTflt);
    function EditOper: string;
  end;

var
  FFTFltFrm: TFFTFltFrm;

implementation
uses
  uWpExtPack;

{$R *.dfm}

{ TFFTFltFrm }

function TFFTFltFrm.EditOper: string;
var
  res: integer;
  i: integer;
  p2:point2d;

  start, stop: integer;
  param: olevariant;
  wstr: widestring;
  s: iwpsignal;
  iD: idispatch;
  str:string;
  rec:LBRecord;
begin
  // ��������� �������� � �����
  p2:=GetActiveCursorX;
  showSignals;
  res := showmodal;
  if res = mrok then
  begin
    // ��������� �������� � ��������
    m_oper.SetPropStr(GetPropStr);
    // ����� ���������
    for i := 0 to SignalsLB.items.count - 1 do
    begin
      rec:=LBRecord(SignalsLB.Items.Objects[i]);
      s := rec.s;
      m_oper.Exec(s, s, iD, iD);
    end;
    // ��������� � ������ ��� ��������
    // 'o="/Operators/����������";p="kindFunc=5, numPoints=16384, nBlocks=1, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=1, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";s1_000="/Signals/6363.mera/NI6363-{PXI1Slot18-18- 1}";i1_000=0;c1_000=1000;d1_000="/Signals/����������/NI6363-{PXI1Slot18-18- 1}_Real#2";d2_000="/Signals/����������/NI6363-{PXI1Slot18-18- 1}_Image#2";dp1_000=3f8f260d;dp2_000=3f8fa48d;'
    str := GetNotifyStr(m_oper.GetPropStrF(wstr));
    param := str;
    // ����� �����������
    TExtPack(extPack).NotifyPlugin($000F0001, param);
  end;
end;

procedure TFFTFltFrm.FormCreate(Sender: TObject);
begin
  curv:=cTrend.create;
end;

function TFFTFltFrm.GetNotifyStr(p_opts: string): string;
var
  i: integer;
  str, numstr: string;
  s1:iwpsignal;
  n:iwpnode;
begin
  result := 'o="/����������/' + 'FFT ������' + '";p="' + p_opts + '";';
  for I := 0 to SignalsLB.Count - 1 do
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

function TFFTFltFrm.GetPropStr: string;
var
  pars: tstringlist;
  b: boolean;
  str: string;
begin
  pars := tstringlist.Create;
  addParam(pars, 'FFTCount', inttostr(pCountIE.IntNum));
  addParam(pars, 'OffsetBlock', inttostr(OffsetSE.Value));
  //addParam(pars, 'Curve', inttostr(pCountSE.Value));

  result := ParsToStr(pars);
  delpars(pars);
  pars.Destroy;
end;

function TFFTFltFrm.getsignal(i: integer): iwpsignal;
var
  rec:lbrecord;
begin
  rec:=lbrecord(SignalsLB.Items.Objects[i]);
  result:=rec.s;
end;

procedure TFFTFltFrm.link(eo: TExtFFTflt);
begin
  m_oper := eo;
end;

procedure TFFTFltFrm.pCountBtnDownClick(Sender: TObject);
begin
  if PCountIE.IntNum>2 then
    PCountIE.IntNum:=round(PCountIE.IntNum/2);
  OffsetSE.Value:=PCountIE.IntNum;
  updatefs;
end;

procedure TFFTFltFrm.pCountBtnUpClick(Sender: TObject);
begin
  if PCountIE.IntNum>2 then
    PCountIE.IntNum:=PCountIE.IntNum*2;
  OffsetSE.Value:=PCountIE.IntNum;
  updatefs;
end;

function TFFTFltFrm.Selected: iwpSignal;
begin
  if SignalsLB.Count=0 then
  begin
    result:=nil;
    exit;
  end;
  if SignalsLB.ItemIndex>-1 then
  begin
    result:=LBRecord(SignalsLB.Items.Objects[SignalsLB.ItemIndex]).s;
  end
  else
  begin
    result:=LBRecord(SignalsLB.Items.Objects[0]).s;
  end;
end;

procedure TFFTFltFrm.SetPropStr(str: string);
begin

end;

procedure TFFTFltFrm.showSignals;
var
  n, ch:iwpnode;
  s:iwpsignal;
  li:tlistitem;
  I: Integer;
  rec:LBRecord;
begin
  n:=getCurSrcInMainWnd;
  for I := 0 to signalsLB.Count - 1 do
  begin
    rec:=LBRecord(signalsLB.Items.Objects[i]);
    rec.Destroy;
  end;
  signalsLB.clear;
  for I := 0 to n.ChildCount - 1 do
  begin
    ch:=n.At(i) as iwpnode;
    if issignal(ch) then
    begin
      s:=TypeCastToIWSignal(ch);
      rec:=LBRecord.Create;
      rec.s:=s;
      signalsLB.Items.AddObject(s.sname+' F='+formatstrnoe(1/s.DeltaX, 4),rec);
    end;
  end;
end;

procedure TFFTFltFrm.SignalsLBClick(Sender: TObject);
begin
  updatefs;
end;

procedure TFFTFltFrm.UpdateFs;
var
  s:iwpsignal;
begin
  s:=Selected;
  if s<>nil then
  begin
    dfLabel.Caption:='dF='+formatstrNoE((1/s.DeltaX)/pCountIE.IntNum,4);
  end;
end;

end.
