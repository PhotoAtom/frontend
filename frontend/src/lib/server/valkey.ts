import Redis from 'ioredis';
import {
	VALKEY_HOST,
	VALKEY_PORT,
	VALKEY_PASSWORD,
	VALKEY_CA_CRT,
	VALKEY_TLS_CRT,
	VALKEY_TLS_KEY
} from '$env/static/private';

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
		const caCert = await Bun.file(VALKEY_CA_CRT).text();
		const tlsCert = await Bun.file(VALKEY_TLS_CRT).text();
		const tlsKey = await Bun.file(VALKEY_TLS_KEY).text();

		// Initialise the client
		valkeyClient = new Redis({
			host: VALKEY_HOST,
			port: Number(VALKEY_PORT),
			password: VALKEY_PASSWORD,
			tls: {
				ca: caCert,
				cert: tlsCert,
				key: tlsKey
			}
		});

		console.log('Completed Setting up Valkey Connection');
	}
}
