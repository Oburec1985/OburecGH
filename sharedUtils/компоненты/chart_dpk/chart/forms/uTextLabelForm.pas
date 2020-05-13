unit uTextLabelForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uPage, ucommonMath,
  Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls, uTextLabel;

type
  TTextLabelForm = class(TForm)
    DrawObjFrame1: TDrawObjFrame;
    TxtGB: TGroupBox;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    ColorBgndLabel: TLabel;
    ColorBgndBox: TPanel;
    CaptionEdit: TEdit;
    CaptionLabel: TLabel;
    TextBgndCB: TCheckBox;
    BorderCb: TCheckBox;
    BorderColorLabel: TLabel;
    BorderColorBox: TPanel;
    procedure ColorBgndBoxDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
    function ShowModal(obj:cTextLabel):integer;
  end;

var
  TextLabelForm: TTextLabelForm;

implementation

{$R *.dfm}

procedure TTextLabelForm.ColorBgndBoxDblClick(Sender: TObject);
begin
  if DrawObjFrame1.BackGroundColorDialog.Execute then
    tpanel(sender).color:=DrawObjFrame1.BackGroundColorDialog.Color;
end;

procedure TTextLabelForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

function TTextLabelForm.ShowModal(obj:cTextLabel):integer;
begin
  DrawObjFrame1.setobj(obj);
  ColorBgndBox.color:=rgbtoint(obj.m_bckGndColor);
  CaptionEdit.Text:=obj.text;
  BorderCb.Checked:=obj.DrawBorder;
  TextBgndCB.Checked:=not obj.TransperentBckGnd;
  BorderColorBox.Color:=rgbtoint(obj.m_borderColor);
  Refresh;
  result:=inherited showmodal;
  if result =mrok then
  begin
    DrawObjFrame1.getObj(obj);
    obj.DrawBorder:=BorderCb.Checked;
    obj.TransperentBckGnd:=not TextBgndCB.Checked;
    obj.m_bckGndColor:=inttorgb(ColorBgndBox.color);
    obj.m_borderColor:=inttorgb(BorderColorBox.color);
    obj.Text:=CaptionEdit.Text;
  end;
end;

end.
