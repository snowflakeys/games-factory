"""Pin-integrity behavior: source/copy drift, dependency completeness, safe destinations."""

import json
import shutil
import tempfile
import unittest
from pathlib import Path

from scripts import shared_systems as systems


class SharedSystemTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        shutil.copytree(systems.ROOT / "shared-systems", self.root / "shared-systems")
        (self.root / "factory-state").mkdir()
        (self.root / "factory-state/state.json").write_text('{"games":["game-999"]}')
        self.game = self.root / "games/game-999"
        self.game.mkdir(parents=True)
        self.lock_path = self.game / "shared-systems.lock.json"
        self.save({"schema_version": 1, "systems": []})
        systems.install(self.root, "game-999", "seeded-random", "1.0.0", "src/server/Systems")

    def lock(self):
        return json.loads(self.lock_path.read_text())

    def save(self, value):
        self.lock_path.write_text(json.dumps(value))

    def verify(self):
        systems.validate_lock(self.root, self.game, self.lock())

    def test_install_is_a_verified_copy_with_a_package_digest(self):
        self.verify()
        self.assertEqual(len(systems.catalog(self.root)), 4)
        self.assertEqual(len(self.lock()["systems"][0]["sha256"]), 64)
        self.assertEqual((self.game / "src/server/Systems/SeededRandom.luau").read_bytes(),
                         (self.root / "shared-systems/seeded-random/1.0.0/SeededRandom.luau").read_bytes())

    def test_source_edits_cannot_silently_upgrade_games(self):
        source = self.root / "shared-systems/seeded-random/1.0.0/SeededRandom.luau"
        source.write_text(source.read_text() + "\n-- drift\n")
        with self.assertRaisesRegex(ValueError, "digest mismatch"):
            self.verify()

    def test_contract_and_test_changes_are_also_hashed(self):
        contract = self.root / "shared-systems/seeded-random/1.0.0/README.md"
        contract.write_text(contract.read_text() + "\nChanged contract.\n")
        with self.assertRaisesRegex(ValueError, "digest mismatch"):
            self.verify()

    def test_game_copy_edits_are_detected(self):
        copied = self.game / "src/server/Systems/SeededRandom.luau"
        copied.write_text(copied.read_text() + "\n-- drift\n")
        with self.assertRaisesRegex(ValueError, "vendored copy differs"):
            self.verify()

    def test_dependency_must_be_pinned_at_its_exact_version(self):
        systems.install(self.root, "game-999", "public-history-bot", "1.0.0", "src/server/Systems")
        self.verify()
        lock = self.lock()
        lock["systems"] = lock["systems"][1:]
        self.save(lock)
        with self.assertRaisesRegex(ValueError, "Missing pinned dependency"):
            self.verify()

    def test_duplicate_pin_is_rejected(self):
        lock = self.lock()
        lock["systems"].append(lock["systems"][0])
        self.save(lock)
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            self.verify()

    def test_source_path_must_identify_the_pinned_package(self):
        lock = self.lock()
        lock["systems"][0]["source"] = "shared-systems/seeded-random/main"
        self.save(lock)
        with self.assertRaisesRegex(ValueError, "source must match"):
            self.verify()

    def test_copied_module_map_cannot_omit_a_source(self):
        lock = self.lock()
        lock["systems"][0]["files"] = {}
        self.save(lock)
        with self.assertRaisesRegex(ValueError, "copy map"):
            self.verify()

    def test_paths_cannot_escape_the_game(self):
        lock = self.lock()
        lock["systems"][0]["files"]["SeededRandom.luau"] = "src/../../outside.luau"
        self.save(lock)
        with self.assertRaisesRegex(ValueError, "Unsafe"):
            self.verify()
        for relative in ("/outside", "../outside", "src/./x", "src\\x"):
            with self.subTest(relative=relative), self.assertRaises(ValueError):
                systems.safe_path(self.game, relative)

    def test_unpinned_system_module_is_rejected(self):
        (self.game / "src/server/Systems/Rogue.luau").write_text("return {}\n")
        with self.assertRaisesRegex(ValueError, "Unpinned module"):
            self.verify()

    def test_package_requires_contract_and_tests(self):
        (self.root / "shared-systems/seeded-random/1.0.0/tests/run.luau").unlink()
        with self.assertRaisesRegex(ValueError, "contract/source/test"):
            systems.catalog(self.root)

    def test_installer_refuses_to_overwrite_a_game_source_or_existing_pin(self):
        before = self.lock_path.read_bytes()
        with self.assertRaisesRegex(ValueError, "Already pinned"):
            systems.install(self.root, "game-999", "seeded-random", "1.0.0", "src/server/Systems")
        occupied = self.game / "src/server/Systems/TokenBucket.luau"
        occupied.write_text("return 'local'\n")
        with self.assertRaisesRegex(ValueError, "unused paths"):
            systems.install(self.root, "game-999", "token-bucket", "1.0.0", "src/server/Systems")
        self.assertEqual(before, self.lock_path.read_bytes())
        self.assertEqual(occupied.read_text(), "return 'local'\n")

    def test_symlink_cannot_redirect_validation_outside_the_game(self):
        copied = self.game / "src/server/Systems/SeededRandom.luau"
        copied.unlink()
        try:
            copied.symlink_to(self.root / "shared-systems/seeded-random/1.0.0/SeededRandom.luau")
        except OSError:
            self.skipTest("Symlinks unavailable on this host")
        with self.assertRaisesRegex(ValueError, "symlinks"):
            self.verify()


if __name__ == "__main__":
    unittest.main()
