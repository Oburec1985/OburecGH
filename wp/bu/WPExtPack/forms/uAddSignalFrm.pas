unit uAddSignalFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,   uWPProc, uCommonMath, uWPProcServices, uFindMaxOper,
  libniipm_tlb, uCorrectUTS, EditSignalPathFrm,
  uWPEvents, StdCtrls;


type
  TEditSignalsListFrm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    DelBtn: TButton;
    AddBtn: TButton;
    GroupBox3: TGroupBox;
    SRCsignalsLB: TListBox;
    DSTsignalsLB: TListBox;
    procedure AddBtnClick(Sender: TObject);
  private
    mng:cWpObjMng;
    m_oper:coperobj;
  private
    // проверка есть ли строка в списке используемых каналов
    function checkdDstName(s:string):boolean;
  public
    procedure edit(o:coperobj; s:csrc);
    procedure ShowOperSignals(oper:coperobj);
    procedure ShowSRCSignals(src:csrc);
    procedure LincMng(p_mng:cWpObjMng);
  end;

var
  EditSignalsListFrm: TEditSignalsListFrm;

implementation

{$R *.dfm}

procedure TEditSignalsListFrm.AddBtnClick(Sender: TObject);
var
  I: Integer;
  sOpts:cSignalsOpt;
  signalDsc:cSignalDesc;
  sig:cwpSignal;
begin
  for I := 0 to SRCsignalsLB.Count - 1 do
  begin
    if SRCsignalsLB.Selected[i] then
    begin
      sOpts:=cSignalsOpt.create(m_oper);
      signalDsc:=cSignalDesc.Create;
      sig:=cwpSignal(SrcSignalsLB.Items.Objects[i]);
      signalDsc.path:=sig.node.AbsolutePath;
      signalDsc.i0:=sig.Signal.IndexOf(m_oper.Interval.t1);
      signalDsc.count:=sig.Signal.IndexOf(m_oper.Interval.t2)-signalDsc.i0;
      sopts.addSrc(signaldsc);
      sopts.pathDstList.Add('<src>');
      m_oper.AddSrc(sopts);
    end;
  end;
  SRCsignalsLB.DeleteSelected;
  ShowOperSignals(m_oper);
end;

function TEditSignalsListFrm.checkdDstName(s:string):boolean;
var
  I: Integer;
begin
  result:=false;
  for I := 0 to dstsignalslb.Count - 1 do
  begin
    if DSTsignalsLB.Items.Strings[i]=s then
    begin
      result:=true;
      exit;
    end;
  end;
end;

procedure TEditSignalsListFrm.LincMng(p_mng:cWpObjMng);
begin
  mng:=p_mng;
end;

procedure TEditSignalsListFrm.ShowOperSignals(oper:coperobj);
var
  I: Integer;
  sopts:cSignalsOpt;
  opt:cSignalDesc;
begin
  DSTsignalsLB.Clear;
  for I := 0 to oper.srcList.Count - 1 do
  begin
    sopts:=oper.GetSignalsOpts(i);
    opt:=cSignalDesc(sopts.pathSrcList.Objects[0]);
    DSTsignalsLB.AddItem(trimname(opt.path), opt);
  end;
end;


procedure TEditSignalsListFrm.ShowSRCSignals(src:csrc);
var
  I: Integer;
  s:cwpsignal;
  sopts:cSignalsOpt;
  opt:cSignalDesc;
begin
  for I := 0 to src.childCount - 1 do
  begin
    s:=src.getSignalObj(i);
    if not checkdDstName(s.Name) then
    begin
      SrcSignalsLB.AddItem(s.Name, s);
    end;
  end;
end;

procedure TEditSignalsListFrm.edit(o:coperobj; s:csrc);
var
  I: Integer;
  str:string;
  opt:cSignalDesc;
begin
  m_oper:=o;
  if s=nil then
    exit;
  ShowOperSignals(o);
  ShowSRCSignals(s);
  if showmodal = mrok then
  begin
    o.srcList.Clear;
    //for I := 0 to DSTsignalsLB.Count - 1 do
    //begin
    // opt:=cSignalDesc(DSTsignalsLB.Items.Objects[i]);
      //o.addSrc(opt);
    //end;
  end;
end;

end.
