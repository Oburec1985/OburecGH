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
  StrUtils;

type
  TRecorderSpectrumSettingsDialog = class(TForm)
  private
    fComponent: TRecorderSpectrumComponent;
    fDraft: TRecorderSpectrumComponent;
    fTagRegistry: TRecorderTagRegistry;

    fAllAvailableTags: TStringList;
    fFilterEdit: TEdit;
    fAvailableList: TListBox;
    fUsedList: TListBox;
    fAddButton: TButton;
    fRemoveButton: TButton;

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
    fTahoCombo: TComboBox;

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

    procedure FilterEditChange(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure RemoveButtonClick(Sender: TObject);
    procedure AvailableListDblClick(Sender: TObject);
    procedure UsedListDblClick(Sender: TObject);
    procedure UpdateAvailableList;
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

  fDraft := TRecorderSpectrumComponent.Create;
  fDraft.Assign(fComponent);

  Caption := CP1251ToUTF8('Настройка спектрального графика - ') + AComponent.Name;
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 710;
  ClientHeight := 555;

  BuildUi;
  LoadFromComponent;
end;

destructor TRecorderSpectrumSettingsDialog.Destroy;
begin
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
  lText := StringReplace(lText, '.', DecimalSeparator, [rfReplaceAll]);
  lText := StringReplace(lText, ',', DecimalSeparator, [rfReplaceAll]);
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
  lLabel.Caption := CP1251ToUTF8('Доступные теги (спектры):');

  fFilterEdit := TEdit.Create(Self);
  fFilterEdit.Parent := Self;
  fFilterEdit.SetBounds(12, 30, 200, 23);
  fFilterEdit.OnChange := @FilterEditChange;

  fAvailableList := TListBox.Create(Self);
  fAvailableList.Parent := Self;
  fAvailableList.SetBounds(12, 60, 200, 400);
  fAvailableList.MultiSelect := True;
  fAvailableList.OnDblClick := @AvailableListDblClick;

  // 2. Кнопки переноса
  fAddButton := TButton.Create(Self);
  fAddButton.Parent := Self;
  fAddButton.SetBounds(220, 180, 36, 25);
  fAddButton.Caption := '>>';
  fAddButton.OnClick := @AddButtonClick;

  fRemoveButton := TButton.Create(Self);
  fRemoveButton.Parent := Self;
  fRemoveButton.SetBounds(220, 215, 36, 25);
  fRemoveButton.Caption := '<<';
  fRemoveButton.OnClick := @RemoveButtonClick;

  // 3. Отображаемые теги
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(262, 12, 200, 15);
  lLabel.Caption := CP1251ToUTF8('Отображаемые теги:');

  fUsedList := TListBox.Create(Self);
  fUsedList.Parent := Self;
  fUsedList.SetBounds(262, 60, 200, 400);
  fUsedList.MultiSelect := True;
  fUsedList.OnDblClick := @UsedListDblClick;

  // 4. Параметры осей
  lGroupBox := TGroupBox.Create(Self);
  lGroupBox.Parent := Self;
  lGroupBox.SetBounds(478, 24, 220, 180);
  lGroupBox.Caption := CP1251ToUTF8('Настройка осей');

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 20, 80, 15);
  lLabel.Caption := CP1251ToUTF8('Мин X (Гц):');

  fMinXEdit := TEdit.Create(lGroupBox);
  fMinXEdit.Parent := lGroupBox;
  fMinXEdit.SetBounds(100, 17, 100, 23);

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 50, 80, 15);
  lLabel.Caption := CP1251ToUTF8('Макс X (Гц):');

  fMaxXEdit := TEdit.Create(lGroupBox);
  fMaxXEdit.Parent := lGroupBox;
  fMaxXEdit.SetBounds(100, 47, 100, 23);

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 80, 80, 15);
  lLabel.Caption := CP1251ToUTF8('Мин Y:');

  fMinYEdit := TEdit.Create(lGroupBox);
  fMinYEdit.Parent := lGroupBox;
  fMinYEdit.SetBounds(100, 77, 100, 23);

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  lLabel.SetBounds(10, 110, 80, 15);
  lLabel.Caption := CP1251ToUTF8('Макс Y:');

  fMaxYEdit := TEdit.Create(lGroupBox);
  fMaxYEdit.Parent := lGroupBox;
  fMaxYEdit.SetBounds(100, 107, 100, 23);

  fLgXCheck := TCheckBox.Create(lGroupBox);
  fLgXCheck.Parent := lGroupBox;
  fLgXCheck.SetBounds(10, 137, 90, 20);
  fLgXCheck.Caption := CP1251ToUTF8('Лог X');

  fLgYCheck := TCheckBox.Create(lGroupBox);
  fLgYCheck.Parent := lGroupBox;
  fLgYCheck.SetBounds(110, 137, 90, 20);
  fLgYCheck.Caption := CP1251ToUTF8('Лог Y');

  // 5. Параметры отображения
  lGroupBox := TGroupBox.Create(Self);
  lGroupBox.Parent := Self;
  lGroupBox.SetBounds(478, 215, 220, 225);
  lGroupBox.Caption := CP1251ToUTF8('Отображение');

  fShowAlarmsCheck := TCheckBox.Create(lGroupBox);
  fShowAlarmsCheck.Parent := lGroupBox;
  fShowAlarmsCheck.SetBounds(10, 20, 180, 20);
  fShowAlarmsCheck.Caption := CP1251ToUTF8('Аварийные уровни');

  fShowWarningsCheck := TCheckBox.Create(lGroupBox);
  fShowWarningsCheck.Parent := lGroupBox;
  fShowWarningsCheck.SetBounds(10, 45, 180, 20);
  fShowWarningsCheck.Caption := CP1251ToUTF8('Предупредительные');

  fShowProfileCheck := TCheckBox.Create(lGroupBox);
  fShowProfileCheck.Parent := lGroupBox;
  fShowProfileCheck.SetBounds(10, 70, 180, 20);
  fShowProfileCheck.Caption := CP1251ToUTF8('Профили');

  fShowLabelsCheck := TCheckBox.Create(lGroupBox);
  fShowLabelsCheck.Parent := lGroupBox;
  fShowLabelsCheck.SetBounds(10, 95, 180, 20);
  fShowLabelsCheck.Caption := CP1251ToUTF8('Метки пиков');

  lLabel := TLabel.Create(lGroupBox);
  lLabel.Parent := lGroupBox;
  fShowLegendCheck := TCheckBox.Create(lGroupBox);
  fShowLegendCheck.Parent := lGroupBox;
  fShowLegendCheck.SetBounds(10, 120, 180, 20);
  fShowLegendCheck.Caption := CP1251ToUTF8('Легенда');

  fZeroY0Check := TCheckBox.Create(lGroupBox);
  fZeroY0Check.Parent := lGroupBox;
  fZeroY0Check.SetBounds(10, 145, 180, 20);
  fZeroY0Check.Caption := CP1251ToUTF8('Занулять Y0');

  lLabel.SetBounds(10, 175, 80, 15);
  lLabel.Caption := CP1251ToUTF8('Результат:');

  fResultTypeCombo := TComboBox.Create(lGroupBox);
  fResultTypeCombo.Parent := lGroupBox;
  fResultTypeCombo.SetBounds(90, 172, 120, 23);
  fResultTypeCombo.Style := csDropDownList;
  fResultTypeCombo.Items.Add(CP1251ToUTF8('Амплитуда'));
  fResultTypeCombo.Items.Add(CP1251ToUTF8('Фаза'));

  // 6. Прочее (Тахометр)
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(478, 452, 80, 15);
  lLabel.Caption := CP1251ToUTF8('Тахометр:');

  fTahoCombo := TComboBox.Create(Self);
  fTahoCombo.Parent := Self;
  fTahoCombo.SetBounds(563, 449, 135, 23);
  fTahoCombo.Style := csDropDownList;
  fTahoCombo.Items.Add('');
  if fTagRegistry <> nil then
  begin
    for I := 0 to fTagRegistry.TagCount - 1 do
      fTahoCombo.Items.Add(fTagRegistry.Tags[I].Name);
  end;

  // 7. Кнопки ОК / Отмена
  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(520, 515, 80, 25);
  fOkButton.Caption := CP1251ToUTF8('ОК');
  fOkButton.Default := True;
  fOkButton.OnClick := @OkButtonClick;

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(615, 515, 80, 25);
  fCancelButton.Caption := CP1251ToUTF8('Отмена');
  fCancelButton.Cancel := True;
  fCancelButton.ModalResult := mrCancel;
