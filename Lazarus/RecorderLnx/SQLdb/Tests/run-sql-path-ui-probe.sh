#!/bin/bash
set -u
cd /mnt/win_share/OburecGH/Lazarus/RecorderLnx/SQLdb/Tests || exit 2
lazbuild --pcp=/home/user/.lazarus_work -B SqlDbPathDialogProbe.lpi > /tmp/sql-path-ui-build.log 2>&1
result=$?
if [ "$result" = 0 ]; then
  export DISPLAY=:0 XAUTHORITY=/home/user/.Xauthority
  SQL_DIALOG_LOCAL_IP=$(hostname -I | cut -d' ' -f1)
  export SQL_DIALOG_LOCAL_IP
  timeout 30 ./lib/x86_64-linux/SqlDbPathDialogProbe /cfg:/tmp/recorder-sql-path-ui-fixture/app.ini > /tmp/sql-path-ui-run.log 2>&1
  result=$?
fi
cp /tmp/sql-path-ui-build.log sql-path-ui-build.log
if [ -f /tmp/sql-path-ui-run.log ]; then cp /tmp/sql-path-ui-run.log sql-path-ui-run.log; fi
printf '%s\n' "$result" > sql-path-ui-result.txt
exit "$result"
