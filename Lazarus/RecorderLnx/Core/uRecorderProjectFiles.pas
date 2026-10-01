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
  Classes, SysUtils, DateUtils, Math, fpjson,
  uRecorderFormModel, uRecorderTags, uRecorderNetworkBinding,
  uRecorderVibrationEstimate;

type
  TRecorderProjectConfigExtensionProc = procedure(AJson: TJSONObject;
    ARegistry: TRecorderTagRegistry);
  TRecorderProjectTagLoadedExtensionProc = procedure(AJson: TJSONObject;
    ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);

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
procedure LoadRecorderProjectConfig(const AFileName: string;
  ATags: TRecorderTagRegistry);

procedure RecorderRegisterProjectConfigExtension(
  ASaveProc, ALoadProc: TRecorderProjectConfigExtensionProc;
  ATagLoadedProc: TRecorderProjectTagLoadedExtensionProc = nil;
  ABeforeSaveProc: TRecorderProjectConfigExtensionProc = nil);

{ Сохраняет структуру страниц формуляров и их компонентов в INI-файл }
procedure SaveRecorderGuiConfig(const AFileName: string;
  AForms: TRecorderFormManager);
{ Загружает структуру страниц формуляров из INI-файла }
procedure LoadRecorderGuiConfig(const AFileName: string;
  AForms: TRecorderFormManager; AFactory: TRecorderComponentFactory);

implementation

uses
  IniFiles, jsonparser, Graphics, uRecorderSpectrumEngine, uRecorderFrequencyBands,
  uOglChartColors, uRecorderConfiguredDataSources, uRecorderSqlTrendModel,
  uRecorderMeasurementSectionModel, uRecorderFrequencyResponseModel,
  uRecorder3dModel, uRecorderSignalGeneratorModel,
  uRecorderFrequencyResponse, uRecorderSdbStore, uRecorderDebugLog,
  uRecorderStrainCalibration;

const
  CRecorderProjectConfigExtensionMax = 32;

type
  TRecorderProjectConfigExtension = record
    SaveProc: TRecorderProjectConfigExtensionProc;
    LoadProc: TRecorderProjectConfigExtensionProc;
    TagLoadedProc: TRecorderProjectTagLoadedExtensionProc;
    BeforeSaveProc: TRecorderProjectConfigExtensionProc;
  end;

var
  g_ProjectConfigExtensions: array[0..CRecorderProjectConfigExtensionMax - 1]
    of TRecorderProjectConfigExtension;
  g_ProjectConfigExtensionCount: Integer = 0;

function MakeFontSnapshot(const AName: string; ASize, AColor: Integer;
  ABold, AItalic: Boolean): TRecorderFontSnapshot;
begin
  Result.Name := AName;
  Result.Size := ASize;
  Result.Color := AColor;
  Result.Bold := ABold;
  Result.Italic := AItalic;
end;

function ProjectTagBelongsToDeletedSource(ATags: TRecorderTagRegistry;
  ATag: TRecorderTag): Boolean;
var
  lSourceId: string;
begin
  Result := False;
  if (ATags = nil) or (ATag = nil) then
    Exit;
  { Отвязанные теги являются частью проекта: удален только источник, а не тег. }
  if RecorderIsDetachedTagSource(ATag.SourceId) then
    Exit;
  if ATags.ConfiguredDataSources.Count = 0 then
    Exit;

  lSourceId := RecorderNormalizeTagSourceId(ATag.SourceId);
  if lSourceId = '' then
    Exit;
  if SameText(lSourceId, 'manual') or SameText(lSourceId, 'debug.diagnostics') then
    Exit;
  if Pos('spectrum:', LowerCase(lSourceId)) = 1 then
    Exit;
  if not (RecorderIsVirtualTagSource(lSourceId) or
    RecorderIsHardwareTagSource(lSourceId)) then
    Exit;

  Result := RecorderConfiguredDataSourcesFind(ATags, lSourceId) = nil;
end;

procedure RecorderRegisterProjectConfigExtension(
  ASaveProc, ALoadProc: TRecorderProjectConfigExtensionProc;
  ATagLoadedProc: TRecorderProjectTagLoadedExtensionProc;
  ABeforeSaveProc: TRecorderProjectConfigExtensionProc);
begin
  if g_ProjectConfigExtensionCount >= CRecorderProjectConfigExtensionMax then
    raise Exception.Create('Too many project config extensions');
  g_ProjectConfigExtensions[g_ProjectConfigExtensionCount].SaveProc := ASaveProc;
  g_ProjectConfigExtensions[g_ProjectConfigExtensionCount].LoadProc := ALoadProc;
  g_ProjectConfigExtensions[g_ProjectConfigExtensionCount].TagLoadedProc := ATagLoadedProc;
  g_ProjectConfigExtensions[g_ProjectConfigExtensionCount].BeforeSaveProc := ABeforeSaveProc;
  Inc(g_ProjectConfigExtensionCount);
end;

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
  if AComponent.Factory <> nil then
    Result := AComponent.Factory.TypeId
  else if AComponent is TRecorderStaticTextComponent then
    Result := TRecorderStaticTextComponent.TypeId
  else if AComponent is TRecorderButtonComponent then
    Result := TRecorderButtonComponent.TypeId
  else if AComponent is TRecorderInputFieldComponent then
    Result := TRecorderInputFieldComponent.TypeId
  else if AComponent is TRecorderTagValueComponent then
    Result := TRecorderTagValueComponent.TypeId
  else if AComponent is TRecorderVibrationEstimateComponent then
    Result := TRecorderVibrationEstimateComponent.TypeId
  else if AComponent is TRecorderImageComponent then
    Result := TRecorderImageComponent.TypeId
  else if AComponent is TRecorderOscillogramComponent then
    Result := TRecorderOscillogramComponent.TypeId
  else if AComponent is TRecorderSqlTrendComponent then
    Result := TRecorderSqlTrendComponent.TypeId
  else if AComponent is TRecorderMeasurementSectionComponent then
    Result := TRecorderMeasurementSectionComponent.TypeId
  else if AComponent is TRecorderTrendComponent then
    Result := TRecorderTrendComponent.TypeId
  else if AComponent is TRecorderSpectrumComponent then
    Result := TRecorderSpectrumComponent.TypeId
  else if AComponent is TRecorderLissajousComponent then
    Result := TRecorderLissajousComponent.TypeId
  else if AComponent is TRecorderDonutComponent then
    Result := TRecorderDonutComponent.TypeId
  else if AComponent is TRecorder3dComponent then
    Result := TRecorder3dComponent.TypeId
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
    rckLinear: Result := 'linear';
    rckPolynomial: Result := 'polynomial';
    rckStrain: Result := 'strain';
  else
    Result := 'piecewiseLinear';
  end;
end;

function ConfigNameToCalibrationKind(const AName: string): TRecorderCalibrationKind;
begin
  if SameText(AName, 'scale') then
    Result := rckScale
  else if SameText(AName, 'linear') then
    Result := rckLinear
  else if SameText(AName, 'polynomial') then
    Result := rckPolynomial
  else if SameText(AName, 'strain') then
    Result := rckStrain
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
    if Trim(lCalibration.SourceFileName) <> '' then
      lItem.Add('sourceFileName', lCalibration.SourceFileName);
    if Trim(lCalibration.SdbKey) <> '' then
    begin
      lItem.Add('sdbKey', lCalibration.SdbKey);
      Continue;
    end;
    lItem.Add('description', lCalibration.Description);
    lItem.Add('unitIn', lCalibration.UnitIn);
    lItem.Add('unitOut', lCalibration.UnitOut);
    lItem.Add('extrapolation', lCalibration.Extrapolation);
    lItem.Add('scale', lCalibration.Scale);
    lItem.Add('offset', lCalibration.Offset);
    lItem.Add('k1', lCalibration.K1);
    lItem.Add('k2', lCalibration.K2);
    lItem.Add('moduleData', lCalibration.ModuleData);
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
  lError: string;
  lMaxRelativeError: Double;
  lItem: TJSONObject;
  lPoint: TJSONObject;
  lPoints: TJSONArray;
  lStrainConfig: TRecorderStrainConfig;
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
      lCalibration.SdbKey := lItem.Get('sdbKey', '');
      lCalibration.SourceFileName := lItem.Get('sourceFileName', '');
      if lCalibration.SdbKey <> '' then
      begin
        if RecorderSdbLoadScaleCalibration(lCalibration.SdbKey,
          lCalibration) then
          lCalibration.SdbKey := lItem.Get('sdbKey', '');
        lCalibration.Name := lItem.Get('name', lCalibration.Name);
        AList.Add(lCalibration);
        lCalibration := nil;
        Continue;
      end;
      lCalibration.Description := lItem.Get('description', '');
      lCalibration.UnitIn := lItem.Get('unitIn', '');
      lCalibration.UnitOut := lItem.Get('unitOut', '');
      lCalibration.Extrapolation := lItem.Get('extrapolation', True);
      lCalibration.Scale := lItem.Get('scale', 1.0);
      lCalibration.Offset := lItem.Get('offset', 0.0);
      lCalibration.K1 := lItem.Get('k1', 1.0);
      lCalibration.K2 := lItem.Get('k2', 0.0);
      lCalibration.ModuleData := lItem.Get('moduleData', '');
      { Коэффициенты встроенной Strain-ГХ являются производными от ModuleData.
        Пересобираем их при загрузке, чтобы исправления физической модели
        применялись и к ранее сохранённым проектам без ручного пересохранения. }
      if (lCalibration.Kind = rckStrain) and
        (Trim(lCalibration.ModuleData) <> '') then
      begin
        lStrainConfig := TRecorderStrainConfig.Create;
        try
          lStrainConfig.Load(lCalibration.ModuleData);
          if not RecorderStrainBuildCalibration(lStrainConfig, lCalibration,
            lMaxRelativeError, lError) then
            RecorderDebugLog(Format(
              'Strain calibration rebuild skipped name=%s: %s',
              [lCalibration.Name, lError]));
        finally
          lStrainConfig.Free;
        end;
      end;
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
  lItem: TJSONObject;
begin
  if (ATag = nil) or (ATag.CalibrationNames = nil) then
    Exit;
  for I := 0 to ATag.CalibrationNames.Count - 1 do
    if RecorderCalibrationStepEnabled(ATag.CalibrationNames, I) then
      AJson.Add(ATag.CalibrationNames[I])
    else
    begin
      lItem := TJSONObject.Create;
      lItem.Add('name', ATag.CalibrationNames[I]);
      lItem.Add('enabled', False);
      AJson.Add(lItem);
    end;
end;

procedure LoadTagCalibrationPipeline(AJson: TJSONArray; ATag: TRecorderTag);
var
  I: Integer;
  lItem: TJSONObject;
  lIndex: Integer;
begin
  if (ATag = nil) or (ATag.CalibrationNames = nil) then
    Exit;
  ATag.CalibrationNames.Clear;
  if AJson = nil then
    Exit;
  for I := 0 to AJson.Count - 1 do
    if AJson.Items[I] is TJSONObject then
    begin
      lItem := TJSONObject(AJson.Items[I]);
      lIndex := ATag.CalibrationNames.Add(lItem.Get('name', ''));
      RecorderSetCalibrationStepEnabled(ATag.CalibrationNames, lIndex,
        lItem.Get('enabled', True));
    end
    else
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
  AJson.Add('rangeControlEnabled', ATag.SetpointRangeControlEnabled);
  AJson.Add('rangeAlarmInfoText', ATag.SetpointRangeAlarmInfoText);

  for lKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
  begin
    lSetpoint := ATag.Setpoints[lKind];
    lItem := JsonObject(AJson, SetpointKindToConfigName(lKind));
    lItem.Add('enabled', lSetpoint.Enabled);
    lItem.Add('threshold', lSetpoint.Threshold);
    lItem.Add('alarmInfoText', lSetpoint.AlarmInfoText);
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
  ATag.SetpointRangeControlEnabled := AJson.Get('rangeControlEnabled',
    ATag.SetpointRangeControlEnabled);
  ATag.SetpointRangeAlarmInfoText := AJson.Get('rangeAlarmInfoText',
    ATag.SetpointRangeAlarmInfoText);

  for lKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
  begin
    lItem := FindObject(AJson, SetpointKindToConfigName(lKind));
    if lItem = nil then
      Continue;

    lSetpoint := ATag.Setpoints[lKind];
    lSetpoint.Enabled := lItem.Get('enabled', lSetpoint.Enabled);
    lSetpoint.Threshold := lItem.Get('threshold', lSetpoint.Threshold);
    lSetpoint.AlarmInfoText := lItem.Get('alarmInfoText',
      lSetpoint.AlarmInfoText);
    lSetpoint.Color := lItem.Get('color', Integer(lSetpoint.Color));
    lSetpoint.OutputEnabled := lItem.Get('outputEnabled',
      lSetpoint.OutputEnabled);
    lSetpoint.HysteresisPercent := lItem.Get('hysteresisPercent',
      lSetpoint.HysteresisPercent);
    ATag.Setpoints[lKind] := lSetpoint;
  end;
end;

procedure SaveDataSources(AJson: TJSONObject; ATags: TRecorderTagRegistry);
begin
  SaveRecorderConfiguredDataSources(AJson, ATags);
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

procedure SaveAlgorithmConfigs(AJson: TJSONArray; AConfigs: TStrings);
var
  I: Integer;
begin
  if (AJson = nil) or (AConfigs = nil) then
    Exit;
  for I := 0 to AConfigs.Count - 1 do
    AJson.Add(AConfigs[I]);
end;

procedure LoadAlgorithmConfigs(AJson: TJSONArray; AConfigs: TStrings);
var
  I: Integer;
