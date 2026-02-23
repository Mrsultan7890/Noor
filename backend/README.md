# Noor API Backend

🌙 Privacy-first backend for Noor Islamic Companion App

## Features

- ✅ Anonymous authentication (fake emails allowed)
- ✅ User profiles with progress tracking
- ✅ Global & country leaderboards
- ✅ Activity logging with points system
- ✅ PocketBase integration
- ✅ JWT authentication
- ✅ FastAPI with auto-generated docs

## Tech Stack

- **Framework**: FastAPI
- **Database**: PocketBase (HuggingFace hosted)
- **Deployment**: Render
- **Auth**: JWT tokens
- **Language**: Python 3.11+

## Setup

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your PocketBase URL and credentials
```

### 3. Run Locally

```bash
python main.py
# or
uvicorn main:app --reload
```

API will be available at: http://localhost:8000

## API Documentation

Once running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user

### Users
- `GET /users/me` - Get current user profile
- `PUT /users/me` - Update profile
- `POST /users/activity` - Log activity & earn points
- `GET /users/rank` - Get user's rank

### Leaderboard
- `GET /leaderboard/global` - Global rankings
- `GET /leaderboard/country/{country}` - Country rankings

## Points System

| Activity | Points |
|----------|--------|
| Quran reading (per surah) | 10 |
| Prayer logged | 5 |
| Lesson completed | 20 |
| Dua memorized | 15 |

## PocketBase Collections

### users
```json
{
  "email": "string",
  "password": "string",
  "username": "string",
  "country": "string",
  "level": "string",
  "points": "number",
  "streak_days": "number",
  "quran_progress": "number",
  "prayers_logged": "number",
  "lessons_completed": "number",
  "avatar": "string"
}
```

### activities
```json
{
  "user_id": "relation",
  "activity_type": "string",
  "points": "number",
  "metadata": "json"
}
```

## Deployment to Render

1. Push code to GitHub
2. Connect Render to your repo
3. Add environment variables in Render dashboard
4. Deploy!

## Privacy Notice

⚠️ **Important**: This API is designed for privacy-first approach:
- Users can use fake emails (e.g., user123@temp.com)
- No email verification required
- No personal data collection
- Anonymous profiles only

## License

MIT License
