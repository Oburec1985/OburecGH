unit u3dLclWidget;

{ LCL/OpenGL host that coordinates one owned scene across rendering, picking,
  fitting, and manipulation. Injected renderer, loader, and picker strategies
  are interface-managed and never own the scene. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Controls, OpenGLContext, u3dCoreTypes, u3dScene,
  u3dSceneMath, u3dGeometryMath, u3dContracts, u3dInteractionTypes, u3dInputRouter,
  u3dInteractionDispatcher, u3dGizmo, u3dCameraRotateOverlay,
  u3dLegacySceneLoader, u3dScenePicker, u3dSelection;

type
  T3dViewChangedEvent = procedure (Sender: TObject) of object;
  T3dVertexPickedEvent = procedure(Sender: TObject; ANodeId: QWord;
    ALogicalVertex: Integer) of object;
  T3dNodeTransformChangedEvent = procedure(Sender: TObject;
    ANodeId: QWord) of object;
  T3dInteractionTraceEvent = procedure (const AMessage: string) of object;

  T3dLclWidget = class(TOpenGLControl, I3dRenderHost)
  private
    fRenderer: I3dRenderer;
    fSceneLoader: I3dSceneLoader;
    fScenePicker: I3dScenePicker;
    fScene: T3dScene;
    fOptions: T3dRenderOptions;
    fInput: T3dInputRouter;
    fDispatcher: T3dInteractionDispatcher;
    fCaptureToken: T3dCaptureToken;
    fInputMode: T3dInputMode;
    fCameraRotationConstraint: T3dCameraRotationConstraint;
    fGizmo: T3dGizmo;
    fCameraOverlay: T3dCameraRotateOverlay;
    fGizmoStart: T3dVector;
    fGizmoRotate: Boolean;
    fGizmoLastPoint: T3dPoint;
    fOverlayRotateObject: Boolean;
    fOverlayRotateNodeId: QWord;
    fCamera: T3dCamera;
    fPerspectiveCamera: T3dCamera;
    fHasPerspectiveCamera: Boolean;
    fShowAxes: Boolean;
    fBackgroundColor: LongWord;
    fDirty: Boolean;
    fOnViewChanged: T3dViewChangedEvent;
    fOnSelectionChanged: TNotifyEvent;
    fOnVertexPicked: T3dVertexPickedEvent;
    fOnNodeTransformChanged: T3dNodeTransformChangedEvent;
    fOnInteractionTrace: T3dInteractionTraceEvent;
    fInteractionEnabled: Boolean;
    fSelectedNodeId: QWord;
    fOverlayNodeId: QWord;
    procedure ApplyInput(const AResult: T3dInputResult);
    function Modifiers(AShift: TShiftState): T3dModifiers;
    function OrbitCamera: T3dOrbitCamera;
    function MouseRay(X, Y: Integer): T3dRay;
    function ScreenGizmoHit(X, Y: Integer): T3dGizmoAxis;
    function SelectedNode: T3dNode;
    function PickScene(const ARay: T3dRay; out AHit: T3dHit): Boolean;
    function LogicalVertexFromNode(ANodeId: QWord; X,Y:Integer): Integer;
    function FindNode(AId: QWord): T3dNode;
    function GetSelectedObjectAxis: T3dGizmoAxis;
    function GetCameraRoll: Single;
    procedure SetCameraRoll(AValue: Single);
    procedure TranslateNodeWorld(ANode: T3dNode;
      const ANewPosition: T3dVector);
    procedure Trace(const AMessage: string);
    procedure PrepareCameraRotationPivot;
    procedure SetInteractionEnabled(AValue: Boolean);
    procedure UpdateInteractionCursor;
  protected
    procedure CancelInteraction;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
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
    { Takes ownership of AScene and releases the previously active scene. }
    procedure ReplaceScene(AScene: T3dScene);
    procedure ResetToDefaultScene;
    procedure FitScene;
    procedure SetInputMode(AMode: T3dInputMode);
    procedure SelectObjectAxis(AAxis: T3dGizmoAxis);
    procedure SetCameraRotationConstraint(
      AConstraint: T3dCameraRotationConstraint);
    procedure SelectNode(AId: QWord);
    procedure SetNodeTranslationComponent(AId: QWord; AAxis: Integer;
      AValue: Single);
    procedure SetNodeTranslation(AId: QWord; const AValue: T3dVector;
      AMask: T3dPositionComponents);
    procedure SetRenderOptions(const AOptions: T3dRenderOptions);
    procedure SetOverlayNodeId(AId:QWord);
    procedure SetVertexHighlight(ANodeId: QWord;
      const APrimaryCorners, AAdjacentCorners: array of LongWord);
    procedure ClearVertexHighlight;
    procedure SetRuntimeNormalLength(AValue: Single);
    procedure SetRenderer(const ARenderer: I3dRenderer);
    procedure SetSceneLoader(const ALoader: I3dSceneLoader);
    procedure SetScenePicker(const APicker: I3dScenePicker);
    procedure SetView(AYaw, APitch, ADistance: Single; AShowAxes: Boolean;
      ABackgroundColor: LongWord);
    procedure SetCameraState(const ACamera: T3dCamera);
    procedure SetStandardView(AView: T3dStandardView);
    function CurrentOrbitCamera:T3dOrbitCamera;
    property Camera: T3dCamera read fCamera;
    property OnViewChanged: T3dViewChangedEvent read fOnViewChanged
      write fOnViewChanged;
    property OnSelectionChanged: TNotifyEvent read fOnSelectionChanged
      write fOnSelectionChanged;
    property OnVertexPicked: T3dVertexPickedEvent read fOnVertexPicked
      write fOnVertexPicked;
    property OnNodeTransformChanged: T3dNodeTransformChangedEvent
      read fOnNodeTransformChanged write fOnNodeTransformChanged;
    property Scene: T3dScene read fScene;
    property SelectedNodeId: QWord read fSelectedNodeId;
    property SelectedObjectAxis: T3dGizmoAxis read GetSelectedObjectAxis;
    property CameraRotationConstraint: T3dCameraRotationConstraint
      read fCameraRotationConstraint write SetCameraRotationConstraint;
    property CameraRoll: Single read GetCameraRoll write SetCameraRoll;
    property InteractionEnabled: Boolean read fInteractionEnabled
      write SetInteractionEnabled;
    property OnInteractionTrace: T3dInteractionTraceEvent
      read fOnInteractionTrace write fOnInteractionTrace;
  end;

implementation

uses
  Math, u3dOpenGLRenderer,
  u3dCamera, u3dCameraInteraction, u3dInteractionMath, u3dTransforms,
  u3dPrimitives, u3dScreenGeometryMath;

procedure T3dLclWidget.Trace(const AMessage: string);
begin
  if Assigned(fOnInteractionTrace) then
    fOnInteractionTrace(AMessage);
end;

function T3dLclWidget.CurrentOrbitCamera:T3dOrbitCamera;
begin
  Result:=OrbitCamera;
end;

constructor T3dLclWidget.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoResizeViewport := False;
  fCamera.YawDegrees := 35;
  fCamera.PitchDegrees := -25;
  fCamera.Distance := 6;
  fCamera.VerticalFovDegrees := 45;
  fCamera.ProjectionKind := pkPerspective;
  fCamera.OrthographicScale := 3;
  fShowAxes := True;
  fBackgroundColor := $0033291F;
  fDirty := True;
  fInput := T3dInputRouter.Create;
  fDispatcher := T3dInteractionDispatcher.Create;
  fGizmo := T3dGizmo.Create;
  fCameraOverlay := T3dCameraRotateOverlay.Create;
  fInputMode := imSelect;
  fInteractionEnabled := True;
  fCameraRotationConstraint := crcFree;
  fOptions.ShowAxes := True;
  fOptions.DrawFill := True;
  fOptions.NormalLength := 0.25;
  fOptions.BackgroundColor := fBackgroundColor;
  fOptions.PointColor.R:=255;
  fOptions.PointColor.G:=128;
  fOptions.PointColor.B:=16;
  fOptions.UseDefaultLighting := True;
  fOptions.DefaultAmbient := 0.35;
  fOptions.DefaultDiffuse := 0.75;
  fOptions.DefaultLightDirection := Vector3d(0.35, 0.65, 1);
  fRenderer := T3dOpenGLRenderer.Create(Self as I3dRenderHost);
  fSceneLoader := T3dLegacySceneLoader.Create;
  fScenePicker := T3dCpuScenePicker.Create;
  ReplaceScene(CreateDefaultCubeScene);
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
  if HandleAllocated and Visible then
    Invalidate;
end;

procedure T3dLclWidget.SetView(AYaw, APitch, ADistance: Single;
                               AShowAxes: Boolean; ABackgroundColor: LongWord);
begin
  fCamera.YawDegrees := AYaw;
  fCamera.PitchDegrees := APitch;
  fCamera.PoseValid := False;
  fCamera.Distance := Max(2.5, ADistance);
  fShowAxes := AShowAxes;
  fBackgroundColor := ABackgroundColor;
  MarkDirty;
end;

procedure T3dLclWidget.SetCameraState(const ACamera: T3dCamera);
begin
  fCamera := ACamera;
  if fCamera.Distance < 0.001 then
    fCamera.Distance := 0.001;
  if (fCamera.VerticalFovDegrees <= 1) or
     (fCamera.VerticalFovDegrees >= 179) then
    fCamera.VerticalFovDegrees := 45;
  MarkDirty;
end;

procedure T3dLclWidget.SetStandardView(AView: T3dStandardView);
begin
  CancelInteraction;
  if AView = svCamera then
  begin
    if fHasPerspectiveCamera then
      fCamera := fPerspectiveCamera
    else
      fCamera.ProjectionKind := pkPerspective;
  end
  else
  begin
    if fCamera.ProjectionKind = pkPerspective then
    begin
      fPerspectiveCamera := fCamera;
      fHasPerspectiveCamera := True;
    end;
    fCamera.ProjectionKind := pkOrthographic;
    fCamera.OrthographicScale := Max(0.1, fCamera.Distance * 0.5);
    fCamera.RollDegrees := 0;
    fCamera.PoseValid := False;
    case AView of
      svTop: begin fCamera.YawDegrees := 0; fCamera.PitchDegrees := -90; end;
      svFront: begin fCamera.YawDegrees := 0; fCamera.PitchDegrees := 0; end;
      svBottom: begin fCamera.YawDegrees := 0; fCamera.PitchDegrees := 90; end;
      else ;
    end;
  end;
  if fCamera.ProjectionKind = pkOrthographic then
    fCameraOverlay.Hide;
  MarkDirty;
  if Assigned(fOnViewChanged) then
    fOnViewChanged(Self);
end;

procedure T3dLclWidget.Paint;

var
  B: T3dBounds;
  C: T3dVector;
  R, D: Single;
begin
  if (csDestroying in ComponentState) or
     (Parent = nil) or (not Parent.HandleAllocated) or
     (not HandleAllocated) or (not Visible) then
    Exit;
  fOptions.ShowAxes := fShowAxes;
  fOptions.BackgroundColor := fBackgroundColor;
  fOptions.SelectedNodeId := fSelectedNodeId;
  fOptions.OverlayNodeId := fOverlayNodeId;
  fOptions.SelectedAxis := Ord(fGizmo.SelectedAxis);
  fOptions.CameraOverlayVisible := fCameraOverlay.State <> crosHidden;
  fOptions.CameraOverlayHover := Ord(fCameraOverlay.HoverHandle);
  fOptions.CameraOverlaySelected := Ord(fCameraOverlay.SelectedHandle);
  fOptions.SceneClipRadius := 0;
  if (fScene <> nil) and fScene.Bounds.Valid then
  begin
    B := fScene.Bounds;
    C := Vector3d((B.Min.X + B.Max.X) * 0.5,
      (B.Min.Y + B.Max.Y) * 0.5, (B.Min.Z + B.Max.Z) * 0.5);
    R := 0.5 * Sqrt(Sqr(B.Max.X - B.Min.X) +
      Sqr(B.Max.Y - B.Min.Y) + Sqr(B.Max.Z - B.Min.Z));
    D := Sqrt(Sqr(C.X - fCamera.Target.X) +
      Sqr(C.Y - fCamera.Target.Y) + Sqr(C.Z - fCamera.Target.Z));
    fOptions.SceneClipRadius := R + D;
  end;
  fRenderer.Render(fScene, fCamera, fOptions);
  fDirty := False;
end;

procedure T3dLclWidget.SetOverlayNodeId(AId:QWord);
begin
  if fOverlayNodeId=AId then
    Exit;
  fOverlayNodeId:=AId;
  MarkDirty;
end;

procedure T3dLclWidget.Resize;
begin
  inherited Resize;
  if fInputMode = imRotate then
    fCameraOverlay.Show(Point3d(ClientWidth * 0.5, ClientHeight * 0.5),
      Max(36, Min(ClientWidth, ClientHeight) * 0.22));
  MarkDirty;
end;

procedure T3dLclWidget.MouseDown(Button: TMouseButton; Shift: TShiftState;
                                 X, Y: Integer);

var R: T3dInputResult;
  B: T3dPointerButton;
  A: T3dGizmoAxis;
  N: T3dNode;
  H: T3dCameraRotateHandle;
  Ctx: T3dInteractionContext;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if CanFocus then
    SetFocus;
  if not fInteractionEnabled then
    Exit;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('mouse-down button=%d x=%d y=%d mode=%d',
      [Ord(Button), X, Y, Ord(fInputMode)]));
  if (Button=mbLeft) and (fInputMode=imRotate) then
    begin
      H := fCameraOverlay.HitTest(Point3d(X,Y));
      if Assigned(fOnInteractionTrace) then
        Trace(Format('overlay-hit handle=%d', [Ord(H)]));
      if H<>crhNone then
        begin
          if fCameraOverlay.SelectedHandle<>H then
            begin
              if not fDispatcher.TryCapture(ictOverlayPick,fCaptureToken) then
                begin
                  Trace('capture denied overlay-select');
                  Exit;
                end;
              if Assigned(fOnInteractionTrace) then
                Trace(Format('capture overlay-select token=%d', [fCaptureToken]));
              fCameraOverlay.SelectHandle(H);
              SetCameraRotationConstraint(RotationConstraintForHandle(H));
              fDispatcher.Release(fCaptureToken);
              Trace('release overlay-select');
              fCaptureToken := 0;
              MarkDirty;
            end;
          fOverlayRotateObject := (ssCtrl in Shift) and (SelectedNode<>nil);
          if fOverlayRotateObject then
            fOverlayRotateNodeId := SelectedNode.Id
          else
            fOverlayRotateNodeId := 0;
          if not fOverlayRotateObject then
            PrepareCameraRotationPivot;
          if fDispatcher.TryCapture(ictOverlayPick,fCaptureToken) and
             fCameraOverlay.BeginDrag(H,Point3d(X,Y)) then
            begin
              if Assigned(fOnInteractionTrace) then
                Trace(Format('capture overlay-drag token=%d', [fCaptureToken]));
              MouseCapture := True;
              Exit;
            end
          else
            begin
              fDispatcher.Release(fCaptureToken);
              fCaptureToken := 0;
            end;
        end;
      { A drag outside the coloured handles is an unconstrained orbit. Do not
        leak the last selected local-axis constraint into the background. }
      if H=crhNone then
        SetCameraRotationConstraint(crcFree);
    end;
  if (Button=mbLeft) and (fInputMode=imSelect) then
    begin
      A := ScreenGizmoHit(X,Y);
      N := SelectedNode;
      if Assigned(fOnInteractionTrace) then
        Trace(Format('gizmo-hit axis=%d node=%d', [Ord(A), fSelectedNodeId]));
      if (A<>gaNone) and (N<>nil) then
        begin
          if fGizmo.SelectedAxis<>A then
            begin
              if fDispatcher.TryCapture(ictObjectSelect,fCaptureToken) then
                begin
                  if Assigned(fOnInteractionTrace) then
                    Trace(Format('capture axis-select token=%d', [fCaptureToken]));
                  SelectObjectAxis(A);
                  fDispatcher.Release(fCaptureToken);
                  Trace('release axis-select');
                  fCaptureToken := 0;
                end;
              Exit;
            end;
          if fDispatcher.TryCapture(ictObjectManipulate,fCaptureToken) and
             fGizmo.BeginDrag(A,MouseRay(X,Y)) then
            begin
              fGizmoStart := Vector3d(N.WorldTransform[12],N.WorldTransform[13],N.WorldTransform[14]
                             );
              fGizmoRotate := ssCtrl in Shift;
              fGizmoLastPoint := Point3d(X,Y);
              if Assigned(fOnInteractionTrace) then
                Trace(Format('capture object-manipulate token=%d rotate=%s',
                  [fCaptureToken, BoolToStr(fGizmoRotate, True)]));
              MouseCapture := True;
              Exit;
            end
          else
            begin
              fDispatcher.Release(fCaptureToken);
              fCaptureToken := 0;
            end;
        end;
    end;
  case Button of
    mbLeft: B := pbLeft;
    mbMiddle: B := pbMiddle;
    mbRight: B := pbRight;
    else B := pbNone;
  end;
  case fInputMode of
    imSelect: Ctx := ictObjectSelect;
    imPan: Ctx := ictCameraPan;
    imRotate: Ctx := ictCameraRotate;
    imZoom: Ctx := ictCameraZoom;
    else Ctx := ictNone;
  end;
  if not fDispatcher.TryCapture(Ctx,fCaptureToken) then
    begin
      if Assigned(fOnInteractionTrace) then
        Trace(Format('capture denied context=%d', [Ord(Ctx)]));
      Exit;
    end;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('capture context=%d token=%d', [Ord(Ctx), fCaptureToken]));
  fInput.PointerDown(B,Point3d(X,Y),Modifiers(Shift),R);
  if R.CapturePointer then
    MouseCapture := True
  else
    begin
      fDispatcher.Release(fCaptureToken);
      fCaptureToken := 0;
    end;
