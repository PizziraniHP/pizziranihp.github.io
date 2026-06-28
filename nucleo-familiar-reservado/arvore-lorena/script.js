document.addEventListener('DOMContentLoaded', function () {
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightbox-img');

    document.querySelectorAll('.card-pessoa img, .foto-zoom').forEach(function (img) {
        img.addEventListener('click', function () {
            if (!lightbox || !lightboxImg) {
                return;
            }
            lightboxImg.src = this.src;
            lightbox.classList.add('active');
        });
    });

    if (lightbox) {
        lightbox.addEventListener('click', function () {
            this.classList.remove('active');
        });
    }

    // Gera o link "Saiba mais" para todo cartao que tiver identificador unico.
    document.querySelectorAll('.card-pessoa[data-person-id]').forEach(function (card) {
        const personId = card.getAttribute('data-person-id');
        const personPage = card.getAttribute('data-person-page');
        if (!personId || card.querySelector('.saiba-mais-link')) {
            return;
        }

        const wrap = document.createElement('div');
        wrap.className = 'saiba-mais-wrap';

        const link = document.createElement('a');
        link.className = 'saiba-mais-link';
        link.href = personPage || ('../pessoa.html?id=' + encodeURIComponent(personId));
        const icon = document.createElement('span');
        icon.className = 'saiba-mais-icone';
        icon.setAttribute('aria-hidden', 'true');

        const label = document.createElement('span');
        label.className = 'saiba-mais-texto';
        label.textContent = 'SAIBA MAIS';

        link.appendChild(icon);
        link.appendChild(label);
        link.setAttribute('aria-label', 'Saiba mais sobre o ID ' + personId);

        wrap.appendChild(link);
        card.appendChild(wrap);
    });

    // Cria barras de geracao com botao de recolher/mostrar por bloco.
    const piramideInner = document.querySelector('.piramide-inversa-inner');
    if (!piramideInner) {
        return;
    }

    const rows = Array.from(piramideInner.querySelectorAll(':scope > .linha-geracao'));
    const groups = [];

    function getGenerationInfo(row) {
        if (row.querySelector('.card-bisneta')) return { key: 'g1', title: 'Geracao 1 - Bisneto' };
        if (row.querySelector('.card-pais')) return { key: 'g2', title: 'Geracao 2 - Pais' };
        if (row.querySelector('.card-avos')) return { key: 'g3', title: 'Geracao 3 - Avos' };
        if (row.querySelector('.card-bisavos')) return { key: 'g4', title: 'Geracao 4 - Bisavos' };
        if (row.querySelector('.card-trisavos')) return { key: 'g5', title: 'Geracao 5 - Trisavos' };
        if (row.querySelector('.foto-tetravos')) return { key: 'g6', title: 'Geracao 6 - Tetravos' };
        if (row.querySelector('.foto-hexaavos')) return { key: 'g7', title: 'Geracao 7 - Pentavos' };
        return null;
    }

    rows.forEach(function (row) {
        const info = getGenerationInfo(row);
        if (!info) {
            return;
        }

        const last = groups[groups.length - 1];
        if (!last || last.key !== info.key) {
            groups.push({ key: info.key, title: info.title, rows: [row] });
            return;
        }

        last.rows.push(row);
    });

    groups.forEach(function (group) {
        const firstRow = group.rows[0];
        if (!firstRow || firstRow.previousElementSibling && firstRow.previousElementSibling.classList.contains('geracao-barra')) {
            return;
        }

        const bar = document.createElement('div');
        bar.className = 'geracao-barra';

        const title = document.createElement('div');
        title.className = 'geracao-titulo';
        title.textContent = group.title;

        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'geracao-toggle';
        btn.textContent = 'Recolher';

        let collapsed = false;
        btn.addEventListener('click', function () {
            collapsed = !collapsed;
            group.rows.forEach(function (row) {
                row.style.display = collapsed ? 'none' : '';
            });
            btn.textContent = collapsed ? 'Mostrar' : 'Recolher';
        });

        bar.appendChild(title);
        bar.appendChild(btn);
        piramideInner.insertBefore(bar, firstRow);
    });
});
