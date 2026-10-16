unit uOscLegacyImport;
{$mode objfpc}{$H+}{$codepage UTF8}

{ Cold plugin-owned migration of recorder.ini.section-v1 (a full UTF8 JSON
  object of INI string values). Host transports bytes only and must not know
  Osc keys. Read/validate a private draft before publishing; errors leave the
  caller model unchanged. Compatibility follows the former project loader,
  including simple built-in versus advanced plugin defaults and clamps. }
interface
uses uOscModel;
function ImportOscLegacy(const AData: UTF8String; const AOriginalType: string;
  AModel: TOscModel; out AError: string): Boolean;
implementation
uses Classes, SysUtils, Math, fpjson, jsonparser;
type
  TLegacyFields = class
  private
    fObject: TJSONObject;
  public
    constructor Create(AObject: TJSONObject);
    function Text(const AKey, ADefault: string): string;
    function Number(const AKey: string; ADefault: Double): Double;
    function Int64Value(const AKey: string; ADefault: Int64): Int64;
    function IntegerValue(const AKey: string; ADefault: Integer): Integer;
    function Flag(const AKey: string; ADefault: Boolean): Boolean;
  end;

constructor TLegacyFields.Create(AObject: TJSONObject);
begin inherited Create; fObject := AObject; end;