begin
  if AConfigs = nil then
    Exit;
  AConfigs.Clear;
  if AJson = nil then
    Exit;
  for I := 0 to AJson.Count - 1 do
    AConfigs.Add(AJson.Strings[I]);
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
  I, J: Integer;
  lRoot: TJSONObject;
  lGroups: TJSONArray;
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
    lRoot.Add('networkBindAddress', RecorderNetworkBindAddress);
    for J := 0 to g_ProjectConfigExtensionCount - 1 do
      if Assigned(g_ProjectConfigExtensions[J].BeforeSaveProc) then
        g_ProjectConfigExtensions[J].BeforeSaveProc(lRoot, ATags);
    ATags.RemoveUnusedCalibrations;
    SaveDataSources(lRoot, ATags);
    for J := 0 to g_ProjectConfigExtensionCount - 1 do
      if Assigned(g_ProjectConfigExtensions[J].SaveProc) then
        g_ProjectConfigExtensions[J].SaveProc(lRoot, ATags);
    SaveCalibrationList(JsonArray(lRoot, 'calibrations'), ATags.Calibrations);
    SaveSpectrumConfigs(JsonArray(lRoot, 'spectrumConfigs'), ATags.SpectrumConfigs);
    SaveAlgorithmConfigs(JsonArray(lRoot, 'algorithmConfigs'), ATags.AlgorithmConfigs);
    SaveFrequencyBands(JsonArray(lRoot, 'frequencyBands'), ATags.FrequencyBands);
    lGroups := JsonArray(lRoot, 'tagGroups');
    for I := 0 to ATags.TagGroupPaths.Count - 1 do
      if Trim(ATags.TagGroupPaths[I]) <> '' then
        lGroups.Add(ATags.TagGroupPaths[I]);

    lTags := JsonArray(lRoot, 'tags');
    for I := 0 to ATags.TagCount - 1 do
    begin
      lTag := ATags.Tags[I];
      if ProjectTagBelongsToDeletedSource(ATags, lTag) then
        Continue;

      lTagJson := TJSONObject.Create;
      lTags.Add(lTagJson);

      lTagJson.Add('id', lTag.Id);
      lTagJson.Add('name', lTag.Name);
      lTagJson.Add('address', lTag.Address);
      lTagJson.Add('unit', lTag.UnitName);
      lTagJson.Add('sourceUnit', lTag.SourceUnitName);
      lTagJson.Add('description', lTag.Description);
      lTagJson.Add('groupPath', lTag.GroupPath);
      lTagJson.Add('sourceId', lTag.SourceId);
      lTagJson.Add('isVirtual', lTag.IsVirtual);
      lTagJson.Add('externalWriteAllowed', lTag.ExternalWriteAllowed);
      lTagJson.Add('isVector', lTag.IsVector);
      lTagJson.Add('sourceValueMode', lTag.SourceValueMode);
      lTagJson.Add('moduleType', lTag.ModuleType);
      lTagJson.Add('pollFrequencyHz', lTag.PollFrequencyHz);
      lTagJson.Add('rangeMin', lTag.RangeMin);
      lTagJson.Add('rangeMax', lTag.RangeMax);
      lTagJson.Add('autoRange', lTag.AutoRange);
      lTagJson.Add('autoUnit', lTag.AutoUnit);
      lTagJson.Add('hardwareCalibrationEnabled',
        lTag.HardwareCalibrationEnabled);
      lTagJson.Add('hardwareCalibrationName', lTag.HardwareCalibrationName);
      lTagJson.Add('channelCalibrationEnabled', lTag.ChannelCalibrationEnabled);
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

function HasLaterPhysicalTagAtAddress(ATagItems: TJSONArray;
  AIndex: Integer): Boolean;
var
  I: Integer;
  lTag, lOther: TJSONObject;
  lSourceId, lAddress: string;
begin
  Result := False;
  if not (ATagItems.Items[AIndex] is TJSONObject) then
    Exit;
  lTag := TJSONObject(ATagItems.Items[AIndex]);
  lSourceId := Trim(lTag.Get('sourceId', ''));
  lAddress := Trim(lTag.Get('address', ''));
  if (lSourceId = '') or (lAddress = '') or
    lTag.Get('isVirtual', False) or RecorderIsDetachedTagSource(lSourceId) then
    Exit;
  for I := AIndex + 1 to ATagItems.Count - 1 do
  begin
    if not (ATagItems.Items[I] is TJSONObject) then
      Continue;
    lOther := TJSONObject(ATagItems.Items[I]);
    if lOther.Get('isVirtual', False) then
      Continue;
    if SameText(Trim(lOther.Get('sourceId', '')), lSourceId) and
      SameText(Trim(lOther.Get('address', '')), lAddress) then
      Exit(True);
  end;
end;

