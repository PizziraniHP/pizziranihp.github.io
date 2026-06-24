$files = Get-ChildItem "nucleo-familiar-reservado/saiba-mais" -File -Filter "*.html"

$topoCss = @'
        .topo-fixo {
            position: fixed;
            right: 18px;
            bottom: 18px;
            z-index: 999;
            padding: 8px 12px;
            border-radius: 999px;
            border: 1px solid var(--line);
            background: #fffdf8;
            color: var(--accent);
            text-decoration: none;
            font-size: 13px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }
        .topo-fixo:hover {
            text-decoration: underline;
        }
'@

foreach ($f in $files) {
    $p = $f.FullName
    $c = Get-Content $p -Raw
    $orig = $c

    if ($c -notmatch 'scroll-behavior:\s*smooth') {
        $c = $c -replace '(\*\s*\{\s*box-sizing:\s*border-box;\s*\})', "$1`r`n        html { scroll-behavior: smooth; }"
    }

    if ($c -match '<body\s*>' ) {
        $c = $c -replace '<body\s*>', '<body id="topo">'
    }

    if ($c -notmatch '\.topo-fixo\s*\{') {
        if ($c -match '@media\s*\(max-width:\s*760px\)') {
            $c = $c -replace '(\s*@media\s*\(max-width:\s*760px\))', ($topoCss + '$1')
        } else {
            $c = $c -replace '(\s*</style>)', ($topoCss + '$1')
        }
    }

    if ($c -notmatch 'class="topo-fixo"') {
        $anchor = "`r`n    <a href=\"#topo\" class=\"topo-fixo\" aria-label=\"Voltar ao topo\">Topo</a>`r`n"
        $c = $c -replace '\s*</body>', ($anchor + '</body>')
    }

    if ($c -ne $orig) {
        Set-Content -Path $p -Value $c -Encoding UTF8
    }
}

Write-Output "OK"
