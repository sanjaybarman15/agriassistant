# backend/main.py

import os
import logging
from contextlib import asynccontextmanager
from dotenv import load_dotenv

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from app.config.settings import settings
from app.api import chat, sessions, rag, stt, hr, tts

# ---------------------------
# ENV & LOGGING
# ---------------------------
load_dotenv(override=True)
logger = logging.getLogger("uvicorn")

def is_production() -> bool:
    return not settings.DEBUG

# ---------------------------
# STARTUP VALIDATION
# ---------------------------
async def startup_validation():
    required_envs = [
        "SUPABASE_URL",
        "SUPABASE_SERVICE_ROLE_KEY",
        "NVIDIA_API_KEY",
        "DEFAULT_CHAT_MODEL"
    ]

    missing = [env for env in required_envs if not getattr(settings, env, None)]
    if missing:
        logger.error(f"❌ CRITICAL: Missing environment variables: {missing}")
        raise RuntimeError(f"Missing environment variables: {missing}")

    logger.info("===================================")
    logger.info(f"🚀 {settings.APP_NAME} Backend Starting")
    logger.info(f"Environment : {'Production' if is_production() else 'Development'}")
    logger.info(f"Debug Mode  : {settings.DEBUG}")
    logger.info(f"AI Model    : {settings.DEFAULT_CHAT_MODEL}")
    logger.info(f"Supabase    : {settings.SUPABASE_URL}")
    logger.info("===================================")

# ---------------------------
# LIFESPAN
# ---------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):
    await startup_validation()
    logger.info("✅ Startup complete. Ready for connections.")
    yield
    logger.info("🛑 Shutting down...")

# ---------------------------
# FASTAPI APP
# ---------------------------
app = FastAPI(
    title=settings.APP_NAME,
    description="Sophisticated AI assistant backend powered by NVIDIA NIM.",
    version="1.0.0",
    lifespan=lifespan,
    docs_url=None if is_production() else "/docs",
    redoc_url=None if is_production() else "/redoc",
    openapi_url=None if is_production() else "/openapi.json",
)

# ---------------------------
# MIDDLEWARE
# ---------------------------
# Define origins explicitly to avoid middleware crashes
origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]
if settings.ALLOWED_ORIGINS:
    if isinstance(settings.ALLOWED_ORIGINS, list):
        origins.extend(settings.ALLOWED_ORIGINS)
    else:
        origins.append(settings.ALLOWED_ORIGINS)

frontend_url = os.getenv("FRONTEND_URL")
if frontend_url:
    origins.append(frontend_url)

app.add_middleware(
    CORSMiddleware,
    allow_origins=list(set(origins)), # Remove duplicates
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------
# ROUTERS
# ---------------------------
app.include_router(chat.router)
app.include_router(sessions.router)
app.include_router(rag.router)
app.include_router(stt.router)
app.include_router(hr.router)
app.include_router(tts.router)

# ---------------------------
# HEALTH ROUTES
# ---------------------------
@app.get("/", tags=["Health"])
async def root():
    return {
        "status": "ok",
        "service": settings.APP_NAME,
        "debug": settings.DEBUG
    }

@app.get("/health", tags=["Health"])
async def health():
    return {"status": "healthy"}

# ---------------------------
# ERROR HANDLERS
# ---------------------------
@app.exception_handler(RequestValidationError)
async def validation_error(request: Request, exc: RequestValidationError):
    logger.error(f"Validation Error: {exc.errors()}")
    return JSONResponse(status_code=422, content={"detail": exc.errors()})

@app.exception_handler(Exception)
async def global_error(request: Request, exc: Exception):
    status_code = getattr(exc, "status_code", 500)
    logger.error(f"Global Error: {str(exc)}", exc_info=True)

    if not is_production():
        return JSONResponse(
            status_code=status_code,
            content={"detail": str(exc), "type": type(exc).__name__},
        )

    return JSONResponse(
        status_code=status_code,
        content={"detail": "Internal Server Error"},
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="[IP_ADDRESS]", port=8000, reload=True)
