unit uGistForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uGistogram, uMarkers, ucommonMath,
  Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls, Spin, uGistFrame;

type
  TGistForm = class(TForm)
    CommonGB: TGroupBox;
    DrawObjFrame1: TDrawObjFrame;
    PointGB: TGroupBox;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    GistFrame1: TGistFrame;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

  public
    function ShowModal(obj:cGistogram):integer;
  end;

var
  GistForm: TGistForm;

implementation

{$R *.dfm}

procedure TGistForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

function TGistForm.ShowModal(obj:cGistogram):integer;
begin
  DrawObjFrame1.setobj(obj);
  GistFrame1.SetObj(obj);
  if inherited showmodal=mrok then
  begin
    DrawObjFrame1.getObj(obj);
    obj:=GistFrame1.GetObj;
  end;
end;

end.
