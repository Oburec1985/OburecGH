program PxiMx248BridgeProcessSmoke;

{$mode objfpc}{$H+}

uses
  SysUtils, uRecorderDriverContractsV2, uRecorderPxiMx248WindowsTransport;

var
  lBridgePath: string;
  lChassis, lSlot: Integer;
  lTransport: TRecorderPxiMx248WindowsTransport;
  lResult: TRecorderOperationResult;
begin
  if (ParamCount < 1) or not FileExists(ParamStr(1)) then
  begin
    WriteLn('Usage: PxiMx248BridgeProcessSmoke <bridge.exe> [chassis] [slot]');
    Halt(2);
  end;
  lBridgePath := ExpandFileName(ParamStr(1));
  lChassis := 0;
  lSlot := 0;
  if (ParamCount >= 2) and not TryStrToInt(ParamStr(2), lChassis) then Halt(2);
  if (ParamCount >= 3) and not TryStrToInt(ParamStr(3), lSlot) then Halt(2);
  lTransport := TRecorderPxiMx248WindowsTransport.Create(lChassis, lSlot,
    lBridgePath, 5000);
  try
    lResult := lTransport.CheckBridge;
    if not lResult.IsSuccess then
    begin
      WriteLn('RESULT PXI MX-248 bridge process smoke failed: ',
        lResult.Stage, ': ', lResult.MessageText);
      Halt(1);
    end;
  finally
    { A successful CheckBridge leaves the child alive; destruction verifies
      the bounded SHUTDOWN path rather than abandoning the process. }
    lTransport.Free;
  end;
  WriteLn('RESULT PXI MX-248 bridge process smoke passed');
end.
