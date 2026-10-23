unit uRecorderImpactHammer;

{ Ядро захвата удара: распознаёт триггер, собирает временные ряды каналов и
  хранит готовые удары для FRF-расчёта. Не зависит от UI, тегов и файлов. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Math, complex, uRecorderFrfContracts, uRecorderFrfRepository;

type
  TRecorderImpactPolarity = (ipPositive, ipNegative, ipAbsolute);
  TRecorderImpactState = (isIdle, isArmed, isCapturing, isStopped, isFaulted);
  TRecorderImpactTriggerState = (itsWaiting, itsAboveThreshold);
  TRecorderFrfEstimatorKind = (fekH0, fekH1, fekH2);
  TRecorderImpactRejectReason = (irrNone, irrOverload, irrTooShort,
    irrMissingResponse, irrInvalidSpectrum, irrManual);

  { Частота задаётся в Гц, порог и гистерезис — в единицах сигнала молотка;
    пре-триггер и длительность окна — в секундах. Capacity — число ударов. }
  TRecorderImpactSettings = record
    SampleRateHz: Double;
    Threshold: Double;
    Hysteresis: Double;
    PretriggerSeconds: Double;
    CaptureSeconds: Double;
    Capacity: Integer;
    ResponseCount: Integer;
    Polarity: TRecorderImpactPolarity;
    Estimator: TRecorderFrfEstimatorKind;
  end;

  TRecorderImpactTriggerEvent = record
    Triggered: Boolean;
    PeakTimeSeconds: Double;
    PeakValue: Double;
    CaptureStartSeconds: Double;
    CaptureEndSeconds: Double;
    CaptureToken: QWord;
  end;

  TRecorderTimedSample = record
    TimeSeconds: Double;
    Value: Double;
  end;

  TRecorderSampleSeries = array of TRecorderTimedSample;

  { Зафиксированный набор каналов одного удара. Каждый ряд хранит исходные
    времена; готовность требует покрытия общего окна всеми каналами. }
  TRecorderImpactCaptureBlock = class
  private
    fToken: QWord;
    fStartSeconds, fEndSeconds: Double;
    fExcitation: TRecorderSampleSeries;
    fResponses: array of TRecorderSampleSeries;
    fExcitationCount: Integer;
    fResponseCounts: array of Integer;
    constructor CreateAdopted;
  public
    constructor Create(AToken: QWord; AStartSeconds, AEndSeconds: Double;
      const AExcitation: TRecorderSampleSeries;
      const AResponses: array of TRecorderSampleSeries);
    class function Adopt(AToken: QWord; AStartSeconds, AEndSeconds: Double;
      var AExcitation: TRecorderSampleSeries;
      var AResponses: array of TRecorderSampleSeries;
      AExcitationCount: Integer; const AResponseCounts: array of Integer):
      TRecorderImpactCaptureBlock; static;
    function ResponseCount: Integer;
    function Excitation: TRecorderSampleSeries;
    function Response(AIndex: Integer): TRecorderSampleSeries;
    property Token: QWord read fToken;
    property EndSeconds: Double read fEndSeconds;
    property StartSeconds: Double read fStartSeconds;
  end;

  TRecorderImpactCapture = class
  private
    fToken: QWord;
    fStartSeconds, fEndSeconds: Double;
    fExcitation: TRecorderSampleSeries;
    fResponses: array of TRecorderSampleSeries;
    fExcitationCount: Integer;
    fResponseCounts: array of Integer;
    fSpareExcitation: TRecorderSampleSeries;
    fSpareResponses: array of TRecorderSampleSeries;
    class function Covers(const ASeries: TRecorderSampleSeries; ACount: Integer;
      AStartSeconds, AEndSeconds: Double): Boolean; static;
    class function Append(var ASeries: TRecorderSampleSeries; var ACount: Integer;
      ATimeSeconds, AValue: Double): Boolean; static;
  public
    procedure PrepareBuffers(AResponseCount, AExpectedSamples: Integer);
    procedure PrepareSpareBuffers(AResponseCount, AExpectedSamples: Integer);
    procedure BeginCapture(AToken: QWord; AStartSeconds, AEndSeconds: Double;
      AResponseCount, AExpectedSamples: Integer);
    function AddExcitation(ATimeSeconds, AValue: Double): Boolean;
    function AddResponse(AIndex: Integer; ATimeSeconds, AValue: Double): Boolean;
    function IsReady: Boolean;
    function Freeze: TRecorderImpactCaptureBlock;
    property Token: QWord read fToken;
  end;

  TRecorderImpactRecord = record
    Sequence: QWord;
    PeakTimeSeconds: Double;
    PeakValue: Double;
    Accepted: Boolean;
    RejectReason: TRecorderImpactRejectReason;
    Hidden: Boolean;
    RecomputeRequired: Boolean;
  end;

  TRecorderImpactSpectrum = record
    FrequencyHz: array of Double;
    Excitation: array of TComplex_d;
    Response: array of TComplex_d;
  end;

  TRecorderFrfEstimate = record
    FrequencyHz: array of Double;
    Magnitude: array of Double;
    PhaseRadians: array of Double;
    Coherence: array of Double;
  end;

  IRecorderFrfEstimator = interface
    ['{99EE790E-6534-4EEC-A999-DB0803930061}']
    function Estimate(const ASpectra: array of TRecorderImpactSpectrum;
      AKind: TRecorderFrfEstimatorKind; out AResult: TRecorderFrfEstimate): Boolean;
  end;

  TRecorderImpactTrigger = class
  private
    fSettings: TRecorderImpactSettings;
    fState: TRecorderImpactTriggerState;
    fPeakTime: Double;
    fPeakValue: Double;
    function DirectedValue(AValue: Double): Double;
  public
    procedure Configure(const ASettings: TRecorderImpactSettings);
    procedure SetThreshold(AValue: Double);
    procedure Reset;
    function ProcessSample(ATimeSeconds, AValue: Double;
      out AEvent: TRecorderImpactTriggerEvent): Boolean;
    property State: TRecorderImpactTriggerState read fState;
  end;

  TRecorderImpactSet = class
  private
    fItems: array of TRecorderImpactRecord;
    fCapacity: Integer;
    fStart: Integer;
    fCount: Integer;
    fNextSequence: QWord;
    fBlocks: array of TRecorderImpactCaptureBlock;
  public
    destructor Destroy; override;
    procedure Configure(ACapacity: Integer);
    procedure Clear;
    function Add(APeakTimeSeconds, APeakValue: Double; AAccepted: Boolean;
      AReason: TRecorderImpactRejectReason;
      ABlock: TRecorderImpactCaptureBlock): QWord;
    function Item(AIndex: Integer): TRecorderImpactRecord;
    function Capture(AIndex: Integer): TRecorderImpactCaptureBlock;
    function Delete(ASequence: QWord): Boolean;
    function SetHidden(ASequence: QWord; AHidden: Boolean): Boolean;
    function MarkForRecompute(ASequence: QWord): Boolean;
    property Count: Integer read fCount;
  end;

  TRecorderCrossSpectrumEstimator = class(TInterfacedObject,
    IRecorderFrfEstimator)
  public
    function Estimate(const ASpectra: array of TRecorderImpactSpectrum;
      AKind: TRecorderFrfEstimatorKind; out AResult: TRecorderFrfEstimate): Boolean;
  end;

  TRecorderImpactRuntime = class
  private
    fSettings: TRecorderImpactSettings;
    fState: TRecorderImpactState;
    fTrigger: TRecorderImpactTrigger;
    fImpacts: TRecorderImpactSet;
    fRepository: TRecorderFrfRepository;
    fProvider: IRecorderFrfProvider;
    fCapture: TRecorderImpactCapture;
    fPendingEvent: TRecorderImpactTriggerEvent;
    fNextCaptureToken: QWord;
  public
    constructor Create;
    destructor Destroy; override;
    class function ValidateSettings(const ASettings: TRecorderImpactSettings;
      out AError: string): Boolean; static;
    function Configure(const ASettings: TRecorderImpactSettings;
      out AError: string): Boolean;
    procedure SetThreshold(AValue: Double);
    function Arm: Boolean;
    function BeginPortion(ATimeSeconds: Double;
      out AEvent: TRecorderImpactTriggerEvent): Boolean;
    procedure Stop;
    function ProcessTriggerSample(ATimeSeconds, AValue: Double;
      out AEvent: TRecorderImpactTriggerEvent): Boolean;
    function AddExcitationSample(AToken: QWord; ATimeSeconds,
      AValue: Double): Boolean;
    function AddResponseSample(AToken: QWord; AResponseIndex: Integer;
      ATimeSeconds, AValue: Double): Boolean;
    function CaptureReady(AToken: QWord): Boolean;
    function RecordImpact(AToken: QWord;
      AAccepted: Boolean; AReason: TRecorderImpactRejectReason): QWord;
    procedure PrepareCaptureSpareBuffers;
    function Publish(ACurveId: QWord; const AEstimate: TRecorderFrfEstimate): Boolean;
    function PublishCurves(
      const ACurves: array of TRecorderFrfCurveData): Boolean;
    procedure ClearPublished;
    property State: TRecorderImpactState read fState;
    property Impacts: TRecorderImpactSet read fImpacts;
    property Provider: IRecorderFrfProvider read fProvider;
  end;

function RecorderImpactFreezePayloadCopyCount: QWord;
function RecorderImpactCaptureResizeCount: QWord;

implementation

var
  GFreezePayloadCopyCount: QWord;
  GCaptureResizeCount: QWord;

{ Число скопированных отсчётов при фиксации захвата; диагностический счётчик. }
function RecorderImpactFreezePayloadCopyCount: QWord;
begin
  Result := GFreezePayloadCopyCount;
end;

{ Число изменений размеров буферов захвата; диагностический счётчик. }
function RecorderImpactCaptureResizeCount: QWord;
begin
  Result := GCaptureResizeCount;
end;

{ Проверяет, что число не NaN и не бесконечность. }
function Finite(AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue);
end;

{ Возвращает квадрат модуля комплексного числа без извлечения корня. }
function ComplexMagnitudeSquared(const AValue: TComplex_d): Double;
begin
  Result := AValue.Re * AValue.Re + AValue.Im * AValue.Im;
end;

{ Вычисляет ALeft умножить на сопряжённое ARight для взаимного спектра. }
function MultiplyConjugate(const ALeft, ARight: TComplex_d): TComplex_d;
begin
  Result.Re := ALeft.Re * ARight.Re + ALeft.Im * ARight.Im;
  Result.Im := ALeft.Im * ARight.Re - ALeft.Re * ARight.Im;
end;

{ Создаёт неизменяемый блок захвата копированием рядов и их фактических длин. }
constructor TRecorderImpactCaptureBlock.Create(AToken: QWord;
  AStartSeconds, AEndSeconds: Double; const AExcitation: TRecorderSampleSeries;
  const AResponses: array of TRecorderSampleSeries);
var
  lIndex: Integer;
begin
  inherited Create;
  fToken := AToken;
  fStartSeconds := AStartSeconds;
  fEndSeconds := AEndSeconds;
  fExcitation := Copy(AExcitation);
  fExcitationCount := Length(fExcitation);
  SetLength(fResponses, Length(AResponses));
  SetLength(fResponseCounts, Length(AResponses));
  for lIndex := 0 to High(AResponses) do
  begin
    fResponses[lIndex] := Copy(AResponses[lIndex]);
    fResponseCounts[lIndex] := Length(fResponses[lIndex]);
  end;
  Inc(GFreezePayloadCopyCount, fExcitationCount);
  for lIndex := 0 to High(fResponseCounts) do
    Inc(GFreezePayloadCopyCount, fResponseCounts[lIndex]);
end;

{ Передаёт массивы отсчётов блоку без копирования; очищает исходные ссылки. }
class function TRecorderImpactCaptureBlock.Adopt(AToken: QWord;
  AStartSeconds, AEndSeconds: Double; var AExcitation: TRecorderSampleSeries;
  var AResponses: array of TRecorderSampleSeries; AExcitationCount: Integer;
  const AResponseCounts: array of Integer): TRecorderImpactCaptureBlock;
var
  I: Integer;
begin
  Result := TRecorderImpactCaptureBlock.CreateAdopted;
  Result.fToken := AToken;
  Result.fStartSeconds := AStartSeconds;
  Result.fEndSeconds := AEndSeconds;
  Result.fExcitation := AExcitation;
  AExcitation := nil;
  Result.fExcitationCount := AExcitationCount;
  SetLength(Result.fResponses, Length(AResponses));
  SetLength(Result.fResponseCounts, Length(AResponses));
  for I := 0 to High(AResponses) do
  begin
    Result.fResponses[I] := AResponses[I];
    AResponses[I] := nil;
    Result.fResponseCounts[I] := AResponseCounts[I];
  end;
end;

{ Создаёт пустую оболочку блока для последующей передачи ему буферов. }
constructor TRecorderImpactCaptureBlock.CreateAdopted;
begin
  inherited Create;
end;

{ Возвращает число рядов отклика в захвате. }
function TRecorderImpactCaptureBlock.ResponseCount: Integer;
begin
  Result := Length(fResponses);
end;

{ Возвращает копию фактически заполненной части ряда воздействия. }
function TRecorderImpactCaptureBlock.Excitation: TRecorderSampleSeries;
begin
  Result := Copy(fExcitation, 0, fExcitationCount);
end;

{ Возвращает копию заполненной части отклика AIndex; неверный индекс вызывает исключение. }
function TRecorderImpactCaptureBlock.Response(
  AIndex: Integer): TRecorderSampleSeries;
begin
  if (AIndex < 0) or (AIndex >= Length(fResponses)) then
    raise ERangeError.Create('Response index outside capture block');
  Result := Copy(fResponses[AIndex], 0, fResponseCounts[AIndex]);
end;

{ Проверяет покрытие обеих границ окна отсчётами без экстраполяции. }
class function TRecorderImpactCapture.Covers(
  const ASeries: TRecorderSampleSeries; ACount: Integer; AStartSeconds,
  AEndSeconds: Double): Boolean;
begin
  { Отсчёты должны охватывать обе границы, чтобы позже пересчитать канал на
    общую временную сетку без экстраполяции за пределы захвата. }
  Result := (ACount > 1) and
    (ASeries[0].TimeSeconds <= AStartSeconds) and
    (ASeries[ACount - 1].TimeSeconds >= AEndSeconds);
end;

{ Добавляет строго более поздний конечный отсчёт в фиксированную банку; при заполнении прореживает историю. }
class function TRecorderImpactCapture.Append(var ASeries: TRecorderSampleSeries;
  var ACount: Integer; ATimeSeconds, AValue: Double): Boolean;
var
  ReadIndex: Integer;
  WriteIndex: Integer;
begin
  Result := Finite(ATimeSeconds) and Finite(AValue) and
    (Length(ASeries) >= 2) and
    ((ACount = 0) or (ATimeSeconds > ASeries[ACount - 1].TimeSeconds));
  if not Result then
    Exit;
  if ACount = Length(ASeries) then
  begin
    { При заполнении банки оставляем первый и каждый второй старый отсчёт;
      новый дописываем в конец. Ёмкость не растёт и память в callback не выделяется. }
    WriteIndex := 1;
    ReadIndex := 2;
    while ReadIndex < ACount do
    begin
      ASeries[WriteIndex] := ASeries[ReadIndex];
      Inc(WriteIndex);
      Inc(ReadIndex, 2);
    end;
    ACount := WriteIndex;
  end;
  ASeries[ACount].TimeSeconds := ATimeSeconds;
  ASeries[ACount].Value := AValue;
  Inc(ACount);
end;

{ Заранее выделяет резервные банки, чтобы переключение захвата не выделяло память в callback. }
procedure TRecorderImpactCapture.PrepareSpareBuffers(AResponseCount,
  AExpectedSamples: Integer);
var
  I: Integer;
begin
  if Length(fSpareExcitation) <> AExpectedSamples then
  begin
    SetLength(fSpareExcitation, AExpectedSamples);
    Inc(GCaptureResizeCount);
  end;
  if Length(fSpareResponses) <> AResponseCount then
  begin
    SetLength(fSpareResponses, AResponseCount);
    Inc(GCaptureResizeCount);
  end;
  for I := 0 to AResponseCount - 1 do
    if Length(fSpareResponses[I]) <> AExpectedSamples then
    begin
      SetLength(fSpareResponses[I], AExpectedSamples);
      Inc(GCaptureResizeCount);
    end;
end;

{ Готовит рабочие и резервные банки для числа каналов и ожидаемой ёмкости. }
procedure TRecorderImpactCapture.PrepareBuffers(AResponseCount,
  AExpectedSamples: Integer);
var
  I: Integer;
begin
  if Length(fExcitation) <> AExpectedSamples then
  begin
    SetLength(fExcitation, AExpectedSamples);
    Inc(GCaptureResizeCount);
  end;
  if Length(fResponses) <> AResponseCount then
  begin
    SetLength(fResponses, AResponseCount);
    Inc(GCaptureResizeCount);
  end;
  if Length(fResponseCounts) <> AResponseCount then
    SetLength(fResponseCounts, AResponseCount);
  for I := 0 to AResponseCount - 1 do
    if Length(fResponses[I]) <> AExpectedSamples then
    begin
      SetLength(fResponses[I], AExpectedSamples);
      Inc(GCaptureResizeCount);
    end;
  PrepareSpareBuffers(AResponseCount, AExpectedSamples);
end;

{ Начинает захват с токеном и общими границами; требует заранее подготовленные банки. }
procedure TRecorderImpactCapture.BeginCapture(AToken: QWord;
  AStartSeconds, AEndSeconds: Double; AResponseCount,
  AExpectedSamples: Integer);
var
  I: Integer;
begin
  if (Length(fExcitation) <> AExpectedSamples) or
    (Length(fResponses) <> AResponseCount) or
    (Length(fResponseCounts) <> AResponseCount) then
    raise EInvalidOpException.Create('Capture buffers were not prepared');
  for I := 0 to AResponseCount - 1 do
    if Length(fResponses[I]) <> AExpectedSamples then
      raise EInvalidOpException.Create('Response buffers were not prepared');
  fToken := AToken;
  fStartSeconds := AStartSeconds;
  fEndSeconds := AEndSeconds;
  fExcitationCount := 0;
  for I := 0 to AResponseCount - 1 do
  begin
    fResponseCounts[I] := 0;
  end;
end;

{ Добавляет отсчёт канала воздействия с временной меткой. }
function TRecorderImpactCapture.AddExcitation(ATimeSeconds,
  AValue: Double): Boolean;
begin
  Result := Append(fExcitation, fExcitationCount, ATimeSeconds, AValue);
end;

{ Добавляет отсчёт отклика AIndex; возвращает False для неверного канала или отсчёта. }
function TRecorderImpactCapture.AddResponse(AIndex: Integer;
  ATimeSeconds, AValue: Double): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < Length(fResponses));
  if Result then
    Result := Append(fResponses[AIndex], fResponseCounts[AIndex],
      ATimeSeconds, AValue);
