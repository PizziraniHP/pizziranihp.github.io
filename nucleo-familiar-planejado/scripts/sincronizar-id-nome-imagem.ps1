param(
  [string]$JsonPath = "dados/pessoas-v2-cartoes-base.json",
  [string]$SourceBlock = "g5-paterno-comum",
  [string[]]$Ids = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $JsonPath)) {
  Write-Error "Arquivo nao encontrado: $JsonPath"
}

if ($Ids.Count -eq 0) {
  Write-Error "Informe ao menos um ID em -Ids, por exemplo: -Ids 0506,0507,0508"
}

$jsonText = Get-Content -LiteralPath $JsonPath -Raw
$data = $jsonText | ConvertFrom-Json

if (-not $data.sharedBlocks) {
  Write-Error "JSON sem sharedBlocks: $JsonPath"
}

$sharedBlocks = $data.sharedBlocks
$sourceBlockProp = $sharedBlocks.PSObject.Properties[$SourceBlock]
if (-not $sourceBlockProp) {
  Write-Error "Bloco fonte nao encontrado: $SourceBlock"
}

$idsSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($id in $Ids) {
  if (-not [string]::IsNullOrWhiteSpace($id)) {
    $idsSet.Add(($id.Trim())) | Out-Null
  }
}

$sourceMap = @{}
foreach ($entry in @($sourceBlockProp.Value)) {
  if ($null -eq $entry) { continue }
  $id = [string]$entry.id
  if ([string]::IsNullOrWhiteSpace($id)) { continue }
  if (-not $idsSet.Contains($id)) { continue }

  $sourceMap[$id] = [pscustomobject]@{
    Nome = [string]$entry.nome
    Imagem = [string]$entry.imagem
  }
}

$missing = @()
foreach ($id in $idsSet) {
  if (-not $sourceMap.ContainsKey($id)) {
    $missing += $id
  }
}

if ($missing.Count -gt 0) {
  Write-Error ("IDs nao encontrados no bloco fonte {0}: {1}" -f $SourceBlock, ($missing -join ", "))
}

$changes = New-Object System.Collections.Generic.List[object]

foreach ($blockProp in $sharedBlocks.PSObject.Properties) {
  $blockName = [string]$blockProp.Name
  $entries = @($blockProp.Value)

  foreach ($entry in $entries) {
    if ($null -eq $entry) { continue }
    $id = [string]$entry.id
    if ([string]::IsNullOrWhiteSpace($id)) { continue }
    if (-not $idsSet.Contains($id)) { continue }
    if (-not $sourceMap.ContainsKey($id)) { continue }

    $target = $sourceMap[$id]
    $oldNome = [string]$entry.nome
    $oldImagem = [string]$entry.imagem

    $newNome = $target.Nome
    $newImagem = $target.Imagem

    if ($oldNome -ne $newNome -or $oldImagem -ne $newImagem) {
      $entry.nome = $newNome
      $entry.imagem = $newImagem

      $changes.Add([pscustomobject]@{
        Block = $blockName
        Id = $id
        NomeAntes = $oldNome
        NomeDepois = $newNome
        ImagemAntes = $oldImagem
        ImagemDepois = $newImagem
      })
    }
  }
}

if ($changes.Count -eq 0) {
  Write-Host "Sem alteracoes necessarias em $JsonPath"
  exit 0
}

$data | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $JsonPath -Encoding UTF8

Write-Host ("Atualizado: {0}" -f $JsonPath)
Write-Host ("Alteracoes: {0}" -f $changes.Count)
foreach ($c in $changes) {
  Write-Host ""
  Write-Host ("Bloco: {0} | ID: {1}" -f $c.Block, $c.Id)
  Write-Host ("  Nome:   {0} -> {1}" -f $c.NomeAntes, $c.NomeDepois)
  Write-Host ("  Imagem: {0} -> {1}" -f $c.ImagemAntes, $c.ImagemDepois)
}
