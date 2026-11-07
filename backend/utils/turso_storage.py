import asyncio
import json
import os
import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

import libsql

from utils.auth import get_password_hash, verify_password


USER_COLUMNS = """
    id, email, username, country, level, points, streak_days,
    quran_progress, prayers_logged, lessons_completed, avatar,
    created, updated
"""


class TursoStorage:
    def __init__(
        self,
        database_url: Optional[str] = None,
        auth_token: Optional[str] = None,
    ):
        self.database_url = database_url
        self.auth_token = auth_token

    def _connect(self):
        database_url = self.database_url or os.getenv("TURSO_DATABASE_URL")
        auth_token = self.auth_token or os.getenv("TURSO_AUTH_TOKEN")
        if not database_url:
            raise RuntimeError("TURSO_DATABASE_URL is not configured.")
        if database_url.startswith("libsql://") and not auth_token:
            raise RuntimeError(
                "TURSO_AUTH_TOKEN is required for a remote Turso database."
            )
        if auth_token:
            return libsql.connect(database=database_url, auth_token=auth_token)
        return libsql.connect(database=database_url)

    async def _run(self, operation, *args):
        return await asyncio.to_thread(operation, *args)

    async def initialize(self) -> None:
        await self._run(self._initialize)

    def _initialize(self) -> None:
        connection = self._connect()
        try:
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS users (
                    id TEXT PRIMARY KEY,
                    email TEXT NOT NULL COLLATE NOCASE UNIQUE,
                    password_hash TEXT NOT NULL,
                    username TEXT NOT NULL,
                    country TEXT NOT NULL,
                    level TEXT NOT NULL,
                    points INTEGER NOT NULL DEFAULT 0,
                    streak_days INTEGER NOT NULL DEFAULT 0,
                    quran_progress REAL NOT NULL DEFAULT 0,
                    prayers_logged INTEGER NOT NULL DEFAULT 0,
                    lessons_completed INTEGER NOT NULL DEFAULT 0,
                    avatar TEXT,
                    created TEXT NOT NULL,
                    updated TEXT NOT NULL
                )
                """
            )
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS activities (
                    id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    activity_type TEXT NOT NULL,
                    points INTEGER NOT NULL,
                    metadata TEXT NOT NULL DEFAULT '{}',
                    created TEXT NOT NULL
                )
                """
            )
            connection.execute(
                "CREATE INDEX IF NOT EXISTS users_points_idx ON users(points DESC)"
            )
            connection.execute(
                "CREATE INDEX IF NOT EXISTS users_country_points_idx "
                "ON users(country, points DESC)"
            )
            connection.commit()
        finally:
            connection.close()

    @staticmethod
    def _row_dict(cursor, row) -> Optional[Dict[str, Any]]:
        if row is None:
            return None
        return dict(zip((column[0] for column in cursor.description), row))

    @classmethod
    def _get_user(cls, connection, user_id: str) -> Optional[Dict[str, Any]]:
        cursor = connection.execute(
            f"SELECT {USER_COLUMNS} FROM users WHERE id = ?", (user_id,)
        )
        return cls._row_dict(cursor, cursor.fetchone())

    async def create_user(
        self,
        email: str,
        password: str,
        username: str,
        country: str,
        level: str,
    ) -> Dict[str, Any]:
        return await self._run(
            self._create_user, email, password, username, country, level
        )

    def _create_user(
        self, email: str, password: str, username: str, country: str, level: str
    ) -> Dict[str, Any]:
        user_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()
        password_hash = get_password_hash(password)
        connection = self._connect()
        try:
            connection.execute(
                """
                INSERT INTO users (
                    id, email, password_hash, username, country, level, created, updated
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (user_id, email, password_hash, username, country, level, now, now),
            )
            connection.commit()
            return self._get_user(connection, user_id)
        except Exception as error:
            connection.rollback()
            if "UNIQUE constraint failed: users.email" in str(error):
                raise ValueError("An account with this email already exists.") from error
            raise
        finally:
            connection.close()

    async def authenticate_user(
        self, email: str, password: str
    ) -> Optional[Dict[str, Any]]:
        return await self._run(self._authenticate_user, email, password)

    def _authenticate_user(
        self, email: str, password: str
    ) -> Optional[Dict[str, Any]]:
        connection = self._connect()
        try:
            cursor = connection.execute(
                "SELECT password_hash FROM users WHERE email = ? COLLATE NOCASE",
                (email,),
            )
            row = cursor.fetchone()
            if row is None or not verify_password(password, row[0]):
                return None
            cursor = connection.execute(
                f"SELECT {USER_COLUMNS} FROM users WHERE email = ? COLLATE NOCASE",
                (email,),
            )
            return self._row_dict(cursor, cursor.fetchone())
        finally:
            connection.close()

    async def get_user(self, user_id: str) -> Optional[Dict[str, Any]]:
        return await self._run(self._get_user_by_id, user_id)

    def _get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        connection = self._connect()
        try:
            return self._get_user(connection, user_id)
        finally:
            connection.close()

    async def update_user(self, user_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        return await self._run(self._update_user, user_id, data)

    def _update_user(self, user_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        allowed_columns = {"username", "country", "level", "avatar"}
        updates = {key: value for key, value in data.items() if key in allowed_columns}
        if not updates:
            user = self._get_user_by_id(user_id)
            if user is None:
                raise ValueError("User not found.")
            return user

        updates["updated"] = datetime.now(timezone.utc).isoformat()
        assignments = ", ".join(f"{column} = ?" for column in updates)
        connection = self._connect()
        try:
            cursor = connection.execute(
                f"UPDATE users SET {assignments} WHERE id = ?",
                (*updates.values(), user_id),
            )
            if cursor.rowcount == 0:
                raise ValueError("User not found.")
            connection.commit()
            return self._get_user(connection, user_id)
        finally:
            connection.close()

    async def log_activity(
        self,
        user_id: str,
        activity_type: str,
        points: int,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        return await self._run(
            self._log_activity, user_id, activity_type, points, metadata
        )

    def _log_activity(
        self,
        user_id: str,
        activity_type: str,
        points: int,
        metadata: Optional[Dict[str, Any]],
    ) -> Dict[str, Any]:
        connection = self._connect()
        try:
            user = self._get_user(connection, user_id)
            if user is None:
                raise ValueError("User not found.")

            now = datetime.now(timezone.utc).isoformat()
            connection.execute(
                """
                INSERT INTO activities (
                    id, user_id, activity_type, points, metadata, created
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    str(uuid.uuid4()),
                    user_id,
                    activity_type,
                    points,
                    json.dumps(metadata or {}),
                    now,
                ),
            )
            updates: Dict[str, Any] = {"points": user["points"] + points}
            if activity_type == "quran_read":
                updates["quran_progress"] = min(100, user["quran_progress"] + 0.88)
            elif activity_type == "prayer_logged":
                updates["prayers_logged"] = user["prayers_logged"] + 1
            elif activity_type == "lesson_completed":
                updates["lessons_completed"] = user["lessons_completed"] + 1
            updates["updated"] = now

            assignments = ", ".join(f"{column} = ?" for column in updates)
            connection.execute(
                f"UPDATE users SET {assignments} WHERE id = ?",
                (*updates.values(), user_id),
            )
            connection.commit()
            return self._get_user(connection, user_id)
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    async def get_leaderboard(
        self, limit: int = 100, country: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        return await self._run(self._get_leaderboard, limit, country)

    def _get_leaderboard(
        self, limit: int, country: Optional[str]
    ) -> List[Dict[str, Any]]:
        connection = self._connect()
        try:
            if country:
                cursor = connection.execute(
                    """
                    SELECT id AS user_id, username, country, points, avatar
                    FROM users WHERE country = ?
                    ORDER BY points DESC, username COLLATE NOCASE
                    LIMIT ?
                    """,
                    (country, limit),
                )
            else:
                cursor = connection.execute(
                    """
                    SELECT id AS user_id, username, country, points, avatar
                    FROM users
                    ORDER BY points DESC, username COLLATE NOCASE
                    LIMIT ?
                    """,
                    (limit,),
                )
            rows = cursor.fetchall()
            columns = [column[0] for column in cursor.description]
            return [
                {**dict(zip(columns, row)), "rank": rank}
                for rank, row in enumerate(rows, start=1)
            ]
        finally:
            connection.close()

    async def get_user_rank(self, user_id: str) -> Dict[str, Any]:
        return await self._run(self._get_user_rank, user_id)

    def _get_user_rank(self, user_id: str) -> Dict[str, Any]:
        connection = self._connect()
        try:
            user = self._get_user(connection, user_id)
            if user is None:
                raise ValueError("User not found.")
            cursor = connection.execute(
                "SELECT COUNT(*) FROM users WHERE points > ?", (user["points"],)
            )
            rank = cursor.fetchone()[0] + 1
            return {
                "rank": rank,
                "points": user["points"],
                "username": user["username"],
            }
        finally:
            connection.close()


turso_storage = TursoStorage()
