program PxiMx248Bridge;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  uPxiMx248BridgeProtocol in 'Source\uPxiMx248BridgeProtocol.pas',
  uPxiMx248DevApi in 'Source\uPxiMx248DevApi.pas';

var Input, Output: THandleStream; H: TBridgeHeader; Payload: TBytes;
  ErrorText, VendorDir, DataText: string; Api: TDevApiBinding; Running, ApiReady: Boolean;
  DevResult: Cardinal; DeviceIndex,CrateSerial,SlotNo: Integer;
  BlockData: TBytes; BlockText: AnsiString;
  Config: TMx248ConfigureV1;
begin
  ExitCode := 1;
  Api := TDevApiBinding.Create;
  Input := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  Output := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
  try
    VendorDir := GetEnvironmentVariable('RECORDER_MX248_VENDOR_DIR');
    if VendorDir = '' then
      VendorDir := ExtractFilePath(ParamStr(0));
    ApiReady := (VendorDir <> '') and Api.Load(VendorDir);
    Running := True;
    while Running and ReadFrame(Input, H, Payload, ErrorText) do begin
      case H.Command of
        Ord(bcHello): WriteResult(Output, H, brOk, 'bridge.hello', '',
          'protocol=1;arch=x86;max_payload=1048576');
        Ord(bcStatus):
          if ApiReady then WriteResult(Output, H, brOk, 'bridge.status', '', 'devapi=ready')
          else WriteResult(Output, H, brDevApi, 'bridge.status', Api.Missing, 'devapi=unavailable');
        Ord(bcDiscover): begin
          if not ApiReady then DevResult:=Cardinal(-1) else DevResult:=Api.Discover(DataText);
          if DevResult=0 then WriteResult(Output,H,brOk,'mx248.discover','',
            RawByteString(UTF8String(DataText)))
          else WriteResult(Output,H,brDevApi,'mx248.discover',IntToStr(DevResult),'');
        end;
        Ord(bcConnect): begin
          if not (Length(Payload) in [4,8]) then
            WriteResult(Output,H,brBadFrame,'mx248.connect','expected legacy index:i32 or CCSN:i32,slot:i32','')
          else begin
            if Length(Payload)=4 then begin
              Move(Payload[0],DeviceIndex,4); DevResult:=Api.Open(DeviceIndex)
            end else begin
              Move(Payload[0],CrateSerial,4); Move(Payload[4],SlotNo,4);
              DevResult:=Api.OpenRoute(CrateSerial,SlotNo)
            end;
            if DevResult=0 then WriteResult(Output,H,brOk,'mx248.connect','','')
            else WriteResult(Output,H,brDevApi,'mx248.connect',IntToStr(DevResult),'') end;
        end;
        Ord(bcInitialize): begin
          DevResult:=Api.Identity(DataText);
          if DevResult=0 then WriteResult(Output,H,brOk,'mx248.initialize','',
            RawByteString(UTF8String(DataText)))
          else WriteResult(Output,H,brDevApi,'mx248.initialize',IntToStr(DevResult),'')
        end;
        Ord(bcTest): begin
          DevResult:=Api.TestDevice;
          if DevResult=0 then WriteResult(Output,H,brOk,'mx248.test','','')
          else WriteResult(Output,H,brDevApi,'mx248.test',IntToStr(DevResult),'')
        end;
        Ord(bcConfigure): begin
          if not DecodeConfigureV1(Payload,Config,ErrorText) then
            WriteResult(Output,H,brBadFrame,'mx248.configure',ErrorText,'')
          else begin
            DevResult:=Api.Configure(Config);
            if DevResult=0 then WriteResult(Output,H,brOk,'mx248.configure','','')
            else WriteResult(Output,H,brDevApi,'mx248.configure',IntToStr(DevResult),'')
          end
        end;
        Ord(bcStart): begin DevResult:=Api.Start;
          if DevResult=0 then WriteResult(Output,H,brOk,'mx248.start','','')
          else WriteResult(Output,H,brDevApi,'mx248.start',IntToStr(DevResult),'') end;
        Ord(bcStop): begin DevResult:=Api.Stop;
          if DevResult=0 then WriteResult(Output,H,brOk,'mx248.stop','','')
          else WriteResult(Output,H,brDevApi,'mx248.stop',IntToStr(DevResult),'') end;
        Ord(bcDisconnect): begin Api.Close; WriteResult(Output,H,brOk,'mx248.disconnect','','') end;
        Ord(bcReadBlock): begin
          if Length(Payload)<>SizeOf(DeviceIndex) then
            WriteResult(Output,H,brBadFrame,'mx248.read','expected Int32 sample count','')
          else begin
            Move(Payload[0],DeviceIndex,4); DevResult:=Api.ReadBlock(DeviceIndex,BlockData);
            if DevResult=0 then begin
              SetString(BlockText,PAnsiChar(@BlockData[0]),Length(BlockData));
              WriteResult(Output,H,brOk,'mx248.read','',RawByteString(BlockText));
            end else WriteResult(Output,H,brDevApi,'mx248.read',IntToStr(DevResult),'');
          end;
        end;
        Ord(bcShutdown): begin WriteResult(Output, H, brOk, 'bridge.shutdown', '', ''); Running := False end;
      else
        WriteResult(Output, H, brUnsupported, 'bridge.abi',
          'TDevice/TDeviceEnum and channel ABI is not yet verified; unsafe DevAPI call refused', '');
      end;
    end;
    ExitCode := 0;
  finally Output.Free; Input.Free; Api.Free end;
end.
