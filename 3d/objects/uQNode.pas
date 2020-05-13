unit uQNode;

interface
uses
  MathFunction,
  uMatrix,
  OpenGl,
  Classes,
  uquat,
  uSimpleObjects,
  uNode,
  uCommonTypes;

type

  // Класс реализует всеми методами по позиционированию объекта
  cQNode = class(cnode)
  private
    // матрица состояния узла (смещение относительно родителя)
    quat:cquat;
    res:tquat;
  protected
    // Меняет матрицу так, чтоб положение в мировых координатах не изменились,
    // но локальная матрица становится относительной к node. Если передаваемый параметр
    // nil тогда матрица узла задается относительно единичной матрицы
    //  те parentResTm*fTM=nodeTM*fTM
    procedure ChangeWorld(node:cnode);overload;override;
    procedure ChangeWorld(ptm:matrixgl);overload;override;
    // Возвращает матрицу, в мировых координатах
    function GetWorldTM:matrixgl;override;
    // Возвращает результирующий кватернион
    function GetWorldQuat:tquat;
  public
    function getlocalTM:matrixgl;override;
    procedure setlocalTM(m:matrixgl);override;
  public
    function getCopy:cnode;override;
    procedure copyTo(node:cnode);override;
    procedure copyFrom(node:cnode);override;
    Constructor Create(p_parent:cnode);overload;override;
    Constructor Create;overload;override;
    destructor destroy;override;
    // Повернуь узел в локальной системе координат
    Procedure RotateNodeLocalByAxisAngle(a:single;axis:point3);overload;override;
    Procedure RotateNodeLocalByAxisAngle(a:single;x,y,z:single);overload;override;
    // Повернуь узел в мировой системе координат вокруг точки world
    Procedure RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:matrixgl);overload;override;
    Procedure RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:cnode);overload;override;
    Procedure RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:tquat);overload;
    // переместить узел в локальных координатах
    Procedure MoveNodeLocal(x,y,z:single);overload;override;
    Procedure MoveNodeLocal(v:point3);overload;override;
    // переместить узел в координатах мира
    Procedure MoveNodeInWorld(v:point3;world:tquat);overload;
    Procedure MoveNodeInWorld(v:point3;world:matrixgl);overload;override;
    Procedure MoveNodeInWorld(v:point3;world:cnode);overload;override;
    //member-ы которые хранят инф-ю свойств
    function GetPosFromQ:point3;
    procedure setdir(dir:point3);override;
  protected
  // процедуры для установки свойств
  protected
    function getPosition:point3;override;
    procedure setPosition(pos:point3);override;
  public
    property tm:matrixgl read getlocalTM write setlocalTM;
  end;

implementation


function cQNode.getCopy:cnode;
var node:cQnode;
begin
  node:=cQNode.Create;
  copyto(node);
  result:=node;
end;

procedure cQNode.copyto(node:cnode);
begin
  inherited copyto(node);
  if node is cQNode then
    cQNode(node).quat.q:=quat.q;
end;

procedure cQNode.copyFrom(node:cnode);
begin
  node.copyto(self);
end;

constructor cQNode.create(p_parent:cnode);
begin
  quat:=cquat.Create;
  quat.q.w:=1;
  GetWorldTM;
  inherited;
end;

Constructor cQNode.Create;
begin
  quat:=cquat.Create;
  quat.q.w:=1;
  GetWorldTM;
  inherited;
end;

destructor cQNode.destroy;
begin
  inherited;
end;

procedure cQNode.ChangeWorld(pTM:matrixgl);
var res:matrixgl;
begin
  res:=GetWorldTM;
  // решаем матричное уравнение A*B=C, B = A^(-1)*C
  tm:=evalrightmatrix(pTM,res);
  restm:=res;
end;

procedure cQNode.ChangeWorld(node:cnode);
var parenttm,res:matrixgl;
begin
  res:=GetWorldTM;
  if node<>nil then
    parenttm:=node.restm
  else
    parenttm:=identmatrix4;
  // решаем матричное уравнение A*B=C, B = A^(-1)*C
  tm:=evalrightmatrix(parenttm,res);
  parent:=node;
  restm:=res;
end;

function cQNode.GetWorldQuat:tquat;
begin
  if parent<>nil then
  begin
    res:=cQNode(parent).res;
    res:=multquat(quat.q,res);
  end
  else
  begin
    res:=quat.q;
  end;
  result:=res;
