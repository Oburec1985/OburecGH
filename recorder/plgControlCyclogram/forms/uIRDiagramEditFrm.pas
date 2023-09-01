unit uIRDiagramEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises, upage,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService, uCommonTypes,uCommonMath,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uSpin, uControlWarnFrm, uEditProfileFrm, Spin,
  uTagsListFrame, uaxis, uIrDiagram;

type
  TIRDiagrEditFrm = class(TForm)
    BackGroundColorDialog: TColorDialog;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    Panel1: TPanel;
    UpdateBtn: TSpeedButton;
    PropPanel: TPanel;
    TagsListFrame1: TTagsListFrame;
    TagsGB: TGroupBox;
    Draw_GB: TGroupBox;
    pCountLabel: TLabel;
    AddBtn: TSpeedButton;
    GroupBox5: TGroupBox;
    XChan_CB: TRcComboBox;
    PCountSE: TSpinEdit;
    GroupBox6: TGroupBox;
    YChan_CB: TRcComboBox;
    GraphNameEdit: TEdit;
    DrawPointsCB: TCheckBox;
    ColorPanel: TPanel;
    DrawLineCB: TCheckBox;
    AL_Panel: TPanel;
    X_GB: TGroupBox;
    MaxXLabel: TLabel;
    MinXLabel: TLabel;
    MaxXfe: TFloatEdit;
    MinXfe: TFloatEdit;
    Y_GB: TGroupBox;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    NameLabel: TLabel;
    PSizeEdit: TFloatEdit;
    PSizeLabel: TLabel;
    NameEdit: TEdit;
    SignalsLB: TListBox;
    procedure UpdateBtnClick(Sender: TObject);
  protected
    curChart:TIRDiagramFrm;
    fcurGraph:IRDiagramTag;
  private
    procedure setcurgraph(g:IRDiagramTag);
    function getcurgraph:IRDiagramTag;

    procedure showChartTags;
    procedure createevents;
    procedure Destroyevents;
  public
    property curGraph:IRDiagramTag read getcurgraph write setcurgraph;
    procedure EditChart(chart:TIRDiagramFrm);
    destructor destroy;override;
    constructor create(aowner:tcomponent);override;
  end;

var
  IRDiagrEditFrm: TIRDiagrEditFrm;

implementation

{$R *.dfm}

{ TIRDiagrEditFrm }


constructor TIRDiagrEditFrm.create(aowner: tcomponent);
begin
  inherited;
end;

procedure TIRDiagrEditFrm.createevents;
begin
  //AddPlgEvent('TEditCntlWrnFrm_UpdateCfg', E_RC_ChangeCfg, DoUpdateCfg);
end;

procedure TIRDiagrEditFrm.Destroyevents;
begin

end;

destructor TIRDiagrEditFrm.destroy;
begin
  inherited;
end;

procedure TIRDiagrEditFrm.EditChart(chart: TIRDiagramFrm);
var
  i:integer;
  p:tprofile;
  page:cIRPage;
  gr:IRDiagramTag;
begin
  curChart:=chart;
  if chart<>nil then
  begin
    page:=cIRPage(chart.chart.activePage);
    NameEdit.text:=chart.name;
    MinXfe.FloatNum:=page.fXAxis.x;
    MaxXfe.FloatNum:=page.fXAxis.y;
    MinYfe.FloatNum:=page.fYAxis.y;
    MaxYfe.FloatNum:=page.fYAxis.y;
    if curchart.fpage<>nil then
      PSizeEdit.FloatNum:=curchart.PSize;
    showChartTags;
    TagsListFrame1.ShowChannels;
    XChan_CB.updateTagsList;
    YChan_CB.updateTagsList;
    gr:=chart.getGraph(0);
    if gr<>nil then
    begin
      setComboBoxItem(gr.taho.tagname,XChan_CB);
      setComboBoxItem(gr.t1.tagname,YChan_CB);
    end;
    showmodal;
  end;
end;


function TIRDiagrEditFrm.getcurgraph: IRDiagramTag;
begin
  result:=fcurGraph;
end;

procedure TIRDiagrEditFrm.setcurgraph(g:IRDiagramTag);
begin
  fcurGraph:=g;
end;

procedure TIRDiagrEditFrm.showChartTags;
var
  i:integer;
  g:IRDiagramTag;
begin
  signalsLB.Clear;
  for I := 0 to curChart.GraphCount - 1 do
  begin
    g:=curChart.getGraph(i);
    SignalsLB.AddItem(g.name, g);
  end;
end;

procedure TIRDiagrEditFrm.UpdateBtnClick(Sender: TObject);
var
  I: Integer;
  g:IRDiagramTag;
  t1,t2:itag;
begin
  if signalsLB.SelCount>0 then
  begin
    for I := 0 to SignalsLB.Count - 1 do
    begin
      if signalsLB.Selected[i] then
      begin
        g:=IRDiagramTag(signalsLB.Items.Objects[i]);
        t1:=Xchan_cb.gettag(Xchan_cb.ItemIndex);
        t2:=Ychan_cb.gettag(Ychan_cb.ItemIndex);
        g.ConfigTag(t2, t1);
      end;
    end
  end;
end;

end.
