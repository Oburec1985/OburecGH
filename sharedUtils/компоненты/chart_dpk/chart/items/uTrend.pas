unit uTrend;

interface

uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
  uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
  uEventList, types, uBasicTrend, MathFunction;

type
  selectpoint = class
  public
    i: integer;
    // тип вершины. True - вершина, False - направляющая
    t: byte;
  end;

  cTrend = class(cBasicTrend)
  public
    nearestP: point2d;

    // цвет направляющей вершины
    VectorPointColor: point3;
    // цвет линии вектора
    VectorColor: point3;
    // цвет выделенной направляющей вершины
    SelectVectorPointColor: point3;
    // цвет выделенной вершины
    SelectPointColor: point3;
    // EvalBoundsOnSetPointIf
    EvalBoundsIfPointCount: integer;
    // массив рисуемых вершин
    drawArray: array of point2;

  protected
    m_nullPolyCount: integer;
    // выделенные точки (хранит индексы)
    selected: cIntVectorList;
    // число сглаженых точек
    smoothCount: integer;
    // точность сглаживания
    SplinePrecision: integer;
    // список 2d точек отсортированный по x
    points: cFloatVectorList;
  protected
    procedure evalDrawPointsList; override;
    procedure createEvents; override;
    procedure DeleteEvents; override;
    procedure compile; override;
    function GetCount: integer; override;
    // вызывается при выделении точки
    procedure doSelectPoint(sender: tobject);
    // происходит при линковке к родителю
    // procedure doLincParent;override;
    // перекрасить вершину
    procedure changePoint(i: integer; p: point2);
    // расчет массива рисуемых вершин
    procedure evalDrawPoints;
    // Метод отрисовки
    procedure drawPoints; override;
    // отрисовать вектора выделенных точек
    procedure drawVectors;
    // Рисует только те точки которые являются вершинами направляющих векторов
    procedure DrawVectorPoints;
    procedure drawSpline(const division: integer);
    // Метод отрисовки
    procedure drawLine; override;
    // отрисовка тренда сплайнами
    procedure DrawBezie;
    function FindSelectPoint(i: integer; var index: integer): selectpoint;
    // проверка что точка выделена.Если выделена возвращает индекс в массиве selected,
    // иначе возвращает -1
    function CheckSelected(i: integer): integer;
    // происходит при смене типа точки. Sender - cBeziePoint
    procedure OnChangePointType(sender: tobject);
    // получить границу точки слева
    function GetPointLeftBorder(i: integer): single;
    // получить границу точки справа
    function GetPointRightBorder(i: integer): single;
    // держать точку в границах
    function KeepPointInBorder(p: point2; leftborder, rightborder: single)
      : point2;
    // получить кубический сплайн задаваемый
    function GetSpline(left, right: integer): CubicSpline;
  public
    constructor create; override;
    destructor destroy; override;
    function GetT0: single; override;
    function GetTypeString: string; override;
    // найти индекс точки точку по ключу
    function GetLowInd(key: single): integer; override;
    function GetHiInd(key: single): integer; override;
    function GetLow(key: single): cBeziePoint;
    function GetHi(key: single): cBeziePoint;
    // выбирает две точки слева и справа от x
    function GetLoHi(key: single; var index: tpoint): frect;
    function GetLoHi_(key: single; var lp: cBeziePoint; var rp: cBeziePoint;
      var index: tpoint): frect;
    // найти точку по ключу
    function FindPoint(key: single; var index: integer): cpoint;
    // взять точку по индексу
    function getPoint(index: integer): cBeziePoint;
    // добавить точку
    function AddPoint(p: cBeziePoint): tobject; overload;
    function AddPoint(x,y:single): tobject; overload;
    function AddPoint(p: point2): tobject; overload; override;
    procedure addpoints(p: array of point2; p_count: integer); override;
    procedure addpoints(p: array of point2d; p_count: integer); overload;
    function GetP2(i: integer): point2; override;
    // изменить тип выделенных точек
    procedure changetype;
    // возвращает true если есть сглаженные точки
    function smooth: boolean;
    // выделить вершину с индексом; ptype - тип выделенной вершины (c_point, c_left, c_right)
    // ltrend.NeedRecompile:=true; Для корректного отображения (покрасить в красный)
    function selectVertex(i: integer; ptype: integer): selectpoint;
    procedure deselectAll;
    procedure DeSelectVertex(i: integer; ptype: integer); overload;
    procedure DeSelectVertex(sp: selectpoint); overload;
    procedure DeSelectVertex(index: integer); overload;
    function selectCount: integer;
    function GetSelectPoint(i: integer): selectpoint;
    // выбирает i-ю выбранную вершину
    function GetSelected(i: integer): cBeziePoint;
    // установить точку в новые координаты
    // i - индекс точки в массиве вершин, t - тип вершины (c_point, c_left, c_right)
    // newPos - новая позиция вершины
    Procedure setPoint(p: point2; index: selectpoint);
    Procedure setPointX(x: double; index: selectpoint);
    // Найти y по известному x на сплайне
    function GetY(x: single): single; override;
    // Найти касательную в точке x;
    // параметр prec определяет точность разбиения сплайна на отрезки,
    // чтобы посчитать производную в точке
    function GetTangent(x: single; prec: single): single;
    // вставка точки
    function insertpoint(x: single): cBeziePoint;
    // число узлов  втренде
    function count: integer;
    // получить массив точек. dx - шаг с которым будут получены точки
    function getdata(dx: single): pointsarray;
    // удалить вершину
    procedure deletepoint(i: integer);
    // очистить данные
    procedure Clear; override;
    function TestObj(p_p2: point2; dist: single): boolean; override;
  public

  end;

