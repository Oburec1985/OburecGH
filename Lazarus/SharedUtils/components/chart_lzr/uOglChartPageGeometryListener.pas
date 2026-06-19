unit uOglChartPageGeometryListener;

{
  Модуль uOglChartPageGeometryListener
  Описание: Слушатель для изменения размеров страниц и перемещения их границ мышью.
}

{ objfpc}{+}

interface

uses
  Classes, SysUtils, Controls, LCLType, Math,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartRenderer, uOglChartChart;

type
  /// <summary>
  /// Слушатель для изменения геометрии страниц (ресайз за границы/углы, перемещение с Shift).
  /// </summary>
  TChartPageGeometryListener = class(TChartFrameListener)
  private
    fActivePage: TChartPage;         // Активная страница во время ресайза/перемещения
    fResizingBorder: Integer;        // 1..4 для сторон, 5..8 для углов
    fMovingPage: Boolean;            // Перемещение страницы
    fIsResizing: Boolean;            // Ресайз страницы
    fSnapSensitivity: Integer;       // Чувствительность примагничивания в пикселях
    fLastX, fLastY: Integer;
  public
    constructor Create; override;
    
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;

    property SnapSensitivity: Integer read fSnapSensitivity write fSnapSensitivity;
  end;

implementation

{ TChartPageGeometryListener }

constructor TChartPageGeometryListener.Create;
begin
  inherited Create;
  fSnapSensitivity := 5;
  fResizingBorder := 0;
  fMovingPage := False;
  fIsResizing := False;
  fActivePage := nil;
end;

procedure TChartPageGeometryListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
begin
  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    // 1. Изменение размеров выделенной страницы (если курсор наведен на границу/угол)
    if (fResizingBorder > 0) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
    begin
      lPage := TChartPage(lRenderer.SelectedObject);
      if not lPage.Locked then
      begin
        fIsResizing := True;
        fActivePage := lPage;

        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
            TChartPage(lModel.Children[lIndex]).Align := cpaNone;

        fLastX := X;
        fLastY := Y;
        Handled := True;
        Exit;
      end;
    end;

    // 2. Перемещение страницы (если зажат Shift и кликнули внутри страницы)
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
end;

procedure TChartPageGeometryListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage, lTempPage: TChartPage;
  lPageRect: TChartPixelRect;
  lWidth, lHeight: Single;
  dX, dY: Integer;
  lIndex: Integer;
  lRect: TChartFloatRect;
  lTargetVal: Integer;
  lTargetLeft, lTargetTop, lTargetRight, lTargetBottom: Integer;
  lSnappedLeft, lSnappedRight, lSnappedTop, lSnappedBottom: Integer;
  lPageWidth, lPageHeight: Integer;

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

    // 1. Состояние перетаскивания (ресайза) границы страницы
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
        5: // Верхний-левый угол (NWSE)
          begin
            lTargetVal := SnapX(lPageRect.Left + dX, fActivePage, fSnapSensitivity);
            lRect.Left := Min(lRect.Right - 0.05, lTargetVal / lWidth);
            lTargetVal := SnapY(lPageRect.Top + dY, fActivePage, fSnapSensitivity);
            lRect.Top := Min(lRect.Bottom - 0.05, lTargetVal / lHeight);
          end;
        6: // Верхний-правый угол (NESW)
          begin
            lTargetVal := SnapX(lPageRect.Right + dX, fActivePage, fSnapSensitivity);
            lRect.Right := Max(lRect.Left + 0.05, lTargetVal / lWidth);
            lTargetVal := SnapY(lPageRect.Top + dY, fActivePage, fSnapSensitivity);
            lRect.Top := Min(lRect.Bottom - 0.05, lTargetVal / lHeight);
          end;
        7: // Нижний-левый угол (NESW)
          begin
            lTargetVal := SnapX(lPageRect.Left + dX, fActivePage, fSnapSensitivity);
            lRect.Left := Min(lRect.Right - 0.05, lTargetVal / lWidth);
            lTargetVal := SnapY(lPageRect.Bottom + dY, fActivePage, fSnapSensitivity);
            lRect.Bottom := Max(lRect.Top + 0.05, lTargetVal / lHeight);
          end;
        8: // Нижний-правый угол (NWSE)
          begin
            lTargetVal := SnapX(lPageRect.Right + dX, fActivePage, fSnapSensitivity);
            lRect.Right := Max(lRect.Left + 0.05, lTargetVal / lWidth);
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

    // 2. Состояние перемещения страницы
    if fMovingPage and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;

      lPageRect := lRenderer.GetPageRect(fActivePage);
      lTargetLeft := lPageRect.Left + dX;
      lTargetTop := lPageRect.Top + dY;

      // Примагничивание по X
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

      // Примагничивание по Y
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

    // 3. Обычное движение мыши: меняем курсор при наведении на границы выделенной страницы
    if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
    begin
      lPage := TChartPage(lRenderer.SelectedObject);
      lPageRect := lRenderer.GetPageRect(lPage);

      fResizingBorder := 0;

      // Проверка на углы
      if (Abs(X - lPageRect.Left) <= 6) and (Abs(Y - lPageRect.Top) <= 6) then
        fResizingBorder := 5  // Top-Left (NWSE)
      else if (Abs(X - lPageRect.Right) <= 6) and (Abs(Y - lPageRect.Top) <= 6) then
        fResizingBorder := 6  // Top-Right (NESW)
      else if (Abs(X - lPageRect.Left) <= 6) and (Abs(Y - lPageRect.Bottom) <= 6) then
        fResizingBorder := 7  // Bottom-Left (NESW)
      else if (Abs(X - lPageRect.Right) <= 6) and (Abs(Y - lPageRect.Bottom) <= 6) then
        fResizingBorder := 8  // Bottom-Right (NWSE)
      else
      begin
        // Проверка на ребра
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
      end;

      if fResizingBorder in [1, 2] then
        TControl(ASender).Cursor := crSizeWE
      else if fResizingBorder in [3, 4] then
        TControl(ASender).Cursor := crSizeNS
      else if fResizingBorder in [5, 8] then
        TControl(ASender).Cursor := crSizeNWSE
      else if fResizingBorder in [6, 7] then
        TControl(ASender).Cursor := crSizeNESW
      else if ssShift in Shift then
      begin
        if not TChartPage(lRenderer.SelectedObject).Locked and
           (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          TControl(ASender).Cursor := crSizeAll;
      end;
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
        TControl(ASender).Cursor := crSizeAll;
    end;
  end;
end;

procedure TChartPageGeometryListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
  if not Enabled then Exit;

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

end.