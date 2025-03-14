unit uEvalSkipBladesForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, CommonOptsFrame, upage, uaxis, uMarkers, uCommonTypes,
  uturbina, ustage, uBaseBldAlg, uBldCompProc, usensor, uSpin, uSensorRep,
  uSensorList,Spin, ExtCtrls, uChart, ImgList, DCL_MYOWN, uMyMath;

type

  TEvalSkipBladesForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    EvalBladesOptsGB: TGroupBox;
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    GroupBox1: TGroupBox;
    SkipLabel: TLabel;
    StepLabel: TLabel;
    FirstSkipSE: TSpinEdit;
    LastSkipSE: TSpinEdit;
    cChart1: cChart;
    PreviewCB: TCheckBox;
    SkipBladeLabel: TLabel;
    SkipBladeSE: TSpinEdit;
    ImageList_16: TImageList;
    CorrLabel: TLabel;
    CorrFE: TFloatEdit;
    procedure PreviewCBClick(Sender: TObject);
    procedure SkipBladeSEChange(Sender: TObject);
    procedure cChart1Init(Sender: TObject);
    procedure BaseAlgOptsFrame1SensorsNameCBChange(Sender: TObject);
  private
    m1,m2:cmarkerlist;
    m_t,m_s:csensor;
    m_stage:cstage;
    // ����� ����������� �����
    newShape,
    // �������� ������� ��� ���������� ����� ������
    OldShape,
    // ��������� ����� �����
    EvaledShape:array of single;
    init:boolean;
  public
  private
    procedure evalShape(opts:cBaseOpts);
    // ��������������� ����� ������ � �����
    procedure SaveShape;
    procedure ReturnShape;
    procedure CopyShape;
    procedure ReEvalShape;
    procedure SetMarkers(m:cMarkerList; buf:array of single);
    procedure SetAxisScale;
  public
    Function ShowModal(t:csensor; s:calgSensorList;opts:cBaseOpts):integer;
  end;

var
  EvalSkipBladesForm: TEvalSkipBladesForm;

implementation
uses
  ugetskipbladesalg;
{$R *.dfm}

// ���������� �������� ������� �� 1 ������ ������� ������ �����
procedure ReEvalOffsetsWithSkip(SkipInd:integer; const a:array of single;var res:array of single);
var
  count,newInd,i:integer;
begin
  count:=length(a);
  for I := 0 to  count- 1 do
  begin
    if i+skipind<count then
      newind:=i+skipind
    else
      newind:=skipind+i- count;
    res[newind]:=a[i];
  end;
end;

procedure TEvalSkipBladesForm.SetAxisScale;
var
  I: Integer;
  max, min:single;
  rect:frect;
begin
  max:=newShape[0]*1.05;
  min:=newShape[0]*0.95;
  rect.BottomLeft:=p2(0,min);
  rect.TopRight:=p2(m_stage.bladecount,max);
  cpage(cchart1.activePage).activeAxis.ZoomfRect(rect);
  m1.updateSize;
  m2.updateSize;
end;

procedure TEvalSkipBladesForm.ReEvalShape;
var
  I: Integer;
begin
  ReEvalOffsetsWithSkip(skipBladeSE.value,newShape,EvaledShape);
  setmarkers(m2,EvaledShape);
  corrFE.FloatNum:=GetCorr(oldShape,EvaledShape);
end;

procedure TEvalSkipBladesForm.SetMarkers(m:cMarkerList; buf:array of single);
var
  I: Integer;
begin
  m.clear;
  for I := 0 to m_stage.BladeCount - 1 do
  begin
    m.AddMarker(p2(i,buf[i]));
  end;
  cChart1.redraw;
end;

