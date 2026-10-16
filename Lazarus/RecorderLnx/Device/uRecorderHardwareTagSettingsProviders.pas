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
  uRecorderMc201Calibration, uRecorderPxiMx248Types,
  uRecorderPxiMx248Addressing,
  uRecorderPxiMx248Properties,
  uRecorderDriverContractsV2, uRecorderPxiMx248RuntimeTransport,
  uRecorderPxiMx248WindowsTransport;

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

  { MX-248 has one ADC clock for all eight channels. The common tag dialog
    therefore edits the persisted source packet and every already published
    tag in place; replacing tag objects here would break external bindings. }
  TRecorderPxiMx248TagSettingsProvider = class(
    TRecorderHardwareTagSettingsProvider)
  private
    function ProgramSourceFrequency(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; AFrequencyHz: Double;
      out AErrorText: string): Boolean;
    procedure ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; AFrequencyHz: Double);
    function PersistSourceFrequency(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; AFrequencyHz: Double;
      out AErrorText: string): Boolean;
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
  lOriginalSourceUnit: string;
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
  lOriginalSourceUnit := RecorderMic185GetSourceChannelUnitName(ARegistry,
    ATag.SourceId, ATag.Address);
  lSourceUnit := Trim(ADraft.UnitName);
  if MatchText(lSourceUnit, ['мВ', 'мВ(тензо)', 'Ом', 'мкстрн', 'мкм/м']) and
    not SameText(lOriginalSourceUnit, lSourceUnit) then
  begin
    RecorderMic185SetSourceChannelUnitName(ARegistry, ATag.SourceId,
      ATag.Address, ADraft.PollFrequencyHz, lSourceUnit);
    AResult.SourceUnitName := lSourceUnit;
    AResult.SourceUnitChanged := True;
  end;
  if MatchText(lSourceUnit, ['мВ', 'мВ(тензо)', 'Ом', 'мкстрн', 'мкм/м']) and
    not ADraft.AutoUnit and not SameText(ATag.UnitName, lSourceUnit) then
  begin
    AResult.UnitName := lSourceUnit;
    AResult.UnitChanged := True;
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
    (ATag.HardwareCalibrationEnabled <> ADraft.HardwareCalibrationEnabled) or
    AResult.SourceUnitChanged or AResult.UnitChanged;
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

