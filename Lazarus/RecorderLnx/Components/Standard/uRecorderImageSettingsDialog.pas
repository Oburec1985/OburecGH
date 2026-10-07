unit uRecorderImageSettingsDialog;

{
  Редактор картинок и параметрических SVG. Изменения применяются к выбранному
  компоненту сразу; снимок исходной модели восстанавливается при отмене.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Contnrs, Forms, Controls, Graphics, StdCtrls, Grids,
  Dialogs, ExtDlgs, ExtCtrls, ComCtrls, LazUTF8, BGRABitmap, BGRASVG, ColorBox,
  uRecorderFormModel, uRecorderTags, uRecorderSvgRenderer,
  uRecorderSvgParameters;

type
  TRecorderSvgBindingDraft = class
  public
    ParameterName: string;
    TagName: string;
    SourceName: string;
    LiteralValue: string;
  end;

  TRecorderImageSettingsDialog = class(TForm)
    AddButton: TButton;
    BrowseButton: TButton;
    BindingSourceCombo: TComboBox;
    BindingSourceLabel: TLabel;
    BindingTagCombo: TComboBox;
    BindingValueEdit: TEdit;
    BindingValueLabel: TLabel;
    BindingColorBox: TColorBox;
    BindingErrorLabel: TLabel;
    DecreaseValueButton: TButton;
    IncreaseValueButton: TButton;
    BindingSearchEdit: TEdit;
    BindingSearchLabel: TLabel;
    BindingBottomPan: TPanel;
    BindingTagLabel: TLabel;
    BindingsGrid: TStringGrid;
    BindingsGroup: TGroupBox;
    BottomPan: TPanel;
    CancelButton: TButton;
    DeleteButton: TButton;
    ImageDialog: TOpenPictureDialog;
    ImagesGrid: TStringGrid;
    OkButton: TButton;
    TagCombo: TComboBox;
    TagLabel: TLabel;
    TagSearchEdit: TEdit;
    TagSearchLabel: TLabel;
    HintLabel: TLabel;
    ClientPan: TPanel;
    ImagesRightPan: TPanel;
    ImagesTab: TTabSheet;
    Pages: TPageControl;
    SvgTab: TTabSheet;
    SvgPreviewImage: TImage;
    SvgPreviewLabel: TLabel;
    SvgPreviewPan: TPanel;
    SvgPreviewSplitter: TSplitter;
    TopPan: TPanel;
    procedure AddButtonClick(Sender: TObject);
    procedure BrowseButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ImagesGridDblClick(Sender: TObject);
    procedure ImagesGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure BindingsGridSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure BindingsGridSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure BindingSearchEditChange(Sender: TObject);
    procedure BindingSourceComboChange(Sender: TObject);
    procedure BindingTagComboChange(Sender: TObject);
    procedure BindingValueEditChange(Sender: TObject);
    procedure BindingColorBoxSelect(Sender: TObject);
    procedure BindingsGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure DecreaseValueButtonClick(Sender: TObject);
    procedure IncreaseValueButtonClick(Sender: TObject);
    procedure ParametersMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ImagesGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure OkButtonClick(Sender: TObject);
    procedure TagSearchEditChange(Sender: TObject);
    procedure TagComboChange(Sender: TObject);
  private
    fComponent: TRecorderImageComponent;
    fOwnComponent: Boolean;
    fOriginalComponent: TRecorderImageComponent;
    fAccepted: Boolean;
    fTagRegistry: TRecorderTagRegistry;
    fPreviews: TList;
    fSwitchTagId: TRecorderTagId;
    fSwitchTagName: string;
    fUpdatingTagCombo: Boolean;
    fUpdatingControls: Boolean;
    procedure AdjustSelectedNumber(ADirection: Integer);
    procedure ApplyLiveChanges;
    function BuildPreviewSvgSource(const AFileName: string): string;
    procedure ClearPreviews;
    procedure FillTags(const AFilter: string = '');
    procedure FillBindingTags(const AFilter: string = '');
    procedure LoadFromComponent;
    procedure RebuildSvgParameters;
    procedure RebuildPreviews;
    procedure RestoreOriginalComponent;
    procedure SelectImageFile;
    function SelectedParameterKind: TRecorderSvgParameterKind;
    procedure StoreToComponent;
    procedure UpdateValueControls;
    function ValidateBindings(out AError: string): Boolean;
    function ValidateLiteralValues(out AError: string): Boolean;
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
  fOriginalComponent := TRecorderImageComponent.Create;
  fOriginalComponent.AssignImage(AComponent);
  fTagRegistry := ATagRegistry;
  fPreviews := TList.Create;
  fSwitchTagId := AComponent.TagId;
  fSwitchTagName := AComponent.TagName;
  Caption := 'Настройка картинки - ' + AComponent.Name;
  ImageDialog.Filter := 'SVG (*.svg)|*.svg|' + ImageDialog.Filter;
  FillTags;
  FillBindingTags;
  LoadFromComponent;
end;

procedure TRecorderImageSettingsDialog.FillBindingTags(const AFilter: string);
var
  I, lSelectedIndex: Integer;
  lTag: TRecorderTag;
  lSelectedId: TRecorderTagId;
  lSelectedName, lFilter, lSearchText: string;
begin
  lSelectedId := 0;
  lSelectedName := BindingTagCombo.Text;
  if (BindingTagCombo.ItemIndex > 0) and
    (BindingTagCombo.Items.Objects[BindingTagCombo.ItemIndex] is TRecorderTag) then
    lSelectedId := TRecorderTag(
      BindingTagCombo.Items.Objects[BindingTagCombo.ItemIndex]).Id;
  lFilter := UTF8LowerCase(Trim(AFilter));
  BindingTagCombo.Items.Clear;
  BindingTagCombo.Items.AddObject('(не связан)', nil);
  lSelectedIndex := 0;
  if fTagRegistry <> nil then
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      lSearchText := UTF8LowerCase(lTag.Name + ' ' + lTag.Address + ' ' +
        lTag.Description);
      if (lFilter <> '') and (Pos(lFilter, lSearchText) = 0) then
        Continue;
      BindingTagCombo.Items.AddObject(lTag.Name, lTag);
      if ((lSelectedId <> 0) and (lTag.Id = lSelectedId)) or
        ((lSelectedId = 0) and SameText(lTag.Name, lSelectedName)) then
        lSelectedIndex := BindingTagCombo.Items.Count - 1;
    end;
  BindingTagCombo.ItemIndex := lSelectedIndex;
  if BindingSourceCombo.Items.Count = 0 then
  begin
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
  BindingSourceCombo.Items.Add('Постоянное значение');
  BindingSourceCombo.Items.Add('Видимость: значение тега не равно нулю');
  BindingSourceCombo.Items.Add('Видимость: включено');
  BindingSourceCombo.Items.Add('Видимость: выключено');
  end;
  BindingSourceCombo.ItemIndex := 0;
end;

procedure TRecorderImageSettingsDialog.BindingSearchEditChange(Sender: TObject);
begin
  FillBindingTags(BindingSearchEdit.Text);
end;

destructor TRecorderImageSettingsDialog.Destroy;
begin
  if not fAccepted then
    RestoreOriginalComponent;
  fOriginalComponent.Free;
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

procedure TRecorderImageSettingsDialog.FillTags(const AFilter: string);
var
  I, lSelected: Integer;
  lTag: TRecorderTag;
  lSelectedId: TRecorderTagId;
  lSelectedName, lFilter, lSearchText: string;
begin
  lSelectedId := fSwitchTagId;
  lSelectedName := fSwitchTagName;
  if (TagCombo.ItemIndex > 0) and
    (TagCombo.Items.Objects[TagCombo.ItemIndex] is TRecorderTag) then
  begin
    lSelectedId := TRecorderTag(TagCombo.Items.Objects[TagCombo.ItemIndex]).Id;
    lSelectedName := TRecorderTag(
      TagCombo.Items.Objects[TagCombo.ItemIndex]).Name;
  end;
  lFilter := UTF8LowerCase(Trim(AFilter));
  fUpdatingTagCombo := True;
  try
    TagCombo.Items.Clear;
    TagCombo.Items.AddObject('(без тега — одна картинка)', nil);
    lSelected := 0;
    if fTagRegistry <> nil then
      for I := 0 to fTagRegistry.TagCount - 1 do
      begin
        lTag := fTagRegistry.Tags[I];
        lSearchText := UTF8LowerCase(lTag.Name + ' ' + lTag.Address + ' ' +
          lTag.Description);
        if (lFilter <> '') and (Pos(lFilter, lSearchText) = 0) then
          Continue;
        TagCombo.Items.AddObject(lTag.Name, lTag);
        if ((lSelectedId <> 0) and (lTag.Id = lSelectedId)) or
          ((lSelectedId = 0) and SameText(lTag.Name, lSelectedName)) then
          lSelected := TagCombo.Items.Count - 1;
      end;
    TagCombo.ItemIndex := lSelected;
  finally
    fUpdatingTagCombo := False;
  end;
end;

procedure TRecorderImageSettingsDialog.TagSearchEditChange(Sender: TObject);
begin
  FillTags(TagSearchEdit.Text);
end;

procedure TRecorderImageSettingsDialog.TagComboChange(Sender: TObject);
var
  lTag: TRecorderTag;
begin
  if fUpdatingTagCombo then
    Exit;
  lTag := nil;
  if (TagCombo.ItemIndex > 0) and
    (TagCombo.Items.Objects[TagCombo.ItemIndex] is TRecorderTag) then
    lTag := TRecorderTag(TagCombo.Items.Objects[TagCombo.ItemIndex]);
  if lTag = nil then
  begin
    fSwitchTagId := 0;
    fSwitchTagName := '';
  end
  else
  begin
    fSwitchTagId := lTag.Id;
    fSwitchTagName := lTag.Name;
  end;
  ApplyLiveChanges;
end;

procedure TRecorderImageSettingsDialog.LoadFromComponent;
var
  I, lRow: Integer;
  lCanSelect, lWasUpdating: Boolean;
begin
  lWasUpdating := fUpdatingControls;
  fUpdatingControls := True;
  try
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
        BindingsGrid.Cells[3, lRow] :=
          fComponent.SvgBindings[I].LiteralValue;
      end;
    end;
    if Trim(BindingsGrid.Cells[0, 1]) <> '' then
    begin
      BindingsGrid.Row := 1;
      lCanSelect := True;
      BindingsGridSelectCell(BindingsGrid, BindingsGrid.Col, 1, lCanSelect);
    end
    else
      UpdateValueControls;
    RebuildPreviews;
  finally
    fUpdatingControls := lWasUpdating;
  end;
end;

procedure TRecorderImageSettingsDialog.RebuildSvgParameters;
var
  I, lOldRow, lDraftIndex: Integer;
  lWasUpdating: Boolean;
  lNames: TStringList;
  lDrafts: TObjectList;
  lDraft: TRecorderSvgBindingDraft;
  lTagName, lSourceName, lLiteralValue: string;
begin
  lWasUpdating := fUpdatingControls;
  fUpdatingControls := True;
  lNames := TStringList.Create;
  lDrafts := TObjectList.Create(True);
  try
    for lOldRow := 1 to BindingsGrid.RowCount - 1 do
      if BindingsGrid.Cells[0, lOldRow] <> '' then
      begin
        lDraft := TRecorderSvgBindingDraft.Create;
        lDraft.ParameterName := BindingsGrid.Cells[0, lOldRow];
        lDraft.TagName := BindingsGrid.Cells[1, lOldRow];
        lDraft.SourceName := BindingsGrid.Cells[2, lOldRow];
        lDraft.LiteralValue := BindingsGrid.Cells[3, lOldRow];
        lDrafts.Add(lDraft);
      end;
    lNames.Sorted := True;
    lNames.Duplicates := dupIgnore;
    for I := 1 to ImagesGrid.RowCount - 1 do
      if SameText(ExtractFileExt(ImagesGrid.Cells[1, I]), '.svg') then
        ExtractSvgParameters(ImagesGrid.Cells[1, I], lNames);
    BindingsGrid.RowCount := Max(2, lNames.Count + 1);
    for I := 0 to lNames.Count - 1 do
    begin
      lTagName := '';
      if lNames.ValueFromIndex[I] <> '' then
        lSourceName := BindingSourceCombo.Items[Ord(rsvLiteral)]
      else
        lSourceName := BindingSourceCombo.Items[0];
      lLiteralValue := lNames.ValueFromIndex[I];
      for lDraftIndex := 0 to lDrafts.Count - 1 do
      begin
        lDraft := TRecorderSvgBindingDraft(lDrafts[lDraftIndex]);
        if SameText(lDraft.ParameterName, lNames.Names[I]) then
        begin
          lTagName := lDraft.TagName;
          lSourceName := lDraft.SourceName;
          lLiteralValue := lDraft.LiteralValue;
          Break;
        end;
      end;
      BindingsGrid.Cells[0, I + 1] := lNames.Names[I];
      BindingsGrid.Cells[1, I + 1] := lTagName;
      BindingsGrid.Cells[2, I + 1] := lSourceName;
      BindingsGrid.Cells[3, I + 1] := lLiteralValue;
    end;
    if lNames.Count = 0 then
      BindingsGrid.Rows[1].Clear;
  finally
    lDrafts.Free;
    lNames.Free;
    fUpdatingControls := lWasUpdating;
  end;
end;

procedure TRecorderImageSettingsDialog.RebuildPreviews;
var
  I: Integer;
  lPicture: TPicture;
  lSvg: TBGRASVG;
  lBitmap: TBGRABitmap;
  lSource: string;
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
            lSource := BuildPreviewSvgSource(ImagesGrid.Cells[1, I]);
            lSource := ResolveSvgRendererExpressions(lSource);
            lSvg.AsUTF8String := lSource;
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

  SvgPreviewImage.Picture.Clear;
  for I := 0 to fPreviews.Count - 1 do
    if (TPicture(fPreviews[I]).Graphic <> nil) and
      not TPicture(fPreviews[I]).Graphic.Empty then
    begin
      SvgPreviewImage.Picture.Assign(TPicture(fPreviews[I]));
      Break;
    end;
end;

function TRecorderImageSettingsDialog.BuildPreviewSvgSource(
  const AFileName: string): string;
var
  I: Integer;
  lParameters: TStringList;
  lValue: string;
begin
  Result := LoadSvgText(AFileName);
  lParameters := TStringList.Create;
  try
    lParameters.NameValueSeparator := '=';
    ExtractSvgParameters(AFileName, lParameters);
    for I := 1 to BindingsGrid.RowCount - 1 do
      if Trim(BindingsGrid.Cells[0, I]) <> '' then
      begin
        lValue := BindingsGrid.Cells[3, I];
        if lValue = '' then
          lValue := lParameters.Values[BindingsGrid.Cells[0, I]];
        Result := ReplaceSvgParameter(Result, BindingsGrid.Cells[0, I],
          EscapeSvgParameterValue(lValue));
      end;
    Result := ResolveSvgParameterDefaults(Result);
    Result := ResolveSvgRendererExpressions(Result);
  finally
    lParameters.Free;
  end;
end;

procedure TRecorderImageSettingsDialog.ApplyLiveChanges;
var
  lError: string;
begin
  if fUpdatingControls or (fComponent = nil) then
    Exit;
  if not ValidateBindings(lError) or not ValidateLiteralValues(lError) then
  begin
    BindingErrorLabel.Caption := lError;
    Exit;
  end;
  BindingErrorLabel.Caption := '';
  StoreToComponent;
  RebuildPreviews;
end;

procedure TRecorderImageSettingsDialog.RestoreOriginalComponent;
begin
  if (fComponent <> nil) and (fOriginalComponent <> nil) then
    fComponent.AssignImage(fOriginalComponent);
end;

procedure TRecorderImageSettingsDialog.StoreToComponent;
var
  I: Integer;
  lTag: TRecorderTag;
  lBinding: TRecorderSvgTagBinding;
begin
  lTag := nil;
  if (fTagRegistry <> nil) and (fSwitchTagId <> 0) then
    lTag := fTagRegistry.FindById(fSwitchTagId);
  if (lTag = nil) and (fTagRegistry <> nil) and (fSwitchTagName <> '') then
    lTag := fTagRegistry.FindByName(fSwitchTagName);
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
    if Trim(BindingsGrid.Cells[0, I]) <> '' then
    begin
      lBinding := fComponent.AddSvgBinding;
      lBinding.ParameterName := Trim(BindingsGrid.Cells[0, I]);
      lBinding.TagName := Trim(BindingsGrid.Cells[1, I]);
      if fTagRegistry <> nil then
      begin
        lTag := fTagRegistry.FindByName(lBinding.TagName);
        if lTag <> nil then
          lBinding.TagId := lTag.Id;
      end;
      lBinding.ValueKind := TRecorderSvgValueKind(
        BindingSourceCombo.Items.IndexOf(BindingsGrid.Cells[2, I]));
      lBinding.LiteralValue := BindingsGrid.Cells[3, I];
    end;
  fComponent.MarkImagesChanged;
end;

procedure TRecorderImageSettingsDialog.AddButtonClick(Sender: TObject);
begin
  ImagesGrid.RowCount := ImagesGrid.RowCount + 1;
  ImagesGrid.Row := ImagesGrid.RowCount - 1;
  RebuildPreviews;
  ApplyLiveChanges;
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
  ApplyLiveChanges;
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
    ApplyLiveChanges;
  end;
end;

procedure TRecorderImageSettingsDialog.BindingsGridSelectCell(Sender: TObject;
  aCol, aRow: Integer; var CanSelect: Boolean);
var
  lIndex: Integer;
  lWasUpdating: Boolean;
begin
  CanSelect := aRow > 0;
  if not CanSelect then
    Exit;
  lWasUpdating := fUpdatingControls;
  fUpdatingControls := True;
  try
    lIndex := BindingTagCombo.Items.IndexOf(BindingsGrid.Cells[1, aRow]);
    if lIndex < 0 then
      lIndex := 0;
    BindingTagCombo.ItemIndex := lIndex;
    lIndex := BindingSourceCombo.Items.IndexOf(BindingsGrid.Cells[2, aRow]);
    if lIndex < 0 then
      lIndex := 0;
    BindingSourceCombo.ItemIndex := lIndex;
    BindingValueEdit.Text := BindingsGrid.Cells[3, aRow];
  finally
    fUpdatingControls := lWasUpdating;
  end;
  UpdateValueControls;
end;

procedure TRecorderImageSettingsDialog.BindingsGridSelectEditor(Sender: TObject;
  aCol, aRow: Integer; var Editor: TWinControl);
begin
  { Parameter, tag identity and source are selected by the template and the
    dedicated controls. Only the literal/default cell is directly editable. }
  if (aRow <= 0) or (aCol <> 3) then
    Editor := nil;
end;

procedure TRecorderImageSettingsDialog.ParametersMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  lCanSelect: Boolean;
  lRow: Integer;
begin
  if (Pages.ActivePage <> SvgTab) or (BindingsGrid.RowCount <= 2) or
    (WheelDelta = 0) then
    Exit;
  if WheelDelta > 0 then
    lRow := Max(1, BindingsGrid.Row - 1)
  else
    lRow := Min(BindingsGrid.RowCount - 1, BindingsGrid.Row + 1);
  BindingsGrid.Row := lRow;
  lCanSelect := True;
  BindingsGridSelectCell(BindingsGrid, BindingsGrid.Col, lRow, lCanSelect);
  Handled := True;
end;

procedure TRecorderImageSettingsDialog.BindingTagComboChange(Sender: TObject);
begin
  if fUpdatingControls then
    Exit;
  if BindingsGrid.Row > 0 then
    if BindingTagCombo.ItemIndex > 0 then
      BindingsGrid.Cells[1, BindingsGrid.Row] := BindingTagCombo.Text
    else
      BindingsGrid.Cells[1, BindingsGrid.Row] := '';
  ApplyLiveChanges;
end;

procedure TRecorderImageSettingsDialog.BindingSourceComboChange(Sender: TObject);
begin
  if fUpdatingControls then
    Exit;
  if BindingsGrid.Row > 0 then
    BindingsGrid.Cells[2, BindingsGrid.Row] := BindingSourceCombo.Text;
  UpdateValueControls;
  ApplyLiveChanges;
end;

procedure TRecorderImageSettingsDialog.BindingValueEditChange(Sender: TObject);
begin
  if fUpdatingControls or (BindingsGrid.Row <= 0) then
    Exit;
  BindingsGrid.Cells[3, BindingsGrid.Row] := BindingValueEdit.Text;
  ApplyLiveChanges;
end;

procedure TRecorderImageSettingsDialog.BindingColorBoxSelect(Sender: TObject);
var
  lColor: TColor;
begin
  if fUpdatingControls or (BindingsGrid.Row <= 0) then
    Exit;
  lColor := ColorToRGB(BindingColorBox.Selected);
  BindingValueEdit.Text := Format('#%.2x%.2x%.2x',
    [Red(lColor), Green(lColor), Blue(lColor)]);
end;

procedure TRecorderImageSettingsDialog.BindingsGridSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
begin
  if fUpdatingControls or (ARow <= 0) or (ACol <> 3) then
    Exit;
  fUpdatingControls := True;
  BindingValueEdit.Text := Value;
  fUpdatingControls := False;
  UpdateValueControls;
  ApplyLiveChanges;
end;

procedure TRecorderImageSettingsDialog.ImagesGridSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
begin
  if fUpdatingControls or (ARow <= 0) or (ACol > 1) then
    Exit;
  { While a path is being typed it is temporarily incomplete. Keep the last
    valid component image until the new file actually exists. }
  if (ACol = 1) and (Trim(Value) <> '') and not FileExists(Trim(Value)) then
    Exit;
  RebuildSvgParameters;
  ApplyLiveChanges;
end;

function TRecorderImageSettingsDialog.SelectedParameterKind:
  TRecorderSvgParameterKind;
var
  I: Integer;
  lSource: string;
begin
  Result := rspText;
  if BindingsGrid.Row <= 0 then
    Exit;
  lSource := '';
  for I := 1 to ImagesGrid.RowCount - 1 do
    if SameText(ExtractFileExt(ImagesGrid.Cells[1, I]), '.svg') then
      lSource := lSource + LoadSvgText(ImagesGrid.Cells[1, I]);
  Result := DetectSvgParameterKind(lSource,
    BindingsGrid.Cells[0, BindingsGrid.Row]);
end;

procedure TRecorderImageSettingsDialog.UpdateValueControls;
var
  lBlue, lGreen, lRed: Integer;
  lKind: TRecorderSvgParameterKind;
  lValue: string;
  lWasUpdating: Boolean;
begin
  lKind := SelectedParameterKind;
  lValue := BindingValueEdit.Text;
  DecreaseValueButton.Enabled := lKind = rspNumber;
  IncreaseValueButton.Enabled := lKind = rspNumber;
  BindingColorBox.Visible := lKind = rspColor;
  if (lKind = rspColor) and (Length(lValue) = 7) and
    (lValue[1] = '#') then
  begin
    if TryStrToInt('$' + Copy(lValue, 2, 2), lRed) and
      TryStrToInt('$' + Copy(lValue, 4, 2), lGreen) and
      TryStrToInt('$' + Copy(lValue, 6, 2), lBlue) then
    begin
      lWasUpdating := fUpdatingControls;
      fUpdatingControls := True;
      BindingColorBox.Selected := RGBToColor(lRed, lGreen, lBlue);
      fUpdatingControls := lWasUpdating;
    end;
  end;
end;

procedure TRecorderImageSettingsDialog.AdjustSelectedNumber(
  ADirection: Integer);
var
  lNumber: Double;
begin
  if (BindingsGrid.Row <= 0) or
    not TryParseSvgNumber(BindingValueEdit.Text, lNumber) then
    Exit;
  lNumber := lNumber + ADirection * SvgNumberOrderStep(lNumber);
  BindingValueEdit.Text := FormatSvgNumber(lNumber);
end;

procedure TRecorderImageSettingsDialog.DecreaseValueButtonClick(
  Sender: TObject);
begin
  AdjustSelectedNumber(-1);
end;

procedure TRecorderImageSettingsDialog.IncreaseValueButtonClick(
  Sender: TObject);
begin
  AdjustSelectedNumber(1);
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
var
  lError: string;
begin
  if not ValidateBindings(lError) then
  begin
    MessageDlg('Параметры SVG', lError, mtError, [mbOK], 0);
    Exit;
  end;
  if not ValidateLiteralValues(lError) then
  begin
    MessageDlg('Параметры SVG', lError, mtError, [mbOK], 0);
    Exit;
  end;
  StoreToComponent;
  fAccepted := True;
  ModalResult := mrOk;
end;

function TRecorderImageSettingsDialog.ValidateLiteralValues(
  out AError: string): Boolean;
var
  I, J, lSourceIndex: Integer;
  lSource: string;
begin
  AError := '';
  lSource := '';
  for I := 1 to ImagesGrid.RowCount - 1 do
    if SameText(ExtractFileExt(ImagesGrid.Cells[1, I]), '.svg') and
      FileExists(ImagesGrid.Cells[1, I]) then
      lSource := lSource + LoadSvgText(ImagesGrid.Cells[1, I]);
  for J := 1 to BindingsGrid.RowCount - 1 do
    if Trim(BindingsGrid.Cells[0, J]) <> '' then
    begin
      lSourceIndex := BindingSourceCombo.Items.IndexOf(
        BindingsGrid.Cells[2, J]);
      { An empty fallback is legitimate for a tag-driven parameter. It is not
        injected while the tag supplies the live value. }
      if (lSourceIndex <> Ord(rsvLiteral)) and
        (BindingsGrid.Cells[3, J] = '') then
        Continue;
      if not ValidateSvgParameterValue(lSource, BindingsGrid.Cells[0, J],
        BindingsGrid.Cells[3, J], AError) then
        Exit(False);
    end;
  Result := True;
end;

function TRecorderImageSettingsDialog.ValidateBindings(
  out AError: string): Boolean;
var
  I, lSourceIndex: Integer;
  lRequiresTag: Boolean;
begin
  AError := '';
  for I := 1 to BindingsGrid.RowCount - 1 do
  begin
    if Trim(BindingsGrid.Cells[0, I]) = '' then
      Continue;
    lSourceIndex := BindingSourceCombo.Items.IndexOf(
      BindingsGrid.Cells[2, I]);
    if (lSourceIndex < Ord(Low(TRecorderSvgValueKind))) or
      (lSourceIndex > Ord(High(TRecorderSvgValueKind))) then
    begin
      AError := Format('Для параметра «%s» выбран неизвестный источник.',
        [BindingsGrid.Cells[0, I]]);
      Exit(False);
    end;
    lRequiresTag := not (TRecorderSvgValueKind(lSourceIndex) in
      [rsvLiteral, rsvAlwaysVisible, rsvAlwaysHidden]);
    if lRequiresTag then
    begin
      if (fTagRegistry = nil) or
        (fTagRegistry.FindByName(BindingsGrid.Cells[1, I]) = nil) then
      begin
        AError := Format('Для параметра «%s» нужно выбрать существующий тег.',
          [BindingsGrid.Cells[0, I]]);
        Exit(False);
      end;
    end;
  end;
  Result := True;
end;

end.
