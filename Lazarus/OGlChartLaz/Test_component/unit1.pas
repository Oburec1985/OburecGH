unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  Math, uOglChart, uOglChartBaseObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, uOglChartRenderer, uOglChartTypes, uOglChartDrawObj, ImgList;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ImageList1: TImageList;
    OglChart1: TOglChart;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OglChart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    fMouseCoordsText: string;
    fFpsText: string;
    procedure UpdateStatusBar;
    procedure OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
    procedure AddChartTreeNode(AParentNode: TTreeNode; AObject: TChartBaseObject);
    procedure BuildChartTree;

  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.UpdateStatusBar;
var
  lSelText: string;
begin
  lSelText := 'Selected: None';
  if Assigned(OglChart1.SelectedObject) then
  begin
    lSelText := 'Selected: ' + OglChart1.SelectedObject.Name;
    if OglChart1.SelectedObject.Caption <> '' then
      lSelText := lSelText + ' ("' + OglChart1.SelectedObject.Caption + '")';
  end;
  StatusBar1.SimpleText := fMouseCoordsText + ' | ' + lSelText + ' | ' + fFpsText;
end;

procedure TForm1.OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
var
  lFps: Double;
begin
  if ARenderTimeMs > 0 then
    lFps := 1000.0 / ARenderTimeMs
  else
    lFps := 0;
  fFpsText := Format('Render: %.2f ms (%.1f FPS)', [ARenderTimeMs, lFps]);
  UpdateStatusBar;
end;

