# syntax=docker/dockerfile:experimental

# Build stage: Install dependencies
# ===
FROM oven/bun:latest AS dependencies
WORKDIR /srv
COPY package.json bun.lock ./
RUN --mount=type=cache,target=/usr/local/share/.cache/bun bun install

# Build stage: Run "bun build"
# ===
FROM dependencies AS build
COPY index.html tsconfig.json vite.config.ts ./
COPY src ./src
RUN bun run build

# Build the demo image
FROM node:22

ARG HOST=0.0.0.0
ARG PORT=80

ENV PORT=$PORT
ENV HOST=$HOST

WORKDIR /srv

RUN npm install -g nodemon

# Import code, build assets
COPY --from=build /srv/node_modules ./node_modules
COPY --from=build /srv/package.json ./package.json
COPY --from=build /srv/bun.lock ./bun.lock
COPY --from=build /srv/dist ./dist

CMD ["node", "dist/server/server.js"]
