program CoordinatorHostActionsTest;
{$mode objfpc}{$H+}
uses SysUtils, fpjson, uCoordinatorModel;
procedure Check(B: Boolean; const S: string);
begin if not B then raise Exception.Create(S); end;
var M: TCoordinatorModel; J, R: TJSONObject; P: string;
begin
  P := GetTempDir + 'rcpanel-host-actions-test.ini';
  DeleteFile(P);
  M := TCoordinatorModel.Create;
  try
    M.EnableHostPersistence(P);
    J := TJSONObject.Create;
    try
      J.Add('instance_id', 'host1'); J.Add('remote_address', '192.168.9.200');
      R := M.RegisterHello(J); R.Free;
    finally J.Free; end;
    J := TJSONObject.Create;
    try
      J.Add('instance_id', 'host1'); J.Add('command', 'recording.start');
      R := M.EnqueueCommand(J);
      try Check(R.Get('command_id', '') <> '', 'default allows start'); finally R.Free; end;
    finally J.Free; end;
    Check(M.SetHostActions('host1', False, False, False), 'set options');
    R := M.NextCommand('host1');
    try Check(R.Get('result_code', '') = 'noCommand', 'pending start cancelled'); finally R.Free; end;
    J := TJSONObject.Create;
    try
      J.Add('instance_id', 'host1'); J.Add('command', 'recording.start');
      R := M.EnqueueCommand(J);
      try Check(R.Get('result_code', '') = 'disabled', 'direct start blocked'); finally R.Free; end;
    finally J.Free; end;
    J := TJSONObject.Create;
    try
      J.Add('instance_id', '*'); J.Add('command', 'recording.start');
      R := M.EnqueueCommand(J);
      try Check(R.Get('queued_count', -1) = 0, 'broadcast start blocked'); finally R.Free; end;
    finally J.Free; end;
  finally M.Free; end;
  M := TCoordinatorModel.Create;
  try
    M.EnableHostPersistence(P);
    R := M.HostByIdJson('host1');
    try
      Check(not R.Get('allow_recording', True), 'recording persisted');
      Check(not R.Get('allow_shutdown', True), 'shutdown persisted');
      Check(not R.Get('allow_launch', True), 'launch persisted');
    finally R.Free; end;
  finally M.Free; DeleteFile(P); end;
  WriteLn('Host action settings OK');
end.
