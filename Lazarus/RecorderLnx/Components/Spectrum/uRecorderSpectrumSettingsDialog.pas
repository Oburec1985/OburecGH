unit uRecorderSpectrumSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  LConvEncoding,
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, Dialogs, ExtCtrls,
  uRecorderFormModel, uRecorderTags, uRecorderSpectrumEngine;

function ShowRecorderSpectrumSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSpectrumComponent; ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

uses
  StrUtils, Math;

type
  TRecorderSpectrumSettingsDialog = class(TForm)
  private
    fComponent: TRecorderSpectrumComponent;
    fDraft: TRecorderSpectrumComponent;
    fTagRegistry: TRecorderTagRegistry;

    fAllAvailableTags: TStringList;
    fUsedAxisIndexes: TStringList;
    fEditingAxisIndex: Integer;
    fFilterEdit: TEdit;
    fAvailableList: TListBox;
    fUsedList: TListBox;
    fAddButton: TButton;
    fApplyButton: TButton;
    fRemoveButton: TButton;
    fNewAxisButton: TButton;
    fAxisCombo: TComboBox;

    fMinXEdit: TEdit;
    fMaxXEdit: TEdit;
    fMinYEdit: TEdit;
    fMaxYEdit: TEdit;
    fLgXCheck: TCheckBox;
    fLgYCheck: TCheckBox;
    fShowAlarmsCheck: TCheckBox;
    fShowWarningsCheck: TCheckBox;
    fShowProfileCheck: TCheckBox;
    fShowLabelsCheck: TCheckBox;
    fShowLegendCheck: TCheckBox;
    fZeroY0Check: TCheckBox;
    fResultTypeCombo: TComboBox;
    fValueModeGroup: TRadioGroup;
    fIntegrationGroup: TRadioGroup;

    fOkButton: TButton;
    fCancelButton: TButton;

    procedure BuildUi;
    procedure LoadFromComponent;
    procedure StoreToComponent;
    procedure OkButtonClick(Sender: TObject);
    function ParseFloatText(const AText: string; ADefault: Double): Double;
    function IsSpectrumTagSelectable(const ATagName: string): Boolean;
    function TagDisplayText(const ATagName: string): string;
    function DisplayItemTagName(AList: TListBox; AIndex: Integer): string;
    function UsedContainsTag(const ATagName: string): Boolean;

    procedure FilterEditChange(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure NewAxisButtonClick(Sender: TObject);
    procedure AxisComboChange(Sender: TObject);
    procedure RemoveButtonClick(Sender: TObject);
    procedure AvailableListDblClick(Sender: TObject);
    procedure UsedListDblClick(Sender: TObject);
    procedure UsedSelectionChange(Sender: TObject; User: Boolean);
    procedure UpdateAvailableList;
    procedure RefreshAxisCombo;
    procedure LoadAxisRange;
    procedure StoreAxisRange;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderSpectrumComponent; ATagRegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderSpectrumSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSpectrumComponent; ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderSpectrumSettingsDialog;
begin
  lDialog := TRecorderSpectrumSettingsDialog.CreateDialog(AOwner, AComponent, ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderSpectrumSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderSpectrumComponent; ATagRegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  
  fAllAvailableTags := TStringList.Create;
  fAllAvailableTags.Sorted := True;
  fAllAvailableTags.Duplicates := dupIgnore;
  fUsedAxisIndexes := TStringList.Create;
  fEditingAxisIndex := -1;

  fDraft := TRecorderSpectrumComponent.Create;
  fDraft.Assign(fComponent);

  Caption := 'Настройка спектрального графика - ' + AComponent.Name;
  BorderStyle := bsSizeable;
  Position := poOwnerFormCenter;
  ClientWidth := 710;
  ClientHeight := 625;
  Constraints.MinWidth := 710;
  Constraints.MinHeight := 625;

  BuildUi;
  LoadFromComponent;
end;

destructor TRecorderSpectrumSettingsDialog.Destroy;
begin
  fUsedAxisIndexes.Free;
  fAllAvailableTags.Free;
  fDraft.Free;
  inherited Destroy;
end;

function TRecorderSpectrumSettingsDialog.ParseFloatText(const AText: string;
  ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AText);
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(lText, ADefault);
end;

function TRecorderSpectrumSettingsDialog.IsSpectrumTagSelectable(
  const ATagName: string): Boolean;
var
  lTag: TRecorderTag;
begin
  Result := False;
  if (ATagName = '') or (fTagRegistry = nil) then
    Exit;
  lTag := fTagRegistry.FindByName(ATagName);
  Result := (lTag <> nil) and (lTag.PollFrequencyHz > 0.0);
end;

function TRecorderSpectrumSettingsDialog.TagDisplayText(
  const ATagName: string): string;
var
  lTag: TRecorderTag;
begin
  Result := ATagName;
  if fTagRegistry = nil then
    Exit;
  lTag := fTagRegistry.FindByName(ATagName);
  if lTag <> nil then
    Result := Format('%s (%.6g Hz)', [ATagName, lTag.PollFrequencyHz]);
end;

function TRecorderSpectrumSettingsDialog.DisplayItemTagName(AList: TListBox;
  AIndex: Integer): string;
begin
  Result := '';
  if (AList = nil) or (AIndex < 0) or (AIndex >= AList.Items.Count) then
    Exit;
  if AList.Items.Objects[AIndex] is TRecorderTag then
    Result := TRecorderTag(AList.Items.Objects[AIndex]).Name
  else
    Result := AList.Items[AIndex];
end;

function TRecorderSpectrumSettingsDialog.UsedContainsTag(
  const ATagName: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to fUsedList.Items.Count - 1 do
    if SameText(DisplayItemTagName(fUsedList, I), ATagName) then
      Exit(True);
  Result := False;
end;

procedure TRecorderSpectrumSettingsDialog.BuildUi;
var
  lLabel: TLabel;
  lGroupBox: TGroupBox;
  I, J: Integer;
  lNode: TRecorderSpectrumConfigNode;
begin
  // Заполняем fAllAvailableTags из SpectrumConfigs
  if (fTagRegistry <> nil) and (fTagRegistry.SpectrumConfigs <> nil) then
  begin
    for I := 0 to fTagRegistry.SpectrumConfigs.NodeCount - 1 do
    begin
      lNode := fTagRegistry.SpectrumConfigs.Nodes[I];
      for J := 0 to lNode.BindingCount - 1 do
        if IsSpectrumTagSelectable(lNode.Bindings[J].SourceTagName) then
          fAllAvailableTags.Add(lNode.Bindings[J].SourceTagName);
    end;
  end;

  // 1. Доступные теги
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 12, 200, 15);
  lLabel.Caption := 'Доступные теги (спектры):';

  fFilterEdit := TEdit.Create(Self);
  fFilterEdit.Parent := Self;
  fFilterEdit.SetBounds(12, 30, 200, 23);
  fFilterEdit.Anchors := [akLeft, akTop, akRight];
  fFilterEdit.OnChange := @FilterEditChange;

  fAvailableList := TListBox.Create(Self);
  fAvailableList.Parent := Self;
  fAvailableList.SetBounds(12, 60, 200, 400);
  fAvailableList.Anchors := [akLeft, akTop, akRight, akBottom];
  fAvailableList.MultiSelect := True;
  fAvailableList.OnDblClick := @AvailableListDblClick;

  // 2. Кнопки переноса
  fAddButton := TButton.Create(Self);
  fAddButton.Parent := Self;
  fAddButton.SetBounds(220, 180, 36, 25);
  fAddButton.Anchors := [akTop, akRight];
  fAddButton.Caption := '+';
  fAddButton.Hint := 'Добавить выбранный тег как новую линию';
  fAddButton.ShowHint := True;
  fAddButton.OnClick := @AddButtonClick;

  fRemoveButton := TButton.Create(Self);
  fRemoveButton.Parent := Self;
  fRemoveButton.SetBounds(220, 215, 36, 25);
  fRemoveButton.Anchors := [akTop, akRight];
  fRemoveButton.Caption := '<<';
  fRemoveButton.OnClick := @RemoveButtonClick;

  // 3. Отображаемые теги
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(262, 12, 200, 15);
  lLabel.Caption := 'Отображаемые теги:';

  fUsedList := TListBox.Create(Self);
  fUsedList.Parent := Self;
  fUsedList.SetBounds(262, 60, 200, 335);
  fUsedList.Anchors := [akTop, akRight, akBottom];
  fUsedList.MultiSelect := False;
  fUsedList.OnDblClick := @UsedListDblClick;
  fUsedList.OnSelectionChange := @UsedSelectionChange;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(262, 402, 75, 15);
  lLabel.Caption := 'Ось линии:';

  fAxisCombo := TComboBox.Create(Self);
  fAxisCombo.Parent := Self;
  fAxisCombo.SetBounds(337, 398, 125, 23);
  fAxisCombo.Style := csDropDownList;
  fAxisCombo.OnChange := @AxisComboChange;

  fApplyButton := TButton.Create(Self);
  fApplyButton.Parent := Self;
  fApplyButton.SetBounds(262, 428, 95, 27);
  fApplyButton.Caption := 'Применить';
  fApplyButton.Hint := 'Заменить тег и ось выбранной линии';
  fApplyButton.ShowHint := True;
  fApplyButton.OnClick := @ApplyButtonClick;

  fNewAxisButton := TButton.Create(Self);
  fNewAxisButton.Parent := Self;
  fNewAxisButton.SetBounds(365, 428, 97, 27);
  fNewAxisButton.Caption := 'Новая ось';
  fNewAxisButton.Hint := 'Создать новую Y-ось и выбрать её для линии';
  fNewAxisButton.ShowHint := True;
  fNewAxisButton.OnClick := @NewAxisButtonClick;

  // 4. Параметры осей
  lGroupBox := TGroupBox.Create(Self);
  lGroupBox.Parent := Self;
  lGroupBox.SetBounds(478, 24, 220, 180);
  lGroupBox.Anchors := [akTop, akRight];
  lGroupBox.Caption := 'Настройка осей';

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 20, 80, 15);
  lLabel.Caption := 'Мин X (Гц):';

  fMinXEdit := TEdit.Create(lGroupBox);
  fMinXEdit.Parent := lGroupBox;
  fMinXEdit.SetBounds(100, 17, 100, 23);

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 50, 80, 15);
  lLabel.Caption := 'Макс X (Гц):';

  fMaxXEdit := TEdit.Create(lGroupBox);
  fMaxXEdit.Parent := lGroupBox;
  fMaxXEdit.SetBounds(100, 47, 100, 23);

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 80, 80, 15);
  lLabel.Caption := 'Мин Y:';

  fMinYEdit := TEdit.Create(lGroupBox);
  fMinYEdit.Parent := lGroupBox;
  fMinYEdit.SetBounds(100, 77, 100, 23);

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 110, 80, 15);
  lLabel.Caption := 'Макс Y:';

  fMaxYEdit := TEdit.Create(lGroupBox);
  fMaxYEdit.Parent := lGroupBox;
  fMaxYEdit.SetBounds(100, 107, 100, 23);

  fLgXCheck := TCheckBox.Create(lGroupBox);
  fLgXCheck.Parent := lGroupBox;
  fLgXCheck.SetBounds(10, 137, 90, 20);
  fLgXCheck.Caption := 'Лог X';

  fLgYCheck := TCheckBox.Create(lGroupBox);
  fLgYCheck.Parent := lGroupBox;
  fLgYCheck.SetBounds(110, 137, 90, 20);
  fLgYCheck.Caption := 'Лог Y';

  // 5. Параметры отображения
  lGroupBox := TGroupBox.Create(Self);
  lGroupBox.Parent := Self;
  lGroupBox.SetBounds(478, 215, 220, 330);
  lGroupBox.Anchors := [akTop, akRight, akBottom];
  lGroupBox.Caption := 'Отображение';

  fShowAlarmsCheck := TCheckBox.Create(lGroupBox);
  fShowAlarmsCheck.Parent := lGroupBox;
  fShowAlarmsCheck.SetBounds(10, 20, 180, 20);
  fShowAlarmsCheck.Caption := 'Аварийные уровни';

  fShowWarningsCheck := TCheckBox.Create(lGroupBox);
  fShowWarningsCheck.Parent := lGroupBox;
  fShowWarningsCheck.SetBounds(10, 45, 180, 20);
  fShowWarningsCheck.Caption := 'Предупредительные';

  fShowProfileCheck := TCheckBox.Create(lGroupBox);
  fShowProfileCheck.Parent := lGroupBox;
  fShowProfileCheck.SetBounds(10, 70, 180, 20);
  fShowProfileCheck.Caption := 'Профили';

  fShowLabelsCheck := TCheckBox.Create(lGroupBox);
  fShowLabelsCheck.Parent := lGroupBox;
  fShowLabelsCheck.SetBounds(10, 95, 180, 20);
  fShowLabelsCheck.Caption := 'Метки пиков';

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  fShowLegendCheck := TCheckBox.Create(lGroupBox);
  fShowLegendCheck.Parent := lGroupBox;
  fShowLegendCheck.SetBounds(10, 120, 180, 20);
  fShowLegendCheck.Caption := 'Легенда';

  fZeroY0Check := TCheckBox.Create(lGroupBox);
  fZeroY0Check.Parent := lGroupBox;
  fZeroY0Check.SetBounds(10, 145, 180, 20);
  fZeroY0Check.Caption := 'Занулять Y0';

  lLabel.SetBounds(10, 175, 80, 15);
  lLabel.Caption := 'Результат:';

  fResultTypeCombo := TComboBox.Create(lGroupBox);
  fResultTypeCombo.Parent := lGroupBox;
  fResultTypeCombo.SetBounds(90, 172, 120, 23);
  fResultTypeCombo.Style := csDropDownList;
  fResultTypeCombo.Items.Add('Амплитуда');
  fResultTypeCombo.Items.Add('Фаза');
  fResultTypeCombo.Items.Add('Re / Im (две линии)');

  fValueModeGroup := TRadioGroup.Create(lGroupBox);
  fValueModeGroup.Parent := lGroupBox;
  fValueModeGroup.SetBounds(10, 202, 200, 57);
  fValueModeGroup.Caption := 'Значения спектра';
  fValueModeGroup.Columns := 2;
  fValueModeGroup.Items.Add('RMS');
  fValueModeGroup.Items.Add('Амплитуда');

  fIntegrationGroup := TRadioGroup.Create(lGroupBox);
  fIntegrationGroup.Parent := lGroupBox;
  fIntegrationGroup.SetBounds(10, 262, 200, 62);
  fIntegrationGroup.Caption := 'Интегрирование ускорения';
  fIntegrationGroup.Items.Add('Без интегрирования');
  fIntegrationGroup.Items.Add('Однократное (скорость)');
  fIntegrationGroup.Items.Add('Двукратное (перемещение)');

  // 6. Кнопки ОК / Отмена
  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(520, 585, 80, 25);
  fOkButton.Anchors := [akRight, akBottom];
  fOkButton.Caption := 'ОК';
  fOkButton.Default := True;
  fOkButton.OnClick := @OkButtonClick;

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(615, 585, 80, 25);
  fCancelButton.Anchors := [akRight, akBottom];
  fCancelButton.Caption := 'Отмена';
  fCancelButton.Cancel := True;
  fCancelButton.ModalResult := mrCancel;
