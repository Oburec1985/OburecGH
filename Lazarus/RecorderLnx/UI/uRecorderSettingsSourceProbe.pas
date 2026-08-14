unit uRecorderSettingsSourceProbe;

{
  Каталог доступных аппаратных каналов по настроенным источникам данных.
  Владеет дескрипторами каналов (TMeraSignalInfo) для Mera file / MIC-140 / MIC-185.
  UI не хранит отдельные списки по типам устройств — только обращается сюда.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderTags, uMeraFile, uRecorderHardwareTree,
  uRecorderConfiguredDataSources, uRecorderMic140DeviceConfig,
  uRecorderMic140DataSource, uRecorderMic140StreamTypes;

type
  TRecorderSettingsSourceGroup = (
    rsgMeraFile,
    rsgMic140,
    rsgMic185,
    rsgMcbus
  );

  TRecorderSettingsSourceProbe = class
  private
    fRegistry: TRecorderTagRegistry;
    fMeraFolder: string;
    fMeraFilePath: string;
    fMeraSignals: TList;
    fMic140Signals: TList;
    fMic185Signals: TList;
    fMcbusSignals: TList;

    function GroupList(AGroup: TRecorderSettingsSourceGroup): TList;
    function MeraSourceIdForPath(const AFileName: string): string;
    function Mic140TagPollFrequency(const ASourceId, AAddress: string): Double;
    function Mic140PollFrequencyForChannel(const ASourceId: string;
      AChannelNumber: Integer): Double;
    function Mic140TagOutputModeForChannel(const ASourceId: string;
      AChannelNumber: Integer; out AMode: TRecorderMic140OutputMode): Boolean;
    procedure ApplyMeraTreeAddresses;
  public
    constructor Create(ARegistry: TRecorderTagRegistry);
    destructor Destroy; override;

    property Registry: TRecorderTagRegistry read fRegistry;
    property MeraFolder: string read fMeraFolder write fMeraFolder;
    property MeraFilePath: string read fMeraFilePath write fMeraFilePath;

    function GroupSignalCount(AGroup: TRecorderSettingsSourceGroup): Integer;
    function GroupSignal(AGroup: TRecorderSettingsSourceGroup;
      AIndex: Integer): TMeraSignalInfo;
    procedure ClearGroup(AGroup: TRecorderSettingsSourceGroup);
    procedure ClearAll;

    procedure LoadMeraFile(const AFileName: string);
    procedure ReloadMeraFile;
    procedure RemoveSourceSignals(const ASourceId: string);
    procedure BuildMic140(const ASourceId: string; AChannelCount: Integer;
      AEnabledChannels: TStrings;
      const AChannelSettings: array of TRecorderMic140ChannelSettings;
      ADeviceSerial: Integer = 0);
    procedure BuildMic185(const ASourceId: string);
    procedure BuildMcbus(const ASourceId, AModulesText: string;
      APollFrequencyHz: Double);
    procedure RestoreFromRegistry;
    procedure SyncToRegistry;
    procedure MarkSignalsFromRegistry;

    function FindTagBySourceAddress(const ASourceId,
      AAddress: string): TRecorderTag;
    function SignalSourceId(ASignal: TMeraSignalInfo): string;
    function SignalHasLinkedTag(ASignal: TMeraSignalInfo): Boolean;
  end;

implementation

uses
  uRecorderMic140Utils, uRecorderMic140LegacyTiming,
  uRecorderMic185DataSource, uMic185Constants, uRecorderMc032SettingsDialog,
  uRecorderMc201SlotSettingsDialog, uMc201ProtocolTypes;

function IsChannelEnabled(AEnabledChannels: TStrings; const AAddress: string): Boolean;
var
  I: Integer;
  lChanNumSrc, lChanNumDest: Integer;
begin
  Result := False;
  if (AEnabledChannels = nil) or (AEnabledChannels.Count = 0) then
    Exit(True);

  if AEnabledChannels.IndexOf(AAddress) >= 0 then
    Exit(True);

  if ParseMic140ChannelNumber(AAddress, lChanNumSrc) then
    for I := 0 to AEnabledChannels.Count - 1 do
      if ParseMic140ChannelNumber(AEnabledChannels[I], lChanNumDest) and
        (lChanNumSrc = lChanNumDest) then
        Exit(True);
end;

{ TRecorderSettingsSourceProbe }

constructor TRecorderSettingsSourceProbe.Create(ARegistry: TRecorderTagRegistry);
begin
  inherited Create;
  fRegistry := ARegistry;
  fMeraSignals := TList.Create;
  fMic140Signals := TList.Create;
  fMic185Signals := TList.Create;
  fMcbusSignals := TList.Create;
end;

destructor TRecorderSettingsSourceProbe.Destroy;
begin
  ClearAll;
  fMcbusSignals.Free;
  fMic185Signals.Free;
  fMic140Signals.Free;
  fMeraSignals.Free;
  inherited Destroy;
end;

function TRecorderSettingsSourceProbe.GroupList(AGroup: TRecorderSettingsSourceGroup): TList;
begin
  case AGroup of
    rsgMeraFile: Result := fMeraSignals;
    rsgMic140: Result := fMic140Signals;
    rsgMic185: Result := fMic185Signals;
  else Result := fMcbusSignals;
  end;
end;

function TRecorderSettingsSourceProbe.MeraSourceIdForPath(const AFileName: string): string;
begin
  Result := RecorderMeraFileTagSourceId(AFileName);
end;

function TRecorderSettingsSourceProbe.GroupSignalCount(
  AGroup: TRecorderSettingsSourceGroup): Integer;
begin
  Result := GroupList(AGroup).Count;
end;

function TRecorderSettingsSourceProbe.GroupSignal(AGroup: TRecorderSettingsSourceGroup;
  AIndex: Integer): TMeraSignalInfo;
begin
  Result := TMeraSignalInfo(GroupList(AGroup)[AIndex]);
end;

procedure TRecorderSettingsSourceProbe.ClearGroup(AGroup: TRecorderSettingsSourceGroup);
begin
  uMeraFile.ClearMeraSignals(GroupList(AGroup));
end;

procedure TRecorderSettingsSourceProbe.ClearAll;
begin
  ClearGroup(rsgMeraFile);
  ClearGroup(rsgMic140);
  ClearGroup(rsgMic185);
  ClearGroup(rsgMcbus);
  fMeraFilePath := '';
  fMeraFolder := '';
end;

procedure TRecorderSettingsSourceProbe.LoadMeraFile(const AFileName: string);
begin
  fMeraFolder := ExtractFilePath(AFileName);
  fMeraFilePath := AFileName;
  LoadMeraSignalsFromFile(AFileName, fMeraSignals);
  ApplyMeraTreeAddresses;
  if fRegistry <> nil then
    RecorderConfiguredDataSourcesEnsure(fRegistry, MeraSourceIdForPath(fMeraFilePath),
      'MC-201', 0);
  MarkSignalsFromRegistry;
end;

procedure TRecorderSettingsSourceProbe.ApplyMeraTreeAddresses;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lSourceId: string;
begin
  lSourceId := MeraSourceIdForPath(fMeraFilePath);
  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    lSignal.Address := RecorderTreeIndexedAddress(fRegistry, lSourceId,
      lSignal.Address, True);
  end;
end;

procedure TRecorderSettingsSourceProbe.ReloadMeraFile;
begin
  if fMeraFilePath = '' then
    Exit;
  if not FileExists(fMeraFilePath) then
    Exit;
  LoadMeraSignalsFromFile(fMeraFilePath, fMeraSignals);
  ApplyMeraTreeAddresses;
  MarkSignalsFromRegistry;
end;

procedure TRecorderSettingsSourceProbe.RemoveSourceSignals(const ASourceId: string);
var
  I: Integer;
  lList: TList;
  lSignal: TMeraSignalInfo;
  g: TRecorderSettingsSourceGroup;
begin
  for g := Low(TRecorderSettingsSourceGroup) to High(TRecorderSettingsSourceGroup) do
  begin
    lList := GroupList(g);
    for I := lList.Count - 1 downto 0 do
    begin
      lSignal := TMeraSignalInfo(lList[I]);
      if SameText(lSignal.FileName, ASourceId) then
      begin
        lSignal.Free;
        lList.Delete(I);
      end;
    end;
  end;
end;

function TRecorderSettingsSourceProbe.FindTagBySourceAddress(const ASourceId,
  AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if fRegistry = nil then
    Exit;
  for I := 0 to fRegistry.TagCount - 1 do
  begin
    lTag := fRegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) then
    begin
      { MIC-140 historically stores channel addresses both as 2-1 and 2-01.
        Treat both spellings as the same channel, otherwise a just-added tag
        remains visible in the available-channel grid. }
      if (Pos('MIC-140:', ASourceId) = 1) and
        SameMic140Address(lTag.Address, AAddress) then
        Exit(lTag);
      if (Pos('MIC-185:', ASourceId) = 1) and
        RecorderMic185SameChannelAddress(lTag.Address, AAddress) then
        Exit(lTag);
      if SameText(lTag.Address, AAddress) then
        Exit(lTag);
    end;
  end;
end;

function TRecorderSettingsSourceProbe.SignalSourceId(ASignal: TMeraSignalInfo): string;
begin
  if (ASignal <> nil) and (fMeraSignals.IndexOf(ASignal) >= 0) then
    Exit(MeraSourceIdForPath(fMeraFilePath));
  Result := RecorderSignalConfiguredSourceId(ASignal, MeraSourceIdForPath(fMeraFilePath));
end;

function TRecorderSettingsSourceProbe.SignalHasLinkedTag(ASignal: TMeraSignalInfo): Boolean;
begin
  Result := (ASignal <> nil) and
    (FindTagBySourceAddress(SignalSourceId(ASignal), ASignal.Address) <> nil);
end;

procedure TRecorderSettingsSourceProbe.MarkSignalsFromRegistry;
var
  I: Integer;
  g: TRecorderSettingsSourceGroup;
  lSignal: TMeraSignalInfo;
  lSourceId: string;
begin
  if fRegistry = nil then
    Exit;

  if fMeraFilePath <> '' then
  begin
    lSourceId := MeraSourceIdForPath(fMeraFilePath);
    fRegistry.RegisterActiveSource(lSourceId);
    for I := 0 to fMeraSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(fMeraSignals[I]);
      lSignal.Enabled := FindTagBySourceAddress(lSourceId, lSignal.Address) <> nil;
      lSignal.Selected := lSignal.Enabled;
    end;
  end;

  for g in [rsgMic140, rsgMic185, rsgMcbus] do
    for I := 0 to GroupSignalCount(g) - 1 do
    begin
      lSignal := GroupSignal(g, I);
      lSignal.Selected := SignalHasLinkedTag(lSignal);
    end;
end;

function TRecorderSettingsSourceProbe.Mic140TagPollFrequency(const ASourceId,
  AAddress: string): Double;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := MIC140DefaultPollFrequencyHz;
  if fRegistry = nil then
    Exit;
  for I := 0 to fRegistry.TagCount - 1 do
  begin
    lTag := fRegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) and SameMic140Address(lTag.Address, AAddress) and
      (lTag.PollFrequencyHz > 0) then
      Exit(RecorderMic140NormalizeFrequency(lTag.PollFrequencyHz));
  end;
