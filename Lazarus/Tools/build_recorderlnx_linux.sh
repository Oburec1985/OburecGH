#!/bin/bash
set -o pipefail

# Единая команда контрольной Linux-сборки RecorderLnx в VM Atra.
project=/mnt/win_share/OburecGH/Lazarus/RecorderLnx
log=/tmp/recorderlnx_build.log
report="$project/linux_build_report.txt"
exe="$project/lib/x86_64-linux/RecorderLnx"

cd "$project" || exit 2
lazbuild --pcp=/home/user/.lazarus_work -B RecorderLnx.lpi >"$log" 2>&1
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