end;

procedure TRecorderSpectrumSettingsDialog.LoadFromComponent;
var
  I: Integer;
begin
  RefreshAxisCombo;
  fMinXEdit.Text := FloatToStr(fDraft.RangeMinX);
  fMaxXEdit.Text := FloatToStr(fDraft.RangeMaxX);
  fMinYEdit.Text := FloatToStr(fDraft.RangeMinY);
  fMaxYEdit.Text := FloatToStr(fDraft.RangeMaxY);
  LoadAxisRange;

  fLgXCheck.Checked := fDraft.LgX;
  fLgYCheck.Checked := fDraft.LgY;
  fShowAlarmsCheck.Checked := fDraft.ShowAlarms;
  fShowWarningsCheck.Checked := fDraft.ShowWarnings;
  fShowProfileCheck.Checked := fDraft.ShowProfile;
  fShowLabelsCheck.Checked := fDraft.ShowLabels;
  fShowLegendCheck.Checked := fDraft.LegendVisible;
  fZeroY0Check.Checked := fDraft.ZeroY0;

  if (fDraft.ResultType >= 0) and (fDraft.ResultType < fResultTypeCombo.Items.Count) then
    fResultTypeCombo.ItemIndex := fDraft.ResultType
  else
    fResultTypeCombo.ItemIndex := 0;

  if (fDraft.SpectrumIntegration >= 0) and
    (fDraft.SpectrumIntegration < fIntegrationGroup.Items.Count) then
    fIntegrationGroup.ItemIndex := fDraft.SpectrumIntegration
  else
    fIntegrationGroup.ItemIndex := 0;

  if (fDraft.SpectrumValueMode >= 0) and
    (fDraft.SpectrumValueMode < fValueModeGroup.Items.Count) then
    fValueModeGroup.ItemIndex := fDraft.SpectrumValueMode
  else
    fValueModeGroup.ItemIndex := 0;

  // Заполняем список используемых
  fUsedList.Items.Clear;
  fUsedAxisIndexes.Clear;
  for I := 0 to fDraft.TagNames.Count - 1 do
    if IsSpectrumTagSelectable(fDraft.TagNames[I]) then
    begin
      fUsedList.Items.AddObject(TagDisplayText(fDraft.TagNames[I]),
        fTagRegistry.FindByName(fDraft.TagNames[I]));
      fUsedAxisIndexes.Add(IntToStr(fDraft.TagAxisIndexAt(I)));
    end;

  if fUsedList.Count > 0 then
  begin
    fUsedList.ItemIndex := 0;
    UsedSelectionChange(fUsedList, False);
  end;

  UpdateAvailableList;
