@echo off
cd /d "%~dp0cms_backend"
echo Starting EV CMS backend API at http://localhost:3003
echo Keep this window open.
node node_modules\next\dist\bin\next dev -H 0.0.0.0 -p 3003
pause
