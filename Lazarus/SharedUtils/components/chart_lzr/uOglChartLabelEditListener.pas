unit uOglChartLabelEditListener;
{
  Модуль uOglChartLabelEditListener
  Описание: Слушатель клавиатуры и мыши для редактирования текста меток в реальном времени.
}
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Controls, Math,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartTrend, uOglChartRenderer, uOglChartChart,
  uOglChartTextLabel;

type
  /// <summary>
  /// Слушатель событий мыши для выделения, перетаскивания, изменения размеров текстовых меток (TChartTextLabel, TChartFlagLabel)
  /// и автоматического бесконфликтного размещения флагов.
  /// </summary>
  TChartLabelEditListener = class(TChartFrameListener)
  private
    fIsDraggingLabel: Boolean;       // Флаг активного перетаскивания/ресайза текстовой метки.
    fDragLabel: TChartTextLabel;     // Ссылка на перетаскиваемую метку.
    fDragLabelBorder: Integer;       // 0 - drag, 3 - right, 4 - bottom, 5 - corner.
    fActivePage: TChartPage;         // Активная страница.
    fLastX: Integer;
    fLastY: Integer;
  public
    /// <summary>
    /// Конструктор по умолчанию.
    /// </summary>

    constructor Create; override;

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;

    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;

    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
  end;

function GetTextLabelPixelRect(ALabel: TChartTextLabel; ARenderer: TOpenGLChartRenderer; APage: TChartPage): TChartPixelRect;

procedure SortFlagsOnPage(APage: TChartPage; ARenderer: TOpenGLChartRenderer);

implementation

function GetTextLabelPixelRect(ALabel: TChartTextLabel; ARenderer: TOpenGLChartRenderer; APage: TChartPage): TChartPixelRect;

var
  lPageRect, lContentRect: TChartPixelRect;
  lX, lY: Single;
  lPageWidth, lPageHeight: Integer;
begin
  lPageRect := ARenderer.GetPageRect(APage);
  lContentRect := ARenderer.GetPageContentRect(APage);
  lPageWidth := lPageRect.Right - lPageRect.Left;
  lPageHeight := lPageRect.Bottom - lPageRect.Top;
  // Вычисляем X
  if ALabel.IsWorldX then
  begin
    lX := ARenderer.XValueToPixel(APage, nil, ALabel.WorldX, lContentRect.Left, lContentRect.Right);
    Result.Left := Round(lX);
    Result.Right := Result.Left + ALabel.Width;
  end

  else
  begin
    Result.Left := lContentRect.Left + Round(ALabel.FloatRect.Left * (lContentRect.Right - lContentRect.Left));
    Result.Right := lContentRect.Left + Round(ALabel.FloatRect.Right * (lContentRect.Right - lContentRect.Left));
  end;

  // Вычисляем Y
  if ALabel.IsWorldY and Assigned(ALabel.Axis) then
  begin
    lY := ARenderer.AxisValueToPixel(ALabel.Axis, ALabel.WorldY, lContentRect.Bottom, lContentRect.Top);
    Result.Top := Round(lY);
    Result.Bottom := Result.Top + ALabel.Height;
  end

  else
  begin
    Result.Top := lContentRect.Top + Round(ALabel.FloatRect.Top * (lContentRect.Bottom - lContentRect.Top));
    Result.Bottom := lContentRect.Top + Round(ALabel.FloatRect.Bottom * (lContentRect.Bottom - lContentRect.Top));
  end;

end;

procedure SortFlagsOnPage(APage: TChartPage; ARenderer: TOpenGLChartRenderer);

var
  lFlags: TList;
  lContentRect: TChartPixelRect;
  I, J, K: Integer;
  lFlag, lFlag2: TChartFlagLabel;
  lPtX: Single;
  lX1, lX2: Single;
  lGroup: TList;
  lGroups: TList;
  lAdded: Boolean;
  lAxis: TChartAxis;
  lYVal: Double;
  lTargetY: Single;
