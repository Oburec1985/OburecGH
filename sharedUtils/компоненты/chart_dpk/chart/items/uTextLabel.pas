// текстовая метка, предназначена для подписей на страницах
unit uTextLabel;

interface

uses ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, types,
     sysutils, math, uCommonMath, u2DMath, stdctrls, forms, controls, uText, uEventList,
     uChartEvents, classes, dialogs, uGistogram, mathfunction, uSimpleObjects;

type

  cTextLabel = class(cMoveObj)
  protected
    fTransperentBckGnd:boolean;
    fAutoWidth:boolean;
    falign:integer;
    // отображаемый текст
    ftext:string;
    // размер в пикселях рамки
    fPixSize:tpoint;
    //fontmng настройки шрифта
    font:cFont;
    fdrawBorder:boolean;
    // точка в которую идет сноска от метки
    fline:point2;
    fdrawline:boolean;
  public
    data:pointer;
    m_bckGndColor:point3;
    m_borderColor:point3;
  protected
    procedure fupdatebound;override;
    // происходит при линковке к родителю
    procedure doLincParent;override;
    // управление размером рамки в пикселях
    procedure SetPixSize(p:tpoint);
    function GetPixSize:tpoint;
    // управление отображаемым тестом
    procedure SetText(str:string);
    procedure SetDrawBorder(b:boolean);
    // управление выравниванием текста
    procedure SetAlign(al:integer);
    procedure setTransperentBckGnd(b:boolean);
    // управление выравниванием текста
    procedure SetAutoWidth(b:boolean);
    // пересчитывает пиксельные размеры рамки в мировые
    procedure UpdateWorldSize;
    procedure DeleteEvents;Override;
    procedure CreateEvents;override;
    procedure setLine(p2:point2);
    procedure setDrawLine(b:boolean);
    procedure doDrawLine;
  protected
    procedure doOnUpdateAxis(sender:tobject);
  public
    constructor create;
    destructor destroy;override;
    procedure drawdata;override;
    // управление положением метки
    function GetTypeString:string;override;
    procedure setFont(p_font:cfont);
    procedure SetPos(p:point2);override;
  public
    property pixSize:tpoint read getPixSize write setPixSize;
    property text:string read ftext write setText;
    property align:integer read fAlign write setAlign;
    property autoWidth:boolean read fAutoWidth write SetAutoWidth;
    property TransperentBckGnd:boolean read fTransperentBckGnd write setTransperentBckGnd;
    property DrawBorder:boolean read fdrawBorder write setDrawBorder;
    property line:point2 read fline write setline;
    property drawline:boolean read fdrawline write setDrawLine;
 end;


implementation
uses uchart ,uPage, uAxis;




procedure cTextLabel.setFont(p_font:cfont);
begin
  font:=p_font;
end;

procedure cTextLabel.setLine(p2: point2);
begin
  fline:=p2;
end;

procedure cTextLabel.setDrawLine(b: boolean);
begin
  fDrawline:=b;
end;

constructor cTextLabel.create;
begin
  inherited create;
  fdrawline:=false;
  fTransperentBckGnd:=false;
  fdrawBorder:=true;
  fAutoWidth:=false;
  align:=c_centr;
  pixSize:=point(20,20);
  fpos:=p2(0,0);
  m_bckGndColor:=white;
  color:=black;
  m_borderColor:=gray;
end;

destructor cTextLabel.destroy;
begin
  DestroyEvents;
  inherited;
end;


procedure cTextLabel.doLincParent;
var
  page:cpage;
begin
  page:=cpage(getpage);
  if page<>nil then
    setfont(getfont(c_AxisFontInd));
  inherited;
  UpdateWorldSize;
  if text='' then
    text:=name;
end;

procedure cTextLabel.doDrawLine;
var
  intersect:point2;
  r:fRect;
  curcolor:point3;