const
  c_left = 0;
  c_right = 1;
  c_point = 2;

implementation

uses uchart, uPage, uChartEvents, uAxis;

function getp2_(bp: cBeziePoint; t: integer): point2;
begin
  case t of
    c_point:
      result := bp.point;
    c_left:
      result := bp.left;
    c_right:
      result := bp.right;
  end;
end;

constructor cTrend.create;
begin
  inherited;
  EvalBoundsIfPointCount := 30;
  weight := 1;
  NeedRecompile := false;
  smoothCount := 0;
  SplinePrecision := 30;
  SelectPointColor := red;
  PointColor := blue;
  color := black;
  VectorPointColor := green;
  SelectVectorPointColor := yellow;
  points := cFloatVectorList.create;
  points.destroydata := true;
  drawLines := true;
  drawpoint := true;
  selected := cIntVectorList.create;
  VectorColor := green;
  imageindex := c_trend_img;
end;

destructor cTrend.destroy;
begin
  points.destroy;
  selected.destroy;
  inherited;
end;

function cTrend.getPoint(index: integer): cBeziePoint;
begin
  result := cBeziePoint(points.getObj(index));
end;

function cTrend.FindPoint(key: single; var index: integer): cpoint;
begin
  result := cpoint(points.findObj(@key, index));
end;

function cTrend.GetLowInd(key: single): integer;
var
  obj: tobject;
  index: integer;
begin
  index:=-1;
  obj := points.GetLow(@key, index);
  result := index;
end;

function cTrend.GetHiInd(key: single): integer;
var
  obj: tobject;
  index: integer;
begin
  obj := points.GetHight(@key, index);
  result := index;
end;

procedure cTrend.evalDrawPoints;
var
  i, j, num, len: integer;
  bp: cBeziePoint;
  prev: double;
begin
  len := points.count;
  m_nullPolyCount := 0;
  for i := 1 to len - 1 do
  begin
    bp := cBeziePoint(points.getObj(i));
    if bp.NullPoly then
      inc(m_nullPolyCount);
  end;

  setlength(drawArray, len + m_nullPolyCount);
  j := 0;
  for i := 0 to len - 1 do
  begin
    bp := cBeziePoint(points.getObj(i));
    bp.UniqIndex := i;
    num := i + j;
    bp.Index := num;
    if i > 0 then
    begin
      if bp.NullPoly then
      begin
        drawArray[num].x := bp.x;
        drawArray[num].y := prev;
        drawArray[num + 1] := bp.point;
        inc(j);
        bp.Index := num + 1;
      end
      else
      begin
        drawArray[num] := bp.point;
      end;
    end
    else
    begin
      drawArray[num] := bp.point;
    end;
    prev := bp.point.y;
  end;
end;

procedure cTrend.evalDrawPointsList;
var
  bp: cBeziePoint;
  p: point2;
  i, j: integer;
  sp: selectpoint;
  page: cpage;
begin
  if drawPointsCallList <> 0 then
    glDeleteLists(drawPointsCallList, 1);
  // подготовка к компиляции списка
  drawPointsCallList := glGenLists(1);
  glNewList(drawPointsCallList, GL_COMPILE);
  glcolor3f(PointColor.x, PointColor.y, PointColor.z);
  glBegin(GL_Points);
  for i := 0 to count - 1 do
  begin
    bp := getPoint(i);
    if false then
    begin

    end
    else
    begin
      p := GetP2(i);

      for j := 0 to selected.count - 1 do
      begin
        sp := GetSelectPoint(j);
        if sp.i = i then
        begin
          glcolor3f(SelectPointColor.x, SelectPointColor.y, SelectPointColor.z);
        end
        else
        begin
          glcolor3f(PointColor.x, PointColor.y, PointColor.z);
        end;
      end;
      if caxis(parent).lg then
      begin
        p.y := logpointsY[i];
      end;
      page := cpage(getpage);
      if page.LgX then
      begin
        p.x := logpointsX[i];
      end;
      glVertex2f(p.x, p.y);
      // if caxis(parent).lg then
      // begin
      // glVertex2f(p.x, logpointsY[i]);
      // end
      // else
      // begin
      // if True then
      // glVertex2f(p.x, p.y);
      // end;
    end;
  end;
  glEnd;
  glEndList;
