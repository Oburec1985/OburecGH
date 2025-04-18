// ��������� � ������� ��������� ���������������� ��������� � ������ ����
unit uChartClickFrListener;

interface
uses
  uFrameListener, messages, classes, windows, uCommonTypes, uPage,
  uTrend, uAxis,
  uPoint, uCommonMath, types, opengl, uOglExpFunc, uChartEvents, udrawobj,
  ucursors, controls, math, uLogFile, uBasePage;

type
  cClickFrListener = class(cFrameListener)
  public
    selectMode:boolean;
    // �������������� �������
    Rect:frect;
    DrawSelectRect,
    moveCamera:boolean;
  protected
    cursowner:integer;  
    overaxis:boolean;
    selectAxis:integer;

    iStartRect:tpoint;
    iEndRect:tpoint;

    normalWndSelSize:single;
    chrt:tobject;
  protected
    function gethandle:thandle;
    function getpage:cpage;
    function getObj(i:integer):cdrawobj;
    function heigth:integer;
    function width:integer;
    procedure invalidate;
    procedure init(p_data:tobject; p_name:string);override;
    // ���������� ������� ������ ����� �� x
    function FindPoint(p2i:tpoint):selectpoint;
    function CheckPoint(p2i:tpoint):tpoint;
    // ����� ����� �� ��� �����
    function FindPoint_lg(p2i:tpoint):selectpoint;
    // ���������� ����� � �������� ����������� ����� �����
    function ActiveObj:cdrawobj;
    // ���� ������ ����� �� ���������� ��� ����� nil
    function Activetrend:ctrend;
    // ������������� ������ � �������� � ��������� �����
    function PixelSizeToTrend(x:integer):single;
    // ���������� ������������� �������������
    procedure ProcDrawSelectRect(sender:tobject);
    // ����������� ���������� �����
    procedure MovePoints(const mouse:smousestruct);
  public
    procedure WndProc(var msg:tmessage;var mouse:smousestruct);override;
  end;

implementation
uses uChart;

procedure cClickFrListener.init(p_data:tobject; p_name:string);
begin
  inherited;
  cursowner:=cchart(data).GenCursOwnerName;
  selectMode:=true;
  chrt:=p_data;
  cchart(p_data).OBJmNG.Events.AddEvent('drawSelectRect', e_onDraw, ProcDrawSelectRect);
end;

procedure cClickFrListener.invalidate;
begin
  cchart(data).needRedraw:=true;
end;

function cClickFrListener.heigth:integer;
begin
  result:=cchart(data).Height;
end;

function cClickFrListener.width:integer;
begin
  result:=cchart(data).width;
end;

function cClickFrListener.gethandle:thandle;
begin
  result:=cchart(data).Handle;
end;

function cClickFrListener.getpage:cpage;
begin
  result:=cpage(cchart(data).activepage);
end;

function cClickFrListener.getObj(i:integer):cdrawobj;
begin
  result:=cdrawobj(getpage.activeAxis.getChild(i));
end;

function cClickFrListener.Activetrend:ctrend;
var
  obj:cdrawobj;
begin
  obj:=activeobj;
  if (obj<>nil) and (obj is ctrend) then
    result:=ctrend(obj)
  else
    result:=nil;
end;

procedure cClickFrListener.WndProc(var msg:tmessage;var mouse:smousestruct);
var
  p2i, checkp:tpoint;
  ltrend:ctrend;
  obj:ctrend;
  page:cdrawobj;
  I, low,hi, axPos: Integer;
  axis:caxis;
  lrect:frect;
  b:boolean;
  cp, bp:cBeziePoint;
  fr:cframelistener;
  lp2:point2d;
