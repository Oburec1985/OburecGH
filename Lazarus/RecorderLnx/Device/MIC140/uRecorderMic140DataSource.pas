unit uRecorderMic140DataSource;

{
  MIC-140 core data source (clean v2 stack).

  The source uses the same RecorderLnx data-source contract as virtual/MERA
  playback sources. Hardware access goes through IMic140Device
  (uRecorderMic140DeviceApi / uRecorderMic140Device / uRecorderMic140Factory):
  Connect / InitializeDevice / ConfigureDevice / Start / Stop / Disconnect /
  ReadBlock. There is no separate raw-block acquisition thread here anymore -
  ReadBlock already returns a decommutated TRecorderDeviceSampleBlock.
  Parsing helpers live in Device/MIC140/uRecorderMic140Utils (2026-06).
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderDataSources, uRecorderDeviceInterfaces,
  uRecorderMic140Utils, uRecorderMic140StreamTypes,
  uRecorderMic140DeviceApi,
  uRecorderTags;

const
  MIC140DefaultDiscoverySubnet = '192.168.14.';
  CMic140Mic140SubRev1 = 1;
  { Re-exported from StreamTypes for legacy callers. }
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;
  CMic140Range100mV = 0;
  CMic140RangeCount = 3;

type
  TRecorderMic140DataSource = class(TRecorderDataSourceBase, IRecorderZeroBalanceSupport)
  private
    fHardwarePrepared: Boolean;
    fHardwarePrepareAttempted: Boolean;
    { Set once ConfigureDevice succeeds; PrepareHardware programs the device
      only once per Connect/Disconnect cycle (lifecycle-codex.md). }
    fConfigured: Boolean;
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
    fPublishedCorruptCount: Integer;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    function TemperatureChannelSelected(AIndex: Integer): Boolean;
    function ChannelIndexForTag(ATag: TRecorderTag): Integer;
    function Mic140RawSample(const ABlock: TRecorderDeviceSampleBlock;
      AChannelIndex, ASampleIndex: Integer; ATag: TRecorderTag): Double;
    procedure RebuildTemperatureTagNames;
    procedure PublishDiagnostics(AStatusCode: Integer; const AStatusText: string;
      AForce: Boolean = False);
    procedure PublishBlockCounter(ABlockCount: Int64);
    procedure PublishTemperatureBlocks(const AAux: TMic140AuxTemperatureBlock;
      const ATimes: TRecorderDoubleArray);
    function Mic140PublishedCodeInRecorderRange(AChannelIndex: Integer;
      AValue: Double): Boolean;
    procedure CheckPublishedTinCodes(const AAux: TMic140AuxTemperatureBlock);
    procedure CheckPublishedRecorderCodes(const ABlock: TRecorderDeviceSampleBlock);
    procedure ProcessAndPublishBlock(const ABlock: TRecorderDeviceSampleBlock);
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

function RecorderMic140IsSourceLinkOk(const ASourceId: string): Boolean;
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
function RecorderMic140TagEffectiveCjcChannel(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; AChannelIndex, ADevSubRev: Integer): Integer;
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
  Math, StrUtils, Controls, Dialogs, Forms,
  uRecorderMeraPaths, uRecorderMeraSdbThermocouples, uRecorderSdbStore,
  uRecorderMic140LegacyConstants, uRecorderMic140LegacyTiming,
  uRecorderMic140Thermocouple, uRecorderMic140StreamHelpers,
  uRecorderMic140DeviceConfig, uRecorderMic140Calibration,
  uRecorderMic140Protocol, uRecorderMic140Factory, uRecorderMic140Diag,
  uRecorderHardwareLiveDevices, uRecorderHardwareTree;

const
  CMic140StatusDisconnected = 0;
  CMic140StatusConnected = 1;
  CMic140StatusProgrammed = 2;
  CMic140StatusStarted = 3;
  CMic140StatusError = -1;
  CMic140ReadTimeoutMinMs = 1500;
  CMic140NoDataFailThreshold = 10;

function RecorderMic140IsSourceLinkOk(const ASourceId: string): Boolean;
var
  lHost: string;
  lPort: Word;
begin
  { Live session first (no new TCP), TCP probe only as a fallback - mirrors
    RecorderMic185IsSourceLinkOk. }
  if RecorderHardwareIsSourceLinkOk(ASourceId) then
    Exit(True);
  if TryParseRecorderMic140SourceId(ASourceId, lHost, lPort) then
    Result := RecorderMic140TcpProbe(lHost, lPort, 1000)
  else
    Result := False;
end;

function RecorderMic140HardwareLinkProbe(const ASourceId: string): Boolean;
begin
  Result := RecorderMic140IsSourceLinkOk(ASourceId);
end;

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
  { 2. По T_ХТС найти мВ на ГХ термопары и прибавить к мВ канала. }
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
  lCli: TMic140v2Tcp;
  lErrorMessage: string;
  lFirmware: TMic140v2Firmware;
begin
  Result := False;
  ADeviceSerial := 0;
  lCli := TMic140v2Tcp.Create(AHost, APort, 5000);
  try
    try
      lCli.Connect;
    except
      Exit;
    end;
    if lCli.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ADeviceSerial := Mic140v2DeviceSerialFromFirmware(lFirmware);
      Result := ADeviceSerial > 0;
    end;
  finally
    lCli.Free;
  end;
end;

function RecorderMic140QueryHardwareCalibrSerial(const AHost: string; APort: Word;
  out ACalibrSerial: Integer): Boolean;
var
  lCli: TMic140v2Tcp;
  lErrorMessage: string;
  lFirmware: TMic140v2Firmware;
begin
  Result := False;
  ACalibrSerial := 0;
  lCli := TMic140v2Tcp.Create(AHost, APort, 5000);
  try
    try
      lCli.Connect;
    except
      Exit;
    end;
    if lCli.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ACalibrSerial := Mic140v2HardwareCalibrSerial(lFirmware);
      Result := ACalibrSerial > 0;
    end;
  finally
    lCli.Free;
  end;
end;

function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;
  out ADeviceSerial: Integer; out AVersionText: string;
  out ADevSubRev: Integer): Boolean;
