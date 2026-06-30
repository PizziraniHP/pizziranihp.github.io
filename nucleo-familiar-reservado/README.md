# NÃºcleo Familiar Reservado

Este diretÃ³rio concentra as Ã¡rvores genealÃ³gicas reservadas da famÃ­lia e o novo modelo de cadastro interno por pessoa.

## Para que serve este README

Este README Ã© o manual rÃ¡pido do projeto. Ele explica:

1. Onde cadastrar pessoas.
2. Como os links "Saiba mais" funcionam.
3. Em qual arquivo mexer para cada tipo de alteraÃ§Ã£o.

## Estrutura Atual

- `index.html`: pÃ¡gina de entrada do nÃºcleo reservado.
- `arvore-alice/`, `arvore-gabriela/`, `arvore-lorena/`, `arvore-luna/`, `arvore-pedro/`, `arvore-rafael/`: pÃ¡ginas de cada bisneto, com seus cartÃµes.
- `dados/pessoas.json`: cadastro interno centralizado (fonte Ãºnica da verdade).
- `pessoa.html`: pÃ¡gina de detalhes "Saiba mais".
- `pessoa.js`: lÃª o ID da URL, consulta `dados/pessoas.json` e monta a pÃ¡gina.
- `pessoa.css`: estilos da pÃ¡gina de detalhes.

## Regra Principal

O cadastro Ã© feito em um Ãºnico lugar: `dados/pessoas.json`.

## Paridade e parentalidade

- Geracao `0100` (bisnetos): excecao por ordem etaria, sem paridade obrigatoria.
- Geracoes `0200+`: convencao de ID (impar masculino, par feminino).
- Parentalidade usa modelo neutro: `responsavel1` e `responsavel2`.
- O casal parental nao depende de genero e pode ser: par+par, impar+impar ou par+impar.

## Padrao de Codigo Genealogico (novo)

Para manter o sistema atual estavel, o projeto continua usando `id` numerico como chave unica.

Novo conceito recomendado:

- `id`: chave tecnica fixa (ex.: `0201`).
- `codigoGenealogico`: etiqueta humana com significado familiar (ex.: `G2PP-201`).

Composicao do `codigoGenealogico`:

- `G1`, `G2`, `G3`... = geracao.
- Letra/bloco da geracao:
	- `B` = bisnetos (geracao 1).
	- `PP` = linha paterna na geracao de pais.
	- `PM` = linha materna na geracao de pais.
	- para avos e acima, manter o mesmo principio de ramo (`P` paterno, `M` materno).
- Sufixo numerico apos `-` = numero sequencial da pessoa no grupo.

Exemplos:

- `G1B-101`, `G1B-102`, `G1B-103`...
- `G2PP-201`, `G2PM-202`, `G2PP-203`, `G2PM-204`...

Regra de paridade para pais (G2):

- sequencias impares: pais (masculino, ramo paterno do casal).
- sequencias pares: maes (feminino, ramo materno do casal).
- em cadastro historico legado, se houver conflito, prevalece o papel real informado no `apelido` (Pai/Mae).

Regra pratica importante:

- O sistema de links e busca continua apontando pelo `id` numerico.
- O `codigoGenealogico` entra como camada de organizacao e leitura humana.

Os cartÃµes das Ã¡rvores sÃ³ precisam do ID da pessoa, por exemplo:

```html
<div class="card-pessoa" data-person-id="0202">
```

Com isso, o link "Saiba mais" passa a abrir automaticamente:

```text
../pessoa.html?id=0202
```

## Modo Simplificado (recomendado para pouco material)

Quando houver pouco conteudo (ex: foco em avos e bisavos), use paginas HTML independentes para o link "Saiba mais".

Como funciona:

- Mantenha `dados/pessoas.json` com o minimo (ID, nome e campos basicos).
- Escreva historia e foto diretamente em uma pagina da pasta `saiba-mais/`.
- No cartao da arvore, adicione `data-person-page` com o caminho da pagina.

Exemplo de cartao:

