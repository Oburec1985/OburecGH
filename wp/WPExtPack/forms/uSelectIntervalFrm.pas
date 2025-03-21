unit uSelectIntervalFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, DCL_MYOWN, ImgList, uChart, uWPProc,
  uCommonTypes, uDoubleCursor, uWPProcServices, upage, utrend, uaxis, uBufftrend1d,
  ComCtrls;

type
  TSelectIntervalFrm = class(TForm)
    ModeRG: TRadioGroup;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    AutoGroup: TGroupBox;
    Panel2: TPanel;
    Panel3: TPanel;
    ChanCB: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    StartCB: TComboBox;
    Label6: TLabel;
    StopCB: TComboBox;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    cChart1: cChart;
    LengthE: TFloatEdit;
    Label8: TLabel;
    srccb: TComboBox;
    StartE: TFloatEdit;
    StopE: TFloatEdit;
    EvalBtn: TButton;
    ActiveLabel: TLabel;
    ApplyBtn: TButton;
    ProgressBar1: TProgressBar;
    idIE: TIntEdit;
    IDLabel: TLabel;
    procedure ModeRGClick(Sender: TObject);
    procedure StartEnter(Sender: TObject);
    procedure SrcCBSelect(Sender: TObject);
    procedure cChart1Init(Sender: TObject);
    procedure ChanCBChange(Sender: TObject);
    procedure StartEChange(Sender: TObject);
    procedure StopEChange(Sender: TObject);
    procedure EvalBtnClick(Sender: TObject);
    procedure StartCBChange(Sender: TObject);
    procedure StopCBChange(Sender: TObject);
  private
    mng:cWpObjMng;
    src:csrc;
    curs:cdoublecursor;
    //tr:cbufftrend1d;
    tr:ctrend;
    ax:caxis;
    page:cpage;
    start,stop:cTrig;
    startT, stopT:double;
  protected
    // ������������� CB � ������������ � ��������� ����������
    procedure updateSrcFrm;
    // ��������� ��������� ����������
    procedure FillSrcCB;
    // ��������� ��� ������ ������ �����/����
    procedure checkstart;
    procedure checkstop;
    // ��������� ���������� ������
    procedure FillCB;
    procedure evalAllTest;
    procedure normalisecursor;
    procedure InitView;
    function StatusBar(Sender: TObject; process:integer):integer;
  public
    Procedure LincMng(m:cWPObjMng);
    function showmodal(s:csrc):integer;
  end;

var
  SelectIntervalFrm: TSelectIntervalFrm;

implementation

{$R *.dfm}

Procedure TSelectIntervalFrm.LincMng(m:cWPObjMng);
begin
  mng:=m;
  if mng.SrcCount>0 then
    src:=mng.GetSrc(0);
end;

procedure TSelectIntervalFrm.checkstart;
begin
  if StartCB.ItemIndex=-1 then
  begin
    StartCb.Color:=$008080FF;
  end
  else
  begin
    StartCb.Color:=clWindow;
  end;
end;

procedure TSelectIntervalFrm.checkstop;
begin
  if StopCB.ItemIndex=-1 then
  begin
    StopCB.Color:=$008080FF;
  end
  else
  begin
    StopCB.Color:=clWindow;
  end;
end;

procedure TSelectIntervalFrm.ModeRGClick(Sender: TObject);
begin
  // ������� ������ ������� ������� ������
  if ModeRG.ItemIndex=1 then
  begin
    StartE.Enabled:=true;
    StopE.Enabled:=true;
    AutoGroup.Enabled:=false;
    ActiveLabel.Font.Color:=clRed;
    ActiveLabel.Caption:='�� �������';
  end;
  if ModeRG.ItemIndex=0 then
  begin
    StartE.Enabled:=true;
    StopE.Enabled:=true;
    AutoGroup.Enabled:=false;
    ActiveLabel.Font.Color:=clRed;
    ActiveLabel.Caption:='�� �������';
  end;
  if ModeRG.ItemIndex=2 then
  begin
    AutoGroup.Enabled:=true;
    ActiveLabel.Font.Color:=clGreen;
    ActiveLabel.Caption:='�������';
    checkstart;
    checkstop;
  end;
  if ModeRG.ItemIndex=3 then
  begin
    AutoGroup.Enabled:=true;
    ActiveLabel.Font.Color:=clRed;
    ActiveLabel.Caption:='�� �������';
    evalAllTest;
  end;