function TLegacyFields.Text(const AKey, ADefault: string): string;
var I: Integer;
begin
  { INI names are case-insensitive; JSON's default lookup is not. }
  for I := 0 to fObject.Count - 1 do
    if SameText(fObject.Names[I], AKey) then
    begin
      if fObject.Items[I].JSONType <> jtString then
        raise EConvertError.Create('Legacy field must be a string: ' + AKey);
      Exit(fObject.Items[I].AsString);
    end;
  Result := ADefault;
end;

function TLegacyFields.Number(const AKey: string; ADefault: Double): Double;
var lText: string; lFormat: TFormatSettings;
begin
  lText := Text(AKey, '');
  if lText = '' then Exit(ADefault);
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  { Old TIniFile.WriteFloat used the machine locale. Russian projects contain
    comma decimals; the raw transport must not normalize them in the host. }
  lText := StringReplace(lText, ',', '.', [rfReplaceAll]);
  if not TryStrToFloat(lText, Result, lFormat) or IsNan(Result) or IsInfinite(Result) then
    raise EConvertError.Create('Invalid legacy number: ' + AKey);
end;

function TLegacyFields.Int64Value(const AKey: string; ADefault: Int64): Int64;
var lText: string;
begin
  lText := Text(AKey, '');
  if lText = '' then Exit(ADefault);
  if not TryStrToInt64(lText, Result) then
    raise EConvertError.Create('Invalid legacy integer: ' + AKey);
end;

function TLegacyFields.IntegerValue(const AKey: string; ADefault: Integer): Integer;
var lValue: Int64;
begin
  lValue := Int64Value(AKey, ADefault);
  if (lValue < Low(Integer)) or (lValue > High(Integer)) then
    raise EConvertError.Create('Legacy integer overflow: ' + AKey);
  Result := lValue;
end;

function TLegacyFields.Flag(const AKey: string; ADefault: Boolean): Boolean;
var lText: string;
begin
  lText := Trim(Text(AKey, ''));
  if lText = '' then Exit(ADefault);
  if SameText(lText, 'true') or (lText = '1') then Exit(True);
  if SameText(lText, 'false') or (lText = '0') then Exit(False);
  raise EConvertError.Create('Invalid legacy boolean: ' + AKey);
end;

procedure ReadAxes(AFields: TLegacyFields; AModel: TOscModel);
var I, lCount: Integer; lAxis: TOscAxis; lScale, lOffset: Double;
begin
  lScale := AModel.YScale;
  lOffset := AModel.YOffset;
  lCount := EnsureRange(AFields.IntegerValue('OscAxisCount', 1), 1, 16);
  AModel.ClearAxes;
  for I := 0 to lCount - 1 do
  begin
    lAxis := AModel.AddAxis;
    lAxis.Name := AFields.Text(Format('OscAxis%dName', [I]), lAxis.Name);
    lAxis.YScale := AFields.Number(Format('OscAxis%dYScale', [I]), lScale);
    if lAxis.YScale <= 0 then lAxis.YScale := 1;
    lAxis.YOffset := AFields.Number(Format('OscAxis%dYOffset', [I]), lOffset);
  end;
  AModel.PrimaryAxisIndex := AFields.IntegerValue('OscPrimaryAxisIndex', 0);
  if (AModel.PrimaryAxisIndex < 0) or (AModel.PrimaryAxisIndex >= lCount) then
    AModel.PrimaryAxisIndex := 0;
end;

procedure ReadAdvanced(AFields: TLegacyFields; AModel: TOscModel);
begin
  AModel.XScale := Max(0.0, AFields.Number('OscXScale', 0));
  AModel.YScale := AFields.Number('OscYScale', 1);
  if AModel.YScale <= 0 then AModel.YScale := 1;
  AModel.YOffset := AFields.Number('OscYOffset', 0);
  AModel.ClosedInput := AFields.Flag('OscClosedInput', False);
  AModel.AutoRangeEnabled := AFields.Flag('OscAutoRangeEnabled', False);
  AModel.XCursorEnabled := AFields.Flag('OscXCursorEnabled', False);
  AModel.XCursorCount := AFields.IntegerValue('OscXCursorCount', 1);
  if (AModel.XCursorCount < 1) or (AModel.XCursorCount > 2) then AModel.XCursorCount := 1;
  AModel.LegendVisible := AFields.Flag('OscLegendVisible', True);
  AModel.LevelCursorVisible := AFields.Flag('OscLevelCursorVisible', False);
  ReadAxes(AFields, AModel);
  AModel.TriggerTagName := AFields.Text('OscTriggerTag', '');
  AModel.TriggerEnabled := AFields.Flag('OscTriggerEnabled', False);
  AModel.TriggerEdge := TOscSignalEdge(EnsureRange(
    AFields.IntegerValue('OscTriggerEdge', 0), 0, 1));
  AModel.TriggerLevel := AFields.Number('OscTriggerLevel', 0);
  AModel.TriggerPreRollPercent := AFields.Number('OscTriggerPreRollPercent', 25);
end;

function PaletteName(APalette: TOscModel; AColor: LongInt): string;
var I: Integer;
begin
  Result := '';
  for I := 0 to APalette.LineCount - 1 do
    if APalette.Lines[I].Color = AColor then Exit(APalette.Lines[I].Name);
end;

procedure ReadLines(AFields: TLegacyFields; AModel: TOscModel);
var I, lCount: Integer; lLine: TOscLine; lPalette: TOscModel;
  lDefaultName: string; lDefaultColor: LongInt;
begin
  lCount := Max(0, AFields.IntegerValue('OscLineCount', 0));
  { Bound hostile sections before allocation; no old valid project approaches
    this limit. Unknown keys do not affect the owned model. }
  if lCount > 65536 then raise EConvertError.Create('Too many legacy lines');
  lPalette := TOscModel.Create;
  try
    for I := 0 to 17 do lPalette.AddLine;
    AModel.ClearLines;
    for I := 0 to lCount - 1 do
    begin
      lLine := AModel.AddLine;
      lDefaultName := lLine.Name;
      lDefaultColor := lLine.Color;
      lLine.TagName := AFields.Text(Format('OscLine%dTagName', [I]), '');
      lLine.TagId := AFields.Int64Value(Format('OscLine%dTagId', [I]), 0);
      lLine.Color := AFields.IntegerValue(Format('OscLine%dColor', [I]), lDefaultColor);
      lLine.Name := PaletteName(lPalette, lLine.Color);
      if lLine.Name = '' then
        lLine.Name := AFields.Text(Format('OscLine%dName', [I]), '');
      if lLine.Name = '' then
      begin lLine.Name := lDefaultName; lLine.Color := lDefaultColor; end;
      lLine.Visible := AFields.Flag(Format('OscLine%dVisible', [I]), True);
      lLine.AxisIndex := AFields.IntegerValue(Format('OscLine%dAxisIndex', [I]), 0);
      if (lLine.AxisIndex < 0) or (lLine.AxisIndex >= AModel.AxisCount) then
        lLine.AxisIndex := 0;
    end;
  finally lPalette.Free; end;
end;

function ImportOscLegacy(const AData: UTF8String; const AOriginalType: string;
  AModel: TOscModel; out AError: string): Boolean;
var lRoot: TJSONData; lFields: TLegacyFields; lDraft: TOscModel; lMode: Integer;
begin
  Result := False; AError := ''; lRoot := nil; lFields := nil; lDraft := nil;
  try
    try
      if AModel = nil then raise EConvertError.Create('Missing legacy target');
      if not SameText(AOriginalType, 'Oscillogram') and
        not SameText(AOriginalType, 'sample.oscillogram') then
        raise EConvertError.Create('Unsupported legacy component type');
      lRoot := GetJSON(AData, True);
      if not (lRoot is TJSONObject) then raise EConvertError.Create('Expected legacy section object');
      lFields := TLegacyFields.Create(TJSONObject(lRoot));
      lDraft := TOscModel.Create;
      lDraft.TagName := lFields.Text('TagName', '');
      lDraft.TagId := lFields.Int64Value('TagId', 0);
      lDraft.DisplayFormat := lFields.Text('DisplayFormat', '4');
      lMode := lFields.IntegerValue('BindingMode', Ord(obRelativeSelectedTag));
      if (lMode < Ord(Low(TOscBindingMode))) or (lMode > Ord(High(TOscBindingMode))) then
        raise EConvertError.Create('Invalid legacy binding mode');
      lDraft.BindingMode := TOscBindingMode(lMode);
      lDraft.TagOffset := lFields.IntegerValue('TagOffset', 0);
      if SameText(AOriginalType, 'sample.oscillogram') then ReadAdvanced(lFields, lDraft);
      ReadLines(lFields, lDraft);
      AModel.Assign(lDraft);
      Result := True;
    except on E: Exception do AError := E.Message; end;
  finally lDraft.Free; lFields.Free; lRoot.Free; end;
end;
end.
