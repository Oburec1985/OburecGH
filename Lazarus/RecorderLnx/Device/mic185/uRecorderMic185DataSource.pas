unit uRecorderMic185DataSource;

{
  MIC183/185 data source for RecorderLnx.

  The protocol/device units in this folder are copies of the standalone
  Tests/mic185 implementation. This adapter binds them to RecorderLnx tags and
  data-source lifecycle.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, fpjson,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uRecorderTags, uMic185Device, uMic185Constants, uMic185MebiusTypes;

const
  MIC185DefaultHost = '192.168.9.142';
  MIC185DefaultPort = 4000;
  MIC185DefaultPollFrequencyHz = CMic185DefaultMeasFrequencyHz;

function RecorderMic185SourceId(const AHost: string; APort: Word): string;
function TryParseRecorderMic185SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
function RecorderMic185ReadDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AErrorText: string; ATimeoutMs: Cardinal = 700): Boolean;
function RecorderMic185IsEndpointLive(const AHost: string; APort: Word): Boolean;
function RecorderMic185IsLiveDeviceConnected(const AHost: string; APort: Word): Boolean;
function RecorderMic185IsSourceLinkOk(const ASourceId: string): Boolean;
function RecorderMic185TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
function RecorderMic185DefaultChannelModeText(AFrequencyHz: Double): string;
function RecorderMic185FormatChannelMode(
  const ASettings: TMic185ChannelProgramSettings): string;
procedure RecorderMic185ReadChannelMode(const AMode: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings);
function RecorderMic185RangeText(ARangeIndex: LongWord): string;
function RecorderMic185RangeUnitText(ARangeIndex: LongWord): string;
function RecorderMic185RangeMax(ARangeIndex: LongWord): Double;
function RecorderMic185CommutationText(ACommutIndex: LongWord): string;
function RecorderMic185SensorSchemeText(ASensorScheme: LongWord): string;
function RecorderMic185ChannelAddressToIndex(const AAddress: string): Integer;
procedure RecorderMic185EnsureConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double);
procedure SaveMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
procedure LoadMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
function RecorderMic185TryGetLiveDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AAcquiring: Boolean): Boolean;
procedure RecorderMic185RegisterLiveDevice(AOwner: TObject; const AHost: string;
  APort: Word; ADevice: IRecorderDevice);
procedure RecorderMic185UnregisterLiveDevice(AOwner: TObject);
procedure RecorderMic185Log(const AMessage: string);

type
  TRecorderMic185DataSource = class(TRecorderDataSourceBase)
  private
    fChannelTagNames: TStringList;
    fDevice: IRecorderDevice;
    fHost: string;
    fPort: Word;
    fPollFrequencyHz: Double;
    fSelectedNames: TStringList;
    function ChannelSelected(const AChannel: TRecorderDeviceChannel): Boolean;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure ApplyChannelProgramSettings;
    procedure ConfigureDevice;
    procedure PublishMeasurementBlock(const ABlock: TRecorderAcquisitionBlock);
    procedure PublishAuxChannels(ATimeSec: Double);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
    procedure PrepareHardware; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ASelectedNames: TStrings = nil);
    destructor Destroy; override;
    procedure RequestStop; override;
    procedure Start; override;
    procedure Stop; override;
  end;

implementation

uses
  Math, StrUtils, Variants,
  uMic185MebiusTcpProtocol, uRecorderMic185Runtime,
  uRecorderHardwareLiveDevices, uRecorderMic140Utils,
  uRecorderConfiguredDataSources;

const
  CMic185SourcePrefix = 'MIC-185: ';
  CMic185ModuleName = 'MIC183/185';
  CMic185ChannelModePrefix = 'mic185:';

function Mic185FloatToText(AValue: Double): string;
begin
  Result := StringReplace(FormatFloat('0.######', AValue), ',', '.', []);
end;

function Mic185TextToFloatDef(const AText: string; ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AText);
  if TryStrToFloat(lText, Result) then
    Exit;
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator, []);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator, []);
  if not TryStrToFloat(lText, Result) then
    Result := ADefault;
end;

function Mic185TextToIntDef(const AText: string; ADefault: Integer): Integer;
begin
  if not TryStrToInt(Trim(AText), Result) then
    Result := ADefault;
end;

function RecorderMic185FormatChannelMode(
  const ASettings: TMic185ChannelProgramSettings): string;
