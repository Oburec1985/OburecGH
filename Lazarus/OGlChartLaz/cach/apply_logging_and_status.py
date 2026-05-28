import os

UNIT1_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"
LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"
CHART_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"

print("Starting logging and status updates...")

# ----------------- 1. Update unit1.pas -----------------
with open(UNIT1_PATH, 'rb') as f:
    raw_u = f.read()
content_u = raw_u.decode('cp1251')
content_u_lf = content_u.replace('\r\n', '\n').replace('\r', '\n')

status_target = """procedure TForm1.UpdateStatusBar;
begin
  StatusBar1.SimpleText := fMouseCoordsText + ' | ' + fFpsText;
end;"""

status_replacement = """procedure TForm1.UpdateStatusBar;
var
  lSelText: string;
begin
  lSelText := 'Selected: None';
  if Assigned(OglChart1.SelectedObject) then
  begin
    lSelText := 'Selected: ' + OglChart1.SelectedObject.Name;
    if OglChart1.SelectedObject.Caption <> '' then
      lSelText := lSelText + ' ("' + OglChart1.SelectedObject.Caption + '")';
  end;
  StatusBar1.SimpleText := fMouseCoordsText + ' | ' + lSelText + ' | ' + fFpsText;
end;"""

if status_target in content_u_lf:
    content_u_lf = content_u_lf.replace(status_target, status_replacement)
    print("Updated TForm1.UpdateStatusBar to show Selected object.")
else:
    print("Warning: status_target not found in unit1!")

with open(UNIT1_PATH, 'wb') as f:
    f.write(content_u_lf.replace('\n', '\r\n').encode('cp1251'))


# ----------------- 2. Update uOglChartFrameListener.pas -----------------
with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

# Add LogToFile to implementation start
impl_start_target = """implementation

{ TChartFrameListener }"""

impl_start_replacement = """implementation

procedure LogToFile(const AMsg: string);
var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;
end;

{ TChartFrameListener }"""

if impl_start_target in content_l_lf:
    content_l_lf = content_l_lf.replace(impl_start_target, impl_start_replacement)
    print("Added LogToFile to uOglChartFrameListener.pas implementation.")
else:
    print("Warning: impl_start_target not found in listeners!")

# Replace KeyDown with logged version
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

  LogToFile('SelectListener.KeyDown: Key=' + IntToStr(Key) + ', ShiftState=' + IntToHex(Byte(Shift), 2));

  if (Key in [45, 46]) and Supports(ASender, IChartControl, lControl) then // 45 = VK_INSERT, 46 = VK_DELETE
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) then
    begin
      if Assigned(lRenderer.SelectedObject) then
        LogToFile('  SelectedObject is ' + lRenderer.SelectedObject.ClassName + ' (Name: ' + lRenderer.SelectedObject.Name + ')')
      else
        LogToFile('  SelectedObject is nil');

      if (lRenderer.SelectedObject is cTrend) then
      begin
        lTrend := cTrend(lRenderer.SelectedObject);
        if Key = 46 then // VK_DELETE
        begin
          for I := 0 to lTrend.BeziePointCount - 1 do
          begin
            if lTrend.BeziePoints[I].Selected then
            begin
              LogToFile('  Deleting point ' + IntToStr(I));
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
              
              lMousePos := TControl(ASender).ScreenToClient(Mouse.CursorPos);
              lMouseX := lMousePos.X;
              lMouseY := lMousePos.Y;

              lXRange := lRenderer.PixelToXValue(lPage, nil, lMouseX, lContentRect.Left, lContentRect.Right);
              lYRange := lRenderer.PixelToAxisValue(lAxis, lMouseY, lContentRect.Bottom, lContentRect.Top);

              LogToFile('  Inserting point at values X=' + FloatToStr(lXRange) + ', Y=' + FloatToStr(lYRange));

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
end;"""

if keydown_target in content_l_lf:
    content_l_lf = content_l_lf.replace(keydown_target, keydown_replacement)
    print("Added logging statements to TChartSelectListener.KeyDown.")
else:
    print("Warning: keydown_target not found in listeners!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))


# ----------------- 3. Update uoglchart.pas -----------------
with open(CHART_PATH, 'rb') as f:
    raw_c = f.read()
content_c = raw_c.decode('cp1251')
content_c_lf = content_c.replace('\r\n', '\n').replace('\r', '\n')

impl_start_chart_target = """implementation

{ TOglChart }"""

impl_start_chart_replacement = """implementation

procedure LogToFile(const AMsg: string);
var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;
end;

{ TOglChart }"""

if impl_start_chart_target in content_c_lf:
    content_c_lf = content_c_lf.replace(impl_start_chart_target, impl_start_chart_replacement)
    print("Added LogToFile to uoglchart.pas implementation.")
else:
    print("Warning: impl_start_chart_target not found in chart!")

chart_keydown_target = """procedure TOglChart.KeyDown(var Key: Word; Shift: TShiftState);
var
  lHandled: Boolean;
  I: Integer;
begin
  inherited KeyDown(Key, Shift);"""

chart_keydown_replacement = """procedure TOglChart.KeyDown(var Key: Word; Shift: TShiftState);
var
  lHandled: Boolean;
  I: Integer;
begin
  LogToFile('TOglChart.KeyDown: Key=' + IntToStr(Key) + ', Shift=' + IntToHex(Byte(Shift), 2));
  inherited KeyDown(Key, Shift);"""

if chart_keydown_target in content_c_lf:
    content_c_lf = content_c_lf.replace(chart_keydown_target, chart_keydown_replacement)
    print("Added logging to TOglChart.KeyDown.")
else:
    print("Warning: chart_keydown_target not found in chart!")

with open(CHART_PATH, 'wb') as f:
    f.write(content_c_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
