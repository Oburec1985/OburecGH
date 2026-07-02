unit uMic140AutoRunner;

{
  Headless-запуск стенда: поток сбора + лог + код возврата 0/1.

  Mic140RunAutoTestFromCommandLine — полный разбор аргументов (для --auto в .exe).
  Mic140RunAutoTest — только длительность, конфиг по умолчанию (для Cli.exe).

  Поддерживаемые флаги (после --auto или в GUI ParseCommandLine):
    --auto [N]           длительность в секундах (по умолчанию 3)
    --seconds, -s N      то же
    --range N            rdpMic140RangeIndex для всех AIn (0=80mV)
    --bank2-range N      range только для CH25..48 (-1 = как --range)
    --commut N           commutator index CH01..48 (0=Вход)
    --bank2-commut N     commut только для CH25..48
    --bank2-delay-mul N  множитель задержки ME048 2-го банка (shadow-scan)
    --tin-slots N        0..3 внутренних TIn в BIOS/FIFO (shadow-scan)
    --chan-dump-count N  m_ChanDump[2]: -1=48, 51=как Recorder
    --fifo-stride N      -1=авто(48), 48 или 51
    --recorder-wire      stride=51, chanDump=51, fifoSamples=3 → msgWords=163

  Переменные окружения (альтернатива флагам, см. Driver/uRecorderMic140v2Scan):
    MIC140_DEBUG_TIN_SLOTS, MIC140_DEBUG_BANK2_DELAY_MUL,
    MIC140_DEBUG_CHAN_DUMP_COUNT, MIC140_DEBUG_ME048_V2=1
}

{$mode objfpc}{$H+}

interface

function Mic140RunAutoTest(ADurationSec: Integer): Integer;
function Mic140RunAutoTestFromCommandLine: Integer;
function Mic140TryRunMdpProxyFromCommandLine: Boolean;

implementation

uses
  SysUtils, Classes,
  uRecorderMic140DeviceApi,
  uMic140DebugConfig, uMic140AcceptanceLog, uMic140AcquireThread, uMic140Api,
  uMic140MdpSniffer;

procedure Mic140AutoParseCommandLine(var AConfig: TMic140DebugConfig;
  var ADurationSec: Integer);
var
  lI: Integer;
  lArg: string;
  lArgs: TStringList;
  lParts: TStringArray;
  lPart: string;
begin
  lArgs := TStringList.Create;
  try
    for lI := 1 to ParamCount do
    begin
      lParts := ParamStr(lI).Split([' '], TStringSplitOptions.ExcludeEmpty);
      for lPart in lParts do
        lArgs.Add(lPart);
    end;

    lI := 0;
    while lI < lArgs.Count do
    begin
      lArg := lArgs[lI];
      if SameText(lArg, '--auto') then
      begin
        if (lI + 1 < lArgs.Count) and (Copy(lArgs[lI + 1], 1, 2) <> '--') then
        begin
          ADurationSec := StrToIntDef(lArgs[lI + 1], ADurationSec);
          Inc(lI);
        end;
      end
      else if (SameText(lArg, '--seconds') or SameText(lArg, '-s')) and
        (lI + 1 < lArgs.Count) then
      begin
        ADurationSec := StrToIntDef(lArgs[lI + 1], ADurationSec);
        Inc(lI);
      end
      else if SameText(lArg, '--range') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.RangeIndex := StrToIntDef(lArgs[lI + 1], AConfig.RangeIndex);
        Inc(lI);
      end
      else if SameText(lArg, '--bank2-range') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.Bank2RangeIndex := StrToIntDef(lArgs[lI + 1],
          AConfig.Bank2RangeIndex);
        Inc(lI);
      end
      else if SameText(lArg, '--commut') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.CommutIndex := StrToIntDef(lArgs[lI + 1], AConfig.CommutIndex);
        Inc(lI);
      end
      else if SameText(lArg, '--bank2-commut') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.Bank2CommutIndex := StrToIntDef(lArgs[lI + 1],
          AConfig.Bank2CommutIndex);
        Inc(lI);
      end
      else if SameText(lArg, '--bank2-delay-mul') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.Bank2DelayMul := StrToIntDef(lArgs[lI + 1],
          AConfig.Bank2DelayMul);
        Inc(lI);
      end
      else if SameText(lArg, '--tin-slots') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.TinSlots := StrToIntDef(lArgs[lI + 1], AConfig.TinSlots);
        Inc(lI);
      end
      else if SameText(lArg, '--chan-dump-count') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.ChanDumpCount := StrToIntDef(lArgs[lI + 1],
          AConfig.ChanDumpCount);
        Inc(lI);
      end
      else if SameText(lArg, '--fifo-stride') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.FifoStride := StrToIntDef(lArgs[lI + 1], AConfig.FifoStride);
        Inc(lI);
      end
      else if SameText(lArg, '--recorder-wire') then
        AConfig.RecorderWireProfile := True
      else if SameText(lArg, '--production-scan') then
      begin
        AConfig.ProductionScan := True;
        AConfig.TinSlots := 0;
        AConfig.Bank2DelayMul := 1;
      end
      else if SameText(lArg, '--settle-sec') and (lI + 1 < lArgs.Count) then
      begin
        AConfig.SettleSec := StrToIntDef(lArgs[lI + 1], AConfig.SettleSec);
        Inc(lI);
      end
      else if SameText(lArg, '--no-settle') then
        AConfig.SettleSec := 0;
      Inc(lI);
    end;
  finally
    lArgs.Free;
  end;
