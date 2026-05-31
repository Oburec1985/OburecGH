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
  function FindNodeByName(AObject: TChartBaseObject; const AName: string): TChartBaseObject;
  var
    lIndex: Integer;
    lRes: TChartBaseObject;
  begin
    Result := nil;
    if not Assigned(AObject) then Exit;
    if AObject.Name = AName then
    begin
      Result := AObject;
      Exit;
    end;
    for lIndex := 0 to AObject.ChildCount - 1 do
    begin
      lRes := FindNodeByName(AObject.Children[lIndex], AName);
      if Assigned(lRes) then
      begin
        Result := lRes;
        Exit;
      end;
    end;
  end;
var
  lFound: TChartBaseObject;
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

  // Always select PerfAxis1DAxisY on startup for testing zoom isolation
  lFound := FindNodeByName(OglChart1.Model, 'PerfAxis1DAxisY');
  if Assigned(lFound) then
  begin
    OglChart1.SelectedObject := lFound;
    UpdateStatusBar;
  end;
end;"""

if target in content:
    content = content.replace(target, replacement)
    with open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
        f.write(content)
    print("Successfully patched FormCreate with recursive finder and UpdateStatusBar!")
else:
    print("Target string not found in unit1.pas.")
