import tempfile
import unittest
from pathlib import Path

from utils.turso_storage import TursoStorage


class TursoStorageTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.database_path = str(Path(self.temp_dir.name) / "noor.db")
        self.storage = TursoStorage(database_url=self.database_path)
        await self.storage.initialize()

    async def asyncTearDown(self):
        self.temp_dir.cleanup()

    async def test_accounts_persist_and_passwords_are_verified(self):
        user = await self.storage.create_user(
            email="person@example.com",
            password="secure-pass-123",
            username="NoorUser",
            country="Pakistan",
            level="Beginner",
        )

        reopened_storage = TursoStorage(database_url=self.database_path)
        authenticated_user = await reopened_storage.authenticate_user(
            "PERSON@example.com", "secure-pass-123"
        )

        self.assertEqual(authenticated_user["id"], user["id"])
        self.assertIsNone(
            await reopened_storage.authenticate_user(
                "person@example.com", "wrong-password"
            )
        )

    async def test_profile_activity_and_leaderboard_are_persisted(self):
        user = await self.storage.create_user(
            email="person@example.com",
            password="secure-pass-123",
            username="NoorUser",
            country="Pakistan",
            level="Beginner",
        )

        updated_user = await self.storage.log_activity(
            user["id"], "prayer_logged", 5, {"prayer": "Fajr"}
        )
        updated_user = await self.storage.update_user(
            user["id"], {"username": "UpdatedUser"}
        )
        leaderboard = await self.storage.get_leaderboard(country="Pakistan")
        rank = await self.storage.get_user_rank(user["id"])

        self.assertEqual(updated_user["prayers_logged"], 1)
        self.assertEqual(updated_user["points"], 5)
        self.assertEqual(leaderboard[0]["user_id"], user["id"])
        self.assertEqual(rank["rank"], 1)

    async def test_duplicate_email_is_rejected_case_insensitively(self):
        await self.storage.create_user(
            email="person@example.com",
            password="secure-pass-123",
            username="NoorUser",
            country="Pakistan",
            level="Beginner",
        )

        with self.assertRaisesRegex(ValueError, "already exists"):
            await self.storage.create_user(
                email="PERSON@example.com",
                password="another-pass-123",
                username="AnotherUser",
                country="Pakistan",
                level="Beginner",
            )


if __name__ == "__main__":
    unittest.main()
