program PxiMx248DevApiAbiSmoke;
{$APPTYPE CONSOLE}
uses System.SysUtils,
  uPxiMx248BridgeProtocol in '..\Source\uPxiMx248BridgeProtocol.pas',
  uPxiMx248DevApi in '..\Source\uPxiMx248DevApi.pas';
var Api: TDevApiBinding; P: string;
begin
  P := GetEnvironmentVariable('RECORDER_MX248_VENDOR_DIR');
  if P='' then P := 'C:\Program Files (x86)\Mera\Recorder';
  Api := TDevApiBinding.Create;
  try
    if not Api.Load(P) then raise Exception.Create('DevAPI ABI smoke: '+Api.Missing);
    Writeln('RESULT PXI MX-248 DevAPI ABI exports passed');
  finally Api.Free end;
end.
