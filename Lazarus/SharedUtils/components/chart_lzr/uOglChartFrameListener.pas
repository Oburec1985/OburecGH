unit uOglChartFrameListener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, LCLType, Math,
  uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj, uOglChartAxis, uOglChartPage,
  uOglChartTrend, uOglChartRenderer, uOglChartChart;

type
  { TChartFrameListener
    Базовый класс слушателя событий кадра и мыши для OglChart. }
  TChartFrameListener = class(TObject)
  private
    fEnabled: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure FrameStarted(ASender: TObject); virtual;
    procedure FrameEnded(ASender: TObject); virtual;

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); virtual;

    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); virtual;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); virtual;

    property Enabled: Boolean read fEnabled write fEnabled;
  end;

  { TChartSelectListener
    Слушатель для выделения и подсветки объектов графика (страниц, осей) при наведении мыши и кликах. }
  TChartSelectListener = class(TChartFrameListener)
  public
    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); override;
    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); override;
  end;

  TChartDragPart = (cdpPoint, cdpLeft, cdpRight);

  { TChartPanZoomListener
    Слушатель для панорамирования (перетаскивания правой кнопкой мыши) и масштабирования (колесиком мыши). }
  TChartPanZoomListener = class(TChartFrameListener)
  private
    fIsPanning: Boolean;
    fLastX: Integer;
    fLastY: Integer;
    fActivePage: TChartPage;
    fResizingBorder: Integer;
    fMovingPage: Boolean;
    fIsResizing: Boolean;
    fSnapSensitivity: Integer;
    fIsZoomSelecting: Boolean;
    fZoomStartX: Integer;
    fZoomStartY: Integer;
    fDragTrend: cTrend;
    fDragPointIdx: Integer;
    fIsDraggingPoint: Boolean;
    fDragPart: TChartDragPart;
  public
    constructor Create; override;
    property SnapSensitivity: Integer read fSnapSensitivity write fSnapSensitivity;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); override;
  end;

implementation

procedure LogToFile(const AMsg: string);
var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;
end;

{ TChartFrameListener }

constructor TChartFrameListener.Create;
begin
  inherited Create;
  fEnabled := True;
end;

destructor TChartFrameListener.Destroy;
begin
  inherited Destroy;
end;

procedure TChartFrameListener.FrameStarted(ASender: TObject);
begin
end;

procedure TChartFrameListener.FrameEnded(ASender: TObject);
begin
end;

procedure TChartFrameListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);
begin
end;

{ TChartSelectListener }

constructor TChartSelectListener.Create;
begin
  inherited Create;
end;

procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lSelectedAxis: TChartAxis;
  lContentRect: TChartPixelRect;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  I, J, K, lIdx: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
  lHasSelectedPoint: Boolean;
begin
  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    // 1. Проверяем попадание в текстовые метки (оси, значения)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // Не помечаем как Handled, чтобы сработал стандартный текстовый редактор рендера!
      Exit;
    end;

    lModel := TChartModel(lControl.GetModel);
    // 1.5. Проверяем попадание в вертикальную ось Y
    if lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then
    begin
      lRenderer.SelectedObject := lSelectedAxis;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 1.8. Проверяем попадание в вершины тренда (cTrend)
    if Assigned(lModel) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lContentRect := lRenderer.GetPageContentRect(lPage);
              
              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is TChartAxis then
                begin
                  lYAxis := TChartAxis(lPage.Children[I]);
                  for J := 0 to lYAxis.ChildCount - 1 do
                    if lYAxis.Children[J] is cTrend then
                    begin
                      lTrend := cTrend(lYAxis.Children[J]);
                      if lTrend.ShowPoints then
                      begin
                        for K := 0 to lTrend.BeziePointCount - 1 do
                        begin
                          lPoint := lTrend.BeziePoints[K].Point;
                          lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                          lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            // Снимаем выделение со всех вершин всех трендов страницы
                            for lIdx := 0 to lPage.ChildCount - 1 do
                              if lPage.Children[lIdx] is TChartAxis then
                              begin
                                lTempAxis := TChartAxis(lPage.Children[lIdx]);
                                for lInnerIdx := 0 to lTempAxis.ChildCount - 1 do
                                  if lTempAxis.Children[lInnerIdx] is cTrend then
                                  begin
                                    lTempTrend := cTrend(lTempAxis.Children[lInnerIdx]);
                                    for lPointIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                      lTempTrend.BeziePoints[lPointIdx].Selected := False;
                                  end;
                              end;
                            lTrend.BeziePoints[K].Selected := True;
                            lRenderer.SelectedObject := lTrend;
                            lControl.Redraw;
                            Handled := True;
                            Exit;
                          end;
                        end;
                      end;
                    end;
                end;
            end;
          end;
        end;
    end;

    // 2. Проверяем попадание в саму страницу
    lModel := TChartModel(lControl.GetModel);
    if Assigned(lModel) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              // Если до этого был выделен тренд, сначала проверяем, есть ли выделенные вершины
              if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
              begin
                lTrend := cTrend(lRenderer.SelectedObject);
                lHasSelectedPoint := False;
                for K := 0 to lTrend.BeziePointCount - 1 do
                  if lTrend.BeziePoints[K].Selected then
                  begin
                    lHasSelectedPoint := True;
                    Break;
                  end;

                if lHasSelectedPoint then
                begin
                  // Снимаем выделение со всех вершин тренда, но САМ тренд оставляем активным
                  for K := 0 to lTrend.BeziePointCount - 1 do
                    lTrend.BeziePoints[K].Selected := False;
                  lControl.Redraw;
                  Handled := True;
                  Exit;
                end;
              end;

              lRenderer.SelectedObject := lPage;
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end;
    end;

    // Снимаем выделение, если кликнули по пустому месту
    if Assigned(lRenderer.SelectedObject) then
    begin
      lRenderer.SelectedObject := nil;
      lControl.Redraw;
    end;
  end;
