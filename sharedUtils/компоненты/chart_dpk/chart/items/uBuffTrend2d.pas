unit uBuffTrend2d;

interface

uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
     uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
     uEventList, types, NativeXML, uChartEvents, uBasicTrend, dglopengl;

type
 cBuffTrend2d = class(cBasicTrend)
  public
    // шаг по оси x между индексированными точками
    dx:single;
    // толщина линии
    weight:double;
    // цвет вершины
    pointcolor:point3;
    // данные
    data:array of point2;
    // идентификатор списка отображени€
    DisplayListName:Cardinal;
  protected
    //получить установить число вершин
    function GetCount:integer;override;
    procedure SetCount(i:integer);override;
    // получить вершину по индексу
    function GetP2(i:integer):point2;override;
    function AddPoint(p:point2):tobject;override;
    procedure compile;override;
    procedure drawLine;override;
    procedure EvalBound; override;
  public
    procedure Clear;override;
    procedure addpoints(p:array of point2; p_count:integer);override;
  end;

  const
    c_size = 40000;

implementation

function cBuffTrend2d.GetCount:integer;
begin
  result:=fcount;
end;

procedure cBuffTrend2d.SetCount(i:integer);
begin
  fcount:=i;
  Setlength(data, i);
end;

function cBuffTrend2d.GetP2(i:integer):point2;
begin
  result:=data[i];
end;

procedure cBuffTrend2d.compile;
var
  i:integer;
begin
  if  drawLines then
  begin
    if DisplayListName<>0 then
      glDeleteLists(DisplayListName, 1);
    // подготовка к компил€ции списка
    DisplayListName:=glGenLists( 1 );
    glNewList(DisplayListName, GL_COMPILE );
    glBegin(GL_LINE_STRIP);
    for I := 0 to Count - 1 do
    begin
      glVertex2f(data[i].x,data[i].y);
    end;
    glEnd;
    glEndList;
  end;
  if drawPoint then
  begin
    evalDrawPointsList;
  end;
  needRecompile:=false;
end;

// ћетод отрисовки
procedure cBuffTrend2d.drawLine;
begin
  glCallList(DisplayListName);
end;

procedure cBuffTrend2d.addpoints(p:array of point2; p_count:integer);
var
  I: Integer;
begin
  if p_count>fcount then
    count:=p_count
  else
    fcount:=p_count;
  move(p[0],data[0],p_count*sizeof(point2));
  // вызов событий обработки
  INHERITED;
  NeedRecompile:=true;
end;

procedure cBuffTrend2d.EvalBound;
var
  l:integer;
  I: Integer;
begin
  if fcount=0 then
  begin
    boundrect.TopRight:=p2(0,0);
    boundrect.BottomLeft:=p2(0,0);
    exit;
  end;
  boundrect.TopRight:=data[0];
  boundrect.BottomLeft:=data[0];
  for I := 0 to Count - 1 do
  begin
    if data[i].y>boundrect.TopRight.y then
    begin
      boundrect.TopRight.y:=data[i].y;
    end
    else
    begin
      if data[i].y<boundrect.BottomLeft.y then
        boundrect.BottomLeft.y:=data[i].y;
    end;
    if data[i].x>boundrect.TopRight.x then
    begin
      boundrect.TopRight.x:=data[i].x;
    end
    else
    begin
      if data[i].x<boundrect.BottomLeft.x then
        boundrect.BottomLeft.x:=data[i].x;
    end;
  end;
end;

function cBuffTrend2d.AddPoint(p:point2):tobject;
begin
  if fcount=length(data) then
  begin
    setlength(data, length(data)+c_size);
  end;
  data[fcount]:=p;
  inc(fcount);
  updateBound(p);
  NeedRecompile:=true;
end;

procedure cBuffTrend2d.Clear;
begin
  fcount:=0;
end;

end.
