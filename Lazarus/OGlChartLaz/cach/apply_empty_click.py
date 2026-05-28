import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Starting empty click selection behavior update...")

with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

# 1. Add lHasSelectedPoint to local variables of TChartSelectListener.MouseDown
vars_target = """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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
begin"""

vars_replacement = """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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
begin"""

if vars_target in content_l_lf:
    content_l_lf = content_l_lf.replace(vars_target, vars_replacement)
    print("Added lHasSelectedPoint variable to MouseDown.")
else:
    print("Warning: vars_target not found in listeners!")

# 2. Modify page click logic to handle trend points deselect
page_click_target = """    // 2. Проверяем попадание в саму страницу
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
              lRenderer.SelectedObject := lPage;
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end;
    end;"""

page_click_replacement = """    // 2. Проверяем попадание в саму страницу
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
    end;"""

if page_click_target in content_l_lf:
    content_l_lf = content_l_lf.replace(page_click_target, page_click_replacement)
    print("Updated page click logic to support trend point deselect.")
else:
    print("Warning: page_click_target not found in listeners!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
