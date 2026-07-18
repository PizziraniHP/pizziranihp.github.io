param(
  [string]$JsonPath = "dados/pessoas-v2-cartoes-base.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $JsonPath)) {
  Write-Error "Arquivo nao encontrado: $JsonPath"
}

$jsonText = Get-Content -LiteralPath $JsonPath -Raw
$data = $jsonText | ConvertFrom-Json

if (-not $data.sharedBlocks) {
  Write-Error "JSON sem sharedBlocks: $JsonPath"
}

$sharedBlocks = $data.sharedBlocks

function Get-ExpandedEntries {
  param(
    [Parameter(Mandatory = $true)]
    [object[]]$Entries,
    [Parameter(Mandatory = $true)]
    [psobject]$Shared,
    [Parameter(Mandatory = $true)]
    [string]$OriginBlock,
    [Parameter(Mandatory = $true)]
    [System.Collections.Generic.HashSet[string]]$Visited
  )

  $result = New-Object System.Collections.Generic.List[object]

  foreach ($entry in $Entries) {
    if ($null -eq $entry) { continue }

    $refProp = $entry.PSObject.Properties["`$ref"]
    if ($refProp) {
      $refName = [string]$refProp.Value
      if ([string]::IsNullOrWhiteSpace($refName)) { continue }

      if ($Visited.Contains($refName)) {
        Write-Warning "Referencia circular detectada: $OriginBlock -> $refName"
        continue
      }

      $refEntries = $Shared.PSObject.Properties[$refName]
      if (-not $refEntries) {
        Write-Warning "Referencia nao encontrada: $OriginBlock -> $refName"
        continue
      }

      $Visited.Add($refName) | Out-Null
      $expanded = Get-ExpandedEntries -Entries @($refEntries.Value) -Shared $Shared -OriginBlock $OriginBlock -Visited $Visited
      foreach ($e in $expanded) { $result.Add($e) }
      $Visited.Remove($refName) | Out-Null
      continue
    }

    $result.Add($entry)
  }

  return ,$result
}

$occurrencesById = @{}

foreach ($blockProp in $sharedBlocks.PSObject.Properties) {
  $blockName = [string]$blockProp.Name
  $entries = @($blockProp.Value)
  $visited = [System.Collections.Generic.HashSet[string]]::new()
  $visited.Add($blockName) | Out-Null
  $expandedEntries = Get-ExpandedEntries -Entries $entries -Shared $sharedBlocks -OriginBlock $blockName -Visited $visited

  foreach ($item in $expandedEntries) {
    if ($null -eq $item) { continue }

    $id = [string]$item.id
    if ([string]::IsNullOrWhiteSpace($id)) { continue }

    $nome = [string]$item.nome
    $imagem = [string]$item.imagem
    $signature = "{0}|{1}" -f $nome.Trim(), $imagem.Trim()

    if (-not $occurrencesById.ContainsKey($id)) {
      $occurrencesById[$id] = New-Object System.Collections.Generic.List[object]
    }

    $occurrencesById[$id].Add([pscustomobject]@{
      Id = $id
      Block = $blockName
      Nome = $nome
      Imagem = $imagem
      Signature = $signature
    })
  }
}

$inconsistencies = New-Object System.Collections.Generic.List[object]

$repeatedAcrossBlocks = New-Object System.Collections.Generic.List[object]

foreach ($id in ($occurrencesById.Keys | Sort-Object)) {
  $rows = $occurrencesById[$id]
  $blocks = @($rows | Select-Object -ExpandProperty Block -Unique)

  if ($blocks.Count -gt 1) {
    $repeatedAcrossBlocks.Add([pscustomobject]@{
      Id = $id
      Blocks = $blocks
    })
  }
}

foreach ($id in ($occurrencesById.Keys | Sort-Object)) {
  $rows = $occurrencesById[$id]
  $uniqueSignatures = @($rows | Select-Object -ExpandProperty Signature -Unique)

  if ($uniqueSignatures.Count -gt 1) {
    $inconsistencies.Add([pscustomobject]@{
      Id = $id
      Rows = $rows
    })
  }
}

if ($repeatedAcrossBlocks.Count -eq 0 -and $inconsistencies.Count -eq 0) {
  Write-Host "OK: sem divergencia de nome/imagem por ID em $JsonPath"
  exit 0
}

if ($repeatedAcrossBlocks.Count -gt 0) {
  Write-Host "ATENCAO: IDs repetidos em mais de um bloco em $JsonPath" -ForegroundColor Yellow
  foreach ($rep in $repeatedAcrossBlocks) {
    Write-Host ("  - ID {0}: {1}" -f $rep.Id, ($rep.Blocks -join ', '))
  }
  Write-Host ""
}

if ($inconsistencies.Count -gt 0) {
  Write-Host "ATENCAO: divergencias encontradas em $JsonPath" -ForegroundColor Yellow
  foreach ($inc in $inconsistencies) {
    Write-Host ""
    Write-Host ("ID {0}" -f $inc.Id) -ForegroundColor Cyan
    foreach ($row in $inc.Rows | Sort-Object Block) {
      Write-Host ("  - Bloco: {0}" -f $row.Block)
      Write-Host ("    Nome: {0}" -f $row.Nome)
      Write-Host ("    Imagem: {0}" -f $row.Imagem)
    }
  }
}

if ($repeatedAcrossBlocks.Count -gt 0) {
  Write-Host ""
  Write-Host "Resumo adicional: ha IDs repetidos em mais de um bloco." -ForegroundColor Yellow
}

if ($inconsistencies.Count -gt 0) {
  exit 2
}

Write-Host "OK: sem divergencia de nome/imagem por ID em $JsonPath"
exit 0
