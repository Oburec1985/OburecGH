unit uGrid;

interface

uses
  Controls, windows, ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, classes,
  uAxis, messages, utext, sysutils, uEventList, uSetList, uFrameListener,
  mathfunction, uChartEvents, uPoint, dialogs, types, forms,
  uDoubleCursor, usimpleobjects, NativeXML, uBasePage, Clipbrd;

type

  cBase = class;
  cColumn = class;
  cRaw = class;

  cScrollBar = class(cMoveObj)
  public
    displaylist:cardinal;
    visible:boolean;
    // вертикальный/горизонтальный
    Vertical: boolean;
    borderColor:point3;
    posColor:point3;
    frame:cframelistener;
  protected
    m_iWidth: integer;
    m_fWidth: single;
    BtnWidth:single;
  protected
    procedure CompileScrollBar;
    procedure linc(p_chart: tcomponent); override;
    procedure drawdata;override;
    procedure DrawPos;
    procedure drawButton;
    procedure fupdatebound; override;
    procedure DoOnClick(p:point2);override;
    procedure DoOnMouseMove(p:point2);override;
    procedure DoOnMouseMove(p:tpoint);overload;
    procedure DoOnMouseLeave;override;
    function TestObj(p2:point2; dist:single):boolean;override;
    procedure SetiWidth(w: integer);
  public
    constructor create;override;
    property width: integer read m_iWidth write SetiWidth;
  end;

  cGrid = class(cBasePage)
  public
    columns: cSetList;
    raws: cSetList;
    // смещение по X таблицы
    fpixOffset:integer;
  protected
    // тащим колонку
    dragColumn:integer;
    ownername:integer;
    scrollBoxH, scrollBoxV:cScrollBar;

    Tab: tpoint;
    DisplayListName: cardinal;
    fFontIndex: integer;
    // высота строк
    m_iRawHeigth: integer;
    m_fRawHeigth,
    // координаты крайней справа линии ограничивающей колонку
    MaximumWidth: single;


    fColumnTextColor: point3;
    fLinesColor: point3;
    HeaderColor:point3;

    // видимые строки
    rawcount,
    firstRaw,
    // первая видимая колонка
    firstColumn:integer;
    // высота вьюпорта колонки
    fColumnViewportHeigth:integer;
    // высота строки в вюпорте колонки
    m_fRawHeigthColViewport: single;
  protected
    // происходит при добавлении колонки ш - индекс колонки
    procedure UpdateRaws(i: integer);
    procedure SetFontIndex(fIndex: integer);
    procedure SetRawHeigth(H: integer);
    procedure UpdateScrollBars;
    // получить колонку по координатам мыши
    function getColumnHeader(p:tpoint):integer;
    procedure DoClick(i_p:tpoint;f_p:point2);override;
    procedure DoButtonUp(i_p:tpoint;f_p:point2);override;
    procedure DoMouseMove(i_p:tpoint;f_p:point2);override;
    procedure doOnExit;override;
    procedure setBound(rect: trect); override;
    procedure linc(p_chart: tcomponent); override;
    procedure DrawData; override;
    // отрисовка колонок
    procedure DrawColumns;
    procedure DrawRaws;
    procedure compile;
    // компилит отрисовку линий - шапка и вертикальные линии колонок
    procedure CompileColumns;
    // пересчитать параметр viewport для всех колонок
    procedure EvalColumnSizes;
    procedure SetPixOffset(p:integer);
    // получить сумарную ширину всех колонок
    function GetGridWidth:integer;
  public
    constructor create; override;
    destructor destroy; override;
    Function GetRaw(i: integer): cRaw;
    Function GetCol(i: integer): cColumn;
    function AddColumn(p_name: string): cColumn;
    function AddRaw: cRaw;
    // делает полную инициализацию строк. Очищает все строки и заполняет пустыми ячейками
    // в соответствии с числом столбцов
    procedure initRaws;
  public
    property FontIndex: integer read fFontIndex write SetFontIndex;
    property RawHeigth: integer read m_iRawHeigth write SetRawHeigth;
    property pixOffset: integer read fPixOffset write SetPixOffset;
  end;

  cBase = class
  protected
    grid: cGrid;
    fName: string;
    fIndex: integer;
  protected
    procedure SetName(s: string); virtual;
    procedure SetIndex(i: integer);
  public
    constructor create; virtual;
    property name: string read fName write SetName;
    property Index: integer read fIndex write SetIndex;
  end;

  cColumn = class(cBase)
  protected
    // дополнительное смещение текста вызванное смещением области просмотра таблицы
    // -1 колонка не видна
    i_offsetColumn:integer;
    f_offsetColumn:single;
    // ширина коолонки в пикселях
    fWidth: integer;
    // при рисовании колонок
    scale,
    // масштаб текста в вьюпорте колонки - при рисовании строк
    ScaleColViewport:point2;
    // определяет смещение текста в строках
    tab,
    // определяет смещение текста в колонке
    tabColViewport:point2;
    viewport:array[0..3] of glint;
  protected
    procedure SetName(s: string); override;
    procedure setWidth(w: integer);
  public
    property width: integer read fWidth write setWidth;
    constructor create; override;
  end;

  cRaw = class(cBase)
  public
    data: pointer;
    // цвета ячеек строки
    colors: array of point3;
    Textcolors: array of point3;
  protected
    fSubitems: TStringList;
  protected
    procedure SetSubItem(index: integer; s: string);
    function GetSubItem(index: integer): string;
  public
    constructor create;override;
    destructor destroy;
    property SubItem[Index: integer]: string read GetSubItem write SetSubItem;
  end;

  cBaseList = class(cSetList)
  protected
    procedure deletechild(node: pointer); override;
  end;

