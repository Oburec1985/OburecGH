unit uRecorderDonutSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Spin, LazUTF8, Dialogs,
  uRecorderFormModel, uRecorderTags;

function ShowRecorderDonutSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderDonutComponent; ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

type
  TRecorderDonutSettingsDialog = class(TForm)
  private
    fComponent: TRecorderDonutComponent;
    fRegistry: TRecorderTagRegistry;
    fTitleEdit: TEdit;
    fHoleEdit: TSpinEdit;
    fSingleModeCheck: TCheckBox;
    fSingleTagLabel: TLabel;
    fSingleTagEdit: TEdit;
    fRangeMinLabel: TLabel;
    fRangeMinEdit: TEdit;
    fRangeMaxLabel: TLabel;
    fRangeMaxEdit: TEdit;
    fAddButton: TButton;
    fRemoveButton: TButton;
    fFilterEdit: TEdit;
    fAvailable: TListBox;
    fSelected: TListBox;
    procedure UpdateAvailable(Sender: TObject);
    procedure AddTag(Sender: TObject);
    procedure RemoveTag(Sender: TObject);
    procedure ApplySettings(Sender: TObject);
    procedure ModeChanged(Sender: TObject);
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderDonutComponent; ARegistry: TRecorderTagRegistry);
  end;

function ShowRecorderDonutSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderDonutComponent; ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderDonutSettingsDialog;
begin
  lDialog := TRecorderDonutSettingsDialog.CreateDialog(AOwner, AComponent,
    ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderDonutSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderDonutComponent; ARegistry: TRecorderTagRegistry);
var
  lLabel: TLabel;
  lButton: TButton;
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fRegistry := ARegistry;
  Caption := 'Настройка круговой гистограммы';
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 540;
  ClientHeight := 390;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 14, 100, 20);
  lLabel.Caption := 'Заголовок:';
  fTitleEdit := TEdit.Create(Self);
  fTitleEdit.Parent := Self;
  fTitleEdit.SetBounds(110, 10, 290, 25);
  fTitleEdit.Text := AComponent.Title;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 47, 160, 20);
  lLabel.Caption := 'Отверстие, %:';
  fHoleEdit := TSpinEdit.Create(Self);
  fHoleEdit.Parent := Self;
  fHoleEdit.SetBounds(170, 43, 70, 25);
  fHoleEdit.MinValue := 10;
  fHoleEdit.MaxValue := 80;
  fHoleEdit.Value := AComponent.HolePercent;

  fSingleModeCheck := TCheckBox.Create(Self);
  fSingleModeCheck.Parent := Self;
  fSingleModeCheck.SetBounds(12, 78, 300, 25);
  fSingleModeCheck.Caption := 'Один тег — текущее значение';
  fSingleModeCheck.Checked := AComponent.SingleValueMode;
  fSingleModeCheck.OnChange := @ModeChanged;

  fFilterEdit := TEdit.Create(Self);
  fFilterEdit.Parent := Self;
  fFilterEdit.SetBounds(12, 110, 210, 25);
  fFilterEdit.TextHint := 'Поиск тега';
  fFilterEdit.OnChange := @UpdateAvailable;
  fAvailable := TListBox.Create(Self);
  fAvailable.Parent := Self;
  fAvailable.SetBounds(12, 140, 210, 192);
  fAvailable.OnDblClick := @AddTag;
  fSelected := TListBox.Create(Self);
  fSelected.Parent := Self;
  fSelected.SetBounds(315, 140, 210, 192);
  fSelected.Items.Assign(AComponent.TagNames);
  fSelected.OnDblClick := @RemoveTag;

  fAddButton := TButton.Create(Self);
  fAddButton.Parent := Self;
  fAddButton.SetBounds(232, 170, 72, 28);
  fAddButton.Caption := 'Добавить';
  fAddButton.OnClick := @AddTag;
  fRemoveButton := TButton.Create(Self);
  fRemoveButton.Parent := Self;
  fRemoveButton.SetBounds(232, 208, 72, 28);
  fRemoveButton.Caption := 'Удалить';
  fRemoveButton.OnClick := @RemoveTag;

  fSingleTagLabel := TLabel.Create(Self);
  fSingleTagLabel.Parent := Self;
  fSingleTagLabel.SetBounds(315, 110, 210, 20);
  fSingleTagLabel.Caption := 'Тег одного значения:';
  fSingleTagEdit := TEdit.Create(Self);
  fSingleTagEdit.Parent := Self;
  fSingleTagEdit.SetBounds(315, 140, 210, 25);
  fSingleTagEdit.Text := AComponent.TagName;
  fRangeMinLabel := TLabel.Create(Self);
  fRangeMinLabel.Parent := Self;
  fRangeMinLabel.SetBounds(315, 178, 85, 20);
  fRangeMinLabel.Caption := 'Минимум:';
  fRangeMinEdit := TEdit.Create(Self);
  fRangeMinEdit.Parent := Self;
  fRangeMinEdit.SetBounds(405, 174, 120, 25);
  fRangeMinEdit.Text := FloatToStr(AComponent.RangeMin);
  fRangeMaxLabel := TLabel.Create(Self);
  fRangeMaxLabel.Parent := Self;
  fRangeMaxLabel.SetBounds(315, 212, 85, 20);
  fRangeMaxLabel.Caption := 'Максимум:';
  fRangeMaxEdit := TEdit.Create(Self);
  fRangeMaxEdit.Parent := Self;
  fRangeMaxEdit.SetBounds(405, 208, 120, 25);
  fRangeMaxEdit.Text := FloatToStr(AComponent.RangeMax);
  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(360, 348, 78, 28);
  lButton.Caption := 'OK';
  lButton.OnClick := @ApplySettings;
  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(447, 348, 78, 28);
  lButton.Caption := 'Отмена';
  lButton.ModalResult := mrCancel;
  UpdateAvailable(nil);
  ModeChanged(nil);
