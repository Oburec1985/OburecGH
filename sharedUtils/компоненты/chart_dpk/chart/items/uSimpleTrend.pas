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
    // ���� �������
    pointcolor:point3;
    // ���� ������������ �������
    VectorPointColor:point3;
    // ���� ����� �������
    VectorColor:point3;
    // ���� ���������� ������������ �������
    SelectVectorPointColor:point3;
    // ���� ���������� �������
    SelectPointColor:point3;
    // EvalBoundsOnSetPointIf
    EvalBoundsIfPointCount:integer;
  protected
    // ���������� ����������� ������ ������
    NeedReEvalDrawArray:boolean;
    // ���������� ����� (������ �������)
    selected:cIntVectorList;
    // ����� ��������� �����
    smoothCount:integer;
    // �������� �����������
    SplinePrecision:integer;
    // ����� ������
    settings:cardinal;
    // ������ ������ �����
    colors:array of point3;
    // ������ �������� ������
    drawArray:array of point2;
    // ������ 2d ����� ��������������� �� x
    points:cFloatVectorList;
  protected
    procedure createEvents;override;
    procedure DeleteEvents;override;
    // ������������� ������� ������� ����� ��������� ���� �����
    procedure EvalBounds;
    // ���������� ��� ��������� �����
    procedure doSelectPoint(sender:tobject);
    // ���������� ��� ���������� �����
    procedure doAddPoint(sender:tobject);
    // ���������� ��� �������� � ��������
    //procedure doLincParent;override;
    // ���� ����� p ������� �� ������� boundrect �� ����������� boundrect
    procedure updateBound(p:point2);
    // ����������� �������
    procedure changecolor(i:integer;color:point3);
    // ����������� �������
    procedure changePoint(i:integer;p:point2);
    // ������ ������� �������� ������
    procedure evalDrawPoints;
    // ���������� ������� ������ ������. ���������� ��� ���������� ������ ���������� ������
    procedure evalColors;
    // ����� ���������
    procedure drawPoints;
    // ���������� ������� ���������� �����
    procedure drawVectors;
    // ������ ������ �� ����� ������� �������� ��������� ������������ ��������
    procedure DrawVectorPoints;
    procedure drawSpline(const division:integer);
    // ����� ���������
    procedure drawLine;
    // ��������� ������ ���������
    procedure DrawBezie;
    function FindSelectPoint(i:integer;var index:integer):selectpoint;
    // �������� ��� ����� ��������.���� �������� ���������� ������ � ������� selected,
    // ����� ���������� -1
    function CheckSelected(i:integer):integer;
    procedure setflag(flag:cardinal);
    procedure dropflag(flag:cardinal);
    // ���������� ��� ����� ���� �����. Sender - cBeziePoint
    procedure OnChangePointType(sender:tobject);
    // �������� ������� ����� �����
    function GetPointLeftBorder(i:integer):single;
    // �������� ������� ����� ������
    function GetPointRightBorder(i:integer):single;
    // ������� ����� � ��������
    function KeepPointInBorder(p:point2; leftborder,rightborder:single):point2;
    // �������� ���������� ������ ����������
    function GetSpline(left,right:integer):CubicSpline;
    // ����� ���������
    procedure drawdata;override;
    function getdrawpoint:boolean;
    procedure setdrawpoint(b:boolean);
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    constructor create;override;
    destructor destroy;override;
    function GetTypeString:string;override;
    // ����� ������ ����� ����� �� �����
    function GetLowInd(key:single):integer;
    function GetHiInd(key:single):integer;
    function GetLow(key:single):cBeziePoint;
    function GetHi(key:single):cBeziePoint;
    // �������� ��� ����� ����� � ������ �� x
    function GetLoHi(key:single; var index:tpoint):frect;
    function GetLoHi_(key:single; var lp:cbeziepoint;var rp:cbeziepoint; var index:tpoint):frect;
    // ����� ����� �� �����
    function FindPoint(key:single; var index:integer):cpoint;
    // ����� ����� �� �������
    function getPoint(index:integer):cbeziepoint;
    // �������� �����
    procedure AddPoint(p:cBeziePoint);overload;
    procedure AddPoint(p:point2);overload;
    procedure addpoints(p:array of point2);
    // �������� ��� ���������� �����
    procedure changetype;
    // ���������� true ���� ���� ���������� �����
    function smooth:boolean;
    // �������� ������� � ��������; ptype - ��� ���������� ������� (c_point, c_left, c_right)
    function selectVertex(i:integer; ptype:integer):selectpoint;
    procedure deselectAll;
    procedure DeSelectVertex(i:integer; ptype:integer);overload;
    procedure DeSelectVertex(sp:selectpoint);overload;
    procedure DeSelectVertex(index:integer);overload;
    function selectCount:integer;
    function GetSelectPoint(i:integer):selectpoint;
    // �������� i-� ��������� �������
    function GetSelected(i:integer):cBeziePoint;
    // ���������� ����� � ����� ����������
    // i - ������ ����� � ������� ������, t - ��� ������� (c_point, c_left, c_right)
    // newPos - ����� ������� �������
    Procedure setPoint(p:point2; index:selectpoint);
    // ����� y �� ���������� x �� �������
    function GetY(x:single):single;
    // ����� ����������� � ����� x;
    // �������� prec ���������� �������� ��������� ������� �� �������,
    // ����� ��������� ����������� � �����
    function GetTangent(x:single; prec:single):single;
    // ������� �����
    function insertpoint(x:single):cBeziePoint;
    // ����� �����  �������
    function count:integer;
    // �������� ������ �����. dx - ��� � ������� ����� �������� �����
    function getdata(dx:single):pointsarray;
    // ������� �������
    procedure deletepoint(i:integer);
    // �������� ������
    procedure Clear;
  public
    property drawpoint:boolean read getdrawpoint write setdrawpoint;
  end;}

end.
