unit uMc032Device;

{
  Низкоуровневый production-драйвер крейт-контроллера MC-031/MC-032.

  Отвечает за поиск и TEST контроллера, чтение слотов, программирование scan,
  запуск/остановку и выделение вложенных BIOS-сообщений из MDP-потока. Класс не
  зависит от UI и TRecorderDevice: адаптацию выполняет uRecorderMcbusDevice.

  После неподтверждённого STOP: no-wait + drain, TCP сохраняется (без
  ForceDisconnect — обрыв после потока «убивал» контроллер). Teardown не
  должен выбрасывать исключение в UI. При повторном Config допускается один
  reset/reconnect. Полная карта: Docs/devices/mc/recorderlnx-integration.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uMc201LegacyMdpClient, uMc201ProtocolTypes;

type
  EMc032Device = class(Exception);

  TMc032Device = class;
  { Диагностический callback для длинных BIOS/IDMA шагов (Config/Play/RX).
    AText — одна строка прогресса; вызывается из рабочего кода драйвера и
    из read-thread, поэтому UI должен только логировать, не трогать железо. }
  TMc032ProgressCallback = procedure(Sender: TObject; const AText: string) of object;

  { Перенос готового BIOS-сообщения в GUI-поток через TThread.Queue.
    Create копирует пакет; Deliver вызывает ACallback и освобождает себя. }
  TMc032QueuedPacket = class
  private
    fCallback: TMc032DataCallback;
    fPacket: TMc032DataPacket;
    fSender: TObject;
  public
    { ASender — обычно TMc032Device; ACallback — потребитель данных (адаптер
      uRecorderMcbusDevice); APacket — уже выделенное BIOS-сообщение. }
    constructor Create(ASender: TObject; ACallback: TMc032DataCallback;
      const APacket: TMc032DataPacket);
    { Вызывается из главного потока после Queue; после callback объект Free. }
    procedure Deliver;
  end;

  { Фоновый потребитель MDP TCP: крутит ReadRawPacket и отдаёт кадры в
    HandleThreadPacket. Живёт только в состоянии Play после Play(). }
  TMc032ReadThread = class(TThread)
  private
    fOwner: TMc032Device;
  protected
    procedure Execute; override;
  public
    { Сразу Start; AOwner обязан пережить поток до StopReadThread. }
    constructor Create(AOwner: TMc032Device);
  end;

  TMc032Device = class
  private
    fBios: TMc201ControllerBios;
    fClient: TMc201LegacyMdpClient;
    fConfig: TMc032Config;
    fHost: string;
    fLastModules: TMc201SlotInfoArray;
    fOnData: TMc032DataCallback;
    fPacketIndex: Int64;
    fPort: Word;
    fOnProgress: TMc032ProgressCallback;
    fReadThread: TMc032ReadThread;
    fState: TMc032DeviceState;
    fStreamBuffer: TMc201WordArray;
    fTimeoutMs: Cardinal;
    fProgramInfo: TMc201ModuleProgramInfoArray;
    fReceivedPacketCount: Int64;
    fRawPacketCount: Int64;
    { Поднимает TCP+BIOS, если State=Disconnected; иначе бросает исключение.
      Вызывается из API, которому нужна уже живая сессия (SearchModules, Config…). }
    procedure EnsureConnected;
    { Ближайший индекс частотной сетки контроллера (0..15) к AFreqHz. }
    function FreqToIndex(AFreqHz: Double): Word;
    { Частота Hz по индексу сетки с учётом BackplaneFrequencyHz из fConfig. }
    function FreqIndexToFreq(AIndex: Word): Double;
    { Код делителя частоты модуля (поле Freq в SET_FREQ_CC) для AFreqHz. }
    function FreqToFreqCode(AFreqHz: Double): Word;
    { Код grid (SET_GRID_CC): чётный индекс сетки → 1, нечётный → 0. }
    function FreqToGridCode(AFreqHz: Double): Word;
    { Склеивает сырой MDP-кадр в fStreamBuffer и вытаскивает целые BIOS-
      сообщения; вызывается только из TMc032ReadThread.
      APort — MDP stream port; AWords — payload кадра без разбора. }
    procedure HandleThreadPacket(APort: Word; const AWords: TMc201WordArray);
    { Пытается снять одно валидное BIOS-сообщение с головы fStreamBuffer
      (word0=0, size в пределах лимита). True — AWords заполнен. }
    function TryExtractStreamMessage(out AWords: TMc201WordArray): Boolean;
    { Упаковывает сообщение в TMc032DataPacket и ставит Deliver в GUI-очередь.
      APort копируется в StreamPort пакета. }
    procedure QueueStreamMessage(APort: Word; const AWords: TMc201WordArray);
    { Полная программа скана MC-201 по AConfig (RESETSCANMAIN…START_TRIGGER).
      Вызывается из Config; STARTSCANMAIN сюда не входит — его даёт Play/
      StartRawScan. AErrorMessage — текст первого упавшего BIOS/IDMA шага. }
    function ProgramMc201Scan(const AConfig: TMc032Config;
      out AErrorMessage: string): Boolean;
    { Пробрасывает AText в OnProgress, если назначен. }
    procedure Progress(const AText: string);
    { Читает flash слота ASlot (type/version/serial) и помечает IsMc201.
      Пустой слот (TypeId 0 или 0xFFFF) — Success с нулевым типом, без ошибки. }
    function ReadSlotInfo(ASlot: Word; out AInfo: TMc201SlotInfo;
      out AErrorMessage: string): Boolean;
    { Terminate+WaitFor фонового RX; безопасен при nil. Нужен перед STOPSCAN
      и при PauseStreamingReader (скан на железе может продолжаться). }
    procedure StopReadThread;
  public
    constructor Create;
    destructor Destroy; override;
    { Проверка доступности Host/Port через TEST_LOAD. При успехе AFoundHost:=Host.
      UI «найти контроллер» без полного Connect. }
    function Search(out AFoundHost: string; out AErrorMessage: string): Boolean;
    { CMD TEST_LOAD на текущем Host/Port. Если сессии ещё нет — открывает
      временный клиент и закрывает его в finally. True при reply[0]=1. }
    function TestConnection(out AErrorMessage: string): Boolean;
    { Обход слотов 0..AMaxSlots-1, возвращает только занятые модули в AModules
      и кэширует их в LastModules (нужно ProgramMc201Scan). Требует Connect. }
    function SearchModules(AMaxSlots: Word; out AModules: TMc201SlotInfoArray;
      out AErrorMessage: string): Boolean;
    { TCP + ReadControllerBios; при ошибке — исключение. Для CLI/адаптера. }
    procedure Connect;
    { Тот же Connect для GUI: False + AErrorMessage вместо исключения;
      при уже Connected сразу True. }
    function TryConnect(out AErrorMessage: string): Boolean;
    { Stop (если Play) и ForceDisconnect(False): рвёт TCP, программу скана
      в LastModules/ProgramInfo не сбрасывает. }
    procedure Disconnect;
    { CMD RESET контроллера на живой сессии. Перед повторным Config после
      сбоя или по явной команде UI. }
    function Reset(out AErrorMessage: string): Boolean;
    { Применяет AConfig: ProgramMc201Scan; при отказе — один Reset+reconnect
      и повтор. Вызывать из UI/адаптера до Play. AConfig копируется в ConfigValue. }
    function Config(const AConfig: TMc032Config; out AErrorMessage: string): Boolean;
    { Config без Disconnect: при сбое Program — CMD_RESET + Sleep + повтор Program
      на той же TCP. Нужен apply баланса (ForceDisconnect убивал контроллер). }
    function ConfigKeepSession(const AConfig: TMc032Config;
      out AErrorMessage: string): Boolean;
    { Жёсткий teardown без STOPSCAN: гасит callback/reader/TCP, State:=Disconnected.
      AClearProgram=True — ещё чистит ProgramInfo и LastModules (полный сброс
      после смены крейта); False — оставляет кэш модулей для быстрого Config. }
    procedure ForceDisconnect(AClearProgram: Boolean);
    procedure SetTimeoutMs(AValue: Cardinal);
    { STARTSCANMAIN + фоновый reader. AOnData получает BIOS-сообщения через
      Queue в GUI-потоке. Повторный вызов в mcsPlay — no-op True. }
    function Play(AOnData: TMc032DataCallback; out AErrorMessage: string): Boolean;
    { Временно гасит TMc032ReadThread (фоновый RX просмотра) чтобы можно было включить поток балансировки,
      не посылая STOPSCANMAIN: скан на контроллере продолжает лить данные в TCP.
      Нужен zero-balance: CollectChannelMean сам читает ReadRawMessage на том
      же сокете. Два потребителя (thread + balance) иначе делят один поток
      кадров — пакеты «уводят» друг у друга, среднее/таймаут ломаются.
      Вызов: ExecuteDeviceAction(rdaZeroBalance) при уже запущенном Play. }
    procedure PauseStreamingReader;
    { После балансировки снова поднимает TMc032ReadThread, если Play и
      callback ещё задан — просмотр продолжает получать BIOS-сообщения. }
    procedure ResumeStreamingReader;
    { Один сырой MDP-кадр с TCP (без склейки BIOS). Для стендов/отладки.
      APort/AWords — выход клиента; False при timeout. }
    function ReadRawPacket(out APort: Word; out AWords: TMc201WordArray): Boolean;
    { Синхронно читает до целого BIOS-сообщения, дописывая кадры в fStreamBuffer.
      Используется StartRawScan-путём без Play/callback (балансировка, CLI). }
    function ReadRawMessage(out APort: Word; out AWords: TMc201WordArray): Boolean;
    { SEND_BALANCE_CC в слот ASlot: канал AChannel, код ЦАП как Lo/Hi байты.
      Сессия должна быть уже открыта (скан может идти). Для zero-balance. }
    function SendBalanceDac(ASlot, AChannel, ACodeLo, ACodeHi: Word;
      out AErrorMessage: string): Boolean;
    { STARTSCANMAIN без callback и без read-thread: поток читает вызывающий код
      через ReadRawMessage. Нужен служебным сценариям (оценка среднего). }
    function StartRawScan(out AErrorMessage: string): Boolean;
    { Если State=Play: гасит reader, шлёт STOPSCANMAIN → mcsConnected.
      При отказе STOP — ForceDisconnect(False), чтобы UI не завис на полуживом TCP.
      Если не Play — сразу True без команды. }
    function Stop(out AErrorMessage: string): Boolean;
    { Остановка после плотного ReadRawMessage (мультибаланс): без CallCommand
      (reply тонет в RX). STOP no-wait + drain до тишины ≥300 мс, TCP жив
      для SEND_BALANCE. Просмотр по-прежнему использует Stop. }
    function StopAfterHeavyStream(out AErrorMessage: string): Boolean;
    property Bios: TMc201ControllerBios read fBios;
    property ConfigValue: TMc032Config read fConfig;
    property Host: string read fHost write fHost;
    property LastModules: TMc201SlotInfoArray read fLastModules;
    property OnProgress: TMc032ProgressCallback read fOnProgress write fOnProgress;
    property ProgramInfo: TMc201ModuleProgramInfoArray read fProgramInfo;
    property Port: Word read fPort write fPort;
    property State: TMc032DeviceState read fState;
    property TimeoutMs: Cardinal read fTimeoutMs write SetTimeoutMs;
  end;

{ Строка состояния для логов/UI (Disconnected/Connected/Play). }
function Mc032StateToString(AState: TMc032DeviceState): string;

implementation

uses
  Math;

constructor TMc032QueuedPacket.Create(ASender: TObject;
  ACallback: TMc032DataCallback; const APacket: TMc032DataPacket);
begin
  inherited Create;
  fSender := ASender;
  fCallback := ACallback;
  fPacket.StreamPort := APacket.StreamPort;
  fPacket.PacketIndex := APacket.PacketIndex;
  fPacket.Words := Copy(APacket.Words, 0, Length(APacket.Words));
end;

procedure TMc032QueuedPacket.Deliver;
begin
  try
    if Assigned(fCallback) then
      fCallback(fSender, fPacket);
  finally
    Free;
  end;
end;

function Mc032StateToString(AState: TMc032DeviceState): string;
begin
  case AState of
    mcsDisconnected: Result := 'Disconnected';
    mcsConnected: Result := 'Connected';
    mcsPlay: Result := 'Play';
  else
    Result := 'Unknown';
  end;
end;

procedure TMc032Device.Progress(const AText: string);
begin
  if Assigned(fOnProgress) then
    fOnProgress(Self, AText);
end;

procedure TMc032Device.SetTimeoutMs(AValue: Cardinal);
begin
  fTimeoutMs := AValue;
  if fClient <> nil then
    fClient.TimeoutMs := AValue;
end;

constructor TMc032ReadThread.Create(AOwner: TMc032Device);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  Start;
end;

procedure TMc032ReadThread.Execute;
var
  lPort: Word;
  lWords: TMc201WordArray;
begin
  while not Terminated do
  begin
    try
      if (fOwner = nil) or (fOwner.fClient = nil) then
        Exit;
      if fOwner.fClient.ReadRawPacket(lPort, lWords) then
      begin
        if Length(lWords) >= CMc201BiosMessageHeaderWords then
          fOwner.Progress(Format(
            'RX packet port=%d words=%d head=[%u %u %u %u 0x%s %u %u %u %u 0x%s]',
            [lPort, Length(lWords), lWords[0], lWords[1], lWords[2],
             lWords[3], IntToHex(lWords[4], 4), lWords[5], lWords[6],
             lWords[7], lWords[8], IntToHex(lWords[9], 4)]))
        else
          fOwner.Progress(Format('RX packet port=%d words=%d',
            [lPort, Length(lWords)]));
        fOwner.HandleThreadPacket(lPort, lWords);
      end
      else
        fOwner.Progress('RX read timeout/no packet');
    except
      on E: Exception do
      begin
        if fOwner <> nil then
          fOwner.Progress('RX read exception: ' + E.Message);
        Exit;
      end;
    end;
  end;
end;

constructor TMc032Device.Create;
begin
  inherited Create;
  fHost := CMc201DefaultHost;
  fPort := CMc201DefaultPort;
  fTimeoutMs := CMc201DefaultTimeoutMs;
  fState := mcsDisconnected;
  fConfig.SampleRateHz := CMc201DefaultSampleRateHz;
  fConfig.BackplaneFrequencyHz := Round(CMc201BackplaneFrequencyHz);
  fConfig.MaxSlots := CMc201DefaultMaxSlots;
  fConfig.ReadTimeoutMs := CMc201DefaultTimeoutMs;
end;

destructor TMc032Device.Destroy;
begin
  ForceDisconnect(False);
  inherited Destroy;
end;

function TMc032Device.FreqIndexToFreq(AIndex: Word): Double;
begin
  Result := RecorderMc201FrequencyGridValue(AIndex,
    fConfig.BackplaneFrequencyHz);
end;

function TMc032Device.FreqToFreqCode(AFreqHz: Double): Word;
var
  I: Integer;
  lBest: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  lBest := 0;
  lBestDelta := Abs(FreqIndexToFreq(0) - AFreqHz);
  for I := 1 to 15 do
  begin
    lDelta := Abs(FreqIndexToFreq(I) - AFreqHz);
    if lDelta < lBestDelta then
    begin
      lBest := I;
      lBestDelta := lDelta;
    end;
  end;
  Result := 7 - (lBest div 2);
end;

function TMc032Device.FreqToGridCode(AFreqHz: Double): Word;
var
  I: Integer;
  lBest: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  lBest := 0;
  lBestDelta := Abs(FreqIndexToFreq(0) - AFreqHz);
  for I := 1 to 15 do
  begin
    lDelta := Abs(FreqIndexToFreq(I) - AFreqHz);
    if lDelta < lBestDelta then
    begin
      lBest := I;
      lBestDelta := lDelta;
    end;
  end;
  if (lBest mod 2) <> 0 then
    Result := 0
  else
    Result := 1;
end;

function TMc032Device.FreqToIndex(AFreqHz: Double): Word;
begin
  Result := 2 * (7 - FreqToFreqCode(AFreqHz)) + (1 - FreqToGridCode(AFreqHz));
end;

{ Программирует слои скана в порядке оригинального Recorder: сброс/настройка
  скана контроллера, BIOS и IDMA-дескрипторы модулей, цепочки каналов MC-201 и
  final flags, дескрипторы скана контроллера, стартовый триггер ADC. Команда
  STARTSCANMAIN остается для Play. }
function TMc032Device.ProgramMc201Scan(const AConfig: TMc032Config;
  out AErrorMessage: string): Boolean;
var
  C: Integer;
  I: Integer;
  J: Integer;
  lAddr: Word;
  lArgs: TMc201WordArray;
  lChanAddr: Word;
  lChanPage: Word;
  lFifoPerChan: Word;
  lFreqCode: Word;
  lGridCode: Word;
  lInfo: TMc201SlotInfo;
  lInternalDivider: Word;
  lAmplif: Word;
  lAtt: Boolean;
  lOffset: Integer;
  lIsOdd: Integer;
  lModuleCount: Integer;
  lMessageAddr: Word;
  lMessagePage: Word;
  lPage: Word;
  lReply: TMc201WordArray;
  lScanAddr: Word;
  lScanPage: Word;
  lSubmoduleHandle: Word;
  lSlotSampleRate: Double;
  lWords: TMc201WordArray;

  function ModuleTimeoutCycle(ATimeoutSec: Double): Word;
  var
    lCycle: Integer;
  begin
    lCycle := Trunc(ATimeoutSec * 2.0 * 16384000.0);
    if lCycle = 0 then
      lCycle := 1;
    if lCycle > $3FFF then
      lCycle := $3FFF;
    Result := Word(lCycle);
  end;

  function CallCC(ACommand: Word; const AArgs: TMc201WordArray;
    const AName: string): Boolean;
  begin
    Progress(AName);
    Result := fClient.CallCommand(ACommand, AArgs, 0, lReply, AErrorMessage);
    if not Result then
      AErrorMessage := AName + ' failed: ' + AErrorMessage;
  end;

  function CallMod(ASlot, ACommand: Word; const AArgs: TMc201WordArray;
    ARetCount: Integer; out ARet: TMc201WordArray; const AName: string): Boolean;
  begin
    Progress(Format('slot %d %s', [ASlot, AName]));
    Result := fClient.CallCommandModuleIdmaActivated(ASlot, ACommand, AArgs,
      ARetCount, ARet, AErrorMessage);
    if not Result then
      AErrorMessage := Format('%s failed slot=%d: %s',
        [AName, ASlot, AErrorMessage]);
  end;

  function SetMm202Property(ASlot, AChannel, AProperty,
    AValue: Word): Boolean;
  begin
    SetLength(lArgs, 4);
    lArgs[0] := AProperty;
    lArgs[1] := AChannel;
    lArgs[2] := AValue;
    lArgs[3] := 0;
    Result := CallMod(ASlot, CMc201ModuleCmdSetProperty, lArgs, 4, lReply,
      Format('MM202 SET_PROPERTY %d ch%d=%d',
        [AProperty, AChannel, AValue]));
    if Result and ((Length(lReply) = 0) or
      (lReply[0] <> CMc201PropertyOk)) then
    begin
      AErrorMessage := Format('MM202 property %d rejected slot=%d channel=%d',
        [AProperty, ASlot, AChannel]);
      Result := False;
    end;
  end;

  function ConfigureStartTriggers: Boolean;
  var
    K: Integer;
  begin
    Result := False;
    for K := 0 to High(fProgramInfo) do
    begin
      SetLength(lArgs, 1);
      lArgs[0] := fProgramInfo[K].Slot;
      if not CallCC(CMc201CmdAddListStartAdcModuleIdma, lArgs,
        'ADD_LISTSTARTADCMODULEIDMA') then Exit;
    end;
    for K := High(fProgramInfo) downto 0 do
    begin
      SetLength(lArgs, 1);
      lArgs[0] := ModuleTimeoutCycle((High(fProgramInfo) - K) *
        ((23 + 11 + 2 + 1) / 32000000.0));
      if not CallMod(fProgramInfo[K].Slot, CMc201ModuleCmdSetTimeoutStartAdc,
        lArgs, 0, lReply, 'SET_TIMEOUTSTARTADC_201') then Exit;
    end;
    SetLength(fStreamBuffer, 0);
    SetLength(lArgs, 3);
    lArgs[0] := 0;
    lArgs[1] := 0;
    lArgs[2] := 1;
    if not CallCC(CMc201CmdConfigSyncStart, lArgs, 'CONFIG_SYNC_START') then Exit;
    for K := 0 to CMc201CrateMaxStartSlots - Length(fProgramInfo) - 1 do
    begin
      SetLength(lArgs, 2);
      lArgs[0] := 0;
      lArgs[1] := K;
      if not CallCC(CMc201CmdAddListStartModuleIdma, lArgs,
        'ADD_LISTSTARTMODULEIDMA empty') then Exit;
    end;
    for K := 0 to High(fProgramInfo) do
    begin
      SetLength(lArgs, 2);
      lArgs[0] := 1;
      lArgs[1] := fProgramInfo[K].Slot;
      if not CallCC(CMc201CmdAddListStartModuleIdma, lArgs,
        'ADD_LISTSTARTMODULEIDMA') then Exit;
    end;
    SetLength(lArgs, 1);
    lArgs[0] := Trunc((((25 + 9 + 2 + 11) / (2.0 * 16384000.0)) -
      (5 / 32000000.0) - ((2 + 2) / 32000000.0)) * 32000000.0 + 1);
    if lArgs[0] < 1 then lArgs[0] := 1;
    if not CallCC(CMc201CmdSetTimeoutStartTimer, lArgs,
      'SET_TIMEOUTSTARTTIMER') then Exit;
    for K := High(fProgramInfo) downto 0 do
    begin
      SetLength(lArgs, 1);
      lArgs[0] := ModuleTimeoutCycle((High(fProgramInfo) - K) *
        ((28 + 11 + 2 + 2) / 32000000.0));
      if not CallMod(fProgramInfo[K].Slot, CMc201ModuleCmdSetTimeoutStart,
        lArgs, 0, lReply, 'SET_TIMEOUTSTART_201') then Exit;
    end;
    if not CallCC(CMc201CmdStartTriggerStartAdc, nil,
      'START_TRIGGERSTARTADC') then Exit;
    Result := True;
  end;

begin
  Result := False;
  AErrorMessage := '';
  SetLength(fProgramInfo, 0);
  if Length(fLastModules) = 0 then
  begin
    Progress('SearchModules');
    if not SearchModules(AConfig.MaxSlots, fLastModules, AErrorMessage) then Exit;
  end;
  lModuleCount := 0;
  for I := 0 to High(fLastModules) do
    if fLastModules[I].IsMc201 then Inc(lModuleCount);
  if lModuleCount = 0 then
  begin
    AErrorMessage := 'No MC-201 modules are available for scan programming';
    Exit;
  end;
  fClient.ResetLocalMemoryHeap;
  Progress('RESETSCANMAIN');
  if not fClient.CallCommand(CMc201CmdResetScanMain, nil, 0, lReply,
    AErrorMessage) then
  begin
    AErrorMessage := 'RESETSCANMAIN failed: ' + AErrorMessage;
    Exit;
  end;

  SetLength(lArgs, 2);
  lArgs[0] := CMc201Cc81TimerScale - 1;
  lArgs[1] := CMc201Cc81TimerPeriod - 1;
  if not CallCC(CMc201CmdConfigScanMain, lArgs, 'CONFIGSCANMAIN') then
    Exit;

  { Это размер FIFO одного канала. В оригинале ScanMC201::Config передаёт
    модулю GetFifoSizeWord()/channels.size(), а в данной конфигурации это 256.
    Деление ещё раз на число каналов создаёт пакеты по 16 отсчётов и резко
    снижает пропускную способность из-за накладных расходов MDP. }
  lFifoPerChan := CMc201AdspFifoSamplesPerChannel;
  SetLength(fProgramInfo, lModuleCount);
  { Оригинальный ScanMC201 сначала создаёт дескрипторы IDMA всех модулей и
    строит общие стартовые триггеры крейта. Только после этого вызывается
    ModuleMC201::Programming для каждого слота. }
  C := 0;
  for I := 0 to High(fLastModules) do
  begin
    lInfo := fLastModules[I];
    if not lInfo.IsMc201 then Continue;
    lSlotSampleRate := AConfig.Slots[lInfo.Slot].SampleRateHz;
    if lSlotSampleRate <= 0 then lSlotSampleRate := AConfig.SampleRateHz;
    fProgramInfo[C].Slot := lInfo.Slot;
    fProgramInfo[C].SampleRateHz := lSlotSampleRate;
    fProgramInfo[C].MaskChan := $000F;
    fProgramInfo[C].FifoSize := lFifoPerChan;
    fProgramInfo[C].FreqIndex := FreqToIndex(lSlotSampleRate);
    fProgramInfo[C].GridCode := FreqToGridCode(lSlotSampleRate);
    lFreqCode := FreqToFreqCode(lSlotSampleRate);
    fProgramInfo[C].DividerCode := lFreqCode or (lFreqCode shl 4);
    Progress(Format('slot %d LOAD_MC201_BIOS', [lInfo.Slot]));
    if not fClient.LoadMc201BiosIdma(lInfo.Slot, CMc201DefaultBiosPath,
      AErrorMessage) then Exit;
    if not fClient.GetInternalMemHeap(CMc201DescModuleWords, lPage, lAddr,
      AErrorMessage) then Exit;
    SetLength(lArgs, 6);
    lArgs[0] := lInfo.Slot;
    lArgs[1] := fClient.GetAddrModuleReg(lInfo.Slot, CMc201ModuleDataReg);
    lArgs[2] := fClient.GetAddrModuleReg(lInfo.Slot, CMc201ModuleIdmaReg);
    lArgs[3] := fClient.GetAddrModuleReg(lInfo.Slot, CMc201ModuleIrqReg);
    lArgs[4] := lAddr;
    lArgs[5] := lPage;
    if not CallCC(CMc201CmdConfigModuleIdma, lArgs,
      'CONFIG_MODULE_IDMA') then Exit;
    Inc(C);
  end;
  C := 0;
  for I := 0 to High(fLastModules) do
  begin
    lInfo := fLastModules[I];
    if not lInfo.IsMc201 then
      Continue;

    lSlotSampleRate := AConfig.Slots[lInfo.Slot].SampleRateHz;
    if lSlotSampleRate <= 0 then
      lSlotSampleRate := AConfig.SampleRateHz;
    lGridCode := FreqToGridCode(lSlotSampleRate);
    lFreqCode := FreqToFreqCode(lSlotSampleRate);
    lInternalDivider := Trunc(lFifoPerChan * 5.0 / 100.0 /
      (lSlotSampleRate *
       (CMc201Cc81TimerScale * CMc201Cc81TimerPeriod / 32000000.0)));
    if lInternalDivider < 1 then
      lInternalDivider := 1;

    fProgramInfo[C].Slot := lInfo.Slot;
    fProgramInfo[C].SampleRateHz := lSlotSampleRate;
    fProgramInfo[C].MaskChan := $000F;
    fProgramInfo[C].FifoSize := lFifoPerChan;
    fProgramInfo[C].FreqIndex := FreqToIndex(lSlotSampleRate);
    fProgramInfo[C].GridCode := lGridCode;
    fProgramInfo[C].DividerCode := lFreqCode or (lFreqCode shl 4);

    if not CallMod(lInfo.Slot, CMc201ModuleCmdStopScan, nil, 0, lReply,
      'module STOP_SCAN') then
      Exit;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdResetScan, nil, 0, lReply,
      'module RESET_SCAN') then
      Exit;

    { Строгое место из ModuleMC201::Programming оригинального Recorder:
      балансировочный ЦАП программируется после STOP_SCAN/RESET_SCAN и до
      CONFIG_RAW/CONFIG_DBL/CONFIG_MIX. Отправка SEND_BALANCE после полной
      настройки триггеров (непосредственно перед STARTSCANMAIN) оставляла
      холодный контроллер без потока, хотя START возвращал успешный ACK. }
    for J := 0 to CMc201MaxModuleChannels - 1 do
    begin
      lOffset := EnsureRange(AConfig.Slots[lInfo.Slot].Channels[J].RangeIndex,
        0, High(AConfig.Slots[lInfo.Slot].Channels[J].BalanceDac));
      lSubmoduleHandle :=
        AConfig.Slots[lInfo.Slot].Channels[J].BalanceDac[lOffset];
      Progress(Format('slot %d SEND_BALANCE ch%d code=$%.4x',
        [lInfo.Slot, J, lSubmoduleHandle]));
      if not SendBalanceDac(lInfo.Slot, J, lSubmoduleHandle and $ff,
        lSubmoduleHandle shr 8, AErrorMessage) then
        Exit;
    end;

    for J := 0 to CMc201MaxModuleChannels - 1 do
    begin
      SetLength(lArgs, 2);
      lArgs[0] := J;
      lArgs[1] := lFifoPerChan;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdConfigRaw, lArgs, 0, lReply,
        'CONFIG_RAW_CC') then
        Exit;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdConfigDbl, lArgs, 0, lReply,
        'CONFIG_DBL_CC') then
        Exit;
      lArgs[1] := J;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdConfigMix, lArgs, 0, lReply,
        'CONFIG_MIX_CC') then
        Exit;
    end;

    { MM202 программируется отдельными BIOS-командами, а не битами основного
      регистра MC-201. Последовательность повторяет CChannelMC201::ProgrammingMm202. }
    if AConfig.Slots[lInfo.Slot].SubmoduleType <> 0 then
      for J := 0 to CMc201MaxModuleChannels - 1 do
      begin
        if not SetMm202Property(lInfo.Slot, J, CMc201PropertyIcpOn,
          AConfig.Slots[lInfo.Slot].Channels[J].IcpOn) then Exit;
        if not SetMm202Property(lInfo.Slot, J, CMc201PropertyIcpHpf,
          AConfig.Slots[lInfo.Slot].Channels[J].IcpHpf) then Exit;
        if not SetMm202Property(lInfo.Slot, J, CMc201PropertySingle,
          AConfig.Slots[lInfo.Slot].Channels[J].IcpSingle) then Exit;
      end;

    SetLength(lWords, 33);
    lWords[0] := 32;
    for J := 0 to 31 do
      lWords[J + 1] := 0;
    { ModuleMC201::SetRange преобразует индекс диапазона в Amplif/Att, после
      чего SetControlRegV5 раскладывает их по 32-разрядному регистру. Ранее
      здесь был постоянный шаблон 2 В, поэтому настройки UI не работали. }
    if lInfo.VersionCode = 2180 then
    begin
      lWords[32] := Ord((AConfig.Slots[lInfo.Slot].Commutator and 1) <> 0);
      lWords[31] := Ord((AConfig.Slots[lInfo.Slot].Commutator and 2) <> 0);
      for J := 0 to CMc201MaxModuleChannels - 1 do
      begin
        lAmplif := AConfig.Slots[lInfo.Slot].Channels[J].RangeIndex div 2;
        lAtt := (AConfig.Slots[lInfo.Slot].Channels[J].RangeIndex mod 2) = 0;
        lOffset := (3 - J) * 8;
        lWords[lOffset + 1] := Ord((lAmplif and 2) <> 0);
        lWords[lOffset + 2] := Ord((lAmplif and 1) <> 0);
        lWords[lOffset + 3] := AConfig.Slots[lInfo.Slot].Channels[J].Integrator;
        lWords[lOffset + 4] := AConfig.Slots[lInfo.Slot].Channels[J].Lpf;
        lWords[lOffset + 5] := AConfig.Slots[lInfo.Slot].Channels[J].Hpf;
        lWords[lOffset + 6] := Ord(not lAtt);
      end;
    end
    else
    begin
      lWords[21] := Ord((AConfig.Slots[lInfo.Slot].Commutator and 1) <> 0);
      lWords[22] := Ord((AConfig.Slots[lInfo.Slot].Commutator and 2) <> 0);
      for J := 0 to CMc201MaxModuleChannels - 1 do
      begin
        lAmplif := AConfig.Slots[lInfo.Slot].Channels[J].RangeIndex div 2;
        lAtt := (AConfig.Slots[lInfo.Slot].Channels[J].RangeIndex mod 2) = 0;
        lOffset := (J div 2) * 8;
        lIsOdd := J mod 2;
        lWords[lOffset + lIsOdd * 2 + 1] := Ord((lAmplif and 1) <> 0);
        lWords[lOffset + lIsOdd * 2 + 2] := Ord((lAmplif and 2) <> 0);
        lWords[lOffset + lIsOdd + 5] := AConfig.Slots[lInfo.Slot].Channels[J].Hpf;
        lWords[lOffset + lIsOdd + 7] := Ord(lAtt);
        lWords[17 + J] := AConfig.Slots[lInfo.Slot].Channels[J].Integrator;
      end;
    end;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSendControlRegister, lWords, 0,
      lReply, 'SEND_2_CONT_REG_CC') then
      Exit;

    { После установки свойств и основного регистра оригинал получает HANDLE
      MM202 и одной командой применяет его накопленное управляющее слово. }
    if AConfig.Slots[lInfo.Slot].SubmoduleType <> 0 then
    begin
      SetLength(lArgs, 1);
      lArgs[0] := CMc201ObjectTypeIcpSubmodule;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdGetObject, lArgs, 2, lReply,
        'MM202 GET_OBJECT') then Exit;
      if (Length(lReply) < 2) or (lReply[0] <> CMc201PropertyOk) then
      begin
        AErrorMessage := Format('MM202 is not available in slot %d',
          [lInfo.Slot]);
        Exit;
      end;
      lSubmoduleHandle := lReply[1];
      SetLength(lArgs, 1);
      lArgs[0] := lSubmoduleHandle;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdSendSubmoduleControl, lArgs,
        2, lReply, 'MM202 SEND_CONTROL_WORD') then Exit;
      if (Length(lReply) < 1) or (lReply[0] <> CMc201PropertyOk) then
      begin
        AErrorMessage := Format('MM202 control word failed in slot %d',
          [lInfo.Slot]);
        Exit;
      end;
    end;

    SetLength(lArgs, 1);
    lArgs[0] := lGridCode;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSetGrid, lArgs, 0, lReply,
      'SET_GRID_CC') then
      Exit;
    lArgs[0] := lFreqCode or (lFreqCode shl 4);
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSetFreq, lArgs, 0, lReply,
      'SET_FREQ_CC') then
      Exit;
    { SEND_BALANCE здесь не повторять. Коды уже установлены после RESET_SCAN,
      как в ModuleMC201::Programming оригинального Recorder. Повторный цикл,
      ранее стоявший после SET_FREQ_CC, нарушал подготовленное состояние scan. }
    lArgs[0] := $000F;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSetChanList, lArgs, 0, lReply,
      'SET_CHAN_LIST_CC') then
      Exit;

    for J := 0 to CMc201MaxModuleChannels - 1 do
    begin
      SetLength(lArgs, 1);
      lArgs[0] := J;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdGetFinalFlag, lArgs, 1,
        lReply, 'GET_FINAL_FLAG_CC') then
        Exit;
      if Length(lReply) > 0 then
        fProgramInfo[C].FinalFlags[J] := lReply[0] or CMc201IsDm;
    end;
    Inc(C);
  end;

  if not fClient.GetInternalMemHeap(CMc201BiosScanContextWords, lScanPage,
    lScanAddr, AErrorMessage) then
    Exit;
  SetLength(lArgs, 5);
  lArgs[0] := CMc201ScanTypeMc201;
  lArgs[1] := CMc201ScanIdDefault;
  lArgs[2] := lInternalDivider;
  lArgs[3] := lScanAddr;
  lArgs[4] := lScanPage;
  if not CallCC(CMc201CmdAppendScanMain, lArgs, 'APPENDSCANMAIN') then
    Exit;

  if not fClient.GetInternalMemHeap(lModuleCount * CMc201MaxModuleChannels *
    CMc201DescChanWords, lChanPage, lChanAddr, AErrorMessage) then
    Exit;
  C := 0;
  for I := 0 to High(fProgramInfo) do
    for J := 0 to CMc201MaxModuleChannels - 1 do
    begin
      SetLength(lArgs, 6);
      lArgs[0] := CMc201ScanIdDefault;
      lArgs[1] := fProgramInfo[I].Slot;
      lArgs[2] := fProgramInfo[I].FinalFlags[J] and $7FFF;
      lArgs[3] := lFifoPerChan;
      lArgs[4] := lChanAddr + C * CMc201DescChanWords;
      lArgs[5] := lChanPage;
      if not CallCC(CMc201CmdAddChannelModule, lArgs, 'ADDCHANNELMODULE') then
        Exit;
      Inc(C);
    end;

  SetLength(lArgs, 4);
  lArgs[0] := CMc201ScanIdDefault;
  lArgs[1] := lModuleCount * CMc201MaxModuleChannels;
  lArgs[2] := lChanAddr;
  lArgs[3] := lChanPage;
  if not CallCC(CMc201CmdScanSetChans, lArgs, 'SCAN_SET_CHANS') then
    Exit;

  { CCWDInterface::Config оригинального Recorder создаёт в памяти КК кольцевой
    массив BIOS-сообщений. Без CMD_CONFIG_MESSAGE скан получает успешный ACK,
    но MC-032 не формирует поток сообщений для Ethernet. }
  if not fClient.GetInternalMemHeap(CMc201BiosMessageArrayWords,
    lMessagePage, lMessageAddr, AErrorMessage) then
    Exit;
  SetLength(lArgs, 3);
  lArgs[0] := lMessageAddr;
  lArgs[1] := lMessagePage;
  lArgs[2] := CMc201BiosMessageArrayWords;
  Progress('CONFIG_MESSAGE');
  if not fClient.CallCommand(CMc201CmdConfigMessage, lArgs, 4, lReply,
    AErrorMessage) then
  begin
    AErrorMessage := 'CONFIG_MESSAGE failed: ' + AErrorMessage;
    Exit;
  end;

  { Триггеры уже настроены до ModuleMC201::Programming. Старый блок ниже
    оставлен временно видимым при сверке с оригиналом, но выполняться не должен. }
  { В оригинальном CCDevice::OnProgramming конфигурация стартовых триггеров
    и START_TRIGGERSTARTADC выполняются после программирования всех модулей
    и создания BIOS-скана. Более ранний запуск разрушается последующими
    STOP_SCAN/RESET_SCAN и на холодном контроллере не создаёт поток. }
  if not ConfigureStartTriggers then
    Exit;
  Sleep(350);
  if False then
  begin
  for I := 0 to High(fProgramInfo) do
  begin
    SetLength(lArgs, 1);
    lArgs[0] := fProgramInfo[I].Slot;
    if not CallCC(CMc201CmdAddListStartAdcModuleIdma, lArgs,
      'ADD_LISTSTARTADCMODULEIDMA') then
      Exit;
  end;

  for I := High(fProgramInfo) downto 0 do
  begin
    SetLength(lArgs, 1);
    lArgs[0] := ModuleTimeoutCycle((High(fProgramInfo) - I) *
      ((23 + 11 + 2 + 1) / 32000000.0));
    if not CallMod(fProgramInfo[I].Slot, CMc201ModuleCmdSetTimeoutStartAdc,
      lArgs, 0, lReply, 'SET_TIMEOUTSTARTADC_201') then
      Exit;
  end;

  SetLength(lArgs, 3);
  { Старые отсчёты, уже собранные до смены кода ЦАП, не должны попадать
    в следующую 60-мс оценку среднего. }
  SetLength(fStreamBuffer, 0);
  lArgs[0] := 0;
  lArgs[1] := 0;
  lArgs[2] := 1;
  if not CallCC(CMc201CmdConfigSyncStart, lArgs, 'CONFIG_SYNC_START') then
    Exit;

  for I := 0 to CMc201CrateMaxStartSlots - Length(fProgramInfo) - 1 do
  begin
    SetLength(lArgs, 2);
    lArgs[0] := 0;
    lArgs[1] := I;
    if not CallCC(CMc201CmdAddListStartModuleIdma, lArgs,
      'ADD_LISTSTARTMODULEIDMA empty') then
      Exit;
  end;

  for I := 0 to High(fProgramInfo) do
  begin
    SetLength(lArgs, 2);
    lArgs[0] := 1;
    lArgs[1] := fProgramInfo[I].Slot;
    if not CallCC(CMc201CmdAddListStartModuleIdma, lArgs,
      'ADD_LISTSTARTMODULEIDMA') then
      Exit;
  end;

  SetLength(lArgs, 1);
  lArgs[0] := Trunc((((25 + 9 + 2 + 11) / (2.0 * 16384000.0)) -
    (5 / 32000000.0) - ((2 + 2) / 32000000.0)) * 32000000.0 + 1);
  if lArgs[0] < 1 then
    lArgs[0] := 1;
  if not CallCC(CMc201CmdSetTimeoutStartTimer, lArgs,
    'SET_TIMEOUTSTARTTIMER') then
    Exit;

  for I := High(fProgramInfo) downto 0 do
  begin
    SetLength(lArgs, 1);
    lArgs[0] := ModuleTimeoutCycle((High(fProgramInfo) - I) *
      ((28 + 11 + 2 + 2) / 32000000.0));
    if not CallMod(fProgramInfo[I].Slot, CMc201ModuleCmdSetTimeoutStart,
      lArgs, 0, lReply, 'SET_TIMEOUTSTART_201') then
      Exit;
  end;

  if not CallCC(CMc201CmdStartTriggerStartAdc, nil,
    'START_TRIGGERSTARTADC') then
    Exit;
  Sleep(350);
  end;

  Result := True;
