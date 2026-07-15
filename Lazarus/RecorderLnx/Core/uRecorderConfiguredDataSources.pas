unit uRecorderConfiguredDataSources;

{
  Канонический список источников данных проекта (секция dataSources в JSON).
  Устройства создаются только через менеджер устройств / загрузку конфигурации.
  Теги не добавляют и не удаляют записи в этом списке.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson, uRecorderTags;

type
  TRecorderConfiguredDataSource = class(TPersistent)
  public
    SourceId: string;
    ModuleType: string;
    DefaultPollFrequencyHz: Double;
    SpecificConfigText: string;
  end;

function RecorderConfiguredDataSourceList(
  ARegistry: TRecorderTagRegistry): TObjectList;
procedure RecorderConfiguredDataSourcesClear(ARegistry: TRecorderTagRegistry);
function RecorderConfiguredDataSourcesFind(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): TRecorderConfiguredDataSource;
function RecorderConfiguredDataSourcesEnsure(ARegistry: TRecorderTagRegistry;
  const ASourceId, AModuleType: string;
  ADefaultPollFrequencyHz: Double = 0): TRecorderConfiguredDataSource;
procedure RecorderConfiguredDataSourcesRemove(ARegistry: TRecorderTagRegistry;
  const ASourceId: string);

procedure RecorderEnumerateConfiguredSourceIds(ARegistry: TRecorderTagRegistry;
  ASourceIds: TStrings; AHardwareTreeOnly: Boolean = False);
function RecorderConfiguredSourceTreeIndex(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Integer;
function RecorderTreeIndexedAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, ANativeAddress: string; AReplaceLeadingIndex: Boolean): string;

procedure LoadRecorderConfiguredDataSources(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
procedure SaveRecorderConfiguredDataSources(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);

implementation

function RecorderConfiguredDataSourceList(
  ARegistry: TRecorderTagRegistry): TObjectList;
begin
  Result := nil;
  if ARegistry <> nil then
    Result := ARegistry.ConfiguredDataSources;
end;

procedure RecorderConfiguredDataSourcesClear(ARegistry: TRecorderTagRegistry);
begin
  if RecorderConfiguredDataSourceList(ARegistry) <> nil then
    RecorderConfiguredDataSourceList(ARegistry).Clear;
end;

function RecorderConfiguredDataSourcesFind(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): TRecorderConfiguredDataSource;
var
  I: Integer;
  lEntry: TRecorderConfiguredDataSource;
  lList: TObjectList;
  lNorm: string;
begin
  Result := nil;
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if lNorm = '' then
    Exit;
  lList := RecorderConfiguredDataSourceList(ARegistry);
  if lList = nil then
    Exit;
  for I := 0 to lList.Count - 1 do
  begin
    lEntry := TRecorderConfiguredDataSource(lList[I]);
    if SameText(RecorderNormalizeTagSourceId(lEntry.SourceId), lNorm) then
      Exit(lEntry);
  end;
end;

function RecorderConfiguredDataSourcesEnsure(ARegistry: TRecorderTagRegistry;
  const ASourceId, AModuleType: string;
  ADefaultPollFrequencyHz: Double): TRecorderConfiguredDataSource;
var
  lNorm: string;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if lNorm = '' then
    Exit;
  Result := RecorderConfiguredDataSourcesFind(ARegistry, lNorm);
  if Result = nil then
  begin
    Result := TRecorderConfiguredDataSource.Create;
    Result.SourceId := lNorm;
    RecorderConfiguredDataSourceList(ARegistry).Add(Result);
  end;
  if AModuleType <> '' then
    Result.ModuleType := AModuleType;
  if ADefaultPollFrequencyHz > 0 then
    Result.DefaultPollFrequencyHz := ADefaultPollFrequencyHz;
end;

procedure RecorderConfiguredDataSourcesRemove(ARegistry: TRecorderTagRegistry;
  const ASourceId: string);
var
  I: Integer;
  lEntry: TRecorderConfiguredDataSource;
  lList: TObjectList;
  lNorm: string;
begin
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if lNorm = '' then
    Exit;
  lList := RecorderConfiguredDataSourceList(ARegistry);
  if lList = nil then
    Exit;
  for I := lList.Count - 1 downto 0 do
  begin
    lEntry := TRecorderConfiguredDataSource(lList[I]);
    if SameText(RecorderNormalizeTagSourceId(lEntry.SourceId), lNorm) then
      lList.Delete(I);
  end;
end;

procedure RecorderEnumerateConfiguredSourceIds(ARegistry: TRecorderTagRegistry;
  ASourceIds: TStrings; AHardwareTreeOnly: Boolean);
var
  I: Integer;
  lEntry: TRecorderConfiguredDataSource;
  lList: TObjectList;
  lNorm: string;
begin
  if (ASourceIds = nil) or (ARegistry = nil) then
    Exit;
  lList := RecorderConfiguredDataSourceList(ARegistry);
  if lList = nil then
    Exit;
  for I := 0 to lList.Count - 1 do
  begin
    lEntry := TRecorderConfiguredDataSource(lList[I]);
    lNorm := RecorderNormalizeTagSourceId(lEntry.SourceId);
    if lNorm = '' then
      Continue;
    if AHardwareTreeOnly and (not RecorderHardwareTreeShowsSourceId(lNorm)) then
      Continue;
    if ASourceIds.IndexOf(lNorm) < 0 then
      ASourceIds.Add(lNorm);
  end;
end;

function RecorderConfiguredSourceTreeIndex(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Integer;
var
  I: Integer;
  lIds: TStringList;
  lNorm: string;
begin
  Result := 0;
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  lIds := TStringList.Create;
  try
    lIds.CaseSensitive := False;
    RecorderEnumerateConfiguredSourceIds(ARegistry, lIds, True);
    for I := 0 to lIds.Count - 1 do
      if SameText(RecorderNormalizeTagSourceId(lIds[I]), lNorm) then
        Exit(I + 1);
  finally
    lIds.Free;
  end;
end;

function RecorderTreeIndexedAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, ANativeAddress: string; AReplaceLeadingIndex: Boolean): string;
var
  lDash: SizeInt;
  lIndex: Integer;
begin
  Result := Trim(ANativeAddress);
  lIndex := RecorderConfiguredSourceTreeIndex(ARegistry, ASourceId);
  if (lIndex <= 0) or (Result = '') then Exit;
  if AReplaceLeadingIndex then
  begin
    lDash := Pos('-', Result);
    if lDash > 0 then
      Result := IntToStr(lIndex) + Copy(Result, lDash, MaxInt)
    else
      Result := IntToStr(lIndex) + '-' + Result;
  end
  else
    Result := IntToStr(lIndex) + '-' + Result;
end;

procedure LoadRecorderConfiguredDataSources(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lArray: TJSONArray;
  lEntry: TRecorderConfiguredDataSource;
  lItem: TJSONObject;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  RecorderConfiguredDataSourcesClear(ARegistry);
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
    if Trim(lItem.Get('sourceId', '')) = '' then
      Continue;
    lEntry := TRecorderConfiguredDataSource.Create;
    lEntry.SourceId := RecorderNormalizeTagSourceId(lItem.Get('sourceId', ''));
    lEntry.ModuleType := lItem.Get('moduleType', '');
    lEntry.DefaultPollFrequencyHz := lItem.Get('defaultPollFrequencyHz', 0.0);
    lEntry.SpecificConfigText := lItem.Get('specificConfigText', '');
    RecorderConfiguredDataSourceList(ARegistry).Add(lEntry);
  end;
end;

procedure SaveRecorderConfiguredDataSources(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lArray: TJSONArray;
  lEntry: TRecorderConfiguredDataSource;
  lItem: TJSONObject;
  lList: TObjectList;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  lList := RecorderConfiguredDataSourceList(ARegistry);
  if lList = nil then
    Exit;
  if not AJson.Find('dataSources', lArray) then
  begin
    lArray := TJSONArray.Create;
    AJson.Add('dataSources', lArray);
  end
  else if not (lArray is TJSONArray) then
    Exit
  else
    lArray := TJSONArray(lArray);
  lArray.Clear;
  for I := 0 to lList.Count - 1 do
  begin
    lEntry := TRecorderConfiguredDataSource(lList[I]);
    if Trim(lEntry.SourceId) = '' then
      Continue;
    lItem := TJSONObject.Create;
    lArray.Add(lItem);
    lItem.Add('sourceId', lEntry.SourceId);
    lItem.Add('moduleType', lEntry.ModuleType);
    lItem.Add('defaultPollFrequencyHz', lEntry.DefaultPollFrequencyHz);
    lItem.Add('specificConfigText', lEntry.SpecificConfigText);
  end;
end;

end.
