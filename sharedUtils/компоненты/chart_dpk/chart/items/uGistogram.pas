unit uGistogram;

interface
uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
     uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
     uEventList, uMarkers, types, dialogs, uGraphObj;

type
  cGistogram = class;

  cGistogramItem = class
  protected
    // ссылка на родительскую гистограмму
    parentgistogram:cGistogram;
    // индекс гистограммы
    key:integer;
    // //высота столбца
    fvalue:single;
  protected
    procedure setvalue(v:single);
  public
    property value:single read fvalue write setvalue;
    function getX:single;
    //procedure draw;
  end;

  cGistogram = class(cGraphObj)
  public
    // нулевое смещение по x
    Offset:Single;
    // ссылки на отрисовываемые столбцы
    Items:cIntVectorList;
    // производиться изменение данных гистограммы. Нельзя читать и писать
  protected
    // размер отрисовываемых объектов в пикселях
    fsize:point2;
    // размер отрисовываемых объектов в пикселях
    pix_fsize:tpoint;
    fDrawType:integer;
    // ширина столбца гистограммы
    fWidth:single;
    // отрисовывать маркеры
    fDrawMarkers:boolean;
    // необходимо обновить список отображения
    NeedRecompile:Boolean;
    // идентификатор списка отображения
    DisplayListName:Cardinal;
  protected
    procedure doUpdateMarkerY(sender:tobject);
    procedure createEvents;override;
    procedure DeleteEvents;override;
    procedure compile;
    function getGist(i:integer):cGistogramItem;
    procedure setdrawmarkers(b:boolean);
    procedure drawCollumns;
    procedure drawRect;
    procedure setdrawType(t:integer);
    procedure setPixSize(s:tpoint);
    procedure updateYSize;
    function getcount:integer;override;
    //procedure testdraw;
  public
    constructor create;override;
    destructor destroy;override;
    procedure drawdata;override;
    function getp2(i:integer):point2;override;
    function GetTypeString:string;override;
    procedure clear;
    procedure fupdatebound;override;
    function findGistByKey(i:integer):cGistogramItem;
    function findGistByPosition(pos:single):cGistogramItem;
    // добавить столбец i - не индекс а ключ
    procedure add(i:integer);overload;
    procedure add(v:single);overload;
    procedure add(key:integer; val:single);overload;
    procedure add(v:single; val:single);overload;
    // добавить значение val к гистограмме i или в позиции v
    procedure addValue(i:integer; val:single);overload;
    procedure addValue(v:single; val:single);overload;
    // установить значение в столбец i - не индекс а ключ
    procedure SetValue(i:integer; val:single);overload;
    procedure SetValue(v:single; val:single);overload;
    // поделить все стобцы на v
    procedure devide(v:single);
    // число столбцов
    function getMarkers:cMarkerList;
    procedure setWidth(w:single);
    function GetY(x:single):single;override;
  public
    property size:tpoint read pix_fsize write setPixSize;
    property DrawType:integer read fDrawType write SetDrawType;
    property width:single read fwidth write setwidth;
    property drawMarkers:boolean read fdrawmarkers write setdrawmarkers;
  end;

  const

    c_Collumn = 1;
    c_Rect = 2;

implementation
uses uchart ,uPage, uChartEvents, uAxis;

function getpage(gistogram:cGistogram):cpage;
begin
  result:=cpage(gistogram.parent.parent.parent);
end;

constructor cGistogram.create;
begin
  inherited;
  color:=black;
  items:=cintvectorlist.create;
  items.destroydata:=true;
  width:=0.1;
  Offset:=0;
  pix_fSize:=point(10,10);
  DisplayListName:=0;
  fDrawType:=c_Collumn;
  drawMarkers:=true;
end;

destructor cGistogram.destroy;
begin
  clear;
  items.destroy;
  inherited;
end;

function cGistogram.GetCount:integer;
begin
  result:=items.Count;
end;

procedure cGistogram.clear;
var
  m:cMarkerList;
  i:integer;
  gist:cgistogramitem;
begin
  items.destroydata:=false;
  for i:= 0 to items.Count - 1 do
  begin
    gist:=getGist(i);
    gist.Destroy;
  end;
  items.clear;
  items.destroydata:=true;
  m:=getMarkers;
  m.clear;
  glDeleteLists(DisplayListName, 1);
