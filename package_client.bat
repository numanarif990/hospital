@echo off
setlocal
cd /d "%~dp0"

echo Building Flutter web release...
call flutter build web --release
if errorlevel 1 (
    echo Build failed.
    exit /b 1
)

set "OUT=dist\hospital_web_client"

echo.
echo Creating client package in %OUT% ...

if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%OUT%"

xcopy /e /i /y "build\web\*" "%OUT%\"
copy /y "client_launcher\Launch Hospital App.bat" "%OUT%\"
copy /y "client_launcher\serve.ps1" "%OUT%\"
copy /y "client_launcher\README_FOR_CLIENT.txt" "%OUT%\"

echo.
echo Done.
echo.
echo Send this folder to your client (zip it first):
echo   %CD%\%OUT%
echo.
echo Client should unzip it and double-click:
echo   Launch Hospital App.bat
echo.
pause
