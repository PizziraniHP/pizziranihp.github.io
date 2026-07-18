# Auditoria de Imagens do Nucleo Antigo

## Resumo

O projeto antigo (`nucleo-familiar-reservado/imagens/`) tem imagens organizadas por geração, com diversos formatos (PNG, JPEG, JPG, SVG) e versionamento no nome.

### Inventario por geracao

- **bisnetos/** → 6 imagens (JPEG)
- **pais/** → 9 imagens (JPEG, JPG)
- **avos/** → 19 imagens (PNG, JPEG, JPG)
- **bisavos/** → 15 imagens (PNG, JPEG)
- **trisavos/** → 16 imagens (PNG)
- **tetravos/** → 9 imagens (JPEG, PNG)
- **pentavos/** → 6 imagens (JPEG, JPG, PNG, SVG)
- **hexavos/** → 2 imagens (SVG)

**Total: 82 imagens**

### Formatos encontrados

- PNG: ~45 arquivos
- JPEG/JPG: ~35 arquivos
- SVG: 3 arquivos

## Padrão de nomes

Exemplo: `0101_lorena_v01.jpeg`
- `0101`: ID genealogico de 4 digitos
- `lorena`: nome da pessoa
- `v01`: versao do arquivo

## Criterios de migracao

1. Manter o ID no nome (ex.: `0101`, `0205`).
2. Manter o nome da pessoa.
3. Converter PNG e JPEG para JPG (em linhas 0-5).
4. Preservar SVG sem conversao.
5. Testar qualidade apos conversao.
6. Colocar em `imagens/ancestrais/[n-geracao]/[id]_[nome].jpg`.

## Prioridade sugerida

1. **bisnetos/** → 6 imagens, testa piloto rápido.
2. **pais/** → 9 imagens, próximo bloco.
3. **avos/** → 19 imagens, maior bloco de raster.
4. **bisavos/** → 15 imagens.
5. **trisavos/** → 16 imagens (todas PNG).
6. **tetravos/** → 9 imagens.
7. **pentavos/** → 6 imagens (com 1 SVG a preservar).
8. **hexavos/** → 2 imagens (ambas SVG).

