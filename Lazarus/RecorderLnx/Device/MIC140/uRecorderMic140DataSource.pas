unit uRecorderMic140DataSource;

{
  MIC-140 core data source.

  The source uses the same RecorderLnx data-source contract as virtual/MERA
  playback sources. Transport/protocol code is isolated in
  uRecorderMebiusTcpProtocol and uRecorderMic140LegacyProtocol.
  Parsing helpers live in Device/MIC140/uRecorderMic140Utils (2026-06).
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, SyncObjs,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140LegacyProtocol, uRecorderMic140Utils,
  uRecorderMic140StreamTypes, uRecorderMic140DoubleBuffer, uRecorderMic140v2RawRing,
  uRecorderMic140ScanConfig, uRecorderMic140StreamFsm,
  uRecorderMic140AcquireTiming,
  uRecorderMic140StreamHelpers, uRecorderMic140LegacyTiming,
  uRecorderMic140Calibration, uRecorderMic140LegacyConstants,
  uRecorderMic140ProtocolDriver, uRecorderMic140DeviceApi,
  uRecorderTags;

const
  MIC140DefaultDiscoverySubnet = '192.168.14.';
  CMic140Mic140SubRev1 = 1;
  { Re-exported from StreamTypes / LegacyConstants for legacy callers. }
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;
  CMic140Range100mV = 0;
  CMic140RangeCount = 3;

type
  TRecorderMic140ChannelSettings = record
    ChannelAddress: string;
    RangeIndex: Integer;
    DefaultCjc: Boolean;
    CjcChannel: Integer;
    ThermocoupleScalePath: string;
    ThermocoupleScaleName: string;
    SoftBalance: Double;
    OutputMode: string;
    ChannelCalibrationEnabled: Boolean;
    HardwareCalibrationEnabled: Boolean;
    HardwareCalibrationName: string;
    { CJC offset °C per channel (SetTemperOffset); 0 = none. }
    CjcTemperOffsetC: Double;
  end;

  TRecorderMic140OutputMode = (
    momMillivolts,
    momTemperatureC
  );

  TRecorderMic140DataSource = class(TRecorderDataSourceBase, IRecorderZeroBalanceSupport)
  private
    fBlockPublishThread: TObject;
    fLegacyReadThread: TObject;
    fRawBuffer: TMic140RawDoubleBuffer;
    fRawRing: TMic140v2RawRing;
    fAcquireTiming: TRecorderMic140AcquireTiming;
    fStreamFsm: TMic140StreamFsm;
    fScanConfig: TRecorderMic140ScanConfig;
    fProtocolDriver: TRecorderMic140ProtocolDriver;
    fHardwarePrepared: Boolean;
    fHardwarePrepareAttempted: Boolean;
    fChannelTagNames: TStringList;
    fDevice: IRecorderDevice;
    fMic: IMic140Device;
    fGoodBlockCount: Int64;
    fLastStatusCode: Integer;
    fOutputMode: TRecorderMic140OutputMode;
    fPollFrequencyHz: Double;
    fReadFailCount: Integer;
    fBlockCountTagName: string;
    fStatusTagName: string;
    fTagNames: TStringList;
    fCjcActiveLogWritten: Boolean;
    fCjcCorrectLogWritten: Boolean;
    fTemperatureModeWarningLogged: Boolean;
    fTemperatureTagNames: TStringList;
    fDeviceSerial: Integer;
    fLastRawChannelMeans: array of Double;
    fLastRawBlockValid: Boolean;
  fLastChannelAdcSamples: array of Double;
  fLastChannelAdcValid: Boolean;
  fLastRingOverloadLogTick: QWord;
  fLastPublishedNumBuff: Word;
  fLastPublishedNumBuffValid: Boolean;
  fPublishedNumBuffGapCount: Integer;
  fPublishedCorruptCount: Integer;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    function TemperatureChannelSelected(AIndex: Integer): Boolean;
    function ChannelIndexForTag(ATag: TRecorderTag): Integer;
    function GetLastRawChannelMean(AChannelIndex: Integer; out AMean: Double): Boolean;
    function Mic140RawSample(const ABlock: TRecorderDeviceSampleBlock;
      AChannelIndex, ASampleIndex: Integer; ATag: TRecorderTag): Double;
    procedure RebuildTemperatureTagNames;
    procedure PublishDiagnostics(AStatusCode: Integer; const AStatusText: string;
      AForce: Boolean = False);
    procedure PublishBlockCounter(ABlockCount: Int64);
    procedure PublishTemperatureBlocks(const AAux: TMic140AuxTemperatureBlock;
      const ATimes: TRecorderDoubleArray);
    procedure EnsureBlockPublishThread;
    procedure StopBlockPublishThread;
    procedure EnsureLegacyReadThread;
    procedure StopLegacyReadThread;
    procedure EnqueueLegacyRawBlock(const ARaw: TMic140LegacyRawBlock);
    function RawHasPending: Boolean;
    function RawTryTake(out ARaw: TMic140LegacyRawBlock): Boolean;
    procedure RawEnqueue(const ARaw: TMic140LegacyRawBlock; out ADropped: Boolean);
    function RawPendingLag: Int64;
    function RawDroppedCount: Int64;
    function TryEnqueueGoodLegacyRawBlock(const ARaw: TMic140LegacyRawBlock): Boolean;
    procedure ProcessLegacyRawBlock(const ARaw: TMic140LegacyRawBlock);
    procedure CheckPublishedNumBuff(const ARaw: TMic140LegacyRawBlock);
    procedure LogMic140StreamSummary(const ARaw: TMic140LegacyRawBlock);
    procedure LogMic140StrideMisalignmentIfNeeded(const ARaw: TMic140LegacyRawBlock;
      const ABlock: TRecorderDeviceSampleBlock);
    procedure ProcessAndPublishBlock(const ABlock: TRecorderDeviceSampleBlock);
    procedure SyncScanConfig;
    procedure EnsureProtocolDriver;
    procedure FreeProtocolDriver;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
    procedure PrepareHardware; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ATagNames: TStrings = nil; AOutputMode: TRecorderMic140OutputMode = momMillivolts);
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
    procedure RequestStop; override;
    function ZeroBalanceTags(AOwner: TComponent; ATags: TList;
      AMessages: TStrings): Boolean;
  end;

function RecorderMic140ZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager; AMessages: TStrings): Boolean;
function RecorderMic140TestConnection(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal = 250): Boolean;
procedure RecorderMic140Discover(AFoundHosts: TStrings;
  const ASubnetPrefix: string = MIC140DefaultDiscoverySubnet;
  APort: Word = MIC140DefaultPort; ATimeoutMs: Cardinal = 180);
procedure RecorderMic140ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
function RecorderMic140OutputModeToConfigName(AValue: TRecorderMic140OutputMode): string;
function RecorderMic140ConfigNameToOutputMode(const AValue: string): TRecorderMic140OutputMode;
function RecorderMic140OutputModeUnitName(AValue: TRecorderMic140OutputMode): string;
function RecorderMic140QueryDeviceSerial(const AHost: string; APort: Word;
  out ADeviceSerial: Integer): Boolean;
function RecorderMic140QueryHardwareCalibrSerial(const AHost: string; APort: Word;
  out ACalibrSerial: Integer): Boolean;
function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;
  out ADeviceSerial: Integer; out AVersionText: string;
  out ADevSubRev: Integer): Boolean;
function RecorderMic140DefaultCjcChannel(AChannelIndex: Integer;
  ADevSubRev: Integer): Integer;
function RecorderMic140FormatAdcRangeMv(ARangeIndex: Integer): string;
function RecorderMic140FormatAdcRangeGrad(ARangeIndex: Integer): string;
function RecorderMic140RangeComboLabel(ARangeIndex: Integer): string;
procedure RecorderMic140InitChannelSettings(out ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer);
function RecorderMic140ChannelUsesTemperature(
  const ASettings: TRecorderMic140ChannelSettings): Boolean;
function RecorderMic140ChannelCjcNumber(const ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer): Integer;
function RecorderMic140TagEffectiveCjcChannel(ATag: TRecorderTag;
  AChannelIndex, ADevSubRev: Integer): Integer;
function RecorderMic140ChannelGradRangeText(
  const ASettings: TRecorderMic140ChannelSettings): string;
procedure RecorderMic140RestoreChannelSettingsFromTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ASettings: TRecorderMic140ChannelSettings);
function RecorderMic140EnsureThermocoupleCalibration(
  ARegistry: TRecorderTagRegistry;
  const ASettings: TRecorderMic140ChannelSettings): string;

implementation

uses
  Math, StrUtils, LazFileUtils, Controls, Dialogs, LCLIntf, Variants,
  uSharedFileLogger, uRecorderMeraPaths, uRecorderDebugLog,
  uRecorderMeraSdbThermocouples, uRecorderSdbStore,
  uRecorderMic140FlashConstants,
  uRecorderMic140Thermocouple, uRecorderMic140MebiusConstants,
  uRecorderMic140DeviceConfig, uRecorderMic140Flash,
  uRecorderMic140MebiusTypes,
  uRecorderMic140LegacyChannelDesc, uRecorderMic140LegacyScanDriver,
  uRecorderMic140v2Factory
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

const
  CMic140StatusDisconnected = 0;
  CMic140StatusConnected = 1;
  CMic140StatusProgrammed = 2;
  CMic140StatusStarted = 3;
  CMic140StatusError = -1;
  CMic140ReadTimeoutMinMs = 1500;
  CMic140IoCtlTypeCallCommand = 2;
  CMic140IoCtlCmdSetControllerParams =
    (CMic140IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic140BalanceMinSamples = 30;
  CMic140BalanceDiscardSamples = 10;
  CMic140BalanceSampleFraction = 0.3;
  CMic140Range5mV = 2;

procedure RecorderMic140ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
var
  I: Integer;
  lCapacity: Integer;
  lFrequencyHz: Double;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (ASourceId = '') then
    Exit;

  lFrequencyHz := RecorderMic140NormalizeFrequency(AFrequencyHz);
  lCapacity := Ceil(Max(4096, lFrequencyHz));
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) then
    begin
      lTag.PollFrequencyHz := lFrequencyHz;
      lTag.EnsureBufferCapacity(lCapacity);
    end;
  end;
