# -*- coding: utf-8 -*-
"""Fix MC-201 re-balance destroying a good DAC code."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

PATH = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\uRecorderMcbusDevice.pas"
)
text = read_pas(PATH)

old = r"""  CMc201AdcCodesPerDacProduct = 2.8;
var
  lChannelInSlot, lHi, lHiOffset, lLo, lLoOffset: Integer;
  lModuleIndex, lSamples, lVerifySamples: Integer;
  lTargetProduct: Double;
  lVerifyMean: Double;
  lNewCode: Word;
  lOldCode: Word;
  lSlot: Word;
begin
  Result := False;
  AFinalMean := 0;
  AErrorText := '';
  lModuleIndex := AChannel div CMc201MaxModuleChannels;
  lSlot := fProgramInfo[lModuleIndex].Slot;
  lChannelInSlot := AChannel mod CMc201MaxModuleChannels;
  { Оценка среднего: окно как у оригинала (~0.06*Fs), но не больше одной
    завершённой MDP-порции (2048). Запрос на целую секунду при Fs=57600
    давал timeout 2048/57600 и требовал несколько повторных нажатий. }
  lSamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
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
"""

new = r"""  CMc201AdcCodesPerDacProduct = 2.8;
  { Порог «уже сбалансировано» в кодах АЦП. Open-loop формула считает поправку
    от нейтрального ЦАП ($8080). Если канал уже около нуля при ненейтральном
    коде, повторный расчёт даёт почти $8080 и затирает рабочий ЦАП (стенд:
    mean≈9 при $E182 → ошибочный $8381 → mean≈530). }
  CBalanceOkThreshold = 32.0;
var
  lChannelInSlot, lHi, lHiOffset, lLo, lLoOffset: Integer;
  lModuleIndex, lSamples, lVerifySamples: Integer;
  lTargetProduct: Double;
  lVerifyMean: Double;
  lNewCode: Word;
  lOldCode: Word;
  lSlot: Word;
  lRange: Integer;
begin
  Result := False;
  AFinalMean := 0;
  AErrorText := '';
  lModuleIndex := AChannel div CMc201MaxModuleChannels;
  lSlot := fProgramInfo[lModuleIndex].Slot;
  lChannelInSlot := AChannel mod CMc201MaxModuleChannels;
  lRange := EnsureRange(fConfig.Slots[lSlot].Channels[lChannelInSlot].RangeIndex,
    0, 5);
  { Оценка среднего: окно как у оригинала (~0.06*Fs), но не больше одной
    завершённой MDP-порции (2048). Запрос на целую секунду при Fs=57600
    давал timeout 2048/57600 и требовал несколько повторных нажатий. }
  lSamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  lOldCode := GetChannelBalanceDac(AChannel);
  BalanceTrace(Format(
    'начало: индекс=%d, слот=%d, канал=%d, Fs=%.3f, проба=%d, старый ЦАП=$%.4x, devState=%d',
    [AChannel, lSlot + 1, lChannelInSlot + 1, ChannelSampleRate(AChannel),
     lSamples, lOldCode, Ord(fState)]));
  if not CollectChannelMean(AChannel, lSamples, AFinalMean, AErrorText) then
    Exit;
  if Abs(AFinalMean) <= CBalanceOkThreshold then
  begin
    BalanceTrace(Format(
      'уже сбалансировано: mean=%.3f <= %.1f, оставляем ЦАП=$%.4x',
      [AFinalMean, CBalanceOkThreshold, lOldCode]));
    Result := True;
    Exit;
  end;
  { Open-loop от текущего ненейтрального ЦАП неверен: сначала измеряем смещение
    при $8080, затем считаем новый код. }
  if lOldCode <> $8080 then
  begin
    BalanceTrace(Format(
      'сброс к нейтрали $8080 перед расчётом (было $%.4x, mean=%.3f)',
      [lOldCode, AFinalMean]));
    if not fController.SendBalanceDac(lSlot, lChannelInSlot, $80, $80,
      AErrorText) then
    begin
      BalanceTrace('neutral SEND_BALANCE failed: ' + AErrorText);
      Exit;
    end;
    fBalanceDac[AChannel] := $8080;
    fConfig.Slots[lSlot].Channels[lChannelInSlot].BalanceDac[lRange] := $8080;
    if not CollectChannelMean(AChannel, lSamples, AFinalMean, AErrorText) then
      Exit;
    if Abs(AFinalMean) <= CBalanceOkThreshold then
    begin
      BalanceTrace(Format(
        'после нейтрали mean=%.3f — дисбаланса нет, оставляем $8080',
        [AFinalMean]));
      Result := True;
      Exit;
    end;
  end;
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
"""

if old not in text:
    raise SystemExit("balance calc block not found")
text = text.replace(old, new, 1)

old2 = r"""  fBalanceDac[AChannel] := lNewCode;
  fConfig.Slots[lSlot].Channels[AChannel mod CMc201MaxModuleChannels].
    BalanceDac[EnsureRange(fConfig.Slots[lSlot].Channels[AChannel mod
      CMc201MaxModuleChannels].RangeIndex, 0, 5)] := lNewCode;
