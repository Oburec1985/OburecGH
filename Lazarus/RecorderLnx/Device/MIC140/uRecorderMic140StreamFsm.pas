unit uRecorderMic140StreamFsm;

{
  Этапы потоков чтения/публикации MIC-140.

  Наследует общую машину этапов TRecorderAcquirePhaseFsm; тайминги — в
  TRecorderMic140AcquireTiming.

  См. Docs/devices/mic140/acquisition_rules.md
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uRecorderAcquirePhase,
  uRecorderMic140AcquireTiming;

type
  TMic140StreamPhase = (
    mspOffline,
    mspIdle,
    mspAcquiring,
    mspStopping,
    mspError
  );

  TMic140StreamFsm = class(TRecorderAcquirePhaseFsm)
  private
    class function ToAcquirePhase(APhase: TMic140StreamPhase): TRecorderAcquirePhase; static;
    class function FromAcquirePhase(APhase: TRecorderAcquirePhase): TMic140StreamPhase; static;
  public
    constructor Create(ATiming: TRecorderMic140AcquireTiming); reintroduce;
    procedure SetPhase(APhase: TMic140StreamPhase; const AErrorText: string = '');
    function CurrentPhase: TMic140StreamPhase;
  end;

implementation

class function TMic140StreamFsm.ToAcquirePhase(APhase: TMic140StreamPhase): TRecorderAcquirePhase;
begin
  case APhase of
    mspOffline: Result := rapOffline;
    mspIdle: Result := rapIdle;
    mspAcquiring: Result := rapAcquiring;
    mspStopping: Result := rapStopping;
    mspError: Result := rapError;
  else
    Result := rapOffline;
  end;
end;

class function TMic140StreamFsm.FromAcquirePhase(
  APhase: TRecorderAcquirePhase): TMic140StreamPhase;
begin
  case APhase of
    rapOffline: Result := mspOffline;
    rapIdle: Result := mspIdle;
    rapAcquiring: Result := mspAcquiring;
    rapStopping: Result := mspStopping;
    rapError: Result := mspError;
  else
    Result := mspOffline;
  end;
end;

constructor TMic140StreamFsm.Create(ATiming: TRecorderMic140AcquireTiming);
begin
  inherited Create(ATiming);
end;

procedure TMic140StreamFsm.SetPhase(APhase: TMic140StreamPhase;
  const AErrorText: string);
begin
  inherited SetPhase(ToAcquirePhase(APhase), AErrorText);
end;

function TMic140StreamFsm.CurrentPhase: TMic140StreamPhase;
begin
  Result := FromAcquirePhase(inherited CurrentPhase);
end;

end.
