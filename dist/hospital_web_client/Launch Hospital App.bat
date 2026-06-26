@echo off
setlocal
cd /d "%~dp0"

echo Starting Hospital Web App...
echo.

start "Hospital App Server" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1"

REM Give the local server a moment to start.
timeout /t 2 /nobreak >nul

start "" http://localhost:8080

echo Browser opened at http://localhost:8080
echo.
echo IMPORTANT:
echo - Do NOT open index.html directly.
echo - Always use this "Launch Hospital App.bat" file.
echo - Keep the "Hospital App Server" window open while using the app.
echo.
pause
