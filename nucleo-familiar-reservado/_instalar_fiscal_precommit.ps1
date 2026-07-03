param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Get-Location).Path
$hookDir = Join-Path $repoRoot '.git/hooks'
$hookFile = Join-Path $hookDir 'pre-commit'

if (-not (Test-Path $hookDir)) {
    throw 'Pasta .git/hooks nao encontrada. Execute este script na raiz do repositorio.'
}

$hookContent = @'
#!/bin/sh
powershell -NoProfile -ExecutionPolicy Bypass -File "nucleo-familiar-reservado/_fiscal_precommit.ps1"
status=$?
if [ $status -ne 0 ]; then
  exit $status
fi
exit 0
'@

Set-Content -Path $hookFile -Value $hookContent -Encoding ASCII
Write-Host 'Hook pre-commit instalado em .git/hooks/pre-commit'
