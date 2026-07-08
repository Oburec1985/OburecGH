unit uRecorderProjectFiles;

{
  Модуль uRecorderProjectFiles

  Назначение:
    Текстовый пакет конфигурации проекта RecorderLnx. Как в оригинальном
    Recorder, визуальная часть формуляров хранится отдельно от основной
    конфигурации каналов/аппаратных настроек. Формат намеренно простой:
      <base>.config.json - теги, расчетные оценки, уставки, источники;
      <base>.gui.ini     - страницы формуляров и компоненты мнемосхем;
      <base>.run-control.ini сохраняется существующей моделью запуска.

  JSON пока не пытается быть бинарно совместимым с rcfg оригинального Recorder:
  он повторяет смысловые разделы, но остается человекочитаемым.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderFormModel, uRecorderTags;

type
  { TRecorderProjectFileSet
    Набор путей к файлам проекта.
    
    BaseName           - базовое имя файлов проекта.
    DirectoryName      - рабочий каталог проекта.
    MainConfigFileName - путь к основному файлу конфигурации (.config.json).
    GuiFileName        - путь к конфигурации GUI-модели (.gui.ini).
    RunControlFileName - путь к настройкам запуска (.run-control.ini). }
  TRecorderProjectFileSet = record
    BaseName: string;
    DirectoryName: string;
    MainConfigFileName: string;
    GuiFileName: string;
    RunControlFileName: string;
  end;

{ Инициализирует и возвращает структуру путей проекта по каталогу и базовому имени }
function RecorderProjectFileSet(const ADirectoryName, ABaseName: string):
  TRecorderProjectFileSet;

{ Загружает конфигурацию тегов из JSON-файла }
procedure SaveRecorderProjectConfig(const AFileName: string;
  ATags: TRecorderTagRegistry);
{ Загружает конфигурацию тегов из JSON-файла }
procedure LoadRecorderProjectConfig(const AFileName: string;
  ATags: TRecorderTagRegistry);

{ Сохраняет структуру страниц формуляров и их компонентов в INI-файл }
procedure SaveRecorderGuiConfig(const AFileName: string;
  AForms: TRecorderFormManager);
{ Загружает структуру страниц формуляров из INI-файла }
procedure LoadRecorderGuiConfig(const AFileName: string;
  AForms: TRecorderFormManager; AFactory: TRecorderComponentFactory);

implementation

uses
  IniFiles, fpjson, jsonparser, Graphics, uRecorderSpectrumEngine, uRecorderFrequencyBands,
  uOglChartColors, uRecorderMic140DeviceConfig;

function RecorderProjectFileSet(const ADirectoryName, ABaseName: string):
  TRecorderProjectFileSet;
var
  lDir: string;
begin
  lDir := IncludeTrailingPathDelimiter(ADirectoryName);
  Result.DirectoryName := lDir;
  Result.BaseName := ABaseName;
  Result.MainConfigFileName := lDir + ABaseName + '.config.json';
  Result.GuiFileName := lDir + ABaseName + '.gui.ini';
  Result.RunControlFileName := lDir + ABaseName + '.run-control.ini';
end;

function EstimateKindToConfigName(AKind: TRecorderTagEstimateKind): string;
begin
  Result := RecorderTagEstimateKindToShortName(AKind);
end;

function ConfigNameToEstimateKind(const AName: string;
  ADefault: TRecorderTagEstimateKind): TRecorderTagEstimateKind;
var
  lKind: TRecorderTagEstimateKind;
begin
  Result := ADefault;
  for lKind := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
    if SameText(AName, EstimateKindToConfigName(lKind)) or
      SameText(AName, RecorderTagEstimateKindToName(lKind)) then
      Exit(lKind);
end;

function SetpointKindToConfigName(AKind: TRecorderTagSetpointKind): string;
begin
  case AKind of
    tskHighAlarm: Result := 'HighAlarm';
    tskHighWarning: Result := 'HighWarning';
    tskLowWarning: Result := 'LowWarning';
    tskLowAlarm: Result := 'LowAlarm';
  else
    Result := '';
  end;
end;

function ConfigNameToSetpointKind(const AName: string;
  ADefault: TRecorderTagSetpointKind): TRecorderTagSetpointKind;
var
  lKind: TRecorderTagSetpointKind;
begin
  Result := ADefault;
  for lKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
    if SameText(AName, SetpointKindToConfigName(lKind)) then
      Exit(lKind);
end;

function ComponentTypeOf(AComponent: TRecorderVisualComponent): string;
begin
  if AComponent is TRecorderStaticTextComponent then
    Result := TRecorderStaticTextComponent.TypeId
  else if AComponent is TRecorderTagValueComponent then
    Result := TRecorderTagValueComponent.TypeId
  else if AComponent is TRecorderOscillogramComponent then
    Result := TRecorderOscillogramComponent.TypeId
  else if AComponent is TRecorderTrendComponent then
    Result := TRecorderTrendComponent.TypeId
  else if AComponent is TRecorderSpectrumComponent then
    Result := TRecorderSpectrumComponent.TypeId
  else
    Result := AComponent.ClassName;
end;

function JsonObject(AOwner: TJSONObject; const AName: string): TJSONObject;
begin
  Result := TJSONObject.Create;
  AOwner.Add(AName, Result);
end;

function JsonArray(AOwner: TJSONObject; const AName: string): TJSONArray;
begin
  Result := TJSONArray.Create;
  AOwner.Add(AName, Result);
end;

function FindObject(AObject: TJSONObject; const AName: string): TJSONObject;
var
  lData: TJSONData;
begin
  Result := nil;
  if AObject = nil then
    Exit;
  lData := AObject.Find(AName);
  if lData is TJSONObject then
    Result := TJSONObject(lData);
end;

function FindArray(AObject: TJSONObject; const AName: string): TJSONArray;
var
  lData: TJSONData;
begin
  Result := nil;
  if AObject = nil then
    Exit;
  lData := AObject.Find(AName);
  if lData is TJSONArray then
    Result := TJSONArray(lData);
end;


function CalibrationKindToConfigName(AKind: TRecorderCalibrationKind): string;
begin
  case AKind of
    rckScale: Result := 'scale';
  else
    Result := 'piecewiseLinear';
  end;
end;

function ConfigNameToCalibrationKind(const AName: string): TRecorderCalibrationKind;
begin
  if SameText(AName, 'scale') then
    Result := rckScale
  else
    Result := rckPiecewiseLinear;
end;

procedure SaveCalibrationList(AJson: TJSONArray; AList: TRecorderCalibrationList);
var
  I: Integer;
  J: Integer;
  lCalibration: TRecorderCalibration;
  lItem: TJSONObject;
  lPoint: TJSONObject;
  lPoints: TJSONArray;
  lPt: TRecorderCalibrationPoint;
begin
  if AList = nil then
    Exit;
  for I := 0 to AList.Count - 1 do
  begin
    lCalibration := AList[I];
    if lCalibration = nil then
      Continue;
    lItem := TJSONObject.Create;
    AJson.Add(lItem);
    lItem.Add('type', CalibrationKindToConfigName(lCalibration.Kind));
    lItem.Add('name', lCalibration.Name);
    lItem.Add('description', lCalibration.Description);
    lItem.Add('unitIn', lCalibration.UnitIn);
    lItem.Add('unitOut', lCalibration.UnitOut);
    lItem.Add('extrapolation', lCalibration.Extrapolation);
    lItem.Add('scale', lCalibration.Scale);
    lPoints := JsonArray(lItem, 'points');
    for J := 0 to lCalibration.PointCount - 1 do
    begin
      lPt := lCalibration.PointAt(J);
      if lPt = nil then
        Continue;
      lPoint := TJSONObject.Create;
      lPoints.Add(lPoint);
      lPoint.Add('x', lPt.X);
      lPoint.Add('y', lPt.Y);
    end;
  end;
end;

procedure LoadCalibrationList(AJson: TJSONArray; AList: TRecorderCalibrationList);
var
  I: Integer;
  J: Integer;
  lCalibration: TRecorderCalibration;
  lItem: TJSONObject;
  lPoint: TJSONObject;
  lPoints: TJSONArray;
begin
  if AList = nil then
    Exit;
  AList.Clear;
  if AJson = nil then
    Exit;

  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then
      Continue;
    lItem := TJSONObject(AJson.Items[I]);
    lCalibration := TRecorderCalibration.Create(ConfigNameToCalibrationKind(
      lItem.Get('type', 'piecewiseLinear')));
    try
      lCalibration.Name := lItem.Get('name', lCalibration.Name);
      lCalibration.Description := lItem.Get('description', '');
      lCalibration.UnitIn := lItem.Get('unitIn', '');
      lCalibration.UnitOut := lItem.Get('unitOut', '');
      lCalibration.Extrapolation := lItem.Get('extrapolation', True);
      lCalibration.Scale := lItem.Get('scale', 1.0);
      lPoints := FindArray(lItem, 'points');
      if lPoints <> nil then
        for J := 0 to lPoints.Count - 1 do
          if lPoints.Items[J] is TJSONObject then
          begin
            lPoint := TJSONObject(lPoints.Items[J]);
            lCalibration.AddPoint(lPoint.Get('x', 0.0), lPoint.Get('y', 0.0));
          end;
      AList.Add(lCalibration);
      lCalibration := nil;
    finally
      lCalibration.Free;
    end;
  end;
end;

procedure SaveTagCalibrationPipeline(AJson: TJSONArray; ATag: TRecorderTag);
var
  I: Integer;
begin
  for I := 0 to ATag.CalibrationNames.Count - 1 do
    AJson.Add(ATag.CalibrationNames[I]);
end;

procedure LoadTagCalibrationPipeline(AJson: TJSONArray; ATag: TRecorderTag);
var
  I: Integer;
begin
  ATag.CalibrationNames.Clear;
  if AJson = nil then
    Exit;
  for I := 0 to AJson.Count - 1 do
    ATag.CalibrationNames.Add(AJson.Strings[I]);
end;
procedure SaveTagEstimates(AJson: TJSONObject; ATag: TRecorderTag);
var
  lArray: TJSONArray;
  lKind: TRecorderTagEstimateKind;
  lSettings: TRecorderTagEstimateSettings;
begin
  lSettings := ATag.EstimateSettings;
  AJson.Add('default', EstimateKindToConfigName(lSettings.DefaultKind));
  AJson.Add('portionLength', lSettings.PortionLength);
  AJson.Add('smoothingEnabled', lSettings.SmoothingEnabled);
  AJson.Add('smoothingK', lSettings.SmoothingK);
  AJson.Add('scadaEnabled', lSettings.ScadaEnabled);

  lArray := JsonArray(AJson, 'enabled');
  for lKind := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
    if lSettings.EnabledKinds[lKind] then
      lArray.Add(EstimateKindToConfigName(lKind));
end;

procedure LoadTagEstimates(AJson: TJSONObject; ATag: TRecorderTag);
var
  I: Integer;
  lArray: TJSONArray;
  lKind: TRecorderTagEstimateKind;
  lSettings: TRecorderTagEstimateSettings;
begin
  if AJson = nil then
    Exit;

  lSettings := ATag.EstimateSettings;
  for lKind := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
    lSettings.EnabledKinds[lKind] := False;

  lArray := FindArray(AJson, 'enabled');
  if lArray <> nil then
    for I := 0 to lArray.Count - 1 do
      lSettings.EnabledKinds[ConfigNameToEstimateKind(lArray.Strings[I],
        tekMean)] := True;

  lSettings.DefaultKind := ConfigNameToEstimateKind(AJson.Get('default',
    EstimateKindToConfigName(lSettings.DefaultKind)), lSettings.DefaultKind);
  lSettings.PortionLength := AJson.Get('portionLength',
    lSettings.PortionLength);
  lSettings.SmoothingEnabled := AJson.Get('smoothingEnabled',
    lSettings.SmoothingEnabled);
  lSettings.SmoothingK := AJson.Get('smoothingK', lSettings.SmoothingK);
  lSettings.ScadaEnabled := AJson.Get('scadaEnabled',
    lSettings.ScadaEnabled);
  ATag.EstimateSettings := lSettings;
end;

procedure SaveTagSetpoints(AJson: TJSONObject; ATag: TRecorderTag);
var
  lItem: TJSONObject;
  lKind: TRecorderTagSetpointKind;
  lSetpoint: TRecorderTagSetpoint;
begin
  AJson.Add('hysteresisEnabled', ATag.SetpointHysteresisEnabled);
  AJson.Add('soundUntilEnd', ATag.SetpointSoundUntilEnd);
  AJson.Add('statusChannelEnabled', ATag.SetpointStatusChannelEnabled);
  AJson.Add('statusChannelName', ATag.SetpointStatusChannelName);

  for lKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
  begin
    lSetpoint := ATag.Setpoints[lKind];
    lItem := JsonObject(AJson, SetpointKindToConfigName(lKind));
    lItem.Add('enabled', lSetpoint.Enabled);
    lItem.Add('threshold', lSetpoint.Threshold);
    lItem.Add('color', lSetpoint.Color);
    lItem.Add('outputEnabled', lSetpoint.OutputEnabled);
    lItem.Add('hysteresisPercent', lSetpoint.HysteresisPercent);
  end;
end;

procedure LoadTagSetpoints(AJson: TJSONObject; ATag: TRecorderTag);
var
  lItem: TJSONObject;
  lKind: TRecorderTagSetpointKind;
  lSetpoint: TRecorderTagSetpoint;
begin
  if AJson = nil then
    Exit;

  ATag.SetpointHysteresisEnabled := AJson.Get('hysteresisEnabled',
    ATag.SetpointHysteresisEnabled);
  ATag.SetpointSoundUntilEnd := AJson.Get('soundUntilEnd',
    ATag.SetpointSoundUntilEnd);
  ATag.SetpointStatusChannelEnabled := AJson.Get('statusChannelEnabled',
    ATag.SetpointStatusChannelEnabled);
  ATag.SetpointStatusChannelName := AJson.Get('statusChannelName',
    ATag.SetpointStatusChannelName);

  for lKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
  begin
    lItem := FindObject(AJson, SetpointKindToConfigName(lKind));
    if lItem = nil then
      Continue;

    lSetpoint := ATag.Setpoints[lKind];
    lSetpoint.Enabled := lItem.Get('enabled', lSetpoint.Enabled);
    lSetpoint.Threshold := lItem.Get('threshold', lSetpoint.Threshold);
    lSetpoint.Color := lItem.Get('color', Integer(lSetpoint.Color));
    lSetpoint.OutputEnabled := lItem.Get('outputEnabled',
      lSetpoint.OutputEnabled);
    lSetpoint.HysteresisPercent := lItem.Get('hysteresisPercent',
      lSetpoint.HysteresisPercent);
    ATag.Setpoints[lKind] := lSetpoint;
  end;
end;

procedure SaveDataSources(AJson: TJSONObject; ATags: TRecorderTagRegistry);
var
  I: Integer;
  lArray: TJSONArray;
  lItem: TJSONObject;
  lKnown: TStringList;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  lArray := JsonArray(AJson, 'dataSources');
  lKnown := TStringList.Create;
  try
    lKnown.CaseSensitive := False;
    lKnown.Sorted := True;
    lKnown.Duplicates := dupIgnore;

    for I := 0 to ATags.TagCount - 1 do
    begin
      lTag := ATags.Tags[I];
      lSourceId := lTag.SourceId;
      if lSourceId = '' then
        lSourceId := 'manual';
      if lKnown.IndexOf(lSourceId) >= 0 then
        Continue;

      lKnown.Add(lSourceId);
      lItem := TJSONObject.Create;
      lArray.Add(lItem);
      lItem.Add('sourceId', lSourceId);
      lItem.Add('moduleType', lTag.ModuleType);
      lItem.Add('defaultPollFrequencyHz', lTag.PollFrequencyHz);
    end;
  finally
    lKnown.Free;
  end;
end;

procedure SaveSpectrumConfigs(AJson: TJSONArray; ATree: TRecorderSpectrumConfigTree);
var
  I, J: Integer;
  lNode: TRecorderSpectrumConfigNode;
  lItem, lBindingJson: TJSONObject;
  lBindingsArray: TJSONArray;
  lBinding: TRecorderSpectrumTagBinding;
begin
  if (AJson = nil) or (ATree = nil) then Exit;
  for I := 0 to ATree.NodeCount - 1 do
  begin
    lNode := ATree.Nodes[I];
    lItem := TJSONObject.Create;
    AJson.Add(lItem);
    
    lItem.Add('id', lNode.Id);
    lItem.Add('displayName', lNode.DisplayName);
    lItem.Add('settings', lNode.Settings.AsString);
    
    lBindingsArray := JsonArray(lItem, 'bindings');
    for J := 0 to lNode.BindingCount - 1 do
    begin
      lBinding := lNode.Bindings[J];
      lBindingJson := TJSONObject.Create;
      lBindingsArray.Add(lBindingJson);
      
      lBindingJson.Add('sourceTagName', lBinding.SourceTagName);
      lBindingJson.Add('outputPrefix', lBinding.OutputPrefix);
      lBindingJson.Add('useOwnSettings', lBinding.UseOwnSettings);
      lBindingJson.Add('settings', lBinding.Settings.AsString);
    end;
  end;
end;

procedure SaveFrequencyBands(AJson: TJSONArray; AList: TRecorderFrequencyBandList);
var
  I, J: Integer;
  lBand: TRecorderFrequencyBand;
  lItem, lTermJson: TJSONObject;
  lTermsArray: TJSONArray;
  lTerm: TRecorderFrequencyBandTerm;
begin
  if (AJson = nil) or (AList = nil) then Exit;
  for I := 0 to AList.BandCount - 1 do
  begin
    lBand := AList.Bands[I];
    lItem := TJSONObject.Create;
    AJson.Add(lItem);
    
    lItem.Add('name', lBand.Name);
    lItem.Add('kind', Ord(lBand.Kind));
    lItem.Add('x1', lBand.X1);
    lItem.Add('x2', lBand.X2);
    
    lTermsArray := JsonArray(lItem, 'terms');
    for J := 0 to lBand.TermCount - 1 do
    begin
      lTerm := lBand.Terms[J];
      lTermJson := TJSONObject.Create;
      lTermsArray.Add(lTermJson);
      
      lTermJson.Add('tagName', lTerm.TagName);
      lTermJson.Add('coefficient', lTerm.Coefficient);
    end;
  end;
end;

procedure LoadFrequencyBands(AJson: TJSONArray; AList: TRecorderFrequencyBandList);
var
  I, J: Integer;
  lItem, lTermJson: TJSONObject;
  lBand: TRecorderFrequencyBand;
  lTermsArray: TJSONArray;
  lTerm: TRecorderFrequencyBandTerm;
begin
  if (AJson = nil) or (AList = nil) then Exit;
  AList.Clear;
  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then Continue;
    lItem := TJSONObject(AJson.Items[I]);
    
    lBand := AList.AddBand(lItem.Get('name', ''));
    lBand.Kind := TRecorderFrequencyBandKind(lItem.Get('kind', Ord(fbkAbsoluteHz)));
    lBand.X1 := lItem.Get('x1', 0.0);
    lBand.X2 := lItem.Get('x2', 0.0);
    
    lTermsArray := FindArray(lItem, 'terms');
    if lTermsArray <> nil then
    begin
      for J := 0 to lTermsArray.Count - 1 do
      begin
        if not (lTermsArray.Items[J] is TJSONObject) then Continue;
        lTermJson := TJSONObject(lTermsArray.Items[J]);
        
        lBand.AddTerm(
          lTermJson.Get('tagName', ''),
          lTermJson.Get('coefficient', 1.0)
        );
      end;
    end;
  end;
end;

procedure LoadSpectrumConfigs(AJson: TJSONArray; ATree: TRecorderSpectrumConfigTree);
var
  I, J: Integer;
  lItem, lBindingJson: TJSONObject;
  lNode: TRecorderSpectrumConfigNode;
  lBindingsArray: TJSONArray;
  lBinding: TRecorderSpectrumTagBinding;
  lSettingsStr: string;
begin
  if (AJson = nil) or (ATree = nil) then Exit;
  ATree.Clear;
  for I := 0 to AJson.Count - 1 do
  begin
    if not (AJson.Items[I] is TJSONObject) then Continue;
    lItem := TJSONObject(AJson.Items[I]);
    
    lNode := ATree.AddNode(
      lItem.Get('id', ''),
      lItem.Get('displayName', '')
    );
    
    lSettingsStr := lItem.Get('settings', '');
    lNode.Settings.FromString(lSettingsStr);
    
    lBindingsArray := FindArray(lItem, 'bindings');
    if lBindingsArray <> nil then
    begin
      for J := 0 to lBindingsArray.Count - 1 do
      begin
        if not (lBindingsArray.Items[J] is TJSONObject) then Continue;
        lBindingJson := TJSONObject(lBindingsArray.Items[J]);
        
        lBinding := lNode.AddBinding(lBindingJson.Get('sourceTagName', ''));
        lBinding.OutputPrefix := lBindingJson.Get('outputPrefix', '');
        lBinding.UseOwnSettings := lBindingJson.Get('useOwnSettings', False);
        
        lSettingsStr := lBindingJson.Get('settings', '');
        lBinding.Settings.FromString(lSettingsStr);
      end;
    end;
  end;
end;

procedure SaveRecorderProjectConfig(const AFileName: string;
  ATags: TRecorderTagRegistry);
var
  I: Integer;
  lRoot: TJSONObject;
  lTags: TJSONArray;
  lTagJson: TJSONObject;
  lTag: TRecorderTag;
  lText: TStringList;
begin
  if ATags = nil then
    raise ERecorderTagError.Create('Tag registry is not assigned');

  ForceDirectories(ExtractFileDir(AFileName));
  lRoot := TJSONObject.Create;
  try
    lRoot.Add('format', 'RecorderLnx.ProjectConfig');
    lRoot.Add('version', 1);
    RecorderMic140RebuildDeviceConfigsFromTags(ATags);
    SaveDataSources(lRoot, ATags);
    SaveMic140DeviceConfigs(lRoot, ATags);
    SaveCalibrationList(JsonArray(lRoot, 'calibrations'), ATags.Calibrations);
    SaveSpectrumConfigs(JsonArray(lRoot, 'spectrumConfigs'), ATags.SpectrumConfigs);
    SaveFrequencyBands(JsonArray(lRoot, 'frequencyBands'), ATags.FrequencyBands);

    lTags := JsonArray(lRoot, 'tags');
    for I := 0 to ATags.TagCount - 1 do
    begin
      lTag := ATags.Tags[I];
      lTagJson := TJSONObject.Create;
      lTags.Add(lTagJson);

      lTagJson.Add('id', lTag.Id);
      lTagJson.Add('name', lTag.Name);
      lTagJson.Add('address', lTag.Address);
      lTagJson.Add('unit', lTag.UnitName);
      lTagJson.Add('description', lTag.Description);
      lTagJson.Add('sourceId', lTag.SourceId);
      lTagJson.Add('sourceValueMode', lTag.SourceValueMode);
      lTagJson.Add('moduleType', lTag.ModuleType);
      lTagJson.Add('pollFrequencyHz', lTag.PollFrequencyHz);
      lTagJson.Add('rangeMin', lTag.RangeMin);
      lTagJson.Add('rangeMax', lTag.RangeMax);
      lTagJson.Add('autoRange', lTag.AutoRange);
      lTagJson.Add('autoUnit', lTag.AutoUnit);
      lTagJson.Add('channelCalibrationEnabled', lTag.ChannelCalibrationEnabled);
      if RecorderTagUsesMic140Settings(lTag) then
        RecorderTagClearMic140Settings(lTag);
      SaveTagEstimates(JsonObject(lTagJson, 'estimates'), lTag);
      SaveTagSetpoints(JsonObject(lTagJson, 'setpoints'), lTag);
      SaveTagCalibrationPipeline(JsonArray(lTagJson, 'calibrationPipeline'), lTag);
    end;

    lText := TStringList.Create;
    try
      lText.Text := lRoot.FormatJSON([foUseTabchar], 2);
      lText.SaveToFile(AFileName);
    finally
      lText.Free;
    end;
  finally
    lRoot.Free;
  end;
end;

procedure LoadRecorderProjectConfig(const AFileName: string;
  ATags: TRecorderTagRegistry);
var
  I: Integer;
  lData: TJSONData;
  lRoot: TJSONObject;
  lTag: TRecorderTag;
  lTagJson: TJSONObject;
  lTags: TJSONArray;
  lText: TStringList;
begin
  if not FileExists(AFileName) then
    Exit;
  if ATags = nil then
    raise ERecorderTagError.Create('Tag registry is not assigned');

  lText := TStringList.Create;
  try
    lText.LoadFromFile(AFileName);
    lData := GetJSON(lText.Text);
  finally
    lText.Free;
  end;

  try
    if not (lData is TJSONObject) then
      raise ERecorderTagError.Create('Project config root must be a JSON object');

    lRoot := TJSONObject(lData);
    lTags := FindArray(lRoot, 'tags');
    if lTags = nil then
      Exit;

    ATags.Clear;
    LoadCalibrationList(FindArray(lRoot, 'calibrations'), ATags.Calibrations);
    LoadSpectrumConfigs(FindArray(lRoot, 'spectrumConfigs'), ATags.SpectrumConfigs);
    LoadFrequencyBands(FindArray(lRoot, 'frequencyBands'), ATags.FrequencyBands);
    for I := 0 to lTags.Count - 1 do
    begin
      if not (lTags.Items[I] is TJSONObject) then
        Continue;

      lTagJson := TJSONObject(lTags.Items[I]);
      lTag := TRecorderTag.Create(lTagJson.Get('id', Int64(I + 1)),
        lTagJson.Get('name', 'Tag' + IntToStr(I + 1)), 4096);
      try
        lTag.Address := lTagJson.Get('address', lTag.Address);
        lTag.UnitName := lTagJson.Get('unit', lTag.UnitName);
        lTag.Description := lTagJson.Get('description', lTag.Description);
        lTag.SourceId := lTagJson.Get('sourceId', lTag.SourceId);
        lTag.SourceValueMode := lTagJson.Get('sourceValueMode', lTag.SourceValueMode);
        lTag.ModuleType := lTagJson.Get('moduleType', lTag.ModuleType);
        lTag.PollFrequencyHz := lTagJson.Get('pollFrequencyHz',
          lTag.PollFrequencyHz);
        lTag.RangeMin := lTagJson.Get('rangeMin', lTag.RangeMin);
        lTag.RangeMax := lTagJson.Get('rangeMax', lTag.RangeMax);
        lTag.AutoRange := lTagJson.Get('autoRange', lTag.AutoRange);
        lTag.AutoUnit := lTagJson.Get('autoUnit', lTag.AutoUnit);
        lTag.ChannelCalibrationEnabled := lTagJson.Get('channelCalibrationEnabled',
          lTag.ChannelCalibrationEnabled);
        if RecorderTagUsesMic140Settings(lTag) then
        begin
          lTag.MeasRangeIndex := lTagJson.Get('measRangeIndex', lTag.MeasRangeIndex);
          lTag.HardwareCalibrationEnabled := lTagJson.Get('hardwareCalibrationEnabled',
            lTag.HardwareCalibrationEnabled);
          lTag.HardwareCalibrationName := lTagJson.Get('hardwareCalibrationName',
            lTag.HardwareCalibrationName);
          lTag.Mic140DeviceSerial := lTagJson.Get('mic140DeviceSerial',
            lTag.Mic140DeviceSerial);
          lTag.Mic140ThermoCompensationEnabled := lTagJson.Get(
            'mic140ThermoCompensationEnabled', lTag.Mic140ThermoCompensationEnabled);
          lTag.Mic140CjcDefault := lTagJson.Get('mic140CjcDefault',
            lTag.Mic140CjcDefault);
          lTag.Mic140CjcChannel := lTagJson.Get('mic140CjcChannel',
            lTag.Mic140CjcChannel);
          lTag.Mic140ThermocoupleScaleName := lTagJson.Get(
            'mic140ThermocoupleScaleName', lTag.Mic140ThermocoupleScaleName);
          lTag.Mic140ThermocoupleScalePath := lTagJson.Get(
            'mic140ThermocoupleScalePath', lTag.Mic140ThermocoupleScalePath);
          lTag.Mic140SoftBalance := lTagJson.Get('mic140SoftBalance',
            lTag.Mic140SoftBalance);
        end
        else
          RecorderTagClearMic140Settings(lTag);
        LoadTagEstimates(FindObject(lTagJson, 'estimates'), lTag);
        LoadTagSetpoints(FindObject(lTagJson, 'setpoints'), lTag);
        LoadTagCalibrationPipeline(FindArray(lTagJson, 'calibrationPipeline'), lTag);
        ATags.AddTag(lTag);
        lTag := nil;
      finally
        lTag.Free;
      end;
    end;
    LoadMic140DeviceConfigs(lRoot, ATags);
    RecorderMic140RebuildDeviceConfigsFromTags(ATags);
  finally
    lData.Free;
  end;
end;

procedure SaveRecorderGuiConfig(const AFileName: string;
  AForms: TRecorderFormManager);
var
  I: Integer;
  J: Integer;
  K: Integer;
  lAxis: TRecorderTrendAxis;
  lComponent: TRecorderVisualComponent;
  lIni: TIniFile;
  lLine: TRecorderTrendLine;
  lPage: TRecorderFormPage;
  lSection: string;
  lTrend: TRecorderTrendComponent;
  lSpectrum: TRecorderSpectrumComponent;
begin
  if AForms = nil then
    raise ERecorderFormError.Create('Form manager is not assigned');

  ForceDirectories(ExtractFileDir(AFileName));
  lIni := TIniFile.Create(AFileName);
  try
    lIni.EraseSection('Project');
    lIni.WriteInteger('Project', 'Version', 1);
    lIni.WriteInteger('Project', 'PageCount', AForms.PageCount);
    if AForms.ActivePage <> nil then
      lIni.WriteString('Project', 'ActivePageId', AForms.ActivePage.Id);

    for I := 0 to AForms.PageCount - 1 do
    begin
      lPage := AForms.Pages[I];
      lSection := Format('Page.%d', [I]);
      lIni.EraseSection(lSection);
      lIni.WriteString(lSection, 'Id', lPage.Id);
      lIni.WriteString(lSection, 'Name', lPage.Name);
      lIni.WriteString(lSection, 'Title', lPage.Title);
      lIni.WriteInteger(lSection, 'Mode', Ord(lPage.Mode));
      lIni.WriteInteger(lSection, 'BaseOscillogramCount',
        lPage.BaseOscillogramCount);
      lIni.WriteInteger(lSection, 'ComponentCount', lPage.ComponentCount);

      for J := 0 to lPage.ComponentCount - 1 do
      begin
        lComponent := lPage.Components[J];
        lSection := Format('Page.%d.Component.%d', [I, J]);
        lIni.EraseSection(lSection);
        lIni.WriteString(lSection, 'Type', ComponentTypeOf(lComponent));
        lIni.WriteString(lSection, 'Id', lComponent.Id);
        lIni.WriteString(lSection, 'Name', lComponent.Name);
        lIni.WriteString(lSection, 'TagName', lComponent.TagName);
        lIni.WriteInt64(lSection, 'TagId', lComponent.TagId);
        lIni.WriteInteger(lSection, 'Left', lComponent.Bounds.Left);
        lIni.WriteInteger(lSection, 'Top', lComponent.Bounds.Top);
        lIni.WriteInteger(lSection, 'Width', lComponent.Bounds.Width);
        lIni.WriteInteger(lSection, 'Height', lComponent.Bounds.Height);
        if lComponent is TRecorderStaticTextComponent then
          lIni.WriteString(lSection, 'Text',
            TRecorderStaticTextComponent(lComponent).Text);
        if lComponent is TRecorderTagValueComponent then
          lIni.WriteString(lSection, 'DisplayFormat',
            TRecorderTagValueComponent(lComponent).DisplayFormat);
        if lComponent is TRecorderOscillogramComponent then
        begin
          lIni.WriteInteger(lSection, 'BindingMode',
            Ord(TRecorderOscillogramComponent(lComponent).BindingMode));
          lIni.WriteInteger(lSection, 'TagOffset',
            TRecorderOscillogramComponent(lComponent).TagOffset);
          lIni.WriteInteger(lSection, 'OscLineCount',
            TRecorderOscillogramComponent(lComponent).LineCount);
          for K := 0 to TRecorderOscillogramComponent(lComponent).LineCount - 1 do
          begin
            lLine := TRecorderOscillogramComponent(lComponent).Lines[K];
            lIni.WriteString(lSection, Format('OscLine%dName', [K]), lLine.TagName);
            lIni.WriteString(lSection, Format('OscLine%dTagName', [K]), lLine.TagName);
            lIni.WriteInt64(lSection, Format('OscLine%dTagId', [K]), lLine.TagId);
            lIni.WriteInteger(lSection, Format('OscLine%dColor', [K]), lLine.Color);
            lIni.WriteBool(lSection, Format('OscLine%dVisible', [K]), lLine.Visible);
          end;
        end;
        if lComponent is TRecorderSpectrumComponent then
        begin
          lSpectrum := TRecorderSpectrumComponent(lComponent);
          lIni.WriteFloat(lSection, 'RangeMinX', lSpectrum.RangeMinX);
          lIni.WriteFloat(lSection, 'RangeMaxX', lSpectrum.RangeMaxX);
          lIni.WriteFloat(lSection, 'RangeMinY', lSpectrum.RangeMinY);
          lIni.WriteFloat(lSection, 'RangeMaxY', lSpectrum.RangeMaxY);
          lIni.WriteBool(lSection, 'LgX', lSpectrum.LgX);
          lIni.WriteBool(lSection, 'LgY', lSpectrum.LgY);
          lIni.WriteBool(lSection, 'ShowAlarms', lSpectrum.ShowAlarms);
          lIni.WriteBool(lSection, 'ShowWarnings', lSpectrum.ShowWarnings);
          lIni.WriteBool(lSection, 'ShowProfile', lSpectrum.ShowProfile);
          lIni.WriteBool(lSection, 'ShowLabels', lSpectrum.ShowLabels);
          lIni.WriteBool(lSection, 'LegendVisible', lSpectrum.LegendVisible);
          lIni.WriteBool(lSection, 'ZeroY0', lSpectrum.ZeroY0);
          lIni.WriteInteger(lSection, 'ResultType', lSpectrum.ResultType);
          lIni.WriteString(lSection, 'TahoTagName', lSpectrum.TahoTagName);
          lIni.WriteInt64(lSection, 'TahoTagId', lSpectrum.TahoTagId);
          lIni.WriteString(lSection, 'ProfileName', lSpectrum.ProfileName);
          lIni.WriteInteger(lSection, 'TagCount', lSpectrum.TagNames.Count);
          for K := 0 to lSpectrum.TagNames.Count - 1 do
            lIni.WriteString(lSection, Format('Tag%d', [K]), lSpectrum.TagNames[K]);
            if lSpectrum.TagIdAt(K) <> 0 then
              lIni.WriteInt64(lSection, Format('Tag%dId', [K]), lSpectrum.TagIdAt(K));
        end;
        if lComponent is TRecorderTrendComponent then
        begin
          lTrend := TRecorderTrendComponent(lComponent);
          lIni.WriteFloat(lSection, 'DurationSec', lTrend.DurationSec);
          lIni.WriteFloat(lSection, 'UpdatePeriodSec', lTrend.UpdatePeriodSec);
          lIni.WriteInteger(lSection, 'YAxisMode', Ord(lTrend.YAxisMode));
          lIni.WriteBool(lSection, 'LegendVisible', lTrend.LegendVisible);
          lIni.WriteBool(lSection, 'ShowCurrentValues', lTrend.ShowCurrentValues);
          lIni.WriteInteger(lSection, 'AxisCount', lTrend.AxisCount);
          lIni.WriteInteger(lSection, 'LineCount', lTrend.LineCount);
          for K := 0 to lTrend.AxisCount - 1 do
          begin
            lAxis := lTrend.Axes[K];
            lIni.WriteString(lSection, Format('Axis%dName', [K]), lAxis.Name);
            lIni.WriteInteger(lSection, Format('Axis%dColor', [K]), lAxis.Color);
            lIni.WriteFloat(lSection, Format('Axis%dRangeMin', [K]), lAxis.RangeMin);
            lIni.WriteFloat(lSection, Format('Axis%dRangeMax', [K]), lAxis.RangeMax);
          end;
          for K := 0 to lTrend.LineCount - 1 do
          begin
            lLine := lTrend.Lines[K];
            lIni.WriteString(lSection, Format('Line%dName', [K]), lLine.Name);
            lIni.WriteString(lSection, Format('Line%dTagName', [K]), lLine.TagName);
            lIni.WriteInt64(lSection, Format('Line%dTagId', [K]), lLine.TagId);
            lIni.WriteInteger(lSection, Format('Line%dEstimateKind', [K]), Ord(lLine.EstimateKind));
            lIni.WriteInteger(lSection, Format('Line%dAxisIndex', [K]), lLine.AxisIndex);
            lIni.WriteInteger(lSection, Format('Line%dColor', [K]), lLine.Color);
            lIni.WriteInteger(lSection, Format('Line%dWidth', [K]), lLine.Width);
            lIni.WriteBool(lSection, Format('Line%dVisible', [K]), lLine.Visible);
          end;
        end;      end;
    end;
  finally
    lIni.Free;
  end;
end;

procedure LoadRecorderGuiConfig(const AFileName: string;
  AForms: TRecorderFormManager; AFactory: TRecorderComponentFactory);
var
  I: Integer;
  J: Integer;
  K: Integer;
  lAxis: TRecorderTrendAxis;
  lComponent: TRecorderVisualComponent;
  lCount: Integer;
  lItemCount: Integer;
  lLine: TRecorderTrendLine;
  lPage: TRecorderFormPage;
  lPaletteColor: LongInt;
  lPaletteName: string;
  lSection: string;
  lTrend: TRecorderTrendComponent;
  lSpectrum: TRecorderSpectrumComponent;
  lTypeId: string;
  lIni: TIniFile;
begin
  if not FileExists(AFileName) then
    Exit;
  if (AForms = nil) or (AFactory = nil) then
    raise ERecorderFormError.Create('Form manager or component factory is not assigned');

  lIni := TIniFile.Create(AFileName);
  try
    AForms.Clear;
    lCount := lIni.ReadInteger('Project', 'PageCount', 0);
    for I := 0 to lCount - 1 do
    begin
      lSection := Format('Page.%d', [I]);
      lPage := TRecorderFormPage.Create(
        lIni.ReadString(lSection, 'Id', 'Page' + IntToStr(I + 1)),
        lIni.ReadString(lSection, 'Name', 'Page' + IntToStr(I + 1)),
        lIni.ReadString(lSection, 'Title', 'Page ' + IntToStr(I + 1)));
      try
        lPage.Mode := TRecorderFormPageMode(lIni.ReadInteger(lSection, 'Mode',
          Ord(fpmView)));
        lPage.BaseOscillogramCount := lIni.ReadInteger(lSection,
          'BaseOscillogramCount', lPage.BaseOscillogramCount);
        AForms.AddPage(lPage);
        lPage := nil;
      finally
        lPage.Free;
      end;

      lPage := AForms.Pages[AForms.PageCount - 1];
      for J := 0 to lIni.ReadInteger(lSection, 'ComponentCount', 0) - 1 do
      begin
        lSection := Format('Page.%d.Component.%d', [I, J]);
        lTypeId := lIni.ReadString(lSection, 'Type', '');
        if not AFactory.IsComponentRegistered(lTypeId) then
          Continue;

        lComponent := AFactory.CreateComponent(lTypeId);
        try
          lComponent.Id := lIni.ReadString(lSection, 'Id', '');
          lComponent.Name := lIni.ReadString(lSection, 'Name', '');
          lComponent.TagName := lIni.ReadString(lSection, 'TagName', '');
          lComponent.TagId := lIni.ReadInt64(lSection, 'TagId', 0);
          lComponent.SetBounds(
            lIni.ReadInteger(lSection, 'Left', 0),
            lIni.ReadInteger(lSection, 'Top', 0),
            lIni.ReadInteger(lSection, 'Width', 0),
            lIni.ReadInteger(lSection, 'Height', 0));
          if lComponent is TRecorderStaticTextComponent then
            TRecorderStaticTextComponent(lComponent).Text :=
              lIni.ReadString(lSection, 'Text', '');
          if lComponent is TRecorderTagValueComponent then
            TRecorderTagValueComponent(lComponent).DisplayFormat :=
              lIni.ReadString(lSection, 'DisplayFormat', '0.###');
          if lComponent is TRecorderOscillogramComponent then
          begin
            TRecorderOscillogramComponent(lComponent).BindingMode :=
              TRecorderTagBindingMode(lIni.ReadInteger(lSection, 'BindingMode',
                Ord(rtbmRelativeSelectedTag)));
            TRecorderOscillogramComponent(lComponent).TagOffset :=
              lIni.ReadInteger(lSection, 'TagOffset', 0);
            lItemCount := lIni.ReadInteger(lSection, 'OscLineCount', 0);
            TRecorderOscillogramComponent(lComponent).ClearLines;
            for K := 0 to lItemCount - 1 do
            begin
              lLine := TRecorderOscillogramComponent(lComponent).AddLine;
              lLine.TagName := lIni.ReadString(lSection, Format('OscLine%dTagName', [K]), '');
              lLine.TagId := lIni.ReadInt64(lSection, Format('OscLine%dTagId', [K]), 0);
              lLine.Color := lIni.ReadInteger(lSection, Format('OscLine%dColor', [K]),
                lLine.Color);
              lLine.Name := OglChartLinePaletteNameForColor(TColor(lLine.Color));
              if lLine.Name = '' then
                lLine.Name := lIni.ReadString(lSection, Format('OscLine%dName', [K]), '');
              if lLine.Name = '' then
              begin
                OglChartLineAppearance(K + 1, lPaletteName, lPaletteColor);
                lLine.Name := lPaletteName;
                lLine.Color := lPaletteColor;
              end;
              lLine.Visible := lIni.ReadBool(lSection, Format('OscLine%dVisible', [K]), True);
            end;
          end;
          if lComponent is TRecorderSpectrumComponent then
          begin
            lSpectrum := TRecorderSpectrumComponent(lComponent);
            lSpectrum.RangeMinX := lIni.ReadFloat(lSection, 'RangeMinX', lSpectrum.RangeMinX);
            lSpectrum.RangeMaxX := lIni.ReadFloat(lSection, 'RangeMaxX', lSpectrum.RangeMaxX);
            lSpectrum.RangeMinY := lIni.ReadFloat(lSection, 'RangeMinY', lSpectrum.RangeMinY);
            lSpectrum.RangeMaxY := lIni.ReadFloat(lSection, 'RangeMaxY', lSpectrum.RangeMaxY);
            lSpectrum.LgX := lIni.ReadBool(lSection, 'LgX', lSpectrum.LgX);
            lSpectrum.LgY := lIni.ReadBool(lSection, 'LgY', lSpectrum.LgY);
            lSpectrum.ShowAlarms := lIni.ReadBool(lSection, 'ShowAlarms', lSpectrum.ShowAlarms);
            lSpectrum.ShowWarnings := lIni.ReadBool(lSection, 'ShowWarnings', lSpectrum.ShowWarnings);
            lSpectrum.ShowProfile := lIni.ReadBool(lSection, 'ShowProfile', lSpectrum.ShowProfile);
            lSpectrum.ShowLabels := lIni.ReadBool(lSection, 'ShowLabels', lSpectrum.ShowLabels);
            lSpectrum.LegendVisible := lIni.ReadBool(lSection, 'LegendVisible', lSpectrum.LegendVisible);
            lSpectrum.ZeroY0 := lIni.ReadBool(lSection, 'ZeroY0', lSpectrum.ZeroY0);
            lSpectrum.ResultType := lIni.ReadInteger(lSection, 'ResultType', lSpectrum.ResultType);
            lSpectrum.TahoTagName := lIni.ReadString(lSection, 'TahoTagName', lSpectrum.TahoTagName);
            lSpectrum.TahoTagId := lIni.ReadInt64(lSection, 'TahoTagId', 0);
            lSpectrum.ProfileName := lIni.ReadString(lSection, 'ProfileName', lSpectrum.ProfileName);
            lSpectrum.TagNames.Clear;
            lItemCount := lIni.ReadInteger(lSection, 'TagCount', 0);
            for K := 0 to lItemCount - 1 do
            begin
              lSpectrum.TagNames.Add(lIni.ReadString(lSection, Format('Tag%d', [K]), ''));
              lSpectrum.SetTagIdAt(lSpectrum.TagNames.Count - 1,
                lIni.ReadInt64(lSection, Format('Tag%dId', [K]), 0));
            end;
          end;
          if lComponent is TRecorderTrendComponent then
          begin
            lTrend := TRecorderTrendComponent(lComponent);
            lTrend.DurationSec := lIni.ReadFloat(lSection, 'DurationSec', lTrend.DurationSec);
            lTrend.UpdatePeriodSec := lIni.ReadFloat(lSection, 'UpdatePeriodSec', lTrend.UpdatePeriodSec);
            lTrend.YAxisMode := TRecorderTrendYAxisMode(lIni.ReadInteger(lSection, 'YAxisMode', Ord(lTrend.YAxisMode)));
            lTrend.LegendVisible := lIni.ReadBool(lSection, 'LegendVisible', lTrend.LegendVisible);
            lTrend.ShowCurrentValues := lIni.ReadBool(lSection, 'ShowCurrentValues', lTrend.ShowCurrentValues);
            lTrend.ClearAxes;
            lItemCount := lIni.ReadInteger(lSection, 'AxisCount', 1);
            for K := 0 to lItemCount - 1 do
            begin
              lAxis := lTrend.AddAxis;
              lAxis.Name := lIni.ReadString(lSection, Format('Axis%dName', [K]), lAxis.Name);
              lAxis.Color := lIni.ReadInteger(lSection, Format('Axis%dColor', [K]), lAxis.Color);
              lAxis.RangeMin := lIni.ReadFloat(lSection, Format('Axis%dRangeMin', [K]), lAxis.RangeMin);
              lAxis.RangeMax := lIni.ReadFloat(lSection, Format('Axis%dRangeMax', [K]), lAxis.RangeMax);
            end;
            lTrend.ClearLines;
            lItemCount := lIni.ReadInteger(lSection, 'LineCount', 0);
            for K := 0 to lItemCount - 1 do
            begin
              lLine := lTrend.AddLine;
              lLine.TagName := lIni.ReadString(lSection, Format('Line%dTagName', [K]), lLine.TagName);
              lLine.TagId := lIni.ReadInt64(lSection, Format('Line%dTagId', [K]), 0);
              lLine.EstimateKind := TRecorderTagEstimateKind(lIni.ReadInteger(lSection, Format('Line%dEstimateKind', [K]), Ord(lLine.EstimateKind)));
              lLine.AxisIndex := lIni.ReadInteger(lSection, Format('Line%dAxisIndex', [K]), lLine.AxisIndex);
              lLine.Color := lIni.ReadInteger(lSection, Format('Line%dColor', [K]), lLine.Color);
              lLine.Name := OglChartLinePaletteNameForColor(TColor(lLine.Color));
              if lLine.Name = '' then
                lLine.Name := lIni.ReadString(lSection, Format('Line%dName', [K]), lLine.Name);
              if lLine.Name = '' then
              begin
                OglChartLineAppearance(K, lPaletteName, lPaletteColor);
                lLine.Name := lPaletteName;
                lLine.Color := lPaletteColor;
              end;
              lLine.Width := lIni.ReadInteger(lSection, Format('Line%dWidth', [K]), lLine.Width);
              lLine.Visible := lIni.ReadBool(lSection, Format('Line%dVisible', [K]), lLine.Visible);
            end;
          end;          lPage.AddComponent(lComponent);
          lComponent := nil;
        finally
          lComponent.Free;
        end;
      end;
    end;

    AForms.TrySetActivePageById(lIni.ReadString('Project', 'ActivePageId', ''));
  finally
    lIni.Free;
  end;
end;

end.
