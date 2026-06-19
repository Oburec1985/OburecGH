unit uRecorderOscillogramSettingsDialog;

{
  Settings dialog for oscillogram components on user mnemonics.
  Supports one primary tag plus additional synchronized lines from the same device.
  РљРѕРґРёСЂРѕРІРєР° (2026-06):
    Р¤Р°Р№Р» РІ UTF-8, {$codepage UTF8}. РЎС‚СЂРѕРєРё РґР»СЏ LCL вЂ” РѕР±С‹С‡РЅС‹Рµ string-Р»РёС‚РµСЂР°Р»С‹.
    РЎРј. Docs/source-encoding.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, Dialogs,
  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags, uOglChartColors,
  uRecorderTagRefs;

function ShowRecorderOscillogramSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderOscillogramComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

type
  TRecorderOscillogramSettingsDialog = class(TForm)
  private
    fComponent: TRecorderOscillogramComponent;
    fDraft: TRecorderOscillogramComponent;
    fTagRegistry: TRecorderTagRegistry;
    fSelectedLine: Integer;
    fUpdating: Boolean;

    fTagSearchEdit: TEdit;
    fTagCombo: TComboBox;
    fBindingModeCombo: TComboBox;
    fTagOffsetEdit: TEdit;
    fLineList: TListBox;
    fAddLineButton: TButton;
    fDeleteLineButton: TButton;
    fLineTagCombo: TComboBox;
    fLineColorSwatch: TRecorderColorSwatch;
    fLineVisibleCheck: TCheckBox;
    fOkButton: TButton;
    fCancelButton: TButton;

    procedure AddLineClick(Sender: TObject);
    procedure BindingModeComboChange(Sender: TObject);
    procedure BuildUi;
    procedure DeleteLineClick(Sender: TObject);
    procedure FillPrimaryTagCombo(const AFilter: string);
    procedure FillLineTagCombo;
    procedure LineSelectionChange(Sender: TObject);
    procedure LineTagChange(Sender: TObject);
    procedure SyncDraftLineNames;
    procedure LoadFromComponent;
    procedure LoadLineControls(AIndex: Integer);
    procedure OkButtonClick(Sender: TObject);
    procedure PrimaryTagChange(Sender: TObject);
    procedure TagSearchEditChange(Sender: TObject);
    procedure StoreLineControls;
    procedure StoreToComponent;
    procedure RefreshLineList;
    function ValidateSourceIds: Boolean;
    procedure UpdatePrimaryTagVisibility;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderOscillogramComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderOscillogramSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderOscillogramComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderOscillogramSettingsDialog;
begin
  lDialog := TRecorderOscillogramSettingsDialog.CreateDialog(AOwner, AComponent,
    ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderOscillogramSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderOscillogramComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  fDraft := TRecorderOscillogramComponent.Create;
  fSelectedLine := -1;
  Caption := 'РќР°СЃС‚СЂРѕР№РєР° РѕСЃС†РёР»Р»РѕРіСЂР°РјРјС‹ - ' + AComponent.Name;
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 560;
  ClientHeight := 488;
  BuildUi;
  LoadFromComponent;
end;

destructor TRecorderOscillogramSettingsDialog.Destroy;
begin
  fDraft.Free;
  inherited Destroy;
end;

procedure TRecorderOscillogramSettingsDialog.BuildUi;
var
  lLabel: TLabel;
  lTop: Integer;
begin
  lTop := 12;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'РџРѕРёСЃРє С‚РµРіР°:';

  fTagSearchEdit := TEdit.Create(Self);
  fTagSearchEdit.Parent := Self;
  fTagSearchEdit.SetBounds(130, lTop, 410, 23);
  fTagSearchEdit.OnChange := @TagSearchEditChange;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'РћСЃРЅРѕРІРЅРѕР№ РєР°РЅР°Р»:';

  fTagCombo := TComboBox.Create(Self);
  fTagCombo.Parent := Self;
  fTagCombo.SetBounds(130, lTop, 410, 23);
  fTagCombo.Style := csDropDownList;
  fTagCombo.OnChange := @PrimaryTagChange;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'РџСЂРёРІСЏР·РєР°:';

  fBindingModeCombo := TComboBox.Create(Self);
  fBindingModeCombo.Parent := Self;
  fBindingModeCombo.SetBounds(130, lTop, 260, 23);
  fBindingModeCombo.Style := csDropDownList;
  fBindingModeCombo.Items.Add('РћС‚РЅРѕСЃРёС‚РµР»СЊРЅР°СЏ (РІС‹Р±СЂР°РЅРЅС‹Р№ С‚РµРі)');
  fBindingModeCombo.Items.Add('РђР±СЃРѕР»СЋС‚РЅР°СЏ РїСЂРёРІСЏР·РєР°');
  fBindingModeCombo.OnChange := @BindingModeComboChange;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'РћС‚РЅРѕСЃРёС‚. СЃРјРµС‰РµРЅРёРµ:';

  fTagOffsetEdit := TEdit.Create(Self);
  fTagOffsetEdit.Parent := Self;
  fTagOffsetEdit.SetBounds(130, lTop, 80, 23);
  Inc(lTop, 40);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop, 320, 16);
  lLabel.Caption := 'Р”РѕРї. Р»РёРЅРёРё (С‚Р° Р¶Рµ РїР»Р°С‚Р°/СѓСЃС‚СЂРѕР№СЃС‚РІРѕ):';

  fLineList := TListBox.Create(Self);
  fLineList.Parent := Self;
  fLineList.SetBounds(12, lTop + 20, 320, 120);
  fLineList.OnClick := @LineSelectionChange;

  fAddLineButton := TButton.Create(Self);
  fAddLineButton.Parent := Self;
  fAddLineButton.SetBounds(340, lTop + 20, 90, 25);
  fAddLineButton.Caption := 'Р”РѕР±Р°РІРёС‚СЊ';
  fAddLineButton.OnClick := @AddLineClick;

  fDeleteLineButton := TButton.Create(Self);
  fDeleteLineButton.Parent := Self;
  fDeleteLineButton.SetBounds(340, lTop + 50, 90, 25);
  fDeleteLineButton.Caption := 'РЈРґР°Р»РёС‚СЊ';
  fDeleteLineButton.OnClick := @DeleteLineClick;
  Inc(lTop, 150);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 80, 16);
  lLabel.Caption := 'РўРµРі:';

  fLineTagCombo := TComboBox.Create(Self);
  fLineTagCombo.Parent := Self;
  fLineTagCombo.SetBounds(90, lTop, 340, 23);
  fLineTagCombo.Style := csDropDownList;
  fLineTagCombo.OnChange := @LineTagChange;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 80, 16);
  lLabel.Caption := 'Р¦РІРµС‚:';

  fLineColorSwatch := TRecorderColorSwatch.Create(Self);
  fLineColorSwatch.Parent := Self;
  fLineColorSwatch.SetBounds(90, lTop, 28, 24);

  fLineVisibleCheck := TCheckBox.Create(Self);
  fLineVisibleCheck.Parent := Self;
  fLineVisibleCheck.SetBounds(130, lTop + 2, 120, 20);
  fLineVisibleCheck.Caption := 'Р’РёРґРёРјР°СЏ';
  Inc(lTop, 44);

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(450, lTop, 90, 25);
  fCancelButton.Caption := 'РћС‚РјРµРЅР°';
  fCancelButton.ModalResult := mrCancel;

  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(350, lTop, 90, 25);
  fOkButton.Caption := 'OK';
  fOkButton.Default := True;
  fOkButton.OnClick := @OkButtonClick;
