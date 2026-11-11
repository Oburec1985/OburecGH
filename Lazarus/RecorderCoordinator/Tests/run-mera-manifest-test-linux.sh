#!/bin/bash
set -eu
cd /mnt/win_share/OburecGH/Lazarus/RecorderCoordinator/Tests
mkdir -p lib/manifest208-linux/units
python3 - <<'PY'
import xml.etree.ElementTree as ET
tree=ET.parse('MeraPackageManifestTest.lpi')
tree.find('./CompilerOptions/Target/Filename').set('Value','lib/manifest208-linux/MeraPackageManifestTest')
tree.find('./CompilerOptions/SearchPaths/UnitOutputDirectory').set('Value','lib/manifest208-linux/units')
tree.write('MeraPackageManifestTestLinux.lpi', encoding='UTF-8', xml_declaration=True)
PY
lazbuild --pcp=/home/user/.lazarus_work -B MeraPackageManifestTestLinux.lpi >manifest-build-linux.log 2>&1
test -x lib/manifest208-linux/MeraPackageManifestTest
fixture=$(mktemp -d /tmp/MeraManifestApp-XXXXXX)
python3 - <<'PY'
import hashlib, json, pathlib
paths = ['/srv/recorderlnx/MeraFiles/RecorderLnx/app.ini', '/home/user/Mera Files/RecorderLnx/app.ini']
def fingerprint(p):
    q=pathlib.Path(p)
    return hashlib.sha256(q.read_bytes()).hexdigest() if q.is_file() else 'absent'
pathlib.Path('manifest-fingerprints-linux-before.json').write_text(json.dumps({p:fingerprint(p) for p in paths}))
PY
set +e
timeout 30s ./lib/manifest208-linux/MeraPackageManifestTest "/cfg:$fixture/app.ini" >manifest-run-linux.log 2>&1
result=$?
set -e
python3 - <<'PY'
import hashlib, json, pathlib
before=json.loads(pathlib.Path('manifest-fingerprints-linux-before.json').read_text())
after={p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest() if pathlib.Path(p).is_file() else 'absent' for p in before}
pathlib.Path('manifest-fingerprints-linux.json').write_text(json.dumps({'before':before,'after':after,'unchanged':before==after}))
assert before==after, 'Working app.ini changed during isolated fixture'
PY
cat manifest-run-linux.log
echo "fixture=$fixture"
exit "$result"
