FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/gallery-service/package.json ./backend/services/gallery-service/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/gallery-service ./backend/services/gallery-service

WORKDIR /app/backend/services/gallery-service
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/gallery-service/package.json ./backend/services/gallery-service/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/gallery-service/dist ./backend/services/gallery-service/dist

WORKDIR /app/backend/services/gallery-service

EXPOSE 3002

CMD ["node", "dist/index.js"]
















