FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/workers/search-indexer/package.json ./backend/workers/search-indexer/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/workers/search-indexer ./backend/workers/search-indexer

WORKDIR /app/backend/workers/search-indexer
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/workers/search-indexer/package.json ./backend/workers/search-indexer/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/workers/search-indexer/dist ./backend/workers/search-indexer/dist

WORKDIR /app/backend/workers/search-indexer

CMD ["node", "dist/index.js"]
















