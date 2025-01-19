unit uProfile;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  math,
  uHardwareMath, MathFunction,
  Forms, ComCtrls,
  uComponentServises,
  uChart,
  inifiles,
  upage,
  complex,
  uBuffTrend1d,
  uCommonMath,
  uCommonTypes, uPoint,
  pluginClass,
  shellapi,
  uPathMng,
  uExcel,
  uListMath,
  uSpm, uBaseAlg,
  opengl, uSimpleObjects,
  uAxis, uDrawObj, uDoubleCursor, uBasicTrend, uTrend,
  Dialogs;

type
  // тип расчета
  tunits = (tuPercent, // ref*((100+v)/100);
            // ref*(Power(10,v/10));
            tuLg10,
            // ref*(Power(10,v/20));
            tuLg20,
            // ref+prof
            tuAbs,
            // значение равно ref
            tuVals);

  TProfPoint = record
    p:point2d;
    t:TPType;
  end;

  cProfile = class;

  // зависимая к профилю линия. при изменении профиля меняется и
  // линия
  cProfileLine = class
  public
    // false - срабатывает если значение ниже/ true - если выше
    m_LineType:boolean;
    m_ref:double;
    m_data:array of double;
    m_owner:cprofile;
    // каждой линии может принадлежать несколько трендов
    m_lines:tlist;
    name:string;
  protected
    // обновить точки всех трендов
    procedure updatepoints;
    procedure reEvalPoints;
    // обновить point
    procedure EvalP(p: double; i:integer);overload;
    // вычислить точку основе единиц измерения,
    // значения v и относительного уровня ref
    function EvalP(v:double):double;overload;
    // расчитать точку с номером i
    procedure updatePoint(i:integer);
    // сразу вызывает reEvalPoints
    procedure setRef(v:double);
  public
    // преобразовать параметры в строку
    function toStr:string;
    // строку в параметры
    procedure fromStr(s:string; var start:integer);
    procedure clear;
    // добавить линию профиля на страницу
    procedure addline(c:cchart; p:cpage; ax:caxis);
    property Ref:double read m_ref write setref;
    constructor create(owner:cprofile);
    destructor destroy;
  end;

  // профиль определяет линии которые к нему прилинкованы
  // если меняется профиль меняется и дочерний ряд (h,hh,l,ll)
  cProfile = class
  protected
    m_capacity, m_size:integer;
  public
    m_LineUnits:tunits;
    // номер сработавшей уставки
    m_NumLine: integer;
    // x,y,t
    m_data:array of TProfPoint;
    // список cProfileLine
    childs:tlist;
  protected
    procedure setsize(s:integer);
    function getsize:integer;
    procedure exclude(l:cProfileLine);
    procedure addline(l:cProfileLine);
  public
    // update - обновить дочерние линии
    procedure AddP(x,y:double; t:TPType; update:boolean);
    function toStr:string;
    procedure fromStr(s: string; var start:integer);
    // очистить
    procedure clear;
    // обновить точки всех дочерних линий
    procedure UpdatePoints;
    property size:integer read getsize write setsize;
    constructor create;
    destructor destroy;
  end;

  function IntToTUnits(i:integer):tunits;

implementation

function IntToTUnits(i:integer):tunits;
begin
  case i of
    0:result:=tuPercent;
    1:result:=tuLg10;
    2:result:=tuLg20;
    3:result:=tuAbs;
    4:result:=tuVals;
  end;
end;

{ cProfile }
procedure cProfile.addline(l: cProfileLine);
var
  I: Integer;
  b:boolean;
begin
  b:=false;
  for I := 0 to childs.Count - 1 do
  begin
    if childs.items[i]=l then
    begin
      b:=true;
      break;
    end;
  end;
  if not b then
  begin
    childs.Add(l);
  end;
end;

procedure cProfile.AddP(x, y: double; t: TPType; update: boolean);
var
  p:TProfPoint;
begin
  p.p.x:=x;
  p.p.y:=y;
  p.t:=t;
  if m_size=m_capacity then
  begin
    m_capacity:=m_size+10;
    SetLength(m_data,m_capacity);
  end;
  m_data[m_size]:=p;
  Inc(m_size);
  if update then
    UpdatePoints;
