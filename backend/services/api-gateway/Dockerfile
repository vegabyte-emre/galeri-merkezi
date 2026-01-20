FROM node:18-alpine AS builder

WORKDIR /app

# Copy root package files
COPY package.json ./
COPY package-lock.json* ./

# Copy workspace package files
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/api-gateway/package.json ./backend/services/api-gateway/

# Install dependencies
RUN npm install --legacy-peer-deps || npm install

# Copy source files
COPY backend/shared ./backend/shared
COPY backend/services/api-gateway ./backend/services/api-gateway

# Build shared first
WORKDIR /app/backend/shared
RUN npm run build || (echo "Shared build failed" && exit 1)

# Build api-gateway
WORKDIR /app/backend/services/api-gateway
RUN npm run build || (echo "API Gateway build failed" && exit 1)

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/api-gateway/package.json ./backend/services/api-gateway/

# Copy built files
COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/api-gateway/dist ./backend/services/api-gateway/dist

# Copy node_modules
COPY --from=builder /app/node_modules ./node_modules

WORKDIR /app/backend/services/api-gateway

EXPOSE 8000

ENV PORT=8000
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