end;

procedure TRecorderOscillogramSettingsDialog.FillPrimaryTagCombo(
  const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lTag: TRecorderTag;
  lCurrent: string;
  lSearchText: string;
begin
  if fTagCombo = nil then
    Exit;
  lCurrent := fDraft.TagName;
  fTagCombo.Items.BeginUpdate;
  try
    fTagCombo.Items.Clear;
    lFilter := LowerCase(Trim(AFilter));
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      lSearchText := LowerCase(lTag.Name + ' ' + lTag.Address + ' ' + lTag.Description);
      if (lFilter = '') or (Pos(lFilter, lSearchText) > 0) then
        fTagCombo.Items.AddObject(lTag.Name, lTag);
    end;
    fTagCombo.ItemIndex := -1;
    for I := 0 to fTagCombo.Items.Count - 1 do
      if (fTagCombo.Items.Objects[I] is TRecorderTag) and
        SameText(TRecorderTag(fTagCombo.Items.Objects[I]).Name, lCurrent) then
      begin
        fTagCombo.ItemIndex := I;
        Break;
      end;
    if (fTagCombo.ItemIndex < 0) and (fTagCombo.Items.Count > 0) then
      fTagCombo.ItemIndex := 0;
  finally
    fTagCombo.Items.EndUpdate;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.FillLineTagCombo;
var
  I: Integer;
  lPrimary: TRecorderTag;
  lTag: TRecorderTag;
  lCurrent: string;
begin
  if fLineTagCombo = nil then
    Exit;
  lPrimary := fTagRegistry.FindByName(fDraft.TagName);
  if (fSelectedLine >= 0) and (fSelectedLine < fDraft.LineCount) then
    lCurrent := fDraft.Lines[fSelectedLine].TagName
  else
    lCurrent := '';
  fLineTagCombo.Items.BeginUpdate;
  try
    fLineTagCombo.Items.Clear;
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if (lPrimary = nil) or SameText(lTag.SourceId, lPrimary.SourceId) then
        fLineTagCombo.Items.AddObject(lTag.Name, lTag);
    end;
    fLineTagCombo.ItemIndex := -1;
    for I := 0 to fLineTagCombo.Items.Count - 1 do
      if (fLineTagCombo.Items.Objects[I] is TRecorderTag) and
        SameText(TRecorderTag(fLineTagCombo.Items.Objects[I]).Name, lCurrent) then
      begin
        fLineTagCombo.ItemIndex := I;
        Break;
      end;
  finally
    fLineTagCombo.Items.EndUpdate;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.SyncDraftLineNames;
var
  I: Integer;
  lName: string;
  lColor: LongInt;
begin
  for I := 0 to fDraft.LineCount - 1 do
  begin
    lName := OglChartLinePaletteNameForColor(TColor(fDraft.Lines[I].Color));
    if lName <> '' then
      fDraft.Lines[I].Name := lName
    else
    begin
      OglChartLineAppearance(I + 1, lName, lColor);
      fDraft.Lines[I].Name := lName;
      fDraft.Lines[I].Color := lColor;
    end;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.LoadFromComponent;
begin
  fDraft.AssignOscillogram(fComponent);
  fDraft.TagName := fComponent.TagName;
  SyncDraftLineNames;
  fBindingModeCombo.ItemIndex := Ord(fDraft.BindingMode);
  fTagOffsetEdit.Text := IntToStr(fDraft.TagOffset);
  FillPrimaryTagCombo('');
  RefreshLineList;
  UpdatePrimaryTagVisibility;
end;

procedure TRecorderOscillogramSettingsDialog.RefreshLineList;
var
  I: Integer;
begin
  if fLineList = nil then
    Exit;
  fUpdating := True;
  try
    fLineList.Items.Clear;
    for I := 0 to fDraft.LineCount - 1 do
      fLineList.Items.Add(fDraft.Lines[I].Name);
    if (fSelectedLine >= 0) and (fSelectedLine < fLineList.Items.Count) then
      fLineList.ItemIndex := fSelectedLine
    else if fLineList.Items.Count > 0 then
    begin
      fSelectedLine := 0;
      fLineList.ItemIndex := 0;
    end
    else
      fSelectedLine := -1;
    LoadLineControls(fSelectedLine);
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.LoadLineControls(AIndex: Integer);
var
  lLine: TRecorderTrendLine;
  lEnabled: Boolean;
begin
  lEnabled := (AIndex >= 0) and (AIndex < fDraft.LineCount);
  fLineTagCombo.Enabled := lEnabled;
  fLineColorSwatch.Enabled := lEnabled;
  fLineVisibleCheck.Enabled := lEnabled;
  fDeleteLineButton.Enabled := lEnabled;
  if not lEnabled then
  begin
    fLineTagCombo.Items.Clear;
    fLineVisibleCheck.Checked := True;
    Exit;
  end;
  lLine := fDraft.Lines[AIndex];
  fLineColorSwatch.LineColor := TColor(lLine.Color);
  fLineVisibleCheck.Checked := lLine.Visible;
  FillLineTagCombo;
end;

procedure TRecorderOscillogramSettingsDialog.StoreLineControls;
var
  lLine: TRecorderTrendLine;
  lName: string;
begin
  if (fSelectedLine < 0) or (fSelectedLine >= fDraft.LineCount) then
    Exit;
  lLine := fDraft.Lines[fSelectedLine];
  if (fLineTagCombo.ItemIndex >= 0) and
    (fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex] is TRecorderTag) then
    RecorderBindTrendLineTag(lLine, TRecorderTag(fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex]));
  lLine.Color := LongInt(fLineColorSwatch.LineColor);
  lName := OglChartLinePaletteNameForColor(fLineColorSwatch.LineColor);
  if lName <> '' then
    lLine.Name := lName;
  lLine.Visible := fLineVisibleCheck.Checked;
