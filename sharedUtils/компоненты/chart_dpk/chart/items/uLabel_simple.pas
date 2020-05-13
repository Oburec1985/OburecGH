unit uLabel_simple;

interface
uses
  uCommonTypes, opengl, uOglExpFunc, types, dialogs,
  sysutils, math, uCommonMath, stdctrls, forms, controls, classes,
  uText, uEventList,
  ubaseobj, udrawobj,
  uChartEvents, mathfunction,
  uSimpleObjects,
  uGraphObj, windows,
  messages,
  clipbrd;

type
  cLabel = class(cMoveObj)
  public
    align:integer;
  protected
    fOnSetText:TNotifyEvent;
    // индексы выделенных букв
    fSelectText:tpoint;
    // отрисовка выделенного текста
    fSelectBound: frect;
    fText:string;
    // индекс рабочего шрифта
    fontIndex,
    // позиция курсора (перед каким символом стоит позиция для вставки текста)
    fCursorPos
    :integer;
    // высота
    fHeigth:integer;
    // ширина
    fWidth:integer;
    // коэффициенты которые масштабируют текст чтобы его размеры соответствовали
    // пиксельному размеру при масштабировании окна
    scale: point2;
    KeepScale:boolean;
    m_TextColor,
    m_SelectTextColor:point3;
    f_iTextPos:tpoint;
    // смещение текста относительно левого нижнего угла рамки
    f_TextPos:point2;
    fTransparent:boolean;

    fKeyDown:TKeyEvent;
  protected
    procedure updateBound;
    procedure SetText(s:string);
    procedure DrawData;override;
    procedure DrawBorder;
    procedure DrawCursorPos;
    procedure DrawText;
    procedure DrawSelectText;
    procedure SetCursPos(i:integer);
    procedure SetHeigth(h:integer);
    procedure SetWidth(w:integer);
    procedure doUpdateWorldSize(sender:tobject);override;
    procedure reEvalScales;
    procedure BuildSelectRect(left: integer; right: integer);
    function GetCharIndexByPos(p:point2):integer;
    procedure SetTransparent(b:boolean);
    function getChar(key:cardinal):char;
    procedure InsertChar(ch:char);virtual;
    // граница текста при выравнивании по правому краю
    function TextRightPos:single;
  public
    property OnKeyEnter:TKeyEvent read fKeyDown write fKeyDown;
  public
    function GetTextHeigth:single;
    function GetTextWidth:single;
    procedure SelectText(rect: frect);
    procedure DoOnBtnUp(p:point2);override;
    procedure DoOnMouseMove(p:point2);override;
    procedure DoOnClick(p:point2);override;
    procedure DoOnDblClick(p:point2);override;
    procedure DoOnKeyEnter(key:word);override;
    procedure DoOnMove(p:point2);override;
    procedure DoOnMouseLeave;override;
    procedure DoOnExit;override;
    function TestObj(p_p2:point2; dist:single):boolean;override;
    constructor create;override;
    destructor destroy;override;
    property Text:string read fText write setText;
    property Heigth:integer read fHeigth write SetHeigth;
    property Width:integer read fWidth write SetWidth;
    property CursorPos:integer read fCursorpos write SetCursPos;
    property Transparent:boolean read fTransparent write SetTransparent;
    property TextColor:point3 read m_textColor write m_TextColor;
    property OnSetText:TNotifyEvent read fOnSetText write fOnSetText;
  end;

implementation
uses
  uchart, uBasePage, uaxis;

function cLabel.TestObj(p_p2:point2; dist:single):boolean;
var
  r:frect;
begin
  result:=inherited;
  r:=GetBound;
  if (p_p2.x>r.BottomLeft.x-dist) and (p_p2.x<r.TopRight.x+dist) then
  begin
    if (p_p2.y>r.BottomLeft.y-dist) and (p_p2.y<r.TopRight.y+dist) then
    begin
      result:=true;
    end;
  end;
