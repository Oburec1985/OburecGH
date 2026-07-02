unit uDrawObjFrame;

interface

uses
  Windows, SysUtils, Graphics, Forms, udrawobj, uCommonMath,
  Dialogs, StdCtrls, ExtCtrls, Controls, Classes, uPageMng;

type
  TDrawObjFrame = class(TFrame)
    BackGroundColorDialog: TColorDialog;
    ColorLabel: TLabel;
    ColorBox: TPanel;
    NameLabel: TLabel;
    TypeLabel: TLabel;
    TypeImage: TImage;
    NameEdit: TEdit;
    TypeEdit: TEdit;
    VisibleCheckBox: TCheckBox;
    procedure ColorBoxClick(Sender: TObject);
  private
  public
    procedure setObj(obj:cdrawObj);
    procedure getObj(obj:cdrawobj);
  end;

implementation
uses
  uchart;
{$R *.dfm}

procedure TDrawObjFrame.setObj(obj:cdrawObj);
var
  tabs:cPageMngList;
begin
  if obj<>nil then
  begin
    nameEdit.Text:=obj.name;
    TypeEdit.Text:=obj.GetTypeString;
    // отрисовка иконки
    TypeImage.Picture:=nil;
    tabs:=cPageMngList(obj.GetParentByClassName('cPageMngList'));
    if cchart(tabs.chart).imagelist<>nil then
      cchart(tabs.chart).imagelist.GetBitmap(obj.imageindex, TypeImage.Picture.Bitmap);
    ColorBox.color:=RGBtoInt(obj.color);
    VisibleCheckBox.Checked:=obj.visible;
  end;
end;

procedure TDrawObjFrame.ColorBoxClick(Sender: TObject);
begin
  if BackGroundColorDialog.Execute then
    tpanel(sender).color:=BackGroundColorDialog.Color;
end;

procedure TDrawObjFrame.getObj(obj:cdrawobj);
begin
  if obj<>nil then
  begin
    obj.name:=nameEdit.Text;
    obj.color:=inttorgb(ColorBox.color);
    obj.visible:=VisibleCheckBox.Checked;
  end;
end;

end.
