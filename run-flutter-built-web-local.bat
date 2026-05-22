@echo off
cd /d "%~dp0cms_frontend\build\web"
echo Serving built Flutter web app at http://127.0.0.1:8080
echo Keep this window open while using the app.
py -m http.server 8080 --bind 127.0.0.1
pause
