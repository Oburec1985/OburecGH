unit u3dInteractionDispatcher;

{ Arbitrates mutually exclusive interaction contexts with explicit capture
  tokens. The widget releases capture on mouse-up, cancel, or mode changes. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  T3dInteractionContext = (ictNone,ictObjectSelect,ictObjectManipulate,
                           ictCameraPan,ictCameraRotate,ictCameraZoom,ictOverlayPick);
  T3dCaptureToken = QWord;

  T3dInteractionDispatcher = class
  private
      fActive: T3dInteractionContext;
      fToken,fNextToken: T3dCaptureToken;
      fEnabled: array[T3dInteractionContext] of Boolean;
      fPriority: array[T3dInteractionContext] of Integer;
  public
      constructor Create;
      procedure Configure(AContext:T3dInteractionContext; AEnabled:Boolean;
                          APriority:Integer);
      function TryCapture(AContext:T3dInteractionContext;
                          out AToken:T3dCaptureToken): Boolean;
      function Owns(AToken:T3dCaptureToken;
                    AContext:T3dInteractionContext): Boolean;
      function IsEnabled(AContext:T3dInteractionContext): Boolean;
      function PriorityOf(AContext:T3dInteractionContext): Integer;
      function Release(AToken:T3dCaptureToken): Boolean;
      procedure Cancel;
      property ActiveContext: T3dInteractionContext read fActive;
  end;

implementation

constructor T3dInteractionDispatcher.Create;

var C: T3dInteractionContext;
begin
  inherited Create;
  fActive := ictNone;
  fNextToken := 1;
  for C:=Low(T3dInteractionContext) to High(T3dInteractionContext) do
    begin
      fEnabled[C] := C<>ictNone;
      fPriority[C] := Ord(C);
    end;
end;

procedure T3dInteractionDispatcher.Configure(AContext:T3dInteractionContext;
                                             AEnabled:Boolean; APriority:Integer);
begin
  if AContext=ictNone then
    Exit;
  fEnabled[AContext] := AEnabled;
  fPriority[AContext] := APriority;
  if (not AEnabled) and (fActive=AContext) then
    Cancel;
end;

function T3dInteractionDispatcher.TryCapture(AContext:T3dInteractionContext;
                                             out AToken:T3dCaptureToken): Boolean;
begin
  AToken := 0;
  Result := (AContext<>ictNone) and fEnabled[AContext] and (fActive=ictNone);
  if not Result then
    Exit;


{ Priority is deliberately stored with each listener/context. It is used by
    callers when resolving simultaneous hits; capture itself remains atomic. }
  fActive := AContext;
  fToken := fNextToken;
  Inc(fNextToken);
  if fNextToken=0 then
    fNextToken := 1;
  AToken := fToken;
end;

function T3dInteractionDispatcher.Owns(AToken:T3dCaptureToken;
                                       AContext:T3dInteractionContext): Boolean;
begin
  Result := (AToken<>0) and (AToken=fToken) and (fActive=AContext);
end;

function T3dInteractionDispatcher.IsEnabled(
                                            AContext:T3dInteractionContext): Boolean;
begin
  Result := (AContext<>ictNone) and fEnabled[AContext];
end;

function T3dInteractionDispatcher.PriorityOf(
                                             AContext:T3dInteractionContext): Integer;
begin
  if AContext=ictNone then
    Result := Low(Integer)
  else Result := fPriority[AContext];
end;

function T3dInteractionDispatcher.Release(AToken:T3dCaptureToken): Boolean;
begin
  Result := (AToken<>0) and (AToken=fToken);
  if Result then
    begin
      fActive := ictNone;
      fToken := 0;
    end;
end;

procedure T3dInteractionDispatcher.Cancel;
begin
  fActive := ictNone;
  fToken := 0;
end;

end.
