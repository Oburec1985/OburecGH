unit uRecorderFrequencyResponseModel;

{ Настройки компонента частотного отклика и однократное разрешение привязок
  каналов при настройке. Ссылки на теги заимствуются из реестра; модуль не
  создаёт расчётные теги и не запускает DSP. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderFormModel, uRecorderTags,
  uRecorderFrequencyResponse;

type
  TRecorderFrequencyResponseKind = (frkAmplitude, frkPhase, frkTransfer);
  TRecorderFrequencyResponseFrequencyMode = (frfmAutomatic, frfmLast,
    frfmMean, frfmSpectrum, frfmTacho);

  { Разрешённая при настройке пара каналов. Теги принадлежат реестру; во время
    работы компонент читает готовые оценки, не разбирая настройки алгоритма. }
  TRecorderFrequencyResponseBinding = record
    ValueTag, FrequencyTag: TRecorderTag;
    FrequencyMode: TRecorderFrequencyResponseFrequencyMode;
    FrequencyLocked, ValueFromSummary: Boolean;
    Hint: string;
  end;

  TRecorderFrequencyResponseAxis = class
  public
    Name: string;
    MinValue, MaxValue: Double;
    Logarithmic: Boolean;
    Kind: TRecorderFrequencyResponseKind;
    constructor Create;
    procedure Assign(ASource: TRecorderFrequencyResponseAxis);
  end;

  TRecorderFrequencyResponseLine = class
  public
    Name, AxisName: string;
    SourceTagName, ValueTagName, FrequencyTagName: string;
    SourceTagId, ValueTagId, FrequencyTagId: TRecorderTagId;
    Kind: TRecorderFrequencyResponseKind;
    FrequencyMode: TRecorderFrequencyResponseFrequencyMode;
    BufferSize: Integer;
    UniformX: Boolean;
    FrequencyStepHz: Double;
    MergeMode: TRecorderFrequencyResponseMergeMode;
    Color: LongInt;
    Width: Integer;
    DrawLine, DrawPoints: Boolean;
    constructor Create;
    procedure Assign(ASource: TRecorderFrequencyResponseLine);
    procedure SetSourceTag(ATag: TRecorderTag);
    procedure SetValueTag(ATag: TRecorderTag);
    procedure SetFrequencyTag(ATag: TRecorderTag);
  end;

  TRecorderFrequencyResponseComponent = class(TRecorderVisualComponent)
  private
    fSourceTagName: string;
    fSourceTagId: TRecorderTagId;
    fValueTagName: string;
    fValueTagId: TRecorderTagId;
    fFrequencyTagName: string;
    fFrequencyTagId: TRecorderTagId;
    fKind: TRecorderFrequencyResponseKind;
    fMinFrequencyHz: Double;
    fMaxFrequencyHz: Double;
    fMinValue: Double;
    fMaxValue: Double;
    fBufferSize: Integer;
    fUniformX: Boolean;
    fFrequencyStepHz: Double;
    fMergeMode: TRecorderFrequencyResponseMergeMode;
    fLegendVisible: Boolean;
    fLogFrequency: Boolean;
    fAxes, fLines: TList;
    function GetAxis(AIndex: Integer): TRecorderFrequencyResponseAxis;
    function GetAxisCount: Integer;
    function GetLine(AIndex: Integer): TRecorderFrequencyResponseLine;
    function GetLineCount: Integer;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(ASource: TRecorderFrequencyResponseComponent);
    function AddAxis: TRecorderFrequencyResponseAxis;
    function AddLine: TRecorderFrequencyResponseLine;
    procedure ClearAxes;
    procedure ClearLines;
    procedure DeleteAxis(AIndex: Integer);
    procedure DeleteLine(AIndex: Integer);
    procedure SetSourceTag(ATag: TRecorderTag);
    procedure SetValueTag(ATag: TRecorderTag);
    procedure SetFrequencyTag(ATag: TRecorderTag);
    function ResolveSourceTag(ARegistry: TRecorderTagRegistry): TRecorderTag;
    function ResolveValueTag(ARegistry: TRecorderTagRegistry): TRecorderTag;
    function ResolveFrequencyTag(ARegistry: TRecorderTagRegistry): TRecorderTag;
    property SourceTagName: string read fSourceTagName write fSourceTagName;
    property SourceTagId: TRecorderTagId read fSourceTagId write fSourceTagId;
    property ValueTagName: string read fValueTagName write fValueTagName;
    property ValueTagId: TRecorderTagId read fValueTagId write fValueTagId;
    property FrequencyTagName: string read fFrequencyTagName write fFrequencyTagName;
    property FrequencyTagId: TRecorderTagId read fFrequencyTagId write fFrequencyTagId;
    property Kind: TRecorderFrequencyResponseKind read fKind write fKind;
    property MinFrequencyHz: Double read fMinFrequencyHz write fMinFrequencyHz;
    property MaxFrequencyHz: Double read fMaxFrequencyHz write fMaxFrequencyHz;
    property MinValue: Double read fMinValue write fMinValue;
    property MaxValue: Double read fMaxValue write fMaxValue;
    property BufferSize: Integer read fBufferSize write fBufferSize;
    property UniformX: Boolean read fUniformX write fUniformX;
    property FrequencyStepHz: Double read fFrequencyStepHz write fFrequencyStepHz;
    property MergeMode: TRecorderFrequencyResponseMergeMode read fMergeMode write fMergeMode;
    property LegendVisible: Boolean read fLegendVisible write fLegendVisible;
    property LogFrequency: Boolean read fLogFrequency write fLogFrequency;
    property Axes[AIndex: Integer]: TRecorderFrequencyResponseAxis read GetAxis;
    property AxisCount: Integer read GetAxisCount;
    property Lines[AIndex: Integer]: TRecorderFrequencyResponseLine read GetLine;
    property LineCount: Integer read GetLineCount;
  end;

  TRecorderFrequencyResponseFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create; reintroduce;
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  end;

procedure RegisterRecorderFrequencyResponseFactory(AFactory: TRecorderComponentFactory);
function RecorderResolveFrequencyResponseValueTag(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderFrequencyResponseComponent): TRecorderTag;
function RecorderResolveFrequencyResponseXTag(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderFrequencyResponseComponent; AValueTag: TRecorderTag): TRecorderTag;
function RecorderResolveFrequencyResponseLineValueTag(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderFrequencyResponseLine): TRecorderTag;
function RecorderResolveFrequencyResponseLineXTag(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderFrequencyResponseLine; AValueTag: TRecorderTag): TRecorderTag;
function RecorderResolveFrequencyResponseBinding(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderFrequencyResponseLine): TRecorderFrequencyResponseBinding;

implementation

uses
  StrUtils, uRecorderFrequencyBands;

{ Создаёт ось с начальными параметрами модели. }
constructor TRecorderFrequencyResponseAxis.Create;
begin
  Name := 'Ось 1'; MinValue := 0; MaxValue := 10; Logarithmic := False;
end;

{ Копирует имя и настройки оси из ASource. }
procedure TRecorderFrequencyResponseAxis.Assign(
  ASource: TRecorderFrequencyResponseAxis);
begin
  Name := ASource.Name; MinValue := ASource.MinValue;
  MaxValue := ASource.MaxValue; Logarithmic := ASource.Logarithmic;
  Kind := ASource.Kind;
end;

{ Создаёт строку с начальными настройками отображения и режима частоты. }
constructor TRecorderFrequencyResponseLine.Create;
begin
  Name := 'Линия'; AxisName := 'Ось 1'; Kind := frkAmplitude;
  BufferSize := 1024; FrequencyStepHz := 1; MergeMode := frmmReplace;
  Color := $00FF0000; Width := 2; DrawLine := True; DrawPoints := True;
end;

{ Копирует параметры и привязки строки из ASource. }
procedure TRecorderFrequencyResponseLine.Assign(
  ASource: TRecorderFrequencyResponseLine);
begin
  Name := ASource.Name; AxisName := ASource.AxisName;
  SourceTagName := ASource.SourceTagName; SourceTagId := ASource.SourceTagId;
  ValueTagName := ASource.ValueTagName; ValueTagId := ASource.ValueTagId;
  FrequencyTagName := ASource.FrequencyTagName;
  FrequencyTagId := ASource.FrequencyTagId; Kind := ASource.Kind;
  FrequencyMode := ASource.FrequencyMode;
  BufferSize := ASource.BufferSize; UniformX := ASource.UniformX;
  FrequencyStepHz := ASource.FrequencyStepHz; MergeMode := ASource.MergeMode;
  Color := ASource.Color; Width := ASource.Width;
  DrawLine := ASource.DrawLine; DrawPoints := ASource.DrawPoints;
end;

{ Сохраняет ID и имя исходного тега; nil очищает привязку. }
procedure TRecorderFrequencyResponseLine.SetSourceTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin SourceTagId := 0; SourceTagName := ''; end
  else begin SourceTagId := ATag.Id; SourceTagName := ATag.Name; end;
end;

{ Сохраняет ID и имя тега Y; nil очищает привязку. }
procedure TRecorderFrequencyResponseLine.SetValueTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin ValueTagId := 0; ValueTagName := ''; end
  else begin ValueTagId := ATag.Id; ValueTagName := ATag.Name; end;
end;

{ Сохраняет ID и имя тега X; nil очищает привязку. }
procedure TRecorderFrequencyResponseLine.SetFrequencyTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin FrequencyTagId := 0; FrequencyTagName := ''; end
  else begin FrequencyTagId := ATag.Id; FrequencyTagName := ATag.Name; end;
end;

{ Извлекает свойство AName из строки свойств с разделителями ; или ,. }
function PropertyValue(const AProperties, AName: string): string;
var
  lText: string;
  lItems: TStringList;
  I, lPos: Integer;
begin
  Result := '';
  lText := StringReplace(AProperties, ';', LineEnding, [rfReplaceAll]);
  lText := StringReplace(lText, ',', LineEnding, [rfReplaceAll]);
  lItems := TStringList.Create;
  try
    lItems.Text := lText;
    for I := 0 to lItems.Count - 1 do
    begin
      lPos := Pos('=', lItems[I]);
      if (lPos > 0) and SameText(Trim(Copy(lItems[I], 1, lPos - 1)), AName) then
        Exit(Trim(Copy(lItems[I], lPos + 1, MaxInt)));
    end;
  finally
    lItems.Free;
  end;
end;

{ Возвращает значение AName из текстовой конфигурации алгоритма. }
function ConfigValue(const AConfig, AName: string): string;
var
  lValues: TStringList;
begin
  lValues := TStringList.Create;
  try
    lValues.Text := AConfig;
    Result := lValues.Values[AName];
  finally
    lValues.Free;
  end;
end;

{ Сопоставляет ссылку сначала по ненулевому ID, иначе по имени. }
function SameTagRef(ATag: TRecorderTag; const AIdText, AName: string): Boolean;
var
  lId: TRecorderTagId;
begin
  Result := False;
  if ATag = nil then Exit;
  lId := StrToQWordDef(AIdText, 0);
  if lId <> 0 then Exit(lId = ATag.Id);
  Result := (AName <> '') and SameText(AName, ATag.Name);
end;

{ Ищет выход алгоритма ATypeName, связанного с AInput в слоте ABindingIndex; возвращает его конфигурацию через AConfig. }
function FindAlgorithmOutput(ARegistry: TRecorderTagRegistry;
  const ATypeName: string; AInput: TRecorderTag; ABindingIndex: Integer;
  out AConfig: string): TRecorderTag;
var
  I: Integer;
  lProps, lName: string;
begin
  Result := nil;
  AConfig := '';
  if (ARegistry = nil) or (AInput = nil) then Exit;
  for I := 0 to ARegistry.AlgorithmConfigs.Count - 1 do
    if SameText(ConfigValue(ARegistry.AlgorithmConfigs[I], 'Type'), ATypeName) and
      SameTagRef(AInput,
        ConfigValue(ARegistry.AlgorithmConfigs[I], Format('Binding.%d.TagId', [ABindingIndex])),
        ConfigValue(ARegistry.AlgorithmConfigs[I], Format('Binding.%d.TagName', [ABindingIndex]))) then
    begin
      AConfig := ARegistry.AlgorithmConfigs[I];
      lProps := ConfigValue(AConfig, 'Properties');
      lName := PropertyValue(lProps, 'OutputTag');
      if lName <> '' then Result := ARegistry.FindByName(lName);
      if Result <> nil then Exit;
    end;
end;

{ Ищет тег ASuffix в том же источнике спектра и родительском адресе, что и AValueTag. }
function FindSpectrumSibling(ARegistry: TRecorderTagRegistry; AValueTag: TRecorderTag;
  const ASuffix: string): TRecorderTag;
var
  I, lSlash: Integer;
  lAddress: string;
begin
  Result := nil;
  if (ARegistry = nil) or (AValueTag = nil) or
    (not StartsText('spectrum:', AValueTag.SourceId)) then Exit;
  lSlash := LastDelimiter('/', AValueTag.Address);
  if lSlash <= 0 then Exit;
  lAddress := Copy(AValueTag.Address, 1, lSlash) + ASuffix;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, AValueTag.SourceId) and
      SameText(ARegistry.Tags[I].Address, lAddress) then
      Exit(ARegistry.Tags[I]);
