unit u3dLclWidget;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Controls, OpenGLContext, u3dCoreTypes, u3dScene, u3dSceneMath, u3dContracts,
  u3dInteractionTypes, u3dInputRouter, u3dInteractionDispatcher, u3dGizmo, u3dCameraRotateOverlay,
  u3dLegacySceneLoader;

type
  T3dViewChangedEvent = procedure(Sender: TObject) of object;

  T3dLclWidget = class(TOpenGLControl, I3dRenderHost)
  private
    fRenderer: I3dRenderer;
    fSceneLoader:I3dSceneLoader;
    fScene: T3dScene;
    fOptions: T3dRenderOptions;
    fInput: T3dInputRouter;
    fDispatcher:T3dInteractionDispatcher;
    fCaptureToken:T3dCaptureToken;
    fInputMode: T3dInputMode;
    fCameraRotationConstraint:T3dCameraRotationConstraint;
    fGizmo: T3dGizmo;
    fCameraOverlay:T3dCameraRotateOverlay;
    fGizmoStart: T3dVector;
    fGizmoRotate:Boolean;
    fGizmoLastPoint:T3dPoint;
    fCamera: T3dCamera;
    fShowAxes: Boolean;
    fBackgroundColor: LongWord;
    fDirty: Boolean;
    fOnViewChanged: T3dViewChangedEvent;
    fOnSelectionChanged: TNotifyEvent;
    fSelectedNodeId: QWord;
    procedure ApplyInput(const AResult: T3dInputResult);
    function Modifiers(AShift: TShiftState): T3dModifiers;
    function OrbitCamera:T3dOrbitCamera;
    function MouseRay(X,Y:Integer):T3dRay;
    function ScreenGizmoHit(X,Y:Integer):T3dGizmoAxis;
    function SelectedNode:T3dNode;
    function PickNode(const ARay:T3dRay):QWord;
    function FindNode(AId:QWord):T3dNode;
    function GetSelectedObjectAxis:T3dGizmoAxis;
    function GetCameraRoll:Single;
    procedure SetCameraRoll(AValue:Single);
    procedure TranslateNodeWorld(ANode:T3dNode; const ANewPosition:T3dVector);
    procedure CancelInteraction;
    procedure PrepareCameraRotationPivot;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure DoExit; override;
    function ActivateContext: Boolean;
    procedure PresentFrame;
    function RenderWidth: Integer;
    function RenderHeight: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MarkDirty;
    procedure LoadScene(const AFileName: string);
    procedure ClearScene;
    procedure FitScene;
    procedure SetInputMode(AMode: T3dInputMode);
    procedure SelectObjectAxis(AAxis:T3dGizmoAxis);
    procedure SetCameraRotationConstraint(AConstraint:T3dCameraRotationConstraint);
    procedure SelectNode(AId:QWord);
    procedure SetNodeTranslationComponent(AId:QWord; AAxis:Integer; AValue:Single);
    procedure SetNodeTranslation(AId:QWord; const AValue:T3dVector;
      AMask:T3dPositionComponents);
    procedure SetRenderOptions(const AOptions: T3dRenderOptions);
    procedure SetRuntimeNormalLength(AValue:Single);
    procedure SetRenderer(const ARenderer:I3dRenderer);
    procedure SetSceneLoader(const ALoader:I3dSceneLoader);
    procedure SetView(AYaw, APitch, ADistance: Single; AShowAxes: Boolean;
      ABackgroundColor: LongWord);
    property Camera: T3dCamera read fCamera;
    property OnViewChanged: T3dViewChangedEvent read fOnViewChanged
      write fOnViewChanged;
    property OnSelectionChanged: TNotifyEvent read fOnSelectionChanged
      write fOnSelectionChanged;
    property Scene: T3dScene read fScene;
    property SelectedNodeId: QWord read fSelectedNodeId;
    property SelectedObjectAxis:T3dGizmoAxis read GetSelectedObjectAxis;
    property CameraRotationConstraint:T3dCameraRotationConstraint
      read fCameraRotationConstraint write SetCameraRotationConstraint;
    property CameraRoll:Single read GetCameraRoll write SetCameraRoll;
  end;

implementation

uses
  Math, u3dOpenGLRenderer,
  u3dCameraInteraction, u3dInteractionMath;

