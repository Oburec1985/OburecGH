unit uRecorderMic140DeviceConfig;

{
  Персистентные настройки MIC-140 на уровне источника данных (устройства).
  Аппаратные и поканальные параметры не хранятся в тегах — только в узле
  dataSources/mic140 проектного JSON, по аналогии с StoreSettings устройства
  в оригинальном Recorder/Mebius.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, fpjson,
  uRecorderTags, uRecorderMic140DataSource, uRecorderMic140Utils;

type
  TRecorderMic140DialogResult = record
    Host: string;
    Port: Word;
    ChannelCount: Integer;
    DeviceSerial: Integer;
    VersionText: string;
    ThermoCompensationEnabled: Boolean;
    SelectedChannels: TStringList;
    ChannelSettings: array of TRecorderMic140ChannelSettings;
  end;

  TRecorderMic140SourceConfig = class(TPersistent)
  public
    Host: string;
    Port: Word;
    ChannelCount: Integer;
    DeviceSerial: Integer;
    VersionText: string;
    ThermoCompensationEnabled: Boolean;
    SelectedChannels: TStringList;
    ChannelSettings: array of TRecorderMic140ChannelSettings;
    constructor Create;
    destructor Destroy; override;
    procedure EnsureChannelCapacity(ACount: Integer);
    function FindChannelIndex(const AAddress: string;
      out AChannelNumber: Integer): Integer;
    function TryGetChannelSettings(const AAddress: string;
      out AChannelNumber: Integer; out ASettings: TRecorderMic140ChannelSettings): Boolean;
    procedure SetChannelSettings(AChannelNumber: Integer;
      const AAddress: string; const ASettings: TRecorderMic140ChannelSettings);
    procedure LoadFromResult(const AResult: TRecorderMic140DialogResult);
    procedure SaveToResult(var AResult: TRecorderMic140DialogResult);
  end;

function RecorderMic140DeviceConfigList(
  ARegistry: TRecorderTagRegistry): TStringList;
function FindRecorderMic140DeviceConfig(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): TRecorderMic140SourceConfig;
function EnsureRecorderMic140DeviceConfig(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): TRecorderMic140SourceConfig;
function FindRecorderMic140SourceConfig(AList: TStrings;
  const ASourceId: string): TRecorderMic140SourceConfig;
function EnsureRecorderMic140SourceConfig(AList: TStrings;
  const ASourceId: string): TRecorderMic140SourceConfig;

function RecorderMic140TryGetChannelSettings(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; out AChannelNumber: Integer;
  out ASettings: TRecorderMic140ChannelSettings): Boolean;
function RecorderMic140DeviceSerialForSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Integer;
function RecorderMic140ThermoCompensationForSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;
function RecorderMic140TagHardwareCalibrationEnabled(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag): Boolean;
function RecorderMic140TagHardwareCalibrationName(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): string;

procedure RecorderMic140MigrateTagHardwareToDeviceConfig(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);
procedure RecorderMic140RebuildDeviceConfigsFromTags(ARegistry: TRecorderTagRegistry);
procedure SaveMic140DeviceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
procedure LoadMic140DeviceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);

implementation

uses
  Math, StrUtils, uRecorderMeraSdbThermocouples, uRecorderMic140LegacyConstants,
  uRecorderMic140StreamTypes;

{ TRecorderMic140SourceConfig }

constructor TRecorderMic140SourceConfig.Create;
begin
  inherited Create;
  SelectedChannels := TStringList.Create;
  ChannelCount := MIC140DefaultChannelCount;
  EnsureChannelCapacity(MIC140MaxChannelCount);
end;

destructor TRecorderMic140SourceConfig.Destroy;
begin
  SelectedChannels.Free;
  SetLength(ChannelSettings, 0);
  inherited Destroy;
end;

procedure TRecorderMic140SourceConfig.EnsureChannelCapacity(ACount: Integer);
var
  I: Integer;
begin
  if ACount <= Length(ChannelSettings) then
    Exit;
  SetLength(ChannelSettings, ACount);
  for I := 0 to ACount - 1 do
    RecorderMic140InitChannelSettings(ChannelSettings[I], I, CMic140Mic140SubRev1);
