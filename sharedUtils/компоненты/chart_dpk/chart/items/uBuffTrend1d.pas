unit uBuffTrend1d;

interface

uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
  uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
  uEventList, types, NativeXML, uChartEvents, uBasicTrend, dglopengl;

type
  cBuffTrend1d = class(cBasicTrend)
  public
    datatype: integer;
    // данные
    data_s: array of single;
    data_r: array of double;
    // смещение по X
    fx0: single;
    // емкость
    flength: integer;
    fcapacity:integer;
  protected
    // шаг по оси x между индексированными точками
    fdx: double;
  protected
    // получить установить число вершин
    function GetCount: integer; override;
    procedure SetCount(i: integer); override;
    procedure setcapacity(c:integer);
    // получить вершину по индексу
    function GetP2(i: integer): point2; override;
    procedure setx0(v: single);
    procedure setdx(v: double);
    procedure compile; override;
    procedure drawdata; override;
    // Метод отрисовки
    procedure drawLine; override;
    // пересчитать границы
    procedure EvalBound; override;
    procedure clear; override;
    procedure setvisible(b:boolean);override;
  public
    function GetYByInd(i:integer):double;override;
    function GetXByInd(i:integer):double;override;
    function GetLowInd(key: single): integer; override;
    function GetHiInd(key: single): integer; override;
    constructor create; override;
    // владельцем данных является не тренд!
    procedure AddPoint(v: double; i: integer);
    // фактически не добавление точек а замена!!!
    procedure AddPoints(const a: array of single); override;
    procedure AddPoints(const a: array of double); override;
    // замещает данные в линии
    procedure AddPoints(const a: array of double; p_count:integer); override;
    procedure AddPoints(const a: array of double; start, p_count:integer);override;
    property Count: integer read GetCount write SetCount;
    property x0: single read fx0 write setx0;
    property dx: double read fdx write setdx;
  end;

const
  c_single = 1;
  c_real = 2;

implementation

uses
  upage, uaxis;

function cBuffTrend1d.GetCount: integer;
begin
  result := flength;
end;

function cBuffTrend1d.GetHiInd(key: single): integer;
begin
  key := key - fx0;
  result := trunc(key / fdx);
  if result * fdx > key then
  begin

  end
  else
  begin
    if result * fdx <= key then
    begin
      inc(result);
      if result >= Count then
      begin
        result := Count - 1;
      end;
    end;
  end;
end;

function cBuffTrend1d.GetLowInd(key: single): integer;
begin
  key := key - fx0;
  result := trunc(key / fdx);
  if result * fdx >= key then
  begin
    dec(result);
    if result < 0 then
    begin
      result := 0;
    end;
  end;
end;

procedure cBuffTrend1d.SetCount(i: integer);
begin
  setcapacity(i);
  flength:=i;
end;

procedure cBuffTrend1d.setcapacity(c: integer);
begin
  case datatype of
    c_single:
      Setlength(data_s, c);
    c_real:
      Setlength(data_r, c);
  end;
  fcapacity := c;
end;

function cBuffTrend1d.GetP2(i: integer): point2;
begin
  case datatype of
    c_single:
      result := p2(dx * i + fx0, data_s[i]);
    c_real:
      result := p2(dx * i + fx0, data_r[i]);
  end;
end;

function cBuffTrend1d.GetXByInd(i: integer): double;
begin
  result:=x0+i*dx;
end;

function cBuffTrend1d.GetYByInd(i: integer): double;
begin
  case datatype of
    c_single:
      result:=data_s[i];
    c_real:
    begin
      result:=data_r[i];
    end;
  end;
end;

procedure cBuffTrend1d.compile;
var
  i: integer;
  a: caxis;
  p: cpage;
begin
  if DisplayListName <> -1 then
    glDeleteLists(DisplayListName, 1);
  EvalBound;

  if drawLines then
  begin
    a := caxis(parent);
    p := cpage(getpage);
    if a.Lg or p.LgX then
    begin
      inherited;
    end
    else
    begin
      // подготовка к компиляции списка
      DisplayListName := glGenLists(1);
      glNewList(DisplayListName, GL_COMPILE);
      glLineWidth(weight);
      // drawrect;
      glBegin(GL_LINE_STRIP);
      case datatype of
        c_single:
          for i := 0 to Count - 1 do
          begin
            glVertex2f(i * dx + fx0, data_s[i]);
          end;
        c_real:
          for i := 0 to Count - 1 do
          begin
            glVertex2f(i * dx + fx0, data_r[i]);
          end;
      end;
      glEnd;
      glEndList;
    end;
  end;

  if drawPoint then
  begin
    evalDrawPointsList;
  end;
  needRecompile := false;