end;

procedure cTrend.addpoints(p: array of point2; p_count: integer);
var
  i: integer;
  bp: cBeziePoint;
  b: boolean;
begin
  if count = 0 then
  begin
    boundrect.BottomLeft := p[0];
    boundrect.TopRight := p[0];
  end;
  for i := 0 to p_count - 1 do
  begin
    bp := cBeziePoint.create;
    bp.point := p[i];
    points.AddObject(@bp.point.x, bp);
    bp.fonchangetype := OnChangePointType;
  end;
  for i := 0 to p_count - 1 do
  begin
    uPage.updateBound(boundrect, p[i], b);
  end;
  // вызов событий добавления точки
  bp := cBeziePoint.create;
  bp.point := boundrect.BottomLeft;
  doaddpoint(bp);
  bp.point := boundrect.TopRight;
  doaddpoint(bp);
  bp.destroy;
  // необходимо пересчитать отрисовываемые массивы
  NeedRecompile := true;
end;

procedure cTrend.addpoints(p: array of point2d; p_count: integer);
var
  i: integer;
  bp: cBeziePoint;
  b: boolean;
  lp2: point2;
begin
  
  if count = 0 then
  begin
    boundrect.BottomLeft := p2(p[0].x, p[0].y);
    boundrect.TopRight := p2(p[0].x, p[0].y); ;
  end;
  for i := 0 to p_count - 1 do
  begin
    bp := cBeziePoint.create;
    bp.point.x := p[i].x;
    bp.point.y := p[i].y;
    points.AddObject(@bp.point.x, bp);
    bp.fonchangetype := OnChangePointType;
  end;
  for i := 0 to p_count - 1 do
  begin
    lp2.x := p[i].x;
    lp2.y := p[i].y;
    uPage.updateBound(boundrect, lp2, b);
  end;
  // вызов событий добавления точки
  bp := cBeziePoint.create;
  bp.point := boundrect.BottomLeft;
  doaddpoint(bp);
  bp.point := boundrect.TopRight;
  doaddpoint(bp);
  bp.destroy;
  // необходимо пересчитать отрисовываемые массивы
  NeedRecompile := true;
end;

function cTrend.AddPoint(p: point2): tobject;
var
  bp: cBeziePoint;
begin
  bp := cBeziePoint.create;
  bp.point := p;
  AddPoint(bp);
  result := bp;
end;

function cTrend.AddPoint(x,y:single): tobject;
begin
  result:=AddPoint(p2(x,y));
end;

function cTrend.AddPoint(p: cBeziePoint): tobject;
var
  i: integer;
  bp: cBeziePoint;
begin
  i := points.AddObject(@p.point.x, p);
  p.UniqIndex := i;
  for i := i + 1 to points.count - 1 do
  begin
    bp := getPoint(i);
    bp.UniqIndex := i;
  end;
  p.fonchangetype := OnChangePointType;
  if p.smooth then
  begin
    inc(smoothCount);
  end;
  // обновляем границу
  updateBound(p.point);
  // необходимо пересчитать отрисовываемые массивы
  NeedRecompile := true;
  // вызов событий добавления точки
  doaddpoint(p);
  result := p;
end;

procedure cTrend.Clear;
begin
  while count <> 0 do
  begin
    points.deleteIndObj(0);
  end;
  // расчет массива рисуемых вершин
  evalDrawPoints;
  boundrect.BottomLeft := p2(0, 0);
  boundrect.TopRight := p2(0, 0);
end;

procedure cTrend.deletepoint(i: integer);
var
  p: cpoint;
begin
  p := getPoint(i);
  if p <> nil then
  begin
    points.deleteIndObj(i);
    // расчет массива рисуемых вершин
    evalDrawPoints;
    // если удалили одну из вершин
    if (p.x = boundrect.BottomLeft.x) or (p.x = boundrect.TopRight.x) or
      (p.y = boundrect.BottomLeft.y) or (p.y = boundrect.TopRight.y) then
    begin
      EvalBounds;
    end;
  end;
end;

procedure cTrend.drawPoints;
var
  red: point3;
  i, j, len: integer;
  _in: boolean;
