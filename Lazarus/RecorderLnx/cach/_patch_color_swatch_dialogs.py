#!/usr/bin/env python3
"""Replace color edit+button with TRecorderColorSwatch in settings dialogs."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

OSC = ROOT / "UI" / "uRecorderOscillogramSettingsDialog.pas"
TREND = ROOT / "UI" / "uRecorderTrendSettingsDialog.pas"


def patch_oscillogram(text: str) -> str:
    text = text.replace(
        "  uRecorderFormModel, uRecorderTags;",
        "  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags;",
        1,
    )
    text = text.replace(
        "    fLineColorEdit: TEdit;\n    fLineColorButton: TButton;",
        "    fLineColorSwatch: TRecorderColorSwatch;",
        1,
    )
    text = text.replace(
        "    procedure LineColorClick(Sender: TObject);\n",
        "",
        1,
    )
    text = text.replace(
        """  fLineColorEdit := TEdit.Create(Self);
  fLineColorEdit.Parent := Self;
  fLineColorEdit.SetBounds(90, lTop, 100, 23);

  fLineColorButton := TButton.Create(Self);
  fLineColorButton.Parent := Self;
  fLineColorButton.SetBounds(200, lTop, 80, 25);
  fLineColorButton.Caption := 'Выбрать';
  fLineColorButton.OnClick := @LineColorClick;

  fLineVisibleCheck := TCheckBox.Create(Self);
  fLineVisibleCheck.Parent := Self;
  fLineVisibleCheck.SetBounds(300, lTop + 2, 120, 20);""",
        """  fLineColorSwatch := TRecorderColorSwatch.Create(Self);
  fLineColorSwatch.Parent := Self;
  fLineColorSwatch.SetBounds(90, lTop, 28, 24);

  fLineVisibleCheck := TCheckBox.Create(Self);
  fLineVisibleCheck.Parent := Self;
  fLineVisibleCheck.SetBounds(130, lTop + 2, 120, 20);""",
        1,
    )
    text = text.replace(
        "  fLineColorEdit.Enabled := lEnabled;\n  fLineColorButton.Enabled := lEnabled;\n",
        "  fLineColorSwatch.Enabled := lEnabled;\n",
        1,
    )
    text = text.replace(
        "    fLineColorEdit.Text := '';\n",
        "",
        1,
    )
    text = text.replace(
        "  fLineColorEdit.Text := ColorText(lLine.Color);\n",
        "  fLineColorSwatch.LineColor := TColor(lLine.Color);\n",
        1,
    )
    text = text.replace(
        "  lLine.Color := ParseColorText(fLineColorEdit.Text, lLine.Color);\n",
        "  lLine.Color := LongInt(fLineColorSwatch.LineColor);\n",
        1,
    )
    # remove LineColorClick procedure block
    start = text.find("procedure TRecorderOscillogramSettingsDialog.LineColorClick")
    if start >= 0:
        end = text.find("procedure TRecorderOscillogramSettingsDialog.TagSearchEditChange", start)
        if end > start:
            text = text[:start] + text[end:]
    return text


def patch_trend(text: str) -> str:
    text = text.replace(
        "  uRecorderFormModel, uRecorderTags;",
        "  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags;",
        1,
    )
    text = text.replace(
        "    fLineColorEdit: TEdit;\n    fLineColorButton: TButton;",
        "    fLineColorSwatch: TRecorderColorSwatch;",
        1,
    )
    text = text.replace(
        "    fAxisColorEdit: TEdit;\n    fAxisColorButton: TButton;",
        "    fAxisColorSwatch: TRecorderColorSwatch;",
        1,
    )
    text = text.replace(
        "    procedure LineColorClick(Sender: TObject);\n",
        "",
        1,
    )
    text = text.replace(
        "    procedure AxisColorClick(Sender: TObject);\n",
        "",
        1,
    )
    text = text.replace(
        """  fLineColorEdit := TEdit.Create(Self);
  fLineColorEdit.Parent := Self;
  fLineColorEdit.SetBounds(78, 246, 120, 24);
  fLineColorEdit.OnDblClick := @LineColorClick;
  fLineColorButton := TButton.Create(Self);
  fLineColorButton.Parent := Self;
  fLineColorButton.SetBounds(204, 246, 32, 24);
  fLineColorButton.Caption := '...';
  fLineColorButton.OnClick := @LineColorClick;""",
        """  fLineColorSwatch := TRecorderColorSwatch.Create(Self);
  fLineColorSwatch.Parent := Self;
  fLineColorSwatch.SetBounds(78, 246, 28, 24);""",
        1,
    )
    text = text.replace(
        """  fAxisColorEdit := TEdit.Create(Self);
  fAxisColorEdit.Parent := Self;
  fAxisColorEdit.SetBounds(410, 368, 100, 24);
  fAxisColorEdit.OnDblClick := @AxisColorClick;
  fAxisColorButton := TButton.Create(Self);
  fAxisColorButton.Parent := Self;
  fAxisColorButton.SetBounds(515, 368, 32, 24);
  fAxisColorButton.Caption := '...';
  fAxisColorButton.OnClick := @AxisColorClick;""",
        """  fAxisColorSwatch := TRecorderColorSwatch.Create(Self);
  fAxisColorSwatch.Parent := Self;
  fAxisColorSwatch.SetBounds(410, 368, 28, 24);""",
        1,
    )
    text = text.replace(
        "  fLineColorEdit.Enabled := AIndex >= 0;\n  fLineColorButton.Enabled := AIndex >= 0;\n",
        "  fLineColorSwatch.Enabled := AIndex >= 0;\n",
        1,
    )
    text = text.replace(
        "    fLineColorEdit.Text := ColorText(clBlue);\n",
        "    fLineColorSwatch.LineColor := clBlue;\n",
        1,
    )
    text = text.replace(
        "  fLineColorEdit.Text := ColorText(TColor(lLine.Color));\n",
        "  fLineColorSwatch.LineColor := TColor(lLine.Color);\n",
        1,
    )
    text = text.replace(
        "  lLine.Color := LongInt(ParseColorText(fLineColorEdit.Text, TColor(lLine.Color)));\n",
        "  lLine.Color := LongInt(fLineColorSwatch.LineColor);\n",
        1,
    )
    text = text.replace(
        "  fAxisColorEdit.Enabled := AIndex >= 0;\n  fAxisColorButton.Enabled := AIndex >= 0;\n",
        "  fAxisColorSwatch.Enabled := AIndex >= 0;\n",
        1,
    )
    text = text.replace(
        "    fAxisColorEdit.Text := ColorText(clBlue);\n",
        "    fAxisColorSwatch.LineColor := clBlue;\n",
        1,
    )
    text = text.replace(
        "  fAxisColorEdit.Text := ColorText(TColor(lAxis.Color));\n",
        "  fAxisColorSwatch.LineColor := TColor(lAxis.Color);\n",
        1,
    )
    text = text.replace(
        "  lAxis.Color := LongInt(ParseColorText(fAxisColorEdit.Text, TColor(lAxis.Color)));\n",
        "  lAxis.Color := LongInt(fAxisColorSwatch.LineColor);\n",
        1,
    )
    for proc in (
        "procedure TRecorderTrendSettingsDialog.LineColorClick",
        "procedure TRecorderTrendSettingsDialog.AxisColorClick",
    ):
        start = text.find(proc)
        if start >= 0:
            end = text.find("\nprocedure ", start + 1)
            if end < 0:
                end = text.find("\nfunction ", start + 1)
            if end > start:
                text = text[:start] + text[end + 1:]
    return text


def write_pas(path: Path, content: str) -> None:
    path.write_bytes(content.replace("\n", "\r\n").encode("utf-8"))


write_pas(OSC, patch_oscillogram(OSC.read_text(encoding="utf-8")))
write_pas(TREND, patch_trend(TREND.read_text(encoding="cp1251")))
print("OK:", OSC.name, TREND.name)