end;

{ Разрешает тег Y: сначала явная привязка компонента, затем вывод алгоритма или спектральный тег по виду результата. }
function RecorderResolveFrequencyResponseValueTag(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderFrequencyResponseComponent): TRecorderTag;
var
  I: Integer;
  lSource, lTag: TRecorderTag;
  lConfig: string;
  lWantedSuffix: string;
begin
  Result := nil;
  if (ARegistry = nil) or (AComponent = nil) then Exit;
  Result := AComponent.ResolveValueTag(ARegistry);
  if Result <> nil then Exit;
  lSource := AComponent.ResolveSourceTag(ARegistry);
  if lSource = nil then Exit;
  if AComponent.Kind = frkPhase then
  begin
    Result := FindAlgorithmOutput(ARegistry, 'Phase', lSource, 0, lConfig);
    Exit;
  end;
  if AComponent.Kind = frkTransfer then
    lWantedSuffix := '/frf'
  else
    lWantedSuffix := '/rms';
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, 'spectrum:' + lSource.Name) and
      EndsText(lWantedSuffix, lTag.Address) then Exit(lTag);
  end;
end;

{ Разрешает тег X: явная частота, спектральный сосед, затем частотный выход расчёта фазы/тахо. }
function RecorderResolveFrequencyResponseXTag(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderFrequencyResponseComponent; AValueTag: TRecorderTag): TRecorderTag;
var
  lPhaseConfig, lTachoConfig: string;
  lReference: TRecorderTag;
