unit uRecorderSqlRevision;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Pure compare-and-swap decision for future distributed SQL configuration.
  The caller owns authenticated revision discovery and atomic persistence of
  the revision with the settings. This unit performs no I/O. }

interface

type
  TRecorderSqlRevisionDecision = (srdApply, srdAlreadyApplied, srdConflict,
    srdInvalid);

function RecorderSqlRevisionDecision(const AStoredRevision, AIncomingRevision,
  ABaseRevision: string; AHasBaseRevision, ASameConfiguration: Boolean):
  TRecorderSqlRevisionDecision;

implementation

uses SysUtils;

function ValidRevision(const AValue: string; AAllowEmpty: Boolean): Boolean;
var
  lIndex: Integer;
begin
  if AValue = '' then Exit(AAllowEmpty);
  if Length(AValue) > 128 then Exit(False);
  for lIndex := 1 to Length(AValue) do
    if not (AValue[lIndex] in ['a'..'z', 'A'..'Z', '0'..'9', '-', '_']) then
      Exit(False);
  Result := True;
end;

function RecorderSqlRevisionDecision(const AStoredRevision, AIncomingRevision,
  ABaseRevision: string; AHasBaseRevision, ASameConfiguration: Boolean):
  TRecorderSqlRevisionDecision;
begin
  if not ValidRevision(AStoredRevision, True) then Exit(srdInvalid);

  { Legacy commands are compatible only before a revision has been set. Once
    revisioned changes are enabled, an old sender must not overwrite them. }
  if AIncomingRevision = '' then
  begin
    if AHasBaseRevision then Exit(srdInvalid);
    if AStoredRevision = '' then Exit(srdApply);
    Exit(srdConflict);
  end;

  if (not AHasBaseRevision) or
     (not ValidRevision(AIncomingRevision, False)) or
     (not ValidRevision(ABaseRevision, True)) then Exit(srdInvalid);

  { A retry is successful only when its payload matches the applied settings.
    Reusing an ID with a different payload is a conflict. }
  if AIncomingRevision = AStoredRevision then
  begin
    if ASameConfiguration then Exit(srdAlreadyApplied);
    Exit(srdConflict);
  end;
  if ABaseRevision <> AStoredRevision then Exit(srdConflict);
  Result := srdApply;
end;

end.