end;

procedure T3dLclWidget.MouseMove(Shift: TShiftState; X, Y: Integer);

var R: T3dInputResult;
  D: T3dVector;
  N: T3dNode;
  A: T3dGizmoAxis;
  lAngle: Single;
  lCameraDelta: T3dPoint;
  C: T3dOrbitCamera;
  H: T3dCameraRotateHandle;
begin
  inherited MouseMove(Shift, X, Y);
  if not fInteractionEnabled then
    Exit;
  if (fDispatcher.ActiveContext=ictOverlayPick) and
     (fCameraOverlay.State in [crosPressed,crosDragging]) then
    begin
      if fCameraOverlay.UpdateDrag(Point3d(X,Y),lCameraDelta) then
        begin
          if fOverlayRotateObject then
            N := FindNode(fOverlayRotateNodeId)
          else
            N := nil;
          if fOverlayRotateObject and (N<>nil) then
          begin
            case fCameraOverlay.SelectedHandle of
              crhX:
                begin
                  A:=gaX;
                  lAngle:=-lCameraDelta.Y*0.5;
                end;
              crhY:
                begin
                  A:=gaY;
                  lAngle:=lCameraDelta.X*0.5;
                end;
              else
                begin
                  A:=gaZ;
                  lAngle:=lCameraDelta.X*0.5;
                end;
            end;
            if RotateNodeLocalAxis(fScene,N.Id,
               T3dLocalRotationAxis(Ord(A)-1),lAngle) then
            begin
              MarkDirty;
              if Assigned(fOnInteractionTrace) then
                Trace(Format('overlay object rotate node=%d angle=%.3f axis=%d',
                  [N.Id,lAngle,Ord(A)]));
              if Assigned(fOnNodeTransformChanged) then
                fOnNodeTransformChanged(Self,N.Id);
            end;
          end
          else if not fOverlayRotateObject then
          begin
            C := OrbitCamera;
            RotateCameraConstrained(C,lCameraDelta,0.5,
                                    RotationConstraintForHandle(fCameraOverlay.SelectedHandle));
            fCamera.Forward := C.Forward;
            fCamera.Right := C.Right;
            fCamera.Up := C.Up;
            fCamera.PoseValid := C.PoseValid;
            MarkDirty;
            if Assigned(fOnInteractionTrace) then
              Trace(Format('camera overlay yaw=%.3f pitch=%.3f roll=%.3f',
                [fCamera.YawDegrees,fCamera.PitchDegrees,fCamera.RollDegrees]));
            if Assigned(fOnViewChanged) then
              fOnViewChanged(Self);
          end;
        end;
      Exit;
    end;
  if (fDispatcher.ActiveContext=ictObjectManipulate) and
     (fGizmo.State=gsDragging) then
    begin
      N := SelectedNode;
      if (N<>nil) and fGizmoRotate then
        begin
          lAngle := ((X-fGizmoLastPoint.X)-(Y-fGizmoLastPoint.Y))*0.5;
          if RotateNodeLocalAxis(fScene,N.Id,
             T3dLocalRotationAxis(Ord(fGizmo.SelectedAxis)-1),lAngle) then
            begin


