unit uRecorder3dModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderFormModel, uRecorderTags, u3dMotionContracts;

type
  TRecorder3dBindingSlot = (r3bPointX, r3bPointY, r3bPointZ, r3bColor,
    r3bNormalLength);

  TRecorder3dFrfBinding = class
  public
    TargetNodeId: QWord;
    Axis: T3dMotionAxis;
    Space: T3dMotionSpace;
    AmplitudeTagId, PhaseTagId: TRecorderTagId;
    AmplitudeTagName, PhaseTagName: string;
    Gain: Double;
    Enabled: Boolean;
    constructor Create;
    procedure SetAxisOrdinal(AValue:Integer);
    procedure SetSpaceOrdinal(AValue:Integer);
  end;

  TRecorder3dNodeRenderOverride = class
  public
    NodeId: QWord;
    DrawFill, DrawWireframe, DrawPoints, DrawNormals: Boolean;
  end;

  TRecorder3dComponent = class(TRecorderVisualComponent)
  private
    fSceneFileName: string;
    fShowAxes: Boolean;
    fBackgroundColor: LongInt;
    fCameraYaw: Double;
    fCameraPitch: Double;
    fCameraDistance: Double;
    fDrawFill: Boolean;
    fDrawWireframe: Boolean;
    fDrawPoints: Boolean;
    fDrawNormals: Boolean;
    fNormalLength: Double;
    fNormalLengthTagId: TRecorderTagId;
    fNormalLengthTagName: string;
    fBindingTargetNodeId: QWord;
    fBindingTagIds: array[TRecorder3dBindingSlot] of TRecorderTagId;
    fBindingTagNames: array[TRecorder3dBindingSlot] of string;
    fFrfBindings: TList;
    fNodeRenderOverrides: TList;
    fFrfFrequencyHz, fFrfAnimationPhaseRadians: Double;
    fFrfFrequencyTagId, fFrfAnimationPhaseTagId: TRecorderTagId;
    fFrfFrequencyTagName, fFrfAnimationPhaseTagName: string;
    function GetBindingTagId(AIndex:TRecorder3dBindingSlot):TRecorderTagId;
    function GetBindingTagName(AIndex:TRecorder3dBindingSlot):string;
    procedure SetBindingTagId(AIndex:TRecorder3dBindingSlot; AValue:TRecorderTagId);
    procedure SetBindingTagName(AIndex:TRecorder3dBindingSlot; const AValue:string);
    function GetFrfBinding(AIndex:Integer):TRecorder3dFrfBinding;
    function GetFrfBindingCount:Integer;
    function GetNodeRenderOverride(AIndex:Integer):TRecorder3dNodeRenderOverride;
    function GetNodeRenderOverrideCount:Integer;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddFrfBinding:TRecorder3dFrfBinding;
    procedure ClearFrfBindings;
    function AddNodeRenderOverride:TRecorder3dNodeRenderOverride;
    procedure ClearNodeRenderOverrides;
    function FindNodeRenderOverride(ANodeId:QWord):TRecorder3dNodeRenderOverride;
    property SceneFileName: string read fSceneFileName write fSceneFileName;
    property ShowAxes: Boolean read fShowAxes write fShowAxes;
    property BackgroundColor: LongInt read fBackgroundColor write fBackgroundColor;
    property CameraYaw: Double read fCameraYaw write fCameraYaw;
    property CameraPitch: Double read fCameraPitch write fCameraPitch;
    property CameraDistance: Double read fCameraDistance write fCameraDistance;
    property DrawFill: Boolean read fDrawFill write fDrawFill;
    property DrawWireframe: Boolean read fDrawWireframe write fDrawWireframe;
    property DrawPoints: Boolean read fDrawPoints write fDrawPoints;
    property DrawNormals: Boolean read fDrawNormals write fDrawNormals;
    property NormalLength: Double read fNormalLength write fNormalLength;
    property NormalLengthTagId: TRecorderTagId read fNormalLengthTagId
      write fNormalLengthTagId;
    property NormalLengthTagName: string read fNormalLengthTagName
      write fNormalLengthTagName;
    property BindingTargetNodeId: QWord read fBindingTargetNodeId write fBindingTargetNodeId;
    property BindingTagIds[AIndex:TRecorder3dBindingSlot]:TRecorderTagId
      read GetBindingTagId write SetBindingTagId;
    property BindingTagNames[AIndex:TRecorder3dBindingSlot]:string
      read GetBindingTagName write SetBindingTagName;
    property FrfBindingCount:Integer read GetFrfBindingCount;
    property FrfBindings[AIndex:Integer]:TRecorder3dFrfBinding read GetFrfBinding;
    property NodeRenderOverrideCount:Integer read GetNodeRenderOverrideCount;
    property NodeRenderOverrides[AIndex:Integer]:TRecorder3dNodeRenderOverride
      read GetNodeRenderOverride;
    property FrfFrequencyHz:Double read fFrfFrequencyHz write fFrfFrequencyHz;
    property FrfAnimationPhaseRadians:Double read fFrfAnimationPhaseRadians write fFrfAnimationPhaseRadians;
    property FrfFrequencyTagId:TRecorderTagId read fFrfFrequencyTagId write fFrfFrequencyTagId;
    property FrfFrequencyTagName:string read fFrfFrequencyTagName write fFrfFrequencyTagName;
    property FrfAnimationPhaseTagId:TRecorderTagId read fFrfAnimationPhaseTagId write fFrfAnimationPhaseTagId;
    property FrfAnimationPhaseTagName:string read fFrfAnimationPhaseTagName write fFrfAnimationPhaseTagName;
  end;

  TRecorder3dFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create;
  end;

