unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  uOglChart, uOglChartBaseObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, ImgList;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ImageList1: TImageList;
    OglChart1: TOglChart;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure AddChartTreeNode(AParentNode: TTreeNode; AObject: TChartBaseObject);
    procedure BuildChartTree;

  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function AxisOrientationToText(AOrientation: TChartAxisOrientation): string;
begin
  case AOrientation of
    caoX: Result := 'X';
    caoY: Result := 'Y';
  else
    Result := '?';
  end;
end;

function AxisScaleToText(AScale: TChartAxisScale): string;
begin
  case AScale of
    casLinear: Result := 'linear';
    casLog10: Result := 'log10';
  else
    Result := '?';
  end;
end;

function ChartObjectTreeText(AObject: TChartBaseObject): string;
var
  lAxis: cAxis;
begin
  if not Assigned(AObject) then
    Exit('');

  Result := AObject.Name;
  if AObject.Caption <> '' then
    Result := Result + ' "' + AObject.Caption + '"';
  Result := Result + ' : ' + AObject.ClassName;

  if AObject is cAxis then
  begin
    lAxis := cAxis(AObject);
    Result := Result + Format(' [%s, %s, %.4g..%.4g]', [
      AxisOrientationToText(lAxis.Orientation),
      AxisScaleToText(lAxis.Scale),
      lAxis.MinValue,
      lAxis.MaxValue
    ]);
  end
  else if AObject is cBuffTrend1d then
    Result := Result + Format(' [count=%d, dx=%.4g]', [
      cBuffTrend1d(AObject).Count,
      cBuffTrend1d(AObject).DX
    ])
  else if AObject is TChartLineSeries then
    Result := Result + Format(' [points=%d]', [TChartLineSeries(AObject).PointCount]);

  if AObject.ChildCount > 0 then
    Result := Result + Format(' (%d)', [AObject.ChildCount]);
end;

function ChartObjectImageIndex(AObject: TChartBaseObject): Integer;
begin
  Result := 0;
  if not Assigned(AObject) then
    Exit;

  if AObject is TChartModel then
    Result := 0
  else if AObject is cBasePage then
    Result := 1
  else if AObject is cAxis then
    Result := 2
  else if AObject is cSeries then
    Result := 2;
end;

procedure TForm1.AddChartTreeNode(AParentNode: TTreeNode; AObject: TChartBaseObject);
var
  lNode: TTreeNode;
  lIndex: Integer;
  lImageIndex: Integer;
begin
  if not Assigned(AObject) then
    Exit;

  if Assigned(AParentNode) then
    lNode := TreeView1.Items.AddChildObject(AParentNode, ChartObjectTreeText(AObject), AObject)
  else
    lNode := TreeView1.Items.AddObject(nil, ChartObjectTreeText(AObject), AObject);

  lImageIndex := ChartObjectImageIndex(AObject);
  lNode.ImageIndex := lImageIndex;
  lNode.SelectedIndex := lImageIndex;

  for lIndex := 0 to AObject.ChildCount - 1 do
    AddChartTreeNode(lNode, AObject.Children[lIndex]);
end;

procedure TForm1.BuildChartTree;
begin
  TreeView1.BeginUpdate;
  try
    TreeView1.Items.Clear;
    AddChartTreeNode(nil, OglChart1.Model);
    TreeView1.FullExpand;
  finally
    TreeView1.EndUpdate;
  end;
end;

procedure AddAxisPair(APage: cBasePage; const ANamePrefix: string; out AXAxis, AYAxis: cAxis);
begin
  AXAxis := cAxis.Create;
  AXAxis.Name := ANamePrefix + 'AxisX';
  AXAxis.Caption := ANamePrefix + ' X';
  AXAxis.Orientation := caoX;
  APage.AddChild(AXAxis);

  AYAxis := cAxis.Create;
  AYAxis.Name := ANamePrefix + 'AxisY';
  AYAxis.Caption := ANamePrefix + ' Y';
  AYAxis.Orientation := caoY;
  APage.AddChild(AYAxis);
end;

function AddPage(AModel: cChart; const AName, ACaption: string): cBasePage;
begin
  Result := cBasePage.Create;
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Align := cpaAuto;
  AModel.AddChild(Result);
end;

function AddLine(AYAxis, AXAxis: cAxis; const AName, ACaption: string; AColor: Cardinal): cTrend;
begin
  Result := cTrend.Create;
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Color := AColor;
  Result.XAxis := AXAxis;
  AYAxis.AddChild(Result);
