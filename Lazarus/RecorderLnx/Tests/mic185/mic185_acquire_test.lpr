program mic185_acquire_test;

{
  Стенд MIC183/185: connect, program, start, read тензоканалов.
  Usage:
    mic185_acquire_test [host] [port] [meas_fs_hz] [blocks]
  Defaults: 192.168.9.142 4000 100 5
  Каналы: 64 тензо + 5 темп. + 1 СЕВ (как в Recorder).
}

{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

uses
  SysUtils, Variants,
  uRecorderAcquisitionTypes,
  uRecorderDeviceInterfaces,
  uRecorderDeviceManager,
  uMic185Device,
  uMic185Registration,
  uMic185MebiusTypes, uMic185Constants, uMic185DebugLog, uMic185CodeVerify;

var
  iDev: IRecorderDevice;
  lObj: TObject;
  Dev: TRecorderMic185Device;
  lBlock: TRecorderAcquisitionBlock;
  lHost: string;
  lPort,   lBlocks: Integer;
  lMeasFs: Double;
  lSniff: Boolean;
  lVerify: Boolean;
  lArgBase: Integer;
  B: Integer;
  lReport: string;
  lLastBlock: TRecorderAcquisitionBlock;
  lHasBlock: Boolean;

procedure Usage;
begin
  WriteLn('Usage: mic185_acquire_test [options] [host] [port] [meas_fs_hz] [blocks]');
  WriteLn('Options: -sniff  -verify-codes');
  WriteLn('Channels fixed: 64 tenzo + 5 temp + 1 UTS (rdpChannelCount=70)');
  WriteLn('Default: 192.168.9.142 4000 100 5');
end;

begin
  Randomize;
  Mic185LogInit('');
  lHost := '192.168.9.142';
  lPort := 4000;
  lMeasFs := CMic185DefaultMeasFrequencyHz;
  lBlocks := 5;
  lSniff := False;
  lVerify := False;
  lArgBase := 1;
  lHasBlock := False;

  if (ParamCount > 0) and ((ParamStr(1) = '-h') or (ParamStr(1) = '--help')) then
  begin
    Usage;
    Exit;
  end;
  while (lArgBase <= ParamCount) and (ParamStr(lArgBase)[1] = '-') do
  begin
    if ParamStr(lArgBase) = '-sniff' then
      lSniff := True
    else if ParamStr(lArgBase) = '-verify-codes' then
      lVerify := True
    else
    begin
      WriteLn('Unknown option: ', ParamStr(lArgBase));
      Halt(1);
    end;
    Inc(lArgBase);
  end;
  if ParamCount >= lArgBase then lHost := ParamStr(lArgBase);
  if ParamCount >= lArgBase + 1 then lPort := StrToIntDef(ParamStr(lArgBase + 1), lPort);
  if ParamCount >= lArgBase + 2 then lMeasFs := StrToFloatDef(ParamStr(lArgBase + 2), lMeasFs);
  if ParamCount >= lArgBase + 3 then lBlocks := StrToIntDef(ParamStr(lArgBase + 3), lBlocks);

  WriteLn('=== MIC183/185 acquire test ===');
  Mic185Log('CLI test started');
  WriteLn('Log: ', Mic185LogFilePath);
  WriteLn('settings blob size = ', SizeOf(TMic185BaseSettings));
  WriteLn('target: ', lHost, ':', lPort,
    ' logicalCh=', CMic185TotalLogicalChannelCount,
    ' measFs=', lMeasFs:0:1, ' blocks=', lBlocks);

  iDev := nil;
  try
    iDev := RecorderDeviceManager.Search('MIC183/185');
    if iDev = nil then
    begin
      WriteLn('Search MIC183/185 returned nil');
      Halt(1);
    end;

    iDev.TrySetDeviceProperty(rdpHost, lHost);
    iDev.TrySetDeviceProperty(rdpPort, lPort);
    iDev.TrySetDeviceProperty(rdpChannelCount, CMic185TotalLogicalChannelCount);
    iDev.TrySetDeviceProperty(rdpPollFrequencyHz, lMeasFs);

    lObj := iDev.GetNativeObject;
    if not (lObj is TRecorderMic185Device) then
    begin
      WriteLn('Native object is not TRecorderMic185Device');
      Halt(1);
    end;
    Dev := TRecorderMic185Device(lObj);

    WriteLn('Channels: meas=', Dev.MeasChannelCount,
      ' temp=', Dev.TempChannelCount, ' uts=', Ord(Dev.UtsEnabled),
      ' total=', Integer(iDev.GetDeviceProperty(rdpChannelCount)));

    WriteLn('Connect...');
    Dev.Connect;
    WriteLn('Connected. s/n=', Dev.DeviceSerial,
      ' version=', Mic185FormatSoftVersion(Dev.SoftVersion));

    WriteLn('Program...');
    Dev.ProgramDevice;
    WriteLn('Programmed, state=', Ord(Dev.State));

    WriteLn('Start...');
    Dev.Start;
    WriteLn('Started. ReadBlock: meas=', Dev.MeasChannelCount,
      ' + temp/UTS when packets arrive.');

    for B := 1 to lBlocks do
    begin
      if Dev.ReadBlock(3000, lBlock) then
      begin
        lLastBlock := lBlock;
        lHasBlock := True;
        WriteLn(Format('Block %d: samples=%d ch=%d t0=%.3f',
          [B, lBlock.SampleCount, lBlock.ChannelCount, lBlock.FirstTimeSec]));
        if (lBlock.ChannelCount > 0) and (lBlock.SampleCount > 0) then
        begin
          WriteLn(Format('  ch1=%d ch6=%d ch32=%d ch48=%d',
            [Round(lBlock.Values[0][lBlock.SampleCount - 1]),
             Round(lBlock.Values[5][lBlock.SampleCount - 1]),
             Round(lBlock.Values[31][lBlock.SampleCount - 1]),
             Round(lBlock.Values[47][lBlock.SampleCount - 1])]));
        end;
        if Dev.HasTempData then
          WriteLn(Format('  temp[1]=%.3f uts=%.3f',
            [Dev.LastTempValue(0), Dev.LastUts]));
      end
      else
        WriteLn('Block ', B, ': timeout or no data');
    end;

    if lVerify and lHasBlock then
    begin
      WriteLn('--- Verify ADC codes vs Recorder reference ---');
      if Mic185VerifyBlockCodes(lLastBlock, lLastBlock.SampleCount - 1, lReport) then
        WriteLn(lReport)
      else
      begin
        WriteLn(lReport);
        Halt(3);
      end;
    end;

    if lSniff then
    begin
      WriteLn('Post-read sniff 3 packets...');
      WriteLn('Sniff got ', Dev.SniffPackets(3, 2000), ' packets');
    end;

    WriteLn('Stop...');
    Dev.Stop;
    Dev.Disconnect;
    WriteLn('Done.');
  except
    on E: Exception do
    begin
      WriteLn('EXCEPTION: ', E.ClassName, ': ', E.Message);
      Halt(2);
    end;
  end;
end.