Begin
  if caxis(parent).lg then
  begin
    inherited
  end
  else
  begin
    len := length(drawArray);
    if len = 0 then
      exit;
    glCallList(drawPointsCallList);
    { red.x:=1; red.y:=0; red.z:=0;
      // Определение цветов рисуемых точек
      if selected.Count=0 then
      glColor3fv(@pointcolor)
      else
      begin
      glEnableClientState(GL_Color_ARRAY);
      glColorPointer(3, GL_FLOAT, 0,@colors[0]);
      end;
      glEnableClientState(GL_VERTEX_ARRAY) ;
      glVertexPointer(2, GL_FLOAT, 0,@drawArray[0]);
      glDrawArrays(GL_Points,0,len);
      glDisableClientState(GL_VERTEX_ARRAY);
      if selected.Count<>0 then
      begin
      glDisableClientState(GL_Color_ARRAY);
      end; }
  end;
  // отрисовка ближайшей точки
  if false then
  begin
    glcolor3f(PointColor.x, PointColor.y, PointColor.z);
    glBegin(GL_Points);
    glVertex2f(nearestP.x, nearestP.y);
    glEnd;
  end;
end;

// возвращает -1 если нет такой буквы
function cTrend.CheckSelected(i: integer): integer;
begin
  result := selected.GetIndex(@i);
end;

procedure cTrend.DrawVectorPoints;
var
  bp: cBeziePoint;
  sp: selectpoint;
  index, i, j: integer;
  leftcolor, rightcolor: point3; // цвета выделенной вершины
  procedure drawOnePoint(p: point2; color: point3);
  begin
    glColor3fv(@color);
    glBegin(GL_Points);
    glvertex2fv(@p);
    glEnd;
  end;

Begin
  for i := 0 to points.count - 1 do
  begin
    bp := cBeziePoint(points.getObj(i));
    if bp.smooth then
    begin
      // если вершина i выделена, то возвращается индекс в массиве выделенных вершин
      sp := FindSelectPoint(i, index);
      leftcolor := VectorPointColor;
      rightcolor := VectorPointColor;
      // если данная вершина выделена? причем выделена направляющая
      if (sp <> nil) then
      begin
        while (sp <> nil) and (sp.i = i) do
        begin
          inc(index);
          case sp.t of
            c_left:
              leftcolor := SelectVectorPointColor;
            c_right:
              rightcolor := SelectVectorPointColor;
          end;
          sp := GetSelectPoint(index);
        end;
        drawOnePoint(bp.left, leftcolor);
        drawOnePoint(bp.right, rightcolor);
      end
    end;
  end;
end;

// отрисовка сплайнов
procedure cTrend.drawSpline(const division: integer);
var
  spline: array [0 .. 3] of point3;
  i, j: integer;
  bp: cBeziePoint;
  nullSpline: boolean;
begin
  for i := 0 to points.count - 2 do
  begin
    // определяем первые две точки сплайна
    bp := cBeziePoint(points.getObj(i));
    spline[0].x := bp.x;
    spline[0].y := bp.y;
    spline[0].z := 0;
    if bp.smooth then
    begin
      spline[1].x := bp.right.x;
      spline[1].y := bp.right.y;
      spline[1].z := 0;
    end
    else
      spline[1] := spline[0];
    // определяем вторые две точки сплайна
    bp := cBeziePoint(points.getObj(i + 1));
    spline[3].x := bp.x;
    spline[3].y := bp.y;
    spline[3].z := 0;
    if bp.smooth then
    begin
      spline[2].x := bp.left.x;
      spline[2].y := bp.left.y;
      spline[2].z := 0;
    end
    else
      spline[2] := spline[3];
    nullSpline := bp.NullPoly;
    if not nullSpline then
    begin
      // отрисовка сплайна по 4-м вершинам
      glMap1f(GL_MAP1_VERTEX_3, 0.0, 1.0, 3, 4, @spline[0]);
      glEnable(GL_MAP1_VERTEX_3);
      glColor3fv(@color);
      glBegin(GL_LINE_STRIP);
      For j := 0 to division do
        glEvalCoord1f(j / SplinePrecision);
      glEnd;
    end
    else
    begin
      glBegin(GL_LINE_STRIP);
      glVertex2f(spline[0].x, spline[0].y);
      glVertex2f(spline[3].x, spline[0].y);
      glVertex2f(spline[3].x, spline[3].y);
      glEnd;
    end;
  end;
end;

// Рисовать линии направляющих векторов
procedure cTrend.drawVectors;
var
  i: integer;
  bp: cBeziePoint;
  procedure drawvector(bp: cBeziePoint);
  begin
    glColor3fv(@VectorColor);
    glBegin(gl_lines);
    glvertex2fv(@bp.left);
    glvertex2fv(@bp.point);
    glEnd;
    glBegin(gl_lines);
    glvertex2fv(@bp.right);
    glvertex2fv(@bp.point);
    glEnd;
  end;