end;

procedure TChartSelectListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  lAxis: TChartAxis;
  lPage: TChartPage;
  lContentRect: TChartPixelRect;
  lXRange, lYRange: Double;
  I, lNewIdx: Integer;
  lMousePos: TPoint;
  lMouseX, lMouseY: Integer;
begin
  if not Enabled then Exit;

  LogToFile('SelectListener.KeyDown: Key=' + IntToStr(Key));

  if (Key in [45, 46]) and Supports(ASender, IChartControl, lControl) then // 45 = VK_INSERT, 46 = VK_DELETE
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) then
    begin
      if Assigned(lRenderer.SelectedObject) then
        LogToFile('  SelectedObject is ' + lRenderer.SelectedObject.ClassName + ' (Name: ' + lRenderer.SelectedObject.Name + ')')
      else
        LogToFile('  SelectedObject is nil');

      if (lRenderer.SelectedObject is cTrend) then
      begin
        lTrend := cTrend(lRenderer.SelectedObject);
        if Key = 46 then // VK_DELETE
        begin
          for I := 0 to lTrend.BeziePointCount - 1 do
          begin
            if lTrend.BeziePoints[I].Selected then
            begin
              LogToFile('  Deleting point ' + IntToStr(I));
              lTrend.DeleteBeziePoint(I);
              // Снимаем выделение со всех оставшихся вершин тренда
              for lNewIdx := 0 to lTrend.BeziePointCount - 1 do
                lTrend.BeziePoints[lNewIdx].Selected := False;
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end
        else if Key = 45 then // VK_INSERT
        begin
          if Assigned(lTrend.Parent) and (lTrend.Parent is TChartAxis) then
          begin
            lAxis := TChartAxis(lTrend.Parent);
            if Assigned(lAxis.Parent) and (lAxis.Parent is TChartPage) then
            begin
              lPage := TChartPage(lAxis.Parent);
              lContentRect := lRenderer.GetPageContentRect(lPage);
              
              lMousePos := TControl(ASender).ScreenToClient(Mouse.CursorPos);
              lMouseX := lMousePos.X;
              lMouseY := lMousePos.Y;

              lXRange := lRenderer.PixelToXValue(lPage, nil, lMouseX, lContentRect.Left, lContentRect.Right);
              lYRange := lRenderer.PixelToAxisValue(lAxis, lMouseY, lContentRect.Bottom, lContentRect.Top);

              LogToFile('  Inserting point at values X=' + FloatToStr(lXRange) + ', Y=' + FloatToStr(lYRange));

              lTrend.InsertBeziePoint(lXRange, lYRange, bptCorner);
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TChartSelectListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);
var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  I: Integer;
begin
  if not Enabled then Exit;

  if (Key in ['1', '2', '3', 't', 'T']) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
    begin
      lTrend := cTrend(lRenderer.SelectedObject);
      for I := 0 to lTrend.BeziePointCount - 1 do
      begin
        if lTrend.BeziePoints[I].Selected then
        begin
          case Key of
            '1': lTrend.BeziePoints[I].PointType := bptCorner;
            '2': lTrend.BeziePoints[I].PointType := bptSmooth;
            '3': lTrend.BeziePoints[I].PointType := bptNull;
            't', 'T': 
              begin
                case lTrend.BeziePoints[I].PointType of
                  bptCorner: lTrend.BeziePoints[I].PointType := bptSmooth;
                  bptSmooth: lTrend.BeziePoints[I].PointType := bptNull;
                  bptNull: lTrend.BeziePoints[I].PointType := bptCorner;
                end;
              end;
          end;
          lTrend.GenerateSplinePoints;
          lControl.Redraw;
          Handled := True;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lNewHover: TChartBaseObject;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    lNewHover := nil;

    // 1. Проверяем попадание в текстовые метки
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lNewHover := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lNewHover := lHit.Page;
    end;

    // 2. Если метка не найдена, проверяем саму страницу
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                lNewHover := lPage;
                Break;
              end;
            end;
          end;
      end;
    end;

    if lRenderer.HoveredObject <> lNewHover then
    begin
      lRenderer.HoveredObject := lNewHover;
      lControl.Redraw;
    end;
  end;
