"""Tests for package templates and non-destructive upgrade seeding."""
import io
import configparser
import json
import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path

import build_deb


class ProjectTemplateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.template = self.root / "template"
        self.template.mkdir()

    def write(self, name, value):
        (self.template / name).write_text(value, encoding="utf-8")

    def packaged(self):
        buffer = io.BytesIO()
        with tarfile.open(fileobj=buffer, mode="w") as tar:
            build_deb.add_default_project_tree(tar, self.template, "default")
        buffer.seek(0)
        with tarfile.open(fileobj=buffer, mode="r") as tar:
            return {m.name: tar.extractfile(m).read().decode("utf-8")
                    for m in tar.getmembers() if m.isfile()}

    def test_missing_source_has_safe_empty_project(self):
        files = self.packaged()
        self.assertEqual(set(files), {"default/config.json", "default/gui.ini", "default/run-control.ini"})
        config = json.loads(files["default/config.json"])
        self.assertEqual(config["tags"], [])
        self.assertEqual(config["dataSources"], [])
        self.assertNotIn("networkBindAddress", config)
        gui = configparser.ConfigParser()
        gui.read_string(files["default/gui.ini"])
        self.assertEqual(gui.getint("Project", "PageCount"), 1)
        self.assertEqual(gui.get("Page.0", "Id"), "Page1")
        run_control = configparser.ConfigParser()
        run_control.read_string(files["default/run-control.ini"])
        self.assertEqual(run_control.get("Start", "Condition"), "Manual")
        self.assertEqual(run_control.get("Stop", "Condition"), "Manual")
        shutil.rmtree(self.template)
        self.assertEqual(self.packaged(), files)

    def test_legacy_template_maps_to_new_names_and_preserves_true_control(self):
        for name, value in (("default.config.json", "legacy config"),
                            ("default.gui.ini", "legacy gui"),
                            ("default.run-control.ini", "legacy control"),
                            ("run-control.ini", "unrelated old control"),
                            ("sql-db.ini", "project SQL")):
            self.write(name, value)
        files = self.packaged()
        self.assertEqual(files, {"default/config.json": "legacy config",
                                 "default/gui.ini": "legacy gui",
                                 "default/run-control.ini": "legacy control",
                                 "default/sql-db.ini": "project SQL"})

    def test_canonical_template_is_used_without_old_duplicates(self):
        for name in ("config.json", "gui.ini", "run-control.ini"):
            self.write(name, "new " + name)
        self.write("default.run-control.ini", "obsolete")
        files = self.packaged()
        self.assertEqual(files["default/run-control.ini"], "new run-control.ini")
        self.assertNotIn("default/default.run-control.ini", files)
        self.assertEqual(len(files), 3)

    def test_partial_template_fails_instead_of_mixing_families(self):
        self.write("config.json", "new config")
        for name in ("default.config.json", "default.gui.ini", "default.run-control.ini"):
            self.write(name, "legacy")
        with self.assertRaises(FileNotFoundError):
            self.packaged()

    @unittest.skipUnless(shutil.which("sh"), "POSIX shell required")
    def test_seed_only_into_empty_directory_preserves_partial_projects(self):
        package = self.root / "package"
        package.mkdir()
        (package / "config.json").write_text("packaged", encoding="utf-8")
        (package / "gui.ini").write_text("packaged gui", encoding="utf-8")
        config = self.root / "config"
        project = config / "projects" / "default"
        project.mkdir(parents=True)
        script = "set -eu\nlog() { :; }\n" + build_deb.default_project_seed_script()
        env = dict(os.environ, config_root=str(config), package_project=str(package))
        subprocess.run(["sh", "-c", script], env=env, check=True)
        self.assertEqual((project / "config.json").read_text(), "packaged")
        for child in project.iterdir():
            child.unlink()
        (project / "default.gui.ini").write_text("user gui", encoding="utf-8")
        subprocess.run(["sh", "-c", script], env=env, check=True)
        self.assertEqual((project / "default.gui.ini").read_text(), "user gui")
        self.assertEqual(sorted(p.name for p in project.iterdir()), ["default.gui.ini"])
        (project / "default.config.json").write_text("user legacy", encoding="utf-8")
        subprocess.run(["sh", "-c", script], env=env, check=True)
        self.assertEqual((project / "default.config.json").read_text(), "user legacy")
        self.assertFalse((project / "config.json").exists())

    @unittest.skipUnless(shutil.which("sh"), "POSIX shell required")
    def test_install_check_accepts_complete_new_and_legacy_families(self):
        complete = build_deb.install_check_script()
        start = complete.index('if [ -f "$mera_files_root/RecorderLnx/config/projects/default/config.json"')
        end = complete.index("if { command -v ldconfig", start)
        snippet = complete[start:end]
        project = self.root / "RecorderLnx/config/projects/default"
        project.mkdir(parents=True)
        script = 'status=0\ncheck_path() { test -f "$1" || status=1; }\n' + snippet + '\nexit "$status"\n'
        env = dict(os.environ, mera_files_root=str(self.root))
        for files in (("config.json", "gui.ini", "run-control.ini"),
                      ("default.config.json", "default.gui.ini", "default.run-control.ini")):
            for name in files:
                (project / name).write_text("fixture", encoding="utf-8")
            subprocess.run(["sh", "-c", script], check=True, env=env)
            (project / files[1]).unlink()
            self.assertNotEqual(subprocess.run(["sh", "-c", script], env=env).returncode, 0)
            for path in project.iterdir():
                path.unlink()


if __name__ == "__main__":
    unittest.main()