begin
  if getflag(c_blockAllWM) then exit;
  page:=getpage;
  if page=nil then
    exit;
  if not cbasepage(page).isCarrier then
    exit;
  ltrend:=Activetrend;
  if ltrend=nil then
  begin
    // ���� ����� ������ �������� ��� ������������,
    // ��� ���� ������� ����� � ������� ��������������� ������� ������
    // ����� �������������� ����� ������ ��������
    fr:=cchart(data).frList.GetFrame('cObjFrListener');
    if (fr.active=false) and (selectmode) then
      fr.active:=true;
  end;

  case msg.Msg of
    wm_mousemove:
    begin
      if drawselectrect then
      begin
        rect.TopRight:=mouse.activeAxisPos;
        invalidate;
      end;
      // ������������ �����
      if SelectMode then
      begin
        if ltrend<>nil then
        begin
          if ltrend.selectCount<>0 then
            MovePoints(mouse)
          else
          // �������� ��� ������ ������ �� �����
          begin
            if ltrend.parent=nil then
              exit;
            if caxis(ltrend.parent).lg then
            begin
              //FindPoint_lg(p2i)
            end
            else
            begin
              checkp:=checkpoint(mouse.iPos_inv);
              if checkp.x<>-1 then
              begin
                cchart(data).setcursor(crCross, cursowner);
                exit;
              end
              else
              begin
                cchart(data).setcursor(crDefault, cursowner)
              end;
            end;
          end;
        end;
      end;
      // �������� ������ ���
      overaxis:=false;
      if page is cpage then
      begin
        for I := 0 to cpage(page).getAxisCount - 1 do
        begin
          axPos:=cpage(page).getaxis(i).iaxispos+cpage(page).bound.Left;
          hi:=axPos+cchart(data).selectsize;
          low:=axPos-cchart(data).selectsize;
          b:=((mouse.ipos.x>=cpage(page).bound.Left) and (mouse.ipos.x<=cpage(page).bound.Right) and
             ((mouse.iPos_inv.y>=cpage(page).bound.Bottom) and (mouse.iPos_inv.y<=cpage(page).bound.Top)));
          if b then
          begin
            if (mouse.ipos.X<=hi) and (mouse.ipos.X>=low) then
            begin
              overaxis:=true;
              selectaxis:=i;
              break;
            end;
          end;
        end;
        if overaxis then
          cchart(data).setcursor(crSize, cursowner)
        else
          cchart(data).setcursor(crDefault, cursowner);
        if moveCamera then
        begin
          lp2:=DecP2d(cpage(page).activeAxis.min,mouse.activeaxisstrafe);
          lRect.BottomLeft:=p2(lp2.x,lp2.y);
          lp2:=DecP2d(cpage(page).activeAxis.max,mouse.activeaxisstrafe);
          lRect.TopRight:=p2(lp2.x,lp2.y);
          cpage(page).ZoomfRect(lrect);
          mouse.activeAxisPos.x:=mouse.activeAxisPos.x-mouse.activeaxisstrafe.x;
          mouse.activeAxisPos.y:=mouse.activeAxisPos.y-mouse.activeaxisstrafe.y;
          invalidate;
        end;
      end;
    end;
    WM_LBUTTONDOWN:
    begin
      Windows.SetFocus(gethandle);
      p2i:=mouse.iPos_inv;
      // ������������� ������� ���� ����� �������
      if GetKeyState(VK_CONTROL)<0 then
      begin
        page:=cchart(data).activepage;
        if page is cpage then
        begin
          if cpage(page).MouseInPage(mouse.iPos_inv) then
          begin
            DrawSelectRect:=true;
            iStartRect.y:=heigth-HIWORD(msg.Lparam);
            iStartRect.x:=LOWORD(msg.LParam);
            rect.BottomLeft:=mouse.activeAxisPos;
            rect.TopRight:=rect.BottomLeft;
            invalidate;
          end;
        end;
      end;
      if ltrend<>nil then
      begin
        ltrend.deselectAll;
        // ��������� ����� ��� ��������� �����
        if SelectMode then
        begin
          if ltrend.parent<>nil then
          begin
            if caxis(ltrend.parent).lg then
              FindPoint_lg(p2i)
            else
              FindPoint(p2i);
          end;
        end;
      end;
      if overaxis then
      begin
        Axis:=cpage(page).getaxis(selectAxis);
        cpage(page).activeAxis:=axis;
      end;
      if GetKeyState(VK_Shift)<0 then
      begin
        // ���� ��������� ������� �� �� ��������
        moveCamera:=true;
      end;
      invalidate;
    end;
    WM_RBUTTONUP:
    begin
      // ��������� ���� ���������� �����
      if ltrend<>nil then
      begin
        ltrend.changetype;
        invalidate;
      end;
    end;
    WM_LBUTTONUP:
    begin
      moveCamera:=false;
      if GetKeyState(VK_CONTROL)<0 then // ���� ����� VK_CONTROL
      begin
        if drawselectrect then
        begin
          // ���������� ������� ������������� �����
          if msg.Lparam<0 then
            exit;
          iendRect.y:=HIWORD(msg.Lparam);
          iendRect.x:=LOWORD(msg.LParam);
          if (mouse.DragBegginPos.x<mouse.iPos.x) and
             (mouse.DragBegginPos.y<mouse.ipos.y) then
          begin
            // ��������� � ��� ������� rect
            axis:=cpage(page).activeAxis;
            //logMessage('uChartClickFrListener.RectToLogScale');
            RectToLogScale(rect,p2d(axis.min.x,axis.min.y),p2d(axis.max.x,axis.max.y),cpage(page).lgx,axis.Lg);
            //logMessage('uChartClickFrListener.cpage(page).ZoomfRect(rect)');
            cpage(page).ZoomfRect(rect);
            cchart(data).doZoomEvent(data, false);
          end
          else
          begin
            cpage(page).Normalise;
            cchart(data).doZoomEvent(data, true);
          end;

        end;
      end;
      DrawSelectRect:=false;
    end;
    WM_KEYUP: // ��� ���������� ������� ������� ������������
              // ���� ��������vjcnb �������� ������� ���������
    begin
      if integer(msg.WParam)=VK_CONTROL then
      begin
        // ���� ��������� ������� �� �� ��������
        DrawSelectRect:=false;
      end;
      if integer(msg.WParam)=VK_Shift then
      begin
        // ���� ��������� ������� �� �� ��������
        moveCamera:=false;
      end;
    end;
    WM_KEYDown:
    begin
      if integer(msg.WParam)=VK_insert then
      begin
        if ltrend<>nil then
        begin
          cp:=ltrend.insertpoint(mouse.activeAxisPos.x);
          if cp.UniqIndex>0 then
          begin
            bp:=ltrend.getPoint(cp.UniqIndex-1);
            if bp.right.x>cp.point.x then
            begin
              bp.right.x:=bp.point.x+(cp.point.x-bp.point.x)/2;
            end;
          end;
          if cp.UniqIndex<ltrend.count-1 then
          begin
            bp:=ltrend.getPoint(cp.UniqIndex+1);
            if bp.left.x<cp.point.x then
            begin
              bp.left.x:=cp.point.x+(bp.point.x-cp.point.x)/2;
            end;
          end;
          cchart(chrt).doOnInsertPoint(ltrend, cp);
          invalidate;
        end;
      end;
    end;
  end;
