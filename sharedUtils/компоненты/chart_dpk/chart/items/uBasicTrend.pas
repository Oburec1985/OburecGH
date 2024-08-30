unit uBasicTrend;

interface

uses uPoint, uvectorlist, uCommonTypes, classes, opengl, math, SYSutils,
     uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj, MathFunction,
     uEventList,  types, NativeXML, uChartEvents, uGraphObj, uMyMath,
     dglOpenGl,
     uShader,
     windows,
     uLineLgShader,
     dialogs;

type
  TPrt = record
    // индекс смещени€
    i:cardinal;
    // врем€ смещени€, без учета t0
    t:double;
  end;

  cBasicTrend = class(cGraphObj)
  public
    // id Uniform переменной дл€ логарифмического шейдера по ос€м x,xmax,y,ymax
    //aLocation:integer;
    // id Uniform переменной дл€ логарифмического шейдера lgx, lgy
    //aLocLg:integer;
    // прерывиста€ лини€
    m_LineStripple:boolean;
    // толщина линии
    oldweight:double;
    // цвет вершины
    pointcolor:point3;
    // список отображени€ дл€ точек
    drawPointsCallList:Cardinal;
    // число вершин
    fcount:integer;
    // массив разрывов тренда
    prt:array of TPrt;
  protected
    fNeedRecompile:boolean;
    fweight:double;
    logpointsY:array of single;
    logpointsX:array of single;
    // идентификатор списка отображени€ дл€ логарифмированной линии
    DisplayListName:Cardinal;
    // опции тренда
    settings:cardinal;
  protected
    // процедуры дл€ рисовани€ шейдера логарифмировани€
    procedure SetLgShaderData;
    procedure SwitchLgProg(b:boolean);

    procedure setNeedRecompile(b:boolean);
    procedure setflag(flag:cardinal);
    procedure dropflag(flag:cardinal);
    function getdrawpoint:boolean;
    procedure setdrawpoint(b:boolean);virtual;
    function getDrawLine:boolean;
    procedure setDrawLine(b:boolean);virtual;
    // пересчитывает границы объекта тупым перебором всех точек
    procedure EvalBounds;virtual;
    procedure compile;virtual;
    // если точка p выходит за границу boundrect то обновл€етс€ boundrect
    procedure updateBound(p:point2);
    // рисовать тренд
    procedure drawdata;override;
    // ћетод отрисовки линии дл€ логарифмического масштаба
    procedure drawLineLg;virtual;
    procedure CompileLineLg;virtual;
    procedure CompileLineLgShader;virtual;
    procedure drawLine;virtual;
    // ћетод отрисовки
    procedure drawPoints;virtual;
    procedure endDrawdata;override;
    // расчет отрисовки точек
    procedure evalDrawPointsList;virtual;
    // вызываетс€ при добавлении точки
    procedure doAddPoint(sender:tobject);
    // ћетод отрисовки
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
    procedure OnAxisChangeLg;override;
    procedure setweight(w:double);
  public
    function GetXByInd(i:integer):double;virtual;abstract;
    function GetYByInd(i:integer):double;virtual;abstract;
    function GetY(x:single):single;override;
    // получить значение тренда рисуемого на логарифмической оси
    function GetY_lg(x:single):single;

    function GetLowInd(key:single):integer;virtual;
    function GetHiInd(key:single):integer;virtual;
    // получить вершину логарифмического тренда.
    function getY_log(i:integer):single;
    function Eval_log(min, max, val:single):single;
    function EvalY_log(i:integer):single;
    function EvalX_log(i:integer):single;
    function GetT0:single;virtual;abstract;
    function TestObj(p_p2:point2; dist:single):boolean;override;
    procedure Clear;virtual;abstract;
    procedure addpoints(p:array of point2; p_count:integer);overload;virtual;
    procedure AddPoints(const a:array of single);overload;virtual;
    procedure AddPoints(const a:array of double);overload;virtual;
    procedure AddPoints(const a: array of double; p_count:integer);overload;virtual;
    procedure AddPoints(const a: array of double; start, p_count:integer);overload;virtual;
    function AddPoint(p:point2):tobject;virtual;
    property drawpoint:boolean read getdrawpoint write setdrawpoint;
    property drawLines:boolean read getDrawLine write setDrawLine;
    constructor create;override;
    property weight: double read fweight write setweight;
    property NeedRecompile: boolean read fNeedRecompile write setNeedRecompile;
  end;

  const
    c_drawPoints = $000001;
    c_drawLine = $000002;

