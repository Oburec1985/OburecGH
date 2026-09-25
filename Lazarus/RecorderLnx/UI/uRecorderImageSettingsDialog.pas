unit uRecorderImageSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, StdCtrls, Grids, Dialogs,
  ExtDlgs, ExtCtrls, BGRABitmap, BGRASVG,
  uRecorderFormModel, uRecorderTags, uRecorderSvgRenderer,
  uRecorderSvgParameters;

type
  TRecorderImageSettingsDialog = class(TForm)
    AddButton: TButton;
    BrowseButton: TButton;
    BindingSourceCombo: TComboBox;
    BindingSourceLabel: TLabel;
    BindingTagCombo: TComboBox;
    BindingTagLabel: TLabel;
    BindingsGrid: TStringGrid;
    BindingsGroup: TGroupBox;
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
    procedure BindingsGridSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure BindingSourceComboChange(Sender: TObject);
    procedure BindingTagComboChange(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private
    fComponent: TRecorderImageComponent;
    fOwnComponent: Boolean;
    fTagRegistry: TRecorderTagRegistry;
    fPreviews: TList;
    procedure ClearPreviews;
    procedure FillTags;
    procedure FillBindingTags;
    procedure LoadFromComponent;
    procedure RebuildSvgParameters;
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
  ImageDialog.Filter := 'SVG (*.svg)|*.svg|' + ImageDialog.Filter;
  FillTags;
  FillBindingTags;
  LoadFromComponent;
end;

procedure TRecorderImageSettingsDialog.FillBindingTags;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  BindingTagCombo.Items.Clear;
  BindingTagCombo.Items.AddObject('(не связан)', nil);
  if fTagRegistry <> nil then
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      BindingTagCombo.Items.AddObject(lTag.Name, lTag);
    end;
  BindingTagCombo.ItemIndex := 0;
  BindingSourceCombo.Items.Clear;
  BindingSourceCombo.Items.Add('Текущее значение');
  BindingSourceCombo.Items.Add('Верхняя аварийная уставка');
  BindingSourceCombo.Items.Add('Верхняя предупредительная уставка');
  BindingSourceCombo.Items.Add('Нижняя предупредительная уставка');
  BindingSourceCombo.Items.Add('Нижняя аварийная уставка');
  BindingSourceCombo.Items.Add('Цвет верхней аварийной уставки');
  BindingSourceCombo.Items.Add('Цвет верхней предупредительной уставки');
  BindingSourceCombo.Items.Add('Цвет нижней предупредительной уставки');
  BindingSourceCombo.Items.Add('Цвет нижней аварийной уставки');
  BindingSourceCombo.Items.Add('Текущий цвет аварии (без аварии: белый)');
  BindingSourceCombo.Items.Add('Текущий цвет аварии (без аварии: прозрачный)');
  BindingSourceCombo.Items.Add('Текущий цвет аварии (без аварии: currentColor)');
  BindingSourceCombo.ItemIndex := 0;
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
  I, lRow: Integer;
begin
  ImagesGrid.RowCount := fComponent.Images.Count + 1;
  if ImagesGrid.RowCount < 2 then
    ImagesGrid.RowCount := 2;
  for I := 0 to fComponent.Images.Count - 1 do
  begin
    ImagesGrid.Cells[0, I + 1] := fComponent.Images.Names[I];
    ImagesGrid.Cells[1, I + 1] := fComponent.Images.ValueFromIndex[I];
  end;
  RebuildSvgParameters;
  for I := 0 to fComponent.SvgBindingCount - 1 do
  begin
    lRow := BindingsGrid.Cols[0].IndexOf(
      fComponent.SvgBindings[I].ParameterName);
    if lRow > 0 then
    begin
      BindingsGrid.Cells[1, lRow] := fComponent.SvgBindings[I].TagName;
      BindingsGrid.Objects[1, lRow] := fComponent.SvgBindings[I];
      BindingsGrid.Cells[2, lRow] :=
        BindingSourceCombo.Items[Ord(fComponent.SvgBindings[I].ValueKind)];
    end;
  end;
  RebuildPreviews;
end;

procedure TRecorderImageSettingsDialog.RebuildSvgParameters;
var
  I, lOldRow, lSeparatorPos: Integer;
  lNames, lExisting: TStringList;
  lTagName, lSourceName: string;
  lExistingValue: string;
begin
  lNames := TStringList.Create;
  lExisting := TStringList.Create;
  try
    lExisting.NameValueSeparator := '=';
    for lOldRow := 1 to BindingsGrid.RowCount - 1 do
      if BindingsGrid.Cells[0, lOldRow] <> '' then
        lExisting.Values[BindingsGrid.Cells[0, lOldRow]] :=
          BindingsGrid.Cells[1, lOldRow] + #9 +
          BindingsGrid.Cells[2, lOldRow];
    lNames.Sorted := True;
    lNames.Duplicates := dupIgnore;
    for I := 1 to ImagesGrid.RowCount - 1 do
      if SameText(ExtractFileExt(ImagesGrid.Cells[1, I]), '.svg') then
        ExtractSvgParameters(ImagesGrid.Cells[1, I], lNames);
    BindingsGrid.RowCount := Max(2, lNames.Count + 1);
    for I := 0 to lNames.Count - 1 do
    begin
      lTagName := '';
      lSourceName := BindingSourceCombo.Items[0];
      lExistingValue := lExisting.Values[lNames[I]];
      lSeparatorPos := Pos(#9, lExistingValue);
      if lSeparatorPos > 0 then
      begin
        lTagName := Copy(lExistingValue, 1, lSeparatorPos - 1);
        lSourceName := Copy(lExistingValue, lSeparatorPos + 1, MaxInt);
      end;
      BindingsGrid.Cells[0, I + 1] := lNames[I];
      BindingsGrid.Cells[1, I + 1] := lTagName;
      BindingsGrid.Cells[2, I + 1] := lSourceName;
    end;
    if lNames.Count = 0 then
      BindingsGrid.Rows[1].Clear;
  finally
    lExisting.Free;
    lNames.Free;
  end;
end;

procedure TRecorderImageSettingsDialog.RebuildPreviews;
var
  I: Integer;
  lPicture: TPicture;
  lSvg: TBGRASVG;
  lBitmap: TBGRABitmap;
begin
  ClearPreviews;
  for I := 1 to ImagesGrid.RowCount - 1 do
  begin
    lPicture := TPicture.Create;
    if (ImagesGrid.Cells[1, I] <> '') and
      FileExists(ImagesGrid.Cells[1, I]) then
      try
        if SameText(ExtractFileExt(ImagesGrid.Cells[1, I]), '.svg') then
        begin
          lSvg := TBGRASVG.Create;
          lBitmap := nil;
          try
            lSvg.LoadFromFile(ImagesGrid.Cells[1, I]);
            lBitmap := RenderSvgContent(lSvg, 96, 64);
            lPicture.Bitmap.Assign(lBitmap);
          finally
            lBitmap.Free;
            lSvg.Free;
          end;
        end
        else
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
  I, lTagIndex: Integer;
  lTag: TRecorderTag;
  lBinding: TRecorderSvgTagBinding;
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
  fComponent.ClearSvgBindings;
  for I := 1 to BindingsGrid.RowCount - 1 do
    if (Trim(BindingsGrid.Cells[0, I]) <> '') and
      (Trim(BindingsGrid.Cells[1, I]) <> '') then
    begin
      lBinding := fComponent.AddSvgBinding;
      lBinding.ParameterName := Trim(BindingsGrid.Cells[0, I]);
      lBinding.TagName := Trim(BindingsGrid.Cells[1, I]);
      lTagIndex := BindingTagCombo.Items.IndexOf(lBinding.TagName);
      if (lTagIndex >= 0) and
        (BindingTagCombo.Items.Objects[lTagIndex] is TRecorderTag) then
        lBinding.TagId := TRecorderTag(
          BindingTagCombo.Items.Objects[lTagIndex]).Id;
      lBinding.ValueKind := TRecorderSvgValueKind(EnsureRange(
        BindingSourceCombo.Items.IndexOf(BindingsGrid.Cells[2, I]),
        Ord(Low(TRecorderSvgValueKind)), Ord(High(TRecorderSvgValueKind))));
    end;
  fComponent.MarkImagesChanged;
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
  RebuildSvgParameters;
  RebuildPreviews;
end;

procedure TRecorderImageSettingsDialog.SelectImageFile;
begin
  if ImagesGrid.Row < 1 then
    Exit;
  if ImageDialog.Execute then
  begin
    ImagesGrid.Cells[1, ImagesGrid.Row] := ImageDialog.FileName;
    RebuildSvgParameters;
    RebuildPreviews;
  end;
end;

procedure TRecorderImageSettingsDialog.BindingsGridSelectCell(Sender: TObject;
  aCol, aRow: Integer; var CanSelect: Boolean);
var
  lIndex: Integer;
begin
  CanSelect := aRow > 0;
  if not CanSelect then
    Exit;
  lIndex := BindingTagCombo.Items.IndexOf(BindingsGrid.Cells[1, aRow]);
  if lIndex < 0 then
    lIndex := 0;
  BindingTagCombo.ItemIndex := lIndex;
  lIndex := BindingSourceCombo.Items.IndexOf(BindingsGrid.Cells[2, aRow]);
  if lIndex < 0 then
    lIndex := 0;
  BindingSourceCombo.ItemIndex := lIndex;
end;

procedure TRecorderImageSettingsDialog.BindingTagComboChange(Sender: TObject);
begin
  if BindingsGrid.Row > 0 then
    if BindingTagCombo.ItemIndex > 0 then
      BindingsGrid.Cells[1, BindingsGrid.Row] := BindingTagCombo.Text
    else
      BindingsGrid.Cells[1, BindingsGrid.Row] := '';
end;

procedure TRecorderImageSettingsDialog.BindingSourceComboChange(Sender: TObject);
begin
  if BindingsGrid.Row > 0 then
    BindingsGrid.Cells[2, BindingsGrid.Row] := BindingSourceCombo.Text;
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
