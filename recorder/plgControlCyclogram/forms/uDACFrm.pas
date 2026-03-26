unit uDACFrm;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, uDacDevice, uSoundCardDac, Math, ImgList,
  IniFiles, uChart, uBuffTrend1d, uPage, uTextLabel, uAxis, uTrend,
  uHardwareMath, uSpin, ulogFile, uCommonTypes,
  uDACProgram,
  uAccuracyStepSin,
  uRecBasicFactory;
type
  TDACFrm = class(TRecFrm)
    pnlTop: TPanel;                  // Панель с органами управления ЦАП
    btnPlayStop: TButton;            // Кнопка запуска и остановки
    cbDacDevices: TComboBox;         // Список доступных устройств ЦАП
    btnRefreshDevices: TButton;      // Кнопка обновления списка устройств
    btnSave: TButton;
    btnLoad: TButton;
    TestBtn: TButton;
    pcPrograms: TPageControl;        // Вкладки выбора программы ЦАП
    tsSin: TTabSheet;
    tsAccuracySin: TTabSheet;
    tsSweepSin: TTabSheet;
    gbProgram: TGroupBox;            // Панель параметров активной программы
    lblProgFreq: TLabel;
    lblProgAmpl: TLabel;
    lblStartFreq: TLabel;
    lblEndFreq: TLabel;
    lblSweepTime: TLabel;
    cbVectorTag: TCheckBox;          // Флаг дублирования сигнала в тег
    lblVectorTagName: TLabel;
    edProgFreq: TEdit;               // Частота синуса
    edProgAmpl: TFloatSpinEdit;      // Амплитуда сигнала
    edStartFreq: TEdit;              // Начальная частота sweep
    edEndFreq: TEdit;                // Конечная частота sweep
    edSweepTime: TEdit;              // Время sweep
    edVectorTagName: TEdit;          // Имя выходного векторного тега
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    procedure btnPlayStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRefreshDevicesClick(Sender: TObject);
    procedure pcProgramsChange(Sender: TObject);
    procedure edProgFreqChange(Sender: TObject);
    procedure edProgAmplChange(Sender: TObject);
    procedure edStartFreqChange(Sender: TObject);
    procedure edEndFreqChange(Sender: TObject);
    procedure edSweepTimeChange(Sender: TObject);
    procedure cbVectorTagClick(Sender: TObject);
    procedure edVectorTagNameChange(Sender: TObject);
  private
    FDacDevice: TDacDevice;              // Текущее устройство ЦАП
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
  lPageIndex: Integer;
  lIsSweep: Boolean;
begin
  lPageIndex := pcPrograms.ActivePageIndex;
  lIsSweep := lPageIndex = 2;
  gbProgram.Caption := 'Signal Parameters';
  lblProgFreq.Visible := not lIsSweep;
  edProgFreq.Visible := not lIsSweep;
  lblStartFreq.Visible := lIsSweep;
  edStartFreq.Visible := lIsSweep;
  lblEndFreq.Visible := lIsSweep;
  edEndFreq.Visible := lIsSweep;
  lblSweepTime.Visible := lIsSweep;
  edSweepTime.Visible := lIsSweep;
end;

procedure TDACFrm.save(ifile: TIniFile);
begin
  ifile.WriteInteger('DAC', 'ProgramPage', pcPrograms.ActivePageIndex);
  ifile.WriteInteger('DAC', 'Mode', Ord(pcPrograms.ActivePageIndex = 2));
  ifile.WriteInteger('DAC', 'ProgramType', Ord(pcPrograms.ActivePageIndex = 1));
  ifile.WriteString('DAC', 'Freq', edProgFreq.Text);
  ifile.WriteString('DAC', 'Ampl', edProgAmpl.Text);
  ifile.WriteString('DAC', 'StartFreq', edStartFreq.Text);
  ifile.WriteString('DAC', 'EndFreq', edEndFreq.Text);
  ifile.WriteString('DAC', 'SweepTime', edSweepTime.Text);
  ifile.WriteBool('DAC', 'VectorTagEnabled', cbVectorTag.Checked);
  ifile.WriteString('DAC', 'VectorTagName', edVectorTagName.Text);
  ifile.WriteInteger('DAC', 'DeviceID', cbDacDevices.ItemIndex);