end;

function TRecorderSettingsSourceProbe.Mic140PollFrequencyForChannel(const ASourceId: string;
  AChannelNumber: Integer): Double;
begin
  Result := Mic140TagPollFrequency(ASourceId,
    Format('%d-%2.2d', [RecorderMic140NodeNumberForSourceId(ASourceId),
      AChannelNumber]));
end;

function TRecorderSettingsSourceProbe.Mic140TagOutputModeForChannel(const ASourceId: string;
  AChannelNumber: Integer; out AMode: TRecorderMic140OutputMode): Boolean;
var
  I: Integer;
  lNum: Integer;
  lTag: TRecorderTag;
begin
  Result := False;
  AMode := momMillivolts;
  if fRegistry = nil then
    Exit;
  for I := 0 to fRegistry.TagCount - 1 do
  begin
    lTag := fRegistry.Tags[I];
    if not SameText(lTag.SourceId, ASourceId) then
      Continue;
    if ParseMic140ChannelNumber(lTag.Address, lNum) and (lNum = AChannelNumber) and
      (Trim(lTag.SourceValueMode) <> '') then
    begin
      AMode := RecorderMic140ConfigNameToOutputMode(lTag.SourceValueMode);
      Exit(True);
    end;
  end;
end;

procedure TRecorderSettingsSourceProbe.BuildMic140(const ASourceId: string;
  AChannelCount: Integer; AEnabledChannels: TStrings;
  const AChannelSettings: array of TRecorderMic140ChannelSettings;
  ADeviceSerial: Integer);
