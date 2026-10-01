unit u3dGeometryMath;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes, u3dScene;

type
  T3dScreenPoint = record X, Y, Depth: Single; end;
  T3dRayValue = record Origin, Direction: T3dVector; end;

function VectorAdd(const ALeft, ARight: T3dVector): T3dVector;
function VectorSubtract(const ALeft, ARight: T3dVector): T3dVector;
function VectorScale(const AValue: T3dVector; AScale: Single): T3dVector;
function VectorDot(const ALeft, ARight: T3dVector): Single;
function VectorCross(const ALeft, ARight: T3dVector): T3dVector;
function TryNormalize(const AValue: T3dVector; out AResult: T3dVector): Boolean;
function TransformPoint(const APoint: T3dVector; const AMatrix: T3dMatrix): T3dVector;
function TransformVector(const AVector: T3dVector; const AMatrix: T3dMatrix): T3dVector;
procedure ComposeMatrices(const ALeft, ARight: T3dMatrix; out AResult: T3dMatrix);
function TryInverseMatrix(const AMatrix: T3dMatrix; out AInverse: T3dMatrix): Boolean;
function TryAxisAngleMatrix(const AAxis: T3dVector; AAngleRadians: Single;
  out AMatrix: T3dMatrix): Boolean;
procedure BoundsCorners(const ABounds: T3dBounds; out ACorners: array of T3dVector);
function TransformBounds(const ABounds: T3dBounds; const AMatrix: T3dMatrix): T3dBounds;
function SceneOrSelectionBounds(AScene: T3dScene; const ASelectedIds: array of QWord): T3dBounds;
function TryRayPlane(const ARay: T3dRayValue; const APlanePoint,
  APlaneNormal: T3dVector; out ADistance: Single; out APoint: T3dVector): Boolean;
function TryClosestRayAxis(const ARay: T3dRayValue; const AAxisOrigin,
  AAxisDirection: T3dVector; out ARayDistance, AAxisDistance: Single): Boolean;
function TryProject(const APoint: T3dVector; const AViewProjection: T3dMatrix;
  AWidth, AHeight: Integer; out AScreen: T3dScreenPoint): Boolean;
function TryUnproject(AScreenX, AScreenY, ADepth: Single;
  const AInverseViewProjection: T3dMatrix; AWidth, AHeight: Integer;
  out APoint: T3dVector): Boolean;
function TryScreenAxisDelta(const AOrigin, AAxis: T3dVector; AAxisLength: Single;
  const AViewProjection: T3dMatrix; AWidth, AHeight: Integer;
  AMouseDeltaX, AMouseDeltaY: Single; out AWorldDelta: T3dVector): Boolean;
function TryFitDistance(const ABounds: T3dBounds; const ARight, AUp,
  AForward: T3dVector; AVerticalFovDegrees, AAspect, AMargin: Single;
  out ADistance: Single): Boolean;

implementation

uses Math;

const Epsilon = 1.0e-6;

function VectorAdd(const ALeft, ARight: T3dVector): T3dVector;
begin Result := Vector3d(ALeft.X + ARight.X, ALeft.Y + ARight.Y, ALeft.Z + ARight.Z); end;
function VectorSubtract(const ALeft, ARight: T3dVector): T3dVector;
begin Result := Vector3d(ALeft.X - ARight.X, ALeft.Y - ARight.Y, ALeft.Z - ARight.Z); end;
function VectorScale(const AValue: T3dVector; AScale: Single): T3dVector;
begin Result := Vector3d(AValue.X * AScale, AValue.Y * AScale, AValue.Z * AScale); end;
function VectorDot(const ALeft, ARight: T3dVector): Single;
begin Result := ALeft.X*ARight.X + ALeft.Y*ARight.Y + ALeft.Z*ARight.Z; end;
function VectorCross(const ALeft, ARight: T3dVector): T3dVector;
begin Result := Vector3d(ALeft.Y*ARight.Z-ALeft.Z*ARight.Y,
  ALeft.Z*ARight.X-ALeft.X*ARight.Z, ALeft.X*ARight.Y-ALeft.Y*ARight.X); end;

function TryNormalize(const AValue: T3dVector; out AResult: T3dVector): Boolean;
var L: Single;
begin
  L := Sqrt(VectorDot(AValue, AValue)); Result := L > Epsilon;
  if Result then AResult := VectorScale(AValue, 1/L) else AResult := Vector3d(0,0,0);
