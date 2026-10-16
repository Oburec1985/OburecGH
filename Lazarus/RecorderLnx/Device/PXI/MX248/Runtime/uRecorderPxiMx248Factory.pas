unit uRecorderPxiMx248Factory;

{
  Production composition entry for one configured MX-248 source. It creates
  the on-demand Win64-to-Win32 bridge transport, applies the persisted atomic
  property packet before Configure, and returns the generic datasource.

  No hardware stage runs during construction. The datasource worker later owns
  PrepareHardware/Start/Read/Stop. See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderDataSources, uRecorderConfiguredDataSources;

function RecorderCreatePxiMx248DataSource(
  AConfigured: TRecorderConfiguredDataSource; AUpdateTimeMs: Cardinal):
  IRecorderDataSource;

implementation

uses
  SysUtils, uRecorderDeviceInterfaces, uRecorderPxiMx248ConfiguredEditor,
  Classes, StrUtils, Variants, uRecorderPxiMx248Types,
  uRecorderPxiMx248Addressing,
  uRecorderPxiMx248RuntimeTransport, uRecorderPxiMx248WindowsTransport,
  uRecorderPxiMx248DeviceAdapter, uRecorderPxiMx248DataSource;

function IsAcquisitionProperty(const AName: string): Boolean;
var
  lChannel, lDot: Integer;
  lName, lSuffix: string;
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

function NormalizeAcquisitionProperties(AConfigured: TRecorderConfiguredDataSource;
  out AProperties: string): Boolean;
var
  I: Integer;
  lBlockSamples: Integer;
  lFormat: TFormatSettings;
  lRate: Double;
  lValues: TStringList;
begin
  Result := False;
  AProperties := '';
  lValues := TStringList.Create;
  try
    lValues.StrictDelimiter := True;
    lValues.Delimiter := ';';
    lValues.NameValueSeparator := '=';
    lValues.DelimitedText := AConfigured.SpecificConfigText;
    for I := lValues.Count - 1 downto 0 do
      if not IsAcquisitionProperty(lValues.Names[I]) then
        lValues.Delete(I);
    lFormat := DefaultFormatSettings;
    lFormat.DecimalSeparator := '.';
    lFormat.ThousandSeparator := #0;
    if not TryStrToFloat(lValues.Values['sample-rate-hz'], lRate, lFormat) or
      not PxiMx248IsSupportedSampleRate(lRate) then
    begin
      lValues.Values['sample-rate-hz'] :=
        IntToStr(CPxiMx248DefaultSampleRateHz);
      AConfigured.DefaultPollFrequencyHz := CPxiMx248DefaultSampleRateHz;
      Result := True;
    end;
    { 256 was an early bridge placeholder, not an MX-248 operator setting.
      Migrate it at startup so old projects do not perform ~400 synchronous
      bridge reads for every 200 ms Recorder update. }
    if not TryStrToInt(lValues.Values['block-samples'], lBlockSamples) or
      (lBlockSamples <= 256) then
    begin
      lValues.Values['block-samples'] := IntToStr(CPxiMx248DefaultBlockSamples);
      Result := True;
    end;
    AProperties := lValues.DelimitedText;
  finally
    lValues.Free;
  end;
end;

function RecorderCreatePxiMx248DataSource(
  AConfigured: TRecorderConfiguredDataSource; AUpdateTimeMs: Cardinal):
  IRecorderDataSource;
var
  lChassis, lSlot: Integer;
  lDevice: IRecorderDevice;
  lAdapter: TRcPxiMx248DeviceAdapter;
  lErrorText, lProperties: string;
  lMigrated: Boolean;
  lTransport: IPxiMx248BlockTransport;
  lAddressRule, lSourceAddress: string;
  lNormalized, lPersisted: TStringList;
  I: Integer;
begin
  Result := nil;
  if AConfigured = nil then Exit;
  if not TryParseRcMx248SourceId(AConfigured.SourceId,
    lChassis, lSlot) then
    raise ERecorderDataSourceError.Create('Invalid PXI MX-248 source id: ' +
      AConfigured.SourceId);
  lTransport := TRecorderPxiMx248WindowsTransport.Create(lChassis, lSlot);
  with TStringList.Create do
  try
    StrictDelimiter := True;
    Delimiter := ';';
    NameValueSeparator := '=';
    DelimitedText := AConfigured.SpecificConfigText;
    lAddressRule := PxiMx248NormalizeAddressRule(
      Values[CPxiMx248AddressRuleKey]);
  finally
    Free;
  end;
  lSourceAddress := Trim(AConfigured.SourceAddress);
  if (lSourceAddress <> '') and
    not SameText(lAddressRule, CPxiMx248AddressRuleManual) and
    SameText(lSourceAddress, PxiMx248DefaultSourceAddress(lChassis, lSlot,
      lAddressRule)) then
  begin
    lSourceAddress := PxiMx248DefaultSourceAddress(1, lChassis,
      lAddressRule);
    AConfigured.SourceAddress := lSourceAddress;
  end;
  if lSourceAddress = '' then
  begin
    lSourceAddress := PxiMx248DefaultSourceAddress(1, lChassis,
      lAddressRule);
    AConfigured.SourceAddress := lSourceAddress;
  end;
  lAdapter := TRcPxiMx248DeviceAdapter.Create(AConfigured.SourceId,
    CRcMx248ModuleType, lTransport, lSourceAddress);
  lDevice := lAdapter;
  lAdapter.LoadPxiSettings(AConfigured.SpecificConfigText);
  lMigrated := NormalizeAcquisitionProperties(AConfigured, lProperties);
  if (Trim(lProperties) <> '') and not lDevice.SetProp(lProperties) then
  begin
    lErrorText := VarToStr(lDevice.GetDeviceProperty(rdpErrorText));
    raise ERecorderDataSourceError.Create('Invalid PXI MX-248 configuration: ' +
      lErrorText);
  end;
  if lMigrated then
  begin
    { Preserve control-plane and future fields in persisted text; only repair
      the legacy unsupported frequency in place. }
    lPersisted := TStringList.Create;
    lNormalized := TStringList.Create;
    try
      lPersisted.StrictDelimiter := True;
      lPersisted.Delimiter := ';';
      lPersisted.NameValueSeparator := '=';
      lPersisted.DelimitedText := AConfigured.SpecificConfigText;
      lNormalized.StrictDelimiter := True;
      lNormalized.Delimiter := ';';
      lNormalized.NameValueSeparator := '=';
      lNormalized.DelimitedText := lProperties;
      for I := 0 to lNormalized.Count - 1 do
        lPersisted.Values[lNormalized.Names[I]] :=
          lNormalized.ValueFromIndex[I];
      AConfigured.SpecificConfigText := lPersisted.DelimitedText;
    finally
      lNormalized.Free;
      lPersisted.Free;
    end;
  end;
  Result := TRecorderPxiMx248DataSource.Create(AConfigured.SourceId,
    lDevice, AUpdateTimeMs);
end;

end.
