unit uOglChartCursor;

{
  Модуль uOglChartCursor
  Описание: Класс интерактивного курсора-визира для измерения текущих значений трендов.
}

{ objfpc}{+}

interface

uses

  Classes, SysUtils, fpjson, uOglChartBaseObj, uOglChartTypes;

type

  TChartCursorType = (cctSingle, cctDouble);

  { TChartCursor }

  // Объект измерительного курсора на странице графика.
  // Поддерживает отображение одной или двух вертикальных линий,
  // привязку к осям и хранение положения текстовых меток.

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

// Возвращает существующий или создает новый курсор для страницы.

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

end.

