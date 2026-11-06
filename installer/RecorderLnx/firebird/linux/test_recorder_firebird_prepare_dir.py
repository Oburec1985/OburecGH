"""Contract tests for the single-directory Firebird permission helper."""
import importlib.util
import contextlib
import io
import json
import os
from pathlib import Path
import stat
import sys
import types
import unittest
from unittest.mock import patch

if os.name == 'nt':
    sys.modules['pwd'] = types.SimpleNamespace()

spec = importlib.util.spec_from_file_location(
    'firebird_prepare', Path(__file__).with_name('recorder_firebird_prepare_dir.py'))
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
real_invoking_uid = helper.invoking_uid


class DirectoryPreparationTests(unittest.TestCase):
    def setUp(self):
        self.account = types.SimpleNamespace(pw_name='firebird', pw_uid=84)
        self.patches = [
            patch.object(helper.os, 'geteuid', return_value=0, create=True),
            patch.object(helper.os, 'close'),
            patch.object(helper.os, 'fstat', return_value=types.SimpleNamespace(st_uid=1000, st_dev=1, st_ino=2)),
            patch.object(helper, 'open_directory', return_value=3),
            patch.object(helper, 'invoking_uid', return_value=1000),
            patch.object(helper.pwd, 'getpwnam', return_value=self.account, create=True),
        ]
        for item in self.patches:
            item.start()
            self.addCleanup(item.stop)

    def test_existing_access_is_idempotent(self):
        with patch.object(helper, 'filesystem_type', return_value='ext4'), \
             patch.object(helper, 'probe_as_firebird', return_value=True), \
             patch.object(helper, 'run') as run:
            self.assertEqual(helper.prepare('/mnt/data/base'), 'ready')
            run.assert_not_called()

    def test_ntfs_is_rejected_before_acl_or_write_probe(self):
        with patch.object(helper, 'filesystem_type', return_value='fuseblk'), \
             patch.object(helper, 'probe_as_firebird') as probe, \
             patch.object(helper, 'run') as run:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.prepare('/mnt/data/base')
            self.assertEqual(caught.exception.code, 'unsupported_filesystem')
            probe.assert_not_called()
            run.assert_not_called()

    def test_failed_probe_does_not_modify_acl(self):
        with patch.object(helper, 'filesystem_type', return_value='ext4'), \
             patch.object(helper, 'probe_as_firebird', return_value=False), \
             patch.object(helper, 'run') as run:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.prepare('/mnt/data/base')
            self.assertEqual(caught.exception.code, 'access_denied')
            run.assert_not_called()

    def test_replaced_directory_is_rejected(self):
        original = types.SimpleNamespace(st_uid=1000, st_dev=1, st_ino=2)
        changed = types.SimpleNamespace(st_uid=1000, st_dev=1, st_ino=3)
        with patch.object(helper, 'filesystem_type', return_value='ext4'), \
             patch.object(helper, 'probe_as_firebird', return_value=True), \
             patch.object(helper.os, 'fstat', side_effect=[original, changed]):
            with self.assertRaises(helper.PrepareError) as caught:
                helper.prepare('/mnt/data/base')
            self.assertEqual(caught.exception.code, 'directory_changed')

    def test_non_owner_is_rejected_before_probe(self):
        with patch.object(helper, 'invoking_uid', return_value=2000), \
             patch.object(helper, 'probe_as_firebird') as probe:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.prepare('/mnt/data/base')
            self.assertEqual(caught.exception.code, 'not_owner')
            probe.assert_not_called()

    def test_firebird_owner_with_caller_access_is_allowed(self):
        service_directory = types.SimpleNamespace(st_uid=84, st_dev=1, st_ino=2)
        with patch.object(helper.os, 'fstat', return_value=service_directory), \
             patch.object(helper, 'filesystem_type', return_value='ext4'), \
             patch.object(helper, 'caller_can_open', return_value=True) as caller, \
             patch.object(helper, 'probe_as_firebird', return_value=True) as probe:
            self.assertEqual(helper.prepare('/mnt/data/base'), 'ready')
            caller.assert_called_once_with('/mnt/data/base', 1000, service_directory)
            probe.assert_called_once_with('/mnt/data/base', 'firebird', service_directory)

    def test_firebird_owner_denies_caller_without_traversal(self):
        service_directory = types.SimpleNamespace(st_uid=84, st_dev=1, st_ino=2)
        with patch.object(helper.os, 'fstat', return_value=service_directory), \
             patch.object(helper, 'caller_can_open', return_value=False), \
             patch.object(helper, 'probe_as_firebird') as probe:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.prepare('/mnt/data/base')
            self.assertEqual(caught.exception.code, 'caller_access_denied')
            probe.assert_not_called()

    def test_firebird_owner_replacement_rejected_before_service_probe(self):
        service_directory = types.SimpleNamespace(st_uid=84, st_dev=1, st_ino=2)
        replacement = types.SimpleNamespace(st_uid=84, st_dev=1, st_ino=3)
        with patch.object(helper.os, 'fstat', side_effect=[service_directory, replacement]), \
             patch.object(helper, 'caller_can_open', return_value=True), \
             patch.object(helper, 'probe_as_firebird') as probe:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.prepare('/mnt/data/base')
            self.assertEqual(caught.exception.code, 'directory_changed')
            probe.assert_not_called()

    def test_sudo_uid_takes_priority_over_pkexec_uid(self):
        with patch.dict(helper.os.environ, {'SUDO_UID': '1001', 'PKEXEC_UID': '0'}, clear=True):
            self.assertEqual(real_invoking_uid(), 1001)

    def test_probe_uses_absolute_executables_without_shell(self):
        result = types.SimpleNamespace(returncode=0)
        identity = types.SimpleNamespace(st_dev=3, st_ino=4)
        with patch.object(helper, 'run', return_value=result) as run:
            self.assertTrue(helper.probe_as_firebird('/mnt/data/base', 'firebird', identity))
            args = run.call_args.args[0]
            self.assertEqual(args[0], '/usr/sbin/runuser')
            self.assertEqual(args[4], '/usr/bin/python3')
            self.assertEqual(args[-3:], ['/mnt/data/base', '3', '4'])

    def test_caller_check_runs_as_actual_caller_without_shell(self):
        result = types.SimpleNamespace(returncode=0)
        identity = types.SimpleNamespace(st_dev=3, st_ino=4)
        caller = types.SimpleNamespace(pw_name='operator')
        with patch.object(helper.pwd, 'getpwuid', return_value=caller, create=True), \
             patch.object(helper, 'run', return_value=result) as run:
            self.assertTrue(helper.caller_can_open('/mnt/data/base', 1000, identity))
            args = run.call_args.args[0]
            self.assertEqual(args[:5], ['/usr/sbin/runuser', '-u', 'operator', '--', '/usr/bin/python3'])
            self.assertEqual(args[-3:], ['/mnt/data/base', '3', '4'])

    def test_cli_mutation_modes_are_fail_closed(self):
        for flag in ('--grant', '--create-child'):
            with self.subTest(flag=flag), \
                 patch.object(sys, 'argv', ['helper', flag, '/mnt/base']), \
                 patch.object(helper, 'prepare') as prepare, \
                 contextlib.redirect_stdout(io.StringIO()) as output:
                self.assertEqual(helper.main(), 2)
                self.assertEqual(json.loads(output.getvalue())['code'], 'experimental_disabled')
                prepare.assert_not_called()


