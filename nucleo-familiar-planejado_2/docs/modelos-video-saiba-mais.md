# Modelos de Video no Saiba Mais

Use os modelos abaixo para copiar e colar dentro da grade de cards do Saiba Mais.

## 1) Video local (arquivo no projeto)

Quando usar:
- Video salvo em imagens/imagens_smais/<pasta-da-pessoa>/
- Exemplo: imagens/imagens_smais/0101-lorena/lorena-4.mp4

Snippet pronto:

~~~html
<figure class="extra-item extra-item-small">
	<video controls preload="metadata" playsinline>
		<source src="../../imagens/imagens_smais/0101-lorena/lorena-4.mp4" type="video/mp4">
		Seu navegador nao suporta reproducao de video.
	</video>
	<p>Lorena -video de apresentacao.</p>
</figure>
~~~

Notas:
- Mantenha controls para facilitar play/pause.
- Se nao reproduzir, normalmente e codec nao compativel do MP4.

## 2) Video do YouTube (embed)

Quando usar:
- Video mais pesado.
- Melhor para desempenho da pagina.

Snippet pronto:

~~~html
<figure class="extra-item extra-item-small">
	<iframe
		src="https://www.youtube-nocookie.com/embed/SEU_VIDEO_ID"
		title="Video do YouTube"
		loading="lazy"
		allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
		referrerpolicy="strict-origin-when-cross-origin"
		allowfullscreen>
	</iframe>
	<p>Video incorporado do YouTube.</p>
</figure>
~~~

Como pegar SEU_VIDEO_ID:
1. Abra o link do video no YouTube.
2. Copie o valor depois de v=.
3. Exemplo: https://www.youtube.com/watch?v=ABC123xyz89
4. ID: ABC123xyz89
5. URL embed: https://www.youtube-nocookie.com/embed/ABC123xyz89

## Checklist rapido

1. Confirmar caminho do arquivo local (se for MP4 local).
2. Testar em desktop e celular.
3. Evitar autoplay com som.
4. Manter uma foto de capa no card anterior ou ao lado (boa usabilidade).

