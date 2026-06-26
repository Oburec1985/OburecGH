unit uRecorderMic140DoubleBuffer;

{
  Single-producer / single-consumer double buffer for TMic140LegacyRawBlock.

  The producer copies into the inactive slot and swaps an index under a short
  critical section. The consumer copies the active slot without blocking the
  producer for more than one index update. If the consumer falls behind, the
  producer overwrites the pending slot — we keep the latest block only.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SyncObjs,
  uRecorderMic140StreamTypes;

type
  TMic140RawDoubleBuffer = class(TObject)
  private
    fSlots: array[0..1] of TMic140LegacyRawBlock;
    fActiveIndex: Integer;
    fHasPending: Boolean;
    fLock: TCriticalSection;
    fDropped: Int64;
    fPublishedSeq: Int64;
    fConsumedSeq: Int64;
  public
    constructor Create;
    destructor Destroy; override;
    { Publish returns True when a previously unconsumed block was replaced. }
    function Publish(const ARaw: TMic140LegacyRawBlock): Boolean;
    function TryTake(out ARaw: TMic140LegacyRawBlock): Boolean;
    function HasPending: Boolean;
    function DroppedCount: Int64;
    function PendingLag: Int64;
  end;

implementation

constructor TMic140RawDoubleBuffer.Create;
begin
  inherited Create;
  fLock := TCriticalSection.Create;
  fActiveIndex := 0;
  fHasPending := False;
  fDropped := 0;
  fPublishedSeq := 0;
  fConsumedSeq := 0;
end;

destructor TMic140RawDoubleBuffer.Destroy;
begin
  fLock.Free;
  inherited Destroy;
end;

function TMic140RawDoubleBuffer.Publish(const ARaw: TMic140LegacyRawBlock): Boolean;
var
  lInactive: Integer;
begin
  Result := False;
  fLock.Acquire;
  try
    lInactive := 1 - fActiveIndex;
    fSlots[lInactive] := ARaw;
    if fHasPending and (fPublishedSeq > fConsumedSeq) then
    begin
      Inc(fDropped);
      Result := True;
    end;
    fActiveIndex := lInactive;
    fHasPending := True;
    Inc(fPublishedSeq);
  finally
    fLock.Release;
  end;
end;

function TMic140RawDoubleBuffer.TryTake(out ARaw: TMic140LegacyRawBlock): Boolean;
begin
  Result := False;
  fLock.Acquire;
  try
    if not fHasPending then
      Exit;
    ARaw := fSlots[fActiveIndex];
    fHasPending := False;
    fConsumedSeq := fPublishedSeq;
    Result := True;
  finally
    fLock.Release;
  end;
end;

function TMic140RawDoubleBuffer.HasPending: Boolean;
begin
  fLock.Acquire;
  try
    Result := fHasPending;
  finally
    fLock.Release;
  end;
end;

function TMic140RawDoubleBuffer.DroppedCount: Int64;
begin
  fLock.Acquire;
  try
    Result := fDropped;
  finally
    fLock.Release;
  end;
end;

function TMic140RawDoubleBuffer.PendingLag: Int64;
begin
  fLock.Acquire;
  try
    Result := fPublishedSeq - fConsumedSeq;
  finally
    fLock.Release;
  end;
end;

end.
