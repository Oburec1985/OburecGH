unit u3dOpenGLRenderer;

{ Compatibility OpenGL renderer for a caller-owned scene. It never fabricates
  render-only geometry, so rendering, picking, and fitting observe one graph. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Math, gl, u3dCoreTypes, u3dScene, u3dContracts, u3dCamera,
  u3dGeometryMath;

type
  T3dOpenGLRenderer = class(TInterfacedObject, I3dRenderer)
  private
    fHost: I3dRenderHost;
    procedure ConfigureLighting(const AOptions: T3dRenderOptions);
    procedure DrawAxes(const ACamera:T3dCameraSnapshot; AWidth,AHeight:Integer);
    procedure DrawMesh(ANode: T3dNode; AMesh: T3dMeshData;
      const AOptions: T3dRenderOptions);
    procedure DrawScene(AScene: T3dScene; const AOptions: T3dRenderOptions);
    procedure DrawNodeGeometry(AScene:T3dScene; ANode:T3dNode;
      const AOptions:T3dRenderOptions);
    procedure DrawSelectionAxes(ANode: T3dNode; AHotAxis,
      ASelectedAxis: Integer; ANormalizeScale:Boolean=False);
    procedure DrawDummyBoxes(AScene:T3dScene; const ACamera:T3dCameraSnapshot;
      AHeight:Integer; const AOptions:T3dRenderOptions);
    procedure DrawVertexHighlight(ANode: T3dNode; AMesh: T3dMeshData;
      const AHighlight: T3dVertexHighlight);
    procedure DrawShape(ANode: T3dNode);
    procedure DrawSelectionBounds(ANode: T3dNode);
    procedure DrawCameraOverlay(const AOptions: T3dRenderOptions;
      W, H: Integer);
  public
    constructor Create(const AHost: I3dRenderHost);
    procedure Render(AScene: T3dScene; const ACamera: T3dCamera;
      const AOptions: T3dRenderOptions);
  end;

implementation

procedure T3dOpenGLRenderer.ConfigureLighting(
  const AOptions: T3dRenderOptions);
var
  lAmbient, lDiffuse, lSpecular, lDirection: array[0..3] of GLfloat;
begin
  if not AOptions.UseDefaultLighting then
  begin
    glDisable(GL_LIGHT0);
    glDisable(GL_LIGHTING);
    Exit;
  end;

  lAmbient[0] := AOptions.DefaultAmbient;
  lAmbient[1] := AOptions.DefaultAmbient;
  lAmbient[2] := AOptions.DefaultAmbient;
  lAmbient[3] := 1;
  lDiffuse[0] := AOptions.DefaultDiffuse;
  lDiffuse[1] := AOptions.DefaultDiffuse;
  lDiffuse[2] := AOptions.DefaultDiffuse;
  lDiffuse[3] := 1;
  lSpecular[0] := 0.18;
  lSpecular[1] := 0.18;
  lSpecular[2] := 0.18;
  lSpecular[3] := 1;
  lDirection[0] := AOptions.DefaultLightDirection.X;
  lDirection[1] := AOptions.DefaultLightDirection.Y;
  lDirection[2] := AOptions.DefaultLightDirection.Z;
  lDirection[3] := 0;

  glLightfv(GL_LIGHT0, GL_AMBIENT, @lAmbient[0]);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @lDiffuse[0]);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @lSpecular[0]);
  glLightfv(GL_LIGHT0, GL_POSITION, @lDirection[0]);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHTING);
  glEnable(GL_NORMALIZE);
  glEnable(GL_COLOR_MATERIAL);
  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
end;

constructor T3dOpenGLRenderer.Create(const AHost: I3dRenderHost);
begin
  inherited Create;
  fHost := AHost;
end;

procedure T3dOpenGLRenderer.DrawCameraOverlay(
  const AOptions: T3dRenderOptions; W, H: Integer);

var
  lIndex: Integer;
  lAngle, lX, lY, lRadius: Single;

