unit uPoint;

interface
uses uCommonTypes, classes;

type

  TPType = (ptNullPoly, ptlinePoly, ptCubePoly);
  TChangePState = (stCubeToLine, stCubeToNull,
                   stLineToCube, stLineToNull,
                   stNullToLine, stNullToCube, stNone);

  cPoint = class
  public
    // кординаты точки
    point:point2;
  protected
    procedure setx(p_x:single);
    function getx:single;
    procedure sety(p_y:single);
    function gety:single;
  public
    property x:single read getx write setx;
    property y:single read gety write sety;
    constructor create(p_x,p_y:single); overload;virtual;
    constructor create; overload; virtual;
  end;

  cBeziePoint=class(cPoint)
  protected
    // тип точки: 0 - corner, 1 - smooth, 2 - c_0_poly (нулевая интерполяция)
    ftype:TPType;
  public
    m_changeState:TChangePState;
    // происходит при смене типа
    fOnChangeType:tNotifyEvent;
    left,right:point2;
    UniqIndex:integer;
    // индекс вершины внутри drawArray для cTrend
    Index:integer;
  protected
    function getType:boolean;
    procedure setType(v:boolean);
    procedure setNullPoly(b:boolean);
    function getNullPoly:boolean;
    procedure setPType(t:TPType);
  public
    constructor create; override;
    property smooth:boolean read gettype write settype;
    property NullPoly:boolean read getNullPoly write setNullPoly;
    property PType:TPType read ftype write setPType;
  end;

  const
    c_corner = ptlinePoly;
    c_smooth = ptCubePoly;
    c_0_poly = ptNullPoly;

implementation

constructor cpoint.create;
begin
  point.x:=0;
  point.y:=0;
end;

constructor cpoint.create(p_x,p_y:single);
begin
  create;
  point.x:=p_x;
  point.y:=p_y;
end;

procedure cpoint.setx(p_x:single);
begin
  point.x:=p_x;
end;

function cpoint.getx:single;
begin
  result:=point.x;
end;

procedure cpoint.sety(p_y:single);
begin
  point.y:=p_y;
end;

function cpoint.gety:single;
begin
  result:=point.y;
end;

function cBeziePoint.getNullPoly: boolean;
begin
  result:=ftype=c_0_poly;
end;

function cBeziePoint.getType: boolean;
begin
  result:=ftype=c_smooth;
end;

procedure cBeziePoint.setNullPoly(b:boolean);
begin
  if b then
    PType:=c_0_poly
  else
    PType:=c_corner;
  if assigned(fOnChangeType) then
    fOnChangeType(self);
end;

procedure cBeziePoint.setPType(t: TPType);
begin
  case ftype of
    ptNullPoly:
    begin
      case t of
        ptNullPoly: m_changeState:=stNone;
        ptlinePoly: m_changeState:=stNullToLine;
        ptCubePoly: m_changeState:=stNullToCube;
      end;
    end;
    ptLinePoly:
    begin
      case t of
        ptNullPoly: m_changeState:=stLineToNull;
        ptlinePoly: m_changeState:=stNone;
        ptCubePoly: m_changeState:=stLineToCube;
      end;
    end;
    ptCubePoly:
    begin
      case t of
        ptNullPoly: m_changeState:=stCubeToNull;
        ptlinePoly: m_changeState:=stCubeToLine;
        ptCubePoly: m_changeState:=stNone;
      end;
    end;
  end;
  ftype:=t;
  if assigned(fOnChangeType) then
    fOnChangeType(self);
end;

procedure cBeziePoint.setType(v:boolean);
begin
  if v then
    PType:=c_smooth
  else
  begin
    PType:=c_corner;
  end;
  if assigned(fOnChangeType) then
    fOnChangeType(self);
end;

constructor cBeziePoint.create;
begin
  inherited;
  ftype:=c_corner;
  left.x:=0; left.y:=0;
  right.x:=0; right.y:=0;
end;

end.
