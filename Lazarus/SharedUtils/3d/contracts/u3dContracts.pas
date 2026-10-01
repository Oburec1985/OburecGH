unit u3dContracts;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes, u3dScene;

type
  T3dRenderOptions = record
    ShowAxes: Boolean;
    DrawFill: Boolean;
    DrawWireframe: Boolean;
    DrawPoints: Boolean;
    DrawNormals: Boolean;
    NormalLength: Single;
    BackgroundColor: LongWord;
    SelectedNodeId: QWord;
    HotAxis: Integer;
    SelectedAxis: Integer;
    CameraOverlayVisible:Boolean;
    CameraOverlayHover:Integer;
    CameraOverlaySelected:Integer;
    SceneClipRadius:Single;
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

implementation

end.
