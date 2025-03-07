unit uSelecTools;

interface
 uses classes, mathfunction, opengl, uObject, uObjectTypes, uMatrix,dialogs, u3dtypes,
 uSimpleObjects, uMeshObr, sysutils, windows, ubasecamera, unodeobject
 ,uCommonTypes
 ,uShape
 ;

 type
   cSelectTools = class
     // ���������� � ���������� �������
     selected:cnodeobject;
     // ������ � ����� �������������� �������
     startP,endP:point3;
   public
    Constructor create;
   end;

   // ��������� ��������� ������� ��� ��������� �������� � ����������� opengl ����
   // width, heigth - ������ � ������ ����
   // mouse_x, mouse_y  - ������� ���������� ������� ����.
   // p1, p2            - ������������ ��������� - ����� �������������� �������,
   // ������� �������������� �� ������� � ������� ���������� ���������.
   procedure CalcSelectLine(mouse_x,mouse_y:integer;var p1:point3;var p2:point3);
   // v1,v2,v3 - ������� ������������.
   // n - ������� ������������.
   // p1, p2 - ������ ����� �������, ������ ����� �������.
   // pc - ������������ ����� �����������.
   function Intersect_triangle_line(v1, v2,v3,n,p1,p2:point3;var pc:point3):boolean;
   // ��������� ����������� �������������� ������� � bounding box �������
   // m - ������� �������� � ������� ���������� �������
   function Intersect_bound(p1,p2:point3; bound:tbound; m:matrixgl; var pc:point3):boolean;
   // ���� ����������� � �����
   function Intersect_Mesh(p1,p2:point3;Mesh:tobject;var pc:point3):boolean;
   function Intersect_Obj(p1,p2:point3;obj:cobject;var pc:point3):boolean;
   // ���������, ����� �� �������� ������� vertex, ��� ����� ����� � ����������� ���� x,y
   // ������� ��������� �������� ���������� selectsize
   function SelectVertex(x,y,selectsize:integer;vertex:point3;modelMatrix,ViewMatrix:matrixgl):boolean;overload;
   function SelectVertex(x,y,selectsize:integer;vertex:point3;modelMatrix:matrixgl):boolean;overload;
   function SelectVertex(ui:pointer;x,y,selectsize:integer;vertex:point3;modelMatrix:matrixgl):boolean;overload;
   // ����� ������� ����������� ���� � ����. ������� ������!!! ���������� �������
   // ��� mesh x - ������ ������� � ������� ���������� ������
   // ��� shape - x - �����, y - ������ �������
   function findVertex(x,y,selectsize:integer;mesh:cnodeobject):tpoint;
   // ����� ��� � ����� �� ����
   // x,y ���������� ����; m - �������������� ������� ���� (Node) ����������� �������
   // len ����� ����, sight - ������ ������� ������
   // sens - ���������������� � ������ � ��������
   function DoTraceSelect(x : GLint; y : GLint;m:matrixgl;sight:point3;
                          sens:integer;len:single) : GLint;
   // ������� ������� ������ �� ����������� ������ ����
   function findobject(x,y:integer;ui:tobject):cnodeobject;


implementation
uses
  uUI,ugroupobjects, uMesh;

function findobject(x,y:integer;ui:tobject):cnodeobject;
var
  obj,curobj:cnodeobject;
  i:integer;
  p1,p2:point3;
  pc:point3;
  ps:paintstruct;
  w,h:single;
  // ���� ����������� � ���������� �������� �������������� ����
  intersect, intersectcurrent:boolean;