var
  I: Integer;
  lAddress: string;
  lDeviceNamePrefix: string;
  lDeviceSerial: Integer;
  lDummyMode: TRecorderMic140OutputMode;
  lFreqHz: Double;
  lHost: string;
  lOutputMode: TRecorderMic140OutputMode;
  lPort: Word;
  lNodeNumber: Integer;
  lSignal: TMeraSignalInfo;

  function Mic140DeviceNamePrefix: string;
  var
    lLastSeparator: Integer;
    lPrefixHost: string;
    lPrefixPort: Word;
  begin
    lPrefixHost := '';
    lPrefixPort := 0;
    if not ((fRegistry <> nil) and
      RecorderMic140ResolveEndpoint(fRegistry, ASourceId, lPrefixHost,
        lPrefixPort)) then
      TryParseRecorderMic140SourceId(ASourceId, lPrefixHost, lPrefixPort);
    lPrefixHost := Trim(lPrefixHost);
    if lPrefixHost = '' then
      lPrefixHost := 'unknown';
    lLastSeparator := LastDelimiter('.:', lPrefixHost);
    if lLastSeparator > 0 then
      lPrefixHost := Copy(lPrefixHost, lLastSeparator + 1, MaxInt);
    lPrefixHost := StringReplace(lPrefixHost, '.', '_', [rfReplaceAll]);
    lPrefixHost := StringReplace(lPrefixHost, ':', '_', [rfReplaceAll]);
    Result := '140-{' + lPrefixHost;
  end;

  procedure MigrateLinkedTagAddress(const AAddress: string);
  var
    lTag: TRecorderTag;
  begin
    lTag := FindTagBySourceAddress(ASourceId, AAddress);
    if (lTag <> nil) and (not SameText(lTag.Address, AAddress)) then
      lTag.Address := AAddress;
  end;
