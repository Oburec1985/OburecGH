unit uRecorderImpactHammerPresenter;

{ Pure presenter for impact-hammer result tabs. It resolves visibility,
  scaling and cursor interpolation before any OglChart paint callback. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Math, uRecorderImpactHammerContracts;

type
  TRecorderImpactPresentationFrame = record
    ResultType: TRecorderImpactResultType;
    AxisState: TImpactResultAxisState;
    XUnitName: string;
    Curves: array of TRecorderImpactPresentationCurve;
    Cursor: TRecorderImpactCursorReadout;
  end;

  TRecorderImpactHammerPresenter = class
  private
    fResultType: TRecorderImpactResultType;
    fAxisState: TImpactResultAxisState;
    class function Interpolate(const ACurve: TRecorderImpactPresentationCurve;
      AX: Double; out AY: Double): Boolean; static;
  public
    procedure Configure(AResultType: TRecorderImpactResultType;
      const AAxisState: TImpactResultAxisState);
    function Build(const ASnapshot: TRecorderImpactHammerSnapshot;
      out AFrame: TRecorderImpactPresentationFrame): Boolean;
    function BuildCursor(const ASnapshot: TRecorderImpactHammerSnapshot;
      var ACursor: TRecorderImpactCursorReadout): Boolean;
  end;

implementation

class function TRecorderImpactHammerPresenter.Interpolate(
  const ACurve: TRecorderImpactPresentationCurve; AX: Double;
  out AY: Double): Boolean;
var
  lIndex: Integer;
  lRatio: Double;
begin
  Result := False;
  if (Length(ACurve.X) = 0) or (Length(ACurve.X) <> Length(ACurve.Y)) or
    (AX < ACurve.X[0]) or (AX > ACurve.X[High(ACurve.X)]) then
    Exit;
  lIndex := 0;
  while (lIndex < High(ACurve.X)) and (ACurve.X[lIndex + 1] < AX) do
    Inc(lIndex);
  if (lIndex = High(ACurve.X)) or (ACurve.X[lIndex] = AX) then
    AY := ACurve.Y[lIndex]
  else
  begin
    lRatio := (AX - ACurve.X[lIndex]) /
      (ACurve.X[lIndex + 1] - ACurve.X[lIndex]);
    AY := ACurve.Y[lIndex] + lRatio *
      (ACurve.Y[lIndex + 1] - ACurve.Y[lIndex]);
  end;
  Result := True;
end;

procedure TRecorderImpactHammerPresenter.Configure(
  AResultType: TRecorderImpactResultType;
  const AAxisState: TImpactResultAxisState);
begin
  fResultType := AResultType;
  fAxisState := AAxisState;
end;

function TRecorderImpactHammerPresenter.Build(
  const ASnapshot: TRecorderImpactHammerSnapshot;
  out AFrame: TRecorderImpactPresentationFrame): Boolean;
var
  lSource, lTarget, lReadout: Integer;
  lValue: Double;
begin
  AFrame := Default(TRecorderImpactPresentationFrame);
  AFrame.ResultType := fResultType;
  AFrame.AxisState := fAxisState;
  AFrame.XUnitName := ASnapshot.Results[fResultType].XUnitName;
  SetLength(AFrame.Curves,
    Length(ASnapshot.Results[fResultType].Curves));
  lTarget := 0;
  for lSource := 0 to High(ASnapshot.Results[fResultType].Curves) do
    if ASnapshot.Results[fResultType].Curves[lSource].Visible then
    begin
      AFrame.Curves[lTarget] :=
        ASnapshot.Results[fResultType].Curves[lSource];
      Inc(lTarget);
    end;
  SetLength(AFrame.Curves, lTarget);
  AFrame.Cursor.FrequencyHz := ASnapshot.Cursor.FrequencyHz;
  AFrame.Cursor.FrequencyHz2 := ASnapshot.Cursor.FrequencyHz2;
  AFrame.Cursor.HasSecond := ASnapshot.Cursor.HasSecond;
  SetLength(AFrame.Cursor.Values, lTarget);
  SetLength(AFrame.Cursor.Values2, lTarget);
  for lReadout := 0 to lTarget - 1 do
  begin
    if Interpolate(AFrame.Curves[lReadout],
      AFrame.Cursor.FrequencyHz, lValue) then
      AFrame.Cursor.Values[lReadout] := lValue
    else
      AFrame.Cursor.Values[lReadout] := NaN;
    if ASnapshot.Cursor.HasSecond and Interpolate(AFrame.Curves[lReadout],
      ASnapshot.Cursor.FrequencyHz2, lValue) then
      AFrame.Cursor.Values2[lReadout] := lValue
    else
      AFrame.Cursor.Values2[lReadout] := NaN;
  end;
  Result := lTarget > 0;
end;

function TRecorderImpactHammerPresenter.BuildCursor(
  const ASnapshot: TRecorderImpactHammerSnapshot;
  var ACursor: TRecorderImpactCursorReadout): Boolean;
var
  Source: Integer;
  Target: Integer;
  Value: Double;
begin
  ACursor.FrequencyHz := ASnapshot.Cursor.FrequencyHz;
  ACursor.FrequencyHz2 := ASnapshot.Cursor.FrequencyHz2;
  ACursor.HasSecond := ASnapshot.Cursor.HasSecond;
  Target := 0;
  for Source := 0 to High(ASnapshot.Results[fResultType].Curves) do
    if ASnapshot.Results[fResultType].Curves[Source].Visible then
      Inc(Target);
  SetLength(ACursor.Values, Target);
  SetLength(ACursor.Values2, Target);
  Target := 0;
  for Source := 0 to High(ASnapshot.Results[fResultType].Curves) do
    if ASnapshot.Results[fResultType].Curves[Source].Visible then
    begin
      if Interpolate(ASnapshot.Results[fResultType].Curves[Source],
        ACursor.FrequencyHz, Value) then
        ACursor.Values[Target] := Value
      else
        ACursor.Values[Target] := NaN;
      if ACursor.HasSecond and
        Interpolate(ASnapshot.Results[fResultType].Curves[Source],
          ACursor.FrequencyHz2, Value) then
        ACursor.Values2[Target] := Value
      else
        ACursor.Values2[Target] := NaN;
      Inc(Target);
    end;
  Result := Target > 0;
end;

end.
