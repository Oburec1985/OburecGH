unit uOglChartCursor;
{
  РњРѕРґСѓР»СЊ uOglChartCursor
  РћРїРёСЃР°РЅРёРµ: РљР»Р°СЃСЃ РёРЅС‚РµСЂР°РєС‚РёРІРЅРѕРіРѕ РєСѓСЂСЃРѕСЂР°-РІРёР·РёСЂР° РґР»СЏ РёР·РјРµСЂРµРЅРёСЏ С‚РµРєСѓС‰РёС… Р·РЅР°С‡РµРЅРёР№ С‚СЂРµРЅРґРѕРІ.
}
{$mode objfpc}{$H+}
{$codepage UTF8}
interface
uses
  Classes, SysUtils, fpjson, uOglChartBaseObj, uOglChartTypes;
type
  TChartCursorType = (cctSingle, cctDouble);
  { TChartCursor }
  // РћР±СЉРµРєС‚ РёР·РјРµСЂРёС‚РµР»СЊРЅРѕРіРѕ РєСѓСЂСЃРѕСЂР° РЅР° СЃС‚СЂР°РЅРёС†Рµ РіСЂР°С„РёРєР°.
  // РџРѕРґРґРµСЂР¶РёРІР°РµС‚ РѕС‚РѕР±СЂР°Р¶РµРЅРёРµ РѕРґРЅРѕР№ РёР»Рё РґРІСѓС… РІРµСЂС‚РёРєР°Р»СЊРЅС‹С… Р»РёРЅРёР№,
  // РїСЂРёРІСЏР·РєСѓ Рє РѕСЃСЏРј Рё С…СЂР°РЅРµРЅРёРµ РїРѕР»РѕР¶РµРЅРёСЏ С‚РµРєСЃС‚РѕРІС‹С… РјРµС‚РѕРє.
  TChartCursor = class(TChartBaseObject)
  private
    fVisible: Boolean;
    fCursorType: TChartCursorType;
    fX1: Double;
    fX2: Double;
    fLabelY1Offset: Double;
    fLabelY2Offset: Double;
    fShowLabel: Boolean;
    fColor: Cardinal;
    fMultiLineMode: TMultiLineMode;
  public
    constructor Create; override;
    procedure AssignDefaultProperties; override;
    procedure SaveJsonAttributes(AJson: TJSONObject); override;
    procedure LoadJsonAttributes(AJson: TJSONObject); override;
    property Visible: Boolean read fVisible write fVisible;
    property CursorType: TChartCursorType read fCursorType write fCursorType;
    property X1: Double read fX1 write fX1;
    property X2: Double read fX2 write fX2;
    property LabelY1Offset: Double read fLabelY1Offset write fLabelY1Offset;
    property LabelY2Offset: Double read fLabelY2Offset write fLabelY2Offset;
    property ShowLabel: Boolean read fShowLabel write fShowLabel;
    property Color: Cardinal read fColor write fColor;
    property MultiLineMode: TMultiLineMode read fMultiLineMode write fMultiLineMode;
  end;
  { TChartFrequencyBand }
  TChartFrequencyBand = class(TChartBaseObject)
  private
    fVisible: Boolean;
    fX1: Double;
    fX2: Double;
    fColor: Cardinal;
    fPeakX: Double;
    fPeakY: Double;
    fRms: Double;
  public
    constructor Create; override;
    procedure AssignDefaultProperties; override;
    function NotSaveToJson: Boolean; override;
    property Visible: Boolean read fVisible write fVisible;
    property X1: Double read fX1 write fX1;
    property X2: Double read fX2 write fX2;
    property Color: Cardinal read fColor write fColor;
    property PeakX: Double read fPeakX write fPeakX;
    property PeakY: Double read fPeakY write fPeakY;
    property Rms: Double read fRms write fRms;
  end;