"""

new2 = r"""  fBalanceDac[AChannel] := lNewCode;
  fConfig.Slots[lSlot].Channels[lChannelInSlot].BalanceDac[lRange] := lNewCode;
"""

if old2 not in text:
    raise SystemExit("soft save block not found")
text = text.replace(old2, new2, 1)

old3 = r"""  BalanceTrace(Format(
    'apply cycle done: verifyMean=%.3f code=$%.4x (DAC must survive later Stop/Start via ApplySavedBalanceDac)',
    [lVerifyMean, lNewCode]));
  RecorderDebugLog(Format(
    '[MCBUS] balance DAC applied slot=%d channel=%d code=$%.4x mean=%.3f verify=%.3f',
    [lSlot + 1, lChannelInSlot + 1, lNewCode, AFinalMean, lVerifyMean]));
  ResetPending;
  Result := True;
end;
"""

new3 = r"""  BalanceTrace(Format(
    'apply cycle done: verifyMean=%.3f code=$%.4x (DAC must survive later Stop/Start via ApplySavedBalanceDac)',
    [lVerifyMean, lNewCode]));
  { Если verify снова «далеко от нуля» — откат к старому коду, иначе в CFG
    попадёт почти нейтральный мусор (как $8381 после второй балансировки). }
  if Abs(lVerifyMean) > Max(CBalanceOkThreshold * 4.0, Abs(AFinalMean) * 0.5) then
  begin
    BalanceTrace(Format(
      'verify плохо: %.3f — откат soft/HW к $%.4x',
      [lVerifyMean, lOldCode]));
    fBalanceDac[AChannel] := lOldCode;
    fConfig.Slots[lSlot].Channels[lChannelInSlot].BalanceDac[lRange] := lOldCode;
    if not fController.SendBalanceDac(lSlot, lChannelInSlot,
      lOldCode and $ff, lOldCode shr 8, AErrorText) then
      BalanceTrace('rollback SEND failed: ' + AErrorText);
    AErrorText := Format(
      'MC-201 balance verify failed: mean=%.3f verify=%.3f code=$%.4x',
      [AFinalMean, lVerifyMean, lNewCode]);
    Exit;
  end;
  RecorderDebugLog(Format(
    '[MCBUS] balance DAC applied slot=%d channel=%d code=$%.4x mean=%.3f verify=%.3f',
    [lSlot + 1, lChannelInSlot + 1, lNewCode, AFinalMean, lVerifyMean]));
  ResetPending;
  Result := True;
end;
"""

if old3 not in text:
    raise SystemExit("verify end block not found")
text = text.replace(old3, new3, 1)

write_utf8_crlf(PATH, text)
print("patched ok")