begin
  Result := nil;
  if (ARegistry = nil) or (AComponent = nil) then Exit;
  Result := AComponent.ResolveFrequencyTag(ARegistry);
  if Result <> nil then Exit;
  Result := FindSpectrumSibling(ARegistry, AValueTag, 'f1');
  if Result <> nil then Exit;
  if AComponent.Kind = frkPhase then
  begin
    FindAlgorithmOutput(ARegistry, 'Phase', AComponent.ResolveSourceTag(ARegistry),
      0, lPhaseConfig);
    if lPhaseConfig <> '' then
    begin
      lReference := ARegistry.FindById(StrToQWordDef(
        ConfigValue(lPhaseConfig, 'Binding.1.TagId'), 0));
      if lReference = nil then
        lReference := ARegistry.FindByName(ConfigValue(lPhaseConfig,
          'Binding.1.TagName'));
      Result := FindAlgorithmOutput(ARegistry, 'Tacho', lReference, 0,
        lTachoConfig);
      if Result <> nil then Exit;
    end;
  end;
end;

{ Переносит поля привязок и Kind строки во временную модель для общих функций разрешения. }
procedure CopyLineToResolver(ALine: TRecorderFrequencyResponseLine;
  AComponent: TRecorderFrequencyResponseComponent);
begin
  AComponent.SourceTagName := ALine.SourceTagName;
  AComponent.SourceTagId := ALine.SourceTagId;
  AComponent.ValueTagName := ALine.ValueTagName;
  AComponent.ValueTagId := ALine.ValueTagId;
  AComponent.FrequencyTagName := ALine.FrequencyTagName;
  AComponent.FrequencyTagId := ALine.FrequencyTagId;
  AComponent.Kind := ALine.Kind;
