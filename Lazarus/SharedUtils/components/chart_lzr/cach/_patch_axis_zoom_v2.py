#!/usr/bin/env python3
from pathlib import Path

PAS = Path(r"D:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas")

HELPERS = """
function IsOnYAxisBand(ARenderer: TOpenGLChartRenderer; APage: TChartPage;
  AX, AY: Integer): Boolean;
var
  lContentRect, lPageRect: TChartPixelRect;
begin
  lPageRect := ARenderer.GetPageRect(APage);
  lContentRect := ARenderer.GetPageContentRect(APage);
  Result := (AX >= lPageRect.Left) and (AX < lContentRect.Left) and
    (AY >= lContentRect.Top) and (AY <= lContentRect.Bottom);
end;

function IsOnXAxisBand(ARenderer: TOpenGLChartRenderer; APage: TChartPage;
  AX, AY: Integer): Boolean;
var
  lContentRect, lPageRect: TChartPixelRect;
begin
  lPageRect := ARenderer.GetPageRect(APage);
  lContentRect := ARenderer.GetPageContentRect(APage);
  Result := (AY > lContentRect.Bottom) and (AY <= lPageRect.Bottom) and
    (AX >= lContentRect.Left) and (AX <= lContentRect.Right);
end;

procedure BuildZoomSelectionRect(AMode: TZoomSelectMode;
  const AContent: TChartPixelRect; AStartX, AStartY, AX, AY: Integer;
  out ASelRect: TChartPixelRect);
begin
  case AMode of
    zsmYOnly:
      begin
        ASelRect.Left := AContent.Left;
        ASelRect.Right := AContent.Right;
        ASelRect.Top := Max(AContent.Top, Min(AStartY, AY));
        ASelRect.Bottom := Min(AContent.Bottom, Max(AStartY, AY));
      end;
    zsmXOnly:
      begin
        ASelRect.Top := AContent.Top;
        ASelRect.Bottom := AContent.Bottom;
        ASelRect.Left := Max(AContent.Left, Min(AStartX, AX));
        ASelRect.Right := Min(AContent.Right, Max(AStartX, AX));
      end;
  else
    begin
      ASelRect.Left := Max(AContent.Left, Min(AStartX, AX));
      ASelRect.Right := Min(AContent.Right, Max(AStartX, AX));
      ASelRect.Top := Max(AContent.Top, Min(AStartY, AY));
      ASelRect.Bottom := Min(AContent.Bottom, Max(AStartY, AY));
    end;
  end;
end;

"""


