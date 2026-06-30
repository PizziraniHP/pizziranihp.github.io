param(
    [string]$JsonPath = "nucleo-familiar-reservado/dados/pessoas.json"
)

$ErrorActionPreference = "Stop"
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-ValidationError {
    param([string]$Message)
    $errors.Add($Message)
}

function Add-ValidationWarning {
    param([string]$Message)
    $warnings.Add($Message)
}

if (-not (Test-Path -LiteralPath $JsonPath)) {
    Write-Host "ERRO: arquivo nao encontrado: $JsonPath" -ForegroundColor Red
    exit 2
}

try {
    $raw = Get-Content -Raw -LiteralPath $JsonPath -Encoding UTF8
    $data = $raw | ConvertFrom-Json -Depth 100
} catch {
    Write-Host "ERRO: JSON invalido em $JsonPath" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 2
}

if ($null -eq $data.people) {
    Write-Host "ERRO: campo people nao encontrado em $JsonPath" -ForegroundColor Red
    exit 2
}

$people = @($data.people)
if ($people.Count -eq 0) {
    Write-Host "ERRO: people esta vazio em $JsonPath" -ForegroundColor Red
    exit 2
}

$idSet = @{}

# Passo 1: validar ID e unicidade.
foreach ($p in $people) {
    $id = [string]$p.id
    if ([string]::IsNullOrWhiteSpace($id) -or $id -notmatch '^\d{4}$') {
        Add-ValidationError "ID invalido: '$id' (esperado 4 digitos)."
        continue
    }

    if ($idSet.ContainsKey($id)) {
        Add-ValidationError "ID duplicado: $id."
    } else {
        $idSet[$id] = $true
    }
}

# Passo 2: validar consistencia genealogica e campos obrigatorios.
foreach ($p in $people) {
    $id = [string]$p.id
    if ($id -notmatch '^\d{4}$') {
        continue
    }

    $nome = [string]$p.nome
    if ([string]::IsNullOrWhiteSpace($nome)) {
        Add-ValidationError "ID ${id}: nome obrigatorio vazio."
    }

    $codigo = [string]$p.codigoGenealogico
    $ramo = [string]$p.ramo
    $sexo = [string]$p.sexo

    if ($null -eq $p.geracao -or "$($p.geracao)" -notmatch '^\d+$') {
        Add-ValidationError "ID ${id}: geracao obrigatoria e numerica."
        continue
    }

    $geracao = [int]$p.geracao
    $geracaoEsperada = [int]$id.Substring(0, 2)
    $sufixoEsperado = [int]$id.Substring(1, 3)

    if ($geracao -ne $geracaoEsperada) {
        Add-ValidationError "ID ${id}: geracao=$geracao, esperado=$geracaoEsperada pelo ID."
    }

    if ([string]::IsNullOrWhiteSpace($codigo)) {
        Add-ValidationError "ID ${id}: codigoGenealogico obrigatorio."
    }

    if ([string]::IsNullOrWhiteSpace($ramo) -or $ramo -notmatch '^[PMN]$') {
        Add-ValidationError "ID ${id}: ramo invalido '$ramo' (usar P, M ou N)."
    }

    if ([string]::IsNullOrWhiteSpace($sexo) -or $sexo -notmatch '^[MFN]$') {
        Add-ValidationError "ID ${id}: sexo invalido '$sexo' (usar M, F ou N)."
    }

    if ($geracaoEsperada -eq 1) {
        if ($codigo -notmatch '^G1B-(\d{3})$') {
            Add-ValidationError "ID ${id}: codigoGenealogico '$codigo' invalido para G1 (esperado G1B-xxx)."
        } else {
            $sufixoCodigo = [int]$Matches[1]
            if ($sufixoCodigo -ne $sufixoEsperado) {
                Add-ValidationError "ID ${id}: sufixo do codigo ($sufixoCodigo) difere do ID ($sufixoEsperado)."
            }
        }

        if ($ramo -ne 'N') {
            Add-ValidationError "ID ${id}: G1 deve usar ramo N."
        }
        if ($sexo -ne 'N') {
            Add-ValidationError "ID ${id}: G1 deve usar sexo N."
        }
    } else {
        $padrao = '^G' + $geracaoEsperada + '(PP|PM)-(\d{3})$'
        if ($codigo -notmatch $padrao) {
            Add-ValidationError "ID ${id}: codigoGenealogico '$codigo' invalido para G$geracaoEsperada (esperado G$geracaoEsperadaPP-xxx ou G$geracaoEsperadaPM-xxx)."
        } else {
            $tipo = $Matches[1]
            $sufixoCodigo = [int]$Matches[2]

            if ($sufixoCodigo -ne $sufixoEsperado) {
                Add-ValidationError "ID ${id}: sufixo do codigo ($sufixoCodigo) difere do ID ($sufixoEsperado)."
            }

            if ($tipo -eq 'PP') {
                if ($ramo -ne 'P') { Add-ValidationError "ID ${id}: codigo PP exige ramo P." }
                if ($sexo -ne 'M') { Add-ValidationError "ID ${id}: codigo PP exige sexo M." }
            }
            if ($tipo -eq 'PM') {
                if ($ramo -ne 'M') { Add-ValidationError "ID ${id}: codigo PM exige ramo M." }
                if ($sexo -ne 'F') { Add-ValidationError "ID ${id}: codigo PM exige sexo F." }
            }
        }
    }

    foreach ($campoResp in @('responsavel1', 'responsavel2')) {
        if ($p.PSObject.Properties.Name -contains $campoResp) {
            $resp = [string]$p.$campoResp
            if (-not [string]::IsNullOrWhiteSpace($resp)) {
                if ($resp -notmatch '^\d{4}$') {
                    Add-ValidationError "ID ${id}: ${campoResp}='$resp' invalido (usar 4 digitos)."
                } elseif (-not $idSet.ContainsKey($resp)) {
                    Add-ValidationWarning "ID ${id}: ${campoResp}='$resp' ainda nao existe no cadastro."
                }
            }
        }
    }
}

Write-Host "\nVALIDACAO: $JsonPath"
Write-Host "Registros avaliados: $($people.Count)"
Write-Host "Erros: $($errors.Count)"
Write-Host "Avisos: $($warnings.Count)"

if ($warnings.Count -gt 0) {
    Write-Host "\nAvisos:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }
}

if ($errors.Count -gt 0) {
    Write-Host "\nErros:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}

Write-Host "\nOK: cadastro consistente com o padrao." -ForegroundColor Green
exit 0
