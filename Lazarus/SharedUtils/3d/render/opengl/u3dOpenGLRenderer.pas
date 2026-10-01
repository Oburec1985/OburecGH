unit u3dOpenGLRenderer;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Math, gl, glu, u3dCoreTypes, u3dScene, u3dContracts;

type
  T3dOpenGLRenderer = class(TInterfacedObject, I3dRenderer)
  private
    fHost: I3dRenderHost;
    procedure DrawAxes;
    procedure DrawCube;
    procedure DrawMesh(ANode: T3dNode; AMesh: T3dMeshData;
      const AOptions: T3dRenderOptions);
    procedure DrawScene(AScene: T3dScene; const AOptions: T3dRenderOptions);
    procedure DrawSelectionAxes(ANode: T3dNode; AHotAxis,ASelectedAxis: Integer);
    procedure DrawSelectionBounds(ANode:T3dNode);
    procedure DrawCameraOverlay(const AOptions:T3dRenderOptions; W,H:Integer);
  public
    constructor Create(const AHost: I3dRenderHost);
    procedure Render(AScene: T3dScene; const ACamera: T3dCamera;
      const AOptions: T3dRenderOptions);
  end;

implementation

constructor T3dOpenGLRenderer.Create(const AHost: I3dRenderHost);
begin
  inherited Create;
  fHost := AHost;
end;

procedure T3dOpenGLRenderer.DrawCameraOverlay(const AOptions:T3dRenderOptions;
  W,H:Integer);
var
  lIndex:Integer;
  lAngle,lX,lY,lRadius:Single;
  procedure SetHandleColor(AHandle:Integer; R,G,B:Single);
  begin
    if AOptions.CameraOverlaySelected=AHandle then glColor3f(1,1,0)
    else if AOptions.CameraOverlayHover=AHandle then
      glColor3f(Min(1,R+0.35),Min(1,G+0.35),Min(1,B+0.35))
    else glColor3f(R,G,B);
  end;
begin
  if not AOptions.CameraOverlayVisible then Exit;
  lRadius:=Max(36,Min(W,H)*0.22);
  glDisable(GL_DEPTH_TEST); glMatrixMode(GL_PROJECTION); glPushMatrix;
  glLoadIdentity; glOrtho(0,W,0,H,-1,1); glMatrixMode(GL_MODELVIEW);
  glPushMatrix; glLoadIdentity; glTranslatef(W*0.5,H*0.5,0); glLineWidth(3);
  SetHandleColor(2,0.2,0.55,1); glBegin(GL_LINE_LOOP);
  for lIndex:=0 to 63 do begin lAngle:=2*Pi*lIndex/64;
    lX:=Cos(lAngle)*lRadius; lY:=Sin(lAngle)*lRadius; glVertex2f(lX,lY); end;
  glEnd;
  glBegin(GL_LINES); SetHandleColor(0,0.1,0.9,0.2);
  glVertex2f(-lRadius,0); glVertex2f(lRadius,0);
  SetHandleColor(1,1,0.15,0.15);
  glVertex2f(0,-lRadius); glVertex2f(0,lRadius); glEnd;
  glPopMatrix; glMatrixMode(GL_PROJECTION); glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
end;

procedure T3dOpenGLRenderer.DrawSelectionBounds(ANode:T3dNode);
const
  CEdges:array[0..11,0..1] of Byte=((0,1),(1,3),(3,2),(2,0),
    (4,5),(5,7),(7,6),(6,4),(0,4),(1,5),(2,6),(3,7));
var
  lCorner,lEdge:Integer;
  lPoints:array[0..7] of T3dVector;
begin
  if (ANode=nil) or not ANode.Bounds.Valid then Exit;
  for lCorner:=0 to 7 do begin
    if (lCorner and 1)=0 then lPoints[lCorner].X:=ANode.Bounds.Min.X
      else lPoints[lCorner].X:=ANode.Bounds.Max.X;
    if (lCorner and 2)=0 then lPoints[lCorner].Y:=ANode.Bounds.Min.Y
      else lPoints[lCorner].Y:=ANode.Bounds.Max.Y;
    if (lCorner and 4)=0 then lPoints[lCorner].Z:=ANode.Bounds.Min.Z
      else lPoints[lCorner].Z:=ANode.Bounds.Max.Z;
  end;
  glPushMatrix; glMultMatrixf(@ANode.WorldTransform[0]); glLineWidth(1.5);
  glColor3f(1,0.85,0.15); glBegin(GL_LINES);
  for lEdge:=0 to High(CEdges) do begin
    with lPoints[CEdges[lEdge,0]] do glVertex3f(X,Y,Z);
    with lPoints[CEdges[lEdge,1]] do glVertex3f(X,Y,Z);
  end;
  glEnd; glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawAxes;
