unit uRecorderSignalGeneratorModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, uRecorderFormModel;

type
  TRecorderGeneratedSignalKind = (rgskSine, rgskSaw, rgskNoise);

  TRecorderSignalGeneratorComponent = class;

  TRecorderGeneratedSignal = class
  private
    fOwner: TRecorderSignalGeneratorComponent;
    fEnabled: Boolean;
    fName: string;
    fKind: TRecorderGeneratedSignalKind;
    fSampleRateHz: Double;
    fAmplitude: Double;
    fFrequencyHz: Double;
    fPhaseDeg: Double;
    fOffset: Double;
    fSweepEnabled: Boolean;
    fSweepEndFrequencyHz: Double;
    fSweepDurationSec: Double;
    fSweepLogarithmic: Boolean;
    fChangePhase: Boolean;
    fPhaseVelocityDegSec: Double;
    procedure Changed;
    procedure SetAmplitude(AValue: Double);
    procedure SetChangePhase(AValue: Boolean);
    procedure SetEnabled(AValue: Boolean);
    procedure SetFrequencyHz(AValue: Double);
    procedure SetKind(AValue: TRecorderGeneratedSignalKind);
    procedure SetName(const AValue: string);
    procedure SetOffset(AValue: Double);
    procedure SetPhaseDeg(AValue: Double);
    procedure SetPhaseVelocityDegSec(AValue: Double);
    procedure SetSampleRateHz(AValue: Double);
    procedure SetSweepDurationSec(AValue: Double);
    procedure SetSweepEnabled(AValue: Boolean);
    procedure SetSweepEndFrequencyHz(AValue: Double);
    procedure SetSweepLogarithmic(AValue: Boolean);
  public
    constructor Create;
    procedure Assign(ASource: TRecorderGeneratedSignal);
    property Enabled: Boolean read fEnabled write SetEnabled;
    property Name: string read fName write SetName;
    property Kind: TRecorderGeneratedSignalKind read fKind write SetKind;
    property SampleRateHz: Double read fSampleRateHz write SetSampleRateHz;
    property Amplitude: Double read fAmplitude write SetAmplitude;
    property FrequencyHz: Double read fFrequencyHz write SetFrequencyHz;
    property PhaseDeg: Double read fPhaseDeg write SetPhaseDeg;
    property Offset: Double read fOffset write SetOffset;
    property SweepEnabled: Boolean read fSweepEnabled write SetSweepEnabled;
    property SweepEndFrequencyHz: Double read fSweepEndFrequencyHz
      write SetSweepEndFrequencyHz;
    property SweepDurationSec: Double read fSweepDurationSec
      write SetSweepDurationSec;
    property SweepLogarithmic: Boolean read fSweepLogarithmic
      write SetSweepLogarithmic;
    property ChangePhase: Boolean read fChangePhase write SetChangePhase;
    property PhaseVelocityDegSec: Double read fPhaseVelocityDegSec
      write SetPhaseVelocityDegSec;
  end;

  TRecorderSignalGeneratorComponent = class(TRecorderVisualComponent)
  private
    fEnabled: Boolean;
    fLock: TRTLCriticalSection;
    fRevision: LongInt;
    fSignals: TObjectList;
    function GetSignal(AIndex: Integer): TRecorderGeneratedSignal;
    function GetSignalCount: Integer;
    procedure MarkChanged;
    procedure SetEnabled(AValue: Boolean);
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddSignal: TRecorderGeneratedSignal;
    procedure BeginSignalEdit;
    procedure ClearSignals;
    procedure EndSignalEdit;
    procedure AssignGenerator(ASource: TRecorderSignalGeneratorComponent);
    procedure SnapshotSignal(AIndex: Integer; ADestination: TRecorderGeneratedSignal);
    property Enabled: Boolean read fEnabled write SetEnabled;
    property Revision: LongInt read fRevision;
    property SignalCount: Integer read GetSignalCount;
    property Signals[AIndex: Integer]: TRecorderGeneratedSignal read GetSignal;
  end;

  TRecorderSignalGeneratorFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create;
  end;

procedure RegisterRecorderSignalGeneratorFactory(
  AFactory: TRecorderComponentFactory);

implementation

constructor TRecorderGeneratedSignal.Create;
begin
  inherited Create;
  fEnabled := True;
  fName := 'GenSignal_001';
  fKind := rgskSine;
  fSampleRateHz := 1000.0;
  fAmplitude := 1.0;
  fFrequencyHz := 10.0;
  fPhaseDeg := 0.0;
  fOffset := 0.0;
  fSweepEnabled := False;
  fSweepEndFrequencyHz := 100.0;
  fSweepDurationSec := 10.0;
  fSweepLogarithmic := False;
  fChangePhase := False;
  fPhaseVelocityDegSec := 0.0;
end;

procedure TRecorderGeneratedSignal.Changed;
begin
  if fOwner <> nil then fOwner.MarkChanged;
end;