begin
  glColor3fv(@color);
  for i := 0 to selected.count - 1 do
  begin
    bp := GetSelected(i);
    if bp.smooth then
      drawvector(bp);
  end;
end;

procedure cTrend.DrawBezie;
begin
  drawSpline(30);
  DrawVectorPoints;
  drawVectors;
end;

procedure cTrend.drawLine;
var
  len: integer;
  p:cpage;
begin
  p:=cpage(getpage);
  if caxis(parent).lg or p.LgX  then
  begin
    inherited
  end
  else
  begin
    if not smooth then
    begin
      len := length(drawArray);
      if len = 0 then
        exit;
      glColor3fv(@color);
      glEnableClientState(GL_VERTEX_ARRAY);
      glVertexPointer(2, GL_FLOAT, 0, @drawArray[0]);
      glDrawArrays(GL_LINE_STRIP, 0, len);
      glDisableClientState(GL_VERTEX_ARRAY);
    end
    else
    begin
      DrawBezie;
    end;
  end;
end;

procedure cTrend.OnChangePointType(sender: tobject);
var
  bp, lp, rp: cBeziePoint;
begin
  bp := cBeziePoint(sender);
  case bp.m_changeState of
    stCubeToLine:
      begin
        dec(smoothCount);
      end;
    stCubeToNull:
      begin
        dec(smoothCount);
        // inc(m_nullPolyCount);
      end;
    stLineToCube:
      begin
        inc(smoothCount);
        lp := nil;
        if bp.UniqIndex > 0 then
        begin
          lp := getPoint(bp.UniqIndex - 1);
          bp.left.x := bp.point.x - (bp.point.x - lp.point.x) / 2;
          bp.left.y := bp.point.y - (bp.point.y - lp.point.y) / 2;
        end;
        rp := nil;
        if bp.UniqIndex < count - 1 then
        begin
          rp := getPoint(bp.UniqIndex + 1);
          bp.right.x := bp.point.x - (bp.point.x - rp.point.x) / 2;
          bp.right.y := bp.point.y - (bp.point.y - rp.point.y) / 2;
        end;
      end;
    stLineToNull:
      begin
        // inc(m_nullPolyCount);
      end;
    stNullToLine:
      begin
        // dec(m_nullPolyCount);
      end;
    stNullToCube:
      begin
        // dec(m_nullPolyCount);
        inc(smoothCount);
        lp := nil;
        if bp.UniqIndex > 0 then
        begin
          lp := getPoint(bp.UniqIndex - 1);
          bp.left.x := bp.point.x - (bp.point.x - lp.point.x) / 2;
          bp.left.y := bp.point.y - (bp.point.y - lp.point.y) / 2;
        end;
        rp := nil;
        if bp.UniqIndex < count - 1 then
        begin
          rp := getPoint(bp.UniqIndex + 1);
          bp.right.x := bp.point.x - (bp.point.x - rp.point.x) / 2;
          bp.right.y := bp.point.y - (bp.point.y - rp.point.y) / 2;
        end;
      end;
    stNone:
      ;
  end;
  evalDrawPoints;
  evalDrawPointsList;
end;

procedure cTrend.changetype;
var
  bp: cBeziePoint;
  count, i: integer;
  l, r, c: single;
  sp: selectpoint;
begin
  for i := 0 to selectCount - 1 do
  begin
    bp := GetSelected(i);
    // инвертируем тип вершины. Событие смены типа, в котором происходит подсчет числа сглаженных вершин
    // происходит аутомотично
    bp.smooth := not bp.smooth;
    if bp.smooth then
    begin
      sp := selectpoint(selected.getObj(i));
      l := GetPointLeftBorder(sp.i);
      r := GetPointRightBorder(sp.i);
      c := (l + bp.point.x) / 2;
      bp.left := p2(c, GetY(c));
      c := (r + bp.point.x) / 2;
      bp.right := p2(c, GetY(c));
    end;
  end;
end;

function cTrend.GetSelected(i: integer): cBeziePoint;
begin
  result := cBeziePoint(getPoint(GetSelectPoint(i).i));
end;

function cTrend.FindSelectPoint(i: integer; var index: integer): selectpoint;
begin
  result := selectpoint(selected.findObj(@i, index));
end;

function cTrend.GetSelectPoint(i: integer): selectpoint;
begin
  result := selectpoint(selected.getObj(i));
end;

function cTrend.smooth: boolean;
begin
  result := (smoothCount > 0);
end;

function cTrend.TestObj(p_p2: point2; dist: single): boolean;
var
  i: integer;
  lDist: single;
  lp1, lp2: cBeziePoint;
  spline: CubicSpline;