end;

procedure TRecorderOscillogramSettingsDialog.StoreToComponent;
begin
  if (fTagCombo.ItemIndex >= 0) and
    (fTagCombo.Items.Objects[fTagCombo.ItemIndex] is TRecorderTag) then
    RecorderBindComponentTag(fDraft, TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]));
  fDraft.BindingMode := TRecorderTagBindingMode(fBindingModeCombo.ItemIndex);
  fDraft.TagOffset := StrToIntDef(fTagOffsetEdit.Text, 0);
  StoreLineControls;
  SyncDraftLineNames;
  fComponent.AssignOscillogram(fDraft);
  fComponent.TagId := fDraft.TagId;
  fComponent.TagName := fDraft.TagName;
end;

function TRecorderOscillogramSettingsDialog.ValidateSourceIds: Boolean;
var
  I: Integer;
  lNames: array of string;
  lCount: Integer;
begin
  Result := False;
  if fDraft.TagName = '' then
  begin
    ShowMessage('Р’С‹Р±РµСЂРёС‚Рµ РѕСЃРЅРѕРІРЅРѕР№ РєР°РЅР°Р».');
    Exit;
  end;
  lCount := 1;
  for I := 0 to fDraft.LineCount - 1 do
    if Trim(fDraft.Lines[I].TagName) <> '' then
      Inc(lCount);
  SetLength(lNames, lCount);
  lCount := 0;
  lNames[lCount] := fDraft.TagName;
  Inc(lCount);
  for I := 0 to fDraft.LineCount - 1 do
    if Trim(fDraft.Lines[I].TagName) <> '' then
    begin
      lNames[lCount] := fDraft.Lines[I].TagName;
      Inc(lCount);
    end;
  if not RecorderTagsShareSourceId(fTagRegistry, lNames) then
  begin
    ShowMessage('Р’СЃРµ РєР°РЅР°Р»С‹ РѕСЃС†РёР»Р»РѕРіСЂР°РјРјС‹ РґРѕР»Р¶РЅС‹ РїСЂРёРЅР°РґР»РµР¶Р°С‚СЊ РѕРґРЅРѕРјСѓ СѓСЃС‚СЂРѕР№СЃС‚РІСѓ (SourceId).');
    Exit;
  end;
  Result := True;