end;

function cClickFrListener.FindPoint_lg(p2i:tpoint):selectpoint;
var
  i,low,hi:integer;
  // ��� ���� ���������� ������� �� x � y
  p2_y, p2_x:point2d;
  p2:point2;

  page:cpage;
  ltrend:ctrend;
  size:point2;
  fr:cframelistener;
  trendY:single;
begin
  result:=nil;
  ltrend:=Activetrend;
  if ltrend<>nil then
  begin
    page:=getpage;
    // ������� ��� ���� ��������� �� �������� ���
    p2_y:=page.yiminmax_ToTrend(point(p2i.y-cchart(data).selectSize,
                            p2i.y+cchart(data).selectSize),
                            page.activeAxis);
    p2_x:=page.ximinmax_ToTrend(point(p2i.x-cchart(data).selectSize,
                            p2i.x+cchart(data).selectSize),
                            page.activeAxis);
    p2:=page.p2itotrend(p2i,page.activeAxis);

    low:=ltrend.GetLowInd(p2_x.x);
    hi:=ltrend.GetHiInd(p2_x.y);
    if (low<0) or (hi=0) then exit;
    for i:=low to hi do
    begin
      trendY:=ltrend.getY_log(i);
      if (trendY>p2_y.x)and (trendY<p2_y.y) then
      begin
        if (ltrend.GetP2(i).x>p2_x.x)and (ltrend.GetP2(i).x<p2_x.y) then
        begin
          // ��� ���������� ������� - corner
          ltrend.NeedRecompile:=true;
          result:=ltrend.selectvertex(i,c_point);
        end;
      end;
    end;
  end;
  fr:=cchart(data).frList.GetFrame('cObjFrListener');
  if result<>nil then
  begin
    fr.active:=false;
  end
  else
  begin
    fr.active:=true;
  end;
end;

