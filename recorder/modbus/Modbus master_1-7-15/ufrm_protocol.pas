unit ufrm_protocol;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ExtCtrls, uFrmSimple;

type

  { Tfrm_protocol }

  Tfrm_protocol = class(TFrmSimple)
    memProtocol: TMemo;
    MenuItem1: TMenuItem;
    PopupMenuMemProt: TPopupMenu;
    Timer1: TTimer;
    procedure MenuItem1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
     constructor Create(AOwner: TComponent); reintroduce;
  end;

implementation

{$R *.lfm}

{ Tfrm_protocol }

constructor Tfrm_protocol.Create(AOwner: TComponent);
begin
  inherited;
  memProtocol.Clear;
end;

procedure Tfrm_protocol.MenuItem1Click(Sender: TObject);
begin
  memProtocol.Clear;
end;

procedure Tfrm_protocol.Timer1Timer(Sender: TObject);
begin
  memProtocol.Clear;
end;



end.

