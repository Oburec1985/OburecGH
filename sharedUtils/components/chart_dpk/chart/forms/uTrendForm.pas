unit uTrendForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uTrend, ucommonMath,
  Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls, Spin, DCL_MYOWN, uSpin, opengl,
  uTrendFrame, uBasicTrend;

type
  TTrendForm = class(TForm)
    CommonGB: TGroupBox;
    DrawObjFrame1: TDrawObjFrame;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    TrendFrame1: TTrendFrame;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

  public
    function ShowModal(obj:cbasictrend):integer;
  end;

var
  TrendForm: TTrendForm;

implementation

{$R *.dfm}

procedure TTrendForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

function TTrendForm.ShowModal(obj:cbasictrend):integer;
begin
  DrawObjFrame1.setobj(obj);
  TrendFrame1.SetObj(obj);
  if inherited showmodal=mrok then
  begin
    DrawObjFrame1.getObj(obj);
    obj:=ctrend(TrendFrame1.GetObj);
  end;
end;

end.
