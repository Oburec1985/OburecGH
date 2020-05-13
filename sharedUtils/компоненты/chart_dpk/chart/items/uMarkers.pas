unit uMarkers;

interface
uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
     uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
     uEventList, types, dialogs, math;

type
  cMarkerList = class;

  cMarker = class
  protected
    // ссылка на родительскую гистограмму
    parentMarkerList:cMarkerList;
    pos:point2;
  protected
  end;

  cMarkerList = class(cdrawobj)
  public
    // список значений y при логарифмической оси
    logpointsY:array of single;
    // размер в координатах окна
    size:point2;
    // ссылки на отрисовываемые столбцы
    Items:cfloatvectorlist;
  protected
    // идентификатор списка отображения
    DisplayListName:Cardinal;
    // необходимо обновить список отображения
    NeedRecompile:Boolean;
    // тип отрисовки маркера
    fmarkertype:integer;
    // размер маркера в пикселях
    fpixelSize:tpoint;
  protected
    procedure fupdatebound;override;
    procedure createevents;override;
    procedure DeleteEvents;override;
    procedure compile;
    // установить тип отрисовки маркеров
    procedure setMarkerType(t:integer);
    procedure drawrect;
    procedure getSize(pixSize:tpoint);
    procedure GetPixSize(p:tpoint);
    procedure doUpdateSize(sender:tobject);
    procedure CompileMarkersLg;
    //procedure testdraw;
  public
    constructor create;override;
    destructor destroy;override;
    procedure drawdata;override;
    function GetTypeString:string;override;
    procedure clear;
    function AddMarker(p2:point2):cmarker;
    function GetMarker(i:integer):cmarker;
    // установить значение в столбец i - не индекс а ключ
    function count:integer;
    // пересчитать пиксельные размеры маркера по Y в координаты тренда
    procedure updateYSize;
    procedure updateSize;
  public
    property MarkerType:integer read fmarkertype write setmarkertype;
    property pixelsize:tpoint read fpixelsize write GetPixSize;
  end;

  const
    c_rectMarker = 1;
    c_BoundRectMarker = 2;
    c_EmptyRectMarker = 3;
    c_pointMarker = 4;


implementation
uses uchart ,uPage, uChartEvents, uAxis;

function getpage(mlist:cMarkerList):cpage;
begin
  result:=cpage(mlist.GetParentByClassName('cPage'));
end;

constructor cMarkerList.create;
begin
  inherited;
  size.y:=-1;
  color:=red;
  items:=cfloatvectorlist.create;
  items.destroydata:=true;
  DisplayListName:=0;
  fmarkertype:=c_rectMarker;
  pixelsize:=point(6,6);
end;

destructor cMarkerList.destroy;
begin
  clear;
  items.destroy;
  inherited;
end;

procedure cMarkerList.clear;
begin
  items.clear;
end;

procedure cMarkerList.CompileMarkersLg;
var
  I: Integer;
  range, lgRange, lgMax, lgMin, yLg:single;
  w,h:single;
  m:cmarker;
begin
  if caxis(parent).max.y<=0 then
  begin
    exit;
  end;
  if size.y=-1 then
  begin
    updateYSize;
  end;
  w:=size.x/2;
  h:=size.y/2;

  lgMax:=log10(caxis(parent).max.y);
  if caxis(parent).min.y<=0 then
  begin
    lgMin:=0.0000000001;
  end
  else
  begin
    lgMin:=log10(caxis(parent).min.y);
  end;
  lgRange:=lgmax-lgmin;
  range:=caxis(parent).max.y-caxis(parent).min.y;
  if DisplayListName<>-1 then
    glDeleteLists(DisplayListName, 1);
  lgrange:=1/lgrange;
  setlength(logpointsY,count);
  for I := 0 to Count - 1 do
  begin
    m:=cmarker(items.getObj(i));
    ylg:=range*(log10(m.pos.y)-lgmin)*lgrange;
    logpointsY[i]:=ylg;
    // отрисовка
    glbegin(gl_quads);
    glvertex2f(m.pos.x-w, yLg-h);
    glvertex2f(m.pos.x-w, yLg+h);
    glvertex2f(m.pos.x+w, yLg+h);
    glvertex2f(m.pos.x+w, yLg-h);
    glend;
  end;
end;

procedure cMarkerList.drawrect;
var
  I: Integer;
  m:cmarker;
  w,h:single;
