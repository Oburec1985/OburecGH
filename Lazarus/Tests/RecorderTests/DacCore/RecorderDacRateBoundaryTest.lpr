program RecorderDacRateBoundaryTest;
{$mode objfpc}{$H+}
uses SysUtils, Math, uRecorderDacTypes, uRecorderDacContracts,
  uRecorderDacSession, uRecorderNullDacBackend, uRecorderBlockClock;

type
  TProbeProvider = class(TInterfacedObject, IRecorderDacSampleProvider,
    IRecorderDacPlaybackRateControl)
  public
    Rate: Double;
    Updates, Frames: Integer;
    function Configure(const C: TRecorderDacConfig; out R: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(B: PDouble; Capacity: Integer; out Count: Integer;
      out R: TRecorderDacResult): Boolean;
    function SetPlaybackSampleRate(ARate: Double; out R: TRecorderDacResult): Boolean;
    function CanSetPlaybackSampleRate(ARate: Double; out R: TRecorderDacResult): Boolean;
  end;
  TProbeMirror = class(TInterfacedObject, IRecorderDacMirror,
    IRecorderDacTimedMirror, IRecorderDacRateControlledMirror)
  public
    Factor, Nominal: Double;
    Writes, Transitions: Integer;
    LastPivot: QWord;
    function Configure(const C: TRecorderDacConfig; out R: TRecorderDacResult): Boolean;
    procedure Reset;
    function WriteBlock(B: PDouble; Count: Integer; out R: TRecorderDacResult): Boolean;
    function WriteTimedBlock(B: PDouble; const T: TRecorderBlockTime;
      out R: TRecorderDacResult): Boolean;
    function CanSetRateFactor(K: Double; out R: TRecorderDacResult): Boolean;
    function SetRateFactorAtFrame(K: Double; Pivot: QWord;
      out R: TRecorderDacResult): Boolean;
  end;

procedure Check(OK: Boolean; const MessageText: string);
begin
  if not OK then raise Exception.Create(MessageText);
  Writeln('PASS ', MessageText);
end;

function TProbeProvider.Configure(const C: TRecorderDacConfig; out R: TRecorderDacResult): Boolean;
begin Rate := C.SampleRateHz; Frames := C.FramesPerBlock; R := RecorderDacOk; Result := True end;
procedure TProbeProvider.Reset;
begin end;
function TProbeProvider.CanSetPlaybackSampleRate(ARate: Double; out R: TRecorderDacResult): Boolean;
begin R := RecorderDacOk; Result := ARate > 0 end;
function TProbeProvider.SetPlaybackSampleRate(ARate: Double; out R: TRecorderDacResult): Boolean;
begin Rate := ARate; Inc(Updates); R := RecorderDacOk; Result := True end;
function TProbeProvider.FillBlock(B: PDouble; Capacity: Integer; out Count: Integer;
  out R: TRecorderDacResult): Boolean;
var I: Integer;
begin
  Count := Frames;
  for I := 0 to Count - 1 do B[I] := Rate / 2000;
  R := RecorderDacOk; Result := Capacity >= Count;
end;

function TProbeMirror.Configure(const C: TRecorderDacConfig; out R: TRecorderDacResult): Boolean;
begin Nominal := C.SampleRateHz; Factor := 1; R := RecorderDacOk; Result := True end;
procedure TProbeMirror.Reset;
begin end;
function TProbeMirror.WriteBlock(B: PDouble; Count: Integer; out R: TRecorderDacResult): Boolean;
begin R := RecorderDacFailed(rdeInvalidConfig, rdsgWrite, 'Timed writes required'); Result := False end;
function TProbeMirror.WriteTimedBlock(B: PDouble; const T: TRecorderBlockTime;
  out R: TRecorderDacResult): Boolean;
begin
  if Abs(B[0] - Factor * Nominal / 2000) > 1E-12 then
    raise Exception.Create('Old queued generation was retimed using a new factor');
  if (Transitions > 0) and (Writes = 3) and
    (Round(T.DeviceStartSeconds * Nominal) <> LastPivot) then
    raise Exception.Create('Publisher transition uses a different frame than provider');
  Inc(Writes); R := RecorderDacOk; Result := True;
end;
function TProbeMirror.CanSetRateFactor(K: Double; out R: TRecorderDacResult): Boolean;
begin
  Result := not IsNan(K) and not IsInfinite(K) and (K >= 0.99) and (K <= 1.01);
  if Result then R := RecorderDacOk
  else R := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure, 'Out of range factor');