```html
<div class="card-pessoa" data-person-id="0101" data-person-page="../saiba-mais/0101-alice.html">
```

Comportamento:

- Se `data-person-page` existir: abre a pagina independente.
- Se nao existir: continua abrindo `../pessoa.html?id=...` (modo antigo).

## Copiar e Colar (modo leigo)

Objetivo: replicar paginas de forma rapida, sem risco de quebrar layout.

Passo a passo simples:

1. Duplicar uma pagina da pasta `saiba-mais/`.
2. Trocar nome do arquivo para o novo ID (ex: `0102-alice.html` -> `0107-novoparente.html`).
3. Abrir o bloco pronto em `saiba-mais/_bloco-fotos-padrao.html`.
4. Copiar e colar as secoes de fotos (grandes e menores).
5. Trocar apenas 3 itens em cada foto:
	- `src` (caminho da imagem)
	- `alt` (descricao curta)
	- texto do `<p>` (comentario da foto)
6. Testar no navegador clicando na foto para validar o zoom.

Regra pratica:

- Nao mexer em classes CSS (`extra-grid`, `extra-item`, `extra-grid-small`, `extra-item-small`).
- Nao mexer no script de lightbox (zoom). Ele ja funciona para fotos grandes e pequenas.
- Se so trocar `src`, `alt` e comentario, o layout permanece estavel.

Arquivo de apoio:

- `saiba-mais/_bloco-fotos-padrao.html` (template de copiar/colar para leigos)

## Fluxo de Cadastro (manual, pessoa por pessoa)

1. Cadastrar ou atualizar a pessoa em `dados/pessoas.json`.
2. Garantir que o cartÃ£o na Ã¡rvore tenha `data-person-id` com o mesmo ID.
3. Abrir a Ã¡rvore no navegador e clicar em "Saiba mais" para testar.

## Exemplo de Registro no JSON

```json
{
	"id": "0202",
	"nome": "Paula",
	"apelido": "Mae da Alice",
	"foto": "imagens/pais/new_paula.jpeg",
	"resumo": "Resumo curto.",
	"textoCompleto": "Texto completo com historia, lembrancas e datas.",
	"galeria": [],
	"fontes": []
}
```

## O que editar em cada caso

- Alterar histÃ³ria, resumo, foto, galeria: `dados/pessoas.json`.
- Alterar visual da pÃ¡gina de detalhes: `pessoa.css`.
- Alterar lÃ³gica de carregamento do cadastro: `pessoa.js`.
- Adicionar novo cartÃ£o em uma Ã¡rvore: arquivo `.html` da Ã¡rvore correspondente.
- Criar conteudo livre por pessoa: `saiba-mais/*.html`.

## Convencoes de Imagem (padrao)

### Pasta central

Use sempre a pasta central de imagens do nucleo reservado:

- `imagens/bisnetos/`
- `imagens/pais/`
- `imagens/avos/`
- `imagens/bisavos/`
- `imagens/trisavos/`
- `imagens/tetravos/`
- `imagens/pentavos/`

Nao duplicar fotos por arvore (`arvore-alice`, `arvore-gabriela`, etc.).

### Nome de arquivo

Padrao recomendado:

`geracao_id_nome-sobrenome_v01.jpg`

Exemplos:

- Foto principal: `bisnetos_0101_alice-sobrenome_v01.jpg`
- Foto revisada: `bisnetos_0101_alice-sobrenome_v02.jpg`
- Galeria (doc): `bisnetos_0101_alice-sobrenome_doc01_v01.jpg`
- Galeria (doc 2): `bisnetos_0101_alice-sobrenome_doc02_v01.jpg`

Significado do `v01`:

- `v01` = primeira versao do arquivo
- `v02` = segunda versao (foto retocada, recortada, etc.)
- Incremente apenas quando substituir a imagem por uma nova edicao

Regras:

- usar minusculas
- sem acentos
- sem espacos (usar `-` ou `_`)
- extensao padrao: `.jpg` (converter PNG apenas se precisar transparencia)

### Peso e formato (boas praticas)