implementation
uses
  uChart, upage, uaxis;

procedure cBasicTrend.EvalBounds;
var
  I, lcount: Integer;
  b,B2:boolean;
begin
  lcount:=Count;
  if lcount=0 then exit;
  if not needUpdateBound then exit;

  B2:=FALSE;
  boundrect.BottomLeft:=GetP2(0);
  boundrect.TopRight:=boundrect.BottomLeft;
  for I := 1 to Count - 1 do
  begin
    upage.updateBound(boundrect,GetP2(I),b);
    if B THEN
      B2:=TRUE;
  end;
  if B2 then
  BEGIN
    if events<>nil then
      events.CallAllEventsWithSender(e_onUpdateBound,self);
  END;
end;

procedure cBasicTrend.updateBound(p:point2);
var
  b:boolean;
begin
  if count=1 then
  begin
    boundrect.BottomLeft:=p;
    boundrect.TopRight:=p;
  end
  else
    upage.updateBound(boundrect,p,b);
  if b then
  begin
    if events<>nil then
      events.CallAllEventsWithSender(e_onUpdateBound,self);
  end;
end;

procedure cBasicTrend.compile;
var
  a:caxis;
  p:cpage;
begin
  if NeedRecompile then
  begin
    a:=caxis(parent);
    p:=cpage(getpage);
    if a.lg or p.lgx then
    begin
      if cchart(chart).m_UseShaders then
        CompileLineLgShader
      else
        CompileLineLg;
      if  drawPoint then
      begin
        evalDrawPointsList;
      end;
      NeedRecompile:=false;
    end
    else
    begin
      if  drawPoint then
      begin
        evalDrawPointsList;
      end;
      NeedRecompile:=false;
    end;
  end;
end;

procedure cBasicTrend.CompileLineLgShader;
var
  I: Integer;
  range, lgRange, lgMax, lgMin, y,
  xrange, xlgRange, xlgMin, x,
  rate
  :double;
  p:cpage;
  a:caxis;
  b:bool;
  l_xlgMax:double;
begin
  a:=caxis(parent);
  p:=cpage(getpage);
  if a.max.y<=0 then
  begin
    exit;
  end;

  if DisplayListName<>-1 then
  begin
    glDeleteLists(DisplayListName, 1);
    DisplayListName:=0;
  end;
  // подготовка к компил€ции списка
  DisplayListName:=glGenLists( 1 );
  glNewList(DisplayListName, GL_COMPILE);
  /// шейдерный логарифм
  b:=a.Lg or p.LgX;
  if b then
    SetLgShaderData;
  glbegin(GL_LINE_STRIP);
  for I := 0 to Count - 1 do
  begin
    glVertex2f(GetP2(i).x, GetP2(i).y);
  end;
  glend;
  if b then
    SwitchLgProg(false);
  glEndList;
end;


procedure cBasicTrend.CompileLineLg;
var
  I: Integer;
  range, lgRange, lgMax, lgMin, y,
  xrange, xlgRange, xlgMin, x,
  rate
  :double;
  p:cpage;
  a:caxis;
  l_xlgMax:double;