end;

function TransformPoint(const APoint: T3dVector; const AMatrix: T3dMatrix): T3dVector;
var W: Single;
begin
  Result := Vector3d(APoint.X*AMatrix[0]+APoint.Y*AMatrix[4]+APoint.Z*AMatrix[8]+AMatrix[12],
    APoint.X*AMatrix[1]+APoint.Y*AMatrix[5]+APoint.Z*AMatrix[9]+AMatrix[13],
    APoint.X*AMatrix[2]+APoint.Y*AMatrix[6]+APoint.Z*AMatrix[10]+AMatrix[14]);
  W := APoint.X*AMatrix[3]+APoint.Y*AMatrix[7]+APoint.Z*AMatrix[11]+AMatrix[15];
  if Abs(W) > Epsilon then Result := VectorScale(Result, 1/W);
end;

function TransformVector(const AVector: T3dVector; const AMatrix: T3dMatrix): T3dVector;
begin Result := Vector3d(AVector.X*AMatrix[0]+AVector.Y*AMatrix[4]+AVector.Z*AMatrix[8],
  AVector.X*AMatrix[1]+AVector.Y*AMatrix[5]+AVector.Z*AMatrix[9],
  AVector.X*AMatrix[2]+AVector.Y*AMatrix[6]+AVector.Z*AMatrix[10]); end;

procedure ComposeMatrices(const ALeft, ARight: T3dMatrix; out AResult: T3dMatrix);
var Row, Column, K: Integer; V: Single; Temp: T3dMatrix;
begin
  for Column := 0 to 3 do for Row := 0 to 3 do begin V := 0;
    for K := 0 to 3 do V := V + ALeft[K*4+Row]*ARight[Column*4+K];
    Temp[Column*4+Row] := V;
  end;
  AResult := Temp;
end;

function TryInverseMatrix(const AMatrix: T3dMatrix; out AInverse: T3dMatrix): Boolean;
var A: array[0..3,0..7] of Double; Row, Col, Pivot, R: Integer; V, F: Double;
begin
  for Row:=0 to 3 do for Col:=0 to 3 do begin
    A[Row,Col] := AMatrix[Col*4+Row]; A[Row,Col+4] := Ord(Row=Col);
  end;
  for Col:=0 to 3 do begin
    Pivot:=Col; for R:=Col+1 to 3 do if Abs(A[R,Col])>Abs(A[Pivot,Col]) then Pivot:=R;
    if Abs(A[Pivot,Col])<=Epsilon then Exit(False);
    if Pivot<>Col then for R:=0 to 7 do begin V:=A[Col,R]; A[Col,R]:=A[Pivot,R]; A[Pivot,R]:=V; end;
    V:=A[Col,Col]; for R:=0 to 7 do A[Col,R]:=A[Col,R]/V;
    for Row:=0 to 3 do if Row<>Col then begin F:=A[Row,Col];
      for R:=0 to 7 do A[Row,R]:=A[Row,R]-F*A[Col,R]; end;
  end;
  for Row:=0 to 3 do for Col:=0 to 3 do AInverse[Col*4+Row]:=A[Row,Col+4];
  Result:=True;
end;

function TryAxisAngleMatrix(const AAxis: T3dVector; AAngleRadians: Single;
  out AMatrix: T3dMatrix): Boolean;
var N: T3dVector; C,S,T: Single;
begin
  Result:=TryNormalize(AAxis,N); if not Result then begin SetIdentity(AMatrix); Exit; end;
  C:=Cos(AAngleRadians); S:=Sin(AAngleRadians); T:=1-C; SetIdentity(AMatrix);
  AMatrix[0]:=T*N.X*N.X+C; AMatrix[4]:=T*N.X*N.Y-S*N.Z; AMatrix[8]:=T*N.X*N.Z+S*N.Y;
  AMatrix[1]:=T*N.X*N.Y+S*N.Z; AMatrix[5]:=T*N.Y*N.Y+C; AMatrix[9]:=T*N.Y*N.Z-S*N.X;
  AMatrix[2]:=T*N.X*N.Z-S*N.Y; AMatrix[6]:=T*N.Y*N.Z+S*N.X; AMatrix[10]:=T*N.Z*N.Z+C;
end;