implementation
uses
  uchart;

procedure cBaseList.deletechild(node: pointer);
begin
  cBase(node).destroy;
end;

// 1 если p1>p2, 0 если равны и -1 если p1<p2
function Comparator(p1, p2: pointer): integer;
begin
  if cBase(p1).index > cBase(p2).index then
  begin
    result := 1
  end
  else
  begin
    if cBase(p1).index < cBase(p2).index then
    begin
      result := -1
    end
    else
      result := 0;
  end;
end;

procedure cGrid.DrawData;
begin
  inherited;
  // рисуем страницу
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  setCommonVP;
  drawPageField;
  drawBound;
  DrawRaws;
  glpopmatrix;
  // рисуем колонки
  DrawColumns;
  setCommonVP;
end;

procedure cGrid.DrawRaws;
var
  j,i:integer;
  col:cColumn;
  raw:craw;
  font:cfont;
  // положение текста
  pos:point2;
  y:single;
begin
  font:=GetFont(fFontIndex);
  // отрисовка текста
  for I := firstColumn to columns.Count - 1 do
  begin
    col:=GetCol(i);
    if col.viewport[0]>=bound.Right then
      break;
    if col.viewport[0]>=bound.Left then
    begin
      glViewport(col.viewport[0],bound.Bottom,col.viewport[2],fColumnViewportHeigth)
    end
    else
    begin
      // вычесть ширину????
      j:=bound.left-col.viewport[0];
      glViewport(bound.Left,bound.Bottom,col.viewport[2]-j,fColumnViewportHeigth)
    end;
    pos.x:=-1+col.tabColViewport.x;
    y:=1-m_fRawHeigthColViewport;
    pos.y:=y+col.tabColViewport.y;
    for j := firstRaw to raws.Count - 1 do
    begin
      raw:=GetRaw(j);
      glColor3fv(@raw.colors[i]);
      glBegin(GL_QUADs);
        glvertex2f(-1,y);
        glvertex2f(-1,y+m_fRawHeigthColViewport);
        glvertex2f(1,y+m_fRawHeigthColViewport);
        glvertex2f(1,y);
      glend;
      // отрисовываем текст в ячейках строк
      glColor3fv(@raw.Textcolors[i]);
      font.scaleVectorText:=col.ScaleColViewport;
      font.OutText(raw.GetSubItem(i),p2(pos.x - col.f_offsetColumn,pos.y),c_left);
      y:=y-m_fRawHeigthColViewport;
      pos.y:=pos.y-m_fRawHeigthColViewport;
    end;
  end;
  setCommonVP;
  glcolor3fv(@fLinesColor);
  // рисуем горизонтальные линии
  for I := 0 to RawCount - 1 do
  begin
    y:=1-(i+1)*m_fRawHeigth;
    glBegin(GL_LINES);
      glVertex2f(-1,y);
      glVertex2f(1,y);
    glEnd;
  end;