end;

procedure TMc032Device.EnsureConnected;
begin
  if fState = mcsDisconnected then
    Connect;
  if (fClient = nil) or (fState = mcsDisconnected) then
    raise EMc032Device.Create('MC032 is not connected');
end;

procedure TMc032Device.StopReadThread;
begin
  if fReadThread <> nil then
  begin
    fReadThread.Terminate;
    fReadThread.WaitFor;
    FreeAndNil(fReadThread);
  end;
end;

procedure TMc032Device.Connect;
var
  lError: string;
begin
  if not TryConnect(lError) then
    raise EMc032Device.Create(lError);
end;

{ Путь подключения для GUI. Обычные timeout/refused возвращаются текстом и
  оставляют устройство отключенным; Connect оборачивает этот метод там, где для
  CLI/внутреннего кода удобнее исключение. }
function TMc032Device.TryConnect(out AErrorMessage: string): Boolean;
var
  lError: string;
begin
  Result := False;
  AErrorMessage := '';
  if fState <> mcsDisconnected then
    Exit(True);
  FreeAndNil(fClient);
  SetLength(fStreamBuffer, 0);
  fClient := TMc201LegacyMdpClient.Create(fHost, fPort, fTimeoutMs);
  try
    if not fClient.TryConnect(AErrorMessage) then
    begin
      FreeAndNil(fClient);
      fState := mcsDisconnected;
      Exit;
    end;
    if not fClient.ReadControllerBios(fBios, lError) then
    begin
      AErrorMessage := 'CMD_REPLY failed: ' + lError;
      FreeAndNil(fClient);
      fState := mcsDisconnected;
      Exit;
    end;
    fState := mcsConnected;
    Result := True;
  except
    on E: Exception do
    begin
      AErrorMessage := E.Message;
      FreeAndNil(fClient);
      fState := mcsDisconnected;
    end;
  end;