end;

constructor cLabel.create;
begin
  inherited;
  align:=c_left;

  cursorPos:=0;
  fontindex:=2;

  color:=green;
  m_TextColor:=black;
  m_SelectTextColor:=blue;
  keepscale:=true;
  scale:=p2(1,1);
  f_iTextPos:=point(0,0);
  fwidth:=80;
  fHeigth:=20;
  fText:=name;


  fTransparent:=true;
  locked:=true;
  enabled:=true;
  selectable:=true;
end;

destructor cLabel.destroy;
begin
  inherited;
end;

procedure cLabel.SetText(s:string);
var
  font:cfont;
  lscale:point2;
  p:cbasepage;
begin
  fText:=s;
  p:=cbasepage(getpage);
  if p=nil then exit;
  if (p.getwidth=0) or (p.getheight=0) then exit;

  font:=GetFont(fontIndex);
  if font<>nil then
  begin
    if align=c_left then
    begin
      lscale:=font.scaleVectorText;
      font.scaleVectorText:=scale;
      boundrect.TopRight.x:=boundrect.BottomLeft.x+font.getwidth(ftext);
      font.scaleVectorText:=lscale;
    end
    else
    begin
      boundrect.TopRight.x:=0;
      lscale:=font.scaleVectorText;
      font.scaleVectorText:=scale;
      boundrect.BottomLeft.x:=boundrect.TopRight.x-font.getwidth(ftext);
      font.scaleVectorText:=lscale;
    end;
    fwidth:=GetiSize(p2(boundrect.TopRight.x,1)).x;
  end;
  if Assigned(fOnSetText) then
    fOnSetText(self);
end;

procedure cLabel.SetHeigth(h:integer);
var
  p:point2;
begin
  fHeigth:=h;
  if fwidth<>0 then
  begin
    if fHeigth<>0 then
    begin
      boundrect.BottomLeft:=p2(0,0);
      p:=GetSize(point(fwidth,fheigth));
      boundrect.TopRight:=p;
    end;
  end;
end;

procedure cLabel.SetWidth(w:integer);
begin
  fWidth:=w;
end;

procedure cLabel.DrawBorder;
var
  m:matrixgl;
begin
  if not Transparent then
  begin
    glgetfloatv(GL_MODELVIEW_MATRIX,@m);
    glgetfloatv(GL_PROJECTION_MATRIX,@m);
    usimpleobjects.drawrect(boundrect, color);
    usimpleobjects.drawBorder(boundrect, textcolor);
  end;
end;

procedure cLabel.DrawSelectText;
begin
  if fSelectText.X > 0 then
  begin
    usimpleobjects.drawrect(fSelectBound, m_SelectTextColor);
  end;
end;

procedure cLabel.DrawCursorPos;
var
  len:single;
  font:cfont;
  m:matrixgl;
  textwidth:single;
begin
  if cursorpos>-1 then
  begin
    if selected then
    begin
      font:=getfont(fontindex);
      len:=font.getWidth(ftext,CursorPos);
      glgetfloatv(GL_MODELVIEW_MATRIX,@m);
      glgetfloatv(GL_PROJECTION_MATRIX,@m);
      glcolor3fv(@blue);
      if align=c_right then
      begin
        textwidth:=font.getwidth(fText);
        len:=boundrect.TopRight.x-textwidth+len;
      end;
      glBegin(GL_LINES);
        glVertex2f(len,fSelectBound.BottomLeft.y);
        glVertex2f(len,fSelectBound.TopRight.y);
      glend;
    end;
  end;
end;

procedure cLabel.drawText;
var
  font: cfont;
begin
  glcolor3fv(@m_TextColor);
  if getmng <> nil then
  begin
    if fText <> '' then
    begin
      font := GetFont(FontIndex);
      // масштабировать текст чтобы сохранять его габариты
      font.scaleVectorText := scale;
      // c_left
      font.OutText(fText, p2(f_TextPos.x+fpos.x,f_TextPos.y+fpos.y), align);
    end;
  end;