end;

{ Проверяет, что воздействие и каждый отклик покрывают всё общее окно. }
function TRecorderImpactCapture.IsReady: Boolean;
var
  lIndex: Integer;
begin
  Result := Covers(fExcitation, fExcitationCount, fStartSeconds, fEndSeconds);
  for lIndex := 0 to High(fResponses) do
    Result := Result and Covers(fResponses[lIndex], fResponseCounts[lIndex],
      fStartSeconds, fEndSeconds);
end;

{ Передаёт заполненные банки неизменяемому блоку и переключает захват на резервные. }
function TRecorderImpactCapture.Freeze: TRecorderImpactCaptureBlock;
begin
  if not IsReady then
    Exit(nil);
  Result := TRecorderImpactCaptureBlock.Adopt(fToken, fStartSeconds,
    fEndSeconds, fExcitation, fResponses, fExcitationCount, fResponseCounts);
  fExcitation := fSpareExcitation;
  fSpareExcitation := nil;
  fResponses := fSpareResponses;
  fSpareResponses := nil;
  fExcitationCount := 0;
  fToken := 0;
end;

{ Задаёт параметры триггера и сбрасывает текущий поиск удара. }
procedure TRecorderImpactTrigger.Configure(const ASettings: TRecorderImpactSettings);
begin
  fSettings := ASettings;
  Reset;
