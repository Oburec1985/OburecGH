unit uBuffTrend1d;

interface

uses
  windows, dialogs,
  uPoint, uvectorlist, uCommonTypes, classes, opengl,
  uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj, uLineLgShader, ushader,
  uEventList, types, NativeXML, uChartEvents, uBasicTrend, dglopengl;

type
  cBuffTrend1d = class(cBasicTrend)
  public
    m_compileThread: integer;
    m_useSh1d: boolean;
    m_useLists: boolean;
    datatype: integer;
    // данные
    data_s: array of single;
    data_r: array of double;
    m_LinePar: point2d;
    // смещение по X
    fx0: single;
    // емкость
    flength: integer;
    fcapacity: integer;
  protected
    // шаг по оси x между индексированными точками
    fdx: double;
  protected
    procedure SetLgShaderData; override;
    procedure BindVBA(sh: cshader);
    procedure compile; override;
    // получить установить число вершин
    function GetCount: integer; override;
    procedure SetCount(i: integer); override;
    procedure setcapacity(c: integer);
    // получить вершину по индексу
    function GetP2(i: integer): point2; override;
    procedure setx0(v: single);
    procedure setdx(v: double);
    procedure drawdata; override;
    // Метод отрисовки
    procedure drawLine; override;
    // пересчитать границы
    procedure EvalBound; override;
    procedure clear; override;
    procedure setvisible(b: boolean); override;
  public
    function getshader: cshader;
    function GetYByInd(i: integer): double; override;
    function GetXByInd(i: integer): double; override;
    function GetLowInd(key: single): integer; override;
    function GetHiInd(key: single): integer; override;
    constructor create; override;
    // владельцем данных является не тренд!
    procedure AddPoint(v: double; i: integer);
    // фактически не добавление точек а замена!!!
    procedure AddPoints(const a: array of single); override;
    procedure AddPoints(const a: array of double); override;
    // замещает данные в линии
    procedure AddPoints(const a: array of double; p_count: integer); override;
    // dropOld - отбрасывать старые данные если их было больше чем добавлено
    procedure AddPoints(const a: array of double; start, p_count: integer);
      override;
    property Count: integer read GetCount write SetCount;
    property x0: single read fx0 write setx0;
    property dx: double read fdx write setdx;
  end;

const
  c_useShader1d = true;
  c_single = 1;
  c_real = 2;

implementation

uses
  uchart, upage, uaxis;

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
  flength := i;
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
  result := x0 + i * dx;
end;

function cBuffTrend1d.GetYByInd(i: integer): double;
var
  l: integer;
begin
  case datatype of
    c_single:
      begin
        l := length(data_s);
        if i < l then
          result := data_s[i]
        else
          result := data_s[l - 1]
      end;
    c_real:
      begin
        l := length(data_r);
        if i < l then
          result := data_r[i]
        else
          result := data_r[l - 1]
      end;
  end;
end;

function cBuffTrend1d.getshader: cshader;
begin
  result := nil;
  if m_useSh1d then
  begin
    if chart <> nil then
    begin
      if cchart(chart).m_ShaderMng.m_shaders.Count > 1 then
        result := cLineLgShader1d(cchart(chart).m_ShaderMng.getshader(1));
    end;
  end;
end;

procedure cBuffTrend1d.compile;
var
  i: integer;
  id: cardinal;
  a: caxis;
  p: cpage;
  sh: cshader;
begin
  if chart = nil then
    exit;
  if not cchart(chart).initgl then
    exit;
  //needRecompile := false;
  EvalBound;
  if not m_useSh1d then
    sh:=nil
  else
    sh := getshader;
  if sh <> nil then
  begin
    //if flength > 0 then
    //  BindVBA(sh);
  end
  else
  begin
    if drawLines then
    begin
      a := caxis(parent);
      p := cpage(getpage);
      id := GetCurrentThreadId;
      if m_compileThread = 0 then
        m_compileThread := id;
      if m_compileThread <> id then
        showmessage('GetCurrentThreadId');
      if a.Lg or p.LgX then
      begin
        inherited;
      end
      else
      begin
        if DisplayListName <> 0 then
        begin
          glDeleteLists(DisplayListName, 1);
          DisplayListName := 0;
        end;
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
  end;

  if drawPoint then
  begin
    evalDrawPointsList;
  end;
  needRecompile := false;
end;

