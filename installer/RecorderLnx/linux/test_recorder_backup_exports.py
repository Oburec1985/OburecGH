import configparser
import os
import pathlib
import shutil
import tempfile
import unittest
from unittest import mock

import recorder_backup_exports as mod


def config_text():
    return ''.join(
        f'[{name}]\n path = /old/{name}\n valid users = user\n'
        ' read only = yes\n guest ok = no\n follow symlinks = no\n\n'
        for name in mod.SHARES)


class ExportsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='recorder-backup-export-test-')
        self.root = pathlib.Path(self.temp.name)
        self.app = self.root / 'service' / 'app.ini'
        self.app.parent.mkdir()
        self.project = self.root / 'projects' / 'project-one'
        self.project.mkdir(parents=True)
        (self.project / 'config.json').write_text('{"tags": []}', encoding='utf-8')
        self.mera = self.root / 'mera'
        (self.mera / 'Calibr').mkdir(parents=True)
        (self.mera / 'SDB').mkdir()
        self.app.write_text('[Application]\nDefaultProjectConfigDir=' + str(self.project) + '\n', encoding='utf-8')
        (self.app.parent / 'storage.ini').write_text('[Storage]\nMeraFilesPath=' + str(self.mera) + '\n', encoding='utf-8')

    def tearDown(self):
        self.temp.cleanup()

    def test_plan_selects_active_project_and_machine_root(self):
        project, mera, paths, inputs = mod.make_plan(self.app)
        self.assertEqual(project, self.project)
        self.assertEqual(mera, self.mera)
        self.assertEqual(paths['RecorderProjects'], str(self.project.parent))
        self.assertIn(self.app, inputs)

    def test_active_root_switch_reads_new_app_and_preserves_old(self):
        paths_ini = self.root / 'paths.ini'
        roots = [self.root / 'Mera Files one', self.root / 'Mera Files two']
        apps = []
        for root in roots:
            app = root / 'RecorderLnx' / 'app.ini'
            app.parent.mkdir(parents=True)
            app.write_bytes(self.app.read_bytes())
            (app.parent / 'storage.ini').write_bytes((self.app.parent / 'storage.ini').read_bytes())
            apps.append(app)
        with mock.patch.object(mod, 'PATHS_INI', paths_ini), \
             mock.patch.object(mod, 'check_root_file', side_effect=os.lstat):
            for root, expected in zip(roots, apps):
                paths_ini.write_text('[Paths]\nMeraFiles=' + str(root) + '\n', encoding='utf-8')
                self.assertEqual(mod.active_app(), expected)
                self.assertEqual(mod.make_plan()[0], self.project)
            self.assertTrue(apps[0].exists())

    def test_invalid_new_root_does_not_overwrite_existing_export(self):
        new_app = self.root / 'new root' / 'RecorderLnx' / 'app.ini'
        new_app.parent.mkdir(parents=True)
        include = self.root / 'include.conf'
        include.write_text('old export remains', encoding='utf-8')
        with mock.patch.object(mod, 'active_app', return_value=new_app), \
             mock.patch.object(mod, 'PATHS_INI', self.root / 'absent-paths.ini'), \
             mock.patch.object(mod, 'LOCK', str(self.root / 'lock')), \
             mock.patch.object(mod, 'require_root'), \
             mock.patch.object(mod, 'trusted_lock', return_value=True), \
             mock.patch.object(mod, 'user_write', side_effect=mod.atomic_user_write):
            with self.assertRaises(PermissionError):
                mod.refresh()
        self.assertEqual(include.read_text(encoding='utf-8'), 'old export remains')
        self.assertEqual(mod.read_ini(new_app.parent / mod.METADATA_NAME).get('BackupExport', 'State'), 'updating')

    def test_unfinished_project_is_not_published(self):
        (self.project / 'config.json').write_text('{', encoding='utf-8')
        with self.assertRaises(ValueError):
            mod.make_plan(self.app)

    def test_legacy_foreign_path_is_not_guessed(self):
        (self.app.parent / 'storage.ini').unlink()
        (self.project / 'default.run-control.ini').write_text('[Mera]\nFilesPath=C:\\Mera Files\n')
        with self.assertRaisesRegex(ValueError, 'cannot establish'):
            mod.make_plan(self.app)

    def test_render_preserves_security_and_rejects_duplicates(self):
        paths = {n: '/new/' + n for n in mod.SHARES}
        rendered = mod.render_smb(config_text(), paths, install=True)
        for name in paths:
            self.assertIn('include = ' + str(mod.include_file(name)), rendered)
        with self.assertRaises(ValueError):
            mod.render_smb(config_text() + config_text(), paths, install=True)
        with self.assertRaises(ValueError):
            mod.render_smb(config_text().replace('read only = yes', 'read only = no', 1), paths, install=True)

    @unittest.skipUnless(shutil.which('testparm'), 'Samba testparm is not installed')
    def test_real_testparm_resolves_managed_include(self):
        includes = self.root / 'includes'
        includes.mkdir()
        paths = {name: str(self.root) for name in mod.SHARES}
        with mock.patch.object(mod, 'INCLUDE_DIR', includes):
            for name in mod.SHARES:
                mod.include_file(name).write_bytes(mod.include_bytes(paths[name]))
            config = self.root / 'smb.conf'
            config.write_text('[global]\n security = user\n' +
                              mod.render_smb(config_text(), paths, install=True))
            mod.verify_effective_config(config, paths)
            mod.include_file('RecorderProjects').write_bytes(mod.include_bytes('/wrong'))
            with self.assertRaises(ValueError):
                mod.verify_effective_config(config, paths)

    def test_transaction_invalidates_then_publishes_matching_markers(self):
        smb = self.root / 'smb.conf'
        includes = self.root / 'includes'
        includes.mkdir()
        with mock.patch.object(mod, 'INCLUDE_DIR', includes):
            smb.write_text(mod.render_smb(config_text(), mod.SHARES, install=True), encoding='utf-8')
            for name in mod.SHARES:
                mod.include_file(name).write_bytes(mod.include_bytes('/old/' + name))
        original_smb = smb.read_bytes()
        metadata = self.app.parent / 'backup-export-info.ini'
        lock = self.root / 'lock'
        calls = []

        def fake_run(args, **kwargs):
            calls.append(args)
            if args[0] == 'smbcontrol':
                current = mod.read_ini(metadata)
                self.assertEqual(current.get('BackupExport', 'State'), 'updating')
            return mock.Mock(returncode=0)

        with mock.patch.object(mod, 'active_app', return_value=self.app), mock.patch.object(mod, 'SMB', smb), \
             mock.patch.object(mod, 'PATHS_INI', self.root / 'absent-paths.ini'), \
             mock.patch.object(mod, 'INCLUDE_DIR', includes), \
             mock.patch.object(mod, 'trusted_include_dir', return_value=True), \
             mock.patch.object(mod, 'verify_effective_config'), \
             mock.patch.object(mod, 'check_root_file', side_effect=os.lstat), \
             mock.patch.object(mod, 'LOCK', str(lock)), \
             mock.patch.object(mod, 'require_root'), \
             mock.patch.object(mod, 'trusted_lock', return_value=True), \
             mock.patch.object(mod, 'user_write', side_effect=mod.atomic_user_write), \
             mock.patch.object(mod.subprocess, 'run', side_effect=fake_run):
            with mock.patch.object(mod, 'make_plan', side_effect=lambda app: original_plan(app)):
                real_replace = os.replace
                replacements = []
                def fail_include(source, target):
                    if pathlib.Path(target).parent == includes:
                        replacements.append(target)
                        if len(replacements) == 1:
                            raise OSError('simulated interruption')
                    return real_replace(source, target)
                with mock.patch.object(mod.os, 'replace', side_effect=fail_include):
                    with self.assertRaisesRegex(OSError, 'simulated interruption'):
                        mod.refresh()
                self.assertEqual(mod.read_ini(metadata).get('BackupExport', 'State'), 'updating')
                mod.refresh()
        self.assertEqual(smb.read_bytes(), original_smb)
        result = mod.read_ini(metadata)['BackupExport']
        self.assertEqual(result['State'], 'ready')
        self.assertTrue(any(c[0] == 'smbcontrol' and c[2] == 'close-share' for c in calls))
        for share, field in mod.GEN_FIELDS.items():
            marker = pathlib.Path(result[mod.SHARES[share]]) / (mod.MARKER_PREFIX + result[field])
            self.assertEqual(marker.read_text().strip(), result[field])

    def test_marker_does_not_overwrite_existing_file_or_symlink(self):
        gen = 'a' * 32
        path = self.root / (mod.MARKER_PREFIX + gen)
        path.write_text('user data')
        with self.assertRaises(FileExistsError):
            mod.atomic_user_write(path, (gen + '\n').encode())
        self.assertEqual(path.read_text(), 'user data')


original_plan = mod.make_plan

if __name__ == '__main__':
    unittest.main()