end;

procedure TRecorderSpectrumSettingsDialog.StoreToComponent;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  StoreAxisRange;
  fDraft.RangeMinX := ParseFloatText(fMinXEdit.Text, fDraft.RangeMinX);
  fDraft.RangeMaxX := ParseFloatText(fMaxXEdit.Text, fDraft.RangeMaxX);
  if fDraft.AxisCount > 0 then
  begin
    fDraft.RangeMinY := fDraft.Axes[0].RangeMin;
    fDraft.RangeMaxY := fDraft.Axes[0].RangeMax;
  end;

  fDraft.LgX := fLgXCheck.Checked;
  fDraft.LgY := fLgYCheck.Checked;
  fDraft.ShowAlarms := fShowAlarmsCheck.Checked;
  fDraft.ShowWarnings := fShowWarningsCheck.Checked;
  fDraft.ShowProfile := fShowProfileCheck.Checked;
  fDraft.ShowLabels := fShowLabelsCheck.Checked;
  fDraft.LegendVisible := fShowLegendCheck.Checked;
  fDraft.ZeroY0 := fZeroY0Check.Checked;

  fDraft.ResultType := fResultTypeCombo.ItemIndex;
  fDraft.SpectrumValueMode := fValueModeGroup.ItemIndex;
  fDraft.SpectrumIntegration := fIntegrationGroup.ItemIndex;

  { Имя в строке списка содержит частоту только для показа. Ссылку сохраняем
    одной операцией как согласованную пару TagId + TagName; иначе старый TagId
    (обычно MemTag) оставался на том же индексе после замены имени. }
  fDraft.TagNames.Clear;
  fDraft.ClearTagRefs;
  for I := 0 to fUsedList.Count - 1 do
  begin
    lTag := nil;
    if fUsedList.Items.Objects[I] is TRecorderTag then
      lTag := TRecorderTag(fUsedList.Items.Objects[I]);
    if (lTag = nil) and (fTagRegistry <> nil) then
      lTag := fTagRegistry.FindByName(DisplayItemTagName(fUsedList, I));
    if lTag <> nil then
    begin
      fDraft.SetTagRefAt(fDraft.TagNames.Count, lTag);
      if I < fUsedAxisIndexes.Count then
        fDraft.SetTagAxisIndexAt(fDraft.TagNames.Count - 1,
          StrToIntDef(fUsedAxisIndexes[I], 0));
    end;
  end;
