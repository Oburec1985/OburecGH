# -*- coding: utf-8 -*-
"""Always reset MC-201 balance DAC to neutral before measuring/calculating."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

PATH = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\uRecorderMcbusDevice.pas"
)
text = read_pas(PATH)

old = r"""  lSamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  lOldCode := GetChannelBalanceDac(AChannel);
  BalanceTrace(Format(
    'начало: индекс=%d, слот=%d, канал=%d, Fs=%.3f, проба=%d, старый ЦАП=$%.4x, devState=%d',
    [AChannel, lSlot + 1, lChannelInSlot + 1, ChannelSampleRate(AChannel),
     lSamples, lOldCode, Ord(fState)]));
  if not CollectChannelMean(AChannel, lSamples, AFinalMean, AErrorText) then
    Exit;
  lTargetProduct := Abs(AFinalMean) / CMc201AdcCodesPerDacProduct;
  lLoOffset := EnsureRange(Ceil(lTargetProduct / 127.0), 1, 127);
  lHiOffset := EnsureRange(Round(lTargetProduct / lLoOffset), 0, 127);
  lLo := 128 + lLoOffset;
  if AFinalMean >= 0 then
    lHi := 128 + lHiOffset
  else
    lHi := 128 - lHiOffset;
  lHi := EnsureRange(lHi, 0, 255);
  lNewCode := Word((lHi shl 8) or lLo);
  BalanceTrace(Format('расчёт: среднее=%.3f, произведение=%.3f, два 8-битных ЦАП: lo=%d hi=%d ($%.4x)',
    [AFinalMean, lTargetProduct, lLo, lHi, lNewCode]));
  BalanceTrace(Format('SEND_BALANCE_CC slot=%d ch=%d lo=%d hi=%d',
    [lSlot, lChannelInSlot, lLo, lHi]));
  { Сначала сохраняем код в runtime-конфиг: STOPSCANMAIN на MC-201/MC-032
    не гарантирует сохранение регистров балансировочного ЦАП. После Stop
    нужно снова выдать SEND_BALANCE_CC до STARTSCANMAIN (как ApplySavedBalanceDac
    в обычном Start). }
  fBalanceDac[AChannel] := lNewCode;
  fConfig.Slots[lSlot].Channels[AChannel mod CMc201MaxModuleChannels].
    BalanceDac[EnsureRange(fConfig.Slots[lSlot].Channels[AChannel mod
      CMc201MaxModuleChannels].RangeIndex, 0, 5)] := lNewCode;
  if not fController.SendBalanceDac(lSlot, lChannelInSlot, lLo, lHi,
    AErrorText) then
  begin
    BalanceTrace('SEND_BALANCE_CC failed: ' + AErrorText);
    Exit;
  end;
  BalanceTrace('SEND_BALANCE_CC ok; soft code saved; apply Stop -> restore DAC -> Start');
  { Оригинал после SendBalanceDAC делает StartStop single-scan. У нас Stop
    сбрасывает ЦАП на железе — поэтому ДО StartRawScan восстанавливаем
    сохранённые коды (включая только что посчитанный). }
  if not fController.Stop(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance apply stop: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;
  BalanceTrace(Format('after Stop: soft=$%.4x; restore before StartRawScan',
    [lNewCode]));
  if not fController.SendBalanceDac(lSlot, lChannelInSlot, lLo, lHi,
    AErrorText) then
  begin
    AErrorText := 'MC-201 balance restore after stop: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  BalanceTrace('DAC restored after Stop');
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance apply start: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;
  lVerifySamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  BalanceTrace(Format('verify samples=%d', [lVerifySamples]));
  if not CollectChannelMean(AChannel, lVerifySamples, lVerifyMean,
    AErrorText) then
  begin
    AErrorText := 'MC-201 balance apply sample: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  BalanceTrace(Format(
    'apply cycle done: verifyMean=%.3f code=$%.4x (DAC must survive later Stop/Start via ApplySavedBalanceDac)',
    [lVerifyMean, lNewCode]));
  RecorderDebugLog(Format(
    '[MCBUS] balance DAC applied slot=%d channel=%d code=$%.4x mean=%.3f verify=%.3f',
    [lSlot + 1, lChannelInSlot + 1, lNewCode, AFinalMean, lVerifyMean]));
  ResetPending;
  Result := True;
