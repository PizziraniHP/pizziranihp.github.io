(function () {
    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/\"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    function getPersonId() {
        const params = new URLSearchParams(window.location.search);
        return params.get("id");
    }

    function notFoundMessage(id) {
        return '<div class="empty-state">Registro nao encontrado para o ID ' + escapeHtml(id || "(vazio)") + ".</div>";
    }

    function parseJsonAllowingComments(rawText) {
        // Permite manter comentarios visuais no cadastro sem quebrar o carregamento.
        const withoutBlockComments = rawText.replace(/\/\*[\s\S]*?\*\//g, "");
        return JSON.parse(withoutBlockComments);
    }

    async function loadPerson() {
        const container = document.getElementById("personCard");
        const personId = getPersonId();

        if (!personId) {
            container.innerHTML = notFoundMessage("(sem id)");
            return;
        }

        try {
            let response = await fetch("dados/pessoas.json", { cache: "no-store" });
            if (!response.ok) {
                // Fallback para estrutura antiga, caso exista em algum ambiente.
                response = await fetch("data/pessoas.json", { cache: "no-store" });
            }
            if (!response.ok) {
                throw new Error("Falha ao carregar base de pessoas");
            }

            const rawText = await response.text();
            const data = parseJsonAllowingComments(rawText);
            const people = Array.isArray(data.people) ? data.people : [];
            const person = people.find(function (p) { return p.id === personId; });

            if (!person) {
                container.innerHTML = notFoundMessage(personId);
                return;
            }

            const nome = escapeHtml(person.nome || "Sem nome");
            const apelido = person.apelido ? '<p><strong>' + escapeHtml(person.apelido) + '</strong></p>' : "";
            const foto = person.foto ? '<img src="' + escapeHtml(person.foto) + '" alt="Foto de ' + nome + '">' : "";
            const resumo = person.resumo ? '<p class="person-summary">' + escapeHtml(person.resumo) + '</p>' : "";
            const texto = person.textoCompleto ? '<div class="person-text">' + escapeHtml(person.textoCompleto) + '</div>' : "";

            const galeria = Array.isArray(person.galeria) && person.galeria.length > 0
                ? '<section class="gallery"><h2>Galeria</h2><div class="gallery-grid">' +
                  person.galeria.map(function (imgPath) {
                      return '<img src="' + escapeHtml(imgPath) + '" alt="Imagem de ' + nome + '">';
                  }).join("") +
                  "</div></section>"
                : "";

            container.innerHTML =
                '<article>' +
                    '<div class="person-header">' +
                        foto +
                        '<div class="person-meta">' +
                            '<h1>' + nome + '</h1>' +
                            '<span class="id-chip">ID ' + escapeHtml(person.id) + '</span>' +
                            apelido +
                            resumo +
                        "</div>" +
                    "</div>" +
                    texto +
                    galeria +
                "</article>";
        } catch (error) {
            container.innerHTML = '<div class="empty-state">Nao foi possivel carregar o cadastro de pessoas.</div>';
            console.error(error);
        }
    }

    loadPerson();
})();