end;

function RecorderMic140TestConnection(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
begin
  Result := RecorderMic140TcpProbe(AHost, APort, ATimeoutMs);
end;

type
  TMic140DiscoveryThread = class(TThread)
  private
    fFound: Boolean;
    fHost: string;
    fPort: Word;
    fTimeoutMs: Cardinal;
  protected
    procedure Execute; override;
  public
    constructor Create(const AHost: string; APort: Word; ATimeoutMs: Cardinal);
    property Found: Boolean read fFound;
    property Host: string read fHost;
  end;

constructor TMic140DiscoveryThread.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  Start;
end;

procedure TMic140DiscoveryThread.Execute;
begin
  fFound := RecorderMic140TestConnection(fHost, fPort, fTimeoutMs);
end;

procedure RecorderMic140Discover(AFoundHosts: TStrings;
  const ASubnetPrefix: string; APort: Word; ATimeoutMs: Cardinal);
var
  I: Integer;
  lThreads: TList;
  lThread: TMic140DiscoveryThread;
begin
  if AFoundHosts = nil then
    Exit;
  AFoundHosts.Clear;
  lThreads := TList.Create;
  try
    lThread := TMic140DiscoveryThread.Create(MIC140DefaultHost, APort, ATimeoutMs);
    lThreads.Add(lThread);
    for I := 1 to 254 do
    begin
      if SameText(ASubnetPrefix + IntToStr(I), MIC140DefaultHost) then
        Continue;
      lThread := TMic140DiscoveryThread.Create(ASubnetPrefix + IntToStr(I),
        APort, ATimeoutMs);
      lThreads.Add(lThread);
    end;

    for I := 0 to lThreads.Count - 1 do
    begin
      lThread := TMic140DiscoveryThread(lThreads[I]);
      lThread.WaitFor;
      if lThread.Found and (AFoundHosts.IndexOf(lThread.Host) < 0) then
        AFoundHosts.Add(lThread.Host);
      lThread.Free;
    end;
  finally
    lThreads.Free;
  end;
end;

function RecorderMic140OutputModeToConfigName(
  AValue: TRecorderMic140OutputMode): string;
begin
  case AValue of
    momTemperatureC: Result := 'degC';
  else
    Result := 'mV';
  end;
end;

function RecorderMic140ConfigNameToOutputMode(
  const AValue: string): TRecorderMic140OutputMode;
begin
  if SameText(Trim(AValue), 'degC') or SameText(Trim(AValue), 'C') or
    SameText(Trim(AValue), 'temperature') then
    Result := momTemperatureC
  else
    Result := momMillivolts;
end;

function RecorderMic140OutputModeUnitName(
  AValue: TRecorderMic140OutputMode): string;
begin
  case AValue of
    momTemperatureC: Result := 'degC';
  else
    Result := 'mV';
  end;
end;

function Mic140TagHasThermocoupleCalibration(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): Boolean;
begin
  Result := (ARegistry <> nil) and
    (ARegistry.FindTagThermocoupleCalibration(ATag) <> nil);
end;

function Mic140TryInvertTagCalibration(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; ATemperatureC: Double; out AMillivolts: Double): Boolean;
begin
  Result := (ARegistry <> nil) and
    ARegistry.InvertTagThermocoupleValue(ATag, ATemperatureC, AMillivolts);
end;

function Mic140TryTransformTInSampleToJunctionC(ARegistry: TRecorderTagRegistry;
  ATemperatureTag: TRecorderTag; ADeviceSerial, ATInListIndex, ADevSubRev: Integer;
  ARawValue: Double; out AJunctionC: Double): Boolean;
var
  lCalName: string;
  lCalibration: TRecorderCalibration;
  lHardwareValue: Double;
  lGotHardware: Boolean;
begin
  Result := False;
  AJunctionC := 0.0;
  if ARegistry = nil then
    Exit;
  if (ATemperatureTag <> nil) and (not ATemperatureTag.HardwareCalibrationEnabled) then
    Exit;
  lGotHardware := False;
  if (ATemperatureTag <> nil) and ATemperatureTag.HardwareCalibrationEnabled and
    (Trim(ATemperatureTag.HardwareCalibrationName) <> '') then
  begin
    lHardwareValue := ARegistry.TransformTagHardwareValue(ATemperatureTag, ARawValue);
    lGotHardware := True;
  end
  else if RecorderMic140EnsureTInHardwareCalibration(ARegistry, ADeviceSerial,
    ATInListIndex, ADevSubRev, lCalName) then
  begin
    lCalibration := ARegistry.FindCalibrationByName(lCalName);
    if lCalibration <> nil then
    begin
      lHardwareValue := lCalibration.Transform(ARawValue);
      lGotHardware := True;
    end;
  end;
  if not lGotHardware then
    Exit;
  { ScanMIC140: tar->Eval(tc_->loc_data) only when T has its own tare; otherwise
    tc_->loc_data is junction temperature in degC from TIn hardware. }
  if Mic140TagHasThermocoupleCalibration(ARegistry, ATemperatureTag) then
    AJunctionC := ARegistry.TransformTagThermocoupleValue(ATemperatureTag,
      lHardwareValue)
  else
    AJunctionC := lHardwareValue;
  Result := Mic140JunctionTemperatureLooksValid(AJunctionC);
end;

function Mic140TransformThermocoupleChannelSample(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; AChannelIndex: Integer; ARawCode, AColdJunctionC: Double): Double;
var
  lChannelMv: Double;
  lCorrectedMv: Double;
  lJunctionC: Double;
  lJunctionMv: Double;
  lSettings: TRecorderMic140ChannelSettings;
  lChannelNumber: Integer;
  lCjcOffsetC: Double;
begin
  if (ARegistry = nil) or (ATag = nil) then
    Exit(ARawCode);
  if not ATag.HardwareCalibrationEnabled then
    Exit(ARawCode);
  { 1. Код АЦП -> мВ (аппаратная ГХ канала). }
  lChannelMv := ARegistry.TransformTagHardwareValue(ATag, ARawCode);
  if not Mic140TagHasThermocoupleCalibration(ARegistry, ATag) then
    Exit(lChannelMv);
  if AColdJunctionC <= CMic140CjcNotAvailable * 0.5 then
    Exit(ARegistry.TransformTagThermocoupleValue(ATag, lChannelMv));
  if not Mic140JunctionTemperatureLooksValid(AColdJunctionC) then
    Exit(ARegistry.TransformTagThermocoupleValue(ATag, lChannelMv));
  lCjcOffsetC := 0.0;
  if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
    lSettings) then
    lCjcOffsetC := lSettings.CjcTemperOffsetC;
  { 2. По T_КТХС найти мВ на ГХ термопары и прибавить к мВ канала. }
  lJunctionC := AColdJunctionC + lCjcOffsetC;
  if not ARegistry.InvertTagThermocoupleValue(ATag, lJunctionC, lJunctionMv) then
    Exit(ARegistry.TransformTagThermocoupleValue(ATag, lChannelMv));
  lCorrectedMv := lChannelMv + lJunctionMv;
  { 3. Скорректированные мВ -> °C по ГХ термопары. }
  Result := ARegistry.TransformTagThermocoupleValue(ATag, lCorrectedMv);
end;

function Mic140TryGetColdJunctionTemperature(ARegistry: TRecorderTagRegistry;
  ATemperatureTag: TRecorderTag; const AAux: TMic140AuxTemperatureBlock;
  ACjcChannel, ADeviceSerial, ADevSubRev: Integer;
  out ATemperatureC: Double): Boolean;
var
  I: Integer;
  lCjcIndex: Integer;
  lCount: Integer;
  lSampleJunctionC: Double;
  lSum: Double;
begin
  Result := False;
  ATemperatureC := CMic140CjcNotAvailable;
  lCjcIndex := ACjcChannel - 1;
  if (ARegistry = nil) or (lCjcIndex < 0) or
    (lCjcIndex >= AAux.ChannelCount) or
    (lCjcIndex >= Length(AAux.Values)) then
    Exit;

  lSum := 0;
  lCount := 0;
  for I := 0 to AAux.SampleCount - 1 do
    if (lCjcIndex < Length(AAux.Valid)) and
      (I < Length(AAux.Valid[lCjcIndex])) and
      AAux.Valid[lCjcIndex][I] and
      (I < Length(AAux.Values[lCjcIndex])) then
    begin
      if Mic140TryTransformTInSampleToJunctionC(ARegistry, ATemperatureTag,
        ADeviceSerial, lCjcIndex, ADevSubRev,
        AAux.Values[lCjcIndex][I], lSampleJunctionC) then
      begin
        lSum := lSum + lSampleJunctionC;
        Inc(lCount);
      end;
    end;
  if lCount <= 0 then
    Exit;
  ATemperatureC := lSum / lCount;
  Result := True;
end;

