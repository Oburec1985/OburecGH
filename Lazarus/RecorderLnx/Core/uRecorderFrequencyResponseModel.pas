unit uRecorderFrequencyResponseModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderFormModel, uRecorderTags,
  uRecorderFrequencyResponse;

type
  TRecorderFrequencyResponseKind = (frkAmplitude, frkPhase, frkTransfer);

  TRecorderFrequencyResponseAxis = class
  public
    Name: string;
    MinValue, MaxValue: Double;
    Logarithmic: Boolean;
    constructor Create;
    procedure Assign(ASource: TRecorderFrequencyResponseAxis);
  end;

  TRecorderFrequencyResponseLine = class
  public
    Name, AxisName: string;
    SourceTagName, ValueTagName, FrequencyTagName: string;
    SourceTagId, ValueTagId, FrequencyTagId: TRecorderTagId;
    Kind: TRecorderFrequencyResponseKind;
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
    property Axes[AIndex: Integer]: TRecorderFrequencyResponseAxis read GetAxis;
    property AxisCount: Integer read GetAxisCount;
    property Lines[AIndex: Integer]: TRecorderFrequencyResponseLine read GetLine;
    property LineCount: Integer read GetLineCount;
  end;

  TRecorderFrequencyResponseFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create;
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

implementation

uses
  StrUtils;

constructor TRecorderFrequencyResponseAxis.Create;
begin
  Name := 'Ось 1'; MinValue := 0; MaxValue := 10; Logarithmic := False;
end;

procedure TRecorderFrequencyResponseAxis.Assign(
  ASource: TRecorderFrequencyResponseAxis);
begin
  Name := ASource.Name; MinValue := ASource.MinValue;
  MaxValue := ASource.MaxValue; Logarithmic := ASource.Logarithmic;
end;

constructor TRecorderFrequencyResponseLine.Create;
begin
  Name := 'Линия'; AxisName := 'Ось 1'; Kind := frkAmplitude;
  BufferSize := 1024; FrequencyStepHz := 1; MergeMode := frmmReplace;
  Color := $00FF0000; Width := 2; DrawLine := True; DrawPoints := True;
end;

procedure TRecorderFrequencyResponseLine.Assign(
  ASource: TRecorderFrequencyResponseLine);
begin
  Name := ASource.Name; AxisName := ASource.AxisName;
  SourceTagName := ASource.SourceTagName; SourceTagId := ASource.SourceTagId;
  ValueTagName := ASource.ValueTagName; ValueTagId := ASource.ValueTagId;
  FrequencyTagName := ASource.FrequencyTagName;
  FrequencyTagId := ASource.FrequencyTagId; Kind := ASource.Kind;
  BufferSize := ASource.BufferSize; UniformX := ASource.UniformX;
  FrequencyStepHz := ASource.FrequencyStepHz; MergeMode := ASource.MergeMode;
  Color := ASource.Color; Width := ASource.Width;
  DrawLine := ASource.DrawLine; DrawPoints := ASource.DrawPoints;
end;

procedure TRecorderFrequencyResponseLine.SetSourceTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin SourceTagId := 0; SourceTagName := ''; end
  else begin SourceTagId := ATag.Id; SourceTagName := ATag.Name; end;
end;

procedure TRecorderFrequencyResponseLine.SetValueTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin ValueTagId := 0; ValueTagName := ''; end
  else begin ValueTagId := ATag.Id; ValueTagName := ATag.Name; end;
end;

procedure TRecorderFrequencyResponseLine.SetFrequencyTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin FrequencyTagId := 0; FrequencyTagName := ''; end
  else begin FrequencyTagId := ATag.Id; FrequencyTagName := ATag.Name; end;
end;

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

function SameTagRef(ATag: TRecorderTag; const AIdText, AName: string): Boolean;
begin
  Result := (ATag <> nil) and
    (((AIdText <> '') and (StrToQWordDef(AIdText, 0) = ATag.Id)) or
     ((AName <> '') and SameText(AName, ATag.Name)));
end;

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
      Exit;
    end;
end;

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

function RecorderResolveFrequencyResponseXTag(ARegistry: TRecorderTagRegistry;
  AComponent: TRecorderFrequencyResponseComponent; AValueTag: TRecorderTag): TRecorderTag;
var
  I: Integer;
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
  for I := 0 to ARegistry.AlgorithmConfigs.Count - 1 do
    if SameText(ConfigValue(ARegistry.AlgorithmConfigs[I], 'Type'), 'Tacho') then
    begin
      Result := ARegistry.FindByName(PropertyValue(
        ConfigValue(ARegistry.AlgorithmConfigs[I], 'Properties'), 'OutputTag'));
      if Result <> nil then Exit;
    end;
end;

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

function RecorderResolveFrequencyResponseLineValueTag(
  ARegistry: TRecorderTagRegistry; ALine: TRecorderFrequencyResponseLine): TRecorderTag;
var lComponent: TRecorderFrequencyResponseComponent;
begin
  lComponent := TRecorderFrequencyResponseComponent.Create;
  try CopyLineToResolver(ALine, lComponent);
    Result := RecorderResolveFrequencyResponseValueTag(ARegistry, lComponent);
  finally lComponent.Free; end;
end;

function RecorderResolveFrequencyResponseLineXTag(ARegistry: TRecorderTagRegistry;
  ALine: TRecorderFrequencyResponseLine; AValueTag: TRecorderTag): TRecorderTag;