procedure SetHandleColor(AHandle: Integer; R, G, B: Single);
begin
  if AOptions.CameraOverlaySelected = AHandle then
    glColor3f(1, 1, 0)
  else if AOptions.CameraOverlayHover = AHandle then
    glColor3f(Min(1, R + 0.35), Min(1, G + 0.35), Min(1, B + 0.35))
  else
    glColor3f(R, G, B);
end;

begin
  if not AOptions.CameraOverlayVisible then
    Exit;
  glDisable(GL_LIGHTING);
  lRadius := Max(36, Min(W, H) * 0.22);
  glDisable(GL_DEPTH_TEST);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  glOrtho(0, W, 0, H, -1, 1);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
  glTranslatef(W * 0.5, H * 0.5, 0);
  glLineWidth(3);
  SetHandleColor(2, 0.2, 0.55, 1);
  glBegin(GL_LINE_LOOP);
  for lIndex := 0 to 63 do
  begin
    lAngle := 2 * Pi * lIndex / 64;
    lX := Cos(lAngle) * lRadius;
    lY := Sin(lAngle) * lRadius;
    glVertex2f(lX, lY);
  end;
  glEnd;
  glBegin(GL_LINES);
  SetHandleColor(0, 0.1, 0.9, 0.2);
  glVertex2f(-lRadius, 0);
  glVertex2f(lRadius, 0);
  SetHandleColor(1, 1, 0.15, 0.15);
  glVertex2f(0, -lRadius);
  glVertex2f(0, lRadius);
  glEnd;
  glPopMatrix;
  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
end;

procedure T3dOpenGLRenderer.DrawSelectionBounds(ANode: T3dNode);

const
  CEdges: array[0..11, 0..1] of Byte = (
    (0, 1), (1, 3), (3, 2), (2, 0),
    (4, 5), (5, 7), (7, 6), (6, 4),
    (0, 4), (1, 5), (2, 6), (3, 7));

var
  lCorner, lEdge: Integer;
  lPoints: array[0..7] of T3dVector;
begin
  if (ANode = nil) or not ANode.Bounds.Valid then
    Exit;
  glDisable(GL_LIGHTING);
  for lCorner := 0 to 7 do
  begin
    if (lCorner and 1) = 0 then
      lPoints[lCorner].X := ANode.Bounds.Min.X
    else
      lPoints[lCorner].X := ANode.Bounds.Max.X;
    if (lCorner and 2) = 0 then
      lPoints[lCorner].Y := ANode.Bounds.Min.Y
    else
      lPoints[lCorner].Y := ANode.Bounds.Max.Y;
    if (lCorner and 4) = 0 then
      lPoints[lCorner].Z := ANode.Bounds.Min.Z
    else
      lPoints[lCorner].Z := ANode.Bounds.Max.Z;
  end;
  glPushMatrix;
  glMultMatrixf(@ANode.WorldTransform[0]);
  glLineWidth(1.5);
  glColor3f(1, 0.85, 0.15);
  glBegin(GL_LINES);
  for lEdge := 0 to High(CEdges) do
  begin
    with lPoints[CEdges[lEdge, 0]] do
      glVertex3f(X, Y, Z);
    with lPoints[CEdges[lEdge, 1]] do
      glVertex3f(X, Y, Z);
  end;
  glEnd;
  glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawAxes(const ACamera:T3dCameraSnapshot;
  AWidth,AHeight:Integer);