var
  lCli: TMic140v2Tcp;
  lErrorMessage: string;
  lFirmware: TMic140v2Firmware;
begin
  Result := False;
  ADeviceSerial := 0;
  AVersionText := '';
  ADevSubRev := 0;
  lCli := TMic140v2Tcp.Create(AHost, APort, 5000);
  try
    try
      lCli.Connect;
    except
      Exit;
    end;
    if lCli.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ADeviceSerial := Mic140v2DisplaySerialFromFirmware(lFirmware, AHost);
      AVersionText := Mic140v2FirmwareVersionText(lFirmware);
      ADevSubRev := Mic140v2DevSubRevFromFirmware(lFirmware);
      Result := (ADeviceSerial > 0) or (AVersionText <> '');
    end;
  finally
    lCli.Free;
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
  ASettings.CommutIndex := CMic140ChannelCommutIn;
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

function RecorderMic140TagEffectiveCjcChannel(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; AChannelIndex, ADevSubRev: Integer): Integer;
var
  lSettings: TRecorderMic140ChannelSettings;
  lChannelNumber: Integer;
begin
  if (ATag <> nil) and RecorderMic140TryGetChannelSettings(ARegistry, ATag,
    lChannelNumber, lSettings) then
    Exit(RecorderMic140ChannelCjcNumber(lSettings, AChannelIndex, ADevSubRev));
  RecorderMic140InitChannelSettings(lSettings, AChannelIndex, ADevSubRev);
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
  fHardwarePrepared := False;
  fHardwarePrepareAttempted := False;
  fConfigured := False;
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
  Stop;
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

function TRecorderMic140DataSource.Mic140RawSample(
  const ABlock: TRecorderDeviceSampleBlock; AChannelIndex, ASampleIndex: Integer;
  ATag: TRecorderTag): Double;
var
  lSettings: TRecorderMic140ChannelSettings;
  lChannelNumber: Integer;
begin
  Result := ABlock.Values[AChannelIndex][ASampleIndex];
  if (ATag <> nil) and RecorderMic140TryGetChannelSettings(Registry, ATag,
    lChannelNumber, lSettings) and (lSettings.SoftBalance <> 0) then
    Result := Result - lSettings.SoftBalance;
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
          RecorderMic140SetChannelSoftBalance(ARegistry, lTag, lMeans[J]);
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
  lConfig: TRecorderMic140SourceConfig;
  lTag: TRecorderTag;
  lTestError: string;