procedure cBuffTrend1d.BindVBA(sh: cshader);
begin
  // готовим VAO для отрисовки
  // связка с аттрибутами вершин
  //ProcDrawSelectRect;  // перенесено в uChart
  if length(data_r)>0 then
  begin
    glBindVertexArray(cLineLgShader1d(sh).m_VAO);
    // загрузка данных
    glBindBuffer(gl_array_buffer, cLineLgShader1d(sh).m_VBO);
    glBufferData(gl_array_buffer, flength * SizeOf(double), @data_r[0], GL_STATIC_DRAW);
    // 0 - вершинные данные; 1 - 1 элемент на вершину (только Y) ; 0 - т.к. берем из видео карты;
    // nil - тоже
    glVertexAttribPointer(0, 1, GL_DOUBLE, false, 0, 0);
    // включаем использование для вершинного буфера VAO (0)
    glEnableVertexAttribArray(0);
    // glBindVertexArray(cLineLgShader1d(sh).m_VAO);
  end;
end;

procedure cBuffTrend1d.SetLgShaderData;
var
  a: caxis;
  p: cpage;
  vertexData: array [0 .. 3] of glfloat;
  glBool: array [0 .. 1] of integer;
  sh: cLineLgShader1d;
  astr: ansistring;
  ls: lpcstr;
begin
  sh := cLineLgShader1d(getshader);
  if sh = nil then
  begin
    inherited;
    exit;
  end;
  a := caxis(parent);
  p := cpage(a.parent.parent);
  if flength = 0 then
    exit;
  if a.Lg then
    glBool[1] := GL_TRUE
  else
    glBool[1] := GL_false;
  if p.LgX then
    glBool[0] := GL_TRUE
  else
    glBool[0] := GL_false;
  // перебинд массива VBA при каждом рисовании. Если не перебиндивать надо
  // в каждом тренде свой VBA


  //glDisableClientState(GL_VERTEX_ARRAY);
  //glDisableClientState(GL_Color_ARRAY);
  //glBindBuffer(GL_ARRAY_buffer,0);
  BindVBA(sh);
  // включаем перед загрузкой параметров
  glUseProgramObjectARB(sh.m_program);
  glUniform2i(sh.aLocLg, glBool[0], glBool[1]);
  vertexData[0] := a.min.X;
  vertexData[1] := a.max.X;
  vertexData[2] := a.minY;
  vertexData[3] := a.maxY;
  //
  glUniform4f(sh.aLocation, vertexData[0], vertexData[1], vertexData[2],
    vertexData[3]);
  m_LinePar.X := fx0;
  m_LinePar.y := dx;
  //
  glUniform2f(sh.aLocLineParams, m_LinePar.X, m_LinePar.y);

  glBindVertexArray(sh.m_VAO);
  glDrawArrays(GL_LINE_STRIP, 0, flength);
  glBindVertexArray(0); // если не делать падает
  glBindBuffer(gl_array_buffer, 0); // если не делать не рисует сетку
  glUseProgramObjectARB(0);
end;

procedure cBuffTrend1d.drawLine;
var
  sh: cshader;
begin
  sh := getshader;
  if sh <> nil then
  begin
    SetLgShaderData;
  end
  else
  begin
    glCallList(DisplayListName);
  end;
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
          flength := fcapacity;
        end;
        move(a[0], data_r[0], flength * SizeOf(double));
      end;
  end;
  // оновляем границы тренда
  inherited;
  needRecompile := true;
end;

procedure cBuffTrend1d.AddPoints(const a: array of double;
  start, p_count: integer);
var
  l: integer;
  i: integer;
begin
  case datatype of
    c_real:
      begin
        if p_count > 0 then
        begin
          if fcapacity < p_count then
          begin
            fcapacity := p_count;
            flength := p_count;
            Setlength(data_r, fcapacity);
          end
          else
          begin
            flength := p_count;
          end;
          move(a[start], data_r[0], p_count * SizeOf(double));
        end;
      end;
  end;
  // оновляем границы тренда
  inherited;
  needRecompile := true;
end;

procedure cBuffTrend1d.AddPoints(const a: array of double; p_count: integer);
var
  l: integer;
  i: integer;
begin
  case datatype of
    c_real:
      begin
        flength := p_count;
        if length(data_r) < p_count then
        begin
          Setlength(data_r, p_count);
        end;
        // sorce; dst; sizze
        move(a[0], data_r[0], p_count * SizeOf(double));
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
        move(a[0], data_s[0], flength * SizeOf(single));
      end;
    c_real:
      begin
        if length(a) > flength then
        begin
          flength := length(a);
          Setlength(data_r, flength);
        end;
        move(a[0], data_r[0], flength * SizeOf(double));
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
  if not needUpdateBound then
    exit;

  boundrect.BottomLeft.X := x0;
  l := Count;
  if count=0 then
  begin
    boundrect.BottomLeft.X:=0;
    boundrect.TopRight.X:=0;
    boundrect.BottomLeft.y:=1;
    boundrect.TopRight.y:=1;
  end;
  boundrect.TopRight.X := x0 + (l - 1) * dx;
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
  m_useSh1d:=c_useShader1d;
  m_useLists := true;
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
