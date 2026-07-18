# Instrucoes de Continuidade do Projeto Familiar

Objetivo: permitir que filho, neto ou outro familiar consiga abrir, preservar e manter este projeto funcionando, mesmo sem conhecimento tecnico avancado.

## 1) O que e este projeto

Este projeto guarda a arvore genealogica familiar e paginas de apoio.

A estrutura principal esta em:
- nucleo-familiar-planejado_2/

Arquivos mais importantes:
- dados/arvores-propagacao.json -> dados principais da arvore por geracao e por ramo
- dados/pessoas-v2-cartoes-base.json -> cadastro geral oficial de pessoas
- paginas/*.html -> paginas principais das arvores (Lorena, Alice, Pedro, Rafael, Luna, Gabriela)
- js/arvore-propagacao.js -> script que monta a arvore a partir do JSON
- paginas/arvores.css -> estilos visuais das arvores

## 2) Como abrir localmente

Opcao simples:
1. Abrir a pasta do projeto no VS Code.
2. Abrir um arquivo como paginas/alice.html.
3. Usar extensao de servidor local (ex.: Live Server) e abrir no navegador.

Opcao alternativa:
1. Publicar no GitHub Pages (repositorio pizziranihp.github.io).
2. Abrir pela URL publicada.

Observacao de consolidacao:
- Considerar nucleo-familiar-planejado_2 como base canonica atual.

## 3) Regra de ouro para nao quebrar

- Nao editar paginas legadas de propagacao para cadastrar dados.
- Cadastrar e corrigir informacoes no JSON.
- Paginas HTML principais sao visualizacao, nao fonte de verdade.

Fluxo correto:
1. Editar dados/arvores-propagacao.json
2. Se necessario, editar dados/pessoas-v2-cartoes-base.json
3. Recarregar a pagina da arvore e conferir resultado

## 4) Backup e preservacao (recomendado)

Aplicar regra 3-2-1:
- 3 copias do projeto
- 2 tipos de midia diferentes
- 1 copia fora de casa

Sugestao pratica:
- Copia A: computador principal
- Copia B: SSD externo ou pendrive dedicado
- Copia C: nuvem e/ou outro local fisico

## 5) Rotina anual de manutencao

Uma vez por ano:
1. Fazer backup completo da pasta do projeto.
2. Abrir uma pagina principal (ex.: paginas/alice.html) e confirmar que carrega.
3. Validar se os arquivos JSON abrem normalmente.
4. Registrar a data da verificacao no final deste documento.

## 6) Recuperacao rapida em caso de perda

1. Restaurar a ultima copia de backup da pasta completa.
2. Abrir no VS Code.
3. Testar paginas/lorena.html e paginas/alice.html.
4. Se abrir normalmente, projeto recuperado.

## 7) Padrao para dados de treino

Quando quiser praticar sem confundir com dados reais:
- usar nomes ficticios
- marcar confianca como fake
- usar endereco ficticio
- se desistir, voltar para placeholder

## 8) Contatos e referencias

Preencher quando possivel:
- Responsavel atual pelo projeto: ____________________
- Segundo responsavel (backup humano): ____________________
- Data da ultima revisao deste documento: ____________________

## 9) Historico de verificacoes anuais

- ____/____/______ - Verificacao realizada por: ____________________
- ____/____/______ - Verificacao realizada por: ____________________
- ____/____/______ - Verificacao realizada por: ____________________
