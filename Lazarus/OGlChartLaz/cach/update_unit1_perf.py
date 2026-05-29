import os

path = r'd:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas'
with open(path, 'r', encoding='cp1251') as f:
    text = f.read()

text = text.replace('\r\n', '\n')

tvar = """procedure CreateTestChart(AChart: TOglChart);
var
  lPage: cBasePage;
  lAxisY: cAxis;
  lAxisY2: cAxis;
  lSeries: cTrend;
  lBuff: cBuffTrend1d;
  lPerfPage: cBasePage;
  lPerfAxis1D, lPerfAxis2D: cAxis;
  lBuff1D: cBuffTrend1d;
  lBuff2D: cBuffTrend2d;
  i: Integer;
  lVal: Double;
begin"""

rvar = """procedure CreateTestChart(AChart: TOglChart);
var
  lPage: cBasePage;
  lAxisY: cAxis;
  lAxisY2: cAxis;
  lSeries: cTrend;
  lBuff: cBuffTrend1d;
  lPerfPage: cBasePage;
  lPerfAxis1D, lPerfAxis2D: cAxis;
  lBuff1D: cBuffTrend1d;
  lBuff2D: cBuffTrend2d;
  i: Integer;
  lVal: Double;
  lArrValues: array of Double;
  lArrPoints: array of TChartPoint;
begin"""

t1 = """  lBuff1D := cBuffTrend1d.Create;
  lBuff1D.Name := 'Buff1D_100k';
  lBuff1D.Caption := 'cBuffTrend1d (100k pts)';
  lBuff1D.Color := $FF0000FF;
  lBuff1D.X0 := 0;
  lBuff1D.DX := 1;
  for i := 0 to 99999 do
  begin
    lVal := Sin(i / 1000.0) * 0.4 + 0.5;
    lBuff1D.AddValue(lVal);
  end;
  lPerfAxis1D.AddChild(lBuff1D);"""

r1 = """  lBuff1D := cBuffTrend1d.Create;
  lBuff1D.Name := 'Buff1D_100k';
  lBuff1D.Caption := 'cBuffTrend1d (100k pts)';
  lBuff1D.Color := $FF0000FF;
  lBuff1D.X0 := 0;
  lBuff1D.DX := 1;
  SetLength(lArrValues, 100000);
  for i := 0 to 99999 do
  begin
    lArrValues[i] := Sin(i / 1000.0) * 0.4 + 0.5;
  end;
  lBuff1D.AddValues(lArrValues);
  SetLength(lArrValues, 0);
  lPerfAxis1D.AddChild(lBuff1D);"""

t2 = """  lBuff2D := cBuffTrend2d.Create;
  lBuff2D.Name := 'Buff2D_100k';
  lBuff2D.Caption := 'cBuffTrend2d (100k pts)';
  lBuff2D.Color := $FF00D000;
  for i := 0 to 99999 do
  begin
    lVal := Sin(i / 1000.0) * 0.4 + 0.5;
    lBuff2D.AddPoint(i, lVal);
  end;
  lPerfAxis2D.AddChild(lBuff2D);"""

r2 = """  lBuff2D := cBuffTrend2d.Create;
  lBuff2D.Name := 'Buff2D_100k';
  lBuff2D.Caption := 'cBuffTrend2d (100k pts)';
  lBuff2D.Color := $FF00D000;
  SetLength(lArrPoints, 100000);
  for i := 0 to 99999 do
  begin
    lArrPoints[i].X := i;
    lArrPoints[i].Y := Sin(i / 1000.0) * 0.4 + 0.5;
  end;
  lBuff2D.AddPoints(lArrPoints);
  SetLength(lArrPoints, 0);
  lPerfAxis2D.AddChild(lBuff2D);"""

# Normalize tvar, t1, t2 to remove any windows carriage returns if any
tvar = tvar.replace('\r', '')
rvar = rvar.replace('\r', '')
t1 = t1.replace('\r', '')
r1 = r1.replace('\r', '')
t2 = t2.replace('\r', '')
r2 = r2.replace('\r', '')

assert tvar in text, 'tvar not found'
assert t1 in text, 't1 not found'
assert t2 in text, 't2 not found'

text = text.replace(tvar, rvar).replace(t1, r1).replace(t2, r2)
text = text.replace('\n', '\r\n')

with open(path, 'w', encoding='cp1251', newline='') as f:
    f.write(text)

print('Successfully updated unit1.pas!')
