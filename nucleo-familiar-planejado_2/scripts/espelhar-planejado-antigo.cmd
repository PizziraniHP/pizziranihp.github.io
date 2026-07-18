@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0espelhar-planejado-antigo.ps1" %*
exit /b %errorlevel%