end;

procedure TRecorderSpectrumSettingsDialog.LoadFromComponent;
var
  I, lIdx: Integer;
begin
  fMinXEdit.Text := FloatToStr(fDraft.RangeMinX);
  fMaxXEdit.Text := FloatToStr(fDraft.RangeMaxX);
  fMinYEdit.Text := FloatToStr(fDraft.RangeMinY);
  fMaxYEdit.Text := FloatToStr(fDraft.RangeMaxY);

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

  lIdx := fTahoCombo.Items.IndexOf(fDraft.TahoTagName);
  if lIdx >= 0 then
    fTahoCombo.ItemIndex := lIdx
  else
    fTahoCombo.ItemIndex := 0;

  // Заполняем список используемых
  fUsedList.Items.Clear;
  for I := 0 to fDraft.TagNames.Count - 1 do
    if IsSpectrumTagSelectable(fDraft.TagNames[I]) then
      fUsedList.Items.AddObject(TagDisplayText(fDraft.TagNames[I]),
        fTagRegistry.FindByName(fDraft.TagNames[I]));

  UpdateAvailableList;
end;

procedure TRecorderSpectrumSettingsDialog.StoreToComponent;
var
  I: Integer;
begin
  fDraft.RangeMinX := ParseFloatText(fMinXEdit.Text, fDraft.RangeMinX);
  fDraft.RangeMaxX := ParseFloatText(fMaxXEdit.Text, fDraft.RangeMaxX);
  fDraft.RangeMinY := ParseFloatText(fMinYEdit.Text, fDraft.RangeMinY);
  fDraft.RangeMaxY := ParseFloatText(fMaxYEdit.Text, fDraft.RangeMaxY);

  fDraft.LgX := fLgXCheck.Checked;
  fDraft.LgY := fLgYCheck.Checked;
  fDraft.ShowAlarms := fShowAlarmsCheck.Checked;
  fDraft.ShowWarnings := fShowWarningsCheck.Checked;
  fDraft.ShowProfile := fShowProfileCheck.Checked;
  fDraft.ShowLabels := fShowLabelsCheck.Checked;
  fDraft.LegendVisible := fShowLegendCheck.Checked;
  fDraft.ZeroY0 := fZeroY0Check.Checked;

  fDraft.ResultType := fResultTypeCombo.ItemIndex;
  fDraft.TahoTagName := fTahoCombo.Text;

  fDraft.TagNames.Clear;
  for I := 0 to fUsedList.Count - 1 do
    fDraft.TagNames.Add(DisplayItemTagName(fUsedList, I));
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
  I: Integer;
  lTagName: string;
  lChanged: Boolean;