{ Rotation around the selected local axis leaves that axis invariant.
          Rebuild the complete gizmo basis on MouseUp without interrupting drag. }
              fGizmoLastPoint := Point3d(X,Y);
              MarkDirty;
              if Assigned(fOnInteractionTrace) then
                Trace(Format('object rotate node=%d angle=%.3f axis=%d',
                  [N.Id,lAngle,Ord(fGizmo.SelectedAxis)]));
              if Assigned(fOnNodeTransformChanged) then
                fOnNodeTransformChanged(Self,N.Id);
            end;
        end
      else if (N<>nil) and fGizmo.UpdateDrag(MouseRay(X,Y),D) then
             begin
               TranslateNodeWorld(N,Add(fGizmoStart,D));
               MarkDirty;
               if Assigned(fOnInteractionTrace) then
                 Trace(Format('object translate node=%d x=%.6f y=%.6f z=%.6f',
                   [N.Id,N.WorldTransform[12],N.WorldTransform[13],
                   N.WorldTransform[14]]));
               if Assigned(fOnNodeTransformChanged) then
                 fOnNodeTransformChanged(Self,N.Id);
             end;
      Exit;
    end;
  if fInputMode=imRotate then
    begin
      H := fCameraOverlay.HitTest(Point3d(X,Y));
      if H=crhNone then
        Cursor := crDefault
      else Cursor := crHandPoint;
      MarkDirty;
    end
  else if (fInputMode=imSelect) and (SelectedNode<>nil) then
         begin
           A := ScreenGizmoHit(X,Y);
           fOptions.HotAxis := Ord(A);
           if A=gaNone then
             Cursor := crDefault
           else Cursor := crSizeAll;
           MarkDirty;
         end
  else if fInputMode=imPan then
         begin
           if Cursor<>crHandPoint then
             Cursor := crHandPoint;
         end
  else if Cursor<>crDefault then
         begin
           Cursor := crDefault;
           fOptions.HotAxis := 0;
           MarkDirty;
         end;
  if fDispatcher.ActiveContext in [ictObjectSelect,ictCameraPan,
     ictCameraRotate,ictCameraZoom] then
    begin
      fInput.PointerMove(Point3d(X,Y),Modifiers(Shift),R);
      ApplyInput(R);
    end;
