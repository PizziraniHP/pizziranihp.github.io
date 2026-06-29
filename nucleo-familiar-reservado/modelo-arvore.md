# Modelo Oficial da Arvore

Este arquivo registra qual e o modelo final de engenharia visual e estrutural das arvores genealogicas do nucleo reservado.

## Base oficial

O modelo oficial da arvore passou a ser a base Alice.

Arquivos de referencia:

- `arvore-alice/alice.html`
- `arvore-alice/alice-piloto.html`
- `arvore-alice/style.css`
- `arvore-alice/script.js`

No estado atual:

1. `alice.html` e `alice-piloto.html` estao equivalentes.
2. As demais arvores ja seguem o mesmo `style.css` e o mesmo `script.js`.
3. Cada arvore preserva apenas seus proprios dados, nomes, links e fotos.

## O que este modelo define

1. Hierarquia visual da piramide inversa.
2. Cores por ramo (`ramo-paterno` e `ramo-materno`).
3. Ordem visual dos blocos por ramo.
4. Barra de geracao com botao `Recolher` / `Mostrar`.
5. Link automatico `SAIBA MAIS` em cada cartao com `data-person-id`.
6. Lightbox para ampliar fotos.

## O que deve ser preservado ao replicar

Ao usar este modelo em outra arvore, preservar:

1. `style.css` como base visual.
2. `script.js` como base funcional.
3. Estrutura HTML por geracao.
4. Classes dos cartoes (`card-bisneta`, `card-pais`, `card-avos`, `card-bisavos`, `card-trisavos`, `card-tataravos`).
5. Classes de ramo (`ramo-paterno`, `ramo-materno`).

## O que muda em cada arvore

Em cada bisneto, alterar apenas:

1. nome da pessoa-base;
2. foto da pessoa-base;
3. titulo e subtitulo da pagina;
4. dados de cada cartao;
5. links `data-person-page`;
6. imagens e textos do proprio ramo.

## Distincao importante

O arquivo `saiba-mais/modelo.html` continua sendo o modelo das paginas `Saiba Mais`.

Este arquivo aqui define o modelo das paginas da arvore genealogica.

## Uso recomendado

Para novos ajustes estruturais:

1. testar primeiro em `arvore-alice/alice-piloto.html`;
2. validar visualmente;
3. sincronizar com `arvore-alice/alice.html` quando estabilizar;
4. depois propagar para as demais arvores.