procedure TEvalSkipBladesForm.evalShape(opts:cBaseOpts);
begin
  SaveShape;
  if Basealgoptsframe1.SensorsNameCB.ItemIndex<>-1 then
    m_s:=csensor(Basealgoptsframe1.SensorsNameCB.Items.Objects[Basealgoptsframe1.SensorsNameCB.ItemIndex])
  else
    m_s:=nil;
  if m_s<>nil then
  begin
    if Basealgoptsframe1.TahoCB.ItemIndex<>-1 then
      m_t:=csensor(Basealgoptsframe1.TahoCB.Items.Objects[Basealgoptsframe1.TahoCB.ItemIndex])
    else
      m_t:=nil;
    if m_t<>nil then
    begin
      m_s.skipBlade:=0;
      m_stage.Shape.Eval(m_t,m_s,m_stage,false, opts.startind, opts.endind);
      // �������� ����� � ����� ������ newShape
      copyShape;
      // ���������� �������� �����
      ReturnShape;
      ReEvalShape;
      SetAxisScale;
    end;
  end;
end;

procedure TEvalSkipBladesForm.BaseAlgOptsFrame1SensorsNameCBChange(
  Sender: TObject);
begin
  BaseAlgOptsFrame1.SensorsNameCBChange(Sender);
  evalShape(BaseAlgOptsFrame1.curopts);
end;

procedure TEvalSkipBladesForm.cChart1Init(Sender: TObject);
var
  page:cpage;
  a:caxis;
begin
  cChart1.showTV:=false;
  page:=cpage(cChart1.activeTab.activepage);
  page.clear;
  a:=page.Newaxis;
  m1:=cMarkerList.create;
  m1.name:='����� ������';
  m1.color:=Red;
  a.AddChild(m1);
  m2:=cMarkerList.create;
  m2.name:='����� ������ �� �������';
  m2.color:=blue;
  a.AddChild(m2);
end;

procedure TEvalSkipBladesForm.ReturnShape;
begin
  move(OldShape[0],m_stage.Shape.offset[0],sizeof(single)*m_stage.BladeCount);
end;

procedure TEvalSkipBladesForm.CopyShape;
begin
  move(m_stage.Shape.offset[0],newShape[0],sizeof(single)*m_stage.BladeCount);
end;

procedure TEvalSkipBladesForm.SaveShape;
var
  I: Integer;
begin
  m_stage:=cstage(Basealgoptsframe1.StageCB.Items.Objects[Basealgoptsframe1.StageCB.ItemIndex]);
  setlength(OldShape,m_stage.BladeCount);
  setlength(NewShape,m_stage.BladeCount);
  setlength(EvaledShape,m_stage.BladeCount);
  move(m_stage.Shape.offset[0],OldShape[0],sizeof(single)*m_stage.BladeCount);
  if PreviewCB.Checked then
  begin
    // ������ �������� �����
    SetMarkers(m1,OldShape);
  end;
end;

procedure TEvalSkipBladesForm.PreviewCBClick(Sender: TObject);
begin
  if PreviewCB.Checked then
  begin
    evalShape(BaseAlgOptsFrame1.curopts);
  end;
end;

Function TEvalSkipBladesForm.ShowModal(t:csensor;s:calgSensorList; opts:cBaseOpts):integer;
var
  st:cstage;
begin
  // ��� ������
  BaseAlgOptsFrame1.SetOpts(t,s,Opts);
  BaseAlgOptsFrame1.ValidBladeGB.Enabled:=false;
  BaseAlgOptsFrame1.UseBadTickProcCheckBox.Enabled:=false;
  LastSkipSE.Value:=cGetSkipBladesOpts(opts).stage.BladeCount-1;
  st:=cstage(s.GetSensor(0).stage);
  LastSkipSE.MaxValue:=st.bladecount;
  FirstSkipSE.Value:=cGetSkipBladesOpts(opts).firstskip;
  FirstSkipSE.MinValue:=0;

  result:= inherited showmodal;
  if Result=mrok then
  begin
    cGetSkipBladesOpts(opts).lastskip:=LastSkipSE.Value;
    cGetSkipBladesOpts(opts).firstskip:=FirstSkipSE.Value;
    BaseAlgOptsFrame1.GetOpts(opts);
  end;
end;

procedure TEvalSkipBladesForm.SkipBladeSEChange(Sender: TObject);
begin
  if m_stage<>nil then
  begin
    if skipBladeSE.value<0 then
      skipBladeSE.value:=0
    else
    begin
      if skipBladeSE.value>m_stage.BladeCount-1 then
        skipBladeSE.value:=0
    end;
    if previewCB.Checked then
      ReEvalShape;
  end;
end;

end.