class AclPreparationTests(unittest.TestCase):
    def setUp(self):
        self.before = {'user:': 'rwx', 'group:': 'r-x', 'other:': '---', 'mask:': 'rwx'}
        self.expected = dict(self.before, **{'user:84': 'rwx', 'mask:': 'rwx'})
        self.account = types.SimpleNamespace(pw_name='firebird', pw_uid=84)
        self.identity = types.SimpleNamespace(st_uid=1000, st_dev=1, st_ino=2)
        self.lock = patch.object(helper, 'lock_directory')
        self.check = patch.object(helper, 'check_identity')
        self.lock.start()
        self.check.start()
        self.addCleanup(self.lock.stop)
        self.addCleanup(self.check.stop)

    def test_simple_acl_grant_keeps_base_entries_and_verifies_probe(self):
        with patch.object(helper, 'read_acl', side_effect=[self.before, self.before, self.expected]), \
             patch.object(helper, 'edit_acl') as edit, \
             patch.object(helper, 'probe_as_firebird', return_value=True):
            self.assertEqual(helper.grant_access(3, '/mnt/base', self.identity, self.account), 'prepared')
            edit.assert_called_once_with(3, '-m', 'u:84:rwx')

    def test_restricted_existing_mask_is_never_widened(self):
        existing = dict(self.before, **{'user:200': 'rwx', 'mask:': 'r-x'})
        with patch.object(helper, 'read_acl', return_value=existing), \
             patch.object(helper, 'edit_acl') as edit:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'acl_mask_conflict')
            edit.assert_not_called()

    def test_missing_mask_aborts_to_avoid_concurrent_broadening(self):
        existing = dict(self.before)
        del existing['mask:']
        with patch.object(helper, 'read_acl', return_value=existing), \
             patch.object(helper, 'edit_acl') as edit:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'acl_mask_missing')
            edit.assert_not_called()

    def test_failed_probe_removes_only_our_entry(self):
        reads = [self.before, self.before, self.expected, self.expected, self.before]
        with patch.object(helper, 'read_acl', side_effect=reads), \
             patch.object(helper, 'edit_acl') as edit, \
             patch.object(helper, 'probe_as_firebird', return_value=False):
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'access_denied')
            self.assertEqual(edit.call_args_list[1].args, (3, '-x', 'u:84'))

    def test_concurrent_change_before_write_aborts_without_mutation(self):
        changed = dict(self.before, **{'other:': 'r-x'})
        with patch.object(helper, 'read_acl', side_effect=[self.before, changed]), \
             patch.object(helper, 'edit_acl') as edit:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'acl_conflict')
            edit.assert_not_called()

    def test_unexpected_acl_after_write_does_not_overwrite_another_editor(self):
        changed = dict(self.expected, **{'user:201': 'r--'})
        restored = dict(self.before, **{'user:201': 'r--'})
        with patch.object(helper, 'read_acl', side_effect=[self.before, self.before, changed, changed, restored]), \
             patch.object(helper, 'edit_acl') as edit:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'acl_conflict')
            self.assertEqual(edit.call_args_list[1].args, (3, '-x', 'u:84'))

    def test_timeout_after_write_rolls_back_our_entry(self):
        reads = [self.before, self.before, self.expected, self.before]
        with patch.object(helper, 'read_acl', side_effect=reads), \
             patch.object(helper, 'edit_acl', side_effect=[helper.PrepareError('tool_failure', 'timeout'), None]) as edit:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'acl_write_rolled_back')
            self.assertEqual(edit.call_args_list[1].args, (3, '-x', 'u:84'))

    def test_timeout_and_unknown_acl_is_reported_as_possibly_changed(self):
        with patch.object(helper, 'read_acl', side_effect=[self.before, self.before,
                          helper.PrepareError('acl_unavailable', 'unreadable')]), \
             patch.object(helper, 'edit_acl', side_effect=helper.PrepareError('tool_failure', 'timeout')):
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'acl_state_unknown')
            self.assertIn('may remain', str(caught.exception))

    def test_successful_write_with_unreadable_acl_reports_uncertainty(self):
        with patch.object(helper, 'read_acl', side_effect=[self.before, self.before,
                          helper.PrepareError('acl_unavailable', 'unreadable')]), \
             patch.object(helper, 'edit_acl'):
            with self.assertRaises(helper.PrepareError) as caught:
                helper.grant_access(3, '/mnt/base', self.identity, self.account)
            self.assertEqual(caught.exception.code, 'acl_state_unknown')

    def test_acl_reader_keeps_default_and_numeric_entries(self):
        result = types.SimpleNamespace(returncode=0, stdout=(
            'user::rwx\nuser:84:rwx\t#effective:r-x\ngroup::r-x\n'
            'mask::r-x\nother::---\ndefault:user::rwx\n'))
        with patch.object(helper, 'run', return_value=result):
            entries = helper.read_acl(3)
            self.assertEqual(entries['user:84'], 'rwx')
            self.assertEqual(entries['mask:'], 'r-x')
            self.assertEqual(entries['default:user:'], 'rwx')

    def test_invalid_acl_permissions_are_rejected(self):
        result = types.SimpleNamespace(returncode=0, stdout=(
            'user::rwx\ngroup::rrr\nother::---\n'))
        with patch.object(helper, 'run', return_value=result):
            with self.assertRaises(helper.PrepareError) as caught:
                helper.read_acl(3)
            self.assertEqual(caught.exception.code, 'invalid_acl')

    def test_concurrent_service_entry_is_not_overwritten_on_rollback(self):
        changed = dict(self.expected, **{'user:84': 'r-x'})
        with patch.object(helper, 'read_acl', return_value=changed), \
             patch.object(helper, 'edit_acl') as edit:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.rollback_grant(3, self.before, self.expected, 84)
            self.assertEqual(caught.exception.code, 'acl_state_unknown')
            edit.assert_not_called()

    def test_unrelated_concurrent_entry_is_preserved_on_targeted_rollback(self):
        original = dict(self.before, **{'mask:': 'rwx', 'user:200': 'r-x'})
        expected = dict(original, **{'user:84': 'rwx'})
        current = dict(expected, **{'user:201': 'r--'})
        restored = dict(original, **{'user:201': 'r--'})
        with patch.object(helper, 'read_acl', side_effect=[current, restored]), \
             patch.object(helper, 'edit_acl') as edit:
            helper.rollback_grant(3, original, expected, 84)
            edit.assert_called_once_with(3, '-x', 'u:84')