end;

procedure FitPageZoom(APage: TChartPage);
var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lSpan: Double;

  procedure ProcessObject(AObject: TChartBaseObject; ACurrentAxis: TChartAxis);
  var
    lIndex, lPtIdx: Integer;
    lLine: TChartLineSeries;
    lBuff1d: cBuffTrend1d;
    lAxis: TChartAxis;
    lAxisMinY, lAxisMaxY: Double;
    lAxisMinX, lAxisMaxX: Double;
    lHasAxisY, lHasAxisX: Boolean;
    lSpan: Double;
  begin
    if not Assigned(AObject) then Exit;

    lAxis := ACurrentAxis;
    if AObject is TChartAxis then
    begin
      lAxis := TChartAxis(AObject);
      lAxisMinY := 1E30;
      lAxisMaxY := -1E30;
      lAxisMinX := 1E30;
      lAxisMaxX := -1E30;
      lHasAxisY := False;
      lHasAxisX := False;

      for lIndex := 0 to lAxis.ChildCount - 1 do
      begin
        if lAxis.Children[lIndex] is TChartLineSeries then
        begin
          lLine := TChartLineSeries(lAxis.Children[lIndex]);
          for lPtIdx := 0 to lLine.PointCount - 1 do
          begin
            lAxisMinY := Min(lAxisMinY, lLine.Points[lPtIdx].Y);
            lAxisMaxY := Max(lAxisMaxY, lLine.Points[lPtIdx].Y);
            lHasAxisY := True;

            if lAxis.UseOwnX then
            begin
              lAxisMinX := Min(lAxisMinX, lLine.Points[lPtIdx].X);
              lAxisMaxX := Max(lAxisMaxX, lLine.Points[lPtIdx].X);
              lHasAxisX := True;
            end
            else
            begin
              lPageMinX := Min(lPageMinX, lLine.Points[lPtIdx].X);
              lPageMaxX := Max(lPageMaxX, lLine.Points[lPtIdx].X);
              lHasPageX := True;
            end;
          end;
        end
        else if lAxis.Children[lIndex] is cBuffTrend1d then
        begin
          lBuff1d := cBuffTrend1d(lAxis.Children[lIndex]);
          for lPtIdx := 0 to lBuff1d.Count - 1 do
          begin
            lAxisMinY := Min(lAxisMinY, lBuff1d.Values[lPtIdx]);
            lAxisMaxY := Max(lAxisMaxY, lBuff1d.Values[lPtIdx]);
            lHasAxisY := True;

            if lAxis.UseOwnX then
            begin
              lAxisMinX := Min(lAxisMinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lAxisMaxX := Max(lAxisMaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lHasAxisX := True;
            end
            else
            begin
              lPageMinX := Min(lPageMinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lPageMaxX := Max(lPageMaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lHasPageX := True;
            end;
          end;
        end;
      end;

      if lHasAxisY then
      begin
        if Abs(lAxisMaxY - lAxisMinY) < 1E-9 then
        begin
          lAxisMinY := lAxisMinY - 1.0;
          lAxisMaxY := lAxisMaxY + 1.0;
        end
        else
        begin
          lSpan := lAxisMaxY - lAxisMinY;
          lAxisMinY := lAxisMinY - lSpan * 0.1;
          lAxisMaxY := lAxisMaxY + lSpan * 0.1;
        end;
        lAxis.MinValue := lAxisMinY;
        lAxis.MaxValue := lAxisMaxY;
      end;

      if lAxis.UseOwnX and lHasAxisX then
      begin
        if Abs(lAxisMaxX - lAxisMinX) < 1E-9 then
        begin
          lAxisMinX := lAxisMinX - 1.0;
          lAxisMaxX := lAxisMaxX + 1.0;
        end
        else
        begin
          lSpan := lAxisMaxX - lAxisMinX;
          lAxisMinX := lAxisMinX - lSpan * 0.1;
          lAxisMaxX := lAxisMaxX + lSpan * 0.1;
        end;
        lAxis.XMinValue := lAxisMinX;
        lAxis.XMaxValue := lAxisMaxX;
      end;
    end;

    for lIndex := 0 to AObject.ChildCount - 1 do
      if not (AObject is TChartAxis) or not (AObject.Children[lIndex] is TChartSeries) then
        ProcessObject(AObject.Children[lIndex], lAxis);
  end;

var
  lIdx: Integer;
begin
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;

  for lIdx := 0 to APage.ChildCount - 1 do
    ProcessObject(APage.Children[lIdx], nil);

  if lHasPageX then
  begin
    if Abs(lPageMaxX - lPageMinX) < 1E-9 then
    begin
      lPageMinX := lPageMinX - 1.0;
      lPageMaxX := lPageMaxX + 1.0;
    end
    else
    begin
      lSpan := lPageMaxX - lPageMinX;
      lPageMinX := lPageMinX - lSpan * 0.1;
      lPageMaxX := lPageMaxX + lSpan * 0.1;
    end;
    APage.XMinValue := lPageMinX;
    APage.XMaxValue := lPageMaxX;
  end;
end;

{ TChartPanZoomListener }

constructor TChartPanZoomListener.Create;
begin
  inherited Create;
  fIsPanning := False;
  fActivePage := nil;
  fResizingBorder := 0;
  fMovingPage := False;
  fIsResizing := False;
  fSnapSensitivity := 5;
  fIsZoomSelecting := False;
  fZoomStartX := 0;
  fZoomStartY := 0;
  fIsDraggingPoint := False;
  fDragTrend := nil;
  fDragPointIdx := -1;
  fDragPart := cdpPoint;
end;

procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  lXLeft, lYLeft, lXRight, lYRight: Single;
  J, K, lIdx, I: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if Button = mbLeft then
    begin
      // 0.5. Проверяем попадание в вершины тренда для перетаскивания (mbLeft)
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lContentRect := lRenderer.GetPageContentRect(lPage);
              
              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is TChartAxis then
                begin
                  lYAxis := TChartAxis(lPage.Children[I]);
                  for J := 0 to lYAxis.ChildCount - 1 do
                    if lYAxis.Children[J] is cTrend then
                    begin
                      lTrend := cTrend(lYAxis.Children[J]);
                      if lTrend.ShowPoints then
                      begin
                        for K := 0 to lTrend.BeziePointCount - 1 do
                        begin
                          lPoint := lTrend.BeziePoints[K].Point;
                          lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                          lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                          // Если вершина сглаженная и выделена, сначала проверяем её направляющие векторы (усы)
                          if (lTrend.BeziePoints[K].PointType = bptSmooth) and lTrend.BeziePoints[K].Selected then
                          begin
                            lXLeft := lRenderer.XValueToPixel(lPage, lYAxis, lTrend.BeziePoints[K].Left.X, lContentRect.Left, lContentRect.Right);
                            lYLeft := lRenderer.AxisValueToPixel(lYAxis, lTrend.BeziePoints[K].Left.Y, lContentRect.Bottom, lContentRect.Top);
                            lXRight := lRenderer.XValueToPixel(lPage, lYAxis, lTrend.BeziePoints[K].Right.X, lContentRect.Left, lContentRect.Right);
                            lYRight := lRenderer.AxisValueToPixel(lYAxis, lTrend.BeziePoints[K].Right.Y, lContentRect.Bottom, lContentRect.Top);

                            if (Abs(X - lXLeft) <= 6) and (Abs(Y - lYLeft) <= 6) then
                            begin
                              fIsDraggingPoint := True;
                              fDragTrend := lTrend;
                              fDragPointIdx := K;
                              fDragPart := cdpLeft;
                              fActivePage := lPage;
                              Handled := True;
                              Exit;
                            end;

                            if (Abs(X - lXRight) <= 6) and (Abs(Y - lYRight) <= 6) then
                            begin
                              fIsDraggingPoint := True;
                              fDragTrend := lTrend;
                              fDragPointIdx := K;
                              fDragPart := cdpRight;
                              fActivePage := lPage;
                              Handled := True;
                              Exit;
                            end;
                          end;

                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            fIsDraggingPoint := True;
                            fDragTrend := lTrend;
                            fDragPointIdx := K;
                            fDragPart := cdpPoint;
                            fActivePage := lPage;

                            // Снимаем выделение со всех вершин всех трендов страницы
                            for lIdx := 0 to lPage.ChildCount - 1 do
                              if lPage.Children[lIdx] is TChartAxis then
                              begin
                                lTempAxis := TChartAxis(lPage.Children[lIdx]);
                                for lInnerIdx := 0 to lTempAxis.ChildCount - 1 do
                                  if lTempAxis.Children[lInnerIdx] is cTrend then
                                  begin
                                    lTempTrend := cTrend(lTempAxis.Children[lInnerIdx]);
                                    for lPointIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                      lTempTrend.BeziePoints[lPointIdx].Selected := False;
                                  end;
                              end;
                            lTrend.BeziePoints[K].Selected := True;
                            lRenderer.SelectedObject := lTrend;
                            lControl.Redraw;
                            Handled := True;
                            Exit;
                          end;
                        end;
                      end;
                    end;
                end;
            end;
          end;
        end;

      // 1. Изменение размеров выделенной страницы
      if (fResizingBorder > 0) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
      begin
        lPage := TChartPage(lRenderer.SelectedObject);
        if not lPage.Locked then
        begin
          fIsResizing := True;
          fActivePage := lPage;

          for lInnerIndex := 0 to lModel.ChildCount - 1 do
            if lModel.Children[lInnerIndex] is TChartPage then
              TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

          fLastX := X;
          fLastY := Y;
          Handled := True;
          Exit;
        end;
      end;

      // 2. Если зажат Ctrl, то это режим зума по рамке (только внутри plot area)
      if ssCtrl in Shift then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                lContentRect := lRenderer.GetPageContentRect(lPage);
                if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                   (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
                begin
                  // Клик внутри области построения - начинаем выделение зума
                  fIsZoomSelecting := True;
                  fZoomStartX := X;
                  fZoomStartY := Y;
                  fActivePage := lPage;
                  Handled := True;
                  Exit;
                end;
              end;
            end;
          end;
      end;

      // 3. Если зажат Shift, то это режим перемещения страницы
      if ssShift in Shift then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                fMovingPage := True;
                fActivePage := lPage;

                for lInnerIndex := 0 to lModel.ChildCount - 1 do
                  if lModel.Children[lInnerIndex] is TChartPage then
                    TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

                fLastX := X;
                fLastY := Y;
                TControl(ASender).Cursor := crSizeAll;
                Handled := True;
                Exit;
              end;
            end;
          end;
      end;
    end;

    if (Button = mbRight) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              fIsPanning := True;
              fLastX := X;
              fLastY := Y;
              fActivePage := lPage;
              Handled := True;
              Exit;
            end;
          end;
        end;
    end;
  end;
end;

procedure TChartPanZoomListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPageRect: TChartPixelRect;
  lWidth, lHeight: Single;
  lXRange, lYRange: Double;
  dX, dY: Integer;
  dValX, dValY: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
  lPage, lTempPage: TChartPage;
  lRect: TChartFloatRect;
  lTargetVal: Integer;
  lTargetLeft, lTargetTop, lTargetRight, lTargetBottom: Integer;
  lSnappedLeft, lSnappedRight, lSnappedTop, lSnappedBottom: Integer;
  lPageWidth, lPageHeight: Integer;
  lSelRect: TChartPixelRect;
  lContentRect: TChartPixelRect;

  function SnapX(APixelX: Integer; AExcludePage: TChartPage; AMaxDiff: Integer): Integer;
  var
    lIdx: Integer;
    lOtherPage: TChartPage;
    lOtherRect: TChartPixelRect;
  begin
    Result := APixelX;
    for lIdx := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIdx] is TChartPage then
      begin
        lOtherPage := TChartPage(lModel.Children[lIdx]);
        if lOtherPage <> AExcludePage then
        begin
          lOtherRect := lRenderer.GetPageRect(lOtherPage);
          if Abs(APixelX - lOtherRect.Left) <= AMaxDiff then
          begin
            Result := lOtherRect.Left;
            Exit;
          end;
          if Abs(APixelX - lOtherRect.Right) <= AMaxDiff then
          begin
            Result := lOtherRect.Right;
            Exit;
          end;
        end;
      end;
    if Abs(APixelX - Round(lModel.PageArea.Left * lWidth)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Left * lWidth)
    else if Abs(APixelX - Round(lModel.PageArea.Right * lWidth)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Right * lWidth);
  end;

  function SnapY(APixelY: Integer; AExcludePage: TChartPage; AMaxDiff: Integer): Integer;
  var
    lIdx: Integer;
    lOtherPage: TChartPage;
    lOtherRect: TChartPixelRect;
  begin
    Result := APixelY;
    for lIdx := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIdx] is TChartPage then
      begin
        lOtherPage := TChartPage(lModel.Children[lIdx]);
        if lOtherPage <> AExcludePage then
        begin
          lOtherRect := lRenderer.GetPageRect(lOtherPage);
          if Abs(APixelY - lOtherRect.Top) <= AMaxDiff then
          begin
            Result := lOtherRect.Top;
            Exit;
          end;
          if Abs(APixelY - lOtherRect.Bottom) <= AMaxDiff then
          begin
            Result := lOtherRect.Bottom;
            Exit;
          end;
        end;
      end;
    if Abs(APixelY - Round(lModel.PageArea.Top * lHeight)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Top * lHeight)
    else if Abs(APixelY - Round(lModel.PageArea.Bottom * lHeight)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Bottom * lHeight);
  end;

begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    lWidth := Max(1.0, TControl(ASender).Width);
    lHeight := Max(1.0, TControl(ASender).Height);

    // 0.2. Состояние перетаскивания вершины тренда
    if fIsDraggingPoint and Assigned(fDragTrend) and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lAxis := nil;
      if Assigned(fDragTrend.Parent) and (fDragTrend.Parent is TChartAxis) then
        lAxis := TChartAxis(fDragTrend.Parent);
      if not Assigned(lAxis) then
      begin
        for lIndex := 0 to fActivePage.ChildCount - 1 do
          if fActivePage.Children[lIndex] is TChartAxis then
          begin
            lAxis := TChartAxis(fActivePage.Children[lIndex]);
            Break;
          end;
      end;

      if Assigned(lAxis) then
      begin
        lXRange := lRenderer.PixelToXValue(fActivePage, nil, X, lContentRect.Left, lContentRect.Right);
        lYRange := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);

        if lXRange < fActivePage.XMinValue then lXRange := fActivePage.XMinValue;
        if lXRange > fActivePage.XMaxValue then lXRange := fActivePage.XMaxValue;

        if lYRange < lAxis.MinValue then lYRange := lAxis.MinValue;
        if lYRange > lAxis.MaxValue then lYRange := lAxis.MaxValue;

        case fDragPart of
          cdpPoint: fDragTrend.UpdateBeziePoint(fDragPointIdx, lXRange, lYRange);
          cdpLeft: fDragTrend.UpdateBezieLeft(fDragPointIdx, lXRange, lYRange);
          cdpRight: fDragTrend.UpdateBezieRight(fDragPointIdx, lXRange, lYRange);
        end;
        lControl.Redraw;
        Handled := True;
        Exit;
      end;
    end;

    // 0. Состояние выделения области зумирования (Ctrl + Drag)
    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lSelRect.Left := Max(lContentRect.Left, Min(fZoomStartX, X));
      lSelRect.Right := Min(lContentRect.Right, Max(fZoomStartX, X));
      lSelRect.Top := Max(lContentRect.Top, Min(fZoomStartY, Y));
      lSelRect.Bottom := Min(lContentRect.Bottom, Max(fZoomStartY, Y));

      lRenderer.SelectionRectActive := True;
      lRenderer.SelectionRect := lSelRect;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 1. Состояние перетаскивания изменения размеров границы страницы
    if fIsResizing and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;

      lPageRect := lRenderer.GetPageRect(fActivePage);
      lRect := fActivePage.FloatRect;

      case fResizingBorder of
        1: // Левая граница
          begin
            lTargetVal := SnapX(lPageRect.Left + dX, fActivePage, fSnapSensitivity);
            lRect.Left := Min(lRect.Right - 0.05, lTargetVal / lWidth);
          end;
        2: // Правая граница
          begin
            lTargetVal := SnapX(lPageRect.Right + dX, fActivePage, fSnapSensitivity);
            lRect.Right := Max(lRect.Left + 0.05, lTargetVal / lWidth);
          end;
        3: // Верхняя граница
          begin
            lTargetVal := SnapY(lPageRect.Top + dY, fActivePage, fSnapSensitivity);
            lRect.Top := Min(lRect.Bottom - 0.05, lTargetVal / lHeight);
          end;
        4: // Нижняя граница
          begin
            lTargetVal := SnapY(lPageRect.Bottom + dY, fActivePage, fSnapSensitivity);
            lRect.Bottom := Max(lRect.Top + 0.05, lTargetVal / lHeight);
          end;
      end;
      fActivePage.FloatRect := lRect;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 2. Состояние перемещения страницы (с зажатым Ctrl)
    if fMovingPage and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;

      lPageRect := lRenderer.GetPageRect(fActivePage);
      lTargetLeft := lPageRect.Left + dX;
      lTargetTop := lPageRect.Top + dY;

      // Примагничивание по X (левая или правая граница)
      lSnappedLeft := SnapX(lTargetLeft, fActivePage, fSnapSensitivity);
      if lSnappedLeft <> lTargetLeft then
        lTargetLeft := lSnappedLeft
      else
      begin
        lTargetRight := lPageRect.Right + dX;
        lSnappedRight := SnapX(lTargetRight, fActivePage, fSnapSensitivity);
        if lSnappedRight <> lTargetRight then
          lTargetLeft := lSnappedRight - (lPageRect.Right - lPageRect.Left);
      end;

      // Примагничивание по Y (верхняя или нижняя граница)
      lSnappedTop := SnapY(lTargetTop, fActivePage, fSnapSensitivity);
      if lSnappedTop <> lTargetTop then
        lTargetTop := lSnappedTop
      else
      begin
        lTargetBottom := lPageRect.Bottom + dY;
        lSnappedBottom := SnapY(lTargetBottom, fActivePage, fSnapSensitivity);
        if lSnappedBottom <> lTargetBottom then
          lTargetTop := lSnappedBottom - (lPageRect.Bottom - lPageRect.Top);
      end;

      lPageWidth := lPageRect.Right - lPageRect.Left;
      lPageHeight := lPageRect.Bottom - lPageRect.Top;

      lRect.Left := lTargetLeft / lWidth;
      lRect.Right := (lTargetLeft + lPageWidth) / lWidth;
      lRect.Top := lTargetTop / lHeight;
      lRect.Bottom := (lTargetTop + lPageHeight) / lHeight;

      fActivePage.FloatRect := lRect;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 3. Состояние обычного панорамирования графика правой кнопкой мыши
    if fIsPanning and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lWidth := Max(1.0, lContentRect.Right - lContentRect.Left);
      lHeight := Max(1.0, lContentRect.Bottom - lContentRect.Top);

      dX := X - fLastX;
      dY := Y - fLastY;

      lXRange := fActivePage.XMaxValue - fActivePage.XMinValue;
      dValX := (dX / lWidth) * lXRange;
      fActivePage.XMinValue := fActivePage.XMinValue - dValX;
      fActivePage.XMaxValue := fActivePage.XMaxValue - dValX;

      for lIndex := 0 to fActivePage.ChildCount - 1 do
        if fActivePage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(fActivePage.Children[lIndex]);
          lYRange := lAxis.MaxValue - lAxis.MinValue;
          dValY := (dY / lHeight) * lYRange;
          lAxis.MinValue := lAxis.MinValue + dValY;
          lAxis.MaxValue := lAxis.MaxValue + dValY;
        end;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 4. Обычное движение мыши: меняем курсор при наведении на границы выделенной страницы
    if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
    begin
      lPage := TChartPage(lRenderer.SelectedObject);
      lPageRect := lRenderer.GetPageRect(lPage);

      fResizingBorder := 0;
      if (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
      begin
        if Abs(X - lPageRect.Left) <= 6 then
          fResizingBorder := 1
        else if Abs(X - lPageRect.Right) <= 6 then
          fResizingBorder := 2;
      end;
      
      if (fResizingBorder = 0) and (X >= lPageRect.Left) and (X <= lPageRect.Right) then
      begin
        if Abs(Y - lPageRect.Top) <= 6 then
          fResizingBorder := 3
        else if Abs(Y - lPageRect.Bottom) <= 6 then
          fResizingBorder := 4;
      end;

      if fResizingBorder in [1, 2] then
        TControl(ASender).Cursor := crSizeWE
      else if fResizingBorder in [3, 4] then
        TControl(ASender).Cursor := crSizeNS
      else if ssShift in Shift then
      begin
        // Если курсор внутри выделенной страницы с зажатым Shift
        if not TChartPage(lRenderer.SelectedObject).Locked and
           (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          TControl(ASender).Cursor := crSizeAll
        else
          TControl(ASender).Cursor := crDefault;
      end
      else
        TControl(ASender).Cursor := crDefault;
    end
    else
    begin
      // Если выделенной страницы нет, но зажат Shift, меняем курсор над любой незаблокированной страницей
      lPage := nil;
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lTempPage := TChartPage(lModel.Children[lIndex]);
          if not lTempPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lTempPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lPage := lTempPage;
              Break;
            end;
          end;
        end;

      if Assigned(lPage) and (ssShift in Shift) then
        TControl(ASender).Cursor := crSizeAll
      else
        TControl(ASender).Cursor := crDefault;
    end;
  end;
end;

procedure TChartPanZoomListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lAxis: TChartAxis;
  NewXMin, NewXMax, NewYMin, NewYMax: Double;
  lSelRect: TChartPixelRect;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lRenderer.SelectionRectActive := False;
      fIsZoomSelecting := False;

      // 1. Полный масштаб при движении влево и вверх
      if (X < fZoomStartX) and (Y < fZoomStartY) then
      begin
        FitPageZoom(fActivePage);
        lControl.Redraw;
        Handled := True;
      end
      // 2. Приближение при движении вправо и вниз (размер рамки должен быть больше 2 пикселей во избежание случайных зумов при кликах)
      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then
      begin
        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        
        lSelRect.Left := Max(lContentRect.Left, fZoomStartX);
        lSelRect.Right := Min(lContentRect.Right, X);
        lSelRect.Top := Max(lContentRect.Top, fZoomStartY);
        lSelRect.Bottom := Min(lContentRect.Bottom, Y);

        if (lSelRect.Right > lSelRect.Left) and (lSelRect.Bottom > lSelRect.Top) then
        begin
          // Зум по X
          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
          NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
          fActivePage.XMinValue := NewXMin;
          fActivePage.XMaxValue := NewXMax;

          // Зум по осям Y
          for lIndex := 0 to fActivePage.ChildCount - 1 do
            if fActivePage.Children[lIndex] is TChartAxis then
            begin
              lAxis := TChartAxis(fActivePage.Children[lIndex]);
              
              if lAxis.UseOwnX then
              begin
                NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                lAxis.XMinValue := NewXMin;
                lAxis.XMaxValue := NewXMax;
              end;

              NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
              NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
              lAxis.MinValue := NewYMin;
              lAxis.MaxValue := NewYMax;
            end;

          lControl.Redraw;
          Handled := True;
        end;
      end
      else
      begin
        lControl.Redraw;
        Handled := True;
      end;
      
      fActivePage := nil;
      Exit;
    end;

    if Button = mbLeft then
    begin
      if fIsDraggingPoint then
      begin
        fIsDraggingPoint := False;
        fDragTrend := nil;
        fDragPointIdx := -1;
        fActivePage := nil;
        Handled := True;
      end;

      if fIsResizing or fMovingPage then
      begin
        fIsResizing := False;
        fMovingPage := False;
        fActivePage := nil;
        fResizingBorder := 0;
        TControl(ASender).Cursor := crDefault;
        Handled := True;
      end;
    end;

    if Button = mbRight then
    begin
      if fIsPanning then
      begin
        fIsPanning := False;
        fActivePage := nil;
        Handled := True;
      end;
    end;
  end;
end;

procedure TChartPanZoomListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lContentRect: TChartPixelRect;
  lZoomFactor: Double;
  lMouseValX: Double;
  lMouseValY: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    // Находим страницу под мышкой для масштабирования
    lPage := nil;
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[lIndex]));
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          Break;
        end;
      end;

    if Assigned(lPage) and not lPage.Locked then
    begin
      lContentRect := lRenderer.GetPageContentRect(lPage);
      if WheelDelta < 0 then
        lZoomFactor := 1.1
      else
        lZoomFactor := 1.0 / 1.1;

      // Масштабирование по оси X относительно курсора мыши
      lMouseValX := lRenderer.PixelToXValue(lPage, nil, X, lContentRect.Left, lContentRect.Right);
      lPage.XMinValue := lMouseValX - (lMouseValX - lPage.XMinValue) * lZoomFactor;
      lPage.XMaxValue := lMouseValX + (lPage.XMaxValue - lMouseValX) * lZoomFactor;

      // Масштабирование по осям Y относительно курсора мыши
      for lIndex := 0 to lPage.ChildCount - 1 do
        if lPage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(lPage.Children[lIndex]);
          lMouseValY := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);
          lAxis.MinValue := lMouseValY - (lMouseValY - lAxis.MinValue) * lZoomFactor;
          lAxis.MaxValue := lMouseValY + (lAxis.MaxValue - lMouseValY) * lZoomFactor;
        end;

      lControl.Redraw;
      Handled := True;
    end;
  end;
end;

end.
