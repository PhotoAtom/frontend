import Redis from 'ioredis';
import { env } from '$env/dynamic/private';

export let valkeyClient: Redis;

/**
 * Create a client on server start if the
 * valkey client is a null value.
 */
export async function initializeValkeyClient() {
	// Check if Valkey Connection is setup
	if (valkeyClient == null) {
		console.log('Setting up Valkey Connection...');

		// Fetch all certificates from environment variables
		const caCert = await Bun.file(env.VALKEY_CA_CRT).text();
		const tlsCert = await Bun.file(env.VALKEY_TLS_CRT).text();
		const tlsKey = await Bun.file(env.VALKEY_TLS_KEY).text();

		// Initialise the client
		valkeyClient = new Redis({
			host: env.VALKEY_HOST,
			port: Number(env.VALKEY_PORT),
			password: env.VALKEY_PASSWORD,
			tls: {
				ca: caCert,
				cert: tlsCert,
				key: tlsKey
			}
		});

		console.log('Completed Setting up Valkey Connection');
	}
}