begin
  result := false;
  if count > 1 then
  begin
    p_p2.x := p_p2.x - position.x;
    p_p2.y := p_p2.y - position.y;
    i := FindLoBound(p_p2.x, 0, count);
    lp1 := getPoint(i);
    if i < count - 1 then
    begin
      lp2 := getPoint(i + 1);
      // не работает для сплайна!!!
      spline := GetSpline(i, i + 1);
      if lp1.smooth or lp2.smooth then
      begin
        nearestP := NearestPCubicSpline(spline, p2d(p_p2.x, p_p2.y));
        lDist := DistPtoCubicSpline(spline, p2d(p_p2.x, p_p2.y));
      end
      else
      begin
        lDist := GetDistance(lp1.point, lp2.point, p_p2);
      end;
      if lDist <> -1 then
      begin
        if lDist < dist then
        begin
          result := true;
        end;
      end;

    end;
  end;
end;

function cTrend.selectVertex(i: integer; ptype: integer): selectpoint;
var
  p: selectpoint;
  index: integer;
  page: cpage;
begin
  p := selectpoint(selected.findObj(@i, index));
  if p = nil then
  begin
    p := selectpoint.create;
    p.i := i;
    p.t := ptype;
    selected.AddObject(@i, p);
    page := cpage(getpage);
  end;
  result := p;
  // вызов событий выделения точек
  page.events.CallAllEventsWithSender(e_onSelectPoint, getPoint(p.i));
end;

procedure cTrend.DeSelectVertex(i: integer; ptype: integer);
var
  p: selectpoint;
  ind: integer;
begin
  p := selectpoint(selected.GetLow(@i, ind));
  while p.i <> i do
  begin
    inc(ind);
    p := selectpoint(selected.getObj(ind));
    if p.i > i then
      exit;
  end;
  if (p.i = i) and (p.t = ptype) then
  begin
    selected.deleteIndObj(ind);
  end;
end;

procedure cTrend.DeSelectVertex(sp: selectpoint);
var
  p: selectpoint;
  ind: integer;
begin
  p := selectpoint(selected.GetLow(@sp.i, ind));
  while p <> sp do
  begin
    inc(ind);
    p := selectpoint(selected.getObj(ind));
    if p.i > sp.i then
      exit;
  end;
  selected.deleteIndObj(ind);
end;

procedure cTrend.DeSelectVertex(index: integer);
var
  p: selectpoint;
begin
  p := selectpoint(selected.getObj(index));
  selected.deleteIndObj(index);
  NeedRecompile := true;
end;

// переместить вершину
procedure cTrend.changePoint(i: integer; p: point2);
var
  len: integer;
  bp, prev: cBeziePoint;
begin
  len := length(drawArray);
  if i < len then
  begin
    bp := getPoint(i);
    if bp.NullPoly then
    begin
      if i > 0 then
      begin
        prev := getPoint(i - 1);
        drawArray[bp.Index - 1] := prev.point;
        drawArray[bp.Index - 1].x := bp.point.x;
        drawArray[bp.Index] := bp.point;
        if len > bp.Index + 1 then
        begin
          drawArray[bp.Index + 1].y := bp.point.y;
        end;
      end;
    end
    else
    begin
      drawArray[bp.index] := bp.point;
    end;
  end;
end;

procedure cTrend.deselectAll;
begin
  while selected.count <> 0 do
  begin
    DeSelectVertex(0);
  end;
end;

function cTrend.selectCount: integer;
begin
  result := selected.count;
end;

// получить границу точки слева
function cTrend.GetPointLeftBorder(i: integer): single;
var
  bp: cBeziePoint;
begin
  if i - 1 >= 0 then
  begin
    bp := cBeziePoint(getPoint(i - 1));
    if bp = nil then
    begin
      result := -1000000;
      exit;
    end;
    if bp.smooth then
    begin
      result := bp.right.x;
    end
    else
      result := bp.point.x;
  end
  else
    result := -1000000;
end;

// получить границу точки справа
function cTrend.GetPointRightBorder(i: integer): single;
var
  bp: cBeziePoint;
begin
  bp := cBeziePoint(getPoint(i + 1));
  if bp = nil then
  begin
    result := 1000000;
    exit;
  end;
  if bp.smooth then
  begin
    result := bp.left.x;
  end
  else
    result := bp.point.x;
end;

function cTrend.KeepPointInBorder(p: point2;
  leftborder, rightborder: single): point2;
begin
  if p.x > rightborder then
    p.x := rightborder;
  if p.x < leftborder then
    p.x := leftborder;
  result := p;
end;

Procedure cTrend.setPointX(x: double; index: selectpoint);
var
  bp: cBeziePoint;
  p, oldpos, strafe: point2;
  leftborder, rightborder: single;
  node: cFloatVectorObj;
  ind: integer;