- foto principal: lado maior entre 1200 e 1600 px
- JPG com qualidade entre 75 e 85
- PNG apenas quando precisar transparencia

### Dimensao de fotos (recomendado)

Use estas medidas como padrao para manter boa qualidade com carregamento leve:

- foto principal da pessoa (card + Saiba mais): 1200 x 1600 px (proporcao 3:4)
- foto horizontal antiga: 1600 x 1200 px (proporcao 4:3)
- imagem de galeria: 1600 px no lado maior
- thumbnail/placeholder: 800 x 1000 px (proporcao 4:5)

Limites praticos de arquivo:

- foto principal: ate 350 KB
- imagem de galeria: ate 500 KB
- placeholder: ate 150 KB

Regras de recorte:

- priorizar rosto centralizado em retratos
- evitar cortes muito fechados no topo da cabeca
- manter margem lateral para nao perder partes no card responsivo

### Preset unico recomendado (padrao oficial)

Para simplificar e evitar duvidas, este e o preset oficial do projeto:

- formato: JPG
- dimensao: 1200 x 1600 px (3:4)
- qualidade: 80
- limite de peso por foto principal: ate 350 KB

Quando usar excecao:

- fotos historicas horizontais: 1600 x 1200 px
- PNG apenas com transparencia necessaria

## Template pronto (copiar e colar)

Use este modelo para acelerar novos registros em `dados/pessoas.json`:

```json
{
	"id": "0000",
	"codigoGenealogico": "G0X-000",
	"geracao": 0,
	"ramo": "P|M|N",
	"sexo": "M|F|N",
	"nome": "Nome Completo",
	"apelido": "Descricao curta",
	"responsavel1": "0000",
	"responsavel2": "0000",
	"foto": "imagens/geracao/geracao_0000_nome-sobrenome_v01.jpg",
	"resumo": "Resumo curto.",
	"textoCompleto": "Texto completo com historia, lembrancas e datas.",
	"galeria": [
		"imagens/geracao/geracao_0000_nome-sobrenome_doc01_v01.jpg",
		"imagens/geracao/geracao_0000_nome-sobrenome_doc02_v01.jpg"
	],
	"fontes": [
		"Fonte 1",
		"Fonte 2"
	]
}
```

Trocas rapidas no template:

- `geracao`: bisnetos, pais, avos, bisavos, trisavos, tetravos, pentavos
- `0000`: ID da pessoa (ex: 0101 para Alice)
- `nome-sobrenome`: nome sem acento e sem espaco
- `doc01`, `doc02`...: fotos extras da galeria (documentos, registros historicos)
- `v01`: primeira versao; incremente para `v02` ao reeditar a mesma foto

## Checklist Operacional (inclusao de foto)

1. Salvar a foto na subpasta correta dentro de `imagens/`.
2. Renomear o arquivo no padrao definido acima.
3. Atualizar `foto` da pessoa em `dados/pessoas.json`.
4. Se houver imagens extras, preencher `galeria` no JSON.
5. Abrir a arvore no navegador e validar o card.
6. Clicar em "Saiba mais" e validar a tela `pessoa.html`.
7. Se a pessoa ainda nao tiver foto, manter placeholder temporario.

## Checklist Operacional (cadastro em lote)

Quando for cadastrar muitas pessoas:

1. Organizar primeiro os arquivos de imagem (nomes e pastas).
2. Atualizar o JSON em bloco (10 a 20 pessoas por vez).
3. Validar uma arvore completa.
4. Corrigir inconsistencias de caminho.
5. Seguir para o proximo lote.

## Regra de Ouro

Texto no JSON pesa pouco. O que pesa sao as imagens.

Por isso:

- pode manter textos completos e fontes historicas
- deve evitar duplicacao de fotos
- deve manter organizacao por geracao na pasta central

## ObservaÃ§Ã£o de Privacidade

Este nÃºcleo foi pensado para conteÃºdo familiar reservado. Mantenha dados sensÃ­veis somente aqui e evite exposiÃ§Ã£o desnecessÃ¡ria nas pÃ¡ginas pÃºblicas.