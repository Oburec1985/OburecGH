unit u3dCoreTypes;

interface

type
  T3dVector3 = record
    X: Double;
    Y: Double;
    Z: Double;
  end;

  T3dAxisFrame = record
    XAxis: T3dVector3;
    YAxis: T3dVector3;
    ZAxis: T3dVector3;
  end;

function Vector3(const AX, AY, AZ: Double): T3dVector3;
function AddVector3(const ALeft, ARight: T3dVector3): T3dVector3;
function ScaleVector3(const AValue: T3dVector3;
  const AScale: Double): T3dVector3;
function TransformByFrame(const AValue: T3dVector3;
  const AFrame: T3dAxisFrame): T3dVector3;
function IdentityAxisFrame: T3dAxisFrame;

implementation

function Vector3(const AX, AY, AZ: Double): T3dVector3;
begin
  Result.X := AX;
  Result.Y := AY;
  Result.Z := AZ;
end;

function AddVector3(const ALeft, ARight: T3dVector3): T3dVector3;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
  Result.Z := ALeft.Z + ARight.Z;
end;

function ScaleVector3(const AValue: T3dVector3;
  const AScale: Double): T3dVector3;
begin
  Result.X := AValue.X * AScale;
  Result.Y := AValue.Y * AScale;
  Result.Z := AValue.Z * AScale;
end;

function TransformByFrame(const AValue: T3dVector3;
  const AFrame: T3dAxisFrame): T3dVector3;
begin
  Result.X := AFrame.XAxis.X * AValue.X +
    AFrame.YAxis.X * AValue.Y + AFrame.ZAxis.X * AValue.Z;
  Result.Y := AFrame.XAxis.Y * AValue.X +
    AFrame.YAxis.Y * AValue.Y + AFrame.ZAxis.Y * AValue.Z;
  Result.Z := AFrame.XAxis.Z * AValue.X +
    AFrame.YAxis.Z * AValue.Y + AFrame.ZAxis.Z * AValue.Z;
end;

function IdentityAxisFrame: T3dAxisFrame;
begin
  Result.XAxis := Vector3(1, 0, 0);
  Result.YAxis := Vector3(0, 1, 0);
  Result.ZAxis := Vector3(0, 0, 1);
end;

end.