end;

procedure T3dLclWidget.MouseUp(Button: TMouseButton; Shift: TShiftState;
                               X, Y: Integer);

var R: T3dInputResult;
  B: T3dPointerButton;
  lNodeId: QWord;
  lHit: T3dHit;
  lLogicalVertex: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if not fInteractionEnabled then
    Exit;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('mouse-up button=%d x=%d y=%d context=%d',
      [Ord(Button), X, Y, Ord(fDispatcher.ActiveContext)]));
  if (fDispatcher.ActiveContext=ictOverlayPick) and
     (fCameraOverlay.State in [crosPressed,crosDragging]) then
    begin
      fCameraOverlay.EndDrag;
      MouseCapture := False;
      fDispatcher.Release(fCaptureToken);
      Trace('release overlay-drag');
      fCaptureToken := 0;
      if fOverlayRotateObject then
      begin
        CommitSceneTransforms(fScene);
        SelectNode(fSelectedNodeId);
      end;
      fOverlayRotateObject := False;
      fOverlayRotateNodeId := 0;
      MarkDirty;
      Exit;
    end;
  if (fDispatcher.ActiveContext=ictObjectManipulate) and
     (fGizmo.State=gsDragging) then
    begin
      fGizmo.EndDrag;
      MouseCapture := False;
      fDispatcher.Release(fCaptureToken);
      Trace('release object-manipulate');
      fCaptureToken := 0;
      CommitSceneTransforms(fScene);
      SelectNode(fSelectedNodeId);
      MarkDirty;
      Exit;
    end;
  case Button of
    mbLeft: B := pbLeft;
    mbMiddle: B := pbMiddle;
    mbRight: B := pbRight;
    else B := pbNone;
  end;
  fInput.PointerUp(B,Point3d(X,Y),Modifiers(Shift),R);
  if R.ReleasePointer then
    MouseCapture := False;
  if (R.Command=icSelect) and
     (fDispatcher.ActiveContext=ictObjectSelect) then
    begin
      if PickScene(MouseRay(X,Y),lHit) then
        lNodeId := lHit.NodeId
      else
        lNodeId := 0;
      lNodeId := NodeIdAfterPick(fSelectedNodeId, lNodeId,
        Assigned(fOnVertexPicked) and (fSelectedNodeId <> 0));
      if Assigned(fOnInteractionTrace) then
        Trace(Format('selection result node=%d', [lNodeId]));
      SelectNode(lNodeId);
      if lNodeId<>0 then
      begin
        { A ray can miss the surface beside a vertex. In vertex mode a miss
          keeps the selected object, so test that object's projected vertices. }
        lLogicalVertex:=LogicalVertexFromNode(lNodeId,X,Y);
        if (lLogicalVertex>=0) and Assigned(fOnVertexPicked) then
          fOnVertexPicked(Self,lNodeId,lLogicalVertex);
      end;
    end
  else ApplyInput(R);
  fDispatcher.Release(fCaptureToken);
  Trace('release pointer context');
  fCaptureToken := 0;
end;

function T3dLclWidget.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
                                   MousePos: TPoint): Boolean;

