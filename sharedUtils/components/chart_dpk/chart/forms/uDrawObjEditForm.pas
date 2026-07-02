unit uDrawObjEditForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uDrawObj, ucommonMath,
  Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls;

type
  TDrawObjEditForm = class(TForm)
    DrawObjFrame1: TDrawObjFrame;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    function ShowModal(obj:cDrawObj):integer;
  end;

var
  DrawObjEditForm: TDrawObjEditForm;

implementation

{$R *.dfm}

procedure TDrawObjEditForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

function TDrawObjEditForm.ShowModal(obj:cDrawObj):integer;
begin
  DrawObjFrame1.setobj(obj);
  if inherited showmodal=mrok then
  begin
    DrawObjFrame1.getObj(obj);
  end;
end;

end.