begin
  if fHardwarePrepared or fHardwarePrepareAttempted then
    Exit;
  fHardwarePrepareAttempted := True;
  PublishDiagnostics(CMic140StatusDisconnected, 'connecting', True);
  { Неудостпное сетевое устройство является штатной конфигурацией проекта.
    Сначала используем небросающий TestLink/TCP-проверку и только после успеха
    вызываем Connect/InitializeDevice/ConfigureDevice. Это не останавливает
    Lazarus debugger на ожидаемо отключённом приборе. }
  if not RecorderMic140HardwareLinkProbe(SourceId) then
  begin
    lTestError := 'TCP TEST failed';
    RecorderHardwareMarkSourceOffline(SourceId, lTestError);
    PublishDiagnostics(CMic140StatusError, 'connection test failed', True);
    Mic140LogWarning(Format('[DataSource:%s] MIC-140 link test failed: %s',
      [SourceId, lTestError]));
    Exit;
  end;
  RecorderHardwareClearSourceOffline(SourceId);
  fDevice.Connect;
  if fDevice.State = rdsDisconnected then
  begin
    RecorderHardwareMarkSourceOffline(SourceId, 'connection failed');
    PublishDiagnostics(CMic140StatusError, 'connection failed', True);
    Exit;
  end;
  PublishDiagnostics(CMic140StatusConnected, 'connected', True);
  RecorderHardwareRegisterLiveDevice(Self, SourceId, fDevice);
  fDevice.InitializeDevice;

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
    RecorderMic140SetDeviceSerialForSource(Registry, SourceId, fDeviceSerial);
  RebuildTemperatureTagNames;
  if (fDeviceSerial > 0) and (Registry <> nil) then
  begin
    RecorderMic140ApplyHardwareCalibrations(Registry, SourceId, fDeviceSerial);
    RecorderMic140ApplyTInHardwareCalibrations(Registry, SourceId,
      fDeviceSerial, CMic140Mic140SubRev1, fTemperatureTagNames);
  end;

  { Serial/GH/channel props (per-tag settings). }
  if Registry <> nil then
    for I := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[I];
      if not SameText(lTag.SourceId, SourceId) or
        (not ParseMic140ChannelNumber(lTag.Address, lChannelNumber)) then
        Continue;
      if not RecorderMic140TryGetChannelSettings(Registry, lTag,
        lChannelNumber, lSettings) then
      begin
        RecorderMic140InitChannelSettings(lSettings, lChannelNumber - 1,
          CMic140Mic140SubRev1);
        RecorderMic140RestoreChannelSettingsFromTag(Registry, lTag, lSettings);
      end;
      fDevice.TrySetDeviceProperty(rdpMic140RangeIndex, lSettings.RangeIndex,
        lChannelNumber - 1);
      fDevice.TrySetDeviceProperty(rdpMic140CommutIndex, lSettings.CommutIndex,
        lChannelNumber - 1);
      if not RecorderMic140ChannelUsesTemperature(lSettings) then
        Continue;
      if not lTag.ChannelCalibrationEnabled then
        Continue;
      RecorderMic140EnsureThermoCompensationForSource(Registry, SourceId);
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
      RecorderMic140UpdateChannelSettings(Registry, lTag, lSettings);
      lTag.SourceValueMode := RecorderMic140OutputModeToConfigName(momTemperatureC);
      lTag.UnitName := RecorderMic140OutputModeUnitName(momTemperatureC);
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 thermocouple curve ready: tag=%s SDB=%s',
        [SourceId, lTag.Name, lSettings.ThermocoupleScalePath]));
    end;

  { Device-level (source config) channel props. }
  lConfig := FindRecorderMic140DeviceConfig(Registry, SourceId);
  if (lConfig <> nil) and (fMic <> nil) then
  begin
    for I := 0 to lConfig.ChannelCount - 1 do
    begin
      if I <= High(lConfig.ChannelSettings) then
        lSettings := lConfig.ChannelSettings[I]
      else
        RecorderMic140InitChannelSettings(lSettings, I, CMic140Mic140SubRev1);
      fMic.TrySetDeviceProperty(rdpMic140RangeIndex, lSettings.RangeIndex, I);
      fMic.TrySetDeviceProperty(rdpMic140CommutIndex, lSettings.CommutIndex, I);
      fMic.TrySetDeviceProperty(rdpMic140BoardCommutIndex, lConfig.BoardCommutIndex, I);
    end;
  end;

  { ConfigureDevice runs exactly once per Connect/Disconnect cycle. Start is
    intentionally not called here - the worker thread calls Start() itself. }
  if not fConfigured then
  begin
    fDevice.ConfigureDevice;
    fConfigured := fDevice.State = rdsProgrammed;
  end;
  if not fConfigured then
  begin
    PublishDiagnostics(CMic140StatusError, 'programming failed', True);
    Exit;
  end;
  PublishDiagnostics(CMic140StatusProgrammed, 'programmed', True);
  fHardwarePrepared := True;
