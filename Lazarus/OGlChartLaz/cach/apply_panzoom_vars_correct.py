import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Fixing PanZoomListener local variables declaration...")

with open(LISTENER_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

target = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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
  J, K, lIdx: Integer;
begin"""

replacement = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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
  J, K, lIdx, I: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
begin"""

if target in content_lf:
    content_lf = content_lf.replace(target, replacement)
    print("Variables declaration replaced successfully.")
else:
    print("Warning: target not found!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))
