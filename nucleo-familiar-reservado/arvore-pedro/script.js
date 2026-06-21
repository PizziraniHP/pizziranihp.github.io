document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.card-pessoa img, .foto-zoom').forEach(img => {
        img.addEventListener('click', function () {
            document.getElementById('lightbox-img').src = this.src;
            document.getElementById('lightbox').classList.add('active');
        });
    });

    document.getElementById('lightbox').addEventListener('click', function () {
        this.classList.remove('active');
    });
});