procedure RegisterRecorder3dFactory(AFactory: TRecorderComponentFactory);

implementation

constructor TRecorder3dFrfBinding.Create;
begin
  inherited Create;
  Axis:=maxisX; Space:=msHelperLocal; Gain:=1; Enabled:=True;
end;

procedure TRecorder3dFrfBinding.SetAxisOrdinal(AValue:Integer);
begin if AValue<Ord(Low(T3dMotionAxis)) then AValue:=Ord(Low(T3dMotionAxis));
  if AValue>Ord(High(T3dMotionAxis)) then AValue:=Ord(High(T3dMotionAxis));
  Axis:=T3dMotionAxis(AValue); end;

procedure TRecorder3dFrfBinding.SetSpaceOrdinal(AValue:Integer);
begin if AValue<Ord(Low(T3dMotionSpace)) then AValue:=Ord(Low(T3dMotionSpace));
  if AValue>Ord(High(T3dMotionSpace)) then AValue:=Ord(High(T3dMotionSpace));
  Space:=T3dMotionSpace(AValue); end;

function TRecorder3dComponent.GetBindingTagId(AIndex:TRecorder3dBindingSlot):TRecorderTagId;
begin Result:=fBindingTagIds[AIndex]; end;
function TRecorder3dComponent.GetBindingTagName(AIndex:TRecorder3dBindingSlot):string;
begin Result:=fBindingTagNames[AIndex]; end;
procedure TRecorder3dComponent.SetBindingTagId(AIndex:TRecorder3dBindingSlot; AValue:TRecorderTagId);
begin fBindingTagIds[AIndex]:=AValue; end;
procedure TRecorder3dComponent.SetBindingTagName(AIndex:TRecorder3dBindingSlot; const AValue:string);
begin fBindingTagNames[AIndex]:=AValue; end;

class function TRecorder3dComponent.GetTypeId: string;
begin
  Result := 'ThreeDView';
end;

constructor TRecorder3dComponent.Create;
begin
  inherited Create;
  fFrfBindings:=TList.Create;
  fNodeRenderOverrides:=TList.Create;
  fShowAxes := True;
  fBackgroundColor := $0033291F;
  fCameraYaw := 35;
  fCameraPitch := -25;
  fCameraDistance := 6;
  fDrawFill := True;
  fDrawWireframe := False;
  fDrawPoints := False;
  fDrawNormals := False;
  fNormalLength := 0.25;
  fFrfFrequencyHz:=100;
  fFrfAnimationPhaseRadians:=0;
end;

destructor TRecorder3dComponent.Destroy;
begin
  ClearNodeRenderOverrides; fNodeRenderOverrides.Free;
  ClearFrfBindings; fFrfBindings.Free; inherited Destroy;
end;

function TRecorder3dComponent.AddFrfBinding:TRecorder3dFrfBinding;
begin Result:=TRecorder3dFrfBinding.Create; fFrfBindings.Add(Result); end;

procedure TRecorder3dComponent.ClearFrfBindings;
begin while fFrfBindings.Count>0 do begin TObject(fFrfBindings.Last).Free;
  fFrfBindings.Delete(fFrfBindings.Count-1); end; end;

function TRecorder3dComponent.GetFrfBinding(AIndex:Integer):TRecorder3dFrfBinding;
begin Result:=TRecorder3dFrfBinding(fFrfBindings[AIndex]); end;

function TRecorder3dComponent.GetFrfBindingCount:Integer;
begin Result:=fFrfBindings.Count; end;

function TRecorder3dComponent.AddNodeRenderOverride:TRecorder3dNodeRenderOverride;
begin Result:=TRecorder3dNodeRenderOverride.Create; fNodeRenderOverrides.Add(Result); end;

procedure TRecorder3dComponent.ClearNodeRenderOverrides;
begin while fNodeRenderOverrides.Count>0 do begin TObject(fNodeRenderOverrides.Last).Free;
  fNodeRenderOverrides.Delete(fNodeRenderOverrides.Count-1); end; end;

function TRecorder3dComponent.FindNodeRenderOverride(ANodeId:QWord):TRecorder3dNodeRenderOverride;
var I:Integer;
begin Result:=nil; for I:=0 to fNodeRenderOverrides.Count-1 do
  if TRecorder3dNodeRenderOverride(fNodeRenderOverrides[I]).NodeId=ANodeId then
    Exit(TRecorder3dNodeRenderOverride(fNodeRenderOverrides[I])); end;

function TRecorder3dComponent.GetNodeRenderOverride(AIndex:Integer):TRecorder3dNodeRenderOverride;
begin Result:=TRecorder3dNodeRenderOverride(fNodeRenderOverrides[AIndex]); end;

function TRecorder3dComponent.GetNodeRenderOverrideCount:Integer;
begin Result:=fNodeRenderOverrides.Count; end;

constructor TRecorder3dFactory.Create;
begin
  inherited Create(TRecorder3dComponent.TypeId, '3D-сцена',
    TRecorder3dComponent, 480, 320, False);
  ConfigurePalette('3D', 'Добавить интерактивную 3D-сцену', '3d-view', 31,
    rppGroup, CRecorderPaletteGroupImages);
end;

procedure TRecorder3dFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('ThreeDView%d', [AContext.ComponentNo]);
end;

procedure RegisterRecorder3dFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorder3dComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorder3dFactory.Create);
end;

end.
