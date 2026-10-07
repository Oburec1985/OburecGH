unit uRecorderSignalGeneratorCreateDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, Forms, Controls, StdCtrls, ExtCtrls, Spin,
  uRecorderSignalGeneratorModel;

function ShowSignalGeneratorCreateDialog(AOwner: TComponent;
  ASignal: TRecorderGeneratedSignal): Boolean;

implementation

function AddSpin(AForm: TForm; ALeft, ATop, AWidth: Integer;
  AValue: Double): TFloatSpinEdit;
begin
  Result := TFloatSpinEdit.Create(AForm);
  Result.Parent := AForm;
  Result.SetBounds(ALeft, ATop, AWidth, 24);
  Result.DecimalPlaces := 4;
  Result.Increment := 0.1;
  Result.MinValue := -1.0E12;
  Result.MaxValue := 1.0E12;
  Result.Value := AValue;
end;

procedure AddLabel(AForm: TForm; const ACaption: string;
  ALeft, ATop, AWidth: Integer);
var
  lLabel: TLabel;
begin
  lLabel := TLabel.Create(AForm);
  lLabel.Parent := AForm;
  lLabel.Caption := ACaption;
  lLabel.SetBounds(ALeft, ATop, AWidth, 18);
end;

function ShowSignalGeneratorCreateDialog(AOwner: TComponent;
  ASignal: TRecorderGeneratedSignal): Boolean;
var
  lForm: TForm;
  lNameEdit: TEdit;
  lKind: TRadioGroup;
  lFs, lAmplitude, lF1, lF2, lTime, lPhase, lOffset: TFloatSpinEdit;
  lSweep, lLog: TCheckBox;
  lCreate, lCancel: TButton;
begin
  Result := False;
  if ASignal = nil then Exit;
  lForm := TForm.CreateNew(AOwner, 1);
  try
    lForm.Caption := 'Создать сигнал';
    lForm.Position := poOwnerFormCenter;
    lForm.BorderStyle := bsDialog;
    lForm.ClientWidth := 330;
    lForm.ClientHeight := 290;
    AddLabel(lForm, 'Имя сигнала', 12, 10, 120);
    lNameEdit := TEdit.Create(lForm);
    lNameEdit.Parent := lForm;
    lNameEdit.SetBounds(12, 29, 180, 24);
    lNameEdit.Text := ASignal.Name;
    AddLabel(lForm, 'Fs, Гц', 218, 10, 85);
    lFs := AddSpin(lForm, 218, 29, 96, ASignal.SampleRateHz);

    lKind := TRadioGroup.Create(lForm);
    lKind.Parent := lForm;
    lKind.Caption := 'Тип сигнала';
    lKind.Items.Add('Синус');
    lKind.Items.Add('Пила');
    lKind.Items.Add('Шум');
    lKind.ItemIndex := Ord(ASignal.Kind);
    lKind.SetBounds(12, 64, 92, 110);

    AddLabel(lForm, 'Амп.', 116, 66, 55);
    lAmplitude := AddSpin(lForm, 116, 84, 82, ASignal.Amplitude);
    lSweep := TCheckBox.Create(lForm);
    lSweep.Parent := lForm;
    lSweep.Caption := 'Sweep';
    lSweep.Checked := ASignal.SweepEnabled;
    lSweep.SetBounds(207, 82, 70, 24);
    lLog := TCheckBox.Create(lForm);
    lLog.Parent := lForm;
    lLog.Caption := 'Lg';
    lLog.Checked := ASignal.SweepLogarithmic;
    lLog.SetBounds(278, 82, 42, 24);

    AddLabel(lForm, 'F1, Гц', 116, 112, 70);
    lF1 := AddSpin(lForm, 116, 130, 82, ASignal.FrequencyHz);
    AddLabel(lForm, 'F2, Гц', 207, 112, 70);
    lF2 := AddSpin(lForm, 207, 130, 82, ASignal.SweepEndFrequencyHz);
    AddLabel(lForm, 'T2, сек', 116, 160, 70);
    lTime := AddSpin(lForm, 116, 178, 82, ASignal.SweepDurationSec);
    AddLabel(lForm, 'Фаза, град.', 207, 160, 90);
    lPhase := AddSpin(lForm, 207, 178, 82, ASignal.PhaseDeg);
    AddLabel(lForm, 'Смещение', 12, 202, 90);
    lOffset := AddSpin(lForm, 12, 220, 92, ASignal.Offset);

    lCreate := TButton.Create(lForm);
    lCreate.Parent := lForm;
    lCreate.Caption := 'Создать';
    lCreate.ModalResult := mrOk;
    lCreate.SetBounds(140, 248, 84, 28);
    lCancel := TButton.Create(lForm);
    lCancel.Parent := lForm;
    lCancel.Caption := 'Отмена';
    lCancel.ModalResult := mrCancel;
    lCancel.SetBounds(232, 248, 84, 28);

    Result := lForm.ShowModal = mrOk;
    if not Result then Exit;
    ASignal.Name := lNameEdit.Text;
    ASignal.SampleRateHz := lFs.Value;
    ASignal.Kind := TRecorderGeneratedSignalKind(lKind.ItemIndex);
    ASignal.Amplitude := lAmplitude.Value;
    ASignal.FrequencyHz := lF1.Value;
    ASignal.SweepEndFrequencyHz := lF2.Value;
    ASignal.SweepDurationSec := lTime.Value;
    ASignal.PhaseDeg := lPhase.Value;
    ASignal.Offset := lOffset.Value;
    ASignal.SweepEnabled := lSweep.Checked;
    ASignal.SweepLogarithmic := lLog.Checked;
  finally
    lForm.Free;
  end;
end;

end.
