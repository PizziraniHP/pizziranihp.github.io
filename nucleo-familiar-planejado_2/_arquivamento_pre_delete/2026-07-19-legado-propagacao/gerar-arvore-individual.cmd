@echo off
setlocal

if "%~1"=="" (
  echo Uso:
  echo   scripts\gerar-arvore-individual.cmd alice
  echo   scripts\gerar-arvore-individual.cmd --all
  exit /b 1
)

if /I "%~1"=="--all" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0gerar-arvore-individual.ps1" -All
  exit /b %errorlevel%
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0gerar-arvore-individual.ps1" -TreeKey "%~1"
exit /b %errorlevel%
