# Nucleo Familiar Planejado

Base nova para evoluir a arvore familiar com mais planejamento, separacao por camadas e migracao gradual do material antigo.

## Objetivo

- Reaproveitar os objetos de dados do projeto antigo sem quebrar o publicado.
- Centralizar informacoes em um formato previsivel.
- Organizar imagens por tipo e por contexto de uso.
- Permitir migracao por etapas: primeiro a estrutura, depois os dados, depois as paginas.

## Continuidade familiar

- Guia de preservacao e continuidade: `INSTRUCOES-CONTINUIDADE.md`

## Operacao em 1 comando (v2/v25)

Para evitar repeticao manual entre as duas bases:

- Execute: `scripts\\alinhar-v2-v25.cmd`
- O comando faz 2 etapas automaticamente:
	1. Sincroniza blocos comuns da v2 para a v25.
	2. Valida codigos/posicoes (sequencia de IDs) entre v2 e v25.

Se houver qualquer divergencia, o comando retorna erro e interrompe.

## Geracao generalizada de arvores individuais

Para evitar colcha de retalhos por correcoes pontuais, as arvores individuais devem ser sempre geradas a partir da fonte canonica `dados/arvores-propagacao.json`.

- Gerar uma arvore:
	- `scripts\gerar-arvore-individual.cmd alice`
- Gerar todas:
	- `scripts\gerar-arvore-individual.cmd --all`

Regras do gerador:

- Coleta automaticamente apenas os `sharedBlocks` referenciados pela arvore.
- Escreve JSON em UTF-8 sem BOM para evitar corrupcao de acentuacao.
- Evita edicao manual nos arquivos `dados/arvore-*-individual.json`.

## Espelho exato do planejado antigo

Quando a meta for manter copia exata do canônico do projeto antigo para evitar retrabalho:

- `scripts\espelhar-planejado-antigo.cmd`

Esse comando:

- Compara hash de `dados/arvores-propagacao.json` entre antigo e `planejado_2`.
- Copia o canônico antigo para `planejado_2` apenas se houver divergência (ou com `-Force`).
- Regenera todas as arvores individuais com o gerador padrão.

## Operacao segura (sem perda de dados)

Para editar cadastro e blocos com cautela, use o fluxo abaixo:

1. Antes de editar, rode checkpoint + validacoes:
	- `scripts\operacao-segura-cadastro.cmd pre-edit`
2. Faca as alteracoes necessarias nos JSONs.
3. Depois de editar, rode validacao final:
	- `scripts\operacao-segura-cadastro.cmd post-edit`

Modos disponiveis:

- `pre-edit`: cria checkpoint local e executa validacoes.
- `backup`: cria apenas checkpoint local.
- `validate`: valida sem criar checkpoint.
- `post-edit`: validacao de fechamento.

Saida de checkpoint:

- Pasta local: `.backups-locais/`
- Cada execucao cria `checkpoint-AAAAmmdd-HHMMSS` com copia dos arquivos criticos e `manifesto-sha256.txt`.

## Estrutura inicial

- `dados/`: fonte de verdade dos registros.
- `imagens/`: imagens separadas por subdiretorios adequados.
- `paginas/`: paginas geradas ou mantidas por contexto.
- `docs/`: regras, padroes e plano de migracao.
- `css/` e `js/`: base visual e comportamento do site.

## Caminho de evolucao

1. Definir padroes de cadastro e nomes de objetos.
2. Mapear o que sera reaproveitado do `nucleo-familiar-reservado`.
3. Migrar uma arvore por vez.
4. Consolidar imagens e links de paginas.
5. Validar homogeneidade antes de publicar qualquer etapa.

## Regra de edicao (propagacao)

Para evitar misturar arquivos manuais com arquivos de propagacao, use esta regra:

- Paginas principais canonicas dos 6 bisnetos ficam em `paginas/` (ex.: `paginas/lorena.html`, `paginas/alice.html`).
- Quer alterar um ancestral compartilhado por varios bisnetos: editar `dados/arvores-propagacao.json`.
- Quer alterar dados gerais de pessoa (nome, imagem, pagina): editar `dados/pessoas-v2-cartoes-base.json`.
- Quer alterar o comportamento de renderizacao para todas as arvores de propagacao: editar `js/arvore-propagacao.js`.

## Checklist curto antes de editar

1. Isso e dado, estrutura ou apenas visual?
2. A pessoa ou ID ja aparece em outro bloco?
3. A mudanca precisa valer para v2, v25 ou so para um caso?
4. Se houver repeticao, editar so o bloco canonico.
5. Se houver duvida, parar e validar antes de repetir a insercao.
- Quer alterar conteudo exclusivo de uma pessoa: editar somente a pagina dela em `paginas/saiba-mais/`.

## Navegacao de retorno (Saiba Mais)

- O retorno das paginas em `paginas/saiba-mais/` foi padronizado de forma global pelo script `paginas/saiba-mais/_retorno.js`.
- Prioridade de retorno: historico do navegador (pagina anterior), depois `from` na URL, depois `referrer` same-origin e por fim fallback do proprio link da pagina.
- Para conteudos raros e pesados, usar `paginas/extra-saiba-mais/` e manter entrada por links dentro de paginas Saiba Mais especificas.

