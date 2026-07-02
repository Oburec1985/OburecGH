unit uMic140DebugConfig;

{
  Конфигурация стенда MIC-140 и подготовка железа.

  Здесь зафиксированы параметры, с которыми снимался эталон Recorder:
    192.168.14.155:4000, 48 AIn, 10 Гц, update 200 мс, диапазон 80 мВ (index 0).

  TMic140DebugConfig — runtime-настройки; значения по умолчанию в константах CMic140Debug*.
  Поля Bank2*, TinSlots, ChanDumpCount, Bank2DelayMul — только для экспериментов
  на shadow-драйвере (Driver/uRecorderMic140v2Scan.pas), не влияют на RecorderLnx.

  Mic140DebugCreateDevice:
    Создаёт TRecorderMic140v2Device из Driver/ (не из общей фабрики RecorderLnx).
  Mic140DebugPrepareHardware:
    tcp probe → Connect → ProgramDevice → Start (как PrepareHardware в DataSource,
    но без проектного JSON и без UI Recorder).

  Перед ProgramDevice вызываются Mic140v2SetDebug* — попадают в shadow-scan.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uRecorderDeviceInterfaces,
  uRecorderMic140DeviceApi,
  uRecorderMic140v2Consts,
  uRecorderMic140v2WireTypes,
  uMic140Api;

const
  { Сеть и идентификатор устройства на стенде }
  CMic140DebugHost = '192.168.14.155';
  CMic140DebugPort = 4000;
  CMic140DebugDeviceId = 'MIC-140: 192.168.14.155:4000';

  { Параметры опроса как в Recorder UI }
  CMic140DebugChannelCount = 48;
  CMic140DebugPollHz = 10.0;
  CMic140DebugUpdateMs = 200;

  { CMic140Range100mV = 0 — диапазон 80 мВ на MIC-140 }
  CMic140DebugRangeIndex = CMic140Range100mV;
  { -1 = тот же range, что и для CH01..24; иначе index для CH25..48 }
  CMic140DebugBank2RangeIndex = -1;
  { CMic140ChannelCommutIn = 0 — вход коммутатора «Вход» }
  CMic140DebugCommutIndex = CMic140ChannelCommutIn;
  { board MUX (calibr2); 0 = «Вход» → desc $0100 }
  CMic140DebugBoardCommutIndex = CMic140ChannelCommutIn;
  { board MUX для второго банка (CH25..48); -1 = как первый банк }
  CMic140DebugBank2CommutIndex = -1;

  { Множитель SPORT-задержки для CH25..48 (1 = как production RecorderLnx H45) }
  CMic140DebugBank2DelayMul = 1;
  { -1 = chanDump[2]=48; 51 = Recorder wire }
  CMic140DebugChanDumpCount = -1;
  { FIFO stride: -1=авто (48) }
  CMic140DebugFifoStride = -1;
  { Канал для строки «CH29:» в UI }
  CMic140DebugWatchChannel1 = 29;
  { Ожидаемые блоки/с при update 200 мс и 10 Гц (~5 блоков/с) }
  CMic140DebugBlocksPerSec = 5.0;
  CMic140DebugTcpProbeMs = 800;
  { 0 = production scan (48 BIOS slots); 3 = +TIn в BIOS (эксперимент) }
  CMic140DebugTinSlots = 0;
  { Прогрев ME048 2-го банка перед strict-приёмкой }
  CMic140DebugSettleSec = 10;

type
  TMic140DebugConfig = record
    Host: string;
    Port: Word;
    ChannelCount: Integer;
    PollHz: Double;
    UpdateMs: Cardinal;
    RangeIndex: Integer;
    Bank2RangeIndex: Integer;
    CommutIndex: Integer;
    BoardCommutIndex: Integer;
    Bank2CommutIndex: Integer;
    Bank2DelayMul: Integer;
    ChanDumpCount: Integer;
    FifoStride: Integer;
    TinSlots: Integer;
    RecorderWireProfile: Boolean;
    ProductionScan: Boolean;
    SettleSec: Integer;
    WatchChannel1: Integer;
  end;

  TMic140DebugLogProc = procedure(const ALine: string) of object;

function Mic140DebugDefaultConfig: TMic140DebugConfig;
function Mic140ConfigFromDebug(const ADebug: TMic140DebugConfig): TMic140Config;
function Mic140DebugCreateDevice(const AConfig: TMic140DebugConfig): IMic140Device;
function Mic140DebugConfigSummary(const AConfig: TMic140DebugConfig): string;
function Mic140DebugMainReadTimeoutMs(const AConfig: TMic140DebugConfig): Cardinal;
function Mic140DebugPrepareHardware(AMic: IMic140Device; const AConfig: TMic140DebugConfig;
  ALog: TMic140DebugLogProc): string;

implementation

uses
  uRecorderMic140v2Device, uRecorderMic140v2Scan, uRecorderMic140v2Helper;

function Mic140DebugDefaultConfig: TMic140DebugConfig;
begin
  Result.Host := CMic140DebugHost;
  Result.Port := CMic140DebugPort;
  Result.ChannelCount := CMic140DebugChannelCount;
  Result.PollHz := CMic140DebugPollHz;
  Result.UpdateMs := CMic140DebugUpdateMs;
  Result.RangeIndex := CMic140DebugRangeIndex;
  Result.Bank2RangeIndex := CMic140DebugBank2RangeIndex;
  Result.CommutIndex := CMic140DebugCommutIndex;
  Result.BoardCommutIndex := CMic140DebugBoardCommutIndex;
  Result.Bank2CommutIndex := CMic140DebugBank2CommutIndex;
  Result.Bank2DelayMul := CMic140DebugBank2DelayMul;
  Result.ChanDumpCount := CMic140DebugChanDumpCount;
  Result.FifoStride := CMic140DebugFifoStride;
  Result.TinSlots := CMic140DebugTinSlots;
  Result.RecorderWireProfile := False;
  Result.ProductionScan := True;
  Result.SettleSec := CMic140DebugSettleSec;
  Result.WatchChannel1 := CMic140DebugWatchChannel1;
end;

procedure Mic140DebugApplyDeviceProperties(AMic: IMic140Device;
  const AConfig: TMic140DebugConfig);
begin
  if AMic = nil then
    Exit;
  AMic.TrySetDeviceProperty(rdpHost, AConfig.Host, 0);
  AMic.TrySetDeviceProperty(rdpPort, Integer(AConfig.Port), 0);
  AMic.TrySetDeviceProperty(rdpPollFrequencyHz, AConfig.PollHz, 0);
  AMic.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(AConfig.UpdateMs), 0);
  AMic.TrySetDeviceProperty(rdpChannelCount, AConfig.ChannelCount, 0);
  Mic140v2SetDebugTinSlotCount(AConfig.TinSlots);
  Mic140v2SetDebugBank2DelayMul(AConfig.Bank2DelayMul);
  if AConfig.RecorderWireProfile then
    Mic140v2ApplyRecorderWireProfile
  else
  begin
    if AConfig.ProductionScan and (AConfig.TinSlots <= 0) then
      Mic140v2SetDebugTinSlotCount(0);
    Mic140v2SetDebugFifoStride(AConfig.FifoStride);
    Mic140v2SetDebugChanDumpCount(AConfig.ChanDumpCount);
  end;
