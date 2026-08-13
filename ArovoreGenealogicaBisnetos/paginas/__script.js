document.addEventListener('DOMContentLoaded', function () {
    const supportStyleId = 'auto-genealogia-ramo-id-style';
    const genealogicalCodeById = new Map();

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
            ,
            '.card-codigo-genealogico { display: inline-block; margin-top: 4px; font-size: 10px; line-height: 1.1; font-weight: 700;',
            'padding: 3px 7px; border-radius: 9px; background: #f8fafc; color: #304255; border: 1px dashed #9aa6b2;',
            'pointer-events: none; letter-spacing: 0.3px; }'
        ].join(' ');
        document.head.appendChild(style);
    }

    function buildFallbackGenealogicalCode(card, personId) {
        const normalized = normalizePersonId(personId);
        if (!normalized) {
            return '';
        }

        const generation = parseInt(normalized.slice(0, 2), 10);
        return 'G' + String(generation) + '-' + normalized;
    }

    function canonicalLineageFromCard(card, personId) {
        const generation = parseInt(String(personId || '').slice(0, 2), 10);
        if (generation === 1) {
            return 'C';
        }

        if (card.classList.contains('ramo-paterno')) {
            return 'LP';
        }
        if (card.classList.contains('ramo-materno')) {
            return 'LM';
        }

        const row = card.closest('.linha-geracao');
        if (row && row.classList.contains('linha-tetravos-azul')) {
            return 'LP';
        }
        if (row && row.classList.contains('linha-tetravos-verde')) {
            return 'LM';
        }

        const lastDigit = parseInt(String(personId || '').slice(-1), 10);
        return Number.isNaN(lastDigit) ? 'LP' : (lastDigit % 2 === 0 ? 'LM' : 'LP');
    }

    function canonicalCodeFromCard(card, personId) {
        const normalized = normalizePersonId(personId);
        if (!normalized) {
            return '';
        }

        const generation = parseInt(normalized.slice(0, 2), 10);
        return 'G' + String(generation) + '-' + canonicalLineageFromCard(card, normalized) + '-' + normalized;
    }

    function detectGenerationFromCard(card) {
        if (card.classList.contains('card-bisneta') || card.classList.contains('card-bisneto')) return 1;
        if (card.classList.contains('card-pais')) return 2;
        if (card.classList.contains('card-avos')) return 3;
        if (card.classList.contains('card-bisavos')) return 4;
        if (card.classList.contains('card-trisavos')) return 5;

        const img = card.querySelector('img');
        if (!img) {
            return 0;
        }

        if (img.classList.contains('foto-tetravos')) return 6;
        if (img.classList.contains('foto-hexaavos')) return 7;
        return 0;
    }

    function ensureGenealogicalBadge(card, personId) {
        const displayId = normalizePersonId(card.getAttribute('data-display-id'));
        const sourceId = displayId || normalizePersonId(personId);
        const codigo = buildFallbackGenealogicalCode(card, sourceId) || genealogicalCodeById.get(personId);
        const canonical = canonicalCodeFromCard(card, sourceId);
        if (!codigo) {
            return;
        }

        if (canonical) {
            card.setAttribute('data-codigo-canonico', canonical);
            card.setAttribute('data-linhagem-canonica', canonicalLineageFromCard(card, sourceId));
        }

        let badge = card.querySelector('.card-codigo-genealogico');
        if (!badge) {
            badge = document.createElement('span');
            badge.className = 'card-codigo-genealogico';
            card.appendChild(badge);
        }
        badge.textContent = codigo;
    }

    function applyDisplaySequenceBadges() {
        const counters = {};
        const rows = Array.from(document.querySelectorAll('.linha-geracao'));

        rows.forEach(function (row) {
            const cards = Array.from(row.querySelectorAll(':scope > .card-pessoa'));
            cards.forEach(function (card) {
                if (isPlaceholderCard(card)) {
                    return;
                }

                const generation = detectGenerationFromCard(card);
                if (!generation) {
                    return;
                }

                counters[generation] = (counters[generation] || 0) + 1;
                const displayId = String(generation).padStart(2, '0') + String(counters[generation]).padStart(2, '0');
                card.setAttribute('data-display-id', displayId);

                let badge = card.querySelector('.card-id');
                if (!badge) {
                    badge = document.createElement('span');
                    badge.className = 'card-id';
                    card.appendChild(badge);
                }

                badge.textContent = 'ID ' + displayId;
                ensureGenealogicalBadge(card, displayId);
            });
        });
    }

    function applyGenealogicalBadges() {
        document.querySelectorAll('.card-pessoa[data-person-id]').forEach(function (card) {
            const personId = normalizePersonId(card.getAttribute('data-person-id'));
            if (!personId) {
                return;
            }
            ensureGenealogicalBadge(card, personId);
        });
    }

    async function loadGenealogicalCodes() {
        try {
            const response = await fetch('../dados/pessoas.json', { cache: 'no-store' });
            if (!response.ok) {
                return;
            }
            const raw = await response.text();
            const sanitized = raw.replace(/\/\*[\s\S]*?\*\//g, '');
            const data = JSON.parse(sanitized);
            const people = Array.isArray(data && data.people) ? data.people : [];

            people.forEach(function (person) {
                const personId = normalizePersonId(person && person.id);
                const code = String(person && person.codigoGenealogico || '').trim();
                if (personId && code) {
                    genealogicalCodeById.set(personId, code);
                }
            });
        } catch (err) {
            // Silently fallback to computed labels when local JSON is unavailable.
        }
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

    function isPlaceholderCard(card) {
        const nome = String(card.querySelector('.nome') && card.querySelector('.nome').textContent || '').trim().toUpperCase();
        const detalhe = String(card.querySelector('.detalhe') && card.querySelector('.detalhe').textContent || '').trim().toUpperCase();
        const img = card.querySelector('img');
        const src = String(img && img.getAttribute('src') || '').trim();

        const genericNames = new Set([
            'BISAVÔ / BISAVÓ', 'BISAVO / BISAVO',
            'TRISAVÔ / TRISAVÓ', 'TRISAVO / TRISAVO',
            'TETRAVÔ / TETRAVÓ', 'TETRAVO / TETRAVO',
            'PENTAVÔ / PENTAVÓ', 'PENTAVO / PENTAVO'
        ]);
        const genericDetails = new Set(['INFORMAÇÕES', 'INFORMACOES', 'ESPAÇO', 'ESPACO']);

        return genericNames.has(nome) || genericDetails.has(detalhe) || src === '../imagens/' || src === '..\/imagens/';
    }

    function autoFillCardData() {
        const cards = Array.from(document.querySelectorAll('.card-pessoa'));
        const perPrefixCounter = {};

        cards.forEach(function (card) {
            if (isPlaceholderCard(card)) {
                return;
            }

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

            ensureGenealogicalBadge(card, personId);
        });
    }

    function autoFillRamoClasses() {
        const rows = Array.from(document.querySelectorAll('.linha-geracao'));

        function inferBranch(card, idx, total, ignoreCardClass) {
            if (!ignoreCardClass && card.classList.contains('ramo-paterno')) {
                return 'paterno';
            }
            if (!ignoreCardClass && card.classList.contains('ramo-materno')) {
                return 'materno';
            }

            const nome = (card.querySelector('.nome') && card.querySelector('.nome').textContent || '').toUpperCase();
            const detalhe = (card.querySelector('.detalhe') && card.querySelector('.detalhe').textContent || '').toUpperCase();
            const combinado = (nome + ' ' + detalhe).normalize('NFD').replace(/[\u0300-\u036f]/g, '');

            if (combinado.includes('PATERN')) {
                return 'paterno';
            }
            if (combinado.includes('MATERN')) {
                return 'materno';
            }

            return idx < Math.ceil(total / 2) ? 'paterno' : 'materno';
        }

        rows.forEach(function (row) {
            const cards = Array.from(row.querySelectorAll(':scope > .card-pessoa'));
            if (!cards.length) {
                return;
            }

            const isG6Row = row.classList.contains('linha-tetravos-verde') || row.classList.contains('linha-tetravos-azul');
            const allCardsMaterno = cards.every(function (card) { return card.classList.contains('ramo-materno'); });
            const allCardsPaterno = cards.every(function (card) { return card.classList.contains('ramo-paterno'); });
            const forcePositionSplit = isG6Row && (allCardsMaterno || allCardsPaterno);

            const classified = cards.map(function (card, idx) {
                const personId = parseInt(normalizePersonId(card.getAttribute('data-person-id')), 10);
                return {
                    card: card,
                    idx: idx,
                    branch: inferBranch(card, idx, cards.length, forcePositionSplit),
                    personId: Number.isNaN(personId) ? Number.MAX_SAFE_INTEGER : personId,
                    placeholder: isPlaceholderCard(card)
                };
            });

            // For generation 6 rows, keep the row-level color rule (verde/azul)
            // only when the row is partial and every known card belongs to one side.
            if (isG6Row) {
                const known = classified.filter(function (entry) {
                    return !entry.placeholder;
                });
                if (!known.length) {
                    cards.forEach(function (card) {
                        card.classList.remove('ramo-paterno', 'ramo-materno');
                    });
                    return;
                }

                const rowIsPartial = known.length < cards.length;
                const singleBranch = known.length > 0 && known.every(function (entry) {
                    return entry.branch === known[0].branch;
                }) ? known[0].branch : '';

                if (rowIsPartial && singleBranch) {
                    row.classList.remove('linha-tetravos-verde', 'linha-tetravos-azul');
                    row.classList.add(singleBranch === 'materno' ? 'linha-tetravos-verde' : 'linha-tetravos-azul');
                    cards.forEach(function (card) {
                        card.classList.remove('ramo-paterno', 'ramo-materno');
                    });
                    return;
                }

                row.classList.remove('linha-tetravos-verde', 'linha-tetravos-azul');
            }

            classified.sort(function (a, b) {
                if (a.branch !== b.branch) {
                    return a.branch === 'paterno' ? -1 : 1;
                }
                if (a.personId !== b.personId) {
                    return a.personId - b.personId;
                }
                return a.idx - b.idx;
            });

            classified.forEach(function (entry) {
                const card = entry.card;
                if (!card.classList.contains('card-bisneta') && !card.classList.contains('card-bisneto')) {
                    card.classList.remove('ramo-paterno', 'ramo-materno');
                    card.classList.add(entry.branch === 'paterno' ? 'ramo-paterno' : 'ramo-materno');
                }
                row.appendChild(card);
            });
        });
    }

    ensureSupportStyles();
    autoFillCardData();
    autoFillRamoClasses();
    loadGenealogicalCodes().then(applyDisplaySequenceBadges);

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


    // Permite abrir o Saiba Mais ao clicar no cartao inteiro.
    document.querySelectorAll('.card-pessoa[data-person-page]').forEach(function (card) {
        card.addEventListener('click', function (event) {
            if (event.target.closest('a') || event.target.closest('button') || event.target.tagName === 'IMG') {
                return;
            }
            const targetPage = card.getAttribute('data-person-page');
            if (targetPage) {
                window.location.href = targetPage;
            }
        });
    });
    // Cria uma barra superior por geracao, com contagem de antecessores.
    const piramideInner = document.querySelector('.piramide-inversa-inner');
    if (!piramideInner) {
        return;
    }

    Array.from(piramideInner.querySelectorAll(':scope > .geracao-barra')).forEach(function (bar) {
        bar.remove();
    });

    Array.from(piramideInner.querySelectorAll('.legenda-linha, .linha-separadora')).forEach(function (node) {
        node.remove();
    });

    const rows = Array.from(piramideInner.querySelectorAll(':scope > .linha-geracao'));
    const groups = [];

    function getGenerationInfo(row) {
        if (row.querySelector('.card-bisneta') || row.querySelector('.card-bisneto')) return { key: 'g1', title: 'Geracao 1 - Bisnetos' };
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
        if (group.key === 'g7') {
            group.rows = group.rows.filter(function (row) {
                const cards = Array.from(row.querySelectorAll(':scope > .card-pessoa'));
                if (cards.length === 1) {
                    row.style.display = 'none';
                    return false;
                }
                return cards.length !== 1;
            });
        }

        if (group.key === 'g7' || group.key === 'g8') {
            if (group.rows[0]) {
                group.rows[0].classList.add('linha-tetravos-azul');
                group.rows[0].classList.remove('linha-tetravos-verde');
            }
            if (group.rows[1]) {
                group.rows[1].classList.add('linha-tetravos-verde');
                group.rows[1].classList.remove('linha-tetravos-azul');
            }
        }

        group.rows.forEach(function (row) {
            row.classList.remove('linha-geracao-compacta');
            if (group.key === 'g7' || group.key === 'g8') {
                row.classList.add('linha-geracao-compacta');
            }
        });

        if (group.key === 'g7' || group.key === 'g8') {
            const MAX_CARDS = 8;
            const allCards = group.rows.flatMap(function (row) {
                return Array.from(row.querySelectorAll(':scope > .card-pessoa'));
            });
            const reais = allCards.filter(function (c) { return !isPlaceholderCard(c); });
            const placeholders = allCards.filter(function (c) { return isPlaceholderCard(c); });
            const vagos = Math.max(0, MAX_CARDS - reais.length);
            placeholders.forEach(function (c, i) {
                c.style.display = i < vagos ? '' : 'none';
            });
        }

        const firstRow = group.rows[0];
        if (!firstRow || firstRow.previousElementSibling && firstRow.previousElementSibling.classList.contains('geracao-barra')) {
            return;
        }

        const totalTeoricoPorGeracao = { g1: 1, g2: 2, g3: 4, g4: 8, g5: 16, g6: 32, g7: 24, g8: 12 };
        const nomePorGeracao = { g1: 'Bisnetos', g2: 'Pais', g3: 'Avos', g4: 'Bisavos', g5: 'Trisavos', g6: 'Tetravos', g7: 'Pentavos', g8: 'Hexavos' };

        const bar = document.createElement('div');
        bar.className = 'geracao-barra';

        const title = document.createElement('div');
        title.className = 'geracao-titulo';
        title.textContent = 'Geracao ' + group.key.slice(1) + ' - ' + (nomePorGeracao[group.key] || group.title) + ' (' + (totalTeoricoPorGeracao[group.key] || 0) + ')';

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

    applyDisplaySequenceBadges();
});

