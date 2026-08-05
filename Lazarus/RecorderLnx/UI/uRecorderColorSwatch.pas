unit uRecorderColorSwatch;

{
  Small color preview panel for trend/oscillogram line settings.
  Double-click opens the standard color dialog.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, Controls, Graphics, ExtCtrls, Dialogs;

type
  TRecorderColorSwatch = class(TPanel)
  private
    fLineColor: TColor;
    fOnColorChange: TNotifyEvent;
    procedure SetLineColor(AValue: TColor);
    procedure SwatchDblClick(Sender: TObject);
    procedure UpdateAppearance;
  public
    constructor Create(AOwner: TComponent); override;
    property LineColor: TColor read fLineColor write SetLineColor;
    property OnColorChange: TNotifyEvent read fOnColorChange write fOnColorChange;
  end;

implementation

constructor TRecorderColorSwatch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 28;
  Height := 24;
  BevelOuter := bvLowered;
  BevelWidth := 1;
  ParentBackground := False;
  Cursor := crHandPoint;
  ShowHint := True;
  Hint := 'Double-click to choose color';
  fLineColor := clBlue;
  OnDblClick := @SwatchDblClick;
  UpdateAppearance;
end;

procedure TRecorderColorSwatch.UpdateAppearance;
begin
  Color := fLineColor;
  Invalidate;
end;

procedure TRecorderColorSwatch.SetLineColor(AValue: TColor);
begin
  if fLineColor = AValue then
    Exit;
  fLineColor := AValue;
  UpdateAppearance;
  if Assigned(fOnColorChange) then
    fOnColorChange(Self);
end;

procedure TRecorderColorSwatch.SwatchDblClick(Sender: TObject);
var
  lDialog: TColorDialog;
begin
  lDialog := TColorDialog.Create(Self);
  try
    lDialog.Color := fLineColor;
    if lDialog.Execute then
      LineColor := lDialog.Color;
  finally
    lDialog.Free;
  end;
end;

end.