end;

{ Меняет порог и сбрасывает состояние поиска, чтобы не продолжать старый фронт. }
procedure TRecorderImpactTrigger.SetThreshold(AValue: Double);
begin
  fSettings.Threshold := AValue;
  Reset;
end;

{ Возвращает триггер к ожиданию пересечения порога. }
procedure TRecorderImpactTrigger.Reset;
begin
  fState := itsWaiting;
  fPeakTime := 0;
  fPeakValue := 0;
end;

{ Приводит сигнал к направлению, выбранному полярностью триггера. }
function TRecorderImpactTrigger.DirectedValue(AValue: Double): Double;
begin
  case fSettings.Polarity of
    ipPositive: Result := AValue;
    ipNegative: Result := -AValue;
  else
    Result := Abs(AValue);
  end;
end;

{ Ищет пересечение порога, удерживает экстремум и подтверждает удар спадом ниже порога с гистерезисом. }
function TRecorderImpactTrigger.ProcessSample(ATimeSeconds, AValue: Double;
  out AEvent: TRecorderImpactTriggerEvent): Boolean;
var
  lValue: Double;
begin
  AEvent := Default(TRecorderImpactTriggerEvent);
  Result := False;
  if not Finite(ATimeSeconds) or not Finite(AValue) then
    Exit;
  lValue := DirectedValue(AValue);
  { ATimeSeconds — время в общей шкале сбора, AValue — отсчёт молотка.
    После пересечения порога запоминаем максимум выбранной полярности; удар
    подтверждается на спаде до порога минус гистерезис. Окно привязано к пику,
    поэтому его начало включает заданное время до удара. }
  case fState of
    itsWaiting:
      if lValue >= fSettings.Threshold then
      begin
        fState := itsAboveThreshold;
        fPeakTime := ATimeSeconds;
        fPeakValue := AValue;
      end;
    itsAboveThreshold:
      begin
        if lValue > DirectedValue(fPeakValue) then
        begin
          fPeakTime := ATimeSeconds;
          fPeakValue := AValue;
        end;
        if lValue <= fSettings.Threshold - fSettings.Hysteresis then
        begin
          AEvent.Triggered := True;
          AEvent.PeakTimeSeconds := fPeakTime;
          AEvent.PeakValue := fPeakValue;
          AEvent.CaptureStartSeconds := fPeakTime - fSettings.PretriggerSeconds;
          AEvent.CaptureEndSeconds := AEvent.CaptureStartSeconds +
            fSettings.CaptureSeconds;
          Reset;
          Result := True;
        end;
      end;
  end;
