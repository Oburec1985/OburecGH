
unit uObjFrameListener;

interface
uses
  uFrameListener, messages, classes, windows, uCommonTypes, uPage, uTrend, uAxis,
  uPoint, uCommonMath, types, opengl, uOglExpFunc, uChartEvents, udrawobj,
  ucursors, controls, uMarkers, usimpleobjects, uBasePage, uBaseObj;

type
  // поиск активных объектов на странице. События doOnClick для объектов и таскание объектов
  // Блокируется фреймом cClickFrListener если найдена точка на тренде!!!
  cObjFrListener = class(cFrameListener)
  public
  protected
    b_overcursor:boolean;
    cursowner:integer;
    // чувствительность к выделению мышкой
    fsize:integer;
    curobj, newObj:cMoveObj;
    mousePos:point2;
    fbeginDrag,fEndDrag:tpoint;
    fDrag:boolean;
    // отклонение положения выделенного объекта от курсора мыши на момент выделения
    delta:point2;

    curpage:cbasepage;
    // координаты мыши на странице
    m_p:tpoint;
    // координаты m_p в нормализованных координатах страницы -1..1
    m_fp:point2;
    m_OverObj:cMoveObj;
  protected
    procedure init(p_data:tobject; p_name:string);override;
  protected
    procedure invalidate;
    procedure setselectsize(s:integer);
    function OverObj(ax:caxis;p:point2):cMoveObj;overload;
    function OverObj(p:tpoint):cMoveObj;overload;
    procedure setactive(b:boolean);override;
    procedure createevents;
    procedure destroyevents;
    procedure DoDraw(sender:tobject);
  public
    procedure WndProc(var msg:tmessage;var mouse:smousestruct);override;
  end;


implementation
uses
  uchart;

procedure cObjFrListener.init(p_data:tobject; p_name:string);
begin
  inherited;
  b_overcursor:=false;
  cursowner:=cChart(data).GenCursOwnerName;
  //createevents;
end;

procedure cObjFrListener.invalidate;
begin
  cchart(data).needRedraw:=true;
end;

procedure cObjFrListener.WndProc(var msg:tmessage;var mouse:smousestruct);
var
  ax:caxis;
  page:cdrawobj;
  curs:integer;

  fp:point2;
begin
  page:=cchart(data).activepage;
  if page=nil then
    exit;
  if not (page is cbasepage) then
    exit;

  case msg.Msg of
    wm_mousemove:
    begin
      // тащим выделенный объект
      if fdrag then
      begin
        fEndDrag:=mouse.iPos_inv;
        ax:=nil;
        page:=curpage;
        if curobj.parent<>page then
        begin
          ax:=caxis(curobj.GetParentByClassName('cAxis'));
          if ax<>nil then
            fp:=ax.p2iTop2(mouse.iPos_inv);
        end
        else
          fp:=cpage(page).p2itop2(mouse.iPos_inv);
        // правка от 30.07.24
        // delta - отклонение объекта от мыши на момент выделения. Ставим объект в новые координаты
        // но сохраняем начальное смещение
        curobj.Position:=p2(fp.x-delta.x, fp.y-delta.y);
        curobj.DoOnMove(mouse.iPos_inv);
      end
      else
      // выделяем объекты
      begin
        newObj:=OverObj(mouse.iPos_inv);
        if curobj<>nil then
        begin
          if curobj<>newobj then
            curobj.DoOnMouseLeave;
        end;
        curobj:=newObj;
        if curobj<>nil then
        begin
          curobj.DoOnMouseMove(mouse.iPos_inv);
          b_overCursor:=true;
          if curobj<>cchart(data).selected then
          begin
            curs:=crSizeNWSE;
            cchart(data).setcursor(curs, cursowner);
            cchart(data).setcursor(crSize, cursowner);
          end;
        end
        else
        begin
          b_overCursor:=false;
          curs:=crDefault;
          cchart(data).setcursor(curs, cursowner);
          cchart(data).setcursor(crDefault, cursowner);
        end;
      end;
      invalidate;
    end;
    WM_LBUTTONDOWN:
    begin
      if b_overcursor then
      BEGIN
        cchart(data).setcursor(crDefault, cursowner);
        if cchart(data).selected<>nil then
        begin
          if curobj<>cchart(data).selected then
          begin
            if cchart(data).selected is cMoveObj then
            begin
              cMoveObj(cchart(data).selected).doOnExit;
            end;
          end;
        end;
        cchart(data).selected:=Curobj;
        // если объект не заблокирован то двигаем
        if not curobj.locked then
        begin
          fDrag:=true;
          fbeginDrag:=mouse.iPos_inv;;
          cchart(data).setcursor(crSize, cursowner);

          if curobj.parent<>curpage then
          begin
            ax:=caxis(curobj.GetParentByClassName('cAxis'));
            fp:=ax.p2iTop2(mouse.iPos_inv);
          end
          else
            fp:=cpage(page).p2itop2(mouse.iPos_inv);
          delta:=p2(fp.x - curobj.Position.x,
                    fp.y - curobj.Position.y);
        end;
        curobj.DoOnClick(mouse.iPos_inv);
      END
      else
      begin
        if cchart(data).selected<>nil then
        begin
          if cchart(data).selected is cMoveObj then
          begin
            cMoveObj(cchart(data).selected).DoOnExit;
          end;
        end;
      end;
    end;
    WM_LBUTTONUP:
    begin
      if fdrag then
      begin
        if curobj<>nil then
        begin
          if assigned(cchart(data).OnObjEndDrag) then
            cchart(data).OnObjEndDrag(curobj);
        end;
      end;
      fdrag:=false;
      cchart(data).setcursor(crDefault, cursowner);
      if curobj<>nil then
        curobj.DoOnBtnUp(mouse.iPos_inv);
    end;
    WM_KEYUP:
    // при отпускании клавиши контрол сбрасывается
    // флаг необходиvjcnb рисовать область выделения
    begin

    end;
    WM_KEYDown:
    // при отпускании клавиши контрол сбрасывается
    // флаг необходиvjcnb рисовать область выделения
    begin
      if cchart(data).selected<>nil then
      begin
        if cchart(data).selected is cMoveObj then
          cMoveObj(cchart(data).selected).DoOnKeyEnter(msg.WParam);
      end;
    end;
    CN_KEYDown:
    // при отпускании клавиши контрол сбрасывается
    // флаг необходиvjcnb рисовать область выделения
    begin
      {if cchart(data).selectobj<>nil then
      begin
        if cchart(data).selectobj is cMoveObj then
          cMoveObj(cchart(data).selectobj).DoOnKeyEnter(msg.WParam);
      end;}
    end;
    WM_LBUTTONDBLCLK:
    begin
      if curobj<>nil then
      begin
        curobj.DoOnDblClick(mouse.iPos_inv);
      end;
    end;
    WM_Size:
    begin
    end;
  end;
