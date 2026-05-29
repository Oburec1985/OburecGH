import os
import re

def fix_mixed_text(raw_bytes):
    # First, decode as cp1251 to get lines
    text_cp1251 = raw_bytes.decode('cp1251', errors='replace')
    lines = text_cp1251.split('\n')
    fixed_lines = []
    
    for line in lines:
        try:
            # Check if this line contains CP1251-misinterpreted UTF-8 sequences
            # e.g., 'РџСЂРѕРІРµСЂСЏРµРј' -> encodes to UTF-8 bytes -> decodes as UTF-8
            line_bytes = line.encode('cp1251')
            line_utf8 = line_bytes.decode('utf-8')
            # If it succeeded and looks like it actually recovered some cyrillic
            if any(ord(c) >= 0x0400 and ord(c) <= 0x04FF for c in line_utf8):
                fixed_lines.append(line_utf8)
            else:
                fixed_lines.append(line)
        except Exception:
            fixed_lines.append(line)
            
    return '\n'.join(fixed_lines)

def process_file(filename, replacements):
    print(f"Repairing and processing {os.path.basename(filename)}...")
    with open(filename, 'rb') as f:
        raw_data = f.read()
        
    fixed_text = fix_mixed_text(raw_data)
    
    # Normalize line endings to LF
    text = fixed_text.replace('\r\n', '\n').replace('\r', '\n')
    
    # Apply replacements
    for old, new, desc in replacements:
        old_lf = old.replace('\r\n', '\n').replace('\r', '\n').strip()
        new_lf = new.replace('\r\n', '\n').replace('\r', '\n').strip()
        if old_lf in text:
            text = text.replace(old_lf, new_lf)
            print(f"  OK: {desc}")
        else:
            # Try matching with flexible whitespace/newlines
            pattern = re.escape(old_lf).replace(r'\ ', r'\s+').replace(r'\n', r'\s*\n\s*')
            match = re.search(pattern, text)
            if match:
                text = text[:match.start()] + new_lf + text[match.end():]
                print(f"  OK (regex match): {desc}")
            else:
                print(f"  FAIL: {desc}")
                print("--- TARGET NOT FOUND ---")
                print(old_lf[:150])
                print("------------------------")
                
    # Normalize line endings to CRLF
    text = text.replace('\n', '\r\n')
    
    # Save back as Windows-1251 (CP1251) without BOM
    with open(filename, 'w', encoding='cp1251', newline='') as f:
        f.write(text)
    print(f"  Saved {os.path.basename(filename)} in CP1251 successfully.")

# ----------------- Path variables -----------------
COMP_DIR = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr"
FL_PATH = os.path.join(COMP_DIR, "uOglChartFrameListener.pas")
RD_PATH = os.path.join(COMP_DIR, "uOglChartRenderer.pas")

