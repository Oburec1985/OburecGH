# -*- coding: utf-8 -*-
"""Copy comments from origin/master into current uRecorderSettingsDialog.pas."""
import re
import subprocess
from pathlib import Path

repo = Path(r"D:\works\OburecGH")
current_path = repo / "Lazarus/RecorderLnx/UI/uRecorderSettingsDialog.pas"
github_raw = repo / "Lazarus/RecorderLnx/cach/uRecorderSettingsDialog_github_raw.pas"

if not github_raw.exists():
    raw = subprocess.check_output(
        ["git", "-C", str(repo), "show", "origin/master:Lazarus/RecorderLnx/UI/uRecorderSettingsDialog.pas"]
    )
    github_raw.write_bytes(raw)

github_lines = github_raw.read_bytes().decode("cp1251").splitlines()

# current file may be cp1251 or utf-8 with mojibake
cur_bytes = current_path.read_bytes()
try:
    current_lines = cur_bytes.decode("cp1251").splitlines()
except UnicodeDecodeError:
    current_lines = cur_bytes.decode("utf-8", errors="replace").splitlines()


def norm_code(part: str) -> str:
    return re.sub(r"\s+", " ", part.strip())


def merge_line(cur: str, gh: str) -> str:
    if "//" in cur and "//" in gh:
        code = cur.split("//", 1)[0].rstrip()
        comment = gh.split("//", 1)[1].strip()
        return f"{code} // {comment}"
    cur_st = cur.strip()
    gh_st = gh.strip()
    if cur_st.startswith("{") and cur_st.endswith("}") and gh_st.startswith("{"):
        indent = cur[: len(cur) - len(cur.lstrip())]
        return indent + gh_st
    return cur


gh_by_code: dict[str, str] = {}
for gl in github_lines:
    if "//" not in gl:
        continue
    key = norm_code(gl.split("//", 1)[0])
    if key:
        gh_by_code[key] = gl

out_lines: list[str] = []
for i, cl in enumerate(current_lines):
    if "//" in cl:
        key = norm_code(cl.split("//", 1)[0])
        gh = gh_by_code.get(key)
        if gh:
            out_lines.append(merge_line(cl, gh))
            continue
    if cl.strip().startswith("{") and cl.strip().endswith("}"):
        if i < len(github_lines) and github_lines[i].strip().startswith("{"):
            out_lines.append(merge_line(cl, github_lines[i]))
            continue
    out_lines.append(cl)

# module header
start = next(i for i, l in enumerate(out_lines) if i == 2 and l.strip() == "{")
end = next(i for i, l in enumerate(out_lines) if i > start and l.strip() == "}")
gh_start = next(i for i, l in enumerate(github_lines) if l.strip() == "{")
gh_end = next(i for i, l in enumerate(github_lines) if i > gh_start and l.strip() == "}")
out_lines[start : end + 1] = github_lines[gh_start : gh_end + 1]

result = "\r\n".join(out_lines) + "\r\n"
current_path.write_bytes(result.encode("cp1251", errors="strict"))
print("OK:", current_path, "lines", len(out_lines))
