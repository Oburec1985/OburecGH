unit uPageMng;

interface
uses ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, classes, stdctrls,
     Graphics, windows, uAxis, messages, utext, sysutils, uEventList,
     uChartEvents, uPoint, dialogs, controls, forms, uPage, uLegend, uBasePage;
type
  cPageMng = class(cdrawobj)
  protected
    factivepage:cbasepage;
  protected
    procedure CreateEvents;override;
    procedure deleteEvents;override;
    procedure doLincParent;override;
  protected
    function getActivePage:cbasepage;
    procedure setactivepage(page:cBasePage);
  public
    procedure clear;
    procedure doalign(sender:tobject);
    // получить границы чарта в которых можно рисовать страницу
    function getClientBound:trect;
    procedure LincChart(p_chart:tcomponent);
    function addPage(align:boolean):cpage;
    function GetPage(i:integer):cpage;overload;
    function GetPage(p_name:string):cpage;overload;
    // выровнять страницы на графике
    procedure Alignpages(cols:integer);
    constructor create;override;
  public
    property activepage:cbasepage read getActivePage write setActivePage;
  end;

  cPageMngList = class(cDrawObj)
  protected
    factiveTab:cPageMng;
  protected
    procedure CreateEvents;
    procedure deleteEvents;
  protected
    function getActivePage:cbasepage;
    procedure setactivepage(page:cbasePage);
    function getActiveTab:cpageMng;
    procedure setactiveTab(pagemng:cPageMng);
  public
    Constructor create;override;
    destructor destroy;override;
    procedure LincChart(p_chart:tcomponent);
    function addTab:cPageMng;
    function getTab(i:integer):cPageMng;
  public
    property activeTab:cPageMng read GetActiveTab write SetActiveTab;
    property activepage:cbasepage read getactivepage write setactivepage;
  end;

implementation
uses
  uchart;

constructor cPageMng.create;
begin
  inherited;
  name:='Pages';
end;

procedure cPageMng.setactivepage(page:cbasepage);
var
  i:integer;
begin
  if page=activepage then exit;
  if page=nil then
  begin
    if ChildCount>0 then
    begin
      for I := 0 to childCount - 1 do
      begin
        if factivepage<>GetPage(i) then
        begin
          factivepage:=GetPage(i);
          if (cchart(chart).frList<>nil) then
            cchart(chart).frList.active:=true;
          exit;
        end;
      end;
    end;
  end;
  factivepage:=page;
  if chart<>nil then
  begin
    if self=cchart(chart).activeTab then
    begin
      cchart(chart).redraw;
    end;
    if page<>nil then
      cchart(chart).SelectInTV(page);
    if (cchart(chart).frList<>nil) then
      cchart(chart).frList.active:=not (factivepage=nil);
  end;
end;

function cPageMng.getActivePage:cbasepage;
begin
  if factivepage=nil then
  begin
    if ChildCount>0 then
    begin
      result:=GetPage(0);
      factivepage:=GetPage(0);
    end;
  end;
  result:=factivepage;
end;

function cPageMng.getClientBound:trect;
var
  r:trect;
begin
  r.left:=0;
  if chart=nil then exit;
  if cchart(Chart).showtv then
  begin
    r.Left:=cchart(self.Chart).tv.Width+2;
  end;
  r.right:=cchart(self.Chart).width+cchart(self.Chart).left-3;
  r.bottom:=0;
  r.top:=cchart(self.Chart).height-1;
  if cchart(Chart).legend<>nil then
  begin
    if cchart(Chart).legend.visible then
    begin
      r.Bottom:=cchart(self.Chart).legend.Height+legendsplitterwidth;
    end;
  end;
  result:=r;
end;

function cPageMng.addPage(align:boolean):cpage;
var
  page:cpage;
begin
  page:=cpage.create;
  page.linc(chart);
  AddChild(page);
  if align then
    doalign(page);
  result:=page;
end;

procedure cPageMng.LincChart(p_chart:tcomponent);
begin
  chart:=p_chart;
end;

function cPageMng.GetPage(i:integer):cpage;
begin
  result:=cpage(getChild(i));
end;

function cPageMng.GetPage(p_name:string):cpage;
begin
  result:=cpage(getChild(p_name));
end;

procedure cPageMng.Alignpages(cols:integer);
var
  clBound:trect;
  i,row,col,rows,w,h:integer;
  size:tpoint;
  page:cpage;

  fsize:point2;
  rect:trect;
  relbound:frect;
