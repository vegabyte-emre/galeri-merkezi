FROM node:18-alpine AS builder

WORKDIR /app

# Copy root package files
COPY package.json ./
COPY package-lock.json* ./

# Copy workspace package files
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/inventory-service/package.json ./backend/services/inventory-service/

# Install dependencies
RUN npm install --legacy-peer-deps || npm install

# Copy source files
COPY backend/shared ./backend/shared
COPY backend/services/inventory-service ./backend/services/inventory-service

# Build shared first
WORKDIR /app/backend/shared
RUN npm run build || (echo "Shared build failed" && exit 1)

# Build inventory-service
WORKDIR /app/backend/services/inventory-service
RUN npm run build || (echo "Inventory service build failed" && exit 1)

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/inventory-service/package.json ./backend/services/inventory-service/

# Copy built files
COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/inventory-service/dist ./backend/services/inventory-service/dist

# Copy node_modules
COPY --from=builder /app/node_modules ./node_modules

WORKDIR /app/backend/services/inventory-service

EXPOSE 3003

ENV PORT=3003
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