begin
  if not Assigned(APage) or not Assigned(ARenderer) then Exit;
  lContentRect := ARenderer.GetPageContentRect(APage);
  lFlags := TList.Create;
  lGroups := TList.Create;
  try
    // 1. Собираем все видимые флаги
    for I := 0 to APage.ChildCount - 1 do
      if APage.Children[I] is TChartFlagLabel then
        lFlags.Add(APage.Children[I]);
    if lFlags.Count = 0 then Exit;
    // 2. Сортируем список флагов по координате привязки AnchorX (слева направо)
    for I := 0 to lFlags.Count - 2 do
      for J := I + 1 to lFlags.Count - 1 do
      begin
        if TChartFlagLabel(lFlags[I]).AnchorX > TChartFlagLabel(lFlags[J]).AnchorX then
        begin
          lFlag := TChartFlagLabel(lFlags[I]);
          lFlags[I] := lFlags[J];
          lFlags[J] := lFlag;
        end;

      end;

    // 3. Группируем флаги по близости координаты AnchorX на экране (порог 60 пикселей)
    for I := 0 to lFlags.Count - 1 do
    begin
      lFlag := TChartFlagLabel(lFlags[I]);
      lPtX := ARenderer.XValueToPixel(APage, nil, lFlag.AnchorX, lContentRect.Left, lContentRect.Right);
      lAdded := False;
      for J := 0 to lGroups.Count - 1 do
      begin
        lGroup := TList(lGroups[J]);
        lFlag2 := TChartFlagLabel(lGroup[lGroup.Count - 1]);
        lX2 := ARenderer.XValueToPixel(APage, nil, lFlag2.AnchorX, lContentRect.Left, lContentRect.Right);
        if Abs(lPtX - lX2) < 60.0 then
        begin
          lGroup.Add(lFlag);
          lAdded := True;
          Break;
        end;

      end;

      if not lAdded then
      begin
        lGroup := TList.Create;
        lGroup.Add(lFlag);
        lGroups.Add(lGroup);
      end;

    end;

    // 4. Для каждой группы выстраиваем флаги стопкой по вертикали
    for I := 0 to lGroups.Count - 1 do
    begin
      lGroup := TList(lGroups[I]);
      // Сортируем внутри группы по значению Y-привязки на графике (сверху вниз)
      for J := 0 to lGroup.Count - 2 do
        for K := J + 1 to lGroup.Count - 1 do
        begin
          lFlag := TChartFlagLabel(lGroup[J]);
          lFlag2 := TChartFlagLabel(lGroup[K]);
          lAxis := TChartAxis(lFlag.Trend.Parent);
          if GetTrendValueAtX(lFlag.Trend, lFlag.AnchorX, lYVal) then
            lX1 := ARenderer.AxisValueToPixel(lAxis, lYVal, lContentRect.Bottom, lContentRect.Top)
          else
            lX1 := lContentRect.Top;
          lAxis := TChartAxis(lFlag2.Trend.Parent);
          if GetTrendValueAtX(lFlag2.Trend, lFlag2.AnchorX, lYVal) then
            lX2 := ARenderer.AxisValueToPixel(lAxis, lYVal, lContentRect.Bottom, lContentRect.Top)
          else
            lX2 := lContentRect.Top;
          if lX1 > lX2 then
          begin
            lGroup[J] := lFlag2;
            lGroup[K] := lFlag;
          end;

        end;

      // Выстраиваем стопку
      lTargetY := lContentRect.Top + 10; // Отступ сверху
      for J := 0 to lGroup.Count - 1 do
      begin
        lFlag := TChartFlagLabel(lGroup[J]);
        // Позиционируем рамку флага
        lFlag.WorldX := lFlag.AnchorX;
        lAxis := TChartAxis(lFlag.Trend.Parent);
        lFlag.WorldY := ARenderer.PixelToAxisValue(lAxis, lTargetY, lContentRect.Bottom, lContentRect.Top);
        // Переходим к следующей позиции
        lTargetY := lTargetY + lFlag.Height + 5;
      end;

    end;

  finally
    for I := 0 to lGroups.Count - 1 do
      TList(lGroups[I]).Free;
    lGroups.Free;
    lFlags.Free;
  end;

