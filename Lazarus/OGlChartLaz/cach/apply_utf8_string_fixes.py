import os

def main():
    target_file = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"
    
    with open(target_file, 'rb') as f:
        content = f.read()

    # Точные UTF-8 байты для русского текста
    lbl_text_bytes = b'\xd0\x92\xd1\x8b\xd0\xb1\xd1\x80\xd0\xb0\xd0\xbd\xd0\xbd\xd0\xb0\xd1\x8f\x20\xd0\xbe\xd1\x81\xd1\x8c\x3a\x20' # "Выбранная ось: "
    lbl_text_none_bytes = b'\xd0\x92\xd1\x8b\xd0\xb1\xd1\x80\xd0\xb0\xd0\xbd\xd0\xbd\xd0\xb0\xd1\x8f\x20\xd0\xbe\xd1\x81\xd1\x8c\x3a\x20\xd0\xbd\xd0\xb5\xd1\x82' # "Выбранная ось: нет"

    # 1. Заменяем процедуру cbLogYChange, cbLogXChange, cbUseShaderChange, TreeView1SelectionChanged
    # Мы найдем начало блока от procedure TForm1.cbLogYChange до начала OglChart1MouseMove
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
      lblSelectedAxis.Caption := '""" + lbl_text_bytes + b"""' + lAxis.Name;
      cbLogY.Enabled := True;
      cbLogX.Enabled := True;
      cbLogY.Checked := lAxis.Scale = casLog10;
      cbLogX.Checked := lAxis.XScale = casLog10;
    end
    else
    begin
      lblSelectedAxis.Caption := '""" + lbl_text_none_bytes + b"""';
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
    good_block = good_block.replace(b'\n', b'\r\n')

    # Ищем начало блока
    idx_start = content.index(b"procedure TForm1.cbLogYChange")
    idx_end = content.index(b"procedure TForm1.OglChart1MouseMove")
    content = content[:idx_start] + good_block + content[idx_end:]

    # 2. Заменяем процедуру OglChart1AfterRender
    # Ищем начало
    after_render_start = b"procedure TForm1.OglChart1AfterRender"
    idx_ar_start = content.index(after_render_start)
    # Ищем конец процедуры (до function AxisScaleToText)
    idx_ar_end = content.index(b"function AxisScaleToText", idx_ar_start)

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
          if TreeView1.Items[i].Data = Pointer(lAxis) then
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
        if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) and
           ((TObject(TreeView1.Selected.Data) is TChartAxis) or (TObject(TreeView1.Selected.Data) is cTrend)) then
          TreeView1.Selected := nil;
      end;
    end;
  finally
    fUpdatingControls := False;
  end;
end;

"""
    new_after_render = new_after_render.replace(b'\n', b'\r\n')
    content = content[:idx_ar_start] + new_after_render + content[idx_ar_end:]

    with open(target_file, 'wb') as f:
        f.write(content)
    print("UTF-8 string literals and selection fix applied successfully!")

if __name__ == '__main__':
    main()
