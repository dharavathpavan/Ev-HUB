@echo off
cd /d "%~dp0cms_frontend"
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080 --dart-define API_BASE_URL=http://localhost:3003
pause
