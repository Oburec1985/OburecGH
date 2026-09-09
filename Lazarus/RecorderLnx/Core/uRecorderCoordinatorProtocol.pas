unit uRecorderCoordinatorProtocol;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, fpjson;

const
  CRecorderCoordinatorProtocolVersion = 1;

type
  TRecorderCoordinatorResultCode = (rcrcNoError, rcrcNotReady,
    rcrcAlreadyRecording, rcrcDeviceOffline, rcrcInsufficientDiskSpace,
    rcrcInvalidProject, rcrcTimeout, rcrcAccessDenied, rcrcInvalidCommand,
    rcrcInternalError);

  TRecorderCoordinatorCommand = class
  public
    CommandId: string;
    CommandType: string;
    CorrelationId: string;
    ExecuteAtUtc: TDateTime;
    DeadlineUtc: TDateTime;
    PayloadJson: string;
    class function FromJson(AJson: TJSONData): TRecorderCoordinatorCommand;
  end;

function RecorderCoordinatorNewId: string;
function RecorderCoordinatorUtcNow: TDateTime;
function RecorderCoordinatorResultCodeName(
  ACode: TRecorderCoordinatorResultCode): string;
function RecorderCoordinatorEnvelope(const AMessageType, AMessageId,
  AInstanceId, ACorrelationId, AReplyTo, APayloadJson: string): string;

implementation

uses
  DateUtils;

function JsonString(AObject: TJSONObject; const AName: string): string;
var
  lData: TJSONData;
begin
  Result := '';
  lData := AObject.Find(AName);
  if lData <> nil then
    Result := lData.AsString;
end;

function JsonUtc(AObject: TJSONObject; const AName: string): TDateTime;
var
  lText: string;
begin
  Result := 0;
  lText := JsonString(AObject, AName);
  if lText <> '' then
    { Coordinator timestamps are ISO-8601 UTC. Returning local time here made
      scheduled command/deadline comparisons depend on the Recorder host TZ. }
    TryISO8601ToDate(lText, Result, True);
end;

class function TRecorderCoordinatorCommand.FromJson(
  AJson: TJSONData): TRecorderCoordinatorCommand;
var
  lObject: TJSONObject;
  lPayload: TJSONData;
begin
  Result := nil;
  if not (AJson is TJSONObject) then
    Exit;
  lObject := TJSONObject(AJson);
  Result := TRecorderCoordinatorCommand.Create;
  Result.CommandId := JsonString(lObject, 'command_id');
  if Result.CommandId = '' then
    Result.CommandId := JsonString(lObject, 'message_id');
  Result.CommandType := JsonString(lObject, 'command_type');
  if Result.CommandType = '' then
    Result.CommandType := JsonString(lObject, 'message_type');
  Result.CorrelationId := JsonString(lObject, 'correlation_id');
  Result.ExecuteAtUtc := JsonUtc(lObject, 'execute_at_utc');
  Result.DeadlineUtc := JsonUtc(lObject, 'deadline_utc');
  lPayload := lObject.Find('payload');
  if lPayload <> nil then
    Result.PayloadJson := lPayload.AsJSON
  else
    Result.PayloadJson := '{}';
end;

function RecorderCoordinatorNewId: string;
var
  lGuid: TGUID;
begin
  if CreateGUID(lGuid) <> 0 then
    Exit('');
  Result := GUIDToString(lGuid);
  Result := StringReplace(Result, '{', '', []);
  Result := StringReplace(Result, '}', '', []);
end;

function RecorderCoordinatorUtcNow: TDateTime;
begin
  Result := LocalTimeToUniversal(Now);
end;

function RecorderCoordinatorResultCodeName(
  ACode: TRecorderCoordinatorResultCode): string;
const
  CNames: array[TRecorderCoordinatorResultCode] of string = (
    'noError', 'notReady', 'alreadyRecording', 'deviceOffline',
    'insufficientDiskSpace', 'invalidProject', 'timeout', 'accessDenied',
    'invalidCommand', 'internalError');
begin
  Result := CNames[ACode];
end;

function RecorderCoordinatorEnvelope(const AMessageType, AMessageId,
  AInstanceId, ACorrelationId, AReplyTo, APayloadJson: string): string;
var
  lEnvelope: TJSONObject;
  lPayload: TJSONData;
begin
  lEnvelope := TJSONObject.Create;
  try
    lEnvelope.Add('protocol_version', CRecorderCoordinatorProtocolVersion);
    lEnvelope.Add('message_id', AMessageId);
    lEnvelope.Add('message_type', AMessageType);
    lEnvelope.Add('instance_id', AInstanceId);
    lEnvelope.Add('correlation_id', ACorrelationId);
    lEnvelope.Add('reply_to', AReplyTo);
    lEnvelope.Add('sent_at_utc', DateToISO8601(RecorderCoordinatorUtcNow, True));
    try
      lPayload := GetJSON(APayloadJson);
    except
      lPayload := TJSONObject.Create;
    end;
    lEnvelope.Add('payload', lPayload);
    Result := lEnvelope.AsJSON;
  finally
    lEnvelope.Free;
  end;
end;

end.
