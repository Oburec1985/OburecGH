unit uRecorderFrfRepository;

{ Репозиторий неизменяемых FRF-снимков и точка их потокобезопасной публикации.
  Расчёт собирает новый снимок целиком; потребитель не видит частичный набор
  кривых и удерживает версию на всё время чтения. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Math, uRecorderFrfContracts;

type
  TRecorderFrfCurveData = record
    Id: QWord;
    FrequencyHz: array of Double;
    Magnitude: array of Double;
    PhaseRadians: array of Double;
    Coherence: array of Double;
    Amplitude: array of Double;
  end;

  TRecorderFrfRepository = class(TInterfacedObject, IRecorderFrfProvider)
  private
    fLock: TRTLCriticalSection;
    fPublishLock: TRTLCriticalSection;
    fSnapshot: IRecorderFrfSampler;
    fVersion: QWord;
  public
    constructor Create;
    destructor Destroy; override;
    function Publish(const ACurves: array of TRecorderFrfCurveData): Boolean;
    procedure Clear;
    function AcquireSnapshot: IRecorderFrfSampler;
  end;

implementation

type
  TRecorderFrfSnapshot = class(TInterfacedObject, IRecorderFrfSampler,
    IRecorderAmplitudeSampler, IRecorderFrfBandSampler, IRecorderFrfRangeScale)
  private
    fVersion: QWord;
    fCurves: array of TRecorderFrfCurveData;
    { Ищет индекс кривой по AId; возвращает -1, если ID отсутствует. }
    function FindCurve(AId: QWord): Integer;
  public
    { Инициализирует кодек и открывает каталог ADirectory для чтения или записи MERA. }
    constructor Create(AVersion: QWord;
      const ACurves: array of TRecorderFrfCurveData);
    { Двоичным поиском находит частотные бины и интерполирует модуль и кратчайшую разность фаз. }
    function TrySample(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    { Возвращает номер версии снимка. }
    function Version: QWord;
    { Находит максимум диапазона или полосовой RSS; ATolerancePercent задаёт ширину полосы. }
    function TryGetRangeMaximum(ACurveId: QWord; AMinHz, AMaxHz: Double;
      AAmplitude, ABand: Boolean; ATolerancePercent: Double;
      out AMaximum: Double): Boolean;
    { Интерполирует сохранённую амплитуду на заданной частоте. }
    function TrySampleAmplitude(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    { Считает RSS бинов около ACenterHz в пределах ATolerancePercent. }
    function TrySampleBand(ACurveId: QWord; ACenterHz,
      ATolerancePercent: Double; AAmplitude: Boolean;
      out AMagnitude, APhaseRadians: Double): Boolean;
  end;

{ Проверяет, что число конечно. }
function Finite(AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue);
end;

{ Проверяет ID, размерность, конечность и порядок данных FRF-кривой. }
function ValidCurve(const ACurve: TRecorderFrfCurveData): Boolean;
var
  lIndex, lCount: Integer;
begin
  lCount := Length(ACurve.FrequencyHz);
  Result := (ACurve.Id <> 0) and (lCount > 0) and
    (Length(ACurve.Magnitude) = lCount) and
    (Length(ACurve.PhaseRadians) = lCount) and
    (Length(ACurve.Coherence) = lCount);
  if not Result then
    Exit;
  for lIndex := 0 to lCount - 1 do
  begin
    Result := Finite(ACurve.FrequencyHz[lIndex]) and
      Finite(ACurve.Magnitude[lIndex]) and
      Finite(ACurve.PhaseRadians[lIndex]) and
      Finite(ACurve.Coherence[lIndex]) and
      (ACurve.Magnitude[lIndex] >= 0) and
      (ACurve.Coherence[lIndex] >= 0) and
      (ACurve.Coherence[lIndex] <= 1) and
      ((lIndex = 0) or
       (ACurve.FrequencyHz[lIndex] > ACurve.FrequencyHz[lIndex - 1]));
    if not Result then
      Exit;
  end;
end;

{ Инициализирует кодек и открывает каталог ADirectory для чтения или записи MERA. }
constructor TRecorderFrfSnapshot.Create(AVersion: QWord;
  const ACurves: array of TRecorderFrfCurveData);
var
  lCurve: Integer;
begin
  inherited Create;
  fVersion := AVersion;
  SetLength(fCurves, Length(ACurves));
  for lCurve := 0 to High(ACurves) do
  begin
    fCurves[lCurve].Id := ACurves[lCurve].Id;
    fCurves[lCurve].FrequencyHz := Copy(ACurves[lCurve].FrequencyHz);
    fCurves[lCurve].Magnitude := Copy(ACurves[lCurve].Magnitude);
    fCurves[lCurve].PhaseRadians := Copy(ACurves[lCurve].PhaseRadians);
    fCurves[lCurve].Coherence := Copy(ACurves[lCurve].Coherence);
    fCurves[lCurve].Amplitude := Copy(ACurves[lCurve].Amplitude);
  end;
end;

{ Ищет индекс кривой по AId; возвращает -1, если ID отсутствует. }
function TRecorderFrfSnapshot.FindCurve(AId: QWord): Integer;
begin
  for Result := 0 to High(fCurves) do
    if fCurves[Result].Id = AId then
      Exit;
  Result := -1;
end;

{ Двоичным поиском находит частотные бины и интерполирует модуль и кратчайшую разность фаз. }
function TRecorderFrfSnapshot.TrySample(ACurveId: QWord;
  AFrequencyHz: Double; out AMagnitude, APhaseRadians: Double): Boolean;
var
  lCurve, lLow, lHigh, lMiddle: Integer;
  lRatio, lPhaseDelta: Double;
begin
  Result := False;
  lCurve := FindCurve(ACurveId);
  if (lCurve < 0) or not Finite(AFrequencyHz) then
    Exit;
  lLow := 0;
  lHigh := High(fCurves[lCurve].FrequencyHz);
  if (AFrequencyHz < fCurves[lCurve].FrequencyHz[lLow]) or
    (AFrequencyHz > fCurves[lCurve].FrequencyHz[lHigh]) then
    Exit;
  while lLow < lHigh do
  begin
    lMiddle := (lLow + lHigh) div 2;
    if fCurves[lCurve].FrequencyHz[lMiddle] < AFrequencyHz then
      lLow := lMiddle + 1
    else
      lHigh := lMiddle;
  end;
  if fCurves[lCurve].FrequencyHz[lLow] = AFrequencyHz then
  begin
    AMagnitude := fCurves[lCurve].Magnitude[lLow];
    APhaseRadians := fCurves[lCurve].PhaseRadians[lLow];
    Exit(True);
  end;
  lHigh := lLow;
  Dec(lLow);
  lRatio := (AFrequencyHz - fCurves[lCurve].FrequencyHz[lLow]) /
    (fCurves[lCurve].FrequencyHz[lHigh] -
     fCurves[lCurve].FrequencyHz[lLow]);
  AMagnitude := fCurves[lCurve].Magnitude[lLow] + lRatio *
    (fCurves[lCurve].Magnitude[lHigh] - fCurves[lCurve].Magnitude[lLow]);
  lPhaseDelta := ArcTan2(
    Sin(fCurves[lCurve].PhaseRadians[lHigh] -
      fCurves[lCurve].PhaseRadians[lLow]),
    Cos(fCurves[lCurve].PhaseRadians[lHigh] -
      fCurves[lCurve].PhaseRadians[lLow]));
  APhaseRadians := fCurves[lCurve].PhaseRadians[lLow] +
    lRatio * lPhaseDelta;
  Result := True;
end;

{ Возвращает номер версии снимка. }
function TRecorderFrfSnapshot.Version: QWord;
begin
  Result := fVersion;
end;

{ Находит максимум диапазона или полосовой RSS; ATolerancePercent задаёт ширину полосы. }
function TRecorderFrfSnapshot.TryGetRangeMaximum(ACurveId: QWord;
  AMinHz, AMaxHz: Double; AAmplitude, ABand: Boolean;
  ATolerancePercent: Double; out AMaximum: Double): Boolean;
var
  lCurve, lIndex, lLeft, lRight: Integer;
  lPhase, lValue, lScale, lSquares, lBestSquares: Double;
  lLowFactor, lHighFactor, lCenter: Double;

  { Выбирает значение бина: амплитуда или модуль FRF. }
  function BinValue(AIndex: Integer): Double;
  begin
    if AAmplitude then Result:=fCurves[lCurve].Amplitude[AIndex]
    else Result:=fCurves[lCurve].Magnitude[AIndex];
  end;

  { Сдвигает границы полосы и обновляет масштабированную сумму квадратов. }
  procedure IncludeCenter(ACenter: Double);
  begin
    while (lRight<Length(fCurves[lCurve].FrequencyHz)) and
      (fCurves[lCurve].FrequencyHz[lRight]/lHighFactor<=ACenter) do
    begin
      lSquares:=lSquares+Sqr(BinValue(lRight)/lScale);
      Inc(lRight);
    end;
    while (lLeft<lRight) and
      (fCurves[lCurve].FrequencyHz[lLeft]<ACenter*lLowFactor) do
    begin
      lSquares:=lSquares-Sqr(BinValue(lLeft)/lScale);
      Inc(lLeft);
    end;
    lBestSquares:=Max(lBestSquares,lSquares);
  end;

begin
  Result:=False;
  AMaximum:=0;
  lCurve:=FindCurve(ACurveId);
  if (lCurve<0) or not Finite(AMinHz) or not Finite(AMaxHz) or
    (AMinHz<0) or (AMaxHz<AMinHz) or not Finite(ATolerancePercent) or
    (ATolerancePercent<0) then Exit;
  if AAmplitude and (Length(fCurves[lCurve].Amplitude)<>
    Length(fCurves[lCurve].FrequencyHz)) then Exit;
  AMinHz:=Max(AMinHz,fCurves[lCurve].FrequencyHz[0]);
  AMaxHz:=Min(AMaxHz,fCurves[lCurve].FrequencyHz[High(fCurves[lCurve].FrequencyHz)]);
  if AMaxHz<AMinHz then Exit;
  if not ABand then
  begin
    if AAmplitude then
      Result:=TrySampleAmplitude(ACurveId,AMinHz,AMaximum,lPhase)
    else Result:=TrySample(ACurveId,AMinHz,AMaximum,lPhase);
    if not Result then Exit;
    if AAmplitude then TrySampleAmplitude(ACurveId,AMaxHz,lValue,lPhase)
    else TrySample(ACurveId,AMaxHz,lValue,lPhase);
    AMaximum:=Max(AMaximum,lValue);
    for lIndex:=0 to High(fCurves[lCurve].FrequencyHz) do
      if (fCurves[lCurve].FrequencyHz[lIndex]>=AMinHz) and
        (fCurves[lCurve].FrequencyHz[lIndex]<=AMaxHz) then
        AMaximum:=Max(AMaximum,BinValue(lIndex));
    Exit(Finite(AMaximum));
  end;
  lLowFactor:=1-ATolerancePercent/100;
  lHighFactor:=1+ATolerancePercent/100;
  if not Finite(AMaxHz*lHighFactor) then Exit;
  lScale:=0;
  for lIndex:=0 to High(fCurves[lCurve].FrequencyHz) do
    if (fCurves[lCurve].FrequencyHz[lIndex]>=AMinHz*lLowFactor) and
      (fCurves[lCurve].FrequencyHz[lIndex]<=AMaxHz*lHighFactor) then
    begin
      lValue:=BinValue(lIndex);
      if not Finite(lValue) or (lValue<0) then Exit;
      lScale:=Max(lScale,lValue);
    end;
  if lScale=0 then Exit(True);
  lLeft:=0;
  while (lLeft<Length(fCurves[lCurve].FrequencyHz)) and
    (fCurves[lCurve].FrequencyHz[lLeft]<AMinHz*lLowFactor) do Inc(lLeft);
  lRight:=lLeft;
  lSquares:=0; lBestSquares:=0;
  { Сумма квадратов растёт только при включении следующего бина верхней границей.
    Упорядоченный проход по событиям и границам точен и выполняется за O(n).
    Перед возведением в квадрат значения масштабируются, чтобы не переполнить сумму. }
  IncludeCenter(AMinHz);
  for lIndex:=0 to High(fCurves[lCurve].FrequencyHz) do
  begin
    lCenter:=fCurves[lCurve].FrequencyHz[lIndex]/lHighFactor;
    if (lCenter>AMinHz) and (lCenter<AMaxHz) then IncludeCenter(lCenter);
  end;
  IncludeCenter(AMaxHz);
  AMaximum:=lScale*Sqrt(Max(0,lBestSquares));
  Result:=Finite(AMaximum);
end;

{ Считает RSS бинов около ACenterHz в пределах ATolerancePercent. }
function TRecorderFrfSnapshot.TrySampleBand(ACurveId: QWord;
  ACenterHz, ATolerancePercent: Double; AAmplitude: Boolean;
  out AMagnitude, APhaseRadians: Double): Boolean;
var
  lCurve, lLow, lHigh, lMiddle, lCount: Integer;
  lMinHz, lMaxHz, lValue, lScale, lSquares, lCenterMagnitude: Double;
begin
  Result := False;
  if not Finite(ACenterHz) or not Finite(ATolerancePercent) or
    (ACenterHz < 0) or (ATolerancePercent < 0) then Exit;
  if not TrySample(ACurveId, ACenterHz, lCenterMagnitude, APhaseRadians) then Exit;
  lCurve := FindCurve(ACurveId);
  if AAmplitude and (Length(fCurves[lCurve].Amplitude) <>
    Length(fCurves[lCurve].FrequencyHz)) then Exit;
  lMinHz := ACenterHz * (1 - ATolerancePercent / 100);
  lMaxHz := ACenterHz * (1 + ATolerancePercent / 100);
  if not Finite(lMinHz) or not Finite(lMaxHz) then Exit;
  lLow := 0;
  lHigh := Length(fCurves[lCurve].FrequencyHz);
  while lLow < lHigh do
  begin
    lMiddle := (lLow + lHigh) div 2;
    if fCurves[lCurve].FrequencyHz[lMiddle] < lMinHz then
      lLow := lMiddle + 1
    else lHigh := lMiddle;
  end;
  lScale := 0;
  lSquares := 0;
  lCount := 0;
  while (lLow < Length(fCurves[lCurve].FrequencyHz)) and
    (fCurves[lCurve].FrequencyHz[lLow] <= lMaxHz) do
  begin
    if AAmplitude then lValue := fCurves[lCurve].Amplitude[lLow]
    else lValue := fCurves[lCurve].Magnitude[lLow];
    if not Finite(lValue) or (lValue < 0) then Exit;
    { Масштабированное суммирование не даёт переполнить сумму больших бинов. }
    if lValue > lScale then
    begin
      lSquares := 1 + lSquares * Sqr(lScale / lValue);
      lScale := lValue;
    end
    else if lScale > 0 then lSquares := lSquares + Sqr(lValue / lScale);
    Inc(lCount);
    Inc(lLow);
  end;
  if lCount = 0 then Exit;
  AMagnitude := lScale * Sqrt(lSquares);
  Result := Finite(AMagnitude);
end;

{ Интерполирует сохранённую амплитуду на заданной частоте. }
function TRecorderFrfSnapshot.TrySampleAmplitude(ACurveId: QWord;
  AFrequencyHz: Double; out AMagnitude, APhaseRadians: Double): Boolean;
var
  Curve, Lo, Hi, Mid: Integer;
  Ratio: Double;
begin
  Result := TrySample(ACurveId, AFrequencyHz, AMagnitude, APhaseRadians);
  if not Result then Exit;
  Curve := FindCurve(ACurveId);
  Result := Length(fCurves[Curve].Amplitude) = Length(fCurves[Curve].FrequencyHz);
  if not Result then Exit;
  Lo := 0;
  Hi := High(fCurves[Curve].FrequencyHz);
  while Lo < Hi do
  begin
    Mid := (Lo + Hi) div 2;
    if fCurves[Curve].FrequencyHz[Mid] < AFrequencyHz then Lo := Mid + 1
    else Hi := Mid;
  end;
  AMagnitude := fCurves[Curve].Amplitude[Lo];
  if fCurves[Curve].FrequencyHz[Lo] <> AFrequencyHz then
  begin
    Hi := Lo;
    Dec(Lo);
    Ratio := (AFrequencyHz - fCurves[Curve].FrequencyHz[Lo]) /
      (fCurves[Curve].FrequencyHz[Hi] - fCurves[Curve].FrequencyHz[Lo]);
    AMagnitude := fCurves[Curve].Amplitude[Lo] + Ratio *
      (fCurves[Curve].Amplitude[Hi] - fCurves[Curve].Amplitude[Lo]);
  end;
end;

{ Инициализирует кодек и открывает каталог ADirectory для чтения или записи MERA. }
constructor TRecorderFrfRepository.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  InitCriticalSection(fPublishLock);
end;

{ Освобождает ресурсы кодека и закрывает открытый каталог. }
destructor TRecorderFrfRepository.Destroy;
begin
  fSnapshot := nil;
  DoneCriticalSection(fPublishLock);
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

{ Проверяет кривые, создаёт неизменяемый снимок и атомарно публикует новую версию. }
function TRecorderFrfRepository.Publish(
  const ACurves: array of TRecorderFrfCurveData): Boolean;
var
  lCurve, lOther: Integer;
  lCandidate: IRecorderFrfSampler;
  lVersion: QWord;
begin
  Result := Length(ACurves) > 0;
  for lCurve := 0 to High(ACurves) do
  begin
    Result := Result and ValidCurve(ACurves[lCurve]);
    for lOther := 0 to lCurve - 1 do
      Result := Result and (ACurves[lOther].Id <> ACurves[lCurve].Id);
  end;
  if not Result then
    Exit;
  { Новый снимок строится и проверяется до блокировки публикации. Читатели ждут
    только атомарной смены ссылки и версии, а не копирования всех кривых и бинов. }
  EnterCriticalSection(fPublishLock);
  try
    lVersion := fVersion + 1;
    lCandidate := TRecorderFrfSnapshot.Create(lVersion, ACurves);
    EnterCriticalSection(fLock);
    try
      fVersion := lVersion;
      fSnapshot := lCandidate;
    finally
      LeaveCriticalSection(fLock);
    end;
  finally
    LeaveCriticalSection(fPublishLock);
  end;
  NotifyRecorderFrfProviderChanged(Self as IRecorderFrfProvider);
  Result := True;
end;

{ Возвращает ссылку на текущий снимок, удерживающую опубликованную версию. }
function TRecorderFrfRepository.AcquireSnapshot: IRecorderFrfSampler;
begin
  EnterCriticalSection(fLock);
  try
    Result := fSnapshot;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ Удаляет опубликованный снимок, увеличивает версию и уведомляет подписчиков. }
procedure TRecorderFrfRepository.Clear;
begin
  EnterCriticalSection(fPublishLock);
  try
    EnterCriticalSection(fLock);
    try
      Inc(fVersion);
      fSnapshot := nil;
    finally
      LeaveCriticalSection(fLock);
    end;
  finally
    LeaveCriticalSection(fPublishLock);
  end;
  NotifyRecorderFrfProviderChanged(Self as IRecorderFrfProvider);
end;

end.
