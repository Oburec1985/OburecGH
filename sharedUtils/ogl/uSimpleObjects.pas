unit uSimpleObjects;

interface
 uses OpenGL,windows,MathFunction,uMatrix, uCommonTypes;

procedure drawrect(rect:frect; color:point3);
procedure drawBorder(rect:frect; color:point3);
//отрисовать линии
procedure DrawLine(p1,p2:point2);
// ќтрисовать круг
procedure DrawCycle(r:glfloat);overload;
procedure DrawCycle(r:glfloat;prec:cardinal);overload;
// ќтрисовать локальные оси (x,y,z)
procedure DrawPivotPoint(len:glfloat);overload;
procedure DrawPivotPoint(m:matrixgl;len:glfloat);overload;
// –исует оси, при этом окрашивает в желтый ось с индексом selected
procedure DrawPivotPoint(m:matrixgl;len:glfloat;selected:integer);overload;
procedure DrawSelectAxis(m:matrixgl;len:glfloat);
// ќтрисовать кубик оси
procedure DrawBox(size:glfloat);overload;
procedure DrawBox(size:glfloat;pos:point3);overload;
procedure DrawBox(size:glfloat;m:matrixgl);overload;
// ќтрисовать кубик оси
procedure DrawBound(low,hi:point3;m:matrixgl;color:point3);
// ѕолучить массив данных дл€ кубика из Bound
procedure GetBoxByBound(lo,hi:point3;m:matrixgl; var box:array of point3);

procedure drawFillBox;
const
  c_Yellow:array[0..2] of GlFloat=(1.0,1.0,0);
  GL_VERTEX_ARRAY             = $8074;
  GL_COLOR_ARRAY              = $8076;
  GL_Normal_ARRAY             = $8075;
  GL_TEXTURE_COORD_ARRAY      = $8078;

implementation

