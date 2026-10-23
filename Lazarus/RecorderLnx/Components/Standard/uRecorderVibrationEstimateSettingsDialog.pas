unit uRecorderVibrationEstimateSettingsDialog;
{ Designer-owned settings. Source capability uses the effective tag unit, not
  inactive calibration metadata. Calculations belong to the spectrum layer. }
{$mode objfpc}{$H+}
{$codepage UTF8}
interface
uses Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Graphics,
  uRecorderFormModel, uRecorderTags, uRecorderVibrationEstimate;
type
  TRecorderVibrationEstimateSettingsForm = class(TForm)
  published
    SourceLabel, CaptionLabel, QuantityLabel, BandLabel, ModeLabel,
      FormatLabel, PresetLabel, FontLabel, FromLabel, ToLabel: TLabel;
    TagEdit, CaptionEdit, FormatEdit, FromEdit, ToEdit: TEdit;
    SelectTagButton, SelectFontButton, OkButton, CancelButton: TButton;
    UseTagNameCheck, HoldMaximumCheck: TCheckBox;
    QuantityCombo, BandCombo, ValueModeCombo, FontPresetCombo: TComboBox;
    FontDialog: TFontDialog;
    procedure SelectTagClick(Sender: TObject);
    procedure SelectFontClick(Sender: TObject);
    procedure FontPresetChange(Sender: TObject);
    procedure BandChange(Sender: TObject);
  private
    fRegistry: TRecorderTagRegistry;
    fModel: TRecorderVibrationEstimateComponent;
    fSelectedFont: TFont;
    function SelectedQuantity: TRecorderVibrationQuantity;
    procedure UpdateQuantities(AQuantity: TRecorderVibrationQuantity);
    procedure UpdateFontCaption;
    procedure LoadSettings;
    procedure SaveSettings(ATag: TRecorderTag);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;
function ShowRecorderVibrationEstimateSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderVibrationEstimateComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
implementation
uses Math, uRecorderSpectrumEngine, uRecorderSpectrumRuntime, uRecorderTagPickerDialog;
{$R *.lfm}
const CDefaultVibrationSpectrumNode = 'spectrum.vibration.default';
const CManualBandIndex = 1;

procedure TRecorderVibrationEstimateSettingsForm.BandChange(Sender: TObject);
begin
  FromEdit.Enabled := BandCombo.ItemIndex = CManualBandIndex;
  ToEdit.Enabled := FromEdit.Enabled;
  FromLabel.Enabled := FromEdit.Enabled;
  ToLabel.Enabled := FromEdit.Enabled;
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


constructor TRecorderVibrationEstimateSettingsForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fSelectedFont := TFont.Create;
end;
destructor TRecorderVibrationEstimateSettingsForm.Destroy;
begin
  fSelectedFont.Free;
  inherited Destroy;
end;
function TRecorderVibrationEstimateSettingsForm.SelectedQuantity:
  TRecorderVibrationQuantity;
begin
  if QuantityCombo.ItemIndex < 0 then Exit(rvqAmplitude);
  Result := TRecorderVibrationQuantity(
    PtrInt(QuantityCombo.Items.Objects[QuantityCombo.ItemIndex]));
end;
procedure TRecorderVibrationEstimateSettingsForm.UpdateQuantities(
  AQuantity: TRecorderVibrationQuantity);
var
  lTag: TRecorderTag;
  lQuantity: TRecorderVibrationQuantity;
  lVibration: Boolean;
  lIndex: Integer;
begin
  lTag := nil;
  if fRegistry <> nil then lTag := fRegistry.FindByName(TagEdit.Text);
  lVibration := (lTag <> nil) and RecorderIsVibrationUnit(lTag.UnitName);
  QuantityCombo.Items.Clear;
  for lQuantity := Low(TRecorderVibrationQuantity) to High(TRecorderVibrationQuantity) do
  begin
    if lVibration and (lQuantity = rvqAmplitude) then Continue;
    if not lVibration and
      not (lQuantity in [rvqAmplitude, rvqDominantFrequency]) then Continue;
    lIndex := QuantityCombo.Items.AddObject(RecorderVibrationQuantityCaption(lQuantity),
      TObject(PtrInt(lQuantity)));
    if lQuantity = AQuantity then QuantityCombo.ItemIndex := lIndex;
  end;
  if QuantityCombo.ItemIndex < 0 then
    if not lVibration then QuantityCombo.ItemIndex :=
      QuantityCombo.Items.IndexOfObject(TObject(PtrInt(rvqAmplitude)))
    else QuantityCombo.ItemIndex := 0;
