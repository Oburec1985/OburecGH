unit uBestSpectrumPipeline;

{$mode objfpc}{$H+}
{$pointermath on}

interface

uses
  Classes, Math, SysUtils
  {$IFDEF WINDOWS}, Windows {$ENDIF};

type
  TBestComplex64 = packed record
    Re: Double;
    Im: Double;
  end;

  PBestComplex64 = ^TBestComplex64;
  PPDouble = ^PDouble;
  TBestSpectrumEngine = class;
  TBestWorker = class;
  TBestWorkerArray = array of TBestWorker;

  TBestNormalizeMode = (
    bnmNone,       // Leave RMS amplitudes in physical scale.
    bnmMax,        // Divide all bins by the maximum amplitude.
    bnmEnergy      // Divide all bins by sqrt(sum(rms^2)).
  );

  TBestAlignedDoubleBuffer = class
  private
    FBase: Pointer;
    FData: PDouble;
    FCount: SizeInt;
  public
    constructor Create(ACount: SizeInt; AAlignment: SizeInt = 64);
    destructor Destroy; override;
    property Data: PDouble read FData;
    property Count: SizeInt read FCount;
  end;

  TBestAlignedComplexBuffer = class
  private
    FBase: Pointer;
    FData: PBestComplex64;
    FCount: SizeInt;
  public
    constructor Create(ACount: SizeInt; AAlignment: SizeInt = 64);
    destructor Destroy; override;
    property Data: PBestComplex64 read FData;
    property Count: SizeInt read FCount;
  end;

  TBestFFTPlan = class
  public
    Size: SizeInt;
    Bits: SizeInt;
    BitReverse: array of SizeInt;
    Twiddle: array of TBestComplex64; // exp(-i * 2*pi*k/N), k=0..N/2-1
    constructor Create(AFFTSize: SizeInt);
  end;

  TBestWorker = class(TThread)
  private
    FEngine: TBestSpectrumEngine;
    FStartEvent: THandle;
    FDoneEvent: THandle;
    FWindowed: TBestAlignedDoubleBuffer;
    FWork: TBestAlignedComplexBuffer;
    FStopRequested: Boolean;
    FInputs: PPDouble;
    FOutputs: PPDouble;
    FStartIndex: SizeInt;
    FEndIndex: SizeInt;
    FNormalize: TBestNormalizeMode;
  protected
    procedure Execute; override;
  public
    constructor Create(AEngine: TBestSpectrumEngine);
    destructor Destroy; override;
    procedure AssignTask(AInputs, AOutputs: PPDouble; AStartIndex, AEndIndex: SizeInt;
      ANormalize: TBestNormalizeMode);
    procedure RunTask;
    procedure WaitDone;
    procedure StopWorker;
  end;

  TBestSpectrumEngine = class
  private
    FFFTSize: SizeInt;
    FBins: SizeInt;
    FPlan: TBestFFTPlan;
    FWindow: TBestAlignedDoubleBuffer;
    FWindowed: TBestAlignedDoubleBuffer;
    FWork: TBestAlignedComplexBuffer;
    FWorkers: TBestWorkerArray;
    procedure BuildHannWindow;
    procedure EvalSingleNoAlloc(AInput, AOutputRms: PDouble; ANormalize: TBestNormalizeMode);
    procedure EvalSingleWithBuffers(AInput, AOutputRms: PDouble; AWindowed: PDouble;
      AWork: PBestComplex64; ANormalize: TBestNormalizeMode);
  public
    constructor Create(AFFTSize, AWorkerCount: SizeInt);
    destructor Destroy; override;
    property FFTSize: SizeInt read FFFTSize;
    property Bins: SizeInt read FBins;
  end;

// Initializes everything that must not happen in realtime:
// FFT twiddle factors, bit-reverse indexes, window coefficients, working
// buffers, and persistent worker threads.
function BestInitProc(AFFTSize, AWorkerCount: SizeInt): TBestSpectrumEngine;

// Runtime single-spectrum path. No allocation, no trigonometry, no thread
// creation. AInput must contain AFFTSize samples. AOutputRms must contain at
// least AFFTSize div 2 values.
procedure BestEvalProc(AEngine: TBestSpectrumEngine; AInput, AOutputRms: PDouble;
  ANormalize: TBestNormalizeMode = bnmNone);

