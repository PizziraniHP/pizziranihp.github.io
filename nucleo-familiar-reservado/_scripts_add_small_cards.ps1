$files = Get-ChildItem "nucleo-familiar-reservado/saiba-mais" -File -Filter "*.html"

foreach ($f in $files) {
    $path = $f.FullName
    $content = Get-Content -Raw -LiteralPath $path
    $orig = $content

    if ($content -notmatch '<div class="extra-grid">') { continue }
    if ($content -match 'extra-grid-small') { continue }

    # 1) Add CSS for additional small cards.
    $content = [regex]::Replace(
        $content,
        '(?s)(\.extra-grid\s*\{[\s\S]*?\})',
        "$1`r`n        .extra-grid-small {`r`n            display: grid;`r`n            grid-template-columns: repeat(3, minmax(0, 1fr));`r`n            gap: 12px;`r`n            align-items: start;`r`n        }",
        1
    )

    $content = [regex]::Replace(
        $content,
        '(?s)(\.extra-item p\s*\{[\s\S]*?\})',
        "$1`r`n        .extra-item-small img {`r`n            aspect-ratio: 1 / 1;`r`n        }`r`n        .extra-item-small p {`r`n            padding: 8px 9px;`r`n            font-size: 12px;`r`n            line-height: 1.4;`r`n        }",
        1
    )

    $content = [regex]::Replace(
        $content,
        '@media \(max-width: 760px\) \{',
        "@media (max-width: 1080px) {`r`n            .extra-grid-small { grid-template-columns: repeat(2, minmax(0, 1fr)); }`r`n        }`r`n        @media (max-width: 760px) {",
        1
    )

    $content = $content -replace '(\.extra-grid\s*\{\s*grid-template-columns:\s*1fr;\s*\})', "$1`r`n            .extra-grid-small { grid-template-columns: 1fr; }"

    # 2) Duplicate existing extra cards into a new "small cards" section.
    $content = [regex]::Replace(
        $content,
        '(?s)(<section class="extra">[\s\S]*?<div class="extra-grid">)([\s\S]*?)(</div>[\s\S]*?</section>)(\s*<section class="story">)',
        {
            param($m)
            $extraStart = $m.Groups[1].Value
            $extraItems = $m.Groups[2].Value
            $extraEnd = $m.Groups[3].Value
            $storyTag = $m.Groups[4].Value

            $smallItems = $extraItems -replace 'class="extra-item"', 'class="extra-item extra-item-small"'
            $smallSection = @"
        <section class="extra extra-small">
            <h2>Fotos menores (adicionais)</h2>
            <div class="extra-grid-small">$smallItems
            </div>
        </section>
"@

            return $extraStart + $extraItems + $extraEnd + $smallSection + $storyTag
        },
        1
    )

    if ($content -ne $orig) {
        Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
        Write-Output "UPDATED: $($f.Name)"
    }
}

Write-Output "DONE"

