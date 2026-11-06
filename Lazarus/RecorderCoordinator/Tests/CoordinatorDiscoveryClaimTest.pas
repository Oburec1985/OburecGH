program CoordinatorDiscoveryClaimTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Classes, SysUtils, Sockets, fpjson, uRecorderLanDiscovery;

type
  TDiscoveryProbe = class(TRecorderLanDiscovery)
    procedure Feed(const AKind, ATarget, AClaim, AToken: string;
      APort: Integer; AForce: Boolean = False);
  end;

procedure TDiscoveryProbe.Feed(const AKind, ATarget, AClaim, AToken: string;
  APort: Integer; AForce: Boolean);
var
  lJson: TJSONObject;
  lSource: TInetSockAddr;
begin
  FillChar(lSource, SizeOf(lSource), 0);
  lJson := TJSONObject.Create;
  try
    lJson.Add('magic', 'RecorderLnxDiscovery');
    lJson.Add('version', 1);
    lJson.Add('kind', AKind);
    lJson.Add('instance_id', 'panel-a');
    lJson.Add('target_instance_id', ATarget);
    lJson.Add('claim_id', AClaim);
    lJson.Add('auth_token', AToken);
    lJson.Add('http_port', APort);
    lJson.Add('force', AForce);
    lJson.Add('url', 'http://unrelated.example:1');
    HandlePacket(lJson.AsJSON, '192.0.2.20', lSource);
  finally
    lJson.Free;
  end;
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

var
  lProbe: TDiscoveryProbe;
  lRequest: TRecorderCoordinatorControlRequest;
  lIndex, lCount: Integer;
begin
  lProbe := TDiscoveryProbe.Create(rdrRecorder, 'recorder-1', 'test', 0);
  try
    lProbe.Feed('coordinator.available', '', '', '', 8765);
    Check(not lProbe.TakeControlRequest(lRequest), 'availability must not claim');
    lProbe.Feed('coordinator.claim', 'other-recorder', 'one', '', 8765);
    Check(not lProbe.TakeControlRequest(lRequest), 'target identity must match');
    lProbe.Feed('coordinator.claim', 'recorder-1', '', '', 8765);
    lProbe.Feed('coordinator.claim', 'recorder-1', 'one', '', 0);
    lProbe.Feed('coordinator.claim', 'recorder-1', 'one', '', 65536);
    Check(not lProbe.TakeControlRequest(lRequest), 'invalid fields must reject');
    lProbe.SetControlToken('test-token');
    lProbe.Feed('coordinator.claim', 'recorder-1', 'one', '', 8765);
    Check(not lProbe.TakeControlRequest(lRequest), 'token must match');
    lProbe.Feed('coordinator.claim', 'recorder-1', 'one', 'test-token', 8765, True);
    lProbe.Feed('coordinator.claim', 'recorder-1', 'one', 'test-token', 8765, True);
    Check(lProbe.TakeControlRequest(lRequest), 'valid claim missing');
    Check(lRequest.CoordinatorId = 'panel-a', 'panel identity');
    Check(lRequest.CoordinatorUrl = 'http://192.0.2.20:8765', 'source URL derivation');
    Check((lRequest.ClaimId = 'one') and lRequest.Force and not lRequest.Release,
      'claim fields');
    Check(not lProbe.TakeControlRequest(lRequest), 'duplicate queued twice');
    lProbe.Feed('coordinator.release', 'recorder-1', 'one', 'test-token', 8765);
    Check(lProbe.TakeControlRequest(lRequest) and lRequest.Release, 'release');
    for lIndex := 1 to 40 do
      lProbe.Feed('coordinator.claim', 'recorder-1', IntToStr(lIndex), 'test-token', 8765);
    lCount := 0;
    while lProbe.TakeControlRequest(lRequest) do Inc(lCount);
    Check(lCount = 16, 'incoming queue must be bounded');
    WriteLn('RESULT CoordinatorDiscoveryClaimTest passed');
  finally
    lProbe.Free;
  end;
end.