end;


procedure cGrid.compile;
begin
  CompileColumns;
end;

procedure cGrid.CompileColumns;
var
  i: integer;
  font: cfont;
  col: cColumn;
  w, H, lwidth: integer;
  ltab, p: point2;
begin
  font := GetFont(fFontIndex);
  if font = nil then
    exit;
  if DisplayListName <> -1 then
    glDeleteLists(DisplayListName, 1);
  // подготовка к компиляции списка
  DisplayListName := glGenLists(1);
  glNewList(DisplayListName, GL_COMPILE);
  glColor3fv(@fColumnTextColor);
  glMatrixMode(GL_PROJECTION_MATRIX);
  glpushmatrix;
  glloadidentity;
  w := bound.left;
  H := bound.top - m_iRawHeigth;
  setCommonVP;
  p := p2iTop2(point(w, H), identMatrix4d, false);
  // рисуем границу шапки
  glbegin(GL_LINES);
    glVertex2f(-1, p.y);
    glVertex2f(1, p.y);
  glend;
  w := bound.left;
  for i := 0 to columns.Count - 1 do
  begin
    col := GetCol(i);
    w := col.width + w;
    if w>pixOffset then
    begin
      p := p2iTop2(point(w-pixOffset, H), identMatrix4d, false);
      glbegin(GL_LINES);
        glVertex2f(p.x, -1);
        glVertex2f(p.x, 1);
      glend;
    end;
  end;
  MaximumWidth:=p.x;
  glpopmatrix;
  glEndList;
end;

constructor cGrid.create;
begin
  inherited;
  dragColumn:=-1;
  m_iRawHeigth := 20;
  fFontIndex := 2;
  Tab := point(2, 2);

  color := white;
  fColumnTextColor := black;
  fLinesColor:=Brightgray;
  HeaderColor:=brightyellow;


  columns := cBaseList.create;
  columns.destroydata := true;
  columns.Comparator := Comparator;
  raws := cBaseList.create;
  raws.destroydata := true;
  raws.Comparator := Comparator;

  // добавляем поля прокрутки
  scrollBoxH:=cScrollBar.create;
  scrollBoxV:=cScrollBar.create;
  scrollBoxV.Vertical:=true;
  AddChild(scrollBoxH);
  AddChild(scrollBoxV);
end;

destructor cGrid.destroy;
begin
  columns.destroy;
  raws.destroy;
  inherited;
end;

procedure cGrid.UpdateRaws(i: integer);
var
  raw: cRaw;
  j: integer;
begin
  for j := 0 to raws.Count - 1 do
  begin
    raw := GetRaw(j);
    raw.fSubitems.Insert(i, '');
  end;
end;

procedure cGrid.initRaws;
var
  raw: cRaw;
  i, j: integer;
begin
  for i := 0 to raws.Count - 1 do
  begin
    raw := GetRaw(i);
    raw.fSubitems.Clear;
    setlength(raw.colors,columns.Count);
    setlength(raw.textcolors,columns.Count);
    for j := 0 to columns.Count - 1 do
    begin
      raw.fSubitems.Add('');
      raw.colors[j]:=white;
      raw.textcolors[j]:=black;
    end;
  end;
end;

Function cGrid.GetRaw(i: integer): cRaw;
begin
  result := cRaw(raws.getNode(i));
end;

Function cGrid.GetCol(i: integer): cColumn;
begin
  result := cColumn(columns.getNode(i));
end;

function cGrid.AddColumn(p_name: string): cColumn;
var
  i: integer;
begin
  result := cColumn.create;
  result.name := p_name;
  result.grid := self;
  i := columns.AddObj(result);
  UpdateRaws(i);
  CompileColumns;
end;

