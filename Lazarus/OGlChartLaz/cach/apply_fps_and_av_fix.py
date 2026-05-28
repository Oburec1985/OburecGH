import os

RENDERER_LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"
OGLCHART_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"
UNIT1_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

print("1. Fixing Access Violation in uOglChartFrameListener.pas...")

with open(RENDERER_LISTENER_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# Find SelectListener MouseDown and fix lModel initialization
target_av = """    // 1.5. Проверяем попадание в вертикальную ось Y
    if lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then"""

replacement_av = """    lModel := TChartModel(lControl.GetModel);
    // 1.5. Проверяем попадание в вертикальную ось Y
    if lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then"""

if target_av in content_lf:
    content_lf = content_lf.replace(target_av, replacement_av)
    
    # Remove now-redundant initialization on line 172 (which becomes 173+)
    target_redundant = """    // 1.8. Проверяем попадание в вершины тренда (cTrend)
    lModel := TChartModel(lControl.GetModel);"""
    replacement_redundant = """    // 1.8. Проверяем попадание в вершины тренда (cTrend)"""
    content_lf = content_lf.replace(target_redundant, replacement_redundant)
    
    print("lModel initialization moved and redundant copy removed.")
else:
    print("Warning: target_av pattern not found!")

with open(RENDERER_LISTENER_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))


print("2. Implementing OnAfterRender and time measurement in uoglchart.pas...")

with open(OGLCHART_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# Add TChartAfterRenderEvent definition
target_type = "type"
replacement_type = """type
  TChartAfterRenderEvent = procedure(Sender: TObject; ARenderTimeMs: Double) of object;"""

if replacement_type not in content_lf:
    content_lf = content_lf.replace(target_type, replacement_type, 1)

# Add FOnAfterRender field and property to TOglChart
target_fields = """    fIsRendererInitialized: Boolean;
    fListeners: TList;"""

replacement_fields = """    fIsRendererInitialized: Boolean;
    fListeners: TList;
    fOnAfterRender: TChartAfterRenderEvent;"""

if target_fields in content_lf:
    content_lf = content_lf.replace(target_fields, replacement_fields)

target_prop = """    property Model: TChartModel read GetModel write SetModel;"""
replacement_prop = """    property Model: TChartModel read GetModel write SetModel;
    property OnAfterRender: TChartAfterRenderEvent read fOnAfterRender write fOnAfterRender;"""

if target_prop in content_lf:
    content_lf = content_lf.replace(target_prop, replacement_prop)

# Add Windows to implementation uses
target_impl_uses = "implementation"
replacement_impl_uses = "implementation\n\nuses Windows;"
if "uses Windows;" not in content_lf:
    content_lf = content_lf.replace(target_impl_uses, replacement_impl_uses)

# Update TOglChart.Paint method to measure time
target_paint = """    fRenderer.Resize(Width, Height);
    fRenderer.Render(Model);
  end;"""

replacement_paint = """    fRenderer.Resize(Width, Height);
    
    QueryPerformanceFrequency(lFreq);
    QueryPerformanceCounter(lStart);
    
    fRenderer.Render(Model);
    
    QueryPerformanceCounter(lEnd);
    if lFreq > 0 then
      lRenderTimeMs := (lEnd - lStart) * 1000.0 / lFreq
    else
      lRenderTimeMs := 0;
      
    if Assigned(fOnAfterRender) then
      fOnAfterRender(Self, lRenderTimeMs);
  end;"""

if target_paint in content_lf:
    content_lf = content_lf.replace(target_paint, replacement_paint)
    
    # Add local variables to Paint
    content_lf = content_lf.replace(
        "procedure TOglChart.Paint;\nvar\n  I: Integer;\nbegin",
        "procedure TOglChart.Paint;\nvar\n  I: Integer;\n  lStart, lEnd, lFreq: Int64;\n  lRenderTimeMs: Double;\nbegin"
    )
    print("Paint method and OnAfterRender property successfully updated.")
else:
    print("Warning: Paint target not found in uoglchart.pas!")

with open(OGLCHART_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))


