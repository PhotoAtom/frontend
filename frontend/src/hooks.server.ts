import type { Handle } from '@sveltejs/kit';
import { initializeValkeyClient } from '$lib/server/valkey';

export const handle: Handle = async ({ event, resolve }) => {
	// Initialize the valkey client
	// If not already initialized
	await initializeValkeyClient();

	const response = await resolve(event);
	return response;
};
