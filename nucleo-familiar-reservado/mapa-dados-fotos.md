# Mapa de Dados e Fotos

Este arquivo serve como roteiro de preenchimento do nucleo reservado.
Use-o para registrar, por pessoa, onde ficam os dados principais, a foto da arvore e os arquivos do Saiba Mais.

## Estrutura de pastas

- `arvore-alice/`, `arvore-gabriela/`, `arvore-lorena/`, `arvore-luna/`, `arvore-pedro/`, `arvore-rafael/`
- `dados/pessoas.json`
- `imagens/` por geracao
- `imagens_smais/` por pessoa e por tipo de foto
- `saiba-mais/` paginas individuais

## Regra pratica

| Campo | Onde fica | Observacao |
|---|---|---|
| Dados gerais | `dados/pessoas.json` | fonte principal da pessoa |
| Card da arvore | `arvore-*/<arquivo>.html` | linka o cartao com `data-person-id` |
| Foto principal da arvore | `imagens/<geracao>/...` | imagem exibida no card da arvore |
| Pagina Saiba Mais | `saiba-mais/<id-nome>.html` | pagina individual da pessoa |
| Fotos extras do Saiba Mais | `imagens_smais/<nome>/...` | galeria, documentos e fotos complementares |

## Mapa base por pessoa

| ID | Pessoa | Arvore | Foto principal | Saiba Mais | Pasta de fotos extras | Status |
|---|---|---|---|---|---|---|
| 0102 | Alice | arvore-alice | `imagens/bisnetos/0102_alice_v01.jpeg` | `saiba-mais/0102-alice.html` | `imagens_smais/0102-alice/` | ok |
| 0104 | Rafael | arvore-rafael | `imagens/bisnetos/0104_rafael_v01.jpeg` | `saiba-mais/0104-rafael.html` | `imagens_smais/0104-rafael/` | ok |
| 0201 | Marcos | arvore-alice / arvore-rafael | `imagens/pais/0201_marcos_v01.jpeg` | `saiba-mais/0201-marcos.html` | `imagens_smais/0201-marcos/` | ok |
| 0202 | Paula | arvore-alice / arvore-rafael | `imagens/pais/0202_paula_v01.jpeg` | `saiba-mais/0202-paula.html` | `imagens_smais/0202-paula/` | ok |
| 0301 | Sidnei | arvore-alice / arvore-rafael | `imagens/avos/0301_sidnei_v01.jpeg` | `saiba-mais/0301-sidnei.html` | `imagens_smais/0301-sidnei/` | ok |
| 0302 | Patricia | arvore-alice / arvore-rafael | `imagens/avos/0302_patricia_v01.jpeg` | `saiba-mais/0302-patricia.html` | `imagens_smais/0302-patricia/` | ok |

## Regra de organizacao

1. A arvore usa a foto principal e o nome curto.
2. O Saiba Mais usa a pagina individual da pessoa.
3. Fotos provisoria/fake podem entrar como placeholder visual, mas devem ser marcadas como pendentes.
4. Fotos reais e documentos complementares ficam em `imagens_smais/<pessoa>/`.

## Pendencias

- Preencher os nomes que ainda nao estao fechados.
- Inserir fotos reais quando existirem.
- Registrar fotos provisoria/fake apenas quando ajudarem a dar leitura visual ao bloco.
- Manter um unico arquivo por pessoa como referencia de manutencao.
