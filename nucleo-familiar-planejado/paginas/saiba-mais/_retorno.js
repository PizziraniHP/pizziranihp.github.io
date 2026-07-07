(function () {
  function applySharedTheme() {
    // Verifica se theme já foi injetado
    'use strict';
    if (document.querySelector('style[data-shared-theme="1"]')) return;

    var styleContent = `
/* Tema visual compartilhado para Saiba Mais e Extra Saiba Mais */
/* Paleta alinhada com as páginas de árvore dos bisnetos */

body {
    background: linear-gradient(160deg, #2c1a0e 0%, #4a2c14 42%, #1e1208 100%) !important;
    margin-top: 0;
}

/* Painel de conteúdo — mantido claro para legibilidade do texto */
.page {
    background: #fffdf7 !important;
    border: 8px solid #3a2210 !important;
    /* v2 - Force CSS injection */
    border-radius: 14px !important;
    box-shadow:
        0 0 0 2px rgba(201, 168, 76, 0.65),
        inset 0 0 0 1px rgba(201, 168, 76, 0.25),
        0 14px 36px rgba(0, 0, 0, 0.40) !important;
    margin-top: 18px !important;
    margin-bottom: 18px !important;
    overflow: hidden;
    position: relative;
}

/* Link "voltar" — estilo botão dourado igual ao das árvores */
.top-links {
    display: flex;
    justify-content: center;
    margin-bottom: 18px;
    font-size: 14px;
}

.top-links a {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: linear-gradient(135deg, #c9a84c, #e8c97a);
    border: 1px solid #f2dc9d;
    border-radius: 999px;
    padding: 7px 18px;
    color: #2c1a0e !important;
    font-weight: 700;
    letter-spacing: 0.03em;
    text-decoration: none !important;
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.22);
}

.top-links a:hover {
    filter: brightness(1.06);
    transform: translateY(-1px);
    text-decoration: none !important;
}

/* Badge "SAIBA MAIS" — bordas douradas */
.saiba-mais-badge,
.badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 11px;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: #4a2b10;
    border: 1px solid #c9a84c;
    border-radius: 999px;
    background: #fff8e3;
    padding: 6px 14px;
}

/* Caixas de foto e itens internos */
.photo-box,
.item,
.img-galeria-item,
.foto-item {
    border-radius: 10px;
    border: 1px solid #ddd7ca;
    background: #faf8f3;
}

/* Borda nas fotos — acabamento tipo porta-retrato generoso, marrom-dourado */
.photo-box img,
figure img,
.extra-item img,
.extra-item-small img {
    border: 8px solid #3a2210;
    outline: 2px solid rgba(201, 168, 76, 0.65);
    border-radius: 6px;
    box-shadow: inset 0 0 0 2px rgba(201, 168, 76, 0.3), 0 6px 16px rgba(0,0,0,0.28);
    box-sizing: border-box;
}

/* Linha separadora interna no estilo das árvores */
.extra {
    border-top: 2px solid rgba(201, 168, 76, 0.35);
}

h1 { line-height: 1.1; }

h2 { color: #3f2a11; }

/* Ocultar título técnico "Fotos menores (adicionais)" */
.extra.extra-small > h2 {
    display: none;
}

/* Requadro nos blocos de texto — história, descrições e legendas de fotos */
.story,
.meta p,
.meta,
.extra-item p,
.extra-item-small p {
    border: 2px solid rgba(58, 34, 16, 0.25);
    border-left: 4px solid #3a2210;
    border-radius: 8px;
    background: #fff8ee;
    padding: 14px 16px;
    margin-bottom: 14px;
    box-shadow: inset 0 0 0 1px rgba(201, 168, 76, 0.18);
}

/* Legendas das fotos em negrito */
figure p,
figure figcaption,
.extra-item p,
.extra-item-small p {
    font-weight: 700;
}

/* Botão fechar lightbox */
.img-lightbox-close {
    border-radius: 999px;
    border: 1px solid #c9a84c;
    background: #fff8e3;
    color: #4a2b10;
}
    `;

    var style = document.createElement('style');
    style.setAttribute('data-shared-theme', '1');
    style.textContent = styleContent;
    document.head.appendChild(style);
  }

  function readFromQuery() {
    try {
      var params = new URLSearchParams(window.location.search);
      return (params.get('from') || '').trim();
    } catch (err) {
      return '';
    }
  }

  function isSameOriginUrl(url) {
    try {
      var parsed = new URL(url, window.location.href);
      // Rejeita origins nulas (about:blank, data:, etc.)
      if (!parsed.origin || parsed.origin === 'null') return false;
      return parsed.origin === window.location.origin;
    } catch (err) {
      return false;
    }
  }

  function buildFallback(fallbackHref) {
    var href = String(fallbackHref || '').trim();
    return href || '../../elo_indice.html';
  }

  function resolveBackTarget(fallbackHref) {
    var from = readFromQuery();
    if (from) {
      try {
        var fromUrl = new URL(from, window.location.href);
        if (fromUrl.origin === window.location.origin && fromUrl.href !== window.location.href) {
          return fromUrl.href;
        }
      } catch (err) {
        // Ignora parametro invalido e segue para outras opcoes.
      }
    }

    var ref = document.referrer || '';
    if (ref && isSameOriginUrl(ref) && ref !== window.location.href) {
      return ref;
    }
    return buildFallback(fallbackHref);
  }

  function applyDynamicBackLink() {
    applySharedTheme();

    var backLinks = Array.from(document.querySelectorAll('.top-links a'));
    if (!backLinks.length) {
      return;
    }

    var defaultHref = String(backLinks[0].getAttribute('href') || '').trim();
    var target = resolveBackTarget(defaultHref);

    backLinks.forEach(function (link) {
      link.setAttribute('href', target);
      link.setAttribute('data-dynamic-back', '1');
      if (target !== buildFallback(defaultHref)) {
        link.textContent = 'voltar para pagina anterior';
      }

      link.addEventListener('click', function (event) {
        if (window.history && window.history.length > 1) {
          event.preventDefault();
          window.history.back();
        }
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', applyDynamicBackLink);
  } else {
    applyDynamicBackLink();
  }
})();

