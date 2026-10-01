unit u3dSceneMotionEngine;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes, u3dScene, u3dMotionContracts;

type
  T3dMotionTargetState = record
    NodeId: QWord;
    BasePosition: T3dVector;
    LocalOffset: T3dVector;
    AxisSpace: array[T3dMotionAxis] of T3dMotionSpace;
    Dirty: Boolean;
  end;

  { Applies absolute offsets from a captured pose. Configuration allocates the
    target table; Apply performs no allocation or name lookup. }
  T3dSceneMotionEngine = class(TInterfacedObject, I3dMotionSink)
  private
    fScene: T3dScene;
    fTargets: array of T3dMotionTargetState;
    fRevision: QWord;
    function FindTarget(AId: QWord): Integer;
    function ApplyCommand(const ACommand: T3dMotionCommand): Boolean;
    function TargetPosition(AIndex: Integer): T3dVector;
  public
    procedure Configure(AScene: T3dScene; const ATargetIds: array of QWord);
    function Apply(const ACommands: array of T3dMotionCommand): Boolean;
    function Revision: QWord;
  end;

implementation

uses
  u3dSceneMath;

function T3dSceneMotionEngine.FindTarget(AId: QWord): Integer;
begin
  for Result := 0 to High(fTargets) do
    if fTargets[Result].NodeId = AId then Exit;
  Result := -1;
end;

procedure T3dSceneMotionEngine.Configure(AScene: T3dScene;
  const ATargetIds: array of QWord);
var
  lIndex: Integer;
  lNode: T3dNode;
begin
  fScene := AScene;
  SetLength(fTargets, Length(ATargetIds));
  for lIndex := 0 to High(fTargets) do
  begin
    fTargets[lIndex].NodeId := ATargetIds[lIndex];
    fTargets[lIndex].LocalOffset := Vector3d(0, 0, 0);
    fTargets[lIndex].AxisSpace[maxisX] := msHelperLocal;
    fTargets[lIndex].AxisSpace[maxisY] := msHelperLocal;
    fTargets[lIndex].AxisSpace[maxisZ] := msHelperLocal;
    fTargets[lIndex].Dirty := False;
    lNode := FindSceneNode(fScene, ATargetIds[lIndex]);
    if lNode = nil then
      fTargets[lIndex].BasePosition := Vector3d(0, 0, 0)
    else
      fTargets[lIndex].BasePosition := Vector3d(lNode.WorldTransform[12],
        lNode.WorldTransform[13], lNode.WorldTransform[14]);
  end;
end;

function T3dSceneMotionEngine.TargetPosition(AIndex: Integer): T3dVector;
var
  lNode, lParent: T3dNode;
  lAxis: T3dMotionAxis;
  lOffset, lVector: T3dVector;
  lMatrix: ^T3dMatrix;
begin
  Result := fTargets[AIndex].BasePosition;
  lOffset := fTargets[AIndex].LocalOffset;
  lNode := FindSceneNode(fScene, fTargets[AIndex].NodeId);
  if lNode = nil then Exit;
  for lAxis := Low(lAxis) to High(lAxis) do
  begin
    case lAxis of
      maxisX: lVector := Vector3d(lOffset.X, 0, 0);
      maxisY: lVector := Vector3d(0, lOffset.Y, 0);
      maxisZ: lVector := Vector3d(0, 0, lOffset.Z);
    end;
    case fTargets[AIndex].AxisSpace[lAxis] of
      msHelperLocal: lMatrix := @lNode.WorldTransform;
      msParent:
        begin
          lParent := FindSceneNode(fScene, lNode.ParentId);
          if lParent = nil then lMatrix := nil else lMatrix := @lParent.WorldTransform;
        end;
    else
      lMatrix := nil;
    end;
    if lMatrix <> nil then lVector := Vector3d(
      lVector.X*lMatrix^[0]+lVector.Y*lMatrix^[4]+lVector.Z*lMatrix^[8],
      lVector.X*lMatrix^[1]+lVector.Y*lMatrix^[5]+lVector.Z*lMatrix^[9],
      lVector.X*lMatrix^[2]+lVector.Y*lMatrix^[6]+lVector.Z*lMatrix^[10]);
    Result.X := Result.X + lVector.X;
    Result.Y := Result.Y + lVector.Y;
    Result.Z := Result.Z + lVector.Z;
  end;
end;

function T3dSceneMotionEngine.ApplyCommand(
  const ACommand: T3dMotionCommand): Boolean;
var
  lIndex: Integer;
begin
  Result := False;
  lIndex := FindTarget(ACommand.TargetNodeId);
  if lIndex < 0 then Exit;
  case ACommand.Axis of
    maxisX: fTargets[lIndex].LocalOffset.X := ACommand.Offset;
    maxisY: fTargets[lIndex].LocalOffset.Y := ACommand.Offset;
    maxisZ: fTargets[lIndex].LocalOffset.Z := ACommand.Offset;
  end;
  fTargets[lIndex].AxisSpace[ACommand.Axis] := ACommand.Space;
  fTargets[lIndex].Dirty := True;
  Result := True;
end;

function T3dSceneMotionEngine.Apply(
  const ACommands: array of T3dMotionCommand): Boolean;
var
  lIndex: Integer;
begin
  Result := False;
  for lIndex := 0 to High(ACommands) do
    Result := ApplyCommand(ACommands[lIndex]) or Result;
  if not Result then Exit;
  Result := False;
  for lIndex := 0 to High(fTargets) do
    if fTargets[lIndex].Dirty then
    begin
      Result := SetNodeWorldPosition(fScene, fTargets[lIndex].NodeId,
        TargetPosition(lIndex)) or Result;
      fTargets[lIndex].Dirty := False;
    end;
  if Result then Inc(fRevision);
end;

function T3dSceneMotionEngine.Revision: QWord;
begin
  Result := fRevision;
end;

end.