begin
  a:=caxis(parent);
  p:=cpage(getpage);
  if a.max.y<=0 then
  begin
    exit;
  end;

  if a.Lg then
  begin
    lgMax:=log10(a.max.y);
    if a.min.y<=0 then
    begin
      lgMin:=0.0000000001;
    end
    else
    begin
      lgMin:=log10(a.min.y);
    end;
    lgRange:=lgmax-lgmin;
    range:=a.max.y-a.min.y;
    setlength(logpointsY, count);
    lgrange:=1/lgrange;
  end;
  if p.LgX then
  begin
    l_xlgMax:=log10(a.max.x);
    if a.min.x<=0 then
    begin
      xlgMin:=0.0000000001;
    end
    else
    begin
      xlgMin:=log10(a.min.x);
    end;
    xlgRange:=l_xlgMax-xlgmin;
    xrange:=a.max.x-a.min.x;
    setlength(logpointsX, count);
    xlgrange:=1/xlgrange;
  end;

  if DisplayListName<>-1 then
  begin
    glDeleteLists(DisplayListName, 1);
    DisplayListName:=0;
  end;
  // подготовка к компил€ции списка
  DisplayListName:=glGenLists( 1 );
  glNewList(DisplayListName, GL_COMPILE);
  glbegin(GL_LINE_STRIP);
  for I := 0 to Count - 1 do
  begin
    if a.lg then
    begin
      // такой треш с переносом координат т.к. видова€ матрица от линейной оси
      if GetP2(i).y=0 then
      begin
        rate:=0;
        y:=-200;
      end
      else
      begin
        rate:=(log10(GetP2(i).y)-lgmin)*lgrange; // перевод в относительные единицы от диапаона lg 0..1
        y:=range*rate+a.min.y;
      end;

      if y<-200 then
        y:=-200;
      if i>length(logpointsY)-1 then
      begin
        showmessage(inttostr(length(logpointsY))+'<'+inttostr(i));
      end
      else
      begin
        logpointsY[i]:=y;
      end;
    end
    else
    begin
      y:=GetP2(i).y;
    end;
    if p.lgx then
    begin
      rate:=(log10(GetP2(i).x)-xlgmin)*xlgrange; // перевод в относительные единицы от диапаона 0..1
      if rate<0 then
        rate:=0;
      x:=Xrange*rate+a.min.X;
      logpointsX[i]:=x;
    end
    else
    begin
      x:=GetP2(i).x;
    end;
    glVertex2f(x, y);
  end;
  glend;
  glEndList;
end;

procedure cBasicTrend.drawLine;
var
  a:caxis;
  p:cpage;
begin
  a:=caxis(parent);
  p:=cpage(getpage);

  if a.Lg or p.LgX then
    drawLineLg;
end;

procedure cBasicTrend.drawLineLg;
begin
  glCallList(DisplayListName);
end;

procedure cBasicTrend.drawdata;
var
  w:double;
begin
  inherited;
  if NeedRecompile then
    compile;
  // GL_LINE_WIDTH_RANGE GL_LINE_WIDTH_GRANULARITY
  glGetDoubleV(GL_LINE_WIDTH,@oldweight);
  glLineWidth(weight);
  // установка типа линии (пунктир)
  if m_LineStripple then
  begin
    glLineStipple(1, $F0F0);
    glEnable(GL_LINE_STIPPLE);
  end;
  if drawlines then
  begin
    drawline;
  end;
  if m_LineStripple then
    glDisable(GL_LINE_STIPPLE);
  if drawpoint then
  begin
    glcolor3fv(@pointcolor);
    drawPoints;
  end;
end;

procedure cBasicTrend.endDrawdata;
begin
  inherited;
  glLineWidth(oldweight);
end;

function cBasicTrend.getdrawpoint:boolean;
begin
  result:=checkflag(settings,c_drawPoints);
end;

procedure cBasicTrend.setdrawpoint(b:boolean);
begin
  if b then
    setflag(c_drawPoints)
  else
    dropflag(c_drawPoints);
  NeedRecompile:=true;
end;

function cBasicTrend.getDrawLine:boolean;
begin
  result:=checkflag(settings,c_drawLine);
end;

procedure cBasicTrend.setDrawLine(b:boolean);
begin
  if b then
    setflag(c_drawLine)
  else
    dropflag(c_drawLine);
  NeedRecompile:=true;
end;

procedure cBasicTrend.evalDrawPointsList;
var
  p:point2;
  i:integer;
  y:single;
begin
  if drawPointsCallList<>0 then
    glDeleteLists(drawPointsCallList, 1);
  // подготовка к компил€ции списка
  drawPointsCallList:=glGenLists( 1 );
  glNewList(drawPointsCallList, GL_COMPILE );
  glBegin(GL_Points);
    for I := 0 to Count - 1 do
    begin
      p:=GetP2(i);
      if caxis(parent).lg then
      begin
        // logpointsY[i]
        y:=EvalY_log(i);
        glVertex2f(p.x,y);
      end
      else
        glVertex2f(p.x,p.y);
    end;
  glEnd;
  glEndList;
