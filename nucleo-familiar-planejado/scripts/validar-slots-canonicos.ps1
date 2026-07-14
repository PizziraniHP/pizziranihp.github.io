param(
    [string]$Source = "..\dados\pessoas-v2-cartoes-base.json",
    [string]$Target = "..\dados\pessoas-v25-cartoes-base.json"
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

function Equal-Sequence {
    param(
        [string[]]$A,
        [string[]]$B
    )

    if ($A.Count -ne $B.Count) { return $false }

    for ($i = 0; $i -lt $A.Count; $i++) {
        if ($A[$i] -ne $B[$i]) {
            return $false
        }
    }

    return $true
}

$sourcePath = Resolve-PathFromScript -Path $Source
$targetPath = Resolve-PathFromScript -Path $Target

if (-not (Test-Path -LiteralPath $sourcePath)) { throw "Arquivo source nao encontrado: $sourcePath" }
if (-not (Test-Path -LiteralPath $targetPath)) { throw "Arquivo target nao encontrado: $targetPath" }

$sourceObj = Get-Content -LiteralPath $sourcePath -Raw -Encoding UTF8 | ConvertFrom-Json
$targetObj = Get-Content -LiteralPath $targetPath -Raw -Encoding UTF8 | ConvertFrom-Json

$sourceNames = @($sourceObj.sharedBlocks.PSObject.Properties.Name)
$targetNames = @($targetObj.sharedBlocks.PSObject.Properties.Name)
$commonNames = @($sourceNames | Where-Object { $targetNames -contains $_ })

$problems = 0

Write-Host "Comparando blocos comuns (v2 canonica -> v25): $($commonNames.Count) bloco(s)"

foreach ($name in $commonNames) {
    $sourceEntries = $sourceObj.sharedBlocks.PSObject.Properties[$name].Value
    $targetEntries = $targetObj.sharedBlocks.PSObject.Properties[$name].Value

    $idsSource = Get-IdsDoBloco -Entries $sourceEntries
    $idsTarget = Get-IdsDoBloco -Entries $targetEntries

    if (-not (Equal-Sequence -A $idsSource -B $idsTarget)) {
        Write-Host "  FALHA divergencia: $name"
        Write-Host "    v2 : $($idsSource -join ',')"
        Write-Host "    v25: $($idsTarget -join ',')"
        $problems++
    }
}

if ($problems -gt 0) {
    Write-Host "Resultado: FALHA ($problems bloco(s) divergente(s))."
    exit 1
}

Write-Host "Resultado: OK. v25 esta sincronizada com v2 nos blocos comuns."
exit 0