begin
  bp := cBeziePoint(getPoint(index.i));
  leftborder := GetPointLeftBorder(index.i);
  rightborder := GetPointRightBorder(index.i);
  // приводим точку по x к диапазону внутри leftborder..rightborder
  oldpos := getp2_(bp, index.t);
  p.x := x;
  p.y := oldpos.y;
  p := KeepPointInBorder(p, leftborder, rightborder);
  updateBound(p);
  case index.t of
    c_point:
      begin
        strafe := subP(p, oldpos);
        bp.point := p;
        node := cFloatVectorObj(points.getNode(index.i));
        node.setfKey(p.x);
        bp.left := summp2(bp.left, strafe);
        bp.left := KeepPointInBorder(bp.left, leftborder, rightborder);
        bp.right := summp2(bp.right, strafe);
        bp.right := KeepPointInBorder(bp.right, leftborder, rightborder);
        changePoint(index.i, p);
        // пересчитываем вершины отрисовки
        evalDrawPointsList;
      end;
    c_left:
      begin
        bp.left := p;
      end;
    c_right:
      begin
        bp.right := p;
      end;
  end;
  if EvalBoundsIfPointCount > count then
  begin
    EvalBounds;
  end;
  if assigned(cchart(chart).OnMovePoint) then
  begin
    cchart(chart).OnMovePoint(self, getPoint(index.i));
  end;
end;

// Установить выделенные точки в заданные координаты
Procedure cTrend.setPoint(p: point2; index: selectpoint);
var
  bp: cBeziePoint;
  oldpos, strafe: point2;
  leftborder, rightborder: single;
  node: cFloatVectorObj;
begin
  bp := cBeziePoint(getPoint(index.i));
  leftborder := GetPointLeftBorder(index.i);
  rightborder := GetPointRightBorder(index.i);
  // приводим точку по x к диапазону внутри leftborder..rightborder
  p := KeepPointInBorder(p, leftborder, rightborder);
  updateBound(p);
  oldpos := getp2_(bp, index.t);
  case index.t of
    c_point:
      begin
        strafe := subP(p, oldpos);
        bp.point := p;
        node := cFloatVectorObj(points.getNode(index.i));
        node.setfKey(p.x);
        bp.left := summp2(bp.left, strafe);
        bp.left := KeepPointInBorder(bp.left, leftborder, rightborder);
        bp.right := summp2(bp.right, strafe);
        bp.right := KeepPointInBorder(bp.right, leftborder, rightborder);
        changePoint(index.i, p);
        // пересчитываем вершины отрисовки
        evalDrawPoints;
        // перекомпилируем отрисовку
        evalDrawPointsList;
      end;
    c_left:
      begin
        bp.left := p;
      end;
    c_right:
      begin
        bp.right := p;
      end;
  end;
  if EvalBoundsIfPointCount > count then
  begin
    EvalBounds;
  end;
  if assigned(cchart(chart).OnMovePoint) then
  begin
    cchart(chart).OnMovePoint(self, getPoint(index.i));
  end;
end;

function cTrend.GetSpline(left, right: integer): CubicSpline;
var
  bp, rightP: cBeziePoint;
begin
  // формула сплайна:
  // b0*P0+b1*P1+B2*P2+b3*P3
  // B0 = (1-u)^3; B1 = 3u(1-u)^2; B2 = 3*u^2(1-u); B3 = (u)^3
  // Кубическое уравнение a*x^3+b*x^2+c*x+d = 0
  // Cплайн приведенный к виду кубического уравнения
  // (3x1-x0-3x2+x3)*u^3 + (3x0+3x2-6x1)*u^2 + (-3x0+3x1)*u +x0
  result.NullPoly := false;
  result.smooth := false;
  bp := getPoint(left);
  if bp = nil then
    exit;
  result.p0 := bp.point;
  if bp.smooth then
    result.p1 := bp.right
  else
    result.p1 := bp.point;
  // -----------------------
  result.smooth := bp.smooth;
  rightP := getPoint(right);
  if rightP.NullPoly then
  begin
    result.NullPoly := true;
    result.p2 := bp.point;
    result.p3 := bp.point;
  end
  else
  begin
    bp := rightP;
    if bp.smooth then
      result.p2 := bp.left
    else
      result.p2 := bp.point;
    result.p3 := bp.point;
    if bp.smooth then
      result.smooth := true;
  end;
end;

function cTrend.GetY(x: single): single;
var
  right, left: integer; // индексы соседних точек
  u: single;
  spline: CubicSpline;
  bp: cBeziePoint;