var R: T3dInputResult;
begin
  if not fInteractionEnabled then
    begin
      Result := inherited DoMouseWheel(Shift,WheelDelta,MousePos);
      Exit;
    end;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('mouse-wheel delta=%d x=%d y=%d',
      [WheelDelta, MousePos.X, MousePos.Y]));
  fInput.Wheel(WheelDelta/120,Point3d(MousePos.X,MousePos.Y),R);
  ApplyInput(R);
  Result := True;
end;

procedure T3dLclWidget.SetInteractionEnabled(AValue:Boolean);
begin
  if fInteractionEnabled=AValue then
    Exit;
  fInteractionEnabled := AValue;
  if not fInteractionEnabled then
    CancelInteraction;
  UpdateInteractionCursor;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('interaction-enabled=%s',
      [BoolToStr(fInteractionEnabled, True)]));
end;

procedure T3dLclWidget.UpdateInteractionCursor;
begin
  if fInteractionEnabled and (fInputMode=imPan) then
    Cursor := crHandPoint
  else
    Cursor := crDefault;
end;

procedure T3dLclWidget.CancelInteraction;

var R: T3dInputResult;
begin
  if fOverlayRotateObject and (fScene<>nil) then
    CommitSceneTransforms(fScene);
  fOverlayRotateObject := False;
  fOverlayRotateNodeId := 0;
  if fGizmo<>nil then
    fGizmo.CancelDrag;
  if fCameraOverlay<>nil then
    fCameraOverlay.Hide;
  if fInput<>nil then
    fInput.Cancel(R);
  if fDispatcher<>nil then
    fDispatcher.Cancel;
  fCaptureToken := 0;
  if MouseCapture then
    MouseCapture := False;
end;

procedure T3dLclWidget.DoExit;
begin
  CancelInteraction;
  inherited DoExit;
end;

function T3dLclWidget.Modifiers(AShift:TShiftState): T3dModifiers;
begin
  Result := [];
  if ssCtrl in AShift then
    Include(Result,mdCtrl);
  if ssShift in AShift then
    Include(Result,mdShift);
  if ssAlt in AShift then
    Include(Result,mdAlt);
end;

procedure T3dLclWidget.ApplyInput(const AResult:T3dInputResult);

var C: T3dOrbitCamera;
  V: T3dViewport;
