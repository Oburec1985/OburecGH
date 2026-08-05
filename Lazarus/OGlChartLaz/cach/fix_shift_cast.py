import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"
CHART_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"

# 1. Fix in uOglChartFrameListener.pas
with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

old_log_l = "LogToFile('SelectListener.KeyDown: Key=' + IntToStr(Key) + ', ShiftState=' + IntToHex(Byte(Shift), 2));"
new_log_l = "LogToFile('SelectListener.KeyDown: Key=' + IntToStr(Key));"

if old_log_l in content_l_lf:
    content_l_lf = content_l_lf.replace(old_log_l, new_log_l)
    print("Fixed shift log in uOglChartFrameListener.pas.")
else:
    print("Warning: old_log_l not found!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))

# 2. Fix in uoglchart.pas
with open(CHART_PATH, 'rb') as f:
    raw_c = f.read()
content_c = raw_c.decode('cp1251')
content_c_lf = content_c.replace('\r\n', '\n').replace('\r', '\n')

old_log_c = "LogToFile('TOglChart.KeyDown: Key=' + IntToStr(Key) + ', Shift=' + IntToHex(Byte(Shift), 2));"
new_log_c = "LogToFile('TOglChart.KeyDown: Key=' + IntToStr(Key));"

if old_log_c in content_c_lf:
    content_c_lf = content_c_lf.replace(old_log_c, new_log_c)
    print("Fixed shift log in uoglchart.pas.")
else:
    print("Warning: old_log_c not found!")

with open(CHART_PATH, 'wb') as f:
    f.write(content_c_lf.replace('\n', '\r\n').encode('cp1251'))

print("Fix completed.")
