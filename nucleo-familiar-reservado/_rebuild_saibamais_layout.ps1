$files = Get-ChildItem "nucleo-familiar-reservado/saiba-mais" -File -Filter "*.html"

$style = @'
        :root {
            --bg: #f7f5ef;
            --panel: #ffffff;
            --ink: #222222;
            --muted: #666666;
            --line: #ddd7ca;
            --accent: #7a2e2e;
        }
        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body {
            margin: 0;
            font-family: Georgia, "Times New Roman", serif;
            color: var(--ink);
            background: radial-gradient(circle at top right, #efe8d8, var(--bg) 45%);
            line-height: 1.55;
        }
        .page {
            width: min(980px, 92vw);
            margin: 32px auto;
            padding: 24px;
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 14px;
            box-shadow: 0 10px 28px rgba(0, 0, 0, 0.08);
        }
        .top-links {
            margin: 0 0 18px;
            font-size: 14px;
            color: var(--muted);
        }
        .top-links a {
            color: var(--accent);
            text-decoration: none;
        }
        .top-links a:hover { text-decoration: underline; }
        .hero {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 22px;
            align-items: start;
            margin-bottom: 20px;
        }
        .photo-box {
            background: #f2efe5;
            border: 1px solid var(--line);
            border-radius: 10px;
            overflow: hidden;
        }
        .photo-box img {
            display: block;
            width: 100%;
            height: auto;
        }
        .meta h1 {
            margin: 0 0 8px;
            font-size: clamp(28px, 4vw, 42px);
            line-height: 1.08;
        }
        .meta .chip {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 999px;
            border: 1px solid var(--line);
            color: var(--muted);
            font-size: 12px;
            margin-bottom: 10px;
        }
        .meta p { margin: 6px 0; }
        .extra {
            border-top: 1px solid var(--line);
            padding-top: 16px;
            margin-bottom: 20px;
        }
        .extra h2 {
            margin: 0 0 12px;
            font-size: 22px;
        }
        .extra-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 14px;
        }
        .extra-item {
            border: 1px solid var(--line);
            border-radius: 10px;
            overflow: hidden;
            background: #faf8f3;
        }
        .extra-item img {
            display: block;
            width: 100%;
            height: auto;
        }
        .extra-item p {
            margin: 0;
            padding: 10px 12px;
            font-size: 14px;
            color: var(--muted);
        }
        .story {
            border-top: 1px solid var(--line);
            padding-top: 16px;
        }
        .story h2 {
            margin: 0 0 10px;
            font-size: 22px;
        }
        .story p {
            margin: 0 0 12px;
            text-align: justify;
        }
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
        @media (max-width: 760px) {
            .hero { grid-template-columns: 1fr; }
            .photo-box { max-width: 320px; }
        }
'@

foreach ($f in $files) {
    $path = $f.FullName
    $content = Get-Content $path -Raw

    $titleMatch = [regex]::Match($content, '<title>(.*?)</title>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $titleMatch.Success) { continue }
    $title = $titleMatch.Groups[1].Value.Trim()

    $mainMatch = [regex]::Match($content, '<main class="page">[\s\S]*?</main>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $mainMatch.Success) { continue }
    $mainHtml = $mainMatch.Value

    $newContent = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex,nofollow">
    <title>$title</title>
    <style>
$style    </style>
</head>
<body id="topo">
$mainHtml
    <a href="#topo" class="topo-fixo" aria-label="Voltar ao topo">Topo</a>
</body>
</html>
"@

    Set-Content -Path $path -Value $newContent -Encoding UTF8
}

Write-Output "OK"