end;

{ Создаёт кольцевой архив заданной ёмкости и очищает старые блоки. }
procedure TRecorderImpactSet.Configure(ACapacity: Integer);
begin
  Clear;
  fCapacity := ACapacity;
  SetLength(fItems, ACapacity);
  SetLength(fBlocks, ACapacity);
end;

{ Освобождает захваты и сбрасывает архив, начиная нумерацию с единицы. }
procedure TRecorderImpactSet.Clear;
var
  lIndex: Integer;
begin
  for lIndex := 0 to High(fBlocks) do
    FreeAndNil(fBlocks[lIndex]);
  fStart := 0;
  fCount := 0;
  fNextSequence := 1;
end;

{ Добавляет результат удара; при переполнении заменяет самый старый элемент. }
function TRecorderImpactSet.Add(APeakTimeSeconds, APeakValue: Double;
  AAccepted: Boolean; AReason: TRecorderImpactRejectReason;
  ABlock: TRecorderImpactCaptureBlock): QWord;
var
  lIndex: Integer;
begin
  Result := fNextSequence;
  Inc(fNextSequence);
  if fCapacity = 0 then
    Exit;
  if fCount < fCapacity then
  begin
    lIndex := (fStart + fCount) mod fCapacity;
    Inc(fCount);
  end
  else
  begin
    lIndex := fStart;
    FreeAndNil(fBlocks[lIndex]);
    fStart := (fStart + 1) mod fCapacity;
  end;
  fItems[lIndex].Sequence := Result;
  fItems[lIndex].PeakTimeSeconds := APeakTimeSeconds;
  fItems[lIndex].PeakValue := APeakValue;
  fItems[lIndex].Accepted := AAccepted;
  fItems[lIndex].RejectReason := AReason;
  fItems[lIndex].Hidden := False;
  fItems[lIndex].RecomputeRequired := False;
  fBlocks[lIndex] := ABlock;
