param(
    [int]$MinId = 300,
    [int]$MaxId = 699,
    [switch]$FailOnMissing,
    [switch]$FailOnExplicitMissing
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$indexPath = Join-Path $repoRoot 'paginas/saiba-mais/index.html'
$saibaDir = Join-Path $repoRoot 'paginas/saiba-mais'

if (-not (Test-Path $indexPath)) { throw "Arquivo nao encontrado: $indexPath" }
if (-not (Test-Path $saibaDir)) { throw "Pasta nao encontrada: $saibaDir" }

$individualJsonFiles = @(Get-ChildItem -Path (Join-Path $repoRoot 'dados') -File -Filter 'arvore-*-individual.json' | Sort-Object Name)

$ids = [System.Collections.Generic.HashSet[string]]::new()
$explicitLinks = New-Object System.Collections.Generic.List[object]

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

function Add-ExplicitLinksFromNode {
    param(
        [object]$Node,
        [string]$JsonFileName
    )

    if ($null -eq $Node) { return }

    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
        foreach ($item in $Node) {
            Add-ExplicitLinksFromNode -Node $item -JsonFileName $JsonFileName
        }
        return
    }

    $props = $Node.PSObject.Properties
    if ($props.Name -contains 'saibamaislink') {
        $link = [string]$Node.saibamaislink
        if (-not [string]::IsNullOrWhiteSpace($link)) {
            $id = ''
            if ($props.Name -contains 'id') {
                $id = [string]$Node.id
            }

            $explicitLinks.Add([pscustomobject]@{
                id = $id
                json = $JsonFileName
                link = $link
            }) | Out-Null
        }
    }

    foreach ($prop in $props) {
        $value = $prop.Value
        if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            Add-ExplicitLinksFromNode -Node $value -JsonFileName $JsonFileName
        } elseif ($value -is [pscustomobject]) {
            Add-ExplicitLinksFromNode -Node $value -JsonFileName $JsonFileName
        }
    }
}

foreach ($jsonFile in $individualJsonFiles) {
    $jsonObj = Get-Content -Raw -Path $jsonFile.FullName | ConvertFrom-Json
    Add-IdsFromNode -Node $jsonObj
    Add-ExplicitLinksFromNode -Node $jsonObj -JsonFileName $jsonFile.Name
}

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

function Resolve-ExplicitHref {
    param([string]$RawLink)

    $raw = ([string]$RawLink).Trim()
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return ''
    }

    if ($raw -match '^paginas/saiba-mais/') {
        return ($raw -replace '^paginas/', '')
    }

    if ($raw -match '^(https?:|file:|/|\.{1,2}/)') {
        return $raw
    }

    if ($raw -match '^saiba-mais/') {
        return $raw
    }

    return ('saiba-mais/' + $raw)
}

$explicitRows = @(foreach ($entry in $explicitLinks) {
    $rawLink = ([string]$entry.link).Trim()
    $resolvedHref = Resolve-ExplicitHref -RawLink (($rawLink -replace '\\', '/').Split('?')[0].Split('#')[0])
    $isExternal = $resolvedHref -match '^(https?:|file:|//)'

    if ($isExternal) {
        $fullPath = ''
        $exists = $true
    } elseif ($resolvedHref.StartsWith('/')) {
        $fullPath = Join-Path $repoRoot ($resolvedHref.TrimStart('/'))
        $exists = Test-Path -LiteralPath $fullPath
    } else {
        $basePageDir = Join-Path $repoRoot 'paginas'
        $fullPath = [System.IO.Path]::GetFullPath((Join-Path $basePageDir $resolvedHref))
        $exists = Test-Path -LiteralPath $fullPath
    }

    [pscustomobject]@{
        id = [string]$entry.id
        json = [string]$entry.json
        link = $rawLink
        hrefResolvido = $resolvedHref
        externo = $isExternal
        existe = $exists
    }
})

$explicitMissing = @($explicitRows | Where-Object { -not $_.externo -and -not $_.existe })

Write-Host "Auditoria Saiba Mais ($MinId-$MaxId)"
Write-Host "IDs analisados: $($rows.Count)"
Write-Host "Sem rota (nem indice nem arquivo): $($semRota.Count)"
Write-Host "Com arquivo, sem indice: $($okSemIndice.Count)"
Write-Host "Indice aponta para arquivo ausente: $($indiceSemArquivo.Count)"
Write-Host "Links explicitos auditados (saibamaislink): $($explicitRows.Count)"
Write-Host "Links explicitos com arquivo ausente: $($explicitMissing.Count)"

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

if ($explicitMissing.Count -gt 0) {
    Write-Host "`nLinks explicitos quebrados (saibamaislink):"
    ($explicitMissing | Select-Object id,json,link,hrefResolvido | Format-Table -AutoSize | Out-String).TrimEnd() | Write-Host
}

if ($FailOnMissing -and ($semRota.Count -gt 0 -or $indiceSemArquivo.Count -gt 0)) {
    exit 1
}

if ($FailOnExplicitMissing -and $explicitMissing.Count -gt 0) {
    exit 1
}

exit 0
