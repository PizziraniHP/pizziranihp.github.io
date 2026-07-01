$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dirs = Get-ChildItem $root -Directory | Where-Object { $_.Name -like 'arvore-*' }

function Get-Cards {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $raw = Get-Content -Raw -Path $Path
    $cards = [regex]::Matches($raw, '<div class="card-pessoa[\s\S]*?</div>\s*</div>')

    $out = @()
    foreach ($c in $cards) {
        $block = $c.Value
        $id = ''
        $name = ''

        $idMatch = [regex]::Match($block, 'data-person-id="([0-9]+)"')
        if ($idMatch.Success) {
            $id = $idMatch.Groups[1].Value
        }

        $nameMatch = [regex]::Match($block, '<div class="nome">\s*([^<]+?)\s*</div>')
        if ($nameMatch.Success) {
            $name = $nameMatch.Groups[1].Value.Trim()
        }

        if ($id -ne '') {
            $out += [pscustomobject]@{
                Id = $id
                Nome = $name
            }
        }
    }

    return $out
}

$summary = @()

foreach ($d in $dirs) {
    $baseName = $d.Name -replace '^arvore-', ''
    $main = Join-Path $d.FullName ($baseName + '.html')
    $pilot = Join-Path $d.FullName ($baseName + '-piloto.html')

    if (-not (Test-Path $main) -or -not (Test-Path $pilot)) {
        continue
    }

    $mCards = Get-Cards -Path $main
    $pCards = Get-Cards -Path $pilot

    $mIds = $mCards.Id | Sort-Object -Unique
    $pIds = $pCards.Id | Sort-Object -Unique

    $onlyMain = Compare-Object -ReferenceObject $mIds -DifferenceObject $pIds -PassThru | Where-Object { $_ -in $mIds }
    $onlyPilot = Compare-Object -ReferenceObject $mIds -DifferenceObject $pIds -PassThru | Where-Object { $_ -in $pIds }

    $nameDiffs = @()
    $common = $mIds | Where-Object { $pIds -contains $_ }
    foreach ($id in $common) {
        $mainName = ($mCards | Where-Object { $_.Id -eq $id } | Select-Object -First 1).Nome
        $pilotName = ($pCards | Where-Object { $_.Id -eq $id } | Select-Object -First 1).Nome

        if ($mainName -ne $pilotName) {
            $nameDiffs += [pscustomobject]@{
                Id = $id
                Main = $mainName
                Piloto = $pilotName
            }
        }
    }

    $summary += [pscustomobject]@{
        Arvore = $baseName
        SoMain = ($onlyMain -join ', ')
        SoPiloto = ($onlyPilot -join ', ')
        QtNomesDiferentes = $nameDiffs.Count
    }

    if ($nameDiffs.Count -gt 0) {
        Write-Host "=== NOMES DIFERENTES: $baseName ==="
        $nameDiffs | Sort-Object Id | Format-Table -AutoSize
        Write-Host ''
    }
}

Write-Host '=== RESUMO GERAL MAIN x PILOTO ==='
$summary | Sort-Object Arvore | Format-Table -AutoSize
