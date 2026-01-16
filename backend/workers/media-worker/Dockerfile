FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/workers/media-worker/package.json ./backend/workers/media-worker/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/workers/media-worker ./backend/workers/media-worker

WORKDIR /app/backend/workers/media-worker
RUN npm run build

FROM node:18-alpine

# Install sharp dependencies
RUN apk add --no-cache vips-dev

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/workers/media-worker/package.json ./backend/workers/media-worker/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/workers/media-worker/dist ./backend/workers/media-worker/dist

WORKDIR /app/backend/workers/media-worker

CMD ["node", "dist/index.js"]
