end;

procedure TRecorderSpectrumSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToComponent;
  fComponent.Assign(fDraft);
  ModalResult := mrOk;
end;

procedure TRecorderSpectrumSettingsDialog.FilterEditChange(Sender: TObject);
begin
  UpdateAvailableList;
end;

procedure TRecorderSpectrumSettingsDialog.AddButtonClick(Sender: TObject);
var
  I, lAxisIndex, lLastAddedIndex: Integer;
  lTagName: string;
  lChanged: Boolean;
begin
  lChanged := False;
  lLastAddedIndex := -1;
  lAxisIndex := fAxisCombo.ItemIndex;
  if lAxisIndex < 0 then
    lAxisIndex := 0;
  for I := 0 to fAvailableList.Count - 1 do
  begin
    if fAvailableList.Selected[I] then
    begin
      lTagName := DisplayItemTagName(fAvailableList, I);
      if not UsedContainsTag(lTagName) then
      begin
        fUsedList.Items.AddObject(TagDisplayText(lTagName), fTagRegistry.FindByName(lTagName));
        fUsedAxisIndexes.Add(IntToStr(lAxisIndex));
        lLastAddedIndex := fUsedList.Count - 1;
        lChanged := True;
      end;
    end;
  end;
  if lChanged then
  begin
    fUsedList.ItemIndex := lLastAddedIndex;
    UsedSelectionChange(fUsedList, False);
    UpdateAvailableList;
  end;