end;

procedure TMc032Device.Disconnect;
var
  lError: string;
begin
  Stop(lError);
  ForceDisconnect(False);
end;

procedure TMc032Device.ForceDisconnect(AClearProgram: Boolean);
begin
  fOnData := nil;
  StopReadThread;
  SetLength(fStreamBuffer, 0);
  FreeAndNil(fClient);
  fState := mcsDisconnected;
  if AClearProgram then
  begin
    SetLength(fProgramInfo, 0);
    SetLength(fLastModules, 0);
  end;
end;

function TMc032Device.Search(out AFoundHost: string;
  out AErrorMessage: string): Boolean;
begin
  AFoundHost := '';
  Result := TestConnection(AErrorMessage);
  if Result then
    AFoundHost := fHost;
end;

function TMc032Device.TestConnection(out AErrorMessage: string): Boolean;
var
  lOwnClient: Boolean;
  lReply: TMc201WordArray;
  lTestData: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  lOwnClient := fClient = nil;
  try
    try
      if lOwnClient then
      begin
        fClient := TMc201LegacyMdpClient.Create(fHost, fPort, fTimeoutMs);
        if not fClient.TryConnect(AErrorMessage) then
          Exit;
      end;
      SetLength(lTestData, 32);
      Result := fClient.CallCommand(CMc201CmdTestLoad, lTestData, 2, lReply,
        AErrorMessage) and (Length(lReply) > 0) and (lReply[0] = 1);
      if (not Result) and (AErrorMessage = '') then
        AErrorMessage := 'TEST_LOAD returned unexpected reply';
    except
      on E: Exception do
      begin
        AErrorMessage := E.Message;
        Result := False;
      end;
    end;
  finally
    if lOwnClient then
      FreeAndNil(fClient);
  end;