const
  { The 3D host overlays a 48 px toolbar at the bottom. Keep the complete
    projected axis, arrowhead and label above it in every camera orientation. }
  COriginX = 40;
  COriginY = 92;
  CAxisLength = 26;
  CLabelSize = 4;

  procedure DrawLabel(AxisIndex:Integer; X,Y:Single);
  begin
    glBegin(GL_LINES);
    case AxisIndex of
      0:
        begin
          glVertex2f(X-CLabelSize,Y-CLabelSize);
          glVertex2f(X+CLabelSize,Y+CLabelSize);
          glVertex2f(X-CLabelSize,Y+CLabelSize);
          glVertex2f(X+CLabelSize,Y-CLabelSize);
        end;
      1:
        begin
          glVertex2f(X-CLabelSize,Y+CLabelSize);
          glVertex2f(X,Y);
          glVertex2f(X+CLabelSize,Y+CLabelSize);
          glVertex2f(X,Y);
          glVertex2f(X,Y);
          glVertex2f(X,Y-CLabelSize);
        end;
      2:
        begin
          glVertex2f(X-CLabelSize,Y+CLabelSize);
          glVertex2f(X+CLabelSize,Y+CLabelSize);
          glVertex2f(X+CLabelSize,Y+CLabelSize);
          glVertex2f(X-CLabelSize,Y-CLabelSize);
          glVertex2f(X-CLabelSize,Y-CLabelSize);
          glVertex2f(X+CLabelSize,Y-CLabelSize);
        end;
    end;
    glEnd;
  end;

  procedure DrawAxis(AxisIndex:Integer; const AAxis:T3dVector);
  var
    DX,DY,Depth,ProjectedLength,EndX,EndY,PerpX,PerpY,Angle:Single;
    I:Integer;
  begin
    DX:=AAxis.X*ACamera.Right.X+AAxis.Y*ACamera.Right.Y+
      AAxis.Z*ACamera.Right.Z;
    DY:=AAxis.X*ACamera.Up.X+AAxis.Y*ACamera.Up.Y+
      AAxis.Z*ACamera.Up.Z;
    Depth:=AAxis.X*ACamera.Forward.X+AAxis.Y*ACamera.Forward.Y+
      AAxis.Z*ACamera.Forward.Z;
    case AxisIndex of
      0: glColor3f(1,0.2,0.2);
      1: glColor3f(0.2,1,0.2);
      2: glColor3f(0.2,0.5,1);
    end;
    ProjectedLength:=Sqrt(DX*DX+DY*DY);
    if ProjectedLength<0.08 then
    begin
      { An axis parallel to the view has no screen direction. A ring with a
        point/cross keeps it visible without inventing a false direction. }
      glBegin(GL_LINE_LOOP);
      for I:=0 to 15 do
      begin
        Angle:=2*Pi*I/16;
        glVertex2f(COriginX+Cos(Angle)*5,COriginY+Sin(Angle)*5);
      end;
      glEnd;
      if Depth>=0 then
      begin
        glPointSize(4);
        glBegin(GL_POINTS);
        glVertex2f(COriginX,COriginY);
        glEnd;
      end
      else
      begin
        glBegin(GL_LINES);
        glVertex2f(COriginX-3,COriginY-3);
        glVertex2f(COriginX+3,COriginY+3);
        glVertex2f(COriginX-3,COriginY+3);
        glVertex2f(COriginX+3,COriginY-3);
        glEnd;
      end;
      DrawLabel(AxisIndex,COriginX+8+AxisIndex*7,COriginY-8);
      Exit;
    end;
    EndX:=COriginX+DX*CAxisLength;
    EndY:=COriginY+DY*CAxisLength;
    PerpX:=-DY/ProjectedLength;
    PerpY:=DX/ProjectedLength;
    glBegin(GL_LINES);
    glVertex2f(COriginX,COriginY);
    glVertex2f(EndX,EndY);
    glVertex2f(EndX,EndY);
    glVertex2f(EndX-DX/ProjectedLength*6+PerpX*3,
      EndY-DY/ProjectedLength*6+PerpY*3);
    glVertex2f(EndX,EndY);
    glVertex2f(EndX-DX/ProjectedLength*6-PerpX*3,
      EndY-DY/ProjectedLength*6-PerpY*3);
    glEnd;
    DrawLabel(AxisIndex,EndX+DX/ProjectedLength*7,
      EndY+DY/ProjectedLength*7);
  end;