end;

procedure TRecorderMic140DataSource.Start;
begin
  inherited Start;
  fGoodBlockCount := 0;
  fReadFailCount := 0;
  fCjcActiveLogWritten := False;
  fCjcCorrectLogWritten := False;
  fTemperatureModeWarningLogged := False;
  fPublishedCorruptCount := 0;
  if (not fHardwarePrepared) or (fDevice = nil) then
  begin
    if fHardwarePrepareAttempted then
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 source is not prepared; preview will continue without device samples',
        [SourceId]));
    Exit;
  end;
  if fDevice.State <> rdsProgrammed then
    Exit;
  try
    fDevice.Start;
  except
    on E: Exception do
    begin
      RecorderHardwareMarkSourceOffline(SourceId, E.Message);
      PublishDiagnostics(CMic140StatusError, 'start failed: ' + E.Message, True);
      Exit;
    end;
  end;
  if fDevice.State = rdsStarted then
    PublishDiagnostics(CMic140StatusStarted, 'started', True)
  else
  begin
    RecorderHardwareMarkSourceOffline(SourceId, 'start failed');
    PublishDiagnostics(CMic140StatusError, 'start failed', True);
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 source is not started; preview will continue without device samples',
      [SourceId]));
  end;
end;

procedure TRecorderMic140DataSource.RequestStop;
begin
  inherited RequestStop;
  if fMic <> nil then
    fMic.RequestStopAcquisition;
end;

procedure TRecorderMic140DataSource.Stop;
begin
  RecorderHardwareUnregisterLiveDevice(Self);
  if (fMic <> nil) and (fGoodBlockCount > 0) then
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 stream stop: published=%d read=%d readGaps=%d dupRead=%d corruptRead=%d corruptPublish=%d mdpResync=%d',
      [SourceId, fGoodBlockCount, fMic.LegacyStreamReadCount,
       fMic.LegacyNumBuffGapCount, fMic.LegacyDuplicateNumBuffCount,
       fMic.LegacyCorruptReadCount, fPublishedCorruptCount,
       fMic.LegacyMdpResyncByteCount]));
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
  fConfigured := False;
  { Ретест TEST после каждого Preview добавляет лишний сетевой timeout для
    уже помеченных offline приборов - новая конфигурация выполнит проверку
    заново. }
  fHardwarePrepareAttempted := RecorderHardwareIsSourceOffline(SourceId);
  if fDevice <> nil then
  begin
    try
      fDevice.Disconnect;
      PublishDiagnostics(CMic140StatusDisconnected, 'stopped', True);
    except
      on E: Exception do
        PublishDiagnostics(CMic140StatusError, 'stop failed: ' + E.Message, True);
    end;
  end;
end;

function TRecorderMic140DataSource.Mic140PublishedCodeInRecorderRange(
  AChannelIndex: Integer; AValue: Double): Boolean;
begin
  if AChannelIndex < 48 then
    Result := Mic140v2CodeInRecorderProfile(Round(AValue), AChannelIndex)
  else
    Result := True;
end;

procedure TRecorderMic140DataSource.CheckPublishedRecorderCodes(
  const ABlock: TRecorderDeviceSampleBlock);
var
  lChannel: Integer;
  lSample: Integer;
  lBad: Integer;
  lFirstChannel: Integer;
  lFirstSample: Integer;
  lFirstValue: Double;
  lExpectedCode: Integer;
  lExpected: string;
begin
  if ABlock.SampleCount <= 0 then
    Exit;
  lBad := 0;
  lFirstChannel := -1;
  lFirstSample := -1;
  lFirstValue := 0.0;
  for lChannel := 0 to Min(ABlock.ChannelCount, 48) - 1 do
  begin
    if lChannel >= Length(ABlock.Values) then
      Break;
    for lSample := 0 to ABlock.SampleCount - 1 do
    begin
      if lSample >= Length(ABlock.Values[lChannel]) then
        Break;
      if not Mic140PublishedCodeInRecorderRange(lChannel,
        ABlock.Values[lChannel][lSample]) then
      begin
        Inc(lBad);
        if lFirstChannel < 0 then
        begin
          lFirstChannel := lChannel;
          lFirstSample := lSample;
          lFirstValue := ABlock.Values[lChannel][lSample];
        end;
      end;
    end;
  end;

  if lBad <= 0 then
    Exit;
  Inc(fPublishedCorruptCount);
  if Mic140v2RecorderReferenceCode(lFirstChannel, lExpectedCode) then
    lExpected := Format('%d +/-20', [lExpectedCode])
  else
    lExpected := 'Recorder reference +/-20';
  if (fPublishedCorruptCount <= 20) or ((fPublishedCorruptCount mod 20) = 0) then
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 code quality violation: publish=%d bad=%d first=ch%d sample=%d raw=%.0f expected=%s',
      [SourceId, fGoodBlockCount, lBad, lFirstChannel + 1, lFirstSample,
       lFirstValue, lExpected]));
