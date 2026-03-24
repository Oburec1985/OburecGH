unit uDacProgram;

interface

uses
  uDacDevice, uCommonTypes, Math, SysUtils;

type
  { Базовый класс программы ЦАП }
  TDacProgram = class
  protected
    fDevice: TDacDevice;
    fCurrentPhase: Double;
    fSampleRate: Integer;
    fAmplitude: Double;
    fFrequency: Double;

    // Вспомогательный метод для нормализации фазы (0..2PI)
    function IsolatePhase(APhase: Double): Double;
    // Расчет размера буфера, кратного периоду
    function GetAlignedSize(AFreq: Double; AMinSamples: Integer): Integer;

    // Обработчик события от устройства
    procedure DoOnBufferEnd(P: Pointer; Size: Integer); virtual;
  public
    constructor Create(ADevice: TDacDevice); virtual;
    destructor Destroy; override;

    // Метод для заполнения данных (переопределяется в наследниках)
    procedure FillData(P: PSmallIntArray; SampleCount: Integer); virtual; abstract;

    // Обновление параметров извне
    procedure SetParameters(AFreq, AAmpl: Double); virtual; abstract;

    property Frequency: Double read fFrequency;
    property Amplitude: Double read fAmplitude;
  end;

  { 1. "Тупая" программа: быстрое обновление без ресайза буфера }
  TSimpleSinusProgram = class(TDacProgram)
  public
    procedure FillData(P: PSmallIntArray; SampleCount: Integer);override;
    procedure SetParameters(AFreq, AAmpl: Double); override;
  end;

  { 2. "Умная" программа: подстройка размера буфера под кратность периодов }
  TAccurateSinusProgram = class(TDacProgram)
  private
    fMinSamplesTarget: Integer;
  public
    constructor Create(ADevice: TDacDevice); override;
    procedure FillData(P: PSmallIntArray; SampleCount: Integer); override;
    procedure SetParameters(AFreq, AAmpl: Double); override;
    property MinSamplesTarget: Integer read fMinSamplesTarget write fMinSamplesTarget;
  end;

implementation

{ TDacProgram }

constructor TDacProgram.Create(ADevice: TDacDevice);
begin
  inherited Create;
  fDevice := ADevice;
  fSampleRate := fDevice.SampleRate;
  fCurrentPhase := 0;
  // Подписываемся на событие устройства
  fDevice.OnBufferEnd := DoOnBufferEnd;
end;

destructor TDacProgram.Destroy;
begin
  if Assigned(fDevice) then
    fDevice.OnBufferEnd := nil;
  inherited;
end;

procedure TDacProgram.DoOnBufferEnd(P: Pointer; Size: Integer);
begin
  // Вызываем генерацию данных (Size / 4, так как 16бит стерео)
  FillData(PSmallIntArray(P), Size div 4);
end;

function TDacProgram.IsolatePhase(APhase: Double): Double;
begin
  Result := APhase - (2 * Pi * Int(APhase / (2 * Pi)));
end;

function TDacProgram.GetAlignedSize(AFreq: Double; AMinSamples: Integer): Integer;
var
  SamplesPerPeriod: Double;
  PeriodsCount: Integer;
begin
  if AFreq < 0.1 then begin Result := 4096; Exit; end;

  SamplesPerPeriod := fSampleRate / AFreq;
  PeriodsCount := Max(1, Round(AMinSamples / SamplesPerPeriod));
  // 4 байта на сэмпл (L+R 16 бит)
  Result := Round(SamplesPerPeriod * PeriodsCount) * 4;
end;

{ TSimpleSinusProgram }

procedure TSimpleSinusProgram.SetParameters(AFreq, AAmpl: Double);
begin
  // Просто запоминаем. Фаза склеится сама в FillData
  fFrequency := AFreq;
  fAmplitude := AAmpl;
end;

procedure TSimpleSinusProgram.FillData(P: PSmallIntArray; SampleCount: Integer);
var
  i: Integer;
  AngleStep: Double;
  v: SmallInt;
begin
  AngleStep := 2 * Pi * fFrequency / fSampleRate;
  for i := 0 to SampleCount - 1 do
  begin
    v := Round(fAmplitude * 32767 * Sin(fCurrentPhase));
    P^[i*2] := v;
    P^[i*2+1] := v;
    fCurrentPhase := fCurrentPhase + AngleStep;
  end;
  fCurrentPhase := IsolatePhase(fCurrentPhase);
end;

{ TAccurateSinusProgram }

constructor TAccurateSinusProgram.Create(ADevice: TDacDevice);
begin
  inherited;
  fMinSamplesTarget := 1024; // Дефолтное значение
end;

procedure TAccurateSinusProgram.SetParameters(AFreq, AAmpl: Double);
var
  NewSize: Integer;
begin
  fFrequency := AFreq;
  fAmplitude := AAmpl;

  // Рассчитываем идеальный размер буфера для этой частоты
  NewSize := GetAlignedSize(fFrequency, fMinSamplesTarget);

  // Если размер изменился - перестраиваем устройство
  if NewSize <> fDevice.BufferSize then
    fDevice.ReallocateBuffers(NewSize);
end;

procedure TAccurateSinusProgram.FillData(P: PSmallIntArray; SampleCount: Integer);
begin
  // Логика заполнения такая же, как в простой,
  // но за счет SetParameters размер SampleCount всегда кратен периоду
  TSimpleSinusProgram(Self).FillData(P, SampleCount);
end;

end.
