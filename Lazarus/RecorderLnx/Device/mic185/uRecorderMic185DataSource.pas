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
  uRecorderTags, uRecorderConfiguredDataSources,
  uMic185Device, uMic185Constants, uMic185MebiusTypes;

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
function RecorderMic185GetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings): Boolean;
procedure RecorderMic185SetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  const ASettings: TMic185ChannelProgramSettings);
function RecorderMic185GetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): LongWord;
procedure RecorderMic185SetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double; APowerMaCode: LongWord);
function RecorderMic185ProgramConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out AErrorText: string): Boolean;
function RecorderMic185RangeText(ARangeIndex: LongWord): string;
function RecorderMic185RangeUnitText(ARangeIndex: LongWord): string;
function RecorderMic185RangeMax(ARangeIndex: LongWord): Double;
function RecorderMic185CommutationText(ACommutIndex: LongWord): string;
function RecorderMic185SensorSchemeText(ASensorScheme: LongWord): string;
function RecorderMic185ChannelAddressToIndex(const AAddress: string): Integer;
function RecorderMic185EnsureConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double): TRecorderConfiguredDataSource;
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
  jsonparser, uMic185MebiusTcpProtocol, uRecorderMic185Runtime,
  uRecorderHardwareLiveDevices, uRecorderMic140Utils;

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
    '%srange=%d;commut=%d;scheme=%d;soft=%d;shunt=%d;eval=%d;sens=%s;res=%s;block=%d;power=%d',
    [CMic185ChannelModePrefix, ASettings.MeasRangeIndex, ASettings.CommutIndex,
     ASettings.SensorScheme, ASettings.SoftBalance, ASettings.ShuntOn,
     ASettings.EvalType, Mic185FloatToText(ASettings.TensoSensitivity),
     Mic185FloatToText(ASettings.Resistance), ASettings.BlockSize,
     ASettings.PowerMaCode]);
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
    ASettings.PowerMaCode :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'power',
      IntToStr(CMic185DefaultPowerMaCode)), CMic185DefaultPowerMaCode));
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

function Mic185SourceConfigObject(AEntry: TRecorderConfiguredDataSource;
  ACreate: Boolean): TJSONObject;
var
  lData: TJSONData;
begin
  Result := nil;
  if AEntry = nil then
    Exit;
  if Trim(AEntry.SpecificConfigText) = '' then
  begin
    if ACreate then
      Result := TJSONObject.Create;
    Exit;
  end;
  try
    lData := GetJSON(AEntry.SpecificConfigText);
  except
    lData := nil;
  end;
  if lData is TJSONObject then
    Result := TJSONObject(lData)
  else
  begin
    lData.Free;
    if ACreate then
      Result := TJSONObject.Create;
  end;
end;

procedure Mic185StoreSourceConfigObject(AEntry: TRecorderConfiguredDataSource;
  AConfig: TJSONObject);
begin
  if (AEntry = nil) or (AConfig = nil) then
    Exit;
  AEntry.SpecificConfigText := AConfig.AsJSON;
end;

function Mic185ConfigChannels(AConfig: TJSONObject;
  ACreate: Boolean): TJSONArray;
var
  lData: TJSONData;
begin
  Result := nil;
  if AConfig = nil then
    Exit;
  lData := AConfig.Find('channels');
  if lData is TJSONArray then
    Exit(TJSONArray(lData));
  if not ACreate then
    Exit;
  Result := TJSONArray.Create;
  AConfig.Add('channels', Result);
end;

function RecorderMic185GetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings): Boolean;
var
  I: Integer;
  lChannels: TJSONArray;
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lItem: TJSONObject;
  lMode: string;
begin
  Result := False;
  Mic185DefaultChannelProgramSettings(AFrequencyHz, ASettings);
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    lChannels := Mic185ConfigChannels(lConfig, False);
    if lChannels = nil then
      Exit;
    for I := 0 to lChannels.Count - 1 do
    begin
      if not (lChannels.Items[I] is TJSONObject) then
        Continue;
      lItem := TJSONObject(lChannels.Items[I]);
      if not SameText(lItem.Get('address', ''), AAddress) then
        Continue;
      lMode := lItem.Get('sourceValueMode', '');
      RecorderMic185ReadChannelMode(lMode, AFrequencyHz, ASettings);
      Result := Trim(lMode) <> '';
      Exit;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185SetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  const ASettings: TMic185ChannelProgramSettings);
