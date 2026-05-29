import os

def main():
    target_file = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"
    
    with open(target_file, 'rb') as f:
        content = f.read()

    # Задаем чистый и правильный блок процедур
    good_block = b"""procedure TForm1.cbLogYChange(Sender: TObject);
var
  lAxis: TChartAxis;
begin
  if fUpdatingControls then Exit;
  if Assigned(OglChart1.SelectedObject) and (OglChart1.SelectedObject is TChartAxis) then
  begin
    lAxis := TChartAxis(OglChart1.SelectedObject);
    if cbLogY.Checked then
      lAxis.Scale := casLog10
    else
      lAxis.Scale := casLinear;
    OglChart1.Redraw;
    BuildChartTree;
  end;
end;

procedure TForm1.cbLogXChange(Sender: TObject);
var
  lAxis: TChartAxis;
begin
  if fUpdatingControls then Exit;
  if Assigned(OglChart1.SelectedObject) and (OglChart1.SelectedObject is TChartAxis) then
  begin
    lAxis := TChartAxis(OglChart1.SelectedObject);
    if cbLogX.Checked then
      lAxis.XScale := casLog10
    else
      lAxis.XScale := casLinear;
    OglChart1.Redraw;
    BuildChartTree;
  end;
end;

procedure TForm1.cbUseShaderChange(Sender: TObject);
var
  lRenderer: TOpenGLChartRenderer;
begin
  lRenderer := TOpenGLChartRenderer(OglChart1.GetRenderer);
  if Assigned(lRenderer) then
  begin
    lRenderer.UseShader := cbUseShader.Checked;
    OglChart1.Redraw;
  end;
end;

procedure TForm1.TreeView1SelectionChanged(Sender: TObject);
var
  lAxis: TChartAxis;
begin
  fUpdatingControls := True;
  try
    if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) and (TObject(TreeView1.Selected.Data) is TChartAxis) then
    begin
      lAxis := TChartAxis(TreeView1.Selected.Data);
      OglChart1.SelectedObject := lAxis;
      lblSelectedAxis.Caption := '\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20' + lAxis.Name;
      cbLogY.Enabled := True;
      cbLogX.Enabled := True;
      cbLogY.Checked := lAxis.Scale = casLog10;
      cbLogX.Checked := lAxis.XScale = casLog10;
    end
    else
    begin
      lblSelectedAxis.Caption := '\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20\xed\xe5\xf2';
      cbLogY.Enabled := False;
      cbLogX.Enabled := False;
      cbLogY.Checked := False;
      cbLogX.Checked := False;
    end;
  finally
    fUpdatingControls := False;
  end;
end;

"""
    # Заменяем esc-коды в good_block на сырые байты cp1251
    good_block = good_block.replace(b'\\xc2\\xfb\\xe1\\xf0\\xe0\\xed\\xed\\xe0\\xff\\x20\\xee\\xf1\\xfc\\x3a\\x20', b'\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20')
    good_block = good_block.replace(b'\\xc2\\xfb\\xe1\\xf0\\xe0\\xed\\xed\\xe0\\xff\\x20\\xee\\xf1\\xfc\\x3a\\x20\\xed\\xe5\\xf2', b'\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20\xed\xe5\xf2')
    good_block = good_block.replace(b'\n', b'\r\n')

    # Ищем начало поврежденного фрагмента
    bad_start_markers = [
        b'"procedure TForm1.cbLogYChange',
        b'procedure TForm1.cbLogYChange',
    ]
    idx_start = -1
    for m in bad_start_markers:
        if m in content:
            idx_start = content.index(m)
            break

    # Ищем конец поврежденного фрагмента (начало MouseMove)
    end_marker = b"procedure TForm1.OglChart1MouseMove"
    if end_marker in content and idx_start != -1:
        idx_end = content.index(end_marker)
        
        new_content = content[:idx_start] + good_block + content[idx_end:]
        with open(target_file, 'wb') as f:
            f.write(new_content)
        print("unit1.pas clean replacement success!")
    else:
        print("Error: markers not found")

if __name__ == '__main__':
    main()
