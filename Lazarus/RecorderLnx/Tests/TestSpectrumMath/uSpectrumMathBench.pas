unit uSpectrumMathBench;

{$mode objfpc}{$H+}
{$asmmode intel}
{$pointermath on}

interface

procedure RunSpectrumMathBench;

implementation

uses
  Classes, Math, SysUtils
  {$IFDEF WINDOWS}, Windows {$ENDIF};

const
  CAlignment = 64;
  CTwoPi = 2.0 * Pi;
  CBenchIterations = 200;
  CBatchIterations = 40;
  CCompareTolerance = 1.0e-8;
  CSqrt2: Double = 1.4142135623730950488;

type
  TComplex64 = packed record
    Re: Double;
    Im: Double;
  end;

  PComplex64 = ^TComplex64;

  TAlignedDoubleBuffer = class
  private
    FBase: Pointer;
    FData: PDouble;
    FCount: SizeInt;
  public
    constructor Create(ACount: SizeInt; AAlignment: SizeInt = CAlignment);
    destructor Destroy; override;
    property Data: PDouble read FData;
    property Count: SizeInt read FCount;
  end;

  TAlignedComplexBuffer = class
  private
    FBase: Pointer;
    FData: PComplex64;
    FCount: SizeInt;
  public
    constructor Create(ACount: SizeInt; AAlignment: SizeInt = CAlignment);
    destructor Destroy; override;
    property Data: PComplex64 read FData;
    property Count: SizeInt read FCount;
  end;

  TFFTPlan = class
  private
    FSize: SizeInt;
    FBits: SizeInt;
    FBitReverse: array of SizeInt;
    FTwiddle: array of TComplex64;
    function GetBitReverse(Index: SizeInt): SizeInt;
    function GetTwiddle(Index: SizeInt): TComplex64;
  public
    constructor Create(ASize: SizeInt);
    property Size: SizeInt read FSize;
    property BitReverse[Index: SizeInt]: SizeInt read GetBitReverse;
    property Twiddle[Index: SizeInt]: TComplex64 read GetTwiddle;
  end;

  TLogWriter = class
  private
    FFile: TextFile;
    FOpened: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Line(const S: string);
  end;

  TDoubleBufferArray = array of TAlignedDoubleBuffer;
  TComplexBufferArray = array of TAlignedComplexBuffer;

  TBatchFftWorker = class(TThread)
  private
    FInputs: TDoubleBufferArray;
    FOutputs: TComplexBufferArray;
    FStartIndex: SizeInt;
    FEndIndex: SizeInt;
    FIterations: SizeInt;
    FFFTSize: SizeInt;
  protected
    procedure Execute; override;
  public
    constructor Create(const AInputs: TDoubleBufferArray; const AOutputs: TComplexBufferArray;
      AStartIndex, AEndIndex, AIterations, AFFTSize: SizeInt);
  end;

  TBatchWorkerArray = array of TBatchFftWorker;

  TPersistentFftWorker = class(TThread)
  private
    FStartEvent: THandle;
    FDoneEvent: THandle;
    FInputs: TDoubleBufferArray;
    FOutputs: TComplexBufferArray;
    FStartIndex: SizeInt;
    FEndIndex: SizeInt;
    FFFTSize: SizeInt;
    FStopRequested: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AssignTask(const AInputs: TDoubleBufferArray; const AOutputs: TComplexBufferArray;
      AStartIndex, AEndIndex, AFFTSize: SizeInt);
    procedure RunTask;
    procedure WaitDone;
    procedure StopWorker;
    property DoneEvent: THandle read FDoneEvent;
  end;

  TPersistentWorkerArray = array of TPersistentFftWorker;

  TSpectrumBackendProc = procedure(Input: PDouble; Output: PComplex64; Count: SizeInt);
  TSpectrumPipelineProc = procedure(Input: PDouble; Work: PComplex64; Magnitude: PDouble; Count: SizeInt);
  TButterflyProc = procedure(Work: PComplex64; Count: SizeInt);
  TFftOnlyProc = procedure(Input: PDouble; Output: PComplex64; Count: SizeInt);

var
  GActivePlan: TFFTPlan = nil;

procedure FftOnlyPrecomputedInline(Input: PDouble; Output: PComplex64; Count: SizeInt); forward;

function AlignPointer(APtr: Pointer; AAlignment: SizeInt): Pointer;
var
  LValue: PtrUInt;
begin
  LValue := PtrUInt(APtr);
  Result := Pointer((LValue + PtrUInt(AAlignment - 1)) and not PtrUInt(AAlignment - 1));
end;

constructor TAlignedDoubleBuffer.Create(ACount: SizeInt; AAlignment: SizeInt);
begin
  inherited Create;
  FCount := ACount;
  GetMem(FBase, ACount * SizeOf(Double) + AAlignment);
  FData := PDouble(AlignPointer(FBase, AAlignment));
end;

destructor TAlignedDoubleBuffer.Destroy;
begin
  if FBase <> nil then
    FreeMem(FBase);
  inherited Destroy;
end;

constructor TAlignedComplexBuffer.Create(ACount: SizeInt; AAlignment: SizeInt);
begin
  inherited Create;
  FCount := ACount;
  GetMem(FBase, ACount * SizeOf(TComplex64) + AAlignment);
  FData := PComplex64(AlignPointer(FBase, AAlignment));
end;

destructor TAlignedComplexBuffer.Destroy;
begin
  if FBase <> nil then
    FreeMem(FBase);
  inherited Destroy;
end;

constructor TLogWriter.Create;
var
  LDir: string;
  LPath: string;
begin
  inherited Create;
  LDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'logs';
  ForceDirectories(LDir);
  LPath := IncludeTrailingPathDelimiter(LDir) +
    FormatDateTime('yyyymmdd_hhnnss', Now) + '_spectrum_math.log';
  AssignFile(FFile, LPath);
  Rewrite(FFile);
  FOpened := True;
  Line('LogFile: ' + LPath);
end;

destructor TLogWriter.Destroy;
begin
  if FOpened then
    CloseFile(FFile);
  inherited Destroy;
end;

procedure TLogWriter.Line(const S: string);
begin
  Writeln(S);
  if FOpened then
  begin
    Writeln(FFile, S);
    Flush(FFile);
  end;
end;

constructor TBatchFftWorker.Create(const AInputs: TDoubleBufferArray; const AOutputs: TComplexBufferArray;
  AStartIndex, AEndIndex, AIterations, AFFTSize: SizeInt);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FInputs := AInputs;
  FOutputs := AOutputs;
  FStartIndex := AStartIndex;
  FEndIndex := AEndIndex;
  FIterations := AIterations;
  FFFTSize := AFFTSize;
end;

procedure TBatchFftWorker.Execute;
var
  Iter: SizeInt;
  I: SizeInt;
begin
  for Iter := 1 to FIterations do
    for I := FStartIndex to FEndIndex - 1 do
      FftOnlyPrecomputedInline(FInputs[I].Data, FOutputs[I].Data, FFFTSize);
end;

constructor TPersistentFftWorker.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FStartEvent := CreateEvent(nil, True, False, nil);
  FDoneEvent := CreateEvent(nil, True, True, nil);
  FStopRequested := False;
  Start;
end;

destructor TPersistentFftWorker.Destroy;
begin
  StopWorker;
  WaitFor;
  if FStartEvent <> 0 then
    CloseHandle(FStartEvent);
  if FDoneEvent <> 0 then
    CloseHandle(FDoneEvent);
  inherited Destroy;
end;

procedure TPersistentFftWorker.AssignTask(const AInputs: TDoubleBufferArray;
  const AOutputs: TComplexBufferArray; AStartIndex, AEndIndex, AFFTSize: SizeInt);
begin
  FInputs := AInputs;
  FOutputs := AOutputs;
  FStartIndex := AStartIndex;
  FEndIndex := AEndIndex;
  FFFTSize := AFFTSize;
end;

procedure TPersistentFftWorker.RunTask;
begin
  ResetEvent(FDoneEvent);
  SetEvent(FStartEvent);
end;

procedure TPersistentFftWorker.WaitDone;
begin
  WaitForSingleObject(FDoneEvent, INFINITE);
end;

procedure TPersistentFftWorker.StopWorker;
begin
  FStopRequested := True;
  SetEvent(FStartEvent);
end;

procedure TPersistentFftWorker.Execute;
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
      FftOnlyPrecomputedInline(FInputs[I].Data, FOutputs[I].Data, FFFTSize);

    SetEvent(FDoneEvent);
  end;
  SetEvent(FDoneEvent);
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

function TFFTPlan.GetBitReverse(Index: SizeInt): SizeInt;
begin
  Result := FBitReverse[Index];
end;

function TFFTPlan.GetTwiddle(Index: SizeInt): TComplex64;
begin
  Result := FTwiddle[Index];
end;

constructor TFFTPlan.Create(ASize: SizeInt);
var
  I: SizeInt;
  S, C: Double;
  Angle: Double;