function RecorderMic140QueryDeviceSerial(const AHost: string; APort: Word;
  out ADeviceSerial: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ADeviceSerial := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ADeviceSerial := RecorderMic140DeviceSerialFromFirmware(lFirmware);
      Result := ADeviceSerial > 0;
    end;
  finally
    lClient.Free;
  end;
end;

function RecorderMic140QueryHardwareCalibrSerial(const AHost: string; APort: Word;
  out ACalibrSerial: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ACalibrSerial := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ACalibrSerial := RecorderMic140HardwareCalibrSerialFromFirmware(lFirmware);
      Result := ACalibrSerial > 0;
    end;
  finally
    lClient.Free;
  end;
end;

function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;
  out ADeviceSerial: Integer; out AVersionText: string;
  out ADevSubRev: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ADeviceSerial := 0;
  AVersionText := '';
  ADevSubRev := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ADeviceSerial := RecorderMic140DisplaySerialFromFirmware(lFirmware, AHost);
      AVersionText := RecorderMic140FirmwareVersionText(lFirmware);
      ADevSubRev := RecorderMic140DevSubRevFromFirmware(lFirmware);
      Result := (ADeviceSerial > 0) or (AVersionText <> '');
    end;
  finally
    lClient.Free;
  end;
end;

function RecorderMic140DefaultCjcChannel(AChannelIndex: Integer;
  ADevSubRev: Integer): Integer;
begin
  Result := Mic140DefaultCjcTChannelNumber(AChannelIndex);
end;

function RecorderMic140FormatAdcRangeMv(ARangeIndex: Integer): string;
const
  CMic140RangeMinMax: array[0..CMic140RangeCount - 1] of record MinV, MaxV: Double end =
    ((MinV: -0.02; MaxV: 0.08), (MinV: -0.01; MaxV: 0.04), (MinV: -0.005; MaxV: 0.02));
var
  lIdx: Integer;
begin
  lIdx := ARangeIndex;
  if (lIdx < 0) or (lIdx >= CMic140RangeCount) then
    lIdx := CMic140Range100mV;
  Result := Format('%.1f...%.1f', [
    CMic140RangeMinMax[lIdx].MinV * 1000.0,
    CMic140RangeMinMax[lIdx].MaxV * 1000.0]);
end;

function RecorderMic140FormatAdcRangeGrad(ARangeIndex: Integer): string;
begin
  Result := RecorderMic140FormatAdcRangeMv(ARangeIndex);
end;

function RecorderMic140RangeComboLabel(ARangeIndex: Integer): string;
const
  CLabels: array[0..CMic140RangeCount - 1] of string =
    ('-20..80mV', '-10..40mV', '-5..20mV');
begin
  if (ARangeIndex >= 0) and (ARangeIndex < CMic140RangeCount) then
    Result := CLabels[ARangeIndex]
  else
    Result := CLabels[CMic140Range100mV];
end;

procedure RecorderMic140InitChannelSettings(out ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer);
begin
  ASettings.RangeIndex := CMic140Range100mV;
  ASettings.DefaultCjc := True;
  ASettings.CjcChannel := RecorderMic140DefaultCjcChannel(AChannelIndex, ADevSubRev);
  ASettings.ThermocoupleScalePath := '';
  ASettings.ThermocoupleScaleName := '';
  ASettings.SoftBalance := 0;
  ASettings.CjcTemperOffsetC := 0.0;
end;

function RecorderMic140ChannelUsesTemperature(
  const ASettings: TRecorderMic140ChannelSettings): Boolean;
begin
  Result := Trim(ASettings.ThermocoupleScaleName) <> '';
end;

function RecorderMic140ChannelCjcNumber(const ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer): Integer;
begin
  if ASettings.DefaultCjc then
    Result := RecorderMic140DefaultCjcChannel(AChannelIndex, ADevSubRev)
  else
    Result := ASettings.CjcChannel;
end;

function RecorderMic140TagEffectiveCjcChannel(ATag: TRecorderTag;
  AChannelIndex, ADevSubRev: Integer): Integer;
var
  lSettings: TRecorderMic140ChannelSettings;
begin
  RecorderMic140InitChannelSettings(lSettings, AChannelIndex, ADevSubRev);
  if ATag <> nil then
  begin
    lSettings.DefaultCjc := ATag.Mic140CjcDefault;
    if (not ATag.Mic140CjcDefault) and
      (ATag.Mic140CjcChannel >= 1) and
      (ATag.Mic140CjcChannel <= MIC140TemperatureChannelCount) then
      lSettings.CjcChannel := ATag.Mic140CjcChannel;
  end;
  Result := RecorderMic140ChannelCjcNumber(lSettings, AChannelIndex, ADevSubRev);
end;

function RecorderMic140ChannelGradRangeText(
  const ASettings: TRecorderMic140ChannelSettings): string;
const
  CRangeMinMax: array[0..CMic140RangeCount - 1] of record MinV, MaxV: Double end =
    ((MinV: -0.02; MaxV: 0.08), (MinV: -0.01; MaxV: 0.04), (MinV: -0.005; MaxV: 0.02));
var
  lCalibration: TRecorderCalibration;
  lDstMax: Double;
  lDstMin: Double;
  lIdx: Integer;
  lMaxC: Double;
  lMinC: Double;
  lMaxMv: Double;
  lMinMv: Double;
  lScaleKey: string;
begin
  if not RecorderMic140ChannelUsesTemperature(ASettings) then
    Exit('');
  lScaleKey := RecorderMeraResolveThermocoupleScaleKey(
    ASettings.ThermocoupleScalePath, ASettings.ThermocoupleScaleName);
  lIdx := ASettings.RangeIndex;
  if (lIdx < 0) or (lIdx >= CMic140RangeCount) then
    lIdx := CMic140Range100mV;
  lMinMv := CRangeMinMax[lIdx].MinV * 1000.0;
  lMaxMv := CRangeMinMax[lIdx].MaxV * 1000.0;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibration(lScaleKey, lCalibration) then
      Exit('');
    lMinC := lCalibration.Transform(lMinMv);
    lMaxC := lCalibration.Transform(lMaxMv);
    if RecorderMeraThermocoupleDstRange(lScaleKey, lDstMin, lDstMax) then
    begin
      if lMinC < lDstMin then
        lMinC := lDstMin;
      if lMinC > lDstMax then
        lMinC := lDstMax;
      if lMaxC < lDstMin then
        lMaxC := lDstMin;
      if lMaxC > lDstMax then
        lMaxC := lDstMax;
    end;
    Result := Format('%.1f...%.1f', [Min(lMinC, lMaxC), Max(lMinC, lMaxC)]);
  finally
    lCalibration.Free;
  end;
end;

procedure RecorderMic140RestoreChannelSettingsFromTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ASettings: TRecorderMic140ChannelSettings);
var
  J: Integer;
  lCal: TRecorderCalibration;
  lCalName: string;
  lResolvedKey: string;
begin
  if ATag = nil then
    Exit;
  if (ATag.MeasRangeIndex >= 0) and (ATag.MeasRangeIndex < CMic140RangeCount) then
    ASettings.RangeIndex := ATag.MeasRangeIndex;
  ASettings.SoftBalance := ATag.Mic140SoftBalance;
  ASettings.DefaultCjc := ATag.Mic140CjcDefault;
  if (ATag.Mic140CjcChannel >= 1) and
    (ATag.Mic140CjcChannel <= MIC140TemperatureChannelCount) then
    ASettings.CjcChannel := ATag.Mic140CjcChannel;
  if Trim(ATag.Mic140ThermocoupleScaleName) <> '' then
  begin
    ASettings.ThermocoupleScaleName := ATag.Mic140ThermocoupleScaleName;
    ASettings.ThermocoupleScalePath := ATag.Mic140ThermocoupleScalePath;
    if Trim(ASettings.ThermocoupleScalePath) = '' then
      ASettings.ThermocoupleScalePath :=
        RecorderMeraThermocoupleRelativePath(ASettings.ThermocoupleScaleName);
    lResolvedKey := RecorderMeraResolveThermocoupleScaleKey(
      ASettings.ThermocoupleScalePath, ASettings.ThermocoupleScaleName);
    if lResolvedKey <> '' then
      ASettings.ThermocoupleScalePath := lResolvedKey;
    Exit;
  end;
  if ATag.CalibrationNames = nil then
    Exit;
  for J := 0 to ATag.CalibrationNames.Count - 1 do
  begin
    lCalName := Trim(ATag.CalibrationNames[J]);
    if Pos('TC ', lCalName) <> 1 then
      Continue;
    ASettings.ThermocoupleScaleName := Trim(Copy(lCalName, 4, MaxInt));
    if ARegistry <> nil then
    begin
      lCal := ARegistry.FindCalibrationByName(lCalName);
      if (lCal <> nil) and (Trim(lCal.Description) <> '') then
        ASettings.ThermocoupleScalePath := lCal.Description
      else if ASettings.ThermocoupleScaleName <> '' then
        ASettings.ThermocoupleScalePath :=
          RecorderMeraThermocoupleRelativePath(ASettings.ThermocoupleScaleName);
    end;
    Break;
  end;
end;

function RecorderMic140EnsureThermocoupleCalibration(
  ARegistry: TRecorderTagRegistry;
  const ASettings: TRecorderMic140ChannelSettings): string;
var
  lCalibration: TRecorderCalibration;
  lName: string;
  lScaleKey: string;
begin
  Result := '';
  if (ARegistry = nil) or (not RecorderMic140ChannelUsesTemperature(ASettings)) then
    Exit;
  lScaleKey := RecorderMeraResolveThermocoupleScaleKey(
    ASettings.ThermocoupleScalePath, ASettings.ThermocoupleScaleName);
  if lScaleKey = '' then
    Exit;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderMeraLoadThermocoupleCalibration(ASettings.ThermocoupleScalePath,
      ASettings.ThermocoupleScaleName, lCalibration) then
      Exit;
    lCalibration.Extrapolation := True;
    lCalibration.UnitIn := 'mV';
    lCalibration.UnitOut := 'degC';
    lName := 'TC ' + ASettings.ThermocoupleScaleName;
    lCalibration.Name := lName;
    lCalibration.Description := lScaleKey;
    if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) <> nil then
      Result := lName;
  finally
    lCalibration.Free;
  end;
end;

{ TRecorderMic140DataSource }

constructor TRecorderMic140DataSource.Create(const ASourceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ATagNames: TStrings; AOutputMode: TRecorderMic140OutputMode);
var
  lNodeNumber: Integer;
