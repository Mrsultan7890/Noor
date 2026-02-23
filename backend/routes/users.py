from fastapi import APIRouter, HTTPException, status, Depends
from models.schemas import UserProfile, UserUpdate, ActivityLog
from routes.auth import get_current_user
from utils.pocketbase_client import pb_client

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserProfile)
async def get_my_profile(current_user: dict = Depends(get_current_user)):
    """Get current user's profile"""
    return UserProfile(
        id=current_user["id"],
        email=current_user["email"],
        username=current_user["username"],
        country=current_user["country"],
        level=current_user["level"],
        points=current_user.get("points", 0),
        streak_days=current_user.get("streak_days", 0),
        quran_progress=current_user.get("quran_progress", 0.0),
        prayers_logged=current_user.get("prayers_logged", 0),
        lessons_completed=current_user.get("lessons_completed", 0),
        avatar=current_user.get("avatar"),
        created_at=current_user["created"],
        updated_at=current_user["updated"]
    )

@router.put("/me", response_model=UserProfile)
async def update_my_profile(
    update_data: UserUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Update current user's profile"""
    try:
        # Filter out None values
        data_to_update = {k: v for k, v in update_data.dict().items() if v is not None}
        
        if not data_to_update:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No data to update"
            )
        
        updated_user = await pb_client.update_user(current_user["id"], data_to_update)
        
        return UserProfile(
            id=updated_user["id"],
            email=updated_user["email"],
            username=updated_user["username"],
            country=updated_user["country"],
            level=updated_user["level"],
            points=updated_user.get("points", 0),
            streak_days=updated_user.get("streak_days", 0),
            quran_progress=updated_user.get("quran_progress", 0.0),
            prayers_logged=updated_user.get("prayers_logged", 0),
            lessons_completed=updated_user.get("lessons_completed", 0),
            avatar=updated_user.get("avatar"),
            created_at=updated_user["created"],
            updated_at=updated_user["updated"]
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.post("/activity", status_code=status.HTTP_201_CREATED)
async def log_activity(
    activity: ActivityLog,
    current_user: dict = Depends(get_current_user)
):
    """
    Log user activity and earn points
    
    Activity Types & Points:
    - quran_read: 10 points per surah
    - prayer_logged: 5 points per prayer
    - lesson_completed: 20 points per lesson
    - dua_memorized: 15 points per dua
    """
    try:
        # Verify user_id matches current user
        if activity.user_id != current_user["id"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot log activity for another user"
            )
        
        updated_user = await pb_client.log_activity(
            user_id=activity.user_id,
            activity_type=activity.activity_type,
            points=activity.points,
            metadata=activity.metadata
        )
        
        return {
            "message": "Activity logged successfully",
            "points_earned": activity.points,
            "total_points": updated_user["points"]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.get("/rank")
async def get_my_rank(current_user: dict = Depends(get_current_user)):
    """Get current user's rank in global leaderboard"""
    try:
        rank_data = await pb_client.get_user_rank(current_user["id"])
        return rank_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