end;
"""

new = r"""  lSamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  lOldCode := GetChannelBalanceDac(AChannel);
  BalanceTrace(Format(
    'начало: индекс=%d, слот=%d, канал=%d, Fs=%.3f, проба=%d, старый ЦАП=$%.4x, devState=%d',
    [AChannel, lSlot + 1, lChannelInSlot + 1, ChannelSampleRate(AChannel),
     lSamples, lOldCode, Ord(fState)]));
  { Open-loop считает поправку только от нейтрали ($8080). Сначала всегда
    гасим ЦАП через Stop → SEND $8080 → Start, иначе повтор меряет уже
    скорректированный вход и ломает рабочий код. }
  BalanceTrace(Format('сброс ЦАП в нейтраль $8080 (было $%.4x)', [lOldCode]));
  fBalanceDac[AChannel] := $8080;
  fConfig.Slots[lSlot].Channels[AChannel mod CMc201MaxModuleChannels].
    BalanceDac[EnsureRange(fConfig.Slots[lSlot].Channels[AChannel mod
      CMc201MaxModuleChannels].RangeIndex, 0, 5)] := $8080;
  if not fController.Stop(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance neutral stop: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;
  if not fController.SendBalanceDac(lSlot, lChannelInSlot, $80, $80,
    AErrorText) then
  begin
    BalanceTrace('neutral SEND_BALANCE failed: ' + AErrorText);
    Exit;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance neutral start: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;
  if not CollectChannelMean(AChannel, lSamples, AFinalMean, AErrorText) then
    Exit;
  lTargetProduct := Abs(AFinalMean) / CMc201AdcCodesPerDacProduct;
  lLoOffset := EnsureRange(Ceil(lTargetProduct / 127.0), 1, 127);
  lHiOffset := EnsureRange(Round(lTargetProduct / lLoOffset), 0, 127);
  lLo := 128 + lLoOffset;
  if AFinalMean >= 0 then
    lHi := 128 + lHiOffset
  else
    lHi := 128 - lHiOffset;
  lHi := EnsureRange(lHi, 0, 255);
  lNewCode := Word((lHi shl 8) or lLo);
  BalanceTrace(Format(
    'расчёт от нейтрали: среднее=%.3f, произведение=%.3f, lo=%d hi=%d ($%.4x)',
    [AFinalMean, lTargetProduct, lLo, lHi, lNewCode]));
  { Soft + Stop → SEND новый код → Start → verify. STOPSCANMAIN сбрасывает
    регистр ЦАП, поэтому SEND до STARTSCANMAIN обязателен. }
  fBalanceDac[AChannel] := lNewCode;
  fConfig.Slots[lSlot].Channels[AChannel mod CMc201MaxModuleChannels].
    BalanceDac[EnsureRange(fConfig.Slots[lSlot].Channels[AChannel mod
      CMc201MaxModuleChannels].RangeIndex, 0, 5)] := lNewCode;
  BalanceTrace(Format('SEND_BALANCE_CC slot=%d ch=%d lo=%d hi=%d',
    [lSlot, lChannelInSlot, lLo, lHi]));
  if not fController.Stop(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance apply stop: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;
  if not fController.SendBalanceDac(lSlot, lChannelInSlot, lLo, lHi,
    AErrorText) then
  begin
    BalanceTrace('SEND_BALANCE_CC failed: ' + AErrorText);
    Exit;
  end;
  BalanceTrace('DAC set after Stop; StartRawScan + verify');
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance apply start: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;
  lVerifySamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  BalanceTrace(Format('verify samples=%d', [lVerifySamples]));
  if not CollectChannelMean(AChannel, lVerifySamples, lVerifyMean,
    AErrorText) then
  begin
    AErrorText := 'MC-201 balance apply sample: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  BalanceTrace(Format(
    'apply cycle done: verifyMean=%.3f code=$%.4x (было $%.4x)',
    [lVerifyMean, lNewCode, lOldCode]));
  RecorderDebugLog(Format(
    '[MCBUS] balance DAC applied slot=%d channel=%d code=$%.4x mean=%.3f verify=%.3f',
    [lSlot + 1, lChannelInSlot + 1, lNewCode, AFinalMean, lVerifyMean]));
  ResetPending;
  Result := True;
end;
"""

if old not in text:
    raise SystemExit("target block not found")
write_utf8_crlf(PATH, text.replace(old, new, 1))
print("patched")
