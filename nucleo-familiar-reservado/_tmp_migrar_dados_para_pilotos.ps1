Set-Location "c:\Users\Arnaldo Pizzirani\OneDrive\pizziranihp.github.io\pizziranihp.github.io"

$targets = @("gabriela", "lorena", "luna", "pedro")

function Get-GenBodyMatch {
    param(
        [string]$Text,
        [string]$Gen,
        [string]$NextGen
    )

    if ($NextGen) {
        $pattern = "(?s)(<!--[^\r\n]*0$Gen[^\r\n]*-->)(.*?)(?=<!--[^\r\n]*0$NextGen[^\r\n]*-->)"
    } else {
        $pattern = "(?s)(<!--[^\r\n]*07[^\r\n]*-->)(.*?)(?=</body>)"
    }

    return [regex]::Match($Text, $pattern)
}

function Update-OpenTagAttr {
    param(
        [string]$OpenTag,
        [string]$Attr,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $OpenTag
    }

    if ($OpenTag -match "$Attr=\"[^"]*\"") {
        return [regex]::Replace($OpenTag, "$Attr=\"[^"]*\"", "$Attr=\"$Value\"")
    }

    return $OpenTag.Replace(">", " $Attr=\"$Value\">")
}

function ParseCardData {
    param([string]$Card)

    $open = [regex]::Match($Card, "<div class=\"card-pessoa[^>]*>").Value
    $imgSrc = [regex]::Match($Card, "<img[^>]*src=\"([^\"]*)\"").Groups[1].Value
    $nome = [regex]::Match($Card, "<div class=\"nome\">([\s\S]*?)</div>").Groups[1].Value
    $det = [regex]::Match($Card, "<div class=\"detalhe\">([\s\S]*?)</div>").Groups[1].Value
    $pid = [regex]::Match($open, "data-person-id=\"([^\"]*)\"").Groups[1].Value
    $ppage = [regex]::Match($open, "data-person-page=\"([^\"]*)\"").Groups[1].Value

    return [pscustomobject]@{
        OpenTag = $open
        ImgSrc = $imgSrc
        Nome = $nome
        Detalhe = $det
        PersonId = $pid
        PersonPage = $ppage
    }
}

foreach ($slug in $targets) {
    $origPath = "nucleo-familiar-reservado/arvore-$slug/$slug.html"
    $pilotPath = "nucleo-familiar-reservado/arvore-$slug/$slug-piloto.html"

    $origText = Get-Content -Raw -LiteralPath $origPath
    $pilotText = Get-Content -Raw -LiteralPath $pilotPath

    $gens = @(
        @{G="02"; N="03"},
        @{G="03"; N="04"},
        @{G="04"; N="05"},
        @{G="05"; N="06"},
        @{G="06"; N="07"},
        @{G="07"; N=$null}
    )

    foreach ($g in $gens) {
        $mOrig = Get-GenBodyMatch -Text $origText -Gen $g.G -NextGen $g.N
        $mPilot = Get-GenBodyMatch -Text $pilotText -Gen $g.G -NextGen $g.N

        if (-not $mOrig.Success -or -not $mPilot.Success) {
            continue
        }

        $origBody = $mOrig.Groups[2].Value
        $pilotBody = $mPilot.Groups[2].Value

        $cardPattern = "(?s)<div class=\"card-pessoa[^>]*>\s*<img[^>]*>\s*<div class=\"nome\">.*?</div>\s*<div class=\"detalhe\">.*?</div>\s*</div>"
        $origCards = [regex]::Matches($origBody, $cardPattern)
        $pilotCards = [regex]::Matches($pilotBody, $cardPattern)

        if ($origCards.Count -eq 0 -or $pilotCards.Count -eq 0) {
            continue
        }

        $count = [Math]::Min($origCards.Count, $pilotCards.Count)
        $newCards = New-Object System.Collections.Generic.List[string]

        for ($i = 0; $i -lt $count; $i++) {
            $origData = ParseCardData -Card $origCards[$i].Value
            $pilotCard = $pilotCards[$i].Value

            $pilotOpen = [regex]::Match($pilotCard, "<div class=\"card-pessoa[^>]*>").Value
            $pilotOpen = Update-OpenTagAttr -OpenTag $pilotOpen -Attr "data-person-id" -Value $origData.PersonId
            $pilotOpen = Update-OpenTagAttr -OpenTag $pilotOpen -Attr "data-person-page" -Value $origData.PersonPage

            $newCard = $pilotCard
            $newCard = [regex]::Replace($newCard, "<div class=\"card-pessoa[^>]*>", [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $pilotOpen }, 1)
            if (-not [string]::IsNullOrWhiteSpace($origData.ImgSrc)) {
                $newCard = [regex]::Replace($newCard, "src=\"[^\"]*\"", "src=\"$($origData.ImgSrc)\"", 1)
            }
            $newCard = [regex]::Replace($newCard, "(<div class=\"nome\">)[\s\S]*?(</div>)", "$1$($origData.Nome)$2", 1)
            $newCard = [regex]::Replace($newCard, "(<div class=\"detalhe\">)[\s\S]*?(</div>)", "$1$($origData.Detalhe)$2", 1)

            $newCards.Add($newCard)
        }

        $idx = 0
        $newPilotBody = [regex]::Replace(
            $pilotBody,
            $cardPattern,
            [System.Text.RegularExpressions.MatchEvaluator]{
                param($m)
                if ($idx -lt $newCards.Count) {
                    $r = $newCards[$idx]
                    $idx++
                    return $r
                }
                return $m.Value
            }
        )

        $pilotText = $pilotText.Remove($mPilot.Groups[2].Index, $mPilot.Groups[2].Length).Insert($mPilot.Groups[2].Index, $newPilotBody)
    }

    Set-Content -LiteralPath $pilotPath -Value $pilotText -Encoding UTF8 -NoNewline
}

Write-Output "MIGRACAO_CONCLUIDA"