begin
  // � p1 � p2 ������������ ��������� �� ������������ �������
  CalcSelectLine(x, y,p1,p2);
  cui(ui).m_selectTools.startP:=p1;
  cui(ui).m_selectTools.endP:=p2;
  cui(ui).m_renderscene.p2:=p2;
  intersect:=false;
  curobj:=nil;
  curobj:=cnodeobject(cui(ui).getselected(0));
  intersectcurrent:=Intersect_Obj(p1, p2, cobject(curobj), pc);
  for I := 0 to cui(ui).scene.Objects.Count - 1 do
  begin
    obj:=cnodeobject(cui(ui).scene.GetObj(i));
    if Intersect_bound(p1, p2, cobject(obj).bound, cobject(obj).restm, pc) then
    begin
      // ���� ��������� ������������bq ������
      if (obj.objtype=constmesh) then
      begin
        if (Intersect_Mesh(p1, p2, obj, pc)) then
          intersect:=true;
      end
      else
      begin
        intersect:=true;
      end;
      // ���� ������ � �������� ������
      if (obj.group) and GetGroupState(obj) then
      begin
        obj:=getgroupleader(obj);
      end;
      // ��������� ��� ������ ����������� ������� ������ ��� ������ ������������
      if (not intersectcurrent) or intersect and (curobj<>obj) and
         (cui(ui).GetObjIndex(cui(ui).m_selectTools.selected)<i) then
      begin
        cobject(obj).doclick;
        if obj.freezObj then
        begin
          intersect:=false;
        end;
        break;
      end;
    end
    else
      obj:=nil;
  end;
  // ���� ������ �� �������� �� ���� ���������� ���������, ���� (���� ���� �����������)
  // ��������� ������� ���������
  if (not intersect) and (obj=nil) then
  begin
    if (curobj<>nil) then
      cui(ui).selectobject(nil,true)
  end
  else
  begin
    if (intersect and (obj<>nil)) then
      cui(ui).selectobject(obj,false);
  end;
  result:=obj;
  cui(ui).m_renderscene.invalidaterect;
end;

function DoTraceSelect(x : GLint; y : GLint;m:matrixgl;sight:point3;
                      sens:integer;len:single) : GLint;
var v1,n:point3;
    projection,model:array [0..15] of gldouble;
  i: Integer;
begin
  //glgetdoublev(gl_projection_matrix,projection);
  for i := 0 to 15 do
  begin
    model[i]:=m[i];
  end;

  v1:=multP3ByM(m,axisX);
  //sight.x:=projection[8]; sight.y:=projection[9]; sight.z:=projection[10];
  //NormalizeVectorP3(sight);
  // ����������� ����� � ��������� XY ������
  n:=multvectorp3(v1,sight);
  NormalizeVectorP3(n);
  // ������� ����� ������ sens � ��������� XY
//  gluUnProject(, vy, vz, @modelview, @projection, @viewport, wx, wy, wz);
//  p1.x := wx;  p1.y := wy;  p1.z := wz;
  // ��������� ������� ����� �������������� �������.
//  vz := 1;

//  gluUnProject(vx, vy, vz, @modelview, @projection, @viewport, wx, wy, wz);
//  p2.x := wx;  p2.y := wy;  p2.z := wz;

end;

Constructor cSelectTools.Create;
begin
  selected:=nil;
end;

procedure CalcSelectLine(mouse_x, mouse_y:integer;var p1:point3;var p2:point3);
var
  viewport:array [0..3] of glint;
  projection:array [0..15] of gldouble; // ������� ��������.
  modelview:array [0..15] of gldouble; // ������� ��������.
  vx,vy,vz:glfloat; // ���������� ������� ���� � ������� ��������� viewport-a.
  wx,wy,wz:gldouble; // ������������ ������� ����������.
begin

  glGetIntegerv(GL_VIEWPORT,@viewport);           // ����� ��������� viewport-a.
  glGetDoublev(GL_PROJECTION_MATRIX,@projection); // ����� ������� ��������.
  glGetDoublev(GL_MODELVIEW_MATRIX,@modelview);   // ����� ������� �������.

  // ��������� ������� ���������� ������� � ������� ��������� viewport-a.
  vx := mouse_x;
  vy := viewport[3] - mouse_y-1; // ��� height - ������� ������ ����.
  // ��������� ������� ����� �������������� �������.
  vz := 0;

  gluUnProject(vx, vy, vz, @modelview, @projection, @viewport, wx, wy, wz);
  p1.x := wx;  p1.y := wy;  p1.z := wz;
  // ��������� ������� ����� �������������� �������.
  vz := 1;

  gluUnProject(vx, vy, vz, @modelview, @projection, @viewport, wx, wy, wz);
  p2.x := wx;  p2.y := wy;  p2.z := wz;

end;