end;

function cBasicTrend.GetLowInd(key:single):integer;
begin
  showmessage('метод GetLowInd јбстрактный используйте cTrend');
end;

function cBasicTrend.GetHiInd(key:single):integer;
begin
  showmessage('метод GetHiInd јбстрактныйб используйте cTrend');
end;

function cBasicTrend.getY_log(i:integer):single;
begin
  result:=logpointsY[i];
end;

function cBasicTrend.Eval_log(min, max, val:single):single;
var
  lgMax, lgMin, lgRange, range, rate:single;
begin
  lgMax:=log10(max);
  if min<=0 then
  begin
    lgMin:=0.0000000001;
  end
  else
  begin
    lgMin:=log10(min);
  end;
  lgRange:=lgmax-lgmin;
  range:=max-min;
  lgrange:=1/lgrange;

  // такой треш с переносом координат т.к. видова€ матрица от линейной оси
  if val=0 then
  begin
    rate:=0;
    result:=-200;
  end
  else
  begin
    rate:=(log10(val)-lgmin)*lgrange; // перевод в относительные единицы от диапаона lg 0..1
    result:=range*rate+min;
  end;

  if result<-200 then
    result:=-200;
end;

function cBasicTrend.EvalY_log(i:integer):single;
var
  a:cAxis;
  lgMax, lgMin, lgRange, range, rate:single;
begin
  a:=caxis(parent);
  result:=Eval_log(a.minY, a.maxY, GetP2(i).y);
end;

function cBasicTrend.EvalX_log(i:integer):single;
var
  p:cpage;
begin
  p:=cpage(getpage);
  result:=Eval_log(p.MinX, p.maxX, GetP2(i).x);
end;

procedure cBasicTrend.setflag(flag:cardinal);
begin
  uCommonMath.setflag(settings,flag);
end;

procedure cBasicTrend.setNeedRecompile(b: boolean);
begin
  fNeedRecompile:=b;
  needUpdateBound:=true;
end;

procedure cBasicTrend.setweight(w: double);
begin
  fweight:=w;
end;

procedure cBasicTrend.dropflag(flag:cardinal);
begin
  uCommonMath.dropflag(settings,flag);
end;

procedure cBasicTrend.drawPoints;
begin
  glCallList(drawPointsCallList);
end;

constructor cBasicTrend.create;
begin
  Inherited;
  m_LineStripple:=false;
  DisplayListName:=0;
  imageindex:=c_trend_img;
  color:=blue;
  drawLines:=true;
  drawPoint:=false;
  fcount:=0;
end;

function cBasicTrend.GetY(x:single):single;
var
  right,left:integer;
  k:single;
  p1,p2:point2;
begin
  x:=x-position.x;
  if count=0 then
  begin
    result:=0;
    exit;
  end;
  right:=FindHiBound(x,0,count);
  if right=0 then
  begin
    result:=getp2(0).y;
    exit;
  end;
  left:=FindLoBound(x,0,count);
  if left=count-1 then
  begin
    result:=getp2(count-1).y;
    exit;
  end;
  p2:=getp2(right);
  p1:=getp2(left);
  k:=(p2.y-p1.y)/(p2.x-p1.x);
  result:=p1.y+k*(x-p1.x);
end;

function cBasicTrend.GetY_lg(x:single):single;
var
  right,left:integer;
  k:single;
  p1,p2:point2;
begin
  x:=x-position.x;
  if count=0 then
  begin
    result:=0;
    exit;
  end;
  right:=FindHiBound(x,0,count);
  if right=0 then
  begin
    result:=getp2(0).y;
    exit;
  end;
  left:=FindLoBound(x,0,count);
  if left=count-1 then
  begin
    result:=getp2(count-1).y;
    exit;
  end;
  p2:=getp2(right);
  p1:=getp2(left);
  k:=(p2.y-p1.y)/(p2.x-p1.x);
  result:=p1.y+k*(x-p1.x);
end;

procedure cBasicTrend.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
begin
  inherited;
  // габариты
  weight:=xmlNode.ReadAttributeFloat('Weight');
