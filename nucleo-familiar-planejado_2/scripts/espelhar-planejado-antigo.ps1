param(
  [string]$OldRepoRelative = "..\nucleo-familiar-planejado",
  [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$oldRepo = Resolve-Path (Join-Path $repoRoot $OldRepoRelative)

$oldCanonical = Join-Path $oldRepo "dados\arvores-propagacao.json"
$newCanonical = Join-Path $repoRoot "dados\arvores-propagacao.json"
$generator = Join-Path $repoRoot "scripts\gerar-arvore-individual.ps1"

if (!(Test-Path $oldCanonical)) {
  throw "Canônico antigo não encontrado: $oldCanonical"
}
if (!(Test-Path $newCanonical)) {
  throw "Canônico novo não encontrado: $newCanonical"
}
if (!(Test-Path $generator)) {
  throw "Gerador individual não encontrado: $generator"
}

$oldHash = (Get-FileHash $oldCanonical -Algorithm SHA256).Hash
$newHash = (Get-FileHash $newCanonical -Algorithm SHA256).Hash

Write-Host "HASH_OLD=$oldHash"
Write-Host "HASH_NEW=$newHash"

$changed = $false
if ($Force -or ($oldHash -ne $newHash)) {
  Copy-Item -Path $oldCanonical -Destination $newCanonical -Force
  $changed = $true
  Write-Host "SINCRONIZADO: canônico antigo copiado para planejado_2."
} else {
  Write-Host "SEM_COPIA: canônico já está idêntico."
}

& $generator -All

if (-not $?) {
  throw "Falha ao regenerar árvores individuais."
}

if ($changed) {
  Write-Host "OK_FINAL: espelho aplicado e árvores individuais regeneradas."
} else {
  Write-Host "OK_FINAL: espelho já idêntico; árvores individuais regeneradas."
}
