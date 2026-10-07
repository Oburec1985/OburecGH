unit uRecorderHardwareTagSettingsProviders;

{
  Device implementations of the common tag-settings capability. Device
  recognition, frequency scope and calibration details intentionally live
  here rather than in uTagSettingsDialog.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderDataSources, uRecorderTagSettingsProvider;

type
  TRecorderHardwareTagSettingsResolver = class(TInterfacedObject,
    IRecorderTagSettingsProviderResolver)
  private
    fProviders: TInterfaceList;
  public
    constructor Create;
    destructor Destroy; override;
    function Resolve(ATag: TRecorderTag; const ASource: IRecorderDataSource;
      out AProvider: IRecorderTagSettingsProvider): Boolean;
  end;

function CreateRecorderHardwareTagSettingsResolver:
  IRecorderTagSettingsProviderResolver;

implementation

uses
  Math, StrUtils,
  uRecorderConfiguredDataSources,
  uRecorderHardwareLiveDevices, uRecorderDeviceInterfaces,
  uRecorderMic140Utils, uRecorderMic140LegacyTiming,
  uRecorderMic140StreamTypes, uRecorderMic140DeviceConfig,
  uRecorderMic140DataSource, uRecorderMic140Calibration,
  uMic185MebiusTypes, uRecorderMic185DataSource, uRecorderMic185Calibration,
  uRecorderMc201Calibration;

type
  IRecorderHardwareTagSettingsProvider = interface(IRecorderTagSettingsProvider)
    ['{42949D96-928D-411C-827E-15CB5D333A49}']
    function Accepts(ATag: TRecorderTag): Boolean;
  end;

  TRecorderHardwareTagSettingsProvider = class(TInterfacedObject,
    IRecorderTagSettingsProvider, IRecorderHardwareTagSettingsProvider)
  public
    function Accepts(ATag: TRecorderTag): Boolean; virtual; abstract;
    function ReadState(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      out AState: TRecorderTagSettingsState): Boolean; virtual;
    function NormalizeDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean; virtual;
    function ApplyDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const ADraft: TRecorderTagSettingsDraft;
      out AResult: TRecorderTagSettingsApplyResult;
      out AErrorText: string): Boolean; virtual;
    function DownloadHardwareCalibration(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; out AResult: TRecorderHardwareCalibrationResult;
      out AErrorText: string): Boolean; virtual;
  end;

  TRecorderMic140TagSettingsProvider = class(TRecorderHardwareTagSettingsProvider)
  public
    function Accepts(ATag: TRecorderTag): Boolean; override;
    function ReadState(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      out AState: TRecorderTagSettingsState): Boolean; override;
    function NormalizeDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean; override;
    function ApplyDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const ADraft: TRecorderTagSettingsDraft;
      out AResult: TRecorderTagSettingsApplyResult;
      out AErrorText: string): Boolean; override;
    function DownloadHardwareCalibration(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; out AResult: TRecorderHardwareCalibrationResult;
      out AErrorText: string): Boolean; override;
  end;

  TRecorderMic185TagSettingsProvider = class(TRecorderHardwareTagSettingsProvider)
  public
    function Accepts(ATag: TRecorderTag): Boolean; override;
    function ReadState(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      out AState: TRecorderTagSettingsState): Boolean; override;
    function NormalizeDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean; override;
    function ApplyDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const ADraft: TRecorderTagSettingsDraft;
      out AResult: TRecorderTagSettingsApplyResult;
      out AErrorText: string): Boolean; override;
    function DownloadHardwareCalibration(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; out AResult: TRecorderHardwareCalibrationResult;
      out AErrorText: string): Boolean; override;
  end;

  TRecorderMc201TagSettingsProvider = class(TRecorderHardwareTagSettingsProvider)
  private
    function SlotFromAddress(const AAddress: string; out ASlot: Integer): Boolean;
    procedure ApplySlotFrequency(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; AFrequencyHz: Double);
  public
    function Accepts(ATag: TRecorderTag): Boolean; override;
    function ReadState(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      out AState: TRecorderTagSettingsState): Boolean; override;
    function ApplyDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const ADraft: TRecorderTagSettingsDraft;
      out AResult: TRecorderTagSettingsApplyResult;
      out AErrorText: string): Boolean; override;
    function DownloadHardwareCalibration(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; out AResult: TRecorderHardwareCalibrationResult;
      out AErrorText: string): Boolean; override;
  end;

var
  GTagSettingsResolverOwner: TObject;
  GTagSettingsResolver: IRecorderTagSettingsProviderResolver;

function TRecorderHardwareTagSettingsProvider.ReadState(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AState: TRecorderTagSettingsState): Boolean;
begin
  RecorderInitTagSettingsState(AState);
  Result := Accepts(ATag);
  AState.HardwareSourceConfigurable := Result;
