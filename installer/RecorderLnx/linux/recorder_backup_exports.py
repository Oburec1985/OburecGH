#!/usr/bin/env python3
"""Refresh the authenticated, read-only RecorderLnx backup exports.

The root-only mode has no network listener and accepts no untrusted paths as
arguments.  The separate internal writer runs as the recorder account.
"""
import configparser
import fcntl
import io
import os
import pathlib
import pwd
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid

PATHS_INI = pathlib.Path('/opt/mera/RecorderLnx/RecorderLnx.paths.ini')
PROGRAM_DIR = PATHS_INI.parent
METADATA_NAME = 'backup-export-info.ini'
SMB = pathlib.Path('/etc/samba/smb.conf')
MARKER_PREFIX = '.recorder-backup-export-'
LOCK = '/run/lock/recorderlnx-backup-exports.lock'
INCLUDE_DIR = pathlib.Path('/etc/samba/recorder-backup')
SMB_BACKUP = pathlib.Path('/etc/samba/smb.conf.before-auto-backup-exports')
ACCOUNT = 'user'
SHARES = {'RecorderProjects': 'ProjectsRoot'}
GEN_FIELDS = {'RecorderProjects': 'ProjectsGeneration'}


def read_ini(path):
    p = configparser.ConfigParser(interpolation=None, strict=True)
    with open(path, 'r', encoding='utf-8-sig') as f:
        p.read_file(f)
    return p


def clean_path(path):
    text = str(path)
    if any(ord(c) < 32 or c in '%\n\r' for c in text):
        raise ValueError('invalid export path')
    return str(pathlib.Path(path).resolve(strict=True))