end;

function TRecorderMic140SourceConfig.FindChannelIndex(const AAddress: string;
  out AChannelNumber: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  AChannelNumber := 0;
  if ParseMic140ChannelNumber(AAddress, AChannelNumber) then
  begin
    if (AChannelNumber > 0) and (AChannelNumber <= Length(ChannelSettings)) then
      Exit(AChannelNumber - 1);
    Exit;
  end;
  for I := 0 to High(ChannelSettings) do
    if SameText(ChannelSettings[I].ChannelAddress, AAddress) then
      Exit(I);
end;

function TRecorderMic140SourceConfig.TryGetChannelSettings(const AAddress: string;
  out AChannelNumber: Integer; out ASettings: TRecorderMic140ChannelSettings): Boolean;
var
  lIndex: Integer;
begin
  Result := False;
  lIndex := FindChannelIndex(AAddress, AChannelNumber);
  if lIndex < 0 then
    Exit;
  ASettings := ChannelSettings[lIndex];
  Result := True;
end;

procedure TRecorderMic140SourceConfig.SetChannelSettings(AChannelNumber: Integer;
  const AAddress: string; const ASettings: TRecorderMic140ChannelSettings);
var
  lIndex: Integer;
begin
  if AChannelNumber <= 0 then
    Exit;
  EnsureChannelCapacity(AChannelNumber);
  lIndex := AChannelNumber - 1;
  ChannelSettings[lIndex] := ASettings;
  if Trim(AAddress) <> '' then
    ChannelSettings[lIndex].ChannelAddress := AAddress;
end;

procedure TRecorderMic140SourceConfig.LoadFromResult(
  const AResult: TRecorderMic140DialogResult);
var
  I: Integer;
begin
  Host := AResult.Host;
  Port := AResult.Port;
  ChannelCount := AResult.ChannelCount;
  DeviceSerial := AResult.DeviceSerial;
  VersionText := AResult.VersionText;
  ThermoCompensationEnabled := AResult.ThermoCompensationEnabled;
  SelectedChannels.Clear;
  if AResult.SelectedChannels <> nil then
    SelectedChannels.Assign(AResult.SelectedChannels);
  EnsureChannelCapacity(Length(AResult.ChannelSettings));
  for I := 0 to High(AResult.ChannelSettings) do
    ChannelSettings[I] := AResult.ChannelSettings[I];
end;

procedure TRecorderMic140SourceConfig.SaveToResult(
  var AResult: TRecorderMic140DialogResult);
var
  I: Integer;
begin
  AResult.Host := Host;
  AResult.Port := Port;
  AResult.ChannelCount := ChannelCount;
  AResult.DeviceSerial := DeviceSerial;
  AResult.VersionText := VersionText;
  AResult.ThermoCompensationEnabled := ThermoCompensationEnabled;
  if AResult.SelectedChannels <> nil then
  begin
    AResult.SelectedChannels.Clear;
    AResult.SelectedChannels.Assign(SelectedChannels);
  end;
  SetLength(AResult.ChannelSettings, Length(ChannelSettings));
  for I := 0 to High(ChannelSettings) do
    AResult.ChannelSettings[I] := ChannelSettings[I];
end;

function RecorderMic140DeviceConfigList(
  ARegistry: TRecorderTagRegistry): TStringList;
begin
  if ARegistry = nil then
    Result := nil
  else
    Result := ARegistry.Mic140DeviceConfigs;
end;

function FindRecorderMic140SourceConfig(AList: TStrings;
  const ASourceId: string): TRecorderMic140SourceConfig;
var
  lIndex: Integer;
begin
  Result := nil;
  if AList = nil then
    Exit;
  lIndex := AList.IndexOf(ASourceId);
  if lIndex >= 0 then
    Result := TRecorderMic140SourceConfig(AList.Objects[lIndex]);
end;

function EnsureRecorderMic140SourceConfig(AList: TStrings;
  const ASourceId: string): TRecorderMic140SourceConfig;
var
  lIndex: Integer;
begin
  Result := FindRecorderMic140SourceConfig(AList, ASourceId);
  if Result <> nil then
    Exit;
  Result := TRecorderMic140SourceConfig.Create;
  lIndex := AList.AddObject(ASourceId, Result);
  AList[lIndex] := ASourceId;
end;

function FindRecorderMic140DeviceConfig(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): TRecorderMic140SourceConfig;
begin
  Result := FindRecorderMic140SourceConfig(RecorderMic140DeviceConfigList(ARegistry),
    ASourceId);
end;

function EnsureRecorderMic140DeviceConfig(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): TRecorderMic140SourceConfig;
begin
  Result := EnsureRecorderMic140SourceConfig(RecorderMic140DeviceConfigList(ARegistry),
    ASourceId);
end;

function RecorderMic140TryGetChannelSettings(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; out AChannelNumber: Integer;
  out ASettings: TRecorderMic140ChannelSettings): Boolean;
var
  lConfig: TRecorderMic140SourceConfig;
begin
  Result := False;
  if (ATag = nil) or (not RecorderTagUsesMic140Settings(ATag)) then
    Exit;
  lConfig := FindRecorderMic140DeviceConfig(ARegistry, ATag.SourceId);
  if lConfig = nil then
    Exit;
  Result := lConfig.TryGetChannelSettings(ATag.Address, AChannelNumber, ASettings);
end;

function RecorderMic140DeviceSerialForSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Integer;
var
  lConfig: TRecorderMic140SourceConfig;
begin
  Result := 0;
  lConfig := FindRecorderMic140DeviceConfig(ARegistry, ASourceId);
  if lConfig <> nil then
    Result := lConfig.DeviceSerial;
end;

function RecorderMic140ThermoCompensationForSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;
var
  lConfig: TRecorderMic140SourceConfig;
begin
  Result := False;
  lConfig := FindRecorderMic140DeviceConfig(ARegistry, ASourceId);
  if lConfig <> nil then
    Result := lConfig.ThermoCompensationEnabled;
end;

function RecorderMic140TagHardwareCalibrationEnabled(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag): Boolean;
var
  lSettings: TRecorderMic140ChannelSettings;
  lChannelNumber: Integer;
begin
  if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
    lSettings) then
    Exit(lSettings.HardwareCalibrationEnabled);
  Result := False;
