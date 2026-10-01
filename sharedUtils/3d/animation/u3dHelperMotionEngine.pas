unit u3dHelperMotionEngine;

interface

uses
  SysUtils, u3dCoreTypes, u3dContracts;

type
  T3dHelperBinding = record
    PointIndex: Integer;
    Frame: T3dAxisFrame;
    Scale: Double;
    BasePosition: T3dVector3;
    Source: I3dDisplacementSource;
    Target: I3dTransformTarget;
    LastVersion: Cardinal;
    LastTime: Double;
    HasVersion: Boolean;
  end;

  T3dHelperMotionEngine = class
  private
    fBindings: array of T3dHelperBinding;
    fInvalidation: I3dInvalidationSink;
    fConfigured: Boolean;
    procedure CheckBinding(const ABinding: T3dHelperBinding);
  public
    procedure Configure(const ABindings: array of T3dHelperBinding;
      const AInvalidation: I3dInvalidationSink);
    procedure ResetVersions;
    function Update(const ATime: Double): Boolean;
    property Configured: Boolean read fConfigured;
  end;

implementation

procedure T3dHelperMotionEngine.CheckBinding(
  const ABinding: T3dHelperBinding);
begin
  if ABinding.Source = nil then
    raise EArgumentException.Create('3D helper binding source is nil');
  if ABinding.Target = nil then
    raise EArgumentException.Create('3D helper binding target is nil');
  if (ABinding.PointIndex < 0) or
     (ABinding.PointIndex >= ABinding.Source.PointCount) then
    raise EArgumentException.Create('3D helper point index is out of range');
end;

procedure T3dHelperMotionEngine.Configure(
  const ABindings: array of T3dHelperBinding;
  const AInvalidation: I3dInvalidationSink);
var
  lIndex: Integer;
begin
  SetLength(fBindings, Length(ABindings));
  for lIndex := 0 to High(ABindings) do
  begin
    CheckBinding(ABindings[lIndex]);
    fBindings[lIndex] := ABindings[lIndex];
    fBindings[lIndex].HasVersion := False;
  end;
  fInvalidation := AInvalidation;
  fConfigured := True;
end;

procedure T3dHelperMotionEngine.ResetVersions;
var
  lIndex: Integer;
begin
  for lIndex := 0 to High(fBindings) do
    fBindings[lIndex].HasVersion := False;
end;

function T3dHelperMotionEngine.Update(const ATime: Double): Boolean;
var
  lBinding: ^T3dHelperBinding;
  lDisplacement: T3dVector3;
  lPosition: T3dVector3;
  lVersion: Cardinal;
  lIndex: Integer;
begin
  Result := False;
  if not fConfigured then
    Exit;

  for lIndex := 0 to High(fBindings) do
  begin
    lBinding := @fBindings[lIndex];
    if lBinding^.Source.TryReadDisplacement(lBinding^.PointIndex,
      ATime, lDisplacement, lVersion) then
    begin
      if lBinding^.HasVersion and (lBinding^.LastVersion = lVersion) and
         (lBinding^.LastTime = ATime) then
        Continue;
      lDisplacement := TransformByFrame(lDisplacement, lBinding^.Frame);
      lDisplacement := ScaleVector3(lDisplacement, lBinding^.Scale);
      lPosition := AddVector3(lBinding^.BasePosition, lDisplacement);
      lBinding^.Target.SetLocalDisplacement(lPosition);
      lBinding^.LastVersion := lVersion;
      lBinding^.LastTime := ATime;
      lBinding^.HasVersion := True;
      Result := True;
    end;
  end;

  if Result and (fInvalidation <> nil) then
    fInvalidation.InvalidateGeometry;
end;

end.