end;

{ Возвращает Y-тег строки после применения общих правил разрешения привязок. }
function RecorderResolveFrequencyResponseLineValueTag(
  ARegistry: TRecorderTagRegistry; ALine: TRecorderFrequencyResponseLine): TRecorderTag;
var lBinding: TRecorderFrequencyResponseBinding;
begin
  lBinding := RecorderResolveFrequencyResponseBinding(ARegistry, ALine);
  Result := lBinding.ValueTag;
end;

{ Возвращает X-тег строки после применения режима частоты и правил разрешения. }
function RecorderResolveFrequencyResponseLineXTag(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderFrequencyResponseLine; AValueTag: TRecorderTag): TRecorderTag;
var lBinding: TRecorderFrequencyResponseBinding;
begin
  lBinding := RecorderResolveFrequencyResponseBinding(ARegistry, ALine);
  Result := lBinding.FrequencyTag;
end;

{ Возвращает стабильный идентификатор типа компонента. }
class function TRecorderFrequencyResponseComponent.GetTypeId: string;
begin
  Result := 'FrequencyResponse';
end;

{ Создаёт модель АФЧХ с осью и одной строкой амплитуды по умолчанию. }
constructor TRecorderFrequencyResponseComponent.Create;
var
  lAxis: TRecorderFrequencyResponseAxis;
