import { redirect } from "@sveltejs/kit";
import { validateSessionToken } from "$lib/server/session";
import { env } from "$env/dynamic/private";

import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async (event) => {
	// Check for session cookies
	if (event.cookies.get("session")) {
		const sessionToken = event.cookies.get("session")!;

		// If it exists, validate the session token
		const session = await validateSessionToken(sessionToken);

		// If the session does not exist
		// redirect to login page
		if (!session) {
			return redirect(302, "/login");
		}

		// API Hit Example
		const response = await fetch(`${env.PHOTOATOM_BACKEND_API_URL}/dummy`, {
			headers: {
				Authorization: `Bearer ${session?.accessToken}`,
			},
		});

		console.log(await response.text());
		console.log(response.status);
	} else {
		return redirect(302, "/login");
	}
};
