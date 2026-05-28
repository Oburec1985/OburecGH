import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Starting insert mouse coordinates fix...")

with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

# 1. Clean up fields in TChartSelectListener interface
decl_target = """  TChartSelectListener = class(TChartFrameListener)
  private
    fLastMouseX: Integer;
    fLastMouseY: Integer;
  public
    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); override;
    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); override;
  end;"""

decl_replacement = """  TChartSelectListener = class(TChartFrameListener)
  public
    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); override;
    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); override;
  end;"""

if decl_target in content_l_lf:
    content_l_lf = content_l_lf.replace(decl_target, decl_replacement)
    print("Cleaned up fields from TChartSelectListener interface.")
else:
    print("Warning: decl_target not found in listeners!")

# 2. Clean up initialization in constructor
ctor_target = """constructor TChartSelectListener.Create;
begin
  inherited Create;
  fLastMouseX := 0;
  fLastMouseY := 0;
end;"""

ctor_replacement = """constructor TChartSelectListener.Create;
begin
  inherited Create;
end;"""

if ctor_target in content_l_lf:
    content_l_lf = content_l_lf.replace(ctor_target, ctor_replacement)
    print("Cleaned up ctor initialization.")
else:
    print("Warning: ctor_target not found in listeners!")

# 3. Clean up coordinate writing in MouseMove
mousemove_target = """procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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

  fLastMouseX := X;
  fLastMouseY := Y;

  if Supports(ASender, IChartControl, lControl) then"""

mousemove_replacement = """procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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

  if Supports(ASender, IChartControl, lControl) then"""

if mousemove_target in content_l_lf:
    content_l_lf = content_l_lf.replace(mousemove_target, mousemove_replacement)
    print("Cleaned up mouse coordinate writing in MouseMove.")
else:
    print("Warning: mousemove_target not found in listeners!")

# 4. Replace KeyDown implementation with clean Mouse.CursorPos retrieval
keydown_target = """procedure TChartSelectListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  lAxis: TChartAxis;
  lPage: TChartPage;
  lContentRect: TChartPixelRect;
  lXRange, lYRange: Double;
  I, lNewIdx: Integer;
begin
  if not Enabled then Exit;

  if (Key in [45, 46]) and Supports(ASender, IChartControl, lControl) then // 45 = VK_INSERT, 46 = VK_DELETE
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
    begin
      lTrend := cTrend(lRenderer.SelectedObject);
      if Key = 46 then // VK_DELETE
      begin
        for I := 0 to lTrend.BeziePointCount - 1 do
        begin
          if lTrend.BeziePoints[I].Selected then
          begin
            lTrend.DeleteBeziePoint(I);
            if lTrend.BeziePointCount > 0 then
            begin
              lNewIdx := I;
              if lNewIdx >= lTrend.BeziePointCount then
                lNewIdx := lTrend.BeziePointCount - 1;
              lTrend.BeziePoints[lNewIdx].Selected := True;
            end;
            lControl.Redraw;
            Handled := True;
            Exit;
          end;
        end;
      end
      else if Key = 45 then // VK_INSERT
      begin
        if Assigned(lTrend.Parent) and (lTrend.Parent is TChartAxis) then
        begin
          lAxis := TChartAxis(lTrend.Parent);
          if Assigned(lAxis.Parent) and (lAxis.Parent is TChartPage) then
          begin
            lPage := TChartPage(lAxis.Parent);
            lContentRect := lRenderer.GetPageContentRect(lPage);
            lXRange := lRenderer.PixelToXValue(lPage, nil, fLastMouseX, lContentRect.Left, lContentRect.Right);
            lYRange := lRenderer.PixelToAxisValue(lAxis, fLastMouseY, lContentRect.Bottom, lContentRect.Top);

            lTrend.InsertBeziePoint(lXRange, lYRange, bptCorner);
            lControl.Redraw;
            Handled := True;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;"""

keydown_replacement = """procedure TChartSelectListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  lAxis: TChartAxis;
  lPage: TChartPage;
  lContentRect: TChartPixelRect;
  lXRange, lYRange: Double;
  I, lNewIdx: Integer;
  lMousePos: TPoint;
  lMouseX, lMouseY: Integer;
begin
  if not Enabled then Exit;

  if (Key in [45, 46]) and Supports(ASender, IChartControl, lControl) then // 45 = VK_INSERT, 46 = VK_DELETE
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
    begin
      lTrend := cTrend(lRenderer.SelectedObject);
      if Key = 46 then // VK_DELETE
      begin
        for I := 0 to lTrend.BeziePointCount - 1 do
        begin
          if lTrend.BeziePoints[I].Selected then
          begin
            lTrend.DeleteBeziePoint(I);
            if lTrend.BeziePointCount > 0 then
            begin
              lNewIdx := I;
              if lNewIdx >= lTrend.BeziePointCount then
                lNewIdx := lTrend.BeziePointCount - 1;
              lTrend.BeziePoints[lNewIdx].Selected := True;
            end;
            lControl.Redraw;
            Handled := True;
            Exit;
          end;
        end;
      end
      else if Key = 45 then // VK_INSERT
      begin
        if Assigned(lTrend.Parent) and (lTrend.Parent is TChartAxis) then
        begin
          lAxis := TChartAxis(lTrend.Parent);
          if Assigned(lAxis.Parent) and (lAxis.Parent is TChartPage) then
          begin
            lPage := TChartPage(lAxis.Parent);
            lContentRect := lRenderer.GetPageContentRect(lPage);
            
            // Получаем координаты мыши прямо из системы в оконных координатах чарта!
            lMousePos := TControl(ASender).ScreenToClient(Mouse.CursorPos);
            lMouseX := lMousePos.X;
            lMouseY := lMousePos.Y;

            lXRange := lRenderer.PixelToXValue(lPage, nil, lMouseX, lContentRect.Left, lContentRect.Right);
            lYRange := lRenderer.PixelToAxisValue(lAxis, lMouseY, lContentRect.Bottom, lContentRect.Top);

            lTrend.InsertBeziePoint(lXRange, lYRange, bptCorner);
            lControl.Redraw;
            Handled := True;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;"""

if keydown_target in content_l_lf:
    content_l_lf = content_l_lf.replace(keydown_target, keydown_replacement)
    print("Replaced KeyDown with ScreenToClient mouse query.")
else:
    print("Warning: keydown_target not found in listeners!")

# Save uOglChartFrameListener.pas
with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
