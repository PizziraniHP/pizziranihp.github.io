param(
    [int]$MinId = 300,
    [int]$MaxId = 699,
    [switch]$FailOnMissing
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$jsonPath = Join-Path $repoRoot 'dados/arvores-propagacao.json'
$indexPath = Join-Path $repoRoot 'paginas/saiba-mais/index.html'
$saibaDir = Join-Path $repoRoot 'paginas/saiba-mais'

if (-not (Test-Path $jsonPath)) { throw "Arquivo nao encontrado: $jsonPath" }
if (-not (Test-Path $indexPath)) { throw "Arquivo nao encontrado: $indexPath" }
if (-not (Test-Path $saibaDir)) { throw "Pasta nao encontrada: $saibaDir" }

$data = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

$ids = [System.Collections.Generic.HashSet[string]]::new()

function Add-IdsFromNode {
    param([object]$Node)

    if ($null -eq $Node) { return }

    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
        foreach ($item in $Node) {
            Add-IdsFromNode -Node $item
        }
        return
    }

    $props = $Node.PSObject.Properties
    if ($props.Name -contains 'id') {
        $id = [string]$Node.id
        if ($id -match '^\d{4}$') {
            $idNum = [int]$id
            if ($idNum -ge $MinId -and $idNum -le $MaxId) {
                [void]$ids.Add($id)
            }
        }
    }

    foreach ($prop in $props) {
        $value = $prop.Value
        if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            Add-IdsFromNode -Node $value
        } elseif ($value -is [pscustomobject]) {
            Add-IdsFromNode -Node $value
        }
    }
}

Add-IdsFromNode -Node $data

$indexHtml = Get-Content -Raw -Path $indexPath
$indexById = @{}
$hrefRegex = [regex]'href\s*=\s*"([^"]+)"'

foreach ($m in $hrefRegex.Matches($indexHtml)) {
    $href = [string]$m.Groups[1].Value
    if ([string]::IsNullOrWhiteSpace($href) -or $href -match 'index\.html$') { continue }

    $fileName = [System.IO.Path]::GetFileName($href)
    if ($fileName -match '^(\d{4})(?:[-_]|[A-Za-z])') {
        $id = $matches[1]
        if (-not $indexById.ContainsKey($id)) {
            $indexById[$id] = $fileName
        }
    }
}

$htmlFiles = Get-ChildItem -Path $saibaDir -File -Filter '*.html' | Select-Object -ExpandProperty Name

$rows = @(foreach ($id in ($ids | Sort-Object)) {
    $hasIndex = $indexById.ContainsKey($id)
    $matchingFiles = @($htmlFiles | Where-Object { $_ -match "^$id([-_]|[A-Za-z]).*\.html$" -or $_ -eq "$id.html" })
    $hasFile = $matchingFiles.Count -gt 0

    [pscustomobject]@{
        id = $id
        temIndice = $hasIndex
        arquivoIndice = if ($hasIndex) { $indexById[$id] } else { '' }
        temArquivo = $hasFile
        arquivoEncontrado = if ($hasFile) { ($matchingFiles -join '|') } else { '' }
    }
})

$semRota = @($rows | Where-Object { -not $_.temIndice -and -not $_.temArquivo })
$okSemIndice = @($rows | Where-Object { -not $_.temIndice -and $_.temArquivo })
$indiceSemArquivo = @($rows | Where-Object { $_.temIndice -and -not ($htmlFiles -contains $_.arquivoIndice) })

Write-Host "Auditoria Saiba Mais ($MinId-$MaxId)"
Write-Host "IDs analisados: $($rows.Count)"
Write-Host "Sem rota (nem indice nem arquivo): $($semRota.Count)"
Write-Host "Com arquivo, sem indice: $($okSemIndice.Count)"
Write-Host "Indice aponta para arquivo ausente: $($indiceSemArquivo.Count)"

if ($semRota.Count -gt 0) {
    Write-Host "`nIDs sem rota:"
    ($semRota | Select-Object id | Format-Table -AutoSize | Out-String).TrimEnd() | Write-Host
}

if ($okSemIndice.Count -gt 0) {
    Write-Host "`nIDs com arquivo mas sem indice:"
    ($okSemIndice | Select-Object id,arquivoEncontrado | Format-Table -AutoSize | Out-String).TrimEnd() | Write-Host
}

if ($indiceSemArquivo.Count -gt 0) {
    Write-Host "`nIDs com indice quebrado (arquivo nao existe):"
    ($indiceSemArquivo | Select-Object id,arquivoIndice | Format-Table -AutoSize | Out-String).TrimEnd() | Write-Host
}

if ($FailOnMissing -and ($semRota.Count -gt 0 -or $indiceSemArquivo.Count -gt 0)) {
    exit 1
}

exit 0
