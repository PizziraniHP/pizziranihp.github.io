param(
    [string]$Source = "..\dados\pessoas-v2-cartoes-base.json",
    [string]$Target = "..\dados\pessoas-v25-cartoes-base.json",
    [string[]]$Blocos = @(),
    [switch]$AutoComuns,
    [switch]$DryRun
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

function Get-BlockRange {
    param(
        [string]$Text,
        [string]$BlockName
    )

    $pattern = '"' + [Regex]::Escape($BlockName) + '"\s*:\s*\['
    $startMatch = [Regex]::Match($Text, $pattern)
    if (-not $startMatch.Success) {
        throw "Bloco '$BlockName' nao encontrado."
    }

    $openBracketIndex = $Text.IndexOf('[', $startMatch.Index)
    if ($openBracketIndex -lt 0) {
        throw "Abertura '[' nao encontrada para bloco '$BlockName'."
    }

    $depth = 0
    $closeBracketIndex = -1
    for ($i = $openBracketIndex; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($ch -eq '[') {
            $depth++
        }
        elseif ($ch -eq ']') {
            $depth--
            if ($depth -eq 0) {
                $closeBracketIndex = $i
                break
            }
        }
    }

    if ($closeBracketIndex -lt 0) {
        throw "Fechamento ']' nao encontrado para bloco '$BlockName'."
    }

    return [pscustomobject]@{
        Start  = $startMatch.Index
        End    = $closeBracketIndex
        Length = ($closeBracketIndex - $startMatch.Index + 1)
    }
}

function Get-BlockText {
    param(
        [string]$Text,
        [string]$BlockName
    )

    $range = Get-BlockRange -Text $Text -BlockName $BlockName
    return $Text.Substring($range.Start, $range.Length)
}

function Set-BlockText {
    param(
        [string]$TargetText,
        [string]$BlockName,
        [string]$ReplacementBlock
    )

    $range = Get-BlockRange -Text $TargetText -BlockName $BlockName
    return $TargetText.Remove($range.Start, $range.Length).Insert($range.Start, $ReplacementBlock)
}

function Get-SharedBlockNames {
    param([string]$JsonText)

    $obj = $JsonText | ConvertFrom-Json
    if (-not $obj.sharedBlocks) {
        throw "Objeto 'sharedBlocks' nao encontrado no JSON."
    }

    return @($obj.sharedBlocks.PSObject.Properties.Name)
}

$sourcePath = Resolve-PathFromScript -Path $Source
$targetPath = Resolve-PathFromScript -Path $Target

if (-not (Test-Path $sourcePath)) { throw "Arquivo source nao encontrado: $sourcePath" }
if (-not (Test-Path $targetPath)) { throw "Arquivo target nao encontrado: $targetPath" }

$sourceText = Get-Content -LiteralPath $sourcePath -Raw -Encoding UTF8
$targetText = Get-Content -LiteralPath $targetPath -Raw -Encoding UTF8

if ($AutoComuns) {
    $sourceNames = Get-SharedBlockNames -JsonText $sourceText
    $targetNames = Get-SharedBlockNames -JsonText $targetText
    $Blocos = @($sourceNames | Where-Object { $targetNames -contains $_ })
}

if (-not $Blocos -or $Blocos.Count -eq 0) {
    throw "Nenhum bloco para sincronizar. Use -Blocos <nomes> ou -AutoComuns."
}

$updatedText = $targetText
$processed = @()

foreach ($bloco in $Blocos) {
    $sourceBlock = Get-BlockText -Text $sourceText -BlockName $bloco
    $updatedText = Set-BlockText -TargetText $updatedText -BlockName $bloco -ReplacementBlock $sourceBlock
    $processed += $bloco
}

if ($DryRun) {
    Write-Host "DryRun: blocos processados -> $($processed -join ', ')"
    exit 0
}

Set-Content -LiteralPath $targetPath -Value $updatedText -Encoding UTF8
Write-Host "Sincronizacao concluida."
Write-Host "Source: $sourcePath"
Write-Host "Target: $targetPath"
Write-Host "Blocos: $($processed -join ', ')"