begin
  x := x - position.x;
  entercs;
  if count = 0 then
  begin
    result := 0;
    exitcs;
    exit;
  end;
  right := GetHiInd(x);
  left := GetLowInd(x);
  spline := GetSpline(left, right);
  if spline.NullPoly then
  begin
    if x < spline.p3.x then
      result := spline.p0.y
    else
      result := spline.p3.y;
  end
  else
  begin
    if spline.smooth then
    begin
      u := FindPointOnSpline(spline, x);
      result := EvalSplinePoint(u, spline).y;
    end
    else
    begin
      result := EvalLineY(x, spline.p0, spline.p3);
    end;
  end;
  exitcs;
end;

function cTrend.insertpoint(x: single): cBeziePoint;
var
  y: single;
begin
  y := GetY(x);
  result := cBeziePoint(AddPoint(p2(x, y)));
end;

function cTrend.count: integer;
begin
  result := points.count;
end;

procedure cTrend.doSelectPoint(sender: tobject);
var
  chart: cchart;
  p: cpage;
begin
  p := cpage(getpage);
  chart := cchart(p.chart);
  if assigned(chart.onSelectpoint) then
    chart.onSelectpoint(sender);
end;

procedure cTrend.createEvents;
begin
  // events.AddEvent('trendAddpoint', e_onAddpoint, doaddpoint);
  events.AddEvent('trendSelectPoint', e_onSelectPoint, doSelectPoint);
end;

procedure cTrend.DeleteEvents;
begin
  // events.removeEvent(doaddpoint, e_onAddpoint);
  events.removeEvent(doSelectPoint, e_onSelectPoint, self);
  inherited;
end;

// получить массив точек. dx - шаг с которым будут получены точки
function cTrend.getdata(dx: single): pointsarray;
var
  i, len: cardinal;
  dx_, x: single;
  a: array of point2;
  bp: cBeziePoint;
begin
  dx_ := caxis(parent).getdx;
  len := round(dx_ / dx);
  setlength(a, len + 1);
  for i := 0 to len - 1 do
  begin
    x := i * dx;
    a[i].x := x;
    a[i].y := GetY(x);
  end;
  bp := getPoint(count - 1);
  a[len] := bp.point;
  result := pointsarray(a);
end;

function cTrend.GetTangent(x: single; prec: single): single;
var
  line: frect;
  p: tpoint;
  lp, rp: cBeziePoint;
  smooth: boolean;
  lx: single;
begin
  entercs;
  line := GetLoHi_(x, lp, rp, p);
  // узнаем являеться ли сплайн кривой безье или просто отрезок
  smooth := lp.smooth or rp.smooth;
  if smooth then
  begin
    lx := x - prec;
    if lx > boundrect.BottomLeft.x then
    begin
      line.BottomLeft := p2(lx, GetY(lx));
    end;
    lx := x + prec;
    if lx < boundrect.TopRight.x then
    begin
      line.TopRight := p2(lx, GetY(lx));
    end;
  end;
  exitcs;
  result := (line.TopRight.y - line.BottomLeft.y) /
    (line.TopRight.x - line.BottomLeft.x);
end;

function cTrend.GetLow(key: single): cBeziePoint;
var
  i: integer;
begin
  i := GetLowInd(key);
  result := getPoint(i);
end;

function cTrend.GetHi(key: single): cBeziePoint;
var
  i: integer;
begin
  i := GetHiInd(key);
  result := getPoint(i);
end;

function cTrend.GetLoHi(key: single; var index: tpoint): frect;
var
  lp, rp: cBeziePoint;
begin
  result := GetLoHi_(key, lp, rp, index);
end;

function cTrend.GetLoHi_(key: single; var lp: cBeziePoint; var rp: cBeziePoint;
  var index: tpoint): frect;
var
  lo: integer;
  p2: point2;
begin
  lo := GetLowInd(key);
  index.x := lo;
  lp := getPoint(lo);
  result.BottomLeft := lp.point;

  if lo <= count - 1 then
  begin
    rp := getPoint(lo + 1);
    p2 := rp.point;
    if (p2.x <> key) then
    begin
      index.y := lo + 1;
      result.TopRight := p2;
    end;
  end
  else
  begin
    if (lo + 2 <= count - 1) then
    begin
      rp := getPoint(lo + 2);
      result.TopRight := rp.point;
      index.y := lo + 2;
    end
    else
    begin
      rp := lp;
      result.TopRight := p2;
      index.y := lo + 1;
    end;
  end;
end;

function cTrend.GetTypeString: string;
begin
  result := 'Тренд';
end;

function cTrend.GetCount: integer;
begin
  result := points.count;
end;

function cTrend.GetP2(i: integer): point2;
begin
  result := getPoint(i).point;
end;

procedure cTrend.compile;
begin
  evalDrawPoints;
  inherited;
end;

function cTrend.GetT0: single;
begin
  result := getPoint(0).point.x;
end;

end.