end;

procedure cBuffTrend1d.drawLine;
begin
  glCallList(DisplayListName);
end;

procedure cBuffTrend1d.drawdata;
begin
  inherited;
end;

procedure cBuffTrend1d.setx0(v: single);
begin
  fx0 := v;
  needRecompile := true;
end;

procedure cBuffTrend1d.AddPoint(v: double; i: integer);
begin
  case datatype of
    c_single:
      data_s[i] := v;
    c_real:
      data_r[i] := v;
  end;
end;

procedure cBuffTrend1d.AddPoints(const a: array of double);
var
  l: integer;
  i: integer;
begin
  case datatype of
    c_real:
      begin
        if length(a) > fcapacity then
        begin
          fcapacity := length(a);
          Setlength(data_r, fcapacity);
          flength:=fcapacity;
        end;
        move(a[0], data_r[0], flength * sizeof(double));
      end;
  end;
  // оновляем границы тренда
  inherited;
  needRecompile := true;
end;

procedure cBuffTrend1d.AddPoints(const a: array of double; start,  p_count: integer);
var
  l: integer;
  i: integer;
begin
  case datatype of
    c_real:
      begin
        if p_count>0 then
        begin
          if fcapacity < p_count then
          begin
            fcapacity := p_count;
            flength:=p_count;
            Setlength(data_r, fcapacity);
          end;
          move(a[start], data_r[0], p_count * sizeof(double));
        end;
      end;
  end;
  // оновляем границы тренда
  inherited;
  needRecompile := true;
end;


procedure cBuffTrend1d.AddPoints(const a: array of double; p_count:integer);
var
  l: integer;
  i: integer;
begin
  case datatype of
    c_real:
      begin
        if length(data_r) < p_count then
        begin
          flength := p_count;
          Setlength(data_r, p_count);
        end;
        // sorce; dst; sizze
        move(a[0], data_r[0], p_count * sizeof(double));
      end;
  end;
  // оновляем границы тренда
  inherited;
  needRecompile := true;
end;

procedure cBuffTrend1d.AddPoints(const a: array of single);
var
  l: integer;
  i: integer;
begin
  case datatype of
    c_single:
      begin
        if length(a) > flength then
        begin
          flength := length(a);
          Setlength(data_s, flength);
        end;
        move(a[0], data_s[0], flength * sizeof(single));
      end;
    c_real:
      begin
        if length(a) > flength then
        begin
          flength := length(a);
          Setlength(data_r, flength);
        end;
        move(a[0], data_r[0], flength * sizeof(double));
      end;
  end;
  // бновляем границы тренда
  inherited;
  needRecompile := true;
end;

procedure cBuffTrend1d.EvalBound;
var
  l: integer;
  i: integer;
begin
  if Count = 0 then
    exit;
  if not needUpdateBound then exit;

  boundrect.BottomLeft.x := x0;
  l := Count;
  boundrect.TopRight.x := x0 + (l - 1) * dx;
  case datatype of
    c_single:
      begin
        boundrect.BottomLeft.y := data_s[0];
        boundrect.TopRight.y := data_s[0];
        for i := 0 to Count - 1 do
        begin
          if data_s[i] > boundrect.TopRight.y then
          begin
            boundrect.TopRight.y := data_s[i];
          end
          else
          begin
            if data_s[i] < boundrect.BottomLeft.y then
              boundrect.BottomLeft.y := data_s[i];
          end;
        end;
      end;
    c_real:
      begin
        boundrect.BottomLeft.y := data_r[0];
        boundrect.TopRight.y := data_r[0];
        for i := 0 to Count - 1 do
        begin
          if data_r[i] > boundrect.TopRight.y then
          begin
            boundrect.TopRight.y := data_r[i];
          end
          else
          begin
            if data_r[i] < boundrect.BottomLeft.y then
              boundrect.BottomLeft.y := data_r[i];
          end;
        end;
      end;
  end;
end;

procedure cBuffTrend1d.setdx(v: double);
begin
  needRecompile := true;
  fdx := v;
end;

procedure cBuffTrend1d.setvisible(b: boolean);
begin
  inherited;
  if b then
    compile;
end;

constructor cBuffTrend1d.create;
begin
  inherited;
  datatype := c_real;
  boundrect.BottomLeft := p2(0, 0);
  boundrect.TopRight := p2(0, 0);
end;


procedure cBuffTrend1d.clear;
begin
  needRecompile := true;
  Count := 0;
end;

end.
