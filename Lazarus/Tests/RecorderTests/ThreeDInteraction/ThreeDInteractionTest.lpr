program ThreeDInteractionTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, Math, u3dCoreTypes, u3dScene, u3dSceneMath, u3dGeometryMath,
  u3dMeshTopology,
  u3dInteractionTypes, u3dInteractionMath,
  u3dCameraInteraction, u3dCameraRotateOverlay, u3dInputRouter, u3dSelection,
  u3dGizmo, u3dScreenGeometryMath, u3dInteractionDispatcher, u3dTransforms,
  u3dCamera, u3dScenePicker, u3dPrimitives, u3dSkin, u3dVertexColors,
  u3dContracts;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure CheckNear(AActual, AExpected: Single; const AMessage: string);
begin
  if Abs(AActual - AExpected) > 1e-3 then
    raise Exception.CreateFmt('%s: expected %.4f, got %.4f',
      [AMessage, AExpected, AActual]);
end;

procedure TestRenderPassLightingPolicy;
var
  lPass: T3dRenderPass;
begin
  Check(RenderPassUsesLighting(rpMeshFill),
    'solid mesh pass supports scene lighting');
  for lPass := Succ(rpMeshFill) to High(T3dRenderPass) do
    Check(not RenderPassUsesLighting(lPass),
      'editor and line render passes must preserve exact unlit colors');
end;

procedure TestEditorOverlayDepthPolicy;
begin
  Check(not RenderPassUsesDepthTest(rpPoints),
    'all topology points must remain visible through mesh faces');
  Check(not RenderPassUsesDepthTest(rpVertexHighlight),
    'selected and adjacent vertices must remain visible through mesh faces');
  Check(not RenderPassUsesDepthTest(rpSelectedHelperOverlay),
    'selected skin helper and gizmo must remain visible through mesh faces');
  Check(RenderPassUsesDepthTest(rpMeshFill),
    'solid geometry still needs the depth test');
end;

procedure TestSelectedHelperAxisIgnoresHelperScale;
var
  SmallAxis,LargeAxis:T3dVector;
begin
  Check(TryNormalize(Vector3d(0.08,0.08,0),SmallAxis),
    'small helper axis normalizes');
  Check(TryNormalize(Vector3d(8,8,0),LargeAxis),
    'large helper axis normalizes');
  CheckNear(Dot(SmallAxis,LargeAxis),1,
    'selected helper axis preserves orientation independently of scale');
end;

procedure TestDefaultCubeIsSceneGeometry;
var
  Scene: T3dScene;
  Picker: I3dScenePicker;
  Hit: T3dHit;
  Ray: T3dRay;
  Topology:T3dMeshTopology;
begin
  Scene := CreateDefaultCubeScene;
  try
    Check(Length(Scene.Nodes) = 1, 'default cube is one scene node');
    Check(Scene.Bounds.Valid, 'default cube contributes scene bounds');
    CheckNear(Scene.Bounds.Min.X, -1, 'default cube bounds min X');
    CheckNear(Scene.Bounds.Max.X, 1, 'default cube bounds max X');
    Topology:=BuildMeshTopology(Scene.Nodes[0].Mesh);
    Check(Length(Topology.Vertices)=8,
      'default flat cube exposes eight logical vertices');
    Picker := T3dCpuScenePicker.Create;
    Ray.Origin := Vector3d(0, 0, 4);
    Ray.Direction := Vector3d(0, 0, -1);
    Check(Picker.Pick(Scene, Ray, Hit), 'default cube is pickable');
    Check(Hit.NodeId = Scene.Nodes[0].Id, 'picker returns default cube node');
  finally
    Scene.Free;
  end;
end;

procedure TestResolveVertexHighlightCorners;
var
  Scene:T3dScene;
  Topology:T3dMeshTopology;
  Primary,Adjacent:array[0..7] of LongWord;
  PrimaryCount,AdjacentCount:Integer;
begin
  Scene := CreateDefaultCubeScene;
  try
    Topology := BuildMeshTopology(Scene.Nodes[0].Mesh);
    ResolveHighlightCorners(Topology,0,Primary,Adjacent,
      PrimaryCount,AdjacentCount);
    Check(PrimaryCount=3,'flat cube logical vertex resolves three face corners');
    Check(Primary[0]=0,'primary corner preserves mesh index');
    Check(AdjacentCount>=3,'cube vertex resolves adjacent corners');
    ResolveHighlightCorners(Topology,-1,Primary,Adjacent,
      PrimaryCount,AdjacentCount);
    Check((PrimaryCount=0) and (AdjacentCount=0),
      'invalid logical vertex clears resolved highlight');
  finally
    Scene.Free;
  end;
end;

procedure TestShapeBoundsAndPicking;
var
  Scene:T3dScene;
  Node:T3dNode;
  Picker:I3dScenePicker;
  Hit:T3dHit;
  Ray:T3dRay;
begin
  Scene := T3dScene.Create;
  try
    Node := T3dNode.Create;
    Node.Id := 77;
    Node.Kind := nkShape;
    SetIdentity(Node.LocalTransform);
    SetIdentity(Node.WorldTransform);
    SetLength(Node.ShapeLines,1);
    SetLength(Node.ShapeLines[0].Points,3);
    Node.ShapeLines[0].Points[0] := Vector3d(-2,-1,0);
    Node.ShapeLines[0].Points[1] := Vector3d(0,2,0);
    Node.ShapeLines[0].Points[2] := Vector3d(3,0,0);
    IncludePoint(Node.Bounds,Node.ShapeLines[0].Points[0]);
    IncludePoint(Node.Bounds,Node.ShapeLines[0].Points[1]);
    IncludePoint(Node.Bounds,Node.ShapeLines[0].Points[2]);
    Scene.AddNode(Node);
    Scene.ResolveLinks;
    CheckNear(Scene.Bounds.Min.X,-2,'shape contributes minimum X');
    CheckNear(Scene.Bounds.Max.X,3,'shape contributes maximum X');
    CheckNear(Scene.Bounds.Max.Y,2,'shape contributes maximum Y');
    Picker := T3dCpuScenePicker.Create;
    Ray.Origin := Vector3d(0,0,5);
    Ray.Direction := Vector3d(0,0,-1);
    Check(Picker.Pick(Scene,Ray,Hit),'shape bounds are pickable');
    Check((Hit.NodeId=77) and (Hit.TriangleId=-1),
      'shape pick reports node without triangle');
  finally
    Scene.Free;
  end;
end;

procedure TestShapePrimitive;
begin
  Check(ShapePrimitive(False) = spLineStrip,
    'open shape must render as a line strip');
  Check(ShapePrimitive(True) = spLineLoop,
    'closed shape must render as a line loop');
end;

procedure TestInputModes;
var
  lRouter: T3dInputRouter;
  lResult: T3dInputResult;
begin
  lRouter := T3dInputRouter.Create;
  try
    lRouter.Mode := imSelect;
    lRouter.PointerDown(pbLeft, Point3d(10, 10), [], lResult);
    Check(lResult.CapturePointer, 'pointer capture on press');
    lRouter.PointerUp(pbLeft, Point3d(10, 10), [], lResult);
    Check(lResult.Command = icSelect, 'select click');

    lRouter.PointerDown(pbLeft, Point3d(0, 0), [], lResult);
    lRouter.PointerMove(Point3d(10, 2), [mdCtrl], lResult);
    Check(lResult.Command = icRotate, 'Ctrl overrides mode with rotate');
    lRouter.PointerUp(pbLeft, Point3d(10, 2), [mdCtrl], lResult);

    lRouter.Mode := imPan;
    lRouter.PointerDown(pbLeft, Point3d(0, 0), [], lResult);
    lRouter.PointerMove(Point3d(8, 0), [], lResult);
    Check(lResult.Command = icPan, 'pan drag');
    lRouter.Cancel(lResult);
    Check((lRouter.State = isIdle) and lResult.ReleasePointer, 'cancel releases');

    lRouter.Wheel(2, Point3d(5, 5), lResult);
    Check((lResult.Command = icZoom) and (lResult.Delta.Y = 2), 'wheel zoom');
  finally
    lRouter.Free;
  end;