end;

procedure TRecorderSpectrumSettingsDialog.RemoveButtonClick(Sender: TObject);
var
  I: Integer;
  lChanged: Boolean;
begin
  lChanged := False;
  for I := fUsedList.Count - 1 downto 0 do
  begin
    if fUsedList.Selected[I] then
    begin
      fUsedList.Items.Delete(I);
      if I < fUsedAxisIndexes.Count then
        fUsedAxisIndexes.Delete(I);
      lChanged := True;
    end;
  end;
  if lChanged then
    UpdateAvailableList;
end;

procedure TRecorderSpectrumSettingsDialog.AvailableListDblClick(Sender: TObject);
begin
  { Выбор — только черновик. Изменение списка выполняют явные кнопки. }
end;

procedure TRecorderSpectrumSettingsDialog.UsedListDblClick(Sender: TObject);
var
  lIdx: Integer;
begin
  lIdx := fUsedList.ItemIndex;
  if (lIdx >= 0) and (lIdx < fUsedAxisIndexes.Count) then
  begin
    fAxisCombo.ItemIndex := StrToIntDef(fUsedAxisIndexes[lIdx], 0);
    LoadAxisRange;
  end;
end;

procedure TRecorderSpectrumSettingsDialog.UsedSelectionChange(Sender: TObject;
  User: Boolean);
