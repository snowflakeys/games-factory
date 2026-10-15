"""Behavioral checks for factory gates and queue/scaffold consistency."""

import shutil
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from scripts import factory


class FactoryTests(unittest.TestCase):
    def setUp(self):
        scratch = factory.ROOT / "work"
        scratch.mkdir(exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(dir=scratch, prefix="factory-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name) / "repo"
        shutil.copytree(factory.ROOT, self.root, ignore=shutil.ignore_patterns(
            ".git", ".tools", "work", "outputs", "__pycache__",
        ))

    def new(self, name="Fixture game"):
        idea_id = factory.add_idea(self.root, name, "Test fixture only", "Unit-test fixture; not Snow approval")
        game_id = factory.new_game(self.root, idea_id)
        return game_id

    def set_stage(self, game_id, stage):
        path = self.root / "games" / game_id / "game.json"
        game = factory.read_json(path)
        game["stage"] = stage
        game["approvals"]["spec"] = self.approval()
        if stage in {"DEV-COMPLETE", "PLAYTESTED", "RELEASE-READY", "LIVE", "WINNER"}:
            game["completion"] = {
                "at": "2026-10-15", "revision": "a" * 40,
                "evidence": "Unit-test fixture only", "core_loop": "Fixture loop checked",
                "checks": {"formatter": "PASS", "lint": "PASS", "logic": "PASS", "build": "PASS"},
            }
        if stage in {"PLAYTESTED", "RELEASE-READY", "LIVE", "WINNER"}:
            game["approvals"]["playtest"] = self.approval()
        if stage in {"RELEASE-READY", "LIVE", "WINNER"}:
            game["approvals"]["publish"] = self.approval()
            game["places"] = {"test": 10, "live": 20}
            project_path = path.parent / "default.project.json"
            project = factory.read_json(project_path)
            project["servePlaceIds"] = [10]
            factory.write_json(project_path, project)
        factory.write_json(path, game)
        state = factory.read_json(self.root / "factory-state/state.json")
        state["active_game"] = game_id if stage in factory.PREPARATION else None
        factory.write_json(self.root / "factory-state/state.json", state)
        return path, game

    @staticmethod
    def approval():
        return {"by": "Snow", "at": "2026-10-15", "evidence": "Unit-test fixture only"}

    def test_empty_factory_is_valid(self):
        state, queue, games = factory.validate(self.root)
        self.assertIsNone(state["active_game"])
        self.assertEqual(queue["ideas"], [])
        self.assertEqual(games, [])

    def test_cannot_create_from_an_empty_queue(self):
        with self.assertRaisesRegex(ValueError, "unassigned idea"):
            factory.new_game(self.root, "idea-001")
        self.assertFalse((self.root / "games/game-001").exists())

    def test_scaffold_preserves_quoted_name_and_pending_gates(self):
        game_id = self.new('Snow "test" \\ name')
        state, queue, games = factory.validate(self.root)
        self.assertEqual(game_id, "game-001")
        self.assertEqual(state["active_game"], game_id)
        self.assertEqual(queue["ideas"][0]["game_id"], game_id)
        self.assertEqual(games[0]["name"], 'Snow "test" \\ name')
        self.assertEqual(games[0]["stage"], "SPEC-PENDING")
        self.assertTrue(all(value is None for value in games[0]["approvals"].values()))
        project = factory.read_json(self.root / "games" / game_id / "default.project.json")
        self.assertEqual(project["name"], games[0]["name"])
        self.assertIn("Snow's approval", (self.root / "factory-state/checkpoint.md").read_text(encoding="utf-8"))

    def test_active_game_blocks_another_scaffold(self):
        self.new()
        idea_id = factory.add_idea(self.root, "Second", "Fixture", "Fixture source")
        with self.assertRaisesRegex(ValueError, "active game"):
            factory.new_game(self.root, idea_id)

    def test_cannot_skip_the_next_queued_idea(self):
        factory.add_idea(self.root, "First", "Fixture", "Fixture source")
        second = factory.add_idea(self.root, "Second", "Fixture", "Fixture source")
        with self.assertRaisesRegex(ValueError, "next idea"):
            factory.new_game(self.root, second)

    def test_binary_assets_are_preserved_when_scaffolding(self):
        payload = b"\x89PNG\r\n\x1a\n\xff\x00"
        asset = self.root / "game-templates/basic-round/assets/fixture.png"
        asset.write_bytes(payload)
        game_id = self.new()
        self.assertEqual((self.root / "games" / game_id / "assets/fixture.png").read_bytes(), payload)

    def test_failed_scaffold_rolls_back_files_and_queue(self):
        idea_id = factory.add_idea(self.root, "Fixture", "Fixture", "Fixture source")
        before = {path.name: path.read_bytes() for path in (self.root / "factory-state").iterdir() if path.is_file()}
        initial = factory.validate(self.root)
        with mock.patch.object(factory, "validate", side_effect=[initial, ValueError("Fixture postvalidation failure")]):
            with self.assertRaisesRegex(ValueError, "postvalidation failure"):
                factory.new_game(self.root, idea_id)
        self.assertFalse((self.root / "games/game-001").exists())
        after = {path.name: path.read_bytes() for path in (self.root / "factory-state").iterdir() if path.is_file()}
        self.assertEqual(before, after)
        factory.validate(self.root)

    def test_two_waiting_games_block_new_work(self):
        self.set_stage(self.new(), "DEV-COMPLETE")
        self.set_stage(self.new(), "DEV-COMPLETE")
        idea_id = factory.add_idea(self.root, "Third", "Fixture", "Fixture source")
        with self.assertRaisesRegex(ValueError, "await Snow's playtest"):
            factory.new_game(self.root, idea_id)

    def test_playtest_frees_a_waiting_slot(self):
        first = self.new()
        self.set_stage(first, "DEV-COMPLETE")
        self.set_stage(self.new(), "DEV-COMPLETE")
        self.set_stage(first, "PLAYTESTED")
        self.assertEqual(self.new(), "game-003")

    def test_winner_blocks_new_games(self):
        self.set_stage(self.new(), "WINNER")
        idea_id = factory.add_idea(self.root, "Later", "Fixture", "Fixture source")
        with self.assertRaisesRegex(ValueError, "WINNER"):
            factory.new_game(self.root, idea_id)

    def test_building_requires_snow_spec_evidence(self):
        game_id = self.new()
        path, game = self.set_stage(game_id, "BUILDING")
        game["approvals"]["spec"] = None
        factory.write_json(path, game)
        with self.assertRaisesRegex(ValueError, "spec approval required"):
            factory.validate(self.root)

    def test_agent_cannot_be_named_as_approver(self):
        game_id = self.new()
        path, game = self.set_stage(game_id, "BUILDING")
        game["approvals"]["spec"]["by"] = "agent"
        factory.write_json(path, game)
        with self.assertRaisesRegex(ValueError, "invalid spec evidence"):
            factory.validate(self.root)

    def test_impossible_dates_and_placeholder_evidence_are_rejected(self):
        approval = self.approval()
        approval["at"] = "2026-99-99"
        self.assertFalse(factory.approval_valid(approval))
        approval = self.approval()
        approval["evidence"] = "PENDING"
        self.assertFalse(factory.approval_valid(approval))

    def test_dev_complete_requires_completion_and_check_evidence(self):
        path, game = self.set_stage(self.new(), "DEV-COMPLETE")
        game["completion"] = None
        factory.write_json(path, game)
        with self.assertRaisesRegex(ValueError, "completion and passing-check evidence"):
            factory.validate(self.root)

    def test_playtested_requires_playtest_evidence(self):
        path, game = self.set_stage(self.new(), "PLAYTESTED")
        game["approvals"]["playtest"] = None
        factory.write_json(path, game)
        with self.assertRaisesRegex(ValueError, "playtest evidence required"):
            factory.validate(self.root)

    def test_release_requires_distinct_places_and_publish_approval(self):
        path, game = self.set_stage(self.new(), "RELEASE-READY")
        game["approvals"]["publish"] = None
        factory.write_json(path, game)
        with self.assertRaisesRegex(ValueError, "publish approval required"):
            factory.validate(self.root)
        game["approvals"]["publish"] = self.approval()
        game["places"]["live"] = game["places"]["test"]
        factory.write_json(path, game)
        with self.assertRaisesRegex(ValueError, "places must differ"):
            factory.validate(self.root)

    def test_release_cannot_sync_to_live_place(self):
        path, game = self.set_stage(self.new(), "RELEASE-READY")
        project = factory.read_json(path.parent / "default.project.json")
        project["servePlaceIds"] = [game["places"]["live"]]
        factory.write_json(path.parent / "default.project.json", project)
        with self.assertRaisesRegex(ValueError, "test place"):
            factory.validate(self.root)

    def test_dead_requires_exact_reason(self):
        path, game = self.set_stage(self.new(), "DEAD")
        with self.assertRaisesRegex(ValueError, "DEAD classification"):
            factory.validate(self.root)
        game["dead_reason"] = "NOT FUN"
        factory.write_json(path, game)
        factory.validate(self.root)

    def test_unregistered_game_directory_is_rejected(self):
        (self.root / "games/game-999").mkdir()
        with self.assertRaisesRegex(ValueError, "registry differ"):
            factory.validate(self.root)

    def test_missing_game_document_is_rejected(self):
        game_id = self.new()
        (self.root / "games" / game_id / "spec.md").unlink()
        with self.assertRaisesRegex(ValueError, "missing spec.md"):
            factory.validate(self.root)

    def test_shared_dependency_needs_a_pin_and_digest(self):
        game_id = self.new()
        lock = self.root / "games" / game_id / "shared-systems.lock.json"
        factory.write_json(lock, {"schema_version": 1, "systems": [{"name": "test", "version": "main"}]})
        with self.assertRaisesRegex(ValueError, "unpinned shared system"):
            factory.validate(self.root)


if __name__ == "__main__":
    unittest.main()
