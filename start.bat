@echo off
title SCAN TO SECURE - Server
echo ============================================================
echo   SCAN TO SECURE: Academic Certificate Management Platform
echo   AI/ML-Powered, Dual-Duplicate Detection, RBAC Security
echo ============================================================
echo.

cd /d "%~dp0backend"
set PYTHONPATH=%~dp0backend

echo Starting FastAPI Server on http://localhost:8000 ...
echo Press Ctrl+C to stop.
echo.

"%~dp0.venv\Scripts\python.exe" -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
