unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uDacDevice, uSoundCardDac, Math, ImgList,
  IniFiles, ulogFile, uCommonTypes, uChart, uSpin, uDACProgram,
  uAccuracyStepSin;

type
  TDACFrm = class(TForm)
    pnlTop: TPanel;
    btnPlayStop: TButton;
    cbDacDevices: TComboBox;
    btnRefreshDevices: TButton;
    btnSave: TButton;
    btnLoad: TButton;
    rgMode: TRadioGroup;
    rgProgramType: TRadioGroup;
    gbSweepSin: TGroupBox;
    lblStartFreq: TLabel;
    lblEndFreq: TLabel;
    lblSweepTime: TLabel;
    edStartFreq: TEdit;
    edEndFreq: TEdit;
    edSweepTime: TEdit;
    gbProgram: TGroupBox;
    lblProgFreq: TLabel;
    lblProgAmpl: TLabel;
    lblMinSamples: TLabel;
    edProgFreq: TEdit;
    edProgAmpl: TFloatSpinEdit;
    edMinSamples: TEdit;
    TestBtn: TButton;
    cChart1: cChart;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    procedure btnPlayStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRefreshDevicesClick(Sender: TObject);
    procedure rgModeClick(Sender: TObject);
    procedure rgProgramTypeClick(Sender: TObject);
    procedure edProgFreqChange(Sender: TObject);
    procedure edProgAmplChange(Sender: TObject);
    procedure edMinSamplesChange(Sender: TObject);
    procedure edStartFreqChange(Sender: TObject);
    procedure edEndFreqChange(Sender: TObject);
    procedure edSweepTimeChange(Sender: TObject);
  private
    FDacDevice: TDacDevice;
    FSimpleSinusProgram: TSimpleSinusProgram;
    FAccurateSinusProgram: TAccurateSinusProgram;
    FSweepSinProgram: TSweepSinProgram;
    FCurrentProgram: TDacProgram;
    procedure RefreshDeviceList;
    procedure UpdateModeView;
    procedure save(ifile: TIniFile);
    procedure load(ifile: TIniFile);
    procedure InitPrograms;
    procedure SyncProgramsFromUi;
    procedure SelectCurrentProgram;
  public
  end;

var
  DACFrm: TDACFrm;

implementation

{$R *.dfm}

procedure TDACFrm.RefreshDeviceList;
var
  lDeviceList: TStringList;
  lPrevIndex: Integer;
begin
  if not Assigned(FDacDevice) then
    Exit;

  lPrevIndex := cbDacDevices.ItemIndex;
  lDeviceList := FDacDevice.GetDeviceList;
  try
    cbDacDevices.Items.Assign(lDeviceList);
    if cbDacDevices.Items.Count = 0 then
    begin
      cbDacDevices.ItemIndex := -1;
      Exit;
    end;

    if (lPrevIndex >= 0) and (lPrevIndex < cbDacDevices.Items.Count) then
      cbDacDevices.ItemIndex := lPrevIndex
    else
      cbDacDevices.ItemIndex := 0;
  finally
    lDeviceList.Free;
  end;
end;

procedure TDACFrm.UpdateModeView;
var
  lIsSweep: Boolean;
  lIsAccurate: Boolean;
begin
  lIsSweep := rgMode.ItemIndex = 1;
  lIsAccurate := (not lIsSweep) and (rgProgramType.ItemIndex = 1);

  gbSweepSin.Visible := lIsSweep;
  rgProgramType.Visible := not lIsSweep;
  gbProgram.Visible := not lIsSweep;
  lblMinSamples.Visible := lIsAccurate;
  edMinSamples.Visible := lIsAccurate;
end;

