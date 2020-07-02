unit uFFTfltFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, Spin, ExtCtrls, uChart, uFFTflt,
  uWPservices, uCommonTypes, posbase, Winpos_ole_TLB,
  inifiles,
  uComponentServises,
  uCommonMath;

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
    Установить: TButton;
    ScaleCurveChart: cChart;
    PCountSE: TSpinEdit;
    FFTCountLabel: TLabel;
    OffsetLabel: TLabel;
    OffsetSE: TSpinEdit;
    dFLabel: TLabel;
    procedure PCountSEKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PCountSEKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    m_oper:TExtFFTflt;
  private
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
  // переносим свойства в форму
  p2:=GetActiveCursorX;
  showSignals;
  res := showmodal;
  if res = mrok then
  begin
    // переносим свойства в оператор
    m_oper.SetPropStr(GetPropStr);
    // Вызов обработки
    for i := 0 to SignalsLB.items.count - 1 do
    begin
      rec:=LBRecord(SignalsLB.Items.Objects[i]);
      s := rec.s;
      m_oper.Exec(s, s, iD, iD);
    end;
    // Сообщение в журнал что вызывали
    // 'o="/Operators/АвтоСпектр";p="kindFunc=5, numPoints=16384, nBlocks=1, nLines=0, typeWindow=1, ofsNextBlock=16384, typeMagnitude=1, type=0, method=0, isMO=1, isCorrectFunc=0, isMonFase=0, isFill0=1, fMaxVal=0, fLog=0, fPrSpec=0, f3D=0, fSwapXZ=0, iStandart=1, fFlt=0, fQual=6, log_kind=0, log_OpZn=2e-005, log_fOpZn=0, prs_kind=1, prs_loFreq=1, prs_s2n=100, prs_fCorr=0, prs_strCorr=, prs_typeCorr=0";s1_000="/Signals/6363.mera/NI6363-{PXI1Slot18-18- 1}";i1_000=0;c1_000=1000;d1_000="/Signals/Результаты/NI6363-{PXI1Slot18-18- 1}_Real#2";d2_000="/Signals/Результаты/NI6363-{PXI1Slot18-18- 1}_Image#2";dp1_000=3f8f260d;dp2_000=3f8fa48d;'
    str := GetNotifyStr(m_oper.GetPropStrF(wstr));
    param := str;
    // вызов уведомления
    TExtPack(extPack).NotifyPlugin($000F0001, param);
  end;
end;

function TFFTFltFrm.GetNotifyStr(p_opts: string): string;
var
  i: integer;
  str, numstr: string;
  s1:iwpsignal;
  n:iwpnode;
begin
  result := 'o="/Расширения/' + 'FFT фильтр' + '";p="' + p_opts + '";';
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
    // важно писать полный путь, т.к. по нему потом определяется источник
    // и соответствующий ID
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
  addParam(pars, 'FFTCount', inttostr(pCountSE.Value));
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

procedure TFFTFltFrm.PCountSEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if PCountSE.Value>2 then
    PCountSE.Value:=round(PCountSE.Value/2);
end;

procedure TFFTFltFrm.PCountSEKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if PCountSE.Value>2 then
    PCountSE.Value:=PCountSE.Value*2;
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
      signalsLB.Items.AddObject(s.sname,rec);
    end;
  end;
end;

end.
