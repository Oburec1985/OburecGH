unit uAccuracyStepSin;

interface
uses
  Classes, SysUtils, Math,
  uDacDevice, uDacProgram, uSoundCardDac;
type
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
    procedure DoPrepareAfterSubscribeBeforeDeviceStart; override;
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

procedure TAccurateSinusProgram.DoPrepareAfterSubscribeBeforeDeviceStart;
begin
  RefreshAlignedBuffers;
end;

procedure TAccurateSinusProgram.ProcessBuffer(P: Pointer; Size: Integer);
var
  i: Integer;
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
  // Шаг фазы задаём по целому числу сэмплов на период,
  // чтобы в конце буфера не было дрейфа по фазе.
  lStep := (2 * Pi) / fPeriodSamples;

  for i := 0 to fDevice.BufferSize - 1 do
  begin
    lSamples^ := Round(fAmplitude * Sin(fCurrentPhase) * 32767);
    Inc(lSamples);
    fCurrentPhase := fCurrentPhase + lStep;
    if fCurrentPhase > (2 * Pi) then
      fCurrentPhase := NormalizePhase(fCurrentPhase);
  end;
end;

end.
