unit Unit1;

{$mode objfpc}{$H+}
{$codepage cp1251}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  Math, uOglChart, uOglChartBaseObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, uOglChartRenderer, uOglChartTypes, uOglChartDrawObj, ImgList,
  uOglChartTextLabel;

type

  { TForm1 }

  TForm1 = class(TForm)
    ImageList1: TImageList;
    OglChart1: TOglChart;
    Splitter1: TSplitter;
    PanelStatus: TPanel;
    lblMouseCoords: TLabel;
    edtSelectedObject: TEdit;
    edtFps: TEdit;
    PanelRight: TPanel;
    TreeView1: TTreeView;
    PanelLogControls: TPanel;
    lblSelectedAxis: TLabel;
    cbLogY: TCheckBox;
    cbLogX: TCheckBox;
    cbUseShader: TCheckBox;
    btnRefreshTree: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OglChart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure cbLogYChange(Sender: TObject);
    procedure cbLogXChange(Sender: TObject);
    procedure cbUseShaderChange(Sender: TObject);
    procedure TreeView1SelectionChanged(Sender: TObject);
  private
    fUpdatingControls: Boolean;
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
  lblMouseCoords.Caption := fMouseCoordsText;

  lSelText := 'Selected: None';
  if Assigned(OglChart1.SelectedObject) then
  begin
    lSelText := 'Selected: ' + OglChart1.SelectedObject.Name;
    if OglChart1.SelectedObject.Caption <> '' then
      lSelText := lSelText + ' ("' + OglChart1.SelectedObject.Caption + '")';
  end;
  edtSelectedObject.Text := lSelText;

  edtFps.Text := fFpsText;
end;

procedure TForm1.OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
var
  lFps: Double;
  lSelected: TChartBaseObject;
  lAxis: TChartAxis;
  i: Integer;
  lNodeToSelect: TTreeNode;
begin
  if ARenderTimeMs > 0 then
    lFps := 1000.0 / ARenderTimeMs
  else
    lFps := 0;
  fFpsText := Format('Render: %.2f ms (%.1f FPS)', [ARenderTimeMs, lFps]);
  UpdateStatusBar;

  lSelected := TChartBaseObject(OglChart1.SelectedObject);
  lAxis := nil;
  if Assigned(lSelected) then
  begin
    if lSelected is TChartAxis then
      lAxis := TChartAxis(lSelected)
    else if (lSelected is cTrend) and Assigned(lSelected.Parent) and (lSelected.Parent is TChartAxis) then
      lAxis := TChartAxis(lSelected.Parent);
  end;

  fUpdatingControls := True;
  try
    if Assigned(lAxis) then
    begin
      if lblSelectedAxis.Caption <> 'Выбранная ось: ' + lAxis.Name then
      begin
        lblSelectedAxis.Caption := 'Выбранная ось: ' + lAxis.Name;
        cbLogY.Enabled := True;
        cbLogX.Enabled := True;
        cbLogY.Checked := lAxis.Scale = casLog10;
        cbLogX.Checked := lAxis.XScale = casLog10;

        lNodeToSelect := nil;
        for i := 0 to TreeView1.Items.Count - 1 do
        begin
          if TreeView1.Items[i].Data = Pointer(lAxis) then
          begin
            lNodeToSelect := TreeView1.Items[i];
            Break;
          end;
        end;
        if Assigned(lNodeToSelect) and (TreeView1.Selected <> lNodeToSelect) then
          TreeView1.Selected := lNodeToSelect;
      end;
    end
    else
    begin
      if lblSelectedAxis.Caption <> 'Выбранная ось: нет' then
      begin
        lblSelectedAxis.Caption := 'Выбранная ось: нет';
        cbLogY.Enabled := False;
        cbLogX.Enabled := False;
        cbLogY.Checked := False;
        cbLogX.Checked := False;
        if TreeView1.Selected <> nil then
          TreeView1.Selected := nil;
      end;
    end;
  finally
    fUpdatingControls := False;
  end;
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

function AddFlag(APage: cBasePage; ATrend: cBaseTrend; AX: Double; const AText: string): TChartFlagLabel;
var
  lYVal: Double;
