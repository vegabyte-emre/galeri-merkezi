FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/workers/notification-worker/package.json ./backend/workers/notification-worker/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/workers/notification-worker ./backend/workers/notification-worker

WORKDIR /app/backend/workers/notification-worker
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/workers/notification-worker/package.json ./backend/workers/notification-worker/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/workers/notification-worker/dist ./backend/workers/notification-worker/dist

WORKDIR /app/backend/workers/notification-worker

CMD ["node", "dist/index.js"]
















