unit uOscModel;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Plugin-owned Oscillogram configuration, edited on drafts and persisted as
  versioned UTF-8 JSON. No RecorderLnx domain, tag objects, UI or LCL types may
  enter this module. Tag IDs/names are values resolved through SDK services.
  Collections are owned; Clone and Assign copy every nested object. }

interface

uses Classes, SysUtils, fpjson;

type
  TOscBindingMode = (obRelativeSelectedTag, obAbsoluteTag);
  TOscSignalEdge = (oeRising, oeFalling);
  TOscEstimate = (ovMean, ovRmsValue, ovRmsDeviation, ovPeak, ovPeakToPeak,
    ovMinimum, ovMaximum, ovPeakToPeakByRmsDeviation, ovLastValue);

  TOscAxis = class
  public
    Name: string;
    Color: LongInt;
    RangeMin, RangeMax, YScale, YOffset: Double;
    constructor Create;
    procedure Assign(ASource: TOscAxis);
  end;

  TOscLine = class
  public
    Name, TagName: string;
    TagId: Int64;
    EstimateKind: TOscEstimate;
    AxisIndex, Width: Integer;
    Color: LongInt;
    Visible: Boolean;
    constructor Create;
    procedure Assign(ASource: TOscLine);
  end;

  TOscModel = class
  private
    fAxes, fLines: TList;
    fYScale, fYOffset, fPreRoll: Double;
    function GetAxis(AIndex: Integer): TOscAxis;
    function GetLine(AIndex: Integer): TOscLine;
    function GetAxisCount: Integer;
    function GetLineCount: Integer;
    function GetYScale: Double;
    function GetYOffset: Double;
    procedure SetYScale(AValue: Double);
    procedure SetYOffset(AValue: Double);
    procedure SetPreRoll(AValue: Double);
    procedure ReadJson(AObject: TJSONObject);
    function ToJson: TJSONObject;
  public
    BindingMode: TOscBindingMode;
    DisplayFormat: string;
    ClosedInput: Boolean;
    AutoRangeEnabled: Boolean;
    XCursorEnabled: Boolean;
    XCursorCount: Integer;
    LegendVisible: Boolean;
    LevelCursorVisible: Boolean;
    PrimaryAxisIndex: Integer;
    TagOffset: Integer;
    XScale: Double;
    TriggerTagName: string;
    TriggerEnabled: Boolean;
    TriggerEdge: TOscSignalEdge;
    TriggerLevel: Double;
    TagName: string;
    TagId: Int64;
    constructor Create;
    destructor Destroy; override;
    function AddAxis: TOscAxis;
    function AddLine: TOscLine;
    procedure ClearAxes;
    procedure ClearLines;
    procedure DeleteLine(AIndex: Integer);
    procedure Assign(ASource: TOscModel);
    function Clone: TOscModel;
    function SaveUtf8: UTF8String;
    { Failed loads leave this instance unchanged; unknown versions are rejected. }
    function LoadUtf8(const AData: UTF8String; out AError: string): Boolean;
    property Axes[AIndex: Integer]: TOscAxis read GetAxis;
    property Lines[AIndex: Integer]: TOscLine read GetLine;
    property AxisCount: Integer read GetAxisCount;
    property LineCount: Integer read GetLineCount;
    property YScale: Double read GetYScale write SetYScale;
    property YOffset: Double read GetYOffset write SetYOffset;
    property TriggerPreRollPercent: Double read fPreRoll write SetPreRoll;
  end;

implementation

uses Math, jsonparser;

constructor TOscAxis.Create;
begin
  inherited Create;
  Name := 'Y'; Color := $00808080; RangeMin := 0; RangeMax := 1;
  YScale := 1; YOffset := 0;
end;

procedure TOscAxis.Assign(ASource: TOscAxis);
begin
  Name := ASource.Name; Color := ASource.Color;
  RangeMin := ASource.RangeMin; RangeMax := ASource.RangeMax;
  YScale := ASource.YScale; YOffset := ASource.YOffset;
end;

constructor TOscLine.Create;
begin
  inherited Create;
  Name := 'Line'; Color := $00FF0000; Width := 1; Visible := True;
end;

