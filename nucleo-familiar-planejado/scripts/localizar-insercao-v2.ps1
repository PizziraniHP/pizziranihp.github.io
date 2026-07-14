param(
    [Parameter(Mandatory = $true)]
    [string]$Pessoa,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 8)]
    [int]$Geracao,

    [string]$Id,

    [int]$Posicao,

    [ValidateRange(1, 32)]
    [int]$ColunasPorLinha = 4,

    [string]$Arquivo = "..\dados\pessoas-v2-cartoes-base.json"
)

$ErrorActionPreference = "Stop"

function Resolve-PathFromScript {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $scriptDir = Split-Path -Parent $PSCommandPath
    return [System.IO.Path]::GetFullPath((Join-Path $scriptDir $Path))
}

function Get-IdsDoBloco {
    param($Entries)

    $ids = @()
    foreach ($entry in $Entries) {
        if ($entry.PSObject.Properties.Name -contains '$ref') {
            continue
        }

        if ($entry.id) {
            $ids += [string]$entry.id
        }
    }

    return @($ids)
}

function Get-BlockLine {
    param(
        [string]$FilePath,
        [string]$BlockName
    )

    $pattern = '"' + [Regex]::Escape($BlockName) + '"\s*:\s*\['
    $match = Select-String -Path $FilePath -Pattern $pattern | Select-Object -First 1
    if ($match) {
        return [int]$match.LineNumber
    }

    return -1
}

function Get-NextIdSuggestion {
    param(
        [string[]]$Ids,
        [int]$Geracao
    )

    if ($Ids.Count -eq 0) {
        return ("{0}001" -f ("{0:D2}" -f $Geracao))
    }

    $max = 0
    foreach ($v in $Ids) {
        $n = 0
        if ([int]::TryParse($v, [ref]$n)) {
            if ($n -gt $max) {
                $max = $n
            }
        }
    }

    if ($max -eq 0) {
        return ("{0}001" -f ("{0:D2}" -f $Geracao))
    }

    return ("{0:D4}" -f ($max + 1))
}

function New-EntryMap {
    param(
        [int]$GlobalPos,
        [string]$BlockName,
        [int]$BlockPos,
        $Entry
    )

    $id = ""
    if ($Entry.PSObject.Properties.Name -contains 'id' -and $Entry.id) {
        $id = [string]$Entry.id
    }

    $nome = ""
    if ($Entry.PSObject.Properties.Name -contains 'nome' -and $Entry.nome) {
        $nome = [string]$Entry.nome
    }

    $ramo = ""
    if ($Entry.PSObject.Properties.Name -contains 'ramo' -and $Entry.ramo) {
        $ramo = [string]$Entry.ramo
    }

    $placeholder = $false
    if ($Entry.PSObject.Properties.Name -contains 'placeholder' -and $Entry.placeholder) {
        $placeholder = [bool]$Entry.placeholder
    }

    return [pscustomobject]@{
        PosGlobal  = $GlobalPos
        BlockName  = $BlockName
        PosNoBloco = $BlockPos
        Id         = $id
        Nome       = $nome
        Ramo       = $ramo
        Placeholder = $placeholder
    }
}

function Get-LineCol {
    param(
        [int]$Pos,
        [int]$Cols
    )

    $linha = [int][Math]::Ceiling($Pos / [double]$Cols)
    $coluna = (($Pos - 1) % $Cols) + 1

    return [pscustomobject]@{
        Linha = $linha
        Coluna = $coluna
    }
}

$arquivoPath = Resolve-PathFromScript -Path $Arquivo
if (-not (Test-Path -LiteralPath $arquivoPath)) {
    throw "Arquivo nao encontrado: $arquivoPath"
}

$jsonText = Get-Content -LiteralPath $arquivoPath -Raw -Encoding UTF8
$json = $jsonText | ConvertFrom-Json

if (-not $json.trees) {
    throw "JSON invalido: trees ausente."
}

if (-not $json.sharedBlocks) {
    throw "JSON invalido: sharedBlocks ausente."
}

if (-not $json.trees.PSObject.Properties.Name.Contains($Pessoa)) {
    $available = $json.trees.PSObject.Properties.Name -join ", "
    throw "Pessoa '$Pessoa' nao encontrada. Opcoes: $available"
}

$genKey = "g$Geracao"
$treeObj = $json.trees.PSObject.Properties[$Pessoa].Value
$genObj = $treeObj.PSObject.Properties[$genKey]
if (-not $genObj) {
    throw "Geracao '$genKey' nao encontrada na arvore de '$Pessoa'."
}

$entries = @($genObj.Value)
$refs = @()

foreach ($entry in $entries) {
    if ($entry.PSObject.Properties.Name -contains '$ref') {
        $refs += [string]$entry.'$ref'
    }
}