var lComponent: TRecorderFrequencyResponseComponent;
begin
  lComponent := TRecorderFrequencyResponseComponent.Create;
  try CopyLineToResolver(ALine, lComponent);
    Result := RecorderResolveFrequencyResponseXTag(ARegistry, lComponent, AValueTag);
  finally lComponent.Free; end;
end;

class function TRecorderFrequencyResponseComponent.GetTypeId: string;
begin
  Result := 'FrequencyResponse';
end;

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

destructor TRecorderFrequencyResponseComponent.Destroy;
begin
  ClearLines; ClearAxes; fLines.Free; fAxes.Free;
  inherited Destroy;
end;

function TRecorderFrequencyResponseComponent.AddAxis: TRecorderFrequencyResponseAxis;
begin Result := TRecorderFrequencyResponseAxis.Create; fAxes.Add(Result); end;
function TRecorderFrequencyResponseComponent.AddLine: TRecorderFrequencyResponseLine;
begin Result := TRecorderFrequencyResponseLine.Create; fLines.Add(Result); end;
procedure TRecorderFrequencyResponseComponent.ClearAxes;
begin while fAxes.Count > 0 do begin TObject(fAxes.Last).Free; fAxes.Delete(fAxes.Count-1); end; end;
procedure TRecorderFrequencyResponseComponent.ClearLines;
begin while fLines.Count > 0 do begin TObject(fLines.Last).Free; fLines.Delete(fLines.Count-1); end; end;
procedure TRecorderFrequencyResponseComponent.DeleteAxis(AIndex: Integer);
begin TObject(fAxes[AIndex]).Free; fAxes.Delete(AIndex); end;
procedure TRecorderFrequencyResponseComponent.DeleteLine(AIndex: Integer);
begin TObject(fLines[AIndex]).Free; fLines.Delete(AIndex); end;
function TRecorderFrequencyResponseComponent.GetAxis(AIndex: Integer): TRecorderFrequencyResponseAxis;
begin Result := TRecorderFrequencyResponseAxis(fAxes[AIndex]); end;
function TRecorderFrequencyResponseComponent.GetAxisCount: Integer;
begin Result := fAxes.Count; end;
function TRecorderFrequencyResponseComponent.GetLine(AIndex: Integer): TRecorderFrequencyResponseLine;
begin Result := TRecorderFrequencyResponseLine(fLines[AIndex]); end;
function TRecorderFrequencyResponseComponent.GetLineCount: Integer;
begin Result := fLines.Count; end;

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
  ClearAxes;
  for I := 0 to ASource.AxisCount - 1 do AddAxis.Assign(ASource.Axes[I]);
  ClearLines;
  for I := 0 to ASource.LineCount - 1 do AddLine.Assign(ASource.Lines[I]);
end;

procedure TRecorderFrequencyResponseComponent.SetSourceTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin fSourceTagId := 0; fSourceTagName := ''; end
  else begin fSourceTagId := ATag.Id; fSourceTagName := ATag.Name; end;
  if fLines.Count > 0 then Lines[0].SetSourceTag(ATag);
end;

procedure TRecorderFrequencyResponseComponent.SetValueTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin fValueTagId := 0; fValueTagName := ''; end
  else begin fValueTagId := ATag.Id; fValueTagName := ATag.Name; end;
  if fLines.Count > 0 then Lines[0].SetValueTag(ATag);
end;

procedure TRecorderFrequencyResponseComponent.SetFrequencyTag(ATag: TRecorderTag);
begin
  if ATag = nil then begin fFrequencyTagId := 0; fFrequencyTagName := ''; end
  else begin fFrequencyTagId := ATag.Id; fFrequencyTagName := ATag.Name; end;
  if fLines.Count > 0 then Lines[0].SetFrequencyTag(ATag);
end;

function ResolveTag(ARegistry: TRecorderTagRegistry; AId: TRecorderTagId;
  const AName: string): TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then Exit;
  if AId <> 0 then Result := ARegistry.FindById(AId);
  if (Result = nil) and (AName <> '') then Result := ARegistry.FindByName(AName);
end;

function TRecorderFrequencyResponseComponent.ResolveSourceTag(
  ARegistry: TRecorderTagRegistry): TRecorderTag;
begin Result := ResolveTag(ARegistry, fSourceTagId, fSourceTagName); if Result <> nil then SetSourceTag(Result); end;
function TRecorderFrequencyResponseComponent.ResolveValueTag(
  ARegistry: TRecorderTagRegistry): TRecorderTag;
begin Result := ResolveTag(ARegistry, fValueTagId, fValueTagName); if Result <> nil then SetValueTag(Result); end;
function TRecorderFrequencyResponseComponent.ResolveFrequencyTag(
  ARegistry: TRecorderTagRegistry): TRecorderTag;
begin Result := ResolveTag(ARegistry, fFrequencyTagId, fFrequencyTagName); if Result <> nil then SetFrequencyTag(Result); end;

constructor TRecorderFrequencyResponseFactory.Create;
begin
  inherited Create(TRecorderFrequencyResponseComponent.TypeId, 'АФЧХ',
    TRecorderFrequencyResponseComponent, 420, 300, False);
  ConfigurePalette('АФЧХ', 'Добавить АЧХ, фазу или передаточную характеристику',
    'frequency-response', 45, rppGroup, CRecorderPaletteGroupCharts);
end;

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

procedure RegisterRecorderFrequencyResponseFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorderFrequencyResponseComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorderFrequencyResponseFactory.Create);
end;

end.