end;

function Mic140RunAutoTestWithConfig(const AConfig: TMic140DebugConfig;
  ADurationSec: Integer): Integer;
var
  lApiDev: TMic140Device;
  lMic: IMic140Device;
  lLog: TMic140AcceptanceLog;
  lThread: TMic140AcquireThread;
  lResult: string;
begin
  Result := 1;
  lApiDev := TMic140Device.Create(Mic140ConfigFromDebug(AConfig));
  lMic := lApiDev.Inner;
  lLog := TMic140AcceptanceLog.Create(ExtractFilePath(ParamStr(0)));
  lThread := TMic140AcquireThread.Create(lMic, lLog, AConfig, ADurationSec, False, True);
  try
    lThread.Start;
    lThread.WaitFor;
    lResult := 'FAIL';
    if (lLog.Path <> '') and FileExists(lLog.Path) then
    begin
      with TStringList.Create do
      try
        LoadFromFile(lLog.Path);
        if Count > 0 then
          lResult := Strings[Count - 1];
      finally
        Free;
      end;
    end;
    if Copy(lResult, 1, 4) = 'PASS' then
      Result := 0;
  finally
    lThread.Free;
    lLog.Free;
    lApiDev.Free;
  end;
end;

function Mic140RunAutoTest(ADurationSec: Integer): Integer;
var
  lConfig: TMic140DebugConfig;
begin
  lConfig := Mic140DebugDefaultConfig;
  Result := Mic140RunAutoTestWithConfig(lConfig, ADurationSec);
end;

function Mic140TryRunMdpProxyFromCommandLine: Boolean;
var
  lI: Integer;
  lListenPort: Word;
  lDeviceHost: string;
  lDevicePort: Word;
begin
  Result := False;
  for lI := 1 to ParamCount do
    if SameText(ParamStr(lI), '--proxy') then
    begin
      Result := True;
      lListenPort := 4001;
      lDeviceHost := CMic140DebugHost;
      lDevicePort := CMic140DebugPort;
      if (lI + 1 <= ParamCount) and (Copy(ParamStr(lI + 1), 1, 2) <> '--') then
        lListenPort := Word(StrToIntDef(ParamStr(lI + 1), lListenPort));
      if (lI + 2 <= ParamCount) and (Copy(ParamStr(lI + 2), 1, 2) <> '--') then
        lDeviceHost := ParamStr(lI + 2);
      if (lI + 3 <= ParamCount) and (Copy(ParamStr(lI + 3), 1, 2) <> '--') then
        lDevicePort := Word(StrToIntDef(ParamStr(lI + 3), lDevicePort));
      ExitCode := Mic140RunMdpProxy(lListenPort, lDeviceHost, lDevicePort);
      Break;
    end;
end;

function Mic140RunAutoTestFromCommandLine: Integer;
var
  lConfig: TMic140DebugConfig;
  lDurationSec: Integer;
begin
  lConfig := Mic140DebugDefaultConfig;
  lDurationSec := 3;
  Mic140AutoParseCommandLine(lConfig, lDurationSec);
  Result := Mic140RunAutoTestWithConfig(lConfig, lDurationSec);
end;

end.
