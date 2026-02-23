from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Import routes
from routes import auth, users, leaderboard

# Create FastAPI app
app = FastAPI(
    title="Noor API",
    description="""
    🌙 Noor - Islamic Companion App Backend
    
    ## Privacy First Approach
    
    We prioritize user privacy:
    - ✅ Use any fake email (no verification required)
    - ✅ No personal data collection
    - ✅ Anonymous profiles
    - ✅ GDPR compliant by default
    
    ## Features
    
    - **Authentication**: Simple email/password (no verification)
    - **User Profiles**: Track progress and stats
    - **Leaderboard**: Global and country rankings
    - **Activity Logging**: Earn points for Islamic activities
    
    ## Points System
    
    - Quran reading: 10 points/surah
    - Daily prayers: 5 points/prayer
    - Lessons completed: 20 points/lesson
    - Dua memorized: 15 points/dua
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(leaderboard.router)

@app.get("/")
async def root():
    """API root endpoint"""
    return {
        "message": "Noor API - Islamic Companion App",
        "version": "1.0.0",
        "docs": "/docs",
        "privacy": "We don't collect personal data. Use fake emails!",
        "status": "operational"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "pocketbase_url": os.getenv("POCKETBASE_URL", "not_configured")
    }

# Error handlers
@app.exception_handler(404)
async def not_found_handler(request, exc):
    return JSONResponse(
        status_code=404,
        content={"detail": "Endpoint not found"}
    )

@app.exception_handler(500)
async def internal_error_handler(request, exc):
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"}
    )

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",  # All network interfaces for WiFi access
        port=port,
        reload=os.getenv("DEBUG", "False") == "True"
    )
