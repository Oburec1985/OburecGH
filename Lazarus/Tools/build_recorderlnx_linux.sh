#!/bin/bash
set -o pipefail

# Единая команда контрольной Linux-сборки RecorderLnx в VM Atra.
repo=/mnt/win_share/OburecGH
project="$repo/Lazarus/RecorderLnx"
log=/tmp/recorderlnx_build.log
report="$project/linux_build_report.txt"
exe="$project/lib/x86_64-linux/RecorderLnx"

cd "$project" || exit 2
{
  lazbuild --pcp=/home/user/.lazarus_work -B RecorderLnx.lpi &&
  cd "$project/Plugins/SampleInfoPlugin" &&
  lazbuild --pcp=/home/user/.lazarus_work -B SampleInfoPlugin.lpi &&
  cd "$project/Tests/PluginInfo" &&
  lazbuild --pcp=/home/user/.lazarus_work -B PluginInfoProbe.lpi &&
  "$project/lib/x86_64-linux/PluginInfoProbe" \
    "$project/lib/x86_64-linux/plugins" &&
  cd "$repo/Lazarus/RecorderHostAgent" &&
  lazbuild --pcp=/home/user/.lazarus_work -B RecorderHostAgent.lpi &&
  cd "$project/Tools/LinuxSetupManager" &&
  lazbuild --pcp=/home/user/.lazarus_work -B LinuxSetupManager.lpi &&
  lazbuild --pcp=/home/user/.lazarus_work -B LinuxSetupManagerCli.lpi
} >"$log" 2>&1
rc=$?

{
  echo "BUILD_EXIT=$rc"
  tail -n 40 "$log"
  if [ -f "$exe" ]; then
    echo "ARTIFACT"
    stat -c '%y|%s|%n' "$exe"
    file "$exe"
    echo "MISSING_LIBS"
    ldd "$exe" | grep 'not found' || echo none
  else
    echo "ARTIFACT_MISSING=$exe"
  fi
} >"$report" 2>&1

exit "$rc"
