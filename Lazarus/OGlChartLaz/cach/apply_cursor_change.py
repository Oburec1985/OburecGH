# -*- coding: cp1251 -*-
file_path = r'c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas'

with open(file_path, 'r', encoding='cp1251') as f:
    text = f.read()

start_str = "procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);"
fit_str = "procedure FitPageZoom"

start_idx = text.find(start_str)
fit_idx = text.find(fit_str)

if start_idx != -1 and fit_idx != -1 and start_idx < fit_idx:
    print(f"Found boundaries: start_idx={start_idx}, fit_idx={fit_idx}")
    
    new_method = """procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lNewHover: TChartBaseObject;
  lSelectedAxis: TChartAxis;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    lNewHover := nil;

    // 1. Поиск текстовых меток
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lNewHover := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lNewHover := lHit.Page;
    end;

    // 1.5. Поиск по линии оси Y
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) and lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then
        lNewHover := lSelectedAxis;
    end;

    // 2. Поиск страницы, если не навели на ось или текст
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

    // Управление формой курсора
    if lNewHover is TChartAxis then
      TControl(ASender).Cursor := crHandPoint
    else if TControl(ASender).Cursor = crHandPoint then
      TControl(ASender).Cursor := crDefault;
  end;
end;

"""
    # Replace method block
    text = text[:start_idx] + new_method.replace('\n', '\r\n').replace('\r\r\n', '\r\n') + text[fit_idx:]
    
    with open(file_path, 'w', encoding='cp1251', newline='\r\n') as f:
        f.write(text)
    print("SUCCESS: File updated successfully using FitPageZoom boundary.")
else:
    print(f"ERROR: Could not find boundaries. start_idx={start_idx}, fit_idx={fit_idx}")