function FindPhysicalTagAtAddress(ATags: TRecorderTagRegistry;
  const ASourceId, AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  for I := 0 to ATags.TagCount - 1 do
  begin
    lTag := ATags.Tags[I];
    if (not lTag.IsVirtual) and SameText(lTag.SourceId, ASourceId) and
      SameText(lTag.Address, AAddress) then
      Exit(lTag);
  end;
end;

procedure LoadRecorderProjectConfig(const AFileName: string;
  ATags: TRecorderTagRegistry);
var
  I, J: Integer;
  lSkippedDuplicateCount: Integer;
  lData: TJSONData;
  lRoot: TJSONObject;
  lTag: TRecorderTag;
  lTagJson: TJSONObject;
  lGroups: TJSONArray;
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
    SetRecorderNetworkBindAddress(lRoot.Get('networkBindAddress', ''));
    lTags := FindArray(lRoot, 'tags');
    if lTags = nil then
      Exit;

    ATags.Clear;
    LoadRecorderConfiguredDataSources(lRoot, ATags);
    LoadCalibrationList(FindArray(lRoot, 'calibrations'), ATags.Calibrations);
    LoadSpectrumConfigs(FindArray(lRoot, 'spectrumConfigs'), ATags.SpectrumConfigs);
    LoadAlgorithmConfigs(FindArray(lRoot, 'algorithmConfigs'), ATags.AlgorithmConfigs);
    LoadFrequencyBands(FindArray(lRoot, 'frequencyBands'), ATags.FrequencyBands);
    lGroups := FindArray(lRoot, 'tagGroups');
    if lGroups <> nil then
      for I := 0 to lGroups.Count - 1 do
        if Trim(lGroups.Strings[I]) <> '' then
          ATags.TagGroupPaths.Add(Trim(lGroups.Strings[I]));
    lSkippedDuplicateCount := 0;
    for I := 0 to lTags.Count - 1 do
    begin
      if not (lTags.Items[I] is TJSONObject) then
        Continue;

      if HasLaterPhysicalTagAtAddress(lTags, I) then
      begin
        Inc(lSkippedDuplicateCount);
        Continue;
      end;

      lTagJson := TJSONObject(lTags.Items[I]);
      lTag := TRecorderTag.Create(lTagJson.Get('id', Int64(I + 1)),
        lTagJson.Get('name', 'Tag' + IntToStr(I + 1)), 4096);
      try
        lTag.Address := lTagJson.Get('address', lTag.Address);
        lTag.UnitName := lTagJson.Get('unit', lTag.UnitName);
        lTag.SourceUnitName := lTagJson.Get('sourceUnit', lTag.UnitName);
        lTag.Description := lTagJson.Get('description', lTag.Description);
        lTag.GroupPath := lTagJson.Get('groupPath', lTag.GroupPath);
        lTag.SourceId := lTagJson.Get('sourceId', lTag.SourceId);
        { Совместимость со старыми проектами: до появления явного поля
          виртуальность можно было восстановить только по известным источникам. }
        lTag.IsVirtual := lTagJson.Get('isVirtual',
          RecorderIsVirtualTagSource(lTag.SourceId) or
          SameText(RecorderNormalizeTagSourceId(lTag.SourceId), 'debug.diagnostics') or
          (Pos('spectrum:', RecorderNormalizeTagSourceId(lTag.SourceId)) = 1));
        lTag.ExternalWriteAllowed := lTagJson.Get('externalWriteAllowed',
          lTag.IsVirtual);
        lTag.SourceValueMode := lTagJson.Get('sourceValueMode', lTag.SourceValueMode);
        lTag.ModuleType := lTagJson.Get('moduleType', lTag.ModuleType);
        lTag.PollFrequencyHz := lTagJson.Get('pollFrequencyHz',
          lTag.PollFrequencyHz);
        lTag.IsVector := lTagJson.Get('isVector',
          (not lTag.IsVirtual) and (lTag.PollFrequencyHz > 0));
        lTag.RangeMin := lTagJson.Get('rangeMin', lTag.RangeMin);
        lTag.RangeMax := lTagJson.Get('rangeMax', lTag.RangeMax);
        lTag.AutoRange := lTagJson.Get('autoRange', lTag.AutoRange);
        lTag.AutoUnit := lTagJson.Get('autoUnit', lTag.AutoUnit);
        lTag.HardwareCalibrationEnabled := lTagJson.Get(
          'hardwareCalibrationEnabled', lTag.HardwareCalibrationEnabled);
        lTag.HardwareCalibrationName := lTagJson.Get('hardwareCalibrationName',
          lTag.HardwareCalibrationName);
        lTag.ChannelCalibrationEnabled := lTagJson.Get('channelCalibrationEnabled',
          lTag.ChannelCalibrationEnabled);
        LoadTagEstimates(FindObject(lTagJson, 'estimates'), lTag);
        LoadTagSetpoints(FindObject(lTagJson, 'setpoints'), lTag);
        LoadTagCalibrationPipeline(FindArray(lTagJson, 'calibrationPipeline'), lTag);
        if not ProjectTagBelongsToDeletedSource(ATags, lTag) then
        begin
          ATags.AddTag(lTag);
          for J := 0 to g_ProjectConfigExtensionCount - 1 do
            if Assigned(g_ProjectConfigExtensions[J].TagLoadedProc) then
              g_ProjectConfigExtensions[J].TagLoadedProc(lTagJson, ATags, lTag);
          lTag := nil;
        end;
      finally
        lTag.Free;
      end;
    end;
    for I := 0 to lTags.Count - 1 do
    begin
      if not HasLaterPhysicalTagAtAddress(lTags, I) then
        Continue;
      lTagJson := TJSONObject(lTags.Items[I]);
      lTag := FindPhysicalTagAtAddress(ATags,
        Trim(lTagJson.Get('sourceId', '')),
        Trim(lTagJson.Get('address', '')));
      if lTag <> nil then
        ATags.RegisterLoadedTagAlias(lTagJson.Get('id', Int64(I + 1)),
          lTagJson.Get('name', ''), lTag);
    end;
    if lSkippedDuplicateCount > 0 then
      RecorderDebugLog(Format(
        '[Project] Ignored %d duplicate physical tags by source and address',
        [lSkippedDuplicateCount]));
    for J := 0 to g_ProjectConfigExtensionCount - 1 do
      if Assigned(g_ProjectConfigExtensions[J].LoadProc) then
        g_ProjectConfigExtensions[J].LoadProc(lRoot, ATags);
  finally
    lData.Free;
  end;
end;

function StoreGuiResourceFileName(const AGuiFileName,
  AResourceFileName: string): string;
var
  lBaseDirectory: string;
begin
  if Trim(AResourceFileName) = '' then
    Exit('');

  { Ресурс хранится относительно GUI-конфигурации, поэтому каталог проекта
    можно переносить между Windows и Linux без изменения настройки. }
  lBaseDirectory := IncludeTrailingPathDelimiter(
    ExpandFileName(ExtractFileDir(AGuiFileName)));
  Result := ExtractRelativePath(lBaseDirectory,
    ExpandFileName(AResourceFileName));
  Result := StringReplace(Result, '\', '/', [rfReplaceAll]);
end;

function LoadGuiResourceFileName(const AGuiFileName,
  AStoredFileName: string): string;
var
  lFileName: string;
begin
  if Trim(AStoredFileName) = '' then
    Exit('');

  lFileName := StringReplace(AStoredFileName, '\', PathDelim,
    [rfReplaceAll]);
  lFileName := StringReplace(lFileName, '/', PathDelim, [rfReplaceAll]);
  if (ExtractFileDrive(lFileName) <> '') or
    ((lFileName <> '') and (lFileName[1] = PathDelim)) then
    Result := ExpandFileName(lFileName)
  else
    Result := ExpandFileName(IncludeTrailingPathDelimiter(
      ExtractFileDir(AGuiFileName)) + lFileName);
end;

procedure SaveRecorderGuiConfig(const AFileName: string;
  AForms: TRecorderFormManager);
var
  I: Integer;
  J: Integer;
  K: Integer;
  L: Integer;
  lAxis: TRecorderTrendAxis;
  lComponent: TRecorderVisualComponent;
  lIni: TIniFile;
  lLine: TRecorderTrendLine;
  lPage: TRecorderFormPage;
  lSection: string;
  lTrend: TRecorderTrendComponent;
  lSpectrum: TRecorderSpectrumComponent;
  lFrequencyResponse: TRecorderFrequencyResponseComponent;
  lFrAxis: TRecorderFrequencyResponseAxis;
  lFrLine: TRecorderFrequencyResponseLine;
  lLissajousLine: TRecorderLissajousLine;
  lImage: TRecorderImageComponent;
  lSqlDisplay: TRecorderSqlTrendDisplay;
  lMeasure: TRecorderMeasurementSectionComponent;
  lMeasureRow: TRecorderMeasurementSectionRow;
  lGeneratedSignal: TRecorderGeneratedSignal;
  lRole: TRecorderRosetteRole;
  lNamedFont: TRecorderNamedFont;
begin
  if AForms = nil then
    raise ERecorderFormError.Create('Form manager is not assigned');

  ForceDirectories(ExtractFileDir(AFileName));
  lIni := TIniFile.Create(AFileName);
  try
    lIni.CacheUpdates := True;
    lIni.EraseSection('Project');
    lIni.WriteInteger('Project', 'Version', 1);
    lIni.WriteInteger('Project', 'PageCount', AForms.PageCount);
    lIni.WriteInteger('NamedFonts', 'Count', AForms.NamedFonts.Count);
    for I := 0 to AForms.NamedFonts.Count - 1 do
    begin
      lNamedFont := AForms.NamedFonts.Items[I];
      lSection := Format('NamedFont.%d', [I]);
      lIni.EraseSection(lSection);
      lIni.WriteString(lSection, 'Name', lNamedFont.Name);
      lIni.WriteString(lSection, 'FontName', lNamedFont.FontName);
      lIni.WriteInteger(lSection, 'FontSize', lNamedFont.FontSize);
      lIni.WriteInteger(lSection, 'FontColor', lNamedFont.FontColor);
      lIni.WriteBool(lSection, 'Bold', lNamedFont.Bold);
      lIni.WriteBool(lSection, 'Italic', lNamedFont.Italic);
    end;
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
      lIni.WriteString(lSection, 'BackgroundImage',
        StoreGuiResourceFileName(AFileName, lPage.BackgroundImageFileName));
      lIni.WriteBool(lSection, 'BackgroundKeepAspect',
        lPage.BackgroundKeepAspect);
      lIni.WriteInteger(lSection, 'Mode', Ord(lPage.Mode));
      lIni.WriteInteger(lSection, 'BaseOscillogramCount',
        lPage.BaseOscillogramCount);
      lIni.WriteBool(lSection, 'Detached', lPage.Detached);
      lIni.WriteInteger(lSection, 'DetachedLeft', lPage.DetachedLeft);
      lIni.WriteInteger(lSection, 'DetachedTop', lPage.DetachedTop);
      lIni.WriteInteger(lSection, 'DetachedWidth', lPage.DetachedWidth);
      lIni.WriteInteger(lSection, 'DetachedHeight', lPage.DetachedHeight);
      lIni.WriteInteger(lSection, 'DetachedMonitor', lPage.DetachedMonitor);
      lIni.WriteBool(lSection, 'DetachedMaximized', lPage.DetachedMaximized);
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
        lIni.WriteString(lSection, 'NamedFont', lComponent.NamedFontName);
        if lComponent is TRecorder3dComponent then
        begin
          lIni.WriteString(lSection, 'SceneFileName',
            TRecorder3dComponent(lComponent).SceneFileName);
          lIni.WriteBool(lSection, 'ShowAxes',
            TRecorder3dComponent(lComponent).ShowAxes);
          lIni.WriteInt64(lSection, 'BackgroundColor',
            TRecorder3dComponent(lComponent).BackgroundColor);
          lIni.WriteFloat(lSection, 'CameraYaw',
            TRecorder3dComponent(lComponent).CameraYaw);
          lIni.WriteFloat(lSection, 'CameraPitch',
            TRecorder3dComponent(lComponent).CameraPitch);
          lIni.WriteFloat(lSection, 'CameraDistance',
            TRecorder3dComponent(lComponent).CameraDistance);
          lIni.WriteBool(lSection, 'DrawFill',
            TRecorder3dComponent(lComponent).DrawFill);
          lIni.WriteBool(lSection, 'DrawWireframe',
            TRecorder3dComponent(lComponent).DrawWireframe);
          lIni.WriteBool(lSection, 'DrawPoints',
            TRecorder3dComponent(lComponent).DrawPoints);
          lIni.WriteBool(lSection, 'DrawNormals',
            TRecorder3dComponent(lComponent).DrawNormals);
          lIni.WriteFloat(lSection, 'NormalLength',
            TRecorder3dComponent(lComponent).NormalLength);
          lIni.WriteInt64(lSection, 'NormalLengthTagId',
            TRecorder3dComponent(lComponent).NormalLengthTagId);
          lIni.WriteString(lSection, 'NormalLengthTagName',
            TRecorder3dComponent(lComponent).NormalLengthTagName);
          lIni.WriteInt64(lSection, 'BindingTargetNodeId',
            TRecorder3dComponent(lComponent).BindingTargetNodeId);
          lIni.WriteInt64(lSection, 'BindingXTagId', TRecorder3dComponent(lComponent).BindingTagIds[r3bPointX]);
          lIni.WriteString(lSection, 'BindingXTagName', TRecorder3dComponent(lComponent).BindingTagNames[r3bPointX]);
          lIni.WriteInt64(lSection, 'BindingYTagId', TRecorder3dComponent(lComponent).BindingTagIds[r3bPointY]);
          lIni.WriteString(lSection, 'BindingYTagName', TRecorder3dComponent(lComponent).BindingTagNames[r3bPointY]);
          lIni.WriteInt64(lSection, 'BindingZTagId', TRecorder3dComponent(lComponent).BindingTagIds[r3bPointZ]);
          lIni.WriteString(lSection, 'BindingZTagName', TRecorder3dComponent(lComponent).BindingTagNames[r3bPointZ]);
          lIni.WriteInt64(lSection, 'BindingColorTagId', TRecorder3dComponent(lComponent).BindingTagIds[r3bColor]);
           lIni.WriteString(lSection, 'BindingColorTagName', TRecorder3dComponent(lComponent).BindingTagNames[r3bColor]);
           lIni.WriteInteger(lSection,'NodeRenderOverrideCount',
             TRecorder3dComponent(lComponent).NodeRenderOverrideCount);
           for K:=0 to TRecorder3dComponent(lComponent).NodeRenderOverrideCount-1 do
           begin
             lIni.WriteInt64(lSection,Format('NodeRender%dId',[K]),TRecorder3dComponent(lComponent).NodeRenderOverrides[K].NodeId);
             lIni.WriteBool(lSection,Format('NodeRender%dFill',[K]),TRecorder3dComponent(lComponent).NodeRenderOverrides[K].DrawFill);
             lIni.WriteBool(lSection,Format('NodeRender%dWire',[K]),TRecorder3dComponent(lComponent).NodeRenderOverrides[K].DrawWireframe);
             lIni.WriteBool(lSection,Format('NodeRender%dPoints',[K]),TRecorder3dComponent(lComponent).NodeRenderOverrides[K].DrawPoints);
             lIni.WriteBool(lSection,Format('NodeRender%dNormals',[K]),TRecorder3dComponent(lComponent).NodeRenderOverrides[K].DrawNormals);
           end;
          lIni.WriteFloat(lSection, 'FrfFrequencyHz', TRecorder3dComponent(lComponent).FrfFrequencyHz);
          lIni.WriteFloat(lSection, 'FrfAnimationPhase', TRecorder3dComponent(lComponent).FrfAnimationPhaseRadians);
          lIni.WriteInt64(lSection, 'FrfFrequencyTagId', TRecorder3dComponent(lComponent).FrfFrequencyTagId);
          lIni.WriteString(lSection, 'FrfFrequencyTagName', TRecorder3dComponent(lComponent).FrfFrequencyTagName);
          lIni.WriteInt64(lSection, 'FrfAnimationPhaseTagId', TRecorder3dComponent(lComponent).FrfAnimationPhaseTagId);
          lIni.WriteString(lSection, 'FrfAnimationPhaseTagName', TRecorder3dComponent(lComponent).FrfAnimationPhaseTagName);
          lIni.WriteInteger(lSection, 'FrfBindingCount', TRecorder3dComponent(lComponent).FrfBindingCount);
          for K:=0 to TRecorder3dComponent(lComponent).FrfBindingCount-1 do
          begin
            lIni.WriteInt64(lSection,Format('Frf%dNodeId',[K]),TRecorder3dComponent(lComponent).FrfBindings[K].TargetNodeId);
            lIni.WriteInteger(lSection,Format('Frf%dAxis',[K]),Ord(TRecorder3dComponent(lComponent).FrfBindings[K].Axis));
            lIni.WriteInteger(lSection,Format('Frf%dSpace',[K]),Ord(TRecorder3dComponent(lComponent).FrfBindings[K].Space));
            lIni.WriteInt64(lSection,Format('Frf%dAmplitudeTagId',[K]),TRecorder3dComponent(lComponent).FrfBindings[K].AmplitudeTagId);
            lIni.WriteString(lSection,Format('Frf%dAmplitudeTagName',[K]),TRecorder3dComponent(lComponent).FrfBindings[K].AmplitudeTagName);
            lIni.WriteInt64(lSection,Format('Frf%dPhaseTagId',[K]),TRecorder3dComponent(lComponent).FrfBindings[K].PhaseTagId);
            lIni.WriteString(lSection,Format('Frf%dPhaseTagName',[K]),TRecorder3dComponent(lComponent).FrfBindings[K].PhaseTagName);
            lIni.WriteFloat(lSection,Format('Frf%dGain',[K]),TRecorder3dComponent(lComponent).FrfBindings[K].Gain);
            lIni.WriteBool(lSection,Format('Frf%dEnabled',[K]),TRecorder3dComponent(lComponent).FrfBindings[K].Enabled);
          end;
        end;
        if lComponent is TRecorderStaticTextComponent then
        begin
          lIni.WriteString(lSection, 'Text',
            TRecorderStaticTextComponent(lComponent).Text);
          lIni.WriteString(lSection, 'FontName', TRecorderStaticTextComponent(lComponent).FontName);
          lIni.WriteInteger(lSection, 'FontSize', TRecorderStaticTextComponent(lComponent).FontSize);
          lIni.WriteInteger(lSection, 'FontColor', TRecorderStaticTextComponent(lComponent).FontColor);
          lIni.WriteBool(lSection, 'FontBold', TRecorderStaticTextComponent(lComponent).FontStyleBold);
          lIni.WriteBool(lSection, 'FontItalic', TRecorderStaticTextComponent(lComponent).FontStyleItalic);
        end;
        if lComponent is TRecorderButtonComponent then
        begin
          lIni.WriteString(lSection, 'Caption', TRecorderButtonComponent(lComponent).Caption);
          lIni.WriteInteger(lSection, 'Behavior', Ord(TRecorderButtonComponent(lComponent).Behavior));
          lIni.WriteFloat(lSection, 'PressedValue', TRecorderButtonComponent(lComponent).PressedValue);
          lIni.WriteFloat(lSection, 'ReleasedValue', TRecorderButtonComponent(lComponent).ReleasedValue);
          lIni.WriteInteger(lSection, 'PulseDurationMs', TRecorderButtonComponent(lComponent).PulseDurationMs);
          lIni.WriteString(lSection, 'PressedImage', TRecorderButtonComponent(lComponent).PressedImageFileName);
          lIni.WriteString(lSection, 'ReleasedImage', TRecorderButtonComponent(lComponent).ReleasedImageFileName);
        if lComponent is TRecorderInputFieldComponent then
          lIni.WriteString(lSection, 'DisplayFormat',
            TRecorderInputFieldComponent(lComponent).DisplayFormat);
        end;
        if lComponent is TRecorderTagValueComponent then
        begin
          lIni.WriteString(lSection, 'DisplayFormat',
            TRecorderTagValueComponent(lComponent).DisplayFormat);
          lIni.WriteInteger(lSection, 'ShowNameMode',
            Ord(TRecorderTagValueComponent(lComponent).ShowNameMode));
          lIni.WriteString(lSection, 'Caption',
            TRecorderTagValueComponent(lComponent).Caption);
          lIni.WriteBool(lSection, 'UseSourceTagName',
            TRecorderTagValueComponent(lComponent).UseSourceTagName);
          lIni.WriteString(lSection, 'FontName', TRecorderTagValueComponent(lComponent).FontName);
          lIni.WriteInteger(lSection, 'FontSize', TRecorderTagValueComponent(lComponent).FontSize);
          lIni.WriteInteger(lSection, 'FontColor', TRecorderTagValueComponent(lComponent).FontColor);
          lIni.WriteBool(lSection, 'FontBold', TRecorderTagValueComponent(lComponent).FontStyleBold);
          lIni.WriteBool(lSection, 'FontItalic', TRecorderTagValueComponent(lComponent).FontStyleItalic);
        end;
        if lComponent is TRecorderImageComponent then
        begin
          lImage := TRecorderImageComponent(lComponent);
          lIni.WriteInteger(lSection, 'ImageCount', lImage.Images.Count);
          for K := 0 to lImage.Images.Count - 1 do
          begin
            lIni.WriteString(lSection, Format('Image%dValue', [K]),
              lImage.Images.Names[K]);
            lIni.WriteString(lSection, Format('Image%dFile', [K]),
              StoreGuiResourceFileName(AFileName,
                lImage.Images.ValueFromIndex[K]));
          end;
          lIni.WriteInteger(lSection, 'SvgBindingCount',
            lImage.SvgBindingCount);
          for K := 0 to lImage.SvgBindingCount - 1 do
          begin
            lIni.WriteString(lSection, Format('SvgBinding%dParameter', [K]),
              lImage.SvgBindings[K].ParameterName);
            lIni.WriteInt64(lSection, Format('SvgBinding%dTagId', [K]),
              lImage.SvgBindings[K].TagId);
            lIni.WriteString(lSection, Format('SvgBinding%dTagName', [K]),
              lImage.SvgBindings[K].TagName);
            lIni.WriteInteger(lSection, Format('SvgBinding%dValueKind', [K]),
              Ord(lImage.SvgBindings[K].ValueKind));
          end;
        end;
        if lComponent is TRecorderMeasurementSectionComponent then
        begin
          lMeasure := TRecorderMeasurementSectionComponent(lComponent);
          lIni.WriteString(lSection, 'MeasureCaption', lMeasure.Caption);
          lIni.WriteBool(lSection, 'MeasureGenerateTags', lMeasure.GenerateTags);
          lIni.WriteInteger(lSection, 'MeasureBackgroundColor',
            lMeasure.BackgroundColor);
          lIni.WriteInteger(lSection, 'MeasureTextBackgroundColor',
            lMeasure.TextBackgroundColor);
          lIni.WriteString(lSection, 'MeasureCaptionFontName',
            lMeasure.CaptionFont.Name);
          lIni.WriteInteger(lSection, 'MeasureCaptionFontSize',
            lMeasure.CaptionFont.Size);
          lIni.WriteInteger(lSection, 'MeasureCaptionFontColor',
            lMeasure.CaptionFont.Color);
          lIni.WriteBool(lSection, 'MeasureCaptionFontBold',
            lMeasure.CaptionFont.Bold);
          lIni.WriteBool(lSection, 'MeasureCaptionFontItalic',
            lMeasure.CaptionFont.Italic);
          lIni.WriteString(lSection, 'MeasureStressNamedFont',
            lMeasure.StressNamedFontName);
          lIni.WriteString(lSection, 'MeasureStressFontName',
            lMeasure.StressFont.Name);
          lIni.WriteInteger(lSection, 'MeasureStressFontSize',
            lMeasure.StressFont.Size);
          lIni.WriteInteger(lSection, 'MeasureStressFontColor',
            lMeasure.StressFont.Color);
          lIni.WriteBool(lSection, 'MeasureStressFontBold',
            lMeasure.StressFont.Bold);
          lIni.WriteBool(lSection, 'MeasureStressFontItalic',
            lMeasure.StressFont.Italic);
          lIni.WriteString(lSection, 'MeasureSectionId', lMeasure.SectionId);
          lIni.WriteFloat(lSection, 'MeasureYoungModulusMPa',
            lMeasure.YoungModulusMPa);
          lIni.WriteFloat(lSection, 'MeasurePoissonRatio',
            lMeasure.PoissonRatio);
          lIni.WriteFloat(lSection, 'MeasureTemperatureCoefficient',
            lMeasure.TemperatureCoefficient);
          lIni.WriteFloat(lSection, 'MeasureReferenceTemperatureC',
            lMeasure.ReferenceTemperatureC);
          lIni.WriteInteger(lSection, 'MeasureRowCount', lMeasure.RowCount);
          for K := 0 to lMeasure.RowCount - 1 do
          begin
            lMeasureRow := lMeasure.Rows[K];
            lIni.WriteInteger(lSection, Format('MeasureRow%dPointNo', [K]),
              lMeasureRow.PointNo);
            lIni.WriteString(lSection, Format('MeasureRow%dPointInfo', [K]),
              lMeasureRow.PointInfo);
            lIni.WriteInteger(lSection, Format('MeasureRow%dRosetteType', [K]),
              Ord(lMeasureRow.RosetteType));
            lIni.WriteFloat(lSection, Format('MeasureRow%dPositionDeg', [K]),
              lMeasureRow.PositionDeg);
            for lRole := Low(TRecorderRosetteRole) to High(TRecorderRosetteRole) do
            begin
              lIni.WriteString(lSection,
                Format('MeasureRow%d%sTagName', [K,
                  RecorderRosetteRoleToText(lRole)]),
                lMeasureRow.TagNames[lRole]);
              lIni.WriteInt64(lSection,
                Format('MeasureRow%d%sTagId', [K,
                  RecorderRosetteRoleToText(lRole)]),
                lMeasureRow.TagIds[lRole]);
              lIni.WriteFloat(lSection,
                Format('MeasureRow%d%sBalance', [K,
                  RecorderRosetteRoleToText(lRole)]),
                lMeasureRow.Balances[lRole]);
            end;
          end;
        end;
        if lComponent is TRecorderSignalGeneratorComponent then
        begin
          lIni.WriteBool(lSection, 'GeneratorEnabled',
            TRecorderSignalGeneratorComponent(lComponent).Enabled);
          lIni.WriteInteger(lSection, 'GeneratorSignalCount',
            TRecorderSignalGeneratorComponent(lComponent).SignalCount);
          for K := 0 to TRecorderSignalGeneratorComponent(lComponent).SignalCount - 1 do
          begin
            lIni.WriteBool(lSection, Format('Generator%dEnabled', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].Enabled);
            lIni.WriteString(lSection, Format('Generator%dName', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].Name);
            lIni.WriteInteger(lSection, Format('Generator%dKind', [K]),
              Ord(TRecorderSignalGeneratorComponent(lComponent).Signals[K].Kind));
            lIni.WriteFloat(lSection, Format('Generator%dSampleRateHz', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].SampleRateHz);
            lIni.WriteFloat(lSection, Format('Generator%dAmplitude', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].Amplitude);
            lIni.WriteFloat(lSection, Format('Generator%dFrequencyHz', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].FrequencyHz);
            lIni.WriteFloat(lSection, Format('Generator%dPhaseDeg', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].PhaseDeg);
            lIni.WriteFloat(lSection, Format('Generator%dOffset', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].Offset);
            lIni.WriteBool(lSection, Format('Generator%dSweepEnabled', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].SweepEnabled);
            lIni.WriteFloat(lSection, Format('Generator%dSweepEndHz', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].SweepEndFrequencyHz);
            lIni.WriteFloat(lSection, Format('Generator%dSweepDurationSec', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].SweepDurationSec);
            lIni.WriteBool(lSection, Format('Generator%dSweepLog', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].SweepLogarithmic);
            lIni.WriteBool(lSection, Format('Generator%dChangePhase', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].ChangePhase);
            lIni.WriteFloat(lSection, Format('Generator%dPhaseVelocity', [K]),
              TRecorderSignalGeneratorComponent(lComponent).Signals[K].PhaseVelocityDegSec);
          end;
        end;
        if lComponent is TRecorderOscillogramComponent then
        begin
          lIni.WriteString(lSection, 'DisplayFormat',
            TRecorderOscillogramComponent(lComponent).DisplayFormat);
          lIni.WriteInteger(lSection, 'BindingMode',
            Ord(TRecorderOscillogramComponent(lComponent).BindingMode));
          lIni.WriteInteger(lSection, 'TagOffset',
            TRecorderOscillogramComponent(lComponent).TagOffset);
          if RecorderIsPluginOscillograph(lComponent) then
          begin
          lIni.WriteFloat(lSection, 'OscXScale',
            TRecorderOscillogramComponent(lComponent).XScale);
          lIni.WriteFloat(lSection, 'OscYScale',
            TRecorderOscillogramComponent(lComponent).YScale);
          lIni.WriteFloat(lSection, 'OscYOffset',
            TRecorderOscillogramComponent(lComponent).YOffset);
          lIni.WriteBool(lSection, 'OscClosedInput',
            TRecorderOscillogramComponent(lComponent).ClosedInput);
          lIni.WriteBool(lSection, 'OscAutoRangeEnabled',
            TRecorderOscillogramComponent(lComponent).AutoRangeEnabled);
          lIni.WriteBool(lSection, 'OscXCursorEnabled',
            TRecorderOscillogramComponent(lComponent).XCursorEnabled);
          lIni.WriteInteger(lSection, 'OscXCursorCount',
            TRecorderOscillogramComponent(lComponent).XCursorCount);
          lIni.WriteBool(lSection, 'OscLegendVisible',
            TRecorderOscillogramComponent(lComponent).LegendVisible);
          lIni.WriteBool(lSection, 'OscLevelCursorVisible',
            TRecorderOscillogramComponent(lComponent).LevelCursorVisible);
          lIni.WriteInteger(lSection, 'OscPrimaryAxisIndex',
            TRecorderOscillogramComponent(lComponent).PrimaryAxisIndex);
          lIni.WriteInteger(lSection, 'OscAxisCount',
            TRecorderOscillogramComponent(lComponent).AxisCount);
          for K := 0 to TRecorderOscillogramComponent(lComponent).AxisCount - 1 do
          begin
            lAxis := TRecorderOscillogramComponent(lComponent).Axes[K];
            lIni.WriteString(lSection, Format('OscAxis%dName', [K]), lAxis.Name);
            lIni.WriteFloat(lSection, Format('OscAxis%dYScale', [K]), lAxis.YScale);
            lIni.WriteFloat(lSection, Format('OscAxis%dYOffset', [K]), lAxis.YOffset);
          end;
          lIni.WriteString(lSection, 'OscTriggerTag',
            TRecorderOscillogramComponent(lComponent).TriggerTagName);
          lIni.WriteBool(lSection, 'OscTriggerEnabled',
            TRecorderOscillogramComponent(lComponent).TriggerEnabled);
          lIni.WriteFloat(lSection, 'OscTriggerLevel',
            TRecorderOscillogramComponent(lComponent).TriggerLevel);
          lIni.WriteFloat(lSection, 'OscTriggerPreRollPercent',
            TRecorderOscillogramComponent(lComponent).TriggerPreRollPercent);
          end;
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
            lIni.WriteInteger(lSection, Format('OscLine%dAxisIndex', [K]), lLine.AxisIndex);
          end;
        end;
        if lComponent is TRecorderDonutComponent then
        begin
          lIni.WriteString(lSection, 'DonutTitle',
            TRecorderDonutComponent(lComponent).Title);
          lIni.WriteInteger(lSection, 'DonutHolePercent',
            TRecorderDonutComponent(lComponent).HolePercent);
          lIni.WriteBool(lSection, 'DonutSingleValueMode',
            TRecorderDonutComponent(lComponent).SingleValueMode);
          lIni.WriteFloat(lSection, 'DonutRangeMin',
            TRecorderDonutComponent(lComponent).RangeMin);
          lIni.WriteFloat(lSection, 'DonutRangeMax',
            TRecorderDonutComponent(lComponent).RangeMax);
          lIni.WriteInteger(lSection, 'DonutTagCount',
            TRecorderDonutComponent(lComponent).TagNames.Count);
          for K := 0 to TRecorderDonutComponent(lComponent).TagNames.Count - 1 do
          begin
            lIni.WriteString(lSection, Format('DonutTag%d', [K]),
              TRecorderDonutComponent(lComponent).TagNames[K]);
            lIni.WriteInt64(lSection, Format('DonutTag%dId', [K]),
              TRecorderDonutComponent(lComponent).TagIdAt(K));
          end;
        end;
        if lComponent is TRecorderVibrationEstimateComponent then
        begin
          lIni.WriteString(lSection, 'Caption',
            TRecorderVibrationEstimateComponent(lComponent).Caption);
          lIni.WriteBool(lSection, 'UseSourceTagName',
            TRecorderVibrationEstimateComponent(lComponent).UseSourceTagName);
          lIni.WriteInteger(lSection, 'Quantity',
            Ord(TRecorderVibrationEstimateComponent(lComponent).Quantity));
          lIni.WriteString(lSection, 'BandName',
            TRecorderVibrationEstimateComponent(lComponent).BandName);
          lIni.WriteString(lSection, 'OutputUnit',
            TRecorderVibrationEstimateComponent(lComponent).OutputUnit);
          lIni.WriteString(lSection, 'DisplayFormat',
            TRecorderVibrationEstimateComponent(lComponent).DisplayFormat);
          lIni.WriteBool(lSection, 'AmplitudeMode',
            TRecorderVibrationEstimateComponent(lComponent).AmplitudeMode);
          lIni.WriteString(lSection, 'FontName',
            TRecorderVibrationEstimateComponent(lComponent).FontName);
          lIni.WriteInteger(lSection, 'FontSize',
            TRecorderVibrationEstimateComponent(lComponent).FontSize);
          lIni.WriteInt64(lSection, 'FontColor',
            TRecorderVibrationEstimateComponent(lComponent).FontColor);
          lIni.WriteBool(lSection, 'FontBold',
            TRecorderVibrationEstimateComponent(lComponent).FontStyleBold);
          lIni.WriteBool(lSection, 'FontItalic',
            TRecorderVibrationEstimateComponent(lComponent).FontStyleItalic);
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
          lIni.WriteInteger(lSection, 'SpectrumValueMode',
            lSpectrum.SpectrumValueMode);
          lIni.WriteInteger(lSection, 'SpectrumIntegration',
            lSpectrum.SpectrumIntegration);
          lIni.WriteString(lSection, 'TahoTagName', lSpectrum.TahoTagName);
          lIni.WriteInt64(lSection, 'TahoTagId', lSpectrum.TahoTagId);
          lIni.WriteString(lSection, 'ProfileName', lSpectrum.ProfileName);
          lIni.WriteInteger(lSection, 'TagCount', lSpectrum.TagNames.Count);
          for K := 0 to lSpectrum.TagNames.Count - 1 do
            lIni.WriteString(lSection, Format('Tag%d', [K]), lSpectrum.TagNames[K]);
            if lSpectrum.TagIdAt(K) <> 0 then
              lIni.WriteInt64(lSection, Format('Tag%dId', [K]), lSpectrum.TagIdAt(K));
        end;
        if lComponent is TRecorderLissajousComponent then
        begin
          lIni.WriteString(lSection, 'XTagName', TRecorderLissajousComponent(lComponent).XTagName);
          lIni.WriteString(lSection, 'YTagName', TRecorderLissajousComponent(lComponent).YTagName);
          lIni.WriteInt64(lSection, 'XTagId', TRecorderLissajousComponent(lComponent).XTagId);
          lIni.WriteInt64(lSection, 'YTagId', TRecorderLissajousComponent(lComponent).YTagId);
          lIni.WriteFloat(lSection, 'DurationSec', TRecorderLissajousComponent(lComponent).DurationSec);
          lIni.WriteFloat(lSection, 'RangeMinX', TRecorderLissajousComponent(lComponent).RangeMinX);
          lIni.WriteFloat(lSection, 'RangeMaxX', TRecorderLissajousComponent(lComponent).RangeMaxX);
          lIni.WriteFloat(lSection, 'RangeMinY', TRecorderLissajousComponent(lComponent).RangeMinY);
          lIni.WriteFloat(lSection, 'RangeMaxY', TRecorderLissajousComponent(lComponent).RangeMaxY);
          lIni.WriteBool(lSection, 'KeepSquare',
            TRecorderLissajousComponent(lComponent).KeepSquare);
          lIni.WriteInt64(lSection, 'LineColor', TRecorderLissajousComponent(lComponent).LineColor);
          lIni.WriteInteger(lSection, 'LineWidth', TRecorderLissajousComponent(lComponent).LineWidth);
          lIni.WriteInteger(lSection, 'LissajousLineCount',
            TRecorderLissajousComponent(lComponent).LineCount);
          for K := 0 to TRecorderLissajousComponent(lComponent).LineCount - 1 do
          begin
            lLissajousLine := TRecorderLissajousComponent(lComponent).Lines[K];
            lIni.WriteString(lSection, Format('LissajousLine%dName', [K]), lLissajousLine.Name);
            lIni.WriteString(lSection, Format('LissajousLine%dXTagName', [K]), lLissajousLine.XTagName);
            lIni.WriteInt64(lSection, Format('LissajousLine%dXTagId', [K]), lLissajousLine.XTagId);
            lIni.WriteString(lSection, Format('LissajousLine%dYTagName', [K]), lLissajousLine.YTagName);
            lIni.WriteInt64(lSection, Format('LissajousLine%dYTagId', [K]), lLissajousLine.YTagId);
            lIni.WriteInt64(lSection, Format('LissajousLine%dColor', [K]), lLissajousLine.Color);
            lIni.WriteInt64(lSection, Format('LissajousLine%dDiameterColor', [K]), lLissajousLine.DiameterColor);
            lIni.WriteInteger(lSection, Format('LissajousLine%dWidth', [K]), lLissajousLine.Width);
            lIni.WriteBool(lSection, Format('LissajousLine%dDrawPoints', [K]), lLissajousLine.DrawPoints);
            lIni.WriteBool(lSection, Format('LissajousLine%dDrawLine', [K]), lLissajousLine.DrawLine);
            lIni.WriteBool(lSection, Format('LissajousLine%dDrawMainDiameter', [K]), lLissajousLine.DrawMainDiameter);
            lIni.WriteBool(lSection, Format('LissajousLine%dDrawDiameterCenter', [K]), lLissajousLine.DrawDiameterCenter);
            lIni.WriteBool(lSection, Format('LissajousLine%dShowDiameterValue', [K]), lLissajousLine.ShowDiameterValue);
          end;
        end;
        if lComponent is TRecorderFrequencyResponseComponent then
        begin
          lFrequencyResponse := TRecorderFrequencyResponseComponent(lComponent);
          lIni.WriteString(lSection, 'FrSourceTagName', lFrequencyResponse.SourceTagName);
          lIni.WriteInt64(lSection, 'FrSourceTagId', lFrequencyResponse.SourceTagId);
          lIni.WriteString(lSection, 'FrValueTagName', lFrequencyResponse.ValueTagName);
          lIni.WriteInt64(lSection, 'FrValueTagId', lFrequencyResponse.ValueTagId);
          lIni.WriteString(lSection, 'FrFrequencyTagName', lFrequencyResponse.FrequencyTagName);
          lIni.WriteInt64(lSection, 'FrFrequencyTagId', lFrequencyResponse.FrequencyTagId);
          lIni.WriteInteger(lSection, 'FrKind', Ord(lFrequencyResponse.Kind));
          lIni.WriteFloat(lSection, 'FrMinFrequencyHz', lFrequencyResponse.MinFrequencyHz);
          lIni.WriteFloat(lSection, 'FrMaxFrequencyHz', lFrequencyResponse.MaxFrequencyHz);
          lIni.WriteFloat(lSection, 'FrMinValue', lFrequencyResponse.MinValue);
          lIni.WriteFloat(lSection, 'FrMaxValue', lFrequencyResponse.MaxValue);
          lIni.WriteInteger(lSection, 'FrBufferSize', lFrequencyResponse.BufferSize);
          lIni.WriteBool(lSection, 'FrUniformX', lFrequencyResponse.UniformX);
          lIni.WriteFloat(lSection, 'FrFrequencyStepHz', lFrequencyResponse.FrequencyStepHz);
          lIni.WriteInteger(lSection, 'FrMergeMode', Ord(lFrequencyResponse.MergeMode));
          lIni.WriteBool(lSection, 'FrLegendVisible', lFrequencyResponse.LegendVisible);
          lIni.WriteInteger(lSection, 'FrAxisCount', lFrequencyResponse.AxisCount);
          for K := 0 to lFrequencyResponse.AxisCount - 1 do
          begin
            lFrAxis := lFrequencyResponse.Axes[K];
            lIni.WriteString(lSection, Format('FrAxis%dName', [K]), lFrAxis.Name);
            lIni.WriteFloat(lSection, Format('FrAxis%dMin', [K]), lFrAxis.MinValue);
            lIni.WriteFloat(lSection, Format('FrAxis%dMax', [K]), lFrAxis.MaxValue);
            lIni.WriteBool(lSection, Format('FrAxis%dLog', [K]), lFrAxis.Logarithmic);
          end;
          lIni.WriteInteger(lSection, 'FrLineCount', lFrequencyResponse.LineCount);
          for K := 0 to lFrequencyResponse.LineCount - 1 do
          begin
            lFrLine := lFrequencyResponse.Lines[K];
            lIni.WriteString(lSection, Format('FrLine%dName', [K]), lFrLine.Name);
            lIni.WriteString(lSection, Format('FrLine%dAxis', [K]), lFrLine.AxisName);
            lIni.WriteString(lSection, Format('FrLine%dSourceName', [K]), lFrLine.SourceTagName);
            lIni.WriteInt64(lSection, Format('FrLine%dSourceId', [K]), lFrLine.SourceTagId);
            lIni.WriteString(lSection, Format('FrLine%dValueName', [K]), lFrLine.ValueTagName);
            lIni.WriteInt64(lSection, Format('FrLine%dValueId', [K]), lFrLine.ValueTagId);
            lIni.WriteString(lSection, Format('FrLine%dFrequencyName', [K]), lFrLine.FrequencyTagName);
            lIni.WriteInt64(lSection, Format('FrLine%dFrequencyId', [K]), lFrLine.FrequencyTagId);
            lIni.WriteInteger(lSection, Format('FrLine%dKind', [K]), Ord(lFrLine.Kind));
            lIni.WriteInteger(lSection, Format('FrLine%dBuffer', [K]), lFrLine.BufferSize);
            lIni.WriteBool(lSection, Format('FrLine%dUniform', [K]), lFrLine.UniformX);
            lIni.WriteFloat(lSection, Format('FrLine%dStep', [K]), lFrLine.FrequencyStepHz);
            lIni.WriteInteger(lSection, Format('FrLine%dMerge', [K]), Ord(lFrLine.MergeMode));
            lIni.WriteInt64(lSection, Format('FrLine%dColor', [K]), lFrLine.Color);
            lIni.WriteInteger(lSection, Format('FrLine%dWidth', [K]), lFrLine.Width);
            lIni.WriteBool(lSection, Format('FrLine%dDrawLine', [K]), lFrLine.DrawLine);
            lIni.WriteBool(lSection, Format('FrLine%dDrawPoints', [K]), lFrLine.DrawPoints);
          end;
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
          if lComponent is TRecorderSqlTrendComponent then
          begin
            lIni.WriteString(lSection, 'SqlConfigFile', 'sql-db.ini');
            lIni.WriteInteger(lSection, 'SqlTimeMode',
              Ord(TRecorderSqlTrendComponent(lComponent).TimeMode));
            lIni.WriteFloat(lSection, 'SqlFromUtc',
              TRecorderSqlTrendComponent(lComponent).FromUtc);
            lIni.WriteFloat(lSection, 'SqlToUtc',
              TRecorderSqlTrendComponent(lComponent).ToUtc);
            lIni.WriteInteger(lSection, 'SqlMaxPoints',
              TRecorderSqlTrendComponent(lComponent).MaxPointsPerLine);
            lIni.WriteBool(lSection, 'SqlShowEvents',
              TRecorderSqlTrendComponent(lComponent).ShowEvents);
            lIni.WriteBool(lSection, 'SqlShowRecordingEvents',
              TRecorderSqlTrendComponent(lComponent).ShowRecordingEvents);
            lIni.WriteBool(lSection, 'SqlShowTagAlarmEvents',
              TRecorderSqlTrendComponent(lComponent).ShowTagAlarmEvents);
            lIni.WriteInteger(lSection, 'SqlDisplayCount',
              TRecorderSqlTrendComponent(lComponent).DisplayCount);
            lIni.WriteInteger(lSection, 'SqlActiveDisplay',
              TRecorderSqlTrendComponent(lComponent).ActiveDisplayIndex);
            for K := 0 to TRecorderSqlTrendComponent(lComponent).DisplayCount - 1 do
            begin
              lSqlDisplay := TRecorderSqlTrendComponent(lComponent).Displays[K];
              lIni.WriteString(lSection, Format('SqlDisplay%dName', [K]), lSqlDisplay.Name);
              lIni.WriteInteger(lSection, Format('SqlDisplay%dAxisCount', [K]), lSqlDisplay.AxisCount);
              for L := 0 to lSqlDisplay.AxisCount - 1 do
              begin
                lAxis := lSqlDisplay.Axes[L];
                lIni.WriteString(lSection, Format('SqlDisplay%dAxis%dName', [K, L]), lAxis.Name);
                lIni.WriteInteger(lSection, Format('SqlDisplay%dAxis%dColor', [K, L]), lAxis.Color);
                lIni.WriteFloat(lSection, Format('SqlDisplay%dAxis%dRangeMin', [K, L]), lAxis.RangeMin);
                lIni.WriteFloat(lSection, Format('SqlDisplay%dAxis%dRangeMax', [K, L]), lAxis.RangeMax);
              end;
              lIni.WriteInteger(lSection, Format('SqlDisplay%dLineCount', [K]), lSqlDisplay.LineCount);
              for L := 0 to lSqlDisplay.LineCount - 1 do
              begin
                lLine := lSqlDisplay.Lines[L];
                lIni.WriteString(lSection, Format('SqlDisplay%dLine%dName', [K, L]), lLine.Name);
                lIni.WriteString(lSection, Format('SqlDisplay%dLine%dTagName', [K, L]), lLine.TagName);
                lIni.WriteInt64(lSection, Format('SqlDisplay%dLine%dTagId', [K, L]), lLine.TagId);
                lIni.WriteInteger(lSection, Format('SqlDisplay%dLine%dEstimateKind', [K, L]), Ord(lLine.EstimateKind));
                lIni.WriteInteger(lSection, Format('SqlDisplay%dLine%dAxisIndex', [K, L]), lLine.AxisIndex);
                lIni.WriteInteger(lSection, Format('SqlDisplay%dLine%dColor', [K, L]), lLine.Color);
                lIni.WriteInteger(lSection, Format('SqlDisplay%dLine%dWidth', [K, L]), lLine.Width);
                lIni.WriteBool(lSection, Format('SqlDisplay%dLine%dVisible', [K, L]), lLine.Visible);
              end;
            end;
          end;
        end;      end;
    end;
    lIni.UpdateFile;
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
  L: Integer;
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
  lFrequencyResponse: TRecorderFrequencyResponseComponent;
  lFrAxis: TRecorderFrequencyResponseAxis;
  lFrLine: TRecorderFrequencyResponseLine;
  lLissajousLine: TRecorderLissajousLine;
  lImage: TRecorderImageComponent;
  lSqlDisplay: TRecorderSqlTrendDisplay;
  lMeasure: TRecorderMeasurementSectionComponent;
  lMeasureRow: TRecorderMeasurementSectionRow;
  lGeneratedSignal: TRecorderGeneratedSignal;
  lRole: TRecorderRosetteRole;
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
    AForms.NamedFonts.Clear;
    lItemCount := lIni.ReadInteger('NamedFonts', 'Count', 0);
    for I := 0 to lItemCount - 1 do
    begin
      lSection := Format('NamedFont.%d', [I]);
      AForms.NamedFonts.Define(
        lIni.ReadString(lSection, 'Name', ''),
        lIni.ReadString(lSection, 'FontName', 'Tahoma'),
        lIni.ReadInteger(lSection, 'FontSize', 10),
        lIni.ReadInteger(lSection, 'FontColor', 0),
        lIni.ReadBool(lSection, 'Bold', False),
        lIni.ReadBool(lSection, 'Italic', False));
    end;
    lCount := lIni.ReadInteger('Project', 'PageCount', 0);
    for I := 0 to lCount - 1 do
    begin
      lSection := Format('Page.%d', [I]);
      lPage := TRecorderFormPage.Create(
        lIni.ReadString(lSection, 'Id', 'Page' + IntToStr(I + 1)),
        lIni.ReadString(lSection, 'Name', 'Page' + IntToStr(I + 1)),
        lIni.ReadString(lSection, 'Title', 'Page ' + IntToStr(I + 1)));
      try
        lPage.BackgroundImageFileName := LoadGuiResourceFileName(AFileName,
          lIni.ReadString(lSection, 'BackgroundImage', ''));
        lPage.BackgroundKeepAspect := lIni.ReadBool(lSection,
          'BackgroundKeepAspect', False);
        lPage.Mode := TRecorderFormPageMode(lIni.ReadInteger(lSection, 'Mode',
          Ord(fpmView)));
        lPage.BaseOscillogramCount := lIni.ReadInteger(lSection,
          'BaseOscillogramCount', lPage.BaseOscillogramCount);
        lPage.Detached := lIni.ReadBool(lSection, 'Detached', False);
        lPage.DetachedLeft := lIni.ReadInteger(lSection, 'DetachedLeft',
          lPage.DetachedLeft);
        lPage.DetachedTop := lIni.ReadInteger(lSection, 'DetachedTop',
          lPage.DetachedTop);
        lPage.DetachedWidth := lIni.ReadInteger(lSection, 'DetachedWidth',
          lPage.DetachedWidth);
        lPage.DetachedHeight := lIni.ReadInteger(lSection, 'DetachedHeight',
          lPage.DetachedHeight);
        lPage.DetachedMonitor := lIni.ReadInteger(lSection, 'DetachedMonitor',
          lPage.DetachedMonitor);
        lPage.DetachedMaximized := lIni.ReadBool(lSection,
          'DetachedMaximized', False);
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
          lComponent.NamedFontName := lIni.ReadString(lSection, 'NamedFont', '');
          if lComponent is TRecorder3dComponent then
          begin
            TRecorder3dComponent(lComponent).SceneFileName :=
              lIni.ReadString(lSection, 'SceneFileName', '');
            TRecorder3dComponent(lComponent).ShowAxes :=
              lIni.ReadBool(lSection, 'ShowAxes', True);
            TRecorder3dComponent(lComponent).BackgroundColor :=
              lIni.ReadInt64(lSection, 'BackgroundColor', $0033291F);
            TRecorder3dComponent(lComponent).CameraYaw :=
              lIni.ReadFloat(lSection, 'CameraYaw', 35);
            TRecorder3dComponent(lComponent).CameraPitch :=
              lIni.ReadFloat(lSection, 'CameraPitch', -25);
            TRecorder3dComponent(lComponent).CameraDistance :=
              lIni.ReadFloat(lSection, 'CameraDistance', 6);
            TRecorder3dComponent(lComponent).DrawFill :=
              lIni.ReadBool(lSection, 'DrawFill', True);
            TRecorder3dComponent(lComponent).DrawWireframe :=
              lIni.ReadBool(lSection, 'DrawWireframe', False);
            TRecorder3dComponent(lComponent).DrawPoints :=
              lIni.ReadBool(lSection, 'DrawPoints', False);
            TRecorder3dComponent(lComponent).DrawNormals :=
              lIni.ReadBool(lSection, 'DrawNormals', False);
            TRecorder3dComponent(lComponent).NormalLength :=
              lIni.ReadFloat(lSection, 'NormalLength', 0.25);
            TRecorder3dComponent(lComponent).NormalLengthTagId :=
              lIni.ReadInt64(lSection, 'NormalLengthTagId', 0);
            TRecorder3dComponent(lComponent).NormalLengthTagName :=
              lIni.ReadString(lSection, 'NormalLengthTagName', '');
            TRecorder3dComponent(lComponent).BindingTargetNodeId :=
              lIni.ReadInt64(lSection, 'BindingTargetNodeId', 0);
            TRecorder3dComponent(lComponent).BindingTagIds[r3bPointX] := lIni.ReadInt64(lSection, 'BindingXTagId', 0);
            TRecorder3dComponent(lComponent).BindingTagNames[r3bPointX] := lIni.ReadString(lSection, 'BindingXTagName', '');
            TRecorder3dComponent(lComponent).BindingTagIds[r3bPointY] := lIni.ReadInt64(lSection, 'BindingYTagId', 0);
            TRecorder3dComponent(lComponent).BindingTagNames[r3bPointY] := lIni.ReadString(lSection, 'BindingYTagName', '');
            TRecorder3dComponent(lComponent).BindingTagIds[r3bPointZ] := lIni.ReadInt64(lSection, 'BindingZTagId', 0);
            TRecorder3dComponent(lComponent).BindingTagNames[r3bPointZ] := lIni.ReadString(lSection, 'BindingZTagName', '');
            TRecorder3dComponent(lComponent).BindingTagIds[r3bColor] := lIni.ReadInt64(lSection, 'BindingColorTagId', 0);
             TRecorder3dComponent(lComponent).BindingTagNames[r3bColor] := lIni.ReadString(lSection, 'BindingColorTagName', '');
             TRecorder3dComponent(lComponent).ClearNodeRenderOverrides;
             lCount:=lIni.ReadInteger(lSection,'NodeRenderOverrideCount',0);
             for K:=0 to lCount-1 do with TRecorder3dComponent(lComponent).AddNodeRenderOverride do
             begin
               NodeId:=lIni.ReadInt64(lSection,Format('NodeRender%dId',[K]),0);
               DrawFill:=lIni.ReadBool(lSection,Format('NodeRender%dFill',[K]),True);
               DrawWireframe:=lIni.ReadBool(lSection,Format('NodeRender%dWire',[K]),False);
               DrawPoints:=lIni.ReadBool(lSection,Format('NodeRender%dPoints',[K]),False);
               DrawNormals:=lIni.ReadBool(lSection,Format('NodeRender%dNormals',[K]),False);
             end;
            TRecorder3dComponent(lComponent).FrfFrequencyHz:=lIni.ReadFloat(lSection,'FrfFrequencyHz',100);
            TRecorder3dComponent(lComponent).FrfAnimationPhaseRadians:=lIni.ReadFloat(lSection,'FrfAnimationPhase',0);
            TRecorder3dComponent(lComponent).FrfFrequencyTagId:=lIni.ReadInt64(lSection,'FrfFrequencyTagId',0);
            TRecorder3dComponent(lComponent).FrfFrequencyTagName:=lIni.ReadString(lSection,'FrfFrequencyTagName','');
            TRecorder3dComponent(lComponent).FrfAnimationPhaseTagId:=lIni.ReadInt64(lSection,'FrfAnimationPhaseTagId',0);
            TRecorder3dComponent(lComponent).FrfAnimationPhaseTagName:=lIni.ReadString(lSection,'FrfAnimationPhaseTagName','');
            TRecorder3dComponent(lComponent).ClearFrfBindings;
            lCount:=lIni.ReadInteger(lSection,'FrfBindingCount',0);
            for K:=0 to lCount-1 do with TRecorder3dComponent(lComponent).AddFrfBinding do
            begin
              TargetNodeId:=lIni.ReadInt64(lSection,Format('Frf%dNodeId',[K]),0);
              SetAxisOrdinal(lIni.ReadInteger(lSection,Format('Frf%dAxis',[K]),0));
              SetSpaceOrdinal(lIni.ReadInteger(lSection,Format('Frf%dSpace',[K]),0));
              AmplitudeTagId:=lIni.ReadInt64(lSection,Format('Frf%dAmplitudeTagId',[K]),0);
              AmplitudeTagName:=lIni.ReadString(lSection,Format('Frf%dAmplitudeTagName',[K]),'');
              PhaseTagId:=lIni.ReadInt64(lSection,Format('Frf%dPhaseTagId',[K]),0);
              PhaseTagName:=lIni.ReadString(lSection,Format('Frf%dPhaseTagName',[K]),'');
              Gain:=lIni.ReadFloat(lSection,Format('Frf%dGain',[K]),1);
              Enabled:=lIni.ReadBool(lSection,Format('Frf%dEnabled',[K]),True);
            end;
          end;
          if lComponent is TRecorderStaticTextComponent then
          begin
            TRecorderStaticTextComponent(lComponent).Text :=
              lIni.ReadString(lSection, 'Text', '');
            TRecorderStaticTextComponent(lComponent).FontName :=
              lIni.ReadString(lSection, 'FontName', 'Tahoma');
            TRecorderStaticTextComponent(lComponent).FontSize :=
              lIni.ReadInteger(lSection, 'FontSize', 10);
            TRecorderStaticTextComponent(lComponent).FontColor :=
              lIni.ReadInteger(lSection, 'FontColor', 0);
            TRecorderStaticTextComponent(lComponent).FontStyleBold :=
              lIni.ReadBool(lSection, 'FontBold', False);
            TRecorderStaticTextComponent(lComponent).FontStyleItalic :=
              lIni.ReadBool(lSection, 'FontItalic', False);
          end;
          if lComponent is TRecorderButtonComponent then
          begin
            TRecorderButtonComponent(lComponent).Caption := lIni.ReadString(lSection, 'Caption', 'Button');
            lItemCount := lIni.ReadInteger(lSection, 'Behavior', Ord(rbbToggle));
            if (lItemCount < Ord(Low(TRecorderButtonBehavior))) or
              (lItemCount > Ord(High(TRecorderButtonBehavior))) then
              lItemCount := Ord(rbbToggle);
            TRecorderButtonComponent(lComponent).Behavior := TRecorderButtonBehavior(lItemCount);
            TRecorderButtonComponent(lComponent).PressedValue := lIni.ReadFloat(lSection, 'PressedValue', 1.0);
            TRecorderButtonComponent(lComponent).ReleasedValue := lIni.ReadFloat(lSection, 'ReleasedValue', 0.0);
            TRecorderButtonComponent(lComponent).PulseDurationMs := lIni.ReadInteger(lSection, 'PulseDurationMs', 250);
            TRecorderButtonComponent(lComponent).PressedImageFileName := lIni.ReadString(lSection, 'PressedImage', '');
            TRecorderButtonComponent(lComponent).ReleasedImageFileName := lIni.ReadString(lSection, 'ReleasedImage', '');
          if lComponent is TRecorderInputFieldComponent then
            TRecorderInputFieldComponent(lComponent).DisplayFormat :=
              lIni.ReadString(lSection, 'DisplayFormat', '0.###');
          end;
          if lComponent is TRecorderTagValueComponent then
          begin
            TRecorderTagValueComponent(lComponent).DisplayFormat :=
              lIni.ReadString(lSection, 'DisplayFormat', '0.###');
            lItemCount := lIni.ReadInteger(lSection, 'ShowNameMode', Ord(tvnmTop));
            if (lItemCount < Ord(Low(TRecorderTagValueNameMode))) or
              (lItemCount > Ord(High(TRecorderTagValueNameMode))) then
              lItemCount := Ord(tvnmTop);
            TRecorderTagValueComponent(lComponent).ShowNameMode :=
              TRecorderTagValueNameMode(lItemCount);
            TRecorderTagValueComponent(lComponent).Caption :=
              lIni.ReadString(lSection, 'Caption', '');
            TRecorderTagValueComponent(lComponent).UseSourceTagName :=
              lIni.ReadBool(lSection, 'UseSourceTagName', True);
            TRecorderTagValueComponent(lComponent).FontName :=
              lIni.ReadString(lSection, 'FontName', 'Tahoma');
            TRecorderTagValueComponent(lComponent).FontSize :=
              lIni.ReadInteger(lSection, 'FontSize', 10);
            TRecorderTagValueComponent(lComponent).FontColor :=
              lIni.ReadInteger(lSection, 'FontColor', 0);
            TRecorderTagValueComponent(lComponent).FontStyleBold :=
              lIni.ReadBool(lSection, 'FontBold', True);
            TRecorderTagValueComponent(lComponent).FontStyleItalic :=
              lIni.ReadBool(lSection, 'FontItalic', False);
          end;
          if lComponent is TRecorderImageComponent then
          begin
            lImage := TRecorderImageComponent(lComponent);
            lImage.Images.Clear;
            lItemCount := lIni.ReadInteger(lSection, 'ImageCount', 0);
            for K := 0 to lItemCount - 1 do
              lImage.Images.Add(
                lIni.ReadString(lSection, Format('Image%dValue', [K]), '') +
                '=' + LoadGuiResourceFileName(AFileName,
                lIni.ReadString(lSection, Format('Image%dFile', [K]), '')));
            lImage.ClearSvgBindings;
            lItemCount := lIni.ReadInteger(lSection, 'SvgBindingCount', 0);
            for K := 0 to lItemCount - 1 do
            begin
              lImage.AddSvgBinding.ParameterName := lIni.ReadString(lSection,
                Format('SvgBinding%dParameter', [K]), '');
              lImage.SvgBindings[lImage.SvgBindingCount - 1].TagId :=
                lIni.ReadInt64(lSection, Format('SvgBinding%dTagId', [K]), 0);
              lImage.SvgBindings[lImage.SvgBindingCount - 1].TagName :=
                lIni.ReadString(lSection, Format('SvgBinding%dTagName', [K]), '');
              lImage.SvgBindings[lImage.SvgBindingCount - 1].ValueKind :=
                TRecorderSvgValueKind(EnsureRange(lIni.ReadInteger(lSection,
                  Format('SvgBinding%dValueKind', [K]), 0),
                  Ord(Low(TRecorderSvgValueKind)),
                  Ord(High(TRecorderSvgValueKind))));
            end;
          end;
          if lComponent is TRecorderMeasurementSectionComponent then
          begin
            lMeasure := TRecorderMeasurementSectionComponent(lComponent);
            lMeasure.Caption := lIni.ReadString(lSection, 'MeasureCaption',
              lMeasure.Caption);
            lMeasure.GenerateTags := lIni.ReadBool(lSection,
              'MeasureGenerateTags', False);
            lMeasure.BackgroundColor := lIni.ReadInteger(lSection,
              'MeasureBackgroundColor', lMeasure.BackgroundColor);
            lMeasure.TextBackgroundColor := lIni.ReadInteger(lSection,
              'MeasureTextBackgroundColor', lMeasure.TextBackgroundColor);
            lMeasure.CaptionFont := MakeFontSnapshot(
              lIni.ReadString(lSection, 'MeasureCaptionFontName',
                lMeasure.CaptionFont.Name),
              lIni.ReadInteger(lSection, 'MeasureCaptionFontSize',
                lMeasure.CaptionFont.Size),
              lIni.ReadInteger(lSection, 'MeasureCaptionFontColor',
                lMeasure.CaptionFont.Color),
              lIni.ReadBool(lSection, 'MeasureCaptionFontBold',
                lMeasure.CaptionFont.Bold),
              lIni.ReadBool(lSection, 'MeasureCaptionFontItalic',
                lMeasure.CaptionFont.Italic));
            lMeasure.StressNamedFontName := lIni.ReadString(lSection,
              'MeasureStressNamedFont', '');
            lMeasure.StressFont := MakeFontSnapshot(
              lIni.ReadString(lSection, 'MeasureStressFontName',
                lMeasure.StressFont.Name),
              lIni.ReadInteger(lSection, 'MeasureStressFontSize',
                lMeasure.StressFont.Size),
              lIni.ReadInteger(lSection, 'MeasureStressFontColor',
                lMeasure.StressFont.Color),
              lIni.ReadBool(lSection, 'MeasureStressFontBold',
                lMeasure.StressFont.Bold),
              lIni.ReadBool(lSection, 'MeasureStressFontItalic',
                lMeasure.StressFont.Italic));
            lMeasure.SectionId := lIni.ReadString(lSection,
              'MeasureSectionId', lMeasure.SectionId);
            lMeasure.YoungModulusMPa := lIni.ReadFloat(lSection,
              'MeasureYoungModulusMPa', lMeasure.YoungModulusMPa);
            lMeasure.PoissonRatio := lIni.ReadFloat(lSection,
              'MeasurePoissonRatio', lMeasure.PoissonRatio);
            lMeasure.TemperatureCoefficient := lIni.ReadFloat(lSection,
              'MeasureTemperatureCoefficient', lMeasure.TemperatureCoefficient);
            lMeasure.ReferenceTemperatureC := lIni.ReadFloat(lSection,
              'MeasureReferenceTemperatureC', lMeasure.ReferenceTemperatureC);
            lMeasure.ClearRows;
            lItemCount := lIni.ReadInteger(lSection, 'MeasureRowCount', 0);
            for K := 0 to lItemCount - 1 do
            begin
              lMeasureRow := lMeasure.AddRow;
              lMeasureRow.PointNo := lIni.ReadInteger(lSection,
                Format('MeasureRow%dPointNo', [K]), K + 1);
              lMeasureRow.PointInfo := lIni.ReadString(lSection,
                Format('MeasureRow%dPointInfo', [K]), '');
              L := lIni.ReadInteger(lSection,
                Format('MeasureRow%dRosetteType', [K]), Ord(rrtThreeComponent));
              if (L < Ord(Low(TRecorderRosetteType))) or
                (L > Ord(High(TRecorderRosetteType))) then
                L := Ord(rrtThreeComponent);
              lMeasureRow.RosetteType := TRecorderRosetteType(L);
              lMeasureRow.PositionDeg := lIni.ReadFloat(lSection,
                Format('MeasureRow%dPositionDeg', [K]), 0.0);
              for lRole := Low(TRecorderRosetteRole) to High(TRecorderRosetteRole) do
              begin
                lMeasureRow.TagNames[lRole] := lIni.ReadString(lSection,
                  Format('MeasureRow%d%sTagName', [K,
                    RecorderRosetteRoleToText(lRole)]), '');
                lMeasureRow.TagIds[lRole] := lIni.ReadInt64(lSection,
                  Format('MeasureRow%d%sTagId', [K,
                    RecorderRosetteRoleToText(lRole)]), 0);
                lMeasureRow.Balances[lRole] := lIni.ReadFloat(lSection,
                  Format('MeasureRow%d%sBalance', [K,
                    RecorderRosetteRoleToText(lRole)]), 0.0);
              end;
            end;
          end;
          if lComponent is TRecorderSignalGeneratorComponent then
          begin
            TRecorderSignalGeneratorComponent(lComponent).Enabled :=
              lIni.ReadBool(lSection, 'GeneratorEnabled', True);
            TRecorderSignalGeneratorComponent(lComponent).ClearSignals;
            lItemCount := lIni.ReadInteger(lSection, 'GeneratorSignalCount', 0);
            for K := 0 to lItemCount - 1 do
            begin
              lGeneratedSignal :=
                TRecorderSignalGeneratorComponent(lComponent).AddSignal;
              lGeneratedSignal.Enabled := lIni.ReadBool(lSection,
                Format('Generator%dEnabled', [K]), True);
              lGeneratedSignal.Name := lIni.ReadString(lSection,
                Format('Generator%dName', [K]), Format('GenSignal_%0.3d', [K + 1]));
              lGeneratedSignal.Kind := TRecorderGeneratedSignalKind(EnsureRange(
                lIni.ReadInteger(lSection, Format('Generator%dKind', [K]), 0),
                Ord(Low(TRecorderGeneratedSignalKind)),
                Ord(High(TRecorderGeneratedSignalKind))));
              lGeneratedSignal.SampleRateHz := Max(1.0, lIni.ReadFloat(lSection,
                Format('Generator%dSampleRateHz', [K]), 1000));
              lGeneratedSignal.Amplitude := lIni.ReadFloat(lSection,
                Format('Generator%dAmplitude', [K]), 1);
              lGeneratedSignal.FrequencyHz := Max(0.0, lIni.ReadFloat(lSection,
                Format('Generator%dFrequencyHz', [K]), 10));
              lGeneratedSignal.PhaseDeg := lIni.ReadFloat(lSection,
                Format('Generator%dPhaseDeg', [K]), 0);
              lGeneratedSignal.Offset := lIni.ReadFloat(lSection,
                Format('Generator%dOffset', [K]), 0);
              lGeneratedSignal.SweepEnabled := lIni.ReadBool(lSection,
                Format('Generator%dSweepEnabled', [K]), False);
              lGeneratedSignal.SweepEndFrequencyHz := Max(0.0,
                lIni.ReadFloat(lSection, Format('Generator%dSweepEndHz', [K]), 100));
              lGeneratedSignal.SweepDurationSec := Max(0.001,
                lIni.ReadFloat(lSection, Format('Generator%dSweepDurationSec', [K]), 10));
              lGeneratedSignal.SweepLogarithmic := lIni.ReadBool(lSection,
                Format('Generator%dSweepLog', [K]), False);
              lGeneratedSignal.ChangePhase := lIni.ReadBool(lSection,
                Format('Generator%dChangePhase', [K]), False);
              lGeneratedSignal.PhaseVelocityDegSec := lIni.ReadFloat(lSection,
                Format('Generator%dPhaseVelocity', [K]), 0.0);
            end;
          end;
          if lComponent is TRecorderOscillogramComponent then
          begin
            TRecorderOscillogramComponent(lComponent).DisplayFormat :=
              lIni.ReadString(lSection, 'DisplayFormat', '4');
            TRecorderOscillogramComponent(lComponent).BindingMode :=
              TRecorderTagBindingMode(lIni.ReadInteger(lSection, 'BindingMode',
                Ord(rtbmRelativeSelectedTag)));
            TRecorderOscillogramComponent(lComponent).TagOffset :=
              lIni.ReadInteger(lSection, 'TagOffset', 0);
            if RecorderIsPluginOscillograph(lComponent) then
            begin
            TRecorderOscillogramComponent(lComponent).XScale :=
              lIni.ReadFloat(lSection, 'OscXScale', 0.0);
            if TRecorderOscillogramComponent(lComponent).XScale < 0 then
              TRecorderOscillogramComponent(lComponent).XScale := 0.0;
            TRecorderOscillogramComponent(lComponent).YScale :=
              lIni.ReadFloat(lSection, 'OscYScale', 1.0);
            if TRecorderOscillogramComponent(lComponent).YScale <= 0 then
              TRecorderOscillogramComponent(lComponent).YScale := 1.0;
            TRecorderOscillogramComponent(lComponent).YOffset :=
              lIni.ReadFloat(lSection, 'OscYOffset', 0.0);
            TRecorderOscillogramComponent(lComponent).ClosedInput :=
              lIni.ReadBool(lSection, 'OscClosedInput', False);
            TRecorderOscillogramComponent(lComponent).AutoRangeEnabled :=
              lIni.ReadBool(lSection, 'OscAutoRangeEnabled', False);
            TRecorderOscillogramComponent(lComponent).XCursorEnabled :=
              lIni.ReadBool(lSection, 'OscXCursorEnabled', False);
            TRecorderOscillogramComponent(lComponent).XCursorCount :=
              lIni.ReadInteger(lSection, 'OscXCursorCount', 1);
            if (TRecorderOscillogramComponent(lComponent).XCursorCount < 1) or
              (TRecorderOscillogramComponent(lComponent).XCursorCount > 2) then
              TRecorderOscillogramComponent(lComponent).XCursorCount := 1;
            TRecorderOscillogramComponent(lComponent).LegendVisible :=
              lIni.ReadBool(lSection, 'OscLegendVisible', True);
            TRecorderOscillogramComponent(lComponent).LevelCursorVisible :=
              lIni.ReadBool(lSection, 'OscLevelCursorVisible', False);
            lItemCount := lIni.ReadInteger(lSection, 'OscAxisCount', 1);
            if lItemCount < 1 then
              lItemCount := 1;
            if lItemCount > 16 then
              lItemCount := 16;
            TRecorderOscillogramComponent(lComponent).ClearAxes;
            for K := 0 to lItemCount - 1 do
            begin
              lAxis := TRecorderOscillogramComponent(lComponent).AddAxis;
              lAxis.Name := lIni.ReadString(lSection,
                Format('OscAxis%dName', [K]), lAxis.Name);
              lAxis.YScale := lIni.ReadFloat(lSection,
                Format('OscAxis%dYScale', [K]),
                TRecorderOscillogramComponent(lComponent).YScale);
              if lAxis.YScale <= 0 then
                lAxis.YScale := 1;
              lAxis.YOffset := lIni.ReadFloat(lSection,
                Format('OscAxis%dYOffset', [K]),
                TRecorderOscillogramComponent(lComponent).YOffset);
            end;
            TRecorderOscillogramComponent(lComponent).PrimaryAxisIndex :=
              lIni.ReadInteger(lSection, 'OscPrimaryAxisIndex', 0);
            if (TRecorderOscillogramComponent(lComponent).PrimaryAxisIndex < 0) or
              (TRecorderOscillogramComponent(lComponent).PrimaryAxisIndex >= lItemCount) then
              TRecorderOscillogramComponent(lComponent).PrimaryAxisIndex := 0;
            TRecorderOscillogramComponent(lComponent).TriggerTagName :=
              lIni.ReadString(lSection, 'OscTriggerTag', '');
            TRecorderOscillogramComponent(lComponent).TriggerEnabled :=
              lIni.ReadBool(lSection, 'OscTriggerEnabled', False);
            TRecorderOscillogramComponent(lComponent).TriggerLevel :=
              lIni.ReadFloat(lSection, 'OscTriggerLevel', 0.0);
            TRecorderOscillogramComponent(lComponent).TriggerPreRollPercent :=
              lIni.ReadFloat(lSection, 'OscTriggerPreRollPercent', 25.0);
            end
            else
            begin
              { Advanced axes, trigger and cursor state belongs to the plugin
                Oscillograph. Ignore keys accidentally written by affected
                versions when loading the built-in simple Oscillogram. }
              TRecorderOscillogramComponent(lComponent).XScale := 0.0;
              TRecorderOscillogramComponent(lComponent).YScale := 1.0;
              TRecorderOscillogramComponent(lComponent).YOffset := 0.0;
              TRecorderOscillogramComponent(lComponent).ClosedInput := False;
              TRecorderOscillogramComponent(lComponent).AutoRangeEnabled := False;
              TRecorderOscillogramComponent(lComponent).XCursorEnabled := False;
              TRecorderOscillogramComponent(lComponent).LegendVisible := True;
              TRecorderOscillogramComponent(lComponent).LevelCursorVisible := False;
              TRecorderOscillogramComponent(lComponent).TriggerTagName := '';
              TRecorderOscillogramComponent(lComponent).TriggerEnabled := False;
              TRecorderOscillogramComponent(lComponent).ClearAxes;
              TRecorderOscillogramComponent(lComponent).AddAxis;
              TRecorderOscillogramComponent(lComponent).PrimaryAxisIndex := 0;
            end;
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
              lLine.AxisIndex := lIni.ReadInteger(lSection,
                Format('OscLine%dAxisIndex', [K]), 0);
              if (lLine.AxisIndex < 0) or (lLine.AxisIndex >=
                TRecorderOscillogramComponent(lComponent).AxisCount) then
                lLine.AxisIndex := 0;
            end;
          end;
          if lComponent is TRecorderDonutComponent then
          begin
            TRecorderDonutComponent(lComponent).Title :=
              lIni.ReadString(lSection, 'DonutTitle', 'Круговая гистограмма');
            TRecorderDonutComponent(lComponent).HolePercent :=
              lIni.ReadInteger(lSection, 'DonutHolePercent', 55);
            TRecorderDonutComponent(lComponent).SingleValueMode :=
              lIni.ReadBool(lSection, 'DonutSingleValueMode', False);
            TRecorderDonutComponent(lComponent).RangeMin :=
              lIni.ReadFloat(lSection, 'DonutRangeMin', 0);
            TRecorderDonutComponent(lComponent).RangeMax :=
              lIni.ReadFloat(lSection, 'DonutRangeMax', 100);
            TRecorderDonutComponent(lComponent).TagNames.Clear;
            lItemCount := lIni.ReadInteger(lSection, 'DonutTagCount', 0);
            for K := 0 to lItemCount - 1 do
            begin
              TRecorderDonutComponent(lComponent).TagNames.Add(
                lIni.ReadString(lSection, Format('DonutTag%d', [K]), ''));
              TRecorderDonutComponent(lComponent).SetTagIdAt(K,
                lIni.ReadInt64(lSection, Format('DonutTag%dId', [K]), 0));
            end;
          end;
          if lComponent is TRecorderVibrationEstimateComponent then
          begin
            TRecorderVibrationEstimateComponent(lComponent).Caption :=
              lIni.ReadString(lSection, 'Caption', 'Виброоценка');
            TRecorderVibrationEstimateComponent(lComponent).UseSourceTagName :=
              lIni.ReadBool(lSection, 'UseSourceTagName', True);
            lItemCount := lIni.ReadInteger(lSection, 'Quantity', 0);
            if (lItemCount < Ord(Low(TRecorderVibrationQuantity))) or
              (lItemCount > Ord(High(TRecorderVibrationQuantity))) then
              lItemCount := Ord(rvqAcceleration);
            TRecorderVibrationEstimateComponent(lComponent).Quantity :=
              TRecorderVibrationQuantity(lItemCount);
            TRecorderVibrationEstimateComponent(lComponent).BandName :=
              lIni.ReadString(lSection, 'BandName', '');
            TRecorderVibrationEstimateComponent(lComponent).OutputUnit :=
              lIni.ReadString(lSection, 'OutputUnit',
                RecorderVibrationDefaultUnit(TRecorderVibrationQuantity(lItemCount)));
            TRecorderVibrationEstimateComponent(lComponent).DisplayFormat :=
              lIni.ReadString(lSection, 'DisplayFormat', '0.###');
            TRecorderVibrationEstimateComponent(lComponent).AmplitudeMode :=
              lIni.ReadBool(lSection, 'AmplitudeMode', False);
            TRecorderVibrationEstimateComponent(lComponent).FontName :=
              lIni.ReadString(lSection, 'FontName', 'Tahoma');
            TRecorderVibrationEstimateComponent(lComponent).FontSize :=
              lIni.ReadInteger(lSection, 'FontSize', 10);
            TRecorderVibrationEstimateComponent(lComponent).FontColor :=
              lIni.ReadInt64(lSection, 'FontColor', 0);
            TRecorderVibrationEstimateComponent(lComponent).FontStyleBold :=
              lIni.ReadBool(lSection, 'FontBold', False);
            TRecorderVibrationEstimateComponent(lComponent).FontStyleItalic :=
              lIni.ReadBool(lSection, 'FontItalic', False);
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
            lSpectrum.SpectrumValueMode := lIni.ReadInteger(lSection,
              'SpectrumValueMode', lSpectrum.SpectrumValueMode);
            lSpectrum.SpectrumIntegration := lIni.ReadInteger(lSection,
              'SpectrumIntegration', lSpectrum.SpectrumIntegration);
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
          if lComponent is TRecorderLissajousComponent then
          begin
            lCount := lIni.ReadInteger(lSection, 'LissajousLineCount', -1);
            if lCount >= 0 then
            begin
              if lCount = 0 then lCount := 1;
              TRecorderLissajousComponent(lComponent).ClearLines;
              for K := 0 to lCount - 1 do
              begin
                lLissajousLine := TRecorderLissajousComponent(lComponent).AddLine;
                lLissajousLine.Name := lIni.ReadString(lSection,
                  Format('LissajousLine%dName', [K]), Format('Линия %d', [K + 1]));
                lLissajousLine.XTagName := lIni.ReadString(lSection,
                  Format('LissajousLine%dXTagName', [K]), '');
                lLissajousLine.XTagId := lIni.ReadInt64(lSection,
                  Format('LissajousLine%dXTagId', [K]), 0);
                lLissajousLine.YTagName := lIni.ReadString(lSection,
                  Format('LissajousLine%dYTagName', [K]), '');
                lLissajousLine.YTagId := lIni.ReadInt64(lSection,
                  Format('LissajousLine%dYTagId', [K]), 0);
                lLissajousLine.Color := lIni.ReadInt64(lSection,
                  Format('LissajousLine%dColor', [K]), lLissajousLine.Color);
                lLissajousLine.DiameterColor := lIni.ReadInt64(lSection,
                  Format('LissajousLine%dDiameterColor', [K]),
                  lLissajousLine.Color);
                lLissajousLine.Width := lIni.ReadInteger(lSection,
                  Format('LissajousLine%dWidth', [K]), lLissajousLine.Width);
                lLissajousLine.DrawPoints := lIni.ReadBool(lSection,
                  Format('LissajousLine%dDrawPoints', [K]), False);
                lLissajousLine.DrawLine := lIni.ReadBool(lSection,
                  Format('LissajousLine%dDrawLine', [K]), True);
                lLissajousLine.DrawMainDiameter := lIni.ReadBool(lSection,
                  Format('LissajousLine%dDrawMainDiameter', [K]), False);
                lLissajousLine.DrawDiameterCenter := lIni.ReadBool(lSection,
                  Format('LissajousLine%dDrawDiameterCenter', [K]), False);
                lLissajousLine.ShowDiameterValue := lIni.ReadBool(lSection,
                  Format('LissajousLine%dShowDiameterValue', [K]), False);
              end;
            end
            else
            begin
            TRecorderLissajousComponent(lComponent).XTagName := lIni.ReadString(lSection, 'XTagName', '');
            TRecorderLissajousComponent(lComponent).YTagName := lIni.ReadString(lSection, 'YTagName', '');
            TRecorderLissajousComponent(lComponent).XTagId := lIni.ReadInt64(lSection, 'XTagId', 0);
            TRecorderLissajousComponent(lComponent).YTagId := lIni.ReadInt64(lSection, 'YTagId', 0);
            TRecorderLissajousComponent(lComponent).DurationSec := lIni.ReadFloat(lSection, 'DurationSec', 0.3);
            TRecorderLissajousComponent(lComponent).RangeMinX := lIni.ReadFloat(lSection, 'RangeMinX', -3);
            TRecorderLissajousComponent(lComponent).RangeMaxX := lIni.ReadFloat(lSection, 'RangeMaxX', 3);
            TRecorderLissajousComponent(lComponent).RangeMinY := lIni.ReadFloat(lSection, 'RangeMinY', -3);
            TRecorderLissajousComponent(lComponent).RangeMaxY := lIni.ReadFloat(lSection, 'RangeMaxY', 3);
            TRecorderLissajousComponent(lComponent).KeepSquare :=
              lIni.ReadBool(lSection, 'KeepSquare', False);
            TRecorderLissajousComponent(lComponent).LineColor := lIni.ReadInt64(lSection, 'LineColor', $00FF0000);
            TRecorderLissajousComponent(lComponent).LineWidth := lIni.ReadInteger(lSection, 'LineWidth', 2);
            end;
            { Диапазоны и длительность общие для всех линий. }
            TRecorderLissajousComponent(lComponent).DurationSec := lIni.ReadFloat(lSection, 'DurationSec', 0.3);
            TRecorderLissajousComponent(lComponent).RangeMinX := lIni.ReadFloat(lSection, 'RangeMinX', -3);
            TRecorderLissajousComponent(lComponent).RangeMaxX := lIni.ReadFloat(lSection, 'RangeMaxX', 3);
            TRecorderLissajousComponent(lComponent).RangeMinY := lIni.ReadFloat(lSection, 'RangeMinY', -3);
            TRecorderLissajousComponent(lComponent).RangeMaxY := lIni.ReadFloat(lSection, 'RangeMaxY', 3);
            TRecorderLissajousComponent(lComponent).KeepSquare :=
              lIni.ReadBool(lSection, 'KeepSquare', False);
          end;
          if lComponent is TRecorderFrequencyResponseComponent then
          begin
            lFrequencyResponse := TRecorderFrequencyResponseComponent(lComponent);
            lFrequencyResponse.SourceTagName := lIni.ReadString(lSection,
              'FrSourceTagName', '');
            lFrequencyResponse.SourceTagId := lIni.ReadInt64(lSection,
              'FrSourceTagId', 0);
            lFrequencyResponse.ValueTagName := lIni.ReadString(lSection,
              'FrValueTagName', '');
            lFrequencyResponse.ValueTagId := lIni.ReadInt64(lSection,
              'FrValueTagId', 0);
            lFrequencyResponse.FrequencyTagName := lIni.ReadString(lSection,
              'FrFrequencyTagName', '');
            lFrequencyResponse.FrequencyTagId := lIni.ReadInt64(lSection,
              'FrFrequencyTagId', 0);
            lItemCount := EnsureRange(lIni.ReadInteger(lSection, 'FrKind', 0),
              Ord(Low(TRecorderFrequencyResponseKind)),
              Ord(High(TRecorderFrequencyResponseKind)));
            lFrequencyResponse.Kind := TRecorderFrequencyResponseKind(lItemCount);
            lFrequencyResponse.MinFrequencyHz := lIni.ReadFloat(lSection,
              'FrMinFrequencyHz', lFrequencyResponse.MinFrequencyHz);
            lFrequencyResponse.MaxFrequencyHz := lIni.ReadFloat(lSection,
              'FrMaxFrequencyHz', lFrequencyResponse.MaxFrequencyHz);
            lFrequencyResponse.MinValue := lIni.ReadFloat(lSection,
              'FrMinValue', lFrequencyResponse.MinValue);
            lFrequencyResponse.MaxValue := lIni.ReadFloat(lSection,
              'FrMaxValue', lFrequencyResponse.MaxValue);
            lFrequencyResponse.BufferSize := Max(1, lIni.ReadInteger(lSection,
              'FrBufferSize', lFrequencyResponse.BufferSize));
            lFrequencyResponse.UniformX := lIni.ReadBool(lSection,
              'FrUniformX', lFrequencyResponse.UniformX);
            lFrequencyResponse.FrequencyStepHz := lIni.ReadFloat(lSection,
              'FrFrequencyStepHz', lFrequencyResponse.FrequencyStepHz);
            lItemCount := EnsureRange(lIni.ReadInteger(lSection, 'FrMergeMode', 0),
              Ord(Low(TRecorderFrequencyResponseMergeMode)),
              Ord(High(TRecorderFrequencyResponseMergeMode)));
            lFrequencyResponse.MergeMode :=
              TRecorderFrequencyResponseMergeMode(lItemCount);
            lFrequencyResponse.LegendVisible := lIni.ReadBool(lSection,
              'FrLegendVisible', lFrequencyResponse.LegendVisible);
            lCount := lIni.ReadInteger(lSection, 'FrAxisCount', -1);
            if lCount >= 0 then
            begin
              lFrequencyResponse.ClearAxes;
              for K := 0 to Max(1, lCount) - 1 do
              begin
                lFrAxis := lFrequencyResponse.AddAxis;
                lFrAxis.Name := lIni.ReadString(lSection, Format('FrAxis%dName', [K]), Format('Ось %d', [K + 1]));
                lFrAxis.MinValue := lIni.ReadFloat(lSection, Format('FrAxis%dMin', [K]), 0);
                lFrAxis.MaxValue := lIni.ReadFloat(lSection, Format('FrAxis%dMax', [K]), 10);
                lFrAxis.Logarithmic := lIni.ReadBool(lSection, Format('FrAxis%dLog', [K]), False);
              end;
              lFrequencyResponse.ClearLines;
              lItemCount := lIni.ReadInteger(lSection, 'FrLineCount', 0);
              for K := 0 to lItemCount - 1 do
              begin
                lFrLine := lFrequencyResponse.AddLine;
                lFrLine.Name := lIni.ReadString(lSection, Format('FrLine%dName', [K]), Format('Линия %d', [K + 1]));
                lFrLine.AxisName := lIni.ReadString(lSection, Format('FrLine%dAxis', [K]), lFrequencyResponse.Axes[0].Name);
                lFrLine.SourceTagName := lIni.ReadString(lSection, Format('FrLine%dSourceName', [K]), '');
                lFrLine.SourceTagId := lIni.ReadInt64(lSection, Format('FrLine%dSourceId', [K]), 0);
                lFrLine.ValueTagName := lIni.ReadString(lSection, Format('FrLine%dValueName', [K]), '');
                lFrLine.ValueTagId := lIni.ReadInt64(lSection, Format('FrLine%dValueId', [K]), 0);
                lFrLine.FrequencyTagName := lIni.ReadString(lSection, Format('FrLine%dFrequencyName', [K]), '');
                lFrLine.FrequencyTagId := lIni.ReadInt64(lSection, Format('FrLine%dFrequencyId', [K]), 0);
                lFrLine.Kind := TRecorderFrequencyResponseKind(EnsureRange(lIni.ReadInteger(lSection, Format('FrLine%dKind', [K]), 0), 0, 2));
                lFrLine.BufferSize := Max(1, lIni.ReadInteger(lSection, Format('FrLine%dBuffer', [K]), 1024));
                lFrLine.UniformX := lIni.ReadBool(lSection, Format('FrLine%dUniform', [K]), False);
                lFrLine.FrequencyStepHz := lIni.ReadFloat(lSection, Format('FrLine%dStep', [K]), 1);
                lFrLine.MergeMode := TRecorderFrequencyResponseMergeMode(EnsureRange(lIni.ReadInteger(lSection, Format('FrLine%dMerge', [K]), 0), 0, 2));
                lFrLine.Color := lIni.ReadInt64(lSection, Format('FrLine%dColor', [K]), lFrLine.Color);
                lFrLine.Width := lIni.ReadInteger(lSection, Format('FrLine%dWidth', [K]), 2);
                lFrLine.DrawLine := lIni.ReadBool(lSection, Format('FrLine%dDrawLine', [K]), True);
                lFrLine.DrawPoints := lIni.ReadBool(lSection, Format('FrLine%dDrawPoints', [K]), True);
              end;
            end;
            if (lCount < 0) and (lFrequencyResponse.LineCount > 0) then
            begin
              lFrAxis := lFrequencyResponse.Axes[0];
              lFrAxis.MinValue := lFrequencyResponse.MinValue;
              lFrAxis.MaxValue := lFrequencyResponse.MaxValue;
              lFrLine := lFrequencyResponse.Lines[0];
              lFrLine.Name := lFrequencyResponse.SourceTagName;
              lFrLine.SourceTagName := lFrequencyResponse.SourceTagName;
              lFrLine.SourceTagId := lFrequencyResponse.SourceTagId;
              lFrLine.ValueTagName := lFrequencyResponse.ValueTagName;
              lFrLine.ValueTagId := lFrequencyResponse.ValueTagId;
              lFrLine.FrequencyTagName := lFrequencyResponse.FrequencyTagName;
              lFrLine.FrequencyTagId := lFrequencyResponse.FrequencyTagId;
              lFrLine.Kind := lFrequencyResponse.Kind;
              lFrLine.BufferSize := lFrequencyResponse.BufferSize;
              lFrLine.UniformX := lFrequencyResponse.UniformX;
              lFrLine.FrequencyStepHz := lFrequencyResponse.FrequencyStepHz;
              lFrLine.MergeMode := lFrequencyResponse.MergeMode;
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
            if lComponent is TRecorderSqlTrendComponent then
            begin
              TRecorderSqlTrendComponent(lComponent).ConfigFileName :=
                IncludeTrailingPathDelimiter(ExtractFileDir(AFileName)) +
                'sql-db.ini';
              lItemCount := lIni.ReadInteger(lSection, 'SqlTimeMode',
                Ord(sttmLatestWindow));
              if (lItemCount < Ord(Low(TRecorderSqlTrendTimeMode))) or
                (lItemCount > Ord(High(TRecorderSqlTrendTimeMode))) then
                lItemCount := Ord(sttmLatestWindow);
              TRecorderSqlTrendComponent(lComponent).TimeMode :=
                TRecorderSqlTrendTimeMode(lItemCount);
              TRecorderSqlTrendComponent(lComponent).FromUtc :=
                lIni.ReadFloat(lSection, 'SqlFromUtc',
                  LocalTimeToUniversal(Now) - 1);
              TRecorderSqlTrendComponent(lComponent).ToUtc :=
                lIni.ReadFloat(lSection, 'SqlToUtc',
                  LocalTimeToUniversal(Now));
              TRecorderSqlTrendComponent(lComponent).MaxPointsPerLine :=
                EnsureRange(lIni.ReadInteger(lSection, 'SqlMaxPoints', 4000),
                  32, 100000);
              TRecorderSqlTrendComponent(lComponent).ShowEvents :=
                lIni.ReadBool(lSection, 'SqlShowEvents', True);
              TRecorderSqlTrendComponent(lComponent).ShowRecordingEvents :=
                lIni.ReadBool(lSection, 'SqlShowRecordingEvents', True);
              TRecorderSqlTrendComponent(lComponent).ShowTagAlarmEvents :=
                lIni.ReadBool(lSection, 'SqlShowTagAlarmEvents', True);
              lItemCount := lIni.ReadInteger(lSection, 'SqlDisplayCount', -1);
              if lItemCount < 0 then
                TRecorderSqlTrendComponent(lComponent).ImportLegacyTrend
              else
              begin
                TRecorderSqlTrendComponent(lComponent).ClearDisplays;
                for K := 0 to lItemCount - 1 do
                begin
                  lSqlDisplay := TRecorderSqlTrendComponent(lComponent).AddDisplay(
                    lIni.ReadString(lSection, Format('SqlDisplay%dName', [K]),
                      'Отображение ' + IntToStr(K + 1)));
                  lSqlDisplay.ClearAxes;
                  for L := 0 to lIni.ReadInteger(lSection,
                    Format('SqlDisplay%dAxisCount', [K]), 1) - 1 do
                  begin
                    lAxis := lSqlDisplay.AddAxis;
                    lAxis.Name := lIni.ReadString(lSection, Format('SqlDisplay%dAxis%dName', [K, L]), lAxis.Name);
                    lAxis.Color := lIni.ReadInteger(lSection, Format('SqlDisplay%dAxis%dColor', [K, L]), lAxis.Color);
                    lAxis.RangeMin := lIni.ReadFloat(lSection, Format('SqlDisplay%dAxis%dRangeMin', [K, L]), lAxis.RangeMin);
                    lAxis.RangeMax := lIni.ReadFloat(lSection, Format('SqlDisplay%dAxis%dRangeMax', [K, L]), lAxis.RangeMax);
                  end;
                  for L := 0 to lIni.ReadInteger(lSection,
                    Format('SqlDisplay%dLineCount', [K]), 0) - 1 do
                  begin
                    lLine := lSqlDisplay.AddLine;
                    lLine.Name := lIni.ReadString(lSection, Format('SqlDisplay%dLine%dName', [K, L]), lLine.Name);
                    lLine.TagName := lIni.ReadString(lSection, Format('SqlDisplay%dLine%dTagName', [K, L]), '');
                    lLine.TagId := lIni.ReadInt64(lSection, Format('SqlDisplay%dLine%dTagId', [K, L]), 0);
                    lLine.EstimateKind := TRecorderTagEstimateKind(lIni.ReadInteger(lSection, Format('SqlDisplay%dLine%dEstimateKind', [K, L]), Ord(lLine.EstimateKind)));
                    lLine.AxisIndex := lIni.ReadInteger(lSection, Format('SqlDisplay%dLine%dAxisIndex', [K, L]), 0);
                    lLine.Color := lIni.ReadInteger(lSection, Format('SqlDisplay%dLine%dColor', [K, L]), lLine.Color);
                    lLine.Width := lIni.ReadInteger(lSection, Format('SqlDisplay%dLine%dWidth', [K, L]), lLine.Width);
                    lLine.Visible := lIni.ReadBool(lSection, Format('SqlDisplay%dLine%dVisible', [K, L]), True);
                  end;
                end;
                if TRecorderSqlTrendComponent(lComponent).DisplayCount = 0 then
                  TRecorderSqlTrendComponent(lComponent).AddDisplay('Отображение 1');
                TRecorderSqlTrendComponent(lComponent).ActiveDisplayIndex :=
                  lIni.ReadInteger(lSection, 'SqlActiveDisplay', 0);
              end;
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
