unit ufrm_adr;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, uFrmSimple;

type

  { Tfrm_adr }

  Tfrm_adr = class(TFrmSimple)
    edAddress: TEdit;
    edPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure edPortKeyPress(Sender: TObject; var Key: char);
  private

  public

  end;

implementation

{$R *.lfm}

{ Tfrm_adr }

procedure Tfrm_adr.edPortKeyPress(Sender: TObject; var Key: char);
begin
   if not (key in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', #8]) then
     Key := Char(0);
end;

end.

