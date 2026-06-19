#!/usr/bin/env python3
"""Move MIC-140 modules to Device/MIC140 and regenerate RecorderLnx.lpi."""
from __future__ import annotations

import re
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx")
LPI = ROOT / "RecorderLnx.lpi"

MOVES: list[tuple[str, str]] = [
    ("Core/uRecorderDeviceInterfaces.pas", "Device/uRecorderDeviceInterfaces.pas"),
    ("Core/uRecorderMic140DataSource.pas", "Device/MIC140/uRecorderMic140DataSource.pas"),
    ("Core/uRecorderMic140Utils.pas", "Device/MIC140/uRecorderMic140Utils.pas"),
    ("Core/uRecorderMic140LegacyProtocol.pas", "Device/MIC140/uRecorderMic140LegacyProtocol.pas"),
    ("Core/uRecorderMebiusTcpProtocol.pas", "Device/MIC140/uRecorderMebiusTcpProtocol.pas"),
    ("UI/uRecorderMic140SettingsDialog.pas", "Device/MIC140/UI/uRecorderMic140SettingsDialog.pas"),
    ("Docs/mic140_protocol.md", "Device/MIC140/Docs/mic140_protocol.md"),
    ("Docs/mic140_quickstart.md", "Device/MIC140/Docs/mic140_quickstart.md"),
]

COMMENT_REPLACEMENTS = [
    ("Core/uRecorderMic140Utils", "Device/MIC140/uRecorderMic140Utils"),
    ("Core/uRecorderMic140DataSource", "Device/MIC140/uRecorderMic140DataSource"),
    ("Core/uRecorderMic140LegacyProtocol", "Device/MIC140/uRecorderMic140LegacyProtocol"),
    ("Core/uRecorderMebiusTcpProtocol", "Device/MIC140/uRecorderMebiusTcpProtocol"),
    ("UI/uRecorderMic140SettingsDialog", "Device/MIC140/UI/uRecorderMic140SettingsDialog"),
    ("Core/uRecorderDeviceInterfaces", "Device/uRecorderDeviceInterfaces"),
]

FORM_UNITS: dict[str, str] = {
    "UI/uMainForm.pas": "MainForm",
    "UI/uRecorderSettingsDialog.pas": "RecorderSettingsDialog",
    "UI/uTagSettingsDialog.pas": "TagSettingsDialog",
    "UI/uRecorderCalibrationAddDialog.pas": "RecorderCalibrationAddDialog",
    "UI/uRecorderCalibrationListDialog.pas": "RecorderCalibrationListDialog",
    "UI/uRecorderCalibrationPropertiesDialog.pas": "RecorderCalibrationPropertiesDialog",
}

SEARCH_PATHS = (
    "Core;UI;Device;Device/MIC140;Device/MIC140/UI;"
    "../SharedUtils;../Tests/RecorderTests/UITestData"
)


def move_files() -> None:
    for src_rel, dst_rel in MOVES:
        src = ROOT / src_rel.replace("/", "\\")
        dst = ROOT / dst_rel.replace("/", "\\")
        if not src.exists():
            if dst.exists():
                continue
            raise FileNotFoundError(src)
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists():
            dst.unlink()
        shutil.move(str(src), str(dst))
        print(f"Moved {src_rel} -> {dst_rel}")


