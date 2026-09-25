unit uRecorderTagPickerDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls,
  uRecorderTags;

function ShowRecorderTagPickerDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const AInitialTagName: string;
  AVectorOnly: Boolean; out ASelectedTag: TRecorderTag): Boolean;
function RecorderTagCanProvideBlocks(ATag: TRecorderTag): Boolean;

implementation

uses
  LazUTF8;

function RecorderTagCanProvideBlocks(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and (ATag.PollFrequencyHz > 0.0) and
    ATag.IsVector;
end;

type
  TRecorderTagPickerDialog = class(TForm)
  private
    fRegistry: TRecorderTagRegistry;
    fVectorOnly: Boolean;
    fInitialTagName: string;
    fSearchEdit: TEdit;
    fTagList: TListBox;
    fOkButton: TButton;
    procedure SearchChanged(Sender: TObject);
    procedure TagListDblClick(Sender: TObject);
    procedure RebuildList;
    function TagMatchesFilter(ATag: TRecorderTag;
      const AFilter: string): Boolean;
  public
    constructor CreatePicker(AOwner: TComponent;
      ARegistry: TRecorderTagRegistry; const AInitialTagName: string;
      AVectorOnly: Boolean);
    function SelectedTag: TRecorderTag;
  end;

constructor TRecorderTagPickerDialog.CreatePicker(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const AInitialTagName: string;
  AVectorOnly: Boolean);
var
  lTopPanel, lBottomPanel: TPanel;
  lLabel: TLabel;
  lCancelButton: TButton;
begin
  inherited CreateNew(AOwner);
  fRegistry := ARegistry;
  fVectorOnly := AVectorOnly;
  fInitialTagName := AInitialTagName;
  Caption := 'Выбор исходного тега';
  Position := poScreenCenter;
  SetBounds(0, 0, 560, 520);
  Constraints.MinWidth := 420;
  Constraints.MinHeight := 340;

  lTopPanel := TPanel.Create(Self);
  lTopPanel.Parent := Self;
  lTopPanel.Align := alTop;
  lTopPanel.AutoSize := True;
  lTopPanel.BevelOuter := bvNone;
  lTopPanel.BorderSpacing.Around := 8;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := lTopPanel;
  lLabel.Align := alTop;
  lLabel.Caption := 'Поиск по имени, адресу или описанию:';
  lLabel.BorderSpacing.Bottom := 4;

  fSearchEdit := TEdit.Create(Self);
  fSearchEdit.Parent := lTopPanel;
  fSearchEdit.Align := alTop;
  fSearchEdit.AutoSize := True;
  fSearchEdit.TabOrder := 0;
  fSearchEdit.OnChange := @SearchChanged;

  lBottomPanel := TPanel.Create(Self);
  lBottomPanel.Parent := Self;
  lBottomPanel.Align := alBottom;
  lBottomPanel.AutoSize := True;
  lBottomPanel.BevelOuter := bvNone;
  lBottomPanel.BorderSpacing.Around := 8;

  lCancelButton := TButton.Create(Self);
  lCancelButton.Parent := lBottomPanel;
  lCancelButton.Align := alRight;
  lCancelButton.Caption := 'Отмена';
  lCancelButton.ModalResult := mrCancel;
  lCancelButton.Cancel := True;
  lCancelButton.AutoSize := True;
  lCancelButton.BorderSpacing.Left := 8;

  fOkButton := TButton.Create(Self);
  fOkButton.Parent := lBottomPanel;
  fOkButton.Align := alRight;
  fOkButton.Caption := 'OK';
  fOkButton.ModalResult := mrOk;
  fOkButton.Default := True;
  fOkButton.AutoSize := True;

  fTagList := TListBox.Create(Self);
  fTagList.Parent := Self;
  fTagList.Align := alClient;
  fTagList.BorderSpacing.Left := 12;
  fTagList.BorderSpacing.Right := 12;
  fTagList.BorderSpacing.Top := 6;
  fTagList.BorderSpacing.Bottom := 6;
  fTagList.IntegralHeight := False;
  fTagList.OnDblClick := @TagListDblClick;

  RebuildList;
end;

function TRecorderTagPickerDialog.TagMatchesFilter(ATag: TRecorderTag;
  const AFilter: string): Boolean;
var
  lText: string;
begin
  Result := False;
  if ATag = nil then Exit;
  if fVectorOnly and not RecorderTagCanProvideBlocks(ATag) then Exit;
  if AFilter = '' then Exit(True);
  lText := UTF8LowerCase(ATag.Name + ' ' + ATag.Address + ' ' +
    ATag.Description);
  Result := Pos(AFilter, lText) > 0;
end;

procedure TRecorderTagPickerDialog.RebuildList;
var
  I, lSelectedIndex: Integer;
  lFilter: string;
  lTag: TRecorderTag;
begin
  lFilter := UTF8LowerCase(Trim(fSearchEdit.Text));
  lSelectedIndex := -1;
  fTagList.Items.BeginUpdate;
  try
    fTagList.Clear;
    if fRegistry = nil then Exit;
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      lTag := fRegistry.Tags[I];
      if not TagMatchesFilter(lTag, lFilter) then Continue;
      fTagList.Items.AddObject(lTag.Name, lTag);
      if SameText(lTag.Name, fInitialTagName) then
        lSelectedIndex := fTagList.Items.Count - 1;
    end;
    if lSelectedIndex >= 0 then
      fTagList.ItemIndex := lSelectedIndex
    else if fTagList.Items.Count > 0 then
      fTagList.ItemIndex := 0;
    fOkButton.Enabled := fTagList.ItemIndex >= 0;
  finally
    fTagList.Items.EndUpdate;
  end;
end;

procedure TRecorderTagPickerDialog.SearchChanged(Sender: TObject);
begin
  RebuildList;
end;

procedure TRecorderTagPickerDialog.TagListDblClick(Sender: TObject);
begin
  if SelectedTag <> nil then ModalResult := mrOk;
end;

function TRecorderTagPickerDialog.SelectedTag: TRecorderTag;
begin
  Result := nil;
  if (fTagList.ItemIndex >= 0) and
    (fTagList.ItemIndex < fTagList.Items.Count) then
    Result := TRecorderTag(fTagList.Items.Objects[fTagList.ItemIndex]);
end;

function ShowRecorderTagPickerDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const AInitialTagName: string;
  AVectorOnly: Boolean; out ASelectedTag: TRecorderTag): Boolean;
var
  lDialog: TRecorderTagPickerDialog;
begin
  Result := False;
  ASelectedTag := nil;
  lDialog := TRecorderTagPickerDialog.CreatePicker(AOwner, ARegistry,
    AInitialTagName, AVectorOnly);
  try
    if lDialog.ShowModal <> mrOk then Exit;
    ASelectedTag := lDialog.SelectedTag;
    Result := ASelectedTag <> nil;
  finally
    lDialog.Free;
  end;
end;

end.
