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
    TagsTV: TVTree;
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
  protected
    curChart:TIRDiagramFrm;
    fcurGraph:IRDiagramTag;
  private
    procedure setcurgraph(g:IRDiagramTag);
    function getcurgraph:IRDiagramTag;
    procedure updateopts;

    procedure showChartTags;
    procedure showGraph;
    procedure createevents;
    procedure Destroyevents;
    // ������� ����������� �������� � ����
    procedure SetGraphToChart;
  public
    property curGraph:IRDiagramTag read getcurgraph write setcurgraph;
    procedure DoUpdateCfg(sender:tobject);
    procedure updateTagsList;
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
  AddPlgEvent('TEditCntlWrnFrm_UpdateCfg', E_RC_ChangeCfg, DoUpdateCfg);
end;

procedure TIRDiagrEditFrm.Destroyevents;
begin
  RemovePlgEvent(DoUpdateCfg, E_RC_ChangeCfg);
end;

destructor TIRDiagrEditFrm.destroy;
begin
  inherited;
end;



procedure TIRDiagrEditFrm.DoUpdateCfg(sender: tobject);
begin

end;

procedure TIRDiagrEditFrm.EditChart(chart: TIRDiagramFrm);
var
  i:integer;
  p:tprofile;
  page:cpage;
begin
  curChart:=chart;
  if chart<>nil then
  begin
    page:=cpage(chart.chart.activePage);
    NameEdit.text:=chart.name;
    MinXfe.FloatNum:=page.activeAxis.min.x;
    MaxXfe.FloatNum:=page.activeAxis.max.x;
    MinYfe.FloatNum:=page.activeAxis.min.y;
    MaxYfe.FloatNum:=page.activeAxis.max.y;
    if curchart.chart.activePage<>nil then
      PSizeEdit.FloatNum:=cpage(curchart.chart.activePage).GetPointSize;
    updateTagsList;
    showChartTags;
    showmodal;
  end;
end;


function TIRDiagrEditFrm.getcurgraph: TWrkPoint;
begin
  result:=fcurGraph;
end;

procedure TIRDiagrEditFrm.setcurgraph(g:IRDiagramTag);
begin
  fcurGraph:=g;
end;

procedure TIRDiagrEditFrm.SetGraphToChart;
var
  I: Integer;
  g, graph:IRDiagramTag;
  j: Integer;
  add:boolean;
  n, parentnode:pVirtualNode;
  d:PNodeData;
begin
  curchart.clearGraphList;
  for I := 0 to tagsTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := tagsTV.GetNext(n)
    else
      n := tagsTV.GetFirst;
    d:=tagsTV.GetNodeData(n);
    if d<>nil then
    begin
      if tobject(d.data) is TWrkPoint then
      begin
        g:=IRDiagramTag(d.data);
        add:=true;
        for j := 0 to curChart.GraphCount - 1 do
        begin
          graph:=curChart.getgraph(j);
          if graph=g then
          begin
            add:=false;
            break;
          end;
        end;
        if add then
        begin
          d:=tagsTV.GetNodeData(n.Parent);
          curchart.addGraph(g,caxis(d.data));
        end;
      end;
    end;
  end;
end;


procedure TIRDiagrEditFrm.showChartTags;
begin

end;

procedure TIRDiagrEditFrm.showGraph;
begin

end;

procedure TIRDiagrEditFrm.updateopts;
var
  i,j:integer;
  g:IRDiagramTag;
  a:caxis;
  next, Node: PVirtualNode;
  Data, parentdata: PNodeData;
begin
  i:=0;
  j:=0;

  Node := tagsTV.GetFirstSelected(true);
  while Node <> nil do
  begin
    Data := tagsTV.GetNodeData(Node);
    if tobject(Data.Data) is TWrkPoint then
    begin
      g:=IRDiagramTag(Data.Data);
      SetMultiSelectComponentString(XChan_cb, g.m_irAlg.ftaho.m_tag.tagname);
      SetMultiSelectComponentString(YChan_cb, g.m_irAlg.fspm.m_tag.tagname);
      SetMultiSelectComponentString(GraphNameEdit, g.name);
      SetMultiSelectComponentString(PCountSE, inttostr(g.PCount));
      SetMultiSelectComponentBool(DrawPointsCB, g.DrawPoints);
      SetMultiSelectComponentBool(DrawLineCB, g.DrawLines);
      ColorPanel.Color:=rgbtoint(g.PointColor);
      SetMultiSelectComponentString(MinYfe, cIRPage(curChart.chart.activePage).);
      SetMultiSelectComponentString(MaxYfe, );
    end;
    next := tagsTV.GetNextSelected(Node, true);
    Node := next;
    inc(I);
  end;
  endMultiSelect(MinYfe);
  endMultiSelect(MaxYfe);
end;


procedure TIRDiagrEditFrm.updateTagsList;
begin

end;

end.