end;

procedure TSelectIntervalFrm.StartCBChange(Sender: TObject);
begin
  checkstart;
  start:= cTrig(StartCB.Items.Objects[StartCB.ItemIndex]);
end;

procedure TSelectIntervalFrm.StartEChange(Sender: TObject);
begin
  if curs<>nil then
    curs.setx1(StartE.FloatNum);
end;

procedure TSelectIntervalFrm.StopCBChange(Sender: TObject);
begin
  checkstop;
  stop:= ctrig(StopCB.Items.Objects[StopCB.ItemIndex]);
end;

procedure TSelectIntervalFrm.StopEChange(Sender: TObject);
begin
  if curs<>nil then
    curs.setx2(stopE.FloatNum);
end;

procedure TSelectIntervalFrm.StartEnter(Sender: TObject);
begin
  lengthe.FloatNum:=stope.FloatNum-starte.FloatNum;
end;


procedure TSelectIntervalFrm.normalisecursor;
begin
  curs.x1:=page.m_viewport[0]+round(page.m_viewport[2]/2);
  curs.x2:=page.m_viewport[0]+round(page.m_viewport[2]/2)+
  round(page.m_viewport[2]/4);
  cChart1.redraw;
end;

procedure TSelectIntervalFrm.InitView;
begin
  curs:=cDoubleCursor(cChart1.activepage.getChild('cDoubleCursor'));
  curs.cursortype:=c_DoubleCursor;
  page:=cpage(cChart1.activepage);
  ax:=page.activeAxis;
  //tr:=cBuffTrend1d.create;
  //ax.AddChild(tr);
  tr:=ax.AddTrend;
  tr.drawpoint:=false;
end;

procedure TSelectIntervalFrm.cChart1Init(Sender: TObject);
begin
  InitView;
end;

procedure TSelectIntervalFrm.ChanCBChange(Sender: TObject);
var
  s:cwpsignal;
begin
  s:=cWPSignal(chancb.Items.Objects[chancb.ItemIndex]);
  if s<>nil then
  begin
    //createtrend(tr,s);
    //page.NormaliseX;
    //page.NormaliseY;
    //normalisecursor;
    evalAllTest;
  end;
end;

procedure TSelectIntervalFrm.SrcCBSelect(Sender: TObject);
begin
  src:=csrc(srccb.Items.Objects[srccb.ItemIndex]);
  updateSrcFrm;
end;

procedure TSelectIntervalFrm.evalAllTest;
var
  minmax:point2d;
  i:integer;
  s:cWPSignal;
  min, max:double;
begin
  for i := 0 to src.ChildCount - 1 do
  begin
    s := src.getSignalObj(i);
    if i = 0 then
    begin
      min := s.Signal.MinX;
      max := s.Signal.MaxX;
    end
    else
    begin
      if s.Signal.MinX > min then
        min := s.Signal.MinX;
      if s.Signal.MaxX < max then
        max := s.Signal.MaxX;
    end;
  end;
  minmax:=p2d(min,max);
  startT:=minmax.x;
  stopT:=minmax.y;
  starte.FloatNum:=minmax.x;
  StopE.FloatNum:=minmax.y;
  lengthe.FloatNum:=minmax.y-minmax.x;
end;

procedure TSelectIntervalFrm.EvalBtnClick(Sender: TObject);
var
  o1, o2:tobject;
  t1,t2:double;