def user_access(path, flags):
    account = pwd.getpwnam(ACCOUNT)
    if os.geteuid() == account.pw_uid:
        return os.access(path, flags)
    tests = []
    if flags & os.R_OK: tests.append('-r')
    if flags & os.W_OK: tests.append('-w')
    if flags & os.X_OK: tests.append('-x')
    return all(subprocess.run(['runuser', '-u', ACCOUNT, '--', 'test', flag, str(path)],
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
               for flag in tests)


def active_app():
    """Resolve the same system root as RecorderLnx, without shell evaluation."""
    root = ''
    if PATHS_INI.exists() or PATHS_INI.is_symlink():
        # The privileged service may only trust an administrator-owned INI.
        check_root_file(PATHS_INI)
        root = read_ini(PATHS_INI).get('Paths', 'MeraFiles', fallback='').strip()
    if not root or '\\' in root or (len(root) > 1 and root[1] == ':'):
        root = str(pathlib.Path(pwd.getpwnam(ACCOUNT).pw_dir) / 'Mera Files')
    root_path = pathlib.Path(root)
    if not root_path.is_absolute():
        root_path = PROGRAM_DIR / root_path
    return root_path.resolve() / 'RecorderLnx' / 'app.ini'


def make_plan(app=None):
    if app is None:
        app = active_app()
    if not user_access(app, os.R_OK):
        raise PermissionError('recorder user cannot read app.ini')
    c = read_ini(app)
    raw = c.get('Application', 'DefaultProjectConfigDir', fallback='config/projects/default').strip()
    if not raw:
        raw = 'config/projects/default'
    project = pathlib.Path(raw) if os.path.isabs(raw) else app.parent / raw
    project = pathlib.Path(clean_path(project))
    if not project.is_dir():
        raise ValueError('active project is not a directory')
    config = next((project / n for n in ('config.json', 'default.config.json')
                   if (project / n).is_file()), None)
    if config is None:
        raise ValueError('active project configuration is not yet available')
    if not user_access(project, os.R_OK | os.X_OK) or not user_access(config, os.R_OK):
        raise PermissionError('recorder user cannot read active project')
    # A partial file during Save As is not a publishable project.
    import json
    with open(config, 'r', encoding='utf-8-sig') as f:
        if not isinstance(json.load(f), dict):
            raise ValueError('invalid active project configuration')
    parent = project.parent
    user = pwd.getpwnam(ACCOUNT)
    forbidden = {'/', '/home', user.pw_dir, '/srv', '/tmp', '/var', '/mnt', '/media'}
    if str(parent) in forbidden or parent == project:
        raise ValueError('project parent is too broad for backup export')
    storage = app.parent / 'storage.ini'
    run = next((project / n for n in ('default.run-control.ini', 'run-control.ini')
                if (project / n).is_file()), None)
    if storage.exists():
        if not user_access(storage, os.R_OK):
            raise PermissionError('recorder user cannot read storage.ini')
        d = read_ini(storage)
        raw_mera = d.get('Storage', 'MeraFilesPath').strip()
        if not raw_mera:
            raise ValueError('empty machine storage path')
        inputs = (app, storage, config)
    else:
        if run is None:
            raise ValueError('active run-control is not yet available')
        if not user_access(run, os.R_OK):
            raise PermissionError('recorder user cannot read run-control')
        d = read_ini(run)
        raw_mera = d.get('Mera', 'FilesPath', fallback='').strip()
        if not raw_mera or '\\' in raw_mera or (len(raw_mera) > 1 and raw_mera[1] == ':'):
            raise ValueError('cannot establish legacy Mera default safely')
        inputs = (app, run, config)
    if not os.path.isabs(raw_mera):
        raise ValueError('relative Mera path is unsupported')
    mera = pathlib.Path(clean_path(raw_mera))
    paths = {'RecorderProjects': clean_path(parent)}
    if any(not pathlib.Path(p).is_dir() for p in paths.values()):
        raise ValueError('backup export is not a directory')
    if any(not user_access(p, os.R_OK | os.W_OK | os.X_OK) for p in paths.values()):
        raise PermissionError('recorder user cannot read and mark backup export')
    return project, mera, paths, inputs


def include_file(name):
    return INCLUDE_DIR / (name + '.conf')


def render_smb(text, paths, install=False):
    for name in paths:
        pattern = re.compile(r'(?ms)^\[' + re.escape(name) + r'\][ \t]*\r?\n(.*?)(?=^\[|\Z)')
        matches = list(pattern.finditer(text))
        if len(matches) != 1:
            raise ValueError('missing or duplicate managed share: ' + name)
        m = matches[0]
        block = m.group(1)
        expected = {'valid users': 'user', 'read only': 'yes', 'guest ok': 'no',
                    'follow symlinks': 'no'}
        for key, value in expected.items():
            lines = re.findall(r'(?im)^\s*' + re.escape(key) + r'\s*=\s*([^\r\n]+)', block)
            if len(lines) != 1 or lines[0].strip().lower() != value:
                raise ValueError('unexpected security setting for ' + name + ': ' + key)
        path_re = re.compile(r'(?im)^([ \t]*path[ \t]*=[ \t]*)([^\r\n]*)')
        if len(list(path_re.finditer(block))) != 1:
            raise ValueError('missing or duplicate path for ' + name)
        includes = re.findall(r'(?im)^[ \t]*include[ \t]*=[ \t]*([^\r\n]+)', block)
        wanted = str(include_file(name))
        if includes.count(wanted) > 1:
            raise ValueError('duplicate managed include for ' + name)
        if wanted not in includes:
            if not install:
                raise ValueError('missing managed include for ' + name)
            new_block = path_re.sub(lambda match: match.group(0) + '\n   include = ' + wanted,
                                    block, count=1)
        else:
            new_block = block
        text = text[:m.start(1)] + new_block + text[m.end(1):]
    return text


def atomic_user_write(path, data):
    """Internal mode executed after dropping privileges to the recorder user."""
    path = pathlib.Path(path)
    if not path.parent.is_dir():
        raise ValueError('invalid user-write target')
    if re.fullmatch(re.escape(MARKER_PREFIX) + '[0-9a-f]{32}', path.name):
        generation = path.name[len(MARKER_PREFIX):]
        if data != (generation + '\n').encode('ascii'):
            raise ValueError('invalid export marker')
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
        try:
            with os.fdopen(fd, 'wb') as f:
                f.write(data)
                f.flush()
                os.fsync(f.fileno())
        except Exception:
            os.unlink(path)
            raise
        return
    if path.name != METADATA_NAME:
        raise ValueError('invalid user-write target')
    if path.exists() or path.is_symlink():
        st = os.lstat(path)
        if not stat.S_ISREG(st.st_mode) or st.st_uid != os.geteuid():
            raise PermissionError('existing backup metadata is not a user-owned regular file')
        old = read_ini(path)
        if not old.has_section('BackupExport') or not (
                old.get('BackupExport', 'State', fallback='') in ('updating', 'ready') or
                all(old.has_option('BackupExport', k) for k in
                    ('ProjectsRoot', 'CalibrRoot', 'SdbRoot', 'ProgramRoot'))):
            raise ValueError('refusing to replace unrecognised backup metadata')
    fd, tmp = tempfile.mkstemp(prefix='.recorder-backup-', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def user_write(path, data):
    subprocess.run(['runuser', '-u', ACCOUNT, '--', sys.executable,
                    os.path.realpath(__file__), '--user-write', str(path)],
                   input=data, check=True)


def check_root_file(path):
    st = os.lstat(path)
    if not stat.S_ISREG(st.st_mode) or st.st_uid != 0 or (st.st_mode & 0o022):
        raise PermissionError('untrusted managed Samba file: ' + str(path))
    return st


def atomic_root_file(path, data):
    fd, tmp = tempfile.mkstemp(prefix='.recorder-managed-', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
        os.chmod(tmp, 0o644)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp): os.unlink(tmp)


def include_bytes(path):
    return ('# RecorderLnx managed backup export\n   path = ' + path + '\n').encode('utf-8')


def verify_effective_config(config_path, paths):
    for name, path in paths.items():
        expected = {'path': path, 'read only': 'Yes', 'guest ok': 'No',
                    'follow symlinks': 'No', 'valid users': ACCOUNT, 'write list': ''}
        for parameter, value in expected.items():
            result = subprocess.run(['testparm', '-s', '--section-name', name,
                                     '--parameter-name', parameter, str(config_path)],
                                    capture_output=True, text=True, check=True).stdout.strip()
            if result.casefold() != value.casefold():
                raise ValueError('unexpected effective Samba setting: ' + name + ' / ' + parameter)


def install_includes_locked():
    """One-time migration of existing explicitly managed shares."""
    require_root()
    INCLUDE_DIR.mkdir(mode=0o755, parents=True, exist_ok=True)
    st = os.lstat(INCLUDE_DIR)
    if not stat.S_ISDIR(st.st_mode) or st.st_uid != 0 or (st.st_mode & 0o022):
        raise PermissionError('untrusted backup include directory')
    original_stat = check_root_file(SMB)
    before = SMB.read_text(encoding='utf-8')
    oldpaths = {}
    for name in SHARES:
        p = subprocess.run(['testparm', '-s', '--section-name', name,
                            '--parameter-name', 'path'], capture_output=True,
                           text=True, check=True).stdout.strip()
        oldpaths[name] = clean_path(p)
    after = render_smb(before, oldpaths, install=True)
    for name in SHARES:
        path = include_file(name)
        if path.exists() or path.is_symlink():
            check_root_file(path)
            if path.read_bytes() != include_bytes(oldpaths[name]):
                raise ValueError('existing managed include differs: ' + name)
        else:
            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o644)
            with os.fdopen(fd, 'wb') as f:
                f.write(include_bytes(oldpaths[name])); f.flush(); os.fsync(f.fileno())
    if after == before:
        return
    fd, tmp = tempfile.mkstemp(prefix='.recorder-smb-migration-', dir=SMB.parent)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='') as f:
            f.write(after); f.flush(); os.fsync(f.fileno())
        os.chmod(tmp, stat.S_IMODE(original_stat.st_mode))
        os.chown(tmp, original_stat.st_uid, original_stat.st_gid)
        subprocess.run(['testparm', '-s', tmp], check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        verify_effective_config(tmp, oldpaths)
        current = check_root_file(SMB)
        if (current.st_dev, current.st_ino) != (original_stat.st_dev, original_stat.st_ino) or SMB.read_text(encoding='utf-8') != before:
            raise RuntimeError('Samba configuration changed during include migration')
        if not SMB_BACKUP.exists():
            fdbackup = os.open(SMB_BACKUP, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
            with os.fdopen(fdbackup, 'w', encoding='utf-8', newline='') as f:
                f.write(before); f.flush(); os.fsync(f.fileno())
        current = check_root_file(SMB)
        if (current.st_dev, current.st_ino) != (original_stat.st_dev, original_stat.st_ino) or SMB.read_text(encoding='utf-8') != before:
            raise RuntimeError('Samba configuration changed before include migration commit')
        os.replace(tmp, SMB)
        subprocess.run(['smbcontrol', 'all', 'reload-config'], check=True)
    finally:
        if os.path.exists(tmp): os.unlink(tmp)


def install_includes():
    require_root()
    fd = os.open(LOCK, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    if not trusted_lock(os.fstat(fd)):
        os.close(fd)
        raise PermissionError('invalid backup export lock')
    with os.fdopen(fd, 'r+') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        install_includes_locked()


def ini_bytes(values):
    c = configparser.ConfigParser(interpolation=None)
    c.optionxform = str
    c['BackupExport'] = values
    out = io.StringIO()
    c.write(out)
    return out.getvalue().encode('utf-8')


def trusted_lock(st):
    return stat.S_ISREG(st.st_mode) and st.st_uid == 0 and (st.st_mode & 0o077) == 0


def trusted_include_dir(st):
    return stat.S_ISDIR(st.st_mode) and st.st_uid == 0 and not (st.st_mode & 0o022)


def invalidate_metadata(metadata):
    if metadata.exists() or metadata.is_symlink():
        st = os.lstat(metadata)
        if not stat.S_ISREG(st.st_mode) or st.st_uid != pwd.getpwnam(ACCOUNT).pw_uid:
            raise PermissionError('invalid existing backup metadata')
        try:
            if read_ini(metadata).get('BackupExport', 'State', fallback='') == 'updating':
                return
        except (OSError, configparser.Error):
            pass
    user_write(metadata, ini_bytes({'State': 'updating'}))


def require_root():
    if os.geteuid() != 0:
        raise PermissionError('refresh requires root')


def refresh():
    require_root()
    lock_fd = os.open(LOCK, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    if not trusted_lock(os.fstat(lock_fd)):
        os.close(lock_fd)
        raise PermissionError('invalid backup export lock')
    with os.fdopen(lock_fd, 'r+') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        app = active_app()
        metadata = app.parent / METADATA_NAME
        try:
            project, mera, paths, inputs = make_plan(app)
            snapshots = {str(p): p.read_bytes() for p in inputs}
            if PATHS_INI.exists():
                check_root_file(PATHS_INI)
                snapshots[str(PATHS_INI)] = PATHS_INI.read_bytes()
            # Save As can replace app.ini between the plan and the snapshot.
            if active_app() != app or make_plan(app) != (project, mera, paths, inputs) or any(
                    pathlib.Path(p).read_bytes() != b for p, b in snapshots.items()):
                raise RuntimeError('project changed while reading backup settings')
        except Exception:
            invalidate_metadata(metadata)
            raise
        try:
            original_stat = check_root_file(SMB)
            before = SMB.read_text(encoding='utf-8')
            render_smb(before, paths)
            inc_stat = os.lstat(INCLUDE_DIR)
            if not trusted_include_dir(inc_stat):
                raise PermissionError('untrusted backup include directory')
            includes = {}
            for n in SHARES:
                p = include_file(n)
                st = check_root_file(p)
                includes[n] = (st.st_dev, st.st_ino, p.read_bytes())
                if before.count(str(p)) != 1:
                    raise ValueError('ambiguous Samba include: ' + n)
        except Exception:
            invalidate_metadata(metadata)
            raise
        if metadata.exists():
            try:
                m = read_ini(metadata)
                old = m['BackupExport']
                unchanged = all(includes[n][2] == include_bytes(paths[n]) and
                    old.get(SHARES[n], '') == paths[n]
                    and re.fullmatch('[0-9a-f]{32}', old.get(GEN_FIELDS[n], ''))
                    and (pathlib.Path(paths[n]) / (MARKER_PREFIX + old[GEN_FIELDS[n]])).read_text(encoding='utf-8').strip() == old[GEN_FIELDS[n]]
                    for n in SHARES)
                if unchanged and old.get('State', '') == 'ready' and old.get('RuntimeMeraRoot', '') == str(mera):
                    return
            except (OSError, ValueError, KeyError, configparser.Error):
                pass
        # Invalidate before changing shares or markers. A concurrent backup must
        # not validate stale metadata while the exports are being replaced.
        invalidate_metadata(metadata)
        staged = {}
        temp_name = None
        try:
            for n in SHARES:
                fd, staged[n] = tempfile.mkstemp(prefix='.recorder-include-', dir=INCLUDE_DIR)
                with os.fdopen(fd, 'wb') as f:
                    f.write(include_bytes(paths[n])); f.flush(); os.fsync(f.fileno())
                os.chmod(staged[n], 0o644)
            candidate = before
            for n in SHARES:
                candidate = candidate.replace(str(include_file(n)), staged[n])
            fd, temp_name = tempfile.mkstemp(prefix='.recorder-smb-', dir=SMB.parent)
            with os.fdopen(fd, 'w', encoding='utf-8', newline='') as f:
                f.write(candidate)
                f.flush()
                os.fsync(f.fileno())
            st = SMB.stat()
            os.chmod(temp_name, stat.S_IMODE(st.st_mode))
            os.chown(temp_name, st.st_uid, st.st_gid)
            subprocess.run(['testparm', '-s', temp_name], check=True,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            verify_effective_config(temp_name, paths)
            if active_app() != app or any(pathlib.Path(p).read_bytes() != b for p, b in snapshots.items()):
                raise RuntimeError('project changed during backup export preparation')
            if ((os.lstat(SMB).st_dev, os.lstat(SMB).st_ino) !=
                    (original_stat.st_dev, original_stat.st_ino) or
                    SMB.read_text(encoding='utf-8') != before):
                raise RuntimeError('Samba configuration changed during backup export preparation')
            for n in SHARES:
                # Terminate established tree connections, so active backups
                # fail rather than reading across different generations.
                subprocess.run(['smbcontrol', 'smbd', 'close-share', n], check=True)
            if ((os.lstat(SMB).st_dev, os.lstat(SMB).st_ino) !=
                    (original_stat.st_dev, original_stat.st_ino) or
                    SMB.read_text(encoding='utf-8') != before):
                raise RuntimeError('Samba configuration changed before backup export commit')
            for n in SHARES:
                p = include_file(n)
                st = check_root_file(p)
                if (st.st_dev, st.st_ino, p.read_bytes()) != includes[n]:
                    raise RuntimeError('managed backup export changed during update: ' + n)
                os.replace(staged[n], p)
                staged[n] = None
            dir_fd = os.open(INCLUDE_DIR, os.O_RDONLY | os.O_DIRECTORY)
            try: os.fsync(dir_fd)
            finally: os.close(dir_fd)
            subprocess.run(['smbcontrol', 'all', 'reload-config'], check=True)
            for n in SHARES:
                subprocess.run(['smbcontrol', 'smbd', 'close-share', n], check=True)
            verify_effective_config(SMB, paths)
            generation = uuid.uuid4().hex
            for n in SHARES:
                user_write(pathlib.Path(paths[n]) / (MARKER_PREFIX + generation),
                           (generation + '\n').encode())
            if active_app() != app or any(pathlib.Path(p).read_bytes() != b for p, b in snapshots.items()):
                raise RuntimeError('project changed while publishing backup exports')
            values = {SHARES[n]: paths[n] for n in SHARES}
            values.update({GEN_FIELDS[n]: generation for n in SHARES})
            values.update({'ProgramRoot': '/opt/mera/RecorderLnx',
                           'RuntimeMeraRoot': str(mera),
                           'DefaultMeraRoot': str(pathlib.Path(pwd.getpwnam(ACCOUNT).pw_dir) / 'Mera Files'),
                           'State': 'ready'})
            user_write(metadata, ini_bytes(values))
        finally:
            if temp_name and os.path.exists(temp_name):
                os.unlink(temp_name)
            for name in staged.values():
                if name and os.path.exists(name): os.unlink(name)


if __name__ == '__main__':
    try:
        if len(sys.argv) == 3 and sys.argv[1] == '--user-write':
            if os.geteuid() != pwd.getpwnam(ACCOUNT).pw_uid:
                raise PermissionError('internal writer requires recorder user')
            atomic_user_write(sys.argv[2], sys.stdin.buffer.read(1024 * 1024))
        elif len(sys.argv) == 2 and sys.argv[1] == '--install-includes':
            install_includes()
        elif len(sys.argv) == 1:
            refresh()
        else:
            raise ValueError('unexpected arguments')
    except Exception as exc:
        print('recorder backup export refresh failed:', exc, file=sys.stderr)
        sys.exit(1)
