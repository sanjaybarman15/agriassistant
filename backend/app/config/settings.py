from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import field_validator
from typing import Optional, List, Union
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    # ── App Config ──────────────────────────────────────────────
    APP_NAME: str
    DEBUG: bool
    
    # ── Supabase ────────────────────────────────────────────────
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_ROLE_KEY: str
    
    # ── AI Providers (NVIDIA NIM) ───────────────────────────────
    NVIDIA_API_KEY: str
    NVIDIA_BASE_URL: str
    
    # ── Database ────────────────────────────────────────────────
    DATABASE_URL: str
    DIRECT_URL: str
    
    # ── Models ──────────────────────────────────────────────────
    DEFAULT_CHAT_MODEL: str
    FAST_MODEL: str
    EMBEDDING_MODEL: str
    STT_MODEL: str
    STT_API_KEY: str
    
    # ── ElevenLabs ──────────────────────────────────────────────
    ELEVENLABS_API_KEY: str
    ELEVENLABS_MODEL_ID: str = "scribe_v2"
    ELEVENLABS_VOICE_ID: str = "EXAVITQu4vr4xnSDxMaL"  # Default: Bella (Pre-made)
    ELEVENLABS_LANGUAGE_CODE: str = "eng"
    ELEVENLABS_DIARIZE: bool = False
    ELEVENLABS_TAG_AUDIO_EVENTS: bool = False
    
    # ── Redis (Upstash) ────────────────────────────────────────
    UPSTASH_REDIS_URL: Optional[str] = None
    UPSTASH_REDIS_TOKEN: Optional[str] = None
    
    # ── AI Profile ─────────────────────────────────────────────
    AI_NAME: str
    AI_DESCRIPTION: str
    AI_DOMAIN: str

    # ── Security ───────────────────────────────────────────────
    ALLOWED_ORIGINS: Union[str, List[str]]

    @field_validator("ALLOWED_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        return v

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

settings = Settings()
