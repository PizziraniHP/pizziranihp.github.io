# Estrutura de Dados - JSON e Codigo Genealogico

## Objetivo

Definir um contrato de dados que seja sofisticado mas prático, sem códigos estratosféricos.

## Princípio

- **Código Genealógico**: simples, rastreável, usado em nomes de arquivo e URL.
- **Metadados**: ramo, cor, posição, informações contextuais em campos separados do JSON.

## Estrutura do Código Genealogico

Formato: `G[n][RAMO]-[IDP]`

Exemplo: `G1P-0101`, `G1A-0104`, `G7PM-0705`

Onde:
- `G[n]` = geração (G1, G2, G3... G8)
- `[RAMO]` = iniciais do ramo (A=Alice, P=Pedro, L=Lorena, etc. ou PP=paterno, M=materno)
- `-` = separador
- `[IDP]` = ID de paridade (4 dígitos, 0101-0999), com regra obrigatória:
  - masculino = ímpar
  - feminino = par

## Estrutura do JSON

```json
{
  "id": "0101",
  "idParidade": "0104",
  "nome": "Alice",
  "sexo": "feminino",
  "codigoGenealogico": "G1A-0104",
  "ordemNascimento": 2,
  "geracao": 1,
  "ramo": "alice",
  "ramoPrincipal": "paterno",
  "relacoes": {
    "pai": "0201",
    "mae": "0202"
  },
  "imagem": "imagens/ancestrais/1-bisnetos/0102_alice.jpg",
  "pagina": "paginas/saiba-mais/0102_alice.html",
  "cartao": {
    "cor": "#c9a876",
    "posicaoX": 1,
    "posicaoY": 1,
    "linha": 1
  },
  "metadata": {
    "confianca": "confirmado",
    "dataAdicao": "2026-07-03",
    "ativo": true
  }
}
```

## Campos principais

- `id`: ID legado/mídia (4 dígitos), útil para compatibilidade na migração.
- `idParidade`: ID genealógico oficial no novo modelo (4 dígitos).
- `sexo`: "masculino" ou "feminino".
- `ordemNascimento`: ordem no grupo de irmãos/irmãs (1, 2, 3...).
- `codigoGenealogico`: Legível para humanos. Usa `idParidade` e o ramo.
- `geracao`: Número (1-8).
- `ramo`: Nome do ramo em letra minúscula (alice, pedro, rafael, etc.).
- `ramoPrincipal`: Caminho ascendente (paterno, materno).
- `relacoes`: Links para pais/cônjuges por ID.
- `imagem`: Caminho completo da imagem.
- `pagina`: Caminho completo da página "Saiba Mais".
- `cartao.cor`: Hexadecimal ou nome CSS (define visual no cartão).
- `cartao.posicaoX/Y`: Coordenadas ou índice na grid.
- `cartao.linha`: Qual linha da pirâmide (para gerações com múltiplas linhas, ex.: G7/G8).
- `metadata.confianca`: "confirmado", "estimado", "fake".
- `metadata.ativo`: true/false (permite desativar sem deletar).

## Vantagens

1. **Simples**: código é string legível, não numérico estratosférico.
2. **Extensível**: JSON permite adicionar campos sem quebrar nada.
3. **Contextual**: ramo, cor, posição em campos específicos, não misturados.
4. **Rastreável**: ID único é a chave, tudo se liga a ele.
5. **Validável**: fiscal pode checar se cor existe, se posição é válida, etc.

## Validacoes esperadas

- ID deve ser único e ter 4 dígitos.
- idParidade deve ser único e ter 4 dígitos.
- ordemNascimento deve ser inteira e sem duplicidade no mesmo grupo de irmãos.
- codigoGenealogico deve iniciar com G[1-8] e conter o idParidade.
- Regra obrigatória de paridade:
  - se sexo = masculino, idParidade deve ser ímpar
  - se sexo = feminino, idParidade deve ser par
- ramo deve estar em lista pré-definida ou ser nome de árvore.
- relacoes.pai/mae deve existir no JSON ou estar vazio.
- imagem deve apontar para arquivo existente em ancestrais/[n-geracao]/.
- cor deve ser válida (hex ou CSS name).
- posicaoX/Y devem ser positivos e razoáveis para a geração.

