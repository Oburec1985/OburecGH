unit uRecorderSpectrumEngine;

{
  RecorderLnx FFT runtime engine.

  The unit deliberately has no LCL/UI dependencies. The settings dialog can edit
  TRecorderSpectrumConfigTree, while the runtime code receives already resolved
  tag bindings and feeds TRecorderSpectrumChannel with driver blocks.
}

{$mode objfpc}{$H+}
{$codepage UTF8}
{$modeswitch advancedrecords}
{$pointermath on}
{$asmmode intel}

interface

uses
  Classes, SysUtils, Math, SyncObjs
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

type
  ERecorderSpectrumError = class(Exception);

  TRecorderSpectrumWindowKind = (
    swkRect,
    swkHann,
    swkHamming,
    swkBlackman,
    swkFlatTop
  );

  TRecorderSpectrumNormalizeMode = (
    snmNone,
    snmMax,
    snmEnergy
  );

  TRecorderSpectrumOverlapMode = (
    somNone,
    somHalf,
    somQuarter
  );

  TRecorderSpectrumIntegrationMode = (
    simNone,
    simSingle,
    simDouble
  );

  TRecorderSpectrumComplex = packed record
    Re: Double;
    Im: Double;
  end;

  PRecorderSpectrumComplex = ^TRecorderSpectrumComplex;
  TRecorderSpectrumFFTPlan = class;
  TRecorderSpectrumForwardProc = procedure(AWork: PRecorderSpectrumComplex;
    APlan: TRecorderSpectrumFFTPlan);

  TRecorderSpectrumSettings = record
    FFTSize: Integer;
    Overlap: Integer;
    OverlapMode: TRecorderSpectrumOverlapMode;
    SampleRateHz: Double;
    AverageBlockCount: Integer;
    ZeroPad: Boolean;
    AhCorrectionEnabled: Boolean;
    AhCorrectionProfileName: string;
    IntegrationMode: TRecorderSpectrumIntegrationMode;
    WindowKind: TRecorderSpectrumWindowKind;
    NormalizeMode: TRecorderSpectrumNormalizeMode;
    KeepPhase: Boolean;
    procedure SetDefaults;
    procedure Validate;
    function HopSize: Integer;
    function FrequencyStepHz: Double;
    function AsString: string;
    procedure FromString(const AValue: string);
  end;

  { A child tag binding inherits the parent settings unless UseOwnSettings is
    enabled. This mirrors plgControlCyclogram style: edit one parent node and the
    same FFT plan immediately applies to all child tags. }
  TRecorderSpectrumTagBinding = class
  private
    fOutputPrefix: string;
    fSettings: TRecorderSpectrumSettings;
    fSourceTagName: string;
    fUseOwnSettings: Boolean;
  public
    constructor Create(const ASourceTagName: string);
    procedure Assign(ASource: TRecorderSpectrumTagBinding);
    function ResolveSettings(const AParent: TRecorderSpectrumSettings): TRecorderSpectrumSettings;
    property SourceTagName: string read fSourceTagName write fSourceTagName;
    property OutputPrefix: string read fOutputPrefix write fOutputPrefix;
    property UseOwnSettings: Boolean read fUseOwnSettings write fUseOwnSettings;
    property Settings: TRecorderSpectrumSettings read fSettings write fSettings;
  end;

  TRecorderSpectrumConfigNode = class
  private
    fBindings: TList;
    fDisplayName: string;
    fId: string;
    fSettings: TRecorderSpectrumSettings;
    function GetBinding(AIndex: Integer): TRecorderSpectrumTagBinding;
    function GetBindingCount: Integer;
  public
    constructor Create(const AId, ADisplayName: string);
    destructor Destroy; override;
    function AddBinding(const ASourceTagName: string): TRecorderSpectrumTagBinding;
    procedure DeleteBinding(AIndex: Integer);
    procedure ClearBindings;
    procedure Assign(ASource: TRecorderSpectrumConfigNode);
    property Id: string read fId write fId;
    property DisplayName: string read fDisplayName write fDisplayName;
    property Settings: TRecorderSpectrumSettings read fSettings write fSettings;
    property BindingCount: Integer read GetBindingCount;
    property Bindings[AIndex: Integer]: TRecorderSpectrumTagBinding read GetBinding;
  end;

  TRecorderSpectrumConfigTree = class
  private
    fNodes: TList;
    function GetNode(AIndex: Integer): TRecorderSpectrumConfigNode;
    function GetNodeCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AddNode(const AId, ADisplayName: string): TRecorderSpectrumConfigNode;
    procedure DeleteNode(AIndex: Integer);
    function FindNode(const AId: string): TRecorderSpectrumConfigNode;
    procedure Clear;
    procedure Assign(ASource: TRecorderSpectrumConfigTree);
    property NodeCount: Integer read GetNodeCount;
    property Nodes[AIndex: Integer]: TRecorderSpectrumConfigNode read GetNode;
  end;

  TRecorderSpectrumBandResult = record
    BandName: string;
    F1: Double;
    F2: Double;
    Rms: Double;
    MaxRms: Double;
    MaxFrequencyHz: Double;
  end;

  TRecorderSpectrumFrame = record
    SourceTagName: string;
    FrameIndex: Int64;
    StartTimeSec: Double;
    EndTimeSec: Double;
    SampleRateHz: Double;
    FFTSize: Integer;
    Bins: Integer;
    FrequencyStepHz: Double;
    Rms: array of Double;
    PhaseRad: array of Double;
    Bands: array of TRecorderSpectrumBandResult;
    MaxIndex: Integer;
    MaxFrequencyHz: Double;
    MaxRms: Double;
  end;

  TRecorderSpectrumFrameEvent = procedure(ASender: TObject;
    const AFrame: TRecorderSpectrumFrame) of object;

  TRecorderSpectrumFFTPlan = class
  private
    fBackendName: string;
    fBitReverse: array of Integer;
    fBits: Integer;
    fForwardProc: TRecorderSpectrumForwardProc;
    fSize: Integer;
    fTwiddle: array of TRecorderSpectrumComplex;
    function GetBitReverse(AIndex: Integer): Integer;
    function GetTwiddle(AIndex: Integer): TRecorderSpectrumComplex;
    procedure SelectFastestForwardProc;
  public
    constructor Create(AFFTSize: Integer);
    procedure ExecuteForward(AWork: PRecorderSpectrumComplex); inline;
    property Size: Integer read fSize;
    property BitReverse[AIndex: Integer]: Integer read GetBitReverse;
    property Twiddle[AIndex: Integer]: TRecorderSpectrumComplex read GetTwiddle;
    property BackendName: string read fBackendName;
  end;

  { Caches immutable FFT plans by size and binds every plan to the fastest
    numerically verified forward-transform function for the current CPU. }
  TRecorderSpectrumComputeManager = class
  private
    fLock: SyncObjs.TCriticalSection;
    fPlans: TList;
    function FindPlan(AFFTSize: Integer): TRecorderSpectrumFFTPlan;
    function GetPlanCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AcquirePlan(AFFTSize: Integer): TRecorderSpectrumFFTPlan;
    procedure Prepare(const AFFTSizes: array of Integer);
    function BackendName(AFFTSize: Integer): string;
    property PlanCount: Integer read GetPlanCount;
  end;

  TRecorderSpectrumEvaluator = class
  private
    fSettings: TRecorderSpectrumSettings;
    fPlan: TRecorderSpectrumFFTPlan;
    fWindow: array of Double;
    fWindowed: PDouble;
    fWindowedBase: Pointer;
    fWork: PRecorderSpectrumComplex;
    fWorkBase: Pointer;
    procedure BuildWindow;
  public
    constructor Create(const ASettings: TRecorderSpectrumSettings);
    destructor Destroy; override;
    procedure Eval(AInput: PDouble; var AFrame: TRecorderSpectrumFrame);
    property Settings: TRecorderSpectrumSettings read fSettings;
  end;

  { One runtime channel for one input tag. FeedSamples may emit zero, one, or
    many frames in one call. Example: FFT=8192, Overlap=4096, input=16384 emits
    three frames: 0..8191, 4096..12287, 8192..16383. }
  TRecorderSpectrumChannel = class
  private
    fEvaluator: TRecorderSpectrumEvaluator;
    fFrame: TRecorderSpectrumFrame;
    fFrameIndex: Int64;
    fOnFrame: TRecorderSpectrumFrameEvent;
    fPendingCount: Integer;
    fPendingTimes: array of Double;
    fPendingValues: array of Double;
    fSettings: TRecorderSpectrumSettings;
    fSourceTagName: string;
    procedure EmitFrame;
    procedure ShiftAfterFrame;
  public
    constructor Create(const ASourceTagName: string;
      const ASettings: TRecorderSpectrumSettings);
    destructor Destroy; override;
    procedure Clear;
    procedure FeedSamples(const ATimes, AValues: array of Double; ACount: Integer);
    property SourceTagName: string read fSourceTagName;
    property Settings: TRecorderSpectrumSettings read fSettings;
    property PendingCount: Integer read fPendingCount;
    property OnFrame: TRecorderSpectrumFrameEvent read fOnFrame write fOnFrame;
  end;