constructor T3dLclWidget.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoResizeViewport := False;
  fCamera.YawDegrees := 35;
  fCamera.PitchDegrees := -25;
  fCamera.Distance := 6;
  fShowAxes := True;
  fBackgroundColor := $0033291F;
  fDirty := True;
  fInput := T3dInputRouter.Create;
  fDispatcher:=T3dInteractionDispatcher.Create;
  fGizmo := T3dGizmo.Create;
  fCameraOverlay:=T3dCameraRotateOverlay.Create;
  fInputMode:=imSelect;
  fCameraRotationConstraint:=crcFree;
  fOptions.ShowAxes := True;
  fOptions.DrawFill := True;
  fOptions.NormalLength := 0.25;
  fOptions.BackgroundColor := fBackgroundColor;
  fRenderer := T3dOpenGLRenderer.Create(Self as I3dRenderHost);
  fSceneLoader:=T3dLegacySceneLoader.Create;
end;

destructor T3dLclWidget.Destroy;
begin
  CancelInteraction;
  fRenderer := nil;
  fInput.Free;
  fDispatcher.Free;
  fGizmo.Free;
  fCameraOverlay.Free;
  fScene.Free;
  inherited Destroy;
end;

procedure T3dLclWidget.MarkDirty;
begin
  fDirty := True;
  if HandleAllocated and Visible then Invalidate;
end;

procedure T3dLclWidget.SetView(AYaw, APitch, ADistance: Single;
  AShowAxes: Boolean; ABackgroundColor: LongWord);
begin
  fCamera.YawDegrees := AYaw;
  fCamera.PitchDegrees := APitch;
  fCamera.Distance := Max(2.5, ADistance);
  fShowAxes := AShowAxes;
  fBackgroundColor := ABackgroundColor;
  MarkDirty;
end;

procedure T3dLclWidget.Paint;
var B:T3dBounds; C:T3dVector; R,D:Single;
begin
  if (csDestroying in ComponentState) or (not fDirty) or
    (Parent = nil) or (not Parent.HandleAllocated) or
    (not HandleAllocated) or (not Visible) then Exit;
  fOptions.ShowAxes := fShowAxes;
  fOptions.BackgroundColor := fBackgroundColor;
  fOptions.SelectedNodeId := fSelectedNodeId;
  fOptions.SelectedAxis:=Ord(fGizmo.SelectedAxis);
  fOptions.CameraOverlayVisible:=fCameraOverlay.State<>crosHidden;
  fOptions.CameraOverlayHover:=Ord(fCameraOverlay.HoverHandle);
  fOptions.CameraOverlaySelected:=Ord(fCameraOverlay.SelectedHandle);
  fOptions.SceneClipRadius:=0;
  if (fScene<>nil) and fScene.Bounds.Valid then begin
    B:=fScene.Bounds; C:=Vector3d((B.Min.X+B.Max.X)*0.5,
      (B.Min.Y+B.Max.Y)*0.5,(B.Min.Z+B.Max.Z)*0.5);
    R:=0.5*Sqrt(Sqr(B.Max.X-B.Min.X)+Sqr(B.Max.Y-B.Min.Y)+Sqr(B.Max.Z-B.Min.Z));
    D:=Sqrt(Sqr(C.X-fCamera.Target.X)+Sqr(C.Y-fCamera.Target.Y)+Sqr(C.Z-fCamera.Target.Z));
    fOptions.SceneClipRadius:=R+D;
  end;
  fRenderer.Render(fScene, fCamera, fOptions);
  fDirty := False;
end;

procedure T3dLclWidget.Resize;
begin
  inherited Resize;
  if fInputMode=imRotate then
    fCameraOverlay.Show(Point3d(ClientWidth*0.5,ClientHeight*0.5),
      Max(36,Min(ClientWidth,ClientHeight)*0.22));
  MarkDirty;
end;

