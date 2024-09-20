unit uSyncOscillogramEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, Buttons, VirtualTrees, uVTServices, ExtCtrls,
  uControlEditFrame, uRecorderEvents, uControlObj,
  uComponentServises, upage,
  pluginClass, ImgList, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService, uCommonTypes, uCommonMath,
  tags, recorder, uBaseObjService, uModesTabsForm, activex,
  uRcCtrls, uEventTypes, uSpin, Spin,
  uBtnListView,
  uBuffTrend1d, udrawobj,
  ComCtrls,
  uTagsListFrame,
  uaxis;

type
  TEditSyncOscFrm = class(TForm)
    TagsListFrame1: TTagsListFrame;
    BottomPanel: TPanel;
    TagsGB: TGroupBox;
    TagsTV: TVTree;
    MainPanel: TPanel;
    YAxisGB: TGroupBox;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    AddAxisBtn: TSpeedButton;
    NameAxisLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    NameAxisEdit: TEdit;
    LengthLabel: TLabel;
    LengthFE: TFloatEdit;
    TrigRG: TRadioGroup;
    UpdateBtn: TSpeedButton;
    ChannelXCB: TRcComboBox;
    TrigLabel: TLabel;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    LegendCB: TCheckBox;
    LineGB: TGroupBox;
    Label3: TLabel;
    LineNameEdit: TEdit;
    LineColor: TPanel;
    Label1: TLabel;
    PhaseE: TFloatEdit;
    ThresholdFE: TFloatEdit;
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure UpdateBtnClick(Sender: TObject);
    procedure AddAxisBtnClick(Sender: TObject);
    procedure TagsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TagsTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    m_curObj:tobject;
  private
    procedure ShowTV;
    function getSignalAxisNode(s:Tobject):pvirtualnode;
  public
    procedure updateTagsList;
    procedure SetEditObj(p_osc:tobject);
  end;



var
  g_EditSyncOscFrm: TEditSyncOscFrm;

implementation
uses
  uSyncOscillogram;

{$R *.dfm}

{ TEditSyncOscFrm }

procedure TEditSyncOscFrm.AddAxisBtnClick(Sender: TObject);
var
  p:cpage;
  a:caxis;
  axcfg:TAxis;
begin
  p:=cpage(TSyncOscFrm(m_curObj).m_Chart.activePage);
  a:=cAxis.create;
  a.name:=NameAxisEdit.Text;
  p.addaxis(a);
  a.min:=p2d(0,MinYfe.FloatNum);
  a.max:=p2d(TSyncOscFrm(m_curObj).m_length, MaxYfe.FloatNum);

  axCfg.name:=NameAxisEdit.Text;
  axCfg.ymin:=MinYfe.FloatNum;
  axCfg.ymax:=MaxYfe.FloatNum;
  TSyncOscFrm(m_curObj).m_ax.push_back(axcfg);
  ShowTV;
end;

function TEditSyncOscFrm.getSignalAxisNode(s: Tobject): pvirtualnode;
var
  i:integer;
  n:pvirtualnode;
  d:pnodedata;
begin
  result:=nil;
  for I := 0 to tagsTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := tagsTV.GetNext(n)
    else
      n := tagsTV.GetFirst;
    d:=tagsTV.GetNodeData(n);
    if d<>nil then
    begin
      if d.data<>nil then
      begin
        if tobject(d.data) is caxis then
        begin
          if d.data=TOscSignal(s).ax then
          begin
            result:=n;
            exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TEditSyncOscFrm.SetEditObj(p_osc: tobject);
var
  osc:TSyncOscFrm;
  p:cpage;
  a:caxis;
  pAx:PAxis;
begin
  m_curObj:=p_osc;
  osc:=TSyncOscFrm(m_curObj);
  ShowTV;
  // отображаемый интервал
  LengthFE.FloatNum:=osc.m_Length;
  setComboBoxItem(osc.m_TrigTag.tagname,ChannelXCB);
  PhaseE.FloatNum:=osc.m_Phase0;
  ThresholdFE.FloatNum:=osc.m_Threshold;
  TrigRG.ItemIndex:=TOscTypeToInt(osc.m_type);
  p:=cpage(osc.m_Chart.activePage);
  a:=p.activeAxis;
  pAx:=TSyncOscFrm(m_curObj).GetPAxCfg(a.name);
  if pAx=nil then
  begin
    MinYfe.FloatNum:=a.min.y;
    MaxYfe.FloatNum:=a.max.y;
    NameAxisEdit.text:=a.name;
  end
  else
  begin
    MinYfe.FloatNum:=pax.ymin;
    MaxYfe.FloatNum:=pax.ymax;
    NameAxisEdit.text:=a.name;
  end;
  showModal;
end;