begin
  RemoveSourceSignals(ASourceId);

  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  if AChannelCount > MIC140DefaultChannelCount then
    AChannelCount := MIC140MaxChannelCount
  else
    AChannelCount := MIC140DefaultChannelCount;

  lDeviceSerial := ADeviceSerial;
  if (lDeviceSerial <= 0) and (fRegistry <> nil) then
    lDeviceSerial := RecorderMic140DeviceSerialForSource(fRegistry, ASourceId);
  if (lDeviceSerial <= 0) and TryParseRecorderMic140SourceId(ASourceId, lHost, lPort) then
  begin
    if lDeviceSerial <= 0 then
      RecorderMic140QueryHardwareCalibrSerial(lHost, lPort, lDeviceSerial);
  end;
  if (fRegistry <> nil) and RecorderMic140ResolveEndpoint(fRegistry, ASourceId,
    lHost, lPort) then
    lNodeNumber := RecorderMic140NodeNumberForHost(lHost)
  else
    lNodeNumber := RecorderMic140NodeNumberForSourceId(ASourceId);
  lDeviceNamePrefix := Mic140DeviceNamePrefix;

  for I := 1 to AChannelCount do
  begin
    lAddress := Format('%d-%2.2d', [lNodeNumber, I]);
    if not IsChannelEnabled(AEnabledChannels, lAddress) then
      Continue;
    MigrateLinkedTagAddress(lAddress);

    lOutputMode := momMillivolts;
    if (I <= Length(AChannelSettings)) and
      RecorderMic140ChannelUsesTemperature(AChannelSettings[I - 1]) then
      lOutputMode := momTemperatureC
    else
    begin
      lDummyMode := momMillivolts;
      if Mic140TagOutputModeForChannel(ASourceId, I, lDummyMode) then
        lOutputMode := lDummyMode;
    end;
    lFreqHz := Mic140PollFrequencyForChannel(ASourceId, I);

    lSignal := TMeraSignalInfo.Create;
    lSignal.Name := Format('%s-%d}', [lDeviceNamePrefix, I]);
    lSignal.Address := lAddress;
    lSignal.ModuleName := 'MIC-140';
    lSignal.DataTypeName := 'R8';
    lSignal.DataType := mvtFloat64;
    lSignal.FrequencyHz := lFreqHz;
    lSignal.UnitsName := RecorderMic140OutputModeUnitName(lOutputMode);
    lSignal.SourceValueMode := RecorderMic140OutputModeToConfigName(lOutputMode);
    lSignal.Description := Format('MIC-140 channel %s; mode=%s',
      [lAddress, RecorderMic140OutputModeToConfigName(lOutputMode)]);
    lSignal.FileName := ASourceId;
    lSignal.Enabled := True;
    lSignal.Selected := SignalHasLinkedTag(lSignal);
    fMic140Signals.Add(lSignal);
  end;

  for I := 1 to RecorderMic140VisibleTemperatureCount(1) do
  begin
    lAddress := RecorderMic140TemperatureAddressText(lNodeNumber, I);
    MigrateLinkedTagAddress(lAddress);
    lFreqHz := Mic140TagPollFrequency(ASourceId, lAddress);
    if lFreqHz <= 0 then
      lFreqHz := Mic140PollFrequencyForChannel(ASourceId, 1);

    lSignal := TMeraSignalInfo.Create;
    lSignal.Name := Format('%s-t%d}', [lDeviceNamePrefix, I]);
    lSignal.Address := lAddress;
    lSignal.ModuleName := 'MIC-140';
    lSignal.DataTypeName := 'R8';
    lSignal.DataType := mvtFloat64;
    lSignal.FrequencyHz := lFreqHz;
    lSignal.UnitsName := 'code';
    lSignal.SourceValueMode := '';
    lSignal.Description := Format('MIC-140 temperature channel %s code',
      [RecorderMic140TemperatureDisplayText(I, 1)]);
    lSignal.FileName := ASourceId;
    lSignal.Enabled := True;
    lSignal.Selected := SignalHasLinkedTag(lSignal);
    fMic140Signals.Add(lSignal);
  end;

  lAddress := RecorderMic140UtsAddressText(lNodeNumber);
  MigrateLinkedTagAddress(lAddress);
  lSignal := TMeraSignalInfo.Create;
  lSignal.Name := RecorderMic140UtsDisplayName(lNodeNumber);
  lSignal.Address := lAddress;
  lSignal.ModuleName := 'MIC-140';
  lSignal.DataTypeName := 'R8';
  lSignal.DataType := mvtFloat64;
  lSignal.FrequencyHz := 1.0;
  lSignal.UnitsName := 's';
  lSignal.SourceValueMode := '';
  lSignal.Description := 'MIC-140 UTS time channel';
  lSignal.FileName := ASourceId;
  lSignal.Enabled := True;
  lSignal.Selected := SignalHasLinkedTag(lSignal);
  fMic140Signals.Add(lSignal);