procedure TRecorderGeneratedSignal.SetEnabled(AValue: Boolean);
begin if fEnabled = AValue then Exit; fEnabled := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetName(const AValue: string);
begin if fName = AValue then Exit; fName := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetKind(AValue: TRecorderGeneratedSignalKind);
begin if fKind = AValue then Exit; fKind := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetSampleRateHz(AValue: Double);
begin if fSampleRateHz = AValue then Exit; fSampleRateHz := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetAmplitude(AValue: Double);
begin if fAmplitude = AValue then Exit; fAmplitude := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetFrequencyHz(AValue: Double);
begin if fFrequencyHz = AValue then Exit; fFrequencyHz := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetPhaseDeg(AValue: Double);
begin if fPhaseDeg = AValue then Exit; fPhaseDeg := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetOffset(AValue: Double);
begin if fOffset = AValue then Exit; fOffset := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetSweepEnabled(AValue: Boolean);
begin if fSweepEnabled = AValue then Exit; fSweepEnabled := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetSweepEndFrequencyHz(AValue: Double);
begin if fSweepEndFrequencyHz = AValue then Exit; fSweepEndFrequencyHz := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetSweepDurationSec(AValue: Double);
begin if fSweepDurationSec = AValue then Exit; fSweepDurationSec := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetSweepLogarithmic(AValue: Boolean);
begin if fSweepLogarithmic = AValue then Exit; fSweepLogarithmic := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetChangePhase(AValue: Boolean);
begin if fChangePhase = AValue then Exit; fChangePhase := AValue; Changed; end;
procedure TRecorderGeneratedSignal.SetPhaseVelocityDegSec(AValue: Double);
begin if fPhaseVelocityDegSec = AValue then Exit; fPhaseVelocityDegSec := AValue; Changed; end;

procedure TRecorderGeneratedSignal.Assign(ASource: TRecorderGeneratedSignal);
begin
  if ASource = nil then Exit;
  Enabled := ASource.Enabled;
  Name := ASource.Name;
  Kind := ASource.Kind;
  SampleRateHz := ASource.SampleRateHz;
  Amplitude := ASource.Amplitude;
  FrequencyHz := ASource.FrequencyHz;
  PhaseDeg := ASource.PhaseDeg;
  Offset := ASource.Offset;
  SweepEnabled := ASource.SweepEnabled;
  SweepEndFrequencyHz := ASource.SweepEndFrequencyHz;
  SweepDurationSec := ASource.SweepDurationSec;
  SweepLogarithmic := ASource.SweepLogarithmic;
  ChangePhase := ASource.ChangePhase;
  PhaseVelocityDegSec := ASource.PhaseVelocityDegSec;
end;

class function TRecorderSignalGeneratorComponent.GetTypeId: string;
begin
  Result := 'SignalGenerator';
end;

constructor TRecorderSignalGeneratorComponent.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  fSignals := TObjectList.Create(True);
  fEnabled := True;
  fRevision := 1;
end;

destructor TRecorderSignalGeneratorComponent.Destroy;
begin
  fSignals.Free;
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderSignalGeneratorComponent.AddSignal: TRecorderGeneratedSignal;
begin
  Result := TRecorderGeneratedSignal.Create;
  Result.fOwner := Self;
  fSignals.Add(Result);
  MarkChanged;
end;

procedure TRecorderSignalGeneratorComponent.ClearSignals;
begin
  fSignals.Clear;
  MarkChanged;
end;

procedure TRecorderSignalGeneratorComponent.MarkChanged;
begin
  InterlockedIncrement(fRevision);
end;

procedure TRecorderSignalGeneratorComponent.BeginSignalEdit;
begin
  EnterCriticalSection(fLock);
end;

procedure TRecorderSignalGeneratorComponent.EndSignalEdit;
begin
  LeaveCriticalSection(fLock);
end;

procedure TRecorderSignalGeneratorComponent.SetEnabled(AValue: Boolean);
begin
  if fEnabled = AValue then Exit;
  fEnabled := AValue;
  MarkChanged;
end;

procedure TRecorderSignalGeneratorComponent.SnapshotSignal(AIndex: Integer;
  ADestination: TRecorderGeneratedSignal);
begin
  if ADestination = nil then Exit;
  EnterCriticalSection(fLock);
  try
    ADestination.Assign(Signals[AIndex]);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalGeneratorComponent.AssignGenerator(
  ASource: TRecorderSignalGeneratorComponent);
var
  I: Integer;
begin
  if ASource = nil then Exit;
  fEnabled := ASource.Enabled;
  ClearSignals;
  for I := 0 to ASource.SignalCount - 1 do
    AddSignal.Assign(ASource.Signals[I]);
end;

function TRecorderSignalGeneratorComponent.GetSignal(
  AIndex: Integer): TRecorderGeneratedSignal;
begin
  Result := TRecorderGeneratedSignal(fSignals[AIndex]);
end;

function TRecorderSignalGeneratorComponent.GetSignalCount: Integer;
begin
  Result := fSignals.Count;
end;

constructor TRecorderSignalGeneratorFactory.Create;
begin
  inherited Create(TRecorderSignalGeneratorComponent.TypeId,
    'Signal generator', TRecorderSignalGeneratorComponent, 360, 170, False);
  ConfigurePalette('Генератор сигналов', 'Добавить генератор сигналов',
    'digital-indicator', 60);
end;

procedure TRecorderSignalGeneratorFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lGenerator: TRecorderSignalGeneratorComponent;
  lSignal: TRecorderGeneratedSignal;
begin
  inherited ConfigureNewComponent(AComponent, AContext);
  lGenerator := TRecorderSignalGeneratorComponent(AComponent);
  lGenerator.Name := Format('Генератор сигналов %d', [AContext.ComponentNo]);
  lSignal := lGenerator.AddSignal;
  lSignal.Name := Format('GenSignal_%0.3d', [AContext.ComponentNo]);
end;

procedure RegisterRecorderSignalGeneratorFactory(
  AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and not AFactory.IsComponentRegistered(
    TRecorderSignalGeneratorComponent.TypeId) then
    AFactory.RegisterFactory(TRecorderSignalGeneratorFactory.Create);
end;

end.
