unit uDACProgram;

{******************************************************************************
 * Модуль управления сценариями ЦАП (uDACProgram.pas)
 *------------------------------------------------------------------------------
 * НАЗНАЧЕНИЕ:
 *   Этот модуль содержит иерархию классов «программ» для управления
 *   генерацией сигналов ЦАП. Программы инкапсулируют логику генерации
 *   и сами управляют подпиской на события устройства.
 *
 * АРХИТЕКТУРА:
 *   TDacProgram - базовый класс программы (знает про устройство)
 *   TSimpleSinusProgram - простая генерация синуса
 *   TAccurateSinusProgram - умная генерация с кратностью периодов
 *****************************************************************************}

interface

uses
  Classes, SysUtils, Math, uCommonTypes, uDacDevice, uSoundCardDac;

type
  { TDacProgram - базовый класс программы }
  TDacProgram = class
  protected
    fDevice: TDacDevice;
    fCurrentPhase: Double;
    fSampleRate: Integer;
    fChannels: Integer;
    fBitsPerSample: Integer;
    fFrequency: Double;
    fAmplitude: Double;
    fActive: Boolean;

    // Виртуальный метод генерации данных
    procedure GenerateData(P: PSmallIntArray; SampleCount: Integer); virtual; abstract;
    // Обработчик события устройства
    procedure OnDeviceGenerateData(P: Pointer; Size: Integer); virtual;
    // Нормализация фазы
    function NormalizePhase(APhase: Double): Double;
    // Получить размер буфера в сэмплах
    function GetSampleCount(Size: Integer): Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // Подписка на устройство
    procedure Start; virtual;
    procedure Stop; virtual;
    procedure SetDevice(AValue: TDacDevice); virtual;

    // Параметры
    procedure SetFrequency(AValue: Double); virtual;
    procedure SetAmplitude(AValue: Double); virtual;

    property Device: TDacDevice read fDevice;
    property Active: Boolean read fActive;
    property Frequency: Double read fFrequency write SetFrequency;
    property Amplitude: Double read fAmplitude write SetAmplitude;
  end;

  { TSimpleSinusProgram - простая генерация синуса }
  TSimpleSinusProgram = class(TDacProgram)
  protected
    procedure GenerateData(P: PSmallIntArray; SampleCount: Integer); override;
    function GenerateSample: Double; virtual;
  public
    constructor Create; override;
  end;

  { TAccurateSinusProgram - умная генерация с кратностью периодов }
  TAccurateSinusProgram = class(TSimpleSinusProgram)
  private
    fMinSamplesTarget: Integer;
    fLastFrequency: Double;
    fRequiredBufferSize: Integer;
    procedure UpdateRequiredSize;
    procedure SetMinSamplesTarget(AValue: Integer);
  protected
    procedure SetFrequency(AValue: Double); override;
    procedure SetDevice(AValue: TDacDevice); override;
  public
    constructor Create; override;
    property MinSamplesTarget: Integer read fMinSamplesTarget write SetMinSamplesTarget;
    property RequiredBufferSize: Integer read fRequiredBufferSize;
  end;

function CalculateAlignedBufferSize(Freq, SampleRate: Double; MinSamples: Integer): Integer;

implementation

function CalculateAlignedBufferSize(Freq, SampleRate: Double; MinSamples: Integer): Integer;
var
  SamplesPerPeriod: Double;
  PeriodsInBuffer: Integer;
begin
  if (Freq <= 0) or (SampleRate <= 0) or (MinSamples <= 0) then
  begin
    Result := MinSamples;
    Exit;
  end;

  SamplesPerPeriod := SampleRate / Freq;
  PeriodsInBuffer := Ceil(MinSamples / SamplesPerPeriod);
  if PeriodsInBuffer < 1 then
    PeriodsInBuffer := 1;

  Result := Round(PeriodsInBuffer * SamplesPerPeriod);
  Result := (Result + 3) and not 3;
end;

{ TDacProgram }

constructor TDacProgram.Create;
begin
  inherited Create;
  fCurrentPhase := 0;
  fSampleRate := 44100;
  fChannels := 1;
  fBitsPerSample := 16;
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
  if Assigned(fDevice) and not fActive then
  begin
    fDevice.OnGenerateData := OnDeviceGenerateData;
    fActive := True;
  end;
end;

procedure TDacProgram.Stop;
begin
  if fActive and Assigned(fDevice) then
  begin
    fDevice.OnGenerateData := nil;
  end;
  fActive := False;
end;

procedure TDacProgram.SetDevice(AValue: TDacDevice);
begin
  if fDevice <> AValue then
  begin
    Stop;
    fDevice := AValue;
    if Assigned(fDevice) then
    begin
      fSampleRate := fDevice.SampleRate;
      fChannels := fDevice.Channels;
      fBitsPerSample := fDevice.BitsPerSample;
    end;
  end;
