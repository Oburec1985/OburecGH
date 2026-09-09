unit uRecorderRecordTimebase;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  TRecorderRecordTimeDomain = record
    Key: string;
    OriginSec: Double;
    Ready: Boolean;
  end;

  { Keeps raw device clocks out of the record-relative MERA time axis. }
  TRecorderRecordTimebase = class
  private
    fDomains: array of TRecorderRecordTimeDomain;
  public
    procedure Reset;
    function RequireDomain(const AKey: string): Integer;
    procedure SetOrigin(AIndex: Integer; AOriginSec: Double);
    function OriginReady(AIndex: Integer): Boolean;
    function Normalize(AIndex: Integer; var ATimes: array of Double;
      ACount: Integer): Boolean;
  end;

implementation

uses
  SysUtils;

procedure TRecorderRecordTimebase.Reset;
begin
  SetLength(fDomains, 0);
end;

function TRecorderRecordTimebase.RequireDomain(const AKey: string): Integer;
var
  I: Integer;
begin
  for I := 0 to High(fDomains) do
    if SameText(fDomains[I].Key, AKey) then
      Exit(I);
  Result := Length(fDomains);
  SetLength(fDomains, Result + 1);
  fDomains[Result].Key := AKey;
  fDomains[Result].OriginSec := 0;
  fDomains[Result].Ready := False;
end;

procedure TRecorderRecordTimebase.SetOrigin(AIndex: Integer;
  AOriginSec: Double);
begin
  if (AIndex < 0) or (AIndex > High(fDomains)) or fDomains[AIndex].Ready then
    Exit;
  fDomains[AIndex].OriginSec := AOriginSec;
  fDomains[AIndex].Ready := True;
end;

function TRecorderRecordTimebase.OriginReady(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex <= High(fDomains)) and
    fDomains[AIndex].Ready;
end;

function TRecorderRecordTimebase.Normalize(AIndex: Integer;
  var ATimes: array of Double; ACount: Integer): Boolean;
var
  I: Integer;
begin
  Result := OriginReady(AIndex);
  if not Result then
    Exit;
  if ACount > Length(ATimes) then
    ACount := Length(ATimes);
  for I := 0 to ACount - 1 do
    ATimes[I] := ATimes[I] - fDomains[AIndex].OriginSec;
end;

end.