end;


procedure cLabel.DrawData;
var
  r:frect;
begin
  DrawBorder;
  DrawSelectText;
  drawText;
  DrawCursorPos;
end;

procedure cLabel.doUpdateWorldSize(sender:tobject);
var
  p2:point2;
  p:cbasepage;
begin
  if parent<>nil then
  begin
    p:=cbasepage(getpage);
    if p.getwidth<>0 then
    begin
      if p.getheight<>0 then
      begin
        p2 := GetSize(point(fwidth, fheigth));
        // пересчитываем границу
        boundrect.TopRight:=p2;
        reEvalScales;
        updateBound;
      end;
    end;
  end;
end;

procedure cLabel.reEvalScales;
var
  p:cbasepage;
  font:cfont;
begin
  // масштаб шрифта
  p:=cbasepage(getpage);
  font:=GetFont(fontindex);
  scale:=font.EvalScale(GetFWidth,GetFHeigth,p.getwidth,p.getheight);
end;

function cLabel.GetCharIndexByPos(p:point2):integer;
var
  font: cfont;
  I: integer;
  len, charWidth, textwidth: single;
  tPos:point2;
begin
  font := GetFont(FontIndex);
  font.scaleVectorText:=scale;
  textwidth:=font.getwidth(fText);
  if align=c_left then
  begin
    tPos:=p2(fpos.x+f_TextPos.x,fpos.y+f_TextPos.y);
    if p.X < tPos.X then
    begin
      result:=0;
      exit;
    end;
    // проверяем левую граниу
    if p.X > tPos.X + textwidth then
    begin
      result:=length(ftext);
      exit;
    end;
    len:=tPos.X;
    for I := 1 to length(ftext) do
    begin
      charWidth := font.getCharWidth(fText[I]);
      // левая граница
      if p.X < len+charWidth/2 then
      begin
        result:= I-1;
        exit;
      end;
      len := len + charWidth;
    end;
    result:=length(ftext);
  end
  else
  // c_right
  begin
    tPos:=p2(fpos.x+f_TextPos.x-textwidth,fpos.y+f_TextPos.y);
    if p.X < tPos.X then
    begin
      result:=0;
      exit;
    end;
    // проверяем левую граниу
    if p.X > tPos.X + textwidth then
    begin
      result:=length(ftext);
      exit;
    end;
    len:=tPos.X;
    for I := 1 to length(ftext) do
    begin
      charWidth := font.getCharWidth(fText[I]);
      // левая граница
      if p.X < len+charWidth/2 then
      begin
        result:= I-1;
        exit;
      end;
      len := len + charWidth;
    end;
    result:=length(ftext);
  end;
end;

procedure cLabel.SelectText(rect: frect);
var
  font: cfont;
  I,j: integer;
  len, charWidth: single;
  tPos:point2;