begin
  Result := TChartFlagLabel.Create;
  Result.Name := 'Flag_' + ATrend.Name;
  Result.Caption := AText;
  Result.Trend := ATrend;
  Result.WorldX := AX;
  Result.AnchorX := AX;
  Result.Width := 140;
  Result.Height := 30;
  Result.Text := AText;
  Result.IsWorldY := True; // Включаем перемещение по Y вместе с графиком
  if GetTrendValueAtX(ATrend, AX, lYVal) then
    Result.WorldY := lYVal + (cAxis(ATrend.Parent).MaxValue - cAxis(ATrend.Parent).MinValue) * 0.1
  else
    Result.WorldY := 0.0;
  APage.AddChild(Result);
end;

procedure CreateTestChart(AChart: TOglChart);
var
  lPage: cBasePage;
  lAxisY: cAxis;
  lAxisY2: cAxis;
  lSeries: cTrend;
  lBuff: cBuffTrend1d;
  lPerfPage: cBasePage;
  lPerfAxis1D, lPerfAxis2D: cAxis;
  lBuff1D: cBuffTrend1d;
  lBuff2D: cBuffTrend2d;
  i: Integer;
  lVal: Double;
  lArrValues: array of Double;
  lArrPoints: array of TChartPoint;
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

  // Добавляем флаг
  if GetTrendValueAtX(lSeries, 5.0, lVal) then
    AddFlag(lPage, lSeries, 5.0, Format('Trend: %.3f', [lVal]));

  lPage := AddPage(AChart.Model, 'PageSignals', 'Page_Signals');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 9;

  // Ось Y (синяя)
  AddAxis(lPage, 'Signals', lAxisY);
  lAxisY.MinValue := 0.4;
  lAxisY.MaxValue := 0.75;
  lAxisY.Color := $FF0000FF;
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

  // Добавляем флаг на синий сигнал
  if GetTrendValueAtX(lSeries, 3.0, lVal) then
    AddFlag(lPage, lSeries, 3.0, Format('Blue: %.3f', [lVal]));

  // Ось Y (красная)
  AddAxis(lPage, 'Signals2', lAxisY2);
  lAxisY2.MinValue := 0.3;
  lAxisY2.MaxValue := 0.9;
  lAxisY2.Color := $FFFF0000;
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

  // Добавляем флаг на красный сигнал
  if GetTrendValueAtX(lSeries, 6.0, lVal) then
    AddFlag(lPage, lSeries, 6.0, Format('Red: %.3f', [lVal]));

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

  // Страница тестирования производительности с большим объемом точек (100 тысяч точек)
  lPerfPage := AddPage(AChart.Model, 'PagePerf', 'Page_Performance_100k');
  lPerfPage.XMinValue := 0;
  lPerfPage.XMaxValue := 100000;

  // cBuffTrend1d (синий график)
  AddAxis(lPerfPage, 'PerfAxis1D', lPerfAxis1D);
  lPerfAxis1D.MinValue := 0;
  lPerfAxis1D.MaxValue := 1;
  lPerfAxis1D.Color := $FF0000FF;
  
  lBuff1D := cBuffTrend1d.Create;
  lBuff1D.Name := 'Buff1D_100k';
  lBuff1D.Caption := 'cBuffTrend1d (100k pts)';
  lBuff1D.Color := $FF0000FF;
  lBuff1D.X0 := 0;
  lBuff1D.DX := 1;
  SetLength(lArrValues, 100000);
  for i := 0 to 99999 do
  begin
    lArrValues[i] := Sin(i / 1000.0) * 0.4 + 0.5;
  end;
  lBuff1D.AddValues(lArrValues);
  SetLength(lArrValues, 0);
  lPerfAxis1D.AddChild(lBuff1D);

  // cBuffTrend2d (зеленый график)
  AddAxis(lPerfPage, 'PerfAxis2D', lPerfAxis2D);
  lPerfAxis2D.MinValue := 0;
  lPerfAxis2D.MaxValue := 1;
  lPerfAxis2D.Color := $FF00D000;
  
  lBuff2D := cBuffTrend2d.Create;
  lBuff2D.Name := 'Buff2D_100k';
  lBuff2D.Caption := 'cBuffTrend2d (100k pts)';
  lBuff2D.Color := $FF00D000;
  SetLength(lArrPoints, 100000);
  for i := 0 to 99999 do
  begin
    lArrPoints[i].X := i;
    lArrPoints[i].Y := Sin(i / 1000.0) * 0.4 + 0.5;
  end;
  lBuff2D.AddPoints(lArrPoints);
  SetLength(lArrPoints, 0);
  lPerfAxis2D.AddChild(lBuff2D);

  AChart.Redraw;
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnCreate := @FormCreate;
end;

