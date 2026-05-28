import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

print(f"Modifying {os.path.basename(FILE_PATH)} to fix compilation errors...")
with open(FILE_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251
text = raw_data.decode('cp1251')

# Normalize newlines
text = text.replace('\r\n', '\n').replace('\r', '\n')

# 1. Update uses in unit1.pas to include Math, uOglChartRenderer, uOglChartTypes, uOglChartDrawObj
old_uses_part = """  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  uOglChart, uOglChartBaseObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, ImgList;"""

new_uses_part = """  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  Math, uOglChart, uOglChartBaseObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, uOglChartRenderer, uOglChartTypes, uOglChartDrawObj, ImgList;"""

if old_uses_part in text:
    text = text.replace(old_uses_part, new_uses_part)
    print("  Successfully updated uses clause.")
else:
    # Try alternate formatting
    old_uses_alt = "  uOglChart, uOglChartBaseObj, uOglChartPage, uOglChartAxis, uOglChartTrend,\n  uOglChartChart, ImgList;"
    new_uses_alt = "  uOglChart, uOglChartBaseObj, uOglChartPage, uOglChartAxis, uOglChartTrend,\n  uOglChartChart, uOglChartRenderer, uOglChartTypes, uOglChartDrawObj, ImgList;"
    if old_uses_alt in text:
        text = text.replace(old_uses_alt, new_uses_alt)
        print("  Successfully updated uses clause (alt).")
    else:
        print("  FAIL: uses clause match not found!")

# 2. Fix variable scope and nesting inside OglChart1MouseMove
old_mouse_move = """procedure TForm1.OglChart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lModel: TChartModel;
  lPage: TChartPage;
  lRect, lContentRect: TChartPixelRect;
  lSelectedAxis: TChartAxis;
  lAxisXVal, lAxisYVal: Double;
  lIdx: Integer;
  lPageFound: Boolean;
  lPageX, lPageY: Integer;
begin"""

new_mouse_move = """procedure TForm1.OglChart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lModel: TChartModel;
  lPage: TChartPage;
  lRect, lContentRect: TChartPixelRect;
  lSelectedAxis: TChartAxis;
  lAxisXVal, lAxisYVal: Double;
  lIdx, lInnerIdx: Integer;
  lPageFound: Boolean;
  lPageX, lPageY: Integer;
begin"""

if old_mouse_move in text:
    text = text.replace(old_mouse_move, new_mouse_move)
    print("  Successfully declared lInnerIdx in OglChart1MouseMove.")
else:
    print("  FAIL: old_mouse_move var declaration not found!")

# 3. Replace internal loop to use lInnerIdx instead of lIdx
old_inner_loop = """            // Если не выбрана ось, берем первую ось этой страницы
            for lIdx := 0 to lPage.ChildCount - 1 do
              if lPage.Children[lIdx] is TChartAxis then
              begin
                lSelectedAxis := TChartAxis(lPage.Children[lIdx]);
                Break;
              end;"""

new_inner_loop = """            // Если не выбрана ось, берем первую ось этой страницы
            for lInnerIdx := 0 to lPage.ChildCount - 1 do
              if lPage.Children[lInnerIdx] is TChartAxis then
              begin
                lSelectedAxis := TChartAxis(lPage.Children[lInnerIdx]);
                Break;
              end;"""

if old_inner_loop in text:
    text = text.replace(old_inner_loop, new_inner_loop)
    print("  Successfully replaced nested loop variable with lInnerIdx.")
else:
    print("  FAIL: old_inner_loop not found!")

# Restore CRLF line endings
text = text.replace('\n', '\r\n')

# Save file
with open(FILE_PATH, 'w', encoding='cp1251', newline='') as f:
    f.write(text)
print("Saved file successfully.")
