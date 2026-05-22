@echo off
echo Checking EV CMS local servers...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:3003' -UseBasicParsing -TimeoutSec 5; Write-Host 'Backend OK:' $r.StatusCode } catch { Write-Host 'Backend NOT running on http://localhost:3003' }"
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:3003/api/vendors/apply' -UseBasicParsing -TimeoutSec 5; Write-Host 'Backend API OK:' $r.StatusCode } catch { Write-Host 'Backend API NOT reachable at http://127.0.0.1:3003/api/vendors/apply' }"
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8080' -UseBasicParsing -TimeoutSec 5; Write-Host 'Flutter web OK:' $r.StatusCode } catch { Write-Host 'Flutter web NOT running on http://127.0.0.1:8080' }"
echo.
pause
