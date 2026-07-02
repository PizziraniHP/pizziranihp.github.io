Set-Location "c:\Users\Arnaldo Pizzirani\OneDrive\pizziranihp.github.io\pizziranihp.github.io"

$source = "nucleo-familiar-reservado/arvore-alice/alice-piloto.html"
$targets = @(
    @{ Slug = "gabriela"; Nome = "Gabriela"; Id = "0106"; Saibamais = "0106-gabriela.html"; Imagem = "0106_gabriela_v01.jpeg"; Genero = "f" },
    @{ Slug = "lorena"; Nome = "Lorena"; Id = "0101"; Saibamais = "0101-lorena.html"; Imagem = "0101_lorena_v01.jpeg"; Genero = "f" },
    @{ Slug = "luna"; Nome = "Luna"; Id = "0105"; Saibamais = "0105-luna.html"; Imagem = "0105_luna_v01.jpeg"; Genero = "f" },
    @{ Slug = "pedro"; Nome = "Pedro"; Id = "0103"; Saibamais = "0103-pedro.html"; Imagem = "0103_pedro_v01.jpeg"; Genero = "m" }
)

foreach ($t in $targets) {
    $dest = "nucleo-familiar-reservado/arvore-$($t.Slug)/$($t.Slug)-piloto.html"
    Copy-Item -LiteralPath $source -Destination $dest -Force

    $c = Get-Content -Raw -LiteralPath $dest

    $h1Prefix = if ($t.Genero -eq "f") { "Bisneta" } else { "Bisneto" }
    $h2Suffix = if ($t.Genero -eq "f") { "bisneta" } else { "bisneto" }
    $baseLinha = if ($t.Genero -eq "f") { "Base da pirâmide – Bisneta (1)" } else { "Base da pirâmide – Bisneto (1)" }

    $c = $c.Replace("<title>Alice - Arvore Genealogica [PILOTO visual]</title>", "<title>$($t.Nome) - Arvore Genealogica [PILOTO visual]</title>")
    $c = $c.Replace("<h1>Bisneta Alice – Pirâmide da Família <span class=\"badge-piloto\">PILOTO VISUAL</span></h1>", "<h1>$h1Prefix $($t.Nome) – Pirâmide da Família <span class=\"badge-piloto\">PILOTO VISUAL</span></h1>")
    $c = $c.Replace("<h2>\"Um universo de ancestrais visto a partir da bisneta Alice\"</h2>", "<h2>\"Um universo de ancestrais visto a partir da $h2Suffix $($t.Nome)\"</h2>")
    $c = $c.Replace("<a href=\"alice.html\">versão atual (sem piloto)</a>", "<a href=\"$($t.Slug).html\">versão atual (sem piloto)</a>")
    $c = $c.Replace("<span><strong>Alice</strong> – base da pirâmide</span>", "<span><strong>$($t.Nome)</strong> – base da pirâmide</span>")
    $c = $c.Replace("<!-- ========== GERAÇÃO 01 - BASE (ALICE) ========== -->", "<!-- ========== GERAÇÃO 01 - BASE ($($t.Nome.ToUpper())) ========== -->")
    $c = $c.Replace("data-person-id=\"0102\" data-person-page=\"../saiba-mais/0102-alice.html\"", "data-person-id=\"$($t.Id)\" data-person-page=\"../saiba-mais/$($t.Saibamais)\"")
    $c = $c.Replace("src=\"../imagens/bisnetos/0102_alice_v01.jpeg\"", "src=\"../imagens/bisnetos/$($t.Imagem)\"")
    $c = $c.Replace("<div class=\"nome\">Alice</div>", "<div class=\"nome\">$($t.Nome)</div>")
    $c = [regex]::Replace($c, "<div class=\"legenda-linha\">Base da pirâmide – Bisnet[ao] \(1\)</div>", "<div class=\"legenda-linha\">$baseLinha</div>")
    $c = $c.Replace("Pai da Alice", "Pai do bisneto")
    $c = $c.Replace("Mãe da Alice", "Mãe do bisneto")

    Set-Content -LiteralPath $dest -Value $c -Encoding UTF8 -NoNewline
}

Write-Output "PILOTOS_CRIADOS=$($targets.Count)"
