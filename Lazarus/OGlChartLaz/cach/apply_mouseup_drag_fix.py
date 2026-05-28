import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Starting MouseUp drag state clear update...")

with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

old_block = """    if Button = mbLeft then
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
    end;"""

new_block = """    if Button = mbLeft then
    begin
      if fIsDraggingPoint then
      begin
        fIsDraggingPoint := False;
        fDragTrend := nil;
        fDragPointIdx := -1;
        fActivePage := nil;
        Handled := True;
      end;

      if fIsResizing or fMovingPage then
      begin
        fIsResizing := False;
        fMovingPage := False;
        fActivePage := nil;
        fResizingBorder := 0;
        TControl(ASender).Cursor := crDefault;
        Handled := True;
      end;
    end;"""

if old_block in content_l_lf:
    content_l_lf = content_l_lf.replace(old_block, new_block)
    print("Replaced mbLeft MouseUp block successfully.")
else:
    print("Error: old_block not found in listeners!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
