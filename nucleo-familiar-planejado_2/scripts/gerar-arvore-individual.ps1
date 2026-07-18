param(
  [string]$TreeKey,
  [switch]$All,
  [string]$Source = "dados/arvores-propagacao.json",
  [string]$OutDir = "dados"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRoot {
  $scriptDir = $PSScriptRoot
  return (Resolve-Path (Join-Path $scriptDir "..")).Path
}

function Set-Utf8NoBomFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Content
  )

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Get-RefNames {
  param(
    [Parameter(Mandatory = $true)]$TreeObj
  )

  $refNames = New-Object System.Collections.Generic.HashSet[string]

  foreach ($g in 1..8) {
    $gk = "g$g"
    $entries = @($TreeObj.$gk)
    foreach ($entry in $entries) {
      if ($null -eq $entry) { continue }
      if ($entry.PSObject.Properties.Name -contains '$ref') {
        [void]$refNames.Add([string]$entry.'$ref')
      }
    }
  }

  return $refNames
}

function New-IndividualObject {
  param(
    [Parameter(Mandatory = $true)]$Src,
    [Parameter(Mandatory = $true)][string]$TreeKey
  )

  if (-not ($Src.trees.PSObject.Properties.Name -contains $TreeKey)) {
    throw "Arvore '$TreeKey' nao encontrada em '$Source'."
  }

  $treeObj = $Src.trees.$TreeKey
  $refNames = Get-RefNames -TreeObj $treeObj

  $shared = [ordered]@{}
  foreach ($name in $refNames) {
    if ($Src.sharedBlocks.PSObject.Properties.Name -contains $name) {
      $shared[$name] = $Src.sharedBlocks.$name
    }
  }

  return [ordered]@{
    sharedBlocks = $shared
    trees = [ordered]@{
      $TreeKey = $treeObj
    }
  }
}

$repoRoot = Resolve-RepoRoot
$srcPath = Join-Path $repoRoot $Source
$outDirPath = Join-Path $repoRoot $OutDir

if (-not (Test-Path $srcPath)) {
  throw "Arquivo fonte nao encontrado: $srcPath"
}

if (-not (Test-Path $outDirPath)) {
  New-Item -ItemType Directory -Path $outDirPath | Out-Null
}

$srcJson = Get-Content -Raw -Encoding UTF8 $srcPath | ConvertFrom-Json
$treeKeys = @()

if ($All) {
  $treeKeys = @($srcJson.trees.PSObject.Properties.Name)
} else {
  if ([string]::IsNullOrWhiteSpace($TreeKey)) {
    throw "Informe -TreeKey <nome> ou use -All."
  }
  $treeKeys = @($TreeKey.Trim())
}

foreach ($key in $treeKeys) {
  $obj = New-IndividualObject -Src $srcJson -TreeKey $key
  $json = $obj | ConvertTo-Json -Depth 100

  $outName = "arvore-$key-individual.json"
  $outPath = Join-Path $outDirPath $outName
  Set-Utf8NoBomFile -Path $outPath -Content $json

  $refCount = @($obj.sharedBlocks.Keys).Count
  Write-Host "OK: $outName gerado com $refCount sharedBlocks."
}
