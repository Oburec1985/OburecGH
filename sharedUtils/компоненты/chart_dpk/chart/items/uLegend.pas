unit uLegend;

interface

uses
  windows, ubtnlistview, classes, stdctrls, controls, ExtCtrls, ComCtrls,
  uchartevents, uBaseObj, uCommonTypes, sysutils, ucommonmath,
  types, uEventTypes, MathFunction, uGraphObj, dialogs;

type
  cLegend = class(tbtnlistview)
  protected
    cs: TRTLCriticalSection;
    fNeedUpdate: boolean;
  public
    legendSplitter: TSplitter;
    prec: integer;
  protected
    procedure initLegend;
    procedure DoOnMoved(sender: tobject);
    procedure DoOnUpdateCfg(sender: tobject);
    // найти индекс тренда в легенде
    function getindex(sender: tobject): integer;
    function getNeedUpdate: boolean;
    procedure setNeedUpdate(b: boolean);
    procedure InitCS;
    procedure DeleteCS;
    procedure OnDraw(sender: tobject);
  public
    // -1 секция не занята. 1 - секция занята другим потоком; 0 - занята текущим потоком
    function CheckCS: integer;
    procedure EnterCS;
    procedure ExitCS;
    procedure doAddObjects(sender: tobject);
    procedure UpdateLegend;
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure SetVisible(Value: boolean);
  public
    property NeedUpdate: boolean read getNeedUpdate write setNeedUpdate;
  end;

const
  legendsplitterwidth = 2;

implementation

uses
  upage, uaxis, uchart, uDoubleCursor;

const
  c_name = 'Имя';
  c_X = 'X1';
  c_Y = 'Y1';
  c_X2 = 'X2';
  c_Y2 = 'Y2';
  c_Length = 'Length';
  c_Xmin = 'Xmin';
  c_Ymin = 'Ymin';
  c_Xmax = 'Xmax';
  c_Ymax = 'Ymax';
  c_dX = 'dX';
  c_dY = 'dY';

function cLegend.getindex(sender: tobject): integer;
var
  I: integer;
  li: tlistitem;
begin
  result := -1;
  if sender is cGraphObj then
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if sender = Items[I].Data then
      begin
        result := I;
      end;
    end;
  end;
end;

function fgetcolor(li: tlistitem): integer;
begin
  result := rgbtoint(cGraphObj(li.Data).color);
end;

destructor cLegend.destroy;
begin
  legendSplitter.destroy;
  legendSplitter := nil;

  cchart(parent).objmng.events.removeEvent(doAddObjects,
    e_OnMoveCursor +
    //e_onUpdateBound +
    e_onLincParent +
    e_onLoadObjMng +
    //e_onAddPoint +
    e_OnChangeName +
    e_OnChangeColor);

  cchart(parent).objmng.events.removeEvent(OnDraw, e_onDraw);
  DeleteCS;
  // showmessage('delline');
  inherited;
end;

constructor cLegend.Create(AOwner: TComponent);
begin
  inherited;
  InitCS;
  DrawColorBox := true;
  getcolor := fgetcolor;
  prec := 3;
  parent := twincontrol(AOwner);
  Align := alBottom;
  Height := 100;
  legendSplitter := TSplitter.Create(AOwner);
  legendSplitter.Width := legendsplitterwidth;
  legendSplitter.parent := twincontrol(AOwner);
  legendSplitter.Align := alBottom;
  legendSplitter.OnMoved := DoOnMoved;
  initLegend;
end;

procedure cLegend.initLegend;
var
  col: tlistcolumn;
begin
  // имя
  col := Columns.Add;
  col.Caption := c_name;
  col.Width := 100;
  // X
  col := Columns.Add;
  col.Caption := c_X;
  col.Width := 70;
  // Y
  col := Columns.Add;
  col.Caption := c_Y;
  col.Width := 70;
  // X2
  col := Columns.Add;
  col.Caption := c_X2;
  col.Width := 70;
  // Y2
  col := Columns.Add;
  col.Caption := c_Y2;
  col.Width := 70;
  // длина сигнала
  col := Columns.Add;
  col.Caption := c_Length;
  col.Width := 70;
  // Xmin
  col := Columns.Add;
  col.Caption := c_Xmin;
  col.Width := 70;
  // Ymin
  col := Columns.Add;
  col.Caption := c_Ymin;
  col.Width := 70;
  // Xmax
  col := Columns.Add;
  col.Caption := c_Xmax;
  col.Width := 70;
  // Ymax
  col := Columns.Add;
  col.Caption := c_Ymax;
  col.Width := 70;
  // dX
  col := Columns.Add;
  col.Caption := c_dX;
  col.Width := 70;
  // dY
  col := Columns.Add;
  col.Caption := c_dY;
  col.Width := 70;
  // происходит при обновлении структуры компонента
  cchart(parent).objmng.events.AddEvent('OnCfgUpdateLegend',
                                        e_OnMoveCursor +
                                        //e_onUpdateBound +
                                        e_onLincParent +
                                        e_onLoadObjMng +
                                        //e_onAddPoint +
                                        e_OnChangeName +
                                        e_OnChangeColor,doAddObjects);
  cchart(parent).objmng.events.AddEvent('OnDrawLegend', e_onDraw, OnDraw);
