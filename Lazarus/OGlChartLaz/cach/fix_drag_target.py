import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

drag_target = """        fDragTrend.UpdateBeziePoint(fDragPointIdx, lXRange, lYRange);
        lControl.Redraw;"""

drag_replacement = """        case fDragPart of
          cdpPoint: fDragTrend.UpdateBeziePoint(fDragPointIdx, lXRange, lYRange);
          cdpLeft: fDragTrend.UpdateBezieLeft(fDragPointIdx, lXRange, lYRange);
          cdpRight: fDragTrend.UpdateBezieRight(fDragPointIdx, lXRange, lYRange);
        end;
        lControl.Redraw;"""

if drag_target in content_l_lf:
    content_l_lf = content_l_lf.replace(drag_target, drag_replacement)
    print("Successfully replaced dragging logic in MouseMove.")
else:
    print("Error: drag_target not found!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))
