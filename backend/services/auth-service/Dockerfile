FROM node:18-alpine AS builder

WORKDIR /app

# Copy root package files
COPY package.json ./
COPY package-lock.json* ./

# Copy workspace package files
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/auth-service/package.json ./backend/services/auth-service/

# Install dependencies
RUN npm install --legacy-peer-deps || npm install

# Copy source files
COPY backend/shared ./backend/shared
COPY backend/services/auth-service ./backend/services/auth-service

# Build shared first
WORKDIR /app/backend/shared
RUN npm run build || (echo "Shared build failed" && exit 1)

# Build auth-service
WORKDIR /app/backend/services/auth-service
RUN npm run build || (echo "Auth service build failed" && exit 1)

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/auth-service/package.json ./backend/services/auth-service/

# Copy built files
COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/auth-service/dist ./backend/services/auth-service/dist

# Copy node_modules
COPY --from=builder /app/node_modules ./node_modules

WORKDIR /app/backend/services/auth-service

EXPOSE 3001

ENV PORT=3001
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
