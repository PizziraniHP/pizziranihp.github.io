@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0validar-slots-canonicos.ps1" %*
endlocal