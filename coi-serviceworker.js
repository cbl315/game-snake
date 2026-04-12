// Service worker to inject Cross-Origin Isolation headers for GitHub Pages
addEventListener("fetch", (event) => {
	event.respondWith(
		fetch(event.request).then((response) => {
			const newHeaders = new Headers(response.headers);
			newHeaders.set("Cross-Origin-Embedder-Policy", "credentialless");
			newHeaders.set("Cross-Origin-Opener-Policy", "same-origin");
			return new Response(response.body, {
				status: response.status,
				statusText: response.statusText,
				headers: newHeaders,
			});
		})
	);
});
