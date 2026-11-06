program RecorderSqlRevisionTest;

{$mode objfpc}{$H+}

uses SysUtils, uRecorderSqlRevision;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

begin
  Check(RecorderSqlRevisionDecision('', '', '', False, False) = srdApply,
    'legacy command should work before migration');
  Check(RecorderSqlRevisionDecision('', 'rev-A', '', True, False) = srdApply,
    'first revision should apply against empty base');
  Check(RecorderSqlRevisionDecision('rev-A', 'rev-A', '', True, True) =
    srdAlreadyApplied, 'same revision and data should be idempotent');
  Check(RecorderSqlRevisionDecision('rev-A', 'rev-A', '', True, False) =
    srdConflict, 'same revision with different data must fail');
  Check(RecorderSqlRevisionDecision('rev-A', 'rev-B', 'rev-A', True, False) =
    srdApply, 'successor should apply');
  Check(RecorderSqlRevisionDecision('rev-B', 'rev-C', 'rev-A', True, False) =
    srdConflict, 'concurrent stale writer must not overwrite');
  Check(RecorderSqlRevisionDecision('rev-B', '', '', False, False) =
    srdConflict, 'legacy command must not overwrite a revisioned setting');
  Check(RecorderSqlRevisionDecision('rev-B', 'rev-C', '', False, False) =
    srdInvalid, 'missing base must fail closed');
  Check(RecorderSqlRevisionDecision('rev-B', 'rev C', 'rev-B', True, False) =
    srdInvalid, 'malformed revision must fail closed');
  WriteLn('OK: SQL configuration compare-and-swap');
end.