procedure T3dLclWidget.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var R: T3dInputResult; B: T3dPointerButton;
    A:T3dGizmoAxis; N:T3dNode; H:T3dCameraRotateHandle;
    Ctx:T3dInteractionContext;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button=mbLeft) and (fInputMode=imRotate) then begin
    H:=fCameraOverlay.HitTest(Point3d(X,Y));
    if H<>crhNone then begin
      if fCameraOverlay.SelectedHandle<>H then begin
        if not fDispatcher.TryCapture(ictOverlayPick,fCaptureToken) then Exit;
        fCameraOverlay.SelectHandle(H);
        SetCameraRotationConstraint(RotationConstraintForHandle(H));
        fDispatcher.Release(fCaptureToken); fCaptureToken:=0; MarkDirty; Exit;
      end;
      PrepareCameraRotationPivot;
      if fDispatcher.TryCapture(ictOverlayPick,fCaptureToken) and
        fCameraOverlay.BeginDrag(H,Point3d(X,Y)) then begin
        MouseCapture:=True; Exit;
      end else begin fDispatcher.Release(fCaptureToken); fCaptureToken:=0; end;
    end;
  end;
  if (Button=mbLeft) and (fInputMode=imSelect) then begin
    A:=ScreenGizmoHit(X,Y); N:=SelectedNode;
    if (A<>gaNone) and (N<>nil) then begin
      if fGizmo.SelectedAxis<>A then begin
        if fDispatcher.TryCapture(ictObjectSelect,fCaptureToken) then begin
          SelectObjectAxis(A); fDispatcher.Release(fCaptureToken); fCaptureToken:=0;
        end; Exit;
      end;
      if fDispatcher.TryCapture(ictObjectManipulate,fCaptureToken) and
        fGizmo.BeginDrag(A,MouseRay(X,Y)) then begin
        fGizmoStart:=Vector3d(N.WorldTransform[12],N.WorldTransform[13],N.WorldTransform[14]);
        fGizmoRotate:=ssCtrl in Shift; fGizmoLastPoint:=Point3d(X,Y);
        MouseCapture:=True; Exit;
      end else begin fDispatcher.Release(fCaptureToken); fCaptureToken:=0; end;
    end;
  end;
  case Button of mbLeft:B:=pbLeft; mbMiddle:B:=pbMiddle; mbRight:B:=pbRight;
  else B:=pbNone; end;
  case fInputMode of
    imSelect:Ctx:=ictObjectSelect; imPan:Ctx:=ictCameraPan;
    imRotate:Ctx:=ictCameraRotate; imZoom:Ctx:=ictCameraZoom;
  else Ctx:=ictNone; end;
  if not fDispatcher.TryCapture(Ctx,fCaptureToken) then Exit;
  fInput.PointerDown(B,Point3d(X,Y),Modifiers(Shift),R);
  if R.CapturePointer then MouseCapture:=True
  else begin fDispatcher.Release(fCaptureToken); fCaptureToken:=0; end;
end;

procedure T3dLclWidget.MouseMove(Shift: TShiftState; X, Y: Integer);
var R: T3dInputResult;
    D:T3dVector; N:T3dNode; A:T3dGizmoAxis; lAngle:Single;
    lCameraDelta:T3dPoint; C:T3dOrbitCamera; H:T3dCameraRotateHandle;
begin
  inherited MouseMove(Shift, X, Y);
  if (fDispatcher.ActiveContext=ictOverlayPick) and
    (fCameraOverlay.State in [crosPressed,crosDragging]) then begin
    if fCameraOverlay.UpdateDrag(Point3d(X,Y),lCameraDelta) then begin
      C:=OrbitCamera; RotateCameraConstrained(C,lCameraDelta,0.5,
        RotationConstraintForHandle(fCameraOverlay.SelectedHandle));
      fCamera.YawDegrees:=C.YawDegrees; fCamera.PitchDegrees:=C.PitchDegrees;
      fCamera.RollDegrees:=C.RollDegrees; MarkDirty;
      if Assigned(fOnViewChanged) then fOnViewChanged(Self);
    end;
    Exit;
  end;
  if (fDispatcher.ActiveContext=ictObjectManipulate) and
    (fGizmo.State=gsDragging) then begin
    N:=SelectedNode;
    if (N<>nil) and fGizmoRotate then begin
      lAngle:=((X-fGizmoLastPoint.X)-(Y-fGizmoLastPoint.Y))*0.5;
      if RotateNodeLocalAxis(fScene,N.Id,
        T3dLocalRotationAxis(Ord(fGizmo.SelectedAxis)-1),lAngle) then begin
        { Rotation around the selected local axis leaves that axis invariant.
          Rebuild the complete gizmo basis on MouseUp without interrupting drag. }
        fGizmoLastPoint:=Point3d(X,Y); MarkDirty;
      end;
    end else if (N<>nil) and fGizmo.UpdateDrag(MouseRay(X,Y),D) then begin
      TranslateNodeWorld(N,Add(fGizmoStart,D)); MarkDirty;
    end;
    Exit;
  end;
  if fInputMode=imRotate then begin
    H:=fCameraOverlay.HitTest(Point3d(X,Y));
    if H=crhNone then Cursor:=crDefault else Cursor:=crHandPoint;
    MarkDirty;
  end else if (fInputMode=imSelect) and (SelectedNode<>nil) then begin
    A:=ScreenGizmoHit(X,Y); fOptions.HotAxis:=Ord(A);
    if A=gaNone then Cursor:=crDefault else Cursor:=crSizeAll;
    MarkDirty;
  end else if Cursor<>crDefault then begin
    Cursor:=crDefault; fOptions.HotAxis:=0; MarkDirty;
  end;
  if fDispatcher.ActiveContext in [ictObjectSelect,ictCameraPan,
    ictCameraRotate,ictCameraZoom] then begin
    fInput.PointerMove(Point3d(X,Y),Modifiers(Shift),R); ApplyInput(R);
  end;
