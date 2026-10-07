unit uRecorderSqlDataSource;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson, Math,
  uRecorderDataSources, uRecorderTags, uRecorderSqlDbTypes,
  uRecorderSqlDbRepository;

const
  CRecorderSqlSourceId = 'SQL database';
  CRecorderSqlSourceModuleType = 'SQL database';

type
  TRecorderSqlSourceBinding = class
  public
    SignalName: string;
    TagName: string;
    MeasurementUnit: string;
  end;

  TRecorderSqlDataSource = class(TRecorderDataSourceBase)
  private
    fBindings: TObjectList;
    fConfig: TRecorderSqlDbConfig;
    fRepository: TRecorderSqlDbRepository;
    fSignalNames: TStringList;
    function BindingBySignal(const AName: string): TRecorderSqlSourceBinding;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const AConfigFileName, AConfigText: string;
      AUpdateTimeMs: Cardinal);
    destructor Destroy; override;
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
  end;

function RecorderSqlSourceConfig(ARegistry: TRecorderTagRegistry): string;
procedure RecorderSqlSourceAddBinding(AArray: TJSONArray; const ASignalName,
  ATagName, AUnitName: string);

implementation

uses
  jsonparser, uRecorderConfiguredDataSources, uRecorderSqlDbRuntime,
  uRecorderHardwareLiveDevices, uRecorderDebugLog;

procedure RecorderSqlSourceAddBinding(AArray: TJSONArray;
  const ASignalName, ATagName, AUnitName: string);
var
  lItem: TJSONObject;
begin
  lItem := TJSONObject.Create;
  lItem.Add('signal', ASignalName);
  lItem.Add('tag', ATagName);
  lItem.Add('unit', AUnitName);
  AArray.Add(lItem);
end;

function RecorderSqlSourceConfig(ARegistry: TRecorderTagRegistry): string;
var
  lSource: TRecorderConfiguredDataSource;
begin
  Result := '';
  lSource := RecorderConfiguredDataSourcesFind(ARegistry, CRecorderSqlSourceId);
  if lSource <> nil then Result := lSource.SpecificConfigText;
end;

constructor TRecorderSqlDataSource.Create(const AConfigFileName,
  AConfigText: string; AUpdateTimeMs: Cardinal);
var
  I: Integer;
  lArray: TJSONArray;
  lBinding: TRecorderSqlSourceBinding;
  lData: TJSONData;
  lItem: TJSONObject;
begin
  inherited Create(CRecorderSqlSourceId, CRecorderSqlSourceModuleType,
    Max(AUpdateTimeMs, 1000));
  fBindings := TObjectList.Create(True);
  fSignalNames := TStringList.Create;
  fSignalNames.CaseSensitive := False;
  fConfig := TRecorderSqlDbConfig.Create;
  fConfig.LoadFromFile(AConfigFileName);
  fRepository := TRecorderSqlDbRepository.Create(fConfig);
  lData := nil;
  try
    lData := GetJSON(AConfigText);
    if not (lData is TJSONArray) then Exit;
    lArray := TJSONArray(lData);
    for I := 0 to lArray.Count - 1 do
    begin
      if not (lArray[I] is TJSONObject) then Continue;
      lItem := TJSONObject(lArray[I]);
      lBinding := TRecorderSqlSourceBinding.Create;
      lBinding.SignalName := Trim(lItem.Get('signal', ''));
      lBinding.TagName := Trim(lItem.Get('tag', ''));
      lBinding.MeasurementUnit := lItem.Get('unit', '');
      if (lBinding.SignalName = '') or (lBinding.TagName = '') then
        lBinding.Free
      else
      begin
        fBindings.Add(lBinding);
        fSignalNames.Add(lBinding.SignalName);
      end;
    end;
  finally
    lData.Free;
  end;
end;

destructor TRecorderSqlDataSource.Destroy;
begin
  fRepository.Free;
  fConfig.Free;
  fSignalNames.Free;
  fBindings.Free;
  inherited Destroy;
end;

procedure TRecorderSqlDataSource.PrepareHardware;
var
  lError: string;
begin
  inherited PrepareHardware;
  if RecorderSqlServerAvailable(fConfig, lError) then
  begin
    { После восстановления не переиспользуем соединение, на котором ранее
      была обнаружена потеря сервера. Это допустимо здесь: PrepareHardware
      выполняется при загрузке/переконфигурации, а не в Play/Stop. }
    fRepository.Close;
    RecorderHardwareClearSourceOffline(SourceId);
    Exit;
  end;

  RecorderHardwareMarkSourceOffline(SourceId, lError);
  RecorderDebugLog(Format('[DataSource:%s] SQL server unavailable: %s',
    [SourceId, lError]));
end;

function TRecorderSqlDataSource.BindingBySignal(
  const AName: string): TRecorderSqlSourceBinding;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fBindings.Count - 1 do
    if SameText(TRecorderSqlSourceBinding(fBindings[I]).SignalName, AName) then
      Exit(TRecorderSqlSourceBinding(fBindings[I]));
end;

procedure TRecorderSqlDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lBinding: TRecorderSqlSourceBinding;
  lTag: TRecorderTag;
begin
  for I := 0 to fBindings.Count - 1 do
  begin
    lBinding := TRecorderSqlSourceBinding(fBindings[I]);
    lTag := ARegistry.FindByName(lBinding.TagName);
    if lTag = nil then lTag := ARegistry.CreateTag(lBinding.TagName, 4096);
    lTag.SourceId := CRecorderSqlSourceId;
    lTag.ModuleType := CRecorderSqlSourceModuleType;
    lTag.Address := lBinding.SignalName;
    lTag.UnitName := lBinding.MeasurementUnit;
    lTag.PollFrequencyHz := 1000.0 / UpdateTimeMs;
  end;
end;

procedure TRecorderSqlDataSource.Start;
begin
  fRepository.Open;
  inherited Start;
end;

procedure TRecorderSqlDataSource.Stop;
begin
  { После потери сервера Close может попытаться завершить Firebird-транзакцию
    через уже оборванную сеть. Offline-источник не должен выполнять SQL I/O в
    общей цепочке Stop; repository будет освобождён при замене/удалении
    конфигурации вне перехода Play -> Stop. }
  if not RecorderHardwareIsSourceOffline(SourceId) then
    fRepository.Close;
  inherited Stop;
end;

procedure TRecorderSqlDataSource.DoTick;
var
  I: Integer;
  lBinding: TRecorderSqlSourceBinding;
  lError: string;
  lValues: TRecorderSqlLatestValues;
begin
  { Проверка выполняется до SQL-запроса. Если сервер пропал уже во время
    Preview/Record, поток сам переводит источник в offline и завершается;
    последующий Stop не ждёт системный таймаут Firebird. }
  if not RecorderSqlServerAvailable(fConfig, lError) then
  begin
    RecorderHardwareMarkSourceOffline(SourceId, lError);
    RecorderDebugLog(Format('[DataSource:%s] SQL server lost: %s',
      [SourceId, lError]));
    RequestStop;
    Exit;
  end;

  fRepository.ReadLatestSignalValues(fSignalNames, lValues);
  for I := 0 to High(lValues) do
  begin
    lBinding := BindingBySignal(lValues[I].SignalName);
    if lBinding <> nil then
      Registry.PublishValue(lBinding.TagName, lValues[I].TimestampUtc,
        lValues[I].Value);
  end;
end;

end.
