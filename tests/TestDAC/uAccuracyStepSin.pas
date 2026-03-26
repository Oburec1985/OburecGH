unit uAccuracyStepSin;

interface
uses
  Classes, SysUtils, Math,
  uDacDevice, uDacProgram, uSoundCardDac;
type
  { ????????? ? ?????????? ???????? }
  TAccurateSinusProgram = class(TSimpleSinusProgram)
  private
    fPeriodSamples: Integer;
    fUseAlignedPeriod: Boolean;
    fMaxAlignedSamples: Integer; // ¦Þ¦¦TÀ¦-¦-¦¬TÇ¦¦¦-¦¬¦¦ ¦-¦- TÁ¦¬¦¬TÈ¦¦¦-¦- ¦+¦¬¦¬¦-¦-TË¦¦ ¦-TËTÀ¦-¦-¦-¦¦¦-¦-TË¦¦ ¦-TÃTÄ¦¦TÀ

    // ¦Þ¦-¦-¦-¦-¦¬TÏ¦¦TÂ TÀ¦-¦¬¦-¦¦TÀ ¦¬¦¦TÀ¦¬¦-¦+¦- ¦¬ ¦¬TÀ¦¬¦¬¦-¦-¦¦ ¦-¦-¦¬¦-¦-¦¦¦-¦-TÁTÂ¦¬ TÂ¦-TÇ¦-¦-¦¦¦- TÀ¦¦¦¦¦¬¦-¦-
    procedure UpdatePeriodFromFrequency;

    // ¦ß¦¦TÀ¦¦TÁTÇ¦¬TÂTË¦-¦-¦¦TÂ ¦-¦-TÃTÂTÀ¦¦¦-¦-¦¬¦¦ ¦¬¦-TÀ¦-¦-¦¦TÂTÀTË ¦-TËTÀ¦-¦-¦-¦¦¦-¦-¦-¦¦¦- TÀ¦¦¦¦¦¬¦-¦-
    procedure ApplyAlignedBufferSize;
  protected
    procedure DoPrepareAfterSubscribeBeforeDeviceStart; override;
    function GetPlaybackBufferSize(ABufferSize: Integer): Integer; override;
    procedure ProcessBuffer(P: Pointer; Size: Integer); override;
    procedure SetFrequency(AValue: Double); override;
  public
    constructor Create; override;

    { ¦Þ¦-¦-¦-¦-¦¬TÏ¦¦TÂ ¦-¦-TÃTÂTÀ¦¦¦-¦-¦¬¦¦ ¦¬¦-TÀ¦-¦-¦¦TÂTÀTË TÂ¦-TÇ¦-¦-¦¦¦- TÀ¦¦¦¦¦¬¦-¦- ¦¬¦¦TÀ¦¦¦+ ¦¬¦-¦¬TÃTÁ¦¦¦-¦- ¦¬ ¦¬¦-TÁ¦¬¦¦ TÁ¦-¦¦¦-TË TÇ¦-TÁTÂ¦-TÂTË. }
    procedure RefreshAlignedBuffers;
    property PeriodSamples: Integer read fPeriodSamples;
  end;

implementation

const
  cMinAlignedSamples = 1024;

{ TAccurateSinusProgram }

constructor TAccurateSinusProgram.Create;
begin
  inherited Create;
  fPeriodSamples := 0;
  fUseAlignedPeriod := False;

  // ¦×¦-TÉ¦¬TÂ¦- ¦-TÂ TÁ¦¬¦¬TÈ¦¦¦-¦- ¦+¦¬¦¬¦-¦-TËTÅ ¦-TËTÀ¦-¦-¦-¦¦¦-¦-TËTÅ ¦-TÃTÄ¦¦TÀ¦-¦-.
  fMaxAlignedSamples := 44100 * 4;
end;

procedure TAccurateSinusProgram.UpdatePeriodFromFrequency;
begin
  fPeriodSamples := 0;
  fUseAlignedPeriod := False;

  if (fFrequency <= 0) or (SampleRate <= 0) then Exit;

  // Recalculate the upper aligned-buffer limit from SampleRate.
  fMaxAlignedSamples := SampleRate * 4;

  fPeriodSamples := Round(SampleRate / fFrequency);
  if fPeriodSamples < 1 then fPeriodSamples := 1;

  if fPeriodSamples > fMaxAlignedSamples then Exit;

  fUseAlignedPeriod := True;
end;

procedure TAccurateSinusProgram.ApplyAlignedBufferSize;
begin
  // Ðàçìåð ôèçè÷åñêîãî áëîêà íå ìåíÿåì: AccuracySin ñàì âûáèðàåò
  // ïîëåçíóþ äëèíó, êðàòíóþ öåëîìó ÷èñëó ïåðèîäîâ.
end;

procedure TAccurateSinusProgram.SetFrequency(AValue: Double);
begin
  if AValue < 0 then AValue := 0;
  if fFrequency = AValue then Exit;

  fFrequency := AValue;

  UpdatePeriodFromFrequency;

  // ¦ÕTÁ¦¬¦¬ TÂ¦-TÇ¦-TË¦¦ TÀ¦¦¦¦¦¬¦- ¦-¦¦¦-¦-¦¬¦-¦-¦¦¦¦¦-, ¦-TÁTÂ¦-¦¦¦-TÁTÏ ¦-¦- ¦-¦-TËTÇ¦-¦-¦¦ ¦-¦¦¦¬TÀ¦¦TÀTË¦-¦-¦-¦¦ ¦¦¦¦¦-¦¦TÀ¦-TÆ¦¬¦¬.
  if not fUseAlignedPeriod then Exit;

  // ¦Ô¦¬TÏ TÂ¦-TÇ¦-¦-¦¦¦- TÀ¦¦¦¦¦¬¦-¦- ¦-¦-¦-¦-¦-¦¬TÏ¦¦¦- ¦-¦-TÃTÂTÀ¦¦¦-¦-¦¬¦¦ ¦¬¦-TÀ¦-¦-¦¦TÂTÀTË ¦-TËTÀ¦-¦-¦-¦¬¦-¦-¦-¦¬TÏ.
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

function TAccurateSinusProgram.GetPlaybackBufferSize(ABufferSize: Integer): Integer;
var
  lBytesPerSample: Integer;
  lAvailableSamples: Integer;
  lWholePeriods: Integer;
begin
  Result := ABufferSize;

  if not fUseAlignedPeriod then
    Exit;

  lBytesPerSample := (BitsPerSample div 8) * Channels;
  if lBytesPerSample <= 0 then
    Exit;

  lAvailableSamples := ABufferSize div lBytesPerSample;
  if (fPeriodSamples <= 0) or (lAvailableSamples < fPeriodSamples) then
    Exit;

  lWholePeriods := lAvailableSamples div fPeriodSamples;
  if lWholePeriods < 1 then
    Exit;

  Result := lWholePeriods * fPeriodSamples * lBytesPerSample;
end;

procedure TAccurateSinusProgram.ProcessBuffer(P: Pointer; Size: Integer);
var
  i: Integer;
  lSampleCount: Integer;
  lSamples: PSmallInt;
  lStep: Double;
begin
  if (P = nil) or (Size <= 0) then Exit;

  lSampleCount := Size shr 1;
  if (not fUseAlignedPeriod) or (fPeriodSamples <= 0) or ((lSampleCount mod fPeriodSamples) <> 0) then
  begin
    inherited ProcessBuffer(P, Size);
    Exit;
  end;

  lSamples := PSmallInt(P);
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