end;

procedure Mic140DebugApplyChannelSettings(AMic: IMic140Device;
  const AConfig: TMic140DebugConfig);
var
  I, lRange, lUserCommut, lBoardCommut: Integer;
begin
  for I := 0 to AConfig.ChannelCount - 1 do
  begin
    lRange := AConfig.RangeIndex;
    if (I >= 24) and (AConfig.Bank2RangeIndex >= 0) then
      lRange := AConfig.Bank2RangeIndex;
    lUserCommut := AConfig.CommutIndex;
    lBoardCommut := AConfig.BoardCommutIndex;
    if (I >= 24) and (AConfig.Bank2CommutIndex >= 0) then
      lBoardCommut := AConfig.Bank2CommutIndex;
    AMic.TrySetDeviceProperty(rdpMic140RangeIndex, lRange, I);
    AMic.TrySetDeviceProperty(rdpMic140CommutIndex, lUserCommut, I);
    AMic.TrySetDeviceProperty(rdpMic140BoardCommutIndex, lBoardCommut, I);
  end;
end;

function Mic140ConfigFromDebug(const ADebug: TMic140DebugConfig): TMic140Config;
begin
  Result := Mic140DefaultConfig;
  Result.Host := ADebug.Host;
  Result.Port := ADebug.Port;
  Result.ChannelCount := ADebug.ChannelCount;
  Result.PollFrequencyHz := ADebug.PollHz;
  Result.DataUpdateMs := ADebug.UpdateMs;
  Result.RangeIndex := ADebug.RangeIndex;
  Result.CommutIndex := ADebug.CommutIndex;
  Result.BoardCommutIndex := ADebug.BoardCommutIndex;
  Result.TinSlots := ADebug.TinSlots;
  Result.FifoStride := ADebug.FifoStride;
  Result.Bank2DelayMul := ADebug.Bank2DelayMul;
  Result.Bank2RangeIndex := ADebug.Bank2RangeIndex;
  Result.Bank2CommutIndex := ADebug.Bank2CommutIndex;
  Result.ChanDumpCount := ADebug.ChanDumpCount;