end;

function TMc032Device.ReadSlotInfo(ASlot: Word; out AInfo: TMc201SlotInfo;
  out AErrorMessage: string): Boolean;
var
  lHi: Word;
  lLo: Word;
begin
  FillChar(AInfo, SizeOf(AInfo), 0);
  AInfo.Slot := ASlot;
  Result := fClient.ReadFlashWord(ASlot, CMc201FlashTypeOffset,
    AInfo.TypeId, AErrorMessage);
  if not Result then
    Exit;
  if (AInfo.TypeId = 0) or (AInfo.TypeId = $FFFF) then
    Exit(True);
  Result := fClient.ReadFlashWord(ASlot, CMc201FlashVersionOffset,
    AInfo.VersionCode, AErrorMessage);
  if not Result then
    Exit;
  lLo := 0;
  lHi := 0;
  if not fClient.ReadFlashWord(ASlot, CMc201FlashSerialLoOffset, lLo,
    AErrorMessage) then
    Exit(False);
  if not fClient.ReadFlashWord(ASlot, CMc201FlashSerialHiOffset, lHi,
    AErrorMessage) then
    Exit(False);
  AInfo.SerialLo := lLo;
  AInfo.SerialHi := lHi;
  AInfo.Serial := Word((lHi shl 8) or lLo);
  AInfo.IsMc201 := (AInfo.TypeId = CMc201FlashTypeId) and
    Mc201IsKnownVersionCode(AInfo.VersionCode);
  AInfo.IsMc201A := AInfo.IsMc201 and (AInfo.VersionCode = CMc201AVersionCode);
  Result := True;
