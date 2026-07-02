unit uSimpleTrend;

interface
uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
     uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
     uEventList, types, NativeXML;

implementation

{type

  cSimpleTrend = class(cdrawobj)
  public
    weight:double;
    // цвет вершины
    pointcolor:point3;
    // цвет направляющей вершины
    VectorPointColor:point3;
    // цвет линии вектора
    VectorColor:point3;
    // цвет выделенной направляющей вершины
    SelectVectorPointColor:point3;
    // цвет выделенной вершины
    SelectPointColor:point3;
    // EvalBoundsOnSetPointIf
    EvalBoundsIfPointCount:integer;
  protected
    // необходимо пересчитать массив вершин
    NeedReEvalDrawArray:boolean;
    // выделенные точки (хранит индексы)
    selected:cIntVectorList;
    // число сглаженых точек
    smoothCount:integer;
    // точность сглаживания
    SplinePrecision:integer;
    // опции тренда
    settings:cardinal;
    // массив цветов точек
    colors:array of point3;
    // массив рисуемых вершин
    drawArray:array of point2;
    // список 2d точек отсортированный по x
    points:cFloatVectorList;
  protected
    procedure createEvents;override;
    procedure DeleteEvents;override;
    // пересчитывает границы объекта тупым перебором всех точек
    procedure EvalBounds;
    // вызывается при выделении точки
    procedure doSelectPoint(sender:tobject);
    // вызывается при добавлении точки
    procedure doAddPoint(sender:tobject);
    // происходит при линковке к родителю
    //procedure doLincParent;override;
    // если точка p выходит за границу boundrect то обновляется boundrect
    procedure updateBound(p:point2);
    // перекрасить вершину
    procedure changecolor(i:integer;color:point3);
    // перекрасить вершину
    procedure changePoint(i:integer;p:point2);
    // расчет массива рисуемых вершин
    procedure evalDrawPoints;
    // обновление массива цветов вершин. Вызывается при обновлении списка выделенных вершин
    procedure evalColors;
    // Метод отрисовки
    procedure drawPoints;
    // отрисовать вектора выделенных точек
    procedure drawVectors;
    // Рисует только те точки которые являются вершинами направляющих векторов
    procedure DrawVectorPoints;
    procedure drawSpline(const division:integer);
    // Метод отрисовки
    procedure drawLine;
    // отрисовка тренда сплайнами
    procedure DrawBezie;
    function FindSelectPoint(i:integer;var index:integer):selectpoint;
    // проверка что точка выделена.Если выделена возвращает индекс в массиве selected,
    // иначе возвращает -1
    function CheckSelected(i:integer):integer;
    procedure setflag(flag:cardinal);
    procedure dropflag(flag:cardinal);
    // происходит при смене типа точки. Sender - cBeziePoint
    procedure OnChangePointType(sender:tobject);
    // получить границу точки слева
    function GetPointLeftBorder(i:integer):single;
    // получить границу точки справа
    function GetPointRightBorder(i:integer):single;
    // держать точку в границах
    function KeepPointInBorder(p:point2; leftborder,rightborder:single):point2;
    // получить кубический сплайн задаваемый
    function GetSpline(left,right:integer):CubicSpline;
    // Метод отрисовки
    procedure drawdata;override;
    function getdrawpoint:boolean;
    procedure setdrawpoint(b:boolean);
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    constructor create;override;
    destructor destroy;override;
    function GetTypeString:string;override;
    // найти индекс точки точку по ключу
    function GetLowInd(key:single):integer;
    function GetHiInd(key:single):integer;
    function GetLow(key:single):cBeziePoint;
    function GetHi(key:single):cBeziePoint;
    // выбирает две точки слева и справа от x
    function GetLoHi(key:single; var index:tpoint):frect;
    function GetLoHi_(key:single; var lp:cbeziepoint;var rp:cbeziepoint; var index:tpoint):frect;
    // найти точку по ключу
    function FindPoint(key:single; var index:integer):cpoint;
    // взять точку по индексу
    function getPoint(index:integer):cbeziepoint;
    // добавить точку
    procedure AddPoint(p:cBeziePoint);overload;
    procedure AddPoint(p:point2);overload;
    procedure addpoints(p:array of point2);
    // изменить тип выделенных точек
    procedure changetype;
    // возвращает true если есть сглаженные точки
    function smooth:boolean;
    // выделить вершину с индексом; ptype - тип выделенной вершины (c_point, c_left, c_right)
    function selectVertex(i:integer; ptype:integer):selectpoint;
    procedure deselectAll;
    procedure DeSelectVertex(i:integer; ptype:integer);overload;
    procedure DeSelectVertex(sp:selectpoint);overload;
    procedure DeSelectVertex(index:integer);overload;
    function selectCount:integer;
    function GetSelectPoint(i:integer):selectpoint;
    // выбирает i-ю выбранную вершину
    function GetSelected(i:integer):cBeziePoint;
    // установить точку в новые координаты
    // i - индекс точки в массиве вершин, t - тип вершины (c_point, c_left, c_right)
    // newPos - новая позиция вершины
    Procedure setPoint(p:point2; index:selectpoint);
    // Найти y по известному x на сплайне
    function GetY(x:single):single;
    // Найти касательную в точке x;
    // параметр prec определяет точность разбиения сплайна на отрезки,
    // чтобы посчитать производную в точке
    function GetTangent(x:single; prec:single):single;
    // вставка точки
    function insertpoint(x:single):cBeziePoint;
    // число узлов  втренде
    function count:integer;
    // получить массив точек. dx - шаг с которым будут получены точки
    function getdata(dx:single):pointsarray;
    // удалить вершину
    procedure deletepoint(i:integer);
    // очистить данные
    procedure Clear;
  public
    property drawpoint:boolean read getdrawpoint write setdrawpoint;
  end;}

end.
