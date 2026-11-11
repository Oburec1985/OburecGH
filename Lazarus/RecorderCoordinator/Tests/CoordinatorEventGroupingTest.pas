program CoordinatorEventGroupingTest;

{$mode objfpc}{$H+}

uses
  SysUtils, fpjson, uCoordinatorModel;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure SendEvent(AModel: TCoordinatorModel; const AType, ACorrelation,
  ARecording, AStartedUtc: string; const AInstanceId: string = '');
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('message_type', AType);
    lData.Add('correlation_id', ACorrelation);
    lData.Add('recording_id', ARecording);
    if AInstanceId <> '' then lData.Add('instance_id', AInstanceId);
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

procedure CheckClosedTakeAndRetries;
var
  lModel: TCoordinatorModel;
  lEvents: TJSONArray;
  I: Integer;
begin
  lModel := TCoordinatorModel.Create;
  try
    SendEvent(lModel, 'recording.started', 'take-one', 'host-a-one',
      '2026-09-09T10:00:00.000Z', 'host-a');
    SendEvent(lModel, 'recording.started', 'take-one', 'host-b-one',
      '2026-09-09T10:00:01.000Z', 'host-b');
    for I := 3 to 5 do
      SendEvent(lModel, 'recording.started', 'take-one', 'host-' + IntToStr(I) + '-one',
        '2026-09-09T10:00:01.500Z', 'host-' + IntToStr(I));
    SendEvent(lModel, 'recording.completed', 'take-one', 'host-a-one',
      '2026-09-09T10:00:02.000Z');
    SendEvent(lModel, 'recording.completed', 'take-one', 'host-b-one',
      '2026-09-09T10:00:03.000Z');
    for I := 3 to 5 do
      SendEvent(lModel, 'recording.completed', 'take-one', 'host-' + IntToStr(I) + '-one',
        '2026-09-09T10:00:03.500Z', 'host-' + IntToStr(I));
    { A second real take inside the original 30-second window is a new event. }
    SendEvent(lModel, 'recording.started', 'take-two', 'host-a-two',
      '2026-09-09T10:00:10.000Z', 'host-a');
    SendEvent(lModel, 'recording.started', 'take-two', 'host-b-two',
      '2026-09-09T10:00:11.000Z', 'host-b');
    for I := 3 to 5 do
      SendEvent(lModel, 'recording.started', 'take-two', 'host-' + IntToStr(I) + '-two',
        '2026-09-09T10:00:11.500Z', 'host-' + IntToStr(I));
    { Delayed/repeated envelopes retain their recording identity. }
    SendEvent(lModel, 'recording.started', 'take-one', 'host-a-one',
      '2026-09-09T10:01:00.000Z', 'host-a');
    SendEvent(lModel, 'recording.started', 'take-two', 'host-b-two',
      '2026-09-09T10:01:01.000Z', 'host-b');
    SendEvent(lModel, 'recording.completed', 'take-one', 'host-b-one',
      '2026-09-09T10:01:02.000Z');
    lEvents := lModel.EventsJson;
    try
      Check(lEvents.Count = 2, 'closed take reopened or retry created another event');
      Check(TJSONObject(lEvents[0]).Get('state', '') = 'completed',
        'late start retry reopened the completed take');
      Check(TJSONObject(lEvents[0]).Arrays['recording_ids'].Count = 5,
        'second take was appended to the completed first take');
      Check(TJSONObject(lEvents[1]).Arrays['recording_ids'].Count = 5,
        'recording retry duplicated a package');
    finally
      lEvents.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckRepeatedHostAndLateParticipant;
var
  lModel: TCoordinatorModel;
  lEvents: TJSONArray;
begin
  lModel := TCoordinatorModel.Create;
  try
    SendEvent(lModel, 'recording.started', 'local-origin', 'a-first',
      '2026-09-09T10:00:00.000Z', 'a');
    SendEvent(lModel, 'recording.started', 'auto-peer-origin', 'b-first',
      '2026-09-09T10:00:01.000Z', 'b');
    SendEvent(lModel, 'recording.started', 'second-take', 'a-second',
      '2026-09-09T10:00:10.000Z', 'a');
    { Its old source timestamp keeps this late participant in the first take. }
    SendEvent(lModel, 'recording.started', 'auto-peer-origin', 'c-first',
      '2026-09-09T10:00:02.000Z', 'c');
    lEvents := lModel.EventsJson;
    try
      Check(lEvents.Count = 2, 'a second recording on an active host reused the first take');
      Check(TJSONObject(lEvents[0]).Arrays['recording_ids'].Count = 3,
        'late first-take participant joined the newer take');
      Check(TJSONObject(lEvents[1]).Arrays['recording_ids'].Count = 1,
        'a repeated host did not begin a separate take');
    finally
      lEvents.Free;
    end;
  finally
    lModel.Free;
  end;

  lModel := TCoordinatorModel.Create;
  try
    SendEvent(lModel, 'recording.started', 'one', 'a-first',
      '2026-09-09T10:00:00.000Z', 'a');
    SendEvent(lModel, 'recording.completed', 'one', 'a-first',
      '2026-09-09T10:00:01.000Z', 'a');
    SendEvent(lModel, 'recording.started', 'peer', 'b-first',
      '2026-09-09T10:00:00.500Z', 'b');
    lEvents := lModel.EventsJson;
    try
      Check(lEvents.Count = 1, 'unseen late participant was separated after known hosts completed');
      Check(TJSONObject(lEvents[0]).Arrays['recording_ids'].Count = 2,
        'late source recording was omitted');
      Check(TJSONObject(lEvents[0]).Get('state', '') = 'active',
        'a real newly reported active participant was marked completed');
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
  CheckClosedTakeAndRetries;
  CheckRepeatedHostAndLateParticipant;
  WriteLn('OK: recording starts use fixed time windows; completion uses recording id');
end.
