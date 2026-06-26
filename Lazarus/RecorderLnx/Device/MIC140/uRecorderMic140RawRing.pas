unit uRecorderMic140RawRing;

{
  Кольцо заранее выделенных слотов TMic140LegacyRawBlock.

  Поток чтения пишет в следующий слот; поток разбора читает из другого —
  без длительной блокировки на копировании payload.

  См. Docs/devices/mic140/acquisition_rules.md §3
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SyncObjs,
  uRecorderMic140StreamTypes;

const
  CMic140RawRingDefaultSlotCount = 8;

type
  TMic140RawBlockRing = class(TObject)
  private
    fSlots: array of TMic140LegacyRawBlock;
    fSlotCount: Integer;
    fWriteIndex: Integer;
    fReadIndex: Integer;
    fCount: Integer;
    fLock: TCriticalSection;
    fDropped: Int64;
  public
    constructor Create(ASlotCount: Integer = CMic140RawRingDefaultSlotCount);
    destructor Destroy; override;
    {
      Копирует ARaw в слот writeIndex. При переполнении сбрасывает старейший блок.
      ADroppedOldest = True, если слот был перезаписан до чтения.
    }
    procedure Enqueue(const ARaw: TMic140LegacyRawBlock; out ADroppedOldest: Boolean);
    function TryDequeue(out ARaw: TMic140LegacyRawBlock): Boolean;
    function PendingCount: Integer;
    function DroppedCount: Int64;
    function SlotCount: Integer;
  end;

implementation

constructor TMic140RawBlockRing.Create(ASlotCount: Integer);
var
  I: Integer;
begin
  inherited Create;
  if ASlotCount < 2 then
    ASlotCount := CMic140RawRingDefaultSlotCount;
  fSlotCount := ASlotCount;
  SetLength(fSlots, fSlotCount);
  for I := 0 to fSlotCount - 1 do
  begin
    fSlots[I].DataWordCount := 0;
    fSlots[I].FirstSampleIndex := 0;
    fSlots[I].ReadSerial := 0;
  end;
  fWriteIndex := 0;
  fReadIndex := 0;
  fCount := 0;
  fDropped := 0;
  fLock := TCriticalSection.Create;
end;

destructor TMic140RawBlockRing.Destroy;
begin
  fLock.Free;
  inherited Destroy;
end;

procedure TMic140RawBlockRing.Enqueue(const ARaw: TMic140LegacyRawBlock;
  out ADroppedOldest: Boolean);
var
  lNextWrite: Integer;
begin
  ADroppedOldest := False;
  fLock.Acquire;
  try
    if fCount >= fSlotCount then
    begin
      Inc(fDropped);
      ADroppedOldest := True;
      fReadIndex := (fReadIndex + 1) mod fSlotCount;
      Dec(fCount);
    end;
    fSlots[fWriteIndex] := ARaw;
    lNextWrite := (fWriteIndex + 1) mod fSlotCount;
    fWriteIndex := lNextWrite;
    if fCount < fSlotCount then
      Inc(fCount);
  finally
    fLock.Release;
  end;
end;

function TMic140RawBlockRing.TryDequeue(out ARaw: TMic140LegacyRawBlock): Boolean;
begin
  Result := False;
  fLock.Acquire;
  try
    if fCount <= 0 then
      Exit;
    ARaw := fSlots[fReadIndex];
    fReadIndex := (fReadIndex + 1) mod fSlotCount;
    Dec(fCount);
    Result := True;
  finally
    fLock.Release;
  end;
end;

function TMic140RawBlockRing.PendingCount: Integer;
begin
  fLock.Acquire;
  try
    Result := fCount;
  finally
    fLock.Release;
  end;
end;

function TMic140RawBlockRing.DroppedCount: Int64;
begin
  fLock.Acquire;
  try
    Result := fDropped;
  finally
    fLock.Release;
  end;
end;

function TMic140RawBlockRing.SlotCount: Integer;
begin
  Result := fSlotCount;
end;

end.
