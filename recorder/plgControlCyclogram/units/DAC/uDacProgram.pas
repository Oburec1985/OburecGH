unit uDACProgram;

interface

uses
  Classes, SysUtils, Math, uCommonTypes, uDacDevice, uSoundCardDac;

type
  TDacProgram = class
  protected
    fDevice: TDacDevice;
    fCurrentPhase: Double;
    fFrequency: Double;
    fAmplitude: Double;
    fActive: Boolean;
    fDacData: TDacData;
    procedure ApplyTransportToDevice;
    procedure DoPrepareAfterSubscribeBeforeDeviceStart; virtual;
    procedure OnGenData(data: TObject); virtual;
    procedure ProcessBuffer(P: Pointer; Size: Integer); virtual; abstract;
    function NormalizePhase(APhase: Double): Double;
    function GetAlignedSize(Freq: Double; MinSamples: Integer): Integer; virtual;
    procedure SetFrequency(AValue: Double); virtual;
    procedure SetAmplitude(AValue: Double); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function SampleRate: Cardinal;
    function BitsPerSample: Cardinal;
    function Channels: Cardinal;
    procedure Start(ALoopCount: Cardinal = 1); virtual;
    procedure Stop(AGraceful: Boolean = False); virtual;
    procedure ConfigureTransport(d: TDacData);
    function IsPlaybackActive: Boolean;
    procedure SetDevice(AValue: TDacDevice); virtual;
    property Device: TDacDevice read fDevice;
    property Active: Boolean read fActive;
    property Frequency: Double read fFrequency write SetFrequency;
    property Amplitude: Double read fAmplitude write SetAmplitude;
  end;

  TSimpleSinusProgram = class(TDacProgram)
  protected
    procedure ProcessBuffer(P: Pointer; Size: Integer); override;
  public
    constructor Create; override;
  end;

  TSweepSinProgram = class(TDacProgram)
  private
    fStartFrequency: Double;
    fEndFrequency: Double;
    fSweepTimeSec: Double;
    fElapsedSamples: Int64;
    procedure SetStartFrequency(AValue: Double);
    procedure SetEndFrequency(AValue: Double);
    procedure SetSweepTimeSec(AValue: Double);
  protected
    procedure ProcessBuffer(P: Pointer; Size: Integer); override;
  public
    constructor Create; override;
    procedure Start(ALoopCount: Cardinal = 1); override;
    property StartFrequency: Double read fStartFrequency write SetStartFrequency;
    property EndFrequency: Double read fEndFrequency write SetEndFrequency;
    property SweepTimeSec: Double read fSweepTimeSec write SetSweepTimeSec;
  end;

implementation

function TDacProgram.BitsPerSample: Cardinal;
begin
  Result := fDevice.BitsPerSample;
end;

function TDacProgram.Channels: Cardinal;
begin
  Result := fDevice.Channels;
end;

constructor TDacProgram.Create;
begin
  inherited Create;
  fCurrentPhase := 0;
  fFrequency := 440;
  fAmplitude := 0.5;
  fActive := False;
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
  if not Assigned(fDevice) then
    Exit;
  if fDevice.IsPlay then
    Exit;

  if fDevice.State = stClosed then
  begin
    ApplyTransportToDevice;
    fDevice.Open;
  end;

  fDevice.OnGenerateData := OnGenData;
  fActive := True;
  DoPrepareAfterSubscribeBeforeDeviceStart;
  fCurrentPhase := 0;
  fDevice.Start(ALoopCount);
end;

procedure TDacProgram.Stop(AGraceful: Boolean);
begin
  if not Assigned(fDevice) then
    Exit;
  fActive := False;
  if fDevice.IsPlay then
    fDevice.Stop(AGraceful);
end;

procedure TDacProgram.SetDevice(AValue: TDacDevice);
begin
  if fDevice = AValue then
    Exit;
  Stop;
  fDevice := AValue;
end;

procedure TDacProgram.ConfigureTransport(d: TDacData);
begin
  fDacData := d;
end;

procedure TDacProgram.ApplyTransportToDevice;
begin
  if not Assigned(fDevice) then
    Exit;
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
  if AValue < 0 then
    AValue := 0;
  fFrequency := AValue;
end;

function TDacProgram.SampleRate: Cardinal;
begin
  Result := fDevice.SampleRate;
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
  lTwoPi: Double;
