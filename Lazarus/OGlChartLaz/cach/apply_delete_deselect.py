import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Starting delete deselect behavior update...")

with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

old_delete_block = """        if Key = 46 then // VK_DELETE
        begin
          for I := 0 to lTrend.BeziePointCount - 1 do
          begin
            if lTrend.BeziePoints[I].Selected then
            begin
              LogToFile('  Deleting point ' + IntToStr(I));
              lTrend.DeleteBeziePoint(I);
              if lTrend.BeziePointCount > 0 then
              begin
                lNewIdx := I;
                if lNewIdx >= lTrend.BeziePointCount then
                  lNewIdx := lTrend.BeziePointCount - 1;
                lTrend.BeziePoints[lNewIdx].Selected := True;
              end;
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end"""

new_delete_block = """        if Key = 46 then // VK_DELETE
        begin
          for I := 0 to lTrend.BeziePointCount - 1 do
          begin
            if lTrend.BeziePoints[I].Selected then
            begin
              LogToFile('  Deleting point ' + IntToStr(I));
              lTrend.DeleteBeziePoint(I);
              // Снимаем выделение со всех оставшихся вершин тренда
              for lNewIdx := 0 to lTrend.BeziePointCount - 1 do
                lTrend.BeziePoints[lNewIdx].Selected := False;
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end"""

if old_delete_block in content_l_lf:
    content_l_lf = content_l_lf.replace(old_delete_block, new_delete_block)
    print("Replaced delete block successfully.")
else:
    print("Error: old_delete_block not found in listeners!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