begin
  inherited Create(ASourceId, 'MIC-140', AUpdateTimeMs);
  fLastStatusCode := Low(Integer);
  fOutputMode := AOutputMode;
  fPollFrequencyHz := RecorderMic140NormalizeFrequency(APollFrequencyHz);
  fCjcCorrectLogWritten := False;
  fTemperatureModeWarningLogged := False;
  fDeviceSerial := 0;
  fLastRawBlockValid := False;
  lNodeNumber := MIC140DefaultNodeNumber;
  fStatusTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'status');
  fBlockCountTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'blocks');
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fChannelTagNames.Sorted := False;
  fTemperatureTagNames := TStringList.Create;
  fTemperatureTagNames.CaseSensitive := False;
  fTemperatureTagNames.Sorted := False;
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  fTagNames.Sorted := False;
  if ATagNames <> nil then
    fTagNames.Assign(ATagNames);
  fMic := CreateMic140Device(ASourceId, AHost, APort,
    AChannelCount, APollFrequencyHz, AUpdateTimeMs);
  fDevice := fMic;
  lNodeNumber := fMic.GetNodeNumber;
  fStatusTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'status');
  fBlockCountTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'blocks');
  RebuildTemperatureTagNames;
  if (fMic <> nil) and fMic.UsesRawRing then
    fRawRing := TMic140v2RawRing.Create
  else
    fRawBuffer := TMic140RawDoubleBuffer.Create;
  fAcquireTiming := TRecorderMic140AcquireTiming.Create(APollFrequencyHz, AUpdateTimeMs);
  fStreamFsm := TMic140StreamFsm.Create(fAcquireTiming);
  fScanConfig := TRecorderMic140ScanConfig.Create(AChannelCount, APollFrequencyHz, AUpdateTimeMs);
  fHardwarePrepared := False;
  fHardwarePrepareAttempted := False;
  fLastRingOverloadLogTick := 0;
end;

procedure TRecorderMic140DataSource.PublishDiagnostics(AStatusCode: Integer;
  const AStatusText: string; AForce: Boolean);
var
  lTag: TRecorderTag;
begin
  if Registry = nil then
    Exit;
  lTag := Registry.FindByName(fStatusTagName);
  if lTag = nil then
    Exit;
  lTag.TextValue := AStatusText;
  lTag.Description := Format('MIC-140 connection status: %s', [AStatusText]);
  if (not AForce) and (fLastStatusCode = AStatusCode) then
    Exit;
  fLastStatusCode := AStatusCode;
  Registry.PublishValue(fStatusTagName, GetTickCount64 / 1000.0, AStatusCode);
  Mic140LogWarning(Format('[DataSource:%s] MIC-140 status=%d %s',
    [SourceId, AStatusCode, AStatusText]));
end;

procedure TRecorderMic140DataSource.PublishBlockCounter(ABlockCount: Int64);
var
  lTag: TRecorderTag;
begin
  if Registry = nil then
    Exit;
  lTag := Registry.FindByName(fBlockCountTagName);
  if lTag = nil then
    Exit;
  lTag.TextValue := IntToStr(ABlockCount);
  Registry.PublishValue(fBlockCountTagName, GetTickCount64 / 1000.0, ABlockCount);
end;

procedure TRecorderMic140DataSource.PublishTemperatureBlocks(
  const AAux: TMic140AuxTemperatureBlock; const ATimes: TRecorderDoubleArray);
var
  I: Integer;
  lJ: Integer;
  lTag: TRecorderTag;
  lValues: TRecorderDoubleArray;
begin
  if (Registry = nil) or (AAux.ChannelCount <= 0) or (AAux.SampleCount <= 0) then
    Exit;
  SetLength(lValues, AAux.SampleCount);
  for I := 0 to Min(AAux.ChannelCount, fTemperatureTagNames.Count) - 1 do
  begin
    if not TemperatureChannelSelected(I + 1) then
      Continue;
    lTag := Registry.FindByName(fTemperatureTagNames[I]);
    if lTag = nil then
      lTag := FindTagBySourceAddress(Registry, fTemperatureTagNames[I]);
    if lTag = nil then
      Continue;
    for lJ := 0 to AAux.SampleCount - 1 do
    begin
      if (I < Length(AAux.Valid)) and
        (lJ < Length(AAux.Valid[I])) and
        AAux.Valid[I][lJ] then
        lValues[lJ] := AAux.Values[I][lJ]
      else
        lValues[lJ] := 0;
    end;
    lTag.TextValue := FormatFloat('0.###', lValues[AAux.SampleCount - 1]);
    Registry.PublishBlock(lTag.Name, ATimes, lValues, AAux.SampleCount);
  end;
end;

destructor TRecorderMic140DataSource.Destroy;
begin
  StopBlockPublishThread;
  Stop;
  fScanConfig.Free;
  fStreamFsm.Free;
  fAcquireTiming.Free;
  fRawBuffer.Free;
  fRawRing.Free;
  fMic := nil;
  fDevice := nil;
  fTagNames.Free;
  fTemperatureTagNames.Free;
  fChannelTagNames.Free;
  inherited Destroy;
end;

function TRecorderMic140DataSource.FindTagBySourceAddress(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, SourceId) and
      SameMic140Address(ARegistry.Tags[I].Address, AAddress) then
      Exit(ARegistry.Tags[I]);
end;

function TRecorderMic140DataSource.TemperatureChannelSelected(
  AIndex: Integer): Boolean;
var
  lDisplayName: string;
begin
  Result := fTagNames.Count = 0;
  if Result then
    Exit;
  if (AIndex < 1) or (AIndex > fTemperatureTagNames.Count) then
    Exit(False);
  Result := fTagNames.IndexOf(fTemperatureTagNames[AIndex - 1]) >= 0;
  if Result then
    Exit;
  if fDeviceSerial > 0 then
  begin
    lDisplayName := RecorderMic140TemperatureDisplayName(fDeviceSerial, AIndex);
    Result := fTagNames.IndexOf(lDisplayName) >= 0;
  end;
end;

procedure TRecorderMic140DataSource.RebuildTemperatureTagNames;
var
  I: Integer;
begin
  fTemperatureTagNames.Clear;
  for I := 1 to MIC140TemperatureChannelCount do
    fTemperatureTagNames.Add(RecorderMic140TemperatureAddressText(fDeviceSerial, I));
end;

function TRecorderMic140DataSource.ChannelIndexForTag(ATag: TRecorderTag): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (ATag = nil) or (fChannelTagNames = nil) then
    Exit;
  for I := 0 to fChannelTagNames.Count - 1 do
    if SameText(fChannelTagNames[I], ATag.Name) then
      Exit(I);
end;

function TRecorderMic140DataSource.GetLastRawChannelMean(AChannelIndex: Integer;
  out AMean: Double): Boolean;
begin
  Result := False;
  if not fLastRawBlockValid then
    Exit;
  if (AChannelIndex < 0) or (AChannelIndex >= Length(fLastRawChannelMeans)) then
    Exit;
  AMean := fLastRawChannelMeans[AChannelIndex];
  Result := True;
end;

function TRecorderMic140DataSource.Mic140RawSample(
  const ABlock: TRecorderDeviceSampleBlock; AChannelIndex, ASampleIndex: Integer;
  ATag: TRecorderTag): Double;
begin
  Result := ABlock.Values[AChannelIndex][ASampleIndex];
  if (ATag <> nil) and (ATag.Mic140SoftBalance <> 0) then
    Result := Result - ATag.Mic140SoftBalance;
end;

function TRecorderMic140DataSource.ZeroBalanceTags(AOwner: TComponent; ATags: TList;
  AMessages: TStrings): Boolean;
var
  lFiltered: TList;
  I: Integer;
  lTag: TRecorderTag;
begin
  lFiltered := TList.Create;
  try
    for I := 0 to ATags.Count - 1 do
    begin
      lTag := TRecorderTag(ATags[I]);
      if SameText(lTag.SourceId, SourceId) then
        lFiltered.Add(lTag);
    end;
    Result := RecorderMic140ZeroBalanceTags(AOwner, Registry, lFiltered, nil,
      AMessages);
  finally
    lFiltered.Free;
  end;
end;

function RecorderMic140ZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager; AMessages: TStrings): Boolean;
var
  lChannelNumbers: array of Integer;
  lDev: IMic140Device;
  lFreq: Double;
  lHost: string;
  lMeans: TRecorderDoubleArray;
  lMessages: TStringList;
  lPort: Word;
  lSourceId: string;
  lTag: TRecorderTag;
  lTempIndex: Integer;
  lErrorMessage: string;
  lWasRunning: Boolean;
  I, J, lChannelNumber: Integer;
begin
  Result := False;
  if (ATags = nil) or (ATags.Count = 0) then
    Exit;
  if AMessages = nil then
  begin
    lMessages := TStringList.Create;
    try
      Result := RecorderMic140ZeroBalanceTags(AOwner, ARegistry, ATags,
        ADataSources, lMessages);
      if lMessages.Count > 0 then
        MessageDlg('Балансировка нуля', lMessages.Text, mtInformation, [mbOK], 0);
    finally
      lMessages.Free;
    end;
    Exit;
  end;

  lSourceId := TRecorderTag(ATags[0]).SourceId;
  for I := 1 to ATags.Count - 1 do
    if not SameText(TRecorderTag(ATags[I]).SourceId, lSourceId) then
    begin
      AMessages.Add('Все теги должны принадлежать одному источнику MIC-140');
      Exit;
    end;
  if not TryParseRecorderMic140SourceId(lSourceId, lHost, lPort) then
  begin
    AMessages.Add('Источник не является MIC-140');
    Exit;
  end;

  SetLength(lChannelNumbers, 0);
  lFreq := MIC140DefaultPollFrequencyHz;
  for I := 0 to ATags.Count - 1 do
  begin
    lTag := TRecorderTag(ATags[I]);
    if ParseMic140TemperatureChannelIndex(lTag.Address, lTempIndex) then
    begin
      AMessages.Add(Format('%s: балансировка недоступна для T-канала', [lTag.Name]));
      Continue;
    end;
    if not ParseMic140ChannelNumber(lTag.Address, lChannelNumber) then
    begin
      AMessages.Add(Format('%s: не удалось определить номер канала', [lTag.Name]));
      Continue;
    end;
    if lTag.PollFrequencyHz > 0 then
      lFreq := lTag.PollFrequencyHz;
    for J := 0 to High(lChannelNumbers) do
      if lChannelNumbers[J] = lChannelNumber then
        Break;
    if J > High(lChannelNumbers) then
    begin
      SetLength(lChannelNumbers, Length(lChannelNumbers) + 1);
      lChannelNumbers[High(lChannelNumbers)] := lChannelNumber;
    end;
  end;
  if Length(lChannelNumbers) = 0 then
    Exit;

  lWasRunning := (ADataSources <> nil) and ADataSources.Running;
  if lWasRunning then
    ADataSources.StopAll;
  if AOwner <> nil then
    Screen.Cursor := crHourGlass;
  lDev := CreateMic140Device('service-balance', lHost, lPort,
    MIC140DefaultChannelCount, lFreq, 200);
  try
    if not lDev.RunServiceZeroBalance(lChannelNumbers, lFreq, lMeans,
      lErrorMessage) then
    begin
      if lErrorMessage <> '' then
        AMessages.Add(lErrorMessage)
      else
        AMessages.Add('Служебная балансировка MIC-140 не выполнена');
      Exit;
    end;
    AMessages.Clear;
    for I := 0 to ATags.Count - 1 do
    begin
      lTag := TRecorderTag(ATags[I]);
      if not ParseMic140ChannelNumber(lTag.Address, lChannelNumber) then
        Continue;
      for J := 0 to High(lChannelNumbers) do
        if lChannelNumbers[J] = lChannelNumber then
        begin
          lTag.Mic140SoftBalance := lMeans[J];
          AMessages.Add(Format('%s: смещение нуля %.3f', [lTag.Name, lMeans[J]]));
          Result := True;
          Break;
        end;
    end;
  finally
    lDev := nil;
    if AOwner <> nil then
      Screen.Cursor := crDefault;
    if lWasRunning and (ADataSources <> nil) then
      ADataSources.StartAll;
  end;
