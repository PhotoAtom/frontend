import Redis from 'ioredis';
import {
	VALKEY_HOST,
	VALKEY_PORT,
	VALKEY_PASSWORD,
	VALKEY_CA_CRT,
	VALKEY_TLS_CRT,
	VALKEY_TLS_KEY
} from '$env/static/private';
import { read } from '$app/server';

export default new Redis({
	host: VALKEY_HOST,
	port: VALKEY_PORT,
	password: VALKEY_PASSWORD,
	tls: {
		ca: read(VALKEY_CA_CRT),
		cert: read(VALKEY_TLS_CRT),
		key: read(VALKEY_TLS_KEY)
	}
});