end;

procedure cObjFrListener.setselectsize(s:integer);
begin

end;

// возвращает - нужно ли продолжать перечисление
function OverObjEnumerator(obj:cBaseObj; data:pointer):boolean;
var
  page:cbasepage;
  bound:frect;
  // область выделения в координатах чарта
  dist :point2;
  mindist:single;
  ax:caxis;
  chart:cchart;
  fp:point2;
  b:boolean;
begin
  result:=true;
  cObjFrListener(data).m_OverObj:=nil;
  if not (obj is cmoveobj) then exit;
  if not cmoveobj(obj).enabled then exit;

  ax:=nil;
  page:=cObjFrListener(data).curpage;
  fp:=cObjFrListener(data).m_fp;

  if obj.parent<>page then
  begin
    ax:=caxis(obj.GetParentByClassName('cAxis'));
    if ax=nil then
      exit;
    fp:=ax.p2iTop2(cObjFrListener(data).m_p);
  end;

  bound:=cDrawObj(obj).getbound;
  chart:=cchart(cObjFrListener(data).data);
  dist:=cpage(page).PixelSizeToTrend(point(chart.selectSize,chart.selectSize),ax);
  if bound.BottomLeft.x-dist.x<fp.x then
  begin
    if bound.topright.x+dist.x>fp.x then
    begin
      if bound.BottomLeft.y-dist.y<fp.y then
      begin
        if bound.topright.y+dist.y>fp.y then
        begin
          if cMoveObj(obj).selectable then
          begin
            mindist:=max(dist.x, dist.y, b);
            //page.Point2ToTrend();
            if cMoveObj(obj).TestObj(fp, mindist) then
            begin
              result:=false;
              cObjFrListener(data).m_OverObj:=cMoveObj(obj);
              exit;
            end
            else
              cObjFrListener(data).m_OverObj:=nil;
          end;
        end;
      end;
    end;
  end;
end;

function cObjFrListener.OverObj(p:tpoint):cMoveObj;
var
  obj:cDrawObj;
begin
  result:=nil;
  curpage:=cchart(data).activepage;
  // координаты на чарте
  m_p:=p;
  m_fp:=curpage.p2iTop2(p, curpage.m_view, false);
  curpage.EnumGroupMembers(OverObjEnumerator, self);
  result:=m_OverObj;
end;

function cObjFrListener.OverObj(ax:caxis;p:point2):cMoveObj;
var
  obj:cDrawObj;
  // область выделения в координатах чарта
  dist:single;
  i:integer;
  page:cpage;
  bound:frect;
begin
  result:=nil;
  for I := 0 to ax.childCount - 1 do
  begin
    obj:=cdrawobj(ax.getChild(i));
    if obj is cMoveObj then
    begin
      bound:=obj.getbound;
      if bound.BottomLeft.x<p.x then
      begin
        if bound.topright.x>p.x then
        begin
          if bound.BottomLeft.y<p.y then
          begin
            if bound.topright.y>p.y then
            begin
              page:=cpage(ax.parent.parent);
              dist:=page.PixelSizeToTrend(point(cChart(data).selectSize,1),
                                          page.activeAxis).x;
              if cMoveObj(obj).selectable then
              begin
                if cMoveObj(obj).TestObj(p, dist) then
                begin
                  result:=cMoveObj(obj);
                  exit;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure cObjFrListener.setactive(b:boolean);
begin
  inherited;
  if not b then
    cchart(data).setcursor(crDefault, cursowner);
end;

procedure cObjFrListener.createevents;
begin
  cChart(data).OBJmNG.Events.AddEvent('cObjFrListener_OnDraw',e_onDraw,doDraw);
end;

procedure cObjFrListener.destroyevents;
begin
  cChart(data).OBJmNG.Events.removeEvent(doDraw,e_onDraw);
end;

procedure cObjFrListener.doDraw(sender:tobject);
var
  dist:single;
  page:cpage;
  ac:caxis;
  r:frect;
begin
  page:=cpage(cchart(data).activePage);
  dist:=page.PixelSizeToTrend(point(cChart(data).selectSize,1),
                              page.activeAxis).x;
  page.setDrawObjVP;
  page.activeAxis.loadstate;
  r.BottomLeft.x:=mousePos.x-dist;
  r.BottomLeft.y:=mousePos.y-dist;
  r.TopRight.x:=mousePos.x+dist;
  r.TopRight.y:=mousePos.y+dist;
  usimpleobjects.drawrect(r,red);
end;

end.
