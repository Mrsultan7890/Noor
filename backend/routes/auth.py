from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from models.schemas import UserRegister, UserLogin, Token, UserProfile
from utils.auth import get_password_hash, create_access_token, decode_token
from utils.pocketbase_client import pb_client
from datetime import timedelta

router = APIRouter(prefix="/auth", tags=["Authentication"])
security = HTTPBearer()

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegister):
    """
    Register new user with anonymous email
    
    Privacy Notice: Use any fake email (e.g., user123@temp.com)
    We don't verify emails or collect personal data!
    """
    try:
        # Create user in PocketBase
        user = await pb_client.create_user(
            email=user_data.email,
            password=user_data.password,
            username=user_data.username,
            country=user_data.country,
            level=user_data.level
        )
        
        # Create access token
        access_token = create_access_token(
            data={"sub": user["id"], "email": user["email"]}
        )
        
        # Return token and user profile
        user_profile = UserProfile(
            id=user["id"],
            email=user["email"],
            username=user["username"],
            country=user["country"],
            level=user["level"],
            points=user.get("points", 0),
            streak_days=user.get("streak_days", 0),
            quran_progress=user.get("quran_progress", 0.0),
            prayers_logged=user.get("prayers_logged", 0),
            lessons_completed=user.get("lessons_completed", 0),
            avatar=user.get("avatar"),
            created_at=user["created"],
            updated_at=user["updated"]
        )
        
        return Token(access_token=access_token, user=user_profile)
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/login", response_model=Token)
async def login(credentials: UserLogin):
    """
    Login with email and password
    
    Remember: Use the same fake email you registered with!
    """
    try:
        # Authenticate with PocketBase
        user = await pb_client.authenticate_user(
            email=credentials.email,
            password=credentials.password
        )
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Create access token
        access_token = create_access_token(
            data={"sub": user["id"], "email": user["email"]}
        )
        
        # Return token and user profile
        user_profile = UserProfile(
            id=user["id"],
            email=user["email"],
            username=user["username"],
            country=user["country"],
            level=user["level"],
            points=user.get("points", 0),
            streak_days=user.get("streak_days", 0),
            quran_progress=user.get("quran_progress", 0.0),
            prayers_logged=user.get("prayers_logged", 0),
            lessons_completed=user.get("lessons_completed", 0),
            avatar=user.get("avatar"),
            created_at=user["created"],
            updated_at=user["updated"]
        )
        
        return Token(access_token=access_token, user=user_profile)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Dependency to get current authenticated user"""
    token = credentials.credentials
    payload = decode_token(token)
    user_id = payload.get("sub")
    
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials"
        )
    
    user = await pb_client.get_user(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return user
