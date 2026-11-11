#!/bin/bash
set -eu
cd /mnt/win_share/OburecGH/Lazarus/Tests/RecorderTests/SourceUnitPipelineUiSmoke
if command -v xvfb-run >/dev/null 2>&1; then exit 0; fi
python3 - <<'PY'
import pathlib, re, subprocess
config = pathlib.Path('/mnt/win_share/OburecGH/installer/RecorderLnx/update-kip-arm.local.psd1').read_text(encoding='utf-8-sig')
password = re.search(r"VmPassword\s*=\s*'([^']*)'", config).group(1)
args = subprocess.check_output(['ps', '-C', 'Xorg', '-o', 'args='], text=True)
authority = re.search(r'-auth\s+(\S+)', args).group(1)
result = subprocess.run(['sudo', '-S', '-p', '', 'cat', authority], input=(password+'\n').encode(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
target = pathlib.Path('lib/linux-Xauthority')
target.write_bytes(result.stdout)
target.chmod(0o600)
PY
