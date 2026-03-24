unit uDACProgram;

{******************************************************************************
 * Модуль управления сценариями ЦАП (uDACProgram.pas)
 *------------------------------------------------------------------------------
 * ЗАДАНИЕ 3:
 *   Иерархия TDacProgram/TSimpleSinusProgram/TAccurateSinusProgram.
 *
 *   Программы подписываются на fDevice.OnBufferEnd и внутри обработчика
 *   вызывают ProcessBuffer(P, Size), а затем очередь устройства ставит буфер
 *   на воспроизведение.
 *****************************************************************************}

interface

uses
  Classes, SysUtils, Math,
  uDacDevice, uSoundCardDac;

type
  { Базовый класс программы ЦАП }
  TDacProgram = class
  protected
    fDevice: TDacDevice;
    fCurrentPhase: Double; // фаза в радианах (преемственность между буферами)

    // брать из девайса
    //fSampleRate: Integer;
    //fChannels: Integer;
    //fBitsPerSample: Integer;
    // частота/ амплитуда генерируемого синуса
    // по логике правильно делать в наследниках, т.к. программа может играть не только синусы
    // а параметры брать из указателя в перкрытой наследником логике обработки
    fFrequency: Double;
    fAmplitude: Double; // 0..1
    fActive: Boolean;

    // Обработчик события устройства: подготовка буфера + вызов ProcessBuffer
    // (инициализация: OnBufferEnd(nil, 0))
    procedure OnDeviceBufferEnd(P: Pointer; Size: Integer); virtual;

    // Генерация данных в буфер (P указывает на память сэмплов)
    procedure ProcessBuffer(P: Pointer; Size: Integer); virtual; abstract;

    // Нормализация фазы в диапазон [0..2Pi)
    function NormalizePhase(APhase: Double): Double;

    // Кол-во сэмплов (моно, 16 bit: Size div SizeOf(SmallInt))
    function GetSampleCountFromBytes(Size: Integer): Integer;

    // Расчет размера буфера (в сэмплах на канал), кратного периоду
    // (алгоритм согласован с тем, как TAccurateSinusProgram задаёт шаг фазы).
    function GetAlignedSize(Freq: Double; MinSamples: Integer): Integer; virtual;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    function SampleRate:cardinal;
    function BitsPerSample:cardinal;
    function Channels:cardinal;
    // Подписка на OnBufferEnd
    procedure Start; virtual;
    procedure Stop; virtual;

    // Привязка к устройству
    procedure SetDevice(AValue: TDacDevice); virtual;

    // Параметры
    procedure SetFrequency(AValue: Double); virtual;
    procedure SetAmplitude(AValue: Double); virtual;

    property Device: TDacDevice read fDevice;
    property Active: Boolean read fActive;
    property Frequency: Double read fFrequency write SetFrequency;
    property Amplitude: Double read fAmplitude write SetAmplitude;
  end;

  { Простая синусоида без перестройки размера буфера }
  TSimpleSinusProgram = class(TDacProgram)
  protected
    procedure ProcessBuffer(P: Pointer; Size: Integer); override;
  public
    constructor Create; override;
  end;

  { Синусоида с кратностью периодов }
  TAccurateSinusProgram = class(TSimpleSinusProgram)
  private
    fMinSamplesTarget: Integer;
    fPeriodSamples: Integer;
    fUseAlignedPeriod: Boolean;
    fMaxAlignedSamples: Integer; // защита от слишком больших буферов

    // Пересчитывает fPeriodSamples и флаг fUseAlignedPeriod по текущей частоте
    procedure UpdatePeriodFromFrequency;
    // Применяет новое значение MinSamplesTarget (и при необходимости вызывает ReallocateBuffers)
    procedure SetMinSamplesTarget(AValue: Integer);

    // Выполняет перевыделение буферов под актуальный aligned size
    procedure ApplyAlignedBufferSize;
  protected
    procedure ProcessBuffer(P: Pointer; Size: Integer); override;
    procedure SetFrequency(AValue: Double); override;
  public
    constructor Create; override;

    { После Open устройства: пересчитать кратный периоду размер и ReallocateBuffers при необходимости }
    procedure RefreshAlignedBuffers;

    property MinSamplesTarget: Integer read fMinSamplesTarget write SetMinSamplesTarget;
    // Для диагностики
    property PeriodSamples: Integer read fPeriodSamples;
  end;

implementation

{ TDacProgram }

function TDacProgram.BitsPerSample: cardinal;
begin
  result:=fDevice.BitsPerSample;
end;

function TDacProgram.Channels: cardinal;
begin
  result:=fDevice.Channels;
end;