end;

procedure cLegend.DoOnMoved(sender: tobject);
var
  page: cpage;
begin
  page := cpage(cchart(parent).activepage);
  if page <> nil then
  begin
    // page.ChangeSize;
    // cchart(parent).;
  end;
end;

procedure cLegend.SetVisible(Value: boolean);
var
  page: cpage;
begin
  visible := Value;
  legendSplitter.visible := Value;
  page := cpage(cchart(parent).activepage);
  if page <> nil then
  begin
    cpage(cchart(parent).activepage).ChangeSize;
    // cchart(parent).redraw;
  end;
end;

function EnumCfg(obj: cBaseObj; Data: pointer): boolean;
var
  p1, p2: point2;
  li: tlistitem;
  bound: frect;
  page: cpage;
  tr: cGraphObj;
  cursor: cDoubleCursor;
  i:integer;
  v:double;
begin
  result := true;
  if obj is cGraphObj then
  begin
    tr := cGraphObj(obj);
    cLegend(Data).EnterCS;
    // Имя тренда
    for I := 0 to cLegend(Data).Items.Count - 1 do
    BEGIN
      li := cLegend(Data).Items[i];
      if li.data=obj then
        break
      else
        li:=nil;
    END;
    if li=nil then
      exit;
    clegend(data).SetSubItemByColumnName(c_Name,cGraphObj(obj).name,li);
    // Длина сигнала
    clegend(data).SetSubItemByColumnName(c_Length,inttostr(cGraphObj(obj).count),li);
    // обновить границы
    bound:=cGraphObj(obj).GetBound;
    // Xmin
    clegend(data).SetSubItemByColumnName(c_Xmin,formatstr(bound.bottomleft.x,clegend(data).prec),li);
    // Ymin
    clegend(data).SetSubItemByColumnName(c_Ymin,formatstr(bound.bottomleft.y,clegend(data).prec),li);
    // Xmax
    clegend(data).SetSubItemByColumnName(c_Xmax,formatstr(bound.topright.x,clegend(data).prec),li);
    // Ymax
    clegend(data).SetSubItemByColumnName(c_Ymax,formatstr(bound.topright.y,clegend(data).prec),li);
    page:=cpage(tr.getparentbyclassname('cPage'));
    if page=nil then
      exit;
    cursor:=page.cursor;
    p1.x:=cursor.getx1;
    p2.x:=cursor.getx2;
    if page.lgx then
    begin
      v:=ValToLogScale(p1.x, p2d(page.activeAxis.min.x,page.activeAxis.max.x));
      p1.y:=tr.GetY(v);
      v:=ValToLogScale(p2.x, p2d(page.activeAxis.min.x,page.activeAxis.max.x));
      p2.y:=tr.GetY(v);
    end
    else
    begin
      p1.y:=tr.GetY(p1.x);
      p2.y:=tr.GetY(p2.x);
    end;
    if page.activeAxis.lg then
    begin
      p1.y:=ValToLogScale(p1.y, p2d(page.activeAxis.min.y,page.activeAxis.max.y));
      p2.y:=ValToLogScale(p2.y, p2d(page.activeAxis.min.y,page.activeAxis.max.y));
    end;

    clegend(data).SetSubItemByColumnName(c_X,formatstr(p1.x,clegend(data).prec),li);
    clegend(data).SetSubItemByColumnName(c_Y,formatstr(p1.Y,clegend(data).prec),li);
    if cursor.cursortype=c_DoubleCursor then
    begin
      clegend(data).SetSubItemByColumnName(c_X2,formatstr(p2.x,clegend(data).prec),li);
      clegend(data).SetSubItemByColumnName(c_Y2,formatstr(p2.Y,clegend(data).prec),li);
      clegend(data).SetSubItemByColumnName(c_dX,formatstr(p2.x-p1.x,clegend(data).prec),li);
      clegend(data).SetSubItemByColumnName(c_dY,formatstr(p2.y-p1.y,clegend(data).prec),li);
    end
    else
    begin
      clegend(data).SetSubItemByColumnName(c_dX,'-',li);
      clegend(data).SetSubItemByColumnName(c_dY,'-',li);
    end;
    clegend(data).NeedUpdate:=false;
    cLegend(Data).ExitCS;
  end;
end;

procedure cLegend.OnDraw(sender: tobject);
begin
  if fNeedUpdate then
    UpdateLegend;
end;

