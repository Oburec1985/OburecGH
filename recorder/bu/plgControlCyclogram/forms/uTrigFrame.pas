unit uTrigFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, ExtCtrls, VirtualTrees, uVTServices, Recorder,
  uRvclService, uRTrig, uBaseObjService, ImgList, uControlObj, uComponentServises,
  uBaseObj, tags, ComCtrls, uBtnListView, uCommonMath, activex;

type
  TTrigFrame = class(TFrame)
    TrigTV: TVTree;
    Panel1: TPanel;
    StartProgramGB: TGroupBox;
    Label4: TLabel;
    TrigChannelCB: TComboBox;
    TrigRG: TRadioGroup;
    ThresholdFE: TFloatEdit;
    TrigNameLabel: TLabel;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    ApplyBtn: TButton;
    Label1: TLabel;
    TrigNameEdit: TEdit;
    NotCB: TCheckBox;
    procedure TrigRGClick(Sender: TObject);
    procedure TrigChannelCBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TrigChannelCBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TrigTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TrigTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ApplyBtnClick(Sender: TObject);
    procedure TrigTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TrigTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
  private
    procedure ShowProperties(t:cBaseTrig);
    procedure applyTrigProps(t:cBaseTrig; node:pvirtualnode);
  public
    procedure ShowTags(ir:irecorder);
    procedure ShowTrig(t:cBaseTrig);
    function NewTrig(p:cProgramObj; startTrig:boolean):cBaseTrig;
  end;

  function getselectTrig(tv:TVTree):cbasetrig;

implementation

{$R *.dfm}

{ TTrigFrame }


function TTrigFrame.NewTrig(p:cProgramObj; startTrig:boolean): cBaseTrig;
var
  obj:tobject;
  parentnode,n:pvirtualnode;
  node:pvirtualNode;
  d:pnodedata;
  subname:string;

begin
  //parentnode:=TrigTV.GetFirstSelected(false);
  case inttotrigtype(TrigRG.ItemIndex) of
    TrPause:
    begin
      result:=cTimeTrig.create(p);
    end
    else
    begin
      result:=cRTrig.create(p);
    end;
  end;
  if startTrig then
    subname:='_Start_'
  else
    subname:='_Stop_';
  if result is crtrig then
  begin
    crtrig(result).Trigtype:=inttotrigtype(TrigRG.ItemIndex);
    crtrig(result).Threshold:=ThresholdFE.FloatNum;
    crtrig(result).setchannel(TrigChannelCB.Text);
  end;
  if trignameedit.text='' then
  begin
    trignameedit.text:=result.ClassName;
  end;
  result.name:=p.name+subname+trignameedit.text;
  if result is cTimeTrig then
  begin
    cTimeTrig(result).dueTime:=round(ThresholdFE.FloatNum*1000);
  end;
  obj:=GetSelectObjectFromVTV(TrigTV);
  if obj=nil then
  begin
    n:=TrigTV.RootNode.FirstChild;
    if n<>nil then
    begin
      d:=TrigTV.GetNodeData(n);
      obj:=cbasetrig(d.data);
    end;
  end;

  if obj<>nil then
  begin
    if obj is cbaseobj then
    begin
      cbaseobj(obj).AddChild(result);
      // добавляем узел в отображении
      n:=GetObjectNodeFromVTV(TrigTV,pointer(obj));
      if n=nil then exit;
      node:=TrigTV.AddChild(n);
      d:=TrigTV.GetNodeData(node);
      d.color:=TrigTV.normalcolor;
      d.caption:=result.caption;
      d.Data:=result;
      d.ImageIndex:=result.imageindex;
      result.ShowComponent(node, TrigTV);
    end;
    if obj is tstringlist then
    begin
      n:=GetSelectNode(TrigTV);
      parentnode:=n.Parent;
      d:=TrigTV.getnodedata(parentnode);
      if obj=cbasetrig(d.data).m_orTrigs then
      begin
        cbasetrig(d.data).addOrTrig(result);
      end;
      if obj=cbasetrig(d.data).m_andTrigs then
      begin
        cbasetrig(d.data).addAndTrig(result);
      end;
      node:=TrigTV.AddChild(n);
      d:=TrigTV.GetNodeData(node);
      d.color:=TrigTV.normalcolor;
      d.caption:=result.caption;
      d.Data:=result;
      d.ImageIndex:=result.imageindex;
      result.ShowComponent(node, TrigTV);
    end;
  end
  else
  // не выбран ни один узел
  begin
    node:=TrigTV.AddChild(TrigTV.RootNode);
    d:=TrigTV.GetNodeData(node);
    d.color:=TrigTV.normalcolor;
    d.caption:=result.caption;
    d.Data:=result;
    d.ImageIndex:=result.imageindex;
  end;
  begin
    if starttrig then
    begin
      //if p.StartTrig=nil then
      //begin
      //  p.StartTrig:=result;
      //end;
    end
    else
    begin
      //if p.StopTrig=nil then
      //begin
      //  p.StopTrig:=result;
      //end;
    end;
  end;
end;

procedure TTrigFrame.ShowTags(ir: irecorder);
begin
  tagsToCB(ir,TrigChannelCB);
end;

procedure TTrigFrame.ApplyBtnClick(Sender: TObject);
var
  t:cbasetrig;
  n:pvirtualnode;
begin
  t:=getselectTrig(TrigTV);
  n:=TrigTV.GetNodeByPointer(t);
  applyTrigProps(t, n);
end;

procedure TTrigFrame.applyTrigProps(t:cBaseTrig; node:pvirtualnode);
var
  d:pnodedata;