procedure BoundsCorners(const ABounds: T3dBounds; out ACorners: array of T3dVector);
var I: Integer;
begin
  if Length(ACorners)<8 then Exit;
  for I:=0 to 7 do begin
    if (I and 1)=0 then ACorners[I].X:=ABounds.Min.X else ACorners[I].X:=ABounds.Max.X;
    if (I and 2)=0 then ACorners[I].Y:=ABounds.Min.Y else ACorners[I].Y:=ABounds.Max.Y;
    if (I and 4)=0 then ACorners[I].Z:=ABounds.Min.Z else ACorners[I].Z:=ABounds.Max.Z;
  end;
end;

function TransformBounds(const ABounds: T3dBounds; const AMatrix: T3dMatrix): T3dBounds;
var C: array[0..7] of T3dVector; I: Integer;
begin Result.Valid:=False; if not ABounds.Valid then Exit; BoundsCorners(ABounds,C);
  for I:=0 to 7 do IncludePoint(Result,TransformPoint(C[I],AMatrix)); end;

function ContainsId(AId: QWord; const AIds: array of QWord): Boolean;
var I: Integer;
begin for I:=0 to High(AIds) do if AIds[I]=AId then Exit(True); Result:=False; end;

function SceneOrSelectionBounds(AScene: T3dScene; const ASelectedIds: array of QWord): T3dBounds;
var I: Integer; B: T3dBounds;
begin
  Result.Valid:=False; if AScene=nil then Exit;
  for I:=0 to High(AScene.Nodes) do begin
    if (Length(ASelectedIds)>0) and not ContainsId(AScene.Nodes[I].Id,ASelectedIds) then Continue;
    B:=TransformBounds(AScene.Nodes[I].Bounds,AScene.Nodes[I].WorldTransform);
    if B.Valid then begin IncludePoint(Result,B.Min); IncludePoint(Result,B.Max); end;
  end;
end;

function TryRayPlane(const ARay: T3dRayValue; const APlanePoint,
  APlaneNormal: T3dVector; out ADistance: Single; out APoint: T3dVector): Boolean;
var N,D: T3dVector; Denominator: Single;
begin
  Result:=TryNormalize(APlaneNormal,N) and TryNormalize(ARay.Direction,D);
  if not Result then Exit;
  Denominator:=VectorDot(D,N); if Abs(Denominator)<=Epsilon then Exit(False);
  ADistance:=VectorDot(VectorSubtract(APlanePoint,ARay.Origin),N)/Denominator;
  Result:=ADistance>=0; if Result then APoint:=VectorAdd(ARay.Origin,VectorScale(D,ADistance));
end;

function TryClosestRayAxis(const ARay: T3dRayValue; const AAxisOrigin,
  AAxisDirection: T3dVector; out ARayDistance, AAxisDistance: Single): Boolean;
var D,A,W: T3dVector; B,Dw,E,Den: Single;
begin
  Result:=TryNormalize(ARay.Direction,D) and TryNormalize(AAxisDirection,A); if not Result then Exit;
  W:=VectorSubtract(ARay.Origin,AAxisOrigin); B:=VectorDot(D,A); Dw:=VectorDot(D,W); E:=VectorDot(A,W);
  Den:=1-B*B; if Abs(Den)<=Epsilon then Exit(False);
  ARayDistance:=(B*E-Dw)/Den; AAxisDistance:=(E-B*Dw)/Den;
  Result:=ARayDistance>=0;
end;

function ClipPoint(const APoint:T3dVector; const M:T3dMatrix; out X,Y,Z,W:Single):Boolean;
begin X:=APoint.X*M[0]+APoint.Y*M[4]+APoint.Z*M[8]+M[12];
  Y:=APoint.X*M[1]+APoint.Y*M[5]+APoint.Z*M[9]+M[13];
  Z:=APoint.X*M[2]+APoint.Y*M[6]+APoint.Z*M[10]+M[14];
  W:=APoint.X*M[3]+APoint.Y*M[7]+APoint.Z*M[11]+M[15]; Result:=Abs(W)>Epsilon; end;

function TryProject(const APoint: T3dVector; const AViewProjection: T3dMatrix;
  AWidth, AHeight: Integer; out AScreen: T3dScreenPoint): Boolean;
var X,Y,Z,W:Single;
begin Result:=(AWidth>0) and (AHeight>0) and ClipPoint(APoint,AViewProjection,X,Y,Z,W); if not Result then Exit;
  AScreen.X:=(X/W+1)*0.5*AWidth; AScreen.Y:=(1-Y/W)*0.5*AHeight; AScreen.Depth:=(Z/W+1)*0.5; end;

