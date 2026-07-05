const cards = [
  {
    title: 'Dados centrais',
    text: 'Um unico lugar para os objetos de pessoas, relacoes e codigos genealogicos.'
  },
  {
    title: 'Imagens organizadas',
    text: 'Subdiretorios separados por contexto para evitar duplicacao e confusao.'
  },
  {
    title: 'Migracao gradual',
    text: 'Cada etapa pode sair do projeto antigo para o novo sem interromper a pagina publicada.'
  },
  {
    title: 'Padroes e validacao',
    text: 'Regras claras para cadastrar, reaproveitar e validar o que entra na arvore.'
  }
];

const container = document.querySelector('#cards');
const treeContainer = document.querySelector('#tree-cards');
const linksContainer = document.querySelector('#bisneto-links');
const treePages = {
  lorena: 'paginas/lorena.html',
  alice: 'paginas/alice.html',
  pedro: 'paginas/pedro.html',
  rafael: 'paginas/rafael.html',
  luna: 'paginas/luna.html',
  gabriela: 'paginas/gabriela.html'
};

if (container) {
  container.innerHTML = cards
    .map(
      (card) => `
        <article class="card">
          <h2>${card.title}</h2>
          <p>${card.text}</p>
        </article>
      `
    )
    .join('');
}

if (treeContainer || linksContainer) {
  fetch('dados/pessoas-v2-cartoes-base.json?v=20260705', { cache: 'no-store' })
    .then((res) => res.json())
    .then((data) => {
      const pessoas = Array.isArray(data?.pessoas) ? data.pessoas : [];
      const bisnetos = pessoas
        .filter((pessoa) => Number(pessoa.geracao) === 1)
        .sort((a, b) => {
          const ordemA = Number(a.ordemNascimento) || 999;
          const ordemB = Number(b.ordemNascimento) || 999;
          return ordemA - ordemB;
        });

      treeContainer.innerHTML = bisnetos
        .map((pessoa) => {
          const ordem = Number(pessoa.ordemNascimento) || '';
          const pagina = treePages[pessoa.ramo] || '';
          const paginaSaibaMais = `paginas/saiba-mais/${String(pessoa.id).padStart(4, '0')}-${String(pessoa.ramo || '').toLowerCase()}.html`;
          const status = pagina ? 'Disponivel' : 'Em preparo';
          const action = pagina
            ? `<div class="tree-card-actions"><a class="tree-link" href="${pagina}">Abrir arvore</a><a class="tree-link" href="${paginaSaibaMais}">Saiba Mais</a></div>`
            : '<span class="tree-link tree-link-disabled">Arvore em preparo</span>';

          return `
            <article class="card tree-card">
              <div class="tree-order">${ordem}</div>
              <p class="tree-id">ID ${pessoa.id}</p>
              <h3>${pessoa.nome}</h3>
              <p class="tree-status">${status}</p>
              ${action}
            </article>
          `;
        })
        .join('');

      if (linksContainer) {
        linksContainer.innerHTML = bisnetos
          .map((pessoa) => {
            const paginaArvore = treePages[pessoa.ramo] || '';
            const paginaSaibaMais = `paginas/saiba-mais/${String(pessoa.id).padStart(4, '0')}-${String(pessoa.ramo || '').toLowerCase()}.html`;

            return `
              <article class="card bisneto-link-card">
                <h3>${pessoa.id} - ${pessoa.nome}</h3>
                <div class="bisneto-link-actions">
                  ${paginaArvore ? `<a class="tree-link" href="${paginaArvore}">Abrir arvore</a>` : '<span class="tree-link tree-link-disabled">Arvore em preparo</span>'}
                  <a class="tree-link" href="${paginaSaibaMais}">Abrir Saiba Mais</a>
                </div>
              </article>
            `;
          })
          .join('');
      }
    })
    .catch(() => {
      treeContainer.innerHTML = '<article class="card tree-card"><p>Falha ao carregar a ordem padrao das arvores.</p></article>';
      if (linksContainer) {
        linksContainer.innerHTML = '<article class="card"><p>Falha ao carregar links dos bisnetos.</p></article>';
      }
    });
}
