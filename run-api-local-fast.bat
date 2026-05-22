@echo off
cd /d "%~dp0cms_backend"
echo Starting fast local API at http://localhost:3003
echo Keep this window open.
node scripts\local_api_server.mjs
pause
