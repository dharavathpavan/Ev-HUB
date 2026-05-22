@echo off
cd /d "%~dp0"
start "EV CMS API - localhost:3003" "%~dp0run-api-local-fast.bat"
timeout /t 6 /nobreak >nul
start "EV CMS Flutter Web - localhost:8080" "%~dp0run-flutter-built-web-local.bat"
echo Started EV CMS local project.
echo Backend: http://localhost:3003
echo Flutter: http://127.0.0.1:8080
echo.
echo Keep both terminal windows open while using the app.
pause