end;

procedure TRecorderMic140DataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lChannel: TRecorderDeviceChannel;
  lChannels: TRecorderDeviceChannelArray;
  lTag: TRecorderTag;
  lTagName: string;
begin
  lTag := ARegistry.FindByName(fStatusTagName);
  if lTag = nil then
    lTag := ARegistry.CreateTag(fStatusTagName, 4096);
  lTag.Address := 'diagnostics.status';
  lTag.UnitName := '';
  lTag.ModuleType := 'MIC-140 diagnostics';
  lTag.PollFrequencyHz := 1.0;
  lTag.SourceId := SourceId;
  lTag.Description := 'MIC-140 connection status: not checked';
  lTag.TextValue := 'not checked';

  lTag := ARegistry.FindByName(fBlockCountTagName);
  if lTag = nil then
    lTag := ARegistry.CreateTag(fBlockCountTagName, 4096);
  lTag.Address := 'diagnostics.blocks';
  lTag.UnitName := 'blocks';
  lTag.ModuleType := 'MIC-140 diagnostics';
  lTag.PollFrequencyHz := 1.0;
  lTag.SourceId := SourceId;
  lTag.Description := 'MIC-140 successfully received scan blocks';
  lTag.TextValue := '0';

  for I := 0 to fTemperatureTagNames.Count - 1 do
  begin
    if not TemperatureChannelSelected(I + 1) then
      Continue;

    lTag := FindTagBySourceAddress(ARegistry, fTemperatureTagNames[I]);
    if lTag = nil then
      lTag := ARegistry.FindByName(fTemperatureTagNames[I]);
    if (lTag = nil) and (fDeviceSerial > 0) then
      lTag := ARegistry.FindByName(
        RecorderMic140TemperatureDisplayName(fDeviceSerial, I + 1));
    if lTag = nil then
      lTag := ARegistry.CreateTag(fTemperatureTagNames[I], 4096);
    lTag.Address := fTemperatureTagNames[I];
    lTag.UnitName := 'code';
    lTag.ModuleType := 'MIC-140';
    lTag.PollFrequencyHz := fPollFrequencyHz;
    lTag.SourceId := SourceId;
    lTag.Description := Format('MIC-140 temperature channel T%d', [I + 1]);
    lTag.TextValue := '-';
  end;

  lChannels := fDevice.GetChannels;
  fChannelTagNames.Clear;
  for I := 0 to High(lChannels) do
  begin
    fChannelTagNames.Add('');
    lChannel := lChannels[I];
    if not lChannel.Enabled then
      Continue;
    if (fTagNames.Count > 0) and (fTagNames.IndexOf(lChannel.Name) < 0) and
      (fTagNames.IndexOf(lChannel.Address) < 0) then
      Continue;

    lTagName := lChannel.Name;
    lTag := FindTagBySourceAddress(ARegistry, lChannel.Address);
    if lTag <> nil then
      lTagName := lTag.Name
    else
      lTag := ARegistry.FindByName(lTagName);
    if lTag = nil then
      lTag := ARegistry.CreateTag(lTagName, Ceil(Max(4096, lChannel.PollFrequencyHz)));
    lTag.Address := lChannel.Address;
    // A source can contain both millivolt and thermocouple channels. Preserve
    // the mode chosen in the per-channel dialog instead of imposing the mode
    // inferred from the first source tag on every channel.
    if Trim(lTag.SourceValueMode) = '' then
      lTag.SourceValueMode := RecorderMic140OutputModeToConfigName(fOutputMode);
    if Trim(lTag.UnitName) = '' then
      lTag.UnitName := RecorderMic140OutputModeUnitName(fOutputMode);
    lTag.ModuleType := lChannel.ModuleType;
    lTag.PollFrequencyHz := lChannel.PollFrequencyHz;
    lTag.SourceId := SourceId;
    lTag.Description := Format('MIC-140 channel %s; freq=%s Hz; mode=%s',
      [lChannel.Address, FormatFloat('0.######', lChannel.PollFrequencyHz),
       lTag.SourceValueMode]);
    fChannelTagNames[I] := lTag.Name;
  end;
end;

procedure TRecorderMic140DataSource.PrepareHardware;
var
  I: Integer;
  lChannelNumber: Integer;
  lCalibrationName: string;
  lFirmware: TRecorderMic140LegacyFirmware;
  lSettings: TRecorderMic140ChannelSettings;
  lTag: TRecorderTag;
begin
  if fHardwarePrepared or fHardwarePrepareAttempted then
    Exit;
  fHardwarePrepareAttempted := True;
  PublishDiagnostics(CMic140StatusDisconnected, 'connecting', True);
  fDevice.Connect;
  if fDevice.State = rdsDisconnected then
  begin
    PublishDiagnostics(CMic140StatusError, 'connection failed', True);
    Exit;
  end;
  PublishDiagnostics(CMic140StatusConnected, 'connected', True);
  if fMic <> nil then
  begin
    fDeviceSerial := fMic.GetDeviceSerial;
    if fMic.GetLegacyFirmware(lFirmware) then
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 firmware devSerNo=%u ccSerNo=%u ccType=%u -> hardware calibr serial=%d',
        [SourceId, lFirmware.DevSerNo, lFirmware.CCSerNo, lFirmware.CCType,
         fDeviceSerial]))
    else
    if fDeviceSerial > 0 then
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 hardware calibr serial=%d',
        [SourceId, fDeviceSerial]));
    if fDeviceSerial > 0 then
    begin
      for I := 0 to Registry.TagCount - 1 do
      begin
        lTag := Registry.Tags[I];
        if SameText(lTag.SourceId, SourceId) and
          (Pos('diagnostics.', LowerCase(lTag.Address)) <> 1) then
          lTag.Mic140DeviceSerial := fDeviceSerial;
      end;
    end;
    RebuildTemperatureTagNames;
    if (fDeviceSerial > 0) and (Registry <> nil) then
    begin
      RecorderMic140ApplyHardwareCalibrations(Registry, SourceId, fDeviceSerial);
      RecorderMic140ApplyTInHardwareCalibrations(Registry, SourceId,
        fDeviceSerial, CMic140Mic140SubRev1, fTemperatureTagNames);
    end;
  end;
  if Registry <> nil then
    for I := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[I];
      if not SameText(lTag.SourceId, SourceId) or
        (not ParseMic140ChannelNumber(lTag.Address, lChannelNumber)) then
        Continue;
      RecorderMic140InitChannelSettings(lSettings, lChannelNumber - 1,
        CMic140Mic140SubRev1);
      RecorderMic140RestoreChannelSettingsFromTag(Registry, lTag, lSettings);
      lTag.Mic140CjcChannel := RecorderMic140ChannelCjcNumber(lSettings,
        lChannelNumber - 1, CMic140Mic140SubRev1);
      if not RecorderMic140ChannelUsesTemperature(lSettings) then
        Continue;
      if not lTag.ChannelCalibrationEnabled then
        Continue;
      if not lTag.Mic140ThermoCompensationEnabled then
        lTag.Mic140ThermoCompensationEnabled := True;
      lCalibrationName := RecorderMic140EnsureThermocoupleCalibration(Registry,
        lSettings);
      if lCalibrationName = '' then
      begin
        Mic140LogWarning(Format(
          '[DataSource:%s] MIC-140 thermocouple curve was not loaded: tag=%s SDB=%s csv=%s',
          [SourceId, lTag.Name, lSettings.ThermocoupleScalePath,
           RecorderMeraThermocoupleCsvPath(lSettings.ThermocoupleScalePath)]));
        Continue;
      end;
      if lTag.CalibrationNames.IndexOf(lCalibrationName) < 0 then
        lTag.CalibrationNames.Add(lCalibrationName);
      lTag.Mic140ThermocoupleScalePath := lSettings.ThermocoupleScalePath;
      lTag.SourceValueMode := RecorderMic140OutputModeToConfigName(momTemperatureC);
      lTag.UnitName := RecorderMic140OutputModeUnitName(momTemperatureC);
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 thermocouple curve ready: tag=%s SDB=%s',
        [SourceId, lTag.Name, lSettings.ThermocoupleScalePath]));
    end;
  fDevice.ProgramDevice;
  if fDevice.State = rdsProgrammed then
    PublishDiagnostics(CMic140StatusProgrammed, 'programmed', True)
  else
  if fDevice.State <> rdsStarted then
  begin
    PublishDiagnostics(CMic140StatusError, 'programming failed', True);
    Exit;
  end;
  fDevice.Start;
  fHardwarePrepared := fDevice.State = rdsStarted;
  if not fHardwarePrepared then
  begin
    PublishDiagnostics(CMic140StatusError, 'start failed', True);
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 source is not started; preview will continue without device samples',
      [SourceId]));
    if fDevice <> nil then
    begin
      try
        fDevice.Stop;
      except
      end;
      try
        fDevice.Disconnect;
      except
      end;
    end;
  end;