// ������� ���������� ���� �����
function f1_sgn(const k:single):integer;
begin
  if( k > 0 ) then
  begin
    result:= 1;
    exit;
  end
  else
  begin
    if( k < 0 ) then
    begin
      result:=-1;
      exit;
    end;
  end;
  result := 0;
end;

function SelectVertex(x,y,selectsize:integer;vertex:point3;modelMatrix,ViewMatrix:matrixgl):boolean;
var
  viewport:array [0..3] of glint;
  vx,vy:gldouble;
  px,py,pz:double;
  projection:array [0..15] of gldouble; // ������� ��������.
  modelview:array [0..15] of gldouble; // ������� ��������.
  wx,wy,wz:gldouble;
  I: Integer; // ������������ ������� ����������.
begin
  glGetIntegerv(GL_VIEWPORT,@viewport);           // ����� ��������� viewport-a.
  vx:=x;
  vy:=viewport[3] - y - 1;
  // ��������� ������� ���������� ������� � ������� ��������� viewport-a.
  for I := 0 to 15 do
  begin
    projection[i]:=ViewMatrix[i];
    modelview[i]:=ModelMatrix[i];
  end;
  px:=vertex.x;py:=vertex.y;pz:=vertex.z;
  gluProject(px, py, pz, @modelview, @projection, @viewport, wx, wy, wz);
  if (abs(wx-vx)<selectsize)and(abs(wy-vy)<selectsize) then
    result:=true
  else
    result:=false;
end;

function SelectVertex(ui:pointer;x,y,selectsize:integer;vertex:point3;modelMatrix:matrixgl):boolean;
var
  lx,ly,lz:integer;
  vy:gldouble;
  viewport:array [0..3] of glint;
begin
  vy:=viewport[3] - y - 1;
  glGetIntegerv(GL_VIEWPORT,@viewport);
  cui(ui).WorldToScreen(vertex,modelMatrix,lx,ly,lz);
  if (abs(cui(ui).mouse.x-lx)<selectsize)and(abs(ly-vy)<selectsize) then
    result:=true
  else
    result:=false;
end;

function SelectVertex(x,y,selectsize:integer;vertex:point3;modelMatrix:matrixgl):boolean;overload;
var
  viewport:array [0..3] of glint;
  vx,vy:gldouble;
  px,py,pz:double;
  projection:array [0..15] of gldouble; // ������� ��������.
  modelview:array [0..15] of gldouble; // ������� ��������.
  wx,wy,wz:gldouble;
  I: Integer; // ������������ ������� ����������.
begin
  glGetIntegerv(GL_VIEWPORT,@viewport);           // ����� ��������� viewport-a.
  vx:=x;
  vy:=viewport[3] - y - 1;
  glGetDoublev(GL_PROJECTION_MATRIX,@projection); // ����� ������� ��������.
  // ��������� ������� ���������� ������� � ������� ��������� viewport-a.
  for I := 0 to 15 do
  begin
    modelview[i]:=ModelMatrix[i];
  end;
  px:=vertex.x;py:=vertex.y;pz:=vertex.z;
  gluProject(px, py, pz, @modelview, @projection, @viewport, wx, wy, wz);
  if (abs(wx-vx)<selectsize)and(abs(wy-vy)<selectsize) then
    result:=true
  else
    result:=false;
end;

function findVertex(x,y,selectsize:integer;mesh:cnodeobject):tpoint;
var i,j,p,len:integer;
    v:Vector3f;
begin
  result:=point(-1, -1);
  if mesh is cmeshobr then
  begin
    for I := 0 to cmeshobr(mesh).mesh.VPointers.Count - 1 do
    begin
      p:=cmeshobr(mesh).mesh.UnicVert[i].pointers[0];
      v:=cmeshobr(mesh).mesh.drawarray[p];
      if SelectVertex(x,y,5,VtoP3(v),mesh.restm) then
      begin
        result:=point(p,p);
        exit;
      end;
    end;
  end;
  if mesh is cShapeObj then
  begin
    result:=point(-1,-1);
    for I := 0 to cShapeObj(mesh).LineCount - 1 do
    begin
      for j := 0 to length(cShapeObj(mesh).Lines[i].data)-1 do
      begin
        p:=j;
        v:=P3toV(cShapeObj(mesh).Lines[i].data[j]);
        if SelectVertex(x,y,5,VtoP3(v),mesh.restm) then
        begin
          result:=point(i,p);
          exit;
        end;
      end;
    end;
  end;
