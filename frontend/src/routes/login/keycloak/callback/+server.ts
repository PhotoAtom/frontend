import { generateSessionToken, createSession, setSessionTokenCookie } from '$lib/server/session';
import { keycloak } from '$lib/server/keycloak';
import { decodeIdToken } from 'arctic';

import type { RequestEvent } from '@sveltejs/kit';
import type { OAuth2Tokens } from 'arctic';

export async function GET(event: RequestEvent): Promise<Response> {
	const code = event.url.searchParams.get('code');
	const state = event.url.searchParams.get('state');
	const storedState = event.cookies.get('photoatom_oauth_state') ?? null;
	const codeVerifier = event.cookies.get('photoatom_code_verifier') ?? null;

	if (code === null || state === null || storedState === null || codeVerifier === null) {
		return new Response(null, {
			status: 400
		});
	}
	if (state !== storedState) {
		return new Response(null, {
			status: 400
		});
	}

	let tokens: OAuth2Tokens;

	try {
		tokens = await keycloak.validateAuthorizationCode(code, codeVerifier);
	} catch (error) {
		console.log(error);
		// Invalid code or client credentials
		return new Response(null, {
			status: 400
		});
	}

	const claims = decodeIdToken(tokens.idToken());
	const userId = claims.sub;

	const accessToken = tokens.accessToken();
	const accessTokenExpiry = tokens.accessTokenExpiresAt();
	const refreshToken = tokens.refreshToken();

	const sessionToken = generateSessionToken();
	const session = await createSession(
		sessionToken,
		userId,
		accessToken,
		accessTokenExpiry,
		refreshToken
	);

	setSessionTokenCookie(event, sessionToken, session.expiresAt);
	return new Response(null, {
		status: 302,
		headers: {
			Location: '/'
		}
	});
}