end;

function RecorderMic140TagHardwareCalibrationName(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): string;
var
  lSettings: TRecorderMic140ChannelSettings;
  lChannelNumber: Integer;
begin
  Result := '';
  if not RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
    lSettings) then
    Exit;
  Result := lSettings.HardwareCalibrationName;
end;

procedure RecorderMic140CopyLegacyTagFieldsToChannelSettings(
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
  if Trim(ATag.Address) <> '' then
    ASettings.ChannelAddress := ATag.Address;
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
  end
  else if ATag.CalibrationNames <> nil then
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
  lResolvedKey := RecorderMeraResolveThermocoupleScaleKey(
    ASettings.ThermocoupleScalePath, ASettings.ThermocoupleScaleName);
  if lResolvedKey <> '' then
    ASettings.ThermocoupleScalePath := lResolvedKey;
  if Trim(ATag.SourceValueMode) <> '' then
    ASettings.OutputMode := ATag.SourceValueMode;
  ASettings.ChannelCalibrationEnabled := ATag.ChannelCalibrationEnabled;
  ASettings.HardwareCalibrationEnabled := ATag.HardwareCalibrationEnabled;
  ASettings.HardwareCalibrationName := ATag.HardwareCalibrationName;
end;

procedure RecorderMic140MigrateTagHardwareToDeviceConfig(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);
var
  lChannelNumber: Integer;
  lConfig: TRecorderMic140SourceConfig;
  lSettings: TRecorderMic140ChannelSettings;
begin
  if (ARegistry = nil) or (ATag = nil) or
    (not RecorderTagUsesMic140Settings(ATag)) or
    (not ParseMic140ChannelNumber(ATag.Address, lChannelNumber)) then
    Exit;

  lConfig := EnsureRecorderMic140DeviceConfig(ARegistry, ATag.SourceId);
  if not TryParseRecorderMic140SourceId(ATag.SourceId, lConfig.Host, lConfig.Port) then
    Exit;
  if lConfig.DeviceSerial <= 0 then
    lConfig.DeviceSerial := ATag.Mic140DeviceSerial;
  lConfig.ThermoCompensationEnabled :=
    lConfig.ThermoCompensationEnabled or ATag.Mic140ThermoCompensationEnabled;
  if lChannelNumber > lConfig.ChannelCount then
    lConfig.ChannelCount := MIC140MaxChannelCount;
  if lConfig.SelectedChannels.IndexOf(IntToStr(lChannelNumber)) < 0 then
    lConfig.SelectedChannels.Add(IntToStr(lChannelNumber));

  RecorderMic140InitChannelSettings(lSettings, lChannelNumber - 1,
    CMic140Mic140SubRev1);
  lConfig.TryGetChannelSettings(ATag.Address, lChannelNumber, lSettings);
  RecorderMic140CopyLegacyTagFieldsToChannelSettings(ARegistry, ATag, lSettings);
  lConfig.SetChannelSettings(lChannelNumber, ATag.Address, lSettings);
  RecorderTagClearMic140Settings(ATag);
  ATag.HardwareCalibrationEnabled := False;
  ATag.HardwareCalibrationName := '';
end;

procedure RecorderMic140RebuildDeviceConfigsFromTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if RecorderTagUsesMic140Settings(lTag) then
      RecorderMic140MigrateTagHardwareToDeviceConfig(ARegistry, lTag);
  end;
end;

procedure SaveMic140ChannelSettingsJson(AJson: TJSONArray;
  const ASettings: TRecorderMic140ChannelSettings);
var
  lItem: TJSONObject;
begin
  lItem := TJSONObject.Create;
  AJson.Add(lItem);
  lItem.Add('address', ASettings.ChannelAddress);
  lItem.Add('rangeIndex', ASettings.RangeIndex);
  lItem.Add('softBalance', ASettings.SoftBalance);
  lItem.Add('defaultCjc', ASettings.DefaultCjc);
  lItem.Add('cjcChannel', ASettings.CjcChannel);
  lItem.Add('thermocoupleScaleName', ASettings.ThermocoupleScaleName);
  lItem.Add('thermocoupleScalePath', ASettings.ThermocoupleScalePath);
  lItem.Add('outputMode', ASettings.OutputMode);
  lItem.Add('channelCalibrationEnabled', ASettings.ChannelCalibrationEnabled);
  lItem.Add('hardwareCalibrationEnabled', ASettings.HardwareCalibrationEnabled);
  lItem.Add('hardwareCalibrationName', ASettings.HardwareCalibrationName);
  if ASettings.CjcTemperOffsetC <> 0.0 then
    lItem.Add('cjcTemperOffsetC', ASettings.CjcTemperOffsetC);
end;

procedure LoadMic140ChannelSettingsJson(AJson: TJSONObject;
  out ASettings: TRecorderMic140ChannelSettings);
begin
  RecorderMic140InitChannelSettings(ASettings, 0, CMic140Mic140SubRev1);
  ASettings.ChannelAddress := AJson.Get('address', ASettings.ChannelAddress);
  ASettings.RangeIndex := AJson.Get('rangeIndex', ASettings.RangeIndex);
  ASettings.SoftBalance := AJson.Get('softBalance', ASettings.SoftBalance);
  ASettings.DefaultCjc := AJson.Get('defaultCjc', ASettings.DefaultCjc);
  ASettings.CjcChannel := AJson.Get('cjcChannel', ASettings.CjcChannel);
  ASettings.ThermocoupleScaleName := AJson.Get('thermocoupleScaleName',
    ASettings.ThermocoupleScaleName);
  ASettings.ThermocoupleScalePath := AJson.Get('thermocoupleScalePath',
    ASettings.ThermocoupleScalePath);
  ASettings.OutputMode := AJson.Get('outputMode', ASettings.OutputMode);
  ASettings.ChannelCalibrationEnabled := AJson.Get('channelCalibrationEnabled',
    ASettings.ChannelCalibrationEnabled);
  ASettings.HardwareCalibrationEnabled := AJson.Get('hardwareCalibrationEnabled',
    ASettings.HardwareCalibrationEnabled);
  ASettings.HardwareCalibrationName := AJson.Get('hardwareCalibrationName',
    ASettings.HardwareCalibrationName);
  ASettings.CjcTemperOffsetC := AJson.Get('cjcTemperOffsetC',
    ASettings.CjcTemperOffsetC);
end;

procedure SaveMic140DeviceConfigJson(AItem: TJSONObject;
  AConfig: TRecorderMic140SourceConfig);
var
  I: Integer;
  lChannels: TJSONArray;
  lMic140: TJSONObject;
  lSelected: TJSONArray;
begin
  if (AItem = nil) or (AConfig = nil) then
    Exit;
  lMic140 := TJSONObject.Create;
  AItem.Add('mic140', lMic140);
  lMic140.Add('host', AConfig.Host);
  lMic140.Add('port', AConfig.Port);
  lMic140.Add('channelCount', AConfig.ChannelCount);
  lMic140.Add('deviceSerial', AConfig.DeviceSerial);
  lMic140.Add('versionText', AConfig.VersionText);
  lMic140.Add('thermoCompensationEnabled', AConfig.ThermoCompensationEnabled);
  lSelected := TJSONArray.Create;
  lMic140.Add('selectedChannels', lSelected);
  for I := 0 to AConfig.SelectedChannels.Count - 1 do
    lSelected.Add(AConfig.SelectedChannels[I]);
  lChannels := TJSONArray.Create;
  lMic140.Add('channels', lChannels);
  for I := 0 to High(AConfig.ChannelSettings) do
    if (Trim(AConfig.ChannelSettings[I].ChannelAddress) <> '') or
      (AConfig.ChannelSettings[I].SoftBalance <> 0) or
      (AConfig.ChannelSettings[I].RangeIndex <> CMic140Range100mV) or
      AConfig.ChannelSettings[I].HardwareCalibrationEnabled or
      AConfig.ChannelSettings[I].ChannelCalibrationEnabled or
      (Trim(AConfig.ChannelSettings[I].ThermocoupleScaleName) <> '') or
      (AConfig.ChannelSettings[I].CjcTemperOffsetC <> 0.0) then
      SaveMic140ChannelSettingsJson(lChannels, AConfig.ChannelSettings[I]);
end;

procedure LoadMic140DeviceConfigJson(AItem: TJSONObject;
  AConfig: TRecorderMic140SourceConfig);
var
  I: Integer;
  lAddress: string;
  lChannelNumber: Integer;
  lChannels: TJSONArray;
  lMic140: TJSONObject;
  lSelected: TJSONArray;
  lSettings: TRecorderMic140ChannelSettings;
begin
  if (AItem = nil) or (AConfig = nil) then
    Exit;
  if not (AItem.Find('mic140', lMic140) and (lMic140 is TJSONObject)) then
    Exit;
  lMic140 := TJSONObject(lMic140);
  AConfig.Host := lMic140.Get('host', AConfig.Host);
  AConfig.Port := lMic140.Get('port', AConfig.Port);
  AConfig.ChannelCount := lMic140.Get('channelCount', AConfig.ChannelCount);
  AConfig.DeviceSerial := lMic140.Get('deviceSerial', AConfig.DeviceSerial);
  AConfig.VersionText := lMic140.Get('versionText', AConfig.VersionText);
  AConfig.ThermoCompensationEnabled := lMic140.Get('thermoCompensationEnabled',
    AConfig.ThermoCompensationEnabled);
  if lMic140.Find('selectedChannels', lSelected) and (lSelected is TJSONArray) then
  begin
    lSelected := TJSONArray(lSelected);
    AConfig.SelectedChannels.Clear;
    for I := 0 to lSelected.Count - 1 do
      if lSelected.Items[I] is TJSONString then
        AConfig.SelectedChannels.Add(TJSONString(lSelected.Items[I]).AsString);
  end;
  if lMic140.Find('channels', lChannels) and (lChannels is TJSONArray) then
  begin
    lChannels := TJSONArray(lChannels);
    AConfig.EnsureChannelCapacity(Max(AConfig.ChannelCount, MIC140MaxChannelCount));
    for I := 0 to lChannels.Count - 1 do
    begin
      if not (lChannels.Items[I] is TJSONObject) then
        Continue;
      LoadMic140ChannelSettingsJson(TJSONObject(lChannels.Items[I]), lSettings);
      lAddress := lSettings.ChannelAddress;
      if ParseMic140ChannelNumber(lAddress, lChannelNumber) then
        AConfig.SetChannelSettings(lChannelNumber, lAddress, lSettings);
    end;
  end;
end;

procedure SaveMic140DeviceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lArray: TJSONArray;
  lConfig: TRecorderMic140SourceConfig;
  lItem: TJSONObject;
  lKnown: TStringList;
  lList: TStringList;
  lSourceId: string;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  lList := RecorderMic140DeviceConfigList(ARegistry);
  if (lList = nil) or (lList.Count = 0) then
    Exit;
  if not AJson.Find('dataSources', lArray) then
    Exit;
  if not (lArray is TJSONArray) then
    Exit;
  lArray := TJSONArray(lArray);
  lKnown := TStringList.Create;
  try
    lKnown.CaseSensitive := False;
    for I := 0 to lArray.Count - 1 do
    begin
      if not (lArray.Items[I] is TJSONObject) then
        Continue;
      lItem := TJSONObject(lArray.Items[I]);
      lSourceId := lItem.Get('sourceId', '');
      if lSourceId = '' then
        Continue;
      lConfig := FindRecorderMic140SourceConfig(lList, lSourceId);
      if lConfig = nil then
        Continue;
      SaveMic140DeviceConfigJson(lItem, lConfig);
      lKnown.Add(lSourceId);
    end;
    for I := 0 to lList.Count - 1 do
    begin
      lSourceId := lList[I];
      if lKnown.IndexOf(lSourceId) >= 0 then
        Continue;
      lConfig := FindRecorderMic140SourceConfig(lList, lSourceId);
      if lConfig = nil then
        Continue;
      lItem := TJSONObject.Create;
      lArray.Add(lItem);
      lItem.Add('sourceId', lSourceId);
      lItem.Add('moduleType', 'MIC-140');
      lItem.Add('defaultPollFrequencyHz', 0.0);
      SaveMic140DeviceConfigJson(lItem, lConfig);
    end;
  finally
    lKnown.Free;
  end;
end;

procedure LoadMic140DeviceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lArray: TJSONArray;
  lConfig: TRecorderMic140SourceConfig;
  lItem: TJSONObject;
  lSourceId: string;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  if not AJson.Find('dataSources', lArray) then
    Exit;
  if not (lArray is TJSONArray) then
    Exit;
  lArray := TJSONArray(lArray);
  for I := 0 to lArray.Count - 1 do
  begin
    if not (lArray.Items[I] is TJSONObject) then
      Continue;
    lItem := TJSONObject(lArray.Items[I]);
    lSourceId := lItem.Get('sourceId', '');
    if not RecorderIsHardwareMic140TagSource(lSourceId) then
      Continue;
    lConfig := EnsureRecorderMic140DeviceConfig(ARegistry, lSourceId);
    if not TryParseRecorderMic140SourceId(lSourceId, lConfig.Host, lConfig.Port) then
      Continue;
    LoadMic140DeviceConfigJson(lItem, lConfig);
  end;
end;

procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
var
  I: Integer;
begin
  AResult.Host := MIC140DefaultHost;
  AResult.Port := MIC140DefaultPort;
  AResult.ChannelCount := MIC140DefaultChannelCount;
  AResult.DeviceSerial := 0;
  AResult.VersionText := '';
  AResult.ThermoCompensationEnabled := False;
  AResult.SelectedChannels := TStringList.Create;
  SetLength(AResult.ChannelSettings, MIC140MaxChannelCount);
  for I := 0 to High(AResult.ChannelSettings) do
    RecorderMic140InitChannelSettings(AResult.ChannelSettings[I], I,
      CMic140Mic140SubRev1);
end;

procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
begin
  FreeAndNil(AResult.SelectedChannels);
  SetLength(AResult.ChannelSettings, 0);
end;

end.