begin
  font := GetFont(FontIndex);
  font.scaleVectorText:=scale;
  fSelectText := point(-1, -1);

  if align=c_left then
  begin
    tPos:=p2(fpos.x+f_TextPos.x,fpos.y+f_TextPos.y);
    // проверяем правую граниу
    if rect.topright.X < tPos.x then
    begin
      exit;
    end;
    // проверяем левую граниу
    if rect.bottomleft.X > tPos.X + font.getwidth(fText) then
    begin
      exit;
    end;

    len := tPos.X;
    for I := 1 to length(fText) do
    begin
      charWidth := font.getCharWidth(fText[I]);
      // левая граница
      if rect.bottomleft.X < len+charWidth/2 then
      begin
        fSelectText.X := I;
        fSelectBound.BottomLeft.X := len-fpos.x;
        break;
      end;
      len := len + charWidth;
    end;
    j:=i;
    for I := j to length(fText) do
    begin
      charWidth := font.getCharWidth(fText[I]);
      len := len + charWidth;
      // правая граница уже справа от мыши
      if rect.topright.X < len-charWidth/2 then
      begin
        fSelectText.y := I - 1;
        fSelectBound.TopRight.X := len - charWidth-fpos.x;
        break;
      end
      else
      begin
        if I = length(fText) then
        begin
          fSelectText.y := I;
          fSelectBound.TopRight.x:=len-fpos.x;//+font.getCharWidth(fText[i]);
        end;
      end;
    end;
    if fSelectText.X = 0 then
      inc(fSelectText.X);
    if fSelectText.y = length(fText) + 1 then
      dec(fSelectText.y)
  end
  else
  // c_right
  begin
    tPos:=p2(fpos.x-TextRightPos,fpos.y+f_TextPos.y);
    i:=GetCharIndexByPos(p2(rect.BottomLeft.x,rect.BottomLeft.y-tpos.y));
    j:=GetCharIndexByPos(p2(rect.topright.x,rect.TopRight.y-tpos.y));
    fSelectText:=point(i,j);
    BuildSelectRect(i,j);
  end;
end;


function cLabel.TextRightPos:single;
var
  font:cfont;
begin
  font:= GetFont(FontIndex);
  result:=f_TextPos.x+font.getwidth(fText);
end;

procedure cLabel.DoOnMouseMove(p:point2);
var
  rect:frect;
begin
  if enabled then
  begin
    inherited;
    if locked then
    begin
      if fdrag then
      begin
        if fDragBegin.X > p.X then
        begin
          rect.BottomLeft.x := p.X;
          rect.TopRight.x := fDragBegin.X;
        end
        else
        begin
          rect.BottomLeft.x := fDragBegin.X;
          rect.TopRight.x := p.X;
        end;
        if fDragBegin.y > p.y then
        begin
          rect.BottomLeft.y := p.y;
          rect.TopRight.y:= fDragBegin.y;
        end
        else
        begin
          rect.Bottomleft.y := fDragBegin.y;
          rect.topright.y := p.y;
        end;
        SelectText(rect);
      end;
      cchart(chart).needRedraw := true;
    end;
  end;
end;

procedure cLabel.DoOnClick(p:point2);
var
  i:integer;
begin
  inherited;
  if enabled then
  begin
    i:=GetCharIndexByPos(p);
    if i<>cursorpos then
    begin
      cursorpos:=i;
      cchart(chart).needRedraw := true;
    end;
  end;
end;

procedure cLabel.DoOnDblClick(p:point2);
begin
  if enabled then
  begin
    inherited;
    fSelectText:=point(1,Length(ftext));
    BuildSelectRect(fSelectText.x,fSelectText.y);
    cchart(chart).needRedraw := true;
    cchart(chart).fDisableInheritedWndProc:=true;
    cchart(chart).fDisabledMsg:=WM_LBUTTONDBLCLK;
  end;
end;

function cLabel.getChar(key:cardinal):char;
var
  l_ch:cardinal;
begin
  l_ch:=mapvirtualkey(key,MAPVK_VK_TO_CHAR);
  Result:=char(l_ch);
end;

procedure cLabel.DoOnKeyEnter(key:word);
var
  ltext:string;
  ch:char;
  Shiftstate:tshiftstate;