procedure TOscLine.Assign(ASource: TOscLine);
begin
  Name := ASource.Name; TagName := ASource.TagName; TagId := ASource.TagId;
  EstimateKind := ASource.EstimateKind; AxisIndex := ASource.AxisIndex;
  Width := ASource.Width; Color := ASource.Color; Visible := ASource.Visible;
end;

constructor TOscModel.Create;
begin
  inherited Create;
  fAxes := TList.Create; fLines := TList.Create;
  BindingMode := obRelativeSelectedTag;
  DisplayFormat := '4';
  ClosedInput := False;
  AutoRangeEnabled := False;
  XCursorEnabled := False;
  XCursorCount := 1;
  LegendVisible := True;
  LevelCursorVisible := False;
  PrimaryAxisIndex := 0;
  TagOffset := 0;
  XScale := 0;
  TriggerTagName := '';
  TriggerEnabled := False;
  TriggerEdge := oeRising;
  TriggerLevel := 0;
  TagName := '';
  TagId := 0;
  fYScale := 1; fYOffset := 0; fPreRoll := 25;
  AddAxis;
end;

destructor TOscModel.Destroy;
begin
  ClearLines; ClearAxes; fLines.Free; fAxes.Free;
  inherited Destroy;
end;

function TOscModel.GetAxis(AIndex: Integer): TOscAxis;
begin Result := TOscAxis(fAxes[AIndex]); end;
function TOscModel.GetLine(AIndex: Integer): TOscLine;
begin Result := TOscLine(fLines[AIndex]); end;
function TOscModel.GetAxisCount: Integer;
begin Result := fAxes.Count; end;
function TOscModel.GetLineCount: Integer;
begin Result := fLines.Count; end;
function TOscModel.GetYScale: Double;
begin if AxisCount > 0 then Result := Axes[0].YScale else Result := fYScale; end;
function TOscModel.GetYOffset: Double;
begin if AxisCount > 0 then Result := Axes[0].YOffset else Result := fYOffset; end;
procedure TOscModel.SetYScale(AValue: Double);
begin fYScale := AValue; if AxisCount > 0 then Axes[0].YScale := AValue; end;
procedure TOscModel.SetYOffset(AValue: Double);
begin fYOffset := AValue; if AxisCount > 0 then Axes[0].YOffset := AValue; end;
procedure TOscModel.SetPreRoll(AValue: Double);
begin fPreRoll := EnsureRange(AValue, 0.0, 50.0); end;

function TOscModel.AddAxis: TOscAxis;
begin
  Result := TOscAxis.Create; Result.Name := 'Y' + IntToStr(AxisCount + 1);
  fAxes.Add(Result);
end;

function TOscModel.AddLine: TOscLine;
const
  Colors: array[0..17] of LongInt = ($00FF0000,$00228B22,$000000FF,$00168EDA,
    $00C50040,$00808000,$009E544C,$00C710E2,$00E8BA7D,$007AE0C4,$00577A3B,
    $002E1C85,$009640E8,$005E701A,$005440CC,$002100E3,$00A67A00,$001FA89E);
  Names: array[0..17] of string = ('Синий','Травяной зелёный','Красный',
    'Оранжевый','Пурпурный','Бирюзовый','Фиолетовый','Сиреневый','Aero',
    'Alien Armpit','Amazon','Antique Ruby','Barbie Pink','Bittersweet',
    'Brick Red','Cadmium Red','Cerulean','Citron');
var lIndex: Integer;
begin
  lIndex := (LineCount + 1) mod 18;
  Result := TOscLine.Create; Result.Color := Colors[lIndex];
  Result.Name := Names[lIndex]; fLines.Add(Result);
end;

procedure TOscModel.ClearAxes;
var lIndex: Integer;
begin
  for lIndex := AxisCount - 1 downto 0 do Axes[lIndex].Free;
  fAxes.Clear;
end;

procedure TOscModel.ClearLines;
var lIndex: Integer;
begin
  for lIndex := LineCount - 1 downto 0 do Lines[lIndex].Free;
  fLines.Clear;
end;

procedure TOscModel.DeleteLine(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= LineCount) then Exit;
  Lines[AIndex].Free; fLines.Delete(AIndex);
end;