# ----------------- uOglChartFrameListener.pas Replacements -----------------
fl_reps = [
    # 1. Update TChartSelectListener.MouseDown
    (
        """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
begin
  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    // 1. Проверяем попадание в текстовые метки (оси, значения)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // Не помечаем как Handled, чтобы сработал стандартный текстовый редактор рендера!
      Exit;
    end;

    // 2. Проверяем попадание в саму страницу
    lModel := TChartModel(lControl.GetModel);
    if Assigned(lModel) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
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

    // Снимаем выделение, если кликнули по пустому месту
    if Assigned(lRenderer.SelectedObject) then
    begin
      lRenderer.SelectedObject := nil;
      lControl.Redraw;
    end;
  end;
end;""",
        """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
begin
  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    // 1. Проверяем попадание в текстовые метки (оси, значения)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // Не помечаем как Handled, чтобы сработал стандартный текстовый редактор рендера!
      Exit;
    end;

    // 2. Проверяем попадание в саму страницу
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
    end;

    // Снимаем выделение, если кликнули по пустому месту
    if Assigned(lRenderer.SelectedObject) then
    begin
      lRenderer.SelectedObject := nil;
      lControl.Redraw;
    end;
  end;
end;""",
        "TChartSelectListener.MouseDown: added locked checks"
    ),
    
    # 2. Update TChartSelectListener.MouseMove
    (
        """procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lNewHover: TChartBaseObject;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    lNewHover := nil;

    // 1. Проверяем попадание в текстовые метки
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) then
        lNewHover := lHit.Axis
      else if Assigned(lHit.Page) then
        lNewHover := lHit.Page;
    end;

    // 2. Если метка не найдена, проверяем саму страницу
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
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

    if lRenderer.HoveredObject <> lNewHover then
    begin
      lRenderer.HoveredObject := lNewHover;
      lControl.Redraw;
    end;
  end;
end;""",
        """procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lNewHover: TChartBaseObject;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    lNewHover := nil;

    // 1. Проверяем попадание в текстовые метки
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lNewHover := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lNewHover := lHit.Page;
    end;

    // 2. Если метка не найдена, проверяем саму страницу
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
  end;
end;""",
        "TChartSelectListener.MouseMove: added locked checks"
    ),

    # 3. Update TChartPanZoomListener.MouseDown
    (
        """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if Button = mbLeft then
    begin
      // 1. Изменение размеров выделенной страницы
      if (fResizingBorder > 0) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
      begin
        fIsResizing := True;
        fActivePage := TChartPage(lRenderer.SelectedObject);

        for lInnerIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lInnerIndex] is TChartPage then
            TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

        fLastX := X;
        fLastY := Y;
        Handled := True;
        Exit;
      end;

      // 2. Если зажат Ctrl, проверяем клик: внутри plot area (зум) или снаружи (перетаскивание страницы)
      if ssCtrl in Shift then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lContentRect := lRenderer.GetPageContentRect(lPage);
              if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                 (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
              begin
                // Клик внутри области построения - начинаем выделение зума
                fIsZoomSelecting := True;
                fZoomStartX := X;
                fZoomStartY := Y;
                fActivePage := lPage;
                Handled := True;
                Exit;
              end
              else
              begin
                // Клик вне области построения - перемещаем страницу
                fMovingPage := True;
                fActivePage := lPage;

                for lInnerIndex := 0 to lModel.ChildCount - 1 do
                  if lModel.Children[lInnerIndex] is TChartPage then
                    TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

                fLastX := X;
                fLastY := Y;
                TControl(ASender).Cursor := crSizeAll;
                Handled := True;
                Exit;
              end;
            end;
          end;
      end;
    end;

    if (Button = mbRight) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          lPageRect := lRenderer.GetPageRect(lPage);
          if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
             (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          begin
            fIsPanning := True;
            fLastX := X;
            fLastY := Y;
            fActivePage := lPage;
            Handled := True;
            Exit;
          end;
        end;
    end;
  end;
end;""",
        """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if Button = mbLeft then
    begin
      // 1. Изменение размеров выделенной страницы
      if (fResizingBorder > 0) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
      begin
        lPage := TChartPage(lRenderer.SelectedObject);
        if not lPage.Locked then
        begin
          fIsResizing := True;
          fActivePage := lPage;

          for lInnerIndex := 0 to lModel.ChildCount - 1 do
            if lModel.Children[lInnerIndex] is TChartPage then
              TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

          fLastX := X;
          fLastY := Y;
          Handled := True;
          Exit;
        end;
      end;

      // 2. Если зажат Ctrl, то это режим зума по рамке (только внутри plot area)
      if ssCtrl in Shift then
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
                lContentRect := lRenderer.GetPageContentRect(lPage);
                if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                   (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
                begin
                  // Клик внутри области построения - начинаем выделение зума
                  fIsZoomSelecting := True;
                  fZoomStartX := X;
                  fZoomStartY := Y;
                  fActivePage := lPage;
                  Handled := True;
                  Exit;
                end;
              end;
            end;
          end;
      end;

      // 3. Если зажат Shift, то это режим перемещения страницы
      if ssShift in Shift then
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
                fMovingPage := True;
                fActivePage := lPage;

                for lInnerIndex := 0 to lModel.ChildCount - 1 do
                  if lModel.Children[lInnerIndex] is TChartPage then
                    TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

                fLastX := X;
                fLastY := Y;
                TControl(ASender).Cursor := crSizeAll;
                Handled := True;
                Exit;
              end;
            end;
          end;
      end;
    end;

    if (Button = mbRight) then
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
              fIsPanning := True;
              fLastX := X;
              fLastY := Y;
              fActivePage := lPage;
              Handled := True;
              Exit;
            end;
          end;
        end;
    end;
  end;
end;""",
        "TChartPanZoomListener.MouseDown: shifted move to Shift key and added locked checks"
    ),

    # 4. Update TChartPanZoomListener.MouseMove (Cursor changes)
    (
        """      else if ssCtrl in Shift then
      begin
        // Если курсор внутри выделенной страницы с зажатым Ctrl
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          TControl(ASender).Cursor := crSizeAll
        else
          TControl(ASender).Cursor := crDefault;
      end
      else
        TControl(ASender).Cursor := crDefault;
    end
    else
    begin
      // Если выделенной страницы нет, но зажат Ctrl, меняем курсор над любой страницей
      lPage := nil;
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lTempPage := TChartPage(lModel.Children[lIndex]);
          lPageRect := lRenderer.GetPageRect(lTempPage);
          if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
             (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          begin
            lPage := lTempPage;
            Break;
          end;
        end;

      if Assigned(lPage) and (ssCtrl in Shift) then
        TControl(ASender).Cursor := crSizeAll
      else
        TControl(ASender).Cursor := crDefault;
    end;""",
        """      else if ssShift in Shift then
      begin
        // Если курсор внутри выделенной страницы с зажатым Shift
        if not TChartPage(lRenderer.SelectedObject).Locked and
           (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          TControl(ASender).Cursor := crSizeAll
        else
          TControl(ASender).Cursor := crDefault;
      end
      else
        TControl(ASender).Cursor := crDefault;
    end
    else
    begin
      // Если выделенной страницы нет, но зажат Shift, меняем курсор над любой незаблокированной страницей
      lPage := nil;
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lTempPage := TChartPage(lModel.Children[lIndex]);
          if not lTempPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lTempPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lPage := lTempPage;
              Break;
            end;
          end;
        end;

      if Assigned(lPage) and (ssShift in Shift) then
        TControl(ASender).Cursor := crSizeAll
      else
        TControl(ASender).Cursor := crDefault;
    end;""",
        "TChartPanZoomListener.MouseMove: cursor changes on Shift key, check Locked"
    ),

    # 5. Update TChartPanZoomListener.MouseWheel
    (
        """    if Assigned(lPage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(lPage);""",
        """    if Assigned(lPage) and not lPage.Locked then
    begin
      lContentRect := lRenderer.GetPageContentRect(lPage);""",
        "TChartPanZoomListener.MouseWheel: skip locked pages"
    )
]