begin
  lTwoPi := 2 * Pi;
  Result := APhase - (lTwoPi * Floor(APhase / lTwoPi));
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

  lPeriodSamples := Round(SampleRate / Freq);
  if lPeriodSamples < 1 then
    lPeriodSamples := 1;

  lPeriodsInBuffer := Ceil(MinSamples / lPeriodSamples);
  if lPeriodsInBuffer < 1 then
    lPeriodsInBuffer := 1;

  Result := lPeriodsInBuffer * lPeriodSamples;
end;

procedure TDacProgram.OnGenData(data: TObject);
var
  lBlockData: PBlockData;
  lBlock: PSoundCardBlock;
  lDataPtr: Pointer;
begin
  if not Assigned(fDevice) then
    Exit;

  lBlockData := fDevice.BlockQueue.GetPushBlock;
  if lBlockData.Data = nil then
    Exit;

  lBlock := PSoundCardBlock(lBlockData.Data);
  if (lBlock = nil) or (lBlock^.Samples = nil) then
    Exit;

  lDataPtr := @lBlock.Samples[0];
  ProcessBuffer(lDataPtr, fDevice.BufferSize);
  fDevice.QueueBuffer;
end;

constructor TSimpleSinusProgram.Create;
begin
  inherited Create;
end;

procedure TSimpleSinusProgram.ProcessBuffer(P: Pointer; Size: Integer);
var
  lIndex: Integer;
  lCount: Integer;
  lSamples: PSmallIntArray;
  lStep: Double;
begin
  if (P = nil) or (Size <= 0) then
    Exit;

  fDevice.EnterCS;
  try
    lSamples := PSmallIntArray(P);
    lStep := 2 * Pi * fFrequency / SampleRate;
    lCount := Size shr 1;

    for lIndex := 0 to lCount - 1 do
    begin
      TSmallIntArray(lSamples)[lIndex] := Round(fAmplitude * Sin(fCurrentPhase) * 32767);
      fCurrentPhase := fCurrentPhase + lStep;
      if fCurrentPhase > (2 * Pi) then
        fCurrentPhase := NormalizePhase(fCurrentPhase);
    end;
  finally
    fDevice.ExitCS;
  end;
end;

constructor TSweepSinProgram.Create;
begin
  inherited Create;
  fStartFrequency := 100;
  fEndFrequency := 10000;
  fSweepTimeSec := 10;
  fElapsedSamples := 0;
end;

procedure TSweepSinProgram.Start(ALoopCount: Cardinal);
begin
  fElapsedSamples := 0;
  inherited Start(ALoopCount);
end;

procedure TSweepSinProgram.SetStartFrequency(AValue: Double);
begin
  if AValue < 0 then
    AValue := 0;
  fStartFrequency := AValue;
end;

procedure TSweepSinProgram.SetEndFrequency(AValue: Double);
begin
  if AValue < 0 then
    AValue := 0;
  fEndFrequency := AValue;
end;

procedure TSweepSinProgram.SetSweepTimeSec(AValue: Double);
begin
  if AValue < 0 then
    AValue := 0;
  fSweepTimeSec := AValue;
end;

procedure TSweepSinProgram.ProcessBuffer(P: Pointer; Size: Integer);
var
  lIndex: Integer;
  lCount: Integer;
  lSamples: PSmallIntArray;
  lFreq: Double;
  lRate: Double;
  lTimeSec: Double;
  lK: Double;
begin
  if (P = nil) or (Size <= 0) then
    Exit;
  if SampleRate <= 0 then
    Exit;

  lSamples := PSmallIntArray(P);
  lCount := Size shr 1;
  lRate := SampleRate;

  for lIndex := 0 to lCount - 1 do
  begin
    if fSweepTimeSec > 0 then
    begin
      lTimeSec := fElapsedSamples / lRate;
      lK := lTimeSec / fSweepTimeSec;
      if lK > 1 then
        lK := 1;
      lFreq := fStartFrequency + (fEndFrequency - fStartFrequency) * lK;
    end
    else
      lFreq := fStartFrequency;

    TSmallIntArray(lSamples)[lIndex] := Round(fAmplitude * Sin(fCurrentPhase) * 32767);
    fCurrentPhase := fCurrentPhase + 2 * Pi * lFreq / lRate;
    if fCurrentPhase > (2 * Pi) then
      fCurrentPhase := NormalizePhase(fCurrentPhase);
    Inc(fElapsedSamples);
  end;
end;

end.