function cGrid.AddRaw: cRaw;
var
  I: Integer;
begin
  result := cRaw.create;
  result.grid := self;
  raws.AddObj(result);
  setlength(result.colors,columns.Count);
  setlength(result.textcolors,columns.Count);
  for I := 0 to columns.Count - 1 do
  begin
    result.fSubitems.Add('');
    result.colors[i]:=white;
    result.textcolors[i]:=black;
  end;
end;

procedure cGrid.SetRawHeigth(H: integer);
var
  I,j: Integer;
  col:ccolumn;
  font:cfont;
begin
  m_iRawHeigth:=H;
  m_fRawHeigth:=H*(fmax.y-fmin.y)/getheight;

  fColumnViewportHeigth:=getheight-m_iRawHeigth;
  m_fRawHeigthColViewport:=m_iRawHeigth*(fmax.y-fmin.y)/fColumnViewportHeigth;
  rawcount:=trunc(fColumnViewportHeigth/m_iRawHeigth);

  EvalColumnSizes;
  font:=GetFont(fFontIndex);
  for I := 0 to columns.Count - 1 do
  begin
    col:=GetCol(i);
    if col.viewport[0]<bound.Left then
    begin
      j:=bound.Left-col.viewport[0];
      col.ScaleColViewport:=font.EvalScale(col.viewport[2]-j,fColumnViewportHeigth);
    end
    else
      col.ScaleColViewport:=font.EvalScale(col.viewport[2],fColumnViewportHeigth);
    col.tabColViewport:=GetSize(Tab,p2(2,2),point(col.viewport[2],fColumnViewportHeigth));
  end;
end;

procedure cGrid.SetFontIndex(fIndex: integer);
begin
  FontIndex := fIndex;
end;

procedure cGrid.EvalColumnSizes;
var
  i, j,w,h, lwidth:integer;
  col,c:ccolumn;
  font:cfont;
begin
  w:=bound.left-fpixOffset;
  h:=bound.top-m_iRawHeigth;
  for i := 0 to columns.Count - 1 do
  begin
    col:=GetCol(i);
    col.viewport[0]:=w;
    if w+col.width<bound.Right then
    begin
      lwidth:=col.width;
    end
    else
    // елси ограничен справа
    begin
      lwidth:=col.width-(col.width+w-bound.right);
    end;
    col.viewport[2]:=lWidth;
    if i=firstColumn then
    begin
      col.i_offsetColumn:=-col.viewport[0]+bound.left;
      if col.viewport[2]<bound.left then
      begin
        j:=bound.Left-col.viewport[0];
        col.f_offsetColumn:=GetSize(point(col.i_offsetColumn, 0),
                            // размер вьюпорта в ogl
                            p2(2,2),
                            // вьюпорт
                            point(col.viewport[2]-j,m_iRawHeigth)).x;
      end
      else
      begin
        col.f_offsetColumn:=GetSize(point(col.i_offsetColumn, 0),
                            // размер вьюпорта в ogl
                            p2(2,2),
                            // вьюпорт
                            point(col.viewport[2],m_iRawHeigth)).x;
      end;
    end
    else
    begin
      col.i_offsetColumn:=0;
      col.f_offsetColumn:=0;
    end;
    w:=w+lWidth;
    col.viewport[1]:=h;
    col.viewport[3]:=m_iRawHeigth;
    col.Tab:=GetSize(Tab,p2(2,2),point(col.viewport[2],m_iRawHeigth));
    font:=GetFont(fFontIndex);
    if col.viewport[0]<bound.Left then
    begin
      j:=bound.Left-col.viewport[0];
      col.scale:=font.EvalScale(col.viewport[2]-j, m_iRawHeigth);
    end
    else
      col.scale:=font.EvalScale(col.viewport[2], m_iRawHeigth);
  end;
end;

procedure cGrid.DrawColumns;
var
  i,j:integer;
  font:cfont;
  col:ccolumn;
  w,lwidth:integer;
