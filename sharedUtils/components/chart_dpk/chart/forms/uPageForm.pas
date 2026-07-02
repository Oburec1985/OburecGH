unit uPageForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uPage, ucommonMath,
  Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls;

type
  TPageForm = class(TForm)
    DrawObjFrame1: TDrawObjFrame;
    PageGB: TGroupBox;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    ColorLabel: TLabel;
    ColorBox: TPanel;
    CaptionEdit: TEdit;
    CaptionLabel: TLabel;
    procedure ColorBoxDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    function ShowModal(obj:cpage):integer;
  end;

var
  PageForm: TPageForm;

implementation

{$R *.dfm}

procedure TPageForm.ColorBoxDblClick(Sender: TObject);
begin
  if DrawObjFrame1.BackGroundColorDialog.Execute then
    tpanel(sender).color:=DrawObjFrame1.BackGroundColorDialog.Color;
end;

procedure TPageForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

function TPageForm.ShowModal(obj:cpage):integer;
begin
  DrawObjFrame1.setobj(obj);
  ColorBox.color:=rgbtoint(obj.GridColor);
  CaptionEdit.Text:=obj.Caption;  
  Refresh;
  if inherited showmodal=mrok then
  begin
    DrawObjFrame1.getObj(obj);
    obj.GridColor:=inttorgb(ColorBox.color);
    obj.Caption:=CaptionEdit.Text;
  end;
end;

end.
