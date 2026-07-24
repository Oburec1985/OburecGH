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

implementation

uses
  SysUtils, Math, uRecorderTags, uRecorderDataSources,
  uRecorderConfiguredDataSources, uRecorderMic140DataSource,
  uRecorderMic140StreamTypes, uRecorderMic140Utils, uRecorderMic185DataSource,
  uRecorderMcbusDataSource;

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
      lSource := TRecorderMeraFileDataSource.Create('mera.file.' +
        IntToStr(I + 1), lFiles[I], ADataUpdateMs, lTagNames, 0);
      ARecorder.DataSources.AddSource(lSource);
      Log(ALog, Format('MERA playback source configured: %s (%d channels).',
        [ExtractFileName(lFiles[I]), lTagNames.Count]));
    end;

    for I := 0 to lMicSources.Count - 1 do
    begin
      if not TryParseRecorderMic140SourceId(lMicSources[I], lHost, lPort) then
        Continue;
      lTagNames := TStringList(lMicSources.Objects[I]);
      lChannelCount := MIC140DefaultChannelCount;
      lPollFrequencyHz := MIC140DefaultPollFrequencyHz;
      lMicOutputMode := momMillivolts;
      for J := 0 to lTagNames.Count - 1 do
        if TryStrToInt(lTagNames[J], lChannelNumber) and
          (lChannelNumber > lChannelCount) then
          lChannelCount := MIC140MaxChannelCount;
      for J := 0 to ARecorder.TagRegistry.TagCount - 1 do
      begin
        lTag := ARecorder.TagRegistry.Tags[J];
        if SameText(lTag.SourceId, lMicSources[I]) and
          (lTag.PollFrequencyHz > 0) then
        begin
          lPollFrequencyHz := lTag.PollFrequencyHz;
          if Trim(lTag.SourceValueMode) <> '' then
            lMicOutputMode := RecorderMic140ConfigNameToOutputMode(
              lTag.SourceValueMode);
          Break;
        end;
      end;
      lSource := TRecorderMic140DataSource.Create(lMicSources[I], lHost, lPort,
        lChannelCount, lPollFrequencyHz, ADataUpdateMs, lTagNames,
        lMicOutputMode);
      ARecorder.DataSources.AddSource(lSource);
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
      ARecorder.DataSources.AddSource(lSource);
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
      ARecorder.DataSources.AddSource(lSource);
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

end.
