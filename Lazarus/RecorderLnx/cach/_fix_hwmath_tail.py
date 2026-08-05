#!/usr/bin/env python3
import re
from pathlib import Path

p = Path(r"D:\works\OburecGH\Lazarus\SharedUtils\math\uHardwareMath.pas")
t = p.read_text(encoding="utf-8")
t = t.replace("eax???", "eax")
p.write_bytes(t.replace("\n", "\r\n").encode("utf-8"))
print("??? left", len(re.findall(r"\?{3,}", t)))
