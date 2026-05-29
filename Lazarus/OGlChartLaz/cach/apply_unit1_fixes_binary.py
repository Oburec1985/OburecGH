import os

def main():
    target_file = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"
    
    with open(target_file, 'rb') as f:
        content = f.read()

    # ASCII представление старого метода
    old_after_render = b"""procedure TForm1.OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
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

    # Точные CP1251 байты для русского текста
    lbl_text_bytes = b'\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20' # "Выбранная ось: "
    lbl_text_none_bytes = b'\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20\xed\xe5\xf2' # "Выбранная ось: нет"

    # Сборка нового метода в байтах
    new_after_render = b"""procedure TForm1.OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
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
      if lblSelectedAxis.Caption <> '""" + lbl_text_bytes + b"""' + lAxis.Name then
      begin
        lblSelectedAxis.Caption := '""" + lbl_text_bytes + b"""' + lAxis.Name;
        cbLogY.Enabled := True;
        cbLogX.Enabled := True;
        cbLogY.Checked := lAxis.Scale = casLog10;
        cbLogX.Checked := lAxis.XScale = casLog10;

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
      if lblSelectedAxis.Caption <> '""" + lbl_text_none_bytes + b"""' then
      begin
        lblSelectedAxis.Caption := '""" + lbl_text_none_bytes + b"""';
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

    # Нормализуем переводы строк до CRLF в шаблонах для точного совпадения
    old_after_render = old_after_render.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
    new_after_render = new_after_render.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')

    if old_after_render in content:
        content = content.replace(old_after_render, new_after_render)
        with open(target_file, 'wb') as f:
            f.write(content)
        print("Success")
    else:
        # Пробуем найти с \n вместо \r\n на случай если в файле LF переводы строк
        old_after_render_lf = old_after_render.replace(b'\r\n', b'\n')
        if old_after_render_lf in content:
            new_after_render_lf = new_after_render.replace(b'\r\n', b'\n')
            content = content.replace(old_after_render_lf, new_after_render_lf)
            with open(target_file, 'wb') as f:
                f.write(content)
            print("Success (LF)")
        else:
            print("Error: Target content not found in file")

if __name__ == '__main__':
    main()
