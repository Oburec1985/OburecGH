# -*- coding: utf-8 -*-
import os

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas"

if not os.path.exists(file_path):
    print("Error: uOglChartPanZoomListener.pas not found")
    exit(1)

with open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Normalize content to LF only for matching
content = content.replace("\r\n", "\n").replace("\r", "\n")

# Targets and replacements with LF only
target_mw_var = """procedure TChartPanZoomListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);

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
begin"""

replacement_mw_var = """procedure TChartPanZoomListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);

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
  lSelectedAxis: TChartAxis;
begin"""

target_mw_loop = """    if Assigned(lPage) and not lPage.Locked then
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

      lControl.Redraw;"""

replacement_mw_loop = """    if Assigned(lPage) and not lPage.Locked then
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
      
      // Определяем выбранную ось (Y) для изоляции зума
      lSelectedAxis := nil;
      if Assigned(lRenderer.SelectedObject) then
      begin
        if lRenderer.SelectedObject is TChartAxis then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
        else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
      end;

      // Масштабирование по осям Y относительно курсора мыши
      for lIndex := 0 to lPage.ChildCount - 1 do
        if lPage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(lPage.Children[lIndex]);
          if (lSelectedAxis = nil) or (lAxis = lSelectedAxis) then
          begin
            lMouseValY := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);
            lAxis.MinValue := lMouseValY - (lMouseValY - lAxis.MinValue) * lZoomFactor;
            lAxis.MaxValue := lMouseValY + (lAxis.MaxValue - lMouseValY) * lZoomFactor;
          end;
        end;

      lControl.Redraw;"""

target_mm_var = """procedure TChartPanZoomListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lWidth, lHeight: Single;
  dX, dY: Integer;
  dValX, dValY: Double;
  lXRange, lYRange: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
  lSelRect: TChartPixelRect;
begin"""

replacement_mm_var = """procedure TChartPanZoomListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lWidth, lHeight: Single;
  dX, dY: Integer;
  dValX, dValY: Double;
  lXRange, lYRange: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
  lSelRect: TChartPixelRect;
  lSelectedAxis: TChartAxis;
begin"""

target_mm_pan = """    // 2. Состояние обычного панорамирования графика правой кнопкой мыши
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

      fLastX := X;"""

replacement_mm_pan = """    // 2. Состояние обычного панорамирования графика правой кнопкой мыши
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
      
      // Определяем выбранную ось (Y) для изоляции панорамирования
      lSelectedAxis := nil;
      if Assigned(lRenderer.SelectedObject) then
      begin
        if lRenderer.SelectedObject is TChartAxis then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
        else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
      end;

      for lIndex := 0 to fActivePage.ChildCount - 1 do
        if fActivePage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(fActivePage.Children[lIndex]);
          if (lSelectedAxis = nil) or (lAxis = lSelectedAxis) then
          begin
            lYRange := lAxis.MaxValue - lAxis.MinValue;
            dValY := (dY / lHeight) * lYRange;
            lAxis.MinValue := lAxis.MinValue + dValY;
            lAxis.MaxValue := lAxis.MaxValue + dValY;
          end;
        end;

      fLastX := X;"""

target_mu_var = """procedure TChartPanZoomListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lAxis: TChartAxis;
  NewXMin, NewXMax, NewYMin, NewYMax: Double;
  lSelRect: TChartPixelRect;
begin"""

replacement_mu_var = """procedure TChartPanZoomListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lAxis: TChartAxis;
  NewXMin, NewXMax, NewYMin, NewYMax: Double;
  lSelRect: TChartPixelRect;
  lSelectedAxis: TChartAxis;
begin"""

target_mu_zoom = """          // Зум по осям Y
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

          lControl.Redraw;"""

replacement_mu_zoom = """          // Определяем выбранную ось (Y) для изоляции рамки зума
          lSelectedAxis := nil;
          if Assigned(lRenderer.SelectedObject) then
          begin
            if lRenderer.SelectedObject is TChartAxis then
              lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
            else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
              lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
          end;

          // Зум по осям Y
          for lIndex := 0 to fActivePage.ChildCount - 1 do
            if fActivePage.Children[lIndex] is TChartAxis then
            begin
              lAxis := TChartAxis(fActivePage.Children[lIndex]);
              if (lSelectedAxis = nil) or (lAxis = lSelectedAxis) then
              begin
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
            end;

          lControl.Redraw;"""

# Check for existence of each target
targets = [
    ("mw_var", target_mw_var, replacement_mw_var),
    ("mw_loop", target_mw_loop, replacement_mw_loop),
    ("mm_var", target_mm_var, replacement_mm_var),
    ("mm_pan", target_mm_pan, replacement_mm_pan),
    ("mu_var", target_mu_var, replacement_mu_var),
    ("mu_zoom", target_mu_zoom, replacement_mu_zoom)
]

for name, tgt, repl in targets:
    if tgt not in content:
        print(f"Error: Target {name} not found in content!")
    else:
        content = content.replace(tgt, repl)
        print(f"Applied replacement: {name}")

# Convert all newlines to CRLF
content = content.replace("\n", "\r\n")

with open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("File successfully normalized to CRLF and written!")