end;

{ TChartLabelEditListener }

constructor TChartLabelEditListener.Create;
begin
  inherited Create;
  fIsDraggingLabel := False;
  fDragLabel := nil;
  fDragLabelBorder := 0;
  fActivePage := nil;
end;

procedure TChartLabelEditListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  J: Integer;
begin
  if not Enabled then Exit;
  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    // Ищем попадание в текстовую метку (TChartTextLabel) для перетаскивания или изменения размеров
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPage := TChartPage(lModel.Children[lIndex]);
        if lPage.Visible then
        begin
          for J := 0 to lPage.ChildCount - 1 do
            if lPage.Children[J] is TChartTextLabel then
            begin
              lPageRect := GetTextLabelPixelRect(TChartTextLabel(lPage.Children[J]), lRenderer, lPage);
              if (X >= lPageRect.Left - 5) and (X <= lPageRect.Right + 5) and
                 (Y >= lPageRect.Top - 5) and (Y <= lPageRect.Bottom + 5) then
              begin
                fDragLabel := TChartTextLabel(lPage.Children[J]);
                if not fDragLabel.Locked then
                begin
                  fIsDraggingLabel := True;
                  fActivePage := lPage;
                  fLastX := X;
                  fLastY := Y;
                  // Вычисляем, за какую границу тащим
                  if (Abs(X - lPageRect.Right) <= 5) and (Abs(Y - lPageRect.Bottom) <= 5) then
                    fDragLabelBorder := 5 // правый нижний угол (ресайз по обеим осям)
                  else if (Abs(X - lPageRect.Right) <= 5) then
                    fDragLabelBorder := 3 // правая граница (ресайз ширины)
                  else if (Abs(Y - lPageRect.Bottom) <= 5) then
                    fDragLabelBorder := 4 // нижняя граница (ресайз высоты)
                  else
                    fDragLabelBorder := 0; // перемещение всей метки
                  lRenderer.SelectedObject := fDragLabel;
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

procedure TChartLabelEditListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPageRect, lContentRect: TChartPixelRect;
  lPageWidth, lPageHeight: Integer;
  dX, dY: Integer;
  lXRange, lYRange: Double;
  lRect: TChartFloatRect;
  dValX, dValY: Double;
  lIndex: Integer;
  lPage: TChartPage;
  J: Integer;
  lLabelHovered: TChartBaseObject;
