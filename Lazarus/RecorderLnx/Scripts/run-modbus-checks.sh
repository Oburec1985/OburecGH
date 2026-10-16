#!/usr/bin/env sh
set -eu

# Linux/Unix counterpart of run-modbus-checks.ps1.  Tool locations may be
# overridden without editing the project, e.g. LAZBUILD=/opt/lazarus/lazbuild.
LAZBUILD="${LAZBUILD:-lazbuild}"
FPC="${FPC:-fpc}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
LOG="${MODBUS_CHECK_LOG:-$PROJECT_ROOT/modbus-checks-linux.log}"
CORE_DIR="$PROJECT_ROOT/../Tests/RecorderTests/Modbus"
RUNTIME_DIR="$PROJECT_ROOT/Device/Modbus/Runtime/Tests"
UI_DIR="$PROJECT_ROOT/Device/Modbus/UI/Tests"

: > "$LOG"
run() {
  label=$1
  shift
  printf '=== %s ===\n' "$label" | tee -a "$LOG"
  stage_log="${TMPDIR:-/tmp}/recorder-modbus-check.$$.log"
  if "$@" >"$stage_log" 2>&1; then
    stage_status=0
  else
    stage_status=$?
  fi
  tee -a "$LOG" <"$stage_log"
  rm -f "$stage_log"
  return "$stage_status"
}
find_exe() {
  find "$1/lib" -type f -name "$2" -perm -u+x -print | head -n 1
}

run 'Core forced build' "$LAZBUILD" -B "$CORE_DIR/ModbusCoreTest.lpi"
CORE_EXE=$(find_exe "$CORE_DIR" ModbusCoreTest)
[ -n "$CORE_EXE" ] || { echo 'Core executable not found' | tee -a "$LOG"; exit 1; }
run 'Core tests' "$CORE_EXE"

run 'Runtime forced build' "$FPC" -B \
  "-Fu$PROJECT_ROOT/Device/Modbus/Core" \
  "-Fu$PROJECT_ROOT/Device/Modbus/Runtime" \
  "-FE$RUNTIME_DIR" "$RUNTIME_DIR/ModbusRuntimeTests.lpr"
run 'Runtime fake TCP/RTU tests' "$RUNTIME_DIR/ModbusRuntimeTests"

run 'UI smoke forced build' "$LAZBUILD" -B "$UI_DIR/ModbusEditorSmoke.lpi"
UI_EXE=$(find_exe "$UI_DIR" ModbusEditorSmoke)
[ -n "$UI_EXE" ] || { echo 'UI executable not found' | tee -a "$LOG"; exit 1; }
run 'UI smoke' "$UI_EXE"

cd "$PROJECT_ROOT"
run 'RecorderLnx forced Linux build' "$LAZBUILD" -B \
  '--opt=-omodbus-recorderlnx-verify' RecorderLnx.lpi
printf '%s\n' 'RESULT all Modbus Linux checks passed' | tee -a "$LOG"
