unit uCursorForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, ucommonMath,
  Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls, Spin, DCL_MYOWN, uSpin, opengl,
  uChartCursor;

type
  TCursorForm = class(TForm)
    CommonGB: TGroupBox;
    DrawObjFrame1: TDrawObjFrame;
    PointGB: TGroupBox;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    WidthLabel: TLabel;
    WidthSE: TFloatSpinEdit;
    procedure ColorBoxClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

  public
    function ShowModal(obj:cChartCursor):integer;
  end;

var
  CursorForm: TCursorForm;

implementation

{$R *.dfm}

procedure TCursorForm.ColorBoxClick(Sender: TObject);
begin
  if DrawObjFrame1.BackGroundColorDialog.Execute then
    tpanel(sender).color:=DrawObjFrame1.BackGroundColorDialog.Color;
end;

procedure TCursorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

function TCursorForm.ShowModal(obj:cChartCursor):integer;
var
  v:double;
begin
  DrawObjFrame1.setobj(obj);
  // устанавливаем толщину линии
  WidthSE.Value:=obj.weight;
  glGetDoublev(GL_LINE_WIDTH_GRANULARITY,@v);
  WidthSE.Increment:=v;
  //glGetDoublev(GL_LINE_WIDTH_RANGE,@v);
  //WidthSE.MaxValue:=v;
  Refresh;
  if inherited showmodal=mrok then
  begin
    DrawObjFrame1.getObj(obj);
    obj.weight:=WidthSE.Value;
  end;
end;

end.