begin
  ProgressBar1.Position:=0;
  if StartCB.ItemIndex>-1 then
  begin
    o1:=start;
    if tobject(o1) is ctrig then
    begin
      src.trigstart:=start;
      t1:=start.GetTime;
      if t1<startT then
        t1:=startT;
      StartE.FloatNum:=t1;
    end
    else
    begin
      t1:=startT;
    end;
  end;
  if StopCB.ItemIndex>-1 then
  begin
    o2:=stop;
    if tobject(o2) is ctrig then
    begin
      src.trigstop:=stop;
      t2:=stop.GetTime;
      if t2>stopT then
        t2:=stopT;
      StopE.FloatNum:=t2;
    end
    else
    begin
      t2:=stopT;
    end;
  end;
  ProgressBar1.Position:=0;
end;

// ��������� ��������� ����������
procedure TSelectIntervalFrm.FillSrcCB;
var
  I: Integer;
  s:csrc;
begin
  for I := 0 to mng.SrcCount - 1 do
  BEGIN
    s:=mng.GetSrc(i);
    srccb.AddItem(s.name,s);
  END;
  srccb.Text:=src.name;
end;

procedure TSelectIntervalFrm.FillCB;
var
  I: Integer;
  t:cTrig;
begin
  chancb.clear;
  Startcb.clear;
  Stopcb.clear;
  for I := 0 to mng.TrigList.Count - 1 do
  begin
    t:=mng.getTrig(i);
    Startcb.Items.AddObject(t.id,t);
    Stopcb.Items.AddObject(t.id,t);
  end;
end;

procedure TSelectIntervalFrm.updateSrcFrm;
var
  I: Integer;
begin
  FillCB;
  evalalltest;
  for I := 0 to srccb.Items.count - 1 do
  begin
    if srccb.Items.Strings[i]=src.name then
    begin
      srccb.Items.Text:=src.name;
      srccb.ItemIndex:=I;
      exit;
    end;
  end;

end;

function TSelectIntervalFrm.showmodal(s:csrc):integer;
var
  I: Integer;
  l_src:csrc;
  iopts:integer;
begin
  src:=s;
  FillSrcCB;
  updateSrcFrm;
  if s.TrigStart<>nil then
  begin
    for I := 0 to startcb.items.Count - 1 do
    begin
      if startcb.items.Strings[i]=s.TrigStart.id then
      begin
        startcb.ItemIndex:=i;
        start:= s.TrigStart;
      end;
    end;
  end;
  if s.TrigStop<>nil then
  begin
    for I := 0 to stopcb.items.Count - 1 do
    begin
      if stopcb.items.Strings[i]=s.TrigStop.id then
      begin
        stopcb.ItemIndex:=i;
        stop:= s.TrigStop;
      end;
    end;
  end;
  case s.IntervalOpts of
    c_IntervalAllTest:Moderg.ItemIndex:=3;
    c_IntervalTime:Moderg.ItemIndex:=1;
    c_IntervalTrigs:Moderg.ItemIndex:=2;
    c_IntervalCursor:Moderg.ItemIndex:=0;
  end;

  idIE.IntNum:=s.id;

  result:=inherited showmodal;
  if result=mrOk then
  begin
    s.t1:=StartE.FloatNum;
    s.t2:=StopE.FloatNum;
    s.TrigStart:=start;
    s.TrigStop:=stop;
    s.id:=idIE.IntNum;
    case moderg.ItemIndex of
      0:s.IntervalOpts:=c_IntervalCursor;
      1:s.IntervalOpts:=c_IntervalTime;
      2:s.IntervalOpts:=c_IntervalTrigs;
      3:s.IntervalOpts:=c_IntervalAllTest;
    end;
  end;
end;

function TSelectIntervalFrm.StatusBar(Sender: TObject; process:integer):integer;
begin
  ProgressBar1.Position:=trunc(process);
  result:=1;
end;

end.