end;

procedure TestCameraMath;
var
  lCamera: T3dOrbitCamera;
  lViewport: T3dViewport;
  lRay: T3dRay;
  lForward,lRight,lUp:T3dVector;
begin
  FillChar(lCamera,SizeOf(lCamera),0);
  lCamera.Target := Vector3d(0, 0, 0);
  lCamera.YawDegrees := 0;
  lCamera.PitchDegrees := 0;
  lCamera.RollDegrees := 0;
  lCamera.Distance := 10;
  lCamera.VerticalFovDegrees := 60;
  lViewport.Width := 800;
  lViewport.Height := 600;
  lRay := CameraRay(lCamera, lViewport, Point3d(400, 300));
  CheckNear(lRay.Direction.X, 0, 'center ray X');
  CheckNear(lRay.Direction.Y, 0, 'center ray Y');
  CheckNear(lRay.Direction.Z, -1, 'center ray Z');

  ZoomCamera(lCamera, 1);
  CheckNear(lCamera.Distance, 9, 'zoom factor');
  RotateCamera(lCamera, Point3d(10, -1000), 1);
  CameraBasis(lCamera,lForward,lRight,lUp);
  Check(lCamera.PoseValid,'rotation stores canonical camera pose');

  lCamera.VerticalFovDegrees := 60;
  FitCamera(lCamera, Vector3d(1, 2, 3), 1, lViewport);
  CheckNear(lCamera.Target.X, 1, 'fit target');
  Check(lCamera.Distance >= 2, 'fit contains sphere');
end;

procedure TestOrthographicInteractionMath;
var
  Camera: T3dOrbitCamera;
  Viewport: T3dViewport;
  CenterRay, CornerRay: T3dRay;
  NearScreen, FarScreen: T3dPoint;
  NearDepth, FarDepth: Single;
begin
  FillChar(Camera, SizeOf(Camera), 0);
  Camera.Distance := 10;
  Camera.VerticalFovDegrees := 60;
  Camera.ProjectionKind := pkOrthographic;
  Camera.OrthographicScale := 3;
  Viewport.Width := 800;
  Viewport.Height := 400;

  CenterRay := CameraRay(Camera, Viewport, Point3d(400, 200));
  CornerRay := CameraRay(Camera, Viewport, Point3d(800, 0));
  CheckNear(Dot(CenterRay.Direction, CornerRay.Direction), 1,
    'orthographic rays are parallel');
  Check(Abs(CenterRay.Origin.X-CornerRay.Origin.X)+
    Abs(CenterRay.Origin.Y-CornerRay.Origin.Y)+
    Abs(CenterRay.Origin.Z-CornerRay.Origin.Z)>0.001,
    'orthographic rays have different origins');

  Check(ProjectWorldToScreen(Vector3d(2, 1, 0), Camera, Viewport,
    NearScreen, NearDepth), 'orthographic near point projects');
  Check(ProjectWorldToScreen(Vector3d(2, 1, -5), Camera, Viewport,
    FarScreen, FarDepth), 'orthographic far point projects');
  CheckNear(NearScreen.X, FarScreen.X,
    'orthographic projection X is depth independent');
  CheckNear(NearScreen.Y, FarScreen.Y,
    'orthographic projection Y is depth independent');
  Check(FarDepth>NearDepth, 'orthographic projection preserves depth');
end;

procedure TestCameraPan;
var
  lCamera:T3dOrbitCamera;
  lViewport:T3dViewport;
  lForward0,lRight0,lUp0,lForward1,lRight1,lUp1,lPosition0,lPosition1,lTarget0,
    lCameraDelta,lTargetDelta:T3dVector;
begin
  FillChar(lCamera,SizeOf(lCamera),0); lCamera.Distance:=10;
  lCamera.VerticalFovDegrees:=60; lCamera.RollDegrees:=30;
  lViewport.Width:=800; lViewport.Height:=600;
  CameraBasis(lCamera,lForward0,lRight0,lUp0); lTarget0:=lCamera.Target;
  lPosition0:=Subtract(lCamera.Target,Scale(lForward0,lCamera.Distance));
  PanCamera(lCamera,Point3d(60,30),lViewport);
  CameraBasis(lCamera,lForward1,lRight1,lUp1);
  lPosition1:=Subtract(lCamera.Target,Scale(lForward1,lCamera.Distance));
  Check(Dot(Subtract(lCamera.Target,lTarget0),lRight0)<0,
    'right drag moves camera left so surface follows pointer');
  Check(Dot(Subtract(lCamera.Target,lTarget0),lUp0)>0,
    'down drag moves camera up so surface follows pointer');
  CheckNear(lCamera.Distance,10,'pan keeps distance');
  CheckNear(lCamera.YawDegrees,0,'pan keeps yaw');
  CheckNear(lCamera.RollDegrees,30,'pan keeps roll');
  CheckNear(Dot(lForward0,lForward1),1,'pan keeps forward');
  lCameraDelta:=Subtract(lPosition1,lPosition0);
  lTargetDelta:=Subtract(lCamera.Target,lTarget0);
  CheckNear(lCameraDelta.X,lTargetDelta.X,'camera and target translate together X');
end;

procedure TestCanonicalCameraMatrices;
var O:T3dOrbitCamera; C:T3dCamera; S0,S1:T3dCameraSnapshot;
  V:T3dViewport; P0,P1:T3dVector;
begin
  FillChar(O,SizeOf(O),0); O.Distance:=10; O.VerticalFovDegrees:=52;
  O.YawDegrees:=20; O.PitchDegrees:=-10; O.RollDegrees:=25;
  C:=CanonicalCamera(O); S0:=BuildCameraSnapshot(C,900,600,20);
  P0:=S0.Position; V.Width:=900; V.Height:=600;
  PanCamera(O,Point3d(30,-15),V); C:=CanonicalCamera(O);
  S1:=BuildCameraSnapshot(C,900,600,20); P1:=S1.Position;
  CheckNear(S1.VerticalFovDegrees,52,'renderer snapshot uses camera FOV');
  CheckNear(O.Distance,10,'canonical pan preserves distance');
  CheckNear(Dot(S0.Forward,S1.Forward),1,'canonical pan preserves orientation');
  Check(Dot(Subtract(P1,P0),S0.Right)<0,
    'camera position opposes right drag');
  Check(Dot(Subtract(P1,P0),S0.Up)<0,
    'camera position opposes upward drag');
  Check(Abs(S1.ViewMatrix[12]-S0.ViewMatrix[12])+
    Abs(S1.ViewMatrix[13]-S0.ViewMatrix[13])>0.001,'pan changes view matrix');
  CheckNear(S1.ProjectionMatrix[5],
    1/Tan(DegToRad(O.VerticalFovDegrees)*0.5),'ray and renderer share FOV');
end;

procedure CheckBoxFits(var ACamera:T3dOrbitCamera; const AMin,AMax:T3dVector;
  const AViewport:T3dViewport; const AMessage:string);
var F,R,U,C,O:T3dVector; I:Integer; Depth,TanV,TanH,Nx,Ny:Single;
begin
  FitCameraToBox(ACamera,AMin,AMax,AViewport);
  CameraBasis(ACamera,F,R,U); TanV:=Tan(DegToRad(ACamera.VerticalFovDegrees)*0.5);
  TanH:=TanV*AViewport.Width/AViewport.Height;
  for I:=0 to 7 do begin
    if (I and 1)=0 then C.X:=AMin.X else C.X:=AMax.X;
    if (I and 2)=0 then C.Y:=AMin.Y else C.Y:=AMax.Y;
    if (I and 4)=0 then C.Z:=AMin.Z else C.Z:=AMax.Z;
    O:=Subtract(C,ACamera.Target); Depth:=ACamera.Distance+Dot(O,F);
    Check(Depth>0,AMessage+' positive depth');
    Nx:=Abs(Dot(O,R))/(Depth*TanH); Ny:=Abs(Dot(O,U))/(Depth*TanV);
    Check((Nx<=0.834) and (Ny<=0.834),AMessage+' corner margin');
  end;
