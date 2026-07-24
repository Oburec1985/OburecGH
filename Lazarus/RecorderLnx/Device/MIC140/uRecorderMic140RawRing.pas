unit uRecorderMic140RawRing;

{
  ╨Ъ╨╛╨╗╤М╤Ж╨╛ ╨╖╨░╤А╨░╨╜╨╡╨╡ ╨▓╤Л╨┤╨╡╨╗╨╡╨╜╨╜╤Л╤Е ╤Б╨╗╨╛╤В╨╛╨▓ TMic140LegacyRawBlock.

  ╨Я╨╛╤В╨╛╨║ ╤З╤В╨╡╨╜╨╕╤П ╨┐╨╕╤И╨╡╤В ╨▓ ╤Б╨╗╨╡╨┤╤Г╤О╤Й╨╕╨╣ ╤Б╨╗╨╛╤В; ╨┐╨╛╤В╨╛╨║ ╤А╨░╨╖╨▒╨╛╤А╨░ ╤З╨╕╤В╨░╨╡╤В ╨╕╨╖ ╨┤╤А╤Г╨│╨╛╨│╨╛ тАФ
  ╨▒╨╡╨╖ ╨┤╨╗╨╕╤В╨╡╨╗╤М╨╜╨╛╨╣ ╨▒╨╗╨╛╨║╨╕╤А╨╛╨▓╨║╨╕ ╨╜╨░ ╨║╨╛╨┐╨╕╤А╨╛╨▓╨░╨╜╨╕╨╕ payload.

  ╨б╨╝. Docs/devices/mic140/acquisition_rules.md ┬з3
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SyncObjs,
  uRecorderMic140WireTypes;

const
  CMic140v2RawRingSlots = 8;

type
  TMic140v2RawRing = class(TObject)
  private
    fSlots: array of TMic140LegacyRawBlock;
    fSlotCount: Integer;
    fWriteIndex: Integer;
    fReadIndex: Integer;
    fCount: Integer;
    fLock: TCriticalSection;
    fDropped: Int64;
  public
    constructor Create(ASlotCount: Integer = CMic140v2RawRingSlots);
    destructor Destroy; override;
    {
      ╨Ъ╨╛╨┐╨╕╤А╤Г╨╡╤В ARaw ╨▓ ╤Б╨╗╨╛╤В writeIndex. ╨Я╤А╨╕ ╨┐╨╡╤А╨╡╨┐╨╛╨╗╨╜╨╡╨╜╨╕╨╕ ╤Б╨▒╤А╨░╤Б╤Л╨▓╨░╨╡╤В ╤Б╤В╨░╤А╨╡╨╣╤И╨╕╨╣ ╨▒╨╗╨╛╨║.
      ADroppedOldest = True, ╨╡╤Б╨╗╨╕ ╤Б╨╗╨╛╤В ╨▒╤Л╨╗ ╨┐╨╡╤А╨╡╨╖╨░╨┐╨╕╤Б╨░╨╜ ╨┤╨╛ ╤З╤В╨╡╨╜╨╕╤П.
    }
    procedure Enqueue(const ARaw: TMic140LegacyRawBlock; out ADroppedOldest: Boolean);
    function TryDequeue(out ARaw: TMic140LegacyRawBlock): Boolean;
    function PendingCount: Integer;
    function DroppedCount: Int64;
    function SlotCount: Integer;
  end;

implementation

constructor TMic140v2RawRing.Create(ASlotCount: Integer);
var
  I: Integer;
begin
  inherited Create;
  if ASlotCount < 2 then
    ASlotCount := CMic140v2RawRingSlots;
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

destructor TMic140v2RawRing.Destroy;
begin
  fLock.Free;
  inherited Destroy;
end;

procedure TMic140v2RawRing.Enqueue(const ARaw: TMic140LegacyRawBlock;
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

function TMic140v2RawRing.TryDequeue(out ARaw: TMic140LegacyRawBlock): Boolean;
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

function TMic140v2RawRing.PendingCount: Integer;
begin
  fLock.Acquire;
  try
    Result := fCount;
  finally
    fLock.Release;
  end;
end;

function TMic140v2RawRing.DroppedCount: Int64;
begin
  fLock.Acquire;
  try
    Result := fDropped;
  finally
    fLock.Release;
  end;
end;

function TMic140v2RawRing.SlotCount: Integer;
begin
  Result := fSlotCount;
end;

end.
