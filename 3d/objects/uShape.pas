unit uShape;

interface

uses
  Windows, OpenGL, Classes, MathFunction, TextureGl, uMaterial,
  SysUtils, uObject, uObjectTypes, umatrix, uMesh, unodeobject, uCommonTypes;

type
  tline = record
    closed: byte;
    data: array of point3;
  end;

  cShapeObj = class(cObject)
  public
    inst: boolean; // Копия другого объекта?   instname:string; // имя прототипа
    instname: string;
    fMesh: cMesh;
    LineCount: integer;
    Lines: array of tline;

    fdrawlines, fdrawverts:boolean;
  private
    // x, y - номре линии, точка внутри линии;
    selectPoints:tpoint;
  private
    CallListLine, CallListVerts:cardinal;
  private
    procedure DrawLine;
    procedure DrawVert;
  protected
    procedure compile;override;
    procedure drawdata; override;
  public
    // function getCopy:cnodeobject;override;
    // procedure CopyTo(obj:cnodeobject);override;
    // Рассчитать min max позиции по x и y;
    Constructor Create; override;
    destructor destroy; override;
    function typestring:string;override;
    procedure UpdateBounds;override;
  protected
  public
    property drawLines:boolean read fdrawLines write fdrawLines;
    property drawVerts:boolean read fdrawverts write fdrawverts;
  end;

implementation

function cShapeObj.typestring:string;
begin
  result:='Линия';
end;

procedure cShapeObj.UpdateBounds;
var
  i, j:integer;
  min,max:point3;
  line:tline;
begin
  min.x:=0;
  min.y:=0;
  min.z:=0;
  max.x:=0;
  max.y:=0;
  max.z:=0;
  for I := 0 to LineCount - 1 do
  begin
    line:=lines[i];
    for j := 0 to length(line.data) - 1 do
    begin
      if min.x>line.data[j].x then
        min.x:=line.data[j].x
      else
      begin
        if max.x<line.data[j].x then
          max.x:=line.data[j].x;
      end;

      if min.y>line.data[j].y then
        min.y:=line.data[j].y
      else
      begin
        if max.y<line.data[j].y then
          max.y:=line.data[j].y;
      end;

      if min.z>line.data[j].z then
        min.z:=line.data[j].z
      else
      begin
        if max.z<line.data[j].z then
          max.z:=line.data[j].z;
      end;
    end;
  end;
  bound.lo:=min;
  bound.hi:=max;
end;

Constructor cShapeObj.Create;
begin
  inherited;
  fhelper:=false;
  imageindex:=constShapeImgIndex;
  fdrawlines:=true;
  fdrawverts:=true;
  objtype := constshape;
  setflag(draw_Edges);
  inst := false;
end;

destructor cShapeObj.destroy;
begin
  inherited;
end;

procedure cShapeObj.compile;
var
  i, j:integer;
  p:point3;
begin
  if needRecompile then
  begin
    if CallListLine<>0 then
      glDeleteLists(CallListLine, 1);
    // подготовка к компиляции списка линий
    CallListLine:=glGenLists( 1 );
    glNewList(CallListLine, GL_COMPILE );
    if drawLines then
    begin
      for I := 0 to LineCount - 1 do
      begin
        glBegin(GL_LINE_STRIP);
        for j := 0 to length(lines[i].data) - 1 do
        begin
          p:=lines[i].data[j];
          glVertex3fv(@p);
        end;
        glEnd;
      end;
    end;
    glEndList;
    if CallListVerts<>0 then
      glDeleteLists(CallListVerts, 1);
    // подготовка к компиляции списка линий
    CallListVerts:=glGenLists( 1 );
    glNewList(CallListVerts, GL_COMPILE );
    // компиляция отрисовки вершин
    if drawVerts then
    begin
      glpointsize(5);
      glBegin(GL_POINTS);
      for I := 0 to LineCount - 1 do
      begin
        for j := 0 to length(lines[i].data) - 1 do
        begin
          p:=lines[i].data[j];
          glVertex3fv(@p);
        end;
      end;
      glEnd;
    end;
    needRecompile:=false;
    glEndList;
  end;
end;


procedure cShapeObj.DrawLine;
begin
  glcolor3fv(@defoultcolor);
  glCallList(CallListLine);
end;

procedure cShapeObj.DrawVert;
begin
  glcolor3fv(@red);
  glCallList(CallListVerts);
end;

procedure cShapeObj.drawdata;
begin
  compile;
  if drawLines then
    DrawLine;
  if drawVerts then
    DrawVert;
end;

end.
