program CoordinatorClaimSessionTest;

{$mode objfpc}{$H+}

uses SysUtils, fpjson, uCoordinatorModel, uCoordinatorConfig;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

procedure Hello(AModel: TCoordinatorModel; const AOwner, AClaim: string);
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', 'recorder-test');
    lData.Add('remote_address', '192.0.2.10');
    lData.Add('coordinator_instance_id', AOwner);
    lData.Add('coordinator_claim_id', AClaim);
    lResult := AModel.RegisterHello(lData);
    lResult.Free;
  finally
    lData.Free;
  end;
end;

function Queue(AModel: TCoordinatorModel): TJSONObject;
var
  lData: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', 'recorder-test');
    lData.Add('command', 'recording.preview');
    Result := AModel.EnqueueCommand(lData);
  finally
    lData.Free;
  end;
end;

var
  lModel: TCoordinatorModel;
  lResult: TJSONObject;
  lConfig, lReload: TCoordinatorConfig;
  lPath, lId: string;
begin
  lModel := TCoordinatorModel.Create;
  try
    lModel.ControlId := 'panel-A';
    Hello(lModel, 'panel-B', 'claim-B');
    lResult := Queue(lModel);
    try Check(lResult.Get('result_code', '') = 'notOwner',
      'foreign-owned Recorder accepted a command'); finally lResult.Free; end;
    Hello(lModel, 'panel-A', 'claim-1');
    lResult := Queue(lModel);
    try Check(lResult.Get('coordinator_claim_id', '') = 'claim-1',
      'command did not snapshot the claim'); finally lResult.Free; end;
    Hello(lModel, 'panel-A', 'claim-2');
    lResult := lModel.NextCommand('recorder-test');
    try Check(lResult.Get('result_code', '') = 'noCommand',
      'old claim command crossed into a new session'); finally lResult.Free; end;
    lResult := Queue(lModel); lResult.Free;
    lResult := lModel.NextCommand('recorder-test');
    try Check(lResult.Get('coordinator_claim_id', '') = 'claim-2',
      'current claim command was not delivered'); finally lResult.Free; end;
    lModel.ApplyControlOwner('recorder-test', 'panel-B', 'claim-B');
    lResult := lModel.HostByIdJson('recorder-test');
    try Check(not lResult.Get('recorder_reachable', True),
      'discovery ownership change left old HTTP session reachable');
    finally lResult.Free; end;
    lResult := lModel.NextCommand('recorder-test');
    try Check(lResult.Get('result_code', '') = 'notOwner',
      'old panel could poll after transfer'); finally lResult.Free; end;
  finally
    lModel.Free;
  end;
  lPath := IncludeTrailingPathDelimiter(GetTempDir) +
    'coordinator-claim-config-' + IntToStr(GetProcessID) + '.ini';
  lConfig := TCoordinatorConfig.Create(lPath);
  try
    lConfig.Load;
    lId := lConfig.CoordinatorId;
    Check(lId <> '', 'missing panel identity');
    lReload := TCoordinatorConfig.Create(lPath);
    try
      lReload.Load;
      Check(lReload.CoordinatorId = lId, 'panel identity changed on restart');
    finally lReload.Free; end;
  finally
    lConfig.Free;
    DeleteFile(lPath);
  end;
  WriteLn('RESULT Coordinator claim session tests passed');
end.
