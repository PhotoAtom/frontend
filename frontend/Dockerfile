FROM oven/bun:1 AS build

WORKDIR /app/frontend

COPY . .

RUN bun install && \
  bun run build

FROM oven/bun:1 AS production

WORKDIR /app

ARG CUSTOM_GROUP=photoatom_group
ARG CUSTOM_GROUP_ID=1001
ARG CUSTOM_USER=photoatom
ARG CUSTOMER_USER_ID=1001

RUN groupadd -g ${CUSTOM_GROUP_ID} ${CUSTOM_GROUP} && \
  useradd -m -u ${CUSTOMER_USER_ID} -g ${CUSTOM_GROUP} ${CUSTOM_USER}

# Valkey Connection Details
ENV VALKEY_HOST=
ENV VALKEY_PORT=
ENV VALKEY_PASSWORD=
ENV VALKEY_CA_CRT=
ENV VALKEY_TLS_CRT=
ENV VALKEY_TLS_KEY=

# Keycloak Connection Details
ENV KEYCLOAK_REALM_URL=
ENV KEYCLOAK_CLIENT_ID=
ENV KEYCLOAK_CLIENT_SECRET=
ENV KEYCLOAK_REDIRECT_URI=

# PhotoAtom Connection Details
ENV PHOTOATOM_BACKEND_API_URL=

COPY --from=build /app/frontend/build ./build

USER ${CUSTOM_USER}
EXPOSE 3000

ENTRYPOINT [ "bun", "/app/build/index.js" ]
