unit uRecorderSignalGeneratorView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Spin, Graphics, uOglChart,
  uRecorderVisualControl, uRecorderFormModel, uRecorderTags,
  uRecorderSignalGeneratorModel;

type
  TRecorderSignalGeneratorView = class(TPanel, IVForm)
  private
    fComponent: TRecorderSignalGeneratorComponent;
    fLoading: Boolean;
    fSignalList: TListBox;
    fEditorPanel: TPanel;
    fKindGroup: TRadioGroup;
    fAmplitudeEdit, fFrequencyEdit, fFrequency2Edit: TFloatSpinEdit;
    fSweepTimeEdit, fPhaseEdit, fPhaseVelocityEdit: TFloatSpinEdit;
    fOffsetEdit: TFloatSpinEdit;
    fChangePhaseCheck, fSweepCheck, fLogSweepCheck: TCheckBox;
    fCurrentFrequencyLabel: TLabel;
    function ActiveSignal: TRecorderGeneratedSignal;
    procedure ApplyEditor(Sender: TObject);
    procedure BuildEditor;
    procedure LoadActiveSignal;
    procedure RebuildSignalList;
    procedure SelectSignal(Sender: TObject);
    procedure UpdateSweepControls;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

function NewCaption(AOwner: TWinControl; const AText: string;
  ALeft, ATop, AWidth: Integer): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AOwner;
  Result.Caption := AText;
  Result.SetBounds(ALeft, ATop, AWidth, 18);
end;

function NewFloatEdit(AOwner: TWinControl; ALeft, ATop, AWidth: Integer;
  AOnChange: TNotifyEvent): TFloatSpinEdit;
begin
  Result := TFloatSpinEdit.Create(AOwner);
  Result.Parent := AOwner;
  Result.SetBounds(ALeft, ATop, AWidth, 24);
  Result.DecimalPlaces := 4;
  Result.Increment := 0.1;
  Result.MinValue := -1.0E12;
  Result.MaxValue := 1.0E12;
  Result.OnChange := AOnChange;
end;

constructor TRecorderSignalGeneratorView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvLowered;
  Color := clBtnFace;
  BuildEditor;
end;

procedure TRecorderSignalGeneratorView.BuildEditor;
begin
  fSignalList := TListBox.Create(Self);
  fSignalList.Parent := Self;
  fSignalList.Align := alRight;
  fSignalList.Width := 145;
  fSignalList.OnClick := @SelectSignal;

  fEditorPanel := TPanel.Create(Self);
  fEditorPanel.Parent := Self;
  fEditorPanel.Align := alClient;
  fEditorPanel.BevelOuter := bvNone;

  fKindGroup := TRadioGroup.Create(fEditorPanel);
  fKindGroup.Parent := fEditorPanel;
  fKindGroup.Caption := 'Тип сигнала';
  fKindGroup.Items.Add('Синус');
  fKindGroup.Items.Add('Пила');
  fKindGroup.Items.Add('Шум');
  fKindGroup.SetBounds(8, 6, 92, 94);
  fKindGroup.OnClick := @ApplyEditor;

  NewCaption(fEditorPanel, 'Амплитуда сигнала', 108, 6, 132);
  fAmplitudeEdit := NewFloatEdit(fEditorPanel, 108, 25, 92, @ApplyEditor);
  NewCaption(fEditorPanel, 'F1, Гц', 108, 54, 65);
  fFrequencyEdit := NewFloatEdit(fEditorPanel, 108, 72, 92, @ApplyEditor);
  NewCaption(fEditorPanel, 'F2, Гц', 208, 54, 65);
  fFrequency2Edit := NewFloatEdit(fEditorPanel, 208, 72, 92, @ApplyEditor);
  NewCaption(fEditorPanel, 'T2, сек', 308, 54, 70);
  fSweepTimeEdit := NewFloatEdit(fEditorPanel, 308, 72, 92, @ApplyEditor);

  NewCaption(fEditorPanel, 'Фаза, град.', 8, 105, 92);
  fPhaseEdit := NewFloatEdit(fEditorPanel, 8, 123, 92, @ApplyEditor);
  NewCaption(fEditorPanel, 'град/сек', 108, 105, 92);
  fPhaseVelocityEdit := NewFloatEdit(fEditorPanel, 108, 123, 92, @ApplyEditor);
  fChangePhaseCheck := TCheckBox.Create(fEditorPanel);
  fChangePhaseCheck.Parent := fEditorPanel;
  fChangePhaseCheck.Caption := 'Менять фазу';
  fChangePhaseCheck.SetBounds(208, 122, 112, 24);
  fChangePhaseCheck.OnClick := @ApplyEditor;

  NewCaption(fEditorPanel, 'Смещение', 8, 151, 92);
  fOffsetEdit := NewFloatEdit(fEditorPanel, 8, 169, 92, @ApplyEditor);
  fSweepCheck := TCheckBox.Create(fEditorPanel);
  fSweepCheck.Parent := fEditorPanel;
  fSweepCheck.Caption := 'Sweep';
  fSweepCheck.SetBounds(108, 168, 78, 24);
  fSweepCheck.OnClick := @ApplyEditor;
  fLogSweepCheck := TCheckBox.Create(fEditorPanel);
  fLogSweepCheck.Parent := fEditorPanel;
  fLogSweepCheck.Caption := 'Lg';
  fLogSweepCheck.SetBounds(190, 168, 52, 24);
  fLogSweepCheck.OnClick := @ApplyEditor;
  fCurrentFrequencyLabel := NewCaption(fEditorPanel, '', 250, 171, 150);
