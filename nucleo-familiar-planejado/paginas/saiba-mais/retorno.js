(function () {
  function getThemeHref() {
    var path = (window.location.pathname || '').toLowerCase();
    if (path.indexOf('/paginas/saiba-mais/') !== -1) {
      return 'tema-global.css';
    }
    if (path.indexOf('/paginas/extra-saiba-mais/') !== -1) {
      return '../saiba-mais/tema-global.css';
    }
    return '';
  }

  function applySharedTheme() {
    var href = getThemeHref();
    if (!href) return;
    if (document.querySelector('link[data-shared-theme="1"]')) return;

    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = href + '?v=20260706b';
    link.setAttribute('data-shared-theme', '1');
    document.head.appendChild(link);
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
    if (!backLinks.length) return;

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
