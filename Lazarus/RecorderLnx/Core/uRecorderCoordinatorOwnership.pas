unit uRecorderCoordinatorOwnership;

{$mode objfpc}{$H+}

interface

const
  CRecorderCoordinatorLeaseMs = 15000;

type
  { Runtime lease only: a restarted Recorder is deliberately unclaimed. }
  TRecorderCoordinatorOwnership = class
  private
    fRetired: array[0..63] of string;
    fRetiredNext: Integer;
    procedure RetireCurrent;
    function IsRetired(const ACoordinatorId, AClaimId: string): Boolean;
  public
    CoordinatorId, ClaimId, Url: string;
    Generation, LastSuccess: QWord;
    function CanClaim(const ACoordinatorId, AClaimId: string;
      AForce: Boolean): Boolean;
    procedure Accept(const ACoordinatorId, AClaimId, AUrl: string; ANow: QWord);
    procedure Clear;
    function Release(const ACoordinatorId, AClaimId: string): Boolean;
    function Expire(ANow: QWord): Boolean;
  end;

implementation

function TRecorderCoordinatorOwnership.IsRetired(const ACoordinatorId,
  AClaimId: string): Boolean;
var
  lIndex: Integer;
begin
  Result := True;
  for lIndex := 0 to High(fRetired) do
    if fRetired[lIndex] = ACoordinatorId + #0 + AClaimId then Exit;
  Result := False;
end;

procedure TRecorderCoordinatorOwnership.RetireCurrent;
begin
  if CoordinatorId = '' then Exit;
  fRetired[fRetiredNext] := CoordinatorId + #0 + ClaimId;
  fRetiredNext := (fRetiredNext + 1) mod Length(fRetired);
end;

function TRecorderCoordinatorOwnership.CanClaim(const ACoordinatorId,
  AClaimId: string; AForce: Boolean): Boolean;
begin
  Result := (ACoordinatorId <> '') and (AClaimId <> '') and
    not IsRetired(ACoordinatorId, AClaimId) and
    ((CoordinatorId = '') or AForce or
     (CoordinatorId = ACoordinatorId));
end;

procedure TRecorderCoordinatorOwnership.Accept(const ACoordinatorId,
  AClaimId, AUrl: string; ANow: QWord);
begin
  if (CoordinatorId <> ACoordinatorId) or (ClaimId <> AClaimId) or
    (Url <> AUrl) then
  begin
    if (CoordinatorId <> ACoordinatorId) or (ClaimId <> AClaimId) then
      RetireCurrent;
    Inc(Generation);
  end;
  CoordinatorId := ACoordinatorId;
  ClaimId := AClaimId;
  Url := AUrl;
  LastSuccess := ANow;
end;

procedure TRecorderCoordinatorOwnership.Clear;
begin
  if CoordinatorId <> '' then
  begin
    RetireCurrent;
    Inc(Generation);
  end;
  CoordinatorId := '';
  ClaimId := '';
  Url := '';
  LastSuccess := 0;
end;

function TRecorderCoordinatorOwnership.Release(const ACoordinatorId,
  AClaimId: string): Boolean;
begin
  Result := (CoordinatorId <> '') and (CoordinatorId = ACoordinatorId) and
    (ClaimId = AClaimId);
  if Result then Clear;
end;

function TRecorderCoordinatorOwnership.Expire(ANow: QWord): Boolean;
begin
  Result := (CoordinatorId <> '') and (ANow - LastSuccess >= CRecorderCoordinatorLeaseMs);
  if Result then Clear;
end;

end.
