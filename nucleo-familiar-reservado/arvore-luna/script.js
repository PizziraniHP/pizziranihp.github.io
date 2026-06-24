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
        link.textContent = 'Saiba mais';
        link.setAttribute('aria-label', 'Saiba mais sobre o ID ' + personId);

        wrap.appendChild(link);
        card.appendChild(wrap);
    });
});