end;

{ Возвращает блок захвата для позиции AIndex или nil при неверной позиции. }
function TRecorderImpactSet.Capture(AIndex: Integer): TRecorderImpactCaptureBlock;
begin
  if (AIndex < 0) or (AIndex >= fCount) then
    raise ERangeError.Create('Impact index outside accepted/rejected set');
  Result := fBlocks[(fStart + AIndex) mod fCapacity];
end;

{ Удаляет удар по устойчивому Sequence, сохраняя порядок оставшихся записей. }
function TRecorderImpactSet.Delete(ASequence: QWord): Boolean;
var
  lIndex, lMove, lPhysical, lNext: Integer;
begin
  Result := False;
  for lIndex := 0 to fCount - 1 do
    if Item(lIndex).Sequence = ASequence then
    begin
      lPhysical := (fStart + lIndex) mod fCapacity;
      FreeAndNil(fBlocks[lPhysical]);
      for lMove := lIndex to fCount - 2 do
      begin
        lPhysical := (fStart + lMove) mod fCapacity;
        lNext := (fStart + lMove + 1) mod fCapacity;
        fItems[lPhysical] := fItems[lNext];
        fBlocks[lPhysical] := fBlocks[lNext];
        fBlocks[lNext] := nil;
      end;
      Dec(fCount);
      Exit(True);
    end;
end;

{ Меняет признак скрытия удара, найденного по Sequence. }
function TRecorderImpactSet.SetHidden(ASequence: QWord;
  AHidden: Boolean): Boolean;
var
  lIndex, lPhysical: Integer;
