unit uCoordinatorHostMonitor;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Process, fpjson, uCoordinatorModel;

type
  TCoordinatorHostMonitor = class(TThread)
  private
    fModel: TCoordinatorModel;
    function PingHost(const AAddress: string): Boolean;
    function WaitUntilNextCycle(AMilliseconds: Cardinal): Boolean;
    procedure ProbeHosts;
  protected
    procedure Execute; override;
  public
    constructor Create(AModel: TCoordinatorModel);
  end;

implementation

constructor TCoordinatorHostMonitor.Create(AModel: TCoordinatorModel);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fModel := AModel;
end;

function TCoordinatorHostMonitor.PingHost(const AAddress: string): Boolean;
var
  lProcess: TProcess;
begin
  Result := False;
  if Trim(AAddress) = '' then Exit;
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := 'ping';
    {$IFDEF WINDOWS}
    lProcess.Parameters.Add('-n');
    lProcess.Parameters.Add('1');
    lProcess.Parameters.Add('-w');
    lProcess.Parameters.Add('1000');
    {$ELSE}
    lProcess.Parameters.Add('-c');
    lProcess.Parameters.Add('1');
    lProcess.Parameters.Add('-W');
    lProcess.Parameters.Add('1');
    {$ENDIF}
    lProcess.Parameters.Add(AAddress);
    lProcess.Options := [poWaitOnExit, poNoConsole];
    try
      lProcess.Execute;
      Result := lProcess.ExitStatus = 0;
    except
      Result := False;
    end;
  finally
    lProcess.Free;
  end;
end;

function TCoordinatorHostMonitor.WaitUntilNextCycle(
  AMilliseconds: Cardinal): Boolean;
const
  CStepMs = 100;
var
  lWaited: Cardinal;
begin
  lWaited := 0;
  while (not Terminated) and (lWaited < AMilliseconds) do
  begin
    Sleep(CStepMs);
    Inc(lWaited, CStepMs);
  end;
  Result := not Terminated;
end;

procedure TCoordinatorHostMonitor.ProbeHosts;
var
  lAddress: string;
  lIndex: Integer;
  lTargets: TJSONArray;
begin
  lTargets := fModel.HostProbeTargets;
  try
    for lIndex := 0 to lTargets.Count - 1 do
    begin
      if Terminated then Exit;
      lAddress := lTargets.Objects[lIndex].Get('address', '');
      fModel.MarkPcReachabilityChecking(lAddress);
      fModel.ApplyPcReachability(lAddress, PingHost(lAddress), Now);
    end;
  finally
    lTargets.Free;
  end;
end;

procedure TCoordinatorHostMonitor.Execute;
begin
  while not Terminated do
  begin
    ProbeHosts;
    if not WaitUntilNextCycle(5000) then Exit;
  end;
end;

end.