function RecorderSpectrumWindowName(AKind: TRecorderSpectrumWindowKind): string;
function RecorderSpectrumNormalizeName(AMode: TRecorderSpectrumNormalizeMode): string;
function RecorderSpectrumOverlapName(AMode: TRecorderSpectrumOverlapMode): string;
function RecorderSpectrumIntegrationName(AMode: TRecorderSpectrumIntegrationMode): string;
function RecorderSpectrumComputeManager: TRecorderSpectrumComputeManager;

implementation

const
  CTwoPi = 2.0 * Pi;
  CSqrt2 = 1.4142135623730950488;

var
  gSpectrumComputeManager: TRecorderSpectrumComputeManager = nil;

function AlignSpectrumPointer(APointer: Pointer; AAlignment: SizeInt): Pointer; inline;
var
  lValue: PtrUInt;
begin
  lValue := PtrUInt(APointer);
  Result := Pointer((lValue + PtrUInt(AAlignment - 1)) and not PtrUInt(AAlignment - 1));
end;

function SpectrumBenchmarkIterations(AFFTSize: Integer): Integer;
begin
  if AFFTSize <= 512 then
    Result := 4000
  else if AFFTSize <= 2048 then
    Result := 1200
  else if AFFTSize <= 8192 then
    Result := 320
  else
    Result := 96;
end;

function SpectrumTickMicroseconds: Int64;
{$IFDEF MSWINDOWS}
var
  lCounter: Int64;
  lFrequency: Int64;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  QueryPerformanceCounter(lCounter);
  QueryPerformanceFrequency(lFrequency);
  if lFrequency > 0 then
    Result := (lCounter * 1000000) div lFrequency
  else
    Result := Int64(GetTickCount64) * 1000;
  {$ELSE}
  Result := Int64(GetTickCount64) * 1000;
  {$ENDIF}
end;