begin
  if AResult.Command=icNone then
    Exit;
  C.Target := fCamera.Target;
  C.Forward := fCamera.Forward;
  C.Right := fCamera.Right;
  C.Up := fCamera.Up;
  C.PoseValid := fCamera.PoseValid;
  C.YawDegrees := fCamera.YawDegrees;
  C.PitchDegrees := fCamera.PitchDegrees;
  C.RollDegrees := fCamera.RollDegrees;
  C.Distance := fCamera.Distance;
  C.VerticalFovDegrees := EffectiveVerticalFov(fCamera);
  V.Width := ClientWidth;
  V.Height := ClientHeight;
  case AResult.Command of
    icRotate:
      begin
        if fCamera.ProjectionKind = pkOrthographic then
          Exit;
        RotateCameraConstrained(C,AResult.Delta,0.5,fCameraRotationConstraint);
      end;
    icPan: PanCamera(C,AResult.Delta,V);
    icZoom: ZoomCamera(C,AResult.Delta.Y);
    else Exit;
  end;
  fCamera.Target := C.Target;
  fCamera.Forward := C.Forward;
  fCamera.Right := C.Right;
  fCamera.Up := C.Up;
  fCamera.PoseValid := C.PoseValid;
  fCamera.YawDegrees := C.YawDegrees;
  fCamera.PitchDegrees := C.PitchDegrees;
  fCamera.RollDegrees := C.RollDegrees;
  fCamera.Distance := C.Distance;
  if fCamera.ProjectionKind = pkOrthographic then
    fCamera.OrthographicScale := Max(0.1, fCamera.Distance * 0.5);
  if Assigned(fOnInteractionTrace) then
    Trace(Format(
      'camera command=%d target=(%.4f,%.4f,%.4f) yaw=%.3f pitch=%.3f roll=%.3f distance=%.4f',
      [Ord(AResult.Command),fCamera.Target.X,fCamera.Target.Y,fCamera.Target.Z,
      fCamera.YawDegrees,fCamera.PitchDegrees,fCamera.RollDegrees,
      fCamera.Distance]));
  MarkDirty;
  if Assigned(fOnViewChanged) then
    fOnViewChanged(Self);
end;

procedure T3dLclWidget.LoadScene(const AFileName:string);

var S: T3dScene;
begin
  if fSceneLoader=nil then
    raise Exception.Create('3D scene loader is not assigned');
  CancelInteraction;
  S := fSceneLoader.LoadScene(AFileName);
  ReplaceScene(S);
  FitScene;
end;

procedure T3dLclWidget.ReplaceScene(AScene:T3dScene);
begin
  if AScene = fScene then
    Exit;
  CancelInteraction;
  fScene.Free;
  fScene := AScene;
  fSelectedNodeId := 0;
  fOptions.VertexHighlight.NodeId := 0;
  SetLength(fOptions.VertexHighlight.PrimaryCornerIndices,0);
  SetLength(fOptions.VertexHighlight.AdjacentCornerIndices,0);
  MarkDirty;
end;

procedure T3dLclWidget.SetRenderer(const ARenderer:I3dRenderer);
begin
  fRenderer := ARenderer;
  MarkDirty;
end;

procedure T3dLclWidget.SetSceneLoader(const ALoader:I3dSceneLoader);
begin
  fSceneLoader := ALoader;
end;

procedure T3dLclWidget.SetScenePicker(const APicker:I3dScenePicker);
begin
  fScenePicker := APicker;
end;

procedure T3dLclWidget.ResetToDefaultScene;
begin
  ReplaceScene(CreateDefaultCubeScene);
end;

procedure T3dLclWidget.FitScene;

var
  C: T3dOrbitCamera;
  V: T3dViewport;
  B: T3dBounds;
  N: T3dNode;
begin
  if fScene=nil then
    begin
      Trace('fit skipped scene=nil');
      Exit;
    end;
  B := fScene.Bounds;
  if not B.Valid then
    begin
      Trace('fit skipped bounds=invalid');
      Exit;
    end;
  N := SelectedNode;
  if N<>nil then
    B := WorldBounds(N)
  else B := fScene.Bounds;
  if not B.Valid then
    B := fScene.Bounds;
  C.Target := fCamera.Target;
  C.YawDegrees := fCamera.YawDegrees;
  C.PitchDegrees := fCamera.PitchDegrees;
  C.RollDegrees := fCamera.RollDegrees;
  C.Distance := fCamera.Distance;
  C.VerticalFovDegrees := EffectiveVerticalFov(fCamera);
  V.Width := ClientWidth;
  V.Height := ClientHeight;
  if Assigned(fOnInteractionTrace) then
    Trace(Format(
      'fit begin selected=%d target=(%.4f,%.4f,%.4f) distance=%.4f',
      [fSelectedNodeId, fCamera.Target.X, fCamera.Target.Y, fCamera.Target.Z,
       fCamera.Distance]));
  FitCameraToBox(C,B.Min,B.Max,V);
  fCamera.Target := C.Target;
  fCamera.Distance := C.Distance;
  if fCamera.ProjectionKind=pkOrthographic then
    fCamera.OrthographicScale:=Max(0.1,C.Distance*0.5);
  if Assigned(fOnInteractionTrace) then
    Trace(Format(
      'fit end target=(%.4f,%.4f,%.4f) distance=%.4f viewport=%dx%d',
      [fCamera.Target.X, fCamera.Target.Y, fCamera.Target.Z, fCamera.Distance,
       V.Width, V.Height]));
  MarkDirty;
  if Assigned(fOnViewChanged) then
    fOnViewChanged(Self);
end;

procedure T3dLclWidget.SetInputMode(AMode:T3dInputMode);
begin
  CancelInteraction;
  if (AMode=imRotate) and
     (fCamera.ProjectionKind=pkOrthographic) then
    AMode:=imPan;
  fInputMode := AMode;
  fInput.Mode := AMode;
  UpdateInteractionCursor;
  if AMode=imRotate then
    fCameraOverlay.Show(Point3d(ClientWidth*0.5,ClientHeight*0.5),
    Max(36,Min(ClientWidth,ClientHeight)*0.22));
  MarkDirty;
end;

procedure T3dLclWidget.PrepareCameraRotationPivot;

var N: T3dNode;
  B: T3dBounds;
  NewTarget,Position,Forward,Right,Up: T3dVector;
  NewDistance: Single;
