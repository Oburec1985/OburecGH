program CoordinatorSqlStoreDiagnostic;
{$mode objfpc}{$H+}
uses SysUtils, uCoordinatorModel, uCoordinatorSqlEventStore;
var
  S: TCoordinatorSqlEventStore;
  I: TCoordinatorRecordingLifecycle;
begin
  I := Default(TCoordinatorRecordingLifecycle);
  I.MessageType := 'recording.started';
  I.EventId := 'diag-event-003';
  I.CorrelationId := 'diag-corr-003';
  I.RecordingId := 'diag-rec-003';
  I.InstanceId := 'diag-host-003';
  I.HostName := 'diagnostic-host';
  I.DisplayName := 'Diagnostic';
  I.ProjectName := 'default';
  I.State := 'building';
  I.LocalPath := 'D:\diag\0003\';
  I.EntryFile := 'D:\diag\0003\0003.mera';
  I.StartedUtc := Now;
  S := TCoordinatorSqlEventStore.Create(
    'D:\works\OburecGH\Lazarus\RecorderLnx\config\projects\default\sql-db.ini');
  try
    Writeln('enabled=', S.Enabled);
    Writeln('result=', S.HandleLifecycle(I));
    Writeln('last=', S.LastError);
  finally
    S.Free;
  end;
end.
