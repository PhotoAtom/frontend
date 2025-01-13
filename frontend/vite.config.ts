import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig(async ({ command, mode }) => {

	return {
		plugins: [sveltekit()],
		server: {
			https: {
				cert: await Bun.file(import.meta.env.TLS_CERT ?? '/dev/null').text(),
				key: await Bun.file(import.meta.env.TLS_CERT_KEY ?? '/dev/null').text(),
			},
			proxy: {}
		}
	};
});
