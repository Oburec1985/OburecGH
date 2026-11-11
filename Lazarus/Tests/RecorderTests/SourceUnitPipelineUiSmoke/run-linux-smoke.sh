#!/bin/bash
set -eu
cd /mnt/win_share/OburecGH/Lazarus/Tests/RecorderTests/SourceUnitPipelineUiSmoke
mkdir -p lib/linuxunits lib/linux-config
trap 'rm -f lib/linux-Xauthority' EXIT
if ! command -v xvfb-run >/dev/null 2>&1; then bash ./prepare-linux-display.sh; fi
python3 - <<'PY'
import xml.etree.ElementTree as ET
tree = ET.parse('SourceUnitPipelineUiSmoke.lpi')
tree.find('./CompilerOptions/Target/Filename').set('Value', 'lib/linuxSmoke')
tree.find('./CompilerOptions/SearchPaths/UnitOutputDirectory').set('Value', 'lib/linuxunits')
tree.write('SourceUnitPipelineUiSmokeLinux.lpi', encoding='UTF-8', xml_declaration=True)
PY
lazbuild --pcp=/home/user/.lazarus_work -B SourceUnitPipelineUiSmokeLinux.lpi >build-linux.log 2>&1
if command -v xvfb-run >/dev/null 2>&1; then
  timeout 30s xvfb-run -a ./lib/linuxSmoke /cfg:"$PWD/lib/linux-config" >run-linux.log 2>&1
else
  XAUTHORITY="$PWD/lib/linux-Xauthority" DISPLAY=:0 timeout 30s ./lib/linuxSmoke /cfg:"$PWD/lib/linux-config" >run-linux.log 2>&1
fi