begin
  Result := Format(
    '%srange=%d;commut=%d;scheme=%d;soft=%d;shunt=%d;eval=%d;sens=%s;res=%s;block=%d',
    [CMic185ChannelModePrefix, ASettings.MeasRangeIndex, ASettings.CommutIndex,
     ASettings.SensorScheme, ASettings.SoftBalance, ASettings.ShuntOn,
     ASettings.EvalType, Mic185FloatToText(ASettings.TensoSensitivity),
     Mic185FloatToText(ASettings.Resistance), ASettings.BlockSize]);
end;

function RecorderMic185DefaultChannelModeText(AFrequencyHz: Double): string;
var
  lSettings: TMic185ChannelProgramSettings;
begin
  Mic185DefaultChannelProgramSettings(AFrequencyHz, lSettings);
  Result := RecorderMic185FormatChannelMode(lSettings);
end;

function Mic185ModeValue(const AMode, AKey: string; const ADefault: string): string;
var
  I, lPos: Integer;
  lItems: TStringList;
  lName: string;
begin
  Result := ADefault;
  lItems := TStringList.Create;
  try
    lItems.Delimiter := ';';
    lItems.StrictDelimiter := True;
    lItems.DelimitedText := AMode;
    for I := 0 to lItems.Count - 1 do
    begin
      lPos := Pos('=', lItems[I]);
      if lPos <= 0 then
        Continue;
      lName := Trim(Copy(lItems[I], 1, lPos - 1));
      if SameText(lName, AKey) then
      begin
        Result := Trim(Copy(lItems[I], lPos + 1, MaxInt));
        Exit;
      end;
    end;
  finally
    lItems.Free;
  end;
end;

procedure RecorderMic185ReadChannelMode(const AMode: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings);
var
  lMode: string;
begin
  Mic185DefaultChannelProgramSettings(AFrequencyHz, ASettings);
  lMode := Trim(AMode);
  if SameText(Copy(lMode, 1, Length(CMic185ChannelModePrefix)),
    CMic185ChannelModePrefix) then
  begin
    Delete(lMode, 1, Length(CMic185ChannelModePrefix));
    ASettings.MeasRangeIndex :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'range',
      IntToStr(CMic185Range5mV)), CMic185Range5mV));
    ASettings.CommutIndex :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'commut',
      IntToStr(CMic185CommutInput)), CMic185CommutInput));
    ASettings.SensorScheme :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'scheme',
      IntToStr(CMic185SensorSchemeTenzo)), CMic185SensorSchemeTenzo));
    ASettings.SoftBalance :=
      Mic185TextToIntDef(Mic185ModeValue(lMode, 'soft', '0'), 0);
    ASettings.ShuntOn :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'shunt', '0'), 0));
    ASettings.EvalType :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'eval', '0'), 0));
    ASettings.TensoSensitivity :=
      Mic185TextToFloatDef(Mic185ModeValue(lMode, 'sens', '2'), 2);
    ASettings.Resistance :=
      Mic185TextToFloatDef(Mic185ModeValue(lMode, 'res', '200'), 200);
    ASettings.BlockSize :=
      Word(Mic185TextToIntDef(Mic185ModeValue(lMode, 'block', '1'), 1));
    if ASettings.BlockSize = 0 then
      ASettings.BlockSize := 1;
    Exit;
  end;

  if lMode <> '' then
  begin
    if (Pos('49', lMode) > 0) or (Pos('39', lMode) > 0) then
      ASettings.CommutIndex := CMic185CommutCalibr
    else if Pos('Зем', lMode) > 0 then
      ASettings.CommutIndex := CMic185CommutGround
    else
      ASettings.CommutIndex := CMic185CommutInput;
  end;
end;

function RecorderMic185RangeText(ARangeIndex: LongWord): string;
begin
  case ARangeIndex of
    CMic185Range500mV: Result := '±500.000';
    CMic185Range50mV: Result := '±50.000';
    CMic185Range05mV: Result := '±0.500';
  else
    Result := '±5.000';
  end;
end;

function RecorderMic185RangeUnitText(ARangeIndex: LongWord): string;
begin
  if ARangeIndex = CMic185Range05mV then
    Result := 'мВ(тензо)'
  else
    Result := 'мВ';
end;

