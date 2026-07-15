program McbusPreviewSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}
{$R ../../../RecorderLnx/Device/MCbus/resources/mcbus.rc}

uses
  Interfaces, SysUtils, Variants,
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uRecorderMcbusDevice;

function ParamValue(const APrefix, ADefault: string): string;
var
  I: Integer;
begin
  Result := ADefault;
  for I := 1 to ParamCount do
    if Pos(APrefix, ParamStr(I)) = 1 then
      Exit(Copy(ParamStr(I), Length(APrefix) + 1, MaxInt));
end;

var
  lBlock: TRecorderAcquisitionBlock;
  lBlocks, lDurationMs, lExpected, lPort, lTotalSamples, lUpdateMs: Integer;
  lDevice: IRecorderDevice;
  lHost: string;
  lNextTick, lNow, lStart: QWord;
begin
  lHost := ParamValue('--host=', '192.169.12.87');
  lPort := StrToIntDef(ParamValue('--port=', '4000'), 4000);
  lDurationMs := StrToIntDef(ParamValue('--seconds=', '3'), 3) * 1000;
  lUpdateMs := StrToIntDef(ParamValue('--update-ms=', '200'), 200);
  lExpected := lDurationMs div lUpdateMs;
  lBlocks := 0;
  lTotalSamples := 0;
  lDevice := CreateRecorderMcbusDevice;
  try
    lDevice.TrySetDeviceProperty(rdpHost, lHost);
    lDevice.TrySetDeviceProperty(rdpPort, lPort);
    lDevice.TrySetDeviceProperty(rdpPollFrequencyHz, 57600.0);
    lDevice.TrySetDeviceProperty(rdpUpdateTimeMs, lUpdateMs);
    Writeln(Format('SMOKE connect=%s:%d durationMs=%d updateMs=%d expected=%d',
      [lHost, lPort, lDurationMs, lUpdateMs, lExpected]));
    lDevice.Connect;
    lDevice.ProgramDevice;
    lDevice.Start;
    lStart := GetTickCount64;
    lNextTick := lStart;
    while GetTickCount64 - lStart < QWord(lDurationMs) do
    begin
      if lDevice.ReadBlock(Cardinal(lUpdateMs * 4), lBlock) then
      begin
        Inc(lBlocks);
        Inc(lTotalSamples, lBlock.SampleCount);
        Writeln(Format('SMOKE block=%d channels=%d samples=%d elapsedMs=%d',
          [lBlocks, lBlock.ChannelCount, lBlock.SampleCount,
           GetTickCount64 - lStart]));
      end;
      Inc(lNextTick, lUpdateMs);
      lNow := GetTickCount64;
      if lNextTick > lNow then
        Sleep(lNextTick - lNow);
    end;
    lDevice.Stop;
    Writeln(Format('RESULT McbusPreviewSmoke blocks=%d expected=%d samplesPerChannel=%d expectedSamples=%d rate=%.2f/s stopState=%d',
      [lBlocks, lExpected, lTotalSamples, 57600 * lDurationMs div 1000,
       lBlocks * 1000.0 / lDurationMs,
       Ord(lDevice.State)]));
    if (lBlocks = lExpected) and
      (lTotalSamples = 57600 * lDurationMs div 1000) and
      (lDevice.State <> rdsStarted) then
      Halt(0)
    else
      Halt(2);
  except
    on E: Exception do
    begin
      Writeln('RESULT McbusPreviewSmoke failed: ' + E.Message);
      Halt(1);
    end;
  end;
end.
