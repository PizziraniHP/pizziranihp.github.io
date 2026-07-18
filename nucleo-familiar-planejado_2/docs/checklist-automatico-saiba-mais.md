# Checklist Automatico - Saiba Mais

Use este checklist sempre que criar ou alterar paginas em paginas/saiba-mais.

## Como executar

No terminal, a partir da raiz do projeto:

```powershell
./scripts/validar-saiba-mais.ps1
```

Para checar outra faixa de IDs:

```powershell
./scripts/validar-saiba-mais.ps1 -MinId 100 -MaxId 899
```

Para usar em validacao mais rigida (retorna erro se houver falta):

```powershell
./scripts/validar-saiba-mais.ps1 -FailOnMissing
```

## O que o script valida

- IDs presentes no dados/arvores-propagacao.json (faixa configurada)
- IDs que tem entrada no paginas/saiba-mais/index.html
- IDs que tem arquivo HTML correspondente em paginas/saiba-mais
- IDs cujo indice aponta para arquivo que nao existe

## Interpretacao rapida

- Sem rota: ID sem entrada no indice e sem arquivo HTML correspondente.
- Com arquivo, sem indice: existe pagina, mas o indice nao lista o ID.
- Indice quebrado: o indice aponta para arquivo inexistente.

## Fluxo recomendado

1. Criou/alterou pagina Saiba Mais.
2. Se a pagina for de casal, garantir que o nome do arquivo deixe isso claro e que ambos os IDs do casal tenham rota valida.
3. Executou o script.
4. Corrigiu os IDs listados em Sem rota e Indice quebrado.
5. Reexecutou ate zerar pendencias criticas.
