unit uRecorderComponentToolGroup;

{
  Reusable drop-down group for the mnemonic component toolbar.  The group
  owns its button and popup menu; command handlers remain in the host form.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Types, Controls, Buttons, Menus, ImgList,
  uRecorderFormModel;

type
  TRecorderPaletteIconIndexEvent = function(const AIconId: string): Integer of object;
  TRecorderPaletteFactoryEvent = procedure(AFactory: TRecorderComponentFactoryBase;
    AButton: TSpeedButton) of object;

  TRecorderPaletteGroup = class
  public
    Id: string;
    Caption: string;
    Hint: string;
    IconId: string;
  end;

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

  { Builds the component part of a toolbar directly from factory metadata.
    The host supplies only icon lookup and the action performed after choosing
    a factory. }
  TRecorderComponentPalette = class(TComponent)
  private
    fRegistry: TRecorderComponentFactory;
    fParent: TWinControl;
    fImages: TCustomImageList;
    fButtons: TList;
    fGroups: TList;
    fOnIconIndex: TRecorderPaletteIconIndexEvent;
    fOnFactorySelected: TRecorderPaletteFactoryEvent;
    fButtonTop: Integer;
    fButtonWidth: Integer;
    fButtonHeight: Integer;
    fSpacing: Integer;
    fGroupIndex: Integer;
    fAllowAllUp: Boolean;
    function FindGroup(const AId: string): TRecorderPaletteGroup;
    function IconIndex(const AIconId: string): Integer;
    function NewButton(ALeft: Integer; const AHint, AIconId: string): TSpeedButton;
    procedure FactoryClick(Sender: TObject);
    procedure GroupItemClick(Sender: TObject);
    procedure GroupOpening(Sender: TObject);
    procedure ShowGroupMenu(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; ARegistry: TRecorderComponentFactory;
      AParent: TWinControl; AImages: TCustomImageList;
      AOnIconIndex: TRecorderPaletteIconIndexEvent;
      AOnFactorySelected: TRecorderPaletteFactoryEvent); reintroduce;
    destructor Destroy; override;
    procedure ConfigureGroup(const AId, ACaption, AHint, AIconId: string);
    function Build(AStartLeft: Integer): Integer;
    procedure ResetSelection;
    property ButtonTop: Integer read fButtonTop write fButtonTop;
    property ButtonWidth: Integer read fButtonWidth write fButtonWidth;
    property ButtonHeight: Integer read fButtonHeight write fButtonHeight;
    property Spacing: Integer read fSpacing write fSpacing;
    property GroupIndex: Integer read fGroupIndex write fGroupIndex;
    property AllowAllUp: Boolean read fAllowAllUp write fAllowAllUp;
  end;

implementation

function ComparePaletteFactories(AItem1, AItem2: Pointer): Integer;
var
  lFactory1: TRecorderComponentFactoryBase;
  lFactory2: TRecorderComponentFactoryBase;
begin
  lFactory1 := TRecorderComponentFactoryBase(AItem1);
  lFactory2 := TRecorderComponentFactoryBase(AItem2);
  Result := lFactory1.PaletteOrder - lFactory2.PaletteOrder;
  if Result = 0 then
    Result := CompareText(lFactory1.TypeId, lFactory2.TypeId);
end;

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

constructor TRecorderComponentPalette.Create(AOwner: TComponent;
  ARegistry: TRecorderComponentFactory; AParent: TWinControl;
  AImages: TCustomImageList; AOnIconIndex: TRecorderPaletteIconIndexEvent;
  AOnFactorySelected: TRecorderPaletteFactoryEvent);
begin
  inherited Create(AOwner);
  if ARegistry = nil then
    raise EArgumentNilException.Create('ARegistry');
  if AParent = nil then
    raise EArgumentNilException.Create('AParent');
  fRegistry := ARegistry;
  fParent := AParent;
  fImages := AImages;
  fOnIconIndex := AOnIconIndex;
  fOnFactorySelected := AOnFactorySelected;
  fButtons := TList.Create;
  fGroups := TList.Create;
  fButtonTop := 4;
  fButtonWidth := 34;
  fButtonHeight := 24;
  fSpacing := 0;
  fGroupIndex := 0;
  fAllowAllUp := False;
end;

destructor TRecorderComponentPalette.Destroy;
var
  I: Integer;
begin
  for I := 0 to fGroups.Count - 1 do
    TObject(fGroups[I]).Free;
  fGroups.Free;
  fButtons.Free;
  inherited Destroy;
end;

procedure TRecorderComponentPalette.ConfigureGroup(const AId, ACaption, AHint,
  AIconId: string);
var
  lGroup: TRecorderPaletteGroup;
begin
  lGroup := FindGroup(AId);
  if lGroup = nil then
  begin
    lGroup := TRecorderPaletteGroup.Create;
    lGroup.Id := AId;
    fGroups.Add(lGroup);
  end;
  lGroup.Caption := ACaption;
  lGroup.Hint := AHint;
  lGroup.IconId := AIconId;
end;

function TRecorderComponentPalette.FindGroup(
  const AId: string): TRecorderPaletteGroup;
var
  I: Integer;
begin
  for I := 0 to fGroups.Count - 1 do
  begin
    Result := TRecorderPaletteGroup(fGroups[I]);
    if SameText(Result.Id, AId) then
      Exit;
  end;
  Result := nil;
end;

function TRecorderComponentPalette.IconIndex(const AIconId: string): Integer;
begin
  if Assigned(fOnIconIndex) then
    Result := fOnIconIndex(AIconId)
  else
    Result := -1;
end;

function TRecorderComponentPalette.NewButton(ALeft: Integer;
  const AHint, AIconId: string): TSpeedButton;
begin
  Result := TSpeedButton.Create(Self);
  Result.Parent := fParent;
  Result.SetBounds(ALeft, fButtonTop, fButtonWidth, fButtonHeight);
  Result.Images := fImages;
  Result.ImageIndex := IconIndex(AIconId);
  Result.ImageWidth := 25;
  Result.Hint := AHint;
  Result.ShowHint := True;
  Result.GroupIndex := fGroupIndex;
  Result.AllowAllUp := fAllowAllUp;
  fButtons.Add(Result);
end;

procedure TRecorderComponentPalette.FactoryClick(Sender: TObject);
var
  lButton: TSpeedButton;
begin
  if not (Sender is TSpeedButton) then
    Exit;
  lButton := TSpeedButton(Sender);
  if Assigned(fOnFactorySelected) then
    fOnFactorySelected(TRecorderComponentFactoryBase(Pointer(lButton.Tag)),
      lButton);
end;

procedure TRecorderComponentPalette.GroupItemClick(Sender: TObject);
var
  lItem: TMenuItem;
  lMenu: TMenu;
  lButton: TSpeedButton;
begin
  if not (Sender is TMenuItem) then
    Exit;
  lItem := TMenuItem(Sender);
  lMenu := lItem.GetParentMenu;
  if lMenu = nil then
    Exit;
  lButton := TSpeedButton(Pointer(lMenu.Tag));
  if Assigned(fOnFactorySelected) then
    fOnFactorySelected(TRecorderComponentFactoryBase(Pointer(lItem.Tag)),
      lButton);
end;

procedure TRecorderComponentPalette.GroupOpening(Sender: TObject);
begin
  ResetSelection;
end;

procedure TRecorderComponentPalette.ShowGroupMenu(Sender: TObject);
var
  lButton: TSpeedButton;
  lPoint: TPoint;
begin
  if not (Sender is TSpeedButton) then
    Exit;
  lButton := TSpeedButton(Sender);
  if lButton.PopupMenu = nil then
    Exit;
  lPoint := lButton.ClientToScreen(Point(0, lButton.Height));
  lButton.PopupMenu.PopUp(lPoint.X, lPoint.Y);
end;

function TRecorderComponentPalette.Build(AStartLeft: Integer): Integer;
var
  lFactories: TList;
  lBuiltGroups: TStringList;
  lFactory: TRecorderComponentFactoryBase;
  lGroupFactory: TRecorderComponentFactoryBase;
  lGroup: TRecorderPaletteGroup;
  lButton: TSpeedButton;
  lMenu: TPopupMenu;
  lItem: TMenuItem;
  I, J: Integer;
begin
  for I := fButtons.Count - 1 downto 0 do
    TObject(fButtons[I]).Free;
  fButtons.Clear;

  lFactories := TList.Create;
  lBuiltGroups := TStringList.Create;
  try
    lBuiltGroups.CaseSensitive := False;
    for I := 0 to fRegistry.FactoryCount - 1 do
      if fRegistry.Factories[I].PalettePlacement <> rppHidden then
        lFactories.Add(fRegistry.Factories[I]);
    lFactories.Sort(@ComparePaletteFactories);

    Result := AStartLeft;
    for I := 0 to lFactories.Count - 1 do
    begin
      lFactory := TRecorderComponentFactoryBase(lFactories[I]);
      if lFactory.PalettePlacement = rppStandalone then
      begin
        lButton := NewButton(Result, lFactory.PaletteHint,
          lFactory.PaletteIconId);
        lButton.Tag := PtrInt(lFactory);
        lButton.OnClick := @FactoryClick;
      end
      else
      begin
        if lBuiltGroups.IndexOf(lFactory.PaletteGroupId) >= 0 then
          Continue;
        lBuiltGroups.Add(lFactory.PaletteGroupId);
        lGroup := FindGroup(lFactory.PaletteGroupId);
        if lGroup = nil then
        begin
          lGroup := TRecorderPaletteGroup.Create;
          lGroup.Id := lFactory.PaletteGroupId;
          lGroup.Caption := lFactory.PaletteGroupId;
          lGroup.Hint := lFactory.PaletteGroupId;
          lGroup.IconId := lFactory.PaletteIconId;
          fGroups.Add(lGroup);
        end;
        lButton := NewButton(Result, lGroup.Hint, lGroup.IconId);
        lMenu := TPopupMenu.Create(lButton);
        lMenu.Images := fImages;
        lMenu.Tag := PtrInt(lButton);
        lMenu.OnPopup := @GroupOpening;
        lButton.PopupMenu := lMenu;
        lButton.OnClick := @ShowGroupMenu;
        for J := 0 to lFactories.Count - 1 do
        begin
          lGroupFactory := TRecorderComponentFactoryBase(lFactories[J]);
          if (lGroupFactory.PalettePlacement <> rppGroup) or
             (not SameText(lGroupFactory.PaletteGroupId,
               lFactory.PaletteGroupId)) then
            Continue;
          lItem := TMenuItem.Create(lMenu);
          lItem.Caption := lGroupFactory.PaletteCaption;
          lItem.Hint := lGroupFactory.PaletteHint;
          lItem.ImageIndex := IconIndex(lGroupFactory.PaletteIconId);
          lItem.Tag := PtrInt(lGroupFactory);
          lItem.OnClick := @GroupItemClick;
          lMenu.Items.Add(lItem);
        end;
      end;
      Inc(Result, fButtonWidth + fSpacing);
    end;
  finally
    lBuiltGroups.Free;
    lFactories.Free;
  end;
end;

procedure TRecorderComponentPalette.ResetSelection;
var
  I: Integer;
begin
  for I := 0 to fButtons.Count - 1 do
    TSpeedButton(fButtons[I]).Down := False;
end;

end.
