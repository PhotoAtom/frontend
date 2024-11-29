import type { PageServerLoad } from './$types';
import { valkeyClient } from '$lib/server/valkey';

export const load: PageServerLoad = async () => {
	// Just checking connection here
	console.log(await valkeyClient.get('key'));
};
