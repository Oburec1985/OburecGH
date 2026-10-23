program CursorSnapSmoke;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Controls, Classes, SysUtils, Math, fpjson,
  uOglChart, uOglChartChart, uOglChartAxis, uOglChartPage,
  uOglChartTrend, uOglChartCursor, uOglChartCursorListener,
  uOglChartRenderer, uOglChartDrawObj;
var
  F: TForm;
  C: TOglChart;
  L: TChartCursorListener;
  P, OtherPage: TChartPage;
  A, A2, OtherAxis: TChartAxis;
  B, Other: cBuffTrend1d;
  Line: cLineSeries;
  Cur: TChartCursor;
  R: TOpenGLChartRenderer;
  Rect: TChartPixelRect;
  X, Y: Integer;
  H: Boolean;
  Key: Word;
  Expected: Double;
  Step: Integer;
procedure CheckLabelDrag(Index: Integer);
var
  PX, PY: Integer;
  OldX1, OldX2: Double;
begin
  Rect := R.GetPageContentRect(P);
  Cur.X1 := 10; Cur.X2 := 100;
  Cur.LabelY1Offset := 0.65; Cur.LabelY2Offset := 0.25;
  OldX1 := Cur.X1; OldX2 := Cur.X2;
  if Index = 1 then
  begin
    PX := Round(R.XValueToPixel(P, nil, Cur.X1, Rect.Left, Rect.Right));
    PY := Round(Rect.Bottom + Cur.LabelY1Offset * (Rect.Top - Rect.Bottom));
  end
  else
  begin
    PX := Round(R.XValueToPixel(P, nil, Cur.X2, Rect.Left, Rect.Right));
    PY := Round(Rect.Bottom + Cur.LabelY2Offset * (Rect.Top - Rect.Bottom));
  end;
  H := False; L.MouseDown(C, mbLeft, [], PX + 8, PY, H);
  if not H then raise Exception.Create('label right hit missed');
  L.MouseMove(C, [], PX - 30, PY, H);
  L.MouseUp(C, mbLeft, [], PX - 30, PY, H);
  if ((Index = 1) and not Cur.Label1OnLeft) or
     ((Index = 2) and not Cur.Label2OnLeft) then
    raise Exception.Create('label did not move left');
  if (Cur.X1 <> OldX1) or (Cur.X2 <> OldX2) then
    raise Exception.Create('label drag moved cursor line');
  H := False; L.MouseDown(C, mbLeft, [], PX - 8, PY, H);
  if not H then raise Exception.Create('label left hit missed');
  L.MouseMove(C, [], PX + 30, PY, H);
  L.MouseUp(C, mbLeft, [], PX + 30, PY, H);
  if ((Index = 1) and Cur.Label1OnLeft) or
     ((Index = 2) and Cur.Label2OnLeft) then
    raise Exception.Create('label did not move back right');
end;
procedure CheckLabelJson;
var J: TJSONObject; CopyCursor: TChartCursor;
begin
  J := TJSONObject.Create; CopyCursor := TChartCursor.Create;
  try
    Cur.Label1OnLeft := True; Cur.Label2OnLeft := True;
    Cur.SaveJsonAttributes(J); CopyCursor.LoadJsonAttributes(J);
    if not CopyCursor.Label1OnLeft or not CopyCursor.Label2OnLeft then
      raise Exception.Create('label sides not persisted');
    J.Delete('label_1_on_left'); J.Delete('label_2_on_left');
    CopyCursor.LoadJsonAttributes(J);
    if CopyCursor.Label1OnLeft or CopyCursor.Label2OnLeft then
      raise Exception.Create('legacy labels must default right');
  finally CopyCursor.Free; J.Free; end;
end;
procedure CheckHorizontalDrag;
var HC: TChartHorizontalCursor; PX, PY, TargetY, CountBefore: Integer;
    WantY, OldX1, OldX2: Double;
begin
  Cur.Visible := False;
  A2.MinValue := 0.01; A2.MaxValue := 10000; A2.Scale := casLog10;
  HC := TChartHorizontalCursor.Create;
  P.AddChild(HC); HC.Axis := A2; HC.Visible := True; HC.ShowLabel := True;
  HC.Y := 1;
  Rect := R.GetPageContentRect(P);
  PX := (Rect.Left + Rect.Right) div 2;
  PY := Round(R.AxisValueToPixel(A2, HC.Y, Rect.Bottom, Rect.Top));
  TargetY := Rect.Top + (Rect.Bottom - Rect.Top) div 3;
  WantY := R.PixelToAxisValue(A2, TargetY, Rect.Bottom, Rect.Top);
  CountBefore := P.ChildCount; OldX1 := Cur.X1; OldX2 := Cur.X2;
  H := False; L.MouseDown(C, mbLeft, [], PX, PY, H);
  if not H then raise Exception.Create('horizontal hit missed');
  H := False; L.MouseMove(C, [], PX + 25, TargetY, H);
  if not H or (Abs(HC.Y - WantY) > WantY * 1e-10) then
    raise Exception.Create('horizontal log secondary axis drag mismatch');
  L.MouseUp(C, mbLeft, [], PX + 25, TargetY, H);
  if Cur.Visible or (P.ChildCount <> CountBefore) or
    (Cur.X1 <> OldX1) or (Cur.X2 <> OldX2) then
    raise Exception.Create('horizontal drag changed vertical cursor');
  if not HC.ShowLabel then raise Exception.Create('horizontal label lost');
  HC.Visible := False;
