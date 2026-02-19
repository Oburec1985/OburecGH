unit uTagInfoEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, ComCtrls, uBtnListView, ExtCtrls, Buttons,
  uComponentservises,
  uTagsListFrame, uRcCtrls;

type
  TTagInfoEditFrm = class(TForm)
    AllClientPanel: TPanel;
    TextInfoLV: TBtnListView;
    ColorDialog1: TColorDialog;
    FontDialog1: TFontDialog;
    Panel1: TPanel;
    TagLabel: TLabel;
    FontBtn: TButton;
    LabFontBtn: TButton;
    GroupBox1: TGroupBox;
    TextNumLabel: TLabel;
    TextLabel: TLabel;
    ColorLabel: TLabel;
    AddRowBtn: TSpeedButton;
    UpdateRowBtn: TSpeedButton;
    Label1: TLabel;
    TextNumIE: TIntEdit;
    ColorPan: TPanel;
    Textedit: TEdit;
    BckGndColorPan: TPanel;
    ShowLabelCB: TCheckBox;
    TagCB: TRcComboBox;
    LabelEdit: TEdit;
    Splitter1: TSplitter;
    TagsListFrame1: TTagsListFrame;
    procedure FormCreate(Sender: TObject);
    procedure FontBtnClick(Sender: TObject);
    procedure LabFontBtnClick(Sender: TObject);
    procedure AddRowBtnClick(Sender: TObject);
    procedure TextInfoLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TextInfoLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure UpdateRowBtnClick(Sender: TObject);
    procedure BckGndColorPanClick(Sender: TObject);
    procedure TagCBChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TagCBDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    m_init:boolean;
    cur:tobject;
  protected
    procedure init;
    procedure showti;
  public
    procedure EditTextInfo(sender:tobject);
  end;

var
  TagInfoEditFrm: TTagInfoEditFrm;

implementation
uses
  uTagInfoFrm;

{$R *.dfm}

{ TTagInfoEditFrm }

function Obj:TTagInfoFrm;
begin
  result:=TTagInfoFrm(TagInfoEditFrm.cur);
end;

procedure TTagInfoEditFrm.showti;
var
  frm:TTagInfoFrm;
  I: Integer;

  pair:PTagInfoPair;
  li:tlistitem;
begin
  frm:=obj;
  ShowLabelCB.Checked:=frm.ShowLabel;
  TextInfoLV.clear;
  for I := 0 to frm.count - 1 do
  begin
    pair:=frm.get(i);
    li:=TextInfoLV.items.Add;
    li.data:=pair;
    TextInfoLV.SetSubItemByColumnName('Текст',pair.str,li);
    TextInfoLV.SetSubItemByColumnName('Значение',inttostr(pair.v),li);
  end;
end;


procedure TTagInfoEditFrm.TagCBChange(Sender: TObject);
begin
  obj.m_tag.tag:=tagcb.gettag(tagcb.ItemIndex);
end;

procedure TTagInfoEditFrm.TagCBDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  TagCBChange(nil);
end;

procedure TTagInfoEditFrm.TextInfoLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  li, next:tlistitem;
  I: Integer;
  p:PTagInfoPair;
  frm:TTagInfoFrm;
begin
  if key=VK_DELETE then
  begin
    li:=TextInfoLV.Selected;
    while li<>nil do
    begin
      next:=TextInfoLV.GetNextItem(li,sdAll,[isSelected]);
      li.Delete;
      li:=next;
    end;
  end;
  frm:=obj;
  for I := 0 to TextInfoLV.items.Count - 1 do
  begin
    li:=TextInfoLV.Items[i];
    p:=li.data;
    frm.pair[i]:=p^;
  end;
  frm.count:=TextInfoLV.items.Count;
end;

procedure TTagInfoEditFrm.TextInfoLVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  p:pTagInfoPair;
begin
  if item<>nil then
  begin
    p:=item.data;
    TextNumIE.IntNum:=p.v;
    Textedit.Text:=p.str;
    colorpan.color:=p.color;
    BckGndColorPan.color:=p.bckgnd;
  end;
end;

procedure TTagInfoEditFrm.UpdateRowBtnClick(Sender: TObject);
var
  li, next:tlistitem;
  I: Integer;
  p:PTagInfoPair;
begin
  li:=TextInfoLV.Selected;
  while li<>nil do
  begin
    p:=li.data;
    p.v:=TextNumIE.IntNum;
    p.str:=Textedit.Text;
    p.color:=colorpan.color;
    p.bckgnd:=BckGndColorPan.color;

    next:=TextInfoLV.GetNextItem(li,sdAll,[isSelected]);

    TextInfoLV.SetSubItemByColumnName('Текст',p.str,li);
    TextInfoLV.SetSubItemByColumnName('Значение',inttostr(p.v),li);

    li:=next;
  end;
end;

procedure TTagInfoEditFrm.AddRowBtnClick(Sender: TObject);
var
  p:PTagInfoPair;
  li:tlistitem;
begin
  p:=obj.addTextInfo(TextNumIE.IntNum,textedit.text,colorpan.Color, BckGndColorPan.color);
  li:=TextInfoLV.items.Add;
  li.data:=p;
  TextInfoLV.SetSubItemByColumnName('Текст',p.str,li);
  TextInfoLV.SetSubItemByColumnName('Значение',inttostr(p.v),li);
end;


procedure TTagInfoEditFrm.BckGndColorPanClick(Sender: TObject);
begin
  FormStyle:=fsNormal;
  if ColorDialog1.Execute(handle) then
  begin
    tpanel(sender).color:=ColorDialog1.color;
  end;
  FormStyle:=fsStayOnTop;
end;

procedure TTagInfoEditFrm.EditTextInfo(sender: tobject);
var
  frm:TTagInfoFrm;
begin
  show;
  TagCB.updateTagsList;
  TagsListFrame1.ShowChannels;
  cur:=sender;

  frm:=obj;
  LabelEdit.Text:=obj.TextLabel;
  setComboBoxItem(frm.m_tag.tagname, tagcb);
  ShowLabelCB.Checked:=frm.ShowLabel;
  showti;
end;

procedure TTagInfoEditFrm.FontBtnClick(Sender: TObject);
begin
  if fontdialog1.Execute(handle) then
  begin
    obj.font:=fontdialog1.font;
  end;
end;

procedure TTagInfoEditFrm.LabFontBtnClick(Sender: TObject);
begin
  if fontdialog1.Execute(handle) then
  begin
    obj.LabelFont:=fontdialog1.font;
  end;
end;

procedure TTagInfoEditFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if obj<>nil then
    obj.TextLabel:=LabelEdit.Text;
end;

procedure TTagInfoEditFrm.FormCreate(Sender: TObject);
begin
  m_init:=false;
end;

procedure TTagInfoEditFrm.init;
begin
  if not m_init then
  begin
    m_init:=true;
  end;
end;


end.