begin
  inherited Create;
  fAxes := TList.Create; fLines := TList.Create;
  fKind := frkAmplitude;
  fMinFrequencyHz := 0.0;
  fMaxFrequencyHz := 1000.0;
  fMinValue := 0.0;
  fMaxValue := 10.0;
  fBufferSize := 1024;
  fUniformX := False;
  fFrequencyStepHz := 1.0;
  fMergeMode := frmmReplace;
  fLegendVisible := True;
  lAxis := AddAxis; lAxis.Name := 'Амплитуда';
  AddLine.AxisName := lAxis.Name;
end;

{ Освобождает строки, оси и их списки. }
destructor TRecorderFrequencyResponseComponent.Destroy;
begin
  ClearLines; ClearAxes; fLines.Free; fAxes.Free;
  inherited Destroy;
end;

{ Добавляет принадлежащую компоненту ось; её имя используют строки с AxisName. }
function TRecorderFrequencyResponseComponent.AddAxis: TRecorderFrequencyResponseAxis;
begin Result := TRecorderFrequencyResponseAxis.Create; fAxes.Add(Result); end;
{ Добавляет принадлежащую компоненту строку, связанную с первой настроенной осью. }
function TRecorderFrequencyResponseComponent.AddLine: TRecorderFrequencyResponseLine;
begin Result := TRecorderFrequencyResponseLine.Create; fLines.Add(Result); end;
{ Освобождает оси; после очистки ссылки строк AxisName могут не разрешиться. }
procedure TRecorderFrequencyResponseComponent.ClearAxes;
begin while fAxes.Count > 0 do begin TObject(fAxes.Last).Free; fAxes.Delete(fAxes.Count-1); end; end;
{ Удаляет строки, сохраняя настроенные оси компонента. }
procedure TRecorderFrequencyResponseComponent.ClearLines;
begin while fLines.Count > 0 do begin TObject(fLines.Last).Free; fLines.Delete(fLines.Count-1); end; end;
{ Удаляет принадлежащую компоненте ось с нулевым индексом AIndex. }
procedure TRecorderFrequencyResponseComponent.DeleteAxis(AIndex: Integer);
begin TObject(fAxes[AIndex]).Free; fAxes.Delete(AIndex); end;
{ Удаляет принадлежащую компоненте строку с нулевым индексом AIndex. }
procedure TRecorderFrequencyResponseComponent.DeleteLine(AIndex: Integer);
begin TObject(fLines[AIndex]).Free; fLines.Delete(AIndex); end;
{ Возвращает ось компонента по нулевому индексу AIndex. }
function TRecorderFrequencyResponseComponent.GetAxis(AIndex: Integer): TRecorderFrequencyResponseAxis;
begin Result := TRecorderFrequencyResponseAxis(fAxes[AIndex]); end;
{ Возвращает число настроенных осей, а не строк отображения. }
function TRecorderFrequencyResponseComponent.GetAxisCount: Integer;
begin Result := fAxes.Count; end;
{ Возвращает строку компонента по нулевому индексу AIndex. }
function TRecorderFrequencyResponseComponent.GetLine(AIndex: Integer): TRecorderFrequencyResponseLine;
begin Result := TRecorderFrequencyResponseLine(fLines[AIndex]); end;
{ Возвращает число настроенных строк; оно может не совпадать с числом осей. }
function TRecorderFrequencyResponseComponent.GetLineCount: Integer;
begin Result := fLines.Count; end;

{ Копирует настройки компонента, затем оси и строки из ASource. }
procedure TRecorderFrequencyResponseComponent.Assign(
  ASource: TRecorderFrequencyResponseComponent);
var
  I: Integer;
