#!/usr/bin/env python3
"""Check or explicitly grant Firebird access to one local directory.

This helper does not mount disks, create databases, change credentials or
configure privilege escalation. Mutation modes are experimental and explicitly
disabled in the CLI pending independent security review. Run as root only
through an explicitly configured privileged launcher. Success requires a real
create/chmod/delete probe as the Firebird service user.
"""

import argparse
import json
import os
import posixpath
import pwd
import stat
import subprocess
import sys


class PrepareError(Exception):
    def __init__(self, code, message):
        super().__init__(message)
        self.code = code


def run(args, *, input_text=None, pass_fds=()):
    try:
        return subprocess.run(args, input=input_text, text=True, cwd='/',
                              env={'PATH': '/usr/sbin:/usr/bin:/sbin:/bin',
                                   'LANG': 'C', 'LC_ALL': 'C'},
                              capture_output=True, timeout=20,
                              pass_fds=pass_fds, check=False)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise PrepareError('tool_failure', str(exc)) from exc


def open_directory(path):
    """Keep an fd to the chosen directory and reject every symbolic link."""
    if not os.path.isabs(path) or path == '/':
        raise PrepareError('invalid_path', 'Choose an absolute directory, not the filesystem root.')
    parts = path.split('/')[1:]
    if any(part in ('.', '..') for part in parts):
        raise PrepareError('invalid_path', 'Dot path components are not allowed.')
    flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW
    fd = os.open('/', flags)
    try:
        for part in filter(None, parts):
            next_fd = os.open(part, flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        return fd
    except OSError as exc:
        os.close(fd)
        raise PrepareError('invalid_path', 'Directory is missing, inaccessible, or contains a symlink.') from exc


def filesystem_type(fd):
    result = run(['/usr/bin/findmnt', '-n', '-o', 'FSTYPE', '--target',
                  '/proc/self/fd/' + str(fd)], pass_fds=(fd,))
    if result.returncode or not result.stdout.strip():
        raise PrepareError('filesystem_unknown', 'Could not identify the filesystem.')
    return result.stdout.strip().splitlines()[-1].lower()


def probe_as_firebird(path, account, identity):
    # Reopen every component as the service user. Refuse a changed directory,
    # and create/delete only our unpredictable file relative to the held fd.
    script = '''import os, sys, secrets
p=sys.argv[1]; want=(int(sys.argv[2]),int(sys.argv[3]))
flags=os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW
d=os.open('/',flags)
try:
 for part in filter(None,p.split('/')):
  n=os.open(part,flags,dir_fd=d); os.close(d); d=n
 st=os.fstat(d)
 if (st.st_dev,st.st_ino)!=want: raise RuntimeError('directory changed')
 name='.recorder-fb-probe-'+secrets.token_hex(16)
 f=os.open(name,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o600,dir_fd=d)
 try: os.fchmod(f,0o600)
 finally:
  os.close(f); os.unlink(name,dir_fd=d)
finally: os.close(d)
'''
    result = run(['/usr/sbin/runuser', '-u', account, '--', '/usr/bin/python3',
                  '-I', '-c', script, path, str(identity.st_dev), str(identity.st_ino)])
    return result.returncode == 0


def caller_can_open(path, caller, identity):
    """Require the invoking user to traverse and inspect a service-owned directory."""
    try:
        caller_name = pwd.getpwuid(caller).pw_name
    except KeyError as exc:
        raise PrepareError('invalid_caller', 'The invoking UID has no local account.') from exc
    script = '''import os, sys
p=sys.argv[1]; want=(int(sys.argv[2]),int(sys.argv[3]))
flags=os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW
d=os.open('/',flags)
try:
 for part in filter(None,p.split('/')):
  n=os.open(part,flags,dir_fd=d); os.close(d); d=n
 st=os.fstat(d)
 if (st.st_dev,st.st_ino)!=want: raise RuntimeError('directory changed')
finally: os.close(d)
'''
    result = run(['/usr/sbin/runuser', '-u', caller_name, '--', '/usr/bin/python3',
                  '-I', '-c', script, path, str(identity.st_dev), str(identity.st_ino)])
    return result.returncode == 0


def check_identity(path, identity):
    """Check that the path still identifies the held no-follow directory."""
    check_fd = open_directory(path)
    try:
        current = os.fstat(check_fd)
        if (current.st_dev, current.st_ino) != (identity.st_dev, identity.st_ino):
            raise PrepareError('directory_changed', 'Directory changed during the access check.')
    finally:
        os.close(check_fd)


def lock_directory(fd):
    """Serialize cooperating helpers; external ACL editors need not honor flock."""
    try:
        import fcntl
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except (ImportError, OSError) as exc:
        raise PrepareError('directory_busy', 'Cannot obtain the directory preparation lock.') from exc


def read_acl(fd):
    result = run(['/usr/bin/getfacl', '-cpn', '--', '/proc/self/fd/' + str(fd)],
                 pass_fds=(fd,))
    if result.returncode:
        raise PrepareError('acl_unavailable', 'Cannot read the directory ACL.')
    entries = {}
    for line in result.stdout.splitlines():
        line = line.split('#', 1)[0].strip()
        if not line:
            continue
        if ':' not in line:
            raise PrepareError('invalid_acl', 'Unexpected directory ACL format.')
        key, value = line.rsplit(':', 1)
        value = value.strip()
        if (key in entries or len(value) != 3 or value[0] not in 'r-' or
                value[1] not in 'w-' or value[2] not in 'x-'):
            raise PrepareError('invalid_acl', 'Unexpected or duplicate ACL entry.')
        entries[key] = value
    if not {'user:', 'group:', 'other:'}.issubset(entries):
        raise PrepareError('invalid_acl', 'The directory ACL lacks required entries.')
    return entries


def planned_acl(entries, service_uid):
    """Never widen an existing mask, which controls other users/groups."""
    mask = entries.get('mask:')
    if mask is None:
        # Adding a mask with setfacl would race an unrelated ACL editor which
        # could create named entries after our read; widening their mask would
        # silently broaden access. There is no ACL compare-and-swap here.
        raise PrepareError('acl_mask_missing', 'Automatic access requires an existing unrestricted ACL mask.')
    if mask is not None and mask != 'rwx':
        raise PrepareError('acl_mask_conflict',
                           'The existing ACL mask restricts rights; it will not be widened automatically.')
    desired = dict(entries)
    desired['user:' + str(service_uid)] = 'rwx'
    desired['mask:'] = 'rwx'
    return desired


def edit_acl(fd, mode, specification):
    result = run(['/usr/bin/setfacl', '-n', mode, specification, '--',
                  '/proc/self/fd/' + str(fd)], pass_fds=(fd,))
    if result.returncode:
        raise PrepareError('acl_write_failed', 'Could not update the selected directory ACL.')


def rollback_grant(fd, original, expected, service_uid):
    """Undo only our service entry; never replace unrelated ACL entries."""
    current = read_acl(fd)
    key = 'user:' + str(service_uid)
    if current.get(key) == original.get(key) and current.get('mask:') == original.get('mask:'):
        return
    if current.get(key) != expected[key] or current.get('mask:') != expected['mask:']:
        raise PrepareError('acl_state_unknown',
                           'The service entry or mask changed concurrently; the service entry may remain. Inspect ACL before retrying.')
    if key in original:
        edit_acl(fd, '-m', 'u:' + str(service_uid) + ':' + original[key])
    else:
        edit_acl(fd, '-x', 'u:' + str(service_uid))
    restored = read_acl(fd)
    if restored.get(key) != original.get(key) or restored.get('mask:') != original.get('mask:'):
        raise PrepareError('rollback_incomplete', 'The service ACL could not be restored exactly.')


def grant_access(fd, path, identity, account):
    if identity.st_uid == account.pw_uid:
        raise PrepareError('owner_access_denied',
                           'The service owns this directory; a named ACL cannot override owner permissions.')
    lock_directory(fd)
    check_identity(path, identity)
    original = read_acl(fd)
    expected = planned_acl(original, account.pw_uid)
    if original == expected:
        raise PrepareError('access_denied', 'The service ACL is already present; check access to ancestor directories.')
    if read_acl(fd) != original:
        raise PrepareError('acl_conflict', 'Directory ACL changed during preparation.')
    specification = 'u:' + str(account.pw_uid) + ':rwx'
    try:
        edit_acl(fd, '-m', specification)
    except Exception as exc:
        # The tool may have changed the ACL before reporting a timeout/error.
        # Inspect and undo only our entry; never replace the whole ACL.
        try:
            rollback_grant(fd, original, expected, account.pw_uid)
        except Exception as rollback_exc:
            raise PrepareError('acl_state_unknown',
                               'ACL write failed and safe rollback was not verified; the service entry may remain. Inspect ACL before retrying.') from rollback_exc
        raise PrepareError('acl_write_rolled_back',
                           'ACL write reported an error; the original service entry was restored.') from exc
    try:
        after = read_acl(fd)
    except Exception as exc:
        raise PrepareError('acl_state_unknown',
                           'ACL was written but could not be read back; the service entry may remain. Inspect ACL before retrying.') from exc
    if after != expected:
        # Preserve unrelated entries even if they changed after our write.
        rollback_grant(fd, original, expected, account.pw_uid)
        raise PrepareError('acl_conflict',
                           'Directory ACL changed concurrently; the original service entry was restored.')
    try:
        check_identity(path, identity)
        if not probe_as_firebird(path, account.pw_name, identity):
            raise PrepareError('access_denied',
                               'Firebird cannot create and chmod a file; check access to ancestor directories.')
        check_identity(path, identity)
    except Exception:
        rollback_grant(fd, original, expected, account.pw_uid)
        raise
    return 'prepared'


def invoking_uid():
    # sudo supplies SUDO_UID; never allow an inherited PKEXEC_UID to override it.
    if 'SUDO_UID' in os.environ:
        raw = os.environ['SUDO_UID']
    elif 'SUDO_USER' in os.environ:
        raise PrepareError('invalid_caller', 'sudo caller UID is missing.')
    else:
        raw = os.environ.get('PKEXEC_UID', '0')
    try:
        uid = int(raw)
    except ValueError as exc:
        raise PrepareError('invalid_caller', 'Invalid caller identity.') from exc
    if uid < 0 or uid >= 2**32 - 1:
        raise PrepareError('invalid_caller', 'Invalid caller identity.')
    return uid


def firebird_account():
    try:
        return pwd.getpwnam('firebird')
    except KeyError:
        try:
            return pwd.getpwnam('firebirdsql')
        except KeyError as exc:
            raise PrepareError('firebird_missing', 'Firebird service account was not found.') from exc


def write_marker(fd, identity, caller, account):
    marker = {'version': 1, 'device': identity.st_dev, 'inode': identity.st_ino,
              'caller': caller, 'firebird': account.pw_uid}
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW
    marker_fd = os.open('.recorder-firebird-managed.json', flags, 0o400, dir_fd=fd)
    try:
        os.fchmod(marker_fd, 0o400)
        data = (json.dumps(marker, sort_keys=True) + '\n').encode('utf-8')
        if os.write(marker_fd, data) != len(data):
            raise PrepareError('created_incomplete', 'Could not write the complete directory marker.')
        os.fsync(marker_fd)
    finally:
        os.close(marker_fd)


def validate_marker(fd, identity, caller, account):
    try:
        marker_fd = os.open('.recorder-firebird-managed.json', os.O_RDONLY | os.O_NOFOLLOW, dir_fd=fd)
    except OSError as exc:
        raise PrepareError('destination_unmanaged', 'Existing child has no trusted marker; it was not changed.') from exc
    try:
        metadata = os.fstat(marker_fd)
        if (not stat.S_ISREG(metadata.st_mode) or metadata.st_uid != 0 or
                stat.S_IMODE(metadata.st_mode) != 0o400 or metadata.st_nlink != 1):
            raise PrepareError('destination_unmanaged', 'Existing child marker is not trusted.')
        data = os.read(marker_fd, 4097)
        if len(data) > 4096:
            raise PrepareError('destination_unmanaged', 'Existing child marker is too large.')
        try:
            marker = json.loads(data.decode('utf-8'))
        except (ValueError, UnicodeError) as exc:
            raise PrepareError('destination_unmanaged', 'Existing child marker is invalid.') from exc
        expected = {'version': 1, 'device': identity.st_dev, 'inode': identity.st_ino,
                    'caller': caller, 'firebird': account.pw_uid}
        if marker != expected or identity.st_uid != account.pw_uid:
            raise PrepareError('destination_unmanaged', 'Existing child does not match its trusted marker.')
    finally:
        os.close(marker_fd)


def create_managed_child(parent_fd, parent_path, parent_identity, caller, account):
    """Create a dedicated inode; never change ACL or ownership of existing folders."""
    lock_directory(parent_fd)
    check_identity(parent_path, parent_identity)
    if not caller_can_open(parent_path, account.pw_uid, parent_identity):
        raise PrepareError('parent_access_denied', 'Firebird cannot traverse the selected parent directory.')
    name = 'recorder-firebird'
    child_path = posixpath.join(parent_path, name)
    created = False
    try:
        os.mkdir(name, 0o700, dir_fd=parent_fd)
        created = True
    except FileExistsError:
        pass
    except OSError as exc:
        raise PrepareError('directory_create_failed', 'Cannot create the managed child directory.') from exc
    flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW
    try:
        fd = os.open(name, flags, dir_fd=parent_fd)
    except OSError as exc:
        code = 'created_incomplete' if created else 'destination_unmanaged'
        raise PrepareError(code, 'Child path is not a safe directory; inspect it before retrying.') from exc
    try:
        identity = os.fstat(fd)
        check_identity(child_path, identity)
        if not created:
            validate_marker(fd, identity, caller, account)
        else:
            if identity.st_uid != 0:
                raise PrepareError('created_incomplete', 'New child owner is unexpected; inspect it manually.')
            # Only this new inode is modified, never the selected parent or an
            # existing child. Remove inherited ACL/default ACL before sharing.
            os.fchmod(fd, 0o700)
            result = run(['/usr/bin/setfacl', '-bk', '--', '/proc/self/fd/' + str(fd)], pass_fds=(fd,))
            if result.returncode:
                raise PrepareError('created_incomplete', 'Could not remove inherited child ACL; inspect the new child.')
            if caller and caller != account.pw_uid:
                edit_acl(fd, '-m', 'u:' + str(caller) + ':rwx,m::rwx')
            write_marker(fd, identity, caller, account)
            os.fchown(fd, account.pw_uid, account.pw_gid)
        check_identity(child_path, identity)
        child_identity = os.fstat(fd)
        if caller and caller != account.pw_uid and not caller_can_open(child_path, caller, child_identity):
            raise PrepareError('caller_access_denied', 'The caller cannot inspect the managed child directory.')
        if not probe_as_firebird(child_path, account.pw_name, child_identity):
            raise PrepareError('access_denied', 'Firebird cannot create and chmod a file in the managed child.')
        check_identity(child_path, child_identity)
        return ('prepared' if created else 'ready', child_path)
    except Exception as exc:
        # Do not rmdir or unlink on failure: an independently writable parent
        # can have been changed concurrently. Report partial creation instead.
        if created and not isinstance(exc, PrepareError):
            raise PrepareError('created_incomplete', 'A new child may remain; inspect it before retrying.') from exc
        if created and isinstance(exc, PrepareError) and exc.code != 'created_incomplete':
            raise PrepareError('created_incomplete', 'A new child may remain; inspect it before retrying. ' + str(exc)) from exc
        raise
    finally:
        os.close(fd)


def prepare(path, grant=False, create_child=False):
    if os.geteuid() != 0:
        raise PrepareError('not_privileged', 'This helper requires a privileged launcher.')
    account = firebird_account()
    fd = open_directory(path)
    try:
        identity = os.fstat(fd)
        caller = invoking_uid()
        if caller and identity.st_uid != caller:
            if identity.st_uid != account.pw_uid:
                raise PrepareError('not_owner', 'The selected directory is owned by neither the caller nor Firebird.')
            if not caller_can_open(path, caller, identity):
                raise PrepareError('caller_access_denied', 'The invoking user cannot safely inspect the selected directory.')
            check_identity(path, identity)
        fs = filesystem_type(fd)
        if fs in ('ntfs', 'ntfs3', 'fuseblk', 'vfat', 'exfat'):
            raise PrepareError('unsupported_filesystem',
                               'This filesystem may not support Firebird chmod/locking; use a mounted Linux filesystem.')
        if not probe_as_firebird(path, account.pw_name, identity):
            if create_child:
                if fs not in ('ext4', 'xfs', 'btrfs', 'tmpfs'):
                    raise PrepareError('unsupported_filesystem', 'Managed directories require a local Linux filesystem.')
                if caller and not caller_can_open(path, caller, identity):
                    raise PrepareError('caller_access_denied', 'The invoking user cannot safely inspect the parent directory.')
                check_identity(path, identity)
                return create_managed_child(fd, path, identity, caller, account)
            if grant:
                if fs not in ('ext4', 'xfs', 'btrfs', 'tmpfs'):
                    raise PrepareError('unsupported_filesystem', 'Automatic ACL changes are limited to local Linux filesystems.')
                return grant_access(fd, path, identity, account)
            raise PrepareError('access_denied',
                               'Firebird cannot safely create and chmod a file here; permissions were not changed.')
        check_identity(path, identity)
        return 'ready'
    finally:
        os.close(fd)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--grant', action='store_true',
                      help='Experimentally grant the existing directory access via one ACL entry')
    mode.add_argument('--create-child', action='store_true',
                      help='Create or verify a dedicated managed child in this directory')
    parser.add_argument('directory', help='Existing local database directory')
    args = parser.parse_args()
    if args.grant or args.create_child:
        print(json.dumps({'ok': False, 'code': 'experimental_disabled',
                          'message': 'Permission changes are disabled pending independent security review.'}))
        return 2
    try:
        result = prepare(args.directory, grant=args.grant, create_child=args.create_child)
        state, directory = result if isinstance(result, tuple) else (result, args.directory)
        print(json.dumps({'ok': True, 'state': state, 'directory': directory}))
        return 0
    except PrepareError as exc:
        print(json.dumps({'ok': False, 'code': exc.code, 'message': str(exc)}))
        return 1
    except Exception:
        print(json.dumps({'ok': False, 'code': 'unknown_state',
                          'message': 'Unexpected failure; inspect the directory before retrying.'}))
        return 1


if __name__ == '__main__':
    sys.exit(main())