end;

procedure TRecorderMic140DataSource.SyncScanConfig;
var
  lChannels: Integer;
begin
  lChannels := MIC140DefaultChannelCount;
  if fMic <> nil then
    lChannels := fMic.ChannelCount;
  if fScanConfig = nil then
    fScanConfig := TRecorderMic140ScanConfig.Create(lChannels, fPollFrequencyHz, UpdateTimeMs)
  else
  begin
    fScanConfig.ChannelCount := lChannels;
    fScanConfig.PollFrequencyHz := fPollFrequencyHz;
    fScanConfig.UpdateTimeMs := UpdateTimeMs;
  end;
  if fAcquireTiming <> nil then
    fAcquireTiming.Apply(fPollFrequencyHz, UpdateTimeMs);
end;

procedure TRecorderMic140DataSource.EnsureProtocolDriver;
begin
  SyncScanConfig;
  if fProtocolDriver <> nil then
    Exit;
  if (fDevice = nil) or (fMic = nil) then
    Exit;
  fProtocolDriver := TRecorderMic140LegacyScanDriver.Create(
    fScanConfig, fDevice, fMic);
end;

procedure TRecorderMic140DataSource.FreeProtocolDriver;
begin
  FreeAndNil(fProtocolDriver);
end;

procedure TRecorderMic140DataSource.Start;
begin
  inherited Start;
  SyncScanConfig;
  fGoodBlockCount := 0;
  fReadFailCount := 0;
  fLastChannelAdcValid := False;
  SetLength(fLastChannelAdcSamples, 0);
  fCjcActiveLogWritten := False;
  fCjcCorrectLogWritten := False;
  fTemperatureModeWarningLogged := False;
  fLastPublishedNumBuffValid := False;
  fPublishedNumBuffGapCount := 0;
  fPublishedCorruptCount := 0;
  if (not fHardwarePrepared) and (fDevice <> nil) and (fDevice.State <> rdsStarted) then
    Exit;
  if fDevice.State = rdsStarted then
  begin
    fStreamFsm.SetPhase(mspAcquiring);
    EnsureBlockPublishThread;
    EnsureLegacyReadThread;
    PublishDiagnostics(CMic140StatusStarted, 'started', True);
  end;
end;

procedure TRecorderMic140DataSource.RequestStop;
begin
  inherited RequestStop;
  if fStreamFsm <> nil then
    fStreamFsm.SetPhase(mspStopping);
  if fMic <> nil then
    fMic.RequestStopAcquisition;
end;

procedure TRecorderMic140DataSource.Stop;
var
  lBufferDropped: Int64;
begin
  if fStreamFsm <> nil then
    fStreamFsm.SetPhase(mspStopping);
  StopLegacyReadThread;
  FreeProtocolDriver;
  StopBlockPublishThread;
  if (fMic <> nil) and
     ((fGoodBlockCount > 0) or (fMic.LegacyStreamReadCount > 0)) then
  begin
    if fRawBuffer <> nil then
      lBufferDropped := fRawBuffer.DroppedCount
    else if fRawRing <> nil then
      lBufferDropped := fRawRing.DroppedCount
    else
      lBufferDropped := 0;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 stream stop: published=%d read=%d readGaps=%d dupRead=%d corruptRead=%d publishGaps=%d corruptPublish=%d bufferDropped=%d mdpResync=%d',
      [SourceId, fGoodBlockCount, fMic.LegacyStreamReadCount,
       fMic.LegacyNumBuffGapCount, fMic.LegacyDuplicateNumBuffCount,
       fMic.LegacyCorruptReadCount, fPublishedNumBuffGapCount,
       fPublishedCorruptCount, lBufferDropped, fMic.LegacyMdpResyncByteCount]));
  end;
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
    except
      on E: Exception do
        PublishDiagnostics(CMic140StatusError, 'device stop failed: ' + E.Message, True);
    end;
  end;
  inherited Stop;
  fHardwarePrepared := False;
  if fStreamFsm <> nil then
    fStreamFsm.SetPhase(mspOffline);
  fHardwarePrepareAttempted := False;
  if fDevice <> nil then
  begin
    try
      fDevice.Disconnect;
      PublishDiagnostics(CMic140StatusDisconnected, 'stopped', True);
    except
      on E: Exception do
      begin
        PublishDiagnostics(CMic140StatusError, 'stop failed: ' + E.Message, True);
      end;
    end;
  end;
end;

type
  TMic140BlockPublishThread = class(TThread)
  private
    fOwner: TRecorderMic140DataSource;
    fWakeEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderMic140DataSource);
    destructor Destroy; override;
    procedure SignalWork;
    procedure Flush;
    procedure RequestStop;
  end;

  TMic140LegacyReadThread = class(TThread)
  private
    fOwner: TRecorderMic140DataSource;
    fWakeEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderMic140DataSource);
    destructor Destroy; override;
    procedure RequestStop;
  end;

constructor TMic140BlockPublishThread.Create(AOwner: TRecorderMic140DataSource);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fWakeEvent := TEvent.Create(nil, False, False, '');
end;

destructor TMic140BlockPublishThread.Destroy;
begin
  fWakeEvent.Free;
  inherited Destroy;
end;

procedure TMic140BlockPublishThread.SignalWork;
begin
  fWakeEvent.SetEvent;
end;

procedure TMic140BlockPublishThread.Flush;
var
  lSpin: Integer;
begin
  lSpin := 0;
  while fOwner.RawHasPending do
  begin
    if lSpin >= 400 then
      Break;
    fWakeEvent.WaitFor(5);
    Inc(lSpin);
  end;
end;

procedure TMic140BlockPublishThread.RequestStop;
begin
  Terminate;
  fWakeEvent.SetEvent;
end;

procedure TMic140BlockPublishThread.Execute;
var
  lRaw: TMic140LegacyRawBlock;
begin
  while not Terminated do
  begin
    if not fOwner.fStreamFsm.ShouldPublish then
    begin
      fWakeEvent.WaitFor(fOwner.fStreamFsm.IdleWaitMs);
      Continue;
    end;
    if not fOwner.RawTryTake(lRaw) then
    begin
      fWakeEvent.WaitFor(fOwner.fStreamFsm.PublishBlockWaitMs);
      Continue;
    end;
    if not Terminated then
      fOwner.ProcessLegacyRawBlock(lRaw);
  end;

  while fOwner.RawTryTake(lRaw) do
    fOwner.ProcessLegacyRawBlock(lRaw);
end;

{ TMic140LegacyReadThread }

constructor TMic140LegacyReadThread.Create(AOwner: TRecorderMic140DataSource);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fWakeEvent := TEvent.Create(nil, False, False, '');
end;

destructor TMic140LegacyReadThread.Destroy;
begin
  fWakeEvent.Free;
  inherited Destroy;
end;

procedure TMic140LegacyReadThread.RequestStop;
begin
  Terminate;
  fWakeEvent.SetEvent;
end;

procedure TMic140LegacyReadThread.Execute;
var
  lConsecutiveFails: Integer;
  lRaw: TMic140LegacyRawBlock;
  lTimeoutMs: Cardinal;
begin
  lConsecutiveFails := 0;
  while not Terminated do
  begin
    if Terminated or not fOwner.fStreamFsm.ShouldRead or (fOwner.fDevice = nil) or
       (fOwner.fDevice.State <> rdsStarted) then
    begin
      fWakeEvent.WaitFor(fOwner.fStreamFsm.IdleWaitMs);
      Continue;
    end;
    fWakeEvent.WaitFor(fOwner.fStreamFsm.AcquirePacingMs);
    if Terminated then
      Break;
    lTimeoutMs := fOwner.fScanConfig.MainScanReadTimeoutMs;
    try
      if fOwner.fMic <> nil then
      begin
        if fOwner.fMic.ReadLegacyRawBlock(lTimeoutMs, lRaw) then
        begin
          lConsecutiveFails := 0;
          fOwner.EnqueueLegacyRawBlock(lRaw);
        end
        else
          Inc(lConsecutiveFails);
        while not Terminated and fOwner.fMic.ReadLegacyRawBlock(0, lRaw) do
          fOwner.EnqueueLegacyRawBlock(lRaw);
      end
      else if (fOwner.fProtocolDriver <> nil) and
         fOwner.fProtocolDriver.ReadRawBlock(lRaw) then
      begin
        lConsecutiveFails := 0;
        fOwner.EnqueueLegacyRawBlock(lRaw);
      end
      else
        Inc(lConsecutiveFails);
      if lConsecutiveFails > 0 then
      begin
        if (lConsecutiveFails >= fOwner.fScanConfig.ReadStallRestartAfter) and
          (
            ((fOwner.fProtocolDriver <> nil) and
             (fOwner.fProtocolDriver.StreamReadCount > 0) and
             fOwner.fProtocolDriver.TryRestartAfterReadStall) or
            ((fOwner.fMic <> nil) and
             (fOwner.fMic.LegacyStreamReadCount > 0) and
             fOwner.fMic.LegacyTryRestartStreamAfterReadStall)
          ) then
          lConsecutiveFails := 0;
        if lConsecutiveFails = fOwner.fScanConfig.ReadTimeoutWarnAfter then
          Mic140LogWarning(Format(
            '[DataSource:%s] MIC-140 read thread: %d consecutive timeouts (%d ms)',
            [fOwner.SourceId, lConsecutiveFails, lTimeoutMs]));
      end;
    except
      on E: Exception do
      begin
        Mic140LogWarning(Format('[DataSource:%s] MIC-140 read thread failed: %s: %s',
          [fOwner.SourceId, E.ClassName, E.Message]));
        fOwner.fStreamFsm.SetPhase(mspError, E.Message);
        fOwner.PublishDiagnostics(CMic140StatusError,
          'read exception: ' + E.Message, True);
        try
          fOwner.fDevice.Stop;
        except
        end;
        Terminate;
      end;
    end;
  end;
