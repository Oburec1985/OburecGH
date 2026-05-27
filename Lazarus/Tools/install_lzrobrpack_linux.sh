#!/usr/bin/env bash
set -euo pipefail

WORKS_ROOT=""
for CANDIDATE in /mnt/win_share /mnt/hgfs/works /home/user/win_share; do
  if [ -d "$CANDIDATE/OburecGH/Lazarus" ]; then
    WORKS_ROOT="$CANDIDATE"
    break
  fi
done

if [ -z "$WORKS_ROOT" ]; then
  echo "Cannot find shared D:\\works mount." >&2
  exit 1
fi

LOG="$WORKS_ROOT/OburecGH/Lazarus/Tools/install_lzrobrpack_linux.log"
exec >"$LOG" 2>&1

echo "Started at $(date -Is)"
echo "WORKS_ROOT=$WORKS_ROOT"

PKG="$WORKS_ROOT/OburecGH/Lazarus/SharedUtils/components/chart_lzr/lzrObrPack.lpk"
PROJECT="$WORKS_ROOT/OburecGH/Lazarus/RecorderLnx/RecorderLnx.lpi"
DEMO="$WORKS_ROOT/OburecGH/Lazarus/OGlChartLaz/Test_component/project1.lpi"

if ! command -v lazbuild >/dev/null 2>&1; then
  echo "lazbuild not found in PATH" >&2
  exit 1
fi

if [ ! -f "$PKG" ]; then
  echo "Package not found: $PKG" >&2
  echo "Check VMware shared folder mount, expected host D:\\works under /mnt/win_share or /mnt/hgfs/works." >&2
  exit 1
fi

lazbuild -B "$PKG"
lazbuild --add-package-link "$PKG"
lazbuild --add-package "$PKG" --build-ide=
lazbuild -B "$DEMO"
lazbuild -B "$PROJECT"

echo "LzrObrPack installed and RecorderLnx build checked."
