unit uRecorderTagSettingsProvider;

{
  UI-neutral extension point for device-specific tag settings.

  The tag settings dialog resolves a provider for a tag and delegates device
  rules to it. A datasource may implement IRecorderTagSettingsProvider itself;
  providers which do not belong to a live datasource are exposed by a
  registered resolver. Device names and source-id formats remain outside UI.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderDataSources;

type
  TRecorderStringArray = array of string;

  { Values displayed by the common dialog. Empty strings mean that the common
    tag/calibration model should supply the value. }
  TRecorderTagSettingsState = record
    FrequencyEditable: Boolean;
    HardwareSourceConfigurable: Boolean;
    HardwareCalibrationDownloadable: Boolean;
    ChannelCalibrationSelectable: Boolean;
    HardwareCalibrationText: string;
    OutputUnitName: string;
    SourceUnitName: string;
    FrequencyNames: TRecorderStringArray;
    UnitNames: TRecorderStringArray;
  end;

  { Common dialog values offered to a provider before commit. A provider may
    normalize related values, then ApplyDraft persists only device-owned state.
    Generic tag fields remain owned by the common dialog. }
  TRecorderTagSettingsDraft = record
    PollFrequencyHz: Double;
    UnitName: string;
    AutoUnit: Boolean;
    HardwareCalibrationEnabled: Boolean;
    ChannelCalibrationEnabled: Boolean;
    DataUpdateMs: Cardinal;
  end;

  TRecorderTagSettingsApplyResult = record
    UnitName: string;
    SourceUnitName: string;
    PollFrequencyHz: Double;
    RangeMin: Double;
    RangeMax: Double;
    UnitChanged: Boolean;
    SourceUnitChanged: Boolean;
    FrequencyChanged: Boolean;
    RangeChanged: Boolean;
    SignalHistoryMustBeCleared: Boolean;
  end;

  TRecorderHardwareCalibrationResult = record
    CalibrationName: string;
    PresentationText: string;
    MessageText: string;
  end;

  { Implemented by a concrete datasource or a device provider. Methods never
    show UI. Registry and tag ownership stays with the caller. }
  IRecorderTagSettingsProvider = interface
    ['{8C160195-8B74-4CF7-9D5E-3D40C48764B1}']
    function ReadState(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      out AState: TRecorderTagSettingsState): Boolean;
    function NormalizeDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      var ADraft: TRecorderTagSettingsDraft; out AErrorText: string): Boolean;
    function ApplyDraft(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const ADraft: TRecorderTagSettingsDraft;
      out AResult: TRecorderTagSettingsApplyResult;
      out AErrorText: string): Boolean;
    function DownloadHardwareCalibration(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag; out AResult: TRecorderHardwareCalibrationResult;
      out AErrorText: string): Boolean;
  end;

  { Resolver is useful when settings support is separate from the datasource.
    It must only identify a provider; device I/O belongs to the provider. }
  IRecorderTagSettingsProviderResolver = interface
    ['{F71FD84D-BBD6-47A7-B44A-6B2DA993E6F2}']
    function Resolve(ATag: TRecorderTag;
      const ASource: IRecorderDataSource;
      out AProvider: IRecorderTagSettingsProvider): Boolean;
  end;

procedure RecorderInitTagSettingsState(out AState: TRecorderTagSettingsState);
procedure RecorderInitTagSettingsDraft(ATag: TRecorderTag;
  ADataUpdateMs: Cardinal; out ADraft: TRecorderTagSettingsDraft);
procedure RecorderInitTagSettingsApplyResult(
  out AResult: TRecorderTagSettingsApplyResult);
procedure RecorderInitHardwareCalibrationResult(
  out AResult: TRecorderHardwareCalibrationResult);

procedure RegisterRecorderTagSettingsProviderResolver(AOwner: TObject;
  const AResolver: IRecorderTagSettingsProviderResolver);
procedure UnregisterRecorderTagSettingsProviderResolver(AOwner: TObject);
function RecorderResolveTagSettingsProvider(ATag: TRecorderTag;
  ADataSources: TRecorderDataSourceManager;
  out AProvider: IRecorderTagSettingsProvider): Boolean;

implementation

type
  TRecorderTagSettingsResolverEntry = record
    Owner: TObject;
    Resolver: IRecorderTagSettingsProviderResolver;
  end;

var
  GResolverLock: TRTLCriticalSection;
  GResolvers: array of TRecorderTagSettingsResolverEntry;

procedure RecorderInitTagSettingsState(out AState: TRecorderTagSettingsState);
begin
  AState.FrequencyEditable := True;
  AState.HardwareSourceConfigurable := False;
  AState.HardwareCalibrationDownloadable := False;
  AState.ChannelCalibrationSelectable := True;
  AState.HardwareCalibrationText := '';
  AState.OutputUnitName := '';
  AState.SourceUnitName := '';
  SetLength(AState.FrequencyNames, 0);
  SetLength(AState.UnitNames, 0);
end;

procedure RecorderInitTagSettingsDraft(ATag: TRecorderTag;
  ADataUpdateMs: Cardinal; out ADraft: TRecorderTagSettingsDraft);
