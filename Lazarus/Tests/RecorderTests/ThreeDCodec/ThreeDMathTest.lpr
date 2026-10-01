program ThreeDMathTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses Math, SysUtils, u3dCoreTypes, u3dScene, u3dGeometryMath;

procedure Check(ACondition:Boolean; const AMessage:string);
begin if not ACondition then raise Exception.Create(AMessage); end;
procedure Near(AActual,AExpected:Single; const AMessage:string);
begin Check(Abs(AActual-AExpected)<1e-4,AMessage); end;

var M,R,I:T3dMatrix; P,Q,Hit,Delta:T3dVector; Ray:T3dRayValue;
  B,TB:T3dBounds; Corners:array[0..7] of T3dVector; D,T,U:Single;
  Screen:T3dScreenPoint; Scene:T3dScene; Node:T3dNode; Ids:array[0..0] of QWord;
begin
  try
    SetIdentity(M); M[12]:=3; M[13]:=-2; M[14]:=5;
    Check(TryAxisAngleMatrix(Vector3d(0,0,1),Pi/2,R),'axis angle');
    ComposeMatrices(M,R,M); Check(TryInverseMatrix(M,I),'inverse');
    P:=Vector3d(2,1,-4); Q:=TransformPoint(TransformPoint(P,M),I);
    Near(Q.X,P.X,'inverse x'); Near(Q.Y,P.Y,'inverse y'); Near(Q.Z,P.Z,'inverse z');

    B.Valid:=True; B.Min:=Vector3d(-1,-2,-3); B.Max:=Vector3d(1,2,3);
    BoundsCorners(B,Corners); TB:=TransformBounds(B,M); Check(TB.Valid,'transformed bounds');
    Check((TB.Max.X>TB.Min.X) and (TB.Max.Y>TB.Min.Y),'oriented bounds');

    Ray.Origin:=Vector3d(0,0,5); Ray.Direction:=Vector3d(0,0,-1);
    Check(TryRayPlane(Ray,Vector3d(0,0,0),Vector3d(0,0,1),D,Hit),'ray plane');
    Near(D,5,'ray distance'); Near(Hit.Z,0,'ray hit');
    Check(TryClosestRayAxis(Ray,Vector3d(0,0,0),Vector3d(1,0,0),T,U),'ray axis');
    Near(T,5,'ray-axis ray parameter'); Near(U,0,'ray-axis axis parameter');

    SetIdentity(M); Check(TryProject(Vector3d(0,0,0),M,100,100,Screen),'project');
    Near(Screen.X,50,'screen x'); Near(Screen.Y,50,'screen y');
    Check(TryUnproject(Screen.X,Screen.Y,Screen.Depth,M,100,100,Q),'unproject');
    Near(Q.X,0,'unproject x'); Near(Q.Y,0,'unproject y');
    Check(TryScreenAxisDelta(Vector3d(0,0,0),Vector3d(1,0,0),1,M,100,100,10,0,Delta),'axis delta');
    Near(Delta.X,0.2,'axis delta value');

    Check(TryFitDistance(B,Vector3d(1,0,0),Vector3d(0,1,0),Vector3d(0,0,-1),90,1,1,D),'fit');
    Near(D,5,'fit distance');

    Scene:=T3dScene.Create;
    try Node:=T3dNode.Create; Node.Id:=1; Node.Bounds:=B; SetIdentity(Node.WorldTransform); Scene.AddNode(Node);
      Node:=T3dNode.Create; Node.Id:=2; Node.Bounds:=B; SetIdentity(Node.WorldTransform); Node.WorldTransform[12]:=10; Scene.AddNode(Node);
      TB:=SceneOrSelectionBounds(Scene,[]); Near(TB.Min.X,-1,'scene min'); Near(TB.Max.X,11,'scene max');
      Ids[0]:=2; TB:=SceneOrSelectionBounds(Scene,Ids); Near(TB.Min.X,9,'selection min'); Near(TB.Max.X,11,'selection max');
    finally Scene.Free; end;
    WriteLn('RESULT ThreeDMath passed');
  except on E:Exception do begin WriteLn(StdErr,'RESULT ThreeDMath failed: ',E.Message); Halt(1); end; end;
end.
