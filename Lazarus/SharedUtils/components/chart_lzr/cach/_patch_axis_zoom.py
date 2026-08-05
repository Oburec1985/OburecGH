#!/usr/bin/env python3
"""Patch uOglChartPanZoomListener for axis-only zoom selection."""
from pathlib import Path

PAS = Path(r"D:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas")

def main() -> None:
    text = PAS.read_bytes().decode("utf-8", errors="replace")
    nl = "\r\n" if "\r\n" in text else "\n"

    if "fZoomSelectMode: TZoomSelectMode" not in text:
        text = text.replace(
            "    fZoomStartY: Integer;",
            "    fZoomStartY: Integer;\n    fZoomSelectMode: TZoomSelectMode;",
            1,
        )

    old_down = """                lContentRect := lRenderer.GetPageContentRect(lPage);
                if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                   (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
                begin
                  fIsZoomSelecting := True;
                  fZoomStartX := X;
                  fZoomStartY := Y;
                  fActivePage := lPage;
                  Handled := True;
                  Exit;
                end;"""

    new_down = """                lContentRect := lRenderer.GetPageContentRect(lPage);
                if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                   (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
                  fZoomSelectMode := zsmXY
                else if IsOnYAxisBand(lRenderer, lPage, X, Y) then
                  fZoomSelectMode := zsmYOnly
                else if IsOnXAxisBand(lRenderer, lPage, X, Y) then
                  fZoomSelectMode := zsmXOnly
                else
                  Continue;
                fIsZoomSelecting := True;
                fZoomStartX := X;
                fZoomStartY := Y;
                fActivePage := lPage;
                Handled := True;
                Exit;"""

    if old_down in text:
        text = text.replace(old_down, new_down)

    old_move = """      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lSelRect.Left := Max(lContentRect.Left, Min(fZoomStartX, X));
      lSelRect.Right := Min(lContentRect.Right, Max(fZoomStartX, X));
      lSelRect.Top := Max(lContentRect.Top, Min(fZoomStartY, Y));
      lSelRect.Bottom := Min(lContentRect.Bottom, Max(fZoomStartY, Y));"""

    new_move = """      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      BuildZoomSelectionRect(fZoomSelectMode, lContentRect, fZoomStartX, fZoomStartY, X, Y, lSelRect);"""

    if old_move in text:
        text = text.replace(old_move, new_move)

    old_up_start = """      // 1. ?????? ???????? ??? ???????? ????? (?????????? ?????)
      if (X < fZoomStartX - 5) then
      begin
        fActivePage.ZoomedX := False;
        FitZoomX(fActivePage);
        ApplyPresetZoomY(fActivePage, lRenderer.SelectedObject);
        lControl.Redraw;
        Handled := True;
      end

      // 2. ??????????? ??? ???????? ?????? ? ?????
      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then"""

    # Use ASCII-only anchor for mouse up block
    old_up_anchor = """      if (X < fZoomStartX - 5) then
      begin
        fActivePage.ZoomedX := False;
        FitZoomX(fActivePage);
        ApplyPresetZoomY(fActivePage, lRenderer.SelectedObject);
        lControl.Redraw;
        Handled := True;
      end

      // 2."""
    
    # Find the block more reliably
    marker1 = "      if (X < fZoomStartX - 5) then"
    marker2 = "      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then"
    idx1 = text.find(marker1)
    idx2 = text.find(marker2)
    if idx1 >= 0 and idx2 > idx1:
        old_block = text[idx1:idx2]
        new_block = """      if ((fZoomSelectMode = zsmXY) and (X < fZoomStartX - 5)) or
         ((fZoomSelectMode = zsmXOnly) and (X < fZoomStartX - 5)) or
         ((fZoomSelectMode = zsmYOnly) and (Y < fZoomStartY - 5)) then
      begin
        if fZoomSelectMode <> zsmYOnly then
        begin
          fActivePage.ZoomedX := False;
          if fActivePage.HasPresetXRange and (fActivePage.PresetMaxXValue > fActivePage.PresetMinXValue) then
          begin
            fActivePage.XMinValue := fActivePage.PresetMinXValue;
            fActivePage.XMaxValue := fActivePage.PresetMaxXValue;
          end
          else
            FitZoomX(fActivePage);
        end;
        if fZoomSelectMode <> zsmXOnly then
          ApplyPresetZoomY(fActivePage, lRenderer.SelectedObject);
        lControl.Redraw;
        Handled := True;
      end

      """
        text = text[:idx1] + new_block + text[idx2:]

    old_zoom_cond = "      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then"
    new_zoom_cond = """      else if ((fZoomSelectMode = zsmXY) and (X > fZoomStartX + 2) and (Y > fZoomStartY + 2)) or
         ((fZoomSelectMode = zsmYOnly) and (Abs(Y - fZoomStartY) > 2)) or
         ((fZoomSelectMode = zsmXOnly) and (Abs(X - fZoomStartX) > 2)) then"""
    if old_zoom_cond in text:
        text = text.replace(old_zoom_cond, new_zoom_cond)

    old_sel = """        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        lSelRect.Left := Max(lContentRect.Left, fZoomStartX);
        lSelRect.Right := Min(lContentRect.Right, X);
        lSelRect.Top := Max(lContentRect.Top, fZoomStartY);
        lSelRect.Bottom := Min(lContentRect.Bottom, Y);"""

    new_sel = """        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        BuildZoomSelectionRect(fZoomSelectMode, lContentRect, fZoomStartX, fZoomStartY, X, Y, lSelRect);"""

    if old_sel in text:
        text = text.replace(old_sel, new_sel)

    old_x_zoom = """          // ??? ?? X
          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
          NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
          fActivePage.XMinValue := NewXMin;
          fActivePage.XMaxValue := NewXMax;
          fActivePage.ZoomedX := True;"""

    # ASCII anchor for X zoom block
    x_marker = "          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);"
    if x_marker in text and "if fZoomSelectMode <> zsmYOnly then" not in text:
        text = text.replace(
            """          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
          NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
          fActivePage.XMinValue := NewXMin;
          fActivePage.XMaxValue := NewXMax;
          fActivePage.ZoomedX := True;
          // """,
            """          if fZoomSelectMode <> zsmYOnly then
          begin
            NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
            NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
            fActivePage.XMinValue := NewXMin;
            fActivePage.XMaxValue := NewXMax;
            fActivePage.ZoomedX := True;
          end;
          // """,
            1,
        )

    y_marker = "                NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);"
    if y_marker in text and "if fZoomSelectMode <> zsmXOnly then" not in text:
        text = text.replace(
            """                NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
                NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
                lAxis.MinValue := NewYMin;
                lAxis.MaxValue := NewYMax;""",
            """                if fZoomSelectMode <> zsmXOnly then
                begin
                  NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
                  NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
                  lAxis.MinValue := NewYMin;
                  lAxis.MaxValue := NewYMax;
                end;""",
            1,
        )

    # Wrap axis UseOwnX X zoom in mode check too
    own_x = """                if lAxis.UseOwnX then
                begin
                  NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                  NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                  lAxis.XMinValue := NewXMin;
                  lAxis.XMaxValue := NewXMax;
                end;"""
    own_x_new = """                if (fZoomSelectMode <> zsmYOnly) and lAxis.UseOwnX then
                begin
                  NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                  NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                  lAxis.XMinValue := NewXMin;
                  lAxis.XMaxValue := NewXMax;
                end;"""
    if own_x in text:
        text = text.replace(own_x, own_x_new)

    PAS.write_bytes(text.replace("\n", nl).encode("utf-8"))
    print("patched", PAS)

if __name__ == "__main__":
    main()