{ TForm1 }



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
    Result := Result + Format(' [%s, %.4g..%.4g]', [
      AxisScaleToText(lAxis.Scale),
      lAxis.MinValue,
      lAxis.MaxValue
    ]);
    if lAxis.UseOwnX then
      Result := Result + Format(' [OwnX: %s, %.4g..%.4g]', [
        AxisScaleToText(lAxis.XScale),
        lAxis.XMinValue,
        lAxis.XMaxValue
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

procedure AddAxis(APage: cBasePage; const ANamePrefix: string; out AYAxis: cAxis);
begin
  AYAxis := cAxis.Create;
  AYAxis.Name := ANamePrefix + 'AxisY';
  AYAxis.Caption := ANamePrefix + ' Y';
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

function AddLine(AYAxis: cAxis; const AName, ACaption: string; AColor: Cardinal): cTrend;
begin
  Result := cTrend.Create;
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Color := AColor;
  AYAxis.AddChild(Result);
end;

procedure CreateTestChart(AChart: TOglChart);
var
  lPage: cBasePage;
  lAxisY: cAxis;
  lAxisY2: cAxis;
  lSeries: cTrend;
  lBuff: cBuffTrend1d;
begin
  AChart.ObjectManager.Clear;
  AChart.Model.BackgroundColor := $FFFFFFFF;

  lPage := AddPage(AChart.Model, 'PageTrend', 'Page_Trend');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 11;
  AddAxis(lPage, 'Trend', lAxisY);
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lSeries := AddLine(lAxisY, 'TrendLine', 'Trend line', $FF303030);
  lSeries.ShowPoints := True;
  lSeries.Smooth := True;
  lSeries.AddBeziePoint(0, 0.22, bptCorner);
  lSeries.AddBeziePoint(1, 0.36, bptSmooth);
  lSeries.AddBeziePoint(2, 0.31, bptSmooth);
  lSeries.AddBeziePoint(3, 0.58, bptCorner);
  lSeries.AddBeziePoint(4, 0.48, bptSmooth);
  lSeries.AddBeziePoint(5, 0.74, bptSmooth);
  lSeries.AddBeziePoint(6, 0.69, bptCorner);
  lSeries.AddBeziePoint(7, 0.86, bptSmooth);
  lSeries.AddBeziePoint(8, 0.63, bptSmooth);
  lSeries.AddBeziePoint(9, 0.78, bptCorner);
  lSeries.AddBeziePoint(10, 0.52, bptSmooth);
  lSeries.AddBeziePoint(11, 0.66, bptCorner);
  lSeries.GenerateSplinePoints();

  lPage := AddPage(AChart.Model, 'PageSignals', 'Page_Signals');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 9;

  // Первая ось Y (синяя в ABGR)
  AddAxis(lPage, 'Signals', lAxisY);
  lAxisY.MinValue := 0.4;
  lAxisY.MaxValue := 0.75;
  lAxisY.Color := $FF0000FF; // Синий
  lSeries := AddLine(lAxisY, 'SignalBlue', 'Signal blue', $FF0000FF);
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

  // Вторая ось Y (красная в ABGR)
  AddAxis(lPage, 'Signals2', lAxisY2);
  lAxisY2.MinValue := 0.3;
  lAxisY2.MaxValue := 0.9;
  lAxisY2.Color := $FFFF0000; // Красный
  lSeries := AddLine(lAxisY2, 'SignalRed', 'Signal red', $FFFF0000);
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
  lPage.XMinValue := 0;
  lPage.XMaxValue := 9;
  AddAxis(lPage, 'Bars', lAxisY);
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lBuff := cBuffTrend1d.Create;
  lBuff.Name := 'BottomBuff1d';
  lBuff.Caption := 'Bottom buffer 1D';
  lBuff.Color := $FF0090D0;
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

  lPage := AddPage(AChart.Model, 'PageOwnX', 'Page_OwnX');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 10;
  AddAxis(lPage, 'OwnX', lAxisY);
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 100;
  lAxisY.UseOwnX := True;
  lAxisY.XMinValue := 50;
  lAxisY.XMaxValue := 150;
  lAxisY.XScale := casLinear;
  lSeries := AddLine(lAxisY, 'OwnXLine', 'Own X line', $FF00FF00);
  lSeries.AddPoint(60, 10);
  lSeries.AddPoint(80, 50);
  lSeries.AddPoint(100, 30);
  lSeries.AddPoint(120, 90);
  lSeries.AddPoint(140, 70);

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
  OglChart1.OnMouseMove := @OglChart1MouseMove;
  OglChart1.OnAfterRender := @OglChart1AfterRender;
  fMouseCoordsText := 'Chart px: (0, 0) | Page: NAN | Axis Val: (X: NAN, Y: NAN)';
  fFpsText := 'Render: 0.00 ms (0.0 FPS)';
  UpdateStatusBar;
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


procedure TForm1.OglChart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lModel: TChartModel;
  lPage: TChartPage;
  lRect, lContentRect: TChartPixelRect;
  lSelectedAxis: TChartAxis;
  lAxisXVal, lAxisYVal: Double;
  lIdx, lInnerIdx: Integer;
  lPageFound: Boolean;
  lPageX, lPageY: Integer;
begin
  lRenderer := TOpenGLChartRenderer(OglChart1.GetRenderer);
  lModel := OglChart1.Model;
  lPageFound := False;
  lAxisXVal := NaN;
  lAxisYVal := NaN;
  lRect.Left := 0;
  lRect.Top := 0;
  lPageX := 0;
  lPageY := 0;

  if Assigned(lRenderer) and Assigned(lModel) then
  begin
    for lIdx := 0 to lModel.ChildCount - 1 do
    begin
      if lModel.Children[lIdx] is TChartPage then
      begin
        lPage := TChartPage(lModel.Children[lIdx]);
        lRect := lRenderer.GetPageRect(lPage);
        if (X >= lRect.Left) and (X <= lRect.Right) and
           (Y >= lRect.Top) and (Y <= lRect.Bottom) then
        begin
          lPageFound := True;
          lPageX := X - lRect.Left;
          lPageY := Y - lRect.Top;
          
          // Ищем выбранную ось или ось выбранного тренда
          lSelectedAxis := nil;
          if OglChart1.SelectedObject is TChartAxis then
            lSelectedAxis := TChartAxis(OglChart1.SelectedObject)
          else if OglChart1.SelectedObject is cTrend then
          begin
            if Assigned(OglChart1.SelectedObject.Parent) and (OglChart1.SelectedObject.Parent is TChartAxis) then
              lSelectedAxis := TChartAxis(OglChart1.SelectedObject.Parent);
          end
          else
          begin
            // Если не выбрана ось, берем первую ось этой страницы
            for lInnerIdx := 0 to lPage.ChildCount - 1 do
              if lPage.Children[lInnerIdx] is TChartAxis then
              begin
                lSelectedAxis := TChartAxis(lPage.Children[lInnerIdx]);
                Break;
              end;
          end;

          lContentRect := lRenderer.GetPageContentRect(lPage);
          if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
             (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
          begin
            lAxisXVal := lRenderer.PixelToXValue(lPage, lSelectedAxis, X, lContentRect.Left, lContentRect.Right);
            lAxisYVal := lRenderer.PixelToAxisValue(lSelectedAxis, Y, lContentRect.Bottom, lContentRect.Top);
          end;
          Break;
        end;
      end;
    end;
  end;

  if not lPageFound then
  begin
    fMouseCoordsText := Format(
      'Chart px: (%d, %d) | Page: NAN (outside page) | Axis Val: (X: NAN, Y: NAN)',
      [X, Y]
    );
  end
  else
  begin
    if IsNaN(lAxisXVal) or IsNaN(lAxisYVal) then
      fMouseCoordsText := Format(
        'Chart px: (%d, %d) | Page px: (%d, %d) | Axis Val: (X: NAN, Y: NAN)',
        [X, Y, lPageX, lPageY]
      )
    else
      fMouseCoordsText := Format(
        'Chart px: (%d, %d) | Page px: (%d, %d) | Axis Val: (X: %.4f, Y: %.4f)',
        [X, Y, lPageX, lPageY, lAxisXVal, lAxisYVal]
      );
  end;
  UpdateStatusBar;
end;

end.