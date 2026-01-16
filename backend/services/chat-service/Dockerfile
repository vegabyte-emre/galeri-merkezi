FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/chat-service/package.json ./backend/services/chat-service/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/chat-service ./backend/services/chat-service

WORKDIR /app/backend/services/chat-service
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/chat-service/package.json ./backend/services/chat-service/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/chat-service/dist ./backend/services/chat-service/dist

WORKDIR /app/backend/services/chat-service

EXPOSE 3005

CMD ["node", "dist/index.js"]
















