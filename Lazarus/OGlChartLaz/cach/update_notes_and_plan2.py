import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"
NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

# 1. Update plan.md
if os.path.exists(PLAN_PATH):
    with open(PLAN_PATH, 'rb') as f:
        plan_content = f.read().decode('utf-8')
    
    addition = "- [x] Шаг 51: Исправлена критическая ошибка отсутствия сброса `fIsDraggingPoint := False` в методе `TChartPanZoomListener.MouseUp`, что приводило к паразитному смещению вершин после их удаления или отпускания кнопки мыши."
    
    plan_content_lf = plan_content.replace('\r\n', '\n')
    if addition not in plan_content_lf:
        lines = plan_content_lf.split('\n')
        for idx in range(len(lines) - 1, -1, -1):
            if lines[idx].strip().startswith("- [x] Шаг 50"):
                lines.insert(idx + 1, addition)
                break
        plan_content_lf = '\n'.join(lines)
        
    with open(PLAN_PATH, 'wb') as f:
        f.write(plan_content_lf.replace('\n', '\r\n').encode('utf-8'))
    print("Updated plan.md step 51.")

# 2. Update notes_current.md
if os.path.exists(NOTES_PATH):
    with open(NOTES_PATH, 'rb') as f:
        notes_content = f.read().decode('utf-8')
        
    notes_content_lf = notes_content.replace('\r\n', '\n')
    
    notes_addition = """
15. **Исправление паразитного перетаскивания вершин Безье**:
    - Обнаружено, что в `TChartPanZoomListener.MouseUp` при отпускании левой кнопки мыши (`mbLeft`) не сбрасывался флаг перетаскивания `fIsDraggingPoint`. Это приводило к тому, что при последующих движениях мыши (даже без зажатия кнопки) вершина продолжала смещаться вслед за курсором.
    - Внедрен сброс флагов `fIsDraggingPoint := False`, `fDragTrend := nil`, `fDragPointIdx := -1` в `MouseUp`.
"""
    if "15. **Исправление паразитного перетаскивания вершин Безье**:" not in notes_content_lf:
        notes_content_lf = notes_content_lf.rstrip('\n') + "\n" + notes_addition
        
    with open(NOTES_PATH, 'wb') as f:
        f.write(notes_content_lf.replace('\n', '\r\n').encode('utf-8'))
    print("Updated notes_current.md with drag fix.")
