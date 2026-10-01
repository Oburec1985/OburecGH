program ThreeDInteractionTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, Math, u3dCoreTypes, u3dScene, u3dSceneMath, u3dMeshTopology,
  u3dInteractionTypes, u3dInteractionMath,
  u3dCameraInteraction, u3dCameraRotateOverlay, u3dInputRouter, u3dSelection,
  u3dGizmo, u3dScreenGeometryMath, u3dInteractionDispatcher;

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
begin
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
  CheckNear(lCamera.YawDegrees, 10, 'yaw');
  CheckNear(lCamera.PitchDegrees, 89, 'pitch clamp');

  lCamera.VerticalFovDegrees := 60;
  FitCamera(lCamera, Vector3d(1, 2, 3), 1, lViewport);
  CheckNear(lCamera.Target.X, 1, 'fit target');
  Check(lCamera.Distance >= 2, 'fit contains sphere');
end;

procedure TestCameraPan;
var
  lCamera:T3dOrbitCamera;
  lViewport:T3dViewport;
begin
  FillChar(lCamera,SizeOf(lCamera),0); lCamera.Distance:=10;
  lCamera.VerticalFovDegrees:=60; lViewport.Width:=800; lViewport.Height:=600;
  PanCamera(lCamera,Point3d(60,30),lViewport);
  Check(lCamera.Target.X<0,'pan changes target horizontally');
  Check(lCamera.Target.Y>0,'pan changes target vertically');
  CheckNear(lCamera.Distance,10,'pan keeps distance');
  CheckNear(lCamera.YawDegrees,0,'pan keeps yaw');
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
  lForward,lRight,lUp:T3dVector;
begin
  FillChar(lCamera,SizeOf(lCamera),0);
  RotateCameraConstrained(lCamera,Point3d(10,20),1,crcX);
  CheckNear(lCamera.PitchDegrees,-20,'X constraint pitch');
  CheckNear(lCamera.YawDegrees,0,'X constraint keeps yaw');
  RotateCameraConstrained(lCamera,Point3d(10,20),1,crcY);
  CheckNear(lCamera.YawDegrees,10,'Y constraint yaw');
  CheckNear(lCamera.PitchDegrees,-20,'Y constraint keeps pitch');
  RotateCameraConstrained(lCamera,Point3d(15,20),1,crcZ);
  CheckNear(lCamera.RollDegrees,15,'Z constraint roll');
  CheckNear(lCamera.YawDegrees,10,'Z constraint keeps yaw');

  lCamera.YawDegrees:=0; lCamera.PitchDegrees:=0; lCamera.RollDegrees:=90;
  CameraBasis(lCamera,lForward,lRight,lUp);
  CheckNear(lRight.X,0,'roll rotates right X');
  CheckNear(lRight.Y,1,'roll rotates right into up');
  CheckNear(lUp.X,-1,'roll rotates up into left');
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
    lChild.LocalTransform[12]:=1; lChild.LocalTransform[13]:=0;
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

begin
  try
    TestInputModes;
    TestCameraMath;
    TestCameraPan;
    TestSelection;
    TestLocalAxisGizmo;
    TestGizmoSelectedAxis;
    TestCameraRotationConstraints;
    TestCameraRotateOverlay;
    TestScreenAxisHitTolerance;
    TestExclusiveInteractionContexts;
    TestSelectedPivotAndFit;
    TestWorldAabbPicking;
    TestHierarchicalTranslation;
    TestLocalAxisObjectRotation;
    TestLogicalVertexTopology;
    Writeln('RESULT ThreeDInteraction passed');
  except
    on E: Exception do
    begin
      Writeln('RESULT ThreeDInteraction failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