begin
  if size.y=-1 then
  begin
    updateYSize;
  end;
  w:=size.x/2;
  h:=size.y/2;
  for I := 0 to items.Count - 1 do
  begin
    m:=cmarker(items.getObj(i));
    // отрисовка
    glbegin(gl_quads);
    glvertex2f(m.pos.x-w,m.pos.y-h);
    glvertex2f(m.pos.x-w,m.pos.y+h);
    glvertex2f(m.pos.x+w,m.pos.y+h);
    glvertex2f(m.pos.x+w,m.pos.y-h);
    glend;
  end;
end;

procedure cMarkerList.compile;
var
  i:integer;
  m:cmarker;
begin
  if needRecompile then
  begin
    if DisplayListName<>-1 then
      glDeleteLists(DisplayListName, 1);
    // подготовка к компиляции списка
    DisplayListName:=glGenLists( 1 );
    glNewList(DisplayListName, GL_COMPILE );
    if  caxis(parent).lg then
    begin
      CompileMarkersLg;
    end
    else
    begin
      case MarkerType of
        c_rectMarker:drawrect;
        c_BoundRectMarker:;
        c_EmptyRectMarker:;
        c_pointMarker:;
      end;
    end;
    glEndList;
  end;
  needRecompile:=false;
end;

procedure cMarkerList.drawdata;
begin
  compile;
  glColor3fv(@color);
  //drawrect;
  glCallList(DisplayListName);
end;

function cMarkerList.count:integer;
begin
  result:=items.Count;
end;

function cMarkerList.GetTypeString:string;
begin
  result:='Маркеры';
end;

function cMarkerList.AddMarker(p2:point2):cmarker;
var
  m:cmarker;
  b:boolean;
begin
  m:=cmarker.Create;
  m.parentMarkerList:=self;
  m.pos:=p2;
  Items.AddObject(@m.pos.x,m);
  NeedRecompile:=true;
  uPage.updateBound(boundrect,m.pos,b);
end;

function cMarkerList.GetMarker(i:integer):cmarker;
var
  m:cmarker;
begin
  if i<items.Count then
    result:=cmarker(items.getObj(i))
  else
    result:=nil;
end;

procedure cMarkerList.setMarkerType(t:integer);
begin
  if fmarkertype<>t then
  begin
    fmarkertype:=t;
    NeedRecompile:=true;
  end;
end;

procedure cMarkerList.getSize(pixSize:tpoint);
var
  p:cpage;
begin
  p:=cpage(getpage);
  pixelsize:=pixsize;
  size:=p.PixelSizeToTrend(pixSize,caxis(parent.parent));
end;

procedure cMarkerList.updateYSize;
var
  p:cpage;
  s:point2;
  axis:caxis;
begin
  p:=cpage(getpage);
  if p<>nil then
  begin
    axis:=caxis(GetParentByClassName('cAxis'));
    s:=p.PixelSizeToTrend(pixelsize, axis);
    size.y:=s.y;
    NeedRecompile:=true;
  end;
end;

procedure cMarkerList.updateSize;
var
  p:cpage;
  s:point2;
  axis:caxis;
begin
  p:=cpage(getpage);
  if p<>nil then
  begin
    axis:=caxis(GetParentByClassName('cAxis'));
    s:=p.PixelSizeToTrend(pixelsize, axis);
    size.y:=s.y;
    size.x:=s.x;
    NeedRecompile:=true;
  end;
end;

procedure cMarkerList.GetPixSize(p:tpoint);
begin
  fpixelSize:=p;
  updateYSize;
  needrecompile:=true;
end;

procedure cMarkerList.doUpdateSize(sender:tobject);
begin
  updateSize;
end;

procedure cMarkerList.createEvents;
begin
  // e_onResize+E_OnZoom
  events.AddEvent('trendSelectPoint', e_OnChangeAxisScale, doUpdateSize);
  inherited;
end;

procedure cMarkerList.DeleteEvents;
begin
  events.removeEvent(doUpdateSize, e_OnChangeAxisScale);
  inherited;
end;

procedure cMarkerList.fupdatebound;
var
  I: Integer;
  m:cmarker;
  b:boolean;
begin
  for I := 0 to items.Count - 1 do
  begin
    m:=cmarker(items.getObj(i));
    uPage.updateBound(boundrect,m.pos,b);
    needUpdateBound:=false;
  end;
end;

end.

