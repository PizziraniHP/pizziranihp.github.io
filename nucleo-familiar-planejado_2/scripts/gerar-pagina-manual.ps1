param(
  [Parameter(Mandatory = $true)][string]$TreeKey,
  [switch]$FullSlots,
  [string]$DataFile,
  [string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($DataFile)) {
  $candidate = Join-Path $repoRoot ("dados/arvore-{0}-individual.json" -f $TreeKey)
  if (Test-Path $candidate) {
    $DataFile = $candidate
  } else {
    $DataFile = Join-Path $repoRoot "dados/arvores-propagacao.json"
  }
} else {
  $DataFile = Join-Path $repoRoot $DataFile
}

if ([string]::IsNullOrWhiteSpace($OutFile)) {
  $OutFile = Join-Path $repoRoot ("paginas/manual/{0}-manual.html" -f $TreeKey)
} else {
  $OutFile = Join-Path $repoRoot $OutFile
}

if (!(Test-Path $DataFile)) {
  throw "Arquivo de dados nao encontrado: $DataFile"
}

$data = Get-Content -Raw -Encoding UTF8 $DataFile | ConvertFrom-Json
if (!($data.trees.PSObject.Properties.Name -contains $TreeKey)) {
  throw "Arvore '$TreeKey' nao encontrada em $DataFile"
}

$tree = $data.trees.$TreeKey
$shared = $data.sharedBlocks
$saibaMaisDir = Join-Path $repoRoot "paginas/saiba-mais"

function Get-SaibaMaisMap {
  param([string]$Dir)

  $map = @{}
  if (!(Test-Path $Dir)) {
    return $map
  }

  $files = Get-ChildItem -Path $Dir -File -Filter "*.html"
  foreach ($f in $files) {
    if ($f.Name -match '^(\d{4})(?:[-_].*)?\.html$') {
      $id = $Matches[1]
      # Mantem o primeiro match encontrado para o ID.
      if (-not $map.ContainsKey($id)) {
        $map[$id] = ("paginas/saiba-mais/{0}" -f $f.Name)
      }
    }
  }

  return $map
}

$saibaMaisMap = Get-SaibaMaisMap -Dir $saibaMaisDir

function Expand-Entries {
  param($entries, $sharedBlocks)
  $out = @()
  foreach ($e in @($entries)) {
    if ($null -eq $e) { continue }
    if ($e.PSObject.Properties.Name -contains '$ref') {
      $ref = [string]$e.'$ref'
      if ($sharedBlocks -and ($sharedBlocks.PSObject.Properties.Name -contains $ref)) {
        $out += Expand-Entries -entries $sharedBlocks.$ref -sharedBlocks $sharedBlocks
      }
      continue
    }
    $out += $e
  }
  return ,$out
}

function Get-SlotCount {
  param([int]$g, [int]$existing, [switch]$useFull)
  if ($useFull) { return [math]::Pow(2, $g - 1) }
  if ($existing -gt 0) { return $existing }
  return [math]::Pow(2, $g - 1)
}

function Get-LineageClass {
  param($ramo)
  if ($ramo -eq 'paterno') { return 'lp' }
  if ($ramo -eq 'materno') { return 'lm' }
  return 'c'
}

function ConvertTo-HtmlEscaped {
  param([string]$s)
  if ($null -eq $s) { return '' }
  return [System.Net.WebUtility]::HtmlEncode($s)
}

$html = New-Object System.Text.StringBuilder
[void]$html.AppendLine('<!DOCTYPE html>')
[void]$html.AppendLine('<html lang="pt-BR">')
[void]$html.AppendLine('<head>')
[void]$html.AppendLine('  <meta charset="UTF-8">')
[void]$html.AppendLine('  <meta name="robots" content="noindex,nofollow">')
[void]$html.AppendLine('  <title>Manual - ' + (ConvertTo-HtmlEscaped $TreeKey) + '</title>')
[void]$html.AppendLine('  <link rel="stylesheet" href="manual-arvore.css">')
[void]$html.AppendLine('</head>')
[void]$html.AppendLine('<body>')
[void]$html.AppendLine('  <div class="container">')
[void]$html.AppendLine('    <header>')
[void]$html.AppendLine('      <h1>Modo Manual Primitivo - ' + (ConvertTo-HtmlEscaped $tree.titulo) + '</h1>')
[void]$html.AppendLine('      <div class="sub">Edicao manual direta no HTML. Sem propagacao automatica nesta pagina.</div>')
[void]$html.AppendLine('    </header>')
[void]$html.AppendLine('    <div class="legenda">Cada slot mostra: CODIGO, ID, NOME, RAMO, FOTO, SAIBA_MAIS e ENDERECO. Edite os valores diretamente no codigo-fonte desta pagina.</div>')
[void]$html.AppendLine('    <div class="legenda">Importante: digite apenas texto/URL nos campos. Nao insira tags HTML dentro dos valores (ex.: &lt;div&gt;, &lt;a&gt;), para nao quebrar a pagina.</div>')

for ($g = 1; $g -le 8; $g++) {
  $gk = "g$g"
  $expanded = Expand-Entries -entries $tree.$gk -sharedBlocks $shared
  $existing = @($expanded).Count
  $slots = [int](Get-SlotCount -g $g -existing $existing -useFull:$FullSlots)

  $cols = $slots
  if ($cols -gt 16) { $cols = 16 }
  if ($cols -lt 1) { $cols = 1 }

  [void]$html.AppendLine('    <section class="geracao">')
  [void]$html.AppendLine('      <div class="geracao-head"><span>Geracao G' + $g + '</span><span>Slots: ' + $slots + ' | Preenchidos: ' + $existing + '</span></div>')
  [void]$html.AppendLine('      <div class="slots" style="--cols:' + $cols + '">')

  for ($i = 0; $i -lt $slots; $i++) {
    $slot = $null
    if ($i -lt $existing) { $slot = $expanded[$i] }

    $id = ''
    $nome = ''
    $ramo = ''
    $imagem = ''
    $saiba = ''
    $endereco = ''

    if ($slot) {
      $id = [string]$slot.id
      $nome = [string]$slot.nome
      $ramo = [string]$slot.ramo
      $imagem = [string]$slot.imagem
      if ($id -match '^\d{4}$') {
        if ($saibaMaisMap.ContainsKey($id)) {
          $saiba = [string]$saibaMaisMap[$id]
        } else {
          $saiba = 'paginas/saiba-mais/' + $id + '.html'
        }
      }
    }

    $slotCode = ('G{0}-SLOT-{1:d3}' -f $g, ($i + 1))
    $cls = Get-LineageClass -ramo $ramo
    if ([string]::IsNullOrWhiteSpace($ramo)) { $cls = 'c' }
    $vazio = [string]::IsNullOrWhiteSpace($nome)
    $imgHref = ''
    if (![string]::IsNullOrWhiteSpace($imagem)) {
      $imgHref = '../../' + $imagem.TrimStart('/')
    }

    $saibaHref = ''
    if (![string]::IsNullOrWhiteSpace($saiba)) {
      $saibaHref = '../../' + $saiba.TrimStart('/')
    }


    [void]$html.AppendLine('        <article class="slot ' + $cls + '">')
    [void]$html.AppendLine('          <div class="slot-code">' + $slotCode + '</div>')
    [void]$html.AppendLine('          <div class="meta">ID: ' + (ConvertTo-HtmlEscaped $id) + '</div>')
    [void]$html.AppendLine('          <div class="meta">NOME: ' + (ConvertTo-HtmlEscaped $nome) + '</div>')
    [void]$html.AppendLine('          <div class="meta">RAMO: ' + (ConvertTo-HtmlEscaped $ramo) + '</div>')
    [void]$html.AppendLine('          <div class="meta">FOTO: ' + (ConvertTo-HtmlEscaped $imagem) + '</div>')
    if (![string]::IsNullOrWhiteSpace($imgHref)) {
      [void]$html.AppendLine('          <div class="meta">FOTO_PREVIEW: <a href="' + (ConvertTo-HtmlEscaped $imgHref) + '" target="_blank" rel="noopener">abrir foto</a></div>')
      [void]$html.AppendLine('          <div class="thumb"><img src="' + (ConvertTo-HtmlEscaped $imgHref) + '" alt="' + (ConvertTo-HtmlEscaped $nome) + '"></div>')
    }
    [void]$html.AppendLine('          <div class="meta">SAIBA_MAIS: ' + (ConvertTo-HtmlEscaped $saiba) + '</div>')
    if (![string]::IsNullOrWhiteSpace($saibaHref)) {
      [void]$html.AppendLine('          <div class="meta">SAIBA_MAIS_LINK: <a href="' + (ConvertTo-HtmlEscaped $saibaHref) + '" target="_blank" rel="noopener">abrir pagina</a></div>')
    }
    [void]$html.AppendLine('          <div class="meta">ENDERECO: ' + (ConvertTo-HtmlEscaped $endereco) + '</div>')
    if ($vazio) {
      [void]$html.AppendLine('          <div class="meta vazio">slot vazio para cadastro manual</div>')
    }
    [void]$html.AppendLine('        </article>')
  }

  [void]$html.AppendLine('      </div>')
  [void]$html.AppendLine('    </section>')
}

[void]$html.AppendLine('  </div>')
[void]$html.AppendLine('</body>')
[void]$html.AppendLine('</html>')

$outDir = Split-Path -Parent $OutFile
if (!(Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, $html.ToString(), $utf8NoBom)

Write-Host "OK_MANUAL_PAGE: $OutFile"
