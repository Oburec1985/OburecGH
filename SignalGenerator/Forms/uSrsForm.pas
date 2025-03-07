unit uSrsForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, uPage, uChart, uSRS, uKoltSrs,
  dialogs, StdCtrls,  DCL_MYOWN, Spin, uMeraSignal, ExtCtrls, Controls, uTrend,
  uAxis, uCommonTypes, ImgList, uPageSrs, uTagUtils, uSignalsUtils;

type

  TSRSForm = class(TForm)
    GraphGB: TGroupBox;
    Splitter1: TSplitter;
    PropertiesGB: TGroupBox;
    cChart1: cChart;
    Freq1FE: TFloatEdit;
    Freq2FE: TFloatEdit;
    Freq1Label: TLabel;
    Freq2Label: TLabel;
    DFreqFE: TFloatEdit;
    DFreqLabel: TLabel;
    SRSGB: TGroupBox;
    ShockCountLabel: TLabel;
    ShockCountIE: TIntEdit;
    Offset1FE: TFloatEdit;
    Offset2FE: TFloatEdit;
    Offset1Label: TLabel;
    Offset2Label: TLabel;
    ThresholdSE: TSpinEdit;
    ThresholdLabel: TLabel;
    ShockSelectIE: TSpinEdit;
    ShockSelectSE: TLabel;
    EvalSrsBtn: TButton;
    T1Label: TLabel;
    T2Label: TLabel;
    T1FE: TFloatEdit;
    T2FE: TFloatEdit;
    DampingLabel: TLabel;
    DampingFE: TFloatEdit;
    ApplyBtn: TButton;
    GistSE: TSpinEdit;
    GistLabel: TLabel;
    ImageList_16: TImageList;
    ShockMaxFE: TFloatEdit;
    ShockMaxLabel: TLabel;
    TimeRealisationBtn: TButton;
    WnFE: TFloatEdit;
    WnLabel: TLabel;
    TypeCB: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure cChart1Init(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure ShockSelectIEChange(Sender: TObject);
    procedure TimeRealisationBtnClick(Sender: TObject);
  private
    init:boolean;
    Page1,Page2:cPage;
    curSignal:cSignal;

    TimeSrsAlg:cSRSAlg;
    ksrsAlg:cKSRSAlg;
    DiscreetSRSAlg:cDiscreetSRSAlg;

    SrsAlg:cSRSAlg;
  private
    procedure createAlgs;
    function GetSRS:cSrsAlg;
    procedure ShowSignal(s:csignal);
    // �������� ���� � ������� i
    procedure SelectShock(i:integer);
    function GetActiveTrend(page:cpage):ctrend;
  public
    function EvalSRS(signal:csignal):csignal;
  end;

var
  SRSForm: TSRSForm;

implementation
{$R *.dfm}

procedure TSRSForm.ApplyBtnClick(Sender: TObject);
begin
  srsAlg:=GetSRS;
  srsalg.Threshold:=ThresholdSE.Value;
  srsAlg.GistThrehold:=GistSE.Value;
  srsAlg.offset1:=Offset1FE.FloatNum;
  srsAlg.offset2:=Offset2FE.FloatNum;
  SrsAlg.EvalShockEdges(cursignal);
  ShockCountIE.IntNum:=SrsAlg.ShockList.Count;
  ShockSelectIE.MaxValue:=ShockCountIE.IntNum;
  ShockSelectIE.Value:=0;
end;

procedure TSRSForm.cChart1Init(Sender: TObject);
begin
  if not init then
  begin
    Page1:=cpage(cchart1.tabs.activeTab.activepage);
    Page1.Caption:='�������� ����';
    Page1.cursor.cursortype:=1;
    Page2:=cchart1.tabs.activeTab.addPage(true);
    Page2.Caption:='��������� ����';
    Page2.cursor.cursortype:=1;
    init:=true;
  end;
  if init then
    ShowSignal(curSignal);
end;

procedure TSRSForm.createAlgs;
begin
  TimeSrsAlg:=cSrsAlg.create;
  ksrsAlg:=cKSRSAlg.create;
  DiscreetSRSAlg:=cDiscreetSRSAlg.create;
end;

function TSRSForm.GetSRS:cSrsAlg;
begin
  case typecb.ItemIndex of
    0:result:=TimeSrsAlg;
    1:result:=ksrsAlg;
    2:result:=DiscreetSRSAlg;
  end;
end;

function TSRSForm.EvalSRS(signal:csignal):csignal;
begin
  result:=nil;
  createAlgs;
  curSignal:=signal;
  if init then
    ShowSignal(curSignal);
  if showmodal=mrok then
  begin
    srsAlg:=GetSRS;

    if srsAlg.ShockList.Count=0 then
    begin
      srsAlg.EvalShockEdges(signal);
    end;
    if srsAlg.ShockList.Count=0 then
    begin
      showmessage('���� �� ������');
      exit;
    end;
    srsAlg.f1:=Freq1FE.FloatNum;
    srsAlg.f2:=Freq2FE.FloatNum;
    srsAlg.dF:=DFreqFE.FloatNum;
    srsAlg.e:=DampingFE.FloatNum;
    result:=SrsAlg.Eval(signal, ShockSelectIE.Value);
    srsAlg.destroy;
  end;
end;

procedure TSRSForm.TimeRealisationBtnClick(Sender: TObject);
var
  trend:ctrend;
  s:csignal;
  maxv:single;
begin
  srsAlg:=GetSRS;
  trend:=GetActiveTrend(page2);
  trend.Clear;
  srsAlg.e:=DampingFE.FloatNum;
  s:=srsAlg.EvalTimeRealisation(cursignal,ShockSelectIE.Value,wnfe.FloatNum, maxv);

  CopyToTrend(trend, s);
  page2.Normalise;
  s.destroy;
end;

procedure TSRSForm.FormCreate(Sender: TObject);
begin
  init:=false;
end;

function TSRSForm.GetActiveTrend(page:cpage):ctrend;
var
  ax:caxis;
  obj:ctrend;
begin
  // �������� �������� ��������
  obj:=ctrend(page.getChildrenByName('cTrend'));
  if obj=nil then
  begin
    ax:=page.activeAxis;
    obj:=ax.AddTrend;
    obj.drawpoint:=false;
  end;
  result:=obj;
end;

procedure TSRSForm.ShockSelectIEChange(Sender: TObject);
begin
  SelectShock(ShockSelectIE.Value);
end;

procedure TSRSForm.ShowSignal(s:csignal);
var
  tr:ctrend;
begin
  tr:=getactivetrend(page1);
  copyToTrend(tr, s);
  page1.Normalise;

  tr:=getactivetrend(page2);
  CopyToTrend(tr, s);

  page2.Normalise;
end;

procedure TSRSForm.SelectShock(i:integer);
var
  shock:cshock;
  rect:frect;
begin
  if (i<=srsAlg.ShockList.Count-1) and (i>=0) then
  begin
    srsAlg:=GetSRS;
    shock:=srsAlg.GetShock(i);
    rect:=page2.activeAxis.getzoomrect;
    rect.BottomLeft.x:=shock.t1;
    rect.TopRight.x:=shock.t2;
    page2.ZoomfRect(rect);
    Page1.cursor.setx1(shock.t1);
    Page1.cursor.setx2(shock.t2);
    cChart1.redraw;

    t1fe.FloatNum:=shock.t1;
    t2fe.FloatNum:=shock.t2;
    ShockMaxFE.FloatNum:=shock.Amax;
  end;
end;

end.
