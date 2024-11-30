import { KeyCloak } from 'arctic';
import {
	KEYCLOAK_REALM_URL,
	KEYCLOAK_CLIENT_ID,
	KEYCLOAK_CLIENT_SECRET,
	KEYCLOAK_REDIRECT_URI
} from '$env/static/private';

// Keycloak Client
export const keycloak = new KeyCloak(
	KEYCLOAK_REALM_URL,
	KEYCLOAK_CLIENT_ID,
	KEYCLOAK_CLIENT_SECRET,
	KEYCLOAK_REDIRECT_URI
);
