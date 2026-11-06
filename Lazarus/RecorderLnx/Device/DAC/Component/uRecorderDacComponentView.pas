unit uRecorderDacComponentView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Spin,
  uOglChart, uRecorderVisualControl, uRecorderFormModel, uRecorderTags,
  uRecorderDacTypes, uRecorderDacComponentModel;

type
  TRecorderDacComponentView = class(TFrame, IVForm)
    btnRefresh, btnSave: TButton;
    btnFeedbackTag, btnCalibrate: TButton;
    cbFeedbackSync: TCheckBox;
    edFeedbackTag: TEdit;
    gbCalibration: TGroupBox;
    lblCalibration, lblOutputStatus, lblCalibrationClock: TLabel;
    lblRateFactor: TLabel;
    edRateFactor: TFloatSpinEdit;
    btnPlay: TPanel;
    edPulseInterval: TFloatSpinEdit;
    edPulsePeriods, edPulseCount: TSpinEdit;
    lblPulseInterval, lblPulsePeriods, lblPulseCount, lblPulseDerived: TLabel;
    cbBackend: TComboBox;
    cbMirror: TCheckBox;
    edAmplitude, edEndFreq, edFrequency, edStartFreq,
      edSweepTime: TFloatSpinEdit;
    edMirrorTag, edInputTag: TEdit;
    btnInputTag: TButton;
    lblInputTag: TLabel;
    gbSignal: TGroupBox;
    lblAmplitude, lblEndFreq, lblFrequency, lblMirrorTag,
      lblStartFreq, lblState, lblSweepTime: TLabel;
    pcPrograms: TPageControl;
    pnlTop: TPanel;
    tsAccurate, tsSin, tsSweep, tsTag, tsPulse, tsConstant: TTabSheet;
    procedure SelectInputTag(Sender: TObject);
    procedure SelectFeedbackTag(Sender: TObject);
    procedure CalibrateClick(Sender: TObject);
    procedure FeedbackSyncClick(Sender: TObject);
    procedure RateFactorChange(Sender: TObject);
    procedure BackendChange(Sender: TObject);
    procedure MirrorClick(Sender: TObject);
    procedure PlayClick(Sender: TObject);
    procedure ProgramChange(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure ParametersChange(Sender: TObject);
  private
    fComponent: TRecorderDacComponent;
    fRuntime: IRecorderDacComponentRuntime;
    fRegistry: TRecorderTagRegistry;
    fEndpoints: TRecorderDacEndpoints;
    fLoading: Boolean;
    fCalibrationRunning: Boolean;
    procedure ApplyModel;
    procedure FillDevices;
    function SelectedEndpointIndex: Integer;
    procedure LoadModel;
    procedure RenderSnapshot(const ASnapshot: TRecorderDacRuntimeSnapshot);
    procedure UpdateModeView;
  public
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

uses uRecorderTagPickerDialog;

{$R *.lfm}

function DacStateText(AState: TRecorderDacState): string;
begin
  case AState of
    rdsClosed: Result := 'Остановлен';
    rdsConnected: Result := 'Подключён';
    rdsInitialized: Result := 'Инициализирован';
    rdsConfigured: Result := 'Готов';
    rdsRunning: Result := 'Вывод сигнала';
    rdsStopping: Result := 'Остановка';
    rdsOffline: Result := 'Ошибка';
  end;
end;

procedure TRecorderDacComponentView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderDacComponent(AComponent);
  fRegistry := ATagRegistry;
  if fComponent.Factory is TRecorderDacComponentFactory then
    fRuntime := TRecorderDacComponentFactory(fComponent.Factory).RuntimeFor(fComponent)
  else
    fRuntime := nil;
  LoadModel;
end;

function TRecorderDacComponentView.SelectedEndpointIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(fEndpoints) do
    if SameText(fEndpoints[I].BackendId, fComponent.BackendId) and
      SameText(fEndpoints[I].Endpoint, fComponent.Endpoint) then
      Exit(I);
end;

procedure TRecorderDacComponentView.FillDevices;
var
  I, lSelected: Integer;
  lResult: TRecorderDacResult;
begin
  if not (fComponent.Factory is TRecorderDacComponentFactory) then Exit;
  cbBackend.Items.BeginUpdate;
  try
    cbBackend.Clear;
    SetLength(fEndpoints, 0);
    TRecorderDacComponentFactory(fComponent.Factory).DiscoverEndpoints(
      fEndpoints, lResult);
    for I := 0 to High(fEndpoints) do
      cbBackend.Items.Add(fEndpoints[I].DisplayName);
    lSelected := SelectedEndpointIndex;
    cbBackend.ItemIndex := lSelected;
    if lSelected < 0 then
    begin
      cbBackend.TextHint := 'Выберите устройство';
      lblOutputStatus.Caption := 'Выбранный ЦАП недоступен. Нажмите Refresh и выберите устройство.';
      lblOutputStatus.Hint := lblOutputStatus.Caption;
    end
    else
      cbBackend.TextHint := '';
    if (Length(fEndpoints) = 0) and (lResult.Error <> rdeNone) then
      lblState.Caption := lResult.Text;
  finally
    cbBackend.Items.EndUpdate;
  end;
end;

procedure TRecorderDacComponentView.LoadModel;
begin
  fLoading := True;
  try
    FillDevices;
    case fComponent.SourceMode of
      rdsmConstant: pcPrograms.ActivePage := tsConstant;
      rdsmPulse: pcPrograms.ActivePage := tsPulse;
      rdsmTag: pcPrograms.ActivePage := tsTag;
      rdsmAccurateSine: pcPrograms.ActivePage := tsAccurate;
      rdsmSweepSine: pcPrograms.ActivePage := tsSweep;
    else pcPrograms.ActivePage := tsSin;
    end;
    edFrequency.Value := fComponent.FrequencyHz;
    UpdateModeView;
    edAmplitude.Value := fComponent.Amplitude;
    edStartFreq.Value := fComponent.SweepStartHz;
    edEndFreq.Value := fComponent.SweepEndHz;
    edSweepTime.Value := fComponent.SweepTimeSec;
    cbMirror.Checked := fComponent.MirrorEnabled;
    edMirrorTag.Text := fComponent.MirrorTagName;
    edInputTag.Text := fComponent.InputTagName;
    edPulseInterval.Value := fComponent.PulseIntervalSec;
    edPulsePeriods.Value := fComponent.PulsePeriods;
    edPulseCount.Value := fComponent.PulseCount;
    edFeedbackTag.Text := fComponent.FeedbackTagName;
    cbFeedbackSync.Checked := fComponent.SynchronizeByFeedback;
    UpdateModeView;
  finally
    fLoading := False;
  end;
end;

procedure TRecorderDacComponentView.ApplyModel;
var
  lTag: TRecorderTag;
begin
  if (cbBackend.ItemIndex >= 0) and
    (cbBackend.ItemIndex < Length(fEndpoints)) then
  begin
    fComponent.BackendId := fEndpoints[cbBackend.ItemIndex].BackendId;
    fComponent.Endpoint := fEndpoints[cbBackend.ItemIndex].Endpoint;
    if fEndpoints[cbBackend.ItemIndex].SampleRateHz > 0 then
      fComponent.SampleRateHz := fEndpoints[cbBackend.ItemIndex].SampleRateHz;
  end;
  case pcPrograms.ActivePageIndex of
    1: fComponent.SourceMode := rdsmAccurateSine;
    2: fComponent.SourceMode := rdsmSweepSine;
    3: fComponent.SourceMode := rdsmTag;
    4: fComponent.SourceMode := rdsmPulse;
    5: fComponent.SourceMode := rdsmConstant;
  else fComponent.SourceMode := rdsmSine;
  end;
  fComponent.FrequencyHz := edFrequency.Value;
  fComponent.PulseIntervalSec := edPulseInterval.Value;
  fComponent.PulsePeriods := edPulsePeriods.Value;
  fComponent.PulseCount := edPulseCount.Value;
  fComponent.Amplitude := edAmplitude.Value;
  fComponent.SweepStartHz := edStartFreq.Value;
  fComponent.SweepEndHz := edEndFreq.Value;
  fComponent.SweepTimeSec := edSweepTime.Value;
  fComponent.MirrorEnabled := cbMirror.Checked;
  fComponent.SynchronizeByFeedback := cbFeedbackSync.Checked;
  fComponent.MirrorTagName := Trim(edMirrorTag.Text);
  lTag := nil;
  if (fRegistry <> nil) and (fComponent.MirrorTagName <> '') then
    lTag := fRegistry.FindByName(fComponent.MirrorTagName);
  if lTag <> nil then fComponent.MirrorTagId := lTag.Id
  else fComponent.MirrorTagId := 0;
end;

procedure TRecorderDacComponentView.UpdateModeView;
var
  lSweep, lTagMode, lPulse, lConstant, lWasLoading: Boolean;
begin
  lSweep := pcPrograms.ActivePage = tsSweep;
  lTagMode := pcPrograms.ActivePage = tsTag;
  lPulse := pcPrograms.ActivePage = tsPulse;
  lConstant := pcPrograms.ActivePage = tsConstant;
  lWasLoading := fLoading;
  fLoading := True;
  try
    edAmplitude.MinValue := -1E9;
    edAmplitude.MaxValue := 1E9;
    if lConstant and (fComponent <> nil) then
    begin
      lblAmplitude.Caption := 'Уровень';
      edAmplitude.MaxValue := fComponent.MaximumValue;
      edAmplitude.MinValue := fComponent.MinimumValue;
    end
    else
    begin
      lblAmplitude.Caption := 'Amplitude';
      edAmplitude.MaxValue := 1000000;
      edAmplitude.MinValue := 0;
    end;
  finally
    fLoading := lWasLoading;
  end;
  lblPulseInterval.Visible := lPulse;
  edPulseInterval.Visible := lPulse;
  lblPulsePeriods.Visible := lPulse;
  edPulsePeriods.Visible := lPulse;
  lblPulseCount.Visible := lPulse;
  edPulseCount.Visible := lPulse;
  lblPulseDerived.Visible := lPulse;
  if (edFrequency.Value > 0) and (edPulsePeriods.Value > 0) then
    lblPulseDerived.Caption := Format('T1 — возбуждение: %.6g с' + LineEnding +
      'T0 — пауза: %.6g с' + LineEnding + 'Скважность T/T1: %.6g',
      [edPulsePeriods.Value / edFrequency.Value,
       edPulseInterval.Value - edPulsePeriods.Value / edFrequency.Value,
       edPulseInterval.Value * edFrequency.Value / edPulsePeriods.Value])
  else lblPulseDerived.Caption := 'T1, T0 и скважность: задайте частоту > 0';
  lblInputTag.Visible := lTagMode;
  edInputTag.Visible := lTagMode;
  btnInputTag.Visible := lTagMode;
  lblAmplitude.Visible := not lTagMode;
  edAmplitude.Visible := not lTagMode;
  lblFrequency.Visible := not (lSweep or lTagMode or lConstant);
  edFrequency.Visible := not (lSweep or lTagMode or lConstant);
  lblStartFreq.Visible := lSweep;
  edStartFreq.Visible := lSweep;
  lblEndFreq.Visible := lSweep;
  edEndFreq.Visible := lSweep;
  lblSweepTime.Visible := lSweep;
  edSweepTime.Visible := lSweep;
  edMirrorTag.Enabled := cbMirror.Checked;
end;

procedure TRecorderDacComponentView.SelectInputTag(Sender: TObject);
var
  lTag: TRecorderTag;
begin
  if (fComponent = nil) or (fRegistry = nil) then Exit;
  if not ShowRecorderTagPickerDialog(Self, fRegistry,
    fComponent.InputTagName, True, lTag) then Exit;
  fComponent.InputTagId := lTag.Id;
  fComponent.InputTagName := lTag.Name;
  edInputTag.Text := lTag.Name;
  ApplyModel;
  if fRuntime <> nil then fRuntime.ApplyOutputSettings;
end;

procedure TRecorderDacComponentView.SelectFeedbackTag(Sender: TObject);
var
  lTag: TRecorderTag;
begin
  if fCalibrationRunning or (fComponent = nil) or (fRegistry = nil) then Exit;
  if not ShowRecorderTagPickerDialog(Self, fRegistry,
    fComponent.FeedbackTagName, True, lTag, True) then Exit;
  fComponent.FeedbackTagId := lTag.Id;
  fComponent.FeedbackTagName := lTag.Name;
  edFeedbackTag.Text := lTag.Name;
  if fRuntime <> nil then fRuntime.ApplyOutputSettings;
end;

procedure TRecorderDacComponentView.CalibrateClick(Sender: TObject);
begin
  if (fRuntime = nil) or fCalibrationRunning then Exit;
  ApplyModel;
  fRuntime.StartCalibration;
  RenderSnapshot(fRuntime.Snapshot);
end;

procedure TRecorderDacComponentView.FeedbackSyncClick(Sender: TObject);
begin
  if fLoading or fCalibrationRunning or (fComponent = nil) then Exit;
  { A new synchronization mode is armed by the configured stream-start event,
    not by editing a checkbox while output is active. }
  fComponent.SynchronizeByFeedback := cbFeedbackSync.Checked;
  if fRuntime <> nil then fRuntime.ApplyOutputSettings;
end;

procedure TRecorderDacComponentView.RateFactorChange(Sender: TObject);
var
  lResult: TRecorderDacResult;
begin
  if fLoading or (fRuntime = nil) then Exit;
  fRuntime.SetRateFactor(edRateFactor.Value, lResult);
  RenderSnapshot(fRuntime.Snapshot);
end;

procedure TRecorderDacComponentView.PlayClick(Sender: TObject);
var
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  if fRuntime = nil then Exit;
  lSnapshot := fRuntime.Snapshot;
  if lSnapshot.OutputPlaying then
  begin
    fRuntime.StopOutput;
  end
  else
  begin
    ApplyModel;
    fRuntime.StartOutput;
  end;
  RenderSnapshot(fRuntime.Snapshot);
end;

procedure TRecorderDacComponentView.RefreshClick(Sender: TObject);
begin FillDevices; end;
procedure TRecorderDacComponentView.SaveClick(Sender: TObject);
begin ParametersChange(Sender); end;

procedure TRecorderDacComponentView.ParametersChange(Sender: TObject);
var
  lRevision: LongInt;
begin
  if fLoading or fCalibrationRunning or (fComponent = nil) then Exit;
  lRevision := fComponent.Revision;
  ApplyModel;
  if lRevision = fComponent.Revision then Exit;
  UpdateModeView;
  if fRuntime <> nil then fRuntime.ApplyOutputSettings;
end;

procedure TRecorderDacComponentView.ProgramChange(Sender: TObject);
begin
  if fLoading then Exit;
  UpdateModeView;
  ParametersChange(Sender);
end;
procedure TRecorderDacComponentView.MirrorClick(Sender: TObject);
begin
  if fLoading or fCalibrationRunning or (fComponent = nil) then Exit;
  ApplyModel;
  if cbMirror.Checked then
  begin
    fComponent.EnsureMirrorTag(fRegistry);
    fLoading := True;
    try
      edMirrorTag.Text := fComponent.MirrorTagName;
    finally
      fLoading := False;
    end;
  end;
  UpdateModeView;
  if fRuntime <> nil then fRuntime.ApplyOutputSettings;
end;
procedure TRecorderDacComponentView.BackendChange(Sender: TObject);
begin
  if fLoading then Exit;
  if (cbBackend.ItemIndex < 0) or
    (cbBackend.ItemIndex >= Length(fEndpoints)) then Exit;
  ParametersChange(Sender);
end;

procedure TRecorderDacComponentView.RenderSnapshot(
  const ASnapshot: TRecorderDacRuntimeSnapshot);
var
  lWasLoading: Boolean;
begin
  fCalibrationRunning := ASnapshot.CalibrationRunning;
  gbSignal.Enabled := not fCalibrationRunning;
  pcPrograms.Enabled := not fCalibrationRunning;
  cbBackend.Enabled := not fCalibrationRunning;
  btnRefresh.Enabled := not fCalibrationRunning;
  btnSave.Enabled := not fCalibrationRunning;
  cbFeedbackSync.Enabled := not fCalibrationRunning;
  btnFeedbackTag.Enabled := not fCalibrationRunning;
  btnCalibrate.Enabled := not fCalibrationRunning and
    (ASnapshot.State <> rdsStopping);
  lblCalibration.Caption := ASnapshot.CalibrationStateText;
  if ASnapshot.CalibrationValid then
    lblCalibrationClock.Caption := Format('Fs: %.3f Гц',
      [ASnapshot.CalibrationSampleRateHz])
  else
    lblCalibrationClock.Caption := 'Fs: —';
  lWasLoading := fLoading;
  fLoading := True;
  try
    if not ASnapshot.CalibrationRatePending then
      if ASnapshot.CalibrationValid then edRateFactor.Value := ASnapshot.CalibrationRateFactor
      else edRateFactor.Value := 1;
  finally
    fLoading := lWasLoading;
  end;
  edRateFactor.Enabled := ASnapshot.CalibrationValid and
    not ASnapshot.CalibrationRunning and (ASnapshot.State <> rdsStopping) and
    (fComponent <> nil) and (fComponent.SourceMode <> rdsmConstant);
  lblCalibrationClock.Hint := 'Fs — рассчитанная частота зеркала; k = Fs_eff / Fs_nominal';
  if ASnapshot.CalibrationValid then
    lblCalibrationClock.Hint := lblCalibrationClock.Hint + LineEnding +
      Format('Корреляция формы: ρ1 = %.4f; ρ2 = %.4f',
        [ASnapshot.CalibrationCorrelationFirst, ASnapshot.CalibrationCorrelationSecond]);
  if ASnapshot.CalibrationValid then
    lblCalibration.Caption := Format('Смещение: %.3f мс; Fs: %.6f Гц; дрейф: %.3f ppm.',
      [ASnapshot.CalibrationDelaySec * 1000, ASnapshot.CalibrationSampleRateHz,
       ASnapshot.CalibrationDriftPpm]) + LineEnding + lblCalibration.Caption
  else if ASnapshot.CalibrationDetectedEdges > 0 then
    lblCalibration.Caption := Format('Сопоставлено колоколов: %d/2. ',
      [ASnapshot.CalibrationDetectedEdges]) + lblCalibration.Caption;
  if lblCalibration.Caption = '' then
    lblCalibration.Caption := 'Выберите вход обратной связи. Калибровка по корреляции формы двух колоколов.';
  if fComponent <> nil then
  begin
    case fComponent.PhaseCalibrationMode of
      rdpcmMeasurementStart: cbFeedbackSync.Hint := 'Калибровка при старте измерения; Play включает рабочий сигнал.';
      rdpcmPlay: cbFeedbackSync.Hint := Format('Каждый Play: калибровка %.3g с, затем рабочий сигнал.',
        [fComponent.FeedbackCalibrationDurationSec]);
      rdpcmButton: cbFeedbackSync.Hint := 'Калибровка только по кнопке «Калибровка фазы».';
    end;
  end;
  lblState.Caption := DacStateText(ASnapshot.State);
  if ASnapshot.LastResult.Error <> rdeNone then
    lblState.Caption := lblState.Caption + ': ' + ASnapshot.LastResult.Text;
  lblOutputStatus.Caption := '';
  if ASnapshot.LastResult.Error <> rdeNone then
    lblOutputStatus.Caption := ASnapshot.LastResult.Text
  else if fCalibrationRunning then
    lblOutputStatus.Caption := 'Калибровка…';
  if (lblOutputStatus.Caption = '') and ASnapshot.CalibrationValid then
    lblOutputStatus.Caption := Format('Корреляция формы: ρ1 = %.4f; ρ2 = %.4f',
      [ASnapshot.CalibrationCorrelationFirst, ASnapshot.CalibrationCorrelationSecond]);
  if ASnapshot.CalibrationManualRate then
    lblOutputStatus.Caption := 'k задан вручную. ' + lblOutputStatus.Caption;
  if ASnapshot.CalibrationRatePending then
    lblOutputStatus.Caption := 'Применяется k… ' + lblOutputStatus.Caption;
  if (lblOutputStatus.Caption = '') and (cbBackend.ItemIndex < 0) then
    lblOutputStatus.Caption := 'Выбранный ЦАП недоступен. Нажмите Refresh и выберите устройство.';
  lblOutputStatus.Hint := lblOutputStatus.Caption;
  lblState.Visible := ASnapshot.LastResult.Error <> rdeNone;
  btnPlay.Hint := lblState.Caption;
  btnPlay.ShowHint := True;
  if ASnapshot.OutputPlaying or (ASnapshot.State = rdsStopping) then
  begin
    btnPlay.Caption := 'Stop';
    btnPlay.Color := clYellow;
  end
  else
  begin
    btnPlay.Caption := 'Play';
    btnPlay.Color := clBtnFace;
  end;
end;

procedure TRecorderDacComponentView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  fRegistry := ATagRegistry;
  if fRuntime <> nil then
  begin
    lSnapshot := fRuntime.Snapshot;
    RenderSnapshot(lSnapshot);
  end;
end;

function TRecorderDacComponentView.GetChartControl: TOglChart;
begin Result := nil; end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderDacComponent, TRecorderDacComponentView);

end.
