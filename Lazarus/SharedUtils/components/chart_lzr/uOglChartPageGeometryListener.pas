unit uOglChartPageGeometryListener;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Controls, Math, LCLType,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartPage, uOglChartRenderer, uOglChartChart;

type
  /// <summary>
  /// —лушатель событий мыши дл€ изменени€ геометрии и разметки страниц (TChartPage).
  /// ”правл€ет изменением размеров за границы и перетаскиванием страниц с помощью Shift + мышь.
  /// </summary>
  TChartPageGeometryListener = class(TChartFrameListener)
  private
    fActivePage: TChartPage;         // —сылка на активную страницу.
    fResizingBorder: Integer;        //  од границы страницы: 1-лево, 2-право, 3-верх, 4-низ.
    fMovingPage: Boolean;            // ‘лаг активного перемещени€ страницы по холсту.
    fIsResizing: Boolean;            // ‘лаг активного изменени€ размеров страницы.
    fSnapSensitivity: Integer;       // „увствительность примагничивани€ страниц друг к другу (в пиксел€х).
    fLastX: Integer;
    fLastY: Integer;
  public
    /// <summary>
    ///  онструктор по умолчанию. »нициализирует настройки чувствительности примагничивани€.
    /// </summary>

    constructor Create; override;

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;

    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;

    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// ћаксимальное рассто€ние в пиксел€х, на котором срабатывает примагничивание страниц при перемещении.
    /// </summary>
    property SnapSensitivity: Integer read fSnapSensitivity write fSnapSensitivity;
  end;

implementation
{ TChartPageGeometryListener }

constructor TChartPageGeometryListener.Create;
begin
  inherited Create;
  fActivePage := nil;
  fResizingBorder := 0;
  fMovingPage := False;
  fIsResizing := False;
  fSnapSensitivity := 5;
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
    // 1. »зменение размеров выделенной страницы
    if (fResizingBorder > 0) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
    begin
      lPage := TChartPage(lRenderer.SelectedObject);
      if not lPage.Locked then
      begin
        fIsResizing := True;
        fActivePage := lPage;
        // ќтключаем автоматическое выравнивание всех страниц при ручном изменении
        for lInnerIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lInnerIndex] is TChartPage then
            TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;
        fLastX := X;
        fLastY := Y;
        Handled := True;
        Exit;
      end;

    end;

    // 2. ≈сли зажат Shift, то это режим перемещени€ страницы
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
  lPageRect: TChartPixelRect;
  lWidth, lHeight: Single;
  dX, dY: Integer;
  lIndex: Integer;
  lPage, lTempPage: TChartPage;
  lRect: TChartFloatRect;
  lTargetVal: Integer;
  lTargetLeft, lTargetTop: Integer;
  lSnappedLeft, lSnappedRight, lSnappedTop, lSnappedBottom: Integer;
  lPageWidth, lPageHeight: Integer;
  lTargetRight, lTargetBottom: Integer;

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
    // 1. —осто€ние перетаскивани€ изменени€ размеров границы страницы
    if fIsResizing and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;
      lPageRect := lRenderer.GetPageRect(fActivePage);
      lRect := fActivePage.FloatRect;
      case fResizingBorder of
        1: // Ћева€ граница
          begin
            lTargetVal := SnapX(lPageRect.Left + dX, fActivePage, fSnapSensitivity);
            lRect.Left := Min(lRect.Right - 0.05, lTargetVal / lWidth);
          end;

        2: // ѕрава€ граница
          begin
            lTargetVal := SnapX(lPageRect.Right + dX, fActivePage, fSnapSensitivity);
            lRect.Right := Max(lRect.Left + 0.05, lTargetVal / lWidth);
          end;

        3: // ¬ерхн€€ граница
          begin
            lTargetVal := SnapY(lPageRect.Top + dY, fActivePage, fSnapSensitivity);
            lRect.Top := Min(lRect.Bottom - 0.05, lTargetVal / lHeight);
          end;

        4: // Ќижн€€ граница
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

    // 2. —осто€ние перемещени€ страницы (Shift + Drag)
    if fMovingPage and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;
      lPageRect := lRenderer.GetPageRect(fActivePage);
      lTargetLeft := lPageRect.Left + dX;
      lTargetTop := lPageRect.Top + dY;
      // ѕримагничивание по X (лева€ или права€ граница)
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

      // ѕримагничивание по Y (верхн€€ или нижн€€ граница)
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

    // 3. ќбычное движение мыши: мен€ем курсор при наведении на границы выделенной страницы
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
      // ≈сли выделенной страницы нет, но зажат Shift, мен€ем курсор над любой незаблокированной страницей
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
      else if TControl(ASender).Cursor = crSizeAll then
        TControl(ASender).Cursor := crDefault;
    end;

  end;

end;

procedure TChartPageGeometryListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
  if not Enabled then Exit;
  if Button = mbLeft then
  begin
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

end;

end.