begin
  // рисуем шапку
  glViewport(bound.Left,bound.top-m_iRawHeigth,getwidth,m_iRawHeigth);
  glColor3fv(@HeaderColor);
  glBegin(GL_QUADs);
    glvertex2f(-1,-1);
    glvertex2f(-1,1);
    glvertex2f(1,1);
    glvertex2f(1,-1);
  glend;

  font:=GetFont(fFontIndex);
  if font=nil then exit;
  glColor3fv(@fColumnTextColor);
  w:=bound.left;
  // рисуем шапку колонок
  for I := 0 to columns.Count - 1 do
  begin
    if w<bound.Right then
    begin
      if i>=firstColumn then
      begin
        col:=GetCol(i);
        w:=col.viewport[0]+col.fWidth;
        //if w+col.width<bound.Right then
        if w<bound.Right then
        begin
          lwidth:=col.width;
        end
        else
        begin
          lwidth:=col.width-(col.width+w-bound.right);
        end;
        if col.viewport[0]>=bound.Left then
          glViewport(col.viewport[0],col.viewport[1],col.viewport[2],col.viewport[3])
        else
        begin
          j:=bound.left-col.viewport[0];
          glViewport(bound.Left,col.viewport[1],col.viewport[2]-j,col.viewport[3]);
        end;
        font.scaleVectorText:=col.scale;
        font.OutText(col.fName,p2(-1-col.f_offsetColumn+col.tab.x,-1+col.tab.y),c_left);
        //w:=w+col.width;
      end;
    end
    else
    begin
      break;
    end;
    if i>=firstcolumn then
    begin
      // рисуем отсутп текста
      if col.i_offsetColumn<>-1 then
      begin
        glColor3fv(@HeaderColor);
        glBegin(GL_QUADs);
          glvertex2f(-1,-1);
          glvertex2f(-1,1);
          glvertex2f(-1+col.tab.x,1);
          glvertex2f(-1+col.tab.x,-1);
        glend;
        glColor3fv(@fColumnTextColor);
      end;
    end;
  end;
  glCallList(DisplayListName);
end;

procedure cGrid.setBound(rect: trect);
begin
  inherited;
  SetRawHeigth(m_iRawHeigth);
  compile;
  UpdateScrollBars;
end;

procedure cGrid.linc(p_chart: tcomponent);
begin
  inherited;
  if p_chart<>nil then
    ownername:=cchart(p_chart).GenCursOwnerName;
  compile;
end;

procedure cGrid.UpdateScrollBars;
begin
  scrollBoxH.fupdatebound;
  scrollBoxV.fupdatebound;
  scrollBoxH.CompileScrollBar;
  scrollBoxV.CompileScrollBar;
end;

function cGrid.getColumnHeader(p:tpoint):integer;
var
  I, w: Integer;
  col :ccolumn;
begin
  p.x:=p.x-bound.Left;
  w:=0;
  result:=-1;
  for I := 0 to columns.Count - 1 do
  begin
    col:=GetCol(i);
    w:=col.viewport[0]+col.viewport[2];
    if abs(w-bound.Left-p.x)<cchart(chart).selectSize then
    begin
      if p.y>(bound.top-m_iRawHeigth) then
      begin
        result:=i;
        break;
      end;
    end;
  end;
end;

procedure cGrid.DoClick(i_p:tpoint;f_p:point2);
begin
  inherited;
  dragColumn:=getColumnHeader(i_p);
end;

procedure cGrid.DoButtonUp(i_p:tpoint;f_p:point2);
begin
  inherited;
  dragColumn:=-1;
end;


function cGrid.GetGridWidth:integer;
var
  col:ccolumn;
begin
  col:=GetCol(columns.Count-1);
  result:=pixOffset+col.viewport[0]+col.width-bound.Left;
end;

procedure cGrid.SetPixOffset(p:integer);
var
  I,w: Integer;
  col:ccolumn;
begin
  if p>0 then
  begin
    fpixOffset:=p;
  end
  else
  begin
    fpixoffset:=0;
  end;
  // первая видимая колонка
  firstColumn:=0;
  w:=0;
  for I := 0 to columns.Count - 1 do
  begin
    col:=GetCol(i);
    w:=w+col.width;
    if w<p then
    begin
      inc(firstColumn);
    end
    else
      break;
  end;
  EvalColumnSizes;
  compile;
  // пересчет размеров текста в ячейках
  RawHeigth:=m_iRawHeigth;
  cchart(chart).needRedraw:=true;