function cClickFrListener.CheckPoint(p2i: tpoint): tpoint;
var
  ltrend:ctrend;
  p2_,p,
  // ������ ��������� ������� �� �������� ������ ������� � ����������� ������
  size:point2;
  pi:tpoint;
  bp:cBeziePoint;
  page:cpage;
  low, hi, i:integer;
begin
  result.x:=-1;
  ltrend:=Activetrend;
  if ltrend<>nil then
  begin
    page:=getpage;
    p2_:=page.p2iToTrend(p2i,page.activeAxis);
    p:=p2_;
    pi.x:=cchart(data).selectsize;
    pi.y:=cchart(data).selectsize;
    p2_.x:=p.x - size.x;
    p2_.y:=p.x + size.x;
    low:=ltrend.GetLowInd(p2_.x);
    hi:=ltrend.GetHiInd(p2_.y);
    for i:=low to hi do
    begin
      bp:=cBeziePoint(ltrend.getpoint(i));
      pi:=page.trendptop2i(bp.point);
      if abs(p2i.y - pi.y)<cchart(data).selectSize then
      begin
        if abs(p2i.x - pi.x)<cchart(data).selectSize then
        begin
          // ��� ���������� ������� - corner
          result.x:=i;
          Result.y:=c_point;
          exit;
        end;
        // ��������� ������������ ��������
        if ltrend.smooth then
        begin
          if bp.smooth then
          begin
            pi:=page.TrendPtoP2i(bp.left);
            if abs(p2i.y - pi.y)<cchart(data).selectSize then
            begin
              if abs(p2i.x - pi.x)<cchart(data).selectSize then
              begin
                result.x:=i;
                Result.y:=c_left;
                exit;
              end;
            end;
            pi:=page.trendptop2i(bp.right);
            if abs(p2i.y - pi.y)<cchart(data).selectSize then
            begin
              if abs(p2i.x - pi.x)<cchart(data).selectSize then
              begin
                result.x:=i;
                Result.y:=c_right;
                exit;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;


// ���������� ������� ������ ����� �� x
function cClickFrListener.FindPoint(p2i:tpoint):selectpoint;
var i,low,hi:integer;
    p2_,p:point2;
    pi:tpoint;
    bp:cBeziePoint;
    page:cpage;
    ltrend:ctrend;
    size:point2;
    fr:cframelistener;
begin
  result:=nil;
  ltrend:=Activetrend;
  if ltrend<>nil then
  begin
    page:=getpage;
    p2_:=page.p2iToTrend(p2i,page.activeAxis);
    p:=p2_;
    pi.x:=cchart(data).selectsize;
    pi.y:=cchart(data).selectsize;
    size:=getpage.PixelSizeToTrend(pi, page.activeAxis);
    p2_.x:=p.x - size.x;
    p2_.y:=p.x + size.x;
    low:=ltrend.GetLowInd(p2_.x);
    hi:=ltrend.GetHiInd(p2_.y);
    if (low<0) or (hi=0) then exit;
    for i:=low to hi do
    begin
      bp:=cBeziePoint(ltrend.getpoint(i));
      pi:=page.trendptop2i(bp.point);
      if abs(p2i.y - pi.y)<cchart(data).selectSize then
      if abs(p2i.x - pi.x)<cchart(data).selectSize then
      begin
        // ��� ���������� ������� - corner
        result:=ltrend.selectvertex(i,c_point);
      end;
      // ��������� ������������ ��������
      if ltrend.smooth then
      begin
        if bp.smooth then
        begin
          pi:=page.TrendPtoP2i(bp.left);
          if abs(p2i.y - pi.y)<cchart(data).selectSize then
          if abs(p2i.x - pi.x)<cchart(data).selectSize then
          begin
            result:=ltrend.selectvertex(i,c_left);
          end;
          pi:=page.trendptop2i(bp.right);
          if abs(p2i.y - pi.y)<cchart(data).selectSize then
          if abs(p2i.x - pi.x)<cchart(data).selectSize then
          begin
            result:=ltrend.selectvertex(i,c_right);
          end;
        end;
      end;
    end;
  end;
  fr:=cchart(data).frList.GetFrame('cObjFrListener');
  if result<>nil then
  begin
    fr.active:=false;
  end
  else
  begin
    fr.active:=true;
  end;
end;

function cClickFrListener.ActiveObj:cdrawobj;
begin
  result:=cchart(data).selected;
end;

