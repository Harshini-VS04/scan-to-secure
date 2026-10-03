import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config import settings, BASE_DIR

logger = logging.getLogger("scantosecure.database")

Base = declarative_base()

def get_engine():
    """
    Connect to MySQL with connection pooling.
    If MySQL server is unavailable or fails to connect, fallback to SQLite
    to ensure seamless local testing without blocking development.
    """
    mysql_url = settings.DATABASE_URL
    try:
        if mysql_url.startswith("mysql"):
            # Attempt to connect to MySQL
            test_engine = create_engine(
                mysql_url,
                pool_pre_ping=True,
                pool_recycle=3600,
                connect_args={"connect_timeout": 3}
            )
            with test_engine.connect() as conn:
                logger.info(f"Connected successfully to MySQL at {settings.MYSQL_HOST}:{settings.MYSQL_PORT}/{settings.MYSQL_DB}")
            return test_engine
    except Exception as e:
        logger.warning(
            f"MySQL connection failed ({e}). "
            f"Falling back to embedded SQLite database for local execution."
        )

    # Fallback to local SQLite database
    sqlite_path = BASE_DIR / "scantosecure.db"
    sqlite_url = f"sqlite:///{sqlite_path}"
    logger.info(f"Using SQLite database: {sqlite_url}")
    return create_engine(
        sqlite_url,
        connect_args={"check_same_thread": False}
    )

engine = get_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """Initialize all tables defined in models"""
    import app.models  # Ensure models are imported
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables initialized successfully.")