end;

procedure TestFitBoxAllCorners;
var C:T3dOrbitCamera; V:T3dViewport; Yaw,Pitch,Roll:Single;
begin
  FillChar(C,SizeOf(C),0); C.VerticalFovDegrees:=45;
  C.YawDegrees:=27; C.PitchDegrees:=-18; C.RollDegrees:=33;
  Yaw:=C.YawDegrees; Pitch:=C.PitchDegrees; Roll:=C.RollDegrees;
  V.Width:=1200; V.Height:=500;
  CheckBoxFits(C,Vector3d(10,-4,2),Vector3d(18,6,9),V,'landscape rolled');
  CheckNear(C.Target.X,14,'off-center fit target X');
  V.Width:=400; V.Height:=1000;
  CheckBoxFits(C,Vector3d(-8,-2,-6),Vector3d(5,12,3),V,'portrait rolled');
  CheckNear(C.YawDegrees,Yaw,'fit preserves yaw');
  CheckNear(C.PitchDegrees,Pitch,'fit preserves pitch');
  CheckNear(C.RollDegrees,Roll,'fit preserves roll');
end;

procedure TestSelection;
var
  lSelection: T3dSelection;
  lVersion: QWord;
begin
  lSelection := T3dSelection.Create(1);
  try
    lSelection.Add(42);
    lVersion := lSelection.Version;
    lSelection.Add(42);
    Check(lSelection.Version = lVersion, 'duplicate is no-op');
    lSelection.Add(High(QWord));
    Check((lSelection.Count = 2) and lSelection.Contains(High(QWord)),
      'stable 64-bit IDs');
    lSelection.Toggle(42);
    Check((lSelection.Count = 1) and (lSelection.PrimaryId = High(QWord)),
      'toggle and primary ID');
    lSelection.Replace(7);
    Check((lSelection.Count = 1) and (lSelection.Item(0) = 7), 'replace');
  finally
    lSelection.Free;
  end;
end;

procedure TestVertexPickMissKeepsObject;
begin
  Check(NodeIdAfterPick(42, 0, True) = 42,
    'vertex miss must keep the selected object');
  Check(NodeIdAfterPick(42, 77, True) = 77,
    'a real hit must select the hit object');
  Check(NodeIdAfterPick(42, 0, False) = 0,
    'ordinary object selection may clear on empty space');
end;

function RayToPoint(AX: Single): T3dRay;
begin
  Result.Origin := Vector3d(0, 0, 5);
  Result.Direction := Normalize(Vector3d(AX, 0, -5));
end;

procedure TestLocalAxisGizmo;
var
  lGizmo: T3dGizmo;
  lBasis: T3dAxisBasis;
  lTranslation: T3dVector;
begin
  lGizmo := T3dGizmo.Create;
  try
    lBasis.XAxis := Vector3d(0, 1, 0);
    lBasis.YAxis := Vector3d(-1, 0, 0);
    lBasis.ZAxis := Vector3d(0, 0, 1);
    lGizmo.Show(Vector3d(0, 0, 0), lBasis, 2);
    lGizmo.SelectAxis(gaY);
    Check(lGizmo.BeginDrag(gaY, RayToPoint(-0.5)), 'begin local Y drag');
    Check(lGizmo.UpdateDrag(RayToPoint(-1.5), lTranslation), 'update drag');
    CheckNear(lTranslation.X, -1, 'local Y maps to world -X');
    CheckNear(lTranslation.Y, 0, 'local Y translation Y');
    lGizmo.EndDrag;
    Check(lGizmo.State = gsHover, 'commit state');
    lGizmo.Hide;
    Check(lGizmo.State = gsHidden, 'hidden state');
  finally
    lGizmo.Free;
  end;
end;

procedure TestGizmoSelectedAxis;
var
  lGizmo:T3dGizmo;
  lAxis:T3dGizmoAxis;
begin
  lGizmo:=T3dGizmo.Create;
  try
    lGizmo.Show(Vector3d(0,0,0),IdentityAxisBasis,2);
    lGizmo.SelectAxis(gaX);
    lAxis:=lGizmo.HitTest(RayToPoint(0.5));
    Check(lAxis=gaX,'hover X');
    Check(lGizmo.SelectedAxis=gaX,'hover does not clear selected axis');
    lAxis:=lGizmo.HitTest(RayToPoint(5));
    Check(lAxis=gaNone,'hover miss');
    Check(lGizmo.SelectedAxis=gaX,'miss does not clear selected axis');
    Check(not lGizmo.BeginDrag(gaY,RayToPoint(0.5)),
      'unselected axis cannot start drag');
    Check(lGizmo.BeginDrag(gaX,RayToPoint(0.5)),
      'selected axis starts drag');
    lGizmo.EndDrag;
    Check(lGizmo.SelectedAxis=gaX,'selected axis survives drag');
  finally
    lGizmo.Free;
  end;
end;

procedure TestCameraRotationConstraints;
var
  lCamera:T3dOrbitCamera;
  lForward,lRight,lUp,lNewForward,lNewRight,lNewUp:T3dVector;
  I: Integer;
begin
  FillChar(lCamera,SizeOf(lCamera),0);
  RotateCameraConstrained(lCamera,Point3d(10,20),1,crcX);
  CameraBasis(lCamera,lForward,lRight,lUp);
  CheckNear(Dot(lForward,Vector3d(0,0,-1)),Cos(DegToRad(20)),
    'X constraint rotates camera pose');

  FillChar(lCamera,SizeOf(lCamera),0);
  RotateCameraConstrained(lCamera,Point3d(10,20),1,crcY);
  CameraBasis(lCamera,lForward,lRight,lUp);
  CheckNear(Dot(lForward,Vector3d(0,0,-1)),Cos(DegToRad(10)),
    'Y constraint rotates camera pose');

  FillChar(lCamera,SizeOf(lCamera),0);
  RotateCameraConstrained(lCamera,Point3d(15,20),1,crcZ);
  CameraBasis(lCamera,lForward,lRight,lUp);
  CheckNear(Dot(lRight,Vector3d(1,0,0)),Cos(DegToRad(15)),
    'Z constraint rotates camera pose');

  lCamera.PoseValid:=False;
  lCamera.YawDegrees:=0; lCamera.PitchDegrees:=0; lCamera.RollDegrees:=90;
  CameraBasis(lCamera,lForward,lRight,lUp);
  CheckNear(lRight.X,0,'roll rotates right X');
  CheckNear(lRight.Y,1,'roll rotates right into up');
  CheckNear(lUp.X,-1,'roll rotates up into left');

  lCamera.PoseValid:=False;
  lCamera.YawDegrees:=31; lCamera.PitchDegrees:=-23; lCamera.RollDegrees:=37;
  CameraBasis(lCamera,lForward,lRight,lUp);
  RotateCameraConstrained(lCamera,Point3d(0,12),1,crcX);
  CameraBasis(lCamera,lNewForward,lNewRight,lNewUp);
  CheckNear(Dot(lRight,lNewRight),1,'local X keeps current camera right');
  CheckNear(Dot(lForward,lNewForward),Cos(DegToRad(12)),
    'local X rotates by requested angle');
  Check(Dot(lNewForward,lUp)<0,'local X preserves vertical drag sign');

  lCamera.PoseValid:=False;
  lCamera.YawDegrees:=31; lCamera.PitchDegrees:=-23; lCamera.RollDegrees:=37;
  CameraBasis(lCamera,lForward,lRight,lUp);
  RotateCameraConstrained(lCamera,Point3d(14,0),1,crcY);
  CameraBasis(lCamera,lNewForward,lNewRight,lNewUp);
  CheckNear(Dot(lUp,lNewUp),1,'local Y keeps current camera up');
  CheckNear(Dot(lForward,lNewForward),Cos(DegToRad(14)),
    'local Y rotates by requested angle');
  Check(Dot(lNewForward,lRight)<0,'local Y preserves horizontal drag sign');

  lCamera.PoseValid:=False;
  lCamera.YawDegrees:=31; lCamera.PitchDegrees:=-23; lCamera.RollDegrees:=37;
  CameraBasis(lCamera,lForward,lRight,lUp);
  RotateCameraConstrained(lCamera,Point3d(16,0),1,crcZ);
  CameraBasis(lCamera,lNewForward,lNewRight,lNewUp);
  CheckNear(Dot(lForward,lNewForward),1,'local Z keeps current camera forward');
  CheckNear(Dot(lRight,lNewRight),Cos(DegToRad(16)),
    'local Z rotates by requested angle');
  Check(Dot(lNewRight,lUp)>0,'local Z preserves roll drag sign');

  FillChar(lCamera,SizeOf(lCamera),0);
  for I:=1 to 200 do
    RotateCameraConstrained(lCamera,Point3d(0,1),1,crcX);
  CameraBasis(lCamera,lForward,lRight,lUp);
  CheckNear(Dot(lForward,lRight),0,'incremental pose forward/right orthogonal');
  CheckNear(Dot(lForward,lUp),0,'incremental pose forward/up orthogonal');
  RotateCameraConstrained(lCamera,Point3d(17,0),1,crcY);
  CameraBasis(lCamera,lNewForward,lNewRight,lNewUp);
  Check(Dot(lForward,lNewForward)<0.999,
    'Y axis remains responsive after crossing former Euler pole');
