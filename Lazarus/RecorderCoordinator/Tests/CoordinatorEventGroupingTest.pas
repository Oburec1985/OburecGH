program CoordinatorEventGroupingTest;

{$mode objfpc}{$H+}

uses
  SysUtils, fpjson, uCoordinatorModel;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure SendEvent(AModel: TCoordinatorModel; const AType, ACorrelation,
  ARecording, AStartedUtc: string);
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('message_type', AType);
    lData.Add('correlation_id', ACorrelation);
    lData.Add('recording_id', ARecording);
    lData.Add('started_utc', AStartedUtc);
    lResult := AModel.AddRecordingEvent(lData);
    lResult.Free;
  finally
    lData.Free;
  end;
end;

procedure CheckCorrelationLifecycle;
var
  lModel: TCoordinatorModel;
  lEvents: TJSONArray;
  lEvent: TJSONObject;
begin
  lModel := TCoordinatorModel.Create;
  try
    SendEvent(lModel, 'recording.started',
      '{11111111-1111-1111-1111-111111111111}', 'rec-1',
      '2026-09-09T10:00:00.000Z');
    SendEvent(lModel, 'recording.started', 'client-b', 'rec-2',
      '2026-09-09T10:00:20.000Z');
    SendEvent(lModel, 'recording.completed', 'unrelated-correlation', 'rec-1',
      '2026-09-09T10:05:00.000Z');
    lEvents := lModel.EventsJson;
    try
      Check(lEvents.Count = 1,
        'starts inside first-start window must form one event');
      lEvent := TJSONObject(lEvents.Items[0]);
      Check(lEvent.Get('correlation_id', '') =
        '11111111-1111-1111-1111-111111111111',
        'braced GUID correlation was not normalized to varchar(36)');
      Check(lEvent.Get('state', '') = 'active',
        'group completed before all recordings');
    finally
      lEvents.Free;
    end;
    SendEvent(lModel, 'recording.completed', '', 'rec-2',
      '2026-09-09T10:05:01.000Z');
    SendEvent(lModel, 'recording.started', 'client-a', 'rec-3',
      '2026-09-09T10:00:30.000Z');
    SendEvent(lModel, 'recording.completed', '', 'orphan',
      '2026-09-09T10:05:02.000Z');
    lEvents := lModel.EventsJson;
    try
      Check(lEvents.Count = 2,
        'start after the fixed window or orphan completion grouped incorrectly');
      Check(TJSONObject(lEvents.Items[0]).Get('state', '') = 'completed',
        'group did not complete after all recordings');
    finally
      lEvents.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckDisabled;
var
  lModel: TCoordinatorModel;
  lEvents: TJSONArray;
begin
  lModel := TCoordinatorModel.Create;
  try
    lModel.CreateRecordingEvents := False;
    SendEvent(lModel, 'recording.started', 'disabled', 'rec-1',
      '2026-09-09T10:00:00.000Z');
    lEvents := lModel.EventsJson;
    try
      Check(lEvents.Count = 0, 'disabled event creation changed the model');
    finally
      lEvents.Free;
    end;
  finally
    lModel.Free;
  end;
end;

begin
  CheckCorrelationLifecycle;
  CheckDisabled;
  WriteLn('OK: recording starts use fixed time windows; completion uses recording id');
end.