end;

procedure TDacProgram.SetFrequency(AValue: Double);
begin
  if AValue < 0 then
    AValue := 0;
  if fFrequency <> AValue then
    fFrequency := AValue;
end;

procedure TDacProgram.SetAmplitude(AValue: Double);
begin
  if AValue < 0 then
    AValue := 0
  else if AValue > 1 then
    AValue := 1;
  if fAmplitude <> AValue then
    fAmplitude := AValue;
end;

function TDacProgram.NormalizePhase(APhase: Double): Double;
begin
  Result := APhase - (2 * Pi * Floor(APhase / (2 * Pi)));
end;

function TDacProgram.GetSampleCount(Size: Integer): Integer;
begin
  Result := Size div SizeOf(SmallInt);
end;

procedure TDacProgram.OnDeviceGenerateData(P: Pointer; Size: Integer);
var
  lBlock: PSoundCardBlock;
  lBlockData: TBlockData;
  lSamples: PSmallIntArray;
  lSampleCount: Integer;
begin
  // Если P=nil, Size=0 - получаем буфер из очереди
  if (P = nil) or (Size = 0) then
  begin
    if not Assigned(fDevice) or not (fDevice is TSoundCardDac) then
      Exit;

    if not TSoundCardDac(fDevice).BlockQueue.GetOldestBlock(lBlockData) then
      Exit;

    if (lBlockData.Data = nil) or lBlockData.IsDeleted then
      Exit;

    lBlock := PSoundCardBlock(lBlockData.Data);
    lSamples := PSmallIntArray(lBlock.Samples);
    lSampleCount := lBlock.Header.dwBufferLength div SizeOf(SmallInt);
  end
  else
  begin
    lSamples := PSmallIntArray(P);
    lSampleCount := GetSampleCount(Size);
  end;

  // Генерируем данные
  GenerateData(lSamples, lSampleCount);

  // Ставим буфер в очередь
  if Assigned(lBlock) then
    fDevice.QueueBuffer(lBlock.Samples^, lBlock.Header.dwBufferLength);
end;

{ TSimpleSinusProgram }

constructor TSimpleSinusProgram.Create;
begin
  inherited Create;
end;

function TSimpleSinusProgram.GenerateSample: Double;
begin
  Result := fAmplitude * Sin(2 * Pi * fFrequency / fSampleRate + fCurrentPhase);
  fCurrentPhase := fCurrentPhase + 2 * Pi * fFrequency / fSampleRate;
  if fCurrentPhase > 2 * Pi then
    fCurrentPhase := NormalizePhase(fCurrentPhase);
end;

procedure TSimpleSinusProgram.GenerateData(P: PSmallIntArray; SampleCount: Integer);
var
  i: Integer;
begin
  if not Assigned(P) or (SampleCount = 0) then
    Exit;

  for i := 0 to SampleCount - 1 do
  begin
    P[i] := Round(GenerateSample * 32767);
  end;
end;

{ TAccurateSinusProgram }

constructor TAccurateSinusProgram.Create;
begin
  inherited Create;
  fMinSamplesTarget := 1024;
  fLastFrequency := 0;
  fRequiredBufferSize := 1024;
end;

procedure TAccurateSinusProgram.UpdateRequiredSize;
begin
  fRequiredBufferSize := CalculateAlignedBufferSize(fFrequency, fSampleRate, fMinSamplesTarget);
end;

procedure TAccurateSinusProgram.SetMinSamplesTarget(AValue: Integer);
begin
  if AValue < 64 then
    AValue := 64;
  if fMinSamplesTarget <> AValue then
  begin
    fMinSamplesTarget := AValue;
    UpdateRequiredSize;
  end;
end;

procedure TAccurateSinusProgram.SetFrequency(AValue: Double);
begin
  inherited SetFrequency(AValue);

  if fFrequency <> fLastFrequency then
  begin
    UpdateRequiredSize;
    fLastFrequency := fFrequency;

    // Если устройство открыто и размер не совпадает - перевыделяем буферы
    if Assigned(fDevice) and (fDevice is TSoundCardDac) then
    begin
      if fRequiredBufferSize * SizeOf(SmallInt) <> Integer(fDevice.BufferSize) then
        TSoundCardDac(fDevice).ReallocateBuffers(fRequiredBufferSize * SizeOf(SmallInt));
    end;
  end;
end;

procedure TAccurateSinusProgram.SetDevice(AValue: TDacDevice);
begin
  inherited SetDevice(AValue);
  if Assigned(AValue) then
  begin
    UpdateRequiredSize;
    fLastFrequency := fFrequency;
  end;
end;

end.