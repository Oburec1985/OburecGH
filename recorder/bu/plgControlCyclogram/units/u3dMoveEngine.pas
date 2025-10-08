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
  uGroupObjects,
  uRcCtrls;

// ����� ������� ���������� �� �������� �������� ����� ����
type
  //
  c3dCtrlObj = class(cObject)
  public
    m_objlist:tlist; // ������ ��������� ��������
  protected
    procedure dostart;virtual; // ���������� ��� ������ ���������
  public
    function ready:boolean;virtual;
    // ������� ���������� � ����� ��� ���������� ��������
    // � ����������� �� ���� ��������������� ��������� �� ��������� �����
    // ��� ������ ����������
    procedure UpdateObjByTag;virtual;abstract;
  end;

  // ������ ���������� �� ������������ � ����������
  c3dMoveObj = class(c3dCtrlObj)
  public
    // ������������������� ������ �������� ����� (��� ������� ������� ��������)
    m_TagsInit:boolean;
    m_starttm:MatrixGl;
    startPos:point3;
    // ���� ���������� �� �������
    xTag, yTag, zTag:cTag;
    RotXTag, RotYTag, RotZTag:cTag;
  protected
    procedure dostart;override;
  public
    // ��� ��������� ������� ������� �������� ������ ����� ������ ���������
    procedure AddChild(o:cnodeobject);
    procedure initTM;
    procedure UpdateObjByTag;override;
    constructor create;override;
    destructor destroy;override;
  end;

  // ������ (�����) ����������� ��������
  // ��������� � TVertexEditFrame
  c3dSkinObj = class(c3dCtrlObj)
  public
    m_bone:cBone; // ���������� � �����
    // ����� �����
    m_PName:integer;
    m_w:double;
    // ��������� ������� �� ���� ��� �������������� ����
    startpos:point3;
    // ������������� ������
    m_defObj:cnodeobject;
    // ������� ������� �� ������� �������� ��������
    PId:tpoint;
    // ���� ���������� �� ��������� �������� �����
    xTag, yTag, zTag:cTag;
  public
    procedure UpdateObjByTag;override;
    constructor create;override;
    destructor destroy;override;
  end;

  // ������ c3dCtrlObj �� ����� uVertexEditFrame
  cCntrlObjList = class (tlist)
  public
  private

  protected
    procedure doOnDestroy(sender:tobject);
  public
    procedure doStart;
    procedure addObj(o:c3dCtrlObj);
    // id - ��� ����� �����; s - ��� ����
    function GetObjBySkin(s:string; id:integer):c3dSkinObj;
    function GetObj(s:string):c3dCtrlObj;overload;
    function GetObj(i:integer):c3dCtrlObj;overload;
    // ��������� ����/ �������� ������� ������
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


procedure c3dSkinObj.UpdateObjByTag;
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

procedure cCntrlObjList.updateObjPos;
var
  I: Integer;
  p3,lp3:point3;
  o:c3dSkinObj;
  b:boolean;
begin
  b:=false;
  for I := 0 to Count - 1 do
  begin
    o:=c3dSkinObj(GetObj(i));
    if o.ready then
    begin
      o.UpdateObjByTag;
      b:=true;
    end;
  end;
  if b then
    crender(cscene(o.getmng).render).invalidaterect;
end;

procedure cCntrlObjList.doStart;
var
  I: Integer;
  o:c3dCtrlObj;
begin
  for I := 0 to Count - 1 do
  begin
    o:=GetObj(i);
    o.dostart;
  end;
end;

function cCntrlObjList.GetObj(s: string): c3dCtrlObj;
var
  I: Integer;
  o:c3dCtrlObj;
begin
  result:=nil;
  for I := 0 to count-1 do
  begin
    o:=GetObj(i);
    if o.name=s then
    begin
      result:=o;
      exit;
    end;
  end;
end;

function cCntrlObjList.GetObj(i: integer): c3dCtrlObj;
begin
  result:=c3dCtrlObj(items[i]); // c3dSkinObj
end;

function cCntrlObjList.GetObjBySkin(s: string; id:integer): c3dSkinObj;
var
  I: Integer;
  o:c3dCtrlObj;
begin
  result:=nil;
  for I := 0 to count-1 do
  begin
    o:=GetObj(i);
    if o is c3dSkinObj then
    begin
      if (c3dSkinObj(o).m_defObj.name=s) and (c3dSkinObj(o).m_PName=id)
      then
      begin
        result:=c3dSkinObj(o);
        exit;
      end;
    end;
  end;
end;

{ c3dMoveObj }
procedure c3dMoveObj.AddChild(o: cnodeobject);
begin
  GroupTo(o,self);
end;

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


procedure c3dMoveObj.dostart;
begin
  initTM;
end;

procedure c3dMoveObj.initTM;
begin
  m_starttm:=nodetm;
end;

procedure c3dMoveObj.UpdateObjByTag;
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
  position:=p3;


  nodetm := m_starttm;
  if RotXTag.tag<>nil then
    rot_p3.x := RotXTag.GetMeanEst;
  if RotYTag.tag<>nil then
    rot_p3.y := RotYTag.GetMeanEst;
  if RotZTag.tag<>nil then
    rot_p3.z := RotZTag.GetMeanEst;
  RotateNodeInLocalNodeWorld(rot_p3);
end;

{ c3dCtrlObj }

procedure c3dCtrlObj.dostart;
begin

end;

function c3dCtrlObj.ready: boolean;
begin
  result:=true;
end;

end.
