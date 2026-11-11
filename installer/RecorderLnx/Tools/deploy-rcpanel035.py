#!/usr/bin/env python3
"""Replace only the installed panel ELF; retain configuration and run state."""
import hashlib
import json
import os
import pwd
import shutil
import signal
import subprocess
import sys
import time
from pathlib import Path

TARGET = Path('/opt/mera/RecorderCoordinator/RecorderCoordinator')


def digest(path):
    h = hashlib.sha256()
    with open(path, 'rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(data)
    return h.hexdigest()


def processes():
    result = []
    for name in os.listdir('/proc'):
        if not name.isdigit():
            continue
        base = Path('/proc') / name
        try:
            exe = os.readlink(base / 'exe')
            if exe.removesuffix(' (deleted)') != str(TARGET):
                continue
            status = (base / 'status').read_text()
            if '\nState:\tZ' in status:
                continue
            env = dict(item.split('=', 1) for item in
                       (base / 'environ').read_bytes().decode().split('\0') if '=' in item)
            result.append(dict(pid=int(name), exe=exe,
                               args=(base / 'cmdline').read_bytes().decode().split('\0')[:-1],
                               cwd=os.readlink(base / 'cwd'), uid=base.stat().st_uid,
                               gid=base.stat().st_gid, env=env))
        except (OSError, UnicodeError):
            continue
    return result


def public_process(item):
    return {key: item[key] for key in ('pid', 'exe', 'args', 'cwd', 'uid', 'gid')} | {
        'display': item['env'].get('DISPLAY'),
        'xauthority': item['env'].get('XAUTHORITY')}


def fingerprints():
    paths = list(TARGET.parent.glob('*.ini')) + list(TARGET.parent.glob('*.json'))
    paths += list(Path('/var/opt/mera/RecorderCoordinator').glob('*.ini'))
    paths += list(Path('/var/opt/mera/RecorderCoordinator').glob('*.json'))
    return {str(path): digest(path) for path in paths if path.is_file()}


def main():
    source, expected, stamp = Path(sys.argv[1]), sys.argv[2].lower(), sys.argv[3]
    if os.geteuid() != 0 or not TARGET.is_file():
        raise RuntimeError('Root and an existing installed panel are required')
    if source.read_bytes()[:4] != b'\x7fELF' or digest(source) != expected:
        raise RuntimeError('Staged binary is not the expected ELF')
    old_stat = TARGET.stat()
    prior = processes()
    if len(prior) > 1:
        raise RuntimeError('Multiple panel instances require separate review')
    backup = Path('/var/opt/mera/RecorderCoordinator/deploy-backups') / stamp
    backup.mkdir(parents=True, exist_ok=False, mode=0o700)
    shutil.copy2(TARGET, backup / 'RecorderCoordinator.before')
    config_before = fingerprints()
    for path in config_before:
        copied = backup / 'configuration' / path.lstrip('/')
        copied.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, copied)
    report = dict(old_sha256=digest(TARGET), expected_sha256=expected,
                  previous=[public_process(item) for item in prior],
                  config_before=config_before, backup=str(backup))
    for item in prior:
        shutil.copy2('/proc/%d/exe' % item['pid'],
                     backup / ('running-%d.before' % item['pid']))
        os.kill(item['pid'], signal.SIGTERM)
    deadline = time.monotonic() + 8
    while processes() and time.monotonic() < deadline:
        time.sleep(0.2)
    for item in processes():
        os.kill(item['pid'], signal.SIGKILL)
    deadline = time.monotonic() + 3
    while processes() and time.monotonic() < deadline:
        time.sleep(0.2)
    if processes():
        raise RuntimeError('Old panel has not exited; replacement aborted')
    temp = TARGET.with_name(TARGET.name + '.deploy-035-%d' % os.getpid())
    shutil.copyfile(source, temp)
    os.chmod(temp, old_stat.st_mode & 0o777)
    os.chown(temp, old_stat.st_uid, old_stat.st_gid)
    with open(temp, 'rb') as stream:
        os.fsync(stream.fileno())
    os.replace(temp, TARGET)
    for item in prior:
        def restore_identity():
            os.initgroups(pwd.getpwuid(item['uid']).pw_name, item['gid'])
            os.setgid(item['gid'])
            os.setuid(item['uid'])
        log = open(backup / 'restart.log', 'ab', buffering=0)
        try:
            subprocess.Popen(item['args'], cwd=item['cwd'], env=item['env'],
                             stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                             start_new_session=True, preexec_fn=restore_identity)
        finally:
            log.close()
    time.sleep(4)
    after = processes()
    report.update(installed_sha256=digest(TARGET),
                  current=[public_process(item) for item in after],
                  config_after=fingerprints())
    (backup / 'deployment.json').write_text(json.dumps(report, ensure_ascii=False, indent=2))
    print(json.dumps(report, ensure_ascii=False))
    if report['installed_sha256'] != expected or len(after) != len(prior):
        raise RuntimeError('Installed hash or process count differs from expected')


if __name__ == '__main__':
    main()
