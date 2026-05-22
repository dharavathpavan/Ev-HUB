@echo off
setlocal
cd /d "%~dp0"
echo EV CMS backend pipeline
echo -----------------------
npm.cmd run push:supabase
echo.
pause
