import logging
from pathlib import Path
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from app.config import settings
from app.database import init_db
from app.routes import auth, certificates, classes, admin, analytics
from app.utils.seed_data import seed_database
from app.ml.classifier import CertificateClassifier

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("scantosecure")

FRONTEND_DIST = Path(__file__).resolve().parent.parent.parent / "frontend" / "dist"

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting up SCAN TO SECURE backend...")
    # Initialize database tables
    init_db()
    # Populate seed data if database is empty
    seed_database()
    # Preload and warm up AI/ML classifier
    CertificateClassifier.get_model()
    logger.info("Platform startup and AI model warmup completed.")
    yield
    logger.info("Shutting down SCAN TO SECURE backend...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="AI/ML-Powered Platform for Secure Academic Certificate Management",
    lifespan=lifespan
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(certificates.router, prefix=settings.API_V1_STR)
app.include_router(classes.router, prefix=settings.API_V1_STR)
app.include_router(admin.router, prefix=settings.API_V1_STR)
app.include_router(analytics.router, prefix=settings.API_V1_STR)

@app.get("/api/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION
    }

# Mount built React frontend SPA
if FRONTEND_DIST.exists():
    assets_dir = FRONTEND_DIST / "assets"
    if assets_dir.exists():
        app.mount("/assets", StaticFiles(directory=assets_dir), name="assets")

    @app.get("/{full_path:path}", include_in_schema=False)
    async def serve_spa(full_path: str):
        if full_path.startswith("api"):
            raise HTTPException(status_code=404, detail="API route not found")
        target_file = FRONTEND_DIST / full_path
        if target_file.is_file():
            return FileResponse(target_file)
        return FileResponse(
            FRONTEND_DIST / "index.html",
            headers={
                "Cache-Control": "no-cache, no-store, must-revalidate",
                "Pragma": "no-cache",
                "Expires": "0"
            }
        )

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": exc.detail,
            "detail": exc.detail,
            "error_code": f"HTTP_{exc.status_code}"
        }
    )

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global unhandled error on {request.url.path}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": "An internal server error occurred. Please contact the administrator.",
            "detail": "An internal server error occurred. Please contact the administrator.",
            "error_code": "INTERNAL_SERVER_ERROR"
        }
    )
