import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")
with open(FILE_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251
text = raw_data.decode('cp1251')

# Normalize newlines
text = text.replace('\r\n', '\n').replace('\r', '\n')

# 1. Update variables in DrawHighlights
old_highlights_vars = """procedure TOpenGLChartRenderer.DrawHighlights;
var
  lHovered, lSelected: TChartBaseObject;
  lIndex: Integer;
  lPageRect: TChartPixelRect;
begin"""

new_highlights_vars = """procedure TOpenGLChartRenderer.DrawHighlights;
var
  lHovered, lSelected: TChartBaseObject;
  lIndex: Integer;
  lPageRect: TChartPixelRect;
  lCursorX: Single;
begin"""

if old_highlights_vars in text:
    text = text.replace(old_highlights_vars, new_highlights_vars)
    print("  Successfully updated DrawHighlights variable block.")
else:
    print("  FAIL: old_highlights_vars block not found!")

# 2. Update end of DrawHighlights to redraw text hits
old_highlights_end = """          glLineWidth(1.5);
          DrawRect(fTextHits[lIndex].Rect);
        end;
    end;
  end;
end;"""

new_highlights_end = """          glLineWidth(1.5);
          DrawRect(fTextHits[lIndex].Rect);
        end;
    end;
  end;

  // 3. Перерисовываем текст поверх нарисованных подложек, чтобы он не закрашивался белым
  for lIndex := 0 to High(fTextHits) do
  begin
    if (Assigned(lHovered) and (fTextHits[lIndex].Axis = lHovered)) or
       (Assigned(lSelected) and (fTextHits[lIndex].Axis = lSelected)) then
    begin
      // Если этот элемент сейчас активно редактируется, рисуем его с курсором и выделением
      if (fActiveHit.Axis = fTextHits[lIndex].Axis) and (fActiveHit.Kind = fTextHits[lIndex].Kind) then
      begin
        // Рисуем выделение текста
        DrawTextSelection(fTextHits[lIndex].TextLeft, fTextHits[lIndex].Rect.Top + 3, fTextHits[lIndex].Font, fEditSelectionStart, fEditSelectionLength);
        // Рисуем курсор
        lCursorX := fTextHits[lIndex].TextLeft + fTextHits[lIndex].Font.TextPixelWidth(Copy(fEditText, 1, Max(0, fEditCursor - 1)));
        SetGLColor($FF202020);
        DrawLine(lCursorX, fTextHits[lIndex].Rect.Top + 2, lCursorX, fTextHits[lIndex].Rect.Top + 3 + fTextHits[lIndex].Font.TextPixelHeight + 1);
        // Рисуем сам редактируемый текст
        DrawText(fEditText, fTextHits[lIndex].TextLeft, fTextHits[lIndex].Rect.Top + 3, fTextHits[lIndex].Font);
      end
      else
      begin
        // Просто рисуем обычный текст метки
        DrawText(fTextHits[lIndex].Text, fTextHits[lIndex].TextLeft, fTextHits[lIndex].Rect.Top + 3, fTextHits[lIndex].Font);
      end;
    end;
  end;
end;"""

if old_highlights_end in text:
    text = text.replace(old_highlights_end, new_highlights_end)
    print("  Successfully updated DrawHighlights end to redraw labels.")
else:
    print("  FAIL: old_highlights_end block not found!")

# Restore CRLF line endings
text = text.replace('\n', '\r\n')

# Write back as Windows-1251 (CP1251)
with open(FILE_PATH, 'w', encoding='cp1251', newline='') as f:
    f.write(text)
print("Saved file successfully.")
