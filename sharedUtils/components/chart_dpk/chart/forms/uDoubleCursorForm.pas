unit uDoubleCursorForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  StdCtrls, uDrawObjFrame, uSpin, uDoubleCursor, opengl;

type
  TDoubleCursorForm = class(TForm)
    DrawObjFrame1: TDrawObjFrame;
    DoubleCursorProperties: TGroupBox;
    LineWidth1: TFloatSpinEdit;
    LineWidthLabel1: TLabel;
    LineWidthLabel2: TLabel;
    LineWidth2: TFloatSpinEdit;
    DoubleCheckBox: TCheckBox;
    DrawYLineCheckBox: TCheckBox;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
  private
    { Private declarations }
  public
    function showmodal(obj:cdoublecursor):integer;
  end;

var
  DoubleCursorForm: TDoubleCursorForm;

implementation

{$R *.dfm}

function TDoubleCursorForm.showmodal(obj:cdoublecursor):integer;
var
  v:double;
begin
  DrawObjFrame1.setObj(obj);
  LineWidth1.Value:=obj.weight1;
  LineWidth2.Value:=obj.weight2;
  LineWidth1.Increment:=v;
  LineWidth2.Increment:=v;
  DrawYLineCheckBox.Checked:=obj.drawYline;
  glGetDoublev(GL_LINE_WIDTH_GRANULARITY,@v);
  DoubleCheckBox.Checked:=obj.cursortype=c_DoubleCursor;
  result:=inherited showmodal;
  if result=mrok then
  begin
    DrawObjFrame1.getObj(obj);
    // пишем тип курсора
    if DoubleCheckBox.Checked then
    begin
      obj.cursortype:=c_DoubleCursor;
    end
    else
    begin
      obj.cursortype:=c_SingleCursor;
    end;
    // пишем толщину линий
    obj.weight1:=LineWidth1.Value;
    obj.weight2:=LineWidth2.Value;
    obj.drawYline:=DrawYLineCheckBox.Checked;
  end;
end;

end.
