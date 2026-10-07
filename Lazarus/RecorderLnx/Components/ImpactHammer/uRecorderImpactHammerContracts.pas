unit uRecorderImpactHammerContracts;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ UI-neutral command and state boundary between the impact application service
  and any presentation. This unit deliberately has no LCL dependency. }

interface

uses
  SysUtils, uRecorderFrfContracts, u3dMotionContracts;

type
  TRecorderImpactResultType = (irtTime, irtSpectrum, irtFrfMagnitude,
    irtPhase, irtCoherence);

  { Persistent display policy for one result tab. It is UI-toolkit neutral so
    presenters and tests do not depend on LCL or the component model. }
  TImpactResultAxisState = record
    LogX: Boolean;
    LogY: Boolean;
    AutoScale: Boolean;
    XMin: Double;
    XMax: Double;
    YMin: Double;
    YMax: Double;
  end;

  TRecorderImpactCurveQuality = (icqUnknown, icqGood, icqLowCoherence,
    icqRejected);

  TRecorderImpactPresentationCurve = record
    CurveId: QWord;
    Name: string;
    UnitName: string;
    Color: LongInt;
    Visible: Boolean;
    ReadOnly: Boolean;
    Quality: TRecorderImpactCurveQuality;
    X: array of Double;
    Y: array of Double;
  end;

  TRecorderImpactResultCurves = record
    ResultType: TRecorderImpactResultType;
    XUnitName: string;
    Curves: array of TRecorderImpactPresentationCurve;
  end;

  TRecorderImpactCursorReadout = record
    FrequencyHz: Double;
    FrequencyHz2: Double;
    HasSecond: Boolean;
    Values: array of Double;
    Values2: array of Double;
  end;

  TRecorderImpactHammerState = (
    ihsIdle,
    ihsArmed,
    ihsRunning,
    ihsStopping,
    ihsCompleted,
    ihsFault
  );

  TRecorderImpactProcessingSettings = record
    Estimator: Integer;
    WindowKind: Integer;
    WelchEnabled: Boolean;
    WelchSegmentSize: Integer;
    WelchOverlapPercent: Integer;
  end;

  { Runtime window edited directly on the time graph. Values are expressed in
    seconds relative to the beginning of the captured impact. Keeping this DTO
    free of chart types lets other editors reuse the same processing command. }
  TRecorderImpactFilterWindow = record
    Enabled: Boolean;
    StartSeconds: Double;
    EndSeconds: Double;
    ExponentialStartSeconds: Double;
    ExponentialEndSeconds: Double;
    ExponentialEndLevel: Double;
  end;

  TRecorderModelPointBinding = record
    CurveId: QWord;
    PointGroup: string;
    PointNumber: Integer;
    TargetNodeId: QWord;
    Axis: T3dMotionAxis;
    Space: T3dMotionSpace;
    Gain: Double;
    Enabled: Boolean;
  end;

  IRecorderModelPointCatalog = interface
    ['{463A8057-041C-46B1-B1C5-DF2E09709E70}']
    function ResolvePoint(const APointGroup: string; APointNumber: Integer;
      out ATargetNodeId: QWord): Boolean;
  end;

  IRecorderModelPointBindingSink = interface
    ['{7961F2E8-85BF-4E43-BEB0-83538857D3EF}']
    procedure PublishBindings(const ASourceBindingId,
      ATargetComponentId: string;
      const ABindings: array of TRecorderModelPointBinding);
    procedure RemoveBindings(const ASourceBindingId: string);
    procedure ConfigureAnimation(const ASourceBindingId: string;
      AScale, AFrequencyHz: Double);
    procedure PlayAnimation(const ASourceBindingId: string);
    procedure StopAnimation(const ASourceBindingId: string);
  end;

  TRecorderImpactHammerSnapshot = record
    State: TRecorderImpactHammerState;
    StatusText: string;
    ProgressPercent: Integer;
    ImpactIndex: Integer;
    ImpactCount: Integer;
    ImpactHidden: Boolean;
    CanNavigatePrevious: Boolean;
    CanNavigateNext: Boolean;
    CanHide: Boolean;
    CanDelete: Boolean;
    CanStart: Boolean;
    CanArm: Boolean;
    CanStop: Boolean;
    Results: array[TRecorderImpactResultType] of TRecorderImpactResultCurves;
    Cursor: TRecorderImpactCursorReadout;
    FilterWindow: TRecorderImpactFilterWindow;
    CaptureDurationSeconds: Double;
  end;

  IRecorderImpactHammerApplicationService = interface
    ['{A788C011-3BC4-479E-A092-0A06BB1F5B13}']
    procedure NavigateToPreviousImpact;
    procedure NavigateToNextImpact;
    procedure SetCurrentImpactHidden(AHidden: Boolean);
    procedure DeleteCurrentImpact;
    procedure StartMeasurement;
    procedure ArmMeasurement;
    procedure StopMeasurement;
    procedure SavePointBindings;
    procedure PlayModelAnimation;
    procedure StopModelAnimation;
    procedure FillSnapshot(out ASnapshot: TRecorderImpactHammerSnapshot);
    function Provider: IRecorderFrfProvider;
    function Revision: QWord;
    function TryUpdateProcessingSettings(
      const ASettings: TRecorderImpactProcessingSettings;
      out AError: string): Boolean;
    function TrySetFilterWindow(const AWindow: TRecorderImpactFilterWindow;
      out AError: string): Boolean;
    function TrySetTriggerThreshold(AValue: Double;
      out AError: string): Boolean;
  end;