def nl(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def to_crlf(text: str) -> str:
    return nl(text).replace("\n", "\r\n")


def must_replace(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise SystemExit(f"missing anchor: {label}")
    return text.replace(old, new, 1)


def main() -> None:
    raw = PAS.read_bytes()
    for enc in ("utf-8", "cp1251"):
        try:
            text = nl(raw.decode(enc))
            break
        except UnicodeDecodeError:
            continue
    else:
        text = nl(raw.decode("latin-1"))

    if "TZoomSelectMode" not in text:
        text = text.replace(
            "type\n  /// <summary>",
            "type\n  TZoomSelectMode = (zsmXY, zsmYOnly, zsmXOnly);\n\n  /// <summary>",
            1,
        )

    if "fZoomSelectMode" not in text:
        text = text.replace(
            "    fZoomStartY: Integer;",
            "    fZoomStartY: Integer;\n    fZoomSelectMode: TZoomSelectMode;",
            1,
        )

    if "IsOnYAxisBand" not in text:
        text = text.replace("implementation\n\ntype", "implementation\n\n" + HELPERS + "type", 1)

    text = must_replace(
        text,
        "  fZoomStartY := 0;\nend;",
        "  fZoomStartY := 0;\n  fZoomSelectMode := zsmXY;\nend;",
        "constructor",
    )

    text = must_replace(
        text,
        """                lContentRect := lRenderer.GetPageContentRect(lPage);
                if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                   (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
                begin
                  fIsZoomSelecting := True;
                  fZoomStartX := X;
                  fZoomStartY := Y;
                  fActivePage := lPage;
                  Handled := True;
                  Exit;
                end;""",
        """                lContentRect := lRenderer.GetPageContentRect(lPage);
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
                Exit;""",
        "mousedown",
    )

    text = must_replace(
        text,
        """      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lSelRect.Left := Max(lContentRect.Left, Min(fZoomStartX, X));
      lSelRect.Right := Min(lContentRect.Right, Max(fZoomStartX, X));
      lSelRect.Top := Max(lContentRect.Top, Min(fZoomStartY, Y));
      lSelRect.Bottom := Min(lContentRect.Bottom, Max(fZoomStartY, Y));""",
        """      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      BuildZoomSelectionRect(fZoomSelectMode, lContentRect, fZoomStartX, fZoomStartY, X, Y, lSelRect);""",
        "mousemove",
    )

    text = must_replace(
        text,
        """      if (X < fZoomStartX - 5) then
      begin
        fActivePage.ZoomedX := False;
        FitZoomX(fActivePage);
        ApplyPresetZoomY(fActivePage, lRenderer.SelectedObject);
        lControl.Redraw;
        Handled := True;
      end""",
        """      if ((fZoomSelectMode = zsmXY) and (X < fZoomStartX - 5)) or
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
      end""",
        "mouseup-reset",
    )

    text = must_replace(
        text,
        "      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then",
        """      else if ((fZoomSelectMode = zsmXY) and (X > fZoomStartX + 2) and (Y > fZoomStartY + 2)) or
         ((fZoomSelectMode = zsmYOnly) and (Abs(Y - fZoomStartY) > 2)) or
         ((fZoomSelectMode = zsmXOnly) and (Abs(X - fZoomStartX) > 2)) then""",
        "mouseup-zoomcond",
    )

    text = must_replace(
        text,
        """        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        lSelRect.Left := Max(lContentRect.Left, fZoomStartX);
        lSelRect.Right := Min(lContentRect.Right, X);
        lSelRect.Top := Max(lContentRect.Top, fZoomStartY);
        lSelRect.Bottom := Min(lContentRect.Bottom, Y);""",
        """        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        BuildZoomSelectionRect(fZoomSelectMode, lContentRect, fZoomStartX, fZoomStartY, X, Y, lSelRect);""",
        "mouseup-selrect",
    )

    text = must_replace(
        text,
        """          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
          NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
          fActivePage.XMinValue := NewXMin;
          fActivePage.XMaxValue := NewXMax;
          fActivePage.ZoomedX := True;""",
        """          if fZoomSelectMode <> zsmYOnly then
          begin
            NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
            NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
            fActivePage.XMinValue := NewXMin;
            fActivePage.XMaxValue := NewXMax;
            fActivePage.ZoomedX := True;
          end;""",
        "mouseup-xzoom",
    )

    text = must_replace(
        text,
        """                if lAxis.UseOwnX then
                begin
                  NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                  NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                  lAxis.XMinValue := NewXMin;
                  lAxis.XMaxValue := NewXMax;
                end;

                NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
                NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
                lAxis.MinValue := NewYMin;
                lAxis.MaxValue := NewYMax;""",
        """                if (fZoomSelectMode <> zsmYOnly) and lAxis.UseOwnX then
                begin
                  NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                  NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                  lAxis.XMinValue := NewXMin;
                  lAxis.XMaxValue := NewXMax;
                end;

                if fZoomSelectMode <> zsmXOnly then
                begin
                  NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
                  NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
                  lAxis.MinValue := NewYMin;
                  lAxis.MaxValue := NewYMax;
                end;""",
        "mouseup-yzoom",
    )

    PAS.write_bytes(to_crlf(text).encode("utf-8"))
    print("ok", PAS)


if __name__ == "__main__":
    main()
