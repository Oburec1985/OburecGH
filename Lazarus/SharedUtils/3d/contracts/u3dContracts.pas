unit u3dContracts;

{ Defines renderer and host boundaries used by the LCL widget and backend
  implementations. Interfaces do not own scenes passed to Render. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes, u3dScene;

type
  T3dRenderPass = (rpMeshFill, rpWireframe, rpPoints, rpNormals,
    rpWorldAxes, rpSelectionBounds, rpSelectionAxes, rpVertexHighlight,
    rpShape, rpCameraOverlay, rpSelectedHelperOverlay);

  T3dCornerIndexArray = array of LongWord;

  { Resolved mesh corners are cached by the editor/controller. The renderer
    reads these arrays for one frame and never owns or changes them. }
  T3dVertexHighlight = record
    NodeId: QWord;
    PrimaryCornerIndices: T3dCornerIndexArray;
    AdjacentCornerIndices: T3dCornerIndexArray;
  end;

  T3dRenderOptions = record
    ShowAxes: Boolean;
    DrawFill: Boolean;
    DrawWireframe: Boolean;
    DrawPoints: Boolean;
    DrawNormals: Boolean;
    NormalLength: Single;
    BackgroundColor: LongWord;
    PointColor:T3dColor;
    { The compatibility renderer supplies one neutral key light when a scene
      has no lighting adapter of its own. Future scene-light adapters disable
      this flag and configure the OpenGL lights before drawing geometry. }
    UseDefaultLighting: Boolean;
    DefaultAmbient: Single;
    DefaultDiffuse: Single;
    DefaultLightDirection: T3dVector;
    SelectedNodeId: QWord;
    { Optional selected editor helper redrawn after scene geometry. }
    OverlayNodeId: QWord;
    HotAxis: Integer;
    SelectedAxis: Integer;
    CameraOverlayVisible: Boolean;
    CameraOverlayHover: Integer;
    CameraOverlaySelected: Integer;
    SceneClipRadius: Single;
    VertexHighlight: T3dVertexHighlight;
  end;

  I3dRenderHost = interface
    ['{8F18CDB8-F492-4E09-91D7-C9FF56A4D943}']
    function ActivateContext: Boolean;
    procedure PresentFrame;
    function RenderWidth: Integer;
    function RenderHeight: Integer;
  end;

  I3dAnimationSnapshot = interface
    ['{24D4DA37-F185-454F-970D-44B96D6C50D8}']
    function Version: QWord;
  end;

  I3dRenderer = interface
    ['{D4FE561C-F3E2-4748-9433-0E4E43E99094}']
    procedure Render(AScene: T3dScene; const ACamera: T3dCamera;
      const AOptions: T3dRenderOptions);
  end;

{ Fixed-function lighting is intentionally restricted to solid surfaces.
  Editor overlays use exact UI colors and therefore always run unlit. }
function RenderPassUsesLighting(APass: T3dRenderPass): Boolean;
function RenderPassUsesDepthTest(APass: T3dRenderPass): Boolean;

implementation

function RenderPassUsesLighting(APass: T3dRenderPass): Boolean;
begin
  Result := APass = rpMeshFill;
end;

function RenderPassUsesDepthTest(APass: T3dRenderPass): Boolean;
begin
  { Editor points describe topology, including vertices behind filled faces.
    They are overlays rather than surface fragments and must all stay visible. }
  Result := not (APass in [rpPoints, rpVertexHighlight,
    rpSelectedHelperOverlay]);
end;

end.
