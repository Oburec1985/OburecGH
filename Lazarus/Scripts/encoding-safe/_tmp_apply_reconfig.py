# -*- coding: utf-8 -*-
"""Apply phase: after collect, reconnect+Config (SEND inside Program). Log-proven SEND fails on soft-stop session."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

PATH = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\uRecorderMcbusDevice.pas")


def main() -> None:
    text = read_pas(PATH)

    old = """  { 5) Программирование всем разом: Stop → SEND → Start. Без verify. }
  BalanceTrace(Format('phase apply: StopAfterHeavyStream + SEND %d + Start',
    [Length(AChannels)]));
  for I := 0 to High(AChannels) do
  begin
    lSlot := fProgramInfo[AChannels[I] div CMc201MaxModuleChannels].Slot;
    lChannelInSlot := AChannels[I] mod CMc201MaxModuleChannels;
    if Length(fBalanceDac) > AChannels[I] then
      fBalanceDac[AChannels[I]] := lCodes[I];
    fConfig.Slots[lSlot].Channels[lChannelInSlot].BalanceDac[
      EnsureRange(fConfig.Slots[lSlot].Channels[lChannelInSlot].RangeIndex,
        0, 5)] := lCodes[I];
  end;
  { После сбора RX забит — обычный Stop как в просмотре не подходит. }
  if not fController.StopAfterHeavyStream(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 multi balance apply stop: ' + AErrorText;
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;
  for I := 0 to High(AChannels) do
  begin
    lSlot := fProgramInfo[AChannels[I] div CMc201MaxModuleChannels].Slot;
    lChannelInSlot := AChannels[I] mod CMc201MaxModuleChannels;
    lLo := lCodes[I] and $ff;
    lHi := lCodes[I] shr 8;
    if not fController.SendBalanceDac(lSlot, lChannelInSlot, lLo, lHi,
      AErrorText) then
    begin
      BalanceTrace('SEND_BALANCE failed: ' + AErrorText);
      Exit;
    end;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 multi balance apply start: ' + AErrorText;
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;
  Result := True;
  BalanceTrace(Format('BalanceChannelsHardware OK programmed=%d/%d',
    [lProgCount, Length(AChannels)]));
end;"""

    new = """  { 5) Программирование: по логу StopAfterHeavyStream «ок», но первый
    SEND_BALANCE на той же TCP-сессии — MDP timeout (~1.2с). После плотного
    сбора сессия для IDMA мертва. Коды уже в soft-config → чистый reconnect
    + Config (там SEND_BALANCE) + Start. Prepare по-прежнему Stop+SEND. }
  BalanceTrace(Format(
    'phase apply: soft-codes + ForceDisconnect + Config (%d new)',
    [lProgCount]));
  for I := 0 to High(AChannels) do
  begin
    lSlot := fProgramInfo[AChannels[I] div CMc201MaxModuleChannels].Slot;
    lChannelInSlot := AChannels[I] mod CMc201MaxModuleChannels;
    if Length(fBalanceDac) > AChannels[I] then
      fBalanceDac[AChannels[I]] := lCodes[I];
    fConfig.Slots[lSlot].Channels[lChannelInSlot].BalanceDac[
      EnsureRange(fConfig.Slots[lSlot].Channels[lChannelInSlot].RangeIndex,
        0, 5)] := lCodes[I];
  end;

  fController.ForceDisconnect(False);
  fState := rdsDisconnected;
  Sleep(1500);
  fController.Host := Trim(fHost);
  fController.Port := Word(fPort);
  if fConfig.ReadTimeoutMs < 5000 then
    fController.TimeoutMs := 5000
  else
    fController.TimeoutMs := fConfig.ReadTimeoutMs;
  for I := 1 to 5 do
  begin
    BalanceTrace(Format('apply reconnect %d/5', [I]));
    if fController.TryConnect(AErrorText) then
      Break;
    BalanceTrace('apply reconnect failed: ' + AErrorText);
    fController.ForceDisconnect(False);
    Sleep(1000 * I);
  end;
  if fController.State = mcsDisconnected then
  begin
    AErrorText := 'MC-201 multi balance apply reconnect: ' + AErrorText;
    Exit;
  end;
  fState := rdsConnected;
  if not fController.Config(fConfig, AErrorText) then
  begin
    AErrorText := 'MC-201 multi balance apply Config: ' + AErrorText;
    fController.ForceDisconnect(False);
    fState := rdsDisconnected;
    Exit;
  end;
  fProgramInfo := Copy(fController.ProgramInfo, 0,
    Length(fController.ProgramInfo));
  fState := rdsProgrammed;
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 multi balance apply start: ' + AErrorText;
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;
  Result := True;
  BalanceTrace(Format('BalanceChannelsHardware OK programmed=%d/%d',
    [lProgCount, Length(AChannels)]));
end;"""

    if old not in text:
        raise SystemExit("apply block not found")
    text = text.replace(old, new, 1)

    # BalanceChannelsHardware vars: I reused for reconnect loop — already have I.
    # Need mcsDisconnected — from uMc032Device, already used elsewhere in unit.
    write_utf8_crlf(PATH, text)
    print("patched apply reconnect")


if __name__ == "__main__":
    main()