end;

function TRecorderSignalGeneratorView.ActiveSignal: TRecorderGeneratedSignal;
begin
  Result := nil;
  if (fComponent = nil) or (fSignalList.ItemIndex < 0) or
    (fSignalList.ItemIndex >= fComponent.SignalCount) then Exit;
  Result := fComponent.Signals[fSignalList.ItemIndex];
end;

procedure TRecorderSignalGeneratorView.RebuildSignalList;
var
  I, lSelection: Integer;
begin
  lSelection := fSignalList.ItemIndex;
  fSignalList.Items.BeginUpdate;
  try
    fSignalList.Clear;
    if fComponent <> nil then
      for I := 0 to fComponent.SignalCount - 1 do
        fSignalList.Items.Add(fComponent.Signals[I].Name);
  finally
    fSignalList.Items.EndUpdate;
  end;
  if fSignalList.Count = 0 then lSelection := -1
  else if (lSelection < 0) or (lSelection >= fSignalList.Count) then
    lSelection := 0;
  fSignalList.ItemIndex := lSelection;
  LoadActiveSignal;
end;

procedure TRecorderSignalGeneratorView.LoadActiveSignal;
var
  lSignal: TRecorderGeneratedSignal;
begin
  lSignal := ActiveSignal;
  fLoading := True;
  try
    fEditorPanel.Enabled := lSignal <> nil;
    if lSignal = nil then Exit;
    fKindGroup.ItemIndex := Ord(lSignal.Kind);
    fAmplitudeEdit.Value := lSignal.Amplitude;
    fFrequencyEdit.Value := lSignal.FrequencyHz;
    fFrequency2Edit.Value := lSignal.SweepEndFrequencyHz;
    fSweepTimeEdit.Value := lSignal.SweepDurationSec;
    fPhaseEdit.Value := lSignal.PhaseDeg;
    fPhaseVelocityEdit.Value := lSignal.PhaseVelocityDegSec;
    fOffsetEdit.Value := lSignal.Offset;
    fChangePhaseCheck.Checked := lSignal.ChangePhase;
    fSweepCheck.Checked := lSignal.SweepEnabled;
    fLogSweepCheck.Checked := lSignal.SweepLogarithmic;
    fCurrentFrequencyLabel.Caption := Format('F = %.4g Гц',
      [lSignal.FrequencyHz]);
    UpdateSweepControls;
  finally
    fLoading := False;
  end;
end;

procedure TRecorderSignalGeneratorView.ApplyEditor(Sender: TObject);
var
  lSignal: TRecorderGeneratedSignal;
begin
  if fLoading then Exit;
  lSignal := ActiveSignal;
  if lSignal = nil then Exit;
  fComponent.BeginSignalEdit;
  try
    if fKindGroup.ItemIndex >= 0 then
      lSignal.Kind := TRecorderGeneratedSignalKind(fKindGroup.ItemIndex);
    lSignal.Amplitude := fAmplitudeEdit.Value;
    lSignal.FrequencyHz := fFrequencyEdit.Value;
    lSignal.SweepEndFrequencyHz := fFrequency2Edit.Value;
    lSignal.SweepDurationSec := fSweepTimeEdit.Value;
    lSignal.PhaseDeg := fPhaseEdit.Value;
    lSignal.PhaseVelocityDegSec := fPhaseVelocityEdit.Value;
    lSignal.Offset := fOffsetEdit.Value;
    lSignal.ChangePhase := fChangePhaseCheck.Checked;
    lSignal.SweepEnabled := fSweepCheck.Checked;
    lSignal.SweepLogarithmic := fLogSweepCheck.Checked;
  finally
    fComponent.EndSignalEdit;
  end;
  fCurrentFrequencyLabel.Caption := Format('F = %.4g Гц',
    [lSignal.FrequencyHz]);
  UpdateSweepControls;
end;

procedure TRecorderSignalGeneratorView.UpdateSweepControls;
begin
  fFrequency2Edit.Visible := fSweepCheck.Checked;
  fSweepTimeEdit.Visible := fSweepCheck.Checked;
  fLogSweepCheck.Visible := fSweepCheck.Checked;
end;

procedure TRecorderSignalGeneratorView.SelectSignal(Sender: TObject);
begin
  LoadActiveSignal;
end;

procedure TRecorderSignalGeneratorView.Configure(
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderSignalGeneratorComponent(AComponent);
  RebuildSignalList;
end;

procedure TRecorderSignalGeneratorView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
begin
  { Runtime controls apply changes directly; repaint must not overwrite edits. }
end;

function TRecorderSignalGeneratorView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderSignalGeneratorComponent, TRecorderSignalGeneratorView);

end.