procedure glVertexPointer (size: GLint; atype: GLenum;
          stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glNormalPointer (size: GLint; stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glColorPointer (size: GLint; atype: GLenum; stride: GLsizei;
          data: pointer); stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDrawArrays (mode: GLenum; first: GLint; count: GLsizei);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glEnableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDisableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDrawElements(mode: GLenum;count: GLsizei;
          GlType:GLEnum;data: pointer);
          stdcall; external OpenGL32;

procedure drawrect(rect:frect; color:point3);
var
 data:array[0..3] of point2;
 curcolor:point3;
begin
  data[0]:=rect.BottomLeft;
  data[1]:=p2(rect.BottomLeft.x,rect.topright.y);
  data[2]:=rect.TopRight;
  data[3]:=p2(rect.TopRight.x,rect.BottomLeft.y);
  // установка цвета
  glGetFloatv(GL_CURRENT_COLOR,@curcolor);
  glcolor3fv(@color);
  // отрисовка полигона
  glBegin(GL_QUADs);
  glvertex2fv(@data[0]);
  glvertex2fv(@data[1]);
  glvertex2fv(@data[2]);
  glvertex2fv(@data[3]);
  glend;
  glcolor3fv(@curcolor);
end;

procedure drawBorder(rect:frect; color:point3);
var
 data:array[0..3] of point2;
 curcolor:point3;
begin
  data[0]:=rect.BottomLeft;
  data[1]:=p2(rect.BottomLeft.x,rect.topright.y);
  data[2]:=rect.TopRight;
  data[3]:=p2(rect.TopRight.x,rect.BottomLeft.y);
  // установка цвета
  glGetFloatv(GL_CURRENT_COLOR,@curcolor);
  glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
  glcolor3fv(@color);
  // отрисовка полигона
  glBegin(GL_QUADs);
    glvertex2fv(@data[0]);
    glvertex2fv(@data[1]);
    glvertex2fv(@data[2]);
    glvertex2fv(@data[3]);
  glend;
  glcolor3fv(@curcolor);
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
end;

procedure GetBoxByBound(lo,hi:point3;m:matrixgl; var box:array of point3);
begin
  //  (  1, 1, 1, -1, 1, 1, -1,-1, 1,  1,-1, 1,
  box[0]:=hi;
  box[1]:=hi; box[1].x:=lo.x;
  box[2]:=lo; box[2].z:=hi.z;
  box[3]:=hi; box[3].y:=lo.y;
  box[0]:=multP3ByM(m,box[0]);
  box[1]:=multP3ByM(m,box[1]);
  box[2]:=multP3ByM(m,box[2]);
  box[3]:=multP3ByM(m,box[3]);

  //     1, 1,-1,  1,-1,-1, -1,-1,-1, -1, 1,-1,
  box[4]:=hi; box[4].z:=lo.z;
  box[5]:=lo; box[5].x:=hi.x;
  box[6]:=lo;
  box[7]:=lo; box[7].y:=hi.y;
  box[4]:=multP3ByM(m,box[4]);
  box[5]:=multP3ByM(m,box[5]);
  box[6]:=multP3ByM(m,box[6]);
  box[7]:=multP3ByM(m,box[7]);

  //    -1,-1,-1, -1,-1, 1, -1, 1, 1, -1, 1,-1,
  box[8]:=lo;
  box[9]:=lo;box[9].z:=hi.z;
  box[10]:=hi;box[10].x:= lo.x;
  box[11]:=lo;box[11].y:=hi.y;
  box[8]:=multP3ByM(m,box[8]);
  box[9]:=multP3ByM(m,box[9]);
  box[10]:=multP3ByM(m,box[10]);
  box[11]:=multP3ByM(m,box[11]);

  //     1, 1, 1,  1,-1, 1,  1,-1,-1,  1, 1,-1,
  box[12]:=hi;
  box[13]:=hi;box[13].y:=lo.y;
  box[14]:=lo;box[14].x:=hi.x;
  box[15]:=hi;box[15].z:=lo.z;
  box[12]:=multP3ByM(m,box[12]);
  box[13]:=multP3ByM(m,box[13]);
  box[14]:=multP3ByM(m,box[14]);
  box[15]:=multP3ByM(m,box[15]);

  //    -1, 1,-1, -1, 1, 1,  1, 1, 1,  1, 1,-1,
  box[16]:=lo;box[16].y:=hi.y;
  box[17]:=hi;box[17].x:=lo.x;
  box[18]:=hi;
  box[19]:=hi;box[19].z:=lo.z;
  box[16]:=multP3ByM(m,box[16]);
  box[17]:=multP3ByM(m,box[17]);
  box[18]:=multP3ByM(m,box[18]);
  box[19]:=multP3ByM(m,box[19]);

  //  -1,-1,-1,  1,-1,-1,  1,-1, 1, -1,-1, 1
  box[20]:=lo;
  box[21]:=lo;box[21].x:=hi.x;
  box[22]:=hi;box[22].y:=lo.y;
  box[23]:=lo;box[23].z:=hi.z;
  box[20]:=multP3ByM(m,box[20]);
  box[21]:=multP3ByM(m,box[21]);
  box[22]:=multP3ByM(m,box[22]);
  box[23]:=multP3ByM(m,box[23]);
end;

Procedure DrawPivotPoint(len:single);
var Axis:array[0..17] of GlFloat;
    b:glboolean;
const c_Colors:array[0..17] of GlFloat=( 1,0,0, 1,0,0,
                                         0,1,0, 0,1,0,
                                         0,0,1, 0,0,1);
begin
 if len>0 then
 begin
   glgetbooleanv(gl_lighting,@b);
   glDisable(GL_LIGHTING);
   //–исуем оси координат
   axis[0]:=0;axis[1]:=0;axis[2]:=0;
   axis[3]:=len;axis[4]:=0;axis[5]:=0;
   axis[6]:=0;axis[7]:=0;axis[8]:=0;
   axis[9]:=0;axis[10]:=len;axis[11]:=0;
   axis[12]:=0;axis[13]:=0;axis[14]:=0;
   axis[15]:=0;axis[16]:=0;axis[17]:=len;

   glEnableClientState(GL_COLOR_ARRAY);
   glColorPointer(3, GL_FLOAT, 0,@c_Colors[0]);
   glEnableClientState(GL_VERTEX_ARRAY) ;// вкл. режим рисовани€
   glVertexPointer(3, GL_FLOAT, 0,@Axis[0]);// указатель на массив
   glDrawArrays(GL_LINES,0,6);
   glDisableClientState(GL_VERTEX_ARRAY);
   glDisableClientState(GL_COLOR_ARRAY);
   if b then
     glEnable(GL_LIGHTING);
 end;
End;

procedure DrawPivotPoint(m:matrixgl;len:glfloat);
var
 TMtype:GLUInt;
begin
  {glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glloadmatrixf(@m);
  DrawPivotPoint(len);
  glpopmatrix;
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION); }

  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glloadmatrixf(@m);
  // ось x
  glcolor3fv(@red);
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(len,0,0);
  glEnd;
  // ось y
  glcolor3fv(@green);
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(0,len,0);
  glEnd;
  // ось z
  glcolor3fv(@blue);
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(0,0,len);
  glEnd;
  glpopmatrix;
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

procedure DrawPivotPoint(m:matrixgl;len:glfloat;selected:integer);
var
  TMtype:GLUInt;
  b:glboolean;
begin
  glgetbooleanv(gl_lighting,@b);
  glDisable(GL_LIGHTING);
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glloadmatrixf(@m);
  // ось x
  if selected=1 then
    glcolor3fv(@yellow)
  else
    glcolor3fv(@red);
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(len,0,0);
  glEnd;
  // ось y
  if selected=2 then
    glcolor3fv(@yellow)
  else
    glcolor3fv(@green);
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(0,len,0);
  glEnd;
  // ось z
  if selected=3 then
    glcolor3fv(@yellow)
  else
    glcolor3fv(@blue);
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(0,0,len);
  glEnd;
  glpopmatrix;
  if b then
    glEnable(GL_LIGHTING);
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

procedure DrawSelectAxis(m:matrixgl;len:glfloat);
var
 TMtype:GLUInt;
begin
  glclear(Gl_COLOR_BUFFER_BIT or Gl_Depth_BUFFER_BIT);

  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glloadmatrixf(@m);
  // ось x
  glLoadName (1); // именуем под именем 1
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(len,0,0);
  glEnd;
  // ось y
  glLoadName (2); // именуем под именем 2
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(0,len,0);
  glEnd;
  // ось z
  glLoadName (3); // именуем под именем 3
  glBegin(GL_LINES);
    glVertex3f(0,0,0);
    glVertex3f(0,0,len);
  glEnd;
  glpopmatrix;
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

procedure DrawBox(size:glfloat);
const box: array[0..71] of glfloat =
  (  1, 1, 1, -1, 1, 1, -1,-1, 1,  1,-1, 1,
     1, 1,-1,  1,-1,-1, -1,-1,-1, -1, 1,-1,
    -1,-1,-1, -1,-1, 1, -1, 1, 1, -1, 1,-1,
     1, 1, 1,  1,-1, 1,  1,-1,-1,  1, 1,-1,
    -1, 1,-1, -1, 1, 1,  1, 1, 1,  1, 1,-1,
    -1,-1,-1,  1,-1,-1,  1,-1, 1, -1,-1, 1
  );
var
 TMtype:GLUInt;
 m:matrixgl;
 low,hi:point3;
 b:glboolean;
begin
  if (size<>0) then
   begin
     glgetbooleanv(gl_lighting,@b);   
     glDisable(GL_LIGHTING);
     glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);

     // ”знаем кака€ матрица активна
     glGetIntegerv(gl_Matrix_Mode,@TMType);
     glMatrixMode(GL_Modelview);
     glPushMatrix;
     // ----------------------------
     glscalef(size,size,size);
     glcolor3fv(@c_Yellow);
     glEnableClientState(GL_VERTEX_ARRAY) ;// вкл. режим рисовани€
     glVertexPointer(3, GL_FLOAT, 0,@box);// указатель на массив
     glDrawArrays(GL_Quads,0,24);
     glDisableClientState(GL_VERTEX_ARRAY);
     // ----------------------------
     glPopMatrix;
     if TMType = GL_PROJECTION then
       glMatrixMode(GL_PROJECTION);
     glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
     if b then
       glEnable(GL_LIGHTING);
   end;
