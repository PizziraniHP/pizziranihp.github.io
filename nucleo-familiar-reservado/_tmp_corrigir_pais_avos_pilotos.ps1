Set-Location 'c:\Users\Arnaldo Pizzirani\OneDrive\pizziranihp.github.io\pizziranihp.github.io'

function Replace-CardById {
    param(
        [string]$Content,
        [string]$OldId,
        [string]$NewId,
        [string]$NewPage,
        [string]$NewImg,
        [string]$NewNome,
        [string]$NewDetalhe,
        [string]$ImgClass
    )

    $pattern = '(?s)<div class="card-pessoa ([^"]*)"[^>]*data-person-id="' + [regex]::Escape($OldId) + '"[^>]*>\s*<img[^>]*>\s*<div class="nome">.*?</div>\s*<div class="detalhe">.*?</div>\s*</div>'

    return [regex]::Replace(
        $Content,
        $pattern,
        [System.Text.RegularExpressions.MatchEvaluator]{
            param($m)
            $classes = $m.Groups[1].Value
            return ('<div class="card-pessoa {0}" data-person-id="{1}" data-person-page="{2}">' -f $classes, $NewId, $NewPage) + "`r`n" +
                   ('                        <img src="{0}" class="{1}">' -f $NewImg, $ImgClass) + "`r`n" +
                   ('                        <div class="nome">{0}</div>' -f $NewNome) + "`r`n" +
                   ('                        <div class="detalhe">{0}</div>' -f $NewDetalhe) + "`r`n" +
                   '                    </div>'
        },
        1
    )
}

$maps = @{
    'gabriela' = @(
        @{Old='0201'; New='0208'; Page='../saiba-mais/0208-marcella.html'; Img='../imagens/pais/0208_marcella_v01.jpg'; Nome='Mãe da Gabriela'; Det='Filha de '; ImgClass='foto-pais'},
        @{Old='0202'; New='0207'; Page='../saiba-mais/0207-livia.html'; Img='../imagens/pais/0207_livia_v01.jpeg'; Nome='Mãe da Gabriela'; Det='Filha de '; ImgClass='foto-pais'},
        @{Old='0318'; New='0391'; Page='../saiba-mais/0391-luiz-carrasco.html'; Img='../imagens/luizao.png'; Nome='LUIZ CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0319'; New='0392'; Page='../saiba-mais/0392-ligia-carrasco.html'; Img='../imagens/ligia.png'; Nome='LIGIA CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0301'; New='0393'; Page='../saiba-mais/0393-avo-materno.html'; Img='../imagens/flavio.png'; Nome='Avô materno'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0302'; New='0394'; Page='../saiba-mais/0394-avo-materna.html'; Img='../imagens/andrea.jpg'; Nome='Avó materna'; Det='Dados a inserir'; ImgClass='foto-avos'}
    )
    'lorena' = @(
        @{Old='0201'; New='0203'; Page='../saiba-mais/0203-anderson.html'; Img='../imagens/pais/0203_anderson_v01.jpeg'; Nome='Pai da Lorena'; Det='Filho de Luiz Augusto Giaponese e Silvana'; ImgClass='foto-pais'},
        @{Old='0202'; New='0204'; Page='../saiba-mais/0204-sthefanie.html'; Img='../imagens/pais/0204_sthefanie _v01.jpeg'; Nome='Mãe da Lorena'; Det='Filha de Arnaldo e Antonia Maria,'; ImgClass='foto-pais'},
        @{Old='0318'; New='0391'; Page='../saiba-mais/0391-luiz-carrasco.html'; Img='../imagens/luizao.png'; Nome='LUIZ CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0319'; New='0392'; Page='../saiba-mais/0392-ligia-carrasco.html'; Img='../imagens/ligia.png'; Nome='LIGIA CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0301'; New='0393'; Page='../saiba-mais/0393-avo-materno.html'; Img='../imagens/flavio.png'; Nome='Avô materno'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0302'; New='0394'; Page='../saiba-mais/0394-avo-materna.html'; Img='../imagens/andrea.jpg'; Nome='Avó materna'; Det='Dados a inserir'; ImgClass='foto-avos'}
    )
    'luna' = @(
        @{Old='0201'; New='0209'; Page='../saiba-mais/0209-luiz.html'; Img='../imagens/pais/0209_luiz_v01.jpeg'; Nome='Pai da Luna'; Det='Filho de Luizão e Lígia, neto de Y'; ImgClass='foto-pais'},
        @{Old='0202'; New='0204'; Page='../saiba-mais/0204-sthefanie.html'; Img='../imagens/pais/0204_sthefanie _v01.jpeg'; Nome='Mãe da Luna'; Det='Filha de Arnaldo e Antonia Maria, neta de B'; ImgClass='foto-pais'},
        @{Old='0318'; New='0391'; Page='../saiba-mais/0391-luiz-carrasco.html'; Img='../imagens/luizao.png'; Nome='LUIZ CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0319'; New='0392'; Page='../saiba-mais/0392-ligia-carrasco.html'; Img='../imagens/ligia.png'; Nome='LIGIA CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0301'; New='0393'; Page='../saiba-mais/0393-avo-materno.html'; Img='../imagens/flavio.png'; Nome='Avô materno'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0302'; New='0394'; Page='../saiba-mais/0394-avo-materna.html'; Img='../imagens/andrea.jpg'; Nome='Avó materna'; Det='Dados a inserir'; ImgClass='foto-avos'}
    )
    'pedro' = @(
        @{Old='0201'; New='0205'; Page='../saiba-mais/0205-flavio.html'; Img='../imagens/pais/0205_flaviopaipedro_v01.jpeg'; Nome='Pai do Pedro'; Det='Filho de '; ImgClass='foto-pais'},
        @{Old='0202'; New='0206'; Page='../saiba-mais/0206-barbara.html'; Img='../imagens/pais/0206_barbara_v01.jpg'; Nome='Mãe do Pedro'; Det='Filha de Marcelo e Lia'; ImgClass='foto-pais'},
        @{Old='0318'; New='0391'; Page='../saiba-mais/0391-luiz-carrasco.html'; Img='../imagens/luizao.png'; Nome='LUIZ CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0319'; New='0392'; Page='../saiba-mais/0392-ligia-carrasco.html'; Img='../imagens/ligia.png'; Nome='LIGIA CARRASCO'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0301'; New='0393'; Page='../saiba-mais/0393-avo-materno.html'; Img='../imagens/flavio.png'; Nome='Avô materno'; Det='Dados a inserir'; ImgClass='foto-avos'},
        @{Old='0302'; New='0394'; Page='../saiba-mais/0394-avo-materna.html'; Img='../imagens/andrea.jpg'; Nome='Avó materna'; Det='Dados a inserir'; ImgClass='foto-avos'}
    )
}

foreach ($slug in $maps.Keys) {
    $path = "nucleo-familiar-reservado/arvore-$slug/$slug-piloto.html"
    $c = Get-Content -Raw -LiteralPath $path
    foreach ($r in $maps[$slug]) {
        $c = Replace-CardById -Content $c -OldId $r.Old -NewId $r.New -NewPage $r.Page -NewImg $r.Img -NewNome $r.Nome -NewDetalhe $r.Det -ImgClass $r.ImgClass
    }
    Set-Content -LiteralPath $path -Value $c -Encoding UTF8 -NoNewline
}

Write-Output 'PAIS_AVOS_CORRIGIDOS'
