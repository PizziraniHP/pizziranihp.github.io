# Núcleo Familiar Reservado

Este diretório concentra as árvores genealógicas reservadas da família e o novo modelo de cadastro interno por pessoa.

## Para que serve este README

Este README é o manual rápido do projeto. Ele explica:

1. Onde cadastrar pessoas.
2. Como os links "Saiba mais" funcionam.
3. Em qual arquivo mexer para cada tipo de alteração.

## Estrutura Atual

- `index.html`: página de entrada do núcleo reservado.
- `arvore-alice/`, `arvore-gabriela/`, `arvore-lorena/`, `arvore-luna/`, `arvore-pedro/`, `arvore-rafael/`: páginas de cada bisneto, com seus cartões.
- `dados/pessoas.json`: cadastro interno centralizado (fonte única da verdade).
- `pessoa.html`: página de detalhes "Saiba mais".
- `pessoa.js`: lê o ID da URL, consulta `dados/pessoas.json` e monta a página.
- `pessoa.css`: estilos da página de detalhes.

## Regra Principal

O cadastro é feito em um único lugar: `dados/pessoas.json`.

Os cartões das árvores só precisam do ID da pessoa, por exemplo:

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

## Fluxo de Cadastro (manual, pessoa por pessoa)

1. Cadastrar ou atualizar a pessoa em `dados/pessoas.json`.
2. Garantir que o cartão na árvore tenha `data-person-id` com o mesmo ID.
3. Abrir a árvore no navegador e clicar em "Saiba mais" para testar.

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

- Alterar história, resumo, foto, galeria: `dados/pessoas.json`.
- Alterar visual da página de detalhes: `pessoa.css`.
- Alterar lógica de carregamento do cadastro: `pessoa.js`.
- Adicionar novo cartão em uma árvore: arquivo `.html` da árvore correspondente.
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
- `imagens/hexavos/`

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
	"nome": "Nome Completo",
	"apelido": "Descricao curta",
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

- `geracao`: bisnetos, pais, avos, bisavos, trisavos, tetravos, hexavos
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

## Observação de Privacidade

Este núcleo foi pensado para conteúdo familiar reservado. Mantenha dados sensíveis somente aqui e evite exposição desnecessária nas páginas públicas.