end;

procedure cBasicTrend.SaveObjAttributes(xmlNode:txmlNode);
begin
  inherited;
  xmlNode.WriteAttributeFloat('Weight',weight);
end;

function cBasicTrend.TestObj(p_p2:point2; dist:single):boolean;
var
  i:integer;
  lDist:single;
  lp1,lp2:point2;
begin
  result:=inherited;
  if count>1 then
  begin
    p_p2.x:=p_p2.x-position.x;
    p_p2.y:=p_p2.y-position.y;
    i:=FindLoBound(p_p2.x,0, count);
    lp1:=GetP2(i);
    if i<count-1 then
    begin
      lp2:=GetP2(i+1);
      // не работает дл€ сплайна!!!
      lDist:=GetDistance(lp1,lp2,p_p2);
      if lDist<>-1 then
      begin
        if lDist<dist then
        begin
          result:=true;
        end;
      end;
    end;
  end;
end;

procedure cBasicTrend.addpoints(p:array of point2; p_count:integer);
begin
  if assigned(cchart(chart).onaddpoint) then
    cchart(chart).onaddpoint(self, tobject(@p[0]));
  NeedRecompile:=true;
  EvalBounds;
  cchart(chart).objmng.events.CallAllEventsWithSender(e_onAddPoint+e_onUpdateBound,self);
end;

procedure cBasicTrend.AddPoints(const a:array of single);
begin
  if assigned(cchart(chart).onaddpoint) then
    cchart(chart).onaddpoint(self, tobject(@a[0]));
  NeedRecompile:=true;
  EvalBounds;

  cchart(chart).objmng.events.CallAllEventsWithSender(e_onAddPoint+e_onUpdateBound,self);
end;

procedure cBasicTrend.AddPoints(const a:array of double);
begin
  if assigned(cchart(chart).onaddpoint) then
    cchart(chart).onaddpoint(self, tobject(@a[0]));
  NeedRecompile:=true;
  EvalBounds;

  cchart(chart).objmng.events.CallAllEventsWithSender(e_onAddPoint+e_onUpdateBound,self);
end;

procedure cBasicTrend.doaddpoint(sender:tobject);
var chart:cchart;
begin
  chart:=cchart(cpage(getpage).chart);
  if assigned(chart.onaddpoint) then
    chart.onaddpoint(self, sender);
  chart.objmng.events.CallAllEventsWithSender(e_onAddPoint, self);
end;

function cBasicTrend.AddPoint(p:point2):tobject;
begin
  doaddpoint(tobject(@p));
end;

procedure cBasicTrend.OnAxisChangeLg;
begin
  needrecompile:=true;
  needUpdateBound:=false;
end;


procedure cBasicTrend.addpoints(const a: array of double; p_count: integer);
begin

end;

procedure cBasicTrend.addpoints(const a: array of double; start,
  p_count: integer);
begin

end;

procedure cBasicTrend.SetLgShaderData;
var
  a: caxis;
  p:cpage;
  vertexData: array[0..3] of glfloat;
  glBool: array[0..1] of integer;

  sh:cLineLgShader;
  astr:ansistring;
  ls:lpcstr;

begin
  sh:=cLineLgShader(cchart(chart).m_ShaderMng.getshader(0));
  SwitchLgProg(true);

  a:=caxis(parent);
  p:=cpage(a.parent.parent);
  if a.Lg then
    glbool[1]:=GL_TRUE
  else
    glbool[1]:=GL_false;
  if p.LgX then
    glbool[0]:=GL_TRUE
  else
    glbool[0]:=GL_false;
  glUniform2i(sh.aLocLg, glbool[0], glbool[1]);
  vertexData[0]:=a.min.X;
  vertexData[1]:=a.max.X;
  vertexData[2]:=a.minY;
  vertexData[3]:=a.maxY;
  glUniform4f(sh.aLocation, vertexData[0],vertexData[1],vertexData[2],vertexData[3]);
end;

procedure cBasicTrend.SwitchLgProg(b:boolean);
var
  sh:cshader;
begin
  sh:=cchart(chart).m_ShaderMng.getshader(0);
  if sh<>nil then
    sh.UseProgram(b);
end;

end.
