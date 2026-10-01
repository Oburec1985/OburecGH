unit uRecorderVibrationEstimateSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Graphics,
  uRecorderFormModel, uRecorderTags;

function ShowRecorderVibrationEstimateSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderVibrationEstimateComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

uses
  uRecorderVibrationEstimate, uRecorderSpectrumEngine,
  uRecorderSpectrumRuntime, uRecorderTagPickerDialog;

const
  CDefaultVibrationSpectrumNode = 'spectrum.vibration.default';

type
  TRecorderVibrationFontButton = class;

  TRecorderVibrationTagSelectButton = class(TButton)
  private
    fRegistry: TRecorderTagRegistry;
    fTagEdit: TEdit;
    fSelectedTag: TRecorderTag;
  protected
    procedure Click; override;
  public
    property Registry: TRecorderTagRegistry read fRegistry write fRegistry;
    property TagEdit: TEdit read fTagEdit write fTagEdit;
    property SelectedTag: TRecorderTag read fSelectedTag;
  end;

  TRecorderVibrationFontButton = class(TButton)
  private
    fSelectedFont: TFont;
    procedure UpdateCaption;
  protected
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SelectedFont: TFont read fSelectedFont;
  end;

  TRecorderVibrationFontPresetCombo = class(TComboBox)
  private
    fManager: TRecorderNamedFontManager;
    fFontButton: TRecorderVibrationFontButton;
  protected
    procedure Change; override;
  public
    procedure LoadPresets;
    property Manager: TRecorderNamedFontManager read fManager write fManager;
    property FontButton: TRecorderVibrationFontButton read fFontButton
      write fFontButton;
  end;

constructor TRecorderVibrationFontButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fSelectedFont := TFont.Create;
  UpdateCaption;
end;

destructor TRecorderVibrationFontButton.Destroy;
begin
  fSelectedFont.Free;
  inherited Destroy;
end;

procedure TRecorderVibrationFontButton.UpdateCaption;
begin
  Caption := Format('%s, %d', [fSelectedFont.Name, fSelectedFont.Size]);
end;

procedure TRecorderVibrationFontButton.Click;
var
  lDialog: TFontDialog;
begin
  inherited Click;
  lDialog := TFontDialog.Create(Owner);
  try
    lDialog.Font.Assign(fSelectedFont);
    if not lDialog.Execute then Exit;
    fSelectedFont.Assign(lDialog.Font);
    UpdateCaption;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderVibrationFontPresetCombo.Change;
var
  lFont: TRecorderNamedFont;
begin
  inherited Change;
  if (fManager = nil) or (fFontButton = nil) then
    Exit;
  lFont := fManager.Find(Text);
  if lFont = nil then
    Exit;
  fFontButton.SelectedFont.Name := lFont.FontName;
  fFontButton.SelectedFont.Size := lFont.FontSize;
  fFontButton.SelectedFont.Color := lFont.FontColor;
  fFontButton.SelectedFont.Style := [];
  if lFont.Bold then
    fFontButton.SelectedFont.Style := fFontButton.SelectedFont.Style + [fsBold];
  if lFont.Italic then
    fFontButton.SelectedFont.Style := fFontButton.SelectedFont.Style + [fsItalic];
  fFontButton.UpdateCaption;
end;

procedure TRecorderVibrationFontPresetCombo.LoadPresets;
var
  I: Integer;
begin
  Items.BeginUpdate;
  try
    Items.Clear;
    if fManager <> nil then
      for I := 0 to fManager.Count - 1 do
        Items.Add(fManager.Items[I].Name);
  finally
    Items.EndUpdate;
  end;
end;

procedure TRecorderVibrationTagSelectButton.Click;
var
  lTag: TRecorderTag;
begin
  inherited Click;
  if (fTagEdit = nil) or not ShowRecorderTagPickerDialog(Owner, fRegistry,
    fTagEdit.Text, True, lTag) then Exit;
  fSelectedTag := lTag;
  fTagEdit.Text := lTag.Name;
end;

function EnsureSpectrumBinding(ARegistry: TRecorderTagRegistry;
  const ATagName: string): Boolean;