def read_text_auto(path: Path) -> str:
    raw = path.read_bytes()
    for enc in ("utf-8", "cp1251"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def patch_comments(path: Path) -> None:
    if not path.exists() or path.suffix.lower() not in {".pas", ".md"}:
        return
    text = read_text_auto(path)
    orig = text
    for old, new in COMMENT_REPLACEMENTS:
        text = text.replace(old, new)
    if text != orig:
        path.write_text(text, encoding="utf-8", newline="\r\n")


def patch_all_comments() -> None:
    for folder in ["Core", "UI", "Device", "Docs", "cach"]:
        base = ROOT / folder
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.suffix.lower() in {".pas", ".md"}:
                patch_comments(path)


def unit_sort_key(rel: str) -> tuple:
    order = {
        "RecorderLnx.lpr": (0, rel),
        "Core/": (1, rel),
        "Device/uRecorderDeviceInterfaces.pas": (2, rel),
        "Device/MIC140/": (3, rel),
        "Device/MIC140/UI/": (4, rel),
        "UI/": (5, rel),
        "../SharedUtils/": (6, rel),
        "../Tests/": (7, rel),
    }
    for prefix, key in order.items():
        if rel == prefix or rel.startswith(prefix):
            return key
    return (8, rel)


def discover_units() -> list[str]:
    units: list[str] = ["RecorderLnx.lpr"]
    for pattern in [
        "Core/*.pas",
        "UI/*.pas",
        "Device/*.pas",
        "Device/MIC140/*.pas",
        "Device/MIC140/UI/*.pas",
        "../SharedUtils/*.pas",
        "../Tests/RecorderTests/UITestData/*.pas",
    ]:
        for path in sorted(ROOT.glob(pattern)):
            rel = path.relative_to(ROOT).as_posix()
            if rel.startswith("../"):
                rel = "../" + path.relative_to(ROOT.parent.parent).as_posix().split("OburecGH/", 1)[-1]
            else:
                rel = path.relative_to(ROOT).as_posix()
            units.append(rel)
    # normalize SharedUtils / Tests paths
    fixed: list[str] = ["RecorderLnx.lpr"]
    fixed.extend(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / "Core").glob("*.pas")))
    fixed.append("Device/uRecorderDeviceInterfaces.pas")
    fixed.extend(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / "Device" / "MIC140").glob("*.pas")))
    fixed.extend(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / "Device" / "MIC140" / "UI").glob("*.pas")))
    fixed.extend(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / "UI").glob("*.pas")))
    shared = ROOT.parent / "SharedUtils"
    fixed.extend(sorted(f"../SharedUtils/{p.name}" for p in shared.glob("*.pas")))
    test_data = ROOT.parent / "Tests" / "RecorderTests" / "UITestData"
    fixed.extend(sorted(f"../Tests/RecorderTests/UITestData/{p.name}" for p in test_data.glob("*.pas")))
    return fixed


def has_lfm(unit_rel: str) -> bool:
    if unit_rel.startswith("../"):
        return False
    pas = ROOT / unit_rel
    return pas.with_suffix(".lfm").exists()


def write_lpi(units: list[str]) -> None:
    tree = ET.parse(LPI)
    root = tree.getroot()
    units_node = root.find("./ProjectOptions/Units")
    if units_node is None:
        raise RuntimeError("Units node not found")
    units_node.clear()

    for rel in units:
        unit_el = ET.SubElement(units_node, "Unit")
        fn = ET.SubElement(unit_el, "Filename")
        fn.set("Value", rel.replace("\\", "/"))
        part = ET.SubElement(unit_el, "IsPartOfProject")
        part.set("Value", "True")
        comp = FORM_UNITS.get(rel.replace("\\", "/"))
        if comp:
            cn = ET.SubElement(unit_el, "ComponentName")
            cn.set("Value", comp)
            if has_lfm(rel.replace("\\", "/")):
                hr = ET.SubElement(unit_el, "HasResources")
                hr.set("Value", "True")
            rb = ET.SubElement(unit_el, "ResourceBaseClass")
            rb.set("Value", "Form")

    search = root.find("./CompilerOptions/SearchPaths/OtherUnitFiles")
    if search is not None:
        search.set("Value", SEARCH_PATHS)

    tree.write(LPI, encoding="UTF-8", xml_declaration=True)
    # Lazarus prefers CRLF in lpi
    text = LPI.read_text(encoding="utf-8")
    LPI.write_text(text.replace("\n", "\r\n"), encoding="utf-8")


def main() -> None:
    for src_rel, dst_rel in MOVES:
        dst = ROOT / dst_rel.replace("/", "\\")
        if not dst.exists():
            move_files()
            break
    else:
        print("Moves already applied, skipping.")
    patch_all_comments()
    units = discover_units()
    write_lpi(units)
    print(f"LPI updated: {len(units)} units")


if __name__ == "__main__":
    main()