begin
  if ASource = nil then Exit;
  fSourceTagName := ASource.SourceTagName; fSourceTagId := ASource.SourceTagId;
  fValueTagName := ASource.ValueTagName; fValueTagId := ASource.ValueTagId;
  fFrequencyTagName := ASource.FrequencyTagName; fFrequencyTagId := ASource.FrequencyTagId;
  fKind := ASource.Kind; fMinFrequencyHz := ASource.MinFrequencyHz;
  fMaxFrequencyHz := ASource.MaxFrequencyHz; fMinValue := ASource.MinValue;
  fMaxValue := ASource.MaxValue; fBufferSize := ASource.BufferSize;
  fUniformX := ASource.UniformX; fFrequencyStepHz := ASource.FrequencyStepHz;
  fMergeMode := ASource.MergeMode; fLegendVisible := ASource.LegendVisible;
  fLogFrequency := ASource.LogFrequency;
  ClearAxes;
  for I := 0 to ASource.AxisCount - 1 do AddAxis.Assign(ASource.Axes[I]);
  ClearLines;
  for I := 0 to ASource.LineCount - 1 do AddLine.Assign(ASource.Lines[I]);
end;

{ Обновляет привязку источника компонента и первой строки. }
procedure TRecorderFrequencyResponseComponent.SetSourceTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin fSourceTagId := 0; fSourceTagName := ''; end
  else begin fSourceTagId := ATag.Id; fSourceTagName := ATag.Name; end;
  if fLines.Count > 0 then Lines[0].SetSourceTag(ATag);
end;

{ Обновляет привязку Y компонента и первой строки. }
procedure TRecorderFrequencyResponseComponent.SetValueTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin fValueTagId := 0; fValueTagName := ''; end
  else begin fValueTagId := ATag.Id; fValueTagName := ATag.Name; end;
  if fLines.Count > 0 then Lines[0].SetValueTag(ATag);
end;

{ Обновляет привязку X компонента и первой строки. }
procedure TRecorderFrequencyResponseComponent.SetFrequencyTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin fFrequencyTagId := 0; fFrequencyTagName := ''; end
  else begin fFrequencyTagId := ATag.Id; fFrequencyTagName := ATag.Name; end;
  if fLines.Count > 0 then Lines[0].SetFrequencyTag(ATag);
end;

{ Ищет тег сначала по ненулевому AId, а при неудаче — по AName. }
function ResolveTag(ARegistry: TRecorderTagRegistry; AId: TRecorderTagId;
  const AName: string): TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then Exit;
  if AId <> 0 then Result := ARegistry.FindById(AId);
  if (Result = nil) and (AName <> '') then Result := ARegistry.FindByName(AName);
end;

{ Находит полосу частот, соответствующую адресу спектрального тега. }
function SpectrumBand(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): TRecorderFrequencyBand;
var
  I, lSlash: Integer;
  lName: string;
begin
  Result := nil;
  if (ATag = nil) or not StartsText('spectrum:', ATag.SourceId) then Exit;
  lSlash := LastDelimiter('/', ATag.Address);
  if lSlash = 0 then Exit;
  lName := Copy(ATag.Address, 1, lSlash - 1);
  for I := 0 to ARegistry.FrequencyBands.BandCount - 1 do
    if SameText(ARegistry.FrequencyBands.Bands[I].Name, lName) then
      Exit(ARegistry.FrequencyBands.Bands[I]);
end;

{ Возвращает тахо-тег полосы только для формулы из одного терма с коэффициентом 1. }
function BandTacho(ARegistry: TRecorderTagRegistry;
  ABand: TRecorderFrequencyBand): TRecorderTag;
begin
  Result := nil;
  if (ABand = nil) or (ABand.Kind <> fbkFormula) or
    (ABand.TermCount <> 1) or (ABand.Terms[0].Coefficient <> 1.0) then Exit;
  Result := ARegistry.FindByName(ABand.Terms[0].TagName);
end;

{ Ищет RMS для ASource; предпочитает тег полосы, связанной с тахо. }
function FindBandRms(ARegistry: TRecorderTagRegistry;
  ASource: TRecorderTag): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if ASource = nil then Exit;
  if StartsText('spectrum:', ASource.SourceId) and
    EndsText('/rms', ASource.Address) then Exit(ASource);
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if not SameText(lTag.SourceId, 'spectrum:' + ASource.Name) or
      not EndsText('/rms', lTag.Address) then Continue;
    if Result = nil then Result := lTag;
    { Полоса слежения имеет приоритет над несвязанной абсолютной полосой RMS. }
    if BandTacho(ARegistry, SpectrumBand(ARegistry, lTag)) <> nil then
      Exit(lTag);
  end;
end;

{ Ищет частотный тег f1: сначала сосед спектра, затем тег/выход алгоритма тахо в режиме спектра. }
function FindSpectrumFrequency(ARegistry: TRecorderTagRegistry;
  ASource: TRecorderTag): TRecorderTag;