end;

procedure TestCameraRotateOverlay;
var
  lOverlay:T3dCameraRotateOverlay;
  lDelta:T3dPoint;
begin
  lOverlay:=T3dCameraRotateOverlay.Create;
  try
    lOverlay.Show(Point3d(100,100),50);
    Check(lOverlay.HitTest(Point3d(125,100))=crhY,'horizontal maps to Y');
    Check(lOverlay.HitTest(Point3d(100,125))=crhX,'vertical maps to X');
    Check(lOverlay.HitTest(Point3d(135.36,135.36))=crhZ,'circle maps to Z');
    Check(lOverlay.HitTest(Point3d(100,100))=crhNone,
      'ambiguous overlay center stays neutral');
    lOverlay.SelectHandle(crhY);
    Check(not lOverlay.BeginDrag(crhX,Point3d(100,125)),
      'unselected camera handle cannot drag');
    Check(lOverlay.BeginDrag(crhY,Point3d(125,100)),'selected handle pressed');
    Check(not lOverlay.UpdateDrag(Point3d(126,100),lDelta),
      'click is separate from drag threshold');
    Check(lOverlay.UpdateDrag(Point3d(130,100),lDelta),'drag after threshold');
    CheckNear(lDelta.X,5,'overlay incremental drag X');
    lOverlay.EndDrag;
    Check(lOverlay.SelectedHandle=crhY,'camera handle stays selected');
    lOverlay.SelectHandle(crhZ);
    Check(lOverlay.BeginDrag(crhZ,Point3d(150,100)),'roll ring pressed');
    Check(lOverlay.UpdateDrag(Point3d(100,150),lDelta),
      'roll ring uses angular drag');
    CheckNear(lDelta.X,-180,'quarter-circle roll delta');
    CheckNear(lDelta.Y,0,'roll ring ignores linear Y delta');
    lOverlay.EndDrag;
    lOverlay.Hide;
    Check(lOverlay.State=crosHidden,'overlay hides outside rotate mode');
  finally
    lOverlay.Free;
  end;
end;

procedure TestScreenAxisHitTolerance;
var
  C:T3dOrbitCamera; V:T3dViewport; B:T3dAxisBasis;
  O,E:T3dPoint; D:Single; Axis:Integer;
begin
  FillChar(C,SizeOf(C),0); C.Distance:=10; C.VerticalFovDegrees:=60;
  V.Width:=800; V.Height:=600; B:=IdentityAxisBasis;
  B.XAxis:=Normalize(Vector3d(0.4,0,0.9165));
  Check(ProjectWorldToScreen(Vector3d(0,0,0),C,V,O,D),'project origin');
  Check(ProjectWorldToScreen(B.XAxis,C,V,E,D),'project foreshortened X');
  Check(ScreenAxisHitTest(Vector3d(0,0,0),B,1,C,V,
    Point3d((O.X+E.X)*0.5,(O.Y+E.Y)*0.5+7),10,Axis) and (Axis=0),
    'foreshortened X uses pixel tolerance');
  Check(ProjectWorldToScreen(Vector3d(1,0,0),C,V,E,D),'project X endpoint');
  B:=IdentityAxisBasis;
  Check(ScreenAxisHitTest(Vector3d(0,0,0),B,1,C,V,
    Point3d(E.X+6,E.Y+5),10,Axis) and (Axis=0),
    'axis endpoint uses pixel tolerance');
  Check(ScreenAxisHitTest(Vector3d(0,0,0),B,1,C,V,
    Point3d(O.X+7,O.Y-35),10,Axis) and (Axis=1),
    'Y axis has same pixel tolerance');
end;

procedure TestExclusiveInteractionContexts;
var D:T3dInteractionDispatcher; PanToken,OtherToken:T3dCaptureToken;
begin
  D:=T3dInteractionDispatcher.Create;
  try
    Check(D.TryCapture(ictCameraPan,PanToken),'pan captures');
    Check(not D.TryCapture(ictObjectSelect,OtherToken),
      'pan cannot be stolen by selection');
    Check(D.Release(PanToken),'pan releases');
    Check(D.TryCapture(ictOverlayPick,PanToken),'camera Y overlay captures');
    Check(not D.TryCapture(ictObjectSelect,OtherToken),
      'camera overlay cannot be stolen by object selection');
    D.Cancel;
    Check(D.TryCapture(ictObjectManipulate,PanToken),'object drag captures');
    Check(not D.TryCapture(ictCameraRotate,OtherToken),
      'object drag cannot rotate camera');
    Check(D.Owns(PanToken,ictObjectManipulate),'capture token owns context');
    D.Cancel;
    Check(D.ActiveContext=ictNone,'cancel releases context');
  finally D.Free; end;
end;

function AddBoxNode(AScene:T3dScene; AId,AParentId:QWord;
  const APosition:T3dVector):T3dNode; forward;

procedure TestSelectedPivotAndFit;
var
  lScene:T3dScene;
  lNode:T3dNode;
  lPivot:T3dVector;
  lCamera:T3dOrbitCamera;
  lViewport:T3dViewport;
begin
  lScene:=T3dScene.Create;
  try
    lNode:=AddBoxNode(lScene,1,0,Vector3d(10,20,30));
    lNode.Bounds.Min:=Vector3d(-2,-1,-3); lNode.Bounds.Max:=Vector3d(2,1,3);
    lPivot:=NodeWorldPivot(lNode);
    CheckNear(lPivot.X,10,'selected pivot X');
    CheckNear(lPivot.Y,20,'selected pivot Y');
    CheckNear(lPivot.Z,30,'selected pivot Z');
    FillChar(lCamera,SizeOf(lCamera),0); lCamera.VerticalFovDegrees:=60;
    lViewport.Width:=400; lViewport.Height:=800;
    FitCameraToBox(lCamera,Vector3d(8,19,27),Vector3d(12,21,33),lViewport);
    CheckNear(lCamera.Target.X,10,'fit selected target X');
    CheckNear(lCamera.Target.Y,20,'fit selected target Y');
    CheckNear(lCamera.Target.Z,30,'fit selected target Z');
    Check(lCamera.Distance>6,'portrait aspect increases fit distance');
  finally
    lScene.Free;
  end;
end;

function AddBoxNode(AScene:T3dScene; AId,AParentId:QWord;
  const APosition:T3dVector):T3dNode;
begin
  Result:=T3dNode.Create; Result.Id:=AId; Result.ParentId:=AParentId;
  Result.Kind:=nkMesh; SetIdentity(Result.LocalTransform);
  SetIdentity(Result.WorldTransform); Result.LocalTransform[12]:=APosition.X;
  Result.LocalTransform[13]:=APosition.Y; Result.LocalTransform[14]:=APosition.Z;
  Result.WorldTransform[12]:=APosition.X; Result.WorldTransform[13]:=APosition.Y;
  Result.WorldTransform[14]:=APosition.Z; Result.Bounds.Valid:=True;
  Result.Bounds.Min:=Vector3d(-1,-1,-1); Result.Bounds.Max:=Vector3d(1,1,1);
  AScene.AddNode(Result);