class ManagedChildTests(unittest.TestCase):
    def setUp(self):
        self.account = types.SimpleNamespace(pw_name='firebird', pw_uid=84, pw_gid=84)
        self.parent = types.SimpleNamespace(st_uid=1000, st_dev=1, st_ino=11)
        self.child_before = types.SimpleNamespace(st_uid=0, st_dev=1, st_ino=22)
        self.child_after = types.SimpleNamespace(st_uid=84, st_dev=1, st_ino=22)
        self.patches = [
            patch.object(helper.os, 'O_DIRECTORY', 0x10000, create=True),
            patch.object(helper.os, 'O_NOFOLLOW', 0x20000, create=True),
            patch.object(helper.os, 'mkdir'),
            patch.object(helper.os, 'open', return_value=7),
            patch.object(helper.os, 'close'),
            patch.object(helper.os, 'fchmod', create=True),
            patch.object(helper.os, 'fchown', create=True),
            patch.object(helper, 'lock_directory'),
            patch.object(helper, 'check_identity'),
            patch.object(helper, 'caller_can_open', return_value=True),
            patch.object(helper, 'probe_as_firebird', return_value=True),
        ]
        for item in self.patches:
            item.start()
            self.addCleanup(item.stop)

    def test_new_child_only_changes_its_own_inode(self):
        ok = types.SimpleNamespace(returncode=0)
        with patch.object(helper.os, 'fstat', side_effect=[self.child_before, self.child_after]), \
             patch.object(helper, 'run', return_value=ok) as run, \
             patch.object(helper, 'edit_acl') as edit, \
             patch.object(helper, 'write_marker') as marker:
            result = helper.create_managed_child(3, '/mnt/base', self.parent, 1000, self.account)
            self.assertEqual(result, ('prepared', '/mnt/base/recorder-firebird'))
            helper.os.mkdir.assert_called_once_with('recorder-firebird', 0o700, dir_fd=3)
            helper.os.fchmod.assert_called_once_with(7, 0o700)
            helper.os.fchown.assert_called_once_with(7, 84, 84)
            self.assertEqual(run.call_args.args[0], ['/usr/bin/setfacl', '-bk', '--', '/proc/self/fd/7'])
            edit.assert_called_once_with(7, '-m', 'u:1000:rwx,m::rwx')
            marker.assert_called_once_with(7, self.child_before, 1000, self.account)

    def test_existing_unmanaged_child_is_never_modified(self):
        helper.os.mkdir.side_effect = FileExistsError()
        with patch.object(helper.os, 'fstat', return_value=self.child_after), \
             patch.object(helper, 'validate_marker', side_effect=helper.PrepareError('destination_unmanaged', 'no marker')), \
             patch.object(helper, 'run') as run, \
             patch.object(helper, 'edit_acl') as edit:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.create_managed_child(3, '/mnt/base', self.parent, 1000, self.account)
            self.assertEqual(caught.exception.code, 'destination_unmanaged')
            helper.os.fchmod.assert_not_called()
            helper.os.fchown.assert_not_called()
            run.assert_not_called()
            edit.assert_not_called()

    def test_existing_managed_child_is_only_checked(self):
        helper.os.mkdir.side_effect = FileExistsError()
        with patch.object(helper.os, 'fstat', return_value=self.child_after), \
             patch.object(helper, 'validate_marker') as marker, \
             patch.object(helper, 'run') as run:
            result = helper.create_managed_child(3, '/mnt/base', self.parent, 1000, self.account)
            self.assertEqual(result, ('ready', '/mnt/base/recorder-firebird'))
            marker.assert_called_once()
            helper.os.fchmod.assert_not_called()
            helper.os.fchown.assert_not_called()
            run.assert_not_called()

    def test_untraversable_parent_is_not_modified(self):
        helper.caller_can_open.return_value = False
        with self.assertRaises(helper.PrepareError) as caught:
            helper.create_managed_child(3, '/mnt/base', self.parent, 1000, self.account)
        self.assertEqual(caught.exception.code, 'parent_access_denied')
        helper.os.mkdir.assert_not_called()

    def test_failure_after_creation_is_explicit_and_never_deletes(self):
        helper.os.fchmod.side_effect = OSError('test failure')
        with patch.object(helper.os, 'fstat', return_value=self.child_before), \
             patch.object(helper.os, 'rmdir') as rmdir, \
             patch.object(helper.os, 'unlink') as unlink:
            with self.assertRaises(helper.PrepareError) as caught:
                helper.create_managed_child(3, '/mnt/base', self.parent, 1000, self.account)
            self.assertEqual(caught.exception.code, 'created_incomplete')
            rmdir.assert_not_called()
            unlink.assert_not_called()

    def test_marker_must_match_root_owned_single_inode(self):
        metadata = types.SimpleNamespace(st_mode=stat.S_IFREG | 0o400, st_uid=0, st_nlink=1)
        marker = {'version': 1, 'device': 1, 'inode': 22, 'caller': 1000, 'firebird': 84}
        with patch.object(helper.os, 'fstat', return_value=metadata), \
             patch.object(helper.os, 'read', return_value=json.dumps(marker).encode('utf-8')):
            helper.validate_marker(7, self.child_after, 1000, self.account)
        marker['inode'] = 99
        with patch.object(helper.os, 'fstat', return_value=metadata), \
             patch.object(helper.os, 'read', return_value=json.dumps(marker).encode('utf-8')):
            with self.assertRaises(helper.PrepareError) as caught:
                helper.validate_marker(7, self.child_after, 1000, self.account)
            self.assertEqual(caught.exception.code, 'destination_unmanaged')


if __name__ == '__main__':
    unittest.main()