# ----------------- uOglChartRenderer.pas Replacements -----------------
rd_reps = [
    # 1. AddTextHit: add padding around text
    (
        """  fTextHits[lIndex].Rect.Left := Floor(AX);
  fTextHits[lIndex].Rect.Top := Floor(AY);
  fTextHits[lIndex].Rect.Right := Ceil(AX + AFont.TextPixelWidth(AText));
  fTextHits[lIndex].Rect.Bottom := Ceil(AY + AFont.TextPixelHeight);""",
        """  fTextHits[lIndex].Rect.Left := Floor(AX) - 4;
  fTextHits[lIndex].Rect.Top := Floor(AY) - 3;
  fTextHits[lIndex].Rect.Right := Ceil(AX + AFont.TextPixelWidth(AText)) + 4;
  fTextHits[lIndex].Rect.Bottom := Ceil(AY + AFont.TextPixelHeight) + 3;""",
        "AddTextHit: added padding (X: 4, Y: 3) around text hit rect"
    ),
    
    # 2. GetTextHitAt: skip locked hits
    (
        """function TOpenGLChartRenderer.GetTextHitAt(AX, AY: Integer; out AHit: TChartTextHit): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
       (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      AHit := fTextHits[I];
      Result := True;
      Exit;
    end;
end;""",
        """function TOpenGLChartRenderer.GetTextHitAt(AX, AY: Integer; out AHit: TChartTextHit): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
       (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      if Assigned(fTextHits[I].Axis) and fTextHits[I].Axis.Locked then Continue;
      if Assigned(fTextHits[I].Page) and fTextHits[I].Page.Locked then Continue;
      AHit := fTextHits[I];
      Result := True;
      Exit;
    end;
end;""",
        "GetTextHitAt: skip locked text hits"
    ),

    # 3. MouseDown in renderer: skip locked hits
    (
        """function TOpenGLChartRenderer.MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  fActiveHit.Axis := nil;
  fActiveHit.Page := nil;
  fActiveHit.Kind := celNone;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
      (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      fActiveHit := fTextHits[I];""",
        """function TOpenGLChartRenderer.MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  fActiveHit.Axis := nil;
  fActiveHit.Page := nil;
  fActiveHit.Kind := celNone;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
      (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      if Assigned(fTextHits[I].Axis) and fTextHits[I].Axis.Locked then Continue;
      if Assigned(fTextHits[I].Page) and fTextHits[I].Page.Locked then Continue;
      fActiveHit := fTextHits[I];""",
        "TOpenGLChartRenderer.MouseDown: skip locked hits"
    ),

    # 4. DrawHighlights: draw background under axis labels and make selected axis line width 1.5
    (
        """  // 1. Highlight hovered page or axis text hit
  if Assigned(lHovered) then
  begin
    if lHovered is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lHovered));
      DrawHighlightRect(lPageRect, $50FFCC00); // semi-transparent yellow highlight frame
    end
    else if lHovered is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lHovered then
          DrawHighlightRect(fTextHits[lIndex].Rect, $80FFCC00);
    end;
  end;

  // 2. Highlight selected page or axis text hit
  if Assigned(lSelected) then
  begin
    if lSelected is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lSelected));
      SetGLColor($FFFF3300); // Bold orange/red border
      glLineWidth(3);
      DrawRect(lPageRect);
    end
    else if lSelected is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lSelected then
        begin
          SetGLColor($FFFF3300);
          glLineWidth(3);
          DrawRect(fTextHits[lIndex].Rect);
        end;
    end;
  end;""",
        """  // 1. Highlight hovered page or axis text hit
  if Assigned(lHovered) then
  begin
    if lHovered is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lHovered));
      DrawHighlightRect(lPageRect, $50FFCC00); // semi-transparent yellow highlight frame
    end
    else if lHovered is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lHovered then
        begin
          glEnable(GL_BLEND);
          glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
          SetGLColor($C0FFFFFF); // полупрозрачный белый фон под текстом
          FillRect(fTextHits[lIndex].Rect);
          glDisable(GL_BLEND);
          DrawHighlightRect(fTextHits[lIndex].Rect, $80FFCC00);
        end;
    end;
  end;

  // 2. Highlight selected page or axis text hit
  if Assigned(lSelected) then
  begin
    if lSelected is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lSelected));
      SetGLColor($FFFF3300); // Bold orange/red border
      glLineWidth(3);
      DrawRect(lPageRect);
    end
    else if lSelected is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lSelected then
        begin
          glEnable(GL_BLEND);
          glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
          SetGLColor($F0FFFFFF); // непрозрачный белый фон под текстом
          FillRect(fTextHits[lIndex].Rect);
          glDisable(GL_BLEND);
          SetGLColor($FFFF3300);
          glLineWidth(1.5);
          DrawRect(fTextHits[lIndex].Rect);
        end;
    end;
  end;""",
        "DrawHighlights: added label background fill and reduced axis frame line width to 1.5"
    ),

    # 5. DrawAxes var section: add local variables for axis fonts, offsets and widths
    (
        """procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
const
  CTick = 5;
var
  lIndex: Integer;
  I: Integer;
  lX: Single;
  lY: Single;
  lPrimaryAxis: TChartAxis;
  lYAxis: TChartAxis;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
  lFont: cOglFont;
  lText: string;
begin""",
        """procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
const
  CTick = 5;
var
  lIndex: Integer;
  I: Integer;
  lX: Single;
  lY: Single;
  lPrimaryAxis: TChartAxis;
  lYAxis: TChartAxis;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
  lFont: cOglFont;
  lText: string;
  lAxisFont, lXFont: cOglFont;
  lAxisX, lAxisOffset: Single;
  lMaxTextWidth, lTextWidth: Integer;
begin""",
        "DrawAxes: added new local variables to var section"
    ),

    # 6. DrawAxes body: update horizontal axis font and vertical axes rendering with offset
    (
        """  lFont := fFontMng.Font(cfGridTick);
  for lIndex := 0 to High(lXTicks) do
  begin
    lText := lXTicks[lIndex].Text;
    lX := XValueToPixel(APage, lPrimaryAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right) -
      lFont.TextPixelWidth(lText) / 2;
      
    if (Assigned(lPrimaryAxis) and lPrimaryAxis.UseOwnX) then
    begin
      if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lPrimaryAxis, nil, celXMin)
      else if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lPrimaryAxis, nil, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lFont);
    end
    else
    begin
      if Abs(lXTicks[lIndex].Value - APage.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, nil, APage, celXMin)
      else if Abs(lXTicks[lIndex].Value - APage.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, nil, APage, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lFont);
    end;
  end;

  // Draw all Y axes
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lYAxis := TChartAxis(APage.Children[I]);
      BuildAxisTicks(lYAxis, 8, lYTicks);

      SetGLColor($FF404040);
      glLineWidth(1);
      for lIndex := 0 to High(lYTicks) do
      begin
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
        DrawLine(ARect.Left - CTick, lY, ARect.Left, lY);
      end;

      for lIndex := 0 to High(lYTicks) do
      begin
        lText := lYTicks[lIndex].Text;
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top) -
          lFont.TextPixelHeight / 2;
        if Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9 then
          DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMin)
        else if Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9 then
          DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMax)
        else
          DrawText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont);
      end;
    end;""",
        """  // Выбор шрифта для шкалы X
  if (Assigned(lPrimaryAxis) and lPrimaryAxis.UseOwnX) then
  begin
    if lPrimaryAxis = fSelectedObject then
      lXFont := fFontMng.Font(cfAxisSelected)
    else
      lXFont := fFontMng.Font(cfAxisLabel);
    lXFont.Color := lPrimaryAxis.Color;
  end
  else
    lXFont := fFontMng.Font(cfGridTick);

  for lIndex := 0 to High(lXTicks) do
  begin
    lText := lXTicks[lIndex].Text;
    lX := XValueToPixel(APage, lPrimaryAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right) -
      lXFont.TextPixelWidth(lText) / 2;
      
    if (Assigned(lPrimaryAxis) and lPrimaryAxis.UseOwnX) then
    begin
      if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lXFont, lPrimaryAxis, nil, celXMin)
      else if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lXFont, lPrimaryAxis, nil, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lXFont);
    end
    else
    begin
      if Abs(lXTicks[lIndex].Value - APage.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lXFont, nil, APage, celXMin)
      else if Abs(lXTicks[lIndex].Value - APage.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lXFont, nil, APage, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lXFont);
    end;
  end;

  // Отрисовка всех осей Y со смещением по горизонтали
  lAxisOffset := 0;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lYAxis := TChartAxis(APage.Children[I]);
      BuildAxisTicks(lYAxis, 8, lYTicks);

      if lYAxis = fSelectedObject then
        lAxisFont := fFontMng.Font(cfAxisSelected)
      else
        lAxisFont := fFontMng.Font(cfAxisLabel);
      lAxisFont.Color := lYAxis.Color;

      lAxisX := ARect.Left - lAxisOffset;

      // Рисуем вертикальную линию оси Y цветом оси
      SetGLColor(lYAxis.Color);
      glLineWidth(1.5);
      DrawLine(lAxisX, ARect.Top, lAxisX, ARect.Bottom);

      // Рисуем засечки цветом оси
      glLineWidth(1);
      for lIndex := 0 to High(lYTicks) do
      begin
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
        DrawLine(lAxisX - CTick, lY, lAxisX, lY);
      end;

      lMaxTextWidth := 0;
      for lIndex := 0 to High(lYTicks) do
      begin
        lText := lYTicks[lIndex].Text;
        lTextWidth := lAxisFont.TextPixelWidth(lText);
        if lTextWidth > lMaxTextWidth then
          lMaxTextWidth := lTextWidth;

        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top) -
          lAxisFont.TextPixelHeight / 2;
        if Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9 then
          DrawEditableText(lText, lAxisX - lTextWidth - 7, lY, lAxisFont, lYAxis, nil, celAxisMin)
        else if Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9 then
          DrawEditableText(lText, lAxisX - lTextWidth - 7, lY, lAxisFont, lYAxis, nil, celAxisMax)
        else
          DrawText(lText, lAxisX - lTextWidth - 7, lY, lAxisFont);
      end;

      lAxisOffset := lAxisOffset + lMaxTextWidth + 15;
    end;""",
        "DrawAxes: updated vertical axes rendering to support horizontal offsets, colored lines/ticks and fonts"
    )
]

try:
    process_file(FL_PATH, fl_reps)
    process_file(RD_PATH, rd_reps)
    print("ALL REPAIRS AND UPDATES APPLIED SUCCESSFULLY!")
except Exception as e:
    import traceback
    traceback.print_exc()
    print("FAILED")