procedure TEditSyncOscFrm.ShowTV;
var
  i:integer;
  p:cpage;
  a:caxis;
  node:pvirtualnode;
  d:pnodedata;
  j: Integer;
  osc:TSyncOscFrm;
  s:TOscSignal;
begin
  osc:=TSyncOscFrm(m_curObj);
  tagstv.clear;
  p:=cpage(osc.m_Chart.activePage);
  for I := 0 to p.getAxisCount - 1 do
  begin
    a:=p.getaxis(i);
    node:=tagstv.AddChild(nil);
    d:=tagstv.GetNodeData(node);
    d.color:=tagstv.normalcolor;
    d.caption:=a.caption;
    d.Data:=a;
    d.ImageIndex:=4;
  end;
  for I := 0 to osc.m_signals.Count - 1 do
  begin
    s:=osc.GetSignal(i);
    node:=getSignalAxisNode(s);
    if node<>nil then
    begin
      node:=tagstv.AddChild(node);
      d:=tagstv.GetNodeData(node);
      d.color:=tagstv.normalcolor;
      d.caption:=s.t.tagname;
      d.Data:=s;
      // линия
      d.ImageIndex:=22;
    end;
  end;
end;

procedure TEditSyncOscFrm.TagsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  i,j:integer;
  a:caxis;
  pa:PAxis;
  s:toscsignal;
  next: PVirtualNode;
  D, parentdata: PNodeData;
begin
  i:=0;
  j:=0;
  Node := tagsTV.GetFirstSelected(true);
  while Node <> nil do
  begin
    D := tagsTV.GetNodeData(node);
    if tobject(D.Data) is caxis then
    begin
      a:=caxis(D.Data);
      pa:=TSyncOscFrm(m_curObj).GetPAxCfg(a.name);
      if pa=nil then
      begin
        SetMultiSelectComponentString(NameAxisEdit, a.name);
        SetMultiSelectComponentString(MinYfe, floattostr(a.minY));
        SetMultiSelectComponentString(MaxYfe, floattostr(a.maxY));
      end
      else
      begin
        SetMultiSelectComponentString(NameAxisEdit, a.name);
        SetMultiSelectComponentString(MinYfe, floattostr(pa.ymin));
        SetMultiSelectComponentString(MaxYfe, floattostr(pa.ymax));
      end;
    end;
    if tobject(D.Data) is TOscSignal then
    begin
      s:=TOscSignal(D.Data);
      SetMultiSelectComponentString(LineNameEdit, s.t.tagname);
      linecolor.Color:=rgbtoint(s.line.color);
    end;
    next := tagsTV.GetNextSelected(Node, true);
    Node := next;
    inc(I);
  end;
  endMultiSelect(NameAxisEdit);
  endMultiSelect(MinYfe);
  endMultiSelect(MaxYfe);
  endMultiSelect(LineNameEdit);
end;


procedure TEditSyncOscFrm.UpdateBtnClick(Sender: TObject);
var
  I,j: Integer;
  n, next:PVirtualNode;
  d:PNodeData;
  p:cpage;
  a:caxis;
  obj:cdrawobj;
  line:cBuffTrend1d;
  pAx:paxis;
  Ax:TAxis;
  b:boolean;
  str:string;
begin
  n := tagsTV.GetFirstSelected(true);
  while n <> nil do
  begin
    D := tagsTV.GetNodeData(n);
    if tobject(D.Data) is caxis then
    begin
      a:=caxis(D.Data);
      pAx:=TSyncOscFrm(m_curObj).GetPAxCfg(a.name);
      // Мин оси
      str:=GetMultiSelectComponentString(MinYfe, b);
      if checkstr(str) then
      begin
        a.minY:=strtoFloatExt(str);
        if pax<>nil then
          pax.ymin:=a.minY;
      end;
      // Макс оси
      str:=GetMultiSelectComponentString(MaxYfe, b);
      if checkstr(str) then
      begin
        a.maxY:=strtoFloatExt(str);
        if pax<>nil then
          pax.ymax:=a.maxY;
      end;
      // имя оси
      str:=GetMultiSelectComponentString(NameAxisEdit, b);
      if checkstr(str) then
      begin
        a.name:=str;
        if pax<>nil then
          pAx.name:=str;
      end;
    end;
    if tobject(D.Data) is TOscSignal then
    begin

    end;
    next := tagsTV.GetNextSelected(N, true);
    N := next;
    inc(I);
  end;
  TSyncOscFrm(m_curObj).m_Chart.showLegend:=LegendCB.checked;
  p:=cpage(TSyncOscFrm(m_curObj).m_Chart.activePage);
  for I := 0 to p.getAxisCount-1 do
  begin
    a:=p.getaxis(i);
    for j := 0 to a.ChildCount - 1 do
    begin
      obj:=cdrawobj(a.getChild(j));
      if obj is cBuffTrend1d then
      begin
        TSyncOscFrm(m_curObj).m_Chart.legend.doAddObjects(obj);
      end;
    end;
  end;
  TSyncOscFrm(m_curObj).m_Chart.activeTab.Alignpages(1);
  TSyncOscFrm(m_curObj).m_Length:=LengthFE.FloatNum;
  //TSyncOscFrm(m_curObj).m_TrigTag.tag:=ChannelXCB.gettag[ChannelXCB.ItemIndex];
  TSyncOscFrm(m_curObj).m_type:=IntToTOscType(TrigRG.ItemIndex);
  TSyncOscFrm(m_curObj).m_Phase0:=PhaseE.FloatNum;
  TSyncOscFrm(m_curObj).m_Threshold:=ThresholdFE.FloatNum;
  if ChannelXCB.ItemIndex<>-1 then
  begin
    TSyncOscFrm(m_curObj).m_TrigTag.tag:=ChannelXCB.gettag(ChannelXCB.ItemIndex);
  end;