function TRecorderPxiMx248TagSettingsProvider.Accepts(
  ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and StartsText('pxi-mx248:',
    RecorderNormalizeTagSourceId(ATag.SourceId));
end;

function TRecorderPxiMx248TagSettingsProvider.ReadState(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AState: TRecorderTagSettingsState): Boolean;
var
  I: Integer;
begin
  Result := inherited ReadState(ARegistry, ATag, AState);
  if not Result then Exit;
  AState.FrequencyEditable := True;
  SetLength(AState.FrequencyNames, CPxiMx248SampleRateCount);
  for I := Low(CPxiMx248SampleRates) to High(CPxiMx248SampleRates) do
    AState.FrequencyNames[I] := IntToStr(CPxiMx248SampleRates[I]);
  AState.HardwareCalibrationDownloadable := True;
end;

function TRecorderPxiMx248TagSettingsProvider.NormalizeDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean;
begin
  Result := inherited NormalizeDraft(ARegistry, ATag, ADraft, AErrorText);
  if not Result then Exit;
  if PxiMx248IsSupportedSampleRate(ADraft.PollFrequencyHz) then Exit(True);
  AErrorText := Format('MX-248 does not support sample rate %g Hz',
    [ADraft.PollFrequencyHz]);
  Result := False;
end;

function IsPxiMx248AcquisitionProperty(const AName: string): Boolean;
var
  lName, lSuffix: string;
  lChannel, lDot: Integer;
begin
  lName := LowerCase(Trim(AName));
  if MatchText(lName, ['sample-rate-hz', 'block-samples',
    'calibration-mode']) then Exit(True);
  if Pos('channel.', lName) <> 1 then Exit(False);
  lSuffix := Copy(lName, Length('channel.') + 1, MaxInt);
  lDot := Pos('.', lSuffix);
  if (lDot <= 1) or not TryStrToInt(Copy(lSuffix, 1, lDot - 1), lChannel) or
    (lChannel < 1) or (lChannel > CPxiMx248ChannelCount) then Exit(False);
  lSuffix := Copy(lSuffix, lDot + 1, MaxInt);
  Result := MatchText(lSuffix, ['enabled', 'amplifier-enabled', 'input-mode',
    'range-index', 'lpf-index', 'icp-current', 'calibration-enabled',
    'input-floating']);
end;

function TRecorderPxiMx248TagSettingsProvider.ProgramSourceFrequency(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  AFrequencyHz: Double; out AErrorText: string): Boolean;
var
  lCanonical, lProperties, lSerial, lVersion: string;
  lConfigured: TRecorderConfiguredDataSource;
  lConfiguration: TPxiMx248Configuration;
  lFormat: TFormatSettings;
  lItems, lValues: TStringList;
  I, lChassis, lSlot: Integer;
  lResult: TRcOperationResult;
  lStore: TPxiMx248PropertyStore;
  lTransport: TRecorderPxiMx248WindowsTransport;
begin
  Result := False;
  AErrorText := '';
  lConfigured := RecorderConfiguredDataSourcesFind(ARegistry, ATag.SourceId);
  if lConfigured = nil then
  begin
    AErrorText := 'MX-248 configured source was not found';
    Exit;
  end;
  lItems := TStringList.Create;
  lValues := TStringList.Create;
  lStore := TPxiMx248PropertyStore.Create(nil);
  try
    lItems.StrictDelimiter := True;
    lItems.Delimiter := ':';
    lItems.DelimitedText := RecorderNormalizeTagSourceId(ATag.SourceId);
    if (lItems.Count <> 3) or not SameText(lItems[0], 'pxi-mx248') or
      not TryStrToInt(lItems[1], lChassis) or
      not TryStrToInt(lItems[2], lSlot) then
    begin
      AErrorText := 'Tag is not linked to a valid PXI MX-248 source';
      Exit;
    end;
    lValues.StrictDelimiter := True;
    lValues.Delimiter := ';';
    lValues.NameValueSeparator := '=';
    lValues.DelimitedText := lConfigured.SpecificConfigText;
    for I := lValues.Count - 1 downto 0 do
      if not IsPxiMx248AcquisitionProperty(lValues.Names[I]) then
        lValues.Delete(I);
    lFormat := DefaultFormatSettings;
    lFormat.DecimalSeparator := '.';
    lFormat.ThousandSeparator := #0;
    lValues.Values['sample-rate-hz'] := FloatToStr(AFrequencyHz, lFormat);
    lResult := lStore.CalcProperties(lValues.DelimitedText, lCanonical);
    if lResult.IsSuccess then
      lResult := lStore.CurrentConfiguration(lConfiguration);
    if not lResult.IsSuccess then
    begin
      AErrorText := lResult.Stage + ': ' + lResult.MessageText;
      Exit;
    end;
    lTransport := TRecorderPxiMx248WindowsTransport.Create(lChassis, lSlot);
    try
      lResult := lTransport.Connect;
      if lResult.IsSuccess then
        lResult := lTransport.Initialize(lSerial, lVersion);
      if lResult.IsSuccess then
        lResult := lTransport.ProgramAcquisition(lConfiguration);
      if lResult.IsSuccess then
        lResult := lTransport.ReadLiveProperties(lProperties);
      if not lResult.IsSuccess then
      begin
        AErrorText := lResult.Stage + ': ' + lResult.MessageText;
        Exit;
      end;
      lValues.DelimitedText := lProperties;
      if not SameText(Trim(lValues.Values['sample-rate-hz']),
        IntToStr(Round(AFrequencyHz))) then
      begin
        AErrorText := 'MX-248 readback did not confirm the requested frequency';
        Exit;
      end;
    finally
      lTransport.Disconnect;
      lTransport.Free;
    end;
    Result := True;
  finally
    lStore.Free;
    lValues.Free;
    lItems.Free;
  end;
end;

function TRecorderPxiMx248TagSettingsProvider.PersistSourceFrequency(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  AFrequencyHz: Double; out AErrorText: string): Boolean;
var
  lConfigured: TRecorderConfiguredDataSource;
  lFormat: TFormatSettings;
  lValues: TStringList;
begin
  Result := False;
  AErrorText := '';
  lConfigured := RecorderConfiguredDataSourcesFind(ARegistry, ATag.SourceId);
  if lConfigured = nil then
  begin
    AErrorText := 'MX-248 configured source was not found';
    Exit;
  end;
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  lFormat.ThousandSeparator := #0;
  lValues := TStringList.Create;
  try
    lValues.StrictDelimiter := True;
    lValues.Delimiter := ';';
    lValues.NameValueSeparator := '=';
    lValues.DelimitedText := lConfigured.SpecificConfigText;
    lValues.Values['sample-rate-hz'] := FloatToStr(AFrequencyHz, lFormat);
    lConfigured.SpecificConfigText := lValues.DelimitedText;
    lConfigured.DefaultPollFrequencyHz := AFrequencyHz;
  finally
    lValues.Free;
  end;
  Result := True;
end;

procedure TRecorderPxiMx248TagSettingsProvider.ApplySourceFrequency(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  AFrequencyHz: Double);
var
  I: Integer;
  lTag: TRecorderTag;
  lSourceId: string;
begin
  if (ARegistry = nil) or (ATag = nil) then Exit;
  lSourceId := RecorderNormalizeTagSourceId(ATag.SourceId);
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) then
      lTag.PollFrequencyHz := AFrequencyHz;
  end;
end;

function TRecorderPxiMx248TagSettingsProvider.ApplyDraft(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  const ADraft: TRecorderTagSettingsDraft;
  out AResult: TRecorderTagSettingsApplyResult;
  out AErrorText: string): Boolean;
