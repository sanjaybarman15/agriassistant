import os
from dotenv import load_dotenv

# Load AgriAssistant Env FIRST
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.endpoints import recommendations, advisory

app = FastAPI(
    title="AgriAssistant AI Backend",
    description="Precision Agriculture Advisory System for Assam",
    version="1.0.0"
)

# CORS Setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(recommendations.router, prefix="/api/v1")
app.include_router(advisory.router, prefix="/api/v1")

@app.get("/")
async def root():
    return {
        "status": "online",
        "service": "AgriAssistant API",
        "region": "Assam, India"
    }

# We will include routers here
# app.include_router(recommendations.router, prefix="/api/v1")