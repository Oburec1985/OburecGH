unit uOglChartChart;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpjson,
  uOglChartTypes, uOglChartLog, uOglChartBaseObj, uOglChartDrawObj, uOglChartPage;

type
  { cChart
    Корневой объект модели. Хранит глобальные настройки и раскладывает страницы
    в нормализованной области PageArea. }
  cChart = class(cBaseObj)
  private
    fTitle: string;
    fBackgroundColor: Cardinal;
    fPageArea: TChartFloatRect;
    fPageGapX: Double;
    fPageGapY: Double;
  public
    procedure AssignDefaultProperties; override;
    procedure Clear;
    procedure AlignPagesAuto(AAspect: Double = 1);
    procedure SaveJsonAttributes(AJson: TJSONObject); override;
    procedure LoadJsonAttributes(AJson: TJSONObject); override;

    function Serialize(ASerializer: IChartSerializer): string;
    procedure Deserialize(ASerializer: IChartSerializer; const AData: string);

    property Title: string read fTitle write fTitle;
    property BackgroundColor: Cardinal read fBackgroundColor write fBackgroundColor;
    property PageArea: TChartFloatRect read fPageArea write fPageArea;
    property PageGapX: Double read fPageGapX write fPageGapX;
    property PageGapY: Double read fPageGapY write fPageGapY;
  end;

  TChartModel = cChart;

implementation

procedure cChart.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'ChartModel';
  Caption := 'Chart';
  Clear;
end;

procedure cChart.Clear;
begin
  fTitle := 'New Chart';
  fBackgroundColor := $FF000000;
  fPageArea.Left := 0.012;
  fPageArea.Top := 0.018;
  fPageArea.Right := 0.988;
  fPageArea.Bottom := 0.982;
  fPageGapX := 0.000;
  fPageGapY := 0.000;
  ClearChildren;
end;

procedure cChart.AlignPagesAuto(AAspect: Double);
var
  lPages: TList;
  lIndex: Integer;
  lPageIndex: Integer;
  lPage: cBasePage;
  lCols: Integer;
  lRows: Integer;
  lRow: Integer;
  lCol: Integer;
  lCellHeight: Double;
  lAreaWidth: Double;
  lAreaHeight: Double;
  lLeft: Double;
  lTop: Double;
  lRowStart: Integer;
  lRowCount: Integer;
  lRowCellWidth: Double;
begin
  if AAspect <= 0 then
    AAspect := 1;

  lPages := TList.Create;
  try
    for lIndex := 0 to ChildCount - 1 do
      if Children[lIndex] is cBasePage then
      begin
        lPage := cBasePage(Children[lIndex]);
        if lPage.Align = cpaClient then
          lPage.SetFloatRect(fPageArea.Left, fPageArea.Top, fPageArea.Right, fPageArea.Bottom)
        else if lPage.Align = cpaAuto then
          lPages.Add(lPage);
      end;

    if lPages.Count = 0 then
      Exit;

    if lPages.Count <= 1 then
      lCols := 1
    else
      lCols := Max(1, Round(Sqrt(lPages.Count)));

    if lCols > lPages.Count then
      lCols := lPages.Count;
    if (lPages.Count mod lCols) > 0 then
      lRows := Trunc(lPages.Count / lCols) + 1
    else
      lRows := Round(lPages.Count / lCols);
    if lRows = 0 then
      lRows := 1;

    lAreaWidth := fPageArea.Right - fPageArea.Left;
    lAreaHeight := fPageArea.Bottom - fPageArea.Top;
    lCellHeight := (lAreaHeight - (lRows - 1) * fPageGapY) / lRows;

    for lPageIndex := 0 to lPages.Count - 1 do
    begin
      lPage := cBasePage(lPages[lPageIndex]);
      lRow := lPageIndex div lCols;
      lCol := lPageIndex mod lCols;
      lRowStart := lRow * lCols;
      lRowCount := Min(lCols, lPages.Count - lRowStart);
      lRowCellWidth := (lAreaWidth - (lRowCount - 1) * fPageGapX) / lRowCount;
      lLeft := fPageArea.Left + lCol * (lRowCellWidth + fPageGapX);
      lTop := fPageArea.Top + lRow * (lCellHeight + fPageGapY);
      lPage.SetFloatRect(lLeft, lTop, lLeft + lRowCellWidth, lTop + lCellHeight);
    end;
  finally
    lPages.Free;
  end;
end;

procedure cChart.SaveJsonAttributes(AJson: TJSONObject);
begin
  inherited SaveJsonAttributes(AJson);
  AJson.Add('Title', fTitle);
  AJson.Add('BackgroundColor', IntToHex(fBackgroundColor, 8));
end;

procedure cChart.LoadJsonAttributes(AJson: TJSONObject);
begin
  inherited LoadJsonAttributes(AJson);
  if not Assigned(AJson) then
    Exit;
  if AJson.IndexOfName('Title') <> -1 then
    fTitle := AJson.Strings['Title'];
  if AJson.IndexOfName('BackgroundColor') <> -1 then
    fBackgroundColor := StrToQWord('$' + AJson.Strings['BackgroundColor']);
end;

function cChart.Serialize(ASerializer: IChartSerializer): string;
begin
  Result := '';
  if Assigned(ASerializer) then
    Result := ASerializer.SaveObject(Self);
end;

procedure cChart.Deserialize(ASerializer: IChartSerializer; const AData: string);
begin
  if Assigned(ASerializer) then
    ASerializer.LoadObject(Self, AData);
end;

end.
