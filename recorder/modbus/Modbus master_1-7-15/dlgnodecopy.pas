unit dlgNodeCopy;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TdlgNodeCopy }

  TdlgNodeCopy = class(TForm)
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    edNumber: TEdit;
    Label1: TLabel;
    procedure edNumberKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  dlg_NodeCopy: TdlgNodeCopy;

implementation

{$R *.lfm}

procedure TdlgNodeCopy.edNumberKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0', '1', '2', '3', '4', '5', '6', '7', '8' , '9', #8]) then
    Key := char(0);
end;

procedure TdlgNodeCopy.FormShow(Sender: TObject);
begin
  edNumber.Text := '1';
end;

end.

