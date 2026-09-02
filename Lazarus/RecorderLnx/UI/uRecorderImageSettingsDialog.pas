unit uRecorderImageSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, Grids, Dialogs,
  ExtDlgs, ExtCtrls, uRecorderFormModel, uRecorderTags;

type
  TRecorderImageSettingsDialog = class(TForm)
    AddButton: TButton;
    BrowseButton: TButton;
    CancelButton: TButton;
    DeleteButton: TButton;
    ImageDialog: TOpenPictureDialog;
    ImagesGrid: TStringGrid;
    OkButton: TButton;
    TagCombo: TComboBox;
    TagLabel: TLabel;
    HintLabel: TLabel;
    procedure AddButtonClick(Sender: TObject);
    procedure BrowseButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ImagesGridDblClick(Sender: TObject);
    procedure ImagesGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure OkButtonClick(Sender: TObject);
  private
    fComponent: TRecorderImageComponent;
    fOwnComponent: Boolean;
    fTagRegistry: TRecorderTagRegistry;
    fPreviews: TList;
    procedure ClearPreviews;
    procedure FillTags;
    procedure LoadFromComponent;
    procedure RebuildPreviews;
    procedure SelectImageFile;
    procedure StoreToComponent;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderImageComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderImageSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderImageComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
function CreateRecorderImageSettingsGuideForm(AOwner: TComponent): TForm;

implementation

{$R *.lfm}

function ShowRecorderImageSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderImageComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderImageSettingsDialog;
begin
  lDialog := TRecorderImageSettingsDialog.CreateDialog(AOwner, AComponent,
    ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

function CreateRecorderImageSettingsGuideForm(AOwner: TComponent): TForm;
var
  lComponent: TRecorderImageComponent;
  lDialog: TRecorderImageSettingsDialog;
begin
  lComponent := TRecorderImageComponent.Create;
  lComponent.Name := 'Картинка';
  try
    lDialog := TRecorderImageSettingsDialog.CreateDialog(AOwner, lComponent, nil);
    lDialog.fOwnComponent := True;
    Result := lDialog;
  except
    lComponent.Free;
    raise;
  end;
end;

constructor TRecorderImageSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderImageComponent; ATagRegistry: TRecorderTagRegistry);
begin
  inherited Create(AOwner);
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  fPreviews := TList.Create;
  Caption := 'Настройка картинки - ' + AComponent.Name;
  FillTags;
  LoadFromComponent;
end;

destructor TRecorderImageSettingsDialog.Destroy;
begin
  ClearPreviews;
  fPreviews.Free;
  if fOwnComponent then
    fComponent.Free;
  inherited Destroy;
end;

procedure TRecorderImageSettingsDialog.ClearPreviews;
var
  I: Integer;
begin
  if fPreviews = nil then
    Exit;
  for I := 0 to fPreviews.Count - 1 do
    TObject(fPreviews[I]).Free;
  fPreviews.Clear;
end;

procedure TRecorderImageSettingsDialog.FillTags;
var
  I, lSelected: Integer;
  lTag: TRecorderTag;
begin
  TagCombo.Items.Clear;
  TagCombo.Items.AddObject('(без тега — одна картинка)', nil);
  lSelected := 0;
  if fTagRegistry <> nil then
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      TagCombo.Items.AddObject(lTag.Name, lTag);
      if ((fComponent.TagId <> 0) and (lTag.Id = fComponent.TagId)) or
        ((fComponent.TagId = 0) and SameText(lTag.Name, fComponent.TagName)) then
        lSelected := TagCombo.Items.Count - 1;
    end;
  TagCombo.ItemIndex := lSelected;
end;

procedure TRecorderImageSettingsDialog.LoadFromComponent;
var
  I: Integer;
begin
  ImagesGrid.RowCount := fComponent.Images.Count + 1;
  if ImagesGrid.RowCount < 2 then
    ImagesGrid.RowCount := 2;
  for I := 0 to fComponent.Images.Count - 1 do
  begin
    ImagesGrid.Cells[0, I + 1] := fComponent.Images.Names[I];
    ImagesGrid.Cells[1, I + 1] := fComponent.Images.ValueFromIndex[I];
  end;
  RebuildPreviews;
