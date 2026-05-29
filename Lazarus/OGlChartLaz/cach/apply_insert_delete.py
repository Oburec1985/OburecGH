import os

TREND_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartTrend.pas"
LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Starting insert/delete vertex updates...")

# ----------------- 1. Update uOglChartTrend.pas -----------------
with open(TREND_PATH, 'rb') as f:
    raw_t = f.read()
content_t = raw_t.decode('cp1251')
content_t_lf = content_t.replace('\r\n', '\n').replace('\r', '\n')

# 1.1 Add declarations of InsertBeziePoint/DeleteBeziePoint to cTrend interface
decl_target = """    procedure UpdateBezieRight(AIndex: Integer; AX, AY: Double);"""

decl_replacement = """    procedure UpdateBezieRight(AIndex: Integer; AX, AY: Double);
    procedure DeleteBeziePoint(AIndex: Integer);
    procedure InsertBeziePoint(AX, AY: Double; AType: TBeziePointType = bptCorner);"""

if decl_target in content_t_lf:
    content_t_lf = content_t_lf.replace(decl_target, decl_replacement)
    print("Added Insert/Delete declarations to cTrend.")
else:
    print("Warning: decl_target not found in trend!")

# 1.2 Add implementations of InsertBeziePoint and DeleteBeziePoint
impl_target = """procedure cTrend.UpdateBezieRight(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fRight.X := AX;
    fBeziePoints[AIndex].fRight.Y := AY;
    GenerateSplinePoints;
  end;
end;"""

impl_replacement = """procedure cTrend.UpdateBezieRight(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fRight.X := AX;
    fBeziePoints[AIndex].fRight.Y := AY;
    GenerateSplinePoints;
  end;
end;

procedure cTrend.DeleteBeziePoint(AIndex: Integer);
var
  I: Integer;
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].Free;
    for I := AIndex to Length(fBeziePoints) - 2 do
      fBeziePoints[I] := fBeziePoints[I + 1];
    SetLength(fBeziePoints, Length(fBeziePoints) - 1);
    GenerateSplinePoints;
  end;
end;

procedure cTrend.InsertBeziePoint(AX, AY: Double; AType: TBeziePointType);
var
  I, J, lInsertIdx: Integer;
  bp: cBeziePoint;
begin
  lInsertIdx := Length(fBeziePoints);
  for I := 0 to High(fBeziePoints) do
  begin
    if fBeziePoints[I].Point.X > AX then
    begin
      lInsertIdx := I;
      Break;
    end;
  end;

  SetLength(fBeziePoints, Length(fBeziePoints) + 1);
  for J := Length(fBeziePoints) - 1 downto lInsertIdx + 1 do
    fBeziePoints[J] := fBeziePoints[J - 1];

  bp := cBeziePoint.Create(AX, AY, AType);
  bp.Selected := True;
  fBeziePoints[lInsertIdx] := bp;

  for J := 0 to Length(fBeziePoints) - 1 do
    if J <> lInsertIdx then
      fBeziePoints[J].Selected := False;

  GenerateSplinePoints;
end;"""

if impl_target in content_t_lf:
    content_t_lf = content_t_lf.replace(impl_target, impl_replacement)
    print("Added Insert/Delete implementations to cTrend.")
else:
    print("Warning: impl_target not found in trend!")

# Save uOglChartTrend.pas
with open(TREND_PATH, 'wb') as f:
    f.write(content_t_lf.replace('\n', '\r\n').encode('cp1251'))


# ----------------- 2. Update uOglChartFrameListener.pas -----------------
with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

# 2.1 Add fields and KeyDown override to TChartSelectListener
listener_decl_target = """  TChartSelectListener = class(TChartFrameListener)
  public
    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); override;
  end;"""

listener_decl_replacement = """  TChartSelectListener = class(TChartFrameListener)
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

if listener_decl_target in content_l_lf:
    content_l_lf = content_l_lf.replace(listener_decl_target, listener_decl_replacement)
    print("Declared KeyDown and mouse cache fields in TChartSelectListener.")
else:
    print("Warning: listener_decl_target not found in listeners!")

# 2.2 Initialize fLastMouseX/Y in constructor TChartSelectListener.Create
ctor_target = """constructor TChartSelectListener.Create;
begin
  inherited Create;
end;"""

ctor_replacement = """constructor TChartSelectListener.Create;
begin
  inherited Create;
  fLastMouseX := 0;
  fLastMouseY := 0;
end;"""

if ctor_target in content_l_lf:
    content_l_lf = content_l_lf.replace(ctor_target, ctor_replacement)
    print("Initialized fLastMouseX/Y in TChartSelectListener.Create.")
else:
    print("Warning: ctor_target not found in listeners!")

# 2.3 Store mouse coordinates in TChartSelectListener.MouseMove
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

  fLastMouseX := X;
  fLastMouseY := Y;

  if Supports(ASender, IChartControl, lControl) then"""

if mousemove_target in content_l_lf:
    content_l_lf = content_l_lf.replace(mousemove_target, mousemove_replacement)
    print("Added coordinate caching to TChartSelectListener.MouseMove.")
else:
    print("Warning: mousemove_target not found in listeners!")

# 2.4 Add KeyDown implementation
keydown_target = """procedure TChartSelectListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);"""

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
end;

procedure TChartSelectListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);"""

if keydown_target in content_l_lf:
    content_l_lf = content_l_lf.replace(keydown_target, keydown_replacement)
    print("Added KeyDown implementation to TChartSelectListener.")
else:
    print("Warning: keydown_target not found in listeners!")

# Save uOglChartFrameListener.pas
with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