end;
function TProbeMirror.SetRateFactorAtFrame(K: Double; Pivot: QWord;
  out R: TRecorderDacResult): Boolean;
begin
  Result := CanSetRateFactor(K, R);
  if Result then begin Factor := K; LastPivot := Pivot; Inc(Transitions) end;
end;

var
  ProviderObject: TProbeProvider;
  MirrorObject: TProbeMirror;
  Provider: IRecorderDacSampleProvider;
  Mirror: IRecorderDacMirror;
  Backend: IRecorderDacBackend;
  Session: TRecorderDacSession;
  Config: TRecorderDacConfig;
  R: TRecorderDacResult;
  I: Integer;
begin
  try
    ProviderObject := TProbeProvider.Create;
    MirrorObject := TProbeMirror.Create;
    Provider := ProviderObject; Mirror := MirrorObject;
    Backend := TRecorderNullDacBackend.Create('rate-boundary');
    Session := TRecorderDacSession.Create(Backend, Provider, Mirror, True);
    try
      Config := Default(TRecorderDacConfig);
      Config.SampleRateHz := 1000; Config.ChannelCount := 1;
      Config.FramesPerBlock := 10; Config.MinimumValue := -1; Config.MaximumValue := 1;
      Check(Session.Configure(Config, R) and Session.Start(R), 'Production session configured and started');
      for I := 1 to 3 do Check(Session.Pump(R), 'Old-rate block queued without publisher');
      Check(Session.RequestRateFactor(1.001, R) and Session.RequestRateFactor(1.002, R),
        'Pending spinner requests accepted and coalesced');
      Check((ProviderObject.Updates = 0) and (MirrorObject.Transitions = 0),
        'Control request mutates neither generator nor recording clock');
      Check(Session.Pump(R), 'Worker generates first new-rate block');
      Check((ProviderObject.Updates = 1) and (Abs(ProviderObject.Rate - 1002) < 1E-9),
        'Worker applies only latest pending rate before FillBlock');
      Check((MirrorObject.Factor = 1) and Session.RateFactorPending,
        'Mirror remains old rate until publisher reaches FIFO transition');
      for I := 1 to 3 do Check(Session.FlushMirror(R), 'Delayed publisher consumes old generation with old clock');
      Check(MirrorObject.Transitions = 0, 'Old queued blocks never acquire future rate');
      Check(Session.FlushMirror(R), 'First new generation commits matching rate at FIFO boundary');
      Check((MirrorObject.Transitions = 1) and (MirrorObject.LastPivot = 30) and
        (Abs(MirrorObject.Factor - 1.002) < 1E-12) and not Session.RateFactorPending,
        'Publisher acknowledgement commits exact frame pivot and clears pending');
      Check(not Session.RequestRateFactor(1.02, R), 'Rejected factor cannot mutate either consumer');
      Check((ProviderObject.Updates = 1) and (MirrorObject.Transitions = 1),
        'Rejected command leaves provider and mirror unchanged');
      Check(Session.Stop(R) and Session.Disconnect(R), 'Native session closes normally without rate restart');
    finally Session.Free end;
    Writeln('RESULT RecorderDacRateBoundaryTest passed');
  except on E: Exception do begin Writeln('RESULT RecorderDacRateBoundaryTest failed: ', E.Message); Halt(1) end end;
end.
