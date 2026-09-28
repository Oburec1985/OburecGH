unit uRecorderCounterAlgorithmFrame;

{ Visual editor for the pulse counter algorithm. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Spin,
  uRecorderTags, uRecorderAlgorithmManager, uRecorderAlgorithmEditorFrame;

type
  TRecorderCounterAlgorithmFrame = class(TRecorderAlgorithmEditorFrame)
    cbGate: TComboBox;
    cbInput: TComboBox;
    cbReset: TComboBox;
    cbShift: TComboBox;
    chkKeepValue: TCheckBox;
    chkRelative: TCheckBox;
    edOutput: TEdit;
    fsHighThreshold: TFloatSpinEdit;
    fsLowThreshold: TFloatSpinEdit;
    fsMinimumAmplitude: TFloatSpinEdit;
    gbControl: TGroupBox;
    gbSignal: TGroupBox;
    lbGate: TLabel;
    lbHighThreshold: TLabel;
    lbInput: TLabel;
    lbLowThreshold: TLabel;
    lbMinimumAmplitude: TLabel;
    lbOutput: TLabel;
    lbReset: TLabel;
    lbShift: TLabel;
  private
    procedure AppendBinding(const ATagName, AProperties: string);
  protected
    procedure LoadFromAlgorithm; override;
    procedure SaveToAlgorithm; override;
  end;

implementation

{$R *.lfm}

function PropertyIsTrue(const AProperties, AName: string;
  ADefault: Boolean): Boolean;
var
  lValue: string;
begin
  lValue := LowerCase(RecorderAlgorithmProperty(AProperties, AName, ''));
  if (lValue = '1') or (lValue = 'true') or (lValue = 'yes') then
    Exit(True);
  if (lValue = '0') or (lValue = 'false') or (lValue = 'no') then
    Exit(False);
  Result := ADefault;
end;

procedure TRecorderCounterAlgorithmFrame.AppendBinding(const ATagName,
  AProperties: string);
var
  lBinding: TRecorderAlgorithmBinding;
  lTag: TRecorderTag;
begin
  if Trim(ATagName) = '' then
    Exit;
  lTag := nil;
  if TagRegistry <> nil then
    lTag := TagRegistry.FindByName(Trim(ATagName));
  lBinding := Algorithm.AddBinding(lTag, AProperties);
  if lTag = nil then
    lBinding.TagName := Trim(ATagName);
end;

procedure TRecorderCounterAlgorithmFrame.LoadFromAlgorithm;
var
  I: Integer;
  lRole: string;
begin
  FillTagCombo(cbInput);
  FillTagCombo(cbGate);
  FillTagCombo(cbReset);
  FillTagCombo(cbShift);
  cbInput.Text := '';
  cbGate.Text := '';
  cbReset.Text := '';
  cbShift.Text := '';
  if Algorithm = nil then
    Exit;

  for I := 0 to Algorithm.BindingCount - 1 do
  begin
    lRole := LowerCase(RecorderAlgorithmProperty(
      Algorithm.Binding(I).Properties, 'Role', ''));
    if (I = 0) and (lRole = '') then
      cbInput.Text := Algorithm.Binding(I).TagName
    else if (lRole = 'gate') or (lRole = 'trig') then
      cbGate.Text := Algorithm.Binding(I).TagName
    else if (lRole = 'reset') or (lRole = 'null') then
      cbReset.Text := Algorithm.Binding(I).TagName
    else if lRole = 'shift' then
      cbShift.Text := Algorithm.Binding(I).TagName;
  end;

  fsLowThreshold.Value := RecorderAlgorithmFloat(
    Algorithm.Properties, 'Lo', 30);
  fsHighThreshold.Value := RecorderAlgorithmFloat(
    Algorithm.Properties, 'Hi', 70);
  fsMinimumAmplitude.Value := RecorderAlgorithmFloat(
    Algorithm.Properties, 'MinThreshold', 0);
  chkRelative.Checked := PropertyIsTrue(
    Algorithm.Properties, 'Relative', True);
  chkKeepValue.Checked := PropertyIsTrue(
    Algorithm.Properties, 'SaveVal', False);
  edOutput.Text := RecorderAlgorithmProperty(
    Algorithm.Properties, 'OutChannel', '');
end;

procedure TRecorderCounterAlgorithmFrame.SaveToAlgorithm;
var
  lProperties: string;
begin
  if Algorithm = nil then
    Exit;

  lProperties := Algorithm.Properties;
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'Lo',
    RecorderInvariantFloat(fsLowThreshold.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'Hi',
    RecorderInvariantFloat(fsHighThreshold.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'MinThreshold',
    RecorderInvariantFloat(fsMinimumAmplitude.Value));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'Relative',
    IntToStr(Ord(chkRelative.Checked)));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'SaveVal',
    IntToStr(Ord(chkKeepValue.Checked)));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'OutChannel',
    Trim(edOutput.Text));
  Algorithm.Properties := lProperties;

  Algorithm.ClearBindings;
  AppendBinding(cbInput.Text, '');
  AppendBinding(cbGate.Text, 'Role=Gate');
  AppendBinding(cbReset.Text, 'Role=Reset');
  AppendBinding(cbShift.Text, 'Role=Shift');
end;

initialization
  RegisterRecorderAlgorithmEditor('Counter',
    TRecorderCounterAlgorithmFrame);

end.