begin
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  glOrtho(0,AWidth,0,AHeight,-1,1);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glLineWidth(2);
  DrawAxis(0,Vector3d(1,0,0));
  DrawAxis(1,Vector3d(0,1,0));
  DrawAxis(2,Vector3d(0,0,1));
  glPopMatrix;
  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
end;

procedure T3dOpenGLRenderer.DrawMesh(ANode: T3dNode; AMesh: T3dMeshData;
                                     const AOptions: T3dRenderOptions);

var
  I: Integer;
  M: T3dMeshData;
  P, N: T3dVector;
  C: T3dColor;
  lDrawFill, lDrawWireframe, lDrawPoints, lDrawNormals: Boolean;
  lDepthTestWasEnabled: GLboolean;

  procedure SetCornerColor(AIndex:LongWord);
  begin
    if ANode.HasColorOverride then
      C:=ANode.ColorOverride
    else if AIndex<LongWord(Length(M.VertexColors)) then
      C:=M.VertexColors[AIndex]
    else
      C:=M.Color;
    glColor3ub(C.R,C.G,C.B);
  end;
begin
  M := AMesh;
  if M = nil then
    Exit;
  if ANode.HasRenderOverride then
  begin
    lDrawFill := ANode.DrawFillOverride;
    lDrawWireframe := ANode.DrawWireframeOverride;
    lDrawPoints := ANode.DrawPointsOverride;
    lDrawNormals := ANode.DrawNormalsOverride;
  end
  else
  begin
    lDrawFill := AOptions.DrawFill;
    lDrawWireframe := AOptions.DrawWireframe;
    lDrawPoints := AOptions.DrawPoints;
    lDrawNormals := AOptions.DrawNormals;
  end;
  glPushMatrix;
  glMultMatrixf(@ANode.WorldTransform[0]);
  if lDrawFill then
  begin
    if AOptions.UseDefaultLighting and RenderPassUsesLighting(rpMeshFill) then
      glEnable(GL_LIGHTING)
    else
      glDisable(GL_LIGHTING);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    if ANode.HasColorOverride then
      C := ANode.ColorOverride
    else
      C := M.Color;
    glColor3ub(C.R, C.G, C.B);
    glBegin(GL_TRIANGLES);
    for I := 0 to High(M.Triangles) do
    begin
      if Length(M.Normals) > Integer(M.Triangles[I].A) then
        N := M.Normals[M.Triangles[I].A]
      else
        N := Vector3d(0, 0, 1);
      glNormal3f(N.X, N.Y, N.Z);
      SetCornerColor(M.Triangles[I].A);
      P := M.Positions[M.Triangles[I].A];
      glVertex3f(P.X, P.Y, P.Z);
      if Length(M.Normals) > Integer(M.Triangles[I].B) then
        N := M.Normals[M.Triangles[I].B]
      else
        N := Vector3d(0, 0, 1);
      glNormal3f(N.X, N.Y, N.Z);
      SetCornerColor(M.Triangles[I].B);
      P := M.Positions[M.Triangles[I].B];
      glVertex3f(P.X, P.Y, P.Z);
      if Length(M.Normals) > Integer(M.Triangles[I].C) then
        N := M.Normals[M.Triangles[I].C]
      else
        N := Vector3d(0, 0, 1);
      glNormal3f(N.X, N.Y, N.Z);
      SetCornerColor(M.Triangles[I].C);
      P := M.Positions[M.Triangles[I].C];
      glVertex3f(P.X, P.Y, P.Z);
    end;
    glEnd;
  end;
  glDisable(GL_LIGHTING);
  if lDrawWireframe then
  begin
    glDisable(GL_LIGHTING);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glColor3f(0.95, 0.8, 0.15);
    if Length(M.WireEdges)>0 then
    begin
      glBegin(GL_LINES);
      for I:=0 to High(M.WireEdges) do
      begin
        P:=M.Positions[M.WireEdges[I].A];
        glVertex3f(P.X,P.Y,P.Z);
        P:=M.Positions[M.WireEdges[I].B];
        glVertex3f(P.X,P.Y,P.Z);
      end;
    end
    else
    begin
      glBegin(GL_TRIANGLES);
      for I := 0 to High(M.Triangles) do
      begin
        P := M.Positions[M.Triangles[I].A];
        glVertex3f(P.X, P.Y, P.Z);
        P := M.Positions[M.Triangles[I].B];
        glVertex3f(P.X, P.Y, P.Z);
        P := M.Positions[M.Triangles[I].C];
        glVertex3f(P.X, P.Y, P.Z);
      end;
    end;
    glEnd;
  end;
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  if lDrawPoints then
  begin
    lDepthTestWasEnabled := glIsEnabled(GL_DEPTH_TEST);
    if not RenderPassUsesDepthTest(rpPoints) then
      glDisable(GL_DEPTH_TEST);
    glPointSize(4);
    glColor3ub(AOptions.PointColor.R,AOptions.PointColor.G,
      AOptions.PointColor.B);
    glBegin(GL_POINTS);
    for I := 0 to High(M.Positions) do
    begin
      P := M.Positions[I];
      glVertex3f(P.X, P.Y, P.Z);
    end;
    glEnd;
    if lDepthTestWasEnabled = GL_TRUE then
      glEnable(GL_DEPTH_TEST);
  end;
  if lDrawNormals then
  begin
    glColor3f(0.2, 1, 1);
    glBegin(GL_LINES);
    for I := 0 to Min(High(M.Positions), High(M.Normals)) do
    begin
      P := M.Positions[I];
      N := M.Normals[I];
      glVertex3f(P.X, P.Y, P.Z);
      glVertex3f(P.X + N.X * AOptions.NormalLength,
        P.Y + N.Y * AOptions.NormalLength,
        P.Z + N.Z * AOptions.NormalLength);
    end;
    glEnd;
  end;
  glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawSelectionAxes(ANode: T3dNode; AHotAxis,
  ASelectedAxis: Integer; ANormalizeScale:Boolean);
