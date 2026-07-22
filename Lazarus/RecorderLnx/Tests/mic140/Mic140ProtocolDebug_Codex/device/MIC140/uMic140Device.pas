unit uMic140Device;

{
  MIC-140 (Codex debug stand).

  TMic140MdpConnection — persistent TCP, аналог hMDP (CCMC031EthernetInterface).
  TMic140_48            — scan program (mic140ppext + MC114 timer + ChanDump).
  TRecorderMic140Device — IRecorderDevice.

  NB: В оригинальном Recorder Ethernet-интерфейс (Mc031) имеет STUB для
  MeasureFreqCCFromFreqModule — реальная реализация была только в PCI (CCWDInterface).
  Здесь мы реализуем измерение через MDP/TCP напрямую.

  См. Docs/devices/mic140/protocol/*.md
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uRecorderDeviceInterfaces
  {$IFDEF MSWINDOWS}, Windows, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

const
  { --- Ёмкость и идентификация модуля MIC-140-48 --- }
  MIC140_48_AIN_COUNT = 48;              // число аналоговых входов AIn (ME048)
  MIC140_48_TIN_VISIBLE_COUNT = 3;       // число видимых TIn (T1..T3)
  MIC140_48_TIN_INTERNAL_COUNT = 12;     // число слотов TIn в области DM
  MIC140_48_RANGE_COUNT = 3;             // диапазоны усиления: 80mV / 800mV / 8V
  MIC140_48_MODULE_TYPE = 12;            // тип модуля для APPENDSCANMAIN (82)
  MIC140_48_SCAN_ID = 0;                 // id главного скана

  { --- Базовая частота и кадровый таймер MC114 --- }
  { Номинал кварца ADSP-218x = 16 МГц.
    В оригинальном Recorder: MIC140_96_rce\mic140_96mod.cpp:
      const DWORD FREQ_CLK = 16000000;
      SetSelfClk(SELF_CLK); SetFreqClk(FREQ_CLK);
    Ethernet-интерфейс MeasureFreqCCFromFreqModule — заглушка (return ERROR_NOERROR),
    поэтому частота кварца НЕ измеряется через TCP, а всегда берётся номинал. }
  MIC140_48_FREQ_CLK_HZ = 16000000.0;          // номинал кварца ADSP (16 МГц)
  MIC140_48_RECORDER_DEFAULT_FREQ_HZ = 10.0;   // Recorder channel Fs remains 10 Hz
  MIC140_48_TIMER_PERIOD = 640;                 // тиков кода на один тик супервизора (20 мкс)
  PERIOD_TIMER_WORK = 112;                      // длительность ISR кадрового таймера (80+32 тиков)

  { --- Фиксированные участки микроциклограммы канального слота (тики кода) --- }
  MIC140_48_PERIOD_2_CHAN_CODE = 27;   // «старт АЦП → RegLatch» (T_proc)
  MIC140_48_PERIOD_1_CHAN_CODE = 30;   // «прерывание → старт АЦП»
  MIC140_48_PERIOD_3_CHAN_CODE = 59;   // «RegLatch → старт SPORT» (фаза decay)
  MIC140_48_PERIOD_21_CHAN_CODE = 21;  // «старт АЦП → старт SPORT» (фаза усреднения)
  MIC140_48_PERIOD_4_CHAN_CODE = 120;  // «RegLatch → конец прерывания» (Tgnd min)
  MIC140_48_DELTA_SPORT = 11;         // поправка драйвера SPORT при len=3
  MIC140_48_PERIOD_PROG_CHAN_CODE = (4 + 1) * 2 * (16 * 2 + (16 + 3)); // время программирования ME048

  { --- Пределы усреднения ΣΔ-АЦП --- }
  MIC140_48_MIN_COUNT_AVER = 1;        // минимум count_aver
  MIC140_48_MAX_COUNT_AVER = 32767;    // максимум count_aver (ограничение прошивки)
  MIC140_48_PERIOD_AVER_US = 5.0;      // период одного отсчёта ΣΔ, мкс (Fs_ADC ≈ 200 кГц)

  { --- MDP-протокол (TCP) --- }
  MIC140_MDP_SYNC_WORD = $12B8;        // маркер начала MDP-пакета
  MIC140_MDP_STREAM_CMD = 1;           // порт командного канала
  MIC140_CMD_TEST_LOAD = 7;            // команда загрузки теста (проверка связи)
  MIC140_CMD_REPLY = 113;              // чтение TBiosInfoMC031 (11 слов)
  MIC140_MAX_TX_WORDS = 32;            // макс. слов аргументов в одном пакете
  MIC140_BIOS_INFO_WORDS = 11;         // слов в ответе CMD_REPLY
  MIC140_CMD_TIMEOUT_MS = 5000;        // таймаут TCP send/recv, мс
  MIC140_CMD_MEASURE_FREQ_MODULE = 12; // команда измерения частоты модуля
  MIC140_MODULE_CMD_MEASURE_FREQ = $8008; // подкоманда CMD_MEASURE_FREQ
  MIC140_DEFAULT_MEASURE_TIME_SEC = 0.1;  // время измерения по умолчанию, с
  MIC140_DEFAULT_MODULE_SLOT = 0;         // слот модуля по умолчанию

  { --- Команды чтения памяти --- }
  MIC140_CMD_READMEMDM      = 114; // CMD_READMEMDM — чтение DM MC031
  MIC140_CMD_IDMAGETARRAY   = 77;  // CMD_IDMAGETARRAY — чтение DM модуля через IDMA
  MIC140_CMD_IDMACALLCOMMAND= 74;  // CMD_IDMACALLCOMMAND — вызов команды модуля через IDMA
  MIC140_CMD_READEEPROM     = 126; // CMD_READEEPROM — чтение EEPROM
  MIC140_IS_DM = $4000;            // флаг DM-пространства в адресе

type
  TMic140ClockMeasureMethod = (mcmNone, mcmMeasureFreqModule, mcmNominal);

  TMic140ClockMeasureResult = record
    Ok: Boolean;
    ModuleClockHz: Double;
    ActualFrequencyHz: Double;
    Method: TMic140ClockMeasureMethod;
    ErrorText: string;
  end;

  TMic140ScanTiming = record
    FrequencyHz: Double;
    PeriodDecayUs: Double;
    PeriodDecay2Us: Double;
    PeriodAverageUs: Double;
    AverageSampleCount: Word;
    AutoCalcPeriodDelay: Boolean;
    LegacyChannelDelaySport: Word;
    LegacyGroundDelaySport: Word;
    LegacyAverageDelaySport: Word;
  end;

  TMic140Mc114Timer = record
    ModuleClockHz: Double;
    ActualFrequencyHz: Double;
    TimerScaleMinus1: Word;
    TimerPeriodMinus1: Word;
    ScanDivider: Word;
  end;

  TMic140FifoProgram = record
    DataUpdateMs: Cardinal;
    PayloadStride: Integer;
    FifoReadyWords: Word;
    FifoCapacityWords: Word;
    TinVisibleSlots: Integer;
  end;

  TMic140ScanFlags = record
    AllChannelsSample: Boolean;
    ChannelGround: Boolean;
    ThermoCompensation: Boolean;
  end;

  TMic140ChanDumpProgram = record
    VisibleAInCount: Word;
    BiosSlotCount: Integer;
    UseGroundPointers: Boolean;
  end;

  TMic140AInChannelProgram = record
    UiChannelIndex: Integer;
    PhysicalMe048Input: Integer;
    Enabled: Boolean;
    RangeIndex: Integer;
    CommutIndex: Integer;
    BoardCommutIndex: Integer;
    RegDesc: Word;
    Me048Word0: Word;
    Me048Word1: Word;
    ChannelDelaySport: Word;
    ValueDmOffset: Word;
  end;

  TMic140TInChannelProgram = record
    VisibleIndex: Integer;
    InternalIndex: Integer;
    Enabled: Boolean;
    RegDesc: Word;
    Me048Word0: Word;
    Me048Word1: Word;
    ValueDmOffset: Word;
  end;

  TMic140FirmwareInfo = record
    Signature: Word;
    MdpType: Word;
    DevType: Word;
    DevRev: Word;
    DevSubRev: Word;
    DevSerial: Integer;
    ControllerType: Word;
    ControllerSerial: Word;
    EepromManufactId: Word;
    EepromDeviceId: Word;
    BiosFunction: Word;
    BiosVersion: Word;
  end;

  TMic140_48 = record
    Timing: TMic140ScanTiming;
    Mc114: TMic140Mc114Timer;
    Fifo: TMic140FifoProgram;
    Flags: TMic140ScanFlags;
    ChanDump: TMic140ChanDumpProgram;
    Firmware: TMic140FirmwareInfo;
    DefaultBoardCommutIndex: Integer;
    DefaultRangeIndex: Integer;
    AInChannels: array of TMic140AInChannelProgram;
    TInChannels: array of TMic140TInChannelProgram;
  end;

  { TMic140MdpConnection — persistent TCP, аналог hMDP. }
  TMic140MdpConnection = class
  private
    {$IFDEF MSWINDOWS}
    fSocket: TSocket;
    fWsaReady: Boolean;
    {$ELSE}
    fSocket: cint;
    {$ENDIF}
    fHost: string;
    fPort: Integer;
    fConnected: Boolean;
    fTimeoutMs: Cardinal;
    { TCP send + recv одного MDP-пакета. }
    function SendPacket(const APacket: array of Byte; ASize: Integer;
      out ARet: array of Word; out ARetCount: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    { Открывает TCP-соединение к AHost:APort (аналог CCMC031::Open). }
    function Open(const AHost: string; APort: Integer): Boolean;
    { Закрывает сокет, безопасен для повторного вызова. }
    procedure Close;
    function IsConnected: Boolean;
    { Отправляет MDP-команду ACommand с массивом аргументов AArgs.
      ARetWords — ожидаемое число слов в ответе.
      Все прикладные методы строятся поверх этого. }
    function CallCommandArgs(ACommand: Word; const AArgs: array of Word;
      ARetWords: Integer; out ARet: array of Word;
      out ARetCount: Integer): Boolean;
    { CallCommand без аргументов. }
    function CallCommand(ACommand: Word; ARetWords: Integer;
      out ARet: array of Word; out ARetCount: Integer): Boolean;
    { Двухфазное измерение freq_clk модуля (CCIFC.CPP:1552):
      1) CMD_MEASURE_FREQ_MODULE + start → счётчик C0
      2) Sleep(timeout)
      3) CMD_MEASURE_FREQ_MODULE + stop ($FFFF) → счётчик C1
      Результат: freq = 2 * freq_mod * (count*scale*period) / (C1 - C0).
      NB: в оригинальном Recorder Ethernet-стаб — мы первые, кто это делает через TCP. }
    function MeasureModuleClockHz(AModuleSlot: Word;
      AReferenceClockHz, AMeasureTimeSec: Double;
      out AMeasuredClockHz: Double; out AError: string): Boolean;
    { Чтение DM-памяти MC031 (CMD_READMEMDM). AAddr содержит IS_DM-флаг. }
    function ReadDM(AAddr: Word; ACount: Word;
      out AData: array of Word; out AReadCount: Integer): Boolean;
    { Чтение DM-памяти модуля через IDMA (CMD_IDMAGETARRAY). }
    function ReadModuleDM(ASlot: Word; AAddr: Word; ACount: Word;
      out AData: array of Word; out AReadCount: Integer): Boolean;
    { Вызов BIOS-команды модуля через IDMA (CMD_IDMACALLCOMMAND). }
    function CallCommandModule(ASlot: Word; AModuleCmd: Word;
      const AArgs: array of Word; ARetWords: Word;
      out ARet: array of Word; out ARetCount: Integer): Boolean;
    { Чтение EEPROM MC031 (CMD_READEEPROM). }
    function ReadEeprom(AAddr: LongWord; ASize: Word;
      out AData: array of Word; out AReadCount: Integer): Boolean;
    { Определение Fclk: CMD12 (PCI) → номинал 16 МГц (Ethernet). }
    function ResolveDeviceTiming(ATimerScaleMinus1, ATimerPeriodMinus1,
      AScanDivider: Word; out AResult: TMic140ClockMeasureResult): Boolean;
    property Host: string read fHost;
    property Port: Integer read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write fTimeoutMs;
  end;

  { TRecorderMic140Device — обёртка IRecorderDevice для MIC-140. }
  TRecorderMic140Device = class(TRecorderDevice)
  protected
    fScanProgram: TMic140_48;
    fClockMeasure: TMic140ClockMeasureResult;
    fConnection: TMic140MdpConnection;
  protected
    { Пересчёт count_aver по текущим параметрам скана. }
    procedure EvalAvrCount;
    { Копирует fPollFrequencyHz/fUpdateTimeMs/fChannelCount в fScanProgram. }
    procedure SyncScanProgramFromDeviceProperties;
    { CMD_TEST_LOAD + CMD_REPLY + MeasureModuleClockHz → заполняет Firmware + Mc114. }
    function ReadMIC140State: Boolean;
    { Вызывается из Connect: ReadMIC140State + SyncScan. }
    procedure ReadDeviceParameters; override;
    { Устанавливает Fs и пересчитывает count_aver. }
    procedure SetFs(fs: Double); override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    { Открывает TCP-соединение и читает параметры устройства. }
    procedure Connect; override;
    { Закрывает TCP-соединение. }
    procedure Disconnect; override;
    property ScanProgram: TMic140_48 read fScanProgram write fScanProgram;
    property ClockMeasure: TMic140ClockMeasureResult read fClockMeasure;
    property Connection: TMic140MdpConnection read fConnection;
  end;

{ Инициализация scan program значениями по умолчанию для 48-канальной конфигурации. }
procedure Mic140InitScanProgram48(var AProg: TMic140_48; fs: Double);
{ Гарантирует минимальную ёмкость массива AInChannels с заполнением по таблице ME048. }
procedure Mic140EnsureAInChannelCapacity(var AProg: TMic140_48; ACount: Integer);
{ Гарантирует минимальную ёмкость массива TInChannels. }
procedure Mic140EnsureTInChannelCapacity(var AProg: TMic140_48; AVisibleCount: Integer);
{ Пересчёт count_aver, Legacy*DelaySport по CalcCountAver/CheckPeriodDelay (AUTO_CALC). }
procedure Mic140EvalAverageSampleCount(var AProg: TMic140_48);

{ Fs = 2·Fclk / (scale·period·divider) — как ModuleMC114::IndexToFreq. }
function Mic140EvalFrequencyFromTimer(const AModuleClockHz: Double;
  ATimerScaleMinus1, ATimerPeriodMinus1, AScanDivider: Word): Double;
{ Обратная формула: Fclk = Fs·scale·period·divider / 2. }
function Mic140InferModuleClockFromScanFrequency(AMeasuredScanHz: Double;
  ATimerScaleMinus1, ATimerPeriodMinus1, AScanDivider: Word): Double;

{ Фабрика IRecorderDevice для менеджера устройств. }
function CreateMic140Device: IRecorderDevice;

implementation

const
  { Таблица коммутации ME048: UI-канал → физический вход. }
  CAInNum48: array[0..MIC140_48_AIN_COUNT - 1] of Word =
    (24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
     36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
     23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12,
     11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);

{ ---- MDP packet helpers ---- }

{ Записывает Word в little-endian по смещению AOfs. }
procedure PutWord(var ABuf: array of Byte; AOfs: Integer; AVal: Word);
begin
  ABuf[AOfs] := Byte(AVal);
  ABuf[AOfs + 1] := Byte(AVal shr 8);
end;

{ Читает Word из little-endian по смещению AOfs. }
function GetWord(const ABuf: array of Byte; AOfs: Integer): Word;
begin
  Result := Word(ABuf[AOfs]) or (Word(ABuf[AOfs + 1]) shl 8);
end;

{ Контрольная сумма: сумма N слов, обрезанная до Word. }
function WordSum(const W: array of Word; N: Integer): Word;
var
  I: Integer;
  S: LongWord;
begin
  S := 0;
  for I := 0 to N - 1 do Inc(S, W[I]);
  Result := Word(S);
end;

{ Формирует MDP-пакет: header(8) + payload + checksum(2). Возвращает размер. }
function BuildMdpPacket(ACmd: Word; const AArgs: array of Word;
  ARetWords: Integer; out APkt: array of Byte): Integer;
var
  I, ArgC, PayW, PayB: Integer;
  Pay: array[0..MIC140_MAX_TX_WORDS + 2] of Word;
begin
  ArgC := Length(AArgs);
  FillChar(Pay, SizeOf(Pay), 0);
  Pay[0] := ACmd;
  Pay[1] := ArgC;
  Pay[2] := ARetWords;
  for I := 0 to ArgC - 1 do
    Pay[I + 3] := AArgs[I];
  PayW := 3 + ArgC;
  PayB := PayW * 2;

  FillChar(APkt, Length(APkt), 0);
  PutWord(APkt, 0, MIC140_MDP_SYNC_WORD);
  PutWord(APkt, 2, MIC140_MDP_STREAM_CMD);
  PutWord(APkt, 4, PayW);
  PutWord(APkt, 6, Word(MIC140_MDP_SYNC_WORD + MIC140_MDP_STREAM_CMD + PayW));
  Move(Pay, APkt[8], PayB);
  PutWord(APkt, 8 + PayB, WordSum(Pay, PayW));
  Result := 8 + PayB + 2;
end;

{ Парсит один MDP-пакет из буфера. APktBytes — сколько байт пакета потреблено.
  Возвращает True при успешном разборе командного ответа. }
function ParseMdpReply(const ABuf: array of Byte; ALen: Integer;
  out APktBytes: Integer; out AData: array of Word;
  out ADataWords: Integer): Boolean;
var
  I, DataOfs, PktBytes: Integer;
  HdrSum, DSum, Size, Port: Word;
begin
  Result := False;
  APktBytes := 0;
  ADataWords := 0;
  if ALen < 8 then Exit;
  if GetWord(ABuf, 0) <> MIC140_MDP_SYNC_WORD then begin APktBytes := 1; Exit; end;

  Port := GetWord(ABuf, 2);
  Size := GetWord(ABuf, 4);
  HdrSum := Word(MIC140_MDP_SYNC_WORD + Port + Size);
  if HdrSum <> GetWord(ABuf, 6) then begin APktBytes := 1; Exit; end;

  PktBytes := 8 + (Integer(Size) + 1) * 2;
  if ALen < PktBytes then Exit;

  DataOfs := 8;
  DSum := 0;
  for I := 0 to Size - 1 do Inc(DSum, GetWord(ABuf, DataOfs + I * 2));
  APktBytes := PktBytes;
  if Word(DSum) <> GetWord(ABuf, DataOfs + Integer(Size) * 2) then Exit;
  if Port <> MIC140_MDP_STREAM_CMD then Exit(True);

  ADataWords := Size;
  if ADataWords > Length(AData) then ADataWords := Length(AData);
  for I := 0 to ADataWords - 1 do
    AData[I] := GetWord(ABuf, DataOfs + I * 2);
  Result := True;
end;

{ Читает из сокета один полный MDP-ответ, возвращает массив данных. }
function RecvMdpReply(ASock: {$IFDEF MSWINDOWS}TSocket{$ELSE}cint{$ENDIF};
  out AData: array of Word; out AWords: Integer): Boolean;
var
  Buf: array[0..4095] of Byte;
  Chunk: array[0..511] of Byte;
  Sz, Rd, Pk: Integer;
begin
  Result := False;
  AWords := 0;
  Sz := 0;
  while Sz < Length(Buf) do
  begin
    {$IFDEF MSWINDOWS}
    Rd := recv(ASock, Chunk, SizeOf(Chunk), 0);
    {$ELSE}
    Rd := fpRecv(ASock, @Chunk[0], SizeOf(Chunk), 0);
    {$ENDIF}
    if Rd <= 0 then Exit;
    if Sz + Rd > Length(Buf) then Exit;
    Move(Chunk, Buf[Sz], Rd);
    Inc(Sz, Rd);
    repeat
      Pk := 0;
      if ParseMdpReply(Buf, Sz, Pk, AData, AWords) then
      begin
        if AWords > 0 then Exit(True);
        if Pk > 0 then begin Move(Buf[Pk], Buf[0], Sz - Pk); Dec(Sz, Pk); end;
      end
      else if Pk > 0 then begin Move(Buf[Pk], Buf[0], Sz - Pk); Dec(Sz, Pk); end
      else Break;
    until Sz = 0;
  end;
end;

{ ---- TMic140MdpConnection ---- }

constructor TMic140MdpConnection.Create;
begin
  inherited;
  {$IFDEF MSWINDOWS}
  fSocket := INVALID_SOCKET;
  fWsaReady := False;
  {$ELSE}
  fSocket := -1;
  {$ENDIF}
  fTimeoutMs := MIC140_CMD_TIMEOUT_MS;
end;

destructor TMic140MdpConnection.Destroy;
begin
  Close;
  inherited;
end;

function TMic140MdpConnection.Open(const AHost: string; APort: Integer): Boolean;
{$IFDEF MSWINDOWS}
var
  Addr: TSockAddrIn;
  Ip: u_long;
  Tmo: LongInt;
  Wsa: TWSAData;
{$ELSE}
var
  Addr: TInetSockAddr;
  HA: in_addr;
  Tmo: TTimeVal;
{$ENDIF}
begin
  Result := False;
  Close;
  if (Trim(AHost) = '') or (APort <= 0) or (APort > High(Word)) then Exit;
  fHost := AHost;
  fPort := APort;

  {$IFDEF MSWINDOWS}
  if WSAStartup($0202, Wsa) <> 0 then Exit;
  fWsaReady := True;
  Ip := inet_addr(PChar(AnsiString(Trim(AHost))));
  if Ip = INADDR_NONE then begin Close; Exit; end;
  fSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if fSocket = INVALID_SOCKET then begin Close; Exit; end;
  Tmo := fTimeoutMs;
  setsockopt(fSocket, SOL_SOCKET, SO_RCVTIMEO, PAnsiChar(@Tmo), SizeOf(Tmo));
  setsockopt(fSocket, SOL_SOCKET, SO_SNDTIMEO, PAnsiChar(@Tmo), SizeOf(Tmo));
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(Word(APort));
  Addr.sin_addr.S_addr := Ip;
  if WinSock2.connect(fSocket, @Addr, SizeOf(Addr)) <> 0 then begin Close; Exit; end;
  {$ELSE}
  if not TryStrToHostAddr(AnsiString(Trim(AHost)), HA) then Exit;
  fSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if fSocket < 0 then Exit;
  Tmo.tv_sec := fTimeoutMs div 1000;
  Tmo.tv_usec := (fTimeoutMs mod 1000) * 1000;
  fpSetSockOpt(fSocket, SOL_SOCKET, SO_RCVTIMEO, @Tmo, SizeOf(Tmo));
  fpSetSockOpt(fSocket, SOL_SOCKET, SO_SNDTIMEO, @Tmo, SizeOf(Tmo));
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := ShortHostToNet(Word(APort));
  Addr.sin_addr.s_addr := HostToNet(HA.s_addr);
  if fpConnect(fSocket, @Addr, SizeOf(Addr)) <> 0 then begin Close; Exit; end;
  {$ENDIF}
  fConnected := True;
  Result := True;
end;

procedure TMic140MdpConnection.Close;
begin
  fConnected := False;
  {$IFDEF MSWINDOWS}
  if fSocket <> INVALID_SOCKET then begin closesocket(fSocket); fSocket := INVALID_SOCKET; end;
  if fWsaReady then begin WSACleanup; fWsaReady := False; end;
  {$ELSE}
  if fSocket >= 0 then begin fpClose(fSocket); fSocket := -1; end;
  {$ENDIF}
end;

function TMic140MdpConnection.IsConnected: Boolean;
begin
  Result := fConnected;
end;

function TMic140MdpConnection.SendPacket(const APacket: array of Byte;
  ASize: Integer; out ARet: array of Word; out ARetCount: Integer): Boolean;
var
  Sent, Ofs: Integer;
begin
  Result := False;
  ARetCount := 0;
  Ofs := 0;
  while Ofs < ASize do
  begin
    {$IFDEF MSWINDOWS}
    Sent := send(fSocket, APacket[Ofs], ASize - Ofs, 0);
    {$ELSE}
    Sent := fpSend(fSocket, @APacket[Ofs], ASize - Ofs, 0);
    {$ENDIF}
    if Sent <= 0 then begin fConnected := False; Exit; end;
    Inc(Ofs, Sent);
  end;
  Result := RecvMdpReply(fSocket, ARet, ARetCount);
  if not Result then fConnected := False;
end;

function TMic140MdpConnection.CallCommandArgs(ACommand: Word;
  const AArgs: array of Word; ARetWords: Integer;
  out ARet: array of Word; out ARetCount: Integer): Boolean;
var
  Pkt: array[0..127] of Byte;
  PktSz: Integer;
begin
  Result := False;
  ARetCount := 0;
  if (not fConnected) or (Length(AArgs) > MIC140_MAX_TX_WORDS) then Exit;
  PktSz := BuildMdpPacket(ACommand, AArgs, ARetWords, Pkt);
  Result := SendPacket(Pkt, PktSz, ARet, ARetCount);
end;

function TMic140MdpConnection.CallCommand(ACommand: Word; ARetWords: Integer;
  out ARet: array of Word; out ARetCount: Integer): Boolean;
begin
  Result := CallCommandArgs(ACommand, [], ARetWords, ARet, ARetCount);
end;

{ Двухфазное измерение частоты кварца модуля.
  Повторяет CCWDInterface::MeasureFreqCCFromFreqModule (CCIFC.CPP:1551).
  Исправлены три бага по сравнению с предыдущей версией:
  1) Period=65536 не помещается в Word → использован LongWord для вычислений
  2) Fallback-пересчёт period при measure_count=0 (как в C++ оригинале)
  3) Stop-команда посылала 5 аргументов вместо 1 }
function TMic140MdpConnection.MeasureModuleClockHz(AModuleSlot: Word;
  AReferenceClockHz, AMeasureTimeSec: Double;
  out AMeasuredClockHz: Double; out AError: string): Boolean;
var
  StartArgs: array[0..4] of Word;
  StopArgs: array[0..0] of Word;  // stop шлёт ровно 1 аргумент ($FFFF)
  StartR: array[0..1] of Word;
  StopR: array[0..2] of Word;
  SC, RC: Integer;
  lScale, lPeriod, lMeasureCount: LongWord; // LongWord — 65536 не помещается в Word
  C0, C1, Delta: QWord;
  WaitMs: Cardinal;
  FMod: Double;
begin
  Result := False;
  AMeasuredClockHz := 0;
  AError := '';
  if not fConnected then begin AError := 'Not connected'; Exit; end;

  if AReferenceClockHz <= 0 then FMod := MIC140_48_FREQ_CLK_HZ else FMod := AReferenceClockHz;
  if AMeasureTimeSec <= 0 then AMeasureTimeSec := MIC140_DEFAULT_MEASURE_TIME_SEC;

  { Расчёт параметров таймера — точная копия CCIFC.CPP:1565 }
  lScale := 256;
  lPeriod := 65536;
  lMeasureCount := Trunc(AMeasureTimeSec / ((lPeriod * lScale) / FMod) + 0.5);
  if lMeasureCount = 0 then
  begin
    // fallback: подбор period под заданное measure_time (CCIFC.CPP:1573)
    lMeasureCount := 1;
    lPeriod := Trunc(AMeasureTimeSec / lScale * FMod + 0.5);
    if lPeriod = 0 then
    begin
      lPeriod := 1;
      lScale := Trunc(AMeasureTimeSec / lPeriod * FMod + 0.5);
      if lScale = 0 then lScale := 1;
    end;
  end;

  WriteLn('[MeasureClk] scale=', lScale, ' period=', lPeriod,
    ' count=', lMeasureCount, ' FMod=', FMod:0:0);

  { Phase 1 — START: 5 аргументов, ожидаем 2 слова (C0 lo/hi) }
  StartArgs[0] := AModuleSlot;
  StartArgs[1] := MIC140_MODULE_CMD_MEASURE_FREQ;
  StartArgs[2] := Word(lScale - 1);
  StartArgs[3] := Word(lPeriod - 1);
  StartArgs[4] := Word(lMeasureCount);
  if not CallCommandArgs(MIC140_CMD_MEASURE_FREQ_MODULE, StartArgs, 2, StartR, SC) then
  begin AError := 'CMD12 start: CallCommand failed'; Exit; end;
  WriteLn('[MeasureClk] start reply: words=', SC,
    ' [0]=$', IntToHex(StartR[0], 4), ' [1]=$', IntToHex(StartR[1], 4));
  if SC < 2 then begin AError := Format('CMD12 start: got %d words, need 2', [SC]); Exit; end;

  { Sleep — ждём завершения таймера в DSP }
  WaitMs := Cardinal(Round((0.1 + lScale * lPeriod * lMeasureCount / FMod) * 1000.0));
  if WaitMs < 50 then WaitMs := 50;
  WriteLn('[MeasureClk] sleeping ', WaitMs, ' ms');
  Sleep(WaitMs);

  { Phase 2 — STOP/READ: 1 аргумент ($FFFF), ожидаем 3 слова (C1 lo/hi + flag) }
  StopArgs[0] := $FFFF;
  if not CallCommandArgs(MIC140_CMD_MEASURE_FREQ_MODULE, StopArgs, 3, StopR, RC) then
  begin AError := 'CMD12 stop: CallCommand failed'; Exit; end;
  WriteLn('[MeasureClk] stop reply: words=', RC,
    ' [0]=$', IntToHex(StopR[0], 4), ' [1]=$', IntToHex(StopR[1], 4),
    ' [2]=', StopR[2]);
  if RC < 3 then begin AError := Format('CMD12 stop: got %d words, need 3', [RC]); Exit; end;
  if StopR[2] = 0 then begin AError := 'CMD12: timer did not complete'; Exit; end;

  { Вычисление частоты }
  C0 := StartR[0] or (QWord(StartR[1]) shl 16);
  C1 := StopR[0] or (QWord(StopR[1]) shl 16);
  WriteLn('[MeasureClk] C0=', C0, ' C1=', C1, ' delta=', C1 - C0);
  if C1 <= C0 then begin AError := Format('CMD12 bad delta %d..%d', [C0, C1]); Exit; end;

  Delta := C1 - C0;
  AMeasuredClockHz := 2.0 * FMod * (Double(lMeasureCount) * lScale * lPeriod) / Delta;
  WriteLn('[MeasureClk] result=', AMeasuredClockHz:0:1, ' Hz (',
    AMeasuredClockHz / 1000000.0:0:6, ' MHz)');

  if (AMeasuredClockHz < 10000000) or (AMeasuredClockHz > 20000000) then
  begin
    AError := Format('Clock out of range: %.3f MHz', [AMeasuredClockHz / 1000000]);
    AMeasuredClockHz := 0;
    Exit;
  end;
  Result := True;
end;

{ Чтение DM-памяти MC031 контроллера через CMD_READMEMDM (114).
  AAddr — адрес с IS_DM-флагом ($4000) для DM-пространства.
  ACount — сколько слов прочитать (начиная с AAddr). }
function TMic140MdpConnection.ReadDM(AAddr: Word; ACount: Word;
  out AData: array of Word; out AReadCount: Integer): Boolean;
var
  Args: array[0..0] of Word;
begin
  Args[0] := AAddr;
  Result := CallCommandArgs(MIC140_CMD_READMEMDM, Args, ACount, AData, AReadCount);
end;

{ Чтение DM-памяти модуля через IDMA (CMD_IDMAGETARRAY = 77).
  ASlot — номер слота модуля.
  AAddr — адрес в адресном пространстве модуля (с IS_DM для DM).
  ACount — количество слов. }
function TMic140MdpConnection.ReadModuleDM(ASlot: Word; AAddr: Word; ACount: Word;
  out AData: array of Word; out AReadCount: Integer): Boolean;
var
  Args: array[0..4] of Word;
begin
  Args[0] := ASlot;
  Args[1] := (ASlot shl 3) or 0;  // MODULE_DATA_REG
  Args[2] := (ASlot shl 3) or 1;  // MODULE_IDMA_REG
  Args[3] := AAddr;
  Args[4] := ACount;
  Result := CallCommandArgs(MIC140_CMD_IDMAGETARRAY, Args, ACount, AData, AReadCount);
end;

{ Вызов команды модуля через IDMA (CMD_IDMACALLCOMMAND = 74).
  Аргументы: slot, command, argc, retc, [args...].
  Ответ: [result_code, ret0, ret1, ...]. }
function TMic140MdpConnection.CallCommandModule(ASlot: Word; AModuleCmd: Word;
  const AArgs: array of Word; ARetWords: Word;
  out ARet: array of Word; out ARetCount: Integer): Boolean;
var
  Args: array[0..35] of Word;
  Ret: array[0..35] of Word;
  ArgC, I, RC: Integer;
begin
  Result := False;
  ARetCount := 0;
  ArgC := Length(AArgs);
  Args[0] := ASlot;
  Args[1] := AModuleCmd;
  Args[2] := ArgC;
  Args[3] := ARetWords;
  for I := 0 to ArgC - 1 do
    Args[4 + I] := AArgs[I];
  FillChar(Ret, SizeOf(Ret), 0);
  if not CallCommandArgs(MIC140_CMD_IDMACALLCOMMAND, Slice(Args, 4 + ArgC),
    1 + ARetWords, Ret, RC) then Exit;
  ARetCount := RC;
  for I := 0 to Min(RC, Length(ARet)) - 1 do
    ARet[I] := Ret[I];
  Result := True;
end;

{ Чтение EEPROM MC031 (CMD_READEEPROM = 126).
  Аргументы: [addr_lo, addr_hi, length_bytes]. Ответ: ceil(length/2) слов. }
function TMic140MdpConnection.ReadEeprom(AAddr: LongWord; ASize: Word;
  out AData: array of Word; out AReadCount: Integer): Boolean;
var
  Args: array[0..2] of Word;
  RetW: Integer;
begin
  Args[0] := Word(AAddr);
  Args[1] := Word(AAddr shr 16);
  Args[2] := ASize;
  RetW := (ASize + 1) div 2;
  if RetW > Length(AData) then RetW := Length(AData);
  Result := CallCommandArgs(MIC140_CMD_READEEPROM, Args, RetW, AData, AReadCount);
end;

{ Полный цикл: определение Fclk → ActualFrequencyHz.
  Приоритет: 1) CMD_MEASURE_FREQ_MODULE (PCI)  2) номинал 16 МГц (Ethernet).
  В оригинальном Recorder Ethernet-интерфейс CCMC031 возвращает ERROR_NOERROR
  из MeasureFreqCCFromFreqModule без измерения — всегда используется номинал. }
function TMic140MdpConnection.ResolveDeviceTiming(
  ATimerScaleMinus1, ATimerPeriodMinus1, AScanDivider: Word;
  out AResult: TMic140ClockMeasureResult): Boolean;
var
  Clk: Double;
  Err: string;
begin
  FillChar(AResult, SizeOf(AResult), 0);

  { 1) Попытка CMD_MEASURE_FREQ_MODULE (работает только по PCI) }
  if MeasureModuleClockHz(MIC140_DEFAULT_MODULE_SLOT,
    MIC140_48_FREQ_CLK_HZ, MIC140_DEFAULT_MEASURE_TIME_SEC, Clk, Err) then
  begin
    AResult.Method := mcmMeasureFreqModule;
    AResult.ModuleClockHz := Clk;
    WriteLn('[ResolveClk] measured via CMD12: ', Clk:0:1, ' Hz');
  end
  else
  begin
    { 2) Номинал кварца ADSP-218x = 16 МГц (как в оригинальном Recorder) }
    AResult.Method := mcmNominal;
    AResult.ModuleClockHz := MIC140_48_FREQ_CLK_HZ;
    WriteLn('[ResolveClk] using nominal ', MIC140_48_FREQ_CLK_HZ/1e6:0:1,
      ' MHz (Ethernet stub: ', Err, ')');
  end;
  AResult.ActualFrequencyHz := Mic140EvalFrequencyFromTimer(
    AResult.ModuleClockHz, ATimerScaleMinus1, ATimerPeriodMinus1, AScanDivider);
  AResult.Ok := AResult.ActualFrequencyHz > 0;
  Result := AResult.Ok;
end;

{ ---- Pure math ---- }

{ Fs = 2·Fclk / (scale · period · divider). }
function Mic140EvalFrequencyFromTimer(const AModuleClockHz: Double;
  ATimerScaleMinus1, ATimerPeriodMinus1, AScanDivider: Word): Double;
var
  S, P, D: Double;
begin
  Result := 0;
  if (AModuleClockHz <= 0) or (AScanDivider = 0) then Exit;
  S := ATimerScaleMinus1 + 1;
  P := ATimerPeriodMinus1 + 1;
  D := AScanDivider;
  Result := 2.0 * AModuleClockHz / (S * P * D);
end;

{ Обратная формула: Fclk = Fs · scale · period · divider / 2. }
function Mic140InferModuleClockFromScanFrequency(AMeasuredScanHz: Double;
  ATimerScaleMinus1, ATimerPeriodMinus1, AScanDivider: Word): Double;
var
  S, P, D: Double;
begin
  Result := 0;
  if AMeasuredScanHz <= 0 then Exit;
  S := ATimerScaleMinus1 + 1;
  P := ATimerPeriodMinus1 + 1;
  D := AScanDivider;
  if (S <= 0) or (P <= 0) or (D <= 0) then Exit;
  Result := AMeasuredScanHz * S * P * D / 2.0;
end;

{ ---- Timing internals (parametrized by ModuleClockHz) ---- }

{ Fclk или номинал 16 МГц. }
function ClkOrDefault(V: Double): Double; inline;
begin
  if V > 0 then Result := V else Result := MIC140_48_FREQ_CLK_HZ;
end;

{ Тики кода → секунды: N / (2·Fclk). }
function CodeToPeriod(Ticks, Clk: Double): Double; inline;
begin
  Result := Ticks / (2.0 * ClkOrDefault(Clk));
end;

{ Секунды → тики SPORT: Trunc(sec · Fclk), маска 24 бита. }
function PeriodToSport(Sec, Clk: Double): LongWord; inline;
begin
  Result := LongWord(Trunc(Sec * ClkOrDefault(Clk) + 1e-9)) and $FFFFFF;
end;

{ Тики SPORT → секунды. }
function SportToPeriod(Cnt: LongWord; Clk: Double): Double; inline;
begin
  Result := (Cnt and $FFFFFF) / ClkOrDefault(Clk);
end;

{ Минимальный период программирования ME048 (SPORT_SCLK_DIV_PROGR). }
function MinProgPeriod(Clk: Double): Double; inline;
begin
  Result := CodeToPeriod(MIC140_48_PERIOD_PROG_CHAN_CODE, Clk);
end;

{ Минимальный период GND-слота (PERIOD_4 + programming + квант). }
function MinGndPeriod(Clk: Double): Double;
var
  P: Double;
begin
  P := CodeToPeriod(MIC140_48_PERIOD_4_CHAN_CODE, Clk) + MinProgPeriod(Clk);
  if P < MIC140_48_PERIOD_AVER_US * 1e-6 then P := MIC140_48_PERIOD_AVER_US * 1e-6;
  Result := SportToPeriod(PeriodToSport(P, Clk), Clk);
end;

{ PeriodDecay (сек) → SPORT-тики для дескриптора word3 (вычитает PERIOD_3/1/DELTA/PROG). }
function DecayToSport(Sec, Clk: Double): Word;
var
  P: Double;
begin
  P := Sec
    - CodeToPeriod(MIC140_48_PERIOD_3_CHAN_CODE, Clk)
    - CodeToPeriod(MIC140_48_PERIOD_1_CHAN_CODE, Clk)
    - CodeToPeriod(MIC140_48_DELTA_SPORT, Clk)
    - MinProgPeriod(Clk);
  if P < 0 then P := 0;
  Result := Word(PeriodToSport(P, Clk));
end;

{ Обратное к DecayToSport: SPORT-тики → полный PeriodDecay (сек). }
function SportToDecay(Cnt: Word; Clk: Double): Double;
begin
  Result := SportToPeriod(Cnt, Clk)
    + CodeToPeriod(MIC140_48_PERIOD_3_CHAN_CODE, Clk)
    + CodeToPeriod(MIC140_48_PERIOD_1_CHAN_CODE, Clk)
    + CodeToPeriod(MIC140_48_DELTA_SPORT, Clk)
    + MinProgPeriod(Clk);
end;

{ PeriodAverage (сек) → SPORT-тики для chanDump[0] (вычитает PERIOD_21/1/DELTA). }
function AverToSport(Sec, Clk: Double): Word;
var
  P: Double;
begin
  P := Sec
    - CodeToPeriod(MIC140_48_PERIOD_21_CHAN_CODE, Clk)
    - CodeToPeriod(MIC140_48_PERIOD_1_CHAN_CODE, Clk)
    - CodeToPeriod(MIC140_48_DELTA_SPORT, Clk);
  if P < 0 then P := 0;
  Result := Word(PeriodToSport(P, Clk));
end;

{ Обратное к AverToSport: SPORT-тики → полный PeriodAverage (сек). }
function SportToAver(Cnt: Word; Clk: Double): Double;
begin
  Result := SportToPeriod(Cnt, Clk)
    + CodeToPeriod(MIC140_48_PERIOD_21_CHAN_CODE, Clk)
    + CodeToPeriod(MIC140_48_PERIOD_1_CHAN_CODE, Clk)
    + CodeToPeriod(MIC140_48_DELTA_SPORT, Clk);
end;

{ Поправочный коэффициент ISR: учитывает «налог» кадрового таймера на T_eff. }
function IsrFactor(Clk: Double): Double;
begin
  Result := 1.0 + (2.0 * ClkOrDefault(Clk) / MIC140_48_TIMER_PERIOD) *
    CodeToPeriod(103, Clk);
end;

{ Число BIOS-слотов для расчёта count_aver (AIn+TIn, ×2 если ground). }
function CountChans(const P: TMic140_48): Word;
var
  I, N: Integer;
begin
  if P.Flags.AllChannelsSample then
    N := P.ChanDump.VisibleAInCount + Length(P.TInChannels)
  else
  begin
    N := 0;
    for I := 0 to High(P.AInChannels) do if P.AInChannels[I].Enabled then Inc(N);
    for I := 0 to High(P.TInChannels) do if P.TInChannels[I].Enabled then Inc(N);
    if N = 0 then N := P.ChanDump.VisibleAInCount + Length(P.TInChannels);
  end;
  Result := Word(N);
  if P.Flags.ChannelGround then Result := Result * 2;
end;

{ AUTO_CALC_COUNT_AVER: максимальный count_aver при заданных таймингах. }
function CalcCountAver(NCh: Word; TPer, TDec, TDec2, TAv: Double;
  Gnd: Boolean; Clk: Double): LongInt;
var
  Eff, Proc, Dec, Dec2, Av: Double;
begin
  Eff := TPer / IsrFactor(Clk);
  Dec := SportToDecay(DecayToSport(TDec, Clk), Clk);
  Dec2 := SportToDecay(DecayToSport(TDec2, Clk), Clk);
  Av := SportToAver(AverToSport(TAv, Clk), Clk);
  Proc := CodeToPeriod(MIC140_48_PERIOD_2_CHAN_CODE, Clk);
  if Gnd then
    Result := Trunc(((Eff - (NCh div 2) * Dec2) / (NCh div 2) - (Proc + Dec)) / Av + 1)
  else
    Result := Trunc((Eff / NCh - (Proc + Dec)) / Av + 1);
  if Result < MIC140_48_MIN_COUNT_AVER then Result := MIC140_48_MIN_COUNT_AVER;
  if Result > MIC140_48_MAX_COUNT_AVER then Result := MIC140_48_MAX_COUNT_AVER;
end;

{ Максимальный PeriodDecay при заданном count_aver (обратный CalcCountAver). }
function MaxDecay(NCh: Word; TPer, TAv: Double; CA: Word; Gnd: Boolean;
  TDec2, Clk: Double): Double;
var
  Eff, Proc, Av, D2: Double;
begin
  Eff := TPer / IsrFactor(Clk);
  Av := SportToAver(AverToSport(TAv, Clk), Clk);
  Proc := CodeToPeriod(MIC140_48_PERIOD_2_CHAN_CODE, Clk);
  D2 := SportToDecay(DecayToSport(TDec2, Clk), Clk);
  if Gnd then
    Result := (Eff - (NCh div 2) * D2) / (NCh div 2) - (Proc + (CA - 1) * Av)
  else
    Result := Eff / NCh - (Proc + (CA - 1) * Av);
end;

{ Проверка и ограничение PeriodDecay: max по бюджету, min по PERIOD_4. }
function CheckDecay(NCh: Word; TPer, TDec, TDec2, TAv: Double;
  CA: Word; Gnd: Boolean; Clk: Double): Double;
var
  MxD, MnD: Double;
begin
  Result := TDec;
  MxD := MaxDecay(NCh, TPer, TAv, CA, Gnd, TDec2, Clk);
  MnD := MinGndPeriod(Clk);
  if MxD < Result then Result := MxD;
  if Result < MnD then Result := MnD;
  Result := SportToPeriod(PeriodToSport(Result, Clk), Clk);
end;

{ Проверка и ограничение count_aver: не больше CalcCountAver, не меньше MIN. }
function CheckCountAver(NCh: Word; TPer, TDec, TDec2, TAv: Double;
  CA: Word; Gnd: Boolean; Clk: Double): Word;
var
  Mx: LongInt;
begin
  Result := CA;
  //TDec:=0.000200; // 200 мкс
  Mx := CalcCountAver(NCh, TPer, TDec, TDec2, TAv, Gnd, Clk);
  if Mx < Result then Result := Word(Mx);
  if Result < MIC140_48_MIN_COUNT_AVER then Result := MIC140_48_MIN_COUNT_AVER;
end;

{ Выбирает TimerScale/ScanDivider/TimerPeriod для заданной Fs
  по таблице scale_period_16000 (ModuleMC114). }
procedure ApplyTimerForFreq(var P: TMic140_48);
var
  F: Double;
begin
  F := P.Timing.FrequencyHz;
  if SameValue(F, 1.0, 0.001) then
    begin P.Mc114.TimerScaleMinus1 := 1; P.Mc114.ScanDivider := 25000; end
  else begin
    P.Mc114.TimerScaleMinus1 := 0;
    if      SameValue(F,  2.0, 0.001) then P.Mc114.ScanDivider := 25000
    else if SameValue(F,  5.0, 0.001) then P.Mc114.ScanDivider := 10000
    else if SameValue(F, 10.0, 0.001) or SameValue(F,  9.875,  0.001) then P.Mc114.ScanDivider := 5000
    else if SameValue(F, 20.0, 0.001) or SameValue(F, 19.75,   0.001) then P.Mc114.ScanDivider := 2500
    else if SameValue(F, 25.0, 0.001) or SameValue(F, 24.6875, 0.001) then P.Mc114.ScanDivider := 2000
    else if SameValue(F, 50.0, 0.001) or SameValue(F, 49.375,  0.001) then P.Mc114.ScanDivider := 1000
    else if SameValue(F,100.0, 0.001) or SameValue(F, 98.75,   0.001) then P.Mc114.ScanDivider :=  500
    else P.Mc114.ScanDivider := 500;
  end;
  P.Mc114.TimerPeriodMinus1 := MIC140_48_TIMER_PERIOD - 1;
  if P.Mc114.ModuleClockHz <= 0 then P.Mc114.ModuleClockHz := MIC140_48_FREQ_CLK_HZ;
  P.Mc114.ActualFrequencyHz := Mic140EvalFrequencyFromTimer(
    P.Mc114.ModuleClockHz, P.Mc114.TimerScaleMinus1,
    P.Mc114.TimerPeriodMinus1, P.Mc114.ScanDivider);
end;

{ ---- Public scan-program helpers ---- }

procedure Mic140EvalAverageSampleCount(var AProg: TMic140_48);
var
  NCh: Word;
  TPer, TDec, TDec2, TAv, Clk: Double;
  Slots, I: Integer;
begin
  if AProg.Timing.FrequencyHz <= 0 then Exit;
  ApplyTimerForFreq(AProg);
  Clk := ClkOrDefault(AProg.Mc114.ModuleClockHz);
  { Recorder's MIC140pp dialog calls GetFreqSFor() and passes that channel
    frequency into CheckPeriodDelay. It does not recalculate this dialog math
    from the programmed scan timer frequency. }
  TPer := 1.0 / AProg.Timing.FrequencyHz;
  TDec := AProg.Timing.PeriodDecayUs * 1e-6;
  TDec2 := AProg.Timing.PeriodDecay2Us * 1e-6;
  TAv := AProg.Timing.PeriodAverageUs * 1e-6;
  if TAv <= 0 then TAv := MIC140_48_PERIOD_AVER_US * 1e-6;
  NCh := CountChans(AProg);

  if AProg.Timing.AutoCalcPeriodDelay then
  begin
    TDec := CheckDecay(NCh, TPer, TDec, TDec2, TAv, 1, AProg.Flags.ChannelGround, Clk);
    AProg.Timing.AverageSampleCount := CheckCountAver(NCh, TPer, TDec, TDec2, TAv,
      MIC140_48_MAX_COUNT_AVER, AProg.Flags.ChannelGround, Clk);
    AProg.Timing.PeriodDecayUs := TDec * 1e6;
  end;

  AProg.Timing.LegacyChannelDelaySport := DecayToSport(AProg.Timing.PeriodDecayUs * 1e-6, Clk);
  AProg.Timing.LegacyGroundDelaySport := DecayToSport(TDec2, Clk);
  AProg.Timing.LegacyAverageDelaySport := AverToSport(TAv, Clk);

  AProg.ChanDump.UseGroundPointers := AProg.Flags.ChannelGround;
  if AProg.Flags.AllChannelsSample then
    Slots := AProg.ChanDump.VisibleAInCount + Length(AProg.TInChannels)
  else begin
    Slots := 0;
    for I := 0 to High(AProg.AInChannels) do if AProg.AInChannels[I].Enabled then Inc(Slots);
    for I := 0 to High(AProg.TInChannels) do if AProg.TInChannels[I].Enabled then Inc(Slots);
    if Slots = 0 then Slots := AProg.ChanDump.VisibleAInCount + Length(AProg.TInChannels);
  end;
  if AProg.Flags.ChannelGround then
    AProg.ChanDump.BiosSlotCount := Slots * 2
  else
    AProg.ChanDump.BiosSlotCount := Slots;
end;

procedure Mic140EnsureAInChannelCapacity(var AProg: TMic140_48; ACount: Integer);
var
  I: Integer;
begin
  if ACount > MIC140_48_AIN_COUNT then ACount := MIC140_48_AIN_COUNT;
  if Length(AProg.AInChannels) >= ACount then Exit;
  SetLength(AProg.AInChannels, ACount);
  for I := 0 to ACount - 1 do
  begin
    AProg.AInChannels[I].UiChannelIndex := I + 1;
    if I <= High(CAInNum48) then
      AProg.AInChannels[I].PhysicalMe048Input := CAInNum48[I]
    else
      AProg.AInChannels[I].PhysicalMe048Input := I;
    AProg.AInChannels[I].Enabled := True;
    AProg.AInChannels[I].RangeIndex := AProg.DefaultRangeIndex;
    AProg.AInChannels[I].BoardCommutIndex := AProg.DefaultBoardCommutIndex;
    AProg.AInChannels[I].RegDesc := $0100;
    AProg.AInChannels[I].ValueDmOffset := Word(I);
  end;
end;

procedure Mic140EnsureTInChannelCapacity(var AProg: TMic140_48; AVisibleCount: Integer);
var
  I: Integer;
begin
  if AVisibleCount > MIC140_48_TIN_VISIBLE_COUNT then AVisibleCount := MIC140_48_TIN_VISIBLE_COUNT;
  if Length(AProg.TInChannels) >= AVisibleCount then Exit;
  SetLength(AProg.TInChannels, AVisibleCount);
  for I := 0 to AVisibleCount - 1 do
  begin
    AProg.TInChannels[I].VisibleIndex := I;
    AProg.TInChannels[I].InternalIndex := I;
    AProg.TInChannels[I].Enabled := True;
    AProg.TInChannels[I].RegDesc := $0100;
    AProg.TInChannels[I].ValueDmOffset := Word(MIC140_48_AIN_COUNT + I);
  end;
end;

procedure Mic140InitScanProgram48(var AProg: TMic140_48; fs: Double);
begin
  FillChar(AProg, SizeOf(AProg), 0);
  AProg.Timing.FrequencyHz := fs;
  AProg.Timing.PeriodDecayUs := 57.0;
  AProg.Timing.PeriodDecay2Us := 19.688;
  AProg.Timing.PeriodAverageUs := MIC140_48_PERIOD_AVER_US;
  AProg.Timing.AverageSampleCount := 1;
  AProg.Timing.AutoCalcPeriodDelay := True;
  AProg.Mc114.TimerScaleMinus1 := 0;
  AProg.Mc114.TimerPeriodMinus1 := MIC140_48_TIMER_PERIOD - 1;
  AProg.Mc114.ScanDivider := 5000;
  AProg.Mc114.ModuleClockHz := MIC140_48_FREQ_CLK_HZ;
  AProg.Mc114.ActualFrequencyHz := Mic140EvalFrequencyFromTimer(
    AProg.Mc114.ModuleClockHz, AProg.Mc114.TimerScaleMinus1,
    AProg.Mc114.TimerPeriodMinus1, AProg.Mc114.ScanDivider);
  AProg.Fifo.DataUpdateMs := 200;
  AProg.Fifo.PayloadStride := MIC140_48_AIN_COUNT;
  AProg.Fifo.TinVisibleSlots := MIC140_48_TIN_VISIBLE_COUNT;
  AProg.Flags.AllChannelsSample := True;
  AProg.Flags.ThermoCompensation := True;
  AProg.ChanDump.VisibleAInCount := MIC140_48_AIN_COUNT;
  AProg.ChanDump.BiosSlotCount := MIC140_48_AIN_COUNT + MIC140_48_TIN_VISIBLE_COUNT;
  Mic140EnsureAInChannelCapacity(AProg, MIC140_48_AIN_COUNT);
  Mic140EnsureTInChannelCapacity(AProg, MIC140_48_TIN_VISIBLE_COUNT);
  Mic140EvalAverageSampleCount(AProg);
end;

{ ---- TRecorderMic140Device ---- }

function CreateMic140Device: IRecorderDevice;
begin
  Result := TRecorderMic140Device.Create;
end;

constructor TRecorderMic140Device.Create;
begin
  inherited Create('MIC140', 'MIC-140');
  fConnection := TMic140MdpConnection.Create;
  inherited SetFs(MIC140_48_RECORDER_DEFAULT_FREQ_HZ);
  Mic140InitScanProgram48(fScanProgram, MIC140_48_RECORDER_DEFAULT_FREQ_HZ);
end;

destructor TRecorderMic140Device.Destroy;
begin
  fConnection.Free;
  inherited;
end;

procedure TRecorderMic140Device.Connect;
begin
  if not fConnection.IsConnected then
    if not fConnection.Open(fHost, fPort) then
      raise ERecorderDeviceError.CreateFmt('MIC140 TCP connect failed %s:%d', [fHost, fPort]);
  inherited;
end;

procedure TRecorderMic140Device.Disconnect;
begin
  fConnection.Close;
  inherited;
end;

procedure TRecorderMic140Device.EvalAvrCount;
begin
  Mic140EvalAverageSampleCount(fScanProgram);
end;

procedure TRecorderMic140Device.SyncScanProgramFromDeviceProperties;
begin
  fScanProgram.Timing.FrequencyHz := fPollFrequencyHz;
  fScanProgram.Fifo.DataUpdateMs := fUpdateTimeMs;
  Mic140EnsureAInChannelCapacity(fScanProgram, fChannelCount);
  Mic140EnsureTInChannelCapacity(fScanProgram, MIC140_48_TIN_VISIBLE_COUNT);
  EvalAvrCount;
end;

function TRecorderMic140Device.ReadMIC140State: Boolean;
var
  TestArgs: array[0..1] of Word;
  TestR: array[0..1] of Word;
  Reply: array[0..MIC140_BIOS_INFO_WORDS - 1] of Word;
  TC, RC: Integer;
begin
  Result := False;
  if not fConnection.IsConnected then begin WriteLn('[ReadState] not connected'); Exit; end;

  if fChannelCount <= 0 then fChannelCount := MIC140_48_AIN_COUNT;
  if fUpdateTimeMs <= 0 then fUpdateTimeMs := 200;
  if fScanProgram.Mc114.TimerPeriodMinus1 = 0 then
    fScanProgram.Mc114.TimerPeriodMinus1 := MIC140_48_TIMER_PERIOD - 1;
  if fScanProgram.Mc114.ScanDivider = 0 then
    fScanProgram.Mc114.ScanDivider := 5000;

  TestArgs[0] := 0; TestArgs[1] := 0;
  if not fConnection.CallCommandArgs(MIC140_CMD_TEST_LOAD, TestArgs, 2, TestR, TC) then
  begin WriteLn('[ReadState] CMD_TEST_LOAD failed'); Exit; end;
  WriteLn('[ReadState] CMD_TEST_LOAD: words=', TC, ' [0]=', TestR[0]);
  if (TC < 1) or (TestR[0] <> 1) then
  begin WriteLn('[ReadState] CMD_TEST_LOAD bad reply'); Exit; end;

  FillChar(Reply, SizeOf(Reply), 0);
  if not fConnection.CallCommand(MIC140_CMD_REPLY, MIC140_BIOS_INFO_WORDS, Reply, RC) then
  begin WriteLn('[ReadState] CMD_REPLY failed'); Exit; end;
  WriteLn('[ReadState] CMD_REPLY: words=', RC);
  if RC < MIC140_BIOS_INFO_WORDS then
  begin WriteLn('[ReadState] CMD_REPLY too short: ', RC); Exit; end;

  fScanProgram.Firmware.Signature        := Reply[0];
  fScanProgram.Firmware.MdpType          := Reply[1];
  fScanProgram.Firmware.DevType          := Reply[2];
  fScanProgram.Firmware.DevRev           := Reply[3];
  fScanProgram.Firmware.DevSerial        := Reply[4];
  fScanProgram.Firmware.ControllerType   := Reply[5];
  fScanProgram.Firmware.ControllerSerial := Reply[6];
  fScanProgram.Firmware.EepromManufactId := Reply[7];
  fScanProgram.Firmware.EepromDeviceId   := Reply[8];
  fScanProgram.Firmware.BiosFunction     := Reply[9];
  fScanProgram.Firmware.BiosVersion      := Reply[10];
  WriteLn('[ReadState] FW sig=$', IntToHex(Reply[0], 4),
    ' dev=', Reply[2], ' rev=', Reply[3], ' serial=', Reply[4]);

  if fPollFrequencyHz <= 0 then fPollFrequencyHz := MIC140_48_RECORDER_DEFAULT_FREQ_HZ;
  fScanProgram.Timing.FrequencyHz := fPollFrequencyHz;
  ApplyTimerForFreq(fScanProgram);

  if not fConnection.ResolveDeviceTiming(
    fScanProgram.Mc114.TimerScaleMinus1, fScanProgram.Mc114.TimerPeriodMinus1,
    fScanProgram.Mc114.ScanDivider, fClockMeasure) then
  begin WriteLn('[ReadState] ResolveDeviceTiming failed'); Exit; end;

  fScanProgram.Mc114.ModuleClockHz := fClockMeasure.ModuleClockHz;
  fScanProgram.Mc114.ActualFrequencyHz := fClockMeasure.ActualFrequencyHz;
  ApplyTimerForFreq(fScanProgram);
  Result := True;
end;

procedure TRecorderMic140Device.ReadDeviceParameters;
begin
  inherited;
  if not ReadMIC140State then
    raise ERecorderDeviceError.CreateFmt('MIC140 CMD_REPLY failed %s:%d', [fHost, fPort]);
  SyncScanProgramFromDeviceProperties;
end;

procedure TRecorderMic140Device.SetFs(fs: Double);
begin
  inherited;
  fScanProgram.Timing.FrequencyHz := fs;
  EvalAvrCount;
end;

end.