end;

function TMc032Device.SearchModules(AMaxSlots: Word;
  out AModules: TMc201SlotInfoArray; out AErrorMessage: string): Boolean;
var
  I: Word;
  lInfo: TMc201SlotInfo;
  lUsedCount: Integer;
begin
  Result := False;
  SetLength(AModules, 0);
  AErrorMessage := '';
  try
    EnsureConnected;
    lUsedCount := 0;
    for I := 0 to AMaxSlots - 1 do
    begin
      if not ReadSlotInfo(I, lInfo, AErrorMessage) then
        Exit;
      if (lInfo.TypeId = 0) or (lInfo.TypeId = $FFFF) then
        Continue;
      SetLength(AModules, lUsedCount + 1);
      AModules[lUsedCount] := lInfo;
      Inc(lUsedCount);
    end;
    fLastModules := Copy(AModules, 0, Length(AModules));
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.Reset(out AErrorMessage: string): Boolean;
var
  lReply: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    Result := fClient.CallCommand(CMc201CmdReset, nil, 0, lReply, AErrorMessage);
    if Result then
    begin
      { CMD_RESET перезапускает BIOS крейт-контроллера и сбрасывает RAM
        модулей. Локальный cache загруженных BIOS после этого недействителен. }
      fClient.InvalidateLoadedBios;
      SetLength(fProgramInfo, 0);
    end;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

