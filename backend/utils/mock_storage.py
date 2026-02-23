from typing import Optional, List, Dict
import uuid
from datetime import datetime

class MockStorage:
    def __init__(self):
        self.users = {}
        self.activities = []
    
    async def create_user(self, email: str, password: str, username: str, country: str, level: str) -> Dict:
        if email in [u['email'] for u in self.users.values()]:
            raise Exception("Email already exists")
        
        user_id = str(uuid.uuid4())
        user = {
            "id": user_id,
            "email": email,
            "password": password,
            "username": username,
            "country": country,
            "level": level,
            "points": 0,
            "streak_days": 0,
            "quran_progress": 0.0,
            "prayers_logged": 0,
            "lessons_completed": 0,
            "avatar": "",
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat(),
        }
        self.users[user_id] = user
        return user
    
    async def authenticate_user(self, email: str, password: str) -> Optional[Dict]:
        for user in self.users.values():
            if user['email'] == email and user['password'] == password:
                return user
        return None
    
    async def get_user(self, user_id: str) -> Optional[Dict]:
        return self.users.get(user_id)
    
    async def update_user(self, user_id: str, data: Dict) -> Dict:
        if user_id not in self.users:
            raise Exception("User not found")
        
        self.users[user_id].update(data)
        self.users[user_id]['updated'] = datetime.now().isoformat()
        return self.users[user_id]
    
    async def log_activity(self, user_id: str, activity_type: str, points: int, metadata: Optional[Dict] = None) -> Dict:
        activity = {
            "id": str(uuid.uuid4()),
            "user_id": user_id,
            "activity_type": activity_type,
            "points": points,
            "metadata": metadata or {},
            "created": datetime.now().isoformat(),
        }
        self.activities.append(activity)
        
        user = self.users.get(user_id)
        if user:
            user['points'] += points
            
            if activity_type == "quran_read":
                user['quran_progress'] = min(100, user['quran_progress'] + 0.88)
            elif activity_type == "prayer_logged":
                user['prayers_logged'] += 1
            elif activity_type == "lesson_completed":
                user['lessons_completed'] += 1
            
            user['updated'] = datetime.now().isoformat()
        
        return user
    
    async def get_leaderboard(self, limit: int = 100, country: Optional[str] = None) -> List[Dict]:
        users = list(self.users.values())
        
        if country:
            users = [u for u in users if u['country'] == country]
        
        users.sort(key=lambda x: x['points'], reverse=True)
        
        leaderboard = []
        for rank, user in enumerate(users[:limit], start=1):
            leaderboard.append({
                "rank": rank,
                "user_id": user['id'],
                "username": user['username'],
                "country": user['country'],
                "points": user['points'],
                "avatar": user.get('avatar', ''),
            })
        
        return leaderboard
    
    async def get_user_rank(self, user_id: str) -> Dict:
        user = self.users.get(user_id)
        if not user:
            raise Exception("User not found")
        
        users = sorted(self.users.values(), key=lambda x: x['points'], reverse=True)
        rank = next((i + 1 for i, u in enumerate(users) if u['id'] == user_id), 0)
        
        return {
            "rank": rank,
            "points": user['points'],
            "username": user['username'],
        }

mock_storage = MockStorage()