var
  I, J: Integer;
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
  lTag: TRecorderTag;
begin
  Result := False;
  if (ARegistry = nil) or (ARegistry.SpectrumConfigs = nil) or
    (Trim(ATagName) = '') then Exit;
  for I := 0 to ARegistry.SpectrumConfigs.NodeCount - 1 do
  begin
    lNode := ARegistry.SpectrumConfigs.Nodes[I];
    for J := 0 to lNode.BindingCount - 1 do
      if SameText(lNode.Bindings[J].SourceTagName, ATagName) then
      begin
        { График сохраняет выбранное окно, а отдельный RectRms используется
          для полосовой энергии и интегрированных виброоценок. }
        lBinding := lNode.Bindings[J];
        lSettings := lBinding.ResolveSettings(lNode.Settings);
        lTag := ARegistry.FindByName(ATagName);
        if (lTag <> nil) and (lTag.PollFrequencyHz > 0.0) then
          lSettings.SampleRateHz := lTag.PollFrequencyHz;
        lSettings.CalculateBandRms := True;
        lSettings.CalculateBandMaximumFrequency := True;
        lSettings.WindowKind := swkRect;
        lBinding.UseOwnSettings := True;
        lBinding.Settings := lSettings;
        Exit(True);
      end;
  end;
  lNode := ARegistry.SpectrumConfigs.FindNode(CDefaultVibrationSpectrumNode);
  if lNode = nil then
  begin
    lNode := ARegistry.SpectrumConfigs.AddNode(CDefaultVibrationSpectrumNode,
      'Виброоценки');
    lSettings.SetDefaults;
    lSettings.FFTSize := 8192;
    lSettings.WindowKind := swkRect;
    lSettings.NormalizeMode := snmNone;
    lSettings.CalculateBandRms := True;
    lSettings.CalculateBandMaximumFrequency := True;
    lSettings.KeepPhase := False;
    lNode.Settings := lSettings;
  end;
  lBinding := lNode.AddBinding(ATagName);
  lSettings := lBinding.ResolveSettings(lNode.Settings);
  lTag := ARegistry.FindByName(ATagName);
  if (lTag <> nil) and (lTag.PollFrequencyHz > 0.0) then
    lSettings.SampleRateHz := lTag.PollFrequencyHz;
  lSettings.WindowKind := swkRect;
  lSettings.CalculateBandRms := True;
  lSettings.CalculateBandMaximumFrequency := True;
  lBinding.UseOwnSettings := True;
  lBinding.Settings := lSettings;
  Result := True;
end;

function ShowRecorderVibrationEstimateSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderVibrationEstimateComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lForm: TForm;
  lQuantityCombo, lBandCombo, lValueModeCombo: TComboBox;
  lTagEdit, lCaptionEdit, lFormatEdit: TEdit;
  lUseTagName: TCheckBox;
  lOk, lCancel: TButton;
  lSelectTag: TRecorderVibrationTagSelectButton;
  lSelectFont: TRecorderVibrationFontButton;
  lFontPreset: TRecorderVibrationFontPresetCombo;
  I: Integer;
  lTag: TRecorderTag;
  lChanged: Boolean;
  lManager: TRecorderSpectrumRuntimeManager;