end;

procedure TRecorderSettingsSourceProbe.BuildMic185(const ASourceId: string);
var
  I: Integer;
  lDeviceIndex: Integer;
  lAddress: string;
  lFreqHz: Double;
  lSignal: TMeraSignalInfo;
begin
  RemoveSourceSignals(ASourceId);
  lDeviceIndex := RecorderMic185SourceDeviceIndex(fRegistry, ASourceId);

  for I := 1 to CMic185TotalLogicalChannelCount do
  begin
    if I <= CMic185ChannelCountMax then
    begin
      lAddress := Format('185-{%d-%d}', [lDeviceIndex, I]);
      lFreqHz := CMic185DefaultMeasFrequencyHz;
    end
    else if I <= CMic185ChannelCountMax + CMic185TempChannelCount then
    begin
      lAddress := Format('185-{%d-t%d}', [lDeviceIndex,
        I - CMic185ChannelCountMax]);
      lFreqHz := CMic185DefaultTempFrequencyHz;
    end
    else
    begin
      lAddress := Format('185-{%d-uts}', [lDeviceIndex]);
      lFreqHz := CMic185DefaultTempFrequencyHz;
    end;

    lSignal := TMeraSignalInfo.Create;
    lSignal.Name := lAddress;
    lSignal.Address := lAddress;
    lSignal.ModuleName := 'MIC183/185';
    lSignal.DataTypeName := 'R8';
    lSignal.DataType := mvtFloat64;
    lSignal.FrequencyHz := lFreqHz;
    if I <= CMic185ChannelCountMax then
      lSignal.UnitsName := 'мВ'
    else if I <= CMic185ChannelCountMax + CMic185TempChannelCount then
      lSignal.UnitsName := '°C'
    else
      lSignal.UnitsName := 'с';
    lSignal.Description := Format('MIC183/185 channel %s', [lAddress]);
    lSignal.FileName := ASourceId;
    lSignal.Enabled := True;
    lSignal.Selected := SignalHasLinkedTag(lSignal);
    fMic185Signals.Add(lSignal);
  end;
