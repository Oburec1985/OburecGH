#!/usr/bin/env python3
"""Batch-fix corrupted Cyrillic comments in RecorderLnx and chart_lzr .pas files."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

REPO = Path(r"D:\works\OburecGH")
RECORDER = REPO / "Lazarus/RecorderLnx"
CACH = RECORDER / "cach"
SCAN_ROOTS = [
    RECORDER,
    REPO / "Lazarus/SharedUtils/components/chart_lzr",
    REPO / "Lazarus/SharedUtils/math",
    REPO / "Lazarus/SharedUtils",
]
SKIP_DIRS = {"cach", "backup", "__history__", ".git"}
CORRUPT_BYTE = "\x98"
MOJIBAKE = "пїЅ"
GIT = ["git", "-C", str(REPO)]

UTF8_BACKUPS = {
    "uRecorderTags.pas": CACH / "uRecorderTags_utf8.pas",
    "uRecorderProjectFiles.pas": CACH / "uRecorderProjectFiles_utf8.pas",
}


def nl(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def to_crlf(text: str) -> bytes:
    return nl(text).replace("\n", "\r\n").encode("utf-8")


def read_text(path: Path) -> str:
    return nl(path.read_text(encoding="utf-8"))


def git_show(rel: str) -> bytes | None:
    try:
        return subprocess.check_output([*GIT, "show", f"HEAD:{rel}"], stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return None


def git_rel(path: Path) -> str | None:
    try:
        rel = path.relative_to(REPO).as_posix()
    except ValueError:
        return None
    return rel if git_show(rel) is not None else None


def ascii_skeleton(s: str) -> str:
    return re.sub(r"[^\x20-\x7e]", "", s)


def score_text(text: str) -> tuple[int, int, int]:
    cyr = sum(1 for c in text if "\u0400" <= c <= "\u04FF")
    bad = text.count("\ufffd") + text.count(CORRUPT_BYTE) + text.count(MOJIBAKE)
    q = len(re.findall(r"\?{3,}", text))
    return cyr, bad, q


def looks_like_utf8_cyrillic(raw: bytes) -> bool:
    return b"\xd0" in raw or b"\xd1" in raw


def decode_cp1251(raw: bytes) -> str | None:
    try:
        return nl(raw.decode("cp1251"))
    except UnicodeDecodeError:
        return None


def decode_utf8(raw: bytes) -> str | None:
    try:
        return nl(raw.decode("utf-8"))
    except UnicodeDecodeError:
        return None


def line_map_from_reference(text: str) -> dict[str, list[str]]:
    gmap: dict[str, list[str]] = {}
    for line in text.split("\n"):
        sk = ascii_skeleton(line)
        if sk.strip():
            gmap.setdefault(sk, []).append(line)
    return gmap


def repair_lines(disk_text: str, references: list[str]) -> tuple[str, int, int]:
    maps = [line_map_from_reference(ref) for ref in references]
    out: list[str] = []
    fixed = unfixed = 0
    for line in disk_text.split("\n"):
        if CORRUPT_BYTE not in line and MOJIBAKE not in line and "\ufffd" not in line:
            out.append(line)
            continue
        sk = ascii_skeleton(re.sub(r"[\ufffd" + CORRUPT_BYTE + MOJIBAKE + r"]+", "", line))
        chosen = None
        for gmap in maps:
            if sk in gmap:
                chosen = min(gmap[sk], key=lambda g: abs(len(g) - len(line)))
                break
        if chosen is not None:
            out.append(chosen)
            fixed += 1
        else:
            out.append(re.sub(r"[\x98\ufffd]|" + re.escape(MOJIBAKE), "?", line))
            unfixed += 1
    return "\n".join(out), fixed, unfixed


def ensure_utf8_codepage(text: str) -> str:
    text = text.replace("{$codepage cp1251}", "{$codepage UTF8}")
    if "{$codepage UTF8}" not in text and re.search(r"[А-Яа-яЁё]", text):
        text = text.replace("{$mode objfpc}{$H+}", "{$mode objfpc}{$H+}\n{$codepage UTF8}", 1)
    return text


def should_skip(path: Path) -> bool:
    if any(part in SKIP_DIRS for part in path.parts):
        return True
    return path.name in {"uRecorderFormModel.pas", "uMainForm.pas"}


def iter_pas_files() -> list[Path]:
    files: list[Path] = []
    seen: set[Path] = set()
    for root in SCAN_ROOTS:
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("*.pas")):
            if should_skip(path):
                continue
            rp = path.resolve()
            if rp in seen:
                continue
            seen.add(rp)
            files.append(path)
    return files


def choose_source(raw: bytes, path: Path) -> tuple[str, str]:
    utf = decode_utf8(raw)
    cp = decode_cp1251(raw)

    if utf is not None:
        _, bad_u, q_u = score_text(utf)
        if bad_u == 0 and q_u == 0 and sum(1 for c in utf if "\u0400" <= c <= "\u04FF") > 0:
            return utf, "keep-utf8"

    if MOJIBAKE in (utf or "") or (utf is not None and "\ufffd" in utf):
        backup = UTF8_BACKUPS.get(path.name)
        refs: list[str] = []
        if backup and backup.is_file():
            refs.append(read_text(backup))
        rel = git_rel(path)
        if rel:
            blob = git_show(rel)
            if blob is not None:
                refs.append(nl(blob.decode("cp1251")))
        if refs:
            repaired, fixed, unfixed = repair_lines(utf or nl(raw.decode("latin-1")), refs)
            if unfixed:
                print(f"    warning: {unfixed} lines still unmatched")
            print(f"    repaired mojibake using {fixed} reference lines")
            return repaired, "repair-mojibake"

    if cp is not None and not looks_like_utf8_cyrillic(raw):
        return cp, "cp1251"

    if utf is not None and CORRUPT_BYTE in utf:
        rel = git_rel(path)
        if rel:
            blob = git_show(rel)
            if blob is not None:
                repaired, fixed, unfixed = repair_lines(utf, [nl(blob.decode("cp1251"))])
                print(f"    repaired \\x98 using {fixed} git lines")
                if unfixed:
                    print(f"    warning: {unfixed} \\x98 lines unmatched")
                return repaired, "repair-x98"

    if cp is not None:
        return cp, "cp1251-fallback"

    if utf is not None:
        return utf, "utf8-fallback"

    return nl(raw.decode("latin-1")), "latin1-fallback"


def fix_hardware_math_comments(text: str) -> str:
    return text.replace(
        "третий в ecx???, ост-ые - стек.",
        "третий — указатель результата, остальные — стек.",
    ).replace(
        "// D2 ???????? ????????? ??? ????? ??????????? ???????",
        "// D2 содержит размерность для цикла перемножения массивов",
    ).replace(
        "// ??????? ?????????? ???????? ????? eax???",
        "// размер передаётся отдельно через eax",
    )


def fix_file(path: Path) -> bool:
    raw = path.read_bytes()
    text, mode = choose_source(raw, path)
    if mode == "keep-utf8":
        return False

    if path.name == "uHardwareMath.pas":
        text = fix_hardware_math_comments(text)

    text = ensure_utf8_codepage(text)
    _, bad, q = score_text(text)
    if bad or q:
        raise RuntimeError(f"{path}: still corrupted after fix (bad={bad}, ???={q})")

    path.write_bytes(to_crlf(text))
    cyr = sum(1 for c in text if "\u0400" <= c <= "\u04FF")
    print(f"  {mode}: {path.relative_to(REPO)} (cyrillic={cyr})")
    return True


def fix_ubldlfmfile() -> None:
    path = REPO / "Lazarus/SharedUtils/ubldlfmfile.pas"
    if not path.is_file():
        return
    text = read_text(path)
    text = text.replace(
        "// Имя канала    //!!!???",
        "// Имя канала (формат поля в файле уточняется)",
    ).replace(
        "// Pasport !!!??? 4 байта у Олега Борисовича!!!",
        "// Pasport — 4 байта у Олега Борисовича (формат уточняется)",
    )
    path.write_bytes(to_crlf(text))


def main() -> None:
    changed = 0
    print("Fixing .pas encodings and comments...")
    for path in iter_pas_files():
        if fix_file(path):
            changed += 1
    fix_ubldlfmfile()

    problems: list[str] = []
    for path in list(iter_pas_files()) + [
        RECORDER / "Core/uRecorderFormModel.pas",
        RECORDER / "UI/uMainForm.pas",
    ]:
        if not path.is_file():
            continue
        text = read_text(path)
        _, bad, q = score_text(text)
        if bad or q:
            problems.append(f"{path.relative_to(REPO)}: bad={bad} ???={q}")

    print(f"\nChanged files: {changed}")
    if problems:
        print("Remaining problems:")
        for item in problems:
            print(f"  {item}")
        raise SystemExit(1)
    print("OK")


if __name__ == "__main__":
    main()
