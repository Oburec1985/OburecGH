#!/usr/bin/env python3
"""Restore uMainForm.pas UTF-8 from git cp1251 and apply functional patches."""
from __future__ import annotations

import subprocess
from pathlib import Path

REPO = Path(r"D:\works\OburecGH")
PAS = REPO / "Lazarus/RecorderLnx/UI/uMainForm.pas"
GIT_PATH = "Lazarus/RecorderLnx/UI/uMainForm.pas"


def nl(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def to_crlf(text: str) -> str:
    return nl(text).replace("\n", "\r\n")


def load_from_git() -> str:
    raw = subprocess.check_output(
        ["git", "-C", str(REPO), "show", f"origin/master:{GIT_PATH}"]
    )
    text = nl(raw.decode("cp1251"))
    text = text.replace("{$codepage cp1251}", "{$codepage UTF8}")
    if "Кодировка (2026-06)" not in text:
        text = text.replace(
            "    посредством TFormEditorController. Изменения сохраняются в файлы проекта (.gui, .ini, .tags).\n}",
            "    посредством TFormEditorController. Изменения сохраняются в файлы проекта (.gui, .ini, .tags).\n\n"
            "  Кодировка (2026-06): файл в UTF-8. См. Docs/source-encoding.md.\n}",
            1,
        )
    return text


def apply_base_patches(text: str) -> str:
    if "uRecorderMic140Utils" not in text:
        text = text.replace(
            "  uRecorderSpectrumRuntime, uRecorderMic140DataSource;\n",
            "  uRecorderSpectrumRuntime, uRecorderMic140DataSource, uRecorderMic140Utils;\n",
        )
    if "procedure SetupStatusBanner;" not in text:
        text = text.replace(
            "    procedure SetupCommandButtons;\n",
            "    procedure SetupCommandButtons;\n    procedure SetupStatusBanner;\n",
        )
        text = text.replace(
            "  LoadRecorderCommandImages(ilCommandButtons);\n  SetupCommandButtons;\n",
            "  LoadRecorderCommandImages(ilCommandButtons);\n  SetupStatusBanner;\n  SetupCommandButtons;\n",
        )
    text = text.replace(
        "  btnSaveConfigAs.ImageIndex := CIconSaveConfig;\n",
        "  btnSaveConfigAs.ImageIndex := CIconSaveConfigAs;\n",
    )
    marker = (
        "{ Инициализация графических кнопок панели управления сбором }\n"
        "procedure TMainForm.SetupCommandButtons;"
    )
    if marker in text and "procedure TMainForm.SetupStatusBanner;" not in text:
        setup_status = (
            "{ Настройка шрифтов баннера состояния/времени под высоту pnRightStatus }\n"
            "procedure TMainForm.SetupStatusBanner;\n"
            "var\n"
            "  lHalf, lStateSize, lTimeSize: Integer;\n"
            "begin\n"
            "  lHalf := pnRightStatus.ClientHeight div 2;\n"
            "  if lHalf < 24 then\n"
            "    lHalf := 24;\n"
            "\n"
            "  lStateSize := Max(12, pnRightStatus.ClientHeight div 5);\n"
            "  lTimeSize := Max(14, pnRightStatus.ClientHeight div 4);\n"
            "\n"
            "  lbState.AutoSize := False;\n"
            "  lbState.Align := alTop;\n"
            "  lbState.Height := lHalf;\n"
            "  lbState.Layout := tlCenter;\n"
            "  lbState.Font.Name := Font.Name;\n"
            "  lbState.Font.Size := lStateSize;\n"
            "  lbState.Font.Style := [fsBold];\n"
            "\n"
            "  lbTime.AutoSize := False;\n"
            "  lbTime.Align := alClient;\n"
            "  lbTime.Layout := tlCenter;\n"
            "  lbTime.Font.Name := Font.Name;\n"
            "  lbTime.Font.Size := lTimeSize;\n"
            "  lbTime.Font.Style := [fsBold];\n"
            "end;\n"
            "\n"
        )
        text = text.replace(marker, setup_status + "procedure TMainForm.SetupCommandButtons;")
    return text


def apply_recent_patches(text: str) -> str:
    old_rebuild = """procedure TMainForm.RebuildTagList(const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lFrequencyText: string;
  lTag: TRecorderTag;
begin
  lbTags.Items.BeginUpdate;
  try
    lbTags.Items.Clear;
    lFilter := LowerCase(Trim(AFilter));

    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if (lFilter <> '') and
        (Pos(lFilter, LowerCase(lTag.Name + ' ' + lTag.Address + ' ' +
        lTag.Description)) = 0) then
        Continue;

      if lTag.PollFrequencyHz > 0 then
        lFrequencyText := FormatFloat('0.######', lTag.PollFrequencyHz) + ' Hz'
      else
        lFrequencyText := '-';

      lbTags.Items.AddObject(Format('%s     %s', [lTag.Name, lFrequencyText]), lTag);
    end;
  finally
    lbTags.Items.EndUpdate;
  end;
end;"""

    new_rebuild = """procedure TMainForm.RebuildTagList(const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lFrequencyText: string;
  lSelectedTag: TRecorderTag;
  lTag: TRecorderTag;
  lTopIndex: Integer;
begin
  lTopIndex := lbTags.TopIndex;
  lSelectedTag := nil;
  if (lbTags.ItemIndex >= 0) and
    (lbTags.Items.Objects[lbTags.ItemIndex] is TRecorderTag) then
    lSelectedTag := TRecorderTag(lbTags.Items.Objects[lbTags.ItemIndex]);

  lbTags.Items.BeginUpdate;
  try
    lbTags.Items.Clear;
    lFilter := LowerCase(Trim(AFilter));

    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if (lFilter <> '') and
        (Pos(lFilter, LowerCase(lTag.Name + ' ' + lTag.Address + ' ' +
        lTag.Description)) = 0) then
        Continue;

      if lTag.PollFrequencyHz > 0 then
        lFrequencyText := FormatFloat('0.######', lTag.PollFrequencyHz) + ' Hz'
      else
        lFrequencyText := '-';

      lbTags.Items.AddObject(Format('%s     %s', [lTag.Name, lFrequencyText]), lTag);
    end;

    if lSelectedTag <> nil then
      for I := 0 to lbTags.Items.Count - 1 do
        if lbTags.Items.Objects[I] = lSelectedTag then
        begin
          lbTags.ItemIndex := I;
          Break;
        end;
    if (lbTags.Items.Count > 0) and (lTopIndex < lbTags.Items.Count) then
      lbTags.TopIndex := lTopIndex;
  finally
    lbTags.Items.EndUpdate;
  end;
end;"""

    if old_rebuild in text:
        text = text.replace(old_rebuild, new_rebuild)

    old_drain = """procedure TMainForm.DrainUiEventQueue(Sender: TObject);
var
  lChanged: Boolean;
  lSnapshot: TRecorderEventSnapshot;
  lStart: QWord;
  lCount: Integer;
begin
  lStart := GetTickCount64;
  lCount := 0;
  Inc(fDiagUiTicks);
  lChanged := False;
  repeat
    lSnapshot := fEventQueue.Pop;
    if lSnapshot = nil then
      Break;
    try
      ApplyTagEventSnapshot(lSnapshot);
      Inc(fDiagDataEvents);
      Inc(lCount);
      lChanged := True;
    finally
      lSnapshot.Free;
    end;
  until False;

  if lChanged then
    RebuildTagList(edTagSearch.Text);

  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) then"""

    new_drain = """procedure TMainForm.DrainUiEventQueue(Sender: TObject);
var
  lSnapshot: TRecorderEventSnapshot;
  lStart: QWord;
  lCount: Integer;
begin
  lStart := GetTickCount64;
  lCount := 0;
  Inc(fDiagUiTicks);
  repeat
    lSnapshot := fEventQueue.Pop;
    if lSnapshot = nil then
      Break;
    try
      ApplyTagEventSnapshot(lSnapshot);
      Inc(fDiagDataEvents);
      Inc(lCount);
    finally
      lSnapshot.Free;
    end;
  until False;

  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) then"""

    if old_drain in text:
        text = text.replace(old_drain, new_drain)

    text = text.replace(
        "      lLine := lComponent.AddLine;\n"
        "      lLine.Name := lTag.Name;\n"
        "      lLine.TagName := lTag.Name;\n",
        "      lLine := lComponent.AddLine;\n"
        "      lLine.TagName := lTag.Name;\n",
    )
    return text


def main() -> None:
    content = apply_recent_patches(apply_base_patches(load_from_git()))
    PAS.write_bytes(to_crlf(content).encode("utf-8"))
    bad_q = content.count("???")
    cyr = sum(1 for c in content if "\u0400" <= c <= "\u04FF")
    print(f"Written {PAS}, cyrillic_chars={cyr}, ??? count={bad_q}")
    if bad_q:
        raise SystemExit("File still contains ??? placeholders")
    if cyr < 100:
        raise SystemExit("Too few Cyrillic characters — encoding restore failed")


if __name__ == "__main__":
    main()
