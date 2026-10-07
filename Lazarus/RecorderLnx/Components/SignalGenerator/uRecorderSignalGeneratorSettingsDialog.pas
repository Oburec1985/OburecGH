unit uRecorderSignalGeneratorSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Grids,
  uRecorderSignalGeneratorModel, uRecorderSignalGeneratorCreateDialog;

function ShowRecorderSignalGeneratorSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSignalGeneratorComponent): Boolean;

implementation

type
  TSignalGeneratorSettingsDialog = class(TForm)
  private
    fComponent: TRecorderSignalGeneratorComponent;
    fEnabledCheck: TCheckBox;
    fGrid: TStringGrid;
    fAddButton, fDeleteButton, fOkButton, fCancelButton: TButton;
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure LoadRows;
    procedure StoreRows;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderSignalGeneratorComponent);
  end;

const
  CColumnCount = 12;

constructor TSignalGeneratorSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderSignalGeneratorComponent);
const
  CHeaders: array[0..CColumnCount - 1] of string =
    ('Вкл', 'Имя тега', 'Тип', 'Fs, Гц', 'Амплитуда', 'F1, Гц',
     'Фаза, °', 'Смещение', 'Sweep', 'F2, Гц', 'T, с', 'Лог');
var
  I: Integer;
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  Caption := 'Генератор сигналов';
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  ClientWidth := 980;
  ClientHeight := 410;
  Constraints.MinWidth := 760;
  Constraints.MinHeight := 300;

  fEnabledCheck := TCheckBox.Create(Self);
  fEnabledCheck.Parent := Self;
  fEnabledCheck.SetBounds(12, 10, 190, 24);
  fEnabledCheck.Caption := 'Генератор включён';

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.SetBounds(12, 42, ClientWidth - 24, ClientHeight - 96);
  fGrid.Anchors := [akLeft, akTop, akRight, akBottom];
  fGrid.ColCount := CColumnCount;
  fGrid.FixedRows := 1;
  fGrid.RowCount := 2;
  fGrid.Options := fGrid.Options + [goEditing, goColSizing, goRowSelect];
  for I := 0 to CColumnCount - 1 do fGrid.Cells[I, 0] := CHeaders[I];
  fGrid.ColWidths[0] := 42;
  fGrid.ColWidths[1] := 145;
  fGrid.ColWidths[2] := 70;
  for I := 3 to CColumnCount - 1 do fGrid.ColWidths[I] := 72;

  fAddButton := TButton.Create(Self);
  fAddButton.Parent := Self;
  fAddButton.SetBounds(12, ClientHeight - 42, 100, 28);
  fAddButton.Anchors := [akLeft, akBottom];
  fAddButton.Caption := 'Добавить';
  fAddButton.OnClick := @AddClick;
  fDeleteButton := TButton.Create(Self);
  fDeleteButton.Parent := Self;
  fDeleteButton.SetBounds(120, ClientHeight - 42, 100, 28);
  fDeleteButton.Anchors := [akLeft, akBottom];
  fDeleteButton.Caption := 'Удалить';
  fDeleteButton.OnClick := @DeleteClick;
  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(ClientWidth - 190, ClientHeight - 42, 82, 28);
  fOkButton.Anchors := [akRight, akBottom];
  fOkButton.Caption := 'OK';
  fOkButton.ModalResult := mrOk;
  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(ClientWidth - 100, ClientHeight - 42, 88, 28);
  fCancelButton.Anchors := [akRight, akBottom];
  fCancelButton.Caption := 'Отмена';
  fCancelButton.ModalResult := mrCancel;
  LoadRows;
end;

procedure TSignalGeneratorSettingsDialog.LoadRows;
const
  CKindNames: array[TRecorderGeneratedSignalKind] of string =
    ('Синус', 'Пила', 'Шум');
var
  I, R: Integer;
  lSignal: TRecorderGeneratedSignal;
begin
  fEnabledCheck.Checked := fComponent.Enabled;
  fGrid.RowCount := Max(2, fComponent.SignalCount + 1);
  for I := 0 to fComponent.SignalCount - 1 do
  begin
    R := I + 1;
    lSignal := fComponent.Signals[I];
    fGrid.Cells[0, R] := BoolToStr(lSignal.Enabled, True);
    fGrid.Cells[1, R] := lSignal.Name;
    fGrid.Cells[2, R] := CKindNames[lSignal.Kind];
    fGrid.Cells[3, R] := FloatToStr(lSignal.SampleRateHz);
    fGrid.Cells[4, R] := FloatToStr(lSignal.Amplitude);
    fGrid.Cells[5, R] := FloatToStr(lSignal.FrequencyHz);
    fGrid.Cells[6, R] := FloatToStr(lSignal.PhaseDeg);
    fGrid.Cells[7, R] := FloatToStr(lSignal.Offset);
    fGrid.Cells[8, R] := BoolToStr(lSignal.SweepEnabled, True);
    fGrid.Cells[9, R] := FloatToStr(lSignal.SweepEndFrequencyHz);
    fGrid.Cells[10, R] := FloatToStr(lSignal.SweepDurationSec);
    fGrid.Cells[11, R] := BoolToStr(lSignal.SweepLogarithmic, True);
  end;