// Р’РѕР·РІСЂР°С‰Р°РµС‚ СЃСѓС‰РµСЃС‚РІСѓСЋС‰РёР№ РёР»Рё СЃРѕР·РґР°РµС‚ РЅРѕРІС‹Р№ РєСѓСЂСЃРѕСЂ РґР»СЏ СЃС‚СЂР°РЅРёС†С‹.
function GetOrCreatePageCursor(APage: TChartBaseObject): TChartCursor;
implementation
function GetOrCreatePageCursor(APage: TChartBaseObject): TChartCursor;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(APage) then Exit;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartCursor then
      Exit(TChartCursor(APage.Children[I]));
  Result := TChartCursor.Create;
  Result.Name := APage.Name + 'Cursor';
  Result.Caption := 'Cursor';
  APage.AddChild(Result);
end;
{ TChartCursor }
constructor TChartCursor.Create;
begin
  inherited Create;
end;
procedure TChartCursor.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  fVisible := False;
  fCursorType := cctSingle;
  fX1 := 0.0;
  fX2 := 1.0;
  fLabelY1Offset := 0.5;
  fLabelY2Offset := 0.4;
  fShowLabel := True;
  fColor := 4294901760;
  fMultiLineMode := mlDisabled;
end;
procedure TChartCursor.SaveJsonAttributes(AJson: TJSONObject);
begin
  inherited SaveJsonAttributes(AJson);
  AJson.Add('visible', fVisible);
  AJson.Add('cursor_type', Ord(fCursorType));
  AJson.Add('x1', fX1);
  AJson.Add('x2', fX2);
  AJson.Add('label_y1_offset', fLabelY1Offset);
  AJson.Add('label_y2_offset', fLabelY2Offset);
  AJson.Add('show_label', fShowLabel);
  AJson.Add('color', Int64(fColor));
  AJson.Add('multiline_mode', Ord(fMultiLineMode));
end;
procedure TChartCursor.LoadJsonAttributes(AJson: TJSONObject);
begin
  inherited LoadJsonAttributes(AJson);
  if not Assigned(AJson) then Exit;
  if AJson.IndexOfName('visible') <> -1 then fVisible := AJson.Booleans['visible'];
  if AJson.IndexOfName('cursor_type') <> -1 then fCursorType := TChartCursorType(AJson.Integers['cursor_type']);
  if AJson.IndexOfName('x1') <> -1 then fX1 := AJson.Floats['x1'];
  if AJson.IndexOfName('x2') <> -1 then fX2 := AJson.Floats['x2'];
  if AJson.IndexOfName('label_y1_offset') <> -1 then fLabelY1Offset := AJson.Floats['label_y1_offset'];
  if AJson.IndexOfName('label_y2_offset') <> -1 then fLabelY2Offset := AJson.Floats['label_y2_offset'];
  if AJson.IndexOfName('show_label') <> -1 then fShowLabel := AJson.Booleans['show_label'];
  if AJson.IndexOfName('color') <> -1 then fColor := Cardinal(AJson.Integers['color']);
  if AJson.IndexOfName('multiline_mode') <> -1 then fMultiLineMode := TMultiLineMode(AJson.Integers['multiline_mode'])
  else if AJson.IndexOfName('multiline') <> -1 then
  begin
    if AJson.Booleans['multiline'] then fMultiLineMode := mlShowNames else fMultiLineMode := mlDisabled;
  end;
end;
{ TChartFrequencyBand }
constructor TChartFrequencyBand.Create;
begin
  inherited Create;
  AssignDefaultProperties;
end;
procedure TChartFrequencyBand.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  fVisible := True;
  fX1 := 0.0;
  fX2 := 0.0;
  fColor := $1E808080; // РћС‡РµРЅСЊ РїСЂРѕР·СЂР°С‡РЅС‹Р№ СЃРµСЂС‹Р№
  fPeakX := 0.0;
  fPeakY := 0.0;
  fRms := 0.0;
end;
function TChartFrequencyBand.NotSaveToJson: Boolean;
begin
  Result := True;
end;
end.