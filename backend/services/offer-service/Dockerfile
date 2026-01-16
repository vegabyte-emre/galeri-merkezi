FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/offer-service/package.json ./backend/services/offer-service/

RUN npm ci

COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/offer-service ./backend/services/offer-service

WORKDIR /app/backend/services/offer-service
RUN npm run build

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/offer-service/package.json ./backend/services/offer-service/

RUN npm ci --production

COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/offer-service/dist ./backend/services/offer-service/dist

WORKDIR /app/backend/services/offer-service

EXPOSE 3004

CMD ["node", "dist/index.js"]
















