program DigitalRawCodesUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, Controls, Grids, Classes, SysUtils,
  uRecorderTags, uRecorderDigitalPageView;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure TestRawCodes;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  Physical: TRecorderTag;
  C: TRecorderCalibration;
  G: TStringGrid;
  Host: TForm;
  Times, Values: array[0..1] of Double;
  V: Double;
begin
  R := TRecorderTagRegistry.Create;
  Host := TForm.Create(nil);
  G := TStringGrid.Create(Host);
  G.Parent := Host;
  G.Align := alClient;
  Host.Show;
  try
    T := R.CreateTag('raw input', 16);
    T.SourceUnitName := 'code';
    T.UnitName := 'mV';
    T.AutoUnit := True;
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'ADC'; C.UnitIn := 'code'; C.UnitOut := 'mV'; C.Scale := 2;
    R.Calibrations.Add(C);
    T.HardwareCalibrationName := C.Name;
    T.HardwareCalibrationEnabled := True;
    T.SourceUnitName := 'code';
    R.PublishValue(T, 1, 17);
    Check(T.TryGetRawValue(V) and (V = 17), 'Scalar keeps original input before GX');
    Check(T.SignalBuffer.LatestValue = 34, 'Hardware GX still transforms Value');
    RenderRecorderDigitalPage(G, R, nil, True);
    Check((G.ColCount = 8) and (G.Cells[4, 0] = 'Value') and
      (G.Cells[5, 1] = '17'), 'Raw column follows Value without moving its index');
    Check(G.Cells[6, 0] = 'Alarm', 'Alarm follows optional raw column');
    RenderRecorderDigitalPage(G, R, nil, False);
    Check((G.ColCount = 7) and (G.Cells[5, 0] = 'Alarm'), 'Checkbox-off layout restored');

    Times[0] := 2; Times[1] := 3;
    Values[0] := 30; Values[1] := 41;
    R.AddBlockSamples(T, Times, Values, 2, False);
    Check(T.TryGetRawValue(V) and (V = 41), 'Block captures actual tail before GX');
    Check(T.SignalBuffer.LatestValue = 82, 'Block physical value independent');

    T.SourceHardwareOutputUnitName := 'mV';
    T.StageRawValue(5, 1234);
    Check(not T.TryGetRawValue(V), 'Pending raw never pairs with previous physical sample');
    Times[0] := 4; Times[1] := 5;
    Values[0] := -8; Values[1] := -9;
    R.AddBlockSamples(T, Times, Values, 2, True);
    Check(T.TryGetRawValue(V) and (V = 1234),
      'Preprocessed source retains explicitly supplied code, never inverse GX');
    RenderRecorderDigitalPage(G, R, nil, True);
    Check(G.Cells[5, 1] = '1234', 'Digital raw column reads original source telemetry');
    Times[0] := 6; Times[1] := 7;
    R.AddBlockSamples(T, Times, Values, 2, True);
    Check(not T.TryGetRawValue(V), 'Physical-only publication invalidates stale raw');
    UpdateRecorderDigitalPage(G, R, nil, True);
    Check(G.Cells[5, 1] = '-', 'Unavailable codes are not reconstructed');

    T.StageRawValue(8, 555);
    T.AddSample(8, -4);
    T.HardwareCalibrationEnabled := False;
    UpdateRecorderDigitalPage(G, R, nil, True);
    Check(G.Cells[5, 1] = '-', 'AH-disabled tag does not show raw column value');
    T.HardwareCalibrationEnabled := True;
    Check(not T.TryGetRawValue(V), 'AH transition requires fresh sample');
    T.StageRawValue(9, 666); T.AddSample(9, -2);
    T.ClearSignalHistory;
    Check(not T.TryGetRawValue(V), 'History reset clears raw telemetry');
    T.StageRawValue(10, 777); T.AddSample(10, -1);
    T.SourceId := 'another-source';
    Check(not T.TryGetRawValue(V), 'Source change clears raw telemetry');
    T.StageRawValue(11, 888); T.AddSample(11, -1);
    T.Address := 'other-channel';
    Check(not T.TryGetRawValue(V), 'Channel change clears raw telemetry');
    Physical := R.CreateTag('physical-only source', 16);
    Physical.UnitName := 'mV';
    Physical.SourceUnitName := 'mV';
    Physical.HardwareCalibrationEnabled := True;
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'voltage gain'; C.UnitIn := 'mV'; C.UnitOut := 'mV'; C.Scale := 2;
    R.Calibrations.Add(C);
    Physical.HardwareCalibrationName := C.Name;
    R.PublishValue(Physical, 12, 0.25);
    Check(not Physical.TryGetRawValue(V),
      'Already physical generic input is not mislabelled as ADC codes');
    WriteLn('RESULT DigitalRawCodesUiSmoke passed');
  finally Host.Free; R.Free; end;
end;

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  try TestRawCodes;
  except on E: Exception do begin WriteLn('RESULT failed: ', E.Message); Halt(1); end; end;
end.
