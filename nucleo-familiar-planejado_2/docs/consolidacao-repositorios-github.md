# Consolidacao de Repositorios no GitHub

Objetivo: reduzir para 2 repositorios canonicos:
1. Site publico principal
2. Nucleo familiar definido

## Estado recomendado

- Canonico do site principal: pizziranihp.github.io
- Canonico do nucleo familiar: definir um unico repositorio (publico ou privado)
- Repositorios antigos: arquivar ou remover

## Passo a passo (GitHub Web)

### 1) Inventario

1. Abrir pagina de repositorios da conta.
2. Filtrar por Public e anotar nomes.
3. Filtrar por Private e anotar nomes.
4. Marcar quais 2 serao canonicos.

### 2) Ajustar visibilidade (se necessario)

1. Abrir repositorio.
2. Settings > General.
3. Danger Zone > Change repository visibility.
4. Confirmar Public ou Private conforme decisao.

### 3) Congelar legados

Opcao A (recomendada primeiro): Archive
1. Settings > General > Danger Zone.
2. Archive this repository.
3. Confirmar.

Opcao B (definitiva): Delete
1. Exportar backup antes.
2. Settings > General > Danger Zone.
3. Delete this repository.

## Roteiro seguro de migracao

1. Definir os 2 canonicos.
2. Arquivar legados por 7 a 15 dias.
3. Validar links no site principal.
4. Se estiver tudo ok, deletar legados.

## Checklist de validacao

- [ ] Somente 2 repositorios ativos para o projeto familiar.
- [ ] Repositorio canonico do nucleo definido claramente.
- [ ] Repositorios legados arquivados (ou deletados).
- [ ] Site principal com links apontando para o canonico.
- [ ] README dos canonicos com aviso de versao oficial.

## Sugestao de aviso em repositorio legado

"Este repositorio foi descontinuado. Versao oficial em: <URL_CANONICA>."