begin
  if childcount mod cols<>0 then
  begin
    rows:=trunc(ChildCount/cols)+1;
  end
  else
    rows:=round(ChildCount/cols);
  if rows=0 then
    rows:=1;
  clBound:=getClientBound;
  w:=clBound.Right-clBound.left;
  h:=clBound.top-clBound.bottom;
  size.x:=trunc(w/cols);
  size.y:=trunc(h/rows);
  // перенес код снизу 10.07.25
  for I := 0 to ChildCount - 1 do
  begin
    page:=GetPage(i);
    row:= i div cols;
    col:=I MOD cols;
    fsize.y:=1/rows;
    fsize.x:=1/cols;
    relbound.BottomLeft.x:=fsize.x*col;
    relbound.TopRight.x:=fsize.x*col+fsize.x;
    relbound.TopRight.y:=1-fsize.y*row;
    relbound.BottomLeft.y:=1-(fsize.y*row+fsize.y);
    page.Relativebound:=relbound;
  end;

  i:=0;
  col:=0;
  if (w>0) and (h>0) then
  begin
    while i<childcount do
    begin
      for row := 0 to cols - 1 do
      begin
        if (col=rows-1) and (row=0) then
        begin
          cols:=ChildCount mod cols;
          if cols<>0 then
            size.x:=trunc(w/cols);
        end;
        rect.left:=clBound.Left+row*size.x;
        rect.top:=clBound.top-col*size.y;;
        rect.Right:=rect.left+size.x;
        rect.Bottom:=rect.top-size.y;
        page:=GetPage(i);
        page.bound:=rect;
        inc(i);
        if i>=childcount then
          break;
      end;
      inc(col);
    end;
  end;
  // установка габаритов по относительным координатам. Возможно все что выше надо похерить...2023
  // т.к. код выше не работает для случая когда чарт появился с нулевыми габаритами
  {if (w<=0) or (h<=0) then
  begin
    for I := 0 to ChildCount - 1 do
    begin
      page:=GetPage(i);
      row:= i div cols;
      col:=I MOD cols;
      fsize.y:=1/rows;
      fsize.x:=1/cols;
      relbound.BottomLeft.x:=fsize.x*col;
      relbound.TopRight.x:=fsize.x*col+fsize.x;
      relbound.TopRight.y:=1-fsize.y*row;
      relbound.BottomLeft.y:=1-(fsize.y*row+fsize.y);
      page.Relativebound:=relbound;
    end;
  end;}
end;

procedure cPageMng.doalign(sender:tobject);
var
  colcount:integer;
begin
  if childcount>1 then
  begin
    //if childcount=2 then
    //  colcount:=2
    //Else
    colcount:=round(sqrt(childcount));
    Alignpages(colcount);
  end
  else
  begin
    if sender<>nil then
    begin
      cpage(sender).ChangeSize;
    end;
  end;
end;

procedure cPageMng.clear;
begin
  destroychildrens;
end;

procedure cPageMng.CreateEvents;
begin
  //events.AddEvent('trendSelectPoint', e_onSelectPoint, doSelectpoint);
end;

procedure cPageMng.deleteEvents;
begin
  inherited;
end;

procedure cPageMng.doLincParent;
begin
  inherited;
  if parent<>nil then
  begin
    if cPageMngList(parent).ChildCount=1 then
    begin
      cPageMngList(parent).activeTab:=self;
    end;
  end;
end;

Constructor cPageMngList.create;
begin
  inherited;
  fHelper:=true;
end;

destructor cPageMngList.destroy;
begin
  inherited;
end;

function cPageMngList.addTab:cPageMng;
var
  pages:cPageMng;
begin
  pages:=cPageMng.create;
  AddChild(pages);
  result:=pages;
  if childcount=1 then
  begin
    setactiveTab(pages);
  end;
end;

procedure cPageMngList.CreateEvents;
begin
  //events.AddEvent('OnDeleteTabs', E_OnDestroyObject, doOnDestroy);
  //deleteEvents;
end;

procedure cPageMngList.deleteEvents;
begin

end;

procedure cPageMngList.LincChart(p_chart:tcomponent);
var
  p:cpage;
begin
  chart:=p_chart;
  if childcount=0 then
  begin
    factivetab:=addTab;
    factivetab.lincchart(p_chart);
    p:=cpage(factivetab.addpage(true));
  end;
  begin
    p:=cpage(factivetab.addpage(true));
    factivetab.events:=events;
  end;
end;

function cPageMngList.getActiveTab:cPageMng;
begin
  result:=factivetab;
end;

function cPageMngList.getTab(i:integer):cPageMng;
begin
  if i<childcount then
  begin
    result:=cpagemng(getchild(i));
  end
  else
    result:=nil;
end;

procedure cPageMngList.setactiveTab(pageMng:cPageMng);
var
  tab:cpagemng;
  i:integer;
begin
  factivetab:=pageMng;
  if pageMng=nil then
  begin
    if childcount>1 then
    begin
      for I := 0 to childcount - 1 do
      begin
        tab:=gettab(i);
        if tab<>pageMng then
        begin
          factiveTab:=tab;
          exit;
        end;
      end;
    end;
  end
  else
  begin
    if pagemng.activepage=nil then
    begin
      if pagemng.ChildCount<>0 then
      begin
        pagemng.activepage:=pagemng.GetPage(0);
      end;
    end;
  end;
end;

function cPageMngList.getActivePage:cbasepage;
begin
  result:=factiveTab.activepage;
end;

procedure cPageMngList.setactivepage(page:cbasePage);
begin
  factiveTab.activepage:=page;
end;

end.
