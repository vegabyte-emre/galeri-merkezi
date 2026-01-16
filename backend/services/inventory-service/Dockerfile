FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/inventory-service/package.json ./backend/services/inventory-service/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/inventory-service ./backend/services/inventory-service

WORKDIR /app/backend/services/inventory-service
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/inventory-service/package.json ./backend/services/inventory-service/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/inventory-service/dist ./backend/services/inventory-service/dist

WORKDIR /app/backend/services/inventory-service

EXPOSE 3003

CMD ["node", "dist/index.js"]
















