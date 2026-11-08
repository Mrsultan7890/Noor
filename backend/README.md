# Noor API Backend

FastAPI backend for Noor, with account and activity data stored in Turso.

## Local setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Set `TURSO_DATABASE_URL` and `TURSO_AUTH_TOKEN` in `.env`. Get both from your
Turso database dashboard or Turso CLI. Keep the auth token private.

Run the API:

```bash
uvicorn main:app --reload
```

The API is available at `http://localhost:8000`; OpenAPI docs are at
`http://localhost:8000/docs`. The backend creates its `users` and `activities`
tables automatically at startup.

For uptime monitoring, use `GET /healthz` (or the existing `GET /health`).
Both return HTTP 200 with `{"status":"healthy","database":"turso"}` while the
API is responding.

## Render deployment

The Render blueprint is in `render.yaml`. Create a web service using the
repository and configure these secret environment variables in Render:

- `TURSO_DATABASE_URL`
- `TURSO_AUTH_TOKEN`
- `SECRET_KEY` (use a long, random value)

The blueprint sets the Python version, install/start commands, and non-secret
JWT settings. Access tokens last 30 days by default; keep `DEBUG` set to
`False` in production.

## API

- `POST /auth/register` - create an account
- `POST /auth/login` - sign in
- `GET /users/me` - get the signed-in user's profile
- `PUT /users/me` - update the profile
- `POST /users/activity` - record activity and points
- `GET /users/rank` - get the user's leaderboard rank
- `GET /leaderboard/global` - global leaderboard
- `GET /leaderboard/country/{country}` - country leaderboard

Passwords are hashed before they are stored. Use a valid email address and
keep your account credentials private.

Activity rewards are assigned by the server, not by the points value sent by
the app. Repeated prayers and Quran surahs are rewarded once per local day;
lessons, duas, and game levels are rewarded once per item. Activity submissions
are idempotent, update the user's streak, and refresh the profile response.

Run backend tests from this directory:

```bash
python -m unittest discover -s tests -v
```
