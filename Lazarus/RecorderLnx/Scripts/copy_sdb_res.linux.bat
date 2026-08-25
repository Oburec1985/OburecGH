#!/bin/sh
set -eu
OUT="${1:-}"
test -n "$OUT"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "${OUT}res/sdb" "${OUT}resources/devices/mc201"
cp "$SCRIPT_DIR/../SDB/res/"*.ico "${OUT}res/sdb/"
cp "$SCRIPT_DIR/../Device/MCbus/resources/devices/mc201/mc_201a.bio" \
  "${OUT}resources/devices/mc201/"