end;

procedure TRecorderMic140DataSource.EnsureBlockPublishThread;
var
  lThread: TMic140BlockPublishThread;
begin
  if fBlockPublishThread <> nil then
    Exit;
  lThread := TMic140BlockPublishThread.Create(Self);
  fBlockPublishThread := lThread;
  lThread.Start;
end;

procedure TRecorderMic140DataSource.StopBlockPublishThread;
var
  lThread: TMic140BlockPublishThread;
begin
  if fBlockPublishThread = nil then
    Exit;
  lThread := TMic140BlockPublishThread(fBlockPublishThread);
  lThread.RequestStop;
  lThread.Flush;
  lThread.WaitFor;
  lThread.Free;
  fBlockPublishThread := nil;
end;

procedure TRecorderMic140DataSource.EnsureLegacyReadThread;
var
  lThread: TMic140LegacyReadThread;
begin
  if fLegacyReadThread <> nil then
    Exit;
  EnsureProtocolDriver;
  lThread := TMic140LegacyReadThread.Create(Self);
  fLegacyReadThread := lThread;
  lThread.Start;
end;

procedure TRecorderMic140DataSource.StopLegacyReadThread;
var
  lThread: TMic140LegacyReadThread;
begin
  if fLegacyReadThread = nil then
    Exit;
  lThread := TMic140LegacyReadThread(fLegacyReadThread);
  lThread.RequestStop;
  lThread.WaitFor;
  lThread.Free;
  fLegacyReadThread := nil;
end;

function TRecorderMic140DataSource.RawHasPending: Boolean;
begin
  if fRawRing <> nil then
    Result := fRawRing.PendingCount > 0
  else if fRawBuffer <> nil then
    Result := fRawBuffer.HasPending
  else
    Result := False;
end;

function TRecorderMic140DataSource.RawTryTake(out ARaw: TMic140LegacyRawBlock): Boolean;
begin
  if fRawRing <> nil then
    Result := fRawRing.TryDequeue(ARaw)
  else if fRawBuffer <> nil then
    Result := fRawBuffer.TryTake(ARaw)
  else
    Result := False;
end;

procedure TRecorderMic140DataSource.RawEnqueue(const ARaw: TMic140LegacyRawBlock;
  out ADropped: Boolean);
begin
  ADropped := False;
  if fRawRing <> nil then
    fRawRing.Enqueue(ARaw, ADropped)
  else if fRawBuffer <> nil then
    ADropped := fRawBuffer.Publish(ARaw);
end;

function TRecorderMic140DataSource.RawPendingLag: Int64;
begin
  if fRawRing <> nil then
    Result := fRawRing.PendingCount
  else if fRawBuffer <> nil then
    Result := fRawBuffer.PendingLag
  else
    Result := 0;
end;

function TRecorderMic140DataSource.RawDroppedCount: Int64;
begin
  if fRawRing <> nil then
    Result := fRawRing.DroppedCount
  else if fRawBuffer <> nil then
    Result := fRawBuffer.DroppedCount
  else
    Result := 0;
end;

procedure TRecorderMic140DataSource.EnqueueLegacyRawBlock(
  const ARaw: TMic140LegacyRawBlock);
var
  lDropped: Boolean;
  lNow: QWord;
  lThread: TMic140BlockPublishThread;
begin
  if (fRawRing = nil) and (fRawBuffer = nil) then
  begin
    ProcessLegacyRawBlock(ARaw);
    Exit;
  end;
  RawEnqueue(ARaw, lDropped);
  lNow := GetTickCount64;
  if lDropped and (lNow - fLastRingOverloadLogTick >= CMic140RawBufferDropLogIntervalMs) then
  begin
    fLastRingOverloadLogTick := lNow;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 raw buffer overflow: readSerial=%d num_buff=%d lag=%d',
      [SourceId, ARaw.ReadSerial, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       RawPendingLag]));
  end;
  if fBlockPublishThread <> nil then
  begin
    lThread := TMic140BlockPublishThread(fBlockPublishThread);
    lThread.SignalWork;
  end
  else
    ProcessLegacyRawBlock(ARaw);
end;

function TRecorderMic140DataSource.TryEnqueueGoodLegacyRawBlock(
  const ARaw: TMic140LegacyRawBlock): Boolean;
begin
  if (fMic = nil) or
     Mic140LegacyRawBlockLooksCorrupt(ARaw, fMic.ChannelCount) then
    Exit(False);
  EnqueueLegacyRawBlock(ARaw);
  Result := True;
end;

procedure TRecorderMic140DataSource.CheckPublishedNumBuff(
  const ARaw: TMic140LegacyRawBlock);
var
  lCurNumBuff: Word;
  lExpected: Word;
  lMissed: Integer;
begin
  if (fMic <> nil) and fMic.LegacyConsumeStreamSequenceReset then
    fLastPublishedNumBuffValid := False;
  lCurNumBuff := ARaw.Header[CMic140LegacyBiosNumBuffIdx];
  if fLastPublishedNumBuffValid then
  begin
    lExpected := Word((Integer(fLastPublishedNumBuff) + 1) and $FFFF);
    if lCurNumBuff <> lExpected then
    begin
      lMissed := Integer(lCurNumBuff) - Integer(lExpected);
      if lMissed < 0 then
        Inc(lMissed, 65536);
      if lMissed >= CMic140LegacyNumBuffDesyncRestartMissed then
      begin
        Mic140LogWarning(Format(
          '[DataSource:%s] MIC-140 num_buff desync on publish: readSerial=%d prev=%d expected=%d cur=%d missed=%d -> re-baseline',
          [SourceId, ARaw.ReadSerial, fLastPublishedNumBuff, lExpected, lCurNumBuff, lMissed]));
        fLastPublishedNumBuff := lCurNumBuff;
        fLastPublishedNumBuffValid := True;
        Exit;
      end;
      Inc(fPublishedNumBuffGapCount);
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 num_buff gap on publish: readSerial=%d prev=%d expected=%d cur=%d missed=%d publishGaps=%d ring=%d',
        [SourceId, ARaw.ReadSerial, fLastPublishedNumBuff, lExpected, lCurNumBuff,
         lMissed, fPublishedNumBuffGapCount, RawPendingLag]));
    end;
  end;
  fLastPublishedNumBuff := lCurNumBuff;
  fLastPublishedNumBuffValid := True;
end;

procedure TRecorderMic140DataSource.LogMic140StreamSummary(
  const ARaw: TMic140LegacyRawBlock);
begin
  if (fMic = nil) or (fGoodBlockCount = 0) then
    Exit;
  if (fGoodBlockCount <> 1) and
     ((fGoodBlockCount mod CMic140LegacyStreamSummaryInterval) <> 0) then
    Exit;
  Mic140LogWarning(Format(
    '[DataSource:%s] MIC-140 stream: published=%d read=%d num_buff=%d readGaps=%d dupRead=%d corruptRead=%d publishGaps=%d ring=%d mdpResync=%d',
    [SourceId, fGoodBlockCount, fMic.LegacyStreamReadCount,
     ARaw.Header[CMic140LegacyBiosNumBuffIdx],
     fMic.LegacyNumBuffGapCount, fMic.LegacyDuplicateNumBuffCount,
     fMic.LegacyCorruptReadCount, fPublishedNumBuffGapCount,
     RawPendingLag, fMic.LegacyMdpResyncByteCount]));
end;

procedure TRecorderMic140DataSource.ProcessLegacyRawBlock(
  const ARaw: TMic140LegacyRawBlock);
var
  lBlock: TRecorderDeviceSampleBlock;
begin
  CheckPublishedNumBuff(ARaw);
  if (ARaw.ReadSerial > 0) and (ARaw.ReadSerial <= CMic140LegacyScanDetailLogBlocks) then
    RecorderDebugLog(Format('[DataSource:%s] raw block words=%d rs=%d nb=%d',
      [SourceId, ARaw.DataWordCount, ARaw.ReadSerial,
       ARaw.Header[CMic140LegacyBiosNumBuffIdx]]));
  if (fMic = nil) or
     not fMic.LegacyDecommutateRawBlock(ARaw, lBlock) then
    Exit;
  try
    LogMic140StrideMisalignmentIfNeeded(ARaw, lBlock);
    ProcessAndPublishBlock(lBlock);
    LogMic140StreamSummary(ARaw);
  finally
    ClearRecorderDeviceSampleBlock(lBlock);
  end;
end;

procedure TRecorderMic140DataSource.LogMic140StrideMisalignmentIfNeeded(
  const ARaw: TMic140LegacyRawBlock; const ABlock: TRecorderDeviceSampleBlock);
var
  lK: Integer;
  lPosCount: Integer;
  lSatCount: Integer;
  lPreview: string;
  lI: Integer;
begin
  if (fMic = nil) or
    (not Mic140LegacyRawBlockLooksCorrupt(ARaw, fMic.ChannelCount)) then
    Exit;

  Inc(fPublishedCorruptCount);
  lPosCount := 0;
  lSatCount := 0;
  for lI := 0 to ABlock.ChannelCount - 1 do
  begin
    if lI >= Length(ABlock.Values) then
      Continue;
    if Mic140AdcCodeIsSaturated(ABlock.Values[lI][0]) then
      Inc(lSatCount)
    else if ABlock.Values[lI][0] > CMic140MisalignPositiveThreshold then
      Inc(lPosCount);
  end;

  lPreview := '';
  for lK := 0 to Min(ABlock.ChannelCount - 1, 7) do
  begin
    if lK >= Length(ABlock.Values) then
      Break;
    if lK > 0 then
      lPreview := lPreview + ',';
    lPreview := lPreview + IntToStr(Trunc(ABlock.Values[lK][0]));
  end;
  RecorderDebugLog(Format(
    '[DataSource:%s] MIC-140 stride misalignment: publish=%d readSerial=%d num_buff=%d positive=%d sat=%d preview=[%s]',
    [SourceId, fGoodBlockCount + 1, ARaw.ReadSerial,
     ARaw.Header[CMic140LegacyBiosNumBuffIdx], lPosCount, lSatCount, lPreview]));