var Origin,XAxis,YAxis,ZAxis:T3dVector;
begin
  glDisable(GL_LIGHTING);
  glPushMatrix;
  if ANormalizeScale then
  begin
    Origin:=Vector3d(ANode.WorldTransform[12],ANode.WorldTransform[13],ANode.WorldTransform[14]);
    if not TryNormalize(Vector3d(ANode.WorldTransform[0],ANode.WorldTransform[1],ANode.WorldTransform[2]),XAxis) then XAxis:=Vector3d(1,0,0);
    if not TryNormalize(Vector3d(ANode.WorldTransform[4],ANode.WorldTransform[5],ANode.WorldTransform[6]),YAxis) then YAxis:=Vector3d(0,1,0);
    if not TryNormalize(Vector3d(ANode.WorldTransform[8],ANode.WorldTransform[9],ANode.WorldTransform[10]),ZAxis) then ZAxis:=Vector3d(0,0,1);
  end else glMultMatrixf(@ANode.WorldTransform[0]);
  glLineWidth(4);
  glBegin(GL_LINES);
  if ASelectedAxis = 1 then
    glColor3f(1, 1, 0)
  else if AHotAxis = 1 then
    glColor3f(1, 0.7, 0.3)
  else
    glColor3f(1, 0, 0);
  if ANormalizeScale then begin glVertex3f(Origin.X,Origin.Y,Origin.Z); glVertex3f(Origin.X+XAxis.X*1.5,Origin.Y+XAxis.Y*1.5,Origin.Z+XAxis.Z*1.5); end
  else begin glVertex3f(0,0,0); glVertex3f(1.5,0,0); end;
  if ASelectedAxis = 2 then
    glColor3f(1, 1, 0)
  else if AHotAxis = 2 then
    glColor3f(0.7, 1, 0.3)
  else
    glColor3f(0, 1, 0);
  if ANormalizeScale then begin glVertex3f(Origin.X,Origin.Y,Origin.Z); glVertex3f(Origin.X+YAxis.X*1.5,Origin.Y+YAxis.Y*1.5,Origin.Z+YAxis.Z*1.5); end
  else begin glVertex3f(0,0,0); glVertex3f(0,1.5,0); end;
  if ASelectedAxis = 3 then
    glColor3f(1, 1, 0)
  else if AHotAxis = 3 then
    glColor3f(0.4, 0.8, 1)
  else
    glColor3f(0, 0.5, 1);
  if ANormalizeScale then begin glVertex3f(Origin.X,Origin.Y,Origin.Z); glVertex3f(Origin.X+ZAxis.X*1.5,Origin.Y+ZAxis.Y*1.5,Origin.Z+ZAxis.Z*1.5); end
  else begin glVertex3f(0,0,0); glVertex3f(0,0,1.5); end;
  glEnd;
  glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawDummyBoxes(AScene:T3dScene;
  const ACamera:T3dCameraSnapshot; AHeight:Integer;
  const AOptions:T3dRenderOptions);
