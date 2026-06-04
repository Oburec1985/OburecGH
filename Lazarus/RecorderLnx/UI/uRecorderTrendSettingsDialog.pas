unit uRecorderTrendSettingsDialog;

{
  Settings dialog for the user mnemonic Trend component.

  The original Recorder stores trend configuration as a set of axes and lines.
  This dialog edits the same model in-process without designer resources, so it
  does not touch legacy .lfm encodings.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, Dialogs,
  uRecorderFormModel, uRecorderTags;

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
    fLineColorEdit: TEdit;
    fLineColorButton: TButton;
    fLineWidthEdit: TEdit;
    fLineVisibleCheck: TCheckBox;

    fAxisList: TListBox;
    fAddAxisButton: TButton;
    fDeleteAxisButton: TButton;
    fAxisNameEdit: TEdit;
    fAxisMinEdit: TEdit;
    fAxisMaxEdit: TEdit;
    fAxisColorEdit: TEdit;
    fAxisColorButton: TButton;

    fDurationEdit: TEdit;
    fUpdatePeriodEdit: TEdit;
    fYAxisModeCombo: TComboBox;
    fLegendVisibleCheck: TCheckBox;
    fShowCurrentValuesCheck: TCheckBox;
    fOkButton: TButton;
    fCancelButton: TButton;

    procedure AddAxisClick(Sender: TObject);
    procedure AddLineClick(Sender: TObject);
    procedure AxisColorClick(Sender: TObject);
    procedure AxisSelectionChange(Sender: TObject);
    procedure BuildUi;
    procedure DeleteAxisClick(Sender: TObject);
    procedure DeleteLineClick(Sender: TObject);
    procedure FillTagCombo;
    procedure LineColorClick(Sender: TObject);
    procedure LineSelectionChange(Sender: TObject);
    procedure LoadAxisControls(AIndex: Integer);
    procedure LoadFromComponent;
    procedure LoadLineControls(AIndex: Integer);
    procedure OkButtonClick(Sender: TObject);
    function ParseColorText(const AText: string; ADefault: TColor): TColor;
    function ParseFloatText(const AText: string; ADefault: Double): Double;
    procedure RefreshAxisList;
    procedure RefreshLineAxisCombo;
    procedure RefreshLineList;
    procedure StoreAxisControls;
    procedure StoreLineControls;
    procedure StoreToComponent;
    function ColorText(AColor: TColor): string;
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

  Caption := 'Trend settings - ' + AComponent.Name;
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 640;
  ClientHeight := 600;

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

function TRecorderTrendSettingsDialog.ColorText(AColor: TColor): string;
begin
  Result := '$' + IntToHex(LongInt(AColor) and $00FFFFFF, 6);
end;

function TRecorderTrendSettingsDialog.ParseColorText(const AText: string;
  ADefault: TColor): TColor;
var
  lText: string;
begin
  lText := Trim(AText);
  if lText = '' then
    Exit(ADefault);
  if lText[1] = '$' then
    Result := TColor(StrToIntDef(lText, LongInt(ADefault)))
  else
    try
      Result := StringToColor(lText);
    except
      Result := TColor(StrToIntDef(lText, LongInt(ADefault)));
    end;
end;

procedure TRecorderTrendSettingsDialog.BuildUi;
var
  lLabel: TLabel;
  lKind: TRecorderTagEstimateKind;
begin
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 12, 160, 18);
  lLabel.Caption := 'Lines';

  fLineList := TListBox.Create(Self);
  fLineList.Parent := Self;
  fLineList.SetBounds(12, 32, 255, 145);
  fLineList.OnClick := @LineSelectionChange;

  fAddLineButton := TButton.Create(Self);
  fAddLineButton.Parent := Self;
  fAddLineButton.SetBounds(275, 32, 80, 25);
  fAddLineButton.Caption := 'Add';
  fAddLineButton.OnClick := @AddLineClick;

  fDeleteLineButton := TButton.Create(Self);
  fDeleteLineButton.Parent := Self;
  fDeleteLineButton.SetBounds(275, 62, 80, 25);
  fDeleteLineButton.Caption := 'Delete';
  fDeleteLineButton.OnClick := @DeleteLineClick;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 190, 80, 18);
  lLabel.Caption := 'Name';
  fLineNameEdit := TEdit.Create(Self);
  fLineNameEdit.Parent := Self;
  fLineNameEdit.SetBounds(92, 186, 180, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(292, 190, 80, 18);
  lLabel.Caption := 'Tag';
  fLineTagCombo := TComboBox.Create(Self);
  fLineTagCombo.Parent := Self;
  fLineTagCombo.SetBounds(372, 186, 250, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 220, 80, 18);
  lLabel.Caption := 'Estimate';
  fLineEstimateCombo := TComboBox.Create(Self);
  fLineEstimateCombo.Parent := Self;
  fLineEstimateCombo.SetBounds(92, 216, 180, 24);
  fLineEstimateCombo.Style := csDropDownList;
  for lKind := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
    fLineEstimateCombo.Items.Add(RecorderTagEstimateKindToShortName(lKind));

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(292, 220, 80, 18);
  lLabel.Caption := 'Axis';
  fLineAxisCombo := TComboBox.Create(Self);
  fLineAxisCombo.Parent := Self;
  fLineAxisCombo.SetBounds(372, 216, 250, 24);
  fLineAxisCombo.Style := csDropDownList;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 250, 80, 18);
  lLabel.Caption := 'Color';
  fLineColorEdit := TEdit.Create(Self);
  fLineColorEdit.Parent := Self;
  fLineColorEdit.SetBounds(92, 246, 100, 24);
  fLineColorButton := TButton.Create(Self);
  fLineColorButton.Parent := Self;
  fLineColorButton.SetBounds(198, 246, 32, 24);
  fLineColorButton.Caption := '...';
  fLineColorButton.OnClick := @LineColorClick;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(292, 250, 80, 18);
  lLabel.Caption := 'Width';
  fLineWidthEdit := TEdit.Create(Self);
  fLineWidthEdit.Parent := Self;
  fLineWidthEdit.SetBounds(372, 246, 70, 24);
  fLineVisibleCheck := TCheckBox.Create(Self);
  fLineVisibleCheck.Parent := Self;
  fLineVisibleCheck.SetBounds(470, 248, 100, 20);
  fLineVisibleCheck.Caption := 'Visible';

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 292, 160, 18);
  lLabel.Caption := 'Y axes';
  fAxisList := TListBox.Create(Self);
  fAxisList.Parent := Self;
  fAxisList.SetBounds(12, 312, 255, 100);
  fAxisList.OnClick := @AxisSelectionChange;

  fAddAxisButton := TButton.Create(Self);
  fAddAxisButton.Parent := Self;
  fAddAxisButton.SetBounds(275, 312, 80, 25);
  fAddAxisButton.Caption := 'Add';
  fAddAxisButton.OnClick := @AddAxisClick;

  fDeleteAxisButton := TButton.Create(Self);
  fDeleteAxisButton.Parent := Self;
  fDeleteAxisButton.SetBounds(275, 342, 80, 25);
  fDeleteAxisButton.Caption := 'Delete';
  fDeleteAxisButton.OnClick := @DeleteAxisClick;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(372, 312, 80, 18);
  lLabel.Caption := 'Axis name';
  fAxisNameEdit := TEdit.Create(Self);
  fAxisNameEdit.Parent := Self;
  fAxisNameEdit.SetBounds(452, 308, 170, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(372, 342, 80, 18);
  lLabel.Caption := 'Range';
  fAxisMinEdit := TEdit.Create(Self);
  fAxisMinEdit.Parent := Self;
  fAxisMinEdit.SetBounds(452, 338, 80, 24);
  fAxisMaxEdit := TEdit.Create(Self);
  fAxisMaxEdit.Parent := Self;
  fAxisMaxEdit.SetBounds(542, 338, 80, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(372, 372, 80, 18);
  lLabel.Caption := 'Axis color';
  fAxisColorEdit := TEdit.Create(Self);
  fAxisColorEdit.Parent := Self;
  fAxisColorEdit.SetBounds(452, 368, 100, 24);
  fAxisColorButton := TButton.Create(Self);
  fAxisColorButton.Parent := Self;
  fAxisColorButton.SetBounds(558, 368, 32, 24);
  fAxisColorButton.Caption := '...';
  fAxisColorButton.OnClick := @AxisColorClick;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 438, 100, 18);
  lLabel.Caption := 'Duration, sec';
  fDurationEdit := TEdit.Create(Self);
  fDurationEdit.Parent := Self;
  fDurationEdit.SetBounds(112, 434, 90, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(225, 438, 105, 18);
  lLabel.Caption := 'Period, sec';
  fUpdatePeriodEdit := TEdit.Create(Self);
  fUpdatePeriodEdit.Parent := Self;
  fUpdatePeriodEdit.SetBounds(330, 434, 90, 24);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, 468, 100, 18);
  lLabel.Caption := 'Y axis mode';
  fYAxisModeCombo := TComboBox.Create(Self);
  fYAxisModeCombo.Parent := Self;
  fYAxisModeCombo.SetBounds(112, 464, 160, 24);
  fYAxisModeCombo.Style := csDropDownList;
  fYAxisModeCombo.Items.Add('Common');
  fYAxisModeCombo.Items.Add('Rows');
  fYAxisModeCombo.Items.Add('Columns');
  fYAxisModeCombo.Items.Add('Free');

  fLegendVisibleCheck := TCheckBox.Create(Self);
  fLegendVisibleCheck.Parent := Self;
  fLegendVisibleCheck.SetBounds(330, 466, 95, 20);
  fLegendVisibleCheck.Caption := 'Legend';
  fShowCurrentValuesCheck := TCheckBox.Create(Self);
  fShowCurrentValuesCheck.Parent := Self;
  fShowCurrentValuesCheck.SetBounds(430, 466, 170, 20);
  fShowCurrentValuesCheck.Caption := 'Current values';

  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(432, 558, 90, 26);
  fOkButton.Caption := 'OK';
  fOkButton.Default := True;
  fOkButton.OnClick := @OkButtonClick;

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(528, 558, 90, 26);
  fCancelButton.Caption := 'Cancel';
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
  fLineColorEdit.Enabled := AIndex >= 0;
  fLineColorButton.Enabled := AIndex >= 0;
  fLineWidthEdit.Enabled := AIndex >= 0;
  fLineVisibleCheck.Enabled := AIndex >= 0;
  if AIndex < 0 then
  begin
    fLineNameEdit.Text := '';
    fLineTagCombo.Text := '';
    fLineEstimateCombo.ItemIndex := 0;
    fLineAxisCombo.ItemIndex := 0;
    fLineColorEdit.Text := ColorText(clBlue);
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
  fLineColorEdit.Text := ColorText(TColor(lLine.Color));
  fLineWidthEdit.Text := IntToStr(lLine.Width);
  fLineVisibleCheck.Checked := lLine.Visible;
end;

procedure TRecorderTrendSettingsDialog.StoreLineControls;
var
  lLine: TRecorderTrendLine;
begin
  if fUpdating or (fSelectedLine < 0) or
    (fSelectedLine >= fDraft.LineCount) then
    Exit;
  lLine := fDraft.Lines[fSelectedLine];
  lLine.Name := Trim(fLineNameEdit.Text);
  if lLine.Name = '' then
    lLine.Name := 'Line';
  lLine.TagName := Trim(fLineTagCombo.Text);
  if fLineEstimateCombo.ItemIndex >= 0 then
    lLine.EstimateKind := TRecorderTagEstimateKind(fLineEstimateCombo.ItemIndex);
  if fLineAxisCombo.ItemIndex >= 0 then
    lLine.AxisIndex := fLineAxisCombo.ItemIndex
  else
    lLine.AxisIndex := 0;
  lLine.Color := LongInt(ParseColorText(fLineColorEdit.Text, TColor(lLine.Color)));
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
  fAxisColorEdit.Enabled := AIndex >= 0;
  fAxisColorButton.Enabled := AIndex >= 0;
  if AIndex < 0 then
  begin
    fAxisNameEdit.Text := '';
    fAxisMinEdit.Text := '0';
    fAxisMaxEdit.Text := '1';
    fAxisColorEdit.Text := ColorText(clBlue);
    Exit;
  end;
  lAxis := fDraft.Axes[AIndex];
  fAxisNameEdit.Text := lAxis.Name;
  fAxisMinEdit.Text := FloatToStr(lAxis.RangeMin);
  fAxisMaxEdit.Text := FloatToStr(lAxis.RangeMax);
  fAxisColorEdit.Text := ColorText(TColor(lAxis.Color));
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
  lAxis.Color := LongInt(ParseColorText(fAxisColorEdit.Text, TColor(lAxis.Color)));
end;

procedure TRecorderTrendSettingsDialog.LineSelectionChange(Sender: TObject);
begin
  StoreLineControls;
  fUpdating := True;
  try
    LoadLineControls(fLineList.ItemIndex);
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

procedure TRecorderTrendSettingsDialog.AddLineClick(Sender: TObject);
var
  lLine: TRecorderTrendLine;
begin
  StoreLineControls;
  lLine := fDraft.AddLine;
  lLine.AxisIndex := 0;
  if fLineTagCombo.Items.Count > 0 then
    lLine.TagName := fLineTagCombo.Items[0];
  lLine.Name := lLine.TagName;
  if lLine.Name = '' then
    lLine.Name := 'Line' + IntToStr(fDraft.LineCount);
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

procedure TRecorderTrendSettingsDialog.LineColorClick(Sender: TObject);
var
  lDialog: TColorDialog;
begin
  lDialog := TColorDialog.Create(Self);
  try
    lDialog.Color := ParseColorText(fLineColorEdit.Text, clBlue);
    if lDialog.Execute then
      fLineColorEdit.Text := ColorText(lDialog.Color);
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderTrendSettingsDialog.AxisColorClick(Sender: TObject);
var
  lDialog: TColorDialog;
begin
  lDialog := TColorDialog.Create(Self);
  try
    lDialog.Color := ParseColorText(fAxisColorEdit.Text, clBlue);
    if lDialog.Execute then
      fAxisColorEdit.Text := ColorText(lDialog.Color);
  finally
    lDialog.Free;
  end;
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