// Runtime batch path for many independent spectra. AInputs and AOutputs are
// arrays of pointers. Each input has FFTSize samples; each output has FFTSize/2
// RMS bins. Uses the persistent worker pool created by BestInitProc.
procedure BestEvalBatchProc(AEngine: TBestSpectrumEngine; const AInputs, AOutputs: array of PDouble;
  ANormalize: TBestNormalizeMode = bnmNone);

implementation

const
  CTwoPi = 2.0 * Pi;
  CSqrt2 = 1.4142135623730950488;

function AlignPointer(APtr: Pointer; AAlignment: SizeInt): Pointer;
var
  V: PtrUInt;
begin
  V := PtrUInt(APtr);
  Result := Pointer((V + PtrUInt(AAlignment - 1)) and not PtrUInt(AAlignment - 1));
end;

function IsPowerOfTwo(AValue: SizeInt): Boolean;
begin
  Result := (AValue > 0) and ((AValue and (AValue - 1)) = 0);
end;

function ReverseBits(AValue, ABitCount: SizeInt): SizeInt;
var
  I: SizeInt;
begin
  Result := 0;
  for I := 0 to ABitCount - 1 do
  begin
    Result := (Result shl 1) or (AValue and 1);
    AValue := AValue shr 1;
  end;
end;

constructor TBestAlignedDoubleBuffer.Create(ACount: SizeInt; AAlignment: SizeInt);
begin
  inherited Create;
  FCount := ACount;
  GetMem(FBase, ACount * SizeOf(Double) + AAlignment);
  FData := PDouble(AlignPointer(FBase, AAlignment));
end;

destructor TBestAlignedDoubleBuffer.Destroy;
begin
  if FBase <> nil then
    FreeMem(FBase);
  inherited Destroy;
end;

constructor TBestAlignedComplexBuffer.Create(ACount: SizeInt; AAlignment: SizeInt);
begin
  inherited Create;
  FCount := ACount;
  GetMem(FBase, ACount * SizeOf(TBestComplex64) + AAlignment);
  FData := PBestComplex64(AlignPointer(FBase, AAlignment));
end;

destructor TBestAlignedComplexBuffer.Destroy;
begin
  if FBase <> nil then
    FreeMem(FBase);
  inherited Destroy;
end;

constructor TBestFFTPlan.Create(AFFTSize: SizeInt);
var
  I: SizeInt;
  Angle: Double;
  S, C: Double;
begin
  inherited Create;
  if not IsPowerOfTwo(AFFTSize) then
    raise Exception.Create('FFT size must be a power of two');

  Size := AFFTSize;
  Bits := 0;
  I := AFFTSize;
  while I > 1 do
  begin
    Inc(Bits);
    I := I shr 1;
  end;

  SetLength(BitReverse, AFFTSize);
  for I := 0 to AFFTSize - 1 do
    BitReverse[I] := ReverseBits(I, Bits);

  // Twiddle factors are the expensive exp/sin/cos part of FFT. They are built
  // once here and then reused by every realtime evaluation.
  SetLength(Twiddle, AFFTSize div 2);
  for I := 0 to (AFFTSize div 2) - 1 do
  begin
    Angle := -CTwoPi * I / AFFTSize;
    SinCos(Angle, S, C);
    Twiddle[I].Re := C;
    Twiddle[I].Im := S;
  end;
end;

constructor TBestWorker.Create(AEngine: TBestSpectrumEngine);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FEngine := AEngine;
  FWindowed := TBestAlignedDoubleBuffer.Create(AEngine.FFTSize);
  FWork := TBestAlignedComplexBuffer.Create(AEngine.FFTSize);
  FStartEvent := CreateEvent(nil, True, False, nil);
  FDoneEvent := CreateEvent(nil, True, True, nil);
  Start;
end;

destructor TBestWorker.Destroy;
begin
  StopWorker;
  WaitFor;
  if FStartEvent <> 0 then
    CloseHandle(FStartEvent);
  if FDoneEvent <> 0 then
    CloseHandle(FDoneEvent);
  FWork.Free;
  FWindowed.Free;
  inherited Destroy;
end;

procedure TBestWorker.AssignTask(AInputs, AOutputs: PPDouble; AStartIndex, AEndIndex: SizeInt;
  ANormalize: TBestNormalizeMode);