end;

procedure TestWorldAabbPicking;
var
  lScene:T3dScene;
  lNear,lRotated:T3dNode;
begin
  lScene:=T3dScene.Create;
  try
    lNear:=AddBoxNode(lScene,10,0,Vector3d(0,0,3));
    lRotated:=AddBoxNode(lScene,20,0,Vector3d(0,0,10));
    { Rotation around Z combined with non-uniform scale. }
    lRotated.WorldTransform[0]:=0; lRotated.WorldTransform[1]:=2;
    lRotated.WorldTransform[4]:=-3; lRotated.WorldTransform[5]:=0;
    lRotated.WorldTransform[10]:=4;
    Check(PickWorldAabb(lScene,Vector3d(0,0,0),Vector3d(0,0,1))=10,
      'nearest world AABB wins');
    Check(PickWorldAabb(lScene,Vector3d(100,0,0),Vector3d(0,0,1))=0,
      'world AABB miss');
    lNear.Kind:=nkDummy;
    Check(PickWorldAabb(lScene,Vector3d(2.5,0,0),Vector3d(0,0,1))=20,
      'rotated and scaled world AABB');
  finally
    lScene.Free;
  end;
end;

function AddTriangleNode(AScene:T3dScene; AId:QWord; AZ:Single;
  const A,B,C:T3dVector):T3dNode;
begin
  Result:=T3dNode.Create; Result.Id:=AId; Result.Kind:=nkMesh;
  SetIdentity(Result.LocalTransform); SetIdentity(Result.WorldTransform);
  Result.WorldTransform[14]:=AZ; Result.LocalTransform[14]:=AZ;
  Result.Mesh:=T3dMeshData.Create; SetLength(Result.Mesh.Positions,3);
  Result.Mesh.Positions[0]:=A; Result.Mesh.Positions[1]:=B;
  Result.Mesh.Positions[2]:=C; SetLength(Result.Mesh.Triangles,1);
  Result.Mesh.Triangles[0].A:=0; Result.Mesh.Triangles[0].B:=1;
  Result.Mesh.Triangles[0].C:=2; Result.Bounds.Valid:=False;
  IncludePoint(Result.Bounds,A); IncludePoint(Result.Bounds,B);
  IncludePoint(Result.Bounds,C); AScene.AddNode(Result);
end;

procedure TestTriangleScenePicker;
var S:T3dScene; Picker:I3dScenePicker; H:T3dHit; R:T3dRay; N:T3dNode;
begin
  Picker:=T3dCpuScenePicker.Create; S:=T3dScene.Create;
  try
    AddTriangleNode(S,10,8,Vector3d(-1,-1,0),Vector3d(1,-1,0),Vector3d(0,1,0));
    AddTriangleNode(S,20,4,Vector3d(-1,-1,0),Vector3d(1,-1,0),Vector3d(0,1,0));
    R.Origin:=Vector3d(0,0,0); R.Direction:=Vector3d(0,0,1);
    Check(Picker.Pick(S,R,H),'triangle picker overlapping hit');
    Check((H.NodeId=20) and (H.TriangleId=0),'nearest overlapping triangle');
    CheckNear(H.Distance,4,'nearest triangle distance');
    CheckNear(H.Barycentric.X+H.Barycentric.Y+H.Barycentric.Z,1,
      'triangle barycentric sum');
    R.Direction:=Vector3d(0,0,10);
    Check(Picker.Pick(S,R,H),'non-normalized ray hit');
    CheckNear(H.Distance,4,'non-normalized ray returns world distance');
    R.Direction:=Vector3d(0,0,0);
    Check(not Picker.Pick(S,R,H),'zero direction ray rejected');
  finally S.Free; end;

  S:=T3dScene.Create;
  try
    AddTriangleNode(S,30,5,Vector3d(-1,-1,0),Vector3d(1,-1,0),Vector3d(-1,1,0));
    R.Origin:=Vector3d(0.8,0.8,0); R.Direction:=Vector3d(0,0,1);
    Check(not Picker.Pick(S,R,H),'AABB false positive rejected by triangle');
    R.Origin:=Vector3d(3,0,0);
    N:=AddTriangleNode(S,40,4,Vector3d(-1,-1,0),Vector3d(1,-1,0),Vector3d(0,1,0));
    N.LocalTransform[12]:=3; N.WorldTransform[12]:=3;
    Check(Picker.Pick(S,R,H) and (H.NodeId=40),'transformed triangle hit');
    R.Origin:=Vector3d(20,20,0);
    Check(not Picker.Pick(S,R,H),'triangle picker no hit');
  finally S.Free; end;
end;

procedure TestHierarchicalTranslation;
var
  lScene:T3dScene;
  lParent,lChild,lGrandChild:T3dNode;
begin
  lScene:=T3dScene.Create;
  try
    lParent:=AddBoxNode(lScene,1,0,Vector3d(0,0,0));
    lChild:=AddBoxNode(lScene,2,1,Vector3d(0,2,0));
    lGrandChild:=AddBoxNode(lScene,3,2,Vector3d(0,2,5));
    { Parent local X maps to world +Y*2, local Y to world -X*3. }
    lParent.WorldTransform[0]:=0; lParent.WorldTransform[1]:=2;
    lParent.WorldTransform[4]:=-3; lParent.WorldTransform[5]:=0;
    lParent.WorldTransform[10]:=4;
    lParent.LocalTransform:=lParent.WorldTransform;
    lChild.LocalTransform[12]:=1; lChild.LocalTransform[13]:=0;
    lGrandChild.LocalTransform[12]:=0; lGrandChild.LocalTransform[13]:=0;
    lGrandChild.LocalTransform[14]:=5;
    Check(SetNodeWorldPosition(lScene,2,Vector3d(-3,4,4)),
      'move child under rotated-scaled parent');
    CheckNear(lChild.LocalTransform[12],2,'inverse parent local X');
    CheckNear(lChild.LocalTransform[13],1,'inverse parent local Y');
    CheckNear(lChild.LocalTransform[14],1,'inverse parent local Z');
    CheckNear(lGrandChild.WorldTransform[12],-3,'descendant follows X');
    CheckNear(lGrandChild.WorldTransform[13],4,'descendant follows Y');
    CheckNear(lGrandChild.WorldTransform[14],9,'descendant follows Z');

    Check(SetNodeWorldPositionComponents(lScene,1,Vector3d(1,2,0),[pcX,pcY]),
      'first batched drag');
    Check(SetNodeWorldPositionComponents(lScene,1,Vector3d(4,6,0),[pcX,pcY]),
      'second batched drag');
    CheckNear(lChild.WorldTransform[12],1,'child follows two drags X');
    CheckNear(lChild.WorldTransform[13],10,'child follows two drags Y');
    CheckNear(lGrandChild.WorldTransform[12],1,'grandchild follows two drags X');
    CheckNear(lGrandChild.WorldTransform[13],10,'grandchild follows two drags Y');
  finally
    lScene.Free;
  end;
end;

procedure TestLocalAxisObjectRotation;
var
  lScene:T3dScene;
  lParent,lChild:T3dNode;
begin
  lScene:=T3dScene.Create;
  try
    lParent:=AddBoxNode(lScene,1,0,Vector3d(0,0,0));
    lChild:=AddBoxNode(lScene,2,1,Vector3d(2,0,0));
    Check(RotateNodeLocalAxis(lScene,1,lraZ,90),'rotate local Z');
    CheckNear(lParent.WorldTransform[0],0,'rotated parent basis X.x');
    CheckNear(lParent.WorldTransform[1],1,'rotated parent basis X.y');
    CheckNear(lChild.WorldTransform[12],0,'child rotated around parent X');
    CheckNear(lChild.WorldTransform[13],2,'child rotated around parent Y');
    Check(RotateNodeLocalAxis(lScene,1,lraZ,90),'second local rotation');
    CheckNear(lChild.WorldTransform[12],-2,'child follows second rotation X');
    CheckNear(lChild.WorldTransform[13],0,'child follows second rotation Y');
  finally
    lScene.Free;
  end;