end;

function intersect_triangle_line(v1, v2,v3,n,p1,p2:point3;var pc:point3):boolean;
var r1,r2,k:single;
    ip:point3;
begin
  // ��������� ���������� ����� ������� ������� � ���������� ������������.
  r1 := multscalarp3(n , subVector(p1,v1));
  r2 := multscalarp3(n , subVector(p2,v1));
  // ���� ��� ����� ������� ����� �� ���� ������� �� ���������, �� �������
  // �� ���������� �����������.
  if( f1_sgn(r1) = f1_sgn(r2) ) then
  begin
    result:=FALSE;
    exit;
  end;
  k:=(-r1 / (r2 - r1));
  // ��������� ����� ����������� ������� � ���������� ������������.
  ip := SummVectorp3(p1,(scalevectorp3(k,(subVector(p2,p1)))));
  // ���������, ��������� �� ����� ����������� ������ ������������.
  if multscalarp3((MultVectorP3(subVector(v2,v1),subVector(ip,v1))),n) <= 0 then
  begin
    result:=FALSE;
    exit;
  end;
  if multscalarp3((MultVectorP3(subVector(v3,v2),subVector(ip,v2))),n) <= 0 then
  begin
    result:=FALSE;
    exit;
  end;
  if multscalarp3((MultVectorP3(subVector(v1,v3),subVector(ip,v3))),n) <= 0 then
  begin
    result:=FALSE;
    exit;
  end;
  pc:=ip;
  result:=TRUE;
end;

function Intersect_bound(p1,p2:point3;bound:tbound;m:matrixgl;var pc:point3):boolean;
var box:array[0..23] of point3;
begin
  if bound.exist then
  begin
    if (bound.lo.x-bound.hi.x)=0 then
    begin
      result:=false;
      exit;
    end;
    GetBoxByBound(bound.lo,bound.hi,m,box);
    if LineCrossFace(p1,p2,box[0],box[1],box[2],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[2],box[3],box[0],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[4],box[5],box[6],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[6],box[7],box[4],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[8],box[9],box[10],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[10],box[11],box[8],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[12],box[13],box[14],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[14],box[15],box[12],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[16],box[17],box[18],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[18],box[19],box[16],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[20],box[21],box[22],pc) then
    begin
      result:=true;
      exit;
    end;
    if LineCrossFace(p1,p2,box[22],box[23],box[20],pc) then
    begin
      result:=true;
      exit;
    end;
    result:=false;
  end
  else
    result:=false;
end;

function Intersect_Obj(p1,p2:point3;obj:cobject;var pc:point3):boolean;
begin
  if obj=nil then
  begin
    result:=false;
    exit;
  end;
  if obj is cmeshobr then
    result:=Intersect_Mesh(p1,p2,obj,pc)
  else
    result:=Intersect_bound(p1, p2, cobject(obj).bound, cobject(obj).restm, pc);
end;

function Intersect_Mesh(p1,p2:point3;Mesh:tobject;var pc:point3):boolean;
var i:integer;
    v1,v2,v3:point3;
begin
  result:=false;
  for I := 0 to cMeshObr(mesh).mesh.FaceCount - 1 do
  begin
    v1:=VtoP3(multVbyM(cMeshObr(mesh).restm,cMeshObr(mesh).mesh.DrawArray[cMeshObr(mesh).mesh.FaceArray[i][0]]));
    v2:=VtoP3(multVbyM(cMeshObr(mesh).restm,cMeshObr(mesh).mesh.DrawArray[cMeshObr(mesh).mesh.FaceArray[i][1]]));
    v3:=VtoP3(multVbyM(cMeshObr(mesh).restm,cMeshObr(mesh).mesh.DrawArray[cMeshObr(mesh).mesh.FaceArray[i][2]]));
    if LineCrossFace(p1,p2,v1,v2,v3,pc) then
    begin
      result:=true;
      exit;
    end;
  end;
end;

end.