const Edges:array[0..11,0..1] of Byte=((0,1),(1,3),(3,2),(2,0),
  (4,5),(5,7),(7,6),(6,4),(0,4),(1,5),(2,6),(3,7));
var I,J:Integer; N:T3dNode; C,X,Y,Z,P:T3dVector; V:array[0..7] of T3dVector;
  Depth,HalfSize,ProjectionY:Single; DepthWas:GLboolean;
begin
  if (AScene=nil) or (AHeight<=0) then Exit;
  ProjectionY:=Abs(ACamera.ProjectionMatrix[5]);
  for I:=0 to High(AScene.Nodes) do
  begin
    N:=AScene.Nodes[I];
    if N.Kind<>nkDummy then Continue;
    C:=Vector3d(N.WorldTransform[12],N.WorldTransform[13],N.WorldTransform[14]);
    Depth:=Abs(VectorDot(VectorSubtract(C,ACamera.Position),ACamera.Forward));
    if Abs(ACamera.ProjectionMatrix[15]-1)<0.01 then
      HalfSize:=10*2/Max(1,ProjectionY*AHeight)
    else
      HalfSize:=10*2*Max(Depth,ACamera.NearPlane)/Max(1,ProjectionY*AHeight);
    X:=Vector3d(N.WorldTransform[0],N.WorldTransform[1],N.WorldTransform[2]);
    Y:=Vector3d(N.WorldTransform[4],N.WorldTransform[5],N.WorldTransform[6]);
    Z:=Vector3d(N.WorldTransform[8],N.WorldTransform[9],N.WorldTransform[10]);
    if not TryNormalize(X,X) then X:=Vector3d(1,0,0);
    if not TryNormalize(Y,Y) then Y:=Vector3d(0,1,0);
    if not TryNormalize(Z,Z) then Z:=Vector3d(0,0,1);
    for J:=0 to 7 do
    begin
      P:=C;
      if (J and 1)=0 then P:=VectorSubtract(P,VectorScale(X,HalfSize)) else P:=VectorAdd(P,VectorScale(X,HalfSize));
      if (J and 2)=0 then P:=VectorSubtract(P,VectorScale(Y,HalfSize)) else P:=VectorAdd(P,VectorScale(Y,HalfSize));
      if (J and 4)=0 then P:=VectorSubtract(P,VectorScale(Z,HalfSize)) else P:=VectorAdd(P,VectorScale(Z,HalfSize));
      V[J]:=P;
    end;
    DepthWas:=glIsEnabled(GL_DEPTH_TEST);
    if AOptions.OverlayNodeId=N.Id then begin glDisable(GL_DEPTH_TEST); glColor3f(1,0.85,0.15); end
    else glColor3f(1,0.55,0.05);
    glDisable(GL_LIGHTING); glBegin(GL_LINES);
    for J:=0 to 11 do begin P:=V[Edges[J,0]]; glVertex3f(P.X,P.Y,P.Z); P:=V[Edges[J,1]]; glVertex3f(P.X,P.Y,P.Z); end;
    glEnd;
    if DepthWas=GL_TRUE then glEnable(GL_DEPTH_TEST) else glDisable(GL_DEPTH_TEST);
  end;