end;

procedure DrawBox(size:glfloat;pos:point3);
var
 TMtype:GLUInt;
 m:matrixgl;
 low,hi:point3;
begin
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glgetfloatv(gl_ModelView_Matrix,@m);
  m:=setpos(m,pos);
  glloadmatrixf(@m);
  drawbox(size);
  glpopmatrix;
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

procedure DrawBox(size:glfloat;m:matrixgl);
var
 TMtype:GLUInt;
 low,hi:point3;
begin
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glloadmatrixf(@m);
  drawbox(size);
  glpopmatrix;
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

// ќтрисовать кубик оси
procedure DrawBound(low,hi:point3;m:matrixgl;color:point3);
var box:array [0..23] of point3;
    TMtype:GLUInt;
    b:glboolean;
begin
  glgetbooleanv(gl_lighting,@b);
  GetBoxByBound(low,hi,m,box);
  glDisable(GL_LIGHTING);
  glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
  // ”знаем кака€ матрица активна
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glcolor3fv(@color);
  glEnableClientState(GL_VERTEX_ARRAY) ;// вкл. режим рисовани€
  glVertexPointer(3, GL_FLOAT, 0,@box[0]);// указатель на массив
  glDrawArrays(GL_Quads,0,24);
  glDisableClientState(GL_VERTEX_ARRAY);
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
  if b then
    glEnable(GL_LIGHTING);
end;