begin
  Result := False;
  lForm := TForm.CreateNew(AOwner);
  try
    lForm.Caption := 'Настройка виброоценки';
    lForm.BorderStyle := bsSizeable;
    lForm.SetBounds(0, 0, 540, 420);
    lForm.Constraints.MinWidth := 540;
    lForm.Constraints.MinHeight := 420;
    lForm.Position := poScreenCenter;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Исходный тег'; SetBounds(12, 20, 150, 23); end;
    lTagEdit := TEdit.Create(lForm); lTagEdit.Parent := lForm;
    lTagEdit.ReadOnly := True; lTagEdit.SetBounds(175, 14, 305, 28);
    lTagEdit.Anchors := [akLeft, akTop, akRight];
    lTagEdit.Text := AComponent.TagName;
    lSelectTag := TRecorderVibrationTagSelectButton.Create(lForm);
    lSelectTag.Parent := lForm;
    lSelectTag.Caption := '...'; lSelectTag.SetBounds(486, 14, 34, 28);
    lSelectTag.Anchors := [akTop, akRight];
    lSelectTag.Registry := ATagRegistry;
    lSelectTag.TagEdit := lTagEdit;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Подпись'; SetBounds(12, 60, 150, 23); end;
    lCaptionEdit := TEdit.Create(lForm); lCaptionEdit.Parent := lForm;
    lCaptionEdit.SetBounds(175, 54, 345, 28); lCaptionEdit.Text := AComponent.Caption;
    lCaptionEdit.Anchors := [akLeft, akTop, akRight];
    lUseTagName := TCheckBox.Create(lForm); lUseTagName.Parent := lForm;
    lUseTagName.Caption := 'Использовать имя исходного тега';
    lUseTagName.SetBounds(175, 90, 345, 24); lUseTagName.Checked := AComponent.UseSourceTagName;
    lUseTagName.AutoSize := True;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Величина'; SetBounds(12, 130, 150, 23); end;
    lQuantityCombo := TComboBox.Create(lForm); lQuantityCombo.Parent := lForm;
    lQuantityCombo.Style := csDropDownList; lQuantityCombo.SetBounds(175, 124, 345, 28);
    lQuantityCombo.Anchors := [akLeft, akTop, akRight];
    for I := Ord(Low(TRecorderVibrationQuantity)) to Ord(High(TRecorderVibrationQuantity)) do
      lQuantityCombo.Items.Add(RecorderVibrationQuantityCaption(TRecorderVibrationQuantity(I)));
    lQuantityCombo.ItemIndex := Ord(AComponent.Quantity);
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Полоса'; SetBounds(12, 170, 150, 23); end;
    lBandCombo := TComboBox.Create(lForm); lBandCombo.Parent := lForm;
    lBandCombo.Style := csDropDownList; lBandCombo.SetBounds(175, 164, 345, 28);
    lBandCombo.Anchors := [akLeft, akTop, akRight];
    lBandCombo.Items.Add('Вся полоса'); lBandCombo.ItemIndex := 0;
    for I := 0 to ATagRegistry.FrequencyBands.BandCount - 1 do
    begin
      lBandCombo.Items.Add(ATagRegistry.FrequencyBands.Bands[I].Name);
      if SameText(AComponent.BandName, ATagRegistry.FrequencyBands.Bands[I].Name) then
        lBandCombo.ItemIndex := I + 1;
    end;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Представление'; SetBounds(12, 210, 150, 23); end;
    lValueModeCombo := TComboBox.Create(lForm); lValueModeCombo.Parent := lForm;
    lValueModeCombo.Style := csDropDownList;
    lValueModeCombo.SetBounds(175, 204, 160, 28);
    lValueModeCombo.Items.Add('СКО');
    lValueModeCombo.Items.Add('Амплитуда');
    if AComponent.AmplitudeMode then lValueModeCombo.ItemIndex := 1
    else lValueModeCombo.ItemIndex := 0;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Формат'; SetBounds(350, 210, 65, 23); end;
    lFormatEdit := TEdit.Create(lForm); lFormatEdit.Parent := lForm;
    lFormatEdit.SetBounds(420, 204, 100, 28); lFormatEdit.Text := AComponent.DisplayFormat;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Преднастроенный шрифт'; SetBounds(12, 250, 158, 23); end;
    lFontPreset := TRecorderVibrationFontPresetCombo.Create(lForm);
    lFontPreset.Parent := lForm;
    lFontPreset.SetBounds(175, 244, 345, 28);
    lFontPreset.Anchors := [akLeft, akTop, akRight];
    lFontPreset.Manager := AComponent.NamedFonts;
    lFontPreset.Text := AComponent.NamedFontName;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Параметры шрифта'; SetBounds(12, 290, 158, 23); end;
    lSelectFont := TRecorderVibrationFontButton.Create(lForm);
    lSelectFont.Parent := lForm;
    lSelectFont.SelectedFont.Name := AComponent.FontName;
    lSelectFont.SelectedFont.Size := AComponent.FontSize;
    lSelectFont.SelectedFont.Color := AComponent.FontColor;
    lSelectFont.SelectedFont.Style := [];
    if AComponent.FontStyleBold then
      lSelectFont.SelectedFont.Style := lSelectFont.SelectedFont.Style + [fsBold];
    if AComponent.FontStyleItalic then
      lSelectFont.SelectedFont.Style := lSelectFont.SelectedFont.Style + [fsItalic];
    lSelectFont.UpdateCaption;
    lSelectFont.SetBounds(175, 284, 345, 30);
    lSelectFont.Anchors := [akLeft, akTop, akRight];
    lFontPreset.FontButton := lSelectFont;
    lFontPreset.LoadPresets;
    lFontPreset.Text := AComponent.NamedFontName;
    lFontPreset.Change;
    lOk := TButton.Create(lForm); lOk.Parent := lForm; lOk.Caption := 'OK';
    lOk.ModalResult := mrOk; lOk.Default := True; lOk.SetBounds(346, 350, 82, 30);
    lOk.Anchors := [akRight, akBottom];
    lCancel := TButton.Create(lForm); lCancel.Parent := lForm; lCancel.Caption := 'Отмена';
    lCancel.ModalResult := mrCancel; lCancel.Cancel := True; lCancel.SetBounds(438, 350, 82, 30);
    lCancel.Anchors := [akRight, akBottom];
    for I := 0 to lForm.ControlCount - 1 do
      if lForm.Controls[I] is TLabel then
        TLabel(lForm.Controls[I]).AutoSize := True;
    if lForm.ShowModal <> mrOk then Exit;
    lTag := lSelectTag.SelectedTag;
    if (lTag = nil) and (ATagRegistry <> nil) then
      lTag := ATagRegistry.FindByName(lTagEdit.Text);
    if not RecorderTagCanProvideBlocks(lTag) then
    begin
      MessageDlg('Выберите блочный исходный тег.', mtWarning, [mbOK], 0);
      Exit;
    end;
    AComponent.TagId := lTag.Id;
    AComponent.TagName := lTag.Name;
    AComponent.Caption := Trim(lCaptionEdit.Text);
    AComponent.UseSourceTagName := lUseTagName.Checked;
    AComponent.Quantity := TRecorderVibrationQuantity(lQuantityCombo.ItemIndex);
    AComponent.OutputUnit := RecorderVibrationDefaultUnit(AComponent.Quantity);
    if lBandCombo.ItemIndex <= 0 then AComponent.BandName := ''
    else AComponent.BandName := lBandCombo.Items[lBandCombo.ItemIndex];
    AComponent.DisplayFormat := Trim(lFormatEdit.Text);
    AComponent.AmplitudeMode := lValueModeCombo.ItemIndex = 1;
    if AComponent.DisplayFormat = '' then AComponent.DisplayFormat := '0.###';
    AComponent.FontName := lSelectFont.SelectedFont.Name;
    AComponent.FontSize := lSelectFont.SelectedFont.Size;
    AComponent.FontColor := lSelectFont.SelectedFont.Color;
    AComponent.FontStyleBold := fsBold in lSelectFont.SelectedFont.Style;
    AComponent.FontStyleItalic := fsItalic in lSelectFont.SelectedFont.Style;
    AComponent.NamedFontName := Trim(lFontPreset.Text);
    if (AComponent.NamedFontName <> '') and (AComponent.NamedFonts <> nil) then
      AComponent.NamedFonts.Define(AComponent.NamedFontName,
        AComponent.FontName, AComponent.FontSize, AComponent.FontColor,
        AComponent.FontStyleBold, AComponent.FontStyleItalic);
    lChanged := EnsureSpectrumBinding(ATagRegistry, lTag.Name);
    if lChanged then
    begin
      lManager := TRecorderSpectrumRuntimeManager.Instance;
      if lManager <> nil then lManager.PrepareConfiguration;
    end;
    Result := True;
  finally
    lForm.Free;
  end;
end;

end.
