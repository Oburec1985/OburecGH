unit uRecorderSpectrumEngine;

{
  RecorderLnx FFT runtime engine.

  The unit deliberately has no LCL/UI dependencies. The settings dialog can edit
  TRecorderSpectrumConfigTree, while the runtime code receives already resolved
  tag bindings and feeds TRecorderSpectrumChannel with driver blocks.
}

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}
{$pointermath on}

interface

uses
  Classes, SysUtils, Math;

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
    property NodeCount: Integer read GetNodeCount;
    property Nodes[AIndex: Integer]: TRecorderSpectrumConfigNode read GetNode;
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
  end;

  TRecorderSpectrumFrameEvent = procedure(ASender: TObject;
    const AFrame: TRecorderSpectrumFrame) of object;

  TRecorderSpectrumFFTPlan = class
  private
    fBitReverse: array of Integer;
    fBits: Integer;
    fSize: Integer;
    fTwiddle: array of TRecorderSpectrumComplex;
    function GetBitReverse(AIndex: Integer): Integer;
    function GetTwiddle(AIndex: Integer): TRecorderSpectrumComplex;
  public
    constructor Create(AFFTSize: Integer);
    property Size: Integer read fSize;
    property BitReverse[AIndex: Integer]: Integer read GetBitReverse;
    property Twiddle[AIndex: Integer]: TRecorderSpectrumComplex read GetTwiddle;
  end;

  TRecorderSpectrumEvaluator = class
  private
    fSettings: TRecorderSpectrumSettings;
    fPlan: TRecorderSpectrumFFTPlan;
    fWindow: array of Double;
    fWindowed: array of Double;
    fWork: array of TRecorderSpectrumComplex;
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

implementation

const
  CTwoPi = 2.0 * Pi;
  CSqrt2 = 1.4142135623730950488;

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
    somNone: Result := 'Р±РµР· РїРµСЂРµРєСЂС‹С‚РёСЏ';
    somHalf: Result := '1/2';
    somQuarter: Result := '1/4';
  else
    Result := 'Unknown';
  end;
end;

function RecorderSpectrumIntegrationName(AMode: TRecorderSpectrumIntegrationMode): string;
begin
  case AMode of
    simNone: Result := 'Р±РµР· РёРЅС‚РµРіСЂРёСЂРѕРІР°РЅРёСЏ';
    simSingle: Result := 'РѕРґРЅРѕРєСЂР°С‚РЅРѕРµ';
    simDouble: Result := 'РґРІСѓС…РєСЂР°С‚РЅРѕРµ';
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

constructor TRecorderSpectrumEvaluator.Create(
  const ASettings: TRecorderSpectrumSettings);
begin
  inherited Create;
  fSettings := ASettings;
  fSettings.Validate;
  fPlan := TRecorderSpectrumFFTPlan.Create(fSettings.FFTSize);
  SetLength(fWindow, fSettings.FFTSize);
  SetLength(fWindowed, fSettings.FFTSize);
  SetLength(fWork, fSettings.FFTSize);
  BuildWindow;
end;

destructor TRecorderSpectrumEvaluator.Destroy;
begin
  fPlan.Free;
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
  lStepSize: Integer;
  lHalfStep: Integer;
  lBlockStart: Integer;
  lK: Integer;
  lTwiddleStep: Integer;
  lTwiddleIndex: Integer;
  lTw: TRecorderSpectrumComplex;
  lURe: Double;
  lUIm: Double;
  lTmpRe: Double;
  lTmpIm: Double;
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

  lStepSize := 2;
  while lStepSize <= fSettings.FFTSize do
  begin
    lHalfStep := lStepSize div 2;
    lTwiddleStep := fSettings.FFTSize div lStepSize;
    lBlockStart := 0;
    while lBlockStart < fSettings.FFTSize do
    begin
      lTwiddleIndex := 0;
      for lK := 0 to lHalfStep - 1 do
      begin
        lTw := fPlan.Twiddle[lTwiddleIndex];
        lURe := fWork[lBlockStart + lK].Re;
        lUIm := fWork[lBlockStart + lK].Im;
        lTmpRe := fWork[lBlockStart + lK + lHalfStep].Re * lTw.Re -
          fWork[lBlockStart + lK + lHalfStep].Im * lTw.Im;
        lTmpIm := fWork[lBlockStart + lK + lHalfStep].Re * lTw.Im +
          fWork[lBlockStart + lK + lHalfStep].Im * lTw.Re;
        fWork[lBlockStart + lK].Re := lURe + lTmpRe;
        fWork[lBlockStart + lK].Im := lUIm + lTmpIm;
        fWork[lBlockStart + lK + lHalfStep].Re := lURe - lTmpRe;
        fWork[lBlockStart + lK + lHalfStep].Im := lUIm - lTmpIm;
        Inc(lTwiddleIndex, lTwiddleStep);
      end;
      Inc(lBlockStart, lStepSize);
    end;
    lStepSize := lStepSize shl 1;
  end;

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

end.