function RecorderMic185RangeMax(ARangeIndex: LongWord): Double;
begin
  case ARangeIndex of
    CMic185Range500mV: Result := 500;
    CMic185Range50mV: Result := 50;
    CMic185Range05mV: Result := 0.5;
  else
    Result := 5;
  end;
end;

function RecorderMic185CommutationText(ACommutIndex: LongWord): string;
begin
  case ACommutIndex of
    CMic185CommutGround: Result := 'Земля';
    CMic185CommutCalibr: Result := '49 мВ';
  else
    Result := 'Вход';
  end;
end;

function RecorderMic185SensorSchemeText(ASensorScheme: LongWord): string;
begin
  case ASensorScheme of
    CMic185SensorSchemeHalf: Result := 'Полумост';
    CMic185SensorSchemeBridge: Result := 'Мост';
  else
    Result := 'Тензометр';
  end;
end;

function RecorderMic185ChannelAddressToIndex(const AAddress: string): Integer;
var
  lEndPos, lStartPos: Integer;
  lText: string;
begin
  Result := -1;
  lStartPos := RPos('-', AAddress);
  if lStartPos <= 0 then
    Exit;
  lEndPos := PosEx('}', AAddress, lStartPos + 1);
  if lEndPos <= lStartPos then
    Exit;
  lText := Copy(AAddress, lStartPos + 1, lEndPos - lStartPos - 1);
  if (Pos('t', LowerCase(lText)) > 0) or SameText(lText, 'uts') then
    Exit;
  if not TryStrToInt(lText, Result) then
    Exit(-1);
  Dec(Result);
  if (Result < 0) or (Result >= CMic185ChannelCountMax) then
    Result := -1;
end;

procedure RecorderMic185EnsureConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double);
begin
  RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId, CMic185ModuleName,
    APollFrequencyHz);
end;

function Mic185JsonArray(AOwner: TJSONObject; const AName: string): TJSONArray;
var
  lData: TJSONData;
begin
  Result := nil;
  if AOwner = nil then
    Exit;
  lData := AOwner.Find(AName);
  if lData is TJSONArray then
    Exit(TJSONArray(lData));
  Result := TJSONArray.Create;
  AOwner.Add(AName, Result);
end;

function Mic185FindOrCreateDataSourceJson(AJson: TJSONObject;
  const ASourceId: string): TJSONObject;
var
  I: Integer;
  lArray: TJSONArray;
begin
  Result := nil;
  lArray := Mic185JsonArray(AJson, 'dataSources');
  if lArray = nil then
    Exit;
  for I := 0 to lArray.Count - 1 do
    if (lArray.Items[I] is TJSONObject) and
      SameText(TJSONObject(lArray.Items[I]).Get('sourceId', ''), ASourceId) then
      Exit(TJSONObject(lArray.Items[I]));

  Result := TJSONObject.Create;
  lArray.Add(Result);
  Result.Add('sourceId', ASourceId);
  Result.Add('moduleType', CMic185ModuleName);
  Result.Add('defaultPollFrequencyHz', MIC185DefaultPollFrequencyHz);
end;

function Mic185FindOrCreateObject(AOwner: TJSONObject;
  const AName: string): TJSONObject;
var
  lData: TJSONData;
begin
  Result := nil;
  if AOwner = nil then
    Exit;
  lData := AOwner.Find(AName);
  if lData is TJSONObject then
  begin
    Result := TJSONObject(lData);
    Result.Clear;
    Exit;
  end;
  Result := TJSONObject.Create;
  AOwner.Add(AName, Result);
end;

