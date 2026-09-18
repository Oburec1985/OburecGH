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
  { Каноническая запись источника в dataSources. SourceId — свойство
    (не «застывшая» константа в коде): потомок может переопределить GetSourceId. }
  TRecorderConfiguredDataSource = class(TPersistent)
  private
    fSourceId: string;
    fSourceAddress: string;
    fModuleType: string;
    fDefaultPollFrequencyHz: Double;
    fSpecificConfigText: string;
    fEnabled: Boolean;
  protected
    function GetSourceId: string; virtual;
    procedure SetSourceId(const AValue: string); virtual;
  public
    constructor Create;
    property SourceId: string read GetSourceId write SetSourceId;
    { Пустая строка означает прежнюю автоматическую адресацию. }
    property SourceAddress: string read fSourceAddress write fSourceAddress;
    property ModuleType: string read fModuleType write fModuleType;
    property Enabled: Boolean read fEnabled write fEnabled;
    property DefaultPollFrequencyHz: Double
      read fDefaultPollFrequencyHz write fDefaultPollFrequencyHz;
    property SpecificConfigText: string
      read fSpecificConfigText write fSpecificConfigText;
  end;

function RecorderConfiguredDataSourceList(
  ARegistry: TRecorderTagRegistry): TObjectList;
procedure RecorderConfiguredDataSourcesClear(ARegistry: TRecorderTagRegistry);
function RecorderConfiguredDataSourcesFind(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): TRecorderConfiguredDataSource;
function RecorderConfiguredDataSourceEnabled(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;
function RecorderConfiguredDataSourcesEnsure(ARegistry: TRecorderTagRegistry;
  const ASourceId, AModuleType: string;
  ADefaultPollFrequencyHz: Double = 0): TRecorderConfiguredDataSource;
procedure RecorderConfiguredDataSourcesRemove(ARegistry: TRecorderTagRegistry;
  const ASourceId: string);

procedure RecorderEnumerateConfiguredSourceIds(ARegistry: TRecorderTagRegistry;
  ASourceIds: TStrings; AHardwareTreeOnly: Boolean = False);
function RecorderConfiguredSourceTreeIndex(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Integer;
function RecorderConfiguredSourceAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): string;
function RecorderSetConfiguredSourceAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, ANewAddress: string; out AError: string): Boolean;
function RecorderTreeIndexedAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, ANativeAddress: string; AReplaceLeadingIndex: Boolean): string;

procedure LoadRecorderConfiguredDataSources(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
procedure SaveRecorderConfiguredDataSources(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);

implementation

constructor TRecorderConfiguredDataSource.Create;
begin
  inherited Create;
  { Старые проекты не содержат enabled и должны продолжать собирать данные. }
  fEnabled := True;
end;

function TRecorderConfiguredDataSource.GetSourceId: string;
begin
  Result := fSourceId;
end;

procedure TRecorderConfiguredDataSource.SetSourceId(const AValue: string);
begin
  fSourceId := RecorderNormalizeTagSourceId(AValue);
end;

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

function RecorderConfiguredDataSourceEnabled(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;
var
  lEntry: TRecorderConfiguredDataSource;
begin
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  Result := (lEntry = nil) or lEntry.Enabled;
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

function RecorderAutoSourceAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): string;
var
  lEntry: TRecorderConfiguredDataSource;
  lHost, lText: string;
  lDot, lColon, I, lDash: Integer;
  lTag: TRecorderTag;
begin
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  if (lEntry <> nil) and (Pos('MIC183/185', UpperCase(lEntry.ModuleType)) > 0) then
  begin
    lText := Trim(Copy(ASourceId, Pos(':', ASourceId) + 1, MaxInt));
    lColon := LastDelimiter(':', lText);
    lHost := Copy(lText, 1, lColon - 1);
    lDot := LastDelimiter('.', lHost);
    if (lDot > 0) and (StrToIntDef(Copy(lHost, lDot + 1, MaxInt), -1) >= 0) then
      Exit(Copy(lHost, lDot + 1, MaxInt));
  end;
  if (lEntry <> nil) and (Pos('MIC-140', UpperCase(lEntry.ModuleType)) > 0) then
    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      if not SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
        RecorderNormalizeTagSourceId(ASourceId)) then
        Continue;
      lDash := Pos('-', lTag.Address);
      if (lDash > 1) and
        (StrToIntDef(Copy(lTag.Address, 1, lDash - 1), -1) >= 0) then
        Exit(Copy(lTag.Address, 1, lDash - 1));
    end;
  Result := IntToStr(RecorderConfiguredSourceTreeIndex(ARegistry, ASourceId));
end;

function RecorderConfiguredSourceAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): string;
var
  lEntry: TRecorderConfiguredDataSource;
begin
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  if (lEntry <> nil) and (Trim(lEntry.SourceAddress) <> '') then
    Exit(Trim(lEntry.SourceAddress));
  Result := RecorderAutoSourceAddress(ARegistry, ASourceId);
end;

function RecorderTagUsesSourceAddress(const ATagAddress, ASourceAddress: string;
  AIsMic185: Boolean): Boolean;
begin
  Result := SameText(Copy(ATagAddress, 1, Length(ASourceAddress) + 1),
    ASourceAddress + '-');
  if not Result and AIsMic185 then
    Result := Pos('{' + ASourceAddress + '-', ATagAddress) > 0;
end;

function RecorderRemappedTagAddress(const ATagAddress, AOldAddress,
  ANewAddress: string; AIsMic185: Boolean): string;
var
  lDash: Integer;
  lSuffix: string;
