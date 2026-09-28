unit uRecorderPhaseAlgorithmFrame;

{ Визуальные настройки относительной фазы двух каналов. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Spin,
  uRecorderAlgorithmEditorFrame;

type
  TRecorderPhaseAlgorithmFrame = class(TRecorderAlgorithmEditorFrame)
    cbReferenceTag: TComboBox;
    cbSignalTag: TComboBox;
    edOutputTag: TEdit;
    gbInputs: TGroupBox;
    gbSpectrum: TGroupBox;
    lblFFTSize: TLabel;
    lblHarmonic: TLabel;
    lblMaximumFrequency: TLabel;
    lblMinimumAmplitude: TLabel;
    lblMinimumFrequency: TLabel;
    lblOutputTag: TLabel;
    lblReferenceTag: TLabel;
    lblSampleRate: TLabel;
    lblSignalTag: TLabel;
    seFFTSize: TSpinEdit;
    seHarmonic: TSpinEdit;
    seMaximumFrequency: TFloatSpinEdit;
    seMinimumAmplitude: TFloatSpinEdit;
    seMinimumFrequency: TFloatSpinEdit;
    seSampleRate: TFloatSpinEdit;
    procedure cbSignalTagChange(Sender: TObject);
  protected
    procedure LoadFromAlgorithm; override;
    procedure SaveToAlgorithm; override;
  private
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

procedure TRecorderPhaseAlgorithmFrame.SuggestOutputName;
begin
  if (Trim(edOutputTag.Text) = '') and (Trim(cbSignalTag.Text) <> '') then
    edOutputTag.Text := Trim(cbSignalTag.Text) + '_Phase';
end;

procedure TRecorderPhaseAlgorithmFrame.cbSignalTagChange(Sender: TObject);
begin
  SuggestOutputName;
end;

procedure TRecorderPhaseAlgorithmFrame.LoadFromAlgorithm;
begin
  FillTagCombo(cbSignalTag);
  FillTagCombo(cbReferenceTag);
  cbSignalTag.Text := BindingName(0);
  cbReferenceTag.Text := BindingName(1);
  if Algorithm = nil then
    Exit;
  edOutputTag.Text := RecorderAlgorithmProperty(Algorithm.Properties,
    'OutputTag', RecorderAlgorithmProperty(Algorithm.Properties,
    'OutChannel', ''));
  seFFTSize.Value := PropertyInteger(Algorithm.Properties, 'FFTSize',
    PropertyInteger(Algorithm.Properties, 'FFTCount', 1024));
  seSampleRate.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'SampleRateHz', 0);
  seMinimumFrequency.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'MinimumFrequencyHz', 0);
  seMaximumFrequency.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'MaximumFrequencyHz', 20000);
  seMinimumAmplitude.Value := RecorderAlgorithmFloat(Algorithm.Properties,
    'MinimumAmplitude', 0);
  seHarmonic.Value := PropertyInteger(Algorithm.Properties, 'Harmonic', 1);
  SuggestOutputName;
end;

procedure TRecorderPhaseAlgorithmFrame.SaveToAlgorithm;
var
  lProperties: string;
begin
  if Algorithm = nil then
    Exit;
  SuggestOutputName;
  SetBindingName(0, cbSignalTag.Text, 'Role=Signal');
  SetBindingName(1, cbReferenceTag.Text, 'Role=Reference');
  lProperties := Algorithm.Properties;
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'OutputTag',
    Trim(edOutputTag.Text));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'FFTSize',
    IntToStr(seFFTSize.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'SampleRateHz',
    RecorderInvariantFloat(seSampleRate.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties,
    'MinimumFrequencyHz', RecorderInvariantFloat(seMinimumFrequency.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties,
    'MaximumFrequencyHz', RecorderInvariantFloat(seMaximumFrequency.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'MinimumAmplitude',
    RecorderInvariantFloat(seMinimumAmplitude.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'Harmonic',
    IntToStr(seHarmonic.Value));
  Algorithm.Properties := lProperties;
end;

initialization
  RegisterRecorderAlgorithmEditor('Phase', TRecorderPhaseAlgorithmFrame);

end.