procedure TOscModel.Assign(ASource: TOscModel);
var lIndex: Integer;
begin
  if (ASource = nil) or (ASource = Self) then Exit;
  BindingMode := ASource.BindingMode;
  DisplayFormat := ASource.DisplayFormat;
  ClosedInput := ASource.ClosedInput;
  AutoRangeEnabled := ASource.AutoRangeEnabled;
  XCursorEnabled := ASource.XCursorEnabled;
  XCursorCount := ASource.XCursorCount;
  LegendVisible := ASource.LegendVisible;
  LevelCursorVisible := ASource.LevelCursorVisible;
  PrimaryAxisIndex := ASource.PrimaryAxisIndex;
  TagOffset := ASource.TagOffset;
  XScale := ASource.XScale;
  TriggerTagName := ASource.TriggerTagName;
  TriggerEnabled := ASource.TriggerEnabled;
  TriggerEdge := ASource.TriggerEdge;
  TriggerLevel := ASource.TriggerLevel;
  TagName := ASource.TagName;
  TagId := ASource.TagId;
  fYScale := ASource.fYScale; fYOffset := ASource.fYOffset;
  fPreRoll := ASource.fPreRoll;
  ClearAxes;
  for lIndex := 0 to ASource.AxisCount - 1 do AddAxis.Assign(ASource.Axes[lIndex]);
  ClearLines;
  for lIndex := 0 to ASource.LineCount - 1 do AddLine.Assign(ASource.Lines[lIndex]);
end;

function TOscModel.Clone: TOscModel;
begin
  Result := TOscModel.Create;
  try Result.Assign(Self); except Result.Free; raise; end;
end;

function Required(AObject: TJSONObject; const AName: string): TJSONData;
begin
  Result := AObject.Find(AName);
  if Result = nil then raise EConvertError.Create('Missing ' + AName);
end;

function JsonString(AObject: TJSONObject; const AName: string): string;
var lData: TJSONData;
begin
  lData := Required(AObject, AName);
  if lData.JSONType <> jtString then raise EConvertError.Create('String ' + AName);
  Result := lData.AsString;
end;

function JsonBool(AObject: TJSONObject; const AName: string): Boolean;
var lData: TJSONData;
begin
  lData := Required(AObject, AName);
  if lData.JSONType <> jtBoolean then raise EConvertError.Create('Boolean ' + AName);
  Result := lData.AsBoolean;
end;

function JsonNumber(AObject: TJSONObject; const AName: string): Double;
var lData: TJSONData;
begin
  lData := Required(AObject, AName);
  if lData.JSONType <> jtNumber then raise EConvertError.Create('Number ' + AName);
  Result := lData.AsFloat;
  if IsNan(Result) or IsInfinite(Result) then raise EConvertError.Create('Finite ' + AName);
end;

function JsonInt(AObject: TJSONObject; const AName: string): Int64;
var lData: TJSONData;
begin
  lData := Required(AObject, AName);
  if (lData.JSONType <> jtNumber) or not TryStrToInt64(lData.AsJSON, Result) then
    raise EConvertError.Create('Integer ' + AName);
end;

function JsonOrdinal(AObject: TJSONObject; const AName: string; AMax: Integer): Integer;
var lValue: Int64;
begin
  lValue := JsonInt(AObject, AName);
  if (lValue < 0) or (lValue > AMax) then raise EConvertError.Create('Ordinal ' + AName);
  Result := lValue;
end;

function JsonInt32(AObject: TJSONObject; const AName: string): LongInt;
var lValue: Int64;
begin
  lValue := JsonInt(AObject, AName);
  if (lValue < Low(LongInt)) or (lValue > High(LongInt)) then
    raise EConvertError.Create('32-bit integer ' + AName);
  Result := lValue;
end;

function JsonObject(AData: TJSONData): TJSONObject;
begin
  if AData.JSONType <> jtObject then raise EConvertError.Create('Object required');
  Result := TJSONObject(AData);
end;

function JsonArray(AObject: TJSONObject; const AName: string): TJSONArray;
var lData: TJSONData;
begin
  lData := Required(AObject, AName);
  if lData.JSONType <> jtArray then raise EConvertError.Create('Array ' + AName);
  Result := TJSONArray(lData);
  if Result.Count > 4096 then raise EConvertError.Create('Collection too large');
end;

