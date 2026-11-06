program CoordinatorLocalDiscoveryTest;
{$mode objfpc}{$H+}
{ Run only with --isolated-network in a dedicated network namespace. }
uses {$IFDEF UNIX}cthreads,{$ENDIF} Classes, SysUtils, uRecorderLanDiscovery;
type
  TObserver = class
    Found: Boolean;
    SourceAddress: string;
    procedure Peer(const Id, DisplayName, Address, Url, Macs: string);
  end;
procedure TObserver.Peer(const Id, DisplayName, Address, Url, Macs: string);
begin
  if Id = 'test-local-recorder' then begin Found := True; SourceAddress := Address end;
end;
procedure TestOrder(RecorderFirst: Boolean);
var
  Panel, Recorder: TRecorderLanDiscovery;
  Observer: TObserver;
  Request: TRecorderCoordinatorControlRequest;
  I: Integer;
  Got: Boolean;
begin
  Observer := TObserver.Create;
  Panel := TRecorderLanDiscovery.Create(rdrCoordinator, 'test-panel', 'panel', 18765, '', '127.0.0.2');
  Recorder := TRecorderLanDiscovery.Create(rdrRecorder, 'test-local-recorder', 'recorder', 0, '', '127.0.0.2');
  try
    Panel.OnFound := @Observer.Peer;
    if RecorderFirst then begin Recorder.Start; Sleep(500); Panel.Start end
    else begin Panel.Start; Sleep(500); Recorder.Start end;
    for I := 1 to 40 do begin if Observer.Found then Break; Sleep(200) end;
    if not Observer.Found then raise Exception.Create('Local discovery failed');
    Panel.RequestClaim('127.0.0.2', 'test-local-recorder', 'claim', False);
    Got := False;
    for I := 1 to 40 do begin if Recorder.TakeControlRequest(Request) then begin Got := True; Break end; Sleep(200) end;
    if not Got then raise Exception.Create('Local claim failed');
    if Request.Force then raise Exception.Create('Unexpected force takeover');
    if Pos('http://127.', Request.CoordinatorUrl) <> 1 then raise Exception.Create('Invalid source URL');
    WriteLn('PASS local discovery and claim, recorder first=', RecorderFirst);
  finally
    Recorder.Free; Panel.Free; Observer.Free;
  end;
end;
begin
  if (ParamCount <> 1) or (ParamStr(1) <> '--isolated-network') then
    raise Exception.Create('Run only with --isolated-network in a dedicated network namespace');
  TestOrder(False);
  TestOrder(True);
end.
