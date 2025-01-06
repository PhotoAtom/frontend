import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(async ({ mode }) => {

	const env = loadEnv(mode, process.cwd(), '');

	return {
		plugins: [sveltekit()],
		server: {
			https: {
				cert: await Bun.file(env.TLS_CERT).text(),
				key: await Bun.file(env.TLS_CERT_KEY).text(),
			},
			proxy: {}
		}
	};
});