end;

function TRecorderHardwareTagSettingsProvider.NormalizeDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean;
begin
  AErrorText := '';
  Result := Accepts(ATag);
end;

function TRecorderHardwareTagSettingsProvider.ApplyDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  const ADraft: TRecorderTagSettingsDraft;
  out AResult: TRecorderTagSettingsApplyResult;
  out AErrorText: string): Boolean;
begin
  RecorderInitTagSettingsApplyResult(AResult);
  AErrorText := '';
  Result := Accepts(ATag);
end;

function TRecorderHardwareTagSettingsProvider.DownloadHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AResult: TRecorderHardwareCalibrationResult;
  out AErrorText: string): Boolean;
begin
  RecorderInitHardwareCalibrationResult(AResult);
  AErrorText := 'Источник не поддерживает выгрузку аппаратной ГХ';
  Result := False;
end;

function TRecorderMic140TagSettingsProvider.Accepts(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and RecorderIsHardwareMic140TagSource(ATag.SourceId);
end;

function TRecorderMic140TagSettingsProvider.ReadState(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AState: TRecorderTagSettingsState): Boolean;
var
  lChannel: Integer;
  lSettings: TRecorderMic140ChannelSettings;
begin
  Result := inherited ReadState(ARegistry, ATag, AState);
  if not Result then Exit;
  AState.HardwareCalibrationDownloadable := True;
  AState.ChannelCalibrationSelectable := False;
  if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannel, lSettings) then
  begin
    if lSettings.ChannelCalibrationEnabled and
      RecorderMic140ChannelUsesTemperature(lSettings) then
      AState.OutputUnitName := RecorderMic140OutputModeUnitName(momTemperatureC)
    else if ATag.HardwareCalibrationEnabled then
      AState.OutputUnitName := RecorderMic140OutputModeUnitName(momMillivolts);
  end;
end;

function TRecorderMic140TagSettingsProvider.NormalizeDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean;
begin
  Result := inherited NormalizeDraft(ARegistry, ATag, ADraft, AErrorText);
  if Result then
    ADraft.PollFrequencyHz := RecorderMic140NormalizeFrequency(ADraft.PollFrequencyHz);
end;

function TRecorderMic140TagSettingsProvider.ApplyDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  const ADraft: TRecorderTagSettingsDraft;
  out AResult: TRecorderTagSettingsApplyResult;
  out AErrorText: string): Boolean;
var
  lChannel: Integer;
  lSettings: TRecorderMic140ChannelSettings;
begin
  Result := inherited ApplyDraft(ARegistry, ATag, ADraft, AResult, AErrorText);
  if not Result then Exit;
  if not SameValue(ATag.PollFrequencyHz, ADraft.PollFrequencyHz, 1E-9) then
  begin
    RecorderMic140ApplySourceFrequency(ARegistry, ATag.SourceId,
      ADraft.PollFrequencyHz);
    AResult.PollFrequencyHz := ADraft.PollFrequencyHz;
    AResult.FrequencyChanged := True;
  end;
  if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannel, lSettings) then
  begin
    lSettings.HardwareCalibrationEnabled := ADraft.HardwareCalibrationEnabled;
    lSettings.HardwareCalibrationName := ATag.HardwareCalibrationName;
    RecorderMic140UpdateChannelSettings(ARegistry, ATag, lSettings);
  end;
end;

function TRecorderMic140TagSettingsProvider.DownloadHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AResult: TRecorderHardwareCalibrationResult;
  out AErrorText: string): Boolean;
begin
  RecorderInitHardwareCalibrationResult(AResult);
  Result := RecorderMic140DownloadHardwareCalibrationFromDevice(ARegistry,
    ATag, AErrorText);
  if Result then
    AResult.CalibrationName := ATag.HardwareCalibrationName;
end;