{ Config сделан повторяемым для GUI. Если после прошлого неудачного запуска
  модуль отвергает программирование скана, устройство делает один
  reset/reconnect и повторяет последовательность, близкую к оригинальному
  Recorder. }
function TMc032Device.Config(const AConfig: TMc032Config;
  out AErrorMessage: string): Boolean;
var
  lRetryError: string;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    fConfig := AConfig;
    fClient.TimeoutMs := AConfig.ReadTimeoutMs;
    { Холодный запуск должен быть самодостаточным, без предварительного запуска
      оригинального Recorder. Как CCDevice::Reset оригинала, перезапускаем BIOS
      контроллера, затем создаём новую TCP-сессию и заново читаем слоты. }
    if not Reset(AErrorMessage) then
      Exit;
    Disconnect;
    Sleep(1500);
    Connect;
    SetLength(fLastModules, 0);
    Result := ProgramMc201Scan(AConfig, AErrorMessage);
    if (not Result) and (fState = mcsConnected) then
    begin
      lRetryError := AErrorMessage;
      if Reset(AErrorMessage) then
      begin
        Disconnect;
        Sleep(1500);
        Connect;
        SetLength(fLastModules, 0);
        Result := ProgramMc201Scan(AConfig, AErrorMessage);
      end
      else
        AErrorMessage := lRetryError + '; reset failed: ' + AErrorMessage;
    end;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.ConfigKeepSession(const AConfig: TMc032Config;
  out AErrorMessage: string): Boolean;
