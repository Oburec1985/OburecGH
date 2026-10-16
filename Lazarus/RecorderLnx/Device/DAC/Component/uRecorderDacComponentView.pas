unit uRecorderDacComponentView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Spin,
  uOglChart, uRecorderVisualControl, uRecorderFormModel, uRecorderTags,
  uRecorderDacTypes, uRecorderDacComponentModel;

type
  TRecorderDacComponentView = class(TFrame, IVForm)
    btnPlay, btnRefresh, btnSave: TButton;
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
    tsAccurate, tsSin, tsSweep, tsTag: TTabSheet;
    procedure SelectInputTag(Sender: TObject);
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
    fApplyPending: Boolean;
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
    if (lSelected < 0) and (Length(fEndpoints) > 0) then lSelected := 0;
    cbBackend.ItemIndex := lSelected;
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
      rdsmTag: pcPrograms.ActivePage := tsTag;
      rdsmAccurateSine: pcPrograms.ActivePage := tsAccurate;
      rdsmSweepSine: pcPrograms.ActivePage := tsSweep;
    else pcPrograms.ActivePage := tsSin;
    end;
    edFrequency.Value := fComponent.FrequencyHz;
    edAmplitude.Value := fComponent.Amplitude;
    edStartFreq.Value := fComponent.SweepStartHz;
    edEndFreq.Value := fComponent.SweepEndHz;
    edSweepTime.Value := fComponent.SweepTimeSec;
    cbMirror.Checked := fComponent.MirrorEnabled;
    edMirrorTag.Text := fComponent.MirrorTagName;
    edInputTag.Text := fComponent.InputTagName;
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
  end;
  case pcPrograms.ActivePageIndex of
    1: fComponent.SourceMode := rdsmAccurateSine;
    2: fComponent.SourceMode := rdsmSweepSine;
    3: fComponent.SourceMode := rdsmTag;
  else fComponent.SourceMode := rdsmSine;
  end;
  fComponent.FrequencyHz := edFrequency.Value;
  fComponent.Amplitude := edAmplitude.Value;
  fComponent.SweepStartHz := edStartFreq.Value;
  fComponent.SweepEndHz := edEndFreq.Value;
  fComponent.SweepTimeSec := edSweepTime.Value;
  fComponent.MirrorEnabled := cbMirror.Checked;
  fComponent.MirrorTagName := Trim(edMirrorTag.Text);
  lTag := nil;
  if (fRegistry <> nil) and (fComponent.MirrorTagName <> '') then
    lTag := fRegistry.FindByName(fComponent.MirrorTagName);
  if lTag <> nil then fComponent.MirrorTagId := lTag.Id
  else fComponent.MirrorTagId := 0;
end;

procedure TRecorderDacComponentView.UpdateModeView;
var
  lSweep, lTagMode: Boolean;
begin
  lSweep := pcPrograms.ActivePage = tsSweep;
  lTagMode := pcPrograms.ActivePage = tsTag;
  lblInputTag.Visible := lTagMode;
  edInputTag.Visible := lTagMode;
  btnInputTag.Visible := lTagMode;
  lblAmplitude.Visible := not lTagMode;
  edAmplitude.Visible := not lTagMode;
  lblFrequency.Visible := not (lSweep or lTagMode);
  edFrequency.Visible := not (lSweep or lTagMode);
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
  lRunning: Boolean;
begin
  if (fComponent = nil) or (fRegistry = nil) then Exit;
  if not ShowRecorderTagPickerDialog(Self, fRegistry,
    fComponent.InputTagName, True, lTag) then Exit;
  lRunning := False;
  if fRuntime <> nil then
    lRunning := fRuntime.Snapshot.State = rdsRunning;
  fComponent.InputTagId := lTag.Id;
  fComponent.InputTagName := lTag.Name;
  edInputTag.Text := lTag.Name;
  ApplyModel;
  if (fRuntime <> nil) and (lRunning or fApplyPending) then
  begin
    fApplyPending := True;
    fRuntime.StopOutput;
    fRuntime.StartOutput;
  end;
end;

procedure TRecorderDacComponentView.PlayClick(Sender: TObject);
begin
  if fRuntime = nil then Exit;
  if (fRuntime.Snapshot.State = rdsRunning) or fApplyPending then
  begin
    fApplyPending := False;
    fRuntime.StopOutput;
  end
  else begin ApplyModel; fRuntime.StartOutput; end;
end;

procedure TRecorderDacComponentView.RefreshClick(Sender: TObject);
begin FillDevices; end;
procedure TRecorderDacComponentView.SaveClick(Sender: TObject);
begin ParametersChange(Sender); end;

procedure TRecorderDacComponentView.ParametersChange(Sender: TObject);
var
  lRevision: LongInt;
  lRunning: Boolean;
begin
  if fLoading or (fComponent = nil) then Exit;
  lRevision := fComponent.Revision;
  lRunning := False;
  if fRuntime <> nil then
    lRunning := fRuntime.Snapshot.State = rdsRunning;
  ApplyModel;
  if lRevision = fComponent.Revision then Exit;
  if lRunning or fApplyPending then
  begin
    { Stop is asynchronous. StartOutput queues the restart until the worker
      finishes; rapid edits therefore configure the latest model revision. }
    fApplyPending := True;
    fRuntime.StopOutput;
    fRuntime.StartOutput;
  end;
end;

procedure TRecorderDacComponentView.ProgramChange(Sender: TObject);
begin
  if fLoading then Exit;
  UpdateModeView;
  ParametersChange(Sender);
end;
procedure TRecorderDacComponentView.MirrorClick(Sender: TObject);
begin
  UpdateModeView;
  ParametersChange(Sender);
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
begin
  lblState.Caption := DacStateText(ASnapshot.State);
  if ASnapshot.LastResult.Error <> rdeNone then
    lblState.Caption := lblState.Caption + ': ' + ASnapshot.LastResult.Text;
  if ASnapshot.State = rdsRunning then btnPlay.Caption := 'Stop'
  else btnPlay.Caption := 'Play';
end;

procedure TRecorderDacComponentView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
begin
  fRegistry := ATagRegistry;
  if fRuntime <> nil then
  begin
    RenderSnapshot(fRuntime.Snapshot);
    if fRuntime.Snapshot.State = rdsRunning then fApplyPending := False;
  end;
end;

function TRecorderDacComponentView.GetChartControl: TOglChart;
begin Result := nil; end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderDacComponent, TRecorderDacComponentView);

end.