end;

procedure TRecorderSettingsSourceProbe.BuildMcbus(const ASourceId,
  AModulesText: string; APollFrequencyHz: Double);
var
  I, lChannel, lSlot: Integer;
  lCaptions: TStringList;
  lSerial, lVersion: string;
  lSignal: TMeraSignalInfo;
begin
  RecorderMc201RegisterFrequencyGrid(ASourceId,
    RecorderMc201BackplaneFromConfig(AModulesText));
  RemoveSourceSignals(ASourceId);
  if APollFrequencyHz <= 0 then
    APollFrequencyHz := CMc201DefaultSampleRateHz;
  lCaptions := TStringList.Create;
  try
    RecorderMc032ModuleCaptions(AModulesText, lCaptions);
    for I := 0 to lCaptions.Count - 1 do
    begin
      if not TryParseRecorderMc201ModuleCaption(lCaptions[I], lSlot,
        lSerial, lVersion) then
        Continue;
      for lChannel := 1 to 4 do
      begin
        lSignal := TMeraSignalInfo.Create;
        lSignal.Address := RecorderTreeIndexedAddress(fRegistry, ASourceId,
          Format('%d-%d', [lSlot, lChannel]), False);
        lSignal.Name := 'MC201_' + lSignal.Address;
        lSignal.ModuleName := 'MC-201';
        lSignal.DataTypeName := 'R8';
        lSignal.DataType := mvtFloat64;
        lSignal.FrequencyHz := APollFrequencyHz;
        { Без аппаратной ГХ публикуются сырые коды АЦП (как MIC-140/185). }
        lSignal.UnitsName := 'код';
        lSignal.Description := Format('MC-201 slot %d channel %d; SN=%s',
          [lSlot, lChannel, lSerial]);
        lSignal.FileName := ASourceId;
        lSignal.Enabled := True;
        lSignal.Selected := SignalHasLinkedTag(lSignal);
        fMcbusSignals.Add(lSignal);
      end;
    end;
  finally
    lCaptions.Free;
  end;
