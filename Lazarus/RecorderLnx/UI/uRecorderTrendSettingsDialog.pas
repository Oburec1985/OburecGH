unit uRecorderTrendSettingsDialog;

{
  Settings dialog for the user mnemonic Trend component.

  The original Recorder stores trend configuration as a set of axes and lines.
  This dialog edits the same model in-process without designer resources, so it
  does not touch legacy .lfm encodings.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, Dialogs,
  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags, uOglChartColors,
  uRecorderTagRefs;

function ShowRecorderTrendSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderTrendComponent; ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

type
  TRecorderTrendSettingsDialog = class(TForm)
  private
    fComponent: TRecorderTrendComponent;
    fDraft: TRecorderTrendComponent;
    fTagRegistry: TRecorderTagRegistry;
    fUpdating: Boolean;
    fSelectedAxis: Integer;
    fSelectedLine: Integer;

    fLineList: TListBox;
    fAddLineButton: TButton;
    fDeleteLineButton: TButton;
    fLineNameEdit: TEdit;
    fLineTagCombo: TComboBox;
    fLineEstimateCombo: TComboBox;
    fLineAxisCombo: TComboBox;
    fLineColorSwatch: TRecorderColorSwatch;
    fLineWidthEdit: TEdit;
    fLineVisibleCheck: TCheckBox;

    fAxisList: TListBox;
    fAddAxisButton: TButton;
    fDeleteAxisButton: TButton;
    fAxisNameEdit: TEdit;
    fAxisMinEdit: TEdit;
    fAxisMaxEdit: TEdit;
    fAxisColorSwatch: TRecorderColorSwatch;

    fDurationEdit: TEdit;
    fUpdatePeriodEdit: TEdit;
    fYAxisModeCombo: TComboBox;
    fLegendVisibleCheck: TCheckBox;
    fShowCurrentValuesCheck: TCheckBox;
    fOkButton: TButton;
    fCancelButton: TButton;

    procedure AddAxisClick(Sender: TObject);
    procedure AddLineClick(Sender: TObject);
    procedure AxisSelectionChange(Sender: TObject);
    procedure AxisScaleDblClick(Sender: TObject);
    procedure BuildUi;
    procedure DeleteAxisClick(Sender: TObject);
    procedure DeleteLineClick(Sender: TObject);
    procedure FillTagCombo;
    procedure LineAxisChange(Sender: TObject);
    procedure LineSelectionChange(Sender: TObject);
    procedure LoadAxisControls(AIndex: Integer);
    procedure LoadFromComponent;
    procedure LoadLineControls(AIndex: Integer);
    procedure OkButtonClick(Sender: TObject);
    function ParseFloatText(const AText: string; ADefault: Double): Double;
    procedure RefreshAxisList;
    procedure RefreshLineAxisCombo;
    procedure RefreshLineList;
    procedure StoreAxisControls;
    procedure StoreLineControls;
    procedure StoreToComponent;
    procedure SelectAxis(AIndex: Integer);
    procedure SelectLineAxis;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderTrendComponent; ATagRegistry: TRecorderTagRegistry);
      reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderTrendSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderTrendComponent; ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderTrendSettingsDialog;