begin
  glLineWidth(2);
  glBegin(GL_LINES);
  glColor3f(1, 0.2, 0.2); glVertex3f(0, 0, 0); glVertex3f(2, 0, 0);
  glColor3f(0.2, 1, 0.2); glVertex3f(0, 0, 0); glVertex3f(0, 2, 0);
  glColor3f(0.2, 0.5, 1); glVertex3f(0, 0, 0); glVertex3f(0, 0, 2);
  glEnd;
end;

procedure T3dOpenGLRenderer.DrawCube;
const
  CVertices: array[0..7, 0..2] of GLfloat = (
    (-1,-1,-1), (1,-1,-1), (1,1,-1), (-1,1,-1),
    (-1,-1, 1), (1,-1, 1), (1,1, 1), (-1,1, 1));
  CFaces: array[0..5, 0..3] of Byte = (
    (0,1,2,3), (4,7,6,5), (0,4,5,1),
    (3,2,6,7), (1,5,6,2), (0,3,7,4));
  CColors: array[0..5, 0..2] of GLfloat = (
    (0.22,0.48,0.82), (0.30,0.62,0.92), (0.18,0.40,0.72),
    (0.35,0.70,0.95), (0.25,0.55,0.88), (0.15,0.35,0.65));
var
  I, J: Integer;
begin
  glBegin(GL_QUADS);
  for I := 0 to High(CFaces) do
  begin
    glColor3fv(@CColors[I, 0]);
    for J := 0 to 3 do
      glVertex3fv(@CVertices[CFaces[I, J], 0]);
  end;
  glEnd;
  glColor3f(0.05, 0.08, 0.12);
  glLineWidth(1.5);
  for I := 0 to High(CFaces) do
  begin
    glBegin(GL_LINE_LOOP);
    for J := 0 to 3 do glVertex3fv(@CVertices[CFaces[I, J], 0]);
    glEnd;
  end;
end;

procedure T3dOpenGLRenderer.DrawMesh(ANode: T3dNode; AMesh: T3dMeshData;
  const AOptions: T3dRenderOptions);
var
  I: Integer;
  M: T3dMeshData;
  P, N: T3dVector;
  C: T3dColor;
  lDrawFill,lDrawWireframe,lDrawPoints,lDrawNormals:Boolean;
begin
  M := AMesh;
  if M = nil then Exit;
  if ANode.HasRenderOverride then begin
    lDrawFill:=ANode.DrawFillOverride;
    lDrawWireframe:=ANode.DrawWireframeOverride;
    lDrawPoints:=ANode.DrawPointsOverride;
    lDrawNormals:=ANode.DrawNormalsOverride;
  end else begin
    lDrawFill:=AOptions.DrawFill; lDrawWireframe:=AOptions.DrawWireframe;
    lDrawPoints:=AOptions.DrawPoints; lDrawNormals:=AOptions.DrawNormals;
  end;
  glPushMatrix;
  glMultMatrixf(@ANode.WorldTransform[0]);
  if lDrawFill then
  begin
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    if ANode.HasColorOverride then C := ANode.ColorOverride else C := M.Color;
    glColor3ub(C.R, C.G, C.B);
    glBegin(GL_TRIANGLES);
    for I := 0 to High(M.Triangles) do
    begin
      if Length(M.Normals)>Integer(M.Triangles[I].A) then N := M.Normals[M.Triangles[I].A]
      else N:=Vector3d(0,0,1); glNormal3f(N.X,N.Y,N.Z);
      P := M.Positions[M.Triangles[I].A]; glVertex3f(P.X,P.Y,P.Z);
      if Length(M.Normals)>Integer(M.Triangles[I].B) then N := M.Normals[M.Triangles[I].B]
      else N:=Vector3d(0,0,1); glNormal3f(N.X,N.Y,N.Z);
      P := M.Positions[M.Triangles[I].B]; glVertex3f(P.X,P.Y,P.Z);
      if Length(M.Normals)>Integer(M.Triangles[I].C) then N := M.Normals[M.Triangles[I].C]
      else N:=Vector3d(0,0,1); glNormal3f(N.X,N.Y,N.Z);
      P := M.Positions[M.Triangles[I].C]; glVertex3f(P.X,P.Y,P.Z);
    end;
    glEnd;
  end;
  if lDrawWireframe then
  begin
    glDisable(GL_LIGHTING);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glColor3f(0.95,0.8,0.15);
    glBegin(GL_TRIANGLES);
    for I := 0 to High(M.Triangles) do
    begin
      P:=M.Positions[M.Triangles[I].A]; glVertex3f(P.X,P.Y,P.Z);
      P:=M.Positions[M.Triangles[I].B]; glVertex3f(P.X,P.Y,P.Z);
      P:=M.Positions[M.Triangles[I].C]; glVertex3f(P.X,P.Y,P.Z);
    end;
    glEnd;
  end;
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  if lDrawPoints then
  begin
    glPointSize(4); glColor3f(1,0.55,0.1); glBegin(GL_POINTS);
    for I:=0 to High(M.Positions) do begin P:=M.Positions[I]; glVertex3f(P.X,P.Y,P.Z); end;
    glEnd;
  end;
  if lDrawNormals then
  begin
    glColor3f(0.2,1,1); glBegin(GL_LINES);
    for I:=0 to Min(High(M.Positions),High(M.Normals)) do begin
      P:=M.Positions[I]; N:=M.Normals[I]; glVertex3f(P.X,P.Y,P.Z);
      glVertex3f(P.X+N.X*AOptions.NormalLength,P.Y+N.Y*AOptions.NormalLength,
        P.Z+N.Z*AOptions.NormalLength);
    end;
    glEnd;
  end;
  glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawSelectionAxes(ANode: T3dNode; AHotAxis,ASelectedAxis: Integer);