end;

procedure TRecorderOscillogramSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToComponent;
  if not ValidateSourceIds then
    Exit;
  ModalResult := mrOk;
end;

procedure TRecorderOscillogramSettingsDialog.AddLineClick(Sender: TObject);
var
  lLine: TRecorderTrendLine;
begin
  StoreLineControls;
  lLine := fDraft.AddLine;
  if fDraft.TagName <> '' then
    lLine.TagName := fDraft.TagName;
  fSelectedLine := fDraft.LineCount - 1;
  RefreshLineList;
end;

procedure TRecorderOscillogramSettingsDialog.DeleteLineClick(Sender: TObject);
begin
  if (fSelectedLine < 0) or (fSelectedLine >= fDraft.LineCount) then
    Exit;
  fDraft.DeleteLine(fSelectedLine);
  if fSelectedLine >= fDraft.LineCount then
    fSelectedLine := fDraft.LineCount - 1;
  RefreshLineList;
end;

procedure TRecorderOscillogramSettingsDialog.LineSelectionChange(Sender: TObject);
begin
  if fUpdating then
    Exit;
  StoreLineControls;
  fSelectedLine := fLineList.ItemIndex;
  LoadLineControls(fSelectedLine);
end;


procedure TRecorderOscillogramSettingsDialog.LineTagChange(Sender: TObject);
begin
  if fUpdating then
    Exit;
  StoreLineControls;
  if (fSelectedLine >= 0) and (fSelectedLine < fLineList.Items.Count) then
    fLineList.Items[fSelectedLine] := fDraft.Lines[fSelectedLine].Name;
end;

procedure TRecorderOscillogramSettingsDialog.TagSearchEditChange(Sender: TObject);
begin
  FillPrimaryTagCombo(fTagSearchEdit.Text);
end;

procedure TRecorderOscillogramSettingsDialog.PrimaryTagChange(Sender: TObject);
begin
  if (fTagCombo.ItemIndex >= 0) and
    (fTagCombo.Items.Objects[fTagCombo.ItemIndex] is TRecorderTag) then
    RecorderBindComponentTag(fDraft, TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]));
  FillLineTagCombo;
end;

procedure TRecorderOscillogramSettingsDialog.BindingModeComboChange(Sender: TObject);
begin
  UpdatePrimaryTagVisibility;
end;

procedure TRecorderOscillogramSettingsDialog.UpdatePrimaryTagVisibility;
var
  lShowTagChoice: Boolean;
begin
  lShowTagChoice := TRecorderTagBindingMode(fBindingModeCombo.ItemIndex) <>
    rtbmRelativeSelectedTag;
  fTagSearchEdit.Visible := lShowTagChoice;
  fTagCombo.Visible := lShowTagChoice;
end;

end.