begin
  if enabled then
  begin
    if key=VK_Shift then
    begin
      exit;
    end;
    if key=VK_LEFT then
    begin
      if fcursorpos>0 then
      begin
        cursorpos:=fCursorPos-1;
      end;
      // если нажат Shift
      if GetKeyState(VK_Shift)<0 then
      begin
        if (fselecttext.y=-1) or ((fselecttext.y-cursorpos)>1) then
        begin
          fselecttext.x:=cursorpos+1;
          if fselecttext.Y=-1 then
            fselecttext.y:=cursorpos+1;
        end
        else
        begin
          if fselecttext.y>fselecttext.x then
            fselecttext.y:=cursorpos
          else
          begin
            if fselecttext.y=fselecttext.x then
            begin
              fselecttext.x:=-1;
              fselecttext.y:=-1;
              exit;
            end;
            fselecttext.x:=cursorpos+1
          end;
        end;
        BuildSelectRect(fselecttext.x,fselecttext.y);
      end
      else
      begin
        fselecttext.X:=-1;
        fselecttext.y:=-1;
      end;
      exit;
    end;
    if key=VK_End then
    begin
      if GetKeyState(VK_Shift)<0 then
      begin
        fselecttext.y:=length(ftext);
        fselecttext.x:=cursorpos;
        if fselecttext.x<1 then
          fselecttext.x:=0;
        BuildSelectRect(fselecttext.x,fselecttext.y);
        cchart(chart).needRedraw := true;
      end
      else
      begin
        cursorpos:=length(ftext);
      end;
      exit;
    end;
    if key=VK_Home then
    begin
      if GetKeyState(VK_Shift)<0 then
      begin
        fselecttext.y:=cursorpos;
        fselecttext.x:=0;
        BuildSelectRect(fselecttext.x,fselecttext.y);
        cchart(chart).needRedraw := true;
      end
      else
      begin
        cursorpos:=0;
      end;
      exit;
    end;
    if key=VK_Right then
    begin
      if fcursorpos<length(ftext) then
        cursorpos:=fCursorPos+1;
      // если нажат Shift
      if GetKeyState(VK_Shift)<0 then
      begin
        if (fselecttext.x=-1) or ((cursorpos-fselecttext.x)>=1) then
        begin
          fselecttext.y:=cursorpos;
          if fselecttext.x=-1 then
            fselecttext.x:=cursorpos;
        end
        else
        begin
          if fselecttext.y>fselecttext.x then
            fselecttext.x:=cursorpos+1
          else
          begin
            if fselecttext.y=fselecttext.x then
            begin
              fselecttext.x:=-1;
              fselecttext.y:=-1;
              exit;
            end;
            fselecttext.y:=cursorpos+1
          end;
        end;
        BuildSelectRect(fselecttext.x,fselecttext.y);
      end
      else
      begin
        fselecttext.X:=-1;
        fselecttext.y:=-1;
      end;
      exit;
    end;
    if key=VK_BACK then
    begin
      if fselecttext.X=-1 then
      begin
        if fcursorpos>0 then
        begin
          delete(ftext,fcursorpos,1);
          dec(fcursorpos);
          cchart(chart).needRedraw := true;
        end;
        exit;
      end
      else
      begin
        delete(ftext,fSelectText.x,fSelectText.y-fSelectText.x+1);
        fcursorpos:=fSelectText.x-1;
        fSelectText:=point(-1,-1);
        cchart(chart).needRedraw := true;
        exit;
      end;
    end;
    if key=VK_DELETE then
    begin
      if fselecttext.X=-1 then
      begin
        if cursorpos<length(fText) then
        begin
          delete(ftext,fcursorpos+1,1);
          cchart(chart).needRedraw := true;
          exit;
        end;
      end
      else
      begin
        delete(ftext,fSelectText.x,fSelectText.y-fSelectText.x+1);
        fcursorpos:=fSelectText.x-1;
        fSelectText:=point(-1,-1);
        cchart(chart).needRedraw := true;
        exit;
      end;
    end;
    // Если нажат VK_CONTROL
    if GetKeyState(VK_CONTROL)<0 then
    begin
      // копируем по С
      if (key=67) then
      begin
        ltext := copy(ftext, fSelectText.x, fSelectText.y-fSelectText.x+1);
        clipboard.AsText:=ltext;
      end;
      // вырезаем по X
      if (key=88) then
      begin
        ltext := copy(ftext, fSelectText.x, fSelectText.y-fSelectText.x+1);
        delete(ftext,fSelectText.x,fSelectText.y-fSelectText.x+1);
        clipboard.AsText:=ltext;
        fSelectText:=point(-1,-1);
        cchart(chart).needRedraw := true;
      end;
      exit;
    end
    else
    begin
      if assigned(fKeyDown) then
      begin
        fkeydown(self,key,Shiftstate);
      end;
      ch:=getchar(key);
      InsertChar(ch);
    end;
  end;