begin
  NewTarget := fCamera.Target;
  N := SelectedNode;
  if N<>nil then
    NewTarget := NodeWorldPivot(N)
  else if (fScene<>nil) and fScene.Bounds.Valid then
    begin
      B := fScene.Bounds;
      NewTarget := Vector3d((B.Min.X+B.Max.X)*0.5,
                   (B.Min.Y+B.Max.Y)*0.5,(B.Min.Z+B.Max.Z)*0.5);
    end;
  Position := CameraPosition(fCamera);
  BuildCameraBasis(fCamera,Forward,Right,Up);
  Forward := VectorSubtract(NewTarget,Position);
  NewDistance := Sqrt(VectorDot(Forward,Forward));
  if NewDistance<=1.0e-6 then
    Exit;
  Forward := VectorScale(Forward,1/NewDistance);
  if not TryNormalize(VectorCross(Forward,Up),Right) then
    if not TryNormalize(VectorCross(Forward,Vector3d(0,1,0)),Right) then
      TryNormalize(VectorCross(Forward,Vector3d(0,0,1)),Right);
  TryNormalize(VectorCross(Right,Forward),Up);
  fCamera.Target := NewTarget;
  fCamera.Distance := NewDistance;
  fCamera.Forward := Forward;
  fCamera.Right := Right;
  fCamera.Up := Up;
  fCamera.PoseValid := True;
end;

function T3dLclWidget.OrbitCamera: T3dOrbitCamera;
begin
  Result.Target := fCamera.Target;
  Result.Forward := fCamera.Forward;
  Result.Right := fCamera.Right;
  Result.Up := fCamera.Up;
  Result.PoseValid := fCamera.PoseValid;
  Result.YawDegrees := fCamera.YawDegrees;
  Result.PitchDegrees := fCamera.PitchDegrees;
  Result.RollDegrees := fCamera.RollDegrees;
  Result.Distance := fCamera.Distance;
  Result.VerticalFovDegrees := EffectiveVerticalFov(fCamera);
  Result.ProjectionKind := fCamera.ProjectionKind;
  Result.OrthographicScale := fCamera.OrthographicScale;
end;

function T3dLclWidget.MouseRay(X,Y:Integer): T3dRay;

var V: T3dViewport;
begin
  V.Width := ClientWidth;
  V.Height := ClientHeight;
  Result := CameraRay(OrbitCamera,V,Point3d(X,Y));
end;

function T3dLclWidget.ScreenGizmoHit(X,Y:Integer): T3dGizmoAxis;

var V: T3dViewport;
begin
  V.Width := ClientWidth;
  V.Height := ClientHeight;
  Result := fGizmo.HitTestScreen(OrbitCamera,V,Point3d(X,Y));
end;

function T3dLclWidget.SelectedNode: T3dNode;
begin
  Result := FindNode(fSelectedNodeId);
end;

function T3dLclWidget.FindNode(AId:QWord): T3dNode;
begin
  Result := FindSceneNode(fScene,AId);
end;

function T3dLclWidget.PickScene(const ARay:T3dRay;
  out AHit:T3dHit):Boolean;
begin
  FillChar(AHit,SizeOf(AHit),0);
  Result:=(fScenePicker<>nil) and fScenePicker.Pick(fScene,ARay,AHit);
end;

function T3dLclWidget.LogicalVertexFromNode(ANodeId:QWord;
  X,Y:Integer):Integer;
var
  Node,SourceNode:T3dNode;
  Mesh:T3dMeshData;
  Corner:LongWord;
  LogicalIndex:Integer;
  WorldVertex:T3dVector;
  ScreenVertex:T3dPoint;
  Viewport:T3dViewport;
  Depth,DistanceSquared,BestDistanceSquared:Single;
begin
  Result:=-1;
  Node:=FindNode(ANodeId);
  if Node=nil then
    Exit;
  Mesh:=Node.Mesh;
  if (Mesh<>nil) and (Length(Mesh.Positions)=0) and
    (Mesh.SourceNodeId<>0) then
  begin
    SourceNode:=FindNode(Mesh.SourceNodeId);
    if SourceNode<>nil then
      Mesh:=SourceNode.Mesh;
  end;
  if Mesh=nil then
    Exit;
  Viewport.Width:=ClientWidth;
  Viewport.Height:=ClientHeight;
  { Keep vertex picking slightly wider than the drawn marker. }
  BestDistanceSquared:=Sqr(7.0)+Sqr(7.0);
  for LogicalIndex:=0 to Max(High(Mesh.LogicalVertices),High(Mesh.Positions)) do
  begin
    if Length(Mesh.LogicalVertices)>0 then
    begin
      if LogicalIndex>High(Mesh.LogicalVertices) then
        Break;
      if Length(Mesh.LogicalVertices[LogicalIndex].CornerIndices)=0 then
        Continue;
      Corner:=Mesh.LogicalVertices[LogicalIndex].CornerIndices[0];
    end
    else
      Corner:=LogicalIndex;
    if Corner>=LongWord(Length(Mesh.Positions)) then
      Continue;
    WorldVertex:=u3dGeometryMath.TransformPoint(Mesh.Positions[Corner],
      Node.WorldTransform);
    if not ProjectWorldToScreen(WorldVertex,OrbitCamera,Viewport,
      ScreenVertex,Depth) then
      Continue;
    if (Abs(ScreenVertex.X-X)>7) or (Abs(ScreenVertex.Y-Y)>7) then
      Continue;
    DistanceSquared:=Sqr(ScreenVertex.X-X)+Sqr(ScreenVertex.Y-Y);
    if DistanceSquared<=BestDistanceSquared then
    begin
      BestDistanceSquared:=DistanceSquared;
      Result:=LogicalIndex;
    end;
  end;
end;

procedure T3dLclWidget.TranslateNodeWorld(ANode:T3dNode; const ANewPosition:T3dVector);
begin
  if ANode<>nil then
    SetNodeWorldPosition(fScene,ANode.Id,ANewPosition);
end;

procedure T3dLclWidget.SetNodeTranslationComponent(AId:QWord; AAxis:Integer; AValue:Single);

var P: T3dVector;
  M: T3dPositionComponents;
begin
  P := Vector3d(AValue,AValue,AValue);
  case AAxis of
    0: M := [pcX];
    1: M := [pcY];
    2: M := [pcZ];
    else Exit;
  end;
  SetNodeTranslation(AId,P,M);