end;
procedure TRecorderVibrationEstimateSettingsForm.SelectTagClick(Sender: TObject);
var
  lTag: TRecorderTag;
  lQuantity: TRecorderVibrationQuantity;
begin
  lQuantity := SelectedQuantity;
  if not ShowRecorderTagPickerDialog(Self, fRegistry, TagEdit.Text, True, lTag) then Exit;
  TagEdit.Text := lTag.Name;
  UpdateQuantities(lQuantity);
end;
procedure TRecorderVibrationEstimateSettingsForm.UpdateFontCaption;
begin
  SelectFontButton.Caption := Format('%s, %d', [fSelectedFont.Name, fSelectedFont.Size]);
end;
procedure TRecorderVibrationEstimateSettingsForm.SelectFontClick(Sender: TObject);
begin
  FontDialog.Font.Assign(fSelectedFont);
  if not FontDialog.Execute then Exit;
  fSelectedFont.Assign(FontDialog.Font);
  UpdateFontCaption;
end;
procedure TRecorderVibrationEstimateSettingsForm.FontPresetChange(Sender: TObject);
var
  lFont: TRecorderNamedFont;
begin
  if (fModel = nil) or (fModel.NamedFonts = nil) then Exit;
  lFont := fModel.NamedFonts.Find(FontPresetCombo.Text);
  if lFont = nil then Exit;
  fSelectedFont.Name := lFont.FontName;
  fSelectedFont.Size := lFont.FontSize;
  fSelectedFont.Color := lFont.FontColor;
  fSelectedFont.Style := [];
  if lFont.Bold then fSelectedFont.Style := fSelectedFont.Style + [fsBold];
  if lFont.Italic then fSelectedFont.Style := fSelectedFont.Style + [fsItalic];
  UpdateFontCaption;
end;
procedure TRecorderVibrationEstimateSettingsForm.LoadSettings;
var
  I: Integer;
begin
  TagEdit.Text := fModel.TagName;
  CaptionEdit.Text := fModel.Caption;
  UseTagNameCheck.Checked := fModel.UseSourceTagName;
  HoldMaximumCheck.Checked := fModel.HoldMaximum;
  FormatEdit.Text := fModel.DisplayFormat;
  UpdateQuantities(fModel.Quantity);
  BandCombo.Items.Add('Вся полоса');
  BandCombo.Items.Add('Задать вручную');
  BandCombo.ItemIndex := 0;
  if (fRegistry <> nil) and (fRegistry.FrequencyBands <> nil) then
    for I := 0 to fRegistry.FrequencyBands.BandCount - 1 do
    begin
      BandCombo.Items.Add(fRegistry.FrequencyBands.Bands[I].Name);
      if SameText(fModel.BandName, fRegistry.FrequencyBands.Bands[I].Name) then
        BandCombo.ItemIndex := I + 2;
    end;
  if fModel.ManualBand then BandCombo.ItemIndex := CManualBandIndex;
  FromEdit.Text := FloatToStr(fModel.BandFromHz);
  ToEdit.Text := FloatToStr(fModel.BandToHz);
  BandChange(nil);
  ValueModeCombo.ItemIndex := Ord(fModel.AmplitudeMode);
  fSelectedFont.Name := fModel.FontName;
  fSelectedFont.Size := fModel.FontSize;
  fSelectedFont.Color := fModel.FontColor;
  fSelectedFont.Style := [];
  if fModel.FontStyleBold then fSelectedFont.Style := fSelectedFont.Style + [fsBold];
  if fModel.FontStyleItalic then fSelectedFont.Style := fSelectedFont.Style + [fsItalic];
  if fModel.NamedFonts <> nil then
    for I := 0 to fModel.NamedFonts.Count - 1 do
      FontPresetCombo.Items.Add(fModel.NamedFonts.Items[I].Name);
  FontPresetCombo.Text := fModel.NamedFontName;
  FontPresetChange(nil);
  UpdateFontCaption;