end;

procedure T3dLclWidget.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var R: T3dInputResult; B: T3dPointerButton;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (fDispatcher.ActiveContext=ictOverlayPick) and
    (fCameraOverlay.State in [crosPressed,crosDragging]) then begin
    fCameraOverlay.EndDrag; MouseCapture:=False;
    fDispatcher.Release(fCaptureToken); fCaptureToken:=0; MarkDirty; Exit;
  end;
  if (fDispatcher.ActiveContext=ictObjectManipulate) and
    (fGizmo.State=gsDragging) then begin fGizmo.EndDrag; MouseCapture:=False;
    fDispatcher.Release(fCaptureToken); fCaptureToken:=0;
    SelectNode(fSelectedNodeId); MarkDirty; Exit; end;
  case Button of mbLeft:B:=pbLeft; mbMiddle:B:=pbMiddle; mbRight:B:=pbRight;
  else B:=pbNone; end;
  fInput.PointerUp(B,Point3d(X,Y),Modifiers(Shift),R);
  if R.ReleasePointer then MouseCapture:=False;
  if (R.Command=icSelect) and
    (fDispatcher.ActiveContext=ictObjectSelect) then begin
    SelectNode(PickNode(MouseRay(X,Y)));
  end else ApplyInput(R);
  fDispatcher.Release(fCaptureToken); fCaptureToken:=0;
end;

function T3dLclWidget.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var R: T3dInputResult;
begin
  fInput.Wheel(WheelDelta/120,Point3d(MousePos.X,MousePos.Y),R);
  ApplyInput(R);
  Result := True;
end;

procedure T3dLclWidget.CancelInteraction;
var R:T3dInputResult;
begin
  if fGizmo<>nil then fGizmo.CancelDrag;
  if fCameraOverlay<>nil then fCameraOverlay.Hide;
  if fInput<>nil then fInput.Cancel(R);
  if fDispatcher<>nil then fDispatcher.Cancel;
  fCaptureToken:=0;
  if MouseCapture then MouseCapture:=False;
end;

procedure T3dLclWidget.DoExit;
begin
  CancelInteraction;
  inherited DoExit;
end;

function T3dLclWidget.Modifiers(AShift:TShiftState):T3dModifiers;
begin
  Result:=[];
  if ssCtrl in AShift then Include(Result,mdCtrl);
  if ssShift in AShift then Include(Result,mdShift);
  if ssAlt in AShift then Include(Result,mdAlt);
end;

procedure T3dLclWidget.ApplyInput(const AResult:T3dInputResult);
var C:T3dOrbitCamera; V:T3dViewport;
begin
  if AResult.Command=icNone then Exit;
  C.Target:=fCamera.Target; C.YawDegrees:=fCamera.YawDegrees;
  C.PitchDegrees:=fCamera.PitchDegrees; C.RollDegrees:=fCamera.RollDegrees;
  C.Distance:=fCamera.Distance;
  C.VerticalFovDegrees:=45; V.Width:=ClientWidth; V.Height:=ClientHeight;
  case AResult.Command of
    icRotate: RotateCameraConstrained(C,AResult.Delta,0.5,fCameraRotationConstraint);
    icPan: PanCamera(C,AResult.Delta,V);
    icZoom: ZoomCamera(C,AResult.Delta.Y);
  else Exit; end;
  fCamera.Target:=C.Target; fCamera.YawDegrees:=C.YawDegrees;
  fCamera.PitchDegrees:=C.PitchDegrees; fCamera.RollDegrees:=C.RollDegrees;
  fCamera.Distance:=C.Distance;
  MarkDirty; if Assigned(fOnViewChanged) then fOnViewChanged(Self);