constructor TDacProgram.Create;
begin
  inherited Create;
  fCurrentPhase := 0;
  //fSampleRate := 44100;
  //fChannels := 1;
  //fBitsPerSample := 16;
  fFrequency := 440;
  fAmplitude := 0.5;
  fActive := False;
end;

destructor TDacProgram.Destroy;
begin
  Stop;
  inherited;
end;


procedure TDacProgram.Start;
begin
  if fActive or not Assigned(fDevice) then Exit;

  fDevice.AssignOnBufferEndHandler(OnDeviceBufferEnd);
  fActive := True;
end;

procedure TDacProgram.Stop;
begin
  if not fActive then Exit;
  if Assigned(fDevice) then
    fDevice.DetachOnBufferEndIfEqual(OnDeviceBufferEnd);
  fActive := False;
end;

procedure TDacProgram.SetDevice(AValue: TDacDevice);
begin
  if fDevice = AValue then Exit;
  Stop;
  fDevice := AValue;
end;

procedure TDacProgram.SetFrequency(AValue: Double);
begin
  if AValue < 0 then AValue := 0;
  fFrequency := AValue;
end;

function TDacProgram.SampleRate: cardinal;
begin
  result:=fDevice.SampleRate;
end;

procedure TDacProgram.SetAmplitude(AValue: Double);
begin
  if AValue < 0 then
    AValue := 0
  else if AValue > 1 then
    AValue := 1;
  fAmplitude := AValue;
end;

function TDacProgram.NormalizePhase(APhase: Double): Double;
var
  TwoPi: Double;
begin
  TwoPi := 2 * Pi;
  Result := APhase - (TwoPi * Floor(APhase / TwoPi));
end;

function TDacProgram.GetSampleCountFromBytes(Size: Integer): Integer;
begin
  Result := Size div SizeOf(SmallInt);
end;

function TDacProgram.GetAlignedSize(Freq: Double; MinSamples: Integer): Integer;
var
  lPeriodSamples: Integer;
  lPeriodsInBuffer: Integer;
begin
  if (SampleRate <= 0) or (MinSamples <= 0) then
  begin
    Result := MinSamples;
    Exit;
  end;

  if Freq <= 0 then
  begin
    Result := MinSamples;
    Exit;
  end;

  // Округляем до целого числа сэмплов на период
  lPeriodSamples := Round(SampleRate / Freq);
  if lPeriodSamples < 1 then lPeriodSamples := 1;

  lPeriodsInBuffer := Ceil(MinSamples / lPeriodSamples);
  if lPeriodsInBuffer < 1 then lPeriodsInBuffer := 1;

  Result := lPeriodsInBuffer * lPeriodSamples;
end;

procedure TDacProgram.OnDeviceBufferEnd(P: Pointer; Size: Integer);
var
  lBlockData: TBlockData;
  lBlock: PSoundCardBlock;
  lBuffer: PAnsiChar;
  lSizeBytes: Integer;
begin
  if not Assigned(fDevice) then Exit;

  // Инициализация: устройство просит заполнить очередной буфер
  // (используем очередь свободных блоков).
  if (P = nil) or (Size = 0) then
  begin
    if not fDevice.BlockQueue.GetOldestBlock(lBlockData) then
      Exit;

    if (lBlockData.Data = nil) then
      Exit;

    lBlock := PSoundCardBlock(lBlockData.Data);
    if (lBlock = nil) or (lBlock^.Samples = nil) then
      Exit;

    P := lBlock^.Samples;
    lSizeBytes := lBlock^.Header.dwBufferLength;
  end
  else
    lSizeBytes := Size;

  if (P = nil) or (lSizeBytes <= 0) then Exit;

  lBuffer := PAnsiChar(P);

  // 1) генерация данных в предоставленную память
  ProcessBuffer(P, lSizeBytes);

  // 2) постановка буфера на воспроизведение
  fDevice.QueueBuffer(lBuffer^, lSizeBytes);
end;

{ TSimpleSinusProgram }

constructor TSimpleSinusProgram.Create;
begin
  inherited Create;
end;

procedure TSimpleSinusProgram.ProcessBuffer(P: Pointer; Size: Integer);
var
  i: Integer;
  lSampleCount: Integer;
  lSamples: PSmallInt;
  lStep: Double;
