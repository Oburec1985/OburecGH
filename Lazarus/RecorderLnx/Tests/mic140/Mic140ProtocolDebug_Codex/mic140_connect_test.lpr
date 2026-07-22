program mic140_connect_test;
{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

uses
  SysUtils, Variants,
  uRecorderDeviceInterfaces,
  uRecorderDeviceManager,
  uMic140Device,
  uMic140Registration;

var
  iDev: IRecorderDevice;
  lObj: TObject;
  Dev: TRecorderMic140Device;
begin
  WriteLn('=== Connect flow test (same as FindAndConnect) ===');
  iDev := nil;
  try
    iDev := RecorderDeviceManager.Search('MIC140');
    if iDev = nil then
    begin WriteLn('Search returned nil'); Halt(1); end;
    WriteLn('Search OK: host=', VarToStr(iDev.GetDeviceProperty(rdpHost)),
      ' port=', Integer(iDev.GetDeviceProperty(rdpPort)));

    lObj := iDev.GetNativeObject;
    if not (lObj is TRecorderMic140Device) then
    begin WriteLn('Not TRecorderMic140Device'); Halt(1); end;
    Dev := TRecorderMic140Device(lObj);

    WriteLn('Calling Connect...');
    Dev.Connect;
    WriteLn('Connect OK, state=', Ord(Dev.State));

    Dev.TrySetDeviceProperty(rdpPollFrequencyHz, 10.0);
    Dev.TrySetDeviceProperty(rdpChannelCount, 48);
    WriteLn('count_aver=', Dev.ScanProgram.Timing.AverageSampleCount);
    WriteLn('Fclk=', Dev.ClockMeasure.ModuleClockHz/1e6:0:3, ' MHz');
    WriteLn('Fs(timer)=', Dev.ScanProgram.Mc114.ActualFrequencyHz:0:6, ' Hz');
  except
    on E: Exception do
    begin
      WriteLn('EXCEPTION: ', E.ClassName, ': ', E.Message);
      Halt(2);
    end;
  end;
end.