begin
  Result := False;
  for lIndex := 0 to fCount - 1 do
  begin
    lPhysical := (fStart + lIndex) mod fCapacity;
    if fItems[lPhysical].Sequence = ASequence then
    begin
      fItems[lPhysical].Hidden := AHidden;
      Exit(True);
    end;
  end;
end;

{ Помечает удар по Sequence для повторного расчёта. }
function TRecorderImpactSet.MarkForRecompute(ASequence: QWord): Boolean;
var
  lIndex, lPhysical: Integer;
begin
  Result := False;
  for lIndex := 0 to fCount - 1 do
  begin
    lPhysical := (fStart + lIndex) mod fCapacity;
    if fItems[lPhysical].Sequence = ASequence then
    begin
      fItems[lPhysical].RecomputeRequired := True;
      Exit(True);
    end;
  end;
end;

{ Возвращает запись по позиции в кольцевом архиве. }
function TRecorderImpactSet.Item(AIndex: Integer): TRecorderImpactRecord;
begin
  if (AIndex < 0) or (AIndex >= fCount) then
    raise ERangeError.Create('Impact index outside accepted/rejected set');
  Result := fItems[(fStart + AIndex) mod fCapacity];
end;

{ Освобождает все сохранённые блоки захвата. }
destructor TRecorderImpactSet.Destroy;
begin
  Clear;
  inherited Destroy;
end;

{ Объединяет спектральные моменты ударов и вычисляет H0/H1/H2, фазу и когерентность. }
function TRecorderCrossSpectrumEstimator.Estimate(
  const ASpectra: array of TRecorderImpactSpectrum;
  AKind: TRecorderFrfEstimatorKind; out AResult: TRecorderFrfEstimate): Boolean;
var
  lBin, lImpact, lBins: Integer;
  lSxx, lSyy, lDenominator, lMagnitude, lExcitationPower: Double;
  lSxy, lTerm, lTransfer: TComplex_d;
  lResult: TRecorderFrfEstimate;
begin
  lResult := Default(TRecorderFrfEstimate);
  Result := False;
  if Length(ASpectra) = 0 then
    Exit;
  lBins := Length(ASpectra[0].FrequencyHz);
  if (lBins = 0) or (Length(ASpectra[0].Excitation) <> lBins) or
    (Length(ASpectra[0].Response) <> lBins) then
    Exit;
  for lImpact := 1 to High(ASpectra) do
    if (Length(ASpectra[lImpact].FrequencyHz) <> lBins) or
      (Length(ASpectra[lImpact].Excitation) <> lBins) or
      (Length(ASpectra[lImpact].Response) <> lBins) then
      Exit;
  for lImpact := 0 to High(ASpectra) do
    for lBin := 0 to lBins - 1 do
      if not Finite(ASpectra[lImpact].FrequencyHz[lBin]) or
        not Finite(ASpectra[lImpact].Excitation[lBin].Re) or
        not Finite(ASpectra[lImpact].Excitation[lBin].Im) or
        not Finite(ASpectra[lImpact].Response[lBin].Re) or
        not Finite(ASpectra[lImpact].Response[lBin].Im) or
        ((lBin > 0) and
         (ASpectra[lImpact].FrequencyHz[lBin] <=
          ASpectra[lImpact].FrequencyHz[lBin - 1])) or
        (Abs(ASpectra[lImpact].FrequencyHz[lBin] -
          ASpectra[0].FrequencyHz[lBin]) >
          1E-10 * Max(1.0, Abs(ASpectra[0].FrequencyHz[lBin]))) then
        Exit;
  SetLength(lResult.FrequencyHz, lBins);
  SetLength(lResult.Magnitude, lBins);
  SetLength(lResult.PhaseRadians, lBins);
  SetLength(lResult.Coherence, lBins);
  for lBin := 0 to lBins - 1 do
  begin
    lSxx := 0;
    lSyy := 0;
    lSxy.Re := 0;
    lSxy.Im := 0;
    lTransfer.Re := 0;
    lTransfer.Im := 0;
    lMagnitude := 0;
    for lImpact := 0 to High(ASpectra) do
    begin
      lSxx := lSxx + ComplexMagnitudeSquared(ASpectra[lImpact].Excitation[lBin]);
      lSyy := lSyy + ComplexMagnitudeSquared(ASpectra[lImpact].Response[lBin]);
      lTerm := MultiplyConjugate(ASpectra[lImpact].Response[lBin],
        ASpectra[lImpact].Excitation[lBin]);
      lSxy.Re := lSxy.Re + lTerm.Re;
      lSxy.Im := lSxy.Im + lTerm.Im;
      lExcitationPower := ComplexMagnitudeSquared(
        ASpectra[lImpact].Excitation[lBin]);
      if lExcitationPower <= 1E-24 * Max(1.0,
        ComplexMagnitudeSquared(ASpectra[lImpact].Response[lBin])) then
        Exit;
      lMagnitude := lMagnitude +
        Sqrt(ComplexMagnitudeSquared(ASpectra[lImpact].Response[lBin]) /
          lExcitationPower);
    end;
    case AKind of
      fekH0:
        begin
          lMagnitude := lMagnitude / Length(ASpectra);
          if ComplexMagnitudeSquared(lSxy) <= 1E-24 * Max(1.0, lSxx * lSyy) then
            Exit;
          lTransfer := lSxy;
        end;
      fekH1:
        begin
          if lSxx <= 1E-24 * Max(1.0, lSyy) then
            Exit;
          lTransfer := lSxy / lSxx;
          lMagnitude := Sqrt(ComplexMagnitudeSquared(lTransfer));
        end;
      fekH2:
        begin
          lDenominator := ComplexMagnitudeSquared(lSxy);
          if lDenominator <= 1E-24 * Max(1.0, lSxx * lSyy) then
            Exit;
          lTransfer := (lSyy * lSxy) / lDenominator;
          lMagnitude := Sqrt(ComplexMagnitudeSquared(lTransfer));
        end;
    end;
    lResult.FrequencyHz[lBin] := ASpectra[0].FrequencyHz[lBin];
    lResult.Magnitude[lBin] := lMagnitude;
    lResult.PhaseRadians[lBin] := ArcTan2(lTransfer.Im, lTransfer.Re);
    if (lSxx > 0) and (lSyy > 0) then
      lResult.Coherence[lBin] := EnsureRange(
        ComplexMagnitudeSquared(lSxy) / (lSxx * lSyy), 0.0, 1.0)
    else
      lResult.Coherence[lBin] := 0;
  end;
  AResult := lResult;
  Result := True;