end;

procedure TRecorderSettingsSourceProbe.RestoreFromRegistry;
var
  I: Integer;
  lConfigured: TRecorderConfiguredDataSource;
  lConfig: TRecorderMic140SourceConfig;
  lHost: string;
  lPort: Word;
  lPath: string;
  lSourceId: string;
  lSourceIds: TStringList;
begin
  ClearAll;
  if fRegistry = nil then
    Exit;

  lSourceIds := TStringList.Create;
  try
    lSourceIds.CaseSensitive := False;
    lSourceIds.Sorted := False;
    RecorderEnumerateConfiguredSourceIds(fRegistry, lSourceIds, True);

    for I := 0 to lSourceIds.Count - 1 do
    begin
      lSourceId := lSourceIds[I];
      if RecorderIsVirtualTagSource(lSourceId) then
      begin
        lPath := RecorderMeraFileTagSourcePath(lSourceId);
        if lPath = '' then
          Continue;
        fMeraFolder := ExtractFilePath(lPath);
        fMeraFilePath := lPath;
        if FileExists(lPath) then
        begin
          LoadMeraSignalsFromFile(lPath, fMeraSignals);
          ApplyMeraTreeAddresses;
          MarkSignalsFromRegistry;
        end;
      end
      else if TryParseRecorderMic140SourceId(lSourceId, lHost, lPort) then
      begin
        lConfig := FindRecorderMic140DeviceConfig(fRegistry, lSourceId);
        if lConfig <> nil then
          BuildMic140(lSourceId, lConfig.ChannelCount, lConfig.SelectedChannels,
            lConfig.ChannelSettings, lConfig.DeviceSerial)
        else
          BuildMic140(lSourceId, MIC140DefaultChannelCount, nil, []);
      end
      else if TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
        BuildMic185(lSourceId)
      else if TryParseRecorderMc032SourceId(lSourceId, lHost, lPort) then
      begin
        lConfigured := RecorderConfiguredDataSourcesFind(fRegistry, lSourceId);
        if lConfigured <> nil then
          BuildMcbus(lSourceId, lConfigured.SpecificConfigText,
            lConfigured.DefaultPollFrequencyHz);
      end;
    end;
  finally
    lSourceIds.Free;
  end;
end;

procedure TRecorderSettingsSourceProbe.SyncToRegistry;
var
  I, J: Integer;
  g: TRecorderSettingsSourceGroup;
  lConfigured: TRecorderConfiguredDataSource;
  lDesired: TStringList;
  lExisting: TStringList;
  lHost: string;
  lPollHz: Double;
  lPort: Word;
  lSignal: TMeraSignalInfo;
  lSourceId: string;
  lUnique: TStringList;