begin
  r:=boundrect;
  intersect:=EvalIntersect(r.BottomLeft,r.TopRight,
                           p2(r.BottomLeft.x,r.TopRight.y),
                           p2(r.TopRight.x,r.BottomLeft.y));
  glGetFloatv(GL_CURRENT_COLOR,@curcolor);
  glcolor3fv(@black);
  // отрисовка полигона
  glBegin(GL_LINES);
    glvertex2fv(@fline);
    glvertex2fv(@intersect);
  glend;
  glBegin(GL_POINTS);
    glvertex2fv(@fline);
  glend;
  glcolor3fv(@curcolor);
end;


procedure cTextLabel.drawdata;
begin
  //compile;
  glColor3fv(@color);
  if drawline then
  begin
    doDrawLine;
  end;
  if not fTransperentBckGnd then
  begin
    drawrect(boundrect, m_bckGndColor);
  end;
  if DrawBorder then
  begin
   uSimpleObjects.drawBorder(boundrect, m_borderColor);
  end;
  font.OutText(ftext, Position, falign);
  //glCallList(DisplayListName);
end;

function cTextLabel.GetTypeString:string;
begin
  result:='Текст';
end;

procedure cTextLabel.fupdatebound;
var
  I: Integer;
  b:boolean;
begin
  inherited;
  //for I := 0 to items.Count - 1 do
  //begin
  //  uPage.updateBound(boundrect,m.pos,b);
  //  needUpdateBound:=false;
  //end;
end;

procedure cTextLabel.UpdateWorldSize;
var
  p2:point2;
begin
  if parent<>nil then
  begin
    p2 := GetSize(pixSize);
    boundrect.BottomLeft.x:=position.x - p2.x/2;
    boundrect.TopRight.x:=position.x + p2.x/2;
    boundrect.BottomLeft.y:=position.y - p2.y/2;
    boundrect.TopRight.y:=position.y + p2.y/2;
  end;
end;

procedure cTextLabel.SetPixSize(p:tpoint);
var
  a:caxis;
begin
  fpixsize:=p;
  UpdateWorldSize;
end;

function cTextLabel.GetPixSize:tpoint;
begin
  result:=fpixsize;
end;

procedure cTextLabel.SetText(str:string);
var
  w,h:integer;
  p:tpoint;
begin
  ftext:=str;
  if font<>nil then
  begin
    w:=font.getPixelWidth(str);
    if fAutoWidth then
    begin
      p:=point(w,pixSize.y);
      pixSize:=p;
    end
    else
    begin
      if pixSize.X<w then
      begin
        p:=point(w,pixSize.y);
        pixSize:=p;
      end;
    end;
  end;
end;

procedure cTextLabel.setTransperentBckGnd(b:boolean);
begin
  fTransperentBckGnd:=b;
end;

procedure cTextLabel.SetAlign(al:integer);
begin
  falign:=al;
end;

procedure cTextLabel.SetAutoWidth(b:boolean);
begin
  fAutoWidth:=b;
end;

procedure cTextLabel.DeleteEvents;
begin
  events.removeEvent(doOnUpdateAxis, e_onResize+E_OnZoom);
  inherited;
end;

procedure cTextLabel.CreateEvents;
begin
  //events.AddEvent('trendAddpoint', e_onAddpoint, doaddpoint);
  events.AddEvent(name+'_OnUpadeteTextLabelBound', e_onResize+E_OnZoom, doOnUpdateAxis);
end;

procedure cTextLabel.doOnUpdateAxis(sender:tobject);
begin
  UpdateWorldSize;
end;

procedure cTextLabel.SetPos(p:point2);
begin
  // закоментил от 06.09.18 т.к. все вычисления для етки работают на основе позиции и не используют нод
  //inherited;
  fpos := p;
  UpdateWorldSize;
end;

procedure cTextLabel.SetDrawBorder(b:boolean);
begin
  fdrawBorder:=b;
end;

end.
