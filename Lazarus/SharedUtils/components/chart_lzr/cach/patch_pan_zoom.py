# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas"

# Read in cp1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# 1. MouseWheel var section
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

# 2. MouseWheel loop section
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
          lAxis.MaxValue := lMouseValY + (lMouseValY - lAxis.MaxValue) * lZoomFactor;
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
            lAxis.MaxValue := lMouseValY + (lMouseValY - lAxis.MaxValue) * lZoomFactor;
          end;
        end;

      lControl.Redraw;"""

# 3. MouseMove var section
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

# 4. MouseMove pan section
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

# 5. MouseUp var section
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

# 6. MouseUp zoom section
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

# Normalize targets and replacements to CRLF just in case
def norm(txt):
    return txt.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")

content = content.replace(norm(target_mw_var), norm(replacement_mw_var))
content = content.replace(norm(target_mw_loop), norm(replacement_mw_loop))
content = content.replace(norm(target_mm_var), norm(replacement_mm_var))
content = content.replace(norm(target_mm_pan), norm(replacement_mm_pan))
content = content.replace(norm(target_mu_var), norm(replacement_mu_var))
content = content.replace(norm(target_mu_zoom), norm(replacement_mu_zoom))

# Save back in cp1251 without BOM
with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Patch applied successfully!")
