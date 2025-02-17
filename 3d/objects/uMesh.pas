unit uMesh;

interface
uses
  Windows, OpenGL, Classes, MathFunction, TextureGl, uMaterial, uObject,
  SysUtils, uObjectTypes, uEventList, uVectorList, uOglExpFunc,uCommonTypes;
type

 cVPointer = class
   ind:integer;
   Pointers:array of integer;
 end;

 cMesh = class
 public
   obj:cobject;
   defoultcolor:point3; // ���� ��������� ������� �� ���������
   m_drawnormal:single; // ����� ��������
   VertexCount,FaceCount:Cardinal;//����� ���������� ������� ������
   DrawArray,DrawNormals:TVertexArray;//������� ������ � ��������
   colorArray:array of point3; // ������ ������ ������
   TexVertexArray:TTextureArray; //������ ���������� ���������
   FaceArray:TFaceC;//������ ������ ������� ������ ��� ������
   VPointers:cIntVectorList;
 protected
   fselectp:integer; // ������ ���������� �������
 public
   linccount:integer;
 public
   Procedure  DrawNormal(len:single);
   destructor Destroy;virtual;
 protected
   // ���������� �������������� ������
   procedure drawpoints(color:point3;size:single;settings:word);
   // ���������� ������ ���������
   procedure drawEdges(color:point3;size:single);
   // ���������� ���������
   procedure drawgeometrie(textured:boolean);virtual;
   function getVertPos(ind:integer):point3;
   // ���� ���������� ���������� ������� ������ ���������� ���� ������
   procedure updateVertDataByUV(ind:integer;p3:point3);overload;
 public
   // ���������� min max ������� �� x � y;
   Constructor Create;
   procedure UpdateBounds(var Lo:point3;var hi:point3);
   procedure updateVertDataByUV(uv:cvPointer;p3:point3);overload;
   Procedure Draw(settings:word; mat:cmaterial);
   procedure prepareVertexBuffer;virtual;
 protected
   procedure setselectp(p:integer);
   function getvert(index:integer):cVPointer;
 public
   property UnicVertPos[index:integer]:point3 read getVertPos  write updateVertDataByUV;
   property UnicVert[index:integer]:cVPointer read getVert;
   property selectp:integer read fselectp write setSelectP;
 end;
implementation
uses umeshobr;

const
  Fl_RotX     = 0;
  Fl_RotX_inv = 1;
  Fl_RotY     = 2;
  Fl_RotY_inv = 3;
  Fl_RotZ     = 4;
  Fl_RotZ_inv = 5;

  red:point3 = (x:1;y:0;z:0);
  green:point3 = (x:0;y:1;z:0);
  blue:point3 = (x:0;y:0;z:1);
  white:point3 = (x:1;y:1;z:1);

//-----------------------------------------------------------------
//-------------------- ������ ������ TMesh_Obr --------------------
//-----------------------------------------------------------------

function cMesh.getvert(index:integer):cVPointer;
begin
  result:=cVPointer(VPointers.getObj(index));
end;

function cMesh.getVertPos(ind:integer):point3;
var uv:cvPointer;
begin
  uv:=UnicVert[ind];
  result:=vtop3(DrawArray[uv.Pointers[0]]);
end;

procedure cMesh.updateVertDataByUV(ind:integer;p3:point3);
var uv:cvPointer;
begin
  uv:=UnicVert[ind];
  updateVertDataByUV(uv,p3);
end;

procedure cMesh.updateVertDataByUV(uv:cvPointer;p3:point3);
var i,len:integer;
begin
  len:=length(uv.Pointers);
  for I := 0 to len - 1 do
  begin
    DrawArray[uv.Pointers[i]]:=p3tov(p3);
  end;
end;


constructor cMesh.Create;
begin
  linccount:=0;
  VPointers:=cIntVectorList.Create;
  inherited;
end;

Destructor cMesh.Destroy;
begin
 setlength(DrawArray,0);
 setlength(DrawNormals,0);
 setlength(TexVertexArray,0);
 VPointers.destroy;
 inherited;
end;

procedure cMesh.drawpoints(color:point3;size:single;settings:word);
var
  curcolor,oldcolor:point3;
begin
  glpointsize(size);
  curcolor:=color;
  glgetfloatv(GL_CURRENT_COLOR,@oldcolor);
  glcolor3fv(@color);
  // ���� ������������ ����� �� ������ ��������� ������
  if checkflag(settings,use_colors) then
  begin
    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(3, GL_FLOAT, 0,@colorArray[0]);
  end;
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0,@DrawArray[0]);
  glDrawElements(GL_Points,FaceCount*3,GL_UNSIGNED_INT,FaceArray);
  glDisableClientState(GL_VERTEX_ARRAY);
  // ���� ������������ ����� �� ��������� ��������� ������
  if checkflag(settings,use_colors) then
  begin
    glDisableClientState(GL_COLOR_ARRAY);
  end;
  glcolor3fv(@oldcolor);
end;

