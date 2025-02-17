unit uEditGraphFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ExtCtrls, StdCtrls, VirtualTrees, uVTServices,
  ImgList,activex, uAxis, ComCtrls,tags;

type
  TEditGraphFrm = class(TForm)
    TagsListFrame1: TTagsListFrame;
    Panel1: TPanel;
    OkBtn: TButton;
    TagsTV: TVTree;
    ImageList_16: TImageList;
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
  private

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
   TagsListFrame1.ShowChannels;
  //TGraphFrm(f).
end;

procedure TEditGraphFrm.TagsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  n, new: PVirtualNode;
  d, sd:pnodedata;
  a:caxis;
  t:itag;
  li:tlistitem;
begin
  // создаем узел при необходимости
  n := Sender.DropTargetNode;
  if n<>nil then
  begin
    d:=TagsTV.GetNodeData(n);
    if not (tobject(d.data) is caxis) then
    begin
      n:=n.Parent;
      d:=TagsTV.GetNodeData(n);
    end;
  end
  else
  begin
    //n:=AddAxis;
    d:=TagsTV.getNodeData(n);
  end;
  a:=caxis(d.data);
  // добавляем к узлу новые теги
  if source=TagsListFrame1.TagsLV then
  begin
    li:=TagsListFrame1.TagsLV.Selected;
    t:=itag(li.data);
    while li<>nil do
    begin
      //a:=a.addtag(t, newAlarm);
      //if newAlarm then
      begin
        li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
        if li<>nil then
          t:=itag(li.data);
      end;
      //else
      begin
        li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
        if li<>nil then
          t:=itag(li.data);
      end;
    end;
  end;
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
