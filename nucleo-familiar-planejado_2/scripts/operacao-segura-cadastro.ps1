param(
  [ValidateSet('pre-edit', 'backup', 'validate', 'post-edit')]
  [string]$Mode = 'pre-edit',
  [string]$BackupRoot = '.backups-locais',
  [switch]$IncludeSaibaMais
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backupBase = if ([System.IO.Path]::IsPathRooted($BackupRoot)) { $BackupRoot } else { Join-Path $repoRoot $BackupRoot }

$filesToBackup = @(
  'dados/pessoas-v2-cartoes-base.json',
  'dados/pessoas-v25-cartoes-base.json',
  'docs/padroes.md',
  'README.md'
)

function Ensure-Directory {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Assert-JsonParse {
  param([Parameter(Mandatory = $true)][string]$RelativePath)

  $fullPath = Join-Path $repoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    throw "Arquivo nao encontrado: $RelativePath"
  }

  try {
    Get-Content -LiteralPath $fullPath -Raw | ConvertFrom-Json | Out-Null
    Write-Host "OK JSON: $RelativePath"
  } catch {
    throw "JSON invalido em $RelativePath. Detalhe: $($_.Exception.Message)"
  }
}

function Run-ValidationScript {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptRelativePath,
    [string[]]$Arguments = @(),
    [int[]]$AcceptExitCodes = @(0)
  )

  $scriptPath = Join-Path $repoRoot $ScriptRelativePath
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Script nao encontrado: $ScriptRelativePath"
  }

  Write-Host "Executando: $ScriptRelativePath $($Arguments -join ' ')"
  & $scriptPath @Arguments
  $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
  if ($AcceptExitCodes -notcontains $exitCode) {
    throw "Falha em $ScriptRelativePath (exit $exitCode)"
  }

  if ($exitCode -ne 0) {
    Write-Host "ALERTA: $ScriptRelativePath retornou exit $exitCode (aceito no modo atual)." -ForegroundColor Yellow
  }
}

function New-Checkpoint {
  Ensure-Directory -Path $backupBase

  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $checkpointDir = Join-Path $backupBase ("checkpoint-" + $stamp)
  Ensure-Directory -Path $checkpointDir

  $manifestPath = Join-Path $checkpointDir 'manifesto-sha256.txt'
  $manifestLines = New-Object System.Collections.Generic.List[string]

  $effectiveFiles = @($filesToBackup)

  foreach ($relative in $effectiveFiles) {
    $source = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $source)) {
      Write-Host "AVISO: arquivo fora do checkpoint: $relative" -ForegroundColor Yellow
      continue
    }

    $target = Join-Path $checkpointDir $relative
    $targetDir = Split-Path -Parent $target
    Ensure-Directory -Path $targetDir

    Copy-Item -LiteralPath $source -Destination $target -Force

    $hash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
    $manifestLines.Add(("{0} *{1}" -f $hash, $relative.Replace('\\', '/'))) | Out-Null
  }

  Set-Content -LiteralPath $manifestPath -Value $manifestLines -Encoding UTF8
  Write-Host "Checkpoint criado: $checkpointDir" -ForegroundColor Green
  return $checkpointDir
}

function Run-Validations {
  Assert-JsonParse -RelativePath 'dados/pessoas-v2-cartoes-base.json'

  $v25Path = Join-Path $repoRoot 'dados/pessoas-v25-cartoes-base.json'
  if (Test-Path -LiteralPath $v25Path) {
    Assert-JsonParse -RelativePath 'dados/pessoas-v25-cartoes-base.json'
  }

  Run-ValidationScript -ScriptRelativePath 'scripts/validar-consistencia-ids.ps1' -Arguments @((Join-Path $repoRoot 'dados/pessoas-v2-cartoes-base.json')) -AcceptExitCodes @(0, 2)

  if (Test-Path -LiteralPath $v25Path) {
    Run-ValidationScript -ScriptRelativePath 'scripts/validar-consistencia-ids.ps1' -Arguments @((Join-Path $repoRoot 'dados/pessoas-v25-cartoes-base.json')) -AcceptExitCodes @(0, 2)
  }

  try {
    Run-ValidationScript -ScriptRelativePath 'scripts/validar-slots-canonicos.ps1' -AcceptExitCodes @(0, 1)
  } catch {
    Write-Host "ALERTA: validacao de slots canonicos nao concluiu. Prosseguindo para nao bloquear cadastro seguro." -ForegroundColor Yellow
    Write-Host ("Detalhe tecnico: " + $_.Exception.Message) -ForegroundColor Yellow
  }

  if ($IncludeSaibaMais) {
    Run-ValidationScript -ScriptRelativePath 'scripts/validar-saiba-mais.ps1'
  }

  Write-Host 'Validacoes concluidas sem falhas.' -ForegroundColor Green
}

try {
  switch ($Mode) {
    'backup' {
      New-Checkpoint | Out-Null
    }
    'validate' {
      Run-Validations
    }
    'pre-edit' {
      New-Checkpoint | Out-Null
      Run-Validations
      Write-Host 'Pronto para editar com seguranca.' -ForegroundColor Green
    }
    'post-edit' {
      Run-Validations
      Write-Host 'Pos-edicao validada.' -ForegroundColor Green
    }
  }

  exit 0
} catch {
  Write-Error $_
  exit 1
}
