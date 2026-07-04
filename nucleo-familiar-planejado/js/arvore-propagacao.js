(function () {
  var saibaMaisCache = Object.create(null);
  var saibaMaisIndexById = null;
  var saibaMaisIndexLoadPromise = null;

  function normalizeId(raw) {
    var digits = String(raw || '').replace(/\D/g, '');
    return digits ? digits.padStart(4, '0').slice(0, 4) : '';
  }

  function codeFromId(id) {
    var n = normalizeId(id);
    if (!n) return '';
    var g = parseInt(n.slice(0, 2), 10);
    var last = parseInt(n.slice(-1), 10);
    var role = Number.isNaN(last) ? 'PP' : (last % 2 === 0 ? 'PM' : 'PP');
    return 'G' + g + role + '-' + n;
  }

  function clsByGeneration(g) {
    if (g === 1) return { card: 'card-bisneta', img: 'foto-bisneta', label: 'Bisneto' };
    if (g === 2) return { card: 'card-pais', img: 'foto-pais', label: 'Pais' };
    if (g === 3) return { card: 'card-avos', img: 'foto-avos', label: 'Avos' };
    if (g === 4) return { card: 'card-bisavos', img: 'foto-bisavos', label: 'Bisavos' };
    if (g === 5) return { card: 'card-trisavos', img: 'foto-tataravos', label: 'Trisavos' };
    if (g === 6) return { card: 'card-tataravos', img: 'foto-tetravos', label: 'Tetravos' };
    if (g === 7) return { card: 'card-tataravos', img: 'foto-pentaavos', label: 'Pentavos' };
    return { card: 'card-tataravos', img: 'foto-hexaavos', label: 'Hexavos' };
  }

  function expectedCountByGeneration(g) {
    if (!Number.isFinite(g) || g < 1) return 0;
    return Math.pow(2, g - 1);
  }

  function expandEntries(entries, sharedBlocks) {
    var output = [];
    (entries || []).forEach(function (entry) {
      if (entry && typeof entry === 'object' && entry.$ref) {
        var refCards = sharedBlocks && sharedBlocks[entry.$ref];
        if (Array.isArray(refCards)) {
          output = output.concat(expandEntries(refCards, sharedBlocks));
        }
        return;
      }
      output.push(entry);
    });
    return output;
  }

  function chunkCards(cards, size) {
    var chunks = [];
    for (var i = 0; i < cards.length; i += size) {
      chunks.push(cards.slice(i, i + size));
    }
    return chunks;
  }

  function slugify(value) {
    return String(value || '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '');
  }

  function saibaMaisCandidates(personId, personName) {
    var id = normalizeId(personId);
    if (!id) {
      return [];
    }

    var slug = slugify(personName);
    var candidates = [id + '.html'];

    if (slug) {
      candidates.push(id + '-' + slug + '.html');
      candidates.push(id + '_' + slug.replace(/-/g, '') + '.html');
      candidates.push(id + '_' + slug.replace(/-/g, '_') + '.html');
    }

    return Array.from(new Set(candidates));
  }

  async function ensureSaibaMaisIndexMap(basePath) {
    if (saibaMaisIndexById) {
      return saibaMaisIndexById;
    }

    if (saibaMaisIndexLoadPromise) {
      return saibaMaisIndexLoadPromise;
    }

    saibaMaisIndexLoadPromise = (async function () {
      var byId = Object.create(null);
      try {
        var res = await fetch(basePath + 'index.html', { cache: 'no-store' });
        if (!res.ok) {
          saibaMaisIndexById = byId;
          return byId;
        }

        var html = await res.text();
        var hrefRegex = /href\s*=\s*"([^"]+)"/gi;
        var match;
        while ((match = hrefRegex.exec(html)) !== null) {
          var href = String(match[1] || '').trim();
          if (!href || /index\.html$/i.test(href)) {
            continue;
          }

          var fileName = href.split('/').pop();
          var idMatch = fileName && fileName.match(/^(\d{4})(?:[-_]|[a-zA-Z])/);
          if (!idMatch) {
            continue;
          }

          var id = normalizeId(idMatch[1]);
          if (!id) {
            continue;
          }

          if (!byId[id]) {
            byId[id] = basePath + fileName;
          }
        }
      } catch (err) {
        // Mantem mapa vazio em caso de erro e segue com fallback por padrao de nome.
      }

      saibaMaisIndexById = byId;
      return byId;
    })();

    return saibaMaisIndexLoadPromise;
  }

  async function resolveSaibaMaisPage(basePath, personId, personName) {
    var id = normalizeId(personId);
    if (!id) {
      return basePath + 'index.html';
    }

    if (saibaMaisCache[id]) {
      return saibaMaisCache[id];
    }

    var indexMap = await ensureSaibaMaisIndexMap(basePath);
    if (indexMap && indexMap[id]) {
      saibaMaisCache[id] = indexMap[id];
      return saibaMaisCache[id];
    }

    var candidates = saibaMaisCandidates(id, personName);
    for (var i = 0; i < candidates.length; i += 1) {
      var url = basePath + candidates[i];
      try {
        var res = await fetch(url, { cache: 'no-store' });
        if (res.ok) {
          saibaMaisCache[id] = url;
          return url;
        }
      } catch (err) {
        // Ignora erro de tentativa e segue para o proximo padrao.
      }
    }

    saibaMaisCache[id] = basePath + 'index.html';
    return saibaMaisCache[id];
  }

  function appendOriginParam(url) {
    try {
      var current = window.location.pathname + window.location.search + window.location.hash;
      var parsed = new URL(url, window.location.href);
      parsed.searchParams.set('from', current);
      return parsed.toString();
    } catch (err) {
      return url;
    }
  }

  function renderLine(cards, generation, imagePrefix) {
    if (!cards || !cards.length) {
      return '';
    }

    var cfg = clsByGeneration(generation);
    var rows = generation >= 4 ? chunkCards(cards, 8) : [cards];
    var html = '';
    rows.forEach(function (row) {
      var rowClass = generation >= 4
        ? ('linha-geracao linha-8' + (row.length < 8 ? ' linha-parcial' : ''))
        : 'linha-geracao';
      html += '<div class="' + rowClass + '">';
      row.forEach(function (p) {
        var ramoCls = p.ramo === 'paterno' ? 'ramo-paterno' : 'ramo-materno';
        var id = normalizeId(p.id);
        var isPlaceholder = !id || !!p.placeholder;
        var detalhe = p.detalhe || '';
        var codigo = codeFromId(id);
        var idAttr = id ? ' data-person-id="' + id + '"' : '';
        var imgPrefix = typeof imagePrefix === 'string' ? imagePrefix : '../../';
        var imagem = p && p.imagem ? p.imagem : '';
        html += [
          '<div class="card-pessoa ' + cfg.card + ' ' + ramoCls + '"' + idAttr + ' data-person-name="' + (p.nome || '') + '">',
          '<img src="' + imgPrefix + imagem + '" class="' + cfg.img + '" alt="' + (p.nome || '') + '">',
          '<div class="nome">' + (p.nome || '') + '</div>',
          '<div class="detalhe">' + detalhe + '</div>',
          isPlaceholder ? '' : '<span class="card-id">ID ' + id + '</span>',
          isPlaceholder ? '' : '<span class="card-codigo-genealogico">' + codigo + '</span>',
          isPlaceholder ? '' : '<div class="saiba-mais-wrap"><a class="saiba-mais-link" href="saiba-mais/index.html" data-saiba-mais="1" data-person-id="' + id + '" data-person-name="' + (p.nome || '') + '"><span class="saiba-mais-icone" aria-hidden="true"></span><span class="saiba-mais-texto">SAIBA MAIS</span></a></div>',
          '</div>'
        ].join('');
      });
      html += '</div>';
    });
    var expected = expectedCountByGeneration(generation);
    var known = cards.filter(function (p) {
      return p && !p.placeholder && normalizeId(p.id);
    }).length;
    html += '<div class="legenda-linha">' + cfg.label + ' (' + known + ' de ' + expected + ')</div><div class="linha-separadora"></div>';
    return html;
  }

  function generationInfoFromRow(row) {
    if (row.querySelector('.card-bisneta, .card-bisneto')) return { key: 'g1', title: 'Geracao 1' };
    if (row.querySelector('.card-pais')) return { key: 'g2', title: 'Geracao 2' };
    if (row.querySelector('.card-avos')) return { key: 'g3', title: 'Geracao 3' };
    if (row.querySelector('.card-bisavos')) return { key: 'g4', title: 'Geracao 4' };
    if (row.querySelector('.card-trisavos')) return { key: 'g5', title: 'Geracao 5' };
    if (row.querySelector('.foto-tetravos')) return { key: 'g6', title: 'Geracao 6' };
    if (row.querySelector('.foto-pentaavos')) return { key: 'g7', title: 'Geracao 7' };
    if (row.querySelector('.foto-hexaavos')) return { key: 'g8', title: 'Geracao 8' };
    return null;
  }

  function createGenerationBars(root) {
    var rows = Array.from(root.querySelectorAll(':scope > .linha-geracao'));
    var groups = [];

    rows.forEach(function (row) {
      var info = generationInfoFromRow(row);
      if (!info) {
        return;
      }

      var last = groups[groups.length - 1];
      if (!last || last.key !== info.key) {
        groups.push({ key: info.key, title: info.title, rows: [row], extras: [] });
        return;
      }

      last.rows.push(row);
    });

    groups.forEach(function (group) {
      var firstRow = group.rows[0];
      var lastRow = group.rows[group.rows.length - 1];
      if (!firstRow || !lastRow) {
        return;
      }

      var next = lastRow.nextElementSibling;
      while (next && (next.classList.contains('legenda-linha') || next.classList.contains('linha-separadora'))) {
        group.extras.push(next);
        next = next.nextElementSibling;
      }

      if (firstRow.previousElementSibling && firstRow.previousElementSibling.classList.contains('geracao-barra')) {
        return;
      }

      var bar = document.createElement('div');
      bar.className = 'geracao-barra';

      var title = document.createElement('div');
      title.className = 'geracao-titulo';
      title.textContent = group.title;

      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'geracao-toggle';
      btn.textContent = 'Recolher';

      var collapsed = false;
      btn.addEventListener('click', function () {
        collapsed = !collapsed;
        group.rows.forEach(function (row) {
          row.style.display = collapsed ? 'none' : '';
        });
        group.extras.forEach(function (extra) {
          extra.style.display = collapsed ? 'none' : '';
        });
        btn.textContent = collapsed ? 'Mostrar' : 'Recolher';
      });

      bar.appendChild(title);
      bar.appendChild(btn);
      root.insertBefore(bar, firstRow);
    });
  }

  window.initArvorePropagacao = async function initArvorePropagacao(opts) {
    var treeKey = opts && opts.treeKey;
    var dataPath = opts && opts.dataPath ? opts.dataPath : '../../dados/arvores-propagacao.json';
    var imagePrefix = opts && Object.prototype.hasOwnProperty.call(opts, 'imagePrefix') ? opts.imagePrefix : '../../';
    var saibaMaisBasePath = opts && opts.saibaMaisBasePath ? opts.saibaMaisBasePath : 'saiba-mais/';
    var target = document.getElementById(opts && opts.containerId || 'piramide-root');
    if (!treeKey || !target) return;

    var res = await fetch(dataPath, { cache: 'no-store' });
    var data = await res.json();

    var tree = data && data.trees && data.trees[treeKey];
    if (!tree) return;

    var sharedBlocks = data && data.sharedBlocks ? data.sharedBlocks : {};
    var h1 = document.getElementById('arvore-title');
    var h2 = document.getElementById('arvore-subtitle');
    if (h1) h1.textContent = tree.titulo || '';
    if (h2) h2.textContent = tree.subtitulo || '';

    var html = '';
    html += renderLine(expandEntries(tree.g1 || [], sharedBlocks), 1, imagePrefix);
    html += renderLine(expandEntries(tree.g2 || [], sharedBlocks), 2, imagePrefix);
    html += renderLine(expandEntries(tree.g3 || [], sharedBlocks), 3, imagePrefix);
    html += renderLine(expandEntries(tree.g4 || [], sharedBlocks), 4, imagePrefix);
    html += renderLine(expandEntries(tree.g5 || [], sharedBlocks), 5, imagePrefix);
    html += renderLine(expandEntries(tree.g6 || [], sharedBlocks), 6, imagePrefix);
    html += renderLine(expandEntries(tree.g7 || [], sharedBlocks), 7, imagePrefix);
    html += renderLine(expandEntries(tree.g8 || [], sharedBlocks), 8, imagePrefix);

    target.innerHTML = html;
    createGenerationBars(target);

    var lb = document.getElementById('lightbox');
    var lbImg = document.getElementById('lightbox-img');
    target.querySelectorAll('img').forEach(function (img) {
      img.addEventListener('click', function () {
        if (!lb || !lbImg) return;
        lb.style.display = 'flex';
        lbImg.src = img.src;
      });
    });

    target.querySelectorAll('.saiba-mais-link[data-saiba-mais="1"]').forEach(function (link) {
      link.addEventListener('click', async function (event) {
        event.preventDefault();
        var personId = link.getAttribute('data-person-id') || '';
        var personName = link.getAttribute('data-person-name') || '';
        var url = await resolveSaibaMaisPage(saibaMaisBasePath, personId, personName);
        window.location.href = appendOriginParam(url);
      });
    });

    target.querySelectorAll('.card-pessoa[data-person-id]').forEach(function (card) {
      card.addEventListener('click', async function (event) {
        if (event.target.closest('a') || event.target.closest('button') || event.target.tagName === 'IMG') {
          return;
        }

        var personId = card.getAttribute('data-person-id') || '';
        var personName = card.getAttribute('data-person-name') || '';
        if (!personId) {
          return;
        }

        var url = await resolveSaibaMaisPage(saibaMaisBasePath, personId, personName);
        window.location.href = appendOriginParam(url);
      });
    });

    if (lb) lb.addEventListener('click', function () { lb.style.display = 'none'; });
  };
})();