end;

procedure TRecorderDonutSettingsDialog.ModeChanged(Sender: TObject);
var
  lSingle: Boolean;
begin
  lSingle := fSingleModeCheck.Checked;
  fSelected.Visible := not lSingle;
  fRemoveButton.Visible := not lSingle;
  fSingleTagLabel.Visible := lSingle;
  fSingleTagEdit.Visible := lSingle;
  fRangeMinLabel.Visible := lSingle;
  fRangeMinEdit.Visible := lSingle;
  fRangeMaxLabel.Visible := lSingle;
  fRangeMaxEdit.Visible := lSingle;
  fAddButton.Caption := 'Выбрать';
  if not lSingle then
    fAddButton.Caption := 'Добавить';
end;

procedure TRecorderDonutSettingsDialog.UpdateAvailable(Sender: TObject);
var
  I: Integer;
  lName: string;
begin
  fAvailable.Items.BeginUpdate;
  try
    fAvailable.Clear;
    if fRegistry = nil then Exit;
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      lName := fRegistry.Tags[I].Name;
      if (fFilterEdit.Text = '') or
        (Pos(UTF8LowerCase(fFilterEdit.Text), UTF8LowerCase(lName)) > 0) then
        fAvailable.Items.Add(lName);
      if (fFilterEdit.Text = '') and (fAvailable.Items.Count >= 200) then
        Break;
    end;
  finally
    fAvailable.Items.EndUpdate;
  end;
end;

procedure TRecorderDonutSettingsDialog.AddTag(Sender: TObject);
var
  lName: string;
begin
  if fAvailable.ItemIndex < 0 then Exit;
  lName := fAvailable.Items[fAvailable.ItemIndex];
  if fSingleModeCheck.Checked then
  begin
    fSingleTagEdit.Text := lName;
    Exit;
  end;
  if fSelected.Items.IndexOf(lName) < 0 then
    fSelected.Items.Add(lName);
end;

procedure TRecorderDonutSettingsDialog.RemoveTag(Sender: TObject);
begin
  if fSelected.ItemIndex >= 0 then
    fSelected.Items.Delete(fSelected.ItemIndex);
end;

procedure TRecorderDonutSettingsDialog.ApplySettings(Sender: TObject);
var
  I: Integer;
  lMin, lMax: Double;
  lTag: TRecorderTag;
begin
  if fSingleModeCheck.Checked then
  begin
    if (not TryStrToFloat(StringReplace(Trim(fRangeMinEdit.Text), '.',
      DecimalSeparator, [rfReplaceAll]), lMin)) or
      (not TryStrToFloat(StringReplace(Trim(fRangeMaxEdit.Text), '.',
      DecimalSeparator, [rfReplaceAll]), lMax)) then
    begin
      MessageDlg('Введите числовой минимум и максимум.', mtError, [mbOK], 0);
      Exit;
    end;
    if lMax <= lMin then
    begin
      MessageDlg('Максимум должен быть больше минимума.', mtError, [mbOK], 0);
      Exit;
    end;
    lTag := nil;
    if fRegistry <> nil then
      lTag := fRegistry.FindByName(Trim(fSingleTagEdit.Text));
    if lTag = nil then
    begin
      MessageDlg('Выберите существующий тег.', mtError, [mbOK], 0);
      Exit;
    end;
    fComponent.TagName := lTag.Name;
    fComponent.TagId := lTag.Id;
  end;
  if not fSingleModeCheck.Checked then
  begin
    lMin := fComponent.RangeMin;
    lMax := fComponent.RangeMax;
  end;
  fComponent.Title := Trim(fTitleEdit.Text);
  fComponent.HolePercent := fHoleEdit.Value;
  fComponent.SingleValueMode := fSingleModeCheck.Checked;
  fComponent.RangeMin := lMin;
  fComponent.RangeMax := lMax;
  fComponent.TagNames.Assign(fSelected.Items);
  for I := 0 to fComponent.TagNames.Count - 1 do
    fComponent.SetTagIdAt(I, 0);
  ModalResult := mrOk;
end;

end.