procedure cLegend.UpdateLegend;
begin
  if parent <> nil then
  begin
    if cchart(parent).activetab <> nil then
      cchart(parent).activetab.EnumGroupMembers(EnumCfg, self);
  end;
end;


function EnumCfgAddObj(obj: cBaseObj; Data: pointer): boolean;
var
  p1, p2: point2;
  li: tlistitem;
  bound: frect;
  page: cpage;
  tr: cGraphObj;
  cursor: cDoubleCursor;
  i:integer;
  v:double;
begin
  result := true;
  if obj is cGraphObj then
  begin
    tr := cGraphObj(obj);
    cLegend(Data).EnterCS;
    // Имя тренда
    li := cLegend(Data).Items.add;
    li.data:=obj;
    clegend(data).SetSubItemByColumnName(c_Name,cGraphObj(obj).name,li);
    // Длина сигнала
    clegend(data).SetSubItemByColumnName(c_Length,inttostr(cGraphObj(obj).count),li);
    // обновить границы
    bound:=cGraphObj(obj).GetBound;
    // Xmin
    clegend(data).SetSubItemByColumnName(c_Xmin,formatstr(bound.bottomleft.x,clegend(data).prec),li);
    // Ymin
    clegend(data).SetSubItemByColumnName(c_Ymin,formatstr(bound.bottomleft.y,clegend(data).prec),li);
    // Xmax
    clegend(data).SetSubItemByColumnName(c_Xmax,formatstr(bound.topright.x,clegend(data).prec),li);
    // Ymax
    clegend(data).SetSubItemByColumnName(c_Ymax,formatstr(bound.topright.y,clegend(data).prec),li);
    page:=cpage(tr.getparentbyclassname('cPage'));
    if page=nil then
      exit;
    cursor:=page.cursor;
    p1.x:=cursor.getx1;
    p2.x:=cursor.getx2;
    if page.lgx then
    begin
      if page.activeAxis<>nil then
      begin
        v:=ValToLogScale(p1.x, p2d(page.activeAxis.min.x,page.activeAxis.max.x));
        p1.x:=v;

        v:=ValToLogScale(p2.x, p2d(page.activeAxis.min.x,page.activeAxis.max.x));
        p2.x:=v;
      end;
    end;
    p1.y:=tr.GetY(p1.x);
    p2.y:=tr.GetY(p2.x);

    clegend(data).SetSubItemByColumnName(c_X,formatstr(p1.x,clegend(data).prec),li);
    clegend(data).SetSubItemByColumnName(c_Y,formatstr(p1.Y,clegend(data).prec),li);
    if cursor.cursortype=c_DoubleCursor then
    begin
      clegend(data).SetSubItemByColumnName(c_X2,formatstr(p2.x,clegend(data).prec),li);
      clegend(data).SetSubItemByColumnName(c_Y2,formatstr(p2.Y,clegend(data).prec),li);
      clegend(data).SetSubItemByColumnName(c_dX,formatstr(p2.x-p1.x,clegend(data).prec),li);
      clegend(data).SetSubItemByColumnName(c_dY,formatstr(p2.y-p1.y,clegend(data).prec),li);
    end
    else
    begin
      clegend(data).SetSubItemByColumnName(c_dX,'-',li);
      clegend(data).SetSubItemByColumnName(c_dY,'-',li);
    end;
    clegend(data).NeedUpdate:=false;
    cLegend(Data).ExitCS;
  end;
end;

procedure cLegend.doAddObjects(sender:tobject);
begin
  if parent <> nil then
  begin
    if visible then
    begin
      if cchart(parent).initGl then
      begin
        if cchart(parent).activetab <> nil then
        begin
          clear;
          cchart(parent).activetab.EnumGroupMembers(EnumCfgAddObj, self);
        end;
      end;
    end;
  end;
end;

procedure cLegend.DoOnUpdateCfg(sender: tobject);
begin
  NeedUpdate := true;
end;

function cLegend.getNeedUpdate: boolean;
begin
  EnterCS;
  result := fNeedUpdate;
  ExitCS;
end;

procedure cLegend.setNeedUpdate(b: boolean);
begin
  // если секция не занята другим потоком
  if CheckCS <> 1 then
  begin
    EnterCS;
    fNeedUpdate := b;
    // закоментил от 04.09.18 - приводит к зацикливанию отрисовки
    // cchart(parent).redraw;
    ExitCS;
  end;
end;

procedure cLegend.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure cLegend.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;

procedure cLegend.EnterCS;
begin
  EnterCriticalSection(cs);
end;

procedure cLegend.ExitCS;
begin
  LeaveCriticalSection(cs);
end;

function cLegend.CheckCS: integer;
begin
  // нет владельца
  result := -1;
  if cs.LockCount <> -1 then
  begin
    if cs.OwningThread <> GetCurrentThreadId then
    begin
      // владелец чужой поток
      result := 1;
    end
    else
      // владелец текущий поток
      result := 0;
  end;
end;

end.