var
  I: Integer;
  lConfig, lProperties, lMode: string;
begin
  Result := FindSpectrumSibling(ARegistry, ASource, 'f1');
  if (Result <> nil) or (ASource = nil) then Exit;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, 'spectrum:' + ASource.Name) and
      EndsText('/f1', ARegistry.Tags[I].Address) then
      Exit(ARegistry.Tags[I]);
  for I := 0 to ARegistry.AlgorithmConfigs.Count - 1 do
  begin
    lConfig := ARegistry.AlgorithmConfigs[I];
    if not SameText(ConfigValue(lConfig, 'Type'), 'Tacho') or
      not SameTagRef(ASource, ConfigValue(lConfig, 'Binding.0.TagId'),
        ConfigValue(lConfig, 'Binding.0.TagName')) then Continue;
    lProperties := ConfigValue(lConfig, 'Properties');
    lMode := PropertyValue(lProperties, 'Mode');
    if lMode = '' then lMode := PropertyValue(lProperties, 'TahoType');
    if SameText(lMode, 'Spectrum') then
    begin
      Result := ARegistry.FindByName(PropertyValue(lProperties, 'OutputTag'));
      if Result <> nil then Exit;
    end;
  end;
end;

{ Выбирает источник частоты X; для автоматического режима приоритетны тахо, затем спектр, затем среднее. }
procedure ResolveFrequencyInput(ARegistry: TRecorderTagRegistry;
  AInput: TRecorderTag; var ABinding: TRecorderFrequencyResponseBinding);
var
  lDerived: TRecorderTag;
  lConfig: string;
begin
  ABinding.FrequencyTag := AInput;
  if AInput = nil then Exit;
  if not AInput.IsVector then
  begin
    ABinding.FrequencyMode := frfmLast;
    Exit;
  end;
  if ABinding.FrequencyMode in [frfmAutomatic, frfmTacho] then
  begin
    lDerived := FindAlgorithmOutput(ARegistry, 'Tacho', AInput, 0, lConfig);
    if lDerived <> nil then
    begin
      ABinding.FrequencyTag := lDerived;
      ABinding.FrequencyMode := frfmTacho;
      Exit;
    end;
  end;
  if ABinding.FrequencyMode in [frfmAutomatic, frfmSpectrum] then
  begin
    lDerived := FindSpectrumFrequency(ARegistry, AInput);
    if lDerived <> nil then
    begin
      ABinding.FrequencyTag := lDerived;
      ABinding.FrequencyMode := frfmSpectrum;
      Exit;
    end;
  end;
  if ABinding.FrequencyMode = frfmAutomatic then
    ABinding.FrequencyMode := frfmMean
  else if ABinding.FrequencyMode in [frfmSpectrum, frfmTacho] then
    ABinding.FrequencyTag := nil;
end;

{ Разрешает Y/X для строки; приоритет: явные ID/имена, связанные производные теги, эвристики по виду сигнала. }
function RecorderResolveFrequencyResponseBinding(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderFrequencyResponseLine): TRecorderFrequencyResponseBinding;
const
  CModeNames: array[TRecorderFrequencyResponseFrequencyMode] of string =
    ('Автоматически', 'Последнее значение', 'Математическое ожидание',
     'Главная гармоника спектра', 'Расчётный тахо');
var
  lSource, lInput: TRecorderTag;
  lConfig: string;
  lComponent: TRecorderFrequencyResponseComponent;
