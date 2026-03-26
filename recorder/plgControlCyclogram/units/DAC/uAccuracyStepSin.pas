unit uAccuracyStepSin;

interface

uses
  Classes, SysUtils, Math,
  uDacDevice, uDacProgram, uSoundCardDac;

type
  TAccurateSinusProgram = class(TSimpleSinusProgram)
  private
    fPeriodSamples: Integer;
    fUseAlignedPeriod: Boolean;
    fMaxAlignedSamples: Integer;
    procedure UpdatePeriodFromFrequency;
    procedure ApplyAlignedBufferSize;
  protected
    procedure DoPrepareAfterSubscribeBeforeDeviceStart; override;
    function GetPlaybackBufferSize(ABufferSize: Integer): Integer; override;
    function DefaultVectorTagName: string; override;
    procedure GenerateWaveSamples(Count: Integer); override;
    procedure SetFrequency(AValue: Double); override;
  public
    constructor Create; override;
    procedure RefreshAlignedBuffers;
    property PeriodSamples: Integer read fPeriodSamples;
  end;

implementation

const
  cMinAlignedSamples = 1024;

constructor TAccurateSinusProgram.Create;
begin
  inherited Create;
  fPeriodSamples := 0;
  fUseAlignedPeriod := False;
  fMaxAlignedSamples := 44100 * 4;
end;

procedure TAccurateSinusProgram.UpdatePeriodFromFrequency;
begin
  fPeriodSamples := 0;
  fUseAlignedPeriod := False;

  if (fFrequency <= 0) or (SampleRate <= 0) then
    Exit;

  fMaxAlignedSamples := SampleRate * 4;
  fPeriodSamples := Round(SampleRate / fFrequency);
  if fPeriodSamples < 1 then
    fPeriodSamples := 1;
  if fPeriodSamples > fMaxAlignedSamples then
    Exit;

  fUseAlignedPeriod := True;
end;

procedure TAccurateSinusProgram.ApplyAlignedBufferSize;
begin
end;

procedure TAccurateSinusProgram.SetFrequency(AValue: Double);
begin
  if AValue < 0 then
    AValue := 0;
  if fFrequency = AValue then
    Exit;

  fFrequency := AValue;
  UpdatePeriodFromFrequency;
  if not fUseAlignedPeriod then
    Exit;

  ApplyAlignedBufferSize;
end;

procedure TAccurateSinusProgram.RefreshAlignedBuffers;
begin
  if not Assigned(fDevice) then
    Exit;

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

  if (lWholePeriods * fPeriodSamples) < cMinAlignedSamples then
    Exit;

  Result := lWholePeriods * fPeriodSamples * lBytesPerSample;
end;

function TAccurateSinusProgram.DefaultVectorTagName: string;
begin
  Result := 'DAC_AccuracySin';
end;

procedure TAccurateSinusProgram.GenerateWaveSamples(Count: Integer);
var
  i: Integer;
  lStep: Double;
begin
  if Count <= 0 then
    Exit;

  if (not fUseAlignedPeriod) or (fPeriodSamples <= 0) or
    ((Count mod fPeriodSamples) <> 0) then
  begin
    inherited GenerateWaveSamples(Count);
    Exit;
  end;

  lStep := (2 * Pi) / fPeriodSamples;
  for i := 0 to Count - 1 do
  begin
    fWaveBuffer[i] := Sin(fCurrentPhase);
    fCurrentPhase := fCurrentPhase + lStep;
    if fCurrentPhase > (2 * Pi) then
      fCurrentPhase := NormalizePhase(fCurrentPhase);
  end;
end;

end.