unit uEditGraphFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ExtCtrls, StdCtrls, VirtualTrees, uVTServices,
  ImgList,activex,
  uAxis, upage, urcfunc,
  ComCtrls,tags;

type
  TEditGraphFrm = class(TForm)
    TagsListFrame1: TTagsListFrame;
    Panel1: TPanel;
    OkBtn: TButton;
    TagsTV: TVTree;
    ImageList_16: TImageList;
    NewAxBtn: TButton;
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure NewAxBtnClick(Sender: TObject);
  private
    m_f:tform;
  private
    procedure showTV;
    function getSignalAxisNode(s:Tobject):pvirtualnode;
  public
    procedure editFrm(f:Tform);
  end;

var
  EditGraphFrm: TEditGraphFrm;

implementation
uses
  uGrapfForm;

{$R *.dfm}

{ TEditGraphFrm }

procedure TEditGraphFrm.editFrm(f: Tform);
begin
  m_f:=f;
  TagsListFrame1.ShowChannels;
  showTV;
  //TGraphFrm(f).
end;

function TEditGraphFrm.getSignalAxisNode(s: Tobject): pvirtualnode;
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
          if d.data=cGraphTag(s).m_line.parent then
          begin
            result:=n;
            exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TEditGraphFrm.NewAxBtnClick(Sender: TObject);
var
  s:cGraphTag;
  n, new, sig_n:pvirtualnode;
  d, axd, sig_d:pnodedata;
  a:caxis;
begin
  n:=TagsTV.GetFirstSelected(false);
  if n<>nil then
  begin
    d:=TagsTV.GetNodeData(n);
    if tobject(d.data) is cGraphTag then
    begin
      new:=tagsTV.AddChild(nil);
      a:=cpage(TGraphFrm(m_f).cChart1.activePage).Newaxis;
      TGraphFrm(m_f).addaxis(a);
      axd:=tagsTV.GetNodeData(new);
      axd.data:=a;
      axd.color:=tagstv.normalcolor;
      axd.Caption:=a.name;
      axd.ImageIndex:=4; // ось

      sig_n:=tagsTV.AddChild(new);
      sig_d:=tagsTV.GetNodeData(sig_n);
      sig_d.data:=tobject(d.data);
      sig_d.color:=tagstv.normalcolor;
      sig_d.caption:=cGraphTag(d.data).m_t.tagname;
      sig_d.ImageIndex:=22;// линия
      cGraphTag(d.data).SetAxis(a);
    end;
    TagsTV.DeleteNode(n,false);
  end;
end;

procedure TEditGraphFrm.showTV;
var
  i:integer;
  p:cpage;
  a:caxis;
  node:pvirtualnode;
  d:pnodedata;
  j: Integer;
  f:TGraphFrm;
  s:cGraphTag;
begin
  f:=TGraphFrm(m_f);
  tagstv.clear;
  p:=cpage(f.cChart1.activePage);
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
  for I := 0 to f.m_slist.Count - 1 do
  begin
    s:=f.GetSignal(i);
    node:=getSignalAxisNode(s);
    if node<>nil then
    begin
      node:=tagstv.AddChild(node);
      d:=tagstv.GetNodeData(node);
      d.color:=tagstv.normalcolor;
      d.caption:=s.m_t.tagname;
      d.Data:=s;
      // линия
      d.ImageIndex:=22;
    end;
  end;
end;

procedure TEditGraphFrm.TagsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pTarget: PVirtualNode;
  attMode: TVTNodeAttachMode;
  dstdata:pnodedata;
  s:cGraphTag;
  a:caxis;
  n, child:pvirtualnode;
  li:TListItem;
  t:ITag;
  f:TGraphFrm;
begin
  f:=TGraphFrm(m_f);
  pTarget := Sender.DropTargetNode;
  if pTarget=nil then
  begin
    pTarget:=tagsTV.RootNode.FirstChild;
    dstdata:=tagsTV.GetNodeData(pTarget);
    a:=cpage(f.cChart1.activePage).activeAxis;
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
      end
      else
      begin
        if tobject(dstdata.data) is cGraphTag then
        begin
          n:=pTarget.Parent;
          a:=caxis(cGraphTag(dstdata.data).m_line.parent);
        end;
      end;
    end;
  end;

  li:=TagsListFrame1.TagsLV.Selected;
  while li<>nil do
  begin
    t:=itag(li.data);
    s:=f.addSignal(t.GetName,a);
    child:=tagsTV.AddChild(n);
    dstdata:=tagsTV.GetNodeData(child);
    dstdata.data:=s;
    dstdata.caption:=s.m_t.tagname;
    dstdata.ImageIndex:=22;
    dstdata.color:=tagsTV.normalcolor;
    li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
    if li=nil then
      break;
  end;
  TagsListFrame1.TagsLV.Refresh;
end;

procedure TEditGraphFrm.TagsTVDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := false;
  if Source = TagsListFrame1.TagsLV then
    Accept := true;
end;

end.
