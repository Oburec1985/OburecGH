#!/bin/bash
set -euo pipefail

repo=${1:-/mnt/win_share/OburecGH}
pcp=${RECORDER_LAZARUS_PCP:-/home/user/.lazarus_work}
log="$repo/installer/RecorderLnx/linux/Output/build-linux-latest.log"

mkdir -p "$(dirname "$log")"
exec > >(tee "$log") 2>&1

echo "Linux build started: $(date -Iseconds)"
lazbuild --pcp="$pcp" -B "$repo/Lazarus/RecorderLnx/RecorderLnx.lpi"
lazbuild --pcp="$pcp" -B "$repo/Lazarus/RecorderHostAgent/RecorderHostAgent.lpi"
lazbuild --pcp="$pcp" -B "$repo/Lazarus/RecorderCoordinator/RecorderCoordinator.lpi"
lazbuild --pcp="$pcp" -B "$repo/Lazarus/RecorderLnx/Plugins/LuaCalcPlugin/LuaCalcPlugin.lpi"
lazbuild --pcp="$pcp" -B "$repo/Lazarus/RecorderLnx/Plugins/SampleInfoPlugin/SampleInfoPlugin.lpi"
lazbuild --pcp="$pcp" -B "$repo/Lazarus/RecorderLnx/Tools/LinuxSetupManager/LinuxSetupManager.lpi"
lazbuild --pcp="$pcp" -B "$repo/Lazarus/RecorderLnx/Tools/LinuxSetupManager/LinuxSetupManagerCli.lpi"
sha256sum "$repo/Lazarus/RecorderLnx/lib/x86_64-linux/RecorderLnx"
echo "Linux build finished: $(date -Iseconds)"
