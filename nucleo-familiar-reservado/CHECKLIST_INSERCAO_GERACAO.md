# Checklist anti-gafe: insercao por geracao

Use esta lista sempre que incluir um novo casal/pessoa na arvore.

## 1) Classe da geracao (obrigatorio)

Confirme a classe CSS correta no card:

- G01 bisnetos: `card-bisneta` ou `card-bisneto`
- G02 pais: `card-pais`
- G03 avos: `card-avos`
- G04 bisavos: `card-bisavos`
- G05 trisavos: `card-trisavos`
- G06 tetravos: `card-tataravos` + foto `foto-tetravos`
- G07 pentavos: `card-tataravos` + foto `foto-hexaavos`
- G08 hexavos: `card-tataravos` + foto `foto-hexaavos`

Regra pratica: em pentavos, nao usar `card-bisavos`.

## 2) Linha da geracao

Insira o novo card dentro do bloco correto da geracao, sem criar uma nova linha por engano.

- Pentavos ficam no bloco com comentario `GERACAO 07 - PENTAVOS`.
- A linha deve permanecer como `linha-geracao linha-8`.

## 3) Ramo e cor/lado

Para manter casal junto no mesmo bloco visual:

- Defina ramo explicitamente nos dois cards do casal.
- Use a mesma logica da linha (normalmente `ramo-materno` no trecho atual de pentavos).

Se faltar ramo em um card, o script pode distribuir automaticamente em outro lado/cor.

## 4) ID e imagem

- `data-person-id` com 4 digitos (ex: `0705`).
- Caminho da foto centralizado em `../imagens/<geracao>/...`.
- Verifique se o nome da imagem bate com o ID.

## 5) Link Saiba mais

Se houver pagina independente, usar `data-person-page`.

Formato:

- `data-person-page="../saiba-mais/<arquivo>.html"`

Atencao: o nome do arquivo pode nao seguir 4 digitos (ex.: `705_...html`). Sempre confirmar o nome real em `saiba-mais/`.

## 6) Validacao rapida (1 minuto)

Antes de concluir:

1. Abrir a arvore e localizar a geracao.
2. Confirmar se o casal ficou junto na mesma linha visual.
3. Conferir cor/lado coerentes com os vizinhos.
4. Clicar em Saiba mais e validar se abriu a pagina correta.
5. Fazer refresh forcado (Ctrl+F5) para evitar cache enganando.

## 7) Mini modelo para copiar

```html
<div class="card-pessoa card-tataravos ramo-materno" data-person-id="0705" data-person-page="../saiba-mais/0705_aquilinojosepacheco.html">
    <img src="../imagens/pentavos/0705_aquilinojosepacheco_v01.png" class="foto-hexaavos">
    <div class="nome">Nome da Pessoa</div>
    <div class="detalhe">Pentavo.</div>
</div>
```