end;

procedure TRecorderImageSettingsDialog.RebuildPreviews;
var
  I: Integer;
  lPicture: TPicture;
begin
  ClearPreviews;
  for I := 1 to ImagesGrid.RowCount - 1 do
  begin
    lPicture := TPicture.Create;
    if (ImagesGrid.Cells[1, I] <> '') and
      FileExists(ImagesGrid.Cells[1, I]) then
      try
        lPicture.LoadFromFile(ImagesGrid.Cells[1, I]);
      except
        lPicture.Clear;
      end;
    fPreviews.Add(lPicture);
  end;
  ImagesGrid.Invalidate;
end;

procedure TRecorderImageSettingsDialog.StoreToComponent;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  lTag := nil;
  if (TagCombo.ItemIndex > 0) and
    (TagCombo.Items.Objects[TagCombo.ItemIndex] is TRecorderTag) then
    lTag := TRecorderTag(TagCombo.Items.Objects[TagCombo.ItemIndex]);
  if lTag <> nil then
  begin
    fComponent.TagId := lTag.Id;
    fComponent.TagName := lTag.Name;
  end
  else
  begin
    fComponent.TagId := 0;
    fComponent.TagName := '';
  end;
  fComponent.Images.Clear;
  for I := 1 to ImagesGrid.RowCount - 1 do
    if Trim(ImagesGrid.Cells[1, I]) <> '' then
      fComponent.Images.Add(Trim(ImagesGrid.Cells[0, I]) + '=' +
        Trim(ImagesGrid.Cells[1, I]));
end;

procedure TRecorderImageSettingsDialog.AddButtonClick(Sender: TObject);
begin
  ImagesGrid.RowCount := ImagesGrid.RowCount + 1;
  ImagesGrid.Row := ImagesGrid.RowCount - 1;
  RebuildPreviews;
end;

procedure TRecorderImageSettingsDialog.DeleteButtonClick(Sender: TObject);
var
  I: Integer;
begin
  if (ImagesGrid.Row <= 0) or (ImagesGrid.Row >= ImagesGrid.RowCount) then
    Exit;
  for I := ImagesGrid.Row to ImagesGrid.RowCount - 2 do
  begin
    ImagesGrid.Rows[I].Assign(ImagesGrid.Rows[I + 1]);
  end;
  if ImagesGrid.RowCount > 2 then
    ImagesGrid.RowCount := ImagesGrid.RowCount - 1
  else
    ImagesGrid.Rows[1].Clear;
  RebuildPreviews;
end;

procedure TRecorderImageSettingsDialog.SelectImageFile;
begin
  if ImagesGrid.Row < 1 then
    Exit;
  if ImageDialog.Execute then
  begin
    ImagesGrid.Cells[1, ImagesGrid.Row] := ImageDialog.FileName;
    RebuildPreviews;
  end;
end;

procedure TRecorderImageSettingsDialog.BrowseButtonClick(Sender: TObject);
begin
  SelectImageFile;
end;

procedure TRecorderImageSettingsDialog.ImagesGridDblClick(Sender: TObject);
begin
  SelectImageFile;
end;

procedure TRecorderImageSettingsDialog.ImagesGridDrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  lPicture: TPicture;
  lRect: TRect;
begin
  if (aCol <> 2) or (aRow <= 0) or (aRow > fPreviews.Count) then
    Exit;
  ImagesGrid.Canvas.Brush.Color := clWhite;
  ImagesGrid.Canvas.FillRect(aRect);
  lPicture := TPicture(fPreviews[aRow - 1]);
  if (lPicture.Graphic = nil) or lPicture.Graphic.Empty then
    Exit;
  lRect := aRect;
  Inc(lRect.Left, 3);
  Inc(lRect.Top, 3);
  Dec(lRect.Right, 3);
  Dec(lRect.Bottom, 3);
  ImagesGrid.Canvas.StretchDraw(lRect, lPicture.Graphic);
end;

procedure TRecorderImageSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToComponent;
  ModalResult := mrOk;
end;

end.