end;

procedure TRecorderMic140DataSource.CheckPublishedTinCodes(
  const AAux: TMic140AuxTemperatureBlock);
const
  CTinRefCount = 2;
  CTinRecorderReference: array[0..CTinRefCount - 1] of Integer = (7650, 7800);
  CTolerance = 400;
var
  lChannel: Integer;
  lSample: Integer;
  lBad: Integer;
  lFirstChannel: Integer;
  lFirstSample: Integer;
  lFirstValue: Double;
  lPreview: string;
begin
  if AAux.SampleCount <= 0 then
    Exit;
  lBad := 0;
  lFirstChannel := -1;
  lFirstSample := -1;
  lFirstValue := 0.0;
  for lChannel := 0 to Min(AAux.ChannelCount, CTinRefCount) - 1 do
  begin
    if lChannel >= Length(AAux.Values) then
      Break;
    for lSample := 0 to AAux.SampleCount - 1 do
    begin
      if lSample >= Length(AAux.Values[lChannel]) then
        Break;
      if (lChannel >= Length(AAux.Valid)) or
        (lSample >= Length(AAux.Valid[lChannel])) or
        (not AAux.Valid[lChannel][lSample]) or
        (Abs(Round(AAux.Values[lChannel][lSample]) -
          CTinRecorderReference[lChannel]) > CTolerance) then
      begin
        Inc(lBad);
        if lFirstChannel < 0 then
        begin
          lFirstChannel := lChannel;
          lFirstSample := lSample;
          lFirstValue := AAux.Values[lChannel][lSample];
        end;
      end;
    end;
  end;

  if (fGoodBlockCount = 1) and (AAux.ChannelCount > 0) then
  begin
    lPreview := '';
    for lChannel := 0 to Min(AAux.ChannelCount, MIC140TemperatureChannelCount) - 1 do
    begin
      if lChannel >= Length(AAux.Values) then
        Break;
      if Length(AAux.Values[lChannel]) <= 0 then
        Continue;
      if lPreview <> '' then
        lPreview := lPreview + ',';
      lPreview := lPreview + Format('T%d=%.0f', [lChannel + 1,
        AAux.Values[lChannel][0]]);
    end;
    if lPreview <> '' then
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 block1 TIn raw=[%s]',
        [SourceId, lPreview]));
  end;

  if lBad <= 0 then
    Exit;
  Inc(fPublishedCorruptCount);
  if (fPublishedCorruptCount <= 20) or ((fPublishedCorruptCount mod 20) = 0) then
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 code quality violation: TIn bad=%d first=T%d sample=%d raw=%.0f expected=%d +/-20',
      [SourceId, lBad, lFirstChannel + 1, lFirstSample, lFirstValue,
       CTinRecorderReference[lFirstChannel]]));
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
  lAll48: string;
  lAll48S1: string;
  lGood48: Integer;
  lGood48S1: Integer;
