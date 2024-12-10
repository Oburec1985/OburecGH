unit ulissajousCurveEdit;

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
  TLisEditFrm = class(TForm)
    BottomPanel: TPanel;
    UpdateBtn: TSpeedButton;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    MainPanel: TPanel;
    LengthLabel: TLabel;
    YAxisGB: TGroupBox;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    LengthFE: TFloatEdit;
    LineGB: TGroupBox;
    LineColor: TPanel;
    TagsGB: TGroupBox;
    TagsTV: TVTree;
    TagsListFrame1: TTagsListFrame;
    Label1: TLabel;
    Label2: TLabel;
    MinXEdit: TFloatEdit;
    MaxXEdit: TFloatEdit;
    XTagCB: TRcComboBox;
    YTagCB: TRcComboBox;
    Label4: TLabel;
    Label5: TLabel;
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TagsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure UpdateBtnClick(Sender: TObject);
  private
    m_curObj:tobject;
  private
    procedure ShowTV;
    function getSignalAxisNode(s:Tobject):pvirtualnode;
  public
    procedure updateselected;
    procedure updateTagsList;
    procedure SetEditObj(p_osc:tobject);
  public
    { Public declarations }
  end;

var
  g_LisEditFrm: TLisEditFrm;

implementation
uses
  uLissajousCurve;

{$R *.dfm}

function TLisEditFrm.getSignalAxisNode(s: Tobject): pvirtualnode;
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
          //if d.data=TLisSig(s). then
          begin
            result:=n;
            exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TLisEditFrm.SetEditObj(p_osc: tobject);
var
  lisFrm:TLissajousFrm;
  p:cpage;
  a:caxis;
  pAx:PAxis;
begin
  m_curObj:=p_osc;
  lisFrm:=TLissajousFrm(m_curObj);
  ShowTV;
  // отображаемый интервал
  LengthFE.FloatNum:=lisFrm.m_timeLen;
  p:=cpage(lisFrm.m_Chart.activePage);
  a:=p.activeAxis;
  pAx:=TLissajousFrm(m_curObj).GetPAxCfg;
  if pAx=nil then
  begin
    MinYfe.FloatNum:=a.min.y;
    MaxYfe.FloatNum:=a.max.y;
  end
  else
  begin
    MinYfe.FloatNum:=pax.ymin;
    MaxYfe.FloatNum:=pax.ymax;
    MaxXEdit.FloatNum:=pax.xmax;
    MinXEdit.FloatNum:=pax.xmin;
  end;
  showModal;
end;

procedure TLisEditFrm.ShowTV;
var
  i:integer;
  p:cpage;
  a:caxis;
  node:pvirtualnode;
  d:pnodedata;
  j: Integer;
  lisfrm:TLissajousFrm;
  s:TLisSig;
begin
  lisfrm:=TLissajousFrm(m_curObj);
  tagstv.clear;
  p:=cpage(lisfrm.m_p);
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
  for I := 0 to lisfrm.sCount - 1 do
  begin
    s:=lisfrm.GetSignal(i);
    node:=getSignalAxisNode(s);
    if node<>nil then
    begin
      node:=tagstv.AddChild(node);
      d:=tagstv.GetNodeData(node);
      d.color:=tagstv.normalcolor;
      d.caption:=s.name;
      d.Data:=s;
      // линия
      d.ImageIndex:=22;
    end;
  end;
end;

procedure TLisEditFrm.TagsTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  i,j:integer;
  a:caxis;
  pa:PAxis;
  s:TLisSig;
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
      pa:=TLissajousFrm(m_curObj).GetPAxCfg;
      if pa=nil then
      begin
        SetMultiSelectComponentString(MinYfe, floattostr(a.minY));
        SetMultiSelectComponentString(MaxYfe, floattostr(a.maxY));
      end
      else
      begin
        SetMultiSelectComponentString(MinYfe, floattostr(pa.ymin));
        SetMultiSelectComponentString(MaxYfe, floattostr(pa.ymax));
      end;
    end;
    if tobject(D.Data) is TLisSig then
    begin
      s:=TLisSig(D.Data);
      if s.m_trend<>nil then
      begin
        linecolor.Color:=rgbtoint(s.m_trend.color);
      end;
      SetMultiSelectComponentString(XTagCB,s.m_tx.tagname);
      SetMultiSelectComponentString(YTagCB,s.m_ty.tagname);
    end;
    next := tagsTV.GetNextSelected(Node, true);
    Node := next;
    inc(I);
  end;
  endMultiSelect(MinYfe);
  endMultiSelect(MaxYfe);
  endMultiSelect(XTagCB);
  endMultiSelect(YTagCB);
end;

procedure TLisEditFrm.TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pTarget: PVirtualNode;
  attMode: TVTNodeAttachMode;
  dstdata:pnodedata;
  s:TLisSig;
  a:caxis;
  n, child:pvirtualnode;
  li:TListItem;
  t:ITag;
  LisFrm:TLissajousFrm;
begin
  LisFrm:=TLissajousFrm(m_curObj);

  n:=TagsTV.GetFirst(false);
  li:=TagsListFrame1.TagsLV.Selected;
  while li<>nil do
  begin
    t:=itag(li.data);
    s:=LisFrm.createsignal;
    s.updatetrend;
    s.m_ty.settag(t);
    child:=tagsTV.AddChild(n);
    dstdata:=tagsTV.GetNodeData(child);
    dstdata.data:=s;
    dstdata.caption:=s.name;
    dstdata.ImageIndex:=22;
    dstdata.color:=tagsTV.normalcolor;
    li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
    if li=nil then
      break;
  end;
  TagsListFrame1.TagsLV.Refresh;
end;

procedure TLisEditFrm.TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
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

procedure TLisEditFrm.UpdateBtnClick(Sender: TObject);
var
  pax:PAxis;
begin
  updateselected;
  TLissajousFrm(m_curObj).m_timeLen:=LengthFE.FloatNum;
  pax:=TLissajousFrm(m_curObj).GetPAxCfg;
  pax.xmin:=MinXEdit.FloatNum;
  pax.xmax:=MaxXEdit.FloatNum;
  pax.ymin:=MinYfe.FloatNum;
  pax.ymax:=MaxYfe.FloatNum;
end;

procedure TLisEditFrm.updateselected;
var
  i: Integer;
  n:pVirtualNode;
  d:PNodeData;
begin
  n:=tagsTV.GetFirstSelected(true);
  while n<>nil do
  begin
    d:=TagsTV.GetNodeData(n);
    if tobject(d.data) is TLisSig then
    begin
      if XTagCB.ItemIndex<>-1 then
        TLisSig(d.data).m_tx.settag(XTagCB.gettag());
      if YTagCB.ItemIndex<>-1 then
        TLisSig(d.data).m_ty.settag(yTagCB.gettag());
    end;
    n:=TagsTV.GetNextSelected(n);
  end;
end;

procedure TLisEditFrm.updateTagsList;
begin
  TagsListFrame1.ShowChannels;
  XTagCB.updateTagsList;
  YTagCB.updateTagsList;
end;

end.