begin
  inherited Create;
  if not IsPowerOfTwo(ASize) then
    raise Exception.Create('FFT plan size must be power of two');

  FSize := ASize;
  FBits := 0;
  I := ASize;
  while I > 1 do
  begin
    Inc(FBits);
    I := I shr 1;
  end;

  SetLength(FBitReverse, ASize);
  for I := 0 to ASize - 1 do
    FBitReverse[I] := ReverseBits(I, FBits);

  SetLength(FTwiddle, ASize div 2);
  for I := 0 to (ASize div 2) - 1 do
  begin
    Angle := -CTwoPi * I / ASize;
    SinCos(Angle, S, C);
    FTwiddle[I].Re := C;
    FTwiddle[I].Im := S;
  end;
end;

procedure FillTestSignal(Output: PDouble; Count: SizeInt);
var
  I: SizeInt;
  T: Double;
begin
  for I := 0 to Count - 1 do
  begin
    T := I / Count;
    Output[I] :=
      1.25 * Sin(CTwoPi * 3.0 * T) +
      0.35 * Cos(CTwoPi * 17.0 * T + 0.4) +
      0.08 * Sin(CTwoPi * 41.0 * T + 1.1);
  end;
end;

procedure ApplyHannWindow(Input, Output: PDouble; Count: SizeInt);
var
  I: SizeInt;
  W: Double;
begin
  if Count <= 1 then
    Exit;
  for I := 0 to Count - 1 do
  begin
    W := 0.5 - 0.5 * Cos(CTwoPi * I / (Count - 1));
    Output[I] := Input[I] * W;
  end;
end;

procedure ClearComplex(Output: PComplex64; Count: SizeInt);
var
  I: SizeInt;
begin
  for I := 0 to Count - 1 do
  begin
    Output[I].Re := 0.0;
    Output[I].Im := 0.0;
  end;
end;

procedure CopyComplex(Src, Dst: PComplex64; Count: SizeInt);
begin
  Move(Src^, Dst^, Count * SizeOf(TComplex64));
end;

procedure PrepareBitReversedReal(Input: PDouble; Output: PComplex64; Count: SizeInt);
var
  I, J: SizeInt;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  ClearComplex(Output, Count);
  for I := 0 to Count - 1 do
  begin
    J := GActivePlan.FBitReverse[I];
    Output[J].Re := Input[I];
    Output[J].Im := 0.0;
  end;
end;

procedure SpectrumDftPascal(Input: PDouble; Output: PComplex64; Count: SizeInt);
var
  K, N: SizeInt;
  Angle: Double;
  S, C: Double;
  ReSum, ImSum: Double;
begin
  for K := 0 to Count - 1 do
  begin
    ReSum := 0.0;
    ImSum := 0.0;
    for N := 0 to Count - 1 do
    begin
      Angle := -CTwoPi * K * N / Count;
      SinCos(Angle, S, C);
      ReSum := ReSum + Input[N] * C;
      ImSum := ImSum + Input[N] * S;
    end;
    Output[K].Re := ReSum;
    Output[K].Im := ImSum;
  end;
end;

procedure SpectrumFftIterativePascal(Input: PDouble; Output: PComplex64; Count: SizeInt);
var
  Bits: SizeInt;
  I, J: SizeInt;
  StepSize, HalfStep, BlockStart, K: SizeInt;
  Angle, S, C: Double;
  TmpRe, TmpIm, URe, UIm, VRe, VIm: Double;
