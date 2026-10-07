unit u3dInputRouter;

{ Converts pointer gestures into mode-neutral interaction commands. The LCL
  widget owns the router and applies emitted deltas to camera or scene state. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dInteractionTypes;

type
  T3dInputRouter = class
  private
      fMode: T3dInputMode;
      fState: T3dInputState;
      fButton: T3dPointerButton;
      fPressPosition: T3dPoint;
      fLastPosition: T3dPoint;
      fDragThreshold: Single;
      function EffectiveCommand(AModifiers: T3dModifiers): T3dInputCommand;
  public
      constructor Create;
      procedure Cancel(out AResult: T3dInputResult);
      procedure PointerDown(AButton: T3dPointerButton; const APosition: T3dPoint;
                            AModifiers: T3dModifiers; out AResult: T3dInputResult);
      procedure PointerMove(const APosition: T3dPoint; AModifiers: T3dModifiers;
                            out AResult: T3dInputResult);
      procedure PointerUp(AButton: T3dPointerButton; const APosition: T3dPoint;
                          AModifiers: T3dModifiers; out AResult: T3dInputResult);
      procedure Wheel(ASteps: Single; const APosition: T3dPoint;
                      out AResult: T3dInputResult);
      property Mode: T3dInputMode read fMode write fMode;
      property State: T3dInputState read fState;
      property DragThreshold: Single read fDragThreshold write fDragThreshold;
  end;

implementation

uses
  Math;

procedure ClearResult(out AResult: T3dInputResult);
begin
  FillChar(AResult, SizeOf(AResult), 0);
  AResult.Command := icNone;
end;

constructor T3dInputRouter.Create;
begin
  inherited Create;
  fMode := imSelect;
  fState := isIdle;
  fDragThreshold := 3;
end;

function T3dInputRouter.EffectiveCommand(AModifiers: T3dModifiers): T3dInputCommand;
begin
  if mdCtrl in AModifiers then
    Exit(icRotate);
  case fMode of
    imPan: Result := icPan;
    imRotate: Result := icRotate;
    imZoom: Result := icZoom;
    else
      Result := icSelect;
  end;
end;

procedure T3dInputRouter.Cancel(out AResult: T3dInputResult);
begin
  ClearResult(AResult);
  AResult.ReleasePointer := fState <> isIdle;
  fState := isIdle;
  fButton := pbNone;
end;

procedure T3dInputRouter.PointerDown(AButton: T3dPointerButton;
                                     const APosition: T3dPoint; AModifiers: T3dModifiers;
                                     out AResult: T3dInputResult);
begin
  ClearResult(AResult);
  if (fState <> isIdle) or (AButton = pbNone) then
    Exit;
  fButton := AButton;
  fPressPosition := APosition;
  fLastPosition := APosition;
  fState := isPressed;
  AResult.CapturePointer := True;
end;

procedure T3dInputRouter.PointerMove(const APosition: T3dPoint;
                                     AModifiers: T3dModifiers; out AResult: T3dInputResult);

var
  lTravelX, lTravelY: Single;
begin
  ClearResult(AResult);
  if fState = isIdle then
    Exit;
  lTravelX := APosition.X - fPressPosition.X;
  lTravelY := APosition.Y - fPressPosition.Y;
  if (fState = isPressed) and
     (Sqrt(Sqr(lTravelX) + Sqr(lTravelY)) >= fDragThreshold) then
    fState := isDragging;
  if fState = isDragging then
    begin
      AResult.Command := EffectiveCommand(AModifiers);
      AResult.Delta := Point3d(APosition.X - fLastPosition.X,
                       APosition.Y - fLastPosition.Y);
      AResult.Position := APosition;
    end;
  fLastPosition := APosition;
end;

procedure T3dInputRouter.PointerUp(AButton: T3dPointerButton;
                                   const APosition: T3dPoint; AModifiers: T3dModifiers;
                                   out AResult: T3dInputResult);
begin
  ClearResult(AResult);
  if (fState = isIdle) or (AButton <> fButton) then
    Exit;
  AResult.Position := APosition;
  AResult.ReleasePointer := True;
  if fState = isPressed then
    AResult.Command := EffectiveCommand(AModifiers);
  fState := isIdle;
  fButton := pbNone;
end;

procedure T3dInputRouter.Wheel(ASteps: Single; const APosition: T3dPoint;
                               out AResult: T3dInputResult);
begin
  ClearResult(AResult);
  AResult.Command := icZoom;
  AResult.Delta := Point3d(0, ASteps);
  AResult.Position := APosition;
end;

end.
