FROM oven/bun:1 AS build

WORKDIR /app/frontend

COPY . .

RUN bun install && \
  bun run build

FROM oven/bun:1 AS production

WORKDIR /app

# Valkey Connection Details
ENV VALKEY_HOST=localhost
ENV VALKEY_PORT=6379
ENV VALKEY_PASSWORD=PASSWORD
ENV VALKEY_CA_CRT=
ENV VALKEY_TLS_CRT=
ENV VALKEY_TLS_KEY=

# Keycloak Connection Details
ENV KEYCLOAK_REALM_URL=
ENV KEYCLOAK_CLIENT_ID=
ENV KEYCLOAK_CLIENT_SECRET=
ENV KEYCLOAK_REDIRECT_URI=

COPY --from=build /app/frontend/build ./build
# COPY --from=build /app/frontend/node_modules ./node_modules
# COPY --from=build /app/frontend/package.json ./package.json

EXPOSE 3000

ENTRYPOINT [ "bun", "/app/build/index.js" ]