function TRecorderMic185TagSettingsProvider.Accepts(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and RecorderIsHardwareMic185TagSource(ATag.SourceId);
end;

function TRecorderMic185TagSettingsProvider.ReadState(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AState: TRecorderTagSettingsState): Boolean;
var
  lSettings: TMic185ChannelProgramSettings;
begin
  Result := inherited ReadState(ARegistry, ATag, AState);
  if not Result then Exit;
  RecorderMic185LoadHardwareCalibrationForTag(ARegistry, ATag, False);
  RecorderMic185GetSourceChannelMode(ARegistry, ATag.SourceId, ATag.Address,
    ATag.PollFrequencyHz, lSettings);
  AState.HardwareCalibrationDownloadable := True;
  AState.SourceUnitName := RecorderMic185GetSourceChannelUnitName(ARegistry,
    ATag.SourceId, ATag.Address);
  if AState.SourceUnitName = '' then
    AState.SourceUnitName := RecorderMic185RangeUnitText(lSettings.MeasRangeIndex);
  AState.OutputUnitName := AState.SourceUnitName;
  AState.HardwareCalibrationText := RecorderMic185EffectiveTransformText(
    ARegistry, ATag, lSettings, ATag.UnitName);
  SetLength(AState.UnitNames, 3);
  AState.UnitNames[0] := 'мВ';
  AState.UnitNames[1] := 'Ом';
  AState.UnitNames[2] := 'мкстрн';
end;

function TRecorderMic185TagSettingsProvider.NormalizeDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean;
begin
  Result := inherited NormalizeDraft(ARegistry, ATag, ADraft, AErrorText);
  if Result then
    ADraft.PollFrequencyHz := RecorderMic185NormalizeFrequency(ADraft.PollFrequencyHz);
end;

function TRecorderMic185TagSettingsProvider.ApplyDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  const ADraft: TRecorderTagSettingsDraft;
  out AResult: TRecorderTagSettingsApplyResult;
  out AErrorText: string): Boolean;
var
  lRange: Double;
  lSettings: TMic185ChannelProgramSettings;
  lSourceUnit: string;
begin
  Result := inherited ApplyDraft(ARegistry, ATag, ADraft, AResult, AErrorText);
  if not Result then Exit;
  if not SameValue(ATag.PollFrequencyHz, ADraft.PollFrequencyHz, 1E-9) then
  begin
    RecorderMic185ApplySourceFrequency(ARegistry, ATag.SourceId,
      ADraft.PollFrequencyHz, ADraft.DataUpdateMs);
    AResult.PollFrequencyHz := ADraft.PollFrequencyHz;
    AResult.FrequencyChanged := True;
  end;
  lSourceUnit := Trim(ADraft.UnitName);
  if MatchText(lSourceUnit, ['мВ', 'мВ(тензо)', 'Ом', 'мкстрн', 'мкм/м']) then
  begin
    RecorderMic185SetSourceChannelUnitName(ARegistry, ATag.SourceId,
      ATag.Address, ADraft.PollFrequencyHz, lSourceUnit);
    AResult.SourceUnitName := lSourceUnit;
    AResult.SourceUnitChanged := True;
    if not ADraft.AutoUnit then
    begin
      AResult.UnitName := lSourceUnit;
      AResult.UnitChanged := True;
    end;
  end;
  if ADraft.HardwareCalibrationEnabled then
  begin
    RecorderMic185LoadHardwareCalibrationForTag(ARegistry, ATag, True);
    RecorderMic185GetSourceChannelMode(ARegistry, ATag.SourceId, ATag.Address,
      ADraft.PollFrequencyHz, lSettings);
    if SameText(ADraft.UnitName, 'код') or SameText(ADraft.UnitName, 'code') then
    begin
      AResult.UnitName := RecorderMic185GetSourceChannelUnitName(ARegistry,
        ATag.SourceId, ATag.Address);
      if AResult.UnitName = '' then
        AResult.UnitName := RecorderMic185RangeUnitText(lSettings.MeasRangeIndex);
      AResult.UnitChanged := True;
    end;
    lRange := RecorderMic185EffectiveRangeMaxForTag(ARegistry, ATag,
      lSettings, ADraft.UnitName);
    AResult.RangeMin := -lRange;
    AResult.RangeMax := lRange;
    AResult.RangeChanged := True;
  end;
  AResult.SignalHistoryMustBeCleared :=
    ATag.HardwareCalibrationEnabled <> ADraft.HardwareCalibrationEnabled;
end;

function TRecorderMic185TagSettingsProvider.DownloadHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AResult: TRecorderHardwareCalibrationResult;
  out AErrorText: string): Boolean;
var
  lB, lK: Double;
begin
  RecorderInitHardwareCalibrationResult(AResult);
  Result := RecorderMic185DownloadHardwareCalibrationFromDeviceEx(ARegistry,
    ATag, lK, lB, AResult.CalibrationName, AErrorText);
  if Result then
    AResult.PresentationText := RecorderMic185FormatHardwareKx(lK, lB);
end;