end;

function Mic140DebugCreateDevice(const AConfig: TMic140DebugConfig): IMic140Device;
begin
  Result := TRecorderMic140v2Device.Create(CMic140DebugDeviceId, AConfig.Host, AConfig.Port,
    AConfig.ChannelCount, AConfig.PollHz, AConfig.UpdateMs);
  Mic140DebugApplyDeviceProperties(Result, AConfig);
  Mic140DebugApplyChannelSettings(Result, AConfig);
end;

function Mic140DebugConfigSummary(const AConfig: TMic140DebugConfig): string;
begin
  Result := Format(
    'MIC-140 debug: %s:%d ch=%d tin=%d fifo=%d dump=%d freq=%.1f Hz update=%d ms range=%d bank2-range=%d user-commut=%d board-commut=%d bank2-board=%d bank2-delay=%d settle=%ds watch=CH%d (~%.0f blk/s)',
    [AConfig.Host, AConfig.Port, AConfig.ChannelCount, AConfig.TinSlots,
     AConfig.FifoStride, AConfig.ChanDumpCount, AConfig.PollHz, AConfig.UpdateMs, AConfig.RangeIndex,
     AConfig.Bank2RangeIndex, AConfig.CommutIndex, AConfig.BoardCommutIndex,
     AConfig.Bank2CommutIndex,
     AConfig.Bank2DelayMul, AConfig.SettleSec, AConfig.WatchChannel1, CMic140DebugBlocksPerSec]);
end;

function Mic140DebugMainReadTimeoutMs(const AConfig: TMic140DebugConfig): Cardinal;
var
  lBlockPeriodMs: Cardinal;
  lFreq: Double;
begin
  { Упрощённый аналог MainScanReadTimeoutMs без TRecorderMic140ScanConfig }
  lFreq := AConfig.PollHz;
  if lFreq <= 0 then
    lFreq := CMic140DebugPollHz;
  if lFreq > 0.1 then
    lBlockPeriodMs := Cardinal(Ceil(2000.0 / lFreq))
  else if AConfig.UpdateMs > 0 then
    lBlockPeriodMs := AConfig.UpdateMs
  else
    lBlockPeriodMs := 200;
  if lBlockPeriodMs < 100 then
    lBlockPeriodMs := 100;
  Result := lBlockPeriodMs + 50;
end;

function Mic140DebugPrepareHardware(AMic: IMic140Device; const AConfig: TMic140DebugConfig;
  ALog: TMic140DebugLogProc): string;
var
  lProbeOk: Boolean;
  lFirmware: TRecorderMic140LegacyFirmware;
  lSerial: Integer;
  procedure LogLine(const AText: string);
  begin
    if Assigned(ALog) then
      ALog(AText);
  end;
begin
  Result := '';
  if AMic = nil then
    Exit('FAIL no device');

  Mic140DebugApplyDeviceProperties(AMic, AConfig);

  if AMic.State <> rdsDisconnected then
  begin
    LogLine('phase: disconnect previous session');
    try
      AMic.Stop;
    except
    end;
    try
      AMic.Disconnect;
    except
    end;
  end;

  lProbeOk := Mic140v2TcpProbe(AConfig.Host, AConfig.Port, CMic140DebugTcpProbeMs);
  LogLine(Format('tcp probe %s:%d => %s', [AConfig.Host, AConfig.Port,
    BoolToStr(lProbeOk, True)]));

  LogLine('phase: connect');
  AMic.Connect;
  if AMic.State = rdsDisconnected then
    Exit('FAIL connect');

  lSerial := AMic.GetDeviceSerial;
  if AMic.GetLegacyFirmware(lFirmware) then
    LogLine(Format(
      'connected devSerNo=%u ccSerNo=%u ccType=%u BIOS=%d.%d hwCal=%d state=%d',
      [lFirmware.DevSerNo, lFirmware.CCSerNo, lFirmware.CCType,
       lFirmware.BiosFunction, lFirmware.BiosVersion, lSerial, Ord(AMic.State)]))
  else
    LogLine(Format('connected hwCal=%d state=%d', [lSerial, Ord(AMic.State)]));

  Mic140DebugApplyChannelSettings(AMic, AConfig);

  LogLine('phase: program');
  AMic.ProgramDevice;
  if AMic.State <> rdsProgrammed then
    Exit('FAIL program (see Mic140v2Log / program failed line)');
  LogLine('scan programmed');

  LogLine('phase: start');
  AMic.Start;
  if AMic.State <> rdsStarted then
    Exit('FAIL start');
  LogLine('scan started');
end;

end.