var
  I: Integer;
  lIndex: Integer;
  lChannels: TJSONArray;
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lItem: TJSONObject;
begin
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId,
    CMic185ModuleName, AFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    lChannels := Mic185ConfigChannels(lConfig, True);
    lItem := nil;
    for I := 0 to lChannels.Count - 1 do
      if (lChannels.Items[I] is TJSONObject) and
        SameText(TJSONObject(lChannels.Items[I]).Get('address', ''), AAddress) then
      begin
        lItem := TJSONObject(lChannels.Items[I]);
        Break;
      end;
    if lItem = nil then
    begin
      lItem := TJSONObject.Create;
      lChannels.Add(lItem);
      lItem.Add('address', AAddress);
    end;
    lIndex := lItem.IndexOfName('sourceValueMode');
    if lIndex >= 0 then
      lItem.Delete(lIndex);
    lIndex := lItem.IndexOfName('pollFrequencyHz');
    if lIndex >= 0 then
      lItem.Delete(lIndex);
    lItem.Add('sourceValueMode', RecorderMic185FormatChannelMode(ASettings));
    lItem.Add('pollFrequencyHz', AFrequencyHz);
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

function RecorderMic185GetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): LongWord;
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
begin
  Result := CMic185DefaultPowerMaCode;
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    if lConfig <> nil then
      Result := LongWord(lConfig.Get('powerMaCode',
        Integer(CMic185DefaultPowerMaCode)));
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185SetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double; APowerMaCode: LongWord);
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lIndex: Integer;
begin
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId,
    CMic185ModuleName, APollFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    lIndex := lConfig.IndexOfName('powerMaCode');
    if lIndex >= 0 then
      lConfig.Delete(lIndex);
    if APowerMaCode = 0 then
      APowerMaCode := CMic185DefaultPowerMaCode;
    lConfig.Add('powerMaCode', Integer(APowerMaCode));
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185BuildSourceProgramSettings(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettingsArray);
var
  I: Integer;
  lAddress: string;
  lPowerMaCode: LongWord;
begin
  Mic185DefaultChannelProgramSettingsArray(AFrequencyHz, ASettings);
  lPowerMaCode := RecorderMic185GetSourcePowerMaCode(ARegistry, ASourceId);
  for I := 0 to CMic185ChannelCountMax - 1 do
  begin
    lAddress := Format('MIC183_185-{%d-%d}', [3, I + 1]);
    RecorderMic185GetSourceChannelMode(ARegistry, ASourceId, lAddress,
      AFrequencyHz, ASettings[I]);
    if ASettings[I].FrequencyHz <= 0 then
      ASettings[I].FrequencyHz := AFrequencyHz;
    ASettings[I].Connected := True;
    ASettings[I].PowerMaCode := lPowerMaCode;
  end;
end;

function RecorderMic185ProgramConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out AErrorText: string): Boolean;
var
  I: Integer;
  lDevice: IRecorderDevice;
  lHost: string;
  lNative: TRecorderMic185Device;
  lPollHz: Double;
  lPort: Word;
  lSettings: TMic185ChannelProgramSettingsArray;
  lSummary: string;
begin
  Result := False;
  AErrorText := '';
  if not TryParseRecorderMic185SourceId(ASourceId, lHost, lPort) then
  begin
    AErrorText := 'Invalid MIC183/185 source id';
    Exit;
  end;
  lPollHz := MIC185DefaultPollFrequencyHz;
  if RecorderConfiguredDataSourcesFind(ARegistry, ASourceId) <> nil then
    if RecorderConfiguredDataSourcesFind(ARegistry, ASourceId).DefaultPollFrequencyHz > 0 then
      lPollHz := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId).DefaultPollFrequencyHz;

  RecorderMic185BuildSourceProgramSettings(ARegistry, ASourceId, lPollHz,
    lSettings);
  lSummary := '';
  for I := 0 to High(lSettings) do
  begin
    if lSummary <> '' then
      lSummary := lSummary + '; ';
    lSummary := lSummary + Format('ch%d range=%d commut=%d scheme=%d shunt=%d block=%d',
      [I + 1, lSettings[I].MeasRangeIndex, lSettings[I].CommutIndex,
       lSettings[I].SensorScheme, lSettings[I].ShuntOn, lSettings[I].BlockSize]);
  end;
  RecorderMic185Log(Format('ProgramConfiguredSource %s power=%d: %s',
    [ASourceId, lSettings[0].PowerMaCode, lSummary]));

  lDevice := CreateRecorderMic185Device;
  try
    lDevice.TrySetDeviceProperty(rdpHost, lHost);
    lDevice.TrySetDeviceProperty(rdpPort, Integer(lPort));
    lDevice.TrySetDeviceProperty(rdpPollFrequencyHz, lPollHz);
    if not (lDevice.GetNativeObject is TRecorderMic185Device) then
    begin
      AErrorText := 'MIC183/185 device object is not available';
      Exit;
    end;
    lNative := TRecorderMic185Device(lDevice.GetNativeObject);
    lNative.ApplyChannelProgramSettings(lSettings);
    try
      lDevice.Connect;
      lDevice.ProgramDevice;
      Result := True;
    except
      on E: Exception do
      begin
        AErrorText := E.Message;
        RecorderMic185Log(Format('ProgramConfiguredSource failed %s: %s',
          [ASourceId, AErrorText]));
      end;
    end;
  finally
    try
      lDevice.Disconnect;
    except
    end;
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