procedure TDACFrm.save(ifile: TIniFile);
begin
  ifile.WriteInteger('DAC', 'Mode', rgMode.ItemIndex);
  ifile.WriteInteger('DAC', 'ProgramType', rgProgramType.ItemIndex);
  ifile.WriteString('DAC', 'Freq', edProgFreq.Text);
  ifile.WriteString('DAC', 'Ampl', edProgAmpl.Text);
  ifile.WriteString('DAC', 'StartFreq', edStartFreq.Text);
  ifile.WriteString('DAC', 'EndFreq', edEndFreq.Text);
  ifile.WriteString('DAC', 'SweepTime', edSweepTime.Text);
  ifile.WriteInteger('DAC', 'DeviceID', cbDacDevices.ItemIndex);
  ifile.WriteString('DAC', 'MinSamples', edMinSamples.Text);
end;

procedure TDACFrm.load(ifile: TIniFile);
var
  lDeviceIndex: Integer;
begin
  rgMode.ItemIndex := ifile.ReadInteger('DAC', 'Mode', 0);
  rgProgramType.ItemIndex := ifile.ReadInteger('DAC', 'ProgramType', 0);
  edProgFreq.Text := ifile.ReadString('DAC', 'Freq', '440');
  edProgAmpl.Text := ifile.ReadString('DAC', 'Ampl', '0.5');
  edStartFreq.Text := ifile.ReadString('DAC', 'StartFreq', '100');
  edEndFreq.Text := ifile.ReadString('DAC', 'EndFreq', '10000');
  edSweepTime.Text := ifile.ReadString('DAC', 'SweepTime', '10');
  edMinSamples.Text := ifile.ReadString('DAC', 'MinSamples', '1024');

  lDeviceIndex := ifile.ReadInteger('DAC', 'DeviceID', 0);
  if (lDeviceIndex >= 0) and (lDeviceIndex < cbDacDevices.Items.Count) then
    cbDacDevices.ItemIndex := lDeviceIndex;

  SyncProgramsFromUi;
  SelectCurrentProgram;
  UpdateModeView;
end;

procedure TDACFrm.InitPrograms;
begin
  FSimpleSinusProgram := TSimpleSinusProgram.Create;
  FAccurateSinusProgram := TAccurateSinusProgram.Create;
  FSweepSinProgram := TSweepSinProgram.Create;

  FSimpleSinusProgram.SetDevice(FDacDevice);
  FAccurateSinusProgram.SetDevice(FDacDevice);
  FSweepSinProgram.SetDevice(FDacDevice);
end;

procedure TDACFrm.SyncProgramsFromUi;
var
  lFreq: Double;
  lAmplitude: Double;
  lStartFreq: Double;
  lEndFreq: Double;
  lSweepTime: Double;
  lMinSamples: Integer;
begin
  if not Assigned(FSimpleSinusProgram) then
    Exit;

  lFreq := StrToFloatDef(edProgFreq.Text, 440);
  lAmplitude := edProgAmpl.Value;
  lStartFreq := StrToFloatDef(edStartFreq.Text, 100);
  lEndFreq := StrToFloatDef(edEndFreq.Text, 10000);
  lSweepTime := StrToFloatDef(edSweepTime.Text, 10);
  lMinSamples := StrToIntDef(edMinSamples.Text, 1024);

  FSimpleSinusProgram.Frequency := lFreq;
  FSimpleSinusProgram.Amplitude := lAmplitude;

  FAccurateSinusProgram.Frequency := lFreq;
  FAccurateSinusProgram.Amplitude := lAmplitude;
  FAccurateSinusProgram.MinSamplesTarget := lMinSamples;

  FSweepSinProgram.StartFrequency := lStartFreq;
  FSweepSinProgram.EndFrequency := lEndFreq;
  FSweepSinProgram.SweepTimeSec := lSweepTime;
  FSweepSinProgram.Amplitude := lAmplitude;
end;

procedure TDACFrm.SelectCurrentProgram;
var
  lNewProgram: TDacProgram;
  lWasActive: Boolean;
