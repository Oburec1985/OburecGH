# -*- coding: utf-8 -*-
"""Add CalibrateScaleByBalanceDacShift to TRecorderMcbusDevice."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

PATH = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\uRecorderMcbusDevice.pas")

DECL = """    function TryApplySavedBalanceDac(out AErrorText: string): Boolean;
  end;"""

DECL_NEW = """    function TryApplySavedBalanceDac(out AErrorText: string): Boolean;
    { Сервис: сдвиг балансировочного ЦАП на известное V → K [В/код] для ГХ. }
    function CalibrateScaleByBalanceDacShift(AChannel: Integer;
      out AScaleVoltPerCode: Double; out AErrorText: string): Boolean;
  end;"""

IMPL = r"""
function TRecorderMcbusDevice.CalibrateScaleByBalanceDacShift(AChannel: Integer;
  out AScaleVoltPerCode: Double; out AErrorText: string): Boolean;
const
  CLoOff = 20;
  CHiOff = 20;
var
  lOldCode, lCodeB: Word;
  lMeanA, lMeanB, lVA, lVB, lDMean: Double;
  lSamples: Integer;
  lStartedHere: Boolean;
  lSlot, lChInSlot: Integer;
  lWasStarted: Boolean;
begin
  Result := False;
  AScaleVoltPerCode := 0;
  AErrorText := '';
  if (AChannel < 0) or (AChannel >= fChannelCount) then
  begin
    AErrorText := Format('MC-201 calibrate: bad channel %d', [AChannel]);
    Exit;
  end;
  if fState = rdsDisconnected then
  begin
    try
      Connect;
    except
      on E: Exception do
      begin
        AErrorText := 'MC-201 calibrate Connect: ' + E.Message;
        Exit;
      end;
    end;
  end;
  if fState = rdsConnected then
  begin
    try
      ProgramDevice;
    except
      on E: Exception do
      begin
        AErrorText := 'MC-201 calibrate ProgramDevice: ' + E.Message;
        Exit;
      end;
    end;
  end;

  lSlot := fProgramInfo[AChannel div CMc201MaxModuleChannels].Slot;
  lChInSlot := AChannel mod CMc201MaxModuleChannels;
  lOldCode := GetChannelBalanceDac(AChannel);
  lCodeB := Word(((CMc201BalanceDacMidCode + CHiOff) shl 8) or
    (CMc201BalanceDacMidCode + CLoOff));
  lVA := 0;
  lVB := RecorderMc201BalanceVoltFromSigned(CLoOff, CHiOff);
  lSamples := Max(64, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  lWasStarted := fState = rdsStarted;
  lStartedHere := False;

  { SEND только на остановленной шине (см. multi-balance docs). }
  if fState = rdsStarted then
    Stop;
  if not fController.SendBalanceDac(lSlot, lChInSlot, $80, $80, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate SEND A: ' + AErrorText;
    Exit;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate Start A: ' + AErrorText;
    Exit;
  end;
  fState := rdsStarted;
  lStartedHere := True;
  if not CollectChannelMean(AChannel, lSamples, lMeanA, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate mean A: ' + AErrorText;
    Exit;
  end;

  Stop;
  if not fController.SendBalanceDac(lSlot, lChInSlot,
    lCodeB and $ff, lCodeB shr 8, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate SEND B: ' + AErrorText;
    Exit;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate Start B: ' + AErrorText;
    Exit;
  end;
  fState := rdsStarted;
  if not CollectChannelMean(AChannel, lSamples, lMeanB, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate mean B: ' + AErrorText;
    Exit;
  end;

  Stop;
  if not fController.SendBalanceDac(lSlot, lChInSlot,
    lOldCode and $ff, lOldCode shr 8, AErrorText) then
    BalanceTrace('calibrate restore DAC: ' + AErrorText);
  if lWasStarted then
  begin
    if fController.StartRawScan(AErrorText) then
      fState := rdsStarted
    else
      BalanceTrace('calibrate restart: ' + AErrorText);
  end
  else
    fState := rdsProgrammed;

  lDMean := lMeanB - lMeanA;
  if Abs(lDMean) < 1.0 then
  begin
    AErrorText := Format(
      'MC-201 calibrate: Δcode too small (%.3f), meanA=%.3f meanB=%.3f',
      [lDMean, lMeanA, lMeanB]);
    Exit;
  end;
  { Знак: V>0 при сдвиге ЦАП; берём согласованный знак ΔV/Δcode. }
  AScaleVoltPerCode := (lVB - lVA) / lDMean;
  BalanceTrace(Format(
    'calibrate ch=%d meanA=%.3f meanB=%.3f Vb=%.6g K=%.9g V/code',
    [AChannel, lMeanA, lMeanB, lVB, AScaleVoltPerCode]));
  Result := True;
end;
"""


def main() -> None:
    t = read_pas(PATH)
    if "CalibrateScaleByBalanceDacShift" in t:
        print("already present")
        return
    if DECL not in t:
        raise SystemExit("decl anchor not found")
    t = t.replace(DECL, DECL_NEW, 1)
    # append before final end of implementation - before "function CreateRecorderMcbusDevice"
    anchor = "function CreateRecorderMcbusDevice: IRecorderDevice;"
    if anchor not in t:
        # try before initialization
        anchor = "initialization"
    idx = t.find(anchor)
    if idx < 0:
        raise SystemExit("impl anchor not found")
    t = t[:idx] + IMPL.strip() + "\n\n" + t[idx:]
    write_utf8_crlf(PATH, t)
    print("patched", PATH)


if __name__ == "__main__":
    main()