end;

procedure T3dLclWidget.LoadScene(const AFileName:string);
var S:T3dScene;
begin
  if fSceneLoader=nil then raise Exception.Create('3D scene loader is not assigned');
  CancelInteraction;
  S:=fSceneLoader.LoadScene(AFileName);
  fScene.Free; fScene:=S; fSelectedNodeId:=0; FitScene;
end;

procedure T3dLclWidget.SetRenderer(const ARenderer:I3dRenderer);
begin fRenderer:=ARenderer; MarkDirty; end;

procedure T3dLclWidget.SetSceneLoader(const ALoader:I3dSceneLoader);
begin fSceneLoader:=ALoader; end;

procedure T3dLclWidget.ClearScene;
begin CancelInteraction; FreeAndNil(fScene); fSelectedNodeId:=0; MarkDirty; end;

procedure T3dLclWidget.FitScene;
var C:T3dOrbitCamera; V:T3dViewport; B:T3dBounds; N:T3dNode;
begin
  if (fScene=nil) or not fScene.Bounds.Valid then Exit;
  N:=SelectedNode; if N<>nil then B:=WorldBounds(N) else B:=fScene.Bounds;
  if not B.Valid then B:=fScene.Bounds;
  C.Target:=fCamera.Target; C.YawDegrees:=fCamera.YawDegrees; C.PitchDegrees:=fCamera.PitchDegrees;
  C.RollDegrees:=fCamera.RollDegrees; C.Distance:=fCamera.Distance;
  C.VerticalFovDegrees:=45; V.Width:=ClientWidth; V.Height:=ClientHeight;
  FitCameraToBox(C,B.Min,B.Max,V); fCamera.Target:=C.Target; fCamera.Distance:=C.Distance;
  MarkDirty; if Assigned(fOnViewChanged) then fOnViewChanged(Self);
end;

procedure T3dLclWidget.SetInputMode(AMode:T3dInputMode);
begin
  CancelInteraction; fInputMode:=AMode; fInput.Mode:=AMode;
  if AMode=imRotate then
    fCameraOverlay.Show(Point3d(ClientWidth*0.5,ClientHeight*0.5),
      Max(36,Min(ClientWidth,ClientHeight)*0.22));
  MarkDirty;
end;

procedure T3dLclWidget.PrepareCameraRotationPivot;
var N:T3dNode; B:T3dBounds;
begin
  N:=SelectedNode;
  if N<>nil then begin
    fCamera.Target:=NodeWorldPivot(N);
  end else if (fScene<>nil) and fScene.Bounds.Valid then begin
    B:=fScene.Bounds; fCamera.Target:=Vector3d((B.Min.X+B.Max.X)*0.5,
      (B.Min.Y+B.Max.Y)*0.5,(B.Min.Z+B.Max.Z)*0.5);
  end;
end;

function T3dLclWidget.OrbitCamera:T3dOrbitCamera;
begin Result.Target:=fCamera.Target; Result.YawDegrees:=fCamera.YawDegrees;
  Result.PitchDegrees:=fCamera.PitchDegrees; Result.RollDegrees:=fCamera.RollDegrees;
  Result.Distance:=fCamera.Distance;
  Result.VerticalFovDegrees:=45; end;

function T3dLclWidget.MouseRay(X,Y:Integer):T3dRay;
var V:T3dViewport;
begin V.Width:=ClientWidth; V.Height:=ClientHeight; Result:=CameraRay(OrbitCamera,V,Point3d(X,Y)); end;

function T3dLclWidget.ScreenGizmoHit(X,Y:Integer):T3dGizmoAxis;
var V:T3dViewport;
begin
  V.Width:=ClientWidth; V.Height:=ClientHeight;
  Result:=fGizmo.HitTestScreen(OrbitCamera,V,Point3d(X,Y));
end;

function T3dLclWidget.SelectedNode:T3dNode;
begin Result:=FindNode(fSelectedNodeId); end;

function T3dLclWidget.FindNode(AId:QWord):T3dNode;
begin Result:=FindSceneNode(fScene,AId); end;

function T3dLclWidget.PickNode(const ARay:T3dRay):QWord;
begin Result:=PickWorldAabb(fScene,ARay.Origin,ARay.Direction); end;

