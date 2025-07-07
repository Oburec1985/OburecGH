unit uFreqBand;

interface
uses
  ubtnlistview, classes, stdctrls, controls, ExtCtrls, ComCtrls, uchartevents,
  uBaseObj, utrend, ucommonmath, uCommonTypes, sysutils, uDrawObj, opengl,  uaxis,
  uFrameListener, messages, windows, uCursors, ulogFile, uLabel, uPage,
  uSimpleObjects,
  uBasicTrend,
  mathfunction
  ;

type
  cTrendPair = class
  public
    tr:cbasictrend;
    l:clabel;
  public
    destructor destroy;
  end;

  cFreqBand = class(cdrawobj)
  public
    // подпись линий
    m_LineLabel:cLabel;
    // хранит cTrendPair
    m_trendLabels:tlist;
    m_fullname:boolean;
    // назначаетс€ из вне!!!!! –аботает в паре с листом m_y[i]
    m_names:tstringlist;
    // значение дл€ подписи по Y. –аботает в паре с листом m_names
    m_y:array of double;
  protected
    m_LineColor:point3;
    m_drawline:boolean;
    // √раница слева (отступ в координатах +-1)
    m_x1:double;
    // √раница справа (отступ в координатах +-1)
    m_x2:double;
    // центральна€ частота в координатах +-1
    m_x:double;
    m_capacity, m_length:integer;
    // отладочна€ дл€ сохранени€ что передавалось в setname
    m_text:string;
  public
    // вли€ет только на подпись. ѕока реализаци€ размещени€ в координатах
    // отрисовки на совести пользовател€ (см. uSpmChart как пример)
    m_realX:double;
  protected
    procedure cleartrendlabels;
    // происходит при назначении нового родител€
    procedure DoLincParent; override;
    procedure drawdata;override;
    procedure setx(v:double);
    procedure setx1(v:double);
    procedure setx2(v:double);
    procedure setdrawline(v:boolean);
    // вызываетс€ с пмоощью механизма event-ов при обновлении страницы
    procedure doLabelMove(sender:tobject);
    procedure doUpdatePageSize(sender:tobject);
    procedure doUpdateTextLabels(sender:tobject);
    procedure DeleteEvents;Override;
    procedure CreateEvents;override;
    procedure setname(s:string);override;
    procedure settext(s:string; i:integer);
    function getLineText:string;
    procedure setLineText(s:string);
    procedure setsize(i:integer);
  public
    property length:integer read m_length write setsize;
    procedure setY(v:double);overload;
    procedure setY(v: double; i:integer);overload;
    procedure inittrendlabels;
    constructor create;override;
    destructor destroy;override;
    property linetext:string read getLineText write setLineText;
    property x:double read m_x write setx;
    // координаты ставить в координатах +-1
    property x1:double read m_x1 write setx1;
    property x2:double read m_x2 write setx2;
    property drawline:boolean read m_drawline write setdrawline;
    //destructor destroy;override;
    //procedure drawdata;override;
  end;

implementation


function correctPosX(page: cpage; x: double; var error:boolean): double;
var
  min, max: double;
begin
  error:=false;
  if page.lgX then
  begin
    min:=page.MinX;
    max:=page.MaxX;
    if (min < x) and (x < max) then
    begin
      result := LogValToLinearScale(x, p2d(min, max));
    end
    else
      error:=true;
  end
  else
  begin
    result := x;
  end;
end;

function correctPosY(aX: caxis; page: cpage; p: point2d): double;
var
  y: double;
begin
  if aX.lg then
  begin
    if (aX.min.y < p.y) and (p.y < aX.max.y) then
    begin
      y := LogValToLinearScale(p.y, p2d(aX.min.y, aX.max.y));
    end;
  end
  else
  begin
    y := p.y;
  end;
  result:=y;
end;

function correctPos(aX: caxis; page: cpage; p: point2d): point2d;
var
  x, y: double;
begin
  if page.lgX then
  begin
    if (aX.min.x < p.x) and (p.x < aX.max.x) then
    begin
      x := LogValToLinearScale(p.x, p2d(aX.min.x, aX.max.x));
    end;
  end
  else
  begin
    x := p.x;
  end;
  if aX.lg then
  begin
    if (aX.min.y < p.y) and (p.y < aX.max.y) then
    begin
      y := LogValToLinearScale(p.y, p2d(aX.min.y, aX.max.y));
    end;
  end
  else
  begin
    y := p.y;
  end;
  result := p2d(x, y);
