# Padroes iniciais

## Objetivo

Definir um modelo previsivel para o novo nucleo, com menos risco de divergencia entre paginas, dados e imagens.

## Regras iniciais

- A fonte principal deve ser `dados/pessoas-v2-cartoes-base.json`.
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
- Cada pessoa com conteudo extra deve ter sua propria subpasta com identificacao padronizada no formato `ID_slug`, por exemplo `0401_arnaldo`, `0402_amaria`, `0601_nicolapizzirani`.
- Nem toda pessoa precisa de pagina Saiba Mais; quando nao houver material ou interesse de migracao, a pessoa pode ficar sem pasta dedicada.
- Quando houver necessidade de separar tipos internos, use subpastas adicionais apenas se isso ajudar a manter a leitura clara; caso contrario, mantenha os arquivos diretamente na pasta da pessoa.
- Nomes de arquivo devem permanecer previsiveis e, quando possivel, devem refletir o conteudo da foto sem quebrar o vinculo historico com a pessoa.
- O caminho das paginas Saiba Mais deve apontar para esse novo repositório de extras sempre que a pagina for migrada para o nucleo planejado.

### Paginas Saiba Mais por casal

- Quando o conteudo historico for essencialmente comum ao casal, preferir uma unica pagina Saiba Mais para os dois.
- Nesses casos, o nome do arquivo deve deixar evidente que se trata de pagina de casal, contendo os dois nomes no identificador do arquivo sempre que praticavel.
- Mesmo com pagina unica de casal, cada ID individual continua precisando de uma rota propria de entrada para a arvore resolver o link corretamente.
- Regra pratica: manter uma pagina principal do casal e criar alias/redirecionamento para o outro ID do casal quando necessario.
- Objetivo: evitar duplicacao de conteudo, preservar rastreabilidade e deixar claro para futuras insercoes que aquela pagina foi pensada como pagina conjunta.

### Paginas Saiba Mais sem material suficiente

- Nao e obrigatorio manter pagina Saiba Mais para toda pessoa.
- Se uma pagina existir, mas nao houver material minimo para justificar manutencao futura, avaliar remocao da pagina dedicada.
- Material minimo pode ser apenas nome confirmado e alguma funcao de navegacao, mas paginas vazias ou sem perspectiva de conteudo devem ser revistas caso a caso.
- Antes de remover uma pagina, garantir que o ID continue com rota valida no indice ou por alias temporario, para nao quebrar os links da arvore.

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

## Matriz oficial de propagacao (bloqueio seletivo)

Objetivo: definir, por bisneto, quais ramos sobem para geracoes superiores e quais ramos ficam bloqueados para evitar mistura indevida de linhagens.

### Regra fixa de identificacao

- IDs sao unicos e imutaveis.
- Nao renumerar IDs para ajustar ordem visual.
- Ajustes de leitura visual devem ocorrer por codigo genealogico, codigo de cartao e referencias de propagacao.

### Matriz por bisneto

1. Alice
- Matriz canonica completa.
- Sem bloqueio adicional.

2. Rafael
- Igual a Alice.
- Usa a mesma logica de propagacao da matriz canonica.

3. Pedro
- Sem subida pelos antecedentes paternos de Flavio.
- No lado materno, subir somente pela linha do avo Marcelo.
- Linha da avo Lia permanece bloqueada para subida.

4. Gabriela
- Subir somente pelos antecedentes de Flavio Melo.
- Andrea pode aparecer no nivel dela (avo), mas sem subir acima dela.

5. Luna
- Pais sem vinculo de propagacao com o tronco familiar principal.
- Subir somente pelos ascendentes da Andrea.
- Demais ramos ficam bloqueados para subida.

6. Lorena
- Pais sem vinculo de propagacao com o tronco familiar principal.
- Subir somente pelos ascendentes da Andrea.
- Demais ramos ficam bloqueados para subida.

### Regra de implementacao

- Quando houver duvida de propagacao, priorizar esta matriz em vez de inferir por semelhanca de nomes ou IDs.
- Se for necessario ajustar um caso, atualizar primeiro esta matriz e depois os blocos no JSON.
- Nao alterar IDs como forma de corrigir propagacao.

## Checklist operacional por bisneto

Objetivo: validar cada arvore antes de publicar alteracoes de propagacao.

### Passo 1 - Confirmar regra do caso

- Ler a Matriz oficial de propagacao (bloqueio seletivo).
- Confirmar tronco ativo e tronco bloqueado do bisneto em analise.

### Passo 2 - Conferir referencias no JSON

- Abrir dados/arvores-propagacao.json.
- Conferir referencias de g2, g3, g4 e g5 do bisneto.
- Verificar se os refs apontam para os blocos corretos do caso.

### Passo 3 - Verificar subida permitida

- Confirmar que os ramos ativos aparecem e continuam subindo nas geracoes seguintes.
- Confirmar que os ramos bloqueados nao sobem acima do nivel permitido.

### Passo 4 - Verificar placeholders

- Confirmar se placeholders estao apenas onde o bloqueio ou falta de dado e intencional.
- Evitar placeholder em ramo que deveria propagar dado confirmado.

### Passo 5 - Revisao visual

- Recarregar a pagina do bisneto.
- Conferir se a leitura da arvore condiz com a regra do caso.
- Confirmar que ajustes de ordem visual nao alteraram IDs.

### Checagem rapida por bisneto

1. Alice
- Deve permanecer matriz canonica completa.

2. Rafael
- Deve permanecer igual a Alice.

3. Pedro
- Bloquear subida pela linha paterna de Flavio.
- No lado materno, subir somente pela linha do avo Marcelo.
- Nao subir pela avo Lia.

4. Gabriela
- Subir somente pelos antecedentes de Flavio Melo.
- Andrea pode aparecer no nivel dela, sem subir acima dela.

5. Luna
- Subir somente pelos ascendentes da Andrea.
- Demais ramos bloqueados para subida.

6. Lorena
- Subir somente pelos ascendentes da Andrea.
- Demais ramos bloqueados para subida.

## Modo sem IA (operacao manual)

Objetivo: permitir manutencao da propagacao mesmo sem assistente.

### Regra simples (lembrar sempre)

- Pessoa so aparece na arvore se estiver no bloco referenciado pela arvore do bisneto.
- Existir no JSON, por si so, nao garante exibicao.

### Fluxo manual em 7 passos

1. Defina o bisneto alvo (ex.: gabriela).
2. Abra `dados/arvores-propagacao.json` e localize o bloco `trees.<bisneto>`.
3. Veja quais `$ref` estao em `g4`, `g5`, `g6`.
4. Abra os blocos referenciados em `sharedBlocks`.
5. Verifique se a pessoa desejada esta dentro do bloco correto.
6. Se nao estiver, escolha uma das opcoes:
- trocar o `$ref` para um bloco que ja tem os dados corretos; ou
- criar bloco exclusivo do bisneto e apontar o `$ref` para ele.
7. Recarregue a pagina e valide visualmente.

### Regra de seguranca

- Nao editar IDs para forcar propagacao.
- Se o bloco for compartilhado por outro bisneto, preferir criar bloco exclusivo para evitar efeito colateral.

### Exemplo curto (caso Gabriela)

- Se `g5` da Gabriela aponta para um bloco parcial, ela exibira so parte dos trisavos.
- Para carregar todos os desejados, o `g5` dela deve apontar para um bloco que contenha exatamente esses nomes.
- Se isso afetar Pedro, criar `g5-gabriela` exclusivo e referenciar apenas nele.