end;

procedure TEditSyncOscFrm.TagsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pTarget: PVirtualNode;
  attMode: TVTNodeAttachMode;
  dstdata:pnodedata;
  s:TOscSignal;
  a:caxis;
  n, child:pvirtualnode;
  li:TListItem;
  t:ITag;
  osc:TSyncOscFrm;
begin
  osc:=TSyncOscFrm(m_curObj);
  pTarget := Sender.DropTargetNode;
  if pTarget=nil then
  begin
    pTarget:=tagsTV.RootNode.FirstChild;
    dstdata:=tagsTV.GetNodeData(pTarget);
    a:=cpage(osc.m_Chart.activePage).activeAxis;
    dstdata.data:=a;
    n:=pTarget;
  end
  else
  begin
    dstdata:=tagsTV.GetNodeData(pTarget);
    if tobject(dstdata.data) is ctag then
    begin
      n:=pTarget.Parent;
      dstdata:=tagsTV.GetNodeData(n);
      a:=caxis(dstdata.data);
    end
    else
    begin
      if tobject(dstdata.data) is caxis then
      begin
        n:=pTarget;
        a:=caxis(dstdata.data);
      end;
    end;
  end;

  li:=TagsListFrame1.TagsLV.Selected;
  while li<>nil do
  begin
    t:=itag(li.data);
    s:=osc.CreateSignal(a,t);
    child:=tagsTV.AddChild(n);
    dstdata:=tagsTV.GetNodeData(child);
    dstdata.data:=s;
    dstdata.caption:=s.t.tagname;
    dstdata.ImageIndex:=22;
    dstdata.color:=tagsTV.normalcolor;
    li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
    if li=nil then
      break;
  end;
  TagsListFrame1.TagsLV.Refresh;
end;

procedure TEditSyncOscFrm.TagsTVDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
var
  pSource, pTarget:PVirtualNode;
  dstdata,srcdata:pnodedata;
  a:caxis;
begin
  Accept := false;
  if Source is TBtnlistView then
  begin
    Accept := true;
  end;
end;


procedure TEditSyncOscFrm.TagsTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  next,n, Node: PVirtualNode;
  Data, parentdata: PNodeData;
  I: Integer;
  p:cpage;
  a:caxis;
  del:boolean;
begin
  if Key = VK_DELETE then
  begin
    Node := TagsTV.GetFirstSelected(true);
    while Node <> nil do
    begin
      del:=false;
      Data := TagsTV.GetNodeData(Node);
      if tobject(data.data) is TOscSignal then
      begin
        del:=true;
        TOscSignal(data.data).Destroy;
      end;
      if tobject(data.data) is cAxis then
      begin
        p:=cpage(TSyncOscFrm(m_curObj).m_Chart.activePage);
        if p.getAxisCount=1 then
        begin
          a:=p.activeAxis;
        end
        else
        begin
          del:=true;
          a:=caxis(data.data);
          // удаляем потомков
          next:=node.FirstChild;
          while (next<>nil) do
          begin
            n:=next;
            Data := TagsTV.GetNodeData(n);
            TOscSignal(data.data).Destroy;
            next:=TagsTV.GetNextSibling(n);
          end;
          i:=TSyncOscFrm(m_curObj).GetAxCfgInd(a.name);
          a.destroy;
          TSyncOscFrm(m_curObj).m_ax.Delete(i);
        end;
      end;
      next := TagsTV.GetNextSelected(Node, false);
      if next = nil then
      begin
        if Data.Data<>nil then
        begin

        end;
      end;
      if del then
      begin
        TagsTV.CancelEditNode;
        TagsTV.DeleteNode(node);
      end;
      Node := next;
      inc(I);
    end;
  end;
end;

procedure TEditSyncOscFrm.updateTagsList;
begin
  TagsListFrame1.ShowChannels;
  ChannelXCB.updateTagsList;
end;

end.