begin
  UsedListDblClick(Sender);
end;

procedure TRecorderSpectrumSettingsDialog.ApplyButtonClick(Sender: TObject);
var
  lLineIndex, lTagIndex: Integer;
  lTagName: string;
begin
  lLineIndex := fUsedList.ItemIndex;
  lTagIndex := fAvailableList.ItemIndex;
  if lLineIndex < 0 then
    Exit;
  if lTagIndex >= 0 then
  begin
    lTagName := DisplayItemTagName(fAvailableList, lTagIndex);
    fUsedList.Items[lLineIndex] := TagDisplayText(lTagName);
    fUsedList.Items.Objects[lLineIndex] := fTagRegistry.FindByName(lTagName);
  end;
  if lLineIndex < fUsedAxisIndexes.Count then
    fUsedAxisIndexes[lLineIndex] := IntToStr(Max(0, fAxisCombo.ItemIndex));
  UpdateAvailableList;
end;

procedure TRecorderSpectrumSettingsDialog.NewAxisButtonClick(Sender: TObject);
var
  lAxis: TRecorderTrendAxis;
  lLineIndex, lSourceAxisIndex: Integer;
  lRangeMin, lRangeMax: Double;
begin
  StoreAxisRange;
  lSourceAxisIndex := fEditingAxisIndex;
  if (lSourceAxisIndex < 0) or (lSourceAxisIndex >= fDraft.AxisCount) then
    lSourceAxisIndex := 0;
  lRangeMin := fDraft.Axes[lSourceAxisIndex].RangeMin;
  lRangeMax := fDraft.Axes[lSourceAxisIndex].RangeMax;
  lAxis := fDraft.AddAxis;
  lAxis.Name := 'Y' + IntToStr(fDraft.AxisCount);
  lAxis.RangeMin := lRangeMin;
  lAxis.RangeMax := lRangeMax;
  RefreshAxisCombo;
  fAxisCombo.ItemIndex := fDraft.AxisCount - 1;
  lLineIndex := fUsedList.ItemIndex;
  if (lLineIndex >= 0) and (lLineIndex < fUsedAxisIndexes.Count) then
    fUsedAxisIndexes[lLineIndex] := IntToStr(fAxisCombo.ItemIndex);
  LoadAxisRange;