function TRecorderMc201TagSettingsProvider.Accepts(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and
    StartsText('MC-032:', RecorderNormalizeTagSourceId(ATag.SourceId));
end;

function TRecorderMc201TagSettingsProvider.SlotFromAddress(
  const AAddress: string; out ASlot: Integer): Boolean;
var
  lParts: TStringList;
begin
  ASlot := 0;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := '-';
    lParts.DelimitedText := Trim(AAddress);
    Result := (lParts.Count >= 2) and
      TryStrToInt(lParts[lParts.Count - 2], ASlot) and (ASlot > 0);
  finally
    lParts.Free;
  end;
end;

procedure TRecorderMc201TagSettingsProvider.ApplySlotFrequency(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag; AFrequencyHz: Double);
var
  lIndex, lSlot, lTagSlot: Integer;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or not SlotFromAddress(ATag.Address, lSlot) then Exit;
  for lIndex := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[lIndex];
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      RecorderNormalizeTagSourceId(ATag.SourceId)) and
      SlotFromAddress(lTag.Address, lTagSlot) and (lTagSlot = lSlot) then
      lTag.PollFrequencyHz := AFrequencyHz;
  end;
end;

function TRecorderMc201TagSettingsProvider.ReadState(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AState: TRecorderTagSettingsState): Boolean;
var
  lConfigured: TRecorderConfiguredDataSource;
begin
  Result := inherited ReadState(ARegistry, ATag, AState);
  if not Result then Exit;
  AState.HardwareCalibrationDownloadable := True;
  lConfigured := RecorderConfiguredDataSourcesFind(ARegistry, ATag.SourceId);
  if lConfigured <> nil then
    RecorderMc201LoadHardwareCalibrationForTag(ARegistry, ATag,
      lConfigured.SpecificConfigText);
end;

function TRecorderMc201TagSettingsProvider.ApplyDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  const ADraft: TRecorderTagSettingsDraft;
  out AResult: TRecorderTagSettingsApplyResult;
  out AErrorText: string): Boolean;
begin
  Result := inherited ApplyDraft(ARegistry, ATag, ADraft, AResult, AErrorText);
  if not Result then Exit;
  if not SameValue(ATag.PollFrequencyHz, ADraft.PollFrequencyHz, 1E-9) then
  begin
    ApplySlotFrequency(ARegistry, ATag, ADraft.PollFrequencyHz);
    AResult.PollFrequencyHz := ADraft.PollFrequencyHz;
    AResult.FrequencyChanged := True;
  end;
end;

function TRecorderMc201TagSettingsProvider.DownloadHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AResult: TRecorderHardwareCalibrationResult;
  out AErrorText: string): Boolean;
var
  lDevice: IRecorderDevice;
  lValues: TRecorderDeviceActionValues;
begin
  RecorderInitHardwareCalibrationResult(AResult);
  lDevice := RecorderHardwareFindLiveDevice(ATag.SourceId);
  if lDevice = nil then
  begin
    AErrorText := 'Нет активной сессии MC-032';
    Exit(False);
  end;
  Result := lDevice.ExecuteDeviceAction(rdaReadHardwareCalibration, [],
    lValues, AErrorText);
  if Result then
    AResult.CalibrationName := ATag.HardwareCalibrationName;
end;

constructor TRecorderHardwareTagSettingsResolver.Create;
begin
  inherited Create;
  fProviders := TInterfaceList.Create;
  fProviders.Add(TRecorderMic140TagSettingsProvider.Create as
    IRecorderHardwareTagSettingsProvider);
  fProviders.Add(TRecorderMic185TagSettingsProvider.Create as
    IRecorderHardwareTagSettingsProvider);
  fProviders.Add(TRecorderMc201TagSettingsProvider.Create as
    IRecorderHardwareTagSettingsProvider);
end;

destructor TRecorderHardwareTagSettingsResolver.Destroy;
begin
  fProviders.Free;
  inherited Destroy;
end;

function TRecorderHardwareTagSettingsResolver.Resolve(ATag: TRecorderTag;
  const ASource: IRecorderDataSource;
  out AProvider: IRecorderTagSettingsProvider): Boolean;
var
  lIndex: Integer;
  lProvider: IRecorderHardwareTagSettingsProvider;
begin
  AProvider := nil;
  for lIndex := 0 to fProviders.Count - 1 do
  begin
    lProvider := IRecorderHardwareTagSettingsProvider(fProviders[lIndex]);
    if lProvider.Accepts(ATag) then
    begin
      AProvider := IRecorderTagSettingsProvider(fProviders[lIndex]);
      Exit(True);
    end;
  end;
  Result := False;
end;

function CreateRecorderHardwareTagSettingsResolver:
  IRecorderTagSettingsProviderResolver;
begin
  Result := TRecorderHardwareTagSettingsResolver.Create;
end;

initialization
  GTagSettingsResolverOwner := TObject.Create;
  GTagSettingsResolver := CreateRecorderHardwareTagSettingsResolver;
  RegisterRecorderTagSettingsProviderResolver(GTagSettingsResolverOwner,
    GTagSettingsResolver);

finalization
  UnregisterRecorderTagSettingsProviderResolver(GTagSettingsResolverOwner);
  GTagSettingsResolver := nil;
  GTagSettingsResolverOwner.Free;

end.
