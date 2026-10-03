import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parent.parent

class Settings(BaseSettings):
    PROJECT_NAME: str = "SCAN TO SECURE"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api"
    
    # Security / JWT
    SECRET_KEY: str = "scantosecure-super-secure-production-grade-jwt-key-2026-xyz"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 120
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Database Configuration (MySQL default, with auto-fallback to SQLite for dev)
    MYSQL_HOST: str = "localhost"
    MYSQL_PORT: int = 3306
    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str = ""
    MYSQL_DB: str = "scantosecure"
    DATABASE_URL: str = ""

    # File Storage
    UPLOAD_DIR: Path = BASE_DIR / "uploads" / "certificates"
    MODEL_STORAGE_DIR: Path = BASE_DIR / "models_storage"
    MAX_FILE_SIZE_MB: int = 10
    ALLOWED_EXTENSIONS: set = {"pdf", "png", "jpg", "jpeg"}
    ALLOWED_MIME_TYPES: set = {
        "application/pdf",
        "image/png",
        "image/jpeg",
        "image/pjpeg"
    }

    # College Email Policy
    COLLEGE_EMAIL_DOMAIN: str = "scantosecure.edu"
    ENFORCE_COLLEGE_DOMAIN: bool = False

    model_config = SettingsConfigDict(
        env_file=str(BASE_DIR / ".env"),
        case_sensitive=True,
        extra="allow"
    )

settings = Settings()

# Build MySQL URL if not explicitly provided
if not settings.DATABASE_URL:
    settings.DATABASE_URL = (
        f"mysql+pymysql://{settings.MYSQL_USER}:{settings.MYSQL_PASSWORD}@"
        f"{settings.MYSQL_HOST}:{settings.MYSQL_PORT}/{settings.MYSQL_DB}"
    )

# Ensure upload and model storage directories exist
settings.UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
settings.MODEL_STORAGE_DIR.mkdir(parents=True, exist_ok=True)