begin
  ADraft.PollFrequencyHz := 0;
  ADraft.UnitName := '';
  ADraft.AutoUnit := False;
  ADraft.HardwareCalibrationEnabled := False;
  ADraft.ChannelCalibrationEnabled := False;
  ADraft.DataUpdateMs := ADataUpdateMs;
  if ATag = nil then
    Exit;
  ADraft.PollFrequencyHz := ATag.PollFrequencyHz;
  ADraft.UnitName := ATag.UnitName;
  ADraft.AutoUnit := ATag.AutoUnit;
  ADraft.HardwareCalibrationEnabled := ATag.HardwareCalibrationEnabled;
  ADraft.ChannelCalibrationEnabled := ATag.ChannelCalibrationEnabled;
end;

procedure RecorderInitTagSettingsApplyResult(
  out AResult: TRecorderTagSettingsApplyResult);
begin
  AResult.UnitName := '';
  AResult.SourceUnitName := '';
  AResult.PollFrequencyHz := 0;
  AResult.RangeMin := 0;
  AResult.RangeMax := 0;
  AResult.UnitChanged := False;
  AResult.SourceUnitChanged := False;
  AResult.FrequencyChanged := False;
  AResult.RangeChanged := False;
  AResult.SignalHistoryMustBeCleared := False;
end;

procedure RecorderInitHardwareCalibrationResult(
  out AResult: TRecorderHardwareCalibrationResult);
begin
  AResult.CalibrationName := '';
  AResult.PresentationText := '';
  AResult.MessageText := '';
end;

function FindResolverOwner(AOwner: TObject): Integer;
var
  lIndex: Integer;
begin
  for lIndex := 0 to High(GResolvers) do
    if GResolvers[lIndex].Owner = AOwner then
      Exit(lIndex);
  Result := -1;
end;

procedure DeleteResolver(AIndex: Integer);
var
  lIndex: Integer;
begin
  for lIndex := AIndex to High(GResolvers) - 1 do
    GResolvers[lIndex] := GResolvers[lIndex + 1];
  if Length(GResolvers) > 0 then
  begin
    GResolvers[High(GResolvers)].Resolver := nil;
    GResolvers[High(GResolvers)].Owner := nil;
    SetLength(GResolvers, Length(GResolvers) - 1);
  end;
end;

procedure RegisterRecorderTagSettingsProviderResolver(AOwner: TObject;
  const AResolver: IRecorderTagSettingsProviderResolver);
var
  lIndex: Integer;
begin
  if AOwner = nil then
    raise EArgumentNilException.Create('Tag settings resolver owner is nil');
  EnterCriticalSection(GResolverLock);
  try
    lIndex := FindResolverOwner(AOwner);
    if AResolver = nil then
    begin
      if lIndex >= 0 then
        DeleteResolver(lIndex);
      Exit;
    end;
    if lIndex < 0 then
    begin
      lIndex := Length(GResolvers);
      SetLength(GResolvers, lIndex + 1);
      GResolvers[lIndex].Owner := AOwner;
    end;
    GResolvers[lIndex].Resolver := AResolver;
  finally
    LeaveCriticalSection(GResolverLock);
  end;
end;

procedure UnregisterRecorderTagSettingsProviderResolver(AOwner: TObject);
begin
  RegisterRecorderTagSettingsProviderResolver(AOwner, nil);
end;

function SnapshotResolvers: TInterfaceList;
var
  lIndex: Integer;
begin
  Result := TInterfaceList.Create;
  EnterCriticalSection(GResolverLock);
  try
    for lIndex := 0 to High(GResolvers) do
      Result.Add(GResolvers[lIndex].Resolver);
  finally
    LeaveCriticalSection(GResolverLock);
  end;
end;

function RecorderResolveTagSettingsProvider(ATag: TRecorderTag;
  ADataSources: TRecorderDataSourceManager;
  out AProvider: IRecorderTagSettingsProvider): Boolean;
var
  lIndex: Integer;
  lResolver: IRecorderTagSettingsProviderResolver;
  lResolvers: TInterfaceList;
  lSource: IRecorderDataSource;
begin
  AProvider := nil;
  if ATag = nil then
    Exit(False);

  lSource := nil;
  if ADataSources <> nil then
    lSource := ADataSources.FindSource(ATag.SourceId);
  if (lSource <> nil) and
    Supports(lSource, IRecorderTagSettingsProvider, AProvider) then
    Exit(True);

  lResolvers := SnapshotResolvers;
  try
    for lIndex := lResolvers.Count - 1 downto 0 do
    begin
      lResolver := IRecorderTagSettingsProviderResolver(lResolvers[lIndex]);
      if lResolver.Resolve(ATag, lSource, AProvider) and (AProvider <> nil) then
        Exit(True);
      AProvider := nil;
    end;
  finally
    lResolvers.Free;
  end;
  Result := False;
end;

initialization
  InitCriticalSection(GResolverLock);

finalization
  { Program shutdown is single-threaded here. Release provider interfaces
    outside the lock: their destructors may unregister related services. }
  SetLength(GResolvers, 0);
  DoneCriticalSection(GResolverLock);

end.
