FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/auth-service/package.json ./backend/services/auth-service/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/auth-service ./backend/services/auth-service

WORKDIR /app/backend/services/auth-service
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/auth-service/package.json ./backend/services/auth-service/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/auth-service/dist ./backend/services/auth-service/dist

WORKDIR /app/backend/services/auth-service

EXPOSE 3001

CMD ["node", "dist/index.js"]
