## Pagina Saiba Mais por casal

Quando um casal compartilha uma unica pagina Saiba Mais, o modelo e:

- **Arquivo real** (codigo impar): contem todo o conteudo — fotos, textos, historia. E aqui que voce edita sempre.
- **Arquivo redirect** (codigo par): arquivo minimo que redireciona para o real. Nunca precisa ser aberto ou editado.

Exemplos ativos:
- `0501_marcelopizzirani_anacristinalienhardt.html` → pagina real (editar aqui)
- `0502_marcelopizzirani_anacristinalienhardt.html` → redirect invisivel

- `0607_josealvescunha_antoniamsantos.html` → pagina real (editar aqui)
- `0608_josealvescunha_antoniamsantos.html` → redirect invisivel

**Regra pratica: insercoes de fotos e textos sempre no arquivo de codigo impar.**

## Paginas duplicadas por pessoa (por que existem)

Em algumas arvores existem duas paginas, por exemplo:

- `paginas/arvore-rafael/rafael.html`: legado, hoje redireciona para `paginas/rafael.html`.
- `paginas/arvore-rafael/rafael-propagacao.html`: legado, hoje redireciona para `paginas/rafael.html`.

Durante a migracao, os caminhos curtos em `paginas/` sao a referencia principal para navegacao.
Arquivos em `paginas/arvore-*` seguem como legado temporario para compatibilidade e auditoria (via redirecionamento).

## Exemplo pratico de treino no JSON (hexavos)

Use este treino quando ainda nao houver ancestral confirmado e voce quiser praticar a edicao com seguranca.

### 1) Trocar placeholder por casal fake de treino

No arquivo `dados/arvores-propagacao.json`, em um bloco de geracao 8 (hexavos), voce pode substituir dois placeholders por um casal ficticio:

```json
{
	"id": "0803",
	"nome": "Heitor Exemplo",
	"detalhe": "HEXAVO",
	"ramo": "materno",
	"imagem": "imagens/ancestrais/8-hexavos/0803_heitor_exemplo.svg",
	"confianca": "fake"
},
{
	"id": "0804",
	"nome": "Helena Modelo",
	"detalhe": "HEXAVA",
	"ramo": "materno",
	"imagem": "imagens/ancestrais/8-hexavos/0804_helena_modelo.svg",
	"confianca": "fake"
}
```

Resultado esperado: ao recarregar a arvore, a contagem da geracao 8 atualiza automaticamente.

### 2) Se quiser voltar para espaco reservado

Troque novamente para placeholder:

```json
{
	"id": "",
	"nome": "Hexavo / Hexava",
	"detalhe": "Espaco",
	"ramo": "materno",
	"imagem": "imagens/ancestrais/6-tetravos/0600_tetravos_lorena.jpg",
	"placeholder": true
}
```

## Exemplo pratico com nome e endereco (ficticios)

Quando quiser registrar um individuo de treino no cadastro geral, use `dados/pessoas-v2-cartoes-base.json` com dados claramente ficticios.

```json
{
	"id": "0803",
	"idParidade": "0803",
	"nome": "Heitor Exemplo",
	"sexo": "masculino",
	"codigoGenealogico": "G8PM-0803",
	"ordemNascimento": 1,
	"geracao": 8,
	"ramo": "alice",
	"ramoPrincipal": "materno",
	"relacoes": {
		"pai": "0705",
		"mae": "0706"
	},
	"imagem": "imagens/ancestrais/8-hexavos/0803_heitor_exemplo.svg",
	"pagina": "paginas/saiba-mais/0803_heitor_exemplo.html",
	"metadata": {
		"confianca": "fake",
		"dataAdicao": "2026-07-04",
		"ativo": true,
		"enderecoReferencia": "Rua Exemplo 123, Bairro Modelo, Cidade-XX"
	}
}
```

Trecho de codigo simples para exibir nome + endereco em uma pagina de teste:

```javascript
const pessoaTreino = {
	nome: 'Heitor Exemplo',
	enderecoReferencia: 'Rua Exemplo 123, Bairro Modelo, Cidade-XX'
};

const alvo = document.querySelector('#resumo-pessoa');
if (alvo) {
	alvo.textContent = pessoaTreino.nome + ' - ' + pessoaTreino.enderecoReferencia;
}
```

Observacao: use sempre endereco ficticio em dados de treino.

## Checklist rapido (5 passos)

Use este fluxo toda vez que for treinar ou inserir novo ancestral:

1. Escolher a geracao e o bloco correto em `dados/arvores-propagacao.json`.
2. Inserir os dois cartoes (pai e mae), com `id` valido e `ramo` coerente.
3. Definir `imagem` na pasta certa da geracao e marcar `confianca` como `fake` quando for treino.
4. Recarregar a pagina principal da arvore e conferir ordem visual + contagem da geracao.
5. Validar: se estiver em treino, manter marcado como fake ou voltar para `placeholder`.

Regra de ouro: nunca misturar dado real com dado de treino sem identificacao clara.