function TryUnproject(AScreenX, AScreenY, ADepth: Single;
  const AInverseViewProjection: T3dMatrix; AWidth, AHeight: Integer;
  out APoint: T3dVector): Boolean;
var X,Y,Z,W:Single;
begin
  Result:=(AWidth>0) and (AHeight>0); if not Result then Exit;
  X:=2*AScreenX/AWidth-1; Y:=1-2*AScreenY/AHeight; Z:=2*ADepth-1;
  W:=X*AInverseViewProjection[3]+Y*AInverseViewProjection[7]+Z*AInverseViewProjection[11]+AInverseViewProjection[15];
  if Abs(W)<=Epsilon then Exit(False);
  APoint:=Vector3d((X*AInverseViewProjection[0]+Y*AInverseViewProjection[4]+Z*AInverseViewProjection[8]+AInverseViewProjection[12])/W,
    (X*AInverseViewProjection[1]+Y*AInverseViewProjection[5]+Z*AInverseViewProjection[9]+AInverseViewProjection[13])/W,
    (X*AInverseViewProjection[2]+Y*AInverseViewProjection[6]+Z*AInverseViewProjection[10]+AInverseViewProjection[14])/W);
  Result:=True;
end;

function TryScreenAxisDelta(const AOrigin, AAxis: T3dVector; AAxisLength: Single;
  const AViewProjection: T3dMatrix; AWidth, AHeight: Integer;
  AMouseDeltaX, AMouseDeltaY: Single; out AWorldDelta: T3dVector): Boolean;
var N,Endpoint:T3dVector; S0,S1:T3dScreenPoint; DX,DY,Den,ScaleValue:Single;
begin
  Result:=(Abs(AAxisLength)>Epsilon) and TryNormalize(AAxis,N); if not Result then Exit;
  Endpoint:=VectorAdd(AOrigin,VectorScale(N,AAxisLength));
  Result:=TryProject(AOrigin,AViewProjection,AWidth,AHeight,S0) and TryProject(Endpoint,AViewProjection,AWidth,AHeight,S1);
  if not Result then Exit;
  DX:=S1.X-S0.X; DY:=S1.Y-S0.Y; Den:=DX*DX+DY*DY; if Den<=Epsilon then Exit(False);
  ScaleValue:=(AMouseDeltaX*DX+AMouseDeltaY*DY)/Den*AAxisLength;
  AWorldDelta:=VectorScale(N,ScaleValue); Result:=True;
end;

function TryFitDistance(const ABounds: T3dBounds; const ARight, AUp,
  AForward: T3dVector; AVerticalFovDegrees, AAspect, AMargin: Single;
  out ADistance: Single): Boolean;
var R,U,F,C: T3dVector; Corners: array[0..7] of T3dVector; I:Integer;
  X,Y,Z,MaxX,MaxY,MaxZ,TanV,TanH:Single;
begin
  Result:=ABounds.Valid and (AVerticalFovDegrees>0) and (AVerticalFovDegrees<179) and (AAspect>Epsilon)
    and TryNormalize(ARight,R) and TryNormalize(AUp,U) and TryNormalize(AForward,F); if not Result then Exit;
  if AMargin<1 then AMargin:=1; C:=VectorScale(VectorAdd(ABounds.Min,ABounds.Max),0.5);
  BoundsCorners(ABounds,Corners); MaxX:=0; MaxY:=0; MaxZ:=0;
  for I:=0 to 7 do begin Corners[I]:=VectorSubtract(Corners[I],C);
    X:=Abs(VectorDot(Corners[I],R)); Y:=Abs(VectorDot(Corners[I],U)); Z:=Abs(VectorDot(Corners[I],F));
    if X>MaxX then MaxX:=X; if Y>MaxY then MaxY:=Y; if Z>MaxZ then MaxZ:=Z; end;
  TanV:=Tan(DegToRad(AVerticalFovDegrees)*0.5); TanH:=TanV*AAspect;
  if (TanV<=Epsilon) or (TanH<=Epsilon) then Exit(False);
  ADistance:=(Max(MaxY/TanV,MaxX/TanH)+MaxZ)*AMargin; Result:=ADistance>Epsilon;
end;

end.
