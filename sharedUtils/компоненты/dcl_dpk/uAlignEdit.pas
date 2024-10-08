unit uAlignEdit;
interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
 StdCtrls;

type

 TAlign = (eaLeft, eaCenter, eaRight);

 TAlignEdit = class(TEdit)
 private
   { Private-Deklarationen }
   FAlign: TAlign;
   procedure SetAlign(const Value: TAlign);
 protected
   { Protected-Deklarationen }
   procedure CreateParams(var Params: TCreateParams); override;
 public
   { Public-Deklarationen }
   constructor Create(AOwner: TComponent); override;
   destructor destroy; override;
 published
   { Published-Deklarationen }
   property Alignment: TAlign read FAlign write SetAlign default eaLeft;
 end;

implementation

constructor TAlignEdit.Create(Aowner: TComponent);
begin
 inherited Create(AOwner);
 FAlign := eaRight;
end;

destructor TAlignEdit.destroy;
begin
  inherited;
end;

procedure TAlignEdit.SetAlign(const Value: TAlign);
begin
 if FAlign <> Value then
 begin
   FAlign := Value;
   RecreateWnd;
 end;
end;

procedure TAlignEdit.CreateParams(var Params: TCreateParams);
begin
 inherited;
 case FAlign of
   eaLeft: Params.Style   := Params.Style or ES_LEFT;
   eaCenter: Params.Style := Params.Style or ES_CENTER;
   eaRight: Params.Style  := Params.Style or ES_RIGHT;
 end;
end;

end.