end;

procedure TDACFrm.load(ifile: TIniFile);
var
  lDeviceIndex: Integer;
  lProgramPage: Integer;
begin
  lProgramPage := ifile.ReadInteger('DAC', 'ProgramPage', -1);
  if lProgramPage < 0 then
  begin
    if ifile.ReadInteger('DAC', 'Mode', 0) = 1 then
      lProgramPage := 2
    else if ifile.ReadInteger('DAC', 'ProgramType', 0) = 1 then
      lProgramPage := 1
    else
      lProgramPage := 0;
  end;
  if (lProgramPage >= 0) and (lProgramPage < pcPrograms.PageCount) then
    pcPrograms.ActivePageIndex := lProgramPage
  else
    pcPrograms.ActivePageIndex := 0;
  edProgFreq.Text := ifile.ReadString('DAC', 'Freq', '440');
  edProgAmpl.Text := ifile.ReadString('DAC', 'Ampl', '0.5');
  edStartFreq.Text := ifile.ReadString('DAC', 'StartFreq', '100');
  edEndFreq.Text := ifile.ReadString('DAC', 'EndFreq', '10000');
  edSweepTime.Text := ifile.ReadString('DAC', 'SweepTime', '10');
  cbVectorTag.Checked := ifile.ReadBool('DAC', 'VectorTagEnabled', False);
  edVectorTagName.Text := ifile.ReadString('DAC', 'VectorTagName', '');
  lDeviceIndex := ifile.ReadInteger('DAC', 'DeviceID', 0);
  if (lDeviceIndex >= 0) and (lDeviceIndex < cbDacDevices.Items.Count) then
    cbDacDevices.ItemIndex := lDeviceIndex;
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
begin
  if not Assigned(FCurrentProgram) then
    Exit;
  lFreq := StrToFloatDef(edProgFreq.Text, 440);
  lAmplitude := edProgAmpl.Value;
  lStartFreq := StrToFloatDef(edStartFreq.Text, 100);
  lEndFreq := StrToFloatDef(edEndFreq.Text, 10000);
  lSweepTime := StrToFloatDef(edSweepTime.Text, 10);
  FCurrentProgram.VectorTagEnabled := cbVectorTag.Checked;
  FCurrentProgram.VectorTagName := edVectorTagName.Text;
  FCurrentProgram.UpdateVectorTag;
  if FCurrentProgram is TSweepSinProgram then
  begin
    TSweepSinProgram(FCurrentProgram).StartFrequency := lStartFreq;
    TSweepSinProgram(FCurrentProgram).EndFrequency := lEndFreq;
    TSweepSinProgram(FCurrentProgram).SweepTimeSec := lSweepTime;
    FCurrentProgram.Amplitude := lAmplitude;
    Exit;
  end;
  FCurrentProgram.Frequency := lFreq;
  FCurrentProgram.Amplitude := lAmplitude;
end;

procedure TDACFrm.SelectCurrentProgram;
var
  lNewProgram: TDacProgram;
  lWasActive: Boolean;
begin
  case pcPrograms.ActivePageIndex of
    1: lNewProgram := FAccurateSinusProgram;
    2: lNewProgram := FSweepSinProgram;
  else
    lNewProgram := FSimpleSinusProgram;
  end;
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
  SyncProgramsFromUi;
  if lWasActive then
    FCurrentProgram.Start(1);
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
  FDacDevice.Name := 'Sound DAC';
  pcPrograms.ActivePageIndex := 0;
  RefreshDeviceList;
  InitPrograms;
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
procedure TDACFrm.btnRefreshDevicesClick(Sender: TObject);
begin
  RefreshDeviceList;
end;
procedure TDACFrm.pcProgramsChange(Sender: TObject);
begin
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
procedure TDACFrm.cbVectorTagClick(Sender: TObject);
begin
  SyncProgramsFromUi;
end;
procedure TDACFrm.edVectorTagNameChange(Sender: TObject);
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