end;

{ Создаёт триггер, архив ударов и публикацию FRF. }
constructor TRecorderImpactRuntime.Create;
begin
  inherited Create;
  fTrigger := TRecorderImpactTrigger.Create;
  fImpacts := TRecorderImpactSet.Create;
  fCapture := TRecorderImpactCapture.Create;
  fRepository := TRecorderFrfRepository.Create;
  fProvider := fRepository;
  fState := isIdle;
end;

{ Освобождает объекты времени выполнения и интерфейс публикации. }
destructor TRecorderImpactRuntime.Destroy;
begin
  fProvider := nil;
  fRepository := nil;
  fCapture.Free;
  fImpacts.Free;
  fTrigger.Free;
  inherited Destroy;
end;

{ Проверяет диапазоны параметров до перенастройки рабочего состояния. }
class function TRecorderImpactRuntime.ValidateSettings(
  const ASettings: TRecorderImpactSettings; out AError: string): Boolean;
begin
  AError := '';
  if not Finite(ASettings.SampleRateHz) or (ASettings.SampleRateHz <= 0) then
    AError := 'Sample rate must be finite and positive'
  else if not Finite(ASettings.Threshold) or (ASettings.Threshold <= 0) then
    AError := 'Threshold must be finite and positive'
  else if not Finite(ASettings.Hysteresis) or (ASettings.Hysteresis < 0) or
    (ASettings.Hysteresis >= ASettings.Threshold) then
    AError := 'Hysteresis must be non-negative and below threshold'
  else if not Finite(ASettings.PretriggerSeconds) or
    (ASettings.PretriggerSeconds < 0) then
    AError := 'Pretrigger must be finite and non-negative'
  else if not Finite(ASettings.CaptureSeconds) or
    (ASettings.CaptureSeconds <= ASettings.PretriggerSeconds) then
    AError := 'Capture duration must exceed pretrigger'
  else if ASettings.Capacity <= 0 then
    AError := 'Impact capacity must be positive'
  else if ASettings.ResponseCount <= 0 then
    AError := 'At least one response channel is required';
  Result := AError = '';
end;

{ Проверяет настройки и пересоздаёт рабочие ресурсы по числу откликов и ёмкости. }
function TRecorderImpactRuntime.Configure(
  const ASettings: TRecorderImpactSettings; out AError: string): Boolean;
begin
  if not (fState in [isIdle, isStopped]) then
  begin
    AError := 'Stop impact acquisition before changing its configuration';
    Exit(False);
  end;
  Result := ValidateSettings(ASettings, AError);
  if not Result then
    Exit;
  fSettings := ASettings;
  fTrigger.Configure(ASettings);
  fImpacts.Configure(ASettings.Capacity);
  fCapture.PrepareBuffers(ASettings.ResponseCount,
    Ceil(ASettings.CaptureSeconds * ASettings.SampleRateHz) + 2);
  fPendingEvent := Default(TRecorderImpactTriggerEvent);
  fNextCaptureToken := 0;
  fState := isStopped;
end;

{ Обновляет порог триггера во время сбора. }
procedure TRecorderImpactRuntime.SetThreshold(AValue: Double);
begin
  fSettings.Threshold := AValue;
  fTrigger.SetThreshold(AValue);
end;

{ Переводит runtime в состояние сбора, если настройки действительны. }
function TRecorderImpactRuntime.Arm: Boolean;
begin
  Result := fState = isStopped;
  if Result then
  begin
    fTrigger.Reset;
    fState := isArmed;
  end;
end;

{ Останавливает триггер и незавершённый захват. }
procedure TRecorderImpactRuntime.Stop;
begin
  if fState <> isIdle then
  begin
    fPendingEvent := Default(TRecorderImpactTriggerEvent);
    fState := isStopped;
  end;
end;

{ Задаёт ручное окно [ATimeSeconds, ATimeSeconds + CaptureSeconds) без поиска
  триггера и присваивает ему токен захвата. }
function TRecorderImpactRuntime.BeginPortion(ATimeSeconds: Double;
  out AEvent: TRecorderImpactTriggerEvent): Boolean;