begin
  if fRegistry = nil then
    Exit;

  lExisting := TStringList.Create;
  lDesired := TStringList.Create;
  lUnique := TStringList.Create;
  try
    lExisting.CaseSensitive := False;
    lDesired.CaseSensitive := False;
    lUnique.CaseSensitive := False;

    if fMeraFilePath <> '' then
      lDesired.Add(MeraSourceIdForPath(fMeraFilePath));
    for g in [rsgMic140, rsgMic185, rsgMcbus] do
      for I := 0 to GroupSignalCount(g) - 1 do
      begin
        lSignal := GroupSignal(g, I);
        lSourceId := RecorderNormalizeTagSourceId(lSignal.FileName);
        if (g = rsgMic140) and
          (not TryParseRecorderMic140SourceId(lSourceId, lHost, lPort)) then
          Continue;
        if (g = rsgMic185) and
          (not RecorderIsHardwareMic185TagSource(lSourceId)) then
          Continue;
        if (g = rsgMcbus) and
          (not TryParseRecorderMc032SourceId(lSourceId, lHost, lPort)) then
          Continue;
        if lDesired.IndexOf(lSourceId) < 0 then
          lDesired.Add(lSourceId);
      end;

    RecorderEnumerateConfiguredSourceIds(fRegistry, lExisting, False);
    for I := lExisting.Count - 1 downto 0 do
    begin
      { This probe owns only Mera, MIC-140 and MIC-185 lists. Never remove a
        configured source owned by another device adapter (for example
        MC-032/MCbus) merely because it has no signal group in this probe. }
      lConfigured := RecorderConfiguredDataSourcesFind(fRegistry, lExisting[I]);
      if (lConfigured <> nil) and
        (SameText(lConfigured.ModuleType, 'MIC-140') or
         SameText(lConfigured.ModuleType, 'MIC183/185') or
         SameText(lConfigured.ModuleType, 'MC-032') or
         RecorderIsVirtualTagSource(lConfigured.SourceId)) and
        RecorderHardwareTreeShowsSourceId(lExisting[I]) and
        (lDesired.IndexOf(lExisting[I]) < 0) then
        RecorderConfiguredDataSourcesRemove(fRegistry, lExisting[I]);
    end;

    if fMeraFilePath <> '' then
    begin
      lPollHz := 0;
      if fMeraSignals.Count > 0 then
        lPollHz := TMeraSignalInfo(fMeraSignals[0]).FrequencyHz;
      RecorderConfiguredDataSourcesEnsure(fRegistry, MeraSourceIdForPath(fMeraFilePath),
        'MC-201', lPollHz);
    end;

    for g in [rsgMic140, rsgMic185, rsgMcbus] do
    begin
      lUnique.Clear;
      for I := 0 to GroupSignalCount(g) - 1 do
      begin
        lSignal := GroupSignal(g, I);
        lSourceId := RecorderNormalizeTagSourceId(lSignal.FileName);
        if (g = rsgMic140) and (not TryParseRecorderMic140SourceId(lSourceId, lHost, lPort)) then
          Continue;
        if (g = rsgMic185) and (not RecorderIsHardwareMic185TagSource(lSourceId)) then
          Continue;
        if (g = rsgMcbus) and
          (not TryParseRecorderMc032SourceId(lSourceId, lHost, lPort)) then
          Continue;
        if lUnique.IndexOf(lSourceId) < 0 then
          lUnique.Add(lSourceId);
      end;
      for I := 0 to lUnique.Count - 1 do
      begin
        lSourceId := lUnique[I];
        lPollHz := 0;
        for J := 0 to GroupSignalCount(g) - 1 do
        begin
          lSignal := GroupSignal(g, J);
          if SameText(RecorderNormalizeTagSourceId(lSignal.FileName), lSourceId) then
          begin
            lPollHz := lSignal.FrequencyHz;
            Break;
          end;
        end;
        if g = rsgMic140 then
          lConfigured := RecorderConfiguredDataSourcesEnsure(fRegistry,
            lSourceId, 'MIC-140', lPollHz)
        else if g = rsgMic185 then
          lConfigured := RecorderConfiguredDataSourcesEnsure(fRegistry,
            lSourceId, 'MIC183/185', lPollHz)
        else
          lConfigured := RecorderConfiguredDataSourcesEnsure(fRegistry,
            lSourceId, 'MC-032', lPollHz);
        if (lConfigured <> nil) and (lConfigured.DefaultPollFrequencyHz <= 0) then
          lConfigured.DefaultPollFrequencyHz := lPollHz;
      end;
    end;
  finally
    lUnique.Free;
    lDesired.Free;
    lExisting.Free;
  end;
end;

end.