begin
  glPushMatrix; glMultMatrixf(@ANode.WorldTransform[0]); glLineWidth(4);
  glBegin(GL_LINES);
  if ASelectedAxis=1 then glColor3f(1,1,0)
  else if AHotAxis=1 then glColor3f(1,0.7,0.3) else glColor3f(1,0,0);
  glVertex3f(0,0,0); glVertex3f(1.5,0,0);
  if ASelectedAxis=2 then glColor3f(1,1,0)
  else if AHotAxis=2 then glColor3f(0.7,1,0.3) else glColor3f(0,1,0);
  glVertex3f(0,0,0); glVertex3f(0,1.5,0);
  if ASelectedAxis=3 then glColor3f(1,1,0)
  else if AHotAxis=3 then glColor3f(0.4,0.8,1) else glColor3f(0,0.5,1);
  glVertex3f(0,0,0); glVertex3f(0,0,1.5);
  glEnd; glPopMatrix;
end;

procedure T3dOpenGLRenderer.DrawScene(AScene: T3dScene;
  const AOptions: T3dRenderOptions);
var I,J: Integer; lMesh:T3dMeshData;
begin
  if AScene=nil then begin DrawCube; Exit; end;
  for I:=0 to High(AScene.Nodes) do if AScene.Nodes[I].Kind=nkMesh then begin
    lMesh:=AScene.Nodes[I].Mesh;
    if (lMesh<>nil) and (Length(lMesh.Positions)=0) and (lMesh.SourceNodeId<>0) then
      for J:=0 to High(AScene.Nodes) do if AScene.Nodes[J].Id=lMesh.SourceNodeId then begin
        lMesh:=AScene.Nodes[J].Mesh; Break;
      end;
    DrawMesh(AScene.Nodes[I],lMesh,AOptions);
  end;
  if AOptions.SelectedNodeId<>0 then
    for I:=0 to High(AScene.Nodes) do
      if AScene.Nodes[I].Id=AOptions.SelectedNodeId then begin
        DrawSelectionBounds(AScene.Nodes[I]);
        DrawSelectionAxes(AScene.Nodes[I],AOptions.HotAxis,AOptions.SelectedAxis); Break;
      end;
end;

procedure T3dOpenGLRenderer.Render(AScene: T3dScene; const ACamera: T3dCamera;
  const AOptions: T3dRenderOptions);
var
  W, H: Integer;
  R, G, B, lNear,lFar,lRadius: Single;
begin
  W := fHost.RenderWidth;
  H := fHost.RenderHeight;
  if (W <= 0) or (H <= 0) then Exit;
  if not fHost.ActivateContext then Exit;
  R := (AOptions.BackgroundColor and $FF) / 255;
  G := ((AOptions.BackgroundColor shr 8) and $FF) / 255;
  B := ((AOptions.BackgroundColor shr 16) and $FF) / 255;
  glViewport(0, 0, W, H);
  glClearColor(R, G, B, 1);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glEnable(GL_DEPTH_TEST);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  lRadius:=Max(AOptions.SceneClipRadius,0);
  if lRadius>0 then begin
    lNear:=Max(0.001,ACamera.Distance-lRadius*2);
    lFar:=Max(lNear+1,ACamera.Distance+lRadius*2);
  end else begin lNear:=0.01; lFar:=Max(100,ACamera.Distance*10); end;
  gluPerspective(45, W / H, lNear, lFar);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0, 0, -Max(2.5, ACamera.Distance));
  glRotatef(ACamera.RollDegrees, 0, 0, 1);
  glRotatef(ACamera.PitchDegrees, 1, 0, 0);
  glRotatef(ACamera.YawDegrees, 0, 1, 0);
  glTranslatef(-ACamera.Target.X, -ACamera.Target.Y, -ACamera.Target.Z);
  DrawScene(AScene, AOptions);
  if AOptions.ShowAxes then DrawAxes;
  DrawCameraOverlay(AOptions,W,H);
  glPopAttrib;
  glFlush;
  fHost.PresentFrame;
end;

end.
