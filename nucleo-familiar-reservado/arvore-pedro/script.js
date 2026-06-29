document.addEventListener('DOMContentLoaded', function () {
    const supportStyleId = 'auto-genealogia-ramo-id-style';

    function ensureSupportStyles() {
        if (document.getElementById(supportStyleId)) {
            return;
        }

        const style = document.createElement('style');
        style.id = supportStyleId;
        style.textContent = [
            '.ramo-paterno { background: #d6e8f7 !important; border-left: 4px solid #2980b9 !important; }',
            '.ramo-materno { background: #d5f0e0 !important; border-left: 4px solid #27ae60 !important; }',
            '.card-id { display: inline-block; margin-top: 6px; font-size: 11px; line-height: 1; font-weight: 700;',
            'padding: 4px 8px; border-radius: 10px; background: #fff; color: #1f2a37; border: 1px solid #9aa6b2;',
            'pointer-events: none; box-shadow: 0 1px 2px rgba(0, 0, 0, 0.12); }'
        ].join(' ');
        document.head.appendChild(style);
    }

    function slugify(value) {
        return (value || '')
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/(^-|-$)/g, '')
            .slice(0, 50);
    }

    function normalizePersonId(raw) {
        const digits = String(raw || '').replace(/\D/g, '');
        if (!digits) {
            return '';
        }
        if (digits.length >= 4) {
            return digits.slice(0, 4);
        }
        return digits.padStart(4, '0');
    }

    function extractIdFromText(rawText) {
        const text = String(rawText || '');
        const match4 = text.match(/(\d{4})/);
        if (match4) {
            return normalizePersonId(match4[1]);
        }
        const match3 = text.match(/(\d{3})/);
        if (match3) {
            return normalizePersonId(match3[1]);
        }
        return '';
    }

    function getIdFromPreviousComments(card) {
        let node = card.previousSibling;
        let steps = 0;
        while (node && steps < 8) {
            if (node.nodeType === 8) {
                const fromComment = extractIdFromText(node.nodeValue || '');
                if (fromComment) {
                    return fromComment;
                }
            }
            node = node.previousSibling;
            steps += 1;
        }
        return '';
    }

    function inferPrefix(card) {
        if (card.classList.contains('card-bisneta') || card.classList.contains('card-bisneto')) return '01';
        if (card.classList.contains('card-pais')) return '02';
        if (card.classList.contains('card-avos')) return '03';
        if (card.classList.contains('card-bisavos')) return '04';
        if (card.classList.contains('card-trisavos')) return '05';
        if (card.classList.contains('card-tataravos')) return '06';
        return '09';
    }

    function inferIdFromImage(card) {
        const img = card.querySelector('img');
        if (!img) {
            return '';
        }
        const src = img.getAttribute('src') || '';
        const match = src.match(/(?:^|\/)(\d{3,4})(?:[_\-\.])/);
        return match ? normalizePersonId(match[1]) : '';
    }

    function autoFillCardData() {
        const cards = Array.from(document.querySelectorAll('.card-pessoa'));
        const perPrefixCounter = {};

        cards.forEach(function (card) {
            let personId = normalizePersonId(card.getAttribute('data-person-id'));
            if (!personId) {
                personId = normalizePersonId(extractIdFromText(card.getAttribute('data-person-page')));
            }
            if (!personId) {
                personId = inferIdFromImage(card);
            }
            if (!personId) {
                personId = getIdFromPreviousComments(card);
            }

            if (!personId) {
                const prefix = inferPrefix(card);
                perPrefixCounter[prefix] = (perPrefixCounter[prefix] || 0) + 1;
                personId = prefix + String(perPrefixCounter[prefix]).padStart(2, '0');
            }

            card.setAttribute('data-person-id', personId);

            if (!card.getAttribute('data-person-page')) {
                const nome = (card.querySelector('.nome') && card.querySelector('.nome').textContent || '').trim();
                const slug = slugify(nome) || 'pessoa';
                card.setAttribute('data-person-page', '../saiba-mais/' + personId + '-' + slug + '.html');
            }

            const img = card.querySelector('img');
            if (img) {
                img.setAttribute('data-person-id', personId);
                if (!img.getAttribute('alt')) {
                    const nome = (card.querySelector('.nome') && card.querySelector('.nome').textContent || '').trim();
                    img.setAttribute('alt', nome || ('Pessoa ID ' + personId));
                }
            }

            if (!card.querySelector('.card-id')) {
                const badge = document.createElement('span');
                badge.className = 'card-id';
                badge.textContent = 'ID ' + personId;
                card.appendChild(badge);
            }
        });
    }

    function autoFillRamoClasses() {
        const rows = Array.from(document.querySelectorAll('.linha-geracao'));

        rows.forEach(function (row) {
            const cards = Array.from(row.querySelectorAll(':scope > .card-pessoa'));
            if (!cards.length) {
                return;
            }

            cards.forEach(function (card) {
                if (card.classList.contains('card-bisneta') || card.classList.contains('card-bisneto')) {
                    return;
                }
                if (card.classList.contains('ramo-paterno') || card.classList.contains('ramo-materno')) {
                    return;
                }

                const nome = (card.querySelector('.nome') && card.querySelector('.nome').textContent || '').toUpperCase();
                const detalhe = (card.querySelector('.detalhe') && card.querySelector('.detalhe').textContent || '').toUpperCase();
                const combinado = (nome + ' ' + detalhe).normalize('NFD').replace(/[\u0300-\u036f]/g, '');

                if (combinado.includes('PATERN')) {
                    card.classList.add('ramo-paterno');
                } else if (combinado.includes('MATERN')) {
                    card.classList.add('ramo-materno');
                }
            });

            const semRamo = cards.filter(function (card) {
                return !card.classList.contains('card-bisneta')
                    && !card.classList.contains('card-bisneto')
                    && !card.classList.contains('ramo-paterno')
                    && !card.classList.contains('ramo-materno');
            });

            if (!semRamo.length) {
                return;
            }

            const metade = Math.ceil(semRamo.length / 2);
            semRamo.forEach(function (card, idx) {
                card.classList.add(idx < metade ? 'ramo-paterno' : 'ramo-materno');
            });
        });
    }

    ensureSupportStyles();
    autoFillCardData();
    autoFillRamoClasses();

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
