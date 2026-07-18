@echo off
setlocal

set "MODE=%~1"
if "%MODE%"=="" set "MODE=pre-edit"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0operacao-segura-cadastro.ps1" -Mode %MODE%
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
  echo.
  echo Falha na operacao segura. Verifique as mensagens acima.
)

exit /b %RC%
