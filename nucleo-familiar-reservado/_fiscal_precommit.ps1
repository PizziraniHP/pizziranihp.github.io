param(
    [switch]$ValidateAll
)

$ErrorActionPreference = 'Stop'

function Get-StagedFiles {
    $output = git diff --cached --name-only --diff-filter=ACM
    if (-not $output) { return @() }
    return $output -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

function Resolve-RepoPath([string]$relativePath) {
    return Join-Path (Get-Location).Path $relativePath
}

function Normalize-PersonId([string]$rawId) {
    $digits = [regex]::Replace([string]$rawId, '\D', '')
    if (-not $digits) {
        return ''
    }
    if ($digits.Length -ge 4) {
        return $digits.Substring(0, 4)
    }
    return $digits.PadLeft(4, '0')
}

function Get-ExpectedClasses([string]$normalizedId) {
    $generation = $normalizedId.Substring(0, 2)
    switch ($generation) {
        '01' { return @('card-bisneta', 'card-bisneto') }
        '02' { return @('card-pais') }
        '03' { return @('card-avos') }
        '04' { return @('card-bisavos') }
        '05' { return @('card-trisavos') }
        '06' { return @('card-tataravos') }
        '07' { return @('card-tataravos') }
        '08' { return @('card-tataravos') }
        default { return @() }
    }
}

function Is-PlaceholderCard([string]$cardHtml) {
    if ($cardHtml -match 'src="\.\./imagens/"') {
        return $true
    }
    if ($cardHtml -match 'Espaco|Espaço|Informacoes|Informações|Pentavo / Pentavo|Hexavo / Hexava|Tetravo / Tetravo') {
        return $true
    }
    return $false
}

function Test-CardRules([string]$relativePath) {
    $errors = @()
    $fullPath = Resolve-RepoPath $relativePath

    if (-not (Test-Path $fullPath)) {
        return $errors
    }

    $content = Get-Content -Path $fullPath -Raw -Encoding UTF8
    $pattern = '<div\s+class="([^"]*card-pessoa[^"]*)"([^>]*)data-person-id="(\d{3,4})"([^>]*)>([\s\S]*?)</div>'
    $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    foreach ($m in $matches) {
        $classes = ($m.Groups[1].Value + ' ' + $m.Groups[2].Value + ' ' + $m.Groups[4].Value)
        $rawId = $m.Groups[3].Value
        $id = Normalize-PersonId $rawId
        if (-not $id) {
            continue
        }

        if (Is-PlaceholderCard $m.Value) {
            continue
        }

        $expected = Get-ExpectedClasses $id
        if ($expected.Count -gt 0) {
            $okClass = $false
            foreach ($c in $expected) {
                if ($classes -match ("\b" + [regex]::Escape($c) + "\b")) {
                    $okClass = $true
                    break
                }
            }
            if (-not $okClass) {
                $errors += "$relativePath :: ID $id com classe divergente. Esperado: $($expected -join ' ou ')."
            }
        }

        if ($id.Substring(0, 2) -eq '06' -and $m.Value -notmatch 'class="[^"]*foto-tetravos[^"]*"') {
            $errors += "$relativePath :: ID $id (geracao 06) deve usar imagem com classe foto-tetravos."
        }

        if (($id.Substring(0, 2) -eq '07' -or $id.Substring(0, 2) -eq '08') -and $m.Value -notmatch 'class="[^"]*foto-hexaavos[^"]*"') {
            $errors += "$relativePath :: ID $id (geracao 07/08) deve usar imagem com classe foto-hexaavos."
        }

        $pageMatch = [regex]::Match($m.Value, 'data-person-page="([^"]+)"', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($pageMatch.Success) {
            $pageRel = $pageMatch.Groups[1].Value
            $baseDir = Split-Path -Path $fullPath -Parent
            $target = [System.IO.Path]::GetFullPath((Join-Path $baseDir $pageRel))
            if (-not (Test-Path $target)) {
                $errors += "$relativePath :: ID $id com data-person-page invalido: $pageRel"
            }
        }
    }

    return $errors
}

function Test-PeopleJsonRules([string]$relativePath) {
    $errors = @()
    $fullPath = Resolve-RepoPath $relativePath

    if (-not (Test-Path $fullPath)) {
        return $errors
    }

    $content = Get-Content -Path $fullPath -Raw -Encoding UTF8
    $sanitized = [regex]::Replace($content, '/\*[\s\S]*?\*/', '')

    try {
        $json = $sanitized | ConvertFrom-Json -ErrorAction Stop
    } catch {
        $errors += "$relativePath :: JSON invalido para validacao de regras genealogicas."
        return $errors
    }

    $people = @($json.people)
    foreach ($p in $people) {
        $id = Normalize-PersonId([string]$p.id)
        if (-not $id) {
            continue
        }

        $code = [string]$p.codigoGenealogico
        if (-not $code) {
            continue
        }

        if ($code -notmatch '^G\d+[A-Z]{1,3}-\d{4}$') {
            $errors += "$relativePath :: ID $id com codigoGenealogico fora do padrao alfa-numerico (ex.: G2PP-0201)."
            continue
        }

        if ($code -notmatch ('-' + [regex]::Escape($id) + '$')) {
            $errors += "$relativePath :: ID $id com codigoGenealogico inconsistente com o proprio ID (esperado sufixo -$id)."
        }
    }

    return $errors
}

if ($ValidateAll) {
    $treeHtmlFiles = Get-ChildItem -Path 'nucleo-familiar-reservado' -Recurse -File |
        Where-Object { $_.FullName -match 'arvore-[^\\/]+[\\/].+\.html$' } |
        ForEach-Object {
            $full = $_.FullName.Replace('\\', '/')
            $root = (Get-Location).Path.Replace('\\', '/') + '/'
            $full.Replace($root, '')
        }
} else {
    $stagedFiles = Get-StagedFiles
    if (-not $stagedFiles.Count) {
        exit 0
    }

    $treeHtmlFiles = $stagedFiles | Where-Object {
        $_ -match '^nucleo-familiar-reservado/arvore-[^/]+/.+\.html$'
    }
}

if (-not $treeHtmlFiles.Count) {
    if (-not $ValidateAll) {
        $stagedFiles = Get-StagedFiles
    }
}

$allErrors = @()
foreach ($file in $treeHtmlFiles) {
    $allErrors += Test-CardRules -relativePath $file
}

$shouldValidatePeopleJson = $ValidateAll
if (-not $shouldValidatePeopleJson) {
    $shouldValidatePeopleJson = $stagedFiles -contains 'nucleo-familiar-reservado/dados/pessoas.json'
}

if ($shouldValidatePeopleJson) {
    $allErrors += Test-PeopleJsonRules -relativePath 'nucleo-familiar-reservado/dados/pessoas.json'
}

if (-not $treeHtmlFiles.Count -and -not $shouldValidatePeopleJson) {
    exit 0
}

if ($allErrors.Count -gt 0) {
    Write-Host ''
    Write-Host 'FISCAL PRE-COMMIT: insercao genealogica inconsistente.' -ForegroundColor Red
    Write-Host 'Corrija os itens abaixo e tente o commit novamente:' -ForegroundColor Yellow
    foreach ($err in $allErrors) {
        Write-Host " - $err" -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host 'Referencia: nucleo-familiar-reservado/CHECKLIST_INSERCAO_GERACAO.md' -ForegroundColor Cyan
    exit 1
}

exit 0
