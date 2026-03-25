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
  ucommontypes,
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
    // Параметры транспорта (задаёт клиент/UI, применяются к fDevice при Open)
    fDacData: TDacData;

    { Применить fTransport* к fDevice (только поля; Open отдельно). }
    procedure ApplyTransportToDevice;
    { После подписки OnBufferEnd и перед fDevice.Start — перевыделение буферов у Accurate и т.п. }
    procedure DoPrepareAfterSubscribeBeforeDeviceStart; virtual;

    // Обработчик события устройства: подготовка буфера + вызов ProcessBuffer
    // (инициализация: OnBufferEnd(nil, 0))
    procedure OnGenData(data: tobject); virtual;

    // Генерация данных в буфер (P указывает на память сэмплов)
    // тут есть проблемма. Генерация данных зависима от типа данных в ЦАП
    // пока заполняем shortint-ами
    procedure ProcessBuffer(P: Pointer; Size: Integer); virtual; abstract;

    // Нормализация фазы в диапазон [0..2Pi)
    function NormalizePhase(APhase: Double): Double;

    // Расчет размера буфера (в сэмплах на канал), кратного периоду
    // (алгоритм согласован с тем, как TAccurateSinusProgram задаёт шаг фазы).
    function GetAlignedSize(Freq: Double; MinSamples: Integer): Integer; virtual;
    // Параметры
    procedure SetFrequency(AValue: Double); virtual;
    procedure SetAmplitude(AValue: Double); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function SampleRate:cardinal;
    function BitsPerSample:cardinal;
    function Channels:cardinal;
    // Подписка на OnBufferEnd
    // Полный запуск: при необходимости Open, подписка, подготовка, fDevice.Start
    procedure Start(ALoopCount: Cardinal = 1); virtual;
    // Останов воспроизведения: снятие подписки + fDevice.Stop.
    procedure Stop(AGraceful: Boolean = False);virtual;
    // Задать параметры устройства из UI (без Open/Start)
    procedure ConfigureTransport(d:TDacData);

    function IsPlaybackActive: Boolean;

    // Привязка к устройству
    procedure SetDevice(AValue: TDacDevice); virtual;


    property Device: TDacDevice read fDevice;
    property Active: Boolean read fActive;
    // частота и амплитуда ЦАП
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
  fFrequency := 440;
  fAmplitude := 0.5;
  fActive := False;
  // так плохо делать, лучше инициировать данные в клиентских модулях с UI
  fDacData.fTransportDeviceIndex := 0;
  fDacData.fTransportSampleRate := 44100;
  fDacData.fTransportBitsPerSample := 16;
  fDacData.fTransportChannels := 1;
  fDacData.fTransportBufferSizeMS := 300;
end;

destructor TDacProgram.Destroy;
begin
  Stop;
  inherited;
end;

procedure TDacProgram.Start(ALoopCount: Cardinal);
begin
  if not Assigned(fDevice) then Exit;
  if fDevice.IsPlay then Exit;

  if fDevice.State = stClosed then
  begin
    ApplyTransportToDevice;
    fDevice.Open;
  end;

  fDevice.OnGenerateData:= OnGenData;
  fActive := True;

  DoPrepareAfterSubscribeBeforeDeviceStart;
  fCurrentPhase := 0;
  fDevice.Start(ALoopCount);
  // генерим один доп блок заранее, чтобы ЦАП был на один блок всегда впереди
  // чтоб не было разрывов данных
  //OnGenData(nil,0);
end;


procedure TDacProgram.Stop(AGraceful: Boolean);
begin
  if not Assigned(fDevice) then Exit;
  fActive := False;
  if fDevice.IsPlay then
    fDevice.Stop(AGraceful);
end;

procedure TDacProgram.SetDevice(AValue: TDacDevice);
begin
  if fDevice = AValue then Exit;
  Stop;
  fDevice := AValue;
end;

procedure TDacProgram.ConfigureTransport(d:TDacData);
begin
  fDacData:=d;
end;

procedure TDacProgram.ApplyTransportToDevice;
begin
  if not Assigned(fDevice) then Exit;
  fDevice.ApplyData(fDacData);
end;

procedure TDacProgram.DoPrepareAfterSubscribeBeforeDeviceStart;
begin
end;

function TDacProgram.IsPlaybackActive: Boolean;
begin
  Result := Assigned(fDevice) and fDevice.IsPlay;
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

procedure TDacProgram.OnGenData(data: tobject);
var
  lBlockData: pBlockData;
  lBlock: PSoundCardBlock;
  p:pointer;
begin
  if not Assigned(fDevice) then Exit;

  // Инициализация: устройство просит заполнить очередной буфер
  // (используем очередь свободных блоков).
  lBlockData:=fDevice.BlockQueue.GetPushBlock;

  if (lBlockData.Data = nil) then  Exit;
  lBlock := PSoundCardBlock(lBlockData.Data);

  if (lBlock = nil) or (lBlock^.Samples = nil) then  Exit;
  // PSmallIntArray
  P := @lBlock.Samples[0];
  // 1) генерация данных в предоставленную память
  ProcessBuffer(P, fDevice.BufferSize);
  // 2) постановка буфера на воспроизведение
  fDevice.QueueBuffer;
end;

{ TSimpleSinusProgram }

constructor TSimpleSinusProgram.Create;
begin
  inherited Create;
end;

procedure TSimpleSinusProgram.ProcessBuffer(P: Pointer; Size: Integer);
var
  i, count: Integer;
  lSamples: pSmallIntArray;
  lStep: Double;
begin
  fDevice.entercs;
  if (P = nil) or (Size <= 0) then Exit;
  lSamples := PSmallIntArray(P);
  // Пошаговое накопление фазы для непрерывности между буферами
  lStep := 2 * Pi * fFrequency / SampleRate;
  count:=size shr 1;
  for i := 0 to (count) - 1 do
  begin
    Tsmallintarray(lSamples)[i] := Round(fAmplitude * Sin(fCurrentPhase) * 32767);
    fCurrentPhase := fCurrentPhase + lStep;
    if fCurrentPhase > (2 * Pi) then
      fCurrentPhase := NormalizePhase(fCurrentPhase);
  end;
  fDevice.exitcs;
end;


end.