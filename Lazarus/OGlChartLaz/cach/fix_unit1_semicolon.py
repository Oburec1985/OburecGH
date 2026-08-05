import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

target = """          else if OglChart1.SelectedObject is cTrend then
          begin
            if Assigned(OglChart1.SelectedObject.Parent) and (OglChart1.SelectedObject.Parent is TChartAxis) then
              lSelectedAxis := TChartAxis(OglChart1.SelectedObject.Parent);
          end;
          else"""

replacement = """          else if OglChart1.SelectedObject is cTrend then
          begin
            if Assigned(OglChart1.SelectedObject.Parent) and (OglChart1.SelectedObject.Parent is TChartAxis) then
              lSelectedAxis := TChartAxis(OglChart1.SelectedObject.Parent);
          end
          else"""

if target in content_lf:
    content_lf = content_lf.replace(target, replacement)
    print("Semicolon removed.")
else:
    print("Warning: target pattern not found!")

# Save
content_crlf = content_lf.replace('\n', '\r\n')
with open(FILE_PATH, 'wb') as f:
    f.write(content_crlf.encode('cp1251'))

print("File unit1.pas saved successfully.")
