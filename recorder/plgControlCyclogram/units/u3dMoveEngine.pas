unit u3dMoveEngine;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, ExtCtrls, StdCtrls, Spin,
  ucommontypes,
  uComponentServises,
  MathFunction,
  uMatrix,
  uSkin, uUI, usceneMng, uRender, uGlEventTypes,
  uNodeObject,
  uObject,
  uMeshObr,
  uShape,
  uBaseDeformer,
  DCL_MYOWN,
  uSpin,
  uRcFunc,
  uQuat,
  uRcCtrls;

type
  c3dCtrlObj = class(cObject)
  public
    m_objlist:tlist; // список агрегатор объектов
  public
    function ready:boolean;virtual;
    procedure UpdateObj;virtual;abstract;
  end;

  // объект отвечающий за перемещением и ориентацию
  c3dMoveObj = class(c3dCtrlObj)
  public
    // проинициализированы первые значени€ тегов (дл€ расчета матрицы смещени€)
    m_TagsInit:boolean;
    startPos, StartRot:point3;
    // теги отвечающие за позицию
    xTag, yTag, zTag:cTag;
    RotXTag, RotYTag, RotZTag:cTag;
  public
    procedure UpdateObj;override;
    constructor create;override;
    destructor destroy;override;
  end;

  // объект (кость) управл€ющий скелетом
  c3dSkinObj = class(c3dCtrlObj)
  public
    m_bone:cBone; // информаци€ о кости
    // номер точки
    m_PName:integer;
    m_w:double;
    // начальна€ позици€ до того как воздействовали теги
    startpos:point3;
    // деформируемый объект
    m_defObj:cnodeobject;
    // вершина скелета за которую зацеплен деформер
    PId:tpoint;
    // теги отвечающие за амплитуду смещени€ кости
    xTag, yTag, zTag:cTag;
  public
    procedure UpdateObj;override;
    constructor create;override;
    destructor destroy;override;
  end;

  // список c3dCtrlObj из файла uVertexEditFrame
  cCntrlObjList = class (tlist)
  public
  protected
    procedure doOnDestroy(sender:tobject);
  public
    procedure addObj(o:c3dSkinObj);
    function GetObj(i:integer):c3dSkinObj;
    // прочитать теги/ обновить позиции костей
    procedure updateObjPos;
  end;

var
  g_CtrlObjList:cCntrlObjList;

implementation


{ cSkinPoint }

constructor c3dSkinObj.create;
begin
  inherited;
  xTag:=cTag.create;
  yTag:=cTag.create;
  zTag:=cTag.create;
end;

destructor c3dSkinObj.destroy;
begin
  xTag.destroy;
  yTag.destroy;
  zTag.destroy;
  inherited;
end;


procedure c3dSkinObj.UpdateObj;
var
  p3,lp3:point3;
  b:boolean;
begin
  lp3:=startpos;
  p3:=lp3;
  if xTag.tag<>nil then
    p3.x:=lp3.x+xTag.GetMeanEst;
  if yTag.tag<>nil then
    p3.y:=lp3.y+yTag.GetMeanEst;
  if xTag.tag<>nil then
    p3.z:=lp3.z+zTag.GetMeanEst;
  begin
    b:=true;
    lp3:=position;
    if p3.x=lp3.x then
      if p3.y=lp3.y then
        if p3.Z=lp3.z then
          b:=false;
    if b then
      position:=p3;
  end;
end;

{ cCntrlObjList }
procedure cCntrlObjList.addObj(o: c3dSkinObj);
begin
  if o.m_objlist<>self then
  begin
    o.m_objlist:=self;
    o.fOnDestroy:=doOnDestroy;
    Add(o);
  end;
end;

procedure cCntrlObjList.doOnDestroy(sender: tobject);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if items[i]=sender then
    begin
      Delete(i);
      break;
    end;
  end;
end;

function cCntrlObjList.GetObj(i: integer): c3dSkinObj;
begin
  result:=c3dSkinObj(items[i]);
end;

procedure cCntrlObjList.updateObjPos;
var
  I: Integer;
  p3,lp3:point3;
  o:c3dSkinObj;
  b:boolean;
begin
  for I := 0 to Count - 1 do
  begin
    o:=GetObj(i);
    if o.ready then
      o.UpdateObj;
  end;
  crender(cscene(o.getmng).render).invalidaterect;
end;

{ c3dMoveObj }
constructor c3dMoveObj.create;
begin
  inherited;
  xTag:=cTag.create;
  yTag:=cTag.create;
  zTag:=cTag.create;
  RotXTag:=cTag.create;
  RotYTag:=cTag.create;
  RotZTag:=cTag.create;
end;

destructor c3dMoveObj.destroy;
begin
  xTag.destroy;
  yTag.destroy;
  zTag.destroy;
  RotXTag.destroy;
  RotYTag.destroy;
  RotZTag.destroy;
  inherited;
end;


procedure c3dMoveObj.UpdateObj;
var
  rot_p3, p3:point3;
  //q:tQuat;
begin
  p3:=position;
  if xTag.tag<>nil then
    p3.x:=xTag.GetMeanEst;
  if yTag.tag<>nil then
    p3.y:=yTag.GetMeanEst;
  if zTag.tag<>nil then
    p3.z:=zTag.GetMeanEst;

  {if RotXTag.tag<>nil then
    q.axis.x:=RotXTag.GetMeanEst;
  if RotYTag.tag<>nil then
    q.axis.y:=RotYTag.GetMeanEst;
  if RotZTag.tag<>nil then
    q.axis.z:=RotZTag.GetMeanEst;
  QuaternionSlerp()}
  position:=p3;
end;

{ c3dCtrlObj }

function c3dCtrlObj.ready: boolean;
begin
  result:=true;
end;

end.
