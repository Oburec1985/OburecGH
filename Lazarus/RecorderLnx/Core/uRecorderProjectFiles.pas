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

{ Сохраняет конфигурацию тегов в JSON-файл }
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
  IniFiles, fpjson, jsonparser;

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
    SaveDataSources(lRoot, ATags);

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
      lTagJson.Add('moduleType', lTag.ModuleType);
      lTagJson.Add('pollFrequencyHz', lTag.PollFrequencyHz);
      lTagJson.Add('rangeMin', lTag.RangeMin);
      lTagJson.Add('rangeMax', lTag.RangeMax);
      lTagJson.Add('autoRange', lTag.AutoRange);
      lTagJson.Add('autoUnit', lTag.AutoUnit);
      SaveTagEstimates(JsonObject(lTagJson, 'estimates'), lTag);
      SaveTagSetpoints(JsonObject(lTagJson, 'setpoints'), lTag);
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
        lTag.ModuleType := lTagJson.Get('moduleType', lTag.ModuleType);
        lTag.PollFrequencyHz := lTagJson.Get('pollFrequencyHz',
          lTag.PollFrequencyHz);
        lTag.RangeMin := lTagJson.Get('rangeMin', lTag.RangeMin);
        lTag.RangeMax := lTagJson.Get('rangeMax', lTag.RangeMax);
        lTag.AutoRange := lTagJson.Get('autoRange', lTag.AutoRange);
        lTag.AutoUnit := lTagJson.Get('autoUnit', lTag.AutoUnit);
        LoadTagEstimates(FindObject(lTagJson, 'estimates'), lTag);
        LoadTagSetpoints(FindObject(lTagJson, 'setpoints'), lTag);
        ATags.AddTag(lTag);
        lTag := nil;
      finally
        lTag.Free;
      end;
    end;
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
  lSection: string;
  lTrend: TRecorderTrendComponent;
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
              lLine.Name := lIni.ReadString(lSection, Format('Line%dName', [K]), lLine.Name);
              lLine.TagName := lIni.ReadString(lSection, Format('Line%dTagName', [K]), lLine.TagName);
              lLine.EstimateKind := TRecorderTagEstimateKind(lIni.ReadInteger(lSection, Format('Line%dEstimateKind', [K]), Ord(lLine.EstimateKind)));
              lLine.AxisIndex := lIni.ReadInteger(lSection, Format('Line%dAxisIndex', [K]), lLine.AxisIndex);
              lLine.Color := lIni.ReadInteger(lSection, Format('Line%dColor', [K]), lLine.Color);
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