end;

function cGistogram.GetY(x:single):single;
var
  i, ind:integer;
  gist:cgistogramitem;
begin
  x:=x-position.x;
  i:=trunc(x/width);
  items.findObj(@i,ind);
  if (ind=-1) then
  begin
    result:=0;
  end
  else
  begin
    gist:=getgist(ind);
    result:=gist.value;
  end;
end;

procedure cGistogram.devide(v:single);
var
  item:cGistogramItem;
  i:integer;
begin
  for I := 0 to count  - 1 do
  begin
    item:=getgist(i);
    item.value:=item.value/v;
  end;
end;

function cGistogram.findGistByKey(i:integer):cGistogramItem;
var
  item:cGistogramItem;
  ind:integer;
begin
  items.findObj(@i,ind);
  result:=getgist(ind);
end;

function cGistogram.findGistByPosition(pos:single):cGistogramItem;
var
  i:integer;
begin
  i:=trunc(pos/width);
  result:=findGistByKey(i);
end;

procedure cGistogram.SetValue(i:integer; val:single);
var
  item:cGistogramItem;
  ind:integer;
begin
  //e-ntercs;
    items.findObj(@i,ind);
    if (ind=-1) then
    begin
      add(i,val);
    end
    else
    begin
      item:=getgist(ind);
      item.value:=val;
    end;
  //e-xitcs;
end;

procedure cGistogram.SetValue(v:single; val:single);
var
  i:integer;
begin
  i:=trunc(v/width);
  SetValue(i,val);
end;

procedure cGistogram.addValue(i:integer; val:single);
var
  item:cGistogramItem;
  ind:integer;
begin
  items.findObj(@i,ind);
  if (ind=-1) then
  begin
    add(i,val);
  end
  else
  begin
    item:=getgist(ind);
    item.value:=item.value+val;
  end;
end;

procedure cGistogram.addValue(v:single; val:single);
var i:integer;
begin
  i:=trunc(v/width);
  addValue(i,val);
end;

procedure cGistogram.add(v:single; val:single);
var i:integer;
begin
  i:=trunc(v/width);
  add(i,val);
end;

procedure cGistogram.add(key:integer; val:single);
var
  item:cGistogramItem;
  ind:integer;
begin
  items.findObj(@key,ind);
  if (ind<>-1) then
  begin
    item:=getGist(ind);
    item.value:=val;
  end
  else
  begin
    item:=cGistogramItem.Create;
    item.parentgistogram:=self;
    item.key:=key;
    item.value:=val;
    items.AddObject(@item.key,item);
    needRecompile:=true;
  end;
end;

procedure cGistogram.add(i:integer);
var
  item:cGistogramItem;
  ind:integer;
begin
  items.findObj(@i,ind);
  if (ind<>-1) then
  begin
    exit;
  end
  else
  begin
    item:=cGistogramItem.Create;
    item.parentgistogram:=self;
    item.key:=i;
    item.value:=0;
    items.AddObject(@item.key,item);
    needRecompile:=true;
  end;
end;

procedure cGistogram.add(v:single);
var
  key:integer;
begin
  key:=trunc(v/width);
  add(key);
end;

function cGistogram.getGist(i:integer):cGistogramItem;
begin
  result:=cGistogramItem(items.getObj(i));
end;

procedure cGistogram.compile;
begin
  //e-ntercs;
    updatebound;
    if needRecompile then
    begin
      if DisplayListName<>0 then
        glDeleteLists(DisplayListName, 1);
      // подготовка к компиляции списка
      DisplayListName:=glGenLists( 1 );
      glNewList(DisplayListName, GL_COMPILE );
      case drawType of
        c_Collumn:drawCollumns;
        c_rect:drawRect;
      end;
      glEndList;
    end;
    needRecompile:=false;
  //e-xitcs;
end;

procedure cGistogram.setdrawtype(t:integer);
begin
  if fdrawtype<>t then
  begin
    fdrawtype:=t;
    NeedRecompile:=true;
  end;
end;

procedure cGistogram.drawRect;
var
  w,h:single;
  i:integer;
  gist:cgistogramitem;