begin
  lChannels := fDevice.GetChannels;
  lCount := Min(ABlock.ChannelCount, Length(lChannels));
  if lCount <= 0 then
    Exit;
  Inc(fGoodBlockCount);
  fReadFailCount := 0;
  CheckPublishedRecorderCodes(ABlock);
  PublishDiagnostics(CMic140StatusStarted, 'started; data ok', False);
  PublishBlockCounter(fGoodBlockCount);
  if (fGoodBlockCount = 1) or ((fGoodBlockCount mod 20) = 0) then
    Mic140LogWarning(Format('[DataSource:%s] MIC-140 block=%d samples=%d stride=%d rate=%.3f Hz',
      [SourceId, fGoodBlockCount, ABlock.SampleCount, ABlock.ChannelCount,
       ABlock.SampleRateHz]));
  if fGoodBlockCount = 1 then
  begin
    lPreview := '';
    lAll48 := '';
    lAll48S1 := '';
    lGood48 := 0;
    lGood48S1 := 0;
    for lI := 0 to lCount - 1 do
    begin
      if lI < 48 then
      begin
        if lI < Length(ABlock.Values) then
        begin
          lRaw := ABlock.Values[lI][0];
          if Mic140PublishedCodeInRecorderRange(lI, lRaw) then
            Inc(lGood48);
          if lAll48 <> '' then
            lAll48 := lAll48 + ',';
          lAll48 := lAll48 + IntToStr(Trunc(lRaw));
          if (ABlock.SampleCount > 1) and (Length(ABlock.Values[lI]) > 1) then
          begin
            lRaw := ABlock.Values[lI][1];
            if Mic140PublishedCodeInRecorderRange(lI, lRaw) then
              Inc(lGood48S1);
            if lAll48S1 <> '' then
              lAll48S1 := lAll48S1 + ',';
            lAll48S1 := lAll48S1 + IntToStr(Trunc(lRaw));
          end;
        end;
      end;
      if (lI > 7) and (lI <> 11) and (lI <> 23) then
        Continue;
      if lI >= fChannelTagNames.Count then
        Break;
      lTag := Registry.FindByName(fChannelTagNames[lI]);
      if lTag = nil then
        Continue;
      lRaw := Mic140RawSample(ABlock, lI, 0, lTag);
      if RecorderMic140TagHardwareCalibrationEnabled(Registry, lTag) then
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
    if lAll48 <> '' then
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 block1 sample0 all48 good=%d/48 raw=[%s]',
        [SourceId, lGood48, lAll48]));
    if lAll48S1 <> '' then
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 block1 sample1 all48 good=%d/48 raw=[%s]',
        [SourceId, lGood48S1, lAll48S1]));
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
  begin
    lAuxTemperature.ChannelCount := 0;
    lAuxTemperature.SampleCount := 0;
    SetLength(lAuxTemperature.Values, 0);
    SetLength(lAuxTemperature.Valid, 0);
  end;
  CheckPublishedTinCodes(lAuxTemperature);
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

    if not RecorderMic140TagHardwareCalibrationEnabled(Registry, lTag) then
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

    lCjcChannel := RecorderMic140TagEffectiveCjcChannel(Registry, lTag, lI,
      CMic140Mic140SubRev1);
    lTTag := nil;
    if (lCjcChannel >= 1) and (lCjcChannel <= fTemperatureTagNames.Count) then
    begin
      lTTag := FindTagBySourceAddress(Registry,
        fTemperatureTagNames[lCjcChannel - 1]);
      if lTTag = nil then
        lTTag := Registry.FindByName(fTemperatureTagNames[lCjcChannel - 1]);
    end;
    lUseCjc := RecorderMic140TagUsesThermoCompensation(Registry, lTag) and
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
    if (not lUseCjc) and RecorderMic140TagUsesThermoCompensation(Registry, lTag) and
      SameText(lTag.SourceValueMode,
        RecorderMic140OutputModeToConfigName(momTemperatureC)) and
      (not fTemperatureModeWarningLogged) then
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 CJC T%d unavailable (TIn cal missing or junction temp invalid, block tin=%d); channel will use thermocouple curve without compensation',
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
        '[DataSource:%s] MIC-140 CJC correction skipped for tag=%s: thermocouple curve is missing or cannot be inverted',
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
  lBlock: TRecorderDeviceSampleBlock;
  lTimeoutMs: Cardinal;
begin
  if ShouldStop then
    Exit;
  if (fDevice = nil) or (fMic = nil) or (fDevice.State <> rdsStarted) then
    Exit;
  lTimeoutMs := Max(Cardinal(CMic140ReadTimeoutMinMs), UpdateTimeMs * 4);
  try
    if fMic.ReadBlock(lTimeoutMs, lBlock) then
    begin
      fReadFailCount := 0;
      ProcessAndPublishBlock(lBlock);
    end
    else
    begin
      Inc(fReadFailCount);
      if fReadFailCount = 1 then
        Mic140LogWarning(Format(
          '[DataSource:%s] MIC-140 read timeout after %d published blocks (read=%d mdpResync=%d)',
          [SourceId, fGoodBlockCount, fMic.LegacyStreamReadCount,
           fMic.LegacyMdpResyncByteCount]));
      if fReadFailCount = CMic140NoDataFailThreshold then
        PublishDiagnostics(CMic140StatusError, 'no scan data', True);
    end;
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

initialization
  RecorderRegisterHardwareSourceLinkProbe(@RecorderMic140HardwareLinkProbe);

end.