function TOscModel.ToJson: TJSONObject;
var lAxes, lLines: TJSONArray; lItem: TJSONObject; lIndex: Integer;
begin
  Result := TJSONObject.Create;
  try
    Result.Add('Version', 1);
    Result.Add('BindingMode', Ord(BindingMode));
    Result.Add('DisplayFormat', DisplayFormat);
    Result.Add('ClosedInput', ClosedInput);
    Result.Add('AutoRangeEnabled', AutoRangeEnabled);
    Result.Add('XCursorEnabled', XCursorEnabled);
    Result.Add('XCursorCount', XCursorCount);
    Result.Add('LegendVisible', LegendVisible);
    Result.Add('LevelCursorVisible', LevelCursorVisible);
    Result.Add('PrimaryAxisIndex', PrimaryAxisIndex);
    Result.Add('TagOffset', TagOffset);
    Result.Add('XScale', XScale);
    Result.Add('TriggerTagName', TriggerTagName);
    Result.Add('TriggerEnabled', TriggerEnabled);
    Result.Add('TriggerEdge', Ord(TriggerEdge));
    Result.Add('TriggerLevel', TriggerLevel);
    Result.Add('TagName', TagName);
    Result.Add('TagId', TagId);
    Result.Add('YScale', fYScale); Result.Add('YOffset', fYOffset);
    Result.Add('TriggerPreRollPercent', fPreRoll);
    lAxes := TJSONArray.Create; Result.Add('Axes', lAxes);
    for lIndex := 0 to AxisCount - 1 do
    begin
      lItem := TJSONObject.Create; lAxes.Add(lItem);
      with Axes[lIndex] do
      begin
        lItem.Add('Name', Name); lItem.Add('Color', Color);
        lItem.Add('RangeMin', RangeMin); lItem.Add('RangeMax', RangeMax);
        lItem.Add('YScale', YScale); lItem.Add('YOffset', YOffset);
      end;
    end;
    lLines := TJSONArray.Create; Result.Add('Lines', lLines);
    for lIndex := 0 to LineCount - 1 do
    begin
      lItem := TJSONObject.Create; lLines.Add(lItem);
      with Lines[lIndex] do
      begin
        lItem.Add('Name', Name); lItem.Add('TagName', TagName);
        lItem.Add('TagId', TagId); lItem.Add('EstimateKind', Ord(EstimateKind));
        lItem.Add('AxisIndex', AxisIndex); lItem.Add('Width', Width);
        lItem.Add('Color', Color); lItem.Add('Visible', Visible);
      end;
    end;
  except Result.Free; raise; end;
end;