procedure SaveMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  J: Integer;
  lChannel: TJSONObject;
  lChannels: TJSONArray;
  lHost: string;
  lItem: TJSONObject;
  lMic185: TJSONObject;
  lPollHz: Double;
  lPort: Word;
  lSourceId: string;
  lSources: TStringList;
  lTag: TRecorderTag;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  lSources := TStringList.Create;
  try
    lSources.CaseSensitive := False;
    lSources.Sorted := False;
    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      lSourceId := RecorderNormalizeTagSourceId(lTag.SourceId);
      if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
        Continue;
      if lSources.IndexOf(lSourceId) < 0 then
        lSources.Add(lSourceId);
    end;

    for I := 0 to lSources.Count - 1 do
    begin
      lSourceId := lSources[I];
      if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
        Continue;
      lPollHz := MIC185DefaultPollFrequencyHz;
      for J := 0 to ARegistry.TagCount - 1 do
      begin
        lTag := ARegistry.Tags[J];
        if SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) and
          (lTag.PollFrequencyHz > 0) then
        begin
          lPollHz := lTag.PollFrequencyHz;
          Break;
        end;
      end;
      RecorderMic185EnsureConfiguredSource(ARegistry, lSourceId, lPollHz);
      lItem := Mic185FindOrCreateDataSourceJson(AJson, lSourceId);
      if lItem = nil then
        Continue;
      lMic185 := Mic185FindOrCreateObject(lItem, 'mic185');
      lMic185.Add('host', lHost);
      lMic185.Add('port', Integer(lPort));
      lMic185.Add('defaultPollFrequencyHz', lPollHz);
      lChannels := TJSONArray.Create;
      lMic185.Add('tagLinks', lChannels);
      for J := 0 to ARegistry.TagCount - 1 do
      begin
        lTag := ARegistry.Tags[J];
        if not SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) then
          Continue;
        lChannel := TJSONObject.Create;
        lChannels.Add(lChannel);
        lChannel.Add('tagName', lTag.Name);
        lChannel.Add('address', lTag.Address);
        lChannel.Add('sourceValueMode', lTag.SourceValueMode);
        lChannel.Add('pollFrequencyHz', lTag.PollFrequencyHz);
      end;
    end;
  finally
    lSources.Free;
  end;
end;

procedure LoadMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lArray: TJSONArray;
  lData: TJSONData;
  lHost: string;
  lItem: TJSONObject;
  lPollHz: Double;
  lPort: Word;
  lSourceId: string;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  lData := AJson.Find('dataSources');
  if not (lData is TJSONArray) then
    Exit;
  lArray := TJSONArray(lData);
  for I := 0 to lArray.Count - 1 do
  begin
    if not (lArray.Items[I] is TJSONObject) then
      Continue;
    lItem := TJSONObject(lArray.Items[I]);
    lSourceId := RecorderNormalizeTagSourceId(lItem.Get('sourceId', ''));
    if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
      Continue;
    lPollHz := lItem.Get('defaultPollFrequencyHz', MIC185DefaultPollFrequencyHz);
    RecorderMic185EnsureConfiguredSource(ARegistry, lSourceId, lPollHz);
  end;
end;

function RecorderMic185FindLiveDevice(const AHost: string; APort: Word): TRecorderMic185Device;
var
  lDevice: IRecorderDevice;
begin
  Result := nil;
  lDevice := RecorderHardwareFindLiveDevice(RecorderMic185SourceId(AHost, APort));
  if (lDevice <> nil) and (lDevice.GetNativeObject is TRecorderMic185Device) then
    Result := TRecorderMic185Device(lDevice.GetNativeObject);
end;

procedure RecorderMic185RegisterLiveDevice(AOwner: TObject; const AHost: string;
  APort: Word; ADevice: IRecorderDevice);
begin
  if (AOwner = nil) or (ADevice = nil) then
    Exit;
  RecorderHardwareRegisterLiveDevice(AOwner, RecorderMic185SourceId(AHost, APort),
    ADevice);
end;

procedure RecorderMic185UnregisterLiveDevice(AOwner: TObject);
begin
  RecorderHardwareUnregisterLiveDevice(AOwner);
end;

function RecorderMic185IsLiveDeviceConnected(const AHost: string; APort: Word): Boolean;
begin
  Result := RecorderHardwareIsSourceLinkOk(RecorderMic185SourceId(AHost, APort));
end;

function RecorderMic185TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
begin
  if RecorderMic185RuntimeIsBusy(AHost, APort) then
    Exit(True);
  Result := RecorderMic140TcpProbe(AHost, APort, ATimeoutMs);
end;

function RecorderMic185IsSourceLinkOk(const ASourceId: string): Boolean;
var
  lHost: string;
  lPort: Word;
  lCanonId: string;
begin
  lCanonId := Trim(ASourceId);
  if RecorderHardwareIsSourceLinkOk(lCanonId) then
    Exit(True);
  if TryParseRecorderMic185SourceId(lCanonId, lHost, lPort) then
  begin
    lCanonId := RecorderMic185SourceId(lHost, lPort);
    if not SameText(lCanonId, Trim(ASourceId)) and
      RecorderHardwareIsSourceLinkOk(lCanonId) then
      Exit(True);
    if RecorderMic185RuntimeIsBusy(lHost, lPort) then
      Exit(True);
    Result := RecorderMic185TcpProbe(lHost, lPort, 1000);
    Exit;
  end;
  Result := False;
