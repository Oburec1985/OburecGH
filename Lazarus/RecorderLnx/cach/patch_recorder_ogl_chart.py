# -*- coding: utf-8 -*-
import os

file_path = r"d:\works\OburecGH\Lazarus\RecorderLnx\UI\uRecorderOglOscillogramView.pas"

if not os.path.exists(file_path):
    print("Error: uRecorderOglOscillogramView.pas not found")
    exit(1)

with open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# 1. Update uses clause
target_uses = """uses
  Classes, Controls, ExtCtrls,
  uOglChart, uRecorderFormModel, uRecorderTags;"""

repl_uses = """uses
  Classes, Controls, ExtCtrls, StdCtrls,
  uOglChart, uRecorderFormModel, uRecorderTags;"""

if target_uses in content:
    content = content.replace(target_uses, repl_uses)
    print("Uses clause replaced successfully.")
else:
    # Try with different spacing/newlines if any
    print("Warning: Target uses clause not found exactly.")

# 2. Update private section of class declaration
target_private = """  private
    fAbsoluteTagName: string;
    fBindingMode: TRecorderTagBindingMode;
    fChart: TOglChart;
    fFrameNo: Integer;
    fTagOffset: Integer;
    fTagSlotIndex: Integer;
    fModel: TObject;
    fPage: TObject;
    fAxis: TObject;
    fTrend: TObject;
    function ResolveTag(ATagRegistry: TRecorderTagRegistry): TRecorderTag;
    procedure SetAxisRange(AMinValue, AMaxValue: Double);
    procedure SetChartTitle(const ATitle: string);
    procedure SetXRange(ADisplaySeconds: Double);"""

repl_private = """  private
    fAbsoluteTagName: string;
    fBindingMode: TRecorderTagBindingMode;
    fChart: TOglChart;
    fInfoLabel: TLabel;
    fCurrentTagName: string;
    fFrameNo: Integer;
    fTagOffset: Integer;
    fTagSlotIndex: Integer;
    fModel: TObject;
    fPage: TObject;
    fAxis: TObject;
    fTrend: TObject;
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    function ResolveTag(ATagRegistry: TRecorderTagRegistry): TRecorderTag;
    procedure SetAxisRange(AMinValue, AMaxValue: Double);
    procedure SetChartTitle(const ATitle: string);
    procedure SetXRange(ADisplaySeconds: Double);"""

if target_private in content:
    content = content.replace(target_private, repl_private)
    print("Class private section replaced successfully.")
else:
    print("Warning: Class private section not found exactly.")

# 3. Update ConfigureDefault implementation
target_config = """procedure TRecorderOglOscillogram.ConfigureDefault;
var
  lChart: TOglChart;
  lModel: TChartModel;
  lPageArea: TChartFloatRect;
  lPage: TChartPage;
  lAxis: TChartAxis;
  lTrend: cBuffTrend1d;
begin
  while ControlCount > 0 do
    Controls[0].Free;

  lChart := TOglChart.Create(Self);
  lChart.Parent := Self;
  lChart.Align := alClient;
  lChart.AutoResizeViewport := True;"""

repl_config = """procedure TRecorderOglOscillogram.ConfigureDefault;
var
  lChart: TOglChart;
  lModel: TChartModel;
  lPageArea: TChartFloatRect;
  lPage: TChartPage;
  lAxis: TChartAxis;
  lTrend: cBuffTrend1d;
begin
  while ControlCount > 0 do
    Controls[0].Free;

  fInfoLabel := TLabel.Create(Self);
  fInfoLabel.Parent := Self;
  fInfoLabel.Align := alTop;
  fInfoLabel.Font.Name := 'Segoe UI';
  fInfoLabel.Font.Size := 9;
  fInfoLabel.Font.Style := [fsBold];
  fInfoLabel.Font.Color := $00404040;
  fInfoLabel.BorderSpacing.Around := 4;
  fInfoLabel.Caption := 'Tag: None | FPS: 0.0';

  lChart := TOglChart.Create(Self);
  lChart.Parent := Self;
  lChart.Align := alClient;
  lChart.AutoResizeViewport := True;
  lChart.OnAfterRender := @ChartAfterRender;"""

if target_config in content:
    content = content.replace(target_config, repl_config)
    print("ConfigureDefault implementation replaced successfully.")
else:
    print("Warning: ConfigureDefault implementation not found exactly.")

# 4. Insert ChartAfterRender implementation and update ResolveTag placement
target_resolvetag = """function TRecorderOglOscillogram.ResolveTag("""

repl_resolvetag = """procedure TRecorderOglOscillogram.ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
var
  lFps: Double;
  lTagName: string;
begin
  if ARenderTimeMs > 0 then
    lFps := 1000.0 / ARenderTimeMs
  else
    lFps := 0;

  if fCurrentTagName <> '' then
    lTagName := fCurrentTagName
  else
    lTagName := 'None';

  fInfoLabel.Caption := Format('Tag: %s | FPS: %.1f (%.2f ms)', [lTagName, lFps, ARenderTimeMs]);
end;

function TRecorderOglOscillogram.ResolveTag("""

if target_resolvetag in content and "procedure TRecorderOglOscillogram.ChartAfterRender" not in content:
    content = content.replace(target_resolvetag, repl_resolvetag, 1)
    print("ChartAfterRender implementation inserted successfully.")
else:
    print("Warning: ResolveTag not found or ChartAfterRender already exists.")

# 5. Update Refresh implementation
target_refresh = """  lTag := ResolveTag(ATagRegistry);
  if lTag = nil then
  begin
    SetChartTitle(Format('No tag frame:%d', [fFrameNo]));
    SetAxisRange(-1, 1);
    if fChart is TOglChart then
      TOglChart(fChart).Redraw;
    Exit;
  end;"""

repl_refresh = """  lTag := ResolveTag(ATagRegistry);
  if lTag = nil then
  begin
    fCurrentTagName := '';
    SetChartTitle(Format('No tag frame:%d', [fFrameNo]));
    SetAxisRange(-1, 1);
    if fChart is TOglChart then
      TOglChart(fChart).Redraw;
    Exit;
  end;

  fCurrentTagName := lTag.Name;"""

if target_refresh in content:
    content = content.replace(target_refresh, repl_refresh)
    print("Refresh implementation replaced successfully.")
else:
    print("Warning: Refresh implementation not found exactly.")

with open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
    f.write(content)
print("Done patching.")
