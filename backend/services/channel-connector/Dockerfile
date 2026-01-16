FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/channel-connector/package.json ./backend/services/channel-connector/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/channel-connector ./backend/services/channel-connector

WORKDIR /app/backend/services/channel-connector
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/channel-connector/package.json ./backend/services/channel-connector/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/channel-connector/dist ./backend/services/channel-connector/dist

WORKDIR /app/backend/services/channel-connector

EXPOSE 3006

CMD ["node", "dist/index.js"]
















