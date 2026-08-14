unit uRecorderRuntimeSourceFactory;

{
  Композиция runtime-источников RecorderLnx.

  Этот модуль является границей между универсальной оболочкой приложения и
  реализациями устройств. UI передаёт модель Recorder и получает полностью
  собранный TRecorderDataSourceManager, не зная типов MIC/MCbus.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, uRecorder;

type
  TRecorderRuntimeSourceLogEvent = procedure(const AMessage: string) of object;

procedure RecorderBuildRuntimeSources(ARecorder: TRecorder;
  ADataUpdateMs: Cardinal; ALog: TRecorderRuntimeSourceLogEvent = nil);
procedure RecorderReplaceRuntimeSource(ARecorder: TRecorder;
  const ASourceId: string; ADataUpdateMs: Cardinal;
  ALog: TRecorderRuntimeSourceLogEvent = nil;
  APrepareNow: Boolean = True);

implementation

uses
  SysUtils, Math, uRecorderTags, uRecorderDataSources,
  uRecorderConfiguredDataSources, uRecorderMic140DataSource,
  uRecorderMic140StreamTypes, uRecorderMic140DeviceConfig,
  uRecorderMic140Utils, uRecorderMic185DataSource, uRecorderMcbusDataSource;

const
  CMeraSourcePrefix = 'Mera file: ';

procedure Log(ALog: TRecorderRuntimeSourceLogEvent; const AText: string);
begin
  if Assigned(ALog) then
    ALog(AText);
end;

procedure FreeGroupedLists(AList: TStringList);
var
  I: Integer;
begin
  if AList = nil then
    Exit;
  for I := 0 to AList.Count - 1 do
    AList.Objects[I].Free;
  AList.Free;
end;

function EnsureGroup(AList: TStringList; const AKey: string): TStringList;
var
  lIndex: Integer;
begin
  lIndex := AList.IndexOf(AKey);
  if lIndex < 0 then
  begin
    Result := TStringList.Create;
    Result.CaseSensitive := False;
    AList.AddObject(AKey, Result);
  end
  else
    Result := TStringList(AList.Objects[lIndex]);
end;

function RecorderMic140TagDefinesScanFrequency(ATag: TRecorderTag): Boolean;
var
  lChannelNumber: Integer;
begin
  Result := (ATag <> nil) and (ATag.PollFrequencyHz > 0) and
    (not RecorderMic140IsUtsAddress(ATag.Address)) and
    (Pos('diagnostics.', LowerCase(Trim(ATag.Address))) <> 1) and
    ParseMic140ChannelNumber(ATag.Address, lChannelNumber);
end;

procedure RecorderBuildRuntimeSources(ARecorder: TRecorder;
  ADataUpdateMs: Cardinal; ALog: TRecorderRuntimeSourceLogEvent);
var
  I: Integer;
  lChannelCount: Integer;
  lChannelNumber: Integer;
  lConfigured: TRecorderConfiguredDataSource;
  lFileName: string;
  lFiles: TStringList;
  lHost: string;
  lMicOutputMode: TRecorderMic140OutputMode;
  lMicSources: TStringList;
  lMic185Sources: TStringList;
  lMcbusSources: TStringList;
  lPollFrequencyHz: Double;
  lPort: Word;
  lSource: IRecorderDataSource;
  lSpecificConfigText: string;
  lTag: TRecorderTag;
  lTagNames: TStringList;
  J: Integer;
begin
  if (ARecorder = nil) or (ARecorder.DataSources = nil) or
    (ARecorder.TagRegistry = nil) then
    Exit;
  if ADataUpdateMs = 0 then
    ADataUpdateMs := 300;

  ARecorder.DataSources.Clear;
  lSource := TRecorderDiagnosticsDataSource.Create('debug.diagnostics',
    ADataUpdateMs, 'MemTag', 'CpuUsage');
  ARecorder.DataSources.AddSource(lSource);

  lFiles := TStringList.Create;
  lMicSources := TStringList.Create;
  lMic185Sources := TStringList.Create;
  lMcbusSources := TStringList.Create;
  try
    lFiles.CaseSensitive := False;
    lMicSources.CaseSensitive := False;
    lMic185Sources.CaseSensitive := False;
    lMcbusSources.CaseSensitive := False;

    for I := 0 to ARecorder.TagRegistry.TagCount - 1 do
    begin
      lTag := ARecorder.TagRegistry.Tags[I];
      if Pos(CMeraSourcePrefix, lTag.SourceId) = 1 then
      begin
        lFileName := Trim(Copy(lTag.SourceId,
          Length(CMeraSourcePrefix) + 1, MaxInt));
        if lFileName = '' then
          Continue;
        lTagNames := EnsureGroup(lFiles, lFileName);
        if lTagNames.IndexOf(lTag.Address) < 0 then
          lTagNames.Add(lTag.Address);
      end
      else if TryParseRecorderMic140SourceId(lTag.SourceId, lHost, lPort) then
      begin
        lTagNames := EnsureGroup(lMicSources, lTag.SourceId);
        if (lTag.Address <> '') and (lTagNames.IndexOf(lTag.Address) < 0) then
          lTagNames.Add(lTag.Address);
        if (lTag.Name <> '') and (lTagNames.IndexOf(lTag.Name) < 0) then
          lTagNames.Add(lTag.Name);
      end
      else if TryParseRecorderMic185SourceId(lTag.SourceId, lHost, lPort) then
      begin
        lTagNames := EnsureGroup(lMic185Sources, lTag.SourceId);
        if (lTag.Address <> '') and (lTagNames.IndexOf(lTag.Address) < 0) then
          lTagNames.Add(lTag.Address);
        if (lTag.Name <> '') and (lTagNames.IndexOf(lTag.Name) < 0) then
          lTagNames.Add(lTag.Name);
      end
      else if TryParseRecorderMc032SourceId(lTag.SourceId, lHost, lPort) then
      begin
        lTagNames := EnsureGroup(lMcbusSources, lTag.SourceId);
        if (lTag.Name <> '') and (lTagNames.IndexOf(lTag.Name) < 0) then
          lTagNames.Add(lTag.Name);
      end;
    end;

    for I := 0 to lFiles.Count - 1 do
    begin
      lTagNames := TStringList(lFiles.Objects[I]);
      lSource := TRecorderMeraFileDataSource.Create(CMeraSourcePrefix +
        lFiles[I], lFiles[I], ADataUpdateMs, lTagNames, 0);
      ARecorder.DataSources.AddSource(lSource,
        RecorderConfiguredDataSourceEnabled(ARecorder.TagRegistry,
          CMeraSourcePrefix + lFiles[I]));
      Log(ALog, Format('MERA playback source configured: %s (%d channels).',
        [ExtractFileName(lFiles[I]), lTagNames.Count]));
    end;

    for I := 0 to lMicSources.Count - 1 do
    begin
      if not RecorderMic140ResolveEndpoint(ARecorder.TagRegistry, lMicSources[I],
        lHost, lPort) then
        Continue;
      lTagNames := TStringList(lMicSources.Objects[I]);
      lChannelCount := MIC140DefaultChannelCount;
      lPollFrequencyHz := MIC140DefaultPollFrequencyHz;
      lMicOutputMode := momMillivolts;
      for J := 0 to lTagNames.Count - 1 do
        if (not RecorderMic140IsUtsAddress(lTagNames[J])) and
          ParseMic140ChannelNumber(lTagNames[J], lChannelNumber) and
          (lChannelNumber > lChannelCount) then
          lChannelCount := MIC140MaxChannelCount;
      for J := 0 to ARecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := ARecorder.TagRegistry.Tags[J];
        if SameText(lTag.SourceId, lMicSources[I]) and
          RecorderMic140TagDefinesScanFrequency(lTag) then
        begin
          lPollFrequencyHz := lTag.PollFrequencyHz;
          if Trim(lTag.SourceValueMode) <> '' then
            lMicOutputMode := RecorderMic140ConfigNameToOutputMode(
              lTag.SourceValueMode);
          Break;
        end;
      end;
      lSource := TRecorderMic140DataSource.Create(
        RecorderMic140SourceId(lHost, lPort), lHost, lPort,
        lChannelCount, lPollFrequencyHz, ADataUpdateMs, lTagNames,
        lMicOutputMode);
      ARecorder.DataSources.AddSource(lSource,
        RecorderConfiguredDataSourceEnabled(ARecorder.TagRegistry,
          lMicSources[I]));
      Log(ALog, Format('MIC-140 source configured: %s:%d (%d channels).',
        [lHost, lPort, lChannelCount]));
    end;

    for I := 0 to lMic185Sources.Count - 1 do
    begin
      if not TryParseRecorderMic185SourceId(lMic185Sources[I], lHost, lPort) then
        Continue;
      lTagNames := TStringList(lMic185Sources.Objects[I]);
      lPollFrequencyHz := MIC185DefaultPollFrequencyHz;
      for J := 0 to ARecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := ARecorder.TagRegistry.Tags[J];
        if SameText(lTag.SourceId, lMic185Sources[I]) and
          (lTag.PollFrequencyHz > 0) then
        begin
          lPollFrequencyHz := lTag.PollFrequencyHz;
          Break;
        end;
      end;
      lSource := TRecorderMic185DataSource.Create(lMic185Sources[I], lHost,
        lPort, lPollFrequencyHz, ADataUpdateMs, lTagNames);
      ARecorder.DataSources.AddSource(lSource,
        RecorderConfiguredDataSourceEnabled(ARecorder.TagRegistry,
          lMic185Sources[I]));
      Log(ALog, Format('MIC183/185 source configured: %s:%d (%d channels).',
        [lHost, lPort, lTagNames.Count]));
    end;

    for I := 0 to lMcbusSources.Count - 1 do
    begin
      if not TryParseRecorderMc032SourceId(lMcbusSources[I], lHost, lPort) then
        Continue;
      lTagNames := TStringList(lMcbusSources.Objects[I]);
      lSpecificConfigText := '';
      lConfigured := RecorderConfiguredDataSourcesFind(ARecorder.TagRegistry,
        lMcbusSources[I]);
      if lConfigured <> nil then
        lSpecificConfigText := lConfigured.SpecificConfigText;
      lPollFrequencyHz := 57600;
      for J := 0 to ARecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := ARecorder.TagRegistry.Tags[J];
        if SameText(lTag.SourceId, lMcbusSources[I]) and
          (lTag.PollFrequencyHz > 0) then
          lPollFrequencyHz := Max(lPollFrequencyHz, lTag.PollFrequencyHz);
      end;
      lSource := TRecorderMcbusDataSource.Create(lMcbusSources[I], lHost,
        lPort, lPollFrequencyHz, ADataUpdateMs, lTagNames,
        lSpecificConfigText);
      ARecorder.DataSources.AddSource(lSource,
        RecorderConfiguredDataSourceEnabled(ARecorder.TagRegistry,
          lMcbusSources[I]));
      Log(ALog, Format('MC-032/MC-201 source configured: %s:%d (%d channels).',
        [lHost, lPort, lTagNames.Count]));
    end;
  finally
    FreeGroupedLists(lFiles);
    FreeGroupedLists(lMicSources);
    FreeGroupedLists(lMic185Sources);
    FreeGroupedLists(lMcbusSources);
  end;

  ARecorder.DataSources.ConfigureTagsAll(ARecorder.TagRegistry);
end;

procedure RecorderReplaceRuntimeSource(ARecorder: TRecorder;
  const ASourceId: string; ADataUpdateMs: Cardinal;
  ALog: TRecorderRuntimeSourceLogEvent; APrepareNow: Boolean);
var
  I: Integer;
  lChannelCount: Integer;
  lChannelNumber: Integer;
  lConfigured: TRecorderConfiguredDataSource;
  lFileName: string;
  lHost: string;
  lMicOutputMode: TRecorderMic140OutputMode;
  lPollFrequencyHz: Double;
  lPort: Word;
  lSource: IRecorderDataSource;
  lSpecificConfigText: string;
  lTag: TRecorderTag;
  lTagNames: TStringList;
begin
  if (ARecorder = nil) or (ARecorder.DataSources = nil) or
    (ARecorder.TagRegistry = nil) or (Trim(ASourceId) = '') then
    Exit;
  if ADataUpdateMs = 0 then
    ADataUpdateMs := 300;

  lConfigured := RecorderConfiguredDataSourcesFind(ARecorder.TagRegistry,
    ASourceId);
  if lConfigured = nil then
  begin
    ARecorder.DataSources.RemoveSource(ASourceId);
    Exit;
  end;

  lTagNames := TStringList.Create;
  try
    lTagNames.CaseSensitive := False;
    for I := 0 to ARecorder.TagRegistry.TagCount - 1 do
    begin
      lTag := ARecorder.TagRegistry.Tags[I];
      if not SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
        RecorderNormalizeTagSourceId(ASourceId)) then
        Continue;
      if Pos(CMeraSourcePrefix, ASourceId) = 1 then
      begin
        if lTagNames.IndexOf(lTag.Address) < 0 then
          lTagNames.Add(lTag.Address);
      end
      else
      begin
        if (lTag.Address <> '') and (lTagNames.IndexOf(lTag.Address) < 0) then
          lTagNames.Add(lTag.Address);
        if (lTag.Name <> '') and (lTagNames.IndexOf(lTag.Name) < 0) then
          lTagNames.Add(lTag.Name);
      end;
    end;

    if Pos(CMeraSourcePrefix, ASourceId) = 1 then
    begin
      lFileName := Trim(Copy(ASourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
      lSource := TRecorderMeraFileDataSource.Create(ASourceId, lFileName,
        ADataUpdateMs, lTagNames, 0);
    end
    else if RecorderMic140ResolveEndpoint(ARecorder.TagRegistry, ASourceId,
      lHost, lPort) then
    begin
      lChannelCount := MIC140DefaultChannelCount;
      lPollFrequencyHz := MIC140DefaultPollFrequencyHz;
      lMicOutputMode := momMillivolts;
      for I := 0 to ARecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := ARecorder.TagRegistry.Tags[I];
        if not SameText(lTag.SourceId, ASourceId) then
          Continue;
        if (not RecorderMic140IsUtsAddress(lTag.Address)) and
          ParseMic140ChannelNumber(lTag.Address, lChannelNumber) and
          (lChannelNumber > lChannelCount) then
          lChannelCount := MIC140MaxChannelCount;
        if RecorderMic140TagDefinesScanFrequency(lTag) then
          lPollFrequencyHz := lTag.PollFrequencyHz;
        if RecorderMic140TagDefinesScanFrequency(lTag) and
          (Trim(lTag.SourceValueMode) <> '') then
          lMicOutputMode := RecorderMic140ConfigNameToOutputMode(
            lTag.SourceValueMode);
      end;
      lSource := TRecorderMic140DataSource.Create(
        RecorderMic140SourceId(lHost, lPort), lHost, lPort, lChannelCount,
        lPollFrequencyHz, ADataUpdateMs, lTagNames, lMicOutputMode);
    end
    else if TryParseRecorderMic185SourceId(ASourceId, lHost, lPort) then
    begin
      lPollFrequencyHz := MIC185DefaultPollFrequencyHz;
      if lConfigured.DefaultPollFrequencyHz > 0 then
        lPollFrequencyHz := lConfigured.DefaultPollFrequencyHz;
      lSource := TRecorderMic185DataSource.Create(ASourceId, lHost, lPort,
        lPollFrequencyHz, ADataUpdateMs, lTagNames);
    end
    else if TryParseRecorderMc032SourceId(ASourceId, lHost, lPort) then
    begin
      lPollFrequencyHz := 57600;
      lSpecificConfigText := lConfigured.SpecificConfigText;
      for I := 0 to ARecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := ARecorder.TagRegistry.Tags[I];
        if SameText(lTag.SourceId, ASourceId) and
          (lTag.PollFrequencyHz > lPollFrequencyHz) then
          lPollFrequencyHz := lTag.PollFrequencyHz;
      end;
      lSource := TRecorderMcbusDataSource.Create(ASourceId, lHost, lPort,
        lPollFrequencyHz, ADataUpdateMs, lTagNames, lSpecificConfigText);
    end
    else
      Exit;

    ARecorder.DataSources.ReplaceSource(lSource, lConfigured.Enabled,
      APrepareNow);
    Log(ALog, 'Runtime source reconfigured: ' + ASourceId);
  finally
    lTagNames.Free;
  end;
end;

end.