procedure drawFillBox;
begin
  glcolor3f(0.5,0.5,0.5);
  glBegin (GL_QUADS);
    glNormal3f ( 0,  0, 1);
    glVertex3f ( 1,  1, 1);
    glVertex3f (-1,  1, 1);
    glVertex3f (-1, -1, 1);
    glVertex3f ( 1, -1, 1);
  glEnd;
  glBegin (GL_QUADS);
    glNormal3f ( 0,  0, -1);
    glVertex3f ( 1,  1, -1);
    glVertex3f ( 1, -1, -1);
    glVertex3f (-1, -1, -1);
    glVertex3f (-1,  1, -1);
  glEnd;
  glBegin (GL_QUADS);
    glNormal3f (-1,  0,  0);
    glVertex3f (-1,  1, -1);
    glVertex3f (-1,  1, -1);
    glVertex3f (-1, -1,  1);
    glVertex3f (-1, -1,  1);
  glEnd;
  glBegin (GL_QUADS);
    glNormal3f (1,  0,  0);
    glVertex3f (1,  1,  1);
    glVertex3f (1, -1,  1);
    glVertex3f (1, -1, -1);
    glVertex3f (1,  1, -1);
  glEnd;
  glBegin (GL_QUADS);
    glNormal3f ( 0, 1,  0);
    glVertex3f (-1, 1, -1);
    glVertex3f (-1, 1,  1);
    glVertex3f ( 1, 1,  1);
    glVertex3f ( 1, 1, -1);
  glEnd;
  glBegin(GL_QUADS);
    glNormal3f ( 0, -1,  0);
    glVertex3f (-1, -1, -1);
    glVertex3f ( 1, -1, -1);
    glVertex3f ( 1, -1,  1);
    glVertex3f (-1, -1,  1);
  glEnd;
end;

procedure DrawCycle(r:glfloat);
var
    b:glboolean;
    i:integer;
    p_ar:array[0..35] of glfloat;
    procedure drawspline(data:pointer);
    var j:integer;
    begin
      glMap1f (GL_MAP1_VERTEX_3, 0, 1, 3, 3, data);
      glEnable (GL_MAP1_VERTEX_3);
      glBegin(GL_LINE_STRIP);
        For j:=0 to 30 do
         glEvalCoord1f (j/30);
      glEnd;
    end;
const
  s : set of byte = [3,4,12,13,21,22,30,31];
  p:array[0..35] of glfloat = (-1, 0,0, -1, 1,0,  0, 1,0,
                                0, 1,0,  1, 1,0,  1, 0,0,
                                1, 0,0,  1,-1,0,  0,-1,0,
                                0,-1,0, -1,-1,0, -1, 0,0);
begin
  glGetBooleanV(GL_LIGHTING,@b);
  for I := 0 to 35  do
  begin
    p_ar[i]:=p[i];
    if p_ar[i]<>0 then
    begin
      if p_ar[i]>0 then

        p_ar[i]:=r
      else
        p_ar[i]:=-r;
      if (i in s) then
      begin
        p_ar[i]:=p_ar[i]*0.95;
      end;
    end;
  end;
  glDisable(GL_LIGHTING);
  drawspline(@p_ar[0]);
  drawspline(@p_ar[9]);
  drawspline(@p_ar[18]);
  drawspline(@p_ar[27]);
  if b then
    glEnable(GL_LIGHTING);
end;

procedure DrawCycle(r:glfloat;prec:cardinal);
var i:integer;
    a:single;
    ar:array of point3;     // i    - x        x = 2*pi/prec-1
                            // prec - 360
    b:glboolean;
begin
  glGetBooleanV(GL_LIGHTING,@b);
  setlength(ar,prec);
  for I := 0 to prec-1 do
  begin
    a:=2*pi*i/(prec-1);
    ar[i].x := r*cos(a);
    ar[i].y := r*sin(a);
    ar[i].z:=0;
  end;
  glDisable(GL_LIGHTING);
  glEnableClientState(GL_VERTEX_ARRAY) ;// вкл. режим рисовани€
  glVertexPointer(3, GL_FLOAT, 0,@ar[0]);// указатель на массив
  glDrawArrays(GL_LINE_strip,0,prec);
  glDisableClientState(GL_VERTEX_ARRAY);
  if b then
    glEnable(GL_LIGHTING);
end;

procedure DrawLine(p1,p2:point2);
var b:glboolean;
begin
  glGetBooleanV(GL_LIGHTING,@b);
  glDisable(GL_LIGHTING);
  glBegin (GL_LINES);
    glVertex2fv (@p1);
    glVertex2fv (@p2);
  glEnd;
  if b then
    glEnable(GL_LIGHTING);
end;

end.