function RecorderMic185EnsureConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double): TRecorderConfiguredDataSource;
begin
  Result := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId, CMic185ModuleName,
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
  lChannels: TJSONArray;
  lConfig: TJSONObject;
  lHost: string;
  lItem: TJSONObject;
  lLink: TJSONObject;
  lLinks: TJSONArray;
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
      lLinks := TJSONArray.Create;
      lMic185.Add('tagLinks', lLinks);
      for J := 0 to ARegistry.TagCount - 1 do
      begin
        lTag := ARegistry.Tags[J];
        if not SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) then
          Continue;
        lLink := TJSONObject.Create;
        lLinks.Add(lLink);
        lLink.Add('tagId', lTag.Id);
        lLink.Add('tagName', lTag.Name);
        lLink.Add('address', lTag.Address);
        lLink.Add('pollFrequencyHz', lTag.PollFrequencyHz);
      end;
      lConfig := Mic185SourceConfigObject(
        RecorderConfiguredDataSourcesFind(ARegistry, lSourceId), False);
      try
        lChannels := Mic185ConfigChannels(lConfig, False);
        if lChannels <> nil then
          lMic185.Add('channels', lChannels.Clone);
        if lConfig <> nil then
          lMic185.Add('powerMaCode', lConfig.Get('powerMaCode',
            Integer(CMic185DefaultPowerMaCode)));
      finally
        lConfig.Free;
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
  J: Integer;
  K: Integer;
  lArray: TJSONArray;
  lAddress: string;
  lCapacity: Integer;
  lConfig: TJSONObject;
  lData: TJSONData;
  lEntry: TRecorderConfiguredDataSource;
  lHost: string;
  lItem: TJSONObject;
  lLink: TJSONObject;
  lLinks: TJSONArray;
  lMic185: TJSONObject;
  lMode: string;
  lPollHz: Double;
  lPort: Word;
  lSettings: TMic185ChannelProgramSettings;
  lSourceId: string;
  lTag: TRecorderTag;
  lTagName: string;
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
    lEntry := RecorderMic185EnsureConfiguredSource(ARegistry, lSourceId, lPollHz);
    lData := lItem.Find('mic185');
    if not (lData is TJSONObject) then
      Continue;
    lMic185 := TJSONObject(lData);
    lConfig := TJSONObject.Create;
    lData := lMic185.Find('channels');
    if lData is TJSONArray then
    begin
      lConfig.Add('channels', lData.Clone);
    end;
    lConfig.Add('powerMaCode', lMic185.Get('powerMaCode',
      Integer(CMic185DefaultPowerMaCode)));
    Mic185StoreSourceConfigObject(lEntry, lConfig);
    lConfig.Free;
    lData := lMic185.Find('tagLinks');
    if not (lData is TJSONArray) then
      Continue;
    lLinks := TJSONArray(lData);
    for J := 0 to lLinks.Count - 1 do
    begin
      if not (lLinks.Items[J] is TJSONObject) then
        Continue;
      lLink := TJSONObject(lLinks.Items[J]);
      lAddress := Trim(lLink.Get('address', ''));
      if lAddress = '' then
        Continue;
      lTagName := Trim(lLink.Get('tagName', lAddress));
      if lTagName = '' then
        lTagName := lAddress;
      lTag := nil;
      for K := 0 to ARegistry.TagCount - 1 do
        if SameText(ARegistry.Tags[K].SourceId, lSourceId) and
          SameText(ARegistry.Tags[K].Address, lAddress) then
        begin
          lTag := ARegistry.Tags[K];
          Break;
        end;
      if lTag = nil then
        lTag := ARegistry.FindByName(lTagName);
      if lTag = nil then
      begin
        lCapacity := Ceil(Max(4096, lPollHz * 4));
        lTag := ARegistry.CreateTag(lTagName, lCapacity);
      end;
      lTag.SourceId := lSourceId;
      lTag.Address := lAddress;
      lTag.ModuleType := CMic185ModuleName;
      lTag.PollFrequencyHz := lLink.Get('pollFrequencyHz', lPollHz);
      lMode := lLink.Get('sourceValueMode', '');
      if Trim(lMode) = '' then
        lMode := lTag.SourceValueMode;
      if (Trim(lMode) <> '') and
        (not RecorderMic185GetSourceChannelMode(ARegistry, lSourceId, lAddress,
          lTag.PollFrequencyHz, lSettings)) then
      begin
        RecorderMic185ReadChannelMode(lMode, lTag.PollFrequencyHz, lSettings);
        RecorderMic185SetSourceChannelMode(ARegistry, lSourceId, lAddress,
          lTag.PollFrequencyHz, lSettings);
      end;
      lTag.SourceValueMode := '';
      lTag.AutoRange := False;
      lTag.AutoUnit := False;
      lTag.Description := Format('%s channel %s', [CMic185ModuleName, lAddress]);
      if RecorderMic185ChannelAddressToIndex(lAddress) >= 0 then
      begin
        RecorderMic185GetSourceChannelMode(ARegistry, lSourceId, lAddress,
          lTag.PollFrequencyHz, lSettings);
        lTag.UnitName := RecorderMic185RangeUnitText(lSettings.MeasRangeIndex);
        lTag.RangeMax := RecorderMic185RangeMax(lSettings.MeasRangeIndex);
        lTag.RangeMin := -lTag.RangeMax;
      end
      else if Pos('-t', LowerCase(lAddress)) > 0 then
      begin
        lTag.UnitName := '°C';
        lTag.RangeMin := CMic185TempMinRangeC;
        lTag.RangeMax := CMic185TempMaxRangeC;
      end
      else
      begin
        lTag.UnitName := 's';
        lTag.RangeMin := 0;
        lTag.RangeMax := 0;
      end;
      lTag.EnsureBufferCapacity(Ceil(Max(4096, lTag.PollFrequencyHz * 4)));
    end;
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
  lPowerMaCode: LongWord;
  lSummary: string;
  lSettings: TMic185ChannelProgramSettingsArray;
  lTag: TRecorderTag;