procedure TForm1.FormCreate(Sender: TObject);
  function FindNodeByName(AObject: TChartBaseObject; const AName: string): TChartBaseObject;
  var
    lIndex: Integer;
    lRes: TChartBaseObject;
  begin
    Result := nil;
    if not Assigned(AObject) then Exit;
    if AObject.Name = AName then
    begin
      Result := AObject;
      Exit;
    end;
    for lIndex := 0 to AObject.ChildCount - 1 do
    begin
      lRes := FindNodeByName(AObject.Children[lIndex], AName);
      if Assigned(lRes) then
      begin
        Result := lRes;
        Exit;
      end;
    end;
  end;
var
  lFound: TChartBaseObject;
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
  btnRefreshTree.Visible := True;
  BuildChartTree;

  // Always select PerfAxis1DAxisY on startup for testing zoom isolation
  lFound := FindNodeByName(OglChart1.Model, 'PerfAxis1DAxisY');
  if Assigned(lFound) then
  begin
    OglChart1.SelectedObject := lFound;
    UpdateStatusBar;
  end;
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


procedure TForm1.cbLogYChange(Sender: TObject);
var
  lAxis: TChartAxis;
begin
  if fUpdatingControls then Exit;
  if Assigned(OglChart1.SelectedObject) and (OglChart1.SelectedObject is TChartAxis) then
  begin
    lAxis := TChartAxis(OglChart1.SelectedObject);
    if cbLogY.Checked then
      lAxis.Scale := casLog10
    else
      lAxis.Scale := casLinear;
    OglChart1.Redraw;
    BuildChartTree;
  end;
end;

procedure TForm1.cbLogXChange(Sender: TObject);
var
  lAxis: TChartAxis;
begin
  if fUpdatingControls then Exit;
  if Assigned(OglChart1.SelectedObject) and (OglChart1.SelectedObject is TChartAxis) then
  begin
    lAxis := TChartAxis(OglChart1.SelectedObject);
    if cbLogX.Checked then
      lAxis.XScale := casLog10
    else
      lAxis.XScale := casLinear;
    OglChart1.Redraw;
    BuildChartTree;
  end;
end;

procedure TForm1.cbUseShaderChange(Sender: TObject);
var
  lRenderer: TOpenGLChartRenderer;
begin
  lRenderer := TOpenGLChartRenderer(OglChart1.GetRenderer);
  if Assigned(lRenderer) then
  begin
    lRenderer.UseShader := cbUseShader.Checked;
    OglChart1.Redraw;
  end;
end;

procedure TForm1.TreeView1SelectionChanged(Sender: TObject);
var
  lAxis: TChartAxis;
begin
  fUpdatingControls := True;
  try
    if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) and (TObject(TreeView1.Selected.Data) is TChartAxis) then
    begin
      lAxis := TChartAxis(TreeView1.Selected.Data);
      OglChart1.SelectedObject := lAxis;
      lblSelectedAxis.Caption := 'Выбранная ось: ' + lAxis.Name;
      cbLogY.Enabled := True;
      cbLogX.Enabled := True;
      cbLogY.Checked := lAxis.Scale = casLog10;
      cbLogX.Checked := lAxis.XScale = casLog10;
    end
    else
    begin
      lblSelectedAxis.Caption := 'Выбранная ось: нет';
      cbLogY.Enabled := False;
      cbLogX.Enabled := False;
      cbLogY.Checked := False;
      cbLogX.Checked := False;
    end;
  finally
    fUpdatingControls := False;
  end;
end;



end.