begin
  lNewProgram := FSimpleSinusProgram;
  if rgMode.ItemIndex = 1 then
    lNewProgram := FSweepSinProgram
  else if rgProgramType.ItemIndex = 1 then
    lNewProgram := FAccurateSinusProgram;

  if FCurrentProgram = lNewProgram then
  begin
    if Assigned(FCurrentProgram) and FCurrentProgram.IsPlaybackActive then
      btnPlayStop.Caption := 'Stop'
    else
      btnPlayStop.Caption := 'Play';
    Exit;
  end;

  lWasActive := Assigned(FCurrentProgram) and FCurrentProgram.IsPlaybackActive;
  if lWasActive then
    FCurrentProgram.Stop(False);

  FCurrentProgram := lNewProgram;

  if lWasActive then
  begin
    SyncProgramsFromUi;
    FCurrentProgram.Start(1);
  end;

  if Assigned(FCurrentProgram) and FCurrentProgram.IsPlaybackActive then
    btnPlayStop.Caption := 'Stop'
  else
    btnPlayStop.Caption := 'Play';
end;

procedure TDACFrm.btnPlayStopClick(Sender: TObject);
var
  lData: TDacData;
begin
  if not Assigned(FCurrentProgram) then
    Exit;

  if FCurrentProgram.IsPlaybackActive then
  begin
    logMessage('btnPlayStopClick: STOP');
    FCurrentProgram.Stop(False);
    btnPlayStop.Caption := 'Play';
    Exit;
  end;

  logMessage('btnPlayStopClick: PLAY');
  SyncProgramsFromUi;

  lData.fTransportDeviceIndex := cbDacDevices.ItemIndex;
  lData.fTransportSampleRate := 44100;
  lData.fTransportBitsPerSample := 16;
  lData.fTransportChannels := 1;
  lData.fTransportBufferSizeMS := 300;
  FCurrentProgram.ConfigureTransport(lData);

  FCurrentProgram.Start(1);
  btnPlayStop.Caption := 'Stop';
end;

procedure TDACFrm.FormCreate(Sender: TObject);
var
  lIniFile: TIniFile;
begin
  g_logFile := cLogFile.Create(ExtractFileDir(Application.ExeName) + '\log.txt', ';');

  FDacDevice := TSoundCardDac.Create;
  FDacDevice.Name := 'Тест DAQ';

  rgMode.ItemIndex := 0;
  rgProgramType.ItemIndex := 0;

  RefreshDeviceList;
  InitPrograms;
  SyncProgramsFromUi;
  SelectCurrentProgram;
  UpdateModeView;

  lIniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    load(lIniFile);
  finally
    lIniFile.Free;
  end;
end;

procedure TDACFrm.FormDestroy(Sender: TObject);
var
  lIniFile: TIniFile;
begin
  lIniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    save(lIniFile);
  finally
    lIniFile.Free;
  end;

  if Assigned(FCurrentProgram) then
    FCurrentProgram.Stop(False);

  FreeAndNil(FSweepSinProgram);
  FreeAndNil(FAccurateSinusProgram);
  FreeAndNil(FSimpleSinusProgram);
  FreeAndNil(FDacDevice);
end;

procedure TDACFrm.FormShow(Sender: TObject);
begin
end;

procedure TDACFrm.btnRefreshDevicesClick(Sender: TObject);
begin
  RefreshDeviceList;
end;

procedure TDACFrm.rgModeClick(Sender: TObject);
begin
  SelectCurrentProgram;
  UpdateModeView;
end;

procedure TDACFrm.rgProgramTypeClick(Sender: TObject);
begin
  SyncProgramsFromUi;
  SelectCurrentProgram;
  UpdateModeView;
end;

procedure TDACFrm.edProgFreqChange(Sender: TObject);
begin
  SyncProgramsFromUi;
end;

procedure TDACFrm.edProgAmplChange(Sender: TObject);
begin
  SyncProgramsFromUi;
end;

procedure TDACFrm.edMinSamplesChange(Sender: TObject);
begin
  SyncProgramsFromUi;
end;

procedure TDACFrm.edStartFreqChange(Sender: TObject);
begin
  SyncProgramsFromUi;
end;

procedure TDACFrm.edEndFreqChange(Sender: TObject);
begin
  SyncProgramsFromUi;
end;

procedure TDACFrm.edSweepTimeChange(Sender: TObject);
begin
  SyncProgramsFromUi;
end;

end.