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
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure UpdateBtnClick(Sender: TObject);
    procedure AddAxisBtnClick(Sender: TObject);
    procedure TagsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
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
begin
  p:=cpage(TSyncOscFrm(m_curObj).m_Chart.activePage);
  a:=cAxis.create;
  a.name:=NameAxisEdit.Text;
  p.addaxis(a);
  a.min:=p2d(0,MinYfe.FloatNum);
  a.max:=p2d(TSyncOscFrm(m_curObj).m_length, MaxYfe.FloatNum);
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
begin
  m_curObj:=p_osc;
  osc:=TSyncOscFrm(m_curObj);
  ShowTV;
  // отображаемый интервал
  LengthFE.FloatNum:=osc.m_Length;
  TrigRG.ItemIndex:=TOscTypeToInt(osc.m_type);
  p:=cpage(osc.m_Chart.activePage);
  a:=p.activeAxis;
  MinYfe.FloatNum:=a.min.y;
  MaxYfe.FloatNum:=a.max.y;
  NameAxisEdit.text:=a.name;

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
  s:toscsignal;
  next, n: PVirtualNode;
  D, parentdata: PNodeData;
begin
  i:=0;
  j:=0;
  n := tagsTV.GetFirstSelected(true);
  while Node <> nil do
  begin
    D := tagsTV.GetNodeData(n);
    if tobject(D.Data) is caxis then
    begin
      a:=caxis(D.Data);
      SetMultiSelectComponentString(NameAxisEdit, a.name);
      SetMultiSelectComponentString(MinYfe, floattostr(a.minY));
      SetMultiSelectComponentString(MaxYfe, floattostr(a.maxY));
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
  I: Integer;
  n, next:PVirtualNode;
  d:PNodeData;
  p:cpage;
  ca:caxis;
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
      ca:=caxis(D.Data);
      pAx:=TSyncOscFrm(m_curObj).GetPAxCfg(ca.name);
      // Мин оси
      str:=GetMultiSelectComponentString(MinYfe, b);
      if checkstr(str) then
      begin
        ca.minY:=strtoFloatExt(str);
        if pax<>nil then
          pax.ymin:=ca.minY;
      end;
      // Макс оси
      str:=GetMultiSelectComponentString(MaxYfe, b);
      if checkstr(str) then
      begin
        ca.maxY:=strtoFloatExt(str);
        if pax<>nil then
          pax.ymax:=ca.maxY;
      end;
      // имя оси
      str:=GetMultiSelectComponentString(NameAxisEdit, b);
      if checkstr(str) then
      begin
        ca.name:=str;
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

  TSyncOscFrm(m_curObj).m_Length:=LengthFE.FloatNum;
  //TSyncOscFrm(m_curObj).m_TrigTag.tag:=ChannelXCB.gettag[ChannelXCB.ItemIndex];
  TSyncOscFrm(m_curObj).m_type:=IntToTOscType(TrigRG.ItemIndex);
  p:=cpage(TSyncOscFrm(m_curObj).m_Chart.activePage);
  for I := 0 to p.getAxisCount - 1 do
  begin
    ca:=p.getaxis(i);
    if i<TSyncOscFrm(m_curObj).m_ax.size then
    begin
      pAx:=paxis(TSyncOscFrm(m_curObj).m_ax.GetPByInd(i));
      pAx.name:=ca.name;
      pAx.ymin:=MinYfe.FloatNum;
      pAx.ymax:=MaxYfe.FloatNum;
    end
    else
    begin
      Ax.name:=ca.name;
      Ax.ymin:=MinYfe.FloatNum;
      Ax.ymax:=MaxYfe.FloatNum;
      TSyncOscFrm(m_curObj).m_ax.push_back(Ax);
    end;
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


procedure TEditSyncOscFrm.updateTagsList;
begin
  TagsListFrame1.ShowChannels;
  ChannelXCB.updateTagsList;
end;

end.
