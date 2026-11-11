#!/bin/bash
set -eu
testroot=/mnt/win_share/OburecGH/Lazarus/Tests/RecorderTests
cd "$testroot/DigitalRawCodesUiSmoke"
mkdir -p lib/linuxunits lib/linux-config
authority="$testroot/SourceUnitPipelineUiSmoke/lib/linux-Xauthority"
trap 'rm -f "$authority"' EXIT
if ! command -v xvfb-run >/dev/null 2>&1; then bash "$testroot/SourceUnitPipelineUiSmoke/prepare-linux-display.sh"; fi
python3 - <<'PY'
import xml.etree.ElementTree as ET
tree = ET.parse('DigitalRawCodesUiSmoke.lpi')
tree.find('./CompilerOptions/Target/Filename').set('Value', 'lib/linuxSmoke')
tree.find('./CompilerOptions/SearchPaths/UnitOutputDirectory').set('Value', 'lib/linuxunits')
tree.write('DigitalRawCodesUiSmokeLinux.lpi', encoding='UTF-8', xml_declaration=True)
PY
lazbuild --pcp=/home/user/.lazarus_work -B DigitalRawCodesUiSmokeLinux.lpi >build-linux.log 2>&1
if command -v xvfb-run >/dev/null 2>&1; then
  timeout 30s xvfb-run -a ./lib/linuxSmoke /cfg:"$PWD/lib/linux-config" >run-linux.log 2>&1
else
  XAUTHORITY="$authority" DISPLAY=:0 timeout 30s ./lib/linuxSmoke /cfg:"$PWD/lib/linux-config" >run-linux.log 2>&1
fi
