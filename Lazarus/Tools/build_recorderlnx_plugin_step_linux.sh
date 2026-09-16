#!/bin/bash
set -o pipefail

project=/mnt/win_share/OburecGH/Lazarus/RecorderLnx
log=/tmp/recorderlnx_plugin_step_build.log
report="$project/plugin_step_linux_build_report.txt"

{
  cd "$project" &&
  lazbuild --pcp=/home/user/.lazarus_work -B RecorderLnx.lpi &&
  cd "$project/Plugins/SampleInfoPlugin" &&
  lazbuild --pcp=/home/user/.lazarus_work -B SampleInfoPlugin.lpi &&
  cd "$project/Plugins/SampleInfoPlugin/Tests" &&
  lazbuild --pcp=/home/user/.lazarus_work -B SamplePluginProbe.lpi &&
  "$project/Plugins/SampleInfoPlugin/Tests/lib/x86_64-linux/SamplePluginProbe" \
    "$project/lib/x86_64-linux/plugins/libsampleinfoplugin.so" &&
  cd "$project/Tests/PluginInfo" &&
  lazbuild --pcp=/home/user/.lazarus_work -B PluginInfoProbe.lpi &&
  "$project/lib/x86_64-linux/PluginInfoProbe" \
    "$project/lib/x86_64-linux/plugins"
} >"$log" 2>&1
rc=$?
{
  echo "BUILD_EXIT=$rc"
  tail -n 50 "$log"
} >"$report"
exit "$rc"