end;

procedure cProfile.clear;
var
  I: Integer;
  ch:cProfileLine;
begin
  size:=0;
  for I := 0 to childs.Count - 1 do
  begin
    ch:=cProfileLine(childs.Items[i]);
    ch.clear;
  end;
end;

constructor cProfile.create;
begin
  m_capacity:=100;
  SetLength(m_data, m_capacity);
  childs:=TList.Create;
end;

destructor cProfile.destroy;
begin
  childs.Destroy;
end;

procedure cProfile.exclude(l: cProfileLine);
var
  I: Integer;
begin
  for I := 0 to childs.Count - 1 do
  begin
    if childs.Items[i]=l then
    begin
      childs.Delete(i);
      exit;
    end;
  end;
end;

function cProfile.getsize: integer;
var
  I: Integer;
begin
  result:=m_size;
end;

procedure cProfile.setsize(s: integer);
var
  i:integer;
  ch:cProfileLine;
begin
  m_size:=s;
  if s>m_capacity then
  begin
    m_capacity:=s;
    setlength(m_data, s);
  end;
  for I := 0 to childs.Count - 1 do
  begin
    ch:=cProfileLine(childs.Items[i]);
    setlength(ch.m_data, s);
  end;
end;

// pCount;x1;y1;t1;...xn;yn;tn;ChildCount;LineType; LineUnits; ;
function cProfile.toStr: string;
var
  I: Integer;
  p:TProfPoint;
  l:cProfileLine;
begin
  result:=inttostr(size);
  for I := 0 to size - 1 do
  begin
    result:=result+';';
    p:=m_data[i];
    result:=result+p2toStr(p.p, 4)+';'+PTypeToStr(p.t);
  end;
  result:=result+';'+inttostr(childs.Count);
  for I := 0 to childs.Count - 1 do
  begin
    result:=result+';';
    l:=cProfileLine(childs.Items[i]);
    result:=result+l.toStr;
  end;
end;

procedure cProfile.fromStr(s: string; var start:integer);
var
  ls:string;
  i, j,c:integer;
  p:TProfPoint;
  line:cProfileLine;
begin
  ls:=GetSubString(s, ';',start,i);
  size:=strtoint(ls);
  for I := 0 to size - 1 do
  begin
    ls:=GetSubString(s, ';',i+1,i);
    p.p.x:=StrTofloatext(ls);
    ls:=GetSubString(s, ';',i+1,i);
    p.p.y:=StrTofloatext(ls);
    ls:=GetSubString(s, ';',i+1,i);
    p.t:=StrToPType(ls);
  end;
  ls:=GetSubString(s, ';',i+1,i);
  j:=i+1;
  c:=strtoint(ls);
  for I := 0 to c - 1 do
  begin
    line:=cProfileLine.create(self);
    line.fromStr(s, j);
    inc(j);
  end;
end;

procedure cProfile.UpdatePoints;
var
  I, j: Integer;
  ch:cProfileLine;
begin
  for I := 0 to childs.Count - 1 do
  begin
    ch:=cProfileLine(childs.Items[i]);
    // пересчитываем точки линии
    ch.reEvalPoints;
    // пересчитываем тренды
    ch.updatepoints;
  end;
end;

{ cProfileLine }
procedure cProfileLine.addline(c: cchart; p: cpage; ax: caxis);
var
  I: Integer;
  tr:ctrend;
  b:boolean;
begin
  b:=false;
  for I := 0 to ax.childCount - 1 do
  begin
    if ax.getChild(i) is ctrend then
    begin
      tr:=ctrend(ax.getChild(i));
      if tr.m_data=self then
      begin
        b:=true;
        break;
      end;
    end;
  end;
  if not b then
  begin
    tr:=ax.AddTrend;
    tr.m_data:=self;
    m_lines.Add(tr);
  end;
end;

procedure cProfileLine.clear;
var
  I: Integer;
  tr:ctrend;
begin
  setlength(m_data, 0);
  for I := 0 to m_lines.Count - 1 do
  begin
    tr:=ctrend(m_lines.Items[i]);
    tr.Clear;
  end;
end;