end;

function RecorderMic185TryGetLiveDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AAcquiring: Boolean): Boolean;
var
  lDevice: TRecorderMic185Device;
  lErrorText: string;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  AAcquiring := False;
  lDevice := RecorderMic185FindLiveDevice(AHost, APort);
  if lDevice = nil then
    Exit;
  if not lDevice.TestLink(lErrorText) then
    Exit;
  ASerialNumber := lDevice.DeviceSerial;
  if lDevice.SoftVersion <> 0 then
    AVersionText := Mic185FormatSoftVersion(lDevice.SoftVersion);
  AAcquiring := lDevice.State = rdsStarted;
  Result := True;
  RecorderMic185Log(Format(
    'LiveDeviceInfo %s:%d sn=%d ver=%s acquiring=%s state=%d',
    [Trim(AHost), APort, ASerialNumber, AVersionText, BoolToStr(AAcquiring, True),
     Ord(lDevice.State)]));
end;

function RecorderMic185IsEndpointLive(const AHost: string; APort: Word): Boolean;
begin
  Result := RecorderMic185IsLiveDeviceConnected(AHost, APort);
end;

procedure RecorderMic185Log(const AMessage: string);
begin
  RecorderMic185RuntimeLog(AMessage);
end;

function RecorderMic185SourceId(const AHost: string; APort: Word): string;
begin
  Result := CMic185SourcePrefix + Trim(AHost) + ':' + IntToStr(APort);
end;

function TryParseRecorderMic185SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
var
  lText: string;
  lPos: Integer;
  lPort: Integer;
begin
  Result := False;
  AHost := '';
  APort := 0;
  if Pos(CMic185SourcePrefix, ASourceId) <> 1 then
    Exit;
  lText := Trim(Copy(ASourceId, Length(CMic185SourcePrefix) + 1, MaxInt));
  lPos := RPos(':', lText);
  if lPos <= 1 then
    Exit;
  if not TryStrToInt(Copy(lText, lPos + 1, MaxInt), lPort) then
    Exit;
  if (lPort < 1) or (lPort > 65535) then
    Exit;
  AHost := Trim(Copy(lText, 1, lPos - 1));
  if AHost = '' then
    Exit;
  APort := Word(lPort);
  Result := True;
end;

function RecorderMic185ReadDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AErrorText: string; ATimeoutMs: Cardinal): Boolean;
var
  lAcquiring: Boolean;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  AErrorText := '';
  if Trim(AHost) = '' then
  begin
    AErrorText := 'MIC183/185 host is not set';
    Exit;
  end;

  if RecorderMic185TryGetLiveDeviceInfo(Trim(AHost), APort, ASerialNumber,
    AVersionText, lAcquiring) then
  begin
    Result := True;
    Exit;
  end;

  AErrorText := 'Нет активного подключения MIC183/185';
  RecorderMic185Log(Format('ReadDeviceInfo %s:%d: no live device (%s)',
    [Trim(AHost), APort, AErrorText]));
end;

constructor TRecorderMic185DataSource.Create(const ASourceId, AHost: string;
  APort: Word; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ASelectedNames: TStrings);
begin
  inherited Create(ASourceId, 'MIC183/185 data source', AUpdateTimeMs);
  fHost := AHost;
  fPort := APort;
  fPollFrequencyHz := APollFrequencyHz;
  if fPollFrequencyHz <= 0 then
    fPollFrequencyHz := MIC185DefaultPollFrequencyHz;
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fSelectedNames := TStringList.Create;
  fSelectedNames.CaseSensitive := False;
  if ASelectedNames <> nil then
    fSelectedNames.Assign(ASelectedNames);
end;

destructor TRecorderMic185DataSource.Destroy;
begin
  Stop;
  fSelectedNames.Free;
  fChannelTagNames.Free;
  inherited Destroy;
end;

function TRecorderMic185DataSource.FindTagBySourceAddress(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, SourceId) and SameText(lTag.Address, AAddress) then
      Exit(lTag);
  end;
