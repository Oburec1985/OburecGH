unit uRecorderMeasurementSectionView;

{
  Визуальное представление компонента "Измерительное сечение".
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Grids, Graphics,
  Math, uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderMeasurementSectionModel;

type
  TRecorderMeasurementSectionTableForm = class(TForm)
  private
    fComponent: TRecorderMeasurementSectionComponent;
    fGrid: TStringGrid;
    fRegistry: TRecorderTagRegistry;
    fTimer: TTimer;
    function FormatMaybe(AHasValue: Boolean; AValue: Double;
      const AFormat: string): string;
    procedure TimerTick(Sender: TObject);
  public
    constructor CreateTable(AOwner: TComponent;
      AComponent: TRecorderMeasurementSectionComponent;
      ARegistry: TRecorderTagRegistry); reintroduce;
    procedure RefreshTable;
  end;

  TRecorderMeasurementSectionView = class(TPanel, IVForm)
  private
    fComponent: TRecorderMeasurementSectionComponent;
    fEditMode: Boolean;
    fRegistry: TRecorderTagRegistry;
    fTableForm: TRecorderMeasurementSectionTableForm;
    procedure OpenTable(Sender: TObject);
    procedure TableDestroyed(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    property EditMode: Boolean read fEditMode write fEditMode;
  end;

implementation

const
  CColPoint = 0;
  CColTemp = 1;
  CColE1 = 2;
  CColE2 = 3;
  CColE3 = 4;
  CColSigma1 = 5;
  CColSigma2 = 6;
  CColAngle = 7;

{ TRecorderMeasurementSectionTableForm }

constructor TRecorderMeasurementSectionTableForm.CreateTable(AOwner: TComponent;
  AComponent: TRecorderMeasurementSectionComponent; ARegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fRegistry := ARegistry;
  Caption := 'Измерительное сечение';
  if fComponent <> nil then
    Caption := fComponent.Caption;
  FormStyle := fsStayOnTop;
  Position := poDesigned;
  Width := 760;
  Height := 360;

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.Align := alClient;
  fGrid.FixedCols := 0;
  fGrid.FixedRows := 1;
  fGrid.ColCount := 8;
  fGrid.RowCount := 2;
  fGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goRowSelect, goColSizing];
  fGrid.Cells[CColPoint, 0] := 'N точки';
  fGrid.Cells[CColTemp, 0] := 'Температура, °C';
  fGrid.Cells[CColE1, 0] := 'e1, мкстрн';
  fGrid.Cells[CColE2, 0] := 'e2, мкстрн';
  fGrid.Cells[CColE3, 0] := 'e3, мкстрн';
  fGrid.Cells[CColSigma1, 0] := 'sigma1, МПа';
  fGrid.Cells[CColSigma2, 0] := 'sigma2, МПа';
  fGrid.Cells[CColAngle, 0] := 'Угол, °';
  fGrid.ColWidths[CColPoint] := 70;
  fGrid.ColWidths[CColTemp] := 110;
  fGrid.ColWidths[CColE1] := 90;
  fGrid.ColWidths[CColE2] := 90;
  fGrid.ColWidths[CColE3] := 90;
  fGrid.ColWidths[CColSigma1] := 100;
  fGrid.ColWidths[CColSigma2] := 100;
  fGrid.ColWidths[CColAngle] := 80;

  fTimer := TTimer.Create(Self);
  fTimer.Interval := 250;
  fTimer.OnTimer := @TimerTick;
  fTimer.Enabled := True;
  RefreshTable;
end;

function TRecorderMeasurementSectionTableForm.FormatMaybe(AHasValue: Boolean;
  AValue: Double; const AFormat: string): string;
begin
  if AHasValue then
    Result := FormatFloat(AFormat, AValue)
  else
    Result := '-';
end;

procedure TRecorderMeasurementSectionTableForm.TimerTick(Sender: TObject);
begin
  RefreshTable;
end;

procedure TRecorderMeasurementSectionTableForm.RefreshTable;
var
  I: Integer;
  lRow: TRecorderMeasurementSectionRow;
  lValues: TRecorderMeasurementSectionValues;
begin
  if fComponent = nil then
    Exit;
  fGrid.RowCount := Max(2, fComponent.RowCount + 1);
  for I := 0 to fComponent.RowCount - 1 do
  begin
    lRow := fComponent.Rows[I];
    fComponent.CalculateRow(fRegistry, lRow, lValues);
    fGrid.Cells[CColPoint, I + 1] := IntToStr(lRow.PointNo);
    fGrid.Cells[CColTemp, I + 1] := FormatMaybe(lValues.HasTemperature,
      lValues.Temperature, '0.###');
    fGrid.Cells[CColE1, I + 1] := FormatMaybe(lValues.HasE1, lValues.E1,
      '0.###');
    fGrid.Cells[CColE2, I + 1] := FormatMaybe(lValues.HasE2, lValues.E2,
      '0.###');
    fGrid.Cells[CColE3, I + 1] := FormatMaybe(lValues.HasE3, lValues.E3,
      '0.###');
    fGrid.Cells[CColSigma1, I + 1] := FormatMaybe(lValues.Valid,
      lValues.Sigma1, '0.###');
    fGrid.Cells[CColSigma2, I + 1] := FormatMaybe(lValues.Valid,
      lValues.Sigma2, '0.###');
    fGrid.Cells[CColAngle, I + 1] := FormatMaybe(lValues.Valid,
      lValues.AngleDeg, '0.###');
  end;
end;

{ TRecorderMeasurementSectionView }

constructor TRecorderMeasurementSectionView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvLowered;
  ParentBackground := False;
  Color := $00FFF4E8;
  Caption := '';
  Alignment := taCenter;
  OnClick := @OpenTable;
end;

destructor TRecorderMeasurementSectionView.Destroy;
begin
  if fTableForm <> nil then
  begin
    fTableForm.OnDestroy := nil;
    FreeAndNil(fTableForm);
  end;
  inherited Destroy;
end;

procedure TRecorderMeasurementSectionView.Configure(
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
begin
  if not (AComponent is TRecorderMeasurementSectionComponent) then
    Exit;
  fComponent := TRecorderMeasurementSectionComponent(AComponent);
  fRegistry := ATagRegistry;
  Caption := fComponent.Caption;
  Hint := Caption;
end;

procedure TRecorderMeasurementSectionView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
begin
  if ATagRegistry <> nil then
    fRegistry := ATagRegistry;
  if (fComponent <> nil) and (Caption <> fComponent.Caption) then
    Caption := fComponent.Caption;
  if fTableForm <> nil then
    fTableForm.RefreshTable;
end;

function TRecorderMeasurementSectionView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

procedure TRecorderMeasurementSectionView.OpenTable(Sender: TObject);
begin
  if (fComponent = nil) or fEditMode then
    Exit;
  if fTableForm = nil then
  begin
    fTableForm := TRecorderMeasurementSectionTableForm.CreateTable(Self,
      fComponent, fRegistry);
    fTableForm.OnDestroy := @TableDestroyed;
  end;
  fTableForm.Show;
  fTableForm.BringToFront;
  fTableForm.RefreshTable;
end;

procedure TRecorderMeasurementSectionView.TableDestroyed(Sender: TObject);
begin
  fTableForm := nil;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderMeasurementSectionComponent, TRecorderMeasurementSectionView);

end.