begin
  d:=TrigTV.getnodedata(node);
  d.caption:=TrigNameEdit.Text;
  t.Trigtype:=inttotrigtype(TrigRG.ItemIndex);

  if t is crtrig then
  begin
    crtrig(t).setchannel(TrigChannelCB.text);
    crtrig(t).Threshold:=ThresholdFE.FloatNum;
  end;
  t.name:=TrigNameEdit.Text;
  if t is cTimeTrig then
  begin
    cTimeTrig(t).dueTime:=round(ThresholdFE.FloatNum)*1000;
  end;
  t.Inverse:=NotCB.Checked;
end;

procedure TTrigFrame.ShowProperties(t:cBaseTrig);
begin
  if t=nil then exit;
  TrigNameEdit.Text:=t.name;
  TrigRG.ItemIndex:=trigtypetoint(t.Trigtype);
  if t is crtrig then
  begin
    setComboBoxItem(crtrig(t).channame,TrigChannelCB);
    ThresholdFE.FloatNum:=crtrig(t).Threshold;
  end;
  if t is cTimetrig then
  begin
    TrigChannelCB.text:='';
    ThresholdFE.FloatNum:=cTimetrig(t).dueTime/1000;
  end;
end;

procedure TTrigFrame.ShowTrig(t: cBaseTrig);
begin
  showInVTreeView(TrigTV, t, imagelist_16);
  ShowProperties(t);
end;

procedure TTrigFrame.TrigChannelCBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  t:itag;
  s:string;
  li:tlistitem;
begin
  li:=tbtnlistview(source).selected;//tbtnlistview(source).GetItemAt(x,y);
  t:=itag(li.data);
  s:=t.getname;
  setComboBoxItem(s,tcombobox(sender));
end;

procedure TTrigFrame.TrigChannelCBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  li:tlistitem;
  v:cardinal;
begin
  Accept:=false;
  if source is tBtnListView then
  begin
    li:=tBtnListView(source).selected;
    if li=nil then exit;
    if li.Data <>nil then
    begin
      if GetObjectClass(li.Data) = nil then
      begin
        if tListitem(source).Data <>nil then
        begin
          Accept:= Supports(itag(li.Data),IID_ITAG);
        end;
      end;
    end;
  end;
end;

procedure TTrigFrame.TrigRGClick(Sender: TObject);
begin
  case inttotrigtype(trigrg.itemindex) of
    TrPause:
    begin
      TrigNameLabel.Visible:=false;
      TrigChannelCB.Visible:=false;
    end
    else
    begin
      TrigNameLabel.Visible:=true;
      TrigChannelCB.Visible:=true;
    end;
  end;
end;

function getselectTrig(tv:TVTree):cbasetrig;
var
  n,parentnode:pvirtualnode;
  d:pnodedata;
begin
  result:=nil;
  n:=GetSelectNode(tv);
  if n=nil then
    exit;
  d:=tv.getnodedata(n);
  if tobject(d.data) is cbaseobj then
  begin
    result:=cbasetrig(d.data);
  end
  else
  begin
    parentnode:=n.Parent;
    d:=tv.getnodedata(parentnode);
    result:=cbasetrig(d.data);
  end;
end;

procedure TTrigFrame.TrigTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  t:cbasetrig;

begin
  if node<>nil then
  begin
    t:=cbasetrig(GetSelectObjectFromVTV(tvtree(sender)));
    ShowProperties(t);
  end;
end;

procedure TTrigFrame.TrigTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pSource, pTarget: PVirtualNode;
  attMode: TVTNodeAttachMode;
  dstdata,srcdata:pnodedata;
  n:pvirtualnode;
  d:PNodeData;
  I: Integer;
  t, srcT:cbasetrig;
begin
  pSource := TVirtualStringTree(Source).FocusedNode;
  pTarget := Sender.DropTargetNode;
  srcdata:=trigtv.GetNodeData(pSource);
  if tobject(srcdata.data) is cbasetrig then
  begin
    srcT:=cbasetrig(srcdata.data);
    pSource.Parent:=pTarget;
  end
  else
  begin
    if tobject(srcdata.data) is tstringlist then
    begin
      pSource:=pSource.Parent;
      srcdata:=trigtv.GetNodeData(pSource);
      srcT:=cbasetrig(srcdata.data);
      pSource.Parent:=pTarget;
    end;
  end;
  dstdata:=trigtv.GetNodeData(pTarget);
  for I := 0 to g_conmng.trigCount - 1 do
  begin
    t:=g_conmng.getTrig(i);
    if t.m_andTrigs=dstdata.data then
    begin
      t.addAndTrig(srcT);
      exit;
    end;
    if t.m_orTrigs=dstdata.data then
    begin
      t.addOrTrig(srcT);
      exit;
    end;
  end;
end;

procedure TTrigFrame.TrigTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
var
  pSource, pTarget:PVirtualNode;
  dstdata,srcdata:pnodedata;
begin
  Accept := false;
  if Source = TrigTV then
  begin
    pSource := TVirtualStringTree(Source).FocusedNode;
    pTarget := Sender.DropTargetNode;
    dstdata:=Sender.GetNodeData(pTarget);
    if tobject(dstdata.data) is tstringlist then
    begin
      Accept:=true;
    end;
  end;
end;

procedure TTrigFrame.TrigTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  n,parentnode:pvirtualnode;
  d:pnodedata;
begin
  if key=VK_DELETE then
  begin
    n:=GetSelectNode(TrigTV);
    if n=nil then
      exit;
    d:=TrigTV.getnodedata(n);
    if tobject(d.data) is cbaseobj then
    begin
      cbaseobj(d.data).Destroy;
      TrigTV.DeleteNode(n);
    end
    else
    begin
      parentnode:=n.Parent;
      d:=TrigTV.getnodedata(parentnode);
      cbaseobj(d.data).destroy;
      TrigTV.DeleteNode(parentnode);
    end;
  end;
end;

end.