end;

function TRecorderMic185DataSource.ChannelSelected(
  const AChannel: TRecorderDeviceChannel): Boolean;
begin
  Result := (fSelectedNames.Count = 0) or
    (fSelectedNames.IndexOf(AChannel.Name) >= 0) or
    (fSelectedNames.IndexOf(AChannel.Address) >= 0);
end;

procedure TRecorderMic185DataSource.ConfigureDevice;
begin
  fDevice := CreateRecorderMic185Device;
  fDevice.TrySetDeviceProperty(rdpHost, fHost);
  fDevice.TrySetDeviceProperty(rdpPort, Integer(fPort));
  fDevice.TrySetDeviceProperty(rdpPollFrequencyHz, fPollFrequencyHz);
  fDevice.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(UpdateTimeMs));
end;

procedure TRecorderMic185DataSource.ApplyChannelProgramSettings;
var
  I, lIndex: Integer;
  lDevice: TRecorderMic185Device;
  lSettings: TMic185ChannelProgramSettingsArray;
  lTag: TRecorderTag;
begin
  if (fDevice = nil) or (not (fDevice.GetNativeObject is TRecorderMic185Device)) then
    Exit;
  lDevice := TRecorderMic185Device(fDevice.GetNativeObject);

  Mic185DefaultChannelProgramSettingsArray(fPollFrequencyHz, lSettings);

  if Registry <> nil then
    for I := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[I];
      if not SameText(lTag.SourceId, SourceId) then
        Continue;
      lIndex := RecorderMic185ChannelAddressToIndex(lTag.Address);
      if lIndex < 0 then
        Continue;
      RecorderMic185ReadChannelMode(lTag.SourceValueMode, lTag.PollFrequencyHz,
        lSettings[lIndex]);
      if lSettings[lIndex].FrequencyHz <= 0 then
        lSettings[lIndex].FrequencyHz := fPollFrequencyHz;
      lSettings[lIndex].Connected := True;
    end;

  lDevice.ApplyChannelProgramSettings(lSettings);
end;

procedure TRecorderMic185DataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lCapacity: Integer;
  lChannels: TRecorderDeviceChannelArray;
  lChannelSettings: TMic185ChannelProgramSettings;
  lTag: TRecorderTag;
begin
  if fDevice = nil then
    ConfigureDevice;

  ARegistry.RegisterActiveSource(SourceId);
  fChannelTagNames.Clear;
  lChannels := fDevice.GetChannels;
  for I := 0 to High(lChannels) do
  begin
    if not ChannelSelected(lChannels[I]) then
      Continue;

    lTag := FindTagBySourceAddress(ARegistry, lChannels[I].Address);
    if lTag = nil then
      lTag := ARegistry.FindByName(lChannels[I].Name);
    if lTag = nil then
    begin
      lCapacity := Ceil(Max(4096, lChannels[I].PollFrequencyHz * 4));
      lTag := ARegistry.CreateTag(lChannels[I].Name, lCapacity);
    end;

    lTag.SourceId := SourceId;
    lTag.Address := lChannels[I].Address;
    lTag.ModuleType := CMic185ModuleName;
    lTag.PollFrequencyHz := lChannels[I].PollFrequencyHz;
    if I < CMic185ChannelCountMax then
    begin
      if Trim(lTag.SourceValueMode) = '' then
        lTag.SourceValueMode :=
          RecorderMic185DefaultChannelModeText(lChannels[I].PollFrequencyHz);
      RecorderMic185ReadChannelMode(lTag.SourceValueMode, lChannels[I].PollFrequencyHz,
        lChannelSettings);
      lTag.UnitName := RecorderMic185RangeUnitText(lChannelSettings.MeasRangeIndex);
      lTag.RangeMax := RecorderMic185RangeMax(lChannelSettings.MeasRangeIndex);
      lTag.RangeMin := -lTag.RangeMax;
    end
    else
    begin
      lTag.UnitName := lChannels[I].UnitName;
      if I < CMic185ChannelCountMax + CMic185TempChannelCount then
      begin
        lTag.RangeMin := CMic185TempMinRangeC;
        lTag.RangeMax := CMic185TempMaxRangeC;
      end;
    end;
    lTag.AutoRange := False;
    lTag.AutoUnit := False;
    lTag.Description := Format('%s channel %s', [CMic185ModuleName, lChannels[I].Address]);
    lTag.EnsureBufferCapacity(Ceil(Max(4096, lChannels[I].PollFrequencyHz * 4)));
    fChannelTagNames.Add(lTag.Name);
  end;