Write-Host "Arquivo : $arquivoPath"
Write-Host "Pessoa  : $Pessoa"
Write-Host "Geracao : $genKey"
Write-Host "Blocos  : $($refs -join ', ')"

if ($refs.Count -eq 0) {
    Write-Host "Nao ha refs nesta geracao; bloco inline na propria arvore."
    exit 0
}

Write-Host ""
Write-Host "Pontos de insercao (v2):"

$allSelectedIds = @()
$expanded = @()
$globalPos = 0

foreach ($blockName in $refs) {
    $blockProp = $json.sharedBlocks.PSObject.Properties[$blockName]
    if (-not $blockProp) {
        Write-Host "- ${blockName}: BLOCO AUSENTE"
        continue
    }

    $ids = Get-IdsDoBloco -Entries $blockProp.Value
    $allSelectedIds += $ids

    $line = Get-BlockLine -FilePath $arquivoPath -BlockName $blockName
    $nextId = Get-NextIdSuggestion -Ids $ids -Geracao $Geracao

    Write-Host "- $blockName (linha $line)"
    Write-Host "  IDs atuais : $($ids -join ', ')"
    Write-Host "  Proximo ID : $nextId"
    Write-Host "  Sugestao   : inserir no final do bloco, mantendo ordem crescente de ID"

    $entriesDoBloco = @($blockProp.Value)
    for ($i = 0; $i -lt $entriesDoBloco.Count; $i++) {
        $entry = $entriesDoBloco[$i]
        if ($entry.PSObject.Properties.Name -contains '$ref') {
            continue
        }

        $globalPos++
        $expanded += New-EntryMap -GlobalPos $globalPos -BlockName $blockName -BlockPos ($i + 1) -Entry $entry
    }
}

if ($expanded.Count -gt 0) {
    Write-Host ""
    Write-Host "Mapa rapido de posicoes (global na geracao):"
    foreach ($item in $expanded) {
        $lc = Get-LineCol -Pos $item.PosGlobal -Cols $ColunasPorLinha
        $idTxt = if ($item.Id) { $item.Id } else { "(vazio)" }
        $flag = if ($item.Placeholder) { "placeholder" } else { "real" }
        Write-Host ("- P{0}: L{1} C{2} | bloco={3} | posBloco={4} | ramo={5} | id={6} | {7}" -f $item.PosGlobal, $lc.Linha, $lc.Coluna, $item.BlockName, $item.PosNoBloco, $item.Ramo, $idTxt, $flag)
    }
}

if ($Posicao) {
    Write-Host ""
    Write-Host "Consulta por posicao: P$Posicao"

    $target = $expanded | Where-Object { $_.PosGlobal -eq $Posicao } | Select-Object -First 1
    if (-not $target) {
        throw "Posicao P$Posicao fora do intervalo 1..$($expanded.Count) desta geracao."
    }

    $lc = Get-LineCol -Pos $target.PosGlobal -Cols $ColunasPorLinha
    $targetId = if ($target.Id) { $target.Id } else { "(vazio)" }
    Write-Host ("Atual: bloco={0}, posBloco={1}, ramo={2}, id={3}, linha={4}, coluna={5}" -f $target.BlockName, $target.PosNoBloco, $target.Ramo, $targetId, $lc.Linha, $lc.Coluna)

    $childA = (2 * $target.PosGlobal) - 1
    $childB = (2 * $target.PosGlobal)
    $lcA = Get-LineCol -Pos $childA -Cols $ColunasPorLinha
    $lcB = Get-LineCol -Pos $childB -Cols $ColunasPorLinha

    Write-Host ("Proxima geracao: P{0} (L{1} C{2}) e P{3} (L{4} C{5})" -f $childA, $lcA.Linha, $lcA.Coluna, $childB, $lcB.Linha, $lcB.Coluna)
}

if ($Id) {
    Write-Host ""
    Write-Host "Checagem do ID informado: $Id"

    $foundBlocks = @()
    foreach ($p in $json.sharedBlocks.PSObject.Properties) {
        $ids = Get-IdsDoBloco -Entries $p.Value
        if ($ids -contains $Id) {
            $foundBlocks += $p.Name
        }
    }

    if ($foundBlocks.Count -eq 0) {
        Write-Host "- ID nao existe em nenhum sharedBlock."
    }
    else {
        Write-Host "- ID ja existe nos blocos: $($foundBlocks -join ', ')"
    }

    $selectedContains = $allSelectedIds -contains $Id
    if ($selectedContains) {
        Write-Host "- ID ja existe na geracao/pessoa selecionada."
    }
    else {
        Write-Host "- ID ainda nao existe na geracao/pessoa selecionada."
    }
}