print("3. Updating unit1.pas to display FPS and Render Time in StatusBar...")

with open(UNIT1_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# Add fields and methods to TForm1 declaration
target_form_fields = """  private
    procedure AddChartTreeNode(AParentNode: TTreeNode; AObject: TChartBaseObject);
    procedure BuildChartTree;"""

replacement_form_fields = """  private
    fMouseCoordsText: string;
    fFpsText: string;
    procedure UpdateStatusBar;
    procedure OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
    procedure AddChartTreeNode(AParentNode: TTreeNode; AObject: TChartBaseObject);
    procedure BuildChartTree;"""

if target_form_fields in content_lf:
    content_lf = content_lf.replace(target_form_fields, replacement_form_fields)

# Add implementation of UpdateStatusBar and OglChart1AfterRender
target_impl_start = "implementation\n\n{$R *.lfm}"
replacement_impl_start = """implementation

{$R *.lfm}

procedure TForm1.UpdateStatusBar;
begin
  StatusBar1.SimpleText := fMouseCoordsText + ' | ' + fFpsText;
end;

procedure TForm1.OglChart1AfterRender(Sender: TObject; ARenderTimeMs: Double);
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

if "procedure TForm1.UpdateStatusBar;" not in content_lf:
    content_lf = content_lf.replace(target_impl_start, replacement_impl_start)

# Wire up event in FormCreate
target_wire = """procedure TForm1.FormCreate(Sender: TObject);
begin
  CreateTestChart(OglChart1);
  OglChart1.OnMouseMove := @OglChart1MouseMove;"""

replacement_wire = """procedure TForm1.FormCreate(Sender: TObject);
begin
  CreateTestChart(OglChart1);
  OglChart1.OnMouseMove := @OglChart1MouseMove;
  OglChart1.OnAfterRender := @OglChart1AfterRender;
  fMouseCoordsText := 'Chart px: (0, 0) | Page: NAN | Axis Val: (X: NAN, Y: NAN)';
  fFpsText := 'Render: 0.00 ms (0.0 FPS)';
  UpdateStatusBar;"""

if target_wire in content_lf:
    content_lf = content_lf.replace(target_wire, replacement_wire)

# Modify MouseMove status updates to use variables and UpdateStatusBar
content_lf = content_lf.replace(
    """  if not lPageFound then
  begin
    StatusBar1.SimpleText := Format(
      'Chart px: (%d, %d) | Page: NAN (outside page) | Axis Val: (X: NAN, Y: NAN)',
      [X, Y]
    );
  end
  else
  begin
    if IsNaN(lAxisXVal) or IsNaN(lAxisYVal) then
      StatusBar1.SimpleText := Format(
        'Chart px: (%d, %d) | Page px: (%d, %d) | Axis Val: (X: NAN, Y: NAN)',
        [X, Y, lPageX, lPageY]
      )
    else
      StatusBar1.SimpleText := Format(
        'Chart px: (%d, %d) | Page px: (%d, %d) | Axis Val: (X: %.4f, Y: %.4f)',
        [X, Y, lPageX, lPageY, lAxisXVal, lAxisYVal]
      );
  end;""",
    """  if not lPageFound then
  begin
    fMouseCoordsText := Format(
      'Chart px: (%d, %d) | Page: NAN (outside page) | Axis Val: (X: NAN, Y: NAN)',
      [X, Y]
    );
  end
  else
  begin
    if IsNaN(lAxisXVal) or IsNaN(lAxisYVal) then
      fMouseCoordsText := Format(
        'Chart px: (%d, %d) | Page px: (%d, %d) | Axis Val: (X: NAN, Y: NAN)',
        [X, Y, lPageX, lPageY]
      )
    else
      fMouseCoordsText := Format(
        'Chart px: (%d, %d) | Page px: (%d, %d) | Axis Val: (X: %.4f, Y: %.4f)',
        [X, Y, lPageX, lPageY, lAxisXVal, lAxisYVal]
      );
  end;
  UpdateStatusBar;"""
)

with open(UNIT1_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
