unit uPageFrameListener;

interface
uses
  uFrameListener, messages, classes, windows, uCommonTypes, uPage, uTrend, uAxis,
  uPoint, uCommonMath, types, opengl, uOglExpFunc, uChartEvents, udrawobj,
  ucursors, controls, sysutils, uBasePage;

type
  // ����� ������� ��������, ������ � ��������� �������� (��������������)
  cPageFrListener = class(cFrameListener)
  public
  protected
    // bound �������� �� ������ ������ ��������������
    beginmoverect:trect;
    b_OnPoint, // ������ ��� ������
    b_Resize, b_move:boolean;
    b_ResizePage:integer;
    cursowner:integer;
    // ���������������� � ��������� ������
    fsize:integer;
    curPage:cbasepage;
    snapPix:integer;
  protected
    procedure init(p_data:tobject; p_name:string);override;
  protected
    procedure invalidate;
    procedure createevents;
    procedure Destroyevents;
    procedure Test(sender:tobject);
    procedure ResizePage(var mouse:smousestruct);
    function findPage(var mouse:smousestruct):cbasePage;
    procedure setselectsize(s:integer);
    // �������� ��� ������ ��� �������� ��������
    // snap - ���������������� �����, res - ������� � ������� ���������
    function OverEdge(page:cBasePage;p:tpoint;snap:integer;var borderid:integer;var res:tpoint):boolean;
    function GetNearestBoundWithSnap(rect:trect;snap:integer):trect;
  public
    procedure WndProc(var msg:tmessage;var mouse:smousestruct);override;
  end;

implementation
uses
  uchart;

const
  c_None = -1;
  c_TopLeft = 1;
  c_TopRight = 2;
  c_Top = 3;
  c_Left = 4;
  c_BottomLeft = 5;
  c_BottomRight = 6;
  c_Bottom = 7;
  c_Right = 8;

procedure cPageFrListener.init(p_data:tobject; p_name:string);
begin
  inherited;
  snapPix:=10;
  b_ResizePage:=c_none;
  b_Resize:=false;
  fsize:=10;
  cursowner:=cChart(data).GenCursOwnerName;
  createevents;
end;

procedure cPageFrListener.invalidate;
begin
  cchart(data).needRedraw:=true;
end;

procedure cPageFrListener.ResizePage(var mouse:smousestruct);
var
  rect:trect;
begin
  rect:=curpage.bound;
  case b_ResizePage of
    c_TopLeft:
    begin
      rect.TopLeft:=mouse.iPos_inv;
    end;
    c_TopRight:
    begin
      rect.Top:=mouse.iPos_inv.Y;
      rect.right:=mouse.iPos_inv.x;
    end;
    c_BottomLeft:
    begin
      rect.Bottom:=mouse.iPos_inv.Y;
      rect.left:=mouse.iPos_inv.x;
    end;
    c_BottomRight:
    begin
      rect.BottomRight:=mouse.iPos_inv;
    end;
    c_Right:
    begin
      rect.Right:=mouse.iPos.x;
    end;
    c_Left:
    begin
      rect.left:=mouse.iPos.x;
    end;
    c_Top:
    begin
      rect.Top:=mouse.iPos_inv.y;
    end;
    c_Bottom:
    begin
      rect.Bottom:=mouse.iPos_inv.y;
    end;
  end;
  rect:=GetNearestBoundWithSnap(rect,snapPix);    
  curpage.Bound:=rect;
  invalidate;
end;

function cPageFrListener.findPage(var mouse:smousestruct):cbasePage;
var
  p:cbasepage;
  i:integer;
begin
  result:=nil;
  for I := 0 to cChart(data).activeTab.ChildCount - 1 do
  begin
    p:=cChart(data).activeTab.GetPage(i);
    if p.MouseInPage(mouse.iPos_inv) then
    begin
      result:=p;
      exit;
    end;
  end;
end;

