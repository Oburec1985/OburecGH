unit uDACFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uDacDevice, uSoundCardDac, Math, ImgList,
  IniFiles, uChart, uBuffTrend1d, uPage, uTextLabel, uAxis, uTrend,
  uHardwareMath, uSpin, ulogFile, uCommonTypes, uDACProgram,
  uAccuracyStepSin, uRecBasicFactory;

type
  TDACFrm = class(TRecFrm)
    pnlTop: TPanel;                  // Панель для кнопок управления
    btnPlayStop: TButton;            // Кнопка Play/Stop
    cbDacDevices: TComboBox;         // Список доступных DAC-устройств
    btnRefreshDevices: TButton;      // Обновить список устройств
    btnSave: TButton;
    btnLoad: TButton;
    TestBtn: TButton;
    rgMode: TRadioGroup;             // Выбор режима: Sin / SweepSin
    rgProgramType: TRadioGroup;      // Выбор типа программы для Sin
    gbProgram: TGroupBox;            // Общая панель параметров сигнала
    lblProgFreq: TLabel;
    lblProgAmpl: TLabel;
    lblMinSamples: TLabel;
    lblStartFreq: TLabel;
    lblEndFreq: TLabel;
    lblSweepTime: TLabel;
    edProgFreq: TEdit;               // Частота сигнала
    edProgAmpl: TFloatSpinEdit;      // Амплитуда сигнала
    edMinSamples: TEdit;             // Мин. число сэмплов для Accurate Sin
    edStartFreq: TEdit;              // Начальная частота sweep
    edEndFreq: TEdit;                // Конечная частота sweep
    edSweepTime: TEdit;              // Время sweep
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
    FDacDevice: TDacDevice;              // Экземпляр класса ЦАП
    FSimpleSinusProgram: TSimpleSinusProgram;
    FAccurateSinusProgram: TAccurateSinusProgram;
    FSweepSinProgram: TSweepSinProgram;
    FCurrentProgram: TDacProgram;        // Текущая активная программа
    procedure RefreshDeviceList;
    procedure UpdateModeView;
    procedure save(ifile: TIniFile);
    procedure load(ifile: TIniFile);
    procedure InitPrograms;
    procedure SyncProgramsFromUi;
    procedure SelectCurrentProgram;
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
  end;

  IDACFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cDacFrmFactory = class(cRecBasicFactory)
  private
    m_counter: Integer;
  protected
    procedure doDestroyForms; override;
  public
    constructor Create;
    destructor Destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

const
  c_Pic = 'GENSIGNALS';
  c_Name = 'DAC';
  c_defXSize = 458;
  c_defYSize = 214;
  IID_DACFRM: TGuid = (D1: $0D8A4AA1; D2: $E64D; D3: $4F42;
    D4: ($B5, $0A, $3C, $20, $B7, $99, $73, $A1));

var
  DACFrm: TDACFrm;
  g_DacFrmFactory: cDacFrmFactory;

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

  rgProgramType.Visible := not lIsSweep;
  gbProgram.Caption := 'Signal Parameters';

  lblProgFreq.Visible := not lIsSweep;
  edProgFreq.Visible := not lIsSweep;

  lblMinSamples.Visible := lIsAccurate;
  edMinSamples.Visible := lIsAccurate;

  lblStartFreq.Visible := lIsSweep;
  edStartFreq.Visible := lIsSweep;
  lblEndFreq.Visible := lIsSweep;
  edEndFreq.Visible := lIsSweep;
  lblSweepTime.Visible := lIsSweep;
  edSweepTime.Visible := lIsSweep;
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
  DACFrm := Self;

  if g_logFile = nil then
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
    LoadSettings(lIniFile, 'DAC');
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
    SaveSettings(lIniFile, 'DAC');
  finally
    lIniFile.Free;
  end;

  if Assigned(FCurrentProgram) then
    FCurrentProgram.Stop(False);

  FreeAndNil(FSweepSinProgram);
  FreeAndNil(FAccurateSinusProgram);
  FreeAndNil(FSimpleSinusProgram);
  FreeAndNil(FDacDevice);

  if DACFrm = Self then
    DACFrm := nil;
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

procedure TDACFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;
  save(a_pIni);
end;

procedure TDACFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;
  load(a_pIni);
end;

procedure IDACFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IDACFrm.doCreateFrm: TRecFrm;
begin
  Result := TDACFrm.Create(nil);
end;

function IDACFrm.doGetName: LPCSTR;
begin
  Result := c_Name;
end;

function IDACFrm.doRepaint: boolean;
begin
  Result := True;
end;

constructor cDacFrmFactory.Create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_DACFRM;
end;

destructor cDacFrmFactory.Destroy;
begin
  inherited;
end;

function cDacFrmFactory.doCreateForm: cRecBasicIFrm;
begin
  Result := IDACFrm.Create;
  Inc(m_counter);
end;

procedure cDacFrmFactory.doDestroyForms;
begin
  inherited;
end;

procedure cDacFrmFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

end.