unit uMic140Device;

{
  Объектная обёртка MIC-140 (Codex).

  TMic140_48 — сводная структура параметров BIOS-программирования (scan program).
  Поля и вложенные record сопоставлены с оригинальным Recorder:
    mic140ppext.cpp (count_aver, period_decay, period_decay2, flags),
    MIC140_48mod.cpp / TDescChanBios_MIC140_96 (5 слов дескриптора),
    m_ChanDump, Modscn CONFIG/APPEND, Mc114mod timer.

  См. Docs/devices/mic140/protocol/*.md
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uRecorderDeviceInterfaces;

const
  { [ORIG] MIC140_48mod }
  MIC140_48_AIN_COUNT = 48;
  MIC140_48_TIN_VISIBLE_COUNT = 3;
  MIC140_48_TIN_INTERNAL_COUNT = 12;
  MIC140_48_RANGE_COUNT = 3;
  MIC140_48_MODULE_TYPE = 12;
  MIC140_48_SCAN_ID = 0;
  // делитель системного таймера (20 мкс - 50кГц)
  MIC140_48_TIMER_PERIOD = 640;
  // накладные расходы супервизора 112 тиков в часах 50кГц
  PERIOD_TIMER_WORK  = 112;
  // Fs ADC=200kHz
  MIC140_48_PERIOD_AVER_US = 5.0;

type
  //  Тайминги скана — UI mic140ppext + расчёт ModuleMIC140_96::CheckPeriodDelay.
  //  PeriodDecay* — мкс (как в диалоге); Legacy*DelaySport — тики SPORT для BIOS (Word3/chanDump[0]).
  TMic140ScanTiming = record
    // Частота кадра скана, Гц (Fs).
    FrequencyHz: Double;
    // «Время переходного процесса» — успокоение MUX после переключения (T0), мкс.
    PeriodDecayUs: Double;
    // «Время заземления 2» — фаза GND перед/между каналами (Tgnd), мкс.
    PeriodDecay2Us: Double;
    // Период одного отсчёта ΣΔ при усреднении, мкс (обычно 5).
    PeriodAverageUs: Double;
    // «Число усреднений» count_aver — сколько отсчётов АЦП в фазе измерения (Tavr).
    AverageSampleCount: Word;
    // mode_auto_calc_period_delay — пересчитывать decay/aver при смене Fs
    AutoCalcPeriodDelay: Boolean;
    // Производные для BIOS: Legacy*DelaySport − 1 пишется в дескрипторы / chanDump[0].
    LegacyChannelDelaySport: Word;
    LegacyGroundDelaySport: Word;
    LegacyAverageDelaySport: Word;
  end;


  //  Таймер MC114 / CONFIGSCANMAIN + APPENDSCANMAIN (16 МГц).
  TMic140Mc114Timer = record
    // модификатор времени расчета времени прерывания. На всех частотах 2 кроме частоты 1Гц, тогда 1 (или наоборот????)
    TimerScaleMinus1: Word;
    // делитель системного таймера (20 мкс = 640/(16Mhz*scale))
    // Она же уходит в BIOS командой CONFIGSCANMAIN (84):
    TimerPeriodMinus1: Word;
    // APPEND word2: ScanDivider для выбранной FrequencyHz
    ScanDivider: Word;
  end;


  //  Параметры FIFO и сетевого payload (Modscn::CreateBiosCCScanBuf, SCAN_SET_BUFF).
  TMic140FifoProgram = record
    // Период опроса на стороне PC, мс (DataUpdateMs / update time). }
    DataUpdateMs: Cardinal;
    // Слов в одной строке payload: 48 (AIn) или 51 (AIn+TIn в wire-профиле). }
    PayloadStride: Integer;
    // Порог готовности FIFO в словах (sizeready). }
    FifoReadyWords: Word;
    // Ёмкость кольца FIFO в словах (обычно 2 × FifoReadyWords). }
    FifoCapacityWords: Word;
    // Число видимых TIn в BIOS (0..3). }
    TinVisibleSlots: Integer;
  end;


  //  Флаги модуля mic140ppext / PrepareModuleDescForScan.
  TMic140ScanFlags = record
    // flag_allch_sampl — опрашивать все AIn+TIn в BIOS.
    AllChannelsSample: Boolean;
    // flag_chan_ground — чередование GND↔канал в chanDump.
    ChannelGround: Boolean;
    // Компенсация холодного спая (CJC) на уровне источника.
    ThermoCompensation: Boolean;
  end;

  //  Заголовок m_ChanDump и число BIOS-слотов (не путать с PayloadStride).
  TMic140ChanDumpProgram = record
    // m_ChanDump[2] — видимое число пользовательских AIn (часто 48).
    VisibleAInCount: Word;
    // Число указателей/слотов в BIOS-списке (48+TIn или 2× при ground).
    BiosSlotCount: Integer;
    // Чередующиеся указатели ground+channel (flag_chan_ground).
    UseGroundPointers: Boolean;
  end;

  //  Программирование одного AIn — TDescChanBios_MIC140_96 + chanmic140pp.
  //  UiChannelIndex: 1..48; PhysicalMe048Input: CAInNum48[i].
  TMic140AInChannelProgram = record
    // Номер канала в UI (1..48).
    UiChannelIndex: Integer;
    // Физический вход ME048 (0..47), таблица CAInNum48.
    PhysicalMe048Input: Integer;
    // Участвует в циклограмме (SelectedChannels / flag не allch).
    Enabled: Boolean;
    // Диапазон АЦП amplif[]: 0=80 mV, 1=800 mV, 2=8 V (HARD_AMPLIF).
    RangeIndex: Integer;
    //Коммутатор «Вход» calibr → code_ME048 (ME048).
    CommutIndex: Integer;
    // Коммутатор платы calibr2 → reg MC114 (MUX_IN1/MUX_IN2).
    BoardCommutIndex: Integer;
    // Дескриптор word2: усиление/ключи MC114 ($0100 / $0110).
    RegDesc: Word;
    // Дескриптор words 0..1: упакованный code_ME048[0..1].
    Me048Word0: Word;
    Me048Word1: Word;
    // Дескриптор word3: LegacyChannelDelaySport−1; 0 = общий Timing.PeriodDecayUs.
    ChannelDelaySport: Word;
    // Смещение в области мгновенных значений DM (var_addr + n).
    ValueDmOffset: Word;
  end;

  //  Внутренний/видимый TIn — дескриптор + ME048 + DM (MASK_CHAN_LEFT на ptr в BIOS).
  TMic140TInChannelProgram = record
    // Видимый T1..T3 (0..2).
    VisibleIndex: Integer;
    // Физический индекс TIn на плате (TInNum / TInNum_SUBREV1).
    InternalIndex: Integer;
    // Участвует в BIOS-скане.
    Enabled: Boolean;
    // Дескриптор word2 ($0100 / $0120 для последнего).
    RegDesc: Word;
    Me048Word0: Word;
    Me048Word1: Word;
    ValueDmOffset: Word;
  end;

  //  Идентификация прошивки CC (TBiosInfoMC031) — влияет на TIn ME048/ptr.
  TMic140FirmwareInfo = record
    DevType: Word;
    DevRev: Word;
    DevSubRev: Word;
    DevSerial: Integer;
    BiosVersion: Word;
  end;

  // Полная программа скана MIC-140 48 каналов для ProgramScan / WRITE_DM / ADDCHANNELMODULE.
  // Соответствует совокупности настроек ModuleMIC140_48 + ScanMIC140.
  TMic140_48 = record
    // настройка скана MIC140
    Timing: TMic140ScanTiming;
    Mc114: TMic140Mc114Timer;
    Fifo: TMic140FifoProgram;
    Flags: TMic140ScanFlags;
    ChanDump: TMic140ChanDumpProgram;
    Firmware: TMic140FirmwareInfo;
    // Глобальный calibr2 для всех AIn, если BoardCommutIndex в канале не переопределён.
    DefaultBoardCommutIndex: Integer;
    // Глобальный диапазон, если RangeIndex в канале не задан.
    DefaultRangeIndex: Integer;
    // Список активных AIn (длина ≤ 48).
    AInChannels: array of TMic140AInChannelProgram;
    // TIn 1..3 + резерв внутренних (до 12 в value area).
    TInChannels: array of TMic140TInChannelProgram;
  end;

  { TRecorderMic140Device }
  TRecorderMic140Device = class(TRecorderDevice)
  protected
    fScanProgram: TMic140_48;
  // методы MIC140
  protected
    // пересчет точек усреднения АЦП. Учитывает Tgnd, Fs, Tlatch (старт АЦП 0.844uS - 27 тиков),
    // Tisr 112 тиков (3.5us)
    procedure EvalAvrCount;
    // отправка данных на программирование модуля
    procedure ProgramScan;
  protected
    procedure SyncScanProgramFromDeviceProperties;
    procedure ReadDeviceParameters; override;
    procedure SetFs(fs:double); override;
  public
    constructor Create; reintroduce;
    property ScanProgram: TMic140_48 read fScanProgram write fScanProgram;
  end;

// fs - частота опроса по умолчанию
procedure Mic140InitScanProgram48(var AProg: TMic140_48; fs:double);
procedure Mic140EnsureAInChannelCapacity(var AProg: TMic140_48; ACount: Integer);
procedure Mic140EnsureTInChannelCapacity(var AProg: TMic140_48; AVisibleCount: Integer);

function CreateMic140Device: IRecorderDevice;

implementation

const
  // таблица коммутации ME048 для сопоставления входных каналов коммутатору
  CAInNum48: array[0..MIC140_48_AIN_COUNT - 1] of Word =
    (24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
     36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
     23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12,
     11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);


procedure Mic140EnsureAInChannelCapacity(var AProg: TMic140_48; ACount: Integer);
var
  I: Integer;
begin
  if ACount > MIC140_48_AIN_COUNT then
    ACount := MIC140_48_AIN_COUNT;
  if Length(AProg.AInChannels) >= ACount then
    Exit;
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
    AProg.AInChannels[I].CommutIndex := 0;
    AProg.AInChannels[I].BoardCommutIndex := AProg.DefaultBoardCommutIndex;
    AProg.AInChannels[I].RegDesc := $0100;
    AProg.AInChannels[I].ChannelDelaySport := 0;
    AProg.AInChannels[I].ValueDmOffset := Word(I);
  end;
end;

procedure Mic140EnsureTInChannelCapacity(var AProg: TMic140_48; AVisibleCount: Integer);
var
  I: Integer;
begin
  if AVisibleCount > MIC140_48_TIN_VISIBLE_COUNT then
    AVisibleCount := MIC140_48_TIN_VISIBLE_COUNT;
  if Length(AProg.TInChannels) >= AVisibleCount then
    Exit;
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

procedure Mic140InitScanProgram48(var AProg: TMic140_48; fs: double);
begin
  FillChar(AProg, SizeOf(AProg), 0);
  AProg.Timing.FrequencyHz := fs;

  AProg.Timing.PeriodDecayUs := 57.0;
  //Tgnd
  AProg.Timing.PeriodDecay2Us := 19.688;
  AProg.Timing.PeriodAverageUs := MIC140_48_PERIOD_AVER_US;
  AProg.Timing.AverageSampleCount := 1;
  // авто пересчет задержек
  AProg.Timing.AutoCalcPeriodDelay := True;

  AProg.Mc114.TimerScaleMinus1 := 0;
  AProg.Mc114.TimerPeriodMinus1 := MIC140_48_TIMER_PERIOD - 1;
  AProg.Mc114.ScanDivider := 5000;

  AProg.Fifo.DataUpdateMs := 200;
  AProg.Fifo.PayloadStride := MIC140_48_AIN_COUNT;
  AProg.Fifo.FifoReadyWords := 0;
  AProg.Fifo.FifoCapacityWords := 0;
  AProg.Fifo.TinVisibleSlots := MIC140_48_TIN_VISIBLE_COUNT;

  AProg.Flags.AllChannelsSample := True;
  AProg.Flags.ChannelGround := False;
  AProg.Flags.ThermoCompensation := True;

  AProg.ChanDump.VisibleAInCount := MIC140_48_AIN_COUNT;
  AProg.ChanDump.BiosSlotCount := MIC140_48_AIN_COUNT + MIC140_48_TIN_VISIBLE_COUNT;
  AProg.ChanDump.UseGroundPointers := False;

  AProg.DefaultBoardCommutIndex := 0;
  AProg.DefaultRangeIndex := 0;

  SetLength(AProg.AInChannels, 0);
  SetLength(AProg.TInChannels, 0);
  Mic140EnsureAInChannelCapacity(AProg, MIC140_48_AIN_COUNT);
  Mic140EnsureTInChannelCapacity(AProg, MIC140_48_TIN_VISIBLE_COUNT);
end;

function CreateMic140Device: IRecorderDevice;
begin
  Result := TRecorderMic140Device.Create;
end;

constructor TRecorderMic140Device.Create;
begin
  inherited Create('MIC140', 'MIC-140');
  Mic140InitScanProgram48(fScanProgram, 10);
end;

procedure TRecorderMic140Device.EvalAvrCount;
begin

end;

procedure TRecorderMic140Device.ProgramScan;
begin

end;

procedure TRecorderMic140Device.SyncScanProgramFromDeviceProperties;
begin
  fScanProgram.Timing.FrequencyHz := fPollFrequencyHz;
  fScanProgram.Fifo.DataUpdateMs := fUpdateTimeMs;
  Mic140EnsureAInChannelCapacity(fScanProgram, fChannelCount);
end;

procedure TRecorderMic140Device.ReadDeviceParameters;
begin
  inherited ReadDeviceParameters;

  if fChannelCount <= 0 then
    fChannelCount := MIC140_48_AIN_COUNT;
  if fPollFrequencyHz <= 0 then
    fPollFrequencyHz := 10.0;
  if fUpdateTimeMs <= 0 then
    fUpdateTimeMs := 200;

  SyncScanProgramFromDeviceProperties;
end;

procedure TRecorderMic140Device.SetFs(fs: double);
begin
  inherited SetFs(fs);
  fScanProgram.Timing.FrequencyHz:=fs;
end;

end.