end;

procedure TRecorderSpectrumSettingsDialog.AxisComboChange(Sender: TObject);
begin
  LoadAxisRange;
end;

procedure TRecorderSpectrumSettingsDialog.RefreshAxisCombo;
var
  I, lOldIndex: Integer;
begin
  lOldIndex := fAxisCombo.ItemIndex;
  fAxisCombo.Items.Clear;
  for I := 0 to fDraft.AxisCount - 1 do
    fAxisCombo.Items.Add(fDraft.Axes[I].Name);
  if fAxisCombo.Items.Count = 0 then
    fDraft.AddAxis;
  if (lOldIndex < 0) or (lOldIndex >= fAxisCombo.Items.Count) then
    lOldIndex := 0;
  fAxisCombo.ItemIndex := lOldIndex;
end;

procedure TRecorderSpectrumSettingsDialog.LoadAxisRange;
var
  lIndex: Integer;
begin
  lIndex := fAxisCombo.ItemIndex;
  if (lIndex < 0) or (lIndex >= fDraft.AxisCount) then
    Exit;
  if lIndex <> fEditingAxisIndex then
    StoreAxisRange;
  fEditingAxisIndex := lIndex;
  fMinYEdit.Text := FloatToStr(fDraft.Axes[lIndex].RangeMin);
  fMaxYEdit.Text := FloatToStr(fDraft.Axes[lIndex].RangeMax);
end;

procedure TRecorderSpectrumSettingsDialog.StoreAxisRange;
var
  lIndex: Integer;
begin
  lIndex := fEditingAxisIndex;
  if (lIndex < 0) or (lIndex >= fDraft.AxisCount) then
    Exit;
  fDraft.Axes[lIndex].RangeMin := ParseFloatText(fMinYEdit.Text,
    fDraft.Axes[lIndex].RangeMin);
  fDraft.Axes[lIndex].RangeMax := ParseFloatText(fMaxYEdit.Text,
    fDraft.Axes[lIndex].RangeMax);
  if lIndex = 0 then
  begin
    fDraft.RangeMinY := fDraft.Axes[0].RangeMin;
    fDraft.RangeMaxY := fDraft.Axes[0].RangeMax;
  end;
end;

procedure TRecorderSpectrumSettingsDialog.UpdateAvailableList;
var
  I: Integer;
  lTagName: string;
  lFilter: string;
begin
  fAvailableList.Items.BeginUpdate;
  try
    fAvailableList.Items.Clear;
    lFilter := AnsiLowerCase(Trim(fFilterEdit.Text));
    for I := 0 to fAllAvailableTags.Count - 1 do
    begin
      lTagName := fAllAvailableTags[I];
      
      // Исключаем те, что уже выбраны
      if UsedContainsTag(lTagName) then
        Continue;
        
      // Фильтруем по подстроке
      if (lFilter = '') or (AnsiContainsText(AnsiLowerCase(lTagName), lFilter)) or
        (AnsiContainsText(AnsiLowerCase(TagDisplayText(lTagName)), lFilter)) then
        fAvailableList.Items.AddObject(TagDisplayText(lTagName), fTagRegistry.FindByName(lTagName));
    end;
  finally
    fAvailableList.Items.EndUpdate;
  end;
end;

end.
