#!/usr/bin/env python3
"""Restore uMainForm.pas encoding and apply recent code changes."""
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


def apply_patches(text: str) -> str:
    text = text.replace(
        "  uRecorderSpectrumRuntime, uRecorderMic140DataSource;\n",
        "  uRecorderSpectrumRuntime, uRecorderMic140DataSource, uRecorderMic140Utils;\n",
    )
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

    marker = (
        "{ Инициализация графических кнопок панели управления сбором }\n"
        "procedure TMainForm.SetupCommandButtons;"
    )
    if marker not in text:
        raise SystemExit("SetupCommandButtons marker not found")
    text = text.replace(marker, setup_status + "procedure TMainForm.SetupCommandButtons;")
    return text


def main() -> None:
    content = apply_patches(load_from_git())
    PAS.write_text(content, encoding="utf-8", newline="\r\n")
    bad = content.count("???")
    lines = len(nl(content).splitlines())
    print(f"Written {PAS}, lines={lines}, ??? count={bad}")
    if bad:
        raise SystemExit("File still contains ??? placeholders")


if __name__ == "__main__":
    main()