end;

procedure TSignalGeneratorSettingsDialog.AddClick(Sender: TObject);
var
  R: Integer;
  lSignal: TRecorderGeneratedSignal;
begin
  lSignal := TRecorderGeneratedSignal.Create;
  try
    lSignal.Name := Format('GenSignal_%0.3d', [fGrid.RowCount]);
    if not ShowSignalGeneratorCreateDialog(Self, lSignal) then Exit;
  R := fGrid.RowCount;
  fGrid.RowCount := R + 1;
    fGrid.Cells[0, R] := BoolToStr(lSignal.Enabled, True);
    fGrid.Cells[1, R] := lSignal.Name;
    case lSignal.Kind of
      rgskSaw: fGrid.Cells[2, R] := 'Пила';
      rgskNoise: fGrid.Cells[2, R] := 'Шум';
    else
      fGrid.Cells[2, R] := 'Синус';
    end;
    fGrid.Cells[3, R] := FloatToStr(lSignal.SampleRateHz);
    fGrid.Cells[4, R] := FloatToStr(lSignal.Amplitude);
    fGrid.Cells[5, R] := FloatToStr(lSignal.FrequencyHz);
    fGrid.Cells[6, R] := FloatToStr(lSignal.PhaseDeg);
    fGrid.Cells[7, R] := FloatToStr(lSignal.Offset);
    fGrid.Cells[8, R] := BoolToStr(lSignal.SweepEnabled, True);
    fGrid.Cells[9, R] := FloatToStr(lSignal.SweepEndFrequencyHz);
    fGrid.Cells[10, R] := FloatToStr(lSignal.SweepDurationSec);
    fGrid.Cells[11, R] := BoolToStr(lSignal.SweepLogarithmic, True);
  finally
    lSignal.Free;
  end;
end;

procedure TSignalGeneratorSettingsDialog.DeleteClick(Sender: TObject);
var
  R, C: Integer;
begin
  R := fGrid.Row;
  if (R <= 0) or (R >= fGrid.RowCount) then Exit;
  for R := R to fGrid.RowCount - 2 do
    for C := 0 to fGrid.ColCount - 1 do
      fGrid.Cells[C, R] := fGrid.Cells[C, R + 1];
  if fGrid.RowCount > 2 then fGrid.RowCount := fGrid.RowCount - 1
  else for C := 0 to fGrid.ColCount - 1 do fGrid.Cells[C, 1] := '';
end;

procedure TSignalGeneratorSettingsDialog.StoreRows;
var
  R: Integer;
  lSignal: TRecorderGeneratedSignal;
  lKind: string;
begin
  fComponent.Enabled := fEnabledCheck.Checked;
  fComponent.ClearSignals;
  for R := 1 to fGrid.RowCount - 1 do
  begin
    if Trim(fGrid.Cells[1, R]) = '' then Continue;
    lSignal := fComponent.AddSignal;
    lSignal.Enabled := StrToBoolDef(fGrid.Cells[0, R], True);
    lSignal.Name := Trim(fGrid.Cells[1, R]);
    lKind := LowerCase(Trim(fGrid.Cells[2, R]));
    if (lKind = 'пила') or (lKind = 'saw') then lSignal.Kind := rgskSaw
    else if (lKind = 'шум') or (lKind = 'noise') then lSignal.Kind := rgskNoise
    else lSignal.Kind := rgskSine;
    lSignal.SampleRateHz := Max(1.0, StrToFloatDef(fGrid.Cells[3, R], 1000));
    lSignal.Amplitude := StrToFloatDef(fGrid.Cells[4, R], 1);
    lSignal.FrequencyHz := Max(0.0, StrToFloatDef(fGrid.Cells[5, R], 10));
    lSignal.PhaseDeg := StrToFloatDef(fGrid.Cells[6, R], 0);
    lSignal.Offset := StrToFloatDef(fGrid.Cells[7, R], 0);
    lSignal.SweepEnabled := StrToBoolDef(fGrid.Cells[8, R], False);
    lSignal.SweepEndFrequencyHz := Max(0.0,
      StrToFloatDef(fGrid.Cells[9, R], 100));
    lSignal.SweepDurationSec := Max(0.001,
      StrToFloatDef(fGrid.Cells[10, R], 10));
    lSignal.SweepLogarithmic := StrToBoolDef(fGrid.Cells[11, R], False);
  end;
end;

function ShowRecorderSignalGeneratorSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSignalGeneratorComponent): Boolean;
var
  lDialog: TSignalGeneratorSettingsDialog;
begin
  lDialog := TSignalGeneratorSettingsDialog.CreateDialog(AOwner, AComponent);
  try
    Result := lDialog.ShowModal = mrOk;
    if Result then lDialog.StoreRows;
  finally
    lDialog.Free;
  end;
end;

end.