end;

procedure cGrid.doOnExit;
begin
  dragColumn:=-1;
  fdrag:=false;
  cchart(chart).setcursor(crDefault, -1);
end;

procedure cGrid.DoMouseMove(i_p:tpoint;f_p:point2);
var
  I,w,p: Integer;
  col:ccolumn;
  lmouseControl:boolean;
begin
  inherited;
  lmouseControl:=false;
  p:=i_p.x;
  i_p.x:=i_p.x-bound.Left;
  w:=0;
  for I := 0 to columns.Count - 1 do
  begin
    col:=GetCol(i);
    //w:=w+col.fWidth;
    w:=col.viewport[0]+col.viewport[2];
    if abs(w-bound.left-i_p.x)<cchart(chart).selectSize then
    begin
      if i_p.y>(bound.top-m_iRawHeigth) then
      begin
        cchart(chart).setcursor(crSizeWE, ownername, true);
        lmouseControl:=true;
        break;
      end;
    end;
  end;
  if dragColumn=-1 then
  begin
    if not lmousecontrol then
    begin
      cchart(chart).setcursor(crDefault, -1);
    end;
  end
  else
  begin
    col:=GetCol(dragColumn);
    w:=(p-col.viewport[0]);
    //if dragcolumn=firstColumn then
    //  w:=w+fpixOffset;
    if w<0 then
    begin
      w:=1;
    end;
    col.width:=w;
  end;
end;

constructor cBase.create;
begin
  inherited;
end;

procedure cBase.SetName(s: string);
begin
  fName := s;
end;

procedure cBase.SetIndex(i: integer);
begin
  fIndex := i;
end;

constructor cColumn.create;
begin
  inherited;
  fWidth := 40;
end;

procedure cColumn.setWidth(w: integer);
begin
  fWidth := w;
  if grid.chart<>nil then
  begin
    grid.CompileColumns;
    // расчет полей колонок
    grid.SetRawHeigth(grid.m_iRawHeigth);
    cchart(grid.chart).needRedraw:=true;
  end;
end;

procedure cColumn.SetName(s: string);
begin
  inherited;
  if grid <> nil then
  begin
    grid.CompileColumns;
  end;
end;

constructor cRaw.create;
begin
  inherited;
  fSubitems:=TStringList.Create;
end;

destructor cRaw.destroy;
begin
  fSubitems.Destroy;
end;

procedure cRaw.SetSubItem(index: integer; s: string);
begin
  fSubitems.Strings[index] := s;
end;

function cRaw.GetSubItem(index: integer): string;
begin
  result := fSubitems.Strings[index];
end;

procedure cScrollBar.SetiWidth(w: integer);
begin
  m_iWidth := w;
  needUpdateBound := true;
end;

procedure cScrollBar.fupdatebound;
var
  page: cBasePage;
  iPageWidth: integer;
begin
  page := cBasePage(getpage);
  if Vertical then
  begin
    iPageWidth := page.getwidth;
    m_fWidth := 2 * (m_iWidth / iPageWidth);
    BtnWidth:= 2 * (m_iWidth / page.getheight);
    boundrect.BottomLeft := p2(1 - m_fWidth, -1+BtnWidth);
    boundrect.topright := p2(1, 1);
  end
  else
  begin
    iPageWidth := page.getheight;
    m_fWidth := 2 * (m_iWidth / iPageWidth);
    BtnWidth:= 2 * (m_iWidth / page.getwidth);
    boundrect.BottomLeft := p2(-1, -1);
    boundrect.TopRight := p2(page.fmax.x, -1 + m_fWidth);
  end;
end;

