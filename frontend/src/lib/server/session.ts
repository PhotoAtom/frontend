import { valkeyClient } from './valkey';
import { encodeBase32LowerCaseNoPadding, encodeHexLowerCase } from '@oslojs/encoding';
import { sha256 } from '@oslojs/crypto/sha2';
import type { RequestEvent } from '@sveltejs/kit';
import { keycloak } from './keycloak';
import { OAuth2RequestError } from 'arctic';

/**
 * Generate a session token
 * @returns Session Token
 */
export function generateSessionToken(): string {
	const bytes = new Uint8Array(20);
	crypto.getRandomValues(bytes);
	const token = encodeBase32LowerCaseNoPadding(bytes);
	return token;
}

/**
 * Create a session and persist
 * it in the Valkey database
 * @param token Session Token
 * @param userId User ID
 * @returns Session object
 */
export async function createSession(
	token: string,
	userId: string,
	accessToken: string,
	accessTokenExpiry: Date,
	refreshToken: string
): Promise<Session> {
	// Generate Random Session ID for storing the session details
	const sessionId = encodeHexLowerCase(sha256(new TextEncoder().encode(token)));

	// Form the session object
	const session: Session = {
		id: sessionId,
		userId,
		expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30),
		accessToken,
		accessTokenExpiry,
		refreshToken
	};

	// Persist the session details in the Valkey Database
	// with planned expiry
	await valkeyClient.set(
		`session:${session.id}`,
		JSON.stringify({
			id: session.id,
			user_id: session.userId,
			expires_at: Math.floor(session.expiresAt.getTime() / 1000),
			access_token: session.accessToken,
			access_token_expiry: session.accessTokenExpiry.getTime(),
			refresh_token: session.refreshToken
		}),
		'EXAT',
		Math.floor(session.expiresAt.getTime() / 1000)
	);

	// Return session object
	return session;
}

/**
 * Validate and update session in Valkey database
 * Else delete the session if it has expired
 * @param token Session Token
 * @returns Session object if its valid
 */
export async function validateSessionToken(token: string): Promise<Session | null> {
	// Get encoded session ID
	const sessionId = encodeHexLowerCase(sha256(new TextEncoder().encode(token)));

	// Validate if session exists or not
	const item = await valkeyClient.get(`session:${sessionId}`);
	if (item === null) {
		return null;
	}

	// Parse the Session Details JSON
	const result = JSON.parse(item);

	// Form the session object from database
	const session: Session = {
		id: result.id,
		userId: result.user_id,
		expiresAt: new Date(result.expires_at * 1000),
		accessToken: result.access_token,
		accessTokenExpiry: new Date(result.access_token_expiry),
		refreshToken: result.refresh_token
	};

	// If session has expired, delete the session
	if (Date.now() >= session.expiresAt.getTime()) {
		await valkeyClient.del(`session:${sessionId}`);
		return null;
	}

	// Refresh the access tokens and the refresh tokens if the login
	// is still valid in Keycloak for API access
	try {
		const tokens = await keycloak.refreshAccessToken(session.refreshToken);

		session.accessToken = tokens.accessToken();
		session.accessTokenExpiry = tokens.accessTokenExpiresAt();
		session.refreshToken = tokens.refreshToken();

		await valkeyClient.set(
			`session:${session.id}`,
			JSON.stringify({
				id: session.id,
				user_id: session.userId,
				expires_at: session.expiresAt,
				access_token: session.accessToken,
				access_token_expiry: session.accessTokenExpiry.getTime(),
				refresh_token: session.refreshToken
			}),
			'EXAT',
			Math.floor(session.expiresAt.getTime() / 1000)
		);
	} catch (error) {
		if (error instanceof OAuth2RequestError) {
			await valkeyClient.del(`session:${sessionId}`);
			return null;
		}
	}

	// If session is 15 days old, renew session and update it in the database
	if (Date.now() >= session.expiresAt.getTime() - 1000 * 60 * 60 * 24 * 15) {
		session.expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 30);

		await valkeyClient.set(
			`session:${session.id}`,
			JSON.stringify({
				id: session.id,
				user_id: session.userId,
				expires_at: Math.floor(session.expiresAt.getTime() / 1000),
				access_token: session.accessToken,
				access_token_expiry: session.accessTokenExpiry.getTime(),
				refresh_token: session.refreshToken
			}),
			'EXAT',
			Math.floor(session.expiresAt.getTime() / 1000)
		);
	}

	// Return session object
	return session;
}

/**
 * Invalidate a session
 * @param sessionId Session ID
 */
export async function invalidateSession(sessionId: string): Promise<void> {
	await valkeyClient.del(`session:${sessionId}`);
}

/**
 * Set Session Token Cookie
 * @param event Request Event
 * @param token Session Token
 * @param expiresAt Session cookie expiry
 */
export function setSessionTokenCookie(event: RequestEvent, token: string, expiresAt: Date): void {
	event.cookies.set('session', token, {
		httpOnly: true,
		path: '/',
		secure: import.meta.env.PROD,
		sameSite: 'lax',
		expires: expiresAt
	});
}

/**
 * Delete Session Token Cookie
 * @param event Request Event
 */
export function deleteSessionTokenCookie(event: RequestEvent): void {
	event.cookies.set('session', '', {
		httpOnly: true,
		path: '/',
		secure: import.meta.env.PROD,
		sameSite: 'lax',
		maxAge: 0
	});
}

export interface Session {
	id: string;
	userId: string;
	expiresAt: Date;
	accessToken: string;
	accessTokenExpiry: Date;
	refreshToken: string;
}