end;

procedure T3dOpenGLRenderer.DrawVertexHighlight(ANode: T3dNode;
  AMesh: T3dMeshData; const AHighlight: T3dVertexHighlight);
var
  I: Integer;
  CornerIndex: LongWord;
  P: T3dVector;
  lDepthTestWasEnabled: GLboolean;
begin
  if (ANode = nil) or (AMesh = nil) then
    Exit;
  glPushMatrix;
  glMultMatrixf(@ANode.WorldTransform[0]);
  glDisable(GL_LIGHTING);
  lDepthTestWasEnabled := glIsEnabled(GL_DEPTH_TEST);
  if not RenderPassUsesDepthTest(rpVertexHighlight) then
    glDisable(GL_DEPTH_TEST);
  glPointSize(7);
  glBegin(GL_POINTS);
  glColor3f(0.25, 1, 0.25);
  for I := 0 to High(AHighlight.AdjacentCornerIndices) do
  begin
    CornerIndex := AHighlight.AdjacentCornerIndices[I];
    if CornerIndex >= LongWord(Length(AMesh.Positions)) then
      Continue;
    P := AMesh.Positions[CornerIndex];
    glVertex3f(P.X, P.Y, P.Z);
  end;
  glColor3f(1, 0.8, 0);
  for I := 0 to High(AHighlight.PrimaryCornerIndices) do
  begin
    CornerIndex := AHighlight.PrimaryCornerIndices[I];
    if CornerIndex >= LongWord(Length(AMesh.Positions)) then
      Continue;
    P := AMesh.Positions[CornerIndex];
    glVertex3f(P.X, P.Y, P.Z);
  end;
  glEnd;
  if lDepthTestWasEnabled = GL_TRUE then
    glEnable(GL_DEPTH_TEST);
  glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawShape(ANode: T3dNode);
var
  I, J: Integer;
  P: T3dVector;
begin
  if ANode = nil then
    Exit;
  glPushMatrix;
  glMultMatrixf(@ANode.WorldTransform[0]);
  glDisable(GL_LIGHTING);
  glColor3f(0.2, 0.85, 1);
  glLineWidth(2);
  for I := 0 to High(ANode.ShapeLines) do
  begin
    if Length(ANode.ShapeLines[I].Points) = 0 then
      Continue;
    if ShapePrimitive(ANode.ShapeLines[I].Closed) = spLineLoop then
      glBegin(GL_LINE_LOOP)
    else
      glBegin(GL_LINE_STRIP);
    for J := 0 to High(ANode.ShapeLines[I].Points) do
    begin
      P := ANode.ShapeLines[I].Points[J];
      glVertex3f(P.X, P.Y, P.Z);
    end;
    glEnd;
  end;
  glPointSize(5);
  glColor3f(0.2, 0.45, 1);
  glBegin(GL_POINTS);
  for I := 0 to High(ANode.ShapeLines) do
    for J := 0 to High(ANode.ShapeLines[I].Points) do
    begin
      P := ANode.ShapeLines[I].Points[J];
      glVertex3f(P.X, P.Y, P.Z);
    end;
  glEnd;
  glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawScene(AScene: T3dScene;
                                      const AOptions: T3dRenderOptions);

var
  I: Integer;
  lSelectedNode: T3dNode;
  lDepthTestWasEnabled:GLboolean;
  lOverlayOptions:T3dRenderOptions;
