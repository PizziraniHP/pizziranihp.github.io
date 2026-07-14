@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0localizar-insercao-v2.ps1" %*
endlocal