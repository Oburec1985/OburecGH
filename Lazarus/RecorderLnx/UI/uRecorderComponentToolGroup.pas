unit uRecorderComponentToolGroup;

{
  Reusable drop-down group for the mnemonic component toolbar.  The group
  owns its button and popup menu; command handlers remain in the host form.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Types, Controls, Buttons, Menus, ImgList;

type
  TRecorderComponentToolGroup = class(TComponent)
  private
    fButton: TSpeedButton;
    fMenu: TPopupMenu;
    fOnBeforePopup: TNotifyEvent;
    procedure ShowMenu(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AParent: TWinControl;
      AImages: TCustomImageList; ALeft, AImageIndex: Integer;
      const AHint: string; AGroupIndex: Integer = 0;
      AAllowAllUp: Boolean = False; AOnBeforePopup: TNotifyEvent = nil);
    function AddCommand(const ACaption: string; AImageIndex: Integer;
      AOnClick: TNotifyEvent): TMenuItem;
    property Button: TSpeedButton read fButton;
    property Menu: TPopupMenu read fMenu;
  end;

implementation

constructor TRecorderComponentToolGroup.Create(AOwner: TComponent;
  AParent: TWinControl; AImages: TCustomImageList; ALeft,
  AImageIndex: Integer; const AHint: string; AGroupIndex: Integer;
  AAllowAllUp: Boolean; AOnBeforePopup: TNotifyEvent);
begin
  inherited Create(AOwner);
  fOnBeforePopup := AOnBeforePopup;
  fMenu := TPopupMenu.Create(Self);
  fMenu.Images := AImages;

  fButton := TSpeedButton.Create(Self);
  fButton.Parent := AParent;
  fButton.SetBounds(ALeft, 4, 34, 24);
  fButton.Images := AImages;
  fButton.ImageIndex := AImageIndex;
  fButton.ImageWidth := 25;
  fButton.Hint := AHint;
  fButton.ShowHint := True;
  fButton.GroupIndex := AGroupIndex;
  fButton.AllowAllUp := AAllowAllUp;
  fButton.OnClick := @ShowMenu;
end;

function TRecorderComponentToolGroup.AddCommand(const ACaption: string;
  AImageIndex: Integer; AOnClick: TNotifyEvent): TMenuItem;
begin
  Result := TMenuItem.Create(fMenu);
  Result.Caption := ACaption;
  Result.ImageIndex := AImageIndex;
  Result.OnClick := AOnClick;
  fMenu.Items.Add(Result);
end;

procedure TRecorderComponentToolGroup.ShowMenu(Sender: TObject);
var
  lPoint: TPoint;
begin
  if Assigned(fOnBeforePopup) then
    fOnBeforePopup(Self);
  lPoint := fButton.ClientToScreen(Point(0, fButton.Height));
  fMenu.PopUp(lPoint.X, lPoint.Y);
end;

end.