begin
  Result := inherited ApplyDraft(ARegistry, ATag, ADraft, AResult, AErrorText);
  if not Result then Exit;
  if not PxiMx248IsSupportedSampleRate(ADraft.PollFrequencyHz) then
  begin
    AErrorText := Format('MX-248 does not support sample rate %g Hz',
      [ADraft.PollFrequencyHz]);
    Exit(False);
  end;
  if SameValue(ATag.PollFrequencyHz, ADraft.PollFrequencyHz, 1E-9) then
    Exit(True);
  if not ProgramSourceFrequency(ARegistry, ATag, ADraft.PollFrequencyHz,
    AErrorText) then Exit(False);
  if not PersistSourceFrequency(ARegistry, ATag, ADraft.PollFrequencyHz,
    AErrorText) then Exit(False);
  ApplySourceFrequency(ARegistry, ATag, ADraft.PollFrequencyHz);
  AResult.PollFrequencyHz := ADraft.PollFrequencyHz;
  AResult.FrequencyChanged := True;
end;

function TRecorderPxiMx248TagSettingsProvider.DownloadHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AResult: TRecorderHardwareCalibrationResult;
  out AErrorText: string): Boolean;
var
  lChannel: Integer;
  lDevice: IRecorderDevice;
  lControl: IPxiMx248LiveControlDevice;
  lItems, lValues: TStringList;
  lAdcSensitivity, lAmplifierSensitivity, lNominal: string;
  lConversionScale, lOutputUnit, lProperties: string;
  lResult: TRcOperationResult;
begin
  RecorderInitHardwareCalibrationResult(AResult);
  Result := False;
  AErrorText := '';
  if (ARegistry = nil) or (ATag = nil) or
    not PxiMx248TryChannelFromAddress(ATag.Address, lChannel) then
  begin
    AErrorText := 'MX-248 channel address must be 1..8';
    Exit;
  end;
  lItems := TStringList.Create;
  lValues := TStringList.Create;
  try
    lItems.StrictDelimiter := True;
    lItems.Delimiter := ':';
    lItems.DelimitedText := RecorderNormalizeTagSourceId(ATag.SourceId);
    if (lItems.Count <> 3) or not SameText(lItems[0], 'pxi-mx248') then
    begin
      AErrorText := 'Tag is not linked to a valid PXI MX-248 source';
      Exit;
    end;
    lDevice := RecorderHardwareFindLiveDevice(ATag.SourceId);
    if (lDevice = nil) or
      not Supports(lDevice, IPxiMx248LiveControlDevice, lControl) then
    begin
      AErrorText := 'Нет активной сессии MX-248';
      Exit;
    end;
    lResult := lControl.ReadLiveProperties(lProperties);
    if not lResult.IsSuccess then
    begin
      AErrorText := lResult.Stage + ': ' + lResult.MessageText;
      Exit;
    end;
    lValues.StrictDelimiter := True;
    lValues.Delimiter := ';';
    lValues.NameValueSeparator := '=';
    lValues.DelimitedText := lProperties;
    lAdcSensitivity := Trim(lValues.Values[
      Format('ch%d.adc-sensitivity', [lChannel])]);
    { Older bridge versions exposed this field under sensitivity. }
    if lAdcSensitivity = '' then
      lAdcSensitivity := Trim(lValues.Values[
        Format('ch%d.sensitivity', [lChannel])]);
    lNominal := Trim(lValues.Values[
      Format('ch%d.sensitivity-nominal', [lChannel])]);
    if (lAdcSensitivity = '') or (lNominal = '') then
    begin
      AErrorText := 'DevAPI did not return MX-248 sensitivity coefficients';
      Exit;
    end;
    lAmplifierSensitivity := Trim(lValues.Values[
      Format('ch%d.amplifier-sensitivity', [lChannel])]);
    lConversionScale := Trim(lValues.Values[
      Format('ch%d.conversion-scale', [lChannel])]);
    lOutputUnit := Trim(lValues.Values[
      Format('ch%d.output-unit', [lChannel])]);
    AResult.PresentationText := Format('adc-sensitivity=%s codes/V; ' +
      'sensitivity-nominal=%s', [lAdcSensitivity, lNominal]);
    if lAmplifierSensitivity <> '' then
      AResult.PresentationText := AResult.PresentationText +
        '; amplifier-sensitivity=' + lAmplifierSensitivity;
    if lConversionScale <> '' then
      AResult.PresentationText := AResult.PresentationText +
        '; conversion-scale=' + lConversionScale;
    if lOutputUnit <> '' then
      AResult.PresentationText := AResult.PresentationText +
        '; output-unit=' + lOutputUnit;
    AResult.MessageText := 'DevAPI уже применил аппаратную ГХ; значения ' +
      'приведены только для информации.';
    Result := True;
  finally
    lValues.Free;
    lItems.Free;
  end;
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
  fProviders.Add(TRecorderPxiMx248TagSettingsProvider.Create as
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