procedure cPageFrListener.WndProc(var msg:tmessage;var mouse:smousestruct);
var
  ax:caxis;
  I, curs: Integer;
  rect:trect;
  strafe:tpoint;
  res:tpoint;
  p:point2;
  page:cbasepage;
begin
  case msg.Msg of
    wm_mousemove:
    begin
      // ������� ��������
      if b_move then
      begin
        if curpage<>nil then
        begin
          strafe:=point(mouse.iPos.x-mouse.DragBegginPos.x,
                  -(mouse.iPos.y-mouse.DragBegginPos.y));
          rect.TopLeft:=point(beginmoverect.TopLeft.x+strafe.x,
                              beginmoverect.TopLeft.y+strafe.y);
          rect.BottomRight:=point(beginmoverect.BottomRight.x+strafe.x,
                                  beginmoverect.BottomRight.y+strafe.y);
          curpage.bound:=rect;
          invalidate;
          exit;
        end;
      end;
      if not b_move then
      begin
        if b_Resize then
        begin
          ResizePage(mouse);
        end
        else
        begin
          page:=cchart(data).activepage;
          if page=nil then exit;
          // ��������� �������� �������� - ������ ��� ����� �� �����?
          if overEdge(page,mouse.iPos_inv,fsize,b_ResizePage,res) then
          begin
            case b_ResizePage of
              c_TopLeft:
              begin
                curs:=crSizeNWSE;
                cchart(data).setcursor(curs, cursowner);
              end;
              c_TopRight:
              begin
                curs:=crSizeNESW;
                cchart(data).setcursor(curs, cursowner);
              end;
              c_BottomLeft:
              begin
                curs:=crSizeNESW;
                cchart(data).setcursor(curs, cursowner);
              end;
              c_BottomRight:
              begin
                curs:=crSizeNWSE;
                cchart(data).setcursor(curs, cursowner);
              end;
              c_Right:
              begin
                curs:=crSizeWE;
                cchart(data).setcursor(curs, cursowner);
              end;
              c_Left:
              begin
                curs:=crSizeWE;
                cchart(data).setcursor(curs, cursowner);
              end;
              c_Top:
              begin
                curs:=crSizeNS;
                cchart(data).setcursor(curs, cursowner);
              end;
              c_Bottom:
              begin
                curs:=crSizeNS;
                cchart(data).setcursor(curs, cursowner);
              end
              else
              begin
                curs:=crDefault;
                cchart(data).setcursor(curs, cursowner);
              end;
            end;
          end
          else
          // ���� �� ��� �������� ��������
          begin
            // ����� ������ �������� ��� ������� ������
            for I := 0 to cChart(data).activeTab.ChildCount - 1 do
            begin
              page:=cChart(data).activeTab.GetPage(i);
              if page<>nil then
              begin
                if page.MouseInPage(mouse.iPos_inv) then
                begin
                  p:=page.p2itoP2(mouse.ipos_inv);
                  mouse.strafe:=p2(p.x-mouse.pos.x, p.y-mouse.pos.y);
                  mouse.pos:=p;
                  page.doMouseMove(point(mouse.iPos_inv.x,
                                        mouse.iPos_inv.Y),
                                  p);
                  if GetKeyState(VK_Menu)<0 then
                  begin
                    b_move:=true;
                    beginmoverect:=page.bound;
                    cchart(data).setcursor(crSize, cursowner);
                  end;
                  break;
                end;
              end;
            end;
            // ������ ������� �������� ��� ������� ������
            if (page<>curpage) and (curpage<>nil) then
            begin
              curpage.DoOnExit;
            end;
            curpage:=page;
          end;
        end;
        if (curpage=nil) and (cchart(data).cursorowner<>-1) then
          cchart(data).setcursor(crDefault, cursowner);
      end;
    end;
    WM_LBUTTONDOWN:
    begin
      b_move:=false;
      if b_ResizePage<>c_None then
        b_Resize:=true
      else
      begin
        b_resize:=false;
      end;
      if not b_resize then
      begin
        // ����� �������� ��������
        for I := 0 to cChart(data).activeTab.ChildCount - 1 do
        begin
          page:=cChart(data).activeTab.GetPage(i);
          page.fDblClick:=false;
          if page.MouseInPage(mouse.iPos_inv) then
          begin
            cchart(data).activePage:=page;
            page.doclick(point(mouse.iPos_inv.x,mouse.iPos_inv.Y),mouse.pos);
            // ����� �������
            if GetKeyState(VK_Menu)<0 then
            begin
              if cChart(data).allowEditPages then
              begin
                b_move:=true;
                beginmoverect:=page.bound;
                cchart(data).setcursor(crSize, cursowner);
              end;
            end;
            break;
          end;
        end;
        if not b_move then
        begin
          cchart(data).setcursor(crDefault, cursowner);
        end;
      end;
    end;
    WM_LBUTTONUP:
    begin
      b_move:=false;
      b_resize:=false;
      if curpage=nil then
        page:=cChart(data).activeTab.activepage
      else
        page:=curpage;
      if page<>nil then
      begin
        p:=page.p2itoP2(mouse.ipos_inv);
        page.DoButtonUp(point(mouse.iPos_inv.x,
                        mouse.iPos_inv.Y),
                        p);
      end;
    end;
    WM_KEYUP:
    // ��� ���������� ������� ������� ������������
    // ���� ������������� �������� ������� ���������
    begin
      page:=cChart(data).activeTab.activepage;
      if page<>nil then
      begin
        page.DoKeyDowne(msg.WParam);
      end;
    end;
    WM_LBUTTONDBLCLK:
    begin
      page:=cChart(data).activeTab.activepage;
      page.fDblClick:=true;
      if page<>nil then
      begin
        p:=page.p2itoP2(mouse.ipos_inv);
        page.DoDblClick(mouse.iPos_inv,p);
      end;
    end;
  end;
