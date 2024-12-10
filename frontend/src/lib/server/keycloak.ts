import { KeyCloak } from 'arctic';
import { env } from '$env/dynamic/private';

// Keycloak Client
export const keycloak = new KeyCloak(
	env.KEYCLOAK_REALM_URL,
	env.KEYCLOAK_CLIENT_ID,
	env.KEYCLOAK_CLIENT_SECRET,
	env.KEYCLOAK_REDIRECT_URI
);