begin
  if AScene = nil then
    Exit;
  for I := 0 to High(AScene.Nodes) do
    DrawNodeGeometry(AScene,AScene.Nodes[I],AOptions);
  if AOptions.SelectedNodeId <> 0 then
  begin
    lSelectedNode := AScene.FindNode(AOptions.SelectedNodeId);
    if lSelectedNode <> nil then
    begin
      if AOptions.OverlayNodeId=lSelectedNode.Id then
      begin
        lDepthTestWasEnabled:=glIsEnabled(GL_DEPTH_TEST);
        if not RenderPassUsesDepthTest(rpSelectedHelperOverlay) then
          glDisable(GL_DEPTH_TEST);
        lOverlayOptions:=AOptions;
        lOverlayOptions.DrawFill:=True;
        DrawNodeGeometry(AScene,lSelectedNode,lOverlayOptions);
        DrawSelectionBounds(lSelectedNode);
        DrawSelectionAxes(lSelectedNode,AOptions.HotAxis,
          AOptions.SelectedAxis,True);
        if lDepthTestWasEnabled=GL_TRUE then glEnable(GL_DEPTH_TEST)
        else glDisable(GL_DEPTH_TEST);
      end
      else
      begin
        DrawSelectionBounds(lSelectedNode);
        DrawSelectionAxes(lSelectedNode,AOptions.HotAxis,
          AOptions.SelectedAxis);
      end;
    end;
  end;
end;

procedure T3dOpenGLRenderer.DrawNodeGeometry(AScene:T3dScene; ANode:T3dNode;
  const AOptions:T3dRenderOptions);
var
  Mesh:T3dMeshData;
  SourceNode:T3dNode;
begin
  if (AScene=nil) or (ANode=nil) then Exit;
  case ANode.Kind of
    nkMesh:
      begin
        Mesh:=ANode.Mesh;
        if (Mesh<>nil) and (Length(Mesh.Positions)=0) and
           (Mesh.SourceNodeId<>0) then
        begin
          SourceNode:=AScene.FindNode(Mesh.SourceNodeId);
          if SourceNode<>nil then Mesh:=SourceNode.Mesh;
        end;
        DrawMesh(ANode,Mesh,AOptions);
        if AOptions.VertexHighlight.NodeId=ANode.Id then
          DrawVertexHighlight(ANode,Mesh,AOptions.VertexHighlight);
      end;
    nkShape:DrawShape(ANode);
  end;
end;

procedure T3dOpenGLRenderer.Render(AScene: T3dScene; const ACamera: T3dCamera;
                                   const AOptions: T3dRenderOptions);

var
  W, H: Integer;
  R, G, B: Single;
  lCamera: T3dCameraSnapshot;
begin
  W := fHost.RenderWidth;
  H := fHost.RenderHeight;
  if (W <= 0) or (H <= 0) then
    Exit;
  if not fHost.ActivateContext then
    Exit;
  R := (AOptions.BackgroundColor and $FF) / 255;
  G := ((AOptions.BackgroundColor shr 8) and $FF) / 255;
  B := ((AOptions.BackgroundColor shr 16) and $FF) / 255;
  glViewport(0, 0, W, H);
  glClearColor(R, G, B, 1);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glEnable(GL_DEPTH_TEST);
  lCamera := BuildCameraSnapshot(ACamera, W, H,
    Max(AOptions.SceneClipRadius, 0));
  glMatrixMode(GL_PROJECTION);
  glLoadMatrixf(@lCamera.ProjectionMatrix[0]);
  glMatrixMode(GL_MODELVIEW);
  glLoadMatrixf(@lCamera.ViewMatrix[0]);
  ConfigureLighting(AOptions);
  DrawScene(AScene, AOptions);
  DrawDummyBoxes(AScene,lCamera,H,AOptions);
  { DrawScene may be empty, so establish the overlay state independently of
    whether a mesh pass happened to disable fixed-function lighting. }
  glDisable(GL_LIGHTING);
  if AOptions.ShowAxes then
    DrawAxes(lCamera,W,H);
  DrawCameraOverlay(AOptions, W, H);
  glPopAttrib;
  glFlush;
  fHost.PresentFrame;
end;

end.