procedure T3dLclWidget.TranslateNodeWorld(ANode:T3dNode; const ANewPosition:T3dVector);
begin
  if ANode<>nil then SetNodeWorldPosition(fScene,ANode.Id,ANewPosition);
end;

procedure T3dLclWidget.SetNodeTranslationComponent(AId:QWord; AAxis:Integer; AValue:Single);
var P:T3dVector; M:T3dPositionComponents;
begin
  P:=Vector3d(AValue,AValue,AValue);
  case AAxis of 0:M:=[pcX]; 1:M:=[pcY]; 2:M:=[pcZ]; else Exit; end;
  SetNodeTranslation(AId,P,M);
end;

procedure T3dLclWidget.SetNodeTranslation(AId:QWord; const AValue:T3dVector;
  AMask:T3dPositionComponents);
begin
  if SetNodeWorldPositionComponents(fScene,AId,AValue,AMask) then MarkDirty;
end;

procedure T3dLclWidget.SelectNode(AId:QWord);
var N:T3dNode; AB:T3dAxisBasis; lChanged:Boolean;
begin lChanged:=fSelectedNodeId<>AId; fSelectedNodeId:=AId; N:=SelectedNode;
  if N=nil then fGizmo.Hide else begin
    if lChanged then fGizmo.SelectAxis(gaNone);
    AB.XAxis:=Vector3d(N.WorldTransform[0],N.WorldTransform[1],N.WorldTransform[2]);
    AB.YAxis:=Vector3d(N.WorldTransform[4],N.WorldTransform[5],N.WorldTransform[6]);
    AB.ZAxis:=Vector3d(N.WorldTransform[8],N.WorldTransform[9],N.WorldTransform[10]);
    fGizmo.Show(Vector3d(N.WorldTransform[12],N.WorldTransform[13],N.WorldTransform[14]),AB,1.5);
  end;
  if Assigned(fOnSelectionChanged) then fOnSelectionChanged(Self); MarkDirty;
end;

procedure T3dLclWidget.SelectObjectAxis(AAxis:T3dGizmoAxis);
begin
  if SelectedNode=nil then AAxis:=gaNone;
  fGizmo.SelectAxis(AAxis); fOptions.SelectedAxis:=Ord(AAxis); MarkDirty;
end;

function T3dLclWidget.GetSelectedObjectAxis:T3dGizmoAxis;
begin Result:=fGizmo.SelectedAxis; end;

procedure T3dLclWidget.SetCameraRotationConstraint(
  AConstraint:T3dCameraRotationConstraint);
begin
  fCameraRotationConstraint:=AConstraint;
  if fInputMode=imRotate then case AConstraint of
    crcX:fCameraOverlay.SelectHandle(crhX);
    crcY:fCameraOverlay.SelectHandle(crhY);
    crcZ:fCameraOverlay.SelectHandle(crhZ);
  else fCameraOverlay.SelectHandle(crhNone); end;
  MarkDirty;
end;

function T3dLclWidget.GetCameraRoll:Single;
begin Result:=fCamera.RollDegrees; end;

procedure T3dLclWidget.SetCameraRoll(AValue:Single);
begin
  if SameValue(fCamera.RollDegrees,AValue) then Exit;
  fCamera.RollDegrees:=AValue; MarkDirty;
  if Assigned(fOnViewChanged) then fOnViewChanged(Self);
end;

procedure T3dLclWidget.SetRenderOptions(const AOptions:T3dRenderOptions);
begin fOptions:=AOptions; MarkDirty; end;

procedure T3dLclWidget.SetRuntimeNormalLength(AValue:Single);
begin if SameValue(fOptions.NormalLength,AValue) then Exit;
  fOptions.NormalLength:=AValue; MarkDirty; end;

function T3dLclWidget.ActivateContext: Boolean;
begin
  Result := False;
  if (csDestroying in ComponentState) or (Parent = nil) or
    (not Parent.HandleAllocated) or (not HandleAllocated) then Exit;
  MakeCurrent;
  Result := True;
end;

procedure T3dLclWidget.PresentFrame;
begin
  if (csDestroying in ComponentState) or (Parent = nil) or
    (not Parent.HandleAllocated) or (not HandleAllocated) then Exit;
  SwapBuffers;
end;

function T3dLclWidget.RenderWidth: Integer;
begin
  Result := ClientWidth;
end;

function T3dLclWidget.RenderHeight: Integer;
begin
  Result := ClientHeight;
end;

end.