end;

procedure cPageFrListener.setselectsize(s:integer);
begin

end;

function cPageFrListener.GetNearestBoundWithSnap(rect:trect;snap:integer):trect;
var
  i,borderid,
  // ������ �������� ������� ������� ��������� � ����� ��������
  min,
  h,w:integer;
  newrect:trect;
  pages:cpage;
  res,p,
  p2MinDist,minpos,dist:tpoint;
  b_snap:boolean;
begin
  b_snap:=false;
  min:=-1;
  p2MinDist:=point(-1,-1);
  h:=round((rect.top+rect.bottom)/2);
  w:=round((rect.left+rect.right)/2);
  case b_ResizePage of
    c_TopLeft: p:=rect.TopLeft;
    c_TopRight: p:=point(rect.right,rect.Top);
    c_BottomLeft: p:=point(rect.left,rect.bottom);
    c_BottomRight: p:=rect.BottomRight;
    c_Right: p:=point(rect.right,h);
    c_Left: p:=point(rect.left,h);
    c_Top: p:=point(w,rect.top);
    c_Bottom: p:=point(w,rect.bottom);
  end;
  minpos:=p;
  for I := 0 to cChart(data).activeTab.ChildCount - 1 do
  begin
    pages:=cChart(data).activeTab.GetPage(i);
    if pages=cChart(data).activepage then continue;
    if OverEdge(pages,p,snapPix,borderid,res) then
    begin
      dist:=point(abs(p.x-res.x),abs(p.y-res.y));
      if (dist.x<>-1) and (dist.x<snapPix) then
      begin
        if (dist.x<p2MinDist.X) or (p2MinDist.X=-1) then
        begin
          p2MinDist.X:=dist.x;
          minpos.x:=res.x;
          b_snap:=true;
        end;
      end;
      if (dist.y<>-1) and (dist.y<snapPix) then
      begin
        if (dist.y<p2MinDist.y) or (p2MinDist.y=-1) then
        begin
          p2MinDist.y:=dist.y;
          minpos.Y:=res.y;
          b_snap:=true;
        end;
      end;
    end;
  end;
  result:=rect;
  if b_snap then
  begin
    case b_ResizePage of
      c_TopLeft: result.TopLeft:=minpos;
      c_TopRight:
      begin
        result.top:=minpos.y;
        result.right:=minpos.x;
      end;
      c_BottomLeft:
      begin
        result.bottom:=minpos.y;
        result.left:=minpos.x;
      end;
      c_BottomRight: result.BottomRight:=minpos;
      c_Right: result.right:=minpos.x;
      c_Left: result.left:=minpos.x;
      c_Top: result.top:=minpos.y;
      c_Bottom: result.bottom:=minpos.y;
    end;
  end;