begin
  w:=width/2;
  h:=fsize.y/2;
  for I := 0 to items.Count - 1 do
  begin
    gist:=getGist(i);
    // отрисовка
    glbegin(gl_quads);
    glvertex2f(gist.getX-w,gist.value-h);
    glvertex2f(gist.getX-w,gist.value+h);
    glvertex2f((gist.getX)+w,gist.value+h);
    glvertex2f((gist.getX)+w,gist.value-h);
    glend;
  end;
end;

procedure cGistogram.drawCollumns;
var
  w:single;
  i:integer;
  gist:cgistogramitem;
begin
  w:=width/2;
  for I := 0 to items.Count - 1 do
  begin
    gist:=getGist(i);
    // отрисовка
    glbegin(gl_quads);
    glvertex2f(gist.getX-w,0);
    glvertex2f(gist.getX-w,gist.value);
    glvertex2f((gist.getX)+w,gist.value);
    glvertex2f((gist.getX)+w,0);
    glend;
  end;
end;

procedure cGistogram.drawdata;
begin
  compile;
  glColor3fv(@color);
  glCallList(DisplayListName);
end;

procedure cGistogram.fupdatebound;
var
  gist:cGistogramItem;
  min:point2;
  max:point2;
  i:integer;
  b:boolean;
  rect:frect;
begin
  if NeedUpdateBound then
  begin
    NeedUpdateBound:=false;
    for I := 0 to items.Count - 1 do
    begin
      gist:=getGist(i);
      if (i=0) then
      begin
        boundrect.BottomLeft.x:=gist.getX;
        boundrect.BottomLeft.y:=gist.fvalue;
        boundrect.TopRight:=boundrect.BottomLeft;
      end;
      upage.updateBound(boundrect,p2(gist.getX,gist.fvalue),b);
      if b then
      begin
        events.CallAllEventsWithSender(e_onUpdateBound, self);
      end;
    end;
    rect:=getallbound;
    upage.updateBound(boundrect,rect.BottomLeft,b);
    upage.updateBound(boundrect,rect.TopRight,b);
  end;
end;

procedure cGistogramItem.setvalue(v:single);
begin
  fvalue:=v;
  parentgistogram.NeedUpdateBound:=true;
end;

function cGistogramItem.getX:single;
begin
  result:=key*parentgistogram.width - parentgistogram.offset;
end;

function cGistogram.GetTypeString:string;
begin
  result:='Гистограмма';
end;

procedure cGistogram.setdrawmarkers(b:boolean);
var
  m:cmarkerlist;
begin
  if (b=true) and (fDrawMarkers=false) then
  begin
    m:=cMarkerList.create;
    m.autocreate:=true;
    m.pixelsize:=point(3,10);
    m.size.x:=Width;
    AddChild(m);
  end
  else
  begin
    m:=getMarkers;
    if m<>nil then
      m.destroy;
  end;
  fDrawMarkers:=b;
end;

function cGistogram.getMarkers:cMarkerList;
begin
  result:=cMarkerlist(getchild(0));
end;

procedure cGistogram.createEvents;
begin
  events.AddEvent('GistUpdateY', E_OnZoom, doUpdateMarkerY);
end;

procedure cGistogram.DeleteEvents;
begin
  events.removeEvent(doUpdateMarkerY, E_OnZoom, self);
  inherited;
end;

procedure cGistogram.updateYSize;
var
  p:cpage;
  s:point2;
begin
  p:=cpage(getpage);
  if p<>nil then
  begin
    s:=p.PixelSizeToTrend(pix_fsize, cAxis(parent));
    fsize.y:=s.y;
    NeedRecompile:=true;
  end;
end;

procedure cGistogram.doUpdateMarkerY(sender:tobject);
var
  m:cmarkerlist;
begin
  m:=getMarkers;
  if m<>nil then
  begin
    m.updateYSize;
  end;
  updateYSize;
end;

procedure cGistogram.setWidth(w:single);
var
  m:cmarkerlist;
begin
  fwidth:=w;
  m:=getMarkers;
  if m<>nil then
  begin
    m.size.x:=w;
  end;
end;

procedure cGistogram.setPixSize(s:tpoint);
begin
  pix_fsize:=s;
  fsize:=getsize(s);
  needrecompile:=true;
end;

function cGistogram.getp2(i:integer):point2;
var
  g:cGistogramItem;
begin
  g:=getGist(i);
  result:=p2(g.getX,g.fvalue);
end;

end.

