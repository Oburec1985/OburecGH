unit uOglChartVertexEditListener;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Controls, Math, LCLType,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartTrend, uOglChartRenderer, uOglChartChart,
  uOglChartLineHelper;

type
  /// <summary>
  /// Определяет перетаскиваемую часть вершины Безье.
  /// </summary>
  TChartDragPart = (
    cdpPoint, ///< Сама точка (вершина) тренда.
    cdpLeft,  ///< Левый направляющий вектор (левый ус сглаживания).
    cdpRight  ///< Правый направляющий вектор (правый ус сглаживания).
  );
  /// <summary>
  /// Слушатель событий мыши и клавиатуры для интерактивного редактирования вершин Безье трендов (cTrend).
  /// Управляет выделением вершин, перетаскиванием вершин/усов, добавлением (INSERT) и удалением (DELETE).
  /// Изменяет типы вершин по горячим клавишам (1 - угол, 2 - гладкая, 3 - скрытая, T - перебор).
  /// </summary>
  TChartVertexEditListener = class(TChartFrameListener)
  private
    fDragTrend: cTrend;              // Ссылка на тренд, точка которого сейчас перетаскивается.
    fDragPointIdx: Integer;          // Индекс перетаскиваемой вершины.
    fIsDraggingPoint: Boolean;       // Флаг активного перетаскивания вершины или её направляющего вектора.
    fDragPart: TChartDragPart;       // Какая часть вершины перетаскивается.
    fActivePage: TChartPage;         // Страница, на которой расположен редактируемый тренд.
  public
    /// <summary>
    /// Конструктор по умолчанию.
    /// </summary>

    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); override;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); override;
  end;

implementation
{ TChartVertexEditListener }

constructor TChartVertexEditListener.Create;
begin
  inherited Create;
  fDragTrend := nil;
  fDragPointIdx := -1;
  fIsDraggingPoint := False;
  fDragPart := cdpPoint;
  fActivePage := nil;
end;

procedure TChartVertexEditListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

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
  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    // Ищем попадание в вершины тренда для перетаскивания и выделения
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

                        // Проверяем саму вершину
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

  end;

end;

procedure TChartVertexEditListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lContentRect: TChartPixelRect;
  lAxis: TChartAxis;
  lXRange, lYRange: Double;
  lIndex: Integer;
begin
  if not Enabled then Exit;
  if fIsDraggingPoint and Assigned(fDragTrend) and Assigned(fActivePage) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;
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
    end;

  end;

end;

procedure TChartVertexEditListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
  if not Enabled then Exit;
  if (Button = mbLeft) and fIsDraggingPoint then
  begin
    fIsDraggingPoint := False;
    fDragTrend := nil;
    fDragPointIdx := -1;
    fActivePage := nil;
    Handled := True;
  end;

end;

procedure TChartVertexEditListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);

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
  LogToFile('VertexEditListener.KeyDown: Key=' + IntToStr(Key));
  // DELETE (46) и INSERT (45)
  if (Key in [45, 46]) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
    begin
      lTrend := cTrend(lRenderer.SelectedObject);
      // Удаление вершины тренда (DELETE)
      if Key = 46 then
      begin
        for I := 0 to lTrend.BeziePointCount - 1 do
        begin
          if lTrend.BeziePoints[I].Selected then
          begin
            LogToFile('  Deleting point ' + IntToStr(I));
            lTrend.DeleteBeziePoint(I);
            for lNewIdx := 0 to lTrend.BeziePointCount - 1 do
              lTrend.BeziePoints[lNewIdx].Selected := False;
            lControl.Redraw;
            Handled := True;
            Exit;
          end;

        end;

      end

      // Вставка вершины тренда (INSERT)
      else if Key = 45 then
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

procedure TChartVertexEditListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);

var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  I: Integer;
begin
  if not Enabled then Exit;
  // Изменение типа вершины Безье ('1', '2', '3', 'T'/'t')
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

end.