// ��������� ���������� ����� � ���������� � ���������� �����
function cClickFrListener.PixelSizeToTrend(x:integer):single;
var
  page:cpage;
  axis:caxis;
  l_p2:point2;
  p:tpoint;
  y,val:single;
  ival:integer;
  b:boolean;
begin
  page:=getpage;
  axis:=page.activeAxis;
  l_p2:=p2(axis.getdx,axis.getdy);
  val:=uCommonMath.min(l_p2.x,l_p2.y,b);
  p.x:=width;  p.y:=heigth;
  ival:=uCommonMath.min(width,heigth);
  result:=x*val/ival;
end;

Procedure cClickFrListener.ProcDrawSelectRect(sender:tobject);
const Colors:array [0..19] of single = (0.2,0.2,0.2,0.1,  0.2,0.2,0.2,0.1,
                                        0.2,0.2,0.2,0.1,  0.2,0.2,0.2,0.1,
                                        0.2,0.2,0.2,0.1 );
var
  RectData:Array [0..4] of point2;
  a:caxis;
  p:cpage;
begin
  if DrawSelectRect then
  begin
    p:=getpage;
    a:=p.activeAxis;
    if a=nil then
    begin
      if p.getAxisCount<>0 then
      begin
        a:=p.getaxis(0);
        p.activeAxis:=a;
      end
      else
        exit;
    end;
    getpage.setDrawObjVP;
    a.loadstate;
    RectData[0].x:=Rect.BottomLeft.x;RectData[0].y:=Rect.BottomLeft.y;
    RectData[1].x:=Rect.BottomLeft.x;RectData[1].y:=Rect.TopRight.y;
    RectData[2].x:=Rect.TopRight.x;RectData[2].y:=Rect.TopRight.y;
    RectData[3].x:=Rect.TopRight.x;RectData[3].y:=Rect.BottomLeft.y;
    RectData[4].x:=Rect.BottomLeft.x;RectData[4].y:=Rect.BottomLeft.y;
    glLineStipple (1, $F0F0);
    // ������ ��� ������������� ---------------------------------------
    glEnable (GL_LINE_STIPPLE);
    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(4, GL_FLOAT, 0,@Colors[0]);    // ��������� �� ������ ������
    glEnableClientState(GL_VERTEX_ARRAY) ;        // ���. ����� ���������
    glVertexPointer(2, GL_FLOAT, 0,@RectData[0]); // ��������� �� ������ ������
    glDrawArrays(GL_LINE_STRIP,0,5);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    //-----------------------------------------------------------------
    glDisable (GL_LINE_STIPPLE);
  end;
end;

procedure cClickFrListener.MovePoints(const mouse:smousestruct);
var i:integer;
    ltrend:ctrend;
    sp:selectpoint;
    p:cbeziepoint;
    point:point2;
    pos:point2;
    page:cpage;
    range, lgrange, lgmin:single;
begin
  if not mouse.mousedown then exit;
  page:=getpage;
  ltrend:=Activetrend;
  if ltrend.parent<>page.activeAxis then
  begin
    if ltrend.parent <>nil then
      pos:=page.Point2ToTrend(mouse.pos, caxis(ltrend.parent));
  end
  else
    pos:=mouse.activeAxisPos;
  if ltrend=nil then exit;
  for I := 0 to ltrend.selectcount - 1 do
  begin
    sp:=ltrend.GetSelectPoint(i);
    p:=ltrend.GetSelected(i);
    case sp.t of
      c_point:
      begin
        point:=pos;
      end;
      c_left:
      begin
        point:=pos;
      end;
      c_right:
      begin
        point:=pos;
      end;
    end;
  end;
  //DoSetPoint(p,ltrend.m_trend.m_selectedPoints[i]);
  if caxis(ltrend.parent).lg then
  begin
    range:=caxis(ltrend.parent).max.y-caxis(ltrend.parent).min.y;
    // ��������� � ������������� ���������� ��� ��� ���
    pos.y:=(pos.y-caxis(ltrend.parent).min.y)/range;
    lgmin:=log10(caxis(ltrend.parent).min.y);
    lgrange:=log10(caxis(ltrend.parent).max.y)-lgmin;
    pos.y:=pos.y*lgrange+lgmin;
    pos.y:=power(10,pos.y);
    point:=pos;
  end;
  ltrend.SetPoint(point,sp);
  invalidate;
end;





end.