begin
  if (fDevice = nil) or (not (fDevice.GetNativeObject is TRecorderMic185Device)) then
    Exit;
  lDevice := TRecorderMic185Device(fDevice.GetNativeObject);

  Mic185DefaultChannelProgramSettingsArray(fPollFrequencyHz, lSettings);
  lPowerMaCode := RecorderMic185GetSourcePowerMaCode(Registry, SourceId);
  for I := 0 to High(lSettings) do
    lSettings[I].PowerMaCode := lPowerMaCode;
  lSummary := '';

  if Registry <> nil then
    for I := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[I];
      if not SameText(lTag.SourceId, SourceId) then
        Continue;
      lIndex := RecorderMic185ChannelAddressToIndex(lTag.Address);
      if lIndex < 0 then
        Continue;
      RecorderMic185GetSourceChannelMode(Registry, SourceId, lTag.Address,
        lTag.PollFrequencyHz, lSettings[lIndex]);
      if lSettings[lIndex].FrequencyHz <= 0 then
        lSettings[lIndex].FrequencyHz := fPollFrequencyHz;
      lSettings[lIndex].Connected := True;
      lSettings[lIndex].PowerMaCode := lPowerMaCode;
      if lSummary <> '' then
        lSummary := lSummary + '; ';
      lSummary := lSummary + Format('ch%d range=%d commut=%d block=%d',
        [lIndex + 1, lSettings[lIndex].MeasRangeIndex,
         lSettings[lIndex].CommutIndex, lSettings[lIndex].BlockSize]);
    end;

  if lSummary <> '' then
    RecorderMic185Log(Format('ApplyChannelProgramSettings %s power=%d: %s',
      [SourceId, lPowerMaCode, lSummary]));
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
    lTag.SourceValueMode := '';
    if I < CMic185ChannelCountMax then
    begin
      RecorderMic185GetSourceChannelMode(ARegistry, SourceId,
        lChannels[I].Address, lChannels[I].PollFrequencyHz, lChannelSettings);
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
