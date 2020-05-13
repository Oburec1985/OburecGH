unit uMNode;

interface
uses MathFunction, uMatrix, OpenGl, Classes, uquat, uSimpleObjects, uNode,uCommonTypes;

type

  // Класс реализует всеми методами по позиционированию объекта
  cMNode = class(cnode)
  private
    // матрица состояния узла (смещение относительно родителя)
    fTM:matrixgl;
  protected
    // Меняет матрицу так, чтоб положение в мировых координатах не изменились,
    // но локальная матрица становится относительной к node. Если передаваемый параметр
    // nil тогда матрица узла задается относительно единичной матрицы
    //  те parentResTm*fTM=nodeTM*fTM
    procedure ChangeWorld(node:cnode);overload;override;
    procedure ChangeWorld(ptm:matrixgl);overload;override;
    // Возвращает матрицу, в мировых координатах
    function GetWorldTM:matrixgl;override;
      // Возвращает родительскую мировую матрицу
    function GetParentWorldTM:matrixgl;
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
    // переместить узел в локальных координатах
    Procedure MoveNodeLocal(x,y,z:single);overload;override;
    Procedure MoveNodeLocal(v:point3);overload;override;
    // переместить узел в координатах мира
    Procedure MoveNodeInWorld(v:point3;world:matrixgl);overload;override;
    Procedure MoveNodeInWorld(v:point3;world:cnode);overload;override;
    //member-ы которые хранят инф-ю свойств
    function GetPosFromTm:point3;
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


function cmNode.getCopy:cnode;
var node:cmnode;
begin
  node:=cmnode.Create;
  copyto(node);
  result:=node;
end;

procedure cmNode.copyto(node:cnode);
begin
  inherited copyto(node);
  if node is cmnode then
    cmnode(node).fTM:=ftm;
end;

procedure cmnode.copyFrom(node:cnode);
begin
  node.copyto(self);
end;

constructor cmnode.create(p_parent:cnode);
begin
  inherited;
  fTM:=identmatrix4;
end;

Constructor cmnode.Create;
begin
  inherited;
  fTM:=identmatrix4;
  settoworld;
end;

destructor cmnode.destroy;
begin
  inherited;
end;

procedure cmnode.ChangeWorld(pTM:matrixgl);
var res:matrixgl;
begin
  res:=GetWorldTM;
  // решаем матричное уравнение A*B=C, B = A^(-1)*C
  tm:=evalrightmatrix(pTM,res);
  restm:=res;
end;

procedure cmnode.ChangeWorld(node:cnode);
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

function cmnode.GetWorldTM:matrixgl;
var ltm:matrixgl;
begin
  if parent<>nil then
  begin
    ltm:=parent.restm;
    result:=multmatrix4(ltm,ftm);
  end
  else
  begin
    result:=ftm;
  end;
  restm:=result;
end;

function cmnode.GetParentWorldTM:matrixgl;
begin
  if parent<>nil then
    result:=Parent.restm
  else
    result:=identmatrix4;
end;

Procedure cmnode.RotateNodeLocalByAxisAngle(a:single;x,y,z:single);
var ltm:matrixgl;
begin
  ltm:=BuildMatrixByAxisAngel(x,y,z,a);
  ftm:=multmatrix4(ftm,ltm);
end;

Procedure cmnode.RotateNodeLocalByAxisAngle(a:single;axis:point3);
begin
  RotateNodeLocalByAxisAngle(a,axis.x,axis.y,axis.z);
end;

Procedure cmnode.RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:matrixgl);
var rotworld,offset,rottm:matrixgl;
    pos:point3;
begin
  if parent<>nil then
  begin
    offset:=evalrightmatrix(world,restm);
    // поворачиваем
    rottm:=BuildMatrixByAxisAngel(axis,a);
    rotworld:=multmatrix4(world,rottm);
    restm:=multmatrix4(rotworld,offset);
    ftm:=evalrightmatrix(parentrestm,restm);
    settoworld;
  end
  else
  begin
    offset:=evalrightmatrix(world,ftm);
    // поворачиваем
    rottm:=BuildMatrixByAxisAngel(axis,a);
    rotworld:=multmatrix4(world,rottm);
    ftm:=multmatrix4(rotworld,offset);
  end;
end;

Procedure cmnode.RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:cnode);
begin
  RotateNodeInWorldByAxisAngle(a,axis,world.restm);
end;

Procedure cmnode.MoveNodeLocal(x,y,z:single);
var transpose:matrixgl;
begin
  transpose:=BuildTransposeMatrix(x,y,z);
  ftm:=multmatrix4(ftm,transpose);
end;

Procedure cmnode.MoveNodeLocal(v:point3);
var transpose:matrixgl;
begin
  MoveNodeLocal(v.x,v.y,v.z);
end;

Procedure cmnode.MoveNodeInWorld(v:point3;world:matrixgl);
var res,transpose,offset,movetm:matrixgl;
begin
  offset:=evalrightmatrix(world,restm);
  // поворачиваем
  transpose:=BuildTransposeMatrix(v);
  movetm:=multmatrix4(world,transpose);
  restm:=multmatrix4(movetm,offset);
  ftm:=evalrightmatrix(parentrestm,restm);
  settoworld;
end;

Procedure cmnode.MoveNodeInWorld(v:point3;world:cnode);
begin
  MoveNodeInWorld(v,world.restm);
end;

function cmnode.GetPosFromTm:point3;
begin
  result:=GetPosFromMatrixP3(ftm);
end;

function cmnode.getPosition:point3;
begin
  result:=GetPosFromMatrixP3(restm);
end;

procedure cmnode.setPosition(pos:point3);
var offset,parentworld,newmatrix:matrixgl;
begin
  newmatrix:=SetPos(restm,pos);
  // матрица перемещения объекта в мировых координатах на которую надо умножить
  // установить позицию
  offset:=EvalRightMatrix(restm,newmatrix);
  // без учета родителя
  tm:=multmatrix4(tm,offset);
end;

function cmnode.getlocalTM:matrixgl;
begin
  result:=ftm;
end;

procedure cmnode.setlocalTM(m:matrixgl);
begin
  ftm:=m;
end;

procedure cmnode.setdir(dir:point3);
var offset,res:matrixgl;
begin
  res:=restm;
  SetAxisFromMatrix(res,2,dir);
  offset:=evalrightmatrix(restm, res);
  restm:=res;
  ftm:=multmatrix4(ftm,offset);
end;

end.
