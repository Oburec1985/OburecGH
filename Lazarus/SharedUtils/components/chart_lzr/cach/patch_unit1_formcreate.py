# -*- coding: utf-8 -*-
import os

file_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

if not os.path.exists(file_path):
    print("Error: unit1.pas not found")
    exit(1)

with open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

target = """procedure TForm1.FormCreate(Sender: TObject);
begin
  CreateTestChart(OglChart1);
  OglChart1.OnMouseMove := @OglChart1MouseMove;
  OglChart1.OnAfterRender := @OglChart1AfterRender;
  fMouseCoordsText := 'Chart px: (0, 0) | Page: NAN | Axis Val: (X: NAN, Y: NAN)';
  fFpsText := 'Render: 0.00 ms (0.0 FPS)';
  UpdateStatusBar;
  TreeView1.MultiSelect := True;
  TreeView1.Images := ImageList1;
  TreeView1.Font.Size := 10;
  btnRefreshTree.Visible := True;
  BuildChartTree;
end;"""

replacement = """procedure TForm1.FormCreate(Sender: TObject);
var
  i, j: Integer;
  lPage: TChartPage;
begin
  CreateTestChart(OglChart1);
  OglChart1.OnMouseMove := @OglChart1MouseMove;
  OglChart1.OnAfterRender := @OglChart1AfterRender;
  fMouseCoordsText := 'Chart px: (0, 0) | Page: NAN | Axis Val: (X: NAN, Y: NAN)';
  fFpsText := 'Render: 0.00 ms (0.0 FPS)';
  UpdateStatusBar;
  TreeView1.MultiSelect := True;
  TreeView1.Images := ImageList1;
  TreeView1.Font.Size := 10;
  btnRefreshTree.Visible := True;
  BuildChartTree;

  // Programmatic selection check for testing
  if GetEnvironmentVariable('CHART_TEST_SELECT_AXIS') = '1' then
  begin
    for i := 0 to OglChart1.Model.ChildCount - 1 do
      if OglChart1.Model.Children[i] is TChartPage then
      begin
        lPage := TChartPage(OglChart1.Model.Children[i]);
        for j := 0 to lPage.ChildCount - 1 do
          if lPage.Children[j].Name = 'PerfAxis1DAxisY' then
          begin
            OglChart1.SelectedObject := lPage.Children[j];
            Break;
          end;
      end;
  end;
end;"""

if target in content:
    content = content.replace(target, replacement)
    with open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
        f.write(content)
    print("Successfully patched FormCreate in unit1.pas!")
else:
    print("Target string not found in unit1.pas.")
