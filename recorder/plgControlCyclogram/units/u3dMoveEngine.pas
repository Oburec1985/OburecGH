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
  uRcCtrls;

type
  // ������ (�����) ����������� ��������
  c3dCtrlObj = class(cObject)
  public
    m_objlist:tlist; // ������ ��������� ��������
    m_bone:cBone; // ���������� � �����
    // ����� �����
    m_PName:integer;
    m_w:double;
    // ��������� ������� �� ���� ��� �������������� ����
    startpos:point3;
    // ������������� ������
    m_defObj:cnodeobject;
    PId:tpoint; // ������� �������
    // ���� ���������� �� ��������� �������� �����
    xTag, yTag, zTag:cTag;
  public
    constructor create;override;
    destructor destroy;override;
  end;

  // ������ c3dCtrlObj �� ����� uVertexEditFrame
  cCntrlObjList = class (tlist)
  public
  protected
    procedure doOnDestroy(sender:tobject);
  public
    procedure addObj(o:c3dCtrlObj);
    function GetObj(i:integer):c3dCtrlObj;
    // ��������� ����/ �������� ������� ������
    procedure updateObjPos;
  end;

var
  g_CtrlObjList:cCntrlObjList;

implementation


{ cSkinPoint }

constructor c3dCtrlObj.create;
begin
  inherited;
  xTag:=cTag.create;
  yTag:=cTag.create;
  zTag:=cTag.create;
end;

destructor c3dCtrlObj.destroy;
begin
  xTag.destroy;
  yTag.destroy;
  zTag.destroy;
  inherited;
end;

{ cCntrlObjList }
procedure cCntrlObjList.addObj(o: c3dCtrlObj);
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

function cCntrlObjList.GetObj(i: integer): c3dCtrlObj;
begin
  result:=c3dCtrlObj(items[i]);
end;

procedure cCntrlObjList.updateObjPos;
var
  I: Integer;
  p3,lp3:point3;
  o:c3dCtrlObj;
  b:boolean;
begin
  for I := 0 to Count - 1 do
  begin
    o:=GetObj(i);
    lp3:=o.startpos;
    p3:=lp3;
    if o.xTag.tag<>nil then
    begin
      p3.x:=lp3.x+o.xTag.GetMeanEst;
    end;
    if o.yTag.tag<>nil then
    begin
      p3.y:=lp3.y+o.yTag.GetMeanEst;
    end;
    if o.zTag.tag<>nil then
    begin
      p3.z:=lp3.z+o.zTag.GetMeanEst;
    end;
    b:=true;
    lp3:=o.position;
    if p3.x=lp3.x then
      if p3.y=lp3.y then
        if p3.Z=lp3.z then
          b:=false;
    if b then
      o.position:=p3;

  end;
  crender(cscene(o.getmng).render).invalidaterect;
end;

end.
