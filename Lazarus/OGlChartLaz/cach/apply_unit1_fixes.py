import os

def main():
    target_file = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"
    
    # Используем latin-1 для побайтовой точности чтения/записи
    with open(target_file, 'r', encoding='latin-1') as f:
        content = f.read()

    # В latin-1 русские буквы декодируются в символы расширенного ASCII, но заменяемый английский код останется прежним.
    # Чтобы не иметь проблем со спецсимволами, заменим только английскую часть.
    old_after_render = """procedure TForm1.OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
var
  lFps: Double;
begin
  if ARenderTimeMs > 0 then
    lFps := 1000.0 / ARenderTimeMs
  else
    lFps := 0;
  fFpsText := Format('Render: %.2f ms (%.1f FPS)', [ARenderTimeMs, lFps]);
  UpdateStatusBar;
end;"""

    # Для русского комментария внутри нового кода перекодируем его из cp1251 в latin-1 представление:
    comment1 = "Синхронизация UI с выбранным объектом в OglChart1".encode('cp1251').decode('latin-1')
    comment2 = "Синхронизируем выделение в дереве TreeView1".encode('cp1251').decode('latin-1')
    lbl_text = "Выбранная ось: ".encode('cp1251').decode('latin-1')
    lbl_text_none = "Выбранная ось: нет".encode('cp1251').decode('latin-1')

    new_after_render = f"""procedure TForm1.OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
var
  lFps: Double;
  lSelected: TChartBaseObject;
  lAxis: TChartAxis;
  i: Integer;
  lNodeToSelect: TTreeNode;
begin
  if ARenderTimeMs > 0 then
    lFps := 1000.0 / ARenderTimeMs
  else
    lFps := 0;
  fFpsText := Format('Render: %.2f ms (%.1f FPS)', [ARenderTimeMs, lFps]);
  UpdateStatusBar;

  // {comment1}
  lSelected := TChartBaseObject(OglChart1.SelectedObject);
  lAxis := nil;
  if Assigned(lSelected) then
  begin
    if lSelected is TChartAxis then
      lAxis := TChartAxis(lSelected)
    else if (lSelected is cTrend) and Assigned(lSelected.Parent) and (lSelected.Parent is TChartAxis) then
      lAxis := TChartAxis(lSelected.Parent);
  end;

  fUpdatingControls := True;
  try
    if Assigned(lAxis) then
    begin
      if lblSelectedAxis.Caption <> '{lbl_text}' + lAxis.Name then
      begin
        lblSelectedAxis.Caption := '{lbl_text}' + lAxis.Name;
        cbLogY.Enabled := True;
        cbLogX.Enabled := True;
        cbLogY.Checked := lAxis.Scale = casLog10;
        cbLogX.Checked := lAxis.XScale = casLog10;

        // {comment2}
        lNodeToSelect := nil;
        for i := 0 to TreeView1.Items.Count - 1 do
        begin
          if TreeView1.Items[i].Data = lAxis then
          begin
            lNodeToSelect := TreeView1.Items[i];
            Break;
          end;
        end;
        if Assigned(lNodeToSelect) and (TreeView1.Selected <> lNodeToSelect) then
          TreeView1.Selected := lNodeToSelect;
      end;
    end
    else
    begin
      if lblSelectedAxis.Caption <> '{lbl_text_none}' then
      begin
        lblSelectedAxis.Caption := '{lbl_text_none}';
        cbLogY.Enabled := False;
        cbLogX.Enabled := False;
        cbLogY.Checked := False;
        cbLogX.Checked := False;
        if TreeView1.Selected <> nil then
          TreeView1.Selected := nil;
      end;
    end;
  finally
    fUpdatingControls := False;
  end;
end;"""

    content = content.replace(old_after_render, new_after_render)

    with open(target_file, 'w', encoding='latin-1', newline='\r\n') as f:
        f.write(content)
        
    print("Success")

if __name__ == '__main__':
    main()