end;

procedure TestLogicalVertexTopology;
var
  M:T3dMeshData; T:T3dMeshTopology; R:T3dTopologyRelations;
begin
  M:=T3dMeshData.Create;
  try
    SetLength(M.Positions,5); SetLength(M.Triangles,2);
    M.Triangles[0].A:=0; M.Triangles[0].B:=1; M.Triangles[0].C:=2;
    M.Triangles[1].A:=3; M.Triangles[1].B:=2; M.Triangles[1].C:=4;
    SetLength(M.LogicalVertices,4);
    M.LogicalVertices[0].Id:=100; SetLength(M.LogicalVertices[0].CornerIndices,2);
    M.LogicalVertices[0].CornerIndices[0]:=0; M.LogicalVertices[0].CornerIndices[1]:=3;
    M.LogicalVertices[1].Id:=101; SetLength(M.LogicalVertices[1].CornerIndices,1); M.LogicalVertices[1].CornerIndices[0]:=1;
    M.LogicalVertices[2].Id:=102; SetLength(M.LogicalVertices[2].CornerIndices,1); M.LogicalVertices[2].CornerIndices[0]:=2;
    M.LogicalVertices[3].Id:=103; SetLength(M.LogicalVertices[3].CornerIndices,1); M.LogicalVertices[3].CornerIndices[0]:=4;
    T:=BuildMeshTopology(M);
    Check(Length(T.Vertices)=4,'logical row count');
    Check((T.CornerToLogical[0]=0) and (T.CornerToLogical[3]=0),'seam copies map to one logical vertex');
    Check((Length(T.LogicalToFaces[0])=2) and (T.Vertices[0].CornerCount=2),'logical faces and corner count');
    R:=ClassifyLogicalVertices(T,0);
    Check(R[0]=trPrimary,'selected logical vertex');
    Check((R[1]=trAdjacent) and (R[2]=trAdjacent) and (R[3]=trAdjacent),'neighbors across seam faces');
  finally M.Free; end;
end;

procedure TestTransformApi;
var S:T3dScene; P,C,G,P2,Z:T3dNode;
  M,F,BeforeLocal,Desired,GWorld,Frame,InFrame,Converted,Rotated:T3dMatrix;
  Stats:T3dTransformStats;
begin
  {$IFDEF CPUX86_64}
  Check(MatrixBackend in [mbSSE2,mbAVX],'x86-64 matrix SIMD backend selected');
  {$ENDIF}
  S:=T3dScene.Create;
  try
    P:=AddBoxNode(S,101,0,Vector3d(0,0,0));
    C:=AddBoxNode(S,102,101,Vector3d(1,0,0));
    G:=AddBoxNode(S,103,102,Vector3d(0,1,0));
    P2:=AddBoxNode(S,104,0,Vector3d(10,0,0));
    Z:=AddBoxNode(S,105,0,Vector3d(0,0,0));
    M:=P.LocalTransform; M[0]:=0; M[1]:=2; M[4]:=-3; M[5]:=0;
    P.LocalTransform:=M; SetIdentity(F); CommitSceneTransforms(S);
    CheckNear(C.WorldTransform[12],0,'parent rotate-scale child X');
    CheckNear(C.WorldTransform[13],2,'parent rotate-scale child Y');
    ResetTransformStats;
    Check(TranslateNode(S,C.Id,Vector3d(1,0,0),tsParent,F),
      'translate in parent frame');
    Stats:=TransformStats;
    Check((Stats.NodesUpdated=QWord(Length(S.Nodes))) and (Stats.BoundsRebuilt=0),
      'hot transform is one scan with deferred bounds');
    CheckNear(C.WorldTransform[13],4,'parent translation uses parent axis');
    CheckNear(G.WorldTransform[13],4,'descendant rebuilt after translation');
    Check(RotateNode(S,C.Id,Vector3d(0,0,1),Pi/2,Vector3d(0,0,0),
      tsWorld,F),'rotate around external pivot');
    CheckNear(C.WorldTransform[12],-4,'external pivot X');
    CheckNear(C.WorldTransform[13],0,'external pivot Y');
    Desired:=C.WorldTransform; GWorld:=G.WorldTransform;
    Check(ReparentNode(S,C.Id,P2.Id,True),'preserve-world reparent');
    CheckNear(C.WorldTransform[12],Desired[12],'reparent preserves world X');
    CheckNear(C.WorldTransform[13],Desired[13],'reparent preserves world Y');
    CheckNear(G.WorldTransform[12],GWorld[12],'reparent preserves descendant X');
    CheckNear(G.WorldTransform[13],GWorld[13],'reparent preserves descendant Y');

    SetIdentity(Frame); Frame[12]:=10; Frame[13]:=20;
    SetIdentity(M); M[12]:=12; M[13]:=23;
    Check(TryTransformToFrame(M,Frame,InFrame),'world transform to frame');
    CheckNear(InFrame[12],2,'frame-local X');
    CheckNear(InFrame[13],3,'frame-local Y');
    TransformFromFrame(InFrame,Frame,Converted);
    CheckNear(Converted[12],12,'frame roundtrip X');
    CheckNear(Converted[13],23,'frame roundtrip Y');
    Check(TryConvertTransformFrame(InFrame,Frame,F,Converted),
      'convert transform between arbitrary frames');
    CheckNear(Converted[12],12,'converted world-frame X');
    Check(TryRotateTransformInFrame(M,Frame,Vector3d(0,0,1),Pi/2,Rotated),
      'rotate transform in arbitrary frame');
    CheckNear(Rotated[12],7,'frame rotation around frame origin X');
    CheckNear(Rotated[13],22,'frame rotation around frame origin Y');

    M:=Z.LocalTransform; M[0]:=0; M[5]:=0; M[10]:=0;
    Check(SetNodeLocalTransform(S,Z.Id,M),'commit singular parent');
    BeforeLocal:=C.LocalTransform;
    Check(not ReparentNode(S,C.Id,Z.Id,True),'singular reparent rejected');
    Check(C.ParentId=P2.Id,'singular failure preserves parent');
    CheckNear(C.LocalTransform[12],BeforeLocal[12],
      'singular failure preserves local transform');
    G.ParentId:=Z.Id; CommitSceneTransforms(S);
    BeforeLocal:=G.LocalTransform; Desired:=G.WorldTransform; Desired[12]:=77;
    Check(not SetNodeWorldTransform(S,G.Id,Desired),'singular set-world rejected');
    CheckNear(G.LocalTransform[12],BeforeLocal[12],
      'singular set-world has no partial mutation');
  finally S.Free; end;
end;

procedure TestUnorderedHierarchyAndIndexedLookup;
var
  S:T3dScene;
  Child,Parent:T3dNode;
  Before,Attempt:T3dMatrix;
  I,NodeCount:Integer;
begin
  S:=T3dScene.Create;
  try
    Child:=AddBoxNode(S,202,201,Vector3d(2,0,0));
    Parent:=AddBoxNode(S,201,0,Vector3d(10,0,0));
    CommitSceneTransforms(S);
    CheckNear(Parent.WorldTransform[12],10,'unordered parent world position');
    CheckNear(Child.WorldTransform[12],12,'child-before-parent hierarchy rebuild');

    for I:=1 to 128 do
      AddBoxNode(S,1000+I,0,Vector3d(I,0,0));
    CommitSceneTransforms(S);
    NodeCount:=Length(S.Nodes);
    S.ResetLookupStats;
    for I:=1 to 128 do
      Check(S.FindNode(1000+I)<>nil,'indexed node lookup');
    Check(S.LookupProbes<QWord(NodeCount*8),
      'id lookup probe count must remain linear');

    Parent.ParentId:=Child.Id;
    Before:=Child.LocalTransform;
    Attempt:=Before; Attempt[12]:=99;
    Check(not SetNodeLocalTransform(S,Child.Id,Attempt),
      'mutation rejects cyclic hierarchy');
    CheckNear(Child.LocalTransform[12],Before[12],
      'cycle rejection leaves local transform unchanged');
  finally
    S.Free;
  end;