begin
  if not IsPowerOfTwo(Count) then
    raise Exception.Create('FFT size must be power of two');

  Bits := 0;
  I := Count;
  while I > 1 do
  begin
    Inc(Bits);
    I := I shr 1;
  end;

  ClearComplex(Output, Count);
  for I := 0 to Count - 1 do
  begin
    J := ReverseBits(I, Bits);
    Output[J].Re := Input[I];
    Output[J].Im := 0.0;
  end;

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      for K := 0 to HalfStep - 1 do
      begin
        Angle := -CTwoPi * K / StepSize;
        SinCos(Angle, S, C);

        URe := Output[BlockStart + K].Re;
        UIm := Output[BlockStart + K].Im;
        VRe := Output[BlockStart + K + HalfStep].Re;
        VIm := Output[BlockStart + K + HalfStep].Im;

        TmpRe := VRe * C - VIm * S;
        TmpIm := VRe * S + VIm * C;

        Output[BlockStart + K].Re := URe + TmpRe;
        Output[BlockStart + K].Im := UIm + TmpIm;
        Output[BlockStart + K + HalfStep].Re := URe - TmpRe;
        Output[BlockStart + K + HalfStep].Im := UIm - TmpIm;
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure SpectrumFftPrecomputedPascal(Input: PDouble; Output: PComplex64; Count: SizeInt);
var
  I, J: SizeInt;
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  Tw: TComplex64;
  TmpRe, TmpIm, URe, UIm, VRe, VIm: Double;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  ClearComplex(Output, Count);
  for I := 0 to Count - 1 do
  begin
    J := GActivePlan.FBitReverse[I];
    Output[J].Re := Input[I];
    Output[J].Im := 0.0;
  end;

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        Tw := GActivePlan.FTwiddle[TwiddleIndex];

        URe := Output[BlockStart + K].Re;
        UIm := Output[BlockStart + K].Im;
        VRe := Output[BlockStart + K + HalfStep].Re;
        VIm := Output[BlockStart + K + HalfStep].Im;

        TmpRe := VRe * Tw.Re - VIm * Tw.Im;
        TmpIm := VRe * Tw.Im + VIm * Tw.Re;

        Output[BlockStart + K].Re := URe + TmpRe;
        Output[BlockStart + K].Im := UIm + TmpIm;
        Output[BlockStart + K + HalfStep].Re := URe - TmpRe;
        Output[BlockStart + K + HalfStep].Im := UIm - TmpIm;

        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflySinCosForward(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  Angle, S, C: Double;
  TmpRe, TmpIm, URe, UIm, VRe, VIm: Double;
begin
  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      for K := 0 to HalfStep - 1 do
      begin
        Angle := -CTwoPi * K / StepSize;
        SinCos(Angle, S, C);

        URe := Work[BlockStart + K].Re;
        UIm := Work[BlockStart + K].Im;
        VRe := Work[BlockStart + K + HalfStep].Re;
        VIm := Work[BlockStart + K + HalfStep].Im;

        TmpRe := VRe * C - VIm * S;
        TmpIm := VRe * S + VIm * C;

        Work[BlockStart + K].Re := URe + TmpRe;
        Work[BlockStart + K].Im := UIm + TmpIm;
        Work[BlockStart + K + HalfStep].Re := URe - TmpRe;
        Work[BlockStart + K + HalfStep].Im := UIm - TmpIm;
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflySinCosInverse(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  Angle, S, C: Double;
  TmpRe, TmpIm, URe, UIm, VRe, VIm: Double;
begin
  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      for K := 0 to HalfStep - 1 do
      begin
        Angle := CTwoPi * K / StepSize;
        SinCos(Angle, S, C);

        URe := Work[BlockStart + K].Re;
        UIm := Work[BlockStart + K].Im;
        VRe := Work[BlockStart + K + HalfStep].Re;
        VIm := Work[BlockStart + K + HalfStep].Im;

        TmpRe := VRe * C - VIm * S;
        TmpIm := VRe * S + VIm * C;

        Work[BlockStart + K].Re := URe + TmpRe;
        Work[BlockStart + K].Im := UIm + TmpIm;
        Work[BlockStart + K + HalfStep].Re := URe - TmpRe;
        Work[BlockStart + K + HalfStep].Im := UIm - TmpIm;
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflyPrecomputedForward(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  Tw: TComplex64;
  TmpRe, TmpIm, URe, UIm, VRe, VIm: Double;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        Tw := GActivePlan.FTwiddle[TwiddleIndex];

        URe := Work[BlockStart + K].Re;
        UIm := Work[BlockStart + K].Im;
        VRe := Work[BlockStart + K + HalfStep].Re;
        VIm := Work[BlockStart + K + HalfStep].Im;

        TmpRe := VRe * Tw.Re - VIm * Tw.Im;
        TmpIm := VRe * Tw.Im + VIm * Tw.Re;

        Work[BlockStart + K].Re := URe + TmpRe;
        Work[BlockStart + K].Im := UIm + TmpIm;
        Work[BlockStart + K + HalfStep].Re := URe - TmpRe;
        Work[BlockStart + K + HalfStep].Im := UIm - TmpIm;

        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflyPrecomputedInverse(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  Tw: TComplex64;
  TmpRe, TmpIm, URe, UIm, VRe, VIm: Double;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        Tw := GActivePlan.FTwiddle[TwiddleIndex];

        URe := Work[BlockStart + K].Re;
        UIm := Work[BlockStart + K].Im;
        VRe := Work[BlockStart + K + HalfStep].Re;
        VIm := Work[BlockStart + K + HalfStep].Im;

        TmpRe := VRe * Tw.Re + VIm * Tw.Im;
        TmpIm := VIm * Tw.Re - VRe * Tw.Im;

        Work[BlockStart + K].Re := URe + TmpRe;
        Work[BlockStart + K].Im := UIm + TmpIm;
        Work[BlockStart + K + HalfStep].Re := URe - TmpRe;
        Work[BlockStart + K + HalfStep].Im := UIm - TmpIm;

        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflyForwardInline(var U, V: TComplex64; const Tw: TComplex64); inline;
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

procedure ButterflyInverseInline(var U, V: TComplex64; const Tw: TComplex64); inline;
var
  TmpRe, TmpIm, URe, UIm: Double;
begin
  URe := U.Re;
  UIm := U.Im;
  TmpRe := V.Re * Tw.Re + V.Im * Tw.Im;
  TmpIm := V.Im * Tw.Re - V.Re * Tw.Im;
  U.Re := URe + TmpRe;
  U.Im := UIm + TmpIm;
  V.Re := URe - TmpRe;
  V.Im := UIm - TmpIm;
end;

procedure ButterflyPrecomputedForwardInline(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        ButterflyForwardInline(
          Work[BlockStart + K],
          Work[BlockStart + K + HalfStep],
          GActivePlan.FTwiddle[TwiddleIndex]);
        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflyPrecomputedInverseInline(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        ButterflyInverseInline(
          Work[BlockStart + K],
          Work[BlockStart + K + HalfStep],
          GActivePlan.FTwiddle[TwiddleIndex]);
        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflyPrecomputedForwardSse2(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  UPtr, VPtr, TwPtr: PComplex64;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        UPtr := @Work[BlockStart + K];
        VPtr := @Work[BlockStart + K + HalfStep];
        TwPtr := @GActivePlan.FTwiddle[TwiddleIndex];
        asm
          mov rax, UPtr
          mov rdx, VPtr
          mov r8, TwPtr

          movsd xmm4, [rax]
          movsd xmm5, [rax + 8]
          movsd xmm0, [rdx]
          movsd xmm1, [rdx + 8]
          movsd xmm2, [r8]
          movsd xmm3, [r8 + 8]

          movapd xmm6, xmm0
          mulsd xmm6, xmm2
          movapd xmm7, xmm1
          mulsd xmm7, xmm3
          subsd xmm6, xmm7

          mulsd xmm0, xmm3
          mulsd xmm1, xmm2
          addsd xmm0, xmm1

          movapd xmm1, xmm4
          addsd xmm1, xmm6
          movsd [rax], xmm1
          movapd xmm1, xmm5
          addsd xmm1, xmm0
          movsd [rax + 8], xmm1

          subsd xmm4, xmm6
          subsd xmm5, xmm0
          movsd [rdx], xmm4
          movsd [rdx + 8], xmm5
        end;
        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflyPrecomputedInverseSse2(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  UPtr, VPtr, TwPtr: PComplex64;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        UPtr := @Work[BlockStart + K];
        VPtr := @Work[BlockStart + K + HalfStep];
        TwPtr := @GActivePlan.FTwiddle[TwiddleIndex];
        asm
          mov rax, UPtr
          mov rdx, VPtr
          mov r8, TwPtr

          movsd xmm4, [rax]
          movsd xmm5, [rax + 8]
          movsd xmm0, [rdx]
          movsd xmm1, [rdx + 8]
          movsd xmm2, [r8]
          movsd xmm3, [r8 + 8]

          movapd xmm6, xmm0
          mulsd xmm6, xmm2
          movapd xmm7, xmm1
          mulsd xmm7, xmm3
          addsd xmm6, xmm7

          mulsd xmm1, xmm2
          mulsd xmm0, xmm3
          subsd xmm1, xmm0

          movapd xmm0, xmm4
          addsd xmm0, xmm6
          movsd [rax], xmm0
          movapd xmm0, xmm5
          addsd xmm0, xmm1
          movsd [rax + 8], xmm0

          subsd xmm4, xmm6
          subsd xmm5, xmm1
          movsd [rdx], xmm4
          movsd [rdx + 8], xmm5
        end;
        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
end;

procedure ButterflyPrecomputedForwardAvx(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  UPtr, VPtr, TwPtr: PComplex64;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        UPtr := @Work[BlockStart + K];
        VPtr := @Work[BlockStart + K + HalfStep];
        TwPtr := @GActivePlan.FTwiddle[TwiddleIndex];
        asm
          mov rax, UPtr
          mov rdx, VPtr
          mov r8, TwPtr

          vmovsd xmm4, [rax]
          vmovsd xmm5, [rax + 8]
          vmovsd xmm0, [rdx]
          vmovsd xmm1, [rdx + 8]
          vmovsd xmm2, [r8]
          vmovsd xmm3, [r8 + 8]

          vmulsd xmm6, xmm0, xmm2
          vmulsd xmm7, xmm1, xmm3
          vsubsd xmm6, xmm6, xmm7

          vmulsd xmm0, xmm0, xmm3
          vmulsd xmm1, xmm1, xmm2
          vaddsd xmm0, xmm0, xmm1

          vaddsd xmm1, xmm4, xmm6
          vmovsd [rax], xmm1
          vaddsd xmm1, xmm5, xmm0
          vmovsd [rax + 8], xmm1

          vsubsd xmm4, xmm4, xmm6
          vsubsd xmm5, xmm5, xmm0
          vmovsd [rdx], xmm4
          vmovsd [rdx + 8], xmm5
        end;
        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
  asm
    vzeroupper
  end;
end;

procedure ButterflyPrecomputedInverseAvx(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  UPtr, VPtr, TwPtr: PComplex64;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      for K := 0 to HalfStep - 1 do
      begin
        UPtr := @Work[BlockStart + K];
        VPtr := @Work[BlockStart + K + HalfStep];
        TwPtr := @GActivePlan.FTwiddle[TwiddleIndex];
        asm
          mov rax, UPtr
          mov rdx, VPtr
          mov r8, TwPtr

          vmovsd xmm4, [rax]
          vmovsd xmm5, [rax + 8]
          vmovsd xmm0, [rdx]
          vmovsd xmm1, [rdx + 8]
          vmovsd xmm2, [r8]
          vmovsd xmm3, [r8 + 8]

          vmulsd xmm6, xmm0, xmm2
          vmulsd xmm7, xmm1, xmm3
          vaddsd xmm6, xmm6, xmm7

          vmulsd xmm1, xmm1, xmm2
          vmulsd xmm0, xmm0, xmm3
          vsubsd xmm1, xmm1, xmm0

          vaddsd xmm0, xmm4, xmm6
          vmovsd [rax], xmm0
          vaddsd xmm0, xmm5, xmm1
          vmovsd [rax + 8], xmm0

          vsubsd xmm4, xmm4, xmm6
          vsubsd xmm5, xmm5, xmm1
          vmovsd [rdx], xmm4
          vmovsd [rdx + 8], xmm5
        end;
        Inc(TwiddleIndex, TwiddleStep);
      end;
      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
  asm
    vzeroupper
  end;
end;

procedure ButterflyPrecomputedForwardAvxVector2(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  UPtr, VPtr, Tw0Ptr, Tw1Ptr: PComplex64;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      K := 0;
      while K + 1 < HalfStep do
      begin
        UPtr := @Work[BlockStart + K];
        VPtr := @Work[BlockStart + K + HalfStep];
        Tw0Ptr := @GActivePlan.FTwiddle[TwiddleIndex];
        Tw1Ptr := @GActivePlan.FTwiddle[TwiddleIndex + TwiddleStep];
        asm
          mov rax, UPtr
          mov rdx, VPtr
          mov r8, Tw0Ptr
          mov r9, Tw1Ptr

          vmovupd ymm0, [rax]             // U0.re,U0.im,U1.re,U1.im
          vmovupd ymm1, [rdx]             // V0.re,V0.im,V1.re,V1.im
          vmovupd xmm2, [r8]              // Tw0.re,Tw0.im
          vinsertf128 ymm2, ymm2, [r9], 1 // Tw0.re,Tw0.im,Tw1.re,Tw1.im

          vpermilpd ymm3, ymm1, 0         // V.re,V.re
          vpermilpd ymm4, ymm1, 15        // V.im,V.im
          vpermilpd ymm5, ymm2, 5         // Tw.im,Tw.re
          vmulpd ymm3, ymm3, ymm2         // V.re*Tw.re, V.re*Tw.im
          vmulpd ymm4, ymm4, ymm5         // V.im*Tw.im, V.im*Tw.re
          vaddsubpd ymm3, ymm3, ymm4      // tmp.re,tmp.im

          vaddpd ymm4, ymm0, ymm3
          vsubpd ymm5, ymm0, ymm3
          vmovupd [rax], ymm4
          vmovupd [rdx], ymm5
        end;
        Inc(K, 2);
        Inc(TwiddleIndex, TwiddleStep * 2);
      end;

      while K < HalfStep do
      begin
        ButterflyForwardInline(
          Work[BlockStart + K],
          Work[BlockStart + K + HalfStep],
          GActivePlan.FTwiddle[TwiddleIndex]);
        Inc(K);
        Inc(TwiddleIndex, TwiddleStep);
      end;

      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
  asm
    vzeroupper
  end;
end;

procedure ButterflyPrecomputedInverseAvxVector2(Work: PComplex64; Count: SizeInt);
var
  StepSize, HalfStep, BlockStart, K: SizeInt;
  TwiddleStep, TwiddleIndex: SizeInt;
  UPtr, VPtr, Tw0Ptr, Tw1Ptr: PComplex64;
begin
  if (GActivePlan = nil) or (GActivePlan.Size <> Count) then
    raise Exception.Create('Active FFT plan is not initialized for this size');

  StepSize := 2;
  while StepSize <= Count do
  begin
    HalfStep := StepSize div 2;
    TwiddleStep := Count div StepSize;
    BlockStart := 0;
    while BlockStart < Count do
    begin
      TwiddleIndex := 0;
      K := 0;
      while K + 1 < HalfStep do
      begin
        UPtr := @Work[BlockStart + K];
        VPtr := @Work[BlockStart + K + HalfStep];
        Tw0Ptr := @GActivePlan.FTwiddle[TwiddleIndex];
        Tw1Ptr := @GActivePlan.FTwiddle[TwiddleIndex + TwiddleStep];
        asm
          mov rax, UPtr
          mov rdx, VPtr
          mov r8, Tw0Ptr
          mov r9, Tw1Ptr

          vmovupd ymm0, [rax]             // U0.re,U0.im,U1.re,U1.im
          vmovupd ymm1, [rdx]             // V0.re,V0.im,V1.re,V1.im
          vmovupd xmm2, [r8]              // Tw0.re,Tw0.im
          vinsertf128 ymm2, ymm2, [r9], 1 // Tw0.re,Tw0.im,Tw1.re,Tw1.im

          vpermilpd ymm3, ymm1, 0         // V.re,V.re
          vpermilpd ymm4, ymm1, 15        // V.im,V.im
          vpermilpd ymm5, ymm2, 5         // Tw.im,Tw.re
          vmulpd ymm3, ymm3, ymm2         // V.re*Tw.re, V.re*Tw.im
          vmulpd ymm4, ymm4, ymm5         // V.im*Tw.im, V.im*Tw.re
          vaddpd ymm5, ymm3, ymm4         // inverse re in even lanes
          vsubpd ymm6, ymm4, ymm3         // inverse im in odd lanes
          vblendpd ymm3, ymm5, ymm6, 10   // tmp.re,tmp.im

          vaddpd ymm4, ymm0, ymm3
          vsubpd ymm5, ymm0, ymm3
          vmovupd [rax], ymm4
          vmovupd [rdx], ymm5
        end;
        Inc(K, 2);
        Inc(TwiddleIndex, TwiddleStep * 2);
      end;

      while K < HalfStep do
      begin
        ButterflyInverseInline(
          Work[BlockStart + K],
          Work[BlockStart + K + HalfStep],
          GActivePlan.FTwiddle[TwiddleIndex]);
        Inc(K);
        Inc(TwiddleIndex, TwiddleStep);
      end;

      Inc(BlockStart, StepSize);
    end;
    StepSize := StepSize shl 1;
  end;
  asm
    vzeroupper
  end;
end;

procedure MagnitudeRms(Input: PComplex64; Output: PDouble; Count: SizeInt);
var
  I: SizeInt;
  Scale: Double;
begin
  Scale := 2.0 / Count;
  for I := 0 to (Count div 2) - 1 do
    Output[I] := Sqrt(Sqr(Input[I].Re) + Sqr(Input[I].Im)) * Scale / Sqrt(2.0);
end;

procedure MagnitudeRmsSse3(Input: PComplex64; Output: PDouble; Count: SizeInt; Scale: PDouble); assembler;
asm
  mov rax, Input
  mov rdx, Output
  mov rcx, Count
  shr rcx, 1
  test rcx, rcx
  jz @done

  mov r8, Scale
  movsd xmm3, [r8]

@loop:
  movupd xmm0, [rax]
  mulpd xmm0, xmm0
  haddpd xmm0, xmm0
  sqrtsd xmm0, xmm0
  mulsd xmm0, xmm3
  movsd [rdx], xmm0
  add rax, 16
  add rdx, 8
  dec rcx
  jnz @loop

@done:
end;

procedure MagnitudeRmsAvx(Input: PComplex64; Output: PDouble; Count: SizeInt; Scale: PDouble); assembler;
asm
  mov rax, Input
  mov rdx, Output
  mov rcx, Count
  shr rcx, 2
  test rcx, rcx
  jz @done

  mov r8, Scale
  movsd xmm3, [r8]
  vunpcklpd xmm3, xmm3, xmm3
  vinsertf128 ymm3, ymm3, xmm3, 1

@loop:
  vmovupd ymm0, [rax]
  vmulpd ymm0, ymm0, ymm0
  vhaddpd ymm0, ymm0, ymm0
  vsqrtpd ymm0, ymm0
  vmulpd ymm0, ymm0, ymm3
  vextractf128 xmm1, ymm0, 1
  vmovsd [rdx], xmm0
  vmovsd [rdx + 8], xmm1
  add rax, 32
  add rdx, 16
  dec rcx
  jnz @loop

@done:
  vzeroupper
end;

procedure SpectrumPipelineFftPascal(Input: PDouble; Work: PComplex64; Magnitude: PDouble; Count: SizeInt);
begin
  SpectrumFftIterativePascal(Input, Work, Count);
  MagnitudeRms(Work, Magnitude, Count);
end;

procedure SpectrumPipelineFftSse3(Input: PDouble; Work: PComplex64; Magnitude: PDouble; Count: SizeInt);
var
  Scale: Double;
begin
  SpectrumFftIterativePascal(Input, Work, Count);
  Scale := CSqrt2 / Count;
  MagnitudeRmsSse3(Work, Magnitude, Count, @Scale);
end;

procedure SpectrumPipelineFftAvx(Input: PDouble; Work: PComplex64; Magnitude: PDouble; Count: SizeInt);
var
  Scale: Double;
begin
  SpectrumFftIterativePascal(Input, Work, Count);
  Scale := CSqrt2 / Count;
  MagnitudeRmsAvx(Work, Magnitude, Count, @Scale);
end;

procedure SpectrumPipelinePrecomputedPascal(Input: PDouble; Work: PComplex64; Magnitude: PDouble; Count: SizeInt);
begin
  SpectrumFftPrecomputedPascal(Input, Work, Count);
  MagnitudeRms(Work, Magnitude, Count);
end;

procedure SpectrumPipelinePrecomputedAvx(Input: PDouble; Work: PComplex64; Magnitude: PDouble; Count: SizeInt);
var
  Scale: Double;
begin
  SpectrumFftPrecomputedPascal(Input, Work, Count);
  Scale := CSqrt2 / Count;
  MagnitudeRmsAvx(Work, Magnitude, Count, @Scale);
end;

procedure FftOnlyPrecomputedPascal(Input: PDouble; Output: PComplex64; Count: SizeInt);
begin
  PrepareBitReversedReal(Input, Output, Count);
  ButterflyPrecomputedForward(Output, Count);
end;

procedure FftOnlyPrecomputedInline(Input: PDouble; Output: PComplex64; Count: SizeInt);
begin
  PrepareBitReversedReal(Input, Output, Count);
  ButterflyPrecomputedForwardInline(Output, Count);
end;

procedure FftOnlyPrecomputedSse2(Input: PDouble; Output: PComplex64; Count: SizeInt);
begin
  PrepareBitReversedReal(Input, Output, Count);
  ButterflyPrecomputedForwardSse2(Output, Count);
end;

procedure FftOnlyPrecomputedAvx(Input: PDouble; Output: PComplex64; Count: SizeInt);
begin
  PrepareBitReversedReal(Input, Output, Count);
  ButterflyPrecomputedForwardAvx(Output, Count);
end;

procedure FftOnlyPrecomputedAvxVector2(Input: PDouble; Output: PComplex64; Count: SizeInt);
begin
  PrepareBitReversedReal(Input, Output, Count);
  ButterflyPrecomputedForwardAvxVector2(Output, Count);
end;

function MaxAbsDiff(A, B: PDouble; Count: SizeInt): Double;
var
  I: SizeInt;
  D: Double;
begin
  Result := 0.0;
  for I := 0 to Count - 1 do
  begin
    D := Abs(A[I] - B[I]);
    if D > Result then
      Result := D;
  end;
end;

function MaxComplexDiff(A, B: PComplex64; Count: SizeInt): Double;
var
  I: SizeInt;
  D: Double;
begin
  Result := 0.0;
  for I := 0 to Count - 1 do
  begin
    D := Abs(A[I].Re - B[I].Re);
    if D > Result then
      Result := D;
    D := Abs(A[I].Im - B[I].Im);
    if D > Result then
      Result := D;
  end;
end;

function NowMicroseconds: Int64;
{$IFDEF WINDOWS}
var
  Counter: TLargeInteger;
  Frequency: TLargeInteger;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  Counter := 0;
  Frequency := 1;
  QueryPerformanceCounter(Counter);
  QueryPerformanceFrequency(Frequency);
  Result := Round(Counter * 1000000.0 / Frequency);
  {$ELSE}
  Result := Int64(GetTickCount64) * 1000;
  {$ENDIF}
end;

function LogicalCpuCount: SizeInt;
{$IFDEF WINDOWS}
var
  Info: TSystemInfo;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  GetSystemInfo(Info);
  Result := Info.dwNumberOfProcessors;
  {$ELSE}
  Result := 1;
  {$ENDIF}
  if Result < 1 then
    Result := 1;
end;

function BenchmarkComplexCopy(Src, Dst: PComplex64; Count, Iterations: SizeInt): Double;
var
  I: SizeInt;
  StartTick, FinishTick: Int64;
begin
  CopyComplex(Src, Dst, Count);
  StartTick := NowMicroseconds;
  for I := 1 to Iterations do
    CopyComplex(Src, Dst, Count);
  FinishTick := NowMicroseconds;
  Result := (FinishTick - StartTick) / Iterations;
end;

function BenchmarkButterfly(AProc: TButterflyProc; Seed, Work: PComplex64;
  Count, Iterations: SizeInt; CopyUs: Double): Double;
var
  I: SizeInt;
  StartTick, FinishTick: Int64;
  RawUs: Double;
begin
  CopyComplex(Seed, Work, Count);
  AProc(Work, Count);

  StartTick := NowMicroseconds;
  for I := 1 to Iterations do
  begin
    CopyComplex(Seed, Work, Count);
    AProc(Work, Count);
  end;
  FinishTick := NowMicroseconds;
  RawUs := (FinishTick - StartTick) / Iterations;
  Result := RawUs - CopyUs;
  if Result < 0.0 then
    Result := 0.0;
end;

function BenchmarkBackend(AProc: TSpectrumBackendProc; Input: PDouble; Output: PComplex64;
  Count, Iterations: SizeInt): Double;
var
  I: SizeInt;
  StartTick, FinishTick: Int64;
begin
  AProc(Input, Output, Count);
  StartTick := NowMicroseconds;
  for I := 1 to Iterations do
    AProc(Input, Output, Count);
  FinishTick := NowMicroseconds;
  Result := (FinishTick - StartTick) / Iterations;
end;

function BenchmarkPipeline(AProc: TSpectrumPipelineProc; Input: PDouble; Work: PComplex64;
  Magnitude: PDouble; Count, Iterations: SizeInt): Double;
var
  I: SizeInt;
  StartTick, FinishTick: Int64;
begin
  AProc(Input, Work, Magnitude, Count);
  StartTick := NowMicroseconds;
  for I := 1 to Iterations do
    AProc(Input, Work, Magnitude, Count);
  FinishTick := NowMicroseconds;
  Result := (FinishTick - StartTick) / Iterations;
end;

function BenchmarkFftOnly(AProc: TFftOnlyProc; Input: PDouble; Output: PComplex64;
  Count, Iterations: SizeInt): Double;
var
  I: SizeInt;
  StartTick, FinishTick: Int64;
begin
  AProc(Input, Output, Count);
  StartTick := NowMicroseconds;
  for I := 1 to Iterations do
    AProc(Input, Output, Count);
  FinishTick := NowMicroseconds;
  Result := (FinishTick - StartTick) / Iterations;
end;

function BenchmarkBatchSingle(const Inputs: TDoubleBufferArray; const Outputs: TComplexBufferArray;
  BatchCount, FFTSize, Iterations: SizeInt): Double;
var
  Iter: SizeInt;
  I: SizeInt;
  StartTick, FinishTick: Int64;
begin
  StartTick := NowMicroseconds;
  for Iter := 1 to Iterations do
    for I := 0 to BatchCount - 1 do
      FftOnlyPrecomputedInline(Inputs[I].Data, Outputs[I].Data, FFTSize);
  FinishTick := NowMicroseconds;
  Result := (FinishTick - StartTick) / Iterations;
end;

function BenchmarkBatchParallel(const Inputs: TDoubleBufferArray; const Outputs: TComplexBufferArray;
  BatchCount, FFTSize, Iterations, WorkerCount: SizeInt): Double;
var
  Workers: TBatchWorkerArray;
  I: SizeInt;
  StartIndex: SizeInt;
  EndIndex: SizeInt;
  StartTick, FinishTick: Int64;
begin
  if WorkerCount > BatchCount then
    WorkerCount := BatchCount;
  if WorkerCount < 1 then
    WorkerCount := 1;

  SetLength(Workers, WorkerCount);
  for I := 0 to WorkerCount - 1 do
  begin
    StartIndex := (BatchCount * I) div WorkerCount;
    EndIndex := (BatchCount * (I + 1)) div WorkerCount;
    Workers[I] := TBatchFftWorker.Create(Inputs, Outputs, StartIndex, EndIndex, Iterations, FFTSize);
  end;

  StartTick := NowMicroseconds;
  for I := 0 to WorkerCount - 1 do
    Workers[I].Start;
  for I := 0 to WorkerCount - 1 do
    Workers[I].WaitFor;
  FinishTick := NowMicroseconds;

  for I := 0 to WorkerCount - 1 do
    Workers[I].Free;

  Result := (FinishTick - StartTick) / Iterations;
end;

function BenchmarkBatchThreadPool(const Inputs: TDoubleBufferArray; const Outputs: TComplexBufferArray;
  BatchCount, FFTSize, Iterations, WorkerCount: SizeInt): Double;
var
  Workers: TPersistentWorkerArray;
  I: SizeInt;
  Iter: SizeInt;
  StartIndex: SizeInt;
  EndIndex: SizeInt;
  StartTick, FinishTick: Int64;
begin
  if WorkerCount > BatchCount then
    WorkerCount := BatchCount;
  if WorkerCount < 1 then
    WorkerCount := 1;

  SetLength(Workers, WorkerCount);
  for I := 0 to WorkerCount - 1 do
  begin
    StartIndex := (BatchCount * I) div WorkerCount;
    EndIndex := (BatchCount * (I + 1)) div WorkerCount;
    Workers[I] := TPersistentFftWorker.Create;
    Workers[I].AssignTask(Inputs, Outputs, StartIndex, EndIndex, FFTSize);
  end;

  StartTick := NowMicroseconds;
  for Iter := 1 to Iterations do
  begin
    for I := 0 to WorkerCount - 1 do
      Workers[I].RunTask;
    for I := 0 to WorkerCount - 1 do
      Workers[I].WaitDone;
  end;
  FinishTick := NowMicroseconds;

  for I := 0 to WorkerCount - 1 do
    Workers[I].Free;

  Result := (FinishTick - StartTick) / Iterations;
end;

function BenchmarkBatchCreateThreadsPerTick(const Inputs: TDoubleBufferArray; const Outputs: TComplexBufferArray;
  BatchCount, FFTSize, Iterations, WorkerCount: SizeInt): Double;
var
  Workers: TBatchWorkerArray;
  Iter: SizeInt;
  I: SizeInt;
  StartIndex: SizeInt;
  EndIndex: SizeInt;
  StartTick, FinishTick: Int64;
begin
  if WorkerCount > BatchCount then
    WorkerCount := BatchCount;
  if WorkerCount < 1 then
    WorkerCount := 1;

  StartTick := NowMicroseconds;
  for Iter := 1 to Iterations do
  begin
    SetLength(Workers, WorkerCount);
    for I := 0 to WorkerCount - 1 do
    begin
      StartIndex := (BatchCount * I) div WorkerCount;
      EndIndex := (BatchCount * (I + 1)) div WorkerCount;
      Workers[I] := TBatchFftWorker.Create(Inputs, Outputs, StartIndex, EndIndex, 1, FFTSize);
    end;
    for I := 0 to WorkerCount - 1 do
      Workers[I].Start;
    for I := 0 to WorkerCount - 1 do
      Workers[I].WaitFor;
    for I := 0 to WorkerCount - 1 do
      Workers[I].Free;
  end;
  FinishTick := NowMicroseconds;

  Result := (FinishTick - StartTick) / Iterations;
end;

procedure RunOneSize(ALog: TLogWriter; ASize: SizeInt; ARunDft: Boolean);
var
  Signal: TAlignedDoubleBuffer;
  Windowed: TAlignedDoubleBuffer;
  DftOut: TAlignedComplexBuffer;
  ChampionWork: TAlignedComplexBuffer;
  SseWork: TAlignedComplexBuffer;
  AvxWork: TAlignedComplexBuffer;
  PreWork: TAlignedComplexBuffer;
  PreAvxWork: TAlignedComplexBuffer;
  DftMag: TAlignedDoubleBuffer;
  ChampionMag: TAlignedDoubleBuffer;
  SseMag: TAlignedDoubleBuffer;
  AvxMag: TAlignedDoubleBuffer;
  PreMag: TAlignedDoubleBuffer;
  PreAvxMag: TAlignedDoubleBuffer;
  DftDiff: Double;
  SseDiff: Double;
  AvxDiff: Double;
  PreDiff: Double;
  PreAvxDiff: Double;
  DftUs: Double;
  ChampionUs: Double;
  SseUs: Double;
  AvxUs: Double;
  PreUs: Double;
  PreAvxUs: Double;
  Iterations: SizeInt;
  Plan: TFFTPlan;
begin
  Plan := TFFTPlan.Create(ASize);
  GActivePlan := Plan;
  Signal := TAlignedDoubleBuffer.Create(ASize);
  Windowed := TAlignedDoubleBuffer.Create(ASize);
  DftOut := TAlignedComplexBuffer.Create(ASize);
  ChampionWork := TAlignedComplexBuffer.Create(ASize);
  SseWork := TAlignedComplexBuffer.Create(ASize);
  AvxWork := TAlignedComplexBuffer.Create(ASize);
  PreWork := TAlignedComplexBuffer.Create(ASize);
  PreAvxWork := TAlignedComplexBuffer.Create(ASize);
  DftMag := TAlignedDoubleBuffer.Create(ASize div 2);
  ChampionMag := TAlignedDoubleBuffer.Create(ASize div 2);
  SseMag := TAlignedDoubleBuffer.Create(ASize div 2);
  AvxMag := TAlignedDoubleBuffer.Create(ASize div 2);
  PreMag := TAlignedDoubleBuffer.Create(ASize div 2);
  PreAvxMag := TAlignedDoubleBuffer.Create(ASize div 2);
  try
    FillTestSignal(Signal.Data, ASize);
    ApplyHannWindow(Signal.Data, Windowed.Data, ASize);

    if ARunDft then
    begin
      SpectrumDftPascal(Windowed.Data, DftOut.Data, ASize);
      MagnitudeRms(DftOut.Data, DftMag.Data, ASize);
    end;

    SpectrumPipelineFftPascal(Windowed.Data, ChampionWork.Data, ChampionMag.Data, ASize);
    SpectrumPipelineFftSse3(Windowed.Data, SseWork.Data, SseMag.Data, ASize);
    SpectrumPipelineFftAvx(Windowed.Data, AvxWork.Data, AvxMag.Data, ASize);
    SpectrumPipelinePrecomputedPascal(Windowed.Data, PreWork.Data, PreMag.Data, ASize);
    SpectrumPipelinePrecomputedAvx(Windowed.Data, PreAvxWork.Data, PreAvxMag.Data, ASize);

    if ARunDft then
      DftDiff := MaxAbsDiff(DftMag.Data, ChampionMag.Data, ASize div 2)
    else
      DftDiff := 0.0;
    SseDiff := MaxAbsDiff(ChampionMag.Data, SseMag.Data, ASize div 2);
    AvxDiff := MaxAbsDiff(ChampionMag.Data, AvxMag.Data, ASize div 2);
    PreDiff := MaxAbsDiff(ChampionMag.Data, PreMag.Data, ASize div 2);
    PreAvxDiff := MaxAbsDiff(ChampionMag.Data, PreAvxMag.Data, ASize div 2);

    Iterations := CBenchIterations;
    if ASize >= 8192 then
      Iterations := CBenchIterations div 4;

    DftUs := -1.0;
    if ARunDft and (ASize <= 1024) then
      DftUs := BenchmarkBackend(@SpectrumDftPascal, Windowed.Data, DftOut.Data, ASize, Max(1, Iterations div 20));
    ChampionUs := BenchmarkPipeline(@SpectrumPipelineFftPascal, Windowed.Data, ChampionWork.Data, ChampionMag.Data, ASize, Iterations);
    SseUs := BenchmarkPipeline(@SpectrumPipelineFftSse3, Windowed.Data, SseWork.Data, SseMag.Data, ASize, Iterations);
    AvxUs := BenchmarkPipeline(@SpectrumPipelineFftAvx, Windowed.Data, AvxWork.Data, AvxMag.Data, ASize, Iterations);
    PreUs := BenchmarkPipeline(@SpectrumPipelinePrecomputedPascal, Windowed.Data, PreWork.Data, PreMag.Data, ASize, Iterations);
    PreAvxUs := BenchmarkPipeline(@SpectrumPipelinePrecomputedAvx, Windowed.Data, PreAvxWork.Data, PreAvxMag.Data, ASize, Iterations);

    ALog.Line(Format('Size=%d AlignmentIn=%d AlignmentChampion=%d AlignmentSSE=%d AlignmentAVX=%d AlignmentPre=%d AlignmentPreAVX=%d DftDiff=%.12g SseDiff=%.12g AvxDiff=%.12g PreDiff=%.12g PreAvxDiff=%.12g Tolerance=%.3g',
      [ASize, PtrUInt(Windowed.Data) mod CAlignment, PtrUInt(ChampionWork.Data) mod CAlignment,
       PtrUInt(SseWork.Data) mod CAlignment, PtrUInt(AvxWork.Data) mod CAlignment,
       PtrUInt(PreWork.Data) mod CAlignment, PtrUInt(PreAvxWork.Data) mod CAlignment,
       DftDiff, SseDiff, AvxDiff, PreDiff, PreAvxDiff, CCompareTolerance]));
    if ARunDft and (DftUs > 0.0) then
      ALog.Line(Format('  Backend=DFT_Pascal Iterations=%d AvgUs=%.3f Correctness=%s',
        [Max(1, Iterations div 20), DftUs, BoolToStr(DftDiff <= CCompareTolerance, 'PASS', 'FAIL')]))
    else if ARunDft then
      ALog.Line(Format('  Backend=DFT_Pascal Iterations=1 AvgUs=NOT_BENCHED Correctness=%s',
        [BoolToStr(DftDiff <= CCompareTolerance, 'PASS', 'FAIL')]));
    ALog.Line(Format('  Backend=FFT_Iterative_Pascal Iterations=%d AvgUs=%.3f Correctness=%s Champion=YES',
      [Iterations, ChampionUs, BoolToStr((not ARunDft) or (DftDiff <= CCompareTolerance), 'PASS', 'FAIL')]));
    ALog.Line(Format('  Backend=FFT_Iterative_SSE3_RMS Iterations=%d AvgUs=%.3f DiffVsChampion=%.12g Correctness=%s RatioVsChampion=%.3fx',
      [Iterations, SseUs, SseDiff, BoolToStr(SseDiff <= CCompareTolerance, 'PASS', 'FAIL'), SseUs / ChampionUs]));
    ALog.Line(Format('  Backend=FFT_Iterative_AVX_RMS Iterations=%d AvgUs=%.3f DiffVsChampion=%.12g Correctness=%s RatioVsChampion=%.3fx',
      [Iterations, AvxUs, AvxDiff, BoolToStr(AvxDiff <= CCompareTolerance, 'PASS', 'FAIL'), AvxUs / ChampionUs]));
    ALog.Line(Format('  Backend=FFT_Precomputed_Pascal Iterations=%d AvgUs=%.3f DiffVsChampion=%.12g Correctness=%s RatioVsChampion=%.3fx',
      [Iterations, PreUs, PreDiff, BoolToStr(PreDiff <= CCompareTolerance, 'PASS', 'FAIL'), PreUs / ChampionUs]));
    ALog.Line(Format('  Backend=FFT_Precomputed_AVX_RMS Iterations=%d AvgUs=%.3f DiffVsChampion=%.12g Correctness=%s RatioVsChampion=%.3fx',
      [Iterations, PreAvxUs, PreAvxDiff, BoolToStr(PreAvxDiff <= CCompareTolerance, 'PASS', 'FAIL'), PreAvxUs / ChampionUs]));
    if (PreAvxUs < ChampionUs) and (PreAvxUs <= SseUs) and (PreAvxUs <= AvxUs) and (PreAvxUs <= PreUs) then
      ALog.Line('  Winner=FFT_Precomputed_AVX_RMS')
    else if (PreUs < ChampionUs) and (PreUs <= SseUs) and (PreUs <= AvxUs) then
      ALog.Line('  Winner=FFT_Precomputed_Pascal')
    else if (SseUs < ChampionUs) and (SseUs <= AvxUs) then
      ALog.Line('  Winner=FFT_Iterative_SSE3_RMS')
    else if (AvxUs < ChampionUs) and (AvxUs < SseUs) then
      ALog.Line('  Winner=FFT_Iterative_AVX_RMS')
    else
      ALog.Line('  Winner=FFT_Iterative_Pascal');
  finally
    PreAvxMag.Free;
    PreMag.Free;
    AvxMag.Free;
    SseMag.Free;
    ChampionMag.Free;
    DftMag.Free;
    PreAvxWork.Free;
    PreWork.Free;
    AvxWork.Free;
    SseWork.Free;
    ChampionWork.Free;
    DftOut.Free;
    Windowed.Free;
    Signal.Free;
    GActivePlan := nil;
    Plan.Free;
  end;
end;

procedure RunButterflySize(ALog: TLogWriter; ASize: SizeInt);
var
  Plan: TFFTPlan;
  Signal: TAlignedDoubleBuffer;
  Windowed: TAlignedDoubleBuffer;
  Seed: TAlignedComplexBuffer;
  Ref: TAlignedComplexBuffer;
  Candidate: TAlignedComplexBuffer;
  Work: TAlignedComplexBuffer;
  Iterations: SizeInt;
  CopyUs: Double;
  SinCosForwardUs: Double;
  PreForwardUs: Double;
  SinCosInverseUs: Double;
  PreInverseUs: Double;
  ForwardDiff: Double;
  InverseDiff: Double;
begin
  Plan := TFFTPlan.Create(ASize);
  GActivePlan := Plan;
  Signal := TAlignedDoubleBuffer.Create(ASize);
  Windowed := TAlignedDoubleBuffer.Create(ASize);
  Seed := TAlignedComplexBuffer.Create(ASize);
  Ref := TAlignedComplexBuffer.Create(ASize);
  Candidate := TAlignedComplexBuffer.Create(ASize);
  Work := TAlignedComplexBuffer.Create(ASize);
  try
    FillTestSignal(Signal.Data, ASize);
    ApplyHannWindow(Signal.Data, Windowed.Data, ASize);
    PrepareBitReversedReal(Windowed.Data, Seed.Data, ASize);

    CopyComplex(Seed.Data, Ref.Data, ASize);
    ButterflySinCosForward(Ref.Data, ASize);
    CopyComplex(Seed.Data, Candidate.Data, ASize);
    ButterflyPrecomputedForward(Candidate.Data, ASize);
    ForwardDiff := MaxComplexDiff(Ref.Data, Candidate.Data, ASize);

    CopyComplex(Seed.Data, Ref.Data, ASize);
    ButterflySinCosInverse(Ref.Data, ASize);
    CopyComplex(Seed.Data, Candidate.Data, ASize);
    ButterflyPrecomputedInverse(Candidate.Data, ASize);
    InverseDiff := MaxComplexDiff(Ref.Data, Candidate.Data, ASize);

    if ASize <= 1024 then
      Iterations := 5000
    else if ASize <= 4096 then
      Iterations := 1000
    else
      Iterations := 300;

    CopyUs := BenchmarkComplexCopy(Seed.Data, Work.Data, ASize, Iterations);
    SinCosForwardUs := BenchmarkButterfly(@ButterflySinCosForward, Seed.Data, Work.Data, ASize, Iterations, CopyUs);
    PreForwardUs := BenchmarkButterfly(@ButterflyPrecomputedForward, Seed.Data, Work.Data, ASize, Iterations, CopyUs);
    SinCosInverseUs := BenchmarkButterfly(@ButterflySinCosInverse, Seed.Data, Work.Data, ASize, Iterations, CopyUs);
    PreInverseUs := BenchmarkButterfly(@ButterflyPrecomputedInverse, Seed.Data, Work.Data, ASize, Iterations, CopyUs);

    ALog.Line(Format('Butterfly Size=%d Iterations=%d CopyUs=%.3f ForwardDiff=%.12g InverseDiff=%.12g Tolerance=%.3g',
      [ASize, Iterations, CopyUs, ForwardDiff, InverseDiff, CCompareTolerance]));
    ALog.Line(Format('  Direction=Forward Backend=Butterfly_SinCos AvgUs=%.3f Correctness=REFERENCE', [SinCosForwardUs]));
    ALog.Line(Format('  Direction=Forward Backend=Butterfly_Precomputed AvgUs=%.3f DiffVsSinCos=%.12g Correctness=%s RatioVsSinCos=%.3fx',
      [PreForwardUs, ForwardDiff, BoolToStr(ForwardDiff <= CCompareTolerance, 'PASS', 'FAIL'), PreForwardUs / SinCosForwardUs]));
    if PreForwardUs < SinCosForwardUs then
      ALog.Line('  Direction=Forward Winner=Butterfly_Precomputed')
    else
      ALog.Line('  Direction=Forward Winner=Butterfly_SinCos');

    ALog.Line(Format('  Direction=Inverse Backend=Butterfly_SinCos AvgUs=%.3f Correctness=REFERENCE', [SinCosInverseUs]));
    ALog.Line(Format('  Direction=Inverse Backend=Butterfly_Precomputed AvgUs=%.3f DiffVsSinCos=%.12g Correctness=%s RatioVsSinCos=%.3fx',
      [PreInverseUs, InverseDiff, BoolToStr(InverseDiff <= CCompareTolerance, 'PASS', 'FAIL'), PreInverseUs / SinCosInverseUs]));
    if PreInverseUs < SinCosInverseUs then
      ALog.Line('  Direction=Inverse Winner=Butterfly_Precomputed')
    else
      ALog.Line('  Direction=Inverse Winner=Butterfly_SinCos');
  finally
    Work.Free;
    Candidate.Free;
    Ref.Free;
    Seed.Free;
    Windowed.Free;
    Signal.Free;
    GActivePlan := nil;
    Plan.Free;
  end;
end;

procedure RunFftOnlyTechSize(ALog: TLogWriter; ASize: SizeInt);
var
  Plan: TFFTPlan;
  Signal: TAlignedDoubleBuffer;
  Windowed: TAlignedDoubleBuffer;
  PascalOut: TAlignedComplexBuffer;
  InlineOut: TAlignedComplexBuffer;
  SseOut: TAlignedComplexBuffer;
  AvxOut: TAlignedComplexBuffer;
  AvxVecOut: TAlignedComplexBuffer;
  Iterations: SizeInt;
  PascalUs: Double;
  InlineUs: Double;
  SseUs: Double;
  AvxUs: Double;
  AvxVecUs: Double;
  InlineDiff: Double;
  SseDiff: Double;
  AvxDiff: Double;
  AvxVecDiff: Double;
begin
  Plan := TFFTPlan.Create(ASize);
  GActivePlan := Plan;
  Signal := TAlignedDoubleBuffer.Create(ASize);
  Windowed := TAlignedDoubleBuffer.Create(ASize);
  PascalOut := TAlignedComplexBuffer.Create(ASize);
  InlineOut := TAlignedComplexBuffer.Create(ASize);
  SseOut := TAlignedComplexBuffer.Create(ASize);
  AvxOut := TAlignedComplexBuffer.Create(ASize);
  AvxVecOut := TAlignedComplexBuffer.Create(ASize);
  try
    FillTestSignal(Signal.Data, ASize);
    ApplyHannWindow(Signal.Data, Windowed.Data, ASize);

    FftOnlyPrecomputedPascal(Windowed.Data, PascalOut.Data, ASize);
    FftOnlyPrecomputedInline(Windowed.Data, InlineOut.Data, ASize);
    FftOnlyPrecomputedSse2(Windowed.Data, SseOut.Data, ASize);
    FftOnlyPrecomputedAvx(Windowed.Data, AvxOut.Data, ASize);
    FftOnlyPrecomputedAvxVector2(Windowed.Data, AvxVecOut.Data, ASize);

    InlineDiff := MaxComplexDiff(PascalOut.Data, InlineOut.Data, ASize);
    SseDiff := MaxComplexDiff(PascalOut.Data, SseOut.Data, ASize);
    AvxDiff := MaxComplexDiff(PascalOut.Data, AvxOut.Data, ASize);
    AvxVecDiff := MaxComplexDiff(PascalOut.Data, AvxVecOut.Data, ASize);

    if ASize <= 1024 then
      Iterations := 5000
    else if ASize <= 4096 then
      Iterations := 1000
    else
      Iterations := 300;

    PascalUs := BenchmarkFftOnly(@FftOnlyPrecomputedPascal, Windowed.Data, PascalOut.Data, ASize, Iterations);
    InlineUs := BenchmarkFftOnly(@FftOnlyPrecomputedInline, Windowed.Data, InlineOut.Data, ASize, Iterations);
    SseUs := BenchmarkFftOnly(@FftOnlyPrecomputedSse2, Windowed.Data, SseOut.Data, ASize, Iterations);
    AvxUs := BenchmarkFftOnly(@FftOnlyPrecomputedAvx, Windowed.Data, AvxOut.Data, ASize, Iterations);
    AvxVecUs := BenchmarkFftOnly(@FftOnlyPrecomputedAvxVector2, Windowed.Data, AvxVecOut.Data, ASize, Iterations);

    ALog.Line(Format('FFTOnly Size=%d Iterations=%d InlineDiff=%.12g SseDiff=%.12g AvxDiff=%.12g AvxVecDiff=%.12g Tolerance=%.3g',
      [ASize, Iterations, InlineDiff, SseDiff, AvxDiff, AvxVecDiff, CCompareTolerance]));
    ALog.Line(Format('  Technology=Pascal_Precomputed AvgUs=%.3f Correctness=REFERENCE', [PascalUs]));
    ALog.Line(Format('  Technology=Pascal_Inline_Precomputed AvgUs=%.3f DiffVsPascal=%.12g Correctness=%s RatioVsPascal=%.3fx',
      [InlineUs, InlineDiff, BoolToStr(InlineDiff <= CCompareTolerance, 'PASS', 'FAIL'), InlineUs / PascalUs]));
    ALog.Line(Format('  Technology=SSE2_InlineAsm_Precomputed AvgUs=%.3f DiffVsPascal=%.12g Correctness=%s RatioVsPascal=%.3fx',
      [SseUs, SseDiff, BoolToStr(SseDiff <= CCompareTolerance, 'PASS', 'FAIL'), SseUs / PascalUs]));
    ALog.Line(Format('  Technology=AVX_InlineAsm_Precomputed AvgUs=%.3f DiffVsPascal=%.12g Correctness=%s RatioVsPascal=%.3fx',
      [AvxUs, AvxDiff, BoolToStr(AvxDiff <= CCompareTolerance, 'PASS', 'FAIL'), AvxUs / PascalUs]));
    ALog.Line(Format('  Technology=AVX_Vector2_InlineAsm_Precomputed AvgUs=%.3f DiffVsPascal=%.12g Correctness=%s RatioVsPascal=%.3fx RatioVsPascalInline=%.3fx',
      [AvxVecUs, AvxVecDiff, BoolToStr(AvxVecDiff <= CCompareTolerance, 'PASS', 'FAIL'), AvxVecUs / PascalUs, AvxVecUs / InlineUs]));

    if (InlineUs <= PascalUs) and (InlineUs <= SseUs) and (InlineUs <= AvxUs) and (InlineUs <= AvxVecUs) then
      ALog.Line('  Winner=Pascal_Inline_Precomputed')
    else if (SseUs <= PascalUs) and (SseUs <= InlineUs) and (SseUs <= AvxUs) and (SseUs <= AvxVecUs) then
      ALog.Line('  Winner=SSE2_InlineAsm_Precomputed')
    else if (AvxUs <= PascalUs) and (AvxUs <= InlineUs) and (AvxUs <= SseUs) and (AvxUs <= AvxVecUs) then
      ALog.Line('  Winner=AVX_InlineAsm_Precomputed')
    else if (AvxVecUs <= PascalUs) and (AvxVecUs <= InlineUs) and (AvxVecUs <= SseUs) and (AvxVecUs <= AvxUs) then
      ALog.Line('  Winner=AVX_Vector2_InlineAsm_Precomputed')
    else
      ALog.Line('  Winner=Pascal_Precomputed');
  finally
    AvxVecOut.Free;
    AvxOut.Free;
    SseOut.Free;
    InlineOut.Free;
    PascalOut.Free;
    Windowed.Free;
    Signal.Free;
    GActivePlan := nil;
    Plan.Free;
  end;
end;

procedure RunBatchFftSize(ALog: TLogWriter; ASize, ABatchCount: SizeInt);
var
  Plan: TFFTPlan;
  Inputs: TDoubleBufferArray;
  Outputs: TComplexBufferArray;
  I: SizeInt;
  Iterations: SizeInt;
  CpuCount: SizeInt;
  WorkerCount: SizeInt;
  SingleUs: Double;
  ParallelUs: Double;
  CreateTickUs: Double;
  PoolUs: Double;
  SingleUsPerSpectrum: Double;
  ParallelUsPerSpectrum: Double;
  CreateTickUsPerSpectrum: Double;
  PoolUsPerSpectrum: Double;
  SingleSpectraPerSec: Double;
  ParallelSpectraPerSec: Double;
  CreateTickSpectraPerSec: Double;
  PoolSpectraPerSec: Double;
begin
  Plan := TFFTPlan.Create(ASize);
  GActivePlan := Plan;
  SetLength(Inputs, ABatchCount);
  SetLength(Outputs, ABatchCount);
  try
    for I := 0 to ABatchCount - 1 do
    begin
      Inputs[I] := TAlignedDoubleBuffer.Create(ASize);
      Outputs[I] := TAlignedComplexBuffer.Create(ASize);
      FillTestSignal(Inputs[I].Data, ASize);
    end;

    if ASize <= 8192 then
      Iterations := CBatchIterations
    else
      Iterations := CBatchIterations div 2;
    if ABatchCount >= 64 then
      Iterations := Iterations div 2;
    if Iterations < 5 then
      Iterations := 5;

    CpuCount := LogicalCpuCount;
    WorkerCount := CpuCount;
    if WorkerCount > ABatchCount then
      WorkerCount := ABatchCount;
    if WorkerCount < 1 then
      WorkerCount := 1;

    SingleUs := BenchmarkBatchSingle(Inputs, Outputs, ABatchCount, ASize, Iterations);
    ParallelUs := BenchmarkBatchParallel(Inputs, Outputs, ABatchCount, ASize, Iterations, WorkerCount);
    CreateTickUs := BenchmarkBatchCreateThreadsPerTick(Inputs, Outputs, ABatchCount, ASize, Iterations, WorkerCount);
    PoolUs := BenchmarkBatchThreadPool(Inputs, Outputs, ABatchCount, ASize, Iterations, WorkerCount);

    SingleUsPerSpectrum := SingleUs / ABatchCount;
    ParallelUsPerSpectrum := ParallelUs / ABatchCount;
    CreateTickUsPerSpectrum := CreateTickUs / ABatchCount;
    PoolUsPerSpectrum := PoolUs / ABatchCount;
    SingleSpectraPerSec := 1000000.0 / SingleUsPerSpectrum;
    ParallelSpectraPerSec := 1000000.0 / ParallelUsPerSpectrum;
    CreateTickSpectraPerSec := 1000000.0 / CreateTickUsPerSpectrum;
    PoolSpectraPerSec := 1000000.0 / PoolUsPerSpectrum;

    ALog.Line(Format('BatchFFT Size=%d Batch=%d Iterations=%d Cpu=%d Workers=%d SingleBatchMs=%.3f SingleUsPerSpectrum=%.3f SingleSpectraPerSec=%.1f ParallelBulkBatchMs=%.3f ParallelBulkUsPerSpectrum=%.3f ParallelBulkSpectraPerSec=%.1f ParallelBulkSpeedup=%.3fx CreateTickBatchMs=%.3f CreateTickUsPerSpectrum=%.3f CreateTickSpectraPerSec=%.1f CreateTickSpeedup=%.3fx PoolTickBatchMs=%.3f PoolTickUsPerSpectrum=%.3f PoolTickSpectraPerSec=%.1f PoolTickSpeedup=%.3fx PoolVsCreateTick=%.3fx',
      [ASize, ABatchCount, Iterations, CpuCount, WorkerCount,
       SingleUs / 1000.0, SingleUsPerSpectrum, SingleSpectraPerSec,
       ParallelUs / 1000.0, ParallelUsPerSpectrum, ParallelSpectraPerSec,
       SingleUs / ParallelUs,
       CreateTickUs / 1000.0, CreateTickUsPerSpectrum, CreateTickSpectraPerSec,
       SingleUs / CreateTickUs,
       PoolUs / 1000.0, PoolUsPerSpectrum, PoolSpectraPerSec,
       SingleUs / PoolUs, CreateTickUs / PoolUs]));
  finally
    for I := 0 to High(Outputs) do
      Outputs[I].Free;
    for I := 0 to High(Inputs) do
      Inputs[I].Free;
    GActivePlan := nil;
    Plan.Free;
  end;
end;

procedure RunSpectrumMathBench;
var
  Log: TLogWriter;
begin
  Log := TLogWriter.Create;
  try
    Log.Line('RecorderLnx SpectrumMath benchmark');
    Log.Line('DateTime: ' + DateTimeToStr(Now));
    Log.Line('Compiler: FPC');
    Log.Line('PointerSize: ' + IntToStr(SizeOf(Pointer) * 8));
    Log.Line('Alignment: ' + IntToStr(CAlignment));
    Log.Line('Backends: DFT_Pascal, FFT_Iterative_Pascal, FFT_Iterative_SSE3_RMS, FFT_Iterative_AVX_RMS, FFT_Precomputed_Pascal, FFT_Precomputed_AVX_RMS');
    Log.Line('');

    RunOneSize(Log, 256, True);
    RunOneSize(Log, 512, True);
    RunOneSize(Log, 1024, True);
    RunOneSize(Log, 2048, True);
    RunOneSize(Log, 4096, True);
    RunOneSize(Log, 8192, True);

    Log.Line('');
    Log.Line('Butterfly-only benchmark');
    RunButterflySize(Log, 256);
    RunButterflySize(Log, 512);
    RunButterflySize(Log, 1024);
    RunButterflySize(Log, 2048);
    RunButterflySize(Log, 4096);
    RunButterflySize(Log, 8192);

    Log.Line('');
    Log.Line('FFT-only runtime benchmark');
    RunFftOnlyTechSize(Log, 256);
    RunFftOnlyTechSize(Log, 512);
    RunFftOnlyTechSize(Log, 1024);
    RunFftOnlyTechSize(Log, 2048);
    RunFftOnlyTechSize(Log, 4096);
    RunFftOnlyTechSize(Log, 8192);

    Log.Line('');
    Log.Line('Batch FFT runtime benchmark');
    RunBatchFftSize(Log, 8192, 1);
    RunBatchFftSize(Log, 8192, 8);
    RunBatchFftSize(Log, 8192, 16);
    RunBatchFftSize(Log, 8192, 32);
    RunBatchFftSize(Log, 8192, 64);
    RunBatchFftSize(Log, 8192, 128);
    RunBatchFftSize(Log, 16384, 1);
    RunBatchFftSize(Log, 16384, 8);
    RunBatchFftSize(Log, 16384, 16);
    RunBatchFftSize(Log, 16384, 32);
    RunBatchFftSize(Log, 16384, 64);
    RunBatchFftSize(Log, 16384, 128);
  finally
    Log.Free;
  end;
end;

end.