begin
  FInputs := AInputs;
  FOutputs := AOutputs;
  FStartIndex := AStartIndex;
  FEndIndex := AEndIndex;
  FNormalize := ANormalize;
end;

procedure TBestWorker.RunTask;
begin
  ResetEvent(FDoneEvent);
  SetEvent(FStartEvent);
end;

procedure TBestWorker.WaitDone;
begin
  WaitForSingleObject(FDoneEvent, INFINITE);
end;

procedure TBestWorker.StopWorker;
begin
  FStopRequested := True;
  SetEvent(FStartEvent);
end;

procedure TBestWorker.Execute;
var
  I: SizeInt;
begin
  while True do
  begin
    WaitForSingleObject(FStartEvent, INFINITE);
    ResetEvent(FStartEvent);
    if FStopRequested then
      Break;

    for I := FStartIndex to FEndIndex - 1 do
      FEngine.EvalSingleWithBuffers(FInputs[I], FOutputs[I], FWindowed.Data, FWork.Data, FNormalize);

    SetEvent(FDoneEvent);
  end;
  SetEvent(FDoneEvent);
end;

procedure MulFloat64To(A, B, Dst: PDouble; Count: SizeInt); inline;
var
  I: SizeInt;
begin
  // Windowing is deliberately a separate point-wise multiply: this is simple,
  // cache-friendly, easy to SIMD later, and does not pollute FFT butterfly code.
  for I := 0 to Count - 1 do
    Dst[I] := A[I] * B[I];
end;

procedure PrepareBitReversedReal(Input: PDouble; Work: PBestComplex64; Plan: TBestFFTPlan); inline;
var
  I, J: SizeInt;
begin
  for I := 0 to Plan.Size - 1 do
  begin
    J := Plan.BitReverse[I];
    Work[J].Re := Input[I];
    Work[J].Im := 0.0;
  end;
end;

procedure ButterflyForwardInline(var U, V: TBestComplex64; const Tw: TBestComplex64); inline;
var
  TmpRe, TmpIm, URe, UIm: Double;
begin
  URe := U.Re;
  UIm := U.Im;
  TmpRe := V.Re * Tw.Re - V.Im * Tw.Im;
  TmpIm := V.Re * Tw.Im + V.Im * Tw.Re;
  U.Re := URe + TmpRe;
  U.Im := UIm + TmpIm;
  V.Re := URe - TmpRe;
  V.Im := UIm - TmpIm;
end;

procedure FFTForwardPrecomputedInline(Work: PBestComplex64; Plan: TBestFFTPlan); inline;
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
begin
  StepSize := 2;
  while StepSize <= Plan.Size do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Plan.Size div StepSize;
    BlockStart := 0;
    while BlockStart < Plan.Size do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        ButterflyForwardInline(
          Work[BlockStart + K],
          Work[BlockStart + K + HalfStep],
          Plan.Twiddle[TwiddleIndex]);
        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure EvalRmsAndNormalize(Work: PBestComplex64; OutputRms: PDouble; FFTSize, Bins: SizeInt;
  ANormalize: TBestNormalizeMode); inline;
var
  I: SizeInt;
  Scale: Double;
  V: Double;
  Norm: Double;
begin
  // For a real signal, positive-frequency RMS amplitude is:
  // sqrt(Re^2 + Im^2) * (2/N) / sqrt(2) = sqrt(Re^2 + Im^2) * sqrt(2)/N.
  Scale := CSqrt2 / FFTSize;
  Norm := 0.0;

  for I := 0 to Bins - 1 do
  begin
    V := Sqrt(Sqr(Work[I].Re) + Sqr(Work[I].Im)) * Scale;
    OutputRms[I] := V;
    case ANormalize of
      bnmMax:
        if V > Norm then
          Norm := V;
      bnmEnergy:
        Norm := Norm + Sqr(V);
    end;
  end;

  case ANormalize of
    bnmMax:
      ; // Norm is already max.
    bnmEnergy:
      Norm := Sqrt(Norm);
  else
    Norm := 0.0;
  end;

  if Norm > 0.0 then
    for I := 0 to Bins - 1 do
      OutputRms[I] := OutputRms[I] / Norm;
end;

constructor TBestSpectrumEngine.Create(AFFTSize, AWorkerCount: SizeInt);
var
  I: SizeInt;