begin
  if AIsMic185 then
  begin
    lDash := LastDelimiter('-', ATagAddress);
    lSuffix := Copy(ATagAddress, lDash + 1, MaxInt);
    if (lSuffix <> '') and (lSuffix[Length(lSuffix)] = '}') then
      Delete(lSuffix, Length(lSuffix), 1);
    Result := ANewAddress + '-' + lSuffix;
  end
  else
    Result := ANewAddress + Copy(ATagAddress, Length(AOldAddress) + 1,
      MaxInt);
end;

function RecorderSetConfiguredSourceAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, ANewAddress: string; out AError: string): Boolean;
var
  I, J: Integer;
  lEntry, lOtherEntry: TRecorderConfiguredDataSource;
  lOldAddress, lNewAddress: string;
  lTag, lOther: TRecorderTag;
  lNewTagAddress, lOtherNewAddress: string;
  lIsMic185: Boolean;
begin
  Result := False;
  AError := '';
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  if lEntry = nil then
  begin
    AError := 'Источник не найден';
    Exit;
  end;
  lOldAddress := RecorderConfiguredSourceAddress(ARegistry, ASourceId);
  lNewAddress := Trim(ANewAddress);
  if lNewAddress = '' then
    lNewAddress := RecorderAutoSourceAddress(ARegistry, ASourceId);
  if (lNewAddress = '') or (lNewAddress = '0') then
  begin
    AError := 'Адрес источника должен быть непустым';
    Exit;
  end;
  if SameText(lOldAddress, lNewAddress) then
  begin
    lEntry.SourceAddress := Trim(ANewAddress);
    Exit(True);
  end;
  { MIC-140 пока использует номер узла внутри аппаратного драйвера. }
  if Pos('MIC-140', UpperCase(lEntry.ModuleType)) > 0 then
  begin
    AError := 'Для MIC-140 адрес пока задаётся аппаратным драйвером';
    Exit;
  end;
  lIsMic185 := (Pos('MIC183/185', UpperCase(lEntry.ModuleType)) > 0) or
    (Pos('MIC-185', UpperCase(lEntry.ModuleType)) > 0);
  for I := 0 to RecorderConfiguredDataSourceList(ARegistry).Count - 1 do
  begin
    lOtherEntry := TRecorderConfiguredDataSource(
      RecorderConfiguredDataSourceList(ARegistry)[I]);
    if (lOtherEntry <> lEntry) and
      SameText(RecorderConfiguredSourceAddress(ARegistry, lOtherEntry.SourceId),
        lNewAddress) then
    begin
      AError := 'Адрес источника уже занят: ' + lNewAddress;
      Exit;
    end;
  end;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if not SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      RecorderNormalizeTagSourceId(ASourceId)) or
      not RecorderTagUsesSourceAddress(lTag.Address, lOldAddress,
        lIsMic185) then
      Continue;
    lNewTagAddress := RecorderRemappedTagAddress(lTag.Address,
      lOldAddress, lNewAddress, lIsMic185);
    for J := 0 to ARegistry.TagCount - 1 do
    begin
      lOther := ARegistry.Tags[J];
      if (lOther = lTag) or
        not SameText(RecorderNormalizeTagSourceId(lOther.SourceId),
          RecorderNormalizeTagSourceId(ASourceId)) then
        Continue;
      lOtherNewAddress := lOther.Address;
      if RecorderTagUsesSourceAddress(lOther.Address, lOldAddress,
        lIsMic185) then
        lOtherNewAddress := RecorderRemappedTagAddress(lOther.Address,
          lOldAddress, lNewAddress, lIsMic185);
      if SameText(lOtherNewAddress, lNewTagAddress) then
      begin
        AError := 'Адрес тега уже занят: ' + lNewTagAddress;
        Exit;
      end;
    end;
  end;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      RecorderNormalizeTagSourceId(ASourceId)) and
      RecorderTagUsesSourceAddress(lTag.Address, lOldAddress,
        lIsMic185) then
      lTag.Address := RecorderRemappedTagAddress(lTag.Address,
        lOldAddress, lNewAddress, lIsMic185);
  end;
  lEntry.SourceAddress := Trim(ANewAddress);
  Result := True;
end;

function RecorderTreeIndexedAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, ANativeAddress: string; AReplaceLeadingIndex: Boolean): string;
var
  lDash: SizeInt;
  lSourceAddress: string;
begin
  Result := Trim(ANativeAddress);
  lSourceAddress := RecorderConfiguredSourceAddress(ARegistry, ASourceId);
  if (lSourceAddress = '') or (lSourceAddress = '0') or (Result = '') then Exit;
  if AReplaceLeadingIndex then
  begin
    lDash := Pos('-', Result);
    if lDash > 0 then
      Result := lSourceAddress + Copy(Result, lDash, MaxInt)
    else
      Result := lSourceAddress + '-' + Result;
  end
  else
    Result := lSourceAddress + '-' + Result;
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
    lEntry.SourceAddress := Trim(lItem.Get('sourceAddress', ''));
    lEntry.ModuleType := lItem.Get('moduleType', '');
    lEntry.Enabled := lItem.Get('enabled', True);
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
    lItem.Add('sourceAddress', lEntry.SourceAddress);
    lItem.Add('moduleType', lEntry.ModuleType);
    lItem.Add('enabled', lEntry.Enabled);
    lItem.Add('defaultPollFrequencyHz', lEntry.DefaultPollFrequencyHz);
    lItem.Add('specificConfigText', lEntry.SpecificConfigText);
  end;
end;

end.