procedure cScrollBar.drawdata;
begin
  inherited;
  glcolor3fv(@color);
  // отрисовка полигона
  glBegin(GL_QUADs);
    glvertex2f(boundrect.BottomLeft.x,boundrect.BottomLeft.y);
    glvertex2f(boundrect.BottomLeft.x,boundrect.TopRight.y);
    glvertex2f(boundrect.TopRight.x,boundrect.TopRight.y);
    glvertex2f(boundrect.TopRight.x,boundrect.BottomLeft.y);
  glend;
  glcolor3fv(@borderColor);
  // отрисовка границы
  glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
  // отрисовка полигона
  glBegin(GL_QUADs);
    glvertex2f(boundrect.BottomLeft.x,boundrect.BottomLeft.y);
    glvertex2f(boundrect.BottomLeft.x,boundrect.TopRight.y);
    glvertex2f(boundrect.TopRight.x,boundrect.TopRight.y);
    glvertex2f(boundrect.TopRight.x,boundrect.BottomLeft.y);
  glend;
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
  //glCallList(DisplayList);
  DrawPos;
  drawButton;
end;

procedure cScrollBar.drawButton;
var
  v:single;
begin
  if Vertical then
  begin
    v:=boundrect.BottomLeft.y+BtnWidth;
    glBegin(GL_Lines);
      glvertex2f(boundrect.BottomLeft.x,v);
      glvertex2f(boundrect.TopRight.x,v);
    glend;
    glBegin(GL_Lines);
      glvertex2f(boundrect.BottomLeft.x,boundrect.BottomLeft.y);
      glvertex2f(boundrect.TopRight.x,v);
    glend;
    glBegin(GL_Lines);
      glvertex2f(boundrect.TopRight.x,boundrect.BottomLeft.y);
      glvertex2f(boundrect.BottomLeft.x,v);
    glend;

    v:=boundrect.TopRight.y-BtnWidth;
    glBegin(GL_Lines);
      glvertex2f(boundrect.BottomLeft.x,v);
      glvertex2f(boundrect.TopRight.x,v);
    glend;
    glBegin(GL_Lines);
      glvertex2f(boundrect.BottomLeft.x,v);
      glvertex2f(boundrect.TopRight.x,boundrect.TopRight.y);
    glend;
    glBegin(GL_Lines);
      glvertex2f(boundrect.TopRight.x,v);
      glvertex2f(boundrect.BottomLeft.x,boundrect.TopRight.y);
    glend;
  end
  else
  begin
    v:=boundrect.BottomLeft.x+BtnWidth;
    glBegin(GL_Lines);
      glvertex2f(v,boundrect.BottomLeft.y);
      glvertex2f(v,boundrect.TopRight.y);
    glend;
    glBegin(GL_Lines);
      glvertex2f(v,boundrect.TopRight.y);
      glvertex2f(boundrect.BottomLeft.x,boundrect.BottomLeft.y);
    glend;
    glBegin(GL_Lines);
      glvertex2f(boundrect.BottomLeft.x,boundrect.TopRight.y);
      glvertex2f(v,boundrect.BottomLeft.y);
    glend;

    v:=boundrect.TopRight.x-BtnWidth;
    glBegin(GL_Lines);
      glvertex2f(v,boundrect.BottomLeft.y);
      glvertex2f(v,boundrect.TopRight.y);
    glend;
    glBegin(GL_Lines);
      glvertex2f(v,boundrect.TopRight.y);
      glvertex2f(boundrect.TopRight.x,boundrect.BottomLeft.y);
    glend;
    glBegin(GL_Lines);
      glvertex2f(boundrect.TopRight.x,boundrect.TopRight.y);
      glvertex2f(v,boundrect.BottomLeft.y);
    glend;
  end;
end;

constructor cScrollBar.create;
begin
  inherited;
  borderColor:=black;
  posColor:=gray;
  color:=Brightgray;
  m_iWidth:=12;
  Vertical:=false;
  fHelper:=true;
  selectable:=true;
  locked:=true;
end;

procedure cScrollBar.CompileScrollBar;
var
  allsize:single;
begin
  if DisplayList > 0 then
    glDeleteLists(DisplayList, 1);
  // подготовка к компиляции списка
  DisplayList := glGenLists(1);
  DrawPos;
  glEndList;
end;

procedure cScrollBar.DrawPos;
var
  size,top,allsize:single;
  fullW, zoomW:integer;
  col:ccolumn;