end;

procedure TestMissingParentIsRejected;
var
  S:T3dScene;
begin
  S:=T3dScene.Create;
  try
    AddBoxNode(S,301,999,Vector3d(1,2,3));
    Check(not S.ValidateHierarchy,
      'non-zero missing parent must not be treated as a root');
  finally
    S.Free;
  end;
end;

procedure TestProceduralPrimitivesAndRemoval;
var
  S: T3dScene;
  Spec: T3dPrimitiveSpec;
  Topology:T3dMeshTopology;
  Cube, Beam, PlaneNode, LineNode, Child, Survivor: T3dNode;
begin
  Spec.NodeId := 10;
  Spec.Kind := pkLine;
  Spec.Iterations := 0;
  Spec.CrossSectionIterations:=0;
  Check(NormalizePrimitiveSpec(Spec), 'persisted primitive spec accepted');
  Check(Spec.Iterations = 2, 'line point count normalized to minimum');
  Spec.Kind := pkCube;
  Spec.Iterations := 10000;
  Check(NormalizePrimitiveSpec(Spec), 'large persisted primitive normalized');
  Check(Spec.Iterations = 128, 'surface subdivisions normalized to maximum');
  Spec.NodeId := 0;
  Check(not NormalizePrimitiveSpec(Spec), 'zero node ID rejected');
  S := T3dScene.Create;
  try
    Spec.Position := Vector3d(0, 0, 0);
    Spec.Iterations := 3;
    Spec.CrossSectionIterations:=1;
    Spec.NodeId := 1;
    Spec.Name := 'cube';
    Spec.Kind := pkCube;
    Cube := CreatePrimitiveNode(Spec);
    Check(Length(Cube.Mesh.Positions) = 6 * 16, 'cube edge subdivisions');
    Check(Length(Cube.Mesh.Triangles) = 12 * 9, 'cube face subdivisions');
    Check((Cube.Mesh.Color.R<>0) or (Cube.Mesh.Color.G<>0) or
      (Cube.Mesh.Color.B<>0),'procedural mesh has visible default color');
    Check(Length(Cube.Mesh.Normals)=Length(Cube.Mesh.Positions),
      'procedural mesh normals generated');
    Topology:=BuildMeshTopology(Cube.Mesh);
    Check(Length(Topology.Vertices)=56,
      'subdivided flat cube welds duplicate face corners logically');
    Check(Topology.Vertices[0].CornerCount=3,
      'cube logical corner groups three face vertices');
    S.AddNode(Cube);

    Spec.NodeId := 2;
    Spec.Name := 'beam';
    Spec.Kind := pkBeam;
    Spec.CrossSectionIterations:=2;
    Beam := CreatePrimitiveNode(Spec);
    Check(Length(Beam.Mesh.Triangles)=8*3*2+4*2*2,
      'beam longitudinal and cross-section subdivisions');
    Beam.LocalTransform[12] := 7;
    Spec.Iterations := 5;
    Spec.CrossSectionIterations:=3;
    RebuildPrimitiveNodeGeometry(Beam, Spec);
    Check((Length(Beam.Mesh.Triangles)=8*5*3+4*3*3) and
      (Beam.LocalTransform[12] = 7) and (Beam.Id = 2),
      'live beam rebuild preserves node identity and transform');
    S.AddNode(Beam);

    Spec.Iterations := 3;
    Spec.NodeId := 3;
    Spec.Name := 'plane';
    Spec.Kind := pkPlane;
    PlaneNode := CreatePrimitiveNode(Spec);
    Check(Length(PlaneNode.Mesh.Positions) = 16, 'plane grid points');
    Check(Length(PlaneNode.Mesh.Triangles) = 18, 'plane grid faces');
    S.AddNode(PlaneNode);

    Spec.NodeId := 4;
    Spec.Name := 'line';
    Spec.Kind := pkLine;
    Spec.Iterations := 7;
    LineNode := CreatePrimitiveNode(Spec);
    Check(Length(LineNode.ShapeLines[0].Points) = 7, 'line point count');
    S.AddNode(LineNode);
    Spec.NodeId := QWord(1) shl 62;
    Spec.Name := 'high-id-line';
    LineNode := CreatePrimitiveNode(Spec);
    S.AddNode(LineNode);
    Check(S.FindNode(Spec.NodeId) = LineNode, '64-bit scene ID lookup');

    Child := T3dNode.Create;
    Child.Id := 5;
    Child.ParentId := Cube.Id;
    SetIdentity(Child.LocalTransform);
    SetIdentity(Child.WorldTransform);
    S.AddNode(Child);
    Survivor := Beam;
    Check(S.RemoveNode(Cube.Id), 'remove existing scene node');
    Check(S.FindNode(Cube.Id) = nil, 'removed node is not indexed');
    Check(S.FindNode(Child.Id) = nil, 'removed subtree is not indexed');
    Check(S.FindNode(Beam.Id) = Survivor, 'unrelated node identity preserved');
    Check(S.NextNodeId = (QWord(1) shl 62) + 1,
      'deleted highest ID is not reused');
  finally
    S.Free;
  end;
end;

procedure TestPointSkinLocalSpace;
var
  S: T3dScene;
  MeshNode,Helper: T3dNode;
  Engine: T3dSkinEngine;
  Influence: T3dSkinInfluence;
  Updated: Integer;
begin
  S := T3dScene.Create;
  Engine := T3dSkinEngine.Create;
  try
    MeshNode := T3dNode.Create;
    MeshNode.Id := 1; MeshNode.Kind := nkMesh;
    SetIdentity(MeshNode.LocalTransform); SetIdentity(MeshNode.WorldTransform);
    MeshNode.Mesh := T3dMeshData.Create;
    SetLength(MeshNode.Mesh.Positions,3);
    MeshNode.Mesh.Positions[0] := Vector3d(1,0,0);
    MeshNode.Mesh.Positions[1] := Vector3d(1,0,0);
    MeshNode.Mesh.Positions[2] := Vector3d(0,5,0);
    SetLength(MeshNode.Mesh.LogicalVertices,1);
    MeshNode.Mesh.LogicalVertices[0].Id := 77;
    SetLength(MeshNode.Mesh.LogicalVertices[0].CornerIndices,2);
    MeshNode.Mesh.LogicalVertices[0].CornerIndices[0] := 0;
    MeshNode.Mesh.LogicalVertices[0].CornerIndices[1] := 1;
    S.AddNode(MeshNode);
    Helper := T3dNode.Create;
    Helper.Id := 2; Helper.Kind := nkDummy; Helper.ParentId := MeshNode.Id;
    SetIdentity(Helper.LocalTransform); SetIdentity(Helper.WorldTransform);
    S.AddNode(Helper);
    S.RebuildWorldTransforms(Updated);
    Influence.MeshNodeId := 1; Influence.LogicalVertexId := 77;
    Influence.HelperNodeId := 2; Influence.Weight := 0.5;
    Influence.HelperBindWorld := Helper.WorldTransform;
    Engine.Configure(S,[Influence]);
    Helper.LocalTransform[12] := 2;
    S.RebuildWorldTransforms(Updated);
    Engine.Apply;
    CheckNear(MeshNode.Mesh.Positions[0].X,2,'skin weighted helper move');
    CheckNear(MeshNode.Mesh.Positions[1].X,2,'skin updates duplicate corners');
    CheckNear(MeshNode.Mesh.Positions[2].Y,5,'skin keeps unbound point');
    CheckNear(MeshNode.Mesh.BasePositions[0].X,1,
      'skin keeps immutable base position');
    CheckNear(MeshNode.LocalTransform[12],0,
      'skin does not mutate object local transform');
    MeshNode.LocalTransform[12] := 10;
    S.RebuildWorldTransforms(Updated);
    Engine.Apply;
    CheckNear(MeshNode.Mesh.Positions[0].X,2,
      'moving object with child helper preserves local deformation');
    Helper.LocalTransform[12] := 0;
    S.RebuildWorldTransforms(Updated);
    Engine.Apply;
    CheckNear(MeshNode.Mesh.Positions[0].X,1,'skin returns to immutable bind pose');
    Helper.LocalTransform[12]:=4;
    S.RebuildWorldTransforms(Updated);
    Engine.Apply;
    CheckNear(MeshNode.Mesh.Positions[0].X,3,
      'skin applies repeated live helper moves without reconfigure');
  finally
    Engine.Free;
    S.Free;
  end;
