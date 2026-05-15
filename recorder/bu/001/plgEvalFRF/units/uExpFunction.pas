unit uExpFunction;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, math, opengl,
  Forms, ComCtrls,
  uCommonTypes,
  uDrawObj, uAxis, uPage, uDoubleCursor, uBasicTrend, uProfile, uExcel;

type

  cExpFuncObj = class(cMoveObj)
  public
    // 0 - точка в которой экс. ф-€=1,
    // x1 - точка в которой нормируетс€ значение экспоненты
    // y1 - значение экспоненты дл€ x1 (например 0,1 шкалы)
    m_x0, m_x1, m_y1: double;
    // событие при обновлении координат
    fUpdateParams: TNotifyEvent;
  protected
    // координаты дл€ отрисовки
    fy0, fy1, fdy, fdy005, faxmin: double;
    // константа дл€ градуировки точки x1 y1
    // exp(-fA*x1)=y1
    fA: double;
    // 0 - не прошел тест 1- точка 0, 2 - точка 1
    fTestObj: integer;
  public
    m_DisplayListName: Cardinal;
    m_needRecompile: boolean;
    m_weight: single;
    m_count: integer;
    // true - sres/taho
  protected
    function TestObj(p_p2: point2; dist: single): boolean; override;
    // пересчитать границы
    procedure EvalBound; override;
    procedure EvalA;
    procedure compile;
    procedure drawdata; override;
    procedure SetPos(p: point2); override;
    function GetPos: point2; override;
    procedure doOnUpdateParams;
  public
    // происходит когда обновилс€ масштаб оси объекта
    procedure doUpdateWorldSize(sender: tobject); override;
  public
    procedure SetParams(x0, x1, y1: double);
    function getScale(x: double): double;
    constructor create; override;
    destructor destroy; override;
  end;

implementation


{ cExpFuncObj }
procedure cExpFuncObj.compile;
var
  a: caxis;
  p: cpage;
  i: integer;
  isize: tpoint;
  bsize: point2;
  x, dx, xmax, y: single;
begin
  if m_needRecompile then
  begin
    a := caxis(parent);
    p := cpage(GetPage);
    if a.lg or p.lgX then
    begin
      // CompileLineLg;
    end
    else
    begin
      a := caxis(parent);
      p := cpage(GetPage);
      if a.lg or p.lgX then
      begin
        inherited;
      end
      else
      begin
        EvalBound;
        EvalA;
        // подготовка к компил€ции списка
        if m_DisplayListName <> 0 then
        begin
          glDeleteLists(m_DisplayListName, 1);
          m_DisplayListName := 0;
        end;
        m_DisplayListName := glGenLists(1);
        glNewList(m_DisplayListName, GL_COMPILE);
        glLineWidth(m_weight);
        xmax := a.max.x;
        // марке на x0y0
        dx := (xmax - m_x0) / m_count;
        i := 0;
        // x := i * dx - m_x0;
        x := i * dx;
        glBegin(GL_LINE_STRIP);
        glVertex2f((x + m_x0), fdy * system.exp(-x * fA) + faxmin);
        for i := 1 to m_count - 1 do
        begin
          x := x + dx;
          glVertex2f((x + m_x0), fdy * system.exp(-x * fA) + faxmin);
        end;
        glEnd;
        // отрисовка ползунка
        isize.x := 15;
        isize.y := 15;
        bsize := p.PixelSizeToTrend(isize, a);
        bsize.x := bsize.x * 0.5;
        bsize.y := bsize.y * 0.5;
        y := fy0; // - fdy005;
        glBegin(GL_LINE_STRIP);
        glVertex2f(m_x0 - bsize.x, y - bsize.y);
        glVertex2f(m_x0 - bsize.x, y + bsize.y);
        glVertex2f(m_x0 + bsize.x, y + bsize.y);
        glVertex2f(m_x0 + bsize.x, y - bsize.y);
        glVertex2f(m_x0 - bsize.x, y - bsize.y);
        glEnd;
        // марке на x1y1
        y := fy1; // + fdy005;
        glBegin(GL_LINE_STRIP);
        glVertex2f(m_x1 - bsize.x, y - bsize.y);
        glVertex2f(m_x1 - bsize.x, y + bsize.y);
        glVertex2f(m_x1 + bsize.x, y + bsize.y);
        glVertex2f(m_x1 + bsize.x, y - bsize.y);
        glVertex2f(m_x1 - bsize.x, y - bsize.y);
        glEnd;
        glEndList;
        // p.Caption:=floattostr(fy1);
      end;
    end;
    m_needRecompile := false;
  end;