procedure cMesh.drawEdges(color:point3;size:single);
var
  oldcolor:point3;
begin
  glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
  glgetfloatv(GL_CURRENT_COLOR,@oldcolor);
  glcolor3fv(@color);
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0,@DrawArray[0]);
  glDrawElements(GL_Triangles,FaceCount*3,GL_UNSIGNED_INT,FaceArray);
  glDisableClientState(GL_VERTEX_ARRAY);
  glcolor3fv(@oldcolor);
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
end;

procedure cMesh.drawgeometrie(textured:boolean);
begin
 if textured then
 begin
   glEnableClientState(GL_TEXTURE_COORD_ARRAY);
   glTexCoordPointer(2, GL_FLOAT, 0,@TexVertexArray[0]);
 end;
 // ����������� ���� ������.
 glEnableClientState(GL_Normal_ARRAY);
 glNormalPointer(Gl_Float,0,@DrawNormals[0]);
 glEnableClientState(GL_VERTEX_ARRAY);
 glVertexPointer(3, GL_FLOAT, 0,@DrawArray[0]);
 glDrawElements(GL_Triangles,FaceCount*3,GL_UNSIGNED_INT,FaceArray);
 glDisableClientState(GL_VERTEX_ARRAY);
 glDisableClientState(GL_Normal_ARRAY);
 if textured then
   glDisableClientState(GL_TEXTURE_COORD_ARRAY);
end;

procedure cMesh.Draw(settings:word;mat:cmaterial);
var b,matexist:boolean;
begin
 // -------------------- ��������� �������
 if checkflag(settings,DRAW_NORMAL) then
 begin
   DrawNormal(m_drawnormal);
 end;
 // -------------------- ��������� �������
 if checkflag(settings,draw_Geom) then
 begin
   matexist:=(mat<>mat.matmng.defMat);
   if matexist then
   begin
     glgetBooleanv(gl_color_material,@b);
     gldisable(gl_color_material);
   end;
   mat.ApplyMaterial(0,defoultcolor);
   // ������ ���������
   drawgeometrie(mat.textured);
   // ���� ���� ��������� ��� �������
   if b then
     glEnable(gl_color_material);
 end;
 glDisable(GL_LIGHTING);
 if checkflag(settings,draw_Edges) then
 begin
   drawEdges(white,0.2);
 end;
 if checkflag(settings,draw_Points) then
 begin
   drawpoints(blue,8,settings);
 end;
 glEnable(GL_LIGHTING);
end;

//---------- ��������� ��������� ������� ��������� �������
Procedure cMesh.DrawNormal(len:single);
var i,j,k:word;
    V:array of Vector3f;
Begin
 //------ ���������� ��������, ������ ������� � ��������
 begin
   SetLength(V,FaceCount*6);
   for i:=0 to (FaceCount-1) do
    begin
     //j:=round(frac(i/3)*3);
     for j := 0 to 2 do
      for k := 0 to 2 do
       begin
         V[(i*3+j)*2][k]:=DrawArray[(FaceArray[i][j])][k];
         V[((i*3+j)*2+1)][k]:=DrawArray[(FaceArray[i][j])][k]+len*DrawNormals[(FaceArray[i][j])][k];
       end;
    end;
   glDisable(GL_LIGHTING)       ;
   glEnableClientState(GL_VERTEX_ARRAY);
   glVertexPointer(3, GL_FLOAT, 0,@V[0]);
   glDrawArrays(GL_Lines,0,FaceCount*6);
   glDisableClientState(GL_VERTEX_ARRAY);
 end;
 glEnable(GL_LIGHTING);
End;

procedure cMesh.UpdateBounds(var Lo:point3;var hi:point3);
var i:integer;
    min,max:point3;
begin
  min.x:=0;
  min.y:=0;
  min.z:=0;
  max.x:=0;
  max.y:=0;
  max.z:=0;
  for I := 0 to vertexcount - 1 do
  begin
    if min.x>DrawArray[i][0] then
      min.x:=drawArray[i][0];
    if max.x<DrawArray[i][0] then
      max.x:=drawArray[i][0];

    if min.y>DrawArray[i][1] then
      min.y:=drawArray[i][1];
    if max.y<DrawArray[i][1] then
      max.y:=drawArray[i][1];

    if min.z>DrawArray[i][2] then
      min.z:=drawArray[i][2];
    if max.z<DrawArray[i][2] then
      max.z:=drawArray[i][2];
  end;
  lo:=min;
  hi:=max;
end;

procedure cmesh.setselectp(p:integer);
begin
  if p<>-1 then
    colorArray[fselectp]:=blue;
  if p>-1 then
    colorArray[p]:=red;
  if selectp<>-1 then
  begin
    obj.settings:=obj.settings or use_colors;
  end
  else
  begin
    if CheckFlag(obj.settings,use_colors) then
      obj.settings:=obj.settings - use_colors;
  end;
  fselectp:=p;
end;

procedure cmesh.preparevertexbuffer;
begin
  
end;

end.
