program mic140_clock_test;
{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

uses
  SysUtils, Math, uMic140Device;

const
  CHost = '192.168.14.155';
  CPort = 4000;

procedure DiagCountAver;
{ Подробный расчёт count_aver с промежуточными значениями. }
var
  Prog: TMic140_48;
  Dev: TRecorderMic140Device;
  Freqs: array[0..12] of Double = (1, 2, 5, 10, 9.875, 20, 19.75,
    25, 24.6875, 50, 49.375, 100, 98.75);
  F: Double;
  I: Integer;
begin
  WriteLn('=== count_aver diagnostic (Fclk=16 MHz, 48 AIn + 3 TIn) ===');
  Dev := TRecorderMic140Device.Create;
  try
    WriteLn(Format('Default object: Fs(ch)=%.6f Hz  count_aver=%d',
      [Dev.ScanProgram.Timing.FrequencyHz,
       Dev.ScanProgram.Timing.AverageSampleCount]));
  finally
    Dev.Free;
  end;
  WriteLn;
  WriteLn('Fs(ch)  NCh  Ground  Divider  TimerFs     TPer(ch ms)  count_aver  PeriodDecay(us)');
  WriteLn('------  ---  ------  -------  ----------  -----------  ----------  ---------------');

  for I := 0 to High(Freqs) do
  begin
    F := Freqs[I];

    { === Вариант 1: AllChannels=True, Ground=False (текущий default) === }
    Mic140InitScanProgram48(Prog, F);
    Prog.Flags.ChannelGround := False;
    Mic140EvalAverageSampleCount(Prog);
    WriteLn(Format('%6.1f  %3d  %6s  %7d  %10.6f  %11.6f  %10d  %15.3f',
      [F,
       Prog.ChanDump.VisibleAInCount + Length(Prog.TInChannels),
       'No',
       Prog.Mc114.ScanDivider,
       Prog.Mc114.ActualFrequencyHz,
       1000.0 / Prog.Timing.FrequencyHz,
       Prog.Timing.AverageSampleCount,
       Prog.Timing.PeriodDecayUs]));

    if SameValue(F, 10.0, 0.000001) then
    begin
      Prog.Timing.PeriodDecayUs := 200.0;
      Mic140EvalAverageSampleCount(Prog);
      WriteLn(Format('%6.3f  %3d  %6s  %7d  %10.6f  %11.6f  %10d  %15.3f',
        [F,
         Prog.ChanDump.VisibleAInCount + Length(Prog.TInChannels),
         'No',
         Prog.Mc114.ScanDivider,
         Prog.Mc114.ActualFrequencyHz,
         1000.0 / Prog.Timing.FrequencyHz,
         Prog.Timing.AverageSampleCount,
         Prog.Timing.PeriodDecayUs]));
    end;

    { === Вариант 2: AllChannels=True, Ground=True (как legacy) === }
    Mic140InitScanProgram48(Prog, F);
    Prog.Flags.ChannelGround := True;
    Mic140EvalAverageSampleCount(Prog);
    WriteLn(Format('%6.1f  %3d  %6s  %7d  %10.6f  %11.6f  %10d  %15.3f',
      [F,
       (Prog.ChanDump.VisibleAInCount + Length(Prog.TInChannels)) * 2,
       'Yes',
       Prog.Mc114.ScanDivider,
       Prog.Mc114.ActualFrequencyHz,
       1000.0 / Prog.Timing.FrequencyHz,
       Prog.Timing.AverageSampleCount,
       Prog.Timing.PeriodDecayUs]));
  end;
end;

var
  Conn: TMic140MdpConnection;
  TestR: array[0..1] of Word;
  Reply: array[0..10] of Word;
  TC, RC: Integer;
  TestArgs: array[0..1] of Word;
  Clk: TMic140ClockMeasureResult;
begin
  DiagCountAver;

  WriteLn;
  WriteLn('=== MIC140 Device Test ===');
  WriteLn('Target: ', CHost, ':', CPort);
  Conn := TMic140MdpConnection.Create;
  try
    if not Conn.Open(CHost, CPort) then
    begin WriteLn('  connect failed (device offline?)'); Halt(0); end;
    WriteLn('  Connected');

    TestArgs[0] := 0; TestArgs[1] := 0;
    Conn.CallCommandArgs(MIC140_CMD_TEST_LOAD, TestArgs, 2, TestR, TC);

    FillChar(Reply, SizeOf(Reply), 0);
    Conn.CallCommand(MIC140_CMD_REPLY, 11, Reply, RC);
    WriteLn('  Firmware: sig=$', IntToHex(Reply[0], 4),
      ' dev=', Reply[2], ' rev=', Reply[3], ' ser=', Reply[4]);

    if Conn.ResolveDeviceTiming(0, 639, 5000, Clk) then
    begin
      Write('  Method: ');
      case Clk.Method of
        mcmMeasureFreqModule: WriteLn('CMD12 (PCI)');
        mcmNominal:           WriteLn('Nominal 16 MHz');
        else                  WriteLn('?');
      end;
      WriteLn('  Fclk = ', Clk.ModuleClockHz/1e6:0:6, ' MHz');
      WriteLn('  Fs   = ', Clk.ActualFrequencyHz:0:6, ' Hz');
    end;

    Conn.Close;
  finally
    Conn.Free;
  end;
  WriteLn;
  WriteLn('=== Done ===');
end.