begin
  lDialog := TRecorderTrendSettingsDialog.CreateDialog(AOwner, AComponent,
    ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderTrendSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderTrendComponent; ATagRegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  fDraft := TRecorderTrendComponent.Create;
  fSelectedAxis := -1;
  fSelectedLine := -1;

  Caption := 'Настройка параметров тренда - ' + AComponent.Name;
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 640;
  ClientHeight := 620;

  BuildUi;
  LoadFromComponent;
end;

destructor TRecorderTrendSettingsDialog.Destroy;
begin
  fDraft.Free;
  inherited Destroy;
end;

function TRecorderTrendSettingsDialog.ParseFloatText(const AText: string;
  ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AText);
  lText := StringReplace(lText, '.', DecimalSeparator, [rfReplaceAll]);
  lText := StringReplace(lText, ',', DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(lText, ADefault);
end;

procedure TRecorderTrendSettingsDialog.BuildUi;
var
  lLabel: TLabel;
  lKind: TRecorderTagEstimateKind;
begin
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 12, 160, 18);
  lLabel.Caption := 'Линии';

  fLineList := TListBox.Create(Self);
  fLineList.Parent := Self;
  fLineList.SetBounds(12, 32, 340, 135);
  fLineList.OnClick := @LineSelectionChange;

  fAddLineButton := TButton.Create(Self);
  fAddLineButton.Parent := Self;
  fAddLineButton.SetBounds(360, 32, 80, 25);
  fAddLineButton.Caption := 'Добавить';
  fAddLineButton.OnClick := @AddLineClick;

  fDeleteLineButton := TButton.Create(Self);
  fDeleteLineButton.Parent := Self;
  fDeleteLineButton.SetBounds(360, 62, 80, 25);
  fDeleteLineButton.Caption := 'Удалить';
  fDeleteLineButton.OnClick := @DeleteLineClick;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 190, 70, 18);
  lLabel.Caption := 'Название';
  fLineNameEdit := TEdit.Create(Self);
  fLineNameEdit.Parent := Self;
  fLineNameEdit.SetBounds(78, 186, 150, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(250, 190, 70, 18);
  lLabel.Caption := 'Тег';
  fLineTagCombo := TComboBox.Create(Self);
  fLineTagCombo.Parent := Self;
  fLineTagCombo.SetBounds(315, 186, 150, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 220, 70, 18);
  lLabel.Caption := 'Оценка';
  fLineEstimateCombo := TComboBox.Create(Self);
  fLineEstimateCombo.Parent := Self;
  fLineEstimateCombo.SetBounds(78, 216, 150, 24);
  fLineEstimateCombo.Style := csDropDownList;
  for lKind := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
    fLineEstimateCombo.Items.Add(RecorderTagEstimateKindToShortName(lKind));

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(250, 220, 70, 18);
  lLabel.Caption := 'Ось';
  fLineAxisCombo := TComboBox.Create(Self);
  fLineAxisCombo.Parent := Self;
  fLineAxisCombo.SetBounds(315, 216, 150, 24);
  fLineAxisCombo.Style := csDropDownList;
  fLineAxisCombo.OnChange := @LineAxisChange;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 250, 70, 18);
  lLabel.Caption := 'Цвет';
  fLineColorSwatch := TRecorderColorSwatch.Create(Self);
  fLineColorSwatch.Parent := Self;
  fLineColorSwatch.SetBounds(78, 246, 28, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(250, 250, 70, 18);
  lLabel.Caption := 'Толщина';
  fLineWidthEdit := TEdit.Create(Self);
  fLineWidthEdit.Parent := Self;
  fLineWidthEdit.SetBounds(315, 246, 70, 24);
  fLineVisibleCheck := TCheckBox.Create(Self);
  fLineVisibleCheck.Parent := Self;
  fLineVisibleCheck.SetBounds(395, 248, 70, 20);
  fLineVisibleCheck.Caption := 'Видна';

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 292, 160, 18);
  lLabel.Caption := 'Оси Y';
  fAxisList := TListBox.Create(Self);
  fAxisList.Parent := Self;
  fAxisList.SetBounds(12, 312, 220, 100);
  fAxisList.OnClick := @AxisSelectionChange;
  fAxisList.OnDblClick := @AxisScaleDblClick;

  fAddAxisButton := TButton.Create(Self);
  fAddAxisButton.Parent := Self;
  fAddAxisButton.SetBounds(240, 312, 80, 25);
  fAddAxisButton.Caption := 'Добавить';
  fAddAxisButton.OnClick := @AddAxisClick;

  fDeleteAxisButton := TButton.Create(Self);
  fDeleteAxisButton.Parent := Self;
  fDeleteAxisButton.SetBounds(240, 342, 80, 25);
  fDeleteAxisButton.Caption := 'Удалить';
  fDeleteAxisButton.OnClick := @DeleteAxisClick;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(330, 312, 80, 18);
  lLabel.Caption := 'Название';
  fAxisNameEdit := TEdit.Create(Self);
  fAxisNameEdit.Parent := Self;
  fAxisNameEdit.SetBounds(410, 308, 55, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(330, 342, 80, 18);
  lLabel.Caption := 'Название';
  fAxisMinEdit := TEdit.Create(Self);
  fAxisMinEdit.Parent := Self;
  fAxisMinEdit.SetBounds(410, 338, 65, 24);
  fAxisMaxEdit := TEdit.Create(Self);
  fAxisMaxEdit.Parent := Self;
  fAxisMaxEdit.SetBounds(480, 338, 65, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(330, 372, 80, 18);
  lLabel.Caption := 'Цвет оси';
  fAxisColorSwatch := TRecorderColorSwatch.Create(Self);
  fAxisColorSwatch.Parent := Self;
  fAxisColorSwatch.SetBounds(410, 368, 28, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 438, 100, 18);
  lLabel.Caption := 'Интервал, сек';
  fDurationEdit := TEdit.Create(Self);
  fDurationEdit.Parent := Self;
  fDurationEdit.SetBounds(112, 434, 90, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(225, 438, 105, 18);
  lLabel.Caption := 'Период, сек';
  fUpdatePeriodEdit := TEdit.Create(Self);
  fUpdatePeriodEdit.Parent := Self;
  fUpdatePeriodEdit.SetBounds(330, 434, 90, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 468, 100, 18);
  lLabel.Caption := 'Тип оси Y';
  fYAxisModeCombo := TComboBox.Create(Self);
  fYAxisModeCombo.Parent := Self;
  fYAxisModeCombo.SetBounds(112, 464, 160, 24);
  fYAxisModeCombo.Style := csDropDownList;
  fYAxisModeCombo.Items.Add('Общая ось');
  fYAxisModeCombo.Items.Add('Строки');
  fYAxisModeCombo.Items.Add('Колонки');
  fYAxisModeCombo.Items.Add('Индивидуальные оси');

  fLegendVisibleCheck := TCheckBox.Create(Self);
  fLegendVisibleCheck.Parent := Self;
  fLegendVisibleCheck.SetBounds(330, 466, 95, 20);
  fLegendVisibleCheck.Caption := 'Легенда';
  fShowCurrentValuesCheck := TCheckBox.Create(Self);
  fShowCurrentValuesCheck.Parent := Self;
  fShowCurrentValuesCheck.SetBounds(430, 466, 170, 20);
  fShowCurrentValuesCheck.Caption := 'Текущие значения';

  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(440, 558, 90, 26);
  fOkButton.Caption := 'OK';
  fOkButton.Default := True;
  fOkButton.OnClick := @OkButtonClick;

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(536, 558, 90, 26);
  fCancelButton.Caption := 'Отмена';
  fCancelButton.ModalResult := mrCancel;
end;

procedure TRecorderTrendSettingsDialog.FillTagCombo;
var
  I: Integer;
begin
  fLineTagCombo.Items.Clear;
  if fTagRegistry = nil then
    Exit;
  for I := 0 to fTagRegistry.TagCount - 1 do
    fLineTagCombo.Items.Add(fTagRegistry.Tags[I].Name);
end;

procedure TRecorderTrendSettingsDialog.RefreshLineAxisCombo;
var
  I: Integer;
  lAxis: TRecorderTrendAxis;
begin
  fLineAxisCombo.Items.Clear;
  for I := 0 to fDraft.AxisCount - 1 do
  begin
    lAxis := fDraft.Axes[I];
    fLineAxisCombo.Items.Add(Format('%d: %s', [I + 1, lAxis.Name]));
  end;
  if fLineAxisCombo.Items.Count > 0 then
    fLineAxisCombo.ItemIndex := 0;
end;

procedure TRecorderTrendSettingsDialog.RefreshLineList;
var
  I: Integer;
  lLine: TRecorderTrendLine;
begin
  fLineList.Items.BeginUpdate;
  try
    fLineList.Items.Clear;
    for I := 0 to fDraft.LineCount - 1 do
    begin
      lLine := fDraft.Lines[I];
      fLineList.Items.Add(Format('%s  [%s]', [lLine.Name, lLine.TagName]));
    end;
  finally
    fLineList.Items.EndUpdate;
  end;
end;

procedure TRecorderTrendSettingsDialog.RefreshAxisList;
var
  I: Integer;
  lAxis: TRecorderTrendAxis;
begin
  fAxisList.Items.BeginUpdate;
  try
    fAxisList.Items.Clear;
    for I := 0 to fDraft.AxisCount - 1 do
    begin
      lAxis := fDraft.Axes[I];
      fAxisList.Items.Add(Format('%s  [%g..%g]', [lAxis.Name,
        lAxis.RangeMin, lAxis.RangeMax]));
    end;
  finally
    fAxisList.Items.EndUpdate;
  end;
  RefreshLineAxisCombo;
end;

procedure TRecorderTrendSettingsDialog.LoadFromComponent;
begin
  fUpdating := True;
  try
    fDraft.AssignTrend(fComponent);
    FillTagCombo;
    fDurationEdit.Text := FloatToStr(fDraft.DurationSec);
    fUpdatePeriodEdit.Text := FloatToStr(fDraft.UpdatePeriodSec);
    fYAxisModeCombo.ItemIndex := Ord(fDraft.YAxisMode);
    fLegendVisibleCheck.Checked := fDraft.LegendVisible;
    fShowCurrentValuesCheck.Checked := fDraft.ShowCurrentValues;
    RefreshAxisList;
    RefreshLineList;
    if fDraft.AxisCount > 0 then
    begin
      fAxisList.ItemIndex := 0;
      LoadAxisControls(0);
    end;
    if fDraft.LineCount > 0 then
    begin
      fLineList.ItemIndex := 0;
      LoadLineControls(0);
      SelectLineAxis;
    end
    else
      LoadLineControls(-1);
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderTrendSettingsDialog.LoadLineControls(AIndex: Integer);
var
  lLine: TRecorderTrendLine;
begin
  fSelectedLine := AIndex;
  fLineNameEdit.Enabled := AIndex >= 0;
  fLineTagCombo.Enabled := AIndex >= 0;
  fLineEstimateCombo.Enabled := AIndex >= 0;
  fLineAxisCombo.Enabled := AIndex >= 0;
  fLineColorSwatch.Enabled := AIndex >= 0;
  fLineWidthEdit.Enabled := AIndex >= 0;
  fLineVisibleCheck.Enabled := AIndex >= 0;
  if AIndex < 0 then
  begin
    fLineNameEdit.Text := '';
    fLineTagCombo.Text := '';
    fLineEstimateCombo.ItemIndex := 0;
    fLineAxisCombo.ItemIndex := 0;
    fLineColorSwatch.LineColor := clBlue;
    fLineWidthEdit.Text := '1';
    fLineVisibleCheck.Checked := True;
    Exit;
  end;
  lLine := fDraft.Lines[AIndex];
  fLineNameEdit.Text := lLine.Name;
  fLineTagCombo.Text := lLine.TagName;
  fLineEstimateCombo.ItemIndex := Ord(lLine.EstimateKind);
  if (lLine.AxisIndex >= 0) and (lLine.AxisIndex < fLineAxisCombo.Items.Count) then
    fLineAxisCombo.ItemIndex := lLine.AxisIndex
  else if fLineAxisCombo.Items.Count > 0 then
    fLineAxisCombo.ItemIndex := 0;
  fLineColorSwatch.LineColor := TColor(lLine.Color);
  fLineWidthEdit.Text := IntToStr(lLine.Width);
  fLineVisibleCheck.Checked := lLine.Visible;
end;

procedure TRecorderTrendSettingsDialog.StoreLineControls;
var
  lLine: TRecorderTrendLine;
  lName: string;
  lTag: TRecorderTag;
begin
  if fUpdating or (fSelectedLine < 0) or
    (fSelectedLine >= fDraft.LineCount) then
    Exit;
  lLine := fDraft.Lines[fSelectedLine];
  lTag := fTagRegistry.FindByName(Trim(fLineTagCombo.Text));
  if lTag <> nil then
    RecorderBindTrendLineTag(lLine, lTag)
  else
  begin
    lLine.TagId := 0;
    lLine.TagName := Trim(fLineTagCombo.Text);
  end;
  if fLineEstimateCombo.ItemIndex >= 0 then
    lLine.EstimateKind := TRecorderTagEstimateKind(fLineEstimateCombo.ItemIndex);
  if fLineAxisCombo.ItemIndex >= 0 then
    lLine.AxisIndex := fLineAxisCombo.ItemIndex
  else
    lLine.AxisIndex := 0;
  lLine.Color := LongInt(fLineColorSwatch.LineColor);
  lName := OglChartLinePaletteNameForColor(fLineColorSwatch.LineColor);
  if lName <> '' then
    lLine.Name := lName
  else
  begin
    lLine.Name := Trim(fLineNameEdit.Text);
    if lLine.Name = '' then
      lLine.Name := OglChartLinePaletteName(fSelectedLine);
  end;
  lLine.Width := StrToIntDef(Trim(fLineWidthEdit.Text), lLine.Width);
  if lLine.Width < 1 then
    lLine.Width := 1;
  lLine.Visible := fLineVisibleCheck.Checked;
end;

procedure TRecorderTrendSettingsDialog.LoadAxisControls(AIndex: Integer);
var
  lAxis: TRecorderTrendAxis;
begin
  fSelectedAxis := AIndex;
  fAxisNameEdit.Enabled := AIndex >= 0;
  fAxisMinEdit.Enabled := AIndex >= 0;
  fAxisMaxEdit.Enabled := AIndex >= 0;
  fAxisColorSwatch.Enabled := AIndex >= 0;
  if AIndex < 0 then
  begin
    fAxisNameEdit.Text := '';
    fAxisMinEdit.Text := '0';
    fAxisMaxEdit.Text := '1';
    fAxisColorSwatch.LineColor := clBlue;
    Exit;
  end;
  lAxis := fDraft.Axes[AIndex];
  fAxisNameEdit.Text := lAxis.Name;
  fAxisMinEdit.Text := FloatToStr(lAxis.RangeMin);
  fAxisMaxEdit.Text := FloatToStr(lAxis.RangeMax);
  fAxisColorSwatch.LineColor := TColor(lAxis.Color);
end;

procedure TRecorderTrendSettingsDialog.StoreAxisControls;
var
  lAxis: TRecorderTrendAxis;
begin
  if fUpdating or (fSelectedAxis < 0) or
    (fSelectedAxis >= fDraft.AxisCount) then
    Exit;
  lAxis := fDraft.Axes[fSelectedAxis];
  lAxis.Name := Trim(fAxisNameEdit.Text);
  if lAxis.Name = '' then
    lAxis.Name := 'Y';
  lAxis.RangeMin := ParseFloatText(fAxisMinEdit.Text, lAxis.RangeMin);
  lAxis.RangeMax := ParseFloatText(fAxisMaxEdit.Text, lAxis.RangeMax);
  if lAxis.RangeMax <= lAxis.RangeMin then
    lAxis.RangeMax := lAxis.RangeMin + 1;
  lAxis.Color := LongInt(fAxisColorSwatch.LineColor);
end;

procedure TRecorderTrendSettingsDialog.LineSelectionChange(Sender: TObject);
begin
  StoreLineControls;
  StoreAxisControls;
  fUpdating := True;
  try
    LoadLineControls(fLineList.ItemIndex);
    SelectLineAxis;
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderTrendSettingsDialog.LineAxisChange(Sender: TObject);
begin
  if fUpdating then
    Exit;
  StoreLineControls;
  fUpdating := True;
  try
    SelectLineAxis;
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderTrendSettingsDialog.AxisSelectionChange(Sender: TObject);
begin
  StoreAxisControls;
  fUpdating := True;
  try
    LoadAxisControls(fAxisList.ItemIndex);
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderTrendSettingsDialog.SelectAxis(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= fDraft.AxisCount) then
  begin
    fAxisList.ItemIndex := -1;
    LoadAxisControls(-1);
    Exit;
  end;
  fAxisList.ItemIndex := AIndex;
  LoadAxisControls(AIndex);
end;

procedure TRecorderTrendSettingsDialog.SelectLineAxis;
var
  lAxisIndex: Integer;
begin
  if (fSelectedLine < 0) or (fSelectedLine >= fDraft.LineCount) then
    Exit;
  lAxisIndex := fDraft.Lines[fSelectedLine].AxisIndex;
  if (fLineAxisCombo.ItemIndex >= 0) and (fLineAxisCombo.ItemIndex < fDraft.AxisCount) then
    lAxisIndex := fLineAxisCombo.ItemIndex;
  SelectAxis(lAxisIndex);
end;

procedure TRecorderTrendSettingsDialog.AxisScaleDblClick(Sender: TObject);
var
  lAxisIndex: Integer;
  lLine: TRecorderTrendLine;
  lTag: TRecorderTag;
begin
  StoreLineControls;
  StoreAxisControls;
  if (fSelectedLine < 0) or (fSelectedLine >= fDraft.LineCount) then
    Exit;
  lLine := fDraft.Lines[fSelectedLine];
  lAxisIndex := lLine.AxisIndex;
  if (lAxisIndex < 0) or (lAxisIndex >= fDraft.AxisCount) then
    Exit;
  if fAxisList.ItemIndex <> lAxisIndex then
    Exit;
  if fTagRegistry = nil then
    Exit;
  lTag := fTagRegistry.FindByName(lLine.TagName);
  if lTag = nil then
    Exit;

  fDraft.Axes[lAxisIndex].RangeMin := lTag.RangeMin;
  fDraft.Axes[lAxisIndex].RangeMax := lTag.RangeMax;
  if Trim(lTag.UnitName) <> '' then
    fDraft.Axes[lAxisIndex].Name := lTag.UnitName;
  RefreshAxisList;
  SelectAxis(lAxisIndex);
  LoadLineControls(fSelectedLine);
end;

procedure TRecorderTrendSettingsDialog.AddLineClick(Sender: TObject);
var
  lLine: TRecorderTrendLine;
  lTag: TRecorderTag;
begin
  StoreLineControls;
  lLine := fDraft.AddLine;
  lLine.AxisIndex := 0;
  if fLineTagCombo.Items.Count > 0 then
  begin
    lTag := fTagRegistry.FindByName(fLineTagCombo.Items[0]);
    if lTag <> nil then
      RecorderBindTrendLineTag(lLine, lTag)
    else
      lLine.TagName := fLineTagCombo.Items[0];
  end;
  RefreshLineList;
  fLineList.ItemIndex := fDraft.LineCount - 1;
  LoadLineControls(fLineList.ItemIndex);
end;

procedure TRecorderTrendSettingsDialog.DeleteLineClick(Sender: TObject);
var
  lIndex: Integer;
begin
  lIndex := fLineList.ItemIndex;
  if (lIndex < 0) or (lIndex >= fDraft.LineCount) then
    Exit;
  fDraft.DeleteLine(lIndex);
  RefreshLineList;
  if lIndex >= fDraft.LineCount then
    lIndex := fDraft.LineCount - 1;
  fLineList.ItemIndex := lIndex;
  LoadLineControls(lIndex);
end;

procedure TRecorderTrendSettingsDialog.AddAxisClick(Sender: TObject);
var
  lAxis: TRecorderTrendAxis;
begin
  StoreAxisControls;
  lAxis := fDraft.AddAxis;
  lAxis.Name := 'Y' + IntToStr(fDraft.AxisCount);
  RefreshAxisList;
  fAxisList.ItemIndex := fDraft.AxisCount - 1;
  LoadAxisControls(fAxisList.ItemIndex);
end;

procedure TRecorderTrendSettingsDialog.DeleteAxisClick(Sender: TObject);
var
  I: Integer;
  lIndex: Integer;
begin
  lIndex := fAxisList.ItemIndex;
  if (lIndex < 0) or (lIndex >= fDraft.AxisCount) then
    Exit;
  fDraft.DeleteAxis(lIndex);
  for I := 0 to fDraft.LineCount - 1 do
  begin
    if fDraft.Lines[I].AxisIndex = lIndex then
      fDraft.Lines[I].AxisIndex := 0
    else if fDraft.Lines[I].AxisIndex > lIndex then
      fDraft.Lines[I].AxisIndex := fDraft.Lines[I].AxisIndex - 1;
  end;
  RefreshAxisList;
  if lIndex >= fDraft.AxisCount then
    lIndex := fDraft.AxisCount - 1;
  fAxisList.ItemIndex := lIndex;
  LoadAxisControls(lIndex);
  if fSelectedLine >= 0 then
    LoadLineControls(fSelectedLine);
end;

procedure TRecorderTrendSettingsDialog.StoreToComponent;
begin
  StoreLineControls;
  StoreAxisControls;
  fDraft.DurationSec := ParseFloatText(fDurationEdit.Text, fDraft.DurationSec);
  if fDraft.DurationSec <= 0 then
    fDraft.DurationSec := 1;
  fDraft.UpdatePeriodSec := ParseFloatText(fUpdatePeriodEdit.Text,
    fDraft.UpdatePeriodSec);
  if fDraft.UpdatePeriodSec <= 0 then
    fDraft.UpdatePeriodSec := 1;
  if fYAxisModeCombo.ItemIndex >= 0 then
    fDraft.YAxisMode := TRecorderTrendYAxisMode(fYAxisModeCombo.ItemIndex);
  fDraft.LegendVisible := fLegendVisibleCheck.Checked;
  fDraft.ShowCurrentValues := fShowCurrentValuesCheck.Checked;
  fComponent.AssignTrend(fDraft);
end;

procedure TRecorderTrendSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToComponent;
  ModalResult := mrOk;
end;

end.
