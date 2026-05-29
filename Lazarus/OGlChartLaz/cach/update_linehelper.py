import os

path = r'd:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLineHelper.pas'
with open(path, 'r', encoding='cp1251') as f:
    text = f.read()

text = text.replace('\r\n', '\n')

t1 = """  if AUseShader and AShaderInitialized then
  begin
    if AYAxis.UseOwnX then
    begin
      lXMin := AYAxis.XMinValue;
      lXMax := AYAxis.XMaxValue;
    end
    else
    begin
      lXMin := APage.XMinValue;
      lXMax := APage.XMaxValue;
    end;
    lYMin := AYAxis.MinValue;
    lYMax := AYAxis.MaxValue;

    glUseProgram(AShaderProgram);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(AShaderProgram, 'a_minmax');
    glUniform4fv(lMinMaxLoc, 1, @lMinMax[0]);

    if AYAxis.UseOwnX then
    begin
      if AYAxis.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end
    else
    begin
      if APage.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end;
    if AYAxis.Scale = casLog10 then lLg[1] := 1 else lLg[1] := 0;
    
    lLgLoc := glGetUniformLocation(AShaderProgram, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    if ASeries.GLListID = 0 then
    begin
      ASeries.GLListID := glGenLists(1);
      glNewList(ASeries.GLListID, GL_COMPILE);
      glBegin(GL_LINE_STRIP);
      for lIndex := 0 to ASeries.PointCount - 1 do
      begin
        lPoint := ASeries.Points[lIndex];
        glVertex2f(lPoint.X, lPoint.Y);
      end;
      glEnd;
      glEndList;
    end;
    glCallList(ASeries.GLListID);

    glPopMatrix;
    glUseProgram(0);
  end"""

r1 = """  if AUseShader and AShaderInitialized then
  begin
    if ASeries.GLListID = 0 then
    begin
      ASeries.GLListID := glGenLists(1);
      glNewList(ASeries.GLListID, GL_COMPILE);
      glBegin(GL_LINE_STRIP);
      for lIndex := 0 to ASeries.PointCount - 1 do
      begin
        lPoint := ASeries.Points[lIndex];
        glVertex2f(lPoint.X, lPoint.Y);
      end;
      glEnd;
      glEndList;
    end;

    if AYAxis.UseOwnX then
    begin
      lXMin := AYAxis.XMinValue;
      lXMax := AYAxis.XMaxValue;
    end
    else
    begin
      lXMin := APage.XMinValue;
      lXMax := APage.XMaxValue;
    end;
    lYMin := AYAxis.MinValue;
    lYMax := AYAxis.MaxValue;

    glUseProgram(AShaderProgram);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(AShaderProgram, 'a_minmax');
    glUniform4fv(lMinMaxLoc, 1, @lMinMax[0]);

    if AYAxis.UseOwnX then
    begin
      if AYAxis.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end
    else
    begin
      if APage.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end;
    if AYAxis.Scale = casLog10 then lLg[1] := 1 else lLg[1] := 0;
    
    lLgLoc := glGetUniformLocation(AShaderProgram, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    glCallList(ASeries.GLListID);

    glPopMatrix;
    glUseProgram(0);
  end"""

t2 = """  if AUseShader and AShaderInitialized then
  begin
    if AYAxis.UseOwnX then
    begin
      lXMin := AYAxis.XMinValue;
      lXMax := AYAxis.XMaxValue;
    end
    else
    begin
      lXMin := APage.XMinValue;
      lXMax := APage.XMaxValue;
    end;
    lYMin := AYAxis.MinValue;
    lYMax := AYAxis.MaxValue;

    glUseProgram(AShaderProgram);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(AShaderProgram, 'a_minmax');
    glUniform4fv(lMinMaxLoc, 1, @lMinMax[0]);

    if AYAxis.UseOwnX then
    begin
      if AYAxis.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end
    else
    begin
      if APage.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end;
    if AYAxis.Scale = casLog10 then lLg[1] := 1 else lLg[1] := 0;
    
    lLgLoc := glGetUniformLocation(AShaderProgram, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    lLinePar[0] := ATrend.X0;
    lLinePar[1] := ATrend.DX;
    lLineParLoc := glGetUniformLocation(AShaderProgram, 'a_LinePar');
    glUniform2fv(lLineParLoc, 1, @lLinePar[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    if ATrend.GLListID = 0 then
    begin
      ATrend.GLListID := glGenLists(1);
      glNewList(ATrend.GLListID, GL_COMPILE);
      glBegin(GL_LINE_STRIP);
      for lIndex := 0 to ATrend.Count - 1 do
      begin
        glVertex2f(ATrend.Values[lIndex], 0);
      end;
      glEnd;
      glEndList;
    end;
    glCallList(ATrend.GLListID);

    glPopMatrix;
    glUseProgram(0);
  end"""

r2 = """  if AUseShader and AShaderInitialized then
  begin
    if ATrend.GLListID = 0 then
    begin
      ATrend.GLListID := glGenLists(1);
      glNewList(ATrend.GLListID, GL_COMPILE);
      glBegin(GL_LINE_STRIP);
      for lIndex := 0 to ATrend.Count - 1 do
      begin
        glVertex2f(ATrend.Values[lIndex], 0);
      end;
      glEnd;
      glEndList;
    end;

    if AYAxis.UseOwnX then
    begin
      lXMin := AYAxis.XMinValue;
      lXMax := AYAxis.XMaxValue;
    end
    else
    begin
      lXMin := APage.XMinValue;
      lXMax := APage.XMaxValue;
    end;
    lYMin := AYAxis.MinValue;
    lYMax := AYAxis.MaxValue;

    glUseProgram(AShaderProgram);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(AShaderProgram, 'a_minmax');
    glUniform4fv(lMinMaxLoc, 1, @lMinMax[0]);

    if AYAxis.UseOwnX then
    begin
      if AYAxis.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end
    else
    begin
      if APage.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end;
    if AYAxis.Scale = casLog10 then lLg[1] := 1 else lLg[1] := 0;
    
    lLgLoc := glGetUniformLocation(AShaderProgram, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    lLinePar[0] := ATrend.X0;
    lLinePar[1] := ATrend.DX;
    lLineParLoc := glGetUniformLocation(AShaderProgram, 'a_LinePar');
    glUniform2fv(lLineParLoc, 1, @lLinePar[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    glCallList(ATrend.GLListID);

    glPopMatrix;
    glUseProgram(0);
  end"""

t1 = t1.replace('\r', '')
r1 = r1.replace('\r', '')
t2 = t2.replace('\r', '')
r2 = r2.replace('\r', '')

assert t1 in text, 't1 not found'
assert t2 in text, 't2 not found'

text = text.replace(t1, r1).replace(t2, r2)
text = text.replace('\n', '\r\n')

with open(path, 'w', encoding='cp1251', newline='') as f:
    f.write(text)

print('Successfully updated uOglChartLineHelper.pas!')