end;

procedure T3dLclWidget.SetNodeTranslation(AId:QWord; const AValue:T3dVector;
                                          AMask:T3dPositionComponents);
begin
  if SetNodeWorldPositionComponents(fScene,AId,AValue,AMask) then
    begin
      if Assigned(fOnNodeTransformChanged) then
        fOnNodeTransformChanged(Self,AId);
      if Assigned(fOnInteractionTrace) then
        Trace(Format('transform node=%d mask=%d value=(%.6f,%.6f,%.6f)',
          [AId,Ord(pcX in AMask)+2*Ord(pcY in AMask)+4*Ord(pcZ in AMask),
          AValue.X,AValue.Y,AValue.Z]));
      MarkDirty;
    end;
end;

procedure T3dLclWidget.SelectNode(AId:QWord);

var N: T3dNode;
  AB: T3dAxisBasis;
  lChanged: Boolean;
begin
  lChanged := fSelectedNodeId<>AId;
  fSelectedNodeId := AId;
  N := SelectedNode;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('select-node requested=%d found=%s changed=%s',
      [AId, BoolToStr(N <> nil, True), BoolToStr(lChanged, True)]));
  if N=nil then
    fGizmo.Hide
  else
    begin
      if lChanged then
        fGizmo.SelectAxis(gaNone);
      AB.XAxis := Vector3d(N.WorldTransform[0],N.WorldTransform[1],N.WorldTransform[2]);
      AB.YAxis := Vector3d(N.WorldTransform[4],N.WorldTransform[5],N.WorldTransform[6]);
      AB.ZAxis := Vector3d(N.WorldTransform[8],N.WorldTransform[9],N.WorldTransform[10]);
      TryNormalize(AB.XAxis,AB.XAxis);
      TryNormalize(AB.YAxis,AB.YAxis);
      TryNormalize(AB.ZAxis,AB.ZAxis);
      fGizmo.Show(Vector3d(N.WorldTransform[12],N.WorldTransform[13],N.WorldTransform[14]),AB,1.5);
    end;
  if Assigned(fOnSelectionChanged) then
    fOnSelectionChanged(Self);
  MarkDirty;
end;

procedure T3dLclWidget.SelectObjectAxis(AAxis:T3dGizmoAxis);
begin
  if SelectedNode=nil then
    AAxis := gaNone;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('select-object-axis axis=%d', [Ord(AAxis)]));
  fGizmo.SelectAxis(AAxis);
  fOptions.SelectedAxis := Ord(AAxis);
  MarkDirty;
end;

function T3dLclWidget.GetSelectedObjectAxis: T3dGizmoAxis;
begin
  Result := fGizmo.SelectedAxis;
end;

procedure T3dLclWidget.SetCameraRotationConstraint(
                                                   AConstraint:T3dCameraRotationConstraint);
begin
  fCameraRotationConstraint := AConstraint;
  if Assigned(fOnInteractionTrace) then
    Trace(Format('camera-constraint value=%d', [Ord(AConstraint)]));
  if fInputMode=imRotate then
    case AConstraint of
      crcX: fCameraOverlay.SelectHandle(crhX);
      crcY: fCameraOverlay.SelectHandle(crhY);
      crcZ: fCameraOverlay.SelectHandle(crhZ);
      else fCameraOverlay.SelectHandle(crhNone);
    end;
  MarkDirty;
end;

function T3dLclWidget.GetCameraRoll: Single;
begin
  Result := fCamera.RollDegrees;
end;

procedure T3dLclWidget.SetCameraRoll(AValue:Single);
begin
  if SameValue(fCamera.RollDegrees,AValue) then
    Exit;
  fCamera.RollDegrees := AValue;
  fCamera.PoseValid := False;
  MarkDirty;
  if Assigned(fOnViewChanged) then
    fOnViewChanged(Self);
end;

procedure T3dLclWidget.SetRenderOptions(const AOptions:T3dRenderOptions);
begin
  fOptions := AOptions;
  MarkDirty;
end;

procedure T3dLclWidget.SetVertexHighlight(ANodeId:QWord;
  const APrimaryCorners,AAdjacentCorners:array of LongWord);
var
  I:Integer;
begin
  fOptions.VertexHighlight.NodeId := ANodeId;
  SetLength(fOptions.VertexHighlight.PrimaryCornerIndices,
    Length(APrimaryCorners));
  for I:=0 to High(APrimaryCorners) do
    fOptions.VertexHighlight.PrimaryCornerIndices[I] := APrimaryCorners[I];
  SetLength(fOptions.VertexHighlight.AdjacentCornerIndices,
    Length(AAdjacentCorners));
  for I:=0 to High(AAdjacentCorners) do
    fOptions.VertexHighlight.AdjacentCornerIndices[I] := AAdjacentCorners[I];
  MarkDirty;
end;

procedure T3dLclWidget.ClearVertexHighlight;
begin
  fOptions.VertexHighlight.NodeId := 0;
  SetLength(fOptions.VertexHighlight.PrimaryCornerIndices,0);
  SetLength(fOptions.VertexHighlight.AdjacentCornerIndices,0);
  MarkDirty;
end;

procedure T3dLclWidget.SetRuntimeNormalLength(AValue:Single);
begin
  if SameValue(fOptions.NormalLength,AValue) then
    Exit;
  fOptions.NormalLength := AValue;
  MarkDirty;
end;

function T3dLclWidget.ActivateContext: Boolean;
begin
  Result := False;
  if (csDestroying in ComponentState) or (Parent = nil) or
     (not Parent.HandleAllocated) or (not HandleAllocated) then
    Exit;
  MakeCurrent;
  Result := True;
end;

procedure T3dLclWidget.PresentFrame;
begin
  if (csDestroying in ComponentState) or (Parent = nil) or
     (not Parent.HandleAllocated) or (not HandleAllocated) then
    Exit;
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
