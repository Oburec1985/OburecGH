# -*- coding: utf-8 -*-
"""Fix CFG comma parse + ApplySavedBalanceDac logging."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

PATH = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\uRecorderMcbusDevice.pas"
)

text = read_pas(PATH)

old_apply = """      lPrefix := 'CFG slot=';
      if Pos(lPrefix, Trim(lLines[I])) <> 1 then
        Continue;
      lFields.DelimitedText := Copy(Trim(lLines[I]), Length(lPrefix) + 1,
        MaxInt);
      lSlot := StrToIntDef(lFields[0], 0) - 1;"""

new_apply = """      lPrefix := 'CFG slot=';
      if Pos(lPrefix, Trim(lLines[I])) <> 1 then
        Continue;
      { Поля CFG должны разделяться ';'. Старые записи с ',' тоже читаем. }
      lFields.DelimitedText := StringReplace(
        Copy(Trim(lLines[I]), Length(lPrefix) + 1, MaxInt), ',', ';',
        [rfReplaceAll]);
      lSlot := StrToIntDef(lFields[0], 0) - 1;"""

if old_apply not in text:
    if "StringReplace(" in text and "CFG slot=" in text:
        print("apply parse already patched")
    else:
        raise SystemExit("apply block missing")
else:
    text = text.replace(old_apply, new_apply, 1)
    print("apply parse patched")

old_loop = """    lCode := GetChannelBalanceDac(I);
    if not fController.SendBalanceDac(lSlot, lChannelInSlot,
      lCode and $ff, lCode shr 8, fLastError) then
    begin
      AErrorText := Format('MC-032 restore balance slot=%d channel=%d: %s',
        [lSlot + 1, lChannelInSlot + 1, fLastError]);
      Exit;
    end;"""

new_loop = """    lCode := GetChannelBalanceDac(I);
    if lCode <> $8080 then
      BalanceTrace(Format(
        'ApplySavedBalanceDac ch=%d slot=%d idx=%d code=$%.4x',
        [I, lSlot + 1, lChannelInSlot, lCode]));
    if not fController.SendBalanceDac(lSlot, lChannelInSlot,
      lCode and $ff, lCode shr 8, fLastError) then
    begin
      AErrorText := Format('MC-032 restore balance slot=%d channel=%d: %s',
        [lSlot + 1, lChannelInSlot + 1, fLastError]);
      BalanceTrace(AErrorText);
      Exit;
    end;"""

if old_loop not in text:
    if "ApplySavedBalanceDac ch=" in text:
        print("apply saved log already patched")
    else:
        idx = text.find("GetChannelBalanceDac(I)")
        print(repr(text[idx : idx + 400]))
        raise SystemExit("apply saved loop missing")
else:
    text = text.replace(old_loop, new_loop, 1)
    print("apply saved log patched")

write_utf8_crlf(PATH, text)
print("written", PATH)