procedure TOscModel.ReadJson(AObject: TJSONObject);
var lArray: TJSONArray; lItem: TJSONObject; lIndex: Integer;
begin
  if JsonInt(AObject, 'Version') <> 1 then raise EConvertError.Create('Unsupported version');
  BindingMode := TOscBindingMode(JsonOrdinal(AObject, 'BindingMode', Ord(High(TOscBindingMode))));
  DisplayFormat := JsonString(AObject, 'DisplayFormat');
  ClosedInput := JsonBool(AObject, 'ClosedInput');
  AutoRangeEnabled := JsonBool(AObject, 'AutoRangeEnabled');
  XCursorEnabled := JsonBool(AObject, 'XCursorEnabled');
  XCursorCount := JsonInt32(AObject, 'XCursorCount');
  LegendVisible := JsonBool(AObject, 'LegendVisible');
  LevelCursorVisible := JsonBool(AObject, 'LevelCursorVisible');
  PrimaryAxisIndex := JsonInt32(AObject, 'PrimaryAxisIndex');
  TagOffset := JsonInt32(AObject, 'TagOffset');
  XScale := JsonNumber(AObject, 'XScale');
  TriggerTagName := JsonString(AObject, 'TriggerTagName');
  TriggerEnabled := JsonBool(AObject, 'TriggerEnabled');
  TriggerEdge := TOscSignalEdge(JsonOrdinal(AObject, 'TriggerEdge', Ord(High(TOscSignalEdge))));
  TriggerLevel := JsonNumber(AObject, 'TriggerLevel');
  TagName := JsonString(AObject, 'TagName');
  TagId := JsonInt(AObject, 'TagId');
  fYScale := JsonNumber(AObject, 'YScale'); fYOffset := JsonNumber(AObject, 'YOffset');
  fPreRoll := JsonNumber(AObject, 'TriggerPreRollPercent');
  if (fPreRoll < 0) or (fPreRoll > 50) or (XCursorCount < 1) or
    (XCursorCount > 2) or (XScale < 0) or (TagId < 0) then
    raise EConvertError.Create('Invalid Oscillogram configuration');
  ClearAxes; lArray := JsonArray(AObject, 'Axes');
  for lIndex := 0 to lArray.Count - 1 do
  begin
    lItem := JsonObject(lArray[lIndex]);
    with AddAxis do
    begin
      Name := JsonString(lItem, 'Name'); Color := JsonInt32(lItem, 'Color');
      RangeMin := JsonNumber(lItem, 'RangeMin'); RangeMax := JsonNumber(lItem, 'RangeMax');
      YScale := JsonNumber(lItem, 'YScale'); YOffset := JsonNumber(lItem, 'YOffset');
      if (RangeMax <= RangeMin) or (YScale <= 0) then
        raise EConvertError.Create('Invalid axis range or scale');
    end;
  end;
  if (AxisCount = 0) or (PrimaryAxisIndex < 0) or (PrimaryAxisIndex >= AxisCount) then
    raise EConvertError.Create('Invalid primary axis');
  ClearLines; lArray := JsonArray(AObject, 'Lines');
  for lIndex := 0 to lArray.Count - 1 do
  begin
    lItem := JsonObject(lArray[lIndex]);
    with AddLine do
    begin
      Name := JsonString(lItem, 'Name'); TagName := JsonString(lItem, 'TagName');
      TagId := JsonInt(lItem, 'TagId');
      EstimateKind := TOscEstimate(JsonOrdinal(lItem, 'EstimateKind', Ord(High(TOscEstimate))));
      AxisIndex := JsonInt32(lItem, 'AxisIndex'); Width := JsonInt32(lItem, 'Width');
      Color := JsonInt32(lItem, 'Color'); Visible := JsonBool(lItem, 'Visible');
      if (TagId < 0) or (AxisIndex < 0) or (AxisIndex >= AxisCount) or (Width < 1) then
        raise EConvertError.Create('Invalid line binding or width');
    end;
  end;
end;

function TOscModel.SaveUtf8: UTF8String;
var lJson: TJSONObject;
begin
  lJson := ToJson;
  try Result := UTF8String(lJson.AsJSON); finally lJson.Free; end;
end;

function TOscModel.LoadUtf8(const AData: UTF8String; out AError: string): Boolean;
var lJson: TJSONData; lDraft: TOscModel; lSwap: TList;
begin
  Result := False; AError := ''; lJson := nil; lDraft := nil;
  try
    try
      if Length(AData) > 16 * 1024 * 1024 then raise EConvertError.Create('State too large');
      lJson := GetJSON(AData, True); lDraft := TOscModel.Create;
      lDraft.ReadJson(JsonObject(lJson));
      { Swap owned collections only after every field has passed validation.
        Assigning scalars cannot fail; this also avoids a partial commit on OOM. }
      BindingMode := lDraft.BindingMode;
      DisplayFormat := lDraft.DisplayFormat;
      ClosedInput := lDraft.ClosedInput;
      AutoRangeEnabled := lDraft.AutoRangeEnabled;
      XCursorEnabled := lDraft.XCursorEnabled;
      XCursorCount := lDraft.XCursorCount;
      LegendVisible := lDraft.LegendVisible;
      LevelCursorVisible := lDraft.LevelCursorVisible;
      PrimaryAxisIndex := lDraft.PrimaryAxisIndex;
      TagOffset := lDraft.TagOffset;
      XScale := lDraft.XScale;
      TriggerTagName := lDraft.TriggerTagName;
      TriggerEnabled := lDraft.TriggerEnabled;
      TriggerEdge := lDraft.TriggerEdge;
      TriggerLevel := lDraft.TriggerLevel;
      TagName := lDraft.TagName;
      TagId := lDraft.TagId;
      fYScale := lDraft.fYScale; fYOffset := lDraft.fYOffset; fPreRoll := lDraft.fPreRoll;
      lSwap := fAxes; fAxes := lDraft.fAxes; lDraft.fAxes := lSwap;
      lSwap := fLines; fLines := lDraft.fLines; lDraft.fLines := lSwap;
      Result := True;
    except on E: Exception do AError := E.Message; end;
  finally lDraft.Free; lJson.Free; end;
end;

end.