var
  lRetryError: string;
  lOldTimeout: Cardinal;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    fConfig := AConfig;
    lOldTimeout := fClient.TimeoutMs;
    if AConfig.ReadTimeoutMs > lOldTimeout then
      fClient.TimeoutMs := AConfig.ReadTimeoutMs;
    if fClient.TimeoutMs < 5000 then
      fClient.TimeoutMs := 5000;
    Result := ProgramMc201Scan(AConfig, AErrorMessage);
    if Result then
      Exit;
    if fState <> mcsConnected then
      Exit;
    lRetryError := AErrorMessage;
    Progress('ConfigKeepSession: Program failed, CMD_RESET + retry (no disconnect)');
    if not Reset(AErrorMessage) then
    begin
      AErrorMessage := lRetryError + '; reset failed: ' + AErrorMessage;
      Exit;
    end;
    Sleep(1500);
    SetLength(fLastModules, 0);
    Result := ProgramMc201Scan(AConfig, AErrorMessage);
    if not Result then
      AErrorMessage := lRetryError + '; retry: ' + AErrorMessage;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.Play(AOnData: TMc032DataCallback;
  out AErrorMessage: string): Boolean;
var
  lDrained: Integer;
  lReply: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    if fState = mcsPlay then
      Exit(True);
    fOnData := AOnData;
    fPacketIndex := 0;
    fReceivedPacketCount := 0;
    fRawPacketCount := 0;
    SetLength(fStreamBuffer, 0);
    if fClient.DrainPackets(20, lDrained, AErrorMessage) and
      (lDrained > 0) then
      Progress(Format('RX drained before STARTSCANMAIN: %d packets',
        [lDrained]));
    if not fClient.CallCommand(CMc201CmdStartScanMain, nil, 0, lReply,
      AErrorMessage) then
      Exit;
    fState := mcsPlay;
    fReadThread := TMc032ReadThread.Create(Self);
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

procedure TMc032Device.PauseStreamingReader;
begin
  { Скан контроллера не останавливаем: на время служебного измерения убираем
    только конкурирующего потребителя TCP-потока. }
  StopReadThread;
end;

procedure TMc032Device.ResumeStreamingReader;
begin
  if (fState = mcsPlay) and (fReadThread = nil) and Assigned(fOnData) then
    fReadThread := TMc032ReadThread.Create(Self);
end;

function TMc032Device.StartRawScan(out AErrorMessage: string): Boolean;
var
  lDrained: Integer;
  lReply: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    if fState = mcsPlay then
      Exit(True);
    fOnData := nil;
    fPacketIndex := 0;
    fRawPacketCount := 0;
    if fClient.DrainPackets(20, lDrained, AErrorMessage) and
      (lDrained > 0) then
      Progress(Format('RX drained before STARTSCANMAIN: %d packets',
        [lDrained]));
    if not fClient.CallCommand(CMc201CmdStartScanMain, nil, 0, lReply,
      AErrorMessage) then
      Exit;
    fState := mcsPlay;
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.ReadRawPacket(out APort: Word;
  out AWords: TMc201WordArray): Boolean;
begin
  EnsureConnected;
  Result := fClient.ReadRawPacket(APort, AWords);
end;

function TMc032Device.TryExtractStreamMessage(
  out AWords: TMc201WordArray): Boolean;
var
  I: Integer;
  lSizeWords: Word;
begin
  Result := False;
  SetLength(AWords, 0);
  while Length(fStreamBuffer) >= CMc201BiosMessageHeaderWords do
  begin
    lSizeWords := fStreamBuffer[1];
    if (fStreamBuffer[0] <> 0) or
      (lSizeWords < CMc201BiosMessageHeaderWords) or
      (lSizeWords > CMc201BiosMessageMaxWords) then
    begin
      for I := 1 to High(fStreamBuffer) do
        fStreamBuffer[I - 1] := fStreamBuffer[I];
      SetLength(fStreamBuffer, Length(fStreamBuffer) - 1);
      Continue;
    end;
    if Length(fStreamBuffer) < lSizeWords then
      Exit;
    SetLength(AWords, lSizeWords);
    Move(fStreamBuffer[0], AWords[0], lSizeWords * SizeOf(Word));
    for I := lSizeWords to High(fStreamBuffer) do
      fStreamBuffer[I - lSizeWords] := fStreamBuffer[I];
    SetLength(fStreamBuffer, Length(fStreamBuffer) - lSizeWords);
    Exit(True);
  end;
end;

function TMc032Device.ReadRawMessage(out APort: Word;
  out AWords: TMc201WordArray): Boolean;
var
  I, lOldLength: Integer;
  lPacket: TMc201WordArray;
begin
  EnsureConnected;
  if TryExtractStreamMessage(AWords) then
    Exit(True);
  repeat
    if not fClient.ReadRawPacket(APort, lPacket) then
      Exit(False);
    Inc(fRawPacketCount);
    { Первые пакеты после START позволяют отличить отсутствие потока в TCP
      от ошибки склейки BIOS-сообщений. Не логируем весь высокочастотный поток. }
    if fRawPacketCount <= 8 then
    begin
      if Length(lPacket) >= 2 then
        Progress(Format('RX raw #%d port=%d words=%d head=[%u %u]',
          [fRawPacketCount, APort, Length(lPacket), lPacket[0], lPacket[1]]))
      else
        Progress(Format('RX raw #%d port=%d words=%d',
          [fRawPacketCount, APort, Length(lPacket)]));
    end;
    if APort = CMc201MdpStreamCommand then
      Continue;
    lOldLength := Length(fStreamBuffer);
    SetLength(fStreamBuffer, lOldLength + Length(lPacket));
    for I := 0 to High(lPacket) do
      fStreamBuffer[lOldLength + I] := lPacket[I];
  until TryExtractStreamMessage(AWords);
  Result := True;
end;

function TMc032Device.SendBalanceDac(ASlot, AChannel, ACodeLo,
  ACodeHi: Word; out AErrorMessage: string): Boolean;
var
  lArgs, lReply: TMc201WordArray;
  lDrained: Integer;
  lErr: string;
begin
  Result := False;
  AErrorMessage := '';
  if fClient = nil then
  begin
    AErrorMessage := 'MC-032 is not connected';
    Exit;
  end;
  SetLength(lArgs, 3);
  lArgs[0] := AChannel;
  lArgs[1] := ACodeLo and $00ff;
  lArgs[2] := ACodeHi and $00ff;
  { Без длинных retry в потоке — иначе диалог «висит» по 15с×4 на канал. }
  fClient.DrainPackets(20, lDrained, lErr);
  if fClient.CallCommandModuleIdmaActivated(ASlot,
    CMc201ModuleCmdSendBalance, lArgs, 0, lReply, AErrorMessage) then
    Exit(True);
  fClient.DrainPackets(30, lDrained, lErr);
  if fClient.CallCommandModuleIdmaNotActivated(ASlot,
    CMc201ModuleCmdSendBalance, lArgs, 0, lReply, AErrorMessage) then
    Exit(True);
  AErrorMessage := Format('SEND_BALANCE_CC failed slot=%d channel=%d: %s',
    [ASlot + 1, AChannel + 1, AErrorMessage]);