end;

function cPageFrListener.OverEdge(page:cbasepage;p:tpoint;snap:integer;var borderid:integer;var res:tpoint):boolean;
var
  rect:trect;
  corner,bleft,bright,btop,bbottom, gor, vert:boolean;
begin
  result:=false;
  borderid:=c_None;
  if not cChart(data).allowEditPages then exit;
  // ���� �������� �� ������������� �� �� �����
  if not page.fEditable then exit;

  rect:=page.bound;
  // ������ � ����� ��� ������ �������
  bleft:=abs(rect.left-p.x)<snap;
  if bleft then
    bright:=false
  else
    bright:=abs(rect.right-p.x)<snap;
  // ������ � ������� ��� ������ �������
  btop:=abs(rect.top-p.y)<snap;
  if btop then
    bbottom:=false
  else
    bbottom:=abs(rect.bottom-p.y)<snap;
  if bleft then
    res.X:=rect.left
  else
  begin
    if bright then
      res.X:=rect.Right
    else
      res.X:=-1;
  end;
  if btop then
    res.y:=rect.top
  else
  begin
    if bbottom then
      res.y:=rect.bottom
    else
      res.y:=-1;
  end;
  if (bleft or bright) or (bTop or bBottom) then
  begin
    corner:=(bleft or bright) and (bTop or bBottom);
    if corner then
    begin
      if bleft then
      begin
        if btop then
        begin
          borderid:=c_TopLeft;
        end
        else
        begin
          borderid:=c_BottomLeft;
        end;
      end
      else
      begin
        if btop then
        begin
          borderid:=c_TopRight;
        end
        else
        begin
          borderid:=c_BottomRight;
        end;
      end;
      result:=true;
    end
    else
    begin
      gor:=(p.X>rect.left) and (p.X<rect.right);
      vert:=(p.y<rect.top) and (p.y>rect.bottom);
      if vert then
      begin
        if bleft then
        begin
          borderid:=c_Left;
        end
        else
        begin
          if bRight then
          begin
            borderid:=c_Right;
          end;
        end;
      end;
      if gor then
      begin
        if bTop then
        begin
          borderid:=c_Top;
        end
        else
        begin
          if bBottom then
          begin
            borderid:=c_Bottom;
          end;
        end;
      end;
      result:=true;
    end;
  end
end;

procedure cPageFrListener.createevents;
begin
   cchart(data).objmng.events.AddEvent('cPageFrListener_OnDrawProc',e_onDraw,Test);
end;

procedure cPageFrListener.Destroyevents;
begin
  cchart(data).objmng.events.removeEvent(Test,e_onDraw);
end;

procedure cPageFrListener.test(sender:tobject);
var
  page:cpage;
  str:string;
begin
  {str:='';
  page:=cchart(data).activepage;
  if b_move then
    str:=' move';
  str:=str+' '+inttostr(cchart(data).cursorowner) +' '+ inttostr(cchart(data).cursor);
  page.Caption:=page.name + str;}
end;

end.
