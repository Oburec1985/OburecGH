#!/bin/bash
set -eu
base=/mnt/win_share/OburecGH/Lazarus/RecorderCoordinator
cd "$base"
mkdir -p Tests/lib/events035-linux Tests/lib/paths035-linux Tests/lib/pending035-linux/units Tests/lib/pending035-linux/config
fpc -B -FuCore -Fu../SharedUtils -Fu../RecorderLnx/SQLdb -Fu../RecorderLnx/Core -Fu../RecorderLnx \
  -FUTests/lib/events035-linux -oTests/lib/events035-linux/CoordinatorEventGroupingTest \
  Tests/CoordinatorEventGroupingTest.pas >Tests/lib/events035-linux/build.log 2>&1
Tests/lib/events035-linux/CoordinatorEventGroupingTest >Tests/lib/events035-linux/run.log 2>&1
fpc -B -Fu../RecorderLnx/SQLdb -FUTests/lib/paths035-linux \
  -oTests/lib/paths035-linux/RecorderNetworkPathIsolationTest \
  Tests/RecorderNetworkPathIsolationTest.pas >Tests/lib/paths035-linux/build.log 2>&1
Tests/lib/paths035-linux/RecorderNetworkPathIsolationTest >Tests/lib/paths035-linux/run.log 2>&1
if [ "${1:-}" = "--console-only" ]; then exit 0; fi
python3 - <<'PY'
import xml.etree.ElementTree as ET
tree = ET.parse('Tests/MeraPackagePendingUiSmoke.lpi')
tree.find('./CompilerOptions/Target/Filename').set('Value', 'lib/pending035-linux/MeraPackagePendingUiSmoke')
tree.find('./CompilerOptions/SearchPaths/UnitOutputDirectory').set('Value', 'lib/pending035-linux/units')
tree.write('Tests/MeraPackagePendingUiSmokeLinux.lpi', encoding='UTF-8', xml_declaration=True)
PY
lazbuild --pcp=/home/user/.lazarus_work -B Tests/MeraPackagePendingUiSmokeLinux.lpi \
  >Tests/lib/pending035-linux/build.log 2>&1
app_dir=$(mktemp -d /tmp/MeraPendingApp-XXXXXXXX)
if command -v xvfb-run >/dev/null 2>&1; then
  timeout 30s xvfb-run -a Tests/lib/pending035-linux/MeraPackagePendingUiSmoke \
    "/cfg:$app_dir/app.ini" >Tests/lib/pending035-linux/run.log 2>&1
else
  helper=/mnt/win_share/OburecGH/Lazarus/Tests/RecorderTests/SourceUnitPipelineUiSmoke
  trap 'rm -f "$helper/lib/linux-Xauthority"' EXIT
  bash "$helper/prepare-linux-display.sh"
  XAUTHORITY="$helper/lib/linux-Xauthority" DISPLAY=:0 timeout 30s \
    Tests/lib/pending035-linux/MeraPackagePendingUiSmoke \
    "/cfg:$app_dir/app.ini" >Tests/lib/pending035-linux/run.log 2>&1
fi
