from pocketbase import PocketBase
from pocketbase.client import ClientResponseError
import os
from typing import Optional, List, Dict

class PocketBaseClient:
    def __init__(self):
        self.url = os.getenv("POCKETBASE_URL")
        self.client = PocketBase(self.url)
        
    async def create_user(self, email: str, password: str, username: str, country: str, level: str) -> Dict:
        """Create new user in PocketBase"""
        try:
            user_data = {
                "email": email,
                "password": password,
                "passwordConfirm": password,
                "username": username,
                "country": country,
                "level": level,
                "points": 0,
                "streak_days": 0,
                "quran_progress": 0.0,
                "prayers_logged": 0,
                "lessons_completed": 0,
            }
            record = self.client.collection('users').create(user_data)
            return record.__dict__
        except ClientResponseError as e:
            raise Exception(f"Failed to create user: {e.data}")
    
    async def authenticate_user(self, email: str, password: str) -> Optional[Dict]:
        """Authenticate user with PocketBase"""
        try:
            auth_data = self.client.collection('users').auth_with_password(email, password)
            return auth_data.record.__dict__
        except ClientResponseError:
            return None
    
    async def get_user(self, user_id: str) -> Optional[Dict]:
        """Get user by ID"""
        try:
            record = self.client.collection('users').get_one(user_id)
            return record.__dict__
        except ClientResponseError:
            return None
    
    async def update_user(self, user_id: str, data: Dict) -> Dict:
        """Update user data"""
        try:
            record = self.client.collection('users').update(user_id, data)
            return record.__dict__
        except ClientResponseError as e:
            raise Exception(f"Failed to update user: {e.data}")
    
    async def log_activity(self, user_id: str, activity_type: str, points: int, metadata: Optional[Dict] = None) -> Dict:
        """Log user activity and update points"""
        try:
            # Create activity log
            activity_data = {
                "user_id": user_id,
                "activity_type": activity_type,
                "points": points,
                "metadata": metadata or {},
            }
            self.client.collection('activities').create(activity_data)
            
            # Update user points
            user = await self.get_user(user_id)
            new_points = user.get('points', 0) + points
            
            # Update specific counters
            update_data = {"points": new_points}
            if activity_type == "quran_read":
                update_data["quran_progress"] = user.get('quran_progress', 0) + 1
            elif activity_type == "prayer_logged":
                update_data["prayers_logged"] = user.get('prayers_logged', 0) + 1
            elif activity_type == "lesson_completed":
                update_data["lessons_completed"] = user.get('lessons_completed', 0) + 1
            
            return await self.update_user(user_id, update_data)
        except Exception as e:
            raise Exception(f"Failed to log activity: {str(e)}")
    
    async def get_leaderboard(self, limit: int = 100, country: Optional[str] = None) -> List[Dict]:
        """Get leaderboard rankings"""
        try:
            filter_query = f'country="{country}"' if country else ''
            records = self.client.collection('users').get_list(
                1, limit,
                {
                    'sort': '-points',
                    'filter': filter_query,
                    'fields': 'id,username,country,points,avatar'
                }
            )
            
            leaderboard = []
            for rank, record in enumerate(records.items, start=1):
                entry = record.__dict__
                entry['rank'] = rank
                leaderboard.append(entry)
            
            return leaderboard
        except ClientResponseError as e:
            raise Exception(f"Failed to get leaderboard: {e.data}")
    
    async def get_user_rank(self, user_id: str) -> Dict:
        """Get user's rank in leaderboard"""
        try:
            user = await self.get_user(user_id)
            if not user:
                raise Exception("User not found")
            
            # Get all users with higher points
            records = self.client.collection('users').get_list(
                1, 10000,
                {
                    'filter': f'points>{user["points"]}',
                    'fields': 'id'
                }
            )
            
            rank = len(records.items) + 1
            return {
                "rank": rank,
                "points": user["points"],
                "username": user["username"]
            }
        except Exception as e:
            raise Exception(f"Failed to get user rank: {str(e)}")

# Singleton instance
pb_client = PocketBaseClient()
