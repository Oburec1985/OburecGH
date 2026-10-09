program PxiMx248WindowsTransportTest;

{$mode objfpc}{$H+}

uses
  SysUtils, uRecorderAcquisitionTypes, uRecorderDriverContractsV2,
  uRecorderPxiMx248Types, uRecorderPxiMx248RuntimeTransport,
  uRecorderPxiMx248WindowsTransport;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure CheckOk(const AResult: TRecorderOperationResult; const AMessage: string);
begin
  Check(AResult.IsSuccess, AMessage + ': ' + AResult.MessageText);
end;

procedure TestCursorAndPoison(const ABridge: string);
var
  lTransport: TRecorderPxiMx248WindowsTransport;
  lConfiguration: TPxiMx248Configuration;
  lBlock: TRecorderAcquisitionBlock;
  lDevices: TPxiMx248DiscoveredDevices;
  lResult: TRecorderOperationResult;
begin
  lTransport := TRecorderPxiMx248WindowsTransport.Create(1, 3, ABridge, 1000);
  try
    PxiMx248DefaultConfiguration(lConfiguration);
    lConfiguration.SampleRateHz := 1000;
    lConfiguration.BlockSamples := 2;
    CheckOk(lTransport.Connect, 'connect');
    CheckOk(lTransport.Discover(lDevices), 'discover');
    Check((Length(lDevices) = 1) and
      (lDevices[0].SerialNumber = 3253) and
      (lDevices[0].Chassis = 2) and (lDevices[0].Slot = 14),
      'discover must decode MX-248 SN=3253 at chassis 2 slot 14');
    CheckOk(lTransport.SetModuleProperties(lConfiguration), 'cache config');
    lResult := lTransport.ProgramAcquisition(lConfiguration);
    Check((not lResult.IsSuccess) and (lResult.Code = rocProtocol),
      'structured bridge error must be returned');
    CheckOk(lTransport.ProgramAcquisition(lConfiguration),
      'structured error must not poison session');
    PreparePxiMx248Block(lBlock, CPxiMx248ChannelCount, 2);
    CheckOk(lTransport.Start, 'start');
    CheckOk(lTransport.ReadBlock(1000, lBlock), 'read 1');
    Check(Abs(lBlock.FirstTimeSec) < 1e-12, 'first cursor must start at zero');
    CheckOk(lTransport.ReadBlock(1000, lBlock), 'read 2');
    Check(Abs(lBlock.FirstTimeSec - 0.002) < 1e-12,
      'second block cursor must be monotonic');
    Check((lBlock.Values[7][0] = -1) and
      (Abs(lBlock.Values[2][0] - 3.5) < 1e-7), 'logical mapping');
    CheckOk(lTransport.Stop, 'stop');
    CheckOk(lTransport.Start, 'restart');
    CheckOk(lTransport.ReadBlock(1000, lBlock), 'read after restart');
    Check(Abs(lBlock.FirstTimeSec) < 1e-12, 'Start must reset cursor');

    lResult := lTransport.TestLink;
    Check((not lResult.IsSuccess) and (lResult.Code = rocProtocol),
      'wrong request id must poison exchange');
    { The previous child is poisoned. No command may silently start a fresh
      process until the owner explicitly closes the lost session. }
    lResult := lTransport.Connect;
    Check((not lResult.IsSuccess) and (lResult.Code = rocTransport),
      'poison must remain sticky until Disconnect');
    lTransport.Disconnect;
    CheckOk(lTransport.Connect, 'connect after explicit disconnect');
  finally
    lTransport.Free;
  end;
end;

var
  lBridge: string;
begin
  try
    lBridge := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'FakePxiMx248Bridge.exe';
    TestCursorAndPoison(lBridge);
    WriteLn('RESULT PXI MX-248 Windows transport passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT PXI MX-248 Windows transport failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