begin
  if (P = nil) or (Size <= 0) then Exit;
  lSamples := PSmallInt(P);
  lSampleCount := GetSampleCountFromBytes(Size);
  if (lSampleCount <= 0) or (SampleRate <= 0) then Exit;

  // Пошаговое накопление фазы для непрерывности между буферами
  lStep := 2 * Pi * fFrequency / SampleRate;

  for i := 0 to lSampleCount - 1 do
  begin
    lSamples^ := Round(fAmplitude * Sin(fCurrentPhase) * 32767);
    Inc(lSamples);
    fCurrentPhase := fCurrentPhase + lStep;
    if fCurrentPhase > (2 * Pi) then
      fCurrentPhase := NormalizePhase(fCurrentPhase);
  end;
end;

{ TAccurateSinusProgram }

constructor TAccurateSinusProgram.Create;
begin
  inherited Create;
  fMinSamplesTarget := 1024;
  fPeriodSamples := 0;
  fUseAlignedPeriod := False;

  // Защита: не более ~4 секунд моно/16-bit буфера (иначе слишком крупные аллокации)
  fMaxAlignedSamples := 44100 * 4;
end;

procedure TAccurateSinusProgram.UpdatePeriodFromFrequency;
var
  lAlignedSamples: Integer;
begin
  fPeriodSamples := 0;
  fUseAlignedPeriod := False;

  if (fFrequency <= 0) or (SampleRate <= 0) then Exit;

  // Обновляем лимит по текущей SampleRate
  fMaxAlignedSamples := SampleRate * 4;

  fPeriodSamples := Round(SampleRate / fFrequency);
  if fPeriodSamples < 1 then fPeriodSamples := 1;

  lAlignedSamples := GetAlignedSize(fFrequency, fMinSamplesTarget);
  if lAlignedSamples > fMaxAlignedSamples then Exit;

  fUseAlignedPeriod := True;
end;

procedure TAccurateSinusProgram.ApplyAlignedBufferSize;
var
  lAlignedSamples: Integer;
  lBytesPerSample: Integer;
  lNewBytes: Integer;
begin
  if not Assigned(fDevice) then Exit;
  if (fDevice.State = stClosed) then Exit;
  if not fUseAlignedPeriod then Exit;

  // aligned sample count (на канал)
  lAlignedSamples := GetAlignedSize(fFrequency, fMinSamplesTarget);
  if lAlignedSamples <= 0 then Exit;

  lBytesPerSample := (BitsPerSample div 8) * Channels;
  if lBytesPerSample <= 0 then Exit;

  lNewBytes := lAlignedSamples * lBytesPerSample;
  if Integer(fDevice.BufferSize) <> lNewBytes then
    fDevice.ReallocateBuffers(lNewBytes);
end;

procedure TAccurateSinusProgram.SetMinSamplesTarget(AValue: Integer);
begin
  if AValue < 64 then AValue := 64;
  if fMinSamplesTarget = AValue then Exit;

  fMinSamplesTarget := AValue;
  UpdatePeriodFromFrequency;
  ApplyAlignedBufferSize;
end;

procedure TAccurateSinusProgram.SetFrequency(AValue: Double);
begin
  if AValue < 0 then AValue := 0;
  if fFrequency = AValue then Exit;

  fFrequency := AValue;

  UpdatePeriodFromFrequency;

  // Если перешли в простой режим — буферы не перевыделяем
  if not fUseAlignedPeriod then Exit;

  // Если размер должен измениться — перевыделяем буферы
  ApplyAlignedBufferSize;
end;

procedure TAccurateSinusProgram.RefreshAlignedBuffers;
begin
  if not Assigned(fDevice) then Exit;
  UpdatePeriodFromFrequency;
  ApplyAlignedBufferSize;
end;

procedure TAccurateSinusProgram.ProcessBuffer(P: Pointer; Size: Integer);
var
  i: Integer;
  lSampleCount: Integer;
  lSamples: PSmallInt;
  lStep: Double;
begin
  if not fUseAlignedPeriod then
  begin
    // Базовое поведение: просто синус с шагом по точной частоте
    inherited ProcessBuffer(P, Size);
    Exit;
  end;

  if (P = nil) or (Size <= 0) then Exit;
  lSamples := PSmallInt(P);
  lSampleCount := GetSampleCountFromBytes(Size);
  if (lSampleCount <= 0) or (fPeriodSamples <= 0) then Exit;

  // Шаг фазы задаём по целому числу сэмплов на период,
  // чтобы в конце буфера не было дрейфа по фазе.
  lStep := (2 * Pi) / fPeriodSamples;

  for i := 0 to lSampleCount - 1 do
  begin
    lSamples^ := Round(fAmplitude * Sin(fCurrentPhase) * 32767);
    Inc(lSamples);
    fCurrentPhase := fCurrentPhase + lStep;
    if fCurrentPhase > (2 * Pi) then
      fCurrentPhase := NormalizePhase(fCurrentPhase);
  end;
end;

end.