begin
  if not Enabled then Exit;
  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    // 1. Обработка перетаскивания и ресайза метки
    if fIsDraggingLabel and Assigned(fDragLabel) and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;
      lPageRect := lRenderer.GetPageRect(fActivePage);
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lPageWidth := Max(1, lContentRect.Right - lContentRect.Left);
      lPageHeight := Max(1, lContentRect.Bottom - lContentRect.Top);
      // Перемещение
      if fDragLabelBorder = 0 then
      begin
        if fDragLabel.IsWorldX then
        begin
          lXRange := lRenderer.XValueToPixel(fActivePage, nil, fDragLabel.WorldX, lContentRect.Left, lContentRect.Right);
          fDragLabel.WorldX := lRenderer.PixelToXValue(fActivePage, nil, lXRange + dX, lContentRect.Left, lContentRect.Right);
        end

        else
        begin
          lRect := fDragLabel.FloatRect;
          dValX := lRect.Right - lRect.Left;
          lRect.Left := lRect.Left + dX / lPageWidth;
          if lRect.Left < 0.0 then lRect.Left := 0.0;
          if lRect.Left + dValX > 1.0 then lRect.Left := 1.0 - dValX;
          lRect.Right := lRect.Left + dValX;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

        if fDragLabel.IsWorldY and Assigned(fDragLabel.Axis) then
        begin
          lYRange := lRenderer.AxisValueToPixel(fDragLabel.Axis, fDragLabel.WorldY, lContentRect.Bottom, lContentRect.Top);
          fDragLabel.WorldY := lRenderer.PixelToAxisValue(fDragLabel.Axis, lYRange + dY, lContentRect.Bottom, lContentRect.Top);
        end

        else
        begin
          lRect := fDragLabel.FloatRect;
          dValY := lRect.Bottom - lRect.Top;
          lRect.Top := lRect.Top + dY / lPageHeight;
          if lRect.Top < 0.0 then lRect.Top := 0.0;
          if lRect.Top + dValY > 1.0 then lRect.Top := 1.0 - dValY;
          lRect.Bottom := lRect.Top + dValY;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

      end

      // Изменение ширины
      else if fDragLabelBorder = 3 then
      begin
        if fDragLabel.IsWorldX then
          fDragLabel.Width := Max(20, fDragLabel.Width + dX)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Right := Max(lRect.Left + 0.01, lRect.Right + dX / lPageWidth);
          if lRect.Right > 1.0 then lRect.Right := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

      end

      // Изменение высоты
      else if fDragLabelBorder = 4 then
      begin
        if fDragLabel.IsWorldY and Assigned(fDragLabel.Axis) then
          fDragLabel.Height := Max(15, fDragLabel.Height + dY)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Bottom := Max(lRect.Top + 0.01, lRect.Bottom + dY / lPageHeight);
          if lRect.Bottom > 1.0 then lRect.Bottom := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

      end

      // Угол (ширина и высота)
      else if fDragLabelBorder = 5 then
      begin
        if fDragLabel.IsWorldX then
          fDragLabel.Width := Max(20, fDragLabel.Width + dX)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Right := Max(lRect.Left + 0.01, lRect.Right + dX / lPageWidth);
          if lRect.Right > 1.0 then lRect.Right := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

        if fDragLabel.IsWorldY and Assigned(fDragLabel.Axis) then
          fDragLabel.Height := Max(15, fDragLabel.Height + dY)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Bottom := Max(lRect.Top + 0.01, lRect.Bottom + dY / lPageHeight);
          if lRect.Bottom > 1.0 then lRect.Bottom := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

      end;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 2. Смена курсора и Hovered-статуса при наведении на метки
    lLabelHovered := nil;
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPage := TChartPage(lModel.Children[lIndex]);
        if lPage.Visible then
        begin
          for J := 0 to lPage.ChildCount - 1 do
            if lPage.Children[J] is TChartTextLabel then
            begin
              lPageRect := GetTextLabelPixelRect(TChartTextLabel(lPage.Children[J]), lRenderer, lPage);
              if (X >= lPageRect.Left - 4) and (X <= lPageRect.Right + 4) and
                 (Y >= lPageRect.Top - 4) and (Y <= lPageRect.Bottom + 4) then
              begin
                lLabelHovered := lPage.Children[J];
                Break;
              end;

            end;

        end;

        if Assigned(lLabelHovered) then Break;
      end;

    if Assigned(lLabelHovered) then
    begin
      lRenderer.HoveredObject := lLabelHovered;
      lPageRect := GetTextLabelPixelRect(TChartTextLabel(lLabelHovered), lRenderer, TChartPage(lLabelHovered.Parent));
      if (Abs(X - lPageRect.Right) <= 5) and (Abs(Y - lPageRect.Bottom) <= 5) then
        TControl(ASender).Cursor := crSizeNWSE
      else if (Abs(X - lPageRect.Right) <= 5) and (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        TControl(ASender).Cursor := crSizeWE
      else if (Abs(Y - lPageRect.Bottom) <= 5) and (X >= lPageRect.Left) and (X <= lPageRect.Right) then
        TControl(ASender).Cursor := crSizeNS
      else if not TChartTextLabel(lLabelHovered).Locked then
        TControl(ASender).Cursor := crSizeAll;
      lControl.Redraw;
    end;

  end;

end;

procedure TChartLabelEditListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
  if not Enabled then Exit;
  if (Button = mbLeft) and fIsDraggingLabel then
  begin
    fIsDraggingLabel := False;
    fDragLabel := nil;
    fDragLabelBorder := 0;
    fActivePage := nil;
    TControl(ASender).Cursor := crDefault;
    Handled := True;
  end;

end;

end.