end;

procedure CreateTestChart(AChart: TOglChart);
var
  lPage: cBasePage;
  lAxisX: cAxis;
  lAxisY: cAxis;
  lSeries: cTrend;
  lBuff: cBuffTrend1d;
begin
  AChart.ObjectManager.Clear;
  AChart.Model.BackgroundColor := $FFFFFFFF;

  lPage := AddPage(AChart.Model, 'PageTrend', 'Page_Trend');
  AddAxisPair(lPage, 'Trend', lAxisX, lAxisY);
  lAxisX.MinValue := 0;
  lAxisX.MaxValue := 11;
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lSeries := AddLine(lAxisY, lAxisX, 'TrendLine', 'Trend line', $FF303030);
  lSeries.AddPoint(0, 0.22);
  lSeries.AddPoint(1, 0.36);
  lSeries.AddPoint(2, 0.31);
  lSeries.AddPoint(3, 0.58);
  lSeries.AddPoint(4, 0.48);
  lSeries.AddPoint(5, 0.74);
  lSeries.AddPoint(6, 0.69);
  lSeries.AddPoint(7, 0.86);
  lSeries.AddPoint(8, 0.63);
  lSeries.AddPoint(9, 0.78);
  lSeries.AddPoint(10, 0.52);
  lSeries.AddPoint(11, 0.66);

  lPage := AddPage(AChart.Model, 'PageSignals', 'Page_Signals');
  AddAxisPair(lPage, 'Signals', lAxisX, lAxisY);
  lAxisX.MinValue := 0;
  lAxisX.MaxValue := 9;
  lAxisY.MinValue := 0.4;
  lAxisY.MaxValue := 0.75;
  lSeries := AddLine(lAxisY, lAxisX, 'SignalBlue', 'Signal blue', $FFFF0000);
  lSeries.AddPoint(0, 0.48);
  lSeries.AddPoint(1, 0.56);
  lSeries.AddPoint(2, 0.41);
  lSeries.AddPoint(3, 0.63);
  lSeries.AddPoint(4, 0.52);
  lSeries.AddPoint(5, 0.74);
  lSeries.AddPoint(6, 0.44);
  lSeries.AddPoint(7, 0.68);
  lSeries.AddPoint(8, 0.58);
  lSeries.AddPoint(9, 0.72);

  lSeries := AddLine(lAxisY, lAxisX, 'SignalRed', 'Signal red', $FF0000FF);
  lSeries.AddPoint(0, 0.42);
  lSeries.AddPoint(1, 0.47);
  lSeries.AddPoint(2, 0.50);
  lSeries.AddPoint(3, 0.45);
  lSeries.AddPoint(4, 0.54);
  lSeries.AddPoint(5, 0.49);
  lSeries.AddPoint(6, 0.57);
  lSeries.AddPoint(7, 0.51);
  lSeries.AddPoint(8, 0.62);
  lSeries.AddPoint(9, 0.55);

  lPage := AddPage(AChart.Model, 'PageBars', 'Page_Bars');
  AddAxisPair(lPage, 'Bars', lAxisX, lAxisY);
  lAxisX.MinValue := 0;
  lAxisX.MaxValue := 9;
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lBuff := cBuffTrend1d.Create;
  lBuff.Name := 'BottomBuff1d';
  lBuff.Caption := 'Bottom buffer 1D';
  lBuff.Color := $FF0090D0;
  lBuff.XAxis := lAxisX;
  lBuff.X0 := 0;
  lBuff.DX := 1;
  lBuff.AddValue(0.32);
  lBuff.AddValue(0.44);
  lBuff.AddValue(0.37);
  lBuff.AddValue(0.61);
  lBuff.AddValue(0.52);
  lBuff.AddValue(0.58);
  lBuff.AddValue(0.71);
  lBuff.AddValue(0.64);
  lBuff.AddValue(0.69);
  lBuff.AddValue(0.80);
  lAxisY.AddChild(lBuff);

  AChart.Redraw;
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnCreate := @FormCreate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CreateTestChart(OglChart1);
  TreeView1.MultiSelect := True;
  TreeView1.Images := ImageList1;
  TreeView1.Font.Size := 10;
  Button1.Visible := True;
  BuildChartTree;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  BuildChartTree;
end;

end.
