unit uRecorderTachoAlgorithmFrame;

{ Визуальные настройки тахометра. Фрейм редактирует только конфигурацию;
  накопление отсчётов и расчёт остаются в TRecorderTachoAlgorithm. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Spin,
  uRecorderAlgorithmEditorFrame;

type
  TRecorderTachoAlgorithmFrame = class(TRecorderAlgorithmEditorFrame)
    cbInputTag: TComboBox;
    cbMode: TComboBox;
    gbCommon: TGroupBox;
    gbSpectrum: TGroupBox;
    gbThresholds: TGroupBox;
    lblFFTSize: TLabel;
    lblHighPercent: TLabel;
    lblInputTag: TLabel;
    lblLowPercent: TLabel;
    lblMaximumFrequency: TLabel;
    lblMinimumAmplitude: TLabel;
    lblMinimumFrequency: TLabel;
    lblMode: TLabel;
    lblOutputTag: TLabel;
    lblPeriod: TLabel;
    lblSampleRate: TLabel;
    edOutputTag: TEdit;
    seFFTSize: TSpinEdit;
    seHighPercent: TFloatSpinEdit;
    seLowPercent: TFloatSpinEdit;
    seMaximumFrequency: TFloatSpinEdit;
    seMinimumAmplitude: TFloatSpinEdit;
    seMinimumFrequency: TFloatSpinEdit;
    sePeriod: TFloatSpinEdit;
    seSampleRate: TFloatSpinEdit;
    procedure cbInputTagChange(Sender: TObject);
    procedure cbModeChange(Sender: TObject);
  protected
    procedure LoadFromAlgorithm; override;
    procedure SaveToAlgorithm; override;
  private
    procedure UpdateModeControls;
    procedure SuggestOutputName;
  end;

implementation

{$R *.lfm}

function PropertyInteger(const AProperties, AName: string;
  ADefault: Integer): Integer;
begin
  Result := StrToIntDef(RecorderAlgorithmProperty(AProperties, AName, ''),
    ADefault);
end;

procedure TRecorderTachoAlgorithmFrame.UpdateModeControls;
begin
  gbThresholds.Enabled := cbMode.ItemIndex = 0;
  gbSpectrum.Enabled := cbMode.ItemIndex = 1;
end;

procedure TRecorderTachoAlgorithmFrame.SuggestOutputName;
begin
  if (Trim(edOutputTag.Text) = '') and (Trim(cbInputTag.Text) <> '') then
    edOutputTag.Text := Trim(cbInputTag.Text) + '_Tacho';
end;

procedure TRecorderTachoAlgorithmFrame.cbInputTagChange(Sender: TObject);
begin
  SuggestOutputName;
end;

procedure TRecorderTachoAlgorithmFrame.cbModeChange(Sender: TObject);
begin
  UpdateModeControls;
end;

procedure TRecorderTachoAlgorithmFrame.LoadFromAlgorithm;
var
  lMode: string;
begin
  FillTagCombo(cbInputTag);
  cbInputTag.Text := BindingName(0);
  if Algorithm = nil then
    Exit;

  lMode := RecorderAlgorithmProperty(Algorithm.Properties, 'Mode',
    RecorderAlgorithmProperty(Algorithm.Properties, 'TahoType', 'Threshold'));
  if SameText(lMode, 'Spectrum') or SameText(lMode, 'FFT') then
    cbMode.ItemIndex := 1
  else
    cbMode.ItemIndex := 0;
  edOutputTag.Text := RecorderAlgorithmProperty(Algorithm.Properties,
    'OutputTag', '');
  sePeriod.Value := RecorderAlgorithmFloat(Algorithm.Properties, 'PeriodSec',
    RecorderAlgorithmFloat(Algorithm.Properties, 'Period', 0.1));
  seLowPercent.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'LowPercent', RecorderAlgorithmFloat(Algorithm.Properties, 'LLo', 30));
  seHighPercent.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'HighPercent', RecorderAlgorithmFloat(Algorithm.Properties, 'LHi', 70));
  seMinimumAmplitude.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'MinimumAmplitude', RecorderAlgorithmFloat(Algorithm.Properties,
    'MinValue', 0.1));
  seSampleRate.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'SampleRateHz', 0);
  seFFTSize.Value := PropertyInteger(Algorithm.Properties, 'FFTSize',
    PropertyInteger(Algorithm.Properties, 'FFTCount', 16384));
  seMinimumFrequency.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'MinimumFrequencyHz', RecorderAlgorithmFloat(Algorithm.Properties,
    'FFTBand1', 0));
  seMaximumFrequency.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'MaximumFrequencyHz', RecorderAlgorithmFloat(Algorithm.Properties,
    'FFTBand2', 20000));
  SuggestOutputName;
  UpdateModeControls;
end;

procedure TRecorderTachoAlgorithmFrame.SaveToAlgorithm;
var
  lProperties: string;
  lMode: string;
begin
  if Algorithm = nil then
    Exit;
  SuggestOutputName;
  SetBindingName(0, cbInputTag.Text, 'Role=Input');
  if cbMode.ItemIndex = 1 then
    lMode := 'Spectrum'
  else
    lMode := 'Threshold';
  lProperties := Algorithm.Properties;
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'Mode', lMode);
  if cbMode.ItemIndex = 1 then
    lProperties := RecorderSetAlgorithmProperty(lProperties, 'TahoType', 'FFT')
  else
    lProperties := RecorderSetAlgorithmProperty(lProperties, 'TahoType', 'Level');
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'OutputTag',
    Trim(edOutputTag.Text));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'PeriodSec',
    RecorderInvariantFloat(sePeriod.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'LowPercent',
    RecorderInvariantFloat(seLowPercent.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'HighPercent',
    RecorderInvariantFloat(seHighPercent.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'MinimumAmplitude',
    RecorderInvariantFloat(seMinimumAmplitude.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'SampleRateHz',
    RecorderInvariantFloat(seSampleRate.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'FFTSize',
    IntToStr(seFFTSize.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties,
    'MinimumFrequencyHz', RecorderInvariantFloat(seMinimumFrequency.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties,
    'MaximumFrequencyHz', RecorderInvariantFloat(seMaximumFrequency.Value));
  Algorithm.Properties := lProperties;
end;

initialization
  RegisterRecorderAlgorithmEditor('Tacho', TRecorderTachoAlgorithmFrame);

end.
