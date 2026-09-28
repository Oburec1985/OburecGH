unit uRecorderArithmeticAlgorithmFrame;

{ Visual editor for arithmetic operations on two tags. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls,
  uRecorderAlgorithmManager, uRecorderAlgorithmEditorFrame;

type
  TRecorderArithmeticAlgorithmFrame = class(TRecorderAlgorithmEditorFrame)
    cbInputA: TComboBox;
    cbInputB: TComboBox;
    cbOperation: TComboBox;
    edOutput: TEdit;
    lbInputA: TLabel;
    lbInputB: TLabel;
    lbOperation: TLabel;
    lbOutput: TLabel;
  protected
    procedure LoadFromAlgorithm; override;
    procedure SaveToAlgorithm; override;
  end;

implementation

{$R *.lfm}

procedure TRecorderArithmeticAlgorithmFrame.LoadFromAlgorithm;
var
  lOperation: string;
  lOperationIndex: Integer;
begin
  FillTagCombo(cbInputA);
  FillTagCombo(cbInputB);
  if Algorithm = nil then
    Exit;

  cbInputA.Text := BindingName(0);
  cbInputB.Text := BindingName(1);
  lOperation := LowerCase(RecorderAlgorithmProperty(
    Algorithm.Properties, 'Operation', ''));
  if lOperation = '' then
    lOperationIndex := StrToIntDef(RecorderAlgorithmProperty(
      Algorithm.Properties, 'TypeRes', '0'), 0)
  else if (lOperation = 'sub') or (lOperation = 'subtract') then
    lOperationIndex := 1
  else if (lOperation = 'mul') or (lOperation = 'multiply') then
    lOperationIndex := 2
  else if (lOperation = 'div') or (lOperation = 'divide') then
    lOperationIndex := 3
  else
    lOperationIndex := 0;
  if (lOperationIndex < 0) or (lOperationIndex >= cbOperation.Items.Count) then
    lOperationIndex := 0;
  cbOperation.ItemIndex := lOperationIndex;
  edOutput.Text := RecorderAlgorithmProperty(
    Algorithm.Properties, 'OutChannel', '');
end;

procedure TRecorderArithmeticAlgorithmFrame.SaveToAlgorithm;
const
  COperationNames: array[0..3] of string =
    ('Add', 'Subtract', 'Multiply', 'Divide');
var
  lProperties: string;
  lOperationIndex: Integer;
begin
  if Algorithm = nil then
    Exit;
  lOperationIndex := cbOperation.ItemIndex;
  if lOperationIndex < 0 then
    lOperationIndex := 0;
  lProperties := RecorderSetAlgorithmProperty(Algorithm.Properties,
    'TypeRes', IntToStr(lOperationIndex));
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'Operation',
    COperationNames[lOperationIndex]);
  lProperties := RecorderSetAlgorithmProperty(lProperties, 'OutChannel',
    Trim(edOutput.Text));
  Algorithm.Properties := lProperties;
  SetBindingName(0, cbInputA.Text);
  SetBindingName(1, cbInputB.Text);
end;

initialization
  RegisterRecorderAlgorithmEditor('Arithmetic',
    TRecorderArithmeticAlgorithmFrame);

end.