end;

{ cFreqBand }

procedure cFreqBand.cleartrendlabels;
var
  I: Integer;
  p:cTrendPair;
begin
  for I := 0 to m_trendLabels.Count - 1 do
  begin
    p:=ctrendpair(m_trendLabels.Items[i]);
    p.destroy;
  end;
  m_trendLabels.Clear;
end;

constructor cFreqBand.create;
begin
  inherited;
  m_trendLabels:=tlist.create;

  fhelper:=false;
  autocreate:=true;
  m_drawline:=true;
  color:=Brightgray;
  m_linecolor:=red;
  m_x1:=0.1;
  m_x2:=0.1;

  m_LineLabel:=clabel.create;
  m_LineLabel.m_drawobjvp:=true;
  m_LineLabel.enabled:=true;
  m_LineLabel.flocked:=false;
  m_LineLabel.fHelper:=false;
  m_LineLabel.autocreate:=true;
  m_LineLabel.Transparent:=false;
  //AddChild(m_LineLabel);

  m_capacity:=10;
  setlength(m_y, m_capacity);
  m_length:=0;

  boundrect.BottomLeft.y:=-1;
  boundrect.TopRight.y:=1;
end;


procedure cFreqBand.DoLincParent;
var
  page: cpage;
  rect: TRect;
  index:integer;
begin
  inherited;
  page := cpage(getpage);
  if page<>nil then
  begin
    m_LineLabel.fOnMove:=doLabelMove;
    page.addchild(m_LineLabel);
    m_LineLabel.Text:=m_LineLabel.Text;
    m_LineLabel.Position:=p2(0, page.m_TabSpace.BottomLeft.y+m_LineLabel.GetTextHeigth);
  end;
end;

procedure cFreqBand.drawdata;
var
  page: cpage;
  a:caxis;
  x1x2:point2;
  b:boolean;
begin
  inherited;
  page := cpage(getpage);
  page.setDrawObjVP;
  if true then
  begin
    drawrect(boundrect, color);
    if drawline then
    begin
      glColor3fv(@m_LineColor);
      uSimpleObjects.DrawLine(p2(m_x,-1), p2(m_x,1));
    end;
  end;
end;


procedure cFreqBand.setdrawline(v: boolean);
begin
  EnterCS;
  m_drawline:=v;
  exitcs;
end;

procedure cFreqBand.setsize(i: integer);
begin
  if i>m_capacity then
  begin
    m_capacity:=i;
    setlength(m_y, m_capacity);
  end;
  m_length:=i;
end;

function cFreqBand.getLineText: string;
begin
  result:=m_LineLabel.text;
end;

procedure cFreqBand.inittrendlabels;
var
  o:cdrawobj;
  t:cbasictrend;
  l:clabel;
  p:cpage;
  a:caxis;
  I, j: Integer;
  pair:cTrendPair;
begin
  cleartrendlabels;
  p := cpage(getpage);
  for I := 0 to p.getAxisCount - 1 do
  begin
    a:=p.getaxis(i);
    for j := 0 to a.ChildCount - 1 do
    begin
      o:=cdrawobj(a.getChild(j));
      if o is cbasictrend then
      begin
        t:=cbasictrend(o);
        l:=clabel.create;
        l.fHelper:=true;
        l.name:=t.name+'_Label';
        pair:=cTrendPair.Create;
        pair.tr:=t;
        pair.l:=l;
        m_trendLabels.Add(pair);
      end;
    end;
  end;
end;

procedure cFreqBand.setLineText(s: string);
begin
  m_LineLabel.text:=s;
end;

procedure cFreqBand.setname(s: string);
var
  str, namestr:string;
  I: Integer;