end;

procedure TestLegacyCornerSkinIdMigration;
var
  Scene:T3dScene;
  MeshNode,Helper:T3dNode;
  Engine:T3dSkinEngine;
  Influence:T3dSkinInfluence;
  Spec:T3dPrimitiveSpec;
  Updated,StableCorner:Integer;
  LegacyBase,StableBase:T3dVector;
begin
  Scene:=T3dScene.Create;
  Engine:=T3dSkinEngine.Create;
  try
    FillChar(Spec,SizeOf(Spec),0);
    Spec.NodeId:=1;
    Spec.Kind:=pkCube;
    Spec.Name:='legacy cube';
    Spec.Iterations:=3;
    Spec.CrossSectionIterations:=1;
    MeshNode:=CreatePrimitiveNode(Spec);
    Scene.AddNode(MeshNode);
    Helper:=T3dNode.Create;
    Helper.Id:=2;
    Helper.Kind:=nkDummy;
    SetIdentity(Helper.LocalTransform);
    Helper.WorldTransform:=Helper.LocalTransform;
    Scene.AddNode(Helper);
    Scene.RebuildWorldTransforms(Updated);
    FillChar(Influence,SizeOf(Influence),0);
    Influence.MeshNodeId:=1;
    Influence.LogicalVertexId:=32;
    Influence.VertexIdKind:=svikLegacyCorner;
    Influence.HelperNodeId:=2;
    Influence.Weight:=1;
    Influence.HelperBindWorld:=Helper.WorldTransform;
    LegacyBase:=MeshNode.Mesh.Positions[32];
    StableCorner:=MeshNode.Mesh.LogicalVertices[32].CornerIndices[0];
    StableBase:=MeshNode.Mesh.Positions[StableCorner];
    Engine.Configure(Scene,[Influence]);
    Helper.LocalTransform[12]:=1;
    Scene.RebuildWorldTransforms(Updated);
    Engine.Apply;
    CheckNear(MeshNode.Mesh.Positions[32].X,LegacyBase.X+1,
      'legacy corner id resolves through corner topology');
    CheckNear(MeshNode.Mesh.Positions[StableCorner].X,StableBase.X,
      'legacy corner id does not collide with stable logical id');
  finally
    Engine.Free;
    Scene.Free;
  end;
end;

procedure TestVertexColorGradientOverlapAndFanout;
var
  Mesh:T3dMeshData;
  Engine:T3dVertexColorEngine;
  Gradients:T3dGradientStrips;
  Anchors:T3dVertexColorAnchorEvals;
  Color:T3dColor;
begin
  FillChar(Gradients,SizeOf(Gradients),0);
  SetLength(Gradients,3);
  Gradients[0].LeftColor.R:=255; Gradients[0].RightColor.R:=255;
  Gradients[0].RightValue:=1;
  Gradients[1].LeftColor.B:=255; Gradients[1].RightColor.B:=255;
  Gradients[1].RightValue:=1;
  Gradients[2].LeftColor.G:=255; Gradients[2].RightColor.G:=255;
  Gradients[2].RightValue:=1;
  Color:=GradientColor(Gradients[0],0.5);
  Check(Color.R=255,'constant red gradient evaluates');

  Mesh:=T3dMeshData.Create;
  Engine:=T3dVertexColorEngine.Create;
  try
    SetLength(Mesh.Positions,3);
    Mesh.Positions[0]:=Vector3d(0,0,0);
    Mesh.Positions[1]:=Vector3d(0,0,0);
    Mesh.Positions[2]:=Vector3d(1,0,0);
    Mesh.BasePositions:=Copy(Mesh.Positions);
    SetLength(Mesh.LogicalVertices,2);
    Mesh.LogicalVertices[0].Id:=10;
    SetLength(Mesh.LogicalVertices[0].CornerIndices,2);
    Mesh.LogicalVertices[0].CornerIndices[0]:=0;
    Mesh.LogicalVertices[0].CornerIndices[1]:=1;
    Mesh.LogicalVertices[1].Id:=11;
    SetLength(Mesh.LogicalVertices[1].CornerIndices,1);
    Mesh.LogicalVertices[1].CornerIndices[0]:=2;
    SetLength(Anchors,3);
    Anchors[0].LogicalIndex:=0; Anchors[0].Radius:=2;
    Anchors[0].GradientIndex:=0; Anchors[0].Enabled:=True;
    Anchors[0].ApplyColor:=True;
    Anchors[1]:=Anchors[0]; Anchors[1].GradientIndex:=1;
    Anchors[2]:=Anchors[0]; Anchors[2].GradientIndex:=2;
    Anchors[2].ApplyColor:=False;
    Engine.Configure(Mesh,Gradients,Anchors);
    Engine.Apply;
    Check((Mesh.VertexColors[0].R=128) and (Mesh.VertexColors[0].B=128),
      'overlapping anchors blend with normalized weights');
    Check(Mesh.VertexColors[0].G=0,
      'label-only anchor is excluded from color normalization');
    Check((Mesh.VertexColors[1].R=Mesh.VertexColors[0].R) and
      (Mesh.VertexColors[1].B=Mesh.VertexColors[0].B),
      'logical color fans out to every render corner');
    Check((Mesh.VertexColors[2].R=128) and (Mesh.VertexColors[2].B=128),
      'bind-space neighbourhood colors nearby logical vertices');
    Engine.SetAnchorEnabled(1,False);
    Engine.Apply;
    Check((Mesh.VertexColors[0].R=255) and (Mesh.VertexColors[0].B=0),
      'inactive or invalid runtime anchor is excluded from normalization');
    Anchors[0].Radius:=0;
    SetLength(Anchors,1);
    Engine.Configure(Mesh,Gradients,Anchors);
    Engine.Apply;
    Check(Mesh.VertexColors[0].R=255,
      'zero-radius anchor colors its epicenter');
    Check(Mesh.VertexColors[2].R=Mesh.Color.R,
      'zero-radius anchor does not color neighbouring vertices');
  finally
    Engine.Free;
    Mesh.Free;
  end;
end;

begin
  try
    TestDefaultCubeIsSceneGeometry;
    TestRenderPassLightingPolicy;
    TestEditorOverlayDepthPolicy;
    TestSelectedHelperAxisIgnoresHelperScale;
    TestResolveVertexHighlightCorners;
    TestShapeBoundsAndPicking;
    TestShapePrimitive;
    TestInputModes;
    TestCameraMath;
    TestOrthographicInteractionMath;
    TestCameraPan;
    TestCanonicalCameraMatrices;
    TestFitBoxAllCorners;
    TestSelection;
    TestVertexPickMissKeepsObject;
    TestLocalAxisGizmo;
    TestGizmoSelectedAxis;
    TestCameraRotationConstraints;
    TestCameraRotateOverlay;
    TestScreenAxisHitTolerance;
    TestExclusiveInteractionContexts;
    TestSelectedPivotAndFit;
    TestWorldAabbPicking;
    TestTriangleScenePicker;
    TestHierarchicalTranslation;
    TestLocalAxisObjectRotation;
    TestLogicalVertexTopology;
    TestTransformApi;
    TestUnorderedHierarchyAndIndexedLookup;
    TestMissingParentIsRejected;
    TestProceduralPrimitivesAndRemoval;
    TestPointSkinLocalSpace;
    TestLegacyCornerSkinIdMigration;
    TestVertexColorGradientOverlapAndFanout;
    Writeln('RESULT ThreeDInteraction passed');
  except
    on E: Exception do
    begin
      Writeln('RESULT ThreeDInteraction failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