end;

procedure TRecorderMic140DataSource.ProcessAndPublishBlock(
  const ABlock: TRecorderDeviceSampleBlock);
var
  lChannels: TRecorderDeviceChannelArray;
  lCount: Integer;
  lI: Integer;
  lJ: Integer;
  lTag: TRecorderTag;
  lCjcChannel: Integer;
  lCjcTemperatureC: Double;
  lCjcPipelineActive: Boolean;
  lTTag: TRecorderTag;
  lUseCjc: Boolean;
  lAuxTemperature: TMic140AuxTemperatureBlock;
  lTimes: TRecorderDoubleArray;
  lValues: TRecorderDoubleArray;
  lSum: Double;
  lRaw: Double;
  lPreview: string;
begin
  lChannels := fDevice.GetChannels;
  lCount := Min(ABlock.ChannelCount, Length(lChannels));
  if lCount <= 0 then
    Exit;
  SetLength(fLastRawChannelMeans, lCount);
  for lI := 0 to lCount - 1 do
  begin
    lSum := 0;
    for lJ := 0 to ABlock.SampleCount - 1 do
      lSum := lSum + ABlock.Values[lI][lJ];
    if ABlock.SampleCount > 0 then
      fLastRawChannelMeans[lI] := lSum / ABlock.SampleCount;
  end;
  fLastRawBlockValid := True;
  Inc(fGoodBlockCount);
  fReadFailCount := 0;
  PublishDiagnostics(CMic140StatusStarted, 'started; data ok', False);
  PublishBlockCounter(fGoodBlockCount);
  if (fGoodBlockCount = 1) or ((fGoodBlockCount mod 20) = 0) then
    Mic140LogWarning(Format('[DataSource:%s] MIC-140 block=%d samples=%d stride=%d rate=%.3f Hz',
      [SourceId, fGoodBlockCount, ABlock.SampleCount, ABlock.ChannelCount +
       MIC140TemperatureChannelCount, ABlock.SampleRateHz]));
  if fGoodBlockCount = 1 then
  begin
    lPreview := '';
    for lI := 0 to lCount - 1 do
    begin
      if (lI > 7) and (lI <> 11) and (lI <> 23) then
        Continue;
      if lI >= fChannelTagNames.Count then
        Break;
      lTag := Registry.FindByName(fChannelTagNames[lI]);
      if lTag = nil then
        Continue;
      lRaw := Mic140RawSample(ABlock, lI, 0, lTag);
      if lTag.HardwareCalibrationEnabled then
        lSum := Registry.TransformTagHardwareValue(lTag, lRaw)
      else
        lSum := lRaw;
      if lPreview <> '' then
        lPreview := lPreview + '; ';
      lPreview := lPreview + Format('%s raw=%.0f mV=%.1f',
        [lTag.Name, lRaw, lSum]);
    end;
    if lPreview <> '' then
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 block1 channels: %s',
        [SourceId, lPreview]));
  end
  else if fGoodBlockCount <= CMic140LegacyScanDetailLogBlocks then
  begin
    lPreview := '';
    for lI := 0 to Min(lCount - 1, 3) do
    begin
      if lI >= Length(ABlock.Values) then
        Break;
      if lPreview <> '' then
        lPreview := lPreview + ',';
      lPreview := lPreview + IntToStr(Trunc(ABlock.Values[lI][0]));
    end;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 block%d published d0=[%s]',
      [SourceId, fGoodBlockCount, lPreview]));
  end;

  SetLength(lTimes, ABlock.SampleCount);
  for lJ := 0 to ABlock.SampleCount - 1 do
    lTimes[lJ] := ABlock.FirstTimeSec + (lJ / ABlock.SampleRateHz);

  if fMic <> nil then
    lAuxTemperature := fMic.LastAuxTemperatureBlock
  else
    ClearMic140AuxTemperatureBlock(lAuxTemperature);
  PublishTemperatureBlocks(lAuxTemperature, lTimes);

  SetLength(lValues, ABlock.SampleCount);
  for lI := 0 to lCount - 1 do
  begin
    if ShouldStop then
      Exit;
    if lI >= fChannelTagNames.Count then
      Continue;
    lTag := Registry.FindByName(fChannelTagNames[lI]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;

    if not lTag.HardwareCalibrationEnabled then
    begin
      for lJ := 0 to ABlock.SampleCount - 1 do
        lValues[lJ] := Mic140RawSample(ABlock, lI, lJ, lTag);
      Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount, True);
      Continue;
    end;

    if not lTag.ChannelCalibrationEnabled then
    begin
      for lJ := 0 to ABlock.SampleCount - 1 do
      begin
        lRaw := Mic140RawSample(ABlock, lI, lJ, lTag);
        lValues[lJ] := Registry.TransformTagHardwareValue(lTag, lRaw);
      end;
      Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount, True);
      Continue;
    end;

    lCjcChannel := RecorderMic140TagEffectiveCjcChannel(lTag, lI,
      CMic140Mic140SubRev1);
    lTTag := nil;
    if (lCjcChannel >= 1) and (lCjcChannel <= fTemperatureTagNames.Count) then
    begin
      lTTag := FindTagBySourceAddress(Registry,
        fTemperatureTagNames[lCjcChannel - 1]);
      if lTTag = nil then
        lTTag := Registry.FindByName(fTemperatureTagNames[lCjcChannel - 1]);
    end;
    lUseCjc := lTag.Mic140ThermoCompensationEnabled and
      SameText(lTag.SourceValueMode,
        RecorderMic140OutputModeToConfigName(momTemperatureC));
    if lUseCjc then
      lUseCjc := Mic140TryGetColdJunctionTemperature(Registry, lTTag,
        lAuxTemperature, lCjcChannel, fDeviceSerial, CMic140Mic140SubRev1,
        lCjcTemperatureC);
    if lUseCjc and (not fCjcActiveLogWritten) then
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 CJC active: tag=%s T%d=%.3f degC',
        [SourceId, lTag.Name, lCjcChannel, lCjcTemperatureC]));
      fCjcActiveLogWritten := True;
    end;
    if (not lUseCjc) and lTag.Mic140ThermoCompensationEnabled and
      SameText(lTag.SourceValueMode,
        RecorderMic140OutputModeToConfigName(momTemperatureC)) and
      (not fTemperatureModeWarningLogged) then
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 CJC T%d unavailable (TIn cal missing or junction temp invalid, block tin=%d); channel will use thermocouple GХ without compensation',
        [SourceId, lCjcChannel, lAuxTemperature.ChannelCount]));
      fTemperatureModeWarningLogged := True;
    end;

    lCjcPipelineActive := lUseCjc and
      Mic140TagHasThermocoupleCalibration(Registry, lTag);
    for lJ := 0 to ABlock.SampleCount - 1 do
    begin
      lRaw := Mic140RawSample(ABlock, lI, lJ, lTag);
      if lCjcPipelineActive then
        lValues[lJ] := Mic140TransformThermocoupleChannelSample(Registry, lTag,
          lI, lRaw, lCjcTemperatureC)
      else
        lValues[lJ] := lRaw;
    end;
    if lUseCjc and (not lCjcPipelineActive) and (not fCjcCorrectLogWritten) then
    begin
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 CJC correction skipped for tag=%s: thermocouple GХ is missing or cannot be inverted',
        [SourceId, lTag.Name]));
      fCjcCorrectLogWritten := True;
    end;
    Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount,
      lCjcPipelineActive);
  end;

  if Registry = nil then
    Exit;
  for lI := 0 to lCount - 1 do
  begin
    if lI >= fChannelTagNames.Count then
      Continue;
    lTag := Registry.FindByName(fChannelTagNames[lI]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;
    Registry.PublishBlockNotifications(lTag.Name);
  end;
end;

procedure TRecorderMic140DataSource.DoTick;
var
  lRaw: TMic140LegacyRawBlock;

  procedure StopDeviceIfRequested;
  begin
    if not ShouldStop then
      Exit;
    if fDevice = nil then
      Exit;
    try
      fDevice.Stop;
    except
      on E: Exception do
        Mic140LogWarning(Format('[DataSource:%s] MIC-140 stop on TryStop failed: %s',
          [SourceId, E.Message]));
    end;
  end;

begin
  if ShouldStop then
  begin
    StopDeviceIfRequested;
    Exit;
  end;
  if (fDevice = nil) or (fDevice.State <> rdsStarted) then
    Exit;
  if fLegacyReadThread <> nil then
  begin
    if ShouldStop then
      StopDeviceIfRequested;
    Exit;
  end;
  try
    if not fMic.ReadLegacyRawBlock(
      fScanConfig.ReadTimeoutMs, lRaw) then
    begin
      Inc(fReadFailCount);
      if fReadFailCount = 1 then
        Mic140LogWarning(Format(
          '[DataSource:%s] MIC-140 read timeout after %d published blocks (read=%d mdpResync=%d)',
          [SourceId, fGoodBlockCount, fMic.LegacyStreamReadCount,
           fMic.LegacyMdpResyncByteCount]));
      if fReadFailCount = CMic140NoDataFailThreshold then
        PublishDiagnostics(CMic140StatusError, 'no scan data', True);
      StopDeviceIfRequested;
      Exit;
    end;
    fReadFailCount := 0;
    if ShouldStop then
    begin
      StopDeviceIfRequested;
      Exit;
    end;
    EnqueueLegacyRawBlock(lRaw);
    StopDeviceIfRequested;
  except
    on E: Exception do
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 read failed: %s: %s',
        [SourceId, E.ClassName, E.Message]));
      PublishDiagnostics(CMic140StatusError, 'read exception: ' + E.Message, True);
      try
        fDevice.Stop;
      except
      end;
    end;
  end;
end;

end.
