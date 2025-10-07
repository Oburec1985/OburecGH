unit uEditPolarFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  recorder, tags, comctrls, uCommonMath, uComponentServises,
  Dialogs, uTagsListFrame, VirtualTrees, uVTServices, StdCtrls, DCL_MYOWN, Spin,
  uRcCtrls, Buttons, ExtCtrls, ImgList, uPolarGraph, uPolarGraphPage, uRCFunc;

type
  TEditPolarFrm = class(TForm)
    TagsGB: TGroupBox;
    GraphTV: TVTree;
    TagsListFrame1: TTagsListFrame;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    AddlineBtn: TSpeedButton;
    XChannelGB: TGroupBox;
    ChannelXCB: TRcComboBox;
    ChannelYGB: TGroupBox;
    ChannelYCB: TRcComboBox;
    GraphName: TEdit;
    WpPointsCB: TCheckBox;
    WpColor: TPanel;
    DrawLineCB: TCheckBox;
    ChartPropGB: TGroupBox;
    MaxXLabel: TLabel;
    MaxXfe: TFloatEdit;
    Panel2: TPanel;
    UpdateBtn: TSpeedButton;
    GroupBox2: TGroupBox;
    NameLabel: TLabel;
    NameEdit: TEdit;
    PSizeLabel: TLabel;
    PSizeEdit: TFloatEdit;
    TahoGB: TGroupBox;
    ChannelTahoCB: TRcComboBox;
    BuffLengthGB: TGroupBox;
    Pcount: TLabel;
    Label1: TLabel;
    PCountSE: TSpinEdit;
    BuffTypeRG: TRadioGroup;
    TurnCount: TSpinEdit;
    TahoThreshold: TFloatEdit;
    Label2: TLabel;
    UseTahoCB: TCheckBox;
    TahoColor: TPanel;
    BackGroundColorDialog: TColorDialog;
    DrawFPLineCB: TCheckBox;
    procedure AddlineBtnClick(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure GraphTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure BuffTypeRGClick(Sender: TObject);
    procedure WpColorClick(Sender: TObject);
  private
    curchart:TPolarGraph;
    curgraph:cTagGraph;
  private
    procedure updateGraph(g:cTagGraph);
    procedure updateopts;
    procedure showChartTags;
    procedure updateTagsList;
  public
    procedure EditChart(chart:TPolarGraph);
  end;

var
  EditPolarFrm: TEditPolarFrm;

implementation

{$R *.dfm}

{ TEditPolarFrm }

procedure TEditPolarFrm.showChartTags;
var
  i:integer;
  g:cTagGraph;
  p:cPolarGraphPage;
  node:pvirtualnode;
  d:pnodedata;
  j: Integer;
begin
  GraphTV.clear;
  p:=cPolarGraphPage(curChart.chart.activePage);
  for I := 0 to curChart.GraphCount - 1 do
  begin
    g:=curChart.getGraph(i);
    node:=GraphTV.AddChild(nil);
    d:=GraphTV.GetNodeData(node);
    d.color:=GraphTV.normalcolor;
    d.caption:=g.name;
    d.Data:=g;
    // линия
    d.ImageIndex:=22;
    //curWP:=wp;
  end;
end;

procedure TEditPolarFrm.updateGraph(g: cTagGraph);
begin
  if GraphName.text<>'' then
  begin
    g.name:=GraphName.text;
  end;
  if ChannelXCB.ItemIndex<>-1 then
  begin
    g.m_xTag.tag:=ChannelXCB.gettag(ChannelXCB.ItemIndex);
  end;
  if ChannelYCB.ItemIndex<>-1 then
  begin
    g.m_yTag.tag:=ChannelXCB.gettag(ChannelYCB.ItemIndex);
  end;
  if ChannelTahoCB.ItemIndex<>-1 then
  begin
    g.m_taho.tag:=ChannelTahoCB.gettag(ChannelTahoCB.ItemIndex);
  end;
  g.m_BuffType:=BuffTypeRG.ItemIndex;
  g.m_TahoThreshold:=TahoThreshold.FloatNum;
  g.TurnCount:=TurnCount.Value;
  g.TahoColor:=TahoColor.Color;
  g.UseTaho:=UseTahoCB.Checked;
  g.DrawFPLine:=DrawFPLineCB.Checked;

  if PCountSE.text<>'' then
    g.PCount:=PCountSE.Value;

  g.PColor:=WPColor.Color;
  g.DrawPoints:=WpPointsCB.checked;
  g.DrawLine:=DrawLineCB.Checked;
  g.init;
end;

procedure TEditPolarFrm.UpdateBtnClick(Sender: TObject);
var
  I, j: Integer;
  find:boolean;
  g:cTagGraph;
  n:PVirtualNode;
  d:pnodedata;
  err:boolean;
  ind:integer;
begin
  if curchart<>nil then
  begin
    curchart.GraphName:=NameEdit.text;
    curchart.psize:=PSizeEdit.FloatNum;
    for I := 0 to GraphTV.TotalCount - 1 do
    begin
      if I <> 0 then
        n := GraphTV.GetNext(n)
      else
        n := GraphTV.GetFirst;
      d:=GraphTV.GetNodeData(n);
      if tobject(d.data) is cTagGraph then
      begin
        if vsSelected in n.States then
        begin
          g:=cTagGraph(d.data);
          if GraphName.text<>'' then
          begin
            d.Caption:=GraphName.text;
          end;
          updateGraph(g);
        end;
      end;
    end;
  end;
  curchart.chart.redraw;
end;

procedure TEditPolarFrm.AddlineBtnClick(Sender: TObject);
Var
  g:cTagGraph;
begin
  if curChart.getGraph(GraphName.Text)=nil then
  begin
    g:=curChart.addGraph(GraphName.text);
    updateGraph(g);
    showChartTags;
  end;
end;

procedure TEditPolarFrm.BuffTypeRGClick(Sender: TObject);
begin
  if BuffTypeRG.ItemIndex=0 then
  begin
    Pcount.Caption:='Число точек';
  end
  else
  begin
    Pcount.Caption:='Максимальное число точек';
  end;
end;

procedure TEditPolarFrm.EditChart(chart: TPolarGraph);
var
  i:integer;
  page:cPolarGraphPage;
  gr:cTagGraph;
begin
  curChart:=chart;
  if chart<>nil then
  begin
    NameEdit.text:=chart.GraphName;
    PSizeEdit.FloatNum:=chart.PSize;
    updateTagsList;
    showChartTags;
    for I := 0 to chart.GraphCount - 1 do
    begin
      gr:=chart.getGraph(i);

    end;
    showmodal;
  end;
end;




procedure TEditPolarFrm.updateopts;
var
  i,j:integer;
  g:cTagGraph;
  next, Node: PVirtualNode;
  Data, parentdata: PNodeData;
begin
  i:=0;
  j:=0;
  Node := GraphTV.GetFirstSelected(true);
  while Node <> nil do
  begin
    Data := GraphTV.GetNodeData(Node);
    if tobject(Data.Data) is cTagGraph then
    begin
      g:=cTagGraph(Data.Data);

      TahoColor.Color:=g.TahoColor;
      SetMultiSelectComponentString(TahoThreshold, floattostr(g.m_TahoThreshold));
      SetMultiSelectComponentString(ChannelTahoCB, g.m_Taho.tagname);
      SetMultiSelectComponentBool(UseTahoCB, g.UseTaho);
      SetMultiSelectComponentString(TurnCount, inttostr(g.TurnCount));
      BuffTypeRG.ItemIndex:=g.m_BuffType;

      SetMultiSelectComponentString(ChannelXCB, g.m_XTag.tagname);
      SetMultiSelectComponentString(ChannelYCB, g.m_YTag.tagname);
      SetMultiSelectComponentString(GraphName, g.name);
      SetMultiSelectComponentString(PCountSE, inttostr(g.PCount));
      SetMultiSelectComponentBool(WpPointsCB, g.DrawPoints);
      SetMultiSelectComponentBool(DrawLineCB, g.DrawLine);
      WPColor.Color:=g.PColor;
    end;
    next := GraphTV.GetNextSelected(Node, true);
    Node := next;
    inc(I);
  end;
  endMultiSelect(BuffTypeRG);
  endMultiSelect(TurnCount);
  endMultiSelect(TahoThreshold);
  endMultiSelect(UseTahoCB);
  endMultiSelect(ChannelTahoCB);
  endMultiSelect(WpPointsCB);
  endMultiSelect(PCountSE);
  endMultiSelect(ChannelXCB);
  endMultiSelect(ChannelYCB);
  endMultiSelect(GraphName);
end;

procedure TEditPolarFrm.GraphTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  updateopts;
end;

procedure TEditPolarFrm.updateTagsList;
var
  I, ind: Integer;
  ir: IRecorder;
  t: iTag;
  tname: string;
  li: TListItem;
begin
  ir := getIR;
  // обновляем список каналов
  TagsListFrame1.ShowChannels;
  ChannelXCB.updateTagsList;
  ChannelYCB.updateTagsList;
  ChannelTahoCB.updateTagsList;
end;

procedure TEditPolarFrm.WpColorClick(Sender: TObject);
begin
  if BackGroundColorDialog.Execute then
    tpanel(sender).color:=BackGroundColorDialog.Color;
end;

end.