end;

function TMc032Device.Stop(out AErrorMessage: string): Boolean;
var
  lReply: TMc201WordArray;
  lOldTimeout: Cardinal;
  lPort: Word;
  lWords: TMc201WordArray;
  lDeadline: QWord;
  lDrained: Integer;
  lErr: string;
begin
  Result := True;
  AErrorMessage := '';
  if (fClient = nil) or (fState <> mcsPlay) then
    Exit;
  StopReadThread;
  SetLength(fStreamBuffer, 0);
  lOldTimeout := fClient.TimeoutMs;
  try
    { Stop — teardown, а не управляющая операция. Не держим UI 15 секунд:
      штатного command timeout достаточно. }
    Result := fClient.CallCommand(CMc201CmdStopScanMain, nil, 0, lReply,
      AErrorMessage);
  finally
    fClient.TimeoutMs := lOldTimeout;
  end;
  if Result then
  begin
    fState := mcsConnected;
    Exit;
  end;
  { Не ForceDisconnect: обрыв TCP после потока «убивал» контроллер до сброса
    оригиналом. STOP no-wait + drain — сессия для ProgramDevice остаётся. }
  Progress('Stop: reply missed, no-wait + drain (keep TCP): ' + AErrorMessage);
  { Ошибка записи означает закрытый peer. Повторная запись гарантированно
    создаёт второй EMc201MdpProtocol в отладчике и ничего не останавливает. }
  if Pos('write failed', LowerCase(AErrorMessage)) > 0 then
  begin
    ForceDisconnect(False);
    AErrorMessage := '';
    Exit(True);
  end;
  if not fClient.SendCommandNoWait(CMc201CmdStopScanMain, nil, lErr) then
  begin
    ForceDisconnect(False);
    AErrorMessage := '';
    Exit(True);
  end;
  lOldTimeout := fClient.TimeoutMs;
  lDrained := 0;
  try
    fClient.TimeoutMs := 50;
    lDeadline := GetTickCount64 + 1000;
    while GetTickCount64 < lDeadline do
    begin
      if not fClient.ReadRawPacket(lPort, lWords) then
        Break;
      Inc(lDrained);
    end;
  finally
    fClient.TimeoutMs := lOldTimeout;
  end;
  SetLength(fStreamBuffer, 0);
  fState := mcsConnected;
  AErrorMessage := '';
  Result := True;
  Progress(Format('Stop soft-ok keep-TCP drained=%d', [lDrained]));
end;

function TMc032Device.StopAfterHeavyStream(out AErrorMessage: string): Boolean;
var
  lOldTimeout: Cardinal;
  lPort: Word;
  lWords: TMc201WordArray;
  lReply: TMc201WordArray;
  lDeadline: QWord;
  lQuietSince: QWord;
  lDrained: Integer;
  lAckCount: Integer;
  lErr: string;
  lGotAck: Boolean;
  lQuietOk: Boolean;
begin
  { 1) CallCommand(STOP) как prepare — сам вычитывает хвост до reply.
    2) Если timeout: no-wait + drain; quiet без ACK тоже OK (лог: ack=0
    quiet=True — поток встал, ACK на fire-and-forget часто нет).
    Не слать второй CallCommand(STOP) после quiet — глушит CC. }
  Result := False;
  AErrorMessage := '';
  if (fClient = nil) or (fState <> mcsPlay) then
  begin
    Result := True;
    Exit;
  end;
  StopReadThread;
  SetLength(fStreamBuffer, 0);

  lOldTimeout := fClient.TimeoutMs;
  try
    if fClient.TimeoutMs < 3000 then
      fClient.TimeoutMs := 3000;
    Progress('StopAfterHeavyStream: CallCommand STOP');
    if fClient.CallCommand(CMc201CmdStopScanMain, nil, 0, lReply,
      AErrorMessage) then
    begin
      fState := mcsConnected;
      AErrorMessage := '';
      Progress('StopAfterHeavyStream CallCommand STOP ok');
      Exit(True);
    end;
  finally
    fClient.TimeoutMs := lOldTimeout;
  end;
  Progress('StopAfterHeavyStream CallCommand miss: ' + AErrorMessage);

  if not fClient.SendCommandNoWait(CMc201CmdStopScanMain, nil, lErr) then
  begin
    AErrorMessage := 'STOPSCANMAIN no-wait failed: ' + lErr;
    Exit;
  end;

  lOldTimeout := fClient.TimeoutMs;
  lDrained := 0;
  lAckCount := 0;
  lGotAck := False;
  lQuietOk := False;
  try
    fClient.TimeoutMs := 50;
    lDeadline := GetTickCount64 + 12000;
    lQuietSince := 0;
    while GetTickCount64 < lDeadline do
    begin
      if fClient.ReadRawPacket(lPort, lWords) then
      begin
        if lPort = CMc201MdpStreamCommand then
        begin
          lGotAck := True;
          Inc(lAckCount);
        end
        else
          Inc(lDrained);
        lQuietSince := 0;
        Continue;
      end;
      if lQuietSince = 0 then
        lQuietSince := GetTickCount64
      else if GetTickCount64 - lQuietSince >= 400 then
      begin
        lQuietOk := True;
        Break;
      end;
    end;
  finally
    fClient.TimeoutMs := lOldTimeout;
  end;
  SetLength(fStreamBuffer, 0);
  fState := mcsConnected;
  Progress(Format(
    'StopAfterHeavyStream drained=%d ack=%d quiet=%s',
    [lDrained, lAckCount, BoolToStr(lQuietOk, True)]));
  if not (lGotAck or lQuietOk) then
  begin
    AErrorMessage := Format(
      'STOPSCANMAIN no quiet drained=%d', [lDrained]);
    Exit;
  end;
  AErrorMessage := '';
  Result := True;
end;

procedure TMc032Device.HandleThreadPacket(APort: Word;
  const AWords: TMc201WordArray);
var
  I: Integer;
  lMessage: TMc201WordArray;
  lOldLength: Integer;
  lSizeWords: Word;
begin
  if not Assigned(fOnData) then
    Exit;
  if APort = CMc201MdpStreamCommand then
    Exit;

  lOldLength := Length(fStreamBuffer);
  SetLength(fStreamBuffer, lOldLength + Length(AWords));
  for I := 0 to High(AWords) do
    fStreamBuffer[lOldLength + I] := AWords[I];

  while Length(fStreamBuffer) >= CMc201BiosMessageHeaderWords do
  begin
    lSizeWords := fStreamBuffer[1];
    if (fStreamBuffer[0] <> 0) or
      (lSizeWords < CMc201BiosMessageHeaderWords) or
      (lSizeWords > CMc201BiosMessageMaxWords) then
    begin
      for I := 1 to High(fStreamBuffer) do
        fStreamBuffer[I - 1] := fStreamBuffer[I];
      SetLength(fStreamBuffer, Length(fStreamBuffer) - 1);
      Continue;
    end;
    if Length(fStreamBuffer) < lSizeWords then
      Break;

    SetLength(lMessage, lSizeWords);
    for I := 0 to lSizeWords - 1 do
      lMessage[I] := fStreamBuffer[I];
    QueueStreamMessage(APort, lMessage);

    for I := lSizeWords to High(fStreamBuffer) do
      fStreamBuffer[I - lSizeWords] := fStreamBuffer[I];
    SetLength(fStreamBuffer, Length(fStreamBuffer) - lSizeWords);
  end;
end;

procedure TMc032Device.QueueStreamMessage(APort: Word;
  const AWords: TMc201WordArray);
var
  lPacket: TMc032DataPacket;
  lQueued: TMc032QueuedPacket;
begin
  Inc(fReceivedPacketCount);
  lPacket.StreamPort := APort;
  lPacket.PacketIndex := fReceivedPacketCount;
  lPacket.Words := Copy(AWords, 0, Length(AWords));
  Inc(fPacketIndex);
  lQueued := TMc032QueuedPacket.Create(Self, fOnData, lPacket);
  TThread.Queue(nil, @lQueued.Deliver);
end;

end.