begin
  AEvent := Default(TRecorderImpactTriggerEvent);
  Result := (fState = isArmed) and Finite(ATimeSeconds);
  if not Result then Exit;
  Inc(fNextCaptureToken);
  AEvent.Triggered := True;
  AEvent.PeakTimeSeconds := ATimeSeconds;
  AEvent.CaptureStartSeconds := ATimeSeconds;
  AEvent.CaptureEndSeconds := ATimeSeconds + fSettings.CaptureSeconds;
  AEvent.CaptureToken := fNextCaptureToken;
  fPendingEvent := AEvent;
  fCapture.BeginCapture(AEvent.CaptureToken, AEvent.CaptureStartSeconds,
    AEvent.CaptureEndSeconds, fSettings.ResponseCount,
    Ceil(fSettings.CaptureSeconds * fSettings.SampleRateHz) + 2);
  fState := isCapturing;
end;

{ Передаёт отсчёт молотка триггеру и открывает окно захвата при подтверждении удара. }
function TRecorderImpactRuntime.ProcessTriggerSample(ATimeSeconds,
  AValue: Double; out AEvent: TRecorderImpactTriggerEvent): Boolean;
begin
  AEvent := Default(TRecorderImpactTriggerEvent);
  Result := False;
  if fState <> isArmed then
    Exit;
  Result := fTrigger.ProcessSample(ATimeSeconds, AValue, AEvent);
  if Result then
  begin
    Inc(fNextCaptureToken);
    AEvent.CaptureToken := fNextCaptureToken;
    fPendingEvent := AEvent;
    fCapture.BeginCapture(AEvent.CaptureToken, AEvent.CaptureStartSeconds,
      AEvent.CaptureEndSeconds, fSettings.ResponseCount,
      Ceil(fSettings.CaptureSeconds * fSettings.SampleRateHz) + 2);
    fState := isCapturing;
  end;
end;

{ Добавляет отсчёт воздействия только для активного токена захвата. }
function TRecorderImpactRuntime.AddExcitationSample(AToken: QWord;
  ATimeSeconds, AValue: Double): Boolean;
begin
  Result := (fState = isCapturing) and
    (AToken = fPendingEvent.CaptureToken) and
    fCapture.AddExcitation(ATimeSeconds, AValue);
end;

{ Добавляет отсчёт отклика AResponseIndex только для активного токена. }
function TRecorderImpactRuntime.AddResponseSample(AToken: QWord;
  AResponseIndex: Integer; ATimeSeconds, AValue: Double): Boolean;
begin
  Result := (fState = isCapturing) and
    (AToken = fPendingEvent.CaptureToken) and
    fCapture.AddResponse(AResponseIndex, ATimeSeconds, AValue);
end;

  { Принимает только текущий AToken и ждёт, пока воздействие и каждый отклик
    покроют обе границы окна без экстраполяции. }
function TRecorderImpactRuntime.CaptureReady(AToken: QWord): Boolean;
begin
  Result := (fState = isCapturing) and
    (AToken = fPendingEvent.CaptureToken) and fCapture.IsReady;
end;

{ Фиксирует принятый или отклонённый удар и связывает его с готовым блоком. }
function TRecorderImpactRuntime.RecordImpact(AToken: QWord;
  AAccepted: Boolean;
  AReason: TRecorderImpactRejectReason): QWord;
var
  lBlock: TRecorderImpactCaptureBlock;
begin
  Result := 0;
  if (fState <> isCapturing) or (AToken <> fPendingEvent.CaptureToken) or
    not fPendingEvent.Triggered or not fCapture.IsReady then
    Exit;
  if AAccepted then
    AReason := irrNone
  else if AReason = irrNone then
    AReason := irrManual;
  lBlock := fCapture.Freeze;
  Result := fImpacts.Add(fPendingEvent.PeakTimeSeconds,
    fPendingEvent.PeakValue, AAccepted, AReason, lBlock);
  fPendingEvent := Default(TRecorderImpactTriggerEvent);
  fState := isArmed;
end;

{ Выделяет резервные банки следующего захвата вне пути обработки отсчётов. }
procedure TRecorderImpactRuntime.PrepareCaptureSpareBuffers;
begin
  fCapture.PrepareSpareBuffers(fSettings.ResponseCount,
    Ceil(fSettings.CaptureSeconds * fSettings.SampleRateHz) + 2);
end;

{ Публикует одну оценку FRF под идентификатором ACurveId. }
function TRecorderImpactRuntime.Publish(ACurveId: QWord;
  const AEstimate: TRecorderFrfEstimate): Boolean;
var
  lCurve: TRecorderFrfCurveData;
begin
  lCurve.Id := ACurveId;
  lCurve.FrequencyHz := AEstimate.FrequencyHz;
  lCurve.Magnitude := AEstimate.Magnitude;
  lCurve.PhaseRadians := AEstimate.PhaseRadians;
  lCurve.Coherence := AEstimate.Coherence;
  Result := fRepository.Publish([lCurve]);
end;

{ Атомарно публикует набор кривых FRF. }
function TRecorderImpactRuntime.PublishCurves(
  const ACurves: array of TRecorderFrfCurveData): Boolean;
begin
  Result := fRepository.Publish(ACurves);
end;

{ Удаляет опубликованные кривые из runtime-провайдера. }
procedure TRecorderImpactRuntime.ClearPublished;
begin
  fRepository.Clear;
end;

end.