end;
procedure TRecorderVibrationEstimateSettingsForm.SaveSettings(ATag: TRecorderTag);
begin
  fModel.TagId := ATag.Id;
  fModel.TagName := ATag.Name;
  fModel.Caption := Trim(CaptionEdit.Text);
  fModel.UseSourceTagName := UseTagNameCheck.Checked;
  fModel.Quantity := SelectedQuantity;
  if fModel.Quantity = rvqAmplitude then fModel.OutputUnit := ATag.UnitName
  else fModel.OutputUnit := RecorderVibrationDefaultUnit(fModel.Quantity);
  fModel.ManualBand := BandCombo.ItemIndex = CManualBandIndex;
  if fModel.ManualBand then
  begin
    fModel.BandFromHz := StrToFloat(FromEdit.Text);
    fModel.BandToHz := StrToFloat(ToEdit.Text);
  end;
  if BandCombo.ItemIndex <= CManualBandIndex then fModel.BandName := ''
  else fModel.BandName := BandCombo.Items[BandCombo.ItemIndex];
  fModel.DisplayFormat := Trim(FormatEdit.Text);
  if fModel.DisplayFormat = '' then fModel.DisplayFormat := '0.###';
  fModel.AmplitudeMode := ValueModeCombo.ItemIndex = 1;
  fModel.HoldMaximum := HoldMaximumCheck.Checked;
  fModel.FontName := fSelectedFont.Name;
  fModel.FontSize := fSelectedFont.Size;
  fModel.FontColor := fSelectedFont.Color;
  fModel.FontStyleBold := fsBold in fSelectedFont.Style;
  fModel.FontStyleItalic := fsItalic in fSelectedFont.Style;
  fModel.NamedFontName := Trim(FontPresetCombo.Text);
  if (fModel.NamedFontName <> '') and (fModel.NamedFonts <> nil) then
    fModel.NamedFonts.Define(fModel.NamedFontName, fModel.FontName,
      fModel.FontSize, fModel.FontColor, fModel.FontStyleBold, fModel.FontStyleItalic);
end;
function ShowRecorderVibrationEstimateSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderVibrationEstimateComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lForm: TRecorderVibrationEstimateSettingsForm;
  lTag: TRecorderTag;
  lManager: TRecorderSpectrumRuntimeManager;
  lFromHz, lToHz: Double;
begin
  Result := False;
  if AComponent = nil then Exit;
  lForm := TRecorderVibrationEstimateSettingsForm.Create(AOwner);
  try
    lForm.fRegistry := ATagRegistry;
    lForm.fModel := AComponent;
    lForm.LoadSettings;
    repeat
      if lForm.ShowModal <> mrOk then Exit;
      if lForm.BandCombo.ItemIndex = CManualBandIndex then
        if not TryStrToFloat(lForm.FromEdit.Text, lFromHz) or
          not TryStrToFloat(lForm.ToEdit.Text, lToHz) or
          IsNan(lFromHz) or IsInfinite(lFromHz) or
          IsNan(lToHz) or IsInfinite(lToHz) or
          (lFromHz < 0) or (lFromHz >= lToHz) then
        begin
          MessageDlg('Задайте полосу в Гц: 0 ≤ от < до, конечные числа.',
            mtWarning, [mbOK], 0);
          Continue;
        end;
      lTag := nil;
      if ATagRegistry <> nil then lTag := ATagRegistry.FindByName(lForm.TagEdit.Text);
      if RecorderTagCanProvideBlocks(lTag) then Break;
      MessageDlg('Выберите блочный исходный тег.', mtWarning, [mbOK], 0);
    until False;
    lForm.SaveSettings(lTag);
    if EnsureSpectrumBinding(ATagRegistry, lTag.Name) then
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