procedure RegisterRecorderModelPointTarget(const AComponentId: string;
  const ACatalog: IRecorderModelPointCatalog;
  const ASink: IRecorderModelPointBindingSink);
procedure UnregisterRecorderModelPointTarget(const AComponentId: string);
function FindRecorderModelPointTarget(const AComponentId: string;
  out ACatalog: IRecorderModelPointCatalog;
  out ASink: IRecorderModelPointBindingSink): Boolean;

implementation

type
  TRecorderModelPointTarget = record
    ComponentId: string;
    Catalog: IRecorderModelPointCatalog;
    Sink: IRecorderModelPointBindingSink;
  end;

var
  GPointTargetLock: TRTLCriticalSection;
  GPointTargets: array of TRecorderModelPointTarget;

procedure RegisterRecorderModelPointTarget(const AComponentId: string;
  const ACatalog: IRecorderModelPointCatalog;
  const ASink: IRecorderModelPointBindingSink);
var
  I: Integer;
begin
  if (AComponentId = '') or (ACatalog = nil) or (ASink = nil) then
    Exit;
  EnterCriticalSection(GPointTargetLock);
  try
    for I := 0 to High(GPointTargets) do
      if GPointTargets[I].ComponentId = AComponentId then
      begin
        GPointTargets[I].Catalog := ACatalog;
        GPointTargets[I].Sink := ASink;
        Exit;
      end;
    I := Length(GPointTargets);
    SetLength(GPointTargets, I + 1);
    GPointTargets[I].ComponentId := AComponentId;
    GPointTargets[I].Catalog := ACatalog;
    GPointTargets[I].Sink := ASink;
  finally
    LeaveCriticalSection(GPointTargetLock);
  end;
end;

procedure UnregisterRecorderModelPointTarget(const AComponentId: string);
var
  I: Integer;
  J: Integer;
begin
  EnterCriticalSection(GPointTargetLock);
  try
    for I := 0 to High(GPointTargets) do
      if GPointTargets[I].ComponentId = AComponentId then
      begin
        for J := I to High(GPointTargets) - 1 do
          GPointTargets[J] := GPointTargets[J + 1];
        SetLength(GPointTargets, Length(GPointTargets) - 1);
        Exit;
      end;
  finally
    LeaveCriticalSection(GPointTargetLock);
  end;
end;

function FindRecorderModelPointTarget(const AComponentId: string;
  out ACatalog: IRecorderModelPointCatalog;
  out ASink: IRecorderModelPointBindingSink): Boolean;
var
  I: Integer;
begin
  ACatalog := nil;
  ASink := nil;
  EnterCriticalSection(GPointTargetLock);
  try
    for I := 0 to High(GPointTargets) do
      if GPointTargets[I].ComponentId = AComponentId then
      begin
        ACatalog := GPointTargets[I].Catalog;
        ASink := GPointTargets[I].Sink;
        Exit(True);
      end;
  finally
    LeaveCriticalSection(GPointTargetLock);
  end;
  Result := False;
end;

initialization
  InitCriticalSection(GPointTargetLock);

finalization
  SetLength(GPointTargets, 0);
  DoneCriticalSection(GPointTargetLock);

end.
