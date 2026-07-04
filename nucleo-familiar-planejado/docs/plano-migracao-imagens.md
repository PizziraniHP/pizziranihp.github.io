# Plano de Migracao de Imagens

## Objetivo

Migrar, padronizar e validar 82 imagens do projeto antigo para o novo núcleo, organizadas por geração, com conversão para JPG (exceto SVG).

## Etapa 1: Piloto com "bisnetos" (6 imagens)

### Passos

1. Copiar as 6 imagens de `nucleo-familiar-reservado/imagens/bisnetos/` para `nucleo-familiar-planejado/imagens/ancestrais/1-bisnetos/`.
2. Renomear conforme padrão: `[ID]_[nome].jpg` (remover versão `_v01`).
3. Converter JPEG para JPG se necessário (manter JPG).
4. Testar qualidade de cada imagem.
5. Validar caminhos no JSON de pessoas.
6. Confirmar que as imagens abrem corretamente.

### Testes de qualidade

- [ ] Nitidez após conversão/cópia.
- [ ] Dimensões mantidas (sem corte).
- [ ] Peso do arquivo aceitável.
- [ ] Arquivo abre no caminho novo.

## Etapa 2: "pais" (9 imagens)

Repetir o processo de bisnetos.

## Etapa 3: "avos" (19 imagens)

- Maior bloco de raster (PNG).
- Converter PNG para JPG.
- Testar qualidade após conversão.

## Etapa 4 em diante

Repetir para bisavos, trisavos, tetravos, pentavos, hexavos.

## Validacao final

- [ ] Todos os IDs baterem com o JSON.
- [ ] Nenhuma imagem solta na raiz.
- [ ] SVG preservados (pentavos, hexavos).
- [ ] Caminhos consistentes.
- [ ] Teste visual no HTML (árvore e Saiba Mais).