end;

procedure cLabel.InsertChar(ch:char);
begin
  if fSelectText.Y>fselectText.x then
  begin
    delete(ftext,fSelectText.x,fSelectText.y-fSelectText.x+1);
    cursorpos:=fSelectText.x-1;
    fSelectText:=point(-1,-1);
  end;
  Insert(ch, ftext, CursorPos+1);
  inc(fcursorpos);
  text:=ftext;
  cchart(chart).needRedraw := true;
end;

procedure cLabel.DoOnMove(p:point2);
begin
  inherited;
end;

procedure cLabel.DoOnBtnUp(p:point2);
var
  rect: trect;
begin
  inherited;
  if (not fDblClick) and (fDragBegin.X=fDragEnd.X) then
  begin
    fSelectText:=point(-1,-1);
    cchart(chart).needRedraw := true;
  end;
end;

procedure cLabel.updateBound;
begin
  fSelectBound.TopRight.y:=boundrect.TopRight.y;
  fSelectBound.BottomLeft.y:=boundrect.BottomLeft.y;
end;

procedure cLabel.BuildSelectRect(left: integer; right: integer);
var
  I: Integer;
  len, textwidth:single;
  font:cfont;
begin
  if left=-1 then exit;
  font:=GetFont(fontindex);
  font.scaleVectorText:=scale;
  len:=f_TextPos.x;
  if align=c_right then
    textwidth:=font.getwidth(fText);
  for I := 1 to right do
  begin
    if left=i then
    begin
      if align=c_Left then
      begin
        fSelectBound.BottomLeft.x:=len;
      end
      else
      begin
        fSelectBound.BottomLeft.x:=len-textwidth;
      end;
    end;
    len:=len+font.getCharWidth(ftext[i]);
    if right=i then
    begin
      if align=c_left then
      begin
        fSelectBound.TopRight.x:=len;
        exit;
      end
      else
      begin
        fSelectBound.TopRight.x:=len-textwidth;
        exit;
      end;
    end;
  end;
end;

procedure cLabel.DoOnExit;
begin
  inherited;
  fSelectText:=point(-1,-1);
  CursorPos:=0;
  cchart(chart).needRedraw := true;
  fdrag:=false;
end;

procedure cLabel.DoOnMouseLeave;
begin
  inherited;
end;

procedure cLabel.SetCursPos(i:integer);
begin
  fCursorPos:=i;
  if cChart(chart)<>nil then
  begin
    cChart(chart).needRedraw:=true;
  end;
end;

procedure cLabel.SetTransparent(b:boolean);
begin
  fTransparent:=b;
  if cChart(chart)<>nil then
  begin
    cChart(chart).needRedraw:=true;
  end;
end;

function cLabel.GetTextHeigth:single;
//var
//  font:cFont;
begin
  //font:=GetFont(fontindex);
  //result:=GetSize(point(1,font.getPixelHeight)).y;
  result:=boundrect.TopRight.y-boundrect.BottomLeft.y;
end;

function cLabel.GetTextWidth:single;
var
  font:cFont;
  lScale:point2;
begin
  font:=GetFont(fontindex);
  if font<>nil then
  begin
    lScale:=font.scaleVectorText;
    font.scaleVectorText:=scale;
    result:=font.getWidth(ftext);
    font.scaleVectorText:=lscale;
  end;
end;


end.

