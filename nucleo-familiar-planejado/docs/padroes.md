# Padroes iniciais

## Objetivo

Definir um modelo previsivel para o novo nucleo, com menos risco de divergencia entre paginas, dados e imagens.

## Regras iniciais

- A fonte principal deve ser `dados/pessoas.json`.
- Nenhuma imagem deve ficar solta na raiz de `imagens/`.
- Cada tipo de imagem deve ter um subdiretorio proprio.
- Paginas novas devem nascer com nomes consistentes e rastreaveis.
- Reaproveitamento do projeto antigo deve acontecer por etapas, nao por copia cega.

## Validacoes

- Conferir se o ID da pessoa bate com o codigo genealogico.
- Conferir se o caminho da imagem existe antes de publicar.
- Conferir se a pagina referenciada foi criada no novo nucleo.

## Ordem sugerida de migracao

1. Padronizar a estrutura de dados e os nomes-base dos objetos.
2. Padronizar as imagens individuais das geracoes, porque elas alimentam as paginas e os links.
3. Usar `alice.html` e `rafael.html` como modelos mais recentes para comparar estrutura, classes e repeticoes.
4. Extrair desses dois modelos a base comum para um template unico ou semi-unificado.
5. So depois montar o `index` dos indices, quando os caminhos e padroes ja estiverem estaveis.

## Regra pratica

- Nao começar pelo `index` dos indices.
- Nao copiar pagina por pagina antes de fechar o padrao de imagens e o padrao de HTML.
- Mover primeiro o que serve de base para o resto.

## Padrao de imagens

- Todas as imagens raster de uso novo devem ser publicadas em `jpg`.
- Arquivos `svg` continuam como `svg`, sem conversao.
- Outros formatos so entram com justificativa tecnica clara.
- A imagem publica deve ter nome previsivel, pasta adequada e dimensao testada antes da migracao.

### Imagens do Saiba Mais

- As imagens complementares do Saiba Mais ficam em `imagens/imagens_smais/`.
- Cada pessoa deve ter sua propria subpasta com identificacao padronizada no formato `ID_slug`, por exemplo `0401_arnaldo`, `0402_amaria`, `0601_nicolapizzirani`.
- Quando houver necessidade de separar tipos internos, use subpastas adicionais apenas se isso ajudar a manter a leitura clara; caso contrario, mantenha os arquivos diretamente na pasta da pessoa.
- Nomes de arquivo devem permanecer previsiveis e, quando possivel, devem refletir o conteudo da foto sem quebrar o vinculo historico com a pessoa.
- O caminho das paginas Saiba Mais deve apontar para esse novo repositório de extras sempre que a pagina for migrada para o nucleo planejado.

### Separacao por pastas de geracao

- `imagens/` é a raiz geral.
- `imagens/ancestrais/` é a pasta guarda-chuva que organiza todas as gerações.
- As geracoes ficam abaixo de `ancestrais/`:
  - `imagens/ancestrais/1-bisnetos/`
  - `imagens/ancestrais/2-pais/`
  - `imagens/ancestrais/3-avos/`
  - `imagens/ancestrais/4-bisavos/`
  - `imagens/ancestrais/5-trisavos/`
  - `imagens/ancestrais/6-tetravos/`
  - `imagens/ancestrais/7-pentavos/`
  - `imagens/ancestrais/8-hexavos/`

Essa separacao facilita migrar, testar e comparar cada bloco sem misturar gerações.

## Teste de qualidade

- Verificar nitidez depois da conversao para `jpg`.
- Verificar se nao houve corte indevido da imagem.
- Verificar se o peso do arquivo ficou aceitavel sem destruir a leitura visual.
- Verificar se o arquivo final abre no caminho esperado dentro do novo nucleo.