constructor cProfileLine.create(owner: cprofile);
begin
  m_owner:=owner;
  m_owner.addline(self);
  m_Lines:=tlist.Create;
end;

destructor cProfileLine.destroy;
var
  I: Integer;
  tr:ctrend;
begin
  m_owner.exclude(self);
  for I := 0 to m_Lines.Count - 1 do
  begin
    tr:=ctrend(m_Lines.Items[i]);
    tr.destroy;
  end;
  m_Lines.Destroy;
end;

function cProfileLine.EvalP(v: double): double;
begin
  case m_owner.m_LineUnits of
    tuPercent:
    begin
      result:=m_ref*((100+v)/100);
    end;
    tuLg20: //20log
    begin
      result:=m_ref*(Power(10,v/20));
    end;
    tuLg10:  //10log
    begin
      result:=m_ref*(Power(10,v/10));
    end;
    tuAbs:  //10log
    begin
      result:=m_ref+v;
    end;
    tuVals:
    begin
      result:=v;
    end;
  end;
end;


procedure cProfileLine.reEvalPoints;
var
  j:integer;
begin
  for j := 0 to m_owner.size - 1 do
  begin
    evalp( m_owner.m_data[j].p.y, j);
  end;
end;

procedure cProfileLine.setRef(v: double);
begin
  m_ref:=v;
  reEvalPoints;
end;

function cProfileLine.toStr: string;
begin
  if m_LineType then
    result:='1;'
  else
    result:='0;';
  case m_owner.m_LineUnits of
    tuPercent:result:=result+'0;';
    tuLg10:result:=result+'1;';
    tuLg20:result:=result+'2;';
    tuAbs:result:=result+'3;';
    tuVals:result:=result+'4;';
  end;
  result:=result+floattostr(m_ref);
end;

procedure cProfileLine.fromStr(s: string; var start:integer);
var
  ls:string;
  i,j:integer;
begin
  ls:=GetSubString(s, ';',start,i);
  if ls='1' then
    m_LineType:=true
  else
    m_LineType:=false;
  ls:=GetSubString(s, ';',i+1,i);
  j:=StrToInt(ls[1]);
  case j of
    0:m_owner.m_LineUnits:=tuPercent;
    1:m_owner.m_LineUnits:=tuLg10;
    2:m_owner.m_LineUnits:=tuLg20;
    3:m_owner.m_LineUnits:=tuAbs;
    4:m_owner.m_LineUnits:=tuVals;
  end;
  ls:=GetSubString(s, ';',i+1,i);
  m_ref:=strtofloat(ls);
  start:=i+1;
end;


procedure cProfileLine.EvalP(p: double; i: integer);
begin
  m_data[i]:=EvalP(p);
end;

procedure cProfileLine.updatepoint(i: integer);
var
  tr:ctrend;
  p:cbeziepoint;
begin
  for I := 0 to m_lines.Count - 1 do
  begin
    tr:=ctrend(m_lines.items[i]);
    p:=tr.getPoint(i);
    p.PType:=m_owner.m_data[i].t;
    p.point.x:=m_owner.m_data[i].p.x;
    p.point.y:=m_data[i];
    tr.NeedRecompile:=true;
  end;
end;

procedure cProfileLine.updatepoints;
var
  I, j: Integer;
  tr:ctrend;
  p:cbeziepoint;
begin
  for I := 0 to m_lines.Count - 1 do
  begin
    tr:=ctrend(m_lines.items[i]);
    if tr.count<>length(m_data) then
    begin
      tr.Clear;
      for j := 0 to length(m_data) - 1 do
      begin
        p:=cBeziePoint.create;
        p.PType:=m_owner.m_data[j].t;
        p.point.x:=m_owner.m_data[j].p.x;
        p.point.y:=m_data[i];
        tr.AddPoint(p);
      end;
    end
    else
      begin
      for j := 0 to length(m_data) - 1 do
      begin
        p:=tr.getPoint(i);
        p.PType:=m_owner.m_data[j].t;
        p.point.x:=m_owner.m_data[j].p.x;
        p.point.y:=m_data[j];
      end;
    end;
    tr.NeedRecompile:=true;
  end;
end;

end.