end;
procedure Check(Value: Boolean; const Msg: string);
begin
  Inc(Step);
  if not Value then raise Exception.Create(Msg);
end;
procedure Drag(Shift: TShiftState; AX: Integer; Want: Double);
begin
  Rect := R.GetPageContentRect(P);
  AX := Round(R.XValueToPixel(P, nil, Expected, Rect.Left, Rect.Right));
  Y := (Rect.Top + Rect.Bottom) div 2;
  Cur.X1 := R.PixelToXValue(P, nil, AX, Rect.Left, Rect.Right);
  if IsNan(Want) then Want := Cur.X1;
  H := False;
  L.MouseDown(C, mbLeft, Shift, AX, Y, H);
  Check(H, Format('MouseDown not handled x=%d y=%d rect=%d,%d,%d,%d cursor=%f',
    [AX,Y,Rect.Left,Rect.Top,Rect.Right,Rect.Bottom,Cur.X1]));
  Check(Abs(Cur.X1 - Want) < 1e-8, Format('MouseDown snap mismatch step %d got %.12g want %.12g', [Step, Cur.X1, Want]));
  H := False;
  L.MouseMove(C, Shift, AX, Y, H);
  Check(Abs(Cur.X1 - Want) < 1e-8, 'MouseMove snap mismatch');
  L.MouseUp(C, mbLeft, [], AX, Y, H);
end;
begin
  try
  Application.Initialize;
  F := TForm.CreateNew(nil);
  L := TChartCursorListener.Create;
  L.Enabled := True;
  try
    F.SetBounds(50, 50, 800, 500);
    C := TOglChart.Create(F);
    C.Parent := F;
    C.Align := alClient;
    P := TChartPage.Create;
    P.SetFloatRect(0, 0, 1, 1);
    P.XMinValue := 1;
    P.XMaxValue := 1000;
    P.XScale := casLog10;
    C.Model.AddChild(P);
    A := TChartAxis.Create;
    A.MinValue := -10; A.MaxValue := 20;
    P.AddChild(A);
    B := cBuffTrend1d.Create;
    A.AddChild(B);
    F.Show;
    Application.ProcessMessages;
    R := TOpenGLChartRenderer(C.GetRenderer);
    Rect := R.GetPageContentRect(P);
    X := (Rect.Left + Rect.Right) div 2;
    Y := (Rect.Top + Rect.Bottom) div 2;
    Expected := R.PixelToXValue(P, nil, X, Rect.Left, Rect.Right);
    B.X0 := Expected * 1.02; B.DX := -Expected * 0.01;
    B.AddValues([1, 12, -9, 2, NaN, Infinity]);
    Cur := GetOrCreatePageCursor(P);
    Cur.Visible := True;
    Cur.LabelY1Offset := 0;
    C.SelectedObject := B;
    Drag([ssShift], X, B.X0 + B.DX);
    Drag([ssShift, ssCtrl], X, B.X0 + 2 * B.DX);
    { Mouse Y near trough must not turn plain Shift into minimum selection. }
    Y := Rect.Bottom - 20;
    Drag([ssShift], X, B.X0 + B.DX);
    A2 := TChartAxis.Create; P.AddChild(A2);
    Line := cLineSeries.Create; A2.AddChild(Line);
    Line.AddPoint(Expected, 4);
    Line.AddPoint(R.PixelToXValue(P, nil, X - 11, Rect.Left, Rect.Right), 1000);
    Line.AddPoint(R.PixelToXValue(P, nil, X + 11, Rect.Left, Rect.Right), 2000);
    C.SelectedObject := Line;
    Drag([ssShift], X, Expected);
    OtherPage := TChartPage.Create; C.Model.AddChild(OtherPage);
    OtherPage.SetFloatRect(2, 2, 3, 3);
    OtherAxis := TChartAxis.Create; OtherPage.AddChild(OtherAxis);
    Other := cBuffTrend1d.Create; OtherAxis.AddChild(Other);
    Other.X0 := Expected; Other.AddValue(999);
    C.SelectedObject := Other;
    Drag([ssShift], X, B.X0 + B.DX);
    B.Visible := False;
    C.SelectedObject := B;
    Drag([ssShift], X, Expected);
    Line.ClearPoints;
    Rect := R.GetPageContentRect(P);
    X := Round(R.XValueToPixel(P, nil, Expected, Rect.Left, Rect.Right));
    Drag([ssShift], X, NaN);
    { Existing Home and Ctrl+Home retain unsnapped pointer coordinates. }
    Cur.CursorType := cctDouble;
    H := False; L.MouseMove(C, [], X, Y, H);
    Key := 36; L.KeyDown(C, Key, [], H);
    Check(Abs(Cur.X1 - R.PixelToXValue(P, nil, X, Rect.Left, Rect.Right)) < 1e-8, 'Home changed');
    Key := 36; L.KeyDown(C, Key, [ssCtrl], H);
    Check(Abs(Cur.X2 - R.PixelToXValue(P, nil, X, Rect.Left, Rect.Right)) < 1e-8, 'Ctrl+Home changed');
    Cur.Label1OnLeft := False; Cur.Label2OnLeft := False;
    CheckLabelDrag(1); CheckLabelDrag(2); CheckLabelJson;
    CheckHorizontalDrag;
    WriteLn('PASS: cursor snapping, both label drags, stable cursor X, label JSON and legacy defaults');
  finally
    L.Free;
    F.Free;
  end;
  except
    on E: Exception do
    begin
      WriteLn('FAIL: ', E.Message);
      Halt(1);
    end;
  end;
end.
