# Paginas independentes de Saiba mais

Esta pasta guarda paginas HTML individuais para historias familiares.

## Como usar

1. Copie `modelo.html` e renomeie para um arquivo da pessoa.
2. Exemplo de nome: `0101-alice.html`.
3. Edite foto, nome, ID, resumo e historia no proprio HTML.
4. No cartao da arvore, adicione o atributo `data-person-page`.

Exemplo no cartao:

```html
<div class="card-pessoa" data-person-id="0101" data-person-page="../saiba-mais/0101-alice.html">
```

## Observacao

Se `data-person-page` nao for informado, o sistema continua usando o modo antigo:

`../pessoa.html?id=ID`
