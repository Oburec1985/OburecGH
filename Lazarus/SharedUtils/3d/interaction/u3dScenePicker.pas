unit u3dScenePicker;



{ Stateless scene-picking strategy. The caller owns the scene; interface
  implementations own no nodes or meshes and may be replaced for another
  acceleration structure without coupling selection to rendering. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses u3dCoreTypes,u3dScene,u3dInteractionTypes;

type
  T3dHit = record
    NodeId: QWord;
    TriangleId: Integer;
    Distance: Single;
    WorldPoint: T3dVector;
    Barycentric: T3dVector;
  end;

  I3dScenePicker = interface
    ['{BC85B9DF-B722-4B1C-901F-ED905076B36A}']
    { Direction may have any usable length. Distance and WorldPoint are
      returned in world units; zero or near-zero direction is rejected. }
    function Pick(AScene:T3dScene; const ARay:T3dRay;
      out AHit:T3dHit): Boolean;
  end;

  T3dCpuScenePicker = class(TInterfacedObject,I3dScenePicker)
  public
    function Pick(AScene:T3dScene; const ARay:T3dRay; out AHit:T3dHit): Boolean;
  end;

implementation

uses Math,u3dSceneMath;

const CEpsilon = 1E-7;

function Subtract(const A,B:T3dVector): T3dVector;
begin
  Result := Vector3d(A.X-B.X,A.Y-B.Y,A.Z-B.Z);
end;

function Cross(const A,B:T3dVector): T3dVector;
begin
  Result := Vector3d(A.Y*B.Z-A.Z*B.Y,A.Z*B.X-A.X*B.Z,
            A.X*B.Y-A.Y*B.X);
end;

function Dot(const A,B:T3dVector): Single;
begin
  Result := A.X*B.X+A.Y*B.Y+A.Z*B.Z;
end;

function WorldPoint(const P:T3dVector; const M:T3dMatrix): T3dVector;
begin
  Result := Vector3d(P.X*M[0]+P.Y*M[4]+P.Z*M[8]+M[12],
            P.X*M[1]+P.Y*M[5]+P.Z*M[9]+M[13],
            P.X*M[2]+P.Y*M[6]+P.Z*M[10]+M[14]);
end;

function RayTriangle(const R:T3dRay; const A,B,C:T3dVector;
                     out T,U,V:Single): Boolean;

var E1,E2,P,Q,S: T3dVector;
  Det,Inv: Single;
begin
  E1 := Subtract(B,A);
  E2 := Subtract(C,A);
  P := Cross(R.Direction,E2);
  Det := Dot(E1,P);
  if Abs(Det)<CEpsilon then
    Exit(False);
  Inv := 1/Det;
  S := Subtract(R.Origin,A);
  U := Dot(S,P)*Inv;
  if (U<0) or (U>1) then
    Exit(False);
  Q := Cross(S,E1);
  V := Dot(R.Direction,Q)*Inv;
  if (V<0) or (U+V>1) then
    Exit(False);
  T := Dot(E2,Q)*Inv;
  Result := T>=0;
end;

function NodeMesh(AScene:T3dScene; ANode:T3dNode): T3dMeshData;

var Source: T3dNode;
begin
  Result := ANode.Mesh;
  if (Result<>nil) and (Length(Result.Positions)=0) and
     (Result.SourceNodeId<>0) then
    begin
      Source := AScene.FindNode(Result.SourceNodeId);
      if Source<>nil then
        Result := Source.Mesh;
    end;
end;

function T3dCpuScenePicker.Pick(AScene:T3dScene; const ARay:T3dRay;
                                out AHit:T3dHit): Boolean;

var I,J: Integer;
  N: T3dNode;
  M: T3dMeshData;
  Tri: T3dTriangle;
  R: T3dRay;
  A,B,C: T3dVector;
  T,U,V,BoxDistance,Best,DirectionLength: Single;
  Bounds: T3dBounds;
begin
  FillChar(AHit,SizeOf(AHit),0);
  Result := False;
  if AScene=nil then
    Exit;
  DirectionLength := Sqrt(Dot(ARay.Direction,ARay.Direction));
  if DirectionLength<=CEpsilon then
    Exit;
  R.Origin := ARay.Origin;
  R.Direction := Vector3d(ARay.Direction.X/DirectionLength,
                 ARay.Direction.Y/DirectionLength,ARay.Direction.Z/DirectionLength);
  Best := MaxSingle;
  for I:=0 to High(AScene.Nodes) do
    begin
    N := AScene.Nodes[I];
    if not (N.Kind in [nkMesh,nkShape]) then
      Continue;
      Bounds := WorldBounds(N);
      if not Bounds.Valid or not RayBoundsDistance(R.Origin,R.Direction,
         Bounds,BoxDistance) or (BoxDistance>Best) then
        Continue;
    if N.Kind=nkShape then
      begin
        if BoxDistance<Best then
          begin
            Best := BoxDistance;
            Result := True;
            AHit.NodeId := N.Id;
            AHit.TriangleId := -1;
            AHit.Distance := BoxDistance;
            AHit.WorldPoint := Vector3d(
              R.Origin.X+R.Direction.X*BoxDistance,
              R.Origin.Y+R.Direction.Y*BoxDistance,
              R.Origin.Z+R.Direction.Z*BoxDistance);
            AHit.Barycentric := Vector3d(0,0,0);
          end;
        Continue;
      end;
    M := NodeMesh(AScene,N);
      if M=nil then
        Continue;
      for J:=0 to High(M.Triangles) do
        begin
          Tri := M.Triangles[J];
          if (Tri.A>=LongWord(Length(M.Positions))) or
             (Tri.B>=LongWord(Length(M.Positions))) or
             (Tri.C>=LongWord(Length(M.Positions))) then
            Continue;
          A := WorldPoint(M.Positions[Tri.A],N.WorldTransform);
          B := WorldPoint(M.Positions[Tri.B],N.WorldTransform);
          C := WorldPoint(M.Positions[Tri.C],N.WorldTransform);
          if RayTriangle(R,A,B,C,T,U,V) and (T<Best) then
            begin
              Best := T;
              Result := True;
              AHit.NodeId := N.Id;
              AHit.TriangleId := J;
              AHit.Distance := T;
              AHit.Barycentric := Vector3d(1-U-V,U,V);
              AHit.WorldPoint := Vector3d(R.Origin.X+R.Direction.X*T,
                                 R.Origin.Y+R.Direction.Y*T,R.Origin.Z+R.Direction.Z*T);
            end;
        end;
    end;
end;

end.