end;

constructor cExpFuncObj.create;
begin
  inherited;
  Color := orange;
  m_count := 200;
  fA := 1;
  m_x0 := 0;
  m_x1 := 1;
  m_weight := 1;
  m_needRecompile := true;
  m_DisplayListName := 0;
  EvalA;
  EvalBound;
  locked := false;
end;

destructor cExpFuncObj.destroy;
begin
  inherited;
end;

procedure cExpFuncObj.doOnUpdateParams;
begin
  if assigned(fUpdateParams) then
    fUpdateParams(self);
end;

procedure cExpFuncObj.doUpdateWorldSize(sender: tobject);
var
  p: cpage;
  a: caxis;
begin
  inherited;
  p := cpage(GetPage);
  a := caxis(parent);
  if a = sender then
  begin
    faxmin := a.minY;
    fdy := a.maxY - a.minY;
    fdy005 := 0.05 * fdy;
    fy0 := a.maxY;
    fy1 := fdy * m_y1 + faxmin;

    m_needRecompile := true;
  end;
end;

procedure cExpFuncObj.drawdata;
var
  oldweight: single;
begin
  inherited;
  if m_needRecompile then
    compile;
  // GL_LINE_WIDTH_RANGE GL_LINE_WIDTH_GRANULARITY
  // glGetDoubleV(GL_LINE_WIDTH,@oldweight);
  glLineWidth(m_weight);
  glCallList(m_DisplayListName);
  // glLineWidth(oldweight);
end;

procedure cExpFuncObj.EvalA;
var
  lnx: double;
begin
  if m_y1 < 0.000001 then
    lnx := -10
  else
    lnx := ln(m_y1);
  // константа дл€ градуировки точки x1 y1
  // exp(-fA*x1)=y1
  fA := -lnx / (m_x1 - m_x0);
end;

procedure cExpFuncObj.EvalBound;
var
  a: caxis;
  p: cpage;
begin
  a := caxis(parent);
  p := cpage(GetPage);

  boundrect.BottomLeft.x := m_x0;
  boundrect.TopRight.x := m_x1;
  boundrect.BottomLeft.y := fy1;
  boundrect.TopRight.y := fy0;
end;

function cExpFuncObj.getScale(x: double): double;
begin
  // (x+m_x0), ymax*system.Exp(-x * fA)
  result := system.exp(-(x - m_x0) * fA);
end;

procedure cExpFuncObj.SetParams(x0, x1, y1: double);
begin
  m_x0 := x0;
  m_x1 := x1;
  m_y1 := m_y1;
  EvalA;
  EvalBound;
  m_needRecompile := true;
end;

function cExpFuncObj.GetPos: point2;
begin
  case fTestObj of
    0:
      ;
    1:
      begin
        result.x := m_x0;
        result.y := fy0;
      end;
    2:
      begin
        result.x := m_x1;
        result.y := m_y1 * fdy + faxmin;
      end;
  end;
end;

procedure cExpFuncObj.SetPos(p: point2);
begin
  case fTestObj of
    0:
      ;
    1:
      begin
        m_x0 := p.x;
      end;
    2:
      begin
        m_x1 := p.x;
        if fdy = 0 then
          m_y1 := 0
        else
        begin
          if p.y < faxmin then
            p.y := faxmin;
          m_y1 := (p.y - faxmin) / fdy;
        end;
        fy1 := fdy * m_y1 + faxmin;
      end;
  end;
  doOnUpdateParams;
  m_needRecompile := true;
end;

function cExpFuncObj.TestObj(p_p2: point2; dist: single): boolean;
var
  i: integer;
  lDist: single;
  lp2: point2;
  page: cpage;
begin
  result := false;
  page := cpage(GetPage);
  fTestObj := 0;

  lp2.x := p_p2.x - m_x1;
  lp2.y := p_p2.y - fy1;
  lDist := sqrt(lp2.x * lp2.x + lp2.y * lp2.y);
  dist := dist * 2;
  // page.Caption:=floattostr(p_p2.x)+' '+floattostr(p_p2.y);
  if lDist < dist then
  begin
    // page.Caption:='test 2';
    fTestObj := 2;
    result := true;
    exit;
  end;

  lp2.x := p_p2.x - m_x0;
  lp2.y := p_p2.y - fy0;
  lDist := sqrt(lp2.x * lp2.x + lp2.y * lp2.y);
  if lDist < dist then
  begin
    // page.Caption:='test 1';
    fTestObj := 1;
    result := true;
  end;
end;

end.