begin
  if vertical then
  begin
    size:=cGrid(parent).rawcount/(cGrid(parent).rawcount+cGrid(parent).firstRaw);
    if size<1 then
    begin
      allsize:=boundrect.TopRight.y-boundrect.BottomLeft.y-2*btnwidth;
      size:=allsize*size;
      top:=boundrect.TopRight.y-btnwidth-
           allsize*cGrid(parent).firstRaw/(cGrid(parent).rawcount+
                                           cGrid(parent).firstRaw);
      glcolor3fv(@posColor);
      glbegin(GL_QUADS);
        glvertex2f(boundrect.BottomLeft.x,top-size);
        glvertex2f(boundrect.BottomLeft.x,top);
        glvertex2f(boundrect.TopRight.x,top);
        glvertex2f(boundrect.TopRight.x,top-size);
      glend;
    end;
  end
  else
  // если скролл бар горизонтальный
  begin
    fullW:=cGrid(parent).GetGridWidth;
    col:=cGrid(parent).GetCol(cGrid(parent).columns.Count-1);
    if (col.viewport[0]+col.fwidth)>cGrid(parent).bound.Right then
    begin
      zoomW:=cGrid(parent).bound.Right-cGrid(parent).bound.Left;
    end
    else
    begin
      zoomW:=fullw-cGrid(parent).pixoffset;
    end;
    allsize:=cGrid(parent).GetFWidth-2*BtnWidth;
    // размер скроллбара
    size:=zoomW/fullW;
    if size<1 then
    begin
      // размер скролл бара
      size:=allsize*size;
      // начальная позиция скроллбара
      top:=boundrect.BottomLeft.x+btnwidth+allsize*cGrid(parent).fpixOffset/fullW;
      glcolor3fv(@posColor);
      glbegin(GL_QUADS);
        glvertex2f(top,boundrect.BottomLeft.y);
        glvertex2f(top,boundrect.TopRight.y);
        glvertex2f(top+size,boundrect.TopRight.y);
        glvertex2f(top+size,boundrect.BottomLeft.y);
      glend;
    end;
  end;
end;

procedure cScrollBar.linc(p_chart: tcomponent);
begin
  inherited;
  if p_chart<>nil then
  begin
    frame:=cChart(chart).frList.GetFrame('cObjFrListener');
  end;
end;

procedure cScrollBar.DoOnMouseMove(p:point2);
begin
  inherited;
  frame.LockMouse:=true;
end;

procedure cScrollBar.DoOnMouseMove(p:tpoint);
begin
  inherited;
end;

procedure cScrollBar.DoOnMouseLeave;
begin
  inherited;
  frame.LockMouse:=false;
end;

procedure cScrollBar.DoOnClick(p:point2);
var
  page:cbasepage;
  d:single;
begin
  inherited;
  if vertical then
  begin
    if abs(boundrect.TopRight.y-p.y)<BtnWidth then
    begin
      if cgrid(parent).firstraw>0 then
      begin
        dec(cgrid(parent).firstRaw);
      end;
    end
    else
    begin
      if abs(boundrect.BottomLeft.y-p.y)<BtnWidth then
      begin
        inc(cgrid(parent).firstRaw);
      end
    end;
  end
  else
  // горизонтальный скроллбар
  begin
    page:=cbasepage(getpage);
    d:=0;
    if abs(boundrect.TopRight.x-p.x)<BtnWidth then
    // сдвиг вправо на 10%
    begin
      d:=page.GetFWidth*0.1;
      cGrid(page).pixOffset:=cgrid(page).pixOffset+10;
    end
    else
    begin
      if abs(boundrect.BottomLeft.x-p.x)<BtnWidth then
      begin
        cGrid(page).pixOffset:=cgrid(page).pixOffset-10;
        d:=page.GetFWidth*(-0.1);
      end
    end;
    if d<>0 then
    begin
      cGrid(page).EvalColumnSizes;
      cGrid(page).compile;
    end;
  end;
  cchart(chart).needRedraw:=true;
end;


function cScrollBar.TestObj(p2:point2; dist:single):boolean;
begin
  Result:=checkBound(p2);
end;


end.