begin
  lChanged := False;
  for I := 0 to fAvailableList.Count - 1 do
  begin
    if fAvailableList.Selected[I] then
    begin
      lTagName := DisplayItemTagName(fAvailableList, I);
      if fUsedList.Items.IndexOf(TagDisplayText(lTagName)) < 0 then
      begin
        fUsedList.Items.AddObject(TagDisplayText(lTagName), fTagRegistry.FindByName(lTagName));
        lChanged := True;
      end;
    end;
  end;
  if lChanged then
    UpdateAvailableList;
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
      lChanged := True;
    end;
  end;
  if lChanged then
    UpdateAvailableList;
end;

procedure TRecorderSpectrumSettingsDialog.AvailableListDblClick(Sender: TObject);
var
  lIdx: Integer;
  lTagName: string;
begin
  lIdx := fAvailableList.ItemIndex;
  if lIdx >= 0 then
  begin
    lTagName := DisplayItemTagName(fAvailableList, lIdx);
    if fUsedList.Items.IndexOf(TagDisplayText(lTagName)) < 0 then
    begin
      fUsedList.Items.AddObject(TagDisplayText(lTagName), fTagRegistry.FindByName(lTagName));
      UpdateAvailableList;
    end;
  end;
end;

procedure TRecorderSpectrumSettingsDialog.UsedListDblClick(Sender: TObject);
var
  lIdx: Integer;
begin
  lIdx := fUsedList.ItemIndex;
  if lIdx >= 0 then
  begin
    fUsedList.Items.Delete(lIdx);
    UpdateAvailableList;
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
      if fUsedList.Items.IndexOf(TagDisplayText(lTagName)) >= 0 then
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
