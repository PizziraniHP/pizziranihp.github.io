@echo off
setlocal

set "ROOT=%~dp0"

echo [1/2] Sincronizando blocos comuns (v2 -> v25)...
call "%ROOT%sincronizar-blocos-v2-v25.cmd" -AutoComuns
if errorlevel 1 goto :fail

echo [2/2] Validando codigos/posicoes...
call "%ROOT%validar-slots-canonicos.cmd"
if errorlevel 1 goto :fail

echo.
echo OK: v25 alinhada com v2 e validada.
exit /b 0

:fail
echo.
echo FALHA: veja mensagens acima.
exit /b 1