{$IF Defined(CPUX86_64)}
function SpectrumAvxAvailableAsm: Boolean; assembler;
var
  lSavedRbx: NativeUInt;
asm
  mov lSavedRbx, rbx
  mov eax, 1
  cpuid
  bt ecx, 28 // AVX hardware
  jnc @not_supported
  bt ecx, 27 // OSXSAVE
  jnc @not_supported
  xor ecx, ecx
  xgetbv
  and eax, 6
  cmp eax, 6
  jne @not_supported
  mov al, 1
  jmp @exit
@not_supported:
  xor al, al
@exit:
  mov rbx, lSavedRbx
end;
{$ENDIF}

function SpectrumAvxAvailable: Boolean;
begin
  {$IF Defined(CPUX86_64)}
  Result := SpectrumAvxAvailableAsm;
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

function IsPowerOfTwo(AValue: Integer): Boolean;
begin
  Result := (AValue > 0) and ((AValue and (AValue - 1)) = 0);
end;

function ReverseBits(AValue, ABitCount: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ABitCount - 1 do
  begin
    Result := (Result shl 1) or (AValue and 1);
    AValue := AValue shr 1;
  end;
end;

function RecorderSpectrumWindowName(AKind: TRecorderSpectrumWindowKind): string;
begin
  case AKind of
    swkRect: Result := 'Rect';
    swkHann: Result := 'Hann';
    swkHamming: Result := 'Hamming';
    swkBlackman: Result := 'Blackman';
    swkFlatTop: Result := 'FlatTop';
  else
    Result := 'Unknown';
  end;
end;

function RecorderSpectrumNormalizeName(AMode: TRecorderSpectrumNormalizeMode): string;
begin
  case AMode of
    snmNone: Result := 'None';
    snmMax: Result := 'Max';
    snmEnergy: Result := 'Energy';
  else
    Result := 'Unknown';
  end;
end;

function RecorderSpectrumOverlapName(AMode: TRecorderSpectrumOverlapMode): string;
begin
  case AMode of
    somNone: Result := 'без перекрытия';
    somHalf: Result := '1/2';
    somQuarter: Result := '1/4';
  else
    Result := 'Unknown';
  end;
end;

function RecorderSpectrumIntegrationName(AMode: TRecorderSpectrumIntegrationMode): string;
begin
  case AMode of
    simNone: Result := 'без интегрирования';
    simSingle: Result := 'однократное';
    simDouble: Result := 'двухкратное';
  else
    Result := 'Unknown';
  end;
end;

procedure TRecorderSpectrumSettings.SetDefaults;
begin
  FFTSize := 8192;
  Overlap := 0;
  OverlapMode := somNone;
  SampleRateHz := 0.0;
  AverageBlockCount := 1;
  ZeroPad := False;
  AhCorrectionEnabled := False;
  AhCorrectionProfileName := '';
  IntegrationMode := simNone;
  WindowKind := swkHann;
  NormalizeMode := snmNone;
  KeepPhase := True;
end;

function TRecorderSpectrumSettings.AsString: string;
var
  lFS: TFormatSettings;
begin
  lFS := DefaultFormatSettings;
  lFS.DecimalSeparator := '.';
  Result := Format(
    'FFTSize=%d,Overlap=%d,OverlapMode=%d,SampleRateHz=%s,AverageBlockCount=%d,ZeroPad=%d,' +
    'AhCorrectionEnabled=%d,AhCorrectionProfileName=%s,IntegrationMode=%d,WindowKind=%d,NormalizeMode=%d,KeepPhase=%d',
    [FFTSize, Overlap, Ord(OverlapMode), FloatToStr(SampleRateHz, lFS), AverageBlockCount, Ord(ZeroPad),
     Ord(AhCorrectionEnabled), AhCorrectionProfileName, Ord(IntegrationMode),
     Ord(WindowKind), Ord(NormalizeMode), Ord(KeepPhase)]);
end;

procedure TRecorderSpectrumSettings.FromString(const AValue: string);
var
  lList: TStringList;
  I: Integer;
  lKey, lVal: string;
  lInt: Integer;
  lFS: TFormatSettings;
begin
  SetDefaults;
  if AValue = '' then
    Exit;

  lFS := DefaultFormatSettings;
  lFS.DecimalSeparator := '.';
  lList := TStringList.Create;
  try
    lList.Delimiter := ',';
    lList.StrictDelimiter := True;
    lList.DelimitedText := AValue;
    for I := 0 to lList.Count - 1 do
    begin
      lKey := Trim(lList.Names[I]);
      lVal := Trim(lList.ValueFromIndex[I]);
      if SameText(lKey, 'FFTSize') then
        FFTSize := StrToIntDef(lVal, FFTSize)
      else if SameText(lKey, 'Overlap') then
        Overlap := StrToIntDef(lVal, Overlap)
      else if SameText(lKey, 'OverlapMode') then
      begin
        lInt := StrToIntDef(lVal, Ord(OverlapMode));
        if (lInt >= Ord(Low(TRecorderSpectrumOverlapMode))) and (lInt <= Ord(High(TRecorderSpectrumOverlapMode))) then
          OverlapMode := TRecorderSpectrumOverlapMode(lInt);
      end
      else if SameText(lKey, 'SampleRateHz') then
        SampleRateHz := StrToFloatDef(lVal, SampleRateHz, lFS)
      else if SameText(lKey, 'AverageBlockCount') then
        AverageBlockCount := StrToIntDef(lVal, AverageBlockCount)
      else if SameText(lKey, 'ZeroPad') then
        ZeroPad := StrToIntDef(lVal, 0) <> 0
      else if SameText(lKey, 'AhCorrectionEnabled') then
        AhCorrectionEnabled := StrToIntDef(lVal, 0) <> 0
      else if SameText(lKey, 'AhCorrectionProfileName') then
        AhCorrectionProfileName := lVal
      else if SameText(lKey, 'IntegrationMode') then
      begin
        lInt := StrToIntDef(lVal, Ord(IntegrationMode));
        if (lInt >= Ord(Low(TRecorderSpectrumIntegrationMode))) and (lInt <= Ord(High(TRecorderSpectrumIntegrationMode))) then
          IntegrationMode := TRecorderSpectrumIntegrationMode(lInt);
      end
      else if SameText(lKey, 'WindowKind') then
      begin
        lInt := StrToIntDef(lVal, Ord(WindowKind));
        if (lInt >= Ord(Low(TRecorderSpectrumWindowKind))) and (lInt <= Ord(High(TRecorderSpectrumWindowKind))) then
          WindowKind := TRecorderSpectrumWindowKind(lInt);
      end
      else if SameText(lKey, 'NormalizeMode') then
      begin
        lInt := StrToIntDef(lVal, Ord(NormalizeMode));
        if (lInt >= Ord(Low(TRecorderSpectrumNormalizeMode))) and (lInt <= Ord(High(TRecorderSpectrumNormalizeMode))) then
          NormalizeMode := TRecorderSpectrumNormalizeMode(lInt);
      end
      else if SameText(lKey, 'KeepPhase') then
        KeepPhase := StrToIntDef(lVal, 0) <> 0;
    end;
  finally
    lList.Free;
  end;
end;

procedure TRecorderSpectrumSettings.Validate;
begin
  if not IsPowerOfTwo(FFTSize) then
    raise ERecorderSpectrumError.CreateFmt('FFT size must be power of two: %d', [FFTSize]);
  if FFTSize < 2 then
    raise ERecorderSpectrumError.Create('FFT size must be at least 2');
  if (Overlap < 0) or (Overlap >= FFTSize) then
    raise ERecorderSpectrumError.CreateFmt('Overlap must be in range 0..FFTSize-1: %d', [Overlap]);
  if SampleRateHz < 0.0 then
    raise ERecorderSpectrumError.Create('Sample rate cannot be negative');
  if AverageBlockCount < 1 then
    raise ERecorderSpectrumError.Create('Average block count must be at least 1');
end;

function TRecorderSpectrumSettings.HopSize: Integer;
begin
  Validate;
  Result := FFTSize - Overlap;
end;

function TRecorderSpectrumSettings.FrequencyStepHz: Double;
begin
  Validate;
  if SampleRateHz > 0.0 then
    Result := SampleRateHz / FFTSize
  else
    Result := 0.0;
end;

constructor TRecorderSpectrumTagBinding.Create(const ASourceTagName: string);
begin
  inherited Create;
  fSourceTagName := ASourceTagName;
  fOutputPrefix := ASourceTagName + '_spm';
  fSettings.SetDefaults;
end;

procedure TRecorderSpectrumTagBinding.Assign(ASource: TRecorderSpectrumTagBinding);
begin
  if ASource = nil then
    Exit;
  fSourceTagName := ASource.SourceTagName;
  fOutputPrefix := ASource.OutputPrefix;
  fUseOwnSettings := ASource.UseOwnSettings;
  fSettings := ASource.Settings;
end;

function TRecorderSpectrumTagBinding.ResolveSettings(
  const AParent: TRecorderSpectrumSettings): TRecorderSpectrumSettings;
begin
  if fUseOwnSettings then
    Result := fSettings
  else
    Result := AParent;
  Result.Validate;
end;

constructor TRecorderSpectrumConfigNode.Create(const AId, ADisplayName: string);
begin
  inherited Create;
  fId := AId;
  fDisplayName := ADisplayName;
  fBindings := TList.Create;
  fSettings.SetDefaults;
end;

destructor TRecorderSpectrumConfigNode.Destroy;
begin
  ClearBindings;
  fBindings.Free;
  inherited Destroy;
end;

function TRecorderSpectrumConfigNode.GetBinding(AIndex: Integer): TRecorderSpectrumTagBinding;
begin
  Result := TRecorderSpectrumTagBinding(fBindings[AIndex]);
end;

function TRecorderSpectrumConfigNode.GetBindingCount: Integer;
begin
  Result := fBindings.Count;
end;

function TRecorderSpectrumConfigNode.AddBinding(
  const ASourceTagName: string): TRecorderSpectrumTagBinding;
begin
  Result := TRecorderSpectrumTagBinding.Create(ASourceTagName);
  fBindings.Add(Result);
end;

procedure TRecorderSpectrumConfigNode.DeleteBinding(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= fBindings.Count) then
    Exit;
  TObject(fBindings[AIndex]).Free;
  fBindings.Delete(AIndex);
end;

procedure TRecorderSpectrumConfigNode.ClearBindings;
var
  I: Integer;
begin
  for I := 0 to fBindings.Count - 1 do
    TObject(fBindings[I]).Free;
  fBindings.Clear;
end;

procedure TRecorderSpectrumConfigNode.Assign(ASource: TRecorderSpectrumConfigNode);
var
  I: Integer;
  lSrcBinding, lDestBinding: TRecorderSpectrumTagBinding;
begin
  if ASource = nil then Exit;
  fId := ASource.Id;
  fDisplayName := ASource.DisplayName;
  fSettings := ASource.Settings;
  ClearBindings;
  for I := 0 to ASource.BindingCount - 1 do
  begin
    lSrcBinding := ASource.Bindings[I];
    lDestBinding := AddBinding(lSrcBinding.SourceTagName);
    lDestBinding.Assign(lSrcBinding);
  end;
end;

constructor TRecorderSpectrumConfigTree.Create;
begin
  inherited Create;
  fNodes := TList.Create;
end;

destructor TRecorderSpectrumConfigTree.Destroy;
begin
  Clear;
  fNodes.Free;
  inherited Destroy;
end;

function TRecorderSpectrumConfigTree.GetNode(AIndex: Integer): TRecorderSpectrumConfigNode;
begin
  Result := TRecorderSpectrumConfigNode(fNodes[AIndex]);
end;

function TRecorderSpectrumConfigTree.GetNodeCount: Integer;
begin
  Result := fNodes.Count;
end;

function TRecorderSpectrumConfigTree.AddNode(const AId,
  ADisplayName: string): TRecorderSpectrumConfigNode;
begin
  if FindNode(AId) <> nil then
    raise ERecorderSpectrumError.CreateFmt('Spectrum config node already exists: %s', [AId]);
  Result := TRecorderSpectrumConfigNode.Create(AId, ADisplayName);
  fNodes.Add(Result);
end;

procedure TRecorderSpectrumConfigTree.DeleteNode(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= fNodes.Count) then
    Exit;
  TObject(fNodes[AIndex]).Free;
  fNodes.Delete(AIndex);
end;

function TRecorderSpectrumConfigTree.FindNode(
  const AId: string): TRecorderSpectrumConfigNode;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fNodes.Count - 1 do
    if SameText(GetNode(I).Id, AId) then
      Exit(GetNode(I));
end;

procedure TRecorderSpectrumConfigTree.Clear;
var
  I: Integer;
begin
  for I := 0 to fNodes.Count - 1 do
    TObject(fNodes[I]).Free;
  fNodes.Clear;
end;

procedure TRecorderSpectrumConfigTree.Assign(ASource: TRecorderSpectrumConfigTree);
var
  I: Integer;
  lSrcNode, lDestNode: TRecorderSpectrumConfigNode;
begin
  if ASource = nil then Exit;
  Clear;
  for I := 0 to ASource.NodeCount - 1 do
  begin
    lSrcNode := ASource.Nodes[I];
    lDestNode := AddNode(lSrcNode.Id, lSrcNode.DisplayName);
    lDestNode.Assign(lSrcNode);
  end;
end;

procedure SpectrumButterflyForwardInline(var AU, AV: TRecorderSpectrumComplex;
  const ATwiddle: TRecorderSpectrumComplex); inline;
var
  lTmpRe: Double;
  lTmpIm: Double;
  lURe: Double;
  lUIm: Double;
begin
  lURe := AU.Re;
  lUIm := AU.Im;
  lTmpRe := AV.Re * ATwiddle.Re - AV.Im * ATwiddle.Im;
  lTmpIm := AV.Re * ATwiddle.Im + AV.Im * ATwiddle.Re;
  AU.Re := lURe + lTmpRe;
  AU.Im := lUIm + lTmpIm;
  AV.Re := lURe - lTmpRe;
  AV.Im := lUIm - lTmpIm;
end;

procedure SpectrumForwardPascalInline(AWork: PRecorderSpectrumComplex;
  APlan: TRecorderSpectrumFFTPlan); inline;
var
  lStepSize: Integer;
  lHalfStep: Integer;
  lBlockStart: Integer;
  lK: Integer;
  lTwiddleStep: Integer;
  lTwiddleIndex: Integer;
begin
  lStepSize := 2;
  while lStepSize <= APlan.Size do
  begin
    lHalfStep := lStepSize div 2;
    lTwiddleStep := APlan.Size div lStepSize;
    lBlockStart := 0;
    while lBlockStart < APlan.Size do
    begin
      lTwiddleIndex := 0;
      for lK := 0 to lHalfStep - 1 do
      begin
        SpectrumButterflyForwardInline(AWork[lBlockStart + lK],
          AWork[lBlockStart + lK + lHalfStep], APlan.fTwiddle[lTwiddleIndex]);
        Inc(lTwiddleIndex, lTwiddleStep);
      end;
      Inc(lBlockStart, lStepSize);
    end;
    lStepSize := lStepSize shl 1;
  end;
end;

{$IF Defined(CPUX86_64)}
procedure SpectrumForwardAvxVector2(AWork: PRecorderSpectrumComplex;
  APlan: TRecorderSpectrumFFTPlan);
var
  lStepSize: Integer;
  lHalfStep: Integer;
  lBlockStart: Integer;
  lK: Integer;
  lTwiddleStep: Integer;
  lTwiddleIndex: Integer;
  lUPtr: PRecorderSpectrumComplex;
  lVPtr: PRecorderSpectrumComplex;
  lTw0Ptr: PRecorderSpectrumComplex;
  lTw1Ptr: PRecorderSpectrumComplex;
begin
  lStepSize := 2;
  while lStepSize <= APlan.Size do
  begin
    lHalfStep := lStepSize div 2;
    lTwiddleStep := APlan.Size div lStepSize;
    lBlockStart := 0;
    while lBlockStart < APlan.Size do
    begin
      lTwiddleIndex := 0;
      lK := 0;
      while lK + 1 < lHalfStep do
      begin
        lUPtr := @AWork[lBlockStart + lK];
        lVPtr := @AWork[lBlockStart + lK + lHalfStep];
        lTw0Ptr := @APlan.fTwiddle[lTwiddleIndex];
        lTw1Ptr := @APlan.fTwiddle[lTwiddleIndex + lTwiddleStep];
        asm
          mov rax, lUPtr
          mov rdx, lVPtr
          mov r8, lTw0Ptr
          mov r9, lTw1Ptr
          vmovupd ymm0, [rax]
          vmovupd ymm1, [rdx]
          vmovupd xmm2, [r8]
          vinsertf128 ymm2, ymm2, [r9], 1
          vpermilpd ymm3, ymm1, 0
          vpermilpd ymm4, ymm1, 15
          vpermilpd ymm5, ymm2, 5
          vmulpd ymm3, ymm3, ymm2
          vmulpd ymm4, ymm4, ymm5
          vaddsubpd ymm3, ymm3, ymm4
          vaddpd ymm4, ymm0, ymm3
          vsubpd ymm5, ymm0, ymm3
          vmovupd [rax], ymm4
          vmovupd [rdx], ymm5
        end;
        Inc(lK, 2);
        Inc(lTwiddleIndex, lTwiddleStep * 2);
      end;
      while lK < lHalfStep do
      begin
        // The last butterfly of an odd half-block is kept scalar.
        SpectrumButterflyForwardInline(AWork[lBlockStart + lK],
          AWork[lBlockStart + lK + lHalfStep], APlan.fTwiddle[lTwiddleIndex]);
        Inc(lK);
        Inc(lTwiddleIndex, lTwiddleStep);
      end;
      Inc(lBlockStart, lStepSize);
    end;
    lStepSize := lStepSize shl 1;
  end;
  asm
    vzeroupper
  end;
end;
{$ENDIF}

constructor TRecorderSpectrumFFTPlan.Create(AFFTSize: Integer);
var
  I: Integer;
  lAngle: Double;
  lSin: Double;
  lCos: Double;
begin
  inherited Create;
  if not IsPowerOfTwo(AFFTSize) then
    raise ERecorderSpectrumError.CreateFmt('FFT size must be power of two: %d', [AFFTSize]);

  fSize := AFFTSize;
  fBits := 0;
  I := AFFTSize;
  while I > 1 do
  begin
    Inc(fBits);
    I := I shr 1;
  end;

  SetLength(fBitReverse, AFFTSize);
  for I := 0 to AFFTSize - 1 do
    fBitReverse[I] := ReverseBits(I, fBits);

  SetLength(fTwiddle, AFFTSize div 2);
  for I := 0 to (AFFTSize div 2) - 1 do
  begin
    lAngle := -CTwoPi * I / AFFTSize;
    SinCos(lAngle, lSin, lCos);
    fTwiddle[I].Re := lCos;
    fTwiddle[I].Im := lSin;
  end;
  SelectFastestForwardProc;
end;

function TRecorderSpectrumFFTPlan.GetBitReverse(AIndex: Integer): Integer;
begin
  Result := fBitReverse[AIndex];
end;

function TRecorderSpectrumFFTPlan.GetTwiddle(
  AIndex: Integer): TRecorderSpectrumComplex;
begin
  Result := fTwiddle[AIndex];
end;

procedure TRecorderSpectrumFFTPlan.ExecuteForward(AWork: PRecorderSpectrumComplex); inline;
begin
  fForwardProc(AWork, Self);
end;

procedure TRecorderSpectrumFFTPlan.SelectFastestForwardProc;
var
  I: Integer;
  lIterations: Integer;
  lStartTick: Int64;
  lPascalTime: Int64;
  lCandidateTime: Int64;
  lSeedBase: Pointer;
  lReferenceBase: Pointer;
  lWorkBase: Pointer;
  lSeed: PRecorderSpectrumComplex;
  lReference: PRecorderSpectrumComplex;
  lWork: PRecorderSpectrumComplex;
  lCandidate: TRecorderSpectrumForwardProc;
  lDiff: Double;
begin
  fForwardProc := @SpectrumForwardPascalInline;
  fBackendName := 'Pascal inline';
  {$IF Defined(CPUX86_64)}
  if not SpectrumAvxAvailable then
    Exit;
  {$ELSE}
  Exit;
  {$ENDIF}

  lSeedBase := nil;
  lReferenceBase := nil;
  lWorkBase := nil;
  try
    GetMem(lSeedBase, fSize * SizeOf(TRecorderSpectrumComplex) + 64);
    GetMem(lReferenceBase, fSize * SizeOf(TRecorderSpectrumComplex) + 64);
    GetMem(lWorkBase, fSize * SizeOf(TRecorderSpectrumComplex) + 64);
    lSeed := PRecorderSpectrumComplex(AlignSpectrumPointer(lSeedBase, 64));
    lReference := PRecorderSpectrumComplex(AlignSpectrumPointer(lReferenceBase, 64));
    lWork := PRecorderSpectrumComplex(AlignSpectrumPointer(lWorkBase, 64));
    for I := 0 to fSize - 1 do
    begin
      lSeed[I].Re := Sin(I * 0.03125) + Cos(I * 0.0078125);
      lSeed[I].Im := 0.0;
    end;
    Move(lSeed^, lReference^, fSize * SizeOf(TRecorderSpectrumComplex));
    SpectrumForwardPascalInline(lReference, Self);

    {$IF Defined(CPUX86_64)}
    lCandidate := @SpectrumForwardAvxVector2;
    Move(lSeed^, lWork^, fSize * SizeOf(TRecorderSpectrumComplex));
    lCandidate(lWork, Self);
    lDiff := 0.0;
    for I := 0 to fSize - 1 do
    begin
      if Abs(lReference[I].Re - lWork[I].Re) > lDiff then
        lDiff := Abs(lReference[I].Re - lWork[I].Re);
      if Abs(lReference[I].Im - lWork[I].Im) > lDiff then
        lDiff := Abs(lReference[I].Im - lWork[I].Im);
    end;
    if lDiff > 1.0e-8 then
      Exit;

    lIterations := SpectrumBenchmarkIterations(fSize);
    lStartTick := SpectrumTickMicroseconds;
    for I := 1 to lIterations do
    begin
      Move(lSeed^, lWork^, fSize * SizeOf(TRecorderSpectrumComplex));
      SpectrumForwardPascalInline(lWork, Self);
    end;
    lPascalTime := SpectrumTickMicroseconds - lStartTick;
    lStartTick := SpectrumTickMicroseconds;
    for I := 1 to lIterations do
    begin
      Move(lSeed^, lWork^, fSize * SizeOf(TRecorderSpectrumComplex));
      lCandidate(lWork, Self);
    end;
    lCandidateTime := SpectrumTickMicroseconds - lStartTick;
    if (lCandidateTime > 0) and ((lPascalTime <= 0) or
      (lCandidateTime < lPascalTime)) then
    begin
      fForwardProc := lCandidate;
      fBackendName := 'AVX vector2';
    end;
    {$ENDIF}
  finally
    if lWorkBase <> nil then
      FreeMem(lWorkBase);
    if lReferenceBase <> nil then
      FreeMem(lReferenceBase);
    if lSeedBase <> nil then
      FreeMem(lSeedBase);
  end;
end;

constructor TRecorderSpectrumComputeManager.Create;
begin
  inherited Create;
  fLock := SyncObjs.TCriticalSection.Create;
  fPlans := TList.Create;
end;

destructor TRecorderSpectrumComputeManager.Destroy;
var
  I: Integer;
begin
  for I := 0 to fPlans.Count - 1 do
    TObject(fPlans[I]).Free;
  fPlans.Free;
  fLock.Free;
  inherited Destroy;
end;

function TRecorderSpectrumComputeManager.FindPlan(
  AFFTSize: Integer): TRecorderSpectrumFFTPlan;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fPlans.Count - 1 do
    if TRecorderSpectrumFFTPlan(fPlans[I]).Size = AFFTSize then
      Exit(TRecorderSpectrumFFTPlan(fPlans[I]));
end;

function TRecorderSpectrumComputeManager.GetPlanCount: Integer;
begin
  Result := fPlans.Count;
end;

function TRecorderSpectrumComputeManager.AcquirePlan(
  AFFTSize: Integer): TRecorderSpectrumFFTPlan;
begin
  fLock.Acquire;
  try
    Result := FindPlan(AFFTSize);
    if Result = nil then
    begin
      Result := TRecorderSpectrumFFTPlan.Create(AFFTSize);
      fPlans.Add(Result);
    end;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderSpectrumComputeManager.Prepare(const AFFTSizes: array of Integer);
var
  I: Integer;
begin
  for I := 0 to High(AFFTSizes) do
    AcquirePlan(AFFTSizes[I]);
end;

function TRecorderSpectrumComputeManager.BackendName(AFFTSize: Integer): string;
begin
  Result := AcquirePlan(AFFTSize).BackendName;
end;

function RecorderSpectrumComputeManager: TRecorderSpectrumComputeManager;
begin
  Result := gSpectrumComputeManager;
end;

constructor TRecorderSpectrumEvaluator.Create(
  const ASettings: TRecorderSpectrumSettings);
begin
  inherited Create;
  fSettings := ASettings;
  fSettings.Validate;
  fPlan := RecorderSpectrumComputeManager.AcquirePlan(fSettings.FFTSize);
  SetLength(fWindow, fSettings.FFTSize);
  GetMem(fWindowedBase, fSettings.FFTSize * SizeOf(Double) + 64);
  fWindowed := PDouble(AlignSpectrumPointer(fWindowedBase, 64));
  GetMem(fWorkBase, fSettings.FFTSize * SizeOf(TRecorderSpectrumComplex) + 64);
  fWork := PRecorderSpectrumComplex(AlignSpectrumPointer(fWorkBase, 64));
  BuildWindow;
end;

destructor TRecorderSpectrumEvaluator.Destroy;
begin
  if fWorkBase <> nil then
    FreeMem(fWorkBase);
  if fWindowedBase <> nil then
    FreeMem(fWindowedBase);
  inherited Destroy;
end;

procedure TRecorderSpectrumEvaluator.BuildWindow;
var
  I: Integer;
  X: Double;
begin
  if fSettings.FFTSize <= 1 then
    Exit;

  for I := 0 to fSettings.FFTSize - 1 do
  begin
    X := CTwoPi * I / (fSettings.FFTSize - 1);
    case fSettings.WindowKind of
      swkRect:
        fWindow[I] := 1.0;
      swkHann:
        fWindow[I] := 0.5 - 0.5 * Cos(X);
      swkHamming:
        fWindow[I] := 0.54 - 0.46 * Cos(X);
      swkBlackman:
        fWindow[I] := 0.42 - 0.5 * Cos(X) + 0.08 * Cos(2.0 * X);
      swkFlatTop:
        fWindow[I] := 1.0 - 1.93 * Cos(X) + 1.29 * Cos(2.0 * X) -
          0.388 * Cos(3.0 * X) + 0.0322 * Cos(4.0 * X);
    end;
  end;
end;

procedure TRecorderSpectrumEvaluator.Eval(AInput: PDouble;
  var AFrame: TRecorderSpectrumFrame);
var
  I: Integer;
  J: Integer;
  lScale: Double;
  lValue: Double;
  lNorm: Double;
begin
  if AInput = nil then
    raise ERecorderSpectrumError.Create('Spectrum input cannot be nil');

  for I := 0 to fSettings.FFTSize - 1 do
    fWindowed[I] := AInput[I] * fWindow[I];

  for I := 0 to fSettings.FFTSize - 1 do
  begin
    J := fPlan.BitReverse[I];
    fWork[J].Re := fWindowed[I];
    fWork[J].Im := 0.0;
  end;

  fPlan.ExecuteForward(fWork);

  AFrame.FFTSize := fSettings.FFTSize;
  AFrame.Bins := fSettings.FFTSize div 2;
  AFrame.SampleRateHz := fSettings.SampleRateHz;
  AFrame.FrequencyStepHz := fSettings.FrequencyStepHz;
  SetLength(AFrame.Rms, AFrame.Bins);
  if fSettings.KeepPhase then
    SetLength(AFrame.PhaseRad, AFrame.Bins)
  else
    SetLength(AFrame.PhaseRad, 0);

  lScale := CSqrt2 / fSettings.FFTSize;
  lNorm := 0.0;
  for I := 0 to AFrame.Bins - 1 do
  begin
    lValue := Sqrt(Sqr(fWork[I].Re) + Sqr(fWork[I].Im)) * lScale;
    AFrame.Rms[I] := lValue;
    if fSettings.KeepPhase then
      AFrame.PhaseRad[I] := ArcTan2(fWork[I].Im, fWork[I].Re);
    case fSettings.NormalizeMode of
      snmMax:
        if lValue > lNorm then
          lNorm := lValue;
      snmEnergy:
        lNorm := lNorm + Sqr(lValue);
    end;
  end;

  if fSettings.NormalizeMode = snmEnergy then
    lNorm := Sqrt(lNorm);
  if lNorm > 0.0 then
    for I := 0 to AFrame.Bins - 1 do
      AFrame.Rms[I] := AFrame.Rms[I] / lNorm;

  AFrame.MaxIndex := -1;
  AFrame.MaxFrequencyHz := 0.0;
  AFrame.MaxRms := 0.0;
  for I := 1 to AFrame.Bins - 1 do
    if (AFrame.MaxIndex < 0) or (AFrame.Rms[I] > AFrame.MaxRms) then
    begin
      AFrame.MaxIndex := I;
      AFrame.MaxFrequencyHz := I * AFrame.FrequencyStepHz;
      AFrame.MaxRms := AFrame.Rms[I];
    end;
end;

constructor TRecorderSpectrumChannel.Create(const ASourceTagName: string;
  const ASettings: TRecorderSpectrumSettings);
begin
  inherited Create;
  if ASourceTagName = '' then
    raise ERecorderSpectrumError.Create('Spectrum source tag cannot be empty');

  fSourceTagName := ASourceTagName;
  fSettings := ASettings;
  fSettings.Validate;
  fEvaluator := TRecorderSpectrumEvaluator.Create(fSettings);
  SetLength(fPendingTimes, fSettings.FFTSize);
  SetLength(fPendingValues, fSettings.FFTSize);
  fFrame.SourceTagName := fSourceTagName;
end;

destructor TRecorderSpectrumChannel.Destroy;
begin
  fEvaluator.Free;
  inherited Destroy;
end;

procedure TRecorderSpectrumChannel.Clear;
begin
  fPendingCount := 0;
  fFrameIndex := 0;
end;

procedure TRecorderSpectrumChannel.EmitFrame;
begin
  fFrame.SourceTagName := fSourceTagName;
  fFrame.FrameIndex := fFrameIndex;
  fFrame.StartTimeSec := fPendingTimes[0];
  fFrame.EndTimeSec := fPendingTimes[fSettings.FFTSize - 1];
  fEvaluator.Eval(@fPendingValues[0], fFrame);
  Inc(fFrameIndex);
  if Assigned(fOnFrame) then
    fOnFrame(Self, fFrame);
end;

procedure TRecorderSpectrumChannel.ShiftAfterFrame;
var
  lKeep: Integer;
begin
  lKeep := fSettings.Overlap;
  if lKeep > 0 then
  begin
    Move(fPendingTimes[fSettings.FFTSize - lKeep], fPendingTimes[0],
      lKeep * SizeOf(Double));
    Move(fPendingValues[fSettings.FFTSize - lKeep], fPendingValues[0],
      lKeep * SizeOf(Double));
  end;
  fPendingCount := lKeep;
end;

procedure TRecorderSpectrumChannel.FeedSamples(const ATimes,
  AValues: array of Double; ACount: Integer);
var
  I: Integer;
begin
  if ACount < 0 then
    raise ERecorderSpectrumError.Create('Spectrum sample count cannot be negative');
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderSpectrumError.Create('Spectrum sample count exceeds input length');

  for I := 0 to ACount - 1 do
  begin
    fPendingTimes[fPendingCount] := ATimes[I];
    fPendingValues[fPendingCount] := AValues[I];
    Inc(fPendingCount);

    if fPendingCount = fSettings.FFTSize then
    begin
      EmitFrame;
      ShiftAfterFrame;
    end;
  end;
end;

initialization
  // The manager object itself is created on the UI/startup path. Expensive
  // plan preparation remains explicit in the stopped-state runtime manager.
  gSpectrumComputeManager := TRecorderSpectrumComputeManager.Create;

finalization
  FreeAndNil(gSpectrumComputeManager);

end.