begin
  inherited;
  m_text:=s;
  //m_LineLabel.Text:=s+char(10)+format(' X:%.3g', [m_realX]);
  if m_names<>nil then
  begin
    if m_names.Count>0 then
    begin
      str:=s+char(10)+'X: '+formatstrNoE(m_realX, 3)+char(10);
      for I := 0 to m_names.Count - 1 do
      begin
        if (m_fullname) and (m_names<>nil) then
        begin
          namestr:=m_names.Strings[i]+': ';
        end
        else
        begin
          namestr:='Y'+inttostr(i)+': ';
        end;
        if i=length-1 then
        begin
          str:=str+namestr+formatstrNoE(m_y[i], 3);
        end
        else
          str:=str+namestr+formatstrNoE(m_y[i], 3)+char(10);
      end;
      // отладочна€ инфа
      //str:=str+char(10)+'Position:' +floattostr(m_LineLabel.Position.X)+' '+floattostr(m_LineLabel.Position.y);
      m_LineLabel.Text:=str;
    end
    else
      m_LineLabel.Text:=s+char(10)+'X: '+formatstrNoE(m_realX, 3)+char(10)+'Y: '+'0';
  end
  else
  begin
    m_LineLabel.Text:=s+char(10)+'X: '+formatstrNoE(m_realX, 3)+char(10)+'Y: '+'0';
  end;
end;

procedure cFreqBand.settext(s:string; i:integer);
begin
  m_LineLabel.Text:=s+char(10)+'X: '+formatstrNoE(m_realX, 3)+char(10)+'Y: '+formatstrNoE(m_y[i], 3);
end;

procedure cFreqBand.doLabelMove(sender: tobject);
begin
  setname(m_text);
end;

procedure cFreqBand.setx(v: double);
var
  p:cpage;
  lp2, lp:point2;
  dx,offset:double;

begin
  EnterCS;
  // смещение позиции полосы
  dx:=v-m_x;
  m_x:=v;
  boundrect.BottomLeft.x:=m_x-m_x1;
  boundrect.TopRight.x:=m_x+m_x2;
  p:=cpage(getpage);
  // находим смещение
  if p<>nil then
  begin
    //lp2:=p.p2iTop2(m_LineLabel.m_userOffset);
    lp2.x:=lp2.x+1;
    lp2.y:=lp2.y+1;
    lp2.x:=0;
    lp2.y:=0;
  end;
  lp:=m_LineLabel.Position;
  m_LineLabel.Position:=p2(lp.x+dx, lp.y);
  exitcs;
end;

procedure cFreqBand.setx1(v:double);
begin
  EnterCS;
  m_x1:=v;
  boundrect.BottomLeft.x:=m_x-m_x1;
  exitcs;
end;

procedure cFreqBand.setx2(v:double);
begin
  EnterCS;
  m_x2:=v;
  boundrect.TopRight.x:=m_x+m_x2;
  exitcs;
end;

procedure cFreqBand.setY(v: double);
begin
  EnterCS;
  if length>0 then
    m_y[0]:=v;
  exitCS;
end;

procedure cFreqBand.setY(v: double; i:integer);
begin
  EnterCS;
  if length>=i then
    m_y[i]:=v;
  exitCS;
end;

procedure cFreqBand.doUpdatePageSize(sender:tobject);
var
  page:cpage;
begin
  page := cpage(getpage);
  //boundrect.BottomLeft.y:=-1;
  //boundrect.TopRight.y:=1;
end;

procedure cFreqBand.doUpdateTextLabels(sender: tobject);
var
  a:caxis;
  p:cpage;
begin
  p := cpage(getpage);
  a:=p.activeAxis;
  if True then

end;

procedure cFreqBand.CreateEvents;
begin
  //events.AddEvent('trendAddpoint', e_onAddpoint, doaddpoint);
  events.AddEvent(name+'_OnPageSizeFreqBand', e_onResize, doUpdatePageSize);
  events.AddEvent(name+'_OnChangeAxisScale', e_OnChangeAxisScale, doUpdateTextLabels);
end;

procedure cFreqBand.DeleteEvents;
begin
  inherited;
  events.removeEvent(doUpdatePageSize, e_onResize);
end;

destructor cFreqBand.destroy;
begin
  cleartrendlabels;
  m_trendLabels.destroy;
  inherited;
end;

{ cTrendPair }

destructor cTrendPair.destroy;
begin
  l.destroy;
  inherited;
end;

end.
