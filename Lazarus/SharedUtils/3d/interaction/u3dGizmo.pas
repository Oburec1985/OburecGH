unit u3dGizmo;

{ Tracks local-axis gizmo hover, selection, and constrained drag state for one
  selected node. Scene mutation remains the widget's responsibility. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes, u3dInteractionTypes;

type
  T3dGizmoAxis = (gaNone, gaX, gaY, gaZ);
  T3dGizmoState = (gsHidden, gsIdle, gsHover, gsDragging);

  T3dGizmo = class
  private
      fState: T3dGizmoState;
      fHoverAxis: T3dGizmoAxis;
      fSelectedAxis: T3dGizmoAxis;
      fDragAxis: T3dGizmoAxis;
      fOrigin: T3dVector;
      fBasis: T3dAxisBasis;
      fAxisLength: Single;
      fHitTolerance: Single;
      fScreenHitTolerance: Single;
      fStartParameter: Single;
      function AxisVector(AAxis: T3dGizmoAxis): T3dVector;
      function RayAxisParameter(const ARay: T3dRay; const AAxis: T3dVector;
                                out AParameter, ADistance: Single): Boolean;
  public
      constructor Create;
      procedure Show(const AOrigin: T3dVector; const ABasis: T3dAxisBasis;
                     AAxisLength: Single);
      procedure Hide;
      procedure SelectAxis(AAxis:T3dGizmoAxis);
      function HitTest(const ARay: T3dRay): T3dGizmoAxis;
      function HitTestScreen(const ACamera:T3dOrbitCamera;
                             const AViewport:T3dViewport; const APoint:T3dPoint): T3dGizmoAxis;
      function BeginDrag(AAxis: T3dGizmoAxis; const ARay: T3dRay): Boolean;
      function UpdateDrag(const ARay: T3dRay; out ATranslation: T3dVector): Boolean;
      procedure EndDrag;
      procedure CancelDrag;
      property State: T3dGizmoState read fState;
      property ActiveAxis: T3dGizmoAxis read fDragAxis;
      property HoverAxis: T3dGizmoAxis read fHoverAxis;
      property SelectedAxis: T3dGizmoAxis read fSelectedAxis;
      property HitTolerance: Single read fHitTolerance write fHitTolerance;
      property ScreenHitTolerance: Single read fScreenHitTolerance
                                   write fScreenHitTolerance;
  end;

implementation

uses
  Math, u3dInteractionMath, u3dScreenGeometryMath;

constructor T3dGizmo.Create;
begin
  inherited Create;
  fState := gsHidden;
  fAxisLength := 1;
  fHitTolerance := 0.08;
  fScreenHitTolerance := 10;
end;

function T3dGizmo.HitTestScreen(const ACamera:T3dOrbitCamera;
                                const AViewport:T3dViewport; const APoint:T3dPoint): T3dGizmoAxis;

var lAxisIndex: Integer;
begin
  Result := gaNone;
  if fState=gsHidden then
    Exit;
  if ScreenAxisHitTest(fOrigin,fBasis,fAxisLength,ACamera,AViewport,APoint,
     fScreenHitTolerance,lAxisIndex) then
    Result := T3dGizmoAxis(lAxisIndex+1);
  fHoverAxis := Result;
  if Result=gaNone then
    fState := gsIdle
  else fState := gsHover;
end;

procedure T3dGizmo.Show(const AOrigin: T3dVector; const ABasis: T3dAxisBasis;
                        AAxisLength: Single);
begin
  fOrigin := AOrigin;
  fBasis.XAxis := Normalize(ABasis.XAxis);
  fBasis.YAxis := Normalize(ABasis.YAxis);
  fBasis.ZAxis := Normalize(ABasis.ZAxis);
  fAxisLength := Max(AAxisLength, C3dEpsilon);
  fHoverAxis := gaNone;
  fDragAxis := gaNone;
  fState := gsIdle;
end;

procedure T3dGizmo.Hide;
begin
  fHoverAxis := gaNone;
  fSelectedAxis := gaNone;
  fDragAxis := gaNone;
  fState := gsHidden;
end;

procedure T3dGizmo.SelectAxis(AAxis:T3dGizmoAxis);
begin
  if fState=gsHidden then
    Exit;
  fSelectedAxis := AAxis;
end;

function T3dGizmo.AxisVector(AAxis: T3dGizmoAxis): T3dVector;
begin
  case AAxis of
    gaX: Result := fBasis.XAxis;
    gaY: Result := fBasis.YAxis;
    gaZ: Result := fBasis.ZAxis;
    else
      Result := Vector3d(0, 0, 0);
  end;
end;

function T3dGizmo.RayAxisParameter(const ARay: T3dRay;
                                   const AAxis: T3dVector; out AParameter, ADistance: Single):

                                                                                             Boolean
;

var
  lOffset, lClosestRay, lClosestAxis: T3dVector;
  lRayParameter, lB, lD, lE, lDenominator: Single;
begin
  lOffset := Subtract(ARay.Origin, fOrigin);
  lB := Dot(ARay.Direction, AAxis);
  lD := Dot(ARay.Direction, lOffset);
  lE := Dot(AAxis, lOffset);
  lDenominator := 1 - lB * lB;
  if Abs(lDenominator) <= C3dEpsilon then
    Exit(False);
  lRayParameter := (lB * lE - lD) / lDenominator;
  AParameter := (lE - lB * lD) / lDenominator;
  lClosestRay := Add(ARay.Origin, Scale(ARay.Direction, lRayParameter));
  lClosestAxis := Add(fOrigin, Scale(AAxis, AParameter));
  ADistance := Length3d(Subtract(lClosestRay, lClosestAxis));
  Result := lRayParameter >= 0;
end;

function T3dGizmo.HitTest(const ARay: T3dRay): T3dGizmoAxis;

var
  lAxis: T3dGizmoAxis;
  lParameter, lDistance, lBestDistance: Single;
begin
  Result := gaNone;
  if fState = gsHidden then
    Exit;
  lBestDistance := MaxSingle;
  for lAxis := gaX to gaZ do
    if RayAxisParameter(ARay, AxisVector(lAxis), lParameter, lDistance) and
       (lParameter >= 0) and (lParameter <= fAxisLength) and
       (lDistance <= fHitTolerance) and (lDistance < lBestDistance) then
      begin
        Result := lAxis;
        lBestDistance := lDistance;
      end;
  fHoverAxis := Result;
  if Result = gaNone then
    fState := gsIdle
  else fState := gsHover;
end;

function T3dGizmo.BeginDrag(AAxis: T3dGizmoAxis;
                            const ARay: T3dRay): Boolean;

var
  lDistance: Single;
begin
  Result := (fState <> gsHidden) and (AAxis <> gaNone) and
            (AAxis=fSelectedAxis) and
            RayAxisParameter(ARay, AxisVector(AAxis), fStartParameter, lDistance);
  if not Result then
    Exit;
  fDragAxis := AAxis;
  fState := gsDragging;
end;

function T3dGizmo.UpdateDrag(const ARay: T3dRay;
                             out ATranslation: T3dVector): Boolean;

var
  lParameter, lDistance: Single;
begin
  ATranslation := Vector3d(0, 0, 0);
  Result := (fState = gsDragging) and
            RayAxisParameter(ARay, AxisVector(fDragAxis), lParameter, lDistance);
  if Result then
    ATranslation := Scale(AxisVector(fDragAxis), lParameter - fStartParameter);
end;

procedure T3dGizmo.EndDrag;
begin
  if fState <> gsDragging then
    Exit;
  fDragAxis := gaNone;
  fState := gsHover;
end;

procedure T3dGizmo.CancelDrag;
begin
  if fState <> gsDragging then
    Exit;
  fDragAxis := gaNone;
  fState := gsIdle;
end;

end.