end;

procedure TRecorderMic185DataSource.PrepareHardware;
begin
  inherited PrepareHardware;
  if fDevice = nil then
    ConfigureDevice;
  ApplyChannelProgramSettings;
  fDevice.Connect;
  fDevice.ProgramDevice;
  RecorderMic185RegisterLiveDevice(Self, fHost, fPort, fDevice);
end;

procedure TRecorderMic185DataSource.Start;
begin
  inherited Start;
  if fDevice = nil then
    ConfigureDevice;
  if fDevice.State <> rdsStarted then
    fDevice.Start;
end;

procedure TRecorderMic185DataSource.RequestStop;
begin
  RecorderMic185RuntimeHoldBusy(Trim(fHost), fPort, True);
  inherited RequestStop;
end;

procedure TRecorderMic185DataSource.Stop;
begin
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
      fDevice.Disconnect;
    except
      on E: Exception do
        ;
    end;
    fDevice := nil;
  end;
  RecorderHardwareUnregisterLiveDevice(Self);
  RecorderMic185RuntimeHoldBusy(Trim(fHost), fPort, False);
  inherited Stop;
end;

procedure TRecorderMic185DataSource.PublishMeasurementBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  I, J: Integer;
  lCount: Integer;
  lTag: TRecorderTag;
  lTimes: TRecorderDoubleArray;
  lValues: TRecorderDoubleArray;
begin
  if (Registry = nil) or (ABlock.SampleCount <= 0) or (ABlock.SampleRateHz <= 0) then
    Exit;

  SetLength(lTimes, ABlock.SampleCount);
  SetLength(lValues, ABlock.SampleCount);
  for J := 0 to ABlock.SampleCount - 1 do
    lTimes[J] := ABlock.FirstTimeSec + (J / ABlock.SampleRateHz);

  lCount := Min(ABlock.ChannelCount, fChannelTagNames.Count);
  for I := 0 to lCount - 1 do
  begin
    lTag := Registry.FindByName(fChannelTagNames[I]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;
    for J := 0 to ABlock.SampleCount - 1 do
      lValues[J] := ABlock.Values[I][J];
    Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount, True);
  end;

  for I := 0 to lCount - 1 do
  begin
    lTag := Registry.FindByName(fChannelTagNames[I]);
    if (lTag <> nil) and SameText(lTag.SourceId, SourceId) then
      Registry.PublishBlockNotifications(lTag.Name);
  end;

  PublishAuxChannels(lTimes[ABlock.SampleCount - 1]);
end;

procedure TRecorderMic185DataSource.PublishAuxChannels(ATimeSec: Double);
var
  I: Integer;
  lDevice: TRecorderMic185Device;
  lTag: TRecorderTag;
begin
  if (Registry = nil) or (fDevice = nil) or
    (not (fDevice.GetNativeObject is TRecorderMic185Device)) then
    Exit;
  lDevice := TRecorderMic185Device(fDevice.GetNativeObject);

  if lDevice.HasTempData then
    for I := 0 to lDevice.TempChannelCount - 1 do
    begin
      lTag := FindTagBySourceAddress(Registry,
        Format('MIC183_185-{%d-t%d}', [3, I + 1]));
      if lTag <> nil then
        Registry.PublishValue(lTag.Name, ATimeSec, lDevice.LastTempValue(I));
    end;

  if lDevice.HasUtsData then
  begin
    lTag := FindTagBySourceAddress(Registry, Format('MIC183_185-{%d-uts}', [3]));
    if lTag <> nil then
      Registry.PublishValue(lTag.Name, ATimeSec, lDevice.LastUts);
  end;
end;

procedure TRecorderMic185DataSource.DoTick;
var
  lBlock: TRecorderAcquisitionBlock;
  lTimeout: Cardinal;
begin
  if fDevice = nil then
    Exit;
  if fDevice.State <> rdsStarted then
    fDevice.Start;

  lTimeout := Max(Cardinal(1000), UpdateTimeMs * 4);
  if fDevice.ReadBlock(lTimeout, lBlock) then
    PublishMeasurementBlock(lBlock);
end;

end.
