@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sincronizar-blocos-v2-v25.ps1" %*
endlocal