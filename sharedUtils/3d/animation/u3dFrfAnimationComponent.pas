unit u3dFrfAnimationComponent;

interface

uses
  Classes, u3dContracts, u3dHelperMotionEngine,
  u3dFrfDisplacementSource;

type
  T3dFrfAnimationComponent = class(TComponent)
  private
    fEngine: T3dHelperMotionEngine;
    fSourceObject: T3dFrfDisplacementSource;
    fSource: I3dDisplacementSource;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ConfigureFrf(const AFrequencyStep: Double;
      const APoints: array of T3dFrfPointSeries);
    procedure ConfigureBindings(const ABindings: array of T3dHelperBinding;
      const AInvalidation: I3dInvalidationSink);
    procedure SetFrame(const AFrequency, APhaseRadians: Double;
      const AVersion: Cardinal);
    function ApplyFrame(const ATime: Double): Boolean;
    property Source: I3dDisplacementSource read fSource;
  end;

implementation

constructor T3dFrfAnimationComponent.Create(AOwner: TComponent);
begin
  inherited;
  fEngine := T3dHelperMotionEngine.Create;
  fSourceObject := T3dFrfDisplacementSource.Create;
  fSource := fSourceObject;
end;

destructor T3dFrfAnimationComponent.Destroy;
begin
  fEngine.Free;
  fSource := nil;
  inherited;
end;

procedure T3dFrfAnimationComponent.ConfigureFrf(
  const AFrequencyStep: Double;
  const APoints: array of T3dFrfPointSeries);
begin
  fSourceObject.Configure(AFrequencyStep, APoints);
end;

procedure T3dFrfAnimationComponent.ConfigureBindings(
  const ABindings: array of T3dHelperBinding;
  const AInvalidation: I3dInvalidationSink);
begin
  fEngine.Configure(ABindings, AInvalidation);
end;

procedure T3dFrfAnimationComponent.SetFrame(const AFrequency,
  APhaseRadians: Double; const AVersion: Cardinal);
begin
  fSourceObject.SetFrame(AFrequency, APhaseRadians, AVersion);
end;

function T3dFrfAnimationComponent.ApplyFrame(
  const ATime: Double): Boolean;
begin
  Result := fEngine.Update(ATime);
end;

end.