begin
  Result := Default(TRecorderFrequencyResponseBinding);
  if (ARegistry = nil) or (ALine = nil) then Exit;
  Result.FrequencyMode := ALine.FrequencyMode;
  lSource := ResolveTag(ARegistry, ALine.SourceTagId, ALine.SourceTagName);
  Result.ValueTag := ResolveTag(ARegistry, ALine.ValueTagId, ALine.ValueTagName);
  if (Result.ValueTag = nil) and (lSource <> nil) and
    ((ALine.Kind = frkAmplitude) or not lSource.IsVector) then
    Result.ValueTag := FindBandRms(ARegistry, lSource);
  if Result.ValueTag = nil then
  begin
    lComponent := TRecorderFrequencyResponseComponent.Create;
    try
      CopyLineToResolver(ALine, lComponent);
      Result.ValueTag := RecorderResolveFrequencyResponseValueTag(ARegistry, lComponent);
    finally
      lComponent.Free;
    end;
  end;
  if (Result.ValueTag = nil) and (ALine.Kind = frkAmplitude) then
  begin
    Result.ValueTag := lSource;
    Result.ValueFromSummary := (lSource <> nil) and lSource.IsVector;
  end;
  lInput := BandTacho(ARegistry, SpectrumBand(ARegistry, Result.ValueTag));
  Result.FrequencyLocked := lInput <> nil;
  if lInput <> nil then
    Result.FrequencyMode := frfmAutomatic
  else
    lInput := ResolveTag(ARegistry, ALine.FrequencyTagId, ALine.FrequencyTagName);
  if lInput = nil then
    lInput := FindSpectrumSibling(ARegistry, Result.ValueTag, 'f1');
  if (lInput = nil) and (ALine.FrequencyTagId = 0) and
    (ALine.FrequencyTagName = '') then
  begin
    if FindAlgorithmOutput(ARegistry, 'Tacho', lSource, 0, lConfig) <> nil then
      lInput := lSource
    else
      lInput := FindSpectrumFrequency(ARegistry, lSource);
  end;
  if (lInput = nil) and (ALine.Kind = frkPhase) then
  begin
    lComponent := TRecorderFrequencyResponseComponent.Create;
    try
      CopyLineToResolver(ALine, lComponent);
      lInput := RecorderResolveFrequencyResponseXTag(ARegistry, lComponent,
        Result.ValueTag);
    finally
      lComponent.Free;
    end;
  end;
  ResolveFrequencyInput(ARegistry, lInput, Result);
  if Result.ValueTag <> nil then Result.Hint := 'Y: ' + Result.ValueTag.Name;
  if Result.Hint <> '' then Result.Hint := Result.Hint + '; ';
  if Result.FrequencyTag <> nil then
    Result.Hint := Result.Hint + 'X: ' + CModeNames[Result.FrequencyMode] +
      ' — ' + Result.FrequencyTag.Name
  else
    Result.Hint := Result.Hint + 'выберите тег частоты с готовым расчётом';
  if Result.FrequencyLocked then
    Result.Hint := Result.Hint + ' (из настроек полосового СКЗ)';
end;

{ Разрешает сохранённую привязку источника и обновляет ID/имя модели при успехе. }
function TRecorderFrequencyResponseComponent.ResolveSourceTag(
  ARegistry: TRecorderTagRegistry): TRecorderTag;
begin Result := ResolveTag(ARegistry, fSourceTagId, fSourceTagName); if Result <> nil then SetSourceTag(Result); end;
{ Разрешает сохранённую привязку Y и обновляет ID/имя модели при успехе. }
function TRecorderFrequencyResponseComponent.ResolveValueTag(
  ARegistry: TRecorderTagRegistry): TRecorderTag;
begin Result := ResolveTag(ARegistry, fValueTagId, fValueTagName); if Result <> nil then SetValueTag(Result); end;
{ Разрешает сохранённую привязку X и обновляет ID/имя модели при успехе. }
function TRecorderFrequencyResponseComponent.ResolveFrequencyTag(
  ARegistry: TRecorderTagRegistry): TRecorderTag;
begin Result := ResolveTag(ARegistry, fFrequencyTagId, fFrequencyTagName); if Result <> nil then SetFrequencyTag(Result); end;

{ Создаёт фабрику АФЧХ с параметрами плитки и палитры. }
constructor TRecorderFrequencyResponseFactory.Create;
begin
  inherited Create(TRecorderFrequencyResponseComponent.TypeId, 'АФЧХ', TRecorderFrequencyResponseComponent, 420, 300, False);
  ConfigurePalette('АФЧХ', 'Добавить АЧХ, фазу или передаточную характеристику','frequency-response', 45, rppGroup, CRecorderPaletteGroupCharts);
end;

{ Задаёт имя новой модели и источник: SelectedTag имеет приоритет над DefaultTag. }
procedure TRecorderFrequencyResponseFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lTag: TRecorderTag;
begin
  AComponent.Name := Format('FrequencyResponse%d', [AContext.ComponentNo]);
  lTag := AContext.SelectedTag;
  if lTag = nil then lTag := AContext.DefaultTag;
  TRecorderFrequencyResponseComponent(AComponent).SetSourceTag(lTag);
end;

{ Регистрирует фабрику АФЧХ, если компонент ещё не добавлен в реестр. }
procedure RegisterRecorderFrequencyResponseFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorderFrequencyResponseComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorderFrequencyResponseFactory.Create);
end;

end.