end;

function cQNode.GetWorldTM:matrixgl;
begin
  GetWorldQuat;
  restm:=Quattomatrix(res);
  result:=restm;
end;

Procedure cQNode.RotateNodeLocalByAxisAngle(a:single;x,y,z:single);
begin
  quat.RotateByAxisAngel(x,y,z,a);
end;

Procedure cQNode.RotateNodeLocalByAxisAngle(a:single;axis:point3);
begin
  quat.RotateByAxisAngel(axis,a);
end;

Procedure cQNode.RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:tquat);
var rotworld,offset,rotq:tquat;

    q:tquat;
begin
  a:=-a;
  if parent<>nil then
  begin
    offset:=Getquat2(world,res);
    // поворачиваем
    rotq:=QuatFromAxisAngle(axis,a);
    rotworld:=multquatNoOffset(rotq,world);
    res:=multquat(offset,rotworld);
    quat.q:=GetQuat2(cQNode(parent).res,res);
  end
  else
  begin
    offset:=Getquat2(world,quat.q);
    // поворачиваем
    rotq:=QuatFromAxisAngle(axis,a);
    rotworld:=multquatNoOffset(rotq,world);
    quat.q:=multquat(offset,rotworld);
  end;
  settoworld;
end;

Procedure cQNode.RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:matrixgl);
var q:tquat;
begin
  q:=matrixtoquat(world);
  RotateNodeInWorldByAxisAngle(a,axis,q);
end;

Procedure cQNode.RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:cnode);
var q:tquat;
begin
  if world is cQNode then
    RotateNodeInWorldByAxisAngle(a,axis,cQNode(world).res)
  else
    RotateNodeInWorldByAxisAngle(a,axis,world.restm);
end;

Procedure cQNode.MoveNodeLocal(x,y,z:single);
var p3:point3;
begin
  p3.x:=x;p3.y:=y;p3.z:=z;
  p3:=rotatevectorbyquat(p3,quat.q);
  quat.q.offset:=summvectorp3(quat.q.offset,p3);
end;

Procedure cQNode.MoveNodeLocal(v:point3);
var p3:point3;
begin
  p3:=rotatevectorbyquat(p3,quat.q);
  quat.q.offset:=summvectorp3(quat.q.offset,p3);
end;

Procedure cQNode.MoveNodeInWorld(v:point3;world:tquat);
var offset,moveq:tquat;
begin
  offset:=Getquat2(world,res);
  // поворачиваем
  moveq.axis:=axisO;
  moveq.w:=1;
  moveq.offset:=v;
  moveq:=multquat(moveq,world);
  res:=multquat(offset,moveq);
  quat.q:=GetQuat2(cQNode(parent).res,res);
  quat.normalize;
  settoworld;
end;


Procedure cQNode.MoveNodeInWorld(v:point3;world:matrixgl);
var q:tquat;
begin
  q:=matrixtoquat(world);
  MoveNodeInWorld(v,q);
end;

Procedure cQNode.MoveNodeInWorld(v:point3;world:cnode);
begin
  if world is cQNode then
    MoveNodeInWorld(v,cQNode(world).res)
  else
    MoveNodeInWorld(v,world.restm);
end;

function cQNode.GetPosFromQ:point3;
begin
  result:=quat.q.offset;
end;

function cQNode.getPosition:point3;
begin
  result:=res.offset;
end;

procedure cQNode.setPosition(pos:point3);
var offset,parentworld,newq:tquat;
begin
  newq:=res;
  newq.offset:=pos;
  // матрица перемещения объекта в мировых координатах на которую надо умножить
  // установить позицию
  offset:=getQuat2(res,newq);
  // без учета родителя
  quat.q:=multquat(offset,quat.q);
end;

function cQNode.getlocalTM:matrixgl;
begin
  result:=quattomatrix(quat.q);
end;

procedure cQNode.setlocalTM(m:matrixgl);
begin
  quat.q:=matrixtoquat(m);
  quat.normalize;
  settoworld;
end;

procedure cQNode.setdir(dir:point3);
var offset,resm:matrixgl;
    lq:tquat;
begin
  resm:=restm;
  SetAxisFromMatrix(resm,2,dir);
  offset:=evalrightmatrix(restm, resm);
  restm:=resm;
  lq:=matrixtoquat(offset);
  quat.q:=multquatNoOffset(lq,quat.q);
  res:=matrixtoquat(restm);
end;

end.
