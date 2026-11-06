"""Regression checks for production freshness versus SDK tests/build copies."""
import os
import tempfile
import unittest
from pathlib import Path

import build_deb


class SourceFreshnessTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "tmp" / "checkout"

    def source(self, relative, timestamp):
        path = self.repo / "Lazarus" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("source", encoding="utf-8")
        os.utime(path, (timestamp, timestamp))
        return path

    def test_test_plugins_and_generated_builds_do_not_invalidate_production(self):
        production = self.source("RecorderLnx/Plugins/SDK/uApi.pas", 100)
        for relative in (
            "RecorderLnx/Plugins/SDK/Tests/VisualComponentAbiV2/Probe.lpr",
            "RecorderLnx/Plugins/SampleInfoPlugin/_buildverify_v2/units/Form.lfm",
            "RecorderLnx/_buildverify_camera_0172/Copy.pas",
            "SharedUtils/Tests/Probe.lpi",
            "RecorderLnx/MeraButtonProbe.lpr",
            "RecorderLnx/SqlDiscoveryProbe.lpi",
        ):
            self.source(relative, 300)
        self.assertEqual(build_deb.newest_source(self.repo), production)

    def test_production_sdk_shared_units_and_project_inputs_still_invalidate(self):
        for index, relative in enumerate((
            "RecorderLnx/Plugins/SDK/uApi.pas",
            "SharedUtils/uShared.pas",
            "RecorderLnx/RecorderLnx.lpi",
            "RecorderLnx/resources/app/app.rc",
        )):
            production = self.source(relative, 100 + index)
            self.assertEqual(build_deb.newest_source(self.repo), production)

    def test_setup_tree_includes_its_own_sources_but_not_tests(self):
        production = self.source("RecorderLnx/Tools/LinuxSetupManager/Core.pas", 100)
        self.source("RecorderLnx/Tools/LinuxSetupManager/Tests/Probe.lpr", 300)
        self.assertEqual(build_deb.newest_tree_source(production.parent), production)


if __name__ == "__main__":
    unittest.main()
