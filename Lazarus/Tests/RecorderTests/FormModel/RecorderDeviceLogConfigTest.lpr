program RecorderDeviceLogConfigTest;
{$mode objfpc}{$H+}
uses SysUtils, uRecorderMeraPaths, uRecorderDebugLog;
begin
  if (ParamCount < 3) or
     not SameText(ExpandFileName(ParamStr(2)), RecorderAppConfigFileName) then
    raise Exception.Create('Pass mode, isolated config path and /cfg: path');
  if ParamStr(1) = 'write' then
  begin
    if FileExists(RecorderAppConfigFileName) then
      raise Exception.Create('Test config already exists');
    if not DeviceLogEnabled then raise Exception.Create('Default must be enabled');
    SetDeviceLogEnabled(False);
  end
  else if ParamStr(1) = 'read' then
  begin
    if DeviceLogEnabled then raise Exception.Create('Saved setting was not loaded');
    SetDeviceLogEnabled(True);
  end
  else if ParamStr(1) = 'verify' then
  begin
    if not DeviceLogEnabled then raise Exception.Create('Updated setting was not loaded');
  end
  else raise Exception.Create('Invalid mode');
  WriteLn('OK: device logging configuration ', ParamStr(1));
end.
