"""Safe first install and upgrade of the machine-owned Recorder paths."""
import configparser
import io
import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path

if os.name == "posix":
    import grp
    import pwd

import build_deb


class PathsUpgradeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="rlnx-upgrade-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        data = build_deb.make_control_tar("1.0", "amd64", 1)
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
            self.preinst = archive.extractfile("preinst").read().decode()
            self.postinst = archive.extractfile("postinst").read().decode()
        self.paths = self.root / "opt/mera/RecorderLnx/RecorderLnx.paths.ini"
        self.backup = self.root / "var/lib/recorderlnx/RecorderLnx.paths.ini.pre-upgrade"

    def translated(self, script):
        # A script copied into a throwaway root: it never touches the real host.
        for prefix in ("/opt/mera/RecorderLnx", "/var/lib/recorderlnx",
                       "/usr/share/recorderlnx/config"):
            script = script.replace(prefix, str(self.root) + prefix)
        return script

    @unittest.skipUnless(shutil.which("sh"), "POSIX shell required")
    def test_upgrade_preserves_machine_paths_and_resolves_active_root(self):
        self.paths.parent.mkdir(parents=True)
        original = b"[Paths]\nMeraFiles=/home/user/Mera files\nConfig=/custom config\n"
        self.paths.write_bytes(original)
        subprocess.run(["sh", "-c", self.translated(self.preinst), "preinst", "upgrade"], check=True)
        self.assertEqual(self.backup.read_bytes(), original)
        # dpkg removes a file owned by the old package but omitted by the new one.
        self.paths.unlink()
        start = self.postinst.index("recorder_mera_root()")
        end = self.postinst.index('recorder_data_root="$mera_files_root/RecorderLnx"', start)
        snippet = self.translated(self.postinst[start:end])
        result = subprocess.run(["sh", "-c", snippet + '\nprintf "%s" "$mera_files_root"'],
                                check=True, capture_output=True, text=True)
        self.assertEqual(result.stdout, "/home/user/Mera files")
        self.assertEqual(self.paths.read_bytes(), original)
        self.assertFalse(self.backup.exists())

    @unittest.skipUnless(shutil.which("sh"), "POSIX shell required")
    def test_first_install_and_repeated_configure_keep_user_path(self):
        home = self.root / "home" / "desktop"
        home.mkdir(parents=True)
        fakebin = self.root / "bin"
        fakebin.mkdir()
        fake_id = fakebin / "id"
        fake_id.write_text("#!/bin/sh\nprintf '1000\\n'\n", encoding="utf-8")
        fake_getent = fakebin / "getent"
        fake_getent.write_text("#!/bin/sh\nprintf 'desktop:x:1000:1000::%s:/bin/bash\\n' '" + str(home) + "'\n", encoding="utf-8")
        fake_id.chmod(0o755)
        fake_getent.chmod(0o755)
        env = dict(os.environ, SUDO_USER="desktop", PATH=str(fakebin) + os.pathsep + os.environ["PATH"])
        start = self.postinst.index("recorder_mera_root()")
        end = self.postinst.index('recorder_data_root="$mera_files_root/RecorderLnx"', start)
        snippet = self.translated(self.postinst[start:end])
        subprocess.run(["sh", "-c", snippet], check=True, env=env)
        self.assertIn("MeraFiles=" + str(home / "Mera Files"), self.paths.read_text(encoding="utf-8"))
        self.paths.write_text("[Paths]\nMeraFiles=/custom\n", encoding="utf-8")
        self.backup.parent.mkdir(parents=True, exist_ok=True)
        self.backup.write_text("[Paths]\nMeraFiles=/stale\n", encoding="utf-8")
        subprocess.run(["sh", "-c", snippet], check=True, env=env)
        self.assertIn("/custom", self.paths.read_text(encoding="utf-8"))
        self.assertFalse(self.backup.exists())
        self.paths.write_text("[Paths]\nMeraFiles=\n", encoding="utf-8")
        result = subprocess.run(["sh", "-c", snippet + '\nprintf "%s" "$mera_files_root"'],
                                check=True, env=env, capture_output=True, text=True)
        self.assertEqual(result.stdout, str(home / "Mera Files"))
        self.assertEqual(self.paths.read_text(encoding="utf-8"), "[Paths]\nMeraFiles=\n")

    @unittest.skipUnless(shutil.which("sh"), "POSIX shell required")
    def test_no_desktop_user_never_uses_root_home(self):
        fakebin = self.root / "bin"
        fakebin.mkdir()
        for name in ("getent", "id"):
            command = fakebin / name
            command.write_text("#!/bin/sh\nexit 1\n", encoding="utf-8")
            command.chmod(0o755)
        env = dict(os.environ, SUDO_USER="", PATH=str(fakebin) + os.pathsep + os.environ["PATH"])
        start = self.postinst.index("recorder_mera_root()")
        end = self.postinst.index('recorder_data_root="$mera_files_root/RecorderLnx"', start)
        snippet = 'log() { :; }\n' + self.translated(self.postinst[start:end])
        result = subprocess.run(["sh", "-c", snippet], env=env)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.paths.exists())

    @unittest.skipUnless(shutil.which("sh"), "POSIX shell required")
    def test_nonroot_account_pointing_at_root_home_is_rejected(self):
        fakebin = self.root / "bin"
        fakebin.mkdir()
        for name, output in (("id", "1000"),
                             ("getent", "desktop:x:1000:1000::/root:/bin/bash")):
            command = fakebin / name
            command.write_text("#!/bin/sh\nprintf '%s\\n' '" + output + "'\n", encoding="utf-8")
            command.chmod(0o755)
        env = dict(os.environ, SUDO_USER="desktop", PATH=str(fakebin) + os.pathsep + os.environ["PATH"])
        start = self.postinst.index("recorder_mera_root()")
        end = self.postinst.index('recorder_data_root="$mera_files_root/RecorderLnx"', start)
        snippet = 'log() { :; }\n' + self.translated(self.postinst[start:end])
        self.assertNotEqual(subprocess.run(["sh", "-c", snippet], env=env).returncode, 0)
        self.assertFalse(self.paths.exists())

    @unittest.skipUnless(shutil.which("sh") and hasattr(os, "geteuid") and os.geteuid() == 0,
                         "root is needed to verify real ownership changes")
    def test_seed_in_existing_empty_project_changes_new_files_only(self):
        nobody = pwd.getpwnam("nobody")
        group = grp.getgrgid(nobody.pw_gid).gr_name
        project = self.root / "config/projects/default"
        package = self.root / "package"
        project.mkdir(parents=True)
        package.mkdir()
        (package / "config.json").write_text("{}", encoding="utf-8")
        env = dict(os.environ, config_root=str(self.root / "config"), package_project=str(package),
                   config_new="0", projects_new="0", project_new="0",
                   runtime_user=nobody.pw_name, runtime_group=group)
        begin = self.postinst.index('  if [ "$config_new" = 1 ]; then')
        end = self.postinst.index('  for path_flag in ', begin)
        code = 'set -eu\nlog() { :; }\n' + build_deb.default_project_seed_script() + self.postinst[begin:end]
        subprocess.run(["sh", "-c", code], env=env, check=True)
        self.assertEqual((project / "config.json").stat().st_uid, nobody.pw_uid)
        self.assertEqual(project.stat().st_uid, 0)

    @unittest.skipUnless(shutil.which("sh"), "POSIX shell required")
    def test_parser_handles_spaces_and_never_evaluates_shell(self):
        ini = self.root / "paths.ini"
        marker = self.root / "executed"
        ini.write_text("[Other]\nMeraFiles=/bad\n[Paths]\nMeraFiles=$(touch " +
                       str(marker) + ")\n", encoding="utf-8")
        script = build_deb.mera_root_resolver_script() + '\nrecorder_mera_root "$1" /opt/app /fallback'
        result = subprocess.run(["sh", "-c", script, "test", str(ini)],
                                check=True, capture_output=True, text=True)
        self.assertIn("$(touch ", result.stdout)
        self.assertFalse(marker.exists())

    def test_template_has_no_per_machine_credentials(self):
        config = configparser.ConfigParser()
        config.read_string(build_deb.APP_INI_TEMPLATE)
        self.assertEqual(config["Application"]["DefaultProjectConfigDir"], "config/projects/default")
        self.assertEqual(config["SQLdbConnection"]["Backend"], "firebird")
        self.assertFalse(any("password" in key or key == "host"
                             for section in config.sections() for key in config[section]))
        self.assertIn('home_mera_root="${runtime_home%/}/Mera Files"', self.postinst)


if __name__ == "__main__":
    unittest.main()
