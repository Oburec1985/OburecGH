unit u3dTransforms;

{ Implements transactional local/parent/world transforms for editor and live
  binding callers. Hot mutations defer aggregate bounds until commit. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses u3dCoreTypes,u3dScene;

type
  { Coordinates are interpreted in the node, parent, world, or explicit frame. }
  T3dTransformSpace = (tsLocal,tsParent,tsWorld,tsFrame);
  T3dTransformStats = record
    NodesUpdated,BoundsRebuilt: QWord;
  end;

function TryTransformToFrame(const AWorld,AFrame:T3dMatrix;
                             out AInFrame:T3dMatrix):Boolean;
procedure TransformFromFrame(const AInFrame,AFrame:T3dMatrix;
                             out AWorld:T3dMatrix);
function TryConvertTransformFrame(const ATransform,AFromFrame,AToFrame:T3dMatrix;
                                  out AResult:T3dMatrix):Boolean;
function TryTranslateTransformInFrame(const ATransform,AFrame:T3dMatrix;
                                      const ADelta:T3dVector;
                                      out AResult:T3dMatrix):Boolean;
function TryRotateTransformInFrame(const ATransform,AFrame:T3dMatrix;
                                   const AAxis:T3dVector; AAngleRadians:Single;
                                   out AResult:T3dMatrix):Boolean;

function SetNodeLocalTransform(AScene:T3dScene; ANodeId:QWord;
                               const ATransform:T3dMatrix): Boolean;
function SetNodeWorldTransform(AScene:T3dScene; ANodeId:QWord;
                               const ATransform:T3dMatrix): Boolean;


{ Delta, axis, and pivot use ASpace coordinates; tsFrame uses AFrame. Hot
  mutations update world matrices once and defer scene bounds to Commit. }
function TranslateNode(AScene:T3dScene; ANodeId:QWord;
                       const ADelta:T3dVector; ASpace:T3dTransformSpace;
                       const AFrame:T3dMatrix): Boolean;
function RotateNode(AScene:T3dScene; ANodeId:QWord;
                    const AAxis:T3dVector; AAngleRadians:Single; const APivot:T3dVector;
                    ASpace:T3dTransformSpace; const AFrame:T3dMatrix): Boolean;
function ReparentNode(AScene:T3dScene; ANodeId,AParentId:QWord;
                      APreserveWorld:Boolean): Boolean;
{ Full commit is intended for setup, reparent, or the end of an edit frame. }
function CommitSceneTransforms(AScene:T3dScene): Boolean;
function UpdateSceneWorldMatrices(AScene:T3dScene): Boolean;
procedure ResetTransformStats;
function TransformStats: T3dTransformStats;

implementation

uses u3dGeometryMath;

var gStats: T3dTransformStats;

function TryTransformToFrame(const AWorld,AFrame:T3dMatrix;
                             out AInFrame:T3dMatrix):Boolean;
var Inv:T3dMatrix;
begin
  Result:=TryInverseMatrix(AFrame,Inv);
  if Result then
    ComposeMatrices(Inv,AWorld,AInFrame);
end;

procedure TransformFromFrame(const AInFrame,AFrame:T3dMatrix;
                             out AWorld:T3dMatrix);
begin
  ComposeMatrices(AFrame,AInFrame,AWorld);
end;

function TryConvertTransformFrame(const ATransform,AFromFrame,AToFrame:T3dMatrix;
                                  out AResult:T3dMatrix):Boolean;
var World:T3dMatrix;
begin
  TransformFromFrame(ATransform,AFromFrame,World);
  Result:=TryTransformToFrame(World,AToFrame,AResult);
end;

function TryTranslateTransformInFrame(const ATransform,AFrame:T3dMatrix;
                                      const ADelta:T3dVector;
                                      out AResult:T3dMatrix):Boolean;
var Offset,Move,FrameMoved:T3dMatrix;
begin
  Result:=TryTransformToFrame(ATransform,AFrame,Offset);
  if not Result then Exit;
  SetIdentity(Move);
  Move[12]:=ADelta.X; Move[13]:=ADelta.Y; Move[14]:=ADelta.Z;
  ComposeMatrices(AFrame,Move,FrameMoved);
  ComposeMatrices(FrameMoved,Offset,AResult);
end;

function TryRotateTransformInFrame(const ATransform,AFrame:T3dMatrix;
                                   const AAxis:T3dVector; AAngleRadians:Single;
                                   out AResult:T3dMatrix):Boolean;
var Offset,Rotation,RotatedFrame:T3dMatrix;
begin
  Result:=TryTransformToFrame(ATransform,AFrame,Offset) and
          TryAxisAngleMatrix(AAxis,AAngleRadians,Rotation);
  if not Result then Exit;
  ComposeMatrices(AFrame,Rotation,RotatedFrame);
  ComposeMatrices(RotatedFrame,Offset,AResult);
end;

function NodeById(AScene:T3dScene; AId:QWord): T3dNode;
begin
  if (AScene=nil) or (AId=0) then
    Exit(nil);
  Result := AScene.FindNode(AId);
end;

function ParentOf(AScene:T3dScene; ANode:T3dNode): T3dNode;
begin
  if ANode=nil then
    Exit(nil);
  Result := NodeById(AScene,ANode.ParentId);
end;

function SpaceMatrix(AScene:T3dScene; ANode:T3dNode;
                     ASpace:T3dTransformSpace; const AFrame:T3dMatrix): T3dMatrix;

var P: T3dNode;
begin
  case ASpace of
    tsLocal: Result := ANode.WorldTransform;
    tsParent:
              begin
                P := ParentOf(AScene,ANode);
                if P=nil then
                  SetIdentity(Result)
                else Result := P.WorldTransform;
              end;
    tsFrame: Result := AFrame;
    else SetIdentity(Result);
  end;
end;

function UpdateSceneWorldMatrices(AScene:T3dScene): Boolean;

var Updated: Integer;
begin
  if AScene=nil then
    Exit(False);
  Result := AScene.RebuildWorldTransforms(Updated);
  if not Result then
    Exit;
  Inc(gStats.NodesUpdated,Updated);
end;

function CommitSceneTransforms(AScene:T3dScene): Boolean;
begin
  if AScene=nil then
    Exit(False);
  Result := UpdateSceneWorldMatrices(AScene);
  if not Result then
    Exit;
  AScene.RecalculateBounds;
  Inc(gStats.BoundsRebuilt);
end;

procedure ResetTransformStats;
begin
  FillChar(gStats,SizeOf(gStats),0);
end;

function TransformStats: T3dTransformStats;
begin
  Result := gStats;
end;

function LocalForWorld(AScene:T3dScene; ANode:T3dNode;
                       const AWorld:T3dMatrix; out ALocal:T3dMatrix): Boolean;

var P: T3dNode;
  Inv: T3dMatrix;
begin
  P := ParentOf(AScene,ANode);
  if P=nil then
    begin
      ALocal := AWorld;
      Exit(True);
    end;
  Result := TryInverseMatrix(P.WorldTransform,Inv);
  if Result then
    ComposeMatrices(Inv,AWorld,ALocal);
end;

function SetNodeLocalTransform(AScene:T3dScene; ANodeId:QWord;
                               const ATransform:T3dMatrix): Boolean;

var N: T3dNode;
begin
  N := NodeById(AScene,ANodeId);
  Result := (N<>nil) and AScene.ValidateHierarchy;
  if not Result then
    Exit;
  N.LocalTransform := ATransform;
  Result := UpdateSceneWorldMatrices(AScene);
end;

function SetNodeWorldTransform(AScene:T3dScene; ANodeId:QWord;
                               const ATransform:T3dMatrix): Boolean;

var N: T3dNode;
  L: T3dMatrix;
begin
  N := NodeById(AScene,ANodeId);
  Result := (N<>nil) and AScene.ValidateHierarchy and
            LocalForWorld(AScene,N,ATransform,L);
  if not Result then
    Exit;
  N.LocalTransform := L;
  Result := UpdateSceneWorldMatrices(AScene);
end;

function TranslateNode(AScene:T3dScene; ANodeId:QWord;
                       const ADelta:T3dVector; ASpace:T3dTransformSpace;
                       const AFrame:T3dMatrix): Boolean;

var N: T3dNode;
  Basis,W: T3dMatrix;
begin
  N := NodeById(AScene,ANodeId);
  if N=nil then
    Exit(False);
  if not AScene.ValidateHierarchy then
    Exit(False);
  Basis := SpaceMatrix(AScene,N,ASpace,AFrame);
  Result := TryTranslateTransformInFrame(N.WorldTransform,Basis,ADelta,W) and
            SetNodeWorldTransform(AScene,ANodeId,W);
end;

function RotateNode(AScene:T3dScene; ANodeId:QWord;
                    const AAxis:T3dVector; AAngleRadians:Single; const APivot:T3dVector;
                    ASpace:T3dTransformSpace; const AFrame:T3dMatrix): Boolean;

var N: T3dNode;
  Basis,PivotFrame,W: T3dMatrix;
  PivotWorld: T3dVector;
begin
  N := NodeById(AScene,ANodeId);
  if N=nil then
    Exit(False);
  if not AScene.ValidateHierarchy then
    Exit(False);
  Basis := SpaceMatrix(AScene,N,ASpace,AFrame);
  PivotWorld := TransformPoint(APivot,Basis);
  PivotFrame:=Basis;
  PivotFrame[12]:=PivotWorld.X;
  PivotFrame[13]:=PivotWorld.Y;
  PivotFrame[14]:=PivotWorld.Z;
  Result := TryRotateTransformInFrame(N.WorldTransform,PivotFrame,AAxis,
            AAngleRadians,W) and SetNodeWorldTransform(AScene,ANodeId,W);
end;

function IsDescendant(AScene:T3dScene; ANodeId,APossibleAncestorId:QWord): Boolean;

var N: T3dNode;
begin
  N := NodeById(AScene,ANodeId);
  while N<>nil do
    begin
      if N.ParentId=APossibleAncestorId then
        Exit(True);
      N := ParentOf(AScene,N);
    end;
  Result := False;
end;

function ReparentNode(AScene:T3dScene; ANodeId,AParentId:QWord;
                      APreserveWorld:Boolean): Boolean;

var N,P: T3dNode;
  OldWorld,NewLocal,Inv: T3dMatrix;
begin
  N := NodeById(AScene,ANodeId);
  if N=nil then
    Exit(False);
  if not AScene.ValidateHierarchy then
    Exit(False);
  P := NodeById(AScene,AParentId);
  if (AParentId<>0) and (P=nil) then
    Exit(False);
  if (AParentId=ANodeId) or IsDescendant(AScene,AParentId,ANodeId) then
    Exit(False);
  OldWorld := N.WorldTransform;
  NewLocal := N.LocalTransform;
  if APreserveWorld then
    begin
      if P=nil then
        NewLocal := OldWorld
      else
        begin
          if not TryInverseMatrix(P.WorldTransform,Inv) then
            Exit(False);
          ComposeMatrices(Inv,OldWorld,NewLocal);
        end;
    end;
  N.ParentId := AParentId;
  N.LocalTransform := NewLocal;
  Result := CommitSceneTransforms(AScene);
end;

end.