begin
  inherited Create;
  FFFTSize := AFFTSize;
  FBins := AFFTSize div 2;
  FPlan := TBestFFTPlan.Create(AFFTSize);
  FWindow := TBestAlignedDoubleBuffer.Create(AFFTSize);
  FWindowed := TBestAlignedDoubleBuffer.Create(AFFTSize);
  FWork := TBestAlignedComplexBuffer.Create(AFFTSize);
  BuildHannWindow;

  if AWorkerCount < 0 then
    AWorkerCount := 0;
  SetLength(FWorkers, AWorkerCount);
  for I := 0 to High(FWorkers) do
    FWorkers[I] := TBestWorker.Create(Self);
end;

destructor TBestSpectrumEngine.Destroy;
var
  I: SizeInt;
begin
  for I := 0 to High(FWorkers) do
    FWorkers[I].Free;
  FWork.Free;
  FWindowed.Free;
  FWindow.Free;
  FPlan.Free;
  inherited Destroy;
end;

procedure TBestSpectrumEngine.BuildHannWindow;
var
  I: SizeInt;
begin
  if FFFTSize <= 1 then
    Exit;
  for I := 0 to FFFTSize - 1 do
    FWindow.Data[I] := 0.5 - 0.5 * Cos(CTwoPi * I / (FFFTSize - 1));
end;

procedure TBestSpectrumEngine.EvalSingleNoAlloc(AInput, AOutputRms: PDouble;
  ANormalize: TBestNormalizeMode);
begin
  EvalSingleWithBuffers(AInput, AOutputRms, FWindowed.Data, FWork.Data, ANormalize);
end;

procedure TBestSpectrumEngine.EvalSingleWithBuffers(AInput, AOutputRms: PDouble;
  AWindowed: PDouble; AWork: PBestComplex64; ANormalize: TBestNormalizeMode);
begin
  MulFloat64To(AInput, FWindow.Data, AWindowed, FFFTSize);
  PrepareBitReversedReal(AWindowed, AWork, FPlan);
  FFTForwardPrecomputedInline(AWork, FPlan);
  EvalRmsAndNormalize(AWork, AOutputRms, FFFTSize, FBins, ANormalize);
end;

function BestInitProc(AFFTSize, AWorkerCount: SizeInt): TBestSpectrumEngine;
begin
  Result := TBestSpectrumEngine.Create(AFFTSize, AWorkerCount);
end;

procedure BestEvalProc(AEngine: TBestSpectrumEngine; AInput, AOutputRms: PDouble;
  ANormalize: TBestNormalizeMode);
begin
  if AEngine = nil then
    raise Exception.Create('BestEvalProc: engine is nil');
  AEngine.EvalSingleNoAlloc(AInput, AOutputRms, ANormalize);
end;

procedure BestEvalBatchProc(AEngine: TBestSpectrumEngine; const AInputs, AOutputs: array of PDouble;
  ANormalize: TBestNormalizeMode);
var
  WorkerCount: SizeInt;
  I: SizeInt;
  StartIndex: SizeInt;
  EndIndex: SizeInt;
begin
  if AEngine = nil then
    raise Exception.Create('BestEvalBatchProc: engine is nil');
  if Length(AInputs) <> Length(AOutputs) then
    raise Exception.Create('BestEvalBatchProc: input/output count mismatch');
  if Length(AInputs) = 0 then
    Exit;

  WorkerCount := Length(AEngine.FWorkers);
  if WorkerCount > Length(AInputs) then
    WorkerCount := Length(AInputs);

  if WorkerCount <= 1 then
  begin
    for I := 0 to High(AInputs) do
      AEngine.EvalSingleNoAlloc(AInputs[I], AOutputs[I], ANormalize);
    Exit;
  end;

  for I := 0 to WorkerCount - 1 do
  begin
    StartIndex := (Length(AInputs) * I) div WorkerCount;
    EndIndex := (Length(AInputs) * (I + 1)) div WorkerCount;
    AEngine.FWorkers[I].AssignTask(@AInputs[0], @AOutputs[0], StartIndex, EndIndex, ANormalize);
  end;
  for I := 0 to WorkerCount - 1 do
    AEngine.FWorkers[I].RunTask;
  for I := 0 to WorkerCount - 1 do
    AEngine.FWorkers[I].WaitDone;
end;

end.
