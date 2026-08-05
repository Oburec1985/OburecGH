#!/usr/bin/env python3
"""Remove separate line Name field; Name := TagName always."""
from pathlib import Path

TARGET = Path(__file__).resolve().parents[1] / "UI" / "uRecorderOscillogramSettingsDialog.pas"

OLD = r'''    fLineNameEdit: TEdit;
    fLineTagCombo: TComboBox;'''

NEW = r'''    fLineTagCombo: TComboBox;'''

OLD2 = r'''    procedure LineColorClick(Sender: TObject);
    procedure LineSelectionChange(Sender: TObject);'''

NEW2 = r'''    procedure LineColorClick(Sender: TObject);
    procedure LineSelectionChange(Sender: TObject);
    procedure LineTagChange(Sender: TObject);
    procedure SyncDraftLineNames;'''

content = TARGET.read_text(encoding="utf-8")
if OLD not in content:
    raise SystemExit("patch anchor 1 not found")
content = content.replace(OLD, NEW, 1)
if OLD2 not in content:
    raise SystemExit("patch anchor 2 not found")
content = content.replace(OLD2, NEW2, 1)

# BuildUi: remove Name row, relabel Tag -> keep as Tag
content = content.replace(
    """  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 80, 16);
  lLabel.Caption := 'Имя:';

  fLineNameEdit := TEdit.Create(Self);
  fLineNameEdit.Parent := Self;
  fLineNameEdit.SetBounds(90, lTop, 160, 23);
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 80, 16);
  lLabel.Caption := 'Тег:';

  fLineTagCombo := TComboBox.Create(Self);
  fLineTagCombo.Parent := Self;
  fLineTagCombo.SetBounds(90, lTop, 340, 23);
  fLineTagCombo.Style := csDropDownList;
  Inc(lTop, 32);""",
    """  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 80, 16);
  lLabel.Caption := 'Тег:';

  fLineTagCombo := TComboBox.Create(Self);
  fLineTagCombo.Parent := Self;
  fLineTagCombo.SetBounds(90, lTop, 340, 23);
  fLineTagCombo.Style := csDropDownList;
  fLineTagCombo.OnChange := @LineTagChange;
  Inc(lTop, 32);""",
    1,
)

content = content.replace("  ClientHeight := 520;", "  ClientHeight := 488;", 1)

content = content.replace(
    """    for I := 0 to fDraft.LineCount - 1 do
      fLineList.Items.Add(fDraft.Lines[I].Name);""",
    """    for I := 0 to fDraft.LineCount - 1 do
    begin
      if fDraft.Lines[I].TagName <> '' then
        fLineList.Items.Add(fDraft.Lines[I].TagName)
      else
        fLineList.Items.Add(fDraft.Lines[I].Name);
    end;""",
    1,
)

content = content.replace(
    """procedure TRecorderOscillogramSettingsDialog.LoadFromComponent;
begin
  fDraft.AssignOscillogram(fComponent);
  fDraft.TagName := fComponent.TagName;""",
    """procedure TRecorderOscillogramSettingsDialog.SyncDraftLineNames;
var
  I: Integer;
begin
  for I := 0 to fDraft.LineCount - 1 do
  begin
    if Trim(fDraft.Lines[I].TagName) <> '' then
      fDraft.Lines[I].Name := fDraft.Lines[I].TagName
    else if Trim(fDraft.Lines[I].Name) <> '' then
      fDraft.Lines[I].TagName := fDraft.Lines[I].Name;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.LoadFromComponent;
begin
  fDraft.AssignOscillogram(fComponent);
  fDraft.TagName := fComponent.TagName;
  SyncDraftLineNames;""",
    1,
)

content = content.replace(
    """  lEnabled := (AIndex >= 0) and (AIndex < fDraft.LineCount);
  fLineNameEdit.Enabled := lEnabled;
  fLineTagCombo.Enabled := lEnabled;""",
    """  lEnabled := (AIndex >= 0) and (AIndex < fDraft.LineCount);
  fLineTagCombo.Enabled := lEnabled;""",
    1,
)

content = content.replace(
    """  if not lEnabled then
  begin
    fLineNameEdit.Text := '';
    fLineTagCombo.Items.Clear;""",
    """  if not lEnabled then
  begin
    fLineTagCombo.Items.Clear;""",
    1,
)

content = content.replace(
    """  lLine := fDraft.Lines[AIndex];
  fLineNameEdit.Text := lLine.Name;
  fLineColorEdit.Text := ColorText(lLine.Color);""",
    """  lLine := fDraft.Lines[AIndex];
  fLineColorEdit.Text := ColorText(lLine.Color);""",
    1,
)

content = content.replace(
    """  lLine := fDraft.Lines[fSelectedLine];
  lLine.Name := Trim(fLineNameEdit.Text);
  if (fLineTagCombo.ItemIndex >= 0) and
    (fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex] is TRecorderTag) then
    lLine.TagName := TRecorderTag(fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex]).Name;""",
    """  lLine := fDraft.Lines[fSelectedLine];
  if (fLineTagCombo.ItemIndex >= 0) and
    (fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex] is TRecorderTag) then
    lLine.TagName := TRecorderTag(fLineTagCombo.Items.Objects[fLineTagCombo.ItemIndex]).Name;
  lLine.Name := lLine.TagName;""",
    1,
)

content = content.replace(
    """  fDraft.TagOffset := StrToIntDef(fTagOffsetEdit.Text, 0);
  StoreLineControls;
  fComponent.AssignOscillogram(fDraft);""",
    """  fDraft.TagOffset := StrToIntDef(fTagOffsetEdit.Text, 0);
  StoreLineControls;
  SyncDraftLineNames;
  fComponent.AssignOscillogram(fDraft);""",
    1,
)

content = content.replace(
    """  if fDraft.TagName <> '' then
    lLine.TagName := fDraft.TagName;
  fSelectedLine := fDraft.LineCount - 1;""",
    """  if fDraft.TagName <> '' then
  begin
    lLine.TagName := fDraft.TagName;
    lLine.Name := lLine.TagName;
  end;
  fSelectedLine := fDraft.LineCount - 1;""",
    1,
)

insert_before = "procedure TRecorderOscillogramSettingsDialog.LineColorClick(Sender: TObject);"
insert_block = """
procedure TRecorderOscillogramSettingsDialog.LineTagChange(Sender: TObject);
begin
  if fUpdating then
    Exit;
  StoreLineControls;
  if (fSelectedLine >= 0) and (fSelectedLine < fLineList.Items.Count) then
    fLineList.Items[fSelectedLine] := fDraft.Lines[fSelectedLine].TagName;
end;

"""
if insert_block.strip() not in content:
    content = content.replace(insert_before, insert_block + insert_before, 1)

TARGET.write_bytes(content.replace("\n", "\r\n").encode("utf-8"))
print("OK:", TARGET)
